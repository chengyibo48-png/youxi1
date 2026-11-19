extends Node2D
var legacy: bool=true
func _draw() -> void:
 var effects=preload("res://scripts/weapon_effects.gd")
 for row in 8:
  var points=PackedVector2Array()
  for i in 12:points.append(Vector2(30+i*35,25+row*42+sin(i*.9+row)*14))
  if row==2:points[4]=points[3]
  if row==3:points[5]=points[2]
  if row==4:points[-1]=points[0]
  var color=Color(.7,.4,.2,.8)
  if legacy:
   for i in points.size()-1:
    var delta: Vector2=points[i+1]-points[i]
    if delta.length_squared()<.04:continue
    var normal: Vector2=delta.normalized().orthogonal()
    var first: float=maxf(.1,sin((i+.5)/points.size()*PI)*6*(.7+.3*sin(i*2.7)))
    var second: float=maxf(.1,sin((i+1.5)/points.size()*PI)*6*(.7+.3*sin((i+1)*2.7)))
    for layer in [1.0,.3]:draw_primitive(PackedVector2Array([points[i]+normal*first*layer,points[i+1]+normal*second*layer,points[i+1]-normal*second*layer,points[i]-normal*first*layer]),PackedColorArray([Color(color,color.a*(.23 if layer==1 else .55))]),PackedVector2Array())
  else:effects.ribbon(self,points,6,color)
  var p=Vector2(470,25+row*42);var axis=Vector2.RIGHT.rotated(row*.3)
  if legacy:
   draw_primitive(PackedVector2Array([p+axis*9,p+axis.orthogonal()*9*.4,p-axis*9*.8,p-axis.orthogonal()*9*.3]),PackedColorArray([color]),PackedVector2Array())
   draw_primitive(PackedVector2Array([p+axis*9,p+axis.orthogonal()*9*.4,p-axis*9*.3]),PackedColorArray([color.lightened(.22)]),PackedVector2Array())
  else:effects.shard(self,p,9,row*.3,color)

