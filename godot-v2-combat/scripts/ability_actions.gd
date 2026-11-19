extends RefCounted
# Each ability owns its windup, contact and recovery; no generic cast timing.
const TIMES={
 "wukong":[[.12,.12,.17],[.16,.34,.2],[.24,.08,.18],[.07,.3,.2],[.1,.12,.14],[.11,.2,.16]],
 "tangseng":[[.23,1.7,.24],[.32,.13,.25],[.22,.3,.24],[.36,.12,.23],[.08,.23,.16],[.21,.22,.18]],
 "bajie":[[.09,.25,.21],[.12,.26,.2],[.32,.22,.3],[.24,.44,.25],[.18,.18,.23],[.28,.16,.21]],
 "shaseng":[[.26,.12,.21],[.13,.14,.18],[.1,.13,.17],[.25,.18,.2],[.06,.16,.14],[.16,.25,.2]],
 "bailongma":[[.09,.22,.16],[.2,.4,.23],[.21,.75,.2],[.06,.18,.13],[.19,.14,.22],[.08,.23,.18]]}
const ULTIMATES={"wukong":[[.42,.25,.35],[.28,.35,.29]],"tangseng":[[.48,.3,.4],[.33,.55,.32]],"bajie":[[.5,.22,.45],[.32,.4,.3]],"shaseng":[[.35,.35,.3],[.4,.24,.35]],"bailongma":[[.28,.42,.3],[.38,.3,.28]]}
static func apply(spec,hero: String,kind: String,definition: Dictionary) -> void:
 var index: int=int(str(definition.id).right(1))
 var timing: Array=([.38,.25,.35] if kind=="ultimate" else [.22,.16,.23]) if (kind=="ultimate" and index==2) or (kind=="skill" and index==6) else ULTIMATES[hero][index] if kind=="ultimate" else TIMES[hero][index]
 spec.windup=timing[0];spec.active=timing[1];spec.recovery=timing[2]
 spec.clip=hero+"_"+definition.effect
