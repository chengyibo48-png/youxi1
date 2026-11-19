from pathlib import Path
import hashlib,json,math
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
PALETTE={'weapons':'#dcba69','skills':'#78b9b3','ultimates':'#eaa25f','relics':'#9dc697','talents':'#b899d2','ui':'#dbca8c'}
def glyph(d,k,c):
 light='#ffedbf';ink='#203735'
 def line(points,width=2,color=None):d.line(points,fill=color or c,width=width)
 if k=='mirror':d.ellipse((8,5,24,21),fill=c,outline=light,width=2);line((16,21,16,27),3)
 elif k=='lamp':d.polygon([(7,15),(25,15),(21,21),(11,21)],fill=c);line((16,21,16,26),3);line((10,27,22,27),2);d.polygon([(16,5),(13,12),(19,12)],fill=light)
 elif k=='bead':d.ellipse((7,7,25,25),fill=c,outline=light,width=2);d.rectangle((11,10,14,13),fill=light)
 elif k=='pill':d.ellipse((7,8,25,24),fill=c,outline=light);line((16,9,16,23),2,ink)
 elif k=='fruit':d.ellipse((9,10,23,26),fill=c);line((16,10,18,5));line((18,6,24,6),2);d.point((13,15),fill=light)
 elif k=='gourd':d.ellipse((11,6,21,15),fill=c);d.ellipse((8,13,24,26),fill=c);line((12,6,20,6),2,light);line((10,17,10,22),2,light)
 elif k=='bottle':d.rectangle((13,5,19,14),fill=c);d.ellipse((9,12,23,26),fill=c);line((12,5,20,5),2,light);line((11,17,11,22),2,light)
 elif k in ['ring','orbit','return']:
  d.arc((6,6,26,26),25,330 if k=='return' else 359,fill=c,width=3)
  if k=='return':d.polygon([(24,6),(28,14),(20,11)],fill=light)
  if k=='orbit':d.rectangle((23,13,27,17),fill=light)
 elif k=='book':d.rectangle((6,6,25,26),fill=c,outline=light);line((9,7,9,25),2,ink);line((13,12,22,12),2,ink);line((13,17,22,17),2,ink)
 elif k=='fan':d.pieslice((4,4,28,27),190,350,fill=c,outline=light);line((16,16,16,27),2);line((9,9,16,17),1,light);line((23,9,16,17),1,light)
 elif k=='pagoda':
  for y,w in [(8,4),(13,7),(18,10),(23,12)]:d.polygon([(16,y-4),(16-w,y),(16+w,y)],fill=c);line((16-w+2,y+2,16+w-2,y+2),1,light)
 elif k=='needles':
  for dx in [-5,0,5]:line((10+dx,25,22+dx,6),1);d.point((22+dx,6),fill=light)
 elif k=='rope':d.arc((7,6,24,24),40,325,fill=c,width=3);line((13,25,21,20),3);line((21,20,26,26),2,light)
 elif k=='scroll':d.rectangle((9,6,23,25),fill=c);line((7,5,25,5),3,light);line((7,26,25,26),3,light);line((12,10,19,21),2,ink);line((12,18,21,13),2,ink)
 elif k=='bell':d.pieslice((8,6,24,28),180,360,fill=c);d.rectangle((8,14,24,22),fill=c);line((6,23,26,23),2,light);d.rectangle((15,24,17,27),fill=light)
 elif k=='bowl':d.pieslice((5,7,27,28),0,180,fill=c,outline=light);line((5,17,27,17),2,light)
 elif k=='banner':line((9,5,9,27),2,light);d.polygon([(10,6),(26,6),(22,13),(26,21),(10,21)],fill=c);line((13,9,20,17),1,ink)
 elif k in ['burn','fire','breath']:d.polygon([(16,5),(19,13),(23,10),(25,22),(19,27),(11,25),(7,19),(12,12),(12,19)],fill=c);d.polygon([(16,14),(20,22),(15,25),(12,21)],fill=light)
 elif k=='frost':
  for a in [0,math.pi/3,math.pi*2/3]:line((16-math.cos(a)*10,16-math.sin(a)*10,16+math.cos(a)*10,16+math.sin(a)*10))
 elif k=='chain':d.polygon([(18,5),(9,18),(16,18),(13,27),(24,13),(17,13)],fill=c)
 elif k=='shield':d.polygon([(7,8),(16,5),(25,8),(23,21),(16,27),(9,21)],fill=c);line((16,8,16,23),2,light)
 elif k=='heal':d.rectangle((13,6,19,26),fill=c);d.rectangle((6,13,26,19),fill=c)
 elif k=='coin':d.ellipse((6,6,26,26),fill=c,outline=light,width=2);d.rectangle((13,13,19,19),fill=ink)
 elif k=='split':
  for y in [7,16,25]:line((7,16,23,y));d.rectangle((22,y-2,26,y+2),fill=light)
 elif k=='dash':
  for y in [9,16,23]:line((6,y,16,y))
  d.polygon([(18,6),(26,16),(18,26),(22,16)],fill=light)
 elif k=='summon':
  for xx,yy in [(10,12),(21,10)]:d.ellipse((xx-3,yy-5,xx+3,yy+1),fill=c);d.polygon([(xx,yy),(xx-5,yy+11),(xx+5,yy+11)],fill=c)
 elif k=='beam':line((5,26,26,5),4);line((5,26,26,5),1,light);line((18,6,26,14),2,light)
 elif k=='mark':d.ellipse((5,10,27,22),outline=c,width=2);d.ellipse((12,10,20,22),fill=c);d.rectangle((15,13,17,18),fill=light)
 elif k=='field':d.ellipse((5,9,27,24),outline=c,width=2);line((7,16,25,16));line((16,7,16,27));d.rectangle((13,13,19,19),fill=light)
 elif k=='wave':
  for y in [10,17,24]:line([(x,y+int(math.sin(x*.45)*2)) for x in range(5,28)],2)
 elif k=='poison':d.polygon([(16,5),(25,20),(22,26),(10,26),(7,20)],fill=c);d.ellipse((12,17,15,20),fill=ink);d.ellipse((18,17,21,20),fill=ink)
 elif k=='sword':line((8,25,23,6),3);line((9,18,17,24),3,light);d.polygon([(23,6),(17,8),(22,12)],fill=light)
 else:d.polygon([(16,5),(26,16),(16,27),(6,16)],fill=c);d.rectangle((12,12,20,20),fill=ink);line((16,9,16,23),1,light)
def semantic(effect):
 mapping={'crit':'mark','regen':'heal','waterguard':'bead','slow':'pill','maxhp':'fruit','gourd':'gourd','barrier':'ring','reset':'book','wind':'fan','pagoda':'pagoda','needles':'needles','root':'rope','blink':'scroll','thunder':'chain','purify':'bell','resource':'coin','summon':'summon','avatars':'summon','convert':'summon','freeze':'frost','dash':'dash','lunge':'dash','charge':'dash','evade':'dash','pursue':'dash','beam':'beam','giant':'sword','mark':'mark','sanctuary':'field','counter':'shield','pull':'rope','slam':'sword','quake':'field','quakes':'field','sand':'field','sandstorm':'field','sandburst':'wave','tide':'wave','wave':'wave','waterwall':'wave','dragon':'wave','dragonflight':'wave','detonate':'burn','purification':'heal','chant':'bell','marshal':'shield','health':'heal','weapon':'sword','skill':'beam','relic':'bottle','talent':'scroll'}
 if effect in mapping:return mapping[effect]
 for names,k in [(['burn','fire','heavy'],'burn'),(['frost','ice'],'frost'),(['chain','thunder'],'chain'),(['shield','guard','armor','goldbody'],'shield'),(['heal','hp','regen'],'heal'),(['coin','salvage','resource','econom'],'coin'),(['split','fan','fork'],'split'),(['return','bounce'],'return'),(['dash','speed','haste','echo'],'dash'),(['summon'],'summon'),(['field','domain','sand'],'field'),(['mark','crit'],'mark'),(['poison'],'poison')]:
  if any(v in effect for v in names):return k
 return 'rune'
def main():
 items=[]
 for table in ['weapons','skills','ultimates','relics','talents']:
  for x in json.loads((ROOT/'data'/f'{table}.json').read_text(encoding='utf-8')):items.append((table,x))
 for k in ['coin','health','resource','dash','weapon','skill','relic','talent']:items.append(('ui',{'id':'ui_'+k,'name':k,'effect':k}))
 atlas=Image.new('RGBA',(512,math.ceil(len(items)/16)*32));manifest={}
 relic_shapes=['mirror','lamp','bead','pill','fruit','gourd','bottle','ring','book','fan','pagoda','needles','rope','scroll','chain','bell','bowl','banner']
 for n,(category,x) in enumerate(items):
  tile=Image.new('RGBA',(32,32));d=ImageDraw.Draw(tile);c=PALETTE[category]
  d.rectangle((2,2,29,29),fill='#203735',outline='#6e806a');d.rectangle((4,4,27,27),outline='#40574b')
  k={'slash':'sword','bolt':'beam','field':'field','orbit':'orbit','return':'return'}.get(x.get('mode',''),semantic(x.get('effect','')))
  if category=='relics':k=relic_shapes[int(x['id'].split('_')[-1])]
  glyph(d,k,c)
  seed=int(hashlib.sha256(x['id'].encode()).hexdigest()[:8],16)
  for bit in range(5):
   if seed&(1<<bit):d.point((7+bit*4,28),fill='#ffedbf')
  xx=n%16*32;yy=n//16*32;atlas.alpha_composite(tile,(xx,yy));manifest[x['id']]={'rect':[xx,yy,32,32],'category':category,'name':x['name'],'glyph':k}
 output=ROOT/'assets/ui';output.mkdir(exist_ok=True);atlas.save(output/'item-icons.png');(output/'item-icons.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
 print('Pixel atlas:',len(manifest),'entries;',len(set(x['glyph'] for x in manifest.values())),'semantic silhouettes')
if __name__=='__main__':main()
