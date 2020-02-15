
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	80010113          	addi	sp,sp,-2048 # 8000a800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000a617          	auipc	a2,0xa
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000a000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	db478793          	addi	a5,a5,-588 # 80005e10 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd57a3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	cba78793          	addi	a5,a5,-838 # 80000d60 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  timerinit();
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	f58080e7          	jalr	-168(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000cc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000d0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000d2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000d4:	30200073          	mret
}
    800000d8:	60a2                	ld	ra,8(sp)
    800000da:	6402                	ld	s0,0(sp)
    800000dc:	0141                	addi	sp,sp,16
    800000de:	8082                	ret

00000000800000e0 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    800000e0:	7119                	addi	sp,sp,-128
    800000e2:	fc86                	sd	ra,120(sp)
    800000e4:	f8a2                	sd	s0,112(sp)
    800000e6:	f4a6                	sd	s1,104(sp)
    800000e8:	f0ca                	sd	s2,96(sp)
    800000ea:	ecce                	sd	s3,88(sp)
    800000ec:	e8d2                	sd	s4,80(sp)
    800000ee:	e4d6                	sd	s5,72(sp)
    800000f0:	e0da                	sd	s6,64(sp)
    800000f2:	fc5e                	sd	s7,56(sp)
    800000f4:	f862                	sd	s8,48(sp)
    800000f6:	f466                	sd	s9,40(sp)
    800000f8:	f06a                	sd	s10,32(sp)
    800000fa:	ec6e                	sd	s11,24(sp)
    800000fc:	0100                	addi	s0,sp,128
    800000fe:	8b2a                	mv	s6,a0
    80000100:	8aae                	mv	s5,a1
    80000102:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000104:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000108:	00012517          	auipc	a0,0x12
    8000010c:	6f850513          	addi	a0,a0,1784 # 80012800 <cons>
    80000110:	00001097          	auipc	ra,0x1
    80000114:	9da080e7          	jalr	-1574(ra) # 80000aea <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000118:	00012497          	auipc	s1,0x12
    8000011c:	6e848493          	addi	s1,s1,1768 # 80012800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000120:	89a6                	mv	s3,s1
    80000122:	00012917          	auipc	s2,0x12
    80000126:	77690913          	addi	s2,s2,1910 # 80012898 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000012a:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000012c:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000012e:	4da9                	li	s11,10
  while(n > 0){
    80000130:	07405863          	blez	s4,800001a0 <consoleread+0xc0>
    while(cons.r == cons.w){
    80000134:	0984a783          	lw	a5,152(s1)
    80000138:	09c4a703          	lw	a4,156(s1)
    8000013c:	02f71463          	bne	a4,a5,80000164 <consoleread+0x84>
      if(myproc()->killed){
    80000140:	00001097          	auipc	ra,0x1
    80000144:	7c6080e7          	jalr	1990(ra) # 80001906 <myproc>
    80000148:	591c                	lw	a5,48(a0)
    8000014a:	e7b5                	bnez	a5,800001b6 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000014c:	85ce                	mv	a1,s3
    8000014e:	854a                	mv	a0,s2
    80000150:	00002097          	auipc	ra,0x2
    80000154:	fd0080e7          	jalr	-48(ra) # 80002120 <sleep>
    while(cons.r == cons.w){
    80000158:	0984a783          	lw	a5,152(s1)
    8000015c:	09c4a703          	lw	a4,156(s1)
    80000160:	fef700e3          	beq	a4,a5,80000140 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000164:	0017871b          	addiw	a4,a5,1
    80000168:	08e4ac23          	sw	a4,152(s1)
    8000016c:	07f7f713          	andi	a4,a5,127
    80000170:	9726                	add	a4,a4,s1
    80000172:	01874703          	lbu	a4,24(a4)
    80000176:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    8000017a:	079c0663          	beq	s8,s9,800001e6 <consoleread+0x106>
    cbuf = c;
    8000017e:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000182:	4685                	li	a3,1
    80000184:	f8f40613          	addi	a2,s0,-113
    80000188:	85d6                	mv	a1,s5
    8000018a:	855a                	mv	a0,s6
    8000018c:	00002097          	auipc	ra,0x2
    80000190:	1f4080e7          	jalr	500(ra) # 80002380 <either_copyout>
    80000194:	01a50663          	beq	a0,s10,800001a0 <consoleread+0xc0>
    dst++;
    80000198:	0a85                	addi	s5,s5,1
    --n;
    8000019a:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    8000019c:	f9bc1ae3          	bne	s8,s11,80000130 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001a0:	00012517          	auipc	a0,0x12
    800001a4:	66050513          	addi	a0,a0,1632 # 80012800 <cons>
    800001a8:	00001097          	auipc	ra,0x1
    800001ac:	9aa080e7          	jalr	-1622(ra) # 80000b52 <release>

  return target - n;
    800001b0:	414b853b          	subw	a0,s7,s4
    800001b4:	a811                	j	800001c8 <consoleread+0xe8>
        release(&cons.lock);
    800001b6:	00012517          	auipc	a0,0x12
    800001ba:	64a50513          	addi	a0,a0,1610 # 80012800 <cons>
    800001be:	00001097          	auipc	ra,0x1
    800001c2:	994080e7          	jalr	-1644(ra) # 80000b52 <release>
        return -1;
    800001c6:	557d                	li	a0,-1
}
    800001c8:	70e6                	ld	ra,120(sp)
    800001ca:	7446                	ld	s0,112(sp)
    800001cc:	74a6                	ld	s1,104(sp)
    800001ce:	7906                	ld	s2,96(sp)
    800001d0:	69e6                	ld	s3,88(sp)
    800001d2:	6a46                	ld	s4,80(sp)
    800001d4:	6aa6                	ld	s5,72(sp)
    800001d6:	6b06                	ld	s6,64(sp)
    800001d8:	7be2                	ld	s7,56(sp)
    800001da:	7c42                	ld	s8,48(sp)
    800001dc:	7ca2                	ld	s9,40(sp)
    800001de:	7d02                	ld	s10,32(sp)
    800001e0:	6de2                	ld	s11,24(sp)
    800001e2:	6109                	addi	sp,sp,128
    800001e4:	8082                	ret
      if(n < target){
    800001e6:	000a071b          	sext.w	a4,s4
    800001ea:	fb777be3          	bgeu	a4,s7,800001a0 <consoleread+0xc0>
        cons.r--;
    800001ee:	00012717          	auipc	a4,0x12
    800001f2:	6af72523          	sw	a5,1706(a4) # 80012898 <cons+0x98>
    800001f6:	b76d                	j	800001a0 <consoleread+0xc0>

00000000800001f8 <consputc>:
  if(panicked){
    800001f8:	00029797          	auipc	a5,0x29
    800001fc:	e207a783          	lw	a5,-480(a5) # 80029018 <panicked>
    80000200:	c391                	beqz	a5,80000204 <consputc+0xc>
    for(;;)
    80000202:	a001                	j	80000202 <consputc+0xa>
{
    80000204:	1141                	addi	sp,sp,-16
    80000206:	e406                	sd	ra,8(sp)
    80000208:	e022                	sd	s0,0(sp)
    8000020a:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000020c:	10000793          	li	a5,256
    80000210:	00f50a63          	beq	a0,a5,80000224 <consputc+0x2c>
    uartputc(c);
    80000214:	00000097          	auipc	ra,0x0
    80000218:	5d2080e7          	jalr	1490(ra) # 800007e6 <uartputc>
}
    8000021c:	60a2                	ld	ra,8(sp)
    8000021e:	6402                	ld	s0,0(sp)
    80000220:	0141                	addi	sp,sp,16
    80000222:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    80000224:	4521                	li	a0,8
    80000226:	00000097          	auipc	ra,0x0
    8000022a:	5c0080e7          	jalr	1472(ra) # 800007e6 <uartputc>
    8000022e:	02000513          	li	a0,32
    80000232:	00000097          	auipc	ra,0x0
    80000236:	5b4080e7          	jalr	1460(ra) # 800007e6 <uartputc>
    8000023a:	4521                	li	a0,8
    8000023c:	00000097          	auipc	ra,0x0
    80000240:	5aa080e7          	jalr	1450(ra) # 800007e6 <uartputc>
    80000244:	bfe1                	j	8000021c <consputc+0x24>

0000000080000246 <consolewrite>:
{
    80000246:	715d                	addi	sp,sp,-80
    80000248:	e486                	sd	ra,72(sp)
    8000024a:	e0a2                	sd	s0,64(sp)
    8000024c:	fc26                	sd	s1,56(sp)
    8000024e:	f84a                	sd	s2,48(sp)
    80000250:	f44e                	sd	s3,40(sp)
    80000252:	f052                	sd	s4,32(sp)
    80000254:	ec56                	sd	s5,24(sp)
    80000256:	0880                	addi	s0,sp,80
    80000258:	89aa                	mv	s3,a0
    8000025a:	84ae                	mv	s1,a1
    8000025c:	8ab2                	mv	s5,a2
  acquire(&cons.lock);
    8000025e:	00012517          	auipc	a0,0x12
    80000262:	5a250513          	addi	a0,a0,1442 # 80012800 <cons>
    80000266:	00001097          	auipc	ra,0x1
    8000026a:	884080e7          	jalr	-1916(ra) # 80000aea <acquire>
  for(i = 0; i < n; i++){
    8000026e:	03505e63          	blez	s5,800002aa <consolewrite+0x64>
    80000272:	00148913          	addi	s2,s1,1
    80000276:	fffa879b          	addiw	a5,s5,-1
    8000027a:	1782                	slli	a5,a5,0x20
    8000027c:	9381                	srli	a5,a5,0x20
    8000027e:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000280:	5a7d                	li	s4,-1
    80000282:	4685                	li	a3,1
    80000284:	8626                	mv	a2,s1
    80000286:	85ce                	mv	a1,s3
    80000288:	fbf40513          	addi	a0,s0,-65
    8000028c:	00002097          	auipc	ra,0x2
    80000290:	14a080e7          	jalr	330(ra) # 800023d6 <either_copyin>
    80000294:	01450b63          	beq	a0,s4,800002aa <consolewrite+0x64>
    consputc(c);
    80000298:	fbf44503          	lbu	a0,-65(s0)
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	f5c080e7          	jalr	-164(ra) # 800001f8 <consputc>
  for(i = 0; i < n; i++){
    800002a4:	0485                	addi	s1,s1,1
    800002a6:	fd249ee3          	bne	s1,s2,80000282 <consolewrite+0x3c>
  release(&cons.lock);
    800002aa:	00012517          	auipc	a0,0x12
    800002ae:	55650513          	addi	a0,a0,1366 # 80012800 <cons>
    800002b2:	00001097          	auipc	ra,0x1
    800002b6:	8a0080e7          	jalr	-1888(ra) # 80000b52 <release>
}
    800002ba:	8556                	mv	a0,s5
    800002bc:	60a6                	ld	ra,72(sp)
    800002be:	6406                	ld	s0,64(sp)
    800002c0:	74e2                	ld	s1,56(sp)
    800002c2:	7942                	ld	s2,48(sp)
    800002c4:	79a2                	ld	s3,40(sp)
    800002c6:	7a02                	ld	s4,32(sp)
    800002c8:	6ae2                	ld	s5,24(sp)
    800002ca:	6161                	addi	sp,sp,80
    800002cc:	8082                	ret

00000000800002ce <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ce:	1101                	addi	sp,sp,-32
    800002d0:	ec06                	sd	ra,24(sp)
    800002d2:	e822                	sd	s0,16(sp)
    800002d4:	e426                	sd	s1,8(sp)
    800002d6:	e04a                	sd	s2,0(sp)
    800002d8:	1000                	addi	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002dc:	00012517          	auipc	a0,0x12
    800002e0:	52450513          	addi	a0,a0,1316 # 80012800 <cons>
    800002e4:	00001097          	auipc	ra,0x1
    800002e8:	806080e7          	jalr	-2042(ra) # 80000aea <acquire>

  switch(c){
    800002ec:	47d5                	li	a5,21
    800002ee:	0af48663          	beq	s1,a5,8000039a <consoleintr+0xcc>
    800002f2:	0297ca63          	blt	a5,s1,80000326 <consoleintr+0x58>
    800002f6:	47a1                	li	a5,8
    800002f8:	0ef48763          	beq	s1,a5,800003e6 <consoleintr+0x118>
    800002fc:	47c1                	li	a5,16
    800002fe:	10f49a63          	bne	s1,a5,80000412 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80000302:	00002097          	auipc	ra,0x2
    80000306:	12a080e7          	jalr	298(ra) # 8000242c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030a:	00012517          	auipc	a0,0x12
    8000030e:	4f650513          	addi	a0,a0,1270 # 80012800 <cons>
    80000312:	00001097          	auipc	ra,0x1
    80000316:	840080e7          	jalr	-1984(ra) # 80000b52 <release>
}
    8000031a:	60e2                	ld	ra,24(sp)
    8000031c:	6442                	ld	s0,16(sp)
    8000031e:	64a2                	ld	s1,8(sp)
    80000320:	6902                	ld	s2,0(sp)
    80000322:	6105                	addi	sp,sp,32
    80000324:	8082                	ret
  switch(c){
    80000326:	07f00793          	li	a5,127
    8000032a:	0af48e63          	beq	s1,a5,800003e6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000032e:	00012717          	auipc	a4,0x12
    80000332:	4d270713          	addi	a4,a4,1234 # 80012800 <cons>
    80000336:	0a072783          	lw	a5,160(a4)
    8000033a:	09872703          	lw	a4,152(a4)
    8000033e:	9f99                	subw	a5,a5,a4
    80000340:	07f00713          	li	a4,127
    80000344:	fcf763e3          	bltu	a4,a5,8000030a <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000348:	47b5                	li	a5,13
    8000034a:	0cf48763          	beq	s1,a5,80000418 <consoleintr+0x14a>
      consputc(c);
    8000034e:	8526                	mv	a0,s1
    80000350:	00000097          	auipc	ra,0x0
    80000354:	ea8080e7          	jalr	-344(ra) # 800001f8 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000358:	00012797          	auipc	a5,0x12
    8000035c:	4a878793          	addi	a5,a5,1192 # 80012800 <cons>
    80000360:	0a07a703          	lw	a4,160(a5)
    80000364:	0017069b          	addiw	a3,a4,1
    80000368:	0006861b          	sext.w	a2,a3
    8000036c:	0ad7a023          	sw	a3,160(a5)
    80000370:	07f77713          	andi	a4,a4,127
    80000374:	97ba                	add	a5,a5,a4
    80000376:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000037a:	47a9                	li	a5,10
    8000037c:	0cf48563          	beq	s1,a5,80000446 <consoleintr+0x178>
    80000380:	4791                	li	a5,4
    80000382:	0cf48263          	beq	s1,a5,80000446 <consoleintr+0x178>
    80000386:	00012797          	auipc	a5,0x12
    8000038a:	5127a783          	lw	a5,1298(a5) # 80012898 <cons+0x98>
    8000038e:	0807879b          	addiw	a5,a5,128
    80000392:	f6f61ce3          	bne	a2,a5,8000030a <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000396:	863e                	mv	a2,a5
    80000398:	a07d                	j	80000446 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039a:	00012717          	auipc	a4,0x12
    8000039e:	46670713          	addi	a4,a4,1126 # 80012800 <cons>
    800003a2:	0a072783          	lw	a5,160(a4)
    800003a6:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003aa:	00012497          	auipc	s1,0x12
    800003ae:	45648493          	addi	s1,s1,1110 # 80012800 <cons>
    while(cons.e != cons.w &&
    800003b2:	4929                	li	s2,10
    800003b4:	f4f70be3          	beq	a4,a5,8000030a <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b8:	37fd                	addiw	a5,a5,-1
    800003ba:	07f7f713          	andi	a4,a5,127
    800003be:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c0:	01874703          	lbu	a4,24(a4)
    800003c4:	f52703e3          	beq	a4,s2,8000030a <consoleintr+0x3c>
      cons.e--;
    800003c8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003cc:	10000513          	li	a0,256
    800003d0:	00000097          	auipc	ra,0x0
    800003d4:	e28080e7          	jalr	-472(ra) # 800001f8 <consputc>
    while(cons.e != cons.w &&
    800003d8:	0a04a783          	lw	a5,160(s1)
    800003dc:	09c4a703          	lw	a4,156(s1)
    800003e0:	fcf71ce3          	bne	a4,a5,800003b8 <consoleintr+0xea>
    800003e4:	b71d                	j	8000030a <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e6:	00012717          	auipc	a4,0x12
    800003ea:	41a70713          	addi	a4,a4,1050 # 80012800 <cons>
    800003ee:	0a072783          	lw	a5,160(a4)
    800003f2:	09c72703          	lw	a4,156(a4)
    800003f6:	f0f70ae3          	beq	a4,a5,8000030a <consoleintr+0x3c>
      cons.e--;
    800003fa:	37fd                	addiw	a5,a5,-1
    800003fc:	00012717          	auipc	a4,0x12
    80000400:	4af72223          	sw	a5,1188(a4) # 800128a0 <cons+0xa0>
      consputc(BACKSPACE);
    80000404:	10000513          	li	a0,256
    80000408:	00000097          	auipc	ra,0x0
    8000040c:	df0080e7          	jalr	-528(ra) # 800001f8 <consputc>
    80000410:	bded                	j	8000030a <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000412:	ee048ce3          	beqz	s1,8000030a <consoleintr+0x3c>
    80000416:	bf21                	j	8000032e <consoleintr+0x60>
      consputc(c);
    80000418:	4529                	li	a0,10
    8000041a:	00000097          	auipc	ra,0x0
    8000041e:	dde080e7          	jalr	-546(ra) # 800001f8 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000422:	00012797          	auipc	a5,0x12
    80000426:	3de78793          	addi	a5,a5,990 # 80012800 <cons>
    8000042a:	0a07a703          	lw	a4,160(a5)
    8000042e:	0017069b          	addiw	a3,a4,1
    80000432:	0006861b          	sext.w	a2,a3
    80000436:	0ad7a023          	sw	a3,160(a5)
    8000043a:	07f77713          	andi	a4,a4,127
    8000043e:	97ba                	add	a5,a5,a4
    80000440:	4729                	li	a4,10
    80000442:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000446:	00012797          	auipc	a5,0x12
    8000044a:	44c7ab23          	sw	a2,1110(a5) # 8001289c <cons+0x9c>
        wakeup(&cons.r);
    8000044e:	00012517          	auipc	a0,0x12
    80000452:	44a50513          	addi	a0,a0,1098 # 80012898 <cons+0x98>
    80000456:	00002097          	auipc	ra,0x2
    8000045a:	e50080e7          	jalr	-432(ra) # 800022a6 <wakeup>
    8000045e:	b575                	j	8000030a <consoleintr+0x3c>

0000000080000460 <consoleinit>:

void
consoleinit(void)
{
    80000460:	1141                	addi	sp,sp,-16
    80000462:	e406                	sd	ra,8(sp)
    80000464:	e022                	sd	s0,0(sp)
    80000466:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000468:	00008597          	auipc	a1,0x8
    8000046c:	cb058593          	addi	a1,a1,-848 # 80008118 <userret+0x88>
    80000470:	00012517          	auipc	a0,0x12
    80000474:	39050513          	addi	a0,a0,912 # 80012800 <cons>
    80000478:	00000097          	auipc	ra,0x0
    8000047c:	560080e7          	jalr	1376(ra) # 800009d8 <initlock>

  uartinit();
    80000480:	00000097          	auipc	ra,0x0
    80000484:	330080e7          	jalr	816(ra) # 800007b0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000488:	00023797          	auipc	a5,0x23
    8000048c:	87878793          	addi	a5,a5,-1928 # 80022d00 <devsw>
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c5070713          	addi	a4,a4,-944 # 800000e0 <consoleread>
    80000498:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000049a:	00000717          	auipc	a4,0x0
    8000049e:	dac70713          	addi	a4,a4,-596 # 80000246 <consolewrite>
    800004a2:	ef98                	sd	a4,24(a5)
}
    800004a4:	60a2                	ld	ra,8(sp)
    800004a6:	6402                	ld	s0,0(sp)
    800004a8:	0141                	addi	sp,sp,16
    800004aa:	8082                	ret

00000000800004ac <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004ac:	7179                	addi	sp,sp,-48
    800004ae:	f406                	sd	ra,40(sp)
    800004b0:	f022                	sd	s0,32(sp)
    800004b2:	ec26                	sd	s1,24(sp)
    800004b4:	e84a                	sd	s2,16(sp)
    800004b6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b8:	c219                	beqz	a2,800004be <printint+0x12>
    800004ba:	08054663          	bltz	a0,80000546 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004be:	2501                	sext.w	a0,a0
    800004c0:	4881                	li	a7,0
    800004c2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c8:	2581                	sext.w	a1,a1
    800004ca:	00008617          	auipc	a2,0x8
    800004ce:	51660613          	addi	a2,a2,1302 # 800089e0 <digits>
    800004d2:	883a                	mv	a6,a4
    800004d4:	2705                	addiw	a4,a4,1
    800004d6:	02b577bb          	remuw	a5,a0,a1
    800004da:	1782                	slli	a5,a5,0x20
    800004dc:	9381                	srli	a5,a5,0x20
    800004de:	97b2                	add	a5,a5,a2
    800004e0:	0007c783          	lbu	a5,0(a5)
    800004e4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e8:	0005079b          	sext.w	a5,a0
    800004ec:	02b5553b          	divuw	a0,a0,a1
    800004f0:	0685                	addi	a3,a3,1
    800004f2:	feb7f0e3          	bgeu	a5,a1,800004d2 <printint+0x26>

  if(sign)
    800004f6:	00088b63          	beqz	a7,8000050c <printint+0x60>
    buf[i++] = '-';
    800004fa:	fe040793          	addi	a5,s0,-32
    800004fe:	973e                	add	a4,a4,a5
    80000500:	02d00793          	li	a5,45
    80000504:	fef70823          	sb	a5,-16(a4)
    80000508:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    8000050c:	02e05763          	blez	a4,8000053a <printint+0x8e>
    80000510:	fd040793          	addi	a5,s0,-48
    80000514:	00e784b3          	add	s1,a5,a4
    80000518:	fff78913          	addi	s2,a5,-1
    8000051c:	993a                	add	s2,s2,a4
    8000051e:	377d                	addiw	a4,a4,-1
    80000520:	1702                	slli	a4,a4,0x20
    80000522:	9301                	srli	a4,a4,0x20
    80000524:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000528:	fff4c503          	lbu	a0,-1(s1)
    8000052c:	00000097          	auipc	ra,0x0
    80000530:	ccc080e7          	jalr	-820(ra) # 800001f8 <consputc>
  while(--i >= 0)
    80000534:	14fd                	addi	s1,s1,-1
    80000536:	ff2499e3          	bne	s1,s2,80000528 <printint+0x7c>
}
    8000053a:	70a2                	ld	ra,40(sp)
    8000053c:	7402                	ld	s0,32(sp)
    8000053e:	64e2                	ld	s1,24(sp)
    80000540:	6942                	ld	s2,16(sp)
    80000542:	6145                	addi	sp,sp,48
    80000544:	8082                	ret
    x = -xx;
    80000546:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000054a:	4885                	li	a7,1
    x = -xx;
    8000054c:	bf9d                	j	800004c2 <printint+0x16>

000000008000054e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000054e:	1101                	addi	sp,sp,-32
    80000550:	ec06                	sd	ra,24(sp)
    80000552:	e822                	sd	s0,16(sp)
    80000554:	e426                	sd	s1,8(sp)
    80000556:	1000                	addi	s0,sp,32
    80000558:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000055a:	00012797          	auipc	a5,0x12
    8000055e:	3607a323          	sw	zero,870(a5) # 800128c0 <pr+0x18>
  printf("panic: ");
    80000562:	00008517          	auipc	a0,0x8
    80000566:	bbe50513          	addi	a0,a0,-1090 # 80008120 <userret+0x90>
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	02e080e7          	jalr	46(ra) # 80000598 <printf>
  printf(s);
    80000572:	8526                	mv	a0,s1
    80000574:	00000097          	auipc	ra,0x0
    80000578:	024080e7          	jalr	36(ra) # 80000598 <printf>
  printf("\n");
    8000057c:	00008517          	auipc	a0,0x8
    80000580:	c3450513          	addi	a0,a0,-972 # 800081b0 <userret+0x120>
    80000584:	00000097          	auipc	ra,0x0
    80000588:	014080e7          	jalr	20(ra) # 80000598 <printf>
  panicked = 1; // freeze other CPUs
    8000058c:	4785                	li	a5,1
    8000058e:	00029717          	auipc	a4,0x29
    80000592:	a8f72523          	sw	a5,-1398(a4) # 80029018 <panicked>
  for(;;)
    80000596:	a001                	j	80000596 <panic+0x48>

0000000080000598 <printf>:
{
    80000598:	7131                	addi	sp,sp,-192
    8000059a:	fc86                	sd	ra,120(sp)
    8000059c:	f8a2                	sd	s0,112(sp)
    8000059e:	f4a6                	sd	s1,104(sp)
    800005a0:	f0ca                	sd	s2,96(sp)
    800005a2:	ecce                	sd	s3,88(sp)
    800005a4:	e8d2                	sd	s4,80(sp)
    800005a6:	e4d6                	sd	s5,72(sp)
    800005a8:	e0da                	sd	s6,64(sp)
    800005aa:	fc5e                	sd	s7,56(sp)
    800005ac:	f862                	sd	s8,48(sp)
    800005ae:	f466                	sd	s9,40(sp)
    800005b0:	f06a                	sd	s10,32(sp)
    800005b2:	ec6e                	sd	s11,24(sp)
    800005b4:	0100                	addi	s0,sp,128
    800005b6:	8a2a                	mv	s4,a0
    800005b8:	e40c                	sd	a1,8(s0)
    800005ba:	e810                	sd	a2,16(s0)
    800005bc:	ec14                	sd	a3,24(s0)
    800005be:	f018                	sd	a4,32(s0)
    800005c0:	f41c                	sd	a5,40(s0)
    800005c2:	03043823          	sd	a6,48(s0)
    800005c6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ca:	00012d97          	auipc	s11,0x12
    800005ce:	2f6dad83          	lw	s11,758(s11) # 800128c0 <pr+0x18>
  if(locking)
    800005d2:	020d9b63          	bnez	s11,80000608 <printf+0x70>
  if (fmt == 0)
    800005d6:	040a0263          	beqz	s4,8000061a <printf+0x82>
  va_start(ap, fmt);
    800005da:	00840793          	addi	a5,s0,8
    800005de:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005e2:	000a4503          	lbu	a0,0(s4)
    800005e6:	16050263          	beqz	a0,8000074a <printf+0x1b2>
    800005ea:	4481                	li	s1,0
    if(c != '%'){
    800005ec:	02500a93          	li	s5,37
    switch(c){
    800005f0:	07000b13          	li	s6,112
  consputc('x');
    800005f4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005f6:	00008b97          	auipc	s7,0x8
    800005fa:	3eab8b93          	addi	s7,s7,1002 # 800089e0 <digits>
    switch(c){
    800005fe:	07300c93          	li	s9,115
    80000602:	06400c13          	li	s8,100
    80000606:	a82d                	j	80000640 <printf+0xa8>
    acquire(&pr.lock);
    80000608:	00012517          	auipc	a0,0x12
    8000060c:	2a050513          	addi	a0,a0,672 # 800128a8 <pr>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	4da080e7          	jalr	1242(ra) # 80000aea <acquire>
    80000618:	bf7d                	j	800005d6 <printf+0x3e>
    panic("null fmt");
    8000061a:	00008517          	auipc	a0,0x8
    8000061e:	b1650513          	addi	a0,a0,-1258 # 80008130 <userret+0xa0>
    80000622:	00000097          	auipc	ra,0x0
    80000626:	f2c080e7          	jalr	-212(ra) # 8000054e <panic>
      consputc(c);
    8000062a:	00000097          	auipc	ra,0x0
    8000062e:	bce080e7          	jalr	-1074(ra) # 800001f8 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000632:	2485                	addiw	s1,s1,1
    80000634:	009a07b3          	add	a5,s4,s1
    80000638:	0007c503          	lbu	a0,0(a5)
    8000063c:	10050763          	beqz	a0,8000074a <printf+0x1b2>
    if(c != '%'){
    80000640:	ff5515e3          	bne	a0,s5,8000062a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000644:	2485                	addiw	s1,s1,1
    80000646:	009a07b3          	add	a5,s4,s1
    8000064a:	0007c783          	lbu	a5,0(a5)
    8000064e:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000652:	cfe5                	beqz	a5,8000074a <printf+0x1b2>
    switch(c){
    80000654:	05678a63          	beq	a5,s6,800006a8 <printf+0x110>
    80000658:	02fb7663          	bgeu	s6,a5,80000684 <printf+0xec>
    8000065c:	09978963          	beq	a5,s9,800006ee <printf+0x156>
    80000660:	07800713          	li	a4,120
    80000664:	0ce79863          	bne	a5,a4,80000734 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	85ea                	mv	a1,s10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e32080e7          	jalr	-462(ra) # 800004ac <printint>
      break;
    80000682:	bf45                	j	80000632 <printf+0x9a>
    switch(c){
    80000684:	0b578263          	beq	a5,s5,80000728 <printf+0x190>
    80000688:	0b879663          	bne	a5,s8,80000734 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4605                	li	a2,1
    8000069a:	45a9                	li	a1,10
    8000069c:	4388                	lw	a0,0(a5)
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	e0e080e7          	jalr	-498(ra) # 800004ac <printint>
      break;
    800006a6:	b771                	j	80000632 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006b8:	03000513          	li	a0,48
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	b3c080e7          	jalr	-1220(ra) # 800001f8 <consputc>
  consputc('x');
    800006c4:	07800513          	li	a0,120
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	b30080e7          	jalr	-1232(ra) # 800001f8 <consputc>
    800006d0:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d2:	03c9d793          	srli	a5,s3,0x3c
    800006d6:	97de                	add	a5,a5,s7
    800006d8:	0007c503          	lbu	a0,0(a5)
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	b1c080e7          	jalr	-1252(ra) # 800001f8 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e4:	0992                	slli	s3,s3,0x4
    800006e6:	397d                	addiw	s2,s2,-1
    800006e8:	fe0915e3          	bnez	s2,800006d2 <printf+0x13a>
    800006ec:	b799                	j	80000632 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006ee:	f8843783          	ld	a5,-120(s0)
    800006f2:	00878713          	addi	a4,a5,8
    800006f6:	f8e43423          	sd	a4,-120(s0)
    800006fa:	0007b903          	ld	s2,0(a5)
    800006fe:	00090e63          	beqz	s2,8000071a <printf+0x182>
      for(; *s; s++)
    80000702:	00094503          	lbu	a0,0(s2)
    80000706:	d515                	beqz	a0,80000632 <printf+0x9a>
        consputc(*s);
    80000708:	00000097          	auipc	ra,0x0
    8000070c:	af0080e7          	jalr	-1296(ra) # 800001f8 <consputc>
      for(; *s; s++)
    80000710:	0905                	addi	s2,s2,1
    80000712:	00094503          	lbu	a0,0(s2)
    80000716:	f96d                	bnez	a0,80000708 <printf+0x170>
    80000718:	bf29                	j	80000632 <printf+0x9a>
        s = "(null)";
    8000071a:	00008917          	auipc	s2,0x8
    8000071e:	a0e90913          	addi	s2,s2,-1522 # 80008128 <userret+0x98>
      for(; *s; s++)
    80000722:	02800513          	li	a0,40
    80000726:	b7cd                	j	80000708 <printf+0x170>
      consputc('%');
    80000728:	8556                	mv	a0,s5
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	ace080e7          	jalr	-1330(ra) # 800001f8 <consputc>
      break;
    80000732:	b701                	j	80000632 <printf+0x9a>
      consputc('%');
    80000734:	8556                	mv	a0,s5
    80000736:	00000097          	auipc	ra,0x0
    8000073a:	ac2080e7          	jalr	-1342(ra) # 800001f8 <consputc>
      consputc(c);
    8000073e:	854a                	mv	a0,s2
    80000740:	00000097          	auipc	ra,0x0
    80000744:	ab8080e7          	jalr	-1352(ra) # 800001f8 <consputc>
      break;
    80000748:	b5ed                	j	80000632 <printf+0x9a>
  if(locking)
    8000074a:	020d9163          	bnez	s11,8000076c <printf+0x1d4>
}
    8000074e:	70e6                	ld	ra,120(sp)
    80000750:	7446                	ld	s0,112(sp)
    80000752:	74a6                	ld	s1,104(sp)
    80000754:	7906                	ld	s2,96(sp)
    80000756:	69e6                	ld	s3,88(sp)
    80000758:	6a46                	ld	s4,80(sp)
    8000075a:	6aa6                	ld	s5,72(sp)
    8000075c:	6b06                	ld	s6,64(sp)
    8000075e:	7be2                	ld	s7,56(sp)
    80000760:	7c42                	ld	s8,48(sp)
    80000762:	7ca2                	ld	s9,40(sp)
    80000764:	7d02                	ld	s10,32(sp)
    80000766:	6de2                	ld	s11,24(sp)
    80000768:	6129                	addi	sp,sp,192
    8000076a:	8082                	ret
    release(&pr.lock);
    8000076c:	00012517          	auipc	a0,0x12
    80000770:	13c50513          	addi	a0,a0,316 # 800128a8 <pr>
    80000774:	00000097          	auipc	ra,0x0
    80000778:	3de080e7          	jalr	990(ra) # 80000b52 <release>
}
    8000077c:	bfc9                	j	8000074e <printf+0x1b6>

000000008000077e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000077e:	1101                	addi	sp,sp,-32
    80000780:	ec06                	sd	ra,24(sp)
    80000782:	e822                	sd	s0,16(sp)
    80000784:	e426                	sd	s1,8(sp)
    80000786:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000788:	00012497          	auipc	s1,0x12
    8000078c:	12048493          	addi	s1,s1,288 # 800128a8 <pr>
    80000790:	00008597          	auipc	a1,0x8
    80000794:	9b058593          	addi	a1,a1,-1616 # 80008140 <userret+0xb0>
    80000798:	8526                	mv	a0,s1
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	23e080e7          	jalr	574(ra) # 800009d8 <initlock>
  pr.locking = 1;
    800007a2:	4785                	li	a5,1
    800007a4:	cc9c                	sw	a5,24(s1)
}
    800007a6:	60e2                	ld	ra,24(sp)
    800007a8:	6442                	ld	s0,16(sp)
    800007aa:	64a2                	ld	s1,8(sp)
    800007ac:	6105                	addi	sp,sp,32
    800007ae:	8082                	ret

00000000800007b0 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007b0:	1141                	addi	sp,sp,-16
    800007b2:	e422                	sd	s0,8(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007d4:	471d                	li	a4,7
    800007d6:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007da:	4705                	li	a4,1
    800007dc:	00e780a3          	sb	a4,1(a5)
}
    800007e0:	6422                	ld	s0,8(sp)
    800007e2:	0141                	addi	sp,sp,16
    800007e4:	8082                	ret

00000000800007e6 <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007e6:	1141                	addi	sp,sp,-16
    800007e8:	e422                	sd	s0,8(sp)
    800007ea:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007ec:	10000737          	lui	a4,0x10000
    800007f0:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007f4:	0ff7f793          	andi	a5,a5,255
    800007f8:	0207f793          	andi	a5,a5,32
    800007fc:	dbf5                	beqz	a5,800007f0 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007fe:	0ff57513          	andi	a0,a0,255
    80000802:	100007b7          	lui	a5,0x10000
    80000806:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000080a:	6422                	ld	s0,8(sp)
    8000080c:	0141                	addi	sp,sp,16
    8000080e:	8082                	ret

0000000080000810 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e422                	sd	s0,8(sp)
    80000814:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000081e:	8b85                	andi	a5,a5,1
    80000820:	cb91                	beqz	a5,80000834 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000082a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000082e:	6422                	ld	s0,8(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret
    return -1;
    80000834:	557d                	li	a0,-1
    80000836:	bfe5                	j	8000082e <uartgetc+0x1e>

0000000080000838 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000838:	1101                	addi	sp,sp,-32
    8000083a:	ec06                	sd	ra,24(sp)
    8000083c:	e822                	sd	s0,16(sp)
    8000083e:	e426                	sd	s1,8(sp)
    80000840:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000842:	54fd                	li	s1,-1
    int c = uartgetc();
    80000844:	00000097          	auipc	ra,0x0
    80000848:	fcc080e7          	jalr	-52(ra) # 80000810 <uartgetc>
    if(c == -1)
    8000084c:	00950763          	beq	a0,s1,8000085a <uartintr+0x22>
      break;
    consoleintr(c);
    80000850:	00000097          	auipc	ra,0x0
    80000854:	a7e080e7          	jalr	-1410(ra) # 800002ce <consoleintr>
  while(1){
    80000858:	b7f5                	j	80000844 <uartintr+0xc>
  }
}
    8000085a:	60e2                	ld	ra,24(sp)
    8000085c:	6442                	ld	s0,16(sp)
    8000085e:	64a2                	ld	s1,8(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret

0000000080000864 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000864:	1101                	addi	sp,sp,-32
    80000866:	ec06                	sd	ra,24(sp)
    80000868:	e822                	sd	s0,16(sp)
    8000086a:	e426                	sd	s1,8(sp)
    8000086c:	e04a                	sd	s2,0(sp)
    8000086e:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000870:	03451793          	slli	a5,a0,0x34
    80000874:	ebb9                	bnez	a5,800008ca <kfree+0x66>
    80000876:	84aa                	mv	s1,a0
    80000878:	00028797          	auipc	a5,0x28
    8000087c:	7e478793          	addi	a5,a5,2020 # 8002905c <end>
    80000880:	04f56563          	bltu	a0,a5,800008ca <kfree+0x66>
    80000884:	47c5                	li	a5,17
    80000886:	07ee                	slli	a5,a5,0x1b
    80000888:	04f57163          	bgeu	a0,a5,800008ca <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    8000088c:	6605                	lui	a2,0x1
    8000088e:	4585                	li	a1,1
    80000890:	00000097          	auipc	ra,0x0
    80000894:	31e080e7          	jalr	798(ra) # 80000bae <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000898:	00012917          	auipc	s2,0x12
    8000089c:	03090913          	addi	s2,s2,48 # 800128c8 <kmem>
    800008a0:	854a                	mv	a0,s2
    800008a2:	00000097          	auipc	ra,0x0
    800008a6:	248080e7          	jalr	584(ra) # 80000aea <acquire>
  r->next = kmem.freelist;
    800008aa:	01893783          	ld	a5,24(s2)
    800008ae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008b0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800008b4:	854a                	mv	a0,s2
    800008b6:	00000097          	auipc	ra,0x0
    800008ba:	29c080e7          	jalr	668(ra) # 80000b52 <release>
}
    800008be:	60e2                	ld	ra,24(sp)
    800008c0:	6442                	ld	s0,16(sp)
    800008c2:	64a2                	ld	s1,8(sp)
    800008c4:	6902                	ld	s2,0(sp)
    800008c6:	6105                	addi	sp,sp,32
    800008c8:	8082                	ret
    panic("kfree");
    800008ca:	00008517          	auipc	a0,0x8
    800008ce:	87e50513          	addi	a0,a0,-1922 # 80008148 <userret+0xb8>
    800008d2:	00000097          	auipc	ra,0x0
    800008d6:	c7c080e7          	jalr	-900(ra) # 8000054e <panic>

00000000800008da <freerange>:
{
    800008da:	7179                	addi	sp,sp,-48
    800008dc:	f406                	sd	ra,40(sp)
    800008de:	f022                	sd	s0,32(sp)
    800008e0:	ec26                	sd	s1,24(sp)
    800008e2:	e84a                	sd	s2,16(sp)
    800008e4:	e44e                	sd	s3,8(sp)
    800008e6:	e052                	sd	s4,0(sp)
    800008e8:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800008ea:	6785                	lui	a5,0x1
    800008ec:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800008f0:	94aa                	add	s1,s1,a0
    800008f2:	757d                	lui	a0,0xfffff
    800008f4:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f6:	94be                	add	s1,s1,a5
    800008f8:	0095ee63          	bltu	a1,s1,80000914 <freerange+0x3a>
    800008fc:	892e                	mv	s2,a1
    kfree(p);
    800008fe:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000900:	6985                	lui	s3,0x1
    kfree(p);
    80000902:	01448533          	add	a0,s1,s4
    80000906:	00000097          	auipc	ra,0x0
    8000090a:	f5e080e7          	jalr	-162(ra) # 80000864 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000090e:	94ce                	add	s1,s1,s3
    80000910:	fe9979e3          	bgeu	s2,s1,80000902 <freerange+0x28>
}
    80000914:	70a2                	ld	ra,40(sp)
    80000916:	7402                	ld	s0,32(sp)
    80000918:	64e2                	ld	s1,24(sp)
    8000091a:	6942                	ld	s2,16(sp)
    8000091c:	69a2                	ld	s3,8(sp)
    8000091e:	6a02                	ld	s4,0(sp)
    80000920:	6145                	addi	sp,sp,48
    80000922:	8082                	ret

0000000080000924 <kinit>:
{
    80000924:	1101                	addi	sp,sp,-32
    80000926:	ec06                	sd	ra,24(sp)
    80000928:	e822                	sd	s0,16(sp)
    8000092a:	e426                	sd	s1,8(sp)
    8000092c:	1000                	addi	s0,sp,32
  initlock(&kmem.lock, "kmem");
    8000092e:	00008597          	auipc	a1,0x8
    80000932:	82258593          	addi	a1,a1,-2014 # 80008150 <userret+0xc0>
    80000936:	00012517          	auipc	a0,0x12
    8000093a:	f9250513          	addi	a0,a0,-110 # 800128c8 <kmem>
    8000093e:	00000097          	auipc	ra,0x0
    80000942:	09a080e7          	jalr	154(ra) # 800009d8 <initlock>
  freerange(end, p);
    80000946:	087ff4b7          	lui	s1,0x87ff
    8000094a:	00449593          	slli	a1,s1,0x4
    8000094e:	00028517          	auipc	a0,0x28
    80000952:	70e50513          	addi	a0,a0,1806 # 8002905c <end>
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	f84080e7          	jalr	-124(ra) # 800008da <freerange>
  bd_init(p, p+MAXHEAP);
    8000095e:	45c5                	li	a1,17
    80000960:	05ee                	slli	a1,a1,0x1b
    80000962:	00449513          	slli	a0,s1,0x4
    80000966:	00006097          	auipc	ra,0x6
    8000096a:	5a4080e7          	jalr	1444(ra) # 80006f0a <bd_init>
}
    8000096e:	60e2                	ld	ra,24(sp)
    80000970:	6442                	ld	s0,16(sp)
    80000972:	64a2                	ld	s1,8(sp)
    80000974:	6105                	addi	sp,sp,32
    80000976:	8082                	ret

0000000080000978 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000978:	1101                	addi	sp,sp,-32
    8000097a:	ec06                	sd	ra,24(sp)
    8000097c:	e822                	sd	s0,16(sp)
    8000097e:	e426                	sd	s1,8(sp)
    80000980:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000982:	00012497          	auipc	s1,0x12
    80000986:	f4648493          	addi	s1,s1,-186 # 800128c8 <kmem>
    8000098a:	8526                	mv	a0,s1
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	15e080e7          	jalr	350(ra) # 80000aea <acquire>
  r = kmem.freelist;
    80000994:	6c84                	ld	s1,24(s1)
  if(r)
    80000996:	c885                	beqz	s1,800009c6 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000998:	609c                	ld	a5,0(s1)
    8000099a:	00012517          	auipc	a0,0x12
    8000099e:	f2e50513          	addi	a0,a0,-210 # 800128c8 <kmem>
    800009a2:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    800009a4:	00000097          	auipc	ra,0x0
    800009a8:	1ae080e7          	jalr	430(ra) # 80000b52 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    800009ac:	6605                	lui	a2,0x1
    800009ae:	4595                	li	a1,5
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	1fc080e7          	jalr	508(ra) # 80000bae <memset>
  return (void*)r;
}
    800009ba:	8526                	mv	a0,s1
    800009bc:	60e2                	ld	ra,24(sp)
    800009be:	6442                	ld	s0,16(sp)
    800009c0:	64a2                	ld	s1,8(sp)
    800009c2:	6105                	addi	sp,sp,32
    800009c4:	8082                	ret
  release(&kmem.lock);
    800009c6:	00012517          	auipc	a0,0x12
    800009ca:	f0250513          	addi	a0,a0,-254 # 800128c8 <kmem>
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	184080e7          	jalr	388(ra) # 80000b52 <release>
  if(r)
    800009d6:	b7d5                	j	800009ba <kalloc+0x42>

00000000800009d8 <initlock>:

uint64 ntest_and_set;

void
initlock(struct spinlock *lk, char *name)
{
    800009d8:	1141                	addi	sp,sp,-16
    800009da:	e422                	sd	s0,8(sp)
    800009dc:	0800                	addi	s0,sp,16
  lk->name = name;
    800009de:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009e0:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009e4:	00053823          	sd	zero,16(a0)
}
    800009e8:	6422                	ld	s0,8(sp)
    800009ea:	0141                	addi	sp,sp,16
    800009ec:	8082                	ret

00000000800009ee <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800009ee:	1101                	addi	sp,sp,-32
    800009f0:	ec06                	sd	ra,24(sp)
    800009f2:	e822                	sd	s0,16(sp)
    800009f4:	e426                	sd	s1,8(sp)
    800009f6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009f8:	100024f3          	csrr	s1,sstatus
    800009fc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000a00:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a02:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000a06:	00001097          	auipc	ra,0x1
    80000a0a:	ee4080e7          	jalr	-284(ra) # 800018ea <mycpu>
    80000a0e:	5d3c                	lw	a5,120(a0)
    80000a10:	cf89                	beqz	a5,80000a2a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a12:	00001097          	auipc	ra,0x1
    80000a16:	ed8080e7          	jalr	-296(ra) # 800018ea <mycpu>
    80000a1a:	5d3c                	lw	a5,120(a0)
    80000a1c:	2785                	addiw	a5,a5,1
    80000a1e:	dd3c                	sw	a5,120(a0)
}
    80000a20:	60e2                	ld	ra,24(sp)
    80000a22:	6442                	ld	s0,16(sp)
    80000a24:	64a2                	ld	s1,8(sp)
    80000a26:	6105                	addi	sp,sp,32
    80000a28:	8082                	ret
    mycpu()->intena = old;
    80000a2a:	00001097          	auipc	ra,0x1
    80000a2e:	ec0080e7          	jalr	-320(ra) # 800018ea <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a32:	8085                	srli	s1,s1,0x1
    80000a34:	8885                	andi	s1,s1,1
    80000a36:	dd64                	sw	s1,124(a0)
    80000a38:	bfe9                	j	80000a12 <push_off+0x24>

0000000080000a3a <pop_off>:

void
pop_off(void)
{
    80000a3a:	1141                	addi	sp,sp,-16
    80000a3c:	e406                	sd	ra,8(sp)
    80000a3e:	e022                	sd	s0,0(sp)
    80000a40:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a42:	00001097          	auipc	ra,0x1
    80000a46:	ea8080e7          	jalr	-344(ra) # 800018ea <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a4a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a4e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a50:	ef8d                	bnez	a5,80000a8a <pop_off+0x50>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a52:	5d3c                	lw	a5,120(a0)
    80000a54:	37fd                	addiw	a5,a5,-1
    80000a56:	0007871b          	sext.w	a4,a5
    80000a5a:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a5c:	02079693          	slli	a3,a5,0x20
    80000a60:	0206cd63          	bltz	a3,80000a9a <pop_off+0x60>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a64:	ef19                	bnez	a4,80000a82 <pop_off+0x48>
    80000a66:	5d7c                	lw	a5,124(a0)
    80000a68:	cf89                	beqz	a5,80000a82 <pop_off+0x48>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a6a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a6e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a72:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a7e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000a82:	60a2                	ld	ra,8(sp)
    80000a84:	6402                	ld	s0,0(sp)
    80000a86:	0141                	addi	sp,sp,16
    80000a88:	8082                	ret
    panic("pop_off - interruptible");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	6ce50513          	addi	a0,a0,1742 # 80008158 <userret+0xc8>
    80000a92:	00000097          	auipc	ra,0x0
    80000a96:	abc080e7          	jalr	-1348(ra) # 8000054e <panic>
    panic("pop_off");
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	6d650513          	addi	a0,a0,1750 # 80008170 <userret+0xe0>
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	aac080e7          	jalr	-1364(ra) # 8000054e <panic>

0000000080000aaa <holding>:
{
    80000aaa:	1101                	addi	sp,sp,-32
    80000aac:	ec06                	sd	ra,24(sp)
    80000aae:	e822                	sd	s0,16(sp)
    80000ab0:	e426                	sd	s1,8(sp)
    80000ab2:	1000                	addi	s0,sp,32
    80000ab4:	84aa                	mv	s1,a0
  push_off();
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	f38080e7          	jalr	-200(ra) # 800009ee <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000abe:	409c                	lw	a5,0(s1)
    80000ac0:	ef81                	bnez	a5,80000ad8 <holding+0x2e>
    80000ac2:	4481                	li	s1,0
  pop_off();
    80000ac4:	00000097          	auipc	ra,0x0
    80000ac8:	f76080e7          	jalr	-138(ra) # 80000a3a <pop_off>
}
    80000acc:	8526                	mv	a0,s1
    80000ace:	60e2                	ld	ra,24(sp)
    80000ad0:	6442                	ld	s0,16(sp)
    80000ad2:	64a2                	ld	s1,8(sp)
    80000ad4:	6105                	addi	sp,sp,32
    80000ad6:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000ad8:	6884                	ld	s1,16(s1)
    80000ada:	00001097          	auipc	ra,0x1
    80000ade:	e10080e7          	jalr	-496(ra) # 800018ea <mycpu>
    80000ae2:	8c89                	sub	s1,s1,a0
    80000ae4:	0014b493          	seqz	s1,s1
    80000ae8:	bff1                	j	80000ac4 <holding+0x1a>

0000000080000aea <acquire>:
{
    80000aea:	1101                	addi	sp,sp,-32
    80000aec:	ec06                	sd	ra,24(sp)
    80000aee:	e822                	sd	s0,16(sp)
    80000af0:	e426                	sd	s1,8(sp)
    80000af2:	1000                	addi	s0,sp,32
    80000af4:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	ef8080e7          	jalr	-264(ra) # 800009ee <push_off>
  if(holding(lk))
    80000afe:	8526                	mv	a0,s1
    80000b00:	00000097          	auipc	ra,0x0
    80000b04:	faa080e7          	jalr	-86(ra) # 80000aaa <holding>
    80000b08:	e901                	bnez	a0,80000b18 <acquire+0x2e>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b0a:	4685                	li	a3,1
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000b0c:	00028717          	auipc	a4,0x28
    80000b10:	51470713          	addi	a4,a4,1300 # 80029020 <ntest_and_set>
    80000b14:	4605                	li	a2,1
    80000b16:	a829                	j	80000b30 <acquire+0x46>
    panic("acquire");
    80000b18:	00007517          	auipc	a0,0x7
    80000b1c:	66050513          	addi	a0,a0,1632 # 80008178 <userret+0xe8>
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	a2e080e7          	jalr	-1490(ra) # 8000054e <panic>
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000b28:	0f50000f          	fence	iorw,ow
    80000b2c:	04c7302f          	amoadd.d.aq	zero,a2,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b30:	87b6                	mv	a5,a3
    80000b32:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b36:	2781                	sext.w	a5,a5
    80000b38:	fbe5                	bnez	a5,80000b28 <acquire+0x3e>
  __sync_synchronize();
    80000b3a:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b3e:	00001097          	auipc	ra,0x1
    80000b42:	dac080e7          	jalr	-596(ra) # 800018ea <mycpu>
    80000b46:	e888                	sd	a0,16(s1)
}
    80000b48:	60e2                	ld	ra,24(sp)
    80000b4a:	6442                	ld	s0,16(sp)
    80000b4c:	64a2                	ld	s1,8(sp)
    80000b4e:	6105                	addi	sp,sp,32
    80000b50:	8082                	ret

0000000080000b52 <release>:
{
    80000b52:	1101                	addi	sp,sp,-32
    80000b54:	ec06                	sd	ra,24(sp)
    80000b56:	e822                	sd	s0,16(sp)
    80000b58:	e426                	sd	s1,8(sp)
    80000b5a:	1000                	addi	s0,sp,32
    80000b5c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b5e:	00000097          	auipc	ra,0x0
    80000b62:	f4c080e7          	jalr	-180(ra) # 80000aaa <holding>
    80000b66:	c115                	beqz	a0,80000b8a <release+0x38>
  lk->cpu = 0;
    80000b68:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b6c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b70:	0f50000f          	fence	iorw,ow
    80000b74:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	ec2080e7          	jalr	-318(ra) # 80000a3a <pop_off>
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret
    panic("release");
    80000b8a:	00007517          	auipc	a0,0x7
    80000b8e:	5f650513          	addi	a0,a0,1526 # 80008180 <userret+0xf0>
    80000b92:	00000097          	auipc	ra,0x0
    80000b96:	9bc080e7          	jalr	-1604(ra) # 8000054e <panic>

0000000080000b9a <sys_ntas>:

uint64
sys_ntas(void)
{
    80000b9a:	1141                	addi	sp,sp,-16
    80000b9c:	e422                	sd	s0,8(sp)
    80000b9e:	0800                	addi	s0,sp,16
  return ntest_and_set;
}
    80000ba0:	00028517          	auipc	a0,0x28
    80000ba4:	48053503          	ld	a0,1152(a0) # 80029020 <ntest_and_set>
    80000ba8:	6422                	ld	s0,8(sp)
    80000baa:	0141                	addi	sp,sp,16
    80000bac:	8082                	ret

0000000080000bae <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000bae:	1141                	addi	sp,sp,-16
    80000bb0:	e422                	sd	s0,8(sp)
    80000bb2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000bb4:	ce09                	beqz	a2,80000bce <memset+0x20>
    80000bb6:	87aa                	mv	a5,a0
    80000bb8:	fff6071b          	addiw	a4,a2,-1
    80000bbc:	1702                	slli	a4,a4,0x20
    80000bbe:	9301                	srli	a4,a4,0x20
    80000bc0:	0705                	addi	a4,a4,1
    80000bc2:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000bc4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000bc8:	0785                	addi	a5,a5,1
    80000bca:	fee79de3          	bne	a5,a4,80000bc4 <memset+0x16>
  }
  return dst;
}
    80000bce:	6422                	ld	s0,8(sp)
    80000bd0:	0141                	addi	sp,sp,16
    80000bd2:	8082                	ret

0000000080000bd4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000bd4:	1141                	addi	sp,sp,-16
    80000bd6:	e422                	sd	s0,8(sp)
    80000bd8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000bda:	ca05                	beqz	a2,80000c0a <memcmp+0x36>
    80000bdc:	fff6069b          	addiw	a3,a2,-1
    80000be0:	1682                	slli	a3,a3,0x20
    80000be2:	9281                	srli	a3,a3,0x20
    80000be4:	0685                	addi	a3,a3,1
    80000be6:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000be8:	00054783          	lbu	a5,0(a0)
    80000bec:	0005c703          	lbu	a4,0(a1)
    80000bf0:	00e79863          	bne	a5,a4,80000c00 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000bf4:	0505                	addi	a0,a0,1
    80000bf6:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000bf8:	fed518e3          	bne	a0,a3,80000be8 <memcmp+0x14>
  }

  return 0;
    80000bfc:	4501                	li	a0,0
    80000bfe:	a019                	j	80000c04 <memcmp+0x30>
      return *s1 - *s2;
    80000c00:	40e7853b          	subw	a0,a5,a4
}
    80000c04:	6422                	ld	s0,8(sp)
    80000c06:	0141                	addi	sp,sp,16
    80000c08:	8082                	ret
  return 0;
    80000c0a:	4501                	li	a0,0
    80000c0c:	bfe5                	j	80000c04 <memcmp+0x30>

0000000080000c0e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000c0e:	1141                	addi	sp,sp,-16
    80000c10:	e422                	sd	s0,8(sp)
    80000c12:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000c14:	02a5e563          	bltu	a1,a0,80000c3e <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000c18:	fff6069b          	addiw	a3,a2,-1
    80000c1c:	ce11                	beqz	a2,80000c38 <memmove+0x2a>
    80000c1e:	1682                	slli	a3,a3,0x20
    80000c20:	9281                	srli	a3,a3,0x20
    80000c22:	0685                	addi	a3,a3,1
    80000c24:	96ae                	add	a3,a3,a1
    80000c26:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000c28:	0585                	addi	a1,a1,1
    80000c2a:	0785                	addi	a5,a5,1
    80000c2c:	fff5c703          	lbu	a4,-1(a1)
    80000c30:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000c34:	fed59ae3          	bne	a1,a3,80000c28 <memmove+0x1a>

  return dst;
}
    80000c38:	6422                	ld	s0,8(sp)
    80000c3a:	0141                	addi	sp,sp,16
    80000c3c:	8082                	ret
  if(s < d && s + n > d){
    80000c3e:	02061713          	slli	a4,a2,0x20
    80000c42:	9301                	srli	a4,a4,0x20
    80000c44:	00e587b3          	add	a5,a1,a4
    80000c48:	fcf578e3          	bgeu	a0,a5,80000c18 <memmove+0xa>
    d += n;
    80000c4c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000c4e:	fff6069b          	addiw	a3,a2,-1
    80000c52:	d27d                	beqz	a2,80000c38 <memmove+0x2a>
    80000c54:	02069613          	slli	a2,a3,0x20
    80000c58:	9201                	srli	a2,a2,0x20
    80000c5a:	fff64613          	not	a2,a2
    80000c5e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000c60:	17fd                	addi	a5,a5,-1
    80000c62:	177d                	addi	a4,a4,-1
    80000c64:	0007c683          	lbu	a3,0(a5)
    80000c68:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000c6c:	fec79ae3          	bne	a5,a2,80000c60 <memmove+0x52>
    80000c70:	b7e1                	j	80000c38 <memmove+0x2a>

0000000080000c72 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000c72:	1141                	addi	sp,sp,-16
    80000c74:	e406                	sd	ra,8(sp)
    80000c76:	e022                	sd	s0,0(sp)
    80000c78:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000c7a:	00000097          	auipc	ra,0x0
    80000c7e:	f94080e7          	jalr	-108(ra) # 80000c0e <memmove>
}
    80000c82:	60a2                	ld	ra,8(sp)
    80000c84:	6402                	ld	s0,0(sp)
    80000c86:	0141                	addi	sp,sp,16
    80000c88:	8082                	ret

0000000080000c8a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000c8a:	1141                	addi	sp,sp,-16
    80000c8c:	e422                	sd	s0,8(sp)
    80000c8e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000c90:	ce11                	beqz	a2,80000cac <strncmp+0x22>
    80000c92:	00054783          	lbu	a5,0(a0)
    80000c96:	cf89                	beqz	a5,80000cb0 <strncmp+0x26>
    80000c98:	0005c703          	lbu	a4,0(a1)
    80000c9c:	00f71a63          	bne	a4,a5,80000cb0 <strncmp+0x26>
    n--, p++, q++;
    80000ca0:	367d                	addiw	a2,a2,-1
    80000ca2:	0505                	addi	a0,a0,1
    80000ca4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ca6:	f675                	bnez	a2,80000c92 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000ca8:	4501                	li	a0,0
    80000caa:	a809                	j	80000cbc <strncmp+0x32>
    80000cac:	4501                	li	a0,0
    80000cae:	a039                	j	80000cbc <strncmp+0x32>
  if(n == 0)
    80000cb0:	ca09                	beqz	a2,80000cc2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000cb2:	00054503          	lbu	a0,0(a0)
    80000cb6:	0005c783          	lbu	a5,0(a1)
    80000cba:	9d1d                	subw	a0,a0,a5
}
    80000cbc:	6422                	ld	s0,8(sp)
    80000cbe:	0141                	addi	sp,sp,16
    80000cc0:	8082                	ret
    return 0;
    80000cc2:	4501                	li	a0,0
    80000cc4:	bfe5                	j	80000cbc <strncmp+0x32>

0000000080000cc6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000cc6:	1141                	addi	sp,sp,-16
    80000cc8:	e422                	sd	s0,8(sp)
    80000cca:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000ccc:	872a                	mv	a4,a0
    80000cce:	8832                	mv	a6,a2
    80000cd0:	367d                	addiw	a2,a2,-1
    80000cd2:	01005963          	blez	a6,80000ce4 <strncpy+0x1e>
    80000cd6:	0705                	addi	a4,a4,1
    80000cd8:	0005c783          	lbu	a5,0(a1)
    80000cdc:	fef70fa3          	sb	a5,-1(a4)
    80000ce0:	0585                	addi	a1,a1,1
    80000ce2:	f7f5                	bnez	a5,80000cce <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ce4:	86ba                	mv	a3,a4
    80000ce6:	00c05c63          	blez	a2,80000cfe <strncpy+0x38>
    *s++ = 0;
    80000cea:	0685                	addi	a3,a3,1
    80000cec:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000cf0:	fff6c793          	not	a5,a3
    80000cf4:	9fb9                	addw	a5,a5,a4
    80000cf6:	010787bb          	addw	a5,a5,a6
    80000cfa:	fef048e3          	bgtz	a5,80000cea <strncpy+0x24>
  return os;
}
    80000cfe:	6422                	ld	s0,8(sp)
    80000d00:	0141                	addi	sp,sp,16
    80000d02:	8082                	ret

0000000080000d04 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000d04:	1141                	addi	sp,sp,-16
    80000d06:	e422                	sd	s0,8(sp)
    80000d08:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000d0a:	02c05363          	blez	a2,80000d30 <safestrcpy+0x2c>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	96ae                	add	a3,a3,a1
    80000d18:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d1a:	00d58963          	beq	a1,a3,80000d2c <safestrcpy+0x28>
    80000d1e:	0585                	addi	a1,a1,1
    80000d20:	0785                	addi	a5,a5,1
    80000d22:	fff5c703          	lbu	a4,-1(a1)
    80000d26:	fee78fa3          	sb	a4,-1(a5)
    80000d2a:	fb65                	bnez	a4,80000d1a <safestrcpy+0x16>
    ;
  *s = 0;
    80000d2c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000d30:	6422                	ld	s0,8(sp)
    80000d32:	0141                	addi	sp,sp,16
    80000d34:	8082                	ret

0000000080000d36 <strlen>:

int
strlen(const char *s)
{
    80000d36:	1141                	addi	sp,sp,-16
    80000d38:	e422                	sd	s0,8(sp)
    80000d3a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000d3c:	00054783          	lbu	a5,0(a0)
    80000d40:	cf91                	beqz	a5,80000d5c <strlen+0x26>
    80000d42:	0505                	addi	a0,a0,1
    80000d44:	87aa                	mv	a5,a0
    80000d46:	4685                	li	a3,1
    80000d48:	9e89                	subw	a3,a3,a0
    80000d4a:	00f6853b          	addw	a0,a3,a5
    80000d4e:	0785                	addi	a5,a5,1
    80000d50:	fff7c703          	lbu	a4,-1(a5)
    80000d54:	fb7d                	bnez	a4,80000d4a <strlen+0x14>
    ;
  return n;
}
    80000d56:	6422                	ld	s0,8(sp)
    80000d58:	0141                	addi	sp,sp,16
    80000d5a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000d5c:	4501                	li	a0,0
    80000d5e:	bfe5                	j	80000d56 <strlen+0x20>

0000000080000d60 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000d60:	1141                	addi	sp,sp,-16
    80000d62:	e406                	sd	ra,8(sp)
    80000d64:	e022                	sd	s0,0(sp)
    80000d66:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000d68:	00001097          	auipc	ra,0x1
    80000d6c:	b72080e7          	jalr	-1166(ra) # 800018da <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000d70:	00028717          	auipc	a4,0x28
    80000d74:	2b870713          	addi	a4,a4,696 # 80029028 <started>
  if(cpuid() == 0){
    80000d78:	c139                	beqz	a0,80000dbe <main+0x5e>
    while(started == 0)
    80000d7a:	431c                	lw	a5,0(a4)
    80000d7c:	2781                	sext.w	a5,a5
    80000d7e:	dff5                	beqz	a5,80000d7a <main+0x1a>
      ;
    __sync_synchronize();
    80000d80:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000d84:	00001097          	auipc	ra,0x1
    80000d88:	b56080e7          	jalr	-1194(ra) # 800018da <cpuid>
    80000d8c:	85aa                	mv	a1,a0
    80000d8e:	00007517          	auipc	a0,0x7
    80000d92:	41250513          	addi	a0,a0,1042 # 800081a0 <userret+0x110>
    80000d96:	00000097          	auipc	ra,0x0
    80000d9a:	802080e7          	jalr	-2046(ra) # 80000598 <printf>
    kvminithart();    // turn on paging
    80000d9e:	00000097          	auipc	ra,0x0
    80000da2:	1ea080e7          	jalr	490(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000da6:	00001097          	auipc	ra,0x1
    80000daa:	7c6080e7          	jalr	1990(ra) # 8000256c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000dae:	00005097          	auipc	ra,0x5
    80000db2:	0a2080e7          	jalr	162(ra) # 80005e50 <plicinithart>
  }

  scheduler();        
    80000db6:	00001097          	auipc	ra,0x1
    80000dba:	09a080e7          	jalr	154(ra) # 80001e50 <scheduler>
    consoleinit();
    80000dbe:	fffff097          	auipc	ra,0xfffff
    80000dc2:	6a2080e7          	jalr	1698(ra) # 80000460 <consoleinit>
    printfinit();
    80000dc6:	00000097          	auipc	ra,0x0
    80000dca:	9b8080e7          	jalr	-1608(ra) # 8000077e <printfinit>
    printf("\n");
    80000dce:	00007517          	auipc	a0,0x7
    80000dd2:	3e250513          	addi	a0,a0,994 # 800081b0 <userret+0x120>
    80000dd6:	fffff097          	auipc	ra,0xfffff
    80000dda:	7c2080e7          	jalr	1986(ra) # 80000598 <printf>
    printf("xv6 kernel is booting\n");
    80000dde:	00007517          	auipc	a0,0x7
    80000de2:	3aa50513          	addi	a0,a0,938 # 80008188 <userret+0xf8>
    80000de6:	fffff097          	auipc	ra,0xfffff
    80000dea:	7b2080e7          	jalr	1970(ra) # 80000598 <printf>
    printf("\n");
    80000dee:	00007517          	auipc	a0,0x7
    80000df2:	3c250513          	addi	a0,a0,962 # 800081b0 <userret+0x120>
    80000df6:	fffff097          	auipc	ra,0xfffff
    80000dfa:	7a2080e7          	jalr	1954(ra) # 80000598 <printf>
    kinit();         // physical page allocator
    80000dfe:	00000097          	auipc	ra,0x0
    80000e02:	b26080e7          	jalr	-1242(ra) # 80000924 <kinit>
    kvminit();       // create kernel page table
    80000e06:	00000097          	auipc	ra,0x0
    80000e0a:	300080e7          	jalr	768(ra) # 80001106 <kvminit>
    kvminithart();   // turn on paging
    80000e0e:	00000097          	auipc	ra,0x0
    80000e12:	17a080e7          	jalr	378(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000e16:	00001097          	auipc	ra,0x1
    80000e1a:	9f4080e7          	jalr	-1548(ra) # 8000180a <procinit>
    trapinit();      // trap vectors
    80000e1e:	00001097          	auipc	ra,0x1
    80000e22:	726080e7          	jalr	1830(ra) # 80002544 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e26:	00001097          	auipc	ra,0x1
    80000e2a:	746080e7          	jalr	1862(ra) # 8000256c <trapinithart>
    plicinit();      // set up interrupt controller
    80000e2e:	00005097          	auipc	ra,0x5
    80000e32:	00c080e7          	jalr	12(ra) # 80005e3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e36:	00005097          	auipc	ra,0x5
    80000e3a:	01a080e7          	jalr	26(ra) # 80005e50 <plicinithart>
    binit();         // buffer cache
    80000e3e:	00002097          	auipc	ra,0x2
    80000e42:	f34080e7          	jalr	-204(ra) # 80002d72 <binit>
    iinit();         // inode cache
    80000e46:	00002097          	auipc	ra,0x2
    80000e4a:	5c8080e7          	jalr	1480(ra) # 8000340e <iinit>
    fileinit();      // file table
    80000e4e:	00003097          	auipc	ra,0x3
    80000e52:	7a4080e7          	jalr	1956(ra) # 800045f2 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80000e56:	4501                	li	a0,0
    80000e58:	00005097          	auipc	ra,0x5
    80000e5c:	12c080e7          	jalr	300(ra) # 80005f84 <virtio_disk_init>
    userinit();      // first user process
    80000e60:	00001097          	auipc	ra,0x1
    80000e64:	d1a080e7          	jalr	-742(ra) # 80001b7a <userinit>
    __sync_synchronize();
    80000e68:	0ff0000f          	fence
    started = 1;
    80000e6c:	4785                	li	a5,1
    80000e6e:	00028717          	auipc	a4,0x28
    80000e72:	1af72d23          	sw	a5,442(a4) # 80029028 <started>
    80000e76:	b781                	j	80000db6 <main+0x56>

0000000080000e78 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000e78:	7139                	addi	sp,sp,-64
    80000e7a:	fc06                	sd	ra,56(sp)
    80000e7c:	f822                	sd	s0,48(sp)
    80000e7e:	f426                	sd	s1,40(sp)
    80000e80:	f04a                	sd	s2,32(sp)
    80000e82:	ec4e                	sd	s3,24(sp)
    80000e84:	e852                	sd	s4,16(sp)
    80000e86:	e456                	sd	s5,8(sp)
    80000e88:	e05a                	sd	s6,0(sp)
    80000e8a:	0080                	addi	s0,sp,64
    80000e8c:	84aa                	mv	s1,a0
    80000e8e:	89ae                	mv	s3,a1
    80000e90:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000e92:	57fd                	li	a5,-1
    80000e94:	83e9                	srli	a5,a5,0x1a
    80000e96:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000e98:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000e9a:	04b7f263          	bgeu	a5,a1,80000ede <walk+0x66>
    panic("walk");
    80000e9e:	00007517          	auipc	a0,0x7
    80000ea2:	31a50513          	addi	a0,a0,794 # 800081b8 <userret+0x128>
    80000ea6:	fffff097          	auipc	ra,0xfffff
    80000eaa:	6a8080e7          	jalr	1704(ra) # 8000054e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000eae:	060a8663          	beqz	s5,80000f1a <walk+0xa2>
    80000eb2:	00000097          	auipc	ra,0x0
    80000eb6:	ac6080e7          	jalr	-1338(ra) # 80000978 <kalloc>
    80000eba:	84aa                	mv	s1,a0
    80000ebc:	c529                	beqz	a0,80000f06 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ebe:	6605                	lui	a2,0x1
    80000ec0:	4581                	li	a1,0
    80000ec2:	00000097          	auipc	ra,0x0
    80000ec6:	cec080e7          	jalr	-788(ra) # 80000bae <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000eca:	00c4d793          	srli	a5,s1,0xc
    80000ece:	07aa                	slli	a5,a5,0xa
    80000ed0:	0017e793          	ori	a5,a5,1
    80000ed4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000ed8:	3a5d                	addiw	s4,s4,-9
    80000eda:	036a0063          	beq	s4,s6,80000efa <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000ede:	0149d933          	srl	s2,s3,s4
    80000ee2:	1ff97913          	andi	s2,s2,511
    80000ee6:	090e                	slli	s2,s2,0x3
    80000ee8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000eea:	00093483          	ld	s1,0(s2)
    80000eee:	0014f793          	andi	a5,s1,1
    80000ef2:	dfd5                	beqz	a5,80000eae <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000ef4:	80a9                	srli	s1,s1,0xa
    80000ef6:	04b2                	slli	s1,s1,0xc
    80000ef8:	b7c5                	j	80000ed8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000efa:	00c9d513          	srli	a0,s3,0xc
    80000efe:	1ff57513          	andi	a0,a0,511
    80000f02:	050e                	slli	a0,a0,0x3
    80000f04:	9526                	add	a0,a0,s1
}
    80000f06:	70e2                	ld	ra,56(sp)
    80000f08:	7442                	ld	s0,48(sp)
    80000f0a:	74a2                	ld	s1,40(sp)
    80000f0c:	7902                	ld	s2,32(sp)
    80000f0e:	69e2                	ld	s3,24(sp)
    80000f10:	6a42                	ld	s4,16(sp)
    80000f12:	6aa2                	ld	s5,8(sp)
    80000f14:	6b02                	ld	s6,0(sp)
    80000f16:	6121                	addi	sp,sp,64
    80000f18:	8082                	ret
        return 0;
    80000f1a:	4501                	li	a0,0
    80000f1c:	b7ed                	j	80000f06 <walk+0x8e>

0000000080000f1e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000f1e:	7179                	addi	sp,sp,-48
    80000f20:	f406                	sd	ra,40(sp)
    80000f22:	f022                	sd	s0,32(sp)
    80000f24:	ec26                	sd	s1,24(sp)
    80000f26:	e84a                	sd	s2,16(sp)
    80000f28:	e44e                	sd	s3,8(sp)
    80000f2a:	e052                	sd	s4,0(sp)
    80000f2c:	1800                	addi	s0,sp,48
    80000f2e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000f30:	84aa                	mv	s1,a0
    80000f32:	6905                	lui	s2,0x1
    80000f34:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f36:	4985                	li	s3,1
    80000f38:	a821                	j	80000f50 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000f3a:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000f3c:	0532                	slli	a0,a0,0xc
    80000f3e:	00000097          	auipc	ra,0x0
    80000f42:	fe0080e7          	jalr	-32(ra) # 80000f1e <freewalk>
      pagetable[i] = 0;
    80000f46:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000f4a:	04a1                	addi	s1,s1,8
    80000f4c:	03248163          	beq	s1,s2,80000f6e <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000f50:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f52:	00f57793          	andi	a5,a0,15
    80000f56:	ff3782e3          	beq	a5,s3,80000f3a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000f5a:	8905                	andi	a0,a0,1
    80000f5c:	d57d                	beqz	a0,80000f4a <freewalk+0x2c>
      panic("freewalk: leaf");
    80000f5e:	00007517          	auipc	a0,0x7
    80000f62:	26250513          	addi	a0,a0,610 # 800081c0 <userret+0x130>
    80000f66:	fffff097          	auipc	ra,0xfffff
    80000f6a:	5e8080e7          	jalr	1512(ra) # 8000054e <panic>
    }
  }
  kfree((void*)pagetable);
    80000f6e:	8552                	mv	a0,s4
    80000f70:	00000097          	auipc	ra,0x0
    80000f74:	8f4080e7          	jalr	-1804(ra) # 80000864 <kfree>
}
    80000f78:	70a2                	ld	ra,40(sp)
    80000f7a:	7402                	ld	s0,32(sp)
    80000f7c:	64e2                	ld	s1,24(sp)
    80000f7e:	6942                	ld	s2,16(sp)
    80000f80:	69a2                	ld	s3,8(sp)
    80000f82:	6a02                	ld	s4,0(sp)
    80000f84:	6145                	addi	sp,sp,48
    80000f86:	8082                	ret

0000000080000f88 <kvminithart>:
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f8e:	00028797          	auipc	a5,0x28
    80000f92:	0a27b783          	ld	a5,162(a5) # 80029030 <kernel_pagetable>
    80000f96:	83b1                	srli	a5,a5,0xc
    80000f98:	577d                	li	a4,-1
    80000f9a:	177e                	slli	a4,a4,0x3f
    80000f9c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f9e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <walkaddr>:
{
    80000fac:	1141                	addi	sp,sp,-16
    80000fae:	e406                	sd	ra,8(sp)
    80000fb0:	e022                	sd	s0,0(sp)
    80000fb2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fb4:	4601                	li	a2,0
    80000fb6:	00000097          	auipc	ra,0x0
    80000fba:	ec2080e7          	jalr	-318(ra) # 80000e78 <walk>
  if(pte == 0)
    80000fbe:	c105                	beqz	a0,80000fde <walkaddr+0x32>
  if((*pte & PTE_V) == 0)
    80000fc0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fc2:	0117f693          	andi	a3,a5,17
    80000fc6:	4745                	li	a4,17
    return 0;
    80000fc8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fca:	00e68663          	beq	a3,a4,80000fd6 <walkaddr+0x2a>
}
    80000fce:	60a2                	ld	ra,8(sp)
    80000fd0:	6402                	ld	s0,0(sp)
    80000fd2:	0141                	addi	sp,sp,16
    80000fd4:	8082                	ret
  pa = PTE2PA(*pte);
    80000fd6:	83a9                	srli	a5,a5,0xa
    80000fd8:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fdc:	bfcd                	j	80000fce <walkaddr+0x22>
    return 0;
    80000fde:	4501                	li	a0,0
    80000fe0:	b7fd                	j	80000fce <walkaddr+0x22>

0000000080000fe2 <kvmpa>:
{
    80000fe2:	1101                	addi	sp,sp,-32
    80000fe4:	ec06                	sd	ra,24(sp)
    80000fe6:	e822                	sd	s0,16(sp)
    80000fe8:	e426                	sd	s1,8(sp)
    80000fea:	1000                	addi	s0,sp,32
    80000fec:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000fee:	1552                	slli	a0,a0,0x34
    80000ff0:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000ff4:	4601                	li	a2,0
    80000ff6:	00028517          	auipc	a0,0x28
    80000ffa:	03a53503          	ld	a0,58(a0) # 80029030 <kernel_pagetable>
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	e7a080e7          	jalr	-390(ra) # 80000e78 <walk>
  if(pte == 0)
    80001006:	cd09                	beqz	a0,80001020 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80001008:	6108                	ld	a0,0(a0)
    8000100a:	00157793          	andi	a5,a0,1
    8000100e:	c38d                	beqz	a5,80001030 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80001010:	8129                	srli	a0,a0,0xa
    80001012:	0532                	slli	a0,a0,0xc
}
    80001014:	9526                	add	a0,a0,s1
    80001016:	60e2                	ld	ra,24(sp)
    80001018:	6442                	ld	s0,16(sp)
    8000101a:	64a2                	ld	s1,8(sp)
    8000101c:	6105                	addi	sp,sp,32
    8000101e:	8082                	ret
    panic("kvmpa");
    80001020:	00007517          	auipc	a0,0x7
    80001024:	1b050513          	addi	a0,a0,432 # 800081d0 <userret+0x140>
    80001028:	fffff097          	auipc	ra,0xfffff
    8000102c:	526080e7          	jalr	1318(ra) # 8000054e <panic>
    panic("kvmpa");
    80001030:	00007517          	auipc	a0,0x7
    80001034:	1a050513          	addi	a0,a0,416 # 800081d0 <userret+0x140>
    80001038:	fffff097          	auipc	ra,0xfffff
    8000103c:	516080e7          	jalr	1302(ra) # 8000054e <panic>

0000000080001040 <mappages>:
{
    80001040:	715d                	addi	sp,sp,-80
    80001042:	e486                	sd	ra,72(sp)
    80001044:	e0a2                	sd	s0,64(sp)
    80001046:	fc26                	sd	s1,56(sp)
    80001048:	f84a                	sd	s2,48(sp)
    8000104a:	f44e                	sd	s3,40(sp)
    8000104c:	f052                	sd	s4,32(sp)
    8000104e:	ec56                	sd	s5,24(sp)
    80001050:	e85a                	sd	s6,16(sp)
    80001052:	e45e                	sd	s7,8(sp)
    80001054:	0880                	addi	s0,sp,80
    80001056:	8aaa                	mv	s5,a0
    80001058:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000105a:	777d                	lui	a4,0xfffff
    8000105c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001060:	167d                	addi	a2,a2,-1
    80001062:	00b609b3          	add	s3,a2,a1
    80001066:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000106a:	893e                	mv	s2,a5
    8000106c:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001070:	6b85                	lui	s7,0x1
    80001072:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	4605                	li	a2,1
    80001078:	85ca                	mv	a1,s2
    8000107a:	8556                	mv	a0,s5
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	dfc080e7          	jalr	-516(ra) # 80000e78 <walk>
    80001084:	c51d                	beqz	a0,800010b2 <mappages+0x72>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef81                	bnez	a5,800010a2 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	03390863          	beq	s2,s3,800010ca <mappages+0x8a>
    a += PGSIZE;
    8000109e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfc9                	j	80001072 <mappages+0x32>
      panic("remap");
    800010a2:	00007517          	auipc	a0,0x7
    800010a6:	13650513          	addi	a0,a0,310 # 800081d8 <userret+0x148>
    800010aa:	fffff097          	auipc	ra,0xfffff
    800010ae:	4a4080e7          	jalr	1188(ra) # 8000054e <panic>
      return -1;
    800010b2:	557d                	li	a0,-1
}
    800010b4:	60a6                	ld	ra,72(sp)
    800010b6:	6406                	ld	s0,64(sp)
    800010b8:	74e2                	ld	s1,56(sp)
    800010ba:	7942                	ld	s2,48(sp)
    800010bc:	79a2                	ld	s3,40(sp)
    800010be:	7a02                	ld	s4,32(sp)
    800010c0:	6ae2                	ld	s5,24(sp)
    800010c2:	6b42                	ld	s6,16(sp)
    800010c4:	6ba2                	ld	s7,8(sp)
    800010c6:	6161                	addi	sp,sp,80
    800010c8:	8082                	ret
  return 0;
    800010ca:	4501                	li	a0,0
    800010cc:	b7e5                	j	800010b4 <mappages+0x74>

00000000800010ce <kvmmap>:
{
    800010ce:	1141                	addi	sp,sp,-16
    800010d0:	e406                	sd	ra,8(sp)
    800010d2:	e022                	sd	s0,0(sp)
    800010d4:	0800                	addi	s0,sp,16
    800010d6:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800010d8:	86ae                	mv	a3,a1
    800010da:	85aa                	mv	a1,a0
    800010dc:	00028517          	auipc	a0,0x28
    800010e0:	f5453503          	ld	a0,-172(a0) # 80029030 <kernel_pagetable>
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	f5c080e7          	jalr	-164(ra) # 80001040 <mappages>
    800010ec:	e509                	bnez	a0,800010f6 <kvmmap+0x28>
}
    800010ee:	60a2                	ld	ra,8(sp)
    800010f0:	6402                	ld	s0,0(sp)
    800010f2:	0141                	addi	sp,sp,16
    800010f4:	8082                	ret
    panic("kvmmap");
    800010f6:	00007517          	auipc	a0,0x7
    800010fa:	0ea50513          	addi	a0,a0,234 # 800081e0 <userret+0x150>
    800010fe:	fffff097          	auipc	ra,0xfffff
    80001102:	450080e7          	jalr	1104(ra) # 8000054e <panic>

0000000080001106 <kvminit>:
{
    80001106:	1101                	addi	sp,sp,-32
    80001108:	ec06                	sd	ra,24(sp)
    8000110a:	e822                	sd	s0,16(sp)
    8000110c:	e426                	sd	s1,8(sp)
    8000110e:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001110:	00000097          	auipc	ra,0x0
    80001114:	868080e7          	jalr	-1944(ra) # 80000978 <kalloc>
    80001118:	00028797          	auipc	a5,0x28
    8000111c:	f0a7bc23          	sd	a0,-232(a5) # 80029030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001120:	6605                	lui	a2,0x1
    80001122:	4581                	li	a1,0
    80001124:	00000097          	auipc	ra,0x0
    80001128:	a8a080e7          	jalr	-1398(ra) # 80000bae <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000112c:	4699                	li	a3,6
    8000112e:	6605                	lui	a2,0x1
    80001130:	100005b7          	lui	a1,0x10000
    80001134:	10000537          	lui	a0,0x10000
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	f96080e7          	jalr	-106(ra) # 800010ce <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001140:	4699                	li	a3,6
    80001142:	6605                	lui	a2,0x1
    80001144:	100015b7          	lui	a1,0x10001
    80001148:	10001537          	lui	a0,0x10001
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f82080e7          	jalr	-126(ra) # 800010ce <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001154:	4699                	li	a3,6
    80001156:	6605                	lui	a2,0x1
    80001158:	100025b7          	lui	a1,0x10002
    8000115c:	10002537          	lui	a0,0x10002
    80001160:	00000097          	auipc	ra,0x0
    80001164:	f6e080e7          	jalr	-146(ra) # 800010ce <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001168:	4699                	li	a3,6
    8000116a:	6641                	lui	a2,0x10
    8000116c:	020005b7          	lui	a1,0x2000
    80001170:	02000537          	lui	a0,0x2000
    80001174:	00000097          	auipc	ra,0x0
    80001178:	f5a080e7          	jalr	-166(ra) # 800010ce <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000117c:	4699                	li	a3,6
    8000117e:	00400637          	lui	a2,0x400
    80001182:	0c0005b7          	lui	a1,0xc000
    80001186:	0c000537          	lui	a0,0xc000
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	f44080e7          	jalr	-188(ra) # 800010ce <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001192:	00008497          	auipc	s1,0x8
    80001196:	e6e48493          	addi	s1,s1,-402 # 80009000 <initcode>
    8000119a:	46a9                	li	a3,10
    8000119c:	80008617          	auipc	a2,0x80008
    800011a0:	e6460613          	addi	a2,a2,-412 # 9000 <_entry-0x7fff7000>
    800011a4:	4585                	li	a1,1
    800011a6:	05fe                	slli	a1,a1,0x1f
    800011a8:	852e                	mv	a0,a1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f24080e7          	jalr	-220(ra) # 800010ce <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011b2:	4699                	li	a3,6
    800011b4:	4645                	li	a2,17
    800011b6:	066e                	slli	a2,a2,0x1b
    800011b8:	8e05                	sub	a2,a2,s1
    800011ba:	85a6                	mv	a1,s1
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f10080e7          	jalr	-240(ra) # 800010ce <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011c6:	46a9                	li	a3,10
    800011c8:	6605                	lui	a2,0x1
    800011ca:	00007597          	auipc	a1,0x7
    800011ce:	e3658593          	addi	a1,a1,-458 # 80008000 <trampoline>
    800011d2:	04000537          	lui	a0,0x4000
    800011d6:	157d                	addi	a0,a0,-1
    800011d8:	0532                	slli	a0,a0,0xc
    800011da:	00000097          	auipc	ra,0x0
    800011de:	ef4080e7          	jalr	-268(ra) # 800010ce <kvmmap>
}
    800011e2:	60e2                	ld	ra,24(sp)
    800011e4:	6442                	ld	s0,16(sp)
    800011e6:	64a2                	ld	s1,8(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret

00000000800011ec <uvmunmap>:
{
    800011ec:	715d                	addi	sp,sp,-80
    800011ee:	e486                	sd	ra,72(sp)
    800011f0:	e0a2                	sd	s0,64(sp)
    800011f2:	fc26                	sd	s1,56(sp)
    800011f4:	f84a                	sd	s2,48(sp)
    800011f6:	f44e                	sd	s3,40(sp)
    800011f8:	f052                	sd	s4,32(sp)
    800011fa:	ec56                	sd	s5,24(sp)
    800011fc:	e85a                	sd	s6,16(sp)
    800011fe:	e45e                	sd	s7,8(sp)
    80001200:	0880                	addi	s0,sp,80
    80001202:	8a2a                	mv	s4,a0
    80001204:	8b36                	mv	s6,a3
  a = PGROUNDDOWN(va);
    80001206:	77fd                	lui	a5,0xfffff
    80001208:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000120c:	167d                	addi	a2,a2,-1
    8000120e:	00b609b3          	add	s3,a2,a1
    80001212:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    80001216:	4b85                	li	s7,1
    a += PGSIZE;
    80001218:	6a85                	lui	s5,0x1
    8000121a:	a02d                	j	80001244 <uvmunmap+0x58>
      panic("uvmunmap: not a leaf");
    8000121c:	00007517          	auipc	a0,0x7
    80001220:	fcc50513          	addi	a0,a0,-52 # 800081e8 <userret+0x158>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	32a080e7          	jalr	810(ra) # 8000054e <panic>
      pa = PTE2PA(*pte);
    8000122c:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    8000122e:	00c79513          	slli	a0,a5,0xc
    80001232:	fffff097          	auipc	ra,0xfffff
    80001236:	632080e7          	jalr	1586(ra) # 80000864 <kfree>
    *pte = 0;
    8000123a:	0004b023          	sd	zero,0(s1)
    if(a == last)
    8000123e:	03390763          	beq	s2,s3,8000126c <uvmunmap+0x80>
    a += PGSIZE;
    80001242:	9956                	add	s2,s2,s5
    if((pte = walk(pagetable, a, 0)) == 0)
    80001244:	4601                	li	a2,0
    80001246:	85ca                	mv	a1,s2
    80001248:	8552                	mv	a0,s4
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	c2e080e7          	jalr	-978(ra) # 80000e78 <walk>
    80001252:	84aa                	mv	s1,a0
    80001254:	d56d                	beqz	a0,8000123e <uvmunmap+0x52>
    if((*pte & PTE_V) == 0){
    80001256:	611c                	ld	a5,0(a0)
    80001258:	0017f713          	andi	a4,a5,1
    8000125c:	d36d                	beqz	a4,8000123e <uvmunmap+0x52>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000125e:	01f7f713          	andi	a4,a5,31
    80001262:	fb770de3          	beq	a4,s7,8000121c <uvmunmap+0x30>
    if(do_free){
    80001266:	fc0b0ae3          	beqz	s6,8000123a <uvmunmap+0x4e>
    8000126a:	b7c9                	j	8000122c <uvmunmap+0x40>
}
    8000126c:	60a6                	ld	ra,72(sp)
    8000126e:	6406                	ld	s0,64(sp)
    80001270:	74e2                	ld	s1,56(sp)
    80001272:	7942                	ld	s2,48(sp)
    80001274:	79a2                	ld	s3,40(sp)
    80001276:	7a02                	ld	s4,32(sp)
    80001278:	6ae2                	ld	s5,24(sp)
    8000127a:	6b42                	ld	s6,16(sp)
    8000127c:	6ba2                	ld	s7,8(sp)
    8000127e:	6161                	addi	sp,sp,80
    80001280:	8082                	ret

0000000080001282 <uvmcreate>:
{
    80001282:	1101                	addi	sp,sp,-32
    80001284:	ec06                	sd	ra,24(sp)
    80001286:	e822                	sd	s0,16(sp)
    80001288:	e426                	sd	s1,8(sp)
    8000128a:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    8000128c:	fffff097          	auipc	ra,0xfffff
    80001290:	6ec080e7          	jalr	1772(ra) # 80000978 <kalloc>
  if(pagetable == 0)
    80001294:	cd11                	beqz	a0,800012b0 <uvmcreate+0x2e>
    80001296:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    80001298:	6605                	lui	a2,0x1
    8000129a:	4581                	li	a1,0
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	912080e7          	jalr	-1774(ra) # 80000bae <memset>
}
    800012a4:	8526                	mv	a0,s1
    800012a6:	60e2                	ld	ra,24(sp)
    800012a8:	6442                	ld	s0,16(sp)
    800012aa:	64a2                	ld	s1,8(sp)
    800012ac:	6105                	addi	sp,sp,32
    800012ae:	8082                	ret
    panic("uvmcreate: out of memory");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	f5050513          	addi	a0,a0,-176 # 80008200 <userret+0x170>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	296080e7          	jalr	662(ra) # 8000054e <panic>

00000000800012c0 <uvminit>:
{
    800012c0:	7179                	addi	sp,sp,-48
    800012c2:	f406                	sd	ra,40(sp)
    800012c4:	f022                	sd	s0,32(sp)
    800012c6:	ec26                	sd	s1,24(sp)
    800012c8:	e84a                	sd	s2,16(sp)
    800012ca:	e44e                	sd	s3,8(sp)
    800012cc:	e052                	sd	s4,0(sp)
    800012ce:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800012d0:	6785                	lui	a5,0x1
    800012d2:	04f67863          	bgeu	a2,a5,80001322 <uvminit+0x62>
    800012d6:	8a2a                	mv	s4,a0
    800012d8:	89ae                	mv	s3,a1
    800012da:	84b2                	mv	s1,a2
  mem = kalloc();
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	69c080e7          	jalr	1692(ra) # 80000978 <kalloc>
    800012e4:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e6:	6605                	lui	a2,0x1
    800012e8:	4581                	li	a1,0
    800012ea:	00000097          	auipc	ra,0x0
    800012ee:	8c4080e7          	jalr	-1852(ra) # 80000bae <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012f2:	4779                	li	a4,30
    800012f4:	86ca                	mv	a3,s2
    800012f6:	6605                	lui	a2,0x1
    800012f8:	4581                	li	a1,0
    800012fa:	8552                	mv	a0,s4
    800012fc:	00000097          	auipc	ra,0x0
    80001300:	d44080e7          	jalr	-700(ra) # 80001040 <mappages>
  memmove(mem, src, sz);
    80001304:	8626                	mv	a2,s1
    80001306:	85ce                	mv	a1,s3
    80001308:	854a                	mv	a0,s2
    8000130a:	00000097          	auipc	ra,0x0
    8000130e:	904080e7          	jalr	-1788(ra) # 80000c0e <memmove>
}
    80001312:	70a2                	ld	ra,40(sp)
    80001314:	7402                	ld	s0,32(sp)
    80001316:	64e2                	ld	s1,24(sp)
    80001318:	6942                	ld	s2,16(sp)
    8000131a:	69a2                	ld	s3,8(sp)
    8000131c:	6a02                	ld	s4,0(sp)
    8000131e:	6145                	addi	sp,sp,48
    80001320:	8082                	ret
    panic("inituvm: more than a page");
    80001322:	00007517          	auipc	a0,0x7
    80001326:	efe50513          	addi	a0,a0,-258 # 80008220 <userret+0x190>
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	224080e7          	jalr	548(ra) # 8000054e <panic>

0000000080001332 <uvmdealloc>:
{
    80001332:	87aa                	mv	a5,a0
    80001334:	852e                	mv	a0,a1
  if(newsz >= oldsz)
    80001336:	00b66363          	bltu	a2,a1,8000133c <uvmdealloc+0xa>
}
    8000133a:	8082                	ret
{
    8000133c:	1101                	addi	sp,sp,-32
    8000133e:	ec06                	sd	ra,24(sp)
    80001340:	e822                	sd	s0,16(sp)
    80001342:	e426                	sd	s1,8(sp)
    80001344:	1000                	addi	s0,sp,32
    80001346:	84b2                	mv	s1,a2
  uvmunmap(pagetable, newsz, oldsz - newsz, 1);
    80001348:	4685                	li	a3,1
    8000134a:	40c58633          	sub	a2,a1,a2
    8000134e:	85a6                	mv	a1,s1
    80001350:	853e                	mv	a0,a5
    80001352:	00000097          	auipc	ra,0x0
    80001356:	e9a080e7          	jalr	-358(ra) # 800011ec <uvmunmap>
  return newsz;
    8000135a:	8526                	mv	a0,s1
}
    8000135c:	60e2                	ld	ra,24(sp)
    8000135e:	6442                	ld	s0,16(sp)
    80001360:	64a2                	ld	s1,8(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <uvmalloc>:
  if(newsz < oldsz)
    80001366:	0ab66163          	bltu	a2,a1,80001408 <uvmalloc+0xa2>
{
    8000136a:	7139                	addi	sp,sp,-64
    8000136c:	fc06                	sd	ra,56(sp)
    8000136e:	f822                	sd	s0,48(sp)
    80001370:	f426                	sd	s1,40(sp)
    80001372:	f04a                	sd	s2,32(sp)
    80001374:	ec4e                	sd	s3,24(sp)
    80001376:	e852                	sd	s4,16(sp)
    80001378:	e456                	sd	s5,8(sp)
    8000137a:	0080                	addi	s0,sp,64
    8000137c:	8aaa                	mv	s5,a0
    8000137e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001380:	6985                	lui	s3,0x1
    80001382:	19fd                	addi	s3,s3,-1
    80001384:	95ce                	add	a1,a1,s3
    80001386:	79fd                	lui	s3,0xfffff
    80001388:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    8000138c:	08c9f063          	bgeu	s3,a2,8000140c <uvmalloc+0xa6>
  a = oldsz;
    80001390:	894e                	mv	s2,s3
    mem = kalloc();
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	5e6080e7          	jalr	1510(ra) # 80000978 <kalloc>
    8000139a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000139c:	c51d                	beqz	a0,800013ca <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	80c080e7          	jalr	-2036(ra) # 80000bae <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800013aa:	4779                	li	a4,30
    800013ac:	86a6                	mv	a3,s1
    800013ae:	6605                	lui	a2,0x1
    800013b0:	85ca                	mv	a1,s2
    800013b2:	8556                	mv	a0,s5
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	c8c080e7          	jalr	-884(ra) # 80001040 <mappages>
    800013bc:	e905                	bnez	a0,800013ec <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800013be:	6785                	lui	a5,0x1
    800013c0:	993e                	add	s2,s2,a5
    800013c2:	fd4968e3          	bltu	s2,s4,80001392 <uvmalloc+0x2c>
  return newsz;
    800013c6:	8552                	mv	a0,s4
    800013c8:	a809                	j	800013da <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013ca:	864e                	mv	a2,s3
    800013cc:	85ca                	mv	a1,s2
    800013ce:	8556                	mv	a0,s5
    800013d0:	00000097          	auipc	ra,0x0
    800013d4:	f62080e7          	jalr	-158(ra) # 80001332 <uvmdealloc>
      return 0;
    800013d8:	4501                	li	a0,0
}
    800013da:	70e2                	ld	ra,56(sp)
    800013dc:	7442                	ld	s0,48(sp)
    800013de:	74a2                	ld	s1,40(sp)
    800013e0:	7902                	ld	s2,32(sp)
    800013e2:	69e2                	ld	s3,24(sp)
    800013e4:	6a42                	ld	s4,16(sp)
    800013e6:	6aa2                	ld	s5,8(sp)
    800013e8:	6121                	addi	sp,sp,64
    800013ea:	8082                	ret
      kfree(mem);
    800013ec:	8526                	mv	a0,s1
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	476080e7          	jalr	1142(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f6:	864e                	mv	a2,s3
    800013f8:	85ca                	mv	a1,s2
    800013fa:	8556                	mv	a0,s5
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	f36080e7          	jalr	-202(ra) # 80001332 <uvmdealloc>
      return 0;
    80001404:	4501                	li	a0,0
    80001406:	bfd1                	j	800013da <uvmalloc+0x74>
    return oldsz;
    80001408:	852e                	mv	a0,a1
}
    8000140a:	8082                	ret
  return newsz;
    8000140c:	8532                	mv	a0,a2
    8000140e:	b7f1                	j	800013da <uvmalloc+0x74>

0000000080001410 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001410:	1101                	addi	sp,sp,-32
    80001412:	ec06                	sd	ra,24(sp)
    80001414:	e822                	sd	s0,16(sp)
    80001416:	e426                	sd	s1,8(sp)
    80001418:	1000                	addi	s0,sp,32
    8000141a:	84aa                	mv	s1,a0
    8000141c:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    8000141e:	4685                	li	a3,1
    80001420:	4581                	li	a1,0
    80001422:	00000097          	auipc	ra,0x0
    80001426:	dca080e7          	jalr	-566(ra) # 800011ec <uvmunmap>
  freewalk(pagetable);
    8000142a:	8526                	mv	a0,s1
    8000142c:	00000097          	auipc	ra,0x0
    80001430:	af2080e7          	jalr	-1294(ra) # 80000f1e <freewalk>
}
    80001434:	60e2                	ld	ra,24(sp)
    80001436:	6442                	ld	s0,16(sp)
    80001438:	64a2                	ld	s1,8(sp)
    8000143a:	6105                	addi	sp,sp,32
    8000143c:	8082                	ret

000000008000143e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000143e:	c671                	beqz	a2,8000150a <uvmcopy+0xcc>
{
    80001440:	715d                	addi	sp,sp,-80
    80001442:	e486                	sd	ra,72(sp)
    80001444:	e0a2                	sd	s0,64(sp)
    80001446:	fc26                	sd	s1,56(sp)
    80001448:	f84a                	sd	s2,48(sp)
    8000144a:	f44e                	sd	s3,40(sp)
    8000144c:	f052                	sd	s4,32(sp)
    8000144e:	ec56                	sd	s5,24(sp)
    80001450:	e85a                	sd	s6,16(sp)
    80001452:	e45e                	sd	s7,8(sp)
    80001454:	0880                	addi	s0,sp,80
    80001456:	8b2a                	mv	s6,a0
    80001458:	8aae                	mv	s5,a1
    8000145a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000145c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000145e:	4601                	li	a2,0
    80001460:	85ce                	mv	a1,s3
    80001462:	855a                	mv	a0,s6
    80001464:	00000097          	auipc	ra,0x0
    80001468:	a14080e7          	jalr	-1516(ra) # 80000e78 <walk>
    8000146c:	c531                	beqz	a0,800014b8 <uvmcopy+0x7a>
      panic("copyuvm: pte should exist");
    if((*pte & PTE_V) == 0)
    8000146e:	6118                	ld	a4,0(a0)
    80001470:	00177793          	andi	a5,a4,1
    80001474:	cbb1                	beqz	a5,800014c8 <uvmcopy+0x8a>
      panic("copyuvm: page not present");
    pa = PTE2PA(*pte);
    80001476:	00a75593          	srli	a1,a4,0xa
    8000147a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000147e:	01f77493          	andi	s1,a4,31
    if((mem = kalloc()) == 0)
    80001482:	fffff097          	auipc	ra,0xfffff
    80001486:	4f6080e7          	jalr	1270(ra) # 80000978 <kalloc>
    8000148a:	892a                	mv	s2,a0
    8000148c:	c939                	beqz	a0,800014e2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000148e:	6605                	lui	a2,0x1
    80001490:	85de                	mv	a1,s7
    80001492:	fffff097          	auipc	ra,0xfffff
    80001496:	77c080e7          	jalr	1916(ra) # 80000c0e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000149a:	8726                	mv	a4,s1
    8000149c:	86ca                	mv	a3,s2
    8000149e:	6605                	lui	a2,0x1
    800014a0:	85ce                	mv	a1,s3
    800014a2:	8556                	mv	a0,s5
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	b9c080e7          	jalr	-1124(ra) # 80001040 <mappages>
    800014ac:	e515                	bnez	a0,800014d8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800014ae:	6785                	lui	a5,0x1
    800014b0:	99be                	add	s3,s3,a5
    800014b2:	fb49e6e3          	bltu	s3,s4,8000145e <uvmcopy+0x20>
    800014b6:	a83d                	j	800014f4 <uvmcopy+0xb6>
      panic("copyuvm: pte should exist");
    800014b8:	00007517          	auipc	a0,0x7
    800014bc:	d8850513          	addi	a0,a0,-632 # 80008240 <userret+0x1b0>
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	08e080e7          	jalr	142(ra) # 8000054e <panic>
      panic("copyuvm: page not present");
    800014c8:	00007517          	auipc	a0,0x7
    800014cc:	d9850513          	addi	a0,a0,-616 # 80008260 <userret+0x1d0>
    800014d0:	fffff097          	auipc	ra,0xfffff
    800014d4:	07e080e7          	jalr	126(ra) # 8000054e <panic>
      kfree(mem);
    800014d8:	854a                	mv	a0,s2
    800014da:	fffff097          	auipc	ra,0xfffff
    800014de:	38a080e7          	jalr	906(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800014e2:	4685                	li	a3,1
    800014e4:	864e                	mv	a2,s3
    800014e6:	4581                	li	a1,0
    800014e8:	8556                	mv	a0,s5
    800014ea:	00000097          	auipc	ra,0x0
    800014ee:	d02080e7          	jalr	-766(ra) # 800011ec <uvmunmap>
  return -1;
    800014f2:	557d                	li	a0,-1
}
    800014f4:	60a6                	ld	ra,72(sp)
    800014f6:	6406                	ld	s0,64(sp)
    800014f8:	74e2                	ld	s1,56(sp)
    800014fa:	7942                	ld	s2,48(sp)
    800014fc:	79a2                	ld	s3,40(sp)
    800014fe:	7a02                	ld	s4,32(sp)
    80001500:	6ae2                	ld	s5,24(sp)
    80001502:	6b42                	ld	s6,16(sp)
    80001504:	6ba2                	ld	s7,8(sp)
    80001506:	6161                	addi	sp,sp,80
    80001508:	8082                	ret
  return 0;
    8000150a:	4501                	li	a0,0
}
    8000150c:	8082                	ret

000000008000150e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000150e:	1141                	addi	sp,sp,-16
    80001510:	e406                	sd	ra,8(sp)
    80001512:	e022                	sd	s0,0(sp)
    80001514:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001516:	4601                	li	a2,0
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	960080e7          	jalr	-1696(ra) # 80000e78 <walk>
  if(pte == 0)
    80001520:	c901                	beqz	a0,80001530 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001522:	611c                	ld	a5,0(a0)
    80001524:	9bbd                	andi	a5,a5,-17
    80001526:	e11c                	sd	a5,0(a0)
}
    80001528:	60a2                	ld	ra,8(sp)
    8000152a:	6402                	ld	s0,0(sp)
    8000152c:	0141                	addi	sp,sp,16
    8000152e:	8082                	ret
    panic("uvmclear");
    80001530:	00007517          	auipc	a0,0x7
    80001534:	d5050513          	addi	a0,a0,-688 # 80008280 <userret+0x1f0>
    80001538:	fffff097          	auipc	ra,0xfffff
    8000153c:	016080e7          	jalr	22(ra) # 8000054e <panic>

0000000080001540 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001540:	cab5                	beqz	a3,800015b4 <copyout+0x74>
{
    80001542:	715d                	addi	sp,sp,-80
    80001544:	e486                	sd	ra,72(sp)
    80001546:	e0a2                	sd	s0,64(sp)
    80001548:	fc26                	sd	s1,56(sp)
    8000154a:	f84a                	sd	s2,48(sp)
    8000154c:	f44e                	sd	s3,40(sp)
    8000154e:	f052                	sd	s4,32(sp)
    80001550:	ec56                	sd	s5,24(sp)
    80001552:	e85a                	sd	s6,16(sp)
    80001554:	e45e                	sd	s7,8(sp)
    80001556:	e062                	sd	s8,0(sp)
    80001558:	0880                	addi	s0,sp,80
    8000155a:	8baa                	mv	s7,a0
    8000155c:	8c2e                	mv	s8,a1
    8000155e:	8a32                	mv	s4,a2
    80001560:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(dstva);
    80001562:	00100b37          	lui	s6,0x100
    80001566:	1b7d                	addi	s6,s6,-1
    80001568:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000156a:	6a85                	lui	s5,0x1
    8000156c:	a015                	j	80001590 <copyout+0x50>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000156e:	9562                	add	a0,a0,s8
    80001570:	0004861b          	sext.w	a2,s1
    80001574:	85d2                	mv	a1,s4
    80001576:	41250533          	sub	a0,a0,s2
    8000157a:	fffff097          	auipc	ra,0xfffff
    8000157e:	694080e7          	jalr	1684(ra) # 80000c0e <memmove>

    len -= n;
    80001582:	409989b3          	sub	s3,s3,s1
    src += n;
    80001586:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001588:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000158c:	02098263          	beqz	s3,800015b0 <copyout+0x70>
    va0 = (uint)PGROUNDDOWN(dstva);
    80001590:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001594:	85ca                	mv	a1,s2
    80001596:	855e                	mv	a0,s7
    80001598:	00000097          	auipc	ra,0x0
    8000159c:	a14080e7          	jalr	-1516(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    800015a0:	cd01                	beqz	a0,800015b8 <copyout+0x78>
    n = PGSIZE - (dstva - va0);
    800015a2:	418904b3          	sub	s1,s2,s8
    800015a6:	94d6                	add	s1,s1,s5
    if(n > len)
    800015a8:	fc99f3e3          	bgeu	s3,s1,8000156e <copyout+0x2e>
    800015ac:	84ce                	mv	s1,s3
    800015ae:	b7c1                	j	8000156e <copyout+0x2e>
  }
  return 0;
    800015b0:	4501                	li	a0,0
    800015b2:	a021                	j	800015ba <copyout+0x7a>
    800015b4:	4501                	li	a0,0
}
    800015b6:	8082                	ret
      return -1;
    800015b8:	557d                	li	a0,-1
}
    800015ba:	60a6                	ld	ra,72(sp)
    800015bc:	6406                	ld	s0,64(sp)
    800015be:	74e2                	ld	s1,56(sp)
    800015c0:	7942                	ld	s2,48(sp)
    800015c2:	79a2                	ld	s3,40(sp)
    800015c4:	7a02                	ld	s4,32(sp)
    800015c6:	6ae2                	ld	s5,24(sp)
    800015c8:	6b42                	ld	s6,16(sp)
    800015ca:	6ba2                	ld	s7,8(sp)
    800015cc:	6c02                	ld	s8,0(sp)
    800015ce:	6161                	addi	sp,sp,80
    800015d0:	8082                	ret

00000000800015d2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800015d2:	cab5                	beqz	a3,80001646 <copyin+0x74>
{
    800015d4:	715d                	addi	sp,sp,-80
    800015d6:	e486                	sd	ra,72(sp)
    800015d8:	e0a2                	sd	s0,64(sp)
    800015da:	fc26                	sd	s1,56(sp)
    800015dc:	f84a                	sd	s2,48(sp)
    800015de:	f44e                	sd	s3,40(sp)
    800015e0:	f052                	sd	s4,32(sp)
    800015e2:	ec56                	sd	s5,24(sp)
    800015e4:	e85a                	sd	s6,16(sp)
    800015e6:	e45e                	sd	s7,8(sp)
    800015e8:	e062                	sd	s8,0(sp)
    800015ea:	0880                	addi	s0,sp,80
    800015ec:	8baa                	mv	s7,a0
    800015ee:	8a2e                	mv	s4,a1
    800015f0:	8c32                	mv	s8,a2
    800015f2:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    800015f4:	00100b37          	lui	s6,0x100
    800015f8:	1b7d                	addi	s6,s6,-1
    800015fa:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015fc:	6a85                	lui	s5,0x1
    800015fe:	a015                	j	80001622 <copyin+0x50>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001600:	9562                	add	a0,a0,s8
    80001602:	0004861b          	sext.w	a2,s1
    80001606:	412505b3          	sub	a1,a0,s2
    8000160a:	8552                	mv	a0,s4
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	602080e7          	jalr	1538(ra) # 80000c0e <memmove>

    len -= n;
    80001614:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001618:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000161a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000161e:	02098263          	beqz	s3,80001642 <copyin+0x70>
    va0 = (uint)PGROUNDDOWN(srcva);
    80001622:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001626:	85ca                	mv	a1,s2
    80001628:	855e                	mv	a0,s7
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	982080e7          	jalr	-1662(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    80001632:	cd01                	beqz	a0,8000164a <copyin+0x78>
    n = PGSIZE - (srcva - va0);
    80001634:	418904b3          	sub	s1,s2,s8
    80001638:	94d6                	add	s1,s1,s5
    if(n > len)
    8000163a:	fc99f3e3          	bgeu	s3,s1,80001600 <copyin+0x2e>
    8000163e:	84ce                	mv	s1,s3
    80001640:	b7c1                	j	80001600 <copyin+0x2e>
  }
  return 0;
    80001642:	4501                	li	a0,0
    80001644:	a021                	j	8000164c <copyin+0x7a>
    80001646:	4501                	li	a0,0
}
    80001648:	8082                	ret
      return -1;
    8000164a:	557d                	li	a0,-1
}
    8000164c:	60a6                	ld	ra,72(sp)
    8000164e:	6406                	ld	s0,64(sp)
    80001650:	74e2                	ld	s1,56(sp)
    80001652:	7942                	ld	s2,48(sp)
    80001654:	79a2                	ld	s3,40(sp)
    80001656:	7a02                	ld	s4,32(sp)
    80001658:	6ae2                	ld	s5,24(sp)
    8000165a:	6b42                	ld	s6,16(sp)
    8000165c:	6ba2                	ld	s7,8(sp)
    8000165e:	6c02                	ld	s8,0(sp)
    80001660:	6161                	addi	sp,sp,80
    80001662:	8082                	ret

0000000080001664 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001664:	c6dd                	beqz	a3,80001712 <copyinstr+0xae>
{
    80001666:	715d                	addi	sp,sp,-80
    80001668:	e486                	sd	ra,72(sp)
    8000166a:	e0a2                	sd	s0,64(sp)
    8000166c:	fc26                	sd	s1,56(sp)
    8000166e:	f84a                	sd	s2,48(sp)
    80001670:	f44e                	sd	s3,40(sp)
    80001672:	f052                	sd	s4,32(sp)
    80001674:	ec56                	sd	s5,24(sp)
    80001676:	e85a                	sd	s6,16(sp)
    80001678:	e45e                	sd	s7,8(sp)
    8000167a:	0880                	addi	s0,sp,80
    8000167c:	8aaa                	mv	s5,a0
    8000167e:	8b2e                	mv	s6,a1
    80001680:	8bb2                	mv	s7,a2
    80001682:	84b6                	mv	s1,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    80001684:	00100a37          	lui	s4,0x100
    80001688:	1a7d                	addi	s4,s4,-1
    8000168a:	0a32                	slli	s4,s4,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000168c:	6985                	lui	s3,0x1
    8000168e:	a035                	j	800016ba <copyinstr+0x56>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001690:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001694:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001696:	0017b793          	seqz	a5,a5
    8000169a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000169e:	60a6                	ld	ra,72(sp)
    800016a0:	6406                	ld	s0,64(sp)
    800016a2:	74e2                	ld	s1,56(sp)
    800016a4:	7942                	ld	s2,48(sp)
    800016a6:	79a2                	ld	s3,40(sp)
    800016a8:	7a02                	ld	s4,32(sp)
    800016aa:	6ae2                	ld	s5,24(sp)
    800016ac:	6b42                	ld	s6,16(sp)
    800016ae:	6ba2                	ld	s7,8(sp)
    800016b0:	6161                	addi	sp,sp,80
    800016b2:	8082                	ret
    srcva = va0 + PGSIZE;
    800016b4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800016b8:	c8a9                	beqz	s1,8000170a <copyinstr+0xa6>
    va0 = (uint)PGROUNDDOWN(srcva);
    800016ba:	014bf933          	and	s2,s7,s4
    pa0 = walkaddr(pagetable, va0);
    800016be:	85ca                	mv	a1,s2
    800016c0:	8556                	mv	a0,s5
    800016c2:	00000097          	auipc	ra,0x0
    800016c6:	8ea080e7          	jalr	-1814(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    800016ca:	c131                	beqz	a0,8000170e <copyinstr+0xaa>
    n = PGSIZE - (srcva - va0);
    800016cc:	41790833          	sub	a6,s2,s7
    800016d0:	984e                	add	a6,a6,s3
    if(n > max)
    800016d2:	0104f363          	bgeu	s1,a6,800016d8 <copyinstr+0x74>
    800016d6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016d8:	955e                	add	a0,a0,s7
    800016da:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016de:	fc080be3          	beqz	a6,800016b4 <copyinstr+0x50>
    800016e2:	985a                	add	a6,a6,s6
    800016e4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016e6:	41650633          	sub	a2,a0,s6
    800016ea:	14fd                	addi	s1,s1,-1
    800016ec:	9b26                	add	s6,s6,s1
    800016ee:	00f60733          	add	a4,a2,a5
    800016f2:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5fa4>
    800016f6:	df49                	beqz	a4,80001690 <copyinstr+0x2c>
        *dst = *p;
    800016f8:	00e78023          	sb	a4,0(a5)
      --max;
    800016fc:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001700:	0785                	addi	a5,a5,1
    while(n > 0){
    80001702:	ff0796e3          	bne	a5,a6,800016ee <copyinstr+0x8a>
      dst++;
    80001706:	8b42                	mv	s6,a6
    80001708:	b775                	j	800016b4 <copyinstr+0x50>
    8000170a:	4781                	li	a5,0
    8000170c:	b769                	j	80001696 <copyinstr+0x32>
      return -1;
    8000170e:	557d                	li	a0,-1
    80001710:	b779                	j	8000169e <copyinstr+0x3a>
  int got_null = 0;
    80001712:	4781                	li	a5,0
  if(got_null){
    80001714:	0017b793          	seqz	a5,a5
    80001718:	40f00533          	neg	a0,a5
}
    8000171c:	8082                	ret

000000008000171e <digdown>:

void digdown(pagetable_t pagetable,int dep){
    8000171e:	7159                	addi	sp,sp,-112
    80001720:	f486                	sd	ra,104(sp)
    80001722:	f0a2                	sd	s0,96(sp)
    80001724:	eca6                	sd	s1,88(sp)
    80001726:	e8ca                	sd	s2,80(sp)
    80001728:	e4ce                	sd	s3,72(sp)
    8000172a:	e0d2                	sd	s4,64(sp)
    8000172c:	fc56                	sd	s5,56(sp)
    8000172e:	f85a                	sd	s6,48(sp)
    80001730:	f45e                	sd	s7,40(sp)
    80001732:	f062                	sd	s8,32(sp)
    80001734:	ec66                	sd	s9,24(sp)
    80001736:	e86a                	sd	s10,16(sp)
    80001738:	e46e                	sd	s11,8(sp)
    8000173a:	1880                	addi	s0,sp,112
    8000173c:	8aae                	mv	s5,a1
	for(int i = 0; i < 512; i++){
    8000173e:	8a2a                	mv	s4,a0
    80001740:	4981                	li	s3,0

		if(pte&PTE_V){
			for(int j=0;j<dep;j++){
				printf(" ..");
		  }
			printf("%d: pte %p pa %p\n",i,pte,PTE2PA(pte));
    80001742:	00007c97          	auipc	s9,0x7
    80001746:	b56c8c93          	addi	s9,s9,-1194 # 80008298 <userret+0x208>
			for(int j=0;j<dep;j++){
    8000174a:	4d01                	li	s10,0
				printf(" ..");
    8000174c:	00007b17          	auipc	s6,0x7
    80001750:	b44b0b13          	addi	s6,s6,-1212 # 80008290 <userret+0x200>
		}

    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001754:	4c05                	li	s8,1
      // this PTE points to a lower-level page table.
			//printf("..%d: pte %s pa %s\n",i, (pte)>>10, ((pte>>12)<<12)+(((*pagetable)<<44)>>44));
      uint64 child = PTE2PA(pte);
			digdown((pagetable_t)child, dep+1);
    80001756:	00158d9b          	addiw	s11,a1,1
	for(int i = 0; i < 512; i++){
    8000175a:	20000b93          	li	s7,512
    8000175e:	a01d                	j	80001784 <digdown+0x66>
			printf("%d: pte %p pa %p\n",i,pte,PTE2PA(pte));
    80001760:	00a95693          	srli	a3,s2,0xa
    80001764:	06b2                	slli	a3,a3,0xc
    80001766:	864a                	mv	a2,s2
    80001768:	85ce                	mv	a1,s3
    8000176a:	8566                	mv	a0,s9
    8000176c:	fffff097          	auipc	ra,0xfffff
    80001770:	e2c080e7          	jalr	-468(ra) # 80000598 <printf>
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001774:	00f97793          	andi	a5,s2,15
    80001778:	03878763          	beq	a5,s8,800017a6 <digdown+0x88>
	for(int i = 0; i < 512; i++){
    8000177c:	2985                	addiw	s3,s3,1
    8000177e:	0a21                	addi	s4,s4,8
    80001780:	03798c63          	beq	s3,s7,800017b8 <digdown+0x9a>
    pte_t pte = pagetable[i];
    80001784:	000a3903          	ld	s2,0(s4) # 100000 <_entry-0x7ff00000>
		if(pte&PTE_V){
    80001788:	00197793          	andi	a5,s2,1
    8000178c:	d7e5                	beqz	a5,80001774 <digdown+0x56>
			for(int j=0;j<dep;j++){
    8000178e:	fd5059e3          	blez	s5,80001760 <digdown+0x42>
    80001792:	84ea                	mv	s1,s10
				printf(" ..");
    80001794:	855a                	mv	a0,s6
    80001796:	fffff097          	auipc	ra,0xfffff
    8000179a:	e02080e7          	jalr	-510(ra) # 80000598 <printf>
			for(int j=0;j<dep;j++){
    8000179e:	2485                	addiw	s1,s1,1
    800017a0:	fe9a9ae3          	bne	s5,s1,80001794 <digdown+0x76>
    800017a4:	bf75                	j	80001760 <digdown+0x42>
      uint64 child = PTE2PA(pte);
    800017a6:	00a95513          	srli	a0,s2,0xa
			digdown((pagetable_t)child, dep+1);
    800017aa:	85ee                	mv	a1,s11
    800017ac:	0532                	slli	a0,a0,0xc
    800017ae:	00000097          	auipc	ra,0x0
    800017b2:	f70080e7          	jalr	-144(ra) # 8000171e <digdown>
    800017b6:	b7d9                	j	8000177c <digdown+0x5e>
      //freewalk((pagetable_t)child);
			//vmprint((pagetable_t)child);
      //pagetable[i] = 0;
    } 
  }
}
    800017b8:	70a6                	ld	ra,104(sp)
    800017ba:	7406                	ld	s0,96(sp)
    800017bc:	64e6                	ld	s1,88(sp)
    800017be:	6946                	ld	s2,80(sp)
    800017c0:	69a6                	ld	s3,72(sp)
    800017c2:	6a06                	ld	s4,64(sp)
    800017c4:	7ae2                	ld	s5,56(sp)
    800017c6:	7b42                	ld	s6,48(sp)
    800017c8:	7ba2                	ld	s7,40(sp)
    800017ca:	7c02                	ld	s8,32(sp)
    800017cc:	6ce2                	ld	s9,24(sp)
    800017ce:	6d42                	ld	s10,16(sp)
    800017d0:	6da2                	ld	s11,8(sp)
    800017d2:	6165                	addi	sp,sp,112
    800017d4:	8082                	ret

00000000800017d6 <vmprint>:

void vmprint(pagetable_t pagetable){
    800017d6:	1101                	addi	sp,sp,-32
    800017d8:	ec06                	sd	ra,24(sp)
    800017da:	e822                	sd	s0,16(sp)
    800017dc:	e426                	sd	s1,8(sp)
    800017de:	1000                	addi	s0,sp,32
    800017e0:	84aa                	mv	s1,a0
	printf("page table %p\n",pagetable);
    800017e2:	85aa                	mv	a1,a0
    800017e4:	00007517          	auipc	a0,0x7
    800017e8:	acc50513          	addi	a0,a0,-1332 # 800082b0 <userret+0x220>
    800017ec:	fffff097          	auipc	ra,0xfffff
    800017f0:	dac080e7          	jalr	-596(ra) # 80000598 <printf>

	digdown(pagetable,1);
    800017f4:	4585                	li	a1,1
    800017f6:	8526                	mv	a0,s1
    800017f8:	00000097          	auipc	ra,0x0
    800017fc:	f26080e7          	jalr	-218(ra) # 8000171e <digdown>
  //kfree((void*)pagetable);
}
    80001800:	60e2                	ld	ra,24(sp)
    80001802:	6442                	ld	s0,16(sp)
    80001804:	64a2                	ld	s1,8(sp)
    80001806:	6105                	addi	sp,sp,32
    80001808:	8082                	ret

000000008000180a <procinit>:

extern char trampoline[]; // trampoline.S

void
procinit(void)
{
    8000180a:	715d                	addi	sp,sp,-80
    8000180c:	e486                	sd	ra,72(sp)
    8000180e:	e0a2                	sd	s0,64(sp)
    80001810:	fc26                	sd	s1,56(sp)
    80001812:	f84a                	sd	s2,48(sp)
    80001814:	f44e                	sd	s3,40(sp)
    80001816:	f052                	sd	s4,32(sp)
    80001818:	ec56                	sd	s5,24(sp)
    8000181a:	e85a                	sd	s6,16(sp)
    8000181c:	e45e                	sd	s7,8(sp)
    8000181e:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001820:	00007597          	auipc	a1,0x7
    80001824:	aa058593          	addi	a1,a1,-1376 # 800082c0 <userret+0x230>
    80001828:	00011517          	auipc	a0,0x11
    8000182c:	0c050513          	addi	a0,a0,192 # 800128e8 <pid_lock>
    80001830:	fffff097          	auipc	ra,0xfffff
    80001834:	1a8080e7          	jalr	424(ra) # 800009d8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001838:	00011917          	auipc	s2,0x11
    8000183c:	4c890913          	addi	s2,s2,1224 # 80012d00 <proc>
      initlock(&p->lock, "proc");
    80001840:	00007b97          	auipc	s7,0x7
    80001844:	a88b8b93          	addi	s7,s7,-1400 # 800082c8 <userret+0x238>
      // Map it high in memory, followed by an invalid
      // guard page.
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) (p - proc));
    80001848:	8b4a                	mv	s6,s2
    8000184a:	00007a97          	auipc	s5,0x7
    8000184e:	2aea8a93          	addi	s5,s5,686 # 80008af8 <syscalls+0xc0>
    80001852:	040009b7          	lui	s3,0x4000
    80001856:	19fd                	addi	s3,s3,-1
    80001858:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185a:	00017a17          	auipc	s4,0x17
    8000185e:	0a6a0a13          	addi	s4,s4,166 # 80018900 <tickslock>
      initlock(&p->lock, "proc");
    80001862:	85de                	mv	a1,s7
    80001864:	854a                	mv	a0,s2
    80001866:	fffff097          	auipc	ra,0xfffff
    8000186a:	172080e7          	jalr	370(ra) # 800009d8 <initlock>
      char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	10a080e7          	jalr	266(ra) # 80000978 <kalloc>
    80001876:	85aa                	mv	a1,a0
      if(pa == 0)
    80001878:	c929                	beqz	a0,800018ca <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000187a:	416904b3          	sub	s1,s2,s6
    8000187e:	8491                	srai	s1,s1,0x4
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f484b3          	mul	s1,s1,a5
    80001888:	2485                	addiw	s1,s1,1
    8000188a:	00d4949b          	slliw	s1,s1,0xd
    8000188e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001892:	4699                	li	a3,6
    80001894:	6605                	lui	a2,0x1
    80001896:	8526                	mv	a0,s1
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	836080e7          	jalr	-1994(ra) # 800010ce <kvmmap>
      p->kstack = va;
    800018a0:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a4:	17090913          	addi	s2,s2,368
    800018a8:	fb491de3          	bne	s2,s4,80001862 <procinit+0x58>
  }
  kvminithart();
    800018ac:	fffff097          	auipc	ra,0xfffff
    800018b0:	6dc080e7          	jalr	1756(ra) # 80000f88 <kvminithart>
}
    800018b4:	60a6                	ld	ra,72(sp)
    800018b6:	6406                	ld	s0,64(sp)
    800018b8:	74e2                	ld	s1,56(sp)
    800018ba:	7942                	ld	s2,48(sp)
    800018bc:	79a2                	ld	s3,40(sp)
    800018be:	7a02                	ld	s4,32(sp)
    800018c0:	6ae2                	ld	s5,24(sp)
    800018c2:	6b42                	ld	s6,16(sp)
    800018c4:	6ba2                	ld	s7,8(sp)
    800018c6:	6161                	addi	sp,sp,80
    800018c8:	8082                	ret
        panic("kalloc");
    800018ca:	00007517          	auipc	a0,0x7
    800018ce:	a0650513          	addi	a0,a0,-1530 # 800082d0 <userret+0x240>
    800018d2:	fffff097          	auipc	ra,0xfffff
    800018d6:	c7c080e7          	jalr	-900(ra) # 8000054e <panic>

00000000800018da <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018da:	1141                	addi	sp,sp,-16
    800018dc:	e422                	sd	s0,8(sp)
    800018de:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018e0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018e2:	2501                	sext.w	a0,a0
    800018e4:	6422                	ld	s0,8(sp)
    800018e6:	0141                	addi	sp,sp,16
    800018e8:	8082                	ret

00000000800018ea <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    800018ea:	1141                	addi	sp,sp,-16
    800018ec:	e422                	sd	s0,8(sp)
    800018ee:	0800                	addi	s0,sp,16
    800018f0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018f2:	2781                	sext.w	a5,a5
    800018f4:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f6:	00011517          	auipc	a0,0x11
    800018fa:	00a50513          	addi	a0,a0,10 # 80012900 <cpus>
    800018fe:	953e                	add	a0,a0,a5
    80001900:	6422                	ld	s0,8(sp)
    80001902:	0141                	addi	sp,sp,16
    80001904:	8082                	ret

0000000080001906 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001906:	1101                	addi	sp,sp,-32
    80001908:	ec06                	sd	ra,24(sp)
    8000190a:	e822                	sd	s0,16(sp)
    8000190c:	e426                	sd	s1,8(sp)
    8000190e:	1000                	addi	s0,sp,32
  push_off();
    80001910:	fffff097          	auipc	ra,0xfffff
    80001914:	0de080e7          	jalr	222(ra) # 800009ee <push_off>
    80001918:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000191a:	2781                	sext.w	a5,a5
    8000191c:	079e                	slli	a5,a5,0x7
    8000191e:	00011717          	auipc	a4,0x11
    80001922:	fca70713          	addi	a4,a4,-54 # 800128e8 <pid_lock>
    80001926:	97ba                	add	a5,a5,a4
    80001928:	6f84                	ld	s1,24(a5)
  pop_off();
    8000192a:	fffff097          	auipc	ra,0xfffff
    8000192e:	110080e7          	jalr	272(ra) # 80000a3a <pop_off>
  return p;
}
    80001932:	8526                	mv	a0,s1
    80001934:	60e2                	ld	ra,24(sp)
    80001936:	6442                	ld	s0,16(sp)
    80001938:	64a2                	ld	s1,8(sp)
    8000193a:	6105                	addi	sp,sp,32
    8000193c:	8082                	ret

000000008000193e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000193e:	1141                	addi	sp,sp,-16
    80001940:	e406                	sd	ra,8(sp)
    80001942:	e022                	sd	s0,0(sp)
    80001944:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001946:	00000097          	auipc	ra,0x0
    8000194a:	fc0080e7          	jalr	-64(ra) # 80001906 <myproc>
    8000194e:	fffff097          	auipc	ra,0xfffff
    80001952:	204080e7          	jalr	516(ra) # 80000b52 <release>

  if (first) {
    80001956:	00007797          	auipc	a5,0x7
    8000195a:	6de7a783          	lw	a5,1758(a5) # 80009034 <first.1750>
    8000195e:	eb89                	bnez	a5,80001970 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(minor(ROOTDEV));
  }

  usertrapret();
    80001960:	00001097          	auipc	ra,0x1
    80001964:	c24080e7          	jalr	-988(ra) # 80002584 <usertrapret>
}
    80001968:	60a2                	ld	ra,8(sp)
    8000196a:	6402                	ld	s0,0(sp)
    8000196c:	0141                	addi	sp,sp,16
    8000196e:	8082                	ret
    first = 0;
    80001970:	00007797          	auipc	a5,0x7
    80001974:	6c07a223          	sw	zero,1732(a5) # 80009034 <first.1750>
    fsinit(minor(ROOTDEV));
    80001978:	4501                	li	a0,0
    8000197a:	00002097          	auipc	ra,0x2
    8000197e:	a14080e7          	jalr	-1516(ra) # 8000338e <fsinit>
    80001982:	bff9                	j	80001960 <forkret+0x22>

0000000080001984 <allocpid>:
allocpid() {
    80001984:	1101                	addi	sp,sp,-32
    80001986:	ec06                	sd	ra,24(sp)
    80001988:	e822                	sd	s0,16(sp)
    8000198a:	e426                	sd	s1,8(sp)
    8000198c:	e04a                	sd	s2,0(sp)
    8000198e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001990:	00011917          	auipc	s2,0x11
    80001994:	f5890913          	addi	s2,s2,-168 # 800128e8 <pid_lock>
    80001998:	854a                	mv	a0,s2
    8000199a:	fffff097          	auipc	ra,0xfffff
    8000199e:	150080e7          	jalr	336(ra) # 80000aea <acquire>
  pid = nextpid;
    800019a2:	00007797          	auipc	a5,0x7
    800019a6:	69678793          	addi	a5,a5,1686 # 80009038 <nextpid>
    800019aa:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019ac:	0014871b          	addiw	a4,s1,1
    800019b0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019b2:	854a                	mv	a0,s2
    800019b4:	fffff097          	auipc	ra,0xfffff
    800019b8:	19e080e7          	jalr	414(ra) # 80000b52 <release>
}
    800019bc:	8526                	mv	a0,s1
    800019be:	60e2                	ld	ra,24(sp)
    800019c0:	6442                	ld	s0,16(sp)
    800019c2:	64a2                	ld	s1,8(sp)
    800019c4:	6902                	ld	s2,0(sp)
    800019c6:	6105                	addi	sp,sp,32
    800019c8:	8082                	ret

00000000800019ca <proc_pagetable>:
{
    800019ca:	1101                	addi	sp,sp,-32
    800019cc:	ec06                	sd	ra,24(sp)
    800019ce:	e822                	sd	s0,16(sp)
    800019d0:	e426                	sd	s1,8(sp)
    800019d2:	e04a                	sd	s2,0(sp)
    800019d4:	1000                	addi	s0,sp,32
    800019d6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019d8:	00000097          	auipc	ra,0x0
    800019dc:	8aa080e7          	jalr	-1878(ra) # 80001282 <uvmcreate>
    800019e0:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019e2:	4729                	li	a4,10
    800019e4:	00006697          	auipc	a3,0x6
    800019e8:	61c68693          	addi	a3,a3,1564 # 80008000 <trampoline>
    800019ec:	6605                	lui	a2,0x1
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	fffff097          	auipc	ra,0xfffff
    800019fa:	64a080e7          	jalr	1610(ra) # 80001040 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    800019fe:	4719                	li	a4,6
    80001a00:	06093683          	ld	a3,96(s2)
    80001a04:	6605                	lui	a2,0x1
    80001a06:	020005b7          	lui	a1,0x2000
    80001a0a:	15fd                	addi	a1,a1,-1
    80001a0c:	05b6                	slli	a1,a1,0xd
    80001a0e:	8526                	mv	a0,s1
    80001a10:	fffff097          	auipc	ra,0xfffff
    80001a14:	630080e7          	jalr	1584(ra) # 80001040 <mappages>
}
    80001a18:	8526                	mv	a0,s1
    80001a1a:	60e2                	ld	ra,24(sp)
    80001a1c:	6442                	ld	s0,16(sp)
    80001a1e:	64a2                	ld	s1,8(sp)
    80001a20:	6902                	ld	s2,0(sp)
    80001a22:	6105                	addi	sp,sp,32
    80001a24:	8082                	ret

0000000080001a26 <allocproc>:
{
    80001a26:	1101                	addi	sp,sp,-32
    80001a28:	ec06                	sd	ra,24(sp)
    80001a2a:	e822                	sd	s0,16(sp)
    80001a2c:	e426                	sd	s1,8(sp)
    80001a2e:	e04a                	sd	s2,0(sp)
    80001a30:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a32:	00011497          	auipc	s1,0x11
    80001a36:	2ce48493          	addi	s1,s1,718 # 80012d00 <proc>
    80001a3a:	00017917          	auipc	s2,0x17
    80001a3e:	ec690913          	addi	s2,s2,-314 # 80018900 <tickslock>
    acquire(&p->lock);
    80001a42:	8526                	mv	a0,s1
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	0a6080e7          	jalr	166(ra) # 80000aea <acquire>
    if(p->state == UNUSED) {
    80001a4c:	4c9c                	lw	a5,24(s1)
    80001a4e:	cf81                	beqz	a5,80001a66 <allocproc+0x40>
      release(&p->lock);
    80001a50:	8526                	mv	a0,s1
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	100080e7          	jalr	256(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a5a:	17048493          	addi	s1,s1,368
    80001a5e:	ff2492e3          	bne	s1,s2,80001a42 <allocproc+0x1c>
  return 0;
    80001a62:	4481                	li	s1,0
    80001a64:	a0a9                	j	80001aae <allocproc+0x88>
  p->pid = allocpid();
    80001a66:	00000097          	auipc	ra,0x0
    80001a6a:	f1e080e7          	jalr	-226(ra) # 80001984 <allocpid>
    80001a6e:	dc88                	sw	a0,56(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	f08080e7          	jalr	-248(ra) # 80000978 <kalloc>
    80001a78:	892a                	mv	s2,a0
    80001a7a:	f0a8                	sd	a0,96(s1)
    80001a7c:	c121                	beqz	a0,80001abc <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001a7e:	8526                	mv	a0,s1
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	f4a080e7          	jalr	-182(ra) # 800019ca <proc_pagetable>
    80001a88:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001a8a:	07000613          	li	a2,112
    80001a8e:	4581                	li	a1,0
    80001a90:	06848513          	addi	a0,s1,104
    80001a94:	fffff097          	auipc	ra,0xfffff
    80001a98:	11a080e7          	jalr	282(ra) # 80000bae <memset>
  p->context.ra = (uint64)forkret;
    80001a9c:	00000797          	auipc	a5,0x0
    80001aa0:	ea278793          	addi	a5,a5,-350 # 8000193e <forkret>
    80001aa4:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001aa6:	64bc                	ld	a5,72(s1)
    80001aa8:	6705                	lui	a4,0x1
    80001aaa:	97ba                	add	a5,a5,a4
    80001aac:	f8bc                	sd	a5,112(s1)
}
    80001aae:	8526                	mv	a0,s1
    80001ab0:	60e2                	ld	ra,24(sp)
    80001ab2:	6442                	ld	s0,16(sp)
    80001ab4:	64a2                	ld	s1,8(sp)
    80001ab6:	6902                	ld	s2,0(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret
    release(&p->lock);
    80001abc:	8526                	mv	a0,s1
    80001abe:	fffff097          	auipc	ra,0xfffff
    80001ac2:	094080e7          	jalr	148(ra) # 80000b52 <release>
    return 0;
    80001ac6:	84ca                	mv	s1,s2
    80001ac8:	b7dd                	j	80001aae <allocproc+0x88>

0000000080001aca <proc_freepagetable>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	e04a                	sd	s2,0(sp)
    80001ad4:	1000                	addi	s0,sp,32
    80001ad6:	84aa                	mv	s1,a0
    80001ad8:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001ada:	4681                	li	a3,0
    80001adc:	6605                	lui	a2,0x1
    80001ade:	040005b7          	lui	a1,0x4000
    80001ae2:	15fd                	addi	a1,a1,-1
    80001ae4:	05b2                	slli	a1,a1,0xc
    80001ae6:	fffff097          	auipc	ra,0xfffff
    80001aea:	706080e7          	jalr	1798(ra) # 800011ec <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001aee:	4681                	li	a3,0
    80001af0:	6605                	lui	a2,0x1
    80001af2:	020005b7          	lui	a1,0x2000
    80001af6:	15fd                	addi	a1,a1,-1
    80001af8:	05b6                	slli	a1,a1,0xd
    80001afa:	8526                	mv	a0,s1
    80001afc:	fffff097          	auipc	ra,0xfffff
    80001b00:	6f0080e7          	jalr	1776(ra) # 800011ec <uvmunmap>
  if(sz > 0)
    80001b04:	00091863          	bnez	s2,80001b14 <proc_freepagetable+0x4a>
}
    80001b08:	60e2                	ld	ra,24(sp)
    80001b0a:	6442                	ld	s0,16(sp)
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	6902                	ld	s2,0(sp)
    80001b10:	6105                	addi	sp,sp,32
    80001b12:	8082                	ret
    uvmfree(pagetable, sz);
    80001b14:	85ca                	mv	a1,s2
    80001b16:	8526                	mv	a0,s1
    80001b18:	00000097          	auipc	ra,0x0
    80001b1c:	8f8080e7          	jalr	-1800(ra) # 80001410 <uvmfree>
}
    80001b20:	b7e5                	j	80001b08 <proc_freepagetable+0x3e>

0000000080001b22 <freeproc>:
{
    80001b22:	1101                	addi	sp,sp,-32
    80001b24:	ec06                	sd	ra,24(sp)
    80001b26:	e822                	sd	s0,16(sp)
    80001b28:	e426                	sd	s1,8(sp)
    80001b2a:	1000                	addi	s0,sp,32
    80001b2c:	84aa                	mv	s1,a0
  if(p->tf)
    80001b2e:	7128                	ld	a0,96(a0)
    80001b30:	c509                	beqz	a0,80001b3a <freeproc+0x18>
    kfree((void*)p->tf);
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	d32080e7          	jalr	-718(ra) # 80000864 <kfree>
  p->tf = 0;
    80001b3a:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001b3e:	6ca8                	ld	a0,88(s1)
    80001b40:	c511                	beqz	a0,80001b4c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b42:	68ac                	ld	a1,80(s1)
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	f86080e7          	jalr	-122(ra) # 80001aca <proc_freepagetable>
  p->pagetable = 0;
    80001b4c:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001b50:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001b54:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001b58:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001b5c:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001b60:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001b64:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001b68:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001b6c:	0004ac23          	sw	zero,24(s1)
}
    80001b70:	60e2                	ld	ra,24(sp)
    80001b72:	6442                	ld	s0,16(sp)
    80001b74:	64a2                	ld	s1,8(sp)
    80001b76:	6105                	addi	sp,sp,32
    80001b78:	8082                	ret

0000000080001b7a <userinit>:
{
    80001b7a:	1101                	addi	sp,sp,-32
    80001b7c:	ec06                	sd	ra,24(sp)
    80001b7e:	e822                	sd	s0,16(sp)
    80001b80:	e426                	sd	s1,8(sp)
    80001b82:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	ea2080e7          	jalr	-350(ra) # 80001a26 <allocproc>
    80001b8c:	84aa                	mv	s1,a0
  initproc = p;
    80001b8e:	00027797          	auipc	a5,0x27
    80001b92:	4aa7b523          	sd	a0,1194(a5) # 80029038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001b96:	03300613          	li	a2,51
    80001b9a:	00007597          	auipc	a1,0x7
    80001b9e:	46658593          	addi	a1,a1,1126 # 80009000 <initcode>
    80001ba2:	6d28                	ld	a0,88(a0)
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	71c080e7          	jalr	1820(ra) # 800012c0 <uvminit>
  p->sz = PGSIZE;
    80001bac:	6785                	lui	a5,0x1
    80001bae:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001bb0:	70b8                	ld	a4,96(s1)
    80001bb2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001bb6:	70b8                	ld	a4,96(s1)
    80001bb8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001bba:	4641                	li	a2,16
    80001bbc:	00006597          	auipc	a1,0x6
    80001bc0:	71c58593          	addi	a1,a1,1820 # 800082d8 <userret+0x248>
    80001bc4:	16048513          	addi	a0,s1,352
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	13c080e7          	jalr	316(ra) # 80000d04 <safestrcpy>
  p->cwd = namei("/");
    80001bd0:	00006517          	auipc	a0,0x6
    80001bd4:	71850513          	addi	a0,a0,1816 # 800082e8 <userret+0x258>
    80001bd8:	00002097          	auipc	ra,0x2
    80001bdc:	1ba080e7          	jalr	442(ra) # 80003d92 <namei>
    80001be0:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001be4:	4789                	li	a5,2
    80001be6:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001be8:	8526                	mv	a0,s1
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	f68080e7          	jalr	-152(ra) # 80000b52 <release>
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <growproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	e04a                	sd	s2,0(sp)
    80001c06:	1000                	addi	s0,sp,32
    80001c08:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c0a:	00000097          	auipc	ra,0x0
    80001c0e:	cfc080e7          	jalr	-772(ra) # 80001906 <myproc>
    80001c12:	892a                	mv	s2,a0
  sz = p->sz;
    80001c14:	692c                	ld	a1,80(a0)
    80001c16:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001c1a:	00904f63          	bgtz	s1,80001c38 <growproc+0x3c>
  } else if(n < 0){
    80001c1e:	0204cc63          	bltz	s1,80001c56 <growproc+0x5a>
  p->sz = sz;
    80001c22:	1602                	slli	a2,a2,0x20
    80001c24:	9201                	srli	a2,a2,0x20
    80001c26:	04c93823          	sd	a2,80(s2)
  return 0;
    80001c2a:	4501                	li	a0,0
}
    80001c2c:	60e2                	ld	ra,24(sp)
    80001c2e:	6442                	ld	s0,16(sp)
    80001c30:	64a2                	ld	s1,8(sp)
    80001c32:	6902                	ld	s2,0(sp)
    80001c34:	6105                	addi	sp,sp,32
    80001c36:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001c38:	9e25                	addw	a2,a2,s1
    80001c3a:	1602                	slli	a2,a2,0x20
    80001c3c:	9201                	srli	a2,a2,0x20
    80001c3e:	1582                	slli	a1,a1,0x20
    80001c40:	9181                	srli	a1,a1,0x20
    80001c42:	6d28                	ld	a0,88(a0)
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	722080e7          	jalr	1826(ra) # 80001366 <uvmalloc>
    80001c4c:	0005061b          	sext.w	a2,a0
    80001c50:	fa69                	bnez	a2,80001c22 <growproc+0x26>
      return -1;
    80001c52:	557d                	li	a0,-1
    80001c54:	bfe1                	j	80001c2c <growproc+0x30>
    if((sz = uvmdealloc(p->pagetable, sz, sz + n)) == 0) {
    80001c56:	9e25                	addw	a2,a2,s1
    80001c58:	1602                	slli	a2,a2,0x20
    80001c5a:	9201                	srli	a2,a2,0x20
    80001c5c:	1582                	slli	a1,a1,0x20
    80001c5e:	9181                	srli	a1,a1,0x20
    80001c60:	6d28                	ld	a0,88(a0)
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	6d0080e7          	jalr	1744(ra) # 80001332 <uvmdealloc>
    80001c6a:	0005061b          	sext.w	a2,a0
    80001c6e:	fa55                	bnez	a2,80001c22 <growproc+0x26>
      return -1;
    80001c70:	557d                	li	a0,-1
    80001c72:	bf6d                	j	80001c2c <growproc+0x30>

0000000080001c74 <fork>:
{
    80001c74:	7179                	addi	sp,sp,-48
    80001c76:	f406                	sd	ra,40(sp)
    80001c78:	f022                	sd	s0,32(sp)
    80001c7a:	ec26                	sd	s1,24(sp)
    80001c7c:	e84a                	sd	s2,16(sp)
    80001c7e:	e44e                	sd	s3,8(sp)
    80001c80:	e052                	sd	s4,0(sp)
    80001c82:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001c84:	00000097          	auipc	ra,0x0
    80001c88:	c82080e7          	jalr	-894(ra) # 80001906 <myproc>
    80001c8c:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	d98080e7          	jalr	-616(ra) # 80001a26 <allocproc>
    80001c96:	c575                	beqz	a0,80001d82 <fork+0x10e>
    80001c98:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c9a:	05093603          	ld	a2,80(s2)
    80001c9e:	6d2c                	ld	a1,88(a0)
    80001ca0:	05893503          	ld	a0,88(s2)
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	79a080e7          	jalr	1946(ra) # 8000143e <uvmcopy>
    80001cac:	04054c63          	bltz	a0,80001d04 <fork+0x90>
  np->sz = p->sz;
    80001cb0:	05093783          	ld	a5,80(s2)
    80001cb4:	04f9b823          	sd	a5,80(s3) # 4000050 <_entry-0x7bffffb0>
  np->ustack=p->ustack;
    80001cb8:	04093783          	ld	a5,64(s2)
    80001cbc:	04f9b023          	sd	a5,64(s3)
  np->parent = p;
    80001cc0:	0329b023          	sd	s2,32(s3)
  *(np->tf) = *(p->tf);
    80001cc4:	06093683          	ld	a3,96(s2)
    80001cc8:	87b6                	mv	a5,a3
    80001cca:	0609b703          	ld	a4,96(s3)
    80001cce:	12068693          	addi	a3,a3,288
    80001cd2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001cd6:	6788                	ld	a0,8(a5)
    80001cd8:	6b8c                	ld	a1,16(a5)
    80001cda:	6f90                	ld	a2,24(a5)
    80001cdc:	01073023          	sd	a6,0(a4)
    80001ce0:	e708                	sd	a0,8(a4)
    80001ce2:	eb0c                	sd	a1,16(a4)
    80001ce4:	ef10                	sd	a2,24(a4)
    80001ce6:	02078793          	addi	a5,a5,32
    80001cea:	02070713          	addi	a4,a4,32
    80001cee:	fed792e3          	bne	a5,a3,80001cd2 <fork+0x5e>
  np->tf->a0 = 0;
    80001cf2:	0609b783          	ld	a5,96(s3)
    80001cf6:	0607b823          	sd	zero,112(a5)
    80001cfa:	0d800493          	li	s1,216
  for(i = 0; i < NOFILE; i++)
    80001cfe:	15800a13          	li	s4,344
    80001d02:	a03d                	j	80001d30 <fork+0xbc>
    freeproc(np);
    80001d04:	854e                	mv	a0,s3
    80001d06:	00000097          	auipc	ra,0x0
    80001d0a:	e1c080e7          	jalr	-484(ra) # 80001b22 <freeproc>
    release(&np->lock);
    80001d0e:	854e                	mv	a0,s3
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	e42080e7          	jalr	-446(ra) # 80000b52 <release>
    return -1;
    80001d18:	54fd                	li	s1,-1
    80001d1a:	a899                	j	80001d70 <fork+0xfc>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d1c:	00003097          	auipc	ra,0x3
    80001d20:	968080e7          	jalr	-1688(ra) # 80004684 <filedup>
    80001d24:	009987b3          	add	a5,s3,s1
    80001d28:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001d2a:	04a1                	addi	s1,s1,8
    80001d2c:	01448763          	beq	s1,s4,80001d3a <fork+0xc6>
    if(p->ofile[i])
    80001d30:	009907b3          	add	a5,s2,s1
    80001d34:	6388                	ld	a0,0(a5)
    80001d36:	f17d                	bnez	a0,80001d1c <fork+0xa8>
    80001d38:	bfcd                	j	80001d2a <fork+0xb6>
  np->cwd = idup(p->cwd);
    80001d3a:	15893503          	ld	a0,344(s2)
    80001d3e:	00002097          	auipc	ra,0x2
    80001d42:	88a080e7          	jalr	-1910(ra) # 800035c8 <idup>
    80001d46:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d4a:	4641                	li	a2,16
    80001d4c:	16090593          	addi	a1,s2,352
    80001d50:	16098513          	addi	a0,s3,352
    80001d54:	fffff097          	auipc	ra,0xfffff
    80001d58:	fb0080e7          	jalr	-80(ra) # 80000d04 <safestrcpy>
  pid = np->pid;
    80001d5c:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001d60:	4789                	li	a5,2
    80001d62:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d66:	854e                	mv	a0,s3
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	dea080e7          	jalr	-534(ra) # 80000b52 <release>
}
    80001d70:	8526                	mv	a0,s1
    80001d72:	70a2                	ld	ra,40(sp)
    80001d74:	7402                	ld	s0,32(sp)
    80001d76:	64e2                	ld	s1,24(sp)
    80001d78:	6942                	ld	s2,16(sp)
    80001d7a:	69a2                	ld	s3,8(sp)
    80001d7c:	6a02                	ld	s4,0(sp)
    80001d7e:	6145                	addi	sp,sp,48
    80001d80:	8082                	ret
    return -1;
    80001d82:	54fd                	li	s1,-1
    80001d84:	b7f5                	j	80001d70 <fork+0xfc>

0000000080001d86 <reparent>:
reparent(struct proc *p, struct proc *parent) {
    80001d86:	711d                	addi	sp,sp,-96
    80001d88:	ec86                	sd	ra,88(sp)
    80001d8a:	e8a2                	sd	s0,80(sp)
    80001d8c:	e4a6                	sd	s1,72(sp)
    80001d8e:	e0ca                	sd	s2,64(sp)
    80001d90:	fc4e                	sd	s3,56(sp)
    80001d92:	f852                	sd	s4,48(sp)
    80001d94:	f456                	sd	s5,40(sp)
    80001d96:	f05a                	sd	s6,32(sp)
    80001d98:	ec5e                	sd	s7,24(sp)
    80001d9a:	e862                	sd	s8,16(sp)
    80001d9c:	e466                	sd	s9,8(sp)
    80001d9e:	1080                	addi	s0,sp,96
    80001da0:	892a                	mv	s2,a0
  int child_of_init = (p->parent == initproc);
    80001da2:	02053b83          	ld	s7,32(a0)
    80001da6:	00027b17          	auipc	s6,0x27
    80001daa:	292b3b03          	ld	s6,658(s6) # 80029038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001dae:	00011497          	auipc	s1,0x11
    80001db2:	f5248493          	addi	s1,s1,-174 # 80012d00 <proc>
      pp->parent = initproc;
    80001db6:	00027a17          	auipc	s4,0x27
    80001dba:	282a0a13          	addi	s4,s4,642 # 80029038 <initproc>
      if(pp->state == ZOMBIE) {
    80001dbe:	4a91                	li	s5,4
// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
  if(p->chan == p && p->state == SLEEPING) {
    80001dc0:	4c05                	li	s8,1
    p->state = RUNNABLE;
    80001dc2:	4c89                	li	s9,2
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001dc4:	00017997          	auipc	s3,0x17
    80001dc8:	b3c98993          	addi	s3,s3,-1220 # 80018900 <tickslock>
    80001dcc:	a805                	j	80001dfc <reparent+0x76>
  if(p->chan == p && p->state == SLEEPING) {
    80001dce:	751c                	ld	a5,40(a0)
    80001dd0:	00f51d63          	bne	a0,a5,80001dea <reparent+0x64>
    80001dd4:	4d1c                	lw	a5,24(a0)
    80001dd6:	01879a63          	bne	a5,s8,80001dea <reparent+0x64>
    p->state = RUNNABLE;
    80001dda:	01952c23          	sw	s9,24(a0)
        if(!child_of_init)
    80001dde:	016b8663          	beq	s7,s6,80001dea <reparent+0x64>
          release(&initproc->lock);
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	d70080e7          	jalr	-656(ra) # 80000b52 <release>
      release(&pp->lock);
    80001dea:	8526                	mv	a0,s1
    80001dec:	fffff097          	auipc	ra,0xfffff
    80001df0:	d66080e7          	jalr	-666(ra) # 80000b52 <release>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001df4:	17048493          	addi	s1,s1,368
    80001df8:	03348f63          	beq	s1,s3,80001e36 <reparent+0xb0>
    if(pp->parent == p){
    80001dfc:	709c                	ld	a5,32(s1)
    80001dfe:	ff279be3          	bne	a5,s2,80001df4 <reparent+0x6e>
      acquire(&pp->lock);
    80001e02:	8526                	mv	a0,s1
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	ce6080e7          	jalr	-794(ra) # 80000aea <acquire>
      pp->parent = initproc;
    80001e0c:	000a3503          	ld	a0,0(s4)
    80001e10:	f088                	sd	a0,32(s1)
      if(pp->state == ZOMBIE) {
    80001e12:	4c9c                	lw	a5,24(s1)
    80001e14:	fd579be3          	bne	a5,s5,80001dea <reparent+0x64>
        if(!child_of_init)
    80001e18:	fb6b8be3          	beq	s7,s6,80001dce <reparent+0x48>
          acquire(&initproc->lock);
    80001e1c:	fffff097          	auipc	ra,0xfffff
    80001e20:	cce080e7          	jalr	-818(ra) # 80000aea <acquire>
        wakeup1(initproc);
    80001e24:	000a3503          	ld	a0,0(s4)
  if(p->chan == p && p->state == SLEEPING) {
    80001e28:	751c                	ld	a5,40(a0)
    80001e2a:	faa79ce3          	bne	a5,a0,80001de2 <reparent+0x5c>
    80001e2e:	4d1c                	lw	a5,24(a0)
    80001e30:	fb8799e3          	bne	a5,s8,80001de2 <reparent+0x5c>
    80001e34:	b75d                	j	80001dda <reparent+0x54>
}
    80001e36:	60e6                	ld	ra,88(sp)
    80001e38:	6446                	ld	s0,80(sp)
    80001e3a:	64a6                	ld	s1,72(sp)
    80001e3c:	6906                	ld	s2,64(sp)
    80001e3e:	79e2                	ld	s3,56(sp)
    80001e40:	7a42                	ld	s4,48(sp)
    80001e42:	7aa2                	ld	s5,40(sp)
    80001e44:	7b02                	ld	s6,32(sp)
    80001e46:	6be2                	ld	s7,24(sp)
    80001e48:	6c42                	ld	s8,16(sp)
    80001e4a:	6ca2                	ld	s9,8(sp)
    80001e4c:	6125                	addi	sp,sp,96
    80001e4e:	8082                	ret

0000000080001e50 <scheduler>:
{
    80001e50:	715d                	addi	sp,sp,-80
    80001e52:	e486                	sd	ra,72(sp)
    80001e54:	e0a2                	sd	s0,64(sp)
    80001e56:	fc26                	sd	s1,56(sp)
    80001e58:	f84a                	sd	s2,48(sp)
    80001e5a:	f44e                	sd	s3,40(sp)
    80001e5c:	f052                	sd	s4,32(sp)
    80001e5e:	ec56                	sd	s5,24(sp)
    80001e60:	e85a                	sd	s6,16(sp)
    80001e62:	e45e                	sd	s7,8(sp)
    80001e64:	e062                	sd	s8,0(sp)
    80001e66:	0880                	addi	s0,sp,80
    80001e68:	8792                	mv	a5,tp
  int id = r_tp();
    80001e6a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001e6c:	00779b13          	slli	s6,a5,0x7
    80001e70:	00011717          	auipc	a4,0x11
    80001e74:	a7870713          	addi	a4,a4,-1416 # 800128e8 <pid_lock>
    80001e78:	975a                	add	a4,a4,s6
    80001e7a:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001e7e:	00011717          	auipc	a4,0x11
    80001e82:	a8a70713          	addi	a4,a4,-1398 # 80012908 <cpus+0x8>
    80001e86:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e88:	4c0d                	li	s8,3
        c->proc = p;
    80001e8a:	079e                	slli	a5,a5,0x7
    80001e8c:	00011a17          	auipc	s4,0x11
    80001e90:	a5ca0a13          	addi	s4,s4,-1444 # 800128e8 <pid_lock>
    80001e94:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e96:	00017997          	auipc	s3,0x17
    80001e9a:	a6a98993          	addi	s3,s3,-1430 # 80018900 <tickslock>
        found = 1;
    80001e9e:	4b85                	li	s7,1
    80001ea0:	a08d                	j	80001f02 <scheduler+0xb2>
        p->state = RUNNING;
    80001ea2:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001ea6:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001eaa:	06848593          	addi	a1,s1,104
    80001eae:	855a                	mv	a0,s6
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	62a080e7          	jalr	1578(ra) # 800024da <swtch>
        c->proc = 0;
    80001eb8:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001ebc:	8ade                	mv	s5,s7
      release(&p->lock);
    80001ebe:	8526                	mv	a0,s1
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	c92080e7          	jalr	-878(ra) # 80000b52 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ec8:	17048493          	addi	s1,s1,368
    80001ecc:	01348b63          	beq	s1,s3,80001ee2 <scheduler+0x92>
      acquire(&p->lock);
    80001ed0:	8526                	mv	a0,s1
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	c18080e7          	jalr	-1000(ra) # 80000aea <acquire>
      if(p->state == RUNNABLE) {
    80001eda:	4c9c                	lw	a5,24(s1)
    80001edc:	ff2791e3          	bne	a5,s2,80001ebe <scheduler+0x6e>
    80001ee0:	b7c9                	j	80001ea2 <scheduler+0x52>
    if(found == 0){
    80001ee2:	020a9063          	bnez	s5,80001f02 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001ee6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001eea:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001eee:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ef2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efa:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001efe:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001f02:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001f06:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001f0a:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f0e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f12:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f16:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001f1a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f1c:	00011497          	auipc	s1,0x11
    80001f20:	de448493          	addi	s1,s1,-540 # 80012d00 <proc>
      if(p->state == RUNNABLE) {
    80001f24:	4909                	li	s2,2
    80001f26:	b76d                	j	80001ed0 <scheduler+0x80>

0000000080001f28 <sched>:
{
    80001f28:	7179                	addi	sp,sp,-48
    80001f2a:	f406                	sd	ra,40(sp)
    80001f2c:	f022                	sd	s0,32(sp)
    80001f2e:	ec26                	sd	s1,24(sp)
    80001f30:	e84a                	sd	s2,16(sp)
    80001f32:	e44e                	sd	s3,8(sp)
    80001f34:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f36:	00000097          	auipc	ra,0x0
    80001f3a:	9d0080e7          	jalr	-1584(ra) # 80001906 <myproc>
    80001f3e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f40:	fffff097          	auipc	ra,0xfffff
    80001f44:	b6a080e7          	jalr	-1174(ra) # 80000aaa <holding>
    80001f48:	c93d                	beqz	a0,80001fbe <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f4a:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f4c:	2781                	sext.w	a5,a5
    80001f4e:	079e                	slli	a5,a5,0x7
    80001f50:	00011717          	auipc	a4,0x11
    80001f54:	99870713          	addi	a4,a4,-1640 # 800128e8 <pid_lock>
    80001f58:	97ba                	add	a5,a5,a4
    80001f5a:	0907a703          	lw	a4,144(a5)
    80001f5e:	4785                	li	a5,1
    80001f60:	06f71763          	bne	a4,a5,80001fce <sched+0xa6>
  if(p->state == RUNNING)
    80001f64:	4c98                	lw	a4,24(s1)
    80001f66:	478d                	li	a5,3
    80001f68:	06f70b63          	beq	a4,a5,80001fde <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f6c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f70:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f72:	efb5                	bnez	a5,80001fee <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f74:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f76:	00011917          	auipc	s2,0x11
    80001f7a:	97290913          	addi	s2,s2,-1678 # 800128e8 <pid_lock>
    80001f7e:	2781                	sext.w	a5,a5
    80001f80:	079e                	slli	a5,a5,0x7
    80001f82:	97ca                	add	a5,a5,s2
    80001f84:	0947a983          	lw	s3,148(a5)
    80001f88:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001f8a:	2781                	sext.w	a5,a5
    80001f8c:	079e                	slli	a5,a5,0x7
    80001f8e:	00011597          	auipc	a1,0x11
    80001f92:	97a58593          	addi	a1,a1,-1670 # 80012908 <cpus+0x8>
    80001f96:	95be                	add	a1,a1,a5
    80001f98:	06848513          	addi	a0,s1,104
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	53e080e7          	jalr	1342(ra) # 800024da <swtch>
    80001fa4:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fa6:	2781                	sext.w	a5,a5
    80001fa8:	079e                	slli	a5,a5,0x7
    80001faa:	97ca                	add	a5,a5,s2
    80001fac:	0937aa23          	sw	s3,148(a5)
}
    80001fb0:	70a2                	ld	ra,40(sp)
    80001fb2:	7402                	ld	s0,32(sp)
    80001fb4:	64e2                	ld	s1,24(sp)
    80001fb6:	6942                	ld	s2,16(sp)
    80001fb8:	69a2                	ld	s3,8(sp)
    80001fba:	6145                	addi	sp,sp,48
    80001fbc:	8082                	ret
    panic("sched p->lock");
    80001fbe:	00006517          	auipc	a0,0x6
    80001fc2:	33250513          	addi	a0,a0,818 # 800082f0 <userret+0x260>
    80001fc6:	ffffe097          	auipc	ra,0xffffe
    80001fca:	588080e7          	jalr	1416(ra) # 8000054e <panic>
    panic("sched locks");
    80001fce:	00006517          	auipc	a0,0x6
    80001fd2:	33250513          	addi	a0,a0,818 # 80008300 <userret+0x270>
    80001fd6:	ffffe097          	auipc	ra,0xffffe
    80001fda:	578080e7          	jalr	1400(ra) # 8000054e <panic>
    panic("sched running");
    80001fde:	00006517          	auipc	a0,0x6
    80001fe2:	33250513          	addi	a0,a0,818 # 80008310 <userret+0x280>
    80001fe6:	ffffe097          	auipc	ra,0xffffe
    80001fea:	568080e7          	jalr	1384(ra) # 8000054e <panic>
    panic("sched interruptible");
    80001fee:	00006517          	auipc	a0,0x6
    80001ff2:	33250513          	addi	a0,a0,818 # 80008320 <userret+0x290>
    80001ff6:	ffffe097          	auipc	ra,0xffffe
    80001ffa:	558080e7          	jalr	1368(ra) # 8000054e <panic>

0000000080001ffe <exit>:
{
    80001ffe:	7179                	addi	sp,sp,-48
    80002000:	f406                	sd	ra,40(sp)
    80002002:	f022                	sd	s0,32(sp)
    80002004:	ec26                	sd	s1,24(sp)
    80002006:	e84a                	sd	s2,16(sp)
    80002008:	e44e                	sd	s3,8(sp)
    8000200a:	e052                	sd	s4,0(sp)
    8000200c:	1800                	addi	s0,sp,48
    8000200e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002010:	00000097          	auipc	ra,0x0
    80002014:	8f6080e7          	jalr	-1802(ra) # 80001906 <myproc>
    80002018:	89aa                	mv	s3,a0
  if(p == initproc)
    8000201a:	00027797          	auipc	a5,0x27
    8000201e:	01e7b783          	ld	a5,30(a5) # 80029038 <initproc>
    80002022:	0d850493          	addi	s1,a0,216
    80002026:	15850913          	addi	s2,a0,344
    8000202a:	02a79363          	bne	a5,a0,80002050 <exit+0x52>
    panic("init exiting");
    8000202e:	00006517          	auipc	a0,0x6
    80002032:	30a50513          	addi	a0,a0,778 # 80008338 <userret+0x2a8>
    80002036:	ffffe097          	auipc	ra,0xffffe
    8000203a:	518080e7          	jalr	1304(ra) # 8000054e <panic>
      fileclose(f);
    8000203e:	00002097          	auipc	ra,0x2
    80002042:	698080e7          	jalr	1688(ra) # 800046d6 <fileclose>
      p->ofile[fd] = 0;
    80002046:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000204a:	04a1                	addi	s1,s1,8
    8000204c:	01248563          	beq	s1,s2,80002056 <exit+0x58>
    if(p->ofile[fd]){
    80002050:	6088                	ld	a0,0(s1)
    80002052:	f575                	bnez	a0,8000203e <exit+0x40>
    80002054:	bfdd                	j	8000204a <exit+0x4c>
  begin_op(ROOTDEV);
    80002056:	4501                	li	a0,0
    80002058:	00002097          	auipc	ra,0x2
    8000205c:	056080e7          	jalr	86(ra) # 800040ae <begin_op>
  iput(p->cwd);
    80002060:	1589b503          	ld	a0,344(s3)
    80002064:	00001097          	auipc	ra,0x1
    80002068:	6b0080e7          	jalr	1712(ra) # 80003714 <iput>
  end_op(ROOTDEV);
    8000206c:	4501                	li	a0,0
    8000206e:	00002097          	auipc	ra,0x2
    80002072:	0ea080e7          	jalr	234(ra) # 80004158 <end_op>
  p->cwd = 0;
    80002076:	1409bc23          	sd	zero,344(s3)
  acquire(&p->parent->lock);
    8000207a:	0209b503          	ld	a0,32(s3)
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	a6c080e7          	jalr	-1428(ra) # 80000aea <acquire>
  acquire(&p->lock);
    80002086:	854e                	mv	a0,s3
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	a62080e7          	jalr	-1438(ra) # 80000aea <acquire>
  reparent(p, p->parent);
    80002090:	0209b583          	ld	a1,32(s3)
    80002094:	854e                	mv	a0,s3
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	cf0080e7          	jalr	-784(ra) # 80001d86 <reparent>
  wakeup1(p->parent);
    8000209e:	0209b783          	ld	a5,32(s3)
  if(p->chan == p && p->state == SLEEPING) {
    800020a2:	7798                	ld	a4,40(a5)
    800020a4:	02e78963          	beq	a5,a4,800020d6 <exit+0xd8>
  p->xstate = status;
    800020a8:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800020ac:	4791                	li	a5,4
    800020ae:	00f9ac23          	sw	a5,24(s3)
  release(&p->parent->lock);
    800020b2:	0209b503          	ld	a0,32(s3)
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	a9c080e7          	jalr	-1380(ra) # 80000b52 <release>
  sched();
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	e6a080e7          	jalr	-406(ra) # 80001f28 <sched>
  panic("zombie exit");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	28250513          	addi	a0,a0,642 # 80008348 <userret+0x2b8>
    800020ce:	ffffe097          	auipc	ra,0xffffe
    800020d2:	480080e7          	jalr	1152(ra) # 8000054e <panic>
  if(p->chan == p && p->state == SLEEPING) {
    800020d6:	4f94                	lw	a3,24(a5)
    800020d8:	4705                	li	a4,1
    800020da:	fce697e3          	bne	a3,a4,800020a8 <exit+0xaa>
    p->state = RUNNABLE;
    800020de:	4709                	li	a4,2
    800020e0:	cf98                	sw	a4,24(a5)
    800020e2:	b7d9                	j	800020a8 <exit+0xaa>

00000000800020e4 <yield>:
{
    800020e4:	1101                	addi	sp,sp,-32
    800020e6:	ec06                	sd	ra,24(sp)
    800020e8:	e822                	sd	s0,16(sp)
    800020ea:	e426                	sd	s1,8(sp)
    800020ec:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	818080e7          	jalr	-2024(ra) # 80001906 <myproc>
    800020f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	9f2080e7          	jalr	-1550(ra) # 80000aea <acquire>
  p->state = RUNNABLE;
    80002100:	4789                	li	a5,2
    80002102:	cc9c                	sw	a5,24(s1)
  sched();
    80002104:	00000097          	auipc	ra,0x0
    80002108:	e24080e7          	jalr	-476(ra) # 80001f28 <sched>
  release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	fffff097          	auipc	ra,0xfffff
    80002112:	a44080e7          	jalr	-1468(ra) # 80000b52 <release>
}
    80002116:	60e2                	ld	ra,24(sp)
    80002118:	6442                	ld	s0,16(sp)
    8000211a:	64a2                	ld	s1,8(sp)
    8000211c:	6105                	addi	sp,sp,32
    8000211e:	8082                	ret

0000000080002120 <sleep>:
{
    80002120:	7179                	addi	sp,sp,-48
    80002122:	f406                	sd	ra,40(sp)
    80002124:	f022                	sd	s0,32(sp)
    80002126:	ec26                	sd	s1,24(sp)
    80002128:	e84a                	sd	s2,16(sp)
    8000212a:	e44e                	sd	s3,8(sp)
    8000212c:	1800                	addi	s0,sp,48
    8000212e:	89aa                	mv	s3,a0
    80002130:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	7d4080e7          	jalr	2004(ra) # 80001906 <myproc>
    8000213a:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000213c:	05250663          	beq	a0,s2,80002188 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	9aa080e7          	jalr	-1622(ra) # 80000aea <acquire>
    release(lk);
    80002148:	854a                	mv	a0,s2
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	a08080e7          	jalr	-1528(ra) # 80000b52 <release>
  p->chan = chan;
    80002152:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002156:	4785                	li	a5,1
    80002158:	cc9c                	sw	a5,24(s1)
  sched();
    8000215a:	00000097          	auipc	ra,0x0
    8000215e:	dce080e7          	jalr	-562(ra) # 80001f28 <sched>
  p->chan = 0;
    80002162:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002166:	8526                	mv	a0,s1
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	9ea080e7          	jalr	-1558(ra) # 80000b52 <release>
    acquire(lk);
    80002170:	854a                	mv	a0,s2
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	978080e7          	jalr	-1672(ra) # 80000aea <acquire>
}
    8000217a:	70a2                	ld	ra,40(sp)
    8000217c:	7402                	ld	s0,32(sp)
    8000217e:	64e2                	ld	s1,24(sp)
    80002180:	6942                	ld	s2,16(sp)
    80002182:	69a2                	ld	s3,8(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret
  p->chan = chan;
    80002188:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000218c:	4785                	li	a5,1
    8000218e:	cd1c                	sw	a5,24(a0)
  sched();
    80002190:	00000097          	auipc	ra,0x0
    80002194:	d98080e7          	jalr	-616(ra) # 80001f28 <sched>
  p->chan = 0;
    80002198:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    8000219c:	bff9                	j	8000217a <sleep+0x5a>

000000008000219e <wait>:
{
    8000219e:	715d                	addi	sp,sp,-80
    800021a0:	e486                	sd	ra,72(sp)
    800021a2:	e0a2                	sd	s0,64(sp)
    800021a4:	fc26                	sd	s1,56(sp)
    800021a6:	f84a                	sd	s2,48(sp)
    800021a8:	f44e                	sd	s3,40(sp)
    800021aa:	f052                	sd	s4,32(sp)
    800021ac:	ec56                	sd	s5,24(sp)
    800021ae:	e85a                	sd	s6,16(sp)
    800021b0:	e45e                	sd	s7,8(sp)
    800021b2:	e062                	sd	s8,0(sp)
    800021b4:	0880                	addi	s0,sp,80
    800021b6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021b8:	fffff097          	auipc	ra,0xfffff
    800021bc:	74e080e7          	jalr	1870(ra) # 80001906 <myproc>
    800021c0:	892a                	mv	s2,a0
  acquire(&p->lock);
    800021c2:	8c2a                	mv	s8,a0
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	926080e7          	jalr	-1754(ra) # 80000aea <acquire>
    havekids = 0;
    800021cc:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021ce:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800021d0:	00016997          	auipc	s3,0x16
    800021d4:	73098993          	addi	s3,s3,1840 # 80018900 <tickslock>
        havekids = 1;
    800021d8:	4a85                	li	s5,1
    havekids = 0;
    800021da:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800021dc:	00011497          	auipc	s1,0x11
    800021e0:	b2448493          	addi	s1,s1,-1244 # 80012d00 <proc>
    800021e4:	a08d                	j	80002246 <wait+0xa8>
          pid = np->pid;
    800021e6:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021ea:	000b0e63          	beqz	s6,80002206 <wait+0x68>
    800021ee:	4691                	li	a3,4
    800021f0:	03448613          	addi	a2,s1,52
    800021f4:	85da                	mv	a1,s6
    800021f6:	05893503          	ld	a0,88(s2)
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	346080e7          	jalr	838(ra) # 80001540 <copyout>
    80002202:	02054263          	bltz	a0,80002226 <wait+0x88>
          freeproc(np);
    80002206:	8526                	mv	a0,s1
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	91a080e7          	jalr	-1766(ra) # 80001b22 <freeproc>
          release(&np->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	940080e7          	jalr	-1728(ra) # 80000b52 <release>
          release(&p->lock);
    8000221a:	854a                	mv	a0,s2
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	936080e7          	jalr	-1738(ra) # 80000b52 <release>
          return pid;
    80002224:	a8a9                	j	8000227e <wait+0xe0>
            release(&np->lock);
    80002226:	8526                	mv	a0,s1
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	92a080e7          	jalr	-1750(ra) # 80000b52 <release>
            release(&p->lock);
    80002230:	854a                	mv	a0,s2
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	920080e7          	jalr	-1760(ra) # 80000b52 <release>
            return -1;
    8000223a:	59fd                	li	s3,-1
    8000223c:	a089                	j	8000227e <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000223e:	17048493          	addi	s1,s1,368
    80002242:	03348463          	beq	s1,s3,8000226a <wait+0xcc>
      if(np->parent == p){
    80002246:	709c                	ld	a5,32(s1)
    80002248:	ff279be3          	bne	a5,s2,8000223e <wait+0xa0>
        acquire(&np->lock);
    8000224c:	8526                	mv	a0,s1
    8000224e:	fffff097          	auipc	ra,0xfffff
    80002252:	89c080e7          	jalr	-1892(ra) # 80000aea <acquire>
        if(np->state == ZOMBIE){
    80002256:	4c9c                	lw	a5,24(s1)
    80002258:	f94787e3          	beq	a5,s4,800021e6 <wait+0x48>
        release(&np->lock);
    8000225c:	8526                	mv	a0,s1
    8000225e:	fffff097          	auipc	ra,0xfffff
    80002262:	8f4080e7          	jalr	-1804(ra) # 80000b52 <release>
        havekids = 1;
    80002266:	8756                	mv	a4,s5
    80002268:	bfd9                	j	8000223e <wait+0xa0>
    if(!havekids || p->killed){
    8000226a:	c701                	beqz	a4,80002272 <wait+0xd4>
    8000226c:	03092783          	lw	a5,48(s2)
    80002270:	c785                	beqz	a5,80002298 <wait+0xfa>
      release(&p->lock);
    80002272:	854a                	mv	a0,s2
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	8de080e7          	jalr	-1826(ra) # 80000b52 <release>
      return -1;
    8000227c:	59fd                	li	s3,-1
}
    8000227e:	854e                	mv	a0,s3
    80002280:	60a6                	ld	ra,72(sp)
    80002282:	6406                	ld	s0,64(sp)
    80002284:	74e2                	ld	s1,56(sp)
    80002286:	7942                	ld	s2,48(sp)
    80002288:	79a2                	ld	s3,40(sp)
    8000228a:	7a02                	ld	s4,32(sp)
    8000228c:	6ae2                	ld	s5,24(sp)
    8000228e:	6b42                	ld	s6,16(sp)
    80002290:	6ba2                	ld	s7,8(sp)
    80002292:	6c02                	ld	s8,0(sp)
    80002294:	6161                	addi	sp,sp,80
    80002296:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002298:	85e2                	mv	a1,s8
    8000229a:	854a                	mv	a0,s2
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	e84080e7          	jalr	-380(ra) # 80002120 <sleep>
    havekids = 0;
    800022a4:	bf1d                	j	800021da <wait+0x3c>

00000000800022a6 <wakeup>:
{
    800022a6:	7139                	addi	sp,sp,-64
    800022a8:	fc06                	sd	ra,56(sp)
    800022aa:	f822                	sd	s0,48(sp)
    800022ac:	f426                	sd	s1,40(sp)
    800022ae:	f04a                	sd	s2,32(sp)
    800022b0:	ec4e                	sd	s3,24(sp)
    800022b2:	e852                	sd	s4,16(sp)
    800022b4:	e456                	sd	s5,8(sp)
    800022b6:	0080                	addi	s0,sp,64
    800022b8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800022ba:	00011497          	auipc	s1,0x11
    800022be:	a4648493          	addi	s1,s1,-1466 # 80012d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800022c2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800022c4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800022c6:	00016917          	auipc	s2,0x16
    800022ca:	63a90913          	addi	s2,s2,1594 # 80018900 <tickslock>
    800022ce:	a821                	j	800022e6 <wakeup+0x40>
      p->state = RUNNABLE;
    800022d0:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	87c080e7          	jalr	-1924(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022de:	17048493          	addi	s1,s1,368
    800022e2:	01248e63          	beq	s1,s2,800022fe <wakeup+0x58>
    acquire(&p->lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	802080e7          	jalr	-2046(ra) # 80000aea <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800022f0:	4c9c                	lw	a5,24(s1)
    800022f2:	ff3791e3          	bne	a5,s3,800022d4 <wakeup+0x2e>
    800022f6:	749c                	ld	a5,40(s1)
    800022f8:	fd479ee3          	bne	a5,s4,800022d4 <wakeup+0x2e>
    800022fc:	bfd1                	j	800022d0 <wakeup+0x2a>
}
    800022fe:	70e2                	ld	ra,56(sp)
    80002300:	7442                	ld	s0,48(sp)
    80002302:	74a2                	ld	s1,40(sp)
    80002304:	7902                	ld	s2,32(sp)
    80002306:	69e2                	ld	s3,24(sp)
    80002308:	6a42                	ld	s4,16(sp)
    8000230a:	6aa2                	ld	s5,8(sp)
    8000230c:	6121                	addi	sp,sp,64
    8000230e:	8082                	ret

0000000080002310 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	1800                	addi	s0,sp,48
    8000231e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002320:	00011497          	auipc	s1,0x11
    80002324:	9e048493          	addi	s1,s1,-1568 # 80012d00 <proc>
    80002328:	00016997          	auipc	s3,0x16
    8000232c:	5d898993          	addi	s3,s3,1496 # 80018900 <tickslock>
    acquire(&p->lock);
    80002330:	8526                	mv	a0,s1
    80002332:	ffffe097          	auipc	ra,0xffffe
    80002336:	7b8080e7          	jalr	1976(ra) # 80000aea <acquire>
    if(p->pid == pid){
    8000233a:	5c9c                	lw	a5,56(s1)
    8000233c:	01278d63          	beq	a5,s2,80002356 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	810080e7          	jalr	-2032(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234a:	17048493          	addi	s1,s1,368
    8000234e:	ff3491e3          	bne	s1,s3,80002330 <kill+0x20>
  }
  return -1;
    80002352:	557d                	li	a0,-1
    80002354:	a821                	j	8000236c <kill+0x5c>
      p->killed = 1;
    80002356:	4785                	li	a5,1
    80002358:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000235a:	4c98                	lw	a4,24(s1)
    8000235c:	00f70f63          	beq	a4,a5,8000237a <kill+0x6a>
      release(&p->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	ffffe097          	auipc	ra,0xffffe
    80002366:	7f0080e7          	jalr	2032(ra) # 80000b52 <release>
      return 0;
    8000236a:	4501                	li	a0,0
}
    8000236c:	70a2                	ld	ra,40(sp)
    8000236e:	7402                	ld	s0,32(sp)
    80002370:	64e2                	ld	s1,24(sp)
    80002372:	6942                	ld	s2,16(sp)
    80002374:	69a2                	ld	s3,8(sp)
    80002376:	6145                	addi	sp,sp,48
    80002378:	8082                	ret
        p->state = RUNNABLE;
    8000237a:	4789                	li	a5,2
    8000237c:	cc9c                	sw	a5,24(s1)
    8000237e:	b7cd                	j	80002360 <kill+0x50>

0000000080002380 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002380:	7179                	addi	sp,sp,-48
    80002382:	f406                	sd	ra,40(sp)
    80002384:	f022                	sd	s0,32(sp)
    80002386:	ec26                	sd	s1,24(sp)
    80002388:	e84a                	sd	s2,16(sp)
    8000238a:	e44e                	sd	s3,8(sp)
    8000238c:	e052                	sd	s4,0(sp)
    8000238e:	1800                	addi	s0,sp,48
    80002390:	84aa                	mv	s1,a0
    80002392:	892e                	mv	s2,a1
    80002394:	89b2                	mv	s3,a2
    80002396:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	56e080e7          	jalr	1390(ra) # 80001906 <myproc>
  if(user_dst){
    800023a0:	c08d                	beqz	s1,800023c2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800023a2:	86d2                	mv	a3,s4
    800023a4:	864e                	mv	a2,s3
    800023a6:	85ca                	mv	a1,s2
    800023a8:	6d28                	ld	a0,88(a0)
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	196080e7          	jalr	406(ra) # 80001540 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800023b2:	70a2                	ld	ra,40(sp)
    800023b4:	7402                	ld	s0,32(sp)
    800023b6:	64e2                	ld	s1,24(sp)
    800023b8:	6942                	ld	s2,16(sp)
    800023ba:	69a2                	ld	s3,8(sp)
    800023bc:	6a02                	ld	s4,0(sp)
    800023be:	6145                	addi	sp,sp,48
    800023c0:	8082                	ret
    memmove((char *)dst, src, len);
    800023c2:	000a061b          	sext.w	a2,s4
    800023c6:	85ce                	mv	a1,s3
    800023c8:	854a                	mv	a0,s2
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	844080e7          	jalr	-1980(ra) # 80000c0e <memmove>
    return 0;
    800023d2:	8526                	mv	a0,s1
    800023d4:	bff9                	j	800023b2 <either_copyout+0x32>

00000000800023d6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800023d6:	7179                	addi	sp,sp,-48
    800023d8:	f406                	sd	ra,40(sp)
    800023da:	f022                	sd	s0,32(sp)
    800023dc:	ec26                	sd	s1,24(sp)
    800023de:	e84a                	sd	s2,16(sp)
    800023e0:	e44e                	sd	s3,8(sp)
    800023e2:	e052                	sd	s4,0(sp)
    800023e4:	1800                	addi	s0,sp,48
    800023e6:	892a                	mv	s2,a0
    800023e8:	84ae                	mv	s1,a1
    800023ea:	89b2                	mv	s3,a2
    800023ec:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	518080e7          	jalr	1304(ra) # 80001906 <myproc>
  if(user_src){
    800023f6:	c08d                	beqz	s1,80002418 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800023f8:	86d2                	mv	a3,s4
    800023fa:	864e                	mv	a2,s3
    800023fc:	85ca                	mv	a1,s2
    800023fe:	6d28                	ld	a0,88(a0)
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	1d2080e7          	jalr	466(ra) # 800015d2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002408:	70a2                	ld	ra,40(sp)
    8000240a:	7402                	ld	s0,32(sp)
    8000240c:	64e2                	ld	s1,24(sp)
    8000240e:	6942                	ld	s2,16(sp)
    80002410:	69a2                	ld	s3,8(sp)
    80002412:	6a02                	ld	s4,0(sp)
    80002414:	6145                	addi	sp,sp,48
    80002416:	8082                	ret
    memmove(dst, (char*)src, len);
    80002418:	000a061b          	sext.w	a2,s4
    8000241c:	85ce                	mv	a1,s3
    8000241e:	854a                	mv	a0,s2
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	7ee080e7          	jalr	2030(ra) # 80000c0e <memmove>
    return 0;
    80002428:	8526                	mv	a0,s1
    8000242a:	bff9                	j	80002408 <either_copyin+0x32>

000000008000242c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000242c:	715d                	addi	sp,sp,-80
    8000242e:	e486                	sd	ra,72(sp)
    80002430:	e0a2                	sd	s0,64(sp)
    80002432:	fc26                	sd	s1,56(sp)
    80002434:	f84a                	sd	s2,48(sp)
    80002436:	f44e                	sd	s3,40(sp)
    80002438:	f052                	sd	s4,32(sp)
    8000243a:	ec56                	sd	s5,24(sp)
    8000243c:	e85a                	sd	s6,16(sp)
    8000243e:	e45e                	sd	s7,8(sp)
    80002440:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002442:	00006517          	auipc	a0,0x6
    80002446:	d6e50513          	addi	a0,a0,-658 # 800081b0 <userret+0x120>
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	14e080e7          	jalr	334(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002452:	00011497          	auipc	s1,0x11
    80002456:	a0e48493          	addi	s1,s1,-1522 # 80012e60 <proc+0x160>
    8000245a:	00016917          	auipc	s2,0x16
    8000245e:	60690913          	addi	s2,s2,1542 # 80018a60 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002462:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002464:	00006997          	auipc	s3,0x6
    80002468:	ef498993          	addi	s3,s3,-268 # 80008358 <userret+0x2c8>
    printf("%d %s %s", p->pid, state, p->name);
    8000246c:	00006a97          	auipc	s5,0x6
    80002470:	ef4a8a93          	addi	s5,s5,-268 # 80008360 <userret+0x2d0>
    printf("\n");
    80002474:	00006a17          	auipc	s4,0x6
    80002478:	d3ca0a13          	addi	s4,s4,-708 # 800081b0 <userret+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000247c:	00006b97          	auipc	s7,0x6
    80002480:	57cb8b93          	addi	s7,s7,1404 # 800089f8 <states.1790>
    80002484:	a00d                	j	800024a6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002486:	ed86a583          	lw	a1,-296(a3)
    8000248a:	8556                	mv	a0,s5
    8000248c:	ffffe097          	auipc	ra,0xffffe
    80002490:	10c080e7          	jalr	268(ra) # 80000598 <printf>
    printf("\n");
    80002494:	8552                	mv	a0,s4
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	102080e7          	jalr	258(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000249e:	17048493          	addi	s1,s1,368
    800024a2:	03248163          	beq	s1,s2,800024c4 <procdump+0x98>
    if(p->state == UNUSED)
    800024a6:	86a6                	mv	a3,s1
    800024a8:	eb84a783          	lw	a5,-328(s1)
    800024ac:	dbed                	beqz	a5,8000249e <procdump+0x72>
      state = "???";
    800024ae:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800024b0:	fcfb6be3          	bltu	s6,a5,80002486 <procdump+0x5a>
    800024b4:	1782                	slli	a5,a5,0x20
    800024b6:	9381                	srli	a5,a5,0x20
    800024b8:	078e                	slli	a5,a5,0x3
    800024ba:	97de                	add	a5,a5,s7
    800024bc:	6390                	ld	a2,0(a5)
    800024be:	f661                	bnez	a2,80002486 <procdump+0x5a>
      state = "???";
    800024c0:	864e                	mv	a2,s3
    800024c2:	b7d1                	j	80002486 <procdump+0x5a>
  }
}
    800024c4:	60a6                	ld	ra,72(sp)
    800024c6:	6406                	ld	s0,64(sp)
    800024c8:	74e2                	ld	s1,56(sp)
    800024ca:	7942                	ld	s2,48(sp)
    800024cc:	79a2                	ld	s3,40(sp)
    800024ce:	7a02                	ld	s4,32(sp)
    800024d0:	6ae2                	ld	s5,24(sp)
    800024d2:	6b42                	ld	s6,16(sp)
    800024d4:	6ba2                	ld	s7,8(sp)
    800024d6:	6161                	addi	sp,sp,80
    800024d8:	8082                	ret

00000000800024da <swtch>:
    800024da:	00153023          	sd	ra,0(a0)
    800024de:	00253423          	sd	sp,8(a0)
    800024e2:	e900                	sd	s0,16(a0)
    800024e4:	ed04                	sd	s1,24(a0)
    800024e6:	03253023          	sd	s2,32(a0)
    800024ea:	03353423          	sd	s3,40(a0)
    800024ee:	03453823          	sd	s4,48(a0)
    800024f2:	03553c23          	sd	s5,56(a0)
    800024f6:	05653023          	sd	s6,64(a0)
    800024fa:	05753423          	sd	s7,72(a0)
    800024fe:	05853823          	sd	s8,80(a0)
    80002502:	05953c23          	sd	s9,88(a0)
    80002506:	07a53023          	sd	s10,96(a0)
    8000250a:	07b53423          	sd	s11,104(a0)
    8000250e:	0005b083          	ld	ra,0(a1)
    80002512:	0085b103          	ld	sp,8(a1)
    80002516:	6980                	ld	s0,16(a1)
    80002518:	6d84                	ld	s1,24(a1)
    8000251a:	0205b903          	ld	s2,32(a1)
    8000251e:	0285b983          	ld	s3,40(a1)
    80002522:	0305ba03          	ld	s4,48(a1)
    80002526:	0385ba83          	ld	s5,56(a1)
    8000252a:	0405bb03          	ld	s6,64(a1)
    8000252e:	0485bb83          	ld	s7,72(a1)
    80002532:	0505bc03          	ld	s8,80(a1)
    80002536:	0585bc83          	ld	s9,88(a1)
    8000253a:	0605bd03          	ld	s10,96(a1)
    8000253e:	0685bd83          	ld	s11,104(a1)
    80002542:	8082                	ret

0000000080002544 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002544:	1141                	addi	sp,sp,-16
    80002546:	e406                	sd	ra,8(sp)
    80002548:	e022                	sd	s0,0(sp)
    8000254a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000254c:	00006597          	auipc	a1,0x6
    80002550:	e4c58593          	addi	a1,a1,-436 # 80008398 <userret+0x308>
    80002554:	00016517          	auipc	a0,0x16
    80002558:	3ac50513          	addi	a0,a0,940 # 80018900 <tickslock>
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	47c080e7          	jalr	1148(ra) # 800009d8 <initlock>
}
    80002564:	60a2                	ld	ra,8(sp)
    80002566:	6402                	ld	s0,0(sp)
    80002568:	0141                	addi	sp,sp,16
    8000256a:	8082                	ret

000000008000256c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000256c:	1141                	addi	sp,sp,-16
    8000256e:	e422                	sd	s0,8(sp)
    80002570:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002572:	00004797          	auipc	a5,0x4
    80002576:	80e78793          	addi	a5,a5,-2034 # 80005d80 <kernelvec>
    8000257a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000257e:	6422                	ld	s0,8(sp)
    80002580:	0141                	addi	sp,sp,16
    80002582:	8082                	ret

0000000080002584 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002584:	1141                	addi	sp,sp,-16
    80002586:	e406                	sd	ra,8(sp)
    80002588:	e022                	sd	s0,0(sp)
    8000258a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	37a080e7          	jalr	890(ra) # 80001906 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002594:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002598:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000259a:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send interrupts and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000259e:	00006617          	auipc	a2,0x6
    800025a2:	a6260613          	addi	a2,a2,-1438 # 80008000 <trampoline>
    800025a6:	00006697          	auipc	a3,0x6
    800025aa:	a5a68693          	addi	a3,a3,-1446 # 80008000 <trampoline>
    800025ae:	8e91                	sub	a3,a3,a2
    800025b0:	040007b7          	lui	a5,0x4000
    800025b4:	17fd                	addi	a5,a5,-1
    800025b6:	07b2                	slli	a5,a5,0xc
    800025b8:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025ba:	10569073          	csrw	stvec,a3

  // set up values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800025be:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800025c0:	180026f3          	csrr	a3,satp
    800025c4:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800025c6:	7138                	ld	a4,96(a0)
    800025c8:	6534                	ld	a3,72(a0)
    800025ca:	6585                	lui	a1,0x1
    800025cc:	96ae                	add	a3,a3,a1
    800025ce:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800025d0:	7138                	ld	a4,96(a0)
    800025d2:	00000697          	auipc	a3,0x0
    800025d6:	12868693          	addi	a3,a3,296 # 800026fa <usertrap>
    800025da:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800025dc:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800025de:	8692                	mv	a3,tp
    800025e0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e2:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800025e6:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800025ea:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025ee:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800025f2:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800025f4:	6f18                	ld	a4,24(a4)
    800025f6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800025fa:	6d2c                	ld	a1,88(a0)
    800025fc:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800025fe:	00006717          	auipc	a4,0x6
    80002602:	a9270713          	addi	a4,a4,-1390 # 80008090 <userret>
    80002606:	8f11                	sub	a4,a4,a2
    80002608:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000260a:	577d                	li	a4,-1
    8000260c:	177e                	slli	a4,a4,0x3f
    8000260e:	8dd9                	or	a1,a1,a4
    80002610:	02000537          	lui	a0,0x2000
    80002614:	157d                	addi	a0,a0,-1
    80002616:	0536                	slli	a0,a0,0xd
    80002618:	9782                	jalr	a5
}
    8000261a:	60a2                	ld	ra,8(sp)
    8000261c:	6402                	ld	s0,0(sp)
    8000261e:	0141                	addi	sp,sp,16
    80002620:	8082                	ret

0000000080002622 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002622:	1101                	addi	sp,sp,-32
    80002624:	ec06                	sd	ra,24(sp)
    80002626:	e822                	sd	s0,16(sp)
    80002628:	e426                	sd	s1,8(sp)
    8000262a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000262c:	00016497          	auipc	s1,0x16
    80002630:	2d448493          	addi	s1,s1,724 # 80018900 <tickslock>
    80002634:	8526                	mv	a0,s1
    80002636:	ffffe097          	auipc	ra,0xffffe
    8000263a:	4b4080e7          	jalr	1204(ra) # 80000aea <acquire>
  ticks++;
    8000263e:	00027517          	auipc	a0,0x27
    80002642:	a0250513          	addi	a0,a0,-1534 # 80029040 <ticks>
    80002646:	411c                	lw	a5,0(a0)
    80002648:	2785                	addiw	a5,a5,1
    8000264a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000264c:	00000097          	auipc	ra,0x0
    80002650:	c5a080e7          	jalr	-934(ra) # 800022a6 <wakeup>
  release(&tickslock);
    80002654:	8526                	mv	a0,s1
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	4fc080e7          	jalr	1276(ra) # 80000b52 <release>
}
    8000265e:	60e2                	ld	ra,24(sp)
    80002660:	6442                	ld	s0,16(sp)
    80002662:	64a2                	ld	s1,8(sp)
    80002664:	6105                	addi	sp,sp,32
    80002666:	8082                	ret

0000000080002668 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002668:	1101                	addi	sp,sp,-32
    8000266a:	ec06                	sd	ra,24(sp)
    8000266c:	e822                	sd	s0,16(sp)
    8000266e:	e426                	sd	s1,8(sp)
    80002670:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002672:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002676:	00074d63          	bltz	a4,80002690 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000267a:	57fd                	li	a5,-1
    8000267c:	17fe                	slli	a5,a5,0x3f
    8000267e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002680:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002682:	04f70b63          	beq	a4,a5,800026d8 <devintr+0x70>
  }
}
    80002686:	60e2                	ld	ra,24(sp)
    80002688:	6442                	ld	s0,16(sp)
    8000268a:	64a2                	ld	s1,8(sp)
    8000268c:	6105                	addi	sp,sp,32
    8000268e:	8082                	ret
     (scause & 0xff) == 9){
    80002690:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002694:	46a5                	li	a3,9
    80002696:	fed792e3          	bne	a5,a3,8000267a <devintr+0x12>
    int irq = plic_claim();
    8000269a:	00004097          	auipc	ra,0x4
    8000269e:	800080e7          	jalr	-2048(ra) # 80005e9a <plic_claim>
    800026a2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800026a4:	47a9                	li	a5,10
    800026a6:	00f50e63          	beq	a0,a5,800026c2 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800026aa:	fff5079b          	addiw	a5,a0,-1
    800026ae:	4705                	li	a4,1
    800026b0:	00f77e63          	bgeu	a4,a5,800026cc <devintr+0x64>
    plic_complete(irq);
    800026b4:	8526                	mv	a0,s1
    800026b6:	00004097          	auipc	ra,0x4
    800026ba:	808080e7          	jalr	-2040(ra) # 80005ebe <plic_complete>
    return 1;
    800026be:	4505                	li	a0,1
    800026c0:	b7d9                	j	80002686 <devintr+0x1e>
      uartintr();
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	176080e7          	jalr	374(ra) # 80000838 <uartintr>
    800026ca:	b7ed                	j	800026b4 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800026cc:	853e                	mv	a0,a5
    800026ce:	00004097          	auipc	ra,0x4
    800026d2:	dc0080e7          	jalr	-576(ra) # 8000648e <virtio_disk_intr>
    800026d6:	bff9                	j	800026b4 <devintr+0x4c>
    if(cpuid() == 0){
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	202080e7          	jalr	514(ra) # 800018da <cpuid>
    800026e0:	c901                	beqz	a0,800026f0 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800026e2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800026e6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800026e8:	14479073          	csrw	sip,a5
    return 2;
    800026ec:	4509                	li	a0,2
    800026ee:	bf61                	j	80002686 <devintr+0x1e>
      clockintr();
    800026f0:	00000097          	auipc	ra,0x0
    800026f4:	f32080e7          	jalr	-206(ra) # 80002622 <clockintr>
    800026f8:	b7ed                	j	800026e2 <devintr+0x7a>

00000000800026fa <usertrap>:
{
    800026fa:	7139                	addi	sp,sp,-64
    800026fc:	fc06                	sd	ra,56(sp)
    800026fe:	f822                	sd	s0,48(sp)
    80002700:	f426                	sd	s1,40(sp)
    80002702:	f04a                	sd	s2,32(sp)
    80002704:	ec4e                	sd	s3,24(sp)
    80002706:	e852                	sd	s4,16(sp)
    80002708:	e456                	sd	s5,8(sp)
    8000270a:	0080                	addi	s0,sp,64
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000270c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002710:	1007f793          	andi	a5,a5,256
    80002714:	ebbd                	bnez	a5,8000278a <usertrap+0x90>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002716:	00003797          	auipc	a5,0x3
    8000271a:	66a78793          	addi	a5,a5,1642 # 80005d80 <kernelvec>
    8000271e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002722:	fffff097          	auipc	ra,0xfffff
    80002726:	1e4080e7          	jalr	484(ra) # 80001906 <myproc>
    8000272a:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    8000272c:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000272e:	14102773          	csrr	a4,sepc
    80002732:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002734:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002738:	47a1                	li	a5,8
    8000273a:	06f71663          	bne	a4,a5,800027a6 <usertrap+0xac>
    if(p->killed)
    8000273e:	591c                	lw	a5,48(a0)
    80002740:	efa9                	bnez	a5,8000279a <usertrap+0xa0>
    p->tf->epc += 4;
    80002742:	70b8                	ld	a4,96(s1)
    80002744:	6f1c                	ld	a5,24(a4)
    80002746:	0791                	addi	a5,a5,4
    80002748:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000274a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000274e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002752:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002756:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000275a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000275e:	10079073          	csrw	sstatus,a5
    syscall();
    80002762:	00000097          	auipc	ra,0x0
    80002766:	37a080e7          	jalr	890(ra) # 80002adc <syscall>
  if(p->killed)
    8000276a:	589c                	lw	a5,48(s1)
    8000276c:	10079963          	bnez	a5,8000287e <usertrap+0x184>
  usertrapret();
    80002770:	00000097          	auipc	ra,0x0
    80002774:	e14080e7          	jalr	-492(ra) # 80002584 <usertrapret>
}
    80002778:	70e2                	ld	ra,56(sp)
    8000277a:	7442                	ld	s0,48(sp)
    8000277c:	74a2                	ld	s1,40(sp)
    8000277e:	7902                	ld	s2,32(sp)
    80002780:	69e2                	ld	s3,24(sp)
    80002782:	6a42                	ld	s4,16(sp)
    80002784:	6aa2                	ld	s5,8(sp)
    80002786:	6121                	addi	sp,sp,64
    80002788:	8082                	ret
    panic("usertrap: not from user mode");
    8000278a:	00006517          	auipc	a0,0x6
    8000278e:	c1650513          	addi	a0,a0,-1002 # 800083a0 <userret+0x310>
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	dbc080e7          	jalr	-580(ra) # 8000054e <panic>
      exit(-1);
    8000279a:	557d                	li	a0,-1
    8000279c:	00000097          	auipc	ra,0x0
    800027a0:	862080e7          	jalr	-1950(ra) # 80001ffe <exit>
    800027a4:	bf79                	j	80002742 <usertrap+0x48>
  } else if((which_dev = devintr()) != 0){
    800027a6:	00000097          	auipc	ra,0x0
    800027aa:	ec2080e7          	jalr	-318(ra) # 80002668 <devintr>
    800027ae:	892a                	mv	s2,a0
    800027b0:	e561                	bnez	a0,80002878 <usertrap+0x17e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027b2:	14202773          	csrr	a4,scause
  }else if(r_scause()==13||r_scause()==15){
    800027b6:	47b5                	li	a5,13
    800027b8:	00f70763          	beq	a4,a5,800027c6 <usertrap+0xcc>
    800027bc:	14202773          	csrr	a4,scause
    800027c0:	47bd                	li	a5,15
    800027c2:	08f71163          	bne	a4,a5,80002844 <usertrap+0x14a>
		struct proc *p=myproc();
    800027c6:	fffff097          	auipc	ra,0xfffff
    800027ca:	140080e7          	jalr	320(ra) # 80001906 <myproc>
    800027ce:	892a                	mv	s2,a0
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027d0:	143029f3          	csrr	s3,stval
		if(faddr>=p->sz||faddr<p->ustack){
    800027d4:	693c                	ld	a5,80(a0)
    800027d6:	00f9f563          	bgeu	s3,a5,800027e0 <usertrap+0xe6>
    800027da:	613c                	ld	a5,64(a0)
    800027dc:	00f9fd63          	bgeu	s3,a5,800027f6 <usertrap+0xfc>
			printf("out of page boundary\n");
    800027e0:	00006517          	auipc	a0,0x6
    800027e4:	be050513          	addi	a0,a0,-1056 # 800083c0 <userret+0x330>
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	db0080e7          	jalr	-592(ra) # 80000598 <printf>
			p->killed=0;
    800027f0:	02092823          	sw	zero,48(s2)
			goto end;
    800027f4:	bf9d                	j	8000276a <usertrap+0x70>
		pagetable_t t=p->pagetable;
    800027f6:	05853a83          	ld	s5,88(a0)
  	char *mem=kalloc();
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	17e080e7          	jalr	382(ra) # 80000978 <kalloc>
    80002802:	8a2a                	mv	s4,a0
		if(mem==0){
    80002804:	cd05                	beqz	a0,8000283c <usertrap+0x142>
		memset(mem,0,PGSIZE);
    80002806:	6605                	lui	a2,0x1
    80002808:	4581                	li	a1,0
    8000280a:	ffffe097          	auipc	ra,0xffffe
    8000280e:	3a4080e7          	jalr	932(ra) # 80000bae <memset>
		if(mappages(t, base, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80002812:	4779                	li	a4,30
    80002814:	86d2                	mv	a3,s4
    80002816:	6605                	lui	a2,0x1
    80002818:	75fd                	lui	a1,0xfffff
    8000281a:	00b9f5b3          	and	a1,s3,a1
    8000281e:	8556                	mv	a0,s5
    80002820:	fffff097          	auipc	ra,0xfffff
    80002824:	820080e7          	jalr	-2016(ra) # 80001040 <mappages>
    80002828:	d129                	beqz	a0,8000276a <usertrap+0x70>
      kfree(mem);
    8000282a:	8552                	mv	a0,s4
    8000282c:	ffffe097          	auipc	ra,0xffffe
    80002830:	038080e7          	jalr	56(ra) # 80000864 <kfree>
			p->killed=1;
    80002834:	4785                	li	a5,1
    80002836:	02f92823          	sw	a5,48(s2)
			goto end;
    8000283a:	bf05                	j	8000276a <usertrap+0x70>
			p->killed=1;
    8000283c:	4785                	li	a5,1
    8000283e:	02f92823          	sw	a5,48(s2)
			goto end;
    80002842:	b725                	j	8000276a <usertrap+0x70>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002844:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002848:	5c90                	lw	a2,56(s1)
    8000284a:	00006517          	auipc	a0,0x6
    8000284e:	b8e50513          	addi	a0,a0,-1138 # 800083d8 <userret+0x348>
    80002852:	ffffe097          	auipc	ra,0xffffe
    80002856:	d46080e7          	jalr	-698(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000285a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000285e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002862:	00006517          	auipc	a0,0x6
    80002866:	ba650513          	addi	a0,a0,-1114 # 80008408 <userret+0x378>
    8000286a:	ffffe097          	auipc	ra,0xffffe
    8000286e:	d2e080e7          	jalr	-722(ra) # 80000598 <printf>
    p->killed = 1;
    80002872:	4785                	li	a5,1
    80002874:	d89c                	sw	a5,48(s1)
  if(p->killed)
    80002876:	a029                	j	80002880 <usertrap+0x186>
    80002878:	589c                	lw	a5,48(s1)
    8000287a:	cb81                	beqz	a5,8000288a <usertrap+0x190>
    8000287c:	a011                	j	80002880 <usertrap+0x186>
    8000287e:	4901                	li	s2,0
    exit(-1);
    80002880:	557d                	li	a0,-1
    80002882:	fffff097          	auipc	ra,0xfffff
    80002886:	77c080e7          	jalr	1916(ra) # 80001ffe <exit>
  if(which_dev == 2)
    8000288a:	4789                	li	a5,2
    8000288c:	eef912e3          	bne	s2,a5,80002770 <usertrap+0x76>
    yield();
    80002890:	00000097          	auipc	ra,0x0
    80002894:	854080e7          	jalr	-1964(ra) # 800020e4 <yield>
    80002898:	bde1                	j	80002770 <usertrap+0x76>

000000008000289a <kerneltrap>:
{
    8000289a:	7179                	addi	sp,sp,-48
    8000289c:	f406                	sd	ra,40(sp)
    8000289e:	f022                	sd	s0,32(sp)
    800028a0:	ec26                	sd	s1,24(sp)
    800028a2:	e84a                	sd	s2,16(sp)
    800028a4:	e44e                	sd	s3,8(sp)
    800028a6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028a8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ac:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028b0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028b4:	1004f793          	andi	a5,s1,256
    800028b8:	cb85                	beqz	a5,800028e8 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ba:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028be:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028c0:	ef85                	bnez	a5,800028f8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800028c2:	00000097          	auipc	ra,0x0
    800028c6:	da6080e7          	jalr	-602(ra) # 80002668 <devintr>
    800028ca:	cd1d                	beqz	a0,80002908 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800028cc:	4789                	li	a5,2
    800028ce:	06f50a63          	beq	a0,a5,80002942 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028d2:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028d6:	10049073          	csrw	sstatus,s1
}
    800028da:	70a2                	ld	ra,40(sp)
    800028dc:	7402                	ld	s0,32(sp)
    800028de:	64e2                	ld	s1,24(sp)
    800028e0:	6942                	ld	s2,16(sp)
    800028e2:	69a2                	ld	s3,8(sp)
    800028e4:	6145                	addi	sp,sp,48
    800028e6:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	b4050513          	addi	a0,a0,-1216 # 80008428 <userret+0x398>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	c5e080e7          	jalr	-930(ra) # 8000054e <panic>
    panic("kerneltrap: interrupts enabled");
    800028f8:	00006517          	auipc	a0,0x6
    800028fc:	b5850513          	addi	a0,a0,-1192 # 80008450 <userret+0x3c0>
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	c4e080e7          	jalr	-946(ra) # 8000054e <panic>
    printf("scause %p\n", scause);
    80002908:	85ce                	mv	a1,s3
    8000290a:	00006517          	auipc	a0,0x6
    8000290e:	b6650513          	addi	a0,a0,-1178 # 80008470 <userret+0x3e0>
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	c86080e7          	jalr	-890(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000291a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000291e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002922:	00006517          	auipc	a0,0x6
    80002926:	b5e50513          	addi	a0,a0,-1186 # 80008480 <userret+0x3f0>
    8000292a:	ffffe097          	auipc	ra,0xffffe
    8000292e:	c6e080e7          	jalr	-914(ra) # 80000598 <printf>
    panic("kerneltrap");
    80002932:	00006517          	auipc	a0,0x6
    80002936:	b6650513          	addi	a0,a0,-1178 # 80008498 <userret+0x408>
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	c14080e7          	jalr	-1004(ra) # 8000054e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002942:	fffff097          	auipc	ra,0xfffff
    80002946:	fc4080e7          	jalr	-60(ra) # 80001906 <myproc>
    8000294a:	d541                	beqz	a0,800028d2 <kerneltrap+0x38>
    8000294c:	fffff097          	auipc	ra,0xfffff
    80002950:	fba080e7          	jalr	-70(ra) # 80001906 <myproc>
    80002954:	4d18                	lw	a4,24(a0)
    80002956:	478d                	li	a5,3
    80002958:	f6f71de3          	bne	a4,a5,800028d2 <kerneltrap+0x38>
    yield();
    8000295c:	fffff097          	auipc	ra,0xfffff
    80002960:	788080e7          	jalr	1928(ra) # 800020e4 <yield>
    80002964:	b7bd                	j	800028d2 <kerneltrap+0x38>

0000000080002966 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002966:	1101                	addi	sp,sp,-32
    80002968:	ec06                	sd	ra,24(sp)
    8000296a:	e822                	sd	s0,16(sp)
    8000296c:	e426                	sd	s1,8(sp)
    8000296e:	1000                	addi	s0,sp,32
    80002970:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002972:	fffff097          	auipc	ra,0xfffff
    80002976:	f94080e7          	jalr	-108(ra) # 80001906 <myproc>
  switch (n) {
    8000297a:	4795                	li	a5,5
    8000297c:	0497e163          	bltu	a5,s1,800029be <argraw+0x58>
    80002980:	048a                	slli	s1,s1,0x2
    80002982:	00006717          	auipc	a4,0x6
    80002986:	09e70713          	addi	a4,a4,158 # 80008a20 <states.1790+0x28>
    8000298a:	94ba                	add	s1,s1,a4
    8000298c:	409c                	lw	a5,0(s1)
    8000298e:	97ba                	add	a5,a5,a4
    80002990:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002992:	713c                	ld	a5,96(a0)
    80002994:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002996:	60e2                	ld	ra,24(sp)
    80002998:	6442                	ld	s0,16(sp)
    8000299a:	64a2                	ld	s1,8(sp)
    8000299c:	6105                	addi	sp,sp,32
    8000299e:	8082                	ret
    return p->tf->a1;
    800029a0:	713c                	ld	a5,96(a0)
    800029a2:	7fa8                	ld	a0,120(a5)
    800029a4:	bfcd                	j	80002996 <argraw+0x30>
    return p->tf->a2;
    800029a6:	713c                	ld	a5,96(a0)
    800029a8:	63c8                	ld	a0,128(a5)
    800029aa:	b7f5                	j	80002996 <argraw+0x30>
    return p->tf->a3;
    800029ac:	713c                	ld	a5,96(a0)
    800029ae:	67c8                	ld	a0,136(a5)
    800029b0:	b7dd                	j	80002996 <argraw+0x30>
    return p->tf->a4;
    800029b2:	713c                	ld	a5,96(a0)
    800029b4:	6bc8                	ld	a0,144(a5)
    800029b6:	b7c5                	j	80002996 <argraw+0x30>
    return p->tf->a5;
    800029b8:	713c                	ld	a5,96(a0)
    800029ba:	6fc8                	ld	a0,152(a5)
    800029bc:	bfe9                	j	80002996 <argraw+0x30>
  panic("argraw");
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	aea50513          	addi	a0,a0,-1302 # 800084a8 <userret+0x418>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	b88080e7          	jalr	-1144(ra) # 8000054e <panic>

00000000800029ce <fetchaddr>:
{
    800029ce:	1101                	addi	sp,sp,-32
    800029d0:	ec06                	sd	ra,24(sp)
    800029d2:	e822                	sd	s0,16(sp)
    800029d4:	e426                	sd	s1,8(sp)
    800029d6:	e04a                	sd	s2,0(sp)
    800029d8:	1000                	addi	s0,sp,32
    800029da:	84aa                	mv	s1,a0
    800029dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029de:	fffff097          	auipc	ra,0xfffff
    800029e2:	f28080e7          	jalr	-216(ra) # 80001906 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    800029e6:	693c                	ld	a5,80(a0)
    800029e8:	02f4f863          	bgeu	s1,a5,80002a18 <fetchaddr+0x4a>
    800029ec:	00848713          	addi	a4,s1,8
    800029f0:	02e7e663          	bltu	a5,a4,80002a1c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029f4:	46a1                	li	a3,8
    800029f6:	8626                	mv	a2,s1
    800029f8:	85ca                	mv	a1,s2
    800029fa:	6d28                	ld	a0,88(a0)
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	bd6080e7          	jalr	-1066(ra) # 800015d2 <copyin>
    80002a04:	00a03533          	snez	a0,a0
    80002a08:	40a00533          	neg	a0,a0
}
    80002a0c:	60e2                	ld	ra,24(sp)
    80002a0e:	6442                	ld	s0,16(sp)
    80002a10:	64a2                	ld	s1,8(sp)
    80002a12:	6902                	ld	s2,0(sp)
    80002a14:	6105                	addi	sp,sp,32
    80002a16:	8082                	ret
    return -1;
    80002a18:	557d                	li	a0,-1
    80002a1a:	bfcd                	j	80002a0c <fetchaddr+0x3e>
    80002a1c:	557d                	li	a0,-1
    80002a1e:	b7fd                	j	80002a0c <fetchaddr+0x3e>

0000000080002a20 <fetchstr>:
{
    80002a20:	7179                	addi	sp,sp,-48
    80002a22:	f406                	sd	ra,40(sp)
    80002a24:	f022                	sd	s0,32(sp)
    80002a26:	ec26                	sd	s1,24(sp)
    80002a28:	e84a                	sd	s2,16(sp)
    80002a2a:	e44e                	sd	s3,8(sp)
    80002a2c:	1800                	addi	s0,sp,48
    80002a2e:	892a                	mv	s2,a0
    80002a30:	84ae                	mv	s1,a1
    80002a32:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	ed2080e7          	jalr	-302(ra) # 80001906 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002a3c:	86ce                	mv	a3,s3
    80002a3e:	864a                	mv	a2,s2
    80002a40:	85a6                	mv	a1,s1
    80002a42:	6d28                	ld	a0,88(a0)
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	c20080e7          	jalr	-992(ra) # 80001664 <copyinstr>
  if(err < 0)
    80002a4c:	00054763          	bltz	a0,80002a5a <fetchstr+0x3a>
  return strlen(buf);
    80002a50:	8526                	mv	a0,s1
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	2e4080e7          	jalr	740(ra) # 80000d36 <strlen>
}
    80002a5a:	70a2                	ld	ra,40(sp)
    80002a5c:	7402                	ld	s0,32(sp)
    80002a5e:	64e2                	ld	s1,24(sp)
    80002a60:	6942                	ld	s2,16(sp)
    80002a62:	69a2                	ld	s3,8(sp)
    80002a64:	6145                	addi	sp,sp,48
    80002a66:	8082                	ret

0000000080002a68 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	1000                	addi	s0,sp,32
    80002a72:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a74:	00000097          	auipc	ra,0x0
    80002a78:	ef2080e7          	jalr	-270(ra) # 80002966 <argraw>
    80002a7c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002a7e:	4501                	li	a0,0
    80002a80:	60e2                	ld	ra,24(sp)
    80002a82:	6442                	ld	s0,16(sp)
    80002a84:	64a2                	ld	s1,8(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret

0000000080002a8a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002a8a:	1101                	addi	sp,sp,-32
    80002a8c:	ec06                	sd	ra,24(sp)
    80002a8e:	e822                	sd	s0,16(sp)
    80002a90:	e426                	sd	s1,8(sp)
    80002a92:	1000                	addi	s0,sp,32
    80002a94:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a96:	00000097          	auipc	ra,0x0
    80002a9a:	ed0080e7          	jalr	-304(ra) # 80002966 <argraw>
    80002a9e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002aa0:	4501                	li	a0,0
    80002aa2:	60e2                	ld	ra,24(sp)
    80002aa4:	6442                	ld	s0,16(sp)
    80002aa6:	64a2                	ld	s1,8(sp)
    80002aa8:	6105                	addi	sp,sp,32
    80002aaa:	8082                	ret

0000000080002aac <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002aac:	1101                	addi	sp,sp,-32
    80002aae:	ec06                	sd	ra,24(sp)
    80002ab0:	e822                	sd	s0,16(sp)
    80002ab2:	e426                	sd	s1,8(sp)
    80002ab4:	e04a                	sd	s2,0(sp)
    80002ab6:	1000                	addi	s0,sp,32
    80002ab8:	84ae                	mv	s1,a1
    80002aba:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	eaa080e7          	jalr	-342(ra) # 80002966 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002ac4:	864a                	mv	a2,s2
    80002ac6:	85a6                	mv	a1,s1
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	f58080e7          	jalr	-168(ra) # 80002a20 <fetchstr>
}
    80002ad0:	60e2                	ld	ra,24(sp)
    80002ad2:	6442                	ld	s0,16(sp)
    80002ad4:	64a2                	ld	s1,8(sp)
    80002ad6:	6902                	ld	s2,0(sp)
    80002ad8:	6105                	addi	sp,sp,32
    80002ada:	8082                	ret

0000000080002adc <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    80002adc:	1101                	addi	sp,sp,-32
    80002ade:	ec06                	sd	ra,24(sp)
    80002ae0:	e822                	sd	s0,16(sp)
    80002ae2:	e426                	sd	s1,8(sp)
    80002ae4:	e04a                	sd	s2,0(sp)
    80002ae6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ae8:	fffff097          	auipc	ra,0xfffff
    80002aec:	e1e080e7          	jalr	-482(ra) # 80001906 <myproc>
    80002af0:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002af2:	06053903          	ld	s2,96(a0)
    80002af6:	0a893783          	ld	a5,168(s2)
    80002afa:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002afe:	37fd                	addiw	a5,a5,-1
    80002b00:	4759                	li	a4,22
    80002b02:	00f76f63          	bltu	a4,a5,80002b20 <syscall+0x44>
    80002b06:	00369713          	slli	a4,a3,0x3
    80002b0a:	00006797          	auipc	a5,0x6
    80002b0e:	f2e78793          	addi	a5,a5,-210 # 80008a38 <syscalls>
    80002b12:	97ba                	add	a5,a5,a4
    80002b14:	639c                	ld	a5,0(a5)
    80002b16:	c789                	beqz	a5,80002b20 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002b18:	9782                	jalr	a5
    80002b1a:	06a93823          	sd	a0,112(s2)
    80002b1e:	a839                	j	80002b3c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b20:	16048613          	addi	a2,s1,352
    80002b24:	5c8c                	lw	a1,56(s1)
    80002b26:	00006517          	auipc	a0,0x6
    80002b2a:	98a50513          	addi	a0,a0,-1654 # 800084b0 <userret+0x420>
    80002b2e:	ffffe097          	auipc	ra,0xffffe
    80002b32:	a6a080e7          	jalr	-1430(ra) # 80000598 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002b36:	70bc                	ld	a5,96(s1)
    80002b38:	577d                	li	a4,-1
    80002b3a:	fbb8                	sd	a4,112(a5)
  }
}
    80002b3c:	60e2                	ld	ra,24(sp)
    80002b3e:	6442                	ld	s0,16(sp)
    80002b40:	64a2                	ld	s1,8(sp)
    80002b42:	6902                	ld	s2,0(sp)
    80002b44:	6105                	addi	sp,sp,32
    80002b46:	8082                	ret

0000000080002b48 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002b50:	fec40593          	addi	a1,s0,-20
    80002b54:	4501                	li	a0,0
    80002b56:	00000097          	auipc	ra,0x0
    80002b5a:	f12080e7          	jalr	-238(ra) # 80002a68 <argint>
    return -1;
    80002b5e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002b60:	00054963          	bltz	a0,80002b72 <sys_exit+0x2a>
  exit(n);
    80002b64:	fec42503          	lw	a0,-20(s0)
    80002b68:	fffff097          	auipc	ra,0xfffff
    80002b6c:	496080e7          	jalr	1174(ra) # 80001ffe <exit>
  return 0;  // not reached
    80002b70:	4781                	li	a5,0
}
    80002b72:	853e                	mv	a0,a5
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret

0000000080002b7c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b7c:	1141                	addi	sp,sp,-16
    80002b7e:	e406                	sd	ra,8(sp)
    80002b80:	e022                	sd	s0,0(sp)
    80002b82:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	d82080e7          	jalr	-638(ra) # 80001906 <myproc>
}
    80002b8c:	5d08                	lw	a0,56(a0)
    80002b8e:	60a2                	ld	ra,8(sp)
    80002b90:	6402                	ld	s0,0(sp)
    80002b92:	0141                	addi	sp,sp,16
    80002b94:	8082                	ret

0000000080002b96 <sys_fork>:

uint64
sys_fork(void)
{
    80002b96:	1141                	addi	sp,sp,-16
    80002b98:	e406                	sd	ra,8(sp)
    80002b9a:	e022                	sd	s0,0(sp)
    80002b9c:	0800                	addi	s0,sp,16
  return fork();
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	0d6080e7          	jalr	214(ra) # 80001c74 <fork>
}
    80002ba6:	60a2                	ld	ra,8(sp)
    80002ba8:	6402                	ld	s0,0(sp)
    80002baa:	0141                	addi	sp,sp,16
    80002bac:	8082                	ret

0000000080002bae <sys_wait>:

uint64
sys_wait(void)
{
    80002bae:	1101                	addi	sp,sp,-32
    80002bb0:	ec06                	sd	ra,24(sp)
    80002bb2:	e822                	sd	s0,16(sp)
    80002bb4:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002bb6:	fe840593          	addi	a1,s0,-24
    80002bba:	4501                	li	a0,0
    80002bbc:	00000097          	auipc	ra,0x0
    80002bc0:	ece080e7          	jalr	-306(ra) # 80002a8a <argaddr>
    80002bc4:	87aa                	mv	a5,a0
    return -1;
    80002bc6:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002bc8:	0007c863          	bltz	a5,80002bd8 <sys_wait+0x2a>
  return wait(p);
    80002bcc:	fe843503          	ld	a0,-24(s0)
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	5ce080e7          	jalr	1486(ra) # 8000219e <wait>
}
    80002bd8:	60e2                	ld	ra,24(sp)
    80002bda:	6442                	ld	s0,16(sp)
    80002bdc:	6105                	addi	sp,sp,32
    80002bde:	8082                	ret

0000000080002be0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002be0:	7179                	addi	sp,sp,-48
    80002be2:	f406                	sd	ra,40(sp)
    80002be4:	f022                	sd	s0,32(sp)
    80002be6:	ec26                	sd	s1,24(sp)
    80002be8:	e84a                	sd	s2,16(sp)
    80002bea:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002bec:	fdc40593          	addi	a1,s0,-36
    80002bf0:	4501                	li	a0,0
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	e76080e7          	jalr	-394(ra) # 80002a68 <argint>
    return -1;
    80002bfa:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002bfc:	02054263          	bltz	a0,80002c20 <sys_sbrk+0x40>
  addr = myproc()->sz;
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	d06080e7          	jalr	-762(ra) # 80001906 <myproc>
    80002c08:	4924                	lw	s1,80(a0)
  myproc()->sz+=n;
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	cfc080e7          	jalr	-772(ra) # 80001906 <myproc>
    80002c12:	fdc42703          	lw	a4,-36(s0)
    80002c16:	693c                	ld	a5,80(a0)
    80002c18:	97ba                	add	a5,a5,a4
    80002c1a:	e93c                	sd	a5,80(a0)
  if(n<0) uvmdealloc(myproc()->pagetable,addr,myproc()->sz);
    80002c1c:	00074963          	bltz	a4,80002c2e <sys_sbrk+0x4e>
  //if(growproc(n) < 0)
  //  return -1;
  return addr;
}
    80002c20:	8526                	mv	a0,s1
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6942                	ld	s2,16(sp)
    80002c2a:	6145                	addi	sp,sp,48
    80002c2c:	8082                	ret
  if(n<0) uvmdealloc(myproc()->pagetable,addr,myproc()->sz);
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	cd8080e7          	jalr	-808(ra) # 80001906 <myproc>
    80002c36:	05853903          	ld	s2,88(a0)
    80002c3a:	fffff097          	auipc	ra,0xfffff
    80002c3e:	ccc080e7          	jalr	-820(ra) # 80001906 <myproc>
    80002c42:	6930                	ld	a2,80(a0)
    80002c44:	85a6                	mv	a1,s1
    80002c46:	854a                	mv	a0,s2
    80002c48:	ffffe097          	auipc	ra,0xffffe
    80002c4c:	6ea080e7          	jalr	1770(ra) # 80001332 <uvmdealloc>
  return addr;
    80002c50:	bfc1                	j	80002c20 <sys_sbrk+0x40>

0000000080002c52 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c52:	7139                	addi	sp,sp,-64
    80002c54:	fc06                	sd	ra,56(sp)
    80002c56:	f822                	sd	s0,48(sp)
    80002c58:	f426                	sd	s1,40(sp)
    80002c5a:	f04a                	sd	s2,32(sp)
    80002c5c:	ec4e                	sd	s3,24(sp)
    80002c5e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002c60:	fcc40593          	addi	a1,s0,-52
    80002c64:	4501                	li	a0,0
    80002c66:	00000097          	auipc	ra,0x0
    80002c6a:	e02080e7          	jalr	-510(ra) # 80002a68 <argint>
    return -1;
    80002c6e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c70:	06054563          	bltz	a0,80002cda <sys_sleep+0x88>
  acquire(&tickslock);
    80002c74:	00016517          	auipc	a0,0x16
    80002c78:	c8c50513          	addi	a0,a0,-884 # 80018900 <tickslock>
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	e6e080e7          	jalr	-402(ra) # 80000aea <acquire>
  ticks0 = ticks;
    80002c84:	00026917          	auipc	s2,0x26
    80002c88:	3bc92903          	lw	s2,956(s2) # 80029040 <ticks>
  while(ticks - ticks0 < n){
    80002c8c:	fcc42783          	lw	a5,-52(s0)
    80002c90:	cf85                	beqz	a5,80002cc8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c92:	00016997          	auipc	s3,0x16
    80002c96:	c6e98993          	addi	s3,s3,-914 # 80018900 <tickslock>
    80002c9a:	00026497          	auipc	s1,0x26
    80002c9e:	3a648493          	addi	s1,s1,934 # 80029040 <ticks>
    if(myproc()->killed){
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	c64080e7          	jalr	-924(ra) # 80001906 <myproc>
    80002caa:	591c                	lw	a5,48(a0)
    80002cac:	ef9d                	bnez	a5,80002cea <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002cae:	85ce                	mv	a1,s3
    80002cb0:	8526                	mv	a0,s1
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	46e080e7          	jalr	1134(ra) # 80002120 <sleep>
  while(ticks - ticks0 < n){
    80002cba:	409c                	lw	a5,0(s1)
    80002cbc:	412787bb          	subw	a5,a5,s2
    80002cc0:	fcc42703          	lw	a4,-52(s0)
    80002cc4:	fce7efe3          	bltu	a5,a4,80002ca2 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002cc8:	00016517          	auipc	a0,0x16
    80002ccc:	c3850513          	addi	a0,a0,-968 # 80018900 <tickslock>
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	e82080e7          	jalr	-382(ra) # 80000b52 <release>
  return 0;
    80002cd8:	4781                	li	a5,0
}
    80002cda:	853e                	mv	a0,a5
    80002cdc:	70e2                	ld	ra,56(sp)
    80002cde:	7442                	ld	s0,48(sp)
    80002ce0:	74a2                	ld	s1,40(sp)
    80002ce2:	7902                	ld	s2,32(sp)
    80002ce4:	69e2                	ld	s3,24(sp)
    80002ce6:	6121                	addi	sp,sp,64
    80002ce8:	8082                	ret
      release(&tickslock);
    80002cea:	00016517          	auipc	a0,0x16
    80002cee:	c1650513          	addi	a0,a0,-1002 # 80018900 <tickslock>
    80002cf2:	ffffe097          	auipc	ra,0xffffe
    80002cf6:	e60080e7          	jalr	-416(ra) # 80000b52 <release>
      return -1;
    80002cfa:	57fd                	li	a5,-1
    80002cfc:	bff9                	j	80002cda <sys_sleep+0x88>

0000000080002cfe <sys_kill>:

uint64
sys_kill(void)
{
    80002cfe:	1101                	addi	sp,sp,-32
    80002d00:	ec06                	sd	ra,24(sp)
    80002d02:	e822                	sd	s0,16(sp)
    80002d04:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d06:	fec40593          	addi	a1,s0,-20
    80002d0a:	4501                	li	a0,0
    80002d0c:	00000097          	auipc	ra,0x0
    80002d10:	d5c080e7          	jalr	-676(ra) # 80002a68 <argint>
    80002d14:	87aa                	mv	a5,a0
    return -1;
    80002d16:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d18:	0007c863          	bltz	a5,80002d28 <sys_kill+0x2a>
  return kill(pid);
    80002d1c:	fec42503          	lw	a0,-20(s0)
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	5f0080e7          	jalr	1520(ra) # 80002310 <kill>
}
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret

0000000080002d30 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d30:	1101                	addi	sp,sp,-32
    80002d32:	ec06                	sd	ra,24(sp)
    80002d34:	e822                	sd	s0,16(sp)
    80002d36:	e426                	sd	s1,8(sp)
    80002d38:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d3a:	00016517          	auipc	a0,0x16
    80002d3e:	bc650513          	addi	a0,a0,-1082 # 80018900 <tickslock>
    80002d42:	ffffe097          	auipc	ra,0xffffe
    80002d46:	da8080e7          	jalr	-600(ra) # 80000aea <acquire>
  xticks = ticks;
    80002d4a:	00026497          	auipc	s1,0x26
    80002d4e:	2f64a483          	lw	s1,758(s1) # 80029040 <ticks>
  release(&tickslock);
    80002d52:	00016517          	auipc	a0,0x16
    80002d56:	bae50513          	addi	a0,a0,-1106 # 80018900 <tickslock>
    80002d5a:	ffffe097          	auipc	ra,0xffffe
    80002d5e:	df8080e7          	jalr	-520(ra) # 80000b52 <release>
  return xticks;
}
    80002d62:	02049513          	slli	a0,s1,0x20
    80002d66:	9101                	srli	a0,a0,0x20
    80002d68:	60e2                	ld	ra,24(sp)
    80002d6a:	6442                	ld	s0,16(sp)
    80002d6c:	64a2                	ld	s1,8(sp)
    80002d6e:	6105                	addi	sp,sp,32
    80002d70:	8082                	ret

0000000080002d72 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d72:	7179                	addi	sp,sp,-48
    80002d74:	f406                	sd	ra,40(sp)
    80002d76:	f022                	sd	s0,32(sp)
    80002d78:	ec26                	sd	s1,24(sp)
    80002d7a:	e84a                	sd	s2,16(sp)
    80002d7c:	e44e                	sd	s3,8(sp)
    80002d7e:	e052                	sd	s4,0(sp)
    80002d80:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d82:	00005597          	auipc	a1,0x5
    80002d86:	74e58593          	addi	a1,a1,1870 # 800084d0 <userret+0x440>
    80002d8a:	00016517          	auipc	a0,0x16
    80002d8e:	b8e50513          	addi	a0,a0,-1138 # 80018918 <bcache>
    80002d92:	ffffe097          	auipc	ra,0xffffe
    80002d96:	c46080e7          	jalr	-954(ra) # 800009d8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002d9a:	0001e797          	auipc	a5,0x1e
    80002d9e:	b7e78793          	addi	a5,a5,-1154 # 80020918 <bcache+0x8000>
    80002da2:	0001e717          	auipc	a4,0x1e
    80002da6:	ece70713          	addi	a4,a4,-306 # 80020c70 <bcache+0x8358>
    80002daa:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002dae:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002db2:	00016497          	auipc	s1,0x16
    80002db6:	b7e48493          	addi	s1,s1,-1154 # 80018930 <bcache+0x18>
    b->next = bcache.head.next;
    80002dba:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dbc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dbe:	00005a17          	auipc	s4,0x5
    80002dc2:	71aa0a13          	addi	s4,s4,1818 # 800084d8 <userret+0x448>
    b->next = bcache.head.next;
    80002dc6:	3a893783          	ld	a5,936(s2)
    80002dca:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dcc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dd0:	85d2                	mv	a1,s4
    80002dd2:	01048513          	addi	a0,s1,16
    80002dd6:	00001097          	auipc	ra,0x1
    80002dda:	6f2080e7          	jalr	1778(ra) # 800044c8 <initsleeplock>
    bcache.head.next->prev = b;
    80002dde:	3a893783          	ld	a5,936(s2)
    80002de2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002de4:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002de8:	46048493          	addi	s1,s1,1120
    80002dec:	fd349de3          	bne	s1,s3,80002dc6 <binit+0x54>
  }
}
    80002df0:	70a2                	ld	ra,40(sp)
    80002df2:	7402                	ld	s0,32(sp)
    80002df4:	64e2                	ld	s1,24(sp)
    80002df6:	6942                	ld	s2,16(sp)
    80002df8:	69a2                	ld	s3,8(sp)
    80002dfa:	6a02                	ld	s4,0(sp)
    80002dfc:	6145                	addi	sp,sp,48
    80002dfe:	8082                	ret

0000000080002e00 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e00:	7179                	addi	sp,sp,-48
    80002e02:	f406                	sd	ra,40(sp)
    80002e04:	f022                	sd	s0,32(sp)
    80002e06:	ec26                	sd	s1,24(sp)
    80002e08:	e84a                	sd	s2,16(sp)
    80002e0a:	e44e                	sd	s3,8(sp)
    80002e0c:	1800                	addi	s0,sp,48
    80002e0e:	89aa                	mv	s3,a0
    80002e10:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002e12:	00016517          	auipc	a0,0x16
    80002e16:	b0650513          	addi	a0,a0,-1274 # 80018918 <bcache>
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	cd0080e7          	jalr	-816(ra) # 80000aea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e22:	0001e497          	auipc	s1,0x1e
    80002e26:	e9e4b483          	ld	s1,-354(s1) # 80020cc0 <bcache+0x83a8>
    80002e2a:	0001e797          	auipc	a5,0x1e
    80002e2e:	e4678793          	addi	a5,a5,-442 # 80020c70 <bcache+0x8358>
    80002e32:	02f48f63          	beq	s1,a5,80002e70 <bread+0x70>
    80002e36:	873e                	mv	a4,a5
    80002e38:	a021                	j	80002e40 <bread+0x40>
    80002e3a:	68a4                	ld	s1,80(s1)
    80002e3c:	02e48a63          	beq	s1,a4,80002e70 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e40:	449c                	lw	a5,8(s1)
    80002e42:	ff379ce3          	bne	a5,s3,80002e3a <bread+0x3a>
    80002e46:	44dc                	lw	a5,12(s1)
    80002e48:	ff2799e3          	bne	a5,s2,80002e3a <bread+0x3a>
      b->refcnt++;
    80002e4c:	40bc                	lw	a5,64(s1)
    80002e4e:	2785                	addiw	a5,a5,1
    80002e50:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e52:	00016517          	auipc	a0,0x16
    80002e56:	ac650513          	addi	a0,a0,-1338 # 80018918 <bcache>
    80002e5a:	ffffe097          	auipc	ra,0xffffe
    80002e5e:	cf8080e7          	jalr	-776(ra) # 80000b52 <release>
      acquiresleep(&b->lock);
    80002e62:	01048513          	addi	a0,s1,16
    80002e66:	00001097          	auipc	ra,0x1
    80002e6a:	69c080e7          	jalr	1692(ra) # 80004502 <acquiresleep>
      return b;
    80002e6e:	a8b9                	j	80002ecc <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e70:	0001e497          	auipc	s1,0x1e
    80002e74:	e484b483          	ld	s1,-440(s1) # 80020cb8 <bcache+0x83a0>
    80002e78:	0001e797          	auipc	a5,0x1e
    80002e7c:	df878793          	addi	a5,a5,-520 # 80020c70 <bcache+0x8358>
    80002e80:	00f48863          	beq	s1,a5,80002e90 <bread+0x90>
    80002e84:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e86:	40bc                	lw	a5,64(s1)
    80002e88:	cf81                	beqz	a5,80002ea0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e8a:	64a4                	ld	s1,72(s1)
    80002e8c:	fee49de3          	bne	s1,a4,80002e86 <bread+0x86>
  panic("bget: no buffers");
    80002e90:	00005517          	auipc	a0,0x5
    80002e94:	65050513          	addi	a0,a0,1616 # 800084e0 <userret+0x450>
    80002e98:	ffffd097          	auipc	ra,0xffffd
    80002e9c:	6b6080e7          	jalr	1718(ra) # 8000054e <panic>
      b->dev = dev;
    80002ea0:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002ea4:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002ea8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002eac:	4785                	li	a5,1
    80002eae:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eb0:	00016517          	auipc	a0,0x16
    80002eb4:	a6850513          	addi	a0,a0,-1432 # 80018918 <bcache>
    80002eb8:	ffffe097          	auipc	ra,0xffffe
    80002ebc:	c9a080e7          	jalr	-870(ra) # 80000b52 <release>
      acquiresleep(&b->lock);
    80002ec0:	01048513          	addi	a0,s1,16
    80002ec4:	00001097          	auipc	ra,0x1
    80002ec8:	63e080e7          	jalr	1598(ra) # 80004502 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ecc:	409c                	lw	a5,0(s1)
    80002ece:	cb89                	beqz	a5,80002ee0 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	70a2                	ld	ra,40(sp)
    80002ed4:	7402                	ld	s0,32(sp)
    80002ed6:	64e2                	ld	s1,24(sp)
    80002ed8:	6942                	ld	s2,16(sp)
    80002eda:	69a2                	ld	s3,8(sp)
    80002edc:	6145                	addi	sp,sp,48
    80002ede:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002ee0:	4601                	li	a2,0
    80002ee2:	85a6                	mv	a1,s1
    80002ee4:	4488                	lw	a0,8(s1)
    80002ee6:	00003097          	auipc	ra,0x3
    80002eea:	286080e7          	jalr	646(ra) # 8000616c <virtio_disk_rw>
    b->valid = 1;
    80002eee:	4785                	li	a5,1
    80002ef0:	c09c                	sw	a5,0(s1)
  return b;
    80002ef2:	bff9                	j	80002ed0 <bread+0xd0>

0000000080002ef4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ef4:	1101                	addi	sp,sp,-32
    80002ef6:	ec06                	sd	ra,24(sp)
    80002ef8:	e822                	sd	s0,16(sp)
    80002efa:	e426                	sd	s1,8(sp)
    80002efc:	1000                	addi	s0,sp,32
    80002efe:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f00:	0541                	addi	a0,a0,16
    80002f02:	00001097          	auipc	ra,0x1
    80002f06:	69a080e7          	jalr	1690(ra) # 8000459c <holdingsleep>
    80002f0a:	cd09                	beqz	a0,80002f24 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002f0c:	4605                	li	a2,1
    80002f0e:	85a6                	mv	a1,s1
    80002f10:	4488                	lw	a0,8(s1)
    80002f12:	00003097          	auipc	ra,0x3
    80002f16:	25a080e7          	jalr	602(ra) # 8000616c <virtio_disk_rw>
}
    80002f1a:	60e2                	ld	ra,24(sp)
    80002f1c:	6442                	ld	s0,16(sp)
    80002f1e:	64a2                	ld	s1,8(sp)
    80002f20:	6105                	addi	sp,sp,32
    80002f22:	8082                	ret
    panic("bwrite");
    80002f24:	00005517          	auipc	a0,0x5
    80002f28:	5d450513          	addi	a0,a0,1492 # 800084f8 <userret+0x468>
    80002f2c:	ffffd097          	auipc	ra,0xffffd
    80002f30:	622080e7          	jalr	1570(ra) # 8000054e <panic>

0000000080002f34 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002f34:	1101                	addi	sp,sp,-32
    80002f36:	ec06                	sd	ra,24(sp)
    80002f38:	e822                	sd	s0,16(sp)
    80002f3a:	e426                	sd	s1,8(sp)
    80002f3c:	e04a                	sd	s2,0(sp)
    80002f3e:	1000                	addi	s0,sp,32
    80002f40:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f42:	01050913          	addi	s2,a0,16
    80002f46:	854a                	mv	a0,s2
    80002f48:	00001097          	auipc	ra,0x1
    80002f4c:	654080e7          	jalr	1620(ra) # 8000459c <holdingsleep>
    80002f50:	c92d                	beqz	a0,80002fc2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f52:	854a                	mv	a0,s2
    80002f54:	00001097          	auipc	ra,0x1
    80002f58:	604080e7          	jalr	1540(ra) # 80004558 <releasesleep>

  acquire(&bcache.lock);
    80002f5c:	00016517          	auipc	a0,0x16
    80002f60:	9bc50513          	addi	a0,a0,-1604 # 80018918 <bcache>
    80002f64:	ffffe097          	auipc	ra,0xffffe
    80002f68:	b86080e7          	jalr	-1146(ra) # 80000aea <acquire>
  b->refcnt--;
    80002f6c:	40bc                	lw	a5,64(s1)
    80002f6e:	37fd                	addiw	a5,a5,-1
    80002f70:	0007871b          	sext.w	a4,a5
    80002f74:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f76:	eb05                	bnez	a4,80002fa6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f78:	68bc                	ld	a5,80(s1)
    80002f7a:	64b8                	ld	a4,72(s1)
    80002f7c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002f7e:	64bc                	ld	a5,72(s1)
    80002f80:	68b8                	ld	a4,80(s1)
    80002f82:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f84:	0001e797          	auipc	a5,0x1e
    80002f88:	99478793          	addi	a5,a5,-1644 # 80020918 <bcache+0x8000>
    80002f8c:	3a87b703          	ld	a4,936(a5)
    80002f90:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f92:	0001e717          	auipc	a4,0x1e
    80002f96:	cde70713          	addi	a4,a4,-802 # 80020c70 <bcache+0x8358>
    80002f9a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f9c:	3a87b703          	ld	a4,936(a5)
    80002fa0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fa2:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80002fa6:	00016517          	auipc	a0,0x16
    80002faa:	97250513          	addi	a0,a0,-1678 # 80018918 <bcache>
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	ba4080e7          	jalr	-1116(ra) # 80000b52 <release>
}
    80002fb6:	60e2                	ld	ra,24(sp)
    80002fb8:	6442                	ld	s0,16(sp)
    80002fba:	64a2                	ld	s1,8(sp)
    80002fbc:	6902                	ld	s2,0(sp)
    80002fbe:	6105                	addi	sp,sp,32
    80002fc0:	8082                	ret
    panic("brelse");
    80002fc2:	00005517          	auipc	a0,0x5
    80002fc6:	53e50513          	addi	a0,a0,1342 # 80008500 <userret+0x470>
    80002fca:	ffffd097          	auipc	ra,0xffffd
    80002fce:	584080e7          	jalr	1412(ra) # 8000054e <panic>

0000000080002fd2 <bpin>:

void
bpin(struct buf *b) {
    80002fd2:	1101                	addi	sp,sp,-32
    80002fd4:	ec06                	sd	ra,24(sp)
    80002fd6:	e822                	sd	s0,16(sp)
    80002fd8:	e426                	sd	s1,8(sp)
    80002fda:	1000                	addi	s0,sp,32
    80002fdc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fde:	00016517          	auipc	a0,0x16
    80002fe2:	93a50513          	addi	a0,a0,-1734 # 80018918 <bcache>
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	b04080e7          	jalr	-1276(ra) # 80000aea <acquire>
  b->refcnt++;
    80002fee:	40bc                	lw	a5,64(s1)
    80002ff0:	2785                	addiw	a5,a5,1
    80002ff2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ff4:	00016517          	auipc	a0,0x16
    80002ff8:	92450513          	addi	a0,a0,-1756 # 80018918 <bcache>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	b56080e7          	jalr	-1194(ra) # 80000b52 <release>
}
    80003004:	60e2                	ld	ra,24(sp)
    80003006:	6442                	ld	s0,16(sp)
    80003008:	64a2                	ld	s1,8(sp)
    8000300a:	6105                	addi	sp,sp,32
    8000300c:	8082                	ret

000000008000300e <bunpin>:

void
bunpin(struct buf *b) {
    8000300e:	1101                	addi	sp,sp,-32
    80003010:	ec06                	sd	ra,24(sp)
    80003012:	e822                	sd	s0,16(sp)
    80003014:	e426                	sd	s1,8(sp)
    80003016:	1000                	addi	s0,sp,32
    80003018:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000301a:	00016517          	auipc	a0,0x16
    8000301e:	8fe50513          	addi	a0,a0,-1794 # 80018918 <bcache>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	ac8080e7          	jalr	-1336(ra) # 80000aea <acquire>
  b->refcnt--;
    8000302a:	40bc                	lw	a5,64(s1)
    8000302c:	37fd                	addiw	a5,a5,-1
    8000302e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003030:	00016517          	auipc	a0,0x16
    80003034:	8e850513          	addi	a0,a0,-1816 # 80018918 <bcache>
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	b1a080e7          	jalr	-1254(ra) # 80000b52 <release>
}
    80003040:	60e2                	ld	ra,24(sp)
    80003042:	6442                	ld	s0,16(sp)
    80003044:	64a2                	ld	s1,8(sp)
    80003046:	6105                	addi	sp,sp,32
    80003048:	8082                	ret

000000008000304a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000304a:	1101                	addi	sp,sp,-32
    8000304c:	ec06                	sd	ra,24(sp)
    8000304e:	e822                	sd	s0,16(sp)
    80003050:	e426                	sd	s1,8(sp)
    80003052:	e04a                	sd	s2,0(sp)
    80003054:	1000                	addi	s0,sp,32
    80003056:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003058:	00d5d59b          	srliw	a1,a1,0xd
    8000305c:	0001e797          	auipc	a5,0x1e
    80003060:	0907a783          	lw	a5,144(a5) # 800210ec <sb+0x1c>
    80003064:	9dbd                	addw	a1,a1,a5
    80003066:	00000097          	auipc	ra,0x0
    8000306a:	d9a080e7          	jalr	-614(ra) # 80002e00 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000306e:	0074f713          	andi	a4,s1,7
    80003072:	4785                	li	a5,1
    80003074:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003078:	14ce                	slli	s1,s1,0x33
    8000307a:	90d9                	srli	s1,s1,0x36
    8000307c:	00950733          	add	a4,a0,s1
    80003080:	06074703          	lbu	a4,96(a4)
    80003084:	00e7f6b3          	and	a3,a5,a4
    80003088:	c69d                	beqz	a3,800030b6 <bfree+0x6c>
    8000308a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000308c:	94aa                	add	s1,s1,a0
    8000308e:	fff7c793          	not	a5,a5
    80003092:	8ff9                	and	a5,a5,a4
    80003094:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80003098:	00001097          	auipc	ra,0x1
    8000309c:	1d2080e7          	jalr	466(ra) # 8000426a <log_write>
  brelse(bp);
    800030a0:	854a                	mv	a0,s2
    800030a2:	00000097          	auipc	ra,0x0
    800030a6:	e92080e7          	jalr	-366(ra) # 80002f34 <brelse>
}
    800030aa:	60e2                	ld	ra,24(sp)
    800030ac:	6442                	ld	s0,16(sp)
    800030ae:	64a2                	ld	s1,8(sp)
    800030b0:	6902                	ld	s2,0(sp)
    800030b2:	6105                	addi	sp,sp,32
    800030b4:	8082                	ret
    panic("freeing free block");
    800030b6:	00005517          	auipc	a0,0x5
    800030ba:	45250513          	addi	a0,a0,1106 # 80008508 <userret+0x478>
    800030be:	ffffd097          	auipc	ra,0xffffd
    800030c2:	490080e7          	jalr	1168(ra) # 8000054e <panic>

00000000800030c6 <balloc>:
{
    800030c6:	711d                	addi	sp,sp,-96
    800030c8:	ec86                	sd	ra,88(sp)
    800030ca:	e8a2                	sd	s0,80(sp)
    800030cc:	e4a6                	sd	s1,72(sp)
    800030ce:	e0ca                	sd	s2,64(sp)
    800030d0:	fc4e                	sd	s3,56(sp)
    800030d2:	f852                	sd	s4,48(sp)
    800030d4:	f456                	sd	s5,40(sp)
    800030d6:	f05a                	sd	s6,32(sp)
    800030d8:	ec5e                	sd	s7,24(sp)
    800030da:	e862                	sd	s8,16(sp)
    800030dc:	e466                	sd	s9,8(sp)
    800030de:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030e0:	0001e797          	auipc	a5,0x1e
    800030e4:	ff47a783          	lw	a5,-12(a5) # 800210d4 <sb+0x4>
    800030e8:	cbd1                	beqz	a5,8000317c <balloc+0xb6>
    800030ea:	8baa                	mv	s7,a0
    800030ec:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030ee:	0001eb17          	auipc	s6,0x1e
    800030f2:	fe2b0b13          	addi	s6,s6,-30 # 800210d0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030f6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800030f8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030fa:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030fc:	6c89                	lui	s9,0x2
    800030fe:	a831                	j	8000311a <balloc+0x54>
    brelse(bp);
    80003100:	854a                	mv	a0,s2
    80003102:	00000097          	auipc	ra,0x0
    80003106:	e32080e7          	jalr	-462(ra) # 80002f34 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000310a:	015c87bb          	addw	a5,s9,s5
    8000310e:	00078a9b          	sext.w	s5,a5
    80003112:	004b2703          	lw	a4,4(s6)
    80003116:	06eaf363          	bgeu	s5,a4,8000317c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000311a:	41fad79b          	sraiw	a5,s5,0x1f
    8000311e:	0137d79b          	srliw	a5,a5,0x13
    80003122:	015787bb          	addw	a5,a5,s5
    80003126:	40d7d79b          	sraiw	a5,a5,0xd
    8000312a:	01cb2583          	lw	a1,28(s6)
    8000312e:	9dbd                	addw	a1,a1,a5
    80003130:	855e                	mv	a0,s7
    80003132:	00000097          	auipc	ra,0x0
    80003136:	cce080e7          	jalr	-818(ra) # 80002e00 <bread>
    8000313a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000313c:	004b2503          	lw	a0,4(s6)
    80003140:	000a849b          	sext.w	s1,s5
    80003144:	8662                	mv	a2,s8
    80003146:	faa4fde3          	bgeu	s1,a0,80003100 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000314a:	41f6579b          	sraiw	a5,a2,0x1f
    8000314e:	01d7d69b          	srliw	a3,a5,0x1d
    80003152:	00c6873b          	addw	a4,a3,a2
    80003156:	00777793          	andi	a5,a4,7
    8000315a:	9f95                	subw	a5,a5,a3
    8000315c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003160:	4037571b          	sraiw	a4,a4,0x3
    80003164:	00e906b3          	add	a3,s2,a4
    80003168:	0606c683          	lbu	a3,96(a3)
    8000316c:	00d7f5b3          	and	a1,a5,a3
    80003170:	cd91                	beqz	a1,8000318c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003172:	2605                	addiw	a2,a2,1
    80003174:	2485                	addiw	s1,s1,1
    80003176:	fd4618e3          	bne	a2,s4,80003146 <balloc+0x80>
    8000317a:	b759                	j	80003100 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000317c:	00005517          	auipc	a0,0x5
    80003180:	3a450513          	addi	a0,a0,932 # 80008520 <userret+0x490>
    80003184:	ffffd097          	auipc	ra,0xffffd
    80003188:	3ca080e7          	jalr	970(ra) # 8000054e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000318c:	974a                	add	a4,a4,s2
    8000318e:	8fd5                	or	a5,a5,a3
    80003190:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80003194:	854a                	mv	a0,s2
    80003196:	00001097          	auipc	ra,0x1
    8000319a:	0d4080e7          	jalr	212(ra) # 8000426a <log_write>
        brelse(bp);
    8000319e:	854a                	mv	a0,s2
    800031a0:	00000097          	auipc	ra,0x0
    800031a4:	d94080e7          	jalr	-620(ra) # 80002f34 <brelse>
  bp = bread(dev, bno);
    800031a8:	85a6                	mv	a1,s1
    800031aa:	855e                	mv	a0,s7
    800031ac:	00000097          	auipc	ra,0x0
    800031b0:	c54080e7          	jalr	-940(ra) # 80002e00 <bread>
    800031b4:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800031b6:	40000613          	li	a2,1024
    800031ba:	4581                	li	a1,0
    800031bc:	06050513          	addi	a0,a0,96
    800031c0:	ffffe097          	auipc	ra,0xffffe
    800031c4:	9ee080e7          	jalr	-1554(ra) # 80000bae <memset>
  log_write(bp);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	0a0080e7          	jalr	160(ra) # 8000426a <log_write>
  brelse(bp);
    800031d2:	854a                	mv	a0,s2
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	d60080e7          	jalr	-672(ra) # 80002f34 <brelse>
}
    800031dc:	8526                	mv	a0,s1
    800031de:	60e6                	ld	ra,88(sp)
    800031e0:	6446                	ld	s0,80(sp)
    800031e2:	64a6                	ld	s1,72(sp)
    800031e4:	6906                	ld	s2,64(sp)
    800031e6:	79e2                	ld	s3,56(sp)
    800031e8:	7a42                	ld	s4,48(sp)
    800031ea:	7aa2                	ld	s5,40(sp)
    800031ec:	7b02                	ld	s6,32(sp)
    800031ee:	6be2                	ld	s7,24(sp)
    800031f0:	6c42                	ld	s8,16(sp)
    800031f2:	6ca2                	ld	s9,8(sp)
    800031f4:	6125                	addi	sp,sp,96
    800031f6:	8082                	ret

00000000800031f8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800031f8:	7179                	addi	sp,sp,-48
    800031fa:	f406                	sd	ra,40(sp)
    800031fc:	f022                	sd	s0,32(sp)
    800031fe:	ec26                	sd	s1,24(sp)
    80003200:	e84a                	sd	s2,16(sp)
    80003202:	e44e                	sd	s3,8(sp)
    80003204:	e052                	sd	s4,0(sp)
    80003206:	1800                	addi	s0,sp,48
    80003208:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000320a:	47ad                	li	a5,11
    8000320c:	04b7fe63          	bgeu	a5,a1,80003268 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003210:	ff45849b          	addiw	s1,a1,-12
    80003214:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003218:	0ff00793          	li	a5,255
    8000321c:	0ae7e363          	bltu	a5,a4,800032c2 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003220:	08052583          	lw	a1,128(a0)
    80003224:	c5ad                	beqz	a1,8000328e <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003226:	00092503          	lw	a0,0(s2)
    8000322a:	00000097          	auipc	ra,0x0
    8000322e:	bd6080e7          	jalr	-1066(ra) # 80002e00 <bread>
    80003232:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003234:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003238:	02049593          	slli	a1,s1,0x20
    8000323c:	9181                	srli	a1,a1,0x20
    8000323e:	058a                	slli	a1,a1,0x2
    80003240:	00b784b3          	add	s1,a5,a1
    80003244:	0004a983          	lw	s3,0(s1)
    80003248:	04098d63          	beqz	s3,800032a2 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000324c:	8552                	mv	a0,s4
    8000324e:	00000097          	auipc	ra,0x0
    80003252:	ce6080e7          	jalr	-794(ra) # 80002f34 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003256:	854e                	mv	a0,s3
    80003258:	70a2                	ld	ra,40(sp)
    8000325a:	7402                	ld	s0,32(sp)
    8000325c:	64e2                	ld	s1,24(sp)
    8000325e:	6942                	ld	s2,16(sp)
    80003260:	69a2                	ld	s3,8(sp)
    80003262:	6a02                	ld	s4,0(sp)
    80003264:	6145                	addi	sp,sp,48
    80003266:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003268:	02059493          	slli	s1,a1,0x20
    8000326c:	9081                	srli	s1,s1,0x20
    8000326e:	048a                	slli	s1,s1,0x2
    80003270:	94aa                	add	s1,s1,a0
    80003272:	0504a983          	lw	s3,80(s1)
    80003276:	fe0990e3          	bnez	s3,80003256 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000327a:	4108                	lw	a0,0(a0)
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	e4a080e7          	jalr	-438(ra) # 800030c6 <balloc>
    80003284:	0005099b          	sext.w	s3,a0
    80003288:	0534a823          	sw	s3,80(s1)
    8000328c:	b7e9                	j	80003256 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000328e:	4108                	lw	a0,0(a0)
    80003290:	00000097          	auipc	ra,0x0
    80003294:	e36080e7          	jalr	-458(ra) # 800030c6 <balloc>
    80003298:	0005059b          	sext.w	a1,a0
    8000329c:	08b92023          	sw	a1,128(s2)
    800032a0:	b759                	j	80003226 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800032a2:	00092503          	lw	a0,0(s2)
    800032a6:	00000097          	auipc	ra,0x0
    800032aa:	e20080e7          	jalr	-480(ra) # 800030c6 <balloc>
    800032ae:	0005099b          	sext.w	s3,a0
    800032b2:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800032b6:	8552                	mv	a0,s4
    800032b8:	00001097          	auipc	ra,0x1
    800032bc:	fb2080e7          	jalr	-78(ra) # 8000426a <log_write>
    800032c0:	b771                	j	8000324c <bmap+0x54>
  panic("bmap: out of range");
    800032c2:	00005517          	auipc	a0,0x5
    800032c6:	27650513          	addi	a0,a0,630 # 80008538 <userret+0x4a8>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	284080e7          	jalr	644(ra) # 8000054e <panic>

00000000800032d2 <iget>:
{
    800032d2:	7179                	addi	sp,sp,-48
    800032d4:	f406                	sd	ra,40(sp)
    800032d6:	f022                	sd	s0,32(sp)
    800032d8:	ec26                	sd	s1,24(sp)
    800032da:	e84a                	sd	s2,16(sp)
    800032dc:	e44e                	sd	s3,8(sp)
    800032de:	e052                	sd	s4,0(sp)
    800032e0:	1800                	addi	s0,sp,48
    800032e2:	89aa                	mv	s3,a0
    800032e4:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800032e6:	0001e517          	auipc	a0,0x1e
    800032ea:	e0a50513          	addi	a0,a0,-502 # 800210f0 <icache>
    800032ee:	ffffd097          	auipc	ra,0xffffd
    800032f2:	7fc080e7          	jalr	2044(ra) # 80000aea <acquire>
  empty = 0;
    800032f6:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800032f8:	0001e497          	auipc	s1,0x1e
    800032fc:	e1048493          	addi	s1,s1,-496 # 80021108 <icache+0x18>
    80003300:	00020697          	auipc	a3,0x20
    80003304:	89868693          	addi	a3,a3,-1896 # 80022b98 <log>
    80003308:	a039                	j	80003316 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000330a:	02090b63          	beqz	s2,80003340 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000330e:	08848493          	addi	s1,s1,136
    80003312:	02d48a63          	beq	s1,a3,80003346 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003316:	449c                	lw	a5,8(s1)
    80003318:	fef059e3          	blez	a5,8000330a <iget+0x38>
    8000331c:	4098                	lw	a4,0(s1)
    8000331e:	ff3716e3          	bne	a4,s3,8000330a <iget+0x38>
    80003322:	40d8                	lw	a4,4(s1)
    80003324:	ff4713e3          	bne	a4,s4,8000330a <iget+0x38>
      ip->ref++;
    80003328:	2785                	addiw	a5,a5,1
    8000332a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000332c:	0001e517          	auipc	a0,0x1e
    80003330:	dc450513          	addi	a0,a0,-572 # 800210f0 <icache>
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	81e080e7          	jalr	-2018(ra) # 80000b52 <release>
      return ip;
    8000333c:	8926                	mv	s2,s1
    8000333e:	a03d                	j	8000336c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003340:	f7f9                	bnez	a5,8000330e <iget+0x3c>
    80003342:	8926                	mv	s2,s1
    80003344:	b7e9                	j	8000330e <iget+0x3c>
  if(empty == 0)
    80003346:	02090c63          	beqz	s2,8000337e <iget+0xac>
  ip->dev = dev;
    8000334a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000334e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003352:	4785                	li	a5,1
    80003354:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003358:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000335c:	0001e517          	auipc	a0,0x1e
    80003360:	d9450513          	addi	a0,a0,-620 # 800210f0 <icache>
    80003364:	ffffd097          	auipc	ra,0xffffd
    80003368:	7ee080e7          	jalr	2030(ra) # 80000b52 <release>
}
    8000336c:	854a                	mv	a0,s2
    8000336e:	70a2                	ld	ra,40(sp)
    80003370:	7402                	ld	s0,32(sp)
    80003372:	64e2                	ld	s1,24(sp)
    80003374:	6942                	ld	s2,16(sp)
    80003376:	69a2                	ld	s3,8(sp)
    80003378:	6a02                	ld	s4,0(sp)
    8000337a:	6145                	addi	sp,sp,48
    8000337c:	8082                	ret
    panic("iget: no inodes");
    8000337e:	00005517          	auipc	a0,0x5
    80003382:	1d250513          	addi	a0,a0,466 # 80008550 <userret+0x4c0>
    80003386:	ffffd097          	auipc	ra,0xffffd
    8000338a:	1c8080e7          	jalr	456(ra) # 8000054e <panic>

000000008000338e <fsinit>:
fsinit(int dev) {
    8000338e:	7179                	addi	sp,sp,-48
    80003390:	f406                	sd	ra,40(sp)
    80003392:	f022                	sd	s0,32(sp)
    80003394:	ec26                	sd	s1,24(sp)
    80003396:	e84a                	sd	s2,16(sp)
    80003398:	e44e                	sd	s3,8(sp)
    8000339a:	1800                	addi	s0,sp,48
    8000339c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000339e:	4585                	li	a1,1
    800033a0:	00000097          	auipc	ra,0x0
    800033a4:	a60080e7          	jalr	-1440(ra) # 80002e00 <bread>
    800033a8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033aa:	0001e997          	auipc	s3,0x1e
    800033ae:	d2698993          	addi	s3,s3,-730 # 800210d0 <sb>
    800033b2:	02000613          	li	a2,32
    800033b6:	06050593          	addi	a1,a0,96
    800033ba:	854e                	mv	a0,s3
    800033bc:	ffffe097          	auipc	ra,0xffffe
    800033c0:	852080e7          	jalr	-1966(ra) # 80000c0e <memmove>
  brelse(bp);
    800033c4:	8526                	mv	a0,s1
    800033c6:	00000097          	auipc	ra,0x0
    800033ca:	b6e080e7          	jalr	-1170(ra) # 80002f34 <brelse>
  if(sb.magic != FSMAGIC)
    800033ce:	0009a703          	lw	a4,0(s3)
    800033d2:	102037b7          	lui	a5,0x10203
    800033d6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033da:	02f71263          	bne	a4,a5,800033fe <fsinit+0x70>
  initlog(dev, &sb);
    800033de:	0001e597          	auipc	a1,0x1e
    800033e2:	cf258593          	addi	a1,a1,-782 # 800210d0 <sb>
    800033e6:	854a                	mv	a0,s2
    800033e8:	00001097          	auipc	ra,0x1
    800033ec:	bfc080e7          	jalr	-1028(ra) # 80003fe4 <initlog>
}
    800033f0:	70a2                	ld	ra,40(sp)
    800033f2:	7402                	ld	s0,32(sp)
    800033f4:	64e2                	ld	s1,24(sp)
    800033f6:	6942                	ld	s2,16(sp)
    800033f8:	69a2                	ld	s3,8(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret
    panic("invalid file system");
    800033fe:	00005517          	auipc	a0,0x5
    80003402:	16250513          	addi	a0,a0,354 # 80008560 <userret+0x4d0>
    80003406:	ffffd097          	auipc	ra,0xffffd
    8000340a:	148080e7          	jalr	328(ra) # 8000054e <panic>

000000008000340e <iinit>:
{
    8000340e:	7179                	addi	sp,sp,-48
    80003410:	f406                	sd	ra,40(sp)
    80003412:	f022                	sd	s0,32(sp)
    80003414:	ec26                	sd	s1,24(sp)
    80003416:	e84a                	sd	s2,16(sp)
    80003418:	e44e                	sd	s3,8(sp)
    8000341a:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000341c:	00005597          	auipc	a1,0x5
    80003420:	15c58593          	addi	a1,a1,348 # 80008578 <userret+0x4e8>
    80003424:	0001e517          	auipc	a0,0x1e
    80003428:	ccc50513          	addi	a0,a0,-820 # 800210f0 <icache>
    8000342c:	ffffd097          	auipc	ra,0xffffd
    80003430:	5ac080e7          	jalr	1452(ra) # 800009d8 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003434:	0001e497          	auipc	s1,0x1e
    80003438:	ce448493          	addi	s1,s1,-796 # 80021118 <icache+0x28>
    8000343c:	0001f997          	auipc	s3,0x1f
    80003440:	76c98993          	addi	s3,s3,1900 # 80022ba8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003444:	00005917          	auipc	s2,0x5
    80003448:	13c90913          	addi	s2,s2,316 # 80008580 <userret+0x4f0>
    8000344c:	85ca                	mv	a1,s2
    8000344e:	8526                	mv	a0,s1
    80003450:	00001097          	auipc	ra,0x1
    80003454:	078080e7          	jalr	120(ra) # 800044c8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003458:	08848493          	addi	s1,s1,136
    8000345c:	ff3498e3          	bne	s1,s3,8000344c <iinit+0x3e>
}
    80003460:	70a2                	ld	ra,40(sp)
    80003462:	7402                	ld	s0,32(sp)
    80003464:	64e2                	ld	s1,24(sp)
    80003466:	6942                	ld	s2,16(sp)
    80003468:	69a2                	ld	s3,8(sp)
    8000346a:	6145                	addi	sp,sp,48
    8000346c:	8082                	ret

000000008000346e <ialloc>:
{
    8000346e:	715d                	addi	sp,sp,-80
    80003470:	e486                	sd	ra,72(sp)
    80003472:	e0a2                	sd	s0,64(sp)
    80003474:	fc26                	sd	s1,56(sp)
    80003476:	f84a                	sd	s2,48(sp)
    80003478:	f44e                	sd	s3,40(sp)
    8000347a:	f052                	sd	s4,32(sp)
    8000347c:	ec56                	sd	s5,24(sp)
    8000347e:	e85a                	sd	s6,16(sp)
    80003480:	e45e                	sd	s7,8(sp)
    80003482:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003484:	0001e717          	auipc	a4,0x1e
    80003488:	c5872703          	lw	a4,-936(a4) # 800210dc <sb+0xc>
    8000348c:	4785                	li	a5,1
    8000348e:	04e7fa63          	bgeu	a5,a4,800034e2 <ialloc+0x74>
    80003492:	8aaa                	mv	s5,a0
    80003494:	8bae                	mv	s7,a1
    80003496:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003498:	0001ea17          	auipc	s4,0x1e
    8000349c:	c38a0a13          	addi	s4,s4,-968 # 800210d0 <sb>
    800034a0:	00048b1b          	sext.w	s6,s1
    800034a4:	0044d593          	srli	a1,s1,0x4
    800034a8:	018a2783          	lw	a5,24(s4)
    800034ac:	9dbd                	addw	a1,a1,a5
    800034ae:	8556                	mv	a0,s5
    800034b0:	00000097          	auipc	ra,0x0
    800034b4:	950080e7          	jalr	-1712(ra) # 80002e00 <bread>
    800034b8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034ba:	06050993          	addi	s3,a0,96
    800034be:	00f4f793          	andi	a5,s1,15
    800034c2:	079a                	slli	a5,a5,0x6
    800034c4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034c6:	00099783          	lh	a5,0(s3)
    800034ca:	c785                	beqz	a5,800034f2 <ialloc+0x84>
    brelse(bp);
    800034cc:	00000097          	auipc	ra,0x0
    800034d0:	a68080e7          	jalr	-1432(ra) # 80002f34 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034d4:	0485                	addi	s1,s1,1
    800034d6:	00ca2703          	lw	a4,12(s4)
    800034da:	0004879b          	sext.w	a5,s1
    800034de:	fce7e1e3          	bltu	a5,a4,800034a0 <ialloc+0x32>
  panic("ialloc: no inodes");
    800034e2:	00005517          	auipc	a0,0x5
    800034e6:	0a650513          	addi	a0,a0,166 # 80008588 <userret+0x4f8>
    800034ea:	ffffd097          	auipc	ra,0xffffd
    800034ee:	064080e7          	jalr	100(ra) # 8000054e <panic>
      memset(dip, 0, sizeof(*dip));
    800034f2:	04000613          	li	a2,64
    800034f6:	4581                	li	a1,0
    800034f8:	854e                	mv	a0,s3
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	6b4080e7          	jalr	1716(ra) # 80000bae <memset>
      dip->type = type;
    80003502:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003506:	854a                	mv	a0,s2
    80003508:	00001097          	auipc	ra,0x1
    8000350c:	d62080e7          	jalr	-670(ra) # 8000426a <log_write>
      brelse(bp);
    80003510:	854a                	mv	a0,s2
    80003512:	00000097          	auipc	ra,0x0
    80003516:	a22080e7          	jalr	-1502(ra) # 80002f34 <brelse>
      return iget(dev, inum);
    8000351a:	85da                	mv	a1,s6
    8000351c:	8556                	mv	a0,s5
    8000351e:	00000097          	auipc	ra,0x0
    80003522:	db4080e7          	jalr	-588(ra) # 800032d2 <iget>
}
    80003526:	60a6                	ld	ra,72(sp)
    80003528:	6406                	ld	s0,64(sp)
    8000352a:	74e2                	ld	s1,56(sp)
    8000352c:	7942                	ld	s2,48(sp)
    8000352e:	79a2                	ld	s3,40(sp)
    80003530:	7a02                	ld	s4,32(sp)
    80003532:	6ae2                	ld	s5,24(sp)
    80003534:	6b42                	ld	s6,16(sp)
    80003536:	6ba2                	ld	s7,8(sp)
    80003538:	6161                	addi	sp,sp,80
    8000353a:	8082                	ret

000000008000353c <iupdate>:
{
    8000353c:	1101                	addi	sp,sp,-32
    8000353e:	ec06                	sd	ra,24(sp)
    80003540:	e822                	sd	s0,16(sp)
    80003542:	e426                	sd	s1,8(sp)
    80003544:	e04a                	sd	s2,0(sp)
    80003546:	1000                	addi	s0,sp,32
    80003548:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000354a:	415c                	lw	a5,4(a0)
    8000354c:	0047d79b          	srliw	a5,a5,0x4
    80003550:	0001e597          	auipc	a1,0x1e
    80003554:	b985a583          	lw	a1,-1128(a1) # 800210e8 <sb+0x18>
    80003558:	9dbd                	addw	a1,a1,a5
    8000355a:	4108                	lw	a0,0(a0)
    8000355c:	00000097          	auipc	ra,0x0
    80003560:	8a4080e7          	jalr	-1884(ra) # 80002e00 <bread>
    80003564:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003566:	06050793          	addi	a5,a0,96
    8000356a:	40c8                	lw	a0,4(s1)
    8000356c:	893d                	andi	a0,a0,15
    8000356e:	051a                	slli	a0,a0,0x6
    80003570:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003572:	04449703          	lh	a4,68(s1)
    80003576:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000357a:	04649703          	lh	a4,70(s1)
    8000357e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003582:	04849703          	lh	a4,72(s1)
    80003586:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000358a:	04a49703          	lh	a4,74(s1)
    8000358e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003592:	44f8                	lw	a4,76(s1)
    80003594:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003596:	03400613          	li	a2,52
    8000359a:	05048593          	addi	a1,s1,80
    8000359e:	0531                	addi	a0,a0,12
    800035a0:	ffffd097          	auipc	ra,0xffffd
    800035a4:	66e080e7          	jalr	1646(ra) # 80000c0e <memmove>
  log_write(bp);
    800035a8:	854a                	mv	a0,s2
    800035aa:	00001097          	auipc	ra,0x1
    800035ae:	cc0080e7          	jalr	-832(ra) # 8000426a <log_write>
  brelse(bp);
    800035b2:	854a                	mv	a0,s2
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	980080e7          	jalr	-1664(ra) # 80002f34 <brelse>
}
    800035bc:	60e2                	ld	ra,24(sp)
    800035be:	6442                	ld	s0,16(sp)
    800035c0:	64a2                	ld	s1,8(sp)
    800035c2:	6902                	ld	s2,0(sp)
    800035c4:	6105                	addi	sp,sp,32
    800035c6:	8082                	ret

00000000800035c8 <idup>:
{
    800035c8:	1101                	addi	sp,sp,-32
    800035ca:	ec06                	sd	ra,24(sp)
    800035cc:	e822                	sd	s0,16(sp)
    800035ce:	e426                	sd	s1,8(sp)
    800035d0:	1000                	addi	s0,sp,32
    800035d2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800035d4:	0001e517          	auipc	a0,0x1e
    800035d8:	b1c50513          	addi	a0,a0,-1252 # 800210f0 <icache>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	50e080e7          	jalr	1294(ra) # 80000aea <acquire>
  ip->ref++;
    800035e4:	449c                	lw	a5,8(s1)
    800035e6:	2785                	addiw	a5,a5,1
    800035e8:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800035ea:	0001e517          	auipc	a0,0x1e
    800035ee:	b0650513          	addi	a0,a0,-1274 # 800210f0 <icache>
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	560080e7          	jalr	1376(ra) # 80000b52 <release>
}
    800035fa:	8526                	mv	a0,s1
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret

0000000080003606 <ilock>:
{
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	e426                	sd	s1,8(sp)
    8000360e:	e04a                	sd	s2,0(sp)
    80003610:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003612:	c115                	beqz	a0,80003636 <ilock+0x30>
    80003614:	84aa                	mv	s1,a0
    80003616:	451c                	lw	a5,8(a0)
    80003618:	00f05f63          	blez	a5,80003636 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000361c:	0541                	addi	a0,a0,16
    8000361e:	00001097          	auipc	ra,0x1
    80003622:	ee4080e7          	jalr	-284(ra) # 80004502 <acquiresleep>
  if(ip->valid == 0){
    80003626:	40bc                	lw	a5,64(s1)
    80003628:	cf99                	beqz	a5,80003646 <ilock+0x40>
}
    8000362a:	60e2                	ld	ra,24(sp)
    8000362c:	6442                	ld	s0,16(sp)
    8000362e:	64a2                	ld	s1,8(sp)
    80003630:	6902                	ld	s2,0(sp)
    80003632:	6105                	addi	sp,sp,32
    80003634:	8082                	ret
    panic("ilock");
    80003636:	00005517          	auipc	a0,0x5
    8000363a:	f6a50513          	addi	a0,a0,-150 # 800085a0 <userret+0x510>
    8000363e:	ffffd097          	auipc	ra,0xffffd
    80003642:	f10080e7          	jalr	-240(ra) # 8000054e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003646:	40dc                	lw	a5,4(s1)
    80003648:	0047d79b          	srliw	a5,a5,0x4
    8000364c:	0001e597          	auipc	a1,0x1e
    80003650:	a9c5a583          	lw	a1,-1380(a1) # 800210e8 <sb+0x18>
    80003654:	9dbd                	addw	a1,a1,a5
    80003656:	4088                	lw	a0,0(s1)
    80003658:	fffff097          	auipc	ra,0xfffff
    8000365c:	7a8080e7          	jalr	1960(ra) # 80002e00 <bread>
    80003660:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003662:	06050593          	addi	a1,a0,96
    80003666:	40dc                	lw	a5,4(s1)
    80003668:	8bbd                	andi	a5,a5,15
    8000366a:	079a                	slli	a5,a5,0x6
    8000366c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000366e:	00059783          	lh	a5,0(a1)
    80003672:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003676:	00259783          	lh	a5,2(a1)
    8000367a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000367e:	00459783          	lh	a5,4(a1)
    80003682:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003686:	00659783          	lh	a5,6(a1)
    8000368a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000368e:	459c                	lw	a5,8(a1)
    80003690:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003692:	03400613          	li	a2,52
    80003696:	05b1                	addi	a1,a1,12
    80003698:	05048513          	addi	a0,s1,80
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	572080e7          	jalr	1394(ra) # 80000c0e <memmove>
    brelse(bp);
    800036a4:	854a                	mv	a0,s2
    800036a6:	00000097          	auipc	ra,0x0
    800036aa:	88e080e7          	jalr	-1906(ra) # 80002f34 <brelse>
    ip->valid = 1;
    800036ae:	4785                	li	a5,1
    800036b0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036b2:	04449783          	lh	a5,68(s1)
    800036b6:	fbb5                	bnez	a5,8000362a <ilock+0x24>
      panic("ilock: no type");
    800036b8:	00005517          	auipc	a0,0x5
    800036bc:	ef050513          	addi	a0,a0,-272 # 800085a8 <userret+0x518>
    800036c0:	ffffd097          	auipc	ra,0xffffd
    800036c4:	e8e080e7          	jalr	-370(ra) # 8000054e <panic>

00000000800036c8 <iunlock>:
{
    800036c8:	1101                	addi	sp,sp,-32
    800036ca:	ec06                	sd	ra,24(sp)
    800036cc:	e822                	sd	s0,16(sp)
    800036ce:	e426                	sd	s1,8(sp)
    800036d0:	e04a                	sd	s2,0(sp)
    800036d2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036d4:	c905                	beqz	a0,80003704 <iunlock+0x3c>
    800036d6:	84aa                	mv	s1,a0
    800036d8:	01050913          	addi	s2,a0,16
    800036dc:	854a                	mv	a0,s2
    800036de:	00001097          	auipc	ra,0x1
    800036e2:	ebe080e7          	jalr	-322(ra) # 8000459c <holdingsleep>
    800036e6:	cd19                	beqz	a0,80003704 <iunlock+0x3c>
    800036e8:	449c                	lw	a5,8(s1)
    800036ea:	00f05d63          	blez	a5,80003704 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800036ee:	854a                	mv	a0,s2
    800036f0:	00001097          	auipc	ra,0x1
    800036f4:	e68080e7          	jalr	-408(ra) # 80004558 <releasesleep>
}
    800036f8:	60e2                	ld	ra,24(sp)
    800036fa:	6442                	ld	s0,16(sp)
    800036fc:	64a2                	ld	s1,8(sp)
    800036fe:	6902                	ld	s2,0(sp)
    80003700:	6105                	addi	sp,sp,32
    80003702:	8082                	ret
    panic("iunlock");
    80003704:	00005517          	auipc	a0,0x5
    80003708:	eb450513          	addi	a0,a0,-332 # 800085b8 <userret+0x528>
    8000370c:	ffffd097          	auipc	ra,0xffffd
    80003710:	e42080e7          	jalr	-446(ra) # 8000054e <panic>

0000000080003714 <iput>:
{
    80003714:	7139                	addi	sp,sp,-64
    80003716:	fc06                	sd	ra,56(sp)
    80003718:	f822                	sd	s0,48(sp)
    8000371a:	f426                	sd	s1,40(sp)
    8000371c:	f04a                	sd	s2,32(sp)
    8000371e:	ec4e                	sd	s3,24(sp)
    80003720:	e852                	sd	s4,16(sp)
    80003722:	e456                	sd	s5,8(sp)
    80003724:	0080                	addi	s0,sp,64
    80003726:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003728:	0001e517          	auipc	a0,0x1e
    8000372c:	9c850513          	addi	a0,a0,-1592 # 800210f0 <icache>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	3ba080e7          	jalr	954(ra) # 80000aea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003738:	4498                	lw	a4,8(s1)
    8000373a:	4785                	li	a5,1
    8000373c:	02f70663          	beq	a4,a5,80003768 <iput+0x54>
  ip->ref--;
    80003740:	449c                	lw	a5,8(s1)
    80003742:	37fd                	addiw	a5,a5,-1
    80003744:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003746:	0001e517          	auipc	a0,0x1e
    8000374a:	9aa50513          	addi	a0,a0,-1622 # 800210f0 <icache>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	404080e7          	jalr	1028(ra) # 80000b52 <release>
}
    80003756:	70e2                	ld	ra,56(sp)
    80003758:	7442                	ld	s0,48(sp)
    8000375a:	74a2                	ld	s1,40(sp)
    8000375c:	7902                	ld	s2,32(sp)
    8000375e:	69e2                	ld	s3,24(sp)
    80003760:	6a42                	ld	s4,16(sp)
    80003762:	6aa2                	ld	s5,8(sp)
    80003764:	6121                	addi	sp,sp,64
    80003766:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003768:	40bc                	lw	a5,64(s1)
    8000376a:	dbf9                	beqz	a5,80003740 <iput+0x2c>
    8000376c:	04a49783          	lh	a5,74(s1)
    80003770:	fbe1                	bnez	a5,80003740 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003772:	01048a13          	addi	s4,s1,16
    80003776:	8552                	mv	a0,s4
    80003778:	00001097          	auipc	ra,0x1
    8000377c:	d8a080e7          	jalr	-630(ra) # 80004502 <acquiresleep>
    release(&icache.lock);
    80003780:	0001e517          	auipc	a0,0x1e
    80003784:	97050513          	addi	a0,a0,-1680 # 800210f0 <icache>
    80003788:	ffffd097          	auipc	ra,0xffffd
    8000378c:	3ca080e7          	jalr	970(ra) # 80000b52 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003790:	05048913          	addi	s2,s1,80
    80003794:	08048993          	addi	s3,s1,128
    80003798:	a819                	j	800037ae <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    8000379a:	4088                	lw	a0,0(s1)
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	8ae080e7          	jalr	-1874(ra) # 8000304a <bfree>
      ip->addrs[i] = 0;
    800037a4:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    800037a8:	0911                	addi	s2,s2,4
    800037aa:	01390663          	beq	s2,s3,800037b6 <iput+0xa2>
    if(ip->addrs[i]){
    800037ae:	00092583          	lw	a1,0(s2)
    800037b2:	d9fd                	beqz	a1,800037a8 <iput+0x94>
    800037b4:	b7dd                	j	8000379a <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037b6:	0804a583          	lw	a1,128(s1)
    800037ba:	ed9d                	bnez	a1,800037f8 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037bc:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    800037c0:	8526                	mv	a0,s1
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	d7a080e7          	jalr	-646(ra) # 8000353c <iupdate>
    ip->type = 0;
    800037ca:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800037ce:	8526                	mv	a0,s1
    800037d0:	00000097          	auipc	ra,0x0
    800037d4:	d6c080e7          	jalr	-660(ra) # 8000353c <iupdate>
    ip->valid = 0;
    800037d8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800037dc:	8552                	mv	a0,s4
    800037de:	00001097          	auipc	ra,0x1
    800037e2:	d7a080e7          	jalr	-646(ra) # 80004558 <releasesleep>
    acquire(&icache.lock);
    800037e6:	0001e517          	auipc	a0,0x1e
    800037ea:	90a50513          	addi	a0,a0,-1782 # 800210f0 <icache>
    800037ee:	ffffd097          	auipc	ra,0xffffd
    800037f2:	2fc080e7          	jalr	764(ra) # 80000aea <acquire>
    800037f6:	b7a9                	j	80003740 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037f8:	4088                	lw	a0,0(s1)
    800037fa:	fffff097          	auipc	ra,0xfffff
    800037fe:	606080e7          	jalr	1542(ra) # 80002e00 <bread>
    80003802:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003804:	06050913          	addi	s2,a0,96
    80003808:	46050993          	addi	s3,a0,1120
    8000380c:	a809                	j	8000381e <iput+0x10a>
        bfree(ip->dev, a[j]);
    8000380e:	4088                	lw	a0,0(s1)
    80003810:	00000097          	auipc	ra,0x0
    80003814:	83a080e7          	jalr	-1990(ra) # 8000304a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003818:	0911                	addi	s2,s2,4
    8000381a:	01390663          	beq	s2,s3,80003826 <iput+0x112>
      if(a[j])
    8000381e:	00092583          	lw	a1,0(s2)
    80003822:	d9fd                	beqz	a1,80003818 <iput+0x104>
    80003824:	b7ed                	j	8000380e <iput+0xfa>
    brelse(bp);
    80003826:	8556                	mv	a0,s5
    80003828:	fffff097          	auipc	ra,0xfffff
    8000382c:	70c080e7          	jalr	1804(ra) # 80002f34 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003830:	0804a583          	lw	a1,128(s1)
    80003834:	4088                	lw	a0,0(s1)
    80003836:	00000097          	auipc	ra,0x0
    8000383a:	814080e7          	jalr	-2028(ra) # 8000304a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000383e:	0804a023          	sw	zero,128(s1)
    80003842:	bfad                	j	800037bc <iput+0xa8>

0000000080003844 <iunlockput>:
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	1000                	addi	s0,sp,32
    8000384e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003850:	00000097          	auipc	ra,0x0
    80003854:	e78080e7          	jalr	-392(ra) # 800036c8 <iunlock>
  iput(ip);
    80003858:	8526                	mv	a0,s1
    8000385a:	00000097          	auipc	ra,0x0
    8000385e:	eba080e7          	jalr	-326(ra) # 80003714 <iput>
}
    80003862:	60e2                	ld	ra,24(sp)
    80003864:	6442                	ld	s0,16(sp)
    80003866:	64a2                	ld	s1,8(sp)
    80003868:	6105                	addi	sp,sp,32
    8000386a:	8082                	ret

000000008000386c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000386c:	1141                	addi	sp,sp,-16
    8000386e:	e422                	sd	s0,8(sp)
    80003870:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003872:	411c                	lw	a5,0(a0)
    80003874:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003876:	415c                	lw	a5,4(a0)
    80003878:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000387a:	04451783          	lh	a5,68(a0)
    8000387e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003882:	04a51783          	lh	a5,74(a0)
    80003886:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000388a:	04c56783          	lwu	a5,76(a0)
    8000388e:	e99c                	sd	a5,16(a1)
}
    80003890:	6422                	ld	s0,8(sp)
    80003892:	0141                	addi	sp,sp,16
    80003894:	8082                	ret

0000000080003896 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003896:	457c                	lw	a5,76(a0)
    80003898:	0ed7e563          	bltu	a5,a3,80003982 <readi+0xec>
{
    8000389c:	7159                	addi	sp,sp,-112
    8000389e:	f486                	sd	ra,104(sp)
    800038a0:	f0a2                	sd	s0,96(sp)
    800038a2:	eca6                	sd	s1,88(sp)
    800038a4:	e8ca                	sd	s2,80(sp)
    800038a6:	e4ce                	sd	s3,72(sp)
    800038a8:	e0d2                	sd	s4,64(sp)
    800038aa:	fc56                	sd	s5,56(sp)
    800038ac:	f85a                	sd	s6,48(sp)
    800038ae:	f45e                	sd	s7,40(sp)
    800038b0:	f062                	sd	s8,32(sp)
    800038b2:	ec66                	sd	s9,24(sp)
    800038b4:	e86a                	sd	s10,16(sp)
    800038b6:	e46e                	sd	s11,8(sp)
    800038b8:	1880                	addi	s0,sp,112
    800038ba:	8baa                	mv	s7,a0
    800038bc:	8c2e                	mv	s8,a1
    800038be:	8ab2                	mv	s5,a2
    800038c0:	8936                	mv	s2,a3
    800038c2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800038c4:	9f35                	addw	a4,a4,a3
    800038c6:	0cd76063          	bltu	a4,a3,80003986 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800038ca:	00e7f463          	bgeu	a5,a4,800038d2 <readi+0x3c>
    n = ip->size - off;
    800038ce:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038d2:	080b0763          	beqz	s6,80003960 <readi+0xca>
    800038d6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800038d8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038dc:	5cfd                	li	s9,-1
    800038de:	a82d                	j	80003918 <readi+0x82>
    800038e0:	02099d93          	slli	s11,s3,0x20
    800038e4:	020ddd93          	srli	s11,s11,0x20
    800038e8:	06048613          	addi	a2,s1,96
    800038ec:	86ee                	mv	a3,s11
    800038ee:	963a                	add	a2,a2,a4
    800038f0:	85d6                	mv	a1,s5
    800038f2:	8562                	mv	a0,s8
    800038f4:	fffff097          	auipc	ra,0xfffff
    800038f8:	a8c080e7          	jalr	-1396(ra) # 80002380 <either_copyout>
    800038fc:	05950d63          	beq	a0,s9,80003956 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003900:	8526                	mv	a0,s1
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	632080e7          	jalr	1586(ra) # 80002f34 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000390a:	01498a3b          	addw	s4,s3,s4
    8000390e:	0129893b          	addw	s2,s3,s2
    80003912:	9aee                	add	s5,s5,s11
    80003914:	056a7663          	bgeu	s4,s6,80003960 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003918:	000ba483          	lw	s1,0(s7)
    8000391c:	00a9559b          	srliw	a1,s2,0xa
    80003920:	855e                	mv	a0,s7
    80003922:	00000097          	auipc	ra,0x0
    80003926:	8d6080e7          	jalr	-1834(ra) # 800031f8 <bmap>
    8000392a:	0005059b          	sext.w	a1,a0
    8000392e:	8526                	mv	a0,s1
    80003930:	fffff097          	auipc	ra,0xfffff
    80003934:	4d0080e7          	jalr	1232(ra) # 80002e00 <bread>
    80003938:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000393a:	3ff97713          	andi	a4,s2,1023
    8000393e:	40ed07bb          	subw	a5,s10,a4
    80003942:	414b06bb          	subw	a3,s6,s4
    80003946:	89be                	mv	s3,a5
    80003948:	2781                	sext.w	a5,a5
    8000394a:	0006861b          	sext.w	a2,a3
    8000394e:	f8f679e3          	bgeu	a2,a5,800038e0 <readi+0x4a>
    80003952:	89b6                	mv	s3,a3
    80003954:	b771                	j	800038e0 <readi+0x4a>
      brelse(bp);
    80003956:	8526                	mv	a0,s1
    80003958:	fffff097          	auipc	ra,0xfffff
    8000395c:	5dc080e7          	jalr	1500(ra) # 80002f34 <brelse>
  }
  return n;
    80003960:	000b051b          	sext.w	a0,s6
}
    80003964:	70a6                	ld	ra,104(sp)
    80003966:	7406                	ld	s0,96(sp)
    80003968:	64e6                	ld	s1,88(sp)
    8000396a:	6946                	ld	s2,80(sp)
    8000396c:	69a6                	ld	s3,72(sp)
    8000396e:	6a06                	ld	s4,64(sp)
    80003970:	7ae2                	ld	s5,56(sp)
    80003972:	7b42                	ld	s6,48(sp)
    80003974:	7ba2                	ld	s7,40(sp)
    80003976:	7c02                	ld	s8,32(sp)
    80003978:	6ce2                	ld	s9,24(sp)
    8000397a:	6d42                	ld	s10,16(sp)
    8000397c:	6da2                	ld	s11,8(sp)
    8000397e:	6165                	addi	sp,sp,112
    80003980:	8082                	ret
    return -1;
    80003982:	557d                	li	a0,-1
}
    80003984:	8082                	ret
    return -1;
    80003986:	557d                	li	a0,-1
    80003988:	bff1                	j	80003964 <readi+0xce>

000000008000398a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000398a:	457c                	lw	a5,76(a0)
    8000398c:	10d7e763          	bltu	a5,a3,80003a9a <writei+0x110>
{
    80003990:	7159                	addi	sp,sp,-112
    80003992:	f486                	sd	ra,104(sp)
    80003994:	f0a2                	sd	s0,96(sp)
    80003996:	eca6                	sd	s1,88(sp)
    80003998:	e8ca                	sd	s2,80(sp)
    8000399a:	e4ce                	sd	s3,72(sp)
    8000399c:	e0d2                	sd	s4,64(sp)
    8000399e:	fc56                	sd	s5,56(sp)
    800039a0:	f85a                	sd	s6,48(sp)
    800039a2:	f45e                	sd	s7,40(sp)
    800039a4:	f062                	sd	s8,32(sp)
    800039a6:	ec66                	sd	s9,24(sp)
    800039a8:	e86a                	sd	s10,16(sp)
    800039aa:	e46e                	sd	s11,8(sp)
    800039ac:	1880                	addi	s0,sp,112
    800039ae:	8baa                	mv	s7,a0
    800039b0:	8c2e                	mv	s8,a1
    800039b2:	8ab2                	mv	s5,a2
    800039b4:	8936                	mv	s2,a3
    800039b6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039b8:	00e687bb          	addw	a5,a3,a4
    800039bc:	0ed7e163          	bltu	a5,a3,80003a9e <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800039c0:	00043737          	lui	a4,0x43
    800039c4:	0cf76f63          	bltu	a4,a5,80003aa2 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039c8:	0a0b0063          	beqz	s6,80003a68 <writei+0xde>
    800039cc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ce:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039d2:	5cfd                	li	s9,-1
    800039d4:	a091                	j	80003a18 <writei+0x8e>
    800039d6:	02099d93          	slli	s11,s3,0x20
    800039da:	020ddd93          	srli	s11,s11,0x20
    800039de:	06048513          	addi	a0,s1,96
    800039e2:	86ee                	mv	a3,s11
    800039e4:	8656                	mv	a2,s5
    800039e6:	85e2                	mv	a1,s8
    800039e8:	953a                	add	a0,a0,a4
    800039ea:	fffff097          	auipc	ra,0xfffff
    800039ee:	9ec080e7          	jalr	-1556(ra) # 800023d6 <either_copyin>
    800039f2:	07950263          	beq	a0,s9,80003a56 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039f6:	8526                	mv	a0,s1
    800039f8:	00001097          	auipc	ra,0x1
    800039fc:	872080e7          	jalr	-1934(ra) # 8000426a <log_write>
    brelse(bp);
    80003a00:	8526                	mv	a0,s1
    80003a02:	fffff097          	auipc	ra,0xfffff
    80003a06:	532080e7          	jalr	1330(ra) # 80002f34 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a0a:	01498a3b          	addw	s4,s3,s4
    80003a0e:	0129893b          	addw	s2,s3,s2
    80003a12:	9aee                	add	s5,s5,s11
    80003a14:	056a7663          	bgeu	s4,s6,80003a60 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a18:	000ba483          	lw	s1,0(s7)
    80003a1c:	00a9559b          	srliw	a1,s2,0xa
    80003a20:	855e                	mv	a0,s7
    80003a22:	fffff097          	auipc	ra,0xfffff
    80003a26:	7d6080e7          	jalr	2006(ra) # 800031f8 <bmap>
    80003a2a:	0005059b          	sext.w	a1,a0
    80003a2e:	8526                	mv	a0,s1
    80003a30:	fffff097          	auipc	ra,0xfffff
    80003a34:	3d0080e7          	jalr	976(ra) # 80002e00 <bread>
    80003a38:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3a:	3ff97713          	andi	a4,s2,1023
    80003a3e:	40ed07bb          	subw	a5,s10,a4
    80003a42:	414b06bb          	subw	a3,s6,s4
    80003a46:	89be                	mv	s3,a5
    80003a48:	2781                	sext.w	a5,a5
    80003a4a:	0006861b          	sext.w	a2,a3
    80003a4e:	f8f674e3          	bgeu	a2,a5,800039d6 <writei+0x4c>
    80003a52:	89b6                	mv	s3,a3
    80003a54:	b749                	j	800039d6 <writei+0x4c>
      brelse(bp);
    80003a56:	8526                	mv	a0,s1
    80003a58:	fffff097          	auipc	ra,0xfffff
    80003a5c:	4dc080e7          	jalr	1244(ra) # 80002f34 <brelse>
  }

  if(n > 0 && off > ip->size){
    80003a60:	04cba783          	lw	a5,76(s7)
    80003a64:	0327e363          	bltu	a5,s2,80003a8a <writei+0x100>
    ip->size = off;
    iupdate(ip);
  }
  return n;
    80003a68:	000b051b          	sext.w	a0,s6
}
    80003a6c:	70a6                	ld	ra,104(sp)
    80003a6e:	7406                	ld	s0,96(sp)
    80003a70:	64e6                	ld	s1,88(sp)
    80003a72:	6946                	ld	s2,80(sp)
    80003a74:	69a6                	ld	s3,72(sp)
    80003a76:	6a06                	ld	s4,64(sp)
    80003a78:	7ae2                	ld	s5,56(sp)
    80003a7a:	7b42                	ld	s6,48(sp)
    80003a7c:	7ba2                	ld	s7,40(sp)
    80003a7e:	7c02                	ld	s8,32(sp)
    80003a80:	6ce2                	ld	s9,24(sp)
    80003a82:	6d42                	ld	s10,16(sp)
    80003a84:	6da2                	ld	s11,8(sp)
    80003a86:	6165                	addi	sp,sp,112
    80003a88:	8082                	ret
    ip->size = off;
    80003a8a:	052ba623          	sw	s2,76(s7)
    iupdate(ip);
    80003a8e:	855e                	mv	a0,s7
    80003a90:	00000097          	auipc	ra,0x0
    80003a94:	aac080e7          	jalr	-1364(ra) # 8000353c <iupdate>
    80003a98:	bfc1                	j	80003a68 <writei+0xde>
    return -1;
    80003a9a:	557d                	li	a0,-1
}
    80003a9c:	8082                	ret
    return -1;
    80003a9e:	557d                	li	a0,-1
    80003aa0:	b7f1                	j	80003a6c <writei+0xe2>
    return -1;
    80003aa2:	557d                	li	a0,-1
    80003aa4:	b7e1                	j	80003a6c <writei+0xe2>

0000000080003aa6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003aa6:	1141                	addi	sp,sp,-16
    80003aa8:	e406                	sd	ra,8(sp)
    80003aaa:	e022                	sd	s0,0(sp)
    80003aac:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003aae:	4639                	li	a2,14
    80003ab0:	ffffd097          	auipc	ra,0xffffd
    80003ab4:	1da080e7          	jalr	474(ra) # 80000c8a <strncmp>
}
    80003ab8:	60a2                	ld	ra,8(sp)
    80003aba:	6402                	ld	s0,0(sp)
    80003abc:	0141                	addi	sp,sp,16
    80003abe:	8082                	ret

0000000080003ac0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003ac0:	7139                	addi	sp,sp,-64
    80003ac2:	fc06                	sd	ra,56(sp)
    80003ac4:	f822                	sd	s0,48(sp)
    80003ac6:	f426                	sd	s1,40(sp)
    80003ac8:	f04a                	sd	s2,32(sp)
    80003aca:	ec4e                	sd	s3,24(sp)
    80003acc:	e852                	sd	s4,16(sp)
    80003ace:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ad0:	04451703          	lh	a4,68(a0)
    80003ad4:	4785                	li	a5,1
    80003ad6:	00f71a63          	bne	a4,a5,80003aea <dirlookup+0x2a>
    80003ada:	892a                	mv	s2,a0
    80003adc:	89ae                	mv	s3,a1
    80003ade:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ae0:	457c                	lw	a5,76(a0)
    80003ae2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ae4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ae6:	e79d                	bnez	a5,80003b14 <dirlookup+0x54>
    80003ae8:	a8a5                	j	80003b60 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003aea:	00005517          	auipc	a0,0x5
    80003aee:	ad650513          	addi	a0,a0,-1322 # 800085c0 <userret+0x530>
    80003af2:	ffffd097          	auipc	ra,0xffffd
    80003af6:	a5c080e7          	jalr	-1444(ra) # 8000054e <panic>
      panic("dirlookup read");
    80003afa:	00005517          	auipc	a0,0x5
    80003afe:	ade50513          	addi	a0,a0,-1314 # 800085d8 <userret+0x548>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	a4c080e7          	jalr	-1460(ra) # 8000054e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b0a:	24c1                	addiw	s1,s1,16
    80003b0c:	04c92783          	lw	a5,76(s2)
    80003b10:	04f4f763          	bgeu	s1,a5,80003b5e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b14:	4741                	li	a4,16
    80003b16:	86a6                	mv	a3,s1
    80003b18:	fc040613          	addi	a2,s0,-64
    80003b1c:	4581                	li	a1,0
    80003b1e:	854a                	mv	a0,s2
    80003b20:	00000097          	auipc	ra,0x0
    80003b24:	d76080e7          	jalr	-650(ra) # 80003896 <readi>
    80003b28:	47c1                	li	a5,16
    80003b2a:	fcf518e3          	bne	a0,a5,80003afa <dirlookup+0x3a>
    if(de.inum == 0)
    80003b2e:	fc045783          	lhu	a5,-64(s0)
    80003b32:	dfe1                	beqz	a5,80003b0a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b34:	fc240593          	addi	a1,s0,-62
    80003b38:	854e                	mv	a0,s3
    80003b3a:	00000097          	auipc	ra,0x0
    80003b3e:	f6c080e7          	jalr	-148(ra) # 80003aa6 <namecmp>
    80003b42:	f561                	bnez	a0,80003b0a <dirlookup+0x4a>
      if(poff)
    80003b44:	000a0463          	beqz	s4,80003b4c <dirlookup+0x8c>
        *poff = off;
    80003b48:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b4c:	fc045583          	lhu	a1,-64(s0)
    80003b50:	00092503          	lw	a0,0(s2)
    80003b54:	fffff097          	auipc	ra,0xfffff
    80003b58:	77e080e7          	jalr	1918(ra) # 800032d2 <iget>
    80003b5c:	a011                	j	80003b60 <dirlookup+0xa0>
  return 0;
    80003b5e:	4501                	li	a0,0
}
    80003b60:	70e2                	ld	ra,56(sp)
    80003b62:	7442                	ld	s0,48(sp)
    80003b64:	74a2                	ld	s1,40(sp)
    80003b66:	7902                	ld	s2,32(sp)
    80003b68:	69e2                	ld	s3,24(sp)
    80003b6a:	6a42                	ld	s4,16(sp)
    80003b6c:	6121                	addi	sp,sp,64
    80003b6e:	8082                	ret

0000000080003b70 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b70:	711d                	addi	sp,sp,-96
    80003b72:	ec86                	sd	ra,88(sp)
    80003b74:	e8a2                	sd	s0,80(sp)
    80003b76:	e4a6                	sd	s1,72(sp)
    80003b78:	e0ca                	sd	s2,64(sp)
    80003b7a:	fc4e                	sd	s3,56(sp)
    80003b7c:	f852                	sd	s4,48(sp)
    80003b7e:	f456                	sd	s5,40(sp)
    80003b80:	f05a                	sd	s6,32(sp)
    80003b82:	ec5e                	sd	s7,24(sp)
    80003b84:	e862                	sd	s8,16(sp)
    80003b86:	e466                	sd	s9,8(sp)
    80003b88:	1080                	addi	s0,sp,96
    80003b8a:	84aa                	mv	s1,a0
    80003b8c:	8b2e                	mv	s6,a1
    80003b8e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b90:	00054703          	lbu	a4,0(a0)
    80003b94:	02f00793          	li	a5,47
    80003b98:	02f70363          	beq	a4,a5,80003bbe <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b9c:	ffffe097          	auipc	ra,0xffffe
    80003ba0:	d6a080e7          	jalr	-662(ra) # 80001906 <myproc>
    80003ba4:	15853503          	ld	a0,344(a0)
    80003ba8:	00000097          	auipc	ra,0x0
    80003bac:	a20080e7          	jalr	-1504(ra) # 800035c8 <idup>
    80003bb0:	89aa                	mv	s3,a0
  while(*path == '/')
    80003bb2:	02f00913          	li	s2,47
  len = path - s;
    80003bb6:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003bb8:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bba:	4c05                	li	s8,1
    80003bbc:	a865                	j	80003c74 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003bbe:	4585                	li	a1,1
    80003bc0:	4501                	li	a0,0
    80003bc2:	fffff097          	auipc	ra,0xfffff
    80003bc6:	710080e7          	jalr	1808(ra) # 800032d2 <iget>
    80003bca:	89aa                	mv	s3,a0
    80003bcc:	b7dd                	j	80003bb2 <namex+0x42>
      iunlockput(ip);
    80003bce:	854e                	mv	a0,s3
    80003bd0:	00000097          	auipc	ra,0x0
    80003bd4:	c74080e7          	jalr	-908(ra) # 80003844 <iunlockput>
      return 0;
    80003bd8:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003bda:	854e                	mv	a0,s3
    80003bdc:	60e6                	ld	ra,88(sp)
    80003bde:	6446                	ld	s0,80(sp)
    80003be0:	64a6                	ld	s1,72(sp)
    80003be2:	6906                	ld	s2,64(sp)
    80003be4:	79e2                	ld	s3,56(sp)
    80003be6:	7a42                	ld	s4,48(sp)
    80003be8:	7aa2                	ld	s5,40(sp)
    80003bea:	7b02                	ld	s6,32(sp)
    80003bec:	6be2                	ld	s7,24(sp)
    80003bee:	6c42                	ld	s8,16(sp)
    80003bf0:	6ca2                	ld	s9,8(sp)
    80003bf2:	6125                	addi	sp,sp,96
    80003bf4:	8082                	ret
      iunlock(ip);
    80003bf6:	854e                	mv	a0,s3
    80003bf8:	00000097          	auipc	ra,0x0
    80003bfc:	ad0080e7          	jalr	-1328(ra) # 800036c8 <iunlock>
      return ip;
    80003c00:	bfe9                	j	80003bda <namex+0x6a>
      iunlockput(ip);
    80003c02:	854e                	mv	a0,s3
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	c40080e7          	jalr	-960(ra) # 80003844 <iunlockput>
      return 0;
    80003c0c:	89d2                	mv	s3,s4
    80003c0e:	b7f1                	j	80003bda <namex+0x6a>
  len = path - s;
    80003c10:	40b48633          	sub	a2,s1,a1
    80003c14:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003c18:	094cd463          	bge	s9,s4,80003ca0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c1c:	4639                	li	a2,14
    80003c1e:	8556                	mv	a0,s5
    80003c20:	ffffd097          	auipc	ra,0xffffd
    80003c24:	fee080e7          	jalr	-18(ra) # 80000c0e <memmove>
  while(*path == '/')
    80003c28:	0004c783          	lbu	a5,0(s1)
    80003c2c:	01279763          	bne	a5,s2,80003c3a <namex+0xca>
    path++;
    80003c30:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c32:	0004c783          	lbu	a5,0(s1)
    80003c36:	ff278de3          	beq	a5,s2,80003c30 <namex+0xc0>
    ilock(ip);
    80003c3a:	854e                	mv	a0,s3
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	9ca080e7          	jalr	-1590(ra) # 80003606 <ilock>
    if(ip->type != T_DIR){
    80003c44:	04499783          	lh	a5,68(s3)
    80003c48:	f98793e3          	bne	a5,s8,80003bce <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003c4c:	000b0563          	beqz	s6,80003c56 <namex+0xe6>
    80003c50:	0004c783          	lbu	a5,0(s1)
    80003c54:	d3cd                	beqz	a5,80003bf6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c56:	865e                	mv	a2,s7
    80003c58:	85d6                	mv	a1,s5
    80003c5a:	854e                	mv	a0,s3
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	e64080e7          	jalr	-412(ra) # 80003ac0 <dirlookup>
    80003c64:	8a2a                	mv	s4,a0
    80003c66:	dd51                	beqz	a0,80003c02 <namex+0x92>
    iunlockput(ip);
    80003c68:	854e                	mv	a0,s3
    80003c6a:	00000097          	auipc	ra,0x0
    80003c6e:	bda080e7          	jalr	-1062(ra) # 80003844 <iunlockput>
    ip = next;
    80003c72:	89d2                	mv	s3,s4
  while(*path == '/')
    80003c74:	0004c783          	lbu	a5,0(s1)
    80003c78:	05279763          	bne	a5,s2,80003cc6 <namex+0x156>
    path++;
    80003c7c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c7e:	0004c783          	lbu	a5,0(s1)
    80003c82:	ff278de3          	beq	a5,s2,80003c7c <namex+0x10c>
  if(*path == 0)
    80003c86:	c79d                	beqz	a5,80003cb4 <namex+0x144>
    path++;
    80003c88:	85a6                	mv	a1,s1
  len = path - s;
    80003c8a:	8a5e                	mv	s4,s7
    80003c8c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003c8e:	01278963          	beq	a5,s2,80003ca0 <namex+0x130>
    80003c92:	dfbd                	beqz	a5,80003c10 <namex+0xa0>
    path++;
    80003c94:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003c96:	0004c783          	lbu	a5,0(s1)
    80003c9a:	ff279ce3          	bne	a5,s2,80003c92 <namex+0x122>
    80003c9e:	bf8d                	j	80003c10 <namex+0xa0>
    memmove(name, s, len);
    80003ca0:	2601                	sext.w	a2,a2
    80003ca2:	8556                	mv	a0,s5
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	f6a080e7          	jalr	-150(ra) # 80000c0e <memmove>
    name[len] = 0;
    80003cac:	9a56                	add	s4,s4,s5
    80003cae:	000a0023          	sb	zero,0(s4)
    80003cb2:	bf9d                	j	80003c28 <namex+0xb8>
  if(nameiparent){
    80003cb4:	f20b03e3          	beqz	s6,80003bda <namex+0x6a>
    iput(ip);
    80003cb8:	854e                	mv	a0,s3
    80003cba:	00000097          	auipc	ra,0x0
    80003cbe:	a5a080e7          	jalr	-1446(ra) # 80003714 <iput>
    return 0;
    80003cc2:	4981                	li	s3,0
    80003cc4:	bf19                	j	80003bda <namex+0x6a>
  if(*path == 0)
    80003cc6:	d7fd                	beqz	a5,80003cb4 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003cc8:	0004c783          	lbu	a5,0(s1)
    80003ccc:	85a6                	mv	a1,s1
    80003cce:	b7d1                	j	80003c92 <namex+0x122>

0000000080003cd0 <dirlink>:
{
    80003cd0:	7139                	addi	sp,sp,-64
    80003cd2:	fc06                	sd	ra,56(sp)
    80003cd4:	f822                	sd	s0,48(sp)
    80003cd6:	f426                	sd	s1,40(sp)
    80003cd8:	f04a                	sd	s2,32(sp)
    80003cda:	ec4e                	sd	s3,24(sp)
    80003cdc:	e852                	sd	s4,16(sp)
    80003cde:	0080                	addi	s0,sp,64
    80003ce0:	892a                	mv	s2,a0
    80003ce2:	8a2e                	mv	s4,a1
    80003ce4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ce6:	4601                	li	a2,0
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	dd8080e7          	jalr	-552(ra) # 80003ac0 <dirlookup>
    80003cf0:	e93d                	bnez	a0,80003d66 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf2:	04c92483          	lw	s1,76(s2)
    80003cf6:	c49d                	beqz	s1,80003d24 <dirlink+0x54>
    80003cf8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cfa:	4741                	li	a4,16
    80003cfc:	86a6                	mv	a3,s1
    80003cfe:	fc040613          	addi	a2,s0,-64
    80003d02:	4581                	li	a1,0
    80003d04:	854a                	mv	a0,s2
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	b90080e7          	jalr	-1136(ra) # 80003896 <readi>
    80003d0e:	47c1                	li	a5,16
    80003d10:	06f51163          	bne	a0,a5,80003d72 <dirlink+0xa2>
    if(de.inum == 0)
    80003d14:	fc045783          	lhu	a5,-64(s0)
    80003d18:	c791                	beqz	a5,80003d24 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d1a:	24c1                	addiw	s1,s1,16
    80003d1c:	04c92783          	lw	a5,76(s2)
    80003d20:	fcf4ede3          	bltu	s1,a5,80003cfa <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d24:	4639                	li	a2,14
    80003d26:	85d2                	mv	a1,s4
    80003d28:	fc240513          	addi	a0,s0,-62
    80003d2c:	ffffd097          	auipc	ra,0xffffd
    80003d30:	f9a080e7          	jalr	-102(ra) # 80000cc6 <strncpy>
  de.inum = inum;
    80003d34:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d38:	4741                	li	a4,16
    80003d3a:	86a6                	mv	a3,s1
    80003d3c:	fc040613          	addi	a2,s0,-64
    80003d40:	4581                	li	a1,0
    80003d42:	854a                	mv	a0,s2
    80003d44:	00000097          	auipc	ra,0x0
    80003d48:	c46080e7          	jalr	-954(ra) # 8000398a <writei>
    80003d4c:	872a                	mv	a4,a0
    80003d4e:	47c1                	li	a5,16
  return 0;
    80003d50:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d52:	02f71863          	bne	a4,a5,80003d82 <dirlink+0xb2>
}
    80003d56:	70e2                	ld	ra,56(sp)
    80003d58:	7442                	ld	s0,48(sp)
    80003d5a:	74a2                	ld	s1,40(sp)
    80003d5c:	7902                	ld	s2,32(sp)
    80003d5e:	69e2                	ld	s3,24(sp)
    80003d60:	6a42                	ld	s4,16(sp)
    80003d62:	6121                	addi	sp,sp,64
    80003d64:	8082                	ret
    iput(ip);
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	9ae080e7          	jalr	-1618(ra) # 80003714 <iput>
    return -1;
    80003d6e:	557d                	li	a0,-1
    80003d70:	b7dd                	j	80003d56 <dirlink+0x86>
      panic("dirlink read");
    80003d72:	00005517          	auipc	a0,0x5
    80003d76:	87650513          	addi	a0,a0,-1930 # 800085e8 <userret+0x558>
    80003d7a:	ffffc097          	auipc	ra,0xffffc
    80003d7e:	7d4080e7          	jalr	2004(ra) # 8000054e <panic>
    panic("dirlink");
    80003d82:	00005517          	auipc	a0,0x5
    80003d86:	a1650513          	addi	a0,a0,-1514 # 80008798 <userret+0x708>
    80003d8a:	ffffc097          	auipc	ra,0xffffc
    80003d8e:	7c4080e7          	jalr	1988(ra) # 8000054e <panic>

0000000080003d92 <namei>:

struct inode*
namei(char *path)
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d9a:	fe040613          	addi	a2,s0,-32
    80003d9e:	4581                	li	a1,0
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	dd0080e7          	jalr	-560(ra) # 80003b70 <namex>
}
    80003da8:	60e2                	ld	ra,24(sp)
    80003daa:	6442                	ld	s0,16(sp)
    80003dac:	6105                	addi	sp,sp,32
    80003dae:	8082                	ret

0000000080003db0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003db0:	1141                	addi	sp,sp,-16
    80003db2:	e406                	sd	ra,8(sp)
    80003db4:	e022                	sd	s0,0(sp)
    80003db6:	0800                	addi	s0,sp,16
    80003db8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dba:	4585                	li	a1,1
    80003dbc:	00000097          	auipc	ra,0x0
    80003dc0:	db4080e7          	jalr	-588(ra) # 80003b70 <namex>
}
    80003dc4:	60a2                	ld	ra,8(sp)
    80003dc6:	6402                	ld	s0,0(sp)
    80003dc8:	0141                	addi	sp,sp,16
    80003dca:	8082                	ret

0000000080003dcc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003dcc:	7179                	addi	sp,sp,-48
    80003dce:	f406                	sd	ra,40(sp)
    80003dd0:	f022                	sd	s0,32(sp)
    80003dd2:	ec26                	sd	s1,24(sp)
    80003dd4:	e84a                	sd	s2,16(sp)
    80003dd6:	e44e                	sd	s3,8(sp)
    80003dd8:	1800                	addi	s0,sp,48
    80003dda:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003ddc:	0a800993          	li	s3,168
    80003de0:	033507b3          	mul	a5,a0,s3
    80003de4:	0001f997          	auipc	s3,0x1f
    80003de8:	db498993          	addi	s3,s3,-588 # 80022b98 <log>
    80003dec:	99be                	add	s3,s3,a5
    80003dee:	0189a583          	lw	a1,24(s3)
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	00e080e7          	jalr	14(ra) # 80002e00 <bread>
    80003dfa:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003dfc:	02c9a783          	lw	a5,44(s3)
    80003e00:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e02:	02c9a783          	lw	a5,44(s3)
    80003e06:	02f05763          	blez	a5,80003e34 <write_head+0x68>
    80003e0a:	0a800793          	li	a5,168
    80003e0e:	02f487b3          	mul	a5,s1,a5
    80003e12:	0001f717          	auipc	a4,0x1f
    80003e16:	db670713          	addi	a4,a4,-586 # 80022bc8 <log+0x30>
    80003e1a:	97ba                	add	a5,a5,a4
    80003e1c:	06450693          	addi	a3,a0,100
    80003e20:	4701                	li	a4,0
    80003e22:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003e24:	4390                	lw	a2,0(a5)
    80003e26:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e28:	2705                	addiw	a4,a4,1
    80003e2a:	0791                	addi	a5,a5,4
    80003e2c:	0691                	addi	a3,a3,4
    80003e2e:	55d0                	lw	a2,44(a1)
    80003e30:	fec74ae3          	blt	a4,a2,80003e24 <write_head+0x58>
  }
  bwrite(buf);
    80003e34:	854a                	mv	a0,s2
    80003e36:	fffff097          	auipc	ra,0xfffff
    80003e3a:	0be080e7          	jalr	190(ra) # 80002ef4 <bwrite>
  brelse(buf);
    80003e3e:	854a                	mv	a0,s2
    80003e40:	fffff097          	auipc	ra,0xfffff
    80003e44:	0f4080e7          	jalr	244(ra) # 80002f34 <brelse>
}
    80003e48:	70a2                	ld	ra,40(sp)
    80003e4a:	7402                	ld	s0,32(sp)
    80003e4c:	64e2                	ld	s1,24(sp)
    80003e4e:	6942                	ld	s2,16(sp)
    80003e50:	69a2                	ld	s3,8(sp)
    80003e52:	6145                	addi	sp,sp,48
    80003e54:	8082                	ret

0000000080003e56 <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003e56:	0a800793          	li	a5,168
    80003e5a:	02f50733          	mul	a4,a0,a5
    80003e5e:	0001f797          	auipc	a5,0x1f
    80003e62:	d3a78793          	addi	a5,a5,-710 # 80022b98 <log>
    80003e66:	97ba                	add	a5,a5,a4
    80003e68:	57dc                	lw	a5,44(a5)
    80003e6a:	0af05663          	blez	a5,80003f16 <write_log+0xc0>
{
    80003e6e:	7139                	addi	sp,sp,-64
    80003e70:	fc06                	sd	ra,56(sp)
    80003e72:	f822                	sd	s0,48(sp)
    80003e74:	f426                	sd	s1,40(sp)
    80003e76:	f04a                	sd	s2,32(sp)
    80003e78:	ec4e                	sd	s3,24(sp)
    80003e7a:	e852                	sd	s4,16(sp)
    80003e7c:	e456                	sd	s5,8(sp)
    80003e7e:	e05a                	sd	s6,0(sp)
    80003e80:	0080                	addi	s0,sp,64
    80003e82:	0001f797          	auipc	a5,0x1f
    80003e86:	d4678793          	addi	a5,a5,-698 # 80022bc8 <log+0x30>
    80003e8a:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003e8e:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003e90:	00050b1b          	sext.w	s6,a0
    80003e94:	0001fa97          	auipc	s5,0x1f
    80003e98:	d04a8a93          	addi	s5,s5,-764 # 80022b98 <log>
    80003e9c:	9aba                	add	s5,s5,a4
    80003e9e:	018aa583          	lw	a1,24(s5)
    80003ea2:	013585bb          	addw	a1,a1,s3
    80003ea6:	2585                	addiw	a1,a1,1
    80003ea8:	855a                	mv	a0,s6
    80003eaa:	fffff097          	auipc	ra,0xfffff
    80003eae:	f56080e7          	jalr	-170(ra) # 80002e00 <bread>
    80003eb2:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003eb4:	000a2583          	lw	a1,0(s4)
    80003eb8:	855a                	mv	a0,s6
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	f46080e7          	jalr	-186(ra) # 80002e00 <bread>
    80003ec2:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003ec4:	40000613          	li	a2,1024
    80003ec8:	06050593          	addi	a1,a0,96
    80003ecc:	06048513          	addi	a0,s1,96
    80003ed0:	ffffd097          	auipc	ra,0xffffd
    80003ed4:	d3e080e7          	jalr	-706(ra) # 80000c0e <memmove>
    bwrite(to);  // write the log
    80003ed8:	8526                	mv	a0,s1
    80003eda:	fffff097          	auipc	ra,0xfffff
    80003ede:	01a080e7          	jalr	26(ra) # 80002ef4 <bwrite>
    brelse(from);
    80003ee2:	854a                	mv	a0,s2
    80003ee4:	fffff097          	auipc	ra,0xfffff
    80003ee8:	050080e7          	jalr	80(ra) # 80002f34 <brelse>
    brelse(to);
    80003eec:	8526                	mv	a0,s1
    80003eee:	fffff097          	auipc	ra,0xfffff
    80003ef2:	046080e7          	jalr	70(ra) # 80002f34 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003ef6:	2985                	addiw	s3,s3,1
    80003ef8:	0a11                	addi	s4,s4,4
    80003efa:	02caa783          	lw	a5,44(s5)
    80003efe:	faf9c0e3          	blt	s3,a5,80003e9e <write_log+0x48>
  }
}
    80003f02:	70e2                	ld	ra,56(sp)
    80003f04:	7442                	ld	s0,48(sp)
    80003f06:	74a2                	ld	s1,40(sp)
    80003f08:	7902                	ld	s2,32(sp)
    80003f0a:	69e2                	ld	s3,24(sp)
    80003f0c:	6a42                	ld	s4,16(sp)
    80003f0e:	6aa2                	ld	s5,8(sp)
    80003f10:	6b02                	ld	s6,0(sp)
    80003f12:	6121                	addi	sp,sp,64
    80003f14:	8082                	ret
    80003f16:	8082                	ret

0000000080003f18 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f18:	0a800793          	li	a5,168
    80003f1c:	02f50733          	mul	a4,a0,a5
    80003f20:	0001f797          	auipc	a5,0x1f
    80003f24:	c7878793          	addi	a5,a5,-904 # 80022b98 <log>
    80003f28:	97ba                	add	a5,a5,a4
    80003f2a:	57dc                	lw	a5,44(a5)
    80003f2c:	0af05b63          	blez	a5,80003fe2 <install_trans+0xca>
{
    80003f30:	7139                	addi	sp,sp,-64
    80003f32:	fc06                	sd	ra,56(sp)
    80003f34:	f822                	sd	s0,48(sp)
    80003f36:	f426                	sd	s1,40(sp)
    80003f38:	f04a                	sd	s2,32(sp)
    80003f3a:	ec4e                	sd	s3,24(sp)
    80003f3c:	e852                	sd	s4,16(sp)
    80003f3e:	e456                	sd	s5,8(sp)
    80003f40:	e05a                	sd	s6,0(sp)
    80003f42:	0080                	addi	s0,sp,64
    80003f44:	0001f797          	auipc	a5,0x1f
    80003f48:	c8478793          	addi	a5,a5,-892 # 80022bc8 <log+0x30>
    80003f4c:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003f50:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003f52:	00050b1b          	sext.w	s6,a0
    80003f56:	0001fa97          	auipc	s5,0x1f
    80003f5a:	c42a8a93          	addi	s5,s5,-958 # 80022b98 <log>
    80003f5e:	9aba                	add	s5,s5,a4
    80003f60:	018aa583          	lw	a1,24(s5)
    80003f64:	013585bb          	addw	a1,a1,s3
    80003f68:	2585                	addiw	a1,a1,1
    80003f6a:	855a                	mv	a0,s6
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	e94080e7          	jalr	-364(ra) # 80002e00 <bread>
    80003f74:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003f76:	000a2583          	lw	a1,0(s4)
    80003f7a:	855a                	mv	a0,s6
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	e84080e7          	jalr	-380(ra) # 80002e00 <bread>
    80003f84:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f86:	40000613          	li	a2,1024
    80003f8a:	06090593          	addi	a1,s2,96
    80003f8e:	06050513          	addi	a0,a0,96
    80003f92:	ffffd097          	auipc	ra,0xffffd
    80003f96:	c7c080e7          	jalr	-900(ra) # 80000c0e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f9a:	8526                	mv	a0,s1
    80003f9c:	fffff097          	auipc	ra,0xfffff
    80003fa0:	f58080e7          	jalr	-168(ra) # 80002ef4 <bwrite>
    bunpin(dbuf);
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	fffff097          	auipc	ra,0xfffff
    80003faa:	068080e7          	jalr	104(ra) # 8000300e <bunpin>
    brelse(lbuf);
    80003fae:	854a                	mv	a0,s2
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	f84080e7          	jalr	-124(ra) # 80002f34 <brelse>
    brelse(dbuf);
    80003fb8:	8526                	mv	a0,s1
    80003fba:	fffff097          	auipc	ra,0xfffff
    80003fbe:	f7a080e7          	jalr	-134(ra) # 80002f34 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003fc2:	2985                	addiw	s3,s3,1
    80003fc4:	0a11                	addi	s4,s4,4
    80003fc6:	02caa783          	lw	a5,44(s5)
    80003fca:	f8f9cbe3          	blt	s3,a5,80003f60 <install_trans+0x48>
}
    80003fce:	70e2                	ld	ra,56(sp)
    80003fd0:	7442                	ld	s0,48(sp)
    80003fd2:	74a2                	ld	s1,40(sp)
    80003fd4:	7902                	ld	s2,32(sp)
    80003fd6:	69e2                	ld	s3,24(sp)
    80003fd8:	6a42                	ld	s4,16(sp)
    80003fda:	6aa2                	ld	s5,8(sp)
    80003fdc:	6b02                	ld	s6,0(sp)
    80003fde:	6121                	addi	sp,sp,64
    80003fe0:	8082                	ret
    80003fe2:	8082                	ret

0000000080003fe4 <initlog>:
{
    80003fe4:	7179                	addi	sp,sp,-48
    80003fe6:	f406                	sd	ra,40(sp)
    80003fe8:	f022                	sd	s0,32(sp)
    80003fea:	ec26                	sd	s1,24(sp)
    80003fec:	e84a                	sd	s2,16(sp)
    80003fee:	e44e                	sd	s3,8(sp)
    80003ff0:	e052                	sd	s4,0(sp)
    80003ff2:	1800                	addi	s0,sp,48
    80003ff4:	84aa                	mv	s1,a0
    80003ff6:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80003ff8:	0a800713          	li	a4,168
    80003ffc:	02e509b3          	mul	s3,a0,a4
    80004000:	0001f917          	auipc	s2,0x1f
    80004004:	b9890913          	addi	s2,s2,-1128 # 80022b98 <log>
    80004008:	994e                	add	s2,s2,s3
    8000400a:	00004597          	auipc	a1,0x4
    8000400e:	5ee58593          	addi	a1,a1,1518 # 800085f8 <userret+0x568>
    80004012:	854a                	mv	a0,s2
    80004014:	ffffd097          	auipc	ra,0xffffd
    80004018:	9c4080e7          	jalr	-1596(ra) # 800009d8 <initlock>
  log[dev].start = sb->logstart;
    8000401c:	014a2583          	lw	a1,20(s4)
    80004020:	00b92c23          	sw	a1,24(s2)
  log[dev].size = sb->nlog;
    80004024:	010a2783          	lw	a5,16(s4)
    80004028:	00f92e23          	sw	a5,28(s2)
  log[dev].dev = dev;
    8000402c:	02992423          	sw	s1,40(s2)
  struct buf *buf = bread(dev, log[dev].start);
    80004030:	8526                	mv	a0,s1
    80004032:	fffff097          	auipc	ra,0xfffff
    80004036:	dce080e7          	jalr	-562(ra) # 80002e00 <bread>
  log[dev].lh.n = lh->n;
    8000403a:	513c                	lw	a5,96(a0)
    8000403c:	02f92623          	sw	a5,44(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004040:	02f05663          	blez	a5,8000406c <initlog+0x88>
    80004044:	06450693          	addi	a3,a0,100
    80004048:	0001f717          	auipc	a4,0x1f
    8000404c:	b8070713          	addi	a4,a4,-1152 # 80022bc8 <log+0x30>
    80004050:	974e                	add	a4,a4,s3
    80004052:	37fd                	addiw	a5,a5,-1
    80004054:	1782                	slli	a5,a5,0x20
    80004056:	9381                	srli	a5,a5,0x20
    80004058:	078a                	slli	a5,a5,0x2
    8000405a:	06850613          	addi	a2,a0,104
    8000405e:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    80004060:	4290                	lw	a2,0(a3)
    80004062:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004064:	0691                	addi	a3,a3,4
    80004066:	0711                	addi	a4,a4,4
    80004068:	fef69ce3          	bne	a3,a5,80004060 <initlog+0x7c>
  brelse(buf);
    8000406c:	fffff097          	auipc	ra,0xfffff
    80004070:	ec8080e7          	jalr	-312(ra) # 80002f34 <brelse>
  install_trans(dev); // if committed, copy from log to disk
    80004074:	8526                	mv	a0,s1
    80004076:	00000097          	auipc	ra,0x0
    8000407a:	ea2080e7          	jalr	-350(ra) # 80003f18 <install_trans>
  log[dev].lh.n = 0;
    8000407e:	0a800793          	li	a5,168
    80004082:	02f48733          	mul	a4,s1,a5
    80004086:	0001f797          	auipc	a5,0x1f
    8000408a:	b1278793          	addi	a5,a5,-1262 # 80022b98 <log>
    8000408e:	97ba                	add	a5,a5,a4
    80004090:	0207a623          	sw	zero,44(a5)
  write_head(dev); // clear the log
    80004094:	8526                	mv	a0,s1
    80004096:	00000097          	auipc	ra,0x0
    8000409a:	d36080e7          	jalr	-714(ra) # 80003dcc <write_head>
}
    8000409e:	70a2                	ld	ra,40(sp)
    800040a0:	7402                	ld	s0,32(sp)
    800040a2:	64e2                	ld	s1,24(sp)
    800040a4:	6942                	ld	s2,16(sp)
    800040a6:	69a2                	ld	s3,8(sp)
    800040a8:	6a02                	ld	s4,0(sp)
    800040aa:	6145                	addi	sp,sp,48
    800040ac:	8082                	ret

00000000800040ae <begin_op>:
{
    800040ae:	7139                	addi	sp,sp,-64
    800040b0:	fc06                	sd	ra,56(sp)
    800040b2:	f822                	sd	s0,48(sp)
    800040b4:	f426                	sd	s1,40(sp)
    800040b6:	f04a                	sd	s2,32(sp)
    800040b8:	ec4e                	sd	s3,24(sp)
    800040ba:	e852                	sd	s4,16(sp)
    800040bc:	e456                	sd	s5,8(sp)
    800040be:	0080                	addi	s0,sp,64
    800040c0:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    800040c2:	0a800913          	li	s2,168
    800040c6:	032507b3          	mul	a5,a0,s2
    800040ca:	0001f917          	auipc	s2,0x1f
    800040ce:	ace90913          	addi	s2,s2,-1330 # 80022b98 <log>
    800040d2:	993e                	add	s2,s2,a5
    800040d4:	854a                	mv	a0,s2
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	a14080e7          	jalr	-1516(ra) # 80000aea <acquire>
    if(log[dev].committing){
    800040de:	0001f997          	auipc	s3,0x1f
    800040e2:	aba98993          	addi	s3,s3,-1350 # 80022b98 <log>
    800040e6:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040e8:	4a79                	li	s4,30
    800040ea:	a039                	j	800040f8 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    800040ec:	85ca                	mv	a1,s2
    800040ee:	854e                	mv	a0,s3
    800040f0:	ffffe097          	auipc	ra,0xffffe
    800040f4:	030080e7          	jalr	48(ra) # 80002120 <sleep>
    if(log[dev].committing){
    800040f8:	50dc                	lw	a5,36(s1)
    800040fa:	fbed                	bnez	a5,800040ec <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040fc:	509c                	lw	a5,32(s1)
    800040fe:	0017871b          	addiw	a4,a5,1
    80004102:	0007069b          	sext.w	a3,a4
    80004106:	0027179b          	slliw	a5,a4,0x2
    8000410a:	9fb9                	addw	a5,a5,a4
    8000410c:	0017979b          	slliw	a5,a5,0x1
    80004110:	54d8                	lw	a4,44(s1)
    80004112:	9fb9                	addw	a5,a5,a4
    80004114:	00fa5963          	bge	s4,a5,80004126 <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    80004118:	85ca                	mv	a1,s2
    8000411a:	854e                	mv	a0,s3
    8000411c:	ffffe097          	auipc	ra,0xffffe
    80004120:	004080e7          	jalr	4(ra) # 80002120 <sleep>
    80004124:	bfd1                	j	800040f8 <begin_op+0x4a>
      log[dev].outstanding += 1;
    80004126:	0a800513          	li	a0,168
    8000412a:	02aa8ab3          	mul	s5,s5,a0
    8000412e:	0001f797          	auipc	a5,0x1f
    80004132:	a6a78793          	addi	a5,a5,-1430 # 80022b98 <log>
    80004136:	9abe                	add	s5,s5,a5
    80004138:	02daa023          	sw	a3,32(s5)
      release(&log[dev].lock);
    8000413c:	854a                	mv	a0,s2
    8000413e:	ffffd097          	auipc	ra,0xffffd
    80004142:	a14080e7          	jalr	-1516(ra) # 80000b52 <release>
}
    80004146:	70e2                	ld	ra,56(sp)
    80004148:	7442                	ld	s0,48(sp)
    8000414a:	74a2                	ld	s1,40(sp)
    8000414c:	7902                	ld	s2,32(sp)
    8000414e:	69e2                	ld	s3,24(sp)
    80004150:	6a42                	ld	s4,16(sp)
    80004152:	6aa2                	ld	s5,8(sp)
    80004154:	6121                	addi	sp,sp,64
    80004156:	8082                	ret

0000000080004158 <end_op>:
{
    80004158:	7179                	addi	sp,sp,-48
    8000415a:	f406                	sd	ra,40(sp)
    8000415c:	f022                	sd	s0,32(sp)
    8000415e:	ec26                	sd	s1,24(sp)
    80004160:	e84a                	sd	s2,16(sp)
    80004162:	e44e                	sd	s3,8(sp)
    80004164:	1800                	addi	s0,sp,48
    80004166:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    80004168:	0a800493          	li	s1,168
    8000416c:	029507b3          	mul	a5,a0,s1
    80004170:	0001f497          	auipc	s1,0x1f
    80004174:	a2848493          	addi	s1,s1,-1496 # 80022b98 <log>
    80004178:	94be                	add	s1,s1,a5
    8000417a:	8526                	mv	a0,s1
    8000417c:	ffffd097          	auipc	ra,0xffffd
    80004180:	96e080e7          	jalr	-1682(ra) # 80000aea <acquire>
  log[dev].outstanding -= 1;
    80004184:	509c                	lw	a5,32(s1)
    80004186:	37fd                	addiw	a5,a5,-1
    80004188:	0007871b          	sext.w	a4,a5
    8000418c:	d09c                	sw	a5,32(s1)
  if(log[dev].committing)
    8000418e:	50dc                	lw	a5,36(s1)
    80004190:	e3ad                	bnez	a5,800041f2 <end_op+0x9a>
  if(log[dev].outstanding == 0){
    80004192:	eb25                	bnez	a4,80004202 <end_op+0xaa>
    log[dev].committing = 1;
    80004194:	0a800993          	li	s3,168
    80004198:	033907b3          	mul	a5,s2,s3
    8000419c:	0001f997          	auipc	s3,0x1f
    800041a0:	9fc98993          	addi	s3,s3,-1540 # 80022b98 <log>
    800041a4:	99be                	add	s3,s3,a5
    800041a6:	4785                	li	a5,1
    800041a8:	02f9a223          	sw	a5,36(s3)
  release(&log[dev].lock);
    800041ac:	8526                	mv	a0,s1
    800041ae:	ffffd097          	auipc	ra,0xffffd
    800041b2:	9a4080e7          	jalr	-1628(ra) # 80000b52 <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    800041b6:	02c9a783          	lw	a5,44(s3)
    800041ba:	06f04863          	bgtz	a5,8000422a <end_op+0xd2>
    acquire(&log[dev].lock);
    800041be:	8526                	mv	a0,s1
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	92a080e7          	jalr	-1750(ra) # 80000aea <acquire>
    log[dev].committing = 0;
    800041c8:	0001f517          	auipc	a0,0x1f
    800041cc:	9d050513          	addi	a0,a0,-1584 # 80022b98 <log>
    800041d0:	0a800793          	li	a5,168
    800041d4:	02f90933          	mul	s2,s2,a5
    800041d8:	992a                	add	s2,s2,a0
    800041da:	02092223          	sw	zero,36(s2)
    wakeup(&log);
    800041de:	ffffe097          	auipc	ra,0xffffe
    800041e2:	0c8080e7          	jalr	200(ra) # 800022a6 <wakeup>
    release(&log[dev].lock);
    800041e6:	8526                	mv	a0,s1
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	96a080e7          	jalr	-1686(ra) # 80000b52 <release>
}
    800041f0:	a035                	j	8000421c <end_op+0xc4>
    panic("log[dev].committing");
    800041f2:	00004517          	auipc	a0,0x4
    800041f6:	40e50513          	addi	a0,a0,1038 # 80008600 <userret+0x570>
    800041fa:	ffffc097          	auipc	ra,0xffffc
    800041fe:	354080e7          	jalr	852(ra) # 8000054e <panic>
    wakeup(&log);
    80004202:	0001f517          	auipc	a0,0x1f
    80004206:	99650513          	addi	a0,a0,-1642 # 80022b98 <log>
    8000420a:	ffffe097          	auipc	ra,0xffffe
    8000420e:	09c080e7          	jalr	156(ra) # 800022a6 <wakeup>
  release(&log[dev].lock);
    80004212:	8526                	mv	a0,s1
    80004214:	ffffd097          	auipc	ra,0xffffd
    80004218:	93e080e7          	jalr	-1730(ra) # 80000b52 <release>
}
    8000421c:	70a2                	ld	ra,40(sp)
    8000421e:	7402                	ld	s0,32(sp)
    80004220:	64e2                	ld	s1,24(sp)
    80004222:	6942                	ld	s2,16(sp)
    80004224:	69a2                	ld	s3,8(sp)
    80004226:	6145                	addi	sp,sp,48
    80004228:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    8000422a:	854a                	mv	a0,s2
    8000422c:	00000097          	auipc	ra,0x0
    80004230:	c2a080e7          	jalr	-982(ra) # 80003e56 <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    80004234:	854a                	mv	a0,s2
    80004236:	00000097          	auipc	ra,0x0
    8000423a:	b96080e7          	jalr	-1130(ra) # 80003dcc <write_head>
    install_trans(dev); // Now install writes to home locations
    8000423e:	854a                	mv	a0,s2
    80004240:	00000097          	auipc	ra,0x0
    80004244:	cd8080e7          	jalr	-808(ra) # 80003f18 <install_trans>
    log[dev].lh.n = 0;
    80004248:	0a800793          	li	a5,168
    8000424c:	02f90733          	mul	a4,s2,a5
    80004250:	0001f797          	auipc	a5,0x1f
    80004254:	94878793          	addi	a5,a5,-1720 # 80022b98 <log>
    80004258:	97ba                	add	a5,a5,a4
    8000425a:	0207a623          	sw	zero,44(a5)
    write_head(dev);    // Erase the transaction from the log
    8000425e:	854a                	mv	a0,s2
    80004260:	00000097          	auipc	ra,0x0
    80004264:	b6c080e7          	jalr	-1172(ra) # 80003dcc <write_head>
    80004268:	bf99                	j	800041be <end_op+0x66>

000000008000426a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000426a:	7179                	addi	sp,sp,-48
    8000426c:	f406                	sd	ra,40(sp)
    8000426e:	f022                	sd	s0,32(sp)
    80004270:	ec26                	sd	s1,24(sp)
    80004272:	e84a                	sd	s2,16(sp)
    80004274:	e44e                	sd	s3,8(sp)
    80004276:	e052                	sd	s4,0(sp)
    80004278:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    8000427a:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    8000427e:	0a800793          	li	a5,168
    80004282:	02f90733          	mul	a4,s2,a5
    80004286:	0001f797          	auipc	a5,0x1f
    8000428a:	91278793          	addi	a5,a5,-1774 # 80022b98 <log>
    8000428e:	97ba                	add	a5,a5,a4
    80004290:	57d4                	lw	a3,44(a5)
    80004292:	47f5                	li	a5,29
    80004294:	0ad7cc63          	blt	a5,a3,8000434c <log_write+0xe2>
    80004298:	89aa                	mv	s3,a0
    8000429a:	0001f797          	auipc	a5,0x1f
    8000429e:	8fe78793          	addi	a5,a5,-1794 # 80022b98 <log>
    800042a2:	97ba                	add	a5,a5,a4
    800042a4:	4fdc                	lw	a5,28(a5)
    800042a6:	37fd                	addiw	a5,a5,-1
    800042a8:	0af6d263          	bge	a3,a5,8000434c <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    800042ac:	0a800793          	li	a5,168
    800042b0:	02f90733          	mul	a4,s2,a5
    800042b4:	0001f797          	auipc	a5,0x1f
    800042b8:	8e478793          	addi	a5,a5,-1820 # 80022b98 <log>
    800042bc:	97ba                	add	a5,a5,a4
    800042be:	539c                	lw	a5,32(a5)
    800042c0:	08f05e63          	blez	a5,8000435c <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800042c4:	0a800793          	li	a5,168
    800042c8:	02f904b3          	mul	s1,s2,a5
    800042cc:	0001fa17          	auipc	s4,0x1f
    800042d0:	8cca0a13          	addi	s4,s4,-1844 # 80022b98 <log>
    800042d4:	9a26                	add	s4,s4,s1
    800042d6:	8552                	mv	a0,s4
    800042d8:	ffffd097          	auipc	ra,0xffffd
    800042dc:	812080e7          	jalr	-2030(ra) # 80000aea <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800042e0:	02ca2603          	lw	a2,44(s4)
    800042e4:	08c05463          	blez	a2,8000436c <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800042e8:	00c9a583          	lw	a1,12(s3)
    800042ec:	0001f797          	auipc	a5,0x1f
    800042f0:	8dc78793          	addi	a5,a5,-1828 # 80022bc8 <log+0x30>
    800042f4:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800042f6:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800042f8:	4394                	lw	a3,0(a5)
    800042fa:	06b68a63          	beq	a3,a1,8000436e <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800042fe:	2705                	addiw	a4,a4,1
    80004300:	0791                	addi	a5,a5,4
    80004302:	fec71be3          	bne	a4,a2,800042f8 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    80004306:	02a00793          	li	a5,42
    8000430a:	02f907b3          	mul	a5,s2,a5
    8000430e:	97b2                	add	a5,a5,a2
    80004310:	07a1                	addi	a5,a5,8
    80004312:	078a                	slli	a5,a5,0x2
    80004314:	0001f717          	auipc	a4,0x1f
    80004318:	88470713          	addi	a4,a4,-1916 # 80022b98 <log>
    8000431c:	97ba                	add	a5,a5,a4
    8000431e:	00c9a703          	lw	a4,12(s3)
    80004322:	cb98                	sw	a4,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004324:	854e                	mv	a0,s3
    80004326:	fffff097          	auipc	ra,0xfffff
    8000432a:	cac080e7          	jalr	-852(ra) # 80002fd2 <bpin>
    log[dev].lh.n++;
    8000432e:	0a800793          	li	a5,168
    80004332:	02f90933          	mul	s2,s2,a5
    80004336:	0001f797          	auipc	a5,0x1f
    8000433a:	86278793          	addi	a5,a5,-1950 # 80022b98 <log>
    8000433e:	993e                	add	s2,s2,a5
    80004340:	02c92783          	lw	a5,44(s2)
    80004344:	2785                	addiw	a5,a5,1
    80004346:	02f92623          	sw	a5,44(s2)
    8000434a:	a099                	j	80004390 <log_write+0x126>
    panic("too big a transaction");
    8000434c:	00004517          	auipc	a0,0x4
    80004350:	2cc50513          	addi	a0,a0,716 # 80008618 <userret+0x588>
    80004354:	ffffc097          	auipc	ra,0xffffc
    80004358:	1fa080e7          	jalr	506(ra) # 8000054e <panic>
    panic("log_write outside of trans");
    8000435c:	00004517          	auipc	a0,0x4
    80004360:	2d450513          	addi	a0,a0,724 # 80008630 <userret+0x5a0>
    80004364:	ffffc097          	auipc	ra,0xffffc
    80004368:	1ea080e7          	jalr	490(ra) # 8000054e <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    8000436c:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    8000436e:	02a00793          	li	a5,42
    80004372:	02f907b3          	mul	a5,s2,a5
    80004376:	97ba                	add	a5,a5,a4
    80004378:	07a1                	addi	a5,a5,8
    8000437a:	078a                	slli	a5,a5,0x2
    8000437c:	0001f697          	auipc	a3,0x1f
    80004380:	81c68693          	addi	a3,a3,-2020 # 80022b98 <log>
    80004384:	97b6                	add	a5,a5,a3
    80004386:	00c9a683          	lw	a3,12(s3)
    8000438a:	cb94                	sw	a3,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    8000438c:	f8e60ce3          	beq	a2,a4,80004324 <log_write+0xba>
  }
  release(&log[dev].lock);
    80004390:	8552                	mv	a0,s4
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	7c0080e7          	jalr	1984(ra) # 80000b52 <release>
}
    8000439a:	70a2                	ld	ra,40(sp)
    8000439c:	7402                	ld	s0,32(sp)
    8000439e:	64e2                	ld	s1,24(sp)
    800043a0:	6942                	ld	s2,16(sp)
    800043a2:	69a2                	ld	s3,8(sp)
    800043a4:	6a02                	ld	s4,0(sp)
    800043a6:	6145                	addi	sp,sp,48
    800043a8:	8082                	ret

00000000800043aa <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    800043aa:	7179                	addi	sp,sp,-48
    800043ac:	f406                	sd	ra,40(sp)
    800043ae:	f022                	sd	s0,32(sp)
    800043b0:	ec26                	sd	s1,24(sp)
    800043b2:	e84a                	sd	s2,16(sp)
    800043b4:	e44e                	sd	s3,8(sp)
    800043b6:	1800                	addi	s0,sp,48
    800043b8:	84aa                	mv	s1,a0
    800043ba:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    800043bc:	0a800913          	li	s2,168
    800043c0:	032507b3          	mul	a5,a0,s2
    800043c4:	0001e917          	auipc	s2,0x1e
    800043c8:	7d490913          	addi	s2,s2,2004 # 80022b98 <log>
    800043cc:	993e                	add	s2,s2,a5
    800043ce:	854a                	mv	a0,s2
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	71a080e7          	jalr	1818(ra) # 80000aea <acquire>

  if (dev < 0 || dev >= NDISK)
    800043d8:	0004871b          	sext.w	a4,s1
    800043dc:	4785                	li	a5,1
    800043de:	0ae7e063          	bltu	a5,a4,8000447e <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    800043e2:	0a800793          	li	a5,168
    800043e6:	02f48733          	mul	a4,s1,a5
    800043ea:	0001e797          	auipc	a5,0x1e
    800043ee:	7ae78793          	addi	a5,a5,1966 # 80022b98 <log>
    800043f2:	97ba                	add	a5,a5,a4
    800043f4:	539c                	lw	a5,32(a5)
    800043f6:	cfc1                	beqz	a5,8000448e <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    800043f8:	37fd                	addiw	a5,a5,-1
    800043fa:	0007861b          	sext.w	a2,a5
    800043fe:	0a800713          	li	a4,168
    80004402:	02e486b3          	mul	a3,s1,a4
    80004406:	0001e717          	auipc	a4,0x1e
    8000440a:	79270713          	addi	a4,a4,1938 # 80022b98 <log>
    8000440e:	9736                	add	a4,a4,a3
    80004410:	d31c                	sw	a5,32(a4)
  if(log[dev].committing)
    80004412:	535c                	lw	a5,36(a4)
    80004414:	e7c9                	bnez	a5,8000449e <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004416:	ee41                	bnez	a2,800044ae <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    80004418:	0a800793          	li	a5,168
    8000441c:	02f48733          	mul	a4,s1,a5
    80004420:	0001e797          	auipc	a5,0x1e
    80004424:	77878793          	addi	a5,a5,1912 # 80022b98 <log>
    80004428:	97ba                	add	a5,a5,a4
    8000442a:	4705                	li	a4,1
    8000442c:	d3d8                	sw	a4,36(a5)
  }
  
  release(&log[dev].lock);
    8000442e:	854a                	mv	a0,s2
    80004430:	ffffc097          	auipc	ra,0xffffc
    80004434:	722080e7          	jalr	1826(ra) # 80000b52 <release>

  if(docommit & do_commit){
    80004438:	0019f993          	andi	s3,s3,1
    8000443c:	06098e63          	beqz	s3,800044b8 <crash_op+0x10e>
    printf("crash_op: commit\n");
    80004440:	00004517          	auipc	a0,0x4
    80004444:	24050513          	addi	a0,a0,576 # 80008680 <userret+0x5f0>
    80004448:	ffffc097          	auipc	ra,0xffffc
    8000444c:	150080e7          	jalr	336(ra) # 80000598 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    80004450:	0a800793          	li	a5,168
    80004454:	02f48733          	mul	a4,s1,a5
    80004458:	0001e797          	auipc	a5,0x1e
    8000445c:	74078793          	addi	a5,a5,1856 # 80022b98 <log>
    80004460:	97ba                	add	a5,a5,a4
    80004462:	57dc                	lw	a5,44(a5)
    80004464:	04f05a63          	blez	a5,800044b8 <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    80004468:	8526                	mv	a0,s1
    8000446a:	00000097          	auipc	ra,0x0
    8000446e:	9ec080e7          	jalr	-1556(ra) # 80003e56 <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    80004472:	8526                	mv	a0,s1
    80004474:	00000097          	auipc	ra,0x0
    80004478:	958080e7          	jalr	-1704(ra) # 80003dcc <write_head>
    8000447c:	a835                	j	800044b8 <crash_op+0x10e>
    panic("end_op: invalid disk");
    8000447e:	00004517          	auipc	a0,0x4
    80004482:	1d250513          	addi	a0,a0,466 # 80008650 <userret+0x5c0>
    80004486:	ffffc097          	auipc	ra,0xffffc
    8000448a:	0c8080e7          	jalr	200(ra) # 8000054e <panic>
    panic("end_op: already closed");
    8000448e:	00004517          	auipc	a0,0x4
    80004492:	1da50513          	addi	a0,a0,474 # 80008668 <userret+0x5d8>
    80004496:	ffffc097          	auipc	ra,0xffffc
    8000449a:	0b8080e7          	jalr	184(ra) # 8000054e <panic>
    panic("log[dev].committing");
    8000449e:	00004517          	auipc	a0,0x4
    800044a2:	16250513          	addi	a0,a0,354 # 80008600 <userret+0x570>
    800044a6:	ffffc097          	auipc	ra,0xffffc
    800044aa:	0a8080e7          	jalr	168(ra) # 8000054e <panic>
  release(&log[dev].lock);
    800044ae:	854a                	mv	a0,s2
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	6a2080e7          	jalr	1698(ra) # 80000b52 <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    800044b8:	00004517          	auipc	a0,0x4
    800044bc:	1e050513          	addi	a0,a0,480 # 80008698 <userret+0x608>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	08e080e7          	jalr	142(ra) # 8000054e <panic>

00000000800044c8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044c8:	1101                	addi	sp,sp,-32
    800044ca:	ec06                	sd	ra,24(sp)
    800044cc:	e822                	sd	s0,16(sp)
    800044ce:	e426                	sd	s1,8(sp)
    800044d0:	e04a                	sd	s2,0(sp)
    800044d2:	1000                	addi	s0,sp,32
    800044d4:	84aa                	mv	s1,a0
    800044d6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044d8:	00004597          	auipc	a1,0x4
    800044dc:	20058593          	addi	a1,a1,512 # 800086d8 <userret+0x648>
    800044e0:	0521                	addi	a0,a0,8
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	4f6080e7          	jalr	1270(ra) # 800009d8 <initlock>
  lk->name = name;
    800044ea:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044ee:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044f2:	0204a423          	sw	zero,40(s1)
}
    800044f6:	60e2                	ld	ra,24(sp)
    800044f8:	6442                	ld	s0,16(sp)
    800044fa:	64a2                	ld	s1,8(sp)
    800044fc:	6902                	ld	s2,0(sp)
    800044fe:	6105                	addi	sp,sp,32
    80004500:	8082                	ret

0000000080004502 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004502:	1101                	addi	sp,sp,-32
    80004504:	ec06                	sd	ra,24(sp)
    80004506:	e822                	sd	s0,16(sp)
    80004508:	e426                	sd	s1,8(sp)
    8000450a:	e04a                	sd	s2,0(sp)
    8000450c:	1000                	addi	s0,sp,32
    8000450e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004510:	00850913          	addi	s2,a0,8
    80004514:	854a                	mv	a0,s2
    80004516:	ffffc097          	auipc	ra,0xffffc
    8000451a:	5d4080e7          	jalr	1492(ra) # 80000aea <acquire>
  while (lk->locked) {
    8000451e:	409c                	lw	a5,0(s1)
    80004520:	cb89                	beqz	a5,80004532 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004522:	85ca                	mv	a1,s2
    80004524:	8526                	mv	a0,s1
    80004526:	ffffe097          	auipc	ra,0xffffe
    8000452a:	bfa080e7          	jalr	-1030(ra) # 80002120 <sleep>
  while (lk->locked) {
    8000452e:	409c                	lw	a5,0(s1)
    80004530:	fbed                	bnez	a5,80004522 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004532:	4785                	li	a5,1
    80004534:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004536:	ffffd097          	auipc	ra,0xffffd
    8000453a:	3d0080e7          	jalr	976(ra) # 80001906 <myproc>
    8000453e:	5d1c                	lw	a5,56(a0)
    80004540:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004542:	854a                	mv	a0,s2
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	60e080e7          	jalr	1550(ra) # 80000b52 <release>
}
    8000454c:	60e2                	ld	ra,24(sp)
    8000454e:	6442                	ld	s0,16(sp)
    80004550:	64a2                	ld	s1,8(sp)
    80004552:	6902                	ld	s2,0(sp)
    80004554:	6105                	addi	sp,sp,32
    80004556:	8082                	ret

0000000080004558 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004558:	1101                	addi	sp,sp,-32
    8000455a:	ec06                	sd	ra,24(sp)
    8000455c:	e822                	sd	s0,16(sp)
    8000455e:	e426                	sd	s1,8(sp)
    80004560:	e04a                	sd	s2,0(sp)
    80004562:	1000                	addi	s0,sp,32
    80004564:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004566:	00850913          	addi	s2,a0,8
    8000456a:	854a                	mv	a0,s2
    8000456c:	ffffc097          	auipc	ra,0xffffc
    80004570:	57e080e7          	jalr	1406(ra) # 80000aea <acquire>
  lk->locked = 0;
    80004574:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004578:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000457c:	8526                	mv	a0,s1
    8000457e:	ffffe097          	auipc	ra,0xffffe
    80004582:	d28080e7          	jalr	-728(ra) # 800022a6 <wakeup>
  release(&lk->lk);
    80004586:	854a                	mv	a0,s2
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	5ca080e7          	jalr	1482(ra) # 80000b52 <release>
}
    80004590:	60e2                	ld	ra,24(sp)
    80004592:	6442                	ld	s0,16(sp)
    80004594:	64a2                	ld	s1,8(sp)
    80004596:	6902                	ld	s2,0(sp)
    80004598:	6105                	addi	sp,sp,32
    8000459a:	8082                	ret

000000008000459c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000459c:	7179                	addi	sp,sp,-48
    8000459e:	f406                	sd	ra,40(sp)
    800045a0:	f022                	sd	s0,32(sp)
    800045a2:	ec26                	sd	s1,24(sp)
    800045a4:	e84a                	sd	s2,16(sp)
    800045a6:	e44e                	sd	s3,8(sp)
    800045a8:	1800                	addi	s0,sp,48
    800045aa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045ac:	00850913          	addi	s2,a0,8
    800045b0:	854a                	mv	a0,s2
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	538080e7          	jalr	1336(ra) # 80000aea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045ba:	409c                	lw	a5,0(s1)
    800045bc:	ef99                	bnez	a5,800045da <holdingsleep+0x3e>
    800045be:	4481                	li	s1,0
  release(&lk->lk);
    800045c0:	854a                	mv	a0,s2
    800045c2:	ffffc097          	auipc	ra,0xffffc
    800045c6:	590080e7          	jalr	1424(ra) # 80000b52 <release>
  return r;
}
    800045ca:	8526                	mv	a0,s1
    800045cc:	70a2                	ld	ra,40(sp)
    800045ce:	7402                	ld	s0,32(sp)
    800045d0:	64e2                	ld	s1,24(sp)
    800045d2:	6942                	ld	s2,16(sp)
    800045d4:	69a2                	ld	s3,8(sp)
    800045d6:	6145                	addi	sp,sp,48
    800045d8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800045da:	0284a983          	lw	s3,40(s1)
    800045de:	ffffd097          	auipc	ra,0xffffd
    800045e2:	328080e7          	jalr	808(ra) # 80001906 <myproc>
    800045e6:	5d04                	lw	s1,56(a0)
    800045e8:	413484b3          	sub	s1,s1,s3
    800045ec:	0014b493          	seqz	s1,s1
    800045f0:	bfc1                	j	800045c0 <holdingsleep+0x24>

00000000800045f2 <fileinit>:
  //struct file *file;
} ftable;

void
fileinit(void)
{
    800045f2:	1141                	addi	sp,sp,-16
    800045f4:	e406                	sd	ra,8(sp)
    800045f6:	e022                	sd	s0,0(sp)
    800045f8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045fa:	00004597          	auipc	a1,0x4
    800045fe:	0ee58593          	addi	a1,a1,238 # 800086e8 <userret+0x658>
    80004602:	0001e517          	auipc	a0,0x1e
    80004606:	6e650513          	addi	a0,a0,1766 # 80022ce8 <ftable>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	3ce080e7          	jalr	974(ra) # 800009d8 <initlock>
}
    80004612:	60a2                	ld	ra,8(sp)
    80004614:	6402                	ld	s0,0(sp)
    80004616:	0141                	addi	sp,sp,16
    80004618:	8082                	ret

000000008000461a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000461a:	1101                	addi	sp,sp,-32
    8000461c:	ec06                	sd	ra,24(sp)
    8000461e:	e822                	sd	s0,16(sp)
    80004620:	e426                	sd	s1,8(sp)
    80004622:	1000                	addi	s0,sp,32
  struct file *f;
  
  acquire(&ftable.lock);
    80004624:	0001e517          	auipc	a0,0x1e
    80004628:	6c450513          	addi	a0,a0,1732 # 80022ce8 <ftable>
    8000462c:	ffffc097          	auipc	ra,0xffffc
    80004630:	4be080e7          	jalr	1214(ra) # 80000aea <acquire>
  f=bd_malloc(sizeof(struct file));
    80004634:	02800513          	li	a0,40
    80004638:	00002097          	auipc	ra,0x2
    8000463c:	220080e7          	jalr	544(ra) # 80006858 <bd_malloc>
    80004640:	84aa                	mv	s1,a0
  if(f){
    80004642:	c905                	beqz	a0,80004672 <filealloc+0x58>
    memset(f,0,sizeof(struct file));
    80004644:	02800613          	li	a2,40
    80004648:	4581                	li	a1,0
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	564080e7          	jalr	1380(ra) # 80000bae <memset>
    f->ref=1;
    80004652:	4785                	li	a5,1
    80004654:	c0dc                	sw	a5,4(s1)
    release(&ftable.lock); //has been used
    80004656:	0001e517          	auipc	a0,0x1e
    8000465a:	69250513          	addi	a0,a0,1682 # 80022ce8 <ftable>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	4f4080e7          	jalr	1268(ra) # 80000b52 <release>
    return f;
  }
  release(&ftable.lock);//release the unused file table
  return 0;
}
    80004666:	8526                	mv	a0,s1
    80004668:	60e2                	ld	ra,24(sp)
    8000466a:	6442                	ld	s0,16(sp)
    8000466c:	64a2                	ld	s1,8(sp)
    8000466e:	6105                	addi	sp,sp,32
    80004670:	8082                	ret
  release(&ftable.lock);//release the unused file table
    80004672:	0001e517          	auipc	a0,0x1e
    80004676:	67650513          	addi	a0,a0,1654 # 80022ce8 <ftable>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	4d8080e7          	jalr	1240(ra) # 80000b52 <release>
  return 0;
    80004682:	b7d5                	j	80004666 <filealloc+0x4c>

0000000080004684 <filedup>:
//}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004684:	1101                	addi	sp,sp,-32
    80004686:	ec06                	sd	ra,24(sp)
    80004688:	e822                	sd	s0,16(sp)
    8000468a:	e426                	sd	s1,8(sp)
    8000468c:	1000                	addi	s0,sp,32
    8000468e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004690:	0001e517          	auipc	a0,0x1e
    80004694:	65850513          	addi	a0,a0,1624 # 80022ce8 <ftable>
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	452080e7          	jalr	1106(ra) # 80000aea <acquire>
  if(f->ref < 1)
    800046a0:	40dc                	lw	a5,4(s1)
    800046a2:	02f05263          	blez	a5,800046c6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046a6:	2785                	addiw	a5,a5,1
    800046a8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046aa:	0001e517          	auipc	a0,0x1e
    800046ae:	63e50513          	addi	a0,a0,1598 # 80022ce8 <ftable>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	4a0080e7          	jalr	1184(ra) # 80000b52 <release>
  return f;
}
    800046ba:	8526                	mv	a0,s1
    800046bc:	60e2                	ld	ra,24(sp)
    800046be:	6442                	ld	s0,16(sp)
    800046c0:	64a2                	ld	s1,8(sp)
    800046c2:	6105                	addi	sp,sp,32
    800046c4:	8082                	ret
    panic("filedup");
    800046c6:	00004517          	auipc	a0,0x4
    800046ca:	02a50513          	addi	a0,a0,42 # 800086f0 <userret+0x660>
    800046ce:	ffffc097          	auipc	ra,0xffffc
    800046d2:	e80080e7          	jalr	-384(ra) # 8000054e <panic>

00000000800046d6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800046d6:	1101                	addi	sp,sp,-32
    800046d8:	ec06                	sd	ra,24(sp)
    800046da:	e822                	sd	s0,16(sp)
    800046dc:	e426                	sd	s1,8(sp)
    800046de:	1000                	addi	s0,sp,32
    800046e0:	84aa                	mv	s1,a0
  //struct file ff;

  acquire(&ftable.lock);
    800046e2:	0001e517          	auipc	a0,0x1e
    800046e6:	60650513          	addi	a0,a0,1542 # 80022ce8 <ftable>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	400080e7          	jalr	1024(ra) # 80000aea <acquire>
  if(f->ref < 1)
    800046f2:	40dc                	lw	a5,4(s1)
    800046f4:	04f05663          	blez	a5,80004740 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    800046f8:	37fd                	addiw	a5,a5,-1
    800046fa:	0007871b          	sext.w	a4,a5
    800046fe:	c0dc                	sw	a5,4(s1)
    80004700:	04e04863          	bgtz	a4,80004750 <fileclose+0x7a>
    release(&ftable.lock);
    return;
  }
  //ff = *f;
  f->ref = 0;
    80004704:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004708:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000470c:	0001e517          	auipc	a0,0x1e
    80004710:	5dc50513          	addi	a0,a0,1500 # 80022ce8 <ftable>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	43e080e7          	jalr	1086(ra) # 80000b52 <release>

  if(f->type == FD_PIPE){
    8000471c:	409c                	lw	a5,0(s1)
    8000471e:	4705                	li	a4,1
    80004720:	04e78163          	beq	a5,a4,80004762 <fileclose+0x8c>
    pipeclose(f->pipe, f->writable);
  } else if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004724:	37f9                	addiw	a5,a5,-2
    80004726:	4705                	li	a4,1
    80004728:	04f77563          	bgeu	a4,a5,80004772 <fileclose+0x9c>
    begin_op(f->ip->dev);
    iput(f->ip);
    end_op(f->ip->dev);
  }
  bd_free(f);
    8000472c:	8526                	mv	a0,s1
    8000472e:	00002097          	auipc	ra,0x2
    80004732:	316080e7          	jalr	790(ra) # 80006a44 <bd_free>
}
    80004736:	60e2                	ld	ra,24(sp)
    80004738:	6442                	ld	s0,16(sp)
    8000473a:	64a2                	ld	s1,8(sp)
    8000473c:	6105                	addi	sp,sp,32
    8000473e:	8082                	ret
    panic("fileclose");
    80004740:	00004517          	auipc	a0,0x4
    80004744:	fb850513          	addi	a0,a0,-72 # 800086f8 <userret+0x668>
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	e06080e7          	jalr	-506(ra) # 8000054e <panic>
    release(&ftable.lock);
    80004750:	0001e517          	auipc	a0,0x1e
    80004754:	59850513          	addi	a0,a0,1432 # 80022ce8 <ftable>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	3fa080e7          	jalr	1018(ra) # 80000b52 <release>
    return;
    80004760:	bfd9                	j	80004736 <fileclose+0x60>
    pipeclose(f->pipe, f->writable);
    80004762:	0094c583          	lbu	a1,9(s1)
    80004766:	6888                	ld	a0,16(s1)
    80004768:	00000097          	auipc	ra,0x0
    8000476c:	36c080e7          	jalr	876(ra) # 80004ad4 <pipeclose>
    80004770:	bf75                	j	8000472c <fileclose+0x56>
    begin_op(f->ip->dev);
    80004772:	6c9c                	ld	a5,24(s1)
    80004774:	4388                	lw	a0,0(a5)
    80004776:	00000097          	auipc	ra,0x0
    8000477a:	938080e7          	jalr	-1736(ra) # 800040ae <begin_op>
    iput(f->ip);
    8000477e:	6c88                	ld	a0,24(s1)
    80004780:	fffff097          	auipc	ra,0xfffff
    80004784:	f94080e7          	jalr	-108(ra) # 80003714 <iput>
    end_op(f->ip->dev);
    80004788:	6c9c                	ld	a5,24(s1)
    8000478a:	4388                	lw	a0,0(a5)
    8000478c:	00000097          	auipc	ra,0x0
    80004790:	9cc080e7          	jalr	-1588(ra) # 80004158 <end_op>
    80004794:	bf61                	j	8000472c <fileclose+0x56>

0000000080004796 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004796:	715d                	addi	sp,sp,-80
    80004798:	e486                	sd	ra,72(sp)
    8000479a:	e0a2                	sd	s0,64(sp)
    8000479c:	fc26                	sd	s1,56(sp)
    8000479e:	f84a                	sd	s2,48(sp)
    800047a0:	f44e                	sd	s3,40(sp)
    800047a2:	0880                	addi	s0,sp,80
    800047a4:	84aa                	mv	s1,a0
    800047a6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800047a8:	ffffd097          	auipc	ra,0xffffd
    800047ac:	15e080e7          	jalr	350(ra) # 80001906 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800047b0:	409c                	lw	a5,0(s1)
    800047b2:	37f9                	addiw	a5,a5,-2
    800047b4:	4705                	li	a4,1
    800047b6:	04f76763          	bltu	a4,a5,80004804 <filestat+0x6e>
    800047ba:	892a                	mv	s2,a0
    ilock(f->ip);
    800047bc:	6c88                	ld	a0,24(s1)
    800047be:	fffff097          	auipc	ra,0xfffff
    800047c2:	e48080e7          	jalr	-440(ra) # 80003606 <ilock>
    stati(f->ip, &st);
    800047c6:	fb840593          	addi	a1,s0,-72
    800047ca:	6c88                	ld	a0,24(s1)
    800047cc:	fffff097          	auipc	ra,0xfffff
    800047d0:	0a0080e7          	jalr	160(ra) # 8000386c <stati>
    iunlock(f->ip);
    800047d4:	6c88                	ld	a0,24(s1)
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	ef2080e7          	jalr	-270(ra) # 800036c8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800047de:	46e1                	li	a3,24
    800047e0:	fb840613          	addi	a2,s0,-72
    800047e4:	85ce                	mv	a1,s3
    800047e6:	05893503          	ld	a0,88(s2)
    800047ea:	ffffd097          	auipc	ra,0xffffd
    800047ee:	d56080e7          	jalr	-682(ra) # 80001540 <copyout>
    800047f2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047f6:	60a6                	ld	ra,72(sp)
    800047f8:	6406                	ld	s0,64(sp)
    800047fa:	74e2                	ld	s1,56(sp)
    800047fc:	7942                	ld	s2,48(sp)
    800047fe:	79a2                	ld	s3,40(sp)
    80004800:	6161                	addi	sp,sp,80
    80004802:	8082                	ret
  return -1;
    80004804:	557d                	li	a0,-1
    80004806:	bfc5                	j	800047f6 <filestat+0x60>

0000000080004808 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004808:	7179                	addi	sp,sp,-48
    8000480a:	f406                	sd	ra,40(sp)
    8000480c:	f022                	sd	s0,32(sp)
    8000480e:	ec26                	sd	s1,24(sp)
    80004810:	e84a                	sd	s2,16(sp)
    80004812:	e44e                	sd	s3,8(sp)
    80004814:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004816:	00854783          	lbu	a5,8(a0)
    8000481a:	cfc1                	beqz	a5,800048b2 <fileread+0xaa>
    8000481c:	84aa                	mv	s1,a0
    8000481e:	89ae                	mv	s3,a1
    80004820:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004822:	411c                	lw	a5,0(a0)
    80004824:	4705                	li	a4,1
    80004826:	04e78963          	beq	a5,a4,80004878 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000482a:	470d                	li	a4,3
    8000482c:	04e78d63          	beq	a5,a4,80004886 <fileread+0x7e>
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004830:	4709                	li	a4,2
    80004832:	06e79863          	bne	a5,a4,800048a2 <fileread+0x9a>
    ilock(f->ip);
    80004836:	6d08                	ld	a0,24(a0)
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	dce080e7          	jalr	-562(ra) # 80003606 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004840:	874a                	mv	a4,s2
    80004842:	5094                	lw	a3,32(s1)
    80004844:	864e                	mv	a2,s3
    80004846:	4585                	li	a1,1
    80004848:	6c88                	ld	a0,24(s1)
    8000484a:	fffff097          	auipc	ra,0xfffff
    8000484e:	04c080e7          	jalr	76(ra) # 80003896 <readi>
    80004852:	892a                	mv	s2,a0
    80004854:	00a05563          	blez	a0,8000485e <fileread+0x56>
      f->off += r;
    80004858:	509c                	lw	a5,32(s1)
    8000485a:	9fa9                	addw	a5,a5,a0
    8000485c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000485e:	6c88                	ld	a0,24(s1)
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	e68080e7          	jalr	-408(ra) # 800036c8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004868:	854a                	mv	a0,s2
    8000486a:	70a2                	ld	ra,40(sp)
    8000486c:	7402                	ld	s0,32(sp)
    8000486e:	64e2                	ld	s1,24(sp)
    80004870:	6942                	ld	s2,16(sp)
    80004872:	69a2                	ld	s3,8(sp)
    80004874:	6145                	addi	sp,sp,48
    80004876:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004878:	6908                	ld	a0,16(a0)
    8000487a:	00000097          	auipc	ra,0x0
    8000487e:	3de080e7          	jalr	990(ra) # 80004c58 <piperead>
    80004882:	892a                	mv	s2,a0
    80004884:	b7d5                	j	80004868 <fileread+0x60>
    r = devsw[f->major].read(1, addr, n);
    80004886:	02451783          	lh	a5,36(a0)
    8000488a:	00479713          	slli	a4,a5,0x4
    8000488e:	0001e797          	auipc	a5,0x1e
    80004892:	45a78793          	addi	a5,a5,1114 # 80022ce8 <ftable>
    80004896:	97ba                	add	a5,a5,a4
    80004898:	6f9c                	ld	a5,24(a5)
    8000489a:	4505                	li	a0,1
    8000489c:	9782                	jalr	a5
    8000489e:	892a                	mv	s2,a0
    800048a0:	b7e1                	j	80004868 <fileread+0x60>
    panic("fileread");
    800048a2:	00004517          	auipc	a0,0x4
    800048a6:	e6650513          	addi	a0,a0,-410 # 80008708 <userret+0x678>
    800048aa:	ffffc097          	auipc	ra,0xffffc
    800048ae:	ca4080e7          	jalr	-860(ra) # 8000054e <panic>
    return -1;
    800048b2:	597d                	li	s2,-1
    800048b4:	bf55                	j	80004868 <fileread+0x60>

00000000800048b6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800048b6:	00954783          	lbu	a5,9(a0)
    800048ba:	12078e63          	beqz	a5,800049f6 <filewrite+0x140>
{
    800048be:	715d                	addi	sp,sp,-80
    800048c0:	e486                	sd	ra,72(sp)
    800048c2:	e0a2                	sd	s0,64(sp)
    800048c4:	fc26                	sd	s1,56(sp)
    800048c6:	f84a                	sd	s2,48(sp)
    800048c8:	f44e                	sd	s3,40(sp)
    800048ca:	f052                	sd	s4,32(sp)
    800048cc:	ec56                	sd	s5,24(sp)
    800048ce:	e85a                	sd	s6,16(sp)
    800048d0:	e45e                	sd	s7,8(sp)
    800048d2:	e062                	sd	s8,0(sp)
    800048d4:	0880                	addi	s0,sp,80
    800048d6:	84aa                	mv	s1,a0
    800048d8:	8aae                	mv	s5,a1
    800048da:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048dc:	411c                	lw	a5,0(a0)
    800048de:	4705                	li	a4,1
    800048e0:	02e78263          	beq	a5,a4,80004904 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048e4:	470d                	li	a4,3
    800048e6:	02e78563          	beq	a5,a4,80004910 <filewrite+0x5a>
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048ea:	4709                	li	a4,2
    800048ec:	0ee79d63          	bne	a5,a4,800049e6 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048f0:	0ec05763          	blez	a2,800049de <filewrite+0x128>
    int i = 0;
    800048f4:	4981                	li	s3,0
    800048f6:	6b05                	lui	s6,0x1
    800048f8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800048fc:	6b85                	lui	s7,0x1
    800048fe:	c00b8b9b          	addiw	s7,s7,-1024
    80004902:	a051                	j	80004986 <filewrite+0xd0>
    ret = pipewrite(f->pipe, addr, n);
    80004904:	6908                	ld	a0,16(a0)
    80004906:	00000097          	auipc	ra,0x0
    8000490a:	23e080e7          	jalr	574(ra) # 80004b44 <pipewrite>
    8000490e:	a065                	j	800049b6 <filewrite+0x100>
    ret = devsw[f->major].write(1, addr, n);
    80004910:	02451783          	lh	a5,36(a0)
    80004914:	00479713          	slli	a4,a5,0x4
    80004918:	0001e797          	auipc	a5,0x1e
    8000491c:	3d078793          	addi	a5,a5,976 # 80022ce8 <ftable>
    80004920:	97ba                	add	a5,a5,a4
    80004922:	739c                	ld	a5,32(a5)
    80004924:	4505                	li	a0,1
    80004926:	9782                	jalr	a5
    80004928:	a079                	j	800049b6 <filewrite+0x100>
    8000492a:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    8000492e:	6c9c                	ld	a5,24(s1)
    80004930:	4388                	lw	a0,0(a5)
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	77c080e7          	jalr	1916(ra) # 800040ae <begin_op>
      ilock(f->ip);
    8000493a:	6c88                	ld	a0,24(s1)
    8000493c:	fffff097          	auipc	ra,0xfffff
    80004940:	cca080e7          	jalr	-822(ra) # 80003606 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004944:	8762                	mv	a4,s8
    80004946:	5094                	lw	a3,32(s1)
    80004948:	01598633          	add	a2,s3,s5
    8000494c:	4585                	li	a1,1
    8000494e:	6c88                	ld	a0,24(s1)
    80004950:	fffff097          	auipc	ra,0xfffff
    80004954:	03a080e7          	jalr	58(ra) # 8000398a <writei>
    80004958:	892a                	mv	s2,a0
    8000495a:	02a05e63          	blez	a0,80004996 <filewrite+0xe0>
        f->off += r;
    8000495e:	509c                	lw	a5,32(s1)
    80004960:	9fa9                	addw	a5,a5,a0
    80004962:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004964:	6c88                	ld	a0,24(s1)
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	d62080e7          	jalr	-670(ra) # 800036c8 <iunlock>
      end_op(f->ip->dev);
    8000496e:	6c9c                	ld	a5,24(s1)
    80004970:	4388                	lw	a0,0(a5)
    80004972:	fffff097          	auipc	ra,0xfffff
    80004976:	7e6080e7          	jalr	2022(ra) # 80004158 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000497a:	052c1a63          	bne	s8,s2,800049ce <filewrite+0x118>
        panic("short filewrite");
      i += r;
    8000497e:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004982:	0349d763          	bge	s3,s4,800049b0 <filewrite+0xfa>
      int n1 = n - i;
    80004986:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000498a:	893e                	mv	s2,a5
    8000498c:	2781                	sext.w	a5,a5
    8000498e:	f8fb5ee3          	bge	s6,a5,8000492a <filewrite+0x74>
    80004992:	895e                	mv	s2,s7
    80004994:	bf59                	j	8000492a <filewrite+0x74>
      iunlock(f->ip);
    80004996:	6c88                	ld	a0,24(s1)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	d30080e7          	jalr	-720(ra) # 800036c8 <iunlock>
      end_op(f->ip->dev);
    800049a0:	6c9c                	ld	a5,24(s1)
    800049a2:	4388                	lw	a0,0(a5)
    800049a4:	fffff097          	auipc	ra,0xfffff
    800049a8:	7b4080e7          	jalr	1972(ra) # 80004158 <end_op>
      if(r < 0)
    800049ac:	fc0957e3          	bgez	s2,8000497a <filewrite+0xc4>
    }
    ret = (i == n ? n : -1);
    800049b0:	8552                	mv	a0,s4
    800049b2:	033a1863          	bne	s4,s3,800049e2 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800049b6:	60a6                	ld	ra,72(sp)
    800049b8:	6406                	ld	s0,64(sp)
    800049ba:	74e2                	ld	s1,56(sp)
    800049bc:	7942                	ld	s2,48(sp)
    800049be:	79a2                	ld	s3,40(sp)
    800049c0:	7a02                	ld	s4,32(sp)
    800049c2:	6ae2                	ld	s5,24(sp)
    800049c4:	6b42                	ld	s6,16(sp)
    800049c6:	6ba2                	ld	s7,8(sp)
    800049c8:	6c02                	ld	s8,0(sp)
    800049ca:	6161                	addi	sp,sp,80
    800049cc:	8082                	ret
        panic("short filewrite");
    800049ce:	00004517          	auipc	a0,0x4
    800049d2:	d4a50513          	addi	a0,a0,-694 # 80008718 <userret+0x688>
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	b78080e7          	jalr	-1160(ra) # 8000054e <panic>
    int i = 0;
    800049de:	4981                	li	s3,0
    800049e0:	bfc1                	j	800049b0 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800049e2:	557d                	li	a0,-1
    800049e4:	bfc9                	j	800049b6 <filewrite+0x100>
    panic("filewrite");
    800049e6:	00004517          	auipc	a0,0x4
    800049ea:	d4250513          	addi	a0,a0,-702 # 80008728 <userret+0x698>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	b60080e7          	jalr	-1184(ra) # 8000054e <panic>
    return -1;
    800049f6:	557d                	li	a0,-1
}
    800049f8:	8082                	ret

00000000800049fa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049fa:	7179                	addi	sp,sp,-48
    800049fc:	f406                	sd	ra,40(sp)
    800049fe:	f022                	sd	s0,32(sp)
    80004a00:	ec26                	sd	s1,24(sp)
    80004a02:	e84a                	sd	s2,16(sp)
    80004a04:	e44e                	sd	s3,8(sp)
    80004a06:	e052                	sd	s4,0(sp)
    80004a08:	1800                	addi	s0,sp,48
    80004a0a:	84aa                	mv	s1,a0
    80004a0c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a0e:	0005b023          	sd	zero,0(a1)
    80004a12:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a16:	00000097          	auipc	ra,0x0
    80004a1a:	c04080e7          	jalr	-1020(ra) # 8000461a <filealloc>
    80004a1e:	e088                	sd	a0,0(s1)
    80004a20:	c551                	beqz	a0,80004aac <pipealloc+0xb2>
    80004a22:	00000097          	auipc	ra,0x0
    80004a26:	bf8080e7          	jalr	-1032(ra) # 8000461a <filealloc>
    80004a2a:	00aa3023          	sd	a0,0(s4)
    80004a2e:	c92d                	beqz	a0,80004aa0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a30:	ffffc097          	auipc	ra,0xffffc
    80004a34:	f48080e7          	jalr	-184(ra) # 80000978 <kalloc>
    80004a38:	892a                	mv	s2,a0
    80004a3a:	c125                	beqz	a0,80004a9a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a3c:	4985                	li	s3,1
    80004a3e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a42:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a46:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a4a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a4e:	00004597          	auipc	a1,0x4
    80004a52:	cea58593          	addi	a1,a1,-790 # 80008738 <userret+0x6a8>
    80004a56:	ffffc097          	auipc	ra,0xffffc
    80004a5a:	f82080e7          	jalr	-126(ra) # 800009d8 <initlock>
  (*f0)->type = FD_PIPE;
    80004a5e:	609c                	ld	a5,0(s1)
    80004a60:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a64:	609c                	ld	a5,0(s1)
    80004a66:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a6a:	609c                	ld	a5,0(s1)
    80004a6c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a70:	609c                	ld	a5,0(s1)
    80004a72:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a76:	000a3783          	ld	a5,0(s4)
    80004a7a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a7e:	000a3783          	ld	a5,0(s4)
    80004a82:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a86:	000a3783          	ld	a5,0(s4)
    80004a8a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a8e:	000a3783          	ld	a5,0(s4)
    80004a92:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a96:	4501                	li	a0,0
    80004a98:	a025                	j	80004ac0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a9a:	6088                	ld	a0,0(s1)
    80004a9c:	e501                	bnez	a0,80004aa4 <pipealloc+0xaa>
    80004a9e:	a039                	j	80004aac <pipealloc+0xb2>
    80004aa0:	6088                	ld	a0,0(s1)
    80004aa2:	c51d                	beqz	a0,80004ad0 <pipealloc+0xd6>
    fileclose(*f0);
    80004aa4:	00000097          	auipc	ra,0x0
    80004aa8:	c32080e7          	jalr	-974(ra) # 800046d6 <fileclose>
  if(*f1)
    80004aac:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ab0:	557d                	li	a0,-1
  if(*f1)
    80004ab2:	c799                	beqz	a5,80004ac0 <pipealloc+0xc6>
    fileclose(*f1);
    80004ab4:	853e                	mv	a0,a5
    80004ab6:	00000097          	auipc	ra,0x0
    80004aba:	c20080e7          	jalr	-992(ra) # 800046d6 <fileclose>
  return -1;
    80004abe:	557d                	li	a0,-1
}
    80004ac0:	70a2                	ld	ra,40(sp)
    80004ac2:	7402                	ld	s0,32(sp)
    80004ac4:	64e2                	ld	s1,24(sp)
    80004ac6:	6942                	ld	s2,16(sp)
    80004ac8:	69a2                	ld	s3,8(sp)
    80004aca:	6a02                	ld	s4,0(sp)
    80004acc:	6145                	addi	sp,sp,48
    80004ace:	8082                	ret
  return -1;
    80004ad0:	557d                	li	a0,-1
    80004ad2:	b7fd                	j	80004ac0 <pipealloc+0xc6>

0000000080004ad4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ad4:	1101                	addi	sp,sp,-32
    80004ad6:	ec06                	sd	ra,24(sp)
    80004ad8:	e822                	sd	s0,16(sp)
    80004ada:	e426                	sd	s1,8(sp)
    80004adc:	e04a                	sd	s2,0(sp)
    80004ade:	1000                	addi	s0,sp,32
    80004ae0:	84aa                	mv	s1,a0
    80004ae2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ae4:	ffffc097          	auipc	ra,0xffffc
    80004ae8:	006080e7          	jalr	6(ra) # 80000aea <acquire>
  if(writable){
    80004aec:	02090d63          	beqz	s2,80004b26 <pipeclose+0x52>
    pi->writeopen = 0;
    80004af0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004af4:	21848513          	addi	a0,s1,536
    80004af8:	ffffd097          	auipc	ra,0xffffd
    80004afc:	7ae080e7          	jalr	1966(ra) # 800022a6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b00:	2204b783          	ld	a5,544(s1)
    80004b04:	eb95                	bnez	a5,80004b38 <pipeclose+0x64>
    release(&pi->lock);
    80004b06:	8526                	mv	a0,s1
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	04a080e7          	jalr	74(ra) # 80000b52 <release>
    kfree((char*)pi);
    80004b10:	8526                	mv	a0,s1
    80004b12:	ffffc097          	auipc	ra,0xffffc
    80004b16:	d52080e7          	jalr	-686(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    80004b1a:	60e2                	ld	ra,24(sp)
    80004b1c:	6442                	ld	s0,16(sp)
    80004b1e:	64a2                	ld	s1,8(sp)
    80004b20:	6902                	ld	s2,0(sp)
    80004b22:	6105                	addi	sp,sp,32
    80004b24:	8082                	ret
    pi->readopen = 0;
    80004b26:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b2a:	21c48513          	addi	a0,s1,540
    80004b2e:	ffffd097          	auipc	ra,0xffffd
    80004b32:	778080e7          	jalr	1912(ra) # 800022a6 <wakeup>
    80004b36:	b7e9                	j	80004b00 <pipeclose+0x2c>
    release(&pi->lock);
    80004b38:	8526                	mv	a0,s1
    80004b3a:	ffffc097          	auipc	ra,0xffffc
    80004b3e:	018080e7          	jalr	24(ra) # 80000b52 <release>
}
    80004b42:	bfe1                	j	80004b1a <pipeclose+0x46>

0000000080004b44 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b44:	7159                	addi	sp,sp,-112
    80004b46:	f486                	sd	ra,104(sp)
    80004b48:	f0a2                	sd	s0,96(sp)
    80004b4a:	eca6                	sd	s1,88(sp)
    80004b4c:	e8ca                	sd	s2,80(sp)
    80004b4e:	e4ce                	sd	s3,72(sp)
    80004b50:	e0d2                	sd	s4,64(sp)
    80004b52:	fc56                	sd	s5,56(sp)
    80004b54:	f85a                	sd	s6,48(sp)
    80004b56:	f45e                	sd	s7,40(sp)
    80004b58:	f062                	sd	s8,32(sp)
    80004b5a:	ec66                	sd	s9,24(sp)
    80004b5c:	1880                	addi	s0,sp,112
    80004b5e:	84aa                	mv	s1,a0
    80004b60:	8b2e                	mv	s6,a1
    80004b62:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004b64:	ffffd097          	auipc	ra,0xffffd
    80004b68:	da2080e7          	jalr	-606(ra) # 80001906 <myproc>
    80004b6c:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    80004b6e:	8526                	mv	a0,s1
    80004b70:	ffffc097          	auipc	ra,0xffffc
    80004b74:	f7a080e7          	jalr	-134(ra) # 80000aea <acquire>
  for(i = 0; i < n; i++){
    80004b78:	0b505063          	blez	s5,80004c18 <pipewrite+0xd4>
    80004b7c:	8926                	mv	s2,s1
    80004b7e:	fffa8b9b          	addiw	s7,s5,-1
    80004b82:	1b82                	slli	s7,s7,0x20
    80004b84:	020bdb93          	srli	s7,s7,0x20
    80004b88:	001b0793          	addi	a5,s6,1
    80004b8c:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b8e:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b92:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b96:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b98:	2184a783          	lw	a5,536(s1)
    80004b9c:	21c4a703          	lw	a4,540(s1)
    80004ba0:	2007879b          	addiw	a5,a5,512
    80004ba4:	02f71e63          	bne	a4,a5,80004be0 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80004ba8:	2204a783          	lw	a5,544(s1)
    80004bac:	c3d9                	beqz	a5,80004c32 <pipewrite+0xee>
    80004bae:	ffffd097          	auipc	ra,0xffffd
    80004bb2:	d58080e7          	jalr	-680(ra) # 80001906 <myproc>
    80004bb6:	591c                	lw	a5,48(a0)
    80004bb8:	efad                	bnez	a5,80004c32 <pipewrite+0xee>
      wakeup(&pi->nread);
    80004bba:	8552                	mv	a0,s4
    80004bbc:	ffffd097          	auipc	ra,0xffffd
    80004bc0:	6ea080e7          	jalr	1770(ra) # 800022a6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004bc4:	85ca                	mv	a1,s2
    80004bc6:	854e                	mv	a0,s3
    80004bc8:	ffffd097          	auipc	ra,0xffffd
    80004bcc:	558080e7          	jalr	1368(ra) # 80002120 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004bd0:	2184a783          	lw	a5,536(s1)
    80004bd4:	21c4a703          	lw	a4,540(s1)
    80004bd8:	2007879b          	addiw	a5,a5,512
    80004bdc:	fcf706e3          	beq	a4,a5,80004ba8 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004be0:	4685                	li	a3,1
    80004be2:	865a                	mv	a2,s6
    80004be4:	f9f40593          	addi	a1,s0,-97
    80004be8:	058c3503          	ld	a0,88(s8)
    80004bec:	ffffd097          	auipc	ra,0xffffd
    80004bf0:	9e6080e7          	jalr	-1562(ra) # 800015d2 <copyin>
    80004bf4:	03950263          	beq	a0,s9,80004c18 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bf8:	21c4a783          	lw	a5,540(s1)
    80004bfc:	0017871b          	addiw	a4,a5,1
    80004c00:	20e4ae23          	sw	a4,540(s1)
    80004c04:	1ff7f793          	andi	a5,a5,511
    80004c08:	97a6                	add	a5,a5,s1
    80004c0a:	f9f44703          	lbu	a4,-97(s0)
    80004c0e:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004c12:	0b05                	addi	s6,s6,1
    80004c14:	f97b12e3          	bne	s6,s7,80004b98 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004c18:	21848513          	addi	a0,s1,536
    80004c1c:	ffffd097          	auipc	ra,0xffffd
    80004c20:	68a080e7          	jalr	1674(ra) # 800022a6 <wakeup>
  release(&pi->lock);
    80004c24:	8526                	mv	a0,s1
    80004c26:	ffffc097          	auipc	ra,0xffffc
    80004c2a:	f2c080e7          	jalr	-212(ra) # 80000b52 <release>
  return n;
    80004c2e:	8556                	mv	a0,s5
    80004c30:	a039                	j	80004c3e <pipewrite+0xfa>
        release(&pi->lock);
    80004c32:	8526                	mv	a0,s1
    80004c34:	ffffc097          	auipc	ra,0xffffc
    80004c38:	f1e080e7          	jalr	-226(ra) # 80000b52 <release>
        return -1;
    80004c3c:	557d                	li	a0,-1
}
    80004c3e:	70a6                	ld	ra,104(sp)
    80004c40:	7406                	ld	s0,96(sp)
    80004c42:	64e6                	ld	s1,88(sp)
    80004c44:	6946                	ld	s2,80(sp)
    80004c46:	69a6                	ld	s3,72(sp)
    80004c48:	6a06                	ld	s4,64(sp)
    80004c4a:	7ae2                	ld	s5,56(sp)
    80004c4c:	7b42                	ld	s6,48(sp)
    80004c4e:	7ba2                	ld	s7,40(sp)
    80004c50:	7c02                	ld	s8,32(sp)
    80004c52:	6ce2                	ld	s9,24(sp)
    80004c54:	6165                	addi	sp,sp,112
    80004c56:	8082                	ret

0000000080004c58 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c58:	715d                	addi	sp,sp,-80
    80004c5a:	e486                	sd	ra,72(sp)
    80004c5c:	e0a2                	sd	s0,64(sp)
    80004c5e:	fc26                	sd	s1,56(sp)
    80004c60:	f84a                	sd	s2,48(sp)
    80004c62:	f44e                	sd	s3,40(sp)
    80004c64:	f052                	sd	s4,32(sp)
    80004c66:	ec56                	sd	s5,24(sp)
    80004c68:	e85a                	sd	s6,16(sp)
    80004c6a:	0880                	addi	s0,sp,80
    80004c6c:	84aa                	mv	s1,a0
    80004c6e:	892e                	mv	s2,a1
    80004c70:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004c72:	ffffd097          	auipc	ra,0xffffd
    80004c76:	c94080e7          	jalr	-876(ra) # 80001906 <myproc>
    80004c7a:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004c7c:	8b26                	mv	s6,s1
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	e6a080e7          	jalr	-406(ra) # 80000aea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c88:	2184a703          	lw	a4,536(s1)
    80004c8c:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c90:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c94:	02f71763          	bne	a4,a5,80004cc2 <piperead+0x6a>
    80004c98:	2244a783          	lw	a5,548(s1)
    80004c9c:	c39d                	beqz	a5,80004cc2 <piperead+0x6a>
    if(myproc()->killed){
    80004c9e:	ffffd097          	auipc	ra,0xffffd
    80004ca2:	c68080e7          	jalr	-920(ra) # 80001906 <myproc>
    80004ca6:	591c                	lw	a5,48(a0)
    80004ca8:	ebc1                	bnez	a5,80004d38 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004caa:	85da                	mv	a1,s6
    80004cac:	854e                	mv	a0,s3
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	472080e7          	jalr	1138(ra) # 80002120 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cb6:	2184a703          	lw	a4,536(s1)
    80004cba:	21c4a783          	lw	a5,540(s1)
    80004cbe:	fcf70de3          	beq	a4,a5,80004c98 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cc4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cc6:	05405363          	blez	s4,80004d0c <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004cca:	2184a783          	lw	a5,536(s1)
    80004cce:	21c4a703          	lw	a4,540(s1)
    80004cd2:	02f70d63          	beq	a4,a5,80004d0c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004cd6:	0017871b          	addiw	a4,a5,1
    80004cda:	20e4ac23          	sw	a4,536(s1)
    80004cde:	1ff7f793          	andi	a5,a5,511
    80004ce2:	97a6                	add	a5,a5,s1
    80004ce4:	0187c783          	lbu	a5,24(a5)
    80004ce8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cec:	4685                	li	a3,1
    80004cee:	fbf40613          	addi	a2,s0,-65
    80004cf2:	85ca                	mv	a1,s2
    80004cf4:	058ab503          	ld	a0,88(s5)
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	848080e7          	jalr	-1976(ra) # 80001540 <copyout>
    80004d00:	01650663          	beq	a0,s6,80004d0c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d04:	2985                	addiw	s3,s3,1
    80004d06:	0905                	addi	s2,s2,1
    80004d08:	fd3a11e3          	bne	s4,s3,80004cca <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d0c:	21c48513          	addi	a0,s1,540
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	596080e7          	jalr	1430(ra) # 800022a6 <wakeup>
  release(&pi->lock);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	e38080e7          	jalr	-456(ra) # 80000b52 <release>
  return i;
}
    80004d22:	854e                	mv	a0,s3
    80004d24:	60a6                	ld	ra,72(sp)
    80004d26:	6406                	ld	s0,64(sp)
    80004d28:	74e2                	ld	s1,56(sp)
    80004d2a:	7942                	ld	s2,48(sp)
    80004d2c:	79a2                	ld	s3,40(sp)
    80004d2e:	7a02                	ld	s4,32(sp)
    80004d30:	6ae2                	ld	s5,24(sp)
    80004d32:	6b42                	ld	s6,16(sp)
    80004d34:	6161                	addi	sp,sp,80
    80004d36:	8082                	ret
      release(&pi->lock);
    80004d38:	8526                	mv	a0,s1
    80004d3a:	ffffc097          	auipc	ra,0xffffc
    80004d3e:	e18080e7          	jalr	-488(ra) # 80000b52 <release>
      return -1;
    80004d42:	59fd                	li	s3,-1
    80004d44:	bff9                	j	80004d22 <piperead+0xca>

0000000080004d46 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d46:	df010113          	addi	sp,sp,-528
    80004d4a:	20113423          	sd	ra,520(sp)
    80004d4e:	20813023          	sd	s0,512(sp)
    80004d52:	ffa6                	sd	s1,504(sp)
    80004d54:	fbca                	sd	s2,496(sp)
    80004d56:	f7ce                	sd	s3,488(sp)
    80004d58:	f3d2                	sd	s4,480(sp)
    80004d5a:	efd6                	sd	s5,472(sp)
    80004d5c:	ebda                	sd	s6,464(sp)
    80004d5e:	e7de                	sd	s7,456(sp)
    80004d60:	e3e2                	sd	s8,448(sp)
    80004d62:	ff66                	sd	s9,440(sp)
    80004d64:	fb6a                	sd	s10,432(sp)
    80004d66:	f76e                	sd	s11,424(sp)
    80004d68:	0c00                	addi	s0,sp,528
    80004d6a:	84aa                	mv	s1,a0
    80004d6c:	dea43c23          	sd	a0,-520(s0)
    80004d70:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	b92080e7          	jalr	-1134(ra) # 80001906 <myproc>
    80004d7c:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80004d7e:	4501                	li	a0,0
    80004d80:	fffff097          	auipc	ra,0xfffff
    80004d84:	32e080e7          	jalr	814(ra) # 800040ae <begin_op>

  if((ip = namei(path)) == 0){
    80004d88:	8526                	mv	a0,s1
    80004d8a:	fffff097          	auipc	ra,0xfffff
    80004d8e:	008080e7          	jalr	8(ra) # 80003d92 <namei>
    80004d92:	c935                	beqz	a0,80004e06 <exec+0xc0>
    80004d94:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004d96:	fffff097          	auipc	ra,0xfffff
    80004d9a:	870080e7          	jalr	-1936(ra) # 80003606 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d9e:	04000713          	li	a4,64
    80004da2:	4681                	li	a3,0
    80004da4:	e4840613          	addi	a2,s0,-440
    80004da8:	4581                	li	a1,0
    80004daa:	8526                	mv	a0,s1
    80004dac:	fffff097          	auipc	ra,0xfffff
    80004db0:	aea080e7          	jalr	-1302(ra) # 80003896 <readi>
    80004db4:	04000793          	li	a5,64
    80004db8:	00f51a63          	bne	a0,a5,80004dcc <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004dbc:	e4842703          	lw	a4,-440(s0)
    80004dc0:	464c47b7          	lui	a5,0x464c4
    80004dc4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004dc8:	04f70663          	beq	a4,a5,80004e14 <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	fffff097          	auipc	ra,0xfffff
    80004dd2:	a76080e7          	jalr	-1418(ra) # 80003844 <iunlockput>
    end_op(ROOTDEV);
    80004dd6:	4501                	li	a0,0
    80004dd8:	fffff097          	auipc	ra,0xfffff
    80004ddc:	380080e7          	jalr	896(ra) # 80004158 <end_op>
  }
  return -1;
    80004de0:	557d                	li	a0,-1
}
    80004de2:	20813083          	ld	ra,520(sp)
    80004de6:	20013403          	ld	s0,512(sp)
    80004dea:	74fe                	ld	s1,504(sp)
    80004dec:	795e                	ld	s2,496(sp)
    80004dee:	79be                	ld	s3,488(sp)
    80004df0:	7a1e                	ld	s4,480(sp)
    80004df2:	6afe                	ld	s5,472(sp)
    80004df4:	6b5e                	ld	s6,464(sp)
    80004df6:	6bbe                	ld	s7,456(sp)
    80004df8:	6c1e                	ld	s8,448(sp)
    80004dfa:	7cfa                	ld	s9,440(sp)
    80004dfc:	7d5a                	ld	s10,432(sp)
    80004dfe:	7dba                	ld	s11,424(sp)
    80004e00:	21010113          	addi	sp,sp,528
    80004e04:	8082                	ret
    end_op(ROOTDEV);
    80004e06:	4501                	li	a0,0
    80004e08:	fffff097          	auipc	ra,0xfffff
    80004e0c:	350080e7          	jalr	848(ra) # 80004158 <end_op>
    return -1;
    80004e10:	557d                	li	a0,-1
    80004e12:	bfc1                	j	80004de2 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e14:	854a                	mv	a0,s2
    80004e16:	ffffd097          	auipc	ra,0xffffd
    80004e1a:	bb4080e7          	jalr	-1100(ra) # 800019ca <proc_pagetable>
    80004e1e:	8c2a                	mv	s8,a0
    80004e20:	d555                	beqz	a0,80004dcc <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e22:	e6842983          	lw	s3,-408(s0)
    80004e26:	e8045783          	lhu	a5,-384(s0)
    80004e2a:	c7fd                	beqz	a5,80004f18 <exec+0x1d2>
  sz = 0;
    80004e2c:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e30:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004e32:	6b05                	lui	s6,0x1
    80004e34:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004e38:	def43823          	sd	a5,-528(s0)
    80004e3c:	a0a5                	j	80004ea4 <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e3e:	00004517          	auipc	a0,0x4
    80004e42:	90250513          	addi	a0,a0,-1790 # 80008740 <userret+0x6b0>
    80004e46:	ffffb097          	auipc	ra,0xffffb
    80004e4a:	708080e7          	jalr	1800(ra) # 8000054e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e4e:	8756                	mv	a4,s5
    80004e50:	012d86bb          	addw	a3,s11,s2
    80004e54:	4581                	li	a1,0
    80004e56:	8526                	mv	a0,s1
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	a3e080e7          	jalr	-1474(ra) # 80003896 <readi>
    80004e60:	2501                	sext.w	a0,a0
    80004e62:	10aa9263          	bne	s5,a0,80004f66 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80004e66:	6785                	lui	a5,0x1
    80004e68:	0127893b          	addw	s2,a5,s2
    80004e6c:	77fd                	lui	a5,0xfffff
    80004e6e:	01478a3b          	addw	s4,a5,s4
    80004e72:	03997263          	bgeu	s2,s9,80004e96 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004e76:	02091593          	slli	a1,s2,0x20
    80004e7a:	9181                	srli	a1,a1,0x20
    80004e7c:	95ea                	add	a1,a1,s10
    80004e7e:	8562                	mv	a0,s8
    80004e80:	ffffc097          	auipc	ra,0xffffc
    80004e84:	12c080e7          	jalr	300(ra) # 80000fac <walkaddr>
    80004e88:	862a                	mv	a2,a0
    if(pa == 0)
    80004e8a:	d955                	beqz	a0,80004e3e <exec+0xf8>
      n = PGSIZE;
    80004e8c:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004e8e:	fd6a70e3          	bgeu	s4,s6,80004e4e <exec+0x108>
      n = sz - i;
    80004e92:	8ad2                	mv	s5,s4
    80004e94:	bf6d                	j	80004e4e <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e96:	2b85                	addiw	s7,s7,1
    80004e98:	0389899b          	addiw	s3,s3,56
    80004e9c:	e8045783          	lhu	a5,-384(s0)
    80004ea0:	06fbde63          	bge	s7,a5,80004f1c <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ea4:	2981                	sext.w	s3,s3
    80004ea6:	03800713          	li	a4,56
    80004eaa:	86ce                	mv	a3,s3
    80004eac:	e1040613          	addi	a2,s0,-496
    80004eb0:	4581                	li	a1,0
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	fffff097          	auipc	ra,0xfffff
    80004eb8:	9e2080e7          	jalr	-1566(ra) # 80003896 <readi>
    80004ebc:	03800793          	li	a5,56
    80004ec0:	0af51363          	bne	a0,a5,80004f66 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004ec4:	e1042783          	lw	a5,-496(s0)
    80004ec8:	4705                	li	a4,1
    80004eca:	fce796e3          	bne	a5,a4,80004e96 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004ece:	e3843603          	ld	a2,-456(s0)
    80004ed2:	e3043783          	ld	a5,-464(s0)
    80004ed6:	08f66863          	bltu	a2,a5,80004f66 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004eda:	e2043783          	ld	a5,-480(s0)
    80004ede:	963e                	add	a2,a2,a5
    80004ee0:	08f66363          	bltu	a2,a5,80004f66 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004ee4:	e0843583          	ld	a1,-504(s0)
    80004ee8:	8562                	mv	a0,s8
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	47c080e7          	jalr	1148(ra) # 80001366 <uvmalloc>
    80004ef2:	e0a43423          	sd	a0,-504(s0)
    80004ef6:	c925                	beqz	a0,80004f66 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004ef8:	e2043d03          	ld	s10,-480(s0)
    80004efc:	df043783          	ld	a5,-528(s0)
    80004f00:	00fd77b3          	and	a5,s10,a5
    80004f04:	e3ad                	bnez	a5,80004f66 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f06:	e1842d83          	lw	s11,-488(s0)
    80004f0a:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f0e:	f80c84e3          	beqz	s9,80004e96 <exec+0x150>
    80004f12:	8a66                	mv	s4,s9
    80004f14:	4901                	li	s2,0
    80004f16:	b785                	j	80004e76 <exec+0x130>
  sz = 0;
    80004f18:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	926080e7          	jalr	-1754(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    80004f26:	4501                	li	a0,0
    80004f28:	fffff097          	auipc	ra,0xfffff
    80004f2c:	230080e7          	jalr	560(ra) # 80004158 <end_op>
  p = myproc();
    80004f30:	ffffd097          	auipc	ra,0xffffd
    80004f34:	9d6080e7          	jalr	-1578(ra) # 80001906 <myproc>
    80004f38:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f3a:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    80004f3e:	6585                	lui	a1,0x1
    80004f40:	15fd                	addi	a1,a1,-1
    80004f42:	e0843783          	ld	a5,-504(s0)
    80004f46:	00b78b33          	add	s6,a5,a1
    80004f4a:	75fd                	lui	a1,0xfffff
    80004f4c:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f50:	6609                	lui	a2,0x2
    80004f52:	962e                	add	a2,a2,a1
    80004f54:	8562                	mv	a0,s8
    80004f56:	ffffc097          	auipc	ra,0xffffc
    80004f5a:	410080e7          	jalr	1040(ra) # 80001366 <uvmalloc>
    80004f5e:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004f62:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004f64:	ed01                	bnez	a0,80004f7c <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80004f66:	e0843583          	ld	a1,-504(s0)
    80004f6a:	8562                	mv	a0,s8
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	b5e080e7          	jalr	-1186(ra) # 80001aca <proc_freepagetable>
  if(ip){
    80004f74:	e4049ce3          	bnez	s1,80004dcc <exec+0x86>
  return -1;
    80004f78:	557d                	li	a0,-1
    80004f7a:	b5a5                	j	80004de2 <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f7c:	75f9                	lui	a1,0xffffe
    80004f7e:	84aa                	mv	s1,a0
    80004f80:	95aa                	add	a1,a1,a0
    80004f82:	8562                	mv	a0,s8
    80004f84:	ffffc097          	auipc	ra,0xffffc
    80004f88:	58a080e7          	jalr	1418(ra) # 8000150e <uvmclear>
  stackbase = sp - PGSIZE;
    80004f8c:	7afd                	lui	s5,0xfffff
    80004f8e:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004f90:	e0043783          	ld	a5,-512(s0)
    80004f94:	6388                	ld	a0,0(a5)
    80004f96:	c135                	beqz	a0,80004ffa <exec+0x2b4>
    80004f98:	e8840993          	addi	s3,s0,-376
    80004f9c:	f8840c93          	addi	s9,s0,-120
    80004fa0:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	d94080e7          	jalr	-620(ra) # 80000d36 <strlen>
    80004faa:	2505                	addiw	a0,a0,1
    80004fac:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fae:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80004fb0:	1154e163          	bltu	s1,s5,800050b2 <exec+0x36c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fb4:	e0043b03          	ld	s6,-512(s0)
    80004fb8:	000b3a03          	ld	s4,0(s6)
    80004fbc:	8552                	mv	a0,s4
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	d78080e7          	jalr	-648(ra) # 80000d36 <strlen>
    80004fc6:	0015069b          	addiw	a3,a0,1
    80004fca:	8652                	mv	a2,s4
    80004fcc:	85a6                	mv	a1,s1
    80004fce:	8562                	mv	a0,s8
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	570080e7          	jalr	1392(ra) # 80001540 <copyout>
    80004fd8:	0c054f63          	bltz	a0,800050b6 <exec+0x370>
    ustack[argc] = sp;
    80004fdc:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004fe0:	0905                	addi	s2,s2,1
    80004fe2:	008b0793          	addi	a5,s6,8
    80004fe6:	e0f43023          	sd	a5,-512(s0)
    80004fea:	008b3503          	ld	a0,8(s6)
    80004fee:	c909                	beqz	a0,80005000 <exec+0x2ba>
    if(argc >= MAXARG)
    80004ff0:	09a1                	addi	s3,s3,8
    80004ff2:	fb3c98e3          	bne	s9,s3,80004fa2 <exec+0x25c>
  ip = 0;
    80004ff6:	4481                	li	s1,0
    80004ff8:	b7bd                	j	80004f66 <exec+0x220>
  sp = sz;
    80004ffa:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004ffe:	4901                	li	s2,0
  ustack[argc] = 0;
    80005000:	00391793          	slli	a5,s2,0x3
    80005004:	f9040713          	addi	a4,s0,-112
    80005008:	97ba                	add	a5,a5,a4
    8000500a:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5e9c>
  sp -= (argc+1) * sizeof(uint64);
    8000500e:	00190693          	addi	a3,s2,1
    80005012:	068e                	slli	a3,a3,0x3
    80005014:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80005016:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    8000501a:	4481                	li	s1,0
  if(sp < stackbase)
    8000501c:	f559e5e3          	bltu	s3,s5,80004f66 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005020:	e8840613          	addi	a2,s0,-376
    80005024:	85ce                	mv	a1,s3
    80005026:	8562                	mv	a0,s8
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	518080e7          	jalr	1304(ra) # 80001540 <copyout>
    80005030:	08054563          	bltz	a0,800050ba <exec+0x374>
  p->tf->a1 = sp;
    80005034:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    80005038:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    8000503c:	df843783          	ld	a5,-520(s0)
    80005040:	0007c703          	lbu	a4,0(a5)
    80005044:	cf11                	beqz	a4,80005060 <exec+0x31a>
    80005046:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005048:	02f00693          	li	a3,47
    8000504c:	a029                	j	80005056 <exec+0x310>
  for(last=s=path; *s; s++)
    8000504e:	0785                	addi	a5,a5,1
    80005050:	fff7c703          	lbu	a4,-1(a5)
    80005054:	c711                	beqz	a4,80005060 <exec+0x31a>
    if(*s == '/')
    80005056:	fed71ce3          	bne	a4,a3,8000504e <exec+0x308>
      last = s+1;
    8000505a:	def43c23          	sd	a5,-520(s0)
    8000505e:	bfc5                	j	8000504e <exec+0x308>
  safestrcpy(p->name, last, sizeof(p->name));
    80005060:	4641                	li	a2,16
    80005062:	df843583          	ld	a1,-520(s0)
    80005066:	160b8513          	addi	a0,s7,352
    8000506a:	ffffc097          	auipc	ra,0xffffc
    8000506e:	c9a080e7          	jalr	-870(ra) # 80000d04 <safestrcpy>
  oldpagetable = p->pagetable;
    80005072:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005076:	058bbc23          	sd	s8,88(s7)
  p->ustack=stackbase;
    8000507a:	055bb023          	sd	s5,64(s7)
  p->sz = sz;
    8000507e:	e0843783          	ld	a5,-504(s0)
    80005082:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005086:	060bb783          	ld	a5,96(s7)
    8000508a:	e6043703          	ld	a4,-416(s0)
    8000508e:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80005090:	060bb783          	ld	a5,96(s7)
    80005094:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005098:	85ea                	mv	a1,s10
    8000509a:	ffffd097          	auipc	ra,0xffffd
    8000509e:	a30080e7          	jalr	-1488(ra) # 80001aca <proc_freepagetable>
  vmprint(pagetable);
    800050a2:	8562                	mv	a0,s8
    800050a4:	ffffc097          	auipc	ra,0xffffc
    800050a8:	732080e7          	jalr	1842(ra) # 800017d6 <vmprint>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050ac:	0009051b          	sext.w	a0,s2
    800050b0:	bb0d                	j	80004de2 <exec+0x9c>
  ip = 0;
    800050b2:	4481                	li	s1,0
    800050b4:	bd4d                	j	80004f66 <exec+0x220>
    800050b6:	4481                	li	s1,0
    800050b8:	b57d                	j	80004f66 <exec+0x220>
    800050ba:	4481                	li	s1,0
    800050bc:	b56d                	j	80004f66 <exec+0x220>

00000000800050be <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050be:	7179                	addi	sp,sp,-48
    800050c0:	f406                	sd	ra,40(sp)
    800050c2:	f022                	sd	s0,32(sp)
    800050c4:	ec26                	sd	s1,24(sp)
    800050c6:	e84a                	sd	s2,16(sp)
    800050c8:	1800                	addi	s0,sp,48
    800050ca:	892e                	mv	s2,a1
    800050cc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050ce:	fdc40593          	addi	a1,s0,-36
    800050d2:	ffffe097          	auipc	ra,0xffffe
    800050d6:	996080e7          	jalr	-1642(ra) # 80002a68 <argint>
    800050da:	04054063          	bltz	a0,8000511a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050de:	fdc42703          	lw	a4,-36(s0)
    800050e2:	47bd                	li	a5,15
    800050e4:	02e7ed63          	bltu	a5,a4,8000511e <argfd+0x60>
    800050e8:	ffffd097          	auipc	ra,0xffffd
    800050ec:	81e080e7          	jalr	-2018(ra) # 80001906 <myproc>
    800050f0:	fdc42703          	lw	a4,-36(s0)
    800050f4:	01a70793          	addi	a5,a4,26
    800050f8:	078e                	slli	a5,a5,0x3
    800050fa:	953e                	add	a0,a0,a5
    800050fc:	651c                	ld	a5,8(a0)
    800050fe:	c395                	beqz	a5,80005122 <argfd+0x64>
    return -1;
  if(pfd)
    80005100:	00090463          	beqz	s2,80005108 <argfd+0x4a>
    *pfd = fd;
    80005104:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005108:	4501                	li	a0,0
  if(pf)
    8000510a:	c091                	beqz	s1,8000510e <argfd+0x50>
    *pf = f;
    8000510c:	e09c                	sd	a5,0(s1)
}
    8000510e:	70a2                	ld	ra,40(sp)
    80005110:	7402                	ld	s0,32(sp)
    80005112:	64e2                	ld	s1,24(sp)
    80005114:	6942                	ld	s2,16(sp)
    80005116:	6145                	addi	sp,sp,48
    80005118:	8082                	ret
    return -1;
    8000511a:	557d                	li	a0,-1
    8000511c:	bfcd                	j	8000510e <argfd+0x50>
    return -1;
    8000511e:	557d                	li	a0,-1
    80005120:	b7fd                	j	8000510e <argfd+0x50>
    80005122:	557d                	li	a0,-1
    80005124:	b7ed                	j	8000510e <argfd+0x50>

0000000080005126 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005126:	1101                	addi	sp,sp,-32
    80005128:	ec06                	sd	ra,24(sp)
    8000512a:	e822                	sd	s0,16(sp)
    8000512c:	e426                	sd	s1,8(sp)
    8000512e:	1000                	addi	s0,sp,32
    80005130:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005132:	ffffc097          	auipc	ra,0xffffc
    80005136:	7d4080e7          	jalr	2004(ra) # 80001906 <myproc>
    8000513a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000513c:	0d850793          	addi	a5,a0,216
    80005140:	4501                	li	a0,0
    80005142:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005144:	6398                	ld	a4,0(a5)
    80005146:	cb19                	beqz	a4,8000515c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005148:	2505                	addiw	a0,a0,1
    8000514a:	07a1                	addi	a5,a5,8
    8000514c:	fed51ce3          	bne	a0,a3,80005144 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005150:	557d                	li	a0,-1
}
    80005152:	60e2                	ld	ra,24(sp)
    80005154:	6442                	ld	s0,16(sp)
    80005156:	64a2                	ld	s1,8(sp)
    80005158:	6105                	addi	sp,sp,32
    8000515a:	8082                	ret
      p->ofile[fd] = f;
    8000515c:	01a50793          	addi	a5,a0,26
    80005160:	078e                	slli	a5,a5,0x3
    80005162:	963e                	add	a2,a2,a5
    80005164:	e604                	sd	s1,8(a2)
      return fd;
    80005166:	b7f5                	j	80005152 <fdalloc+0x2c>

0000000080005168 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005168:	715d                	addi	sp,sp,-80
    8000516a:	e486                	sd	ra,72(sp)
    8000516c:	e0a2                	sd	s0,64(sp)
    8000516e:	fc26                	sd	s1,56(sp)
    80005170:	f84a                	sd	s2,48(sp)
    80005172:	f44e                	sd	s3,40(sp)
    80005174:	f052                	sd	s4,32(sp)
    80005176:	ec56                	sd	s5,24(sp)
    80005178:	0880                	addi	s0,sp,80
    8000517a:	89ae                	mv	s3,a1
    8000517c:	8ab2                	mv	s5,a2
    8000517e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005180:	fb040593          	addi	a1,s0,-80
    80005184:	fffff097          	auipc	ra,0xfffff
    80005188:	c2c080e7          	jalr	-980(ra) # 80003db0 <nameiparent>
    8000518c:	892a                	mv	s2,a0
    8000518e:	12050e63          	beqz	a0,800052ca <create+0x162>
    return 0;

  ilock(dp);
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	474080e7          	jalr	1140(ra) # 80003606 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000519a:	4601                	li	a2,0
    8000519c:	fb040593          	addi	a1,s0,-80
    800051a0:	854a                	mv	a0,s2
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	91e080e7          	jalr	-1762(ra) # 80003ac0 <dirlookup>
    800051aa:	84aa                	mv	s1,a0
    800051ac:	c921                	beqz	a0,800051fc <create+0x94>
    iunlockput(dp);
    800051ae:	854a                	mv	a0,s2
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	694080e7          	jalr	1684(ra) # 80003844 <iunlockput>
    ilock(ip);
    800051b8:	8526                	mv	a0,s1
    800051ba:	ffffe097          	auipc	ra,0xffffe
    800051be:	44c080e7          	jalr	1100(ra) # 80003606 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051c2:	2981                	sext.w	s3,s3
    800051c4:	4789                	li	a5,2
    800051c6:	02f99463          	bne	s3,a5,800051ee <create+0x86>
    800051ca:	0444d783          	lhu	a5,68(s1)
    800051ce:	37f9                	addiw	a5,a5,-2
    800051d0:	17c2                	slli	a5,a5,0x30
    800051d2:	93c1                	srli	a5,a5,0x30
    800051d4:	4705                	li	a4,1
    800051d6:	00f76c63          	bltu	a4,a5,800051ee <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051da:	8526                	mv	a0,s1
    800051dc:	60a6                	ld	ra,72(sp)
    800051de:	6406                	ld	s0,64(sp)
    800051e0:	74e2                	ld	s1,56(sp)
    800051e2:	7942                	ld	s2,48(sp)
    800051e4:	79a2                	ld	s3,40(sp)
    800051e6:	7a02                	ld	s4,32(sp)
    800051e8:	6ae2                	ld	s5,24(sp)
    800051ea:	6161                	addi	sp,sp,80
    800051ec:	8082                	ret
    iunlockput(ip);
    800051ee:	8526                	mv	a0,s1
    800051f0:	ffffe097          	auipc	ra,0xffffe
    800051f4:	654080e7          	jalr	1620(ra) # 80003844 <iunlockput>
    return 0;
    800051f8:	4481                	li	s1,0
    800051fa:	b7c5                	j	800051da <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051fc:	85ce                	mv	a1,s3
    800051fe:	00092503          	lw	a0,0(s2)
    80005202:	ffffe097          	auipc	ra,0xffffe
    80005206:	26c080e7          	jalr	620(ra) # 8000346e <ialloc>
    8000520a:	84aa                	mv	s1,a0
    8000520c:	c521                	beqz	a0,80005254 <create+0xec>
  ilock(ip);
    8000520e:	ffffe097          	auipc	ra,0xffffe
    80005212:	3f8080e7          	jalr	1016(ra) # 80003606 <ilock>
  ip->major = major;
    80005216:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000521a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000521e:	4a05                	li	s4,1
    80005220:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005224:	8526                	mv	a0,s1
    80005226:	ffffe097          	auipc	ra,0xffffe
    8000522a:	316080e7          	jalr	790(ra) # 8000353c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000522e:	2981                	sext.w	s3,s3
    80005230:	03498a63          	beq	s3,s4,80005264 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005234:	40d0                	lw	a2,4(s1)
    80005236:	fb040593          	addi	a1,s0,-80
    8000523a:	854a                	mv	a0,s2
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	a94080e7          	jalr	-1388(ra) # 80003cd0 <dirlink>
    80005244:	06054b63          	bltz	a0,800052ba <create+0x152>
  iunlockput(dp);
    80005248:	854a                	mv	a0,s2
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	5fa080e7          	jalr	1530(ra) # 80003844 <iunlockput>
  return ip;
    80005252:	b761                	j	800051da <create+0x72>
    panic("create: ialloc");
    80005254:	00003517          	auipc	a0,0x3
    80005258:	50c50513          	addi	a0,a0,1292 # 80008760 <userret+0x6d0>
    8000525c:	ffffb097          	auipc	ra,0xffffb
    80005260:	2f2080e7          	jalr	754(ra) # 8000054e <panic>
    dp->nlink++;  // for ".."
    80005264:	04a95783          	lhu	a5,74(s2)
    80005268:	2785                	addiw	a5,a5,1
    8000526a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000526e:	854a                	mv	a0,s2
    80005270:	ffffe097          	auipc	ra,0xffffe
    80005274:	2cc080e7          	jalr	716(ra) # 8000353c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005278:	40d0                	lw	a2,4(s1)
    8000527a:	00003597          	auipc	a1,0x3
    8000527e:	4f658593          	addi	a1,a1,1270 # 80008770 <userret+0x6e0>
    80005282:	8526                	mv	a0,s1
    80005284:	fffff097          	auipc	ra,0xfffff
    80005288:	a4c080e7          	jalr	-1460(ra) # 80003cd0 <dirlink>
    8000528c:	00054f63          	bltz	a0,800052aa <create+0x142>
    80005290:	00492603          	lw	a2,4(s2)
    80005294:	00003597          	auipc	a1,0x3
    80005298:	4e458593          	addi	a1,a1,1252 # 80008778 <userret+0x6e8>
    8000529c:	8526                	mv	a0,s1
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	a32080e7          	jalr	-1486(ra) # 80003cd0 <dirlink>
    800052a6:	f80557e3          	bgez	a0,80005234 <create+0xcc>
      panic("create dots");
    800052aa:	00003517          	auipc	a0,0x3
    800052ae:	4d650513          	addi	a0,a0,1238 # 80008780 <userret+0x6f0>
    800052b2:	ffffb097          	auipc	ra,0xffffb
    800052b6:	29c080e7          	jalr	668(ra) # 8000054e <panic>
    panic("create: dirlink");
    800052ba:	00003517          	auipc	a0,0x3
    800052be:	4d650513          	addi	a0,a0,1238 # 80008790 <userret+0x700>
    800052c2:	ffffb097          	auipc	ra,0xffffb
    800052c6:	28c080e7          	jalr	652(ra) # 8000054e <panic>
    return 0;
    800052ca:	84aa                	mv	s1,a0
    800052cc:	b739                	j	800051da <create+0x72>

00000000800052ce <sys_dup>:
{
    800052ce:	7179                	addi	sp,sp,-48
    800052d0:	f406                	sd	ra,40(sp)
    800052d2:	f022                	sd	s0,32(sp)
    800052d4:	ec26                	sd	s1,24(sp)
    800052d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052d8:	fd840613          	addi	a2,s0,-40
    800052dc:	4581                	li	a1,0
    800052de:	4501                	li	a0,0
    800052e0:	00000097          	auipc	ra,0x0
    800052e4:	dde080e7          	jalr	-546(ra) # 800050be <argfd>
    return -1;
    800052e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052ea:	02054363          	bltz	a0,80005310 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800052ee:	fd843503          	ld	a0,-40(s0)
    800052f2:	00000097          	auipc	ra,0x0
    800052f6:	e34080e7          	jalr	-460(ra) # 80005126 <fdalloc>
    800052fa:	84aa                	mv	s1,a0
    return -1;
    800052fc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052fe:	00054963          	bltz	a0,80005310 <sys_dup+0x42>
  filedup(f);
    80005302:	fd843503          	ld	a0,-40(s0)
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	37e080e7          	jalr	894(ra) # 80004684 <filedup>
  return fd;
    8000530e:	87a6                	mv	a5,s1
}
    80005310:	853e                	mv	a0,a5
    80005312:	70a2                	ld	ra,40(sp)
    80005314:	7402                	ld	s0,32(sp)
    80005316:	64e2                	ld	s1,24(sp)
    80005318:	6145                	addi	sp,sp,48
    8000531a:	8082                	ret

000000008000531c <sys_read>:
{
    8000531c:	7179                	addi	sp,sp,-48
    8000531e:	f406                	sd	ra,40(sp)
    80005320:	f022                	sd	s0,32(sp)
    80005322:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005324:	fe840613          	addi	a2,s0,-24
    80005328:	4581                	li	a1,0
    8000532a:	4501                	li	a0,0
    8000532c:	00000097          	auipc	ra,0x0
    80005330:	d92080e7          	jalr	-622(ra) # 800050be <argfd>
    return -1;
    80005334:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005336:	04054163          	bltz	a0,80005378 <sys_read+0x5c>
    8000533a:	fe440593          	addi	a1,s0,-28
    8000533e:	4509                	li	a0,2
    80005340:	ffffd097          	auipc	ra,0xffffd
    80005344:	728080e7          	jalr	1832(ra) # 80002a68 <argint>
    return -1;
    80005348:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000534a:	02054763          	bltz	a0,80005378 <sys_read+0x5c>
    8000534e:	fd840593          	addi	a1,s0,-40
    80005352:	4505                	li	a0,1
    80005354:	ffffd097          	auipc	ra,0xffffd
    80005358:	736080e7          	jalr	1846(ra) # 80002a8a <argaddr>
    return -1;
    8000535c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000535e:	00054d63          	bltz	a0,80005378 <sys_read+0x5c>
  return fileread(f, p, n);
    80005362:	fe442603          	lw	a2,-28(s0)
    80005366:	fd843583          	ld	a1,-40(s0)
    8000536a:	fe843503          	ld	a0,-24(s0)
    8000536e:	fffff097          	auipc	ra,0xfffff
    80005372:	49a080e7          	jalr	1178(ra) # 80004808 <fileread>
    80005376:	87aa                	mv	a5,a0
}
    80005378:	853e                	mv	a0,a5
    8000537a:	70a2                	ld	ra,40(sp)
    8000537c:	7402                	ld	s0,32(sp)
    8000537e:	6145                	addi	sp,sp,48
    80005380:	8082                	ret

0000000080005382 <sys_write>:
{
    80005382:	7179                	addi	sp,sp,-48
    80005384:	f406                	sd	ra,40(sp)
    80005386:	f022                	sd	s0,32(sp)
    80005388:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000538a:	fe840613          	addi	a2,s0,-24
    8000538e:	4581                	li	a1,0
    80005390:	4501                	li	a0,0
    80005392:	00000097          	auipc	ra,0x0
    80005396:	d2c080e7          	jalr	-724(ra) # 800050be <argfd>
    return -1;
    8000539a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000539c:	04054163          	bltz	a0,800053de <sys_write+0x5c>
    800053a0:	fe440593          	addi	a1,s0,-28
    800053a4:	4509                	li	a0,2
    800053a6:	ffffd097          	auipc	ra,0xffffd
    800053aa:	6c2080e7          	jalr	1730(ra) # 80002a68 <argint>
    return -1;
    800053ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053b0:	02054763          	bltz	a0,800053de <sys_write+0x5c>
    800053b4:	fd840593          	addi	a1,s0,-40
    800053b8:	4505                	li	a0,1
    800053ba:	ffffd097          	auipc	ra,0xffffd
    800053be:	6d0080e7          	jalr	1744(ra) # 80002a8a <argaddr>
    return -1;
    800053c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c4:	00054d63          	bltz	a0,800053de <sys_write+0x5c>
  return filewrite(f, p, n);
    800053c8:	fe442603          	lw	a2,-28(s0)
    800053cc:	fd843583          	ld	a1,-40(s0)
    800053d0:	fe843503          	ld	a0,-24(s0)
    800053d4:	fffff097          	auipc	ra,0xfffff
    800053d8:	4e2080e7          	jalr	1250(ra) # 800048b6 <filewrite>
    800053dc:	87aa                	mv	a5,a0
}
    800053de:	853e                	mv	a0,a5
    800053e0:	70a2                	ld	ra,40(sp)
    800053e2:	7402                	ld	s0,32(sp)
    800053e4:	6145                	addi	sp,sp,48
    800053e6:	8082                	ret

00000000800053e8 <sys_close>:
{
    800053e8:	1101                	addi	sp,sp,-32
    800053ea:	ec06                	sd	ra,24(sp)
    800053ec:	e822                	sd	s0,16(sp)
    800053ee:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053f0:	fe040613          	addi	a2,s0,-32
    800053f4:	fec40593          	addi	a1,s0,-20
    800053f8:	4501                	li	a0,0
    800053fa:	00000097          	auipc	ra,0x0
    800053fe:	cc4080e7          	jalr	-828(ra) # 800050be <argfd>
    return -1;
    80005402:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005404:	02054463          	bltz	a0,8000542c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	4fe080e7          	jalr	1278(ra) # 80001906 <myproc>
    80005410:	fec42783          	lw	a5,-20(s0)
    80005414:	07e9                	addi	a5,a5,26
    80005416:	078e                	slli	a5,a5,0x3
    80005418:	97aa                	add	a5,a5,a0
    8000541a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000541e:	fe043503          	ld	a0,-32(s0)
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	2b4080e7          	jalr	692(ra) # 800046d6 <fileclose>
  return 0;
    8000542a:	4781                	li	a5,0
}
    8000542c:	853e                	mv	a0,a5
    8000542e:	60e2                	ld	ra,24(sp)
    80005430:	6442                	ld	s0,16(sp)
    80005432:	6105                	addi	sp,sp,32
    80005434:	8082                	ret

0000000080005436 <sys_fstat>:
{
    80005436:	1101                	addi	sp,sp,-32
    80005438:	ec06                	sd	ra,24(sp)
    8000543a:	e822                	sd	s0,16(sp)
    8000543c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000543e:	fe840613          	addi	a2,s0,-24
    80005442:	4581                	li	a1,0
    80005444:	4501                	li	a0,0
    80005446:	00000097          	auipc	ra,0x0
    8000544a:	c78080e7          	jalr	-904(ra) # 800050be <argfd>
    return -1;
    8000544e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005450:	02054563          	bltz	a0,8000547a <sys_fstat+0x44>
    80005454:	fe040593          	addi	a1,s0,-32
    80005458:	4505                	li	a0,1
    8000545a:	ffffd097          	auipc	ra,0xffffd
    8000545e:	630080e7          	jalr	1584(ra) # 80002a8a <argaddr>
    return -1;
    80005462:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005464:	00054b63          	bltz	a0,8000547a <sys_fstat+0x44>
  return filestat(f, st);
    80005468:	fe043583          	ld	a1,-32(s0)
    8000546c:	fe843503          	ld	a0,-24(s0)
    80005470:	fffff097          	auipc	ra,0xfffff
    80005474:	326080e7          	jalr	806(ra) # 80004796 <filestat>
    80005478:	87aa                	mv	a5,a0
}
    8000547a:	853e                	mv	a0,a5
    8000547c:	60e2                	ld	ra,24(sp)
    8000547e:	6442                	ld	s0,16(sp)
    80005480:	6105                	addi	sp,sp,32
    80005482:	8082                	ret

0000000080005484 <sys_link>:
{
    80005484:	7169                	addi	sp,sp,-304
    80005486:	f606                	sd	ra,296(sp)
    80005488:	f222                	sd	s0,288(sp)
    8000548a:	ee26                	sd	s1,280(sp)
    8000548c:	ea4a                	sd	s2,272(sp)
    8000548e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005490:	08000613          	li	a2,128
    80005494:	ed040593          	addi	a1,s0,-304
    80005498:	4501                	li	a0,0
    8000549a:	ffffd097          	auipc	ra,0xffffd
    8000549e:	612080e7          	jalr	1554(ra) # 80002aac <argstr>
    return -1;
    800054a2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054a4:	12054363          	bltz	a0,800055ca <sys_link+0x146>
    800054a8:	08000613          	li	a2,128
    800054ac:	f5040593          	addi	a1,s0,-176
    800054b0:	4505                	li	a0,1
    800054b2:	ffffd097          	auipc	ra,0xffffd
    800054b6:	5fa080e7          	jalr	1530(ra) # 80002aac <argstr>
    return -1;
    800054ba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054bc:	10054763          	bltz	a0,800055ca <sys_link+0x146>
  begin_op(ROOTDEV);
    800054c0:	4501                	li	a0,0
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	bec080e7          	jalr	-1044(ra) # 800040ae <begin_op>
  if((ip = namei(old)) == 0){
    800054ca:	ed040513          	addi	a0,s0,-304
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	8c4080e7          	jalr	-1852(ra) # 80003d92 <namei>
    800054d6:	84aa                	mv	s1,a0
    800054d8:	c559                	beqz	a0,80005566 <sys_link+0xe2>
  ilock(ip);
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	12c080e7          	jalr	300(ra) # 80003606 <ilock>
  if(ip->type == T_DIR){
    800054e2:	04449703          	lh	a4,68(s1)
    800054e6:	4785                	li	a5,1
    800054e8:	08f70663          	beq	a4,a5,80005574 <sys_link+0xf0>
  ip->nlink++;
    800054ec:	04a4d783          	lhu	a5,74(s1)
    800054f0:	2785                	addiw	a5,a5,1
    800054f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	044080e7          	jalr	68(ra) # 8000353c <iupdate>
  iunlock(ip);
    80005500:	8526                	mv	a0,s1
    80005502:	ffffe097          	auipc	ra,0xffffe
    80005506:	1c6080e7          	jalr	454(ra) # 800036c8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000550a:	fd040593          	addi	a1,s0,-48
    8000550e:	f5040513          	addi	a0,s0,-176
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	89e080e7          	jalr	-1890(ra) # 80003db0 <nameiparent>
    8000551a:	892a                	mv	s2,a0
    8000551c:	cd2d                	beqz	a0,80005596 <sys_link+0x112>
  ilock(dp);
    8000551e:	ffffe097          	auipc	ra,0xffffe
    80005522:	0e8080e7          	jalr	232(ra) # 80003606 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005526:	00092703          	lw	a4,0(s2)
    8000552a:	409c                	lw	a5,0(s1)
    8000552c:	06f71063          	bne	a4,a5,8000558c <sys_link+0x108>
    80005530:	40d0                	lw	a2,4(s1)
    80005532:	fd040593          	addi	a1,s0,-48
    80005536:	854a                	mv	a0,s2
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	798080e7          	jalr	1944(ra) # 80003cd0 <dirlink>
    80005540:	04054663          	bltz	a0,8000558c <sys_link+0x108>
  iunlockput(dp);
    80005544:	854a                	mv	a0,s2
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	2fe080e7          	jalr	766(ra) # 80003844 <iunlockput>
  iput(ip);
    8000554e:	8526                	mv	a0,s1
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	1c4080e7          	jalr	452(ra) # 80003714 <iput>
  end_op(ROOTDEV);
    80005558:	4501                	li	a0,0
    8000555a:	fffff097          	auipc	ra,0xfffff
    8000555e:	bfe080e7          	jalr	-1026(ra) # 80004158 <end_op>
  return 0;
    80005562:	4781                	li	a5,0
    80005564:	a09d                	j	800055ca <sys_link+0x146>
    end_op(ROOTDEV);
    80005566:	4501                	li	a0,0
    80005568:	fffff097          	auipc	ra,0xfffff
    8000556c:	bf0080e7          	jalr	-1040(ra) # 80004158 <end_op>
    return -1;
    80005570:	57fd                	li	a5,-1
    80005572:	a8a1                	j	800055ca <sys_link+0x146>
    iunlockput(ip);
    80005574:	8526                	mv	a0,s1
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	2ce080e7          	jalr	718(ra) # 80003844 <iunlockput>
    end_op(ROOTDEV);
    8000557e:	4501                	li	a0,0
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	bd8080e7          	jalr	-1064(ra) # 80004158 <end_op>
    return -1;
    80005588:	57fd                	li	a5,-1
    8000558a:	a081                	j	800055ca <sys_link+0x146>
    iunlockput(dp);
    8000558c:	854a                	mv	a0,s2
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	2b6080e7          	jalr	694(ra) # 80003844 <iunlockput>
  ilock(ip);
    80005596:	8526                	mv	a0,s1
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	06e080e7          	jalr	110(ra) # 80003606 <ilock>
  ip->nlink--;
    800055a0:	04a4d783          	lhu	a5,74(s1)
    800055a4:	37fd                	addiw	a5,a5,-1
    800055a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055aa:	8526                	mv	a0,s1
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	f90080e7          	jalr	-112(ra) # 8000353c <iupdate>
  iunlockput(ip);
    800055b4:	8526                	mv	a0,s1
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	28e080e7          	jalr	654(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    800055be:	4501                	li	a0,0
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	b98080e7          	jalr	-1128(ra) # 80004158 <end_op>
  return -1;
    800055c8:	57fd                	li	a5,-1
}
    800055ca:	853e                	mv	a0,a5
    800055cc:	70b2                	ld	ra,296(sp)
    800055ce:	7412                	ld	s0,288(sp)
    800055d0:	64f2                	ld	s1,280(sp)
    800055d2:	6952                	ld	s2,272(sp)
    800055d4:	6155                	addi	sp,sp,304
    800055d6:	8082                	ret

00000000800055d8 <sys_unlink>:
{
    800055d8:	7151                	addi	sp,sp,-240
    800055da:	f586                	sd	ra,232(sp)
    800055dc:	f1a2                	sd	s0,224(sp)
    800055de:	eda6                	sd	s1,216(sp)
    800055e0:	e9ca                	sd	s2,208(sp)
    800055e2:	e5ce                	sd	s3,200(sp)
    800055e4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055e6:	08000613          	li	a2,128
    800055ea:	f3040593          	addi	a1,s0,-208
    800055ee:	4501                	li	a0,0
    800055f0:	ffffd097          	auipc	ra,0xffffd
    800055f4:	4bc080e7          	jalr	1212(ra) # 80002aac <argstr>
    800055f8:	18054463          	bltz	a0,80005780 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800055fc:	4501                	li	a0,0
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	ab0080e7          	jalr	-1360(ra) # 800040ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005606:	fb040593          	addi	a1,s0,-80
    8000560a:	f3040513          	addi	a0,s0,-208
    8000560e:	ffffe097          	auipc	ra,0xffffe
    80005612:	7a2080e7          	jalr	1954(ra) # 80003db0 <nameiparent>
    80005616:	84aa                	mv	s1,a0
    80005618:	cd61                	beqz	a0,800056f0 <sys_unlink+0x118>
  ilock(dp);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	fec080e7          	jalr	-20(ra) # 80003606 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005622:	00003597          	auipc	a1,0x3
    80005626:	14e58593          	addi	a1,a1,334 # 80008770 <userret+0x6e0>
    8000562a:	fb040513          	addi	a0,s0,-80
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	478080e7          	jalr	1144(ra) # 80003aa6 <namecmp>
    80005636:	14050c63          	beqz	a0,8000578e <sys_unlink+0x1b6>
    8000563a:	00003597          	auipc	a1,0x3
    8000563e:	13e58593          	addi	a1,a1,318 # 80008778 <userret+0x6e8>
    80005642:	fb040513          	addi	a0,s0,-80
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	460080e7          	jalr	1120(ra) # 80003aa6 <namecmp>
    8000564e:	14050063          	beqz	a0,8000578e <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005652:	f2c40613          	addi	a2,s0,-212
    80005656:	fb040593          	addi	a1,s0,-80
    8000565a:	8526                	mv	a0,s1
    8000565c:	ffffe097          	auipc	ra,0xffffe
    80005660:	464080e7          	jalr	1124(ra) # 80003ac0 <dirlookup>
    80005664:	892a                	mv	s2,a0
    80005666:	12050463          	beqz	a0,8000578e <sys_unlink+0x1b6>
  ilock(ip);
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	f9c080e7          	jalr	-100(ra) # 80003606 <ilock>
  if(ip->nlink < 1)
    80005672:	04a91783          	lh	a5,74(s2)
    80005676:	08f05463          	blez	a5,800056fe <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000567a:	04491703          	lh	a4,68(s2)
    8000567e:	4785                	li	a5,1
    80005680:	08f70763          	beq	a4,a5,8000570e <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005684:	4641                	li	a2,16
    80005686:	4581                	li	a1,0
    80005688:	fc040513          	addi	a0,s0,-64
    8000568c:	ffffb097          	auipc	ra,0xffffb
    80005690:	522080e7          	jalr	1314(ra) # 80000bae <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005694:	4741                	li	a4,16
    80005696:	f2c42683          	lw	a3,-212(s0)
    8000569a:	fc040613          	addi	a2,s0,-64
    8000569e:	4581                	li	a1,0
    800056a0:	8526                	mv	a0,s1
    800056a2:	ffffe097          	auipc	ra,0xffffe
    800056a6:	2e8080e7          	jalr	744(ra) # 8000398a <writei>
    800056aa:	47c1                	li	a5,16
    800056ac:	0af51763          	bne	a0,a5,8000575a <sys_unlink+0x182>
  if(ip->type == T_DIR){
    800056b0:	04491703          	lh	a4,68(s2)
    800056b4:	4785                	li	a5,1
    800056b6:	0af70a63          	beq	a4,a5,8000576a <sys_unlink+0x192>
  iunlockput(dp);
    800056ba:	8526                	mv	a0,s1
    800056bc:	ffffe097          	auipc	ra,0xffffe
    800056c0:	188080e7          	jalr	392(ra) # 80003844 <iunlockput>
  ip->nlink--;
    800056c4:	04a95783          	lhu	a5,74(s2)
    800056c8:	37fd                	addiw	a5,a5,-1
    800056ca:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056ce:	854a                	mv	a0,s2
    800056d0:	ffffe097          	auipc	ra,0xffffe
    800056d4:	e6c080e7          	jalr	-404(ra) # 8000353c <iupdate>
  iunlockput(ip);
    800056d8:	854a                	mv	a0,s2
    800056da:	ffffe097          	auipc	ra,0xffffe
    800056de:	16a080e7          	jalr	362(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    800056e2:	4501                	li	a0,0
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	a74080e7          	jalr	-1420(ra) # 80004158 <end_op>
  return 0;
    800056ec:	4501                	li	a0,0
    800056ee:	a85d                	j	800057a4 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800056f0:	4501                	li	a0,0
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	a66080e7          	jalr	-1434(ra) # 80004158 <end_op>
    return -1;
    800056fa:	557d                	li	a0,-1
    800056fc:	a065                	j	800057a4 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800056fe:	00003517          	auipc	a0,0x3
    80005702:	0a250513          	addi	a0,a0,162 # 800087a0 <userret+0x710>
    80005706:	ffffb097          	auipc	ra,0xffffb
    8000570a:	e48080e7          	jalr	-440(ra) # 8000054e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000570e:	04c92703          	lw	a4,76(s2)
    80005712:	02000793          	li	a5,32
    80005716:	f6e7f7e3          	bgeu	a5,a4,80005684 <sys_unlink+0xac>
    8000571a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000571e:	4741                	li	a4,16
    80005720:	86ce                	mv	a3,s3
    80005722:	f1840613          	addi	a2,s0,-232
    80005726:	4581                	li	a1,0
    80005728:	854a                	mv	a0,s2
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	16c080e7          	jalr	364(ra) # 80003896 <readi>
    80005732:	47c1                	li	a5,16
    80005734:	00f51b63          	bne	a0,a5,8000574a <sys_unlink+0x172>
    if(de.inum != 0)
    80005738:	f1845783          	lhu	a5,-232(s0)
    8000573c:	e7a1                	bnez	a5,80005784 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000573e:	29c1                	addiw	s3,s3,16
    80005740:	04c92783          	lw	a5,76(s2)
    80005744:	fcf9ede3          	bltu	s3,a5,8000571e <sys_unlink+0x146>
    80005748:	bf35                	j	80005684 <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000574a:	00003517          	auipc	a0,0x3
    8000574e:	06e50513          	addi	a0,a0,110 # 800087b8 <userret+0x728>
    80005752:	ffffb097          	auipc	ra,0xffffb
    80005756:	dfc080e7          	jalr	-516(ra) # 8000054e <panic>
    panic("unlink: writei");
    8000575a:	00003517          	auipc	a0,0x3
    8000575e:	07650513          	addi	a0,a0,118 # 800087d0 <userret+0x740>
    80005762:	ffffb097          	auipc	ra,0xffffb
    80005766:	dec080e7          	jalr	-532(ra) # 8000054e <panic>
    dp->nlink--;
    8000576a:	04a4d783          	lhu	a5,74(s1)
    8000576e:	37fd                	addiw	a5,a5,-1
    80005770:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005774:	8526                	mv	a0,s1
    80005776:	ffffe097          	auipc	ra,0xffffe
    8000577a:	dc6080e7          	jalr	-570(ra) # 8000353c <iupdate>
    8000577e:	bf35                	j	800056ba <sys_unlink+0xe2>
    return -1;
    80005780:	557d                	li	a0,-1
    80005782:	a00d                	j	800057a4 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005784:	854a                	mv	a0,s2
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	0be080e7          	jalr	190(ra) # 80003844 <iunlockput>
  iunlockput(dp);
    8000578e:	8526                	mv	a0,s1
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	0b4080e7          	jalr	180(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    80005798:	4501                	li	a0,0
    8000579a:	fffff097          	auipc	ra,0xfffff
    8000579e:	9be080e7          	jalr	-1602(ra) # 80004158 <end_op>
  return -1;
    800057a2:	557d                	li	a0,-1
}
    800057a4:	70ae                	ld	ra,232(sp)
    800057a6:	740e                	ld	s0,224(sp)
    800057a8:	64ee                	ld	s1,216(sp)
    800057aa:	694e                	ld	s2,208(sp)
    800057ac:	69ae                	ld	s3,200(sp)
    800057ae:	616d                	addi	sp,sp,240
    800057b0:	8082                	ret

00000000800057b2 <sys_open>:

uint64
sys_open(void)
{
    800057b2:	7131                	addi	sp,sp,-192
    800057b4:	fd06                	sd	ra,184(sp)
    800057b6:	f922                	sd	s0,176(sp)
    800057b8:	f526                	sd	s1,168(sp)
    800057ba:	f14a                	sd	s2,160(sp)
    800057bc:	ed4e                	sd	s3,152(sp)
    800057be:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057c0:	08000613          	li	a2,128
    800057c4:	f5040593          	addi	a1,s0,-176
    800057c8:	4501                	li	a0,0
    800057ca:	ffffd097          	auipc	ra,0xffffd
    800057ce:	2e2080e7          	jalr	738(ra) # 80002aac <argstr>
    return -1;
    800057d2:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057d4:	0a054963          	bltz	a0,80005886 <sys_open+0xd4>
    800057d8:	f4c40593          	addi	a1,s0,-180
    800057dc:	4505                	li	a0,1
    800057de:	ffffd097          	auipc	ra,0xffffd
    800057e2:	28a080e7          	jalr	650(ra) # 80002a68 <argint>
    800057e6:	0a054063          	bltz	a0,80005886 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800057ea:	4501                	li	a0,0
    800057ec:	fffff097          	auipc	ra,0xfffff
    800057f0:	8c2080e7          	jalr	-1854(ra) # 800040ae <begin_op>

  if(omode & O_CREATE){
    800057f4:	f4c42783          	lw	a5,-180(s0)
    800057f8:	2007f793          	andi	a5,a5,512
    800057fc:	c3dd                	beqz	a5,800058a2 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800057fe:	4681                	li	a3,0
    80005800:	4601                	li	a2,0
    80005802:	4589                	li	a1,2
    80005804:	f5040513          	addi	a0,s0,-176
    80005808:	00000097          	auipc	ra,0x0
    8000580c:	960080e7          	jalr	-1696(ra) # 80005168 <create>
    80005810:	892a                	mv	s2,a0
    if(ip == 0){
    80005812:	c151                	beqz	a0,80005896 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005814:	04491703          	lh	a4,68(s2)
    80005818:	478d                	li	a5,3
    8000581a:	00f71763          	bne	a4,a5,80005828 <sys_open+0x76>
    8000581e:	04695703          	lhu	a4,70(s2)
    80005822:	47a5                	li	a5,9
    80005824:	0ce7e663          	bltu	a5,a4,800058f0 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	df2080e7          	jalr	-526(ra) # 8000461a <filealloc>
    80005830:	89aa                	mv	s3,a0
    80005832:	c57d                	beqz	a0,80005920 <sys_open+0x16e>
    80005834:	00000097          	auipc	ra,0x0
    80005838:	8f2080e7          	jalr	-1806(ra) # 80005126 <fdalloc>
    8000583c:	84aa                	mv	s1,a0
    8000583e:	0c054c63          	bltz	a0,80005916 <sys_open+0x164>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005842:	04491703          	lh	a4,68(s2)
    80005846:	478d                	li	a5,3
    80005848:	0cf70063          	beq	a4,a5,80005908 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000584c:	4789                	li	a5,2
    8000584e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005852:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005856:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000585a:	f4c42783          	lw	a5,-180(s0)
    8000585e:	0017c713          	xori	a4,a5,1
    80005862:	8b05                	andi	a4,a4,1
    80005864:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005868:	8b8d                	andi	a5,a5,3
    8000586a:	00f037b3          	snez	a5,a5
    8000586e:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005872:	854a                	mv	a0,s2
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	e54080e7          	jalr	-428(ra) # 800036c8 <iunlock>
  end_op(ROOTDEV);
    8000587c:	4501                	li	a0,0
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	8da080e7          	jalr	-1830(ra) # 80004158 <end_op>

  return fd;
}
    80005886:	8526                	mv	a0,s1
    80005888:	70ea                	ld	ra,184(sp)
    8000588a:	744a                	ld	s0,176(sp)
    8000588c:	74aa                	ld	s1,168(sp)
    8000588e:	790a                	ld	s2,160(sp)
    80005890:	69ea                	ld	s3,152(sp)
    80005892:	6129                	addi	sp,sp,192
    80005894:	8082                	ret
      end_op(ROOTDEV);
    80005896:	4501                	li	a0,0
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	8c0080e7          	jalr	-1856(ra) # 80004158 <end_op>
      return -1;
    800058a0:	b7dd                	j	80005886 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    800058a2:	f5040513          	addi	a0,s0,-176
    800058a6:	ffffe097          	auipc	ra,0xffffe
    800058aa:	4ec080e7          	jalr	1260(ra) # 80003d92 <namei>
    800058ae:	892a                	mv	s2,a0
    800058b0:	c90d                	beqz	a0,800058e2 <sys_open+0x130>
    ilock(ip);
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	d54080e7          	jalr	-684(ra) # 80003606 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058ba:	04491703          	lh	a4,68(s2)
    800058be:	4785                	li	a5,1
    800058c0:	f4f71ae3          	bne	a4,a5,80005814 <sys_open+0x62>
    800058c4:	f4c42783          	lw	a5,-180(s0)
    800058c8:	d3a5                	beqz	a5,80005828 <sys_open+0x76>
      iunlockput(ip);
    800058ca:	854a                	mv	a0,s2
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	f78080e7          	jalr	-136(ra) # 80003844 <iunlockput>
      end_op(ROOTDEV);
    800058d4:	4501                	li	a0,0
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	882080e7          	jalr	-1918(ra) # 80004158 <end_op>
      return -1;
    800058de:	54fd                	li	s1,-1
    800058e0:	b75d                	j	80005886 <sys_open+0xd4>
      end_op(ROOTDEV);
    800058e2:	4501                	li	a0,0
    800058e4:	fffff097          	auipc	ra,0xfffff
    800058e8:	874080e7          	jalr	-1932(ra) # 80004158 <end_op>
      return -1;
    800058ec:	54fd                	li	s1,-1
    800058ee:	bf61                	j	80005886 <sys_open+0xd4>
    iunlockput(ip);
    800058f0:	854a                	mv	a0,s2
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	f52080e7          	jalr	-174(ra) # 80003844 <iunlockput>
    end_op(ROOTDEV);
    800058fa:	4501                	li	a0,0
    800058fc:	fffff097          	auipc	ra,0xfffff
    80005900:	85c080e7          	jalr	-1956(ra) # 80004158 <end_op>
    return -1;
    80005904:	54fd                	li	s1,-1
    80005906:	b741                	j	80005886 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005908:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000590c:	04691783          	lh	a5,70(s2)
    80005910:	02f99223          	sh	a5,36(s3)
    80005914:	b789                	j	80005856 <sys_open+0xa4>
      fileclose(f);
    80005916:	854e                	mv	a0,s3
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	dbe080e7          	jalr	-578(ra) # 800046d6 <fileclose>
    iunlockput(ip);
    80005920:	854a                	mv	a0,s2
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	f22080e7          	jalr	-222(ra) # 80003844 <iunlockput>
    end_op(ROOTDEV);
    8000592a:	4501                	li	a0,0
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	82c080e7          	jalr	-2004(ra) # 80004158 <end_op>
    return -1;
    80005934:	54fd                	li	s1,-1
    80005936:	bf81                	j	80005886 <sys_open+0xd4>

0000000080005938 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005938:	7175                	addi	sp,sp,-144
    8000593a:	e506                	sd	ra,136(sp)
    8000593c:	e122                	sd	s0,128(sp)
    8000593e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005940:	4501                	li	a0,0
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	76c080e7          	jalr	1900(ra) # 800040ae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000594a:	08000613          	li	a2,128
    8000594e:	f7040593          	addi	a1,s0,-144
    80005952:	4501                	li	a0,0
    80005954:	ffffd097          	auipc	ra,0xffffd
    80005958:	158080e7          	jalr	344(ra) # 80002aac <argstr>
    8000595c:	02054a63          	bltz	a0,80005990 <sys_mkdir+0x58>
    80005960:	4681                	li	a3,0
    80005962:	4601                	li	a2,0
    80005964:	4585                	li	a1,1
    80005966:	f7040513          	addi	a0,s0,-144
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	7fe080e7          	jalr	2046(ra) # 80005168 <create>
    80005972:	cd19                	beqz	a0,80005990 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005974:	ffffe097          	auipc	ra,0xffffe
    80005978:	ed0080e7          	jalr	-304(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    8000597c:	4501                	li	a0,0
    8000597e:	ffffe097          	auipc	ra,0xffffe
    80005982:	7da080e7          	jalr	2010(ra) # 80004158 <end_op>
  return 0;
    80005986:	4501                	li	a0,0
}
    80005988:	60aa                	ld	ra,136(sp)
    8000598a:	640a                	ld	s0,128(sp)
    8000598c:	6149                	addi	sp,sp,144
    8000598e:	8082                	ret
    end_op(ROOTDEV);
    80005990:	4501                	li	a0,0
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	7c6080e7          	jalr	1990(ra) # 80004158 <end_op>
    return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	b7f5                	j	80005988 <sys_mkdir+0x50>

000000008000599e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000599e:	7135                	addi	sp,sp,-160
    800059a0:	ed06                	sd	ra,152(sp)
    800059a2:	e922                	sd	s0,144(sp)
    800059a4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    800059a6:	4501                	li	a0,0
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	706080e7          	jalr	1798(ra) # 800040ae <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059b0:	08000613          	li	a2,128
    800059b4:	f7040593          	addi	a1,s0,-144
    800059b8:	4501                	li	a0,0
    800059ba:	ffffd097          	auipc	ra,0xffffd
    800059be:	0f2080e7          	jalr	242(ra) # 80002aac <argstr>
    800059c2:	04054b63          	bltz	a0,80005a18 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    800059c6:	f6c40593          	addi	a1,s0,-148
    800059ca:	4505                	li	a0,1
    800059cc:	ffffd097          	auipc	ra,0xffffd
    800059d0:	09c080e7          	jalr	156(ra) # 80002a68 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059d4:	04054263          	bltz	a0,80005a18 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    800059d8:	f6840593          	addi	a1,s0,-152
    800059dc:	4509                	li	a0,2
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	08a080e7          	jalr	138(ra) # 80002a68 <argint>
     argint(1, &major) < 0 ||
    800059e6:	02054963          	bltz	a0,80005a18 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059ea:	f6841683          	lh	a3,-152(s0)
    800059ee:	f6c41603          	lh	a2,-148(s0)
    800059f2:	458d                	li	a1,3
    800059f4:	f7040513          	addi	a0,s0,-144
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	770080e7          	jalr	1904(ra) # 80005168 <create>
     argint(2, &minor) < 0 ||
    80005a00:	cd01                	beqz	a0,80005a18 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005a02:	ffffe097          	auipc	ra,0xffffe
    80005a06:	e42080e7          	jalr	-446(ra) # 80003844 <iunlockput>
  end_op(ROOTDEV);
    80005a0a:	4501                	li	a0,0
    80005a0c:	ffffe097          	auipc	ra,0xffffe
    80005a10:	74c080e7          	jalr	1868(ra) # 80004158 <end_op>
  return 0;
    80005a14:	4501                	li	a0,0
    80005a16:	a039                	j	80005a24 <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005a18:	4501                	li	a0,0
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	73e080e7          	jalr	1854(ra) # 80004158 <end_op>
    return -1;
    80005a22:	557d                	li	a0,-1
}
    80005a24:	60ea                	ld	ra,152(sp)
    80005a26:	644a                	ld	s0,144(sp)
    80005a28:	610d                	addi	sp,sp,160
    80005a2a:	8082                	ret

0000000080005a2c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a2c:	7135                	addi	sp,sp,-160
    80005a2e:	ed06                	sd	ra,152(sp)
    80005a30:	e922                	sd	s0,144(sp)
    80005a32:	e526                	sd	s1,136(sp)
    80005a34:	e14a                	sd	s2,128(sp)
    80005a36:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a38:	ffffc097          	auipc	ra,0xffffc
    80005a3c:	ece080e7          	jalr	-306(ra) # 80001906 <myproc>
    80005a40:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005a42:	4501                	li	a0,0
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	66a080e7          	jalr	1642(ra) # 800040ae <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a4c:	08000613          	li	a2,128
    80005a50:	f6040593          	addi	a1,s0,-160
    80005a54:	4501                	li	a0,0
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	056080e7          	jalr	86(ra) # 80002aac <argstr>
    80005a5e:	04054c63          	bltz	a0,80005ab6 <sys_chdir+0x8a>
    80005a62:	f6040513          	addi	a0,s0,-160
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	32c080e7          	jalr	812(ra) # 80003d92 <namei>
    80005a6e:	84aa                	mv	s1,a0
    80005a70:	c139                	beqz	a0,80005ab6 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	b94080e7          	jalr	-1132(ra) # 80003606 <ilock>
  if(ip->type != T_DIR){
    80005a7a:	04449703          	lh	a4,68(s1)
    80005a7e:	4785                	li	a5,1
    80005a80:	04f71263          	bne	a4,a5,80005ac4 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	c42080e7          	jalr	-958(ra) # 800036c8 <iunlock>
  iput(p->cwd);
    80005a8e:	15893503          	ld	a0,344(s2)
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	c82080e7          	jalr	-894(ra) # 80003714 <iput>
  end_op(ROOTDEV);
    80005a9a:	4501                	li	a0,0
    80005a9c:	ffffe097          	auipc	ra,0xffffe
    80005aa0:	6bc080e7          	jalr	1724(ra) # 80004158 <end_op>
  p->cwd = ip;
    80005aa4:	14993c23          	sd	s1,344(s2)
  return 0;
    80005aa8:	4501                	li	a0,0
}
    80005aaa:	60ea                	ld	ra,152(sp)
    80005aac:	644a                	ld	s0,144(sp)
    80005aae:	64aa                	ld	s1,136(sp)
    80005ab0:	690a                	ld	s2,128(sp)
    80005ab2:	610d                	addi	sp,sp,160
    80005ab4:	8082                	ret
    end_op(ROOTDEV);
    80005ab6:	4501                	li	a0,0
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	6a0080e7          	jalr	1696(ra) # 80004158 <end_op>
    return -1;
    80005ac0:	557d                	li	a0,-1
    80005ac2:	b7e5                	j	80005aaa <sys_chdir+0x7e>
    iunlockput(ip);
    80005ac4:	8526                	mv	a0,s1
    80005ac6:	ffffe097          	auipc	ra,0xffffe
    80005aca:	d7e080e7          	jalr	-642(ra) # 80003844 <iunlockput>
    end_op(ROOTDEV);
    80005ace:	4501                	li	a0,0
    80005ad0:	ffffe097          	auipc	ra,0xffffe
    80005ad4:	688080e7          	jalr	1672(ra) # 80004158 <end_op>
    return -1;
    80005ad8:	557d                	li	a0,-1
    80005ada:	bfc1                	j	80005aaa <sys_chdir+0x7e>

0000000080005adc <sys_exec>:

uint64
sys_exec(void)
{
    80005adc:	7145                	addi	sp,sp,-464
    80005ade:	e786                	sd	ra,456(sp)
    80005ae0:	e3a2                	sd	s0,448(sp)
    80005ae2:	ff26                	sd	s1,440(sp)
    80005ae4:	fb4a                	sd	s2,432(sp)
    80005ae6:	f74e                	sd	s3,424(sp)
    80005ae8:	f352                	sd	s4,416(sp)
    80005aea:	ef56                	sd	s5,408(sp)
    80005aec:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005aee:	08000613          	li	a2,128
    80005af2:	f4040593          	addi	a1,s0,-192
    80005af6:	4501                	li	a0,0
    80005af8:	ffffd097          	auipc	ra,0xffffd
    80005afc:	fb4080e7          	jalr	-76(ra) # 80002aac <argstr>
    80005b00:	0c054863          	bltz	a0,80005bd0 <sys_exec+0xf4>
    80005b04:	e3840593          	addi	a1,s0,-456
    80005b08:	4505                	li	a0,1
    80005b0a:	ffffd097          	auipc	ra,0xffffd
    80005b0e:	f80080e7          	jalr	-128(ra) # 80002a8a <argaddr>
    80005b12:	0c054963          	bltz	a0,80005be4 <sys_exec+0x108>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005b16:	10000613          	li	a2,256
    80005b1a:	4581                	li	a1,0
    80005b1c:	e4040513          	addi	a0,s0,-448
    80005b20:	ffffb097          	auipc	ra,0xffffb
    80005b24:	08e080e7          	jalr	142(ra) # 80000bae <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b28:	e4040993          	addi	s3,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b2c:	894e                	mv	s2,s3
    80005b2e:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005b30:	02000a13          	li	s4,32
    80005b34:	00048a9b          	sext.w	s5,s1
      return -1;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b38:	00349513          	slli	a0,s1,0x3
    80005b3c:	e3040593          	addi	a1,s0,-464
    80005b40:	e3843783          	ld	a5,-456(s0)
    80005b44:	953e                	add	a0,a0,a5
    80005b46:	ffffd097          	auipc	ra,0xffffd
    80005b4a:	e88080e7          	jalr	-376(ra) # 800029ce <fetchaddr>
    80005b4e:	08054d63          	bltz	a0,80005be8 <sys_exec+0x10c>
      return -1;
    }
    if(uarg == 0){
    80005b52:	e3043783          	ld	a5,-464(s0)
    80005b56:	cb85                	beqz	a5,80005b86 <sys_exec+0xaa>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b58:	ffffb097          	auipc	ra,0xffffb
    80005b5c:	e20080e7          	jalr	-480(ra) # 80000978 <kalloc>
    80005b60:	85aa                	mv	a1,a0
    80005b62:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005b66:	cd29                	beqz	a0,80005bc0 <sys_exec+0xe4>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005b68:	6605                	lui	a2,0x1
    80005b6a:	e3043503          	ld	a0,-464(s0)
    80005b6e:	ffffd097          	auipc	ra,0xffffd
    80005b72:	eb2080e7          	jalr	-334(ra) # 80002a20 <fetchstr>
    80005b76:	06054b63          	bltz	a0,80005bec <sys_exec+0x110>
    if(i >= NELEM(argv)){
    80005b7a:	0485                	addi	s1,s1,1
    80005b7c:	0921                	addi	s2,s2,8
    80005b7e:	fb449be3          	bne	s1,s4,80005b34 <sys_exec+0x58>
      return -1;
    80005b82:	557d                	li	a0,-1
    80005b84:	a0b9                	j	80005bd2 <sys_exec+0xf6>
      argv[i] = 0;
    80005b86:	0a8e                	slli	s5,s5,0x3
    80005b88:	fc040793          	addi	a5,s0,-64
    80005b8c:	9abe                	add	s5,s5,a5
    80005b8e:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd5e24>
      return -1;
    }
  }

  int ret = exec(path, argv);
    80005b92:	e4040593          	addi	a1,s0,-448
    80005b96:	f4040513          	addi	a0,s0,-192
    80005b9a:	fffff097          	auipc	ra,0xfffff
    80005b9e:	1ac080e7          	jalr	428(ra) # 80004d46 <exec>
    80005ba2:	84aa                	mv	s1,a0

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba4:	10098913          	addi	s2,s3,256
    80005ba8:	0009b503          	ld	a0,0(s3)
    80005bac:	c901                	beqz	a0,80005bbc <sys_exec+0xe0>
    kfree(argv[i]);
    80005bae:	ffffb097          	auipc	ra,0xffffb
    80005bb2:	cb6080e7          	jalr	-842(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb6:	09a1                	addi	s3,s3,8
    80005bb8:	ff2998e3          	bne	s3,s2,80005ba8 <sys_exec+0xcc>

  return ret;
    80005bbc:	8526                	mv	a0,s1
    80005bbe:	a811                	j	80005bd2 <sys_exec+0xf6>
      panic("sys_exec kalloc");
    80005bc0:	00003517          	auipc	a0,0x3
    80005bc4:	c2050513          	addi	a0,a0,-992 # 800087e0 <userret+0x750>
    80005bc8:	ffffb097          	auipc	ra,0xffffb
    80005bcc:	986080e7          	jalr	-1658(ra) # 8000054e <panic>
    return -1;
    80005bd0:	557d                	li	a0,-1
}
    80005bd2:	60be                	ld	ra,456(sp)
    80005bd4:	641e                	ld	s0,448(sp)
    80005bd6:	74fa                	ld	s1,440(sp)
    80005bd8:	795a                	ld	s2,432(sp)
    80005bda:	79ba                	ld	s3,424(sp)
    80005bdc:	7a1a                	ld	s4,416(sp)
    80005bde:	6afa                	ld	s5,408(sp)
    80005be0:	6179                	addi	sp,sp,464
    80005be2:	8082                	ret
    return -1;
    80005be4:	557d                	li	a0,-1
    80005be6:	b7f5                	j	80005bd2 <sys_exec+0xf6>
      return -1;
    80005be8:	557d                	li	a0,-1
    80005bea:	b7e5                	j	80005bd2 <sys_exec+0xf6>
      return -1;
    80005bec:	557d                	li	a0,-1
    80005bee:	b7d5                	j	80005bd2 <sys_exec+0xf6>

0000000080005bf0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bf0:	7139                	addi	sp,sp,-64
    80005bf2:	fc06                	sd	ra,56(sp)
    80005bf4:	f822                	sd	s0,48(sp)
    80005bf6:	f426                	sd	s1,40(sp)
    80005bf8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bfa:	ffffc097          	auipc	ra,0xffffc
    80005bfe:	d0c080e7          	jalr	-756(ra) # 80001906 <myproc>
    80005c02:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005c04:	fd840593          	addi	a1,s0,-40
    80005c08:	4501                	li	a0,0
    80005c0a:	ffffd097          	auipc	ra,0xffffd
    80005c0e:	e80080e7          	jalr	-384(ra) # 80002a8a <argaddr>
    return -1;
    80005c12:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005c14:	0e054063          	bltz	a0,80005cf4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005c18:	fc840593          	addi	a1,s0,-56
    80005c1c:	fd040513          	addi	a0,s0,-48
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	dda080e7          	jalr	-550(ra) # 800049fa <pipealloc>
    return -1;
    80005c28:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c2a:	0c054563          	bltz	a0,80005cf4 <sys_pipe+0x104>
  fd0 = -1;
    80005c2e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c32:	fd043503          	ld	a0,-48(s0)
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	4f0080e7          	jalr	1264(ra) # 80005126 <fdalloc>
    80005c3e:	fca42223          	sw	a0,-60(s0)
    80005c42:	08054c63          	bltz	a0,80005cda <sys_pipe+0xea>
    80005c46:	fc843503          	ld	a0,-56(s0)
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	4dc080e7          	jalr	1244(ra) # 80005126 <fdalloc>
    80005c52:	fca42023          	sw	a0,-64(s0)
    80005c56:	06054863          	bltz	a0,80005cc6 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c5a:	4691                	li	a3,4
    80005c5c:	fc440613          	addi	a2,s0,-60
    80005c60:	fd843583          	ld	a1,-40(s0)
    80005c64:	6ca8                	ld	a0,88(s1)
    80005c66:	ffffc097          	auipc	ra,0xffffc
    80005c6a:	8da080e7          	jalr	-1830(ra) # 80001540 <copyout>
    80005c6e:	02054063          	bltz	a0,80005c8e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c72:	4691                	li	a3,4
    80005c74:	fc040613          	addi	a2,s0,-64
    80005c78:	fd843583          	ld	a1,-40(s0)
    80005c7c:	0591                	addi	a1,a1,4
    80005c7e:	6ca8                	ld	a0,88(s1)
    80005c80:	ffffc097          	auipc	ra,0xffffc
    80005c84:	8c0080e7          	jalr	-1856(ra) # 80001540 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c88:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c8a:	06055563          	bgez	a0,80005cf4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c8e:	fc442783          	lw	a5,-60(s0)
    80005c92:	07e9                	addi	a5,a5,26
    80005c94:	078e                	slli	a5,a5,0x3
    80005c96:	97a6                	add	a5,a5,s1
    80005c98:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005c9c:	fc042503          	lw	a0,-64(s0)
    80005ca0:	0569                	addi	a0,a0,26
    80005ca2:	050e                	slli	a0,a0,0x3
    80005ca4:	9526                	add	a0,a0,s1
    80005ca6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005caa:	fd043503          	ld	a0,-48(s0)
    80005cae:	fffff097          	auipc	ra,0xfffff
    80005cb2:	a28080e7          	jalr	-1496(ra) # 800046d6 <fileclose>
    fileclose(wf);
    80005cb6:	fc843503          	ld	a0,-56(s0)
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	a1c080e7          	jalr	-1508(ra) # 800046d6 <fileclose>
    return -1;
    80005cc2:	57fd                	li	a5,-1
    80005cc4:	a805                	j	80005cf4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005cc6:	fc442783          	lw	a5,-60(s0)
    80005cca:	0007c863          	bltz	a5,80005cda <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cce:	01a78513          	addi	a0,a5,26
    80005cd2:	050e                	slli	a0,a0,0x3
    80005cd4:	9526                	add	a0,a0,s1
    80005cd6:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005cda:	fd043503          	ld	a0,-48(s0)
    80005cde:	fffff097          	auipc	ra,0xfffff
    80005ce2:	9f8080e7          	jalr	-1544(ra) # 800046d6 <fileclose>
    fileclose(wf);
    80005ce6:	fc843503          	ld	a0,-56(s0)
    80005cea:	fffff097          	auipc	ra,0xfffff
    80005cee:	9ec080e7          	jalr	-1556(ra) # 800046d6 <fileclose>
    return -1;
    80005cf2:	57fd                	li	a5,-1
}
    80005cf4:	853e                	mv	a0,a5
    80005cf6:	70e2                	ld	ra,56(sp)
    80005cf8:	7442                	ld	s0,48(sp)
    80005cfa:	74a2                	ld	s1,40(sp)
    80005cfc:	6121                	addi	sp,sp,64
    80005cfe:	8082                	ret

0000000080005d00 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005d00:	7171                	addi	sp,sp,-176
    80005d02:	f506                	sd	ra,168(sp)
    80005d04:	f122                	sd	s0,160(sp)
    80005d06:	ed26                	sd	s1,152(sp)
    80005d08:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005d0a:	08000613          	li	a2,128
    80005d0e:	f6040593          	addi	a1,s0,-160
    80005d12:	4501                	li	a0,0
    80005d14:	ffffd097          	auipc	ra,0xffffd
    80005d18:	d98080e7          	jalr	-616(ra) # 80002aac <argstr>
    return -1;
    80005d1c:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005d1e:	04054363          	bltz	a0,80005d64 <sys_crash+0x64>
    80005d22:	f5c40593          	addi	a1,s0,-164
    80005d26:	4505                	li	a0,1
    80005d28:	ffffd097          	auipc	ra,0xffffd
    80005d2c:	d40080e7          	jalr	-704(ra) # 80002a68 <argint>
    return -1;
    80005d30:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005d32:	02054963          	bltz	a0,80005d64 <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005d36:	4681                	li	a3,0
    80005d38:	4601                	li	a2,0
    80005d3a:	4589                	li	a1,2
    80005d3c:	f6040513          	addi	a0,s0,-160
    80005d40:	fffff097          	auipc	ra,0xfffff
    80005d44:	428080e7          	jalr	1064(ra) # 80005168 <create>
    80005d48:	84aa                	mv	s1,a0
  if(ip == 0){
    80005d4a:	c11d                	beqz	a0,80005d70 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	af8080e7          	jalr	-1288(ra) # 80003844 <iunlockput>
  crash_op(ip->dev, crash);
    80005d54:	f5c42583          	lw	a1,-164(s0)
    80005d58:	4088                	lw	a0,0(s1)
    80005d5a:	ffffe097          	auipc	ra,0xffffe
    80005d5e:	650080e7          	jalr	1616(ra) # 800043aa <crash_op>
  return 0;
    80005d62:	4781                	li	a5,0
}
    80005d64:	853e                	mv	a0,a5
    80005d66:	70aa                	ld	ra,168(sp)
    80005d68:	740a                	ld	s0,160(sp)
    80005d6a:	64ea                	ld	s1,152(sp)
    80005d6c:	614d                	addi	sp,sp,176
    80005d6e:	8082                	ret
    return -1;
    80005d70:	57fd                	li	a5,-1
    80005d72:	bfcd                	j	80005d64 <sys_crash+0x64>
	...

0000000080005d80 <kernelvec>:
    80005d80:	7111                	addi	sp,sp,-256
    80005d82:	e006                	sd	ra,0(sp)
    80005d84:	e40a                	sd	sp,8(sp)
    80005d86:	e80e                	sd	gp,16(sp)
    80005d88:	ec12                	sd	tp,24(sp)
    80005d8a:	f016                	sd	t0,32(sp)
    80005d8c:	f41a                	sd	t1,40(sp)
    80005d8e:	f81e                	sd	t2,48(sp)
    80005d90:	fc22                	sd	s0,56(sp)
    80005d92:	e0a6                	sd	s1,64(sp)
    80005d94:	e4aa                	sd	a0,72(sp)
    80005d96:	e8ae                	sd	a1,80(sp)
    80005d98:	ecb2                	sd	a2,88(sp)
    80005d9a:	f0b6                	sd	a3,96(sp)
    80005d9c:	f4ba                	sd	a4,104(sp)
    80005d9e:	f8be                	sd	a5,112(sp)
    80005da0:	fcc2                	sd	a6,120(sp)
    80005da2:	e146                	sd	a7,128(sp)
    80005da4:	e54a                	sd	s2,136(sp)
    80005da6:	e94e                	sd	s3,144(sp)
    80005da8:	ed52                	sd	s4,152(sp)
    80005daa:	f156                	sd	s5,160(sp)
    80005dac:	f55a                	sd	s6,168(sp)
    80005dae:	f95e                	sd	s7,176(sp)
    80005db0:	fd62                	sd	s8,184(sp)
    80005db2:	e1e6                	sd	s9,192(sp)
    80005db4:	e5ea                	sd	s10,200(sp)
    80005db6:	e9ee                	sd	s11,208(sp)
    80005db8:	edf2                	sd	t3,216(sp)
    80005dba:	f1f6                	sd	t4,224(sp)
    80005dbc:	f5fa                	sd	t5,232(sp)
    80005dbe:	f9fe                	sd	t6,240(sp)
    80005dc0:	adbfc0ef          	jal	ra,8000289a <kerneltrap>
    80005dc4:	6082                	ld	ra,0(sp)
    80005dc6:	6122                	ld	sp,8(sp)
    80005dc8:	61c2                	ld	gp,16(sp)
    80005dca:	7282                	ld	t0,32(sp)
    80005dcc:	7322                	ld	t1,40(sp)
    80005dce:	73c2                	ld	t2,48(sp)
    80005dd0:	7462                	ld	s0,56(sp)
    80005dd2:	6486                	ld	s1,64(sp)
    80005dd4:	6526                	ld	a0,72(sp)
    80005dd6:	65c6                	ld	a1,80(sp)
    80005dd8:	6666                	ld	a2,88(sp)
    80005dda:	7686                	ld	a3,96(sp)
    80005ddc:	7726                	ld	a4,104(sp)
    80005dde:	77c6                	ld	a5,112(sp)
    80005de0:	7866                	ld	a6,120(sp)
    80005de2:	688a                	ld	a7,128(sp)
    80005de4:	692a                	ld	s2,136(sp)
    80005de6:	69ca                	ld	s3,144(sp)
    80005de8:	6a6a                	ld	s4,152(sp)
    80005dea:	7a8a                	ld	s5,160(sp)
    80005dec:	7b2a                	ld	s6,168(sp)
    80005dee:	7bca                	ld	s7,176(sp)
    80005df0:	7c6a                	ld	s8,184(sp)
    80005df2:	6c8e                	ld	s9,192(sp)
    80005df4:	6d2e                	ld	s10,200(sp)
    80005df6:	6dce                	ld	s11,208(sp)
    80005df8:	6e6e                	ld	t3,216(sp)
    80005dfa:	7e8e                	ld	t4,224(sp)
    80005dfc:	7f2e                	ld	t5,232(sp)
    80005dfe:	7fce                	ld	t6,240(sp)
    80005e00:	6111                	addi	sp,sp,256
    80005e02:	10200073          	sret
    80005e06:	00000013          	nop
    80005e0a:	00000013          	nop
    80005e0e:	0001                	nop

0000000080005e10 <timervec>:
    80005e10:	34051573          	csrrw	a0,mscratch,a0
    80005e14:	e10c                	sd	a1,0(a0)
    80005e16:	e510                	sd	a2,8(a0)
    80005e18:	e914                	sd	a3,16(a0)
    80005e1a:	710c                	ld	a1,32(a0)
    80005e1c:	7510                	ld	a2,40(a0)
    80005e1e:	6194                	ld	a3,0(a1)
    80005e20:	96b2                	add	a3,a3,a2
    80005e22:	e194                	sd	a3,0(a1)
    80005e24:	4589                	li	a1,2
    80005e26:	14459073          	csrw	sip,a1
    80005e2a:	6914                	ld	a3,16(a0)
    80005e2c:	6510                	ld	a2,8(a0)
    80005e2e:	610c                	ld	a1,0(a0)
    80005e30:	34051573          	csrrw	a0,mscratch,a0
    80005e34:	30200073          	mret
	...

0000000080005e3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e3a:	1141                	addi	sp,sp,-16
    80005e3c:	e422                	sd	s0,8(sp)
    80005e3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e40:	0c0007b7          	lui	a5,0xc000
    80005e44:	4705                	li	a4,1
    80005e46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e48:	c3d8                	sw	a4,4(a5)
}
    80005e4a:	6422                	ld	s0,8(sp)
    80005e4c:	0141                	addi	sp,sp,16
    80005e4e:	8082                	ret

0000000080005e50 <plicinithart>:

void
plicinithart(void)
{
    80005e50:	1141                	addi	sp,sp,-16
    80005e52:	e406                	sd	ra,8(sp)
    80005e54:	e022                	sd	s0,0(sp)
    80005e56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	a82080e7          	jalr	-1406(ra) # 800018da <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005e60:	0085171b          	slliw	a4,a0,0x8
    80005e64:	0c0027b7          	lui	a5,0xc002
    80005e68:	97ba                	add	a5,a5,a4
    80005e6a:	40200713          	li	a4,1026
    80005e6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005e72:	00d5151b          	slliw	a0,a0,0xd
    80005e76:	0c2017b7          	lui	a5,0xc201
    80005e7a:	953e                	add	a0,a0,a5
    80005e7c:	00052023          	sw	zero,0(a0)
}
    80005e80:	60a2                	ld	ra,8(sp)
    80005e82:	6402                	ld	s0,0(sp)
    80005e84:	0141                	addi	sp,sp,16
    80005e86:	8082                	ret

0000000080005e88 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005e88:	1141                	addi	sp,sp,-16
    80005e8a:	e422                	sd	s0,8(sp)
    80005e8c:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005e8e:	0c0017b7          	lui	a5,0xc001
    80005e92:	6388                	ld	a0,0(a5)
    80005e94:	6422                	ld	s0,8(sp)
    80005e96:	0141                	addi	sp,sp,16
    80005e98:	8082                	ret

0000000080005e9a <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005e9a:	1141                	addi	sp,sp,-16
    80005e9c:	e406                	sd	ra,8(sp)
    80005e9e:	e022                	sd	s0,0(sp)
    80005ea0:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ea2:	ffffc097          	auipc	ra,0xffffc
    80005ea6:	a38080e7          	jalr	-1480(ra) # 800018da <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005eaa:	00d5179b          	slliw	a5,a0,0xd
    80005eae:	0c201537          	lui	a0,0xc201
    80005eb2:	953e                	add	a0,a0,a5
  return irq;
}
    80005eb4:	4148                	lw	a0,4(a0)
    80005eb6:	60a2                	ld	ra,8(sp)
    80005eb8:	6402                	ld	s0,0(sp)
    80005eba:	0141                	addi	sp,sp,16
    80005ebc:	8082                	ret

0000000080005ebe <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005ebe:	1101                	addi	sp,sp,-32
    80005ec0:	ec06                	sd	ra,24(sp)
    80005ec2:	e822                	sd	s0,16(sp)
    80005ec4:	e426                	sd	s1,8(sp)
    80005ec6:	1000                	addi	s0,sp,32
    80005ec8:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005eca:	ffffc097          	auipc	ra,0xffffc
    80005ece:	a10080e7          	jalr	-1520(ra) # 800018da <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ed2:	00d5151b          	slliw	a0,a0,0xd
    80005ed6:	0c2017b7          	lui	a5,0xc201
    80005eda:	97aa                	add	a5,a5,a0
    80005edc:	c3c4                	sw	s1,4(a5)
}
    80005ede:	60e2                	ld	ra,24(sp)
    80005ee0:	6442                	ld	s0,16(sp)
    80005ee2:	64a2                	ld	s1,8(sp)
    80005ee4:	6105                	addi	sp,sp,32
    80005ee6:	8082                	ret

0000000080005ee8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005ee8:	1141                	addi	sp,sp,-16
    80005eea:	e406                	sd	ra,8(sp)
    80005eec:	e022                	sd	s0,0(sp)
    80005eee:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005ef0:	479d                	li	a5,7
    80005ef2:	06b7c963          	blt	a5,a1,80005f64 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005ef6:	00151793          	slli	a5,a0,0x1
    80005efa:	97aa                	add	a5,a5,a0
    80005efc:	00c79713          	slli	a4,a5,0xc
    80005f00:	0001d797          	auipc	a5,0x1d
    80005f04:	10078793          	addi	a5,a5,256 # 80023000 <disk>
    80005f08:	97ba                	add	a5,a5,a4
    80005f0a:	97ae                	add	a5,a5,a1
    80005f0c:	6709                	lui	a4,0x2
    80005f0e:	97ba                	add	a5,a5,a4
    80005f10:	0187c783          	lbu	a5,24(a5)
    80005f14:	e3a5                	bnez	a5,80005f74 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005f16:	0001d817          	auipc	a6,0x1d
    80005f1a:	0ea80813          	addi	a6,a6,234 # 80023000 <disk>
    80005f1e:	00151693          	slli	a3,a0,0x1
    80005f22:	00a68733          	add	a4,a3,a0
    80005f26:	0732                	slli	a4,a4,0xc
    80005f28:	00e807b3          	add	a5,a6,a4
    80005f2c:	6709                	lui	a4,0x2
    80005f2e:	00f70633          	add	a2,a4,a5
    80005f32:	6210                	ld	a2,0(a2)
    80005f34:	00459893          	slli	a7,a1,0x4
    80005f38:	9646                	add	a2,a2,a7
    80005f3a:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005f3e:	97ae                	add	a5,a5,a1
    80005f40:	97ba                	add	a5,a5,a4
    80005f42:	4605                	li	a2,1
    80005f44:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005f48:	96aa                	add	a3,a3,a0
    80005f4a:	06b2                	slli	a3,a3,0xc
    80005f4c:	0761                	addi	a4,a4,24
    80005f4e:	96ba                	add	a3,a3,a4
    80005f50:	00d80533          	add	a0,a6,a3
    80005f54:	ffffc097          	auipc	ra,0xffffc
    80005f58:	352080e7          	jalr	850(ra) # 800022a6 <wakeup>
}
    80005f5c:	60a2                	ld	ra,8(sp)
    80005f5e:	6402                	ld	s0,0(sp)
    80005f60:	0141                	addi	sp,sp,16
    80005f62:	8082                	ret
    panic("virtio_disk_intr 1");
    80005f64:	00003517          	auipc	a0,0x3
    80005f68:	88c50513          	addi	a0,a0,-1908 # 800087f0 <userret+0x760>
    80005f6c:	ffffa097          	auipc	ra,0xffffa
    80005f70:	5e2080e7          	jalr	1506(ra) # 8000054e <panic>
    panic("virtio_disk_intr 2");
    80005f74:	00003517          	auipc	a0,0x3
    80005f78:	89450513          	addi	a0,a0,-1900 # 80008808 <userret+0x778>
    80005f7c:	ffffa097          	auipc	ra,0xffffa
    80005f80:	5d2080e7          	jalr	1490(ra) # 8000054e <panic>

0000000080005f84 <virtio_disk_init>:
  __sync_synchronize();
    80005f84:	0ff0000f          	fence
  if(disk[n].init)
    80005f88:	00151793          	slli	a5,a0,0x1
    80005f8c:	97aa                	add	a5,a5,a0
    80005f8e:	07b2                	slli	a5,a5,0xc
    80005f90:	0001d717          	auipc	a4,0x1d
    80005f94:	07070713          	addi	a4,a4,112 # 80023000 <disk>
    80005f98:	973e                	add	a4,a4,a5
    80005f9a:	6789                	lui	a5,0x2
    80005f9c:	97ba                	add	a5,a5,a4
    80005f9e:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80005fa2:	c391                	beqz	a5,80005fa6 <virtio_disk_init+0x22>
    80005fa4:	8082                	ret
{
    80005fa6:	7139                	addi	sp,sp,-64
    80005fa8:	fc06                	sd	ra,56(sp)
    80005faa:	f822                	sd	s0,48(sp)
    80005fac:	f426                	sd	s1,40(sp)
    80005fae:	f04a                	sd	s2,32(sp)
    80005fb0:	ec4e                	sd	s3,24(sp)
    80005fb2:	e852                	sd	s4,16(sp)
    80005fb4:	e456                	sd	s5,8(sp)
    80005fb6:	0080                	addi	s0,sp,64
    80005fb8:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80005fba:	85aa                	mv	a1,a0
    80005fbc:	00003517          	auipc	a0,0x3
    80005fc0:	86450513          	addi	a0,a0,-1948 # 80008820 <userret+0x790>
    80005fc4:	ffffa097          	auipc	ra,0xffffa
    80005fc8:	5d4080e7          	jalr	1492(ra) # 80000598 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80005fcc:	00149993          	slli	s3,s1,0x1
    80005fd0:	99a6                	add	s3,s3,s1
    80005fd2:	09b2                	slli	s3,s3,0xc
    80005fd4:	6789                	lui	a5,0x2
    80005fd6:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80005fda:	97ce                	add	a5,a5,s3
    80005fdc:	00003597          	auipc	a1,0x3
    80005fe0:	85c58593          	addi	a1,a1,-1956 # 80008838 <userret+0x7a8>
    80005fe4:	0001d517          	auipc	a0,0x1d
    80005fe8:	01c50513          	addi	a0,a0,28 # 80023000 <disk>
    80005fec:	953e                	add	a0,a0,a5
    80005fee:	ffffb097          	auipc	ra,0xffffb
    80005ff2:	9ea080e7          	jalr	-1558(ra) # 800009d8 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ff6:	0014891b          	addiw	s2,s1,1
    80005ffa:	00c9191b          	slliw	s2,s2,0xc
    80005ffe:	100007b7          	lui	a5,0x10000
    80006002:	97ca                	add	a5,a5,s2
    80006004:	4398                	lw	a4,0(a5)
    80006006:	2701                	sext.w	a4,a4
    80006008:	747277b7          	lui	a5,0x74727
    8000600c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006010:	12f71663          	bne	a4,a5,8000613c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006014:	100007b7          	lui	a5,0x10000
    80006018:	0791                	addi	a5,a5,4
    8000601a:	97ca                	add	a5,a5,s2
    8000601c:	439c                	lw	a5,0(a5)
    8000601e:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006020:	4705                	li	a4,1
    80006022:	10e79d63          	bne	a5,a4,8000613c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006026:	100007b7          	lui	a5,0x10000
    8000602a:	07a1                	addi	a5,a5,8
    8000602c:	97ca                	add	a5,a5,s2
    8000602e:	439c                	lw	a5,0(a5)
    80006030:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006032:	4709                	li	a4,2
    80006034:	10e79463          	bne	a5,a4,8000613c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006038:	100007b7          	lui	a5,0x10000
    8000603c:	07b1                	addi	a5,a5,12
    8000603e:	97ca                	add	a5,a5,s2
    80006040:	4398                	lw	a4,0(a5)
    80006042:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006044:	554d47b7          	lui	a5,0x554d4
    80006048:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000604c:	0ef71863          	bne	a4,a5,8000613c <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006050:	100007b7          	lui	a5,0x10000
    80006054:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006058:	96ca                	add	a3,a3,s2
    8000605a:	4705                	li	a4,1
    8000605c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000605e:	470d                	li	a4,3
    80006060:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006062:	01078713          	addi	a4,a5,16
    80006066:	974a                	add	a4,a4,s2
    80006068:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000606a:	02078613          	addi	a2,a5,32
    8000606e:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006070:	c7ffe737          	lui	a4,0xc7ffe
    80006074:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5703>
    80006078:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000607a:	2701                	sext.w	a4,a4
    8000607c:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000607e:	472d                	li	a4,11
    80006080:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80006082:	473d                	li	a4,15
    80006084:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006086:	02878713          	addi	a4,a5,40
    8000608a:	974a                	add	a4,a4,s2
    8000608c:	6685                	lui	a3,0x1
    8000608e:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006090:	03078713          	addi	a4,a5,48
    80006094:	974a                	add	a4,a4,s2
    80006096:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000609a:	03478793          	addi	a5,a5,52
    8000609e:	97ca                	add	a5,a5,s2
    800060a0:	439c                	lw	a5,0(a5)
    800060a2:	2781                	sext.w	a5,a5
  if(max == 0)
    800060a4:	c7c5                	beqz	a5,8000614c <virtio_disk_init+0x1c8>
  if(max < NUM)
    800060a6:	471d                	li	a4,7
    800060a8:	0af77a63          	bgeu	a4,a5,8000615c <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060ac:	10000ab7          	lui	s5,0x10000
    800060b0:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    800060b4:	97ca                	add	a5,a5,s2
    800060b6:	4721                	li	a4,8
    800060b8:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    800060ba:	0001da17          	auipc	s4,0x1d
    800060be:	f46a0a13          	addi	s4,s4,-186 # 80023000 <disk>
    800060c2:	99d2                	add	s3,s3,s4
    800060c4:	6609                	lui	a2,0x2
    800060c6:	4581                	li	a1,0
    800060c8:	854e                	mv	a0,s3
    800060ca:	ffffb097          	auipc	ra,0xffffb
    800060ce:	ae4080e7          	jalr	-1308(ra) # 80000bae <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800060d2:	040a8a93          	addi	s5,s5,64
    800060d6:	9956                	add	s2,s2,s5
    800060d8:	00c9d793          	srli	a5,s3,0xc
    800060dc:	2781                	sext.w	a5,a5
    800060de:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    800060e2:	00149513          	slli	a0,s1,0x1
    800060e6:	009507b3          	add	a5,a0,s1
    800060ea:	07b2                	slli	a5,a5,0xc
    800060ec:	97d2                	add	a5,a5,s4
    800060ee:	6689                	lui	a3,0x2
    800060f0:	97b6                	add	a5,a5,a3
    800060f2:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    800060f6:	08098713          	addi	a4,s3,128
    800060fa:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    800060fc:	6705                	lui	a4,0x1
    800060fe:	99ba                	add	s3,s3,a4
    80006100:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006104:	4705                	li	a4,1
    80006106:	00e78c23          	sb	a4,24(a5)
    8000610a:	00e78ca3          	sb	a4,25(a5)
    8000610e:	00e78d23          	sb	a4,26(a5)
    80006112:	00e78da3          	sb	a4,27(a5)
    80006116:	00e78e23          	sb	a4,28(a5)
    8000611a:	00e78ea3          	sb	a4,29(a5)
    8000611e:	00e78f23          	sb	a4,30(a5)
    80006122:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006126:	0ae7a423          	sw	a4,168(a5)
}
    8000612a:	70e2                	ld	ra,56(sp)
    8000612c:	7442                	ld	s0,48(sp)
    8000612e:	74a2                	ld	s1,40(sp)
    80006130:	7902                	ld	s2,32(sp)
    80006132:	69e2                	ld	s3,24(sp)
    80006134:	6a42                	ld	s4,16(sp)
    80006136:	6aa2                	ld	s5,8(sp)
    80006138:	6121                	addi	sp,sp,64
    8000613a:	8082                	ret
    panic("could not find virtio disk");
    8000613c:	00002517          	auipc	a0,0x2
    80006140:	70c50513          	addi	a0,a0,1804 # 80008848 <userret+0x7b8>
    80006144:	ffffa097          	auipc	ra,0xffffa
    80006148:	40a080e7          	jalr	1034(ra) # 8000054e <panic>
    panic("virtio disk has no queue 0");
    8000614c:	00002517          	auipc	a0,0x2
    80006150:	71c50513          	addi	a0,a0,1820 # 80008868 <userret+0x7d8>
    80006154:	ffffa097          	auipc	ra,0xffffa
    80006158:	3fa080e7          	jalr	1018(ra) # 8000054e <panic>
    panic("virtio disk max queue too short");
    8000615c:	00002517          	auipc	a0,0x2
    80006160:	72c50513          	addi	a0,a0,1836 # 80008888 <userret+0x7f8>
    80006164:	ffffa097          	auipc	ra,0xffffa
    80006168:	3ea080e7          	jalr	1002(ra) # 8000054e <panic>

000000008000616c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000616c:	7135                	addi	sp,sp,-160
    8000616e:	ed06                	sd	ra,152(sp)
    80006170:	e922                	sd	s0,144(sp)
    80006172:	e526                	sd	s1,136(sp)
    80006174:	e14a                	sd	s2,128(sp)
    80006176:	fcce                	sd	s3,120(sp)
    80006178:	f8d2                	sd	s4,112(sp)
    8000617a:	f4d6                	sd	s5,104(sp)
    8000617c:	f0da                	sd	s6,96(sp)
    8000617e:	ecde                	sd	s7,88(sp)
    80006180:	e8e2                	sd	s8,80(sp)
    80006182:	e4e6                	sd	s9,72(sp)
    80006184:	e0ea                	sd	s10,64(sp)
    80006186:	fc6e                	sd	s11,56(sp)
    80006188:	1100                	addi	s0,sp,160
    8000618a:	892a                	mv	s2,a0
    8000618c:	89ae                	mv	s3,a1
    8000618e:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80006190:	45dc                	lw	a5,12(a1)
    80006192:	0017979b          	slliw	a5,a5,0x1
    80006196:	1782                	slli	a5,a5,0x20
    80006198:	9381                	srli	a5,a5,0x20
    8000619a:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    8000619e:	00151493          	slli	s1,a0,0x1
    800061a2:	94aa                	add	s1,s1,a0
    800061a4:	04b2                	slli	s1,s1,0xc
    800061a6:	6a89                	lui	s5,0x2
    800061a8:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    800061ac:	9a26                	add	s4,s4,s1
    800061ae:	0001db97          	auipc	s7,0x1d
    800061b2:	e52b8b93          	addi	s7,s7,-430 # 80023000 <disk>
    800061b6:	9a5e                	add	s4,s4,s7
    800061b8:	8552                	mv	a0,s4
    800061ba:	ffffb097          	auipc	ra,0xffffb
    800061be:	930080e7          	jalr	-1744(ra) # 80000aea <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800061c2:	0ae1                	addi	s5,s5,24
    800061c4:	94d6                	add	s1,s1,s5
    800061c6:	01748ab3          	add	s5,s1,s7
    800061ca:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    800061cc:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    800061ce:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    800061d0:	00191b13          	slli	s6,s2,0x1
    800061d4:	9b4a                	add	s6,s6,s2
    800061d6:	00cb1793          	slli	a5,s6,0xc
    800061da:	0001db17          	auipc	s6,0x1d
    800061de:	e26b0b13          	addi	s6,s6,-474 # 80023000 <disk>
    800061e2:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    800061e4:	8c5e                	mv	s8,s7
    800061e6:	a8ad                	j	80006260 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    800061e8:	00fb06b3          	add	a3,s6,a5
    800061ec:	96aa                	add	a3,a3,a0
    800061ee:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    800061f2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800061f4:	0207c363          	bltz	a5,8000621a <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    800061f8:	2485                	addiw	s1,s1,1
    800061fa:	0711                	addi	a4,a4,4
    800061fc:	1eb48363          	beq	s1,a1,800063e2 <virtio_disk_rw+0x276>
    idx[i] = alloc_desc(n);
    80006200:	863a                	mv	a2,a4
    80006202:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    80006204:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    80006206:	0006c803          	lbu	a6,0(a3)
    8000620a:	fc081fe3          	bnez	a6,800061e8 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    8000620e:	2785                	addiw	a5,a5,1
    80006210:	0685                	addi	a3,a3,1
    80006212:	ff979ae3          	bne	a5,s9,80006206 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    80006216:	57fd                	li	a5,-1
    80006218:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000621a:	02905d63          	blez	s1,80006254 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    8000621e:	f8042583          	lw	a1,-128(s0)
    80006222:	854a                	mv	a0,s2
    80006224:	00000097          	auipc	ra,0x0
    80006228:	cc4080e7          	jalr	-828(ra) # 80005ee8 <free_desc>
      for(int j = 0; j < i; j++)
    8000622c:	4785                	li	a5,1
    8000622e:	0297d363          	bge	a5,s1,80006254 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006232:	f8442583          	lw	a1,-124(s0)
    80006236:	854a                	mv	a0,s2
    80006238:	00000097          	auipc	ra,0x0
    8000623c:	cb0080e7          	jalr	-848(ra) # 80005ee8 <free_desc>
      for(int j = 0; j < i; j++)
    80006240:	4789                	li	a5,2
    80006242:	0097d963          	bge	a5,s1,80006254 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006246:	f8842583          	lw	a1,-120(s0)
    8000624a:	854a                	mv	a0,s2
    8000624c:	00000097          	auipc	ra,0x0
    80006250:	c9c080e7          	jalr	-868(ra) # 80005ee8 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006254:	85d2                	mv	a1,s4
    80006256:	8556                	mv	a0,s5
    80006258:	ffffc097          	auipc	ra,0xffffc
    8000625c:	ec8080e7          	jalr	-312(ra) # 80002120 <sleep>
  for(int i = 0; i < 3; i++){
    80006260:	f8040713          	addi	a4,s0,-128
    80006264:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    80006266:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    80006268:	458d                	li	a1,3
    8000626a:	bf59                	j	80006200 <virtio_disk_rw+0x94>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    8000626c:	00191793          	slli	a5,s2,0x1
    80006270:	97ca                	add	a5,a5,s2
    80006272:	07b2                	slli	a5,a5,0xc
    80006274:	0001d717          	auipc	a4,0x1d
    80006278:	d8c70713          	addi	a4,a4,-628 # 80023000 <disk>
    8000627c:	973e                	add	a4,a4,a5
    8000627e:	6789                	lui	a5,0x2
    80006280:	97ba                	add	a5,a5,a4
    80006282:	639c                	ld	a5,0(a5)
    80006284:	97b6                	add	a5,a5,a3
    80006286:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000628a:	0001d517          	auipc	a0,0x1d
    8000628e:	d7650513          	addi	a0,a0,-650 # 80023000 <disk>
    80006292:	00191793          	slli	a5,s2,0x1
    80006296:	01278733          	add	a4,a5,s2
    8000629a:	0732                	slli	a4,a4,0xc
    8000629c:	972a                	add	a4,a4,a0
    8000629e:	6609                	lui	a2,0x2
    800062a0:	9732                	add	a4,a4,a2
    800062a2:	630c                	ld	a1,0(a4)
    800062a4:	95b6                	add	a1,a1,a3
    800062a6:	00c5d603          	lhu	a2,12(a1)
    800062aa:	00166613          	ori	a2,a2,1
    800062ae:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    800062b2:	f8842603          	lw	a2,-120(s0)
    800062b6:	630c                	ld	a1,0(a4)
    800062b8:	96ae                	add	a3,a3,a1
    800062ba:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    800062be:	97ca                	add	a5,a5,s2
    800062c0:	07a2                	slli	a5,a5,0x8
    800062c2:	97a6                	add	a5,a5,s1
    800062c4:	20078793          	addi	a5,a5,512
    800062c8:	0792                	slli	a5,a5,0x4
    800062ca:	97aa                	add	a5,a5,a0
    800062cc:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800062d0:	00461693          	slli	a3,a2,0x4
    800062d4:	00073803          	ld	a6,0(a4)
    800062d8:	9836                	add	a6,a6,a3
    800062da:	20348613          	addi	a2,s1,515
    800062de:	00191593          	slli	a1,s2,0x1
    800062e2:	95ca                	add	a1,a1,s2
    800062e4:	05a2                	slli	a1,a1,0x8
    800062e6:	962e                	add	a2,a2,a1
    800062e8:	0612                	slli	a2,a2,0x4
    800062ea:	962a                	add	a2,a2,a0
    800062ec:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    800062f0:	630c                	ld	a1,0(a4)
    800062f2:	95b6                	add	a1,a1,a3
    800062f4:	4605                	li	a2,1
    800062f6:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062f8:	630c                	ld	a1,0(a4)
    800062fa:	95b6                	add	a1,a1,a3
    800062fc:	4509                	li	a0,2
    800062fe:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    80006302:	630c                	ld	a1,0(a4)
    80006304:	96ae                	add	a3,a3,a1
    80006306:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000630a:	00c9a223          	sw	a2,4(s3)
  disk[n].info[idx[0]].b = b;
    8000630e:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006312:	6714                	ld	a3,8(a4)
    80006314:	0026d783          	lhu	a5,2(a3)
    80006318:	8b9d                	andi	a5,a5,7
    8000631a:	2789                	addiw	a5,a5,2
    8000631c:	0786                	slli	a5,a5,0x1
    8000631e:	97b6                	add	a5,a5,a3
    80006320:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006324:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006328:	6718                	ld	a4,8(a4)
    8000632a:	00275783          	lhu	a5,2(a4)
    8000632e:	2785                	addiw	a5,a5,1
    80006330:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006334:	0019079b          	addiw	a5,s2,1
    80006338:	00c7979b          	slliw	a5,a5,0xc
    8000633c:	10000737          	lui	a4,0x10000
    80006340:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006344:	97ba                	add	a5,a5,a4
    80006346:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000634a:	0049a783          	lw	a5,4(s3)
    8000634e:	00c79d63          	bne	a5,a2,80006368 <virtio_disk_rw+0x1fc>
    80006352:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006354:	85d2                	mv	a1,s4
    80006356:	854e                	mv	a0,s3
    80006358:	ffffc097          	auipc	ra,0xffffc
    8000635c:	dc8080e7          	jalr	-568(ra) # 80002120 <sleep>
  while(b->disk == 1) {
    80006360:	0049a783          	lw	a5,4(s3)
    80006364:	fe9788e3          	beq	a5,s1,80006354 <virtio_disk_rw+0x1e8>
  }

  disk[n].info[idx[0]].b = 0;
    80006368:	f8042483          	lw	s1,-128(s0)
    8000636c:	00191793          	slli	a5,s2,0x1
    80006370:	97ca                	add	a5,a5,s2
    80006372:	07a2                	slli	a5,a5,0x8
    80006374:	97a6                	add	a5,a5,s1
    80006376:	20078793          	addi	a5,a5,512
    8000637a:	0792                	slli	a5,a5,0x4
    8000637c:	0001d717          	auipc	a4,0x1d
    80006380:	c8470713          	addi	a4,a4,-892 # 80023000 <disk>
    80006384:	97ba                	add	a5,a5,a4
    80006386:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    8000638a:	00191793          	slli	a5,s2,0x1
    8000638e:	97ca                	add	a5,a5,s2
    80006390:	07b2                	slli	a5,a5,0xc
    80006392:	97ba                	add	a5,a5,a4
    80006394:	6989                	lui	s3,0x2
    80006396:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006398:	85a6                	mv	a1,s1
    8000639a:	854a                	mv	a0,s2
    8000639c:	00000097          	auipc	ra,0x0
    800063a0:	b4c080e7          	jalr	-1204(ra) # 80005ee8 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800063a4:	0492                	slli	s1,s1,0x4
    800063a6:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    800063aa:	94be                	add	s1,s1,a5
    800063ac:	00c4d783          	lhu	a5,12(s1)
    800063b0:	8b85                	andi	a5,a5,1
    800063b2:	c781                	beqz	a5,800063ba <virtio_disk_rw+0x24e>
      i = disk[n].desc[i].next;
    800063b4:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    800063b8:	b7c5                	j	80006398 <virtio_disk_rw+0x22c>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800063ba:	8552                	mv	a0,s4
    800063bc:	ffffa097          	auipc	ra,0xffffa
    800063c0:	796080e7          	jalr	1942(ra) # 80000b52 <release>
}
    800063c4:	60ea                	ld	ra,152(sp)
    800063c6:	644a                	ld	s0,144(sp)
    800063c8:	64aa                	ld	s1,136(sp)
    800063ca:	690a                	ld	s2,128(sp)
    800063cc:	79e6                	ld	s3,120(sp)
    800063ce:	7a46                	ld	s4,112(sp)
    800063d0:	7aa6                	ld	s5,104(sp)
    800063d2:	7b06                	ld	s6,96(sp)
    800063d4:	6be6                	ld	s7,88(sp)
    800063d6:	6c46                	ld	s8,80(sp)
    800063d8:	6ca6                	ld	s9,72(sp)
    800063da:	6d06                	ld	s10,64(sp)
    800063dc:	7de2                	ld	s11,56(sp)
    800063de:	610d                	addi	sp,sp,160
    800063e0:	8082                	ret
  if(write)
    800063e2:	01b037b3          	snez	a5,s11
    800063e6:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800063ea:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800063ee:	f6843783          	ld	a5,-152(s0)
    800063f2:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800063f6:	f8042483          	lw	s1,-128(s0)
    800063fa:	00449b13          	slli	s6,s1,0x4
    800063fe:	00191793          	slli	a5,s2,0x1
    80006402:	97ca                	add	a5,a5,s2
    80006404:	07b2                	slli	a5,a5,0xc
    80006406:	0001da97          	auipc	s5,0x1d
    8000640a:	bfaa8a93          	addi	s5,s5,-1030 # 80023000 <disk>
    8000640e:	97d6                	add	a5,a5,s5
    80006410:	6a89                	lui	s5,0x2
    80006412:	9abe                	add	s5,s5,a5
    80006414:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006418:	9bda                	add	s7,s7,s6
    8000641a:	f7040513          	addi	a0,s0,-144
    8000641e:	ffffb097          	auipc	ra,0xffffb
    80006422:	bc4080e7          	jalr	-1084(ra) # 80000fe2 <kvmpa>
    80006426:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    8000642a:	000ab783          	ld	a5,0(s5)
    8000642e:	97da                	add	a5,a5,s6
    80006430:	4741                	li	a4,16
    80006432:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006434:	000ab783          	ld	a5,0(s5)
    80006438:	97da                	add	a5,a5,s6
    8000643a:	4705                	li	a4,1
    8000643c:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006440:	f8442683          	lw	a3,-124(s0)
    80006444:	000ab783          	ld	a5,0(s5)
    80006448:	9b3e                	add	s6,s6,a5
    8000644a:	00db1723          	sh	a3,14(s6)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    8000644e:	0692                	slli	a3,a3,0x4
    80006450:	000ab783          	ld	a5,0(s5)
    80006454:	97b6                	add	a5,a5,a3
    80006456:	06098713          	addi	a4,s3,96
    8000645a:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    8000645c:	000ab783          	ld	a5,0(s5)
    80006460:	97b6                	add	a5,a5,a3
    80006462:	40000713          	li	a4,1024
    80006466:	c798                	sw	a4,8(a5)
  if(write)
    80006468:	e00d92e3          	bnez	s11,8000626c <virtio_disk_rw+0x100>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000646c:	00191793          	slli	a5,s2,0x1
    80006470:	97ca                	add	a5,a5,s2
    80006472:	07b2                	slli	a5,a5,0xc
    80006474:	0001d717          	auipc	a4,0x1d
    80006478:	b8c70713          	addi	a4,a4,-1140 # 80023000 <disk>
    8000647c:	973e                	add	a4,a4,a5
    8000647e:	6789                	lui	a5,0x2
    80006480:	97ba                	add	a5,a5,a4
    80006482:	639c                	ld	a5,0(a5)
    80006484:	97b6                	add	a5,a5,a3
    80006486:	4709                	li	a4,2
    80006488:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    8000648c:	bbfd                	j	8000628a <virtio_disk_rw+0x11e>

000000008000648e <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    8000648e:	7139                	addi	sp,sp,-64
    80006490:	fc06                	sd	ra,56(sp)
    80006492:	f822                	sd	s0,48(sp)
    80006494:	f426                	sd	s1,40(sp)
    80006496:	f04a                	sd	s2,32(sp)
    80006498:	ec4e                	sd	s3,24(sp)
    8000649a:	e852                	sd	s4,16(sp)
    8000649c:	e456                	sd	s5,8(sp)
    8000649e:	0080                	addi	s0,sp,64
    800064a0:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    800064a2:	00151913          	slli	s2,a0,0x1
    800064a6:	00a90a33          	add	s4,s2,a0
    800064aa:	0a32                	slli	s4,s4,0xc
    800064ac:	6989                	lui	s3,0x2
    800064ae:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800064b2:	9a3e                	add	s4,s4,a5
    800064b4:	0001da97          	auipc	s5,0x1d
    800064b8:	b4ca8a93          	addi	s5,s5,-1204 # 80023000 <disk>
    800064bc:	9a56                	add	s4,s4,s5
    800064be:	8552                	mv	a0,s4
    800064c0:	ffffa097          	auipc	ra,0xffffa
    800064c4:	62a080e7          	jalr	1578(ra) # 80000aea <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800064c8:	9926                	add	s2,s2,s1
    800064ca:	0932                	slli	s2,s2,0xc
    800064cc:	9956                	add	s2,s2,s5
    800064ce:	99ca                	add	s3,s3,s2
    800064d0:	0209d783          	lhu	a5,32(s3)
    800064d4:	0109b703          	ld	a4,16(s3)
    800064d8:	00275683          	lhu	a3,2(a4)
    800064dc:	8ebd                	xor	a3,a3,a5
    800064de:	8a9d                	andi	a3,a3,7
    800064e0:	c2a5                	beqz	a3,80006540 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    800064e2:	8956                	mv	s2,s5
    800064e4:	00149693          	slli	a3,s1,0x1
    800064e8:	96a6                	add	a3,a3,s1
    800064ea:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800064ee:	06b2                	slli	a3,a3,0xc
    800064f0:	96d6                	add	a3,a3,s5
    800064f2:	6489                	lui	s1,0x2
    800064f4:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    800064f6:	078e                	slli	a5,a5,0x3
    800064f8:	97ba                	add	a5,a5,a4
    800064fa:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    800064fc:	00f98733          	add	a4,s3,a5
    80006500:	20070713          	addi	a4,a4,512
    80006504:	0712                	slli	a4,a4,0x4
    80006506:	974a                	add	a4,a4,s2
    80006508:	03074703          	lbu	a4,48(a4)
    8000650c:	eb21                	bnez	a4,8000655c <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    8000650e:	97ce                	add	a5,a5,s3
    80006510:	20078793          	addi	a5,a5,512
    80006514:	0792                	slli	a5,a5,0x4
    80006516:	97ca                	add	a5,a5,s2
    80006518:	7798                	ld	a4,40(a5)
    8000651a:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    8000651e:	7788                	ld	a0,40(a5)
    80006520:	ffffc097          	auipc	ra,0xffffc
    80006524:	d86080e7          	jalr	-634(ra) # 800022a6 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006528:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    8000652c:	2785                	addiw	a5,a5,1
    8000652e:	8b9d                	andi	a5,a5,7
    80006530:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006534:	6898                	ld	a4,16(s1)
    80006536:	00275683          	lhu	a3,2(a4)
    8000653a:	8a9d                	andi	a3,a3,7
    8000653c:	faf69de3          	bne	a3,a5,800064f6 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006540:	8552                	mv	a0,s4
    80006542:	ffffa097          	auipc	ra,0xffffa
    80006546:	610080e7          	jalr	1552(ra) # 80000b52 <release>
}
    8000654a:	70e2                	ld	ra,56(sp)
    8000654c:	7442                	ld	s0,48(sp)
    8000654e:	74a2                	ld	s1,40(sp)
    80006550:	7902                	ld	s2,32(sp)
    80006552:	69e2                	ld	s3,24(sp)
    80006554:	6a42                	ld	s4,16(sp)
    80006556:	6aa2                	ld	s5,8(sp)
    80006558:	6121                	addi	sp,sp,64
    8000655a:	8082                	ret
      panic("virtio_disk_intr status");
    8000655c:	00002517          	auipc	a0,0x2
    80006560:	34c50513          	addi	a0,a0,844 # 800088a8 <userret+0x818>
    80006564:	ffffa097          	auipc	ra,0xffffa
    80006568:	fea080e7          	jalr	-22(ra) # 8000054e <panic>

000000008000656c <bit_isset>:
static Sz_info *bd_sizes;
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    8000656c:	1141                	addi	sp,sp,-16
    8000656e:	e422                	sd	s0,8(sp)
    80006570:	0800                	addi	s0,sp,16
  char b = array[index/8];//1 bit to indicate a value
  char m = (1 << (index % 8));
    80006572:	41f5d79b          	sraiw	a5,a1,0x1f
    80006576:	01d7d79b          	srliw	a5,a5,0x1d
    8000657a:	9dbd                	addw	a1,a1,a5
    8000657c:	0075f713          	andi	a4,a1,7
    80006580:	9f1d                	subw	a4,a4,a5
    80006582:	4785                	li	a5,1
    80006584:	00e797bb          	sllw	a5,a5,a4
    80006588:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];//1 bit to indicate a value
    8000658c:	4035d59b          	sraiw	a1,a1,0x3
    80006590:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    80006592:	0005c503          	lbu	a0,0(a1)
    80006596:	8d7d                	and	a0,a0,a5
    80006598:	8d1d                	sub	a0,a0,a5
}
    8000659a:	00153513          	seqz	a0,a0
    8000659e:	6422                	ld	s0,8(sp)
    800065a0:	0141                	addi	sp,sp,16
    800065a2:	8082                	ret

00000000800065a4 <bit_set>:

// Set bit at position index in array to 1
//eg. index==2. b=array[0] and m=100
// b|m=set the second position to 1
void bit_set(char *array, int index) {
    800065a4:	1141                	addi	sp,sp,-16
    800065a6:	e422                	sd	s0,8(sp)
    800065a8:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800065aa:	41f5d79b          	sraiw	a5,a1,0x1f
    800065ae:	01d7d79b          	srliw	a5,a5,0x1d
    800065b2:	9dbd                	addw	a1,a1,a5
    800065b4:	4035d71b          	sraiw	a4,a1,0x3
    800065b8:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800065ba:	899d                	andi	a1,a1,7
    800065bc:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    800065be:	4785                	li	a5,1
    800065c0:	00b795bb          	sllw	a1,a5,a1
    800065c4:	00054783          	lbu	a5,0(a0)
    800065c8:	8ddd                	or	a1,a1,a5
    800065ca:	00b50023          	sb	a1,0(a0)
}
    800065ce:	6422                	ld	s0,8(sp)
    800065d0:	0141                	addi	sp,sp,16
    800065d2:	8082                	ret

00000000800065d4 <bit_clear>:

// Clear bit at position index in array
//index==2. set the second position to 0
void bit_clear(char *array, int index) {
    800065d4:	1141                	addi	sp,sp,-16
    800065d6:	e422                	sd	s0,8(sp)
    800065d8:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800065da:	41f5d79b          	sraiw	a5,a1,0x1f
    800065de:	01d7d79b          	srliw	a5,a5,0x1d
    800065e2:	9dbd                	addw	a1,a1,a5
    800065e4:	4035d71b          	sraiw	a4,a1,0x3
    800065e8:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800065ea:	899d                	andi	a1,a1,7
    800065ec:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    800065ee:	4785                	li	a5,1
    800065f0:	00b795bb          	sllw	a1,a5,a1
    800065f4:	fff5c593          	not	a1,a1
    800065f8:	00054783          	lbu	a5,0(a0)
    800065fc:	8dfd                	and	a1,a1,a5
    800065fe:	00b50023          	sb	a1,0(a0)
}
    80006602:	6422                	ld	s0,8(sp)
    80006604:	0141                	addi	sp,sp,16
    80006606:	8082                	ret

0000000080006608 <bd_toggle>:

//if index==8 -> 4
//m=10000
//the fourth position will be set to opposite
//eg. 10101 --> 00101
void bd_toggle(char *array,int index){
    80006608:	1141                	addi	sp,sp,-16
    8000660a:	e422                	sd	s0,8(sp)
    8000660c:	0800                	addi	s0,sp,16
  index>>=1;
    8000660e:	4015d79b          	sraiw	a5,a1,0x1
  char m=(1<<(index%8));
  array[index/8]^=m;
    80006612:	95fd                	srai	a1,a1,0x3f
    80006614:	01d5d59b          	srliw	a1,a1,0x1d
    80006618:	9fad                	addw	a5,a5,a1
    8000661a:	4037d71b          	sraiw	a4,a5,0x3
    8000661e:	953a                	add	a0,a0,a4
  char m=(1<<(index%8));
    80006620:	8b9d                	andi	a5,a5,7
    80006622:	40b785bb          	subw	a1,a5,a1
  array[index/8]^=m;
    80006626:	4785                	li	a5,1
    80006628:	00b795bb          	sllw	a1,a5,a1
    8000662c:	00054783          	lbu	a5,0(a0)
    80006630:	8dbd                	xor	a1,a1,a5
    80006632:	00b50023          	sb	a1,0(a0)
}
    80006636:	6422                	ld	s0,8(sp)
    80006638:	0141                	addi	sp,sp,16
    8000663a:	8082                	ret

000000008000663c <bd_print>:

void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000663c:	00023797          	auipc	a5,0x23
    80006640:	a1c7a783          	lw	a5,-1508(a5) # 80029058 <nsizes>
    80006644:	16f05a63          	blez	a5,800067b8 <bd_print+0x17c>
bd_print() {
    80006648:	7159                	addi	sp,sp,-112
    8000664a:	f486                	sd	ra,104(sp)
    8000664c:	f0a2                	sd	s0,96(sp)
    8000664e:	eca6                	sd	s1,88(sp)
    80006650:	e8ca                	sd	s2,80(sp)
    80006652:	e4ce                	sd	s3,72(sp)
    80006654:	e0d2                	sd	s4,64(sp)
    80006656:	fc56                	sd	s5,56(sp)
    80006658:	f85a                	sd	s6,48(sp)
    8000665a:	f45e                	sd	s7,40(sp)
    8000665c:	f062                	sd	s8,32(sp)
    8000665e:	ec66                	sd	s9,24(sp)
    80006660:	e86a                	sd	s10,16(sp)
    80006662:	e46e                	sd	s11,8(sp)
    80006664:	1880                	addi	s0,sp,112
  for (int k = 0; k < nsizes; k++) {
    80006666:	4c01                	li	s8,0
    printf("size %d (%d):", k, BLK_SIZE(k));
    80006668:	4dc1                	li	s11,16
    8000666a:	00002d17          	auipc	s10,0x2
    8000666e:	256d0d13          	addi	s10,s10,598 # 800088c0 <userret+0x830>
    lst_print(&bd_sizes[k].free);
    80006672:	00023b17          	auipc	s6,0x23
    80006676:	9deb0b13          	addi	s6,s6,-1570 # 80029050 <bd_sizes>
    printf("  alloc:");
    8000667a:	00002c97          	auipc	s9,0x2
    8000667e:	256c8c93          	addi	s9,s9,598 # 800088d0 <userret+0x840>
    for (int b = 0; b < NBLK(k); b++) {
    80006682:	00023997          	auipc	s3,0x23
    80006686:	9d698993          	addi	s3,s3,-1578 # 80029058 <nsizes>
    8000668a:	4a85                	li	s5,1
     printf(" %d", bit_isset(bd_sizes[k].alloc, b));
    8000668c:	00002b97          	auipc	s7,0x2
    80006690:	254b8b93          	addi	s7,s7,596 # 800088e0 <userret+0x850>
    80006694:	a889                	j	800066e6 <bd_print+0xaa>
    }
    printf("\n");
    if(k > 0) {
      printf("  split:");
      for (int b = 0; b < NBLK(k); b++) {
        printf(" %d", bit_isset(bd_sizes[k].split, b));
    80006696:	000b3783          	ld	a5,0(s6)
    8000669a:	97d2                	add	a5,a5,s4
    8000669c:	85a6                	mv	a1,s1
    8000669e:	6f88                	ld	a0,24(a5)
    800066a0:	00000097          	auipc	ra,0x0
    800066a4:	ecc080e7          	jalr	-308(ra) # 8000656c <bit_isset>
    800066a8:	85aa                	mv	a1,a0
    800066aa:	855e                	mv	a0,s7
    800066ac:	ffffa097          	auipc	ra,0xffffa
    800066b0:	eec080e7          	jalr	-276(ra) # 80000598 <printf>
      for (int b = 0; b < NBLK(k); b++) {
    800066b4:	2485                	addiw	s1,s1,1
    800066b6:	0009a783          	lw	a5,0(s3)
    800066ba:	37fd                	addiw	a5,a5,-1
    800066bc:	412787bb          	subw	a5,a5,s2
    800066c0:	00fa97bb          	sllw	a5,s5,a5
    800066c4:	fcf4c9e3          	blt	s1,a5,80006696 <bd_print+0x5a>
      }
      printf("\n");
    800066c8:	00002517          	auipc	a0,0x2
    800066cc:	ae850513          	addi	a0,a0,-1304 # 800081b0 <userret+0x120>
    800066d0:	ffffa097          	auipc	ra,0xffffa
    800066d4:	ec8080e7          	jalr	-312(ra) # 80000598 <printf>
  for (int k = 0; k < nsizes; k++) {
    800066d8:	0c05                	addi	s8,s8,1
    800066da:	0009a703          	lw	a4,0(s3)
    800066de:	000c079b          	sext.w	a5,s8
    800066e2:	0ae7dc63          	bge	a5,a4,8000679a <bd_print+0x15e>
    800066e6:	000c091b          	sext.w	s2,s8
    printf("size %d (%d):", k, BLK_SIZE(k));
    800066ea:	018d9633          	sll	a2,s11,s8
    800066ee:	85ca                	mv	a1,s2
    800066f0:	856a                	mv	a0,s10
    800066f2:	ffffa097          	auipc	ra,0xffffa
    800066f6:	ea6080e7          	jalr	-346(ra) # 80000598 <printf>
    lst_print(&bd_sizes[k].free);
    800066fa:	005c1a13          	slli	s4,s8,0x5
    800066fe:	000b3503          	ld	a0,0(s6)
    80006702:	9552                	add	a0,a0,s4
    80006704:	00001097          	auipc	ra,0x1
    80006708:	acc080e7          	jalr	-1332(ra) # 800071d0 <lst_print>
    printf("  alloc:");
    8000670c:	8566                	mv	a0,s9
    8000670e:	ffffa097          	auipc	ra,0xffffa
    80006712:	e8a080e7          	jalr	-374(ra) # 80000598 <printf>
    for (int b = 0; b < NBLK(k); b++) {
    80006716:	0009a783          	lw	a5,0(s3)
    8000671a:	37fd                	addiw	a5,a5,-1
    8000671c:	412787bb          	subw	a5,a5,s2
    80006720:	00fa97bb          	sllw	a5,s5,a5
    80006724:	02f05c63          	blez	a5,8000675c <bd_print+0x120>
    80006728:	4481                	li	s1,0
     printf(" %d", bit_isset(bd_sizes[k].alloc, b));
    8000672a:	000b3783          	ld	a5,0(s6)
    8000672e:	97d2                	add	a5,a5,s4
    80006730:	85a6                	mv	a1,s1
    80006732:	6b88                	ld	a0,16(a5)
    80006734:	00000097          	auipc	ra,0x0
    80006738:	e38080e7          	jalr	-456(ra) # 8000656c <bit_isset>
    8000673c:	85aa                	mv	a1,a0
    8000673e:	855e                	mv	a0,s7
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e58080e7          	jalr	-424(ra) # 80000598 <printf>
    for (int b = 0; b < NBLK(k); b++) {
    80006748:	2485                	addiw	s1,s1,1
    8000674a:	0009a783          	lw	a5,0(s3)
    8000674e:	37fd                	addiw	a5,a5,-1
    80006750:	412787bb          	subw	a5,a5,s2
    80006754:	00fa97bb          	sllw	a5,s5,a5
    80006758:	fcf4c9e3          	blt	s1,a5,8000672a <bd_print+0xee>
    printf("\n");
    8000675c:	00002517          	auipc	a0,0x2
    80006760:	a5450513          	addi	a0,a0,-1452 # 800081b0 <userret+0x120>
    80006764:	ffffa097          	auipc	ra,0xffffa
    80006768:	e34080e7          	jalr	-460(ra) # 80000598 <printf>
    if(k > 0) {
    8000676c:	000c079b          	sext.w	a5,s8
    80006770:	f6f054e3          	blez	a5,800066d8 <bd_print+0x9c>
      printf("  split:");
    80006774:	00002517          	auipc	a0,0x2
    80006778:	17450513          	addi	a0,a0,372 # 800088e8 <userret+0x858>
    8000677c:	ffffa097          	auipc	ra,0xffffa
    80006780:	e1c080e7          	jalr	-484(ra) # 80000598 <printf>
      for (int b = 0; b < NBLK(k); b++) {
    80006784:	0009a783          	lw	a5,0(s3)
    80006788:	37fd                	addiw	a5,a5,-1
    8000678a:	412787bb          	subw	a5,a5,s2
    8000678e:	00fa97bb          	sllw	a5,s5,a5
    80006792:	f2f05be3          	blez	a5,800066c8 <bd_print+0x8c>
    80006796:	4481                	li	s1,0
    80006798:	bdfd                	j	80006696 <bd_print+0x5a>
    }
  }
}
    8000679a:	70a6                	ld	ra,104(sp)
    8000679c:	7406                	ld	s0,96(sp)
    8000679e:	64e6                	ld	s1,88(sp)
    800067a0:	6946                	ld	s2,80(sp)
    800067a2:	69a6                	ld	s3,72(sp)
    800067a4:	6a06                	ld	s4,64(sp)
    800067a6:	7ae2                	ld	s5,56(sp)
    800067a8:	7b42                	ld	s6,48(sp)
    800067aa:	7ba2                	ld	s7,40(sp)
    800067ac:	7c02                	ld	s8,32(sp)
    800067ae:	6ce2                	ld	s9,24(sp)
    800067b0:	6d42                	ld	s10,16(sp)
    800067b2:	6da2                	ld	s11,8(sp)
    800067b4:	6165                	addi	sp,sp,112
    800067b6:	8082                	ret
    800067b8:	8082                	ret

00000000800067ba <bit_get>:

int bit_get(char *array,int index){
    800067ba:	1141                	addi	sp,sp,-16
    800067bc:	e422                	sd	s0,8(sp)
    800067be:	0800                	addi	s0,sp,16
  index>>=1;
    800067c0:	4015d79b          	sraiw	a5,a1,0x1
  char b=array[index/8];
  char m=(1<<(index%8));
    800067c4:	95fd                	srai	a1,a1,0x3f
    800067c6:	01d5d59b          	srliw	a1,a1,0x1d
    800067ca:	9fad                	addw	a5,a5,a1
    800067cc:	0077f713          	andi	a4,a5,7
    800067d0:	9f0d                	subw	a4,a4,a1
    800067d2:	4585                	li	a1,1
    800067d4:	00e595bb          	sllw	a1,a1,a4
    800067d8:	0ff5f593          	andi	a1,a1,255
  char b=array[index/8];
    800067dc:	4037d79b          	sraiw	a5,a5,0x3
    800067e0:	97aa                	add	a5,a5,a0
  return (b&m)==m;
    800067e2:	0007c503          	lbu	a0,0(a5)
    800067e6:	8d6d                	and	a0,a0,a1
    800067e8:	8d0d                	sub	a0,a0,a1
}
    800067ea:	00153513          	seqz	a0,a0
    800067ee:	6422                	ld	s0,8(sp)
    800067f0:	0141                	addi	sp,sp,16
    800067f2:	8082                	ret

00000000800067f4 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800067f4:	1141                	addi	sp,sp,-16
    800067f6:	e422                	sd	s0,8(sp)
    800067f8:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800067fa:	47c1                	li	a5,16
    800067fc:	00a7fb63          	bgeu	a5,a0,80006812 <firstk+0x1e>
    80006800:	872a                	mv	a4,a0
  int k = 0;
    80006802:	4501                	li	a0,0
    k++;
    80006804:	2505                	addiw	a0,a0,1
    size *= 2;
    80006806:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006808:	fee7eee3          	bltu	a5,a4,80006804 <firstk+0x10>
  }
  return k;
}
    8000680c:	6422                	ld	s0,8(sp)
    8000680e:	0141                	addi	sp,sp,16
    80006810:	8082                	ret
  int k = 0;
    80006812:	4501                	li	a0,0
    80006814:	bfe5                	j	8000680c <firstk+0x18>

0000000080006816 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006816:	1141                	addi	sp,sp,-16
    80006818:	e422                	sd	s0,8(sp)
    8000681a:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    8000681c:	00023797          	auipc	a5,0x23
    80006820:	82c7b783          	ld	a5,-2004(a5) # 80029048 <bd_base>
    80006824:	9d9d                	subw	a1,a1,a5
    80006826:	47c1                	li	a5,16
    80006828:	00a79533          	sll	a0,a5,a0
    8000682c:	02a5c533          	div	a0,a1,a0
}
    80006830:	2501                	sext.w	a0,a0
    80006832:	6422                	ld	s0,8(sp)
    80006834:	0141                	addi	sp,sp,16
    80006836:	8082                	ret

0000000080006838 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006838:	1141                	addi	sp,sp,-16
    8000683a:	e422                	sd	s0,8(sp)
    8000683c:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000683e:	47c1                	li	a5,16
    80006840:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    80006844:	02b787bb          	mulw	a5,a5,a1
}
    80006848:	00023517          	auipc	a0,0x23
    8000684c:	80053503          	ld	a0,-2048(a0) # 80029048 <bd_base>
    80006850:	953e                	add	a0,a0,a5
    80006852:	6422                	ld	s0,8(sp)
    80006854:	0141                	addi	sp,sp,16
    80006856:	8082                	ret

0000000080006858 <bd_malloc>:

void *
bd_malloc(uint64 nbytes)
{
    80006858:	7159                	addi	sp,sp,-112
    8000685a:	f486                	sd	ra,104(sp)
    8000685c:	f0a2                	sd	s0,96(sp)
    8000685e:	eca6                	sd	s1,88(sp)
    80006860:	e8ca                	sd	s2,80(sp)
    80006862:	e4ce                	sd	s3,72(sp)
    80006864:	e0d2                	sd	s4,64(sp)
    80006866:	fc56                	sd	s5,56(sp)
    80006868:	f85a                	sd	s6,48(sp)
    8000686a:	f45e                	sd	s7,40(sp)
    8000686c:	f062                	sd	s8,32(sp)
    8000686e:	ec66                	sd	s9,24(sp)
    80006870:	e86a                	sd	s10,16(sp)
    80006872:	e46e                	sd	s11,8(sp)
    80006874:	1880                	addi	s0,sp,112
    80006876:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006878:	00022517          	auipc	a0,0x22
    8000687c:	78850513          	addi	a0,a0,1928 # 80029000 <lock>
    80006880:	ffffa097          	auipc	ra,0xffffa
    80006884:	26a080e7          	jalr	618(ra) # 80000aea <acquire>
  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006888:	8526                	mv	a0,s1
    8000688a:	00000097          	auipc	ra,0x0
    8000688e:	f6a080e7          	jalr	-150(ra) # 800067f4 <firstk>
  for (k = fk; k < nsizes; k++) {
    80006892:	00022797          	auipc	a5,0x22
    80006896:	7c67a783          	lw	a5,1990(a5) # 80029058 <nsizes>
    8000689a:	02f55d63          	bge	a0,a5,800068d4 <bd_malloc+0x7c>
    8000689e:	8c2a                	mv	s8,a0
    800068a0:	00551913          	slli	s2,a0,0x5
    800068a4:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    800068a6:	00022997          	auipc	s3,0x22
    800068aa:	7aa98993          	addi	s3,s3,1962 # 80029050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    800068ae:	00022a17          	auipc	s4,0x22
    800068b2:	7aaa0a13          	addi	s4,s4,1962 # 80029058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    800068b6:	0009b503          	ld	a0,0(s3)
    800068ba:	954a                	add	a0,a0,s2
    800068bc:	00001097          	auipc	ra,0x1
    800068c0:	89a080e7          	jalr	-1894(ra) # 80007156 <lst_empty>
    800068c4:	c115                	beqz	a0,800068e8 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    800068c6:	2485                	addiw	s1,s1,1
    800068c8:	02090913          	addi	s2,s2,32
    800068cc:	000a2783          	lw	a5,0(s4)
    800068d0:	fef4c3e3          	blt	s1,a5,800068b6 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    800068d4:	00022517          	auipc	a0,0x22
    800068d8:	72c50513          	addi	a0,a0,1836 # 80029000 <lock>
    800068dc:	ffffa097          	auipc	ra,0xffffa
    800068e0:	276080e7          	jalr	630(ra) # 80000b52 <release>
    return 0;
    800068e4:	4b01                	li	s6,0
    800068e6:	a0e1                	j	800069ae <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800068e8:	00022797          	auipc	a5,0x22
    800068ec:	7707a783          	lw	a5,1904(a5) # 80029058 <nsizes>
    800068f0:	fef4d2e3          	bge	s1,a5,800068d4 <bd_malloc+0x7c>
  }

  // Found one; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800068f4:	00549993          	slli	s3,s1,0x5
    800068f8:	00022917          	auipc	s2,0x22
    800068fc:	75890913          	addi	s2,s2,1880 # 80029050 <bd_sizes>
    80006900:	00093503          	ld	a0,0(s2)
    80006904:	954e                	add	a0,a0,s3
    80006906:	00001097          	auipc	ra,0x1
    8000690a:	87c080e7          	jalr	-1924(ra) # 80007182 <lst_pop>
    8000690e:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006910:	00022597          	auipc	a1,0x22
    80006914:	7385b583          	ld	a1,1848(a1) # 80029048 <bd_base>
    80006918:	40b505bb          	subw	a1,a0,a1
    8000691c:	47c1                	li	a5,16
    8000691e:	009797b3          	sll	a5,a5,s1
    80006922:	02f5c5b3          	div	a1,a1,a5
  //bit_set(bd_sizes[k].alloc, blk_index(k, p));
  bd_toggle(bd_sizes[k].alloc,blk_index(k,p));
    80006926:	00093783          	ld	a5,0(s2)
    8000692a:	97ce                	add	a5,a5,s3
    8000692c:	2581                	sext.w	a1,a1
    8000692e:	6b88                	ld	a0,16(a5)
    80006930:	00000097          	auipc	ra,0x0
    80006934:	cd8080e7          	jalr	-808(ra) # 80006608 <bd_toggle>
  for(; k > fk; k--) {
    80006938:	069c5363          	bge	s8,s1,8000699e <bd_malloc+0x146>
    char *q = p + BLK_SIZE(k-1);
    8000693c:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000693e:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006940:	00022d17          	auipc	s10,0x22
    80006944:	708d0d13          	addi	s10,s10,1800 # 80029048 <bd_base>
    char *q = p + BLK_SIZE(k-1);
    80006948:	85a6                	mv	a1,s1
    8000694a:	34fd                	addiw	s1,s1,-1
    8000694c:	009b9ab3          	sll	s5,s7,s1
    80006950:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006954:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    80006958:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    8000695c:	412b093b          	subw	s2,s6,s2
    80006960:	00bb95b3          	sll	a1,s7,a1
    80006964:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006968:	013a07b3          	add	a5,s4,s3
    8000696c:	2581                	sext.w	a1,a1
    8000696e:	6f88                	ld	a0,24(a5)
    80006970:	00000097          	auipc	ra,0x0
    80006974:	c34080e7          	jalr	-972(ra) # 800065a4 <bit_set>
    //bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    bd_toggle(bd_sizes[k-1].alloc,blk_index(k-1,p));
    80006978:	1981                	addi	s3,s3,-32
    8000697a:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    8000697c:	035945b3          	div	a1,s2,s5
    bd_toggle(bd_sizes[k-1].alloc,blk_index(k-1,p));
    80006980:	2581                	sext.w	a1,a1
    80006982:	010a3503          	ld	a0,16(s4)
    80006986:	00000097          	auipc	ra,0x0
    8000698a:	c82080e7          	jalr	-894(ra) # 80006608 <bd_toggle>
    lst_push(&bd_sizes[k-1].free, q);
    8000698e:	85e6                	mv	a1,s9
    80006990:	8552                	mv	a0,s4
    80006992:	00001097          	auipc	ra,0x1
    80006996:	826080e7          	jalr	-2010(ra) # 800071b8 <lst_push>
  for(; k > fk; k--) {
    8000699a:	fb8497e3          	bne	s1,s8,80006948 <bd_malloc+0xf0>
  }
  //printf("malloc: %p size class %d\n", p, fk);
  release(&lock);
    8000699e:	00022517          	auipc	a0,0x22
    800069a2:	66250513          	addi	a0,a0,1634 # 80029000 <lock>
    800069a6:	ffffa097          	auipc	ra,0xffffa
    800069aa:	1ac080e7          	jalr	428(ra) # 80000b52 <release>
  return p;
}
    800069ae:	855a                	mv	a0,s6
    800069b0:	70a6                	ld	ra,104(sp)
    800069b2:	7406                	ld	s0,96(sp)
    800069b4:	64e6                	ld	s1,88(sp)
    800069b6:	6946                	ld	s2,80(sp)
    800069b8:	69a6                	ld	s3,72(sp)
    800069ba:	6a06                	ld	s4,64(sp)
    800069bc:	7ae2                	ld	s5,56(sp)
    800069be:	7b42                	ld	s6,48(sp)
    800069c0:	7ba2                	ld	s7,40(sp)
    800069c2:	7c02                	ld	s8,32(sp)
    800069c4:	6ce2                	ld	s9,24(sp)
    800069c6:	6d42                	ld	s10,16(sp)
    800069c8:	6da2                	ld	s11,8(sp)
    800069ca:	6165                	addi	sp,sp,112
    800069cc:	8082                	ret

00000000800069ce <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    800069ce:	7139                	addi	sp,sp,-64
    800069d0:	fc06                	sd	ra,56(sp)
    800069d2:	f822                	sd	s0,48(sp)
    800069d4:	f426                	sd	s1,40(sp)
    800069d6:	f04a                	sd	s2,32(sp)
    800069d8:	ec4e                	sd	s3,24(sp)
    800069da:	e852                	sd	s4,16(sp)
    800069dc:	e456                	sd	s5,8(sp)
    800069de:	e05a                	sd	s6,0(sp)
    800069e0:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    800069e2:	00022a97          	auipc	s5,0x22
    800069e6:	676aaa83          	lw	s5,1654(s5) # 80029058 <nsizes>
  return n / BLK_SIZE(k);
    800069ea:	00022a17          	auipc	s4,0x22
    800069ee:	65ea3a03          	ld	s4,1630(s4) # 80029048 <bd_base>
    800069f2:	41450a3b          	subw	s4,a0,s4
    800069f6:	00022497          	auipc	s1,0x22
    800069fa:	65a4b483          	ld	s1,1626(s1) # 80029050 <bd_sizes>
    800069fe:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006a02:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006a04:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006a06:	03595363          	bge	s2,s5,80006a2c <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006a0a:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006a0e:	013b15b3          	sll	a1,s6,s3
    80006a12:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006a16:	2581                	sext.w	a1,a1
    80006a18:	6088                	ld	a0,0(s1)
    80006a1a:	00000097          	auipc	ra,0x0
    80006a1e:	b52080e7          	jalr	-1198(ra) # 8000656c <bit_isset>
    80006a22:	02048493          	addi	s1,s1,32
    80006a26:	e501                	bnez	a0,80006a2e <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006a28:	894e                	mv	s2,s3
    80006a2a:	bff1                	j	80006a06 <size+0x38>
      return k;
    }
  }
  return 0;
    80006a2c:	4901                	li	s2,0
}
    80006a2e:	854a                	mv	a0,s2
    80006a30:	70e2                	ld	ra,56(sp)
    80006a32:	7442                	ld	s0,48(sp)
    80006a34:	74a2                	ld	s1,40(sp)
    80006a36:	7902                	ld	s2,32(sp)
    80006a38:	69e2                	ld	s3,24(sp)
    80006a3a:	6a42                	ld	s4,16(sp)
    80006a3c:	6aa2                	ld	s5,8(sp)
    80006a3e:	6b02                	ld	s6,0(sp)
    80006a40:	6121                	addi	sp,sp,64
    80006a42:	8082                	ret

0000000080006a44 <bd_free>:

void
bd_free(void *p) {
    80006a44:	7159                	addi	sp,sp,-112
    80006a46:	f486                	sd	ra,104(sp)
    80006a48:	f0a2                	sd	s0,96(sp)
    80006a4a:	eca6                	sd	s1,88(sp)
    80006a4c:	e8ca                	sd	s2,80(sp)
    80006a4e:	e4ce                	sd	s3,72(sp)
    80006a50:	e0d2                	sd	s4,64(sp)
    80006a52:	fc56                	sd	s5,56(sp)
    80006a54:	f85a                	sd	s6,48(sp)
    80006a56:	f45e                	sd	s7,40(sp)
    80006a58:	f062                	sd	s8,32(sp)
    80006a5a:	ec66                	sd	s9,24(sp)
    80006a5c:	e86a                	sd	s10,16(sp)
    80006a5e:	e46e                	sd	s11,8(sp)
    80006a60:	1880                	addi	s0,sp,112
    80006a62:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006a64:	00022517          	auipc	a0,0x22
    80006a68:	59c50513          	addi	a0,a0,1436 # 80029000 <lock>
    80006a6c:	ffffa097          	auipc	ra,0xffffa
    80006a70:	07e080e7          	jalr	126(ra) # 80000aea <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006a74:	8556                	mv	a0,s5
    80006a76:	00000097          	auipc	ra,0x0
    80006a7a:	f58080e7          	jalr	-168(ra) # 800069ce <size>
    80006a7e:	84aa                	mv	s1,a0
    80006a80:	00022797          	auipc	a5,0x22
    80006a84:	5d87a783          	lw	a5,1496(a5) # 80029058 <nsizes>
    80006a88:	37fd                	addiw	a5,a5,-1
    80006a8a:	0af55d63          	bge	a0,a5,80006b44 <bd_free+0x100>
    80006a8e:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    80006a92:	00022c17          	auipc	s8,0x22
    80006a96:	5b6c0c13          	addi	s8,s8,1462 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006a9a:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bd_toggle(bd_sizes[k].alloc,bi);
    80006a9c:	00022b17          	auipc	s6,0x22
    80006aa0:	5b4b0b13          	addi	s6,s6,1460 # 80029050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006aa4:	00022c97          	auipc	s9,0x22
    80006aa8:	5b4c8c93          	addi	s9,s9,1460 # 80029058 <nsizes>
    80006aac:	a82d                	j	80006ae6 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006aae:	fff58d9b          	addiw	s11,a1,-1
    80006ab2:	a881                	j	80006b02 <bd_free+0xbe>
    q = addr(k, buddy);
    lst_remove(q);
    if(buddy % 2 == 0) {
      p = q;
    }
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006ab4:	020a0a13          	addi	s4,s4,32
    80006ab8:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006aba:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006abe:	40ba85bb          	subw	a1,s5,a1
    80006ac2:	009b97b3          	sll	a5,s7,s1
    80006ac6:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006aca:	000b3783          	ld	a5,0(s6)
    80006ace:	97d2                	add	a5,a5,s4
    80006ad0:	2581                	sext.w	a1,a1
    80006ad2:	6f88                	ld	a0,24(a5)
    80006ad4:	00000097          	auipc	ra,0x0
    80006ad8:	b00080e7          	jalr	-1280(ra) # 800065d4 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006adc:	000ca783          	lw	a5,0(s9)
    80006ae0:	37fd                	addiw	a5,a5,-1
    80006ae2:	06f4d163          	bge	s1,a5,80006b44 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80006ae6:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006aea:	009b99b3          	sll	s3,s7,s1
    80006aee:	412a87bb          	subw	a5,s5,s2
    80006af2:	0337c7b3          	div	a5,a5,s3
    80006af6:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006afa:	8b85                	andi	a5,a5,1
    80006afc:	fbcd                	bnez	a5,80006aae <bd_free+0x6a>
    80006afe:	00158d9b          	addiw	s11,a1,1
    bd_toggle(bd_sizes[k].alloc,bi);
    80006b02:	000b3d03          	ld	s10,0(s6)
    80006b06:	9d52                	add	s10,s10,s4
    80006b08:	010d3503          	ld	a0,16(s10)
    80006b0c:	00000097          	auipc	ra,0x0
    80006b10:	afc080e7          	jalr	-1284(ra) # 80006608 <bd_toggle>
    if(bit_get(bd_sizes[k].alloc,buddy)){
    80006b14:	85ee                	mv	a1,s11
    80006b16:	010d3503          	ld	a0,16(s10)
    80006b1a:	00000097          	auipc	ra,0x0
    80006b1e:	ca0080e7          	jalr	-864(ra) # 800067ba <bit_get>
    80006b22:	e10d                	bnez	a0,80006b44 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80006b24:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006b28:	03b989bb          	mulw	s3,s3,s11
    80006b2c:	994e                	add	s2,s2,s3
    lst_remove(q);
    80006b2e:	854a                	mv	a0,s2
    80006b30:	00000097          	auipc	ra,0x0
    80006b34:	63c080e7          	jalr	1596(ra) # 8000716c <lst_remove>
    if(buddy % 2 == 0) {
    80006b38:	001d7d13          	andi	s10,s10,1
    80006b3c:	f60d1ce3          	bnez	s10,80006ab4 <bd_free+0x70>
      p = q;
    80006b40:	8aca                	mv	s5,s2
    80006b42:	bf8d                	j	80006ab4 <bd_free+0x70>
  }
  //printf("free %p @ %d\n", p, k);
  lst_push(&bd_sizes[k].free, p);
    80006b44:	0496                	slli	s1,s1,0x5
    80006b46:	85d6                	mv	a1,s5
    80006b48:	00022517          	auipc	a0,0x22
    80006b4c:	50853503          	ld	a0,1288(a0) # 80029050 <bd_sizes>
    80006b50:	9526                	add	a0,a0,s1
    80006b52:	00000097          	auipc	ra,0x0
    80006b56:	666080e7          	jalr	1638(ra) # 800071b8 <lst_push>
  release(&lock);
    80006b5a:	00022517          	auipc	a0,0x22
    80006b5e:	4a650513          	addi	a0,a0,1190 # 80029000 <lock>
    80006b62:	ffffa097          	auipc	ra,0xffffa
    80006b66:	ff0080e7          	jalr	-16(ra) # 80000b52 <release>
}
    80006b6a:	70a6                	ld	ra,104(sp)
    80006b6c:	7406                	ld	s0,96(sp)
    80006b6e:	64e6                	ld	s1,88(sp)
    80006b70:	6946                	ld	s2,80(sp)
    80006b72:	69a6                	ld	s3,72(sp)
    80006b74:	6a06                	ld	s4,64(sp)
    80006b76:	7ae2                	ld	s5,56(sp)
    80006b78:	7b42                	ld	s6,48(sp)
    80006b7a:	7ba2                	ld	s7,40(sp)
    80006b7c:	7c02                	ld	s8,32(sp)
    80006b7e:	6ce2                	ld	s9,24(sp)
    80006b80:	6d42                	ld	s10,16(sp)
    80006b82:	6da2                	ld	s11,8(sp)
    80006b84:	6165                	addi	sp,sp,112
    80006b86:	8082                	ret

0000000080006b88 <blk_index_next>:

//get the index for the next block
int
blk_index_next(int k, char *p) {
    80006b88:	1141                	addi	sp,sp,-16
    80006b8a:	e422                	sd	s0,8(sp)
    80006b8c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006b8e:	00022797          	auipc	a5,0x22
    80006b92:	4ba7b783          	ld	a5,1210(a5) # 80029048 <bd_base>
    80006b96:	8d9d                	sub	a1,a1,a5
    80006b98:	47c1                	li	a5,16
    80006b9a:	00a797b3          	sll	a5,a5,a0
    80006b9e:	02f5c533          	div	a0,a1,a5
    80006ba2:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006ba4:	02f5e5b3          	rem	a1,a1,a5
    80006ba8:	c191                	beqz	a1,80006bac <blk_index_next+0x24>
      n++;
    80006baa:	2505                	addiw	a0,a0,1
  return n ;
}
    80006bac:	6422                	ld	s0,8(sp)
    80006bae:	0141                	addi	sp,sp,16
    80006bb0:	8082                	ret

0000000080006bb2 <log2>:

//get the #of bits
int
log2(uint64 n) {
    80006bb2:	1141                	addi	sp,sp,-16
    80006bb4:	e422                	sd	s0,8(sp)
    80006bb6:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006bb8:	4705                	li	a4,1
    80006bba:	00a77b63          	bgeu	a4,a0,80006bd0 <log2+0x1e>
    80006bbe:	87aa                	mv	a5,a0
  int k = 0;
    80006bc0:	4501                	li	a0,0
    k++;
    80006bc2:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006bc4:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006bc6:	fef76ee3          	bltu	a4,a5,80006bc2 <log2+0x10>
  }
  return k;
}
    80006bca:	6422                	ld	s0,8(sp)
    80006bcc:	0141                	addi	sp,sp,16
    80006bce:	8082                	ret
  int k = 0;
    80006bd0:	4501                	li	a0,0
    80006bd2:	bfe5                	j	80006bca <log2+0x18>

0000000080006bd4 <bd_mark>:

void bd_mark(void *start,void *stop){
    80006bd4:	711d                	addi	sp,sp,-96
    80006bd6:	ec86                	sd	ra,88(sp)
    80006bd8:	e8a2                	sd	s0,80(sp)
    80006bda:	e4a6                	sd	s1,72(sp)
    80006bdc:	e0ca                	sd	s2,64(sp)
    80006bde:	fc4e                	sd	s3,56(sp)
    80006be0:	f852                	sd	s4,48(sp)
    80006be2:	f456                	sd	s5,40(sp)
    80006be4:	f05a                	sd	s6,32(sp)
    80006be6:	ec5e                	sd	s7,24(sp)
    80006be8:	e862                	sd	s8,16(sp)
    80006bea:	e466                	sd	s9,8(sp)
    80006bec:	e06a                	sd	s10,0(sp)
    80006bee:	1080                	addi	s0,sp,96
  int bi,bj;

  if(((uint64) start%LEAF_SIZE!=0)||((uint64)stop%LEAF_SIZE!=0))
    80006bf0:	00b56933          	or	s2,a0,a1
    80006bf4:	00f97913          	andi	s2,s2,15
    80006bf8:	04091263          	bnez	s2,80006c3c <bd_mark+0x68>
    80006bfc:	8b2a                	mv	s6,a0
    80006bfe:	8bae                	mv	s7,a1
    panic("bd_mark");

  for(int k=0;k<nsizes;k++){
    80006c00:	00022c17          	auipc	s8,0x22
    80006c04:	458c2c03          	lw	s8,1112(s8) # 80029058 <nsizes>
    80006c08:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006c0a:	00022d17          	auipc	s10,0x22
    80006c0e:	43ed0d13          	addi	s10,s10,1086 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006c12:	4cc1                	li	s9,16
    bi=blk_index(k,start);
    bj=blk_index_next(k,stop);
    for(;bi<bj;bi++){
      if(k>0){
	     bit_set(bd_sizes[k].split,bi);
    80006c14:	00022a97          	auipc	s5,0x22
    80006c18:	43ca8a93          	addi	s5,s5,1084 # 80029050 <bd_sizes>
  for(int k=0;k<nsizes;k++){
    80006c1c:	07804563          	bgtz	s8,80006c86 <bd_mark+0xb2>
      }
      //bit_set(bd_sizes[k].alloc,bi);
	  bd_toggle(bd_sizes[k].alloc,bi);
    }
  }
}
    80006c20:	60e6                	ld	ra,88(sp)
    80006c22:	6446                	ld	s0,80(sp)
    80006c24:	64a6                	ld	s1,72(sp)
    80006c26:	6906                	ld	s2,64(sp)
    80006c28:	79e2                	ld	s3,56(sp)
    80006c2a:	7a42                	ld	s4,48(sp)
    80006c2c:	7aa2                	ld	s5,40(sp)
    80006c2e:	7b02                	ld	s6,32(sp)
    80006c30:	6be2                	ld	s7,24(sp)
    80006c32:	6c42                	ld	s8,16(sp)
    80006c34:	6ca2                	ld	s9,8(sp)
    80006c36:	6d02                	ld	s10,0(sp)
    80006c38:	6125                	addi	sp,sp,96
    80006c3a:	8082                	ret
    panic("bd_mark");
    80006c3c:	00002517          	auipc	a0,0x2
    80006c40:	cbc50513          	addi	a0,a0,-836 # 800088f8 <userret+0x868>
    80006c44:	ffffa097          	auipc	ra,0xffffa
    80006c48:	90a080e7          	jalr	-1782(ra) # 8000054e <panic>
	  bd_toggle(bd_sizes[k].alloc,bi);
    80006c4c:	000ab783          	ld	a5,0(s5)
    80006c50:	97ca                	add	a5,a5,s2
    80006c52:	85a6                	mv	a1,s1
    80006c54:	6b88                	ld	a0,16(a5)
    80006c56:	00000097          	auipc	ra,0x0
    80006c5a:	9b2080e7          	jalr	-1614(ra) # 80006608 <bd_toggle>
    for(;bi<bj;bi++){
    80006c5e:	2485                	addiw	s1,s1,1
    80006c60:	009a0e63          	beq	s4,s1,80006c7c <bd_mark+0xa8>
      if(k>0){
    80006c64:	ff3054e3          	blez	s3,80006c4c <bd_mark+0x78>
	     bit_set(bd_sizes[k].split,bi);
    80006c68:	000ab783          	ld	a5,0(s5)
    80006c6c:	97ca                	add	a5,a5,s2
    80006c6e:	85a6                	mv	a1,s1
    80006c70:	6f88                	ld	a0,24(a5)
    80006c72:	00000097          	auipc	ra,0x0
    80006c76:	932080e7          	jalr	-1742(ra) # 800065a4 <bit_set>
    80006c7a:	bfc9                	j	80006c4c <bd_mark+0x78>
  for(int k=0;k<nsizes;k++){
    80006c7c:	2985                	addiw	s3,s3,1
    80006c7e:	02090913          	addi	s2,s2,32
    80006c82:	f9898fe3          	beq	s3,s8,80006c20 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006c86:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006c8a:	409b04bb          	subw	s1,s6,s1
    80006c8e:	013c97b3          	sll	a5,s9,s3
    80006c92:	02f4c4b3          	div	s1,s1,a5
    80006c96:	2481                	sext.w	s1,s1
    bj=blk_index_next(k,stop);
    80006c98:	85de                	mv	a1,s7
    80006c9a:	854e                	mv	a0,s3
    80006c9c:	00000097          	auipc	ra,0x0
    80006ca0:	eec080e7          	jalr	-276(ra) # 80006b88 <blk_index_next>
    80006ca4:	8a2a                	mv	s4,a0
    for(;bi<bj;bi++){
    80006ca6:	faa4cfe3          	blt	s1,a0,80006c64 <bd_mark+0x90>
    80006caa:	bfc9                	j	80006c7c <bd_mark+0xa8>

0000000080006cac <bd_initfree_pair>:

int bd_initfree_pair(int k,int bi,void *allow_left,void *allow_right){
    80006cac:	715d                	addi	sp,sp,-80
    80006cae:	e486                	sd	ra,72(sp)
    80006cb0:	e0a2                	sd	s0,64(sp)
    80006cb2:	fc26                	sd	s1,56(sp)
    80006cb4:	f84a                	sd	s2,48(sp)
    80006cb6:	f44e                	sd	s3,40(sp)
    80006cb8:	f052                	sd	s4,32(sp)
    80006cba:	ec56                	sd	s5,24(sp)
    80006cbc:	e85a                	sd	s6,16(sp)
    80006cbe:	e45e                	sd	s7,8(sp)
    80006cc0:	0880                	addi	s0,sp,80
    80006cc2:	892a                	mv	s2,a0
    80006cc4:	89b2                	mv	s3,a2
    80006cc6:	8a36                	mv	s4,a3
	int buddy=(bi%2==0)?bi+1:bi-1;
    80006cc8:	00058a9b          	sext.w	s5,a1
    80006ccc:	0015f793          	andi	a5,a1,1
    80006cd0:	e7bd                	bnez	a5,80006d3e <bd_initfree_pair+0x92>
    80006cd2:	00158b9b          	addiw	s7,a1,1
	int free=0;
	if(bit_get(bd_sizes[k].alloc,bi)){
    80006cd6:	00591793          	slli	a5,s2,0x5
    80006cda:	00022b17          	auipc	s6,0x22
    80006cde:	376b3b03          	ld	s6,886(s6) # 80029050 <bd_sizes>
    80006ce2:	9b3e                	add	s6,s6,a5
    80006ce4:	010b3503          	ld	a0,16(s6)
    80006ce8:	00000097          	auipc	ra,0x0
    80006cec:	ad2080e7          	jalr	-1326(ra) # 800067ba <bit_get>
    80006cf0:	84aa                	mv	s1,a0
    80006cf2:	c915                	beqz	a0,80006d26 <bd_initfree_pair+0x7a>
		free=BLK_SIZE(k);
    80006cf4:	44c1                	li	s1,16
    80006cf6:	012494b3          	sll	s1,s1,s2
    80006cfa:	2481                	sext.w	s1,s1
  int n = bi * BLK_SIZE(k);
    80006cfc:	87a6                	mv	a5,s1
  return (char *) bd_base + n;
    80006cfe:	00022717          	auipc	a4,0x22
    80006d02:	34a73703          	ld	a4,842(a4) # 80029048 <bd_base>
    80006d06:	029b85bb          	mulw	a1,s7,s1
    80006d0a:	95ba                	add	a1,a1,a4
		if(in_range(allow_left,allow_right,addr(k,buddy))){
    80006d0c:	0135e463          	bltu	a1,s3,80006d14 <bd_initfree_pair+0x68>
    80006d10:	0345ea63          	bltu	a1,s4,80006d44 <bd_initfree_pair+0x98>
  return (char *) bd_base + n;
    80006d14:	02fa87bb          	mulw	a5,s5,a5
			lst_push(&bd_sizes[k].free,addr(k,buddy));
		}
		else{
			lst_push(&bd_sizes[k].free,addr(k,bi));
    80006d18:	00f705b3          	add	a1,a4,a5
    80006d1c:	855a                	mv	a0,s6
    80006d1e:	00000097          	auipc	ra,0x0
    80006d22:	49a080e7          	jalr	1178(ra) # 800071b8 <lst_push>
		}
	}
	return free;
}
    80006d26:	8526                	mv	a0,s1
    80006d28:	60a6                	ld	ra,72(sp)
    80006d2a:	6406                	ld	s0,64(sp)
    80006d2c:	74e2                	ld	s1,56(sp)
    80006d2e:	7942                	ld	s2,48(sp)
    80006d30:	79a2                	ld	s3,40(sp)
    80006d32:	7a02                	ld	s4,32(sp)
    80006d34:	6ae2                	ld	s5,24(sp)
    80006d36:	6b42                	ld	s6,16(sp)
    80006d38:	6ba2                	ld	s7,8(sp)
    80006d3a:	6161                	addi	sp,sp,80
    80006d3c:	8082                	ret
	int buddy=(bi%2==0)?bi+1:bi-1;
    80006d3e:	fff58b9b          	addiw	s7,a1,-1
    80006d42:	bf51                	j	80006cd6 <bd_initfree_pair+0x2a>
			lst_push(&bd_sizes[k].free,addr(k,buddy));
    80006d44:	855a                	mv	a0,s6
    80006d46:	00000097          	auipc	ra,0x0
    80006d4a:	472080e7          	jalr	1138(ra) # 800071b8 <lst_push>
    80006d4e:	bfe1                	j	80006d26 <bd_initfree_pair+0x7a>

0000000080006d50 <bd_initfree>:

int bd_initfree(void *bd_left,void *bd_right,void *allow_left,void *allow_right){
    80006d50:	7119                	addi	sp,sp,-128
    80006d52:	fc86                	sd	ra,120(sp)
    80006d54:	f8a2                	sd	s0,112(sp)
    80006d56:	f4a6                	sd	s1,104(sp)
    80006d58:	f0ca                	sd	s2,96(sp)
    80006d5a:	ecce                	sd	s3,88(sp)
    80006d5c:	e8d2                	sd	s4,80(sp)
    80006d5e:	e4d6                	sd	s5,72(sp)
    80006d60:	e0da                	sd	s6,64(sp)
    80006d62:	fc5e                	sd	s7,56(sp)
    80006d64:	f862                	sd	s8,48(sp)
    80006d66:	f466                	sd	s9,40(sp)
    80006d68:	f06a                	sd	s10,32(sp)
    80006d6a:	ec6e                	sd	s11,24(sp)
    80006d6c:	0100                	addi	s0,sp,128
    80006d6e:	f8a43423          	sd	a0,-120(s0)
	int free=0;

	for(int k=0;k<MAXSIZE;k++){
    80006d72:	00022717          	auipc	a4,0x22
    80006d76:	2e672703          	lw	a4,742(a4) # 80029058 <nsizes>
    80006d7a:	4785                	li	a5,1
    80006d7c:	08e7d163          	bge	a5,a4,80006dfe <bd_initfree+0xae>
    80006d80:	8c2e                	mv	s8,a1
    80006d82:	8b32                	mv	s6,a2
    80006d84:	8bb6                	mv	s7,a3
    80006d86:	4901                	li	s2,0
	int free=0;
    80006d88:	4a81                	li	s5,0
  int n = p - (char *) bd_base;
    80006d8a:	00022d97          	auipc	s11,0x22
    80006d8e:	2bed8d93          	addi	s11,s11,702 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006d92:	4d41                	li	s10,16
	for(int k=0;k<MAXSIZE;k++){
    80006d94:	00022c97          	auipc	s9,0x22
    80006d98:	2c4c8c93          	addi	s9,s9,708 # 80029058 <nsizes>
    80006d9c:	a039                	j	80006daa <bd_initfree+0x5a>
    80006d9e:	2905                	addiw	s2,s2,1
    80006da0:	000ca783          	lw	a5,0(s9)
    80006da4:	37fd                	addiw	a5,a5,-1
    80006da6:	04f95d63          	bge	s2,a5,80006e00 <bd_initfree+0xb0>
		int left=blk_index_next(k,bd_left);
    80006daa:	f8843583          	ld	a1,-120(s0)
    80006dae:	854a                	mv	a0,s2
    80006db0:	00000097          	auipc	ra,0x0
    80006db4:	dd8080e7          	jalr	-552(ra) # 80006b88 <blk_index_next>
    80006db8:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006dba:	000db483          	ld	s1,0(s11)
  return n / BLK_SIZE(k);
    80006dbe:	409c04bb          	subw	s1,s8,s1
    80006dc2:	012d17b3          	sll	a5,s10,s2
    80006dc6:	02f4c4b3          	div	s1,s1,a5
    80006dca:	2481                	sext.w	s1,s1
		int right=blk_index(k,bd_right);
		free+=bd_initfree_pair(k,left,allow_left,allow_right);
    80006dcc:	86de                	mv	a3,s7
    80006dce:	865a                	mv	a2,s6
    80006dd0:	85aa                	mv	a1,a0
    80006dd2:	854a                	mv	a0,s2
    80006dd4:	00000097          	auipc	ra,0x0
    80006dd8:	ed8080e7          	jalr	-296(ra) # 80006cac <bd_initfree_pair>
    80006ddc:	01550a3b          	addw	s4,a0,s5
    80006de0:	000a0a9b          	sext.w	s5,s4
		if(right<=left){
    80006de4:	fa99dde3          	bge	s3,s1,80006d9e <bd_initfree+0x4e>
			continue;
		}
		free+=bd_initfree_pair(k,right,allow_left,allow_right);
    80006de8:	86de                	mv	a3,s7
    80006dea:	865a                	mv	a2,s6
    80006dec:	85a6                	mv	a1,s1
    80006dee:	854a                	mv	a0,s2
    80006df0:	00000097          	auipc	ra,0x0
    80006df4:	ebc080e7          	jalr	-324(ra) # 80006cac <bd_initfree_pair>
    80006df8:	00aa0abb          	addw	s5,s4,a0
    80006dfc:	b74d                	j	80006d9e <bd_initfree+0x4e>
	int free=0;
    80006dfe:	4a81                	li	s5,0
	}
	return free;
}
    80006e00:	8556                	mv	a0,s5
    80006e02:	70e6                	ld	ra,120(sp)
    80006e04:	7446                	ld	s0,112(sp)
    80006e06:	74a6                	ld	s1,104(sp)
    80006e08:	7906                	ld	s2,96(sp)
    80006e0a:	69e6                	ld	s3,88(sp)
    80006e0c:	6a46                	ld	s4,80(sp)
    80006e0e:	6aa6                	ld	s5,72(sp)
    80006e10:	6b06                	ld	s6,64(sp)
    80006e12:	7be2                	ld	s7,56(sp)
    80006e14:	7c42                	ld	s8,48(sp)
    80006e16:	7ca2                	ld	s9,40(sp)
    80006e18:	7d02                	ld	s10,32(sp)
    80006e1a:	6de2                	ld	s11,24(sp)
    80006e1c:	6109                	addi	sp,sp,128
    80006e1e:	8082                	ret

0000000080006e20 <bd_mark_data_structures>:

int bd_mark_data_structures(char *p){
    80006e20:	7179                	addi	sp,sp,-48
    80006e22:	f406                	sd	ra,40(sp)
    80006e24:	f022                	sd	s0,32(sp)
    80006e26:	ec26                	sd	s1,24(sp)
    80006e28:	e84a                	sd	s2,16(sp)
    80006e2a:	e44e                	sd	s3,8(sp)
    80006e2c:	1800                	addi	s0,sp,48
    80006e2e:	892a                	mv	s2,a0
	int meta=p-(char*)bd_base;
    80006e30:	00022997          	auipc	s3,0x22
    80006e34:	21898993          	addi	s3,s3,536 # 80029048 <bd_base>
    80006e38:	0009b483          	ld	s1,0(s3)
    80006e3c:	409504bb          	subw	s1,a0,s1
	printf("bd: %d meta bytes for managing %d bytes of memory\n",meta,BLK_SIZE(MAXSIZE));
    80006e40:	00022797          	auipc	a5,0x22
    80006e44:	2187a783          	lw	a5,536(a5) # 80029058 <nsizes>
    80006e48:	37fd                	addiw	a5,a5,-1
    80006e4a:	4641                	li	a2,16
    80006e4c:	00f61633          	sll	a2,a2,a5
    80006e50:	85a6                	mv	a1,s1
    80006e52:	00002517          	auipc	a0,0x2
    80006e56:	aae50513          	addi	a0,a0,-1362 # 80008900 <userret+0x870>
    80006e5a:	ffff9097          	auipc	ra,0xffff9
    80006e5e:	73e080e7          	jalr	1854(ra) # 80000598 <printf>
	bd_mark(bd_base,p);
    80006e62:	85ca                	mv	a1,s2
    80006e64:	0009b503          	ld	a0,0(s3)
    80006e68:	00000097          	auipc	ra,0x0
    80006e6c:	d6c080e7          	jalr	-660(ra) # 80006bd4 <bd_mark>
	return meta;
}
    80006e70:	8526                	mv	a0,s1
    80006e72:	70a2                	ld	ra,40(sp)
    80006e74:	7402                	ld	s0,32(sp)
    80006e76:	64e2                	ld	s1,24(sp)
    80006e78:	6942                	ld	s2,16(sp)
    80006e7a:	69a2                	ld	s3,8(sp)
    80006e7c:	6145                	addi	sp,sp,48
    80006e7e:	8082                	ret

0000000080006e80 <bd_mark_unavailable>:

int bd_mark_unavailable(void *end,void *left){
    80006e80:	1101                	addi	sp,sp,-32
    80006e82:	ec06                	sd	ra,24(sp)
    80006e84:	e822                	sd	s0,16(sp)
    80006e86:	e426                	sd	s1,8(sp)
    80006e88:	1000                	addi	s0,sp,32
	int unavailable=BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006e8a:	00022497          	auipc	s1,0x22
    80006e8e:	1ce4a483          	lw	s1,462(s1) # 80029058 <nsizes>
    80006e92:	fff4879b          	addiw	a5,s1,-1
    80006e96:	44c1                	li	s1,16
    80006e98:	00f494b3          	sll	s1,s1,a5
    80006e9c:	00022797          	auipc	a5,0x22
    80006ea0:	1ac7b783          	ld	a5,428(a5) # 80029048 <bd_base>
    80006ea4:	8d1d                	sub	a0,a0,a5
    80006ea6:	40a4853b          	subw	a0,s1,a0
    80006eaa:	0005049b          	sext.w	s1,a0
	if(unavailable>0) unavailable=ROUNDUP(unavailable,LEAF_SIZE);
    80006eae:	00905a63          	blez	s1,80006ec2 <bd_mark_unavailable+0x42>
    80006eb2:	357d                	addiw	a0,a0,-1
    80006eb4:	41f5549b          	sraiw	s1,a0,0x1f
    80006eb8:	01c4d49b          	srliw	s1,s1,0x1c
    80006ebc:	9ca9                	addw	s1,s1,a0
    80006ebe:	98c1                	andi	s1,s1,-16
    80006ec0:	24c1                	addiw	s1,s1,16
	printf("bd:0x%x bytes unavailable\n",unavailable);
    80006ec2:	85a6                	mv	a1,s1
    80006ec4:	00002517          	auipc	a0,0x2
    80006ec8:	a7450513          	addi	a0,a0,-1420 # 80008938 <userret+0x8a8>
    80006ecc:	ffff9097          	auipc	ra,0xffff9
    80006ed0:	6cc080e7          	jalr	1740(ra) # 80000598 <printf>
	
	void *bd_end=bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006ed4:	00022717          	auipc	a4,0x22
    80006ed8:	17473703          	ld	a4,372(a4) # 80029048 <bd_base>
    80006edc:	00022597          	auipc	a1,0x22
    80006ee0:	17c5a583          	lw	a1,380(a1) # 80029058 <nsizes>
    80006ee4:	fff5879b          	addiw	a5,a1,-1
    80006ee8:	45c1                	li	a1,16
    80006eea:	00f595b3          	sll	a1,a1,a5
    80006eee:	40958533          	sub	a0,a1,s1
	bd_mark(bd_end,bd_base+BLK_SIZE(MAXSIZE));
    80006ef2:	95ba                	add	a1,a1,a4
    80006ef4:	953a                	add	a0,a0,a4
    80006ef6:	00000097          	auipc	ra,0x0
    80006efa:	cde080e7          	jalr	-802(ra) # 80006bd4 <bd_mark>
	return unavailable;
}
    80006efe:	8526                	mv	a0,s1
    80006f00:	60e2                	ld	ra,24(sp)
    80006f02:	6442                	ld	s0,16(sp)
    80006f04:	64a2                	ld	s1,8(sp)
    80006f06:	6105                	addi	sp,sp,32
    80006f08:	8082                	ret

0000000080006f0a <bd_init>:

// The buddy allocator manages the memory from base till end.
void
bd_init(void *base, void *end) {
    80006f0a:	715d                	addi	sp,sp,-80
    80006f0c:	e486                	sd	ra,72(sp)
    80006f0e:	e0a2                	sd	s0,64(sp)
    80006f10:	fc26                	sd	s1,56(sp)
    80006f12:	f84a                	sd	s2,48(sp)
    80006f14:	f44e                	sd	s3,40(sp)
    80006f16:	f052                	sd	s4,32(sp)
    80006f18:	ec56                	sd	s5,24(sp)
    80006f1a:	e85a                	sd	s6,16(sp)
    80006f1c:	e45e                	sd	s7,8(sp)
    80006f1e:	e062                	sd	s8,0(sp)
    80006f20:	0880                	addi	s0,sp,80
    80006f22:	8c2e                	mv	s8,a1
	char *p=(char *)ROUNDUP((uint64)base,LEAF_SIZE);
    80006f24:	fff50493          	addi	s1,a0,-1
    80006f28:	98c1                	andi	s1,s1,-16
    80006f2a:	04c1                	addi	s1,s1,16
	int sz;
	
 	initlock(&lock, "buddy");
    80006f2c:	00002597          	auipc	a1,0x2
    80006f30:	a2c58593          	addi	a1,a1,-1492 # 80008958 <userret+0x8c8>
    80006f34:	00022517          	auipc	a0,0x22
    80006f38:	0cc50513          	addi	a0,a0,204 # 80029000 <lock>
    80006f3c:	ffffa097          	auipc	ra,0xffffa
    80006f40:	a9c080e7          	jalr	-1380(ra) # 800009d8 <initlock>
	
  // YOUR CODE HERE TO INITIALIZE THE BUDDY ALLOCATOR.  FEEL FREE TO
  // BORROW CODE FROM bd_init() in the lecture notes.
	bd_base=(void *)p;
    80006f44:	00022797          	auipc	a5,0x22
    80006f48:	1097b223          	sd	s1,260(a5) # 80029048 <bd_base>
	
	nsizes=log2(((char *)end-p)/LEAF_SIZE)+1;
    80006f4c:	409c0933          	sub	s2,s8,s1
    80006f50:	43f95513          	srai	a0,s2,0x3f
    80006f54:	893d                	andi	a0,a0,15
    80006f56:	954a                	add	a0,a0,s2
    80006f58:	8511                	srai	a0,a0,0x4
    80006f5a:	00000097          	auipc	ra,0x0
    80006f5e:	c58080e7          	jalr	-936(ra) # 80006bb2 <log2>
	if((char*)end-p>BLK_SIZE(MAXSIZE)){
    80006f62:	47c1                	li	a5,16
    80006f64:	00a797b3          	sll	a5,a5,a0
    80006f68:	1b27c863          	blt	a5,s2,80007118 <bd_init+0x20e>
	nsizes=log2(((char *)end-p)/LEAF_SIZE)+1;
    80006f6c:	2505                	addiw	a0,a0,1
    80006f6e:	00022797          	auipc	a5,0x22
    80006f72:	0ea7a523          	sw	a0,234(a5) # 80029058 <nsizes>
		nsizes++;
	}
	
	printf("bd: memory sz is %d bytes, and allocate an size array of length %d\n",(char*)end-p,nsizes);
    80006f76:	00022997          	auipc	s3,0x22
    80006f7a:	0e298993          	addi	s3,s3,226 # 80029058 <nsizes>
    80006f7e:	0009a603          	lw	a2,0(s3)
    80006f82:	85ca                	mv	a1,s2
    80006f84:	00002517          	auipc	a0,0x2
    80006f88:	9dc50513          	addi	a0,a0,-1572 # 80008960 <userret+0x8d0>
    80006f8c:	ffff9097          	auipc	ra,0xffff9
    80006f90:	60c080e7          	jalr	1548(ra) # 80000598 <printf>
	//allocate bd size array
	bd_sizes=(Sz_info *)p;
    80006f94:	00022797          	auipc	a5,0x22
    80006f98:	0a97be23          	sd	s1,188(a5) # 80029050 <bd_sizes>
	p+=sizeof(Sz_info)*nsizes;
    80006f9c:	0009a603          	lw	a2,0(s3)
    80006fa0:	00561913          	slli	s2,a2,0x5
    80006fa4:	9926                	add	s2,s2,s1
	memset(bd_sizes,0,sizeof(Sz_info)*nsizes);
    80006fa6:	0056161b          	slliw	a2,a2,0x5
    80006faa:	4581                	li	a1,0
    80006fac:	8526                	mv	a0,s1
    80006fae:	ffffa097          	auipc	ra,0xffffa
    80006fb2:	c00080e7          	jalr	-1024(ra) # 80000bae <memset>
	
	//init the free lst, alloc the value
	for(int k=0;k<nsizes;k++){
    80006fb6:	0009a783          	lw	a5,0(s3)
    80006fba:	06f05a63          	blez	a5,8000702e <bd_init+0x124>
    80006fbe:	4981                	li	s3,0
		lst_init(&bd_sizes[k].free);  //connecting a node with previous and next
    80006fc0:	00022a97          	auipc	s5,0x22
    80006fc4:	090a8a93          	addi	s5,s5,144 # 80029050 <bd_sizes>
		sz=sizeof(char)* ROUNDUP(NBLK(k),8)/8;
    80006fc8:	00022a17          	auipc	s4,0x22
    80006fcc:	090a0a13          	addi	s4,s4,144 # 80029058 <nsizes>
    80006fd0:	4b05                	li	s6,1
		lst_init(&bd_sizes[k].free);  //connecting a node with previous and next
    80006fd2:	00599b93          	slli	s7,s3,0x5
    80006fd6:	000ab503          	ld	a0,0(s5)
    80006fda:	955e                	add	a0,a0,s7
    80006fdc:	00000097          	auipc	ra,0x0
    80006fe0:	16a080e7          	jalr	362(ra) # 80007146 <lst_init>
		sz=sizeof(char)* ROUNDUP(NBLK(k),8)/8;
    80006fe4:	000a2483          	lw	s1,0(s4)
    80006fe8:	34fd                	addiw	s1,s1,-1
    80006fea:	413484bb          	subw	s1,s1,s3
    80006fee:	009b14bb          	sllw	s1,s6,s1
    80006ff2:	fff4879b          	addiw	a5,s1,-1
    80006ff6:	41f7d49b          	sraiw	s1,a5,0x1f
    80006ffa:	01d4d49b          	srliw	s1,s1,0x1d
    80006ffe:	9cbd                	addw	s1,s1,a5
    80007000:	98e1                	andi	s1,s1,-8
    80007002:	24a1                	addiw	s1,s1,8
		bd_sizes[k].alloc=p;
    80007004:	000ab783          	ld	a5,0(s5)
    80007008:	9bbe                	add	s7,s7,a5
    8000700a:	012bb823          	sd	s2,16(s7)
		memset(bd_sizes[k].alloc,0,sz);
    8000700e:	848d                	srai	s1,s1,0x3
    80007010:	8626                	mv	a2,s1
    80007012:	4581                	li	a1,0
    80007014:	854a                	mv	a0,s2
    80007016:	ffffa097          	auipc	ra,0xffffa
    8000701a:	b98080e7          	jalr	-1128(ra) # 80000bae <memset>
		p+=sz;
    8000701e:	9926                	add	s2,s2,s1
	for(int k=0;k<nsizes;k++){
    80007020:	0985                	addi	s3,s3,1
    80007022:	000a2703          	lw	a4,0(s4)
    80007026:	0009879b          	sext.w	a5,s3
    8000702a:	fae7c4e3          	blt	a5,a4,80006fd2 <bd_init+0xc8>
	}
	
	//alloc the split array
	for (int k=1;k<nsizes;k++){
    8000702e:	00022797          	auipc	a5,0x22
    80007032:	02a7a783          	lw	a5,42(a5) # 80029058 <nsizes>
    80007036:	4705                	li	a4,1
    80007038:	06f75163          	bge	a4,a5,8000709a <bd_init+0x190>
    8000703c:	02000a13          	li	s4,32
    80007040:	4985                	li	s3,1
		sz=sizeof(char)*(ROUNDUP(NBLK(k),8))/8;
    80007042:	4b85                	li	s7,1
		bd_sizes[k].split=p;
    80007044:	00022b17          	auipc	s6,0x22
    80007048:	00cb0b13          	addi	s6,s6,12 # 80029050 <bd_sizes>
	for (int k=1;k<nsizes;k++){
    8000704c:	00022a97          	auipc	s5,0x22
    80007050:	00ca8a93          	addi	s5,s5,12 # 80029058 <nsizes>
		sz=sizeof(char)*(ROUNDUP(NBLK(k),8))/8;
    80007054:	37fd                	addiw	a5,a5,-1
    80007056:	413787bb          	subw	a5,a5,s3
    8000705a:	00fb94bb          	sllw	s1,s7,a5
    8000705e:	fff4879b          	addiw	a5,s1,-1
    80007062:	41f7d49b          	sraiw	s1,a5,0x1f
    80007066:	01d4d49b          	srliw	s1,s1,0x1d
    8000706a:	9cbd                	addw	s1,s1,a5
    8000706c:	98e1                	andi	s1,s1,-8
    8000706e:	24a1                	addiw	s1,s1,8
		bd_sizes[k].split=p;
    80007070:	000b3783          	ld	a5,0(s6)
    80007074:	97d2                	add	a5,a5,s4
    80007076:	0127bc23          	sd	s2,24(a5)
		memset(bd_sizes[k].split,0,sz);
    8000707a:	848d                	srai	s1,s1,0x3
    8000707c:	8626                	mv	a2,s1
    8000707e:	4581                	li	a1,0
    80007080:	854a                	mv	a0,s2
    80007082:	ffffa097          	auipc	ra,0xffffa
    80007086:	b2c080e7          	jalr	-1236(ra) # 80000bae <memset>
		p+=sz;
    8000708a:	9926                	add	s2,s2,s1
	for (int k=1;k<nsizes;k++){
    8000708c:	2985                	addiw	s3,s3,1
    8000708e:	000aa783          	lw	a5,0(s5)
    80007092:	020a0a13          	addi	s4,s4,32
    80007096:	faf9cfe3          	blt	s3,a5,80007054 <bd_init+0x14a>
	}

	p=(char *) ROUNDUP((uint64)p,LEAF_SIZE);
    8000709a:	197d                	addi	s2,s2,-1
    8000709c:	ff097913          	andi	s2,s2,-16
    800070a0:	0941                	addi	s2,s2,16
	
	//mark [base,p] as allocated, so they will not be allocated again
	int meta=bd_mark_data_structures(p);
    800070a2:	854a                	mv	a0,s2
    800070a4:	00000097          	auipc	ra,0x0
    800070a8:	d7c080e7          	jalr	-644(ra) # 80006e20 <bd_mark_data_structures>
    800070ac:	8a2a                	mv	s4,a0

	//mark unavailable memory [end,]HEAP_SIZE] as allocated
	int unavailable=bd_mark_unavailable(end,p);
    800070ae:	85ca                	mv	a1,s2
    800070b0:	8562                	mv	a0,s8
    800070b2:	00000097          	auipc	ra,0x0
    800070b6:	dce080e7          	jalr	-562(ra) # 80006e80 <bd_mark_unavailable>
    800070ba:	89aa                	mv	s3,a0

	void *bd_end=bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    800070bc:	00022a97          	auipc	s5,0x22
    800070c0:	f9ca8a93          	addi	s5,s5,-100 # 80029058 <nsizes>
    800070c4:	000aa783          	lw	a5,0(s5)
    800070c8:	37fd                	addiw	a5,a5,-1
    800070ca:	44c1                	li	s1,16
    800070cc:	00f497b3          	sll	a5,s1,a5
    800070d0:	8f89                	sub	a5,a5,a0
	int free=bd_initfree(p,bd_end,p,end); //get available space 
    800070d2:	86e2                	mv	a3,s8
    800070d4:	864a                	mv	a2,s2
    800070d6:	00022597          	auipc	a1,0x22
    800070da:	f725b583          	ld	a1,-142(a1) # 80029048 <bd_base>
    800070de:	95be                	add	a1,a1,a5
    800070e0:	854a                	mv	a0,s2
    800070e2:	00000097          	auipc	ra,0x0
    800070e6:	c6e080e7          	jalr	-914(ra) # 80006d50 <bd_initfree>

	if(free!=BLK_SIZE(MAXSIZE)-meta-unavailable){
    800070ea:	000aa603          	lw	a2,0(s5)
    800070ee:	367d                	addiw	a2,a2,-1
    800070f0:	00c49633          	sll	a2,s1,a2
    800070f4:	41460633          	sub	a2,a2,s4
    800070f8:	41360633          	sub	a2,a2,s3
    800070fc:	02c51463          	bne	a0,a2,80007124 <bd_init+0x21a>
		printf("free %d %d\n",free,BLK_SIZE(MAXSIZE)-meta-unavailable);
		panic("bd_init: free memory");
	}
  
}
    80007100:	60a6                	ld	ra,72(sp)
    80007102:	6406                	ld	s0,64(sp)
    80007104:	74e2                	ld	s1,56(sp)
    80007106:	7942                	ld	s2,48(sp)
    80007108:	79a2                	ld	s3,40(sp)
    8000710a:	7a02                	ld	s4,32(sp)
    8000710c:	6ae2                	ld	s5,24(sp)
    8000710e:	6b42                	ld	s6,16(sp)
    80007110:	6ba2                	ld	s7,8(sp)
    80007112:	6c02                	ld	s8,0(sp)
    80007114:	6161                	addi	sp,sp,80
    80007116:	8082                	ret
		nsizes++;
    80007118:	2509                	addiw	a0,a0,2
    8000711a:	00022797          	auipc	a5,0x22
    8000711e:	f2a7af23          	sw	a0,-194(a5) # 80029058 <nsizes>
    80007122:	bd91                	j	80006f76 <bd_init+0x6c>
		printf("free %d %d\n",free,BLK_SIZE(MAXSIZE)-meta-unavailable);
    80007124:	85aa                	mv	a1,a0
    80007126:	00002517          	auipc	a0,0x2
    8000712a:	88250513          	addi	a0,a0,-1918 # 800089a8 <userret+0x918>
    8000712e:	ffff9097          	auipc	ra,0xffff9
    80007132:	46a080e7          	jalr	1130(ra) # 80000598 <printf>
		panic("bd_init: free memory");
    80007136:	00002517          	auipc	a0,0x2
    8000713a:	88250513          	addi	a0,a0,-1918 # 800089b8 <userret+0x928>
    8000713e:	ffff9097          	auipc	ra,0xffff9
    80007142:	410080e7          	jalr	1040(ra) # 8000054e <panic>

0000000080007146 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80007146:	1141                	addi	sp,sp,-16
    80007148:	e422                	sd	s0,8(sp)
    8000714a:	0800                	addi	s0,sp,16
  lst->next = lst;
    8000714c:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    8000714e:	e508                	sd	a0,8(a0)
}
    80007150:	6422                	ld	s0,8(sp)
    80007152:	0141                	addi	sp,sp,16
    80007154:	8082                	ret

0000000080007156 <lst_empty>:

int
lst_empty(struct list *lst) {
    80007156:	1141                	addi	sp,sp,-16
    80007158:	e422                	sd	s0,8(sp)
    8000715a:	0800                	addi	s0,sp,16
  return lst->next == lst;
    8000715c:	611c                	ld	a5,0(a0)
    8000715e:	40a78533          	sub	a0,a5,a0
}
    80007162:	00153513          	seqz	a0,a0
    80007166:	6422                	ld	s0,8(sp)
    80007168:	0141                	addi	sp,sp,16
    8000716a:	8082                	ret

000000008000716c <lst_remove>:

void
lst_remove(struct list *e) {
    8000716c:	1141                	addi	sp,sp,-16
    8000716e:	e422                	sd	s0,8(sp)
    80007170:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007172:	6518                	ld	a4,8(a0)
    80007174:	611c                	ld	a5,0(a0)
    80007176:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80007178:	6518                	ld	a4,8(a0)
    8000717a:	e798                	sd	a4,8(a5)
}
    8000717c:	6422                	ld	s0,8(sp)
    8000717e:	0141                	addi	sp,sp,16
    80007180:	8082                	ret

0000000080007182 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007182:	1101                	addi	sp,sp,-32
    80007184:	ec06                	sd	ra,24(sp)
    80007186:	e822                	sd	s0,16(sp)
    80007188:	e426                	sd	s1,8(sp)
    8000718a:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    8000718c:	6104                	ld	s1,0(a0)
    8000718e:	00a48d63          	beq	s1,a0,800071a8 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007192:	8526                	mv	a0,s1
    80007194:	00000097          	auipc	ra,0x0
    80007198:	fd8080e7          	jalr	-40(ra) # 8000716c <lst_remove>
  return (void *)p;
}
    8000719c:	8526                	mv	a0,s1
    8000719e:	60e2                	ld	ra,24(sp)
    800071a0:	6442                	ld	s0,16(sp)
    800071a2:	64a2                	ld	s1,8(sp)
    800071a4:	6105                	addi	sp,sp,32
    800071a6:	8082                	ret
    panic("lst_pop");
    800071a8:	00002517          	auipc	a0,0x2
    800071ac:	82850513          	addi	a0,a0,-2008 # 800089d0 <userret+0x940>
    800071b0:	ffff9097          	auipc	ra,0xffff9
    800071b4:	39e080e7          	jalr	926(ra) # 8000054e <panic>

00000000800071b8 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    800071b8:	1141                	addi	sp,sp,-16
    800071ba:	e422                	sd	s0,8(sp)
    800071bc:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    800071be:	611c                	ld	a5,0(a0)
    800071c0:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    800071c2:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    800071c4:	611c                	ld	a5,0(a0)
    800071c6:	e78c                	sd	a1,8(a5)
  lst->next = e;
    800071c8:	e10c                	sd	a1,0(a0)
}
    800071ca:	6422                	ld	s0,8(sp)
    800071cc:	0141                	addi	sp,sp,16
    800071ce:	8082                	ret

00000000800071d0 <lst_print>:

void
lst_print(struct list *lst)
{
    800071d0:	7179                	addi	sp,sp,-48
    800071d2:	f406                	sd	ra,40(sp)
    800071d4:	f022                	sd	s0,32(sp)
    800071d6:	ec26                	sd	s1,24(sp)
    800071d8:	e84a                	sd	s2,16(sp)
    800071da:	e44e                	sd	s3,8(sp)
    800071dc:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800071de:	6104                	ld	s1,0(a0)
    800071e0:	02950063          	beq	a0,s1,80007200 <lst_print+0x30>
    800071e4:	892a                	mv	s2,a0
    printf(" %p", p);
    800071e6:	00001997          	auipc	s3,0x1
    800071ea:	7f298993          	addi	s3,s3,2034 # 800089d8 <userret+0x948>
    800071ee:	85a6                	mv	a1,s1
    800071f0:	854e                	mv	a0,s3
    800071f2:	ffff9097          	auipc	ra,0xffff9
    800071f6:	3a6080e7          	jalr	934(ra) # 80000598 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800071fa:	6084                	ld	s1,0(s1)
    800071fc:	fe9919e3          	bne	s2,s1,800071ee <lst_print+0x1e>
  }
  printf("\n");
    80007200:	00001517          	auipc	a0,0x1
    80007204:	fb050513          	addi	a0,a0,-80 # 800081b0 <userret+0x120>
    80007208:	ffff9097          	auipc	ra,0xffff9
    8000720c:	390080e7          	jalr	912(ra) # 80000598 <printf>
}
    80007210:	70a2                	ld	ra,40(sp)
    80007212:	7402                	ld	s0,32(sp)
    80007214:	64e2                	ld	s1,24(sp)
    80007216:	6942                	ld	s2,16(sp)
    80007218:	69a2                	ld	s3,8(sp)
    8000721a:	6145                	addi	sp,sp,48
    8000721c:	8082                	ret
	...

0000000080008000 <trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
