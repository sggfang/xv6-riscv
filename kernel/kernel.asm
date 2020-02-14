
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
    80000060:	c1478793          	addi	a5,a5,-1004 # 80005c70 <timervec>
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
    80000144:	70c080e7          	jalr	1804(ra) # 8000184c <myproc>
    80000148:	591c                	lw	a5,48(a0)
    8000014a:	e7b5                	bnez	a5,800001b6 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000014c:	85ce                	mv	a1,s3
    8000014e:	854a                	mv	a0,s2
    80000150:	00002097          	auipc	ra,0x2
    80000154:	f0e080e7          	jalr	-242(ra) # 8000205e <sleep>
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
    80000190:	132080e7          	jalr	306(ra) # 800022be <either_copyout>
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
    80000290:	088080e7          	jalr	136(ra) # 80002314 <either_copyin>
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
    80000306:	068080e7          	jalr	104(ra) # 8000236a <procdump>
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
    8000045a:	d8e080e7          	jalr	-626(ra) # 800021e4 <wakeup>
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
    80000488:	00022797          	auipc	a5,0x22
    8000048c:	67878793          	addi	a5,a5,1656 # 80022b00 <devsw>
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
    800004ce:	50660613          	addi	a2,a2,1286 # 800089d0 <digits>
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
    800005fa:	3dab8b93          	addi	s7,s7,986 # 800089d0 <digits>
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
    8000096a:	404080e7          	jalr	1028(ra) # 80006d6a <bd_init>
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
    80000a0a:	e2a080e7          	jalr	-470(ra) # 80001830 <mycpu>
    80000a0e:	5d3c                	lw	a5,120(a0)
    80000a10:	cf89                	beqz	a5,80000a2a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000a12:	00001097          	auipc	ra,0x1
    80000a16:	e1e080e7          	jalr	-482(ra) # 80001830 <mycpu>
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
    80000a2e:	e06080e7          	jalr	-506(ra) # 80001830 <mycpu>
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
    80000a46:	dee080e7          	jalr	-530(ra) # 80001830 <mycpu>
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
    80000ade:	d56080e7          	jalr	-682(ra) # 80001830 <mycpu>
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
    80000b42:	cf2080e7          	jalr	-782(ra) # 80001830 <mycpu>
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
    80000d6c:	ab8080e7          	jalr	-1352(ra) # 80001820 <cpuid>
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
    80000d88:	a9c080e7          	jalr	-1380(ra) # 80001820 <cpuid>
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
    80000daa:	704080e7          	jalr	1796(ra) # 800024aa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000dae:	00005097          	auipc	ra,0x5
    80000db2:	f02080e7          	jalr	-254(ra) # 80005cb0 <plicinithart>
  }

  scheduler();        
    80000db6:	00001097          	auipc	ra,0x1
    80000dba:	fd8080e7          	jalr	-40(ra) # 80001d8e <scheduler>
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
    80000e1a:	93a080e7          	jalr	-1734(ra) # 80001750 <procinit>
    trapinit();      // trap vectors
    80000e1e:	00001097          	auipc	ra,0x1
    80000e22:	664080e7          	jalr	1636(ra) # 80002482 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e26:	00001097          	auipc	ra,0x1
    80000e2a:	684080e7          	jalr	1668(ra) # 800024aa <trapinithart>
    plicinit();      // set up interrupt controller
    80000e2e:	00005097          	auipc	ra,0x5
    80000e32:	e6c080e7          	jalr	-404(ra) # 80005c9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e36:	00005097          	auipc	ra,0x5
    80000e3a:	e7a080e7          	jalr	-390(ra) # 80005cb0 <plicinithart>
    binit();         // buffer cache
    80000e3e:	00002097          	auipc	ra,0x2
    80000e42:	daa080e7          	jalr	-598(ra) # 80002be8 <binit>
    iinit();         // inode cache
    80000e46:	00002097          	auipc	ra,0x2
    80000e4a:	43e080e7          	jalr	1086(ra) # 80003284 <iinit>
    fileinit();      // file table
    80000e4e:	00003097          	auipc	ra,0x3
    80000e52:	61a080e7          	jalr	1562(ra) # 80004468 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80000e56:	4501                	li	a0,0
    80000e58:	00005097          	auipc	ra,0x5
    80000e5c:	f8c080e7          	jalr	-116(ra) # 80005de4 <virtio_disk_init>
    userinit();      // first user process
    80000e60:	00001097          	auipc	ra,0x1
    80000e64:	c60080e7          	jalr	-928(ra) # 80001ac0 <userinit>
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
    80001204:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    80001206:	77fd                	lui	a5,0xfffff
    80001208:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    8000120c:	167d                	addi	a2,a2,-1
    8000120e:	00b609b3          	add	s3,a2,a1
    80001212:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    80001216:	4b05                	li	s6,1
    a += PGSIZE;
    80001218:	6b85                	lui	s7,0x1
    8000121a:	a8b1                	j	80001276 <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    8000121c:	00007517          	auipc	a0,0x7
    80001220:	fcc50513          	addi	a0,a0,-52 # 800081e8 <userret+0x158>
    80001224:	fffff097          	auipc	ra,0xfffff
    80001228:	32a080e7          	jalr	810(ra) # 8000054e <panic>
      printf("va=%p pte=%p\n", a, *pte);
    8000122c:	862a                	mv	a2,a0
    8000122e:	85ca                	mv	a1,s2
    80001230:	00007517          	auipc	a0,0x7
    80001234:	fc850513          	addi	a0,a0,-56 # 800081f8 <userret+0x168>
    80001238:	fffff097          	auipc	ra,0xfffff
    8000123c:	360080e7          	jalr	864(ra) # 80000598 <printf>
      panic("uvmunmap: not mapped");
    80001240:	00007517          	auipc	a0,0x7
    80001244:	fc850513          	addi	a0,a0,-56 # 80008208 <userret+0x178>
    80001248:	fffff097          	auipc	ra,0xfffff
    8000124c:	306080e7          	jalr	774(ra) # 8000054e <panic>
      panic("uvmunmap: not a leaf");
    80001250:	00007517          	auipc	a0,0x7
    80001254:	fd050513          	addi	a0,a0,-48 # 80008220 <userret+0x190>
    80001258:	fffff097          	auipc	ra,0xfffff
    8000125c:	2f6080e7          	jalr	758(ra) # 8000054e <panic>
      pa = PTE2PA(*pte);
    80001260:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001262:	0532                	slli	a0,a0,0xc
    80001264:	fffff097          	auipc	ra,0xfffff
    80001268:	600080e7          	jalr	1536(ra) # 80000864 <kfree>
    *pte = 0;
    8000126c:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001270:	03390763          	beq	s2,s3,8000129e <uvmunmap+0xb2>
    a += PGSIZE;
    80001274:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001276:	4601                	li	a2,0
    80001278:	85ca                	mv	a1,s2
    8000127a:	8552                	mv	a0,s4
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	bfc080e7          	jalr	-1028(ra) # 80000e78 <walk>
    80001284:	84aa                	mv	s1,a0
    80001286:	d959                	beqz	a0,8000121c <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001288:	6108                	ld	a0,0(a0)
    8000128a:	00157793          	andi	a5,a0,1
    8000128e:	dfd9                	beqz	a5,8000122c <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001290:	01f57793          	andi	a5,a0,31
    80001294:	fb678ee3          	beq	a5,s6,80001250 <uvmunmap+0x64>
    if(do_free){
    80001298:	fc0a8ae3          	beqz	s5,8000126c <uvmunmap+0x80>
    8000129c:	b7d1                	j	80001260 <uvmunmap+0x74>
}
    8000129e:	60a6                	ld	ra,72(sp)
    800012a0:	6406                	ld	s0,64(sp)
    800012a2:	74e2                	ld	s1,56(sp)
    800012a4:	7942                	ld	s2,48(sp)
    800012a6:	79a2                	ld	s3,40(sp)
    800012a8:	7a02                	ld	s4,32(sp)
    800012aa:	6ae2                	ld	s5,24(sp)
    800012ac:	6b42                	ld	s6,16(sp)
    800012ae:	6ba2                	ld	s7,8(sp)
    800012b0:	6161                	addi	sp,sp,80
    800012b2:	8082                	ret

00000000800012b4 <uvmcreate>:
{
    800012b4:	1101                	addi	sp,sp,-32
    800012b6:	ec06                	sd	ra,24(sp)
    800012b8:	e822                	sd	s0,16(sp)
    800012ba:	e426                	sd	s1,8(sp)
    800012bc:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800012be:	fffff097          	auipc	ra,0xfffff
    800012c2:	6ba080e7          	jalr	1722(ra) # 80000978 <kalloc>
  if(pagetable == 0)
    800012c6:	cd11                	beqz	a0,800012e2 <uvmcreate+0x2e>
    800012c8:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	8e0080e7          	jalr	-1824(ra) # 80000bae <memset>
}
    800012d6:	8526                	mv	a0,s1
    800012d8:	60e2                	ld	ra,24(sp)
    800012da:	6442                	ld	s0,16(sp)
    800012dc:	64a2                	ld	s1,8(sp)
    800012de:	6105                	addi	sp,sp,32
    800012e0:	8082                	ret
    panic("uvmcreate: out of memory");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	f5650513          	addi	a0,a0,-170 # 80008238 <userret+0x1a8>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	264080e7          	jalr	612(ra) # 8000054e <panic>

00000000800012f2 <uvminit>:
{
    800012f2:	7179                	addi	sp,sp,-48
    800012f4:	f406                	sd	ra,40(sp)
    800012f6:	f022                	sd	s0,32(sp)
    800012f8:	ec26                	sd	s1,24(sp)
    800012fa:	e84a                	sd	s2,16(sp)
    800012fc:	e44e                	sd	s3,8(sp)
    800012fe:	e052                	sd	s4,0(sp)
    80001300:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    80001302:	6785                	lui	a5,0x1
    80001304:	04f67863          	bgeu	a2,a5,80001354 <uvminit+0x62>
    80001308:	8a2a                	mv	s4,a0
    8000130a:	89ae                	mv	s3,a1
    8000130c:	84b2                	mv	s1,a2
  mem = kalloc();
    8000130e:	fffff097          	auipc	ra,0xfffff
    80001312:	66a080e7          	jalr	1642(ra) # 80000978 <kalloc>
    80001316:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001318:	6605                	lui	a2,0x1
    8000131a:	4581                	li	a1,0
    8000131c:	00000097          	auipc	ra,0x0
    80001320:	892080e7          	jalr	-1902(ra) # 80000bae <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001324:	4779                	li	a4,30
    80001326:	86ca                	mv	a3,s2
    80001328:	6605                	lui	a2,0x1
    8000132a:	4581                	li	a1,0
    8000132c:	8552                	mv	a0,s4
    8000132e:	00000097          	auipc	ra,0x0
    80001332:	d12080e7          	jalr	-750(ra) # 80001040 <mappages>
  memmove(mem, src, sz);
    80001336:	8626                	mv	a2,s1
    80001338:	85ce                	mv	a1,s3
    8000133a:	854a                	mv	a0,s2
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	8d2080e7          	jalr	-1838(ra) # 80000c0e <memmove>
}
    80001344:	70a2                	ld	ra,40(sp)
    80001346:	7402                	ld	s0,32(sp)
    80001348:	64e2                	ld	s1,24(sp)
    8000134a:	6942                	ld	s2,16(sp)
    8000134c:	69a2                	ld	s3,8(sp)
    8000134e:	6a02                	ld	s4,0(sp)
    80001350:	6145                	addi	sp,sp,48
    80001352:	8082                	ret
    panic("inituvm: more than a page");
    80001354:	00007517          	auipc	a0,0x7
    80001358:	f0450513          	addi	a0,a0,-252 # 80008258 <userret+0x1c8>
    8000135c:	fffff097          	auipc	ra,0xfffff
    80001360:	1f2080e7          	jalr	498(ra) # 8000054e <panic>

0000000080001364 <uvmdealloc>:
{
    80001364:	87aa                	mv	a5,a0
    80001366:	852e                	mv	a0,a1
  if(newsz >= oldsz)
    80001368:	00b66363          	bltu	a2,a1,8000136e <uvmdealloc+0xa>
}
    8000136c:	8082                	ret
{
    8000136e:	1101                	addi	sp,sp,-32
    80001370:	ec06                	sd	ra,24(sp)
    80001372:	e822                	sd	s0,16(sp)
    80001374:	e426                	sd	s1,8(sp)
    80001376:	1000                	addi	s0,sp,32
    80001378:	84b2                	mv	s1,a2
  uvmunmap(pagetable, newsz, oldsz - newsz, 1);
    8000137a:	4685                	li	a3,1
    8000137c:	40c58633          	sub	a2,a1,a2
    80001380:	85a6                	mv	a1,s1
    80001382:	853e                	mv	a0,a5
    80001384:	00000097          	auipc	ra,0x0
    80001388:	e68080e7          	jalr	-408(ra) # 800011ec <uvmunmap>
  return newsz;
    8000138c:	8526                	mv	a0,s1
}
    8000138e:	60e2                	ld	ra,24(sp)
    80001390:	6442                	ld	s0,16(sp)
    80001392:	64a2                	ld	s1,8(sp)
    80001394:	6105                	addi	sp,sp,32
    80001396:	8082                	ret

0000000080001398 <uvmalloc>:
  if(newsz < oldsz)
    80001398:	0ab66163          	bltu	a2,a1,8000143a <uvmalloc+0xa2>
{
    8000139c:	7139                	addi	sp,sp,-64
    8000139e:	fc06                	sd	ra,56(sp)
    800013a0:	f822                	sd	s0,48(sp)
    800013a2:	f426                	sd	s1,40(sp)
    800013a4:	f04a                	sd	s2,32(sp)
    800013a6:	ec4e                	sd	s3,24(sp)
    800013a8:	e852                	sd	s4,16(sp)
    800013aa:	e456                	sd	s5,8(sp)
    800013ac:	0080                	addi	s0,sp,64
    800013ae:	8aaa                	mv	s5,a0
    800013b0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800013b2:	6985                	lui	s3,0x1
    800013b4:	19fd                	addi	s3,s3,-1
    800013b6:	95ce                	add	a1,a1,s3
    800013b8:	79fd                	lui	s3,0xfffff
    800013ba:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800013be:	08c9f063          	bgeu	s3,a2,8000143e <uvmalloc+0xa6>
  a = oldsz;
    800013c2:	894e                	mv	s2,s3
    mem = kalloc();
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	5b4080e7          	jalr	1460(ra) # 80000978 <kalloc>
    800013cc:	84aa                	mv	s1,a0
    if(mem == 0){
    800013ce:	c51d                	beqz	a0,800013fc <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013d0:	6605                	lui	a2,0x1
    800013d2:	4581                	li	a1,0
    800013d4:	fffff097          	auipc	ra,0xfffff
    800013d8:	7da080e7          	jalr	2010(ra) # 80000bae <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800013dc:	4779                	li	a4,30
    800013de:	86a6                	mv	a3,s1
    800013e0:	6605                	lui	a2,0x1
    800013e2:	85ca                	mv	a1,s2
    800013e4:	8556                	mv	a0,s5
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	c5a080e7          	jalr	-934(ra) # 80001040 <mappages>
    800013ee:	e905                	bnez	a0,8000141e <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800013f0:	6785                	lui	a5,0x1
    800013f2:	993e                	add	s2,s2,a5
    800013f4:	fd4968e3          	bltu	s2,s4,800013c4 <uvmalloc+0x2c>
  return newsz;
    800013f8:	8552                	mv	a0,s4
    800013fa:	a809                	j	8000140c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013fc:	864e                	mv	a2,s3
    800013fe:	85ca                	mv	a1,s2
    80001400:	8556                	mv	a0,s5
    80001402:	00000097          	auipc	ra,0x0
    80001406:	f62080e7          	jalr	-158(ra) # 80001364 <uvmdealloc>
      return 0;
    8000140a:	4501                	li	a0,0
}
    8000140c:	70e2                	ld	ra,56(sp)
    8000140e:	7442                	ld	s0,48(sp)
    80001410:	74a2                	ld	s1,40(sp)
    80001412:	7902                	ld	s2,32(sp)
    80001414:	69e2                	ld	s3,24(sp)
    80001416:	6a42                	ld	s4,16(sp)
    80001418:	6aa2                	ld	s5,8(sp)
    8000141a:	6121                	addi	sp,sp,64
    8000141c:	8082                	ret
      kfree(mem);
    8000141e:	8526                	mv	a0,s1
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	444080e7          	jalr	1092(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001428:	864e                	mv	a2,s3
    8000142a:	85ca                	mv	a1,s2
    8000142c:	8556                	mv	a0,s5
    8000142e:	00000097          	auipc	ra,0x0
    80001432:	f36080e7          	jalr	-202(ra) # 80001364 <uvmdealloc>
      return 0;
    80001436:	4501                	li	a0,0
    80001438:	bfd1                	j	8000140c <uvmalloc+0x74>
    return oldsz;
    8000143a:	852e                	mv	a0,a1
}
    8000143c:	8082                	ret
  return newsz;
    8000143e:	8532                	mv	a0,a2
    80001440:	b7f1                	j	8000140c <uvmalloc+0x74>

0000000080001442 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001442:	1101                	addi	sp,sp,-32
    80001444:	ec06                	sd	ra,24(sp)
    80001446:	e822                	sd	s0,16(sp)
    80001448:	e426                	sd	s1,8(sp)
    8000144a:	1000                	addi	s0,sp,32
    8000144c:	84aa                	mv	s1,a0
    8000144e:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001450:	4685                	li	a3,1
    80001452:	4581                	li	a1,0
    80001454:	00000097          	auipc	ra,0x0
    80001458:	d98080e7          	jalr	-616(ra) # 800011ec <uvmunmap>
  freewalk(pagetable);
    8000145c:	8526                	mv	a0,s1
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	ac0080e7          	jalr	-1344(ra) # 80000f1e <freewalk>
}
    80001466:	60e2                	ld	ra,24(sp)
    80001468:	6442                	ld	s0,16(sp)
    8000146a:	64a2                	ld	s1,8(sp)
    8000146c:	6105                	addi	sp,sp,32
    8000146e:	8082                	ret

0000000080001470 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001470:	c671                	beqz	a2,8000153c <uvmcopy+0xcc>
{
    80001472:	715d                	addi	sp,sp,-80
    80001474:	e486                	sd	ra,72(sp)
    80001476:	e0a2                	sd	s0,64(sp)
    80001478:	fc26                	sd	s1,56(sp)
    8000147a:	f84a                	sd	s2,48(sp)
    8000147c:	f44e                	sd	s3,40(sp)
    8000147e:	f052                	sd	s4,32(sp)
    80001480:	ec56                	sd	s5,24(sp)
    80001482:	e85a                	sd	s6,16(sp)
    80001484:	e45e                	sd	s7,8(sp)
    80001486:	0880                	addi	s0,sp,80
    80001488:	8b2a                	mv	s6,a0
    8000148a:	8aae                	mv	s5,a1
    8000148c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000148e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001490:	4601                	li	a2,0
    80001492:	85ce                	mv	a1,s3
    80001494:	855a                	mv	a0,s6
    80001496:	00000097          	auipc	ra,0x0
    8000149a:	9e2080e7          	jalr	-1566(ra) # 80000e78 <walk>
    8000149e:	c531                	beqz	a0,800014ea <uvmcopy+0x7a>
      panic("copyuvm: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a0:	6118                	ld	a4,0(a0)
    800014a2:	00177793          	andi	a5,a4,1
    800014a6:	cbb1                	beqz	a5,800014fa <uvmcopy+0x8a>
      panic("copyuvm: page not present");
    pa = PTE2PA(*pte);
    800014a8:	00a75593          	srli	a1,a4,0xa
    800014ac:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b0:	01f77493          	andi	s1,a4,31
    if((mem = kalloc()) == 0)
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	4c4080e7          	jalr	1220(ra) # 80000978 <kalloc>
    800014bc:	892a                	mv	s2,a0
    800014be:	c939                	beqz	a0,80001514 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014c0:	6605                	lui	a2,0x1
    800014c2:	85de                	mv	a1,s7
    800014c4:	fffff097          	auipc	ra,0xfffff
    800014c8:	74a080e7          	jalr	1866(ra) # 80000c0e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014cc:	8726                	mv	a4,s1
    800014ce:	86ca                	mv	a3,s2
    800014d0:	6605                	lui	a2,0x1
    800014d2:	85ce                	mv	a1,s3
    800014d4:	8556                	mv	a0,s5
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	b6a080e7          	jalr	-1174(ra) # 80001040 <mappages>
    800014de:	e515                	bnez	a0,8000150a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800014e0:	6785                	lui	a5,0x1
    800014e2:	99be                	add	s3,s3,a5
    800014e4:	fb49e6e3          	bltu	s3,s4,80001490 <uvmcopy+0x20>
    800014e8:	a83d                	j	80001526 <uvmcopy+0xb6>
      panic("copyuvm: pte should exist");
    800014ea:	00007517          	auipc	a0,0x7
    800014ee:	d8e50513          	addi	a0,a0,-626 # 80008278 <userret+0x1e8>
    800014f2:	fffff097          	auipc	ra,0xfffff
    800014f6:	05c080e7          	jalr	92(ra) # 8000054e <panic>
      panic("copyuvm: page not present");
    800014fa:	00007517          	auipc	a0,0x7
    800014fe:	d9e50513          	addi	a0,a0,-610 # 80008298 <userret+0x208>
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	04c080e7          	jalr	76(ra) # 8000054e <panic>
      kfree(mem);
    8000150a:	854a                	mv	a0,s2
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	358080e7          	jalr	856(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001514:	4685                	li	a3,1
    80001516:	864e                	mv	a2,s3
    80001518:	4581                	li	a1,0
    8000151a:	8556                	mv	a0,s5
    8000151c:	00000097          	auipc	ra,0x0
    80001520:	cd0080e7          	jalr	-816(ra) # 800011ec <uvmunmap>
  return -1;
    80001524:	557d                	li	a0,-1
}
    80001526:	60a6                	ld	ra,72(sp)
    80001528:	6406                	ld	s0,64(sp)
    8000152a:	74e2                	ld	s1,56(sp)
    8000152c:	7942                	ld	s2,48(sp)
    8000152e:	79a2                	ld	s3,40(sp)
    80001530:	7a02                	ld	s4,32(sp)
    80001532:	6ae2                	ld	s5,24(sp)
    80001534:	6b42                	ld	s6,16(sp)
    80001536:	6ba2                	ld	s7,8(sp)
    80001538:	6161                	addi	sp,sp,80
    8000153a:	8082                	ret
  return 0;
    8000153c:	4501                	li	a0,0
}
    8000153e:	8082                	ret

0000000080001540 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001540:	1141                	addi	sp,sp,-16
    80001542:	e406                	sd	ra,8(sp)
    80001544:	e022                	sd	s0,0(sp)
    80001546:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001548:	4601                	li	a2,0
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	92e080e7          	jalr	-1746(ra) # 80000e78 <walk>
  if(pte == 0)
    80001552:	c901                	beqz	a0,80001562 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001554:	611c                	ld	a5,0(a0)
    80001556:	9bbd                	andi	a5,a5,-17
    80001558:	e11c                	sd	a5,0(a0)
}
    8000155a:	60a2                	ld	ra,8(sp)
    8000155c:	6402                	ld	s0,0(sp)
    8000155e:	0141                	addi	sp,sp,16
    80001560:	8082                	ret
    panic("uvmclear");
    80001562:	00007517          	auipc	a0,0x7
    80001566:	d5650513          	addi	a0,a0,-682 # 800082b8 <userret+0x228>
    8000156a:	fffff097          	auipc	ra,0xfffff
    8000156e:	fe4080e7          	jalr	-28(ra) # 8000054e <panic>

0000000080001572 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001572:	cab5                	beqz	a3,800015e6 <copyout+0x74>
{
    80001574:	715d                	addi	sp,sp,-80
    80001576:	e486                	sd	ra,72(sp)
    80001578:	e0a2                	sd	s0,64(sp)
    8000157a:	fc26                	sd	s1,56(sp)
    8000157c:	f84a                	sd	s2,48(sp)
    8000157e:	f44e                	sd	s3,40(sp)
    80001580:	f052                	sd	s4,32(sp)
    80001582:	ec56                	sd	s5,24(sp)
    80001584:	e85a                	sd	s6,16(sp)
    80001586:	e45e                	sd	s7,8(sp)
    80001588:	e062                	sd	s8,0(sp)
    8000158a:	0880                	addi	s0,sp,80
    8000158c:	8baa                	mv	s7,a0
    8000158e:	8c2e                	mv	s8,a1
    80001590:	8a32                	mv	s4,a2
    80001592:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(dstva);
    80001594:	00100b37          	lui	s6,0x100
    80001598:	1b7d                	addi	s6,s6,-1
    8000159a:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000159c:	6a85                	lui	s5,0x1
    8000159e:	a015                	j	800015c2 <copyout+0x50>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015a0:	9562                	add	a0,a0,s8
    800015a2:	0004861b          	sext.w	a2,s1
    800015a6:	85d2                	mv	a1,s4
    800015a8:	41250533          	sub	a0,a0,s2
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	662080e7          	jalr	1634(ra) # 80000c0e <memmove>

    len -= n;
    800015b4:	409989b3          	sub	s3,s3,s1
    src += n;
    800015b8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800015ba:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015be:	02098263          	beqz	s3,800015e2 <copyout+0x70>
    va0 = (uint)PGROUNDDOWN(dstva);
    800015c2:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    800015c6:	85ca                	mv	a1,s2
    800015c8:	855e                	mv	a0,s7
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	9e2080e7          	jalr	-1566(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    800015d2:	cd01                	beqz	a0,800015ea <copyout+0x78>
    n = PGSIZE - (dstva - va0);
    800015d4:	418904b3          	sub	s1,s2,s8
    800015d8:	94d6                	add	s1,s1,s5
    if(n > len)
    800015da:	fc99f3e3          	bgeu	s3,s1,800015a0 <copyout+0x2e>
    800015de:	84ce                	mv	s1,s3
    800015e0:	b7c1                	j	800015a0 <copyout+0x2e>
  }
  return 0;
    800015e2:	4501                	li	a0,0
    800015e4:	a021                	j	800015ec <copyout+0x7a>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
}
    800015ec:	60a6                	ld	ra,72(sp)
    800015ee:	6406                	ld	s0,64(sp)
    800015f0:	74e2                	ld	s1,56(sp)
    800015f2:	7942                	ld	s2,48(sp)
    800015f4:	79a2                	ld	s3,40(sp)
    800015f6:	7a02                	ld	s4,32(sp)
    800015f8:	6ae2                	ld	s5,24(sp)
    800015fa:	6b42                	ld	s6,16(sp)
    800015fc:	6ba2                	ld	s7,8(sp)
    800015fe:	6c02                	ld	s8,0(sp)
    80001600:	6161                	addi	sp,sp,80
    80001602:	8082                	ret

0000000080001604 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001604:	cab5                	beqz	a3,80001678 <copyin+0x74>
{
    80001606:	715d                	addi	sp,sp,-80
    80001608:	e486                	sd	ra,72(sp)
    8000160a:	e0a2                	sd	s0,64(sp)
    8000160c:	fc26                	sd	s1,56(sp)
    8000160e:	f84a                	sd	s2,48(sp)
    80001610:	f44e                	sd	s3,40(sp)
    80001612:	f052                	sd	s4,32(sp)
    80001614:	ec56                	sd	s5,24(sp)
    80001616:	e85a                	sd	s6,16(sp)
    80001618:	e45e                	sd	s7,8(sp)
    8000161a:	e062                	sd	s8,0(sp)
    8000161c:	0880                	addi	s0,sp,80
    8000161e:	8baa                	mv	s7,a0
    80001620:	8a2e                	mv	s4,a1
    80001622:	8c32                	mv	s8,a2
    80001624:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    80001626:	00100b37          	lui	s6,0x100
    8000162a:	1b7d                	addi	s6,s6,-1
    8000162c:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000162e:	6a85                	lui	s5,0x1
    80001630:	a015                	j	80001654 <copyin+0x50>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001632:	9562                	add	a0,a0,s8
    80001634:	0004861b          	sext.w	a2,s1
    80001638:	412505b3          	sub	a1,a0,s2
    8000163c:	8552                	mv	a0,s4
    8000163e:	fffff097          	auipc	ra,0xfffff
    80001642:	5d0080e7          	jalr	1488(ra) # 80000c0e <memmove>

    len -= n;
    80001646:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000164a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000164c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001650:	02098263          	beqz	s3,80001674 <copyin+0x70>
    va0 = (uint)PGROUNDDOWN(srcva);
    80001654:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001658:	85ca                	mv	a1,s2
    8000165a:	855e                	mv	a0,s7
    8000165c:	00000097          	auipc	ra,0x0
    80001660:	950080e7          	jalr	-1712(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    80001664:	cd01                	beqz	a0,8000167c <copyin+0x78>
    n = PGSIZE - (srcva - va0);
    80001666:	418904b3          	sub	s1,s2,s8
    8000166a:	94d6                	add	s1,s1,s5
    if(n > len)
    8000166c:	fc99f3e3          	bgeu	s3,s1,80001632 <copyin+0x2e>
    80001670:	84ce                	mv	s1,s3
    80001672:	b7c1                	j	80001632 <copyin+0x2e>
  }
  return 0;
    80001674:	4501                	li	a0,0
    80001676:	a021                	j	8000167e <copyin+0x7a>
    80001678:	4501                	li	a0,0
}
    8000167a:	8082                	ret
      return -1;
    8000167c:	557d                	li	a0,-1
}
    8000167e:	60a6                	ld	ra,72(sp)
    80001680:	6406                	ld	s0,64(sp)
    80001682:	74e2                	ld	s1,56(sp)
    80001684:	7942                	ld	s2,48(sp)
    80001686:	79a2                	ld	s3,40(sp)
    80001688:	7a02                	ld	s4,32(sp)
    8000168a:	6ae2                	ld	s5,24(sp)
    8000168c:	6b42                	ld	s6,16(sp)
    8000168e:	6ba2                	ld	s7,8(sp)
    80001690:	6c02                	ld	s8,0(sp)
    80001692:	6161                	addi	sp,sp,80
    80001694:	8082                	ret

0000000080001696 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001696:	c6dd                	beqz	a3,80001744 <copyinstr+0xae>
{
    80001698:	715d                	addi	sp,sp,-80
    8000169a:	e486                	sd	ra,72(sp)
    8000169c:	e0a2                	sd	s0,64(sp)
    8000169e:	fc26                	sd	s1,56(sp)
    800016a0:	f84a                	sd	s2,48(sp)
    800016a2:	f44e                	sd	s3,40(sp)
    800016a4:	f052                	sd	s4,32(sp)
    800016a6:	ec56                	sd	s5,24(sp)
    800016a8:	e85a                	sd	s6,16(sp)
    800016aa:	e45e                	sd	s7,8(sp)
    800016ac:	0880                	addi	s0,sp,80
    800016ae:	8aaa                	mv	s5,a0
    800016b0:	8b2e                	mv	s6,a1
    800016b2:	8bb2                	mv	s7,a2
    800016b4:	84b6                	mv	s1,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    800016b6:	00100a37          	lui	s4,0x100
    800016ba:	1a7d                	addi	s4,s4,-1
    800016bc:	0a32                	slli	s4,s4,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016be:	6985                	lui	s3,0x1
    800016c0:	a035                	j	800016ec <copyinstr+0x56>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016c2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016c6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016c8:	0017b793          	seqz	a5,a5
    800016cc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016d0:	60a6                	ld	ra,72(sp)
    800016d2:	6406                	ld	s0,64(sp)
    800016d4:	74e2                	ld	s1,56(sp)
    800016d6:	7942                	ld	s2,48(sp)
    800016d8:	79a2                	ld	s3,40(sp)
    800016da:	7a02                	ld	s4,32(sp)
    800016dc:	6ae2                	ld	s5,24(sp)
    800016de:	6b42                	ld	s6,16(sp)
    800016e0:	6ba2                	ld	s7,8(sp)
    800016e2:	6161                	addi	sp,sp,80
    800016e4:	8082                	ret
    srcva = va0 + PGSIZE;
    800016e6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800016ea:	c8a9                	beqz	s1,8000173c <copyinstr+0xa6>
    va0 = (uint)PGROUNDDOWN(srcva);
    800016ec:	014bf933          	and	s2,s7,s4
    pa0 = walkaddr(pagetable, va0);
    800016f0:	85ca                	mv	a1,s2
    800016f2:	8556                	mv	a0,s5
    800016f4:	00000097          	auipc	ra,0x0
    800016f8:	8b8080e7          	jalr	-1864(ra) # 80000fac <walkaddr>
    if(pa0 == 0)
    800016fc:	c131                	beqz	a0,80001740 <copyinstr+0xaa>
    n = PGSIZE - (srcva - va0);
    800016fe:	41790833          	sub	a6,s2,s7
    80001702:	984e                	add	a6,a6,s3
    if(n > max)
    80001704:	0104f363          	bgeu	s1,a6,8000170a <copyinstr+0x74>
    80001708:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000170a:	955e                	add	a0,a0,s7
    8000170c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001710:	fc080be3          	beqz	a6,800016e6 <copyinstr+0x50>
    80001714:	985a                	add	a6,a6,s6
    80001716:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001718:	41650633          	sub	a2,a0,s6
    8000171c:	14fd                	addi	s1,s1,-1
    8000171e:	9b26                	add	s6,s6,s1
    80001720:	00f60733          	add	a4,a2,a5
    80001724:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd5fa4>
    80001728:	df49                	beqz	a4,800016c2 <copyinstr+0x2c>
        *dst = *p;
    8000172a:	00e78023          	sb	a4,0(a5)
      --max;
    8000172e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001732:	0785                	addi	a5,a5,1
    while(n > 0){
    80001734:	ff0796e3          	bne	a5,a6,80001720 <copyinstr+0x8a>
      dst++;
    80001738:	8b42                	mv	s6,a6
    8000173a:	b775                	j	800016e6 <copyinstr+0x50>
    8000173c:	4781                	li	a5,0
    8000173e:	b769                	j	800016c8 <copyinstr+0x32>
      return -1;
    80001740:	557d                	li	a0,-1
    80001742:	b779                	j	800016d0 <copyinstr+0x3a>
  int got_null = 0;
    80001744:	4781                	li	a5,0
  if(got_null){
    80001746:	0017b793          	seqz	a5,a5
    8000174a:	40f00533          	neg	a0,a5
}
    8000174e:	8082                	ret

0000000080001750 <procinit>:

extern char trampoline[]; // trampoline.S

void
procinit(void)
{
    80001750:	715d                	addi	sp,sp,-80
    80001752:	e486                	sd	ra,72(sp)
    80001754:	e0a2                	sd	s0,64(sp)
    80001756:	fc26                	sd	s1,56(sp)
    80001758:	f84a                	sd	s2,48(sp)
    8000175a:	f44e                	sd	s3,40(sp)
    8000175c:	f052                	sd	s4,32(sp)
    8000175e:	ec56                	sd	s5,24(sp)
    80001760:	e85a                	sd	s6,16(sp)
    80001762:	e45e                	sd	s7,8(sp)
    80001764:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001766:	00007597          	auipc	a1,0x7
    8000176a:	b6258593          	addi	a1,a1,-1182 # 800082c8 <userret+0x238>
    8000176e:	00011517          	auipc	a0,0x11
    80001772:	17a50513          	addi	a0,a0,378 # 800128e8 <pid_lock>
    80001776:	fffff097          	auipc	ra,0xfffff
    8000177a:	262080e7          	jalr	610(ra) # 800009d8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177e:	00011917          	auipc	s2,0x11
    80001782:	58290913          	addi	s2,s2,1410 # 80012d00 <proc>
      initlock(&p->lock, "proc");
    80001786:	00007b97          	auipc	s7,0x7
    8000178a:	b4ab8b93          	addi	s7,s7,-1206 # 800082d0 <userret+0x240>
      // Map it high in memory, followed by an invalid
      // guard page.
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) (p - proc));
    8000178e:	8b4a                	mv	s6,s2
    80001790:	00007a97          	auipc	s5,0x7
    80001794:	358a8a93          	addi	s5,s5,856 # 80008ae8 <syscalls+0xc0>
    80001798:	040009b7          	lui	s3,0x4000
    8000179c:	19fd                	addi	s3,s3,-1
    8000179e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a0:	00017a17          	auipc	s4,0x17
    800017a4:	f60a0a13          	addi	s4,s4,-160 # 80018700 <tickslock>
      initlock(&p->lock, "proc");
    800017a8:	85de                	mv	a1,s7
    800017aa:	854a                	mv	a0,s2
    800017ac:	fffff097          	auipc	ra,0xfffff
    800017b0:	22c080e7          	jalr	556(ra) # 800009d8 <initlock>
      char *pa = kalloc();
    800017b4:	fffff097          	auipc	ra,0xfffff
    800017b8:	1c4080e7          	jalr	452(ra) # 80000978 <kalloc>
    800017bc:	85aa                	mv	a1,a0
      if(pa == 0)
    800017be:	c929                	beqz	a0,80001810 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800017c0:	416904b3          	sub	s1,s2,s6
    800017c4:	848d                	srai	s1,s1,0x3
    800017c6:	000ab783          	ld	a5,0(s5)
    800017ca:	02f484b3          	mul	s1,s1,a5
    800017ce:	2485                	addiw	s1,s1,1
    800017d0:	00d4949b          	slliw	s1,s1,0xd
    800017d4:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017d8:	4699                	li	a3,6
    800017da:	6605                	lui	a2,0x1
    800017dc:	8526                	mv	a0,s1
    800017de:	00000097          	auipc	ra,0x0
    800017e2:	8f0080e7          	jalr	-1808(ra) # 800010ce <kvmmap>
      p->kstack = va;
    800017e6:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ea:	16890913          	addi	s2,s2,360
    800017ee:	fb491de3          	bne	s2,s4,800017a8 <procinit+0x58>
  }
  kvminithart();
    800017f2:	fffff097          	auipc	ra,0xfffff
    800017f6:	796080e7          	jalr	1942(ra) # 80000f88 <kvminithart>
}
    800017fa:	60a6                	ld	ra,72(sp)
    800017fc:	6406                	ld	s0,64(sp)
    800017fe:	74e2                	ld	s1,56(sp)
    80001800:	7942                	ld	s2,48(sp)
    80001802:	79a2                	ld	s3,40(sp)
    80001804:	7a02                	ld	s4,32(sp)
    80001806:	6ae2                	ld	s5,24(sp)
    80001808:	6b42                	ld	s6,16(sp)
    8000180a:	6ba2                	ld	s7,8(sp)
    8000180c:	6161                	addi	sp,sp,80
    8000180e:	8082                	ret
        panic("kalloc");
    80001810:	00007517          	auipc	a0,0x7
    80001814:	ac850513          	addi	a0,a0,-1336 # 800082d8 <userret+0x248>
    80001818:	fffff097          	auipc	ra,0xfffff
    8000181c:	d36080e7          	jalr	-714(ra) # 8000054e <panic>

0000000080001820 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001820:	1141                	addi	sp,sp,-16
    80001822:	e422                	sd	s0,8(sp)
    80001824:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001826:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001828:	2501                	sext.w	a0,a0
    8000182a:	6422                	ld	s0,8(sp)
    8000182c:	0141                	addi	sp,sp,16
    8000182e:	8082                	ret

0000000080001830 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001830:	1141                	addi	sp,sp,-16
    80001832:	e422                	sd	s0,8(sp)
    80001834:	0800                	addi	s0,sp,16
    80001836:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001838:	2781                	sext.w	a5,a5
    8000183a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000183c:	00011517          	auipc	a0,0x11
    80001840:	0c450513          	addi	a0,a0,196 # 80012900 <cpus>
    80001844:	953e                	add	a0,a0,a5
    80001846:	6422                	ld	s0,8(sp)
    80001848:	0141                	addi	sp,sp,16
    8000184a:	8082                	ret

000000008000184c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    8000184c:	1101                	addi	sp,sp,-32
    8000184e:	ec06                	sd	ra,24(sp)
    80001850:	e822                	sd	s0,16(sp)
    80001852:	e426                	sd	s1,8(sp)
    80001854:	1000                	addi	s0,sp,32
  push_off();
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	198080e7          	jalr	408(ra) # 800009ee <push_off>
    8000185e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001860:	2781                	sext.w	a5,a5
    80001862:	079e                	slli	a5,a5,0x7
    80001864:	00011717          	auipc	a4,0x11
    80001868:	08470713          	addi	a4,a4,132 # 800128e8 <pid_lock>
    8000186c:	97ba                	add	a5,a5,a4
    8000186e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001870:	fffff097          	auipc	ra,0xfffff
    80001874:	1ca080e7          	jalr	458(ra) # 80000a3a <pop_off>
  return p;
}
    80001878:	8526                	mv	a0,s1
    8000187a:	60e2                	ld	ra,24(sp)
    8000187c:	6442                	ld	s0,16(sp)
    8000187e:	64a2                	ld	s1,8(sp)
    80001880:	6105                	addi	sp,sp,32
    80001882:	8082                	ret

0000000080001884 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001884:	1141                	addi	sp,sp,-16
    80001886:	e406                	sd	ra,8(sp)
    80001888:	e022                	sd	s0,0(sp)
    8000188a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000188c:	00000097          	auipc	ra,0x0
    80001890:	fc0080e7          	jalr	-64(ra) # 8000184c <myproc>
    80001894:	fffff097          	auipc	ra,0xfffff
    80001898:	2be080e7          	jalr	702(ra) # 80000b52 <release>

  if (first) {
    8000189c:	00007797          	auipc	a5,0x7
    800018a0:	7987a783          	lw	a5,1944(a5) # 80009034 <first.1743>
    800018a4:	eb89                	bnez	a5,800018b6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(minor(ROOTDEV));
  }

  usertrapret();
    800018a6:	00001097          	auipc	ra,0x1
    800018aa:	c1c080e7          	jalr	-996(ra) # 800024c2 <usertrapret>
}
    800018ae:	60a2                	ld	ra,8(sp)
    800018b0:	6402                	ld	s0,0(sp)
    800018b2:	0141                	addi	sp,sp,16
    800018b4:	8082                	ret
    first = 0;
    800018b6:	00007797          	auipc	a5,0x7
    800018ba:	7607af23          	sw	zero,1918(a5) # 80009034 <first.1743>
    fsinit(minor(ROOTDEV));
    800018be:	4501                	li	a0,0
    800018c0:	00002097          	auipc	ra,0x2
    800018c4:	944080e7          	jalr	-1724(ra) # 80003204 <fsinit>
    800018c8:	bff9                	j	800018a6 <forkret+0x22>

00000000800018ca <allocpid>:
allocpid() {
    800018ca:	1101                	addi	sp,sp,-32
    800018cc:	ec06                	sd	ra,24(sp)
    800018ce:	e822                	sd	s0,16(sp)
    800018d0:	e426                	sd	s1,8(sp)
    800018d2:	e04a                	sd	s2,0(sp)
    800018d4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018d6:	00011917          	auipc	s2,0x11
    800018da:	01290913          	addi	s2,s2,18 # 800128e8 <pid_lock>
    800018de:	854a                	mv	a0,s2
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	20a080e7          	jalr	522(ra) # 80000aea <acquire>
  pid = nextpid;
    800018e8:	00007797          	auipc	a5,0x7
    800018ec:	75078793          	addi	a5,a5,1872 # 80009038 <nextpid>
    800018f0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018f2:	0014871b          	addiw	a4,s1,1
    800018f6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018f8:	854a                	mv	a0,s2
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	258080e7          	jalr	600(ra) # 80000b52 <release>
}
    80001902:	8526                	mv	a0,s1
    80001904:	60e2                	ld	ra,24(sp)
    80001906:	6442                	ld	s0,16(sp)
    80001908:	64a2                	ld	s1,8(sp)
    8000190a:	6902                	ld	s2,0(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <proc_pagetable>:
{
    80001910:	1101                	addi	sp,sp,-32
    80001912:	ec06                	sd	ra,24(sp)
    80001914:	e822                	sd	s0,16(sp)
    80001916:	e426                	sd	s1,8(sp)
    80001918:	e04a                	sd	s2,0(sp)
    8000191a:	1000                	addi	s0,sp,32
    8000191c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    8000191e:	00000097          	auipc	ra,0x0
    80001922:	996080e7          	jalr	-1642(ra) # 800012b4 <uvmcreate>
    80001926:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001928:	4729                	li	a4,10
    8000192a:	00006697          	auipc	a3,0x6
    8000192e:	6d668693          	addi	a3,a3,1750 # 80008000 <trampoline>
    80001932:	6605                	lui	a2,0x1
    80001934:	040005b7          	lui	a1,0x4000
    80001938:	15fd                	addi	a1,a1,-1
    8000193a:	05b2                	slli	a1,a1,0xc
    8000193c:	fffff097          	auipc	ra,0xfffff
    80001940:	704080e7          	jalr	1796(ra) # 80001040 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001944:	4719                	li	a4,6
    80001946:	05893683          	ld	a3,88(s2)
    8000194a:	6605                	lui	a2,0x1
    8000194c:	020005b7          	lui	a1,0x2000
    80001950:	15fd                	addi	a1,a1,-1
    80001952:	05b6                	slli	a1,a1,0xd
    80001954:	8526                	mv	a0,s1
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	6ea080e7          	jalr	1770(ra) # 80001040 <mappages>
}
    8000195e:	8526                	mv	a0,s1
    80001960:	60e2                	ld	ra,24(sp)
    80001962:	6442                	ld	s0,16(sp)
    80001964:	64a2                	ld	s1,8(sp)
    80001966:	6902                	ld	s2,0(sp)
    80001968:	6105                	addi	sp,sp,32
    8000196a:	8082                	ret

000000008000196c <allocproc>:
{
    8000196c:	1101                	addi	sp,sp,-32
    8000196e:	ec06                	sd	ra,24(sp)
    80001970:	e822                	sd	s0,16(sp)
    80001972:	e426                	sd	s1,8(sp)
    80001974:	e04a                	sd	s2,0(sp)
    80001976:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001978:	00011497          	auipc	s1,0x11
    8000197c:	38848493          	addi	s1,s1,904 # 80012d00 <proc>
    80001980:	00017917          	auipc	s2,0x17
    80001984:	d8090913          	addi	s2,s2,-640 # 80018700 <tickslock>
    acquire(&p->lock);
    80001988:	8526                	mv	a0,s1
    8000198a:	fffff097          	auipc	ra,0xfffff
    8000198e:	160080e7          	jalr	352(ra) # 80000aea <acquire>
    if(p->state == UNUSED) {
    80001992:	4c9c                	lw	a5,24(s1)
    80001994:	cf81                	beqz	a5,800019ac <allocproc+0x40>
      release(&p->lock);
    80001996:	8526                	mv	a0,s1
    80001998:	fffff097          	auipc	ra,0xfffff
    8000199c:	1ba080e7          	jalr	442(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a0:	16848493          	addi	s1,s1,360
    800019a4:	ff2492e3          	bne	s1,s2,80001988 <allocproc+0x1c>
  return 0;
    800019a8:	4481                	li	s1,0
    800019aa:	a0a9                	j	800019f4 <allocproc+0x88>
  p->pid = allocpid();
    800019ac:	00000097          	auipc	ra,0x0
    800019b0:	f1e080e7          	jalr	-226(ra) # 800018ca <allocpid>
    800019b4:	dc88                	sw	a0,56(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	fc2080e7          	jalr	-62(ra) # 80000978 <kalloc>
    800019be:	892a                	mv	s2,a0
    800019c0:	eca8                	sd	a0,88(s1)
    800019c2:	c121                	beqz	a0,80001a02 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    800019c4:	8526                	mv	a0,s1
    800019c6:	00000097          	auipc	ra,0x0
    800019ca:	f4a080e7          	jalr	-182(ra) # 80001910 <proc_pagetable>
    800019ce:	e8a8                	sd	a0,80(s1)
  memset(&p->context, 0, sizeof p->context);
    800019d0:	07000613          	li	a2,112
    800019d4:	4581                	li	a1,0
    800019d6:	06048513          	addi	a0,s1,96
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	1d4080e7          	jalr	468(ra) # 80000bae <memset>
  p->context.ra = (uint64)forkret;
    800019e2:	00000797          	auipc	a5,0x0
    800019e6:	ea278793          	addi	a5,a5,-350 # 80001884 <forkret>
    800019ea:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800019ec:	60bc                	ld	a5,64(s1)
    800019ee:	6705                	lui	a4,0x1
    800019f0:	97ba                	add	a5,a5,a4
    800019f2:	f4bc                	sd	a5,104(s1)
}
    800019f4:	8526                	mv	a0,s1
    800019f6:	60e2                	ld	ra,24(sp)
    800019f8:	6442                	ld	s0,16(sp)
    800019fa:	64a2                	ld	s1,8(sp)
    800019fc:	6902                	ld	s2,0(sp)
    800019fe:	6105                	addi	sp,sp,32
    80001a00:	8082                	ret
    release(&p->lock);
    80001a02:	8526                	mv	a0,s1
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	14e080e7          	jalr	334(ra) # 80000b52 <release>
    return 0;
    80001a0c:	84ca                	mv	s1,s2
    80001a0e:	b7dd                	j	800019f4 <allocproc+0x88>

0000000080001a10 <proc_freepagetable>:
{
    80001a10:	1101                	addi	sp,sp,-32
    80001a12:	ec06                	sd	ra,24(sp)
    80001a14:	e822                	sd	s0,16(sp)
    80001a16:	e426                	sd	s1,8(sp)
    80001a18:	e04a                	sd	s2,0(sp)
    80001a1a:	1000                	addi	s0,sp,32
    80001a1c:	84aa                	mv	s1,a0
    80001a1e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001a20:	4681                	li	a3,0
    80001a22:	6605                	lui	a2,0x1
    80001a24:	040005b7          	lui	a1,0x4000
    80001a28:	15fd                	addi	a1,a1,-1
    80001a2a:	05b2                	slli	a1,a1,0xc
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	7c0080e7          	jalr	1984(ra) # 800011ec <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001a34:	4681                	li	a3,0
    80001a36:	6605                	lui	a2,0x1
    80001a38:	020005b7          	lui	a1,0x2000
    80001a3c:	15fd                	addi	a1,a1,-1
    80001a3e:	05b6                	slli	a1,a1,0xd
    80001a40:	8526                	mv	a0,s1
    80001a42:	fffff097          	auipc	ra,0xfffff
    80001a46:	7aa080e7          	jalr	1962(ra) # 800011ec <uvmunmap>
  if(sz > 0)
    80001a4a:	00091863          	bnez	s2,80001a5a <proc_freepagetable+0x4a>
}
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret
    uvmfree(pagetable, sz);
    80001a5a:	85ca                	mv	a1,s2
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	00000097          	auipc	ra,0x0
    80001a62:	9e4080e7          	jalr	-1564(ra) # 80001442 <uvmfree>
}
    80001a66:	b7e5                	j	80001a4e <proc_freepagetable+0x3e>

0000000080001a68 <freeproc>:
{
    80001a68:	1101                	addi	sp,sp,-32
    80001a6a:	ec06                	sd	ra,24(sp)
    80001a6c:	e822                	sd	s0,16(sp)
    80001a6e:	e426                	sd	s1,8(sp)
    80001a70:	1000                	addi	s0,sp,32
    80001a72:	84aa                	mv	s1,a0
  if(p->tf)
    80001a74:	6d28                	ld	a0,88(a0)
    80001a76:	c509                	beqz	a0,80001a80 <freeproc+0x18>
    kfree((void*)p->tf);
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	dec080e7          	jalr	-532(ra) # 80000864 <kfree>
  p->tf = 0;
    80001a80:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a84:	68a8                	ld	a0,80(s1)
    80001a86:	c511                	beqz	a0,80001a92 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001a88:	64ac                	ld	a1,72(s1)
    80001a8a:	00000097          	auipc	ra,0x0
    80001a8e:	f86080e7          	jalr	-122(ra) # 80001a10 <proc_freepagetable>
  p->pagetable = 0;
    80001a92:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a96:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a9a:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001a9e:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001aa2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001aa6:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001aaa:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001aae:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001ab2:	0004ac23          	sw	zero,24(s1)
}
    80001ab6:	60e2                	ld	ra,24(sp)
    80001ab8:	6442                	ld	s0,16(sp)
    80001aba:	64a2                	ld	s1,8(sp)
    80001abc:	6105                	addi	sp,sp,32
    80001abe:	8082                	ret

0000000080001ac0 <userinit>:
{
    80001ac0:	1101                	addi	sp,sp,-32
    80001ac2:	ec06                	sd	ra,24(sp)
    80001ac4:	e822                	sd	s0,16(sp)
    80001ac6:	e426                	sd	s1,8(sp)
    80001ac8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001aca:	00000097          	auipc	ra,0x0
    80001ace:	ea2080e7          	jalr	-350(ra) # 8000196c <allocproc>
    80001ad2:	84aa                	mv	s1,a0
  initproc = p;
    80001ad4:	00027797          	auipc	a5,0x27
    80001ad8:	56a7b223          	sd	a0,1380(a5) # 80029038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001adc:	03300613          	li	a2,51
    80001ae0:	00007597          	auipc	a1,0x7
    80001ae4:	52058593          	addi	a1,a1,1312 # 80009000 <initcode>
    80001ae8:	6928                	ld	a0,80(a0)
    80001aea:	00000097          	auipc	ra,0x0
    80001aee:	808080e7          	jalr	-2040(ra) # 800012f2 <uvminit>
  p->sz = PGSIZE;
    80001af2:	6785                	lui	a5,0x1
    80001af4:	e4bc                	sd	a5,72(s1)
  p->tf->epc = 0;      // user program counter
    80001af6:	6cb8                	ld	a4,88(s1)
    80001af8:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001afc:	6cb8                	ld	a4,88(s1)
    80001afe:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b00:	4641                	li	a2,16
    80001b02:	00006597          	auipc	a1,0x6
    80001b06:	7de58593          	addi	a1,a1,2014 # 800082e0 <userret+0x250>
    80001b0a:	15848513          	addi	a0,s1,344
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	1f6080e7          	jalr	502(ra) # 80000d04 <safestrcpy>
  p->cwd = namei("/");
    80001b16:	00006517          	auipc	a0,0x6
    80001b1a:	7da50513          	addi	a0,a0,2010 # 800082f0 <userret+0x260>
    80001b1e:	00002097          	auipc	ra,0x2
    80001b22:	0ea080e7          	jalr	234(ra) # 80003c08 <namei>
    80001b26:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b2a:	4789                	li	a5,2
    80001b2c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b2e:	8526                	mv	a0,s1
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	022080e7          	jalr	34(ra) # 80000b52 <release>
}
    80001b38:	60e2                	ld	ra,24(sp)
    80001b3a:	6442                	ld	s0,16(sp)
    80001b3c:	64a2                	ld	s1,8(sp)
    80001b3e:	6105                	addi	sp,sp,32
    80001b40:	8082                	ret

0000000080001b42 <growproc>:
{
    80001b42:	1101                	addi	sp,sp,-32
    80001b44:	ec06                	sd	ra,24(sp)
    80001b46:	e822                	sd	s0,16(sp)
    80001b48:	e426                	sd	s1,8(sp)
    80001b4a:	e04a                	sd	s2,0(sp)
    80001b4c:	1000                	addi	s0,sp,32
    80001b4e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b50:	00000097          	auipc	ra,0x0
    80001b54:	cfc080e7          	jalr	-772(ra) # 8000184c <myproc>
    80001b58:	892a                	mv	s2,a0
  sz = p->sz;
    80001b5a:	652c                	ld	a1,72(a0)
    80001b5c:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001b60:	00904f63          	bgtz	s1,80001b7e <growproc+0x3c>
  } else if(n < 0){
    80001b64:	0204cc63          	bltz	s1,80001b9c <growproc+0x5a>
  p->sz = sz;
    80001b68:	1602                	slli	a2,a2,0x20
    80001b6a:	9201                	srli	a2,a2,0x20
    80001b6c:	04c93423          	sd	a2,72(s2)
  return 0;
    80001b70:	4501                	li	a0,0
}
    80001b72:	60e2                	ld	ra,24(sp)
    80001b74:	6442                	ld	s0,16(sp)
    80001b76:	64a2                	ld	s1,8(sp)
    80001b78:	6902                	ld	s2,0(sp)
    80001b7a:	6105                	addi	sp,sp,32
    80001b7c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001b7e:	9e25                	addw	a2,a2,s1
    80001b80:	1602                	slli	a2,a2,0x20
    80001b82:	9201                	srli	a2,a2,0x20
    80001b84:	1582                	slli	a1,a1,0x20
    80001b86:	9181                	srli	a1,a1,0x20
    80001b88:	6928                	ld	a0,80(a0)
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	80e080e7          	jalr	-2034(ra) # 80001398 <uvmalloc>
    80001b92:	0005061b          	sext.w	a2,a0
    80001b96:	fa69                	bnez	a2,80001b68 <growproc+0x26>
      return -1;
    80001b98:	557d                	li	a0,-1
    80001b9a:	bfe1                	j	80001b72 <growproc+0x30>
    if((sz = uvmdealloc(p->pagetable, sz, sz + n)) == 0) {
    80001b9c:	9e25                	addw	a2,a2,s1
    80001b9e:	1602                	slli	a2,a2,0x20
    80001ba0:	9201                	srli	a2,a2,0x20
    80001ba2:	1582                	slli	a1,a1,0x20
    80001ba4:	9181                	srli	a1,a1,0x20
    80001ba6:	6928                	ld	a0,80(a0)
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	7bc080e7          	jalr	1980(ra) # 80001364 <uvmdealloc>
    80001bb0:	0005061b          	sext.w	a2,a0
    80001bb4:	fa55                	bnez	a2,80001b68 <growproc+0x26>
      return -1;
    80001bb6:	557d                	li	a0,-1
    80001bb8:	bf6d                	j	80001b72 <growproc+0x30>

0000000080001bba <fork>:
{
    80001bba:	7179                	addi	sp,sp,-48
    80001bbc:	f406                	sd	ra,40(sp)
    80001bbe:	f022                	sd	s0,32(sp)
    80001bc0:	ec26                	sd	s1,24(sp)
    80001bc2:	e84a                	sd	s2,16(sp)
    80001bc4:	e44e                	sd	s3,8(sp)
    80001bc6:	e052                	sd	s4,0(sp)
    80001bc8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	c82080e7          	jalr	-894(ra) # 8000184c <myproc>
    80001bd2:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	d98080e7          	jalr	-616(ra) # 8000196c <allocproc>
    80001bdc:	c175                	beqz	a0,80001cc0 <fork+0x106>
    80001bde:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001be0:	04893603          	ld	a2,72(s2)
    80001be4:	692c                	ld	a1,80(a0)
    80001be6:	05093503          	ld	a0,80(s2)
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	886080e7          	jalr	-1914(ra) # 80001470 <uvmcopy>
    80001bf2:	04054863          	bltz	a0,80001c42 <fork+0x88>
  np->sz = p->sz;
    80001bf6:	04893783          	ld	a5,72(s2)
    80001bfa:	04f9b423          	sd	a5,72(s3) # 4000048 <_entry-0x7bffffb8>
  np->parent = p;
    80001bfe:	0329b023          	sd	s2,32(s3)
  *(np->tf) = *(p->tf);
    80001c02:	05893683          	ld	a3,88(s2)
    80001c06:	87b6                	mv	a5,a3
    80001c08:	0589b703          	ld	a4,88(s3)
    80001c0c:	12068693          	addi	a3,a3,288
    80001c10:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c14:	6788                	ld	a0,8(a5)
    80001c16:	6b8c                	ld	a1,16(a5)
    80001c18:	6f90                	ld	a2,24(a5)
    80001c1a:	01073023          	sd	a6,0(a4)
    80001c1e:	e708                	sd	a0,8(a4)
    80001c20:	eb0c                	sd	a1,16(a4)
    80001c22:	ef10                	sd	a2,24(a4)
    80001c24:	02078793          	addi	a5,a5,32
    80001c28:	02070713          	addi	a4,a4,32
    80001c2c:	fed792e3          	bne	a5,a3,80001c10 <fork+0x56>
  np->tf->a0 = 0;
    80001c30:	0589b783          	ld	a5,88(s3)
    80001c34:	0607b823          	sd	zero,112(a5)
    80001c38:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001c3c:	15000a13          	li	s4,336
    80001c40:	a03d                	j	80001c6e <fork+0xb4>
    freeproc(np);
    80001c42:	854e                	mv	a0,s3
    80001c44:	00000097          	auipc	ra,0x0
    80001c48:	e24080e7          	jalr	-476(ra) # 80001a68 <freeproc>
    release(&np->lock);
    80001c4c:	854e                	mv	a0,s3
    80001c4e:	fffff097          	auipc	ra,0xfffff
    80001c52:	f04080e7          	jalr	-252(ra) # 80000b52 <release>
    return -1;
    80001c56:	54fd                	li	s1,-1
    80001c58:	a899                	j	80001cae <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c5a:	00003097          	auipc	ra,0x3
    80001c5e:	8a0080e7          	jalr	-1888(ra) # 800044fa <filedup>
    80001c62:	009987b3          	add	a5,s3,s1
    80001c66:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001c68:	04a1                	addi	s1,s1,8
    80001c6a:	01448763          	beq	s1,s4,80001c78 <fork+0xbe>
    if(p->ofile[i])
    80001c6e:	009907b3          	add	a5,s2,s1
    80001c72:	6388                	ld	a0,0(a5)
    80001c74:	f17d                	bnez	a0,80001c5a <fork+0xa0>
    80001c76:	bfcd                	j	80001c68 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001c78:	15093503          	ld	a0,336(s2)
    80001c7c:	00001097          	auipc	ra,0x1
    80001c80:	7c2080e7          	jalr	1986(ra) # 8000343e <idup>
    80001c84:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c88:	4641                	li	a2,16
    80001c8a:	15890593          	addi	a1,s2,344
    80001c8e:	15898513          	addi	a0,s3,344
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	072080e7          	jalr	114(ra) # 80000d04 <safestrcpy>
  pid = np->pid;
    80001c9a:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    80001c9e:	4789                	li	a5,2
    80001ca0:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001ca4:	854e                	mv	a0,s3
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	eac080e7          	jalr	-340(ra) # 80000b52 <release>
}
    80001cae:	8526                	mv	a0,s1
    80001cb0:	70a2                	ld	ra,40(sp)
    80001cb2:	7402                	ld	s0,32(sp)
    80001cb4:	64e2                	ld	s1,24(sp)
    80001cb6:	6942                	ld	s2,16(sp)
    80001cb8:	69a2                	ld	s3,8(sp)
    80001cba:	6a02                	ld	s4,0(sp)
    80001cbc:	6145                	addi	sp,sp,48
    80001cbe:	8082                	ret
    return -1;
    80001cc0:	54fd                	li	s1,-1
    80001cc2:	b7f5                	j	80001cae <fork+0xf4>

0000000080001cc4 <reparent>:
reparent(struct proc *p, struct proc *parent) {
    80001cc4:	711d                	addi	sp,sp,-96
    80001cc6:	ec86                	sd	ra,88(sp)
    80001cc8:	e8a2                	sd	s0,80(sp)
    80001cca:	e4a6                	sd	s1,72(sp)
    80001ccc:	e0ca                	sd	s2,64(sp)
    80001cce:	fc4e                	sd	s3,56(sp)
    80001cd0:	f852                	sd	s4,48(sp)
    80001cd2:	f456                	sd	s5,40(sp)
    80001cd4:	f05a                	sd	s6,32(sp)
    80001cd6:	ec5e                	sd	s7,24(sp)
    80001cd8:	e862                	sd	s8,16(sp)
    80001cda:	e466                	sd	s9,8(sp)
    80001cdc:	1080                	addi	s0,sp,96
    80001cde:	892a                	mv	s2,a0
  int child_of_init = (p->parent == initproc);
    80001ce0:	02053b83          	ld	s7,32(a0)
    80001ce4:	00027b17          	auipc	s6,0x27
    80001ce8:	354b3b03          	ld	s6,852(s6) # 80029038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001cec:	00011497          	auipc	s1,0x11
    80001cf0:	01448493          	addi	s1,s1,20 # 80012d00 <proc>
      pp->parent = initproc;
    80001cf4:	00027a17          	auipc	s4,0x27
    80001cf8:	344a0a13          	addi	s4,s4,836 # 80029038 <initproc>
      if(pp->state == ZOMBIE) {
    80001cfc:	4a91                	li	s5,4
// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
  if(p->chan == p && p->state == SLEEPING) {
    80001cfe:	4c05                	li	s8,1
    p->state = RUNNABLE;
    80001d00:	4c89                	li	s9,2
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001d02:	00017997          	auipc	s3,0x17
    80001d06:	9fe98993          	addi	s3,s3,-1538 # 80018700 <tickslock>
    80001d0a:	a805                	j	80001d3a <reparent+0x76>
  if(p->chan == p && p->state == SLEEPING) {
    80001d0c:	751c                	ld	a5,40(a0)
    80001d0e:	00f51d63          	bne	a0,a5,80001d28 <reparent+0x64>
    80001d12:	4d1c                	lw	a5,24(a0)
    80001d14:	01879a63          	bne	a5,s8,80001d28 <reparent+0x64>
    p->state = RUNNABLE;
    80001d18:	01952c23          	sw	s9,24(a0)
        if(!child_of_init)
    80001d1c:	016b8663          	beq	s7,s6,80001d28 <reparent+0x64>
          release(&initproc->lock);
    80001d20:	fffff097          	auipc	ra,0xfffff
    80001d24:	e32080e7          	jalr	-462(ra) # 80000b52 <release>
      release(&pp->lock);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	fffff097          	auipc	ra,0xfffff
    80001d2e:	e28080e7          	jalr	-472(ra) # 80000b52 <release>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001d32:	16848493          	addi	s1,s1,360
    80001d36:	03348f63          	beq	s1,s3,80001d74 <reparent+0xb0>
    if(pp->parent == p){
    80001d3a:	709c                	ld	a5,32(s1)
    80001d3c:	ff279be3          	bne	a5,s2,80001d32 <reparent+0x6e>
      acquire(&pp->lock);
    80001d40:	8526                	mv	a0,s1
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	da8080e7          	jalr	-600(ra) # 80000aea <acquire>
      pp->parent = initproc;
    80001d4a:	000a3503          	ld	a0,0(s4)
    80001d4e:	f088                	sd	a0,32(s1)
      if(pp->state == ZOMBIE) {
    80001d50:	4c9c                	lw	a5,24(s1)
    80001d52:	fd579be3          	bne	a5,s5,80001d28 <reparent+0x64>
        if(!child_of_init)
    80001d56:	fb6b8be3          	beq	s7,s6,80001d0c <reparent+0x48>
          acquire(&initproc->lock);
    80001d5a:	fffff097          	auipc	ra,0xfffff
    80001d5e:	d90080e7          	jalr	-624(ra) # 80000aea <acquire>
        wakeup1(initproc);
    80001d62:	000a3503          	ld	a0,0(s4)
  if(p->chan == p && p->state == SLEEPING) {
    80001d66:	751c                	ld	a5,40(a0)
    80001d68:	faa79ce3          	bne	a5,a0,80001d20 <reparent+0x5c>
    80001d6c:	4d1c                	lw	a5,24(a0)
    80001d6e:	fb8799e3          	bne	a5,s8,80001d20 <reparent+0x5c>
    80001d72:	b75d                	j	80001d18 <reparent+0x54>
}
    80001d74:	60e6                	ld	ra,88(sp)
    80001d76:	6446                	ld	s0,80(sp)
    80001d78:	64a6                	ld	s1,72(sp)
    80001d7a:	6906                	ld	s2,64(sp)
    80001d7c:	79e2                	ld	s3,56(sp)
    80001d7e:	7a42                	ld	s4,48(sp)
    80001d80:	7aa2                	ld	s5,40(sp)
    80001d82:	7b02                	ld	s6,32(sp)
    80001d84:	6be2                	ld	s7,24(sp)
    80001d86:	6c42                	ld	s8,16(sp)
    80001d88:	6ca2                	ld	s9,8(sp)
    80001d8a:	6125                	addi	sp,sp,96
    80001d8c:	8082                	ret

0000000080001d8e <scheduler>:
{
    80001d8e:	715d                	addi	sp,sp,-80
    80001d90:	e486                	sd	ra,72(sp)
    80001d92:	e0a2                	sd	s0,64(sp)
    80001d94:	fc26                	sd	s1,56(sp)
    80001d96:	f84a                	sd	s2,48(sp)
    80001d98:	f44e                	sd	s3,40(sp)
    80001d9a:	f052                	sd	s4,32(sp)
    80001d9c:	ec56                	sd	s5,24(sp)
    80001d9e:	e85a                	sd	s6,16(sp)
    80001da0:	e45e                	sd	s7,8(sp)
    80001da2:	e062                	sd	s8,0(sp)
    80001da4:	0880                	addi	s0,sp,80
    80001da6:	8792                	mv	a5,tp
  int id = r_tp();
    80001da8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001daa:	00779b13          	slli	s6,a5,0x7
    80001dae:	00011717          	auipc	a4,0x11
    80001db2:	b3a70713          	addi	a4,a4,-1222 # 800128e8 <pid_lock>
    80001db6:	975a                	add	a4,a4,s6
    80001db8:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001dbc:	00011717          	auipc	a4,0x11
    80001dc0:	b4c70713          	addi	a4,a4,-1204 # 80012908 <cpus+0x8>
    80001dc4:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001dc6:	4c0d                	li	s8,3
        c->proc = p;
    80001dc8:	079e                	slli	a5,a5,0x7
    80001dca:	00011a17          	auipc	s4,0x11
    80001dce:	b1ea0a13          	addi	s4,s4,-1250 # 800128e8 <pid_lock>
    80001dd2:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dd4:	00017997          	auipc	s3,0x17
    80001dd8:	92c98993          	addi	s3,s3,-1748 # 80018700 <tickslock>
        found = 1;
    80001ddc:	4b85                	li	s7,1
    80001dde:	a08d                	j	80001e40 <scheduler+0xb2>
        p->state = RUNNING;
    80001de0:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001de4:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001de8:	06048593          	addi	a1,s1,96
    80001dec:	855a                	mv	a0,s6
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	62a080e7          	jalr	1578(ra) # 80002418 <swtch>
        c->proc = 0;
    80001df6:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001dfa:	8ade                	mv	s5,s7
      release(&p->lock);
    80001dfc:	8526                	mv	a0,s1
    80001dfe:	fffff097          	auipc	ra,0xfffff
    80001e02:	d54080e7          	jalr	-684(ra) # 80000b52 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e06:	16848493          	addi	s1,s1,360
    80001e0a:	01348b63          	beq	s1,s3,80001e20 <scheduler+0x92>
      acquire(&p->lock);
    80001e0e:	8526                	mv	a0,s1
    80001e10:	fffff097          	auipc	ra,0xfffff
    80001e14:	cda080e7          	jalr	-806(ra) # 80000aea <acquire>
      if(p->state == RUNNABLE) {
    80001e18:	4c9c                	lw	a5,24(s1)
    80001e1a:	ff2791e3          	bne	a5,s2,80001dfc <scheduler+0x6e>
    80001e1e:	b7c9                	j	80001de0 <scheduler+0x52>
    if(found == 0){
    80001e20:	020a9063          	bnez	s5,80001e40 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001e24:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001e28:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001e2c:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e34:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e38:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e3c:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001e40:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001e44:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001e48:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e4c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e50:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e54:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e58:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e5a:	00011497          	auipc	s1,0x11
    80001e5e:	ea648493          	addi	s1,s1,-346 # 80012d00 <proc>
      if(p->state == RUNNABLE) {
    80001e62:	4909                	li	s2,2
    80001e64:	b76d                	j	80001e0e <scheduler+0x80>

0000000080001e66 <sched>:
{
    80001e66:	7179                	addi	sp,sp,-48
    80001e68:	f406                	sd	ra,40(sp)
    80001e6a:	f022                	sd	s0,32(sp)
    80001e6c:	ec26                	sd	s1,24(sp)
    80001e6e:	e84a                	sd	s2,16(sp)
    80001e70:	e44e                	sd	s3,8(sp)
    80001e72:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e74:	00000097          	auipc	ra,0x0
    80001e78:	9d8080e7          	jalr	-1576(ra) # 8000184c <myproc>
    80001e7c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	c2c080e7          	jalr	-980(ra) # 80000aaa <holding>
    80001e86:	c93d                	beqz	a0,80001efc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e88:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e8a:	2781                	sext.w	a5,a5
    80001e8c:	079e                	slli	a5,a5,0x7
    80001e8e:	00011717          	auipc	a4,0x11
    80001e92:	a5a70713          	addi	a4,a4,-1446 # 800128e8 <pid_lock>
    80001e96:	97ba                	add	a5,a5,a4
    80001e98:	0907a703          	lw	a4,144(a5)
    80001e9c:	4785                	li	a5,1
    80001e9e:	06f71763          	bne	a4,a5,80001f0c <sched+0xa6>
  if(p->state == RUNNING)
    80001ea2:	4c98                	lw	a4,24(s1)
    80001ea4:	478d                	li	a5,3
    80001ea6:	06f70b63          	beq	a4,a5,80001f1c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eaa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001eae:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001eb0:	efb5                	bnez	a5,80001f2c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eb2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001eb4:	00011917          	auipc	s2,0x11
    80001eb8:	a3490913          	addi	s2,s2,-1484 # 800128e8 <pid_lock>
    80001ebc:	2781                	sext.w	a5,a5
    80001ebe:	079e                	slli	a5,a5,0x7
    80001ec0:	97ca                	add	a5,a5,s2
    80001ec2:	0947a983          	lw	s3,148(a5)
    80001ec6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001ec8:	2781                	sext.w	a5,a5
    80001eca:	079e                	slli	a5,a5,0x7
    80001ecc:	00011597          	auipc	a1,0x11
    80001ed0:	a3c58593          	addi	a1,a1,-1476 # 80012908 <cpus+0x8>
    80001ed4:	95be                	add	a1,a1,a5
    80001ed6:	06048513          	addi	a0,s1,96
    80001eda:	00000097          	auipc	ra,0x0
    80001ede:	53e080e7          	jalr	1342(ra) # 80002418 <swtch>
    80001ee2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ee4:	2781                	sext.w	a5,a5
    80001ee6:	079e                	slli	a5,a5,0x7
    80001ee8:	97ca                	add	a5,a5,s2
    80001eea:	0937aa23          	sw	s3,148(a5)
}
    80001eee:	70a2                	ld	ra,40(sp)
    80001ef0:	7402                	ld	s0,32(sp)
    80001ef2:	64e2                	ld	s1,24(sp)
    80001ef4:	6942                	ld	s2,16(sp)
    80001ef6:	69a2                	ld	s3,8(sp)
    80001ef8:	6145                	addi	sp,sp,48
    80001efa:	8082                	ret
    panic("sched p->lock");
    80001efc:	00006517          	auipc	a0,0x6
    80001f00:	3fc50513          	addi	a0,a0,1020 # 800082f8 <userret+0x268>
    80001f04:	ffffe097          	auipc	ra,0xffffe
    80001f08:	64a080e7          	jalr	1610(ra) # 8000054e <panic>
    panic("sched locks");
    80001f0c:	00006517          	auipc	a0,0x6
    80001f10:	3fc50513          	addi	a0,a0,1020 # 80008308 <userret+0x278>
    80001f14:	ffffe097          	auipc	ra,0xffffe
    80001f18:	63a080e7          	jalr	1594(ra) # 8000054e <panic>
    panic("sched running");
    80001f1c:	00006517          	auipc	a0,0x6
    80001f20:	3fc50513          	addi	a0,a0,1020 # 80008318 <userret+0x288>
    80001f24:	ffffe097          	auipc	ra,0xffffe
    80001f28:	62a080e7          	jalr	1578(ra) # 8000054e <panic>
    panic("sched interruptible");
    80001f2c:	00006517          	auipc	a0,0x6
    80001f30:	3fc50513          	addi	a0,a0,1020 # 80008328 <userret+0x298>
    80001f34:	ffffe097          	auipc	ra,0xffffe
    80001f38:	61a080e7          	jalr	1562(ra) # 8000054e <panic>

0000000080001f3c <exit>:
{
    80001f3c:	7179                	addi	sp,sp,-48
    80001f3e:	f406                	sd	ra,40(sp)
    80001f40:	f022                	sd	s0,32(sp)
    80001f42:	ec26                	sd	s1,24(sp)
    80001f44:	e84a                	sd	s2,16(sp)
    80001f46:	e44e                	sd	s3,8(sp)
    80001f48:	e052                	sd	s4,0(sp)
    80001f4a:	1800                	addi	s0,sp,48
    80001f4c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001f4e:	00000097          	auipc	ra,0x0
    80001f52:	8fe080e7          	jalr	-1794(ra) # 8000184c <myproc>
    80001f56:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f58:	00027797          	auipc	a5,0x27
    80001f5c:	0e07b783          	ld	a5,224(a5) # 80029038 <initproc>
    80001f60:	0d050493          	addi	s1,a0,208
    80001f64:	15050913          	addi	s2,a0,336
    80001f68:	02a79363          	bne	a5,a0,80001f8e <exit+0x52>
    panic("init exiting");
    80001f6c:	00006517          	auipc	a0,0x6
    80001f70:	3d450513          	addi	a0,a0,980 # 80008340 <userret+0x2b0>
    80001f74:	ffffe097          	auipc	ra,0xffffe
    80001f78:	5da080e7          	jalr	1498(ra) # 8000054e <panic>
      fileclose(f);
    80001f7c:	00002097          	auipc	ra,0x2
    80001f80:	5d0080e7          	jalr	1488(ra) # 8000454c <fileclose>
      p->ofile[fd] = 0;
    80001f84:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f88:	04a1                	addi	s1,s1,8
    80001f8a:	01248563          	beq	s1,s2,80001f94 <exit+0x58>
    if(p->ofile[fd]){
    80001f8e:	6088                	ld	a0,0(s1)
    80001f90:	f575                	bnez	a0,80001f7c <exit+0x40>
    80001f92:	bfdd                	j	80001f88 <exit+0x4c>
  begin_op(ROOTDEV);
    80001f94:	4501                	li	a0,0
    80001f96:	00002097          	auipc	ra,0x2
    80001f9a:	f8e080e7          	jalr	-114(ra) # 80003f24 <begin_op>
  iput(p->cwd);
    80001f9e:	1509b503          	ld	a0,336(s3)
    80001fa2:	00001097          	auipc	ra,0x1
    80001fa6:	5e8080e7          	jalr	1512(ra) # 8000358a <iput>
  end_op(ROOTDEV);
    80001faa:	4501                	li	a0,0
    80001fac:	00002097          	auipc	ra,0x2
    80001fb0:	022080e7          	jalr	34(ra) # 80003fce <end_op>
  p->cwd = 0;
    80001fb4:	1409b823          	sd	zero,336(s3)
  acquire(&p->parent->lock);
    80001fb8:	0209b503          	ld	a0,32(s3)
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	b2e080e7          	jalr	-1234(ra) # 80000aea <acquire>
  acquire(&p->lock);
    80001fc4:	854e                	mv	a0,s3
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	b24080e7          	jalr	-1244(ra) # 80000aea <acquire>
  reparent(p, p->parent);
    80001fce:	0209b583          	ld	a1,32(s3)
    80001fd2:	854e                	mv	a0,s3
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	cf0080e7          	jalr	-784(ra) # 80001cc4 <reparent>
  wakeup1(p->parent);
    80001fdc:	0209b783          	ld	a5,32(s3)
  if(p->chan == p && p->state == SLEEPING) {
    80001fe0:	7798                	ld	a4,40(a5)
    80001fe2:	02e78963          	beq	a5,a4,80002014 <exit+0xd8>
  p->xstate = status;
    80001fe6:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80001fea:	4791                	li	a5,4
    80001fec:	00f9ac23          	sw	a5,24(s3)
  release(&p->parent->lock);
    80001ff0:	0209b503          	ld	a0,32(s3)
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	b5e080e7          	jalr	-1186(ra) # 80000b52 <release>
  sched();
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	e6a080e7          	jalr	-406(ra) # 80001e66 <sched>
  panic("zombie exit");
    80002004:	00006517          	auipc	a0,0x6
    80002008:	34c50513          	addi	a0,a0,844 # 80008350 <userret+0x2c0>
    8000200c:	ffffe097          	auipc	ra,0xffffe
    80002010:	542080e7          	jalr	1346(ra) # 8000054e <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80002014:	4f94                	lw	a3,24(a5)
    80002016:	4705                	li	a4,1
    80002018:	fce697e3          	bne	a3,a4,80001fe6 <exit+0xaa>
    p->state = RUNNABLE;
    8000201c:	4709                	li	a4,2
    8000201e:	cf98                	sw	a4,24(a5)
    80002020:	b7d9                	j	80001fe6 <exit+0xaa>

0000000080002022 <yield>:
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	820080e7          	jalr	-2016(ra) # 8000184c <myproc>
    80002034:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	ab4080e7          	jalr	-1356(ra) # 80000aea <acquire>
  p->state = RUNNABLE;
    8000203e:	4789                	li	a5,2
    80002040:	cc9c                	sw	a5,24(s1)
  sched();
    80002042:	00000097          	auipc	ra,0x0
    80002046:	e24080e7          	jalr	-476(ra) # 80001e66 <sched>
  release(&p->lock);
    8000204a:	8526                	mv	a0,s1
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	b06080e7          	jalr	-1274(ra) # 80000b52 <release>
}
    80002054:	60e2                	ld	ra,24(sp)
    80002056:	6442                	ld	s0,16(sp)
    80002058:	64a2                	ld	s1,8(sp)
    8000205a:	6105                	addi	sp,sp,32
    8000205c:	8082                	ret

000000008000205e <sleep>:
{
    8000205e:	7179                	addi	sp,sp,-48
    80002060:	f406                	sd	ra,40(sp)
    80002062:	f022                	sd	s0,32(sp)
    80002064:	ec26                	sd	s1,24(sp)
    80002066:	e84a                	sd	s2,16(sp)
    80002068:	e44e                	sd	s3,8(sp)
    8000206a:	1800                	addi	s0,sp,48
    8000206c:	89aa                	mv	s3,a0
    8000206e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	7dc080e7          	jalr	2012(ra) # 8000184c <myproc>
    80002078:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000207a:	05250663          	beq	a0,s2,800020c6 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	a6c080e7          	jalr	-1428(ra) # 80000aea <acquire>
    release(lk);
    80002086:	854a                	mv	a0,s2
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	aca080e7          	jalr	-1334(ra) # 80000b52 <release>
  p->chan = chan;
    80002090:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002094:	4785                	li	a5,1
    80002096:	cc9c                	sw	a5,24(s1)
  sched();
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	dce080e7          	jalr	-562(ra) # 80001e66 <sched>
  p->chan = 0;
    800020a0:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800020a4:	8526                	mv	a0,s1
    800020a6:	fffff097          	auipc	ra,0xfffff
    800020aa:	aac080e7          	jalr	-1364(ra) # 80000b52 <release>
    acquire(lk);
    800020ae:	854a                	mv	a0,s2
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	a3a080e7          	jalr	-1478(ra) # 80000aea <acquire>
}
    800020b8:	70a2                	ld	ra,40(sp)
    800020ba:	7402                	ld	s0,32(sp)
    800020bc:	64e2                	ld	s1,24(sp)
    800020be:	6942                	ld	s2,16(sp)
    800020c0:	69a2                	ld	s3,8(sp)
    800020c2:	6145                	addi	sp,sp,48
    800020c4:	8082                	ret
  p->chan = chan;
    800020c6:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800020ca:	4785                	li	a5,1
    800020cc:	cd1c                	sw	a5,24(a0)
  sched();
    800020ce:	00000097          	auipc	ra,0x0
    800020d2:	d98080e7          	jalr	-616(ra) # 80001e66 <sched>
  p->chan = 0;
    800020d6:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800020da:	bff9                	j	800020b8 <sleep+0x5a>

00000000800020dc <wait>:
{
    800020dc:	715d                	addi	sp,sp,-80
    800020de:	e486                	sd	ra,72(sp)
    800020e0:	e0a2                	sd	s0,64(sp)
    800020e2:	fc26                	sd	s1,56(sp)
    800020e4:	f84a                	sd	s2,48(sp)
    800020e6:	f44e                	sd	s3,40(sp)
    800020e8:	f052                	sd	s4,32(sp)
    800020ea:	ec56                	sd	s5,24(sp)
    800020ec:	e85a                	sd	s6,16(sp)
    800020ee:	e45e                	sd	s7,8(sp)
    800020f0:	e062                	sd	s8,0(sp)
    800020f2:	0880                	addi	s0,sp,80
    800020f4:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	756080e7          	jalr	1878(ra) # 8000184c <myproc>
    800020fe:	892a                	mv	s2,a0
  acquire(&p->lock);
    80002100:	8c2a                	mv	s8,a0
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	9e8080e7          	jalr	-1560(ra) # 80000aea <acquire>
    havekids = 0;
    8000210a:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000210c:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    8000210e:	00016997          	auipc	s3,0x16
    80002112:	5f298993          	addi	s3,s3,1522 # 80018700 <tickslock>
        havekids = 1;
    80002116:	4a85                	li	s5,1
    havekids = 0;
    80002118:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000211a:	00011497          	auipc	s1,0x11
    8000211e:	be648493          	addi	s1,s1,-1050 # 80012d00 <proc>
    80002122:	a08d                	j	80002184 <wait+0xa8>
          pid = np->pid;
    80002124:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002128:	000b0e63          	beqz	s6,80002144 <wait+0x68>
    8000212c:	4691                	li	a3,4
    8000212e:	03448613          	addi	a2,s1,52
    80002132:	85da                	mv	a1,s6
    80002134:	05093503          	ld	a0,80(s2)
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	43a080e7          	jalr	1082(ra) # 80001572 <copyout>
    80002140:	02054263          	bltz	a0,80002164 <wait+0x88>
          freeproc(np);
    80002144:	8526                	mv	a0,s1
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	922080e7          	jalr	-1758(ra) # 80001a68 <freeproc>
          release(&np->lock);
    8000214e:	8526                	mv	a0,s1
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	a02080e7          	jalr	-1534(ra) # 80000b52 <release>
          release(&p->lock);
    80002158:	854a                	mv	a0,s2
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	9f8080e7          	jalr	-1544(ra) # 80000b52 <release>
          return pid;
    80002162:	a8a9                	j	800021bc <wait+0xe0>
            release(&np->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	9ec080e7          	jalr	-1556(ra) # 80000b52 <release>
            release(&p->lock);
    8000216e:	854a                	mv	a0,s2
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	9e2080e7          	jalr	-1566(ra) # 80000b52 <release>
            return -1;
    80002178:	59fd                	li	s3,-1
    8000217a:	a089                	j	800021bc <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    8000217c:	16848493          	addi	s1,s1,360
    80002180:	03348463          	beq	s1,s3,800021a8 <wait+0xcc>
      if(np->parent == p){
    80002184:	709c                	ld	a5,32(s1)
    80002186:	ff279be3          	bne	a5,s2,8000217c <wait+0xa0>
        acquire(&np->lock);
    8000218a:	8526                	mv	a0,s1
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	95e080e7          	jalr	-1698(ra) # 80000aea <acquire>
        if(np->state == ZOMBIE){
    80002194:	4c9c                	lw	a5,24(s1)
    80002196:	f94787e3          	beq	a5,s4,80002124 <wait+0x48>
        release(&np->lock);
    8000219a:	8526                	mv	a0,s1
    8000219c:	fffff097          	auipc	ra,0xfffff
    800021a0:	9b6080e7          	jalr	-1610(ra) # 80000b52 <release>
        havekids = 1;
    800021a4:	8756                	mv	a4,s5
    800021a6:	bfd9                	j	8000217c <wait+0xa0>
    if(!havekids || p->killed){
    800021a8:	c701                	beqz	a4,800021b0 <wait+0xd4>
    800021aa:	03092783          	lw	a5,48(s2)
    800021ae:	c785                	beqz	a5,800021d6 <wait+0xfa>
      release(&p->lock);
    800021b0:	854a                	mv	a0,s2
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	9a0080e7          	jalr	-1632(ra) # 80000b52 <release>
      return -1;
    800021ba:	59fd                	li	s3,-1
}
    800021bc:	854e                	mv	a0,s3
    800021be:	60a6                	ld	ra,72(sp)
    800021c0:	6406                	ld	s0,64(sp)
    800021c2:	74e2                	ld	s1,56(sp)
    800021c4:	7942                	ld	s2,48(sp)
    800021c6:	79a2                	ld	s3,40(sp)
    800021c8:	7a02                	ld	s4,32(sp)
    800021ca:	6ae2                	ld	s5,24(sp)
    800021cc:	6b42                	ld	s6,16(sp)
    800021ce:	6ba2                	ld	s7,8(sp)
    800021d0:	6c02                	ld	s8,0(sp)
    800021d2:	6161                	addi	sp,sp,80
    800021d4:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800021d6:	85e2                	mv	a1,s8
    800021d8:	854a                	mv	a0,s2
    800021da:	00000097          	auipc	ra,0x0
    800021de:	e84080e7          	jalr	-380(ra) # 8000205e <sleep>
    havekids = 0;
    800021e2:	bf1d                	j	80002118 <wait+0x3c>

00000000800021e4 <wakeup>:
{
    800021e4:	7139                	addi	sp,sp,-64
    800021e6:	fc06                	sd	ra,56(sp)
    800021e8:	f822                	sd	s0,48(sp)
    800021ea:	f426                	sd	s1,40(sp)
    800021ec:	f04a                	sd	s2,32(sp)
    800021ee:	ec4e                	sd	s3,24(sp)
    800021f0:	e852                	sd	s4,16(sp)
    800021f2:	e456                	sd	s5,8(sp)
    800021f4:	0080                	addi	s0,sp,64
    800021f6:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800021f8:	00011497          	auipc	s1,0x11
    800021fc:	b0848493          	addi	s1,s1,-1272 # 80012d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002200:	4985                	li	s3,1
      p->state = RUNNABLE;
    80002202:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002204:	00016917          	auipc	s2,0x16
    80002208:	4fc90913          	addi	s2,s2,1276 # 80018700 <tickslock>
    8000220c:	a821                	j	80002224 <wakeup+0x40>
      p->state = RUNNABLE;
    8000220e:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	93e080e7          	jalr	-1730(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000221c:	16848493          	addi	s1,s1,360
    80002220:	01248e63          	beq	s1,s2,8000223c <wakeup+0x58>
    acquire(&p->lock);
    80002224:	8526                	mv	a0,s1
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	8c4080e7          	jalr	-1852(ra) # 80000aea <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000222e:	4c9c                	lw	a5,24(s1)
    80002230:	ff3791e3          	bne	a5,s3,80002212 <wakeup+0x2e>
    80002234:	749c                	ld	a5,40(s1)
    80002236:	fd479ee3          	bne	a5,s4,80002212 <wakeup+0x2e>
    8000223a:	bfd1                	j	8000220e <wakeup+0x2a>
}
    8000223c:	70e2                	ld	ra,56(sp)
    8000223e:	7442                	ld	s0,48(sp)
    80002240:	74a2                	ld	s1,40(sp)
    80002242:	7902                	ld	s2,32(sp)
    80002244:	69e2                	ld	s3,24(sp)
    80002246:	6a42                	ld	s4,16(sp)
    80002248:	6aa2                	ld	s5,8(sp)
    8000224a:	6121                	addi	sp,sp,64
    8000224c:	8082                	ret

000000008000224e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000224e:	7179                	addi	sp,sp,-48
    80002250:	f406                	sd	ra,40(sp)
    80002252:	f022                	sd	s0,32(sp)
    80002254:	ec26                	sd	s1,24(sp)
    80002256:	e84a                	sd	s2,16(sp)
    80002258:	e44e                	sd	s3,8(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000225e:	00011497          	auipc	s1,0x11
    80002262:	aa248493          	addi	s1,s1,-1374 # 80012d00 <proc>
    80002266:	00016997          	auipc	s3,0x16
    8000226a:	49a98993          	addi	s3,s3,1178 # 80018700 <tickslock>
    acquire(&p->lock);
    8000226e:	8526                	mv	a0,s1
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	87a080e7          	jalr	-1926(ra) # 80000aea <acquire>
    if(p->pid == pid){
    80002278:	5c9c                	lw	a5,56(s1)
    8000227a:	01278d63          	beq	a5,s2,80002294 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	8d2080e7          	jalr	-1838(ra) # 80000b52 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002288:	16848493          	addi	s1,s1,360
    8000228c:	ff3491e3          	bne	s1,s3,8000226e <kill+0x20>
  }
  return -1;
    80002290:	557d                	li	a0,-1
    80002292:	a821                	j	800022aa <kill+0x5c>
      p->killed = 1;
    80002294:	4785                	li	a5,1
    80002296:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002298:	4c98                	lw	a4,24(s1)
    8000229a:	00f70f63          	beq	a4,a5,800022b8 <kill+0x6a>
      release(&p->lock);
    8000229e:	8526                	mv	a0,s1
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	8b2080e7          	jalr	-1870(ra) # 80000b52 <release>
      return 0;
    800022a8:	4501                	li	a0,0
}
    800022aa:	70a2                	ld	ra,40(sp)
    800022ac:	7402                	ld	s0,32(sp)
    800022ae:	64e2                	ld	s1,24(sp)
    800022b0:	6942                	ld	s2,16(sp)
    800022b2:	69a2                	ld	s3,8(sp)
    800022b4:	6145                	addi	sp,sp,48
    800022b6:	8082                	ret
        p->state = RUNNABLE;
    800022b8:	4789                	li	a5,2
    800022ba:	cc9c                	sw	a5,24(s1)
    800022bc:	b7cd                	j	8000229e <kill+0x50>

00000000800022be <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800022be:	7179                	addi	sp,sp,-48
    800022c0:	f406                	sd	ra,40(sp)
    800022c2:	f022                	sd	s0,32(sp)
    800022c4:	ec26                	sd	s1,24(sp)
    800022c6:	e84a                	sd	s2,16(sp)
    800022c8:	e44e                	sd	s3,8(sp)
    800022ca:	e052                	sd	s4,0(sp)
    800022cc:	1800                	addi	s0,sp,48
    800022ce:	84aa                	mv	s1,a0
    800022d0:	892e                	mv	s2,a1
    800022d2:	89b2                	mv	s3,a2
    800022d4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	576080e7          	jalr	1398(ra) # 8000184c <myproc>
  if(user_dst){
    800022de:	c08d                	beqz	s1,80002300 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800022e0:	86d2                	mv	a3,s4
    800022e2:	864e                	mv	a2,s3
    800022e4:	85ca                	mv	a1,s2
    800022e6:	6928                	ld	a0,80(a0)
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	28a080e7          	jalr	650(ra) # 80001572 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022f0:	70a2                	ld	ra,40(sp)
    800022f2:	7402                	ld	s0,32(sp)
    800022f4:	64e2                	ld	s1,24(sp)
    800022f6:	6942                	ld	s2,16(sp)
    800022f8:	69a2                	ld	s3,8(sp)
    800022fa:	6a02                	ld	s4,0(sp)
    800022fc:	6145                	addi	sp,sp,48
    800022fe:	8082                	ret
    memmove((char *)dst, src, len);
    80002300:	000a061b          	sext.w	a2,s4
    80002304:	85ce                	mv	a1,s3
    80002306:	854a                	mv	a0,s2
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	906080e7          	jalr	-1786(ra) # 80000c0e <memmove>
    return 0;
    80002310:	8526                	mv	a0,s1
    80002312:	bff9                	j	800022f0 <either_copyout+0x32>

0000000080002314 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002314:	7179                	addi	sp,sp,-48
    80002316:	f406                	sd	ra,40(sp)
    80002318:	f022                	sd	s0,32(sp)
    8000231a:	ec26                	sd	s1,24(sp)
    8000231c:	e84a                	sd	s2,16(sp)
    8000231e:	e44e                	sd	s3,8(sp)
    80002320:	e052                	sd	s4,0(sp)
    80002322:	1800                	addi	s0,sp,48
    80002324:	892a                	mv	s2,a0
    80002326:	84ae                	mv	s1,a1
    80002328:	89b2                	mv	s3,a2
    8000232a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	520080e7          	jalr	1312(ra) # 8000184c <myproc>
  if(user_src){
    80002334:	c08d                	beqz	s1,80002356 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002336:	86d2                	mv	a3,s4
    80002338:	864e                	mv	a2,s3
    8000233a:	85ca                	mv	a1,s2
    8000233c:	6928                	ld	a0,80(a0)
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	2c6080e7          	jalr	710(ra) # 80001604 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002346:	70a2                	ld	ra,40(sp)
    80002348:	7402                	ld	s0,32(sp)
    8000234a:	64e2                	ld	s1,24(sp)
    8000234c:	6942                	ld	s2,16(sp)
    8000234e:	69a2                	ld	s3,8(sp)
    80002350:	6a02                	ld	s4,0(sp)
    80002352:	6145                	addi	sp,sp,48
    80002354:	8082                	ret
    memmove(dst, (char*)src, len);
    80002356:	000a061b          	sext.w	a2,s4
    8000235a:	85ce                	mv	a1,s3
    8000235c:	854a                	mv	a0,s2
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	8b0080e7          	jalr	-1872(ra) # 80000c0e <memmove>
    return 0;
    80002366:	8526                	mv	a0,s1
    80002368:	bff9                	j	80002346 <either_copyin+0x32>

000000008000236a <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000236a:	715d                	addi	sp,sp,-80
    8000236c:	e486                	sd	ra,72(sp)
    8000236e:	e0a2                	sd	s0,64(sp)
    80002370:	fc26                	sd	s1,56(sp)
    80002372:	f84a                	sd	s2,48(sp)
    80002374:	f44e                	sd	s3,40(sp)
    80002376:	f052                	sd	s4,32(sp)
    80002378:	ec56                	sd	s5,24(sp)
    8000237a:	e85a                	sd	s6,16(sp)
    8000237c:	e45e                	sd	s7,8(sp)
    8000237e:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002380:	00006517          	auipc	a0,0x6
    80002384:	e3050513          	addi	a0,a0,-464 # 800081b0 <userret+0x120>
    80002388:	ffffe097          	auipc	ra,0xffffe
    8000238c:	210080e7          	jalr	528(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002390:	00011497          	auipc	s1,0x11
    80002394:	ac848493          	addi	s1,s1,-1336 # 80012e58 <proc+0x158>
    80002398:	00016917          	auipc	s2,0x16
    8000239c:	4c090913          	addi	s2,s2,1216 # 80018858 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023a0:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800023a2:	00006997          	auipc	s3,0x6
    800023a6:	fbe98993          	addi	s3,s3,-66 # 80008360 <userret+0x2d0>
    printf("%d %s %s", p->pid, state, p->name);
    800023aa:	00006a97          	auipc	s5,0x6
    800023ae:	fbea8a93          	addi	s5,s5,-66 # 80008368 <userret+0x2d8>
    printf("\n");
    800023b2:	00006a17          	auipc	s4,0x6
    800023b6:	dfea0a13          	addi	s4,s4,-514 # 800081b0 <userret+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ba:	00006b97          	auipc	s7,0x6
    800023be:	62eb8b93          	addi	s7,s7,1582 # 800089e8 <states.1783>
    800023c2:	a00d                	j	800023e4 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800023c4:	ee06a583          	lw	a1,-288(a3)
    800023c8:	8556                	mv	a0,s5
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	1ce080e7          	jalr	462(ra) # 80000598 <printf>
    printf("\n");
    800023d2:	8552                	mv	a0,s4
    800023d4:	ffffe097          	auipc	ra,0xffffe
    800023d8:	1c4080e7          	jalr	452(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800023dc:	16848493          	addi	s1,s1,360
    800023e0:	03248163          	beq	s1,s2,80002402 <procdump+0x98>
    if(p->state == UNUSED)
    800023e4:	86a6                	mv	a3,s1
    800023e6:	ec04a783          	lw	a5,-320(s1)
    800023ea:	dbed                	beqz	a5,800023dc <procdump+0x72>
      state = "???";
    800023ec:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023ee:	fcfb6be3          	bltu	s6,a5,800023c4 <procdump+0x5a>
    800023f2:	1782                	slli	a5,a5,0x20
    800023f4:	9381                	srli	a5,a5,0x20
    800023f6:	078e                	slli	a5,a5,0x3
    800023f8:	97de                	add	a5,a5,s7
    800023fa:	6390                	ld	a2,0(a5)
    800023fc:	f661                	bnez	a2,800023c4 <procdump+0x5a>
      state = "???";
    800023fe:	864e                	mv	a2,s3
    80002400:	b7d1                	j	800023c4 <procdump+0x5a>
  }
}
    80002402:	60a6                	ld	ra,72(sp)
    80002404:	6406                	ld	s0,64(sp)
    80002406:	74e2                	ld	s1,56(sp)
    80002408:	7942                	ld	s2,48(sp)
    8000240a:	79a2                	ld	s3,40(sp)
    8000240c:	7a02                	ld	s4,32(sp)
    8000240e:	6ae2                	ld	s5,24(sp)
    80002410:	6b42                	ld	s6,16(sp)
    80002412:	6ba2                	ld	s7,8(sp)
    80002414:	6161                	addi	sp,sp,80
    80002416:	8082                	ret

0000000080002418 <swtch>:
    80002418:	00153023          	sd	ra,0(a0)
    8000241c:	00253423          	sd	sp,8(a0)
    80002420:	e900                	sd	s0,16(a0)
    80002422:	ed04                	sd	s1,24(a0)
    80002424:	03253023          	sd	s2,32(a0)
    80002428:	03353423          	sd	s3,40(a0)
    8000242c:	03453823          	sd	s4,48(a0)
    80002430:	03553c23          	sd	s5,56(a0)
    80002434:	05653023          	sd	s6,64(a0)
    80002438:	05753423          	sd	s7,72(a0)
    8000243c:	05853823          	sd	s8,80(a0)
    80002440:	05953c23          	sd	s9,88(a0)
    80002444:	07a53023          	sd	s10,96(a0)
    80002448:	07b53423          	sd	s11,104(a0)
    8000244c:	0005b083          	ld	ra,0(a1)
    80002450:	0085b103          	ld	sp,8(a1)
    80002454:	6980                	ld	s0,16(a1)
    80002456:	6d84                	ld	s1,24(a1)
    80002458:	0205b903          	ld	s2,32(a1)
    8000245c:	0285b983          	ld	s3,40(a1)
    80002460:	0305ba03          	ld	s4,48(a1)
    80002464:	0385ba83          	ld	s5,56(a1)
    80002468:	0405bb03          	ld	s6,64(a1)
    8000246c:	0485bb83          	ld	s7,72(a1)
    80002470:	0505bc03          	ld	s8,80(a1)
    80002474:	0585bc83          	ld	s9,88(a1)
    80002478:	0605bd03          	ld	s10,96(a1)
    8000247c:	0685bd83          	ld	s11,104(a1)
    80002480:	8082                	ret

0000000080002482 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002482:	1141                	addi	sp,sp,-16
    80002484:	e406                	sd	ra,8(sp)
    80002486:	e022                	sd	s0,0(sp)
    80002488:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000248a:	00006597          	auipc	a1,0x6
    8000248e:	f1658593          	addi	a1,a1,-234 # 800083a0 <userret+0x310>
    80002492:	00016517          	auipc	a0,0x16
    80002496:	26e50513          	addi	a0,a0,622 # 80018700 <tickslock>
    8000249a:	ffffe097          	auipc	ra,0xffffe
    8000249e:	53e080e7          	jalr	1342(ra) # 800009d8 <initlock>
}
    800024a2:	60a2                	ld	ra,8(sp)
    800024a4:	6402                	ld	s0,0(sp)
    800024a6:	0141                	addi	sp,sp,16
    800024a8:	8082                	ret

00000000800024aa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800024aa:	1141                	addi	sp,sp,-16
    800024ac:	e422                	sd	s0,8(sp)
    800024ae:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024b0:	00003797          	auipc	a5,0x3
    800024b4:	73078793          	addi	a5,a5,1840 # 80005be0 <kernelvec>
    800024b8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024bc:	6422                	ld	s0,8(sp)
    800024be:	0141                	addi	sp,sp,16
    800024c0:	8082                	ret

00000000800024c2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800024c2:	1141                	addi	sp,sp,-16
    800024c4:	e406                	sd	ra,8(sp)
    800024c6:	e022                	sd	s0,0(sp)
    800024c8:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	382080e7          	jalr	898(ra) # 8000184c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024d6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024d8:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send interrupts and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800024dc:	00006617          	auipc	a2,0x6
    800024e0:	b2460613          	addi	a2,a2,-1244 # 80008000 <trampoline>
    800024e4:	00006697          	auipc	a3,0x6
    800024e8:	b1c68693          	addi	a3,a3,-1252 # 80008000 <trampoline>
    800024ec:	8e91                	sub	a3,a3,a2
    800024ee:	040007b7          	lui	a5,0x4000
    800024f2:	17fd                	addi	a5,a5,-1
    800024f4:	07b2                	slli	a5,a5,0xc
    800024f6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024f8:	10569073          	csrw	stvec,a3

  // set up values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800024fc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024fe:	180026f3          	csrr	a3,satp
    80002502:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002504:	6d38                	ld	a4,88(a0)
    80002506:	6134                	ld	a3,64(a0)
    80002508:	6585                	lui	a1,0x1
    8000250a:	96ae                	add	a3,a3,a1
    8000250c:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    8000250e:	6d38                	ld	a4,88(a0)
    80002510:	00000697          	auipc	a3,0x0
    80002514:	12868693          	addi	a3,a3,296 # 80002638 <usertrap>
    80002518:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    8000251a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000251c:	8692                	mv	a3,tp
    8000251e:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002520:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002524:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002528:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000252c:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    80002530:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002532:	6f18                	ld	a4,24(a4)
    80002534:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002538:	692c                	ld	a1,80(a0)
    8000253a:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000253c:	00006717          	auipc	a4,0x6
    80002540:	b5470713          	addi	a4,a4,-1196 # 80008090 <userret>
    80002544:	8f11                	sub	a4,a4,a2
    80002546:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002548:	577d                	li	a4,-1
    8000254a:	177e                	slli	a4,a4,0x3f
    8000254c:	8dd9                	or	a1,a1,a4
    8000254e:	02000537          	lui	a0,0x2000
    80002552:	157d                	addi	a0,a0,-1
    80002554:	0536                	slli	a0,a0,0xd
    80002556:	9782                	jalr	a5
}
    80002558:	60a2                	ld	ra,8(sp)
    8000255a:	6402                	ld	s0,0(sp)
    8000255c:	0141                	addi	sp,sp,16
    8000255e:	8082                	ret

0000000080002560 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002560:	1101                	addi	sp,sp,-32
    80002562:	ec06                	sd	ra,24(sp)
    80002564:	e822                	sd	s0,16(sp)
    80002566:	e426                	sd	s1,8(sp)
    80002568:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000256a:	00016497          	auipc	s1,0x16
    8000256e:	19648493          	addi	s1,s1,406 # 80018700 <tickslock>
    80002572:	8526                	mv	a0,s1
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	576080e7          	jalr	1398(ra) # 80000aea <acquire>
  ticks++;
    8000257c:	00027517          	auipc	a0,0x27
    80002580:	ac450513          	addi	a0,a0,-1340 # 80029040 <ticks>
    80002584:	411c                	lw	a5,0(a0)
    80002586:	2785                	addiw	a5,a5,1
    80002588:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000258a:	00000097          	auipc	ra,0x0
    8000258e:	c5a080e7          	jalr	-934(ra) # 800021e4 <wakeup>
  release(&tickslock);
    80002592:	8526                	mv	a0,s1
    80002594:	ffffe097          	auipc	ra,0xffffe
    80002598:	5be080e7          	jalr	1470(ra) # 80000b52 <release>
}
    8000259c:	60e2                	ld	ra,24(sp)
    8000259e:	6442                	ld	s0,16(sp)
    800025a0:	64a2                	ld	s1,8(sp)
    800025a2:	6105                	addi	sp,sp,32
    800025a4:	8082                	ret

00000000800025a6 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800025a6:	1101                	addi	sp,sp,-32
    800025a8:	ec06                	sd	ra,24(sp)
    800025aa:	e822                	sd	s0,16(sp)
    800025ac:	e426                	sd	s1,8(sp)
    800025ae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025b0:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800025b4:	00074d63          	bltz	a4,800025ce <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    800025b8:	57fd                	li	a5,-1
    800025ba:	17fe                	slli	a5,a5,0x3f
    800025bc:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800025be:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800025c0:	04f70b63          	beq	a4,a5,80002616 <devintr+0x70>
  }
}
    800025c4:	60e2                	ld	ra,24(sp)
    800025c6:	6442                	ld	s0,16(sp)
    800025c8:	64a2                	ld	s1,8(sp)
    800025ca:	6105                	addi	sp,sp,32
    800025cc:	8082                	ret
     (scause & 0xff) == 9){
    800025ce:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800025d2:	46a5                	li	a3,9
    800025d4:	fed792e3          	bne	a5,a3,800025b8 <devintr+0x12>
    int irq = plic_claim();
    800025d8:	00003097          	auipc	ra,0x3
    800025dc:	722080e7          	jalr	1826(ra) # 80005cfa <plic_claim>
    800025e0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025e2:	47a9                	li	a5,10
    800025e4:	00f50e63          	beq	a0,a5,80002600 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800025e8:	fff5079b          	addiw	a5,a0,-1
    800025ec:	4705                	li	a4,1
    800025ee:	00f77e63          	bgeu	a4,a5,8000260a <devintr+0x64>
    plic_complete(irq);
    800025f2:	8526                	mv	a0,s1
    800025f4:	00003097          	auipc	ra,0x3
    800025f8:	72a080e7          	jalr	1834(ra) # 80005d1e <plic_complete>
    return 1;
    800025fc:	4505                	li	a0,1
    800025fe:	b7d9                	j	800025c4 <devintr+0x1e>
      uartintr();
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	238080e7          	jalr	568(ra) # 80000838 <uartintr>
    80002608:	b7ed                	j	800025f2 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    8000260a:	853e                	mv	a0,a5
    8000260c:	00004097          	auipc	ra,0x4
    80002610:	ce2080e7          	jalr	-798(ra) # 800062ee <virtio_disk_intr>
    80002614:	bff9                	j	800025f2 <devintr+0x4c>
    if(cpuid() == 0){
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	20a080e7          	jalr	522(ra) # 80001820 <cpuid>
    8000261e:	c901                	beqz	a0,8000262e <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002620:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002624:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002626:	14479073          	csrw	sip,a5
    return 2;
    8000262a:	4509                	li	a0,2
    8000262c:	bf61                	j	800025c4 <devintr+0x1e>
      clockintr();
    8000262e:	00000097          	auipc	ra,0x0
    80002632:	f32080e7          	jalr	-206(ra) # 80002560 <clockintr>
    80002636:	b7ed                	j	80002620 <devintr+0x7a>

0000000080002638 <usertrap>:
{
    80002638:	1101                	addi	sp,sp,-32
    8000263a:	ec06                	sd	ra,24(sp)
    8000263c:	e822                	sd	s0,16(sp)
    8000263e:	e426                	sd	s1,8(sp)
    80002640:	e04a                	sd	s2,0(sp)
    80002642:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002644:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002648:	1007f793          	andi	a5,a5,256
    8000264c:	e7bd                	bnez	a5,800026ba <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000264e:	00003797          	auipc	a5,0x3
    80002652:	59278793          	addi	a5,a5,1426 # 80005be0 <kernelvec>
    80002656:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000265a:	fffff097          	auipc	ra,0xfffff
    8000265e:	1f2080e7          	jalr	498(ra) # 8000184c <myproc>
    80002662:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002664:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002666:	14102773          	csrr	a4,sepc
    8000266a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000266c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002670:	47a1                	li	a5,8
    80002672:	06f71263          	bne	a4,a5,800026d6 <usertrap+0x9e>
    if(p->killed)
    80002676:	591c                	lw	a5,48(a0)
    80002678:	eba9                	bnez	a5,800026ca <usertrap+0x92>
    p->tf->epc += 4;
    8000267a:	6cb8                	ld	a4,88(s1)
    8000267c:	6f1c                	ld	a5,24(a4)
    8000267e:	0791                	addi	a5,a5,4
    80002680:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002682:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002686:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000268a:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000268e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002692:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002696:	10079073          	csrw	sstatus,a5
    syscall();
    8000269a:	00000097          	auipc	ra,0x0
    8000269e:	2e0080e7          	jalr	736(ra) # 8000297a <syscall>
  if(p->killed)
    800026a2:	589c                	lw	a5,48(s1)
    800026a4:	ebc1                	bnez	a5,80002734 <usertrap+0xfc>
  usertrapret();
    800026a6:	00000097          	auipc	ra,0x0
    800026aa:	e1c080e7          	jalr	-484(ra) # 800024c2 <usertrapret>
}
    800026ae:	60e2                	ld	ra,24(sp)
    800026b0:	6442                	ld	s0,16(sp)
    800026b2:	64a2                	ld	s1,8(sp)
    800026b4:	6902                	ld	s2,0(sp)
    800026b6:	6105                	addi	sp,sp,32
    800026b8:	8082                	ret
    panic("usertrap: not from user mode");
    800026ba:	00006517          	auipc	a0,0x6
    800026be:	cee50513          	addi	a0,a0,-786 # 800083a8 <userret+0x318>
    800026c2:	ffffe097          	auipc	ra,0xffffe
    800026c6:	e8c080e7          	jalr	-372(ra) # 8000054e <panic>
      exit(-1);
    800026ca:	557d                	li	a0,-1
    800026cc:	00000097          	auipc	ra,0x0
    800026d0:	870080e7          	jalr	-1936(ra) # 80001f3c <exit>
    800026d4:	b75d                	j	8000267a <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800026d6:	00000097          	auipc	ra,0x0
    800026da:	ed0080e7          	jalr	-304(ra) # 800025a6 <devintr>
    800026de:	892a                	mv	s2,a0
    800026e0:	c501                	beqz	a0,800026e8 <usertrap+0xb0>
  if(p->killed)
    800026e2:	589c                	lw	a5,48(s1)
    800026e4:	c3a1                	beqz	a5,80002724 <usertrap+0xec>
    800026e6:	a815                	j	8000271a <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026e8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800026ec:	5c90                	lw	a2,56(s1)
    800026ee:	00006517          	auipc	a0,0x6
    800026f2:	cda50513          	addi	a0,a0,-806 # 800083c8 <userret+0x338>
    800026f6:	ffffe097          	auipc	ra,0xffffe
    800026fa:	ea2080e7          	jalr	-350(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026fe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002702:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002706:	00006517          	auipc	a0,0x6
    8000270a:	cf250513          	addi	a0,a0,-782 # 800083f8 <userret+0x368>
    8000270e:	ffffe097          	auipc	ra,0xffffe
    80002712:	e8a080e7          	jalr	-374(ra) # 80000598 <printf>
    p->killed = 1;
    80002716:	4785                	li	a5,1
    80002718:	d89c                	sw	a5,48(s1)
    exit(-1);
    8000271a:	557d                	li	a0,-1
    8000271c:	00000097          	auipc	ra,0x0
    80002720:	820080e7          	jalr	-2016(ra) # 80001f3c <exit>
  if(which_dev == 2)
    80002724:	4789                	li	a5,2
    80002726:	f8f910e3          	bne	s2,a5,800026a6 <usertrap+0x6e>
    yield();
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	8f8080e7          	jalr	-1800(ra) # 80002022 <yield>
    80002732:	bf95                	j	800026a6 <usertrap+0x6e>
  int which_dev = 0;
    80002734:	4901                	li	s2,0
    80002736:	b7d5                	j	8000271a <usertrap+0xe2>

0000000080002738 <kerneltrap>:
{
    80002738:	7179                	addi	sp,sp,-48
    8000273a:	f406                	sd	ra,40(sp)
    8000273c:	f022                	sd	s0,32(sp)
    8000273e:	ec26                	sd	s1,24(sp)
    80002740:	e84a                	sd	s2,16(sp)
    80002742:	e44e                	sd	s3,8(sp)
    80002744:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002746:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000274a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000274e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002752:	1004f793          	andi	a5,s1,256
    80002756:	cb85                	beqz	a5,80002786 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002758:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000275c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000275e:	ef85                	bnez	a5,80002796 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002760:	00000097          	auipc	ra,0x0
    80002764:	e46080e7          	jalr	-442(ra) # 800025a6 <devintr>
    80002768:	cd1d                	beqz	a0,800027a6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000276a:	4789                	li	a5,2
    8000276c:	06f50a63          	beq	a0,a5,800027e0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002770:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002774:	10049073          	csrw	sstatus,s1
}
    80002778:	70a2                	ld	ra,40(sp)
    8000277a:	7402                	ld	s0,32(sp)
    8000277c:	64e2                	ld	s1,24(sp)
    8000277e:	6942                	ld	s2,16(sp)
    80002780:	69a2                	ld	s3,8(sp)
    80002782:	6145                	addi	sp,sp,48
    80002784:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002786:	00006517          	auipc	a0,0x6
    8000278a:	c9250513          	addi	a0,a0,-878 # 80008418 <userret+0x388>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	dc0080e7          	jalr	-576(ra) # 8000054e <panic>
    panic("kerneltrap: interrupts enabled");
    80002796:	00006517          	auipc	a0,0x6
    8000279a:	caa50513          	addi	a0,a0,-854 # 80008440 <userret+0x3b0>
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	db0080e7          	jalr	-592(ra) # 8000054e <panic>
    printf("scause %p\n", scause);
    800027a6:	85ce                	mv	a1,s3
    800027a8:	00006517          	auipc	a0,0x6
    800027ac:	cb850513          	addi	a0,a0,-840 # 80008460 <userret+0x3d0>
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	de8080e7          	jalr	-536(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027b8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800027bc:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800027c0:	00006517          	auipc	a0,0x6
    800027c4:	cb050513          	addi	a0,a0,-848 # 80008470 <userret+0x3e0>
    800027c8:	ffffe097          	auipc	ra,0xffffe
    800027cc:	dd0080e7          	jalr	-560(ra) # 80000598 <printf>
    panic("kerneltrap");
    800027d0:	00006517          	auipc	a0,0x6
    800027d4:	cb850513          	addi	a0,a0,-840 # 80008488 <userret+0x3f8>
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	d76080e7          	jalr	-650(ra) # 8000054e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800027e0:	fffff097          	auipc	ra,0xfffff
    800027e4:	06c080e7          	jalr	108(ra) # 8000184c <myproc>
    800027e8:	d541                	beqz	a0,80002770 <kerneltrap+0x38>
    800027ea:	fffff097          	auipc	ra,0xfffff
    800027ee:	062080e7          	jalr	98(ra) # 8000184c <myproc>
    800027f2:	4d18                	lw	a4,24(a0)
    800027f4:	478d                	li	a5,3
    800027f6:	f6f71de3          	bne	a4,a5,80002770 <kerneltrap+0x38>
    yield();
    800027fa:	00000097          	auipc	ra,0x0
    800027fe:	828080e7          	jalr	-2008(ra) # 80002022 <yield>
    80002802:	b7bd                	j	80002770 <kerneltrap+0x38>

0000000080002804 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002804:	1101                	addi	sp,sp,-32
    80002806:	ec06                	sd	ra,24(sp)
    80002808:	e822                	sd	s0,16(sp)
    8000280a:	e426                	sd	s1,8(sp)
    8000280c:	1000                	addi	s0,sp,32
    8000280e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002810:	fffff097          	auipc	ra,0xfffff
    80002814:	03c080e7          	jalr	60(ra) # 8000184c <myproc>
  switch (n) {
    80002818:	4795                	li	a5,5
    8000281a:	0497e163          	bltu	a5,s1,8000285c <argraw+0x58>
    8000281e:	048a                	slli	s1,s1,0x2
    80002820:	00006717          	auipc	a4,0x6
    80002824:	1f070713          	addi	a4,a4,496 # 80008a10 <states.1783+0x28>
    80002828:	94ba                	add	s1,s1,a4
    8000282a:	409c                	lw	a5,0(s1)
    8000282c:	97ba                	add	a5,a5,a4
    8000282e:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002830:	6d3c                	ld	a5,88(a0)
    80002832:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002834:	60e2                	ld	ra,24(sp)
    80002836:	6442                	ld	s0,16(sp)
    80002838:	64a2                	ld	s1,8(sp)
    8000283a:	6105                	addi	sp,sp,32
    8000283c:	8082                	ret
    return p->tf->a1;
    8000283e:	6d3c                	ld	a5,88(a0)
    80002840:	7fa8                	ld	a0,120(a5)
    80002842:	bfcd                	j	80002834 <argraw+0x30>
    return p->tf->a2;
    80002844:	6d3c                	ld	a5,88(a0)
    80002846:	63c8                	ld	a0,128(a5)
    80002848:	b7f5                	j	80002834 <argraw+0x30>
    return p->tf->a3;
    8000284a:	6d3c                	ld	a5,88(a0)
    8000284c:	67c8                	ld	a0,136(a5)
    8000284e:	b7dd                	j	80002834 <argraw+0x30>
    return p->tf->a4;
    80002850:	6d3c                	ld	a5,88(a0)
    80002852:	6bc8                	ld	a0,144(a5)
    80002854:	b7c5                	j	80002834 <argraw+0x30>
    return p->tf->a5;
    80002856:	6d3c                	ld	a5,88(a0)
    80002858:	6fc8                	ld	a0,152(a5)
    8000285a:	bfe9                	j	80002834 <argraw+0x30>
  panic("argraw");
    8000285c:	00006517          	auipc	a0,0x6
    80002860:	c3c50513          	addi	a0,a0,-964 # 80008498 <userret+0x408>
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	cea080e7          	jalr	-790(ra) # 8000054e <panic>

000000008000286c <fetchaddr>:
{
    8000286c:	1101                	addi	sp,sp,-32
    8000286e:	ec06                	sd	ra,24(sp)
    80002870:	e822                	sd	s0,16(sp)
    80002872:	e426                	sd	s1,8(sp)
    80002874:	e04a                	sd	s2,0(sp)
    80002876:	1000                	addi	s0,sp,32
    80002878:	84aa                	mv	s1,a0
    8000287a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000287c:	fffff097          	auipc	ra,0xfffff
    80002880:	fd0080e7          	jalr	-48(ra) # 8000184c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002884:	653c                	ld	a5,72(a0)
    80002886:	02f4f863          	bgeu	s1,a5,800028b6 <fetchaddr+0x4a>
    8000288a:	00848713          	addi	a4,s1,8
    8000288e:	02e7e663          	bltu	a5,a4,800028ba <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002892:	46a1                	li	a3,8
    80002894:	8626                	mv	a2,s1
    80002896:	85ca                	mv	a1,s2
    80002898:	6928                	ld	a0,80(a0)
    8000289a:	fffff097          	auipc	ra,0xfffff
    8000289e:	d6a080e7          	jalr	-662(ra) # 80001604 <copyin>
    800028a2:	00a03533          	snez	a0,a0
    800028a6:	40a00533          	neg	a0,a0
}
    800028aa:	60e2                	ld	ra,24(sp)
    800028ac:	6442                	ld	s0,16(sp)
    800028ae:	64a2                	ld	s1,8(sp)
    800028b0:	6902                	ld	s2,0(sp)
    800028b2:	6105                	addi	sp,sp,32
    800028b4:	8082                	ret
    return -1;
    800028b6:	557d                	li	a0,-1
    800028b8:	bfcd                	j	800028aa <fetchaddr+0x3e>
    800028ba:	557d                	li	a0,-1
    800028bc:	b7fd                	j	800028aa <fetchaddr+0x3e>

00000000800028be <fetchstr>:
{
    800028be:	7179                	addi	sp,sp,-48
    800028c0:	f406                	sd	ra,40(sp)
    800028c2:	f022                	sd	s0,32(sp)
    800028c4:	ec26                	sd	s1,24(sp)
    800028c6:	e84a                	sd	s2,16(sp)
    800028c8:	e44e                	sd	s3,8(sp)
    800028ca:	1800                	addi	s0,sp,48
    800028cc:	892a                	mv	s2,a0
    800028ce:	84ae                	mv	s1,a1
    800028d0:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800028d2:	fffff097          	auipc	ra,0xfffff
    800028d6:	f7a080e7          	jalr	-134(ra) # 8000184c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800028da:	86ce                	mv	a3,s3
    800028dc:	864a                	mv	a2,s2
    800028de:	85a6                	mv	a1,s1
    800028e0:	6928                	ld	a0,80(a0)
    800028e2:	fffff097          	auipc	ra,0xfffff
    800028e6:	db4080e7          	jalr	-588(ra) # 80001696 <copyinstr>
  if(err < 0)
    800028ea:	00054763          	bltz	a0,800028f8 <fetchstr+0x3a>
  return strlen(buf);
    800028ee:	8526                	mv	a0,s1
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	446080e7          	jalr	1094(ra) # 80000d36 <strlen>
}
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6942                	ld	s2,16(sp)
    80002900:	69a2                	ld	s3,8(sp)
    80002902:	6145                	addi	sp,sp,48
    80002904:	8082                	ret

0000000080002906 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002906:	1101                	addi	sp,sp,-32
    80002908:	ec06                	sd	ra,24(sp)
    8000290a:	e822                	sd	s0,16(sp)
    8000290c:	e426                	sd	s1,8(sp)
    8000290e:	1000                	addi	s0,sp,32
    80002910:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002912:	00000097          	auipc	ra,0x0
    80002916:	ef2080e7          	jalr	-270(ra) # 80002804 <argraw>
    8000291a:	c088                	sw	a0,0(s1)
  return 0;
}
    8000291c:	4501                	li	a0,0
    8000291e:	60e2                	ld	ra,24(sp)
    80002920:	6442                	ld	s0,16(sp)
    80002922:	64a2                	ld	s1,8(sp)
    80002924:	6105                	addi	sp,sp,32
    80002926:	8082                	ret

0000000080002928 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002928:	1101                	addi	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	1000                	addi	s0,sp,32
    80002932:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002934:	00000097          	auipc	ra,0x0
    80002938:	ed0080e7          	jalr	-304(ra) # 80002804 <argraw>
    8000293c:	e088                	sd	a0,0(s1)
  return 0;
}
    8000293e:	4501                	li	a0,0
    80002940:	60e2                	ld	ra,24(sp)
    80002942:	6442                	ld	s0,16(sp)
    80002944:	64a2                	ld	s1,8(sp)
    80002946:	6105                	addi	sp,sp,32
    80002948:	8082                	ret

000000008000294a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000294a:	1101                	addi	sp,sp,-32
    8000294c:	ec06                	sd	ra,24(sp)
    8000294e:	e822                	sd	s0,16(sp)
    80002950:	e426                	sd	s1,8(sp)
    80002952:	e04a                	sd	s2,0(sp)
    80002954:	1000                	addi	s0,sp,32
    80002956:	84ae                	mv	s1,a1
    80002958:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	eaa080e7          	jalr	-342(ra) # 80002804 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002962:	864a                	mv	a2,s2
    80002964:	85a6                	mv	a1,s1
    80002966:	00000097          	auipc	ra,0x0
    8000296a:	f58080e7          	jalr	-168(ra) # 800028be <fetchstr>
}
    8000296e:	60e2                	ld	ra,24(sp)
    80002970:	6442                	ld	s0,16(sp)
    80002972:	64a2                	ld	s1,8(sp)
    80002974:	6902                	ld	s2,0(sp)
    80002976:	6105                	addi	sp,sp,32
    80002978:	8082                	ret

000000008000297a <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    8000297a:	1101                	addi	sp,sp,-32
    8000297c:	ec06                	sd	ra,24(sp)
    8000297e:	e822                	sd	s0,16(sp)
    80002980:	e426                	sd	s1,8(sp)
    80002982:	e04a                	sd	s2,0(sp)
    80002984:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002986:	fffff097          	auipc	ra,0xfffff
    8000298a:	ec6080e7          	jalr	-314(ra) # 8000184c <myproc>
    8000298e:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002990:	05853903          	ld	s2,88(a0)
    80002994:	0a893783          	ld	a5,168(s2)
    80002998:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000299c:	37fd                	addiw	a5,a5,-1
    8000299e:	4759                	li	a4,22
    800029a0:	00f76f63          	bltu	a4,a5,800029be <syscall+0x44>
    800029a4:	00369713          	slli	a4,a3,0x3
    800029a8:	00006797          	auipc	a5,0x6
    800029ac:	08078793          	addi	a5,a5,128 # 80008a28 <syscalls>
    800029b0:	97ba                	add	a5,a5,a4
    800029b2:	639c                	ld	a5,0(a5)
    800029b4:	c789                	beqz	a5,800029be <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    800029b6:	9782                	jalr	a5
    800029b8:	06a93823          	sd	a0,112(s2)
    800029bc:	a839                	j	800029da <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800029be:	15848613          	addi	a2,s1,344
    800029c2:	5c8c                	lw	a1,56(s1)
    800029c4:	00006517          	auipc	a0,0x6
    800029c8:	adc50513          	addi	a0,a0,-1316 # 800084a0 <userret+0x410>
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	bcc080e7          	jalr	-1076(ra) # 80000598 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    800029d4:	6cbc                	ld	a5,88(s1)
    800029d6:	577d                	li	a4,-1
    800029d8:	fbb8                	sd	a4,112(a5)
  }
}
    800029da:	60e2                	ld	ra,24(sp)
    800029dc:	6442                	ld	s0,16(sp)
    800029de:	64a2                	ld	s1,8(sp)
    800029e0:	6902                	ld	s2,0(sp)
    800029e2:	6105                	addi	sp,sp,32
    800029e4:	8082                	ret

00000000800029e6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800029e6:	1101                	addi	sp,sp,-32
    800029e8:	ec06                	sd	ra,24(sp)
    800029ea:	e822                	sd	s0,16(sp)
    800029ec:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800029ee:	fec40593          	addi	a1,s0,-20
    800029f2:	4501                	li	a0,0
    800029f4:	00000097          	auipc	ra,0x0
    800029f8:	f12080e7          	jalr	-238(ra) # 80002906 <argint>
    return -1;
    800029fc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800029fe:	00054963          	bltz	a0,80002a10 <sys_exit+0x2a>
  exit(n);
    80002a02:	fec42503          	lw	a0,-20(s0)
    80002a06:	fffff097          	auipc	ra,0xfffff
    80002a0a:	536080e7          	jalr	1334(ra) # 80001f3c <exit>
  return 0;  // not reached
    80002a0e:	4781                	li	a5,0
}
    80002a10:	853e                	mv	a0,a5
    80002a12:	60e2                	ld	ra,24(sp)
    80002a14:	6442                	ld	s0,16(sp)
    80002a16:	6105                	addi	sp,sp,32
    80002a18:	8082                	ret

0000000080002a1a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002a1a:	1141                	addi	sp,sp,-16
    80002a1c:	e406                	sd	ra,8(sp)
    80002a1e:	e022                	sd	s0,0(sp)
    80002a20:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002a22:	fffff097          	auipc	ra,0xfffff
    80002a26:	e2a080e7          	jalr	-470(ra) # 8000184c <myproc>
}
    80002a2a:	5d08                	lw	a0,56(a0)
    80002a2c:	60a2                	ld	ra,8(sp)
    80002a2e:	6402                	ld	s0,0(sp)
    80002a30:	0141                	addi	sp,sp,16
    80002a32:	8082                	ret

0000000080002a34 <sys_fork>:

uint64
sys_fork(void)
{
    80002a34:	1141                	addi	sp,sp,-16
    80002a36:	e406                	sd	ra,8(sp)
    80002a38:	e022                	sd	s0,0(sp)
    80002a3a:	0800                	addi	s0,sp,16
  return fork();
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	17e080e7          	jalr	382(ra) # 80001bba <fork>
}
    80002a44:	60a2                	ld	ra,8(sp)
    80002a46:	6402                	ld	s0,0(sp)
    80002a48:	0141                	addi	sp,sp,16
    80002a4a:	8082                	ret

0000000080002a4c <sys_wait>:

uint64
sys_wait(void)
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002a54:	fe840593          	addi	a1,s0,-24
    80002a58:	4501                	li	a0,0
    80002a5a:	00000097          	auipc	ra,0x0
    80002a5e:	ece080e7          	jalr	-306(ra) # 80002928 <argaddr>
    80002a62:	87aa                	mv	a5,a0
    return -1;
    80002a64:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002a66:	0007c863          	bltz	a5,80002a76 <sys_wait+0x2a>
  return wait(p);
    80002a6a:	fe843503          	ld	a0,-24(s0)
    80002a6e:	fffff097          	auipc	ra,0xfffff
    80002a72:	66e080e7          	jalr	1646(ra) # 800020dc <wait>
}
    80002a76:	60e2                	ld	ra,24(sp)
    80002a78:	6442                	ld	s0,16(sp)
    80002a7a:	6105                	addi	sp,sp,32
    80002a7c:	8082                	ret

0000000080002a7e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002a7e:	7179                	addi	sp,sp,-48
    80002a80:	f406                	sd	ra,40(sp)
    80002a82:	f022                	sd	s0,32(sp)
    80002a84:	ec26                	sd	s1,24(sp)
    80002a86:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002a88:	fdc40593          	addi	a1,s0,-36
    80002a8c:	4501                	li	a0,0
    80002a8e:	00000097          	auipc	ra,0x0
    80002a92:	e78080e7          	jalr	-392(ra) # 80002906 <argint>
    80002a96:	87aa                	mv	a5,a0
    return -1;
    80002a98:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002a9a:	0207c063          	bltz	a5,80002aba <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002a9e:	fffff097          	auipc	ra,0xfffff
    80002aa2:	dae080e7          	jalr	-594(ra) # 8000184c <myproc>
    80002aa6:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002aa8:	fdc42503          	lw	a0,-36(s0)
    80002aac:	fffff097          	auipc	ra,0xfffff
    80002ab0:	096080e7          	jalr	150(ra) # 80001b42 <growproc>
    80002ab4:	00054863          	bltz	a0,80002ac4 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002ab8:	8526                	mv	a0,s1
}
    80002aba:	70a2                	ld	ra,40(sp)
    80002abc:	7402                	ld	s0,32(sp)
    80002abe:	64e2                	ld	s1,24(sp)
    80002ac0:	6145                	addi	sp,sp,48
    80002ac2:	8082                	ret
    return -1;
    80002ac4:	557d                	li	a0,-1
    80002ac6:	bfd5                	j	80002aba <sys_sbrk+0x3c>

0000000080002ac8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ac8:	7139                	addi	sp,sp,-64
    80002aca:	fc06                	sd	ra,56(sp)
    80002acc:	f822                	sd	s0,48(sp)
    80002ace:	f426                	sd	s1,40(sp)
    80002ad0:	f04a                	sd	s2,32(sp)
    80002ad2:	ec4e                	sd	s3,24(sp)
    80002ad4:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ad6:	fcc40593          	addi	a1,s0,-52
    80002ada:	4501                	li	a0,0
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	e2a080e7          	jalr	-470(ra) # 80002906 <argint>
    return -1;
    80002ae4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ae6:	06054563          	bltz	a0,80002b50 <sys_sleep+0x88>
  acquire(&tickslock);
    80002aea:	00016517          	auipc	a0,0x16
    80002aee:	c1650513          	addi	a0,a0,-1002 # 80018700 <tickslock>
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	ff8080e7          	jalr	-8(ra) # 80000aea <acquire>
  ticks0 = ticks;
    80002afa:	00026917          	auipc	s2,0x26
    80002afe:	54692903          	lw	s2,1350(s2) # 80029040 <ticks>
  while(ticks - ticks0 < n){
    80002b02:	fcc42783          	lw	a5,-52(s0)
    80002b06:	cf85                	beqz	a5,80002b3e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002b08:	00016997          	auipc	s3,0x16
    80002b0c:	bf898993          	addi	s3,s3,-1032 # 80018700 <tickslock>
    80002b10:	00026497          	auipc	s1,0x26
    80002b14:	53048493          	addi	s1,s1,1328 # 80029040 <ticks>
    if(myproc()->killed){
    80002b18:	fffff097          	auipc	ra,0xfffff
    80002b1c:	d34080e7          	jalr	-716(ra) # 8000184c <myproc>
    80002b20:	591c                	lw	a5,48(a0)
    80002b22:	ef9d                	bnez	a5,80002b60 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002b24:	85ce                	mv	a1,s3
    80002b26:	8526                	mv	a0,s1
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	536080e7          	jalr	1334(ra) # 8000205e <sleep>
  while(ticks - ticks0 < n){
    80002b30:	409c                	lw	a5,0(s1)
    80002b32:	412787bb          	subw	a5,a5,s2
    80002b36:	fcc42703          	lw	a4,-52(s0)
    80002b3a:	fce7efe3          	bltu	a5,a4,80002b18 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002b3e:	00016517          	auipc	a0,0x16
    80002b42:	bc250513          	addi	a0,a0,-1086 # 80018700 <tickslock>
    80002b46:	ffffe097          	auipc	ra,0xffffe
    80002b4a:	00c080e7          	jalr	12(ra) # 80000b52 <release>
  return 0;
    80002b4e:	4781                	li	a5,0
}
    80002b50:	853e                	mv	a0,a5
    80002b52:	70e2                	ld	ra,56(sp)
    80002b54:	7442                	ld	s0,48(sp)
    80002b56:	74a2                	ld	s1,40(sp)
    80002b58:	7902                	ld	s2,32(sp)
    80002b5a:	69e2                	ld	s3,24(sp)
    80002b5c:	6121                	addi	sp,sp,64
    80002b5e:	8082                	ret
      release(&tickslock);
    80002b60:	00016517          	auipc	a0,0x16
    80002b64:	ba050513          	addi	a0,a0,-1120 # 80018700 <tickslock>
    80002b68:	ffffe097          	auipc	ra,0xffffe
    80002b6c:	fea080e7          	jalr	-22(ra) # 80000b52 <release>
      return -1;
    80002b70:	57fd                	li	a5,-1
    80002b72:	bff9                	j	80002b50 <sys_sleep+0x88>

0000000080002b74 <sys_kill>:

uint64
sys_kill(void)
{
    80002b74:	1101                	addi	sp,sp,-32
    80002b76:	ec06                	sd	ra,24(sp)
    80002b78:	e822                	sd	s0,16(sp)
    80002b7a:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002b7c:	fec40593          	addi	a1,s0,-20
    80002b80:	4501                	li	a0,0
    80002b82:	00000097          	auipc	ra,0x0
    80002b86:	d84080e7          	jalr	-636(ra) # 80002906 <argint>
    80002b8a:	87aa                	mv	a5,a0
    return -1;
    80002b8c:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002b8e:	0007c863          	bltz	a5,80002b9e <sys_kill+0x2a>
  return kill(pid);
    80002b92:	fec42503          	lw	a0,-20(s0)
    80002b96:	fffff097          	auipc	ra,0xfffff
    80002b9a:	6b8080e7          	jalr	1720(ra) # 8000224e <kill>
}
    80002b9e:	60e2                	ld	ra,24(sp)
    80002ba0:	6442                	ld	s0,16(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret

0000000080002ba6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	e426                	sd	s1,8(sp)
    80002bae:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002bb0:	00016517          	auipc	a0,0x16
    80002bb4:	b5050513          	addi	a0,a0,-1200 # 80018700 <tickslock>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	f32080e7          	jalr	-206(ra) # 80000aea <acquire>
  xticks = ticks;
    80002bc0:	00026497          	auipc	s1,0x26
    80002bc4:	4804a483          	lw	s1,1152(s1) # 80029040 <ticks>
  release(&tickslock);
    80002bc8:	00016517          	auipc	a0,0x16
    80002bcc:	b3850513          	addi	a0,a0,-1224 # 80018700 <tickslock>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	f82080e7          	jalr	-126(ra) # 80000b52 <release>
  return xticks;
}
    80002bd8:	02049513          	slli	a0,s1,0x20
    80002bdc:	9101                	srli	a0,a0,0x20
    80002bde:	60e2                	ld	ra,24(sp)
    80002be0:	6442                	ld	s0,16(sp)
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	6105                	addi	sp,sp,32
    80002be6:	8082                	ret

0000000080002be8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002be8:	7179                	addi	sp,sp,-48
    80002bea:	f406                	sd	ra,40(sp)
    80002bec:	f022                	sd	s0,32(sp)
    80002bee:	ec26                	sd	s1,24(sp)
    80002bf0:	e84a                	sd	s2,16(sp)
    80002bf2:	e44e                	sd	s3,8(sp)
    80002bf4:	e052                	sd	s4,0(sp)
    80002bf6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002bf8:	00006597          	auipc	a1,0x6
    80002bfc:	8c858593          	addi	a1,a1,-1848 # 800084c0 <userret+0x430>
    80002c00:	00016517          	auipc	a0,0x16
    80002c04:	b1850513          	addi	a0,a0,-1256 # 80018718 <bcache>
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	dd0080e7          	jalr	-560(ra) # 800009d8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002c10:	0001e797          	auipc	a5,0x1e
    80002c14:	b0878793          	addi	a5,a5,-1272 # 80020718 <bcache+0x8000>
    80002c18:	0001e717          	auipc	a4,0x1e
    80002c1c:	e5870713          	addi	a4,a4,-424 # 80020a70 <bcache+0x8358>
    80002c20:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002c24:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c28:	00016497          	auipc	s1,0x16
    80002c2c:	b0848493          	addi	s1,s1,-1272 # 80018730 <bcache+0x18>
    b->next = bcache.head.next;
    80002c30:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002c32:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002c34:	00006a17          	auipc	s4,0x6
    80002c38:	894a0a13          	addi	s4,s4,-1900 # 800084c8 <userret+0x438>
    b->next = bcache.head.next;
    80002c3c:	3a893783          	ld	a5,936(s2)
    80002c40:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002c42:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002c46:	85d2                	mv	a1,s4
    80002c48:	01048513          	addi	a0,s1,16
    80002c4c:	00001097          	auipc	ra,0x1
    80002c50:	6f2080e7          	jalr	1778(ra) # 8000433e <initsleeplock>
    bcache.head.next->prev = b;
    80002c54:	3a893783          	ld	a5,936(s2)
    80002c58:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002c5a:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002c5e:	46048493          	addi	s1,s1,1120
    80002c62:	fd349de3          	bne	s1,s3,80002c3c <binit+0x54>
  }
}
    80002c66:	70a2                	ld	ra,40(sp)
    80002c68:	7402                	ld	s0,32(sp)
    80002c6a:	64e2                	ld	s1,24(sp)
    80002c6c:	6942                	ld	s2,16(sp)
    80002c6e:	69a2                	ld	s3,8(sp)
    80002c70:	6a02                	ld	s4,0(sp)
    80002c72:	6145                	addi	sp,sp,48
    80002c74:	8082                	ret

0000000080002c76 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002c76:	7179                	addi	sp,sp,-48
    80002c78:	f406                	sd	ra,40(sp)
    80002c7a:	f022                	sd	s0,32(sp)
    80002c7c:	ec26                	sd	s1,24(sp)
    80002c7e:	e84a                	sd	s2,16(sp)
    80002c80:	e44e                	sd	s3,8(sp)
    80002c82:	1800                	addi	s0,sp,48
    80002c84:	89aa                	mv	s3,a0
    80002c86:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002c88:	00016517          	auipc	a0,0x16
    80002c8c:	a9050513          	addi	a0,a0,-1392 # 80018718 <bcache>
    80002c90:	ffffe097          	auipc	ra,0xffffe
    80002c94:	e5a080e7          	jalr	-422(ra) # 80000aea <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c98:	0001e497          	auipc	s1,0x1e
    80002c9c:	e284b483          	ld	s1,-472(s1) # 80020ac0 <bcache+0x83a8>
    80002ca0:	0001e797          	auipc	a5,0x1e
    80002ca4:	dd078793          	addi	a5,a5,-560 # 80020a70 <bcache+0x8358>
    80002ca8:	02f48f63          	beq	s1,a5,80002ce6 <bread+0x70>
    80002cac:	873e                	mv	a4,a5
    80002cae:	a021                	j	80002cb6 <bread+0x40>
    80002cb0:	68a4                	ld	s1,80(s1)
    80002cb2:	02e48a63          	beq	s1,a4,80002ce6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002cb6:	449c                	lw	a5,8(s1)
    80002cb8:	ff379ce3          	bne	a5,s3,80002cb0 <bread+0x3a>
    80002cbc:	44dc                	lw	a5,12(s1)
    80002cbe:	ff2799e3          	bne	a5,s2,80002cb0 <bread+0x3a>
      b->refcnt++;
    80002cc2:	40bc                	lw	a5,64(s1)
    80002cc4:	2785                	addiw	a5,a5,1
    80002cc6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cc8:	00016517          	auipc	a0,0x16
    80002ccc:	a5050513          	addi	a0,a0,-1456 # 80018718 <bcache>
    80002cd0:	ffffe097          	auipc	ra,0xffffe
    80002cd4:	e82080e7          	jalr	-382(ra) # 80000b52 <release>
      acquiresleep(&b->lock);
    80002cd8:	01048513          	addi	a0,s1,16
    80002cdc:	00001097          	auipc	ra,0x1
    80002ce0:	69c080e7          	jalr	1692(ra) # 80004378 <acquiresleep>
      return b;
    80002ce4:	a8b9                	j	80002d42 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ce6:	0001e497          	auipc	s1,0x1e
    80002cea:	dd24b483          	ld	s1,-558(s1) # 80020ab8 <bcache+0x83a0>
    80002cee:	0001e797          	auipc	a5,0x1e
    80002cf2:	d8278793          	addi	a5,a5,-638 # 80020a70 <bcache+0x8358>
    80002cf6:	00f48863          	beq	s1,a5,80002d06 <bread+0x90>
    80002cfa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002cfc:	40bc                	lw	a5,64(s1)
    80002cfe:	cf81                	beqz	a5,80002d16 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d00:	64a4                	ld	s1,72(s1)
    80002d02:	fee49de3          	bne	s1,a4,80002cfc <bread+0x86>
  panic("bget: no buffers");
    80002d06:	00005517          	auipc	a0,0x5
    80002d0a:	7ca50513          	addi	a0,a0,1994 # 800084d0 <userret+0x440>
    80002d0e:	ffffe097          	auipc	ra,0xffffe
    80002d12:	840080e7          	jalr	-1984(ra) # 8000054e <panic>
      b->dev = dev;
    80002d16:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002d1a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002d1e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d22:	4785                	li	a5,1
    80002d24:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002d26:	00016517          	auipc	a0,0x16
    80002d2a:	9f250513          	addi	a0,a0,-1550 # 80018718 <bcache>
    80002d2e:	ffffe097          	auipc	ra,0xffffe
    80002d32:	e24080e7          	jalr	-476(ra) # 80000b52 <release>
      acquiresleep(&b->lock);
    80002d36:	01048513          	addi	a0,s1,16
    80002d3a:	00001097          	auipc	ra,0x1
    80002d3e:	63e080e7          	jalr	1598(ra) # 80004378 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002d42:	409c                	lw	a5,0(s1)
    80002d44:	cb89                	beqz	a5,80002d56 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002d46:	8526                	mv	a0,s1
    80002d48:	70a2                	ld	ra,40(sp)
    80002d4a:	7402                	ld	s0,32(sp)
    80002d4c:	64e2                	ld	s1,24(sp)
    80002d4e:	6942                	ld	s2,16(sp)
    80002d50:	69a2                	ld	s3,8(sp)
    80002d52:	6145                	addi	sp,sp,48
    80002d54:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002d56:	4601                	li	a2,0
    80002d58:	85a6                	mv	a1,s1
    80002d5a:	4488                	lw	a0,8(s1)
    80002d5c:	00003097          	auipc	ra,0x3
    80002d60:	270080e7          	jalr	624(ra) # 80005fcc <virtio_disk_rw>
    b->valid = 1;
    80002d64:	4785                	li	a5,1
    80002d66:	c09c                	sw	a5,0(s1)
  return b;
    80002d68:	bff9                	j	80002d46 <bread+0xd0>

0000000080002d6a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
    80002d74:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d76:	0541                	addi	a0,a0,16
    80002d78:	00001097          	auipc	ra,0x1
    80002d7c:	69a080e7          	jalr	1690(ra) # 80004412 <holdingsleep>
    80002d80:	cd09                	beqz	a0,80002d9a <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002d82:	4605                	li	a2,1
    80002d84:	85a6                	mv	a1,s1
    80002d86:	4488                	lw	a0,8(s1)
    80002d88:	00003097          	auipc	ra,0x3
    80002d8c:	244080e7          	jalr	580(ra) # 80005fcc <virtio_disk_rw>
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret
    panic("bwrite");
    80002d9a:	00005517          	auipc	a0,0x5
    80002d9e:	74e50513          	addi	a0,a0,1870 # 800084e8 <userret+0x458>
    80002da2:	ffffd097          	auipc	ra,0xffffd
    80002da6:	7ac080e7          	jalr	1964(ra) # 8000054e <panic>

0000000080002daa <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002daa:	1101                	addi	sp,sp,-32
    80002dac:	ec06                	sd	ra,24(sp)
    80002dae:	e822                	sd	s0,16(sp)
    80002db0:	e426                	sd	s1,8(sp)
    80002db2:	e04a                	sd	s2,0(sp)
    80002db4:	1000                	addi	s0,sp,32
    80002db6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002db8:	01050913          	addi	s2,a0,16
    80002dbc:	854a                	mv	a0,s2
    80002dbe:	00001097          	auipc	ra,0x1
    80002dc2:	654080e7          	jalr	1620(ra) # 80004412 <holdingsleep>
    80002dc6:	c92d                	beqz	a0,80002e38 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002dc8:	854a                	mv	a0,s2
    80002dca:	00001097          	auipc	ra,0x1
    80002dce:	604080e7          	jalr	1540(ra) # 800043ce <releasesleep>

  acquire(&bcache.lock);
    80002dd2:	00016517          	auipc	a0,0x16
    80002dd6:	94650513          	addi	a0,a0,-1722 # 80018718 <bcache>
    80002dda:	ffffe097          	auipc	ra,0xffffe
    80002dde:	d10080e7          	jalr	-752(ra) # 80000aea <acquire>
  b->refcnt--;
    80002de2:	40bc                	lw	a5,64(s1)
    80002de4:	37fd                	addiw	a5,a5,-1
    80002de6:	0007871b          	sext.w	a4,a5
    80002dea:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002dec:	eb05                	bnez	a4,80002e1c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002dee:	68bc                	ld	a5,80(s1)
    80002df0:	64b8                	ld	a4,72(s1)
    80002df2:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002df4:	64bc                	ld	a5,72(s1)
    80002df6:	68b8                	ld	a4,80(s1)
    80002df8:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002dfa:	0001e797          	auipc	a5,0x1e
    80002dfe:	91e78793          	addi	a5,a5,-1762 # 80020718 <bcache+0x8000>
    80002e02:	3a87b703          	ld	a4,936(a5)
    80002e06:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002e08:	0001e717          	auipc	a4,0x1e
    80002e0c:	c6870713          	addi	a4,a4,-920 # 80020a70 <bcache+0x8358>
    80002e10:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002e12:	3a87b703          	ld	a4,936(a5)
    80002e16:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002e18:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80002e1c:	00016517          	auipc	a0,0x16
    80002e20:	8fc50513          	addi	a0,a0,-1796 # 80018718 <bcache>
    80002e24:	ffffe097          	auipc	ra,0xffffe
    80002e28:	d2e080e7          	jalr	-722(ra) # 80000b52 <release>
}
    80002e2c:	60e2                	ld	ra,24(sp)
    80002e2e:	6442                	ld	s0,16(sp)
    80002e30:	64a2                	ld	s1,8(sp)
    80002e32:	6902                	ld	s2,0(sp)
    80002e34:	6105                	addi	sp,sp,32
    80002e36:	8082                	ret
    panic("brelse");
    80002e38:	00005517          	auipc	a0,0x5
    80002e3c:	6b850513          	addi	a0,a0,1720 # 800084f0 <userret+0x460>
    80002e40:	ffffd097          	auipc	ra,0xffffd
    80002e44:	70e080e7          	jalr	1806(ra) # 8000054e <panic>

0000000080002e48 <bpin>:

void
bpin(struct buf *b) {
    80002e48:	1101                	addi	sp,sp,-32
    80002e4a:	ec06                	sd	ra,24(sp)
    80002e4c:	e822                	sd	s0,16(sp)
    80002e4e:	e426                	sd	s1,8(sp)
    80002e50:	1000                	addi	s0,sp,32
    80002e52:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e54:	00016517          	auipc	a0,0x16
    80002e58:	8c450513          	addi	a0,a0,-1852 # 80018718 <bcache>
    80002e5c:	ffffe097          	auipc	ra,0xffffe
    80002e60:	c8e080e7          	jalr	-882(ra) # 80000aea <acquire>
  b->refcnt++;
    80002e64:	40bc                	lw	a5,64(s1)
    80002e66:	2785                	addiw	a5,a5,1
    80002e68:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e6a:	00016517          	auipc	a0,0x16
    80002e6e:	8ae50513          	addi	a0,a0,-1874 # 80018718 <bcache>
    80002e72:	ffffe097          	auipc	ra,0xffffe
    80002e76:	ce0080e7          	jalr	-800(ra) # 80000b52 <release>
}
    80002e7a:	60e2                	ld	ra,24(sp)
    80002e7c:	6442                	ld	s0,16(sp)
    80002e7e:	64a2                	ld	s1,8(sp)
    80002e80:	6105                	addi	sp,sp,32
    80002e82:	8082                	ret

0000000080002e84 <bunpin>:

void
bunpin(struct buf *b) {
    80002e84:	1101                	addi	sp,sp,-32
    80002e86:	ec06                	sd	ra,24(sp)
    80002e88:	e822                	sd	s0,16(sp)
    80002e8a:	e426                	sd	s1,8(sp)
    80002e8c:	1000                	addi	s0,sp,32
    80002e8e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002e90:	00016517          	auipc	a0,0x16
    80002e94:	88850513          	addi	a0,a0,-1912 # 80018718 <bcache>
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	c52080e7          	jalr	-942(ra) # 80000aea <acquire>
  b->refcnt--;
    80002ea0:	40bc                	lw	a5,64(s1)
    80002ea2:	37fd                	addiw	a5,a5,-1
    80002ea4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ea6:	00016517          	auipc	a0,0x16
    80002eaa:	87250513          	addi	a0,a0,-1934 # 80018718 <bcache>
    80002eae:	ffffe097          	auipc	ra,0xffffe
    80002eb2:	ca4080e7          	jalr	-860(ra) # 80000b52 <release>
}
    80002eb6:	60e2                	ld	ra,24(sp)
    80002eb8:	6442                	ld	s0,16(sp)
    80002eba:	64a2                	ld	s1,8(sp)
    80002ebc:	6105                	addi	sp,sp,32
    80002ebe:	8082                	ret

0000000080002ec0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002ec0:	1101                	addi	sp,sp,-32
    80002ec2:	ec06                	sd	ra,24(sp)
    80002ec4:	e822                	sd	s0,16(sp)
    80002ec6:	e426                	sd	s1,8(sp)
    80002ec8:	e04a                	sd	s2,0(sp)
    80002eca:	1000                	addi	s0,sp,32
    80002ecc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002ece:	00d5d59b          	srliw	a1,a1,0xd
    80002ed2:	0001e797          	auipc	a5,0x1e
    80002ed6:	01a7a783          	lw	a5,26(a5) # 80020eec <sb+0x1c>
    80002eda:	9dbd                	addw	a1,a1,a5
    80002edc:	00000097          	auipc	ra,0x0
    80002ee0:	d9a080e7          	jalr	-614(ra) # 80002c76 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ee4:	0074f713          	andi	a4,s1,7
    80002ee8:	4785                	li	a5,1
    80002eea:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002eee:	14ce                	slli	s1,s1,0x33
    80002ef0:	90d9                	srli	s1,s1,0x36
    80002ef2:	00950733          	add	a4,a0,s1
    80002ef6:	06074703          	lbu	a4,96(a4)
    80002efa:	00e7f6b3          	and	a3,a5,a4
    80002efe:	c69d                	beqz	a3,80002f2c <bfree+0x6c>
    80002f00:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f02:	94aa                	add	s1,s1,a0
    80002f04:	fff7c793          	not	a5,a5
    80002f08:	8ff9                	and	a5,a5,a4
    80002f0a:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80002f0e:	00001097          	auipc	ra,0x1
    80002f12:	1d2080e7          	jalr	466(ra) # 800040e0 <log_write>
  brelse(bp);
    80002f16:	854a                	mv	a0,s2
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	e92080e7          	jalr	-366(ra) # 80002daa <brelse>
}
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6902                	ld	s2,0(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret
    panic("freeing free block");
    80002f2c:	00005517          	auipc	a0,0x5
    80002f30:	5cc50513          	addi	a0,a0,1484 # 800084f8 <userret+0x468>
    80002f34:	ffffd097          	auipc	ra,0xffffd
    80002f38:	61a080e7          	jalr	1562(ra) # 8000054e <panic>

0000000080002f3c <balloc>:
{
    80002f3c:	711d                	addi	sp,sp,-96
    80002f3e:	ec86                	sd	ra,88(sp)
    80002f40:	e8a2                	sd	s0,80(sp)
    80002f42:	e4a6                	sd	s1,72(sp)
    80002f44:	e0ca                	sd	s2,64(sp)
    80002f46:	fc4e                	sd	s3,56(sp)
    80002f48:	f852                	sd	s4,48(sp)
    80002f4a:	f456                	sd	s5,40(sp)
    80002f4c:	f05a                	sd	s6,32(sp)
    80002f4e:	ec5e                	sd	s7,24(sp)
    80002f50:	e862                	sd	s8,16(sp)
    80002f52:	e466                	sd	s9,8(sp)
    80002f54:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002f56:	0001e797          	auipc	a5,0x1e
    80002f5a:	f7e7a783          	lw	a5,-130(a5) # 80020ed4 <sb+0x4>
    80002f5e:	cbd1                	beqz	a5,80002ff2 <balloc+0xb6>
    80002f60:	8baa                	mv	s7,a0
    80002f62:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002f64:	0001eb17          	auipc	s6,0x1e
    80002f68:	f6cb0b13          	addi	s6,s6,-148 # 80020ed0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f6c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002f6e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f70:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002f72:	6c89                	lui	s9,0x2
    80002f74:	a831                	j	80002f90 <balloc+0x54>
    brelse(bp);
    80002f76:	854a                	mv	a0,s2
    80002f78:	00000097          	auipc	ra,0x0
    80002f7c:	e32080e7          	jalr	-462(ra) # 80002daa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002f80:	015c87bb          	addw	a5,s9,s5
    80002f84:	00078a9b          	sext.w	s5,a5
    80002f88:	004b2703          	lw	a4,4(s6)
    80002f8c:	06eaf363          	bgeu	s5,a4,80002ff2 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80002f90:	41fad79b          	sraiw	a5,s5,0x1f
    80002f94:	0137d79b          	srliw	a5,a5,0x13
    80002f98:	015787bb          	addw	a5,a5,s5
    80002f9c:	40d7d79b          	sraiw	a5,a5,0xd
    80002fa0:	01cb2583          	lw	a1,28(s6)
    80002fa4:	9dbd                	addw	a1,a1,a5
    80002fa6:	855e                	mv	a0,s7
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	cce080e7          	jalr	-818(ra) # 80002c76 <bread>
    80002fb0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fb2:	004b2503          	lw	a0,4(s6)
    80002fb6:	000a849b          	sext.w	s1,s5
    80002fba:	8662                	mv	a2,s8
    80002fbc:	faa4fde3          	bgeu	s1,a0,80002f76 <balloc+0x3a>
      m = 1 << (bi % 8);
    80002fc0:	41f6579b          	sraiw	a5,a2,0x1f
    80002fc4:	01d7d69b          	srliw	a3,a5,0x1d
    80002fc8:	00c6873b          	addw	a4,a3,a2
    80002fcc:	00777793          	andi	a5,a4,7
    80002fd0:	9f95                	subw	a5,a5,a3
    80002fd2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002fd6:	4037571b          	sraiw	a4,a4,0x3
    80002fda:	00e906b3          	add	a3,s2,a4
    80002fde:	0606c683          	lbu	a3,96(a3)
    80002fe2:	00d7f5b3          	and	a1,a5,a3
    80002fe6:	cd91                	beqz	a1,80003002 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fe8:	2605                	addiw	a2,a2,1
    80002fea:	2485                	addiw	s1,s1,1
    80002fec:	fd4618e3          	bne	a2,s4,80002fbc <balloc+0x80>
    80002ff0:	b759                	j	80002f76 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002ff2:	00005517          	auipc	a0,0x5
    80002ff6:	51e50513          	addi	a0,a0,1310 # 80008510 <userret+0x480>
    80002ffa:	ffffd097          	auipc	ra,0xffffd
    80002ffe:	554080e7          	jalr	1364(ra) # 8000054e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003002:	974a                	add	a4,a4,s2
    80003004:	8fd5                	or	a5,a5,a3
    80003006:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000300a:	854a                	mv	a0,s2
    8000300c:	00001097          	auipc	ra,0x1
    80003010:	0d4080e7          	jalr	212(ra) # 800040e0 <log_write>
        brelse(bp);
    80003014:	854a                	mv	a0,s2
    80003016:	00000097          	auipc	ra,0x0
    8000301a:	d94080e7          	jalr	-620(ra) # 80002daa <brelse>
  bp = bread(dev, bno);
    8000301e:	85a6                	mv	a1,s1
    80003020:	855e                	mv	a0,s7
    80003022:	00000097          	auipc	ra,0x0
    80003026:	c54080e7          	jalr	-940(ra) # 80002c76 <bread>
    8000302a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000302c:	40000613          	li	a2,1024
    80003030:	4581                	li	a1,0
    80003032:	06050513          	addi	a0,a0,96
    80003036:	ffffe097          	auipc	ra,0xffffe
    8000303a:	b78080e7          	jalr	-1160(ra) # 80000bae <memset>
  log_write(bp);
    8000303e:	854a                	mv	a0,s2
    80003040:	00001097          	auipc	ra,0x1
    80003044:	0a0080e7          	jalr	160(ra) # 800040e0 <log_write>
  brelse(bp);
    80003048:	854a                	mv	a0,s2
    8000304a:	00000097          	auipc	ra,0x0
    8000304e:	d60080e7          	jalr	-672(ra) # 80002daa <brelse>
}
    80003052:	8526                	mv	a0,s1
    80003054:	60e6                	ld	ra,88(sp)
    80003056:	6446                	ld	s0,80(sp)
    80003058:	64a6                	ld	s1,72(sp)
    8000305a:	6906                	ld	s2,64(sp)
    8000305c:	79e2                	ld	s3,56(sp)
    8000305e:	7a42                	ld	s4,48(sp)
    80003060:	7aa2                	ld	s5,40(sp)
    80003062:	7b02                	ld	s6,32(sp)
    80003064:	6be2                	ld	s7,24(sp)
    80003066:	6c42                	ld	s8,16(sp)
    80003068:	6ca2                	ld	s9,8(sp)
    8000306a:	6125                	addi	sp,sp,96
    8000306c:	8082                	ret

000000008000306e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000306e:	7179                	addi	sp,sp,-48
    80003070:	f406                	sd	ra,40(sp)
    80003072:	f022                	sd	s0,32(sp)
    80003074:	ec26                	sd	s1,24(sp)
    80003076:	e84a                	sd	s2,16(sp)
    80003078:	e44e                	sd	s3,8(sp)
    8000307a:	e052                	sd	s4,0(sp)
    8000307c:	1800                	addi	s0,sp,48
    8000307e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003080:	47ad                	li	a5,11
    80003082:	04b7fe63          	bgeu	a5,a1,800030de <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003086:	ff45849b          	addiw	s1,a1,-12
    8000308a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000308e:	0ff00793          	li	a5,255
    80003092:	0ae7e363          	bltu	a5,a4,80003138 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003096:	08052583          	lw	a1,128(a0)
    8000309a:	c5ad                	beqz	a1,80003104 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000309c:	00092503          	lw	a0,0(s2)
    800030a0:	00000097          	auipc	ra,0x0
    800030a4:	bd6080e7          	jalr	-1066(ra) # 80002c76 <bread>
    800030a8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800030aa:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800030ae:	02049593          	slli	a1,s1,0x20
    800030b2:	9181                	srli	a1,a1,0x20
    800030b4:	058a                	slli	a1,a1,0x2
    800030b6:	00b784b3          	add	s1,a5,a1
    800030ba:	0004a983          	lw	s3,0(s1)
    800030be:	04098d63          	beqz	s3,80003118 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800030c2:	8552                	mv	a0,s4
    800030c4:	00000097          	auipc	ra,0x0
    800030c8:	ce6080e7          	jalr	-794(ra) # 80002daa <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800030cc:	854e                	mv	a0,s3
    800030ce:	70a2                	ld	ra,40(sp)
    800030d0:	7402                	ld	s0,32(sp)
    800030d2:	64e2                	ld	s1,24(sp)
    800030d4:	6942                	ld	s2,16(sp)
    800030d6:	69a2                	ld	s3,8(sp)
    800030d8:	6a02                	ld	s4,0(sp)
    800030da:	6145                	addi	sp,sp,48
    800030dc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800030de:	02059493          	slli	s1,a1,0x20
    800030e2:	9081                	srli	s1,s1,0x20
    800030e4:	048a                	slli	s1,s1,0x2
    800030e6:	94aa                	add	s1,s1,a0
    800030e8:	0504a983          	lw	s3,80(s1)
    800030ec:	fe0990e3          	bnez	s3,800030cc <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800030f0:	4108                	lw	a0,0(a0)
    800030f2:	00000097          	auipc	ra,0x0
    800030f6:	e4a080e7          	jalr	-438(ra) # 80002f3c <balloc>
    800030fa:	0005099b          	sext.w	s3,a0
    800030fe:	0534a823          	sw	s3,80(s1)
    80003102:	b7e9                	j	800030cc <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003104:	4108                	lw	a0,0(a0)
    80003106:	00000097          	auipc	ra,0x0
    8000310a:	e36080e7          	jalr	-458(ra) # 80002f3c <balloc>
    8000310e:	0005059b          	sext.w	a1,a0
    80003112:	08b92023          	sw	a1,128(s2)
    80003116:	b759                	j	8000309c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003118:	00092503          	lw	a0,0(s2)
    8000311c:	00000097          	auipc	ra,0x0
    80003120:	e20080e7          	jalr	-480(ra) # 80002f3c <balloc>
    80003124:	0005099b          	sext.w	s3,a0
    80003128:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000312c:	8552                	mv	a0,s4
    8000312e:	00001097          	auipc	ra,0x1
    80003132:	fb2080e7          	jalr	-78(ra) # 800040e0 <log_write>
    80003136:	b771                	j	800030c2 <bmap+0x54>
  panic("bmap: out of range");
    80003138:	00005517          	auipc	a0,0x5
    8000313c:	3f050513          	addi	a0,a0,1008 # 80008528 <userret+0x498>
    80003140:	ffffd097          	auipc	ra,0xffffd
    80003144:	40e080e7          	jalr	1038(ra) # 8000054e <panic>

0000000080003148 <iget>:
{
    80003148:	7179                	addi	sp,sp,-48
    8000314a:	f406                	sd	ra,40(sp)
    8000314c:	f022                	sd	s0,32(sp)
    8000314e:	ec26                	sd	s1,24(sp)
    80003150:	e84a                	sd	s2,16(sp)
    80003152:	e44e                	sd	s3,8(sp)
    80003154:	e052                	sd	s4,0(sp)
    80003156:	1800                	addi	s0,sp,48
    80003158:	89aa                	mv	s3,a0
    8000315a:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000315c:	0001e517          	auipc	a0,0x1e
    80003160:	d9450513          	addi	a0,a0,-620 # 80020ef0 <icache>
    80003164:	ffffe097          	auipc	ra,0xffffe
    80003168:	986080e7          	jalr	-1658(ra) # 80000aea <acquire>
  empty = 0;
    8000316c:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000316e:	0001e497          	auipc	s1,0x1e
    80003172:	d9a48493          	addi	s1,s1,-614 # 80020f08 <icache+0x18>
    80003176:	00020697          	auipc	a3,0x20
    8000317a:	82268693          	addi	a3,a3,-2014 # 80022998 <log>
    8000317e:	a039                	j	8000318c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003180:	02090b63          	beqz	s2,800031b6 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003184:	08848493          	addi	s1,s1,136
    80003188:	02d48a63          	beq	s1,a3,800031bc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000318c:	449c                	lw	a5,8(s1)
    8000318e:	fef059e3          	blez	a5,80003180 <iget+0x38>
    80003192:	4098                	lw	a4,0(s1)
    80003194:	ff3716e3          	bne	a4,s3,80003180 <iget+0x38>
    80003198:	40d8                	lw	a4,4(s1)
    8000319a:	ff4713e3          	bne	a4,s4,80003180 <iget+0x38>
      ip->ref++;
    8000319e:	2785                	addiw	a5,a5,1
    800031a0:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800031a2:	0001e517          	auipc	a0,0x1e
    800031a6:	d4e50513          	addi	a0,a0,-690 # 80020ef0 <icache>
    800031aa:	ffffe097          	auipc	ra,0xffffe
    800031ae:	9a8080e7          	jalr	-1624(ra) # 80000b52 <release>
      return ip;
    800031b2:	8926                	mv	s2,s1
    800031b4:	a03d                	j	800031e2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031b6:	f7f9                	bnez	a5,80003184 <iget+0x3c>
    800031b8:	8926                	mv	s2,s1
    800031ba:	b7e9                	j	80003184 <iget+0x3c>
  if(empty == 0)
    800031bc:	02090c63          	beqz	s2,800031f4 <iget+0xac>
  ip->dev = dev;
    800031c0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800031c4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800031c8:	4785                	li	a5,1
    800031ca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800031ce:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800031d2:	0001e517          	auipc	a0,0x1e
    800031d6:	d1e50513          	addi	a0,a0,-738 # 80020ef0 <icache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	978080e7          	jalr	-1672(ra) # 80000b52 <release>
}
    800031e2:	854a                	mv	a0,s2
    800031e4:	70a2                	ld	ra,40(sp)
    800031e6:	7402                	ld	s0,32(sp)
    800031e8:	64e2                	ld	s1,24(sp)
    800031ea:	6942                	ld	s2,16(sp)
    800031ec:	69a2                	ld	s3,8(sp)
    800031ee:	6a02                	ld	s4,0(sp)
    800031f0:	6145                	addi	sp,sp,48
    800031f2:	8082                	ret
    panic("iget: no inodes");
    800031f4:	00005517          	auipc	a0,0x5
    800031f8:	34c50513          	addi	a0,a0,844 # 80008540 <userret+0x4b0>
    800031fc:	ffffd097          	auipc	ra,0xffffd
    80003200:	352080e7          	jalr	850(ra) # 8000054e <panic>

0000000080003204 <fsinit>:
fsinit(int dev) {
    80003204:	7179                	addi	sp,sp,-48
    80003206:	f406                	sd	ra,40(sp)
    80003208:	f022                	sd	s0,32(sp)
    8000320a:	ec26                	sd	s1,24(sp)
    8000320c:	e84a                	sd	s2,16(sp)
    8000320e:	e44e                	sd	s3,8(sp)
    80003210:	1800                	addi	s0,sp,48
    80003212:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003214:	4585                	li	a1,1
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	a60080e7          	jalr	-1440(ra) # 80002c76 <bread>
    8000321e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003220:	0001e997          	auipc	s3,0x1e
    80003224:	cb098993          	addi	s3,s3,-848 # 80020ed0 <sb>
    80003228:	02000613          	li	a2,32
    8000322c:	06050593          	addi	a1,a0,96
    80003230:	854e                	mv	a0,s3
    80003232:	ffffe097          	auipc	ra,0xffffe
    80003236:	9dc080e7          	jalr	-1572(ra) # 80000c0e <memmove>
  brelse(bp);
    8000323a:	8526                	mv	a0,s1
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	b6e080e7          	jalr	-1170(ra) # 80002daa <brelse>
  if(sb.magic != FSMAGIC)
    80003244:	0009a703          	lw	a4,0(s3)
    80003248:	102037b7          	lui	a5,0x10203
    8000324c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003250:	02f71263          	bne	a4,a5,80003274 <fsinit+0x70>
  initlog(dev, &sb);
    80003254:	0001e597          	auipc	a1,0x1e
    80003258:	c7c58593          	addi	a1,a1,-900 # 80020ed0 <sb>
    8000325c:	854a                	mv	a0,s2
    8000325e:	00001097          	auipc	ra,0x1
    80003262:	bfc080e7          	jalr	-1028(ra) # 80003e5a <initlog>
}
    80003266:	70a2                	ld	ra,40(sp)
    80003268:	7402                	ld	s0,32(sp)
    8000326a:	64e2                	ld	s1,24(sp)
    8000326c:	6942                	ld	s2,16(sp)
    8000326e:	69a2                	ld	s3,8(sp)
    80003270:	6145                	addi	sp,sp,48
    80003272:	8082                	ret
    panic("invalid file system");
    80003274:	00005517          	auipc	a0,0x5
    80003278:	2dc50513          	addi	a0,a0,732 # 80008550 <userret+0x4c0>
    8000327c:	ffffd097          	auipc	ra,0xffffd
    80003280:	2d2080e7          	jalr	722(ra) # 8000054e <panic>

0000000080003284 <iinit>:
{
    80003284:	7179                	addi	sp,sp,-48
    80003286:	f406                	sd	ra,40(sp)
    80003288:	f022                	sd	s0,32(sp)
    8000328a:	ec26                	sd	s1,24(sp)
    8000328c:	e84a                	sd	s2,16(sp)
    8000328e:	e44e                	sd	s3,8(sp)
    80003290:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003292:	00005597          	auipc	a1,0x5
    80003296:	2d658593          	addi	a1,a1,726 # 80008568 <userret+0x4d8>
    8000329a:	0001e517          	auipc	a0,0x1e
    8000329e:	c5650513          	addi	a0,a0,-938 # 80020ef0 <icache>
    800032a2:	ffffd097          	auipc	ra,0xffffd
    800032a6:	736080e7          	jalr	1846(ra) # 800009d8 <initlock>
  for(i = 0; i < NINODE; i++) {
    800032aa:	0001e497          	auipc	s1,0x1e
    800032ae:	c6e48493          	addi	s1,s1,-914 # 80020f18 <icache+0x28>
    800032b2:	0001f997          	auipc	s3,0x1f
    800032b6:	6f698993          	addi	s3,s3,1782 # 800229a8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800032ba:	00005917          	auipc	s2,0x5
    800032be:	2b690913          	addi	s2,s2,694 # 80008570 <userret+0x4e0>
    800032c2:	85ca                	mv	a1,s2
    800032c4:	8526                	mv	a0,s1
    800032c6:	00001097          	auipc	ra,0x1
    800032ca:	078080e7          	jalr	120(ra) # 8000433e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800032ce:	08848493          	addi	s1,s1,136
    800032d2:	ff3498e3          	bne	s1,s3,800032c2 <iinit+0x3e>
}
    800032d6:	70a2                	ld	ra,40(sp)
    800032d8:	7402                	ld	s0,32(sp)
    800032da:	64e2                	ld	s1,24(sp)
    800032dc:	6942                	ld	s2,16(sp)
    800032de:	69a2                	ld	s3,8(sp)
    800032e0:	6145                	addi	sp,sp,48
    800032e2:	8082                	ret

00000000800032e4 <ialloc>:
{
    800032e4:	715d                	addi	sp,sp,-80
    800032e6:	e486                	sd	ra,72(sp)
    800032e8:	e0a2                	sd	s0,64(sp)
    800032ea:	fc26                	sd	s1,56(sp)
    800032ec:	f84a                	sd	s2,48(sp)
    800032ee:	f44e                	sd	s3,40(sp)
    800032f0:	f052                	sd	s4,32(sp)
    800032f2:	ec56                	sd	s5,24(sp)
    800032f4:	e85a                	sd	s6,16(sp)
    800032f6:	e45e                	sd	s7,8(sp)
    800032f8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800032fa:	0001e717          	auipc	a4,0x1e
    800032fe:	be272703          	lw	a4,-1054(a4) # 80020edc <sb+0xc>
    80003302:	4785                	li	a5,1
    80003304:	04e7fa63          	bgeu	a5,a4,80003358 <ialloc+0x74>
    80003308:	8aaa                	mv	s5,a0
    8000330a:	8bae                	mv	s7,a1
    8000330c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000330e:	0001ea17          	auipc	s4,0x1e
    80003312:	bc2a0a13          	addi	s4,s4,-1086 # 80020ed0 <sb>
    80003316:	00048b1b          	sext.w	s6,s1
    8000331a:	0044d593          	srli	a1,s1,0x4
    8000331e:	018a2783          	lw	a5,24(s4)
    80003322:	9dbd                	addw	a1,a1,a5
    80003324:	8556                	mv	a0,s5
    80003326:	00000097          	auipc	ra,0x0
    8000332a:	950080e7          	jalr	-1712(ra) # 80002c76 <bread>
    8000332e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003330:	06050993          	addi	s3,a0,96
    80003334:	00f4f793          	andi	a5,s1,15
    80003338:	079a                	slli	a5,a5,0x6
    8000333a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000333c:	00099783          	lh	a5,0(s3)
    80003340:	c785                	beqz	a5,80003368 <ialloc+0x84>
    brelse(bp);
    80003342:	00000097          	auipc	ra,0x0
    80003346:	a68080e7          	jalr	-1432(ra) # 80002daa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000334a:	0485                	addi	s1,s1,1
    8000334c:	00ca2703          	lw	a4,12(s4)
    80003350:	0004879b          	sext.w	a5,s1
    80003354:	fce7e1e3          	bltu	a5,a4,80003316 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003358:	00005517          	auipc	a0,0x5
    8000335c:	22050513          	addi	a0,a0,544 # 80008578 <userret+0x4e8>
    80003360:	ffffd097          	auipc	ra,0xffffd
    80003364:	1ee080e7          	jalr	494(ra) # 8000054e <panic>
      memset(dip, 0, sizeof(*dip));
    80003368:	04000613          	li	a2,64
    8000336c:	4581                	li	a1,0
    8000336e:	854e                	mv	a0,s3
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	83e080e7          	jalr	-1986(ra) # 80000bae <memset>
      dip->type = type;
    80003378:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000337c:	854a                	mv	a0,s2
    8000337e:	00001097          	auipc	ra,0x1
    80003382:	d62080e7          	jalr	-670(ra) # 800040e0 <log_write>
      brelse(bp);
    80003386:	854a                	mv	a0,s2
    80003388:	00000097          	auipc	ra,0x0
    8000338c:	a22080e7          	jalr	-1502(ra) # 80002daa <brelse>
      return iget(dev, inum);
    80003390:	85da                	mv	a1,s6
    80003392:	8556                	mv	a0,s5
    80003394:	00000097          	auipc	ra,0x0
    80003398:	db4080e7          	jalr	-588(ra) # 80003148 <iget>
}
    8000339c:	60a6                	ld	ra,72(sp)
    8000339e:	6406                	ld	s0,64(sp)
    800033a0:	74e2                	ld	s1,56(sp)
    800033a2:	7942                	ld	s2,48(sp)
    800033a4:	79a2                	ld	s3,40(sp)
    800033a6:	7a02                	ld	s4,32(sp)
    800033a8:	6ae2                	ld	s5,24(sp)
    800033aa:	6b42                	ld	s6,16(sp)
    800033ac:	6ba2                	ld	s7,8(sp)
    800033ae:	6161                	addi	sp,sp,80
    800033b0:	8082                	ret

00000000800033b2 <iupdate>:
{
    800033b2:	1101                	addi	sp,sp,-32
    800033b4:	ec06                	sd	ra,24(sp)
    800033b6:	e822                	sd	s0,16(sp)
    800033b8:	e426                	sd	s1,8(sp)
    800033ba:	e04a                	sd	s2,0(sp)
    800033bc:	1000                	addi	s0,sp,32
    800033be:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033c0:	415c                	lw	a5,4(a0)
    800033c2:	0047d79b          	srliw	a5,a5,0x4
    800033c6:	0001e597          	auipc	a1,0x1e
    800033ca:	b225a583          	lw	a1,-1246(a1) # 80020ee8 <sb+0x18>
    800033ce:	9dbd                	addw	a1,a1,a5
    800033d0:	4108                	lw	a0,0(a0)
    800033d2:	00000097          	auipc	ra,0x0
    800033d6:	8a4080e7          	jalr	-1884(ra) # 80002c76 <bread>
    800033da:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033dc:	06050793          	addi	a5,a0,96
    800033e0:	40c8                	lw	a0,4(s1)
    800033e2:	893d                	andi	a0,a0,15
    800033e4:	051a                	slli	a0,a0,0x6
    800033e6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800033e8:	04449703          	lh	a4,68(s1)
    800033ec:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800033f0:	04649703          	lh	a4,70(s1)
    800033f4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800033f8:	04849703          	lh	a4,72(s1)
    800033fc:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003400:	04a49703          	lh	a4,74(s1)
    80003404:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003408:	44f8                	lw	a4,76(s1)
    8000340a:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000340c:	03400613          	li	a2,52
    80003410:	05048593          	addi	a1,s1,80
    80003414:	0531                	addi	a0,a0,12
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	7f8080e7          	jalr	2040(ra) # 80000c0e <memmove>
  log_write(bp);
    8000341e:	854a                	mv	a0,s2
    80003420:	00001097          	auipc	ra,0x1
    80003424:	cc0080e7          	jalr	-832(ra) # 800040e0 <log_write>
  brelse(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	00000097          	auipc	ra,0x0
    8000342e:	980080e7          	jalr	-1664(ra) # 80002daa <brelse>
}
    80003432:	60e2                	ld	ra,24(sp)
    80003434:	6442                	ld	s0,16(sp)
    80003436:	64a2                	ld	s1,8(sp)
    80003438:	6902                	ld	s2,0(sp)
    8000343a:	6105                	addi	sp,sp,32
    8000343c:	8082                	ret

000000008000343e <idup>:
{
    8000343e:	1101                	addi	sp,sp,-32
    80003440:	ec06                	sd	ra,24(sp)
    80003442:	e822                	sd	s0,16(sp)
    80003444:	e426                	sd	s1,8(sp)
    80003446:	1000                	addi	s0,sp,32
    80003448:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000344a:	0001e517          	auipc	a0,0x1e
    8000344e:	aa650513          	addi	a0,a0,-1370 # 80020ef0 <icache>
    80003452:	ffffd097          	auipc	ra,0xffffd
    80003456:	698080e7          	jalr	1688(ra) # 80000aea <acquire>
  ip->ref++;
    8000345a:	449c                	lw	a5,8(s1)
    8000345c:	2785                	addiw	a5,a5,1
    8000345e:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003460:	0001e517          	auipc	a0,0x1e
    80003464:	a9050513          	addi	a0,a0,-1392 # 80020ef0 <icache>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	6ea080e7          	jalr	1770(ra) # 80000b52 <release>
}
    80003470:	8526                	mv	a0,s1
    80003472:	60e2                	ld	ra,24(sp)
    80003474:	6442                	ld	s0,16(sp)
    80003476:	64a2                	ld	s1,8(sp)
    80003478:	6105                	addi	sp,sp,32
    8000347a:	8082                	ret

000000008000347c <ilock>:
{
    8000347c:	1101                	addi	sp,sp,-32
    8000347e:	ec06                	sd	ra,24(sp)
    80003480:	e822                	sd	s0,16(sp)
    80003482:	e426                	sd	s1,8(sp)
    80003484:	e04a                	sd	s2,0(sp)
    80003486:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003488:	c115                	beqz	a0,800034ac <ilock+0x30>
    8000348a:	84aa                	mv	s1,a0
    8000348c:	451c                	lw	a5,8(a0)
    8000348e:	00f05f63          	blez	a5,800034ac <ilock+0x30>
  acquiresleep(&ip->lock);
    80003492:	0541                	addi	a0,a0,16
    80003494:	00001097          	auipc	ra,0x1
    80003498:	ee4080e7          	jalr	-284(ra) # 80004378 <acquiresleep>
  if(ip->valid == 0){
    8000349c:	40bc                	lw	a5,64(s1)
    8000349e:	cf99                	beqz	a5,800034bc <ilock+0x40>
}
    800034a0:	60e2                	ld	ra,24(sp)
    800034a2:	6442                	ld	s0,16(sp)
    800034a4:	64a2                	ld	s1,8(sp)
    800034a6:	6902                	ld	s2,0(sp)
    800034a8:	6105                	addi	sp,sp,32
    800034aa:	8082                	ret
    panic("ilock");
    800034ac:	00005517          	auipc	a0,0x5
    800034b0:	0e450513          	addi	a0,a0,228 # 80008590 <userret+0x500>
    800034b4:	ffffd097          	auipc	ra,0xffffd
    800034b8:	09a080e7          	jalr	154(ra) # 8000054e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034bc:	40dc                	lw	a5,4(s1)
    800034be:	0047d79b          	srliw	a5,a5,0x4
    800034c2:	0001e597          	auipc	a1,0x1e
    800034c6:	a265a583          	lw	a1,-1498(a1) # 80020ee8 <sb+0x18>
    800034ca:	9dbd                	addw	a1,a1,a5
    800034cc:	4088                	lw	a0,0(s1)
    800034ce:	fffff097          	auipc	ra,0xfffff
    800034d2:	7a8080e7          	jalr	1960(ra) # 80002c76 <bread>
    800034d6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034d8:	06050593          	addi	a1,a0,96
    800034dc:	40dc                	lw	a5,4(s1)
    800034de:	8bbd                	andi	a5,a5,15
    800034e0:	079a                	slli	a5,a5,0x6
    800034e2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034e4:	00059783          	lh	a5,0(a1)
    800034e8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034ec:	00259783          	lh	a5,2(a1)
    800034f0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034f4:	00459783          	lh	a5,4(a1)
    800034f8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800034fc:	00659783          	lh	a5,6(a1)
    80003500:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003504:	459c                	lw	a5,8(a1)
    80003506:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003508:	03400613          	li	a2,52
    8000350c:	05b1                	addi	a1,a1,12
    8000350e:	05048513          	addi	a0,s1,80
    80003512:	ffffd097          	auipc	ra,0xffffd
    80003516:	6fc080e7          	jalr	1788(ra) # 80000c0e <memmove>
    brelse(bp);
    8000351a:	854a                	mv	a0,s2
    8000351c:	00000097          	auipc	ra,0x0
    80003520:	88e080e7          	jalr	-1906(ra) # 80002daa <brelse>
    ip->valid = 1;
    80003524:	4785                	li	a5,1
    80003526:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003528:	04449783          	lh	a5,68(s1)
    8000352c:	fbb5                	bnez	a5,800034a0 <ilock+0x24>
      panic("ilock: no type");
    8000352e:	00005517          	auipc	a0,0x5
    80003532:	06a50513          	addi	a0,a0,106 # 80008598 <userret+0x508>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	018080e7          	jalr	24(ra) # 8000054e <panic>

000000008000353e <iunlock>:
{
    8000353e:	1101                	addi	sp,sp,-32
    80003540:	ec06                	sd	ra,24(sp)
    80003542:	e822                	sd	s0,16(sp)
    80003544:	e426                	sd	s1,8(sp)
    80003546:	e04a                	sd	s2,0(sp)
    80003548:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000354a:	c905                	beqz	a0,8000357a <iunlock+0x3c>
    8000354c:	84aa                	mv	s1,a0
    8000354e:	01050913          	addi	s2,a0,16
    80003552:	854a                	mv	a0,s2
    80003554:	00001097          	auipc	ra,0x1
    80003558:	ebe080e7          	jalr	-322(ra) # 80004412 <holdingsleep>
    8000355c:	cd19                	beqz	a0,8000357a <iunlock+0x3c>
    8000355e:	449c                	lw	a5,8(s1)
    80003560:	00f05d63          	blez	a5,8000357a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003564:	854a                	mv	a0,s2
    80003566:	00001097          	auipc	ra,0x1
    8000356a:	e68080e7          	jalr	-408(ra) # 800043ce <releasesleep>
}
    8000356e:	60e2                	ld	ra,24(sp)
    80003570:	6442                	ld	s0,16(sp)
    80003572:	64a2                	ld	s1,8(sp)
    80003574:	6902                	ld	s2,0(sp)
    80003576:	6105                	addi	sp,sp,32
    80003578:	8082                	ret
    panic("iunlock");
    8000357a:	00005517          	auipc	a0,0x5
    8000357e:	02e50513          	addi	a0,a0,46 # 800085a8 <userret+0x518>
    80003582:	ffffd097          	auipc	ra,0xffffd
    80003586:	fcc080e7          	jalr	-52(ra) # 8000054e <panic>

000000008000358a <iput>:
{
    8000358a:	7139                	addi	sp,sp,-64
    8000358c:	fc06                	sd	ra,56(sp)
    8000358e:	f822                	sd	s0,48(sp)
    80003590:	f426                	sd	s1,40(sp)
    80003592:	f04a                	sd	s2,32(sp)
    80003594:	ec4e                	sd	s3,24(sp)
    80003596:	e852                	sd	s4,16(sp)
    80003598:	e456                	sd	s5,8(sp)
    8000359a:	0080                	addi	s0,sp,64
    8000359c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000359e:	0001e517          	auipc	a0,0x1e
    800035a2:	95250513          	addi	a0,a0,-1710 # 80020ef0 <icache>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	544080e7          	jalr	1348(ra) # 80000aea <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035ae:	4498                	lw	a4,8(s1)
    800035b0:	4785                	li	a5,1
    800035b2:	02f70663          	beq	a4,a5,800035de <iput+0x54>
  ip->ref--;
    800035b6:	449c                	lw	a5,8(s1)
    800035b8:	37fd                	addiw	a5,a5,-1
    800035ba:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800035bc:	0001e517          	auipc	a0,0x1e
    800035c0:	93450513          	addi	a0,a0,-1740 # 80020ef0 <icache>
    800035c4:	ffffd097          	auipc	ra,0xffffd
    800035c8:	58e080e7          	jalr	1422(ra) # 80000b52 <release>
}
    800035cc:	70e2                	ld	ra,56(sp)
    800035ce:	7442                	ld	s0,48(sp)
    800035d0:	74a2                	ld	s1,40(sp)
    800035d2:	7902                	ld	s2,32(sp)
    800035d4:	69e2                	ld	s3,24(sp)
    800035d6:	6a42                	ld	s4,16(sp)
    800035d8:	6aa2                	ld	s5,8(sp)
    800035da:	6121                	addi	sp,sp,64
    800035dc:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800035de:	40bc                	lw	a5,64(s1)
    800035e0:	dbf9                	beqz	a5,800035b6 <iput+0x2c>
    800035e2:	04a49783          	lh	a5,74(s1)
    800035e6:	fbe1                	bnez	a5,800035b6 <iput+0x2c>
    acquiresleep(&ip->lock);
    800035e8:	01048a13          	addi	s4,s1,16
    800035ec:	8552                	mv	a0,s4
    800035ee:	00001097          	auipc	ra,0x1
    800035f2:	d8a080e7          	jalr	-630(ra) # 80004378 <acquiresleep>
    release(&icache.lock);
    800035f6:	0001e517          	auipc	a0,0x1e
    800035fa:	8fa50513          	addi	a0,a0,-1798 # 80020ef0 <icache>
    800035fe:	ffffd097          	auipc	ra,0xffffd
    80003602:	554080e7          	jalr	1364(ra) # 80000b52 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003606:	05048913          	addi	s2,s1,80
    8000360a:	08048993          	addi	s3,s1,128
    8000360e:	a819                	j	80003624 <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80003610:	4088                	lw	a0,0(s1)
    80003612:	00000097          	auipc	ra,0x0
    80003616:	8ae080e7          	jalr	-1874(ra) # 80002ec0 <bfree>
      ip->addrs[i] = 0;
    8000361a:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    8000361e:	0911                	addi	s2,s2,4
    80003620:	01390663          	beq	s2,s3,8000362c <iput+0xa2>
    if(ip->addrs[i]){
    80003624:	00092583          	lw	a1,0(s2)
    80003628:	d9fd                	beqz	a1,8000361e <iput+0x94>
    8000362a:	b7dd                	j	80003610 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000362c:	0804a583          	lw	a1,128(s1)
    80003630:	ed9d                	bnez	a1,8000366e <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003632:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    80003636:	8526                	mv	a0,s1
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	d7a080e7          	jalr	-646(ra) # 800033b2 <iupdate>
    ip->type = 0;
    80003640:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003644:	8526                	mv	a0,s1
    80003646:	00000097          	auipc	ra,0x0
    8000364a:	d6c080e7          	jalr	-660(ra) # 800033b2 <iupdate>
    ip->valid = 0;
    8000364e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003652:	8552                	mv	a0,s4
    80003654:	00001097          	auipc	ra,0x1
    80003658:	d7a080e7          	jalr	-646(ra) # 800043ce <releasesleep>
    acquire(&icache.lock);
    8000365c:	0001e517          	auipc	a0,0x1e
    80003660:	89450513          	addi	a0,a0,-1900 # 80020ef0 <icache>
    80003664:	ffffd097          	auipc	ra,0xffffd
    80003668:	486080e7          	jalr	1158(ra) # 80000aea <acquire>
    8000366c:	b7a9                	j	800035b6 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000366e:	4088                	lw	a0,0(s1)
    80003670:	fffff097          	auipc	ra,0xfffff
    80003674:	606080e7          	jalr	1542(ra) # 80002c76 <bread>
    80003678:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    8000367a:	06050913          	addi	s2,a0,96
    8000367e:	46050993          	addi	s3,a0,1120
    80003682:	a809                	j	80003694 <iput+0x10a>
        bfree(ip->dev, a[j]);
    80003684:	4088                	lw	a0,0(s1)
    80003686:	00000097          	auipc	ra,0x0
    8000368a:	83a080e7          	jalr	-1990(ra) # 80002ec0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000368e:	0911                	addi	s2,s2,4
    80003690:	01390663          	beq	s2,s3,8000369c <iput+0x112>
      if(a[j])
    80003694:	00092583          	lw	a1,0(s2)
    80003698:	d9fd                	beqz	a1,8000368e <iput+0x104>
    8000369a:	b7ed                	j	80003684 <iput+0xfa>
    brelse(bp);
    8000369c:	8556                	mv	a0,s5
    8000369e:	fffff097          	auipc	ra,0xfffff
    800036a2:	70c080e7          	jalr	1804(ra) # 80002daa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800036a6:	0804a583          	lw	a1,128(s1)
    800036aa:	4088                	lw	a0,0(s1)
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	814080e7          	jalr	-2028(ra) # 80002ec0 <bfree>
    ip->addrs[NDIRECT] = 0;
    800036b4:	0804a023          	sw	zero,128(s1)
    800036b8:	bfad                	j	80003632 <iput+0xa8>

00000000800036ba <iunlockput>:
{
    800036ba:	1101                	addi	sp,sp,-32
    800036bc:	ec06                	sd	ra,24(sp)
    800036be:	e822                	sd	s0,16(sp)
    800036c0:	e426                	sd	s1,8(sp)
    800036c2:	1000                	addi	s0,sp,32
    800036c4:	84aa                	mv	s1,a0
  iunlock(ip);
    800036c6:	00000097          	auipc	ra,0x0
    800036ca:	e78080e7          	jalr	-392(ra) # 8000353e <iunlock>
  iput(ip);
    800036ce:	8526                	mv	a0,s1
    800036d0:	00000097          	auipc	ra,0x0
    800036d4:	eba080e7          	jalr	-326(ra) # 8000358a <iput>
}
    800036d8:	60e2                	ld	ra,24(sp)
    800036da:	6442                	ld	s0,16(sp)
    800036dc:	64a2                	ld	s1,8(sp)
    800036de:	6105                	addi	sp,sp,32
    800036e0:	8082                	ret

00000000800036e2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036e2:	1141                	addi	sp,sp,-16
    800036e4:	e422                	sd	s0,8(sp)
    800036e6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036e8:	411c                	lw	a5,0(a0)
    800036ea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036ec:	415c                	lw	a5,4(a0)
    800036ee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036f0:	04451783          	lh	a5,68(a0)
    800036f4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036f8:	04a51783          	lh	a5,74(a0)
    800036fc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003700:	04c56783          	lwu	a5,76(a0)
    80003704:	e99c                	sd	a5,16(a1)
}
    80003706:	6422                	ld	s0,8(sp)
    80003708:	0141                	addi	sp,sp,16
    8000370a:	8082                	ret

000000008000370c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000370c:	457c                	lw	a5,76(a0)
    8000370e:	0ed7e563          	bltu	a5,a3,800037f8 <readi+0xec>
{
    80003712:	7159                	addi	sp,sp,-112
    80003714:	f486                	sd	ra,104(sp)
    80003716:	f0a2                	sd	s0,96(sp)
    80003718:	eca6                	sd	s1,88(sp)
    8000371a:	e8ca                	sd	s2,80(sp)
    8000371c:	e4ce                	sd	s3,72(sp)
    8000371e:	e0d2                	sd	s4,64(sp)
    80003720:	fc56                	sd	s5,56(sp)
    80003722:	f85a                	sd	s6,48(sp)
    80003724:	f45e                	sd	s7,40(sp)
    80003726:	f062                	sd	s8,32(sp)
    80003728:	ec66                	sd	s9,24(sp)
    8000372a:	e86a                	sd	s10,16(sp)
    8000372c:	e46e                	sd	s11,8(sp)
    8000372e:	1880                	addi	s0,sp,112
    80003730:	8baa                	mv	s7,a0
    80003732:	8c2e                	mv	s8,a1
    80003734:	8ab2                	mv	s5,a2
    80003736:	8936                	mv	s2,a3
    80003738:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000373a:	9f35                	addw	a4,a4,a3
    8000373c:	0cd76063          	bltu	a4,a3,800037fc <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003740:	00e7f463          	bgeu	a5,a4,80003748 <readi+0x3c>
    n = ip->size - off;
    80003744:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003748:	080b0763          	beqz	s6,800037d6 <readi+0xca>
    8000374c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000374e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003752:	5cfd                	li	s9,-1
    80003754:	a82d                	j	8000378e <readi+0x82>
    80003756:	02099d93          	slli	s11,s3,0x20
    8000375a:	020ddd93          	srli	s11,s11,0x20
    8000375e:	06048613          	addi	a2,s1,96
    80003762:	86ee                	mv	a3,s11
    80003764:	963a                	add	a2,a2,a4
    80003766:	85d6                	mv	a1,s5
    80003768:	8562                	mv	a0,s8
    8000376a:	fffff097          	auipc	ra,0xfffff
    8000376e:	b54080e7          	jalr	-1196(ra) # 800022be <either_copyout>
    80003772:	05950d63          	beq	a0,s9,800037cc <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003776:	8526                	mv	a0,s1
    80003778:	fffff097          	auipc	ra,0xfffff
    8000377c:	632080e7          	jalr	1586(ra) # 80002daa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003780:	01498a3b          	addw	s4,s3,s4
    80003784:	0129893b          	addw	s2,s3,s2
    80003788:	9aee                	add	s5,s5,s11
    8000378a:	056a7663          	bgeu	s4,s6,800037d6 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000378e:	000ba483          	lw	s1,0(s7)
    80003792:	00a9559b          	srliw	a1,s2,0xa
    80003796:	855e                	mv	a0,s7
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	8d6080e7          	jalr	-1834(ra) # 8000306e <bmap>
    800037a0:	0005059b          	sext.w	a1,a0
    800037a4:	8526                	mv	a0,s1
    800037a6:	fffff097          	auipc	ra,0xfffff
    800037aa:	4d0080e7          	jalr	1232(ra) # 80002c76 <bread>
    800037ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037b0:	3ff97713          	andi	a4,s2,1023
    800037b4:	40ed07bb          	subw	a5,s10,a4
    800037b8:	414b06bb          	subw	a3,s6,s4
    800037bc:	89be                	mv	s3,a5
    800037be:	2781                	sext.w	a5,a5
    800037c0:	0006861b          	sext.w	a2,a3
    800037c4:	f8f679e3          	bgeu	a2,a5,80003756 <readi+0x4a>
    800037c8:	89b6                	mv	s3,a3
    800037ca:	b771                	j	80003756 <readi+0x4a>
      brelse(bp);
    800037cc:	8526                	mv	a0,s1
    800037ce:	fffff097          	auipc	ra,0xfffff
    800037d2:	5dc080e7          	jalr	1500(ra) # 80002daa <brelse>
  }
  return n;
    800037d6:	000b051b          	sext.w	a0,s6
}
    800037da:	70a6                	ld	ra,104(sp)
    800037dc:	7406                	ld	s0,96(sp)
    800037de:	64e6                	ld	s1,88(sp)
    800037e0:	6946                	ld	s2,80(sp)
    800037e2:	69a6                	ld	s3,72(sp)
    800037e4:	6a06                	ld	s4,64(sp)
    800037e6:	7ae2                	ld	s5,56(sp)
    800037e8:	7b42                	ld	s6,48(sp)
    800037ea:	7ba2                	ld	s7,40(sp)
    800037ec:	7c02                	ld	s8,32(sp)
    800037ee:	6ce2                	ld	s9,24(sp)
    800037f0:	6d42                	ld	s10,16(sp)
    800037f2:	6da2                	ld	s11,8(sp)
    800037f4:	6165                	addi	sp,sp,112
    800037f6:	8082                	ret
    return -1;
    800037f8:	557d                	li	a0,-1
}
    800037fa:	8082                	ret
    return -1;
    800037fc:	557d                	li	a0,-1
    800037fe:	bff1                	j	800037da <readi+0xce>

0000000080003800 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003800:	457c                	lw	a5,76(a0)
    80003802:	10d7e763          	bltu	a5,a3,80003910 <writei+0x110>
{
    80003806:	7159                	addi	sp,sp,-112
    80003808:	f486                	sd	ra,104(sp)
    8000380a:	f0a2                	sd	s0,96(sp)
    8000380c:	eca6                	sd	s1,88(sp)
    8000380e:	e8ca                	sd	s2,80(sp)
    80003810:	e4ce                	sd	s3,72(sp)
    80003812:	e0d2                	sd	s4,64(sp)
    80003814:	fc56                	sd	s5,56(sp)
    80003816:	f85a                	sd	s6,48(sp)
    80003818:	f45e                	sd	s7,40(sp)
    8000381a:	f062                	sd	s8,32(sp)
    8000381c:	ec66                	sd	s9,24(sp)
    8000381e:	e86a                	sd	s10,16(sp)
    80003820:	e46e                	sd	s11,8(sp)
    80003822:	1880                	addi	s0,sp,112
    80003824:	8baa                	mv	s7,a0
    80003826:	8c2e                	mv	s8,a1
    80003828:	8ab2                	mv	s5,a2
    8000382a:	8936                	mv	s2,a3
    8000382c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000382e:	00e687bb          	addw	a5,a3,a4
    80003832:	0ed7e163          	bltu	a5,a3,80003914 <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003836:	00043737          	lui	a4,0x43
    8000383a:	0cf76f63          	bltu	a4,a5,80003918 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000383e:	0a0b0063          	beqz	s6,800038de <writei+0xde>
    80003842:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003844:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003848:	5cfd                	li	s9,-1
    8000384a:	a091                	j	8000388e <writei+0x8e>
    8000384c:	02099d93          	slli	s11,s3,0x20
    80003850:	020ddd93          	srli	s11,s11,0x20
    80003854:	06048513          	addi	a0,s1,96
    80003858:	86ee                	mv	a3,s11
    8000385a:	8656                	mv	a2,s5
    8000385c:	85e2                	mv	a1,s8
    8000385e:	953a                	add	a0,a0,a4
    80003860:	fffff097          	auipc	ra,0xfffff
    80003864:	ab4080e7          	jalr	-1356(ra) # 80002314 <either_copyin>
    80003868:	07950263          	beq	a0,s9,800038cc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000386c:	8526                	mv	a0,s1
    8000386e:	00001097          	auipc	ra,0x1
    80003872:	872080e7          	jalr	-1934(ra) # 800040e0 <log_write>
    brelse(bp);
    80003876:	8526                	mv	a0,s1
    80003878:	fffff097          	auipc	ra,0xfffff
    8000387c:	532080e7          	jalr	1330(ra) # 80002daa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003880:	01498a3b          	addw	s4,s3,s4
    80003884:	0129893b          	addw	s2,s3,s2
    80003888:	9aee                	add	s5,s5,s11
    8000388a:	056a7663          	bgeu	s4,s6,800038d6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000388e:	000ba483          	lw	s1,0(s7)
    80003892:	00a9559b          	srliw	a1,s2,0xa
    80003896:	855e                	mv	a0,s7
    80003898:	fffff097          	auipc	ra,0xfffff
    8000389c:	7d6080e7          	jalr	2006(ra) # 8000306e <bmap>
    800038a0:	0005059b          	sext.w	a1,a0
    800038a4:	8526                	mv	a0,s1
    800038a6:	fffff097          	auipc	ra,0xfffff
    800038aa:	3d0080e7          	jalr	976(ra) # 80002c76 <bread>
    800038ae:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800038b0:	3ff97713          	andi	a4,s2,1023
    800038b4:	40ed07bb          	subw	a5,s10,a4
    800038b8:	414b06bb          	subw	a3,s6,s4
    800038bc:	89be                	mv	s3,a5
    800038be:	2781                	sext.w	a5,a5
    800038c0:	0006861b          	sext.w	a2,a3
    800038c4:	f8f674e3          	bgeu	a2,a5,8000384c <writei+0x4c>
    800038c8:	89b6                	mv	s3,a3
    800038ca:	b749                	j	8000384c <writei+0x4c>
      brelse(bp);
    800038cc:	8526                	mv	a0,s1
    800038ce:	fffff097          	auipc	ra,0xfffff
    800038d2:	4dc080e7          	jalr	1244(ra) # 80002daa <brelse>
  }

  if(n > 0 && off > ip->size){
    800038d6:	04cba783          	lw	a5,76(s7)
    800038da:	0327e363          	bltu	a5,s2,80003900 <writei+0x100>
    ip->size = off;
    iupdate(ip);
  }
  return n;
    800038de:	000b051b          	sext.w	a0,s6
}
    800038e2:	70a6                	ld	ra,104(sp)
    800038e4:	7406                	ld	s0,96(sp)
    800038e6:	64e6                	ld	s1,88(sp)
    800038e8:	6946                	ld	s2,80(sp)
    800038ea:	69a6                	ld	s3,72(sp)
    800038ec:	6a06                	ld	s4,64(sp)
    800038ee:	7ae2                	ld	s5,56(sp)
    800038f0:	7b42                	ld	s6,48(sp)
    800038f2:	7ba2                	ld	s7,40(sp)
    800038f4:	7c02                	ld	s8,32(sp)
    800038f6:	6ce2                	ld	s9,24(sp)
    800038f8:	6d42                	ld	s10,16(sp)
    800038fa:	6da2                	ld	s11,8(sp)
    800038fc:	6165                	addi	sp,sp,112
    800038fe:	8082                	ret
    ip->size = off;
    80003900:	052ba623          	sw	s2,76(s7)
    iupdate(ip);
    80003904:	855e                	mv	a0,s7
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	aac080e7          	jalr	-1364(ra) # 800033b2 <iupdate>
    8000390e:	bfc1                	j	800038de <writei+0xde>
    return -1;
    80003910:	557d                	li	a0,-1
}
    80003912:	8082                	ret
    return -1;
    80003914:	557d                	li	a0,-1
    80003916:	b7f1                	j	800038e2 <writei+0xe2>
    return -1;
    80003918:	557d                	li	a0,-1
    8000391a:	b7e1                	j	800038e2 <writei+0xe2>

000000008000391c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000391c:	1141                	addi	sp,sp,-16
    8000391e:	e406                	sd	ra,8(sp)
    80003920:	e022                	sd	s0,0(sp)
    80003922:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003924:	4639                	li	a2,14
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	364080e7          	jalr	868(ra) # 80000c8a <strncmp>
}
    8000392e:	60a2                	ld	ra,8(sp)
    80003930:	6402                	ld	s0,0(sp)
    80003932:	0141                	addi	sp,sp,16
    80003934:	8082                	ret

0000000080003936 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003936:	7139                	addi	sp,sp,-64
    80003938:	fc06                	sd	ra,56(sp)
    8000393a:	f822                	sd	s0,48(sp)
    8000393c:	f426                	sd	s1,40(sp)
    8000393e:	f04a                	sd	s2,32(sp)
    80003940:	ec4e                	sd	s3,24(sp)
    80003942:	e852                	sd	s4,16(sp)
    80003944:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003946:	04451703          	lh	a4,68(a0)
    8000394a:	4785                	li	a5,1
    8000394c:	00f71a63          	bne	a4,a5,80003960 <dirlookup+0x2a>
    80003950:	892a                	mv	s2,a0
    80003952:	89ae                	mv	s3,a1
    80003954:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003956:	457c                	lw	a5,76(a0)
    80003958:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000395a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000395c:	e79d                	bnez	a5,8000398a <dirlookup+0x54>
    8000395e:	a8a5                	j	800039d6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003960:	00005517          	auipc	a0,0x5
    80003964:	c5050513          	addi	a0,a0,-944 # 800085b0 <userret+0x520>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	be6080e7          	jalr	-1050(ra) # 8000054e <panic>
      panic("dirlookup read");
    80003970:	00005517          	auipc	a0,0x5
    80003974:	c5850513          	addi	a0,a0,-936 # 800085c8 <userret+0x538>
    80003978:	ffffd097          	auipc	ra,0xffffd
    8000397c:	bd6080e7          	jalr	-1066(ra) # 8000054e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003980:	24c1                	addiw	s1,s1,16
    80003982:	04c92783          	lw	a5,76(s2)
    80003986:	04f4f763          	bgeu	s1,a5,800039d4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000398a:	4741                	li	a4,16
    8000398c:	86a6                	mv	a3,s1
    8000398e:	fc040613          	addi	a2,s0,-64
    80003992:	4581                	li	a1,0
    80003994:	854a                	mv	a0,s2
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	d76080e7          	jalr	-650(ra) # 8000370c <readi>
    8000399e:	47c1                	li	a5,16
    800039a0:	fcf518e3          	bne	a0,a5,80003970 <dirlookup+0x3a>
    if(de.inum == 0)
    800039a4:	fc045783          	lhu	a5,-64(s0)
    800039a8:	dfe1                	beqz	a5,80003980 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800039aa:	fc240593          	addi	a1,s0,-62
    800039ae:	854e                	mv	a0,s3
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	f6c080e7          	jalr	-148(ra) # 8000391c <namecmp>
    800039b8:	f561                	bnez	a0,80003980 <dirlookup+0x4a>
      if(poff)
    800039ba:	000a0463          	beqz	s4,800039c2 <dirlookup+0x8c>
        *poff = off;
    800039be:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800039c2:	fc045583          	lhu	a1,-64(s0)
    800039c6:	00092503          	lw	a0,0(s2)
    800039ca:	fffff097          	auipc	ra,0xfffff
    800039ce:	77e080e7          	jalr	1918(ra) # 80003148 <iget>
    800039d2:	a011                	j	800039d6 <dirlookup+0xa0>
  return 0;
    800039d4:	4501                	li	a0,0
}
    800039d6:	70e2                	ld	ra,56(sp)
    800039d8:	7442                	ld	s0,48(sp)
    800039da:	74a2                	ld	s1,40(sp)
    800039dc:	7902                	ld	s2,32(sp)
    800039de:	69e2                	ld	s3,24(sp)
    800039e0:	6a42                	ld	s4,16(sp)
    800039e2:	6121                	addi	sp,sp,64
    800039e4:	8082                	ret

00000000800039e6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800039e6:	711d                	addi	sp,sp,-96
    800039e8:	ec86                	sd	ra,88(sp)
    800039ea:	e8a2                	sd	s0,80(sp)
    800039ec:	e4a6                	sd	s1,72(sp)
    800039ee:	e0ca                	sd	s2,64(sp)
    800039f0:	fc4e                	sd	s3,56(sp)
    800039f2:	f852                	sd	s4,48(sp)
    800039f4:	f456                	sd	s5,40(sp)
    800039f6:	f05a                	sd	s6,32(sp)
    800039f8:	ec5e                	sd	s7,24(sp)
    800039fa:	e862                	sd	s8,16(sp)
    800039fc:	e466                	sd	s9,8(sp)
    800039fe:	1080                	addi	s0,sp,96
    80003a00:	84aa                	mv	s1,a0
    80003a02:	8b2e                	mv	s6,a1
    80003a04:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003a06:	00054703          	lbu	a4,0(a0)
    80003a0a:	02f00793          	li	a5,47
    80003a0e:	02f70363          	beq	a4,a5,80003a34 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003a12:	ffffe097          	auipc	ra,0xffffe
    80003a16:	e3a080e7          	jalr	-454(ra) # 8000184c <myproc>
    80003a1a:	15053503          	ld	a0,336(a0)
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	a20080e7          	jalr	-1504(ra) # 8000343e <idup>
    80003a26:	89aa                	mv	s3,a0
  while(*path == '/')
    80003a28:	02f00913          	li	s2,47
  len = path - s;
    80003a2c:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003a2e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003a30:	4c05                	li	s8,1
    80003a32:	a865                	j	80003aea <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003a34:	4585                	li	a1,1
    80003a36:	4501                	li	a0,0
    80003a38:	fffff097          	auipc	ra,0xfffff
    80003a3c:	710080e7          	jalr	1808(ra) # 80003148 <iget>
    80003a40:	89aa                	mv	s3,a0
    80003a42:	b7dd                	j	80003a28 <namex+0x42>
      iunlockput(ip);
    80003a44:	854e                	mv	a0,s3
    80003a46:	00000097          	auipc	ra,0x0
    80003a4a:	c74080e7          	jalr	-908(ra) # 800036ba <iunlockput>
      return 0;
    80003a4e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003a50:	854e                	mv	a0,s3
    80003a52:	60e6                	ld	ra,88(sp)
    80003a54:	6446                	ld	s0,80(sp)
    80003a56:	64a6                	ld	s1,72(sp)
    80003a58:	6906                	ld	s2,64(sp)
    80003a5a:	79e2                	ld	s3,56(sp)
    80003a5c:	7a42                	ld	s4,48(sp)
    80003a5e:	7aa2                	ld	s5,40(sp)
    80003a60:	7b02                	ld	s6,32(sp)
    80003a62:	6be2                	ld	s7,24(sp)
    80003a64:	6c42                	ld	s8,16(sp)
    80003a66:	6ca2                	ld	s9,8(sp)
    80003a68:	6125                	addi	sp,sp,96
    80003a6a:	8082                	ret
      iunlock(ip);
    80003a6c:	854e                	mv	a0,s3
    80003a6e:	00000097          	auipc	ra,0x0
    80003a72:	ad0080e7          	jalr	-1328(ra) # 8000353e <iunlock>
      return ip;
    80003a76:	bfe9                	j	80003a50 <namex+0x6a>
      iunlockput(ip);
    80003a78:	854e                	mv	a0,s3
    80003a7a:	00000097          	auipc	ra,0x0
    80003a7e:	c40080e7          	jalr	-960(ra) # 800036ba <iunlockput>
      return 0;
    80003a82:	89d2                	mv	s3,s4
    80003a84:	b7f1                	j	80003a50 <namex+0x6a>
  len = path - s;
    80003a86:	40b48633          	sub	a2,s1,a1
    80003a8a:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80003a8e:	094cd463          	bge	s9,s4,80003b16 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003a92:	4639                	li	a2,14
    80003a94:	8556                	mv	a0,s5
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	178080e7          	jalr	376(ra) # 80000c0e <memmove>
  while(*path == '/')
    80003a9e:	0004c783          	lbu	a5,0(s1)
    80003aa2:	01279763          	bne	a5,s2,80003ab0 <namex+0xca>
    path++;
    80003aa6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003aa8:	0004c783          	lbu	a5,0(s1)
    80003aac:	ff278de3          	beq	a5,s2,80003aa6 <namex+0xc0>
    ilock(ip);
    80003ab0:	854e                	mv	a0,s3
    80003ab2:	00000097          	auipc	ra,0x0
    80003ab6:	9ca080e7          	jalr	-1590(ra) # 8000347c <ilock>
    if(ip->type != T_DIR){
    80003aba:	04499783          	lh	a5,68(s3)
    80003abe:	f98793e3          	bne	a5,s8,80003a44 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ac2:	000b0563          	beqz	s6,80003acc <namex+0xe6>
    80003ac6:	0004c783          	lbu	a5,0(s1)
    80003aca:	d3cd                	beqz	a5,80003a6c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003acc:	865e                	mv	a2,s7
    80003ace:	85d6                	mv	a1,s5
    80003ad0:	854e                	mv	a0,s3
    80003ad2:	00000097          	auipc	ra,0x0
    80003ad6:	e64080e7          	jalr	-412(ra) # 80003936 <dirlookup>
    80003ada:	8a2a                	mv	s4,a0
    80003adc:	dd51                	beqz	a0,80003a78 <namex+0x92>
    iunlockput(ip);
    80003ade:	854e                	mv	a0,s3
    80003ae0:	00000097          	auipc	ra,0x0
    80003ae4:	bda080e7          	jalr	-1062(ra) # 800036ba <iunlockput>
    ip = next;
    80003ae8:	89d2                	mv	s3,s4
  while(*path == '/')
    80003aea:	0004c783          	lbu	a5,0(s1)
    80003aee:	05279763          	bne	a5,s2,80003b3c <namex+0x156>
    path++;
    80003af2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003af4:	0004c783          	lbu	a5,0(s1)
    80003af8:	ff278de3          	beq	a5,s2,80003af2 <namex+0x10c>
  if(*path == 0)
    80003afc:	c79d                	beqz	a5,80003b2a <namex+0x144>
    path++;
    80003afe:	85a6                	mv	a1,s1
  len = path - s;
    80003b00:	8a5e                	mv	s4,s7
    80003b02:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003b04:	01278963          	beq	a5,s2,80003b16 <namex+0x130>
    80003b08:	dfbd                	beqz	a5,80003a86 <namex+0xa0>
    path++;
    80003b0a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003b0c:	0004c783          	lbu	a5,0(s1)
    80003b10:	ff279ce3          	bne	a5,s2,80003b08 <namex+0x122>
    80003b14:	bf8d                	j	80003a86 <namex+0xa0>
    memmove(name, s, len);
    80003b16:	2601                	sext.w	a2,a2
    80003b18:	8556                	mv	a0,s5
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	0f4080e7          	jalr	244(ra) # 80000c0e <memmove>
    name[len] = 0;
    80003b22:	9a56                	add	s4,s4,s5
    80003b24:	000a0023          	sb	zero,0(s4)
    80003b28:	bf9d                	j	80003a9e <namex+0xb8>
  if(nameiparent){
    80003b2a:	f20b03e3          	beqz	s6,80003a50 <namex+0x6a>
    iput(ip);
    80003b2e:	854e                	mv	a0,s3
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	a5a080e7          	jalr	-1446(ra) # 8000358a <iput>
    return 0;
    80003b38:	4981                	li	s3,0
    80003b3a:	bf19                	j	80003a50 <namex+0x6a>
  if(*path == 0)
    80003b3c:	d7fd                	beqz	a5,80003b2a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003b3e:	0004c783          	lbu	a5,0(s1)
    80003b42:	85a6                	mv	a1,s1
    80003b44:	b7d1                	j	80003b08 <namex+0x122>

0000000080003b46 <dirlink>:
{
    80003b46:	7139                	addi	sp,sp,-64
    80003b48:	fc06                	sd	ra,56(sp)
    80003b4a:	f822                	sd	s0,48(sp)
    80003b4c:	f426                	sd	s1,40(sp)
    80003b4e:	f04a                	sd	s2,32(sp)
    80003b50:	ec4e                	sd	s3,24(sp)
    80003b52:	e852                	sd	s4,16(sp)
    80003b54:	0080                	addi	s0,sp,64
    80003b56:	892a                	mv	s2,a0
    80003b58:	8a2e                	mv	s4,a1
    80003b5a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003b5c:	4601                	li	a2,0
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	dd8080e7          	jalr	-552(ra) # 80003936 <dirlookup>
    80003b66:	e93d                	bnez	a0,80003bdc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b68:	04c92483          	lw	s1,76(s2)
    80003b6c:	c49d                	beqz	s1,80003b9a <dirlink+0x54>
    80003b6e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b70:	4741                	li	a4,16
    80003b72:	86a6                	mv	a3,s1
    80003b74:	fc040613          	addi	a2,s0,-64
    80003b78:	4581                	li	a1,0
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	b90080e7          	jalr	-1136(ra) # 8000370c <readi>
    80003b84:	47c1                	li	a5,16
    80003b86:	06f51163          	bne	a0,a5,80003be8 <dirlink+0xa2>
    if(de.inum == 0)
    80003b8a:	fc045783          	lhu	a5,-64(s0)
    80003b8e:	c791                	beqz	a5,80003b9a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b90:	24c1                	addiw	s1,s1,16
    80003b92:	04c92783          	lw	a5,76(s2)
    80003b96:	fcf4ede3          	bltu	s1,a5,80003b70 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003b9a:	4639                	li	a2,14
    80003b9c:	85d2                	mv	a1,s4
    80003b9e:	fc240513          	addi	a0,s0,-62
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	124080e7          	jalr	292(ra) # 80000cc6 <strncpy>
  de.inum = inum;
    80003baa:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bae:	4741                	li	a4,16
    80003bb0:	86a6                	mv	a3,s1
    80003bb2:	fc040613          	addi	a2,s0,-64
    80003bb6:	4581                	li	a1,0
    80003bb8:	854a                	mv	a0,s2
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	c46080e7          	jalr	-954(ra) # 80003800 <writei>
    80003bc2:	872a                	mv	a4,a0
    80003bc4:	47c1                	li	a5,16
  return 0;
    80003bc6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bc8:	02f71863          	bne	a4,a5,80003bf8 <dirlink+0xb2>
}
    80003bcc:	70e2                	ld	ra,56(sp)
    80003bce:	7442                	ld	s0,48(sp)
    80003bd0:	74a2                	ld	s1,40(sp)
    80003bd2:	7902                	ld	s2,32(sp)
    80003bd4:	69e2                	ld	s3,24(sp)
    80003bd6:	6a42                	ld	s4,16(sp)
    80003bd8:	6121                	addi	sp,sp,64
    80003bda:	8082                	ret
    iput(ip);
    80003bdc:	00000097          	auipc	ra,0x0
    80003be0:	9ae080e7          	jalr	-1618(ra) # 8000358a <iput>
    return -1;
    80003be4:	557d                	li	a0,-1
    80003be6:	b7dd                	j	80003bcc <dirlink+0x86>
      panic("dirlink read");
    80003be8:	00005517          	auipc	a0,0x5
    80003bec:	9f050513          	addi	a0,a0,-1552 # 800085d8 <userret+0x548>
    80003bf0:	ffffd097          	auipc	ra,0xffffd
    80003bf4:	95e080e7          	jalr	-1698(ra) # 8000054e <panic>
    panic("dirlink");
    80003bf8:	00005517          	auipc	a0,0x5
    80003bfc:	b9050513          	addi	a0,a0,-1136 # 80008788 <userret+0x6f8>
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	94e080e7          	jalr	-1714(ra) # 8000054e <panic>

0000000080003c08 <namei>:

struct inode*
namei(char *path)
{
    80003c08:	1101                	addi	sp,sp,-32
    80003c0a:	ec06                	sd	ra,24(sp)
    80003c0c:	e822                	sd	s0,16(sp)
    80003c0e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003c10:	fe040613          	addi	a2,s0,-32
    80003c14:	4581                	li	a1,0
    80003c16:	00000097          	auipc	ra,0x0
    80003c1a:	dd0080e7          	jalr	-560(ra) # 800039e6 <namex>
}
    80003c1e:	60e2                	ld	ra,24(sp)
    80003c20:	6442                	ld	s0,16(sp)
    80003c22:	6105                	addi	sp,sp,32
    80003c24:	8082                	ret

0000000080003c26 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003c26:	1141                	addi	sp,sp,-16
    80003c28:	e406                	sd	ra,8(sp)
    80003c2a:	e022                	sd	s0,0(sp)
    80003c2c:	0800                	addi	s0,sp,16
    80003c2e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003c30:	4585                	li	a1,1
    80003c32:	00000097          	auipc	ra,0x0
    80003c36:	db4080e7          	jalr	-588(ra) # 800039e6 <namex>
}
    80003c3a:	60a2                	ld	ra,8(sp)
    80003c3c:	6402                	ld	s0,0(sp)
    80003c3e:	0141                	addi	sp,sp,16
    80003c40:	8082                	ret

0000000080003c42 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003c42:	7179                	addi	sp,sp,-48
    80003c44:	f406                	sd	ra,40(sp)
    80003c46:	f022                	sd	s0,32(sp)
    80003c48:	ec26                	sd	s1,24(sp)
    80003c4a:	e84a                	sd	s2,16(sp)
    80003c4c:	e44e                	sd	s3,8(sp)
    80003c4e:	1800                	addi	s0,sp,48
    80003c50:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003c52:	0a800993          	li	s3,168
    80003c56:	033507b3          	mul	a5,a0,s3
    80003c5a:	0001f997          	auipc	s3,0x1f
    80003c5e:	d3e98993          	addi	s3,s3,-706 # 80022998 <log>
    80003c62:	99be                	add	s3,s3,a5
    80003c64:	0189a583          	lw	a1,24(s3)
    80003c68:	fffff097          	auipc	ra,0xfffff
    80003c6c:	00e080e7          	jalr	14(ra) # 80002c76 <bread>
    80003c70:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003c72:	02c9a783          	lw	a5,44(s3)
    80003c76:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003c78:	02c9a783          	lw	a5,44(s3)
    80003c7c:	02f05763          	blez	a5,80003caa <write_head+0x68>
    80003c80:	0a800793          	li	a5,168
    80003c84:	02f487b3          	mul	a5,s1,a5
    80003c88:	0001f717          	auipc	a4,0x1f
    80003c8c:	d4070713          	addi	a4,a4,-704 # 800229c8 <log+0x30>
    80003c90:	97ba                	add	a5,a5,a4
    80003c92:	06450693          	addi	a3,a0,100
    80003c96:	4701                	li	a4,0
    80003c98:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003c9a:	4390                	lw	a2,0(a5)
    80003c9c:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003c9e:	2705                	addiw	a4,a4,1
    80003ca0:	0791                	addi	a5,a5,4
    80003ca2:	0691                	addi	a3,a3,4
    80003ca4:	55d0                	lw	a2,44(a1)
    80003ca6:	fec74ae3          	blt	a4,a2,80003c9a <write_head+0x58>
  }
  bwrite(buf);
    80003caa:	854a                	mv	a0,s2
    80003cac:	fffff097          	auipc	ra,0xfffff
    80003cb0:	0be080e7          	jalr	190(ra) # 80002d6a <bwrite>
  brelse(buf);
    80003cb4:	854a                	mv	a0,s2
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	0f4080e7          	jalr	244(ra) # 80002daa <brelse>
}
    80003cbe:	70a2                	ld	ra,40(sp)
    80003cc0:	7402                	ld	s0,32(sp)
    80003cc2:	64e2                	ld	s1,24(sp)
    80003cc4:	6942                	ld	s2,16(sp)
    80003cc6:	69a2                	ld	s3,8(sp)
    80003cc8:	6145                	addi	sp,sp,48
    80003cca:	8082                	ret

0000000080003ccc <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003ccc:	0a800793          	li	a5,168
    80003cd0:	02f50733          	mul	a4,a0,a5
    80003cd4:	0001f797          	auipc	a5,0x1f
    80003cd8:	cc478793          	addi	a5,a5,-828 # 80022998 <log>
    80003cdc:	97ba                	add	a5,a5,a4
    80003cde:	57dc                	lw	a5,44(a5)
    80003ce0:	0af05663          	blez	a5,80003d8c <write_log+0xc0>
{
    80003ce4:	7139                	addi	sp,sp,-64
    80003ce6:	fc06                	sd	ra,56(sp)
    80003ce8:	f822                	sd	s0,48(sp)
    80003cea:	f426                	sd	s1,40(sp)
    80003cec:	f04a                	sd	s2,32(sp)
    80003cee:	ec4e                	sd	s3,24(sp)
    80003cf0:	e852                	sd	s4,16(sp)
    80003cf2:	e456                	sd	s5,8(sp)
    80003cf4:	e05a                	sd	s6,0(sp)
    80003cf6:	0080                	addi	s0,sp,64
    80003cf8:	0001f797          	auipc	a5,0x1f
    80003cfc:	cd078793          	addi	a5,a5,-816 # 800229c8 <log+0x30>
    80003d00:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003d04:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003d06:	00050b1b          	sext.w	s6,a0
    80003d0a:	0001fa97          	auipc	s5,0x1f
    80003d0e:	c8ea8a93          	addi	s5,s5,-882 # 80022998 <log>
    80003d12:	9aba                	add	s5,s5,a4
    80003d14:	018aa583          	lw	a1,24(s5)
    80003d18:	013585bb          	addw	a1,a1,s3
    80003d1c:	2585                	addiw	a1,a1,1
    80003d1e:	855a                	mv	a0,s6
    80003d20:	fffff097          	auipc	ra,0xfffff
    80003d24:	f56080e7          	jalr	-170(ra) # 80002c76 <bread>
    80003d28:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003d2a:	000a2583          	lw	a1,0(s4)
    80003d2e:	855a                	mv	a0,s6
    80003d30:	fffff097          	auipc	ra,0xfffff
    80003d34:	f46080e7          	jalr	-186(ra) # 80002c76 <bread>
    80003d38:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003d3a:	40000613          	li	a2,1024
    80003d3e:	06050593          	addi	a1,a0,96
    80003d42:	06048513          	addi	a0,s1,96
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	ec8080e7          	jalr	-312(ra) # 80000c0e <memmove>
    bwrite(to);  // write the log
    80003d4e:	8526                	mv	a0,s1
    80003d50:	fffff097          	auipc	ra,0xfffff
    80003d54:	01a080e7          	jalr	26(ra) # 80002d6a <bwrite>
    brelse(from);
    80003d58:	854a                	mv	a0,s2
    80003d5a:	fffff097          	auipc	ra,0xfffff
    80003d5e:	050080e7          	jalr	80(ra) # 80002daa <brelse>
    brelse(to);
    80003d62:	8526                	mv	a0,s1
    80003d64:	fffff097          	auipc	ra,0xfffff
    80003d68:	046080e7          	jalr	70(ra) # 80002daa <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003d6c:	2985                	addiw	s3,s3,1
    80003d6e:	0a11                	addi	s4,s4,4
    80003d70:	02caa783          	lw	a5,44(s5)
    80003d74:	faf9c0e3          	blt	s3,a5,80003d14 <write_log+0x48>
  }
}
    80003d78:	70e2                	ld	ra,56(sp)
    80003d7a:	7442                	ld	s0,48(sp)
    80003d7c:	74a2                	ld	s1,40(sp)
    80003d7e:	7902                	ld	s2,32(sp)
    80003d80:	69e2                	ld	s3,24(sp)
    80003d82:	6a42                	ld	s4,16(sp)
    80003d84:	6aa2                	ld	s5,8(sp)
    80003d86:	6b02                	ld	s6,0(sp)
    80003d88:	6121                	addi	sp,sp,64
    80003d8a:	8082                	ret
    80003d8c:	8082                	ret

0000000080003d8e <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003d8e:	0a800793          	li	a5,168
    80003d92:	02f50733          	mul	a4,a0,a5
    80003d96:	0001f797          	auipc	a5,0x1f
    80003d9a:	c0278793          	addi	a5,a5,-1022 # 80022998 <log>
    80003d9e:	97ba                	add	a5,a5,a4
    80003da0:	57dc                	lw	a5,44(a5)
    80003da2:	0af05b63          	blez	a5,80003e58 <install_trans+0xca>
{
    80003da6:	7139                	addi	sp,sp,-64
    80003da8:	fc06                	sd	ra,56(sp)
    80003daa:	f822                	sd	s0,48(sp)
    80003dac:	f426                	sd	s1,40(sp)
    80003dae:	f04a                	sd	s2,32(sp)
    80003db0:	ec4e                	sd	s3,24(sp)
    80003db2:	e852                	sd	s4,16(sp)
    80003db4:	e456                	sd	s5,8(sp)
    80003db6:	e05a                	sd	s6,0(sp)
    80003db8:	0080                	addi	s0,sp,64
    80003dba:	0001f797          	auipc	a5,0x1f
    80003dbe:	c0e78793          	addi	a5,a5,-1010 # 800229c8 <log+0x30>
    80003dc2:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003dc6:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003dc8:	00050b1b          	sext.w	s6,a0
    80003dcc:	0001fa97          	auipc	s5,0x1f
    80003dd0:	bcca8a93          	addi	s5,s5,-1076 # 80022998 <log>
    80003dd4:	9aba                	add	s5,s5,a4
    80003dd6:	018aa583          	lw	a1,24(s5)
    80003dda:	013585bb          	addw	a1,a1,s3
    80003dde:	2585                	addiw	a1,a1,1
    80003de0:	855a                	mv	a0,s6
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	e94080e7          	jalr	-364(ra) # 80002c76 <bread>
    80003dea:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003dec:	000a2583          	lw	a1,0(s4)
    80003df0:	855a                	mv	a0,s6
    80003df2:	fffff097          	auipc	ra,0xfffff
    80003df6:	e84080e7          	jalr	-380(ra) # 80002c76 <bread>
    80003dfa:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003dfc:	40000613          	li	a2,1024
    80003e00:	06090593          	addi	a1,s2,96
    80003e04:	06050513          	addi	a0,a0,96
    80003e08:	ffffd097          	auipc	ra,0xffffd
    80003e0c:	e06080e7          	jalr	-506(ra) # 80000c0e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e10:	8526                	mv	a0,s1
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	f58080e7          	jalr	-168(ra) # 80002d6a <bwrite>
    bunpin(dbuf);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	fffff097          	auipc	ra,0xfffff
    80003e20:	068080e7          	jalr	104(ra) # 80002e84 <bunpin>
    brelse(lbuf);
    80003e24:	854a                	mv	a0,s2
    80003e26:	fffff097          	auipc	ra,0xfffff
    80003e2a:	f84080e7          	jalr	-124(ra) # 80002daa <brelse>
    brelse(dbuf);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	fffff097          	auipc	ra,0xfffff
    80003e34:	f7a080e7          	jalr	-134(ra) # 80002daa <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003e38:	2985                	addiw	s3,s3,1
    80003e3a:	0a11                	addi	s4,s4,4
    80003e3c:	02caa783          	lw	a5,44(s5)
    80003e40:	f8f9cbe3          	blt	s3,a5,80003dd6 <install_trans+0x48>
}
    80003e44:	70e2                	ld	ra,56(sp)
    80003e46:	7442                	ld	s0,48(sp)
    80003e48:	74a2                	ld	s1,40(sp)
    80003e4a:	7902                	ld	s2,32(sp)
    80003e4c:	69e2                	ld	s3,24(sp)
    80003e4e:	6a42                	ld	s4,16(sp)
    80003e50:	6aa2                	ld	s5,8(sp)
    80003e52:	6b02                	ld	s6,0(sp)
    80003e54:	6121                	addi	sp,sp,64
    80003e56:	8082                	ret
    80003e58:	8082                	ret

0000000080003e5a <initlog>:
{
    80003e5a:	7179                	addi	sp,sp,-48
    80003e5c:	f406                	sd	ra,40(sp)
    80003e5e:	f022                	sd	s0,32(sp)
    80003e60:	ec26                	sd	s1,24(sp)
    80003e62:	e84a                	sd	s2,16(sp)
    80003e64:	e44e                	sd	s3,8(sp)
    80003e66:	e052                	sd	s4,0(sp)
    80003e68:	1800                	addi	s0,sp,48
    80003e6a:	84aa                	mv	s1,a0
    80003e6c:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80003e6e:	0a800713          	li	a4,168
    80003e72:	02e509b3          	mul	s3,a0,a4
    80003e76:	0001f917          	auipc	s2,0x1f
    80003e7a:	b2290913          	addi	s2,s2,-1246 # 80022998 <log>
    80003e7e:	994e                	add	s2,s2,s3
    80003e80:	00004597          	auipc	a1,0x4
    80003e84:	76858593          	addi	a1,a1,1896 # 800085e8 <userret+0x558>
    80003e88:	854a                	mv	a0,s2
    80003e8a:	ffffd097          	auipc	ra,0xffffd
    80003e8e:	b4e080e7          	jalr	-1202(ra) # 800009d8 <initlock>
  log[dev].start = sb->logstart;
    80003e92:	014a2583          	lw	a1,20(s4)
    80003e96:	00b92c23          	sw	a1,24(s2)
  log[dev].size = sb->nlog;
    80003e9a:	010a2783          	lw	a5,16(s4)
    80003e9e:	00f92e23          	sw	a5,28(s2)
  log[dev].dev = dev;
    80003ea2:	02992423          	sw	s1,40(s2)
  struct buf *buf = bread(dev, log[dev].start);
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	fffff097          	auipc	ra,0xfffff
    80003eac:	dce080e7          	jalr	-562(ra) # 80002c76 <bread>
  log[dev].lh.n = lh->n;
    80003eb0:	513c                	lw	a5,96(a0)
    80003eb2:	02f92623          	sw	a5,44(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003eb6:	02f05663          	blez	a5,80003ee2 <initlog+0x88>
    80003eba:	06450693          	addi	a3,a0,100
    80003ebe:	0001f717          	auipc	a4,0x1f
    80003ec2:	b0a70713          	addi	a4,a4,-1270 # 800229c8 <log+0x30>
    80003ec6:	974e                	add	a4,a4,s3
    80003ec8:	37fd                	addiw	a5,a5,-1
    80003eca:	1782                	slli	a5,a5,0x20
    80003ecc:	9381                	srli	a5,a5,0x20
    80003ece:	078a                	slli	a5,a5,0x2
    80003ed0:	06850613          	addi	a2,a0,104
    80003ed4:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    80003ed6:	4290                	lw	a2,0(a3)
    80003ed8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003eda:	0691                	addi	a3,a3,4
    80003edc:	0711                	addi	a4,a4,4
    80003ede:	fef69ce3          	bne	a3,a5,80003ed6 <initlog+0x7c>
  brelse(buf);
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	ec8080e7          	jalr	-312(ra) # 80002daa <brelse>
  install_trans(dev); // if committed, copy from log to disk
    80003eea:	8526                	mv	a0,s1
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	ea2080e7          	jalr	-350(ra) # 80003d8e <install_trans>
  log[dev].lh.n = 0;
    80003ef4:	0a800793          	li	a5,168
    80003ef8:	02f48733          	mul	a4,s1,a5
    80003efc:	0001f797          	auipc	a5,0x1f
    80003f00:	a9c78793          	addi	a5,a5,-1380 # 80022998 <log>
    80003f04:	97ba                	add	a5,a5,a4
    80003f06:	0207a623          	sw	zero,44(a5)
  write_head(dev); // clear the log
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	00000097          	auipc	ra,0x0
    80003f10:	d36080e7          	jalr	-714(ra) # 80003c42 <write_head>
}
    80003f14:	70a2                	ld	ra,40(sp)
    80003f16:	7402                	ld	s0,32(sp)
    80003f18:	64e2                	ld	s1,24(sp)
    80003f1a:	6942                	ld	s2,16(sp)
    80003f1c:	69a2                	ld	s3,8(sp)
    80003f1e:	6a02                	ld	s4,0(sp)
    80003f20:	6145                	addi	sp,sp,48
    80003f22:	8082                	ret

0000000080003f24 <begin_op>:
{
    80003f24:	7139                	addi	sp,sp,-64
    80003f26:	fc06                	sd	ra,56(sp)
    80003f28:	f822                	sd	s0,48(sp)
    80003f2a:	f426                	sd	s1,40(sp)
    80003f2c:	f04a                	sd	s2,32(sp)
    80003f2e:	ec4e                	sd	s3,24(sp)
    80003f30:	e852                	sd	s4,16(sp)
    80003f32:	e456                	sd	s5,8(sp)
    80003f34:	0080                	addi	s0,sp,64
    80003f36:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80003f38:	0a800913          	li	s2,168
    80003f3c:	032507b3          	mul	a5,a0,s2
    80003f40:	0001f917          	auipc	s2,0x1f
    80003f44:	a5890913          	addi	s2,s2,-1448 # 80022998 <log>
    80003f48:	993e                	add	s2,s2,a5
    80003f4a:	854a                	mv	a0,s2
    80003f4c:	ffffd097          	auipc	ra,0xffffd
    80003f50:	b9e080e7          	jalr	-1122(ra) # 80000aea <acquire>
    if(log[dev].committing){
    80003f54:	0001f997          	auipc	s3,0x1f
    80003f58:	a4498993          	addi	s3,s3,-1468 # 80022998 <log>
    80003f5c:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f5e:	4a79                	li	s4,30
    80003f60:	a039                	j	80003f6e <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80003f62:	85ca                	mv	a1,s2
    80003f64:	854e                	mv	a0,s3
    80003f66:	ffffe097          	auipc	ra,0xffffe
    80003f6a:	0f8080e7          	jalr	248(ra) # 8000205e <sleep>
    if(log[dev].committing){
    80003f6e:	50dc                	lw	a5,36(s1)
    80003f70:	fbed                	bnez	a5,80003f62 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f72:	509c                	lw	a5,32(s1)
    80003f74:	0017871b          	addiw	a4,a5,1
    80003f78:	0007069b          	sext.w	a3,a4
    80003f7c:	0027179b          	slliw	a5,a4,0x2
    80003f80:	9fb9                	addw	a5,a5,a4
    80003f82:	0017979b          	slliw	a5,a5,0x1
    80003f86:	54d8                	lw	a4,44(s1)
    80003f88:	9fb9                	addw	a5,a5,a4
    80003f8a:	00fa5963          	bge	s4,a5,80003f9c <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    80003f8e:	85ca                	mv	a1,s2
    80003f90:	854e                	mv	a0,s3
    80003f92:	ffffe097          	auipc	ra,0xffffe
    80003f96:	0cc080e7          	jalr	204(ra) # 8000205e <sleep>
    80003f9a:	bfd1                	j	80003f6e <begin_op+0x4a>
      log[dev].outstanding += 1;
    80003f9c:	0a800513          	li	a0,168
    80003fa0:	02aa8ab3          	mul	s5,s5,a0
    80003fa4:	0001f797          	auipc	a5,0x1f
    80003fa8:	9f478793          	addi	a5,a5,-1548 # 80022998 <log>
    80003fac:	9abe                	add	s5,s5,a5
    80003fae:	02daa023          	sw	a3,32(s5)
      release(&log[dev].lock);
    80003fb2:	854a                	mv	a0,s2
    80003fb4:	ffffd097          	auipc	ra,0xffffd
    80003fb8:	b9e080e7          	jalr	-1122(ra) # 80000b52 <release>
}
    80003fbc:	70e2                	ld	ra,56(sp)
    80003fbe:	7442                	ld	s0,48(sp)
    80003fc0:	74a2                	ld	s1,40(sp)
    80003fc2:	7902                	ld	s2,32(sp)
    80003fc4:	69e2                	ld	s3,24(sp)
    80003fc6:	6a42                	ld	s4,16(sp)
    80003fc8:	6aa2                	ld	s5,8(sp)
    80003fca:	6121                	addi	sp,sp,64
    80003fcc:	8082                	ret

0000000080003fce <end_op>:
{
    80003fce:	7179                	addi	sp,sp,-48
    80003fd0:	f406                	sd	ra,40(sp)
    80003fd2:	f022                	sd	s0,32(sp)
    80003fd4:	ec26                	sd	s1,24(sp)
    80003fd6:	e84a                	sd	s2,16(sp)
    80003fd8:	e44e                	sd	s3,8(sp)
    80003fda:	1800                	addi	s0,sp,48
    80003fdc:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    80003fde:	0a800493          	li	s1,168
    80003fe2:	029507b3          	mul	a5,a0,s1
    80003fe6:	0001f497          	auipc	s1,0x1f
    80003fea:	9b248493          	addi	s1,s1,-1614 # 80022998 <log>
    80003fee:	94be                	add	s1,s1,a5
    80003ff0:	8526                	mv	a0,s1
    80003ff2:	ffffd097          	auipc	ra,0xffffd
    80003ff6:	af8080e7          	jalr	-1288(ra) # 80000aea <acquire>
  log[dev].outstanding -= 1;
    80003ffa:	509c                	lw	a5,32(s1)
    80003ffc:	37fd                	addiw	a5,a5,-1
    80003ffe:	0007871b          	sext.w	a4,a5
    80004002:	d09c                	sw	a5,32(s1)
  if(log[dev].committing)
    80004004:	50dc                	lw	a5,36(s1)
    80004006:	e3ad                	bnez	a5,80004068 <end_op+0x9a>
  if(log[dev].outstanding == 0){
    80004008:	eb25                	bnez	a4,80004078 <end_op+0xaa>
    log[dev].committing = 1;
    8000400a:	0a800993          	li	s3,168
    8000400e:	033907b3          	mul	a5,s2,s3
    80004012:	0001f997          	auipc	s3,0x1f
    80004016:	98698993          	addi	s3,s3,-1658 # 80022998 <log>
    8000401a:	99be                	add	s3,s3,a5
    8000401c:	4785                	li	a5,1
    8000401e:	02f9a223          	sw	a5,36(s3)
  release(&log[dev].lock);
    80004022:	8526                	mv	a0,s1
    80004024:	ffffd097          	auipc	ra,0xffffd
    80004028:	b2e080e7          	jalr	-1234(ra) # 80000b52 <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    8000402c:	02c9a783          	lw	a5,44(s3)
    80004030:	06f04863          	bgtz	a5,800040a0 <end_op+0xd2>
    acquire(&log[dev].lock);
    80004034:	8526                	mv	a0,s1
    80004036:	ffffd097          	auipc	ra,0xffffd
    8000403a:	ab4080e7          	jalr	-1356(ra) # 80000aea <acquire>
    log[dev].committing = 0;
    8000403e:	0001f517          	auipc	a0,0x1f
    80004042:	95a50513          	addi	a0,a0,-1702 # 80022998 <log>
    80004046:	0a800793          	li	a5,168
    8000404a:	02f90933          	mul	s2,s2,a5
    8000404e:	992a                	add	s2,s2,a0
    80004050:	02092223          	sw	zero,36(s2)
    wakeup(&log);
    80004054:	ffffe097          	auipc	ra,0xffffe
    80004058:	190080e7          	jalr	400(ra) # 800021e4 <wakeup>
    release(&log[dev].lock);
    8000405c:	8526                	mv	a0,s1
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	af4080e7          	jalr	-1292(ra) # 80000b52 <release>
}
    80004066:	a035                	j	80004092 <end_op+0xc4>
    panic("log[dev].committing");
    80004068:	00004517          	auipc	a0,0x4
    8000406c:	58850513          	addi	a0,a0,1416 # 800085f0 <userret+0x560>
    80004070:	ffffc097          	auipc	ra,0xffffc
    80004074:	4de080e7          	jalr	1246(ra) # 8000054e <panic>
    wakeup(&log);
    80004078:	0001f517          	auipc	a0,0x1f
    8000407c:	92050513          	addi	a0,a0,-1760 # 80022998 <log>
    80004080:	ffffe097          	auipc	ra,0xffffe
    80004084:	164080e7          	jalr	356(ra) # 800021e4 <wakeup>
  release(&log[dev].lock);
    80004088:	8526                	mv	a0,s1
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	ac8080e7          	jalr	-1336(ra) # 80000b52 <release>
}
    80004092:	70a2                	ld	ra,40(sp)
    80004094:	7402                	ld	s0,32(sp)
    80004096:	64e2                	ld	s1,24(sp)
    80004098:	6942                	ld	s2,16(sp)
    8000409a:	69a2                	ld	s3,8(sp)
    8000409c:	6145                	addi	sp,sp,48
    8000409e:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    800040a0:	854a                	mv	a0,s2
    800040a2:	00000097          	auipc	ra,0x0
    800040a6:	c2a080e7          	jalr	-982(ra) # 80003ccc <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    800040aa:	854a                	mv	a0,s2
    800040ac:	00000097          	auipc	ra,0x0
    800040b0:	b96080e7          	jalr	-1130(ra) # 80003c42 <write_head>
    install_trans(dev); // Now install writes to home locations
    800040b4:	854a                	mv	a0,s2
    800040b6:	00000097          	auipc	ra,0x0
    800040ba:	cd8080e7          	jalr	-808(ra) # 80003d8e <install_trans>
    log[dev].lh.n = 0;
    800040be:	0a800793          	li	a5,168
    800040c2:	02f90733          	mul	a4,s2,a5
    800040c6:	0001f797          	auipc	a5,0x1f
    800040ca:	8d278793          	addi	a5,a5,-1838 # 80022998 <log>
    800040ce:	97ba                	add	a5,a5,a4
    800040d0:	0207a623          	sw	zero,44(a5)
    write_head(dev);    // Erase the transaction from the log
    800040d4:	854a                	mv	a0,s2
    800040d6:	00000097          	auipc	ra,0x0
    800040da:	b6c080e7          	jalr	-1172(ra) # 80003c42 <write_head>
    800040de:	bf99                	j	80004034 <end_op+0x66>

00000000800040e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040e0:	7179                	addi	sp,sp,-48
    800040e2:	f406                	sd	ra,40(sp)
    800040e4:	f022                	sd	s0,32(sp)
    800040e6:	ec26                	sd	s1,24(sp)
    800040e8:	e84a                	sd	s2,16(sp)
    800040ea:	e44e                	sd	s3,8(sp)
    800040ec:	e052                	sd	s4,0(sp)
    800040ee:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    800040f0:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    800040f4:	0a800793          	li	a5,168
    800040f8:	02f90733          	mul	a4,s2,a5
    800040fc:	0001f797          	auipc	a5,0x1f
    80004100:	89c78793          	addi	a5,a5,-1892 # 80022998 <log>
    80004104:	97ba                	add	a5,a5,a4
    80004106:	57d4                	lw	a3,44(a5)
    80004108:	47f5                	li	a5,29
    8000410a:	0ad7cc63          	blt	a5,a3,800041c2 <log_write+0xe2>
    8000410e:	89aa                	mv	s3,a0
    80004110:	0001f797          	auipc	a5,0x1f
    80004114:	88878793          	addi	a5,a5,-1912 # 80022998 <log>
    80004118:	97ba                	add	a5,a5,a4
    8000411a:	4fdc                	lw	a5,28(a5)
    8000411c:	37fd                	addiw	a5,a5,-1
    8000411e:	0af6d263          	bge	a3,a5,800041c2 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004122:	0a800793          	li	a5,168
    80004126:	02f90733          	mul	a4,s2,a5
    8000412a:	0001f797          	auipc	a5,0x1f
    8000412e:	86e78793          	addi	a5,a5,-1938 # 80022998 <log>
    80004132:	97ba                	add	a5,a5,a4
    80004134:	539c                	lw	a5,32(a5)
    80004136:	08f05e63          	blez	a5,800041d2 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    8000413a:	0a800793          	li	a5,168
    8000413e:	02f904b3          	mul	s1,s2,a5
    80004142:	0001fa17          	auipc	s4,0x1f
    80004146:	856a0a13          	addi	s4,s4,-1962 # 80022998 <log>
    8000414a:	9a26                	add	s4,s4,s1
    8000414c:	8552                	mv	a0,s4
    8000414e:	ffffd097          	auipc	ra,0xffffd
    80004152:	99c080e7          	jalr	-1636(ra) # 80000aea <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004156:	02ca2603          	lw	a2,44(s4)
    8000415a:	08c05463          	blez	a2,800041e2 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000415e:	00c9a583          	lw	a1,12(s3)
    80004162:	0001f797          	auipc	a5,0x1f
    80004166:	86678793          	addi	a5,a5,-1946 # 800229c8 <log+0x30>
    8000416a:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000416c:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000416e:	4394                	lw	a3,0(a5)
    80004170:	06b68a63          	beq	a3,a1,800041e4 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004174:	2705                	addiw	a4,a4,1
    80004176:	0791                	addi	a5,a5,4
    80004178:	fec71be3          	bne	a4,a2,8000416e <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000417c:	02a00793          	li	a5,42
    80004180:	02f907b3          	mul	a5,s2,a5
    80004184:	97b2                	add	a5,a5,a2
    80004186:	07a1                	addi	a5,a5,8
    80004188:	078a                	slli	a5,a5,0x2
    8000418a:	0001f717          	auipc	a4,0x1f
    8000418e:	80e70713          	addi	a4,a4,-2034 # 80022998 <log>
    80004192:	97ba                	add	a5,a5,a4
    80004194:	00c9a703          	lw	a4,12(s3)
    80004198:	cb98                	sw	a4,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    8000419a:	854e                	mv	a0,s3
    8000419c:	fffff097          	auipc	ra,0xfffff
    800041a0:	cac080e7          	jalr	-852(ra) # 80002e48 <bpin>
    log[dev].lh.n++;
    800041a4:	0a800793          	li	a5,168
    800041a8:	02f90933          	mul	s2,s2,a5
    800041ac:	0001e797          	auipc	a5,0x1e
    800041b0:	7ec78793          	addi	a5,a5,2028 # 80022998 <log>
    800041b4:	993e                	add	s2,s2,a5
    800041b6:	02c92783          	lw	a5,44(s2)
    800041ba:	2785                	addiw	a5,a5,1
    800041bc:	02f92623          	sw	a5,44(s2)
    800041c0:	a099                	j	80004206 <log_write+0x126>
    panic("too big a transaction");
    800041c2:	00004517          	auipc	a0,0x4
    800041c6:	44650513          	addi	a0,a0,1094 # 80008608 <userret+0x578>
    800041ca:	ffffc097          	auipc	ra,0xffffc
    800041ce:	384080e7          	jalr	900(ra) # 8000054e <panic>
    panic("log_write outside of trans");
    800041d2:	00004517          	auipc	a0,0x4
    800041d6:	44e50513          	addi	a0,a0,1102 # 80008620 <userret+0x590>
    800041da:	ffffc097          	auipc	ra,0xffffc
    800041de:	374080e7          	jalr	884(ra) # 8000054e <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    800041e2:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    800041e4:	02a00793          	li	a5,42
    800041e8:	02f907b3          	mul	a5,s2,a5
    800041ec:	97ba                	add	a5,a5,a4
    800041ee:	07a1                	addi	a5,a5,8
    800041f0:	078a                	slli	a5,a5,0x2
    800041f2:	0001e697          	auipc	a3,0x1e
    800041f6:	7a668693          	addi	a3,a3,1958 # 80022998 <log>
    800041fa:	97b6                	add	a5,a5,a3
    800041fc:	00c9a683          	lw	a3,12(s3)
    80004200:	cb94                	sw	a3,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    80004202:	f8e60ce3          	beq	a2,a4,8000419a <log_write+0xba>
  }
  release(&log[dev].lock);
    80004206:	8552                	mv	a0,s4
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	94a080e7          	jalr	-1718(ra) # 80000b52 <release>
}
    80004210:	70a2                	ld	ra,40(sp)
    80004212:	7402                	ld	s0,32(sp)
    80004214:	64e2                	ld	s1,24(sp)
    80004216:	6942                	ld	s2,16(sp)
    80004218:	69a2                	ld	s3,8(sp)
    8000421a:	6a02                	ld	s4,0(sp)
    8000421c:	6145                	addi	sp,sp,48
    8000421e:	8082                	ret

0000000080004220 <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    80004220:	7179                	addi	sp,sp,-48
    80004222:	f406                	sd	ra,40(sp)
    80004224:	f022                	sd	s0,32(sp)
    80004226:	ec26                	sd	s1,24(sp)
    80004228:	e84a                	sd	s2,16(sp)
    8000422a:	e44e                	sd	s3,8(sp)
    8000422c:	1800                	addi	s0,sp,48
    8000422e:	84aa                	mv	s1,a0
    80004230:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    80004232:	0a800913          	li	s2,168
    80004236:	032507b3          	mul	a5,a0,s2
    8000423a:	0001e917          	auipc	s2,0x1e
    8000423e:	75e90913          	addi	s2,s2,1886 # 80022998 <log>
    80004242:	993e                	add	s2,s2,a5
    80004244:	854a                	mv	a0,s2
    80004246:	ffffd097          	auipc	ra,0xffffd
    8000424a:	8a4080e7          	jalr	-1884(ra) # 80000aea <acquire>

  if (dev < 0 || dev >= NDISK)
    8000424e:	0004871b          	sext.w	a4,s1
    80004252:	4785                	li	a5,1
    80004254:	0ae7e063          	bltu	a5,a4,800042f4 <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    80004258:	0a800793          	li	a5,168
    8000425c:	02f48733          	mul	a4,s1,a5
    80004260:	0001e797          	auipc	a5,0x1e
    80004264:	73878793          	addi	a5,a5,1848 # 80022998 <log>
    80004268:	97ba                	add	a5,a5,a4
    8000426a:	539c                	lw	a5,32(a5)
    8000426c:	cfc1                	beqz	a5,80004304 <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    8000426e:	37fd                	addiw	a5,a5,-1
    80004270:	0007861b          	sext.w	a2,a5
    80004274:	0a800713          	li	a4,168
    80004278:	02e486b3          	mul	a3,s1,a4
    8000427c:	0001e717          	auipc	a4,0x1e
    80004280:	71c70713          	addi	a4,a4,1820 # 80022998 <log>
    80004284:	9736                	add	a4,a4,a3
    80004286:	d31c                	sw	a5,32(a4)
  if(log[dev].committing)
    80004288:	535c                	lw	a5,36(a4)
    8000428a:	e7c9                	bnez	a5,80004314 <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    8000428c:	ee41                	bnez	a2,80004324 <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    8000428e:	0a800793          	li	a5,168
    80004292:	02f48733          	mul	a4,s1,a5
    80004296:	0001e797          	auipc	a5,0x1e
    8000429a:	70278793          	addi	a5,a5,1794 # 80022998 <log>
    8000429e:	97ba                	add	a5,a5,a4
    800042a0:	4705                	li	a4,1
    800042a2:	d3d8                	sw	a4,36(a5)
  }
  
  release(&log[dev].lock);
    800042a4:	854a                	mv	a0,s2
    800042a6:	ffffd097          	auipc	ra,0xffffd
    800042aa:	8ac080e7          	jalr	-1876(ra) # 80000b52 <release>

  if(docommit & do_commit){
    800042ae:	0019f993          	andi	s3,s3,1
    800042b2:	06098e63          	beqz	s3,8000432e <crash_op+0x10e>
    printf("crash_op: commit\n");
    800042b6:	00004517          	auipc	a0,0x4
    800042ba:	3ba50513          	addi	a0,a0,954 # 80008670 <userret+0x5e0>
    800042be:	ffffc097          	auipc	ra,0xffffc
    800042c2:	2da080e7          	jalr	730(ra) # 80000598 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    800042c6:	0a800793          	li	a5,168
    800042ca:	02f48733          	mul	a4,s1,a5
    800042ce:	0001e797          	auipc	a5,0x1e
    800042d2:	6ca78793          	addi	a5,a5,1738 # 80022998 <log>
    800042d6:	97ba                	add	a5,a5,a4
    800042d8:	57dc                	lw	a5,44(a5)
    800042da:	04f05a63          	blez	a5,8000432e <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    800042de:	8526                	mv	a0,s1
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	9ec080e7          	jalr	-1556(ra) # 80003ccc <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    800042e8:	8526                	mv	a0,s1
    800042ea:	00000097          	auipc	ra,0x0
    800042ee:	958080e7          	jalr	-1704(ra) # 80003c42 <write_head>
    800042f2:	a835                	j	8000432e <crash_op+0x10e>
    panic("end_op: invalid disk");
    800042f4:	00004517          	auipc	a0,0x4
    800042f8:	34c50513          	addi	a0,a0,844 # 80008640 <userret+0x5b0>
    800042fc:	ffffc097          	auipc	ra,0xffffc
    80004300:	252080e7          	jalr	594(ra) # 8000054e <panic>
    panic("end_op: already closed");
    80004304:	00004517          	auipc	a0,0x4
    80004308:	35450513          	addi	a0,a0,852 # 80008658 <userret+0x5c8>
    8000430c:	ffffc097          	auipc	ra,0xffffc
    80004310:	242080e7          	jalr	578(ra) # 8000054e <panic>
    panic("log[dev].committing");
    80004314:	00004517          	auipc	a0,0x4
    80004318:	2dc50513          	addi	a0,a0,732 # 800085f0 <userret+0x560>
    8000431c:	ffffc097          	auipc	ra,0xffffc
    80004320:	232080e7          	jalr	562(ra) # 8000054e <panic>
  release(&log[dev].lock);
    80004324:	854a                	mv	a0,s2
    80004326:	ffffd097          	auipc	ra,0xffffd
    8000432a:	82c080e7          	jalr	-2004(ra) # 80000b52 <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    8000432e:	00004517          	auipc	a0,0x4
    80004332:	35a50513          	addi	a0,a0,858 # 80008688 <userret+0x5f8>
    80004336:	ffffc097          	auipc	ra,0xffffc
    8000433a:	218080e7          	jalr	536(ra) # 8000054e <panic>

000000008000433e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000433e:	1101                	addi	sp,sp,-32
    80004340:	ec06                	sd	ra,24(sp)
    80004342:	e822                	sd	s0,16(sp)
    80004344:	e426                	sd	s1,8(sp)
    80004346:	e04a                	sd	s2,0(sp)
    80004348:	1000                	addi	s0,sp,32
    8000434a:	84aa                	mv	s1,a0
    8000434c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000434e:	00004597          	auipc	a1,0x4
    80004352:	37a58593          	addi	a1,a1,890 # 800086c8 <userret+0x638>
    80004356:	0521                	addi	a0,a0,8
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	680080e7          	jalr	1664(ra) # 800009d8 <initlock>
  lk->name = name;
    80004360:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004364:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004368:	0204a423          	sw	zero,40(s1)
}
    8000436c:	60e2                	ld	ra,24(sp)
    8000436e:	6442                	ld	s0,16(sp)
    80004370:	64a2                	ld	s1,8(sp)
    80004372:	6902                	ld	s2,0(sp)
    80004374:	6105                	addi	sp,sp,32
    80004376:	8082                	ret

0000000080004378 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004378:	1101                	addi	sp,sp,-32
    8000437a:	ec06                	sd	ra,24(sp)
    8000437c:	e822                	sd	s0,16(sp)
    8000437e:	e426                	sd	s1,8(sp)
    80004380:	e04a                	sd	s2,0(sp)
    80004382:	1000                	addi	s0,sp,32
    80004384:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004386:	00850913          	addi	s2,a0,8
    8000438a:	854a                	mv	a0,s2
    8000438c:	ffffc097          	auipc	ra,0xffffc
    80004390:	75e080e7          	jalr	1886(ra) # 80000aea <acquire>
  while (lk->locked) {
    80004394:	409c                	lw	a5,0(s1)
    80004396:	cb89                	beqz	a5,800043a8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004398:	85ca                	mv	a1,s2
    8000439a:	8526                	mv	a0,s1
    8000439c:	ffffe097          	auipc	ra,0xffffe
    800043a0:	cc2080e7          	jalr	-830(ra) # 8000205e <sleep>
  while (lk->locked) {
    800043a4:	409c                	lw	a5,0(s1)
    800043a6:	fbed                	bnez	a5,80004398 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043a8:	4785                	li	a5,1
    800043aa:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	4a0080e7          	jalr	1184(ra) # 8000184c <myproc>
    800043b4:	5d1c                	lw	a5,56(a0)
    800043b6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043b8:	854a                	mv	a0,s2
    800043ba:	ffffc097          	auipc	ra,0xffffc
    800043be:	798080e7          	jalr	1944(ra) # 80000b52 <release>
}
    800043c2:	60e2                	ld	ra,24(sp)
    800043c4:	6442                	ld	s0,16(sp)
    800043c6:	64a2                	ld	s1,8(sp)
    800043c8:	6902                	ld	s2,0(sp)
    800043ca:	6105                	addi	sp,sp,32
    800043cc:	8082                	ret

00000000800043ce <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043ce:	1101                	addi	sp,sp,-32
    800043d0:	ec06                	sd	ra,24(sp)
    800043d2:	e822                	sd	s0,16(sp)
    800043d4:	e426                	sd	s1,8(sp)
    800043d6:	e04a                	sd	s2,0(sp)
    800043d8:	1000                	addi	s0,sp,32
    800043da:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043dc:	00850913          	addi	s2,a0,8
    800043e0:	854a                	mv	a0,s2
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	708080e7          	jalr	1800(ra) # 80000aea <acquire>
  lk->locked = 0;
    800043ea:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043ee:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043f2:	8526                	mv	a0,s1
    800043f4:	ffffe097          	auipc	ra,0xffffe
    800043f8:	df0080e7          	jalr	-528(ra) # 800021e4 <wakeup>
  release(&lk->lk);
    800043fc:	854a                	mv	a0,s2
    800043fe:	ffffc097          	auipc	ra,0xffffc
    80004402:	754080e7          	jalr	1876(ra) # 80000b52 <release>
}
    80004406:	60e2                	ld	ra,24(sp)
    80004408:	6442                	ld	s0,16(sp)
    8000440a:	64a2                	ld	s1,8(sp)
    8000440c:	6902                	ld	s2,0(sp)
    8000440e:	6105                	addi	sp,sp,32
    80004410:	8082                	ret

0000000080004412 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004412:	7179                	addi	sp,sp,-48
    80004414:	f406                	sd	ra,40(sp)
    80004416:	f022                	sd	s0,32(sp)
    80004418:	ec26                	sd	s1,24(sp)
    8000441a:	e84a                	sd	s2,16(sp)
    8000441c:	e44e                	sd	s3,8(sp)
    8000441e:	1800                	addi	s0,sp,48
    80004420:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004422:	00850913          	addi	s2,a0,8
    80004426:	854a                	mv	a0,s2
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	6c2080e7          	jalr	1730(ra) # 80000aea <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004430:	409c                	lw	a5,0(s1)
    80004432:	ef99                	bnez	a5,80004450 <holdingsleep+0x3e>
    80004434:	4481                	li	s1,0
  release(&lk->lk);
    80004436:	854a                	mv	a0,s2
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	71a080e7          	jalr	1818(ra) # 80000b52 <release>
  return r;
}
    80004440:	8526                	mv	a0,s1
    80004442:	70a2                	ld	ra,40(sp)
    80004444:	7402                	ld	s0,32(sp)
    80004446:	64e2                	ld	s1,24(sp)
    80004448:	6942                	ld	s2,16(sp)
    8000444a:	69a2                	ld	s3,8(sp)
    8000444c:	6145                	addi	sp,sp,48
    8000444e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004450:	0284a983          	lw	s3,40(s1)
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	3f8080e7          	jalr	1016(ra) # 8000184c <myproc>
    8000445c:	5d04                	lw	s1,56(a0)
    8000445e:	413484b3          	sub	s1,s1,s3
    80004462:	0014b493          	seqz	s1,s1
    80004466:	bfc1                	j	80004436 <holdingsleep+0x24>

0000000080004468 <fileinit>:
  //struct file *file;
} ftable;

void
fileinit(void)
{
    80004468:	1141                	addi	sp,sp,-16
    8000446a:	e406                	sd	ra,8(sp)
    8000446c:	e022                	sd	s0,0(sp)
    8000446e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004470:	00004597          	auipc	a1,0x4
    80004474:	26858593          	addi	a1,a1,616 # 800086d8 <userret+0x648>
    80004478:	0001e517          	auipc	a0,0x1e
    8000447c:	67050513          	addi	a0,a0,1648 # 80022ae8 <ftable>
    80004480:	ffffc097          	auipc	ra,0xffffc
    80004484:	558080e7          	jalr	1368(ra) # 800009d8 <initlock>
}
    80004488:	60a2                	ld	ra,8(sp)
    8000448a:	6402                	ld	s0,0(sp)
    8000448c:	0141                	addi	sp,sp,16
    8000448e:	8082                	ret

0000000080004490 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004490:	1101                	addi	sp,sp,-32
    80004492:	ec06                	sd	ra,24(sp)
    80004494:	e822                	sd	s0,16(sp)
    80004496:	e426                	sd	s1,8(sp)
    80004498:	1000                	addi	s0,sp,32
  struct file *f;
  
  acquire(&ftable.lock);
    8000449a:	0001e517          	auipc	a0,0x1e
    8000449e:	64e50513          	addi	a0,a0,1614 # 80022ae8 <ftable>
    800044a2:	ffffc097          	auipc	ra,0xffffc
    800044a6:	648080e7          	jalr	1608(ra) # 80000aea <acquire>
  f=bd_malloc(sizeof(struct file));
    800044aa:	02800513          	li	a0,40
    800044ae:	00002097          	auipc	ra,0x2
    800044b2:	20a080e7          	jalr	522(ra) # 800066b8 <bd_malloc>
    800044b6:	84aa                	mv	s1,a0
  if(f){
    800044b8:	c905                	beqz	a0,800044e8 <filealloc+0x58>
    memset(f,0,sizeof(struct file));
    800044ba:	02800613          	li	a2,40
    800044be:	4581                	li	a1,0
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	6ee080e7          	jalr	1774(ra) # 80000bae <memset>
    f->ref=1;
    800044c8:	4785                	li	a5,1
    800044ca:	c0dc                	sw	a5,4(s1)
    release(&ftable.lock); //has been used
    800044cc:	0001e517          	auipc	a0,0x1e
    800044d0:	61c50513          	addi	a0,a0,1564 # 80022ae8 <ftable>
    800044d4:	ffffc097          	auipc	ra,0xffffc
    800044d8:	67e080e7          	jalr	1662(ra) # 80000b52 <release>
    return f;
  }
  release(&ftable.lock);//release the unused file table
  return 0;
}
    800044dc:	8526                	mv	a0,s1
    800044de:	60e2                	ld	ra,24(sp)
    800044e0:	6442                	ld	s0,16(sp)
    800044e2:	64a2                	ld	s1,8(sp)
    800044e4:	6105                	addi	sp,sp,32
    800044e6:	8082                	ret
  release(&ftable.lock);//release the unused file table
    800044e8:	0001e517          	auipc	a0,0x1e
    800044ec:	60050513          	addi	a0,a0,1536 # 80022ae8 <ftable>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	662080e7          	jalr	1634(ra) # 80000b52 <release>
  return 0;
    800044f8:	b7d5                	j	800044dc <filealloc+0x4c>

00000000800044fa <filedup>:
//}

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	1000                	addi	s0,sp,32
    80004504:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004506:	0001e517          	auipc	a0,0x1e
    8000450a:	5e250513          	addi	a0,a0,1506 # 80022ae8 <ftable>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	5dc080e7          	jalr	1500(ra) # 80000aea <acquire>
  if(f->ref < 1)
    80004516:	40dc                	lw	a5,4(s1)
    80004518:	02f05263          	blez	a5,8000453c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000451c:	2785                	addiw	a5,a5,1
    8000451e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004520:	0001e517          	auipc	a0,0x1e
    80004524:	5c850513          	addi	a0,a0,1480 # 80022ae8 <ftable>
    80004528:	ffffc097          	auipc	ra,0xffffc
    8000452c:	62a080e7          	jalr	1578(ra) # 80000b52 <release>
  return f;
}
    80004530:	8526                	mv	a0,s1
    80004532:	60e2                	ld	ra,24(sp)
    80004534:	6442                	ld	s0,16(sp)
    80004536:	64a2                	ld	s1,8(sp)
    80004538:	6105                	addi	sp,sp,32
    8000453a:	8082                	ret
    panic("filedup");
    8000453c:	00004517          	auipc	a0,0x4
    80004540:	1a450513          	addi	a0,a0,420 # 800086e0 <userret+0x650>
    80004544:	ffffc097          	auipc	ra,0xffffc
    80004548:	00a080e7          	jalr	10(ra) # 8000054e <panic>

000000008000454c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000454c:	1101                	addi	sp,sp,-32
    8000454e:	ec06                	sd	ra,24(sp)
    80004550:	e822                	sd	s0,16(sp)
    80004552:	e426                	sd	s1,8(sp)
    80004554:	1000                	addi	s0,sp,32
    80004556:	84aa                	mv	s1,a0
  //struct file ff;

  acquire(&ftable.lock);
    80004558:	0001e517          	auipc	a0,0x1e
    8000455c:	59050513          	addi	a0,a0,1424 # 80022ae8 <ftable>
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	58a080e7          	jalr	1418(ra) # 80000aea <acquire>
  if(f->ref < 1)
    80004568:	40dc                	lw	a5,4(s1)
    8000456a:	04f05663          	blez	a5,800045b6 <fileclose+0x6a>
    panic("fileclose");
  if(--f->ref > 0){
    8000456e:	37fd                	addiw	a5,a5,-1
    80004570:	0007871b          	sext.w	a4,a5
    80004574:	c0dc                	sw	a5,4(s1)
    80004576:	04e04863          	bgtz	a4,800045c6 <fileclose+0x7a>
    release(&ftable.lock);
    return;
  }
  //ff = *f;
  f->ref = 0;
    8000457a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000457e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004582:	0001e517          	auipc	a0,0x1e
    80004586:	56650513          	addi	a0,a0,1382 # 80022ae8 <ftable>
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	5c8080e7          	jalr	1480(ra) # 80000b52 <release>

  if(f->type == FD_PIPE){
    80004592:	409c                	lw	a5,0(s1)
    80004594:	4705                	li	a4,1
    80004596:	04e78163          	beq	a5,a4,800045d8 <fileclose+0x8c>
    pipeclose(f->pipe, f->writable);
  } else if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000459a:	37f9                	addiw	a5,a5,-2
    8000459c:	4705                	li	a4,1
    8000459e:	04f77563          	bgeu	a4,a5,800045e8 <fileclose+0x9c>
    begin_op(f->ip->dev);
    iput(f->ip);
    end_op(f->ip->dev);
  }
  bd_free(f);
    800045a2:	8526                	mv	a0,s1
    800045a4:	00002097          	auipc	ra,0x2
    800045a8:	300080e7          	jalr	768(ra) # 800068a4 <bd_free>
}
    800045ac:	60e2                	ld	ra,24(sp)
    800045ae:	6442                	ld	s0,16(sp)
    800045b0:	64a2                	ld	s1,8(sp)
    800045b2:	6105                	addi	sp,sp,32
    800045b4:	8082                	ret
    panic("fileclose");
    800045b6:	00004517          	auipc	a0,0x4
    800045ba:	13250513          	addi	a0,a0,306 # 800086e8 <userret+0x658>
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	f90080e7          	jalr	-112(ra) # 8000054e <panic>
    release(&ftable.lock);
    800045c6:	0001e517          	auipc	a0,0x1e
    800045ca:	52250513          	addi	a0,a0,1314 # 80022ae8 <ftable>
    800045ce:	ffffc097          	auipc	ra,0xffffc
    800045d2:	584080e7          	jalr	1412(ra) # 80000b52 <release>
    return;
    800045d6:	bfd9                	j	800045ac <fileclose+0x60>
    pipeclose(f->pipe, f->writable);
    800045d8:	0094c583          	lbu	a1,9(s1)
    800045dc:	6888                	ld	a0,16(s1)
    800045de:	00000097          	auipc	ra,0x0
    800045e2:	36c080e7          	jalr	876(ra) # 8000494a <pipeclose>
    800045e6:	bf75                	j	800045a2 <fileclose+0x56>
    begin_op(f->ip->dev);
    800045e8:	6c9c                	ld	a5,24(s1)
    800045ea:	4388                	lw	a0,0(a5)
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	938080e7          	jalr	-1736(ra) # 80003f24 <begin_op>
    iput(f->ip);
    800045f4:	6c88                	ld	a0,24(s1)
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	f94080e7          	jalr	-108(ra) # 8000358a <iput>
    end_op(f->ip->dev);
    800045fe:	6c9c                	ld	a5,24(s1)
    80004600:	4388                	lw	a0,0(a5)
    80004602:	00000097          	auipc	ra,0x0
    80004606:	9cc080e7          	jalr	-1588(ra) # 80003fce <end_op>
    8000460a:	bf61                	j	800045a2 <fileclose+0x56>

000000008000460c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000460c:	715d                	addi	sp,sp,-80
    8000460e:	e486                	sd	ra,72(sp)
    80004610:	e0a2                	sd	s0,64(sp)
    80004612:	fc26                	sd	s1,56(sp)
    80004614:	f84a                	sd	s2,48(sp)
    80004616:	f44e                	sd	s3,40(sp)
    80004618:	0880                	addi	s0,sp,80
    8000461a:	84aa                	mv	s1,a0
    8000461c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000461e:	ffffd097          	auipc	ra,0xffffd
    80004622:	22e080e7          	jalr	558(ra) # 8000184c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004626:	409c                	lw	a5,0(s1)
    80004628:	37f9                	addiw	a5,a5,-2
    8000462a:	4705                	li	a4,1
    8000462c:	04f76763          	bltu	a4,a5,8000467a <filestat+0x6e>
    80004630:	892a                	mv	s2,a0
    ilock(f->ip);
    80004632:	6c88                	ld	a0,24(s1)
    80004634:	fffff097          	auipc	ra,0xfffff
    80004638:	e48080e7          	jalr	-440(ra) # 8000347c <ilock>
    stati(f->ip, &st);
    8000463c:	fb840593          	addi	a1,s0,-72
    80004640:	6c88                	ld	a0,24(s1)
    80004642:	fffff097          	auipc	ra,0xfffff
    80004646:	0a0080e7          	jalr	160(ra) # 800036e2 <stati>
    iunlock(f->ip);
    8000464a:	6c88                	ld	a0,24(s1)
    8000464c:	fffff097          	auipc	ra,0xfffff
    80004650:	ef2080e7          	jalr	-270(ra) # 8000353e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004654:	46e1                	li	a3,24
    80004656:	fb840613          	addi	a2,s0,-72
    8000465a:	85ce                	mv	a1,s3
    8000465c:	05093503          	ld	a0,80(s2)
    80004660:	ffffd097          	auipc	ra,0xffffd
    80004664:	f12080e7          	jalr	-238(ra) # 80001572 <copyout>
    80004668:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000466c:	60a6                	ld	ra,72(sp)
    8000466e:	6406                	ld	s0,64(sp)
    80004670:	74e2                	ld	s1,56(sp)
    80004672:	7942                	ld	s2,48(sp)
    80004674:	79a2                	ld	s3,40(sp)
    80004676:	6161                	addi	sp,sp,80
    80004678:	8082                	ret
  return -1;
    8000467a:	557d                	li	a0,-1
    8000467c:	bfc5                	j	8000466c <filestat+0x60>

000000008000467e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000467e:	7179                	addi	sp,sp,-48
    80004680:	f406                	sd	ra,40(sp)
    80004682:	f022                	sd	s0,32(sp)
    80004684:	ec26                	sd	s1,24(sp)
    80004686:	e84a                	sd	s2,16(sp)
    80004688:	e44e                	sd	s3,8(sp)
    8000468a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000468c:	00854783          	lbu	a5,8(a0)
    80004690:	cfc1                	beqz	a5,80004728 <fileread+0xaa>
    80004692:	84aa                	mv	s1,a0
    80004694:	89ae                	mv	s3,a1
    80004696:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004698:	411c                	lw	a5,0(a0)
    8000469a:	4705                	li	a4,1
    8000469c:	04e78963          	beq	a5,a4,800046ee <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046a0:	470d                	li	a4,3
    800046a2:	04e78d63          	beq	a5,a4,800046fc <fileread+0x7e>
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046a6:	4709                	li	a4,2
    800046a8:	06e79863          	bne	a5,a4,80004718 <fileread+0x9a>
    ilock(f->ip);
    800046ac:	6d08                	ld	a0,24(a0)
    800046ae:	fffff097          	auipc	ra,0xfffff
    800046b2:	dce080e7          	jalr	-562(ra) # 8000347c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046b6:	874a                	mv	a4,s2
    800046b8:	5094                	lw	a3,32(s1)
    800046ba:	864e                	mv	a2,s3
    800046bc:	4585                	li	a1,1
    800046be:	6c88                	ld	a0,24(s1)
    800046c0:	fffff097          	auipc	ra,0xfffff
    800046c4:	04c080e7          	jalr	76(ra) # 8000370c <readi>
    800046c8:	892a                	mv	s2,a0
    800046ca:	00a05563          	blez	a0,800046d4 <fileread+0x56>
      f->off += r;
    800046ce:	509c                	lw	a5,32(s1)
    800046d0:	9fa9                	addw	a5,a5,a0
    800046d2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046d4:	6c88                	ld	a0,24(s1)
    800046d6:	fffff097          	auipc	ra,0xfffff
    800046da:	e68080e7          	jalr	-408(ra) # 8000353e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046de:	854a                	mv	a0,s2
    800046e0:	70a2                	ld	ra,40(sp)
    800046e2:	7402                	ld	s0,32(sp)
    800046e4:	64e2                	ld	s1,24(sp)
    800046e6:	6942                	ld	s2,16(sp)
    800046e8:	69a2                	ld	s3,8(sp)
    800046ea:	6145                	addi	sp,sp,48
    800046ec:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046ee:	6908                	ld	a0,16(a0)
    800046f0:	00000097          	auipc	ra,0x0
    800046f4:	3de080e7          	jalr	990(ra) # 80004ace <piperead>
    800046f8:	892a                	mv	s2,a0
    800046fa:	b7d5                	j	800046de <fileread+0x60>
    r = devsw[f->major].read(1, addr, n);
    800046fc:	02451783          	lh	a5,36(a0)
    80004700:	00479713          	slli	a4,a5,0x4
    80004704:	0001e797          	auipc	a5,0x1e
    80004708:	3e478793          	addi	a5,a5,996 # 80022ae8 <ftable>
    8000470c:	97ba                	add	a5,a5,a4
    8000470e:	6f9c                	ld	a5,24(a5)
    80004710:	4505                	li	a0,1
    80004712:	9782                	jalr	a5
    80004714:	892a                	mv	s2,a0
    80004716:	b7e1                	j	800046de <fileread+0x60>
    panic("fileread");
    80004718:	00004517          	auipc	a0,0x4
    8000471c:	fe050513          	addi	a0,a0,-32 # 800086f8 <userret+0x668>
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	e2e080e7          	jalr	-466(ra) # 8000054e <panic>
    return -1;
    80004728:	597d                	li	s2,-1
    8000472a:	bf55                	j	800046de <fileread+0x60>

000000008000472c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000472c:	00954783          	lbu	a5,9(a0)
    80004730:	12078e63          	beqz	a5,8000486c <filewrite+0x140>
{
    80004734:	715d                	addi	sp,sp,-80
    80004736:	e486                	sd	ra,72(sp)
    80004738:	e0a2                	sd	s0,64(sp)
    8000473a:	fc26                	sd	s1,56(sp)
    8000473c:	f84a                	sd	s2,48(sp)
    8000473e:	f44e                	sd	s3,40(sp)
    80004740:	f052                	sd	s4,32(sp)
    80004742:	ec56                	sd	s5,24(sp)
    80004744:	e85a                	sd	s6,16(sp)
    80004746:	e45e                	sd	s7,8(sp)
    80004748:	e062                	sd	s8,0(sp)
    8000474a:	0880                	addi	s0,sp,80
    8000474c:	84aa                	mv	s1,a0
    8000474e:	8aae                	mv	s5,a1
    80004750:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004752:	411c                	lw	a5,0(a0)
    80004754:	4705                	li	a4,1
    80004756:	02e78263          	beq	a5,a4,8000477a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000475a:	470d                	li	a4,3
    8000475c:	02e78563          	beq	a5,a4,80004786 <filewrite+0x5a>
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004760:	4709                	li	a4,2
    80004762:	0ee79d63          	bne	a5,a4,8000485c <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004766:	0ec05763          	blez	a2,80004854 <filewrite+0x128>
    int i = 0;
    8000476a:	4981                	li	s3,0
    8000476c:	6b05                	lui	s6,0x1
    8000476e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004772:	6b85                	lui	s7,0x1
    80004774:	c00b8b9b          	addiw	s7,s7,-1024
    80004778:	a051                	j	800047fc <filewrite+0xd0>
    ret = pipewrite(f->pipe, addr, n);
    8000477a:	6908                	ld	a0,16(a0)
    8000477c:	00000097          	auipc	ra,0x0
    80004780:	23e080e7          	jalr	574(ra) # 800049ba <pipewrite>
    80004784:	a065                	j	8000482c <filewrite+0x100>
    ret = devsw[f->major].write(1, addr, n);
    80004786:	02451783          	lh	a5,36(a0)
    8000478a:	00479713          	slli	a4,a5,0x4
    8000478e:	0001e797          	auipc	a5,0x1e
    80004792:	35a78793          	addi	a5,a5,858 # 80022ae8 <ftable>
    80004796:	97ba                	add	a5,a5,a4
    80004798:	739c                	ld	a5,32(a5)
    8000479a:	4505                	li	a0,1
    8000479c:	9782                	jalr	a5
    8000479e:	a079                	j	8000482c <filewrite+0x100>
    800047a0:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    800047a4:	6c9c                	ld	a5,24(s1)
    800047a6:	4388                	lw	a0,0(a5)
    800047a8:	fffff097          	auipc	ra,0xfffff
    800047ac:	77c080e7          	jalr	1916(ra) # 80003f24 <begin_op>
      ilock(f->ip);
    800047b0:	6c88                	ld	a0,24(s1)
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	cca080e7          	jalr	-822(ra) # 8000347c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047ba:	8762                	mv	a4,s8
    800047bc:	5094                	lw	a3,32(s1)
    800047be:	01598633          	add	a2,s3,s5
    800047c2:	4585                	li	a1,1
    800047c4:	6c88                	ld	a0,24(s1)
    800047c6:	fffff097          	auipc	ra,0xfffff
    800047ca:	03a080e7          	jalr	58(ra) # 80003800 <writei>
    800047ce:	892a                	mv	s2,a0
    800047d0:	02a05e63          	blez	a0,8000480c <filewrite+0xe0>
        f->off += r;
    800047d4:	509c                	lw	a5,32(s1)
    800047d6:	9fa9                	addw	a5,a5,a0
    800047d8:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    800047da:	6c88                	ld	a0,24(s1)
    800047dc:	fffff097          	auipc	ra,0xfffff
    800047e0:	d62080e7          	jalr	-670(ra) # 8000353e <iunlock>
      end_op(f->ip->dev);
    800047e4:	6c9c                	ld	a5,24(s1)
    800047e6:	4388                	lw	a0,0(a5)
    800047e8:	fffff097          	auipc	ra,0xfffff
    800047ec:	7e6080e7          	jalr	2022(ra) # 80003fce <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800047f0:	052c1a63          	bne	s8,s2,80004844 <filewrite+0x118>
        panic("short filewrite");
      i += r;
    800047f4:	013909bb          	addw	s3,s2,s3
    while(i < n){
    800047f8:	0349d763          	bge	s3,s4,80004826 <filewrite+0xfa>
      int n1 = n - i;
    800047fc:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004800:	893e                	mv	s2,a5
    80004802:	2781                	sext.w	a5,a5
    80004804:	f8fb5ee3          	bge	s6,a5,800047a0 <filewrite+0x74>
    80004808:	895e                	mv	s2,s7
    8000480a:	bf59                	j	800047a0 <filewrite+0x74>
      iunlock(f->ip);
    8000480c:	6c88                	ld	a0,24(s1)
    8000480e:	fffff097          	auipc	ra,0xfffff
    80004812:	d30080e7          	jalr	-720(ra) # 8000353e <iunlock>
      end_op(f->ip->dev);
    80004816:	6c9c                	ld	a5,24(s1)
    80004818:	4388                	lw	a0,0(a5)
    8000481a:	fffff097          	auipc	ra,0xfffff
    8000481e:	7b4080e7          	jalr	1972(ra) # 80003fce <end_op>
      if(r < 0)
    80004822:	fc0957e3          	bgez	s2,800047f0 <filewrite+0xc4>
    }
    ret = (i == n ? n : -1);
    80004826:	8552                	mv	a0,s4
    80004828:	033a1863          	bne	s4,s3,80004858 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000482c:	60a6                	ld	ra,72(sp)
    8000482e:	6406                	ld	s0,64(sp)
    80004830:	74e2                	ld	s1,56(sp)
    80004832:	7942                	ld	s2,48(sp)
    80004834:	79a2                	ld	s3,40(sp)
    80004836:	7a02                	ld	s4,32(sp)
    80004838:	6ae2                	ld	s5,24(sp)
    8000483a:	6b42                	ld	s6,16(sp)
    8000483c:	6ba2                	ld	s7,8(sp)
    8000483e:	6c02                	ld	s8,0(sp)
    80004840:	6161                	addi	sp,sp,80
    80004842:	8082                	ret
        panic("short filewrite");
    80004844:	00004517          	auipc	a0,0x4
    80004848:	ec450513          	addi	a0,a0,-316 # 80008708 <userret+0x678>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	d02080e7          	jalr	-766(ra) # 8000054e <panic>
    int i = 0;
    80004854:	4981                	li	s3,0
    80004856:	bfc1                	j	80004826 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    80004858:	557d                	li	a0,-1
    8000485a:	bfc9                	j	8000482c <filewrite+0x100>
    panic("filewrite");
    8000485c:	00004517          	auipc	a0,0x4
    80004860:	ebc50513          	addi	a0,a0,-324 # 80008718 <userret+0x688>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	cea080e7          	jalr	-790(ra) # 8000054e <panic>
    return -1;
    8000486c:	557d                	li	a0,-1
}
    8000486e:	8082                	ret

0000000080004870 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004870:	7179                	addi	sp,sp,-48
    80004872:	f406                	sd	ra,40(sp)
    80004874:	f022                	sd	s0,32(sp)
    80004876:	ec26                	sd	s1,24(sp)
    80004878:	e84a                	sd	s2,16(sp)
    8000487a:	e44e                	sd	s3,8(sp)
    8000487c:	e052                	sd	s4,0(sp)
    8000487e:	1800                	addi	s0,sp,48
    80004880:	84aa                	mv	s1,a0
    80004882:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004884:	0005b023          	sd	zero,0(a1)
    80004888:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	c04080e7          	jalr	-1020(ra) # 80004490 <filealloc>
    80004894:	e088                	sd	a0,0(s1)
    80004896:	c551                	beqz	a0,80004922 <pipealloc+0xb2>
    80004898:	00000097          	auipc	ra,0x0
    8000489c:	bf8080e7          	jalr	-1032(ra) # 80004490 <filealloc>
    800048a0:	00aa3023          	sd	a0,0(s4)
    800048a4:	c92d                	beqz	a0,80004916 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	0d2080e7          	jalr	210(ra) # 80000978 <kalloc>
    800048ae:	892a                	mv	s2,a0
    800048b0:	c125                	beqz	a0,80004910 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048b2:	4985                	li	s3,1
    800048b4:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048b8:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048bc:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048c0:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048c4:	00004597          	auipc	a1,0x4
    800048c8:	e6458593          	addi	a1,a1,-412 # 80008728 <userret+0x698>
    800048cc:	ffffc097          	auipc	ra,0xffffc
    800048d0:	10c080e7          	jalr	268(ra) # 800009d8 <initlock>
  (*f0)->type = FD_PIPE;
    800048d4:	609c                	ld	a5,0(s1)
    800048d6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048da:	609c                	ld	a5,0(s1)
    800048dc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048e0:	609c                	ld	a5,0(s1)
    800048e2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048e6:	609c                	ld	a5,0(s1)
    800048e8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048ec:	000a3783          	ld	a5,0(s4)
    800048f0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048f4:	000a3783          	ld	a5,0(s4)
    800048f8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048fc:	000a3783          	ld	a5,0(s4)
    80004900:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004904:	000a3783          	ld	a5,0(s4)
    80004908:	0127b823          	sd	s2,16(a5)
  return 0;
    8000490c:	4501                	li	a0,0
    8000490e:	a025                	j	80004936 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004910:	6088                	ld	a0,0(s1)
    80004912:	e501                	bnez	a0,8000491a <pipealloc+0xaa>
    80004914:	a039                	j	80004922 <pipealloc+0xb2>
    80004916:	6088                	ld	a0,0(s1)
    80004918:	c51d                	beqz	a0,80004946 <pipealloc+0xd6>
    fileclose(*f0);
    8000491a:	00000097          	auipc	ra,0x0
    8000491e:	c32080e7          	jalr	-974(ra) # 8000454c <fileclose>
  if(*f1)
    80004922:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004926:	557d                	li	a0,-1
  if(*f1)
    80004928:	c799                	beqz	a5,80004936 <pipealloc+0xc6>
    fileclose(*f1);
    8000492a:	853e                	mv	a0,a5
    8000492c:	00000097          	auipc	ra,0x0
    80004930:	c20080e7          	jalr	-992(ra) # 8000454c <fileclose>
  return -1;
    80004934:	557d                	li	a0,-1
}
    80004936:	70a2                	ld	ra,40(sp)
    80004938:	7402                	ld	s0,32(sp)
    8000493a:	64e2                	ld	s1,24(sp)
    8000493c:	6942                	ld	s2,16(sp)
    8000493e:	69a2                	ld	s3,8(sp)
    80004940:	6a02                	ld	s4,0(sp)
    80004942:	6145                	addi	sp,sp,48
    80004944:	8082                	ret
  return -1;
    80004946:	557d                	li	a0,-1
    80004948:	b7fd                	j	80004936 <pipealloc+0xc6>

000000008000494a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000494a:	1101                	addi	sp,sp,-32
    8000494c:	ec06                	sd	ra,24(sp)
    8000494e:	e822                	sd	s0,16(sp)
    80004950:	e426                	sd	s1,8(sp)
    80004952:	e04a                	sd	s2,0(sp)
    80004954:	1000                	addi	s0,sp,32
    80004956:	84aa                	mv	s1,a0
    80004958:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	190080e7          	jalr	400(ra) # 80000aea <acquire>
  if(writable){
    80004962:	02090d63          	beqz	s2,8000499c <pipeclose+0x52>
    pi->writeopen = 0;
    80004966:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000496a:	21848513          	addi	a0,s1,536
    8000496e:	ffffe097          	auipc	ra,0xffffe
    80004972:	876080e7          	jalr	-1930(ra) # 800021e4 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004976:	2204b783          	ld	a5,544(s1)
    8000497a:	eb95                	bnez	a5,800049ae <pipeclose+0x64>
    release(&pi->lock);
    8000497c:	8526                	mv	a0,s1
    8000497e:	ffffc097          	auipc	ra,0xffffc
    80004982:	1d4080e7          	jalr	468(ra) # 80000b52 <release>
    kfree((char*)pi);
    80004986:	8526                	mv	a0,s1
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	edc080e7          	jalr	-292(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    80004990:	60e2                	ld	ra,24(sp)
    80004992:	6442                	ld	s0,16(sp)
    80004994:	64a2                	ld	s1,8(sp)
    80004996:	6902                	ld	s2,0(sp)
    80004998:	6105                	addi	sp,sp,32
    8000499a:	8082                	ret
    pi->readopen = 0;
    8000499c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049a0:	21c48513          	addi	a0,s1,540
    800049a4:	ffffe097          	auipc	ra,0xffffe
    800049a8:	840080e7          	jalr	-1984(ra) # 800021e4 <wakeup>
    800049ac:	b7e9                	j	80004976 <pipeclose+0x2c>
    release(&pi->lock);
    800049ae:	8526                	mv	a0,s1
    800049b0:	ffffc097          	auipc	ra,0xffffc
    800049b4:	1a2080e7          	jalr	418(ra) # 80000b52 <release>
}
    800049b8:	bfe1                	j	80004990 <pipeclose+0x46>

00000000800049ba <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049ba:	7159                	addi	sp,sp,-112
    800049bc:	f486                	sd	ra,104(sp)
    800049be:	f0a2                	sd	s0,96(sp)
    800049c0:	eca6                	sd	s1,88(sp)
    800049c2:	e8ca                	sd	s2,80(sp)
    800049c4:	e4ce                	sd	s3,72(sp)
    800049c6:	e0d2                	sd	s4,64(sp)
    800049c8:	fc56                	sd	s5,56(sp)
    800049ca:	f85a                	sd	s6,48(sp)
    800049cc:	f45e                	sd	s7,40(sp)
    800049ce:	f062                	sd	s8,32(sp)
    800049d0:	ec66                	sd	s9,24(sp)
    800049d2:	1880                	addi	s0,sp,112
    800049d4:	84aa                	mv	s1,a0
    800049d6:	8b2e                	mv	s6,a1
    800049d8:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    800049da:	ffffd097          	auipc	ra,0xffffd
    800049de:	e72080e7          	jalr	-398(ra) # 8000184c <myproc>
    800049e2:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    800049e4:	8526                	mv	a0,s1
    800049e6:	ffffc097          	auipc	ra,0xffffc
    800049ea:	104080e7          	jalr	260(ra) # 80000aea <acquire>
  for(i = 0; i < n; i++){
    800049ee:	0b505063          	blez	s5,80004a8e <pipewrite+0xd4>
    800049f2:	8926                	mv	s2,s1
    800049f4:	fffa8b9b          	addiw	s7,s5,-1
    800049f8:	1b82                	slli	s7,s7,0x20
    800049fa:	020bdb93          	srli	s7,s7,0x20
    800049fe:	001b0793          	addi	a5,s6,1
    80004a02:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004a04:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a08:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a0c:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a0e:	2184a783          	lw	a5,536(s1)
    80004a12:	21c4a703          	lw	a4,540(s1)
    80004a16:	2007879b          	addiw	a5,a5,512
    80004a1a:	02f71e63          	bne	a4,a5,80004a56 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80004a1e:	2204a783          	lw	a5,544(s1)
    80004a22:	c3d9                	beqz	a5,80004aa8 <pipewrite+0xee>
    80004a24:	ffffd097          	auipc	ra,0xffffd
    80004a28:	e28080e7          	jalr	-472(ra) # 8000184c <myproc>
    80004a2c:	591c                	lw	a5,48(a0)
    80004a2e:	efad                	bnez	a5,80004aa8 <pipewrite+0xee>
      wakeup(&pi->nread);
    80004a30:	8552                	mv	a0,s4
    80004a32:	ffffd097          	auipc	ra,0xffffd
    80004a36:	7b2080e7          	jalr	1970(ra) # 800021e4 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a3a:	85ca                	mv	a1,s2
    80004a3c:	854e                	mv	a0,s3
    80004a3e:	ffffd097          	auipc	ra,0xffffd
    80004a42:	620080e7          	jalr	1568(ra) # 8000205e <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004a46:	2184a783          	lw	a5,536(s1)
    80004a4a:	21c4a703          	lw	a4,540(s1)
    80004a4e:	2007879b          	addiw	a5,a5,512
    80004a52:	fcf706e3          	beq	a4,a5,80004a1e <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a56:	4685                	li	a3,1
    80004a58:	865a                	mv	a2,s6
    80004a5a:	f9f40593          	addi	a1,s0,-97
    80004a5e:	050c3503          	ld	a0,80(s8)
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	ba2080e7          	jalr	-1118(ra) # 80001604 <copyin>
    80004a6a:	03950263          	beq	a0,s9,80004a8e <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a6e:	21c4a783          	lw	a5,540(s1)
    80004a72:	0017871b          	addiw	a4,a5,1
    80004a76:	20e4ae23          	sw	a4,540(s1)
    80004a7a:	1ff7f793          	andi	a5,a5,511
    80004a7e:	97a6                	add	a5,a5,s1
    80004a80:	f9f44703          	lbu	a4,-97(s0)
    80004a84:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004a88:	0b05                	addi	s6,s6,1
    80004a8a:	f97b12e3          	bne	s6,s7,80004a0e <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004a8e:	21848513          	addi	a0,s1,536
    80004a92:	ffffd097          	auipc	ra,0xffffd
    80004a96:	752080e7          	jalr	1874(ra) # 800021e4 <wakeup>
  release(&pi->lock);
    80004a9a:	8526                	mv	a0,s1
    80004a9c:	ffffc097          	auipc	ra,0xffffc
    80004aa0:	0b6080e7          	jalr	182(ra) # 80000b52 <release>
  return n;
    80004aa4:	8556                	mv	a0,s5
    80004aa6:	a039                	j	80004ab4 <pipewrite+0xfa>
        release(&pi->lock);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffc097          	auipc	ra,0xffffc
    80004aae:	0a8080e7          	jalr	168(ra) # 80000b52 <release>
        return -1;
    80004ab2:	557d                	li	a0,-1
}
    80004ab4:	70a6                	ld	ra,104(sp)
    80004ab6:	7406                	ld	s0,96(sp)
    80004ab8:	64e6                	ld	s1,88(sp)
    80004aba:	6946                	ld	s2,80(sp)
    80004abc:	69a6                	ld	s3,72(sp)
    80004abe:	6a06                	ld	s4,64(sp)
    80004ac0:	7ae2                	ld	s5,56(sp)
    80004ac2:	7b42                	ld	s6,48(sp)
    80004ac4:	7ba2                	ld	s7,40(sp)
    80004ac6:	7c02                	ld	s8,32(sp)
    80004ac8:	6ce2                	ld	s9,24(sp)
    80004aca:	6165                	addi	sp,sp,112
    80004acc:	8082                	ret

0000000080004ace <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ace:	715d                	addi	sp,sp,-80
    80004ad0:	e486                	sd	ra,72(sp)
    80004ad2:	e0a2                	sd	s0,64(sp)
    80004ad4:	fc26                	sd	s1,56(sp)
    80004ad6:	f84a                	sd	s2,48(sp)
    80004ad8:	f44e                	sd	s3,40(sp)
    80004ada:	f052                	sd	s4,32(sp)
    80004adc:	ec56                	sd	s5,24(sp)
    80004ade:	e85a                	sd	s6,16(sp)
    80004ae0:	0880                	addi	s0,sp,80
    80004ae2:	84aa                	mv	s1,a0
    80004ae4:	892e                	mv	s2,a1
    80004ae6:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004ae8:	ffffd097          	auipc	ra,0xffffd
    80004aec:	d64080e7          	jalr	-668(ra) # 8000184c <myproc>
    80004af0:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004af2:	8b26                	mv	s6,s1
    80004af4:	8526                	mv	a0,s1
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	ff4080e7          	jalr	-12(ra) # 80000aea <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afe:	2184a703          	lw	a4,536(s1)
    80004b02:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b06:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b0a:	02f71763          	bne	a4,a5,80004b38 <piperead+0x6a>
    80004b0e:	2244a783          	lw	a5,548(s1)
    80004b12:	c39d                	beqz	a5,80004b38 <piperead+0x6a>
    if(myproc()->killed){
    80004b14:	ffffd097          	auipc	ra,0xffffd
    80004b18:	d38080e7          	jalr	-712(ra) # 8000184c <myproc>
    80004b1c:	591c                	lw	a5,48(a0)
    80004b1e:	ebc1                	bnez	a5,80004bae <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b20:	85da                	mv	a1,s6
    80004b22:	854e                	mv	a0,s3
    80004b24:	ffffd097          	auipc	ra,0xffffd
    80004b28:	53a080e7          	jalr	1338(ra) # 8000205e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b2c:	2184a703          	lw	a4,536(s1)
    80004b30:	21c4a783          	lw	a5,540(s1)
    80004b34:	fcf70de3          	beq	a4,a5,80004b0e <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b38:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b3a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b3c:	05405363          	blez	s4,80004b82 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b40:	2184a783          	lw	a5,536(s1)
    80004b44:	21c4a703          	lw	a4,540(s1)
    80004b48:	02f70d63          	beq	a4,a5,80004b82 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b4c:	0017871b          	addiw	a4,a5,1
    80004b50:	20e4ac23          	sw	a4,536(s1)
    80004b54:	1ff7f793          	andi	a5,a5,511
    80004b58:	97a6                	add	a5,a5,s1
    80004b5a:	0187c783          	lbu	a5,24(a5)
    80004b5e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b62:	4685                	li	a3,1
    80004b64:	fbf40613          	addi	a2,s0,-65
    80004b68:	85ca                	mv	a1,s2
    80004b6a:	050ab503          	ld	a0,80(s5)
    80004b6e:	ffffd097          	auipc	ra,0xffffd
    80004b72:	a04080e7          	jalr	-1532(ra) # 80001572 <copyout>
    80004b76:	01650663          	beq	a0,s6,80004b82 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b7a:	2985                	addiw	s3,s3,1
    80004b7c:	0905                	addi	s2,s2,1
    80004b7e:	fd3a11e3          	bne	s4,s3,80004b40 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b82:	21c48513          	addi	a0,s1,540
    80004b86:	ffffd097          	auipc	ra,0xffffd
    80004b8a:	65e080e7          	jalr	1630(ra) # 800021e4 <wakeup>
  release(&pi->lock);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	fc2080e7          	jalr	-62(ra) # 80000b52 <release>
  return i;
}
    80004b98:	854e                	mv	a0,s3
    80004b9a:	60a6                	ld	ra,72(sp)
    80004b9c:	6406                	ld	s0,64(sp)
    80004b9e:	74e2                	ld	s1,56(sp)
    80004ba0:	7942                	ld	s2,48(sp)
    80004ba2:	79a2                	ld	s3,40(sp)
    80004ba4:	7a02                	ld	s4,32(sp)
    80004ba6:	6ae2                	ld	s5,24(sp)
    80004ba8:	6b42                	ld	s6,16(sp)
    80004baa:	6161                	addi	sp,sp,80
    80004bac:	8082                	ret
      release(&pi->lock);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffc097          	auipc	ra,0xffffc
    80004bb4:	fa2080e7          	jalr	-94(ra) # 80000b52 <release>
      return -1;
    80004bb8:	59fd                	li	s3,-1
    80004bba:	bff9                	j	80004b98 <piperead+0xca>

0000000080004bbc <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bbc:	df010113          	addi	sp,sp,-528
    80004bc0:	20113423          	sd	ra,520(sp)
    80004bc4:	20813023          	sd	s0,512(sp)
    80004bc8:	ffa6                	sd	s1,504(sp)
    80004bca:	fbca                	sd	s2,496(sp)
    80004bcc:	f7ce                	sd	s3,488(sp)
    80004bce:	f3d2                	sd	s4,480(sp)
    80004bd0:	efd6                	sd	s5,472(sp)
    80004bd2:	ebda                	sd	s6,464(sp)
    80004bd4:	e7de                	sd	s7,456(sp)
    80004bd6:	e3e2                	sd	s8,448(sp)
    80004bd8:	ff66                	sd	s9,440(sp)
    80004bda:	fb6a                	sd	s10,432(sp)
    80004bdc:	f76e                	sd	s11,424(sp)
    80004bde:	0c00                	addi	s0,sp,528
    80004be0:	84aa                	mv	s1,a0
    80004be2:	dea43c23          	sd	a0,-520(s0)
    80004be6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bea:	ffffd097          	auipc	ra,0xffffd
    80004bee:	c62080e7          	jalr	-926(ra) # 8000184c <myproc>
    80004bf2:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80004bf4:	4501                	li	a0,0
    80004bf6:	fffff097          	auipc	ra,0xfffff
    80004bfa:	32e080e7          	jalr	814(ra) # 80003f24 <begin_op>

  if((ip = namei(path)) == 0){
    80004bfe:	8526                	mv	a0,s1
    80004c00:	fffff097          	auipc	ra,0xfffff
    80004c04:	008080e7          	jalr	8(ra) # 80003c08 <namei>
    80004c08:	c935                	beqz	a0,80004c7c <exec+0xc0>
    80004c0a:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004c0c:	fffff097          	auipc	ra,0xfffff
    80004c10:	870080e7          	jalr	-1936(ra) # 8000347c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c14:	04000713          	li	a4,64
    80004c18:	4681                	li	a3,0
    80004c1a:	e4840613          	addi	a2,s0,-440
    80004c1e:	4581                	li	a1,0
    80004c20:	8526                	mv	a0,s1
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	aea080e7          	jalr	-1302(ra) # 8000370c <readi>
    80004c2a:	04000793          	li	a5,64
    80004c2e:	00f51a63          	bne	a0,a5,80004c42 <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c32:	e4842703          	lw	a4,-440(s0)
    80004c36:	464c47b7          	lui	a5,0x464c4
    80004c3a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c3e:	04f70663          	beq	a4,a5,80004c8a <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c42:	8526                	mv	a0,s1
    80004c44:	fffff097          	auipc	ra,0xfffff
    80004c48:	a76080e7          	jalr	-1418(ra) # 800036ba <iunlockput>
    end_op(ROOTDEV);
    80004c4c:	4501                	li	a0,0
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	380080e7          	jalr	896(ra) # 80003fce <end_op>
  }
  return -1;
    80004c56:	557d                	li	a0,-1
}
    80004c58:	20813083          	ld	ra,520(sp)
    80004c5c:	20013403          	ld	s0,512(sp)
    80004c60:	74fe                	ld	s1,504(sp)
    80004c62:	795e                	ld	s2,496(sp)
    80004c64:	79be                	ld	s3,488(sp)
    80004c66:	7a1e                	ld	s4,480(sp)
    80004c68:	6afe                	ld	s5,472(sp)
    80004c6a:	6b5e                	ld	s6,464(sp)
    80004c6c:	6bbe                	ld	s7,456(sp)
    80004c6e:	6c1e                	ld	s8,448(sp)
    80004c70:	7cfa                	ld	s9,440(sp)
    80004c72:	7d5a                	ld	s10,432(sp)
    80004c74:	7dba                	ld	s11,424(sp)
    80004c76:	21010113          	addi	sp,sp,528
    80004c7a:	8082                	ret
    end_op(ROOTDEV);
    80004c7c:	4501                	li	a0,0
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	350080e7          	jalr	848(ra) # 80003fce <end_op>
    return -1;
    80004c86:	557d                	li	a0,-1
    80004c88:	bfc1                	j	80004c58 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c8a:	854a                	mv	a0,s2
    80004c8c:	ffffd097          	auipc	ra,0xffffd
    80004c90:	c84080e7          	jalr	-892(ra) # 80001910 <proc_pagetable>
    80004c94:	8c2a                	mv	s8,a0
    80004c96:	d555                	beqz	a0,80004c42 <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c98:	e6842983          	lw	s3,-408(s0)
    80004c9c:	e8045783          	lhu	a5,-384(s0)
    80004ca0:	c7fd                	beqz	a5,80004d8e <exec+0x1d2>
  sz = 0;
    80004ca2:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ca6:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004ca8:	6b05                	lui	s6,0x1
    80004caa:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004cae:	def43823          	sd	a5,-528(s0)
    80004cb2:	a0a5                	j	80004d1a <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004cb4:	00004517          	auipc	a0,0x4
    80004cb8:	a7c50513          	addi	a0,a0,-1412 # 80008730 <userret+0x6a0>
    80004cbc:	ffffc097          	auipc	ra,0xffffc
    80004cc0:	892080e7          	jalr	-1902(ra) # 8000054e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cc4:	8756                	mv	a4,s5
    80004cc6:	012d86bb          	addw	a3,s11,s2
    80004cca:	4581                	li	a1,0
    80004ccc:	8526                	mv	a0,s1
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	a3e080e7          	jalr	-1474(ra) # 8000370c <readi>
    80004cd6:	2501                	sext.w	a0,a0
    80004cd8:	10aa9263          	bne	s5,a0,80004ddc <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80004cdc:	6785                	lui	a5,0x1
    80004cde:	0127893b          	addw	s2,a5,s2
    80004ce2:	77fd                	lui	a5,0xfffff
    80004ce4:	01478a3b          	addw	s4,a5,s4
    80004ce8:	03997263          	bgeu	s2,s9,80004d0c <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004cec:	02091593          	slli	a1,s2,0x20
    80004cf0:	9181                	srli	a1,a1,0x20
    80004cf2:	95ea                	add	a1,a1,s10
    80004cf4:	8562                	mv	a0,s8
    80004cf6:	ffffc097          	auipc	ra,0xffffc
    80004cfa:	2b6080e7          	jalr	694(ra) # 80000fac <walkaddr>
    80004cfe:	862a                	mv	a2,a0
    if(pa == 0)
    80004d00:	d955                	beqz	a0,80004cb4 <exec+0xf8>
      n = PGSIZE;
    80004d02:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004d04:	fd6a70e3          	bgeu	s4,s6,80004cc4 <exec+0x108>
      n = sz - i;
    80004d08:	8ad2                	mv	s5,s4
    80004d0a:	bf6d                	j	80004cc4 <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d0c:	2b85                	addiw	s7,s7,1
    80004d0e:	0389899b          	addiw	s3,s3,56
    80004d12:	e8045783          	lhu	a5,-384(s0)
    80004d16:	06fbde63          	bge	s7,a5,80004d92 <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d1a:	2981                	sext.w	s3,s3
    80004d1c:	03800713          	li	a4,56
    80004d20:	86ce                	mv	a3,s3
    80004d22:	e1040613          	addi	a2,s0,-496
    80004d26:	4581                	li	a1,0
    80004d28:	8526                	mv	a0,s1
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	9e2080e7          	jalr	-1566(ra) # 8000370c <readi>
    80004d32:	03800793          	li	a5,56
    80004d36:	0af51363          	bne	a0,a5,80004ddc <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004d3a:	e1042783          	lw	a5,-496(s0)
    80004d3e:	4705                	li	a4,1
    80004d40:	fce796e3          	bne	a5,a4,80004d0c <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004d44:	e3843603          	ld	a2,-456(s0)
    80004d48:	e3043783          	ld	a5,-464(s0)
    80004d4c:	08f66863          	bltu	a2,a5,80004ddc <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d50:	e2043783          	ld	a5,-480(s0)
    80004d54:	963e                	add	a2,a2,a5
    80004d56:	08f66363          	bltu	a2,a5,80004ddc <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004d5a:	e0843583          	ld	a1,-504(s0)
    80004d5e:	8562                	mv	a0,s8
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	638080e7          	jalr	1592(ra) # 80001398 <uvmalloc>
    80004d68:	e0a43423          	sd	a0,-504(s0)
    80004d6c:	c925                	beqz	a0,80004ddc <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004d6e:	e2043d03          	ld	s10,-480(s0)
    80004d72:	df043783          	ld	a5,-528(s0)
    80004d76:	00fd77b3          	and	a5,s10,a5
    80004d7a:	e3ad                	bnez	a5,80004ddc <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d7c:	e1842d83          	lw	s11,-488(s0)
    80004d80:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d84:	f80c84e3          	beqz	s9,80004d0c <exec+0x150>
    80004d88:	8a66                	mv	s4,s9
    80004d8a:	4901                	li	s2,0
    80004d8c:	b785                	j	80004cec <exec+0x130>
  sz = 0;
    80004d8e:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004d92:	8526                	mv	a0,s1
    80004d94:	fffff097          	auipc	ra,0xfffff
    80004d98:	926080e7          	jalr	-1754(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    80004d9c:	4501                	li	a0,0
    80004d9e:	fffff097          	auipc	ra,0xfffff
    80004da2:	230080e7          	jalr	560(ra) # 80003fce <end_op>
  p = myproc();
    80004da6:	ffffd097          	auipc	ra,0xffffd
    80004daa:	aa6080e7          	jalr	-1370(ra) # 8000184c <myproc>
    80004dae:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004db0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004db4:	6585                	lui	a1,0x1
    80004db6:	15fd                	addi	a1,a1,-1
    80004db8:	e0843783          	ld	a5,-504(s0)
    80004dbc:	00b78b33          	add	s6,a5,a1
    80004dc0:	75fd                	lui	a1,0xfffff
    80004dc2:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dc6:	6609                	lui	a2,0x2
    80004dc8:	962e                	add	a2,a2,a1
    80004dca:	8562                	mv	a0,s8
    80004dcc:	ffffc097          	auipc	ra,0xffffc
    80004dd0:	5cc080e7          	jalr	1484(ra) # 80001398 <uvmalloc>
    80004dd4:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004dd8:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dda:	ed01                	bnez	a0,80004df2 <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80004ddc:	e0843583          	ld	a1,-504(s0)
    80004de0:	8562                	mv	a0,s8
    80004de2:	ffffd097          	auipc	ra,0xffffd
    80004de6:	c2e080e7          	jalr	-978(ra) # 80001a10 <proc_freepagetable>
  if(ip){
    80004dea:	e4049ce3          	bnez	s1,80004c42 <exec+0x86>
  return -1;
    80004dee:	557d                	li	a0,-1
    80004df0:	b5a5                	j	80004c58 <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004df2:	75f9                	lui	a1,0xffffe
    80004df4:	84aa                	mv	s1,a0
    80004df6:	95aa                	add	a1,a1,a0
    80004df8:	8562                	mv	a0,s8
    80004dfa:	ffffc097          	auipc	ra,0xffffc
    80004dfe:	746080e7          	jalr	1862(ra) # 80001540 <uvmclear>
  stackbase = sp - PGSIZE;
    80004e02:	7afd                	lui	s5,0xfffff
    80004e04:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004e06:	e0043783          	ld	a5,-512(s0)
    80004e0a:	6388                	ld	a0,0(a5)
    80004e0c:	c135                	beqz	a0,80004e70 <exec+0x2b4>
    80004e0e:	e8840993          	addi	s3,s0,-376
    80004e12:	f8840c93          	addi	s9,s0,-120
    80004e16:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	f1e080e7          	jalr	-226(ra) # 80000d36 <strlen>
    80004e20:	2505                	addiw	a0,a0,1
    80004e22:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e24:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80004e26:	0f54ea63          	bltu	s1,s5,80004f1a <exec+0x35e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e2a:	e0043b03          	ld	s6,-512(s0)
    80004e2e:	000b3a03          	ld	s4,0(s6)
    80004e32:	8552                	mv	a0,s4
    80004e34:	ffffc097          	auipc	ra,0xffffc
    80004e38:	f02080e7          	jalr	-254(ra) # 80000d36 <strlen>
    80004e3c:	0015069b          	addiw	a3,a0,1
    80004e40:	8652                	mv	a2,s4
    80004e42:	85a6                	mv	a1,s1
    80004e44:	8562                	mv	a0,s8
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	72c080e7          	jalr	1836(ra) # 80001572 <copyout>
    80004e4e:	0c054863          	bltz	a0,80004f1e <exec+0x362>
    ustack[argc] = sp;
    80004e52:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e56:	0905                	addi	s2,s2,1
    80004e58:	008b0793          	addi	a5,s6,8
    80004e5c:	e0f43023          	sd	a5,-512(s0)
    80004e60:	008b3503          	ld	a0,8(s6)
    80004e64:	c909                	beqz	a0,80004e76 <exec+0x2ba>
    if(argc >= MAXARG)
    80004e66:	09a1                	addi	s3,s3,8
    80004e68:	fb3c98e3          	bne	s9,s3,80004e18 <exec+0x25c>
  ip = 0;
    80004e6c:	4481                	li	s1,0
    80004e6e:	b7bd                	j	80004ddc <exec+0x220>
  sp = sz;
    80004e70:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e74:	4901                	li	s2,0
  ustack[argc] = 0;
    80004e76:	00391793          	slli	a5,s2,0x3
    80004e7a:	f9040713          	addi	a4,s0,-112
    80004e7e:	97ba                	add	a5,a5,a4
    80004e80:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd5e9c>
  sp -= (argc+1) * sizeof(uint64);
    80004e84:	00190693          	addi	a3,s2,1
    80004e88:	068e                	slli	a3,a3,0x3
    80004e8a:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80004e8c:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    80004e90:	4481                	li	s1,0
  if(sp < stackbase)
    80004e92:	f559e5e3          	bltu	s3,s5,80004ddc <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e96:	e8840613          	addi	a2,s0,-376
    80004e9a:	85ce                	mv	a1,s3
    80004e9c:	8562                	mv	a0,s8
    80004e9e:	ffffc097          	auipc	ra,0xffffc
    80004ea2:	6d4080e7          	jalr	1748(ra) # 80001572 <copyout>
    80004ea6:	06054e63          	bltz	a0,80004f22 <exec+0x366>
  p->tf->a1 = sp;
    80004eaa:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004eae:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    80004eb2:	df843783          	ld	a5,-520(s0)
    80004eb6:	0007c703          	lbu	a4,0(a5)
    80004eba:	cf11                	beqz	a4,80004ed6 <exec+0x31a>
    80004ebc:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004ebe:	02f00693          	li	a3,47
    80004ec2:	a029                	j	80004ecc <exec+0x310>
  for(last=s=path; *s; s++)
    80004ec4:	0785                	addi	a5,a5,1
    80004ec6:	fff7c703          	lbu	a4,-1(a5)
    80004eca:	c711                	beqz	a4,80004ed6 <exec+0x31a>
    if(*s == '/')
    80004ecc:	fed71ce3          	bne	a4,a3,80004ec4 <exec+0x308>
      last = s+1;
    80004ed0:	def43c23          	sd	a5,-520(s0)
    80004ed4:	bfc5                	j	80004ec4 <exec+0x308>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ed6:	4641                	li	a2,16
    80004ed8:	df843583          	ld	a1,-520(s0)
    80004edc:	158b8513          	addi	a0,s7,344
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	e24080e7          	jalr	-476(ra) # 80000d04 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ee8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004eec:	058bb823          	sd	s8,80(s7)
  p->sz = sz;
    80004ef0:	e0843783          	ld	a5,-504(s0)
    80004ef4:	04fbb423          	sd	a5,72(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80004ef8:	058bb783          	ld	a5,88(s7)
    80004efc:	e6043703          	ld	a4,-416(s0)
    80004f00:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80004f02:	058bb783          	ld	a5,88(s7)
    80004f06:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f0a:	85ea                	mv	a1,s10
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	b04080e7          	jalr	-1276(ra) # 80001a10 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f14:	0009051b          	sext.w	a0,s2
    80004f18:	b381                	j	80004c58 <exec+0x9c>
  ip = 0;
    80004f1a:	4481                	li	s1,0
    80004f1c:	b5c1                	j	80004ddc <exec+0x220>
    80004f1e:	4481                	li	s1,0
    80004f20:	bd75                	j	80004ddc <exec+0x220>
    80004f22:	4481                	li	s1,0
    80004f24:	bd65                	j	80004ddc <exec+0x220>

0000000080004f26 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f26:	7179                	addi	sp,sp,-48
    80004f28:	f406                	sd	ra,40(sp)
    80004f2a:	f022                	sd	s0,32(sp)
    80004f2c:	ec26                	sd	s1,24(sp)
    80004f2e:	e84a                	sd	s2,16(sp)
    80004f30:	1800                	addi	s0,sp,48
    80004f32:	892e                	mv	s2,a1
    80004f34:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f36:	fdc40593          	addi	a1,s0,-36
    80004f3a:	ffffe097          	auipc	ra,0xffffe
    80004f3e:	9cc080e7          	jalr	-1588(ra) # 80002906 <argint>
    80004f42:	04054063          	bltz	a0,80004f82 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f46:	fdc42703          	lw	a4,-36(s0)
    80004f4a:	47bd                	li	a5,15
    80004f4c:	02e7ed63          	bltu	a5,a4,80004f86 <argfd+0x60>
    80004f50:	ffffd097          	auipc	ra,0xffffd
    80004f54:	8fc080e7          	jalr	-1796(ra) # 8000184c <myproc>
    80004f58:	fdc42703          	lw	a4,-36(s0)
    80004f5c:	01a70793          	addi	a5,a4,26
    80004f60:	078e                	slli	a5,a5,0x3
    80004f62:	953e                	add	a0,a0,a5
    80004f64:	611c                	ld	a5,0(a0)
    80004f66:	c395                	beqz	a5,80004f8a <argfd+0x64>
    return -1;
  if(pfd)
    80004f68:	00090463          	beqz	s2,80004f70 <argfd+0x4a>
    *pfd = fd;
    80004f6c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f70:	4501                	li	a0,0
  if(pf)
    80004f72:	c091                	beqz	s1,80004f76 <argfd+0x50>
    *pf = f;
    80004f74:	e09c                	sd	a5,0(s1)
}
    80004f76:	70a2                	ld	ra,40(sp)
    80004f78:	7402                	ld	s0,32(sp)
    80004f7a:	64e2                	ld	s1,24(sp)
    80004f7c:	6942                	ld	s2,16(sp)
    80004f7e:	6145                	addi	sp,sp,48
    80004f80:	8082                	ret
    return -1;
    80004f82:	557d                	li	a0,-1
    80004f84:	bfcd                	j	80004f76 <argfd+0x50>
    return -1;
    80004f86:	557d                	li	a0,-1
    80004f88:	b7fd                	j	80004f76 <argfd+0x50>
    80004f8a:	557d                	li	a0,-1
    80004f8c:	b7ed                	j	80004f76 <argfd+0x50>

0000000080004f8e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f8e:	1101                	addi	sp,sp,-32
    80004f90:	ec06                	sd	ra,24(sp)
    80004f92:	e822                	sd	s0,16(sp)
    80004f94:	e426                	sd	s1,8(sp)
    80004f96:	1000                	addi	s0,sp,32
    80004f98:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f9a:	ffffd097          	auipc	ra,0xffffd
    80004f9e:	8b2080e7          	jalr	-1870(ra) # 8000184c <myproc>
    80004fa2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fa4:	0d050793          	addi	a5,a0,208
    80004fa8:	4501                	li	a0,0
    80004faa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fac:	6398                	ld	a4,0(a5)
    80004fae:	cb19                	beqz	a4,80004fc4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004fb0:	2505                	addiw	a0,a0,1
    80004fb2:	07a1                	addi	a5,a5,8
    80004fb4:	fed51ce3          	bne	a0,a3,80004fac <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fb8:	557d                	li	a0,-1
}
    80004fba:	60e2                	ld	ra,24(sp)
    80004fbc:	6442                	ld	s0,16(sp)
    80004fbe:	64a2                	ld	s1,8(sp)
    80004fc0:	6105                	addi	sp,sp,32
    80004fc2:	8082                	ret
      p->ofile[fd] = f;
    80004fc4:	01a50793          	addi	a5,a0,26
    80004fc8:	078e                	slli	a5,a5,0x3
    80004fca:	963e                	add	a2,a2,a5
    80004fcc:	e204                	sd	s1,0(a2)
      return fd;
    80004fce:	b7f5                	j	80004fba <fdalloc+0x2c>

0000000080004fd0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fd0:	715d                	addi	sp,sp,-80
    80004fd2:	e486                	sd	ra,72(sp)
    80004fd4:	e0a2                	sd	s0,64(sp)
    80004fd6:	fc26                	sd	s1,56(sp)
    80004fd8:	f84a                	sd	s2,48(sp)
    80004fda:	f44e                	sd	s3,40(sp)
    80004fdc:	f052                	sd	s4,32(sp)
    80004fde:	ec56                	sd	s5,24(sp)
    80004fe0:	0880                	addi	s0,sp,80
    80004fe2:	89ae                	mv	s3,a1
    80004fe4:	8ab2                	mv	s5,a2
    80004fe6:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fe8:	fb040593          	addi	a1,s0,-80
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	c3a080e7          	jalr	-966(ra) # 80003c26 <nameiparent>
    80004ff4:	892a                	mv	s2,a0
    80004ff6:	12050e63          	beqz	a0,80005132 <create+0x162>
    return 0;

  ilock(dp);
    80004ffa:	ffffe097          	auipc	ra,0xffffe
    80004ffe:	482080e7          	jalr	1154(ra) # 8000347c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005002:	4601                	li	a2,0
    80005004:	fb040593          	addi	a1,s0,-80
    80005008:	854a                	mv	a0,s2
    8000500a:	fffff097          	auipc	ra,0xfffff
    8000500e:	92c080e7          	jalr	-1748(ra) # 80003936 <dirlookup>
    80005012:	84aa                	mv	s1,a0
    80005014:	c921                	beqz	a0,80005064 <create+0x94>
    iunlockput(dp);
    80005016:	854a                	mv	a0,s2
    80005018:	ffffe097          	auipc	ra,0xffffe
    8000501c:	6a2080e7          	jalr	1698(ra) # 800036ba <iunlockput>
    ilock(ip);
    80005020:	8526                	mv	a0,s1
    80005022:	ffffe097          	auipc	ra,0xffffe
    80005026:	45a080e7          	jalr	1114(ra) # 8000347c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000502a:	2981                	sext.w	s3,s3
    8000502c:	4789                	li	a5,2
    8000502e:	02f99463          	bne	s3,a5,80005056 <create+0x86>
    80005032:	0444d783          	lhu	a5,68(s1)
    80005036:	37f9                	addiw	a5,a5,-2
    80005038:	17c2                	slli	a5,a5,0x30
    8000503a:	93c1                	srli	a5,a5,0x30
    8000503c:	4705                	li	a4,1
    8000503e:	00f76c63          	bltu	a4,a5,80005056 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005042:	8526                	mv	a0,s1
    80005044:	60a6                	ld	ra,72(sp)
    80005046:	6406                	ld	s0,64(sp)
    80005048:	74e2                	ld	s1,56(sp)
    8000504a:	7942                	ld	s2,48(sp)
    8000504c:	79a2                	ld	s3,40(sp)
    8000504e:	7a02                	ld	s4,32(sp)
    80005050:	6ae2                	ld	s5,24(sp)
    80005052:	6161                	addi	sp,sp,80
    80005054:	8082                	ret
    iunlockput(ip);
    80005056:	8526                	mv	a0,s1
    80005058:	ffffe097          	auipc	ra,0xffffe
    8000505c:	662080e7          	jalr	1634(ra) # 800036ba <iunlockput>
    return 0;
    80005060:	4481                	li	s1,0
    80005062:	b7c5                	j	80005042 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005064:	85ce                	mv	a1,s3
    80005066:	00092503          	lw	a0,0(s2)
    8000506a:	ffffe097          	auipc	ra,0xffffe
    8000506e:	27a080e7          	jalr	634(ra) # 800032e4 <ialloc>
    80005072:	84aa                	mv	s1,a0
    80005074:	c521                	beqz	a0,800050bc <create+0xec>
  ilock(ip);
    80005076:	ffffe097          	auipc	ra,0xffffe
    8000507a:	406080e7          	jalr	1030(ra) # 8000347c <ilock>
  ip->major = major;
    8000507e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005082:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005086:	4a05                	li	s4,1
    80005088:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000508c:	8526                	mv	a0,s1
    8000508e:	ffffe097          	auipc	ra,0xffffe
    80005092:	324080e7          	jalr	804(ra) # 800033b2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005096:	2981                	sext.w	s3,s3
    80005098:	03498a63          	beq	s3,s4,800050cc <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000509c:	40d0                	lw	a2,4(s1)
    8000509e:	fb040593          	addi	a1,s0,-80
    800050a2:	854a                	mv	a0,s2
    800050a4:	fffff097          	auipc	ra,0xfffff
    800050a8:	aa2080e7          	jalr	-1374(ra) # 80003b46 <dirlink>
    800050ac:	06054b63          	bltz	a0,80005122 <create+0x152>
  iunlockput(dp);
    800050b0:	854a                	mv	a0,s2
    800050b2:	ffffe097          	auipc	ra,0xffffe
    800050b6:	608080e7          	jalr	1544(ra) # 800036ba <iunlockput>
  return ip;
    800050ba:	b761                	j	80005042 <create+0x72>
    panic("create: ialloc");
    800050bc:	00003517          	auipc	a0,0x3
    800050c0:	69450513          	addi	a0,a0,1684 # 80008750 <userret+0x6c0>
    800050c4:	ffffb097          	auipc	ra,0xffffb
    800050c8:	48a080e7          	jalr	1162(ra) # 8000054e <panic>
    dp->nlink++;  // for ".."
    800050cc:	04a95783          	lhu	a5,74(s2)
    800050d0:	2785                	addiw	a5,a5,1
    800050d2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800050d6:	854a                	mv	a0,s2
    800050d8:	ffffe097          	auipc	ra,0xffffe
    800050dc:	2da080e7          	jalr	730(ra) # 800033b2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050e0:	40d0                	lw	a2,4(s1)
    800050e2:	00003597          	auipc	a1,0x3
    800050e6:	67e58593          	addi	a1,a1,1662 # 80008760 <userret+0x6d0>
    800050ea:	8526                	mv	a0,s1
    800050ec:	fffff097          	auipc	ra,0xfffff
    800050f0:	a5a080e7          	jalr	-1446(ra) # 80003b46 <dirlink>
    800050f4:	00054f63          	bltz	a0,80005112 <create+0x142>
    800050f8:	00492603          	lw	a2,4(s2)
    800050fc:	00003597          	auipc	a1,0x3
    80005100:	66c58593          	addi	a1,a1,1644 # 80008768 <userret+0x6d8>
    80005104:	8526                	mv	a0,s1
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	a40080e7          	jalr	-1472(ra) # 80003b46 <dirlink>
    8000510e:	f80557e3          	bgez	a0,8000509c <create+0xcc>
      panic("create dots");
    80005112:	00003517          	auipc	a0,0x3
    80005116:	65e50513          	addi	a0,a0,1630 # 80008770 <userret+0x6e0>
    8000511a:	ffffb097          	auipc	ra,0xffffb
    8000511e:	434080e7          	jalr	1076(ra) # 8000054e <panic>
    panic("create: dirlink");
    80005122:	00003517          	auipc	a0,0x3
    80005126:	65e50513          	addi	a0,a0,1630 # 80008780 <userret+0x6f0>
    8000512a:	ffffb097          	auipc	ra,0xffffb
    8000512e:	424080e7          	jalr	1060(ra) # 8000054e <panic>
    return 0;
    80005132:	84aa                	mv	s1,a0
    80005134:	b739                	j	80005042 <create+0x72>

0000000080005136 <sys_dup>:
{
    80005136:	7179                	addi	sp,sp,-48
    80005138:	f406                	sd	ra,40(sp)
    8000513a:	f022                	sd	s0,32(sp)
    8000513c:	ec26                	sd	s1,24(sp)
    8000513e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005140:	fd840613          	addi	a2,s0,-40
    80005144:	4581                	li	a1,0
    80005146:	4501                	li	a0,0
    80005148:	00000097          	auipc	ra,0x0
    8000514c:	dde080e7          	jalr	-546(ra) # 80004f26 <argfd>
    return -1;
    80005150:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005152:	02054363          	bltz	a0,80005178 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005156:	fd843503          	ld	a0,-40(s0)
    8000515a:	00000097          	auipc	ra,0x0
    8000515e:	e34080e7          	jalr	-460(ra) # 80004f8e <fdalloc>
    80005162:	84aa                	mv	s1,a0
    return -1;
    80005164:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005166:	00054963          	bltz	a0,80005178 <sys_dup+0x42>
  filedup(f);
    8000516a:	fd843503          	ld	a0,-40(s0)
    8000516e:	fffff097          	auipc	ra,0xfffff
    80005172:	38c080e7          	jalr	908(ra) # 800044fa <filedup>
  return fd;
    80005176:	87a6                	mv	a5,s1
}
    80005178:	853e                	mv	a0,a5
    8000517a:	70a2                	ld	ra,40(sp)
    8000517c:	7402                	ld	s0,32(sp)
    8000517e:	64e2                	ld	s1,24(sp)
    80005180:	6145                	addi	sp,sp,48
    80005182:	8082                	ret

0000000080005184 <sys_read>:
{
    80005184:	7179                	addi	sp,sp,-48
    80005186:	f406                	sd	ra,40(sp)
    80005188:	f022                	sd	s0,32(sp)
    8000518a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000518c:	fe840613          	addi	a2,s0,-24
    80005190:	4581                	li	a1,0
    80005192:	4501                	li	a0,0
    80005194:	00000097          	auipc	ra,0x0
    80005198:	d92080e7          	jalr	-622(ra) # 80004f26 <argfd>
    return -1;
    8000519c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000519e:	04054163          	bltz	a0,800051e0 <sys_read+0x5c>
    800051a2:	fe440593          	addi	a1,s0,-28
    800051a6:	4509                	li	a0,2
    800051a8:	ffffd097          	auipc	ra,0xffffd
    800051ac:	75e080e7          	jalr	1886(ra) # 80002906 <argint>
    return -1;
    800051b0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051b2:	02054763          	bltz	a0,800051e0 <sys_read+0x5c>
    800051b6:	fd840593          	addi	a1,s0,-40
    800051ba:	4505                	li	a0,1
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	76c080e7          	jalr	1900(ra) # 80002928 <argaddr>
    return -1;
    800051c4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051c6:	00054d63          	bltz	a0,800051e0 <sys_read+0x5c>
  return fileread(f, p, n);
    800051ca:	fe442603          	lw	a2,-28(s0)
    800051ce:	fd843583          	ld	a1,-40(s0)
    800051d2:	fe843503          	ld	a0,-24(s0)
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	4a8080e7          	jalr	1192(ra) # 8000467e <fileread>
    800051de:	87aa                	mv	a5,a0
}
    800051e0:	853e                	mv	a0,a5
    800051e2:	70a2                	ld	ra,40(sp)
    800051e4:	7402                	ld	s0,32(sp)
    800051e6:	6145                	addi	sp,sp,48
    800051e8:	8082                	ret

00000000800051ea <sys_write>:
{
    800051ea:	7179                	addi	sp,sp,-48
    800051ec:	f406                	sd	ra,40(sp)
    800051ee:	f022                	sd	s0,32(sp)
    800051f0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f2:	fe840613          	addi	a2,s0,-24
    800051f6:	4581                	li	a1,0
    800051f8:	4501                	li	a0,0
    800051fa:	00000097          	auipc	ra,0x0
    800051fe:	d2c080e7          	jalr	-724(ra) # 80004f26 <argfd>
    return -1;
    80005202:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005204:	04054163          	bltz	a0,80005246 <sys_write+0x5c>
    80005208:	fe440593          	addi	a1,s0,-28
    8000520c:	4509                	li	a0,2
    8000520e:	ffffd097          	auipc	ra,0xffffd
    80005212:	6f8080e7          	jalr	1784(ra) # 80002906 <argint>
    return -1;
    80005216:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005218:	02054763          	bltz	a0,80005246 <sys_write+0x5c>
    8000521c:	fd840593          	addi	a1,s0,-40
    80005220:	4505                	li	a0,1
    80005222:	ffffd097          	auipc	ra,0xffffd
    80005226:	706080e7          	jalr	1798(ra) # 80002928 <argaddr>
    return -1;
    8000522a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000522c:	00054d63          	bltz	a0,80005246 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005230:	fe442603          	lw	a2,-28(s0)
    80005234:	fd843583          	ld	a1,-40(s0)
    80005238:	fe843503          	ld	a0,-24(s0)
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	4f0080e7          	jalr	1264(ra) # 8000472c <filewrite>
    80005244:	87aa                	mv	a5,a0
}
    80005246:	853e                	mv	a0,a5
    80005248:	70a2                	ld	ra,40(sp)
    8000524a:	7402                	ld	s0,32(sp)
    8000524c:	6145                	addi	sp,sp,48
    8000524e:	8082                	ret

0000000080005250 <sys_close>:
{
    80005250:	1101                	addi	sp,sp,-32
    80005252:	ec06                	sd	ra,24(sp)
    80005254:	e822                	sd	s0,16(sp)
    80005256:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005258:	fe040613          	addi	a2,s0,-32
    8000525c:	fec40593          	addi	a1,s0,-20
    80005260:	4501                	li	a0,0
    80005262:	00000097          	auipc	ra,0x0
    80005266:	cc4080e7          	jalr	-828(ra) # 80004f26 <argfd>
    return -1;
    8000526a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000526c:	02054463          	bltz	a0,80005294 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	5dc080e7          	jalr	1500(ra) # 8000184c <myproc>
    80005278:	fec42783          	lw	a5,-20(s0)
    8000527c:	07e9                	addi	a5,a5,26
    8000527e:	078e                	slli	a5,a5,0x3
    80005280:	97aa                	add	a5,a5,a0
    80005282:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005286:	fe043503          	ld	a0,-32(s0)
    8000528a:	fffff097          	auipc	ra,0xfffff
    8000528e:	2c2080e7          	jalr	706(ra) # 8000454c <fileclose>
  return 0;
    80005292:	4781                	li	a5,0
}
    80005294:	853e                	mv	a0,a5
    80005296:	60e2                	ld	ra,24(sp)
    80005298:	6442                	ld	s0,16(sp)
    8000529a:	6105                	addi	sp,sp,32
    8000529c:	8082                	ret

000000008000529e <sys_fstat>:
{
    8000529e:	1101                	addi	sp,sp,-32
    800052a0:	ec06                	sd	ra,24(sp)
    800052a2:	e822                	sd	s0,16(sp)
    800052a4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052a6:	fe840613          	addi	a2,s0,-24
    800052aa:	4581                	li	a1,0
    800052ac:	4501                	li	a0,0
    800052ae:	00000097          	auipc	ra,0x0
    800052b2:	c78080e7          	jalr	-904(ra) # 80004f26 <argfd>
    return -1;
    800052b6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052b8:	02054563          	bltz	a0,800052e2 <sys_fstat+0x44>
    800052bc:	fe040593          	addi	a1,s0,-32
    800052c0:	4505                	li	a0,1
    800052c2:	ffffd097          	auipc	ra,0xffffd
    800052c6:	666080e7          	jalr	1638(ra) # 80002928 <argaddr>
    return -1;
    800052ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052cc:	00054b63          	bltz	a0,800052e2 <sys_fstat+0x44>
  return filestat(f, st);
    800052d0:	fe043583          	ld	a1,-32(s0)
    800052d4:	fe843503          	ld	a0,-24(s0)
    800052d8:	fffff097          	auipc	ra,0xfffff
    800052dc:	334080e7          	jalr	820(ra) # 8000460c <filestat>
    800052e0:	87aa                	mv	a5,a0
}
    800052e2:	853e                	mv	a0,a5
    800052e4:	60e2                	ld	ra,24(sp)
    800052e6:	6442                	ld	s0,16(sp)
    800052e8:	6105                	addi	sp,sp,32
    800052ea:	8082                	ret

00000000800052ec <sys_link>:
{
    800052ec:	7169                	addi	sp,sp,-304
    800052ee:	f606                	sd	ra,296(sp)
    800052f0:	f222                	sd	s0,288(sp)
    800052f2:	ee26                	sd	s1,280(sp)
    800052f4:	ea4a                	sd	s2,272(sp)
    800052f6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052f8:	08000613          	li	a2,128
    800052fc:	ed040593          	addi	a1,s0,-304
    80005300:	4501                	li	a0,0
    80005302:	ffffd097          	auipc	ra,0xffffd
    80005306:	648080e7          	jalr	1608(ra) # 8000294a <argstr>
    return -1;
    8000530a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000530c:	12054363          	bltz	a0,80005432 <sys_link+0x146>
    80005310:	08000613          	li	a2,128
    80005314:	f5040593          	addi	a1,s0,-176
    80005318:	4505                	li	a0,1
    8000531a:	ffffd097          	auipc	ra,0xffffd
    8000531e:	630080e7          	jalr	1584(ra) # 8000294a <argstr>
    return -1;
    80005322:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005324:	10054763          	bltz	a0,80005432 <sys_link+0x146>
  begin_op(ROOTDEV);
    80005328:	4501                	li	a0,0
    8000532a:	fffff097          	auipc	ra,0xfffff
    8000532e:	bfa080e7          	jalr	-1030(ra) # 80003f24 <begin_op>
  if((ip = namei(old)) == 0){
    80005332:	ed040513          	addi	a0,s0,-304
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	8d2080e7          	jalr	-1838(ra) # 80003c08 <namei>
    8000533e:	84aa                	mv	s1,a0
    80005340:	c559                	beqz	a0,800053ce <sys_link+0xe2>
  ilock(ip);
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	13a080e7          	jalr	314(ra) # 8000347c <ilock>
  if(ip->type == T_DIR){
    8000534a:	04449703          	lh	a4,68(s1)
    8000534e:	4785                	li	a5,1
    80005350:	08f70663          	beq	a4,a5,800053dc <sys_link+0xf0>
  ip->nlink++;
    80005354:	04a4d783          	lhu	a5,74(s1)
    80005358:	2785                	addiw	a5,a5,1
    8000535a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000535e:	8526                	mv	a0,s1
    80005360:	ffffe097          	auipc	ra,0xffffe
    80005364:	052080e7          	jalr	82(ra) # 800033b2 <iupdate>
  iunlock(ip);
    80005368:	8526                	mv	a0,s1
    8000536a:	ffffe097          	auipc	ra,0xffffe
    8000536e:	1d4080e7          	jalr	468(ra) # 8000353e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005372:	fd040593          	addi	a1,s0,-48
    80005376:	f5040513          	addi	a0,s0,-176
    8000537a:	fffff097          	auipc	ra,0xfffff
    8000537e:	8ac080e7          	jalr	-1876(ra) # 80003c26 <nameiparent>
    80005382:	892a                	mv	s2,a0
    80005384:	cd2d                	beqz	a0,800053fe <sys_link+0x112>
  ilock(dp);
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	0f6080e7          	jalr	246(ra) # 8000347c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000538e:	00092703          	lw	a4,0(s2)
    80005392:	409c                	lw	a5,0(s1)
    80005394:	06f71063          	bne	a4,a5,800053f4 <sys_link+0x108>
    80005398:	40d0                	lw	a2,4(s1)
    8000539a:	fd040593          	addi	a1,s0,-48
    8000539e:	854a                	mv	a0,s2
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	7a6080e7          	jalr	1958(ra) # 80003b46 <dirlink>
    800053a8:	04054663          	bltz	a0,800053f4 <sys_link+0x108>
  iunlockput(dp);
    800053ac:	854a                	mv	a0,s2
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	30c080e7          	jalr	780(ra) # 800036ba <iunlockput>
  iput(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	1d2080e7          	jalr	466(ra) # 8000358a <iput>
  end_op(ROOTDEV);
    800053c0:	4501                	li	a0,0
    800053c2:	fffff097          	auipc	ra,0xfffff
    800053c6:	c0c080e7          	jalr	-1012(ra) # 80003fce <end_op>
  return 0;
    800053ca:	4781                	li	a5,0
    800053cc:	a09d                	j	80005432 <sys_link+0x146>
    end_op(ROOTDEV);
    800053ce:	4501                	li	a0,0
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	bfe080e7          	jalr	-1026(ra) # 80003fce <end_op>
    return -1;
    800053d8:	57fd                	li	a5,-1
    800053da:	a8a1                	j	80005432 <sys_link+0x146>
    iunlockput(ip);
    800053dc:	8526                	mv	a0,s1
    800053de:	ffffe097          	auipc	ra,0xffffe
    800053e2:	2dc080e7          	jalr	732(ra) # 800036ba <iunlockput>
    end_op(ROOTDEV);
    800053e6:	4501                	li	a0,0
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	be6080e7          	jalr	-1050(ra) # 80003fce <end_op>
    return -1;
    800053f0:	57fd                	li	a5,-1
    800053f2:	a081                	j	80005432 <sys_link+0x146>
    iunlockput(dp);
    800053f4:	854a                	mv	a0,s2
    800053f6:	ffffe097          	auipc	ra,0xffffe
    800053fa:	2c4080e7          	jalr	708(ra) # 800036ba <iunlockput>
  ilock(ip);
    800053fe:	8526                	mv	a0,s1
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	07c080e7          	jalr	124(ra) # 8000347c <ilock>
  ip->nlink--;
    80005408:	04a4d783          	lhu	a5,74(s1)
    8000540c:	37fd                	addiw	a5,a5,-1
    8000540e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005412:	8526                	mv	a0,s1
    80005414:	ffffe097          	auipc	ra,0xffffe
    80005418:	f9e080e7          	jalr	-98(ra) # 800033b2 <iupdate>
  iunlockput(ip);
    8000541c:	8526                	mv	a0,s1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	29c080e7          	jalr	668(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    80005426:	4501                	li	a0,0
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	ba6080e7          	jalr	-1114(ra) # 80003fce <end_op>
  return -1;
    80005430:	57fd                	li	a5,-1
}
    80005432:	853e                	mv	a0,a5
    80005434:	70b2                	ld	ra,296(sp)
    80005436:	7412                	ld	s0,288(sp)
    80005438:	64f2                	ld	s1,280(sp)
    8000543a:	6952                	ld	s2,272(sp)
    8000543c:	6155                	addi	sp,sp,304
    8000543e:	8082                	ret

0000000080005440 <sys_unlink>:
{
    80005440:	7151                	addi	sp,sp,-240
    80005442:	f586                	sd	ra,232(sp)
    80005444:	f1a2                	sd	s0,224(sp)
    80005446:	eda6                	sd	s1,216(sp)
    80005448:	e9ca                	sd	s2,208(sp)
    8000544a:	e5ce                	sd	s3,200(sp)
    8000544c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000544e:	08000613          	li	a2,128
    80005452:	f3040593          	addi	a1,s0,-208
    80005456:	4501                	li	a0,0
    80005458:	ffffd097          	auipc	ra,0xffffd
    8000545c:	4f2080e7          	jalr	1266(ra) # 8000294a <argstr>
    80005460:	18054463          	bltz	a0,800055e8 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    80005464:	4501                	li	a0,0
    80005466:	fffff097          	auipc	ra,0xfffff
    8000546a:	abe080e7          	jalr	-1346(ra) # 80003f24 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000546e:	fb040593          	addi	a1,s0,-80
    80005472:	f3040513          	addi	a0,s0,-208
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	7b0080e7          	jalr	1968(ra) # 80003c26 <nameiparent>
    8000547e:	84aa                	mv	s1,a0
    80005480:	cd61                	beqz	a0,80005558 <sys_unlink+0x118>
  ilock(dp);
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	ffa080e7          	jalr	-6(ra) # 8000347c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000548a:	00003597          	auipc	a1,0x3
    8000548e:	2d658593          	addi	a1,a1,726 # 80008760 <userret+0x6d0>
    80005492:	fb040513          	addi	a0,s0,-80
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	486080e7          	jalr	1158(ra) # 8000391c <namecmp>
    8000549e:	14050c63          	beqz	a0,800055f6 <sys_unlink+0x1b6>
    800054a2:	00003597          	auipc	a1,0x3
    800054a6:	2c658593          	addi	a1,a1,710 # 80008768 <userret+0x6d8>
    800054aa:	fb040513          	addi	a0,s0,-80
    800054ae:	ffffe097          	auipc	ra,0xffffe
    800054b2:	46e080e7          	jalr	1134(ra) # 8000391c <namecmp>
    800054b6:	14050063          	beqz	a0,800055f6 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054ba:	f2c40613          	addi	a2,s0,-212
    800054be:	fb040593          	addi	a1,s0,-80
    800054c2:	8526                	mv	a0,s1
    800054c4:	ffffe097          	auipc	ra,0xffffe
    800054c8:	472080e7          	jalr	1138(ra) # 80003936 <dirlookup>
    800054cc:	892a                	mv	s2,a0
    800054ce:	12050463          	beqz	a0,800055f6 <sys_unlink+0x1b6>
  ilock(ip);
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	faa080e7          	jalr	-86(ra) # 8000347c <ilock>
  if(ip->nlink < 1)
    800054da:	04a91783          	lh	a5,74(s2)
    800054de:	08f05463          	blez	a5,80005566 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054e2:	04491703          	lh	a4,68(s2)
    800054e6:	4785                	li	a5,1
    800054e8:	08f70763          	beq	a4,a5,80005576 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800054ec:	4641                	li	a2,16
    800054ee:	4581                	li	a1,0
    800054f0:	fc040513          	addi	a0,s0,-64
    800054f4:	ffffb097          	auipc	ra,0xffffb
    800054f8:	6ba080e7          	jalr	1722(ra) # 80000bae <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054fc:	4741                	li	a4,16
    800054fe:	f2c42683          	lw	a3,-212(s0)
    80005502:	fc040613          	addi	a2,s0,-64
    80005506:	4581                	li	a1,0
    80005508:	8526                	mv	a0,s1
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	2f6080e7          	jalr	758(ra) # 80003800 <writei>
    80005512:	47c1                	li	a5,16
    80005514:	0af51763          	bne	a0,a5,800055c2 <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005518:	04491703          	lh	a4,68(s2)
    8000551c:	4785                	li	a5,1
    8000551e:	0af70a63          	beq	a4,a5,800055d2 <sys_unlink+0x192>
  iunlockput(dp);
    80005522:	8526                	mv	a0,s1
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	196080e7          	jalr	406(ra) # 800036ba <iunlockput>
  ip->nlink--;
    8000552c:	04a95783          	lhu	a5,74(s2)
    80005530:	37fd                	addiw	a5,a5,-1
    80005532:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005536:	854a                	mv	a0,s2
    80005538:	ffffe097          	auipc	ra,0xffffe
    8000553c:	e7a080e7          	jalr	-390(ra) # 800033b2 <iupdate>
  iunlockput(ip);
    80005540:	854a                	mv	a0,s2
    80005542:	ffffe097          	auipc	ra,0xffffe
    80005546:	178080e7          	jalr	376(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    8000554a:	4501                	li	a0,0
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	a82080e7          	jalr	-1406(ra) # 80003fce <end_op>
  return 0;
    80005554:	4501                	li	a0,0
    80005556:	a85d                	j	8000560c <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005558:	4501                	li	a0,0
    8000555a:	fffff097          	auipc	ra,0xfffff
    8000555e:	a74080e7          	jalr	-1420(ra) # 80003fce <end_op>
    return -1;
    80005562:	557d                	li	a0,-1
    80005564:	a065                	j	8000560c <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005566:	00003517          	auipc	a0,0x3
    8000556a:	22a50513          	addi	a0,a0,554 # 80008790 <userret+0x700>
    8000556e:	ffffb097          	auipc	ra,0xffffb
    80005572:	fe0080e7          	jalr	-32(ra) # 8000054e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005576:	04c92703          	lw	a4,76(s2)
    8000557a:	02000793          	li	a5,32
    8000557e:	f6e7f7e3          	bgeu	a5,a4,800054ec <sys_unlink+0xac>
    80005582:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005586:	4741                	li	a4,16
    80005588:	86ce                	mv	a3,s3
    8000558a:	f1840613          	addi	a2,s0,-232
    8000558e:	4581                	li	a1,0
    80005590:	854a                	mv	a0,s2
    80005592:	ffffe097          	auipc	ra,0xffffe
    80005596:	17a080e7          	jalr	378(ra) # 8000370c <readi>
    8000559a:	47c1                	li	a5,16
    8000559c:	00f51b63          	bne	a0,a5,800055b2 <sys_unlink+0x172>
    if(de.inum != 0)
    800055a0:	f1845783          	lhu	a5,-232(s0)
    800055a4:	e7a1                	bnez	a5,800055ec <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055a6:	29c1                	addiw	s3,s3,16
    800055a8:	04c92783          	lw	a5,76(s2)
    800055ac:	fcf9ede3          	bltu	s3,a5,80005586 <sys_unlink+0x146>
    800055b0:	bf35                	j	800054ec <sys_unlink+0xac>
      panic("isdirempty: readi");
    800055b2:	00003517          	auipc	a0,0x3
    800055b6:	1f650513          	addi	a0,a0,502 # 800087a8 <userret+0x718>
    800055ba:	ffffb097          	auipc	ra,0xffffb
    800055be:	f94080e7          	jalr	-108(ra) # 8000054e <panic>
    panic("unlink: writei");
    800055c2:	00003517          	auipc	a0,0x3
    800055c6:	1fe50513          	addi	a0,a0,510 # 800087c0 <userret+0x730>
    800055ca:	ffffb097          	auipc	ra,0xffffb
    800055ce:	f84080e7          	jalr	-124(ra) # 8000054e <panic>
    dp->nlink--;
    800055d2:	04a4d783          	lhu	a5,74(s1)
    800055d6:	37fd                	addiw	a5,a5,-1
    800055d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	dd4080e7          	jalr	-556(ra) # 800033b2 <iupdate>
    800055e6:	bf35                	j	80005522 <sys_unlink+0xe2>
    return -1;
    800055e8:	557d                	li	a0,-1
    800055ea:	a00d                	j	8000560c <sys_unlink+0x1cc>
    iunlockput(ip);
    800055ec:	854a                	mv	a0,s2
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	0cc080e7          	jalr	204(ra) # 800036ba <iunlockput>
  iunlockput(dp);
    800055f6:	8526                	mv	a0,s1
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	0c2080e7          	jalr	194(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    80005600:	4501                	li	a0,0
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	9cc080e7          	jalr	-1588(ra) # 80003fce <end_op>
  return -1;
    8000560a:	557d                	li	a0,-1
}
    8000560c:	70ae                	ld	ra,232(sp)
    8000560e:	740e                	ld	s0,224(sp)
    80005610:	64ee                	ld	s1,216(sp)
    80005612:	694e                	ld	s2,208(sp)
    80005614:	69ae                	ld	s3,200(sp)
    80005616:	616d                	addi	sp,sp,240
    80005618:	8082                	ret

000000008000561a <sys_open>:

uint64
sys_open(void)
{
    8000561a:	7131                	addi	sp,sp,-192
    8000561c:	fd06                	sd	ra,184(sp)
    8000561e:	f922                	sd	s0,176(sp)
    80005620:	f526                	sd	s1,168(sp)
    80005622:	f14a                	sd	s2,160(sp)
    80005624:	ed4e                	sd	s3,152(sp)
    80005626:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005628:	08000613          	li	a2,128
    8000562c:	f5040593          	addi	a1,s0,-176
    80005630:	4501                	li	a0,0
    80005632:	ffffd097          	auipc	ra,0xffffd
    80005636:	318080e7          	jalr	792(ra) # 8000294a <argstr>
    return -1;
    8000563a:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000563c:	0a054963          	bltz	a0,800056ee <sys_open+0xd4>
    80005640:	f4c40593          	addi	a1,s0,-180
    80005644:	4505                	li	a0,1
    80005646:	ffffd097          	auipc	ra,0xffffd
    8000564a:	2c0080e7          	jalr	704(ra) # 80002906 <argint>
    8000564e:	0a054063          	bltz	a0,800056ee <sys_open+0xd4>

  begin_op(ROOTDEV);
    80005652:	4501                	li	a0,0
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	8d0080e7          	jalr	-1840(ra) # 80003f24 <begin_op>

  if(omode & O_CREATE){
    8000565c:	f4c42783          	lw	a5,-180(s0)
    80005660:	2007f793          	andi	a5,a5,512
    80005664:	c3dd                	beqz	a5,8000570a <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005666:	4681                	li	a3,0
    80005668:	4601                	li	a2,0
    8000566a:	4589                	li	a1,2
    8000566c:	f5040513          	addi	a0,s0,-176
    80005670:	00000097          	auipc	ra,0x0
    80005674:	960080e7          	jalr	-1696(ra) # 80004fd0 <create>
    80005678:	892a                	mv	s2,a0
    if(ip == 0){
    8000567a:	c151                	beqz	a0,800056fe <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000567c:	04491703          	lh	a4,68(s2)
    80005680:	478d                	li	a5,3
    80005682:	00f71763          	bne	a4,a5,80005690 <sys_open+0x76>
    80005686:	04695703          	lhu	a4,70(s2)
    8000568a:	47a5                	li	a5,9
    8000568c:	0ce7e663          	bltu	a5,a4,80005758 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005690:	fffff097          	auipc	ra,0xfffff
    80005694:	e00080e7          	jalr	-512(ra) # 80004490 <filealloc>
    80005698:	89aa                	mv	s3,a0
    8000569a:	c57d                	beqz	a0,80005788 <sys_open+0x16e>
    8000569c:	00000097          	auipc	ra,0x0
    800056a0:	8f2080e7          	jalr	-1806(ra) # 80004f8e <fdalloc>
    800056a4:	84aa                	mv	s1,a0
    800056a6:	0c054c63          	bltz	a0,8000577e <sys_open+0x164>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    800056aa:	04491703          	lh	a4,68(s2)
    800056ae:	478d                	li	a5,3
    800056b0:	0cf70063          	beq	a4,a5,80005770 <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800056b4:	4789                	li	a5,2
    800056b6:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800056ba:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800056be:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800056c2:	f4c42783          	lw	a5,-180(s0)
    800056c6:	0017c713          	xori	a4,a5,1
    800056ca:	8b05                	andi	a4,a4,1
    800056cc:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800056d0:	8b8d                	andi	a5,a5,3
    800056d2:	00f037b3          	snez	a5,a5
    800056d6:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    800056da:	854a                	mv	a0,s2
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	e62080e7          	jalr	-414(ra) # 8000353e <iunlock>
  end_op(ROOTDEV);
    800056e4:	4501                	li	a0,0
    800056e6:	fffff097          	auipc	ra,0xfffff
    800056ea:	8e8080e7          	jalr	-1816(ra) # 80003fce <end_op>

  return fd;
}
    800056ee:	8526                	mv	a0,s1
    800056f0:	70ea                	ld	ra,184(sp)
    800056f2:	744a                	ld	s0,176(sp)
    800056f4:	74aa                	ld	s1,168(sp)
    800056f6:	790a                	ld	s2,160(sp)
    800056f8:	69ea                	ld	s3,152(sp)
    800056fa:	6129                	addi	sp,sp,192
    800056fc:	8082                	ret
      end_op(ROOTDEV);
    800056fe:	4501                	li	a0,0
    80005700:	fffff097          	auipc	ra,0xfffff
    80005704:	8ce080e7          	jalr	-1842(ra) # 80003fce <end_op>
      return -1;
    80005708:	b7dd                	j	800056ee <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    8000570a:	f5040513          	addi	a0,s0,-176
    8000570e:	ffffe097          	auipc	ra,0xffffe
    80005712:	4fa080e7          	jalr	1274(ra) # 80003c08 <namei>
    80005716:	892a                	mv	s2,a0
    80005718:	c90d                	beqz	a0,8000574a <sys_open+0x130>
    ilock(ip);
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	d62080e7          	jalr	-670(ra) # 8000347c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005722:	04491703          	lh	a4,68(s2)
    80005726:	4785                	li	a5,1
    80005728:	f4f71ae3          	bne	a4,a5,8000567c <sys_open+0x62>
    8000572c:	f4c42783          	lw	a5,-180(s0)
    80005730:	d3a5                	beqz	a5,80005690 <sys_open+0x76>
      iunlockput(ip);
    80005732:	854a                	mv	a0,s2
    80005734:	ffffe097          	auipc	ra,0xffffe
    80005738:	f86080e7          	jalr	-122(ra) # 800036ba <iunlockput>
      end_op(ROOTDEV);
    8000573c:	4501                	li	a0,0
    8000573e:	fffff097          	auipc	ra,0xfffff
    80005742:	890080e7          	jalr	-1904(ra) # 80003fce <end_op>
      return -1;
    80005746:	54fd                	li	s1,-1
    80005748:	b75d                	j	800056ee <sys_open+0xd4>
      end_op(ROOTDEV);
    8000574a:	4501                	li	a0,0
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	882080e7          	jalr	-1918(ra) # 80003fce <end_op>
      return -1;
    80005754:	54fd                	li	s1,-1
    80005756:	bf61                	j	800056ee <sys_open+0xd4>
    iunlockput(ip);
    80005758:	854a                	mv	a0,s2
    8000575a:	ffffe097          	auipc	ra,0xffffe
    8000575e:	f60080e7          	jalr	-160(ra) # 800036ba <iunlockput>
    end_op(ROOTDEV);
    80005762:	4501                	li	a0,0
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	86a080e7          	jalr	-1942(ra) # 80003fce <end_op>
    return -1;
    8000576c:	54fd                	li	s1,-1
    8000576e:	b741                	j	800056ee <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005770:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005774:	04691783          	lh	a5,70(s2)
    80005778:	02f99223          	sh	a5,36(s3)
    8000577c:	b789                	j	800056be <sys_open+0xa4>
      fileclose(f);
    8000577e:	854e                	mv	a0,s3
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	dcc080e7          	jalr	-564(ra) # 8000454c <fileclose>
    iunlockput(ip);
    80005788:	854a                	mv	a0,s2
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	f30080e7          	jalr	-208(ra) # 800036ba <iunlockput>
    end_op(ROOTDEV);
    80005792:	4501                	li	a0,0
    80005794:	fffff097          	auipc	ra,0xfffff
    80005798:	83a080e7          	jalr	-1990(ra) # 80003fce <end_op>
    return -1;
    8000579c:	54fd                	li	s1,-1
    8000579e:	bf81                	j	800056ee <sys_open+0xd4>

00000000800057a0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800057a0:	7175                	addi	sp,sp,-144
    800057a2:	e506                	sd	ra,136(sp)
    800057a4:	e122                	sd	s0,128(sp)
    800057a6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    800057a8:	4501                	li	a0,0
    800057aa:	ffffe097          	auipc	ra,0xffffe
    800057ae:	77a080e7          	jalr	1914(ra) # 80003f24 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800057b2:	08000613          	li	a2,128
    800057b6:	f7040593          	addi	a1,s0,-144
    800057ba:	4501                	li	a0,0
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	18e080e7          	jalr	398(ra) # 8000294a <argstr>
    800057c4:	02054a63          	bltz	a0,800057f8 <sys_mkdir+0x58>
    800057c8:	4681                	li	a3,0
    800057ca:	4601                	li	a2,0
    800057cc:	4585                	li	a1,1
    800057ce:	f7040513          	addi	a0,s0,-144
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	7fe080e7          	jalr	2046(ra) # 80004fd0 <create>
    800057da:	cd19                	beqz	a0,800057f8 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800057dc:	ffffe097          	auipc	ra,0xffffe
    800057e0:	ede080e7          	jalr	-290(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    800057e4:	4501                	li	a0,0
    800057e6:	ffffe097          	auipc	ra,0xffffe
    800057ea:	7e8080e7          	jalr	2024(ra) # 80003fce <end_op>
  return 0;
    800057ee:	4501                	li	a0,0
}
    800057f0:	60aa                	ld	ra,136(sp)
    800057f2:	640a                	ld	s0,128(sp)
    800057f4:	6149                	addi	sp,sp,144
    800057f6:	8082                	ret
    end_op(ROOTDEV);
    800057f8:	4501                	li	a0,0
    800057fa:	ffffe097          	auipc	ra,0xffffe
    800057fe:	7d4080e7          	jalr	2004(ra) # 80003fce <end_op>
    return -1;
    80005802:	557d                	li	a0,-1
    80005804:	b7f5                	j	800057f0 <sys_mkdir+0x50>

0000000080005806 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005806:	7135                	addi	sp,sp,-160
    80005808:	ed06                	sd	ra,152(sp)
    8000580a:	e922                	sd	s0,144(sp)
    8000580c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    8000580e:	4501                	li	a0,0
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	714080e7          	jalr	1812(ra) # 80003f24 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005818:	08000613          	li	a2,128
    8000581c:	f7040593          	addi	a1,s0,-144
    80005820:	4501                	li	a0,0
    80005822:	ffffd097          	auipc	ra,0xffffd
    80005826:	128080e7          	jalr	296(ra) # 8000294a <argstr>
    8000582a:	04054b63          	bltz	a0,80005880 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    8000582e:	f6c40593          	addi	a1,s0,-148
    80005832:	4505                	li	a0,1
    80005834:	ffffd097          	auipc	ra,0xffffd
    80005838:	0d2080e7          	jalr	210(ra) # 80002906 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000583c:	04054263          	bltz	a0,80005880 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005840:	f6840593          	addi	a1,s0,-152
    80005844:	4509                	li	a0,2
    80005846:	ffffd097          	auipc	ra,0xffffd
    8000584a:	0c0080e7          	jalr	192(ra) # 80002906 <argint>
     argint(1, &major) < 0 ||
    8000584e:	02054963          	bltz	a0,80005880 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005852:	f6841683          	lh	a3,-152(s0)
    80005856:	f6c41603          	lh	a2,-148(s0)
    8000585a:	458d                	li	a1,3
    8000585c:	f7040513          	addi	a0,s0,-144
    80005860:	fffff097          	auipc	ra,0xfffff
    80005864:	770080e7          	jalr	1904(ra) # 80004fd0 <create>
     argint(2, &minor) < 0 ||
    80005868:	cd01                	beqz	a0,80005880 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	e50080e7          	jalr	-432(ra) # 800036ba <iunlockput>
  end_op(ROOTDEV);
    80005872:	4501                	li	a0,0
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	75a080e7          	jalr	1882(ra) # 80003fce <end_op>
  return 0;
    8000587c:	4501                	li	a0,0
    8000587e:	a039                	j	8000588c <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005880:	4501                	li	a0,0
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	74c080e7          	jalr	1868(ra) # 80003fce <end_op>
    return -1;
    8000588a:	557d                	li	a0,-1
}
    8000588c:	60ea                	ld	ra,152(sp)
    8000588e:	644a                	ld	s0,144(sp)
    80005890:	610d                	addi	sp,sp,160
    80005892:	8082                	ret

0000000080005894 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005894:	7135                	addi	sp,sp,-160
    80005896:	ed06                	sd	ra,152(sp)
    80005898:	e922                	sd	s0,144(sp)
    8000589a:	e526                	sd	s1,136(sp)
    8000589c:	e14a                	sd	s2,128(sp)
    8000589e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800058a0:	ffffc097          	auipc	ra,0xffffc
    800058a4:	fac080e7          	jalr	-84(ra) # 8000184c <myproc>
    800058a8:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    800058aa:	4501                	li	a0,0
    800058ac:	ffffe097          	auipc	ra,0xffffe
    800058b0:	678080e7          	jalr	1656(ra) # 80003f24 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800058b4:	08000613          	li	a2,128
    800058b8:	f6040593          	addi	a1,s0,-160
    800058bc:	4501                	li	a0,0
    800058be:	ffffd097          	auipc	ra,0xffffd
    800058c2:	08c080e7          	jalr	140(ra) # 8000294a <argstr>
    800058c6:	04054c63          	bltz	a0,8000591e <sys_chdir+0x8a>
    800058ca:	f6040513          	addi	a0,s0,-160
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	33a080e7          	jalr	826(ra) # 80003c08 <namei>
    800058d6:	84aa                	mv	s1,a0
    800058d8:	c139                	beqz	a0,8000591e <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	ba2080e7          	jalr	-1118(ra) # 8000347c <ilock>
  if(ip->type != T_DIR){
    800058e2:	04449703          	lh	a4,68(s1)
    800058e6:	4785                	li	a5,1
    800058e8:	04f71263          	bne	a4,a5,8000592c <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    800058ec:	8526                	mv	a0,s1
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	c50080e7          	jalr	-944(ra) # 8000353e <iunlock>
  iput(p->cwd);
    800058f6:	15093503          	ld	a0,336(s2)
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	c90080e7          	jalr	-880(ra) # 8000358a <iput>
  end_op(ROOTDEV);
    80005902:	4501                	li	a0,0
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	6ca080e7          	jalr	1738(ra) # 80003fce <end_op>
  p->cwd = ip;
    8000590c:	14993823          	sd	s1,336(s2)
  return 0;
    80005910:	4501                	li	a0,0
}
    80005912:	60ea                	ld	ra,152(sp)
    80005914:	644a                	ld	s0,144(sp)
    80005916:	64aa                	ld	s1,136(sp)
    80005918:	690a                	ld	s2,128(sp)
    8000591a:	610d                	addi	sp,sp,160
    8000591c:	8082                	ret
    end_op(ROOTDEV);
    8000591e:	4501                	li	a0,0
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	6ae080e7          	jalr	1710(ra) # 80003fce <end_op>
    return -1;
    80005928:	557d                	li	a0,-1
    8000592a:	b7e5                	j	80005912 <sys_chdir+0x7e>
    iunlockput(ip);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffe097          	auipc	ra,0xffffe
    80005932:	d8c080e7          	jalr	-628(ra) # 800036ba <iunlockput>
    end_op(ROOTDEV);
    80005936:	4501                	li	a0,0
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	696080e7          	jalr	1686(ra) # 80003fce <end_op>
    return -1;
    80005940:	557d                	li	a0,-1
    80005942:	bfc1                	j	80005912 <sys_chdir+0x7e>

0000000080005944 <sys_exec>:

uint64
sys_exec(void)
{
    80005944:	7145                	addi	sp,sp,-464
    80005946:	e786                	sd	ra,456(sp)
    80005948:	e3a2                	sd	s0,448(sp)
    8000594a:	ff26                	sd	s1,440(sp)
    8000594c:	fb4a                	sd	s2,432(sp)
    8000594e:	f74e                	sd	s3,424(sp)
    80005950:	f352                	sd	s4,416(sp)
    80005952:	ef56                	sd	s5,408(sp)
    80005954:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005956:	08000613          	li	a2,128
    8000595a:	f4040593          	addi	a1,s0,-192
    8000595e:	4501                	li	a0,0
    80005960:	ffffd097          	auipc	ra,0xffffd
    80005964:	fea080e7          	jalr	-22(ra) # 8000294a <argstr>
    80005968:	0c054863          	bltz	a0,80005a38 <sys_exec+0xf4>
    8000596c:	e3840593          	addi	a1,s0,-456
    80005970:	4505                	li	a0,1
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	fb6080e7          	jalr	-74(ra) # 80002928 <argaddr>
    8000597a:	0c054963          	bltz	a0,80005a4c <sys_exec+0x108>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    8000597e:	10000613          	li	a2,256
    80005982:	4581                	li	a1,0
    80005984:	e4040513          	addi	a0,s0,-448
    80005988:	ffffb097          	auipc	ra,0xffffb
    8000598c:	226080e7          	jalr	550(ra) # 80000bae <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005990:	e4040993          	addi	s3,s0,-448
  memset(argv, 0, sizeof(argv));
    80005994:	894e                	mv	s2,s3
    80005996:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005998:	02000a13          	li	s4,32
    8000599c:	00048a9b          	sext.w	s5,s1
      return -1;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800059a0:	00349513          	slli	a0,s1,0x3
    800059a4:	e3040593          	addi	a1,s0,-464
    800059a8:	e3843783          	ld	a5,-456(s0)
    800059ac:	953e                	add	a0,a0,a5
    800059ae:	ffffd097          	auipc	ra,0xffffd
    800059b2:	ebe080e7          	jalr	-322(ra) # 8000286c <fetchaddr>
    800059b6:	08054d63          	bltz	a0,80005a50 <sys_exec+0x10c>
      return -1;
    }
    if(uarg == 0){
    800059ba:	e3043783          	ld	a5,-464(s0)
    800059be:	cb85                	beqz	a5,800059ee <sys_exec+0xaa>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800059c0:	ffffb097          	auipc	ra,0xffffb
    800059c4:	fb8080e7          	jalr	-72(ra) # 80000978 <kalloc>
    800059c8:	85aa                	mv	a1,a0
    800059ca:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    800059ce:	cd29                	beqz	a0,80005a28 <sys_exec+0xe4>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    800059d0:	6605                	lui	a2,0x1
    800059d2:	e3043503          	ld	a0,-464(s0)
    800059d6:	ffffd097          	auipc	ra,0xffffd
    800059da:	ee8080e7          	jalr	-280(ra) # 800028be <fetchstr>
    800059de:	06054b63          	bltz	a0,80005a54 <sys_exec+0x110>
    if(i >= NELEM(argv)){
    800059e2:	0485                	addi	s1,s1,1
    800059e4:	0921                	addi	s2,s2,8
    800059e6:	fb449be3          	bne	s1,s4,8000599c <sys_exec+0x58>
      return -1;
    800059ea:	557d                	li	a0,-1
    800059ec:	a0b9                	j	80005a3a <sys_exec+0xf6>
      argv[i] = 0;
    800059ee:	0a8e                	slli	s5,s5,0x3
    800059f0:	fc040793          	addi	a5,s0,-64
    800059f4:	9abe                	add	s5,s5,a5
    800059f6:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd5e24>
      return -1;
    }
  }

  int ret = exec(path, argv);
    800059fa:	e4040593          	addi	a1,s0,-448
    800059fe:	f4040513          	addi	a0,s0,-192
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	1ba080e7          	jalr	442(ra) # 80004bbc <exec>
    80005a0a:	84aa                	mv	s1,a0

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a0c:	10098913          	addi	s2,s3,256
    80005a10:	0009b503          	ld	a0,0(s3)
    80005a14:	c901                	beqz	a0,80005a24 <sys_exec+0xe0>
    kfree(argv[i]);
    80005a16:	ffffb097          	auipc	ra,0xffffb
    80005a1a:	e4e080e7          	jalr	-434(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a1e:	09a1                	addi	s3,s3,8
    80005a20:	ff2998e3          	bne	s3,s2,80005a10 <sys_exec+0xcc>

  return ret;
    80005a24:	8526                	mv	a0,s1
    80005a26:	a811                	j	80005a3a <sys_exec+0xf6>
      panic("sys_exec kalloc");
    80005a28:	00003517          	auipc	a0,0x3
    80005a2c:	da850513          	addi	a0,a0,-600 # 800087d0 <userret+0x740>
    80005a30:	ffffb097          	auipc	ra,0xffffb
    80005a34:	b1e080e7          	jalr	-1250(ra) # 8000054e <panic>
    return -1;
    80005a38:	557d                	li	a0,-1
}
    80005a3a:	60be                	ld	ra,456(sp)
    80005a3c:	641e                	ld	s0,448(sp)
    80005a3e:	74fa                	ld	s1,440(sp)
    80005a40:	795a                	ld	s2,432(sp)
    80005a42:	79ba                	ld	s3,424(sp)
    80005a44:	7a1a                	ld	s4,416(sp)
    80005a46:	6afa                	ld	s5,408(sp)
    80005a48:	6179                	addi	sp,sp,464
    80005a4a:	8082                	ret
    return -1;
    80005a4c:	557d                	li	a0,-1
    80005a4e:	b7f5                	j	80005a3a <sys_exec+0xf6>
      return -1;
    80005a50:	557d                	li	a0,-1
    80005a52:	b7e5                	j	80005a3a <sys_exec+0xf6>
      return -1;
    80005a54:	557d                	li	a0,-1
    80005a56:	b7d5                	j	80005a3a <sys_exec+0xf6>

0000000080005a58 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a58:	7139                	addi	sp,sp,-64
    80005a5a:	fc06                	sd	ra,56(sp)
    80005a5c:	f822                	sd	s0,48(sp)
    80005a5e:	f426                	sd	s1,40(sp)
    80005a60:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a62:	ffffc097          	auipc	ra,0xffffc
    80005a66:	dea080e7          	jalr	-534(ra) # 8000184c <myproc>
    80005a6a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005a6c:	fd840593          	addi	a1,s0,-40
    80005a70:	4501                	li	a0,0
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	eb6080e7          	jalr	-330(ra) # 80002928 <argaddr>
    return -1;
    80005a7a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005a7c:	0e054063          	bltz	a0,80005b5c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005a80:	fc840593          	addi	a1,s0,-56
    80005a84:	fd040513          	addi	a0,s0,-48
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	de8080e7          	jalr	-536(ra) # 80004870 <pipealloc>
    return -1;
    80005a90:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a92:	0c054563          	bltz	a0,80005b5c <sys_pipe+0x104>
  fd0 = -1;
    80005a96:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a9a:	fd043503          	ld	a0,-48(s0)
    80005a9e:	fffff097          	auipc	ra,0xfffff
    80005aa2:	4f0080e7          	jalr	1264(ra) # 80004f8e <fdalloc>
    80005aa6:	fca42223          	sw	a0,-60(s0)
    80005aaa:	08054c63          	bltz	a0,80005b42 <sys_pipe+0xea>
    80005aae:	fc843503          	ld	a0,-56(s0)
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	4dc080e7          	jalr	1244(ra) # 80004f8e <fdalloc>
    80005aba:	fca42023          	sw	a0,-64(s0)
    80005abe:	06054863          	bltz	a0,80005b2e <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ac2:	4691                	li	a3,4
    80005ac4:	fc440613          	addi	a2,s0,-60
    80005ac8:	fd843583          	ld	a1,-40(s0)
    80005acc:	68a8                	ld	a0,80(s1)
    80005ace:	ffffc097          	auipc	ra,0xffffc
    80005ad2:	aa4080e7          	jalr	-1372(ra) # 80001572 <copyout>
    80005ad6:	02054063          	bltz	a0,80005af6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ada:	4691                	li	a3,4
    80005adc:	fc040613          	addi	a2,s0,-64
    80005ae0:	fd843583          	ld	a1,-40(s0)
    80005ae4:	0591                	addi	a1,a1,4
    80005ae6:	68a8                	ld	a0,80(s1)
    80005ae8:	ffffc097          	auipc	ra,0xffffc
    80005aec:	a8a080e7          	jalr	-1398(ra) # 80001572 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005af0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005af2:	06055563          	bgez	a0,80005b5c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005af6:	fc442783          	lw	a5,-60(s0)
    80005afa:	07e9                	addi	a5,a5,26
    80005afc:	078e                	slli	a5,a5,0x3
    80005afe:	97a6                	add	a5,a5,s1
    80005b00:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b04:	fc042503          	lw	a0,-64(s0)
    80005b08:	0569                	addi	a0,a0,26
    80005b0a:	050e                	slli	a0,a0,0x3
    80005b0c:	9526                	add	a0,a0,s1
    80005b0e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b12:	fd043503          	ld	a0,-48(s0)
    80005b16:	fffff097          	auipc	ra,0xfffff
    80005b1a:	a36080e7          	jalr	-1482(ra) # 8000454c <fileclose>
    fileclose(wf);
    80005b1e:	fc843503          	ld	a0,-56(s0)
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	a2a080e7          	jalr	-1494(ra) # 8000454c <fileclose>
    return -1;
    80005b2a:	57fd                	li	a5,-1
    80005b2c:	a805                	j	80005b5c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005b2e:	fc442783          	lw	a5,-60(s0)
    80005b32:	0007c863          	bltz	a5,80005b42 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005b36:	01a78513          	addi	a0,a5,26
    80005b3a:	050e                	slli	a0,a0,0x3
    80005b3c:	9526                	add	a0,a0,s1
    80005b3e:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b42:	fd043503          	ld	a0,-48(s0)
    80005b46:	fffff097          	auipc	ra,0xfffff
    80005b4a:	a06080e7          	jalr	-1530(ra) # 8000454c <fileclose>
    fileclose(wf);
    80005b4e:	fc843503          	ld	a0,-56(s0)
    80005b52:	fffff097          	auipc	ra,0xfffff
    80005b56:	9fa080e7          	jalr	-1542(ra) # 8000454c <fileclose>
    return -1;
    80005b5a:	57fd                	li	a5,-1
}
    80005b5c:	853e                	mv	a0,a5
    80005b5e:	70e2                	ld	ra,56(sp)
    80005b60:	7442                	ld	s0,48(sp)
    80005b62:	74a2                	ld	s1,40(sp)
    80005b64:	6121                	addi	sp,sp,64
    80005b66:	8082                	ret

0000000080005b68 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005b68:	7171                	addi	sp,sp,-176
    80005b6a:	f506                	sd	ra,168(sp)
    80005b6c:	f122                	sd	s0,160(sp)
    80005b6e:	ed26                	sd	s1,152(sp)
    80005b70:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005b72:	08000613          	li	a2,128
    80005b76:	f6040593          	addi	a1,s0,-160
    80005b7a:	4501                	li	a0,0
    80005b7c:	ffffd097          	auipc	ra,0xffffd
    80005b80:	dce080e7          	jalr	-562(ra) # 8000294a <argstr>
    return -1;
    80005b84:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005b86:	04054363          	bltz	a0,80005bcc <sys_crash+0x64>
    80005b8a:	f5c40593          	addi	a1,s0,-164
    80005b8e:	4505                	li	a0,1
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	d76080e7          	jalr	-650(ra) # 80002906 <argint>
    return -1;
    80005b98:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005b9a:	02054963          	bltz	a0,80005bcc <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005b9e:	4681                	li	a3,0
    80005ba0:	4601                	li	a2,0
    80005ba2:	4589                	li	a1,2
    80005ba4:	f6040513          	addi	a0,s0,-160
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	428080e7          	jalr	1064(ra) # 80004fd0 <create>
    80005bb0:	84aa                	mv	s1,a0
  if(ip == 0){
    80005bb2:	c11d                	beqz	a0,80005bd8 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	b06080e7          	jalr	-1274(ra) # 800036ba <iunlockput>
  crash_op(ip->dev, crash);
    80005bbc:	f5c42583          	lw	a1,-164(s0)
    80005bc0:	4088                	lw	a0,0(s1)
    80005bc2:	ffffe097          	auipc	ra,0xffffe
    80005bc6:	65e080e7          	jalr	1630(ra) # 80004220 <crash_op>
  return 0;
    80005bca:	4781                	li	a5,0
}
    80005bcc:	853e                	mv	a0,a5
    80005bce:	70aa                	ld	ra,168(sp)
    80005bd0:	740a                	ld	s0,160(sp)
    80005bd2:	64ea                	ld	s1,152(sp)
    80005bd4:	614d                	addi	sp,sp,176
    80005bd6:	8082                	ret
    return -1;
    80005bd8:	57fd                	li	a5,-1
    80005bda:	bfcd                	j	80005bcc <sys_crash+0x64>
    80005bdc:	0000                	unimp
	...

0000000080005be0 <kernelvec>:
    80005be0:	7111                	addi	sp,sp,-256
    80005be2:	e006                	sd	ra,0(sp)
    80005be4:	e40a                	sd	sp,8(sp)
    80005be6:	e80e                	sd	gp,16(sp)
    80005be8:	ec12                	sd	tp,24(sp)
    80005bea:	f016                	sd	t0,32(sp)
    80005bec:	f41a                	sd	t1,40(sp)
    80005bee:	f81e                	sd	t2,48(sp)
    80005bf0:	fc22                	sd	s0,56(sp)
    80005bf2:	e0a6                	sd	s1,64(sp)
    80005bf4:	e4aa                	sd	a0,72(sp)
    80005bf6:	e8ae                	sd	a1,80(sp)
    80005bf8:	ecb2                	sd	a2,88(sp)
    80005bfa:	f0b6                	sd	a3,96(sp)
    80005bfc:	f4ba                	sd	a4,104(sp)
    80005bfe:	f8be                	sd	a5,112(sp)
    80005c00:	fcc2                	sd	a6,120(sp)
    80005c02:	e146                	sd	a7,128(sp)
    80005c04:	e54a                	sd	s2,136(sp)
    80005c06:	e94e                	sd	s3,144(sp)
    80005c08:	ed52                	sd	s4,152(sp)
    80005c0a:	f156                	sd	s5,160(sp)
    80005c0c:	f55a                	sd	s6,168(sp)
    80005c0e:	f95e                	sd	s7,176(sp)
    80005c10:	fd62                	sd	s8,184(sp)
    80005c12:	e1e6                	sd	s9,192(sp)
    80005c14:	e5ea                	sd	s10,200(sp)
    80005c16:	e9ee                	sd	s11,208(sp)
    80005c18:	edf2                	sd	t3,216(sp)
    80005c1a:	f1f6                	sd	t4,224(sp)
    80005c1c:	f5fa                	sd	t5,232(sp)
    80005c1e:	f9fe                	sd	t6,240(sp)
    80005c20:	b19fc0ef          	jal	ra,80002738 <kerneltrap>
    80005c24:	6082                	ld	ra,0(sp)
    80005c26:	6122                	ld	sp,8(sp)
    80005c28:	61c2                	ld	gp,16(sp)
    80005c2a:	7282                	ld	t0,32(sp)
    80005c2c:	7322                	ld	t1,40(sp)
    80005c2e:	73c2                	ld	t2,48(sp)
    80005c30:	7462                	ld	s0,56(sp)
    80005c32:	6486                	ld	s1,64(sp)
    80005c34:	6526                	ld	a0,72(sp)
    80005c36:	65c6                	ld	a1,80(sp)
    80005c38:	6666                	ld	a2,88(sp)
    80005c3a:	7686                	ld	a3,96(sp)
    80005c3c:	7726                	ld	a4,104(sp)
    80005c3e:	77c6                	ld	a5,112(sp)
    80005c40:	7866                	ld	a6,120(sp)
    80005c42:	688a                	ld	a7,128(sp)
    80005c44:	692a                	ld	s2,136(sp)
    80005c46:	69ca                	ld	s3,144(sp)
    80005c48:	6a6a                	ld	s4,152(sp)
    80005c4a:	7a8a                	ld	s5,160(sp)
    80005c4c:	7b2a                	ld	s6,168(sp)
    80005c4e:	7bca                	ld	s7,176(sp)
    80005c50:	7c6a                	ld	s8,184(sp)
    80005c52:	6c8e                	ld	s9,192(sp)
    80005c54:	6d2e                	ld	s10,200(sp)
    80005c56:	6dce                	ld	s11,208(sp)
    80005c58:	6e6e                	ld	t3,216(sp)
    80005c5a:	7e8e                	ld	t4,224(sp)
    80005c5c:	7f2e                	ld	t5,232(sp)
    80005c5e:	7fce                	ld	t6,240(sp)
    80005c60:	6111                	addi	sp,sp,256
    80005c62:	10200073          	sret
    80005c66:	00000013          	nop
    80005c6a:	00000013          	nop
    80005c6e:	0001                	nop

0000000080005c70 <timervec>:
    80005c70:	34051573          	csrrw	a0,mscratch,a0
    80005c74:	e10c                	sd	a1,0(a0)
    80005c76:	e510                	sd	a2,8(a0)
    80005c78:	e914                	sd	a3,16(a0)
    80005c7a:	710c                	ld	a1,32(a0)
    80005c7c:	7510                	ld	a2,40(a0)
    80005c7e:	6194                	ld	a3,0(a1)
    80005c80:	96b2                	add	a3,a3,a2
    80005c82:	e194                	sd	a3,0(a1)
    80005c84:	4589                	li	a1,2
    80005c86:	14459073          	csrw	sip,a1
    80005c8a:	6914                	ld	a3,16(a0)
    80005c8c:	6510                	ld	a2,8(a0)
    80005c8e:	610c                	ld	a1,0(a0)
    80005c90:	34051573          	csrrw	a0,mscratch,a0
    80005c94:	30200073          	mret
	...

0000000080005c9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c9a:	1141                	addi	sp,sp,-16
    80005c9c:	e422                	sd	s0,8(sp)
    80005c9e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ca0:	0c0007b7          	lui	a5,0xc000
    80005ca4:	4705                	li	a4,1
    80005ca6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ca8:	c3d8                	sw	a4,4(a5)
}
    80005caa:	6422                	ld	s0,8(sp)
    80005cac:	0141                	addi	sp,sp,16
    80005cae:	8082                	ret

0000000080005cb0 <plicinithart>:

void
plicinithart(void)
{
    80005cb0:	1141                	addi	sp,sp,-16
    80005cb2:	e406                	sd	ra,8(sp)
    80005cb4:	e022                	sd	s0,0(sp)
    80005cb6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	b68080e7          	jalr	-1176(ra) # 80001820 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cc0:	0085171b          	slliw	a4,a0,0x8
    80005cc4:	0c0027b7          	lui	a5,0xc002
    80005cc8:	97ba                	add	a5,a5,a4
    80005cca:	40200713          	li	a4,1026
    80005cce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cd2:	00d5151b          	slliw	a0,a0,0xd
    80005cd6:	0c2017b7          	lui	a5,0xc201
    80005cda:	953e                	add	a0,a0,a5
    80005cdc:	00052023          	sw	zero,0(a0)
}
    80005ce0:	60a2                	ld	ra,8(sp)
    80005ce2:	6402                	ld	s0,0(sp)
    80005ce4:	0141                	addi	sp,sp,16
    80005ce6:	8082                	ret

0000000080005ce8 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005ce8:	1141                	addi	sp,sp,-16
    80005cea:	e422                	sd	s0,8(sp)
    80005cec:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005cee:	0c0017b7          	lui	a5,0xc001
    80005cf2:	6388                	ld	a0,0(a5)
    80005cf4:	6422                	ld	s0,8(sp)
    80005cf6:	0141                	addi	sp,sp,16
    80005cf8:	8082                	ret

0000000080005cfa <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cfa:	1141                	addi	sp,sp,-16
    80005cfc:	e406                	sd	ra,8(sp)
    80005cfe:	e022                	sd	s0,0(sp)
    80005d00:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d02:	ffffc097          	auipc	ra,0xffffc
    80005d06:	b1e080e7          	jalr	-1250(ra) # 80001820 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d0a:	00d5179b          	slliw	a5,a0,0xd
    80005d0e:	0c201537          	lui	a0,0xc201
    80005d12:	953e                	add	a0,a0,a5
  return irq;
}
    80005d14:	4148                	lw	a0,4(a0)
    80005d16:	60a2                	ld	ra,8(sp)
    80005d18:	6402                	ld	s0,0(sp)
    80005d1a:	0141                	addi	sp,sp,16
    80005d1c:	8082                	ret

0000000080005d1e <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d1e:	1101                	addi	sp,sp,-32
    80005d20:	ec06                	sd	ra,24(sp)
    80005d22:	e822                	sd	s0,16(sp)
    80005d24:	e426                	sd	s1,8(sp)
    80005d26:	1000                	addi	s0,sp,32
    80005d28:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d2a:	ffffc097          	auipc	ra,0xffffc
    80005d2e:	af6080e7          	jalr	-1290(ra) # 80001820 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d32:	00d5151b          	slliw	a0,a0,0xd
    80005d36:	0c2017b7          	lui	a5,0xc201
    80005d3a:	97aa                	add	a5,a5,a0
    80005d3c:	c3c4                	sw	s1,4(a5)
}
    80005d3e:	60e2                	ld	ra,24(sp)
    80005d40:	6442                	ld	s0,16(sp)
    80005d42:	64a2                	ld	s1,8(sp)
    80005d44:	6105                	addi	sp,sp,32
    80005d46:	8082                	ret

0000000080005d48 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005d48:	1141                	addi	sp,sp,-16
    80005d4a:	e406                	sd	ra,8(sp)
    80005d4c:	e022                	sd	s0,0(sp)
    80005d4e:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d50:	479d                	li	a5,7
    80005d52:	06b7c963          	blt	a5,a1,80005dc4 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005d56:	00151793          	slli	a5,a0,0x1
    80005d5a:	97aa                	add	a5,a5,a0
    80005d5c:	00c79713          	slli	a4,a5,0xc
    80005d60:	0001d797          	auipc	a5,0x1d
    80005d64:	2a078793          	addi	a5,a5,672 # 80023000 <disk>
    80005d68:	97ba                	add	a5,a5,a4
    80005d6a:	97ae                	add	a5,a5,a1
    80005d6c:	6709                	lui	a4,0x2
    80005d6e:	97ba                	add	a5,a5,a4
    80005d70:	0187c783          	lbu	a5,24(a5)
    80005d74:	e3a5                	bnez	a5,80005dd4 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005d76:	0001d817          	auipc	a6,0x1d
    80005d7a:	28a80813          	addi	a6,a6,650 # 80023000 <disk>
    80005d7e:	00151693          	slli	a3,a0,0x1
    80005d82:	00a68733          	add	a4,a3,a0
    80005d86:	0732                	slli	a4,a4,0xc
    80005d88:	00e807b3          	add	a5,a6,a4
    80005d8c:	6709                	lui	a4,0x2
    80005d8e:	00f70633          	add	a2,a4,a5
    80005d92:	6210                	ld	a2,0(a2)
    80005d94:	00459893          	slli	a7,a1,0x4
    80005d98:	9646                	add	a2,a2,a7
    80005d9a:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005d9e:	97ae                	add	a5,a5,a1
    80005da0:	97ba                	add	a5,a5,a4
    80005da2:	4605                	li	a2,1
    80005da4:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005da8:	96aa                	add	a3,a3,a0
    80005daa:	06b2                	slli	a3,a3,0xc
    80005dac:	0761                	addi	a4,a4,24
    80005dae:	96ba                	add	a3,a3,a4
    80005db0:	00d80533          	add	a0,a6,a3
    80005db4:	ffffc097          	auipc	ra,0xffffc
    80005db8:	430080e7          	jalr	1072(ra) # 800021e4 <wakeup>
}
    80005dbc:	60a2                	ld	ra,8(sp)
    80005dbe:	6402                	ld	s0,0(sp)
    80005dc0:	0141                	addi	sp,sp,16
    80005dc2:	8082                	ret
    panic("virtio_disk_intr 1");
    80005dc4:	00003517          	auipc	a0,0x3
    80005dc8:	a1c50513          	addi	a0,a0,-1508 # 800087e0 <userret+0x750>
    80005dcc:	ffffa097          	auipc	ra,0xffffa
    80005dd0:	782080e7          	jalr	1922(ra) # 8000054e <panic>
    panic("virtio_disk_intr 2");
    80005dd4:	00003517          	auipc	a0,0x3
    80005dd8:	a2450513          	addi	a0,a0,-1500 # 800087f8 <userret+0x768>
    80005ddc:	ffffa097          	auipc	ra,0xffffa
    80005de0:	772080e7          	jalr	1906(ra) # 8000054e <panic>

0000000080005de4 <virtio_disk_init>:
  __sync_synchronize();
    80005de4:	0ff0000f          	fence
  if(disk[n].init)
    80005de8:	00151793          	slli	a5,a0,0x1
    80005dec:	97aa                	add	a5,a5,a0
    80005dee:	07b2                	slli	a5,a5,0xc
    80005df0:	0001d717          	auipc	a4,0x1d
    80005df4:	21070713          	addi	a4,a4,528 # 80023000 <disk>
    80005df8:	973e                	add	a4,a4,a5
    80005dfa:	6789                	lui	a5,0x2
    80005dfc:	97ba                	add	a5,a5,a4
    80005dfe:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80005e02:	c391                	beqz	a5,80005e06 <virtio_disk_init+0x22>
    80005e04:	8082                	ret
{
    80005e06:	7139                	addi	sp,sp,-64
    80005e08:	fc06                	sd	ra,56(sp)
    80005e0a:	f822                	sd	s0,48(sp)
    80005e0c:	f426                	sd	s1,40(sp)
    80005e0e:	f04a                	sd	s2,32(sp)
    80005e10:	ec4e                	sd	s3,24(sp)
    80005e12:	e852                	sd	s4,16(sp)
    80005e14:	e456                	sd	s5,8(sp)
    80005e16:	0080                	addi	s0,sp,64
    80005e18:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80005e1a:	85aa                	mv	a1,a0
    80005e1c:	00003517          	auipc	a0,0x3
    80005e20:	9f450513          	addi	a0,a0,-1548 # 80008810 <userret+0x780>
    80005e24:	ffffa097          	auipc	ra,0xffffa
    80005e28:	774080e7          	jalr	1908(ra) # 80000598 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80005e2c:	00149993          	slli	s3,s1,0x1
    80005e30:	99a6                	add	s3,s3,s1
    80005e32:	09b2                	slli	s3,s3,0xc
    80005e34:	6789                	lui	a5,0x2
    80005e36:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80005e3a:	97ce                	add	a5,a5,s3
    80005e3c:	00003597          	auipc	a1,0x3
    80005e40:	9ec58593          	addi	a1,a1,-1556 # 80008828 <userret+0x798>
    80005e44:	0001d517          	auipc	a0,0x1d
    80005e48:	1bc50513          	addi	a0,a0,444 # 80023000 <disk>
    80005e4c:	953e                	add	a0,a0,a5
    80005e4e:	ffffb097          	auipc	ra,0xffffb
    80005e52:	b8a080e7          	jalr	-1142(ra) # 800009d8 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e56:	0014891b          	addiw	s2,s1,1
    80005e5a:	00c9191b          	slliw	s2,s2,0xc
    80005e5e:	100007b7          	lui	a5,0x10000
    80005e62:	97ca                	add	a5,a5,s2
    80005e64:	4398                	lw	a4,0(a5)
    80005e66:	2701                	sext.w	a4,a4
    80005e68:	747277b7          	lui	a5,0x74727
    80005e6c:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e70:	12f71663          	bne	a4,a5,80005f9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005e74:	100007b7          	lui	a5,0x10000
    80005e78:	0791                	addi	a5,a5,4
    80005e7a:	97ca                	add	a5,a5,s2
    80005e7c:	439c                	lw	a5,0(a5)
    80005e7e:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e80:	4705                	li	a4,1
    80005e82:	10e79d63          	bne	a5,a4,80005f9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e86:	100007b7          	lui	a5,0x10000
    80005e8a:	07a1                	addi	a5,a5,8
    80005e8c:	97ca                	add	a5,a5,s2
    80005e8e:	439c                	lw	a5,0(a5)
    80005e90:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005e92:	4709                	li	a4,2
    80005e94:	10e79463          	bne	a5,a4,80005f9c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e98:	100007b7          	lui	a5,0x10000
    80005e9c:	07b1                	addi	a5,a5,12
    80005e9e:	97ca                	add	a5,a5,s2
    80005ea0:	4398                	lw	a4,0(a5)
    80005ea2:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ea4:	554d47b7          	lui	a5,0x554d4
    80005ea8:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eac:	0ef71863          	bne	a4,a5,80005f9c <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005eb0:	100007b7          	lui	a5,0x10000
    80005eb4:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80005eb8:	96ca                	add	a3,a3,s2
    80005eba:	4705                	li	a4,1
    80005ebc:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005ebe:	470d                	li	a4,3
    80005ec0:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80005ec2:	01078713          	addi	a4,a5,16
    80005ec6:	974a                	add	a4,a4,s2
    80005ec8:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005eca:	02078613          	addi	a2,a5,32
    80005ece:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ed0:	c7ffe737          	lui	a4,0xc7ffe
    80005ed4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd5703>
    80005ed8:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005eda:	2701                	sext.w	a4,a4
    80005edc:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005ede:	472d                	li	a4,11
    80005ee0:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005ee2:	473d                	li	a4,15
    80005ee4:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ee6:	02878713          	addi	a4,a5,40
    80005eea:	974a                	add	a4,a4,s2
    80005eec:	6685                	lui	a3,0x1
    80005eee:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ef0:	03078713          	addi	a4,a5,48
    80005ef4:	974a                	add	a4,a4,s2
    80005ef6:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005efa:	03478793          	addi	a5,a5,52
    80005efe:	97ca                	add	a5,a5,s2
    80005f00:	439c                	lw	a5,0(a5)
    80005f02:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f04:	c7c5                	beqz	a5,80005fac <virtio_disk_init+0x1c8>
  if(max < NUM)
    80005f06:	471d                	li	a4,7
    80005f08:	0af77a63          	bgeu	a4,a5,80005fbc <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f0c:	10000ab7          	lui	s5,0x10000
    80005f10:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80005f14:	97ca                	add	a5,a5,s2
    80005f16:	4721                	li	a4,8
    80005f18:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80005f1a:	0001da17          	auipc	s4,0x1d
    80005f1e:	0e6a0a13          	addi	s4,s4,230 # 80023000 <disk>
    80005f22:	99d2                	add	s3,s3,s4
    80005f24:	6609                	lui	a2,0x2
    80005f26:	4581                	li	a1,0
    80005f28:	854e                	mv	a0,s3
    80005f2a:	ffffb097          	auipc	ra,0xffffb
    80005f2e:	c84080e7          	jalr	-892(ra) # 80000bae <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80005f32:	040a8a93          	addi	s5,s5,64
    80005f36:	9956                	add	s2,s2,s5
    80005f38:	00c9d793          	srli	a5,s3,0xc
    80005f3c:	2781                	sext.w	a5,a5
    80005f3e:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80005f42:	00149513          	slli	a0,s1,0x1
    80005f46:	009507b3          	add	a5,a0,s1
    80005f4a:	07b2                	slli	a5,a5,0xc
    80005f4c:	97d2                	add	a5,a5,s4
    80005f4e:	6689                	lui	a3,0x2
    80005f50:	97b6                	add	a5,a5,a3
    80005f52:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80005f56:	08098713          	addi	a4,s3,128
    80005f5a:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80005f5c:	6705                	lui	a4,0x1
    80005f5e:	99ba                	add	s3,s3,a4
    80005f60:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80005f64:	4705                	li	a4,1
    80005f66:	00e78c23          	sb	a4,24(a5)
    80005f6a:	00e78ca3          	sb	a4,25(a5)
    80005f6e:	00e78d23          	sb	a4,26(a5)
    80005f72:	00e78da3          	sb	a4,27(a5)
    80005f76:	00e78e23          	sb	a4,28(a5)
    80005f7a:	00e78ea3          	sb	a4,29(a5)
    80005f7e:	00e78f23          	sb	a4,30(a5)
    80005f82:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80005f86:	0ae7a423          	sw	a4,168(a5)
}
    80005f8a:	70e2                	ld	ra,56(sp)
    80005f8c:	7442                	ld	s0,48(sp)
    80005f8e:	74a2                	ld	s1,40(sp)
    80005f90:	7902                	ld	s2,32(sp)
    80005f92:	69e2                	ld	s3,24(sp)
    80005f94:	6a42                	ld	s4,16(sp)
    80005f96:	6aa2                	ld	s5,8(sp)
    80005f98:	6121                	addi	sp,sp,64
    80005f9a:	8082                	ret
    panic("could not find virtio disk");
    80005f9c:	00003517          	auipc	a0,0x3
    80005fa0:	89c50513          	addi	a0,a0,-1892 # 80008838 <userret+0x7a8>
    80005fa4:	ffffa097          	auipc	ra,0xffffa
    80005fa8:	5aa080e7          	jalr	1450(ra) # 8000054e <panic>
    panic("virtio disk has no queue 0");
    80005fac:	00003517          	auipc	a0,0x3
    80005fb0:	8ac50513          	addi	a0,a0,-1876 # 80008858 <userret+0x7c8>
    80005fb4:	ffffa097          	auipc	ra,0xffffa
    80005fb8:	59a080e7          	jalr	1434(ra) # 8000054e <panic>
    panic("virtio disk max queue too short");
    80005fbc:	00003517          	auipc	a0,0x3
    80005fc0:	8bc50513          	addi	a0,a0,-1860 # 80008878 <userret+0x7e8>
    80005fc4:	ffffa097          	auipc	ra,0xffffa
    80005fc8:	58a080e7          	jalr	1418(ra) # 8000054e <panic>

0000000080005fcc <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80005fcc:	7135                	addi	sp,sp,-160
    80005fce:	ed06                	sd	ra,152(sp)
    80005fd0:	e922                	sd	s0,144(sp)
    80005fd2:	e526                	sd	s1,136(sp)
    80005fd4:	e14a                	sd	s2,128(sp)
    80005fd6:	fcce                	sd	s3,120(sp)
    80005fd8:	f8d2                	sd	s4,112(sp)
    80005fda:	f4d6                	sd	s5,104(sp)
    80005fdc:	f0da                	sd	s6,96(sp)
    80005fde:	ecde                	sd	s7,88(sp)
    80005fe0:	e8e2                	sd	s8,80(sp)
    80005fe2:	e4e6                	sd	s9,72(sp)
    80005fe4:	e0ea                	sd	s10,64(sp)
    80005fe6:	fc6e                	sd	s11,56(sp)
    80005fe8:	1100                	addi	s0,sp,160
    80005fea:	892a                	mv	s2,a0
    80005fec:	89ae                	mv	s3,a1
    80005fee:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ff0:	45dc                	lw	a5,12(a1)
    80005ff2:	0017979b          	slliw	a5,a5,0x1
    80005ff6:	1782                	slli	a5,a5,0x20
    80005ff8:	9381                	srli	a5,a5,0x20
    80005ffa:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80005ffe:	00151493          	slli	s1,a0,0x1
    80006002:	94aa                	add	s1,s1,a0
    80006004:	04b2                	slli	s1,s1,0xc
    80006006:	6a89                	lui	s5,0x2
    80006008:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    8000600c:	9a26                	add	s4,s4,s1
    8000600e:	0001db97          	auipc	s7,0x1d
    80006012:	ff2b8b93          	addi	s7,s7,-14 # 80023000 <disk>
    80006016:	9a5e                	add	s4,s4,s7
    80006018:	8552                	mv	a0,s4
    8000601a:	ffffb097          	auipc	ra,0xffffb
    8000601e:	ad0080e7          	jalr	-1328(ra) # 80000aea <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006022:	0ae1                	addi	s5,s5,24
    80006024:	94d6                	add	s1,s1,s5
    80006026:	01748ab3          	add	s5,s1,s7
    8000602a:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    8000602c:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    8000602e:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    80006030:	00191b13          	slli	s6,s2,0x1
    80006034:	9b4a                	add	s6,s6,s2
    80006036:	00cb1793          	slli	a5,s6,0xc
    8000603a:	0001db17          	auipc	s6,0x1d
    8000603e:	fc6b0b13          	addi	s6,s6,-58 # 80023000 <disk>
    80006042:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    80006044:	8c5e                	mv	s8,s7
    80006046:	a8ad                	j	800060c0 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    80006048:	00fb06b3          	add	a3,s6,a5
    8000604c:	96aa                	add	a3,a3,a0
    8000604e:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80006052:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006054:	0207c363          	bltz	a5,8000607a <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    80006058:	2485                	addiw	s1,s1,1
    8000605a:	0711                	addi	a4,a4,4
    8000605c:	1eb48363          	beq	s1,a1,80006242 <virtio_disk_rw+0x276>
    idx[i] = alloc_desc(n);
    80006060:	863a                	mv	a2,a4
    80006062:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    80006064:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    80006066:	0006c803          	lbu	a6,0(a3)
    8000606a:	fc081fe3          	bnez	a6,80006048 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    8000606e:	2785                	addiw	a5,a5,1
    80006070:	0685                	addi	a3,a3,1
    80006072:	ff979ae3          	bne	a5,s9,80006066 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    80006076:	57fd                	li	a5,-1
    80006078:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000607a:	02905d63          	blez	s1,800060b4 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    8000607e:	f8042583          	lw	a1,-128(s0)
    80006082:	854a                	mv	a0,s2
    80006084:	00000097          	auipc	ra,0x0
    80006088:	cc4080e7          	jalr	-828(ra) # 80005d48 <free_desc>
      for(int j = 0; j < i; j++)
    8000608c:	4785                	li	a5,1
    8000608e:	0297d363          	bge	a5,s1,800060b4 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006092:	f8442583          	lw	a1,-124(s0)
    80006096:	854a                	mv	a0,s2
    80006098:	00000097          	auipc	ra,0x0
    8000609c:	cb0080e7          	jalr	-848(ra) # 80005d48 <free_desc>
      for(int j = 0; j < i; j++)
    800060a0:	4789                	li	a5,2
    800060a2:	0097d963          	bge	a5,s1,800060b4 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    800060a6:	f8842583          	lw	a1,-120(s0)
    800060aa:	854a                	mv	a0,s2
    800060ac:	00000097          	auipc	ra,0x0
    800060b0:	c9c080e7          	jalr	-868(ra) # 80005d48 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800060b4:	85d2                	mv	a1,s4
    800060b6:	8556                	mv	a0,s5
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	fa6080e7          	jalr	-90(ra) # 8000205e <sleep>
  for(int i = 0; i < 3; i++){
    800060c0:	f8040713          	addi	a4,s0,-128
    800060c4:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    800060c6:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    800060c8:	458d                	li	a1,3
    800060ca:	bf59                	j	80006060 <virtio_disk_rw+0x94>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    800060cc:	00191793          	slli	a5,s2,0x1
    800060d0:	97ca                	add	a5,a5,s2
    800060d2:	07b2                	slli	a5,a5,0xc
    800060d4:	0001d717          	auipc	a4,0x1d
    800060d8:	f2c70713          	addi	a4,a4,-212 # 80023000 <disk>
    800060dc:	973e                	add	a4,a4,a5
    800060de:	6789                	lui	a5,0x2
    800060e0:	97ba                	add	a5,a5,a4
    800060e2:	639c                	ld	a5,0(a5)
    800060e4:	97b6                	add	a5,a5,a3
    800060e6:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060ea:	0001d517          	auipc	a0,0x1d
    800060ee:	f1650513          	addi	a0,a0,-234 # 80023000 <disk>
    800060f2:	00191793          	slli	a5,s2,0x1
    800060f6:	01278733          	add	a4,a5,s2
    800060fa:	0732                	slli	a4,a4,0xc
    800060fc:	972a                	add	a4,a4,a0
    800060fe:	6609                	lui	a2,0x2
    80006100:	9732                	add	a4,a4,a2
    80006102:	630c                	ld	a1,0(a4)
    80006104:	95b6                	add	a1,a1,a3
    80006106:	00c5d603          	lhu	a2,12(a1)
    8000610a:	00166613          	ori	a2,a2,1
    8000610e:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006112:	f8842603          	lw	a2,-120(s0)
    80006116:	630c                	ld	a1,0(a4)
    80006118:	96ae                	add	a3,a3,a1
    8000611a:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    8000611e:	97ca                	add	a5,a5,s2
    80006120:	07a2                	slli	a5,a5,0x8
    80006122:	97a6                	add	a5,a5,s1
    80006124:	20078793          	addi	a5,a5,512
    80006128:	0792                	slli	a5,a5,0x4
    8000612a:	97aa                	add	a5,a5,a0
    8000612c:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    80006130:	00461693          	slli	a3,a2,0x4
    80006134:	00073803          	ld	a6,0(a4)
    80006138:	9836                	add	a6,a6,a3
    8000613a:	20348613          	addi	a2,s1,515
    8000613e:	00191593          	slli	a1,s2,0x1
    80006142:	95ca                	add	a1,a1,s2
    80006144:	05a2                	slli	a1,a1,0x8
    80006146:	962e                	add	a2,a2,a1
    80006148:	0612                	slli	a2,a2,0x4
    8000614a:	962a                	add	a2,a2,a0
    8000614c:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    80006150:	630c                	ld	a1,0(a4)
    80006152:	95b6                	add	a1,a1,a3
    80006154:	4605                	li	a2,1
    80006156:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006158:	630c                	ld	a1,0(a4)
    8000615a:	95b6                	add	a1,a1,a3
    8000615c:	4509                	li	a0,2
    8000615e:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    80006162:	630c                	ld	a1,0(a4)
    80006164:	96ae                	add	a3,a3,a1
    80006166:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000616a:	00c9a223          	sw	a2,4(s3)
  disk[n].info[idx[0]].b = b;
    8000616e:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    80006172:	6714                	ld	a3,8(a4)
    80006174:	0026d783          	lhu	a5,2(a3)
    80006178:	8b9d                	andi	a5,a5,7
    8000617a:	2789                	addiw	a5,a5,2
    8000617c:	0786                	slli	a5,a5,0x1
    8000617e:	97b6                	add	a5,a5,a3
    80006180:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006184:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006188:	6718                	ld	a4,8(a4)
    8000618a:	00275783          	lhu	a5,2(a4)
    8000618e:	2785                	addiw	a5,a5,1
    80006190:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006194:	0019079b          	addiw	a5,s2,1
    80006198:	00c7979b          	slliw	a5,a5,0xc
    8000619c:	10000737          	lui	a4,0x10000
    800061a0:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    800061a4:	97ba                	add	a5,a5,a4
    800061a6:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061aa:	0049a783          	lw	a5,4(s3)
    800061ae:	00c79d63          	bne	a5,a2,800061c8 <virtio_disk_rw+0x1fc>
    800061b2:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    800061b4:	85d2                	mv	a1,s4
    800061b6:	854e                	mv	a0,s3
    800061b8:	ffffc097          	auipc	ra,0xffffc
    800061bc:	ea6080e7          	jalr	-346(ra) # 8000205e <sleep>
  while(b->disk == 1) {
    800061c0:	0049a783          	lw	a5,4(s3)
    800061c4:	fe9788e3          	beq	a5,s1,800061b4 <virtio_disk_rw+0x1e8>
  }

  disk[n].info[idx[0]].b = 0;
    800061c8:	f8042483          	lw	s1,-128(s0)
    800061cc:	00191793          	slli	a5,s2,0x1
    800061d0:	97ca                	add	a5,a5,s2
    800061d2:	07a2                	slli	a5,a5,0x8
    800061d4:	97a6                	add	a5,a5,s1
    800061d6:	20078793          	addi	a5,a5,512
    800061da:	0792                	slli	a5,a5,0x4
    800061dc:	0001d717          	auipc	a4,0x1d
    800061e0:	e2470713          	addi	a4,a4,-476 # 80023000 <disk>
    800061e4:	97ba                	add	a5,a5,a4
    800061e6:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800061ea:	00191793          	slli	a5,s2,0x1
    800061ee:	97ca                	add	a5,a5,s2
    800061f0:	07b2                	slli	a5,a5,0xc
    800061f2:	97ba                	add	a5,a5,a4
    800061f4:	6989                	lui	s3,0x2
    800061f6:	99be                	add	s3,s3,a5
    free_desc(n, i);
    800061f8:	85a6                	mv	a1,s1
    800061fa:	854a                	mv	a0,s2
    800061fc:	00000097          	auipc	ra,0x0
    80006200:	b4c080e7          	jalr	-1204(ra) # 80005d48 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006204:	0492                	slli	s1,s1,0x4
    80006206:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    8000620a:	94be                	add	s1,s1,a5
    8000620c:	00c4d783          	lhu	a5,12(s1)
    80006210:	8b85                	andi	a5,a5,1
    80006212:	c781                	beqz	a5,8000621a <virtio_disk_rw+0x24e>
      i = disk[n].desc[i].next;
    80006214:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006218:	b7c5                	j	800061f8 <virtio_disk_rw+0x22c>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    8000621a:	8552                	mv	a0,s4
    8000621c:	ffffb097          	auipc	ra,0xffffb
    80006220:	936080e7          	jalr	-1738(ra) # 80000b52 <release>
}
    80006224:	60ea                	ld	ra,152(sp)
    80006226:	644a                	ld	s0,144(sp)
    80006228:	64aa                	ld	s1,136(sp)
    8000622a:	690a                	ld	s2,128(sp)
    8000622c:	79e6                	ld	s3,120(sp)
    8000622e:	7a46                	ld	s4,112(sp)
    80006230:	7aa6                	ld	s5,104(sp)
    80006232:	7b06                	ld	s6,96(sp)
    80006234:	6be6                	ld	s7,88(sp)
    80006236:	6c46                	ld	s8,80(sp)
    80006238:	6ca6                	ld	s9,72(sp)
    8000623a:	6d06                	ld	s10,64(sp)
    8000623c:	7de2                	ld	s11,56(sp)
    8000623e:	610d                	addi	sp,sp,160
    80006240:	8082                	ret
  if(write)
    80006242:	01b037b3          	snez	a5,s11
    80006246:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    8000624a:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    8000624e:	f6843783          	ld	a5,-152(s0)
    80006252:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006256:	f8042483          	lw	s1,-128(s0)
    8000625a:	00449b13          	slli	s6,s1,0x4
    8000625e:	00191793          	slli	a5,s2,0x1
    80006262:	97ca                	add	a5,a5,s2
    80006264:	07b2                	slli	a5,a5,0xc
    80006266:	0001da97          	auipc	s5,0x1d
    8000626a:	d9aa8a93          	addi	s5,s5,-614 # 80023000 <disk>
    8000626e:	97d6                	add	a5,a5,s5
    80006270:	6a89                	lui	s5,0x2
    80006272:	9abe                	add	s5,s5,a5
    80006274:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    80006278:	9bda                	add	s7,s7,s6
    8000627a:	f7040513          	addi	a0,s0,-144
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	d64080e7          	jalr	-668(ra) # 80000fe2 <kvmpa>
    80006286:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    8000628a:	000ab783          	ld	a5,0(s5)
    8000628e:	97da                	add	a5,a5,s6
    80006290:	4741                	li	a4,16
    80006292:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006294:	000ab783          	ld	a5,0(s5)
    80006298:	97da                	add	a5,a5,s6
    8000629a:	4705                	li	a4,1
    8000629c:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    800062a0:	f8442683          	lw	a3,-124(s0)
    800062a4:	000ab783          	ld	a5,0(s5)
    800062a8:	9b3e                	add	s6,s6,a5
    800062aa:	00db1723          	sh	a3,14(s6)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    800062ae:	0692                	slli	a3,a3,0x4
    800062b0:	000ab783          	ld	a5,0(s5)
    800062b4:	97b6                	add	a5,a5,a3
    800062b6:	06098713          	addi	a4,s3,96
    800062ba:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    800062bc:	000ab783          	ld	a5,0(s5)
    800062c0:	97b6                	add	a5,a5,a3
    800062c2:	40000713          	li	a4,1024
    800062c6:	c798                	sw	a4,8(a5)
  if(write)
    800062c8:	e00d92e3          	bnez	s11,800060cc <virtio_disk_rw+0x100>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800062cc:	00191793          	slli	a5,s2,0x1
    800062d0:	97ca                	add	a5,a5,s2
    800062d2:	07b2                	slli	a5,a5,0xc
    800062d4:	0001d717          	auipc	a4,0x1d
    800062d8:	d2c70713          	addi	a4,a4,-724 # 80023000 <disk>
    800062dc:	973e                	add	a4,a4,a5
    800062de:	6789                	lui	a5,0x2
    800062e0:	97ba                	add	a5,a5,a4
    800062e2:	639c                	ld	a5,0(a5)
    800062e4:	97b6                	add	a5,a5,a3
    800062e6:	4709                	li	a4,2
    800062e8:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    800062ec:	bbfd                	j	800060ea <virtio_disk_rw+0x11e>

00000000800062ee <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    800062ee:	7139                	addi	sp,sp,-64
    800062f0:	fc06                	sd	ra,56(sp)
    800062f2:	f822                	sd	s0,48(sp)
    800062f4:	f426                	sd	s1,40(sp)
    800062f6:	f04a                	sd	s2,32(sp)
    800062f8:	ec4e                	sd	s3,24(sp)
    800062fa:	e852                	sd	s4,16(sp)
    800062fc:	e456                	sd	s5,8(sp)
    800062fe:	0080                	addi	s0,sp,64
    80006300:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006302:	00151913          	slli	s2,a0,0x1
    80006306:	00a90a33          	add	s4,s2,a0
    8000630a:	0a32                	slli	s4,s4,0xc
    8000630c:	6989                	lui	s3,0x2
    8000630e:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006312:	9a3e                	add	s4,s4,a5
    80006314:	0001da97          	auipc	s5,0x1d
    80006318:	ceca8a93          	addi	s5,s5,-788 # 80023000 <disk>
    8000631c:	9a56                	add	s4,s4,s5
    8000631e:	8552                	mv	a0,s4
    80006320:	ffffa097          	auipc	ra,0xffffa
    80006324:	7ca080e7          	jalr	1994(ra) # 80000aea <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006328:	9926                	add	s2,s2,s1
    8000632a:	0932                	slli	s2,s2,0xc
    8000632c:	9956                	add	s2,s2,s5
    8000632e:	99ca                	add	s3,s3,s2
    80006330:	0209d783          	lhu	a5,32(s3)
    80006334:	0109b703          	ld	a4,16(s3)
    80006338:	00275683          	lhu	a3,2(a4)
    8000633c:	8ebd                	xor	a3,a3,a5
    8000633e:	8a9d                	andi	a3,a3,7
    80006340:	c2a5                	beqz	a3,800063a0 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    80006342:	8956                	mv	s2,s5
    80006344:	00149693          	slli	a3,s1,0x1
    80006348:	96a6                	add	a3,a3,s1
    8000634a:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    8000634e:	06b2                	slli	a3,a3,0xc
    80006350:	96d6                	add	a3,a3,s5
    80006352:	6489                	lui	s1,0x2
    80006354:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    80006356:	078e                	slli	a5,a5,0x3
    80006358:	97ba                	add	a5,a5,a4
    8000635a:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    8000635c:	00f98733          	add	a4,s3,a5
    80006360:	20070713          	addi	a4,a4,512
    80006364:	0712                	slli	a4,a4,0x4
    80006366:	974a                	add	a4,a4,s2
    80006368:	03074703          	lbu	a4,48(a4)
    8000636c:	eb21                	bnez	a4,800063bc <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    8000636e:	97ce                	add	a5,a5,s3
    80006370:	20078793          	addi	a5,a5,512
    80006374:	0792                	slli	a5,a5,0x4
    80006376:	97ca                	add	a5,a5,s2
    80006378:	7798                	ld	a4,40(a5)
    8000637a:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    8000637e:	7788                	ld	a0,40(a5)
    80006380:	ffffc097          	auipc	ra,0xffffc
    80006384:	e64080e7          	jalr	-412(ra) # 800021e4 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006388:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    8000638c:	2785                	addiw	a5,a5,1
    8000638e:	8b9d                	andi	a5,a5,7
    80006390:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006394:	6898                	ld	a4,16(s1)
    80006396:	00275683          	lhu	a3,2(a4)
    8000639a:	8a9d                	andi	a3,a3,7
    8000639c:	faf69de3          	bne	a3,a5,80006356 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    800063a0:	8552                	mv	a0,s4
    800063a2:	ffffa097          	auipc	ra,0xffffa
    800063a6:	7b0080e7          	jalr	1968(ra) # 80000b52 <release>
}
    800063aa:	70e2                	ld	ra,56(sp)
    800063ac:	7442                	ld	s0,48(sp)
    800063ae:	74a2                	ld	s1,40(sp)
    800063b0:	7902                	ld	s2,32(sp)
    800063b2:	69e2                	ld	s3,24(sp)
    800063b4:	6a42                	ld	s4,16(sp)
    800063b6:	6aa2                	ld	s5,8(sp)
    800063b8:	6121                	addi	sp,sp,64
    800063ba:	8082                	ret
      panic("virtio_disk_intr status");
    800063bc:	00002517          	auipc	a0,0x2
    800063c0:	4dc50513          	addi	a0,a0,1244 # 80008898 <userret+0x808>
    800063c4:	ffffa097          	auipc	ra,0xffffa
    800063c8:	18a080e7          	jalr	394(ra) # 8000054e <panic>

00000000800063cc <bit_isset>:
static Sz_info *bd_sizes;
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    800063cc:	1141                	addi	sp,sp,-16
    800063ce:	e422                	sd	s0,8(sp)
    800063d0:	0800                	addi	s0,sp,16
  char b = array[index/8];//1 bit to indicate a value
  char m = (1 << (index % 8));
    800063d2:	41f5d79b          	sraiw	a5,a1,0x1f
    800063d6:	01d7d79b          	srliw	a5,a5,0x1d
    800063da:	9dbd                	addw	a1,a1,a5
    800063dc:	0075f713          	andi	a4,a1,7
    800063e0:	9f1d                	subw	a4,a4,a5
    800063e2:	4785                	li	a5,1
    800063e4:	00e797bb          	sllw	a5,a5,a4
    800063e8:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];//1 bit to indicate a value
    800063ec:	4035d59b          	sraiw	a1,a1,0x3
    800063f0:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    800063f2:	0005c503          	lbu	a0,0(a1)
    800063f6:	8d7d                	and	a0,a0,a5
    800063f8:	8d1d                	sub	a0,a0,a5
}
    800063fa:	00153513          	seqz	a0,a0
    800063fe:	6422                	ld	s0,8(sp)
    80006400:	0141                	addi	sp,sp,16
    80006402:	8082                	ret

0000000080006404 <bit_set>:

// Set bit at position index in array to 1
//eg. index==2. b=array[0] and m=100
// b|m=set the second position to 1
void bit_set(char *array, int index) {
    80006404:	1141                	addi	sp,sp,-16
    80006406:	e422                	sd	s0,8(sp)
    80006408:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000640a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000640e:	01d7d79b          	srliw	a5,a5,0x1d
    80006412:	9dbd                	addw	a1,a1,a5
    80006414:	4035d71b          	sraiw	a4,a1,0x3
    80006418:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000641a:	899d                	andi	a1,a1,7
    8000641c:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b | m);
    8000641e:	4785                	li	a5,1
    80006420:	00b795bb          	sllw	a1,a5,a1
    80006424:	00054783          	lbu	a5,0(a0)
    80006428:	8ddd                	or	a1,a1,a5
    8000642a:	00b50023          	sb	a1,0(a0)
}
    8000642e:	6422                	ld	s0,8(sp)
    80006430:	0141                	addi	sp,sp,16
    80006432:	8082                	ret

0000000080006434 <bit_clear>:

// Clear bit at position index in array
//index==2. set the second position to 0
void bit_clear(char *array, int index) {
    80006434:	1141                	addi	sp,sp,-16
    80006436:	e422                	sd	s0,8(sp)
    80006438:	0800                	addi	s0,sp,16
  char b = array[index/8];
    8000643a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000643e:	01d7d79b          	srliw	a5,a5,0x1d
    80006442:	9dbd                	addw	a1,a1,a5
    80006444:	4035d71b          	sraiw	a4,a1,0x3
    80006448:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    8000644a:	899d                	andi	a1,a1,7
    8000644c:	9d9d                	subw	a1,a1,a5
  array[index/8] = (b & ~m);
    8000644e:	4785                	li	a5,1
    80006450:	00b795bb          	sllw	a1,a5,a1
    80006454:	fff5c593          	not	a1,a1
    80006458:	00054783          	lbu	a5,0(a0)
    8000645c:	8dfd                	and	a1,a1,a5
    8000645e:	00b50023          	sb	a1,0(a0)
}
    80006462:	6422                	ld	s0,8(sp)
    80006464:	0141                	addi	sp,sp,16
    80006466:	8082                	ret

0000000080006468 <bd_toggle>:

//if index==8 -> 4
//m=10000
//the fourth position will be set to opposite
//eg. 10101 --> 00101
void bd_toggle(char *array,int index){
    80006468:	1141                	addi	sp,sp,-16
    8000646a:	e422                	sd	s0,8(sp)
    8000646c:	0800                	addi	s0,sp,16
  index>>=1;
    8000646e:	4015d79b          	sraiw	a5,a1,0x1
  char m=(1<<(index%8));
  array[index/8]^=m;
    80006472:	95fd                	srai	a1,a1,0x3f
    80006474:	01d5d59b          	srliw	a1,a1,0x1d
    80006478:	9fad                	addw	a5,a5,a1
    8000647a:	4037d71b          	sraiw	a4,a5,0x3
    8000647e:	953a                	add	a0,a0,a4
  char m=(1<<(index%8));
    80006480:	8b9d                	andi	a5,a5,7
    80006482:	40b785bb          	subw	a1,a5,a1
  array[index/8]^=m;
    80006486:	4785                	li	a5,1
    80006488:	00b795bb          	sllw	a1,a5,a1
    8000648c:	00054783          	lbu	a5,0(a0)
    80006490:	8dbd                	xor	a1,a1,a5
    80006492:	00b50023          	sb	a1,0(a0)
}
    80006496:	6422                	ld	s0,8(sp)
    80006498:	0141                	addi	sp,sp,16
    8000649a:	8082                	ret

000000008000649c <bd_print>:

void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    8000649c:	00023797          	auipc	a5,0x23
    800064a0:	bbc7a783          	lw	a5,-1092(a5) # 80029058 <nsizes>
    800064a4:	16f05a63          	blez	a5,80006618 <bd_print+0x17c>
bd_print() {
    800064a8:	7159                	addi	sp,sp,-112
    800064aa:	f486                	sd	ra,104(sp)
    800064ac:	f0a2                	sd	s0,96(sp)
    800064ae:	eca6                	sd	s1,88(sp)
    800064b0:	e8ca                	sd	s2,80(sp)
    800064b2:	e4ce                	sd	s3,72(sp)
    800064b4:	e0d2                	sd	s4,64(sp)
    800064b6:	fc56                	sd	s5,56(sp)
    800064b8:	f85a                	sd	s6,48(sp)
    800064ba:	f45e                	sd	s7,40(sp)
    800064bc:	f062                	sd	s8,32(sp)
    800064be:	ec66                	sd	s9,24(sp)
    800064c0:	e86a                	sd	s10,16(sp)
    800064c2:	e46e                	sd	s11,8(sp)
    800064c4:	1880                	addi	s0,sp,112
  for (int k = 0; k < nsizes; k++) {
    800064c6:	4c01                	li	s8,0
    printf("size %d (%d):", k, BLK_SIZE(k));
    800064c8:	4dc1                	li	s11,16
    800064ca:	00002d17          	auipc	s10,0x2
    800064ce:	3e6d0d13          	addi	s10,s10,998 # 800088b0 <userret+0x820>
    lst_print(&bd_sizes[k].free);
    800064d2:	00023b17          	auipc	s6,0x23
    800064d6:	b7eb0b13          	addi	s6,s6,-1154 # 80029050 <bd_sizes>
    printf("  alloc:");
    800064da:	00002c97          	auipc	s9,0x2
    800064de:	3e6c8c93          	addi	s9,s9,998 # 800088c0 <userret+0x830>
    for (int b = 0; b < NBLK(k); b++) {
    800064e2:	00023997          	auipc	s3,0x23
    800064e6:	b7698993          	addi	s3,s3,-1162 # 80029058 <nsizes>
    800064ea:	4a85                	li	s5,1
     printf(" %d", bit_isset(bd_sizes[k].alloc, b));
    800064ec:	00002b97          	auipc	s7,0x2
    800064f0:	3e4b8b93          	addi	s7,s7,996 # 800088d0 <userret+0x840>
    800064f4:	a889                	j	80006546 <bd_print+0xaa>
    }
    printf("\n");
    if(k > 0) {
      printf("  split:");
      for (int b = 0; b < NBLK(k); b++) {
        printf(" %d", bit_isset(bd_sizes[k].split, b));
    800064f6:	000b3783          	ld	a5,0(s6)
    800064fa:	97d2                	add	a5,a5,s4
    800064fc:	85a6                	mv	a1,s1
    800064fe:	6f88                	ld	a0,24(a5)
    80006500:	00000097          	auipc	ra,0x0
    80006504:	ecc080e7          	jalr	-308(ra) # 800063cc <bit_isset>
    80006508:	85aa                	mv	a1,a0
    8000650a:	855e                	mv	a0,s7
    8000650c:	ffffa097          	auipc	ra,0xffffa
    80006510:	08c080e7          	jalr	140(ra) # 80000598 <printf>
      for (int b = 0; b < NBLK(k); b++) {
    80006514:	2485                	addiw	s1,s1,1
    80006516:	0009a783          	lw	a5,0(s3)
    8000651a:	37fd                	addiw	a5,a5,-1
    8000651c:	412787bb          	subw	a5,a5,s2
    80006520:	00fa97bb          	sllw	a5,s5,a5
    80006524:	fcf4c9e3          	blt	s1,a5,800064f6 <bd_print+0x5a>
      }
      printf("\n");
    80006528:	00002517          	auipc	a0,0x2
    8000652c:	c8850513          	addi	a0,a0,-888 # 800081b0 <userret+0x120>
    80006530:	ffffa097          	auipc	ra,0xffffa
    80006534:	068080e7          	jalr	104(ra) # 80000598 <printf>
  for (int k = 0; k < nsizes; k++) {
    80006538:	0c05                	addi	s8,s8,1
    8000653a:	0009a703          	lw	a4,0(s3)
    8000653e:	000c079b          	sext.w	a5,s8
    80006542:	0ae7dc63          	bge	a5,a4,800065fa <bd_print+0x15e>
    80006546:	000c091b          	sext.w	s2,s8
    printf("size %d (%d):", k, BLK_SIZE(k));
    8000654a:	018d9633          	sll	a2,s11,s8
    8000654e:	85ca                	mv	a1,s2
    80006550:	856a                	mv	a0,s10
    80006552:	ffffa097          	auipc	ra,0xffffa
    80006556:	046080e7          	jalr	70(ra) # 80000598 <printf>
    lst_print(&bd_sizes[k].free);
    8000655a:	005c1a13          	slli	s4,s8,0x5
    8000655e:	000b3503          	ld	a0,0(s6)
    80006562:	9552                	add	a0,a0,s4
    80006564:	00001097          	auipc	ra,0x1
    80006568:	acc080e7          	jalr	-1332(ra) # 80007030 <lst_print>
    printf("  alloc:");
    8000656c:	8566                	mv	a0,s9
    8000656e:	ffffa097          	auipc	ra,0xffffa
    80006572:	02a080e7          	jalr	42(ra) # 80000598 <printf>
    for (int b = 0; b < NBLK(k); b++) {
    80006576:	0009a783          	lw	a5,0(s3)
    8000657a:	37fd                	addiw	a5,a5,-1
    8000657c:	412787bb          	subw	a5,a5,s2
    80006580:	00fa97bb          	sllw	a5,s5,a5
    80006584:	02f05c63          	blez	a5,800065bc <bd_print+0x120>
    80006588:	4481                	li	s1,0
     printf(" %d", bit_isset(bd_sizes[k].alloc, b));
    8000658a:	000b3783          	ld	a5,0(s6)
    8000658e:	97d2                	add	a5,a5,s4
    80006590:	85a6                	mv	a1,s1
    80006592:	6b88                	ld	a0,16(a5)
    80006594:	00000097          	auipc	ra,0x0
    80006598:	e38080e7          	jalr	-456(ra) # 800063cc <bit_isset>
    8000659c:	85aa                	mv	a1,a0
    8000659e:	855e                	mv	a0,s7
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	ff8080e7          	jalr	-8(ra) # 80000598 <printf>
    for (int b = 0; b < NBLK(k); b++) {
    800065a8:	2485                	addiw	s1,s1,1
    800065aa:	0009a783          	lw	a5,0(s3)
    800065ae:	37fd                	addiw	a5,a5,-1
    800065b0:	412787bb          	subw	a5,a5,s2
    800065b4:	00fa97bb          	sllw	a5,s5,a5
    800065b8:	fcf4c9e3          	blt	s1,a5,8000658a <bd_print+0xee>
    printf("\n");
    800065bc:	00002517          	auipc	a0,0x2
    800065c0:	bf450513          	addi	a0,a0,-1036 # 800081b0 <userret+0x120>
    800065c4:	ffffa097          	auipc	ra,0xffffa
    800065c8:	fd4080e7          	jalr	-44(ra) # 80000598 <printf>
    if(k > 0) {
    800065cc:	000c079b          	sext.w	a5,s8
    800065d0:	f6f054e3          	blez	a5,80006538 <bd_print+0x9c>
      printf("  split:");
    800065d4:	00002517          	auipc	a0,0x2
    800065d8:	30450513          	addi	a0,a0,772 # 800088d8 <userret+0x848>
    800065dc:	ffffa097          	auipc	ra,0xffffa
    800065e0:	fbc080e7          	jalr	-68(ra) # 80000598 <printf>
      for (int b = 0; b < NBLK(k); b++) {
    800065e4:	0009a783          	lw	a5,0(s3)
    800065e8:	37fd                	addiw	a5,a5,-1
    800065ea:	412787bb          	subw	a5,a5,s2
    800065ee:	00fa97bb          	sllw	a5,s5,a5
    800065f2:	f2f05be3          	blez	a5,80006528 <bd_print+0x8c>
    800065f6:	4481                	li	s1,0
    800065f8:	bdfd                	j	800064f6 <bd_print+0x5a>
    }
  }
}
    800065fa:	70a6                	ld	ra,104(sp)
    800065fc:	7406                	ld	s0,96(sp)
    800065fe:	64e6                	ld	s1,88(sp)
    80006600:	6946                	ld	s2,80(sp)
    80006602:	69a6                	ld	s3,72(sp)
    80006604:	6a06                	ld	s4,64(sp)
    80006606:	7ae2                	ld	s5,56(sp)
    80006608:	7b42                	ld	s6,48(sp)
    8000660a:	7ba2                	ld	s7,40(sp)
    8000660c:	7c02                	ld	s8,32(sp)
    8000660e:	6ce2                	ld	s9,24(sp)
    80006610:	6d42                	ld	s10,16(sp)
    80006612:	6da2                	ld	s11,8(sp)
    80006614:	6165                	addi	sp,sp,112
    80006616:	8082                	ret
    80006618:	8082                	ret

000000008000661a <bit_get>:

int bit_get(char *array,int index){
    8000661a:	1141                	addi	sp,sp,-16
    8000661c:	e422                	sd	s0,8(sp)
    8000661e:	0800                	addi	s0,sp,16
  index>>=1;
    80006620:	4015d79b          	sraiw	a5,a1,0x1
  char b=array[index/8];
  char m=(1<<(index%8));
    80006624:	95fd                	srai	a1,a1,0x3f
    80006626:	01d5d59b          	srliw	a1,a1,0x1d
    8000662a:	9fad                	addw	a5,a5,a1
    8000662c:	0077f713          	andi	a4,a5,7
    80006630:	9f0d                	subw	a4,a4,a1
    80006632:	4585                	li	a1,1
    80006634:	00e595bb          	sllw	a1,a1,a4
    80006638:	0ff5f593          	andi	a1,a1,255
  char b=array[index/8];
    8000663c:	4037d79b          	sraiw	a5,a5,0x3
    80006640:	97aa                	add	a5,a5,a0
  return (b&m)==m;
    80006642:	0007c503          	lbu	a0,0(a5)
    80006646:	8d6d                	and	a0,a0,a1
    80006648:	8d0d                	sub	a0,a0,a1
}
    8000664a:	00153513          	seqz	a0,a0
    8000664e:	6422                	ld	s0,8(sp)
    80006650:	0141                	addi	sp,sp,16
    80006652:	8082                	ret

0000000080006654 <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    80006654:	1141                	addi	sp,sp,-16
    80006656:	e422                	sd	s0,8(sp)
    80006658:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    8000665a:	47c1                	li	a5,16
    8000665c:	00a7fb63          	bgeu	a5,a0,80006672 <firstk+0x1e>
    80006660:	872a                	mv	a4,a0
  int k = 0;
    80006662:	4501                	li	a0,0
    k++;
    80006664:	2505                	addiw	a0,a0,1
    size *= 2;
    80006666:	0786                	slli	a5,a5,0x1
  while (size < n) {
    80006668:	fee7eee3          	bltu	a5,a4,80006664 <firstk+0x10>
  }
  return k;
}
    8000666c:	6422                	ld	s0,8(sp)
    8000666e:	0141                	addi	sp,sp,16
    80006670:	8082                	ret
  int k = 0;
    80006672:	4501                	li	a0,0
    80006674:	bfe5                	j	8000666c <firstk+0x18>

0000000080006676 <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    80006676:	1141                	addi	sp,sp,-16
    80006678:	e422                	sd	s0,8(sp)
    8000667a:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    8000667c:	00023797          	auipc	a5,0x23
    80006680:	9cc7b783          	ld	a5,-1588(a5) # 80029048 <bd_base>
    80006684:	9d9d                	subw	a1,a1,a5
    80006686:	47c1                	li	a5,16
    80006688:	00a79533          	sll	a0,a5,a0
    8000668c:	02a5c533          	div	a0,a1,a0
}
    80006690:	2501                	sext.w	a0,a0
    80006692:	6422                	ld	s0,8(sp)
    80006694:	0141                	addi	sp,sp,16
    80006696:	8082                	ret

0000000080006698 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006698:	1141                	addi	sp,sp,-16
    8000669a:	e422                	sd	s0,8(sp)
    8000669c:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    8000669e:	47c1                	li	a5,16
    800066a0:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    800066a4:	02b787bb          	mulw	a5,a5,a1
}
    800066a8:	00023517          	auipc	a0,0x23
    800066ac:	9a053503          	ld	a0,-1632(a0) # 80029048 <bd_base>
    800066b0:	953e                	add	a0,a0,a5
    800066b2:	6422                	ld	s0,8(sp)
    800066b4:	0141                	addi	sp,sp,16
    800066b6:	8082                	ret

00000000800066b8 <bd_malloc>:

void *
bd_malloc(uint64 nbytes)
{
    800066b8:	7159                	addi	sp,sp,-112
    800066ba:	f486                	sd	ra,104(sp)
    800066bc:	f0a2                	sd	s0,96(sp)
    800066be:	eca6                	sd	s1,88(sp)
    800066c0:	e8ca                	sd	s2,80(sp)
    800066c2:	e4ce                	sd	s3,72(sp)
    800066c4:	e0d2                	sd	s4,64(sp)
    800066c6:	fc56                	sd	s5,56(sp)
    800066c8:	f85a                	sd	s6,48(sp)
    800066ca:	f45e                	sd	s7,40(sp)
    800066cc:	f062                	sd	s8,32(sp)
    800066ce:	ec66                	sd	s9,24(sp)
    800066d0:	e86a                	sd	s10,16(sp)
    800066d2:	e46e                	sd	s11,8(sp)
    800066d4:	1880                	addi	s0,sp,112
    800066d6:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    800066d8:	00023517          	auipc	a0,0x23
    800066dc:	92850513          	addi	a0,a0,-1752 # 80029000 <lock>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	40a080e7          	jalr	1034(ra) # 80000aea <acquire>
  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    800066e8:	8526                	mv	a0,s1
    800066ea:	00000097          	auipc	ra,0x0
    800066ee:	f6a080e7          	jalr	-150(ra) # 80006654 <firstk>
  for (k = fk; k < nsizes; k++) {
    800066f2:	00023797          	auipc	a5,0x23
    800066f6:	9667a783          	lw	a5,-1690(a5) # 80029058 <nsizes>
    800066fa:	02f55d63          	bge	a0,a5,80006734 <bd_malloc+0x7c>
    800066fe:	8c2a                	mv	s8,a0
    80006700:	00551913          	slli	s2,a0,0x5
    80006704:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006706:	00023997          	auipc	s3,0x23
    8000670a:	94a98993          	addi	s3,s3,-1718 # 80029050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    8000670e:	00023a17          	auipc	s4,0x23
    80006712:	94aa0a13          	addi	s4,s4,-1718 # 80029058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006716:	0009b503          	ld	a0,0(s3)
    8000671a:	954a                	add	a0,a0,s2
    8000671c:	00001097          	auipc	ra,0x1
    80006720:	89a080e7          	jalr	-1894(ra) # 80006fb6 <lst_empty>
    80006724:	c115                	beqz	a0,80006748 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006726:	2485                	addiw	s1,s1,1
    80006728:	02090913          	addi	s2,s2,32
    8000672c:	000a2783          	lw	a5,0(s4)
    80006730:	fef4c3e3          	blt	s1,a5,80006716 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    80006734:	00023517          	auipc	a0,0x23
    80006738:	8cc50513          	addi	a0,a0,-1844 # 80029000 <lock>
    8000673c:	ffffa097          	auipc	ra,0xffffa
    80006740:	416080e7          	jalr	1046(ra) # 80000b52 <release>
    return 0;
    80006744:	4b01                	li	s6,0
    80006746:	a0e1                	j	8000680e <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    80006748:	00023797          	auipc	a5,0x23
    8000674c:	9107a783          	lw	a5,-1776(a5) # 80029058 <nsizes>
    80006750:	fef4d2e3          	bge	s1,a5,80006734 <bd_malloc+0x7c>
  }

  // Found one; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    80006754:	00549993          	slli	s3,s1,0x5
    80006758:	00023917          	auipc	s2,0x23
    8000675c:	8f890913          	addi	s2,s2,-1800 # 80029050 <bd_sizes>
    80006760:	00093503          	ld	a0,0(s2)
    80006764:	954e                	add	a0,a0,s3
    80006766:	00001097          	auipc	ra,0x1
    8000676a:	87c080e7          	jalr	-1924(ra) # 80006fe2 <lst_pop>
    8000676e:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    80006770:	00023597          	auipc	a1,0x23
    80006774:	8d85b583          	ld	a1,-1832(a1) # 80029048 <bd_base>
    80006778:	40b505bb          	subw	a1,a0,a1
    8000677c:	47c1                	li	a5,16
    8000677e:	009797b3          	sll	a5,a5,s1
    80006782:	02f5c5b3          	div	a1,a1,a5
  //bit_set(bd_sizes[k].alloc, blk_index(k, p));
  bd_toggle(bd_sizes[k].alloc,blk_index(k,p));
    80006786:	00093783          	ld	a5,0(s2)
    8000678a:	97ce                	add	a5,a5,s3
    8000678c:	2581                	sext.w	a1,a1
    8000678e:	6b88                	ld	a0,16(a5)
    80006790:	00000097          	auipc	ra,0x0
    80006794:	cd8080e7          	jalr	-808(ra) # 80006468 <bd_toggle>
  for(; k > fk; k--) {
    80006798:	069c5363          	bge	s8,s1,800067fe <bd_malloc+0x146>
    char *q = p + BLK_SIZE(k-1);
    8000679c:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    8000679e:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    800067a0:	00023d17          	auipc	s10,0x23
    800067a4:	8a8d0d13          	addi	s10,s10,-1880 # 80029048 <bd_base>
    char *q = p + BLK_SIZE(k-1);
    800067a8:	85a6                	mv	a1,s1
    800067aa:	34fd                	addiw	s1,s1,-1
    800067ac:	009b9ab3          	sll	s5,s7,s1
    800067b0:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800067b4:	000dba03          	ld	s4,0(s11)
  int n = p - (char *) bd_base;
    800067b8:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    800067bc:	412b093b          	subw	s2,s6,s2
    800067c0:	00bb95b3          	sll	a1,s7,a1
    800067c4:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    800067c8:	013a07b3          	add	a5,s4,s3
    800067cc:	2581                	sext.w	a1,a1
    800067ce:	6f88                	ld	a0,24(a5)
    800067d0:	00000097          	auipc	ra,0x0
    800067d4:	c34080e7          	jalr	-972(ra) # 80006404 <bit_set>
    //bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    bd_toggle(bd_sizes[k-1].alloc,blk_index(k-1,p));
    800067d8:	1981                	addi	s3,s3,-32
    800067da:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    800067dc:	035945b3          	div	a1,s2,s5
    bd_toggle(bd_sizes[k-1].alloc,blk_index(k-1,p));
    800067e0:	2581                	sext.w	a1,a1
    800067e2:	010a3503          	ld	a0,16(s4)
    800067e6:	00000097          	auipc	ra,0x0
    800067ea:	c82080e7          	jalr	-894(ra) # 80006468 <bd_toggle>
    lst_push(&bd_sizes[k-1].free, q);
    800067ee:	85e6                	mv	a1,s9
    800067f0:	8552                	mv	a0,s4
    800067f2:	00001097          	auipc	ra,0x1
    800067f6:	826080e7          	jalr	-2010(ra) # 80007018 <lst_push>
  for(; k > fk; k--) {
    800067fa:	fb8497e3          	bne	s1,s8,800067a8 <bd_malloc+0xf0>
  }
  //printf("malloc: %p size class %d\n", p, fk);
  release(&lock);
    800067fe:	00023517          	auipc	a0,0x23
    80006802:	80250513          	addi	a0,a0,-2046 # 80029000 <lock>
    80006806:	ffffa097          	auipc	ra,0xffffa
    8000680a:	34c080e7          	jalr	844(ra) # 80000b52 <release>
  return p;
}
    8000680e:	855a                	mv	a0,s6
    80006810:	70a6                	ld	ra,104(sp)
    80006812:	7406                	ld	s0,96(sp)
    80006814:	64e6                	ld	s1,88(sp)
    80006816:	6946                	ld	s2,80(sp)
    80006818:	69a6                	ld	s3,72(sp)
    8000681a:	6a06                	ld	s4,64(sp)
    8000681c:	7ae2                	ld	s5,56(sp)
    8000681e:	7b42                	ld	s6,48(sp)
    80006820:	7ba2                	ld	s7,40(sp)
    80006822:	7c02                	ld	s8,32(sp)
    80006824:	6ce2                	ld	s9,24(sp)
    80006826:	6d42                	ld	s10,16(sp)
    80006828:	6da2                	ld	s11,8(sp)
    8000682a:	6165                	addi	sp,sp,112
    8000682c:	8082                	ret

000000008000682e <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    8000682e:	7139                	addi	sp,sp,-64
    80006830:	fc06                	sd	ra,56(sp)
    80006832:	f822                	sd	s0,48(sp)
    80006834:	f426                	sd	s1,40(sp)
    80006836:	f04a                	sd	s2,32(sp)
    80006838:	ec4e                	sd	s3,24(sp)
    8000683a:	e852                	sd	s4,16(sp)
    8000683c:	e456                	sd	s5,8(sp)
    8000683e:	e05a                	sd	s6,0(sp)
    80006840:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006842:	00023a97          	auipc	s5,0x23
    80006846:	816aaa83          	lw	s5,-2026(s5) # 80029058 <nsizes>
  return n / BLK_SIZE(k);
    8000684a:	00022a17          	auipc	s4,0x22
    8000684e:	7fea3a03          	ld	s4,2046(s4) # 80029048 <bd_base>
    80006852:	41450a3b          	subw	s4,a0,s4
    80006856:	00022497          	auipc	s1,0x22
    8000685a:	7fa4b483          	ld	s1,2042(s1) # 80029050 <bd_sizes>
    8000685e:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006862:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006864:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006866:	03595363          	bge	s2,s5,8000688c <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    8000686a:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    8000686e:	013b15b3          	sll	a1,s6,s3
    80006872:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006876:	2581                	sext.w	a1,a1
    80006878:	6088                	ld	a0,0(s1)
    8000687a:	00000097          	auipc	ra,0x0
    8000687e:	b52080e7          	jalr	-1198(ra) # 800063cc <bit_isset>
    80006882:	02048493          	addi	s1,s1,32
    80006886:	e501                	bnez	a0,8000688e <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006888:	894e                	mv	s2,s3
    8000688a:	bff1                	j	80006866 <size+0x38>
      return k;
    }
  }
  return 0;
    8000688c:	4901                	li	s2,0
}
    8000688e:	854a                	mv	a0,s2
    80006890:	70e2                	ld	ra,56(sp)
    80006892:	7442                	ld	s0,48(sp)
    80006894:	74a2                	ld	s1,40(sp)
    80006896:	7902                	ld	s2,32(sp)
    80006898:	69e2                	ld	s3,24(sp)
    8000689a:	6a42                	ld	s4,16(sp)
    8000689c:	6aa2                	ld	s5,8(sp)
    8000689e:	6b02                	ld	s6,0(sp)
    800068a0:	6121                	addi	sp,sp,64
    800068a2:	8082                	ret

00000000800068a4 <bd_free>:

void
bd_free(void *p) {
    800068a4:	7159                	addi	sp,sp,-112
    800068a6:	f486                	sd	ra,104(sp)
    800068a8:	f0a2                	sd	s0,96(sp)
    800068aa:	eca6                	sd	s1,88(sp)
    800068ac:	e8ca                	sd	s2,80(sp)
    800068ae:	e4ce                	sd	s3,72(sp)
    800068b0:	e0d2                	sd	s4,64(sp)
    800068b2:	fc56                	sd	s5,56(sp)
    800068b4:	f85a                	sd	s6,48(sp)
    800068b6:	f45e                	sd	s7,40(sp)
    800068b8:	f062                	sd	s8,32(sp)
    800068ba:	ec66                	sd	s9,24(sp)
    800068bc:	e86a                	sd	s10,16(sp)
    800068be:	e46e                	sd	s11,8(sp)
    800068c0:	1880                	addi	s0,sp,112
    800068c2:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    800068c4:	00022517          	auipc	a0,0x22
    800068c8:	73c50513          	addi	a0,a0,1852 # 80029000 <lock>
    800068cc:	ffffa097          	auipc	ra,0xffffa
    800068d0:	21e080e7          	jalr	542(ra) # 80000aea <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    800068d4:	8556                	mv	a0,s5
    800068d6:	00000097          	auipc	ra,0x0
    800068da:	f58080e7          	jalr	-168(ra) # 8000682e <size>
    800068de:	84aa                	mv	s1,a0
    800068e0:	00022797          	auipc	a5,0x22
    800068e4:	7787a783          	lw	a5,1912(a5) # 80029058 <nsizes>
    800068e8:	37fd                	addiw	a5,a5,-1
    800068ea:	0af55d63          	bge	a0,a5,800069a4 <bd_free+0x100>
    800068ee:	00551a13          	slli	s4,a0,0x5
  int n = p - (char *) bd_base;
    800068f2:	00022c17          	auipc	s8,0x22
    800068f6:	756c0c13          	addi	s8,s8,1878 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    800068fa:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bd_toggle(bd_sizes[k].alloc,bi);
    800068fc:	00022b17          	auipc	s6,0x22
    80006900:	754b0b13          	addi	s6,s6,1876 # 80029050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006904:	00022c97          	auipc	s9,0x22
    80006908:	754c8c93          	addi	s9,s9,1876 # 80029058 <nsizes>
    8000690c:	a82d                	j	80006946 <bd_free+0xa2>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000690e:	fff58d9b          	addiw	s11,a1,-1
    80006912:	a881                	j	80006962 <bd_free+0xbe>
    q = addr(k, buddy);
    lst_remove(q);
    if(buddy % 2 == 0) {
      p = q;
    }
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006914:	020a0a13          	addi	s4,s4,32
    80006918:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    8000691a:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    8000691e:	40ba85bb          	subw	a1,s5,a1
    80006922:	009b97b3          	sll	a5,s7,s1
    80006926:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    8000692a:	000b3783          	ld	a5,0(s6)
    8000692e:	97d2                	add	a5,a5,s4
    80006930:	2581                	sext.w	a1,a1
    80006932:	6f88                	ld	a0,24(a5)
    80006934:	00000097          	auipc	ra,0x0
    80006938:	b00080e7          	jalr	-1280(ra) # 80006434 <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    8000693c:	000ca783          	lw	a5,0(s9)
    80006940:	37fd                	addiw	a5,a5,-1
    80006942:	06f4d163          	bge	s1,a5,800069a4 <bd_free+0x100>
  int n = p - (char *) bd_base;
    80006946:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    8000694a:	009b99b3          	sll	s3,s7,s1
    8000694e:	412a87bb          	subw	a5,s5,s2
    80006952:	0337c7b3          	div	a5,a5,s3
    80006956:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    8000695a:	8b85                	andi	a5,a5,1
    8000695c:	fbcd                	bnez	a5,8000690e <bd_free+0x6a>
    8000695e:	00158d9b          	addiw	s11,a1,1
    bd_toggle(bd_sizes[k].alloc,bi);
    80006962:	000b3d03          	ld	s10,0(s6)
    80006966:	9d52                	add	s10,s10,s4
    80006968:	010d3503          	ld	a0,16(s10)
    8000696c:	00000097          	auipc	ra,0x0
    80006970:	afc080e7          	jalr	-1284(ra) # 80006468 <bd_toggle>
    if(bit_get(bd_sizes[k].alloc,buddy)){
    80006974:	85ee                	mv	a1,s11
    80006976:	010d3503          	ld	a0,16(s10)
    8000697a:	00000097          	auipc	ra,0x0
    8000697e:	ca0080e7          	jalr	-864(ra) # 8000661a <bit_get>
    80006982:	e10d                	bnez	a0,800069a4 <bd_free+0x100>
  int n = bi * BLK_SIZE(k);
    80006984:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006988:	03b989bb          	mulw	s3,s3,s11
    8000698c:	994e                	add	s2,s2,s3
    lst_remove(q);
    8000698e:	854a                	mv	a0,s2
    80006990:	00000097          	auipc	ra,0x0
    80006994:	63c080e7          	jalr	1596(ra) # 80006fcc <lst_remove>
    if(buddy % 2 == 0) {
    80006998:	001d7d13          	andi	s10,s10,1
    8000699c:	f60d1ce3          	bnez	s10,80006914 <bd_free+0x70>
      p = q;
    800069a0:	8aca                	mv	s5,s2
    800069a2:	bf8d                	j	80006914 <bd_free+0x70>
  }
  //printf("free %p @ %d\n", p, k);
  lst_push(&bd_sizes[k].free, p);
    800069a4:	0496                	slli	s1,s1,0x5
    800069a6:	85d6                	mv	a1,s5
    800069a8:	00022517          	auipc	a0,0x22
    800069ac:	6a853503          	ld	a0,1704(a0) # 80029050 <bd_sizes>
    800069b0:	9526                	add	a0,a0,s1
    800069b2:	00000097          	auipc	ra,0x0
    800069b6:	666080e7          	jalr	1638(ra) # 80007018 <lst_push>
  release(&lock);
    800069ba:	00022517          	auipc	a0,0x22
    800069be:	64650513          	addi	a0,a0,1606 # 80029000 <lock>
    800069c2:	ffffa097          	auipc	ra,0xffffa
    800069c6:	190080e7          	jalr	400(ra) # 80000b52 <release>
}
    800069ca:	70a6                	ld	ra,104(sp)
    800069cc:	7406                	ld	s0,96(sp)
    800069ce:	64e6                	ld	s1,88(sp)
    800069d0:	6946                	ld	s2,80(sp)
    800069d2:	69a6                	ld	s3,72(sp)
    800069d4:	6a06                	ld	s4,64(sp)
    800069d6:	7ae2                	ld	s5,56(sp)
    800069d8:	7b42                	ld	s6,48(sp)
    800069da:	7ba2                	ld	s7,40(sp)
    800069dc:	7c02                	ld	s8,32(sp)
    800069de:	6ce2                	ld	s9,24(sp)
    800069e0:	6d42                	ld	s10,16(sp)
    800069e2:	6da2                	ld	s11,8(sp)
    800069e4:	6165                	addi	sp,sp,112
    800069e6:	8082                	ret

00000000800069e8 <blk_index_next>:

//get the index for the next block
int
blk_index_next(int k, char *p) {
    800069e8:	1141                	addi	sp,sp,-16
    800069ea:	e422                	sd	s0,8(sp)
    800069ec:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    800069ee:	00022797          	auipc	a5,0x22
    800069f2:	65a7b783          	ld	a5,1626(a5) # 80029048 <bd_base>
    800069f6:	8d9d                	sub	a1,a1,a5
    800069f8:	47c1                	li	a5,16
    800069fa:	00a797b3          	sll	a5,a5,a0
    800069fe:	02f5c533          	div	a0,a1,a5
    80006a02:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006a04:	02f5e5b3          	rem	a1,a1,a5
    80006a08:	c191                	beqz	a1,80006a0c <blk_index_next+0x24>
      n++;
    80006a0a:	2505                	addiw	a0,a0,1
  return n ;
}
    80006a0c:	6422                	ld	s0,8(sp)
    80006a0e:	0141                	addi	sp,sp,16
    80006a10:	8082                	ret

0000000080006a12 <log2>:

//get the #of bits
int
log2(uint64 n) {
    80006a12:	1141                	addi	sp,sp,-16
    80006a14:	e422                	sd	s0,8(sp)
    80006a16:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006a18:	4705                	li	a4,1
    80006a1a:	00a77b63          	bgeu	a4,a0,80006a30 <log2+0x1e>
    80006a1e:	87aa                	mv	a5,a0
  int k = 0;
    80006a20:	4501                	li	a0,0
    k++;
    80006a22:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006a24:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006a26:	fef76ee3          	bltu	a4,a5,80006a22 <log2+0x10>
  }
  return k;
}
    80006a2a:	6422                	ld	s0,8(sp)
    80006a2c:	0141                	addi	sp,sp,16
    80006a2e:	8082                	ret
  int k = 0;
    80006a30:	4501                	li	a0,0
    80006a32:	bfe5                	j	80006a2a <log2+0x18>

0000000080006a34 <bd_mark>:

void bd_mark(void *start,void *stop){
    80006a34:	711d                	addi	sp,sp,-96
    80006a36:	ec86                	sd	ra,88(sp)
    80006a38:	e8a2                	sd	s0,80(sp)
    80006a3a:	e4a6                	sd	s1,72(sp)
    80006a3c:	e0ca                	sd	s2,64(sp)
    80006a3e:	fc4e                	sd	s3,56(sp)
    80006a40:	f852                	sd	s4,48(sp)
    80006a42:	f456                	sd	s5,40(sp)
    80006a44:	f05a                	sd	s6,32(sp)
    80006a46:	ec5e                	sd	s7,24(sp)
    80006a48:	e862                	sd	s8,16(sp)
    80006a4a:	e466                	sd	s9,8(sp)
    80006a4c:	e06a                	sd	s10,0(sp)
    80006a4e:	1080                	addi	s0,sp,96
  int bi,bj;

  if(((uint64) start%LEAF_SIZE!=0)||((uint64)stop%LEAF_SIZE!=0))
    80006a50:	00b56933          	or	s2,a0,a1
    80006a54:	00f97913          	andi	s2,s2,15
    80006a58:	04091263          	bnez	s2,80006a9c <bd_mark+0x68>
    80006a5c:	8b2a                	mv	s6,a0
    80006a5e:	8bae                	mv	s7,a1
    panic("bd_mark");

  for(int k=0;k<nsizes;k++){
    80006a60:	00022c17          	auipc	s8,0x22
    80006a64:	5f8c2c03          	lw	s8,1528(s8) # 80029058 <nsizes>
    80006a68:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006a6a:	00022d17          	auipc	s10,0x22
    80006a6e:	5ded0d13          	addi	s10,s10,1502 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006a72:	4cc1                	li	s9,16
    bi=blk_index(k,start);
    bj=blk_index_next(k,stop);
    for(;bi<bj;bi++){
      if(k>0){
	     bit_set(bd_sizes[k].split,bi);
    80006a74:	00022a97          	auipc	s5,0x22
    80006a78:	5dca8a93          	addi	s5,s5,1500 # 80029050 <bd_sizes>
  for(int k=0;k<nsizes;k++){
    80006a7c:	07804563          	bgtz	s8,80006ae6 <bd_mark+0xb2>
      }
      //bit_set(bd_sizes[k].alloc,bi);
	  bd_toggle(bd_sizes[k].alloc,bi);
    }
  }
}
    80006a80:	60e6                	ld	ra,88(sp)
    80006a82:	6446                	ld	s0,80(sp)
    80006a84:	64a6                	ld	s1,72(sp)
    80006a86:	6906                	ld	s2,64(sp)
    80006a88:	79e2                	ld	s3,56(sp)
    80006a8a:	7a42                	ld	s4,48(sp)
    80006a8c:	7aa2                	ld	s5,40(sp)
    80006a8e:	7b02                	ld	s6,32(sp)
    80006a90:	6be2                	ld	s7,24(sp)
    80006a92:	6c42                	ld	s8,16(sp)
    80006a94:	6ca2                	ld	s9,8(sp)
    80006a96:	6d02                	ld	s10,0(sp)
    80006a98:	6125                	addi	sp,sp,96
    80006a9a:	8082                	ret
    panic("bd_mark");
    80006a9c:	00002517          	auipc	a0,0x2
    80006aa0:	e4c50513          	addi	a0,a0,-436 # 800088e8 <userret+0x858>
    80006aa4:	ffffa097          	auipc	ra,0xffffa
    80006aa8:	aaa080e7          	jalr	-1366(ra) # 8000054e <panic>
	  bd_toggle(bd_sizes[k].alloc,bi);
    80006aac:	000ab783          	ld	a5,0(s5)
    80006ab0:	97ca                	add	a5,a5,s2
    80006ab2:	85a6                	mv	a1,s1
    80006ab4:	6b88                	ld	a0,16(a5)
    80006ab6:	00000097          	auipc	ra,0x0
    80006aba:	9b2080e7          	jalr	-1614(ra) # 80006468 <bd_toggle>
    for(;bi<bj;bi++){
    80006abe:	2485                	addiw	s1,s1,1
    80006ac0:	009a0e63          	beq	s4,s1,80006adc <bd_mark+0xa8>
      if(k>0){
    80006ac4:	ff3054e3          	blez	s3,80006aac <bd_mark+0x78>
	     bit_set(bd_sizes[k].split,bi);
    80006ac8:	000ab783          	ld	a5,0(s5)
    80006acc:	97ca                	add	a5,a5,s2
    80006ace:	85a6                	mv	a1,s1
    80006ad0:	6f88                	ld	a0,24(a5)
    80006ad2:	00000097          	auipc	ra,0x0
    80006ad6:	932080e7          	jalr	-1742(ra) # 80006404 <bit_set>
    80006ada:	bfc9                	j	80006aac <bd_mark+0x78>
  for(int k=0;k<nsizes;k++){
    80006adc:	2985                	addiw	s3,s3,1
    80006ade:	02090913          	addi	s2,s2,32
    80006ae2:	f9898fe3          	beq	s3,s8,80006a80 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006ae6:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006aea:	409b04bb          	subw	s1,s6,s1
    80006aee:	013c97b3          	sll	a5,s9,s3
    80006af2:	02f4c4b3          	div	s1,s1,a5
    80006af6:	2481                	sext.w	s1,s1
    bj=blk_index_next(k,stop);
    80006af8:	85de                	mv	a1,s7
    80006afa:	854e                	mv	a0,s3
    80006afc:	00000097          	auipc	ra,0x0
    80006b00:	eec080e7          	jalr	-276(ra) # 800069e8 <blk_index_next>
    80006b04:	8a2a                	mv	s4,a0
    for(;bi<bj;bi++){
    80006b06:	faa4cfe3          	blt	s1,a0,80006ac4 <bd_mark+0x90>
    80006b0a:	bfc9                	j	80006adc <bd_mark+0xa8>

0000000080006b0c <bd_initfree_pair>:

int bd_initfree_pair(int k,int bi,void *allow_left,void *allow_right){
    80006b0c:	715d                	addi	sp,sp,-80
    80006b0e:	e486                	sd	ra,72(sp)
    80006b10:	e0a2                	sd	s0,64(sp)
    80006b12:	fc26                	sd	s1,56(sp)
    80006b14:	f84a                	sd	s2,48(sp)
    80006b16:	f44e                	sd	s3,40(sp)
    80006b18:	f052                	sd	s4,32(sp)
    80006b1a:	ec56                	sd	s5,24(sp)
    80006b1c:	e85a                	sd	s6,16(sp)
    80006b1e:	e45e                	sd	s7,8(sp)
    80006b20:	0880                	addi	s0,sp,80
    80006b22:	892a                	mv	s2,a0
    80006b24:	89b2                	mv	s3,a2
    80006b26:	8a36                	mv	s4,a3
	int buddy=(bi%2==0)?bi+1:bi-1;
    80006b28:	00058a9b          	sext.w	s5,a1
    80006b2c:	0015f793          	andi	a5,a1,1
    80006b30:	e7bd                	bnez	a5,80006b9e <bd_initfree_pair+0x92>
    80006b32:	00158b9b          	addiw	s7,a1,1
	int free=0;
	if(bit_get(bd_sizes[k].alloc,bi)){
    80006b36:	00591793          	slli	a5,s2,0x5
    80006b3a:	00022b17          	auipc	s6,0x22
    80006b3e:	516b3b03          	ld	s6,1302(s6) # 80029050 <bd_sizes>
    80006b42:	9b3e                	add	s6,s6,a5
    80006b44:	010b3503          	ld	a0,16(s6)
    80006b48:	00000097          	auipc	ra,0x0
    80006b4c:	ad2080e7          	jalr	-1326(ra) # 8000661a <bit_get>
    80006b50:	84aa                	mv	s1,a0
    80006b52:	c915                	beqz	a0,80006b86 <bd_initfree_pair+0x7a>
		free=BLK_SIZE(k);
    80006b54:	44c1                	li	s1,16
    80006b56:	012494b3          	sll	s1,s1,s2
    80006b5a:	2481                	sext.w	s1,s1
  int n = bi * BLK_SIZE(k);
    80006b5c:	87a6                	mv	a5,s1
  return (char *) bd_base + n;
    80006b5e:	00022717          	auipc	a4,0x22
    80006b62:	4ea73703          	ld	a4,1258(a4) # 80029048 <bd_base>
    80006b66:	029b85bb          	mulw	a1,s7,s1
    80006b6a:	95ba                	add	a1,a1,a4
		if(in_range(allow_left,allow_right,addr(k,buddy))){
    80006b6c:	0135e463          	bltu	a1,s3,80006b74 <bd_initfree_pair+0x68>
    80006b70:	0345ea63          	bltu	a1,s4,80006ba4 <bd_initfree_pair+0x98>
  return (char *) bd_base + n;
    80006b74:	02fa87bb          	mulw	a5,s5,a5
			lst_push(&bd_sizes[k].free,addr(k,buddy));
		}
		else{
			lst_push(&bd_sizes[k].free,addr(k,bi));
    80006b78:	00f705b3          	add	a1,a4,a5
    80006b7c:	855a                	mv	a0,s6
    80006b7e:	00000097          	auipc	ra,0x0
    80006b82:	49a080e7          	jalr	1178(ra) # 80007018 <lst_push>
		}
	}
	return free;
}
    80006b86:	8526                	mv	a0,s1
    80006b88:	60a6                	ld	ra,72(sp)
    80006b8a:	6406                	ld	s0,64(sp)
    80006b8c:	74e2                	ld	s1,56(sp)
    80006b8e:	7942                	ld	s2,48(sp)
    80006b90:	79a2                	ld	s3,40(sp)
    80006b92:	7a02                	ld	s4,32(sp)
    80006b94:	6ae2                	ld	s5,24(sp)
    80006b96:	6b42                	ld	s6,16(sp)
    80006b98:	6ba2                	ld	s7,8(sp)
    80006b9a:	6161                	addi	sp,sp,80
    80006b9c:	8082                	ret
	int buddy=(bi%2==0)?bi+1:bi-1;
    80006b9e:	fff58b9b          	addiw	s7,a1,-1
    80006ba2:	bf51                	j	80006b36 <bd_initfree_pair+0x2a>
			lst_push(&bd_sizes[k].free,addr(k,buddy));
    80006ba4:	855a                	mv	a0,s6
    80006ba6:	00000097          	auipc	ra,0x0
    80006baa:	472080e7          	jalr	1138(ra) # 80007018 <lst_push>
    80006bae:	bfe1                	j	80006b86 <bd_initfree_pair+0x7a>

0000000080006bb0 <bd_initfree>:

int bd_initfree(void *bd_left,void *bd_right,void *allow_left,void *allow_right){
    80006bb0:	7119                	addi	sp,sp,-128
    80006bb2:	fc86                	sd	ra,120(sp)
    80006bb4:	f8a2                	sd	s0,112(sp)
    80006bb6:	f4a6                	sd	s1,104(sp)
    80006bb8:	f0ca                	sd	s2,96(sp)
    80006bba:	ecce                	sd	s3,88(sp)
    80006bbc:	e8d2                	sd	s4,80(sp)
    80006bbe:	e4d6                	sd	s5,72(sp)
    80006bc0:	e0da                	sd	s6,64(sp)
    80006bc2:	fc5e                	sd	s7,56(sp)
    80006bc4:	f862                	sd	s8,48(sp)
    80006bc6:	f466                	sd	s9,40(sp)
    80006bc8:	f06a                	sd	s10,32(sp)
    80006bca:	ec6e                	sd	s11,24(sp)
    80006bcc:	0100                	addi	s0,sp,128
    80006bce:	f8a43423          	sd	a0,-120(s0)
	int free=0;

	for(int k=0;k<MAXSIZE;k++){
    80006bd2:	00022717          	auipc	a4,0x22
    80006bd6:	48672703          	lw	a4,1158(a4) # 80029058 <nsizes>
    80006bda:	4785                	li	a5,1
    80006bdc:	08e7d163          	bge	a5,a4,80006c5e <bd_initfree+0xae>
    80006be0:	8c2e                	mv	s8,a1
    80006be2:	8b32                	mv	s6,a2
    80006be4:	8bb6                	mv	s7,a3
    80006be6:	4901                	li	s2,0
	int free=0;
    80006be8:	4a81                	li	s5,0
  int n = p - (char *) bd_base;
    80006bea:	00022d97          	auipc	s11,0x22
    80006bee:	45ed8d93          	addi	s11,s11,1118 # 80029048 <bd_base>
  return n / BLK_SIZE(k);
    80006bf2:	4d41                	li	s10,16
	for(int k=0;k<MAXSIZE;k++){
    80006bf4:	00022c97          	auipc	s9,0x22
    80006bf8:	464c8c93          	addi	s9,s9,1124 # 80029058 <nsizes>
    80006bfc:	a039                	j	80006c0a <bd_initfree+0x5a>
    80006bfe:	2905                	addiw	s2,s2,1
    80006c00:	000ca783          	lw	a5,0(s9)
    80006c04:	37fd                	addiw	a5,a5,-1
    80006c06:	04f95d63          	bge	s2,a5,80006c60 <bd_initfree+0xb0>
		int left=blk_index_next(k,bd_left);
    80006c0a:	f8843583          	ld	a1,-120(s0)
    80006c0e:	854a                	mv	a0,s2
    80006c10:	00000097          	auipc	ra,0x0
    80006c14:	dd8080e7          	jalr	-552(ra) # 800069e8 <blk_index_next>
    80006c18:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006c1a:	000db483          	ld	s1,0(s11)
  return n / BLK_SIZE(k);
    80006c1e:	409c04bb          	subw	s1,s8,s1
    80006c22:	012d17b3          	sll	a5,s10,s2
    80006c26:	02f4c4b3          	div	s1,s1,a5
    80006c2a:	2481                	sext.w	s1,s1
		int right=blk_index(k,bd_right);
		free+=bd_initfree_pair(k,left,allow_left,allow_right);
    80006c2c:	86de                	mv	a3,s7
    80006c2e:	865a                	mv	a2,s6
    80006c30:	85aa                	mv	a1,a0
    80006c32:	854a                	mv	a0,s2
    80006c34:	00000097          	auipc	ra,0x0
    80006c38:	ed8080e7          	jalr	-296(ra) # 80006b0c <bd_initfree_pair>
    80006c3c:	01550a3b          	addw	s4,a0,s5
    80006c40:	000a0a9b          	sext.w	s5,s4
		if(right<=left){
    80006c44:	fa99dde3          	bge	s3,s1,80006bfe <bd_initfree+0x4e>
			continue;
		}
		free+=bd_initfree_pair(k,right,allow_left,allow_right);
    80006c48:	86de                	mv	a3,s7
    80006c4a:	865a                	mv	a2,s6
    80006c4c:	85a6                	mv	a1,s1
    80006c4e:	854a                	mv	a0,s2
    80006c50:	00000097          	auipc	ra,0x0
    80006c54:	ebc080e7          	jalr	-324(ra) # 80006b0c <bd_initfree_pair>
    80006c58:	00aa0abb          	addw	s5,s4,a0
    80006c5c:	b74d                	j	80006bfe <bd_initfree+0x4e>
	int free=0;
    80006c5e:	4a81                	li	s5,0
	}
	return free;
}
    80006c60:	8556                	mv	a0,s5
    80006c62:	70e6                	ld	ra,120(sp)
    80006c64:	7446                	ld	s0,112(sp)
    80006c66:	74a6                	ld	s1,104(sp)
    80006c68:	7906                	ld	s2,96(sp)
    80006c6a:	69e6                	ld	s3,88(sp)
    80006c6c:	6a46                	ld	s4,80(sp)
    80006c6e:	6aa6                	ld	s5,72(sp)
    80006c70:	6b06                	ld	s6,64(sp)
    80006c72:	7be2                	ld	s7,56(sp)
    80006c74:	7c42                	ld	s8,48(sp)
    80006c76:	7ca2                	ld	s9,40(sp)
    80006c78:	7d02                	ld	s10,32(sp)
    80006c7a:	6de2                	ld	s11,24(sp)
    80006c7c:	6109                	addi	sp,sp,128
    80006c7e:	8082                	ret

0000000080006c80 <bd_mark_data_structures>:

int bd_mark_data_structures(char *p){
    80006c80:	7179                	addi	sp,sp,-48
    80006c82:	f406                	sd	ra,40(sp)
    80006c84:	f022                	sd	s0,32(sp)
    80006c86:	ec26                	sd	s1,24(sp)
    80006c88:	e84a                	sd	s2,16(sp)
    80006c8a:	e44e                	sd	s3,8(sp)
    80006c8c:	1800                	addi	s0,sp,48
    80006c8e:	892a                	mv	s2,a0
	int meta=p-(char*)bd_base;
    80006c90:	00022997          	auipc	s3,0x22
    80006c94:	3b898993          	addi	s3,s3,952 # 80029048 <bd_base>
    80006c98:	0009b483          	ld	s1,0(s3)
    80006c9c:	409504bb          	subw	s1,a0,s1
	printf("bd: %d meta bytes for managing %d bytes of memory\n",meta,BLK_SIZE(MAXSIZE));
    80006ca0:	00022797          	auipc	a5,0x22
    80006ca4:	3b87a783          	lw	a5,952(a5) # 80029058 <nsizes>
    80006ca8:	37fd                	addiw	a5,a5,-1
    80006caa:	4641                	li	a2,16
    80006cac:	00f61633          	sll	a2,a2,a5
    80006cb0:	85a6                	mv	a1,s1
    80006cb2:	00002517          	auipc	a0,0x2
    80006cb6:	c3e50513          	addi	a0,a0,-962 # 800088f0 <userret+0x860>
    80006cba:	ffffa097          	auipc	ra,0xffffa
    80006cbe:	8de080e7          	jalr	-1826(ra) # 80000598 <printf>
	bd_mark(bd_base,p);
    80006cc2:	85ca                	mv	a1,s2
    80006cc4:	0009b503          	ld	a0,0(s3)
    80006cc8:	00000097          	auipc	ra,0x0
    80006ccc:	d6c080e7          	jalr	-660(ra) # 80006a34 <bd_mark>
	return meta;
}
    80006cd0:	8526                	mv	a0,s1
    80006cd2:	70a2                	ld	ra,40(sp)
    80006cd4:	7402                	ld	s0,32(sp)
    80006cd6:	64e2                	ld	s1,24(sp)
    80006cd8:	6942                	ld	s2,16(sp)
    80006cda:	69a2                	ld	s3,8(sp)
    80006cdc:	6145                	addi	sp,sp,48
    80006cde:	8082                	ret

0000000080006ce0 <bd_mark_unavailable>:

int bd_mark_unavailable(void *end,void *left){
    80006ce0:	1101                	addi	sp,sp,-32
    80006ce2:	ec06                	sd	ra,24(sp)
    80006ce4:	e822                	sd	s0,16(sp)
    80006ce6:	e426                	sd	s1,8(sp)
    80006ce8:	1000                	addi	s0,sp,32
	int unavailable=BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006cea:	00022497          	auipc	s1,0x22
    80006cee:	36e4a483          	lw	s1,878(s1) # 80029058 <nsizes>
    80006cf2:	fff4879b          	addiw	a5,s1,-1
    80006cf6:	44c1                	li	s1,16
    80006cf8:	00f494b3          	sll	s1,s1,a5
    80006cfc:	00022797          	auipc	a5,0x22
    80006d00:	34c7b783          	ld	a5,844(a5) # 80029048 <bd_base>
    80006d04:	8d1d                	sub	a0,a0,a5
    80006d06:	40a4853b          	subw	a0,s1,a0
    80006d0a:	0005049b          	sext.w	s1,a0
	if(unavailable>0) unavailable=ROUNDUP(unavailable,LEAF_SIZE);
    80006d0e:	00905a63          	blez	s1,80006d22 <bd_mark_unavailable+0x42>
    80006d12:	357d                	addiw	a0,a0,-1
    80006d14:	41f5549b          	sraiw	s1,a0,0x1f
    80006d18:	01c4d49b          	srliw	s1,s1,0x1c
    80006d1c:	9ca9                	addw	s1,s1,a0
    80006d1e:	98c1                	andi	s1,s1,-16
    80006d20:	24c1                	addiw	s1,s1,16
	printf("bd:0x%x bytes unavailable\n",unavailable);
    80006d22:	85a6                	mv	a1,s1
    80006d24:	00002517          	auipc	a0,0x2
    80006d28:	c0450513          	addi	a0,a0,-1020 # 80008928 <userret+0x898>
    80006d2c:	ffffa097          	auipc	ra,0xffffa
    80006d30:	86c080e7          	jalr	-1940(ra) # 80000598 <printf>
	
	void *bd_end=bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006d34:	00022717          	auipc	a4,0x22
    80006d38:	31473703          	ld	a4,788(a4) # 80029048 <bd_base>
    80006d3c:	00022597          	auipc	a1,0x22
    80006d40:	31c5a583          	lw	a1,796(a1) # 80029058 <nsizes>
    80006d44:	fff5879b          	addiw	a5,a1,-1
    80006d48:	45c1                	li	a1,16
    80006d4a:	00f595b3          	sll	a1,a1,a5
    80006d4e:	40958533          	sub	a0,a1,s1
	bd_mark(bd_end,bd_base+BLK_SIZE(MAXSIZE));
    80006d52:	95ba                	add	a1,a1,a4
    80006d54:	953a                	add	a0,a0,a4
    80006d56:	00000097          	auipc	ra,0x0
    80006d5a:	cde080e7          	jalr	-802(ra) # 80006a34 <bd_mark>
	return unavailable;
}
    80006d5e:	8526                	mv	a0,s1
    80006d60:	60e2                	ld	ra,24(sp)
    80006d62:	6442                	ld	s0,16(sp)
    80006d64:	64a2                	ld	s1,8(sp)
    80006d66:	6105                	addi	sp,sp,32
    80006d68:	8082                	ret

0000000080006d6a <bd_init>:

// The buddy allocator manages the memory from base till end.
void
bd_init(void *base, void *end) {
    80006d6a:	715d                	addi	sp,sp,-80
    80006d6c:	e486                	sd	ra,72(sp)
    80006d6e:	e0a2                	sd	s0,64(sp)
    80006d70:	fc26                	sd	s1,56(sp)
    80006d72:	f84a                	sd	s2,48(sp)
    80006d74:	f44e                	sd	s3,40(sp)
    80006d76:	f052                	sd	s4,32(sp)
    80006d78:	ec56                	sd	s5,24(sp)
    80006d7a:	e85a                	sd	s6,16(sp)
    80006d7c:	e45e                	sd	s7,8(sp)
    80006d7e:	e062                	sd	s8,0(sp)
    80006d80:	0880                	addi	s0,sp,80
    80006d82:	8c2e                	mv	s8,a1
	char *p=(char *)ROUNDUP((uint64)base,LEAF_SIZE);
    80006d84:	fff50493          	addi	s1,a0,-1
    80006d88:	98c1                	andi	s1,s1,-16
    80006d8a:	04c1                	addi	s1,s1,16
	int sz;
	
 	initlock(&lock, "buddy");
    80006d8c:	00002597          	auipc	a1,0x2
    80006d90:	bbc58593          	addi	a1,a1,-1092 # 80008948 <userret+0x8b8>
    80006d94:	00022517          	auipc	a0,0x22
    80006d98:	26c50513          	addi	a0,a0,620 # 80029000 <lock>
    80006d9c:	ffffa097          	auipc	ra,0xffffa
    80006da0:	c3c080e7          	jalr	-964(ra) # 800009d8 <initlock>
	
  // YOUR CODE HERE TO INITIALIZE THE BUDDY ALLOCATOR.  FEEL FREE TO
  // BORROW CODE FROM bd_init() in the lecture notes.
	bd_base=(void *)p;
    80006da4:	00022797          	auipc	a5,0x22
    80006da8:	2a97b223          	sd	s1,676(a5) # 80029048 <bd_base>
	
	nsizes=log2(((char *)end-p)/LEAF_SIZE)+1;
    80006dac:	409c0933          	sub	s2,s8,s1
    80006db0:	43f95513          	srai	a0,s2,0x3f
    80006db4:	893d                	andi	a0,a0,15
    80006db6:	954a                	add	a0,a0,s2
    80006db8:	8511                	srai	a0,a0,0x4
    80006dba:	00000097          	auipc	ra,0x0
    80006dbe:	c58080e7          	jalr	-936(ra) # 80006a12 <log2>
	if((char*)end-p>BLK_SIZE(MAXSIZE)){
    80006dc2:	47c1                	li	a5,16
    80006dc4:	00a797b3          	sll	a5,a5,a0
    80006dc8:	1b27c863          	blt	a5,s2,80006f78 <bd_init+0x20e>
	nsizes=log2(((char *)end-p)/LEAF_SIZE)+1;
    80006dcc:	2505                	addiw	a0,a0,1
    80006dce:	00022797          	auipc	a5,0x22
    80006dd2:	28a7a523          	sw	a0,650(a5) # 80029058 <nsizes>
		nsizes++;
	}
	
	printf("bd: memory sz is %d bytes, and allocate an size array of length %d\n",(char*)end-p,nsizes);
    80006dd6:	00022997          	auipc	s3,0x22
    80006dda:	28298993          	addi	s3,s3,642 # 80029058 <nsizes>
    80006dde:	0009a603          	lw	a2,0(s3)
    80006de2:	85ca                	mv	a1,s2
    80006de4:	00002517          	auipc	a0,0x2
    80006de8:	b6c50513          	addi	a0,a0,-1172 # 80008950 <userret+0x8c0>
    80006dec:	ffff9097          	auipc	ra,0xffff9
    80006df0:	7ac080e7          	jalr	1964(ra) # 80000598 <printf>
	//allocate bd size array
	bd_sizes=(Sz_info *)p;
    80006df4:	00022797          	auipc	a5,0x22
    80006df8:	2497be23          	sd	s1,604(a5) # 80029050 <bd_sizes>
	p+=sizeof(Sz_info)*nsizes;
    80006dfc:	0009a603          	lw	a2,0(s3)
    80006e00:	00561913          	slli	s2,a2,0x5
    80006e04:	9926                	add	s2,s2,s1
	memset(bd_sizes,0,sizeof(Sz_info)*nsizes);
    80006e06:	0056161b          	slliw	a2,a2,0x5
    80006e0a:	4581                	li	a1,0
    80006e0c:	8526                	mv	a0,s1
    80006e0e:	ffffa097          	auipc	ra,0xffffa
    80006e12:	da0080e7          	jalr	-608(ra) # 80000bae <memset>
	
	//init the free lst, alloc the value
	for(int k=0;k<nsizes;k++){
    80006e16:	0009a783          	lw	a5,0(s3)
    80006e1a:	06f05a63          	blez	a5,80006e8e <bd_init+0x124>
    80006e1e:	4981                	li	s3,0
		lst_init(&bd_sizes[k].free);  //connecting a node with previous and next
    80006e20:	00022a97          	auipc	s5,0x22
    80006e24:	230a8a93          	addi	s5,s5,560 # 80029050 <bd_sizes>
		sz=sizeof(char)* ROUNDUP(NBLK(k),8)/8;
    80006e28:	00022a17          	auipc	s4,0x22
    80006e2c:	230a0a13          	addi	s4,s4,560 # 80029058 <nsizes>
    80006e30:	4b05                	li	s6,1
		lst_init(&bd_sizes[k].free);  //connecting a node with previous and next
    80006e32:	00599b93          	slli	s7,s3,0x5
    80006e36:	000ab503          	ld	a0,0(s5)
    80006e3a:	955e                	add	a0,a0,s7
    80006e3c:	00000097          	auipc	ra,0x0
    80006e40:	16a080e7          	jalr	362(ra) # 80006fa6 <lst_init>
		sz=sizeof(char)* ROUNDUP(NBLK(k),8)/8;
    80006e44:	000a2483          	lw	s1,0(s4)
    80006e48:	34fd                	addiw	s1,s1,-1
    80006e4a:	413484bb          	subw	s1,s1,s3
    80006e4e:	009b14bb          	sllw	s1,s6,s1
    80006e52:	fff4879b          	addiw	a5,s1,-1
    80006e56:	41f7d49b          	sraiw	s1,a5,0x1f
    80006e5a:	01d4d49b          	srliw	s1,s1,0x1d
    80006e5e:	9cbd                	addw	s1,s1,a5
    80006e60:	98e1                	andi	s1,s1,-8
    80006e62:	24a1                	addiw	s1,s1,8
		bd_sizes[k].alloc=p;
    80006e64:	000ab783          	ld	a5,0(s5)
    80006e68:	9bbe                	add	s7,s7,a5
    80006e6a:	012bb823          	sd	s2,16(s7)
		memset(bd_sizes[k].alloc,0,sz);
    80006e6e:	848d                	srai	s1,s1,0x3
    80006e70:	8626                	mv	a2,s1
    80006e72:	4581                	li	a1,0
    80006e74:	854a                	mv	a0,s2
    80006e76:	ffffa097          	auipc	ra,0xffffa
    80006e7a:	d38080e7          	jalr	-712(ra) # 80000bae <memset>
		p+=sz;
    80006e7e:	9926                	add	s2,s2,s1
	for(int k=0;k<nsizes;k++){
    80006e80:	0985                	addi	s3,s3,1
    80006e82:	000a2703          	lw	a4,0(s4)
    80006e86:	0009879b          	sext.w	a5,s3
    80006e8a:	fae7c4e3          	blt	a5,a4,80006e32 <bd_init+0xc8>
	}
	
	//alloc the split array
	for (int k=1;k<nsizes;k++){
    80006e8e:	00022797          	auipc	a5,0x22
    80006e92:	1ca7a783          	lw	a5,458(a5) # 80029058 <nsizes>
    80006e96:	4705                	li	a4,1
    80006e98:	06f75163          	bge	a4,a5,80006efa <bd_init+0x190>
    80006e9c:	02000a13          	li	s4,32
    80006ea0:	4985                	li	s3,1
		sz=sizeof(char)*(ROUNDUP(NBLK(k),8))/8;
    80006ea2:	4b85                	li	s7,1
		bd_sizes[k].split=p;
    80006ea4:	00022b17          	auipc	s6,0x22
    80006ea8:	1acb0b13          	addi	s6,s6,428 # 80029050 <bd_sizes>
	for (int k=1;k<nsizes;k++){
    80006eac:	00022a97          	auipc	s5,0x22
    80006eb0:	1aca8a93          	addi	s5,s5,428 # 80029058 <nsizes>
		sz=sizeof(char)*(ROUNDUP(NBLK(k),8))/8;
    80006eb4:	37fd                	addiw	a5,a5,-1
    80006eb6:	413787bb          	subw	a5,a5,s3
    80006eba:	00fb94bb          	sllw	s1,s7,a5
    80006ebe:	fff4879b          	addiw	a5,s1,-1
    80006ec2:	41f7d49b          	sraiw	s1,a5,0x1f
    80006ec6:	01d4d49b          	srliw	s1,s1,0x1d
    80006eca:	9cbd                	addw	s1,s1,a5
    80006ecc:	98e1                	andi	s1,s1,-8
    80006ece:	24a1                	addiw	s1,s1,8
		bd_sizes[k].split=p;
    80006ed0:	000b3783          	ld	a5,0(s6)
    80006ed4:	97d2                	add	a5,a5,s4
    80006ed6:	0127bc23          	sd	s2,24(a5)
		memset(bd_sizes[k].split,0,sz);
    80006eda:	848d                	srai	s1,s1,0x3
    80006edc:	8626                	mv	a2,s1
    80006ede:	4581                	li	a1,0
    80006ee0:	854a                	mv	a0,s2
    80006ee2:	ffffa097          	auipc	ra,0xffffa
    80006ee6:	ccc080e7          	jalr	-820(ra) # 80000bae <memset>
		p+=sz;
    80006eea:	9926                	add	s2,s2,s1
	for (int k=1;k<nsizes;k++){
    80006eec:	2985                	addiw	s3,s3,1
    80006eee:	000aa783          	lw	a5,0(s5)
    80006ef2:	020a0a13          	addi	s4,s4,32
    80006ef6:	faf9cfe3          	blt	s3,a5,80006eb4 <bd_init+0x14a>
	}

	p=(char *) ROUNDUP((uint64)p,LEAF_SIZE);
    80006efa:	197d                	addi	s2,s2,-1
    80006efc:	ff097913          	andi	s2,s2,-16
    80006f00:	0941                	addi	s2,s2,16
	
	//mark [base,p] as allocated, so they will not be allocated again
	int meta=bd_mark_data_structures(p);
    80006f02:	854a                	mv	a0,s2
    80006f04:	00000097          	auipc	ra,0x0
    80006f08:	d7c080e7          	jalr	-644(ra) # 80006c80 <bd_mark_data_structures>
    80006f0c:	8a2a                	mv	s4,a0

	//mark unavailable memory [end,]HEAP_SIZE] as allocated
	int unavailable=bd_mark_unavailable(end,p);
    80006f0e:	85ca                	mv	a1,s2
    80006f10:	8562                	mv	a0,s8
    80006f12:	00000097          	auipc	ra,0x0
    80006f16:	dce080e7          	jalr	-562(ra) # 80006ce0 <bd_mark_unavailable>
    80006f1a:	89aa                	mv	s3,a0

	void *bd_end=bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006f1c:	00022a97          	auipc	s5,0x22
    80006f20:	13ca8a93          	addi	s5,s5,316 # 80029058 <nsizes>
    80006f24:	000aa783          	lw	a5,0(s5)
    80006f28:	37fd                	addiw	a5,a5,-1
    80006f2a:	44c1                	li	s1,16
    80006f2c:	00f497b3          	sll	a5,s1,a5
    80006f30:	8f89                	sub	a5,a5,a0
	int free=bd_initfree(p,bd_end,p,end); //get available space 
    80006f32:	86e2                	mv	a3,s8
    80006f34:	864a                	mv	a2,s2
    80006f36:	00022597          	auipc	a1,0x22
    80006f3a:	1125b583          	ld	a1,274(a1) # 80029048 <bd_base>
    80006f3e:	95be                	add	a1,a1,a5
    80006f40:	854a                	mv	a0,s2
    80006f42:	00000097          	auipc	ra,0x0
    80006f46:	c6e080e7          	jalr	-914(ra) # 80006bb0 <bd_initfree>

	if(free!=BLK_SIZE(MAXSIZE)-meta-unavailable){
    80006f4a:	000aa603          	lw	a2,0(s5)
    80006f4e:	367d                	addiw	a2,a2,-1
    80006f50:	00c49633          	sll	a2,s1,a2
    80006f54:	41460633          	sub	a2,a2,s4
    80006f58:	41360633          	sub	a2,a2,s3
    80006f5c:	02c51463          	bne	a0,a2,80006f84 <bd_init+0x21a>
		printf("free %d %d\n",free,BLK_SIZE(MAXSIZE)-meta-unavailable);
		panic("bd_init: free memory");
	}
  
}
    80006f60:	60a6                	ld	ra,72(sp)
    80006f62:	6406                	ld	s0,64(sp)
    80006f64:	74e2                	ld	s1,56(sp)
    80006f66:	7942                	ld	s2,48(sp)
    80006f68:	79a2                	ld	s3,40(sp)
    80006f6a:	7a02                	ld	s4,32(sp)
    80006f6c:	6ae2                	ld	s5,24(sp)
    80006f6e:	6b42                	ld	s6,16(sp)
    80006f70:	6ba2                	ld	s7,8(sp)
    80006f72:	6c02                	ld	s8,0(sp)
    80006f74:	6161                	addi	sp,sp,80
    80006f76:	8082                	ret
		nsizes++;
    80006f78:	2509                	addiw	a0,a0,2
    80006f7a:	00022797          	auipc	a5,0x22
    80006f7e:	0ca7af23          	sw	a0,222(a5) # 80029058 <nsizes>
    80006f82:	bd91                	j	80006dd6 <bd_init+0x6c>
		printf("free %d %d\n",free,BLK_SIZE(MAXSIZE)-meta-unavailable);
    80006f84:	85aa                	mv	a1,a0
    80006f86:	00002517          	auipc	a0,0x2
    80006f8a:	a1250513          	addi	a0,a0,-1518 # 80008998 <userret+0x908>
    80006f8e:	ffff9097          	auipc	ra,0xffff9
    80006f92:	60a080e7          	jalr	1546(ra) # 80000598 <printf>
		panic("bd_init: free memory");
    80006f96:	00002517          	auipc	a0,0x2
    80006f9a:	a1250513          	addi	a0,a0,-1518 # 800089a8 <userret+0x918>
    80006f9e:	ffff9097          	auipc	ra,0xffff9
    80006fa2:	5b0080e7          	jalr	1456(ra) # 8000054e <panic>

0000000080006fa6 <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    80006fa6:	1141                	addi	sp,sp,-16
    80006fa8:	e422                	sd	s0,8(sp)
    80006faa:	0800                	addi	s0,sp,16
  lst->next = lst;
    80006fac:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80006fae:	e508                	sd	a0,8(a0)
}
    80006fb0:	6422                	ld	s0,8(sp)
    80006fb2:	0141                	addi	sp,sp,16
    80006fb4:	8082                	ret

0000000080006fb6 <lst_empty>:

int
lst_empty(struct list *lst) {
    80006fb6:	1141                	addi	sp,sp,-16
    80006fb8:	e422                	sd	s0,8(sp)
    80006fba:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80006fbc:	611c                	ld	a5,0(a0)
    80006fbe:	40a78533          	sub	a0,a5,a0
}
    80006fc2:	00153513          	seqz	a0,a0
    80006fc6:	6422                	ld	s0,8(sp)
    80006fc8:	0141                	addi	sp,sp,16
    80006fca:	8082                	ret

0000000080006fcc <lst_remove>:

void
lst_remove(struct list *e) {
    80006fcc:	1141                	addi	sp,sp,-16
    80006fce:	e422                	sd	s0,8(sp)
    80006fd0:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80006fd2:	6518                	ld	a4,8(a0)
    80006fd4:	611c                	ld	a5,0(a0)
    80006fd6:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    80006fd8:	6518                	ld	a4,8(a0)
    80006fda:	e798                	sd	a4,8(a5)
}
    80006fdc:	6422                	ld	s0,8(sp)
    80006fde:	0141                	addi	sp,sp,16
    80006fe0:	8082                	ret

0000000080006fe2 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80006fe2:	1101                	addi	sp,sp,-32
    80006fe4:	ec06                	sd	ra,24(sp)
    80006fe6:	e822                	sd	s0,16(sp)
    80006fe8:	e426                	sd	s1,8(sp)
    80006fea:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80006fec:	6104                	ld	s1,0(a0)
    80006fee:	00a48d63          	beq	s1,a0,80007008 <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80006ff2:	8526                	mv	a0,s1
    80006ff4:	00000097          	auipc	ra,0x0
    80006ff8:	fd8080e7          	jalr	-40(ra) # 80006fcc <lst_remove>
  return (void *)p;
}
    80006ffc:	8526                	mv	a0,s1
    80006ffe:	60e2                	ld	ra,24(sp)
    80007000:	6442                	ld	s0,16(sp)
    80007002:	64a2                	ld	s1,8(sp)
    80007004:	6105                	addi	sp,sp,32
    80007006:	8082                	ret
    panic("lst_pop");
    80007008:	00002517          	auipc	a0,0x2
    8000700c:	9b850513          	addi	a0,a0,-1608 # 800089c0 <userret+0x930>
    80007010:	ffff9097          	auipc	ra,0xffff9
    80007014:	53e080e7          	jalr	1342(ra) # 8000054e <panic>

0000000080007018 <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    80007018:	1141                	addi	sp,sp,-16
    8000701a:	e422                	sd	s0,8(sp)
    8000701c:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    8000701e:	611c                	ld	a5,0(a0)
    80007020:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007022:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007024:	611c                	ld	a5,0(a0)
    80007026:	e78c                	sd	a1,8(a5)
  lst->next = e;
    80007028:	e10c                	sd	a1,0(a0)
}
    8000702a:	6422                	ld	s0,8(sp)
    8000702c:	0141                	addi	sp,sp,16
    8000702e:	8082                	ret

0000000080007030 <lst_print>:

void
lst_print(struct list *lst)
{
    80007030:	7179                	addi	sp,sp,-48
    80007032:	f406                	sd	ra,40(sp)
    80007034:	f022                	sd	s0,32(sp)
    80007036:	ec26                	sd	s1,24(sp)
    80007038:	e84a                	sd	s2,16(sp)
    8000703a:	e44e                	sd	s3,8(sp)
    8000703c:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000703e:	6104                	ld	s1,0(a0)
    80007040:	02950063          	beq	a0,s1,80007060 <lst_print+0x30>
    80007044:	892a                	mv	s2,a0
    printf(" %p", p);
    80007046:	00002997          	auipc	s3,0x2
    8000704a:	98298993          	addi	s3,s3,-1662 # 800089c8 <userret+0x938>
    8000704e:	85a6                	mv	a1,s1
    80007050:	854e                	mv	a0,s3
    80007052:	ffff9097          	auipc	ra,0xffff9
    80007056:	546080e7          	jalr	1350(ra) # 80000598 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    8000705a:	6084                	ld	s1,0(s1)
    8000705c:	fe9919e3          	bne	s2,s1,8000704e <lst_print+0x1e>
  }
  printf("\n");
    80007060:	00001517          	auipc	a0,0x1
    80007064:	15050513          	addi	a0,a0,336 # 800081b0 <userret+0x120>
    80007068:	ffff9097          	auipc	ra,0xffff9
    8000706c:	530080e7          	jalr	1328(ra) # 80000598 <printf>
}
    80007070:	70a2                	ld	ra,40(sp)
    80007072:	7402                	ld	s0,32(sp)
    80007074:	64e2                	ld	s1,24(sp)
    80007076:	6942                	ld	s2,16(sp)
    80007078:	69a2                	ld	s3,8(sp)
    8000707a:	6145                	addi	sp,sp,48
    8000707c:	8082                	ret
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
