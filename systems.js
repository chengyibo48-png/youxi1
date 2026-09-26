// 取经规则表。文案与数值集中在此，避免把设定写死在战斗循环中。
(() => {
  const names={metal:"金",wood:"木",water:"水",fire:"火",earth:"土",none:"无"};
  const conquers={metal:"wood",wood:"earth",earth:"water",water:"fire",fire:"metal"};
  const generates={metal:"water",water:"wood",wood:"fire",fire:"earth",earth:"metal"};
  const hero={tangseng:"metal",wukong:"fire",bajie:"earth",shaseng:"wood",bailongma:"water"};
  const biomes={wild:"earth",forest:"wood",desert:"none",grave:"none",night:"none",cave:"earth",ember:"fire",city:"none",river:"water",temple:"metal",web:"wood",moon:"none"};
  const mobs={jackal:"earth",wolf:"earth",tiger:"wood",leopard:"wood",bat:"none",bearling:"earth",windling:"none",bee:"none",disguised:"none",lotusling:"metal",fireling:"fire",bonelet:"none",shade:"none",stone:"earth",guard:"metal",fishling:"water",bulllet:"earth",spiderlet:"wood",scorpionlet:"wood",lionlet:"earth",deerlet:"wood",rabbitlet:"none"};
  const bosses={"黄风怪":"none","白骨精":"none","金角大王":"metal","银角大王":"metal","红孩儿":"fire","青牛精":"metal","蝎子精":"wood","牛魔王":"fire","铁扇公主":"fire","大鹏金翅雕":"none","六耳猕猴":"none","金鼻白毛老鼠精":"none","南山大王":"wood","辟寒大王":"water","玉兔精":"none"};
  const special={13:"none",20:"none",24:"metal",25:"metal",31:"fire",40:"metal",47:"fire",48:"fire",49:"fire",64:"none",77:"water"};
  // 按实际抵达的地点配敌。共覆盖八十一难，剧情关没有战斗时保留地貌属性。
  const themes=[
    [1,4,"none",["jackal","wolf","tiger"],{}],
    [5,7,"earth",["jackal","wolf","tiger"],{}],
    [8,9,"earth",["jackal","wolf","bat"],{}],
    [10,11,"wood",["bearling","wolf","bat"],{bearling:"黑风洞熊兵",wolf:"黑风山狼妖"}],
    [12,12,"earth",["bulllet","jackal","guard"],{}],
    [13,14,"none",["bee","tigerScout","windling"],{}],
    [15,16,"water",["fishling","stone","shade"],{fishling:"流沙河水妖",stone:"河底龟卒"}],
    [17,19,"wood",["guard","shade","stone"],{}],
    [20,20,"none",["disguised","bonelet","shade"],{}],
    [21,23,"wood",["wolf","leopard","shade"],{shade:"波月洞星侍"}],
    [24,25,"metal",["lotusling","stone","shade"],{}],
    [26,27,"earth",["guard","shade","stone"],{guard:"乌鸡国伪王亲兵",shade:"井底冤影"}],
    [28,31,"fire",["fireling","fireguard","jackal"],{}],
    [32,32,"water",["fishling","stone","shade"],{fishling:"黑水河虾兵",stone:"鼍龙河卫"}],
    [33,35,"earth",["tiger","guard","stone"],{guard:"车迟国道坛守卫"}],
    [36,38,"water",["fishling","shade","stone"],{fishling:"灵感水府鱼兵",stone:"冰河甲卒"}],
    [39,41,"metal",["bulllet","stone","guard"],{bulllet:"金兜洞牛兵",guard:"独角兕亲卫"}],
    [42,43,"water",["fishling","guard","shade"],{}],
    [44,44,"wood",["scorpionlet","spiderlet","shade"],{}],
    [45,46,"none",["disguised","shade","leopard"],{disguised:"六耳幻化猴兵"}],
    [47,49,"fire",["fireling","bulllet","jackal"],{bulllet:"积雷山牛兵"}],
    [50,51,"water",["fishling","guard","shade"],{fishling:"碧波潭水卒",guard:"九头虫亲卫"}],
    [52,52,"wood",["shade","stone","guard"],{shade:"荆棘岭树精"}],
    [53,54,"metal",["guard","shade","stone"],{guard:"小雷音寺黄眉亲卫"}],
    [55,55,"earth",["leopard","stone","shade"],{shade:"稀柿衕蟒影"}],
    [56,58,"fire",["leopard","fireling","wolf"],{fireling:"麒麟山金铃火卒"}],
    [59,60,"wood",["spiderlet","scorpionlet","shade"],{shade:"黄花观毒目侍"}],
    [61,64,"earth",["lionlet","leopard","guard"],{guard:"狮驼国妖兵"}],
    [65,66,"wood",["deerlet","guard","shade"],{guard:"比丘国妖卫"}],
    [67,69,"none",["bat","shade","guard"],{shade:"无底洞灯影"}],
    [70,70,"none",["guard","shade","jackal"],{guard:"灭法国巡卒"}],
    [71,71,"wood",["leopard","wolf","shade"],{shade:"隐雾山雾妖"}],
    [72,72,"earth",["guard","stone","shade"],{}],
    [73,75,"earth",["lionlet","guard","leopard"],{guard:"竹节山狮兵"}],
    [76,77,"water",["bulllet","fishling","stone"],{bulllet:"玄英洞犀兵",fishling:"青龙山寒水妖"}],
    [78,78,"none",["rabbitlet","shade","guard"],{shade:"月宫玉兔幻影"}],
    [79,81,"none",["guard","shade","fishling"],{}]
  ].map(([first,last,element,mobs,names])=>({first,last,element,mobs,names}));
  function themeForTrial(trial){return themes.find(t=>trial>=t.first&&trial<=t.last);}
  function sceneForTrial(trial){
    const n=trial.trial;
    if([15,16,32,36,37,38,42,43,50,51,76,77].includes(n))return "river";
    if([26,27,33,34,35,56,57,65,66,70,79].includes(n))return "city";
    if([47,48,49].includes(n))return "ember";
    if([45,46,67,68,69,71].includes(n))return "night";
    if([52,59,60,73,74,75].includes(n))return "forest";
    return trial.biome;
  }
  function elementForTrial(trial){return special[trial.trial]||bosses[trial.boss]||themeForTrial(trial.trial)?.element||biomes[trial.biome]||"none";}
  function elementForMob(type,stageElement){return mobs[type]||stageElement||"none";}
  function attackFactor(attacker,defender){
    if(!attacker||!defender||attacker==="none"||defender==="none"||attacker===defender)return 1;
    if(conquers[attacker]===defender)return 1.12;
    if(conquers[defender]===attacker)return .92;
    return 1;
  }
  // 地貌生养本命五行。只提供小幅续航和施法节奏，避免角色因关卡属性被迫重选。
  function nurtureForTrial(trial,heroElement){
    const land=typeof trial==="string"?trial:elementForTrial(trial);
    return land!=="none"&&generates[land]===heroElement;
  }
  // 每难都有相应地貌；玩家可自愿承担劫难。报酬按关结算，不叠加永久战力。
  const ordeals={
    wind:{name:"风沙迷眼",cost:"远程妖弹伤害 +12%",reward:"过关得 10 文",enemyProjectile:1.12,coins:10},
    fire:{name:"火路难行",cost:"受到的灼烧伤害 +20%",reward:"过关得 12 文",burn:1.2,coins:12},
    water:{name:"弱水牵衣",cost:"移动速度 -10%",reward:"过关得 10 文",move:.9,coins:10},
    wood:{name:"藤瘴缠身",cost:"小妖生命 +12%",reward:"过关得 12 文",mobHp:1.12,coins:12},
    metal:{name:"宝光压阵",cost:"妖王法术伤害 +10%",reward:"过关得 14 文",bossSpell:1.1,coins:14},
    earth:{name:"山重路险",cost:"小妖接触伤害 +12%",reward:"过关得 10 文",mobTouch:1.12,coins:10},
    plain:{name:"风餐露宿",cost:"小妖伤害 +8%",reward:"过关得 10 文",mobDamage:1.08,coins:10}
  };
  function ordealForTrial(trial){
    if(trial.trial===13)return ordeals.wind;
    if([31,47,48,49].includes(trial.trial))return ordeals.fire;
    if([15,32,36,37,38,42,51,77].includes(trial.trial))return ordeals.water;
    return ordeals[elementForTrial(trial)]||ordeals.plain;
  }
  const tactics={
    "寅将军":"先横移避开扑杀，再从侧面反击。",
    "黑熊精":"黑风环射前会近身冲撞；沿风弹间隙穿出。",
    "黄风怪":"风袋先承受伤害；破袋后风弹收束。留意黄沙扇形前摇。",
    "白骨精":"三副人形依次变招：先召骨傀，再放骨刺，最后铺开骨矛。",
    "黄袍怪":"星光先成扇形，再向四周散开；保持侧移。",
    "金角大王":"葫芦点名会在脚下画圈，离圈即可避开摄魂。",
    "银角大王":"净瓶点名后迅速离开原位置。",
    "红孩儿":"三昧真火留下火区；水行攻击更克火，走位避开持续灼烧。",
    "虎力大仙":"求雨法坛的符箓先环射后直落，穿过弹幕空隙。",
    "灵感大王":"水浪与冰箭交替袭来，冰面一侧留着可躲的间隙。",
    "青牛精":"金刚琢会短暂封住法宝；贴近时可躲开收宝。",
    "蝎子精":"倒马毒桩出手极快，远离尾钩的直线方向。",
    "六耳猕猴":"假身会换位并挥棍，记住移位前的金光位置。",
    "大鹏金翅雕":"俯冲前会在脚下出现羽影；闪避离开阴影。",
    "铁扇公主":"芭蕉扇吹出宽风阵；绕到侧面躲避。",
    "牛魔王":"本相冲锋速度很快；留好闪避，别贪最后一击。",
    "黄眉怪":"金铙音波环射时贴着空隙移动，莫站在正面。",
    "赛太岁":"紫金铃依次放烟、沙、火；听铃声辨认下一轮。",
    "百眼魔君":"毒目环射后还有直线光束，先穿过弹幕空隙。",
    "白鹿精":"鹿角飞矢会从正面与四周压来，先让出直线。",
    "金鼻白毛老鼠精":"洞灯一暗便换位，先找灯光再看弹幕。",
    "南山大王":"雾弹会使视野发暗，莫在浓雾中停步。",
    "黄狮精":"冲锋接钉耙扇击，等冲势过去再靠近。",
    "九灵元圣":"九口齐啸的环形声波间有缝隙，小狮围来时先清侧翼。",
    "辟寒大王":"冰弹过后脚下还会结寒区，离开圆圈再输出。",
    "玉兔精":"月影换位后会环射银光，追逐时别丢掉退路。"
  };
  const traits={
    tangseng:"金蝉慈悲：受击后短暂佛光护体；击破小妖有 10% 概率度化为护法，最多 2 名。",
    wukong:"烈焰连击：命中积攒火印，每层攻速 +4%；第五击爆出小范围火浪。火眼金睛对幻化妖邪伤害 +12%。",
    bajie:"厚土护体：生命高于 60% 时额外减伤 10%；击破小妖回复少量生命。",
    shaseng:"藤沙印记：命中使小妖迟缓，五层定身；持有护盾时伤害 +12%。",
    bailongma:"化龙逐日：移动积蓄潮势；化龙技能持续 5 秒，伤害 +25%、移速 +22%。"
  };
  window.XIYOU_SYSTEMS=Object.freeze({names,hero,biomes,mobs,conquers,generates,themeForTrial,sceneForTrial,elementForTrial,elementForMob,attackFactor,nurtureForTrial,ordeals,ordealForTrial,tactics,traits});
})();
