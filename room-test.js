// Executes actual room actions and combat effects using the game's VM hooks.
const assert=require("assert"),h=require("./smoke-test.js");
const vm=require("vm");
const content=h.browser.window.XIYOU_ROOM_CONTENT,chapters=h.browser.window.XIYOU_CHAPTERS.chapters;
let game=h.game,checks=0;
function fresh(hero=1){game.select(hero);game.startRun();game.grantCoins(500);return game.state().player;}
function fixture(hero=1){const p=fresh(hero);p.hp=30;p.curse=1;p.burnTime=2;p.skillCd=4;p.dashCd=3;p.relicBag=["mirror"];p.shieldCharges=0;return p;}
function catalog(){return content.build(game.roomContext());}
function ids(){return [...h.screen.innerHTML.matchAll(/data-choice-id="([^"]+)"/g)].map(m=>m[1]);}
function click(id){const i=ids().indexOf(id);assert(i>=0,`missing choice ${id}`);h.screen.dataElements["room-option"][i].click();}
function snapshot(){const s=game.state();return JSON.stringify({p:s.player,coins:s.coins,xp:s.xp,enemies:s.enemies});}
function roomChapter(type,predicate=()=>true){return chapters.findIndex((_,i)=>{const plan=h.browser.window.XIYOU_ROOMS.generate(i,h.browser.window.XIYOU_BALANCE.rooms);return plan.main.some((id,j)=>plan.rooms[id].type===type&&predicate(j));});}

// Every listed service, item and event branch changes a real game resource.
for(const group of ["shrine","shop","reward","guanyin","rest"]){
  fixture();const choices=catalog()[group];
  for(const entry of choices){
    fixture();const choice=catalog()[group].find(c=>c.id===entry.id);
    assert(choice.visible()&&!choice.check(),`${group}:${entry.id} valid fixture`);
    const before=snapshot();const result=choice.run();game.grantCoins(-choice.cost);
    assert.notStrictEqual(result,false,`${group}:${entry.id} executes`);
    assert.notStrictEqual(snapshot(),before,`${group}:${entry.id} must have a real effect`);checks++;
  }
}
fixture();const events=catalog().events;
for(const e of events)for(const entry of e.choices){
  fixture();const choice=catalog().events.find(v=>v.id===e.id).choices.find(c=>c.id===entry.id);
  assert(choice.visible()&&!choice.check(),`${e.id}:${entry.id} valid fixture`);
  const before=snapshot();const result=choice.run();game.grantCoins(-choice.cost);
  assert.notStrictEqual(result,false);assert.notStrictEqual(snapshot(),before,`${e.id}:${entry.id} must work`);checks++;
}
// All five heroes receive their own effective weapon, skill and new-skill upgrades.
for(let hero=0;hero<5;hero++)for(const id of ["weapon","active","skill"]){
  fixture(hero);const c=catalog().shop.find(c=>c.id===id),before=snapshot();
  assert(!c.check());c.run();assert.notStrictEqual(snapshot(),before);checks++;
}

// Rotation covers an entire stable pool before repeating, without duplicate cards.
for(const size of [4,6]){
  const pool=Array.from({length:24},(_,i)=>({id:String(i)}));let history=[],seen=new Set();
  for(let n=0;n<24/size;n++){
    const roll=content.rotate(pool,size,history);history=roll.history;
    for(const id of roll.ids){assert(!seen.has(id));seen.add(id);}
  }
  assert.strictEqual(seen.size,24);
}
const patterns=new Set();for(let n=0;n<40;n++){fresh();game.enterRoom("shop");patterns.add(ids().join(","));}
assert(patterns.size>10,"fresh runs rotate stock");

// Unowned relics never appear as sacrifices. Invalid and ineffective actions cannot spend.
let p=fresh();game.enterRoom("event");game.setOffer(["sacrifice","listen","help"],"old_man");
assert(!ids().includes("sacrifice"));assert(!h.screen.innerHTML.includes("舍弃袋首「无」"));
p.relicBag=["mirror"];p.armor=.49;game.setOffer(["sacrifice"],"old_man");
let before=snapshot();click("sacrifice");assert.strictEqual(snapshot(),before);assert(h.screen.innerHTML.includes("减伤已达"));
p=fresh();game.enterRoom("shop");game.setOffer(["food","incense","weapon","shop_relic"]);
before=snapshot();click("food");click("incense");assert.strictEqual(snapshot(),before);
assert(h.screen.innerHTML.includes("生命已满")&&h.screen.innerHTML.includes("当前没有心魔"));
p.taken.weapon_tangseng=5;game.showRoomChoice();before=snapshot();click("weapon");assert.strictEqual(snapshot(),before);
p.relicBag=["mirror","lotus"];game.showRoomChoice();before=snapshot();click("shop_relic");assert.strictEqual(snapshot(),before);
assert(h.screen.innerHTML.includes("法宝袋已满"));
p.relicBag=[];game.grantCoins(-game.state().coins);game.showRoomChoice();before=snapshot();click("shop_relic");assert.strictEqual(snapshot(),before);assert(h.screen.innerHTML.includes("铜钱不足"));

// Successful purchases deduct exactly once and remain on sale until explicitly leaving.
const shopChapter=roomChapter("shop");p=fresh();game.enterRoom("shop",shopChapter);game.setOffer(["shop_relic","weapon"]);
const relicId=game.state().save.roomRewardId,price=catalog().shop.find(c=>c.id==="shop_relic").cost;
const balance=game.state().coins;click("shop_relic");
assert.strictEqual(game.state().mode,"room");assert.strictEqual(game.state().coins,balance-price);assert(p.relicBag.includes(relicId));
before=snapshot();click("shop_relic");assert.strictEqual(snapshot(),before);
const stock=JSON.stringify(game.state().roomOffer.ids),bought=JSON.stringify(game.state().roomOffer.bought);
game.showMap();h.screen.querySelector("#map-back").click();assert.strictEqual(JSON.stringify(game.state().roomOffer.ids),stock);
game.saveRun();game=h.reload();assert.strictEqual(JSON.stringify(game.state().roomOffer.ids),stock);assert.strictEqual(JSON.stringify(game.state().roomOffer.bought),bought);
before=snapshot();click("shop_relic");assert.strictEqual(snapshot(),before);
click("weapon");assert.strictEqual(game.state().player.weaponRank,1);
game.showMap();h.windowHandlers.keydown({key:"Escape",target:{},preventDefault(){}});assert.strictEqual(game.state().mode,"room","Escape must return to room choices");

// Shrines after index 3 grant healing only once, including reload and map round trips.
const shrineChapter=roomChapter("shrine",j=>j>3);assert(shrineChapter>=0);
p=fresh();p.hp=20;game.enterRoom("shrine",shrineChapter);const healed=p.hp,offered=JSON.stringify(game.state().roomOffer.ids);
assert.strictEqual(healed,20+Math.ceil(p.maxHp*.08));game.showMap();game.saveRun();game=h.reload();h.screen.querySelector("#map-back").click();
assert.strictEqual(game.state().player.hp,healed);assert.strictEqual(JSON.stringify(game.state().roomOffer.ids),offered);
game.saveRun();game=h.reload();assert.strictEqual(game.state().player.hp,healed);
assert.strictEqual(game.state().mode,"room","saved map returns to its actual room");

// Battle reward is paid only after clear, and survives saving during battle.
const eventChapter=roomChapter("event");p=fresh();game.enterRoom("event",eventChapter);game.setOffer(["fight"],"bandits");
const expected=18+Math.floor(game.roomContext().tier),coins=game.state().coins;click("fight");
assert.strictEqual(game.state().mode,"playing");assert.strictEqual(game.state().enemies.length,3);assert.strictEqual(game.state().coins,coins);
game.update(.01);assert.strictEqual(game.state().roomType,"event","live enemies block completion");
game.saveRun();game=h.reload();for(const enemy of game.state().enemies)enemy.dead=true;
game.update(.01);assert.strictEqual(game.state().coins,coins+expected);assert.notStrictEqual(game.state().roomType,"event");

// Full bags keep fragments; invalid IDs cannot corrupt inventory.
p=fresh();p.relicBag=["mirror","lotus"];game.addRelicFragments(3);assert.strictEqual(p.relicFragments,3);
p.relicBag.pop();game.addRelicFragments(0);assert.strictEqual(p.relicFragments,0);assert.strictEqual(p.relicBag.length,2);
before=snapshot();assert.strictEqual(game.storeRelic("missing"),false);assert.strictEqual(snapshot(),before);

// Instant medicine preserves active buffs, consumes one actual item, and obeys no-effect checks.
p=fresh();h.screen.querySelector("#story-go").click();p.hp=20;game.activateRelic("mirror");p.relicBag=["bottle"];
game.useRelic();assert.strictEqual(p.relic,"mirror");assert.strictEqual(p.relicBag.length,0);assert(p.hp>20);
p.hp=p.maxHp;p.relicBag=["bottle"];game.useRelic();assert.strictEqual(p.relicBag.length,1);
p.relicBag=["lifeledger"];p.skillCd=0;p.dashCd=0;game.useRelic();assert.strictEqual(p.relicBag.length,1);
p.skillCd=6;game.useRelic();assert.strictEqual(p.skillCd,0);assert.strictEqual(p.relicBag.length,0);assert(p.hp<p.maxHp);
game.updateTouchStatus();assert.strictEqual(h.elements["touch-relic"].disabled,true);
game.pause();assert(h.screen.innerHTML.includes("尚未持有法宝"));
p.relicBag=["lifeledger","mirror"];game.pause();game.pause();h.screen.dataElements["bag-first"][1].click();assert.strictEqual(p.relicBag[0],"mirror");

// Offensive relics produce real attacks; defensive relics reduce actual incoming damage.
for(const id of ["fan","pagoda","needle","gourd"]){
  p=fresh();h.screen.querySelector("#story-go").click();const enemy=game.state().enemies[0];enemy.x=p.x+40;enemy.y=p.y;enemy.hp=10000;enemy.maxHp=10000;
  const hp=enemy.hp,shots=game.state().projectiles.length;game.activateRelic(id);game.updatePassives(.2);
  assert(enemy.hp<hp||game.state().projectiles.length>shots,`${id} has combat effect`);
}
for(const id of ["waterbead","pearl","circle"]){
  p=fresh();h.screen.querySelector("#story-go").click();p.hp=p.maxHp;p.invuln=0;p.shieldCharges=0;
  game.hurtPlayer(40,null,"test","water","projectile");const raw=p.maxHp-p.hp;
  p.hp=p.maxHp;p.invuln=0;game.activateRelic(id);game.hurtPlayer(40,null,"test","water","projectile");
  assert(p.maxHp-p.hp<raw,`${id} protects the player`);
}
p=fresh();p.hp=20;game.activateRelic("lotus");game.updatePassives(1);assert(p.hp>=22.2);
p=fresh();game.activateRelic("peach");const max=p.maxHp;game.activateRelic("peach");assert.strictEqual(p.maxHp,max);
p=fresh();p.hp=20;p.synergies=["relic_hunt"];game.storeRelic("mirror");assert.strictEqual(p.hp,38,"pickup synergy matches its description");

// The mirror's crit chance and the shop's hero-specific bonuses affect combat.
p=fresh();h.screen.querySelector("#story-go").click();let enemy=game.state().enemies[0];enemy.hp=10000;enemy.maxHp=10000;
vm.runInContext("globalThis.savedRandom=Math.random;Math.random=()=>.2",h.browser);
let hp=enemy.hp;game.damageEnemy(enemy,100);const normalHit=hp-enemy.hp;
game.activateRelic("mirror");hp=enemy.hp;game.damageEnemy(enemy,100);assert(hp-enemy.hp>normalHit);
vm.runInContext("Math.random=globalThis.savedRandom",h.browser);
for(let hero=0;hero<5;hero++){
  p=fresh(hero);p.skillHaste=.35;catalog().shop.find(c=>c.id==="active").run();assert(p.skillHaste<=.35,"upgrading never worsens cooldown");
}
p=fresh(1);game.select(1,0,1);h.screen.querySelector("#story-go").click();catalog().shop.find(c=>c.id==="active").run();
enemy=game.state().enemies[0];enemy.x=p.x+50;enemy.y=p.y;game.skill();assert.strictEqual(enemy.allyTime,7,"Tang monk upgrade extends conversion");
p=fresh(0);h.screen.querySelector("#story-go").click();catalog().shop.find(c=>c.id==="active").run();
game.skill();game.update(.2);assert(game.state().projectiles.some(shot=>shot.color==="#e8bb78"&&Math.abs(shot.damage-11*1.08)<.001),"clone shots gain promised damage");
p=fresh(4);h.screen.querySelector("#story-go").click();p.momentum=1;game.attack();const damage=game.state().projectiles.at(-1).damage;
catalog().shop.find(c=>c.id==="active").run();game.attack();assert(game.state().projectiles.at(-1).damage>damage,"dragon tide upgrade changes weapon damage");
console.log(`Room regression passed: ${checks} real option/hero effects, rotation, purchases, inventory, save, map, battle rewards and relic combat effects.`);
