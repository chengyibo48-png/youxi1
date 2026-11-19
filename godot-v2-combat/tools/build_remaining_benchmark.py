from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
text=(ROOT/'tests/weapon_performance.gd').read_text(encoding='utf-8')
text=text.replace('var benchmark_case: int=0','var benchmark_case: int=0\n var sample_target: int=600 if "--long" in OS.get_cmdline_user_args() else 120')
text=text.replace('samples.size()>=120','samples.size()>=sample_target')
text=text.replace('var file=FileAccess.open(output,FileAccess.WRITE)','output=output.replace(".json","-remaining.json")\n report.sample_target=sample_target\n var file=FileAccess.open(output,FileAccess.WRITE)')
(ROOT/'tests/remaining_performance.gd').write_text(text,encoding='utf-8')
