from pathlib import Path
import numpy as np
import wave
root=Path(__file__).resolve().parents[1]
p=root/'assets/audio';p.mkdir(exist_ok=True)
sr=22050;out=np.zeros(sr*24,dtype=np.float64)
notes=[57,60,62,64,67,69,67,64,62,60,57,55,57,62,64,67]
for idx,note in enumerate(notes*2):
 t=np.arange(int(sr*1.8))/sr;f=440*2**((note-69)/12)
 env=(1-np.exp(-t*28))*np.exp(-t*2.4)
 tone=(np.sin(2*np.pi*f*t+np.sin(2*np.pi*f*2*t)*.15)+.25*np.sin(2*np.pi*f*2.01*t)+.12*np.sin(2*np.pi*f*3*t))*env*.12
 at=int(idx*.75*sr);count=min(len(t),len(out)-at)
 if count>0:out[at:at+count]+=tone[:count]
for i in range(8):
 at=int(i*3*sr);t=np.arange(sr*3)/sr;f=440*2**((45+[0,5,7,0][i%4]-69)/12)
 out[at:at+len(t)]+=(np.sin(2*np.pi*f*t)+.2*np.sin(2*np.pi*f*1.005*t))*.04*np.sin(np.pi*t/3)**2
out=np.tanh(out);stereo=np.stack([out,np.roll(out,230)*.92],axis=1)
with wave.open(str(p/'journey-theme.wav'),'wb') as w:
 w.setnchannels(2);w.setsampwidth(2);w.setframerate(sr);w.writeframes((stereo*24000).astype('<i2').tobytes())

rng=np.random.default_rng(42)
frequencies={'slash':170,'bolt':720,'field':300,'orbit':450,'return':530,'heavy':95,'impact':110,'hit':420,'crit':760,'hurt':72,'dash':310,'skill':560,'ultimate':84,'break':145,'pickup':900,'warning':250}
for kind,f in frequencies.items():
 duration=.32 if kind in ['ultimate','break','warning'] else .14 if kind in ['heavy','impact','skill'] else .07
 t=np.arange(int(sr*duration))/sr;x=t/duration
 phase=2*np.pi*f*(t-.2*t*t/duration)
 tone=np.sin(phase)+.3*np.sin(phase*2.7)
 if kind in ['slash','dash','heavy','impact','hurt']:tone=tone*.4+rng.uniform(-1,1,len(t))*.55
 wave_data=np.tanh(tone*np.sin(np.pi*x)*(1-x)**2*.5)
 with wave.open(str(p/(kind+'.wav')),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(sr);w.writeframes((wave_data*27000).astype('<i2').tobytes())
