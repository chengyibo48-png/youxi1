"""Authored pose directions for all existing boss actions, not new hand-painted art."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
# Rotation, root lift, left/right upper arm, left/right forearm, head tilt, implement roll.
POSES={
 'charge':([-.22,8,-.5,.8,.3,-.6,-.08,-.2],[.34,-6,1,-.9,-.2,.6,.06,.3]),
 'slam':([-.2,-8,-1.8,-1.5,.7,.5,-.12,-.5],[.42,9,.9,1.2,-.5,-.7,.15,.6]),
 'fan':([-.14,-3,-.6,-1.2,.4,.8,-.1,-.7],[.2,-1,.5,1.1,-.3,-.6,.04,.9]),
 'wave':([-.12,-4,-1.2,-.7,.5,.2,-.06,-.2],[.18,2,.7,.9,-.3,-.5,.04,.3]),
 'burst':([-.08,-5,-1.5,-1.5,.8,.8,-.1,-.1],[.05,-1,.9,.9,-.6,-.6,.05,.2]),
 'fire':([-.12,-2,-.7,-1.1,.4,.6,-.14,-.3],[.27,3,.3,.8,-.3,-.4,.12,.35]),
 'ice':([-.04,-4,-1.4,-.8,.8,.5,-.06,-.1],[.08,1,.9,.4,-.5,-.3,.05,.2]),
 'poison':([.08,5,-.9,.2,.4,-.4,-.04,-.2],[-.18,-2,.6,-.7,-.3,.7,.08,.3]),
 'web':([-.1,4,-1.2,-1.6,.8,.7,-.08,-.1],[.14,1,.8,1.1,-.6,-.8,.07,.3]),
 'laser':([-.15,-3,-1.2,-.3,.8,.1,-.15,-.15],[.16,-2,.4,-.8,-.3,.5,.16,.3]),
 'gourd':([-.14,-1,-.4,-1.1,.5,.8,-.12,-.6],[.08,2,-.7,.5,.3,-.5,.1,.7]),
 'gust':([-.23,-4,-.8,-1.5,.3,.8,-.1,-.9],[.32,1,.6,1.3,-.4,-.6,.08,1.1]),
 'illusion':([-.07,-6,-1.5,-.8,.7,.4,-.1,-.2],[.1,-2,.6,.2,-.4,-.2,.07,.2]),
 'mirror':([-.17,-4,-1.1,.3,.6,-.5,-.1,-.5],[.22,-3,.6,-.7,-.4,.6,.08,.5]),
 'blink':([.1,7,-.5,-.9,.3,.7,-.12,-.3],[-.23,-7,.9,.2,-.6,-.2,.1,.3]),
 'fog':([-.05,-2,-1.1,-1,.6,.6,-.08,-.1],[.06,-3,.3,.3,-.2,-.2,.07,.1]),
 'roar':([-.2,-5,-.8,-.8,.5,.5,-.2,-.3],[.23,2,.7,.7,-.4,-.4,.24,.35]),
 'summon':([-.05,-3,-1.4,-1.1,.7,.6,-.08,-.2],[.09,-2,.7,.9,-.5,-.7,.08,.3]),
 'ward':([-.08,-1,-.8,-1.2,.7,.8,-.08,-.2],[.04,-2,-.4,.2,.3,-.4,.06,.2])}
# Explicit identity weighting: force, lead hand, recoil, tail and wing gesture.
IDENTITIES=[
 ('虎踞扑猎',1.2,.7,1.0,.7,0),('熊掌压身',1.45,.3,1.3,0,0),
 ('三昧妖风',.85,1.4,.75,.5,0),('白骨引魂',.65,-1.1,.6,0,0),
 ('黄袍长臂',1.0,1.0,.9,.3,0),('金角举葫',.85,1.2,.7,0,0),
 ('银角低引',.75,-1.1,.8,0,0),('赤子吐焰',.8,.65,1.0,0,0),
 ('虎力结印',1.1,-.7,.85,.4,0),('鱼王逐潮',1.15,.9,1.1,1.0,0),
 ('青牛沉肩',1.35,.5,1.25,.4,0),('蝎尾蓄针',.7,-1.2,.8,1.7,0),
 ('六耳逆势',1.05,-1.4,.75,.7,0),('铁扇展袖',.7,1.6,.7,0,0),
 ('牛魔踏阵',1.65,1.0,1.35,.8,0),('黄眉纳袋',.8,-.6,.85,0,0),
 ('犼王弓背',1.15,.7,1.1,.9,0),('蜈蚣百手',.85,-.9,.7,1.4,0),
 ('金鹏展翼',1.0,1.4,.65,.3,1.3),('白鹿斜步',.8,-.5,.7,.5,0),
 ('地涌缩影',.55,-1.0,.55,.6,0),('南山伏猎',1.0,.8,.9,.7,0),
 ('青狮昂首',1.3,.6,1.2,.8,0),('九灵群首',1.05,-.4,.9,.4,0),
 ('犀王横角',1.4,1.2,1.25,.5,0),('玉兔轻跃',.6,-1.3,.55,.6,0)]

bosses=json.loads((ROOT/'data/bosses.json').read_text(encoding='utf-8-sig'))
result={}
for index,boss in enumerate(bosses):
 language,force,lead,recoil,tail,wing=IDENTITIES[index]
 actions={}
 for action in dict.fromkeys(boss['phase_one']+boss['phase_two']+boss['phase_three']):
  windup,release=POSES[action]
  def adjusted(values,release=False):
   out=[round(v*(recoil if release else force),4) for v in values]
   out[2]*=1+lead*.18;out[3]*=1-lead*.18
   out[4]*=1-lead*.15;out[5]*=1+lead*.15
   return [round(v,4) for v in out]
  actions[action]={'keys':[[0,[0]*8],[.42,adjusted(windup)],[.58,adjusted(release,True)],[1,[0]*8]],
                   'tail':tail,'wing':wing,'source':'authored skeletal choreography; full independent painted sequence pending'}
 result[boss['id']]={'name':boss['name'],'language':language,'actions':actions}
(ROOT/'data/boss_choreography_v11.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'bosses':len(result),'action_sequences':sum(len(p['actions']) for p in result.values())}))
