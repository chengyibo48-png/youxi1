"""Record alpha bounds only. Source PNGs remain unchanged."""
from pathlib import Path
from PIL import Image
import json
root=Path(__file__).resolve().parents[1]
cuts={
 'hero-rig':[[0,167,329,499,690,806,910,1020,1154,1384,1536]]*5,
 'weapons':[[0,291,550,793,1024,1340,1536],[0,271,540,800,1024,1340,1536],[0,287,549,797,1052,1313,1536],[0,287,549,798,1047,1305,1536],[0,283,552,804,1045,1307,1536]],
 'rooms':[[0,420,797,1140,1536],[0,405,795,1165,1536]],
 'enemy-rig':[[round(x*1536) for x in [0,.107,.219,.302,.386,.470,.553,.638,.734,1]]]*8,
}
result={}
for sheet,rows in cuts.items():
 image=Image.open(root/'assets/painterly'/f'{sheet}.png');w,h=image.size
 for row,xs in enumerate(rows):
  for col in range(len(xs)-1):
   x0=xs[col]+2;x1=xs[col+1]-2;y0=round(row*h/len(rows))+2;y1=round((row+1)*h/len(rows))-2
   alpha=image.getchannel('A').crop((x0,y0,x1,y1));box=alpha.point(lambda v:255 if v>40 else 0).getbbox()
   if box:
    a,b,c,d=box;result[f'{sheet}:{col}:{row}']=[x0+a,y0+b,c-a,d-b]
(root/'assets/painterly/regions.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(f'Recorded {len(result)} inspected sprite regions; PNGs unchanged.')
