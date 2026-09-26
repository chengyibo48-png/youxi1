// Route, save, five heroes, boss mechanics, mobile settings and ending.
const fs=require("fs"),vm=require("vm"),assert=require("assert"),path=require("path");
const root=__dirname,storage=new Map(),noop=()=>{};
const ctx=new Proxy({}, {get:(o,k)=>o[k]??noop,set:(o,k,v)=>(o[k]=v,true)});
class Element{
  constructor(dataset={}){this.dataset=dataset;this.handlers={};this.style={};this.value="";this.checked=false;this.textContent="";this.classList={add:noop,remove:noop,toggle:noop};}
  addEventListener(n,f){this.handlers[n]=f;}
  click(){this.handlers.click?.({target:this,preventDefault:noop});}
  getContext(){return ctx;}
  getBoundingClientRect(){return {left:0,top:0,width:100,height:100};}
  setPointerCapture(){}
  requestFullscreen(){return Promise.resolve();}
}
class Screen extends Element{
  set innerHTML(s){this.markup=s;this.elements=new Map();}
  get innerHTML(){return this.markup||"";}
  querySelector(s){if(!this.elements)this.elements=new Map();if(!this.elements.has(s))this.elements.set(s,new Element());return this.elements.get(s);}
  querySelectorAll(s){
    const m=s.match(/^\[data-([a-z-]+)\]$/);if(!m)return [];
    const key=m[1],prop=key.replace(/-([a-z])/g,(_,c)=>c.toUpperCase()),out=[];
    for(const hit of this.innerHTML.matchAll(new RegExp('<button[^>]*data-'+key+'="([^"]+)"[^>]*>','g'))){
      const el=new Element({[prop]:hit[1]});el.disabled=/\sdisabled(?:\s|>)/.test(hit[0]);out.push(el);
    }
    this.dataElements??={};this.dataElements[key]=out;return out;
  }
}
const screen=new Screen(),elements={game:new Element(),screen,"touch-controls":new Element(),joystick:new Element(),"joystick-knob":new Element(),"touch-skill":new Element(),"touch-dash":new Element(),"touch-relic":new Element(),"touch-relic-name":new Element(),"touch-pause":new Element(),"touch-skill-cd":new Element(),"touch-dash-cd":new Element(),"game-shell":new Element()};
elements.game.clientWidth=720;
const windowHandlers={},documentHandlers={};
const browser={
  document:{documentElement:{dataset:{}},getElementById:id=>elements[id],createElement:()=>new Element(),addEventListener:(n,f)=>documentHandlers[n]=f,hidden:false},
  window:{innerWidth:1280,addEventListener:(n,f)=>windowHandlers[n]=f},
  localStorage:{getItem:k=>storage.get(k)||null,setItem:(k,v)=>storage.set(k,v),removeItem:k=>storage.delete(k)},
  requestAnimationFrame:noop,setTimeout:noop,console
};
vm.createContext(browser);
for(const name of ["lore.js","journey81.js","systems.js","chapters.js","balance.js","item-pool.js","rooms.js","audio.js","progression.js","room-content.js"])
  vm.runInContext(fs.readFileSync(path.join(root,name),"utf8"),browser,{filename:name});
const trials=browser.window.XIYOU_JOURNEY81.trials;
const systems=browser.window.XIYOU_SYSTEMS;
assert.strictEqual(trials.length,81);
assert.strictEqual(trials[80].trialName,"通天河归渡");
assert(trials.every((t,i)=>t.trial===i+1&&(!t.boss||t.kind==="boss")));
assert(trials.every((t,i)=>i===0||t.ch>=trials[i-1].ch),"original chapter order");
assert.deepStrictEqual(Array.from(trials[12].mobs),["bee","tigerScout","windling"]);
assert.deepStrictEqual(Array.from(trials[19].mobs),["disguised","bonelet","shade"]);
assert.deepStrictEqual(Array.from(trials[23].mobs),["lotusling","stone","shade"]);
assert.strictEqual(systems.attackFactor("water","fire"),1.12);
assert.strictEqual(systems.attackFactor("fire","water"),.92);
assert.strictEqual(systems.nurtureForTrial("water","wood"),true,"water nourishes wood");
assert.strictEqual(systems.nurtureForTrial("water","fire"),false,"unrelated terrain gives no free buff");
assert.strictEqual(browser.window.XIYOU_SKILL_CARDS.length,5,"each hero has a third active skill");
assert(browser.window.XIYOU_ITEM_POOL.some(item=>item.id==="lifeledger"&&item.type==="curse"&&item.minTrial>=45));
assert(trials.every(t=>systems.themeForTrial(t.trial)&&systems.ordealForTrial(t)),"all trials have local encounter data");
assert(trials.filter(t=>t.boss).every(t=>systems.tactics[t.boss]),"all named bosses have readable counterplay hints");
assert(systems.themeForTrial(15).mobs.includes("fishling"),"Flowing Sands has water enemies");
assert(systems.themeForTrial(32).mobs.includes("fishling"),"Blackwater River has water enemies");
assert.strictEqual(systems.sceneForTrial(trials[50]),"river","Bibo Pool has river scenery");
const routeLengths=new Set(),routePatterns=new Set(),optionalSeen=new Set();
for(let n=0;n<37;n++){
  const plan=browser.window.XIYOU_ROOMS.generate(n,browser.window.XIYOU_BALANCE.rooms);
  const same=browser.window.XIYOU_ROOMS.generate(n,browser.window.XIYOU_BALANCE.rooms);
  assert(browser.window.XIYOU_ROOMS.validate(plan,browser.window.XIYOU_BALANCE.rooms),"validated route "+n);
  const types=plan.main.map(id=>plan.rooms[id].type);
  assert.strictEqual(types.join(","),same.main.map(id=>same.rooms[id].type).join(","),"save-stable random route");
  assert(types.filter(type=>["combat","elite","boss"].includes(type)).length>=5,"combat is the majority");
  assert(types.filter(type=>["shop","event","rest","reward","guanyin"].includes(type)).length<=2,"optional rooms are not mandatory");
  routeLengths.add(types.length);routePatterns.add(types.join(","));
  for(const type of types)optionalSeen.add(type);
}
assert.deepStrictEqual([...routeLengths].sort(),[6,7,8]);
assert(routePatterns.size>25,"room order varies by chapter");
for(const type of ["shop","event","rest","reward"])assert(optionalSeen.has(type),type+" appears on some routes");
const original=fs.readFileSync(path.join(root,"game.js"),"utf8");
const source=original.replace(/\n  home\(\);\s*requestAnimationFrame\(frame\);\s*\}\)\(\);\s*$/,
`\n  globalThis.__test={home,menu,library,settingsPage,startRun,resumeRun,spawnMob,spawnBoss,bossAttack,damageEnemy,hurtPlayer,rollRelic,activateRelic,useRelic,showMap,showTrialEvent,showEncounter,showRoomChoice,completeTrial,advanceStage,beginRoom,finishRoom,update,updatePassives,drawWorld,saveRun,readSave,skill,attack,pause,applyUpgrade,roomContext,choiceReason,storeRelic,addRelicFragments,relicUseReason,updateTouchStatus,
enterRoom:(type,index=0)=>{stageIndex=index;roomPlan=rooms.generate(index,BAL.rooms);roomIndex=Math.max(0,roomPlan.main.findIndex(id=>roomPlan.rooms[id].type===type));roomAt(roomIndex).type=type;roomStarted=true;roomChoice=-1;roomRewardId=null;roomOffer=null;enemies=[];showRoomChoice();},
setOffer:(ids,eventId=null)=>{roomOffer.ids=ids;roomOffer.eventId=eventId;roomOffer.bought=[];showRoomChoice();},
grantCoins:n=>coins+=n,select:(h,w=0,s=0)=>{selectedHero=h;selectedWeapon=w;selectedSkill=s;},state:()=>({mode,stageIndex,roomIndex,roomType:roomAt(roomIndex).type,roomPlan,roomOffer,player,enemies,projectiles,effects,meta,coins,xp,level,kills,bossCursor,save:readSave()}),pixels:heroPixels};\n  home();requestAnimationFrame(frame);\n})();`);
assert.notStrictEqual(source,original,"test hooks installed");
vm.runInContext(source,browser,{filename:"game.js"});
let game=browser.__test;
const chapters=browser.window.XIYOU_CHAPTERS.chapters;
assert.strictEqual(chapters.length,37);
assert.strictEqual(chapters[0].firstTrial,1);
assert.strictEqual(chapters.at(-1).lastTrial,81);
assert(chapters.every((c,i)=>i===0||c.firstTrial===chapters[i-1].lastTrial+1));
assert.strictEqual(game.state().mode,"home");
game.settingsPage();
assert(screen.innerHTML.includes("画面比例")&&screen.innerHTML.includes("切换全屏"));
screen.querySelector("#settings-back").click();
game.menu();assert(screen.innerHTML.includes("白龙马"));
game.select(1);game.startRun();
assert.strictEqual(game.state().mode,"story");
assert.strictEqual(game.state().save.version,18);
for(let i=0;i<chapters.length;i++){
  assert.strictEqual(game.state().stageIndex,i);
  assert.strictEqual(game.state().mode,"story");
  screen.querySelector("#story-go").click();
  assert.strictEqual(game.state().roomType,"combat");
  assert(game.state().enemies.length>=4,"combat starts with real enemies");
  if(i===0){game.update(.016);assert.strictEqual(game.state().roomIndex,0,"combat must not clear while enemies live");}
  const plan=game.state().roomPlan;
  assert(plan.main.some(id=>plan.rooms[id].type==="shrine"),"land shrine guaranteed");
  for(let room=0;room<plan.main.length;room++){
    const st=game.state(),type=st.roomType;
    assert.strictEqual(st.roomIndex,room,"room order chapter "+i);
    if(type==="combat"||type==="elite"){
      game.finishRoom();
    }else if(type==="boss"){
      for(const ref of chapters[i].bossRefs){
        const boss=game.state().enemies.find(e=>e.boss&&!e.dead);
        assert(boss&&boss.name===ref.boss,"boss order "+ref.boss);
        game.drawWorld();
        if(ref.attack?.length){const before=game.state().projectiles.length;game.bossAttack(boss);assert(game.state().projectiles.length>before,"boss attack "+ref.boss);}
        boss.windBagHp=0;game.damageEnemy(boss,1e8);
      }
    }else{
      assert.strictEqual(game.state().mode,"room",type+" opens its choices");
      assert(screen.innerHTML.includes(browser.window.XIYOU_ROOMS.describe(chapters[i],plan.rooms[plan.main[room]]).name),"room title "+i+":"+room+":"+type+" "+screen.innerHTML.slice(0,80));
      const choices=screen.dataElements["room-option"];
      assert(choices.length>=2,type+" has choices");
      choices[type==="reward"?1:choices.length-1].click();
    }
    if(game.state().mode==="upgrade"){
      assert.strictEqual(screen.dataElements.upgrade.length,3);
      screen.dataElements.upgrade[0].click();
    }
    if(game.state().mode==="encounter")screen.dataElements["room-option"].at(-1).click();
  }
  if(i===0)assert(game.state().meta.heroUnlocks.includes("wukong"));
  if(i===3)assert(game.state().meta.heroUnlocks.includes("bailongma"));
  if(i===5)assert(game.state().meta.heroUnlocks.includes("bajie"));
  if(i===7)assert(game.state().meta.heroUnlocks.includes("shaseng"));
  if(i===7){game.home();vm.runInContext(source,browser,{filename:"reload.js"});game=browser.__test;game.resumeRun();assert.strictEqual(game.state().mode,"story","v18 save resumes chapter");}
}
assert.strictEqual(game.state().mode,"epilogue");
assert(screen.innerHTML.includes("护经东归"));
screen.querySelector("#epilogue-next").click();
screen.querySelector("#epilogue-next").click();
assert.strictEqual(game.state().mode,"ended");
assert(screen.innerHTML.includes("真经已得"));
assert.strictEqual(game.state().save,null);
game.select(1);game.startRun();
const legacy=JSON.parse(storage.get("xiyou-run-v18"));
legacy.version=14;legacy.stageIndex=24;legacy.mode="playing";
legacy.player.clearedTrials=Array.from({length:24},(_,i)=>i);
storage.delete("xiyou-run-v18");storage.set("xiyou-run-v14",JSON.stringify(legacy));
vm.runInContext(source,browser,{filename:"legacy-reload.js"});game=browser.__test;
game.resumeRun();
assert.strictEqual(game.state().stageIndex,10,"old trial 25 maps to Lotus Cave chapter");
assert.strictEqual(game.state().mode,"story","old save restarts at chapter entry");
assert(!game.state().player.clearedTrials.includes(10),"partial old chapter cannot be counted as cleared");
const previous=JSON.parse(storage.get("xiyou-run-v18"));
previous.version=17;previous.mode="playing";previous.roomIndex=3;previous.roomStarted=true;
storage.delete("xiyou-run-v18");storage.delete("xiyou-run-v14");storage.set("xiyou-run-v17",JSON.stringify(previous));
vm.runInContext(source,browser,{filename:"v17-reload.js"});game=browser.__test;game.resumeRun();
assert.strictEqual(game.state().mode,"story","old fixed-room save restarts at chapter entry");
assert.strictEqual(game.state().roomIndex,0,"old room index is not applied to the new map");
console.log("Smoke test passed: 37 playable chapters, 81 source ordeals, room routes, named bosses, save resume and ending.");
module.exports={browser,screen,elements,storage,windowHandlers,source,get game(){return game;},reload:()=>{vm.runInContext(source,browser,{filename:"room-reload.js"});game=browser.__test;game.resumeRun();return game;}};
