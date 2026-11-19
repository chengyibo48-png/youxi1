"""Original short role/interaction cues; no recordings or external licensed samples."""
from pathlib import Path
import wave
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
rate=22050
palette={'wukong':(240,1.8),'tangseng':(540,3.0),'bajie':(90,1.3),'shaseng':(330,2.4),'bailongma':(710,2.8)}
rng=np.random.default_rng(37081)

def write(name, frequency, length, metallic, noise):
 t=np.arange(int(length*rate))/rate
 env=np.minimum(1,t/.006)*np.exp(-t/(length*.22))
 phase=2*np.pi*(frequency*t+frequency*.1*t*t/length)
 signal=np.sin(phase)*.45+np.sin(phase*metallic)*.12+rng.normal(0,noise,t.size)
 signal=np.tanh(signal*env)*.45
 with wave.open(str(ROOT/'assets/audio'/f'{name}.wav'),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
  f.writeframes((signal*32767).astype('<i2').tobytes())

for role,(frequency,metallic) in palette.items():
 for kind,multiplier,length in [('skill',1,.24),('ultimate',.65,.48),('dash',1.5,.13),('heavy',.7,.30)]:
  write(role+'_'+kind,frequency*multiplier,length,metallic,.13 if role=='bajie' else .035)
skills={
 'wukong':['summon','dash','freeze','lunge','mark','orbit','windwheel'],
 'tangseng':['heal','convert','beam','sanctuary','counter','pull','wake_bell'],
 'bajie':['shield','slam','quake','charge','pull','resource','rake_wall'],
 'shaseng':['sand','wave','fan','root','blink','detonate','sand_guardian'],
 'bailongma':['wave','dragon','breath','evade','waterwall','pursue','arrow_rain']}
ultimates={'wukong':['giant','avatars','ring_storm'],'tangseng':['purification','chant','golden_city'],'bajie':['marshal','quakes','mountain_rake'],'shaseng':['sandstorm','sandburst','mark_collapse'],'bailongma':['dragonflight','tide','sky_bow']}
for role,(frequency,metallic) in palette.items():
 for index,effect in enumerate(skills[role]):write(role+'_skill_'+effect,frequency*(.8+index*.17),.16+index*.035,metallic+index*.12,.08 if role=='bajie' else .025)
 for index,effect in enumerate(ultimates[role]):write(role+'_ultimate_'+effect,frequency*(.55+index*.25),.48+index*.1,metallic+.4,.06)
for name,freq,noise in [('guard',210,.06),('shield',640,.02),('wall',125,.17),('empty',350,.025)]:
 write(name,freq,.12,2.7,noise)
print('74 original role, ability and interaction audio cues generated.')
