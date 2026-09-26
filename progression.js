// 构筑数据：数值字段均在 game.js 的战斗循环中生效。
window.XIYOU_UPGRADES = [
  {id:"might",name:"降妖真力",icon:"✦",desc:"攻击伤害 +14%",max:6,apply:p=>p.damage*=1.14},
  {id:"tempo",name:"连环棍势",icon:"❯",desc:"武器攻速 +12%",max:5,apply:p=>p.attackSpeed*=1.12},
  {id:"vigor",name:"金刚躯",icon:"◆",desc:"生命上限 +22，并回复 22",max:7,apply:p=>{p.maxHp+=22;p.hp=Math.min(p.maxHp,p.hp+22)}},
  {id:"stride",name:"踏云步",icon:"➤",desc:"移动速度 +10%",max:4,apply:p=>p.speed*=1.1},
  {id:"guard",name:"护体罡气",icon:"◈",desc:"减伤 +7%，最多 49%",max:7,apply:p=>p.armor=Math.min(.49,p.armor+.07)},
  {id:"crit",name:"火眼金睛",icon:"✧",desc:"暴击率 +8%",max:6,apply:p=>p.crit=Math.min(.65,p.crit+.08)},
  {id:"magnet",name:"聚灵珠",icon:"◎",desc:"拾取范围 +55",max:4,apply:p=>p.magnet+=55},
  {id:"haste",name:"真言通明",icon:"☼",desc:"技能冷却 -13%",max:5,apply:p=>p.skillHaste=Math.max(.42,p.skillHaste*.87)},
  {id:"boss",name:"镇魔锋",icon:"⚔",desc:"首领伤害 +18%",max:5,apply:p=>p.bossDamage*=1.18},
  {id:"healing",name:"甘露法水",icon:"✚",desc:"立即回复 48 生命",max:99,apply:p=>p.hp=Math.min(p.maxHp,p.hp+48)},
  {id:"wisdom",name:"悟道经卷",icon:"卷",desc:"获得修为 +18%",max:5,apply:p=>p.xpGain*=1.18},
  {id:"split",name:"一气化三清",icon:"⋆",desc:"远程武器额外发射 1 枚",max:3,apply:p=>p.extraShots++},
  {id:"pierce",name:"破甲透骨",icon:"↣",desc:"远程穿透数 +1",max:4,apply:p=>p.pierce++},
  {id:"area",name:"法力扩散",icon:"◌",desc:"攻击范围 +11%",max:5,apply:p=>p.area*=1.11},
  {id:"force",name:"震山劲",icon:"◀",desc:"击退力度 +20%",max:5,apply:p=>p.knockback*=1.2},
  {id:"velocity",name:"追风法",icon:"⇢",desc:"飞行物速度 +16%",max:4,apply:p=>p.projectileSpeed*=1.16},
  {id:"leech",name:"回春心法",icon:"♡",desc:"伤害有 3% 概率回复 1 生命",max:5,apply:p=>p.lifeSteal+=.03},
  {id:"burn",name:"三昧余烬",icon:"炎",desc:"命中有 13% 概率灼烧敌人",max:5,apply:p=>p.burnChance+=.13},
  {id:"frost",name:"寒潭真气",icon:"❄",desc:"命中有 12% 概率冻结敌人",max:5,apply:p=>p.freezeChance+=.12},
  {id:"chain",name:"惊雷引",icon:"ϟ",desc:"暴击有 25% 概率弹射雷击",max:4,apply:p=>p.chainChance+=.25},
  {id:"regen",name:"九转还丹",icon:"☯",desc:"每秒回复 0.6 生命",max:5,apply:p=>p.regen+=.6},
  {id:"thorns",name:"反震法衣",icon:"♢",desc:"接触敌人时反震 16 伤害",max:5,apply:p=>p.thorns+=16},
  {id:"relic",name:"借宝有时",icon:"宝",desc:"临时法宝持续时间 +22%",max:4,apply:p=>p.relicDuration*=1.22},
  {id:"dash",name:"筋斗步",icon:"≫",desc:"闪避冷却 -14%",max:4,apply:p=>p.dashHaste=Math.max(.45,p.dashHaste*.86)},
  {id:"execute",name:"斩魔诀",icon:"斩",desc:"敌人低于 20% 生命时伤害 +30%",max:3,apply:p=>p.execute+=.3},
  {id:"size",name:"宝光大盛",icon:"◇",desc:"飞行物体积 +15%",max:4,apply:p=>p.projectileSize*=1.15},
  {id:"poison",name:"百草毒经",icon:"毒",desc:"命中有 12% 概率施毒",max:5,apply:p=>p.poisonChance+=.12},
  {id:"orbit",name:"护法金轮",icon:"⊙",desc:"召唤绕身金轮，持续切割近敌",max:3,apply:p=>p.orbitBlades++},
  {id:"wind",name:"定风之势",icon:"风",desc:"每 5 秒放出一道风刃",max:3,apply:p=>p.windPower++},
  {id:"pulse",name:"佛光回响",icon:"✺",desc:"每 8 秒震伤周围敌人",max:3,apply:p=>p.pulsePower++},
  {id:"fortune",name:"福缘深厚",icon:"福",desc:"法宝刷新更快，掉落修为更多",max:3,apply:p=>{p.fortune++;p.xpGain*=1.06}},
  {id:"barrier",name:"灵台清明",icon:"盾",desc:"每关开始获得 1 层护身盾",max:3,apply:p=>p.startShield++},
  {id:"dashblast",name:"逐电踏火",icon:"⚡",desc:"闪避时震伤周围敌人",max:3,apply:p=>p.dashBlast+=12}
];

// 修行分三阶；专属修行直接改变武器的表现或技能节奏。
window.XIYOU_UPGRADES.forEach((u,i)=>{u.tier=i<16?"基础":i<28?"进阶":"秘传";});
window.XIYOU_UPGRADES.push(
  {id:"wukong_sweep",hero:"wukong",tier:"专属",name:"猴王千钧",icon:"悟",desc:"金箍棒横扫更宽，留下第二道金色棍影",max:2,apply:p=>p.heroTalent=(p.heroTalent||0)+1},
  {id:"tangseng_sutra",hero:"tangseng",tier:"专属",name:"般若经轮",icon:"经",desc:"法印附带佛光回响，并缩短主动技能冷却",max:2,apply:p=>{p.heroTalent=(p.heroTalent||0)+1;p.skillHaste*=.9}},
  {id:"bajie_rake",hero:"bajie",tier:"专属",name:"天蓬九击",icon:"耙",desc:"钉耙重击震开地面，并提高击退效果",max:2,apply:p=>{p.heroTalent=(p.heroTalent||0)+1;p.knockback*=1.15}},
  {id:"shaseng_tide",hero:"shaseng",tier:"专属",name:"流沙回澜",icon:"沙",desc:"宝杖与飞刃附带水纹，命中迟滞敌人",max:2,apply:p=>p.heroTalent=(p.heroTalent||0)+1},
  {id:"resonance",tier:"进阶",name:"法脉共鸣",icon:"✺",desc:"每次主动技能释放，震伤近处妖怪",max:3,apply:p=>p.resonance=(p.resonance||0)+1},
  {id:"golden_guard",tier:"进阶",name:"护行金符",icon:"符",desc:"每关开场额外获得护盾，并提升生命上限",max:3,apply:p=>{p.startShield++;p.maxHp+=12;p.hp+=12}},
  {id:"coin_luck",tier:"基础",name:"聚宝缘",icon:"钱",desc:"妖怪掉落金币概率和数量提高",max:3,apply:p=>p.coinLuck=(p.coinLuck||0)+1},
  {id:"relic_master",tier:"秘传",name:"御宝诀",icon:"宝",desc:"存储法宝上限 +1，法宝持续时间 +25%",max:2,apply:p=>{p.relicCapacity=(p.relicCapacity||2)+1;p.relicDuration*=1.25}}
);

window.XIYOU_UPGRADES.push(
  {id:"bailongma_tide_start",hero:"bailongma",tier:"专属",name:"龙脉潮汐",icon:"龙",desc:"移动积蓄潮势；水系攻击伤害提高 12%",max:3,apply:p=>{p.heroTalent=(p.heroTalent||0)+1;p.tidePower=(p.tidePower||0)+.12}},
  {id:"wukong_clones",hero:"wukong",tier:"专属",name:"毫毛不尽",icon:"毛",desc:"分身延长 2 秒，分身攻击更快",max:3,apply:p=>p.clonePower=(p.clonePower||0)+1},
  {id:"wukong_armorbreak",hero:"wukong",tier:"专属",name:"破甲棍花",icon:"棍",desc:"金箍棒命中令妖王防御破绽持续 4 秒",max:2,apply:p=>p.armorBreak=(p.armorBreak||0)+1},
  {id:"bajie_bloodwell",hero:"bajie",tier:"专属",name:"耙下回生",icon:"血",desc:"近战命中回复生命，连续命中有递减收益",max:3,apply:p=>p.bajieHeal=(p.bajieHeal||0)+1},
  {id:"bajie_taunt",hero:"bajie",tier:"专属",name:"天蓬怒喝",icon:"喝",desc:"护体时反震伤害增加 18",max:3,apply:p=>p.thorns+=18},
  {id:"shaseng_barrier",hero:"shaseng",tier:"专属",name:"流沙护阵",icon:"护",desc:"每次施法得到一层护身盾",max:2,apply:p=>p.sandBarrier=(p.sandBarrier||0)+1},
  {id:"shaseng_venom",hero:"shaseng",tier:"专属",name:"沉沙毒潮",icon:"潮",desc:"宝杖命中有 18% 概率施毒",max:3,apply:p=>p.poisonChance+=.18},
  {id:"tangseng_convert",hero:"tangseng",tier:"专属",name:"慈悲度化",icon:"化",desc:"被度化小妖效忠时间 +3 秒",max:3,apply:p=>p.convertPower=(p.convertPower||0)+1},
  {id:"tangseng_purify",hero:"tangseng",tier:"专属",name:"清净法音",icon:"净",desc:"佛光施法清除负面状态，并增加佛光伤害",max:2,apply:p=>p.purifyPower=(p.purifyPower||0)+1},
  {id:"bailongma_surf",hero:"bailongma",tier:"专属",name:"逐浪连蹄",icon:"浪",desc:"潮势高时武器追加一枚水刃",max:3,apply:p=>p.surfPower=(p.surfPower||0)+1},
  {id:"bailongma_scale",hero:"bailongma",tier:"专属",name:"龙鳞护身",icon:"鳞",desc:"闪避后得到短暂护盾",max:2,apply:p=>p.scalePower=(p.scalePower||0)+1},
  {id:"wukong_clone",hero:"wukong",tier:"秘传",metaUnlock:true,name:"猴毛分身诀",icon:"身",desc:"分身存在时间 +4 秒",max:1,apply:p=>p.clonePower=(p.clonePower||0)+2},
  {id:"bajie_blood",hero:"bajie",tier:"秘传",metaUnlock:true,name:"天蓬回生诀",icon:"耙",desc:"近战击回 +2，受伤提高 5%",max:1,apply:p=>{p.bajieHeal=(p.bajieHeal||0)+2;p.curse=(p.curse||0)+.25}},
  {id:"shaseng_sand",hero:"shaseng",tier:"秘传",metaUnlock:true,name:"流沙护阵诀",icon:"阵",desc:"施法获得护盾层数 +1",max:1,apply:p=>p.sandBarrier=(p.sandBarrier||0)+1},
  {id:"tangseng_mercy",hero:"tangseng",tier:"秘传",metaUnlock:true,name:"度化偈",icon:"慈",desc:"度化小妖效忠时间 +5 秒",max:1,apply:p=>p.convertPower=(p.convertPower||0)+2},
  {id:"bailongma_tide",hero:"bailongma",tier:"秘传",metaUnlock:true,name:"龙脉踏潮诀",icon:"龙",desc:"潮势高时攻击额外水刃",max:1,apply:p=>p.surfPower=(p.surfPower||0)+2}
);
window.XIYOU_WEAPON_CARDS=[
  {id:"weapon_wukong",hero:"wukong",tier:"兵器",name:"棍影进阶",icon:"棍",desc:"当前兵器伤害 +12%，攻速 +3%",max:5,apply:p=>{p.weaponRank=(p.weaponRank||0)+1;p.attackSpeed=Math.min(2.4,p.attackSpeed*1.03)}},
  {id:"weapon_tangseng",hero:"tangseng",tier:"兵器",name:"佛珠进阶",icon:"珠",desc:"当前法器伤害 +12%，佛光范围 +3%",max:5,apply:p=>{p.weaponRank=(p.weaponRank||0)+1;p.area=Math.min(1.8,p.area*1.03)}},
  {id:"weapon_bajie",hero:"bajie",tier:"兵器",name:"九齿进阶",icon:"耙",desc:"当前兵器伤害 +12%，生命上限 +4",max:5,apply:p=>{p.weaponRank=(p.weaponRank||0)+1;p.maxHp+=4;p.hp+=4}},
  {id:"weapon_shaseng",hero:"shaseng",tier:"兵器",name:"宝杖进阶",icon:"杖",desc:"当前兵器伤害 +12%，穿透 +1",max:5,apply:p=>{p.weaponRank=(p.weaponRank||0)+1;p.pierce++}},
  {id:"weapon_bailongma",hero:"bailongma",tier:"兵器",name:"龙角进阶",icon:"角",desc:"当前兵器伤害 +12%，潮势积蓄 +8%",max:5,apply:p=>{p.weaponRank=(p.weaponRank||0)+1;p.tidePower=(p.tidePower||0)+.08}}
];
window.XIYOU_ACTIVE_CARDS=[
  {id:"active_wukong",hero:"wukong",tier:"主动",name:"身法精进",icon:"云",desc:"主动技能冷却 -9%，分身伤害 +8%",max:4,apply:p=>{p.skillRank=(p.skillRank||0)+1;p.skillHaste=Math.min(p.skillHaste,Math.max(.42,p.skillHaste*.91))}},
  {id:"active_tangseng",hero:"tangseng",tier:"主动",name:"真言精进",icon:"经",desc:"主动技能冷却 -9%，度化时间 +1 秒",max:4,apply:p=>{p.skillRank=(p.skillRank||0)+1;p.skillHaste=Math.min(p.skillHaste,Math.max(.42,p.skillHaste*.91))}},
  {id:"active_bajie",hero:"bajie",tier:"主动",name:"天蓬精进",icon:"蓬",desc:"主动技能冷却 -9%，护体时间 +0.5 秒",max:4,apply:p=>{p.skillRank=(p.skillRank||0)+1;p.skillHaste=Math.min(p.skillHaste,Math.max(.42,p.skillHaste*.91))}},
  {id:"active_shaseng",hero:"shaseng",tier:"主动",name:"流沙精进",icon:"沙",desc:"主动技能冷却 -9%，结界时间 +0.5 秒",max:4,apply:p=>{p.skillRank=(p.skillRank||0)+1;p.skillHaste=Math.min(p.skillHaste,Math.max(.42,p.skillHaste*.91))}},
  {id:"active_bailongma",hero:"bailongma",tier:"主动",name:"龙吟精进",icon:"吟",desc:"主动技能冷却 -9%，潮势上限效果 +8%",max:4,apply:p=>{p.skillRank=(p.skillRank||0)+1;p.skillHaste=Math.min(p.skillHaste,Math.max(.42,p.skillHaste*.91))}}
];
// 每位取经人各有一式只能在局内悟得的第三主动技能。获得时替换当前主动技能。
window.XIYOU_SKILL_CARDS=[
  {id:"skill_wukong_bind",hero:"wukong",tier:"新神通",name:"定身术",icon:"定",desc:"替换当前主动：定住近处小妖 2 秒；妖王迟缓 1 秒。冷却 15 秒",max:1,apply:p=>p.skillVariant=2},
  {id:"skill_tangseng_ray",hero:"tangseng",tier:"新神通",name:"金光破障",icon:"光",desc:"替换当前主动：朝最近妖怪发射穿透佛光；清除自身中毒与灼烧。冷却 12 秒",max:1,apply:p=>p.skillVariant=2},
  {id:"skill_bajie_quake",hero:"bajie",tier:"新神通",name:"九齿震地",icon:"震",desc:"替换当前主动：范围重击并减速，命中后至多回复 18 生命。冷却 13 秒",max:1,apply:p=>p.skillVariant=2},
  {id:"skill_shaseng_moon",hero:"shaseng",tier:"新神通",name:"水月木刃",icon:"月",desc:"替换当前主动：连发三道穿透月刃，命中可更快叠加藤沙。冷却 11 秒",max:1,apply:p=>p.skillVariant=2},
  {id:"skill_bailongma_breath",hero:"bailongma",tier:"新神通",name:"龙息吐纳",icon:"息",desc:"替换当前主动：喷出三道水息，迟缓前方妖怪并积攒潮势。冷却 10 秒",max:1,apply:p=>p.skillVariant=2}
];

window.XIYOU_SYNERGIES = [
  {id:"firewind",name:"风助火势",requires:["burn","wind"],desc:"风刃引燃敌人，燃烧时间延长"},
  {id:"thunder_eye",name:"火眼惊雷",requires:["crit","chain"],desc:"暴击雷击额外寻找目标"},
  {id:"frost_split",name:"霜刃千重",requires:["frost","split"],desc:"额外飞行物更易冻结"},
  {id:"mercy_armor",name:"慈悲金身",requires:["regen","guard"],desc:"护甲达到上限时回复增强"},
  {id:"relic_hunt",name:"法宝巡游",requires:["relic","fortune"],desc:"拾取法宝时立即回复生命"},
  {id:"boss_execute",name:"诛魔一线",requires:["boss","execute"],desc:"首领濒危时再获斩杀加成"},
  {id:"poison_leech",name:"以毒养身",requires:["poison","leech"],desc:"中毒敌人死亡时回复生命"}
];

