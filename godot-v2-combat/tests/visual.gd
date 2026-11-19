extends SceneTree
func _initialize() -> void:
 call_deferred("run")
func capture(name: String) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tests/"+name+".png")
func run() -> void:
 root.size=Vector2i(1280,720)
 var scene=load("res://Main.tscn").instantiate()
 scene.pause_on_focus_loss=false
 scene.storage.base_path="user://visual-only.json"
 scene.cinematics_enabled=false
 root.add_child(scene)
 await process_frame
 await capture("qa-home")
 scene.mode="training"
 scene.start_run()
 scene.fight.take("echo")
 scene.fight.take("chain")
 scene.fight.player.pos=Vector2(550,380)
 scene.fight.attack(Vector2.RIGHT,true)
 for i in 12:await process_frame
 await capture("qa-combat")
 scene.fight.owned.erase("echo");scene.fight.rebuild_effects()
 scene.show_talent_preview(scene.db.find("talents","echo"))
 await create_timer(1.5).timeout
 await capture("qa-preview")
 scene.panel.hide();scene.state="playing";scene.set_physics_process(false)
 scene.fight.clear_room()
 scene.fight.player.pos=Vector2(640,450)
 var boss=scene.fight.spawn("boss",Vector2(850,270),0,"红孩儿")
 scene.fight.bosses.begin(scene.fight,boss,"fire")
 scene.queue_redraw()
 await capture("qa-boss")
 for u in scene.db.tables.ultimates:
  scene.fight.reset(scene.db.find("heroes",u.hero),scene.db.find("weapons",u.hero+"_w0"))
  scene.hero_id=u.hero;scene.fight.player.resource=100
  scene.fight.spawn("dummy",Vector2(750,370),0)
  scene.fight.ultimate(u,Vector2.RIGHT);scene.queue_redraw()
  await process_frame
  await RenderingServer.frame_post_draw
 scene.fight.reset(scene.db.find("heroes","wukong"),scene.db.find("weapons","wukong_w2"))
 scene.hero_id="wukong";scene.fight.evolve(1)
 scene.numbers=[];scene.fight.attack(Vector2.RIGHT,true);scene.update_hud();scene.queue_redraw()
 await capture("qa-evolution")
 scene.fight.configure_arena(Vector2(2400,1400));scene.fight.clear_room()
 scene.fight.player.pos=scene.fight.arena_bounds().get_center();scene.fight.player.room_cleared=true
 scene.fight.caches=[{"pos":scene.fight.player.pos+Vector2(150,60),"coins":8,"claimed":false}]
 scene.fight.spawn("dummy",scene.fight.player.pos+Vector2(200,-60),0)
 scene.update_hud();scene.queue_redraw();await capture("qa-large-map")
 scene.fight.player.pos=scene.fight.exit_position();scene.update_hud();scene.queue_redraw();await capture("qa-map-exit")
 scene.fight.clear_room();scene.fight.rng.seed=14;scene.fight.create_layout("combat","forest")
 scene.fight.player.pos=scene.fight.clamp_actor(scene.fight.arena_origin+Vector2(1050,1050))
 for i in 5:scene.fight.spawn("chaser",scene.fight.clamp_actor(scene.fight.player.pos+Vector2(-180+i*100,-90)),0)
 scene.update_hud();scene.queue_redraw();await capture("qa-obstacles")
 scene.start_demo();scene.set_physics_process(false)
 await capture("qa-demo-lab")
 scene.demo_build(1);scene.demo_squad();scene.update_hud();scene.queue_redraw()
 await capture("qa-random-squad")
 scene.demo_boss("红孩儿",3)
 var demon=scene.fight.enemies[0]
 demon.transition=0
 scene.fight.bosses.begin(scene.fight,demon,"fire");scene.update_hud();scene.queue_redraw()
 await capture("qa-boss-phase3")
 scene.demo_build(1);scene.offers=["return","split","chain"]
 scene.fight.owned={};scene.fight.rebuild_effects();scene.talent_panel();scene.update_hud()
 await capture("qa-talent-cards")
 scene.mode="training";scene.loadout();scene.update_hud()
 await capture("qa-icon-loadout")
 scene.demo_build(0);scene.demo_dummies()
 scene.fight.update(.016,Vector2.RIGHT);scene.fight.attack(Vector2.RIGHT,true)
 scene.fight.update(.07,Vector2.RIGHT);scene.update_hud();scene.queue_redraw()
 await capture("qa-action-heavy")
 scene.fight.dash(Vector2.RIGHT);scene.fight.update(.05,Vector2.RIGHT)
 scene.afterimages=[{"pos":scene.fight.player.pos-Vector2(30,0),"life":.16},{"pos":scene.fight.player.pos-Vector2(60,0),"life":.12}]
 scene.update_hud();scene.queue_redraw();await capture("qa-action-dash")
 root.content_scale_size=Vector2i(1280,720)
 scene.offers=["echo","frost","frost_break"];scene.fight.owned={};scene.fight.rebuild_effects();scene.talent_panel();scene.update_hud()
 root.size=Vector2i(960,540);await capture("qa-ui-small")
 root.size=Vector2i(1920,1080);await capture("qa-ui-1080p")
 root.size=Vector2i(1280,720)
 scene.home();scene.update_hud();await capture("qa-ui-home")
 for page in ["hero","weapon","skill","ultimate"]:
  scene.mode="training";scene.loadout_tab=page;scene.loadout();scene.update_hud();await capture("qa-ui-loadout-"+page)
 scene.demo_build(1);scene.training_category="shape";scene.build_tab="training";scene.talent_search="";scene.build_panel();scene.update_hud();await capture("qa-ui-training")
 scene.demo_boss_panel();scene.update_hud();await capture("qa-ui-boss-picker")
 scene.start_demo();scene.update_hud();await capture("qa-ui-lab")
 root.size=Vector2i(960,540);scene.loadout_tab="weapon";scene.loadout();scene.update_hud();await capture("qa-ui-navigation-small")
 root.size=Vector2i(1280,720);scene.settings_tab="controls";scene.show_settings();scene.update_hud();await capture("qa-ui-settings")
 scene.demo_build(3);scene.demo_dummies();scene.fight.invuln=0;scene.update_hud();scene.set_physics_process(false)
 scene.fight.player.velocity=Vector2(230,0)
 for frame in 6:
  scene.fight.player.gait=frame*TAU/6;scene.queue_redraw();await capture("qa-walk-%02d"%frame)
 scene.fight.player.velocity=Vector2.ZERO
 for effect in ["beam","breath","waterwall","quake","wave","counter","summon","pull"]:
  var definition=scene.db.tables.skills.filter(func(d):return d.effect==effect)[0]
  scene.fight.clear_room();scene.fight.player.resource=100;scene.fight.player.skill_left=0;scene.fight.skill_cd=[0.0,0.0]
  scene.fight.skill(definition,0,Vector2.RIGHT);scene.fight.update(.12,Vector2.ZERO)
  scene.queue_redraw();await capture("qa-skill-"+effect)
 scene.demo_build(3);scene.demo_dummies();scene.fight.skill(scene.db.find("skills","wukong_s0"),0,Vector2.RIGHT)
 scene.fight.attack(Vector2.RIGHT);scene.fight.dash(Vector2.RIGHT);scene.queue_redraw();await capture("qa-lotus-build")
 scene.cinematics_enabled=true;scene.play_cinematic("五行山 · 破封西行","山河入画，步步修行")
 scene.cinematic.elapsed=1.3;scene.cinematic.queue_redraw();await capture("qa-cinematic")
 scene.cinematic.skip()
 scene.cinematic.skip();scene.cinematics_enabled=false
 for name in ["红孩儿","牛魔王","白骨精","黄眉怪","百眼魔君"]:
  scene.demo_boss(name,3);scene.fight.enemies[0].transition=0
  scene.fight.bosses.begin(scene.fight,scene.fight.enemies[0],"fire" if name=="红孩儿" else "web" if name=="百眼魔君" else "slam")
  scene.update_hud();scene.queue_redraw();await capture("qa-final-"+name)
 scene.cinematics_enabled=true;scene.demo_boss("红孩儿",3);scene.cinematic.elapsed=1.3;scene.cinematic.queue_redraw();await capture("qa-final-boss-intro");scene.cinematic.skip()
 scene.settings_tab="audio";scene.show_settings();scene.update_hud();await capture("qa-final-audio")
 scene.cinematics_enabled=false;scene.demo_build(4);scene.demo_dummies()
 for i in 3:scene.fight.attack_cd=0;scene.fight.attack(Vector2.RIGHT)
 scene.update_hud();scene.queue_redraw();await capture("qa-synergy-lightning")
 scene.build_tab="relics";scene.build_panel();scene.update_hud();await capture("qa-synergy-roles")
 print("Visual captures complete")
 scene.queue_free()
 await create_timer(.25).timeout
 await process_frame
 quit()
