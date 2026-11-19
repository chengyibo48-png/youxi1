"""Extract only the matching Windows release template from the official remote TPZ.
HTTP byte ranges avoid downloading the unrelated 1.28 GB platform bundle.
zipfile verifies the extracted member CRC before it is saved.
"""
import hashlib
import io
import json
from pathlib import Path
import urllib.request
import zipfile

URL='https://godot-releases.nbg1.your-objectstorage.com/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz'
ROOT=Path(__file__).resolve().parents[1]

class RemoteArchive(io.RawIOBase):
    def __init__(self, url):
        self.url=url
        with urllib.request.urlopen(urllib.request.Request(url,method='HEAD'),timeout=30) as response:
            self.size=int(response.headers['Content-Length'])
        self.position=0
        self.transferred=0
        self.buffer=b''
        self.buffer_start=0
    def readable(self): return True
    def seekable(self): return True
    def tell(self): return self.position
    def seek(self, offset, whence=0):
        self.position=offset if whence==0 else self.position+offset if whence==1 else self.size+offset
        if self.position<0: raise ValueError('Negative archive position')
        return self.position
    def read(self, size=-1):
        if size<0: size=self.size-self.position
        size=min(size,self.size-self.position)
        if size<=0: return b''
        if not (self.buffer_start<=self.position and self.position+size<=self.buffer_start+len(self.buffer)):
            start=self.position
            end=min(self.size-1,start+max(size,1024*1024)-1)
            request=urllib.request.Request(self.url,headers={'Range':f'bytes={start}-{end}'})
            with urllib.request.urlopen(request,timeout=120) as response:
                if response.status!=206 or response.headers.get('Content-Range','').split('/')[0]!=f'bytes {start}-{end}':
                    raise RuntimeError('Official server did not honor byte range; no full-bundle fallback')
                self.buffer=response.read()
            if len(self.buffer)!=end-start+1: raise RuntimeError('Truncated byte range')
            self.buffer_start=start
            self.transferred+=len(self.buffer)
        result=self.buffer[self.position-self.buffer_start:self.position-self.buffer_start+size]
        self.position+=size
        return result

def main():
    cache=ROOT/'build/template-cache'
    cache.mkdir(parents=True,exist_ok=True)
    remote=RemoteArchive(URL)
    with zipfile.ZipFile(remote) as archive:
        versions=[n for n in archive.namelist() if n.endswith('/version.txt')]
        if len(versions)!=1: raise RuntimeError('Missing template version')
        version=archive.read(versions[0]).decode().strip()
        if version!='4.7.2.stable': raise RuntimeError('Template version mismatch: '+version)
        names=[n for n in archive.namelist() if n.endswith('/windows_release_x86_64.exe')]
        if len(names)!=1: raise RuntimeError('Matching Windows template missing')
        entry=archive.getinfo(names[0])
        print(f'Matching template: {version}; compressed Windows payload: {entry.compress_size} bytes',flush=True)
        payload=archive.read(entry)
        if not payload.startswith(b'MZ'): raise RuntimeError('Not a Windows executable')
        destination=cache/'windows_release_x86_64.exe'
        destination.write_bytes(payload)
        report={'source':URL,'version':version,'zip_member':entry.filename,'member_crc32':f'{entry.CRC:08x}',
                'sha256':hashlib.sha256(payload).hexdigest(),'size':len(payload),'downloaded_bytes':remote.transferred,
                'validation':'Official TPZ central directory, version, member CRC and PE magic'}
        (cache/'source.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
        print(json.dumps(report),flush=True)

if __name__=='__main__':main()
