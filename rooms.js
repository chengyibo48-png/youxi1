(() => {
  const size=6;
  const templates={
    combat:{name:"妖氛隘口",mark:"战",risk:2,intro:"前方妖风渐起，隐隐有怪啸之声，定是有邪祟在此盘踞。"},
    elite:{name:"妖将营寨",mark:"将",risk:3,intro:"寨门紧闭，妖气凝重，守在此处的定是妖王手下的得力头目。"},
    shop:{name:"珍奇货肆",mark:"商",risk:0,intro:"货郎挑担立于路旁，架上琳琅满目，似有不少降妖的好物。"},
    event:{name:"奇遇岔口",mark:"奇",risk:1,intro:"前路分作两道，隐隐各有光影人声，不知哪一边是机缘，哪一边是劫难。"},
    rest:{name:"歇脚丹房",mark:"息",risk:0,intro:"室内丹炉温着，蒲团整洁，正好歇脚片刻，调养精神。"},
    reward:{name:"藏宝密室",mark:"宝",risk:0,intro:"石门半掩，宝光隐约透出，想来是此间主人藏珍的密室。"},
    boss:{name:"妖王正殿",mark:"王",risk:3,intro:"妖王高坐台上，妖兵分列两侧，这一关的正主，终于现身了。"},
    guanyin:{name:"观音点化台",mark:"愿",risk:0,intro:"莲光轻落，观音化身在岔路等候。此处可求一桩济厄之缘。"},
    shrine:{name:"土地神龛",mark:"土",risk:0,intro:"土地神自石龛现身，递来药草，也肯说说前路妖王的门道。"}
  };
  const variants={
    combat:{forest:"荒林妖径",cave:"洞岔妖巢",desert:"戈壁妖寨"},
    elite:{grave:"白骨校尉营",ember:"火云亲卫营",forest:"黑风先锋寨"},
    shop:{river:"龙宫武库",temple:"禅院法器阁",cave:"妖窟宝货房"},
    rest:{temple:"禅院净室",wild:"山神庙",forest:"山神庙",cave:"密室调息处"},
    reward:{river:"东海藏宝库",cave:"妖王宝库"},
    event:{temple:"禅院后门小径"},
    boss:{grave:"白骨洞主殿",ember:"芭蕉洞正殿",cave:"妖王洞府正殿"}
  };
  function describe(chapter,room){
    const type=room.type,place=chapter?.place||"";
    let name=variants[type]?.[chapter?.biome]||templates[type].name;
    if(type==="event"&&place.includes("五庄观"))name="人参果园岔路";
    if(type==="shop"&&place.includes("金兜山"))name="老君丹房旁货柜";
    if(type==="shop"&&place.includes("五庄观"))name="五庄观丹房货柜";
    if(type==="rest"&&place.includes("五庄观"))name="五庄观丹房";
    if(type==="rest"&&place.includes("金兜山"))name="太上老君炼丹房";
    if(type==="boss"&&place.includes("莲花洞"))name="莲花洞金銮殿";
    if(type==="boss"&&place.includes("火焰山"))name="芭蕉洞正殿";
    return {...templates[type],name};
  }
  const key=(x,y)=>x+","+y;
  const rng=seed=>{let state=seed>>>0;return ()=>((state=(Math.imul(state,1664525)+1013904223)>>>0)/4294967296);};
  const mixSeed=(stage,attempt)=>{let seed=(stage+1)^Math.imul(attempt+1,0x9e3779b9);seed=Math.imul(seed^(seed>>>16),0x85ebca6b);seed=Math.imul(seed^(seed>>>13),0xc2b2ae35);return (seed^(seed>>>16))>>>0;};
  function validate(plan,limits={}){
    if(!plan||!Array.isArray(plan.rooms)||!Array.isArray(plan.main)||plan.main.length<6||plan.main.length>8)return false;
    const byId=new Map(plan.rooms.map(r=>[r.id,r]));
    if(byId.size!==plan.rooms.length||new Set(plan.rooms.map(r=>key(r.x,r.y))).size!==plan.rooms.length)return false;
    const types=plan.main.map(id=>byId.get(id)?.type),battle=types.filter(type=>["combat","elite","boss"].includes(type)).length;
    if(types[0]!=="combat"||!["boss","combat"].includes(types.at(-1))||battle<5||battle<=types.length/2)return false;
    if(types.filter(type=>type==="shrine").length!==1||types.filter(type=>type==="elite").length!==1||types.filter(type=>type==="boss").length>1)return false;
    if(types.filter(type=>["shop","event","rest","reward","guanyin"].includes(type)).length>2)return false;
    for(const room of plan.rooms){
      if(!templates[room.type]||room.x<0||room.x>=size||room.y<0||room.y>=size)return false;
      if(room.links.some(id=>!byId.has(id)||!byId.get(id).links.includes(room.id)||Math.abs(byId.get(id).x-room.x)+Math.abs(byId.get(id).y-room.y)!==1))return false;
    }
    for(let i=1;i<plan.main.length;i++)if(!byId.get(plan.main[i-1]).links.includes(plan.main[i]))return false;
    const seen=new Set([0]),stack=[0];while(stack.length)for(const id of byId.get(stack.pop()).links)if(!seen.has(id)){seen.add(id);stack.push(id);}
    const risk=plan.main.reduce((n,id)=>n+templates[byId.get(id).type].risk,0);
    return seen.size===plan.rooms.length&&risk<=(limits.maxRisk??18);
  }
  function weightedOptional(random,chapter,used){
    const place=chapter?.place||"";
    const weights=[
      ["shop",place.includes("龙")||place.includes("金兜")?1.7:1],
      ["event",place.includes("五庄观")||place.includes("观音禅院")?1.8:1.15],
      ["rest",1.1],
      ["reward",1]
    ].filter(([type])=>!used.has(type));
    let roll=random()*weights.reduce((sum,[,weight])=>sum+weight,0);
    for(const [type,weight] of weights){roll-=weight;if(roll<=0)return type;}
    return weights.at(-1)[0];
  }
  function routeTypes(stage,random){
    const chapter=window.XIYOU_CHAPTERS?.chapters?.[stage];
    // 五间战斗房为主线：首房、两间普通战、一间精英战和结尾战。
    // 商店、奇遇、休息、宝箱只作为概率插入的支路节点。
    const middle=["combat","combat","elite","shrine"];
    const countRoll=random(),optionalCount=countRoll<.25?0:countRoll<.8?1:2;
    const used=new Set();
    for(let i=0;i<optionalCount;i++){
      const rare=random()<((chapter?.bossRefs?.length||0)>1||stage>=25?.13:.06);
      const type=rare&&!used.has("guanyin")?"guanyin":weightedOptional(random,chapter,used);
      used.add(type);middle.push(type);
    }
    for(let i=middle.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[middle[i],middle[j]]=[middle[j],middle[i]];}
    return ["combat",...middle,chapter?.bossRefs?.length?"boss":"combat"];
  }
  function generate(stage,limits={}){
    for(let attempt=0;attempt<256;attempt++){
      const random=rng(mixSeed(stage,attempt)),rooms=[],main=[],occupied=new Set();
      const add=(x,y,type)=>{const r={id:rooms.length,x,y,type,links:[]};rooms.push(r);main.push(r.id);occupied.add(key(x,y));return r;};
      let current=add(2,2,"combat"),valid=true;
      const types=routeTypes(stage,random).slice(1);
      for(const type of types){
        const choices=[[1,0],[-1,0],[0,1],[0,-1]].map(([dx,dy])=>({x:current.x+dx,y:current.y+dy})).filter(p=>p.x>=0&&p.x<size&&p.y>=0&&p.y<size&&!occupied.has(key(p.x,p.y)));
        if(!choices.length){valid=false;break;}
        const p=choices[Math.floor(random()*choices.length)],next=add(p.x,p.y,type);current.links.push(next.id);next.links.push(current.id);current=next;
      }
      const plan={rooms,main};if(valid&&validate(plan,limits))return plan;
    }
    throw Error("无法生成连通且资源充足的房间路线");
  }
  window.XIYOU_ROOMS={generate,validate,templates,describe,size};
})();
