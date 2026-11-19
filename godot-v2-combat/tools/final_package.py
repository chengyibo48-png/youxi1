from pathlib import Path
import zipfile,hashlib,json,re
root=Path(__file__).resolve().parents[1]
release=root/'build'/'Final-2.0'
windows=release/'Windows'
source_files=[]
for folder in ['scripts','data','assets']:
 source_files.extend(p for p in (root/folder).rglob('*') if p.is_file() and p.suffix not in ['.import','.tmp','.bak'])
for p in (root/'tests').glob('*.gd'):source_files.append(p)
for p in (root/'tools').glob('*'):
 if p.is_file() and p.suffix in ['.gd','.py','.ps1','.md','.js']:source_files.append(p)
for name in ['project.godot','Main.tscn','export_presets.cfg','README.md','FINAL_REPORT.md','PROJECT_STATUS.md','VALIDATION.md','Start-Demo.cmd','Start-Demo.ps1']:source_files.append(root/name)
# No local account names, credential files, deployment caches, logs, or saves.
for p in source_files:
 if any(part in ['.git','.godot','.publisher','node_modules','web-site'] for part in p.relative_to(root).parts):raise RuntimeError('Unexpected private/cache file')
 if p.suffix in ['.gd','.py','.ps1','.md','.json','.cfg','.godot','.tscn']:
  text=p.read_text(encoding='utf-8-sig')
  if re.search(r'(?i)(ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|C:[\\/]Users[\\/])',text):raise RuntimeError('Potential credential or local profile path: '+str(p.relative_to(root)))
with zipfile.ZipFile(release/'取经2.0-整合源码.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(set(source_files)):z.write(p,'取经2.0-源码/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(release/'取经2.0-Windows整合版.zip','w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(windows.rglob('*')):
  if p.is_file():z.write(p,'取经2.0/'+p.relative_to(windows).as_posix())
for name in ['取经2.0-整合源码.zip','取经2.0-Windows整合版.zip']:
 p=release/name
 with zipfile.ZipFile(p) as z:
  if z.testzip():raise RuntimeError('Corrupt archive: '+name)
checks=[]
for p in sorted(release.glob('*.zip')):checks.append(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name)
(release/'SHA256.txt').write_text('\n'.join(checks)+'\n',encoding='utf-8')
(release/'package-audit.json').write_text(json.dumps({'source_files':len(set(source_files)),'credentials_and_profile_path_scan':'PASS','git_and_tool_caches':'EXCLUDED','zip_integrity':'PASS'},ensure_ascii=False,indent=2),encoding='utf-8')
print('PACKAGES READY:',len(set(source_files)),'source files; privacy scan and ZIP integrity PASS')
