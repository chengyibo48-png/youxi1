extends RefCounted
const COLORS={"wukong":"e0ba57","tangseng":"bd5943","bajie":"a98458","shaseng":"89a9a6","bailongma":"8ed8ef"}
var clone_rig=preload("res://scripts/layered_rig.gd").new()

func legacy_draw_seals(canvas: CanvasItem, seals: Array, clock: float) -> void:
 for seal in seals:
  var p: Vector2=seal.pos;var r: float=seal.radius
  canvas.draw_arc(p,r,0,TAU,40,Color("a54e3e",.6),2,true)
  canvas.draw_rect(Rect2(p-Vector2(14,14),Vector2(28,28)),Color("ba5644",.35),false,3)
  for i in 4:
   var d: Vector2=Vector2.RIGHT.rotated(i*PI*.5)
   canvas.draw_line(p+d*7,p+d*20,Color("e4c383",.75),2,true)

func draw_projectile(canvas: CanvasItem,shot: Dictionary) -> bool:
 if preload("res://scripts/weapon_visual.gd").projectile(canvas,shot):return true
 if not shot.get("friendly",true):return false
 var W=preload("res://scripts/weapon_effects.gd")
 var color: Color=Color(COLORS.get(shot.get("role","wukong"),"cbb279"))
 var type: String=shot.get("visual","")
 var ids: Dictionary={"crescent":"shaseng_w1","sword":"bailongma_w4","bead":"tangseng_w3"}
 if ids.has(type):preload("res://scripts/painterly_assets.gd").stamp(canvas,preload("res://scripts/painterly_assets.gd").weapon(ids[type]),shot.pos,Vector2(22,13),shot.dir.angle(),.9)
 else:W.shard(canvas,shot.pos,6,shot.dir.angle(),color)
 W.ribbon(canvas,PackedVector2Array([shot.pos-shot.dir*17,shot.pos-shot.dir*8,shot.pos]),1.5,Color(color,.45))
 return true

func legacy_draw(canvas: CanvasItem, v: Dictionary, reduced_flash: bool=false) -> void:
 if v.effect=="ultimate_stage":
  preload("res://scripts/ultimate_visual.gd").draw(canvas,v,reduced_flash);return
 if v.effect=="weapon":
  preload("res://scripts/weapon_visual.gd").effect(canvas,v,reduced_flash);return
 var extension_styles={"windwheel":"disc","wake_bell":"bell","rake_wall":"gate_shield","sand_guardian":"sand_seal","arrow_rain":"tide_bow"}
 if extension_styles.has(v.effect):
  var image: Dictionary=v.duplicate();image.weapon_style=extension_styles[v.effect]
  preload("res://scripts/weapon_visual.gd").effect(canvas,image,reduced_flash);return
 var t: float=clampf(1-v.life/v.max,0,1)
 var col: Color=Color(COLORS[v.role]);col.a=(1-t)*(.5 if reduced_flash else .8)
 var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=v.radius
 var effect: String=v.effect
 if effect=="anticipation":
  canvas.draw_arc(p,r*.7,0,TAU,32,Color(col,.35),2,true)
  canvas.draw_line(p-Vector2(12,12),p+Vector2(12,12),Color(col,.45),3,true)
  return
 if effect=="link":canvas.draw_line(p,p+d*r,Color(col,.15),13,true);canvas.draw_line(p,p+d*r,col,3,true);return
 match v.role:
  "wukong":
   if effect in ["giant","heavy"]:
    var at: Vector2=p+d*r*.7
    canvas.draw_line(p-d*15,p+d*r,Color("514339",col.a*.4),14,true)
    canvas.draw_line(p,p+d*r,col,5,true)
    for i in 6:canvas.draw_line(at,at+Vector2.RIGHT.rotated(i*TAU/6)*70*t,col,3,true)
   elif effect in ["summon","clone","avatars"]:
    for i in 3:
     var center: Vector2=p+d.orthogonal()*(i-1)*30+d*t*45
     canvas.draw_line(center+Vector2(0,-55),center+Vector2(0,-10),Color(col,.4),14,true)
     canvas.draw_line(center-d*r*.3,center+d*r*.7,col,3,true)
   elif effect=="dash":
    for i in 5:
     var at: Vector2=p+d*r*t-d*i*24
     canvas.draw_arc(at,18+i*3,PI*.1,PI*.9,20,Color(col,.4),4,true)
   elif effect=="lunge":canvas.draw_line(p,p+d*r,col,6,true);canvas.draw_line(p+d.orthogonal()*9,p+d*r+d.orthogonal()*9,Color(col,.3),2,true)
   elif effect=="mark":
    var at: Vector2=p+d*65
    canvas.draw_arc(at,25,0,PI,20,col,3,true);canvas.draw_arc(at,25,PI,TAU,20,col,3,true);canvas.draw_line(at-Vector2(0,13),at+Vector2(0,13),col,5,true)
   elif effect=="orbit":
    for i in 6:
     var delta: Vector2=Vector2.RIGHT.rotated(i*TAU/6+t*4)
     canvas.draw_line(p+delta*55-delta.orthogonal()*18,p+delta*55+delta.orthogonal()*18,col,4,true)
   elif effect=="freeze":
    for i in 8:
     var center: Vector2=p+Vector2.RIGHT.rotated(i*TAU/8)*r*(.5+t*.3)
     canvas.draw_rect(Rect2(center-Vector2(7,12),Vector2(14,24)),col,false,2)
   else:canvas.draw_arc(p,r*(.7+t*.3),d.angle()-1.15,d.angle()+1.15,28,col,5,true)
  "tangseng":
   var radius: float=r*(.55+t*.35)
   canvas.draw_arc(p,radius,0,TAU,48,col,2,true)
   for i in 8:
    var delta: Vector2=Vector2.RIGHT.rotated(i*TAU/8+t*.2)
    var at: Vector2=p+delta*radius*.8
    canvas.draw_rect(Rect2(at-Vector2(4,7),Vector2(8,14)),col,false,2)
   if effect in ["heavy","detonate","purification"]:
    canvas.draw_rect(Rect2(p-Vector2(18,18),Vector2(36,36)),col,false,5)
    canvas.draw_line(p-Vector2(0,12),p+Vector2(0,12),col,4,true)
   elif effect=="counter":canvas.draw_arc(p,55,d.angle()-1.2,d.angle()+1.2,24,col,5,true)
   elif effect=="convert":
    canvas.draw_circle(p+d*70+Vector2(0,-30),10,Color(col,.3));canvas.draw_line(p+d*70+Vector2(0,-20),p+d*70+Vector2(0,15),col,10,true)
   elif effect in ["heal","sanctuary","chant"]:
    for i in 6:canvas.draw_line(p+Vector2(i*16-40,5),p+Vector2(i*16-40,-35*t),Color(col,.4),2,true)
    if effect=="sanctuary":
     for i in 6:
      var dir: Vector2=Vector2.RIGHT.rotated(i*TAU/6)
      canvas.draw_polyline(PackedVector2Array([p+dir*30,p+dir*70+dir.orthogonal()*20,p+dir*100,p+dir*70-dir.orthogonal()*20,p+dir*30]),col,2,true)
  "bajie":
   if effect in ["shield","guard"]:
    canvas.draw_arc(p,55,d.angle()-1.2,d.angle()+1.2,24,col,8,true)
   elif effect=="resource":
    canvas.draw_arc(p+Vector2(0,-25),25,0,PI,24,col,4,true)
    for i in 4:canvas.draw_line(p+Vector2(i*10-15,-20),p+Vector2(i*10-15,-40-t*20),col,2,true)
   elif effect=="charge":
    for i in 6:canvas.draw_line(p-d*(i*14)+d.orthogonal()*sin(i)*12,p+d*r*t-d*(i*14),Color(col,.5),4,true)
   else:
    for i in 9:
     var at: Vector2=p+d.orthogonal()*(i-4)*8+d*r*t
     canvas.draw_line(at-d*28,at,col,3,true)
    if effect in ["heavy","quake","marshal","quakes","slam","detonate"]:
     for i in 7:
      var dir: Vector2=Vector2.RIGHT.rotated(i*TAU/7)
      canvas.draw_polyline(PackedVector2Array([p,p+dir*r*.3+dir.orthogonal()*8,p+dir*r*.65-dir.orthogonal()*6,p+dir*r]),col,3,true)
  "shaseng":
   if effect in ["detonate","heavy","sandburst"]:
    for i in 6:
     var dir: Vector2=Vector2.RIGHT.rotated(i*TAU/6)
     canvas.draw_line(p+dir*r*.15,p+dir*r*(.5+t*.5),col,3,true)
   elif effect in ["root","bind","sand","sandstorm"]:
    for i in 3:canvas.draw_arc(p,r*(.5+i*.18),t*2+i,t*2+i+PI*1.6,32,col,2,true)
   elif effect=="fan":
    for i in 5:
     var delta: Vector2=d.rotated((i-2)*.22)
     var at: Vector2=p+delta*r*t
     canvas.draw_colored_polygon(PackedVector2Array([at+delta*14,at-delta*8+delta.orthogonal()*6,at-delta*8-delta.orthogonal()*6]),col)
   elif effect=="blink":
    for i in 2:
     var at: Vector2=p+d*(i*150)
     canvas.draw_circle(at+Vector2(0,-35),8,Color(col,.4));canvas.draw_line(at+Vector2(0,-26),at+Vector2(0,5),Color(col,.35),14,true)
   else:
    var center: Vector2=p+d*r*t
    canvas.draw_arc(center,28,d.angle()-PI*.7,d.angle()+PI*.7,24,col,5,true)
    canvas.draw_line(p,center,Color(col,.3),2,true)
  "bailongma":
   if effect=="waterwall":
    for i in 3:
     var at: Vector2=p+d*(45+i*60)
     canvas.draw_line(at+d.orthogonal()*40,at-d.orthogonal()*40,col,5,true)
     canvas.draw_line(at+Vector2(0,-35),at,col,2,true)
    return
   if effect=="breath":
    for i in 5:
     var delta: Vector2=d.rotated((i-2)*.12)
     canvas.draw_line(p+delta*20,p+delta*r*t,col,3,true)
    return
   var points:=PackedVector2Array()
   for i in 20:points.append(p+d*(i*r/20)+d.orthogonal()*sin(i*.55-t*8)*(12 if effect in ["dragon","dragonflight","heavy"] else 5))
   canvas.draw_polyline(points,Color(col,.15),16,true);canvas.draw_polyline(points,col,3,true)
   if effect in ["dragon","dragonflight","heavy"]:
    var head: Vector2=p+d*r*minf(1,t*2)
    canvas.draw_colored_polygon(PackedVector2Array([head+d*25,head-d*15+d.orthogonal()*16,head-d*5,head-d*15-d.orthogonal()*16]),col)
    for side in [-1,1]:canvas.draw_line(head+d.orthogonal()*side*8,head-d*28+d.orthogonal()*side*22,col,2,true)

func draw_seals(canvas: CanvasItem,seals: Array,clock: float) -> void:
 for seal in seals:
  preload("res://scripts/painterly_assets.gd").stamp(canvas,preload("res://scripts/painterly_assets.gd").relic("relic_13"),seal.pos,Vector2(26,29),sin(clock)*.03,.36)
func bitmap_skill_draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false) -> void:
 if v.effect=="weapon":preload("res://scripts/weapon_visual.gd").effect(canvas,v,reduced_flash);return
 if v.effect=="ultimate_stage":preload("res://scripts/ultimate_visual.gd").draw(canvas,v,reduced_flash);return
 var t: float=clampf(1-v.life/v.max,0,1)
 var alpha: float=.4 if reduced_flash else .8
 if v.effect=="anticipation":alpha*=.4
 var art=preload("res://scripts/painterly_assets.gd");var p: Vector2=v.pos;var d: Vector2=v.dir;var r: float=v.radius
 if v.effect in ["dash","lunge","dragon","blink","charge","evade","pursue"]:
  for i in 3:art.burst(canvas,v.role,p+d*r*(t-i*.18),d,r*.5,t,alpha*(1-i*.2),1)
 elif v.effect in ["summon","clone","avatars"]:
  for i in 3:
   var at: Vector2=p+d.orthogonal()*(i-1)*36+d*t*r*.4
   art.stamp(canvas,art.weapon("wukong_w4"),at,Vector2(r*.7,r*.56),d.angle()+t*.3,alpha*.8)
   art.burst(canvas,v.role,at,d,r*.4,t,alpha*.5,1)
 elif v.effect in ["beam","link","breath","arrow_rain"]:
  for i in 4:art.burst(canvas,v.role,p+d*r*i/4,d,r*.48,clampf(t-i*.06,0,1),alpha,1)
 elif v.effect in ["shield","guard","counter","rake_wall"]:
  art.stamp(canvas,art.weapon("bajie_w5"),p+d*35,Vector2(92,74),d.angle(),alpha)
  art.burst(canvas,v.role,p+d*30,d,r*.7,t,alpha*.55,2)
 elif v.effect in ["pull","root","freeze","mark"]:
  var item: String="relic_12" if v.effect in ["pull","root"] else "relic_0" if v.effect=="mark" else "relic_13"
  art.stamp(canvas,art.relic(item),p+d*r*.3,Vector2(70,70),d.angle()+t*.2,alpha)
  art.burst(canvas,v.role,p+d*r*.3,d,r*.6,t,alpha*.5,2)
 elif v.effect in ["heal","chant","sanctuary","lotus","wake_bell","resource"]:
  var item: String="relic_15" if v.effect=="wake_bell" else "relic_19" if v.effect=="sanctuary" else "relic_1" if v.effect=="heal" else "relic_16"
  art.stamp(canvas,art.relic(item),p-Vector2(0,25+t*25),Vector2(75,75),0,alpha)
  for sign in [-1,1]:art.burst(canvas,v.role,p+Vector2(sign*25,0),Vector2.ZERO,r*.75,t,alpha*.6,2)
 elif v.effect in ["quake","slam","detonate","sand_guardian"]:
  for i in 3:art.burst(canvas,v.role,p+d*r*(.15+i*.23),d,r*.75,clampf(t-i*.08,0,1),alpha,2)
 else:art.burst(canvas,v.role,p,d,r,t,alpha,0)

func draw(canvas: CanvasItem,v: Dictionary,reduced_flash: bool=false) -> void:
 if v.effect=="clone_replay":
  var actor: Dictionary=v.actor
  if not v.melee:actor.action.elapsed=clampf(v.max-v.life,0,v.max)
  var base: Transform2D=canvas.art_draw_base() if canvas.has_method("art_draw_base") else Transform2D.IDENTITY
  clone_rig.draw(canvas,0,actor,Color(.9,.88,.76,.35*minf(1,v.life/.10)),v.max-v.life,base*Transform2D(0,v.pos),"wukong")
  canvas.draw_set_transform_matrix(base)
  preload("res://scripts/weapon_effects.gd").action_trail(canvas,actor.action,v.pos,reduced_flash)
 elif v.effect=="weapon":preload("res://scripts/weapon_effects.gd").effect(canvas,v,reduced_flash)
 elif v.effect=="ultimate_stage":preload("res://scripts/abilities_visual.gd").ultimate(canvas,v,reduced_flash)
 else:preload("res://scripts/abilities_visual.gd").draw(canvas,v,reduced_flash)
