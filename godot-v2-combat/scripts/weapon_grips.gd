extends RefCounted
# Handle fraction, second-hand spacing, rest angle, handling family. Stable per weapon.
const GRIPS={
 "wukong_w0":[.32,28.0,-.5,"staff"],"wukong_w1":[.26,32.0,-.35,"pillar"],"wukong_w2":[.30,25.0,-.55,"staff"],"wukong_w3":[.19,0.0,-.85,"dual"],"wukong_w4":[.25,0.0,-.45,"cast"],"wukong_w5":[.18,0.0,-.1,"throw"],
 "tangseng_w0":[.24,23.0,-1.15,"staff"],"tangseng_w1":[.85,30.0,0.0,"scroll"],"tangseng_w2":[.50,0.0,0.0,"dual"],"tangseng_w3":[.18,0.0,-.2,"beads"],"tangseng_w4":[.24,26.0,-1.05,"staff"],"tangseng_w5":[.52,0.0,-1.2,"lantern"],
 "bajie_w0":[.23,32.0,-.45,"rake"],"bajie_w1":[.23,22.0,-.35,"rake"],"bajie_w2":[.25,34.0,-.5,"rake"],"bajie_w3":[.25,26.0,-.6,"hammer"],"bajie_w4":[.18,0.0,-.45,"chain"],"bajie_w5":[.50,0.0,0.0,"shield"],
 "shaseng_w0":[.28,29.0,-.4,"polearm"],"shaseng_w1":[.48,0.0,-.3,"throw"],"shaseng_w2":[.36,28.0,-.4,"polearm"],"shaseng_w3":[.25,0.0,-.6,"focus"],"shaseng_w4":[.22,0.0,-.3,"dual"],"shaseng_w5":[.48,0.0,-.4,"chain"],
 "bailongma_w0":[.23,30.0,-.2,"spear"],"bailongma_w1":[.17,0.0,-.4,"sword"],"bailongma_w2":[.18,0.0,-.45,"sword"],"bailongma_w3":[.28,0.0,-.2,"focus"],"bailongma_w4":[.16,0.0,-.4,"sword"],"bailongma_w5":[.50,34.0,0.0,"bow"]}
static func get_grip(id: String) -> Array:return GRIPS.get(id,[.25,0.0,-.5,"sword"])
