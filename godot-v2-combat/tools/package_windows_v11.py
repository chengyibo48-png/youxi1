"""Package only the exported game directory, never the project or its parent."""
from pathlib import Path
import hashlib
import json
import shutil
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "exports" / "Windows-20261011"
DEST.mkdir(parents=True, exist_ok=True)
README = """《重生之我也要取经》2.0 · v11 本地 Windows 演示版

运行：解压整个 ZIP 后，双击「取经2.0.exe」。无需安装 Godot、登录或联网。
平台：Windows 10/11，64 位；支持 OpenGL 3.3 的显卡。

主页提供三域短局、37 章战役、兵器与神通试炼，以及继续上次旅途。
WASD 移动；鼠标左键三段普攻；右键按住蓄力、松开重击；空格闪避。
Q/E 神通，R 绝技，F 法宝，T 切换兵器，C 召回，G 场景交互，Tab 路线，Esc 暂停。
鼠标滚轮切换法宝。按键、声音、特效和全身行走素材开关可在设置调整。
使用低特效设置时，敌方危险提示仍然保留。

存档保存在 %APPDATA%/Godot/app_userdata/重生之我也要取经 · 2.0/。
游戏包没有携带开发者存档、私人联系方式、登录凭据或 Git 历史。

本次：五角色全身行走轮廓裁切，26 首领 95 招式骨架衔接，37 章气氛差异，
观音院／黑风山、黄风岭、五庄观三张新增章节地面；修复奖励场景释放遗留节点。

制作说明：本人主导设计与迭代，AI 辅助开发。美术含原创 AI 辅助素材、
分层骨架和程序效果；声音含原创程序合成素材，不是专业录音／编曲。
这不是已完成人工逐帧美术及全流程验收的最终版。
尚待：重复步态返修、全部兵器全身动作、首领完整方向原画、37 章完整人工背景、
正常全战役／真人短局时长、实物手柄和多人反馈、全流程长时间性能。
密集战斗五角色样本达标，但首次场景显示仍有停顿；具体数据见检查摘要。
"""

def prepare():
    (DEST / "运行说明.txt").write_text(README, encoding="utf-8-sig")
    licenses = DEST / "licenses"
    licenses.mkdir(exist_ok=True)
    shutil.copyfile(ROOT / "assets" / "FONT-LICENSE.txt", licenses / "FONT-LICENSE.txt")
    for name in ["LICENSE.txt", "COPYRIGHT.txt", "AUTHORS.md"]:
        url = "https://raw.githubusercontent.com/godotengine/godot/4.7.2-stable/" + name
        payload = urllib.request.urlopen(url, timeout=60).read()
        if len(payload) < 100 or b"<html" in payload[:100].lower():
            raise ValueError("Invalid license response: " + name)
        (licenses / ("GODOT-" + name)).write_bytes(payload)

def package():
    exe = DEST / "取经2.0.exe"
    if not exe.is_file() or exe.stat().st_size < 109268480:
        raise ValueError("Exported executable missing or truncated")
    performance = json.loads((ROOT / "tests" / "art-v11-performance.json").read_text("utf-8"))
    report = {"build": "v11-20261011", "engine": "4.7.2.stable", "integration_checks": 1711,
              "rig_chapter_checks": 894,
              "packed_resource_and_gameplay_probe": "passed; editor runtime loaded only exported pack from delivery directory",
              "release_executable_home_render": "passed; actual exported EXE rendered home and exited 0",
              "performance": performance,
              "not_accepted": ["professional hand-drawn animation", "all independent boss art", "37 human-painted backgrounds", "normal full campaign", "human playtests", "physical controller", "full-flow cold-start/long-run performance"]}
    (DEST / "检查摘要.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), "utf-8")
    # Explicit allowlist: do not accidentally ship probe logs, .console executables, caches or unrelated files.
    members = [exe, DEST / "运行说明.txt", DEST / "检查摘要.json"] + sorted(path for path in (DEST / "licenses").iterdir() if path.is_file())
    text_paths = [p for p in members if p.suffix in {".txt", ".md", ".json"} and p.parent.name != "licenses"]
    for path in text_paths:
        content = path.read_text("utf-8-sig").lower()
        for marker in ["c:\\users\\", "d:\\.codex", "ghp_", "github_pat_", "sk-proj-", "netlify.app/claim", "智者不入爱河"]:
            if marker in content:
                raise ValueError("Private marker in delivery text: " + path.name)
    checksums = {str(path.relative_to(DEST)).replace("\\", "/"): hashlib.sha256(path.read_bytes()).hexdigest() for path in members}
    checksum_file = DEST / "SHA256.json"
    checksum_file.write_text(json.dumps(checksums, ensure_ascii=False, indent=2), "utf-8")
    members.append(checksum_file)
    archive = ROOT / "exports" / "重生之我也要取经-2.0-v11-Windows.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as bundle:
        for path in members:
            bundle.write(path, "重生之我也要取经-2.0-v11/" + str(path.relative_to(DEST)).replace("\\", "/"))
    with zipfile.ZipFile(archive) as bundle:
        if bundle.testzip() is not None:
            raise ValueError("ZIP CRC failure")
        print(json.dumps({"archive": str(archive), "bytes": archive.stat().st_size, "members": bundle.namelist(), "sha256": hashlib.sha256(archive.read_bytes()).hexdigest()}, ensure_ascii=False))

if __name__ == "__main__":
    import sys
    if "--prepare" in sys.argv:
        prepare()
    elif "--package" in sys.argv:
        package()
    else:
        raise SystemExit("Choose --prepare or --package")
