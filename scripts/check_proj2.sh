#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
import random, unittest, struct
from pathlib import Path
Path("test-src").mkdir(exist_ok=True)
Path("test-src/ownership.s").write_text(".globl ownership\n.text\nownership:\n addi sp sp -16\n sw ra 12(sp)\n jal read_matrix\n jal free\n lw ra 12(sp)\n addi sp sp 16\n jr ra\n")
from framework import AssemblyTest, _venus_default_args
_venus_default_args.append('-mc')
rng=random.Random(6102)
def signed(x): return (x+2**31)%2**32-2**31
class Oracle(unittest.TestCase):
    def test_products(self):
        for case in range(36):
            r,k,c=(rng.randint(1,7) for _ in range(3))
            a=[rng.choice([-2147483648,2147483647,-7,0,13]) for _ in range(r*k)]
            b=[rng.randint(-100,100) for _ in range(k*c)]
            expected=[signed(sum(a[i*k+q]*b[q*c+j] for q in range(k))) for i in range(r) for j in range(c)]
            t=AssemblyTest(self,'matmul.s'); t.include('dot.s')
            aa=t.array(a); bb=t.array(b); out=t.array([-123]*(r*c))
            t.input_array('a0',aa); t.input_scalar('a1',r); t.input_scalar('a2',k)
            t.input_array('a3',bb); t.input_scalar('a4',k); t.input_scalar('a5',c); t.input_array('a6',out)
            t.call('matmul'); t.check_array(out,expected); t.check_array(aa,a); t.check_array(bb,b); t.execute()
        print('36 seeded rectangular signed-overflow products and input preservation passed')
    def test_read_ownership(self):
        t=AssemblyTest(self,'../test-src/ownership.s'); t.include('read_matrix.s')
        t.input_read_filename('a0','../tests/read-matrix-1/input.bin')
        t.input_array('a1',t.array([0])); t.input_array('a2',t.array([0]))
        t.call('ownership'); t.execute()
    def test_generated_networks(self):
        folder=Path('test-src/generated'); folder.mkdir(exist_ok=True)
        def mm(a,b,r,k,c): return [signed(sum(a[i*k+q]*b[q*c+j] for q in range(k))) for i in range(r) for j in range(c)]
        def save(name,r,c,data):
            path=folder/name; path.write_bytes(struct.pack('<'+'i'*(len(data)+2),r,c,*data)); return 'generated/'+name
        for case in range(16):
            n,h,o,batch=(rng.randint(1,6) for _ in range(4))
            a=[rng.randint(-20,20) for _ in range(h*n)]
            b=[rng.randint(-20,20) for _ in range(o*h)]
            x=[rng.randint(-20,20) for _ in range(n*batch)]
            if case==0: a=[0]*len(a)
            hidden=[max(0,v) for v in mm(a,x,h,n,batch)]
            output=mm(b,hidden,o,h,batch)
            label=output.index(max(output))
            args=[save('m0.bin',h,n,a),save('m1.bin',o,h,b),save('input.bin',n,batch,x),'generated/output.bin']
            reference=save('reference.bin',o,batch,output)
            t=AssemblyTest(self,'classify.s')
            for name in ['argmax','dot','matmul','read_matrix','relu','write_matrix']: t.include(name+'.s')
            silent=case%2
            t.input_scalar('a2',silent); t.call('classify'); t.check_scalar('a0',label); t.execute(args=args)
            t.check_file_output(args[-1],reference)
            t.check_stdout(('' if silent else str(label)+'\n\n')+'Exited with error code 0')
        print('16 generated multi-column networks, complete output bytes, labels, ties, printing and silent paths passed')
    def test_classifier_silent(self):
        t=AssemblyTest(self,'classify.s')
        for name in ['argmax','dot','matmul','read_matrix','relu','write_matrix']: t.include(name+'.s')
        t.input_scalar('a2',1); t.call('classify'); t.check_scalar('a0',2)
        t.execute(args=['../tests/classify-1/m0.bin','../tests/classify-1/m1.bin','../tests/classify-1/input.bin','../tests/classify-1/oracle-output.bin'])
        t.check_file_output('../tests/classify-1/oracle-output.bin','../tests/classify-1/reference.bin')
unittest.main()
PY
