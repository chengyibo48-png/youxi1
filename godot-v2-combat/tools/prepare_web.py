from pathlib import Path
import gzip,json
root=Path(__file__).resolve().parents[1]
out=root/'web-site/dist'
wasm=out/'play.wasm'
if wasm.exists():
 (out/'play.wasm.gz').write_bytes(gzip.compress(wasm.read_bytes(),compresslevel=9,mtime=0))
 wasm.unlink()
html=out/'play.html'
s=html.read_text(encoding='utf-8')
shim="""<script>
const nativeFetch=window.fetch.bind(window);
window.fetch=async function(input,init){
 const url=typeof input==='string'?input:input instanceof URL?input.href:input.url;
 if(new URL(url,location.href).pathname.endsWith('/play.wasm')){
  const compressed=await nativeFetch(new URL('play.wasm.gz',location.href),init);
  if(!compressed.ok)throw new Error('引擎文件加载失败，请刷新页面');
  return new Response(compressed.body.pipeThrough(new DecompressionStream('gzip')),{headers:{'Content-Type':'application/wasm'}});
 }
 return nativeFetch(input,init);
};
</script>"""
if 'const nativeFetch=' not in s:s=s.replace('<script src="play.js"></script>',shim+'<script src="play.js"></script>')
s=s.replace('<title>重生之我也要取经', '<title>重生之我也要取经')
html.write_text(s,encoding='utf-8')
(out/'index.html').write_text("""<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>重生之我也要取经 · 2.0试玩</title><style>*{box-sizing:border-box}body{margin:0;background:#192e2d;color:#ede4cd;font:18px/1.8 system-ui,sans-serif}main{max-width:850px;margin:8vh auto;padding:40px;border:1px solid #a88c57;background:#213b36}small{color:#c4b48b}h1{font-size:36px;line-height:1.3}a{color:#e8cd92}a.play{display:inline-block;padding:12px 32px;margin:18px 0;background:#dec793;color:#213b36;text-decoration:none;border-radius:5px}p{margin:12px 0}</style><main><small>国风动作肉鸽 · 开发试玩版</small><h1>重生之我也要取经</h1><p>2400×1400探索地图、随机兵器构筑、障碍掩体与妖王三阶段战斗。</p><a class="play" href="play.html">进入 2.0 试玩</a><p>推荐电脑 Chrome 或 Edge。首次进入需加载引擎与素材，请稍候。手机操作暂未适配。</p><p>WASD移动 · 左键攻击 · 右键蓄力重击 · Space闪避<br>Q/E神通 · R绝技 · F法宝 · T切换兵器 · Tab构筑 · Esc暂停</p><p>建议先进入训练场试用。每次历劫的敌人外观与攻击套路会有变化；躲开妖王预警，抓住收招窗口反击。</p><small>本人主导设计与迭代，AI辅助开发。角色完整动画、更多首领专属形象与平衡仍在迭代。存档保存在当前浏览器。</small><p><a href="https://qujing-journey-2026.pages.dev/">游玩经典1.9网页版</a></p></main></html>""",encoding='utf-8')
print(json.dumps({'web_ready':True,'files':[{ 'name':f.name,'bytes':f.stat().st_size} for f in out.iterdir() if f.is_file()]}))
