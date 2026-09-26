// 房间选项只使用真实的背包、修行与战斗字段；显示和执行共用条件。
(() => {
  const option=(id,name,desc,run,check=()=>"",cost=0,visible=()=>true)=>({id,name,desc,run,check,cost,visible});
  function rotate(pool,count,history,random=Math.random){
    const ids=pool.map(item=>item.id),seen=Array.isArray(history)?history.filter(id=>ids.includes(id)):[];
    const picked=[];
    while(picked.length<Math.min(count,pool.length)){
      let available=pool.filter(item=>!seen.includes(item.id)&&!picked.includes(item));
      if(!available.length){seen.length=0;available=pool.filter(item=>!picked.includes(item));}
      const item=available[Math.floor(random()*available.length)];
      picked.push(item);seen.push(item.id);
    }
    return {ids:picked.map(item=>item.id),history:seen};
  }
  function build(c){
    const p=c.player,relic=c.relic,price=c.price;
    const heal=n=>{p.hp=Math.min(p.maxHp,p.hp+Math.ceil(p.maxHp*n));};
    const wounded=()=>p.hp>=p.maxHp?"生命已满":"";
    const cursed=()=>p.curse<=0?"当前没有心魔":"";
    const bagSpace=()=>p.relicBag.length>=p.relicCapacity?"法宝袋已满，请在下方整理":"";
    const guard=()=>p.shieldCharges>=3?"护盾已达 3 层上限":"";
    const cleanse=()=>{p.burnTime=0;p.poisonTime=0;p.slowTime=0;p.blindTime=0;};
    const afflicted=()=>!(p.burnTime>0||p.poisonTime>0||p.slowTime>0||p.blindTime>0)?"当前没有异常状态":"";
    const cleanseCurse=()=>{p.curse=Math.max(0,p.curse-1);};
    const armor=()=>p.armor>=.49?"减伤已达 49% 上限":"";
    const card=id=>c.upgrades.find(u=>u.id===id);
    function upgradeCheck(u){
      if(!u)return "当前角色没有此项修行";
      if((p.taken[u.id]||0)>=u.max)return "此项修行已达上限";
      const caps={might:[p.damage,2.8],tempo:[p.attackSpeed,2.4],guard:[p.armor,.49],crit:[p.crit,.65]};
      if(caps[u.id]&&caps[u.id][0]>=caps[u.id][1])return "对应属性已达上限";
      if(u.id==="haste"&&p.skillHaste<=.42||u.id==="dash"&&p.dashHaste<=.45)return "冷却缩减已达上限";
      return "";
    }
    const train=(id,name,upgradeId,cost)=>{
      const u=card(upgradeId);
      return option(id,name,u?.desc||"",()=>c.upgrade(u),()=>upgradeCheck(u),price(cost));
    };
    const treasure=(id,name,cost)=>option(id,`${name} · ${relic.name}`,`${relic.desc}；收入法宝袋，战斗时使用`,()=>c.storeRelic(relic.id),bagSpace,price(cost));
    const sacrifice=(id,name,desc,run,check=()=>"")=>option(id,name,`舍弃袋首「${c.relicName(p.relicBag[0])}」；${desc}`,()=>{p.relicBag.shift();run();},()=>!p.relicBag.length?"没有可舍弃的法宝":check(),0,()=>p.relicBag.length>0);
    const leave=option("leave","继续赶路","保留现有资源，离开此处",()=>{});
    const shrine=[
      option("rations","添置行粮","回复 20% 最大生命",()=>heal(.2),wounded,price(10)),
      treasure("shrine_relic","请领法宝",22),
      option("shrine_cleanse","焚香净心","移除 1 层心魔",cleanseCurse,cursed,price(14)),
      option("shrine_shield","求护行符","获得 1 层护盾，可抵挡一次伤害（上限 3 层）",()=>p.shieldCharges++,guard,price(12)),
      option("shrine_study","听土地讲经",`获得 ${16+Math.floor(c.tier)} 修为`,()=>c.addXp(16+Math.floor(c.tier))),
      option("shrine_alms","领取盘缠","获得 10 文铜钱",()=>c.addCoins(10)),
      option("shrine_water","饮净泉水","清除灼烧、中毒、迟缓与致盲",cleanse,afflicted),
      option("shrine_fragment","寻访散宝","获得 1 枚法宝碎片；满 3 枚且背包有空位时自动合成",()=>c.addFragments(1),()=>"",price(9)),
      train("shrine_stride","土地缩地诀","stride",20),
      train("shrine_magnet","聚灵小诀","magnet",18),
      train("shrine_guard","护身石符","guard",24),
      train("shrine_fortune","祈求福缘","fortune",25),
      sacrifice("shrine_sacrifice","舍宝修心","本局减伤增加 6 个百分点，上限 49%",()=>p.armor=Math.min(.49,p.armor+.06),armor),
      option("shrine_recover","吐纳调息","立即清空主动技能与闪避冷却",()=>{p.skillCd=0;p.dashCd=0;},()=>p.skillCd<=0&&p.dashCd<=0?"技能与闪避均已就绪":"")
    ];
    const shop=[
      option("food","旅途干粮","回复 30% 最大生命",()=>heal(.3),wounded,price(18)),
      treasure("shop_relic","购入法宝",30),
      option("incense","净心香","移除 1 层心魔",cleanseCurse,cursed,price(24)),
      train("weapon","磨砺随身兵器",`weapon_${c.hero}`,36),
      train("active","参悟主动技能",`active_${c.hero}`,34),
      train("vitality","护心金丹","vigor",30),
      train("damage","淬锋灵砂","might",32),
      train("tempo","疾攻符","tempo",30),
      train("armor","龙鳞软甲","guard",28),
      train("haste","真言抄本","haste",30),
      train("dash","踏云履","dash",26),
      train("regen","回春丹方","regen",36),
      train("boss","镇魔砥石","boss",32),
      train("magnet","聚灵佩","magnet",22),
      train("fortune","福缘钱","fortune",32),
      train("bag","御宝行囊","relic_master",42),
      train("relic_time","温养宝匣","relic",26),
      option("shield","护行金符","获得 1 层护盾（上限 3 层）",()=>p.shieldCharges++,guard,price(18)),
      option("fragment","残宝碎片","获得 2 枚法宝碎片；满 3 枚且背包有空位时自动合成",()=>c.addFragments(2),()=>"",price(18)),
      option("sutra","行脚经注",`获得 ${28+Math.floor(c.tier*2)} 修为`,()=>c.addXp(28+Math.floor(c.tier*2)),()=>"",price(20)),
      train("skill","秘传神通",c.skillId,40)
    ];
    const xp=n=>option("study","静心参悟",`获得 ${n} 修为`,()=>c.addXp(n));
    const money=n=>option("coins","收下谢礼",`获得 ${n} 文铜钱`,()=>c.addCoins(n));
    const event=(id,name,intro,choices,eligible=true)=>({id,name,intro,choices,eligible});
    const events=[
      event("bandits","拦路强盗","山径前刀光闪动，三名强人索要买路钱。",[
        option("fight","出手破阵",`迎战 3 名强盗，清场额外获得 ${18+Math.floor(c.tier)} 文；悟空使敌人生命降低 25%`,()=>c.battle(3,18+Math.floor(c.tier))),
        option("pay","破财消灾","付清买路钱，安全通过",()=>{},()=>"",price(c.hero==="tangseng"?6:12)),
        option("persuade","以慈悲劝化",`获得 15 文；${c.hero==="tangseng"?"唐僧免受伤害":"失去 12% 当前生命（不致死）"}`,()=>{if(c.hero!=="tangseng")p.hp=Math.max(1,p.hp-Math.ceil(p.hp*.12));c.addCoins(15);})
      ]),
      event("old_man","山中老叟","老叟教你衡量行囊，也讲起护身的道理。",[
        sacrifice("sacrifice","舍宝修心","本局减伤增加 6 个百分点，上限 49%",()=>p.armor=Math.min(.49,p.armor+.06),armor),
        option("listen","听一席话","回复 12 生命并获得 10 修为",()=>{p.hp=Math.min(p.maxHp,p.hp+12);c.addXp(10);}),
        option("help","替老叟挑柴","获得 14 文铜钱",()=>c.addCoins(14))
      ]),
      event("spring","山间灵泉","泉水绕过青石，岸边有道人留下的调息口诀。",[
        option("drink","饮泉疗伤","回复 24% 最大生命，并清除全部异常状态",()=>{heal(.24);cleanse();},()=>wounded()&&afflicted()?"生命已满且没有异常状态":""),
        xp(22),train("learn","以盘缠换口诀","regen",24)
      ]),
      event("smith","云游铁匠","铁匠借山火架起小炉，愿为西行人修整兵器。",[
        train("forge","重锻兵器",`weapon_${c.hero}`,24),
        option("scraps","收集炉边残宝","获得 1 枚法宝碎片和 8 文铜钱",()=>{c.addFragments(1);c.addCoins(8);}),
        train("armor","锻造护甲","guard",20)
      ]),
      event("pilgrim","迷路香客","香客奉上薄礼，盼你指一条平安路。",[
        money(18),xp(26),option("escort","护送越岭",`迎战 4 名妖怪；清场额外获得 ${25+Math.floor(c.tier)} 文`,()=>c.battle(4,25+Math.floor(c.tier)))
      ]),
      event("cache","古道封匣","一只蒙尘宝匣压着半卷经书，封口的符纸仍有余温。",[
        treasure("open","破符取宝",0),money(20),xp(25)
      ]),
      event("monk","行脚僧人","僧人展开发黄经卷，邀你共参一段降魔真言。",[
        option("purify","共诵净心经","移除 1 层心魔，并获得 12 修为",()=>{cleanseCurse();c.addXp(12);},cursed),
        train("haste","抄录真言","haste",18),xp(24)
      ]),
      event("herbs","采药童子","药童背篓里既有灵药，也有尚未辨明的异草。",[
        option("medicine","买下灵药","回复 45% 最大生命",()=>heal(.45),wounded,price(14)),
        option("taste","试服异草","生命上限 +12，并回复 12；心魔 +1（受到伤害增加 18%）",()=>{p.maxHp+=12;p.hp=Math.min(p.maxHp,p.hp+12);p.curse++;}),
        option("sort","帮忙辨草","获得 12 文与 10 修为",()=>{c.addCoins(12);c.addXp(10);})
      ]),
      event("echo","石壁回声","石壁映出随身法宝的影子，似乎愿以旧物换新缘。",[
        sacrifice("trade","以宝换缘","获得 28 文铜钱与 15 修为",()=>{c.addCoins(28);c.addXp(15);}),
        train("bag","悟御宝之法","relic_master",30),xp(20)
      ]),
      event("training","护路武师","武师在路边演练步法，愿指点有心的行者。",[
        train("stride","学踏云步","stride",16),train("skill","请教主动神通",`active_${c.hero}`,24),
        option("spar","比武试炼",`迎战 3 名对手；清场额外获得 ${20+Math.floor(c.tier)} 文`,()=>c.battle(3,20+Math.floor(c.tier)))
      ]),
      event("fruit","人参果园","清风明月守着果园，枝间传来诱人的清香。",[
        option("steal","偷食人参果","生命上限 +16，回复 30% 最大生命；心魔 +1（受到伤害增加 18%）",()=>{p.maxHp+=16;heal(.3);p.curse++;}),
        option("ask","向清风明月问路","获得 16 文和 12 修为",()=>{c.addCoins(16);c.addXp(12);}),
        option("tend","帮助照料果树","回复 18% 最大生命并获得 15 修为",()=>{heal(.18);c.addXp(15);})
      ],c.place.includes("五庄观")),
      event("temple_fire","禅院夜火","禅房火光骤起，经卷与香客都需要照应。",[
        option("rescue","护住经卷","失去 12% 当前生命（不致死），获得 24 文与 12 修为",()=>{p.hp=Math.max(1,p.hp-Math.ceil(p.hp*.12));c.addCoins(24);c.addXp(12);}),
        option("wait","静候天明","回复 12% 最大生命并获得 10 修为",()=>{heal(.12);c.addXp(10);}),
        option("guide","引香客避火","获得 1 层护盾（上限 3）与 8 文",()=>{p.shieldCharges=Math.min(3,p.shieldCharges+1);c.addCoins(8);})
      ],c.place.includes("观音禅院"))
    ];
    const reward=[treasure("chest","开启宝匣",0),money(18+Math.floor(c.tier))];
    const guanyin=[option("purify","净除业障","移除全部心魔",()=>p.curse=0,cursed),option("heal","莲光疗伤","回复全部生命",()=>p.hp=p.maxHp,wounded),treasure("gift","赐下法宝",0),xp(24)];
    const rest=[
      option("rest","整顿行装",`回复 ${c.restHeal*100}% 最大生命，清除全部异常状态`,()=>{heal(c.restHeal);cleanse();},()=>wounded()&&afflicted()?"生命已满且没有异常状态":""),
      option("elixir","炼制护心丹","回复 20% 最大生命，获得 1 层护盾（上限 3）",()=>{heal(.2);p.shieldCharges=Math.min(3,p.shieldCharges+1);},()=>wounded()&&guard()?"生命与护盾均已满":"",price(20)),xp(18+Math.floor(c.tier*2))
    ];
    return {shrine,shop,events,reward,guanyin,rest,leave};
  }
  window.XIYOU_ROOM_CONTENT={build,rotate};
})();
