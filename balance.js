// 可单独调节的数值表。保持纯数据，不包含战斗代码。
window.XIYOU_BALANCE = Object.freeze({
  stage:{seconds:58,secondsPerStage:1.2,maxExtraSeconds:22,ambushAt:[.2,.43,.66,.85]},
  experience:{firstGoal:65,growth:1.23,flat:11,mobMultiplier:.55,bossMultiplier:1},
  enemy:{hpPerStage:.08,speedPerStage:.018,damagePerStage:.75,maxSpeed:184},
  boss:{baseHp:340,hpPerStage:40,hpQuadratic:2.5,superHealth:1.75,superSecondPhaseAt:.5},
  economy:{mobCoinChance:.17,coinLuckBonus:.08,eliteCoins:7,bossCoins:18,bossCoinsPerStage:1.8,
    begSuccess:.5,begFailureHealthRatio:.5,shopInflation:.12},
  relic:{firstSpawn:26,nextSpawnMin:38,nextSpawnMax:54,dropChance:.54,fortuneBonus:.09,
    ordinaryWeight:70,rareWeight:25,legendaryWeight:5,rareFromStage:3,legendaryFromStage:9},
  rooms:{minMain:6,maxMain:8,minResources:1,maxRisk:18}
});
