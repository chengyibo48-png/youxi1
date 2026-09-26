(() => {
  "use strict";

  const canvas = document.getElementById("game");
  let ctx = canvas.getContext("2d");
  const screen = document.getElementById("screen");
  const touchControls = document.getElementById("touch-controls");
  const W = 720, H = 720;
  const worldSize = 1280;
  const arena = { left: 28, right: 1252, top: 28, bottom: 1252 };
  const view = { left: 12, right: 708, top: 92, bottom: 666 };
  const TWO_PI = Math.PI * 2;
  const BAL = window.XIYOU_BALANCE;
  const SYS = window.XIYOU_SYSTEMS;
  ctx.imageSmoothingEnabled = false;

  const heroes = [
    { id: "wukong", name: "孙悟空", role: "近战 · 爆发", color: "#e8ad62", hp: 108, speed: 205,
      weapons: [
        { name: "如意金箍棒", desc: "扇形横扫，近身击退群妖", mode: "staff", cooldown: .54, damage: 21 },
        { name: "定海神针", desc: "贯穿直线，长距离重击", mode: "pierce", cooldown: .83, damage: 30 },
        { name: "火云金箍", desc: "隐武 · 棍势携真火，破阵燃敌", mode: "firestaff", cooldown: .72, damage: 29, hidden:true, unlock:"wukong-hidden" }
      ],
      skills: [
        { name: "身外身", desc: "召唤分身，协同攻击 8 秒", cooldown: 17 },
        { name: "筋斗云", desc: "无敌冲刺并震退周围妖怪", cooldown: 12 },
        { name: "定身术", desc: "局内悟得 · 定住近处小妖，迟缓妖王", cooldown: 15, earned:true }
      ] },
    { id: "tangseng", name: "唐三藏", role: "远程 · 度化", color: "#f0d9a6", hp: 94, speed: 183,
      weapons: [
        { name: "九环锡杖", desc: "佛光震波，攻击身边群妖", mode: "pulse", cooldown: .9, damage: 18 },
        { name: "诵经法卷", desc: "经文追踪，连发两道法印", mode: "homing", cooldown: .74, damage: 16 },
        { name: "金铙梵音", desc: "隐武 · 佛音回荡，远程震波", mode: "bell", cooldown: 1.05, damage: 29, hidden:true, unlock:"tangseng-hidden" }
      ],
      skills: [
        { name: "佛光普照", desc: "回复生命并震慑近身妖怪", cooldown: 16 },
        { name: "度化真言", desc: "让一名小妖暂时助战；无小妖时震伤妖王", cooldown: 13 },
        { name: "金光破障", desc: "局内悟得 · 穿透佛光，净化自身毒火", cooldown: 12, earned:true }
      ] },
    { id: "bajie", name: "猪八戒", role: "坚韧 · 清场", color: "#d98787", hp: 145, speed: 169,
      weapons: [
        { name: "九齿钉耙", desc: "宽幅横扫，覆盖前方大范围", mode: "rake", cooldown: .73, damage: 27 },
        { name: "旋风耙", desc: "连续回旋，扫清身边敌人", mode: "whirl", cooldown: .55, damage: 15 },
        { name: "九灵裂地耙", desc: "隐武 · 狮吼裂地，重击群妖", mode: "earthrake", cooldown: 1.1, damage: 42, hidden:true, unlock:"bajie-hidden" }
      ],
      skills: [
        { name: "天蓬护体", desc: "获得护盾并反弹接触伤害", cooldown: 18 },
        { name: "倒打一耙", desc: "猛烈重击，击飞附近所有妖怪", cooldown: 14 },
        { name: "九齿震地", desc: "局内悟得 · 震地减速，命中可回血", cooldown: 13, earned:true }
      ] },
    { id: "shaseng", name: "沙悟净", role: "控制 · 穿透", color: "#83baca", hp: 120, speed: 190,
      weapons: [
        { name: "降妖宝杖", desc: "疾射宝杖，贯穿一列敌人", mode: "spear", cooldown: .69, damage: 23 },
        { name: "流沙飞刃", desc: "三道飞刃，扇形压制远处", mode: "fan", cooldown: .8, damage: 15 },
        { name: "沧浪宝杖", desc: "隐武 · 水刃穿透，并迟滞妖怪", mode: "windstaff", cooldown: .85, damage: 28, hidden:true, unlock:"shaseng-hidden" }
      ],
      skills: [
        { name: "流沙结界", desc: "生成结界，持续减速并灼伤敌人", cooldown: 17 },
        { name: "沧浪一击", desc: "水波扩散，对全场近敌造成伤害", cooldown: 14 },
        { name: "水月木刃", desc: "局内悟得 · 三道月刃穿透群妖", cooldown: 11, earned:true }
      ] },
    { id: "bailongma", name: "白龙马", role: "疾驰 · 潮汐", color: "#d3edf0", hp: 105, speed: 221,
      weapons: [
        { name: "龙角水枪", desc: "水枪直刺，穿透并减速", mode: "dragonlance", cooldown: .7, damage: 21 },
        { name: "踏浪蹄", desc: "疾驰踢踏，回旋击退", mode: "hooves", cooldown: .6, damage: 17 },
        { name: "沧海龙脊", desc: "隐武 · 潮汐连射，破甲逐浪", mode: "dragonwave", cooldown: .85, damage: 26, hidden:true, unlock:"bailongma-hidden" }
      ],
      skills: [
        { name: "龙吟潮生", desc: "潮汐冲击并留下减速水域", cooldown: 16 },
        { name: "化龙逐日", desc: "高速突进并化龙 5 秒：伤害 +25%、移速 +22%", cooldown: 14 },
        { name: "龙息吐纳", desc: "局内悟得 · 三道水息迟缓前方妖怪", cooldown: 10, earned:true }
      ] }
  ];
  const heroTravelLines={
    wukong:["师父莫怕，俺老孙先去探路。","妖风有来处，金箍棒也有去处。","火眼金睛看得明白，这里有古怪。","莫急，待俺老孙破了这阵。"],
    tangseng:["山高路远，且守一念慈悲。","纵有妖氛，正心不可失。","此地百姓有难，我们不可袖手。","前路未明，愿众生平安。"],
    bajie:["先寻些吃食，再打这帮妖怪！","这一路可真不消停，老猪来开道。","好家伙，九齿钉耙又有用武之地。","打完这阵，莫忘了找个歇脚处。"],
    shaseng:["师父放心，行李与后路有我。","水声不对，前头恐有埋伏。","妖怪若近身，我的宝杖不答应。","一步一步走，总能走到西天。"],
    bailongma:["我载师父过山河，前路交给我。","风向变了，水脉就在近处。","蹄声虽轻，也能踏破妖阵。","西行千里，不能停在这里。"]
  };

  // 首领依照原著中主要遭遇的大致先后排列。
  const biomeTints = {wild:"#34443b",forest:"#2b4b41",desert:"#5a4b39",grave:"#3c4552",night:"#303e50",cave:"#414644",ember:"#553b37",city:"#4a4b43",river:"#2c4d59",temple:"#4e5040",web:"#464051",moon:"#3d4e5c"};
  const stages = window.XIYOU_CHAPTERS.chapters.map((s,i)=>({...s,biome:s.biome,mobs:s.mobs,mobNames:s.mobNames||{},element:s.element,ordeal:s.ordeal,chapter:`第 ${i+1} 章`,tint:biomeTints[s.biome],bossColor:s.accent,
    hp:Math.round(BAL.boss.baseHp+BAL.boss.hpPerStage*s.powerTier+BAL.boss.hpQuadratic*s.powerTier*s.powerTier)}));
  const mobTypes = window.XIYOU_LORE.mobs;
  const relicTypes = window.XIYOU_ITEM_POOL;
  const rooms = window.XIYOU_ROOMS;
  const upgrades = window.XIYOU_UPGRADES;
  const weaponCards=window.XIYOU_WEAPON_CARDS,activeCards=window.XIYOU_ACTIVE_CARDS,skillCards=window.XIYOU_SKILL_CARDS;
  const allUpgrades=[...upgrades,...weaponCards,...activeCards,...skillCards];
  const synergies = window.XIYOU_SYNERGIES;
  const keys = new Set();
  const touch = { x: 0, y: 0, pointer: null };
  let mode = "home";
  let selectedHero = 1, selectedWeapon = 0, selectedSkill = 0, selectedChallenge=false;
  let player = null, enemies = [], projectiles = [], orbs = [], effects = [], particles = [], relicDrops = [];
  let stageIndex = 0, stageTime = 0, runTime = 0, spawnTimer = 0, relicTimer = 0, bossSpawned = false;
  let coins=0, pendingEncounter=false, encounterIndex=-1, stagePhase=0, epilogueStep=0;
  let roomPlan=rooms.generate(0,BAL.rooms),roomIndex=0,roomChoice=-1,roomRewardId=null,mapReturnMode="paused",roomStarted=false,roomBattle=false,bossCursor=0;
  let roomOffer=null;
  let kills = 0, level = 1, xp = 0, xpGoal = BAL.experience.firstGoal, upgradeQueue = [], advancing = false;
  let currentUpgradeChoices = [];
  let banner = "", bannerTime = 0, shake = 0, lastFrame = 0, animationTime = 0, hitStop = 0, saveTimer = 0;
  let camera = {x:worldSize/2,y:worldSize/2}, dialogue = "", dialogueTime = 0, dialogueSpeaker = "";
  let libraryHero = 0, settingsReturn = "home", storyFrom = -1, newUnlock = "";
  let terrainCanvas = null, terrainStage = -1;
  const audio = new window.XIYOU_AUDIO();
  let soundMuted=false;
  const settings = {bgm:.38,sfx:.6,voice:false,zoom:1.35,particles:"high",shake:true,display:window.innerWidth<650?"full":"fit"};
  try { Object.assign(settings,JSON.parse(localStorage.getItem("xiyou-settings-v2")||"{}")); } catch (_) {}
  settings.bgm=Math.max(0,Math.min(1,Number(settings.bgm)||0));
  settings.sfx=Math.max(0,Math.min(1,Number(settings.sfx)||0));
  if(![1.1,1.35,1.6].includes(settings.zoom))settings.zoom=1.35;
  if(!["high","low"].includes(settings.particles))settings.particles="high";
  settings.shake=!!settings.shake;
  settings.voice=!!settings.voice;
  if(!["fit","wide","full"].includes(settings.display))settings.display="fit";
  document.documentElement.dataset.display=settings.display;
  audio.setVolumes(settings.bgm,settings.sfx);
  audio.setVoiceEnabled(settings.voice);
  let meta = {unlocks:[],seenBosses:[],heroUnlocks:["tangseng"],merit:0,collections:[]};
  try { meta={...meta,...JSON.parse(localStorage.getItem("xiyou-meta-v2")||"{}")}; } catch (_) {}
  if(!Array.isArray(meta.unlocks))meta.unlocks=[];
  if(!Array.isArray(meta.seenBosses))meta.seenBosses=[];
  if(!Array.isArray(meta.collections))meta.collections=[];
  meta.collections=meta.collections.filter(id=>["wukong_clone","bajie_blood","shaseng_sand","tangseng_mercy","bailongma_tide"].includes(id));
  if(!Array.isArray(meta.heroUnlocks))meta.heroUnlocks=["tangseng"];
  meta.heroUnlocks=[...new Set(["tangseng",...meta.heroUnlocks.filter(id=>heroes.some(h=>h.id===id))])];
  meta.merit=Math.max(0,Math.floor(Number(meta.merit)||0));
  meta.unlocks=[...new Set(meta.unlocks.filter(id=>heroes.some(h=>h.weapons.some(w=>w.unlock===id))))];
  meta.seenBosses=[...new Set(meta.seenBosses.filter(name=>stages.some(s=>s.bossRefs.some(b=>b.boss===name))))];
  let best = { stage: 0, kills: 0, clears: 0 };
  try { best = { ...best, ...JSON.parse(localStorage.getItem("xiyou-best-v17") || "{}") }; } catch (_) {}
  for(const key of ["stage","kills","clears"]){
    if(!Number.isSafeInteger(best[key])||best[key]<0)best[key]=0;
  }

  const rand = (a, b) => a + Math.random() * (b - a);
  const clamp = (v, lo, hi) => Math.max(lo, Math.min(hi, v));
  const distance = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);
  const choose = list => list[Math.floor(Math.random() * list.length)];
  const heroUnlockTrial={tangseng:0,wukong:7,bailongma:11,bajie:13,shaseng:19};
  function unlockAfterTrial(){
    if(player.clearedTrials?.includes(stageIndex))return;
    player.clearedTrials=[...(player.clearedTrials||[]),stageIndex];
    const cleared=stages[stageIndex].lastTrial;
    for(const hero of heroes)if(heroUnlockTrial[hero.id]>=stages[stageIndex].firstTrial&&heroUnlockTrial[hero.id]<=cleared&&!meta.heroUnlocks.includes(hero.id)){
      meta.heroUnlocks.push(hero.id);newUnlock=`${hero.name}成为可玩角色`;audio.effect("win");
    }
    if(player.ordealAccepted){
      const gain=stages[stageIndex].ordeal.coins;
      coins+=gain;player.ordealAccepted=false;
      banner=`历劫已成 · 获得 ${gain} 文`;bannerTime=2.5;
    }
    meta.merit+=Math.round((stages[stageIndex].kind==="boss"?5:1)*(player.challenge?1.5:1));
    saveMeta();
  }
  const tier=()=>stages[stageIndex].powerTier;
  const nurtured=()=>SYS.nurtureForTrial(stages[stageIndex],SYS.hero[heroes[selectedHero].id]);
  const stageFightTime=()=>stages[stageIndex].kind==="boss"?30+Math.min(10,tier()*.5):stages[stageIndex].kind==="combat"?17+Math.min(7,tier()*.35):player?.eventBattle?15:0;
  const roomAt=index=>roomPlan.rooms[roomPlan.main[Math.min(index,roomPlan.main.length-1)]];
  function rollRelic(room="combat"){
    const options=relicTypes.filter(item=>stages[stageIndex].lastTrial>=(item.minTrial||1)&&
      (item.rarity==="ordinary"||item.rarity==="rare"&&stageIndex>=BAL.relic.rareFromStage||item.rarity==="legendary"&&stageIndex>=BAL.relic.legendaryFromStage));
    const weighted=options.map(item=>{
      const tier=item.rarity==="legendary"?BAL.relic.legendaryWeight:item.rarity==="rare"?BAL.relic.rareWeight:BAL.relic.ordinaryWeight;
      let weight=item.weight*tier/70;
      if(room==="reward")weight*=item.rarity==="ordinary"?.7:1.8;
      if(player){
        if(item.tags.includes("speed")&&player.attackSpeed>1.3)weight*=1.6;
        if(item.tags.includes("crit")&&player.crit>.2)weight*=1.6;
        if(item.tags.includes("area")&&player.area>1.25)weight*=1.45;
        if(item.tags.includes("guard")&&player.hp/player.maxHp<.45)weight*=1.5;
        if(player.relicBag.includes(item.id))weight*=.55;
      }
      return {item,weight};
    });
    let total=weighted.reduce((sum,p)=>sum+p.weight,0),pick=Math.random()*total;
    for(const entry of weighted){pick-=entry.weight;if(pick<=0)return entry.item;}
    return weighted.at(-1)?.item||relicTypes[0];
  }
  const saveBest = () => { try { localStorage.setItem("xiyou-best-v17", JSON.stringify(best)); } catch (_) {} };
  const norm = (x, y) => { const n = Math.hypot(x, y) || 1; return { x: x / n, y: y / n }; };

  function sound(freq = 440, duration = .08, type = "square", volume = .035) {
    if (soundMuted || !settings.sfx) return;
    audio.unlock(); audio.tone(freq,duration,type,volume*settings.sfx);
  }

  function showScreen(html) { screen.innerHTML = html; screen.classList.add("visible"); }
  function hideScreen() { screen.classList.remove("visible"); screen.innerHTML = ""; }
  function button(selector, fn) { const el = screen.querySelector(selector); if (el) el.addEventListener("click", fn); }
  function resetTouch(){
    touch.pointer=null;touch.x=0;touch.y=0;
    const knob=document.getElementById("joystick-knob");
    if(knob)knob.style.transform="translate(0,0)";
  }

  const SAVE_KEY = "xiyou-run-v18";
  const META_KEY = "xiyou-meta-v2";
  function saveMeta(){try{localStorage.setItem(META_KEY,JSON.stringify(meta));}catch(_){}}
  function readSave(){
    try{
      const data=JSON.parse(localStorage.getItem(SAVE_KEY)||localStorage.getItem("xiyou-run-v17")||localStorage.getItem("xiyou-run-v14")||"null");
      if(data?.version===14&&data.player){
        const oldTrial=data.stageIndex+1;
        data.stageIndex=window.XIYOU_CHAPTERS.chapterForTrial(oldTrial);
        
        data.player.clearedTrials=window.XIYOU_CHAPTERS.chapters.map((c,i)=>c.lastTrial<oldTrial?i:-1).filter(n=>n>=0);
      }
      if((data?.version===14||data?.version===17)&&data.player){
        data.version=18;data.mode="story";data.roomIndex=0;data.roomStarted=false;data.roomBattle=false;data.bossCursor=0;data.bossSpawned=false;data.enemies=[];data.orbs=[];data.relicDrops=[];data.upgradeQueue=[];
      }
      if(data?.version!==18||!data.player||!Number.isInteger(data.stageIndex)||
        data.stageIndex<0||data.stageIndex>=stages.length||
        !Number.isInteger(data.selectedHero)||data.selectedHero<0||data.selectedHero>=heroes.length||
        !Number.isInteger(data.selectedWeapon)||data.selectedWeapon<0||data.selectedWeapon>=heroes[data.selectedHero].weapons.length||
        !Number.isInteger(data.selectedSkill)||data.selectedSkill<0||data.selectedSkill>=heroes[data.selectedHero].skills.length||
        !["playing","paused","story","upgrade","encounter","eventtrial","map","epilogue","room"].includes(data.mode)||
        !Number.isFinite(data.player.x)||!Number.isFinite(data.player.y)||
        !Number.isFinite(data.player.hp)||!Number.isFinite(data.player.maxHp)||data.player.maxHp<=0||
        !Array.isArray(data.enemies)||!Array.isArray(data.orbs)||!Array.isArray(data.relicDrops)||
        !Array.isArray(data.upgradeQueue))return null;
      return data;
    }catch(_){}
    return null;
  }
  function saveRun(){
    if(!player || mode==="ended")return;
    try{
      localStorage.setItem(SAVE_KEY,JSON.stringify({
        version:18,savedAt:Date.now(),mode,selectedHero,selectedWeapon,selectedSkill,
        player,stageIndex,stageTime,runTime,spawnTimer,relicTimer,bossSpawned,kills,level,xp,xpGoal,coins,pendingEncounter,encounterIndex,stagePhase,epilogueStep,roomIndex,roomChoice,roomRewardId,roomOffer,mapReturnMode,roomStarted,roomBattle,bossCursor,
        enemies:enemies.filter(e=>!e.dead),orbs,relicDrops,upgradeQueue,advancing,
        currentUpgradeIds:currentUpgradeChoices.map(u=>u.id),storyFrom,newUnlock
      }));
    }catch(_){}
  }
  function clearRun(){try{localStorage.removeItem(SAVE_KEY);localStorage.removeItem("xiyou-run-v17");localStorage.removeItem("xiyou-run-v14");}catch(_){}}
  function home(){
    if(player && ["playing","paused","upgrade","story","encounter","map","epilogue","room"].includes(mode))saveRun();
    mode="home";resetTouch();touchControls.classList.remove("active");audio.setTheme("menu");
    player=null;enemies=[];projectiles=[];orbs=[];effects=[];particles=[];relicDrops=[];
    camera={x:worldSize/2,y:worldSize/2};stageIndex=0;
    const saved=readSave();
    showScreen(`<div class="panel home-panel center">
      <div class="eyebrow">A PIXEL JOURNEY TO THE WEST</div>
      <h1 class="title">重生之我也要取经</h1>
      <p class="subtitle">九九八十一难 · 师徒五人 · 一段取经路</p>
      <div class="home-seal">西<br>行</div>
      <p class="home-lead">从双叉岭到天竺国。每一难，都是另一段传说。</p>
      <div class="home-actions">
        ${saved?`<button id="continue" class="primary" type="button">继续游戏 <span>第 ${saved.stageIndex+1} 章 · ${stages[saved.stageIndex].place}</span></button>`:""}
        <button id="new-game" class="${saved?"secondary":"primary"}" type="button">开始新游戏 <span>选择取经人和兵器</span></button>
        ${saved?"":`<button id="continue" class="secondary" type="button" disabled>继续游戏 <span>暂无存档</span></button>`}
        <button id="library" class="secondary" type="button">人物与武器库 <span>${meta.unlocks.length}/5 件隐武已解锁</span></button>
        <button id="merit-shop" class="secondary" type="button">功德阁 <span>${meta.merit} 功德 · 解锁构筑内容</span></button>
        <button id="settings" class="secondary" type="button">设置 <span>按键、音量与画面</span></button>
      </div>
      <p class="small-note center">最高抵达第 ${best.stage} 章 · ${best.clears} 次圆满<br>角色战斗是取经旅程的重演；事件与地名按原著回目排序。</p>
    </div>`);
    button("#continue",resumeRun);
    button("#new-game",()=>{audio.effect("select");menu();});
    button("#library",()=>{audio.effect("select");library();});
    button("#merit-shop",meritShop);
    button("#settings",()=>{audio.effect("select");settingsPage("home");});
  }
  function menu(){
    mode="loadout";resetTouch();touchControls.classList.remove("active");
    const hero=heroes[selectedHero];
    if(hero.skills[selectedSkill]?.earned)selectedSkill=0;
    if(hero.weapons[selectedWeapon]?.hidden && !meta.unlocks.includes(hero.weapons[selectedWeapon].unlock))selectedWeapon=0;
    showScreen(`<div class="panel">
      <div class="eyebrow">CHOOSE YOUR PILGRIM</div>
      <h2 class="modal-title">择一人，走西行路</h2>
      <p class="modal-desc">可玩角色随历难逐步解锁；剧情中的入队顺序依原著。${SYS.traits[hero.id]}</p>
      <p class="section-label">取经人</p>
      <div class="characters">${heroes.map((h,i)=>`<button class="character-card ${i===selectedHero?"selected":""} ${meta.heroUnlocks.includes(h.id)?"":"locked"}" data-hero="${i}" type="button" ${meta.heroUnlocks.includes(h.id)?"":"disabled"}><canvas class="portrait" data-portrait="${i}" width="32" height="32"></canvas><span class="character-name">${h.name}</span><span class="character-role">${meta.heroUnlocks.includes(h.id)?h.role:`第 ${heroUnlockTrial[h.id]} 难解锁`}</span></button>`).join("")}</div>
      <div class="divider"></div><p class="section-label">专属武器</p>
      <div class="options weapon-options">${hero.weapons.map((w,i)=>{
        const locked=w.hidden&&!meta.unlocks.includes(w.unlock);
        const place=stages.find(s=>s.unlock===w.unlock)?.place||"后续关卡";
        return `<button class="option ${i===selectedWeapon?"selected":""} ${locked?"locked":""}" data-weapon="${i}" type="button" ${locked?"disabled":""}><strong>${locked?"🔒 ":""}${w.name}</strong><span>${locked?`击败 ${place} 首领解锁`:w.desc}</span></button>`;
      }).join("")}</div>
      <div class="divider"></div><p class="section-label">主动技能</p>
      <div class="options">${hero.skills.map((s,i)=>`<button class="option ${i===selectedSkill?"selected":""} ${s.earned?"locked":""}" data-skill="${i}" type="button" ${s.earned?"disabled":""}><strong>${s.earned?"🔒 ":""}${s.name}</strong><span>${s.desc}</span></button>`).join("")}</div>
      <label class="setting-row check-row challenge-row">心魔难度：敌人生命、伤害 +15%，功德收益 +50% <input id="challenge" type="checkbox" ${selectedChallenge?"checked":""}></label>
      ${readSave()?`<p class="small-note center">开始新游戏会覆盖尚未完成的战局存档。</p>`:""}
      <div class="start-row"><button class="secondary" id="back-home" type="button">← 返回主页</button><button id="start" class="primary" type="button">启程西行 →</button></div>
    </div>`);
    screen.querySelectorAll("[data-hero]").forEach(el=>el.addEventListener("click",()=>{const next=Number(el.dataset.hero);if(!meta.heroUnlocks.includes(heroes[next].id))return;selectedHero=next;selectedWeapon=0;selectedSkill=0;audio.effect("select");menu();}));
    screen.querySelectorAll("[data-weapon]").forEach(el=>el.addEventListener("click",()=>{selectedWeapon=Number(el.dataset.weapon);audio.effect("select");menu();}));
    screen.querySelectorAll("[data-skill]").forEach(el=>el.addEventListener("click",()=>{selectedSkill=Number(el.dataset.skill);audio.effect("select");menu();}));
    screen.querySelector("#challenge")?.addEventListener("change",e=>{selectedChallenge=e.target.checked;});
    button("#back-home",home);button("#start",startRun);drawPortraits();
  }
  function library(){
    mode="library";resetTouch();touchControls.classList.remove("active");
    const hero=heroes[libraryHero];
    showScreen(`<div class="panel">
      <div class="eyebrow">PILGRIMS & ARSENAL</div><h2 class="modal-title">人物与武器库</h2>
      <p class="modal-desc">隐武通过指定首领关卡后永久解锁，可在下次启程时装备。</p>
      <div class="characters">${heroes.map((h,i)=>`<button class="character-card ${i===libraryHero?"selected":""}" data-library-hero="${i}" type="button"><canvas class="portrait" data-portrait="${i}" width="32" height="32"></canvas><span class="character-name">${h.name}</span><span class="character-role">${h.role}</span></button>`).join("")}</div>
      <div class="library-details"><h3>${hero.name} <small>${hero.role}</small></h3>
      <p>生命 ${hero.hp} · 速度 ${hero.speed} · ${SYS.names[SYS.hero[hero.id]]}行 · 2 种初始主动技能 + 1 种局内神通</p><p>${SYS.traits[hero.id]}</p>
      ${hero.weapons.map((w,i)=>{
        const locked=w.hidden&&!meta.unlocks.includes(w.unlock);
        const target=stages.find(s=>s.bossRefs.some(b=>b.unlock===w.unlock));
        const boss=target?.bossRefs.find(b=>b.unlock===w.unlock);
        return `<div class="library-weapon ${locked?"locked":""}"><span class="library-index">0${i+1}</span><div><strong>${w.name}</strong><small>${locked?`未解锁 · 第 ${stages.indexOf(target)+1} 章 ${boss?.boss||"妖王"}`:w.desc}</small></div><b>${locked?"未得":w.hidden?"已解锁":"初始"}</b></div>`;
      }).join("")}</div>
      <div class="divider"></div><p class="section-label">妖怪图鉴 <small>${meta.seenBosses.length}/${stages.flatMap(s=>s.bossRefs).length} 位首领已相遇</small></p>
      <div class="lore-list">${stages.flatMap(s=>s.bossRefs).map(s=>`<span class="${meta.seenBosses.includes(s.boss)?"seen":""}">${meta.seenBosses.includes(s.boss)?s.boss:"???"}<small>第 ${s.ch} 回 · ${s.trialName}</small></span>`).join("")}</div>
      <div class="button-row"><button class="secondary" id="back-home" type="button">返回主页</button></div>
    </div>`);
    screen.querySelectorAll("[data-library-hero]").forEach(el=>el.addEventListener("click",()=>{libraryHero=Number(el.dataset.libraryHero);audio.effect("select");library();}));
    button("#back-home",home);drawPortraits();
  }
  function settingsPage(from="home"){
    settingsReturn=from;mode="settings";resetTouch();touchControls.classList.remove("active");
    showScreen(`<div class="panel"><div class="eyebrow">CONFIGURATION</div><h2 class="modal-title">设置</h2>
      <div class="settings-grid">
        <section><h3>声音</h3><label class="setting-row">背景音乐 <span id="bgm-value">${Math.round(settings.bgm*100)}%</span><input id="bgm" type="range" min="0" max="100" value="${Math.round(settings.bgm*100)}"></label>
        <label class="setting-row">战斗音效 <span id="sfx-value">${Math.round(settings.sfx*100)}%</span><input id="sfx" type="range" min="0" max="100" value="${Math.round(settings.sfx*100)}"></label><label class="setting-row check-row">系统中文语音 <input id="voice" type="checkbox" ${settings.voice?"checked":""}></label></section>
        <section><h3>画面</h3><label class="setting-row">镜头倍率 <select id="zoom"><option value="1.1" ${settings.zoom===1.1?"selected":""}>1.1× 广角</option><option value="1.35" ${settings.zoom===1.35?"selected":""}>1.35× 标准</option><option value="1.6" ${settings.zoom===1.6?"selected":""}>1.6× 近景</option></select></label>
        <label class="setting-row">粒子效果 <select id="particles"><option value="high" ${settings.particles==="high"?"selected":""}>丰富</option><option value="low" ${settings.particles==="low"?"selected":""}>精简</option></select></label>
        <label class="setting-row">画面比例 <select id="display"><option value="fit" ${settings.display==="fit"?"selected":""}>方形适配</option><option value="wide" ${settings.display==="wide"?"selected":""}>横屏宽画布</option><option value="full" ${settings.display==="full"?"selected":""}>铺满屏幕界面</option></select></label>
        <label class="setting-row check-row">画面震动 <input id="shake" type="checkbox" ${settings.shake?"checked":""}></label></section>
      </div>
      <div class="divider"></div><h3 class="section-label">按键操作</h3>
      <div class="controls-guide"><span>移动 <b>W A S D / 方向键</b></span><span>主动技能 <b>空格</b></span><span>法宝袋首件 <b>Q 手动释放</b></span><span>闪避 <b>Shift</b></span><span>西行地图 <b>Tab</b></span><span>暂停 <b>P / Esc</b></span><span>声音静音 <b>M</b></span><span>战斗 <b>自动瞄准最近敌人</b></span></div>
      <p class="small-note">语音默认关闭，开启后使用设备本地中文语音包。触屏使用左下摇杆、右下法宝、技能与闪避键。全屏按钮在支持的浏览器中隐藏浏览器边框；手机如仍有地址栏，可将网页添加到主屏幕。进度只保存在当前浏览器。</p>
      <div class="button-row"><button class="secondary" id="fullscreen" type="button">切换全屏</button><button class="primary" id="settings-back" type="button">完成</button></div>
    </div>`);
    function persist(){try{localStorage.setItem("xiyou-settings-v2",JSON.stringify(settings));}catch(_){}audio.setVolumes(soundMuted?0:settings.bgm,soundMuted?0:settings.sfx);}
    for(const key of ["bgm","sfx"]){
      const el=screen.querySelector("#"+key);
      el?.addEventListener("input",()=>{settings[key]=Number(el.value)/100;screen.querySelector("#"+key+"-value").textContent=el.value+"%";persist();audio.unlock();});
    }
    screen.querySelector("#zoom")?.addEventListener("change",e=>{settings.zoom=Number(e.target.value);persist();});
    screen.querySelector("#particles")?.addEventListener("change",e=>{settings.particles=e.target.value;persist();});
    screen.querySelector("#display")?.addEventListener("change",e=>{settings.display=e.target.value;document.documentElement.dataset.display=settings.display;persist();});
    screen.querySelector("#shake")?.addEventListener("change",e=>{settings.shake=e.target.checked;persist();});
    screen.querySelector("#voice")?.addEventListener("change",e=>{settings.voice=e.target.checked;audio.setVoiceEnabled(settings.voice);persist();});
    button("#fullscreen",async()=>{try{if(document.fullscreenElement)await document.exitFullscreen();else await document.getElementById("game-shell").requestFullscreen();}catch(_){settings.display="full";document.documentElement.dataset.display="full";persist();}});
    button("#settings-back",()=>{audio.effect("select");if(settingsReturn==="paused")renderPause();else home();});
  }
  function initialPlayer(hero){
    return {x:worldSize/2,y:worldSize/2,radius:18,hp:hero.hp,maxHp:hero.hp,speed:hero.speed,
      damage:1,attackSpeed:1,armor:0,crit:.05,magnet:95,skillHaste:1,bossDamage:1,
      xpGain:1,extraShots:0,pierce:0,area:1,knockback:1,projectileSpeed:1,lifeSteal:0,
      burnChance:0,freezeChance:0,chainChance:0,poisonChance:0,regen:0,thorns:0,
      relicDuration:1,dashHaste:1,execute:0,projectileSize:1,orbitBlades:0,windPower:0,
      pulsePower:0,fortune:0,startShield:hero.id==="shaseng"?1:0,dashBlast:0,shieldCharges:hero.id==="shaseng"?1:0,
      relicBag:[],relicCapacity:2,relicFragments:0,offerHistory:{},eventReward:0,beggedAt:[],purchasedAt:{},vitalityBuys:0,clearedTrials:[],heroTalent:0,coinLuck:0,resonance:0,weaponSwing:0,peachBlessed:false,
      ordealAccepted:false,combo:0,comboDecay:0,dragonTime:0,sandMarks:0,relicSealTime:0,
      weaponRank:0,skillRank:0,momentum:0,curse:0,passiveCd:0,lastHit:"无",
      skillVariant:0,
      taken:{},synergies:[],weaponCd:.2,skillCd:0,dashCd:0,dashTime:0,invuln:0,facing:{x:1,y:0},
      cloneTime:0,cloneCd:0,shieldTime:0,fieldTime:0,fieldTick:0,
      regenTick:0,orbitTick:0,windTick:5,pulseTick:8,relic:null,relicTime:0,relicTick:0,
      burnTime:0,poisonTime:0,slowTime:0,statusTick:.7};
  }
  function startRun(){
    audio.unlock();clearRun();
    const hero=heroes[selectedHero];
    if(!meta.heroUnlocks.includes(hero.id)){selectedHero=1;menu();return;}
    if(hero.weapons[selectedWeapon]?.hidden && !meta.unlocks.includes(hero.weapons[selectedWeapon].unlock))selectedWeapon=0;
    if(hero.skills[selectedSkill]?.earned)selectedSkill=0;
    player=initialPlayer(hero);
    roomOffer=null;
    player.challenge=selectedChallenge;
    enemies=[];projectiles=[];orbs=[];effects=[];particles=[];relicDrops=[];
    stageIndex=0;stageTime=0;runTime=0;spawnTimer=1;relicTimer=BAL.relic.firstSpawn;bossSpawned=false;
    roomPlan=rooms.generate(stageIndex,BAL.rooms);roomIndex=0;roomChoice=-1;roomRewardId=null;mapReturnMode="paused";roomStarted=false;roomBattle=false;bossCursor=0;
    coins=0;pendingEncounter=false;encounterIndex=-1;stagePhase=0;epilogueStep=0;
    kills=0;level=1;xp=0;xpGoal=BAL.experience.firstGoal;upgradeQueue=[];advancing=false;currentUpgradeChoices=[];
    camera={x:player.x,y:player.y};storyFrom=-1;newUnlock="";
    showStory();
  }
  function resumeRun(){
    const data=readSave();if(!data){home();return;}
    const safeNumber=(value,fallback,lo=0,hi=1e8)=>Number.isFinite(value)?clamp(value,lo,hi):fallback;
    selectedHero=data.selectedHero;
    selectedWeapon=data.selectedWeapon;
    selectedSkill=data.selectedSkill;
    const defaults=initialPlayer(heroes[selectedHero]);
    player={...defaults,...data.player};
    for(const [key,value] of Object.entries(defaults))
      if(typeof value==="number"&&!Number.isFinite(player[key]))player[key]=value;
    if(!player.facing||!Number.isFinite(player.facing.x)||!Number.isFinite(player.facing.y))player.facing={x:1,y:0};
    if(!player.dashDir||!Number.isFinite(player.dashDir.x)||!Number.isFinite(player.dashDir.y)){
      player.dashTime=0;player.dashDir={x:0,y:0};
    }
    player.taken={};
    if(data.player.taken&&typeof data.player.taken==="object")
      for(const u of allUpgrades){
        const count=data.player.taken[u.id];
        if(Number.isInteger(count)&&count>0)player.taken[u.id]=Math.min(count,u.max);
      }
    if(selectedSkill===2&&!skillCards.some(u=>u.hero===heroes[selectedHero].id&&player.taken[u.id]))selectedSkill=0;
    player.synergies=Array.isArray(data.player.synergies)?data.player.synergies.filter(id=>synergies.some(s=>s.id===id)):[];
    if(!relicTypes.some(r=>r.id===player.relic)){player.relic=null;player.relicTime=0;}
    player.relicCapacity=clamp(Math.floor(player.relicCapacity),2,4);
    player.relicBag=Array.isArray(data.player.relicBag)?data.player.relicBag.filter(id=>relicTypes.some(r=>r.id===id)).slice(0,player.relicCapacity):[];
    player.relicFragments=Math.max(0,Math.floor(player.relicFragments));
    player.offerHistory={};
    for(const key of ["shop","shrine","events"]){
      const history=data.player.offerHistory?.[key];
      player.offerHistory[key]=Array.isArray(history)?history.filter(id=>typeof id==="string").slice(-100):[];
    }
    player.beggedAt=Array.isArray(data.player.beggedAt)?data.player.beggedAt.filter(n=>Number.isInteger(n)&&n>=0&&n<stages.length):[];
    player.purchasedAt=data.player.purchasedAt&&typeof data.player.purchasedAt==="object"&&!Array.isArray(data.player.purchasedAt)?data.player.purchasedAt:{};
    player.vitalityBuys=Number.isInteger(data.player.vitalityBuys)?clamp(data.player.vitalityBuys,0,4):0;
    player.clearedTrials=Array.isArray(data.player.clearedTrials)?data.player.clearedTrials.filter(n=>Number.isInteger(n)&&n>=0&&n<stages.length):[];
    player.lastHit=typeof data.player.lastHit==="string"?data.player.lastHit.replace(/[<>&"']/g,"").slice(0,70):"无";
    player.ordealAccepted=!!data.player.ordealAccepted;
    if(!player.gourdMark||!Number.isFinite(player.gourdMark.x)||!Number.isFinite(player.gourdMark.y)||!Number.isFinite(player.gourdMark.time))player.gourdMark=null;
    stageIndex=data.stageIndex;stageTime=safeNumber(data.stageTime,0);runTime=safeNumber(data.runTime,0);
    roomPlan=rooms.generate(stageIndex,BAL.rooms);
    stagePhase=Number.isInteger(data.stagePhase)?clamp(data.stagePhase,0,4):BAL.stage.ambushAt.filter(t=>stageTime>=t*stageFightTime()).length;
    roomIndex=Number.isInteger(data.roomIndex)?clamp(data.roomIndex,0,roomPlan.main.length-1):0;
    roomStarted=!!data.roomStarted;roomBattle=!!data.roomBattle;bossCursor=Number.isInteger(data.bossCursor)?clamp(data.bossCursor,0,stages[stageIndex].bossRefs.length):0;
    roomChoice=Number.isInteger(data.roomChoice)?clamp(data.roomChoice,-1,roomPlan.main.length-1):-1;
    roomRewardId=relicTypes.some(r=>r.id===data.roomRewardId)?data.roomRewardId:null;
    roomOffer=data.roomOffer&&typeof data.roomOffer.key==="string"&&Array.isArray(data.roomOffer.ids)?{
      key:data.roomOffer.key,ids:data.roomOffer.ids.filter(id=>typeof id==="string"),
      eventId:typeof data.roomOffer.eventId==="string"?data.roomOffer.eventId:null,
      bought:Array.isArray(data.roomOffer.bought)?data.roomOffer.bought.filter(id=>typeof id==="string"):[],
      message:""
    }:null;
    mapReturnMode=["story","epilogue","encounter","eventtrial","room","playing","paused"].includes(data.mapReturnMode)?data.mapReturnMode:"paused";
    epilogueStep=Number.isInteger(data.epilogueStep)?clamp(data.epilogueStep,0,5):0;
    spawnTimer=safeNumber(data.spawnTimer,1,-10,60);relicTimer=safeNumber(data.relicTimer,8,-10,60);bossSpawned=!!data.bossSpawned;
    kills=Math.floor(safeNumber(data.kills,0));level=Math.max(1,Math.floor(safeNumber(data.level,1)));
    xp=safeNumber(data.xp,0);xpGoal=Math.max(1,Math.floor(safeNumber(data.xpGoal,BAL.experience.firstGoal)));
    coins=Math.floor(safeNumber(data.coins,0,0,999999));pendingEncounter=!!data.pendingEncounter;
    encounterIndex=Number.isInteger(data.encounterIndex)?clamp(data.encounterIndex,-1,stages.length-1):-1;
    enemies=data.enemies.filter(e=>e&&Number.isFinite(e.x)&&Number.isFinite(e.y)&&Number.isFinite(e.hp)&&Number.isFinite(e.radius)&&Number.isFinite(e.speed)&&Number.isFinite(e.damage));
    orbs=data.orbs.filter(o=>o&&Number.isFinite(o.x)&&Number.isFinite(o.y)&&Number.isFinite(o.value)&&Number.isFinite(o.life));
    relicDrops=data.relicDrops.filter(r=>r&&relicTypes.some(type=>type.id===r.id)&&Number.isFinite(r.x)&&Number.isFinite(r.y)&&Number.isFinite(r.life));
    projectiles=[];effects=[];particles=[];upgradeQueue=data.upgradeQueue.filter(reason=>reason==="level"||reason==="stage");
    advancing=!!data.advancing;storyFrom=Number.isInteger(data.storyFrom)?clamp(data.storyFrom,-1,stages.length-1):-1;
    const weaponNames=heroes.flatMap(h=>h.weapons).filter(w=>w.hidden).map(w=>w.name);
    newUnlock=weaponNames.includes(data.newUnlock)?data.newUnlock:"";
    currentUpgradeChoices=(Array.isArray(data.currentUpgradeIds)?data.currentUpgradeIds:[]).map(id=>allUpgrades.find(u=>u.id===id)).filter(Boolean);
    camera={x:player.x,y:player.y};audio.unlock();
    if(data.mode==="story")showStory();
    else if(data.mode==="epilogue")showEpilogue();
    else if(data.mode==="encounter")showEncounter();
    else if(data.mode==="eventtrial")showTrialEvent();
    else if(data.mode==="room"&&roomChoice>=0)showRoomChoice();
    else if(data.mode==="map"){mode="map";showMap();}
    else if(data.mode==="paused")renderPause();
    else if(data.mode==="merit")meritShop();
    else if(data.mode==="upgrade"&&upgradeQueue.length)showNextUpgrade();
    else {mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme(bossSpawned?"boss":"travel:"+stages[stageIndex].biome);if(!roomStarted)beginRoom();}
  }
  function showStory(){
    mode="story";resetTouch();touchControls.classList.remove("active");audio.setTheme("story");
    const s=stages[stageIndex],previous=storyFrom>=0?stages[storyFrom]:null;
    showScreen(`<div class="panel story-panel">
      <div class="eyebrow">JOURNEY · CHAPTER ${stageIndex+1}</div>
      <h2 class="modal-title">${s.place}</h2>
      <p class="story-index">第 ${stageIndex+1} / ${stages.length} 章 · 包含原著第 ${s.firstTrial}—${s.lastTrial} 难 · ${s.bossRefs.length?`守关：${s.bossRefs.map(b=>b.boss).join("、")}`:"沿途妖氛"}</p>
      ${previous?`<p class="story-bridge">${previous.bridge}</p>`:""}
      <p class="story-copy">${s.story}</p>
      <p class="story-bridge">${heroes[selectedHero].name}属${SYS.names[SYS.hero[heroes[selectedHero].id]]} · 此地${s.element==="none"?"五行不定":`属${SYS.names[s.element]}`}。克制目标时输出 +12%，被目标克制时输出 -8%。${nurtured()?"此地生养本命：战斗时每秒缓回 0.18 生命，主动技能冷却 -5%，过关回血 +8%。":""}</p>
      ${s.boss&&SYS.tactics[s.boss]?`<p class="story-bridge">土地提示：${SYS.tactics[s.boss]}</p>`:""}
      ${s.kind==="combat"||s.kind==="boss"?`<label class="setting-row check-row ordeal-choice"><span>自选历劫：${s.ordeal.name}<small>${s.ordeal.cost}；${s.ordeal.reward}</small></span><input id="ordeal" type="checkbox" ${player.ordealAccepted?"checked":""}></label>`:""}
      ${newUnlock?`<div class="unlock-notice">✦ 新的专属隐武已收入武器库：${newUnlock}</div>`:""}
      <div class="chapter-progress"><span style="width:${((stageIndex+1)/stages.length)*100}%"></span></div>
      <div class="button-row"><button id="story-go" class="primary" type="button">踏入本章 →</button><button id="story-map" class="secondary" type="button">西行地图</button><button id="story-home" class="secondary" type="button">返回主页</button></div>
    </div>`);
    button("#story-go",()=>{
      newUnlock="";
      player.ordealAccepted=(s.kind==="combat"||s.kind==="boss")&&!!screen.querySelector("#ordeal")?.checked;
      
      mode="playing";hideScreen();touchControls.classList.add("active");banner=`${s.chapter} · ${s.place}`;bannerTime=2.8;
      audio.setTheme("travel:"+s.biome);sayHero(heroTravelLines[heroes[selectedHero].id][stageIndex%4],3);beginRoom();saveRun();
    });
    button("#story-map",showMap);
    button("#story-home",home);
    saveRun();
  }
  function advanceStage(){
    advancing=false;
    unlockAfterTrial();
    if(stageIndex===stages.length-1){epilogueStep=0;showEpilogue();return;}
    if(pendingEncounter){showEncounter();return;}
    const nurtureHeal=nurtured()?1.08:1;
    storyFrom=stageIndex;stageIndex++;stageTime=0;stagePhase=0;bossSpawned=false;spawnTimer=1.2;relicTimer=rand(BAL.relic.nextSpawnMin,BAL.relic.nextSpawnMax);
    roomPlan=rooms.generate(stageIndex,BAL.rooms);roomIndex=0;roomChoice=-1;roomRewardId=null;mapReturnMode="paused";roomStarted=false;roomBattle=false;bossCursor=0;
    enemies=[];projectiles=[];orbs=[];relicDrops=[];effects=[];particles=[];
    player.x=worldSize/2;player.y=worldSize/2;camera={x:player.x,y:player.y};
    const rest=stages[storyFrom].kind==="boss"?.18:stages[storyFrom].kind==="combat"?.12:.04;
    player.hp=Math.min(player.maxHp,player.hp+Math.round(player.maxHp*rest*nurtureHeal));
    player.shieldCharges=Math.min(3,player.startShield);
    player.ordealAccepted=false;
    showStory();
  }
  function completeTrial(withReward=true){
    if((stageIndex+1)%5===0&&stageIndex<stages.length-1)pendingEncounter=true;
    advancing=true;enemies=[];projectiles=[];player.gourdMark=null;player.relicSealTime=0;
    if(withReward)queueUpgrade("stage");else advanceStage();
  }
  function sayHero(line,time=2.8){dialogue=line;dialogueSpeaker=heroes[selectedHero].name;dialogueTime=time;audio.speak(line,"hero");}
  const epilogue=[
    {ch:"99",place:"通天河岸",title:"护经东归",story:"老鼋翻船，师徒把湿透的经卷逐页晾开。虽有残缺，他们仍护着真经归东土。",choice:"把经卷带回长安"},
    {ch:"100",place:"长安与灵山",title:"功成行满",story:"真经送抵东土，取经之约终于完成。师徒回归灵山，各得正果。九九八十一难，至此圆满。",choice:"完成取经"}
  ];
  function showEpilogue(){
    mode="epilogue";resetTouch();touchControls.classList.remove("active");audio.setTheme("story");
    const part=epilogue[Math.min(epilogueStep,epilogue.length-1)];
    showScreen(`<div class="panel story-panel epilogue-panel"><div class="eyebrow">FINAL JOURNEY · CHAPTER ${part.ch}</div>
      <h2 class="modal-title">${part.place}</h2><p class="story-index">终章 ${epilogueStep+1} / ${epilogue.length} · ${part.title}</p>
      <p class="story-copy">${part.story}</p><div class="chapter-progress"><span style="width:${(epilogueStep+1)/epilogue.length*100}%"></span></div>
      <div class="button-row"><button id="epilogue-next" class="primary" type="button">${part.choice} →</button><button id="epilogue-home" class="secondary" type="button">保存并返回主页</button></div></div>`);
    button("#epilogue-next",()=>{epilogueStep++;if(epilogueStep>=epilogue.length)endRun(true);else showEpilogue();});
    button("#epilogue-home",home);saveRun();
  }
  function showMap(){
    const previous=mode==="map"?mapReturnMode:mode;mapReturnMode=previous;mode="map";resetTouch();touchControls.classList.remove("active");saveRun();
    showScreen(`<div class="panel map-panel"><div class="eyebrow">THE WESTWARD ROAD</div><h2 class="modal-title">西行路线</h2>
      <p class="modal-desc">第 ${stageIndex+1} / ${stages.length} 章 · ${stages[stageIndex].place} · 原著第 ${stages[stageIndex].firstTrial}—${stages[stageIndex].lastTrial} 难 · 铜钱 ${coins}</p>
      <div class="room-route">${roomPlan.main.map((id,i)=>{const room=roomPlan.rooms[id],template=rooms.describe(stages[stageIndex],room);return `<span class="room-chip ${i<roomIndex?"cleared":i===roomIndex?"current":"future"}" title="${template.name}">${template.mark} ${template.name}</span>`;}).join("<span class=\"room-arrow\">→</span>")}</div>
      <div class="room-grid" aria-label="当前关卡房间位置">${Array.from({length:rooms.size*rooms.size},(_,cell)=>{const x=cell%rooms.size,y=Math.floor(cell/rooms.size),room=roomPlan.rooms.find(r=>r.x===x&&r.y===y);if(!room)return `<span class="room-grid-empty"></span>`;const order=roomPlan.main.indexOf(room.id);return `<span class="room-grid-cell ${order===roomIndex?"current":order>=0&&order<roomIndex?"cleared":"future"}" title="${rooms.describe(stages[stageIndex],room).name}">${rooms.describe(stages[stageIndex],room).mark}</span>`;}).join("")}</div>
      <div class="route-map">${stages.map((s,i)=>`<div class="route-node ${i<stageIndex?"cleared":i===stageIndex?"current":"future"} ${[4,9,14,19].includes(i)?"waystation":""}"><b>${String(i+1).padStart(2,"0")}</b><span>${s.place}</span><small>${i<=stageIndex?(s.bossRefs.map(b=>b.boss).join("、")||"取经路"):"未抵达"}${(i+1)%10===0?" · 大妖王":(i+1)%5===0?" · 奇遇":""}</small></div>`).join("")}<div class="route-node ${previous==="epilogue"?"current":"future"}"><b>终</b><span>灵山 · 东土</span><small>取经结局</small></div></div>
      <div class="button-row"><button id="map-back" class="primary" type="button">返回旅途</button></div></div>`);
    button("#map-back",()=>{if(previous==="story")showStory();else if(previous==="epilogue")showEpilogue();else if(previous==="encounter")showEncounter();else if(previous==="eventtrial")showTrialEvent();else if(previous==="room")showRoomChoice();else if(previous==="playing"){mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme(bossSpawned?"boss":"travel:"+stages[stageIndex].biome);}else renderPause();});
  }
  const shopCost=item=>Math.round(item.cost*(1+tier()*.04));
  function showEncounter(){showRoomChoice("encounter");}
  function showTrialEvent(){showRoomChoice("eventtrial");}
  const meritGoods=[
    {id:"wukong_clone",name:"猴毛分身诀",hero:"wukong",cost:24},
    {id:"bajie_blood",name:"天蓬回生诀",hero:"bajie",cost:24},
    {id:"shaseng_sand",name:"流沙护阵诀",hero:"shaseng",cost:24},
    {id:"tangseng_mercy",name:"度化偈",hero:"tangseng",cost:24},
    {id:"bailongma_tide",name:"龙脉踏潮诀",hero:"bailongma",cost:24}
  ];
  function meritShop(){
    mode="merit";resetTouch();touchControls.classList.remove("active");audio.setTheme("menu");
    showScreen(`<div class="panel"><div class="eyebrow">MERIT ARCHIVE</div><h2 class="modal-title">功德阁</h2>
      <p class="modal-desc">身故后功德与已解锁内容仍保留。这里只扩充各角色的局内天赋池，不增加开局属性。</p>
      <p class="coin-line">持有功德：${meta.merit}</p><div class="shop-list">${meritGoods.map((g,i)=>`<div class="shop-item"><div><b>${g.name}</b><small>${heroes.find(h=>h.id===g.hero).name}专属 · 加入随机修行池</small></div><button data-merit="${i}" ${meta.collections?.includes(g.id)||meta.merit<g.cost?"disabled":""}>${meta.collections?.includes(g.id)?"已解锁":g.cost+" 功德"}</button></div>`).join("")}</div>
      <div class="button-row"><button id="merit-back" class="primary">返回主页</button></div></div>`);
    screen.querySelectorAll("[data-merit]").forEach(el=>el.addEventListener("click",()=>{
      const g=meritGoods[Number(el.dataset.merit)];if(!g||meta.merit<g.cost||meta.collections?.includes(g.id))return;
      meta.merit-=g.cost;meta.collections=[...new Set([...(meta.collections||[]),g.id])];saveMeta();meritShop();
    }));
    button("#merit-back",home);
  }
  function queueUpgrade(reason){
    upgradeQueue.push(reason);
    if(mode==="playing")showNextUpgrade();
    saveRun();
  }
  function chooseUpgrades(){
    const id=heroes[selectedHero].id;
    const eligible=upgrades.filter(u=>(player.taken[u.id]||0)<u.max&&(!u.hero||u.hero===id)
      &&(!u.metaUnlock||meta.collections.includes(u.id))
      &&(u.tier==="基础"||u.tier==="进阶"&&level>=3||u.tier==="秘传"&&level>=6||u.tier==="专属"&&level>=2));
    const weight=u=>{
      let w=u.hero===id?3:1;
      if(level<=3&&u.tier==="基础")w*=2;
      if(synergies.some(s=>s.requires.includes(u.id)&&s.requires.some(other=>other!==u.id&&player.taken[other]>0)))w*=2.1;
      if(player.taken[u.id])w*=1.35;
      return w;
    };
    let sum=eligible.reduce((a,u)=>a+weight(u),0),roll=Math.random()*sum,passive=eligible[0];
    for(const u of eligible){roll-=weight(u);if(roll<=0){passive=u;break;}}
    const weapon=weaponCards.find(u=>u.hero===id&&(player.taken[u.id]||0)<u.max);
    const skillCard=skillCards.find(u=>u.hero===id&&(player.taken[u.id]||0)<u.max);
    const active=skillCard&&level>=3&&stageIndex>=3&&(Math.random()<.65||stageIndex>=12)
      ?skillCard:activeCards.find(u=>u.hero===id&&(player.taken[u.id]||0)<u.max);
    const picked=[weapon,passive,active].filter(Boolean);
    const fallback=eligible.filter(u=>!picked.includes(u));
    while(picked.length<3&&fallback.length)picked.push(fallback.splice(Math.floor(Math.random()*fallback.length),1)[0]);
    return picked;
  }
  function applyUpgrade(u){
    if(!u||(player.taken[u.id]||0)>=u.max)return;
    u.apply(player);player.taken[u.id]=(player.taken[u.id]||0)+1;
    if(skillCards.includes(u)){selectedSkill=2;player.skillCd=Math.min(player.skillCd,1);banner=`悟得神通 · ${u.name}`;bannerTime=3;}
    player.damage=Math.min(2.8,player.damage);player.attackSpeed=Math.min(2.4,player.attackSpeed);
    for(const s of synergies)if(!player.synergies.includes(s.id)&&s.requires.every(id=>player.taken[id]>0)){
      player.synergies.push(s.id);banner=`联动觉醒 · ${s.name}`;bannerTime=3;audio.effect("win");
    }
    audio.effect("level");saveRun();
  }
  function showNextUpgrade(){
    if(upgradeQueue.length===0){
      currentUpgradeChoices=[];
      if(advancing){advanceStage();return;}
      mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme(bossSpawned?"boss":"travel:"+stages[stageIndex].biome);saveRun();return;
    }
    mode="upgrade";resetTouch();touchControls.classList.remove("active");audio.setTheme("story");
    const reason=upgradeQueue[0];
    if(!currentUpgradeChoices.length)currentUpgradeChoices=chooseUpgrades();
    const nextSynergy=u=>synergies.find(s=>s.requires.includes(u.id) && s.requires.every(id=>id===u.id || player.taken[id]>0) && !player.synergies.includes(s.id));
    showScreen(`<div class="panel"><div class="eyebrow">CHOOSE YOUR PATH · LV.${level}</div>
      <h2 class="modal-title">${reason==="stage"?"此难已过":"修行突破"}</h2>
      ${reason==="stage"&&stages[stageIndex].defeat?`<p class="story-bridge">${stages[stageIndex].defeat}</p>`:""}
      <p class="modal-desc">${reason==="stage"?`走过${stages[stageIndex].trialName}，从兵器、被动、主动神通中择一。`:"获得足够修为，从三项强化中择一；新神通会替换当前主动技能。"}</p>
      <div class="upgrade-grid">${currentUpgradeChoices.map((u,i)=>`<button class="upgrade" data-upgrade="${i}" type="button"><span class="talent-tier">${u.tier}</span><span class="upgrade-icon">${u.icon}</span><strong>${u.name}</strong><small>${u.desc}</small>${nextSynergy(u)?`<em>可激活：${nextSynergy(u).name}</em>`:""}<small>已修 ${player.taken[u.id]||0}/${u.max}</small></button>`).join("")}</div>
      <p class="small-note center">本局已激活联动：${player.synergies.length?synergies.filter(s=>player.synergies.includes(s.id)).map(s=>s.name).join(" · "):"暂无"}<br>进阶修行 LV.3 开放 · 秘传修行 LV.6 开放</p>
    </div>`);
    screen.querySelectorAll("[data-upgrade]").forEach(el=>el.addEventListener("click",()=>{
      const u=currentUpgradeChoices[Number(el.dataset.upgrade)];
      if(!u)return;
      applyUpgrade(u);upgradeQueue.shift();currentUpgradeChoices=[];showNextUpgrade();
    }));
    saveRun();
  }
  function renderPause(){
    mode="paused";resetTouch();touchControls.classList.remove("active");saveRun();
    const learned=upgrades.filter(u=>player.taken[u.id]).map(u=>`${u.name} ×${player.taken[u.id]}`);
    showScreen(`<div class="panel center"><div class="eyebrow">REST AT THE WAYSTATION</div><h2 class="modal-title">暂歇片刻</h2>
      <p class="modal-desc">第 ${stageIndex+1} / ${stages.length} 章 · ${stages[stageIndex].place} · 原著第 ${stages[stageIndex].firstTrial}—${stages[stageIndex].lastTrial} 难<br>本局已自动保存，返回主页后可继续。${player.ordealAccepted?`本关历劫：${stages[stageIndex].ordeal.name}。`:""}</p>
      <div class="build-summary"><b>本局修行录</b><span>${heroes[selectedHero].weapons[selectedWeapon].name} +${player.weaponRank||0} · ${heroes[selectedHero].skills[selectedSkill].name} +${player.skillRank||0}</span><span>伤害 ×${player.damage.toFixed(2)} · 暴击 ${Math.round(player.crit*100)}% · 减伤 ${Math.round(player.armor*100)}% · 心魔 ${player.curse||0} · 铜钱 ${coins}</span><small>${learned.length?learned.join(" · "):"尚未获得强化"}</small></div>
      <div class="button-row"><button class="primary" id="resume" type="button">继续西行</button><button class="secondary" id="pause-map" type="button">西行地图</button><button class="secondary" id="save-now" type="button">保存进度</button><button class="secondary" id="pause-settings" type="button">设置</button><button class="secondary" id="quit" type="button">返回主页</button></div>
      ${relicBagMarkup()}<p class="small-note center" id="save-status"></p>
      <p class="small-note center">P / Esc 继续 · 空格施法 · Shift 闪避</p></div>`);
    button("#resume",()=>{mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme(bossSpawned?"boss":"travel:"+stages[stageIndex].biome);});
    button("#save-now",()=>{saveRun();const label=screen.querySelector("#save-status");if(label)label.textContent="已保存当前战局";audio.effect("select");});
    button("#pause-map",showMap);
    button("#pause-settings",()=>settingsPage("paused"));
    button("#quit",home);
    bindRelicBag(renderPause);
  }
  function pause(){
    if(mode==="playing")renderPause();
    else if(mode==="paused"){mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme(bossSpawned?"boss":"travel:"+stages[stageIndex].biome);}
  }
  function endRun(won){
    mode="ended";resetTouch();touchControls.classList.remove("active");clearRun();audio.setTheme(won?"story":"menu");
    best.stage=Math.max(best.stage,stageIndex+1);best.kills=Math.max(best.kills,kills);
    if(won)best.clears++;saveBest();
    meta.merit+=won?25:Math.min(12,Math.floor((stageIndex+1)/6));saveMeta();
    const time=`${Math.floor(runTime/60)}:${String(Math.floor(runTime%60)).padStart(2,"0")}`;
    showScreen(`<div class="panel center"><div class="eyebrow">${won?"THE JOURNEY IS COMPLETE":"THE JOURNEY CONTINUES"}</div>
      <h2 class="modal-title">${won?"真经已得":"此难未过"}</h2>
      <p class="modal-desc">${won?`你以 ${heroes[selectedHero].name} 历尽九九八十一难，护送真经回到东土。`:`倒在 ${stages[stageIndex].place}。致死伤害：${player.lastHit||"未知"}。已解锁内容与功德会保留。`}</p>
      <div class="stats"><div class="stat"><b>${stageIndex+1}/${stages.length}</b><span>抵达关卡</span></div><div class="stat"><b>${kills}</b><span>击破妖怪</span></div><div class="stat"><b>${time}</b><span>西行时间</span></div></div>
      <div class="button-row"><button class="primary" id="again" type="button">再走一遭</button><button class="secondary" id="home" type="button">返回主页</button></div></div>`);
    button("#again",menu);button("#home",home);audio.effect(won?"win":"hurt");
  }

  function edgeSpawn() {
    const a=rand(0,TWO_PI),r=rand(290,390)/Math.max(1,settings.zoom*.8);
    return {x:clamp(player.x+Math.cos(a)*r,arena.left+24,arena.right-24),
      y:clamp(player.y+Math.sin(a)*r,arena.top+24,arena.bottom-24)};
  }

  function spawnMob(typeKey) {
    const key=typeof typeKey==="string"?typeKey:choose(stages[stageIndex].mobs);
    const type=mobTypes[key]||mobTypes.wolf;
    const pos = edgeSpawn();
    const trialOrdeal=player.ordealAccepted?stages[stageIndex].ordeal:{};
    const scale = (1 + tier() * BAL.enemy.hpPerStage)*(player.challenge?1.15:1)*(trialOrdeal.mobHp||1);
    enemies.push({ ...pos, type: type.type, name: stages[stageIndex].mobNames[key]||type.name, color: type.color, radius: type.radius,
      element:SYS.elementForMob(type.type,stages[stageIndex].element),
      hp: Math.round(type.hp*scale), maxHp: Math.round(type.hp*scale), speed: Math.min(BAL.enemy.maxSpeed,type.speed*(1+tier()*BAL.enemy.speedPerStage)),
      damage: Math.round((Math.max(5,type.damage*.7)+Math.floor(tier()*BAL.enemy.damagePerStage))*(player.challenge?1.15:1)*(trialOrdeal.mobDamage||1)), xp: Math.max(2,Math.round((type.xp+Math.floor(tier()*.35))*BAL.experience.mobMultiplier)), dead:false,boss:false,
      attackCd:rand(1.3,2.4),contactCd:0,slow:0,freeze:0,burn:0,poison:0,dotTick:.5,
      hitFlash:0,knockX:0,knockY:0 });
  }

  function spawnBoss() {
    if (bossSpawned) return;
    bossSpawned = true;
    terrainStage=-1;
    const chapter=stages[stageIndex],stage=chapter.bossRefs[bossCursor];
    if(!stage){bossSpawned=false;return;}
    const pos = edgeSpawn();
    enemies.push({ ...pos, type: stage.type, name: stage.boss, color: stage.accent,element:SYS.elementForTrial(stage),legacyBossIndex:stage.legacyBossIndex,mechanic:stage.mechanic,attack:stage.attack,intro:stage.intro,defeat:stage.defeat,unlock:stage.unlock,ch:stage.ch,accent:stage.accent,
      radius:(stageIndex+1)%10===0?43:35,hp:Math.round(chapter.hp*((stageIndex+1)%10===0?BAL.boss.superHealth:1)*(player.challenge?1.15:1)),maxHp:Math.round(chapter.hp*((stageIndex+1)%10===0?BAL.boss.superHealth:1)*(player.challenge?1.15:1)),speed:Math.min(116,67+tier()*2.2),
      damage:Math.round((19+Math.floor(tier()*.85))*(player.challenge?1.15:1)),xp:40+tier()*4,dead:false,boss:true,windBagHp:stage.legacyBossIndex===2?160:0,
      attackCd:1.7,windup:0,contactCd:0,slow:0,freeze:0,burn:0,poison:0,dotTick:.5,
      hitFlash:0,knockX:0,knockY:0,patternCount:0 });
    if(!meta.seenBosses.includes(stage.boss)){meta.seenBosses.push(stage.boss);saveMeta();}
    banner=`妖王来袭 · ${stage.boss}`;bannerTime=3.2;shake=8;
    sayBoss(stage.intro,4);audio.effect("boss");audio.setTheme("boss");saveRun();
  }
  function sayBoss(line,time=2.6){
    dialogue=line;dialogueSpeaker=enemies.find(e=>e.boss&&!e.dead)?.name||stages[stageIndex].boss||"妖王";dialogueTime=time;
    audio.speak(line,"boss");
  }

  function nearestEnemy(x = player.x, y = player.y, bossFirst = false) {
    let bestEnemy = null, bestDist = Infinity;
    for (const e of enemies) {
      if (e.dead||e.allyTime>0) continue;
      const d = Math.hypot(e.x-x, e.y-y);
      const score = bossFirst && e.boss ? d*.6 : d;
      if (score < bestDist) { bestDist = score; bestEnemy = e; }
    }
    return bestEnemy;
  }

  function burst(x, y, color, count = 8, speed = 85) {
    if(settings.particles==="low")count=Math.ceil(count*.4);
    for (let i=0; i<count; i++) {
      const a = rand(0, TWO_PI), s = rand(speed*.25, speed);
      particles.push({x,y,vx:Math.cos(a)*s,vy:Math.sin(a)*s,life:rand(.25,.65),maxLife:.65,color,size:rand(2,5)});
    }
  }

  function addEffect(type, x, y, radius, color, life = .25, angle = 0, extras = {}) {
    effects.push({ type, x, y, radius, color, life, maxLife:life, angle, ...extras });
  }

  function damageEnemy(e, raw, knock = 0, isSkill = false, flags = {}) {
    if (!e || e.dead||e.allyTime>0) return;
    if(e.windBagHp>0){e.windBagHp=Math.max(0,e.windBagHp-raw);addEffect("ring",e.x+24,e.y-25,28,"#dfca79",.25);if(e.windBagHp===0){banner="风袋已破 · 三昧神风减弱";bannerTime=3;audio.effect("crit");}return;}
    const crit=!flags.noCrit && Math.random()<Math.min(.82,player.crit+(player.dashCritTime>0?.22:0)+(player.relic==="mirror"?.35:0));
    const execute=e.hp/e.maxHp<.2?1+player.execute+(e.boss&&player.synergies.includes("boss_execute")?.25:0):1;
    const heroElement=SYS.hero[heroes[selectedHero].id];
    const elemental=SYS.attackFactor(heroElement,e.element||"none");
    const insight=selectedHero===0&&(e.name==="白骨精"||e.type==="disguised")?1.12:1;
    const shieldBonus=selectedHero===3&&player.shieldCharges>0?1.12:1;
    const dragonBonus=selectedHero===4&&player.dragonTime>0?1.25:1;
    const amount=Math.max(1,Math.round(raw*player.damage*(e.boss?player.bossDamage:1)*(crit?1.65:1)*execute*(e.brokenTime>0?1.08:1)*elemental*insight*shieldBonus*dragonBonus));
    e.hp-=amount;e.hitFlash=.16;
    if(!flags.noStatus&&selectedHero===0&&!flags.noCombo){
      player.combo=Math.min(5,(player.combo||0)+1);player.comboDecay=2.8;
      if(player.combo>=5){
        player.combo=0;addEffect("ring",e.x,e.y,78,"#f6ad67",.34);
        for(const other of enemies)if(other!==e&&!other.dead&&distance(other,e)<78)
          damageEnemy(other,Math.min(22,raw*.65),20,true,{noStatus:true,noChain:true,noCrit:true,noCombo:true});
      }
    }
    if(!flags.noStatus&&selectedHero===3&&!e.boss){
      e.sandMarks=(e.sandMarks||0)+1;e.slow=Math.max(e.slow,1.3);
      if(e.sandMarks>=5){e.sandMarks=0;e.freeze=Math.max(e.freeze,1.05);addEffect("ring",e.x,e.y,48,"#96d5bb",.34);}
    }
    if(e.boss&&selectedHero===0&&player.armorBreak)e.brokenTime=4;
    if(selectedHero===2&&!isSkill&&player.bajieHeal){player.healCd=(player.healCd||0)-.08;if(player.healCd<=0){player.hp=Math.min(player.maxHp,player.hp+Math.min(4,player.bajieHeal));player.healCd=.35;}}
    const dir = norm(e.x-player.x, e.y-player.y);
    e.knockX+=dir.x*knock*player.knockback*(e.boss?.25:1);
    e.knockY+=dir.y*knock*player.knockback*(e.boss?.25:1);
    if(!flags.noStatus){
      if(Math.random()<player.burnChance)e.burn=Math.max(e.burn,player.synergies.includes("firewind")?5:3);
      if(Math.random()<player.freezeChance+(flags.extraFreeze||0))e.freeze=Math.max(e.freeze,1.1);
      if(Math.random()<player.poisonChance)e.poison=Math.max(e.poison,4);
      if(Math.random()<player.lifeSteal)player.hp=Math.min(player.maxHp,player.hp+1);
    }
    if(crit||isSkill||amount>=35){
      effects.push({type:"number",x:e.x,y:e.y-e.radius,vy:-30,text:`${amount}${crit?"!":""}`,color:crit?"#f5d67f":"#f4eee0",life:.6,maxLife:.6});
    }
    burst(e.x,e.y,crit?"#f4d188":e.color,crit?5:2,65);
    if(crit){hitStop=Math.max(hitStop,.025);shake=Math.max(shake,settings.shake?2:0);audio.effect("crit");}
    else if(Math.random()<.22)audio.effect("hit");
    if(crit&&!flags.noChain&&Math.random()<player.chainChance){
      const others=enemies.filter(other=>other!==e&&!other.dead&&distance(other,e)<155);
      const count=player.synergies.includes("thunder_eye")?2:1;
      for(const target of others.slice(0,count)){
        addEffect("beam",e.x,e.y,0,"#badcf2",.19,0,{toX:target.x,toY:target.y});
        damageEnemy(target,Math.max(8,raw*.5),0,true,{noStatus:true,noChain:true,noCrit:true});
      }
    }
    if (e.hp <= 0) {
      e.dead=true;kills++;burst(e.x,e.y,e.color,e.boss?28:8,e.boss?180:105);
      if(e.boss||e.elite||Math.random()<Math.min(.5,BAL.economy.mobCoinChance+player.coinLuck*BAL.economy.coinLuckBonus)){
        const gain=e.boss?BAL.economy.bossCoins+tier()*BAL.economy.bossCoinsPerStage+Math.floor(rand(0,10)):e.elite?BAL.economy.eliteCoins+tier()+Math.floor(rand(0,5)):1+Math.floor(rand(0,4+player.coinLuck*2));
        coins+=gain;effects.push({type:"number",x:e.x,y:e.y+15,vy:-22,text:`+${gain} 文`,color:"#f0d27c",life:.85,maxLife:.85});
      }
      if(e.poison>0&&player.synergies.includes("poison_leech"))player.hp=Math.min(player.maxHp,player.hp+4);
      if(selectedHero===2&&!e.boss)player.hp=Math.min(player.maxHp,player.hp+Math.min(4,player.maxHp*.018));
      if(e.boss)xp+=Math.round(e.xp*player.xpGain);
      else orbs.push({x:e.x+rand(-20,20),y:e.y+rand(-20,20),value:Math.round(e.xp*player.xpGain),life:24});
      if(selectedHero===1&&!e.boss&&!e.elite&&enemies.filter(other=>!other.dead&&other.allyTime>0).length<2
         &&Math.random()<Math.min(.24,.10+(player.convertPower||0)*.045)){
        e.dead=false;e.allyTime=6+(player.convertPower||0)*2;e.allyCd=.15;e.hp=Math.max(1,e.maxHp*.35);
        addEffect("ring",e.x,e.y,55,"#f2dc9d",.45);
      }
      sound(e.boss?280:170,e.boss?.34:.055,"triangle",e.boss?.08:.025);
      if (e.boss) {
        projectiles = projectiles.filter(p => p.friendly);
        const stage=e;
        sayBoss(stage.defeat,3);
        if(stage.unlock&&!meta.unlocks.includes(stage.unlock)){
          meta.unlocks.push(stage.unlock);saveMeta();
          newUnlock=heroes.flatMap(h=>h.weapons).find(w=>w.unlock===stage.unlock)?.name||"专属隐武";
          audio.effect("win");
        }
        hitStop=.14;shake=Math.max(shake,settings.shake?10:0);
        bossCursor++;bossSpawned=false;
        if(bossCursor<stages[stageIndex].bossRefs.length)spawnBoss();else finishRoom();
      }
    } else if(isSkill)sound(430,.07,"triangle",.025);
  }

  function hurtPlayer(raw,status=null,source=null,element="none",delivery="other") {
    if (mode !== "playing" || player.invuln > 0) return;
    if(player.relic==="circle"&&delivery==="projectile"){
      addEffect("ring",player.x,player.y,45,"#c8d9d9",.3);audio.effect("skill");return;
    }
    if(player.shieldCharges>0){player.shieldCharges--;player.invuln=.6;addEffect("ring",player.x,player.y,52,"#bde3d5",.35);audio.effect("skill");return;}
    const relicGuard=player.relic==="pearl"?.55:player.relic==="waterbead"&&element==="water"?.65:1;
    const elemental=SYS.attackFactor(element,SYS.hero[heroes[selectedHero].id]);
    const takenElement=elemental>1?1.10:elemental<1?.94:1;
    const ordeal=player.ordealAccepted?stages[stageIndex].ordeal:{};
    const bossHit=!!source&&enemies.some(e=>e.boss&&source.startsWith(e.name));
    const trialCost=(delivery==="projectile"?ordeal.enemyProjectile||1:1)*(delivery==="touch"&&!bossHit?ordeal.mobTouch||1:1)*(bossHit&&delivery!=="touch"?ordeal.bossSpell||1:1)*(status==="burn"?ordeal.burn||1:1);
    const hardy=selectedHero===2&&player.hp/player.maxHp>.6?.90:1;
    const dmg=Math.max(1,Math.round(raw*(1-player.armor)*(player.shieldTime>0?.35:1)*relicGuard*(player.riskTime>0?1.35:1)*(1+(player.curse||0)*.18)*takenElement*trialCost*hardy));
    player.lastHit=`${source||stages[stageIndex].boss||"沿途妖怪"} · ${SYS.names[element]||"无"}行${status==="burn"?"火":status==="poison"?"毒":status==="slow"?"法术":status==="blind"?"风沙":"物理"} ${dmg}`;
    player.hp -= dmg; player.invuln = .7; shake = Math.max(shake, 5);
    if(selectedHero===1&&player.passiveCd<=0){player.shieldTime=Math.max(player.shieldTime,1.2);player.passiveCd=9;addEffect("ring",player.x,player.y,65,"#ffebbd",.5);}
    if(status==="burn")player.burnTime=Math.max(player.burnTime,3.2);
    if(status==="poison")player.poisonTime=Math.max(player.poisonTime,4.2);
    if(status==="slow")player.slowTime=Math.max(player.slowTime,3);
    if(status==="blind")player.blindTime=Math.max(player.blindTime||0,2.8);
    burst(player.x, player.y, "#e98572", 7, 75);
    effects.push({type:"number",x:player.x,y:player.y-25,vy:-36,text:`-${dmg}`,color:"#f48f78",life:.6,maxLife:.6});
    audio.effect("hurt");
    if (player.hp <= 0) { player.hp = 0; endRun(false); }
  }

  function shoot(x, y, dx, dy, speed, damage, opts = {}) {
    const v = norm(dx,dy);
    const friendly=opts.friendly!==false;
    const factor=friendly?player.projectileSpeed:1;
    projectiles.push({x,y,vx:v.x*speed*factor,vy:v.y*speed*factor,damage,
      radius:(opts.radius||6)*(friendly?player.projectileSize:1),
      life:opts.life||2, friendly:opts.friendly!==false, color:opts.color||"#efd18b",element:opts.element||(friendly?SYS.hero[heroes[selectedHero].id]:stages[stageIndex].element),
      pierce:(opts.pierce||0)+(friendly?player.pierce:0),homing:opts.homing||false,
      hit:new Set(),type:opts.type||"bolt",extraFreeze:opts.extraFreeze||0,ignite:opts.ignite||false,
      slow:opts.slow||false,status:opts.status||null,source:opts.source||null});
  }

  function attack() {
    const target = nearestEnemy();
    if (!target) return;
    const hero = heroes[selectedHero], weapon = hero.weapons[selectedWeapon];
    const dir = norm(target.x-player.x,target.y-player.y);
    player.facing = dir;
    const kind = weapon.mode;
    const weaponDamage=weapon.damage*(1+Math.min(5,player.weaponRank||0)*.12)*(selectedHero===4?1+player.momentum*(.22+(player.tidePower||0)+(player.skillRank||0)*.08):1);
    const angle=Math.atan2(dir.y,dir.x);
    if (["staff","rake","firestaff","earthrake"].includes(kind)) {
      const radius=(kind==="earthrake"?132:kind==="rake"?108:kind==="firestaff"?105:88)*player.area*(selectedHero===0?1+player.heroTalent*.16:1);
      const threshold=kind==="earthrake"?-.2:kind==="rake"?.22:.42;
      for (const e of enemies) {
        if (e.dead) continue;
        const d = distance(e,player);
        if (d < radius + e.radius) {
          const toward = norm(e.x-player.x,e.y-player.y);
          if (toward.x*dir.x+toward.y*dir.y > threshold){
            damageEnemy(e,weaponDamage,kind==="earthrake"?160:95);
            if(kind==="firestaff")e.burn=Math.max(e.burn,4);
          }
        }
      }
      addEffect("slash",player.x,player.y,radius,kind==="firestaff"?"#f39a63":kind==="earthrake"?"#edc783":"#f2cb7f",.22,angle);
      if(player.heroTalent&&selectedHero===0)addEffect("slash",player.x+dir.x*20,player.y+dir.y*20,radius*.7,"#ffe4a5",.3,angle+.27);
      if(player.heroTalent&&selectedHero===2){addEffect("ring",player.x+dir.x*45,player.y+dir.y*45,radius*.8,"#d9a879",.35);for(const e of enemies)if(!e.dead&&distance(e,{x:player.x+dir.x*55,y:player.y+dir.y*55})<45)damageEnemy(e,8*player.heroTalent,80);}
      if(kind==="earthrake")addEffect("ring",player.x,player.y,radius*.78,"#d5ae75",.27);
      burst(player.x+dir.x*55,player.y+dir.y*55,kind==="firestaff"?"#f18352":"#ecc88d",7,100);
      sound(kind==="rake"||kind==="earthrake"?230:345,.09,"square",.034);
    } else if (["pulse","whirl","bell","hooves"].includes(kind)) {
      const radius=(kind==="bell"?160:kind==="pulse"?99:kind==="hooves"?85:75)*player.area;
      for (const e of enemies) if (!e.dead && distance(e,player)<radius+e.radius) {
        damageEnemy(e,weaponDamage,kind==="bell"?125:kind==="pulse"?60:35);
        if(kind==="bell")e.slow=Math.max(e.slow,1.1);
      }
      addEffect("ring",player.x,player.y,radius,kind==="bell"?"#f3e5ab":kind==="pulse"?"#f3e6b2":"#d89f82",.35);
      if(player.heroTalent&&selectedHero===1)addEffect("ring",player.x,player.y,radius*.65,"#fff7d6",.55);
      sound(kind==="bell"?790:kind==="pulse"?670:250,.14,"triangle",.04);
    } else if (kind==="homing") {
      const count=2+player.extraShots;
      for(let i=0;i<count;i++){
        const a=(i-(count-1)/2)*.19,ang=angle+a;
        shoot(player.x,player.y,Math.cos(ang),Math.sin(ang),270,weaponDamage,{radius:7,life:2.5,homing:true,color:"#f3df9a",extraFreeze:player.synergies.includes("frost_split")?.12:0});
        if(player.heroTalent&&selectedHero===1)addEffect("ring",player.x+Math.cos(ang)*18,player.y+Math.sin(ang)*18,16,"#fff0b7",.27);
      }
      sound(700,.08,"sine",.028);
    } else if(kind==="fan"){
      const count=3+player.extraShots;
      for(let i=0;i<count;i++){
        const a=(i-(count-1)/2)*.23,ang=angle+a;
        shoot(player.x,player.y,Math.cos(ang),Math.sin(ang),370,weaponDamage,{radius:6,life:1.8,color:"#87c5d2",slow:player.heroTalent&&selectedHero===3,extraFreeze:player.synergies.includes("frost_split")?.12:0});
      }
      sound(470,.08,"triangle",.034);
    } else {
      const count=1+player.extraShots+(kind==="dragonwave"?1:0)+(selectedHero===4&&player.momentum>.75?(player.surfPower||0):0);
      for(let i=0;i<count;i++){
        const a=(i-(count-1)/2)*.15,ang=angle+a;
        shoot(player.x,player.y,Math.cos(ang),Math.sin(ang),["spear","dragonlance","dragonwave"].includes(kind)?475:420,weaponDamage,
          {radius:["spear","dragonlance"].includes(kind)?7:9,life:2,pierce:kind==="spear"?3:kind==="windstaff"?4:kind==="dragonlance"?2:5,
            color:kind==="windstaff"?"#a4e3df":kind.startsWith("dragon")?"#a4e8ed":kind==="spear"?"#9fcddd":"#efcb7d",type:"spear",slow:kind==="windstaff"||kind.startsWith("dragon")||(player.heroTalent&&selectedHero===3),
            extraFreeze:player.synergies.includes("frost_split")?.12:0});
      }
      sound(kind==="spear"?520:300,.09,"triangle",.032);
    }
    player.weaponSwing=.24;
    player.weaponCd=Math.max(.15,weapon.cooldown/(player.attackSpeed*(selectedHero===0?1+(player.combo||0)*.04:1)));
  }

  function skill() {
    if (mode !== "playing" || player.skillCd > 0) return;
    const hero = heroes[selectedHero];
    player.skillCd = hero.skills[selectedSkill].cooldown * player.skillHaste * (nurtured()?.95:1);
    const id = hero.id, alt = selectedSkill === 1;
    if(selectedSkill===2){
      if(id==="wukong"){
        for(const e of enemies)if(!e.dead&&distance(e,player)<175*player.area+e.radius){
          damageEnemy(e,25,35,true);
          if(e.boss)e.slow=Math.max(e.slow,1.1);else e.freeze=Math.max(e.freeze,2);
          addEffect("ring",e.x,e.y,e.radius+22,"#f4cf80",.42);
        }
      }else if(id==="tangseng"){
        player.burnTime=0;player.poisonTime=0;
        const target=nearestEnemy(),dir=target?norm(target.x-player.x,target.y-player.y):player.facing;
        shoot(player.x,player.y,dir.x,dir.y,530,64,{radius:12,pierce:5,life:2,color:"#fff0b2",type:"sutra"});
        addEffect("slash",player.x,player.y,160,"#fff3bc",.38,Math.atan2(dir.y,dir.x));
      }else if(id==="bajie"){
        let hits=0;
        for(const e of enemies)if(!e.dead&&distance(e,player)<155*player.area+e.radius){damageEnemy(e,42,140,true);e.slow=Math.max(e.slow,3);hits++;}
        player.hp=Math.min(player.maxHp,player.hp+Math.min(18,hits*5));
        addEffect("ring",player.x,player.y,155*player.area,"#dfaf79",.5);
      }else if(id==="shaseng"){
        const target=nearestEnemy(),angle=target?Math.atan2(target.y-player.y,target.x-player.x):Math.atan2(player.facing.y,player.facing.x);
        for(let i=-1;i<=1;i++){const a=angle+i*.18;shoot(player.x,player.y,Math.cos(a),Math.sin(a),440,31,{radius:8,pierce:3,life:1.8,color:"#9adbd1",type:"moon",slow:true});}
        addEffect("ring",player.x,player.y,85,"#a3ddd5",.4);
      }else if(id==="bailongma"){
        const target=nearestEnemy(),angle=target?Math.atan2(target.y-player.y,target.x-player.x):Math.atan2(player.facing.y,player.facing.x);
        for(let i=-1;i<=1;i++){const a=angle+i*.21;shoot(player.x,player.y,Math.cos(a),Math.sin(a),460,27,{radius:9,pierce:2,life:1.6,color:"#8ce3ed",type:"water",slow:true});}
        player.momentum=Math.min(1,player.momentum+.28);
        addEffect("fan",player.x,player.y,145,"#8ce3ed",.4,angle);
      }
    }else if (id === "wukong") {
      if (!alt) { player.cloneTime = 8+(player.clonePower||0)*2; player.cloneCd = .1; addEffect("ring",player.x,player.y,85,"#f0ca80",.5); }
      else { player.invuln = 1.3; for(const e of enemies) if(!e.dead && distance(e,player)<150*player.area+e.radius) damageEnemy(e,45,250,true); addEffect("ring",player.x,player.y,150*player.area,"#f1d083",.45); }
    } else if (id === "tangseng") {
      if (!alt) { player.hp = Math.min(player.maxHp,player.hp+38);if(player.purifyPower){player.burnTime=0;player.poisonTime=0;player.slowTime=0;} for(const e of enemies) if(!e.dead && distance(e,player)<130*player.area+e.radius){e.slow=2.5;damageEnemy(e,16+(player.purifyPower||0)*6,70,true);} addEffect("ring",player.x,player.y,130*player.area,"#fff2bc",.55); }
      else { const e=enemies.find(x=>!x.dead&&!x.boss&&distance(x,player)<300);if(e){e.allyTime=6+(player.convertPower||0)*3+(player.skillRank||0);e.allyCd=.1;addEffect("ring",e.x,e.y,55,"#f4d391",.65);}else{const boss=nearestEnemy(player.x,player.y,true);if(boss){damageEnemy(boss,65,0,true);boss.slow=2;}} }
    } else if (id === "bajie") {
      if (!alt) { player.shieldTime=5+(player.skillRank||0)*.5; addEffect("ring",player.x,player.y,70,"#edb39b",.48); }
      else { for(const e of enemies) if(!e.dead && distance(e,player)<170*player.area+e.radius) damageEnemy(e,60,260,true);addEffect("ring",player.x,player.y,170*player.area,"#e9a77e",.5); }
    } else if(id==="shaseng"){
      if(player.sandBarrier)player.shieldCharges=Math.min(4,player.shieldCharges+player.sandBarrier);
      if (!alt) { player.fieldTime=6+(player.skillRank||0)*.5;player.fieldTick=.05;addEffect("ring",player.x,player.y,140,"#82c9d7",.5); }
      else { for(const e of enemies) if(!e.dead && distance(e,player)<230*player.area+e.radius) damageEnemy(e,47,110,true);addEffect("ring",player.x,player.y,230*player.area,"#a4dbe6",.58); }
    } else if(id==="bailongma"){
      if(!alt){player.fieldTime=5;player.fieldTick=.05;for(const e of enemies)if(!e.dead&&distance(e,player)<180+e.radius){e.slow=3;damageEnemy(e,35+player.momentum*20,110,true);}addEffect("ring",player.x,player.y,180,"#8ce1ea",.6);}
      else{player.invuln=1;player.dashTime=.32;player.dashDir=player.facing;player.momentum=0;player.dragonTime=5+(player.skillRank||0)*.4;addEffect("slash",player.x,player.y,140,"#b3ecf2",.45,Math.atan2(player.facing.y,player.facing.x));}
    }
    burst(player.x,player.y,hero.color,15,140);shake=settings.shake?5:0;audio.effect("skill");
    if(player.resonance)for(const e of enemies)if(!e.dead&&distance(e,player)<100+player.resonance*18)damageEnemy(e,12*player.resonance,80,true);
  }

  function dash() {
    if (mode !== "playing" || player.dashCd > 0) return;
    const dx = (keys.has("d")||keys.has("arrowright")?1:0)-(keys.has("a")||keys.has("arrowleft")?1:0)+touch.x;
    const dy = (keys.has("s")||keys.has("arrowdown")?1:0)-(keys.has("w")||keys.has("arrowup")?1:0)+touch.y;
    const v = norm(dx||player.facing.x,dy||player.facing.y);
    player.dashDir=v;player.dashTime=.17;player.dashCd=3.1*player.dashHaste;player.invuln=.26;
    if(selectedHero===0)player.dashCritTime=2;
    if(selectedHero===4&&player.scalePower)player.shieldCharges=Math.min(3,player.shieldCharges+1);
    addEffect("ring",player.x,player.y,32,"#d2ecdc",.22);
    if(player.dashBlast)for(const e of enemies)if(!e.dead&&distance(e,player)<100+e.radius)damageEnemy(e,player.dashBlast,100,true);
    audio.effect("dash");
  }

  function bossAttack(e) {
    const stage=e,toward=norm(player.x-e.x,player.y-e.y);
    const aim=Math.atan2(toward.y,toward.x),color=stage.accent;
    const raw=11+Math.floor(tier()*.7);
    const status=stage.legacyBossIndex===2?"blind":stage.ch===40||stage.ch===70?"burn":
      stage.ch===55||stage.ch===72?"poison":
      stage.ch===20||stage.ch===47||stage.ch===95?"slow":null;
    const cast=(a,s=205,r=7,c=color,st=status,type="bolt")=>shoot(e.x,e.y,Math.cos(a),Math.sin(a),s,raw,{friendly:false,radius:r,life:3.2,color:c,status:st,type,source:e.name});
    const fan=(n,spread,s=210,c=color,st=status,type="bolt")=>{for(let i=0;i<n;i++)cast(aim+(i-(n-1)/2)*spread,s,8,c,st,type);};
    const ring=(n,s=180,c=color,st=status,type="bolt",offset=0)=>{for(let i=0;i<n;i++)cast(i*TWO_PI/n+offset,s,7,c,st,type);};
    const dashToward=(force=440)=>{e.knockX+=toward.x*force;e.knockY+=toward.y*force;addEffect("slash",e.x,e.y,115,color,.34,aim);};
    switch(stage.legacyBossIndex){
      case 0: dashToward(570);fan(3,.24,250,"#f3b475",null,"claw");break; // 寅将军：扑杀
      case 1: dashToward(310);ring(9,155,"#5b756d",null,"wind");break; // 黑熊精：黑风
      case 2: fan(e.windBagHp>0?13:5,.11,260,"#e3c77f","blind","sand");addEffect("fan",e.x,e.y,220,"#e2c17c",.48,aim);break;
      case 3: {const old={x:e.x,y:e.y},form=e.hp/e.maxHp>.66?0:e.hp/e.maxHp>.33?1:2;const pos=edgeSpawn();e.x=pos.x;e.y=pos.y;addEffect("ring",old.x,old.y,90,"#e9e2d6",.5);
        if(form===0){ring(6,155,"#e7e0d3",null,"bone");if(enemies.filter(m=>!m.boss&&!m.dead).length<14)spawnMob("bonelet");}
        else if(form===1)fan(7,.13,250,"#d9d1c7","slow","bone");
        else{ring(12,190,"#ede7df",null,"bone",e.patternCount*.15);fan(5,.19,270,"#f2e6d8",null,"bone");}
        if(e.phaseIndex!==form){e.phaseIndex=form;banner=["村姑形现","老妇形现 · 骨刺袭来","老翁形现 · 骨矛四散"][form];bannerTime=2.8;}break;}
      case 4: fan(5,.32,230,"#a6a3dc",null,"star");ring(6,140,"#d3c4e7",null,"star",e.patternCount*.23);break;
      case 5: ring(10,165,"#d9b777",null,"gourd",e.patternCount*.16);fan(3,.16,275,"#f3d190",null,"gourd");player.gourdMark={x:player.x,y:player.y,time:2.2,source:e.name};banner="紫金葫芦点名！迅速离开光圈";bannerTime=2.2;break;
      case 6: fan(11,.12,265,"#ff8750","burn","flame");dashToward(220);effects.push({type:"firezone",x:player.x,y:player.y,radius:76,color:"#f3874e",life:4,maxLife:4,tick:.25});break;
      case 7: ring(12,180,"#dcb876",null,"talisman",e.patternCount*.11);fan(3,.25,250,"#f4de9c",null,"talisman");break;
      case 8: ring(14,155,"#81cdda","slow","water",e.patternCount*.12);fan(3,.28,235,"#b6edf0","slow","ice");break;
      case 9: fan(7,.18,245,"#bdccca","slow","ring");addEffect("ring",player.x,player.y,72,"#d4e5e1",.55);
        if(distance(player,e)>135){player.relicSealTime=4;banner="金刚琢收宝！贴近青牛可避开";bannerTime=2.4;}break;
      case 10: fan(5,.16,320,"#df9cbd","poison","sting");dashToward(370);break;
      case 11: dashToward(650);ring(12,175,"#f39758","burn","flame");break;
      case 12: ring(11,160,"#edca82",null,"bell");fan(5,.13,255,"#f5dc9f",null,"bell");break;
      case 13: {const phase=e.patternCount%3;fan(7,.17,245,["#a4afb2","#d9bb80","#f08e63"][phase],["slow","slow","burn"][phase],["smoke","sand","flame"][phase]);ring(5,145,color,null,"bell");break;}
      case 14: ring(16,185,"#bb9cc9","poison","eye",e.patternCount*.09);fan(3,.18,290,"#edc6e9","poison","eye");break;
      case 15: {const pos=edgeSpawn();addEffect("ring",e.x,e.y,90,color,.3);e.x=pos.x;e.y=pos.y;fan(9,.14,260,"#cab6e9",null,"feather");
        player.gourdMark={x:player.x,y:player.y,time:1.5,source:e.name,kind:"dive"};banner="大鹏羽影落下！闪避离开阴影";bannerTime=2.3;break;}
      case 16: ring(8,165,"#c4d6a5",null,"antler");fan(5,.25,260,"#ecddab",null,"antler");break;
      case 17: dashToward(540);fan(7,.18,220,"#e3c47d",null,"rake");break;
      case 18: ring(18,205,"#f2d992",null,"roar",e.patternCount*.08);if(enemies.filter(m=>!m.boss&&!m.dead).length<15)spawnMob("lionlet");break;
      case 19: {const pos=edgeSpawn();e.x=pos.x;e.y=pos.y;ring(10,190,"#efcfeb","slow","moon",e.patternCount*.15);fan(3,.12,285,"#f4e0f4","slow","moon");break;}
    }
    if(stage.mechanic==="gourd"){fan(4,.19,255,"#cbd9dc",null,"bottle");player.gourdMark={x:player.x,y:player.y,time:2.2,source:e.name};banner="羊脂玉净瓶点名！离开光圈";bannerTime=2.2;}
    if(stage.mechanic==="gust"){fan(9,.12,295,"#e9c295","slow","gust");player.knockX=(player.knockX||0)+toward.x*180;player.knockY=(player.knockY||0)+toward.y*180;addEffect("fan",e.x,e.y,260,"#e8c79e",.6,aim);}
    if(stage.mechanic==="mirror"){const pos=edgeSpawn();addEffect("ring",e.x,e.y,55,"#d4b0a4",.4);e.x=pos.x;e.y=pos.y;fan(5,.17,240,"#e9c688",null,"staff");}
    if(stage.mechanic==="blink"){const pos=edgeSpawn();e.x=pos.x;e.y=pos.y;ring(7,180,"#e0bbcf",null,"lamp");}
    if(stage.mechanic==="fog"){fan(8,.14,210,"#c8c3a8","blind","fog");}
    if(stage.mechanic==="ice"){ring(12,190,"#a7dce2","slow","ice");effects.push({type:"firezone",x:player.x,y:player.y,radius:72,color:"#a7dce2",life:3,maxLife:3,tick:.5,status:"slow"});}
    addEffect("ring",e.x,e.y,110,color,.35);
    e.patternCount++;e.attackCd=Math.max(1.18,2.7-tier()*.035);
    if(e.hp<e.maxHp*.5){if(!e.phaseTwo){e.phaseTwo=true;banner=`${e.name}显露凶相 · 第二阶段`;bannerTime=3;sayBoss(stage.attack?.at(-1)||stage.intro,2.6);}ring(8,240,"#f5e1ad",status,"rampage",e.patternCount*.2);e.attackCd*=.78;}
    shake=Math.max(shake,settings.shake?5:0);audio.effect("boss");
  }

  function spawnRelic(){
    const relic=rollRelic(),a=rand(0,TWO_PI),r=rand(95,220);
    relicDrops.push({id:relic.id,x:clamp(player.x+Math.cos(a)*r,arena.left+20,arena.right-20),
      y:clamp(player.y+Math.sin(a)*r,arena.top+20,arena.bottom-20),life:21});
    addEffect("ring",relicDrops.at(-1).x,relicDrops.at(-1).y,32,relic.color,.5);
  }
  function beginRoom(){
    if(roomStarted)return;
    const room=roomAt(roomIndex),stage=stages[stageIndex];
    roomStarted=true;roomBattle=false;roomChoice=-1;roomRewardId=null;roomOffer=null;terrainStage=-1;
    enemies=[];projectiles=[];player.x=worldSize/2;player.y=worldSize/2;
    banner=`${rooms.describe(stage,room).name} · ${roomIndex+1}/${roomPlan.main.length}`;bannerTime=2.6;
    if(room.type==="combat"||room.type==="elite"){
      const count=room.type==="elite"?4:4+Math.min(2,Math.floor(stageIndex/12));
      for(let i=0;i<count;i++)spawnMob();
      if(room.type==="elite"){
        const elite=enemies[0];elite.elite=true;elite.radius=Math.round(elite.radius*1.25);
        elite.maxHp=Math.round(elite.maxHp*2.6);elite.hp=elite.maxHp;
        elite.damage=Math.round(elite.damage*1.25);elite.xp=Math.round(elite.xp*2);
        elite.name=`头目 · ${elite.name}`;
      }
      mode="playing";hideScreen();touchControls.classList.add("active");
      audio.setTheme("travel:"+stage.biome);sayHero(room.type==="elite"?"寨门已开，先破那妖将！":"前方妖风起，护好经卷。",2.5);
    }else if(room.type==="boss"){
      mode="playing";hideScreen();touchControls.classList.add("active");
      bossCursor=0;bossSpawned=false;spawnBoss();
    }else showRoomChoice();
    saveRun();
  }
  function finishRoom(){
    const room=roomAt(roomIndex),stage=stages[stageIndex];
    xp+=orbs.reduce((sum,o)=>sum+o.value,0);orbs=[];
    if(room.type==="combat"){coins+=4+Math.floor(tier()/3);xp+=8+Math.floor(tier()/2);}
    if(room.type==="elite"){
      coins+=BAL.economy.eliteCoins+Math.floor(tier()/2);
      addRelicFragments(1);
      xp+=15+Math.floor(tier());
    }
    if(roomBattle){
      coins+=player.eventReward||12+Math.floor(tier());player.eventReward=0;roomBattle=false;
      if(roomOffer?.key.startsWith("eventtrial:")){roomOffer=null;completeTrial(true);return;}
    }
    enemies=[];projectiles=[];roomStarted=false;roomChoice=-1;roomRewardId=null;
    if(roomIndex>=roomPlan.main.length-1){completeTrial(true);return;}
    roomIndex++;terrainStage=-1;beginRoom();
  }
  function roomContext(){
    return {player,hero:heroes[selectedHero].id,place:stages[stageIndex].place,tier:tier(),
      price:n=>shopCost({cost:n}),relic:relicTypes.find(r=>r.id===roomRewardId)||relicTypes[0],
      relicName:id=>relicTypes.find(r=>r.id===id)?.name||"无",upgrades:allUpgrades,
      skillId:skillCards.find(u=>u.hero===heroes[selectedHero].id)?.id,
      restHeal:rooms.describe(stages[stageIndex],roomAt(roomIndex)).name.includes("老君")?.42:.28,
      addCoins:n=>coins+=n,addXp:n=>xp+=n,addFragments:addRelicFragments,storeRelic,upgrade:applyUpgrade,
      battle:(count,reward)=>{
        enemies=[];projectiles=[];
        for(let i=0;i<count;i++)spawnMob();
        if(selectedHero===0)for(const e of enemies){e.hp=Math.ceil(e.hp*.75);e.maxHp=e.hp;}
        player.eventReward=reward;roomBattle=true;roomStarted=true;return "battle";
      }};
  }
  function choiceReason(choice){
    if(roomOffer?.bought.includes(choice.id))return "已购入，本店仅此一份";
    if(!choice.visible())return "当前没有符合条件的物品";
    const reason=choice.check();
    if(reason)return reason;
    return coins<choice.cost?`铜钱不足，还需 ${choice.cost-coins} 文`:"";
  }
  function showRoomChoice(kind="room"){
    const stage=stages[stageIndex],room=roomAt(roomIndex);
    const type=kind==="encounter"?"shop":kind==="eventtrial"?"event":room.type;
    const info=rooms.describe(stage,{...room,type}),key=`${kind}:${stageIndex}:${roomIndex}`;
    const firstVisit=kind==="room"&&roomChoice!==roomIndex;
    mode=kind;resetTouch();touchControls.classList.remove("active");audio.setTheme("story");
    if(kind==="room")roomChoice=roomIndex;
    if(firstVisit&&type==="shrine")player.hp=Math.min(player.maxHp,player.hp+Math.ceil(player.maxHp*.08));
    if(!roomRewardId)roomRewardId=rollRelic(type==="shop"?"shop":"reward").id;
    let content=window.XIYOU_ROOM_CONTENT.build(roomContext());
    if(!roomOffer||roomOffer.key!==key){
      roomOffer={key,ids:[],bought:[],eventId:null,message:""};
      if(type==="event"){
        const roll=window.XIYOU_ROOM_CONTENT.rotate(content.events.filter(e=>e.eligible),1,player.offerHistory.events);
        player.offerHistory.events=roll.history;roomOffer.eventId=roll.ids[0];
        roomOffer.ids=content.events.find(e=>e.id===roomOffer.eventId).choices.filter(c=>c.visible()).map(c=>c.id);
      }else if(type==="shop"||type==="shrine"){
        // 不抽取对当前角色完全无效的商品；资金不足仍展示价格与差额。
        const pool=content[type].filter(c=>c.visible()&&!c.check());
        const roll=window.XIYOU_ROOM_CONTENT.rotate(pool,type==="shop"?6:4,player.offerHistory[type]);
        player.offerHistory[type]=roll.history;roomOffer.ids=roll.ids;
      }else roomOffer.ids=(content[type]||[]).filter(c=>c.visible()).map(c=>c.id);
    }
    let intro=info.intro,event=content.events.find(e=>e.id===roomOffer.eventId&&e.eligible);
    if(type==="event"&&event)intro=`${event.name} · ${event.intro}`;
    if(type==="shrine"){
      const boss=stage.bossRefs[0]?.boss;
      intro+=` 本次到访已赠草药，回复至多 8% 最大生命。${boss&&SYS.tactics[boss]?`土地提醒：${SYS.tactics[boss]}`:"土地指明前路，嘱咐师徒谨慎而行。"}`;
    }
    const pool=type==="event"?(event?.choices||[]):content[type]||[];
    const choices=roomOffer.ids.map(id=>pool.find(c=>c.id===id)).filter(c=>c&&c.visible());
    choices.push(content.leave);
    const offer=roomOffer;
    showScreen(`<div class="panel room-panel"><div class="eyebrow">${stage.place} · ${kind==="encounter"?"章末行商":`房间 ${roomIndex+1}/${roomPlan.main.length}`}</div><h2 class="modal-title">${info.name}</h2><p class="story-copy">${intro}</p>
      <p class="coin-line">铜钱 ${coins} · 生命 ${Math.ceil(player.hp)}/${player.maxHp} · 心魔 ${player.curse||0}<br>法宝 ${player.relicBag.length}/${player.relicCapacity} · 碎片 ${player.relicFragments||0} · 修为 ${Math.floor(xp)}/${xpGoal}</p>
      <p class="small-note center">${type==="shop"?"本店随机陈列 6 件商品，可连续购买，每件限购一次。":"本次机缘择一，选后继续前行。"} 查看地图和读档会保留本次选项。</p>
      ${offer.message?`<p class="room-feedback" role="status">${offer.message}</p>`:""}
      <div class="upgrade-grid">${choices.map((c,i)=>{const reason=choiceReason(c);return `<button class="upgrade" data-room-option="${i}" data-choice-id="${c.id}" type="button" ${reason?"disabled":""}><strong>${c.name}</strong><small>${c.cost?`花费 ${c.cost} 文；`:""}${c.desc}</small>${reason?`<em class="option-reason">${reason}</em>`:""}</button>`;}).join("")}</div>
      ${relicBagMarkup()}<div class="button-row"><button id="room-map" class="secondary">查看地图</button></div></div>`);
    screen.querySelectorAll("[data-room-option]").forEach(el=>el.addEventListener("click",()=>{
      if(mode!==kind||roomOffer!==offer)return;
      const choice=choices[Number(el.dataset.roomOption)];if(!choice)return;
      const reason=choiceReason(choice);
      if(reason){offer.message=reason;showRoomChoice(kind);return;}
      const result=choice.run();
      if(result===false){offer.message="当前条件已变化，请整理行囊后再试。";showRoomChoice(kind);return;}
      coins-=choice.cost;audio.effect("pickup");
      if(result==="battle"){
        mode="playing";hideScreen();touchControls.classList.add("active");audio.setTheme("travel:"+stage.biome);saveRun();
      }else if(type==="shop"&&choice.id!=="leave"){
        offer.bought.push(choice.id);offer.message=`已购入：${choice.name}。${choice.desc}`;
        showRoomChoice(kind);
      }else if(kind==="encounter"){
        roomOffer=null;roomRewardId=null;pendingEncounter=false;encounterIndex=-1;advanceStage();
      }else if(kind==="eventtrial")completeTrial(false);
      else finishRoom();
    }));
    bindRelicBag(()=>showRoomChoice(kind));
    button("#room-map",showMap);saveRun();
  }
  function addRelicFragments(amount){
    player.relicFragments=(player.relicFragments||0)+amount;
    while(player.relicFragments>=3&&player.relicBag.length<player.relicCapacity){
      if(!storeRelic(rollRelic("reward").id))break;
      player.relicFragments-=3;
    }
  }
  function relicBagMarkup(){
    return `<details class="relic-inventory"><summary>整理法宝袋 · ${player.relicBag.length}/${player.relicCapacity}</summary>
      <p class="small-note">Q / 触屏法宝键使用袋首。可将想用的法宝置于首位；舍弃会永久移除该件。即时灵药可在此服用。</p>
      ${player.relicBag.length?player.relicBag.map((id,i)=>{const r=relicTypes.find(r=>r.id===id);return `<div class="bag-item"><b>${i===0?"袋首 · ":""}${r.name}</b><small>${r.desc}</small><div class="bag-actions"><button data-bag-first="${i}" ${i===0?"disabled":""}>置于首位</button>${["peach","bottle"].includes(id)?`<button data-bag-use="${i}" ${relicUseReason(id,true)?"disabled":""}>立即服用</button>`:""}<button data-bag-drop="${i}">舍弃 ${r.name}</button></div></div>`;}).join(""):"<p class=\"small-note\">尚未持有法宝。遇到宝匣或购入后会列在这里。</p>"}
      ${player.relicFragments>=3?`<button id="bag-craft" ${player.relicBag.length>=player.relicCapacity?"disabled":""}>消耗 3 碎片合成法宝${player.relicBag.length>=player.relicCapacity?"（需空位）":""}</button>`:""}</details>`;
  }
  function bindRelicBag(refresh){
    const bag=player.relicBag.slice();
    for(const action of ["first","drop","use"]){
      screen.querySelectorAll(`[data-bag-${action}]`).forEach(el=>el.addEventListener("click",()=>{
        const i=Number(el.dataset[`bag${action[0].toUpperCase()+action.slice(1)}`]);
        if(!["room","encounter","eventtrial","paused"].includes(mode)||!bag[i]||player.relicBag[i]!==bag[i])return;
        if(action==="first")player.relicBag.unshift(player.relicBag.splice(i,1)[0]);
        if(action==="drop")player.relicBag.splice(i,1);
        if(action==="use"){
          if(!["peach","bottle"].includes(bag[i])||relicUseReason(bag[i],true))return;
          activateRelic(player.relicBag.splice(i,1)[0]);
        }
        refresh();saveRun();
      }));
    }
    button("#bag-craft",()=>{
      if(player.relicFragments<3||player.relicBag.length>=player.relicCapacity)return;
      addRelicFragments(0);refresh();saveRun();
    });
  }
  function relicUseReason(id,peaceful=false){
    if(!id||!relicTypes.some(r=>r.id===id))return "尚未持有法宝";
    if(player.relicSealTime>0&&!peaceful)return `封宝 ${Math.ceil(player.relicSealTime)} 秒`;
    if(id==="lifeledger"&&player.skillCd<=0&&player.dashCd<=0)return "技能与闪避均已就绪";
    if(id==="peach"&&player.peachBlessed&&player.hp>=player.maxHp)return "生命已满";
    if(id==="bottle"&&player.hp>=player.maxHp&&![player.burnTime,player.poisonTime,player.slowTime,player.blindTime].some(n=>n>0))return "生命已满且没有异常状态";
    return "";
  }
  function storeRelic(id){
    const relic=relicTypes.find(r=>r.id===id);if(!relic)return false;
    if(player.relicBag.length>=player.relicCapacity){banner="法宝袋已满，可在暂停或房间选项中整理";bannerTime=2;return false;}
    player.relicBag.push(id);
    if(player.synergies.includes("relic_hunt"))player.hp=Math.min(player.maxHp,player.hp+18);
    banner=`法宝入袋 · ${relic.name}（按 Q 使用）`;bannerTime=2.6;audio.effect("pickup");return true;
  }
  function useRelic(){
    if(mode!=="playing")return;
    const reason=relicUseReason(player.relicBag[0]);
    if(reason){banner=reason;bannerTime=2;return;}
    activateRelic(player.relicBag.shift());saveRun();
  }
  function activateRelic(id){
    const relic=relicTypes.find(r=>r.id===id);if(!relic)return;
    if(!["peach","bottle","lifeledger"].includes(id)){
      player.relic=id;player.relicTime=relic.duration*player.relicDuration;player.relicTick=.1;
    }
    if(id==="peach"){
      if(!player.peachBlessed){player.maxHp+=18;player.peachBlessed=true;}
      player.hp=Math.min(player.maxHp,player.hp+Math.ceil(player.maxHp*.25));
    }
    if(id==="bottle"){
      player.hp=Math.min(player.maxHp,player.hp+Math.ceil(player.maxHp*.28));
      player.burnTime=0;player.poisonTime=0;player.slowTime=0;player.blindTime=0;
    }
    if(id==="lifeledger"){
      const before=player.hp,cost=Math.ceil(before*.12);
      player.hp=Math.max(1,player.hp-cost);
      player.skillCd=0;player.dashCd=0;
      addEffect("ring",player.x,player.y,105,"#b9a6d0",.58);
      effects.push({type:"number",x:player.x,y:player.y-30,vy:-28,text:`阳寿 -${Math.ceil(before-player.hp)}`,color:"#d6b3da",life:.8,maxLife:.8});
    }
    if(id==="fan")effects=effects.filter(effect=>effect.type!=="firezone"||effect.status==="slow");
    if(id==="gourd"){
      const target=nearestEnemy(player.x,player.y,true);
      if(target&&distance(target,player)<340){
        damageEnemy(target,target.boss?Math.min(100,target.maxHp*.05):50,0,true,{noCrit:true,noChain:true,noStatus:true});
        if(!target.dead)target.freeze=Math.max(target.freeze,1.1);
        addEffect("beam",player.x,player.y,0,"#dbaa78",.3,0,{toX:target.x,toY:target.y});
      }
    }
    banner=`祭出法宝 · ${relic.name}`;bannerTime=2.6;
    burst(player.x,player.y,relic.color,18,150);audio.effect("pickup");
  }
  function updatePassives(dt){
    player.regenTick-=dt;
    if(player.regenTick<=0){
      const bonus=player.synergies.includes("mercy_armor")&&player.armor>=.4?1.5:1;
      player.hp=Math.min(player.maxHp,player.hp+player.regen*bonus+(nurtured()?.18:0));
      if(player.relic==="lotus")player.hp=Math.min(player.maxHp,player.hp+2.2);
      player.regenTick=1;
    }
    player.orbitTick-=dt;
    if(player.orbitBlades>0&&player.orbitTick<=0){
      for(const e of enemies)if(!e.dead&&distance(e,player)<(68+player.orbitBlades*12)*player.area+e.radius)
        damageEnemy(e,6+player.orbitBlades*4,18);
      player.orbitTick=.5;
    }
    player.windTick-=dt;
    if(player.windPower>0&&player.windTick<=0){
      const target=nearestEnemy();if(target){
        const base=Math.atan2(target.y-player.y,target.x-player.x);
        for(let i=0;i<player.windPower;i++){const a=base+(i-(player.windPower-1)/2)*.18;shoot(player.x,player.y,Math.cos(a),Math.sin(a),410,18,{radius:7,pierce:2,life:2,color:"#b2dfd1",ignite:player.synergies.includes("firewind")});}
      }
      player.windTick=5;
    }
    player.pulseTick-=dt;
    if(player.pulsePower>0&&player.pulseTick<=0){
      for(const e of enemies)if(!e.dead&&distance(e,player)<(100+player.pulsePower*20)*player.area)damageEnemy(e,15+player.pulsePower*8,70,true);
      addEffect("ring",player.x,player.y,(100+player.pulsePower*20)*player.area,"#f2e4a3",.45);
      player.pulseTick=8;
    }
    if(player.relicTime>0){
      player.relicTime=Math.max(0,player.relicTime-dt);
      player.relicTick-=dt;
      if(player.relicTick<=0){
        if(player.relic==="fan"){
          const target=nearestEnemy();if(target){
            const d=norm(target.x-player.x,target.y-player.y);
            shoot(player.x,player.y,d.x,d.y,445,25,{radius:9,pierce:3,life:2,color:"#a7dbd2"});
          }
          player.relicTick=.48;
        }else if(player.relic==="gourd"){
          for(const e of enemies)if(!e.dead&&distance(e,player)<130)damageEnemy(e,8,0,false,{noStatus:true,noChain:true,noCrit:true});
          addEffect("ring",player.x,player.y,130,"#e5ae80",.28);
          player.relicTick=.65;
        }else if(player.relic==="pagoda"){
          const target=nearestEnemy();
          if(target&&distance(target,player)<170){damageEnemy(target,15,160,true);addEffect("ring",target.x,target.y,55,"#efcf82",.3);}
          player.relicTick=.7;
        }else if(player.relic==="needle"){
          const target=nearestEnemy();
          if(target)shoot(player.x,player.y,target.x-player.x,target.y-player.y,570,18,{radius:3,pierce:1,life:1.8,color:"#f3d2a1",type:"needle"});
          player.relicTick=.35;
        }else player.relicTick=.5;
      }
      if(player.relicTime<=0){player.relic=null;banner="法宝灵力已散";bannerTime=1.6;}
    }
  }
  function update(dt){
    animationTime+=dt;runTime+=dt;stageTime+=dt;saveTimer+=dt;
    bannerTime=Math.max(0,bannerTime-dt);dialogueTime=Math.max(0,dialogueTime-dt);shake=Math.max(0,shake-dt*30);
    player.weaponCd-=dt;player.skillCd=Math.max(0,player.skillCd-dt);
    player.weaponSwing=Math.max(0,player.weaponSwing-dt);
    player.dashCd=Math.max(0,player.dashCd-dt);player.invuln=Math.max(0,player.invuln-dt);
    player.cloneTime=Math.max(0,player.cloneTime-dt);player.shieldTime=Math.max(0,player.shieldTime-dt);
    player.dragonTime=Math.max(0,(player.dragonTime||0)-dt);
    player.relicSealTime=Math.max(0,(player.relicSealTime||0)-dt);
    player.comboDecay=Math.max(0,(player.comboDecay||0)-dt);if(player.comboDecay===0)player.combo=0;
    player.fieldTime=Math.max(0,player.fieldTime-dt);
    player.passiveCd=Math.max(0,(player.passiveCd||0)-dt);player.dashCritTime=Math.max(0,(player.dashCritTime||0)-dt);
    player.blindTime=Math.max(0,(player.blindTime||0)-dt);
    player.burnTime=Math.max(0,(player.burnTime||0)-dt);
    player.poisonTime=Math.max(0,(player.poisonTime||0)-dt);
    player.slowTime=Math.max(0,(player.slowTime||0)-dt);
    player.riskTime=Math.max(0,(player.riskTime||0)-dt);
    player.statusTick=(player.statusTick??.7)-dt;
    if(player.statusTick<=0){
      const damage=(player.burnTime>0?2:0)+(player.poisonTime>0?2:0);
      if(damage){
        player.hp=Math.max(0,player.hp-damage);
        effects.push({type:"number",x:player.x,y:player.y-29,vy:-30,text:`-${damage}`,color:player.poisonTime>0?"#bed181":"#f49b72",life:.6,maxLife:.6});
        if(player.hp<=0){player.lastHit=player.poisonTime>0?`中毒持续伤害 ${damage}`:`灼烧持续伤害 ${damage}`;endRun(false);return;}
      }
      player.statusTick=.7;
    }

    const dx=(keys.has("d")||keys.has("arrowright")?1:0)-(keys.has("a")||keys.has("arrowleft")?1:0)+touch.x;
    const dy=(keys.has("s")||keys.has("arrowdown")?1:0)-(keys.has("w")||keys.has("arrowup")?1:0)+touch.y;
    const move=norm(dx,dy);
    if(dx||dy)player.facing=move;
    if(selectedHero===4)player.momentum=clamp((player.momentum||0)+(dx||dy?dt*.55:-dt*.33),0,1);
    if(player.dashTime>0){
      player.dashTime-=dt;player.x+=player.dashDir.x*690*dt;player.y+=player.dashDir.y*690*dt;
      if(Math.random()<.6)burst(player.x,player.y,heroes[selectedHero].color,1,25);
    }else{const slow=player.slowTime>0?.72:1,ordealMove=player.ordealAccepted?(stages[stageIndex].ordeal.move||1):1,dragonMove=player.dragonTime>0?1.22:1;player.x+=move.x*player.speed*slow*ordealMove*dragonMove*dt*(dx||dy?1:0);player.y+=move.y*player.speed*slow*ordealMove*dragonMove*dt*(dx||dy?1:0);}
    player.x=clamp(player.x,arena.left+player.radius,arena.right-player.radius);
    player.y=clamp(player.y,arena.top+player.radius,arena.bottom-player.radius);
    if(player.gourdMark){
      player.gourdMark.time-=dt;
      if(player.gourdMark.time<=0){
        const dive=player.gourdMark.kind==="dive";
        if(distance(player,player.gourdMark)<(dive?112:106)){
          player.invuln=0;hurtPlayer((dive?38:52)+tier()*2,dive?null:"slow",player.gourdMark.source+(dive?" · 真身俯冲":" · 葫芦摄魂"),dive?"none":"metal","spell");
        }else{banner=dive?"避开大鹏俯冲":"避开葫芦摄魂";bannerTime=1.5;}
        player.gourdMark=null;
      }
    }
    const halfW=(view.right-view.left)/settings.zoom/2,halfH=(view.bottom-view.top)/settings.zoom/2;
    const targetX=clamp(player.x+player.facing.x*32,halfW,worldSize-halfW);
    const targetY=clamp(player.y+player.facing.y*22,halfH,worldSize-halfH);
    camera.x+=(targetX-camera.x)*Math.min(1,dt*5.5);
    camera.y+=(targetY-camera.y)*Math.min(1,dt*5.5);

    // 战斗房必须清剿敌人才能前进，不再按倒计时自动通关。
    if(roomStarted&&(["combat","elite","boss"].includes(roomAt(roomIndex).type)||roomBattle)&&
       !enemies.some(e=>!e.dead&&(e.allyTime||0)<=0)){
      finishRoom();return;
    }
    relicTimer-=dt;
    if(relicTimer<=0&&relicDrops.length<1){
      if(Math.random()<BAL.relic.dropChance+player.fortune*BAL.relic.fortuneBonus)spawnRelic();relicTimer=rand(BAL.relic.nextSpawnMin,BAL.relic.nextSpawnMax)/(1+player.fortune*.12);
    }
    for(const r of relicDrops){
      r.life-=dt;
      if(distance(r,player)<player.radius+20&&storeRelic(r.id))r.life=0;
    }
    relicDrops=relicDrops.filter(r=>r.life>0);

    for(const e of enemies){
      if(e.dead)continue;
      if(e.allyTime>0){
        e.allyTime-=dt;e.allyCd=(e.allyCd||0)-dt;
        if(e.allyTime<=0){e.dead=true;addEffect("ring",e.x,e.y,45,"#ead69a",.28);continue;}
        const target=enemies.filter(other=>other!==e&&!other.dead&&other.allyTime<=0).sort((a,b)=>distance(a,e)-distance(b,e))[0];
        if(target){const v=norm(target.x-e.x,target.y-e.y);if(distance(e,target)>e.radius+target.radius+5){e.x+=v.x*e.speed*dt;e.y+=v.y*e.speed*dt;}
          if(e.allyCd<=0&&distance(e,target)<e.radius+target.radius+16){damageEnemy(target,Math.max(10,e.damage*1.5),55,true);e.allyCd=1.1;addEffect("slash",e.x,e.y,38,"#f2dc9d",.2,Math.atan2(v.y,v.x));}}
        continue;
      }
      e.hitFlash=Math.max(0,(e.hitFlash||0)-dt);
      e.contactCd=Math.max(0,(e.contactCd||0)-dt);
      e.slow=Math.max(0,(e.slow||0)-dt);e.brokenTime=Math.max(0,(e.brokenTime||0)-dt);
      e.freeze=Math.max(0,(e.freeze||0)-dt);
      e.burn=Math.max(0,(e.burn||0)-dt);
      e.poison=Math.max(0,(e.poison||0)-dt);
      e.dotTick=(e.dotTick??.5)-dt;
      if(e.dotTick<=0){
        if(e.burn>0)damageEnemy(e,5,0,false,{noStatus:true,noChain:true,noCrit:true});
        if(!e.dead&&e.poison>0)damageEnemy(e,4,0,false,{noStatus:true,noChain:true,noCrit:true});
        e.dotTick=.5;
      }
      if(e.dead)continue;
      const v=norm(player.x-e.x,player.y-e.y),d=distance(e,player);
      const speed=e.speed*(e.freeze>0?.08:e.slow>0?.45:1);
      if(d>e.radius+player.radius-2){e.x+=v.x*speed*dt;e.y+=v.y*speed*dt;}
      e.x+=(e.knockX||0)*dt;e.y+=(e.knockY||0)*dt;
      e.knockX*=Math.max(0,1-dt*7);e.knockY*=Math.max(0,1-dt*7);
      e.x=clamp(e.x,arena.left+e.radius,arena.right-e.radius);
      e.y=clamp(e.y,arena.top+e.radius,arena.bottom-e.radius);
      if(d<e.radius+player.radius&&e.contactCd<=0){
        const ch=e.ch||stages[stageIndex].ch;
        const status=e.boss?(ch===40||ch===70?"burn":ch===55||ch===72?"poison":null):null;
        hurtPlayer(e.damage,status,e.name,e.element,"touch");e.contactCd=.85;
        if(player.shieldTime>0||player.thorns>0)damageEnemy(e,17+player.thorns,90);
      }
      if(e.boss){
        if(e.windup>0){e.windup-=dt;if(e.windup<=0)bossAttack(e);}
        else{e.attackCd-=dt;if(e.attackCd<=0){
          e.windup=.75;
          const lines=e.attack||stages[stageIndex].attack||["妖风骤起！"];
          sayBoss(lines[e.patternCount%lines.length],2.4);
          audio.effect("boss");
        }}
      }else if(["fireling","fishling","windling","spiderlet","shade","stone"].includes(e.type)){
        e.attackCd-=dt;
        if(e.attackCd<=0){
          if(e.type==="shade"){
            if(enemies.filter(m=>!m.dead&&!m.boss).length<18){
              const summon=stages[stageIndex].mobs.filter(type=>type!=="shade");
              spawnMob(choose(summon.length?summon:["jackal"]));
              addEffect("ring",e.x,e.y,60,"#b3a7cd",.45);
            }
            e.attackCd=rand(6,8);
          }else if(e.type==="stone"){
            if(d<110){addEffect("ring",e.x,e.y,110,"#c5baa0",.45);hurtPlayer(7+Math.floor(tier()*.3),"slow",e.name,e.element,"spell");}
            e.attackCd=rand(3.4,4.5);
          }else if(e.type==="windling"){
            const a=Math.atan2(player.y-e.y,player.x-e.x);
            for(const spread of [-.26,0,.26])shoot(e.x,e.y,Math.cos(a+spread),Math.sin(a+spread),158,7+Math.floor(tier()*.4),{friendly:false,radius:5,life:2.3,color:"#dcd09a",status:"slow",source:e.name,element:e.element});
            e.attackCd=rand(3.1,4);
          }else{
            const venom=e.type==="spiderlet",fire=e.type==="fireling";
            shoot(e.x,e.y,player.x-e.x,player.y-e.y,venom?135:165+tier()*2,8+Math.floor(tier()*.6),
              {friendly:false,radius:venom?8:6,life:2.6,color:venom?"#c9a4d3":fire?"#ed8b58":"#8dc9d5",status:venom?"poison":fire?"burn":"slow",source:e.name,element:e.element});
            e.attackCd=rand(venom?3.4:2.3,venom?4.4:3.1);
          }
        }
      }
    }
    if(mode!=="playing")return;
    if(player.weaponCd<=0)attack();
    if(mode!=="playing")return;
    if(player.cloneTime>0){
      player.cloneCd-=dt;
      if(player.cloneCd<=0){
        const target=nearestEnemy();if(target)for(const side of [-1,1]){
          const pos={x:player.x+side*30,y:player.y+14};
          shoot(pos.x,pos.y,target.x-pos.x,target.y-pos.y,360,11*(1+(player.skillRank||0)*.08),{radius:5,life:1.8,color:"#e8bb78"});
        }
        player.cloneCd=.57;
      }
    }
    if(player.fieldTime>0){
      player.fieldTick-=dt;
      if(player.fieldTick<=0){
        for(const e of enemies)if(!e.dead&&distance(e,player)<145*player.area+e.radius){e.slow=.7;damageEnemy(e,7,0);}
        player.fieldTick=.48;
      }
    }
    updatePassives(dt);
    if(mode!=="playing")return;
    for(const p of projectiles){
      if(p.life<=0)continue;
      if(p.homing&&p.friendly){
        const target=nearestEnemy(p.x,p.y);
        if(target){const v=norm(target.x-p.x,target.y-p.y);p.vx=p.vx*.91+v.x*300*.09;p.vy=p.vy*.91+v.y*300*.09;}
      }
      const slowBullet=!p.friendly&&player.relic==="pearl"?.55:1;
      p.x+=p.vx*dt*slowBullet;p.y+=p.vy*dt*slowBullet;p.life-=dt;
      if(p.x<arena.left-15||p.x>arena.right+15||p.y<arena.top-15||p.y>arena.bottom+15)p.life=0;
      if(p.friendly){
        for(const e of enemies){
          if(e.dead||e.allyTime>0||p.hit.has(e)||p.life<=0)continue;
          if(distance(p,e)<p.radius+e.radius){
            damageEnemy(e,p.damage,p.type==="spear"?40:16,false,{extraFreeze:p.extraFreeze});
            if(p.ignite)e.burn=Math.max(e.burn,4);
            if(p.slow)e.slow=Math.max(e.slow,1.8);
            p.hit.add(e);if(p.pierce>0)p.pierce--;else p.life=0;
          }
        }
      }else if(distance(p,player)<p.radius+player.radius){hurtPlayer(p.damage,p.status,p.source,p.element,"projectile");p.life=0;}
    }
    projectiles=projectiles.filter(p=>p.life>0);
    enemies=enemies.filter(e=>!e.dead);
    for(const o of orbs){
      o.life-=dt;
      const d=distance(o,player),range=player.magnet+(player.relic==="gourd"?170:0);
      if(d<range){const v=norm(player.x-o.x,player.y-o.y),s=275+(range-d)*1.8;o.x+=v.x*s*dt;o.y+=v.y*s*dt;}
      if(d<player.radius+10){xp+=o.value;o.life=0;if(Math.random()<.25)audio.effect("pickup");}
    }
    orbs=orbs.filter(o=>o.life>0);
    while(xp>=xpGoal){xp-=xpGoal;level++;xpGoal=Math.round(xpGoal*BAL.experience.growth+BAL.experience.flat);queueUpgrade("level");}
    for(const p of particles){p.x+=p.vx*dt;p.y+=p.vy*dt;p.vx*=Math.max(0,1-dt*3);p.vy*=Math.max(0,1-dt*3);p.life-=dt;}
    particles=particles.filter(p=>p.life>0);
    for(const e of effects){
      e.life-=dt;if(e.type==="number")e.y+=e.vy*dt;
      if(e.type==="firezone"){
        e.tick-=dt;if(e.tick<=0){e.tick=.7;if(distance(e,player)<e.radius+player.radius)hurtPlayer(e.status==="slow"?5:8,e.status||"burn",(enemies.find(m=>m.boss&&!m.dead)?.name||"妖王")+" · 地面法术",stages[stageIndex].element,"spell");}
      }
    }
    effects=effects.filter(e=>e.life>0);
    if(saveTimer>=5){saveTimer=0;saveRun();}
  }

  function rect(x,y,w,h,color){ctx.fillStyle=color;ctx.fillRect(Math.round(x),Math.round(y),Math.round(w),Math.round(h));}
  function textDraw(str,x,y,size=16,color="#f4e7c8",align="left",weight="700"){
    ctx.fillStyle=color;ctx.font=`${weight} ${size}px "Microsoft YaHei",system-ui,sans-serif`;
    ctx.textAlign=align;ctx.textBaseline="middle";ctx.fillText(str,Math.round(x),Math.round(y));
  }

  const heroPixels = {
    wukong: [
      ".....gggggg.....","...gggyygggg....","..gggrrrrgggg...","..bbrrrrrrbb....",
      "..bbttttttbb....","..bttkttkttb....","..bttttttttb....","...bttnnttb.....",
      "..rrggggggrr....",".rrryyyyyyrrr...",".rrryygyyyrrr...","..rryyyyyyrr....",
      "...rrggggrr.....","...rr...rr......","..bbb...bbb.....","..bbb...bbb....."
    ].map(r=>r.padEnd(16,".")),
    tangseng: [
      "......hhhh......",".....hhhhhh.....","....hhtttthh....","....htttttth....",
      "....htkttkth....","....htttttth....",".....htnnth.....","...rrrrrrrrrr...",
      "..rrrwwwwrrrr...","..rrwwgwwwrrr...","..rrwwwwwwrrr...","..rrwwwwwwrrr...",
      "...rwwwwwwr.....","....ww..ww......","....bb..bb......","....bb..bb......"
    ].map(r=>r.padEnd(16,".")),
    bajie: [
      "..pp........pp..","..ppp......ppp..","...pppppppppp...","..ppttttttttpp..",
      "..pttkttktttp...","..ptttnnntttp...","...pttnnnttp....","...ptttttttp....",
      "..bbggggggbb....",".bbbggyyggbbb...",".bbbggyyggbbb...","..bbggggggbb....",
      "...bggggggb.....","...gg....gg.....","..bbb....bbb....","..bbb....bbb...."
    ].map(r=>r.padEnd(16,".")),
    shaseng: [
      "....dddddddd....","...dddddddddd...","..dddttttttddd..","..ddttttttttdd..",
      "..dttkttkttttd..","..dttttttttttd..","...dttnnnttd....","...dddrrrddd....",
      "..ccbbbbbbbbcc..",".cccbbrrbbcccc..",".cccbbbbbbcccc..","..ccbbbbbbbbcc..",
      "...cbbbbbbc.....","...bb....bb.....","..bbb....bbb....","..bbb....bbb...."
    ].map(r=>r.padEnd(16,".")),
    bailongma: [
      ".....hhhhhh.....","...hhwwwwhh.....","..hwwwwwwwwh....","..hwwwwwwwwhh...",
      "..hwkkkkkkwhh...","..hwwnwwnwwhh...","...hwwwwwwhh....","..ccchhhhcccc...",
      "..cccbbbbcccc...","...ccbbbbcc.....","...ccbbbbcc.....","..ccbbbbbbcc....",
      "..ccbb..bbcc....","...bb....bb.....","..hhh....hhh....","..hhh....hhh...."
    ].map(r=>r.padEnd(16,"."))
  };
  const heroPalette = {
    wukong:{g:"#e2ae52",r:"#b84d42",b:"#473634",t:"#c9926c",k:"#332b2b",y:"#f0ce7a",n:"#8a5a48"},
    tangseng:{h:"#e1c48d",t:"#f0d3a3",k:"#3d3635",r:"#a84748",w:"#f2e8cf",g:"#d9bf79",n:"#b98c6f",b:"#705451"},
    bajie:{p:"#dc9a95",t:"#f0baaa",k:"#383137",n:"#ad7075",b:"#5b615e",g:"#6e9078",y:"#d6b077"},
    shaseng:{d:"#343a43",t:"#aa806e",k:"#e9e0cd",r:"#bf6855",b:"#587e96",c:"#92bdc1",n:"#684e4c"},
    bailongma:{h:"#b7e0e6",w:"#f0f4ea",k:"#406475",n:"#7ebdcc",c:"#77a8c3",b:"#dce9e4"}
  };
  function pixelSprite(context, rows, palette, x, y, scale=3){
    const width=rows[0].length;
    for(let yy=0;yy<rows.length;yy++)for(let xx=0;xx<width;xx++){
      const c=palette[rows[yy][xx]];if(!c)continue;
      context.fillStyle=c;context.fillRect(Math.round(x+xx*scale),Math.round(y+yy*scale),Math.ceil(scale),Math.ceil(scale));
    }
  }
  function drawPortraits(){
    screen.querySelectorAll("[data-portrait]").forEach(el=>{
      const h=heroes[Number(el.dataset.portrait)], c=el.getContext("2d");
      c.imageSmoothingEnabled=false;c.clearRect(0,0,32,32);
      c.fillStyle="#263b3b";c.fillRect(0,0,32,32);
      pixelSprite(c,heroPixels[h.id],heroPalette[h.id],0,0,2);
    });
  }

  function drawArena() {
    const stage=stages[stageIndex],biome=stage.biome;
    rect(0,0,worldSize,worldSize,"#17252b");
    rect(arena.left,arena.top,arena.right-arena.left,arena.bottom-arena.top,stage.tint);
    const hash=(i,j)=>((i*928371+j*12377+stageIndex*7919)>>>0)%997;
    const pathColor=biome==="river"?"#a0cad028":biome==="ember"?"#d7826025":"#d3c39a20";
    const vertical=stageIndex%3===1;
    for(let a=0;a<worldSize;a+=32){
      const bend=Math.sin(a/145+stageIndex*.7)*75;
      if(vertical)rect(worldSize/2+bend-37,a,74,34,pathColor);
      else rect(a,worldSize/2+bend-37,34,74,pathColor);
    }
    for(let j=0;j<20;j++)for(let i=0;i<20;i++){
      const x=i*64+10,y=j*64+9,h=hash(i,j);
      if(h%3===0){rect(x+(h%23),y+(h%31),4,4,"#ffffff10");rect(x+(h%23)+4,y+(h%31)+4,3,3,"#101b2018");}
      if(h%5!==0)continue;
      if(["forest","wild"].includes(biome)){
        rect(x+10,y+34,8,16,"#394632");rect(x+2,y+12,25,26,"#1f4a3f");rect(x+7,y+7,18,13,biome==="wild"?"#59724f":"#4d7660");
        rect(x+5,y+16,5,5,"#a4bf7c55");
      }else if(biome==="desert"){
        rect(x+3,y+36,34,5,"#ab916353");rect(x+18,y+24,4,15,"#c5a16e");rect(x+15,y+19,10,5,"#ddbb7a");
      }else if(biome==="grave"||biome==="night"){
        rect(x+8,y+18,19,29,"#7e879055");rect(x+11,y+16,13,7,"#adb3ad55");rect(x+5,y+43,25,3,"#1d283057");
      }else if(biome==="cave"){
        rect(x+8,y+25,28,17,"#a4a99b33");rect(x+12,y+21,16,4,"#ced1b045");
      }else if(biome==="ember"){
        rect(x+6,y+37,32,4,"#f28d5555");rect(x+19,y+28,5,8,"#e7aa6055");rect(x+25,y+22,4,10,"#e9785244");
      }else if(biome==="river"){
        rect(x+2,y+28,39,3,"#b0e4e343");rect(x+10,y+39,24,3,"#b0e4e333");rect(x+38,y+20,3,20,"#9cbf9255");
      }else if(biome==="city"||biome==="temple"){
        rect(x+2,y+8,43,30,"#d4c8a71a");rect(x+6,y+12,35,2,"#ead8a522");rect(x+6,y+32,35,2,"#ead8a522");
      }else if(biome==="web"){
        rect(x+7,y+7,2,38,"#d2bfdb3a");rect(x+7,y+7,35,2,"#d2bfdb3a");rect(x+20,y+21,20,2,"#d2bfdb2c");
      }else if(biome==="moon"){
        rect(x+13,y+23,12,20,"#b4cee753");rect(x+16,y+15,6,10,"#d1e3f060");rect(x+8,y+43,24,3,"#d1e3f030");
      }
    }
    // 四角各有一组与回目对应的地貌地标；始终在地面层，不阻挡战斗。
    const landmarks={
      13:["虎穴","#876b50"],16:["禅院","#8b9c78"],20:["风沙","#b99d68"],27:["白骨","#c2c0b6"],28:["月洞","#8e8aae"],
      32:["莲花洞","#b69b6b"],40:["火云洞","#c86549"],44:["法坛","#b99970"],47:["冰河","#8ec5d2"],50:["金兜洞","#8ba9a7"],
      55:["琵琶洞","#a78caa"],59:["火焰山","#c67751"],65:["雷音殿","#bdac80"],70:["麒麟山","#b99670"],72:["黄花观","#a296bd"],
      74:["狮驼岭","#a995b4"],78:["宫城","#a8b985"],89:["豹头山","#cba270"],90:["竹节山","#d1b782"],95:["月宫","#cdbbd9"]
    };
    const [label,stone]=landmarks[stage.ch]||[stage.place,"#8d8e75"];
    for(const [lx,ly] of [[460,490],[820,490],[460,790],[820,790]]){
      rect(lx-70,ly+33,140,13,"#12232b77");
      if(["虎穴","白骨","莲花洞","火云洞","金兜洞","琵琶洞","火焰山","狮驼岭","豹头山","竹节山"].includes(label)){
        rect(lx-76,ly+13,152,28,stone);rect(lx-55,ly-20,110,40,"#26353c");rect(lx-32,ly-47,64,27,stone);
        rect(lx-22,ly+1,44,37,"#17252b");rect(lx-13,ly+1,26,27,"#101c24");
        for(let k=-2;k<=2;k++)rect(lx+k*27-4,ly-23,8,9,"#f5e6bb55");
      }else if(["禅院","法坛","雷音殿","黄花观","宫城"].includes(label)){
        rect(lx-70,ly-14,140,55,stone);rect(lx-82,ly-24,164,12,"#503d37");rect(lx-54,ly-51,108,24,"#6f5344");rect(lx-14,ly-7,28,48,"#34424a");
        for(let k of [-45,45])rect(lx+k-7,ly-5,14,20,"#f0d69a99");
      }else if(label==="冰河"){
        for(let k=0;k<5;k++)rect(lx-71+k*31,ly-30+(k%2)*14,27,17,"#b8e5e799");
        rect(lx-84,ly+13,168,18,"#5e9fb1");rect(lx-64,ly+18,128,4,"#d0f0e2");
      }else if(label==="风沙"){
        for(let k=0;k<4;k++)rect(lx-76+k*41,ly-18+(k%2)*8,43,45,"#d2af73");
        rect(lx-69,ly+1,138,5,"#f2d69977");
      }else if(label==="月宫"){
        rect(lx-57,ly-20,114,62,"#b7add0");rect(lx-64,ly-33,128,12,"#e3d4e5");rect(lx-18,ly-51,36,19,"#f3e6de");
        rect(lx-11,ly-7,22,44,"#4c5269");
      }else{
        rect(lx-68,ly-13,136,54,stone);rect(lx-29,ly-42,58,30,"#435565");rect(lx-8,ly-60,16,20,"#e8dbb2");
      }
      rect(lx-37,ly+49,74,3,"#ead6ae55");
    }
    // 边界始终封闭；镜头靠近边缘时可看见完整的砖石围墙。
    rect(0,0,worldSize,arena.top,"#27333a");
    rect(0,arena.bottom,worldSize,worldSize-arena.bottom,"#27333a");
    rect(0,arena.top,arena.left,arena.bottom-arena.top,"#27333a");
    rect(arena.right,arena.top,worldSize-arena.right,arena.bottom-arena.top,"#27333a");
    for(let p=0;p<worldSize;p+=48){
      rect(p,arena.top-7,29,7,"#c9ac78");rect(p,arena.bottom,29,7,"#af9067");
      rect(arena.left-7,p,7,29,"#c9ac78");rect(arena.right,p,7,29,"#af9067");
    }
    rect(arena.left,arena.top,arena.right-arena.left,5,"#e2c185");
    rect(arena.left,arena.bottom-5,arena.right-arena.left,5,"#b39465");
    rect(arena.left,arena.top,5,arena.bottom-arena.top,"#dbbc82");
    rect(arena.right-5,arena.top,5,arena.bottom-arena.top,"#af9067");
    const roomType=roomAt(roomIndex).type;
    if(roomType==="reward"){
      for(const [x,y] of [[390,390],[890,390],[390,890],[890,890]]){rect(x-25,y-14,50,38,"#9b794844");rect(x-29,y-17,58,9,"#efc87966");rect(x-4,y-8,8,18,"#e8d39a99");}
    }else if(roomType==="rest"){
      for(const [x,y] of [[370,360],[910,360],[370,920],[910,920]]){rect(x-40,y-10,80,24,"#8ad4c655");rect(x-28,y-19,56,9,"#c2e0cc44");}
    }else if(roomType==="shop"){
      for(const [x,y] of [[380,370],[900,370],[380,910],[900,910]]){rect(x-34,y-25,68,12,"#d6a77677");rect(x-31,y-13,6,37,"#c2b48d88");rect(x+25,y-13,6,37,"#c2b48d88");rect(x-29,y+19,58,7,"#bd926777");}
    }else if(roomType==="event"){
      for(const [x,y] of [[370,370],[910,370],[370,910],[910,910]]){rect(x-13,y-31,26,62,"#9a9fc766");rect(x-18,y+24,36,10,"#d6c68e77");}
    }else if(roomType==="boss"){
      for(const [x,y] of [[340,340],[940,340],[340,940],[940,940]]){rect(x-24,y-24,48,48,"#e5826555");rect(x-13,y-13,26,26,"#573e4c88");}
    }
    rect(worldSize/2-18,worldSize/2-18,36,36,"#e8d9b017");
    rect(worldSize/2-11,worldSize/2-11,22,22,"#e8d9b014");
  }

  function drawCachedArena(){
    if(!terrainCanvas){
      terrainCanvas=document.createElement("canvas");
      terrainCanvas.width=worldSize;terrainCanvas.height=worldSize;
    }
    if(terrainStage!==`${stageIndex}:${roomIndex}`){
      const visibleContext=ctx;
      try{
        ctx=terrainCanvas.getContext("2d");
        ctx.imageSmoothingEnabled=false;
        drawArena();
        terrainStage=`${stageIndex}:${roomIndex}`;
      }finally{ctx=visibleContext;}
    }
    ctx.drawImage(terrainCanvas,0,0);
  }

  function drawHero(x,y,id,scale=3) {
    rect(x-24,y+21,48,8,"#0b171a66");
    if(player && player.invuln>0 && Math.floor(animationTime*14)%2===0)return;
    const rows=heroPixels[id], palette=heroPalette[id];
    const bob=mode==="playing"&&Math.floor(animationTime*7)%2?1:0;
    pixelSprite(ctx,rows,palette,x-rows[0].length*scale/2,y-rows.length*scale/2+bob,scale);
    const wx=x+rows[0].length*scale/2+2,wy=y-rows.length*scale/2;
    ctx.save();
    const swing=player?.weaponSwing>0?Math.sin((1-player.weaponSwing/.24)*Math.PI)*.8:Math.sin(animationTime*3)*.06;
    ctx.translate(wx,wy+rows.length*scale*.55);ctx.rotate(swing);ctx.translate(-wx,-wy-rows.length*scale*.55);
    if(id==="wukong"){
      rect(wx,wy+1,4,rows.length*scale-1,"#70452e");
      rect(wx-1,wy,6,7,"#f1cc72");rect(wx-1,wy+rows.length*scale-7,6,7,"#f1cc72");
      rect(wx+1,wy+9,2,rows.length*scale-19,"#e6ad5e");
    }else if(id==="tangseng"){
      rect(wx,wy,3,rows.length*scale+1,"#b99a69");rect(wx-6,wy+2,15,4,"#e9d7a2");
      for(let i=0;i<3;i++)rect(wx-5+i*5,wy-3,3,5,"#f5e8ba");
    }else if(id==="bajie"){
      rect(wx,wy+5,4,rows.length*scale-3,"#6e5548");
      for(let i=0;i<5;i++)rect(wx-9+i*5,wy,3,14,"#ccd0b6");
      rect(wx-10,wy+11,25,4,"#ccd0b6");
    }else if(id==="shaseng"){
      rect(wx,wy,4,rows.length*scale+1,"#c4ad7e");
      rect(wx-6,wy+2,16,9,"#8cd4d5");rect(wx-2,wy+rows.length*scale-7,8,7,"#8cd4d5");
      rect(wx-2,wy+5,8,3,"#e4f5df");
    }else{
      rect(wx,wy+3,4,rows.length*scale-2,"#8fc9d6");rect(wx-5,wy-2,14,8,"#e7f4ec");
      rect(wx+1,wy+11,3,rows.length*scale-18,"#d8eced");
    }
    ctx.restore();
    if(player?.heroTalent>0){
      const aura={wukong:"#eec778",tangseng:"#fff0b6",bajie:"#e8a481",shaseng:"#90d4e1",bailongma:"#b1e7ed"}[id];
      ctx.strokeStyle=aura;ctx.globalAlpha=.28+Math.sin(animationTime*5)*.12;ctx.lineWidth=2;ctx.beginPath();ctx.arc(x,y,24+player.heroTalent*3,0,TWO_PI);ctx.stroke();ctx.globalAlpha=1;
    }
    if(id==="bailongma"&&player?.dragonTime>0){
      ctx.strokeStyle="#9de8ec";ctx.globalAlpha=.55+Math.sin(animationTime*10)*.18;ctx.lineWidth=4;
      ctx.beginPath();ctx.arc(x,y,30+Math.sin(animationTime*8)*3,0,TWO_PI);ctx.stroke();ctx.globalAlpha=1;
    }
    if(player && player.shieldTime>0){
      ctx.strokeStyle="#e8b69d";ctx.lineWidth=3;ctx.setLineDash([7,5]);ctx.beginPath();ctx.arc(x,y,27+Math.sin(animationTime*5)*2,0,TWO_PI);ctx.stroke();ctx.setLineDash([]);
    }
    if(player && player.fieldTime>0){
      ctx.strokeStyle="#8bd0da88";ctx.lineWidth=3;ctx.beginPath();ctx.arc(x,y,141*player.area,0,TWO_PI);ctx.stroke();
    }
  }

  function drawMob(e) {
    const x=Math.round(e.x),y=Math.round(e.y);
    rect(x-e.radius*.75,y+e.radius*.55,e.radius*1.5,7,"#0b151955");
    if(e.elite){
      ctx.strokeStyle="#f5d188";ctx.lineWidth=3;ctx.beginPath();ctx.arc(x,y,e.radius+8,0,TWO_PI);ctx.stroke();
      rect(x-7,y-e.radius-20,14,7,"#d7a968");rect(x-3,y-e.radius-25,6,6,"#f7d99a");
    }
    if(e.allyTime>0){ctx.strokeStyle="#f1dc93";ctx.lineWidth=3;ctx.beginPath();ctx.arc(x,y,e.radius+5,0,TWO_PI);ctx.stroke();}
    const c=e.hitFlash>0?"#fff6df":e.color;
    if(e.type==="bee"){
      rect(x-17,y-9,13,9,"#e6e2be");rect(x+4,y-9,13,9,"#e6e2be");rect(x-12,y-13,24,25,c);
      for(let i=0;i<3;i++)rect(x-10+i*8,y-10,4,21,"#3f3c32");rect(x-3,y+11,6,9,"#84623d");
      rect(x-14,y-17,6,5,"#4b4034");rect(x+8,y-17,6,5,"#4b4034");
    }else if(e.type==="disguised"){
      rect(x-9,y-22,18,14,"#d9c8ac");rect(x-14,y-7,28,28,"#b5a7a0");
      rect(x-12,y+5,24,10,"#d7d0c6");rect(x-6,y-15,4,4,"#793e4e");rect(x+3,y-15,4,4,"#793e4e");
      rect(x-2,y+6,4,12,"#eee9dd");
    }else if(e.type==="lotusling"){
      rect(x-14,y-23,28,11,"#c9aa67");rect(x-8,y-28,16,7,"#e7cc8a");
      rect(x-14,y-12,28,32,c);rect(x-9,y-5,5,5,"#3e3630");rect(x+4,y-5,5,5,"#3e3630");
      rect(x+13,y-1,5,25,"#7e624a");rect(x+8,y-8,15,7,"#e5c888");
    }else if(["jackal","wolf","windling"].includes(e.type)){
      rect(x-15,y-18,9,12,c);rect(x+6,y-18,9,12,c);
      rect(x-15,y-8,30,27,c);rect(x-10,y+9,20,12,"#695e55");
      rect(x-8,y-3,5,5,"#f0ddab");rect(x+3,y-3,5,5,"#f0ddab");
      rect(x-3,y+6,6,5,"#2f3435");rect(x+14,y+4,9,4,c);
      if(e.type==="windling"){rect(x-5,y-22,10,4,"#edd8a0");rect(x-19,y+9,8,3,"#edd8a0");}
    }else if(["tiger","leopard","lionlet"].includes(e.type)){
      rect(x-16,y-16,10,11,c);rect(x+6,y-16,10,11,c);
      rect(x-17,y-8,34,28,c);rect(x-13,y+7,26,13,"#e4c797");
      rect(x-10,y-3,6,5,"#463a32");rect(x+4,y-3,6,5,"#463a32");
      rect(x-3,y+8,6,4,"#644a3c");
      if(e.type==="tiger"){for(let i=-1;i<=1;i++)rect(x-2+i*6,y-13,3,9,"#634b3d");}
      if(e.type==="leopard"){for(const p of [[-10,-8],[9,-9],[-14,4],[12,5]])rect(x+p[0],y+p[1],4,4,"#7a6449");}
      if(e.type==="lionlet"){rect(x-20,y-13,5,25,"#b17b54");rect(x+15,y-13,5,25,"#b17b54");}
      rect(x+15,y+10,11,4,c);
    }else if(["bearling","bulllet"].includes(e.type)){
      if(e.type==="bulllet"){rect(x-20,y-24,7,16,"#e6d3a5");rect(x+13,y-24,7,16,"#e6d3a5");}
      else{rect(x-19,y-20,10,13,c);rect(x+9,y-20,10,13,c);}
      rect(x-20,y-10,40,31,c);rect(x-13,y+8,26,13,"#bd9c82");
      rect(x-11,y-3,6,5,"#f0d4a1");rect(x+5,y-3,6,5,"#f0d4a1");
      rect(x-3,y+8,6,5,"#473a38");
    }else if(e.type==="spiderlet"||e.type==="scorpionlet"){
      for(let i=-2;i<=2;i++){rect(x-24,y+i*6,11,3,c);rect(x+13,y+i*6,11,3,c);}
      rect(x-15,y-11,30,24,c);rect(x-8,y-5,6,5,"#f1c4a8");rect(x+2,y-5,6,5,"#f1c4a8");
      rect(x-4,y+5,8,4,"#4b3649");
      if(e.type==="scorpionlet"){rect(x+13,y-20,6,15,"#8b637a");rect(x+16,y-25,9,6,"#e5b4a8");}
    }else if(e.type==="fishling"){
      rect(x-21,y-11,12,9,c);rect(x-17,y+1,10,11,c);
      rect(x-13,y-13,28,27,c);rect(x+5,y-5,7,6,"#e7e8cd");
      rect(x-4,y+2,9,5,"#568e9a");rect(x-6,y-20,11,8,"#9bd8d2");
    }else if(e.type==="rabbitlet"){
      rect(x-14,y-28,7,21,c);rect(x+7,y-28,7,21,c);
      rect(x-12,y-10,24,28,c);rect(x-8,y-3,5,5,"#af6f86");rect(x+3,y-3,5,5,"#af6f86");
      rect(x-2,y+8,4,4,"#9d6574");
    }else if(e.type==="deerlet"){
      rect(x-19,y-23,5,17,"#d9ce9b");rect(x+14,y-23,5,17,"#d9ce9b");
      rect(x-15,y-11,30,28,c);rect(x-9,y-3,5,5,"#f2e8c7");rect(x+4,y-3,5,5,"#f2e8c7");
      rect(x-3,y+9,6,4,"#816b59");
    }else if(e.type==="bonelet"){
      rect(x-12,y-18,24,24,c);rect(x-8,y-7,6,7,"#343945");rect(x+2,y-7,6,7,"#343945");
      rect(x-3,y+3,6,4,"#7d7380");rect(x-15,y+7,30,13,"#9b9b9c");
      for(let i=0;i<4;i++)rect(x-10+i*6,y+13,3,6,"#e5dfcb");
    }else if(e.type==="bat"){
      rect(x-18,y-4,13,7,c);rect(x+5,y-4,13,7,c);
      rect(x-10,y-10,20,18,"#6d5d78");rect(x-5,y-5,4,4,"#f0d6a1");rect(x+3,y-5,4,4,"#f0d6a1");
      rect(x-15,y-11,8,4,c);rect(x+7,y-11,8,4,c);
    } else if(e.type==="stone"){
      rect(x-14,y-13,28,29,"#4c5d61");rect(x-10,y-17,20,8,c);
      rect(x-9,y-5,6,4,"#ebae73");rect(x+3,y-5,6,4,"#ebae73");
      rect(x-18,y+2,7,13,c);rect(x+11,y+2,7,13,c);
    } else if(e.type==="fireling"){
      rect(x-10,y-9,20,22,c);rect(x-7,y-17,6,9,"#f1be75");rect(x+2,y-22,6,13,"#ef9b54");
      rect(x-5,y-3,4,4,"#442e2c");rect(x+3,y-3,4,4,"#442e2c");
      rect(x-7,y+13,5,6,"#a4503e");rect(x+3,y+13,5,6,"#a4503e");
    } else if(e.type==="guard"||e.type==="shade"){
      rect(x-13,y-19,26,24,c);rect(x-16,y+5,32,19,e.type==="shade"?"#636779":"#6f795e");
      rect(x-8,y-8,5,5,"#ecdcae");rect(x+3,y-8,5,5,"#ecdcae");
      rect(x+17,y-13,4,34,"#c8ad7d");rect(x+14,y-15,10,4,"#c8ad7d");
    } else {
      rect(x-12,y-10,24,26,c);rect(x-8,y-16,16,8,e.type==="wolf"?"#806850":"#63795f");
      rect(x-14,y-16,6,9,c);rect(x+8,y-16,6,9,c);
      rect(x-7,y-4,5,4,"#e8d6a5");rect(x+3,y-4,5,4,"#e8d6a5");
      rect(x-8,y+16,6,4,"#4b5147");rect(x+2,y+16,6,4,"#4b5147");
    }
    if(e.hp<e.maxHp) {
      rect(x-15,y-e.radius-10,30,4,"#161d22");
      rect(x-15,y-e.radius-10,30*e.hp/e.maxHp,4,"#d17c67");
    }
    if(e.burn>0)rect(x-3,y-e.radius-17,6,5,"#f48b57");
    if(e.freeze>0)rect(x+5,y-e.radius-17,6,5,"#a6dbe7");
    if(e.poison>0)rect(x-11,y-e.radius-17,6,5,"#b7c977");
  }

  function drawBoss(e) {
    const x=Math.round(e.x),y=Math.round(e.y),c=e.hitFlash>0?"#fff5db":e.color;
    const stage=e;
    rect(x-31,y+25,62,11,"#0c141855");
    if(e.type==="tiger"){
      rect(x-30,y-32,15,20,c);rect(x+15,y-32,15,20,c);
      rect(x-29,y-14,58,47,c);rect(x-22,y-25,44,34,"#e9b478");
      for(let i=-2;i<=2;i++)rect(x+i*8-2,y-26,4,13,"#6e5147");
      rect(x-15,y-8,9,7,"#483b37");rect(x+6,y-8,9,7,"#483b37");
      rect(x-10,y+8,20,11,"#f1d2a0");rect(x-3,y+7,6,5,"#5c423a");
      if(e.legacyBossIndex===7){rect(x-28,y+15,56,19,"#a34e43");rect(x-21,y-30,42,5,"#e4d392");}
    } else if(e.type==="robe"){
      rect(x-24,y-31,48,35,"#4c4d79");rect(x-19,y-24,38,28,c);
      rect(x-28,y+1,56,34,"#67527b");rect(x-16,y+5,32,16,"#d2bcb0");
      rect(x-11,y-9,8,5,"#f0deb0");rect(x+3,y-9,8,5,"#f0deb0");
      rect(x-4,y+7,8,4,"#684e59");rect(x-33,y-9,8,31,"#a9a5ca");rect(x+25,y-9,8,31,"#a9a5ca");
    } else if(e.type==="horn"){
      rect(x-32,y-35,13,27,"#e9d398");rect(x+19,y-35,13,27,"#e9d398");
      rect(x-28,y-17,56,51,"#8f715a");rect(x-20,y-27,40,36,c);
      rect(x-15,y-11,10,7,"#49392e");rect(x+5,y-11,10,7,"#49392e");
      rect(x-9,y+7,18,11,"#d7ad77");rect(x-5,y+10,10,5,"#6b4a36");
      rect(x-33,y+18,66,8,"#d1ae6a");rect(x-6,y+16,12,15,"#f2d890");
    } else if(e.type==="monkey"){
      rect(x-22,y-27,44,30,"#72534f");rect(x-18,y-36,36,15,"#a48378");
      rect(x-28,y-17,9,18,"#c39276");rect(x+19,y-17,9,18,"#c39276");
      rect(x-17,y-12,34,23,c);rect(x-10,y-4,7,6,"#f7d69b");rect(x+3,y-4,7,6,"#f7d69b");
      rect(x-25,y+12,50,23,"#6b658a");rect(x-30,y+20,60,7,"#c5a47b");
    } else if(e.type==="fan"){
      rect(x-20,y-34,40,15,"#2f393d");rect(x-26,y-23,52,8,"#d4aa72");
      rect(x-18,y-15,36,33,"#e0b79f");rect(x-11,y-4,7,5,"#493c3c");rect(x+4,y-4,7,5,"#493c3c");
      rect(x-31,y+17,62,21,"#ad5e55");rect(x+27,y-46,8,73,"#a8735a");
      for(let i=0;i<5;i++)rect(x+13+i*7,y-49+i*4,7,29,"#e9c489");
    } else if(e.type==="mouse"){
      rect(x-24,y-26,16,22,"#d7bec8");rect(x+8,y-26,16,22,"#d7bec8");
      rect(x-23,y-12,46,45,c);rect(x-15,y-7,10,6,"#5a3b44");rect(x+5,y-7,10,6,"#5a3b44");
      rect(x-4,y+7,8,6,"#eeb5af");rect(x-30,y+13,15,4,"#f1dbd8");rect(x+15,y+13,15,4,"#f1dbd8");
      rect(x+29,y-38,6,69,"#bc8c6d");rect(x+23,y-45,18,10,"#f2d791");
    } else if(e.type==="leopard"){
      rect(x-29,y-34,13,24,c);rect(x+16,y-34,13,24,c);rect(x-28,y-13,56,47,c);
      for(const [dx,dy] of [[-18,-25],[4,-24],[-12,4],[16,9],[-5,22]])rect(x+dx,y+dy,7,6,"#6b5547");
      rect(x-15,y-8,9,6,"#e9d6a3");rect(x+6,y-8,9,6,"#e9d6a3");rect(x-8,y+8,16,9,"#e9cc9e");
      rect(x+29,y-26,7,60,"#8c806c");
    } else if(e.type==="rhino"){
      rect(x-34,y-20,68,56,"#5b828b");rect(x-25,y-30,50,38,c);
      rect(x-10,y-50,20,34,"#e2e8db");rect(x-15,y-7,10,7,"#365261");rect(x+5,y-7,10,7,"#365261");
      rect(x-20,y+18,40,14,"#79a5a7");rect(x-36,y+27,13,14,"#4f727c");rect(x+23,y+27,13,14,"#4f727c");
    } else if(e.type==="fish"){
      rect(x-38,y-4,18,16,c);rect(x-27,y-23,54,50,c);
      rect(x-16,y-30,25,12,"#a8d4d1");rect(x-10,y-13,40,20,"#a5d3d7");
      rect(x-12,y-5,7,7,"#344e53");rect(x+5,y-5,7,7,"#344e53");
      rect(x-4,y+10,13,5,"#467f87");rect(x-27,y+16,10,16,"#6dabb1");rect(x+17,y+16,10,16,"#6dabb1");
    } else if(e.type==="beast"){
      rect(x-32,y-34,12,25,"#e5cc83");rect(x+20,y-34,12,25,"#e5cc83");
      rect(x-30,y-19,60,53,"#8f7358");rect(x-22,y-26,44,34,c);
      rect(x-16,y-11,10,7,"#413b35");rect(x+6,y-11,10,7,"#413b35");
      rect(x-11,y+8,22,11,"#ddb582");rect(x-3,y+9,6,6,"#554138");
      for(let i=-1;i<=1;i++)rect(x-22+i*21,y+23,11,7,"#f0c66e");
    } else if(e.type==="scorpion"){
      for(let i=-2;i<=2;i++){rect(x-43,y+i*9,17,4,"#936b86");rect(x+26,y+i*9,17,4,"#936b86");}
      rect(x-28,y-23,56,57,"#664e65");rect(x-20,y-31,40,37,c);
      rect(x-13,y-12,8,6,"#f4d0a5");rect(x+5,y-12,8,6,"#f4d0a5");
      rect(x-9,y+5,18,12,"#a16b83");rect(x+26,y-38,9,29,"#976780");
      rect(x+29,y-45,14,9,"#f0b6a4");rect(x-34,y+16,12,18,"#a8758d");
    } else if(e.type==="spider"){
      for(let i=-2;i<=2;i++){rect(x-40,y+i*9,16,4,"#8a6b93");rect(x+24,y+i*9,16,4,"#8a6b93");}
      rect(x-29,y-25,58,58,"#5c4b65");rect(x-20,y-32,40,38,c);
      for(let i=0;i<5;i++)rect(x-17+i*8,y-18+(i%2)*5,5,5,"#f0d697");
      rect(x-10,y+8,20,8,"#c8a9c9");rect(x-4,y+17,8,6,"#4b3951");
    } else if(e.type==="bird"){
      rect(x-48,y-21,24,43,"#897eac");rect(x+24,y-21,24,43,"#897eac");
      rect(x-43,y-25,18,16,c);rect(x+25,y-25,18,16,c);
      rect(x-24,y-28,48,60,c);rect(x-16,y-38,32,29,"#d3c4d9");
      rect(x-12,y-22,7,6,"#373542");rect(x+5,y-22,7,6,"#373542");
      rect(x-5,y-9,10,15,"#ddb572");rect(x-19,y+13,38,11,"#a599bd");
    } else if(e.type==="deer"){
      rect(x-30,y-41,8,33,"#d9c899");rect(x+22,y-41,8,33,"#d9c899");
      rect(x-36,y-34,15,6,"#d9c899");rect(x+21,y-34,15,6,"#d9c899");
      rect(x-26,y-15,52,49,"#7f947b");rect(x-19,y-25,38,34,c);
      rect(x-13,y-10,8,6,"#3f493f");rect(x+5,y-10,8,6,"#3f493f");
      rect(x-6,y+8,12,8,"#e8d9b3");rect(x-23,y+18,46,11,"#e7d5a2");
    } else if(e.type==="bear"){
      rect(x-26,y-30,16,17,c);rect(x+10,y-30,16,17,c);
      rect(x-29,y-14,58,45,c);rect(x-19,y-23,38,34,c);
      rect(x-15,y-8,8,6,"#e2b377");rect(x+7,y-8,8,6,"#e2b377");
      rect(x-9,y+4,18,12,"#a7836f");rect(x-3,y+4,6,5,"#242c2a");
      rect(x-32,y+14,13,19,"#353a37");rect(x+19,y+14,13,19,"#353a37");
    } else if(e.type==="wind"){
      rect(x-30,y-28,19,22,c);rect(x+11,y-28,19,22,c);
      rect(x-25,y-14,50,45,"#b8a05e");rect(x-20,y-16,40,28,c);
      rect(x-14,y-5,7,5,"#543e38");rect(x+7,y-5,7,5,"#543e38");rect(x-5,y+5,10,10,"#7d6252");
      rect(x-35,y+7,17,3,"#e4d2a1");rect(x+18,y+7,17,3,"#e4d2a1");
    } else if(e.type==="bone"){
      rect(x-26,y-14,52,46,"#685b77");rect(x-20,y-29,40,37,c);
      rect(x-19,y-24,38,29,"#e0dccd");rect(x-13,y-11,9,8,"#3b3545");rect(x+4,y-11,9,8,"#3b3545");
      rect(x-4,y+2,8,6,"#6d5e67");for(let i=0;i<4;i++)rect(x-12+i*7,y+10,4,6,"#e4dfcf");
    } else if(e.type==="fire"){
      rect(x-23,y-29,12,20,"#ec8b4e");rect(x-5,y-37,12,27,"#f3b35f");rect(x+14,y-30,12,21,"#df6846");
      rect(x-24,y-14,48,45,"#a6443b");rect(x-16,y-20,32,31,c);
      rect(x-11,y-7,8,5,"#352c2c");rect(x+3,y-7,8,5,"#352c2c");rect(x-5,y+7,10,5,"#f5bc84");
      rect(x-29,y+2,11,25,"#ef9e5c");rect(x+18,y+2,11,25,"#ef9e5c");
    } else if(e.type==="bull"){
      rect(x-36,y-31,13,24,"#ddd1ac");rect(x+23,y-31,13,24,"#ddd1ac");
      rect(x-26,y-19,52,53,c);rect(x-17,y-23,34,29,"#8e6664");
      rect(x-12,y-7,7,6,"#f2ca94");rect(x+5,y-7,7,6,"#f2ca94");
      rect(x-11,y+6,22,14,"#a87870");rect(x-7,y+9,5,4,"#5d403f");rect(x+3,y+9,5,4,"#5d403f");
      rect(x-33,y+12,10,24,"#57454d");rect(x+23,y+12,10,24,"#57454d");
    } else if(e.type==="brow"){
      rect(x-28,y-22,56,54,"#c19b56");rect(x-20,y-28,40,39,c);
      rect(x-17,y-11,15,5,"#786449");rect(x+2,y-11,15,5,"#786449");
      rect(x-11,y-4,7,6,"#3e3833");rect(x+4,y-4,7,6,"#3e3833");
      rect(x-6,y+10,12,5,"#78594a");rect(x-33,y+5,10,25,"#dfc17f");rect(x+23,y+5,10,25,"#dfc17f");
    } else if(e.type==="lion"){
      for(let i=0;i<8;i++){const a=i*TWO_PI/8;rect(x+Math.cos(a)*24-8,y+Math.sin(a)*23-8,16,16,"#d9a45d");}
      rect(x-26,y-27,52,56,c);rect(x-18,y-16,36,37,"#edc882");
      rect(x-14,y-6,8,7,"#493e32");rect(x+6,y-6,8,7,"#493e32");
      rect(x-7,y+7,14,9,"#8a674b");rect(x-17,y+17,9,6,"#f0dfb8");rect(x+8,y+17,9,6,"#f0dfb8");
    } else {
      rect(x-21,y-45,13,36,c);rect(x+8,y-45,13,36,c);
      rect(x-17,y-42,5,26,"#e9abb3");rect(x+12,y-42,5,26,"#e9abb3");
      rect(x-23,y-13,46,44,"#b786aa");rect(x-17,y-20,34,33,c);
      rect(x-11,y-6,6,6,"#ad6178");rect(x+5,y-6,6,6,"#ad6178");rect(x-3,y+7,6,5,"#b3768a");
    }
    // 原著身份与法器在主轮廓之外另绘，避免同类兽形首领仅换颜色。
    const weaponColor=e.hitFlash>0?"#fff4db":"#f4d28c";
    switch(stage.legacyBossIndex){
      case 0: rect(x-37,y+4,8,31,"#eee0b1");rect(x+29,y+4,8,31,"#eee0b1");break;
      case 1: rect(x-44,y-18,10,48,"#4b6b59");rect(x-47,y-23,16,10,"#b5d5a5");break;
      case 2: for(let i=0;i<3;i++)rect(x-39+i*30,y-35-i*3,18,5,"#e7d18c");break;
      case 3: rect(x-18,y-42,36,8,"#eee7db");rect(x-31,y-1,7,31,"#ddd7ce");break;
      case 4: rect(x-23,y-42,46,7,"#e1c88e");rect(x-8,y-49,16,9,"#aeb4e2");break;
      case 5: rect(x+33,y-31,15,45,"#8a5c7b");rect(x+35,y-37,11,10,"#dbb379");break;
      case 6: rect(x+29,y-36,5,70,"#ead9a5");rect(x+25,y-45,13,14,"#f49b64");break;
      case 7: rect(x-28,y-42,56,8,"#be554b");rect(x-7,y-50,14,10,"#e6c88b");break;
      case 8: rect(x+30,y-35,8,64,"#8cc9d8");rect(x+24,y-38,20,8,"#b6e6e2");break;
      case 9: ctx.strokeStyle="#d7e7d8";ctx.lineWidth=5;ctx.beginPath();ctx.arc(x+35,y-4,22,0,TWO_PI);ctx.stroke();break;
      case 10: rect(x+34,y-46,10,27,"#e6a9be");rect(x+36,y-53,15,9,"#f3d4b5");break;
      case 11: rect(x-50,y-19,11,50,"#734d39");rect(x-57,y-32,25,18,"#d6b06d");break;
      case 12: rect(x+31,y-36,7,62,"#d4b375");rect(x+24,y-44,22,13,"#f2dc9b");break;
      case 13: for(let i=0;i<3;i++)rect(x+29+i*6,y-23+i*11,7,9,["#b8b7b4","#d7bc84","#ef9c6b"][i]);break;
      case 14: for(let i=0;i<5;i++)rect(x-20+i*10,y-43,5,5,"#f0d8a8");break;
      case 15: rect(x-53,y-21,19,16,"#9c91c7");rect(x+34,y-21,19,16,"#9c91c7");break;
      case 16: rect(x-33,y-47,8,27,"#f2e2b8");rect(x+25,y-47,8,27,"#f2e2b8");break;
      case 17: rect(x+32,y-38,5,69,"#8d6945");for(let i=0;i<5;i++)rect(x+20+i*6,y-44,4,16,"#e9d4a0");break;
      case 18: for(let i=0;i<8;i++){const a=i*TWO_PI/8;rect(x+Math.cos(a)*44-7,y+Math.sin(a)*34-7,14,14,"#d4a768");rect(x+Math.cos(a)*44-2,y+Math.sin(a)*34-2,4,4,"#f1ddae");}break;
      case 19: rect(x-26,y-50,52,8,"#edd6e8");rect(x+27,y-29,6,60,"#f0d6dd");rect(x+23,y-38,14,13,"#f5e8da");break;
    }
    if(stage.mechanic==="gourd"){rect(x+30,y-42,16,29,"#c5d8d8");rect(x+34,y-48,8,8,"#e2d69f");}
    if(stage.mechanic==="mirror"){rect(x+31,y-43,8,73,"#d5b573");rect(x+29,y-46,12,10,"#f2dd9f");}
    if(stage.mechanic==="ice"){rect(x+28,y-39,10,66,"#b7e3e5");rect(x+22,y-42,22,12,"#ecf3e7");}
    if(e.windBagHp>0){rect(x+31,y+1,21,26,"#ab8e58");rect(x+35,y-5,13,9,"#e5d28d");textDraw(`风袋 ${Math.ceil(e.windBagHp)}`,x+43,y+39,11,"#f4d993","center");}
    rect(x-36,y-60,72,6,"#161d22");
    rect(x-36,y-60,72*Math.max(0,e.hp/e.maxHp),6,"#d67e61");
    textDraw(e.name,x,y-72,15,"#f3d69a","center","900");
    if(e.windup>0){
      ctx.strokeStyle="#f5dcad";ctx.lineWidth=3;ctx.setLineDash([6,5]);
      ctx.beginPath();ctx.arc(x,y,48+(1-e.windup/.75)*18,0,TWO_PI);ctx.stroke();
      ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(player.x,player.y);ctx.stroke();ctx.setLineDash([]);
    }
  }

  function drawWorld(){
    rect(0,0,W,H,"#101b24");
    rect(0,0,W,95,"#1b2b31");rect(0,95,W,3,"#a4895b");
    rect(0,663,W,5,"#a4895b");rect(0,668,W,52,"#1b2b31");
    ctx.save();
    ctx.beginPath();ctx.rect(view.left,view.top,view.right-view.left,view.bottom-view.top);ctx.clip();
    const zoom=settings.zoom;
    ctx.translate((view.left+view.right)/2-camera.x*zoom,(view.top+view.bottom)/2-camera.y*zoom);
    ctx.scale(zoom,zoom);
    drawCachedArena();
    if(!player){
      drawHero(worldSize/2,worldSize/2,heroes[selectedHero].id,3);
      drawMob({x:worldSize/2-155,y:worldSize/2-80,radius:16,type:"wolf",color:"#83929a",hp:1,maxHp:1});
      drawMob({x:worldSize/2+150,y:worldSize/2+65,radius:17,type:"jackal",color:"#b59672",hp:1,maxHp:1});
    }else{
      for(const r of relicDrops){
        const info=relicTypes.find(a=>a.id===r.id);
        if(!info)continue;
        const bob=Math.sin(animationTime*4+r.x)*4;
        rect(r.x-21,r.y-15+bob,42,37,"#091a1faa");rect(r.x-18,r.y-23+bob,36,36,"#684b3a");
        rect(r.x-15,r.y-21+bob,30,30,info.color);rect(r.x-11,r.y-18+bob,22,23,"#24343c");
        rect(r.x-15,r.y+9+bob,30,5,"#a77b55");rect(r.x-10,r.y-18+bob,6,5,"#ffffff99");
        textDraw(info.glyph,r.x,r.y-1+bob,17,info.color,"center","900");
        ctx.strokeStyle=info.color;ctx.lineWidth=2;ctx.beginPath();ctx.arc(r.x,r.y-1+bob,24,0,TWO_PI);ctx.stroke();
      }
      for(const o of orbs){rect(o.x-4,o.y-4,8,8,"#63c8ba");rect(o.x-2,o.y-7,4,4,"#d3f3dc");}
      const actors=[...enemies.filter(e=>!e.dead).map(e=>({y:e.y,entity:e})),{y:player.y,hero:true}].sort((a,b)=>a.y-b.y);
      for(const item of actors){
        if(item.hero)drawHero(player.x,player.y,heroes[selectedHero].id,3);
        else if(item.entity.boss)drawBoss(item.entity);
        else drawMob(item.entity);
      }
      if(player.cloneTime>0){
        ctx.globalAlpha=.68;
        drawHero(player.x-38,player.y+22,"wukong",2);
        drawHero(player.x+38,player.y+22,"wukong",2);
        ctx.globalAlpha=1;
      }
      if(player.orbitBlades>0){
        for(let i=0;i<player.orbitBlades;i++){
          const a=animationTime*3+i*TWO_PI/player.orbitBlades,r=68+player.orbitBlades*12;
          const x=player.x+Math.cos(a)*r,y=player.y+Math.sin(a)*r;
          rect(x-7,y-7,14,14,"#e6d497");rect(x-3,y-3,6,6,"#fff4d7");
        }
      }
      for(const p of projectiles){
        const tail=p.type==="spear"?25:p.type==="flame"?18:p.type==="feather"?20:12;
        ctx.strokeStyle=p.color;ctx.lineWidth=p.type==="spear"||p.type==="rake"?5:p.type==="flame"?9:4;
        ctx.beginPath();ctx.moveTo(p.x-p.vx/250*tail,p.y-p.vy/250*tail);ctx.lineTo(p.x,p.y);ctx.stroke();
        rect(p.x-p.radius*.6,p.y-p.radius*.6,p.radius*1.2,p.radius*1.2,p.color);
        if(["flame","eye","star","moon","talisman"].includes(p.type))rect(p.x-2,p.y-2,4,4,"#fff4db");
      }
      for(const p of particles){ctx.globalAlpha=clamp(p.life/p.maxLife,0,1);rect(p.x,p.y,p.size,p.size,p.color);}
      ctx.globalAlpha=1;
      for(const e of effects){
        const f=e.life/e.maxLife;ctx.globalAlpha=f;
        if(e.type==="number")textDraw(e.text,e.x,e.y,17,e.color,"center","900");
        else if(e.type==="firezone"){ctx.fillStyle=e.color+"55";ctx.strokeStyle=e.color;ctx.lineWidth=4;ctx.beginPath();ctx.arc(e.x,e.y,e.radius,0,TWO_PI);ctx.fill();ctx.stroke();}
        else if(e.type==="ring"){ctx.strokeStyle=e.color;ctx.lineWidth=4;ctx.beginPath();ctx.arc(e.x,e.y,e.radius*(1-f*.35),0,TWO_PI);ctx.stroke();}
        else if(e.type==="slash"||e.type==="fan"){
          ctx.strokeStyle=e.color;ctx.lineWidth=e.type==="slash"?11:6;ctx.beginPath();
          ctx.arc(e.x,e.y,e.radius*.8,e.angle-(e.type==="fan"?.6:.8),e.angle+(e.type==="fan"?.6:.8));ctx.stroke();
        }else if(e.type==="beam"){
          ctx.strokeStyle=e.color;ctx.lineWidth=5;ctx.beginPath();ctx.moveTo(e.x,e.y);ctx.lineTo(e.toX,e.toY);ctx.stroke();
        }
      }
      ctx.globalAlpha=1;
      if(player.gourdMark){ctx.strokeStyle=player.gourdMark.kind==="dive"?"#c3b0e2":"#eed589";ctx.lineWidth=6;ctx.setLineDash([10,8]);ctx.beginPath();ctx.arc(player.gourdMark.x,player.gourdMark.y,player.gourdMark.kind==="dive"?112:106,0,TWO_PI);ctx.stroke();ctx.setLineDash([]);}
    }
    ctx.restore();
    if(player?.blindTime>0){ctx.globalAlpha=Math.min(.25,player.blindTime*.1);rect(0,96,W,567,"#c0a171");ctx.globalAlpha=1;textDraw("风沙遮眼 · 速离黄风",360,178,17,"#f5dba9","center","900");}
    drawHUD();
  }

  function drawHUD(){
    const stage=stages[stageIndex];
    if(!player){
      textDraw("重生之我也要取经",28,42,24,"#efd39c","left","900");
      textDraw("二十处山河 · 像素肉鸽",690,43,14,"#b6c6b5","right");
      textDraw("WASD 移动  ·  空格施法  ·  Shift 闪避",360,693,13,"#c6d2bd","center");
      return;
    }
    const compact=(canvas.clientWidth||W)<560;
    const skillName=heroes[selectedHero].skills[selectedSkill].name;
    const skillText=player.skillCd>0?`${skillName} ${player.skillCd.toFixed(1)}s`:`${skillName} 就绪`;
    const relic=player.relic?relicTypes.find(r=>r.id===player.relic):null;
    if(compact){
      rect(18,15,42,48,"#2d4544");
      pixelSprite(ctx,heroPixels[heroes[selectedHero].id],heroPalette[heroes[selectedHero].id],22,19,2);
      textDraw(heroes[selectedHero].name,72,34,22,"#f1d397","left","900");
      textDraw(`LV.${level}`,72,57,17,"#b8cab8");
      textDraw(`第 ${stageIndex+1}/${stages.length} 章`,692,33,22,"#f1d397","right","900");
      textDraw(stage.place,692,60,18,"#d7cfb4","right");
      rect(18,73,238,16,"#102126");rect(18,73,238*clamp(player.hp/player.maxHp,0,1),16,"#ca6b59");
      textDraw(`${Math.ceil(player.hp)}/${player.maxHp}`,137,86,16,"#fff0dc","center","900");
      rect(270,73,150,16,"#102126");rect(270,73,150*clamp(xp/xpGoal,0,1),16,"#69c3b6");
      textDraw("修为",345,86,15,"#edf1da","center","900");
      textDraw(bossSpawned?"妖王现身":`${rooms.describe(stage,roomAt(roomIndex)).name} · 清剿后前进`,692,86,16,"#c8d1b9","right");
      textDraw(skillText,22,695,19,"#ead69e","left","900");
      textDraw(player.dashCd>0?`闪避 ${player.dashCd.toFixed(1)}s`:"闪避就绪",360,695,18,"#c6d5be","center");
      if(relic)textDraw(`${relic.name} ${player.relicTime.toFixed(0)}s`,695,695,18,relic.color,"right","900");
      else textDraw(`钱 ${coins} · 宝 ${player.relicBag.length}`,695,695,18,"#e4cb95","right");
    }else{
      rect(18,13,5,65,"#d3a46c");rect(28,15,40,42,"#2d4544");
      pixelSprite(ctx,heroPixels[heroes[selectedHero].id],heroPalette[heroes[selectedHero].id],31,18,2);
      textDraw(heroes[selectedHero].name,80,27,19,"#f1d397","left","900");
      textDraw(`LV.${level} · ${heroes[selectedHero].role}`,80,50,12,"#aebfad");
      rect(80,65,205,11,"#102126");rect(80,65,205*Math.max(0,player.hp/player.maxHp),11,"#ca6b59");
      textDraw(`${Math.ceil(player.hp)} / ${player.maxHp}`,182,70,11,"#fff0dc","center","900");
      if(player.burnTime>0||player.poisonTime>0||player.slowTime>0)
        textDraw([player.burnTime>0?"灼烧":"",player.poisonTime>0?"中毒":"",player.slowTime>0?"迟滞":""].filter(Boolean).join(" · "),80,87,10,"#e8b38a");
      rect(296,65,126,11,"#102126");rect(296,65,126*clamp(xp/xpGoal,0,1),11,"#69c3b6");
      textDraw("修为",359,70,11,"#edf1da","center","900");
      textDraw(`第 ${stageIndex+1}/${stages.length} 章 · ${stage.place}`,692,27,17,"#f1d397","right","900");
      textDraw(`第 ${stageIndex+1} 章 · ${stage.place} · 原著 ${stage.firstTrial}—${stage.lastTrial} 难${player.ordealAccepted?" · 历劫":""}`,692,51,12,"#b9c3ad","right");
      textDraw("空格",32,693,13,"#e5c487","left","900");textDraw(skillText,80,693,13,"#e8e0c7");
      textDraw(`Shift ${player.dashCd>0?player.dashCd.toFixed(1)+"s":"闪避"}`,370,693,12,player.dashCd>0?"#859793":"#c6d5be");
      if(relic)textDraw(`${relic.name} ${player.relicTime.toFixed(0)}s · 钱 ${coins}`,683,693,13,relic.color,"right","900");
      else textDraw(`Q 宝 ${player.relicBag.length}/${player.relicCapacity} · 钱 ${coins}`,683,693,12,"#e4cb95","right");
    }
    if(dialogueTime>0){
      ctx.globalAlpha=Math.min(1,dialogueTime*2);
      rect(118,109,484,52,"#101c24e8");rect(118,109,5,52,stage.accent);
      textDraw(dialogueSpeaker,133,126,12,stage.accent);
      textDraw(dialogue,133,145,15,"#f1e6c9");
      ctx.globalAlpha=1;
    }
    if(bannerTime>0){
      ctx.globalAlpha=Math.min(1,bannerTime*2);
      rect(147,291,426,64,"#111d24e8");rect(147,291,426,3,"#deb67a");rect(147,352,426,3,"#deb67a");
      textDraw(banner,360,324,23,"#f6dea8","center","900");ctx.globalAlpha=1;
    }
  }

  function frame(ts) {
    const dt=Math.min(.035,(ts-lastFrame)/1000||.016);lastFrame=ts;
    audio.update();
    if(hitStop>0)hitStop=Math.max(0,hitStop-dt);
    else if(mode==="playing") update(dt);
    else animationTime+=dt*.3;
    ctx.save();
    if(settings.shake&&shake>0&&mode==="playing")ctx.translate(Math.round(rand(-shake,shake)),Math.round(rand(-shake,shake)));
    drawWorld();ctx.restore();
    updateTouchStatus();
    requestAnimationFrame(frame);
  }

  const touchDashLabel=document.getElementById("touch-dash-cd");
  const touchSkillLabel=document.getElementById("touch-skill-cd");
  const touchRelicLabel=document.getElementById("touch-relic-name");
  const touchDashButton=document.getElementById("touch-dash");
  const touchSkillButton=document.getElementById("touch-skill");
  function updateTouchStatus(){
    if(!player||mode!=="playing")return;
    const dash=player.dashCd>0?`${Math.ceil(player.dashCd)}s`:"就绪";
    const skill=player.skillCd>0?`${Math.ceil(player.skillCd)}s`:"就绪";
    if(touchDashLabel&&touchDashLabel.textContent!==dash)touchDashLabel.textContent=dash;
    if(touchSkillLabel&&touchSkillLabel.textContent!==skill)touchSkillLabel.textContent=skill;
    const unavailable=relicUseReason(player.relicBag[0]);
    const stored=unavailable||relicTypes.find(r=>r.id===player.relicBag[0])?.name||"空";
    if(touchRelicLabel&&touchRelicLabel.textContent!==stored)touchRelicLabel.textContent=stored;
    document.getElementById("touch-relic").disabled=!!unavailable;
    touchDashButton?.classList.toggle("cooling",player.dashCd>0);
    touchSkillButton?.classList.toggle("cooling",player.skillCd>0);
  }

  window.addEventListener("keydown", e=>{
    const k=e.key.toLowerCase();
    if(["INPUT","SELECT","TEXTAREA","BUTTON"].includes(e.target?.tagName)&&!["p","escape","m"].includes(k))return;
    if(mode==="playing"&&[" ","arrowup","arrowdown","arrowleft","arrowright","shift","tab"].includes(k))e.preventDefault();
    if(mode==="playing")keys.add(k);
    if(e.repeat)return;
    if(k===" " && mode==="playing")skill();
    else if(k==="shift" && mode==="playing")dash();
    else if(k==="q" && mode==="playing")useRelic();
    else if(k==="tab" && mode==="playing")showMap();
    else if(k==="p"||k==="escape"){
      if(mode==="settings"){settingsReturn==="paused"?renderPause():home();}
      else if(mode==="library"||mode==="loadout")home();
      else if(mode==="map")screen.querySelector("#map-back")?.click();
      else pause();
    }
    else if(k==="m"){
      soundMuted=!soundMuted;
      audio.setVolumes(soundMuted?0:settings.bgm,soundMuted?0:settings.sfx);
    }
  });
  window.addEventListener("keyup",e=>keys.delete(e.key.toLowerCase()));
  window.addEventListener("blur",()=>{keys.clear();resetTouch();if(mode==="playing")pause();});
  document.addEventListener?.("visibilitychange",()=>{if(document.hidden){keys.clear();resetTouch();if(mode==="playing")pause();}});
  window.addEventListener("beforeunload",()=>{if(["playing","paused","story","upgrade","encounter","map","epilogue"].includes(mode))saveRun();});
  const stick=document.getElementById("joystick"),knob=document.getElementById("joystick-knob");
  function stickMove(e){
    const r=stick.getBoundingClientRect(),cx=r.left+r.width/2,cy=r.top+r.height/2;
    const max=r.width*.32,vx=e.clientX-cx,vy=e.clientY-cy,d=Math.hypot(vx,vy)||1;
    const f=Math.min(1,d/max);touch.x=vx/d*f;touch.y=vy/d*f;
    knob.style.transform=`translate(${touch.x*max}px,${touch.y*max}px)`;
  }
  stick.addEventListener("pointerdown",e=>{e.preventDefault();touch.pointer=e.pointerId;stick.setPointerCapture(e.pointerId);stickMove(e);});
  stick.addEventListener("pointermove",e=>{if(touch.pointer===e.pointerId){e.preventDefault();stickMove(e);}});
  function stickEnd(e){if(touch.pointer!==e.pointerId)return;touch.pointer=null;touch.x=0;touch.y=0;knob.style.transform="translate(0,0)";}
  stick.addEventListener("pointerup",stickEnd);stick.addEventListener("pointercancel",stickEnd);
  stick.addEventListener("lostpointercapture",stickEnd);
  document.getElementById("touch-pause").addEventListener("click",pause);
  document.getElementById("touch-skill").addEventListener("pointerdown",e=>{e.preventDefault();skill();});
  document.getElementById("touch-dash").addEventListener("pointerdown",e=>{e.preventDefault();dash();});
  document.getElementById("touch-relic").addEventListener("pointerdown",e=>{e.preventDefault();useRelic();});

  home();
  requestAnimationFrame(frame);
})();






