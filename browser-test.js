// Real Chromium QA against the unmodified production page, using isolated saves.
const fs=require("fs"),path=require("path"),assert=require("assert"),{pathToFileURL}=require("url");
const playwright=require("playwright");
const h=require("./smoke-test.js"),game=h.game;
const chapters=h.browser.window.XIYOU_CHAPTERS.chapters;
function seed(type,ids,eventId){
  game.select(1);game.startRun();game.grantCoins(600);
  const p=game.state().player;p.hp=32;p.curse=1;p.skillCd=4;p.relicBag=[];
  const chapter=chapters.findIndex((_,i)=>{const plan=h.browser.window.XIYOU_ROOMS.generate(i,h.browser.window.XIYOU_BALANCE.rooms);return plan.main.some(id=>plan.rooms[id].type===type);});
  game.enterRoom(type,chapter);if(ids)game.setOffer(ids,eventId);game.saveRun();return game.state().save;
}
(async()=>{
  const browser=await playwright.chromium.launch({headless:true,...(process.env.PLAYWRIGHT_CHANNEL?{channel:process.env.PLAYWRIGHT_CHANNEL}:{})});
  const errors=[];fs.mkdirSync(path.join(__dirname,"qa-1.9"),{recursive:true});
  try{
    for(const mobile of [false,true]){
      const context=await browser.newContext({viewport:mobile?{width:390,height:844}:{width:1280,height:960},isMobile:mobile,hasTouch:mobile,deviceScaleFactor:1});
      const page=await context.newPage();page.on("pageerror",e=>errors.push(e.message));
      const load=async save=>{
        await page.goto(pathToFileURL(path.join(__dirname,"index.html")).href);
        await page.evaluate(save=>{localStorage.setItem("xiyou-run-v18",JSON.stringify(save));localStorage.setItem("xiyou-settings-v2",JSON.stringify({display:"full",voice:false,bgm:0,sfx:0}));},save);
        await page.reload();await page.locator("#continue").click();
      };
      await load(seed("shop",["shop_relic","weapon","food","incense","bag","skill"]));
      await page.locator('[data-choice-id="shop_relic"]').click();
      assert(await page.locator('[data-choice-id="shop_relic"]').isDisabled());
      assert((await page.locator(".room-feedback").innerText()).includes("已购入"));
      await page.locator('[data-choice-id="weapon"]').click();
      const before=await page.locator("[data-choice-id]").count();
      await page.locator("#room-map").click();await page.locator("#map-back").click();
      assert.strictEqual(await page.locator("[data-choice-id]").count(),before);
      await page.reload();await page.locator("#continue").click();
      assert(await page.locator('[data-choice-id="weapon"]').isDisabled());
      const horizontal=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth);
      assert(!horizontal,"no horizontal overflow");
      await page.locator(".panel").evaluate(el=>el.scrollTop=0);
      await page.screenshot({path:path.join(__dirname,`qa-1.9/${mobile?"mobile":"desktop"}-shop.png`),animations:"disabled"});
      await page.locator(".relic-inventory summary").click();
      assert.strictEqual(await page.locator("[data-bag-drop]").count(),1);
      await page.locator("[data-bag-drop]").click();
      assert.strictEqual(await page.locator("[data-bag-drop]").count(),0);
      await page.locator('[data-choice-id="leave"]').click();
      assert.strictEqual(await page.locator(".room-panel").count(),0);

      await load(seed("shrine"));
      await page.locator(".panel").evaluate(el=>el.scrollTop=0);
      await page.screenshot({path:path.join(__dirname,`qa-1.9/${mobile?"mobile":"desktop"}-shrine.png`),animations:"disabled"});
      await load(seed("event",["sacrifice","listen","help"],"old_man"));
      assert.strictEqual(await page.locator('[data-choice-id="sacrifice"]').count(),0,"no phantom relic sacrifice");
      await page.screenshot({path:path.join(__dirname,`qa-1.9/${mobile?"mobile":"desktop"}-event.png`),animations:"disabled"});
      await page.locator('[data-choice-id="listen"]').click();
      assert.strictEqual(await page.locator(".room-panel").count(),0);
      await context.close();
    }
    assert.deepStrictEqual(errors,[]);console.log("Browser QA passed: desktop + 390px mobile, actual purchases, disabled states, inventory, map, reload, exit and zero page errors.");
  }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
