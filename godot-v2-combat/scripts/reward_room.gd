extends Node2D
@export var room_kind: String="shop"
var biome: String="wild"
var place: String="西行路"
var chapter_index: int=0
var environment: Texture2D
var typeface: Font
var combat
var interaction: Vector2
var clock: float=0
var static_floor=preload("res://scripts/static_journey_floor.gd").new()
func _init() -> void:
 static_floor.z_index=-1;add_child(static_floor)
const TITLES={"shop":"珍奇货肆","shrine":"土地神龛","event":"奇遇岔口","rest":"行旅歇脚","reward":"经匣藏宝","forge":"西行锻炉","curse":"妖契祭坛"}
const PALETTES={"shop":["bec1a1","9b6848"],"shrine":["c3b99e","9c5440"],"event":["aebd9c","6d7d5b"],"rest":["aabdaf","6d9390"],"reward":["c6ba93","b6924f"],"forge":["aca99c","a96642"],"curse":["aaa4ab","806174"]}
func configure(c,font: Font,fresh: bool=true) -> void:
 combat=c;typeface=font
 if fresh:c.configure_arena(Vector2(1600,900));c.layout_name=TITLES[room_kind]
 interaction=c.arena_origin+Vector2(760,450)
 if fresh:
  c.obstacles=[]
  for i in 3:c.obstacles.append({"pos":interaction+Vector2((i-1)*65,-105),"radius":42.0,"kind":"pillar"})
  preload("res://scripts/chapter_scenery.gd").reward_props(c,chapter_index,biome)
  c.geometry.configure(c.arena_bounds(),c.obstacles)
  c.player.pos=c.arena_origin+Vector2(460,450)
 queue_redraw()
func near() -> bool:return combat!=null and combat.player.pos.distance_to(interaction)<115
func _process(dt: float) -> void:
 clock+=dt
 if combat!=null:static_floor.configure(combat.arena_bounds(),environment,biome,chapter_index)
 queue_redraw()
func words(value: String,p: Vector2,size: int=18,color: Color=Color("314a3d")) -> void:
 if typeface!=null:
  var extent: Vector2=typeface.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,size)
  draw_rect(Rect2(p-Vector2(7,size+3),extent+Vector2(14,8)),Color("192e2d",.8))
  draw_string(typeface,p,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("f0dfba"))
func lantern(p: Vector2,color: Color) -> void:
 draw_line(p-Vector2(0,38),p-Vector2(0,18),Color("514d3a"),2,true)
 draw_rect(Rect2(p-Vector2(14,18),Vector2(28,36)),color);draw_rect(Rect2(p-Vector2(14,18),Vector2(28,36)),Color("584e3b"),false,2)
 for x in [-7,0,7]:draw_line(p+Vector2(x,-15),p+Vector2(x,15),Color("e4c695",.45),1,true)
 draw_line(p+Vector2(0,18),p+Vector2(0,31),color,3,true)
func crate(p: Vector2,color: Color) -> void:
 draw_rect(Rect2(p,Vector2(50,34)),color.darkened(.25));draw_rect(Rect2(p-Vector2(0,9),Vector2(50,32)),color)
 draw_rect(Rect2(p-Vector2(0,9),Vector2(50,32)),Color("6b6148"),false,2)
 for x in [10,25,40]:draw_line(p+Vector2(x,-8),p+Vector2(x,23),color.darkened(.2),2,true)
func surroundings(p: Vector2,accent: Color) -> void:
 for sign in [-1,1]:
  var point: Vector2=p+Vector2(sign*270,-165)
  match room_kind:
   "shop":
    crate(point,Color("a78b59"));crate(point+Vector2(-35,43),Color("b59b70"));lantern(point+Vector2(60,0),accent)
    draw_line(point+Vector2(-25,-45),point+Vector2(90,-45),Color("655b43"),4,true)
   "shrine":
    draw_line(point+Vector2(0,-50),point+Vector2(0,95),Color("786a4e"),10,true)
    draw_rect(Rect2(point+Vector2(13,-30),Vector2(38,110)),accent);words("土地",point+Vector2(17,10),16,Color("ead9ae"));words("庇佑",point+Vector2(17,39),16,Color("ead9ae"));lantern(point+Vector2(-45,15),Color("bb8861"))
   "event":
    for i in 5:
     var bamboo: Vector2=point+Vector2(i*20,0)
     draw_line(bamboo-Vector2(0,65),bamboo+Vector2(0,90),Color("677a54"),4,true)
     for joint in 4:draw_line(bamboo+Vector2(-5,joint*32-60),bamboo+Vector2(5,joint*32-60),Color("92a374"),2,true);draw_line(bamboo+Vector2(0,joint*32-55),bamboo+Vector2(sign*25,joint*32-75),Color("637b51"),3,true)
   "rest":
    draw_rect(Rect2(point+Vector2(-35,45),Vector2(125,22)),Color("85795b"));draw_circle(point+Vector2(0,33),9,Color("d3c6a3"));draw_circle(point+Vector2(38,33),12,Color("8c936f"));draw_arc(point+Vector2(38,23),10,PI,TAU,12,Color("d3c6a3"),2,true)
   "reward":
    draw_rect(Rect2(point+Vector2(-22,-60),Vector2(44,140)),Color("978e71"));draw_rect(Rect2(point+Vector2(-27,-68),Vector2(54,15)),Color("b2a986"));lantern(point+Vector2(0,33),Color("c9a66d"))
   "forge":
    crate(point,Color("807d63"))
    for i in 4:draw_circle(point+Vector2(i*13,36),9,Color("534f42"));draw_line(point+Vector2(90,-55),point+Vector2(70,75),Color("baa980"),5,true)
    draw_line(point+Vector2(75,-45),point+Vector2(111,-40),Color("aaa68c"),12,true)
   "curse":
    draw_line(point+Vector2(0,-70),point+Vector2(0,85),Color("615564"),6,true);draw_rect(Rect2(point+Vector2(6,-60),Vector2(65,78)),accent)
    for i in 5:draw_line(point+Vector2(17+i*9,-40),point+Vector2(24+i*9,-5),Color("bc9e88"),2,true)
func legacy_draw() -> void:
 if combat==null:return
 var bounds: Rect2=combat.arena_bounds();var base=Color(PALETTES[room_kind][0]);var accent=Color(PALETTES[room_kind][1]);var p: Vector2=interaction
 draw_rect(bounds.grow(100),base.darkened(.18));draw_rect(bounds,base)
 for i in 18:draw_line(bounds.position+Vector2(i*96,0),bounds.position+Vector2(i*96,bounds.size.y),Color("e3d9bb",.2),1,true)
 draw_rect(bounds.grow(-45),Color(accent,.4),false,3)
 # A clear road links entry, interaction and exit; scenery never blocks the road.
 draw_rect(Rect2(bounds.position+Vector2(0,380),Vector2(bounds.size.x,140)),Color("e0d5b8",.45))
 for row in 3:
  for tile in 20:
   var rect=Rect2(bounds.position+Vector2(tile*82+(row%2)*28,387+row*45),Vector2(73,36))
   draw_rect(rect,Color("d8ccb0",.28));draw_line(rect.position+Vector2(3,32),rect.end-Vector2(6,4),Color("91876a",.2),1,true)
 for grain in 130:
  var point: Vector2=bounds.position+Vector2(fmod(grain*127.0,1600),fmod(grain*211.0,900))
  draw_line(point,point+Vector2(9+grain%7,1),Color("7a8064",.1),1,true)
 surroundings(p,accent)
 for i in 6:
  var stone: Vector2=bounds.position+Vector2(110+i*250,170 if i%2==0 else 730)
  draw_circle(stone,30,Color(accent,.25));draw_arc(stone,23,0,PI,16,Color(accent,.35),3,true)
 words(TITLES[room_kind],p+Vector2(-90,-210),30,accent)
 match room_kind:
  "shop":
   draw_rect(Rect2(p+Vector2(-135,-140),Vector2(270,90)),Color("70583e"));draw_rect(Rect2(p+Vector2(-150,-185),Vector2(300,50)),accent)
   for i in 7:draw_rect(Rect2(p+Vector2(-150+i*43,-185),Vector2(22,50)),Color("d4b478"))
   for i in 5:draw_circle(p+Vector2(-90+i*45,-87),12,Color("cbb47e"));draw_line(p+Vector2(-90+i*45,-100),p+Vector2(-90+i*45,-60),accent,3,true)
   words("铜钱有价 · 选择有舍",p+Vector2(-100,175),17)
  "shrine":
   draw_rect(Rect2(p+Vector2(-90,-135),Vector2(180,85)),Color("846c4c"));draw_colored_polygon(PackedVector2Array([p+Vector2(-120,-130),p+Vector2(0,-195),p+Vector2(120,-130)]),accent)
   draw_circle(p+Vector2(0,-104),19,Color("d4bc82"));draw_rect(Rect2(p+Vector2(-23,-89),Vector2(46,39)),Color("bba578"))
   for i in 3:draw_line(p+Vector2((i-1)*15,-38),p+Vector2((i-1)*15,-12),accent,3,true);draw_circle(p+Vector2((i-1)*15,-43-sin(clock+i)*4),3,Color(accent,.3))
   words("香火不灭 · 今日所求",p+Vector2(-100,175),17)
  "event":
   draw_line(p+Vector2(0,-60),p+Vector2(0,-155),Color("625841"),8,true)
   for i in 2:draw_rect(Rect2(p+Vector2(-65 if i==0 else -15,-150+i*38),Vector2(80,27)),accent)
   draw_rect(Rect2(p+Vector2(50,-70),Vector2(65,35)),Color("b69c70"));draw_arc(p+Vector2(-100,-70),36,0,TAU,24,Color("8c8567"),5,true)
   words("岔路相逢 · 因果自选",p+Vector2(-100,175),17)
  "rest":
   draw_circle(p+Vector2(0,-100),95,Color("759b94",.6));draw_arc(p+Vector2(0,-100),80,0,TAU,40,Color("c6dfcd",.5),3,true)
   draw_rect(Rect2(p+Vector2(-90,-18),Vector2(180,22)),Color("887857"));draw_circle(p+Vector2(100,60),18,Color("c3864a"));draw_line(p+Vector2(80,62),p+Vector2(120,62),Color("685640"),6,true)
   words("歇步煮茶 · 清心续行",p+Vector2(-100,175),17)
  "reward":
   draw_rect(Rect2(p+Vector2(-75,-120),Vector2(150,75)),accent);draw_rect(Rect2(p+Vector2(-82,-134),Vector2(164,23)),Color("766044"))
   draw_rect(Rect2(p+Vector2(-11,-104),Vector2(22,33)),Color("e8d39b"));draw_line(p+Vector2(-58,-95),p+Vector2(58,-95),Color("dec482"),3,true)
   for i in 5:draw_rect(Rect2(p+Vector2(-130+i*58,80),Vector2(30,17)),Color("bca26b"),false,3)
   words("经匣有余 · 只取所需",p+Vector2(-100,175),17)
  "forge":
   draw_rect(Rect2(p+Vector2(-85,-155),Vector2(170,110)),Color("625f54"));draw_circle(p+Vector2(0,-90),37,Color("c5864a",.8));draw_circle(p+Vector2(0,-90),20+sin(clock*4)*3,Color("e4bd71"))
   draw_rect(Rect2(p+Vector2(110,-115),Vector2(100,22)),Color("666859"));draw_line(p+Vector2(155,-94),p+Vector2(155,-40),Color("666859"),18,true)
   for i in 3:draw_line(p+Vector2(-150-i*25,-60),p+Vector2(-150-i*25,-160),Color("bfb38f"),4,true)
   words("淬锋换势 · 兵器有道",p+Vector2(-100,175),17)
  "curse":
   draw_colored_polygon(PackedVector2Array([p+Vector2(-90,-50),p+Vector2(-60,-130),p+Vector2(60,-130),p+Vector2(90,-50)]),Color("6d626b"))
   draw_rect(Rect2(p+Vector2(-28,-180),Vector2(56,90)),accent);draw_line(p+Vector2(-12,-160),p+Vector2(12,-112),Color("c3a786"),4,true)
   words("妖契须偿 · 代价先明",p+Vector2(-100,175),17)
 draw_arc(p,45+sin(clock*2)*3,0,TAU,32,Color(accent,.5),2,true)
 words("走近后按 G / Enter / 手柄确认",p+Vector2(-145,85),16)
 var exit: Vector2=combat.exit_position()
 draw_rect(Rect2(exit-Vector2(24,52),Vector2(48,104)),Color("bbaa72"),false,5);words("出口",exit+Vector2(-20,-67),17)

func _draw() -> void:
 if combat==null:return
 var bounds: Rect2=combat.arena_bounds();var p: Vector2=interaction
 static_floor.configure(bounds,environment,biome,chapter_index)
 var art=preload("res://scripts/painterly_assets.gd")
 var index: int=["shop","shrine","event","rest","reward","forge","curse"].find(room_kind)
 # The obstacle shapes stay aligned with the three visible supports.
 words(place+" · "+TITLES[room_kind],p+Vector2(-145,52),20,Color("ead6a4"))
 words("走近后按 G / Enter / 手柄确认",p+Vector2(-145,85),16,Color("f3dcb0"))
 var exit: Vector2=combat.exit_position()
 preload("res://scripts/journey_scene_art.gd").gate(self,exit)
 preload("res://scripts/journey_scene_art.gd").gate(self,combat.arena_origin+Vector2(120,combat.arena_size.y*.5),true,true)
 words("继续西行",exit+Vector2(-35,55),17,Color("f3dcb0"))
