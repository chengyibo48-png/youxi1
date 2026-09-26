// 八十一难保留为原著次序的故事节点；实际闯关按三十七段取经地点组织。
(() => {
  const route=[
    ["双叉岭",1,7],["两界山",8,8],["鹰愁涧",9,9],["观音禅院与黑风山",10,11],
    ["高老庄",12,12],["黄风岭",13,14],["流沙河",15,16],["万寿山五庄观",17,19],
    ["白虎岭",20,20],["黑松林与宝象国",21,23],["平顶山莲花洞",24,25],
    ["乌鸡国",26,27],["枯松涧火云洞",28,31],["黑水河",32,32],
    ["车迟国",33,35],["通天河",36,38],["金兜山",39,41],["子母河与西梁国",42,44],
    ["真假美猴王",45,46],["火焰山",47,49],["祭赛国与碧波潭",50,51],
    ["荆棘岭",52,52],["小雷音寺",53,54],["驼罗庄",55,55],
    ["朱紫国与麒麟山",56,58],["盘丝岭",59,59],["黄花观",60,60],
    ["狮驼岭与狮驼国",61,64],["比丘国",65,66],["镇海禅林寺与无底洞",67,69],
    ["灭法国",70,70],["隐雾山",71,71],["凤仙郡",72,72],
    ["玉华州与竹节山",73,75],["金平府与玄英洞",76,77],["天竺国",78,78],
    ["凌云渡与归途",79,81]
  ];
  const trials=window.XIYOU_JOURNEY81.trials;
  const systems=window.XIYOU_SYSTEMS;
  const chapters=route.map(([name,firstTrial,lastTrial],index)=>{
    const sourceTrials=trials.slice(firstTrial-1,lastTrial);
    const bossRefs=sourceTrials.filter(trial=>trial.boss);
    const focus=bossRefs.at(-1)||sourceTrials.at(-1);
    const encounter=sourceTrials.find(trial=>trial.kind==="combat"||trial.kind==="boss")||focus;
    const theme=systems.themeForTrial(encounter.trial);
    const scene=systems.sceneForTrial(encounter);
    return {
      ...focus,chapterIndex:index+1,firstTrial,lastTrial,sourceTrials,bossRefs,
      trial:firstTrial,trialName:name,place:name,kind:bossRefs.length?"boss":"combat",
      story:sourceTrials.map(trial=>trial.story).join(" "),
      bridge:`上一段路已过，师徒来到${name}。`,
      biome:scene,mobs:theme?.mobs||encounter.mobs,mobNames:theme?.names||{},
      element:systems.elementForTrial(encounter),ordeal:systems.ordealForTrial(encounter),
      // 三十七章维持旧版约二十档的强度跨度，避免缩短关数后属性突然翻倍。
      powerTier:Math.round(index*19/36)
    };
  });
  if(chapters.length!==37||chapters[0].firstTrial!==1||chapters.at(-1).lastTrial!==81||
    chapters.some((chapter,i)=>i&&chapter.firstTrial!==chapters[i-1].lastTrial+1))
    throw Error("取经章节未完整覆盖八十一难");
  window.XIYOU_CHAPTERS={chapters,route,chapterForTrial:number=>chapters.findIndex(chapter=>number>=chapter.firstTrial&&number<=chapter.lastTrial)};
})();
