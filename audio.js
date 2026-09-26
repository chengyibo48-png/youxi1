// 小体积程序化配乐：不下载任何音频素材，首次点击后由 Web Audio 启动。
class XiyouAudio {
  constructor() {
    this.context = null;
    this.bgmVolume = .38;
    this.sfxVolume = .6;
    this.theme = "menu";
    this.nextBeat = 0;
    this.step = 0;
    this.voiceEnabled = true;
  }
  unlock() {
    try {
      if (!this.context) this.context = new (window.AudioContext || window.webkitAudioContext)();
      if (this.context.state === "suspended") this.context.resume();
      this.nextBeat = Math.max(this.nextBeat, this.context.currentTime + .02);
    } catch (_) {}
  }
  setVolumes(bgm, sfx) {
    this.bgmVolume = Math.max(0, Math.min(1, bgm));
    this.sfxVolume = Math.max(0, Math.min(1, sfx));
  }
  setTheme(name) {
    if (this.theme === name) return;
    this.theme = name;
    this.step = 0;
    if (this.context) this.nextBeat = this.context.currentTime + .06;
  }
  setVoiceEnabled(enabled){
    this.voiceEnabled=!!enabled;
    if(!enabled)try{window.speechSynthesis?.cancel();}catch(_){}
  }
  speak(line,kind="hero"){
    if(!this.voiceEnabled||this.sfxVolume<=0||!line||!window.speechSynthesis||!window.SpeechSynthesisUtterance)return;
    try{
      window.speechSynthesis.cancel();
      const utterance=new window.SpeechSynthesisUtterance(String(line).slice(0,90));
      utterance.lang="zh-CN";utterance.rate=kind==="boss"?.86:1.05;
      utterance.pitch=kind==="boss"?.62:kind==="hero"?1.13:1;
      utterance.volume=Math.min(1,this.sfxVolume);
      const voices=window.speechSynthesis.getVoices?.()||[];
      const local=voices.find(voice=>voice.localService&&/^zh/i.test(voice.lang));
      if(!local)return;
      utterance.voice=local;
      window.speechSynthesis.speak(utterance);
    }catch(_){}
  }
  tone(freq, duration, wave = "triangle", gain = .15, at) {
    if (!this.context || freq <= 0) return;
    const t = at ?? this.context.currentTime;
    const oscillator = this.context.createOscillator();
    const envelope = this.context.createGain();
    oscillator.type = wave;
    oscillator.frequency.setValueAtTime(freq, t);
    envelope.gain.setValueAtTime(.0001, t);
    envelope.gain.linearRampToValueAtTime(gain, t + .016);
    envelope.gain.exponentialRampToValueAtTime(.0001, t + duration);
    oscillator.connect(envelope);
    envelope.connect(this.context.destination);
    oscillator.start(t);
    oscillator.stop(t + duration + .01);
  }
  effect(kind = "hit") {
    if (!this.sfxVolume) return;
    this.unlock();
    if (!this.context) return;
    const v = this.sfxVolume;
    const sounds = {
      hit:[330,.07,"square",.065], crit:[620,.13,"triangle",.11],
      hurt:[130,.17,"sawtooth",.1], skill:[760,.24,"sine",.11],
      pickup:[840,.12,"sine",.08], boss:[155,.42,"sawtooth",.1],
      level:[680,.28,"triangle",.1], select:[510,.09,"triangle",.055],
      win:[880,.45,"sine",.11], dash:[540,.1,"sawtooth",.045]
    };
    const [f,d,w,g] = sounds[kind] || sounds.hit;
    this.tone(f,d,w,g*v);
    if (kind==="level" || kind==="win") this.tone(f*1.5,d*.9,"sine",g*.55*v,this.context.currentTime+.1);
  }
  update() {
    if (!this.context || this.bgmVolume <= 0 || this.context.state !== "running") return;
    const now=this.context.currentTime;
    if (this.nextBeat < now - .5) this.nextBeat=now;
    const boss=this.theme==="boss";
    const menu=this.theme==="menu";
    const story=this.theme==="story";
    const biome=this.theme.split(":")[1] || "forest";
    const biomeRoots={wild:196,forest:220,desert:174.61,grave:164.81,night:185,cave:196,ember:174.61,city:220,river:246.94,temple:196,web:185,moon:261.63};
    const root=menu?220:story?246.94:boss?174.61:(biomeRoots[biome]||220);
    const intervals=boss?[0,3,5,7,10]:[0,2,5,7,9];
    const line=menu?[0,2,4,2,1,3,2,-1,0,2,4,3,2,1,0,-1]:
      story?[0,-1,2,-1,1,-1,3,-1,2,-1,1,-1,0,-1,-1,-1]:
      boss?[0,1,2,1,3,2,1,4,0,1,3,2,4,3,2,1]:
      [0,-1,2,1,3,-1,2,4,1,-1,3,2,4,2,1,-1];
    const seconds=60/(boss?150:menu?82:story?68:106)/2;
    let loops=0;
    while(this.nextBeat < now + .13 && loops++ < 4) {
      const i=this.step%16, note=line[i], time=this.nextBeat, gain=this.bgmVolume;
      if(note>=0) {
        const semitone=intervals[note%intervals.length]+12*Math.floor(note/intervals.length);
        const freq=root*Math.pow(2,semitone/12);
        this.tone(freq,seconds*(boss?.78:1.7),boss?"sawtooth":story?"sine":"triangle",gain*(boss?.035:.047),time);
      }
      if(i%4===0) this.tone(root/2,seconds*3,boss?"sawtooth":"sine",gain*(boss?.043:.032),time);
      if(boss && i%2===0) this.tone(72,seconds*.2,"square",gain*.028,time);
      if(!boss && !story && i%4===2) this.tone(root*2,seconds*.42,"sine",gain*.018,time);
      if(!boss&&!story&&!menu&&i===0){
        const ambience={river:[98,"sine"],ember:[74,"sawtooth"],desert:[330,"triangle"],forest:[147,"sine"],wild:[131,"triangle"],web:[185,"sine"],moon:[261,"sine"]}[biome];
        if(ambience)this.tone(ambience[0],seconds*5,ambience[1],gain*.012,time);
      }
      this.step++; this.nextBeat+=seconds;
    }
  }
}
window.XIYOU_AUDIO = XiyouAudio;
