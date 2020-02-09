
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	80010113          	addi	sp,sp,-2048 # 80009800 <stack0>
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
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fb660613          	addi	a2,a2,-74 # 80009000 <mscratch0>
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
    80000060:	b9478793          	addi	a5,a5,-1132 # 80005bf0 <timervec>
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
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <ticks+0xffffffff7ffd57d7>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	ca278793          	addi	a5,a5,-862 # 80000d48 <main>
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
    80000108:	00011517          	auipc	a0,0x11
    8000010c:	6f850513          	addi	a0,a0,1784 # 80011800 <cons>
    80000110:	00001097          	auipc	ra,0x1
    80000114:	9c2080e7          	jalr	-1598(ra) # 80000ad2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000118:	00011497          	auipc	s1,0x11
    8000011c:	6e848493          	addi	s1,s1,1768 # 80011800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000120:	89a6                	mv	s3,s1
    80000122:	00011917          	auipc	s2,0x11
    80000126:	77690913          	addi	s2,s2,1910 # 80011898 <cons+0x98>
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
    80000144:	6f4080e7          	jalr	1780(ra) # 80001834 <myproc>
    80000148:	591c                	lw	a5,48(a0)
    8000014a:	e7b5                	bnez	a5,800001b6 <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    8000014c:	85ce                	mv	a1,s3
    8000014e:	854a                	mv	a0,s2
    80000150:	00002097          	auipc	ra,0x2
    80000154:	eea080e7          	jalr	-278(ra) # 8000203a <sleep>
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
    80000190:	0d4080e7          	jalr	212(ra) # 80002260 <either_copyout>
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
    800001a0:	00011517          	auipc	a0,0x11
    800001a4:	66050513          	addi	a0,a0,1632 # 80011800 <cons>
    800001a8:	00001097          	auipc	ra,0x1
    800001ac:	992080e7          	jalr	-1646(ra) # 80000b3a <release>

  return target - n;
    800001b0:	414b853b          	subw	a0,s7,s4
    800001b4:	a811                	j	800001c8 <consoleread+0xe8>
        release(&cons.lock);
    800001b6:	00011517          	auipc	a0,0x11
    800001ba:	64a50513          	addi	a0,a0,1610 # 80011800 <cons>
    800001be:	00001097          	auipc	ra,0x1
    800001c2:	97c080e7          	jalr	-1668(ra) # 80000b3a <release>
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
    800001ee:	00011717          	auipc	a4,0x11
    800001f2:	6af72523          	sw	a5,1706(a4) # 80011898 <cons+0x98>
    800001f6:	b76d                	j	800001a0 <consoleread+0xc0>

00000000800001f8 <consputc>:
  if(panicked){
    800001f8:	00029797          	auipc	a5,0x29
    800001fc:	e087a783          	lw	a5,-504(a5) # 80029000 <end>
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
    8000025e:	00011517          	auipc	a0,0x11
    80000262:	5a250513          	addi	a0,a0,1442 # 80011800 <cons>
    80000266:	00001097          	auipc	ra,0x1
    8000026a:	86c080e7          	jalr	-1940(ra) # 80000ad2 <acquire>
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
    80000290:	02a080e7          	jalr	42(ra) # 800022b6 <either_copyin>
    80000294:	01450b63          	beq	a0,s4,800002aa <consolewrite+0x64>
    consputc(c);
    80000298:	fbf44503          	lbu	a0,-65(s0)
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	f5c080e7          	jalr	-164(ra) # 800001f8 <consputc>
  for(i = 0; i < n; i++){
    800002a4:	0485                	addi	s1,s1,1
    800002a6:	fd249ee3          	bne	s1,s2,80000282 <consolewrite+0x3c>
  release(&cons.lock);
    800002aa:	00011517          	auipc	a0,0x11
    800002ae:	55650513          	addi	a0,a0,1366 # 80011800 <cons>
    800002b2:	00001097          	auipc	ra,0x1
    800002b6:	888080e7          	jalr	-1912(ra) # 80000b3a <release>
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
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	52450513          	addi	a0,a0,1316 # 80011800 <cons>
    800002e4:	00000097          	auipc	ra,0x0
    800002e8:	7ee080e7          	jalr	2030(ra) # 80000ad2 <acquire>

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
    80000306:	00a080e7          	jalr	10(ra) # 8000230c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030a:	00011517          	auipc	a0,0x11
    8000030e:	4f650513          	addi	a0,a0,1270 # 80011800 <cons>
    80000312:	00001097          	auipc	ra,0x1
    80000316:	828080e7          	jalr	-2008(ra) # 80000b3a <release>
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
    8000032e:	00011717          	auipc	a4,0x11
    80000332:	4d270713          	addi	a4,a4,1234 # 80011800 <cons>
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
    80000358:	00011797          	auipc	a5,0x11
    8000035c:	4a878793          	addi	a5,a5,1192 # 80011800 <cons>
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
    80000386:	00011797          	auipc	a5,0x11
    8000038a:	5127a783          	lw	a5,1298(a5) # 80011898 <cons+0x98>
    8000038e:	0807879b          	addiw	a5,a5,128
    80000392:	f6f61ce3          	bne	a2,a5,8000030a <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000396:	863e                	mv	a2,a5
    80000398:	a07d                	j	80000446 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000039a:	00011717          	auipc	a4,0x11
    8000039e:	46670713          	addi	a4,a4,1126 # 80011800 <cons>
    800003a2:	0a072783          	lw	a5,160(a4)
    800003a6:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003aa:	00011497          	auipc	s1,0x11
    800003ae:	45648493          	addi	s1,s1,1110 # 80011800 <cons>
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
    800003e6:	00011717          	auipc	a4,0x11
    800003ea:	41a70713          	addi	a4,a4,1050 # 80011800 <cons>
    800003ee:	0a072783          	lw	a5,160(a4)
    800003f2:	09c72703          	lw	a4,156(a4)
    800003f6:	f0f70ae3          	beq	a4,a5,8000030a <consoleintr+0x3c>
      cons.e--;
    800003fa:	37fd                	addiw	a5,a5,-1
    800003fc:	00011717          	auipc	a4,0x11
    80000400:	4af72223          	sw	a5,1188(a4) # 800118a0 <cons+0xa0>
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
    80000422:	00011797          	auipc	a5,0x11
    80000426:	3de78793          	addi	a5,a5,990 # 80011800 <cons>
    8000042a:	0a07a703          	lw	a4,160(a5)
    8000042e:	0017069b          	addiw	a3,a4,1
    80000432:	0006861b          	sext.w	a2,a3
    80000436:	0ad7a023          	sw	a3,160(a5)
    8000043a:	07f77713          	andi	a4,a4,127
    8000043e:	97ba                	add	a5,a5,a4
    80000440:	4729                	li	a4,10
    80000442:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000446:	00011797          	auipc	a5,0x11
    8000044a:	44c7ab23          	sw	a2,1110(a5) # 8001189c <cons+0x9c>
        wakeup(&cons.r);
    8000044e:	00011517          	auipc	a0,0x11
    80000452:	44a50513          	addi	a0,a0,1098 # 80011898 <cons+0x98>
    80000456:	00002097          	auipc	ra,0x2
    8000045a:	d30080e7          	jalr	-720(ra) # 80002186 <wakeup>
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
    80000468:	00007597          	auipc	a1,0x7
    8000046c:	cb058593          	addi	a1,a1,-848 # 80007118 <userret+0x88>
    80000470:	00011517          	auipc	a0,0x11
    80000474:	39050513          	addi	a0,a0,912 # 80011800 <cons>
    80000478:	00000097          	auipc	ra,0x0
    8000047c:	548080e7          	jalr	1352(ra) # 800009c0 <initlock>

  uartinit();
    80000480:	00000097          	auipc	ra,0x0
    80000484:	330080e7          	jalr	816(ra) # 800007b0 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000488:	00021797          	auipc	a5,0x21
    8000048c:	46078793          	addi	a5,a5,1120 # 800218e8 <devsw>
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
    800004ca:	00007617          	auipc	a2,0x7
    800004ce:	3e660613          	addi	a2,a2,998 # 800078b0 <digits>
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
    8000055a:	00011797          	auipc	a5,0x11
    8000055e:	3607a323          	sw	zero,870(a5) # 800118c0 <pr+0x18>
  printf("panic: ");
    80000562:	00007517          	auipc	a0,0x7
    80000566:	bbe50513          	addi	a0,a0,-1090 # 80007120 <userret+0x90>
    8000056a:	00000097          	auipc	ra,0x0
    8000056e:	02e080e7          	jalr	46(ra) # 80000598 <printf>
  printf(s);
    80000572:	8526                	mv	a0,s1
    80000574:	00000097          	auipc	ra,0x0
    80000578:	024080e7          	jalr	36(ra) # 80000598 <printf>
  printf("\n");
    8000057c:	00007517          	auipc	a0,0x7
    80000580:	c3450513          	addi	a0,a0,-972 # 800071b0 <userret+0x120>
    80000584:	00000097          	auipc	ra,0x0
    80000588:	014080e7          	jalr	20(ra) # 80000598 <printf>
  panicked = 1; // freeze other CPUs
    8000058c:	4785                	li	a5,1
    8000058e:	00029717          	auipc	a4,0x29
    80000592:	a6f72923          	sw	a5,-1422(a4) # 80029000 <end>
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
    800005ca:	00011d97          	auipc	s11,0x11
    800005ce:	2f6dad83          	lw	s11,758(s11) # 800118c0 <pr+0x18>
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
    800005f6:	00007b97          	auipc	s7,0x7
    800005fa:	2bab8b93          	addi	s7,s7,698 # 800078b0 <digits>
    switch(c){
    800005fe:	07300c93          	li	s9,115
    80000602:	06400c13          	li	s8,100
    80000606:	a82d                	j	80000640 <printf+0xa8>
    acquire(&pr.lock);
    80000608:	00011517          	auipc	a0,0x11
    8000060c:	2a050513          	addi	a0,a0,672 # 800118a8 <pr>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	4c2080e7          	jalr	1218(ra) # 80000ad2 <acquire>
    80000618:	bf7d                	j	800005d6 <printf+0x3e>
    panic("null fmt");
    8000061a:	00007517          	auipc	a0,0x7
    8000061e:	b1650513          	addi	a0,a0,-1258 # 80007130 <userret+0xa0>
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
    8000071a:	00007917          	auipc	s2,0x7
    8000071e:	a0e90913          	addi	s2,s2,-1522 # 80007128 <userret+0x98>
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
    8000076c:	00011517          	auipc	a0,0x11
    80000770:	13c50513          	addi	a0,a0,316 # 800118a8 <pr>
    80000774:	00000097          	auipc	ra,0x0
    80000778:	3c6080e7          	jalr	966(ra) # 80000b3a <release>
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
    80000788:	00011497          	auipc	s1,0x11
    8000078c:	12048493          	addi	s1,s1,288 # 800118a8 <pr>
    80000790:	00007597          	auipc	a1,0x7
    80000794:	9b058593          	addi	a1,a1,-1616 # 80007140 <userret+0xb0>
    80000798:	8526                	mv	a0,s1
    8000079a:	00000097          	auipc	ra,0x0
    8000079e:	226080e7          	jalr	550(ra) # 800009c0 <initlock>
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
    8000087c:	78878793          	addi	a5,a5,1928 # 80029000 <end>
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
    80000894:	306080e7          	jalr	774(ra) # 80000b96 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000898:	00011917          	auipc	s2,0x11
    8000089c:	03090913          	addi	s2,s2,48 # 800118c8 <kmem>
    800008a0:	854a                	mv	a0,s2
    800008a2:	00000097          	auipc	ra,0x0
    800008a6:	230080e7          	jalr	560(ra) # 80000ad2 <acquire>
  r->next = kmem.freelist;
    800008aa:	01893783          	ld	a5,24(s2)
    800008ae:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    800008b0:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    800008b4:	854a                	mv	a0,s2
    800008b6:	00000097          	auipc	ra,0x0
    800008ba:	284080e7          	jalr	644(ra) # 80000b3a <release>
}
    800008be:	60e2                	ld	ra,24(sp)
    800008c0:	6442                	ld	s0,16(sp)
    800008c2:	64a2                	ld	s1,8(sp)
    800008c4:	6902                	ld	s2,0(sp)
    800008c6:	6105                	addi	sp,sp,32
    800008c8:	8082                	ret
    panic("kfree");
    800008ca:	00007517          	auipc	a0,0x7
    800008ce:	87e50513          	addi	a0,a0,-1922 # 80007148 <userret+0xb8>
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
    800008ea:	6485                	lui	s1,0x1
    800008ec:	14fd                	addi	s1,s1,-1
    800008ee:	94aa                	add	s1,s1,a0
    800008f0:	757d                	lui	a0,0xfffff
    800008f2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800008f4:	6789                	lui	a5,0x2
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
    80000924:	1141                	addi	sp,sp,-16
    80000926:	e406                	sd	ra,8(sp)
    80000928:	e022                	sd	s0,0(sp)
    8000092a:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    8000092c:	00007597          	auipc	a1,0x7
    80000930:	82458593          	addi	a1,a1,-2012 # 80007150 <userret+0xc0>
    80000934:	00011517          	auipc	a0,0x11
    80000938:	f9450513          	addi	a0,a0,-108 # 800118c8 <kmem>
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	084080e7          	jalr	132(ra) # 800009c0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000944:	45c5                	li	a1,17
    80000946:	05ee                	slli	a1,a1,0x1b
    80000948:	00028517          	auipc	a0,0x28
    8000094c:	6b850513          	addi	a0,a0,1720 # 80029000 <end>
    80000950:	00000097          	auipc	ra,0x0
    80000954:	f8a080e7          	jalr	-118(ra) # 800008da <freerange>
}
    80000958:	60a2                	ld	ra,8(sp)
    8000095a:	6402                	ld	s0,0(sp)
    8000095c:	0141                	addi	sp,sp,16
    8000095e:	8082                	ret

0000000080000960 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000960:	1101                	addi	sp,sp,-32
    80000962:	ec06                	sd	ra,24(sp)
    80000964:	e822                	sd	s0,16(sp)
    80000966:	e426                	sd	s1,8(sp)
    80000968:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000096a:	00011497          	auipc	s1,0x11
    8000096e:	f5e48493          	addi	s1,s1,-162 # 800118c8 <kmem>
    80000972:	8526                	mv	a0,s1
    80000974:	00000097          	auipc	ra,0x0
    80000978:	15e080e7          	jalr	350(ra) # 80000ad2 <acquire>
  r = kmem.freelist;
    8000097c:	6c84                	ld	s1,24(s1)
  if(r)
    8000097e:	c885                	beqz	s1,800009ae <kalloc+0x4e>
    kmem.freelist = r->next;
    80000980:	609c                	ld	a5,0(s1)
    80000982:	00011517          	auipc	a0,0x11
    80000986:	f4650513          	addi	a0,a0,-186 # 800118c8 <kmem>
    8000098a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	1ae080e7          	jalr	430(ra) # 80000b3a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000994:	6605                	lui	a2,0x1
    80000996:	4595                	li	a1,5
    80000998:	8526                	mv	a0,s1
    8000099a:	00000097          	auipc	ra,0x0
    8000099e:	1fc080e7          	jalr	508(ra) # 80000b96 <memset>
  return (void*)r;
}
    800009a2:	8526                	mv	a0,s1
    800009a4:	60e2                	ld	ra,24(sp)
    800009a6:	6442                	ld	s0,16(sp)
    800009a8:	64a2                	ld	s1,8(sp)
    800009aa:	6105                	addi	sp,sp,32
    800009ac:	8082                	ret
  release(&kmem.lock);
    800009ae:	00011517          	auipc	a0,0x11
    800009b2:	f1a50513          	addi	a0,a0,-230 # 800118c8 <kmem>
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	184080e7          	jalr	388(ra) # 80000b3a <release>
  if(r)
    800009be:	b7d5                	j	800009a2 <kalloc+0x42>

00000000800009c0 <initlock>:

uint64 ntest_and_set;

void
initlock(struct spinlock *lk, char *name)
{
    800009c0:	1141                	addi	sp,sp,-16
    800009c2:	e422                	sd	s0,8(sp)
    800009c4:	0800                	addi	s0,sp,16
  lk->name = name;
    800009c6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800009c8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800009cc:	00053823          	sd	zero,16(a0)
}
    800009d0:	6422                	ld	s0,8(sp)
    800009d2:	0141                	addi	sp,sp,16
    800009d4:	8082                	ret

00000000800009d6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009e0:	100024f3          	csrr	s1,sstatus
    800009e4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800009e8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800009ea:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800009ee:	00001097          	auipc	ra,0x1
    800009f2:	e2a080e7          	jalr	-470(ra) # 80001818 <mycpu>
    800009f6:	5d3c                	lw	a5,120(a0)
    800009f8:	cf89                	beqz	a5,80000a12 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800009fa:	00001097          	auipc	ra,0x1
    800009fe:	e1e080e7          	jalr	-482(ra) # 80001818 <mycpu>
    80000a02:	5d3c                	lw	a5,120(a0)
    80000a04:	2785                	addiw	a5,a5,1
    80000a06:	dd3c                	sw	a5,120(a0)
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret
    mycpu()->intena = old;
    80000a12:	00001097          	auipc	ra,0x1
    80000a16:	e06080e7          	jalr	-506(ra) # 80001818 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000a1a:	8085                	srli	s1,s1,0x1
    80000a1c:	8885                	andi	s1,s1,1
    80000a1e:	dd64                	sw	s1,124(a0)
    80000a20:	bfe9                	j	800009fa <push_off+0x24>

0000000080000a22 <pop_off>:

void
pop_off(void)
{
    80000a22:	1141                	addi	sp,sp,-16
    80000a24:	e406                	sd	ra,8(sp)
    80000a26:	e022                	sd	s0,0(sp)
    80000a28:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000a2a:	00001097          	auipc	ra,0x1
    80000a2e:	dee080e7          	jalr	-530(ra) # 80001818 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a32:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000a36:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000a38:	ef8d                	bnez	a5,80000a72 <pop_off+0x50>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000a3a:	5d3c                	lw	a5,120(a0)
    80000a3c:	37fd                	addiw	a5,a5,-1
    80000a3e:	0007871b          	sext.w	a4,a5
    80000a42:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000a44:	02079693          	slli	a3,a5,0x20
    80000a48:	0206cd63          	bltz	a3,80000a82 <pop_off+0x60>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000a4c:	ef19                	bnez	a4,80000a6a <pop_off+0x48>
    80000a4e:	5d7c                	lw	a5,124(a0)
    80000a50:	cf89                	beqz	a5,80000a6a <pop_off+0x48>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000a52:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000a56:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000a5a:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000a5e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000a62:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000a66:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000a6a:	60a2                	ld	ra,8(sp)
    80000a6c:	6402                	ld	s0,0(sp)
    80000a6e:	0141                	addi	sp,sp,16
    80000a70:	8082                	ret
    panic("pop_off - interruptible");
    80000a72:	00006517          	auipc	a0,0x6
    80000a76:	6e650513          	addi	a0,a0,1766 # 80007158 <userret+0xc8>
    80000a7a:	00000097          	auipc	ra,0x0
    80000a7e:	ad4080e7          	jalr	-1324(ra) # 8000054e <panic>
    panic("pop_off");
    80000a82:	00006517          	auipc	a0,0x6
    80000a86:	6ee50513          	addi	a0,a0,1774 # 80007170 <userret+0xe0>
    80000a8a:	00000097          	auipc	ra,0x0
    80000a8e:	ac4080e7          	jalr	-1340(ra) # 8000054e <panic>

0000000080000a92 <holding>:
{
    80000a92:	1101                	addi	sp,sp,-32
    80000a94:	ec06                	sd	ra,24(sp)
    80000a96:	e822                	sd	s0,16(sp)
    80000a98:	e426                	sd	s1,8(sp)
    80000a9a:	1000                	addi	s0,sp,32
    80000a9c:	84aa                	mv	s1,a0
  push_off();
    80000a9e:	00000097          	auipc	ra,0x0
    80000aa2:	f38080e7          	jalr	-200(ra) # 800009d6 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000aa6:	409c                	lw	a5,0(s1)
    80000aa8:	ef81                	bnez	a5,80000ac0 <holding+0x2e>
    80000aaa:	4481                	li	s1,0
  pop_off();
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	f76080e7          	jalr	-138(ra) # 80000a22 <pop_off>
}
    80000ab4:	8526                	mv	a0,s1
    80000ab6:	60e2                	ld	ra,24(sp)
    80000ab8:	6442                	ld	s0,16(sp)
    80000aba:	64a2                	ld	s1,8(sp)
    80000abc:	6105                	addi	sp,sp,32
    80000abe:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000ac0:	6884                	ld	s1,16(s1)
    80000ac2:	00001097          	auipc	ra,0x1
    80000ac6:	d56080e7          	jalr	-682(ra) # 80001818 <mycpu>
    80000aca:	8c89                	sub	s1,s1,a0
    80000acc:	0014b493          	seqz	s1,s1
    80000ad0:	bff1                	j	80000aac <holding+0x1a>

0000000080000ad2 <acquire>:
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
    80000adc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ade:	00000097          	auipc	ra,0x0
    80000ae2:	ef8080e7          	jalr	-264(ra) # 800009d6 <push_off>
  if(holding(lk))
    80000ae6:	8526                	mv	a0,s1
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	faa080e7          	jalr	-86(ra) # 80000a92 <holding>
    80000af0:	e901                	bnez	a0,80000b00 <acquire+0x2e>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000af2:	4685                	li	a3,1
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000af4:	00028717          	auipc	a4,0x28
    80000af8:	51470713          	addi	a4,a4,1300 # 80029008 <ntest_and_set>
    80000afc:	4605                	li	a2,1
    80000afe:	a829                	j	80000b18 <acquire+0x46>
    panic("acquire");
    80000b00:	00006517          	auipc	a0,0x6
    80000b04:	67850513          	addi	a0,a0,1656 # 80007178 <userret+0xe8>
    80000b08:	00000097          	auipc	ra,0x0
    80000b0c:	a46080e7          	jalr	-1466(ra) # 8000054e <panic>
     __sync_fetch_and_add(&ntest_and_set, 1);
    80000b10:	0f50000f          	fence	iorw,ow
    80000b14:	04c7302f          	amoadd.d.aq	zero,a2,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000b18:	87b6                	mv	a5,a3
    80000b1a:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000b1e:	2781                	sext.w	a5,a5
    80000b20:	fbe5                	bnez	a5,80000b10 <acquire+0x3e>
  __sync_synchronize();
    80000b22:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000b26:	00001097          	auipc	ra,0x1
    80000b2a:	cf2080e7          	jalr	-782(ra) # 80001818 <mycpu>
    80000b2e:	e888                	sd	a0,16(s1)
}
    80000b30:	60e2                	ld	ra,24(sp)
    80000b32:	6442                	ld	s0,16(sp)
    80000b34:	64a2                	ld	s1,8(sp)
    80000b36:	6105                	addi	sp,sp,32
    80000b38:	8082                	ret

0000000080000b3a <release>:
{
    80000b3a:	1101                	addi	sp,sp,-32
    80000b3c:	ec06                	sd	ra,24(sp)
    80000b3e:	e822                	sd	s0,16(sp)
    80000b40:	e426                	sd	s1,8(sp)
    80000b42:	1000                	addi	s0,sp,32
    80000b44:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000b46:	00000097          	auipc	ra,0x0
    80000b4a:	f4c080e7          	jalr	-180(ra) # 80000a92 <holding>
    80000b4e:	c115                	beqz	a0,80000b72 <release+0x38>
  lk->cpu = 0;
    80000b50:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000b54:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000b58:	0f50000f          	fence	iorw,ow
    80000b5c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000b60:	00000097          	auipc	ra,0x0
    80000b64:	ec2080e7          	jalr	-318(ra) # 80000a22 <pop_off>
}
    80000b68:	60e2                	ld	ra,24(sp)
    80000b6a:	6442                	ld	s0,16(sp)
    80000b6c:	64a2                	ld	s1,8(sp)
    80000b6e:	6105                	addi	sp,sp,32
    80000b70:	8082                	ret
    panic("release");
    80000b72:	00006517          	auipc	a0,0x6
    80000b76:	60e50513          	addi	a0,a0,1550 # 80007180 <userret+0xf0>
    80000b7a:	00000097          	auipc	ra,0x0
    80000b7e:	9d4080e7          	jalr	-1580(ra) # 8000054e <panic>

0000000080000b82 <sys_ntas>:

uint64
sys_ntas(void)
{
    80000b82:	1141                	addi	sp,sp,-16
    80000b84:	e422                	sd	s0,8(sp)
    80000b86:	0800                	addi	s0,sp,16
  return ntest_and_set;
}
    80000b88:	00028517          	auipc	a0,0x28
    80000b8c:	48053503          	ld	a0,1152(a0) # 80029008 <ntest_and_set>
    80000b90:	6422                	ld	s0,8(sp)
    80000b92:	0141                	addi	sp,sp,16
    80000b94:	8082                	ret

0000000080000b96 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000b96:	1141                	addi	sp,sp,-16
    80000b98:	e422                	sd	s0,8(sp)
    80000b9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000b9c:	ce09                	beqz	a2,80000bb6 <memset+0x20>
    80000b9e:	87aa                	mv	a5,a0
    80000ba0:	fff6071b          	addiw	a4,a2,-1
    80000ba4:	1702                	slli	a4,a4,0x20
    80000ba6:	9301                	srli	a4,a4,0x20
    80000ba8:	0705                	addi	a4,a4,1
    80000baa:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000bac:	00b78023          	sb	a1,0(a5) # 2000 <_entry-0x7fffe000>
  for(i = 0; i < n; i++){
    80000bb0:	0785                	addi	a5,a5,1
    80000bb2:	fee79de3          	bne	a5,a4,80000bac <memset+0x16>
  }
  return dst;
}
    80000bb6:	6422                	ld	s0,8(sp)
    80000bb8:	0141                	addi	sp,sp,16
    80000bba:	8082                	ret

0000000080000bbc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000bbc:	1141                	addi	sp,sp,-16
    80000bbe:	e422                	sd	s0,8(sp)
    80000bc0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000bc2:	ca05                	beqz	a2,80000bf2 <memcmp+0x36>
    80000bc4:	fff6069b          	addiw	a3,a2,-1
    80000bc8:	1682                	slli	a3,a3,0x20
    80000bca:	9281                	srli	a3,a3,0x20
    80000bcc:	0685                	addi	a3,a3,1
    80000bce:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000bd0:	00054783          	lbu	a5,0(a0)
    80000bd4:	0005c703          	lbu	a4,0(a1)
    80000bd8:	00e79863          	bne	a5,a4,80000be8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000bdc:	0505                	addi	a0,a0,1
    80000bde:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000be0:	fed518e3          	bne	a0,a3,80000bd0 <memcmp+0x14>
  }

  return 0;
    80000be4:	4501                	li	a0,0
    80000be6:	a019                	j	80000bec <memcmp+0x30>
      return *s1 - *s2;
    80000be8:	40e7853b          	subw	a0,a5,a4
}
    80000bec:	6422                	ld	s0,8(sp)
    80000bee:	0141                	addi	sp,sp,16
    80000bf0:	8082                	ret
  return 0;
    80000bf2:	4501                	li	a0,0
    80000bf4:	bfe5                	j	80000bec <memcmp+0x30>

0000000080000bf6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000bf6:	1141                	addi	sp,sp,-16
    80000bf8:	e422                	sd	s0,8(sp)
    80000bfa:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000bfc:	02a5e563          	bltu	a1,a0,80000c26 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000c00:	fff6069b          	addiw	a3,a2,-1
    80000c04:	ce11                	beqz	a2,80000c20 <memmove+0x2a>
    80000c06:	1682                	slli	a3,a3,0x20
    80000c08:	9281                	srli	a3,a3,0x20
    80000c0a:	0685                	addi	a3,a3,1
    80000c0c:	96ae                	add	a3,a3,a1
    80000c0e:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000c10:	0585                	addi	a1,a1,1
    80000c12:	0785                	addi	a5,a5,1
    80000c14:	fff5c703          	lbu	a4,-1(a1)
    80000c18:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000c1c:	fed59ae3          	bne	a1,a3,80000c10 <memmove+0x1a>

  return dst;
}
    80000c20:	6422                	ld	s0,8(sp)
    80000c22:	0141                	addi	sp,sp,16
    80000c24:	8082                	ret
  if(s < d && s + n > d){
    80000c26:	02061713          	slli	a4,a2,0x20
    80000c2a:	9301                	srli	a4,a4,0x20
    80000c2c:	00e587b3          	add	a5,a1,a4
    80000c30:	fcf578e3          	bgeu	a0,a5,80000c00 <memmove+0xa>
    d += n;
    80000c34:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000c36:	fff6069b          	addiw	a3,a2,-1
    80000c3a:	d27d                	beqz	a2,80000c20 <memmove+0x2a>
    80000c3c:	02069613          	slli	a2,a3,0x20
    80000c40:	9201                	srli	a2,a2,0x20
    80000c42:	fff64613          	not	a2,a2
    80000c46:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000c48:	17fd                	addi	a5,a5,-1
    80000c4a:	177d                	addi	a4,a4,-1
    80000c4c:	0007c683          	lbu	a3,0(a5)
    80000c50:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000c54:	fec79ae3          	bne	a5,a2,80000c48 <memmove+0x52>
    80000c58:	b7e1                	j	80000c20 <memmove+0x2a>

0000000080000c5a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000c5a:	1141                	addi	sp,sp,-16
    80000c5c:	e406                	sd	ra,8(sp)
    80000c5e:	e022                	sd	s0,0(sp)
    80000c60:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	f94080e7          	jalr	-108(ra) # 80000bf6 <memmove>
}
    80000c6a:	60a2                	ld	ra,8(sp)
    80000c6c:	6402                	ld	s0,0(sp)
    80000c6e:	0141                	addi	sp,sp,16
    80000c70:	8082                	ret

0000000080000c72 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000c72:	1141                	addi	sp,sp,-16
    80000c74:	e422                	sd	s0,8(sp)
    80000c76:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000c78:	ce11                	beqz	a2,80000c94 <strncmp+0x22>
    80000c7a:	00054783          	lbu	a5,0(a0)
    80000c7e:	cf89                	beqz	a5,80000c98 <strncmp+0x26>
    80000c80:	0005c703          	lbu	a4,0(a1)
    80000c84:	00f71a63          	bne	a4,a5,80000c98 <strncmp+0x26>
    n--, p++, q++;
    80000c88:	367d                	addiw	a2,a2,-1
    80000c8a:	0505                	addi	a0,a0,1
    80000c8c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000c8e:	f675                	bnez	a2,80000c7a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000c90:	4501                	li	a0,0
    80000c92:	a809                	j	80000ca4 <strncmp+0x32>
    80000c94:	4501                	li	a0,0
    80000c96:	a039                	j	80000ca4 <strncmp+0x32>
  if(n == 0)
    80000c98:	ca09                	beqz	a2,80000caa <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000c9a:	00054503          	lbu	a0,0(a0)
    80000c9e:	0005c783          	lbu	a5,0(a1)
    80000ca2:	9d1d                	subw	a0,a0,a5
}
    80000ca4:	6422                	ld	s0,8(sp)
    80000ca6:	0141                	addi	sp,sp,16
    80000ca8:	8082                	ret
    return 0;
    80000caa:	4501                	li	a0,0
    80000cac:	bfe5                	j	80000ca4 <strncmp+0x32>

0000000080000cae <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000cae:	1141                	addi	sp,sp,-16
    80000cb0:	e422                	sd	s0,8(sp)
    80000cb2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000cb4:	872a                	mv	a4,a0
    80000cb6:	8832                	mv	a6,a2
    80000cb8:	367d                	addiw	a2,a2,-1
    80000cba:	01005963          	blez	a6,80000ccc <strncpy+0x1e>
    80000cbe:	0705                	addi	a4,a4,1
    80000cc0:	0005c783          	lbu	a5,0(a1)
    80000cc4:	fef70fa3          	sb	a5,-1(a4)
    80000cc8:	0585                	addi	a1,a1,1
    80000cca:	f7f5                	bnez	a5,80000cb6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ccc:	86ba                	mv	a3,a4
    80000cce:	00c05c63          	blez	a2,80000ce6 <strncpy+0x38>
    *s++ = 0;
    80000cd2:	0685                	addi	a3,a3,1
    80000cd4:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000cd8:	fff6c793          	not	a5,a3
    80000cdc:	9fb9                	addw	a5,a5,a4
    80000cde:	010787bb          	addw	a5,a5,a6
    80000ce2:	fef048e3          	bgtz	a5,80000cd2 <strncpy+0x24>
  return os;
}
    80000ce6:	6422                	ld	s0,8(sp)
    80000ce8:	0141                	addi	sp,sp,16
    80000cea:	8082                	ret

0000000080000cec <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000cec:	1141                	addi	sp,sp,-16
    80000cee:	e422                	sd	s0,8(sp)
    80000cf0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000cf2:	02c05363          	blez	a2,80000d18 <safestrcpy+0x2c>
    80000cf6:	fff6069b          	addiw	a3,a2,-1
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	96ae                	add	a3,a3,a1
    80000d00:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000d02:	00d58963          	beq	a1,a3,80000d14 <safestrcpy+0x28>
    80000d06:	0585                	addi	a1,a1,1
    80000d08:	0785                	addi	a5,a5,1
    80000d0a:	fff5c703          	lbu	a4,-1(a1)
    80000d0e:	fee78fa3          	sb	a4,-1(a5)
    80000d12:	fb65                	bnez	a4,80000d02 <safestrcpy+0x16>
    ;
  *s = 0;
    80000d14:	00078023          	sb	zero,0(a5)
  return os;
}
    80000d18:	6422                	ld	s0,8(sp)
    80000d1a:	0141                	addi	sp,sp,16
    80000d1c:	8082                	ret

0000000080000d1e <strlen>:

int
strlen(const char *s)
{
    80000d1e:	1141                	addi	sp,sp,-16
    80000d20:	e422                	sd	s0,8(sp)
    80000d22:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000d24:	00054783          	lbu	a5,0(a0)
    80000d28:	cf91                	beqz	a5,80000d44 <strlen+0x26>
    80000d2a:	0505                	addi	a0,a0,1
    80000d2c:	87aa                	mv	a5,a0
    80000d2e:	4685                	li	a3,1
    80000d30:	9e89                	subw	a3,a3,a0
    80000d32:	00f6853b          	addw	a0,a3,a5
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff7c703          	lbu	a4,-1(a5)
    80000d3c:	fb7d                	bnez	a4,80000d32 <strlen+0x14>
    ;
  return n;
}
    80000d3e:	6422                	ld	s0,8(sp)
    80000d40:	0141                	addi	sp,sp,16
    80000d42:	8082                	ret
  for(n = 0; s[n]; n++)
    80000d44:	4501                	li	a0,0
    80000d46:	bfe5                	j	80000d3e <strlen+0x20>

0000000080000d48 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000d48:	1141                	addi	sp,sp,-16
    80000d4a:	e406                	sd	ra,8(sp)
    80000d4c:	e022                	sd	s0,0(sp)
    80000d4e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000d50:	00001097          	auipc	ra,0x1
    80000d54:	ab8080e7          	jalr	-1352(ra) # 80001808 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000d58:	00028717          	auipc	a4,0x28
    80000d5c:	2b870713          	addi	a4,a4,696 # 80029010 <started>
  if(cpuid() == 0){
    80000d60:	c139                	beqz	a0,80000da6 <main+0x5e>
    while(started == 0)
    80000d62:	431c                	lw	a5,0(a4)
    80000d64:	2781                	sext.w	a5,a5
    80000d66:	dff5                	beqz	a5,80000d62 <main+0x1a>
      ;
    __sync_synchronize();
    80000d68:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000d6c:	00001097          	auipc	ra,0x1
    80000d70:	a9c080e7          	jalr	-1380(ra) # 80001808 <cpuid>
    80000d74:	85aa                	mv	a1,a0
    80000d76:	00006517          	auipc	a0,0x6
    80000d7a:	42a50513          	addi	a0,a0,1066 # 800071a0 <userret+0x110>
    80000d7e:	00000097          	auipc	ra,0x0
    80000d82:	81a080e7          	jalr	-2022(ra) # 80000598 <printf>
    kvminithart();    // turn on paging
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	1ea080e7          	jalr	490(ra) # 80000f70 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000d8e:	00001097          	auipc	ra,0x1
    80000d92:	6be080e7          	jalr	1726(ra) # 8000244c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000d96:	00005097          	auipc	ra,0x5
    80000d9a:	e9a080e7          	jalr	-358(ra) # 80005c30 <plicinithart>
  }

  scheduler();        
    80000d9e:	00001097          	auipc	ra,0x1
    80000da2:	fd4080e7          	jalr	-44(ra) # 80001d72 <scheduler>
    consoleinit();
    80000da6:	fffff097          	auipc	ra,0xfffff
    80000daa:	6ba080e7          	jalr	1722(ra) # 80000460 <consoleinit>
    printfinit();
    80000dae:	00000097          	auipc	ra,0x0
    80000db2:	9d0080e7          	jalr	-1584(ra) # 8000077e <printfinit>
    printf("\n");
    80000db6:	00006517          	auipc	a0,0x6
    80000dba:	3fa50513          	addi	a0,a0,1018 # 800071b0 <userret+0x120>
    80000dbe:	fffff097          	auipc	ra,0xfffff
    80000dc2:	7da080e7          	jalr	2010(ra) # 80000598 <printf>
    printf("xv6 kernel is booting\n");
    80000dc6:	00006517          	auipc	a0,0x6
    80000dca:	3c250513          	addi	a0,a0,962 # 80007188 <userret+0xf8>
    80000dce:	fffff097          	auipc	ra,0xfffff
    80000dd2:	7ca080e7          	jalr	1994(ra) # 80000598 <printf>
    printf("\n");
    80000dd6:	00006517          	auipc	a0,0x6
    80000dda:	3da50513          	addi	a0,a0,986 # 800071b0 <userret+0x120>
    80000dde:	fffff097          	auipc	ra,0xfffff
    80000de2:	7ba080e7          	jalr	1978(ra) # 80000598 <printf>
    kinit();         // physical page allocator
    80000de6:	00000097          	auipc	ra,0x0
    80000dea:	b3e080e7          	jalr	-1218(ra) # 80000924 <kinit>
    kvminit();       // create kernel page table
    80000dee:	00000097          	auipc	ra,0x0
    80000df2:	300080e7          	jalr	768(ra) # 800010ee <kvminit>
    kvminithart();   // turn on paging
    80000df6:	00000097          	auipc	ra,0x0
    80000dfa:	17a080e7          	jalr	378(ra) # 80000f70 <kvminithart>
    procinit();      // process table
    80000dfe:	00001097          	auipc	ra,0x1
    80000e02:	93a080e7          	jalr	-1734(ra) # 80001738 <procinit>
    trapinit();      // trap vectors
    80000e06:	00001097          	auipc	ra,0x1
    80000e0a:	61e080e7          	jalr	1566(ra) # 80002424 <trapinit>
    trapinithart();  // install kernel trap vector
    80000e0e:	00001097          	auipc	ra,0x1
    80000e12:	63e080e7          	jalr	1598(ra) # 8000244c <trapinithart>
    plicinit();      // set up interrupt controller
    80000e16:	00005097          	auipc	ra,0x5
    80000e1a:	e04080e7          	jalr	-508(ra) # 80005c1a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000e1e:	00005097          	auipc	ra,0x5
    80000e22:	e12080e7          	jalr	-494(ra) # 80005c30 <plicinithart>
    binit();         // buffer cache
    80000e26:	00002097          	auipc	ra,0x2
    80000e2a:	d2c080e7          	jalr	-724(ra) # 80002b52 <binit>
    iinit();         // inode cache
    80000e2e:	00002097          	auipc	ra,0x2
    80000e32:	3c0080e7          	jalr	960(ra) # 800031ee <iinit>
    fileinit();      // file table
    80000e36:	00003097          	auipc	ra,0x3
    80000e3a:	59c080e7          	jalr	1436(ra) # 800043d2 <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    80000e3e:	4501                	li	a0,0
    80000e40:	00005097          	auipc	ra,0x5
    80000e44:	f24080e7          	jalr	-220(ra) # 80005d64 <virtio_disk_init>
    userinit();      // first user process
    80000e48:	00001097          	auipc	ra,0x1
    80000e4c:	c5c080e7          	jalr	-932(ra) # 80001aa4 <userinit>
    __sync_synchronize();
    80000e50:	0ff0000f          	fence
    started = 1;
    80000e54:	4785                	li	a5,1
    80000e56:	00028717          	auipc	a4,0x28
    80000e5a:	1af72d23          	sw	a5,442(a4) # 80029010 <started>
    80000e5e:	b781                	j	80000d9e <main+0x56>

0000000080000e60 <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000e60:	7139                	addi	sp,sp,-64
    80000e62:	fc06                	sd	ra,56(sp)
    80000e64:	f822                	sd	s0,48(sp)
    80000e66:	f426                	sd	s1,40(sp)
    80000e68:	f04a                	sd	s2,32(sp)
    80000e6a:	ec4e                	sd	s3,24(sp)
    80000e6c:	e852                	sd	s4,16(sp)
    80000e6e:	e456                	sd	s5,8(sp)
    80000e70:	e05a                	sd	s6,0(sp)
    80000e72:	0080                	addi	s0,sp,64
    80000e74:	84aa                	mv	s1,a0
    80000e76:	89ae                	mv	s3,a1
    80000e78:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000e7a:	57fd                	li	a5,-1
    80000e7c:	83e9                	srli	a5,a5,0x1a
    80000e7e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000e80:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000e82:	04b7f263          	bgeu	a5,a1,80000ec6 <walk+0x66>
    panic("walk");
    80000e86:	00006517          	auipc	a0,0x6
    80000e8a:	33250513          	addi	a0,a0,818 # 800071b8 <userret+0x128>
    80000e8e:	fffff097          	auipc	ra,0xfffff
    80000e92:	6c0080e7          	jalr	1728(ra) # 8000054e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000e96:	060a8663          	beqz	s5,80000f02 <walk+0xa2>
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	ac6080e7          	jalr	-1338(ra) # 80000960 <kalloc>
    80000ea2:	84aa                	mv	s1,a0
    80000ea4:	c529                	beqz	a0,80000eee <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ea6:	6605                	lui	a2,0x1
    80000ea8:	4581                	li	a1,0
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	cec080e7          	jalr	-788(ra) # 80000b96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000eb2:	00c4d793          	srli	a5,s1,0xc
    80000eb6:	07aa                	slli	a5,a5,0xa
    80000eb8:	0017e793          	ori	a5,a5,1
    80000ebc:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000ec0:	3a5d                	addiw	s4,s4,-9
    80000ec2:	036a0063          	beq	s4,s6,80000ee2 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80000ec6:	0149d933          	srl	s2,s3,s4
    80000eca:	1ff97913          	andi	s2,s2,511
    80000ece:	090e                	slli	s2,s2,0x3
    80000ed0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000ed2:	00093483          	ld	s1,0(s2)
    80000ed6:	0014f793          	andi	a5,s1,1
    80000eda:	dfd5                	beqz	a5,80000e96 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000edc:	80a9                	srli	s1,s1,0xa
    80000ede:	04b2                	slli	s1,s1,0xc
    80000ee0:	b7c5                	j	80000ec0 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000ee2:	00c9d513          	srli	a0,s3,0xc
    80000ee6:	1ff57513          	andi	a0,a0,511
    80000eea:	050e                	slli	a0,a0,0x3
    80000eec:	9526                	add	a0,a0,s1
}
    80000eee:	70e2                	ld	ra,56(sp)
    80000ef0:	7442                	ld	s0,48(sp)
    80000ef2:	74a2                	ld	s1,40(sp)
    80000ef4:	7902                	ld	s2,32(sp)
    80000ef6:	69e2                	ld	s3,24(sp)
    80000ef8:	6a42                	ld	s4,16(sp)
    80000efa:	6aa2                	ld	s5,8(sp)
    80000efc:	6b02                	ld	s6,0(sp)
    80000efe:	6121                	addi	sp,sp,64
    80000f00:	8082                	ret
        return 0;
    80000f02:	4501                	li	a0,0
    80000f04:	b7ed                	j	80000eee <walk+0x8e>

0000000080000f06 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80000f06:	7179                	addi	sp,sp,-48
    80000f08:	f406                	sd	ra,40(sp)
    80000f0a:	f022                	sd	s0,32(sp)
    80000f0c:	ec26                	sd	s1,24(sp)
    80000f0e:	e84a                	sd	s2,16(sp)
    80000f10:	e44e                	sd	s3,8(sp)
    80000f12:	e052                	sd	s4,0(sp)
    80000f14:	1800                	addi	s0,sp,48
    80000f16:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000f18:	84aa                	mv	s1,a0
    80000f1a:	6905                	lui	s2,0x1
    80000f1c:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f1e:	4985                	li	s3,1
    80000f20:	a821                	j	80000f38 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000f22:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000f24:	0532                	slli	a0,a0,0xc
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	fe0080e7          	jalr	-32(ra) # 80000f06 <freewalk>
      pagetable[i] = 0;
    80000f2e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000f32:	04a1                	addi	s1,s1,8
    80000f34:	03248163          	beq	s1,s2,80000f56 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000f38:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000f3a:	00f57793          	andi	a5,a0,15
    80000f3e:	ff3782e3          	beq	a5,s3,80000f22 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000f42:	8905                	andi	a0,a0,1
    80000f44:	d57d                	beqz	a0,80000f32 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000f46:	00006517          	auipc	a0,0x6
    80000f4a:	27a50513          	addi	a0,a0,634 # 800071c0 <userret+0x130>
    80000f4e:	fffff097          	auipc	ra,0xfffff
    80000f52:	600080e7          	jalr	1536(ra) # 8000054e <panic>
    }
  }
  kfree((void*)pagetable);
    80000f56:	8552                	mv	a0,s4
    80000f58:	00000097          	auipc	ra,0x0
    80000f5c:	90c080e7          	jalr	-1780(ra) # 80000864 <kfree>
}
    80000f60:	70a2                	ld	ra,40(sp)
    80000f62:	7402                	ld	s0,32(sp)
    80000f64:	64e2                	ld	s1,24(sp)
    80000f66:	6942                	ld	s2,16(sp)
    80000f68:	69a2                	ld	s3,8(sp)
    80000f6a:	6a02                	ld	s4,0(sp)
    80000f6c:	6145                	addi	sp,sp,48
    80000f6e:	8082                	ret

0000000080000f70 <kvminithart>:
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e422                	sd	s0,8(sp)
    80000f74:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f76:	00028797          	auipc	a5,0x28
    80000f7a:	0a27b783          	ld	a5,162(a5) # 80029018 <kernel_pagetable>
    80000f7e:	83b1                	srli	a5,a5,0xc
    80000f80:	577d                	li	a4,-1
    80000f82:	177e                	slli	a4,a4,0x3f
    80000f84:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f86:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8a:	12000073          	sfence.vma
}
    80000f8e:	6422                	ld	s0,8(sp)
    80000f90:	0141                	addi	sp,sp,16
    80000f92:	8082                	ret

0000000080000f94 <walkaddr>:
{
    80000f94:	1141                	addi	sp,sp,-16
    80000f96:	e406                	sd	ra,8(sp)
    80000f98:	e022                	sd	s0,0(sp)
    80000f9a:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f9c:	4601                	li	a2,0
    80000f9e:	00000097          	auipc	ra,0x0
    80000fa2:	ec2080e7          	jalr	-318(ra) # 80000e60 <walk>
  if(pte == 0)
    80000fa6:	c105                	beqz	a0,80000fc6 <walkaddr+0x32>
  if((*pte & PTE_V) == 0)
    80000fa8:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000faa:	0117f693          	andi	a3,a5,17
    80000fae:	4745                	li	a4,17
    return 0;
    80000fb0:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fb2:	00e68663          	beq	a3,a4,80000fbe <walkaddr+0x2a>
}
    80000fb6:	60a2                	ld	ra,8(sp)
    80000fb8:	6402                	ld	s0,0(sp)
    80000fba:	0141                	addi	sp,sp,16
    80000fbc:	8082                	ret
  pa = PTE2PA(*pte);
    80000fbe:	83a9                	srli	a5,a5,0xa
    80000fc0:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000fc4:	bfcd                	j	80000fb6 <walkaddr+0x22>
    return 0;
    80000fc6:	4501                	li	a0,0
    80000fc8:	b7fd                	j	80000fb6 <walkaddr+0x22>

0000000080000fca <kvmpa>:
{
    80000fca:	1101                	addi	sp,sp,-32
    80000fcc:	ec06                	sd	ra,24(sp)
    80000fce:	e822                	sd	s0,16(sp)
    80000fd0:	e426                	sd	s1,8(sp)
    80000fd2:	1000                	addi	s0,sp,32
    80000fd4:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80000fd6:	1552                	slli	a0,a0,0x34
    80000fd8:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    80000fdc:	4601                	li	a2,0
    80000fde:	00028517          	auipc	a0,0x28
    80000fe2:	03a53503          	ld	a0,58(a0) # 80029018 <kernel_pagetable>
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	e7a080e7          	jalr	-390(ra) # 80000e60 <walk>
  if(pte == 0)
    80000fee:	cd09                	beqz	a0,80001008 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    80000ff0:	6108                	ld	a0,0(a0)
    80000ff2:	00157793          	andi	a5,a0,1
    80000ff6:	c38d                	beqz	a5,80001018 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80000ff8:	8129                	srli	a0,a0,0xa
    80000ffa:	0532                	slli	a0,a0,0xc
}
    80000ffc:	9526                	add	a0,a0,s1
    80000ffe:	60e2                	ld	ra,24(sp)
    80001000:	6442                	ld	s0,16(sp)
    80001002:	64a2                	ld	s1,8(sp)
    80001004:	6105                	addi	sp,sp,32
    80001006:	8082                	ret
    panic("kvmpa");
    80001008:	00006517          	auipc	a0,0x6
    8000100c:	1c850513          	addi	a0,a0,456 # 800071d0 <userret+0x140>
    80001010:	fffff097          	auipc	ra,0xfffff
    80001014:	53e080e7          	jalr	1342(ra) # 8000054e <panic>
    panic("kvmpa");
    80001018:	00006517          	auipc	a0,0x6
    8000101c:	1b850513          	addi	a0,a0,440 # 800071d0 <userret+0x140>
    80001020:	fffff097          	auipc	ra,0xfffff
    80001024:	52e080e7          	jalr	1326(ra) # 8000054e <panic>

0000000080001028 <mappages>:
{
    80001028:	715d                	addi	sp,sp,-80
    8000102a:	e486                	sd	ra,72(sp)
    8000102c:	e0a2                	sd	s0,64(sp)
    8000102e:	fc26                	sd	s1,56(sp)
    80001030:	f84a                	sd	s2,48(sp)
    80001032:	f44e                	sd	s3,40(sp)
    80001034:	f052                	sd	s4,32(sp)
    80001036:	ec56                	sd	s5,24(sp)
    80001038:	e85a                	sd	s6,16(sp)
    8000103a:	e45e                	sd	s7,8(sp)
    8000103c:	0880                	addi	s0,sp,80
    8000103e:	8aaa                	mv	s5,a0
    80001040:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    80001042:	777d                	lui	a4,0xfffff
    80001044:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001048:	167d                	addi	a2,a2,-1
    8000104a:	00b609b3          	add	s3,a2,a1
    8000104e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80001052:	893e                	mv	s2,a5
    80001054:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001058:	6b85                	lui	s7,0x1
    8000105a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000105e:	4605                	li	a2,1
    80001060:	85ca                	mv	a1,s2
    80001062:	8556                	mv	a0,s5
    80001064:	00000097          	auipc	ra,0x0
    80001068:	dfc080e7          	jalr	-516(ra) # 80000e60 <walk>
    8000106c:	c51d                	beqz	a0,8000109a <mappages+0x72>
    if(*pte & PTE_V)
    8000106e:	611c                	ld	a5,0(a0)
    80001070:	8b85                	andi	a5,a5,1
    80001072:	ef81                	bnez	a5,8000108a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001074:	80b1                	srli	s1,s1,0xc
    80001076:	04aa                	slli	s1,s1,0xa
    80001078:	0164e4b3          	or	s1,s1,s6
    8000107c:	0014e493          	ori	s1,s1,1
    80001080:	e104                	sd	s1,0(a0)
    if(a == last)
    80001082:	03390863          	beq	s2,s3,800010b2 <mappages+0x8a>
    a += PGSIZE;
    80001086:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001088:	bfc9                	j	8000105a <mappages+0x32>
      panic("remap");
    8000108a:	00006517          	auipc	a0,0x6
    8000108e:	14e50513          	addi	a0,a0,334 # 800071d8 <userret+0x148>
    80001092:	fffff097          	auipc	ra,0xfffff
    80001096:	4bc080e7          	jalr	1212(ra) # 8000054e <panic>
      return -1;
    8000109a:	557d                	li	a0,-1
}
    8000109c:	60a6                	ld	ra,72(sp)
    8000109e:	6406                	ld	s0,64(sp)
    800010a0:	74e2                	ld	s1,56(sp)
    800010a2:	7942                	ld	s2,48(sp)
    800010a4:	79a2                	ld	s3,40(sp)
    800010a6:	7a02                	ld	s4,32(sp)
    800010a8:	6ae2                	ld	s5,24(sp)
    800010aa:	6b42                	ld	s6,16(sp)
    800010ac:	6ba2                	ld	s7,8(sp)
    800010ae:	6161                	addi	sp,sp,80
    800010b0:	8082                	ret
  return 0;
    800010b2:	4501                	li	a0,0
    800010b4:	b7e5                	j	8000109c <mappages+0x74>

00000000800010b6 <kvmmap>:
{
    800010b6:	1141                	addi	sp,sp,-16
    800010b8:	e406                	sd	ra,8(sp)
    800010ba:	e022                	sd	s0,0(sp)
    800010bc:	0800                	addi	s0,sp,16
    800010be:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800010c0:	86ae                	mv	a3,a1
    800010c2:	85aa                	mv	a1,a0
    800010c4:	00028517          	auipc	a0,0x28
    800010c8:	f5453503          	ld	a0,-172(a0) # 80029018 <kernel_pagetable>
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	f5c080e7          	jalr	-164(ra) # 80001028 <mappages>
    800010d4:	e509                	bnez	a0,800010de <kvmmap+0x28>
}
    800010d6:	60a2                	ld	ra,8(sp)
    800010d8:	6402                	ld	s0,0(sp)
    800010da:	0141                	addi	sp,sp,16
    800010dc:	8082                	ret
    panic("kvmmap");
    800010de:	00006517          	auipc	a0,0x6
    800010e2:	10250513          	addi	a0,a0,258 # 800071e0 <userret+0x150>
    800010e6:	fffff097          	auipc	ra,0xfffff
    800010ea:	468080e7          	jalr	1128(ra) # 8000054e <panic>

00000000800010ee <kvminit>:
{
    800010ee:	1101                	addi	sp,sp,-32
    800010f0:	ec06                	sd	ra,24(sp)
    800010f2:	e822                	sd	s0,16(sp)
    800010f4:	e426                	sd	s1,8(sp)
    800010f6:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    800010f8:	00000097          	auipc	ra,0x0
    800010fc:	868080e7          	jalr	-1944(ra) # 80000960 <kalloc>
    80001100:	00028797          	auipc	a5,0x28
    80001104:	f0a7bc23          	sd	a0,-232(a5) # 80029018 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001108:	6605                	lui	a2,0x1
    8000110a:	4581                	li	a1,0
    8000110c:	00000097          	auipc	ra,0x0
    80001110:	a8a080e7          	jalr	-1398(ra) # 80000b96 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001114:	4699                	li	a3,6
    80001116:	6605                	lui	a2,0x1
    80001118:	100005b7          	lui	a1,0x10000
    8000111c:	10000537          	lui	a0,0x10000
    80001120:	00000097          	auipc	ra,0x0
    80001124:	f96080e7          	jalr	-106(ra) # 800010b6 <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001128:	4699                	li	a3,6
    8000112a:	6605                	lui	a2,0x1
    8000112c:	100015b7          	lui	a1,0x10001
    80001130:	10001537          	lui	a0,0x10001
    80001134:	00000097          	auipc	ra,0x0
    80001138:	f82080e7          	jalr	-126(ra) # 800010b6 <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    8000113c:	4699                	li	a3,6
    8000113e:	6605                	lui	a2,0x1
    80001140:	100025b7          	lui	a1,0x10002
    80001144:	10002537          	lui	a0,0x10002
    80001148:	00000097          	auipc	ra,0x0
    8000114c:	f6e080e7          	jalr	-146(ra) # 800010b6 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001150:	4699                	li	a3,6
    80001152:	6641                	lui	a2,0x10
    80001154:	020005b7          	lui	a1,0x2000
    80001158:	02000537          	lui	a0,0x2000
    8000115c:	00000097          	auipc	ra,0x0
    80001160:	f5a080e7          	jalr	-166(ra) # 800010b6 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001164:	4699                	li	a3,6
    80001166:	00400637          	lui	a2,0x400
    8000116a:	0c0005b7          	lui	a1,0xc000
    8000116e:	0c000537          	lui	a0,0xc000
    80001172:	00000097          	auipc	ra,0x0
    80001176:	f44080e7          	jalr	-188(ra) # 800010b6 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000117a:	00007497          	auipc	s1,0x7
    8000117e:	e8648493          	addi	s1,s1,-378 # 80008000 <initcode>
    80001182:	46a9                	li	a3,10
    80001184:	80007617          	auipc	a2,0x80007
    80001188:	e7c60613          	addi	a2,a2,-388 # 8000 <_entry-0x7fff8000>
    8000118c:	4585                	li	a1,1
    8000118e:	05fe                	slli	a1,a1,0x1f
    80001190:	852e                	mv	a0,a1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f24080e7          	jalr	-220(ra) # 800010b6 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000119a:	4699                	li	a3,6
    8000119c:	4645                	li	a2,17
    8000119e:	066e                	slli	a2,a2,0x1b
    800011a0:	8e05                	sub	a2,a2,s1
    800011a2:	85a6                	mv	a1,s1
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f10080e7          	jalr	-240(ra) # 800010b6 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ae:	46a9                	li	a3,10
    800011b0:	6605                	lui	a2,0x1
    800011b2:	00006597          	auipc	a1,0x6
    800011b6:	e4e58593          	addi	a1,a1,-434 # 80007000 <trampoline>
    800011ba:	04000537          	lui	a0,0x4000
    800011be:	157d                	addi	a0,a0,-1
    800011c0:	0532                	slli	a0,a0,0xc
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	ef4080e7          	jalr	-268(ra) # 800010b6 <kvmmap>
}
    800011ca:	60e2                	ld	ra,24(sp)
    800011cc:	6442                	ld	s0,16(sp)
    800011ce:	64a2                	ld	s1,8(sp)
    800011d0:	6105                	addi	sp,sp,32
    800011d2:	8082                	ret

00000000800011d4 <uvmunmap>:
{
    800011d4:	715d                	addi	sp,sp,-80
    800011d6:	e486                	sd	ra,72(sp)
    800011d8:	e0a2                	sd	s0,64(sp)
    800011da:	fc26                	sd	s1,56(sp)
    800011dc:	f84a                	sd	s2,48(sp)
    800011de:	f44e                	sd	s3,40(sp)
    800011e0:	f052                	sd	s4,32(sp)
    800011e2:	ec56                	sd	s5,24(sp)
    800011e4:	e85a                	sd	s6,16(sp)
    800011e6:	e45e                	sd	s7,8(sp)
    800011e8:	0880                	addi	s0,sp,80
    800011ea:	8a2a                	mv	s4,a0
    800011ec:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800011ee:	77fd                	lui	a5,0xfffff
    800011f0:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800011f4:	167d                	addi	a2,a2,-1
    800011f6:	00b609b3          	add	s3,a2,a1
    800011fa:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    800011fe:	4b05                	li	s6,1
    a += PGSIZE;
    80001200:	6b85                	lui	s7,0x1
    80001202:	a8b1                	j	8000125e <uvmunmap+0x8a>
      panic("uvmunmap: walk");
    80001204:	00006517          	auipc	a0,0x6
    80001208:	fe450513          	addi	a0,a0,-28 # 800071e8 <userret+0x158>
    8000120c:	fffff097          	auipc	ra,0xfffff
    80001210:	342080e7          	jalr	834(ra) # 8000054e <panic>
      printf("va=%p pte=%p\n", a, *pte);
    80001214:	862a                	mv	a2,a0
    80001216:	85ca                	mv	a1,s2
    80001218:	00006517          	auipc	a0,0x6
    8000121c:	fe050513          	addi	a0,a0,-32 # 800071f8 <userret+0x168>
    80001220:	fffff097          	auipc	ra,0xfffff
    80001224:	378080e7          	jalr	888(ra) # 80000598 <printf>
      panic("uvmunmap: not mapped");
    80001228:	00006517          	auipc	a0,0x6
    8000122c:	fe050513          	addi	a0,a0,-32 # 80007208 <userret+0x178>
    80001230:	fffff097          	auipc	ra,0xfffff
    80001234:	31e080e7          	jalr	798(ra) # 8000054e <panic>
      panic("uvmunmap: not a leaf");
    80001238:	00006517          	auipc	a0,0x6
    8000123c:	fe850513          	addi	a0,a0,-24 # 80007220 <userret+0x190>
    80001240:	fffff097          	auipc	ra,0xfffff
    80001244:	30e080e7          	jalr	782(ra) # 8000054e <panic>
      pa = PTE2PA(*pte);
    80001248:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000124a:	0532                	slli	a0,a0,0xc
    8000124c:	fffff097          	auipc	ra,0xfffff
    80001250:	618080e7          	jalr	1560(ra) # 80000864 <kfree>
    *pte = 0;
    80001254:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001258:	03390763          	beq	s2,s3,80001286 <uvmunmap+0xb2>
    a += PGSIZE;
    8000125c:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125e:	4601                	li	a2,0
    80001260:	85ca                	mv	a1,s2
    80001262:	8552                	mv	a0,s4
    80001264:	00000097          	auipc	ra,0x0
    80001268:	bfc080e7          	jalr	-1028(ra) # 80000e60 <walk>
    8000126c:	84aa                	mv	s1,a0
    8000126e:	d959                	beqz	a0,80001204 <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    80001270:	6108                	ld	a0,0(a0)
    80001272:	00157793          	andi	a5,a0,1
    80001276:	dfd9                	beqz	a5,80001214 <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001278:	01f57793          	andi	a5,a0,31
    8000127c:	fb678ee3          	beq	a5,s6,80001238 <uvmunmap+0x64>
    if(do_free){
    80001280:	fc0a8ae3          	beqz	s5,80001254 <uvmunmap+0x80>
    80001284:	b7d1                	j	80001248 <uvmunmap+0x74>
}
    80001286:	60a6                	ld	ra,72(sp)
    80001288:	6406                	ld	s0,64(sp)
    8000128a:	74e2                	ld	s1,56(sp)
    8000128c:	7942                	ld	s2,48(sp)
    8000128e:	79a2                	ld	s3,40(sp)
    80001290:	7a02                	ld	s4,32(sp)
    80001292:	6ae2                	ld	s5,24(sp)
    80001294:	6b42                	ld	s6,16(sp)
    80001296:	6ba2                	ld	s7,8(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret

000000008000129c <uvmcreate>:
{
    8000129c:	1101                	addi	sp,sp,-32
    8000129e:	ec06                	sd	ra,24(sp)
    800012a0:	e822                	sd	s0,16(sp)
    800012a2:	e426                	sd	s1,8(sp)
    800012a4:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800012a6:	fffff097          	auipc	ra,0xfffff
    800012aa:	6ba080e7          	jalr	1722(ra) # 80000960 <kalloc>
  if(pagetable == 0)
    800012ae:	cd11                	beqz	a0,800012ca <uvmcreate+0x2e>
    800012b0:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800012b2:	6605                	lui	a2,0x1
    800012b4:	4581                	li	a1,0
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	8e0080e7          	jalr	-1824(ra) # 80000b96 <memset>
}
    800012be:	8526                	mv	a0,s1
    800012c0:	60e2                	ld	ra,24(sp)
    800012c2:	6442                	ld	s0,16(sp)
    800012c4:	64a2                	ld	s1,8(sp)
    800012c6:	6105                	addi	sp,sp,32
    800012c8:	8082                	ret
    panic("uvmcreate: out of memory");
    800012ca:	00006517          	auipc	a0,0x6
    800012ce:	f6e50513          	addi	a0,a0,-146 # 80007238 <userret+0x1a8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	27c080e7          	jalr	636(ra) # 8000054e <panic>

00000000800012da <uvminit>:
{
    800012da:	7179                	addi	sp,sp,-48
    800012dc:	f406                	sd	ra,40(sp)
    800012de:	f022                	sd	s0,32(sp)
    800012e0:	ec26                	sd	s1,24(sp)
    800012e2:	e84a                	sd	s2,16(sp)
    800012e4:	e44e                	sd	s3,8(sp)
    800012e6:	e052                	sd	s4,0(sp)
    800012e8:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800012ea:	6785                	lui	a5,0x1
    800012ec:	04f67863          	bgeu	a2,a5,8000133c <uvminit+0x62>
    800012f0:	8a2a                	mv	s4,a0
    800012f2:	89ae                	mv	s3,a1
    800012f4:	84b2                	mv	s1,a2
  mem = kalloc();
    800012f6:	fffff097          	auipc	ra,0xfffff
    800012fa:	66a080e7          	jalr	1642(ra) # 80000960 <kalloc>
    800012fe:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001300:	6605                	lui	a2,0x1
    80001302:	4581                	li	a1,0
    80001304:	00000097          	auipc	ra,0x0
    80001308:	892080e7          	jalr	-1902(ra) # 80000b96 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000130c:	4779                	li	a4,30
    8000130e:	86ca                	mv	a3,s2
    80001310:	6605                	lui	a2,0x1
    80001312:	4581                	li	a1,0
    80001314:	8552                	mv	a0,s4
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	d12080e7          	jalr	-750(ra) # 80001028 <mappages>
  memmove(mem, src, sz);
    8000131e:	8626                	mv	a2,s1
    80001320:	85ce                	mv	a1,s3
    80001322:	854a                	mv	a0,s2
    80001324:	00000097          	auipc	ra,0x0
    80001328:	8d2080e7          	jalr	-1838(ra) # 80000bf6 <memmove>
}
    8000132c:	70a2                	ld	ra,40(sp)
    8000132e:	7402                	ld	s0,32(sp)
    80001330:	64e2                	ld	s1,24(sp)
    80001332:	6942                	ld	s2,16(sp)
    80001334:	69a2                	ld	s3,8(sp)
    80001336:	6a02                	ld	s4,0(sp)
    80001338:	6145                	addi	sp,sp,48
    8000133a:	8082                	ret
    panic("inituvm: more than a page");
    8000133c:	00006517          	auipc	a0,0x6
    80001340:	f1c50513          	addi	a0,a0,-228 # 80007258 <userret+0x1c8>
    80001344:	fffff097          	auipc	ra,0xfffff
    80001348:	20a080e7          	jalr	522(ra) # 8000054e <panic>

000000008000134c <uvmdealloc>:
{
    8000134c:	87aa                	mv	a5,a0
    8000134e:	852e                	mv	a0,a1
  if(newsz >= oldsz)
    80001350:	00b66363          	bltu	a2,a1,80001356 <uvmdealloc+0xa>
}
    80001354:	8082                	ret
{
    80001356:	1101                	addi	sp,sp,-32
    80001358:	ec06                	sd	ra,24(sp)
    8000135a:	e822                	sd	s0,16(sp)
    8000135c:	e426                	sd	s1,8(sp)
    8000135e:	1000                	addi	s0,sp,32
    80001360:	84b2                	mv	s1,a2
  uvmunmap(pagetable, newsz, oldsz - newsz, 1);
    80001362:	4685                	li	a3,1
    80001364:	40c58633          	sub	a2,a1,a2
    80001368:	85a6                	mv	a1,s1
    8000136a:	853e                	mv	a0,a5
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	e68080e7          	jalr	-408(ra) # 800011d4 <uvmunmap>
  return newsz;
    80001374:	8526                	mv	a0,s1
}
    80001376:	60e2                	ld	ra,24(sp)
    80001378:	6442                	ld	s0,16(sp)
    8000137a:	64a2                	ld	s1,8(sp)
    8000137c:	6105                	addi	sp,sp,32
    8000137e:	8082                	ret

0000000080001380 <uvmalloc>:
  if(newsz < oldsz)
    80001380:	0ab66163          	bltu	a2,a1,80001422 <uvmalloc+0xa2>
{
    80001384:	7139                	addi	sp,sp,-64
    80001386:	fc06                	sd	ra,56(sp)
    80001388:	f822                	sd	s0,48(sp)
    8000138a:	f426                	sd	s1,40(sp)
    8000138c:	f04a                	sd	s2,32(sp)
    8000138e:	ec4e                	sd	s3,24(sp)
    80001390:	e852                	sd	s4,16(sp)
    80001392:	e456                	sd	s5,8(sp)
    80001394:	0080                	addi	s0,sp,64
    80001396:	8aaa                	mv	s5,a0
    80001398:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000139a:	6985                	lui	s3,0x1
    8000139c:	19fd                	addi	s3,s3,-1
    8000139e:	95ce                	add	a1,a1,s3
    800013a0:	79fd                	lui	s3,0xfffff
    800013a2:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800013a6:	08c9f063          	bgeu	s3,a2,80001426 <uvmalloc+0xa6>
  a = oldsz;
    800013aa:	894e                	mv	s2,s3
    mem = kalloc();
    800013ac:	fffff097          	auipc	ra,0xfffff
    800013b0:	5b4080e7          	jalr	1460(ra) # 80000960 <kalloc>
    800013b4:	84aa                	mv	s1,a0
    if(mem == 0){
    800013b6:	c51d                	beqz	a0,800013e4 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013b8:	6605                	lui	a2,0x1
    800013ba:	4581                	li	a1,0
    800013bc:	fffff097          	auipc	ra,0xfffff
    800013c0:	7da080e7          	jalr	2010(ra) # 80000b96 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800013c4:	4779                	li	a4,30
    800013c6:	86a6                	mv	a3,s1
    800013c8:	6605                	lui	a2,0x1
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	00000097          	auipc	ra,0x0
    800013d2:	c5a080e7          	jalr	-934(ra) # 80001028 <mappages>
    800013d6:	e905                	bnez	a0,80001406 <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800013d8:	6785                	lui	a5,0x1
    800013da:	993e                	add	s2,s2,a5
    800013dc:	fd4968e3          	bltu	s2,s4,800013ac <uvmalloc+0x2c>
  return newsz;
    800013e0:	8552                	mv	a0,s4
    800013e2:	a809                	j	800013f4 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800013e4:	864e                	mv	a2,s3
    800013e6:	85ca                	mv	a1,s2
    800013e8:	8556                	mv	a0,s5
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	f62080e7          	jalr	-158(ra) # 8000134c <uvmdealloc>
      return 0;
    800013f2:	4501                	li	a0,0
}
    800013f4:	70e2                	ld	ra,56(sp)
    800013f6:	7442                	ld	s0,48(sp)
    800013f8:	74a2                	ld	s1,40(sp)
    800013fa:	7902                	ld	s2,32(sp)
    800013fc:	69e2                	ld	s3,24(sp)
    800013fe:	6a42                	ld	s4,16(sp)
    80001400:	6aa2                	ld	s5,8(sp)
    80001402:	6121                	addi	sp,sp,64
    80001404:	8082                	ret
      kfree(mem);
    80001406:	8526                	mv	a0,s1
    80001408:	fffff097          	auipc	ra,0xfffff
    8000140c:	45c080e7          	jalr	1116(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001410:	864e                	mv	a2,s3
    80001412:	85ca                	mv	a1,s2
    80001414:	8556                	mv	a0,s5
    80001416:	00000097          	auipc	ra,0x0
    8000141a:	f36080e7          	jalr	-202(ra) # 8000134c <uvmdealloc>
      return 0;
    8000141e:	4501                	li	a0,0
    80001420:	bfd1                	j	800013f4 <uvmalloc+0x74>
    return oldsz;
    80001422:	852e                	mv	a0,a1
}
    80001424:	8082                	ret
  return newsz;
    80001426:	8532                	mv	a0,a2
    80001428:	b7f1                	j	800013f4 <uvmalloc+0x74>

000000008000142a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000142a:	1101                	addi	sp,sp,-32
    8000142c:	ec06                	sd	ra,24(sp)
    8000142e:	e822                	sd	s0,16(sp)
    80001430:	e426                	sd	s1,8(sp)
    80001432:	1000                	addi	s0,sp,32
    80001434:	84aa                	mv	s1,a0
    80001436:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001438:	4685                	li	a3,1
    8000143a:	4581                	li	a1,0
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	d98080e7          	jalr	-616(ra) # 800011d4 <uvmunmap>
  freewalk(pagetable);
    80001444:	8526                	mv	a0,s1
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	ac0080e7          	jalr	-1344(ra) # 80000f06 <freewalk>
}
    8000144e:	60e2                	ld	ra,24(sp)
    80001450:	6442                	ld	s0,16(sp)
    80001452:	64a2                	ld	s1,8(sp)
    80001454:	6105                	addi	sp,sp,32
    80001456:	8082                	ret

0000000080001458 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001458:	c671                	beqz	a2,80001524 <uvmcopy+0xcc>
{
    8000145a:	715d                	addi	sp,sp,-80
    8000145c:	e486                	sd	ra,72(sp)
    8000145e:	e0a2                	sd	s0,64(sp)
    80001460:	fc26                	sd	s1,56(sp)
    80001462:	f84a                	sd	s2,48(sp)
    80001464:	f44e                	sd	s3,40(sp)
    80001466:	f052                	sd	s4,32(sp)
    80001468:	ec56                	sd	s5,24(sp)
    8000146a:	e85a                	sd	s6,16(sp)
    8000146c:	e45e                	sd	s7,8(sp)
    8000146e:	0880                	addi	s0,sp,80
    80001470:	8b2a                	mv	s6,a0
    80001472:	8aae                	mv	s5,a1
    80001474:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001476:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001478:	4601                	li	a2,0
    8000147a:	85ce                	mv	a1,s3
    8000147c:	855a                	mv	a0,s6
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	9e2080e7          	jalr	-1566(ra) # 80000e60 <walk>
    80001486:	c531                	beqz	a0,800014d2 <uvmcopy+0x7a>
      panic("copyuvm: pte should exist");
    if((*pte & PTE_V) == 0)
    80001488:	6118                	ld	a4,0(a0)
    8000148a:	00177793          	andi	a5,a4,1
    8000148e:	cbb1                	beqz	a5,800014e2 <uvmcopy+0x8a>
      panic("copyuvm: page not present");
    pa = PTE2PA(*pte);
    80001490:	00a75593          	srli	a1,a4,0xa
    80001494:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001498:	01f77493          	andi	s1,a4,31
    if((mem = kalloc()) == 0)
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	4c4080e7          	jalr	1220(ra) # 80000960 <kalloc>
    800014a4:	892a                	mv	s2,a0
    800014a6:	c939                	beqz	a0,800014fc <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014a8:	6605                	lui	a2,0x1
    800014aa:	85de                	mv	a1,s7
    800014ac:	fffff097          	auipc	ra,0xfffff
    800014b0:	74a080e7          	jalr	1866(ra) # 80000bf6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014b4:	8726                	mv	a4,s1
    800014b6:	86ca                	mv	a3,s2
    800014b8:	6605                	lui	a2,0x1
    800014ba:	85ce                	mv	a1,s3
    800014bc:	8556                	mv	a0,s5
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	b6a080e7          	jalr	-1174(ra) # 80001028 <mappages>
    800014c6:	e515                	bnez	a0,800014f2 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800014c8:	6785                	lui	a5,0x1
    800014ca:	99be                	add	s3,s3,a5
    800014cc:	fb49e6e3          	bltu	s3,s4,80001478 <uvmcopy+0x20>
    800014d0:	a83d                	j	8000150e <uvmcopy+0xb6>
      panic("copyuvm: pte should exist");
    800014d2:	00006517          	auipc	a0,0x6
    800014d6:	da650513          	addi	a0,a0,-602 # 80007278 <userret+0x1e8>
    800014da:	fffff097          	auipc	ra,0xfffff
    800014de:	074080e7          	jalr	116(ra) # 8000054e <panic>
      panic("copyuvm: page not present");
    800014e2:	00006517          	auipc	a0,0x6
    800014e6:	db650513          	addi	a0,a0,-586 # 80007298 <userret+0x208>
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	064080e7          	jalr	100(ra) # 8000054e <panic>
      kfree(mem);
    800014f2:	854a                	mv	a0,s2
    800014f4:	fffff097          	auipc	ra,0xfffff
    800014f8:	370080e7          	jalr	880(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    800014fc:	4685                	li	a3,1
    800014fe:	864e                	mv	a2,s3
    80001500:	4581                	li	a1,0
    80001502:	8556                	mv	a0,s5
    80001504:	00000097          	auipc	ra,0x0
    80001508:	cd0080e7          	jalr	-816(ra) # 800011d4 <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	00000097          	auipc	ra,0x0
    80001536:	92e080e7          	jalr	-1746(ra) # 80000e60 <walk>
  if(pte == 0)
    8000153a:	c901                	beqz	a0,8000154a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000153c:	611c                	ld	a5,0(a0)
    8000153e:	9bbd                	andi	a5,a5,-17
    80001540:	e11c                	sd	a5,0(a0)
}
    80001542:	60a2                	ld	ra,8(sp)
    80001544:	6402                	ld	s0,0(sp)
    80001546:	0141                	addi	sp,sp,16
    80001548:	8082                	ret
    panic("uvmclear");
    8000154a:	00006517          	auipc	a0,0x6
    8000154e:	d6e50513          	addi	a0,a0,-658 # 800072b8 <userret+0x228>
    80001552:	fffff097          	auipc	ra,0xfffff
    80001556:	ffc080e7          	jalr	-4(ra) # 8000054e <panic>

000000008000155a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000155a:	cab5                	beqz	a3,800015ce <copyout+0x74>
{
    8000155c:	715d                	addi	sp,sp,-80
    8000155e:	e486                	sd	ra,72(sp)
    80001560:	e0a2                	sd	s0,64(sp)
    80001562:	fc26                	sd	s1,56(sp)
    80001564:	f84a                	sd	s2,48(sp)
    80001566:	f44e                	sd	s3,40(sp)
    80001568:	f052                	sd	s4,32(sp)
    8000156a:	ec56                	sd	s5,24(sp)
    8000156c:	e85a                	sd	s6,16(sp)
    8000156e:	e45e                	sd	s7,8(sp)
    80001570:	e062                	sd	s8,0(sp)
    80001572:	0880                	addi	s0,sp,80
    80001574:	8baa                	mv	s7,a0
    80001576:	8c2e                	mv	s8,a1
    80001578:	8a32                	mv	s4,a2
    8000157a:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(dstva);
    8000157c:	00100b37          	lui	s6,0x100
    80001580:	1b7d                	addi	s6,s6,-1
    80001582:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001584:	6a85                	lui	s5,0x1
    80001586:	a015                	j	800015aa <copyout+0x50>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001588:	9562                	add	a0,a0,s8
    8000158a:	0004861b          	sext.w	a2,s1
    8000158e:	85d2                	mv	a1,s4
    80001590:	41250533          	sub	a0,a0,s2
    80001594:	fffff097          	auipc	ra,0xfffff
    80001598:	662080e7          	jalr	1634(ra) # 80000bf6 <memmove>

    len -= n;
    8000159c:	409989b3          	sub	s3,s3,s1
    src += n;
    800015a0:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800015a2:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015a6:	02098263          	beqz	s3,800015ca <copyout+0x70>
    va0 = (uint)PGROUNDDOWN(dstva);
    800015aa:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    800015ae:	85ca                	mv	a1,s2
    800015b0:	855e                	mv	a0,s7
    800015b2:	00000097          	auipc	ra,0x0
    800015b6:	9e2080e7          	jalr	-1566(ra) # 80000f94 <walkaddr>
    if(pa0 == 0)
    800015ba:	cd01                	beqz	a0,800015d2 <copyout+0x78>
    n = PGSIZE - (dstva - va0);
    800015bc:	418904b3          	sub	s1,s2,s8
    800015c0:	94d6                	add	s1,s1,s5
    if(n > len)
    800015c2:	fc99f3e3          	bgeu	s3,s1,80001588 <copyout+0x2e>
    800015c6:	84ce                	mv	s1,s3
    800015c8:	b7c1                	j	80001588 <copyout+0x2e>
  }
  return 0;
    800015ca:	4501                	li	a0,0
    800015cc:	a021                	j	800015d4 <copyout+0x7a>
    800015ce:	4501                	li	a0,0
}
    800015d0:	8082                	ret
      return -1;
    800015d2:	557d                	li	a0,-1
}
    800015d4:	60a6                	ld	ra,72(sp)
    800015d6:	6406                	ld	s0,64(sp)
    800015d8:	74e2                	ld	s1,56(sp)
    800015da:	7942                	ld	s2,48(sp)
    800015dc:	79a2                	ld	s3,40(sp)
    800015de:	7a02                	ld	s4,32(sp)
    800015e0:	6ae2                	ld	s5,24(sp)
    800015e2:	6b42                	ld	s6,16(sp)
    800015e4:	6ba2                	ld	s7,8(sp)
    800015e6:	6c02                	ld	s8,0(sp)
    800015e8:	6161                	addi	sp,sp,80
    800015ea:	8082                	ret

00000000800015ec <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800015ec:	cab5                	beqz	a3,80001660 <copyin+0x74>
{
    800015ee:	715d                	addi	sp,sp,-80
    800015f0:	e486                	sd	ra,72(sp)
    800015f2:	e0a2                	sd	s0,64(sp)
    800015f4:	fc26                	sd	s1,56(sp)
    800015f6:	f84a                	sd	s2,48(sp)
    800015f8:	f44e                	sd	s3,40(sp)
    800015fa:	f052                	sd	s4,32(sp)
    800015fc:	ec56                	sd	s5,24(sp)
    800015fe:	e85a                	sd	s6,16(sp)
    80001600:	e45e                	sd	s7,8(sp)
    80001602:	e062                	sd	s8,0(sp)
    80001604:	0880                	addi	s0,sp,80
    80001606:	8baa                	mv	s7,a0
    80001608:	8a2e                	mv	s4,a1
    8000160a:	8c32                	mv	s8,a2
    8000160c:	89b6                	mv	s3,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    8000160e:	00100b37          	lui	s6,0x100
    80001612:	1b7d                	addi	s6,s6,-1
    80001614:	0b32                	slli	s6,s6,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001616:	6a85                	lui	s5,0x1
    80001618:	a015                	j	8000163c <copyin+0x50>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000161a:	9562                	add	a0,a0,s8
    8000161c:	0004861b          	sext.w	a2,s1
    80001620:	412505b3          	sub	a1,a0,s2
    80001624:	8552                	mv	a0,s4
    80001626:	fffff097          	auipc	ra,0xfffff
    8000162a:	5d0080e7          	jalr	1488(ra) # 80000bf6 <memmove>

    len -= n;
    8000162e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001632:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001634:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001638:	02098263          	beqz	s3,8000165c <copyin+0x70>
    va0 = (uint)PGROUNDDOWN(srcva);
    8000163c:	016c7933          	and	s2,s8,s6
    pa0 = walkaddr(pagetable, va0);
    80001640:	85ca                	mv	a1,s2
    80001642:	855e                	mv	a0,s7
    80001644:	00000097          	auipc	ra,0x0
    80001648:	950080e7          	jalr	-1712(ra) # 80000f94 <walkaddr>
    if(pa0 == 0)
    8000164c:	cd01                	beqz	a0,80001664 <copyin+0x78>
    n = PGSIZE - (srcva - va0);
    8000164e:	418904b3          	sub	s1,s2,s8
    80001652:	94d6                	add	s1,s1,s5
    if(n > len)
    80001654:	fc99f3e3          	bgeu	s3,s1,8000161a <copyin+0x2e>
    80001658:	84ce                	mv	s1,s3
    8000165a:	b7c1                	j	8000161a <copyin+0x2e>
  }
  return 0;
    8000165c:	4501                	li	a0,0
    8000165e:	a021                	j	80001666 <copyin+0x7a>
    80001660:	4501                	li	a0,0
}
    80001662:	8082                	ret
      return -1;
    80001664:	557d                	li	a0,-1
}
    80001666:	60a6                	ld	ra,72(sp)
    80001668:	6406                	ld	s0,64(sp)
    8000166a:	74e2                	ld	s1,56(sp)
    8000166c:	7942                	ld	s2,48(sp)
    8000166e:	79a2                	ld	s3,40(sp)
    80001670:	7a02                	ld	s4,32(sp)
    80001672:	6ae2                	ld	s5,24(sp)
    80001674:	6b42                	ld	s6,16(sp)
    80001676:	6ba2                	ld	s7,8(sp)
    80001678:	6c02                	ld	s8,0(sp)
    8000167a:	6161                	addi	sp,sp,80
    8000167c:	8082                	ret

000000008000167e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000167e:	c6dd                	beqz	a3,8000172c <copyinstr+0xae>
{
    80001680:	715d                	addi	sp,sp,-80
    80001682:	e486                	sd	ra,72(sp)
    80001684:	e0a2                	sd	s0,64(sp)
    80001686:	fc26                	sd	s1,56(sp)
    80001688:	f84a                	sd	s2,48(sp)
    8000168a:	f44e                	sd	s3,40(sp)
    8000168c:	f052                	sd	s4,32(sp)
    8000168e:	ec56                	sd	s5,24(sp)
    80001690:	e85a                	sd	s6,16(sp)
    80001692:	e45e                	sd	s7,8(sp)
    80001694:	0880                	addi	s0,sp,80
    80001696:	8aaa                	mv	s5,a0
    80001698:	8b2e                	mv	s6,a1
    8000169a:	8bb2                	mv	s7,a2
    8000169c:	84b6                	mv	s1,a3
    va0 = (uint)PGROUNDDOWN(srcva);
    8000169e:	00100a37          	lui	s4,0x100
    800016a2:	1a7d                	addi	s4,s4,-1
    800016a4:	0a32                	slli	s4,s4,0xc
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016a6:	6985                	lui	s3,0x1
    800016a8:	a035                	j	800016d4 <copyinstr+0x56>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016aa:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016ae:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016b0:	0017b793          	seqz	a5,a5
    800016b4:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016b8:	60a6                	ld	ra,72(sp)
    800016ba:	6406                	ld	s0,64(sp)
    800016bc:	74e2                	ld	s1,56(sp)
    800016be:	7942                	ld	s2,48(sp)
    800016c0:	79a2                	ld	s3,40(sp)
    800016c2:	7a02                	ld	s4,32(sp)
    800016c4:	6ae2                	ld	s5,24(sp)
    800016c6:	6b42                	ld	s6,16(sp)
    800016c8:	6ba2                	ld	s7,8(sp)
    800016ca:	6161                	addi	sp,sp,80
    800016cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800016ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800016d2:	c8a9                	beqz	s1,80001724 <copyinstr+0xa6>
    va0 = (uint)PGROUNDDOWN(srcva);
    800016d4:	014bf933          	and	s2,s7,s4
    pa0 = walkaddr(pagetable, va0);
    800016d8:	85ca                	mv	a1,s2
    800016da:	8556                	mv	a0,s5
    800016dc:	00000097          	auipc	ra,0x0
    800016e0:	8b8080e7          	jalr	-1864(ra) # 80000f94 <walkaddr>
    if(pa0 == 0)
    800016e4:	c131                	beqz	a0,80001728 <copyinstr+0xaa>
    n = PGSIZE - (srcva - va0);
    800016e6:	41790833          	sub	a6,s2,s7
    800016ea:	984e                	add	a6,a6,s3
    if(n > max)
    800016ec:	0104f363          	bgeu	s1,a6,800016f2 <copyinstr+0x74>
    800016f0:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800016f2:	955e                	add	a0,a0,s7
    800016f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016f8:	fc080be3          	beqz	a6,800016ce <copyinstr+0x50>
    800016fc:	985a                	add	a6,a6,s6
    800016fe:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001700:	41650633          	sub	a2,a0,s6
    80001704:	14fd                	addi	s1,s1,-1
    80001706:	9b26                	add	s6,s6,s1
    80001708:	00f60733          	add	a4,a2,a5
    8000170c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <ticks+0xffffffff7ffd5fd8>
    80001710:	df49                	beqz	a4,800016aa <copyinstr+0x2c>
        *dst = *p;
    80001712:	00e78023          	sb	a4,0(a5)
      --max;
    80001716:	40fb04b3          	sub	s1,s6,a5
      dst++;
    8000171a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000171c:	ff0796e3          	bne	a5,a6,80001708 <copyinstr+0x8a>
      dst++;
    80001720:	8b42                	mv	s6,a6
    80001722:	b775                	j	800016ce <copyinstr+0x50>
    80001724:	4781                	li	a5,0
    80001726:	b769                	j	800016b0 <copyinstr+0x32>
      return -1;
    80001728:	557d                	li	a0,-1
    8000172a:	b779                	j	800016b8 <copyinstr+0x3a>
  int got_null = 0;
    8000172c:	4781                	li	a5,0
  if(got_null){
    8000172e:	0017b793          	seqz	a5,a5
    80001732:	40f00533          	neg	a0,a5
}
    80001736:	8082                	ret

0000000080001738 <procinit>:

extern char trampoline[]; // trampoline.S

void
procinit(void)
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	0880                	addi	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000174e:	00006597          	auipc	a1,0x6
    80001752:	b7a58593          	addi	a1,a1,-1158 # 800072c8 <userret+0x238>
    80001756:	00010517          	auipc	a0,0x10
    8000175a:	19250513          	addi	a0,a0,402 # 800118e8 <pid_lock>
    8000175e:	fffff097          	auipc	ra,0xfffff
    80001762:	262080e7          	jalr	610(ra) # 800009c0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001766:	00010917          	auipc	s2,0x10
    8000176a:	59a90913          	addi	s2,s2,1434 # 80011d00 <proc>
      initlock(&p->lock, "proc");
    8000176e:	00006b97          	auipc	s7,0x6
    80001772:	b62b8b93          	addi	s7,s7,-1182 # 800072d0 <userret+0x240>
      // Map it high in memory, followed by an invalid
      // guard page.
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      uint64 va = KSTACK((int) (p - proc));
    80001776:	8b4a                	mv	s6,s2
    80001778:	00006a97          	auipc	s5,0x6
    8000177c:	250a8a93          	addi	s5,s5,592 # 800079c8 <syscalls+0xc0>
    80001780:	040009b7          	lui	s3,0x4000
    80001784:	19fd                	addi	s3,s3,-1
    80001786:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001788:	00016a17          	auipc	s4,0x16
    8000178c:	d78a0a13          	addi	s4,s4,-648 # 80017500 <tickslock>
      initlock(&p->lock, "proc");
    80001790:	85de                	mv	a1,s7
    80001792:	854a                	mv	a0,s2
    80001794:	fffff097          	auipc	ra,0xfffff
    80001798:	22c080e7          	jalr	556(ra) # 800009c0 <initlock>
      char *pa = kalloc();
    8000179c:	fffff097          	auipc	ra,0xfffff
    800017a0:	1c4080e7          	jalr	452(ra) # 80000960 <kalloc>
    800017a4:	85aa                	mv	a1,a0
      if(pa == 0)
    800017a6:	c929                	beqz	a0,800017f8 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    800017a8:	416904b3          	sub	s1,s2,s6
    800017ac:	8495                	srai	s1,s1,0x5
    800017ae:	000ab783          	ld	a5,0(s5)
    800017b2:	02f484b3          	mul	s1,s1,a5
    800017b6:	2485                	addiw	s1,s1,1
    800017b8:	00d4949b          	slliw	s1,s1,0xd
    800017bc:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c0:	4699                	li	a3,6
    800017c2:	6605                	lui	a2,0x1
    800017c4:	8526                	mv	a0,s1
    800017c6:	00000097          	auipc	ra,0x0
    800017ca:	8f0080e7          	jalr	-1808(ra) # 800010b6 <kvmmap>
      p->kstack = va;
    800017ce:	02993c23          	sd	s1,56(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d2:	16090913          	addi	s2,s2,352
    800017d6:	fb491de3          	bne	s2,s4,80001790 <procinit+0x58>
  }
  kvminithart();
    800017da:	fffff097          	auipc	ra,0xfffff
    800017de:	796080e7          	jalr	1942(ra) # 80000f70 <kvminithart>
}
    800017e2:	60a6                	ld	ra,72(sp)
    800017e4:	6406                	ld	s0,64(sp)
    800017e6:	74e2                	ld	s1,56(sp)
    800017e8:	7942                	ld	s2,48(sp)
    800017ea:	79a2                	ld	s3,40(sp)
    800017ec:	7a02                	ld	s4,32(sp)
    800017ee:	6ae2                	ld	s5,24(sp)
    800017f0:	6b42                	ld	s6,16(sp)
    800017f2:	6ba2                	ld	s7,8(sp)
    800017f4:	6161                	addi	sp,sp,80
    800017f6:	8082                	ret
        panic("kalloc");
    800017f8:	00006517          	auipc	a0,0x6
    800017fc:	ae050513          	addi	a0,a0,-1312 # 800072d8 <userret+0x248>
    80001800:	fffff097          	auipc	ra,0xfffff
    80001804:	d4e080e7          	jalr	-690(ra) # 8000054e <panic>

0000000080001808 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001808:	1141                	addi	sp,sp,-16
    8000180a:	e422                	sd	s0,8(sp)
    8000180c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000180e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001810:	2501                	sext.w	a0,a0
    80001812:	6422                	ld	s0,8(sp)
    80001814:	0141                	addi	sp,sp,16
    80001816:	8082                	ret

0000000080001818 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001818:	1141                	addi	sp,sp,-16
    8000181a:	e422                	sd	s0,8(sp)
    8000181c:	0800                	addi	s0,sp,16
    8000181e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001820:	2781                	sext.w	a5,a5
    80001822:	079e                	slli	a5,a5,0x7
  return c;
}
    80001824:	00010517          	auipc	a0,0x10
    80001828:	0dc50513          	addi	a0,a0,220 # 80011900 <cpus>
    8000182c:	953e                	add	a0,a0,a5
    8000182e:	6422                	ld	s0,8(sp)
    80001830:	0141                	addi	sp,sp,16
    80001832:	8082                	ret

0000000080001834 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001834:	1101                	addi	sp,sp,-32
    80001836:	ec06                	sd	ra,24(sp)
    80001838:	e822                	sd	s0,16(sp)
    8000183a:	e426                	sd	s1,8(sp)
    8000183c:	1000                	addi	s0,sp,32
  push_off();
    8000183e:	fffff097          	auipc	ra,0xfffff
    80001842:	198080e7          	jalr	408(ra) # 800009d6 <push_off>
    80001846:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001848:	2781                	sext.w	a5,a5
    8000184a:	079e                	slli	a5,a5,0x7
    8000184c:	00010717          	auipc	a4,0x10
    80001850:	09c70713          	addi	a4,a4,156 # 800118e8 <pid_lock>
    80001854:	97ba                	add	a5,a5,a4
    80001856:	6f84                	ld	s1,24(a5)
  pop_off();
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	1ca080e7          	jalr	458(ra) # 80000a22 <pop_off>
  return p;
}
    80001860:	8526                	mv	a0,s1
    80001862:	60e2                	ld	ra,24(sp)
    80001864:	6442                	ld	s0,16(sp)
    80001866:	64a2                	ld	s1,8(sp)
    80001868:	6105                	addi	sp,sp,32
    8000186a:	8082                	ret

000000008000186c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000186c:	1141                	addi	sp,sp,-16
    8000186e:	e406                	sd	ra,8(sp)
    80001870:	e022                	sd	s0,0(sp)
    80001872:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001874:	00000097          	auipc	ra,0x0
    80001878:	fc0080e7          	jalr	-64(ra) # 80001834 <myproc>
    8000187c:	fffff097          	auipc	ra,0xfffff
    80001880:	2be080e7          	jalr	702(ra) # 80000b3a <release>

  if (first) {
    80001884:	00006797          	auipc	a5,0x6
    80001888:	7b07a783          	lw	a5,1968(a5) # 80008034 <first.1719>
    8000188c:	eb89                	bnez	a5,8000189e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(minor(ROOTDEV));
  }

  usertrapret();
    8000188e:	00001097          	auipc	ra,0x1
    80001892:	bd6080e7          	jalr	-1066(ra) # 80002464 <usertrapret>
}
    80001896:	60a2                	ld	ra,8(sp)
    80001898:	6402                	ld	s0,0(sp)
    8000189a:	0141                	addi	sp,sp,16
    8000189c:	8082                	ret
    first = 0;
    8000189e:	00006797          	auipc	a5,0x6
    800018a2:	7807ab23          	sw	zero,1942(a5) # 80008034 <first.1719>
    fsinit(minor(ROOTDEV));
    800018a6:	4501                	li	a0,0
    800018a8:	00002097          	auipc	ra,0x2
    800018ac:	8c6080e7          	jalr	-1850(ra) # 8000316e <fsinit>
    800018b0:	bff9                	j	8000188e <forkret+0x22>

00000000800018b2 <allocpid>:
allocpid() {
    800018b2:	1101                	addi	sp,sp,-32
    800018b4:	ec06                	sd	ra,24(sp)
    800018b6:	e822                	sd	s0,16(sp)
    800018b8:	e426                	sd	s1,8(sp)
    800018ba:	e04a                	sd	s2,0(sp)
    800018bc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    800018be:	00010917          	auipc	s2,0x10
    800018c2:	02a90913          	addi	s2,s2,42 # 800118e8 <pid_lock>
    800018c6:	854a                	mv	a0,s2
    800018c8:	fffff097          	auipc	ra,0xfffff
    800018cc:	20a080e7          	jalr	522(ra) # 80000ad2 <acquire>
  pid = nextpid;
    800018d0:	00006797          	auipc	a5,0x6
    800018d4:	76878793          	addi	a5,a5,1896 # 80008038 <nextpid>
    800018d8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800018da:	0014871b          	addiw	a4,s1,1
    800018de:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800018e0:	854a                	mv	a0,s2
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	258080e7          	jalr	600(ra) # 80000b3a <release>
}
    800018ea:	8526                	mv	a0,s1
    800018ec:	60e2                	ld	ra,24(sp)
    800018ee:	6442                	ld	s0,16(sp)
    800018f0:	64a2                	ld	s1,8(sp)
    800018f2:	6902                	ld	s2,0(sp)
    800018f4:	6105                	addi	sp,sp,32
    800018f6:	8082                	ret

00000000800018f8 <proc_pagetable>:
{
    800018f8:	1101                	addi	sp,sp,-32
    800018fa:	ec06                	sd	ra,24(sp)
    800018fc:	e822                	sd	s0,16(sp)
    800018fe:	e426                	sd	s1,8(sp)
    80001900:	e04a                	sd	s2,0(sp)
    80001902:	1000                	addi	s0,sp,32
    80001904:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001906:	00000097          	auipc	ra,0x0
    8000190a:	996080e7          	jalr	-1642(ra) # 8000129c <uvmcreate>
    8000190e:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001910:	4729                	li	a4,10
    80001912:	00005697          	auipc	a3,0x5
    80001916:	6ee68693          	addi	a3,a3,1774 # 80007000 <trampoline>
    8000191a:	6605                	lui	a2,0x1
    8000191c:	040005b7          	lui	a1,0x4000
    80001920:	15fd                	addi	a1,a1,-1
    80001922:	05b2                	slli	a1,a1,0xc
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	704080e7          	jalr	1796(ra) # 80001028 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    8000192c:	4719                	li	a4,6
    8000192e:	05093683          	ld	a3,80(s2)
    80001932:	6605                	lui	a2,0x1
    80001934:	020005b7          	lui	a1,0x2000
    80001938:	15fd                	addi	a1,a1,-1
    8000193a:	05b6                	slli	a1,a1,0xd
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	6ea080e7          	jalr	1770(ra) # 80001028 <mappages>
}
    80001946:	8526                	mv	a0,s1
    80001948:	60e2                	ld	ra,24(sp)
    8000194a:	6442                	ld	s0,16(sp)
    8000194c:	64a2                	ld	s1,8(sp)
    8000194e:	6902                	ld	s2,0(sp)
    80001950:	6105                	addi	sp,sp,32
    80001952:	8082                	ret

0000000080001954 <allocproc>:
{
    80001954:	1101                	addi	sp,sp,-32
    80001956:	ec06                	sd	ra,24(sp)
    80001958:	e822                	sd	s0,16(sp)
    8000195a:	e426                	sd	s1,8(sp)
    8000195c:	e04a                	sd	s2,0(sp)
    8000195e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001960:	00010497          	auipc	s1,0x10
    80001964:	3a048493          	addi	s1,s1,928 # 80011d00 <proc>
    80001968:	00016917          	auipc	s2,0x16
    8000196c:	b9890913          	addi	s2,s2,-1128 # 80017500 <tickslock>
    acquire(&p->lock);
    80001970:	8526                	mv	a0,s1
    80001972:	fffff097          	auipc	ra,0xfffff
    80001976:	160080e7          	jalr	352(ra) # 80000ad2 <acquire>
    if(p->state == UNUSED) {
    8000197a:	4c9c                	lw	a5,24(s1)
    8000197c:	cf81                	beqz	a5,80001994 <allocproc+0x40>
      release(&p->lock);
    8000197e:	8526                	mv	a0,s1
    80001980:	fffff097          	auipc	ra,0xfffff
    80001984:	1ba080e7          	jalr	442(ra) # 80000b3a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001988:	16048493          	addi	s1,s1,352
    8000198c:	ff2492e3          	bne	s1,s2,80001970 <allocproc+0x1c>
  return 0;
    80001990:	4481                	li	s1,0
    80001992:	a0a9                	j	800019dc <allocproc+0x88>
  p->pid = allocpid();
    80001994:	00000097          	auipc	ra,0x0
    80001998:	f1e080e7          	jalr	-226(ra) # 800018b2 <allocpid>
    8000199c:	d8c8                	sw	a0,52(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    8000199e:	fffff097          	auipc	ra,0xfffff
    800019a2:	fc2080e7          	jalr	-62(ra) # 80000960 <kalloc>
    800019a6:	892a                	mv	s2,a0
    800019a8:	e8a8                	sd	a0,80(s1)
    800019aa:	c121                	beqz	a0,800019ea <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    800019ac:	8526                	mv	a0,s1
    800019ae:	00000097          	auipc	ra,0x0
    800019b2:	f4a080e7          	jalr	-182(ra) # 800018f8 <proc_pagetable>
    800019b6:	e4a8                	sd	a0,72(s1)
  memset(&p->context, 0, sizeof p->context);
    800019b8:	07000613          	li	a2,112
    800019bc:	4581                	li	a1,0
    800019be:	05848513          	addi	a0,s1,88
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	1d4080e7          	jalr	468(ra) # 80000b96 <memset>
  p->context.ra = (uint64)forkret;
    800019ca:	00000797          	auipc	a5,0x0
    800019ce:	ea278793          	addi	a5,a5,-350 # 8000186c <forkret>
    800019d2:	ecbc                	sd	a5,88(s1)
  p->context.sp = p->kstack + PGSIZE;
    800019d4:	7c9c                	ld	a5,56(s1)
    800019d6:	6705                	lui	a4,0x1
    800019d8:	97ba                	add	a5,a5,a4
    800019da:	f0bc                	sd	a5,96(s1)
}
    800019dc:	8526                	mv	a0,s1
    800019de:	60e2                	ld	ra,24(sp)
    800019e0:	6442                	ld	s0,16(sp)
    800019e2:	64a2                	ld	s1,8(sp)
    800019e4:	6902                	ld	s2,0(sp)
    800019e6:	6105                	addi	sp,sp,32
    800019e8:	8082                	ret
    release(&p->lock);
    800019ea:	8526                	mv	a0,s1
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	14e080e7          	jalr	334(ra) # 80000b3a <release>
    return 0;
    800019f4:	84ca                	mv	s1,s2
    800019f6:	b7dd                	j	800019dc <allocproc+0x88>

00000000800019f8 <proc_freepagetable>:
{
    800019f8:	1101                	addi	sp,sp,-32
    800019fa:	ec06                	sd	ra,24(sp)
    800019fc:	e822                	sd	s0,16(sp)
    800019fe:	e426                	sd	s1,8(sp)
    80001a00:	e04a                	sd	s2,0(sp)
    80001a02:	1000                	addi	s0,sp,32
    80001a04:	84aa                	mv	s1,a0
    80001a06:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001a08:	4681                	li	a3,0
    80001a0a:	6605                	lui	a2,0x1
    80001a0c:	040005b7          	lui	a1,0x4000
    80001a10:	15fd                	addi	a1,a1,-1
    80001a12:	05b2                	slli	a1,a1,0xc
    80001a14:	fffff097          	auipc	ra,0xfffff
    80001a18:	7c0080e7          	jalr	1984(ra) # 800011d4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	6605                	lui	a2,0x1
    80001a20:	020005b7          	lui	a1,0x2000
    80001a24:	15fd                	addi	a1,a1,-1
    80001a26:	05b6                	slli	a1,a1,0xd
    80001a28:	8526                	mv	a0,s1
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	7aa080e7          	jalr	1962(ra) # 800011d4 <uvmunmap>
  if(sz > 0)
    80001a32:	00091863          	bnez	s2,80001a42 <proc_freepagetable+0x4a>
}
    80001a36:	60e2                	ld	ra,24(sp)
    80001a38:	6442                	ld	s0,16(sp)
    80001a3a:	64a2                	ld	s1,8(sp)
    80001a3c:	6902                	ld	s2,0(sp)
    80001a3e:	6105                	addi	sp,sp,32
    80001a40:	8082                	ret
    uvmfree(pagetable, sz);
    80001a42:	85ca                	mv	a1,s2
    80001a44:	8526                	mv	a0,s1
    80001a46:	00000097          	auipc	ra,0x0
    80001a4a:	9e4080e7          	jalr	-1564(ra) # 8000142a <uvmfree>
}
    80001a4e:	b7e5                	j	80001a36 <proc_freepagetable+0x3e>

0000000080001a50 <freeproc>:
{
    80001a50:	1101                	addi	sp,sp,-32
    80001a52:	ec06                	sd	ra,24(sp)
    80001a54:	e822                	sd	s0,16(sp)
    80001a56:	e426                	sd	s1,8(sp)
    80001a58:	1000                	addi	s0,sp,32
    80001a5a:	84aa                	mv	s1,a0
  if(p->tf)
    80001a5c:	6928                	ld	a0,80(a0)
    80001a5e:	c509                	beqz	a0,80001a68 <freeproc+0x18>
    kfree((void*)p->tf);
    80001a60:	fffff097          	auipc	ra,0xfffff
    80001a64:	e04080e7          	jalr	-508(ra) # 80000864 <kfree>
  p->tf = 0;
    80001a68:	0404b823          	sd	zero,80(s1)
  if(p->pagetable)
    80001a6c:	64a8                	ld	a0,72(s1)
    80001a6e:	c511                	beqz	a0,80001a7a <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001a70:	60ac                	ld	a1,64(s1)
    80001a72:	00000097          	auipc	ra,0x0
    80001a76:	f86080e7          	jalr	-122(ra) # 800019f8 <proc_freepagetable>
  p->pagetable = 0;
    80001a7a:	0404b423          	sd	zero,72(s1)
  p->sz = 0;
    80001a7e:	0404b023          	sd	zero,64(s1)
  p->pid = 0;
    80001a82:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001a86:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001a8a:	14048823          	sb	zero,336(s1)
  p->chan = 0;
    80001a8e:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001a92:	0204a823          	sw	zero,48(s1)
  p->state = UNUSED;
    80001a96:	0004ac23          	sw	zero,24(s1)
}
    80001a9a:	60e2                	ld	ra,24(sp)
    80001a9c:	6442                	ld	s0,16(sp)
    80001a9e:	64a2                	ld	s1,8(sp)
    80001aa0:	6105                	addi	sp,sp,32
    80001aa2:	8082                	ret

0000000080001aa4 <userinit>:
{
    80001aa4:	1101                	addi	sp,sp,-32
    80001aa6:	ec06                	sd	ra,24(sp)
    80001aa8:	e822                	sd	s0,16(sp)
    80001aaa:	e426                	sd	s1,8(sp)
    80001aac:	1000                	addi	s0,sp,32
  p = allocproc();
    80001aae:	00000097          	auipc	ra,0x0
    80001ab2:	ea6080e7          	jalr	-346(ra) # 80001954 <allocproc>
    80001ab6:	84aa                	mv	s1,a0
  initproc = p;
    80001ab8:	00027797          	auipc	a5,0x27
    80001abc:	56a7b423          	sd	a0,1384(a5) # 80029020 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ac0:	03300613          	li	a2,51
    80001ac4:	00006597          	auipc	a1,0x6
    80001ac8:	53c58593          	addi	a1,a1,1340 # 80008000 <initcode>
    80001acc:	6528                	ld	a0,72(a0)
    80001ace:	00000097          	auipc	ra,0x0
    80001ad2:	80c080e7          	jalr	-2036(ra) # 800012da <uvminit>
  p->sz = PGSIZE;
    80001ad6:	6785                	lui	a5,0x1
    80001ad8:	e0bc                	sd	a5,64(s1)
  p->tf->epc = 0;      // user program counter
    80001ada:	68b8                	ld	a4,80(s1)
    80001adc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001ae0:	68b8                	ld	a4,80(s1)
    80001ae2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001ae4:	4641                	li	a2,16
    80001ae6:	00005597          	auipc	a1,0x5
    80001aea:	7fa58593          	addi	a1,a1,2042 # 800072e0 <userret+0x250>
    80001aee:	15048513          	addi	a0,s1,336
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	1fa080e7          	jalr	506(ra) # 80000cec <safestrcpy>
  p->cwd = namei("/");
    80001afa:	00005517          	auipc	a0,0x5
    80001afe:	7f650513          	addi	a0,a0,2038 # 800072f0 <userret+0x260>
    80001b02:	00002097          	auipc	ra,0x2
    80001b06:	070080e7          	jalr	112(ra) # 80003b72 <namei>
    80001b0a:	14a4b423          	sd	a0,328(s1)
  p->state = RUNNABLE;
    80001b0e:	4789                	li	a5,2
    80001b10:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b12:	8526                	mv	a0,s1
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	026080e7          	jalr	38(ra) # 80000b3a <release>
}
    80001b1c:	60e2                	ld	ra,24(sp)
    80001b1e:	6442                	ld	s0,16(sp)
    80001b20:	64a2                	ld	s1,8(sp)
    80001b22:	6105                	addi	sp,sp,32
    80001b24:	8082                	ret

0000000080001b26 <growproc>:
{
    80001b26:	1101                	addi	sp,sp,-32
    80001b28:	ec06                	sd	ra,24(sp)
    80001b2a:	e822                	sd	s0,16(sp)
    80001b2c:	e426                	sd	s1,8(sp)
    80001b2e:	e04a                	sd	s2,0(sp)
    80001b30:	1000                	addi	s0,sp,32
    80001b32:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001b34:	00000097          	auipc	ra,0x0
    80001b38:	d00080e7          	jalr	-768(ra) # 80001834 <myproc>
    80001b3c:	892a                	mv	s2,a0
  sz = p->sz;
    80001b3e:	612c                	ld	a1,64(a0)
    80001b40:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001b44:	00904f63          	bgtz	s1,80001b62 <growproc+0x3c>
  } else if(n < 0){
    80001b48:	0204cc63          	bltz	s1,80001b80 <growproc+0x5a>
  p->sz = sz;
    80001b4c:	1602                	slli	a2,a2,0x20
    80001b4e:	9201                	srli	a2,a2,0x20
    80001b50:	04c93023          	sd	a2,64(s2)
  return 0;
    80001b54:	4501                	li	a0,0
}
    80001b56:	60e2                	ld	ra,24(sp)
    80001b58:	6442                	ld	s0,16(sp)
    80001b5a:	64a2                	ld	s1,8(sp)
    80001b5c:	6902                	ld	s2,0(sp)
    80001b5e:	6105                	addi	sp,sp,32
    80001b60:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001b62:	9e25                	addw	a2,a2,s1
    80001b64:	1602                	slli	a2,a2,0x20
    80001b66:	9201                	srli	a2,a2,0x20
    80001b68:	1582                	slli	a1,a1,0x20
    80001b6a:	9181                	srli	a1,a1,0x20
    80001b6c:	6528                	ld	a0,72(a0)
    80001b6e:	00000097          	auipc	ra,0x0
    80001b72:	812080e7          	jalr	-2030(ra) # 80001380 <uvmalloc>
    80001b76:	0005061b          	sext.w	a2,a0
    80001b7a:	fa69                	bnez	a2,80001b4c <growproc+0x26>
      return -1;
    80001b7c:	557d                	li	a0,-1
    80001b7e:	bfe1                	j	80001b56 <growproc+0x30>
    if((sz = uvmdealloc(p->pagetable, sz, sz + n)) == 0) {
    80001b80:	9e25                	addw	a2,a2,s1
    80001b82:	1602                	slli	a2,a2,0x20
    80001b84:	9201                	srli	a2,a2,0x20
    80001b86:	1582                	slli	a1,a1,0x20
    80001b88:	9181                	srli	a1,a1,0x20
    80001b8a:	6528                	ld	a0,72(a0)
    80001b8c:	fffff097          	auipc	ra,0xfffff
    80001b90:	7c0080e7          	jalr	1984(ra) # 8000134c <uvmdealloc>
    80001b94:	0005061b          	sext.w	a2,a0
    80001b98:	fa55                	bnez	a2,80001b4c <growproc+0x26>
      return -1;
    80001b9a:	557d                	li	a0,-1
    80001b9c:	bf6d                	j	80001b56 <growproc+0x30>

0000000080001b9e <fork>:
{
    80001b9e:	7179                	addi	sp,sp,-48
    80001ba0:	f406                	sd	ra,40(sp)
    80001ba2:	f022                	sd	s0,32(sp)
    80001ba4:	ec26                	sd	s1,24(sp)
    80001ba6:	e84a                	sd	s2,16(sp)
    80001ba8:	e44e                	sd	s3,8(sp)
    80001baa:	e052                	sd	s4,0(sp)
    80001bac:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001bae:	00000097          	auipc	ra,0x0
    80001bb2:	c86080e7          	jalr	-890(ra) # 80001834 <myproc>
    80001bb6:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001bb8:	00000097          	auipc	ra,0x0
    80001bbc:	d9c080e7          	jalr	-612(ra) # 80001954 <allocproc>
    80001bc0:	c175                	beqz	a0,80001ca4 <fork+0x106>
    80001bc2:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001bc4:	04093603          	ld	a2,64(s2)
    80001bc8:	652c                	ld	a1,72(a0)
    80001bca:	04893503          	ld	a0,72(s2)
    80001bce:	00000097          	auipc	ra,0x0
    80001bd2:	88a080e7          	jalr	-1910(ra) # 80001458 <uvmcopy>
    80001bd6:	04054863          	bltz	a0,80001c26 <fork+0x88>
  np->sz = p->sz;
    80001bda:	04093783          	ld	a5,64(s2)
    80001bde:	04f9b023          	sd	a5,64(s3) # 4000040 <_entry-0x7bffffc0>
  np->parent = p;
    80001be2:	0329b023          	sd	s2,32(s3)
  *(np->tf) = *(p->tf);
    80001be6:	05093683          	ld	a3,80(s2)
    80001bea:	87b6                	mv	a5,a3
    80001bec:	0509b703          	ld	a4,80(s3)
    80001bf0:	12068693          	addi	a3,a3,288
    80001bf4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001bf8:	6788                	ld	a0,8(a5)
    80001bfa:	6b8c                	ld	a1,16(a5)
    80001bfc:	6f90                	ld	a2,24(a5)
    80001bfe:	01073023          	sd	a6,0(a4)
    80001c02:	e708                	sd	a0,8(a4)
    80001c04:	eb0c                	sd	a1,16(a4)
    80001c06:	ef10                	sd	a2,24(a4)
    80001c08:	02078793          	addi	a5,a5,32
    80001c0c:	02070713          	addi	a4,a4,32
    80001c10:	fed792e3          	bne	a5,a3,80001bf4 <fork+0x56>
  np->tf->a0 = 0;
    80001c14:	0509b783          	ld	a5,80(s3)
    80001c18:	0607b823          	sd	zero,112(a5)
    80001c1c:	0c800493          	li	s1,200
  for(i = 0; i < NOFILE; i++)
    80001c20:	14800a13          	li	s4,328
    80001c24:	a03d                	j	80001c52 <fork+0xb4>
    freeproc(np);
    80001c26:	854e                	mv	a0,s3
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	e28080e7          	jalr	-472(ra) # 80001a50 <freeproc>
    release(&np->lock);
    80001c30:	854e                	mv	a0,s3
    80001c32:	fffff097          	auipc	ra,0xfffff
    80001c36:	f08080e7          	jalr	-248(ra) # 80000b3a <release>
    return -1;
    80001c3a:	54fd                	li	s1,-1
    80001c3c:	a899                	j	80001c92 <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001c3e:	00003097          	auipc	ra,0x3
    80001c42:	826080e7          	jalr	-2010(ra) # 80004464 <filedup>
    80001c46:	009987b3          	add	a5,s3,s1
    80001c4a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001c4c:	04a1                	addi	s1,s1,8
    80001c4e:	01448763          	beq	s1,s4,80001c5c <fork+0xbe>
    if(p->ofile[i])
    80001c52:	009907b3          	add	a5,s2,s1
    80001c56:	6388                	ld	a0,0(a5)
    80001c58:	f17d                	bnez	a0,80001c3e <fork+0xa0>
    80001c5a:	bfcd                	j	80001c4c <fork+0xae>
  np->cwd = idup(p->cwd);
    80001c5c:	14893503          	ld	a0,328(s2)
    80001c60:	00001097          	auipc	ra,0x1
    80001c64:	748080e7          	jalr	1864(ra) # 800033a8 <idup>
    80001c68:	14a9b423          	sd	a0,328(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001c6c:	4641                	li	a2,16
    80001c6e:	15090593          	addi	a1,s2,336
    80001c72:	15098513          	addi	a0,s3,336
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	076080e7          	jalr	118(ra) # 80000cec <safestrcpy>
  pid = np->pid;
    80001c7e:	0349a483          	lw	s1,52(s3)
  np->state = RUNNABLE;
    80001c82:	4789                	li	a5,2
    80001c84:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001c88:	854e                	mv	a0,s3
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	eb0080e7          	jalr	-336(ra) # 80000b3a <release>
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	70a2                	ld	ra,40(sp)
    80001c96:	7402                	ld	s0,32(sp)
    80001c98:	64e2                	ld	s1,24(sp)
    80001c9a:	6942                	ld	s2,16(sp)
    80001c9c:	69a2                	ld	s3,8(sp)
    80001c9e:	6a02                	ld	s4,0(sp)
    80001ca0:	6145                	addi	sp,sp,48
    80001ca2:	8082                	ret
    return -1;
    80001ca4:	54fd                	li	s1,-1
    80001ca6:	b7f5                	j	80001c92 <fork+0xf4>

0000000080001ca8 <reparent>:
reparent(struct proc *p, struct proc *parent) {
    80001ca8:	711d                	addi	sp,sp,-96
    80001caa:	ec86                	sd	ra,88(sp)
    80001cac:	e8a2                	sd	s0,80(sp)
    80001cae:	e4a6                	sd	s1,72(sp)
    80001cb0:	e0ca                	sd	s2,64(sp)
    80001cb2:	fc4e                	sd	s3,56(sp)
    80001cb4:	f852                	sd	s4,48(sp)
    80001cb6:	f456                	sd	s5,40(sp)
    80001cb8:	f05a                	sd	s6,32(sp)
    80001cba:	ec5e                	sd	s7,24(sp)
    80001cbc:	e862                	sd	s8,16(sp)
    80001cbe:	e466                	sd	s9,8(sp)
    80001cc0:	1080                	addi	s0,sp,96
    80001cc2:	892a                	mv	s2,a0
  int child_of_init = (p->parent == initproc);
    80001cc4:	02053b83          	ld	s7,32(a0)
    80001cc8:	00027b17          	auipc	s6,0x27
    80001ccc:	358b3b03          	ld	s6,856(s6) # 80029020 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001cd0:	00010497          	auipc	s1,0x10
    80001cd4:	03048493          	addi	s1,s1,48 # 80011d00 <proc>
      pp->parent = initproc;
    80001cd8:	00027a17          	auipc	s4,0x27
    80001cdc:	348a0a13          	addi	s4,s4,840 # 80029020 <initproc>
      if(pp->state == ZOMBIE) {
    80001ce0:	4a91                	li	s5,4
// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
  if(p->chan == p && p->state == SLEEPING) {
    80001ce2:	4c05                	li	s8,1
    p->state = RUNNABLE;
    80001ce4:	4c89                	li	s9,2
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ce6:	00016997          	auipc	s3,0x16
    80001cea:	81a98993          	addi	s3,s3,-2022 # 80017500 <tickslock>
    80001cee:	a805                	j	80001d1e <reparent+0x76>
  if(p->chan == p && p->state == SLEEPING) {
    80001cf0:	751c                	ld	a5,40(a0)
    80001cf2:	00f51d63          	bne	a0,a5,80001d0c <reparent+0x64>
    80001cf6:	4d1c                	lw	a5,24(a0)
    80001cf8:	01879a63          	bne	a5,s8,80001d0c <reparent+0x64>
    p->state = RUNNABLE;
    80001cfc:	01952c23          	sw	s9,24(a0)
        if(!child_of_init)
    80001d00:	016b8663          	beq	s7,s6,80001d0c <reparent+0x64>
          release(&initproc->lock);
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	e36080e7          	jalr	-458(ra) # 80000b3a <release>
      release(&pp->lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	e2c080e7          	jalr	-468(ra) # 80000b3a <release>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001d16:	16048493          	addi	s1,s1,352
    80001d1a:	03348f63          	beq	s1,s3,80001d58 <reparent+0xb0>
    if(pp->parent == p){
    80001d1e:	709c                	ld	a5,32(s1)
    80001d20:	ff279be3          	bne	a5,s2,80001d16 <reparent+0x6e>
      acquire(&pp->lock);
    80001d24:	8526                	mv	a0,s1
    80001d26:	fffff097          	auipc	ra,0xfffff
    80001d2a:	dac080e7          	jalr	-596(ra) # 80000ad2 <acquire>
      pp->parent = initproc;
    80001d2e:	000a3503          	ld	a0,0(s4)
    80001d32:	f088                	sd	a0,32(s1)
      if(pp->state == ZOMBIE) {
    80001d34:	4c9c                	lw	a5,24(s1)
    80001d36:	fd579be3          	bne	a5,s5,80001d0c <reparent+0x64>
        if(!child_of_init)
    80001d3a:	fb6b8be3          	beq	s7,s6,80001cf0 <reparent+0x48>
          acquire(&initproc->lock);
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	d94080e7          	jalr	-620(ra) # 80000ad2 <acquire>
        wakeup1(initproc);
    80001d46:	000a3503          	ld	a0,0(s4)
  if(p->chan == p && p->state == SLEEPING) {
    80001d4a:	751c                	ld	a5,40(a0)
    80001d4c:	faa79ce3          	bne	a5,a0,80001d04 <reparent+0x5c>
    80001d50:	4d1c                	lw	a5,24(a0)
    80001d52:	fb8799e3          	bne	a5,s8,80001d04 <reparent+0x5c>
    80001d56:	b75d                	j	80001cfc <reparent+0x54>
}
    80001d58:	60e6                	ld	ra,88(sp)
    80001d5a:	6446                	ld	s0,80(sp)
    80001d5c:	64a6                	ld	s1,72(sp)
    80001d5e:	6906                	ld	s2,64(sp)
    80001d60:	79e2                	ld	s3,56(sp)
    80001d62:	7a42                	ld	s4,48(sp)
    80001d64:	7aa2                	ld	s5,40(sp)
    80001d66:	7b02                	ld	s6,32(sp)
    80001d68:	6be2                	ld	s7,24(sp)
    80001d6a:	6c42                	ld	s8,16(sp)
    80001d6c:	6ca2                	ld	s9,8(sp)
    80001d6e:	6125                	addi	sp,sp,96
    80001d70:	8082                	ret

0000000080001d72 <scheduler>:
{
    80001d72:	715d                	addi	sp,sp,-80
    80001d74:	e486                	sd	ra,72(sp)
    80001d76:	e0a2                	sd	s0,64(sp)
    80001d78:	fc26                	sd	s1,56(sp)
    80001d7a:	f84a                	sd	s2,48(sp)
    80001d7c:	f44e                	sd	s3,40(sp)
    80001d7e:	f052                	sd	s4,32(sp)
    80001d80:	ec56                	sd	s5,24(sp)
    80001d82:	e85a                	sd	s6,16(sp)
    80001d84:	e45e                	sd	s7,8(sp)
    80001d86:	e062                	sd	s8,0(sp)
    80001d88:	0880                	addi	s0,sp,80
    80001d8a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d8c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d8e:	00779b13          	slli	s6,a5,0x7
    80001d92:	00010717          	auipc	a4,0x10
    80001d96:	b5670713          	addi	a4,a4,-1194 # 800118e8 <pid_lock>
    80001d9a:	975a                	add	a4,a4,s6
    80001d9c:	00073c23          	sd	zero,24(a4)
        swtch(&c->scheduler, &p->context);
    80001da0:	00010717          	auipc	a4,0x10
    80001da4:	b6870713          	addi	a4,a4,-1176 # 80011908 <cpus+0x8>
    80001da8:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001daa:	4c0d                	li	s8,3
        c->proc = p;
    80001dac:	079e                	slli	a5,a5,0x7
    80001dae:	00010a17          	auipc	s4,0x10
    80001db2:	b3aa0a13          	addi	s4,s4,-1222 # 800118e8 <pid_lock>
    80001db6:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001db8:	00015997          	auipc	s3,0x15
    80001dbc:	74898993          	addi	s3,s3,1864 # 80017500 <tickslock>
        found = 1;
    80001dc0:	4b85                	li	s7,1
    80001dc2:	a08d                	j	80001e24 <scheduler+0xb2>
        p->state = RUNNING;
    80001dc4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dc8:	009a3c23          	sd	s1,24(s4)
        swtch(&c->scheduler, &p->context);
    80001dcc:	05848593          	addi	a1,s1,88
    80001dd0:	855a                	mv	a0,s6
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	5e8080e7          	jalr	1512(ra) # 800023ba <swtch>
        c->proc = 0;
    80001dda:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001dde:	8ade                	mv	s5,s7
      release(&p->lock);
    80001de0:	8526                	mv	a0,s1
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	d58080e7          	jalr	-680(ra) # 80000b3a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dea:	16048493          	addi	s1,s1,352
    80001dee:	01348b63          	beq	s1,s3,80001e04 <scheduler+0x92>
      acquire(&p->lock);
    80001df2:	8526                	mv	a0,s1
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	cde080e7          	jalr	-802(ra) # 80000ad2 <acquire>
      if(p->state == RUNNABLE) {
    80001dfc:	4c9c                	lw	a5,24(s1)
    80001dfe:	ff2791e3          	bne	a5,s2,80001de0 <scheduler+0x6e>
    80001e02:	b7c9                	j	80001dc4 <scheduler+0x52>
    if(found == 0){
    80001e04:	020a9063          	bnez	s5,80001e24 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80001e08:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80001e0c:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80001e10:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e1c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e20:	10500073          	wfi
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
    int found = 0;
    80001e3c:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e3e:	00010497          	auipc	s1,0x10
    80001e42:	ec248493          	addi	s1,s1,-318 # 80011d00 <proc>
      if(p->state == RUNNABLE) {
    80001e46:	4909                	li	s2,2
    80001e48:	b76d                	j	80001df2 <scheduler+0x80>

0000000080001e4a <sched>:
{
    80001e4a:	7179                	addi	sp,sp,-48
    80001e4c:	f406                	sd	ra,40(sp)
    80001e4e:	f022                	sd	s0,32(sp)
    80001e50:	ec26                	sd	s1,24(sp)
    80001e52:	e84a                	sd	s2,16(sp)
    80001e54:	e44e                	sd	s3,8(sp)
    80001e56:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	9dc080e7          	jalr	-1572(ra) # 80001834 <myproc>
    80001e60:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	c30080e7          	jalr	-976(ra) # 80000a92 <holding>
    80001e6a:	c93d                	beqz	a0,80001ee0 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e6c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e6e:	2781                	sext.w	a5,a5
    80001e70:	079e                	slli	a5,a5,0x7
    80001e72:	00010717          	auipc	a4,0x10
    80001e76:	a7670713          	addi	a4,a4,-1418 # 800118e8 <pid_lock>
    80001e7a:	97ba                	add	a5,a5,a4
    80001e7c:	0907a703          	lw	a4,144(a5)
    80001e80:	4785                	li	a5,1
    80001e82:	06f71763          	bne	a4,a5,80001ef0 <sched+0xa6>
  if(p->state == RUNNING)
    80001e86:	4c98                	lw	a4,24(s1)
    80001e88:	478d                	li	a5,3
    80001e8a:	06f70b63          	beq	a4,a5,80001f00 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e94:	efb5                	bnez	a5,80001f10 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e96:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e98:	00010917          	auipc	s2,0x10
    80001e9c:	a5090913          	addi	s2,s2,-1456 # 800118e8 <pid_lock>
    80001ea0:	2781                	sext.w	a5,a5
    80001ea2:	079e                	slli	a5,a5,0x7
    80001ea4:	97ca                	add	a5,a5,s2
    80001ea6:	0947a983          	lw	s3,148(a5)
    80001eaa:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80001eac:	2781                	sext.w	a5,a5
    80001eae:	079e                	slli	a5,a5,0x7
    80001eb0:	00010597          	auipc	a1,0x10
    80001eb4:	a5858593          	addi	a1,a1,-1448 # 80011908 <cpus+0x8>
    80001eb8:	95be                	add	a1,a1,a5
    80001eba:	05848513          	addi	a0,s1,88
    80001ebe:	00000097          	auipc	ra,0x0
    80001ec2:	4fc080e7          	jalr	1276(ra) # 800023ba <swtch>
    80001ec6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001ec8:	2781                	sext.w	a5,a5
    80001eca:	079e                	slli	a5,a5,0x7
    80001ecc:	97ca                	add	a5,a5,s2
    80001ece:	0937aa23          	sw	s3,148(a5)
}
    80001ed2:	70a2                	ld	ra,40(sp)
    80001ed4:	7402                	ld	s0,32(sp)
    80001ed6:	64e2                	ld	s1,24(sp)
    80001ed8:	6942                	ld	s2,16(sp)
    80001eda:	69a2                	ld	s3,8(sp)
    80001edc:	6145                	addi	sp,sp,48
    80001ede:	8082                	ret
    panic("sched p->lock");
    80001ee0:	00005517          	auipc	a0,0x5
    80001ee4:	41850513          	addi	a0,a0,1048 # 800072f8 <userret+0x268>
    80001ee8:	ffffe097          	auipc	ra,0xffffe
    80001eec:	666080e7          	jalr	1638(ra) # 8000054e <panic>
    panic("sched locks");
    80001ef0:	00005517          	auipc	a0,0x5
    80001ef4:	41850513          	addi	a0,a0,1048 # 80007308 <userret+0x278>
    80001ef8:	ffffe097          	auipc	ra,0xffffe
    80001efc:	656080e7          	jalr	1622(ra) # 8000054e <panic>
    panic("sched running");
    80001f00:	00005517          	auipc	a0,0x5
    80001f04:	41850513          	addi	a0,a0,1048 # 80007318 <userret+0x288>
    80001f08:	ffffe097          	auipc	ra,0xffffe
    80001f0c:	646080e7          	jalr	1606(ra) # 8000054e <panic>
    panic("sched interruptible");
    80001f10:	00005517          	auipc	a0,0x5
    80001f14:	41850513          	addi	a0,a0,1048 # 80007328 <userret+0x298>
    80001f18:	ffffe097          	auipc	ra,0xffffe
    80001f1c:	636080e7          	jalr	1590(ra) # 8000054e <panic>

0000000080001f20 <exit>:
{
    80001f20:	7179                	addi	sp,sp,-48
    80001f22:	f406                	sd	ra,40(sp)
    80001f24:	f022                	sd	s0,32(sp)
    80001f26:	ec26                	sd	s1,24(sp)
    80001f28:	e84a                	sd	s2,16(sp)
    80001f2a:	e44e                	sd	s3,8(sp)
    80001f2c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f2e:	00000097          	auipc	ra,0x0
    80001f32:	906080e7          	jalr	-1786(ra) # 80001834 <myproc>
    80001f36:	89aa                	mv	s3,a0
  if(p == initproc)
    80001f38:	00027797          	auipc	a5,0x27
    80001f3c:	0e87b783          	ld	a5,232(a5) # 80029020 <initproc>
    80001f40:	0c850493          	addi	s1,a0,200
    80001f44:	14850913          	addi	s2,a0,328
    80001f48:	02a79363          	bne	a5,a0,80001f6e <exit+0x4e>
    panic("init exiting");
    80001f4c:	00005517          	auipc	a0,0x5
    80001f50:	3f450513          	addi	a0,a0,1012 # 80007340 <userret+0x2b0>
    80001f54:	ffffe097          	auipc	ra,0xffffe
    80001f58:	5fa080e7          	jalr	1530(ra) # 8000054e <panic>
      fileclose(f);
    80001f5c:	00002097          	auipc	ra,0x2
    80001f60:	55a080e7          	jalr	1370(ra) # 800044b6 <fileclose>
      p->ofile[fd] = 0;
    80001f64:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001f68:	04a1                	addi	s1,s1,8
    80001f6a:	01248563          	beq	s1,s2,80001f74 <exit+0x54>
    if(p->ofile[fd]){
    80001f6e:	6088                	ld	a0,0(s1)
    80001f70:	f575                	bnez	a0,80001f5c <exit+0x3c>
    80001f72:	bfdd                	j	80001f68 <exit+0x48>
  begin_op(ROOTDEV);
    80001f74:	4501                	li	a0,0
    80001f76:	00002097          	auipc	ra,0x2
    80001f7a:	f18080e7          	jalr	-232(ra) # 80003e8e <begin_op>
  iput(p->cwd);
    80001f7e:	1489b503          	ld	a0,328(s3)
    80001f82:	00001097          	auipc	ra,0x1
    80001f86:	572080e7          	jalr	1394(ra) # 800034f4 <iput>
  end_op(ROOTDEV);
    80001f8a:	4501                	li	a0,0
    80001f8c:	00002097          	auipc	ra,0x2
    80001f90:	fac080e7          	jalr	-84(ra) # 80003f38 <end_op>
  p->cwd = 0;
    80001f94:	1409b423          	sd	zero,328(s3)
  acquire(&p->parent->lock);
    80001f98:	0209b503          	ld	a0,32(s3)
    80001f9c:	fffff097          	auipc	ra,0xfffff
    80001fa0:	b36080e7          	jalr	-1226(ra) # 80000ad2 <acquire>
  acquire(&p->lock);
    80001fa4:	854e                	mv	a0,s3
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	b2c080e7          	jalr	-1236(ra) # 80000ad2 <acquire>
  reparent(p, p->parent);
    80001fae:	0209b583          	ld	a1,32(s3)
    80001fb2:	854e                	mv	a0,s3
    80001fb4:	00000097          	auipc	ra,0x0
    80001fb8:	cf4080e7          	jalr	-780(ra) # 80001ca8 <reparent>
  wakeup1(p->parent);
    80001fbc:	0209b783          	ld	a5,32(s3)
  if(p->chan == p && p->state == SLEEPING) {
    80001fc0:	7798                	ld	a4,40(a5)
    80001fc2:	02e78763          	beq	a5,a4,80001ff0 <exit+0xd0>
  p->state = ZOMBIE;
    80001fc6:	4791                	li	a5,4
    80001fc8:	00f9ac23          	sw	a5,24(s3)
  release(&p->parent->lock);
    80001fcc:	0209b503          	ld	a0,32(s3)
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	b6a080e7          	jalr	-1174(ra) # 80000b3a <release>
  sched();
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	e72080e7          	jalr	-398(ra) # 80001e4a <sched>
  panic("zombie exit");
    80001fe0:	00005517          	auipc	a0,0x5
    80001fe4:	37050513          	addi	a0,a0,880 # 80007350 <userret+0x2c0>
    80001fe8:	ffffe097          	auipc	ra,0xffffe
    80001fec:	566080e7          	jalr	1382(ra) # 8000054e <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001ff0:	4f94                	lw	a3,24(a5)
    80001ff2:	4705                	li	a4,1
    80001ff4:	fce699e3          	bne	a3,a4,80001fc6 <exit+0xa6>
    p->state = RUNNABLE;
    80001ff8:	4709                	li	a4,2
    80001ffa:	cf98                	sw	a4,24(a5)
    80001ffc:	b7e9                	j	80001fc6 <exit+0xa6>

0000000080001ffe <yield>:
{
    80001ffe:	1101                	addi	sp,sp,-32
    80002000:	ec06                	sd	ra,24(sp)
    80002002:	e822                	sd	s0,16(sp)
    80002004:	e426                	sd	s1,8(sp)
    80002006:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002008:	00000097          	auipc	ra,0x0
    8000200c:	82c080e7          	jalr	-2004(ra) # 80001834 <myproc>
    80002010:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002012:	fffff097          	auipc	ra,0xfffff
    80002016:	ac0080e7          	jalr	-1344(ra) # 80000ad2 <acquire>
  p->state = RUNNABLE;
    8000201a:	4789                	li	a5,2
    8000201c:	cc9c                	sw	a5,24(s1)
  sched();
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	e2c080e7          	jalr	-468(ra) # 80001e4a <sched>
  release(&p->lock);
    80002026:	8526                	mv	a0,s1
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	b12080e7          	jalr	-1262(ra) # 80000b3a <release>
}
    80002030:	60e2                	ld	ra,24(sp)
    80002032:	6442                	ld	s0,16(sp)
    80002034:	64a2                	ld	s1,8(sp)
    80002036:	6105                	addi	sp,sp,32
    80002038:	8082                	ret

000000008000203a <sleep>:
{
    8000203a:	7179                	addi	sp,sp,-48
    8000203c:	f406                	sd	ra,40(sp)
    8000203e:	f022                	sd	s0,32(sp)
    80002040:	ec26                	sd	s1,24(sp)
    80002042:	e84a                	sd	s2,16(sp)
    80002044:	e44e                	sd	s3,8(sp)
    80002046:	1800                	addi	s0,sp,48
    80002048:	89aa                	mv	s3,a0
    8000204a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000204c:	fffff097          	auipc	ra,0xfffff
    80002050:	7e8080e7          	jalr	2024(ra) # 80001834 <myproc>
    80002054:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002056:	05250663          	beq	a0,s2,800020a2 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	a78080e7          	jalr	-1416(ra) # 80000ad2 <acquire>
    release(lk);
    80002062:	854a                	mv	a0,s2
    80002064:	fffff097          	auipc	ra,0xfffff
    80002068:	ad6080e7          	jalr	-1322(ra) # 80000b3a <release>
  p->chan = chan;
    8000206c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002070:	4785                	li	a5,1
    80002072:	cc9c                	sw	a5,24(s1)
  sched();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	dd6080e7          	jalr	-554(ra) # 80001e4a <sched>
  p->chan = 0;
    8000207c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002080:	8526                	mv	a0,s1
    80002082:	fffff097          	auipc	ra,0xfffff
    80002086:	ab8080e7          	jalr	-1352(ra) # 80000b3a <release>
    acquire(lk);
    8000208a:	854a                	mv	a0,s2
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	a46080e7          	jalr	-1466(ra) # 80000ad2 <acquire>
}
    80002094:	70a2                	ld	ra,40(sp)
    80002096:	7402                	ld	s0,32(sp)
    80002098:	64e2                	ld	s1,24(sp)
    8000209a:	6942                	ld	s2,16(sp)
    8000209c:	69a2                	ld	s3,8(sp)
    8000209e:	6145                	addi	sp,sp,48
    800020a0:	8082                	ret
  p->chan = chan;
    800020a2:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800020a6:	4785                	li	a5,1
    800020a8:	cd1c                	sw	a5,24(a0)
  sched();
    800020aa:	00000097          	auipc	ra,0x0
    800020ae:	da0080e7          	jalr	-608(ra) # 80001e4a <sched>
  p->chan = 0;
    800020b2:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800020b6:	bff9                	j	80002094 <sleep+0x5a>

00000000800020b8 <wait>:
{
    800020b8:	715d                	addi	sp,sp,-80
    800020ba:	e486                	sd	ra,72(sp)
    800020bc:	e0a2                	sd	s0,64(sp)
    800020be:	fc26                	sd	s1,56(sp)
    800020c0:	f84a                	sd	s2,48(sp)
    800020c2:	f44e                	sd	s3,40(sp)
    800020c4:	f052                	sd	s4,32(sp)
    800020c6:	ec56                	sd	s5,24(sp)
    800020c8:	e85a                	sd	s6,16(sp)
    800020ca:	e45e                	sd	s7,8(sp)
    800020cc:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	766080e7          	jalr	1894(ra) # 80001834 <myproc>
    800020d6:	892a                	mv	s2,a0
  acquire(&p->lock);
    800020d8:	8baa                	mv	s7,a0
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	9f8080e7          	jalr	-1544(ra) # 80000ad2 <acquire>
    havekids = 0;
    800020e2:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800020e4:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800020e6:	00015997          	auipc	s3,0x15
    800020ea:	41a98993          	addi	s3,s3,1050 # 80017500 <tickslock>
        havekids = 1;
    800020ee:	4a85                	li	s5,1
    havekids = 0;
    800020f0:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800020f2:	00010497          	auipc	s1,0x10
    800020f6:	c0e48493          	addi	s1,s1,-1010 # 80011d00 <proc>
    800020fa:	a03d                	j	80002128 <wait+0x70>
          pid = np->pid;
    800020fc:	0344a983          	lw	s3,52(s1)
          freeproc(np);
    80002100:	8526                	mv	a0,s1
    80002102:	00000097          	auipc	ra,0x0
    80002106:	94e080e7          	jalr	-1714(ra) # 80001a50 <freeproc>
          release(&np->lock);
    8000210a:	8526                	mv	a0,s1
    8000210c:	fffff097          	auipc	ra,0xfffff
    80002110:	a2e080e7          	jalr	-1490(ra) # 80000b3a <release>
          release(&p->lock);
    80002114:	854a                	mv	a0,s2
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	a24080e7          	jalr	-1500(ra) # 80000b3a <release>
          return pid;
    8000211e:	a089                	j	80002160 <wait+0xa8>
    for(np = proc; np < &proc[NPROC]; np++){
    80002120:	16048493          	addi	s1,s1,352
    80002124:	03348463          	beq	s1,s3,8000214c <wait+0x94>
      if(np->parent == p){
    80002128:	709c                	ld	a5,32(s1)
    8000212a:	ff279be3          	bne	a5,s2,80002120 <wait+0x68>
        acquire(&np->lock);
    8000212e:	8526                	mv	a0,s1
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	9a2080e7          	jalr	-1630(ra) # 80000ad2 <acquire>
        if(np->state == ZOMBIE){
    80002138:	4c9c                	lw	a5,24(s1)
    8000213a:	fd4781e3          	beq	a5,s4,800020fc <wait+0x44>
        release(&np->lock);
    8000213e:	8526                	mv	a0,s1
    80002140:	fffff097          	auipc	ra,0xfffff
    80002144:	9fa080e7          	jalr	-1542(ra) # 80000b3a <release>
        havekids = 1;
    80002148:	8756                	mv	a4,s5
    8000214a:	bfd9                	j	80002120 <wait+0x68>
    if(!havekids || p->killed){
    8000214c:	c701                	beqz	a4,80002154 <wait+0x9c>
    8000214e:	03092783          	lw	a5,48(s2)
    80002152:	c39d                	beqz	a5,80002178 <wait+0xc0>
      release(&p->lock);
    80002154:	854a                	mv	a0,s2
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	9e4080e7          	jalr	-1564(ra) # 80000b3a <release>
      return -1;
    8000215e:	59fd                	li	s3,-1
}
    80002160:	854e                	mv	a0,s3
    80002162:	60a6                	ld	ra,72(sp)
    80002164:	6406                	ld	s0,64(sp)
    80002166:	74e2                	ld	s1,56(sp)
    80002168:	7942                	ld	s2,48(sp)
    8000216a:	79a2                	ld	s3,40(sp)
    8000216c:	7a02                	ld	s4,32(sp)
    8000216e:	6ae2                	ld	s5,24(sp)
    80002170:	6b42                	ld	s6,16(sp)
    80002172:	6ba2                	ld	s7,8(sp)
    80002174:	6161                	addi	sp,sp,80
    80002176:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80002178:	85de                	mv	a1,s7
    8000217a:	854a                	mv	a0,s2
    8000217c:	00000097          	auipc	ra,0x0
    80002180:	ebe080e7          	jalr	-322(ra) # 8000203a <sleep>
    havekids = 0;
    80002184:	b7b5                	j	800020f0 <wait+0x38>

0000000080002186 <wakeup>:
{
    80002186:	7139                	addi	sp,sp,-64
    80002188:	fc06                	sd	ra,56(sp)
    8000218a:	f822                	sd	s0,48(sp)
    8000218c:	f426                	sd	s1,40(sp)
    8000218e:	f04a                	sd	s2,32(sp)
    80002190:	ec4e                	sd	s3,24(sp)
    80002192:	e852                	sd	s4,16(sp)
    80002194:	e456                	sd	s5,8(sp)
    80002196:	0080                	addi	s0,sp,64
    80002198:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000219a:	00010497          	auipc	s1,0x10
    8000219e:	b6648493          	addi	s1,s1,-1178 # 80011d00 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800021a2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800021a4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a6:	00015917          	auipc	s2,0x15
    800021aa:	35a90913          	addi	s2,s2,858 # 80017500 <tickslock>
    800021ae:	a821                	j	800021c6 <wakeup+0x40>
      p->state = RUNNABLE;
    800021b0:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	984080e7          	jalr	-1660(ra) # 80000b3a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021be:	16048493          	addi	s1,s1,352
    800021c2:	01248e63          	beq	s1,s2,800021de <wakeup+0x58>
    acquire(&p->lock);
    800021c6:	8526                	mv	a0,s1
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	90a080e7          	jalr	-1782(ra) # 80000ad2 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800021d0:	4c9c                	lw	a5,24(s1)
    800021d2:	ff3791e3          	bne	a5,s3,800021b4 <wakeup+0x2e>
    800021d6:	749c                	ld	a5,40(s1)
    800021d8:	fd479ee3          	bne	a5,s4,800021b4 <wakeup+0x2e>
    800021dc:	bfd1                	j	800021b0 <wakeup+0x2a>
}
    800021de:	70e2                	ld	ra,56(sp)
    800021e0:	7442                	ld	s0,48(sp)
    800021e2:	74a2                	ld	s1,40(sp)
    800021e4:	7902                	ld	s2,32(sp)
    800021e6:	69e2                	ld	s3,24(sp)
    800021e8:	6a42                	ld	s4,16(sp)
    800021ea:	6aa2                	ld	s5,8(sp)
    800021ec:	6121                	addi	sp,sp,64
    800021ee:	8082                	ret

00000000800021f0 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800021f0:	7179                	addi	sp,sp,-48
    800021f2:	f406                	sd	ra,40(sp)
    800021f4:	f022                	sd	s0,32(sp)
    800021f6:	ec26                	sd	s1,24(sp)
    800021f8:	e84a                	sd	s2,16(sp)
    800021fa:	e44e                	sd	s3,8(sp)
    800021fc:	1800                	addi	s0,sp,48
    800021fe:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002200:	00010497          	auipc	s1,0x10
    80002204:	b0048493          	addi	s1,s1,-1280 # 80011d00 <proc>
    80002208:	00015997          	auipc	s3,0x15
    8000220c:	2f898993          	addi	s3,s3,760 # 80017500 <tickslock>
    acquire(&p->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	8c0080e7          	jalr	-1856(ra) # 80000ad2 <acquire>
    if(p->pid == pid){
    8000221a:	58dc                	lw	a5,52(s1)
    8000221c:	01278d63          	beq	a5,s2,80002236 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	918080e7          	jalr	-1768(ra) # 80000b3a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000222a:	16048493          	addi	s1,s1,352
    8000222e:	ff3491e3          	bne	s1,s3,80002210 <kill+0x20>
  }
  return -1;
    80002232:	557d                	li	a0,-1
    80002234:	a821                	j	8000224c <kill+0x5c>
      p->killed = 1;
    80002236:	4785                	li	a5,1
    80002238:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    8000223a:	4c98                	lw	a4,24(s1)
    8000223c:	00f70f63          	beq	a4,a5,8000225a <kill+0x6a>
      release(&p->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	8f8080e7          	jalr	-1800(ra) # 80000b3a <release>
      return 0;
    8000224a:	4501                	li	a0,0
}
    8000224c:	70a2                	ld	ra,40(sp)
    8000224e:	7402                	ld	s0,32(sp)
    80002250:	64e2                	ld	s1,24(sp)
    80002252:	6942                	ld	s2,16(sp)
    80002254:	69a2                	ld	s3,8(sp)
    80002256:	6145                	addi	sp,sp,48
    80002258:	8082                	ret
        p->state = RUNNABLE;
    8000225a:	4789                	li	a5,2
    8000225c:	cc9c                	sw	a5,24(s1)
    8000225e:	b7cd                	j	80002240 <kill+0x50>

0000000080002260 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002260:	7179                	addi	sp,sp,-48
    80002262:	f406                	sd	ra,40(sp)
    80002264:	f022                	sd	s0,32(sp)
    80002266:	ec26                	sd	s1,24(sp)
    80002268:	e84a                	sd	s2,16(sp)
    8000226a:	e44e                	sd	s3,8(sp)
    8000226c:	e052                	sd	s4,0(sp)
    8000226e:	1800                	addi	s0,sp,48
    80002270:	84aa                	mv	s1,a0
    80002272:	892e                	mv	s2,a1
    80002274:	89b2                	mv	s3,a2
    80002276:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	5bc080e7          	jalr	1468(ra) # 80001834 <myproc>
  if(user_dst){
    80002280:	c08d                	beqz	s1,800022a2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002282:	86d2                	mv	a3,s4
    80002284:	864e                	mv	a2,s3
    80002286:	85ca                	mv	a1,s2
    80002288:	6528                	ld	a0,72(a0)
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	2d0080e7          	jalr	720(ra) # 8000155a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002292:	70a2                	ld	ra,40(sp)
    80002294:	7402                	ld	s0,32(sp)
    80002296:	64e2                	ld	s1,24(sp)
    80002298:	6942                	ld	s2,16(sp)
    8000229a:	69a2                	ld	s3,8(sp)
    8000229c:	6a02                	ld	s4,0(sp)
    8000229e:	6145                	addi	sp,sp,48
    800022a0:	8082                	ret
    memmove((char *)dst, src, len);
    800022a2:	000a061b          	sext.w	a2,s4
    800022a6:	85ce                	mv	a1,s3
    800022a8:	854a                	mv	a0,s2
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	94c080e7          	jalr	-1716(ra) # 80000bf6 <memmove>
    return 0;
    800022b2:	8526                	mv	a0,s1
    800022b4:	bff9                	j	80002292 <either_copyout+0x32>

00000000800022b6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022b6:	7179                	addi	sp,sp,-48
    800022b8:	f406                	sd	ra,40(sp)
    800022ba:	f022                	sd	s0,32(sp)
    800022bc:	ec26                	sd	s1,24(sp)
    800022be:	e84a                	sd	s2,16(sp)
    800022c0:	e44e                	sd	s3,8(sp)
    800022c2:	e052                	sd	s4,0(sp)
    800022c4:	1800                	addi	s0,sp,48
    800022c6:	892a                	mv	s2,a0
    800022c8:	84ae                	mv	s1,a1
    800022ca:	89b2                	mv	s3,a2
    800022cc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	566080e7          	jalr	1382(ra) # 80001834 <myproc>
  if(user_src){
    800022d6:	c08d                	beqz	s1,800022f8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800022d8:	86d2                	mv	a3,s4
    800022da:	864e                	mv	a2,s3
    800022dc:	85ca                	mv	a1,s2
    800022de:	6528                	ld	a0,72(a0)
    800022e0:	fffff097          	auipc	ra,0xfffff
    800022e4:	30c080e7          	jalr	780(ra) # 800015ec <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022e8:	70a2                	ld	ra,40(sp)
    800022ea:	7402                	ld	s0,32(sp)
    800022ec:	64e2                	ld	s1,24(sp)
    800022ee:	6942                	ld	s2,16(sp)
    800022f0:	69a2                	ld	s3,8(sp)
    800022f2:	6a02                	ld	s4,0(sp)
    800022f4:	6145                	addi	sp,sp,48
    800022f6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022f8:	000a061b          	sext.w	a2,s4
    800022fc:	85ce                	mv	a1,s3
    800022fe:	854a                	mv	a0,s2
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	8f6080e7          	jalr	-1802(ra) # 80000bf6 <memmove>
    return 0;
    80002308:	8526                	mv	a0,s1
    8000230a:	bff9                	j	800022e8 <either_copyin+0x32>

000000008000230c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000230c:	715d                	addi	sp,sp,-80
    8000230e:	e486                	sd	ra,72(sp)
    80002310:	e0a2                	sd	s0,64(sp)
    80002312:	fc26                	sd	s1,56(sp)
    80002314:	f84a                	sd	s2,48(sp)
    80002316:	f44e                	sd	s3,40(sp)
    80002318:	f052                	sd	s4,32(sp)
    8000231a:	ec56                	sd	s5,24(sp)
    8000231c:	e85a                	sd	s6,16(sp)
    8000231e:	e45e                	sd	s7,8(sp)
    80002320:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002322:	00005517          	auipc	a0,0x5
    80002326:	e8e50513          	addi	a0,a0,-370 # 800071b0 <userret+0x120>
    8000232a:	ffffe097          	auipc	ra,0xffffe
    8000232e:	26e080e7          	jalr	622(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002332:	00010497          	auipc	s1,0x10
    80002336:	b1e48493          	addi	s1,s1,-1250 # 80011e50 <proc+0x150>
    8000233a:	00015917          	auipc	s2,0x15
    8000233e:	31690913          	addi	s2,s2,790 # 80017650 <bcache+0x138>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002342:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002344:	00005997          	auipc	s3,0x5
    80002348:	01c98993          	addi	s3,s3,28 # 80007360 <userret+0x2d0>
    printf("%d %s %s", p->pid, state, p->name);
    8000234c:	00005a97          	auipc	s5,0x5
    80002350:	01ca8a93          	addi	s5,s5,28 # 80007368 <userret+0x2d8>
    printf("\n");
    80002354:	00005a17          	auipc	s4,0x5
    80002358:	e5ca0a13          	addi	s4,s4,-420 # 800071b0 <userret+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000235c:	00005b97          	auipc	s7,0x5
    80002360:	56cb8b93          	addi	s7,s7,1388 # 800078c8 <states.1759>
    80002364:	a00d                	j	80002386 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002366:	ee46a583          	lw	a1,-284(a3)
    8000236a:	8556                	mv	a0,s5
    8000236c:	ffffe097          	auipc	ra,0xffffe
    80002370:	22c080e7          	jalr	556(ra) # 80000598 <printf>
    printf("\n");
    80002374:	8552                	mv	a0,s4
    80002376:	ffffe097          	auipc	ra,0xffffe
    8000237a:	222080e7          	jalr	546(ra) # 80000598 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000237e:	16048493          	addi	s1,s1,352
    80002382:	03248163          	beq	s1,s2,800023a4 <procdump+0x98>
    if(p->state == UNUSED)
    80002386:	86a6                	mv	a3,s1
    80002388:	ec84a783          	lw	a5,-312(s1)
    8000238c:	dbed                	beqz	a5,8000237e <procdump+0x72>
      state = "???";
    8000238e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002390:	fcfb6be3          	bltu	s6,a5,80002366 <procdump+0x5a>
    80002394:	1782                	slli	a5,a5,0x20
    80002396:	9381                	srli	a5,a5,0x20
    80002398:	078e                	slli	a5,a5,0x3
    8000239a:	97de                	add	a5,a5,s7
    8000239c:	6390                	ld	a2,0(a5)
    8000239e:	f661                	bnez	a2,80002366 <procdump+0x5a>
      state = "???";
    800023a0:	864e                	mv	a2,s3
    800023a2:	b7d1                	j	80002366 <procdump+0x5a>
  }
}
    800023a4:	60a6                	ld	ra,72(sp)
    800023a6:	6406                	ld	s0,64(sp)
    800023a8:	74e2                	ld	s1,56(sp)
    800023aa:	7942                	ld	s2,48(sp)
    800023ac:	79a2                	ld	s3,40(sp)
    800023ae:	7a02                	ld	s4,32(sp)
    800023b0:	6ae2                	ld	s5,24(sp)
    800023b2:	6b42                	ld	s6,16(sp)
    800023b4:	6ba2                	ld	s7,8(sp)
    800023b6:	6161                	addi	sp,sp,80
    800023b8:	8082                	ret

00000000800023ba <swtch>:
    800023ba:	00153023          	sd	ra,0(a0)
    800023be:	00253423          	sd	sp,8(a0)
    800023c2:	e900                	sd	s0,16(a0)
    800023c4:	ed04                	sd	s1,24(a0)
    800023c6:	03253023          	sd	s2,32(a0)
    800023ca:	03353423          	sd	s3,40(a0)
    800023ce:	03453823          	sd	s4,48(a0)
    800023d2:	03553c23          	sd	s5,56(a0)
    800023d6:	05653023          	sd	s6,64(a0)
    800023da:	05753423          	sd	s7,72(a0)
    800023de:	05853823          	sd	s8,80(a0)
    800023e2:	05953c23          	sd	s9,88(a0)
    800023e6:	07a53023          	sd	s10,96(a0)
    800023ea:	07b53423          	sd	s11,104(a0)
    800023ee:	0005b083          	ld	ra,0(a1)
    800023f2:	0085b103          	ld	sp,8(a1)
    800023f6:	6980                	ld	s0,16(a1)
    800023f8:	6d84                	ld	s1,24(a1)
    800023fa:	0205b903          	ld	s2,32(a1)
    800023fe:	0285b983          	ld	s3,40(a1)
    80002402:	0305ba03          	ld	s4,48(a1)
    80002406:	0385ba83          	ld	s5,56(a1)
    8000240a:	0405bb03          	ld	s6,64(a1)
    8000240e:	0485bb83          	ld	s7,72(a1)
    80002412:	0505bc03          	ld	s8,80(a1)
    80002416:	0585bc83          	ld	s9,88(a1)
    8000241a:	0605bd03          	ld	s10,96(a1)
    8000241e:	0685bd83          	ld	s11,104(a1)
    80002422:	8082                	ret

0000000080002424 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002424:	1141                	addi	sp,sp,-16
    80002426:	e406                	sd	ra,8(sp)
    80002428:	e022                	sd	s0,0(sp)
    8000242a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000242c:	00005597          	auipc	a1,0x5
    80002430:	f7458593          	addi	a1,a1,-140 # 800073a0 <userret+0x310>
    80002434:	00015517          	auipc	a0,0x15
    80002438:	0cc50513          	addi	a0,a0,204 # 80017500 <tickslock>
    8000243c:	ffffe097          	auipc	ra,0xffffe
    80002440:	584080e7          	jalr	1412(ra) # 800009c0 <initlock>
}
    80002444:	60a2                	ld	ra,8(sp)
    80002446:	6402                	ld	s0,0(sp)
    80002448:	0141                	addi	sp,sp,16
    8000244a:	8082                	ret

000000008000244c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000244c:	1141                	addi	sp,sp,-16
    8000244e:	e422                	sd	s0,8(sp)
    80002450:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002452:	00003797          	auipc	a5,0x3
    80002456:	70e78793          	addi	a5,a5,1806 # 80005b60 <kernelvec>
    8000245a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000245e:	6422                	ld	s0,8(sp)
    80002460:	0141                	addi	sp,sp,16
    80002462:	8082                	ret

0000000080002464 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002464:	1141                	addi	sp,sp,-16
    80002466:	e406                	sd	ra,8(sp)
    80002468:	e022                	sd	s0,0(sp)
    8000246a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	3c8080e7          	jalr	968(ra) # 80001834 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002474:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002478:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000247a:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send interrupts and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000247e:	00005617          	auipc	a2,0x5
    80002482:	b8260613          	addi	a2,a2,-1150 # 80007000 <trampoline>
    80002486:	00005697          	auipc	a3,0x5
    8000248a:	b7a68693          	addi	a3,a3,-1158 # 80007000 <trampoline>
    8000248e:	8e91                	sub	a3,a3,a2
    80002490:	040007b7          	lui	a5,0x4000
    80002494:	17fd                	addi	a5,a5,-1
    80002496:	07b2                	slli	a5,a5,0xc
    80002498:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000249a:	10569073          	csrw	stvec,a3

  // set up values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    8000249e:	6938                	ld	a4,80(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024a0:	180026f3          	csrr	a3,satp
    800024a4:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024a6:	6938                	ld	a4,80(a0)
    800024a8:	7d14                	ld	a3,56(a0)
    800024aa:	6585                	lui	a1,0x1
    800024ac:	96ae                	add	a3,a3,a1
    800024ae:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    800024b0:	6938                	ld	a4,80(a0)
    800024b2:	00000697          	auipc	a3,0x0
    800024b6:	12868693          	addi	a3,a3,296 # 800025da <usertrap>
    800024ba:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    800024bc:	6938                	ld	a4,80(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024be:	8692                	mv	a3,tp
    800024c0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c2:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024c6:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024ca:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024ce:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    800024d2:	6938                	ld	a4,80(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024d4:	6f18                	ld	a4,24(a4)
    800024d6:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024da:	652c                	ld	a1,72(a0)
    800024dc:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800024de:	00005717          	auipc	a4,0x5
    800024e2:	bb270713          	addi	a4,a4,-1102 # 80007090 <userret>
    800024e6:	8f11                	sub	a4,a4,a2
    800024e8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800024ea:	577d                	li	a4,-1
    800024ec:	177e                	slli	a4,a4,0x3f
    800024ee:	8dd9                	or	a1,a1,a4
    800024f0:	02000537          	lui	a0,0x2000
    800024f4:	157d                	addi	a0,a0,-1
    800024f6:	0536                	slli	a0,a0,0xd
    800024f8:	9782                	jalr	a5
}
    800024fa:	60a2                	ld	ra,8(sp)
    800024fc:	6402                	ld	s0,0(sp)
    800024fe:	0141                	addi	sp,sp,16
    80002500:	8082                	ret

0000000080002502 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002502:	1101                	addi	sp,sp,-32
    80002504:	ec06                	sd	ra,24(sp)
    80002506:	e822                	sd	s0,16(sp)
    80002508:	e426                	sd	s1,8(sp)
    8000250a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000250c:	00015497          	auipc	s1,0x15
    80002510:	ff448493          	addi	s1,s1,-12 # 80017500 <tickslock>
    80002514:	8526                	mv	a0,s1
    80002516:	ffffe097          	auipc	ra,0xffffe
    8000251a:	5bc080e7          	jalr	1468(ra) # 80000ad2 <acquire>
  ticks++;
    8000251e:	00027517          	auipc	a0,0x27
    80002522:	b0a50513          	addi	a0,a0,-1270 # 80029028 <ticks>
    80002526:	411c                	lw	a5,0(a0)
    80002528:	2785                	addiw	a5,a5,1
    8000252a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000252c:	00000097          	auipc	ra,0x0
    80002530:	c5a080e7          	jalr	-934(ra) # 80002186 <wakeup>
  release(&tickslock);
    80002534:	8526                	mv	a0,s1
    80002536:	ffffe097          	auipc	ra,0xffffe
    8000253a:	604080e7          	jalr	1540(ra) # 80000b3a <release>
}
    8000253e:	60e2                	ld	ra,24(sp)
    80002540:	6442                	ld	s0,16(sp)
    80002542:	64a2                	ld	s1,8(sp)
    80002544:	6105                	addi	sp,sp,32
    80002546:	8082                	ret

0000000080002548 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002548:	1101                	addi	sp,sp,-32
    8000254a:	ec06                	sd	ra,24(sp)
    8000254c:	e822                	sd	s0,16(sp)
    8000254e:	e426                	sd	s1,8(sp)
    80002550:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002552:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002556:	00074d63          	bltz	a4,80002570 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    8000255a:	57fd                	li	a5,-1
    8000255c:	17fe                	slli	a5,a5,0x3f
    8000255e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002560:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002562:	04f70b63          	beq	a4,a5,800025b8 <devintr+0x70>
  }
}
    80002566:	60e2                	ld	ra,24(sp)
    80002568:	6442                	ld	s0,16(sp)
    8000256a:	64a2                	ld	s1,8(sp)
    8000256c:	6105                	addi	sp,sp,32
    8000256e:	8082                	ret
     (scause & 0xff) == 9){
    80002570:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002574:	46a5                	li	a3,9
    80002576:	fed792e3          	bne	a5,a3,8000255a <devintr+0x12>
    int irq = plic_claim();
    8000257a:	00003097          	auipc	ra,0x3
    8000257e:	700080e7          	jalr	1792(ra) # 80005c7a <plic_claim>
    80002582:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002584:	47a9                	li	a5,10
    80002586:	00f50e63          	beq	a0,a5,800025a2 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    8000258a:	fff5079b          	addiw	a5,a0,-1
    8000258e:	4705                	li	a4,1
    80002590:	00f77e63          	bgeu	a4,a5,800025ac <devintr+0x64>
    plic_complete(irq);
    80002594:	8526                	mv	a0,s1
    80002596:	00003097          	auipc	ra,0x3
    8000259a:	708080e7          	jalr	1800(ra) # 80005c9e <plic_complete>
    return 1;
    8000259e:	4505                	li	a0,1
    800025a0:	b7d9                	j	80002566 <devintr+0x1e>
      uartintr();
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	296080e7          	jalr	662(ra) # 80000838 <uartintr>
    800025aa:	b7ed                	j	80002594 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800025ac:	853e                	mv	a0,a5
    800025ae:	00004097          	auipc	ra,0x4
    800025b2:	cc0080e7          	jalr	-832(ra) # 8000626e <virtio_disk_intr>
    800025b6:	bff9                	j	80002594 <devintr+0x4c>
    if(cpuid() == 0){
    800025b8:	fffff097          	auipc	ra,0xfffff
    800025bc:	250080e7          	jalr	592(ra) # 80001808 <cpuid>
    800025c0:	c901                	beqz	a0,800025d0 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800025c2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800025c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800025c8:	14479073          	csrw	sip,a5
    return 2;
    800025cc:	4509                	li	a0,2
    800025ce:	bf61                	j	80002566 <devintr+0x1e>
      clockintr();
    800025d0:	00000097          	auipc	ra,0x0
    800025d4:	f32080e7          	jalr	-206(ra) # 80002502 <clockintr>
    800025d8:	b7ed                	j	800025c2 <devintr+0x7a>

00000000800025da <usertrap>:
{
    800025da:	1101                	addi	sp,sp,-32
    800025dc:	ec06                	sd	ra,24(sp)
    800025de:	e822                	sd	s0,16(sp)
    800025e0:	e426                	sd	s1,8(sp)
    800025e2:	e04a                	sd	s2,0(sp)
    800025e4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025ea:	1007f793          	andi	a5,a5,256
    800025ee:	e7bd                	bnez	a5,8000265c <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025f0:	00003797          	auipc	a5,0x3
    800025f4:	57078793          	addi	a5,a5,1392 # 80005b60 <kernelvec>
    800025f8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025fc:	fffff097          	auipc	ra,0xfffff
    80002600:	238080e7          	jalr	568(ra) # 80001834 <myproc>
    80002604:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002606:	693c                	ld	a5,80(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002608:	14102773          	csrr	a4,sepc
    8000260c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000260e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002612:	47a1                	li	a5,8
    80002614:	06f71163          	bne	a4,a5,80002676 <usertrap+0x9c>
    if(p->killed)
    80002618:	591c                	lw	a5,48(a0)
    8000261a:	eba9                	bnez	a5,8000266c <usertrap+0x92>
    p->tf->epc += 4;
    8000261c:	68b8                	ld	a4,80(s1)
    8000261e:	6f1c                	ld	a5,24(a4)
    80002620:	0791                	addi	a5,a5,4
    80002622:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002624:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002628:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000262c:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002630:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002634:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002638:	10079073          	csrw	sstatus,a5
    syscall();
    8000263c:	00000097          	auipc	ra,0x0
    80002640:	2dc080e7          	jalr	732(ra) # 80002918 <syscall>
  if(p->killed)
    80002644:	589c                	lw	a5,48(s1)
    80002646:	e7d1                	bnez	a5,800026d2 <usertrap+0xf8>
  usertrapret();
    80002648:	00000097          	auipc	ra,0x0
    8000264c:	e1c080e7          	jalr	-484(ra) # 80002464 <usertrapret>
}
    80002650:	60e2                	ld	ra,24(sp)
    80002652:	6442                	ld	s0,16(sp)
    80002654:	64a2                	ld	s1,8(sp)
    80002656:	6902                	ld	s2,0(sp)
    80002658:	6105                	addi	sp,sp,32
    8000265a:	8082                	ret
    panic("usertrap: not from user mode");
    8000265c:	00005517          	auipc	a0,0x5
    80002660:	d4c50513          	addi	a0,a0,-692 # 800073a8 <userret+0x318>
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	eea080e7          	jalr	-278(ra) # 8000054e <panic>
      exit();
    8000266c:	00000097          	auipc	ra,0x0
    80002670:	8b4080e7          	jalr	-1868(ra) # 80001f20 <exit>
    80002674:	b765                	j	8000261c <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002676:	00000097          	auipc	ra,0x0
    8000267a:	ed2080e7          	jalr	-302(ra) # 80002548 <devintr>
    8000267e:	892a                	mv	s2,a0
    80002680:	c501                	beqz	a0,80002688 <usertrap+0xae>
  if(p->killed)
    80002682:	589c                	lw	a5,48(s1)
    80002684:	cf9d                	beqz	a5,800026c2 <usertrap+0xe8>
    80002686:	a815                	j	800026ba <usertrap+0xe0>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002688:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000268c:	58d0                	lw	a2,52(s1)
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	d3a50513          	addi	a0,a0,-710 # 800073c8 <userret+0x338>
    80002696:	ffffe097          	auipc	ra,0xffffe
    8000269a:	f02080e7          	jalr	-254(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000269e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026a2:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800026a6:	00005517          	auipc	a0,0x5
    800026aa:	d5250513          	addi	a0,a0,-686 # 800073f8 <userret+0x368>
    800026ae:	ffffe097          	auipc	ra,0xffffe
    800026b2:	eea080e7          	jalr	-278(ra) # 80000598 <printf>
    p->killed = 1;
    800026b6:	4785                	li	a5,1
    800026b8:	d89c                	sw	a5,48(s1)
    exit();
    800026ba:	00000097          	auipc	ra,0x0
    800026be:	866080e7          	jalr	-1946(ra) # 80001f20 <exit>
  if(which_dev == 2)
    800026c2:	4789                	li	a5,2
    800026c4:	f8f912e3          	bne	s2,a5,80002648 <usertrap+0x6e>
    yield();
    800026c8:	00000097          	auipc	ra,0x0
    800026cc:	936080e7          	jalr	-1738(ra) # 80001ffe <yield>
    800026d0:	bfa5                	j	80002648 <usertrap+0x6e>
  int which_dev = 0;
    800026d2:	4901                	li	s2,0
    800026d4:	b7dd                	j	800026ba <usertrap+0xe0>

00000000800026d6 <kerneltrap>:
{
    800026d6:	7179                	addi	sp,sp,-48
    800026d8:	f406                	sd	ra,40(sp)
    800026da:	f022                	sd	s0,32(sp)
    800026dc:	ec26                	sd	s1,24(sp)
    800026de:	e84a                	sd	s2,16(sp)
    800026e0:	e44e                	sd	s3,8(sp)
    800026e2:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026e4:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026e8:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ec:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026f0:	1004f793          	andi	a5,s1,256
    800026f4:	cb85                	beqz	a5,80002724 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026f6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026fa:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026fc:	ef85                	bnez	a5,80002734 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800026fe:	00000097          	auipc	ra,0x0
    80002702:	e4a080e7          	jalr	-438(ra) # 80002548 <devintr>
    80002706:	cd1d                	beqz	a0,80002744 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002708:	4789                	li	a5,2
    8000270a:	06f50a63          	beq	a0,a5,8000277e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000270e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002712:	10049073          	csrw	sstatus,s1
}
    80002716:	70a2                	ld	ra,40(sp)
    80002718:	7402                	ld	s0,32(sp)
    8000271a:	64e2                	ld	s1,24(sp)
    8000271c:	6942                	ld	s2,16(sp)
    8000271e:	69a2                	ld	s3,8(sp)
    80002720:	6145                	addi	sp,sp,48
    80002722:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002724:	00005517          	auipc	a0,0x5
    80002728:	cf450513          	addi	a0,a0,-780 # 80007418 <userret+0x388>
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	e22080e7          	jalr	-478(ra) # 8000054e <panic>
    panic("kerneltrap: interrupts enabled");
    80002734:	00005517          	auipc	a0,0x5
    80002738:	d0c50513          	addi	a0,a0,-756 # 80007440 <userret+0x3b0>
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	e12080e7          	jalr	-494(ra) # 8000054e <panic>
    printf("scause %p\n", scause);
    80002744:	85ce                	mv	a1,s3
    80002746:	00005517          	auipc	a0,0x5
    8000274a:	d1a50513          	addi	a0,a0,-742 # 80007460 <userret+0x3d0>
    8000274e:	ffffe097          	auipc	ra,0xffffe
    80002752:	e4a080e7          	jalr	-438(ra) # 80000598 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002756:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000275a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000275e:	00005517          	auipc	a0,0x5
    80002762:	d1250513          	addi	a0,a0,-750 # 80007470 <userret+0x3e0>
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	e32080e7          	jalr	-462(ra) # 80000598 <printf>
    panic("kerneltrap");
    8000276e:	00005517          	auipc	a0,0x5
    80002772:	d1a50513          	addi	a0,a0,-742 # 80007488 <userret+0x3f8>
    80002776:	ffffe097          	auipc	ra,0xffffe
    8000277a:	dd8080e7          	jalr	-552(ra) # 8000054e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000277e:	fffff097          	auipc	ra,0xfffff
    80002782:	0b6080e7          	jalr	182(ra) # 80001834 <myproc>
    80002786:	d541                	beqz	a0,8000270e <kerneltrap+0x38>
    80002788:	fffff097          	auipc	ra,0xfffff
    8000278c:	0ac080e7          	jalr	172(ra) # 80001834 <myproc>
    80002790:	4d18                	lw	a4,24(a0)
    80002792:	478d                	li	a5,3
    80002794:	f6f71de3          	bne	a4,a5,8000270e <kerneltrap+0x38>
    yield();
    80002798:	00000097          	auipc	ra,0x0
    8000279c:	866080e7          	jalr	-1946(ra) # 80001ffe <yield>
    800027a0:	b7bd                	j	8000270e <kerneltrap+0x38>

00000000800027a2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027a2:	1101                	addi	sp,sp,-32
    800027a4:	ec06                	sd	ra,24(sp)
    800027a6:	e822                	sd	s0,16(sp)
    800027a8:	e426                	sd	s1,8(sp)
    800027aa:	1000                	addi	s0,sp,32
    800027ac:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027ae:	fffff097          	auipc	ra,0xfffff
    800027b2:	086080e7          	jalr	134(ra) # 80001834 <myproc>
  switch (n) {
    800027b6:	4795                	li	a5,5
    800027b8:	0497e163          	bltu	a5,s1,800027fa <argraw+0x58>
    800027bc:	048a                	slli	s1,s1,0x2
    800027be:	00005717          	auipc	a4,0x5
    800027c2:	13270713          	addi	a4,a4,306 # 800078f0 <states.1759+0x28>
    800027c6:	94ba                	add	s1,s1,a4
    800027c8:	409c                	lw	a5,0(s1)
    800027ca:	97ba                	add	a5,a5,a4
    800027cc:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    800027ce:	693c                	ld	a5,80(a0)
    800027d0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    800027d2:	60e2                	ld	ra,24(sp)
    800027d4:	6442                	ld	s0,16(sp)
    800027d6:	64a2                	ld	s1,8(sp)
    800027d8:	6105                	addi	sp,sp,32
    800027da:	8082                	ret
    return p->tf->a1;
    800027dc:	693c                	ld	a5,80(a0)
    800027de:	7fa8                	ld	a0,120(a5)
    800027e0:	bfcd                	j	800027d2 <argraw+0x30>
    return p->tf->a2;
    800027e2:	693c                	ld	a5,80(a0)
    800027e4:	63c8                	ld	a0,128(a5)
    800027e6:	b7f5                	j	800027d2 <argraw+0x30>
    return p->tf->a3;
    800027e8:	693c                	ld	a5,80(a0)
    800027ea:	67c8                	ld	a0,136(a5)
    800027ec:	b7dd                	j	800027d2 <argraw+0x30>
    return p->tf->a4;
    800027ee:	693c                	ld	a5,80(a0)
    800027f0:	6bc8                	ld	a0,144(a5)
    800027f2:	b7c5                	j	800027d2 <argraw+0x30>
    return p->tf->a5;
    800027f4:	693c                	ld	a5,80(a0)
    800027f6:	6fc8                	ld	a0,152(a5)
    800027f8:	bfe9                	j	800027d2 <argraw+0x30>
  panic("argraw");
    800027fa:	00005517          	auipc	a0,0x5
    800027fe:	c9e50513          	addi	a0,a0,-866 # 80007498 <userret+0x408>
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	d4c080e7          	jalr	-692(ra) # 8000054e <panic>

000000008000280a <fetchaddr>:
{
    8000280a:	1101                	addi	sp,sp,-32
    8000280c:	ec06                	sd	ra,24(sp)
    8000280e:	e822                	sd	s0,16(sp)
    80002810:	e426                	sd	s1,8(sp)
    80002812:	e04a                	sd	s2,0(sp)
    80002814:	1000                	addi	s0,sp,32
    80002816:	84aa                	mv	s1,a0
    80002818:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000281a:	fffff097          	auipc	ra,0xfffff
    8000281e:	01a080e7          	jalr	26(ra) # 80001834 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002822:	613c                	ld	a5,64(a0)
    80002824:	02f4f863          	bgeu	s1,a5,80002854 <fetchaddr+0x4a>
    80002828:	00848713          	addi	a4,s1,8
    8000282c:	02e7e663          	bltu	a5,a4,80002858 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002830:	46a1                	li	a3,8
    80002832:	8626                	mv	a2,s1
    80002834:	85ca                	mv	a1,s2
    80002836:	6528                	ld	a0,72(a0)
    80002838:	fffff097          	auipc	ra,0xfffff
    8000283c:	db4080e7          	jalr	-588(ra) # 800015ec <copyin>
    80002840:	00a03533          	snez	a0,a0
    80002844:	40a00533          	neg	a0,a0
}
    80002848:	60e2                	ld	ra,24(sp)
    8000284a:	6442                	ld	s0,16(sp)
    8000284c:	64a2                	ld	s1,8(sp)
    8000284e:	6902                	ld	s2,0(sp)
    80002850:	6105                	addi	sp,sp,32
    80002852:	8082                	ret
    return -1;
    80002854:	557d                	li	a0,-1
    80002856:	bfcd                	j	80002848 <fetchaddr+0x3e>
    80002858:	557d                	li	a0,-1
    8000285a:	b7fd                	j	80002848 <fetchaddr+0x3e>

000000008000285c <fetchstr>:
{
    8000285c:	7179                	addi	sp,sp,-48
    8000285e:	f406                	sd	ra,40(sp)
    80002860:	f022                	sd	s0,32(sp)
    80002862:	ec26                	sd	s1,24(sp)
    80002864:	e84a                	sd	s2,16(sp)
    80002866:	e44e                	sd	s3,8(sp)
    80002868:	1800                	addi	s0,sp,48
    8000286a:	892a                	mv	s2,a0
    8000286c:	84ae                	mv	s1,a1
    8000286e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	fc4080e7          	jalr	-60(ra) # 80001834 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002878:	86ce                	mv	a3,s3
    8000287a:	864a                	mv	a2,s2
    8000287c:	85a6                	mv	a1,s1
    8000287e:	6528                	ld	a0,72(a0)
    80002880:	fffff097          	auipc	ra,0xfffff
    80002884:	dfe080e7          	jalr	-514(ra) # 8000167e <copyinstr>
  if(err < 0)
    80002888:	00054763          	bltz	a0,80002896 <fetchstr+0x3a>
  return strlen(buf);
    8000288c:	8526                	mv	a0,s1
    8000288e:	ffffe097          	auipc	ra,0xffffe
    80002892:	490080e7          	jalr	1168(ra) # 80000d1e <strlen>
}
    80002896:	70a2                	ld	ra,40(sp)
    80002898:	7402                	ld	s0,32(sp)
    8000289a:	64e2                	ld	s1,24(sp)
    8000289c:	6942                	ld	s2,16(sp)
    8000289e:	69a2                	ld	s3,8(sp)
    800028a0:	6145                	addi	sp,sp,48
    800028a2:	8082                	ret

00000000800028a4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800028a4:	1101                	addi	sp,sp,-32
    800028a6:	ec06                	sd	ra,24(sp)
    800028a8:	e822                	sd	s0,16(sp)
    800028aa:	e426                	sd	s1,8(sp)
    800028ac:	1000                	addi	s0,sp,32
    800028ae:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b0:	00000097          	auipc	ra,0x0
    800028b4:	ef2080e7          	jalr	-270(ra) # 800027a2 <argraw>
    800028b8:	c088                	sw	a0,0(s1)
  return 0;
}
    800028ba:	4501                	li	a0,0
    800028bc:	60e2                	ld	ra,24(sp)
    800028be:	6442                	ld	s0,16(sp)
    800028c0:	64a2                	ld	s1,8(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret

00000000800028c6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800028c6:	1101                	addi	sp,sp,-32
    800028c8:	ec06                	sd	ra,24(sp)
    800028ca:	e822                	sd	s0,16(sp)
    800028cc:	e426                	sd	s1,8(sp)
    800028ce:	1000                	addi	s0,sp,32
    800028d0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028d2:	00000097          	auipc	ra,0x0
    800028d6:	ed0080e7          	jalr	-304(ra) # 800027a2 <argraw>
    800028da:	e088                	sd	a0,0(s1)
  return 0;
}
    800028dc:	4501                	li	a0,0
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	64a2                	ld	s1,8(sp)
    800028e4:	6105                	addi	sp,sp,32
    800028e6:	8082                	ret

00000000800028e8 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028e8:	1101                	addi	sp,sp,-32
    800028ea:	ec06                	sd	ra,24(sp)
    800028ec:	e822                	sd	s0,16(sp)
    800028ee:	e426                	sd	s1,8(sp)
    800028f0:	e04a                	sd	s2,0(sp)
    800028f2:	1000                	addi	s0,sp,32
    800028f4:	84ae                	mv	s1,a1
    800028f6:	8932                	mv	s2,a2
  *ip = argraw(n);
    800028f8:	00000097          	auipc	ra,0x0
    800028fc:	eaa080e7          	jalr	-342(ra) # 800027a2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002900:	864a                	mv	a2,s2
    80002902:	85a6                	mv	a1,s1
    80002904:	00000097          	auipc	ra,0x0
    80002908:	f58080e7          	jalr	-168(ra) # 8000285c <fetchstr>
}
    8000290c:	60e2                	ld	ra,24(sp)
    8000290e:	6442                	ld	s0,16(sp)
    80002910:	64a2                	ld	s1,8(sp)
    80002912:	6902                	ld	s2,0(sp)
    80002914:	6105                	addi	sp,sp,32
    80002916:	8082                	ret

0000000080002918 <syscall>:
[SYS_crash]   sys_crash,
};

void
syscall(void)
{
    80002918:	1101                	addi	sp,sp,-32
    8000291a:	ec06                	sd	ra,24(sp)
    8000291c:	e822                	sd	s0,16(sp)
    8000291e:	e426                	sd	s1,8(sp)
    80002920:	e04a                	sd	s2,0(sp)
    80002922:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002924:	fffff097          	auipc	ra,0xfffff
    80002928:	f10080e7          	jalr	-240(ra) # 80001834 <myproc>
    8000292c:	84aa                	mv	s1,a0

  num = p->tf->a7;
    8000292e:	05053903          	ld	s2,80(a0)
    80002932:	0a893783          	ld	a5,168(s2)
    80002936:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000293a:	37fd                	addiw	a5,a5,-1
    8000293c:	4759                	li	a4,22
    8000293e:	00f76f63          	bltu	a4,a5,8000295c <syscall+0x44>
    80002942:	00369713          	slli	a4,a3,0x3
    80002946:	00005797          	auipc	a5,0x5
    8000294a:	fc278793          	addi	a5,a5,-62 # 80007908 <syscalls>
    8000294e:	97ba                	add	a5,a5,a4
    80002950:	639c                	ld	a5,0(a5)
    80002952:	c789                	beqz	a5,8000295c <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002954:	9782                	jalr	a5
    80002956:	06a93823          	sd	a0,112(s2)
    8000295a:	a839                	j	80002978 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000295c:	15048613          	addi	a2,s1,336
    80002960:	58cc                	lw	a1,52(s1)
    80002962:	00005517          	auipc	a0,0x5
    80002966:	b3e50513          	addi	a0,a0,-1218 # 800074a0 <userret+0x410>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c2e080e7          	jalr	-978(ra) # 80000598 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002972:	68bc                	ld	a5,80(s1)
    80002974:	577d                	li	a4,-1
    80002976:	fbb8                	sd	a4,112(a5)
  }
}
    80002978:	60e2                	ld	ra,24(sp)
    8000297a:	6442                	ld	s0,16(sp)
    8000297c:	64a2                	ld	s1,8(sp)
    8000297e:	6902                	ld	s2,0(sp)
    80002980:	6105                	addi	sp,sp,32
    80002982:	8082                	ret

0000000080002984 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002984:	1141                	addi	sp,sp,-16
    80002986:	e406                	sd	ra,8(sp)
    80002988:	e022                	sd	s0,0(sp)
    8000298a:	0800                	addi	s0,sp,16
  exit();
    8000298c:	fffff097          	auipc	ra,0xfffff
    80002990:	594080e7          	jalr	1428(ra) # 80001f20 <exit>
  return 0;  // not reached
}
    80002994:	4501                	li	a0,0
    80002996:	60a2                	ld	ra,8(sp)
    80002998:	6402                	ld	s0,0(sp)
    8000299a:	0141                	addi	sp,sp,16
    8000299c:	8082                	ret

000000008000299e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000299e:	1141                	addi	sp,sp,-16
    800029a0:	e406                	sd	ra,8(sp)
    800029a2:	e022                	sd	s0,0(sp)
    800029a4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	e8e080e7          	jalr	-370(ra) # 80001834 <myproc>
}
    800029ae:	5948                	lw	a0,52(a0)
    800029b0:	60a2                	ld	ra,8(sp)
    800029b2:	6402                	ld	s0,0(sp)
    800029b4:	0141                	addi	sp,sp,16
    800029b6:	8082                	ret

00000000800029b8 <sys_fork>:

uint64
sys_fork(void)
{
    800029b8:	1141                	addi	sp,sp,-16
    800029ba:	e406                	sd	ra,8(sp)
    800029bc:	e022                	sd	s0,0(sp)
    800029be:	0800                	addi	s0,sp,16
  return fork();
    800029c0:	fffff097          	auipc	ra,0xfffff
    800029c4:	1de080e7          	jalr	478(ra) # 80001b9e <fork>
}
    800029c8:	60a2                	ld	ra,8(sp)
    800029ca:	6402                	ld	s0,0(sp)
    800029cc:	0141                	addi	sp,sp,16
    800029ce:	8082                	ret

00000000800029d0 <sys_wait>:

uint64
sys_wait(void)
{
    800029d0:	1141                	addi	sp,sp,-16
    800029d2:	e406                	sd	ra,8(sp)
    800029d4:	e022                	sd	s0,0(sp)
    800029d6:	0800                	addi	s0,sp,16
  return wait();
    800029d8:	fffff097          	auipc	ra,0xfffff
    800029dc:	6e0080e7          	jalr	1760(ra) # 800020b8 <wait>
}
    800029e0:	60a2                	ld	ra,8(sp)
    800029e2:	6402                	ld	s0,0(sp)
    800029e4:	0141                	addi	sp,sp,16
    800029e6:	8082                	ret

00000000800029e8 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029e8:	7179                	addi	sp,sp,-48
    800029ea:	f406                	sd	ra,40(sp)
    800029ec:	f022                	sd	s0,32(sp)
    800029ee:	ec26                	sd	s1,24(sp)
    800029f0:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    800029f2:	fdc40593          	addi	a1,s0,-36
    800029f6:	4501                	li	a0,0
    800029f8:	00000097          	auipc	ra,0x0
    800029fc:	eac080e7          	jalr	-340(ra) # 800028a4 <argint>
    80002a00:	87aa                	mv	a5,a0
    return -1;
    80002a02:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002a04:	0207c063          	bltz	a5,80002a24 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002a08:	fffff097          	auipc	ra,0xfffff
    80002a0c:	e2c080e7          	jalr	-468(ra) # 80001834 <myproc>
    80002a10:	4124                	lw	s1,64(a0)
  if(growproc(n) < 0)
    80002a12:	fdc42503          	lw	a0,-36(s0)
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	110080e7          	jalr	272(ra) # 80001b26 <growproc>
    80002a1e:	00054863          	bltz	a0,80002a2e <sys_sbrk+0x46>
    return -1;
  return addr;
    80002a22:	8526                	mv	a0,s1
}
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6145                	addi	sp,sp,48
    80002a2c:	8082                	ret
    return -1;
    80002a2e:	557d                	li	a0,-1
    80002a30:	bfd5                	j	80002a24 <sys_sbrk+0x3c>

0000000080002a32 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002a32:	7139                	addi	sp,sp,-64
    80002a34:	fc06                	sd	ra,56(sp)
    80002a36:	f822                	sd	s0,48(sp)
    80002a38:	f426                	sd	s1,40(sp)
    80002a3a:	f04a                	sd	s2,32(sp)
    80002a3c:	ec4e                	sd	s3,24(sp)
    80002a3e:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002a40:	fcc40593          	addi	a1,s0,-52
    80002a44:	4501                	li	a0,0
    80002a46:	00000097          	auipc	ra,0x0
    80002a4a:	e5e080e7          	jalr	-418(ra) # 800028a4 <argint>
    return -1;
    80002a4e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002a50:	06054563          	bltz	a0,80002aba <sys_sleep+0x88>
  acquire(&tickslock);
    80002a54:	00015517          	auipc	a0,0x15
    80002a58:	aac50513          	addi	a0,a0,-1364 # 80017500 <tickslock>
    80002a5c:	ffffe097          	auipc	ra,0xffffe
    80002a60:	076080e7          	jalr	118(ra) # 80000ad2 <acquire>
  ticks0 = ticks;
    80002a64:	00026917          	auipc	s2,0x26
    80002a68:	5c492903          	lw	s2,1476(s2) # 80029028 <ticks>
  while(ticks - ticks0 < n){
    80002a6c:	fcc42783          	lw	a5,-52(s0)
    80002a70:	cf85                	beqz	a5,80002aa8 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a72:	00015997          	auipc	s3,0x15
    80002a76:	a8e98993          	addi	s3,s3,-1394 # 80017500 <tickslock>
    80002a7a:	00026497          	auipc	s1,0x26
    80002a7e:	5ae48493          	addi	s1,s1,1454 # 80029028 <ticks>
    if(myproc()->killed){
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	db2080e7          	jalr	-590(ra) # 80001834 <myproc>
    80002a8a:	591c                	lw	a5,48(a0)
    80002a8c:	ef9d                	bnez	a5,80002aca <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002a8e:	85ce                	mv	a1,s3
    80002a90:	8526                	mv	a0,s1
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	5a8080e7          	jalr	1448(ra) # 8000203a <sleep>
  while(ticks - ticks0 < n){
    80002a9a:	409c                	lw	a5,0(s1)
    80002a9c:	412787bb          	subw	a5,a5,s2
    80002aa0:	fcc42703          	lw	a4,-52(s0)
    80002aa4:	fce7efe3          	bltu	a5,a4,80002a82 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002aa8:	00015517          	auipc	a0,0x15
    80002aac:	a5850513          	addi	a0,a0,-1448 # 80017500 <tickslock>
    80002ab0:	ffffe097          	auipc	ra,0xffffe
    80002ab4:	08a080e7          	jalr	138(ra) # 80000b3a <release>
  return 0;
    80002ab8:	4781                	li	a5,0
}
    80002aba:	853e                	mv	a0,a5
    80002abc:	70e2                	ld	ra,56(sp)
    80002abe:	7442                	ld	s0,48(sp)
    80002ac0:	74a2                	ld	s1,40(sp)
    80002ac2:	7902                	ld	s2,32(sp)
    80002ac4:	69e2                	ld	s3,24(sp)
    80002ac6:	6121                	addi	sp,sp,64
    80002ac8:	8082                	ret
      release(&tickslock);
    80002aca:	00015517          	auipc	a0,0x15
    80002ace:	a3650513          	addi	a0,a0,-1482 # 80017500 <tickslock>
    80002ad2:	ffffe097          	auipc	ra,0xffffe
    80002ad6:	068080e7          	jalr	104(ra) # 80000b3a <release>
      return -1;
    80002ada:	57fd                	li	a5,-1
    80002adc:	bff9                	j	80002aba <sys_sleep+0x88>

0000000080002ade <sys_kill>:

uint64
sys_kill(void)
{
    80002ade:	1101                	addi	sp,sp,-32
    80002ae0:	ec06                	sd	ra,24(sp)
    80002ae2:	e822                	sd	s0,16(sp)
    80002ae4:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002ae6:	fec40593          	addi	a1,s0,-20
    80002aea:	4501                	li	a0,0
    80002aec:	00000097          	auipc	ra,0x0
    80002af0:	db8080e7          	jalr	-584(ra) # 800028a4 <argint>
    80002af4:	87aa                	mv	a5,a0
    return -1;
    80002af6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002af8:	0007c863          	bltz	a5,80002b08 <sys_kill+0x2a>
  return kill(pid);
    80002afc:	fec42503          	lw	a0,-20(s0)
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	6f0080e7          	jalr	1776(ra) # 800021f0 <kill>
}
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	6105                	addi	sp,sp,32
    80002b0e:	8082                	ret

0000000080002b10 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b1a:	00015517          	auipc	a0,0x15
    80002b1e:	9e650513          	addi	a0,a0,-1562 # 80017500 <tickslock>
    80002b22:	ffffe097          	auipc	ra,0xffffe
    80002b26:	fb0080e7          	jalr	-80(ra) # 80000ad2 <acquire>
  xticks = ticks;
    80002b2a:	00026497          	auipc	s1,0x26
    80002b2e:	4fe4a483          	lw	s1,1278(s1) # 80029028 <ticks>
  release(&tickslock);
    80002b32:	00015517          	auipc	a0,0x15
    80002b36:	9ce50513          	addi	a0,a0,-1586 # 80017500 <tickslock>
    80002b3a:	ffffe097          	auipc	ra,0xffffe
    80002b3e:	000080e7          	jalr	ra # 80000b3a <release>
  return xticks;
}
    80002b42:	02049513          	slli	a0,s1,0x20
    80002b46:	9101                	srli	a0,a0,0x20
    80002b48:	60e2                	ld	ra,24(sp)
    80002b4a:	6442                	ld	s0,16(sp)
    80002b4c:	64a2                	ld	s1,8(sp)
    80002b4e:	6105                	addi	sp,sp,32
    80002b50:	8082                	ret

0000000080002b52 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b52:	7179                	addi	sp,sp,-48
    80002b54:	f406                	sd	ra,40(sp)
    80002b56:	f022                	sd	s0,32(sp)
    80002b58:	ec26                	sd	s1,24(sp)
    80002b5a:	e84a                	sd	s2,16(sp)
    80002b5c:	e44e                	sd	s3,8(sp)
    80002b5e:	e052                	sd	s4,0(sp)
    80002b60:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b62:	00005597          	auipc	a1,0x5
    80002b66:	95e58593          	addi	a1,a1,-1698 # 800074c0 <userret+0x430>
    80002b6a:	00015517          	auipc	a0,0x15
    80002b6e:	9ae50513          	addi	a0,a0,-1618 # 80017518 <bcache>
    80002b72:	ffffe097          	auipc	ra,0xffffe
    80002b76:	e4e080e7          	jalr	-434(ra) # 800009c0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b7a:	0001d797          	auipc	a5,0x1d
    80002b7e:	99e78793          	addi	a5,a5,-1634 # 8001f518 <bcache+0x8000>
    80002b82:	0001d717          	auipc	a4,0x1d
    80002b86:	cee70713          	addi	a4,a4,-786 # 8001f870 <bcache+0x8358>
    80002b8a:	3ae7b023          	sd	a4,928(a5)
  bcache.head.next = &bcache.head;
    80002b8e:	3ae7b423          	sd	a4,936(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b92:	00015497          	auipc	s1,0x15
    80002b96:	99e48493          	addi	s1,s1,-1634 # 80017530 <bcache+0x18>
    b->next = bcache.head.next;
    80002b9a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b9c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b9e:	00005a17          	auipc	s4,0x5
    80002ba2:	92aa0a13          	addi	s4,s4,-1750 # 800074c8 <userret+0x438>
    b->next = bcache.head.next;
    80002ba6:	3a893783          	ld	a5,936(s2)
    80002baa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bac:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bb0:	85d2                	mv	a1,s4
    80002bb2:	01048513          	addi	a0,s1,16
    80002bb6:	00001097          	auipc	ra,0x1
    80002bba:	6f2080e7          	jalr	1778(ra) # 800042a8 <initsleeplock>
    bcache.head.next->prev = b;
    80002bbe:	3a893783          	ld	a5,936(s2)
    80002bc2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bc4:	3a993423          	sd	s1,936(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bc8:	46048493          	addi	s1,s1,1120
    80002bcc:	fd349de3          	bne	s1,s3,80002ba6 <binit+0x54>
  }
}
    80002bd0:	70a2                	ld	ra,40(sp)
    80002bd2:	7402                	ld	s0,32(sp)
    80002bd4:	64e2                	ld	s1,24(sp)
    80002bd6:	6942                	ld	s2,16(sp)
    80002bd8:	69a2                	ld	s3,8(sp)
    80002bda:	6a02                	ld	s4,0(sp)
    80002bdc:	6145                	addi	sp,sp,48
    80002bde:	8082                	ret

0000000080002be0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002be0:	7179                	addi	sp,sp,-48
    80002be2:	f406                	sd	ra,40(sp)
    80002be4:	f022                	sd	s0,32(sp)
    80002be6:	ec26                	sd	s1,24(sp)
    80002be8:	e84a                	sd	s2,16(sp)
    80002bea:	e44e                	sd	s3,8(sp)
    80002bec:	1800                	addi	s0,sp,48
    80002bee:	89aa                	mv	s3,a0
    80002bf0:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002bf2:	00015517          	auipc	a0,0x15
    80002bf6:	92650513          	addi	a0,a0,-1754 # 80017518 <bcache>
    80002bfa:	ffffe097          	auipc	ra,0xffffe
    80002bfe:	ed8080e7          	jalr	-296(ra) # 80000ad2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c02:	0001d497          	auipc	s1,0x1d
    80002c06:	cbe4b483          	ld	s1,-834(s1) # 8001f8c0 <bcache+0x83a8>
    80002c0a:	0001d797          	auipc	a5,0x1d
    80002c0e:	c6678793          	addi	a5,a5,-922 # 8001f870 <bcache+0x8358>
    80002c12:	02f48f63          	beq	s1,a5,80002c50 <bread+0x70>
    80002c16:	873e                	mv	a4,a5
    80002c18:	a021                	j	80002c20 <bread+0x40>
    80002c1a:	68a4                	ld	s1,80(s1)
    80002c1c:	02e48a63          	beq	s1,a4,80002c50 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002c20:	449c                	lw	a5,8(s1)
    80002c22:	ff379ce3          	bne	a5,s3,80002c1a <bread+0x3a>
    80002c26:	44dc                	lw	a5,12(s1)
    80002c28:	ff2799e3          	bne	a5,s2,80002c1a <bread+0x3a>
      b->refcnt++;
    80002c2c:	40bc                	lw	a5,64(s1)
    80002c2e:	2785                	addiw	a5,a5,1
    80002c30:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c32:	00015517          	auipc	a0,0x15
    80002c36:	8e650513          	addi	a0,a0,-1818 # 80017518 <bcache>
    80002c3a:	ffffe097          	auipc	ra,0xffffe
    80002c3e:	f00080e7          	jalr	-256(ra) # 80000b3a <release>
      acquiresleep(&b->lock);
    80002c42:	01048513          	addi	a0,s1,16
    80002c46:	00001097          	auipc	ra,0x1
    80002c4a:	69c080e7          	jalr	1692(ra) # 800042e2 <acquiresleep>
      return b;
    80002c4e:	a8b9                	j	80002cac <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c50:	0001d497          	auipc	s1,0x1d
    80002c54:	c684b483          	ld	s1,-920(s1) # 8001f8b8 <bcache+0x83a0>
    80002c58:	0001d797          	auipc	a5,0x1d
    80002c5c:	c1878793          	addi	a5,a5,-1000 # 8001f870 <bcache+0x8358>
    80002c60:	00f48863          	beq	s1,a5,80002c70 <bread+0x90>
    80002c64:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c66:	40bc                	lw	a5,64(s1)
    80002c68:	cf81                	beqz	a5,80002c80 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c6a:	64a4                	ld	s1,72(s1)
    80002c6c:	fee49de3          	bne	s1,a4,80002c66 <bread+0x86>
  panic("bget: no buffers");
    80002c70:	00005517          	auipc	a0,0x5
    80002c74:	86050513          	addi	a0,a0,-1952 # 800074d0 <userret+0x440>
    80002c78:	ffffe097          	auipc	ra,0xffffe
    80002c7c:	8d6080e7          	jalr	-1834(ra) # 8000054e <panic>
      b->dev = dev;
    80002c80:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002c84:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002c88:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c8c:	4785                	li	a5,1
    80002c8e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c90:	00015517          	auipc	a0,0x15
    80002c94:	88850513          	addi	a0,a0,-1912 # 80017518 <bcache>
    80002c98:	ffffe097          	auipc	ra,0xffffe
    80002c9c:	ea2080e7          	jalr	-350(ra) # 80000b3a <release>
      acquiresleep(&b->lock);
    80002ca0:	01048513          	addi	a0,s1,16
    80002ca4:	00001097          	auipc	ra,0x1
    80002ca8:	63e080e7          	jalr	1598(ra) # 800042e2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002cac:	409c                	lw	a5,0(s1)
    80002cae:	cb89                	beqz	a5,80002cc0 <bread+0xe0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    80002cb0:	8526                	mv	a0,s1
    80002cb2:	70a2                	ld	ra,40(sp)
    80002cb4:	7402                	ld	s0,32(sp)
    80002cb6:	64e2                	ld	s1,24(sp)
    80002cb8:	6942                	ld	s2,16(sp)
    80002cba:	69a2                	ld	s3,8(sp)
    80002cbc:	6145                	addi	sp,sp,48
    80002cbe:	8082                	ret
    virtio_disk_rw(b->dev, b, 0);
    80002cc0:	4601                	li	a2,0
    80002cc2:	85a6                	mv	a1,s1
    80002cc4:	4488                	lw	a0,8(s1)
    80002cc6:	00003097          	auipc	ra,0x3
    80002cca:	286080e7          	jalr	646(ra) # 80005f4c <virtio_disk_rw>
    b->valid = 1;
    80002cce:	4785                	li	a5,1
    80002cd0:	c09c                	sw	a5,0(s1)
  return b;
    80002cd2:	bff9                	j	80002cb0 <bread+0xd0>

0000000080002cd4 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	1000                	addi	s0,sp,32
    80002cde:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ce0:	0541                	addi	a0,a0,16
    80002ce2:	00001097          	auipc	ra,0x1
    80002ce6:	69a080e7          	jalr	1690(ra) # 8000437c <holdingsleep>
    80002cea:	cd09                	beqz	a0,80002d04 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    80002cec:	4605                	li	a2,1
    80002cee:	85a6                	mv	a1,s1
    80002cf0:	4488                	lw	a0,8(s1)
    80002cf2:	00003097          	auipc	ra,0x3
    80002cf6:	25a080e7          	jalr	602(ra) # 80005f4c <virtio_disk_rw>
}
    80002cfa:	60e2                	ld	ra,24(sp)
    80002cfc:	6442                	ld	s0,16(sp)
    80002cfe:	64a2                	ld	s1,8(sp)
    80002d00:	6105                	addi	sp,sp,32
    80002d02:	8082                	ret
    panic("bwrite");
    80002d04:	00004517          	auipc	a0,0x4
    80002d08:	7e450513          	addi	a0,a0,2020 # 800074e8 <userret+0x458>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	842080e7          	jalr	-1982(ra) # 8000054e <panic>

0000000080002d14 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80002d14:	1101                	addi	sp,sp,-32
    80002d16:	ec06                	sd	ra,24(sp)
    80002d18:	e822                	sd	s0,16(sp)
    80002d1a:	e426                	sd	s1,8(sp)
    80002d1c:	e04a                	sd	s2,0(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002d22:	01050913          	addi	s2,a0,16
    80002d26:	854a                	mv	a0,s2
    80002d28:	00001097          	auipc	ra,0x1
    80002d2c:	654080e7          	jalr	1620(ra) # 8000437c <holdingsleep>
    80002d30:	c92d                	beqz	a0,80002da2 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002d32:	854a                	mv	a0,s2
    80002d34:	00001097          	auipc	ra,0x1
    80002d38:	604080e7          	jalr	1540(ra) # 80004338 <releasesleep>

  acquire(&bcache.lock);
    80002d3c:	00014517          	auipc	a0,0x14
    80002d40:	7dc50513          	addi	a0,a0,2012 # 80017518 <bcache>
    80002d44:	ffffe097          	auipc	ra,0xffffe
    80002d48:	d8e080e7          	jalr	-626(ra) # 80000ad2 <acquire>
  b->refcnt--;
    80002d4c:	40bc                	lw	a5,64(s1)
    80002d4e:	37fd                	addiw	a5,a5,-1
    80002d50:	0007871b          	sext.w	a4,a5
    80002d54:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d56:	eb05                	bnez	a4,80002d86 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002d58:	68bc                	ld	a5,80(s1)
    80002d5a:	64b8                	ld	a4,72(s1)
    80002d5c:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002d5e:	64bc                	ld	a5,72(s1)
    80002d60:	68b8                	ld	a4,80(s1)
    80002d62:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d64:	0001c797          	auipc	a5,0x1c
    80002d68:	7b478793          	addi	a5,a5,1972 # 8001f518 <bcache+0x8000>
    80002d6c:	3a87b703          	ld	a4,936(a5)
    80002d70:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d72:	0001d717          	auipc	a4,0x1d
    80002d76:	afe70713          	addi	a4,a4,-1282 # 8001f870 <bcache+0x8358>
    80002d7a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d7c:	3a87b703          	ld	a4,936(a5)
    80002d80:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d82:	3a97b423          	sd	s1,936(a5)
  }
  
  release(&bcache.lock);
    80002d86:	00014517          	auipc	a0,0x14
    80002d8a:	79250513          	addi	a0,a0,1938 # 80017518 <bcache>
    80002d8e:	ffffe097          	auipc	ra,0xffffe
    80002d92:	dac080e7          	jalr	-596(ra) # 80000b3a <release>
}
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	64a2                	ld	s1,8(sp)
    80002d9c:	6902                	ld	s2,0(sp)
    80002d9e:	6105                	addi	sp,sp,32
    80002da0:	8082                	ret
    panic("brelse");
    80002da2:	00004517          	auipc	a0,0x4
    80002da6:	74e50513          	addi	a0,a0,1870 # 800074f0 <userret+0x460>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	7a4080e7          	jalr	1956(ra) # 8000054e <panic>

0000000080002db2 <bpin>:

void
bpin(struct buf *b) {
    80002db2:	1101                	addi	sp,sp,-32
    80002db4:	ec06                	sd	ra,24(sp)
    80002db6:	e822                	sd	s0,16(sp)
    80002db8:	e426                	sd	s1,8(sp)
    80002dba:	1000                	addi	s0,sp,32
    80002dbc:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dbe:	00014517          	auipc	a0,0x14
    80002dc2:	75a50513          	addi	a0,a0,1882 # 80017518 <bcache>
    80002dc6:	ffffe097          	auipc	ra,0xffffe
    80002dca:	d0c080e7          	jalr	-756(ra) # 80000ad2 <acquire>
  b->refcnt++;
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	2785                	addiw	a5,a5,1
    80002dd2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dd4:	00014517          	auipc	a0,0x14
    80002dd8:	74450513          	addi	a0,a0,1860 # 80017518 <bcache>
    80002ddc:	ffffe097          	auipc	ra,0xffffe
    80002de0:	d5e080e7          	jalr	-674(ra) # 80000b3a <release>
}
    80002de4:	60e2                	ld	ra,24(sp)
    80002de6:	6442                	ld	s0,16(sp)
    80002de8:	64a2                	ld	s1,8(sp)
    80002dea:	6105                	addi	sp,sp,32
    80002dec:	8082                	ret

0000000080002dee <bunpin>:

void
bunpin(struct buf *b) {
    80002dee:	1101                	addi	sp,sp,-32
    80002df0:	ec06                	sd	ra,24(sp)
    80002df2:	e822                	sd	s0,16(sp)
    80002df4:	e426                	sd	s1,8(sp)
    80002df6:	1000                	addi	s0,sp,32
    80002df8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dfa:	00014517          	auipc	a0,0x14
    80002dfe:	71e50513          	addi	a0,a0,1822 # 80017518 <bcache>
    80002e02:	ffffe097          	auipc	ra,0xffffe
    80002e06:	cd0080e7          	jalr	-816(ra) # 80000ad2 <acquire>
  b->refcnt--;
    80002e0a:	40bc                	lw	a5,64(s1)
    80002e0c:	37fd                	addiw	a5,a5,-1
    80002e0e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002e10:	00014517          	auipc	a0,0x14
    80002e14:	70850513          	addi	a0,a0,1800 # 80017518 <bcache>
    80002e18:	ffffe097          	auipc	ra,0xffffe
    80002e1c:	d22080e7          	jalr	-734(ra) # 80000b3a <release>
}
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	64a2                	ld	s1,8(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret

0000000080002e2a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	e04a                	sd	s2,0(sp)
    80002e34:	1000                	addi	s0,sp,32
    80002e36:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002e38:	00d5d59b          	srliw	a1,a1,0xd
    80002e3c:	0001d797          	auipc	a5,0x1d
    80002e40:	eb07a783          	lw	a5,-336(a5) # 8001fcec <sb+0x1c>
    80002e44:	9dbd                	addw	a1,a1,a5
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	d9a080e7          	jalr	-614(ra) # 80002be0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e4e:	0074f713          	andi	a4,s1,7
    80002e52:	4785                	li	a5,1
    80002e54:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002e58:	14ce                	slli	s1,s1,0x33
    80002e5a:	90d9                	srli	s1,s1,0x36
    80002e5c:	00950733          	add	a4,a0,s1
    80002e60:	06074703          	lbu	a4,96(a4)
    80002e64:	00e7f6b3          	and	a3,a5,a4
    80002e68:	c69d                	beqz	a3,80002e96 <bfree+0x6c>
    80002e6a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e6c:	94aa                	add	s1,s1,a0
    80002e6e:	fff7c793          	not	a5,a5
    80002e72:	8ff9                	and	a5,a5,a4
    80002e74:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    80002e78:	00001097          	auipc	ra,0x1
    80002e7c:	1d2080e7          	jalr	466(ra) # 8000404a <log_write>
  brelse(bp);
    80002e80:	854a                	mv	a0,s2
    80002e82:	00000097          	auipc	ra,0x0
    80002e86:	e92080e7          	jalr	-366(ra) # 80002d14 <brelse>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	64a2                	ld	s1,8(sp)
    80002e90:	6902                	ld	s2,0(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret
    panic("freeing free block");
    80002e96:	00004517          	auipc	a0,0x4
    80002e9a:	66250513          	addi	a0,a0,1634 # 800074f8 <userret+0x468>
    80002e9e:	ffffd097          	auipc	ra,0xffffd
    80002ea2:	6b0080e7          	jalr	1712(ra) # 8000054e <panic>

0000000080002ea6 <balloc>:
{
    80002ea6:	711d                	addi	sp,sp,-96
    80002ea8:	ec86                	sd	ra,88(sp)
    80002eaa:	e8a2                	sd	s0,80(sp)
    80002eac:	e4a6                	sd	s1,72(sp)
    80002eae:	e0ca                	sd	s2,64(sp)
    80002eb0:	fc4e                	sd	s3,56(sp)
    80002eb2:	f852                	sd	s4,48(sp)
    80002eb4:	f456                	sd	s5,40(sp)
    80002eb6:	f05a                	sd	s6,32(sp)
    80002eb8:	ec5e                	sd	s7,24(sp)
    80002eba:	e862                	sd	s8,16(sp)
    80002ebc:	e466                	sd	s9,8(sp)
    80002ebe:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002ec0:	0001d797          	auipc	a5,0x1d
    80002ec4:	e147a783          	lw	a5,-492(a5) # 8001fcd4 <sb+0x4>
    80002ec8:	cbd1                	beqz	a5,80002f5c <balloc+0xb6>
    80002eca:	8baa                	mv	s7,a0
    80002ecc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002ece:	0001db17          	auipc	s6,0x1d
    80002ed2:	e02b0b13          	addi	s6,s6,-510 # 8001fcd0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ed6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002ed8:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eda:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002edc:	6c89                	lui	s9,0x2
    80002ede:	a831                	j	80002efa <balloc+0x54>
    brelse(bp);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	e32080e7          	jalr	-462(ra) # 80002d14 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002eea:	015c87bb          	addw	a5,s9,s5
    80002eee:	00078a9b          	sext.w	s5,a5
    80002ef2:	004b2703          	lw	a4,4(s6)
    80002ef6:	06eaf363          	bgeu	s5,a4,80002f5c <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80002efa:	41fad79b          	sraiw	a5,s5,0x1f
    80002efe:	0137d79b          	srliw	a5,a5,0x13
    80002f02:	015787bb          	addw	a5,a5,s5
    80002f06:	40d7d79b          	sraiw	a5,a5,0xd
    80002f0a:	01cb2583          	lw	a1,28(s6)
    80002f0e:	9dbd                	addw	a1,a1,a5
    80002f10:	855e                	mv	a0,s7
    80002f12:	00000097          	auipc	ra,0x0
    80002f16:	cce080e7          	jalr	-818(ra) # 80002be0 <bread>
    80002f1a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f1c:	004b2503          	lw	a0,4(s6)
    80002f20:	000a849b          	sext.w	s1,s5
    80002f24:	8662                	mv	a2,s8
    80002f26:	faa4fde3          	bgeu	s1,a0,80002ee0 <balloc+0x3a>
      m = 1 << (bi % 8);
    80002f2a:	41f6579b          	sraiw	a5,a2,0x1f
    80002f2e:	01d7d69b          	srliw	a3,a5,0x1d
    80002f32:	00c6873b          	addw	a4,a3,a2
    80002f36:	00777793          	andi	a5,a4,7
    80002f3a:	9f95                	subw	a5,a5,a3
    80002f3c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f40:	4037571b          	sraiw	a4,a4,0x3
    80002f44:	00e906b3          	add	a3,s2,a4
    80002f48:	0606c683          	lbu	a3,96(a3)
    80002f4c:	00d7f5b3          	and	a1,a5,a3
    80002f50:	cd91                	beqz	a1,80002f6c <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f52:	2605                	addiw	a2,a2,1
    80002f54:	2485                	addiw	s1,s1,1
    80002f56:	fd4618e3          	bne	a2,s4,80002f26 <balloc+0x80>
    80002f5a:	b759                	j	80002ee0 <balloc+0x3a>
  panic("balloc: out of blocks");
    80002f5c:	00004517          	auipc	a0,0x4
    80002f60:	5b450513          	addi	a0,a0,1460 # 80007510 <userret+0x480>
    80002f64:	ffffd097          	auipc	ra,0xffffd
    80002f68:	5ea080e7          	jalr	1514(ra) # 8000054e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002f6c:	974a                	add	a4,a4,s2
    80002f6e:	8fd5                	or	a5,a5,a3
    80002f70:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    80002f74:	854a                	mv	a0,s2
    80002f76:	00001097          	auipc	ra,0x1
    80002f7a:	0d4080e7          	jalr	212(ra) # 8000404a <log_write>
        brelse(bp);
    80002f7e:	854a                	mv	a0,s2
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	d94080e7          	jalr	-620(ra) # 80002d14 <brelse>
  bp = bread(dev, bno);
    80002f88:	85a6                	mv	a1,s1
    80002f8a:	855e                	mv	a0,s7
    80002f8c:	00000097          	auipc	ra,0x0
    80002f90:	c54080e7          	jalr	-940(ra) # 80002be0 <bread>
    80002f94:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002f96:	40000613          	li	a2,1024
    80002f9a:	4581                	li	a1,0
    80002f9c:	06050513          	addi	a0,a0,96
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	bf6080e7          	jalr	-1034(ra) # 80000b96 <memset>
  log_write(bp);
    80002fa8:	854a                	mv	a0,s2
    80002faa:	00001097          	auipc	ra,0x1
    80002fae:	0a0080e7          	jalr	160(ra) # 8000404a <log_write>
  brelse(bp);
    80002fb2:	854a                	mv	a0,s2
    80002fb4:	00000097          	auipc	ra,0x0
    80002fb8:	d60080e7          	jalr	-672(ra) # 80002d14 <brelse>
}
    80002fbc:	8526                	mv	a0,s1
    80002fbe:	60e6                	ld	ra,88(sp)
    80002fc0:	6446                	ld	s0,80(sp)
    80002fc2:	64a6                	ld	s1,72(sp)
    80002fc4:	6906                	ld	s2,64(sp)
    80002fc6:	79e2                	ld	s3,56(sp)
    80002fc8:	7a42                	ld	s4,48(sp)
    80002fca:	7aa2                	ld	s5,40(sp)
    80002fcc:	7b02                	ld	s6,32(sp)
    80002fce:	6be2                	ld	s7,24(sp)
    80002fd0:	6c42                	ld	s8,16(sp)
    80002fd2:	6ca2                	ld	s9,8(sp)
    80002fd4:	6125                	addi	sp,sp,96
    80002fd6:	8082                	ret

0000000080002fd8 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80002fd8:	7179                	addi	sp,sp,-48
    80002fda:	f406                	sd	ra,40(sp)
    80002fdc:	f022                	sd	s0,32(sp)
    80002fde:	ec26                	sd	s1,24(sp)
    80002fe0:	e84a                	sd	s2,16(sp)
    80002fe2:	e44e                	sd	s3,8(sp)
    80002fe4:	e052                	sd	s4,0(sp)
    80002fe6:	1800                	addi	s0,sp,48
    80002fe8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002fea:	47ad                	li	a5,11
    80002fec:	04b7fe63          	bgeu	a5,a1,80003048 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80002ff0:	ff45849b          	addiw	s1,a1,-12
    80002ff4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002ff8:	0ff00793          	li	a5,255
    80002ffc:	0ae7e363          	bltu	a5,a4,800030a2 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003000:	08052583          	lw	a1,128(a0)
    80003004:	c5ad                	beqz	a1,8000306e <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003006:	00092503          	lw	a0,0(s2)
    8000300a:	00000097          	auipc	ra,0x0
    8000300e:	bd6080e7          	jalr	-1066(ra) # 80002be0 <bread>
    80003012:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003014:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    80003018:	02049593          	slli	a1,s1,0x20
    8000301c:	9181                	srli	a1,a1,0x20
    8000301e:	058a                	slli	a1,a1,0x2
    80003020:	00b784b3          	add	s1,a5,a1
    80003024:	0004a983          	lw	s3,0(s1)
    80003028:	04098d63          	beqz	s3,80003082 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000302c:	8552                	mv	a0,s4
    8000302e:	00000097          	auipc	ra,0x0
    80003032:	ce6080e7          	jalr	-794(ra) # 80002d14 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003036:	854e                	mv	a0,s3
    80003038:	70a2                	ld	ra,40(sp)
    8000303a:	7402                	ld	s0,32(sp)
    8000303c:	64e2                	ld	s1,24(sp)
    8000303e:	6942                	ld	s2,16(sp)
    80003040:	69a2                	ld	s3,8(sp)
    80003042:	6a02                	ld	s4,0(sp)
    80003044:	6145                	addi	sp,sp,48
    80003046:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80003048:	02059493          	slli	s1,a1,0x20
    8000304c:	9081                	srli	s1,s1,0x20
    8000304e:	048a                	slli	s1,s1,0x2
    80003050:	94aa                	add	s1,s1,a0
    80003052:	0504a983          	lw	s3,80(s1)
    80003056:	fe0990e3          	bnez	s3,80003036 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000305a:	4108                	lw	a0,0(a0)
    8000305c:	00000097          	auipc	ra,0x0
    80003060:	e4a080e7          	jalr	-438(ra) # 80002ea6 <balloc>
    80003064:	0005099b          	sext.w	s3,a0
    80003068:	0534a823          	sw	s3,80(s1)
    8000306c:	b7e9                	j	80003036 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000306e:	4108                	lw	a0,0(a0)
    80003070:	00000097          	auipc	ra,0x0
    80003074:	e36080e7          	jalr	-458(ra) # 80002ea6 <balloc>
    80003078:	0005059b          	sext.w	a1,a0
    8000307c:	08b92023          	sw	a1,128(s2)
    80003080:	b759                	j	80003006 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003082:	00092503          	lw	a0,0(s2)
    80003086:	00000097          	auipc	ra,0x0
    8000308a:	e20080e7          	jalr	-480(ra) # 80002ea6 <balloc>
    8000308e:	0005099b          	sext.w	s3,a0
    80003092:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003096:	8552                	mv	a0,s4
    80003098:	00001097          	auipc	ra,0x1
    8000309c:	fb2080e7          	jalr	-78(ra) # 8000404a <log_write>
    800030a0:	b771                	j	8000302c <bmap+0x54>
  panic("bmap: out of range");
    800030a2:	00004517          	auipc	a0,0x4
    800030a6:	48650513          	addi	a0,a0,1158 # 80007528 <userret+0x498>
    800030aa:	ffffd097          	auipc	ra,0xffffd
    800030ae:	4a4080e7          	jalr	1188(ra) # 8000054e <panic>

00000000800030b2 <iget>:
{
    800030b2:	7179                	addi	sp,sp,-48
    800030b4:	f406                	sd	ra,40(sp)
    800030b6:	f022                	sd	s0,32(sp)
    800030b8:	ec26                	sd	s1,24(sp)
    800030ba:	e84a                	sd	s2,16(sp)
    800030bc:	e44e                	sd	s3,8(sp)
    800030be:	e052                	sd	s4,0(sp)
    800030c0:	1800                	addi	s0,sp,48
    800030c2:	89aa                	mv	s3,a0
    800030c4:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800030c6:	0001d517          	auipc	a0,0x1d
    800030ca:	c2a50513          	addi	a0,a0,-982 # 8001fcf0 <icache>
    800030ce:	ffffe097          	auipc	ra,0xffffe
    800030d2:	a04080e7          	jalr	-1532(ra) # 80000ad2 <acquire>
  empty = 0;
    800030d6:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800030d8:	0001d497          	auipc	s1,0x1d
    800030dc:	c3048493          	addi	s1,s1,-976 # 8001fd08 <icache+0x18>
    800030e0:	0001e697          	auipc	a3,0x1e
    800030e4:	6b868693          	addi	a3,a3,1720 # 80021798 <log>
    800030e8:	a039                	j	800030f6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800030ea:	02090b63          	beqz	s2,80003120 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800030ee:	08848493          	addi	s1,s1,136
    800030f2:	02d48a63          	beq	s1,a3,80003126 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800030f6:	449c                	lw	a5,8(s1)
    800030f8:	fef059e3          	blez	a5,800030ea <iget+0x38>
    800030fc:	4098                	lw	a4,0(s1)
    800030fe:	ff3716e3          	bne	a4,s3,800030ea <iget+0x38>
    80003102:	40d8                	lw	a4,4(s1)
    80003104:	ff4713e3          	bne	a4,s4,800030ea <iget+0x38>
      ip->ref++;
    80003108:	2785                	addiw	a5,a5,1
    8000310a:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000310c:	0001d517          	auipc	a0,0x1d
    80003110:	be450513          	addi	a0,a0,-1052 # 8001fcf0 <icache>
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	a26080e7          	jalr	-1498(ra) # 80000b3a <release>
      return ip;
    8000311c:	8926                	mv	s2,s1
    8000311e:	a03d                	j	8000314c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003120:	f7f9                	bnez	a5,800030ee <iget+0x3c>
    80003122:	8926                	mv	s2,s1
    80003124:	b7e9                	j	800030ee <iget+0x3c>
  if(empty == 0)
    80003126:	02090c63          	beqz	s2,8000315e <iget+0xac>
  ip->dev = dev;
    8000312a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000312e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003132:	4785                	li	a5,1
    80003134:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003138:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000313c:	0001d517          	auipc	a0,0x1d
    80003140:	bb450513          	addi	a0,a0,-1100 # 8001fcf0 <icache>
    80003144:	ffffe097          	auipc	ra,0xffffe
    80003148:	9f6080e7          	jalr	-1546(ra) # 80000b3a <release>
}
    8000314c:	854a                	mv	a0,s2
    8000314e:	70a2                	ld	ra,40(sp)
    80003150:	7402                	ld	s0,32(sp)
    80003152:	64e2                	ld	s1,24(sp)
    80003154:	6942                	ld	s2,16(sp)
    80003156:	69a2                	ld	s3,8(sp)
    80003158:	6a02                	ld	s4,0(sp)
    8000315a:	6145                	addi	sp,sp,48
    8000315c:	8082                	ret
    panic("iget: no inodes");
    8000315e:	00004517          	auipc	a0,0x4
    80003162:	3e250513          	addi	a0,a0,994 # 80007540 <userret+0x4b0>
    80003166:	ffffd097          	auipc	ra,0xffffd
    8000316a:	3e8080e7          	jalr	1000(ra) # 8000054e <panic>

000000008000316e <fsinit>:
fsinit(int dev) {
    8000316e:	7179                	addi	sp,sp,-48
    80003170:	f406                	sd	ra,40(sp)
    80003172:	f022                	sd	s0,32(sp)
    80003174:	ec26                	sd	s1,24(sp)
    80003176:	e84a                	sd	s2,16(sp)
    80003178:	e44e                	sd	s3,8(sp)
    8000317a:	1800                	addi	s0,sp,48
    8000317c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000317e:	4585                	li	a1,1
    80003180:	00000097          	auipc	ra,0x0
    80003184:	a60080e7          	jalr	-1440(ra) # 80002be0 <bread>
    80003188:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000318a:	0001d997          	auipc	s3,0x1d
    8000318e:	b4698993          	addi	s3,s3,-1210 # 8001fcd0 <sb>
    80003192:	02000613          	li	a2,32
    80003196:	06050593          	addi	a1,a0,96
    8000319a:	854e                	mv	a0,s3
    8000319c:	ffffe097          	auipc	ra,0xffffe
    800031a0:	a5a080e7          	jalr	-1446(ra) # 80000bf6 <memmove>
  brelse(bp);
    800031a4:	8526                	mv	a0,s1
    800031a6:	00000097          	auipc	ra,0x0
    800031aa:	b6e080e7          	jalr	-1170(ra) # 80002d14 <brelse>
  if(sb.magic != FSMAGIC)
    800031ae:	0009a703          	lw	a4,0(s3)
    800031b2:	102037b7          	lui	a5,0x10203
    800031b6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800031ba:	02f71263          	bne	a4,a5,800031de <fsinit+0x70>
  initlog(dev, &sb);
    800031be:	0001d597          	auipc	a1,0x1d
    800031c2:	b1258593          	addi	a1,a1,-1262 # 8001fcd0 <sb>
    800031c6:	854a                	mv	a0,s2
    800031c8:	00001097          	auipc	ra,0x1
    800031cc:	bfc080e7          	jalr	-1028(ra) # 80003dc4 <initlog>
}
    800031d0:	70a2                	ld	ra,40(sp)
    800031d2:	7402                	ld	s0,32(sp)
    800031d4:	64e2                	ld	s1,24(sp)
    800031d6:	6942                	ld	s2,16(sp)
    800031d8:	69a2                	ld	s3,8(sp)
    800031da:	6145                	addi	sp,sp,48
    800031dc:	8082                	ret
    panic("invalid file system");
    800031de:	00004517          	auipc	a0,0x4
    800031e2:	37250513          	addi	a0,a0,882 # 80007550 <userret+0x4c0>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	368080e7          	jalr	872(ra) # 8000054e <panic>

00000000800031ee <iinit>:
{
    800031ee:	7179                	addi	sp,sp,-48
    800031f0:	f406                	sd	ra,40(sp)
    800031f2:	f022                	sd	s0,32(sp)
    800031f4:	ec26                	sd	s1,24(sp)
    800031f6:	e84a                	sd	s2,16(sp)
    800031f8:	e44e                	sd	s3,8(sp)
    800031fa:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800031fc:	00004597          	auipc	a1,0x4
    80003200:	36c58593          	addi	a1,a1,876 # 80007568 <userret+0x4d8>
    80003204:	0001d517          	auipc	a0,0x1d
    80003208:	aec50513          	addi	a0,a0,-1300 # 8001fcf0 <icache>
    8000320c:	ffffd097          	auipc	ra,0xffffd
    80003210:	7b4080e7          	jalr	1972(ra) # 800009c0 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003214:	0001d497          	auipc	s1,0x1d
    80003218:	b0448493          	addi	s1,s1,-1276 # 8001fd18 <icache+0x28>
    8000321c:	0001e997          	auipc	s3,0x1e
    80003220:	58c98993          	addi	s3,s3,1420 # 800217a8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003224:	00004917          	auipc	s2,0x4
    80003228:	34c90913          	addi	s2,s2,844 # 80007570 <userret+0x4e0>
    8000322c:	85ca                	mv	a1,s2
    8000322e:	8526                	mv	a0,s1
    80003230:	00001097          	auipc	ra,0x1
    80003234:	078080e7          	jalr	120(ra) # 800042a8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003238:	08848493          	addi	s1,s1,136
    8000323c:	ff3498e3          	bne	s1,s3,8000322c <iinit+0x3e>
}
    80003240:	70a2                	ld	ra,40(sp)
    80003242:	7402                	ld	s0,32(sp)
    80003244:	64e2                	ld	s1,24(sp)
    80003246:	6942                	ld	s2,16(sp)
    80003248:	69a2                	ld	s3,8(sp)
    8000324a:	6145                	addi	sp,sp,48
    8000324c:	8082                	ret

000000008000324e <ialloc>:
{
    8000324e:	715d                	addi	sp,sp,-80
    80003250:	e486                	sd	ra,72(sp)
    80003252:	e0a2                	sd	s0,64(sp)
    80003254:	fc26                	sd	s1,56(sp)
    80003256:	f84a                	sd	s2,48(sp)
    80003258:	f44e                	sd	s3,40(sp)
    8000325a:	f052                	sd	s4,32(sp)
    8000325c:	ec56                	sd	s5,24(sp)
    8000325e:	e85a                	sd	s6,16(sp)
    80003260:	e45e                	sd	s7,8(sp)
    80003262:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003264:	0001d717          	auipc	a4,0x1d
    80003268:	a7872703          	lw	a4,-1416(a4) # 8001fcdc <sb+0xc>
    8000326c:	4785                	li	a5,1
    8000326e:	04e7fa63          	bgeu	a5,a4,800032c2 <ialloc+0x74>
    80003272:	8aaa                	mv	s5,a0
    80003274:	8bae                	mv	s7,a1
    80003276:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003278:	0001da17          	auipc	s4,0x1d
    8000327c:	a58a0a13          	addi	s4,s4,-1448 # 8001fcd0 <sb>
    80003280:	00048b1b          	sext.w	s6,s1
    80003284:	0044d593          	srli	a1,s1,0x4
    80003288:	018a2783          	lw	a5,24(s4)
    8000328c:	9dbd                	addw	a1,a1,a5
    8000328e:	8556                	mv	a0,s5
    80003290:	00000097          	auipc	ra,0x0
    80003294:	950080e7          	jalr	-1712(ra) # 80002be0 <bread>
    80003298:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000329a:	06050993          	addi	s3,a0,96
    8000329e:	00f4f793          	andi	a5,s1,15
    800032a2:	079a                	slli	a5,a5,0x6
    800032a4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800032a6:	00099783          	lh	a5,0(s3)
    800032aa:	c785                	beqz	a5,800032d2 <ialloc+0x84>
    brelse(bp);
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	a68080e7          	jalr	-1432(ra) # 80002d14 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800032b4:	0485                	addi	s1,s1,1
    800032b6:	00ca2703          	lw	a4,12(s4)
    800032ba:	0004879b          	sext.w	a5,s1
    800032be:	fce7e1e3          	bltu	a5,a4,80003280 <ialloc+0x32>
  panic("ialloc: no inodes");
    800032c2:	00004517          	auipc	a0,0x4
    800032c6:	2b650513          	addi	a0,a0,694 # 80007578 <userret+0x4e8>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	284080e7          	jalr	644(ra) # 8000054e <panic>
      memset(dip, 0, sizeof(*dip));
    800032d2:	04000613          	li	a2,64
    800032d6:	4581                	li	a1,0
    800032d8:	854e                	mv	a0,s3
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	8bc080e7          	jalr	-1860(ra) # 80000b96 <memset>
      dip->type = type;
    800032e2:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800032e6:	854a                	mv	a0,s2
    800032e8:	00001097          	auipc	ra,0x1
    800032ec:	d62080e7          	jalr	-670(ra) # 8000404a <log_write>
      brelse(bp);
    800032f0:	854a                	mv	a0,s2
    800032f2:	00000097          	auipc	ra,0x0
    800032f6:	a22080e7          	jalr	-1502(ra) # 80002d14 <brelse>
      return iget(dev, inum);
    800032fa:	85da                	mv	a1,s6
    800032fc:	8556                	mv	a0,s5
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	db4080e7          	jalr	-588(ra) # 800030b2 <iget>
}
    80003306:	60a6                	ld	ra,72(sp)
    80003308:	6406                	ld	s0,64(sp)
    8000330a:	74e2                	ld	s1,56(sp)
    8000330c:	7942                	ld	s2,48(sp)
    8000330e:	79a2                	ld	s3,40(sp)
    80003310:	7a02                	ld	s4,32(sp)
    80003312:	6ae2                	ld	s5,24(sp)
    80003314:	6b42                	ld	s6,16(sp)
    80003316:	6ba2                	ld	s7,8(sp)
    80003318:	6161                	addi	sp,sp,80
    8000331a:	8082                	ret

000000008000331c <iupdate>:
{
    8000331c:	1101                	addi	sp,sp,-32
    8000331e:	ec06                	sd	ra,24(sp)
    80003320:	e822                	sd	s0,16(sp)
    80003322:	e426                	sd	s1,8(sp)
    80003324:	e04a                	sd	s2,0(sp)
    80003326:	1000                	addi	s0,sp,32
    80003328:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000332a:	415c                	lw	a5,4(a0)
    8000332c:	0047d79b          	srliw	a5,a5,0x4
    80003330:	0001d597          	auipc	a1,0x1d
    80003334:	9b85a583          	lw	a1,-1608(a1) # 8001fce8 <sb+0x18>
    80003338:	9dbd                	addw	a1,a1,a5
    8000333a:	4108                	lw	a0,0(a0)
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	8a4080e7          	jalr	-1884(ra) # 80002be0 <bread>
    80003344:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003346:	06050793          	addi	a5,a0,96
    8000334a:	40c8                	lw	a0,4(s1)
    8000334c:	893d                	andi	a0,a0,15
    8000334e:	051a                	slli	a0,a0,0x6
    80003350:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003352:	04449703          	lh	a4,68(s1)
    80003356:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000335a:	04649703          	lh	a4,70(s1)
    8000335e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003362:	04849703          	lh	a4,72(s1)
    80003366:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000336a:	04a49703          	lh	a4,74(s1)
    8000336e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003372:	44f8                	lw	a4,76(s1)
    80003374:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003376:	03400613          	li	a2,52
    8000337a:	05048593          	addi	a1,s1,80
    8000337e:	0531                	addi	a0,a0,12
    80003380:	ffffe097          	auipc	ra,0xffffe
    80003384:	876080e7          	jalr	-1930(ra) # 80000bf6 <memmove>
  log_write(bp);
    80003388:	854a                	mv	a0,s2
    8000338a:	00001097          	auipc	ra,0x1
    8000338e:	cc0080e7          	jalr	-832(ra) # 8000404a <log_write>
  brelse(bp);
    80003392:	854a                	mv	a0,s2
    80003394:	00000097          	auipc	ra,0x0
    80003398:	980080e7          	jalr	-1664(ra) # 80002d14 <brelse>
}
    8000339c:	60e2                	ld	ra,24(sp)
    8000339e:	6442                	ld	s0,16(sp)
    800033a0:	64a2                	ld	s1,8(sp)
    800033a2:	6902                	ld	s2,0(sp)
    800033a4:	6105                	addi	sp,sp,32
    800033a6:	8082                	ret

00000000800033a8 <idup>:
{
    800033a8:	1101                	addi	sp,sp,-32
    800033aa:	ec06                	sd	ra,24(sp)
    800033ac:	e822                	sd	s0,16(sp)
    800033ae:	e426                	sd	s1,8(sp)
    800033b0:	1000                	addi	s0,sp,32
    800033b2:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800033b4:	0001d517          	auipc	a0,0x1d
    800033b8:	93c50513          	addi	a0,a0,-1732 # 8001fcf0 <icache>
    800033bc:	ffffd097          	auipc	ra,0xffffd
    800033c0:	716080e7          	jalr	1814(ra) # 80000ad2 <acquire>
  ip->ref++;
    800033c4:	449c                	lw	a5,8(s1)
    800033c6:	2785                	addiw	a5,a5,1
    800033c8:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800033ca:	0001d517          	auipc	a0,0x1d
    800033ce:	92650513          	addi	a0,a0,-1754 # 8001fcf0 <icache>
    800033d2:	ffffd097          	auipc	ra,0xffffd
    800033d6:	768080e7          	jalr	1896(ra) # 80000b3a <release>
}
    800033da:	8526                	mv	a0,s1
    800033dc:	60e2                	ld	ra,24(sp)
    800033de:	6442                	ld	s0,16(sp)
    800033e0:	64a2                	ld	s1,8(sp)
    800033e2:	6105                	addi	sp,sp,32
    800033e4:	8082                	ret

00000000800033e6 <ilock>:
{
    800033e6:	1101                	addi	sp,sp,-32
    800033e8:	ec06                	sd	ra,24(sp)
    800033ea:	e822                	sd	s0,16(sp)
    800033ec:	e426                	sd	s1,8(sp)
    800033ee:	e04a                	sd	s2,0(sp)
    800033f0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800033f2:	c115                	beqz	a0,80003416 <ilock+0x30>
    800033f4:	84aa                	mv	s1,a0
    800033f6:	451c                	lw	a5,8(a0)
    800033f8:	00f05f63          	blez	a5,80003416 <ilock+0x30>
  acquiresleep(&ip->lock);
    800033fc:	0541                	addi	a0,a0,16
    800033fe:	00001097          	auipc	ra,0x1
    80003402:	ee4080e7          	jalr	-284(ra) # 800042e2 <acquiresleep>
  if(ip->valid == 0){
    80003406:	40bc                	lw	a5,64(s1)
    80003408:	cf99                	beqz	a5,80003426 <ilock+0x40>
}
    8000340a:	60e2                	ld	ra,24(sp)
    8000340c:	6442                	ld	s0,16(sp)
    8000340e:	64a2                	ld	s1,8(sp)
    80003410:	6902                	ld	s2,0(sp)
    80003412:	6105                	addi	sp,sp,32
    80003414:	8082                	ret
    panic("ilock");
    80003416:	00004517          	auipc	a0,0x4
    8000341a:	17a50513          	addi	a0,a0,378 # 80007590 <userret+0x500>
    8000341e:	ffffd097          	auipc	ra,0xffffd
    80003422:	130080e7          	jalr	304(ra) # 8000054e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003426:	40dc                	lw	a5,4(s1)
    80003428:	0047d79b          	srliw	a5,a5,0x4
    8000342c:	0001d597          	auipc	a1,0x1d
    80003430:	8bc5a583          	lw	a1,-1860(a1) # 8001fce8 <sb+0x18>
    80003434:	9dbd                	addw	a1,a1,a5
    80003436:	4088                	lw	a0,0(s1)
    80003438:	fffff097          	auipc	ra,0xfffff
    8000343c:	7a8080e7          	jalr	1960(ra) # 80002be0 <bread>
    80003440:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003442:	06050593          	addi	a1,a0,96
    80003446:	40dc                	lw	a5,4(s1)
    80003448:	8bbd                	andi	a5,a5,15
    8000344a:	079a                	slli	a5,a5,0x6
    8000344c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000344e:	00059783          	lh	a5,0(a1)
    80003452:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003456:	00259783          	lh	a5,2(a1)
    8000345a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000345e:	00459783          	lh	a5,4(a1)
    80003462:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003466:	00659783          	lh	a5,6(a1)
    8000346a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000346e:	459c                	lw	a5,8(a1)
    80003470:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003472:	03400613          	li	a2,52
    80003476:	05b1                	addi	a1,a1,12
    80003478:	05048513          	addi	a0,s1,80
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	77a080e7          	jalr	1914(ra) # 80000bf6 <memmove>
    brelse(bp);
    80003484:	854a                	mv	a0,s2
    80003486:	00000097          	auipc	ra,0x0
    8000348a:	88e080e7          	jalr	-1906(ra) # 80002d14 <brelse>
    ip->valid = 1;
    8000348e:	4785                	li	a5,1
    80003490:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003492:	04449783          	lh	a5,68(s1)
    80003496:	fbb5                	bnez	a5,8000340a <ilock+0x24>
      panic("ilock: no type");
    80003498:	00004517          	auipc	a0,0x4
    8000349c:	10050513          	addi	a0,a0,256 # 80007598 <userret+0x508>
    800034a0:	ffffd097          	auipc	ra,0xffffd
    800034a4:	0ae080e7          	jalr	174(ra) # 8000054e <panic>

00000000800034a8 <iunlock>:
{
    800034a8:	1101                	addi	sp,sp,-32
    800034aa:	ec06                	sd	ra,24(sp)
    800034ac:	e822                	sd	s0,16(sp)
    800034ae:	e426                	sd	s1,8(sp)
    800034b0:	e04a                	sd	s2,0(sp)
    800034b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800034b4:	c905                	beqz	a0,800034e4 <iunlock+0x3c>
    800034b6:	84aa                	mv	s1,a0
    800034b8:	01050913          	addi	s2,a0,16
    800034bc:	854a                	mv	a0,s2
    800034be:	00001097          	auipc	ra,0x1
    800034c2:	ebe080e7          	jalr	-322(ra) # 8000437c <holdingsleep>
    800034c6:	cd19                	beqz	a0,800034e4 <iunlock+0x3c>
    800034c8:	449c                	lw	a5,8(s1)
    800034ca:	00f05d63          	blez	a5,800034e4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800034ce:	854a                	mv	a0,s2
    800034d0:	00001097          	auipc	ra,0x1
    800034d4:	e68080e7          	jalr	-408(ra) # 80004338 <releasesleep>
}
    800034d8:	60e2                	ld	ra,24(sp)
    800034da:	6442                	ld	s0,16(sp)
    800034dc:	64a2                	ld	s1,8(sp)
    800034de:	6902                	ld	s2,0(sp)
    800034e0:	6105                	addi	sp,sp,32
    800034e2:	8082                	ret
    panic("iunlock");
    800034e4:	00004517          	auipc	a0,0x4
    800034e8:	0c450513          	addi	a0,a0,196 # 800075a8 <userret+0x518>
    800034ec:	ffffd097          	auipc	ra,0xffffd
    800034f0:	062080e7          	jalr	98(ra) # 8000054e <panic>

00000000800034f4 <iput>:
{
    800034f4:	7139                	addi	sp,sp,-64
    800034f6:	fc06                	sd	ra,56(sp)
    800034f8:	f822                	sd	s0,48(sp)
    800034fa:	f426                	sd	s1,40(sp)
    800034fc:	f04a                	sd	s2,32(sp)
    800034fe:	ec4e                	sd	s3,24(sp)
    80003500:	e852                	sd	s4,16(sp)
    80003502:	e456                	sd	s5,8(sp)
    80003504:	0080                	addi	s0,sp,64
    80003506:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003508:	0001c517          	auipc	a0,0x1c
    8000350c:	7e850513          	addi	a0,a0,2024 # 8001fcf0 <icache>
    80003510:	ffffd097          	auipc	ra,0xffffd
    80003514:	5c2080e7          	jalr	1474(ra) # 80000ad2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003518:	4498                	lw	a4,8(s1)
    8000351a:	4785                	li	a5,1
    8000351c:	02f70663          	beq	a4,a5,80003548 <iput+0x54>
  ip->ref--;
    80003520:	449c                	lw	a5,8(s1)
    80003522:	37fd                	addiw	a5,a5,-1
    80003524:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003526:	0001c517          	auipc	a0,0x1c
    8000352a:	7ca50513          	addi	a0,a0,1994 # 8001fcf0 <icache>
    8000352e:	ffffd097          	auipc	ra,0xffffd
    80003532:	60c080e7          	jalr	1548(ra) # 80000b3a <release>
}
    80003536:	70e2                	ld	ra,56(sp)
    80003538:	7442                	ld	s0,48(sp)
    8000353a:	74a2                	ld	s1,40(sp)
    8000353c:	7902                	ld	s2,32(sp)
    8000353e:	69e2                	ld	s3,24(sp)
    80003540:	6a42                	ld	s4,16(sp)
    80003542:	6aa2                	ld	s5,8(sp)
    80003544:	6121                	addi	sp,sp,64
    80003546:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003548:	40bc                	lw	a5,64(s1)
    8000354a:	dbf9                	beqz	a5,80003520 <iput+0x2c>
    8000354c:	04a49783          	lh	a5,74(s1)
    80003550:	fbe1                	bnez	a5,80003520 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003552:	01048a13          	addi	s4,s1,16
    80003556:	8552                	mv	a0,s4
    80003558:	00001097          	auipc	ra,0x1
    8000355c:	d8a080e7          	jalr	-630(ra) # 800042e2 <acquiresleep>
    release(&icache.lock);
    80003560:	0001c517          	auipc	a0,0x1c
    80003564:	79050513          	addi	a0,a0,1936 # 8001fcf0 <icache>
    80003568:	ffffd097          	auipc	ra,0xffffd
    8000356c:	5d2080e7          	jalr	1490(ra) # 80000b3a <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003570:	05048913          	addi	s2,s1,80
    80003574:	08048993          	addi	s3,s1,128
    80003578:	a819                	j	8000358e <iput+0x9a>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    8000357a:	4088                	lw	a0,0(s1)
    8000357c:	00000097          	auipc	ra,0x0
    80003580:	8ae080e7          	jalr	-1874(ra) # 80002e2a <bfree>
      ip->addrs[i] = 0;
    80003584:	00092023          	sw	zero,0(s2)
  for(i = 0; i < NDIRECT; i++){
    80003588:	0911                	addi	s2,s2,4
    8000358a:	01390663          	beq	s2,s3,80003596 <iput+0xa2>
    if(ip->addrs[i]){
    8000358e:	00092583          	lw	a1,0(s2)
    80003592:	d9fd                	beqz	a1,80003588 <iput+0x94>
    80003594:	b7dd                	j	8000357a <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003596:	0804a583          	lw	a1,128(s1)
    8000359a:	ed9d                	bnez	a1,800035d8 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000359c:	0404a623          	sw	zero,76(s1)
  iupdate(ip);
    800035a0:	8526                	mv	a0,s1
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	d7a080e7          	jalr	-646(ra) # 8000331c <iupdate>
    ip->type = 0;
    800035aa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800035ae:	8526                	mv	a0,s1
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	d6c080e7          	jalr	-660(ra) # 8000331c <iupdate>
    ip->valid = 0;
    800035b8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800035bc:	8552                	mv	a0,s4
    800035be:	00001097          	auipc	ra,0x1
    800035c2:	d7a080e7          	jalr	-646(ra) # 80004338 <releasesleep>
    acquire(&icache.lock);
    800035c6:	0001c517          	auipc	a0,0x1c
    800035ca:	72a50513          	addi	a0,a0,1834 # 8001fcf0 <icache>
    800035ce:	ffffd097          	auipc	ra,0xffffd
    800035d2:	504080e7          	jalr	1284(ra) # 80000ad2 <acquire>
    800035d6:	b7a9                	j	80003520 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035d8:	4088                	lw	a0,0(s1)
    800035da:	fffff097          	auipc	ra,0xfffff
    800035de:	606080e7          	jalr	1542(ra) # 80002be0 <bread>
    800035e2:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    800035e4:	06050913          	addi	s2,a0,96
    800035e8:	46050993          	addi	s3,a0,1120
    800035ec:	a809                	j	800035fe <iput+0x10a>
        bfree(ip->dev, a[j]);
    800035ee:	4088                	lw	a0,0(s1)
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	83a080e7          	jalr	-1990(ra) # 80002e2a <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800035f8:	0911                	addi	s2,s2,4
    800035fa:	01390663          	beq	s2,s3,80003606 <iput+0x112>
      if(a[j])
    800035fe:	00092583          	lw	a1,0(s2)
    80003602:	d9fd                	beqz	a1,800035f8 <iput+0x104>
    80003604:	b7ed                	j	800035ee <iput+0xfa>
    brelse(bp);
    80003606:	8556                	mv	a0,s5
    80003608:	fffff097          	auipc	ra,0xfffff
    8000360c:	70c080e7          	jalr	1804(ra) # 80002d14 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003610:	0804a583          	lw	a1,128(s1)
    80003614:	4088                	lw	a0,0(s1)
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	814080e7          	jalr	-2028(ra) # 80002e2a <bfree>
    ip->addrs[NDIRECT] = 0;
    8000361e:	0804a023          	sw	zero,128(s1)
    80003622:	bfad                	j	8000359c <iput+0xa8>

0000000080003624 <iunlockput>:
{
    80003624:	1101                	addi	sp,sp,-32
    80003626:	ec06                	sd	ra,24(sp)
    80003628:	e822                	sd	s0,16(sp)
    8000362a:	e426                	sd	s1,8(sp)
    8000362c:	1000                	addi	s0,sp,32
    8000362e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003630:	00000097          	auipc	ra,0x0
    80003634:	e78080e7          	jalr	-392(ra) # 800034a8 <iunlock>
  iput(ip);
    80003638:	8526                	mv	a0,s1
    8000363a:	00000097          	auipc	ra,0x0
    8000363e:	eba080e7          	jalr	-326(ra) # 800034f4 <iput>
}
    80003642:	60e2                	ld	ra,24(sp)
    80003644:	6442                	ld	s0,16(sp)
    80003646:	64a2                	ld	s1,8(sp)
    80003648:	6105                	addi	sp,sp,32
    8000364a:	8082                	ret

000000008000364c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000364c:	1141                	addi	sp,sp,-16
    8000364e:	e422                	sd	s0,8(sp)
    80003650:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003652:	411c                	lw	a5,0(a0)
    80003654:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003656:	415c                	lw	a5,4(a0)
    80003658:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000365a:	04451783          	lh	a5,68(a0)
    8000365e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003662:	04a51783          	lh	a5,74(a0)
    80003666:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000366a:	04c56783          	lwu	a5,76(a0)
    8000366e:	e99c                	sd	a5,16(a1)
}
    80003670:	6422                	ld	s0,8(sp)
    80003672:	0141                	addi	sp,sp,16
    80003674:	8082                	ret

0000000080003676 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003676:	457c                	lw	a5,76(a0)
    80003678:	0ed7e563          	bltu	a5,a3,80003762 <readi+0xec>
{
    8000367c:	7159                	addi	sp,sp,-112
    8000367e:	f486                	sd	ra,104(sp)
    80003680:	f0a2                	sd	s0,96(sp)
    80003682:	eca6                	sd	s1,88(sp)
    80003684:	e8ca                	sd	s2,80(sp)
    80003686:	e4ce                	sd	s3,72(sp)
    80003688:	e0d2                	sd	s4,64(sp)
    8000368a:	fc56                	sd	s5,56(sp)
    8000368c:	f85a                	sd	s6,48(sp)
    8000368e:	f45e                	sd	s7,40(sp)
    80003690:	f062                	sd	s8,32(sp)
    80003692:	ec66                	sd	s9,24(sp)
    80003694:	e86a                	sd	s10,16(sp)
    80003696:	e46e                	sd	s11,8(sp)
    80003698:	1880                	addi	s0,sp,112
    8000369a:	8baa                	mv	s7,a0
    8000369c:	8c2e                	mv	s8,a1
    8000369e:	8ab2                	mv	s5,a2
    800036a0:	8936                	mv	s2,a3
    800036a2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800036a4:	9f35                	addw	a4,a4,a3
    800036a6:	0cd76063          	bltu	a4,a3,80003766 <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    800036aa:	00e7f463          	bgeu	a5,a4,800036b2 <readi+0x3c>
    n = ip->size - off;
    800036ae:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036b2:	080b0763          	beqz	s6,80003740 <readi+0xca>
    800036b6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800036bc:	5cfd                	li	s9,-1
    800036be:	a82d                	j	800036f8 <readi+0x82>
    800036c0:	02099d93          	slli	s11,s3,0x20
    800036c4:	020ddd93          	srli	s11,s11,0x20
    800036c8:	06048613          	addi	a2,s1,96
    800036cc:	86ee                	mv	a3,s11
    800036ce:	963a                	add	a2,a2,a4
    800036d0:	85d6                	mv	a1,s5
    800036d2:	8562                	mv	a0,s8
    800036d4:	fffff097          	auipc	ra,0xfffff
    800036d8:	b8c080e7          	jalr	-1140(ra) # 80002260 <either_copyout>
    800036dc:	05950d63          	beq	a0,s9,80003736 <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    800036e0:	8526                	mv	a0,s1
    800036e2:	fffff097          	auipc	ra,0xfffff
    800036e6:	632080e7          	jalr	1586(ra) # 80002d14 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036ea:	01498a3b          	addw	s4,s3,s4
    800036ee:	0129893b          	addw	s2,s3,s2
    800036f2:	9aee                	add	s5,s5,s11
    800036f4:	056a7663          	bgeu	s4,s6,80003740 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800036f8:	000ba483          	lw	s1,0(s7)
    800036fc:	00a9559b          	srliw	a1,s2,0xa
    80003700:	855e                	mv	a0,s7
    80003702:	00000097          	auipc	ra,0x0
    80003706:	8d6080e7          	jalr	-1834(ra) # 80002fd8 <bmap>
    8000370a:	0005059b          	sext.w	a1,a0
    8000370e:	8526                	mv	a0,s1
    80003710:	fffff097          	auipc	ra,0xfffff
    80003714:	4d0080e7          	jalr	1232(ra) # 80002be0 <bread>
    80003718:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000371a:	3ff97713          	andi	a4,s2,1023
    8000371e:	40ed07bb          	subw	a5,s10,a4
    80003722:	414b06bb          	subw	a3,s6,s4
    80003726:	89be                	mv	s3,a5
    80003728:	2781                	sext.w	a5,a5
    8000372a:	0006861b          	sext.w	a2,a3
    8000372e:	f8f679e3          	bgeu	a2,a5,800036c0 <readi+0x4a>
    80003732:	89b6                	mv	s3,a3
    80003734:	b771                	j	800036c0 <readi+0x4a>
      brelse(bp);
    80003736:	8526                	mv	a0,s1
    80003738:	fffff097          	auipc	ra,0xfffff
    8000373c:	5dc080e7          	jalr	1500(ra) # 80002d14 <brelse>
  }
  return n;
    80003740:	000b051b          	sext.w	a0,s6
}
    80003744:	70a6                	ld	ra,104(sp)
    80003746:	7406                	ld	s0,96(sp)
    80003748:	64e6                	ld	s1,88(sp)
    8000374a:	6946                	ld	s2,80(sp)
    8000374c:	69a6                	ld	s3,72(sp)
    8000374e:	6a06                	ld	s4,64(sp)
    80003750:	7ae2                	ld	s5,56(sp)
    80003752:	7b42                	ld	s6,48(sp)
    80003754:	7ba2                	ld	s7,40(sp)
    80003756:	7c02                	ld	s8,32(sp)
    80003758:	6ce2                	ld	s9,24(sp)
    8000375a:	6d42                	ld	s10,16(sp)
    8000375c:	6da2                	ld	s11,8(sp)
    8000375e:	6165                	addi	sp,sp,112
    80003760:	8082                	ret
    return -1;
    80003762:	557d                	li	a0,-1
}
    80003764:	8082                	ret
    return -1;
    80003766:	557d                	li	a0,-1
    80003768:	bff1                	j	80003744 <readi+0xce>

000000008000376a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000376a:	457c                	lw	a5,76(a0)
    8000376c:	10d7e763          	bltu	a5,a3,8000387a <writei+0x110>
{
    80003770:	7159                	addi	sp,sp,-112
    80003772:	f486                	sd	ra,104(sp)
    80003774:	f0a2                	sd	s0,96(sp)
    80003776:	eca6                	sd	s1,88(sp)
    80003778:	e8ca                	sd	s2,80(sp)
    8000377a:	e4ce                	sd	s3,72(sp)
    8000377c:	e0d2                	sd	s4,64(sp)
    8000377e:	fc56                	sd	s5,56(sp)
    80003780:	f85a                	sd	s6,48(sp)
    80003782:	f45e                	sd	s7,40(sp)
    80003784:	f062                	sd	s8,32(sp)
    80003786:	ec66                	sd	s9,24(sp)
    80003788:	e86a                	sd	s10,16(sp)
    8000378a:	e46e                	sd	s11,8(sp)
    8000378c:	1880                	addi	s0,sp,112
    8000378e:	8baa                	mv	s7,a0
    80003790:	8c2e                	mv	s8,a1
    80003792:	8ab2                	mv	s5,a2
    80003794:	8936                	mv	s2,a3
    80003796:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003798:	00e687bb          	addw	a5,a3,a4
    8000379c:	0ed7e163          	bltu	a5,a3,8000387e <writei+0x114>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    800037a0:	00043737          	lui	a4,0x43
    800037a4:	0cf76f63          	bltu	a4,a5,80003882 <writei+0x118>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037a8:	0a0b0063          	beqz	s6,80003848 <writei+0xde>
    800037ac:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    800037ae:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800037b2:	5cfd                	li	s9,-1
    800037b4:	a091                	j	800037f8 <writei+0x8e>
    800037b6:	02099d93          	slli	s11,s3,0x20
    800037ba:	020ddd93          	srli	s11,s11,0x20
    800037be:	06048513          	addi	a0,s1,96
    800037c2:	86ee                	mv	a3,s11
    800037c4:	8656                	mv	a2,s5
    800037c6:	85e2                	mv	a1,s8
    800037c8:	953a                	add	a0,a0,a4
    800037ca:	fffff097          	auipc	ra,0xfffff
    800037ce:	aec080e7          	jalr	-1300(ra) # 800022b6 <either_copyin>
    800037d2:	07950263          	beq	a0,s9,80003836 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800037d6:	8526                	mv	a0,s1
    800037d8:	00001097          	auipc	ra,0x1
    800037dc:	872080e7          	jalr	-1934(ra) # 8000404a <log_write>
    brelse(bp);
    800037e0:	8526                	mv	a0,s1
    800037e2:	fffff097          	auipc	ra,0xfffff
    800037e6:	532080e7          	jalr	1330(ra) # 80002d14 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037ea:	01498a3b          	addw	s4,s3,s4
    800037ee:	0129893b          	addw	s2,s3,s2
    800037f2:	9aee                	add	s5,s5,s11
    800037f4:	056a7663          	bgeu	s4,s6,80003840 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800037f8:	000ba483          	lw	s1,0(s7)
    800037fc:	00a9559b          	srliw	a1,s2,0xa
    80003800:	855e                	mv	a0,s7
    80003802:	fffff097          	auipc	ra,0xfffff
    80003806:	7d6080e7          	jalr	2006(ra) # 80002fd8 <bmap>
    8000380a:	0005059b          	sext.w	a1,a0
    8000380e:	8526                	mv	a0,s1
    80003810:	fffff097          	auipc	ra,0xfffff
    80003814:	3d0080e7          	jalr	976(ra) # 80002be0 <bread>
    80003818:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000381a:	3ff97713          	andi	a4,s2,1023
    8000381e:	40ed07bb          	subw	a5,s10,a4
    80003822:	414b06bb          	subw	a3,s6,s4
    80003826:	89be                	mv	s3,a5
    80003828:	2781                	sext.w	a5,a5
    8000382a:	0006861b          	sext.w	a2,a3
    8000382e:	f8f674e3          	bgeu	a2,a5,800037b6 <writei+0x4c>
    80003832:	89b6                	mv	s3,a3
    80003834:	b749                	j	800037b6 <writei+0x4c>
      brelse(bp);
    80003836:	8526                	mv	a0,s1
    80003838:	fffff097          	auipc	ra,0xfffff
    8000383c:	4dc080e7          	jalr	1244(ra) # 80002d14 <brelse>
  }

  if(n > 0 && off > ip->size){
    80003840:	04cba783          	lw	a5,76(s7)
    80003844:	0327e363          	bltu	a5,s2,8000386a <writei+0x100>
    ip->size = off;
    iupdate(ip);
  }
  return n;
    80003848:	000b051b          	sext.w	a0,s6
}
    8000384c:	70a6                	ld	ra,104(sp)
    8000384e:	7406                	ld	s0,96(sp)
    80003850:	64e6                	ld	s1,88(sp)
    80003852:	6946                	ld	s2,80(sp)
    80003854:	69a6                	ld	s3,72(sp)
    80003856:	6a06                	ld	s4,64(sp)
    80003858:	7ae2                	ld	s5,56(sp)
    8000385a:	7b42                	ld	s6,48(sp)
    8000385c:	7ba2                	ld	s7,40(sp)
    8000385e:	7c02                	ld	s8,32(sp)
    80003860:	6ce2                	ld	s9,24(sp)
    80003862:	6d42                	ld	s10,16(sp)
    80003864:	6da2                	ld	s11,8(sp)
    80003866:	6165                	addi	sp,sp,112
    80003868:	8082                	ret
    ip->size = off;
    8000386a:	052ba623          	sw	s2,76(s7)
    iupdate(ip);
    8000386e:	855e                	mv	a0,s7
    80003870:	00000097          	auipc	ra,0x0
    80003874:	aac080e7          	jalr	-1364(ra) # 8000331c <iupdate>
    80003878:	bfc1                	j	80003848 <writei+0xde>
    return -1;
    8000387a:	557d                	li	a0,-1
}
    8000387c:	8082                	ret
    return -1;
    8000387e:	557d                	li	a0,-1
    80003880:	b7f1                	j	8000384c <writei+0xe2>
    return -1;
    80003882:	557d                	li	a0,-1
    80003884:	b7e1                	j	8000384c <writei+0xe2>

0000000080003886 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003886:	1141                	addi	sp,sp,-16
    80003888:	e406                	sd	ra,8(sp)
    8000388a:	e022                	sd	s0,0(sp)
    8000388c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000388e:	4639                	li	a2,14
    80003890:	ffffd097          	auipc	ra,0xffffd
    80003894:	3e2080e7          	jalr	994(ra) # 80000c72 <strncmp>
}
    80003898:	60a2                	ld	ra,8(sp)
    8000389a:	6402                	ld	s0,0(sp)
    8000389c:	0141                	addi	sp,sp,16
    8000389e:	8082                	ret

00000000800038a0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800038a0:	7139                	addi	sp,sp,-64
    800038a2:	fc06                	sd	ra,56(sp)
    800038a4:	f822                	sd	s0,48(sp)
    800038a6:	f426                	sd	s1,40(sp)
    800038a8:	f04a                	sd	s2,32(sp)
    800038aa:	ec4e                	sd	s3,24(sp)
    800038ac:	e852                	sd	s4,16(sp)
    800038ae:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800038b0:	04451703          	lh	a4,68(a0)
    800038b4:	4785                	li	a5,1
    800038b6:	00f71a63          	bne	a4,a5,800038ca <dirlookup+0x2a>
    800038ba:	892a                	mv	s2,a0
    800038bc:	89ae                	mv	s3,a1
    800038be:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c0:	457c                	lw	a5,76(a0)
    800038c2:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800038c4:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038c6:	e79d                	bnez	a5,800038f4 <dirlookup+0x54>
    800038c8:	a8a5                	j	80003940 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800038ca:	00004517          	auipc	a0,0x4
    800038ce:	ce650513          	addi	a0,a0,-794 # 800075b0 <userret+0x520>
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	c7c080e7          	jalr	-900(ra) # 8000054e <panic>
      panic("dirlookup read");
    800038da:	00004517          	auipc	a0,0x4
    800038de:	cee50513          	addi	a0,a0,-786 # 800075c8 <userret+0x538>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	c6c080e7          	jalr	-916(ra) # 8000054e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038ea:	24c1                	addiw	s1,s1,16
    800038ec:	04c92783          	lw	a5,76(s2)
    800038f0:	04f4f763          	bgeu	s1,a5,8000393e <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038f4:	4741                	li	a4,16
    800038f6:	86a6                	mv	a3,s1
    800038f8:	fc040613          	addi	a2,s0,-64
    800038fc:	4581                	li	a1,0
    800038fe:	854a                	mv	a0,s2
    80003900:	00000097          	auipc	ra,0x0
    80003904:	d76080e7          	jalr	-650(ra) # 80003676 <readi>
    80003908:	47c1                	li	a5,16
    8000390a:	fcf518e3          	bne	a0,a5,800038da <dirlookup+0x3a>
    if(de.inum == 0)
    8000390e:	fc045783          	lhu	a5,-64(s0)
    80003912:	dfe1                	beqz	a5,800038ea <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003914:	fc240593          	addi	a1,s0,-62
    80003918:	854e                	mv	a0,s3
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	f6c080e7          	jalr	-148(ra) # 80003886 <namecmp>
    80003922:	f561                	bnez	a0,800038ea <dirlookup+0x4a>
      if(poff)
    80003924:	000a0463          	beqz	s4,8000392c <dirlookup+0x8c>
        *poff = off;
    80003928:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000392c:	fc045583          	lhu	a1,-64(s0)
    80003930:	00092503          	lw	a0,0(s2)
    80003934:	fffff097          	auipc	ra,0xfffff
    80003938:	77e080e7          	jalr	1918(ra) # 800030b2 <iget>
    8000393c:	a011                	j	80003940 <dirlookup+0xa0>
  return 0;
    8000393e:	4501                	li	a0,0
}
    80003940:	70e2                	ld	ra,56(sp)
    80003942:	7442                	ld	s0,48(sp)
    80003944:	74a2                	ld	s1,40(sp)
    80003946:	7902                	ld	s2,32(sp)
    80003948:	69e2                	ld	s3,24(sp)
    8000394a:	6a42                	ld	s4,16(sp)
    8000394c:	6121                	addi	sp,sp,64
    8000394e:	8082                	ret

0000000080003950 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003950:	711d                	addi	sp,sp,-96
    80003952:	ec86                	sd	ra,88(sp)
    80003954:	e8a2                	sd	s0,80(sp)
    80003956:	e4a6                	sd	s1,72(sp)
    80003958:	e0ca                	sd	s2,64(sp)
    8000395a:	fc4e                	sd	s3,56(sp)
    8000395c:	f852                	sd	s4,48(sp)
    8000395e:	f456                	sd	s5,40(sp)
    80003960:	f05a                	sd	s6,32(sp)
    80003962:	ec5e                	sd	s7,24(sp)
    80003964:	e862                	sd	s8,16(sp)
    80003966:	e466                	sd	s9,8(sp)
    80003968:	1080                	addi	s0,sp,96
    8000396a:	84aa                	mv	s1,a0
    8000396c:	8b2e                	mv	s6,a1
    8000396e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003970:	00054703          	lbu	a4,0(a0)
    80003974:	02f00793          	li	a5,47
    80003978:	02f70363          	beq	a4,a5,8000399e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000397c:	ffffe097          	auipc	ra,0xffffe
    80003980:	eb8080e7          	jalr	-328(ra) # 80001834 <myproc>
    80003984:	14853503          	ld	a0,328(a0)
    80003988:	00000097          	auipc	ra,0x0
    8000398c:	a20080e7          	jalr	-1504(ra) # 800033a8 <idup>
    80003990:	89aa                	mv	s3,a0
  while(*path == '/')
    80003992:	02f00913          	li	s2,47
  len = path - s;
    80003996:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80003998:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000399a:	4c05                	li	s8,1
    8000399c:	a865                	j	80003a54 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000399e:	4585                	li	a1,1
    800039a0:	4501                	li	a0,0
    800039a2:	fffff097          	auipc	ra,0xfffff
    800039a6:	710080e7          	jalr	1808(ra) # 800030b2 <iget>
    800039aa:	89aa                	mv	s3,a0
    800039ac:	b7dd                	j	80003992 <namex+0x42>
      iunlockput(ip);
    800039ae:	854e                	mv	a0,s3
    800039b0:	00000097          	auipc	ra,0x0
    800039b4:	c74080e7          	jalr	-908(ra) # 80003624 <iunlockput>
      return 0;
    800039b8:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039ba:	854e                	mv	a0,s3
    800039bc:	60e6                	ld	ra,88(sp)
    800039be:	6446                	ld	s0,80(sp)
    800039c0:	64a6                	ld	s1,72(sp)
    800039c2:	6906                	ld	s2,64(sp)
    800039c4:	79e2                	ld	s3,56(sp)
    800039c6:	7a42                	ld	s4,48(sp)
    800039c8:	7aa2                	ld	s5,40(sp)
    800039ca:	7b02                	ld	s6,32(sp)
    800039cc:	6be2                	ld	s7,24(sp)
    800039ce:	6c42                	ld	s8,16(sp)
    800039d0:	6ca2                	ld	s9,8(sp)
    800039d2:	6125                	addi	sp,sp,96
    800039d4:	8082                	ret
      iunlock(ip);
    800039d6:	854e                	mv	a0,s3
    800039d8:	00000097          	auipc	ra,0x0
    800039dc:	ad0080e7          	jalr	-1328(ra) # 800034a8 <iunlock>
      return ip;
    800039e0:	bfe9                	j	800039ba <namex+0x6a>
      iunlockput(ip);
    800039e2:	854e                	mv	a0,s3
    800039e4:	00000097          	auipc	ra,0x0
    800039e8:	c40080e7          	jalr	-960(ra) # 80003624 <iunlockput>
      return 0;
    800039ec:	89d2                	mv	s3,s4
    800039ee:	b7f1                	j	800039ba <namex+0x6a>
  len = path - s;
    800039f0:	40b48633          	sub	a2,s1,a1
    800039f4:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800039f8:	094cd463          	bge	s9,s4,80003a80 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800039fc:	4639                	li	a2,14
    800039fe:	8556                	mv	a0,s5
    80003a00:	ffffd097          	auipc	ra,0xffffd
    80003a04:	1f6080e7          	jalr	502(ra) # 80000bf6 <memmove>
  while(*path == '/')
    80003a08:	0004c783          	lbu	a5,0(s1)
    80003a0c:	01279763          	bne	a5,s2,80003a1a <namex+0xca>
    path++;
    80003a10:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a12:	0004c783          	lbu	a5,0(s1)
    80003a16:	ff278de3          	beq	a5,s2,80003a10 <namex+0xc0>
    ilock(ip);
    80003a1a:	854e                	mv	a0,s3
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	9ca080e7          	jalr	-1590(ra) # 800033e6 <ilock>
    if(ip->type != T_DIR){
    80003a24:	04499783          	lh	a5,68(s3)
    80003a28:	f98793e3          	bne	a5,s8,800039ae <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003a2c:	000b0563          	beqz	s6,80003a36 <namex+0xe6>
    80003a30:	0004c783          	lbu	a5,0(s1)
    80003a34:	d3cd                	beqz	a5,800039d6 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a36:	865e                	mv	a2,s7
    80003a38:	85d6                	mv	a1,s5
    80003a3a:	854e                	mv	a0,s3
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	e64080e7          	jalr	-412(ra) # 800038a0 <dirlookup>
    80003a44:	8a2a                	mv	s4,a0
    80003a46:	dd51                	beqz	a0,800039e2 <namex+0x92>
    iunlockput(ip);
    80003a48:	854e                	mv	a0,s3
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	bda080e7          	jalr	-1062(ra) # 80003624 <iunlockput>
    ip = next;
    80003a52:	89d2                	mv	s3,s4
  while(*path == '/')
    80003a54:	0004c783          	lbu	a5,0(s1)
    80003a58:	05279763          	bne	a5,s2,80003aa6 <namex+0x156>
    path++;
    80003a5c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a5e:	0004c783          	lbu	a5,0(s1)
    80003a62:	ff278de3          	beq	a5,s2,80003a5c <namex+0x10c>
  if(*path == 0)
    80003a66:	c79d                	beqz	a5,80003a94 <namex+0x144>
    path++;
    80003a68:	85a6                	mv	a1,s1
  len = path - s;
    80003a6a:	8a5e                	mv	s4,s7
    80003a6c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003a6e:	01278963          	beq	a5,s2,80003a80 <namex+0x130>
    80003a72:	dfbd                	beqz	a5,800039f0 <namex+0xa0>
    path++;
    80003a74:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003a76:	0004c783          	lbu	a5,0(s1)
    80003a7a:	ff279ce3          	bne	a5,s2,80003a72 <namex+0x122>
    80003a7e:	bf8d                	j	800039f0 <namex+0xa0>
    memmove(name, s, len);
    80003a80:	2601                	sext.w	a2,a2
    80003a82:	8556                	mv	a0,s5
    80003a84:	ffffd097          	auipc	ra,0xffffd
    80003a88:	172080e7          	jalr	370(ra) # 80000bf6 <memmove>
    name[len] = 0;
    80003a8c:	9a56                	add	s4,s4,s5
    80003a8e:	000a0023          	sb	zero,0(s4)
    80003a92:	bf9d                	j	80003a08 <namex+0xb8>
  if(nameiparent){
    80003a94:	f20b03e3          	beqz	s6,800039ba <namex+0x6a>
    iput(ip);
    80003a98:	854e                	mv	a0,s3
    80003a9a:	00000097          	auipc	ra,0x0
    80003a9e:	a5a080e7          	jalr	-1446(ra) # 800034f4 <iput>
    return 0;
    80003aa2:	4981                	li	s3,0
    80003aa4:	bf19                	j	800039ba <namex+0x6a>
  if(*path == 0)
    80003aa6:	d7fd                	beqz	a5,80003a94 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003aa8:	0004c783          	lbu	a5,0(s1)
    80003aac:	85a6                	mv	a1,s1
    80003aae:	b7d1                	j	80003a72 <namex+0x122>

0000000080003ab0 <dirlink>:
{
    80003ab0:	7139                	addi	sp,sp,-64
    80003ab2:	fc06                	sd	ra,56(sp)
    80003ab4:	f822                	sd	s0,48(sp)
    80003ab6:	f426                	sd	s1,40(sp)
    80003ab8:	f04a                	sd	s2,32(sp)
    80003aba:	ec4e                	sd	s3,24(sp)
    80003abc:	e852                	sd	s4,16(sp)
    80003abe:	0080                	addi	s0,sp,64
    80003ac0:	892a                	mv	s2,a0
    80003ac2:	8a2e                	mv	s4,a1
    80003ac4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ac6:	4601                	li	a2,0
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	dd8080e7          	jalr	-552(ra) # 800038a0 <dirlookup>
    80003ad0:	e93d                	bnez	a0,80003b46 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ad2:	04c92483          	lw	s1,76(s2)
    80003ad6:	c49d                	beqz	s1,80003b04 <dirlink+0x54>
    80003ad8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ada:	4741                	li	a4,16
    80003adc:	86a6                	mv	a3,s1
    80003ade:	fc040613          	addi	a2,s0,-64
    80003ae2:	4581                	li	a1,0
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	b90080e7          	jalr	-1136(ra) # 80003676 <readi>
    80003aee:	47c1                	li	a5,16
    80003af0:	06f51163          	bne	a0,a5,80003b52 <dirlink+0xa2>
    if(de.inum == 0)
    80003af4:	fc045783          	lhu	a5,-64(s0)
    80003af8:	c791                	beqz	a5,80003b04 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003afa:	24c1                	addiw	s1,s1,16
    80003afc:	04c92783          	lw	a5,76(s2)
    80003b00:	fcf4ede3          	bltu	s1,a5,80003ada <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003b04:	4639                	li	a2,14
    80003b06:	85d2                	mv	a1,s4
    80003b08:	fc240513          	addi	a0,s0,-62
    80003b0c:	ffffd097          	auipc	ra,0xffffd
    80003b10:	1a2080e7          	jalr	418(ra) # 80000cae <strncpy>
  de.inum = inum;
    80003b14:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b18:	4741                	li	a4,16
    80003b1a:	86a6                	mv	a3,s1
    80003b1c:	fc040613          	addi	a2,s0,-64
    80003b20:	4581                	li	a1,0
    80003b22:	854a                	mv	a0,s2
    80003b24:	00000097          	auipc	ra,0x0
    80003b28:	c46080e7          	jalr	-954(ra) # 8000376a <writei>
    80003b2c:	872a                	mv	a4,a0
    80003b2e:	47c1                	li	a5,16
  return 0;
    80003b30:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b32:	02f71863          	bne	a4,a5,80003b62 <dirlink+0xb2>
}
    80003b36:	70e2                	ld	ra,56(sp)
    80003b38:	7442                	ld	s0,48(sp)
    80003b3a:	74a2                	ld	s1,40(sp)
    80003b3c:	7902                	ld	s2,32(sp)
    80003b3e:	69e2                	ld	s3,24(sp)
    80003b40:	6a42                	ld	s4,16(sp)
    80003b42:	6121                	addi	sp,sp,64
    80003b44:	8082                	ret
    iput(ip);
    80003b46:	00000097          	auipc	ra,0x0
    80003b4a:	9ae080e7          	jalr	-1618(ra) # 800034f4 <iput>
    return -1;
    80003b4e:	557d                	li	a0,-1
    80003b50:	b7dd                	j	80003b36 <dirlink+0x86>
      panic("dirlink read");
    80003b52:	00004517          	auipc	a0,0x4
    80003b56:	a8650513          	addi	a0,a0,-1402 # 800075d8 <userret+0x548>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	9f4080e7          	jalr	-1548(ra) # 8000054e <panic>
    panic("dirlink");
    80003b62:	00004517          	auipc	a0,0x4
    80003b66:	c2650513          	addi	a0,a0,-986 # 80007788 <userret+0x6f8>
    80003b6a:	ffffd097          	auipc	ra,0xffffd
    80003b6e:	9e4080e7          	jalr	-1564(ra) # 8000054e <panic>

0000000080003b72 <namei>:

struct inode*
namei(char *path)
{
    80003b72:	1101                	addi	sp,sp,-32
    80003b74:	ec06                	sd	ra,24(sp)
    80003b76:	e822                	sd	s0,16(sp)
    80003b78:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b7a:	fe040613          	addi	a2,s0,-32
    80003b7e:	4581                	li	a1,0
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	dd0080e7          	jalr	-560(ra) # 80003950 <namex>
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	6105                	addi	sp,sp,32
    80003b8e:	8082                	ret

0000000080003b90 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b90:	1141                	addi	sp,sp,-16
    80003b92:	e406                	sd	ra,8(sp)
    80003b94:	e022                	sd	s0,0(sp)
    80003b96:	0800                	addi	s0,sp,16
    80003b98:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b9a:	4585                	li	a1,1
    80003b9c:	00000097          	auipc	ra,0x0
    80003ba0:	db4080e7          	jalr	-588(ra) # 80003950 <namex>
}
    80003ba4:	60a2                	ld	ra,8(sp)
    80003ba6:	6402                	ld	s0,0(sp)
    80003ba8:	0141                	addi	sp,sp,16
    80003baa:	8082                	ret

0000000080003bac <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80003bac:	7179                	addi	sp,sp,-48
    80003bae:	f406                	sd	ra,40(sp)
    80003bb0:	f022                	sd	s0,32(sp)
    80003bb2:	ec26                	sd	s1,24(sp)
    80003bb4:	e84a                	sd	s2,16(sp)
    80003bb6:	e44e                	sd	s3,8(sp)
    80003bb8:	1800                	addi	s0,sp,48
    80003bba:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80003bbc:	0a800993          	li	s3,168
    80003bc0:	033507b3          	mul	a5,a0,s3
    80003bc4:	0001e997          	auipc	s3,0x1e
    80003bc8:	bd498993          	addi	s3,s3,-1068 # 80021798 <log>
    80003bcc:	99be                	add	s3,s3,a5
    80003bce:	0189a583          	lw	a1,24(s3)
    80003bd2:	fffff097          	auipc	ra,0xfffff
    80003bd6:	00e080e7          	jalr	14(ra) # 80002be0 <bread>
    80003bda:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80003bdc:	02c9a783          	lw	a5,44(s3)
    80003be0:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003be2:	02c9a783          	lw	a5,44(s3)
    80003be6:	02f05763          	blez	a5,80003c14 <write_head+0x68>
    80003bea:	0a800793          	li	a5,168
    80003bee:	02f487b3          	mul	a5,s1,a5
    80003bf2:	0001e717          	auipc	a4,0x1e
    80003bf6:	bd670713          	addi	a4,a4,-1066 # 800217c8 <log+0x30>
    80003bfa:	97ba                	add	a5,a5,a4
    80003bfc:	06450693          	addi	a3,a0,100
    80003c00:	4701                	li	a4,0
    80003c02:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    80003c04:	4390                	lw	a2,0(a5)
    80003c06:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003c08:	2705                	addiw	a4,a4,1
    80003c0a:	0791                	addi	a5,a5,4
    80003c0c:	0691                	addi	a3,a3,4
    80003c0e:	55d0                	lw	a2,44(a1)
    80003c10:	fec74ae3          	blt	a4,a2,80003c04 <write_head+0x58>
  }
  bwrite(buf);
    80003c14:	854a                	mv	a0,s2
    80003c16:	fffff097          	auipc	ra,0xfffff
    80003c1a:	0be080e7          	jalr	190(ra) # 80002cd4 <bwrite>
  brelse(buf);
    80003c1e:	854a                	mv	a0,s2
    80003c20:	fffff097          	auipc	ra,0xfffff
    80003c24:	0f4080e7          	jalr	244(ra) # 80002d14 <brelse>
}
    80003c28:	70a2                	ld	ra,40(sp)
    80003c2a:	7402                	ld	s0,32(sp)
    80003c2c:	64e2                	ld	s1,24(sp)
    80003c2e:	6942                	ld	s2,16(sp)
    80003c30:	69a2                	ld	s3,8(sp)
    80003c32:	6145                	addi	sp,sp,48
    80003c34:	8082                	ret

0000000080003c36 <write_log>:
static void
write_log(int dev)
{
  int tail;

  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003c36:	0a800793          	li	a5,168
    80003c3a:	02f50733          	mul	a4,a0,a5
    80003c3e:	0001e797          	auipc	a5,0x1e
    80003c42:	b5a78793          	addi	a5,a5,-1190 # 80021798 <log>
    80003c46:	97ba                	add	a5,a5,a4
    80003c48:	57dc                	lw	a5,44(a5)
    80003c4a:	0af05663          	blez	a5,80003cf6 <write_log+0xc0>
{
    80003c4e:	7139                	addi	sp,sp,-64
    80003c50:	fc06                	sd	ra,56(sp)
    80003c52:	f822                	sd	s0,48(sp)
    80003c54:	f426                	sd	s1,40(sp)
    80003c56:	f04a                	sd	s2,32(sp)
    80003c58:	ec4e                	sd	s3,24(sp)
    80003c5a:	e852                	sd	s4,16(sp)
    80003c5c:	e456                	sd	s5,8(sp)
    80003c5e:	e05a                	sd	s6,0(sp)
    80003c60:	0080                	addi	s0,sp,64
    80003c62:	0001e797          	auipc	a5,0x1e
    80003c66:	b6678793          	addi	a5,a5,-1178 # 800217c8 <log+0x30>
    80003c6a:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003c6e:	4981                	li	s3,0
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80003c70:	00050b1b          	sext.w	s6,a0
    80003c74:	0001ea97          	auipc	s5,0x1e
    80003c78:	b24a8a93          	addi	s5,s5,-1244 # 80021798 <log>
    80003c7c:	9aba                	add	s5,s5,a4
    80003c7e:	018aa583          	lw	a1,24(s5)
    80003c82:	013585bb          	addw	a1,a1,s3
    80003c86:	2585                	addiw	a1,a1,1
    80003c88:	855a                	mv	a0,s6
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	f56080e7          	jalr	-170(ra) # 80002be0 <bread>
    80003c92:	84aa                	mv	s1,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    80003c94:	000a2583          	lw	a1,0(s4)
    80003c98:	855a                	mv	a0,s6
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	f46080e7          	jalr	-186(ra) # 80002be0 <bread>
    80003ca2:	892a                	mv	s2,a0
    memmove(to->data, from->data, BSIZE);
    80003ca4:	40000613          	li	a2,1024
    80003ca8:	06050593          	addi	a1,a0,96
    80003cac:	06048513          	addi	a0,s1,96
    80003cb0:	ffffd097          	auipc	ra,0xffffd
    80003cb4:	f46080e7          	jalr	-186(ra) # 80000bf6 <memmove>
    bwrite(to);  // write the log
    80003cb8:	8526                	mv	a0,s1
    80003cba:	fffff097          	auipc	ra,0xfffff
    80003cbe:	01a080e7          	jalr	26(ra) # 80002cd4 <bwrite>
    brelse(from);
    80003cc2:	854a                	mv	a0,s2
    80003cc4:	fffff097          	auipc	ra,0xfffff
    80003cc8:	050080e7          	jalr	80(ra) # 80002d14 <brelse>
    brelse(to);
    80003ccc:	8526                	mv	a0,s1
    80003cce:	fffff097          	auipc	ra,0xfffff
    80003cd2:	046080e7          	jalr	70(ra) # 80002d14 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003cd6:	2985                	addiw	s3,s3,1
    80003cd8:	0a11                	addi	s4,s4,4
    80003cda:	02caa783          	lw	a5,44(s5)
    80003cde:	faf9c0e3          	blt	s3,a5,80003c7e <write_log+0x48>
  }
}
    80003ce2:	70e2                	ld	ra,56(sp)
    80003ce4:	7442                	ld	s0,48(sp)
    80003ce6:	74a2                	ld	s1,40(sp)
    80003ce8:	7902                	ld	s2,32(sp)
    80003cea:	69e2                	ld	s3,24(sp)
    80003cec:	6a42                	ld	s4,16(sp)
    80003cee:	6aa2                	ld	s5,8(sp)
    80003cf0:	6b02                	ld	s6,0(sp)
    80003cf2:	6121                	addi	sp,sp,64
    80003cf4:	8082                	ret
    80003cf6:	8082                	ret

0000000080003cf8 <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003cf8:	0a800793          	li	a5,168
    80003cfc:	02f50733          	mul	a4,a0,a5
    80003d00:	0001e797          	auipc	a5,0x1e
    80003d04:	a9878793          	addi	a5,a5,-1384 # 80021798 <log>
    80003d08:	97ba                	add	a5,a5,a4
    80003d0a:	57dc                	lw	a5,44(a5)
    80003d0c:	0af05b63          	blez	a5,80003dc2 <install_trans+0xca>
{
    80003d10:	7139                	addi	sp,sp,-64
    80003d12:	fc06                	sd	ra,56(sp)
    80003d14:	f822                	sd	s0,48(sp)
    80003d16:	f426                	sd	s1,40(sp)
    80003d18:	f04a                	sd	s2,32(sp)
    80003d1a:	ec4e                	sd	s3,24(sp)
    80003d1c:	e852                	sd	s4,16(sp)
    80003d1e:	e456                	sd	s5,8(sp)
    80003d20:	e05a                	sd	s6,0(sp)
    80003d22:	0080                	addi	s0,sp,64
    80003d24:	0001e797          	auipc	a5,0x1e
    80003d28:	aa478793          	addi	a5,a5,-1372 # 800217c8 <log+0x30>
    80003d2c:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003d30:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80003d32:	00050b1b          	sext.w	s6,a0
    80003d36:	0001ea97          	auipc	s5,0x1e
    80003d3a:	a62a8a93          	addi	s5,s5,-1438 # 80021798 <log>
    80003d3e:	9aba                	add	s5,s5,a4
    80003d40:	018aa583          	lw	a1,24(s5)
    80003d44:	013585bb          	addw	a1,a1,s3
    80003d48:	2585                	addiw	a1,a1,1
    80003d4a:	855a                	mv	a0,s6
    80003d4c:	fffff097          	auipc	ra,0xfffff
    80003d50:	e94080e7          	jalr	-364(ra) # 80002be0 <bread>
    80003d54:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    80003d56:	000a2583          	lw	a1,0(s4)
    80003d5a:	855a                	mv	a0,s6
    80003d5c:	fffff097          	auipc	ra,0xfffff
    80003d60:	e84080e7          	jalr	-380(ra) # 80002be0 <bread>
    80003d64:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003d66:	40000613          	li	a2,1024
    80003d6a:	06090593          	addi	a1,s2,96
    80003d6e:	06050513          	addi	a0,a0,96
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	e84080e7          	jalr	-380(ra) # 80000bf6 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003d7a:	8526                	mv	a0,s1
    80003d7c:	fffff097          	auipc	ra,0xfffff
    80003d80:	f58080e7          	jalr	-168(ra) # 80002cd4 <bwrite>
    bunpin(dbuf);
    80003d84:	8526                	mv	a0,s1
    80003d86:	fffff097          	auipc	ra,0xfffff
    80003d8a:	068080e7          	jalr	104(ra) # 80002dee <bunpin>
    brelse(lbuf);
    80003d8e:	854a                	mv	a0,s2
    80003d90:	fffff097          	auipc	ra,0xfffff
    80003d94:	f84080e7          	jalr	-124(ra) # 80002d14 <brelse>
    brelse(dbuf);
    80003d98:	8526                	mv	a0,s1
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	f7a080e7          	jalr	-134(ra) # 80002d14 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80003da2:	2985                	addiw	s3,s3,1
    80003da4:	0a11                	addi	s4,s4,4
    80003da6:	02caa783          	lw	a5,44(s5)
    80003daa:	f8f9cbe3          	blt	s3,a5,80003d40 <install_trans+0x48>
}
    80003dae:	70e2                	ld	ra,56(sp)
    80003db0:	7442                	ld	s0,48(sp)
    80003db2:	74a2                	ld	s1,40(sp)
    80003db4:	7902                	ld	s2,32(sp)
    80003db6:	69e2                	ld	s3,24(sp)
    80003db8:	6a42                	ld	s4,16(sp)
    80003dba:	6aa2                	ld	s5,8(sp)
    80003dbc:	6b02                	ld	s6,0(sp)
    80003dbe:	6121                	addi	sp,sp,64
    80003dc0:	8082                	ret
    80003dc2:	8082                	ret

0000000080003dc4 <initlog>:
{
    80003dc4:	7179                	addi	sp,sp,-48
    80003dc6:	f406                	sd	ra,40(sp)
    80003dc8:	f022                	sd	s0,32(sp)
    80003dca:	ec26                	sd	s1,24(sp)
    80003dcc:	e84a                	sd	s2,16(sp)
    80003dce:	e44e                	sd	s3,8(sp)
    80003dd0:	e052                	sd	s4,0(sp)
    80003dd2:	1800                	addi	s0,sp,48
    80003dd4:	84aa                	mv	s1,a0
    80003dd6:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    80003dd8:	0a800713          	li	a4,168
    80003ddc:	02e509b3          	mul	s3,a0,a4
    80003de0:	0001e917          	auipc	s2,0x1e
    80003de4:	9b890913          	addi	s2,s2,-1608 # 80021798 <log>
    80003de8:	994e                	add	s2,s2,s3
    80003dea:	00003597          	auipc	a1,0x3
    80003dee:	7fe58593          	addi	a1,a1,2046 # 800075e8 <userret+0x558>
    80003df2:	854a                	mv	a0,s2
    80003df4:	ffffd097          	auipc	ra,0xffffd
    80003df8:	bcc080e7          	jalr	-1076(ra) # 800009c0 <initlock>
  log[dev].start = sb->logstart;
    80003dfc:	014a2583          	lw	a1,20(s4)
    80003e00:	00b92c23          	sw	a1,24(s2)
  log[dev].size = sb->nlog;
    80003e04:	010a2783          	lw	a5,16(s4)
    80003e08:	00f92e23          	sw	a5,28(s2)
  log[dev].dev = dev;
    80003e0c:	02992423          	sw	s1,40(s2)
  struct buf *buf = bread(dev, log[dev].start);
    80003e10:	8526                	mv	a0,s1
    80003e12:	fffff097          	auipc	ra,0xfffff
    80003e16:	dce080e7          	jalr	-562(ra) # 80002be0 <bread>
  log[dev].lh.n = lh->n;
    80003e1a:	513c                	lw	a5,96(a0)
    80003e1c:	02f92623          	sw	a5,44(s2)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e20:	02f05663          	blez	a5,80003e4c <initlog+0x88>
    80003e24:	06450693          	addi	a3,a0,100
    80003e28:	0001e717          	auipc	a4,0x1e
    80003e2c:	9a070713          	addi	a4,a4,-1632 # 800217c8 <log+0x30>
    80003e30:	974e                	add	a4,a4,s3
    80003e32:	37fd                	addiw	a5,a5,-1
    80003e34:	1782                	slli	a5,a5,0x20
    80003e36:	9381                	srli	a5,a5,0x20
    80003e38:	078a                	slli	a5,a5,0x2
    80003e3a:	06850613          	addi	a2,a0,104
    80003e3e:	97b2                	add	a5,a5,a2
    log[dev].lh.block[i] = lh->block[i];
    80003e40:	4290                	lw	a2,0(a3)
    80003e42:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    80003e44:	0691                	addi	a3,a3,4
    80003e46:	0711                	addi	a4,a4,4
    80003e48:	fef69ce3          	bne	a3,a5,80003e40 <initlog+0x7c>
  brelse(buf);
    80003e4c:	fffff097          	auipc	ra,0xfffff
    80003e50:	ec8080e7          	jalr	-312(ra) # 80002d14 <brelse>
  install_trans(dev); // if committed, copy from log to disk
    80003e54:	8526                	mv	a0,s1
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	ea2080e7          	jalr	-350(ra) # 80003cf8 <install_trans>
  log[dev].lh.n = 0;
    80003e5e:	0a800793          	li	a5,168
    80003e62:	02f48733          	mul	a4,s1,a5
    80003e66:	0001e797          	auipc	a5,0x1e
    80003e6a:	93278793          	addi	a5,a5,-1742 # 80021798 <log>
    80003e6e:	97ba                	add	a5,a5,a4
    80003e70:	0207a623          	sw	zero,44(a5)
  write_head(dev); // clear the log
    80003e74:	8526                	mv	a0,s1
    80003e76:	00000097          	auipc	ra,0x0
    80003e7a:	d36080e7          	jalr	-714(ra) # 80003bac <write_head>
}
    80003e7e:	70a2                	ld	ra,40(sp)
    80003e80:	7402                	ld	s0,32(sp)
    80003e82:	64e2                	ld	s1,24(sp)
    80003e84:	6942                	ld	s2,16(sp)
    80003e86:	69a2                	ld	s3,8(sp)
    80003e88:	6a02                	ld	s4,0(sp)
    80003e8a:	6145                	addi	sp,sp,48
    80003e8c:	8082                	ret

0000000080003e8e <begin_op>:
{
    80003e8e:	7139                	addi	sp,sp,-64
    80003e90:	fc06                	sd	ra,56(sp)
    80003e92:	f822                	sd	s0,48(sp)
    80003e94:	f426                	sd	s1,40(sp)
    80003e96:	f04a                	sd	s2,32(sp)
    80003e98:	ec4e                	sd	s3,24(sp)
    80003e9a:	e852                	sd	s4,16(sp)
    80003e9c:	e456                	sd	s5,8(sp)
    80003e9e:	0080                	addi	s0,sp,64
    80003ea0:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80003ea2:	0a800913          	li	s2,168
    80003ea6:	032507b3          	mul	a5,a0,s2
    80003eaa:	0001e917          	auipc	s2,0x1e
    80003eae:	8ee90913          	addi	s2,s2,-1810 # 80021798 <log>
    80003eb2:	993e                	add	s2,s2,a5
    80003eb4:	854a                	mv	a0,s2
    80003eb6:	ffffd097          	auipc	ra,0xffffd
    80003eba:	c1c080e7          	jalr	-996(ra) # 80000ad2 <acquire>
    if(log[dev].committing){
    80003ebe:	0001e997          	auipc	s3,0x1e
    80003ec2:	8da98993          	addi	s3,s3,-1830 # 80021798 <log>
    80003ec6:	84ca                	mv	s1,s2
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ec8:	4a79                	li	s4,30
    80003eca:	a039                	j	80003ed8 <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    80003ecc:	85ca                	mv	a1,s2
    80003ece:	854e                	mv	a0,s3
    80003ed0:	ffffe097          	auipc	ra,0xffffe
    80003ed4:	16a080e7          	jalr	362(ra) # 8000203a <sleep>
    if(log[dev].committing){
    80003ed8:	50dc                	lw	a5,36(s1)
    80003eda:	fbed                	bnez	a5,80003ecc <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003edc:	509c                	lw	a5,32(s1)
    80003ede:	0017871b          	addiw	a4,a5,1
    80003ee2:	0007069b          	sext.w	a3,a4
    80003ee6:	0027179b          	slliw	a5,a4,0x2
    80003eea:	9fb9                	addw	a5,a5,a4
    80003eec:	0017979b          	slliw	a5,a5,0x1
    80003ef0:	54d8                	lw	a4,44(s1)
    80003ef2:	9fb9                	addw	a5,a5,a4
    80003ef4:	00fa5963          	bge	s4,a5,80003f06 <begin_op+0x78>
      sleep(&log, &log[dev].lock);
    80003ef8:	85ca                	mv	a1,s2
    80003efa:	854e                	mv	a0,s3
    80003efc:	ffffe097          	auipc	ra,0xffffe
    80003f00:	13e080e7          	jalr	318(ra) # 8000203a <sleep>
    80003f04:	bfd1                	j	80003ed8 <begin_op+0x4a>
      log[dev].outstanding += 1;
    80003f06:	0a800513          	li	a0,168
    80003f0a:	02aa8ab3          	mul	s5,s5,a0
    80003f0e:	0001e797          	auipc	a5,0x1e
    80003f12:	88a78793          	addi	a5,a5,-1910 # 80021798 <log>
    80003f16:	9abe                	add	s5,s5,a5
    80003f18:	02daa023          	sw	a3,32(s5)
      release(&log[dev].lock);
    80003f1c:	854a                	mv	a0,s2
    80003f1e:	ffffd097          	auipc	ra,0xffffd
    80003f22:	c1c080e7          	jalr	-996(ra) # 80000b3a <release>
}
    80003f26:	70e2                	ld	ra,56(sp)
    80003f28:	7442                	ld	s0,48(sp)
    80003f2a:	74a2                	ld	s1,40(sp)
    80003f2c:	7902                	ld	s2,32(sp)
    80003f2e:	69e2                	ld	s3,24(sp)
    80003f30:	6a42                	ld	s4,16(sp)
    80003f32:	6aa2                	ld	s5,8(sp)
    80003f34:	6121                	addi	sp,sp,64
    80003f36:	8082                	ret

0000000080003f38 <end_op>:
{
    80003f38:	7179                	addi	sp,sp,-48
    80003f3a:	f406                	sd	ra,40(sp)
    80003f3c:	f022                	sd	s0,32(sp)
    80003f3e:	ec26                	sd	s1,24(sp)
    80003f40:	e84a                	sd	s2,16(sp)
    80003f42:	e44e                	sd	s3,8(sp)
    80003f44:	1800                	addi	s0,sp,48
    80003f46:	892a                	mv	s2,a0
  acquire(&log[dev].lock);
    80003f48:	0a800493          	li	s1,168
    80003f4c:	029507b3          	mul	a5,a0,s1
    80003f50:	0001e497          	auipc	s1,0x1e
    80003f54:	84848493          	addi	s1,s1,-1976 # 80021798 <log>
    80003f58:	94be                	add	s1,s1,a5
    80003f5a:	8526                	mv	a0,s1
    80003f5c:	ffffd097          	auipc	ra,0xffffd
    80003f60:	b76080e7          	jalr	-1162(ra) # 80000ad2 <acquire>
  log[dev].outstanding -= 1;
    80003f64:	509c                	lw	a5,32(s1)
    80003f66:	37fd                	addiw	a5,a5,-1
    80003f68:	0007871b          	sext.w	a4,a5
    80003f6c:	d09c                	sw	a5,32(s1)
  if(log[dev].committing)
    80003f6e:	50dc                	lw	a5,36(s1)
    80003f70:	e3ad                	bnez	a5,80003fd2 <end_op+0x9a>
  if(log[dev].outstanding == 0){
    80003f72:	eb25                	bnez	a4,80003fe2 <end_op+0xaa>
    log[dev].committing = 1;
    80003f74:	0a800993          	li	s3,168
    80003f78:	033907b3          	mul	a5,s2,s3
    80003f7c:	0001e997          	auipc	s3,0x1e
    80003f80:	81c98993          	addi	s3,s3,-2020 # 80021798 <log>
    80003f84:	99be                	add	s3,s3,a5
    80003f86:	4785                	li	a5,1
    80003f88:	02f9a223          	sw	a5,36(s3)
  release(&log[dev].lock);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	ffffd097          	auipc	ra,0xffffd
    80003f92:	bac080e7          	jalr	-1108(ra) # 80000b3a <release>

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80003f96:	02c9a783          	lw	a5,44(s3)
    80003f9a:	06f04863          	bgtz	a5,8000400a <end_op+0xd2>
    acquire(&log[dev].lock);
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	b32080e7          	jalr	-1230(ra) # 80000ad2 <acquire>
    log[dev].committing = 0;
    80003fa8:	0001d517          	auipc	a0,0x1d
    80003fac:	7f050513          	addi	a0,a0,2032 # 80021798 <log>
    80003fb0:	0a800793          	li	a5,168
    80003fb4:	02f90933          	mul	s2,s2,a5
    80003fb8:	992a                	add	s2,s2,a0
    80003fba:	02092223          	sw	zero,36(s2)
    wakeup(&log);
    80003fbe:	ffffe097          	auipc	ra,0xffffe
    80003fc2:	1c8080e7          	jalr	456(ra) # 80002186 <wakeup>
    release(&log[dev].lock);
    80003fc6:	8526                	mv	a0,s1
    80003fc8:	ffffd097          	auipc	ra,0xffffd
    80003fcc:	b72080e7          	jalr	-1166(ra) # 80000b3a <release>
}
    80003fd0:	a035                	j	80003ffc <end_op+0xc4>
    panic("log[dev].committing");
    80003fd2:	00003517          	auipc	a0,0x3
    80003fd6:	61e50513          	addi	a0,a0,1566 # 800075f0 <userret+0x560>
    80003fda:	ffffc097          	auipc	ra,0xffffc
    80003fde:	574080e7          	jalr	1396(ra) # 8000054e <panic>
    wakeup(&log);
    80003fe2:	0001d517          	auipc	a0,0x1d
    80003fe6:	7b650513          	addi	a0,a0,1974 # 80021798 <log>
    80003fea:	ffffe097          	auipc	ra,0xffffe
    80003fee:	19c080e7          	jalr	412(ra) # 80002186 <wakeup>
  release(&log[dev].lock);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	b46080e7          	jalr	-1210(ra) # 80000b3a <release>
}
    80003ffc:	70a2                	ld	ra,40(sp)
    80003ffe:	7402                	ld	s0,32(sp)
    80004000:	64e2                	ld	s1,24(sp)
    80004002:	6942                	ld	s2,16(sp)
    80004004:	69a2                	ld	s3,8(sp)
    80004006:	6145                	addi	sp,sp,48
    80004008:	8082                	ret
    write_log(dev);     // Write modified blocks from cache to log
    8000400a:	854a                	mv	a0,s2
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	c2a080e7          	jalr	-982(ra) # 80003c36 <write_log>
    write_head(dev);    // Write header to disk -- the real commit
    80004014:	854a                	mv	a0,s2
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	b96080e7          	jalr	-1130(ra) # 80003bac <write_head>
    install_trans(dev); // Now install writes to home locations
    8000401e:	854a                	mv	a0,s2
    80004020:	00000097          	auipc	ra,0x0
    80004024:	cd8080e7          	jalr	-808(ra) # 80003cf8 <install_trans>
    log[dev].lh.n = 0;
    80004028:	0a800793          	li	a5,168
    8000402c:	02f90733          	mul	a4,s2,a5
    80004030:	0001d797          	auipc	a5,0x1d
    80004034:	76878793          	addi	a5,a5,1896 # 80021798 <log>
    80004038:	97ba                	add	a5,a5,a4
    8000403a:	0207a623          	sw	zero,44(a5)
    write_head(dev);    // Erase the transaction from the log
    8000403e:	854a                	mv	a0,s2
    80004040:	00000097          	auipc	ra,0x0
    80004044:	b6c080e7          	jalr	-1172(ra) # 80003bac <write_head>
    80004048:	bf99                	j	80003f9e <end_op+0x66>

000000008000404a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000404a:	7179                	addi	sp,sp,-48
    8000404c:	f406                	sd	ra,40(sp)
    8000404e:	f022                	sd	s0,32(sp)
    80004050:	ec26                	sd	s1,24(sp)
    80004052:	e84a                	sd	s2,16(sp)
    80004054:	e44e                	sd	s3,8(sp)
    80004056:	e052                	sd	s4,0(sp)
    80004058:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    8000405a:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    8000405e:	0a800793          	li	a5,168
    80004062:	02f90733          	mul	a4,s2,a5
    80004066:	0001d797          	auipc	a5,0x1d
    8000406a:	73278793          	addi	a5,a5,1842 # 80021798 <log>
    8000406e:	97ba                	add	a5,a5,a4
    80004070:	57d4                	lw	a3,44(a5)
    80004072:	47f5                	li	a5,29
    80004074:	0ad7cc63          	blt	a5,a3,8000412c <log_write+0xe2>
    80004078:	89aa                	mv	s3,a0
    8000407a:	0001d797          	auipc	a5,0x1d
    8000407e:	71e78793          	addi	a5,a5,1822 # 80021798 <log>
    80004082:	97ba                	add	a5,a5,a4
    80004084:	4fdc                	lw	a5,28(a5)
    80004086:	37fd                	addiw	a5,a5,-1
    80004088:	0af6d263          	bge	a3,a5,8000412c <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    8000408c:	0a800793          	li	a5,168
    80004090:	02f90733          	mul	a4,s2,a5
    80004094:	0001d797          	auipc	a5,0x1d
    80004098:	70478793          	addi	a5,a5,1796 # 80021798 <log>
    8000409c:	97ba                	add	a5,a5,a4
    8000409e:	539c                	lw	a5,32(a5)
    800040a0:	08f05e63          	blez	a5,8000413c <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    800040a4:	0a800793          	li	a5,168
    800040a8:	02f904b3          	mul	s1,s2,a5
    800040ac:	0001da17          	auipc	s4,0x1d
    800040b0:	6eca0a13          	addi	s4,s4,1772 # 80021798 <log>
    800040b4:	9a26                	add	s4,s4,s1
    800040b6:	8552                	mv	a0,s4
    800040b8:	ffffd097          	auipc	ra,0xffffd
    800040bc:	a1a080e7          	jalr	-1510(ra) # 80000ad2 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    800040c0:	02ca2603          	lw	a2,44(s4)
    800040c4:	08c05463          	blez	a2,8000414c <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800040c8:	00c9a583          	lw	a1,12(s3)
    800040cc:	0001d797          	auipc	a5,0x1d
    800040d0:	6fc78793          	addi	a5,a5,1788 # 800217c8 <log+0x30>
    800040d4:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    800040d6:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    800040d8:	4394                	lw	a3,0(a5)
    800040da:	06b68a63          	beq	a3,a1,8000414e <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    800040de:	2705                	addiw	a4,a4,1
    800040e0:	0791                	addi	a5,a5,4
    800040e2:	fec71be3          	bne	a4,a2,800040d8 <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    800040e6:	02a00793          	li	a5,42
    800040ea:	02f907b3          	mul	a5,s2,a5
    800040ee:	97b2                	add	a5,a5,a2
    800040f0:	07a1                	addi	a5,a5,8
    800040f2:	078a                	slli	a5,a5,0x2
    800040f4:	0001d717          	auipc	a4,0x1d
    800040f8:	6a470713          	addi	a4,a4,1700 # 80021798 <log>
    800040fc:	97ba                	add	a5,a5,a4
    800040fe:	00c9a703          	lw	a4,12(s3)
    80004102:	cb98                	sw	a4,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    80004104:	854e                	mv	a0,s3
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	cac080e7          	jalr	-852(ra) # 80002db2 <bpin>
    log[dev].lh.n++;
    8000410e:	0a800793          	li	a5,168
    80004112:	02f90933          	mul	s2,s2,a5
    80004116:	0001d797          	auipc	a5,0x1d
    8000411a:	68278793          	addi	a5,a5,1666 # 80021798 <log>
    8000411e:	993e                	add	s2,s2,a5
    80004120:	02c92783          	lw	a5,44(s2)
    80004124:	2785                	addiw	a5,a5,1
    80004126:	02f92623          	sw	a5,44(s2)
    8000412a:	a099                	j	80004170 <log_write+0x126>
    panic("too big a transaction");
    8000412c:	00003517          	auipc	a0,0x3
    80004130:	4dc50513          	addi	a0,a0,1244 # 80007608 <userret+0x578>
    80004134:	ffffc097          	auipc	ra,0xffffc
    80004138:	41a080e7          	jalr	1050(ra) # 8000054e <panic>
    panic("log_write outside of trans");
    8000413c:	00003517          	auipc	a0,0x3
    80004140:	4e450513          	addi	a0,a0,1252 # 80007620 <userret+0x590>
    80004144:	ffffc097          	auipc	ra,0xffffc
    80004148:	40a080e7          	jalr	1034(ra) # 8000054e <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    8000414c:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    8000414e:	02a00793          	li	a5,42
    80004152:	02f907b3          	mul	a5,s2,a5
    80004156:	97ba                	add	a5,a5,a4
    80004158:	07a1                	addi	a5,a5,8
    8000415a:	078a                	slli	a5,a5,0x2
    8000415c:	0001d697          	auipc	a3,0x1d
    80004160:	63c68693          	addi	a3,a3,1596 # 80021798 <log>
    80004164:	97b6                	add	a5,a5,a3
    80004166:	00c9a683          	lw	a3,12(s3)
    8000416a:	cb94                	sw	a3,16(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    8000416c:	f8e60ce3          	beq	a2,a4,80004104 <log_write+0xba>
  }
  release(&log[dev].lock);
    80004170:	8552                	mv	a0,s4
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	9c8080e7          	jalr	-1592(ra) # 80000b3a <release>
}
    8000417a:	70a2                	ld	ra,40(sp)
    8000417c:	7402                	ld	s0,32(sp)
    8000417e:	64e2                	ld	s1,24(sp)
    80004180:	6942                	ld	s2,16(sp)
    80004182:	69a2                	ld	s3,8(sp)
    80004184:	6a02                	ld	s4,0(sp)
    80004186:	6145                	addi	sp,sp,48
    80004188:	8082                	ret

000000008000418a <crash_op>:

// crash before commit or after commit
void
crash_op(int dev, int docommit)
{
    8000418a:	7179                	addi	sp,sp,-48
    8000418c:	f406                	sd	ra,40(sp)
    8000418e:	f022                	sd	s0,32(sp)
    80004190:	ec26                	sd	s1,24(sp)
    80004192:	e84a                	sd	s2,16(sp)
    80004194:	e44e                	sd	s3,8(sp)
    80004196:	1800                	addi	s0,sp,48
    80004198:	84aa                	mv	s1,a0
    8000419a:	89ae                	mv	s3,a1
  int do_commit = 0;
    
  acquire(&log[dev].lock);
    8000419c:	0a800913          	li	s2,168
    800041a0:	032507b3          	mul	a5,a0,s2
    800041a4:	0001d917          	auipc	s2,0x1d
    800041a8:	5f490913          	addi	s2,s2,1524 # 80021798 <log>
    800041ac:	993e                	add	s2,s2,a5
    800041ae:	854a                	mv	a0,s2
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	922080e7          	jalr	-1758(ra) # 80000ad2 <acquire>

  if (dev < 0 || dev >= NDISK)
    800041b8:	0004871b          	sext.w	a4,s1
    800041bc:	4785                	li	a5,1
    800041be:	0ae7e063          	bltu	a5,a4,8000425e <crash_op+0xd4>
    panic("end_op: invalid disk");
  if(log[dev].outstanding == 0)
    800041c2:	0a800793          	li	a5,168
    800041c6:	02f48733          	mul	a4,s1,a5
    800041ca:	0001d797          	auipc	a5,0x1d
    800041ce:	5ce78793          	addi	a5,a5,1486 # 80021798 <log>
    800041d2:	97ba                	add	a5,a5,a4
    800041d4:	539c                	lw	a5,32(a5)
    800041d6:	cfc1                	beqz	a5,8000426e <crash_op+0xe4>
    panic("end_op: already closed");
  log[dev].outstanding -= 1;
    800041d8:	37fd                	addiw	a5,a5,-1
    800041da:	0007861b          	sext.w	a2,a5
    800041de:	0a800713          	li	a4,168
    800041e2:	02e486b3          	mul	a3,s1,a4
    800041e6:	0001d717          	auipc	a4,0x1d
    800041ea:	5b270713          	addi	a4,a4,1458 # 80021798 <log>
    800041ee:	9736                	add	a4,a4,a3
    800041f0:	d31c                	sw	a5,32(a4)
  if(log[dev].committing)
    800041f2:	535c                	lw	a5,36(a4)
    800041f4:	e7c9                	bnez	a5,8000427e <crash_op+0xf4>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    800041f6:	ee41                	bnez	a2,8000428e <crash_op+0x104>
    do_commit = 1;
    log[dev].committing = 1;
    800041f8:	0a800793          	li	a5,168
    800041fc:	02f48733          	mul	a4,s1,a5
    80004200:	0001d797          	auipc	a5,0x1d
    80004204:	59878793          	addi	a5,a5,1432 # 80021798 <log>
    80004208:	97ba                	add	a5,a5,a4
    8000420a:	4705                	li	a4,1
    8000420c:	d3d8                	sw	a4,36(a5)
  }
  
  release(&log[dev].lock);
    8000420e:	854a                	mv	a0,s2
    80004210:	ffffd097          	auipc	ra,0xffffd
    80004214:	92a080e7          	jalr	-1750(ra) # 80000b3a <release>

  if(docommit & do_commit){
    80004218:	0019f993          	andi	s3,s3,1
    8000421c:	06098e63          	beqz	s3,80004298 <crash_op+0x10e>
    printf("crash_op: commit\n");
    80004220:	00003517          	auipc	a0,0x3
    80004224:	45050513          	addi	a0,a0,1104 # 80007670 <userret+0x5e0>
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	370080e7          	jalr	880(ra) # 80000598 <printf>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.

    if (log[dev].lh.n > 0) {
    80004230:	0a800793          	li	a5,168
    80004234:	02f48733          	mul	a4,s1,a5
    80004238:	0001d797          	auipc	a5,0x1d
    8000423c:	56078793          	addi	a5,a5,1376 # 80021798 <log>
    80004240:	97ba                	add	a5,a5,a4
    80004242:	57dc                	lw	a5,44(a5)
    80004244:	04f05a63          	blez	a5,80004298 <crash_op+0x10e>
      write_log(dev);     // Write modified blocks from cache to log
    80004248:	8526                	mv	a0,s1
    8000424a:	00000097          	auipc	ra,0x0
    8000424e:	9ec080e7          	jalr	-1556(ra) # 80003c36 <write_log>
      write_head(dev);    // Write header to disk -- the real commit
    80004252:	8526                	mv	a0,s1
    80004254:	00000097          	auipc	ra,0x0
    80004258:	958080e7          	jalr	-1704(ra) # 80003bac <write_head>
    8000425c:	a835                	j	80004298 <crash_op+0x10e>
    panic("end_op: invalid disk");
    8000425e:	00003517          	auipc	a0,0x3
    80004262:	3e250513          	addi	a0,a0,994 # 80007640 <userret+0x5b0>
    80004266:	ffffc097          	auipc	ra,0xffffc
    8000426a:	2e8080e7          	jalr	744(ra) # 8000054e <panic>
    panic("end_op: already closed");
    8000426e:	00003517          	auipc	a0,0x3
    80004272:	3ea50513          	addi	a0,a0,1002 # 80007658 <userret+0x5c8>
    80004276:	ffffc097          	auipc	ra,0xffffc
    8000427a:	2d8080e7          	jalr	728(ra) # 8000054e <panic>
    panic("log[dev].committing");
    8000427e:	00003517          	auipc	a0,0x3
    80004282:	37250513          	addi	a0,a0,882 # 800075f0 <userret+0x560>
    80004286:	ffffc097          	auipc	ra,0xffffc
    8000428a:	2c8080e7          	jalr	712(ra) # 8000054e <panic>
  release(&log[dev].lock);
    8000428e:	854a                	mv	a0,s2
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	8aa080e7          	jalr	-1878(ra) # 80000b3a <release>
    }
  }
  panic("crashed file system; please restart xv6 and run crashtest\n");
    80004298:	00003517          	auipc	a0,0x3
    8000429c:	3f050513          	addi	a0,a0,1008 # 80007688 <userret+0x5f8>
    800042a0:	ffffc097          	auipc	ra,0xffffc
    800042a4:	2ae080e7          	jalr	686(ra) # 8000054e <panic>

00000000800042a8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042a8:	1101                	addi	sp,sp,-32
    800042aa:	ec06                	sd	ra,24(sp)
    800042ac:	e822                	sd	s0,16(sp)
    800042ae:	e426                	sd	s1,8(sp)
    800042b0:	e04a                	sd	s2,0(sp)
    800042b2:	1000                	addi	s0,sp,32
    800042b4:	84aa                	mv	s1,a0
    800042b6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042b8:	00003597          	auipc	a1,0x3
    800042bc:	41058593          	addi	a1,a1,1040 # 800076c8 <userret+0x638>
    800042c0:	0521                	addi	a0,a0,8
    800042c2:	ffffc097          	auipc	ra,0xffffc
    800042c6:	6fe080e7          	jalr	1790(ra) # 800009c0 <initlock>
  lk->name = name;
    800042ca:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042ce:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042d2:	0204a423          	sw	zero,40(s1)
}
    800042d6:	60e2                	ld	ra,24(sp)
    800042d8:	6442                	ld	s0,16(sp)
    800042da:	64a2                	ld	s1,8(sp)
    800042dc:	6902                	ld	s2,0(sp)
    800042de:	6105                	addi	sp,sp,32
    800042e0:	8082                	ret

00000000800042e2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042e2:	1101                	addi	sp,sp,-32
    800042e4:	ec06                	sd	ra,24(sp)
    800042e6:	e822                	sd	s0,16(sp)
    800042e8:	e426                	sd	s1,8(sp)
    800042ea:	e04a                	sd	s2,0(sp)
    800042ec:	1000                	addi	s0,sp,32
    800042ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042f0:	00850913          	addi	s2,a0,8
    800042f4:	854a                	mv	a0,s2
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	7dc080e7          	jalr	2012(ra) # 80000ad2 <acquire>
  while (lk->locked) {
    800042fe:	409c                	lw	a5,0(s1)
    80004300:	cb89                	beqz	a5,80004312 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004302:	85ca                	mv	a1,s2
    80004304:	8526                	mv	a0,s1
    80004306:	ffffe097          	auipc	ra,0xffffe
    8000430a:	d34080e7          	jalr	-716(ra) # 8000203a <sleep>
  while (lk->locked) {
    8000430e:	409c                	lw	a5,0(s1)
    80004310:	fbed                	bnez	a5,80004302 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004312:	4785                	li	a5,1
    80004314:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	51e080e7          	jalr	1310(ra) # 80001834 <myproc>
    8000431e:	595c                	lw	a5,52(a0)
    80004320:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004322:	854a                	mv	a0,s2
    80004324:	ffffd097          	auipc	ra,0xffffd
    80004328:	816080e7          	jalr	-2026(ra) # 80000b3a <release>
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	64a2                	ld	s1,8(sp)
    80004332:	6902                	ld	s2,0(sp)
    80004334:	6105                	addi	sp,sp,32
    80004336:	8082                	ret

0000000080004338 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004338:	1101                	addi	sp,sp,-32
    8000433a:	ec06                	sd	ra,24(sp)
    8000433c:	e822                	sd	s0,16(sp)
    8000433e:	e426                	sd	s1,8(sp)
    80004340:	e04a                	sd	s2,0(sp)
    80004342:	1000                	addi	s0,sp,32
    80004344:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004346:	00850913          	addi	s2,a0,8
    8000434a:	854a                	mv	a0,s2
    8000434c:	ffffc097          	auipc	ra,0xffffc
    80004350:	786080e7          	jalr	1926(ra) # 80000ad2 <acquire>
  lk->locked = 0;
    80004354:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004358:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000435c:	8526                	mv	a0,s1
    8000435e:	ffffe097          	auipc	ra,0xffffe
    80004362:	e28080e7          	jalr	-472(ra) # 80002186 <wakeup>
  release(&lk->lk);
    80004366:	854a                	mv	a0,s2
    80004368:	ffffc097          	auipc	ra,0xffffc
    8000436c:	7d2080e7          	jalr	2002(ra) # 80000b3a <release>
}
    80004370:	60e2                	ld	ra,24(sp)
    80004372:	6442                	ld	s0,16(sp)
    80004374:	64a2                	ld	s1,8(sp)
    80004376:	6902                	ld	s2,0(sp)
    80004378:	6105                	addi	sp,sp,32
    8000437a:	8082                	ret

000000008000437c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000437c:	7179                	addi	sp,sp,-48
    8000437e:	f406                	sd	ra,40(sp)
    80004380:	f022                	sd	s0,32(sp)
    80004382:	ec26                	sd	s1,24(sp)
    80004384:	e84a                	sd	s2,16(sp)
    80004386:	e44e                	sd	s3,8(sp)
    80004388:	1800                	addi	s0,sp,48
    8000438a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000438c:	00850913          	addi	s2,a0,8
    80004390:	854a                	mv	a0,s2
    80004392:	ffffc097          	auipc	ra,0xffffc
    80004396:	740080e7          	jalr	1856(ra) # 80000ad2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000439a:	409c                	lw	a5,0(s1)
    8000439c:	ef99                	bnez	a5,800043ba <holdingsleep+0x3e>
    8000439e:	4481                	li	s1,0
  release(&lk->lk);
    800043a0:	854a                	mv	a0,s2
    800043a2:	ffffc097          	auipc	ra,0xffffc
    800043a6:	798080e7          	jalr	1944(ra) # 80000b3a <release>
  return r;
}
    800043aa:	8526                	mv	a0,s1
    800043ac:	70a2                	ld	ra,40(sp)
    800043ae:	7402                	ld	s0,32(sp)
    800043b0:	64e2                	ld	s1,24(sp)
    800043b2:	6942                	ld	s2,16(sp)
    800043b4:	69a2                	ld	s3,8(sp)
    800043b6:	6145                	addi	sp,sp,48
    800043b8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043ba:	0284a983          	lw	s3,40(s1)
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	476080e7          	jalr	1142(ra) # 80001834 <myproc>
    800043c6:	5944                	lw	s1,52(a0)
    800043c8:	413484b3          	sub	s1,s1,s3
    800043cc:	0014b493          	seqz	s1,s1
    800043d0:	bfc1                	j	800043a0 <holdingsleep+0x24>

00000000800043d2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043d2:	1141                	addi	sp,sp,-16
    800043d4:	e406                	sd	ra,8(sp)
    800043d6:	e022                	sd	s0,0(sp)
    800043d8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043da:	00003597          	auipc	a1,0x3
    800043de:	2fe58593          	addi	a1,a1,766 # 800076d8 <userret+0x648>
    800043e2:	0001d517          	auipc	a0,0x1d
    800043e6:	5a650513          	addi	a0,a0,1446 # 80021988 <ftable>
    800043ea:	ffffc097          	auipc	ra,0xffffc
    800043ee:	5d6080e7          	jalr	1494(ra) # 800009c0 <initlock>
}
    800043f2:	60a2                	ld	ra,8(sp)
    800043f4:	6402                	ld	s0,0(sp)
    800043f6:	0141                	addi	sp,sp,16
    800043f8:	8082                	ret

00000000800043fa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043fa:	1101                	addi	sp,sp,-32
    800043fc:	ec06                	sd	ra,24(sp)
    800043fe:	e822                	sd	s0,16(sp)
    80004400:	e426                	sd	s1,8(sp)
    80004402:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004404:	0001d517          	auipc	a0,0x1d
    80004408:	58450513          	addi	a0,a0,1412 # 80021988 <ftable>
    8000440c:	ffffc097          	auipc	ra,0xffffc
    80004410:	6c6080e7          	jalr	1734(ra) # 80000ad2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004414:	0001d497          	auipc	s1,0x1d
    80004418:	58c48493          	addi	s1,s1,1420 # 800219a0 <ftable+0x18>
    8000441c:	0001e717          	auipc	a4,0x1e
    80004420:	52470713          	addi	a4,a4,1316 # 80022940 <ftable+0xfb8>
    if(f->ref == 0){
    80004424:	40dc                	lw	a5,4(s1)
    80004426:	cf99                	beqz	a5,80004444 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004428:	02848493          	addi	s1,s1,40
    8000442c:	fee49ce3          	bne	s1,a4,80004424 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004430:	0001d517          	auipc	a0,0x1d
    80004434:	55850513          	addi	a0,a0,1368 # 80021988 <ftable>
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	702080e7          	jalr	1794(ra) # 80000b3a <release>
  return 0;
    80004440:	4481                	li	s1,0
    80004442:	a819                	j	80004458 <filealloc+0x5e>
      f->ref = 1;
    80004444:	4785                	li	a5,1
    80004446:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004448:	0001d517          	auipc	a0,0x1d
    8000444c:	54050513          	addi	a0,a0,1344 # 80021988 <ftable>
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	6ea080e7          	jalr	1770(ra) # 80000b3a <release>
}
    80004458:	8526                	mv	a0,s1
    8000445a:	60e2                	ld	ra,24(sp)
    8000445c:	6442                	ld	s0,16(sp)
    8000445e:	64a2                	ld	s1,8(sp)
    80004460:	6105                	addi	sp,sp,32
    80004462:	8082                	ret

0000000080004464 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004464:	1101                	addi	sp,sp,-32
    80004466:	ec06                	sd	ra,24(sp)
    80004468:	e822                	sd	s0,16(sp)
    8000446a:	e426                	sd	s1,8(sp)
    8000446c:	1000                	addi	s0,sp,32
    8000446e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004470:	0001d517          	auipc	a0,0x1d
    80004474:	51850513          	addi	a0,a0,1304 # 80021988 <ftable>
    80004478:	ffffc097          	auipc	ra,0xffffc
    8000447c:	65a080e7          	jalr	1626(ra) # 80000ad2 <acquire>
  if(f->ref < 1)
    80004480:	40dc                	lw	a5,4(s1)
    80004482:	02f05263          	blez	a5,800044a6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004486:	2785                	addiw	a5,a5,1
    80004488:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000448a:	0001d517          	auipc	a0,0x1d
    8000448e:	4fe50513          	addi	a0,a0,1278 # 80021988 <ftable>
    80004492:	ffffc097          	auipc	ra,0xffffc
    80004496:	6a8080e7          	jalr	1704(ra) # 80000b3a <release>
  return f;
}
    8000449a:	8526                	mv	a0,s1
    8000449c:	60e2                	ld	ra,24(sp)
    8000449e:	6442                	ld	s0,16(sp)
    800044a0:	64a2                	ld	s1,8(sp)
    800044a2:	6105                	addi	sp,sp,32
    800044a4:	8082                	ret
    panic("filedup");
    800044a6:	00003517          	auipc	a0,0x3
    800044aa:	23a50513          	addi	a0,a0,570 # 800076e0 <userret+0x650>
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	0a0080e7          	jalr	160(ra) # 8000054e <panic>

00000000800044b6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044b6:	7139                	addi	sp,sp,-64
    800044b8:	fc06                	sd	ra,56(sp)
    800044ba:	f822                	sd	s0,48(sp)
    800044bc:	f426                	sd	s1,40(sp)
    800044be:	f04a                	sd	s2,32(sp)
    800044c0:	ec4e                	sd	s3,24(sp)
    800044c2:	e852                	sd	s4,16(sp)
    800044c4:	e456                	sd	s5,8(sp)
    800044c6:	0080                	addi	s0,sp,64
    800044c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044ca:	0001d517          	auipc	a0,0x1d
    800044ce:	4be50513          	addi	a0,a0,1214 # 80021988 <ftable>
    800044d2:	ffffc097          	auipc	ra,0xffffc
    800044d6:	600080e7          	jalr	1536(ra) # 80000ad2 <acquire>
  if(f->ref < 1)
    800044da:	40dc                	lw	a5,4(s1)
    800044dc:	06f05563          	blez	a5,80004546 <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    800044e0:	37fd                	addiw	a5,a5,-1
    800044e2:	0007871b          	sext.w	a4,a5
    800044e6:	c0dc                	sw	a5,4(s1)
    800044e8:	06e04763          	bgtz	a4,80004556 <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044ec:	0004a903          	lw	s2,0(s1)
    800044f0:	0094ca83          	lbu	s5,9(s1)
    800044f4:	0104ba03          	ld	s4,16(s1)
    800044f8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044fc:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004500:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004504:	0001d517          	auipc	a0,0x1d
    80004508:	48450513          	addi	a0,a0,1156 # 80021988 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	62e080e7          	jalr	1582(ra) # 80000b3a <release>

  if(ff.type == FD_PIPE){
    80004514:	4785                	li	a5,1
    80004516:	06f90163          	beq	s2,a5,80004578 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000451a:	3979                	addiw	s2,s2,-2
    8000451c:	4785                	li	a5,1
    8000451e:	0527e463          	bltu	a5,s2,80004566 <fileclose+0xb0>
    begin_op(ff.ip->dev);
    80004522:	0009a503          	lw	a0,0(s3)
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	968080e7          	jalr	-1688(ra) # 80003e8e <begin_op>
    iput(ff.ip);
    8000452e:	854e                	mv	a0,s3
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	fc4080e7          	jalr	-60(ra) # 800034f4 <iput>
    end_op(ff.ip->dev);
    80004538:	0009a503          	lw	a0,0(s3)
    8000453c:	00000097          	auipc	ra,0x0
    80004540:	9fc080e7          	jalr	-1540(ra) # 80003f38 <end_op>
    80004544:	a00d                	j	80004566 <fileclose+0xb0>
    panic("fileclose");
    80004546:	00003517          	auipc	a0,0x3
    8000454a:	1a250513          	addi	a0,a0,418 # 800076e8 <userret+0x658>
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	000080e7          	jalr	ra # 8000054e <panic>
    release(&ftable.lock);
    80004556:	0001d517          	auipc	a0,0x1d
    8000455a:	43250513          	addi	a0,a0,1074 # 80021988 <ftable>
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	5dc080e7          	jalr	1500(ra) # 80000b3a <release>
  }
}
    80004566:	70e2                	ld	ra,56(sp)
    80004568:	7442                	ld	s0,48(sp)
    8000456a:	74a2                	ld	s1,40(sp)
    8000456c:	7902                	ld	s2,32(sp)
    8000456e:	69e2                	ld	s3,24(sp)
    80004570:	6a42                	ld	s4,16(sp)
    80004572:	6aa2                	ld	s5,8(sp)
    80004574:	6121                	addi	sp,sp,64
    80004576:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004578:	85d6                	mv	a1,s5
    8000457a:	8552                	mv	a0,s4
    8000457c:	00000097          	auipc	ra,0x0
    80004580:	348080e7          	jalr	840(ra) # 800048c4 <pipeclose>
    80004584:	b7cd                	j	80004566 <fileclose+0xb0>

0000000080004586 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004586:	715d                	addi	sp,sp,-80
    80004588:	e486                	sd	ra,72(sp)
    8000458a:	e0a2                	sd	s0,64(sp)
    8000458c:	fc26                	sd	s1,56(sp)
    8000458e:	f84a                	sd	s2,48(sp)
    80004590:	f44e                	sd	s3,40(sp)
    80004592:	0880                	addi	s0,sp,80
    80004594:	84aa                	mv	s1,a0
    80004596:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004598:	ffffd097          	auipc	ra,0xffffd
    8000459c:	29c080e7          	jalr	668(ra) # 80001834 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045a0:	409c                	lw	a5,0(s1)
    800045a2:	37f9                	addiw	a5,a5,-2
    800045a4:	4705                	li	a4,1
    800045a6:	04f76763          	bltu	a4,a5,800045f4 <filestat+0x6e>
    800045aa:	892a                	mv	s2,a0
    ilock(f->ip);
    800045ac:	6c88                	ld	a0,24(s1)
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	e38080e7          	jalr	-456(ra) # 800033e6 <ilock>
    stati(f->ip, &st);
    800045b6:	fb840593          	addi	a1,s0,-72
    800045ba:	6c88                	ld	a0,24(s1)
    800045bc:	fffff097          	auipc	ra,0xfffff
    800045c0:	090080e7          	jalr	144(ra) # 8000364c <stati>
    iunlock(f->ip);
    800045c4:	6c88                	ld	a0,24(s1)
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	ee2080e7          	jalr	-286(ra) # 800034a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045ce:	46e1                	li	a3,24
    800045d0:	fb840613          	addi	a2,s0,-72
    800045d4:	85ce                	mv	a1,s3
    800045d6:	04893503          	ld	a0,72(s2)
    800045da:	ffffd097          	auipc	ra,0xffffd
    800045de:	f80080e7          	jalr	-128(ra) # 8000155a <copyout>
    800045e2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045e6:	60a6                	ld	ra,72(sp)
    800045e8:	6406                	ld	s0,64(sp)
    800045ea:	74e2                	ld	s1,56(sp)
    800045ec:	7942                	ld	s2,48(sp)
    800045ee:	79a2                	ld	s3,40(sp)
    800045f0:	6161                	addi	sp,sp,80
    800045f2:	8082                	ret
  return -1;
    800045f4:	557d                	li	a0,-1
    800045f6:	bfc5                	j	800045e6 <filestat+0x60>

00000000800045f8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045f8:	7179                	addi	sp,sp,-48
    800045fa:	f406                	sd	ra,40(sp)
    800045fc:	f022                	sd	s0,32(sp)
    800045fe:	ec26                	sd	s1,24(sp)
    80004600:	e84a                	sd	s2,16(sp)
    80004602:	e44e                	sd	s3,8(sp)
    80004604:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004606:	00854783          	lbu	a5,8(a0)
    8000460a:	cfc1                	beqz	a5,800046a2 <fileread+0xaa>
    8000460c:	84aa                	mv	s1,a0
    8000460e:	89ae                	mv	s3,a1
    80004610:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004612:	411c                	lw	a5,0(a0)
    80004614:	4705                	li	a4,1
    80004616:	04e78963          	beq	a5,a4,80004668 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000461a:	470d                	li	a4,3
    8000461c:	04e78d63          	beq	a5,a4,80004676 <fileread+0x7e>
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004620:	4709                	li	a4,2
    80004622:	06e79863          	bne	a5,a4,80004692 <fileread+0x9a>
    ilock(f->ip);
    80004626:	6d08                	ld	a0,24(a0)
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	dbe080e7          	jalr	-578(ra) # 800033e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004630:	874a                	mv	a4,s2
    80004632:	5094                	lw	a3,32(s1)
    80004634:	864e                	mv	a2,s3
    80004636:	4585                	li	a1,1
    80004638:	6c88                	ld	a0,24(s1)
    8000463a:	fffff097          	auipc	ra,0xfffff
    8000463e:	03c080e7          	jalr	60(ra) # 80003676 <readi>
    80004642:	892a                	mv	s2,a0
    80004644:	00a05563          	blez	a0,8000464e <fileread+0x56>
      f->off += r;
    80004648:	509c                	lw	a5,32(s1)
    8000464a:	9fa9                	addw	a5,a5,a0
    8000464c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000464e:	6c88                	ld	a0,24(s1)
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	e58080e7          	jalr	-424(ra) # 800034a8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004658:	854a                	mv	a0,s2
    8000465a:	70a2                	ld	ra,40(sp)
    8000465c:	7402                	ld	s0,32(sp)
    8000465e:	64e2                	ld	s1,24(sp)
    80004660:	6942                	ld	s2,16(sp)
    80004662:	69a2                	ld	s3,8(sp)
    80004664:	6145                	addi	sp,sp,48
    80004666:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004668:	6908                	ld	a0,16(a0)
    8000466a:	00000097          	auipc	ra,0x0
    8000466e:	3de080e7          	jalr	990(ra) # 80004a48 <piperead>
    80004672:	892a                	mv	s2,a0
    80004674:	b7d5                	j	80004658 <fileread+0x60>
    r = devsw[f->major].read(1, addr, n);
    80004676:	02451783          	lh	a5,36(a0)
    8000467a:	00479713          	slli	a4,a5,0x4
    8000467e:	0001d797          	auipc	a5,0x1d
    80004682:	26a78793          	addi	a5,a5,618 # 800218e8 <devsw>
    80004686:	97ba                	add	a5,a5,a4
    80004688:	639c                	ld	a5,0(a5)
    8000468a:	4505                	li	a0,1
    8000468c:	9782                	jalr	a5
    8000468e:	892a                	mv	s2,a0
    80004690:	b7e1                	j	80004658 <fileread+0x60>
    panic("fileread");
    80004692:	00003517          	auipc	a0,0x3
    80004696:	06650513          	addi	a0,a0,102 # 800076f8 <userret+0x668>
    8000469a:	ffffc097          	auipc	ra,0xffffc
    8000469e:	eb4080e7          	jalr	-332(ra) # 8000054e <panic>
    return -1;
    800046a2:	597d                	li	s2,-1
    800046a4:	bf55                	j	80004658 <fileread+0x60>

00000000800046a6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800046a6:	00954783          	lbu	a5,9(a0)
    800046aa:	12078e63          	beqz	a5,800047e6 <filewrite+0x140>
{
    800046ae:	715d                	addi	sp,sp,-80
    800046b0:	e486                	sd	ra,72(sp)
    800046b2:	e0a2                	sd	s0,64(sp)
    800046b4:	fc26                	sd	s1,56(sp)
    800046b6:	f84a                	sd	s2,48(sp)
    800046b8:	f44e                	sd	s3,40(sp)
    800046ba:	f052                	sd	s4,32(sp)
    800046bc:	ec56                	sd	s5,24(sp)
    800046be:	e85a                	sd	s6,16(sp)
    800046c0:	e45e                	sd	s7,8(sp)
    800046c2:	e062                	sd	s8,0(sp)
    800046c4:	0880                	addi	s0,sp,80
    800046c6:	84aa                	mv	s1,a0
    800046c8:	8aae                	mv	s5,a1
    800046ca:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046cc:	411c                	lw	a5,0(a0)
    800046ce:	4705                	li	a4,1
    800046d0:	02e78263          	beq	a5,a4,800046f4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046d4:	470d                	li	a4,3
    800046d6:	02e78563          	beq	a5,a4,80004700 <filewrite+0x5a>
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046da:	4709                	li	a4,2
    800046dc:	0ee79d63          	bne	a5,a4,800047d6 <filewrite+0x130>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046e0:	0ec05763          	blez	a2,800047ce <filewrite+0x128>
    int i = 0;
    800046e4:	4981                	li	s3,0
    800046e6:	6b05                	lui	s6,0x1
    800046e8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    800046ec:	6b85                	lui	s7,0x1
    800046ee:	c00b8b9b          	addiw	s7,s7,-1024
    800046f2:	a051                	j	80004776 <filewrite+0xd0>
    ret = pipewrite(f->pipe, addr, n);
    800046f4:	6908                	ld	a0,16(a0)
    800046f6:	00000097          	auipc	ra,0x0
    800046fa:	23e080e7          	jalr	574(ra) # 80004934 <pipewrite>
    800046fe:	a065                	j	800047a6 <filewrite+0x100>
    ret = devsw[f->major].write(1, addr, n);
    80004700:	02451783          	lh	a5,36(a0)
    80004704:	00479713          	slli	a4,a5,0x4
    80004708:	0001d797          	auipc	a5,0x1d
    8000470c:	1e078793          	addi	a5,a5,480 # 800218e8 <devsw>
    80004710:	97ba                	add	a5,a5,a4
    80004712:	679c                	ld	a5,8(a5)
    80004714:	4505                	li	a0,1
    80004716:	9782                	jalr	a5
    80004718:	a079                	j	800047a6 <filewrite+0x100>
    8000471a:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    8000471e:	6c9c                	ld	a5,24(s1)
    80004720:	4388                	lw	a0,0(a5)
    80004722:	fffff097          	auipc	ra,0xfffff
    80004726:	76c080e7          	jalr	1900(ra) # 80003e8e <begin_op>
      ilock(f->ip);
    8000472a:	6c88                	ld	a0,24(s1)
    8000472c:	fffff097          	auipc	ra,0xfffff
    80004730:	cba080e7          	jalr	-838(ra) # 800033e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004734:	8762                	mv	a4,s8
    80004736:	5094                	lw	a3,32(s1)
    80004738:	01598633          	add	a2,s3,s5
    8000473c:	4585                	li	a1,1
    8000473e:	6c88                	ld	a0,24(s1)
    80004740:	fffff097          	auipc	ra,0xfffff
    80004744:	02a080e7          	jalr	42(ra) # 8000376a <writei>
    80004748:	892a                	mv	s2,a0
    8000474a:	02a05e63          	blez	a0,80004786 <filewrite+0xe0>
        f->off += r;
    8000474e:	509c                	lw	a5,32(s1)
    80004750:	9fa9                	addw	a5,a5,a0
    80004752:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004754:	6c88                	ld	a0,24(s1)
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	d52080e7          	jalr	-686(ra) # 800034a8 <iunlock>
      end_op(f->ip->dev);
    8000475e:	6c9c                	ld	a5,24(s1)
    80004760:	4388                	lw	a0,0(a5)
    80004762:	fffff097          	auipc	ra,0xfffff
    80004766:	7d6080e7          	jalr	2006(ra) # 80003f38 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    8000476a:	052c1a63          	bne	s8,s2,800047be <filewrite+0x118>
        panic("short filewrite");
      i += r;
    8000476e:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004772:	0349d763          	bge	s3,s4,800047a0 <filewrite+0xfa>
      int n1 = n - i;
    80004776:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    8000477a:	893e                	mv	s2,a5
    8000477c:	2781                	sext.w	a5,a5
    8000477e:	f8fb5ee3          	bge	s6,a5,8000471a <filewrite+0x74>
    80004782:	895e                	mv	s2,s7
    80004784:	bf59                	j	8000471a <filewrite+0x74>
      iunlock(f->ip);
    80004786:	6c88                	ld	a0,24(s1)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	d20080e7          	jalr	-736(ra) # 800034a8 <iunlock>
      end_op(f->ip->dev);
    80004790:	6c9c                	ld	a5,24(s1)
    80004792:	4388                	lw	a0,0(a5)
    80004794:	fffff097          	auipc	ra,0xfffff
    80004798:	7a4080e7          	jalr	1956(ra) # 80003f38 <end_op>
      if(r < 0)
    8000479c:	fc0957e3          	bgez	s2,8000476a <filewrite+0xc4>
    }
    ret = (i == n ? n : -1);
    800047a0:	8552                	mv	a0,s4
    800047a2:	033a1863          	bne	s4,s3,800047d2 <filewrite+0x12c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047a6:	60a6                	ld	ra,72(sp)
    800047a8:	6406                	ld	s0,64(sp)
    800047aa:	74e2                	ld	s1,56(sp)
    800047ac:	7942                	ld	s2,48(sp)
    800047ae:	79a2                	ld	s3,40(sp)
    800047b0:	7a02                	ld	s4,32(sp)
    800047b2:	6ae2                	ld	s5,24(sp)
    800047b4:	6b42                	ld	s6,16(sp)
    800047b6:	6ba2                	ld	s7,8(sp)
    800047b8:	6c02                	ld	s8,0(sp)
    800047ba:	6161                	addi	sp,sp,80
    800047bc:	8082                	ret
        panic("short filewrite");
    800047be:	00003517          	auipc	a0,0x3
    800047c2:	f4a50513          	addi	a0,a0,-182 # 80007708 <userret+0x678>
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	d88080e7          	jalr	-632(ra) # 8000054e <panic>
    int i = 0;
    800047ce:	4981                	li	s3,0
    800047d0:	bfc1                	j	800047a0 <filewrite+0xfa>
    ret = (i == n ? n : -1);
    800047d2:	557d                	li	a0,-1
    800047d4:	bfc9                	j	800047a6 <filewrite+0x100>
    panic("filewrite");
    800047d6:	00003517          	auipc	a0,0x3
    800047da:	f4250513          	addi	a0,a0,-190 # 80007718 <userret+0x688>
    800047de:	ffffc097          	auipc	ra,0xffffc
    800047e2:	d70080e7          	jalr	-656(ra) # 8000054e <panic>
    return -1;
    800047e6:	557d                	li	a0,-1
}
    800047e8:	8082                	ret

00000000800047ea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047ea:	7179                	addi	sp,sp,-48
    800047ec:	f406                	sd	ra,40(sp)
    800047ee:	f022                	sd	s0,32(sp)
    800047f0:	ec26                	sd	s1,24(sp)
    800047f2:	e84a                	sd	s2,16(sp)
    800047f4:	e44e                	sd	s3,8(sp)
    800047f6:	e052                	sd	s4,0(sp)
    800047f8:	1800                	addi	s0,sp,48
    800047fa:	84aa                	mv	s1,a0
    800047fc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047fe:	0005b023          	sd	zero,0(a1)
    80004802:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004806:	00000097          	auipc	ra,0x0
    8000480a:	bf4080e7          	jalr	-1036(ra) # 800043fa <filealloc>
    8000480e:	e088                	sd	a0,0(s1)
    80004810:	c551                	beqz	a0,8000489c <pipealloc+0xb2>
    80004812:	00000097          	auipc	ra,0x0
    80004816:	be8080e7          	jalr	-1048(ra) # 800043fa <filealloc>
    8000481a:	00aa3023          	sd	a0,0(s4)
    8000481e:	c92d                	beqz	a0,80004890 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	140080e7          	jalr	320(ra) # 80000960 <kalloc>
    80004828:	892a                	mv	s2,a0
    8000482a:	c125                	beqz	a0,8000488a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000482c:	4985                	li	s3,1
    8000482e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004832:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004836:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000483a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000483e:	00003597          	auipc	a1,0x3
    80004842:	eea58593          	addi	a1,a1,-278 # 80007728 <userret+0x698>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	17a080e7          	jalr	378(ra) # 800009c0 <initlock>
  (*f0)->type = FD_PIPE;
    8000484e:	609c                	ld	a5,0(s1)
    80004850:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004854:	609c                	ld	a5,0(s1)
    80004856:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000485a:	609c                	ld	a5,0(s1)
    8000485c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004860:	609c                	ld	a5,0(s1)
    80004862:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004866:	000a3783          	ld	a5,0(s4)
    8000486a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000486e:	000a3783          	ld	a5,0(s4)
    80004872:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004876:	000a3783          	ld	a5,0(s4)
    8000487a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000487e:	000a3783          	ld	a5,0(s4)
    80004882:	0127b823          	sd	s2,16(a5)
  return 0;
    80004886:	4501                	li	a0,0
    80004888:	a025                	j	800048b0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000488a:	6088                	ld	a0,0(s1)
    8000488c:	e501                	bnez	a0,80004894 <pipealloc+0xaa>
    8000488e:	a039                	j	8000489c <pipealloc+0xb2>
    80004890:	6088                	ld	a0,0(s1)
    80004892:	c51d                	beqz	a0,800048c0 <pipealloc+0xd6>
    fileclose(*f0);
    80004894:	00000097          	auipc	ra,0x0
    80004898:	c22080e7          	jalr	-990(ra) # 800044b6 <fileclose>
  if(*f1)
    8000489c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048a0:	557d                	li	a0,-1
  if(*f1)
    800048a2:	c799                	beqz	a5,800048b0 <pipealloc+0xc6>
    fileclose(*f1);
    800048a4:	853e                	mv	a0,a5
    800048a6:	00000097          	auipc	ra,0x0
    800048aa:	c10080e7          	jalr	-1008(ra) # 800044b6 <fileclose>
  return -1;
    800048ae:	557d                	li	a0,-1
}
    800048b0:	70a2                	ld	ra,40(sp)
    800048b2:	7402                	ld	s0,32(sp)
    800048b4:	64e2                	ld	s1,24(sp)
    800048b6:	6942                	ld	s2,16(sp)
    800048b8:	69a2                	ld	s3,8(sp)
    800048ba:	6a02                	ld	s4,0(sp)
    800048bc:	6145                	addi	sp,sp,48
    800048be:	8082                	ret
  return -1;
    800048c0:	557d                	li	a0,-1
    800048c2:	b7fd                	j	800048b0 <pipealloc+0xc6>

00000000800048c4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048c4:	1101                	addi	sp,sp,-32
    800048c6:	ec06                	sd	ra,24(sp)
    800048c8:	e822                	sd	s0,16(sp)
    800048ca:	e426                	sd	s1,8(sp)
    800048cc:	e04a                	sd	s2,0(sp)
    800048ce:	1000                	addi	s0,sp,32
    800048d0:	84aa                	mv	s1,a0
    800048d2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	1fe080e7          	jalr	510(ra) # 80000ad2 <acquire>
  if(writable){
    800048dc:	02090d63          	beqz	s2,80004916 <pipeclose+0x52>
    pi->writeopen = 0;
    800048e0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048e4:	21848513          	addi	a0,s1,536
    800048e8:	ffffe097          	auipc	ra,0xffffe
    800048ec:	89e080e7          	jalr	-1890(ra) # 80002186 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048f0:	2204b783          	ld	a5,544(s1)
    800048f4:	eb95                	bnez	a5,80004928 <pipeclose+0x64>
    release(&pi->lock);
    800048f6:	8526                	mv	a0,s1
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	242080e7          	jalr	578(ra) # 80000b3a <release>
    kfree((char*)pi);
    80004900:	8526                	mv	a0,s1
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	f62080e7          	jalr	-158(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    8000490a:	60e2                	ld	ra,24(sp)
    8000490c:	6442                	ld	s0,16(sp)
    8000490e:	64a2                	ld	s1,8(sp)
    80004910:	6902                	ld	s2,0(sp)
    80004912:	6105                	addi	sp,sp,32
    80004914:	8082                	ret
    pi->readopen = 0;
    80004916:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000491a:	21c48513          	addi	a0,s1,540
    8000491e:	ffffe097          	auipc	ra,0xffffe
    80004922:	868080e7          	jalr	-1944(ra) # 80002186 <wakeup>
    80004926:	b7e9                	j	800048f0 <pipeclose+0x2c>
    release(&pi->lock);
    80004928:	8526                	mv	a0,s1
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	210080e7          	jalr	528(ra) # 80000b3a <release>
}
    80004932:	bfe1                	j	8000490a <pipeclose+0x46>

0000000080004934 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004934:	7159                	addi	sp,sp,-112
    80004936:	f486                	sd	ra,104(sp)
    80004938:	f0a2                	sd	s0,96(sp)
    8000493a:	eca6                	sd	s1,88(sp)
    8000493c:	e8ca                	sd	s2,80(sp)
    8000493e:	e4ce                	sd	s3,72(sp)
    80004940:	e0d2                	sd	s4,64(sp)
    80004942:	fc56                	sd	s5,56(sp)
    80004944:	f85a                	sd	s6,48(sp)
    80004946:	f45e                	sd	s7,40(sp)
    80004948:	f062                	sd	s8,32(sp)
    8000494a:	ec66                	sd	s9,24(sp)
    8000494c:	1880                	addi	s0,sp,112
    8000494e:	84aa                	mv	s1,a0
    80004950:	8b2e                	mv	s6,a1
    80004952:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004954:	ffffd097          	auipc	ra,0xffffd
    80004958:	ee0080e7          	jalr	-288(ra) # 80001834 <myproc>
    8000495c:	8c2a                	mv	s8,a0

  acquire(&pi->lock);
    8000495e:	8526                	mv	a0,s1
    80004960:	ffffc097          	auipc	ra,0xffffc
    80004964:	172080e7          	jalr	370(ra) # 80000ad2 <acquire>
  for(i = 0; i < n; i++){
    80004968:	0b505063          	blez	s5,80004a08 <pipewrite+0xd4>
    8000496c:	8926                	mv	s2,s1
    8000496e:	fffa8b9b          	addiw	s7,s5,-1
    80004972:	1b82                	slli	s7,s7,0x20
    80004974:	020bdb93          	srli	s7,s7,0x20
    80004978:	001b0793          	addi	a5,s6,1
    8000497c:	9bbe                	add	s7,s7,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    8000497e:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004982:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004986:	5cfd                	li	s9,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004988:	2184a783          	lw	a5,536(s1)
    8000498c:	21c4a703          	lw	a4,540(s1)
    80004990:	2007879b          	addiw	a5,a5,512
    80004994:	02f71e63          	bne	a4,a5,800049d0 <pipewrite+0x9c>
      if(pi->readopen == 0 || myproc()->killed){
    80004998:	2204a783          	lw	a5,544(s1)
    8000499c:	c3d9                	beqz	a5,80004a22 <pipewrite+0xee>
    8000499e:	ffffd097          	auipc	ra,0xffffd
    800049a2:	e96080e7          	jalr	-362(ra) # 80001834 <myproc>
    800049a6:	591c                	lw	a5,48(a0)
    800049a8:	efad                	bnez	a5,80004a22 <pipewrite+0xee>
      wakeup(&pi->nread);
    800049aa:	8552                	mv	a0,s4
    800049ac:	ffffd097          	auipc	ra,0xffffd
    800049b0:	7da080e7          	jalr	2010(ra) # 80002186 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049b4:	85ca                	mv	a1,s2
    800049b6:	854e                	mv	a0,s3
    800049b8:	ffffd097          	auipc	ra,0xffffd
    800049bc:	682080e7          	jalr	1666(ra) # 8000203a <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    800049c0:	2184a783          	lw	a5,536(s1)
    800049c4:	21c4a703          	lw	a4,540(s1)
    800049c8:	2007879b          	addiw	a5,a5,512
    800049cc:	fcf706e3          	beq	a4,a5,80004998 <pipewrite+0x64>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049d0:	4685                	li	a3,1
    800049d2:	865a                	mv	a2,s6
    800049d4:	f9f40593          	addi	a1,s0,-97
    800049d8:	048c3503          	ld	a0,72(s8)
    800049dc:	ffffd097          	auipc	ra,0xffffd
    800049e0:	c10080e7          	jalr	-1008(ra) # 800015ec <copyin>
    800049e4:	03950263          	beq	a0,s9,80004a08 <pipewrite+0xd4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049e8:	21c4a783          	lw	a5,540(s1)
    800049ec:	0017871b          	addiw	a4,a5,1
    800049f0:	20e4ae23          	sw	a4,540(s1)
    800049f4:	1ff7f793          	andi	a5,a5,511
    800049f8:	97a6                	add	a5,a5,s1
    800049fa:	f9f44703          	lbu	a4,-97(s0)
    800049fe:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004a02:	0b05                	addi	s6,s6,1
    80004a04:	f97b12e3          	bne	s6,s7,80004988 <pipewrite+0x54>
  }
  wakeup(&pi->nread);
    80004a08:	21848513          	addi	a0,s1,536
    80004a0c:	ffffd097          	auipc	ra,0xffffd
    80004a10:	77a080e7          	jalr	1914(ra) # 80002186 <wakeup>
  release(&pi->lock);
    80004a14:	8526                	mv	a0,s1
    80004a16:	ffffc097          	auipc	ra,0xffffc
    80004a1a:	124080e7          	jalr	292(ra) # 80000b3a <release>
  return n;
    80004a1e:	8556                	mv	a0,s5
    80004a20:	a039                	j	80004a2e <pipewrite+0xfa>
        release(&pi->lock);
    80004a22:	8526                	mv	a0,s1
    80004a24:	ffffc097          	auipc	ra,0xffffc
    80004a28:	116080e7          	jalr	278(ra) # 80000b3a <release>
        return -1;
    80004a2c:	557d                	li	a0,-1
}
    80004a2e:	70a6                	ld	ra,104(sp)
    80004a30:	7406                	ld	s0,96(sp)
    80004a32:	64e6                	ld	s1,88(sp)
    80004a34:	6946                	ld	s2,80(sp)
    80004a36:	69a6                	ld	s3,72(sp)
    80004a38:	6a06                	ld	s4,64(sp)
    80004a3a:	7ae2                	ld	s5,56(sp)
    80004a3c:	7b42                	ld	s6,48(sp)
    80004a3e:	7ba2                	ld	s7,40(sp)
    80004a40:	7c02                	ld	s8,32(sp)
    80004a42:	6ce2                	ld	s9,24(sp)
    80004a44:	6165                	addi	sp,sp,112
    80004a46:	8082                	ret

0000000080004a48 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a48:	715d                	addi	sp,sp,-80
    80004a4a:	e486                	sd	ra,72(sp)
    80004a4c:	e0a2                	sd	s0,64(sp)
    80004a4e:	fc26                	sd	s1,56(sp)
    80004a50:	f84a                	sd	s2,48(sp)
    80004a52:	f44e                	sd	s3,40(sp)
    80004a54:	f052                	sd	s4,32(sp)
    80004a56:	ec56                	sd	s5,24(sp)
    80004a58:	e85a                	sd	s6,16(sp)
    80004a5a:	0880                	addi	s0,sp,80
    80004a5c:	84aa                	mv	s1,a0
    80004a5e:	892e                	mv	s2,a1
    80004a60:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004a62:	ffffd097          	auipc	ra,0xffffd
    80004a66:	dd2080e7          	jalr	-558(ra) # 80001834 <myproc>
    80004a6a:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004a6c:	8b26                	mv	s6,s1
    80004a6e:	8526                	mv	a0,s1
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	062080e7          	jalr	98(ra) # 80000ad2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a78:	2184a703          	lw	a4,536(s1)
    80004a7c:	21c4a783          	lw	a5,540(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a80:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a84:	02f71763          	bne	a4,a5,80004ab2 <piperead+0x6a>
    80004a88:	2244a783          	lw	a5,548(s1)
    80004a8c:	c39d                	beqz	a5,80004ab2 <piperead+0x6a>
    if(myproc()->killed){
    80004a8e:	ffffd097          	auipc	ra,0xffffd
    80004a92:	da6080e7          	jalr	-602(ra) # 80001834 <myproc>
    80004a96:	591c                	lw	a5,48(a0)
    80004a98:	ebc1                	bnez	a5,80004b28 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a9a:	85da                	mv	a1,s6
    80004a9c:	854e                	mv	a0,s3
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	59c080e7          	jalr	1436(ra) # 8000203a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aa6:	2184a703          	lw	a4,536(s1)
    80004aaa:	21c4a783          	lw	a5,540(s1)
    80004aae:	fcf70de3          	beq	a4,a5,80004a88 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ab2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ab4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ab6:	05405363          	blez	s4,80004afc <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004aba:	2184a783          	lw	a5,536(s1)
    80004abe:	21c4a703          	lw	a4,540(s1)
    80004ac2:	02f70d63          	beq	a4,a5,80004afc <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ac6:	0017871b          	addiw	a4,a5,1
    80004aca:	20e4ac23          	sw	a4,536(s1)
    80004ace:	1ff7f793          	andi	a5,a5,511
    80004ad2:	97a6                	add	a5,a5,s1
    80004ad4:	0187c783          	lbu	a5,24(a5)
    80004ad8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004adc:	4685                	li	a3,1
    80004ade:	fbf40613          	addi	a2,s0,-65
    80004ae2:	85ca                	mv	a1,s2
    80004ae4:	048ab503          	ld	a0,72(s5)
    80004ae8:	ffffd097          	auipc	ra,0xffffd
    80004aec:	a72080e7          	jalr	-1422(ra) # 8000155a <copyout>
    80004af0:	01650663          	beq	a0,s6,80004afc <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004af4:	2985                	addiw	s3,s3,1
    80004af6:	0905                	addi	s2,s2,1
    80004af8:	fd3a11e3          	bne	s4,s3,80004aba <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004afc:	21c48513          	addi	a0,s1,540
    80004b00:	ffffd097          	auipc	ra,0xffffd
    80004b04:	686080e7          	jalr	1670(ra) # 80002186 <wakeup>
  release(&pi->lock);
    80004b08:	8526                	mv	a0,s1
    80004b0a:	ffffc097          	auipc	ra,0xffffc
    80004b0e:	030080e7          	jalr	48(ra) # 80000b3a <release>
  return i;
}
    80004b12:	854e                	mv	a0,s3
    80004b14:	60a6                	ld	ra,72(sp)
    80004b16:	6406                	ld	s0,64(sp)
    80004b18:	74e2                	ld	s1,56(sp)
    80004b1a:	7942                	ld	s2,48(sp)
    80004b1c:	79a2                	ld	s3,40(sp)
    80004b1e:	7a02                	ld	s4,32(sp)
    80004b20:	6ae2                	ld	s5,24(sp)
    80004b22:	6b42                	ld	s6,16(sp)
    80004b24:	6161                	addi	sp,sp,80
    80004b26:	8082                	ret
      release(&pi->lock);
    80004b28:	8526                	mv	a0,s1
    80004b2a:	ffffc097          	auipc	ra,0xffffc
    80004b2e:	010080e7          	jalr	16(ra) # 80000b3a <release>
      return -1;
    80004b32:	59fd                	li	s3,-1
    80004b34:	bff9                	j	80004b12 <piperead+0xca>

0000000080004b36 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004b36:	df010113          	addi	sp,sp,-528
    80004b3a:	20113423          	sd	ra,520(sp)
    80004b3e:	20813023          	sd	s0,512(sp)
    80004b42:	ffa6                	sd	s1,504(sp)
    80004b44:	fbca                	sd	s2,496(sp)
    80004b46:	f7ce                	sd	s3,488(sp)
    80004b48:	f3d2                	sd	s4,480(sp)
    80004b4a:	efd6                	sd	s5,472(sp)
    80004b4c:	ebda                	sd	s6,464(sp)
    80004b4e:	e7de                	sd	s7,456(sp)
    80004b50:	e3e2                	sd	s8,448(sp)
    80004b52:	ff66                	sd	s9,440(sp)
    80004b54:	fb6a                	sd	s10,432(sp)
    80004b56:	f76e                	sd	s11,424(sp)
    80004b58:	0c00                	addi	s0,sp,528
    80004b5a:	84aa                	mv	s1,a0
    80004b5c:	dea43c23          	sd	a0,-520(s0)
    80004b60:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b64:	ffffd097          	auipc	ra,0xffffd
    80004b68:	cd0080e7          	jalr	-816(ra) # 80001834 <myproc>
    80004b6c:	892a                	mv	s2,a0

  begin_op(ROOTDEV);
    80004b6e:	4501                	li	a0,0
    80004b70:	fffff097          	auipc	ra,0xfffff
    80004b74:	31e080e7          	jalr	798(ra) # 80003e8e <begin_op>

  if((ip = namei(path)) == 0){
    80004b78:	8526                	mv	a0,s1
    80004b7a:	fffff097          	auipc	ra,0xfffff
    80004b7e:	ff8080e7          	jalr	-8(ra) # 80003b72 <namei>
    80004b82:	c935                	beqz	a0,80004bf6 <exec+0xc0>
    80004b84:	84aa                	mv	s1,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004b86:	fffff097          	auipc	ra,0xfffff
    80004b8a:	860080e7          	jalr	-1952(ra) # 800033e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b8e:	04000713          	li	a4,64
    80004b92:	4681                	li	a3,0
    80004b94:	e4840613          	addi	a2,s0,-440
    80004b98:	4581                	li	a1,0
    80004b9a:	8526                	mv	a0,s1
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	ada080e7          	jalr	-1318(ra) # 80003676 <readi>
    80004ba4:	04000793          	li	a5,64
    80004ba8:	00f51a63          	bne	a0,a5,80004bbc <exec+0x86>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004bac:	e4842703          	lw	a4,-440(s0)
    80004bb0:	464c47b7          	lui	a5,0x464c4
    80004bb4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bb8:	04f70663          	beq	a4,a5,80004c04 <exec+0xce>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bbc:	8526                	mv	a0,s1
    80004bbe:	fffff097          	auipc	ra,0xfffff
    80004bc2:	a66080e7          	jalr	-1434(ra) # 80003624 <iunlockput>
    end_op(ROOTDEV);
    80004bc6:	4501                	li	a0,0
    80004bc8:	fffff097          	auipc	ra,0xfffff
    80004bcc:	370080e7          	jalr	880(ra) # 80003f38 <end_op>
  }
  return -1;
    80004bd0:	557d                	li	a0,-1
}
    80004bd2:	20813083          	ld	ra,520(sp)
    80004bd6:	20013403          	ld	s0,512(sp)
    80004bda:	74fe                	ld	s1,504(sp)
    80004bdc:	795e                	ld	s2,496(sp)
    80004bde:	79be                	ld	s3,488(sp)
    80004be0:	7a1e                	ld	s4,480(sp)
    80004be2:	6afe                	ld	s5,472(sp)
    80004be4:	6b5e                	ld	s6,464(sp)
    80004be6:	6bbe                	ld	s7,456(sp)
    80004be8:	6c1e                	ld	s8,448(sp)
    80004bea:	7cfa                	ld	s9,440(sp)
    80004bec:	7d5a                	ld	s10,432(sp)
    80004bee:	7dba                	ld	s11,424(sp)
    80004bf0:	21010113          	addi	sp,sp,528
    80004bf4:	8082                	ret
    end_op(ROOTDEV);
    80004bf6:	4501                	li	a0,0
    80004bf8:	fffff097          	auipc	ra,0xfffff
    80004bfc:	340080e7          	jalr	832(ra) # 80003f38 <end_op>
    return -1;
    80004c00:	557d                	li	a0,-1
    80004c02:	bfc1                	j	80004bd2 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c04:	854a                	mv	a0,s2
    80004c06:	ffffd097          	auipc	ra,0xffffd
    80004c0a:	cf2080e7          	jalr	-782(ra) # 800018f8 <proc_pagetable>
    80004c0e:	8c2a                	mv	s8,a0
    80004c10:	d555                	beqz	a0,80004bbc <exec+0x86>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c12:	e6842983          	lw	s3,-408(s0)
    80004c16:	e8045783          	lhu	a5,-384(s0)
    80004c1a:	c7fd                	beqz	a5,80004d08 <exec+0x1d2>
  sz = 0;
    80004c1c:	e0043423          	sd	zero,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c20:	4b81                	li	s7,0
    if(ph.vaddr % PGSIZE != 0)
    80004c22:	6b05                	lui	s6,0x1
    80004c24:	fffb0793          	addi	a5,s6,-1 # fff <_entry-0x7ffff001>
    80004c28:	def43823          	sd	a5,-528(s0)
    80004c2c:	a0a5                	j	80004c94 <exec+0x15e>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c2e:	00003517          	auipc	a0,0x3
    80004c32:	b0250513          	addi	a0,a0,-1278 # 80007730 <userret+0x6a0>
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	918080e7          	jalr	-1768(ra) # 8000054e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c3e:	8756                	mv	a4,s5
    80004c40:	012d86bb          	addw	a3,s11,s2
    80004c44:	4581                	li	a1,0
    80004c46:	8526                	mv	a0,s1
    80004c48:	fffff097          	auipc	ra,0xfffff
    80004c4c:	a2e080e7          	jalr	-1490(ra) # 80003676 <readi>
    80004c50:	2501                	sext.w	a0,a0
    80004c52:	10aa9263          	bne	s5,a0,80004d56 <exec+0x220>
  for(i = 0; i < sz; i += PGSIZE){
    80004c56:	6785                	lui	a5,0x1
    80004c58:	0127893b          	addw	s2,a5,s2
    80004c5c:	77fd                	lui	a5,0xfffff
    80004c5e:	01478a3b          	addw	s4,a5,s4
    80004c62:	03997263          	bgeu	s2,s9,80004c86 <exec+0x150>
    pa = walkaddr(pagetable, va + i);
    80004c66:	02091593          	slli	a1,s2,0x20
    80004c6a:	9181                	srli	a1,a1,0x20
    80004c6c:	95ea                	add	a1,a1,s10
    80004c6e:	8562                	mv	a0,s8
    80004c70:	ffffc097          	auipc	ra,0xffffc
    80004c74:	324080e7          	jalr	804(ra) # 80000f94 <walkaddr>
    80004c78:	862a                	mv	a2,a0
    if(pa == 0)
    80004c7a:	d955                	beqz	a0,80004c2e <exec+0xf8>
      n = PGSIZE;
    80004c7c:	8ada                	mv	s5,s6
    if(sz - i < PGSIZE)
    80004c7e:	fd6a70e3          	bgeu	s4,s6,80004c3e <exec+0x108>
      n = sz - i;
    80004c82:	8ad2                	mv	s5,s4
    80004c84:	bf6d                	j	80004c3e <exec+0x108>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c86:	2b85                	addiw	s7,s7,1
    80004c88:	0389899b          	addiw	s3,s3,56
    80004c8c:	e8045783          	lhu	a5,-384(s0)
    80004c90:	06fbde63          	bge	s7,a5,80004d0c <exec+0x1d6>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c94:	2981                	sext.w	s3,s3
    80004c96:	03800713          	li	a4,56
    80004c9a:	86ce                	mv	a3,s3
    80004c9c:	e1040613          	addi	a2,s0,-496
    80004ca0:	4581                	li	a1,0
    80004ca2:	8526                	mv	a0,s1
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	9d2080e7          	jalr	-1582(ra) # 80003676 <readi>
    80004cac:	03800793          	li	a5,56
    80004cb0:	0af51363          	bne	a0,a5,80004d56 <exec+0x220>
    if(ph.type != ELF_PROG_LOAD)
    80004cb4:	e1042783          	lw	a5,-496(s0)
    80004cb8:	4705                	li	a4,1
    80004cba:	fce796e3          	bne	a5,a4,80004c86 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004cbe:	e3843603          	ld	a2,-456(s0)
    80004cc2:	e3043783          	ld	a5,-464(s0)
    80004cc6:	08f66863          	bltu	a2,a5,80004d56 <exec+0x220>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004cca:	e2043783          	ld	a5,-480(s0)
    80004cce:	963e                	add	a2,a2,a5
    80004cd0:	08f66363          	bltu	a2,a5,80004d56 <exec+0x220>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004cd4:	e0843583          	ld	a1,-504(s0)
    80004cd8:	8562                	mv	a0,s8
    80004cda:	ffffc097          	auipc	ra,0xffffc
    80004cde:	6a6080e7          	jalr	1702(ra) # 80001380 <uvmalloc>
    80004ce2:	e0a43423          	sd	a0,-504(s0)
    80004ce6:	c925                	beqz	a0,80004d56 <exec+0x220>
    if(ph.vaddr % PGSIZE != 0)
    80004ce8:	e2043d03          	ld	s10,-480(s0)
    80004cec:	df043783          	ld	a5,-528(s0)
    80004cf0:	00fd77b3          	and	a5,s10,a5
    80004cf4:	e3ad                	bnez	a5,80004d56 <exec+0x220>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cf6:	e1842d83          	lw	s11,-488(s0)
    80004cfa:	e3042c83          	lw	s9,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004cfe:	f80c84e3          	beqz	s9,80004c86 <exec+0x150>
    80004d02:	8a66                	mv	s4,s9
    80004d04:	4901                	li	s2,0
    80004d06:	b785                	j	80004c66 <exec+0x130>
  sz = 0;
    80004d08:	e0043423          	sd	zero,-504(s0)
  iunlockput(ip);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	916080e7          	jalr	-1770(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    80004d16:	4501                	li	a0,0
    80004d18:	fffff097          	auipc	ra,0xfffff
    80004d1c:	220080e7          	jalr	544(ra) # 80003f38 <end_op>
  p = myproc();
    80004d20:	ffffd097          	auipc	ra,0xffffd
    80004d24:	b14080e7          	jalr	-1260(ra) # 80001834 <myproc>
    80004d28:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004d2a:	04053d03          	ld	s10,64(a0)
  sz = PGROUNDUP(sz);
    80004d2e:	6585                	lui	a1,0x1
    80004d30:	15fd                	addi	a1,a1,-1
    80004d32:	e0843783          	ld	a5,-504(s0)
    80004d36:	00b78b33          	add	s6,a5,a1
    80004d3a:	75fd                	lui	a1,0xfffff
    80004d3c:	00bb75b3          	and	a1,s6,a1
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d40:	6609                	lui	a2,0x2
    80004d42:	962e                	add	a2,a2,a1
    80004d44:	8562                	mv	a0,s8
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	63a080e7          	jalr	1594(ra) # 80001380 <uvmalloc>
    80004d4e:	e0a43423          	sd	a0,-504(s0)
  ip = 0;
    80004d52:	4481                	li	s1,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004d54:	ed01                	bnez	a0,80004d6c <exec+0x236>
    proc_freepagetable(pagetable, sz);
    80004d56:	e0843583          	ld	a1,-504(s0)
    80004d5a:	8562                	mv	a0,s8
    80004d5c:	ffffd097          	auipc	ra,0xffffd
    80004d60:	c9c080e7          	jalr	-868(ra) # 800019f8 <proc_freepagetable>
  if(ip){
    80004d64:	e4049ce3          	bnez	s1,80004bbc <exec+0x86>
  return -1;
    80004d68:	557d                	li	a0,-1
    80004d6a:	b5a5                	j	80004bd2 <exec+0x9c>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d6c:	75f9                	lui	a1,0xffffe
    80004d6e:	84aa                	mv	s1,a0
    80004d70:	95aa                	add	a1,a1,a0
    80004d72:	8562                	mv	a0,s8
    80004d74:	ffffc097          	auipc	ra,0xffffc
    80004d78:	7b4080e7          	jalr	1972(ra) # 80001528 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d7c:	7afd                	lui	s5,0xfffff
    80004d7e:	9aa6                	add	s5,s5,s1
  for(argc = 0; argv[argc]; argc++) {
    80004d80:	e0043783          	ld	a5,-512(s0)
    80004d84:	6388                	ld	a0,0(a5)
    80004d86:	c135                	beqz	a0,80004dea <exec+0x2b4>
    80004d88:	e8840993          	addi	s3,s0,-376
    80004d8c:	f8840c93          	addi	s9,s0,-120
    80004d90:	4901                	li	s2,0
    sp -= strlen(argv[argc]) + 1;
    80004d92:	ffffc097          	auipc	ra,0xffffc
    80004d96:	f8c080e7          	jalr	-116(ra) # 80000d1e <strlen>
    80004d9a:	2505                	addiw	a0,a0,1
    80004d9c:	8c89                	sub	s1,s1,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d9e:	98c1                	andi	s1,s1,-16
    if(sp < stackbase)
    80004da0:	0f54ea63          	bltu	s1,s5,80004e94 <exec+0x35e>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004da4:	e0043b03          	ld	s6,-512(s0)
    80004da8:	000b3a03          	ld	s4,0(s6)
    80004dac:	8552                	mv	a0,s4
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	f70080e7          	jalr	-144(ra) # 80000d1e <strlen>
    80004db6:	0015069b          	addiw	a3,a0,1
    80004dba:	8652                	mv	a2,s4
    80004dbc:	85a6                	mv	a1,s1
    80004dbe:	8562                	mv	a0,s8
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	79a080e7          	jalr	1946(ra) # 8000155a <copyout>
    80004dc8:	0c054863          	bltz	a0,80004e98 <exec+0x362>
    ustack[argc] = sp;
    80004dcc:	0099b023          	sd	s1,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004dd0:	0905                	addi	s2,s2,1
    80004dd2:	008b0793          	addi	a5,s6,8
    80004dd6:	e0f43023          	sd	a5,-512(s0)
    80004dda:	008b3503          	ld	a0,8(s6)
    80004dde:	c909                	beqz	a0,80004df0 <exec+0x2ba>
    if(argc >= MAXARG)
    80004de0:	09a1                	addi	s3,s3,8
    80004de2:	fb3c98e3          	bne	s9,s3,80004d92 <exec+0x25c>
  ip = 0;
    80004de6:	4481                	li	s1,0
    80004de8:	b7bd                	j	80004d56 <exec+0x220>
  sp = sz;
    80004dea:	e0843483          	ld	s1,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004dee:	4901                	li	s2,0
  ustack[argc] = 0;
    80004df0:	00391793          	slli	a5,s2,0x3
    80004df4:	f9040713          	addi	a4,s0,-112
    80004df8:	97ba                	add	a5,a5,a4
    80004dfa:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <ticks+0xffffffff7ffd5ed0>
  sp -= (argc+1) * sizeof(uint64);
    80004dfe:	00190693          	addi	a3,s2,1
    80004e02:	068e                	slli	a3,a3,0x3
    80004e04:	8c95                	sub	s1,s1,a3
  sp -= sp % 16;
    80004e06:	ff04f993          	andi	s3,s1,-16
  ip = 0;
    80004e0a:	4481                	li	s1,0
  if(sp < stackbase)
    80004e0c:	f559e5e3          	bltu	s3,s5,80004d56 <exec+0x220>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e10:	e8840613          	addi	a2,s0,-376
    80004e14:	85ce                	mv	a1,s3
    80004e16:	8562                	mv	a0,s8
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	742080e7          	jalr	1858(ra) # 8000155a <copyout>
    80004e20:	06054e63          	bltz	a0,80004e9c <exec+0x366>
  p->tf->a1 = sp;
    80004e24:	050bb783          	ld	a5,80(s7) # 1050 <_entry-0x7fffefb0>
    80004e28:	0737bc23          	sd	s3,120(a5)
  for(last=s=path; *s; s++)
    80004e2c:	df843783          	ld	a5,-520(s0)
    80004e30:	0007c703          	lbu	a4,0(a5)
    80004e34:	cf11                	beqz	a4,80004e50 <exec+0x31a>
    80004e36:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e38:	02f00693          	li	a3,47
    80004e3c:	a029                	j	80004e46 <exec+0x310>
  for(last=s=path; *s; s++)
    80004e3e:	0785                	addi	a5,a5,1
    80004e40:	fff7c703          	lbu	a4,-1(a5)
    80004e44:	c711                	beqz	a4,80004e50 <exec+0x31a>
    if(*s == '/')
    80004e46:	fed71ce3          	bne	a4,a3,80004e3e <exec+0x308>
      last = s+1;
    80004e4a:	def43c23          	sd	a5,-520(s0)
    80004e4e:	bfc5                	j	80004e3e <exec+0x308>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e50:	4641                	li	a2,16
    80004e52:	df843583          	ld	a1,-520(s0)
    80004e56:	150b8513          	addi	a0,s7,336
    80004e5a:	ffffc097          	auipc	ra,0xffffc
    80004e5e:	e92080e7          	jalr	-366(ra) # 80000cec <safestrcpy>
  oldpagetable = p->pagetable;
    80004e62:	048bb503          	ld	a0,72(s7)
  p->pagetable = pagetable;
    80004e66:	058bb423          	sd	s8,72(s7)
  p->sz = sz;
    80004e6a:	e0843783          	ld	a5,-504(s0)
    80004e6e:	04fbb023          	sd	a5,64(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80004e72:	050bb783          	ld	a5,80(s7)
    80004e76:	e6043703          	ld	a4,-416(s0)
    80004e7a:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    80004e7c:	050bb783          	ld	a5,80(s7)
    80004e80:	0337b823          	sd	s3,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e84:	85ea                	mv	a1,s10
    80004e86:	ffffd097          	auipc	ra,0xffffd
    80004e8a:	b72080e7          	jalr	-1166(ra) # 800019f8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e8e:	0009051b          	sext.w	a0,s2
    80004e92:	b381                	j	80004bd2 <exec+0x9c>
  ip = 0;
    80004e94:	4481                	li	s1,0
    80004e96:	b5c1                	j	80004d56 <exec+0x220>
    80004e98:	4481                	li	s1,0
    80004e9a:	bd75                	j	80004d56 <exec+0x220>
    80004e9c:	4481                	li	s1,0
    80004e9e:	bd65                	j	80004d56 <exec+0x220>

0000000080004ea0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ea0:	7179                	addi	sp,sp,-48
    80004ea2:	f406                	sd	ra,40(sp)
    80004ea4:	f022                	sd	s0,32(sp)
    80004ea6:	ec26                	sd	s1,24(sp)
    80004ea8:	e84a                	sd	s2,16(sp)
    80004eaa:	1800                	addi	s0,sp,48
    80004eac:	892e                	mv	s2,a1
    80004eae:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004eb0:	fdc40593          	addi	a1,s0,-36
    80004eb4:	ffffe097          	auipc	ra,0xffffe
    80004eb8:	9f0080e7          	jalr	-1552(ra) # 800028a4 <argint>
    80004ebc:	04054063          	bltz	a0,80004efc <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ec0:	fdc42703          	lw	a4,-36(s0)
    80004ec4:	47bd                	li	a5,15
    80004ec6:	02e7ed63          	bltu	a5,a4,80004f00 <argfd+0x60>
    80004eca:	ffffd097          	auipc	ra,0xffffd
    80004ece:	96a080e7          	jalr	-1686(ra) # 80001834 <myproc>
    80004ed2:	fdc42703          	lw	a4,-36(s0)
    80004ed6:	01870793          	addi	a5,a4,24
    80004eda:	078e                	slli	a5,a5,0x3
    80004edc:	953e                	add	a0,a0,a5
    80004ede:	651c                	ld	a5,8(a0)
    80004ee0:	c395                	beqz	a5,80004f04 <argfd+0x64>
    return -1;
  if(pfd)
    80004ee2:	00090463          	beqz	s2,80004eea <argfd+0x4a>
    *pfd = fd;
    80004ee6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004eea:	4501                	li	a0,0
  if(pf)
    80004eec:	c091                	beqz	s1,80004ef0 <argfd+0x50>
    *pf = f;
    80004eee:	e09c                	sd	a5,0(s1)
}
    80004ef0:	70a2                	ld	ra,40(sp)
    80004ef2:	7402                	ld	s0,32(sp)
    80004ef4:	64e2                	ld	s1,24(sp)
    80004ef6:	6942                	ld	s2,16(sp)
    80004ef8:	6145                	addi	sp,sp,48
    80004efa:	8082                	ret
    return -1;
    80004efc:	557d                	li	a0,-1
    80004efe:	bfcd                	j	80004ef0 <argfd+0x50>
    return -1;
    80004f00:	557d                	li	a0,-1
    80004f02:	b7fd                	j	80004ef0 <argfd+0x50>
    80004f04:	557d                	li	a0,-1
    80004f06:	b7ed                	j	80004ef0 <argfd+0x50>

0000000080004f08 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f08:	1101                	addi	sp,sp,-32
    80004f0a:	ec06                	sd	ra,24(sp)
    80004f0c:	e822                	sd	s0,16(sp)
    80004f0e:	e426                	sd	s1,8(sp)
    80004f10:	1000                	addi	s0,sp,32
    80004f12:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	920080e7          	jalr	-1760(ra) # 80001834 <myproc>
    80004f1c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f1e:	0c850793          	addi	a5,a0,200
    80004f22:	4501                	li	a0,0
    80004f24:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f26:	6398                	ld	a4,0(a5)
    80004f28:	cb19                	beqz	a4,80004f3e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f2a:	2505                	addiw	a0,a0,1
    80004f2c:	07a1                	addi	a5,a5,8
    80004f2e:	fed51ce3          	bne	a0,a3,80004f26 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f32:	557d                	li	a0,-1
}
    80004f34:	60e2                	ld	ra,24(sp)
    80004f36:	6442                	ld	s0,16(sp)
    80004f38:	64a2                	ld	s1,8(sp)
    80004f3a:	6105                	addi	sp,sp,32
    80004f3c:	8082                	ret
      p->ofile[fd] = f;
    80004f3e:	01850793          	addi	a5,a0,24
    80004f42:	078e                	slli	a5,a5,0x3
    80004f44:	963e                	add	a2,a2,a5
    80004f46:	e604                	sd	s1,8(a2)
      return fd;
    80004f48:	b7f5                	j	80004f34 <fdalloc+0x2c>

0000000080004f4a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f4a:	715d                	addi	sp,sp,-80
    80004f4c:	e486                	sd	ra,72(sp)
    80004f4e:	e0a2                	sd	s0,64(sp)
    80004f50:	fc26                	sd	s1,56(sp)
    80004f52:	f84a                	sd	s2,48(sp)
    80004f54:	f44e                	sd	s3,40(sp)
    80004f56:	f052                	sd	s4,32(sp)
    80004f58:	ec56                	sd	s5,24(sp)
    80004f5a:	0880                	addi	s0,sp,80
    80004f5c:	89ae                	mv	s3,a1
    80004f5e:	8ab2                	mv	s5,a2
    80004f60:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f62:	fb040593          	addi	a1,s0,-80
    80004f66:	fffff097          	auipc	ra,0xfffff
    80004f6a:	c2a080e7          	jalr	-982(ra) # 80003b90 <nameiparent>
    80004f6e:	892a                	mv	s2,a0
    80004f70:	12050e63          	beqz	a0,800050ac <create+0x162>
    return 0;
  ilock(dp);
    80004f74:	ffffe097          	auipc	ra,0xffffe
    80004f78:	472080e7          	jalr	1138(ra) # 800033e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f7c:	4601                	li	a2,0
    80004f7e:	fb040593          	addi	a1,s0,-80
    80004f82:	854a                	mv	a0,s2
    80004f84:	fffff097          	auipc	ra,0xfffff
    80004f88:	91c080e7          	jalr	-1764(ra) # 800038a0 <dirlookup>
    80004f8c:	84aa                	mv	s1,a0
    80004f8e:	c921                	beqz	a0,80004fde <create+0x94>
    iunlockput(dp);
    80004f90:	854a                	mv	a0,s2
    80004f92:	ffffe097          	auipc	ra,0xffffe
    80004f96:	692080e7          	jalr	1682(ra) # 80003624 <iunlockput>
    ilock(ip);
    80004f9a:	8526                	mv	a0,s1
    80004f9c:	ffffe097          	auipc	ra,0xffffe
    80004fa0:	44a080e7          	jalr	1098(ra) # 800033e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fa4:	2981                	sext.w	s3,s3
    80004fa6:	4789                	li	a5,2
    80004fa8:	02f99463          	bne	s3,a5,80004fd0 <create+0x86>
    80004fac:	0444d783          	lhu	a5,68(s1)
    80004fb0:	37f9                	addiw	a5,a5,-2
    80004fb2:	17c2                	slli	a5,a5,0x30
    80004fb4:	93c1                	srli	a5,a5,0x30
    80004fb6:	4705                	li	a4,1
    80004fb8:	00f76c63          	bltu	a4,a5,80004fd0 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004fbc:	8526                	mv	a0,s1
    80004fbe:	60a6                	ld	ra,72(sp)
    80004fc0:	6406                	ld	s0,64(sp)
    80004fc2:	74e2                	ld	s1,56(sp)
    80004fc4:	7942                	ld	s2,48(sp)
    80004fc6:	79a2                	ld	s3,40(sp)
    80004fc8:	7a02                	ld	s4,32(sp)
    80004fca:	6ae2                	ld	s5,24(sp)
    80004fcc:	6161                	addi	sp,sp,80
    80004fce:	8082                	ret
    iunlockput(ip);
    80004fd0:	8526                	mv	a0,s1
    80004fd2:	ffffe097          	auipc	ra,0xffffe
    80004fd6:	652080e7          	jalr	1618(ra) # 80003624 <iunlockput>
    return 0;
    80004fda:	4481                	li	s1,0
    80004fdc:	b7c5                	j	80004fbc <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004fde:	85ce                	mv	a1,s3
    80004fe0:	00092503          	lw	a0,0(s2)
    80004fe4:	ffffe097          	auipc	ra,0xffffe
    80004fe8:	26a080e7          	jalr	618(ra) # 8000324e <ialloc>
    80004fec:	84aa                	mv	s1,a0
    80004fee:	c521                	beqz	a0,80005036 <create+0xec>
  ilock(ip);
    80004ff0:	ffffe097          	auipc	ra,0xffffe
    80004ff4:	3f6080e7          	jalr	1014(ra) # 800033e6 <ilock>
  ip->major = major;
    80004ff8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004ffc:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005000:	4a05                	li	s4,1
    80005002:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005006:	8526                	mv	a0,s1
    80005008:	ffffe097          	auipc	ra,0xffffe
    8000500c:	314080e7          	jalr	788(ra) # 8000331c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005010:	2981                	sext.w	s3,s3
    80005012:	03498a63          	beq	s3,s4,80005046 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005016:	40d0                	lw	a2,4(s1)
    80005018:	fb040593          	addi	a1,s0,-80
    8000501c:	854a                	mv	a0,s2
    8000501e:	fffff097          	auipc	ra,0xfffff
    80005022:	a92080e7          	jalr	-1390(ra) # 80003ab0 <dirlink>
    80005026:	06054b63          	bltz	a0,8000509c <create+0x152>
  iunlockput(dp);
    8000502a:	854a                	mv	a0,s2
    8000502c:	ffffe097          	auipc	ra,0xffffe
    80005030:	5f8080e7          	jalr	1528(ra) # 80003624 <iunlockput>
  return ip;
    80005034:	b761                	j	80004fbc <create+0x72>
    panic("create: ialloc");
    80005036:	00002517          	auipc	a0,0x2
    8000503a:	71a50513          	addi	a0,a0,1818 # 80007750 <userret+0x6c0>
    8000503e:	ffffb097          	auipc	ra,0xffffb
    80005042:	510080e7          	jalr	1296(ra) # 8000054e <panic>
    dp->nlink++;  // for ".."
    80005046:	04a95783          	lhu	a5,74(s2)
    8000504a:	2785                	addiw	a5,a5,1
    8000504c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005050:	854a                	mv	a0,s2
    80005052:	ffffe097          	auipc	ra,0xffffe
    80005056:	2ca080e7          	jalr	714(ra) # 8000331c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000505a:	40d0                	lw	a2,4(s1)
    8000505c:	00002597          	auipc	a1,0x2
    80005060:	70458593          	addi	a1,a1,1796 # 80007760 <userret+0x6d0>
    80005064:	8526                	mv	a0,s1
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	a4a080e7          	jalr	-1462(ra) # 80003ab0 <dirlink>
    8000506e:	00054f63          	bltz	a0,8000508c <create+0x142>
    80005072:	00492603          	lw	a2,4(s2)
    80005076:	00002597          	auipc	a1,0x2
    8000507a:	6f258593          	addi	a1,a1,1778 # 80007768 <userret+0x6d8>
    8000507e:	8526                	mv	a0,s1
    80005080:	fffff097          	auipc	ra,0xfffff
    80005084:	a30080e7          	jalr	-1488(ra) # 80003ab0 <dirlink>
    80005088:	f80557e3          	bgez	a0,80005016 <create+0xcc>
      panic("create dots");
    8000508c:	00002517          	auipc	a0,0x2
    80005090:	6e450513          	addi	a0,a0,1764 # 80007770 <userret+0x6e0>
    80005094:	ffffb097          	auipc	ra,0xffffb
    80005098:	4ba080e7          	jalr	1210(ra) # 8000054e <panic>
    panic("create: dirlink");
    8000509c:	00002517          	auipc	a0,0x2
    800050a0:	6e450513          	addi	a0,a0,1764 # 80007780 <userret+0x6f0>
    800050a4:	ffffb097          	auipc	ra,0xffffb
    800050a8:	4aa080e7          	jalr	1194(ra) # 8000054e <panic>
    return 0;
    800050ac:	84aa                	mv	s1,a0
    800050ae:	b739                	j	80004fbc <create+0x72>

00000000800050b0 <sys_dup>:
{
    800050b0:	7179                	addi	sp,sp,-48
    800050b2:	f406                	sd	ra,40(sp)
    800050b4:	f022                	sd	s0,32(sp)
    800050b6:	ec26                	sd	s1,24(sp)
    800050b8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050ba:	fd840613          	addi	a2,s0,-40
    800050be:	4581                	li	a1,0
    800050c0:	4501                	li	a0,0
    800050c2:	00000097          	auipc	ra,0x0
    800050c6:	dde080e7          	jalr	-546(ra) # 80004ea0 <argfd>
    return -1;
    800050ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050cc:	02054363          	bltz	a0,800050f2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800050d0:	fd843503          	ld	a0,-40(s0)
    800050d4:	00000097          	auipc	ra,0x0
    800050d8:	e34080e7          	jalr	-460(ra) # 80004f08 <fdalloc>
    800050dc:	84aa                	mv	s1,a0
    return -1;
    800050de:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800050e0:	00054963          	bltz	a0,800050f2 <sys_dup+0x42>
  filedup(f);
    800050e4:	fd843503          	ld	a0,-40(s0)
    800050e8:	fffff097          	auipc	ra,0xfffff
    800050ec:	37c080e7          	jalr	892(ra) # 80004464 <filedup>
  return fd;
    800050f0:	87a6                	mv	a5,s1
}
    800050f2:	853e                	mv	a0,a5
    800050f4:	70a2                	ld	ra,40(sp)
    800050f6:	7402                	ld	s0,32(sp)
    800050f8:	64e2                	ld	s1,24(sp)
    800050fa:	6145                	addi	sp,sp,48
    800050fc:	8082                	ret

00000000800050fe <sys_read>:
{
    800050fe:	7179                	addi	sp,sp,-48
    80005100:	f406                	sd	ra,40(sp)
    80005102:	f022                	sd	s0,32(sp)
    80005104:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005106:	fe840613          	addi	a2,s0,-24
    8000510a:	4581                	li	a1,0
    8000510c:	4501                	li	a0,0
    8000510e:	00000097          	auipc	ra,0x0
    80005112:	d92080e7          	jalr	-622(ra) # 80004ea0 <argfd>
    return -1;
    80005116:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005118:	04054163          	bltz	a0,8000515a <sys_read+0x5c>
    8000511c:	fe440593          	addi	a1,s0,-28
    80005120:	4509                	li	a0,2
    80005122:	ffffd097          	auipc	ra,0xffffd
    80005126:	782080e7          	jalr	1922(ra) # 800028a4 <argint>
    return -1;
    8000512a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000512c:	02054763          	bltz	a0,8000515a <sys_read+0x5c>
    80005130:	fd840593          	addi	a1,s0,-40
    80005134:	4505                	li	a0,1
    80005136:	ffffd097          	auipc	ra,0xffffd
    8000513a:	790080e7          	jalr	1936(ra) # 800028c6 <argaddr>
    return -1;
    8000513e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005140:	00054d63          	bltz	a0,8000515a <sys_read+0x5c>
  return fileread(f, p, n);
    80005144:	fe442603          	lw	a2,-28(s0)
    80005148:	fd843583          	ld	a1,-40(s0)
    8000514c:	fe843503          	ld	a0,-24(s0)
    80005150:	fffff097          	auipc	ra,0xfffff
    80005154:	4a8080e7          	jalr	1192(ra) # 800045f8 <fileread>
    80005158:	87aa                	mv	a5,a0
}
    8000515a:	853e                	mv	a0,a5
    8000515c:	70a2                	ld	ra,40(sp)
    8000515e:	7402                	ld	s0,32(sp)
    80005160:	6145                	addi	sp,sp,48
    80005162:	8082                	ret

0000000080005164 <sys_write>:
{
    80005164:	7179                	addi	sp,sp,-48
    80005166:	f406                	sd	ra,40(sp)
    80005168:	f022                	sd	s0,32(sp)
    8000516a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000516c:	fe840613          	addi	a2,s0,-24
    80005170:	4581                	li	a1,0
    80005172:	4501                	li	a0,0
    80005174:	00000097          	auipc	ra,0x0
    80005178:	d2c080e7          	jalr	-724(ra) # 80004ea0 <argfd>
    return -1;
    8000517c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000517e:	04054163          	bltz	a0,800051c0 <sys_write+0x5c>
    80005182:	fe440593          	addi	a1,s0,-28
    80005186:	4509                	li	a0,2
    80005188:	ffffd097          	auipc	ra,0xffffd
    8000518c:	71c080e7          	jalr	1820(ra) # 800028a4 <argint>
    return -1;
    80005190:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005192:	02054763          	bltz	a0,800051c0 <sys_write+0x5c>
    80005196:	fd840593          	addi	a1,s0,-40
    8000519a:	4505                	li	a0,1
    8000519c:	ffffd097          	auipc	ra,0xffffd
    800051a0:	72a080e7          	jalr	1834(ra) # 800028c6 <argaddr>
    return -1;
    800051a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051a6:	00054d63          	bltz	a0,800051c0 <sys_write+0x5c>
  return filewrite(f, p, n);
    800051aa:	fe442603          	lw	a2,-28(s0)
    800051ae:	fd843583          	ld	a1,-40(s0)
    800051b2:	fe843503          	ld	a0,-24(s0)
    800051b6:	fffff097          	auipc	ra,0xfffff
    800051ba:	4f0080e7          	jalr	1264(ra) # 800046a6 <filewrite>
    800051be:	87aa                	mv	a5,a0
}
    800051c0:	853e                	mv	a0,a5
    800051c2:	70a2                	ld	ra,40(sp)
    800051c4:	7402                	ld	s0,32(sp)
    800051c6:	6145                	addi	sp,sp,48
    800051c8:	8082                	ret

00000000800051ca <sys_close>:
{
    800051ca:	1101                	addi	sp,sp,-32
    800051cc:	ec06                	sd	ra,24(sp)
    800051ce:	e822                	sd	s0,16(sp)
    800051d0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051d2:	fe040613          	addi	a2,s0,-32
    800051d6:	fec40593          	addi	a1,s0,-20
    800051da:	4501                	li	a0,0
    800051dc:	00000097          	auipc	ra,0x0
    800051e0:	cc4080e7          	jalr	-828(ra) # 80004ea0 <argfd>
    return -1;
    800051e4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051e6:	02054463          	bltz	a0,8000520e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800051ea:	ffffc097          	auipc	ra,0xffffc
    800051ee:	64a080e7          	jalr	1610(ra) # 80001834 <myproc>
    800051f2:	fec42783          	lw	a5,-20(s0)
    800051f6:	07e1                	addi	a5,a5,24
    800051f8:	078e                	slli	a5,a5,0x3
    800051fa:	97aa                	add	a5,a5,a0
    800051fc:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    80005200:	fe043503          	ld	a0,-32(s0)
    80005204:	fffff097          	auipc	ra,0xfffff
    80005208:	2b2080e7          	jalr	690(ra) # 800044b6 <fileclose>
  return 0;
    8000520c:	4781                	li	a5,0
}
    8000520e:	853e                	mv	a0,a5
    80005210:	60e2                	ld	ra,24(sp)
    80005212:	6442                	ld	s0,16(sp)
    80005214:	6105                	addi	sp,sp,32
    80005216:	8082                	ret

0000000080005218 <sys_fstat>:
{
    80005218:	1101                	addi	sp,sp,-32
    8000521a:	ec06                	sd	ra,24(sp)
    8000521c:	e822                	sd	s0,16(sp)
    8000521e:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005220:	fe840613          	addi	a2,s0,-24
    80005224:	4581                	li	a1,0
    80005226:	4501                	li	a0,0
    80005228:	00000097          	auipc	ra,0x0
    8000522c:	c78080e7          	jalr	-904(ra) # 80004ea0 <argfd>
    return -1;
    80005230:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005232:	02054563          	bltz	a0,8000525c <sys_fstat+0x44>
    80005236:	fe040593          	addi	a1,s0,-32
    8000523a:	4505                	li	a0,1
    8000523c:	ffffd097          	auipc	ra,0xffffd
    80005240:	68a080e7          	jalr	1674(ra) # 800028c6 <argaddr>
    return -1;
    80005244:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005246:	00054b63          	bltz	a0,8000525c <sys_fstat+0x44>
  return filestat(f, st);
    8000524a:	fe043583          	ld	a1,-32(s0)
    8000524e:	fe843503          	ld	a0,-24(s0)
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	334080e7          	jalr	820(ra) # 80004586 <filestat>
    8000525a:	87aa                	mv	a5,a0
}
    8000525c:	853e                	mv	a0,a5
    8000525e:	60e2                	ld	ra,24(sp)
    80005260:	6442                	ld	s0,16(sp)
    80005262:	6105                	addi	sp,sp,32
    80005264:	8082                	ret

0000000080005266 <sys_link>:
{
    80005266:	7169                	addi	sp,sp,-304
    80005268:	f606                	sd	ra,296(sp)
    8000526a:	f222                	sd	s0,288(sp)
    8000526c:	ee26                	sd	s1,280(sp)
    8000526e:	ea4a                	sd	s2,272(sp)
    80005270:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005272:	08000613          	li	a2,128
    80005276:	ed040593          	addi	a1,s0,-304
    8000527a:	4501                	li	a0,0
    8000527c:	ffffd097          	auipc	ra,0xffffd
    80005280:	66c080e7          	jalr	1644(ra) # 800028e8 <argstr>
    return -1;
    80005284:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005286:	12054363          	bltz	a0,800053ac <sys_link+0x146>
    8000528a:	08000613          	li	a2,128
    8000528e:	f5040593          	addi	a1,s0,-176
    80005292:	4505                	li	a0,1
    80005294:	ffffd097          	auipc	ra,0xffffd
    80005298:	654080e7          	jalr	1620(ra) # 800028e8 <argstr>
    return -1;
    8000529c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000529e:	10054763          	bltz	a0,800053ac <sys_link+0x146>
  begin_op(ROOTDEV);
    800052a2:	4501                	li	a0,0
    800052a4:	fffff097          	auipc	ra,0xfffff
    800052a8:	bea080e7          	jalr	-1046(ra) # 80003e8e <begin_op>
  if((ip = namei(old)) == 0){
    800052ac:	ed040513          	addi	a0,s0,-304
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	8c2080e7          	jalr	-1854(ra) # 80003b72 <namei>
    800052b8:	84aa                	mv	s1,a0
    800052ba:	c559                	beqz	a0,80005348 <sys_link+0xe2>
  ilock(ip);
    800052bc:	ffffe097          	auipc	ra,0xffffe
    800052c0:	12a080e7          	jalr	298(ra) # 800033e6 <ilock>
  if(ip->type == T_DIR){
    800052c4:	04449703          	lh	a4,68(s1)
    800052c8:	4785                	li	a5,1
    800052ca:	08f70663          	beq	a4,a5,80005356 <sys_link+0xf0>
  ip->nlink++;
    800052ce:	04a4d783          	lhu	a5,74(s1)
    800052d2:	2785                	addiw	a5,a5,1
    800052d4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052d8:	8526                	mv	a0,s1
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	042080e7          	jalr	66(ra) # 8000331c <iupdate>
  iunlock(ip);
    800052e2:	8526                	mv	a0,s1
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	1c4080e7          	jalr	452(ra) # 800034a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052ec:	fd040593          	addi	a1,s0,-48
    800052f0:	f5040513          	addi	a0,s0,-176
    800052f4:	fffff097          	auipc	ra,0xfffff
    800052f8:	89c080e7          	jalr	-1892(ra) # 80003b90 <nameiparent>
    800052fc:	892a                	mv	s2,a0
    800052fe:	cd2d                	beqz	a0,80005378 <sys_link+0x112>
  ilock(dp);
    80005300:	ffffe097          	auipc	ra,0xffffe
    80005304:	0e6080e7          	jalr	230(ra) # 800033e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005308:	00092703          	lw	a4,0(s2)
    8000530c:	409c                	lw	a5,0(s1)
    8000530e:	06f71063          	bne	a4,a5,8000536e <sys_link+0x108>
    80005312:	40d0                	lw	a2,4(s1)
    80005314:	fd040593          	addi	a1,s0,-48
    80005318:	854a                	mv	a0,s2
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	796080e7          	jalr	1942(ra) # 80003ab0 <dirlink>
    80005322:	04054663          	bltz	a0,8000536e <sys_link+0x108>
  iunlockput(dp);
    80005326:	854a                	mv	a0,s2
    80005328:	ffffe097          	auipc	ra,0xffffe
    8000532c:	2fc080e7          	jalr	764(ra) # 80003624 <iunlockput>
  iput(ip);
    80005330:	8526                	mv	a0,s1
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	1c2080e7          	jalr	450(ra) # 800034f4 <iput>
  end_op(ROOTDEV);
    8000533a:	4501                	li	a0,0
    8000533c:	fffff097          	auipc	ra,0xfffff
    80005340:	bfc080e7          	jalr	-1028(ra) # 80003f38 <end_op>
  return 0;
    80005344:	4781                	li	a5,0
    80005346:	a09d                	j	800053ac <sys_link+0x146>
    end_op(ROOTDEV);
    80005348:	4501                	li	a0,0
    8000534a:	fffff097          	auipc	ra,0xfffff
    8000534e:	bee080e7          	jalr	-1042(ra) # 80003f38 <end_op>
    return -1;
    80005352:	57fd                	li	a5,-1
    80005354:	a8a1                	j	800053ac <sys_link+0x146>
    iunlockput(ip);
    80005356:	8526                	mv	a0,s1
    80005358:	ffffe097          	auipc	ra,0xffffe
    8000535c:	2cc080e7          	jalr	716(ra) # 80003624 <iunlockput>
    end_op(ROOTDEV);
    80005360:	4501                	li	a0,0
    80005362:	fffff097          	auipc	ra,0xfffff
    80005366:	bd6080e7          	jalr	-1066(ra) # 80003f38 <end_op>
    return -1;
    8000536a:	57fd                	li	a5,-1
    8000536c:	a081                	j	800053ac <sys_link+0x146>
    iunlockput(dp);
    8000536e:	854a                	mv	a0,s2
    80005370:	ffffe097          	auipc	ra,0xffffe
    80005374:	2b4080e7          	jalr	692(ra) # 80003624 <iunlockput>
  ilock(ip);
    80005378:	8526                	mv	a0,s1
    8000537a:	ffffe097          	auipc	ra,0xffffe
    8000537e:	06c080e7          	jalr	108(ra) # 800033e6 <ilock>
  ip->nlink--;
    80005382:	04a4d783          	lhu	a5,74(s1)
    80005386:	37fd                	addiw	a5,a5,-1
    80005388:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000538c:	8526                	mv	a0,s1
    8000538e:	ffffe097          	auipc	ra,0xffffe
    80005392:	f8e080e7          	jalr	-114(ra) # 8000331c <iupdate>
  iunlockput(ip);
    80005396:	8526                	mv	a0,s1
    80005398:	ffffe097          	auipc	ra,0xffffe
    8000539c:	28c080e7          	jalr	652(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    800053a0:	4501                	li	a0,0
    800053a2:	fffff097          	auipc	ra,0xfffff
    800053a6:	b96080e7          	jalr	-1130(ra) # 80003f38 <end_op>
  return -1;
    800053aa:	57fd                	li	a5,-1
}
    800053ac:	853e                	mv	a0,a5
    800053ae:	70b2                	ld	ra,296(sp)
    800053b0:	7412                	ld	s0,288(sp)
    800053b2:	64f2                	ld	s1,280(sp)
    800053b4:	6952                	ld	s2,272(sp)
    800053b6:	6155                	addi	sp,sp,304
    800053b8:	8082                	ret

00000000800053ba <sys_unlink>:
{
    800053ba:	7151                	addi	sp,sp,-240
    800053bc:	f586                	sd	ra,232(sp)
    800053be:	f1a2                	sd	s0,224(sp)
    800053c0:	eda6                	sd	s1,216(sp)
    800053c2:	e9ca                	sd	s2,208(sp)
    800053c4:	e5ce                	sd	s3,200(sp)
    800053c6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053c8:	08000613          	li	a2,128
    800053cc:	f3040593          	addi	a1,s0,-208
    800053d0:	4501                	li	a0,0
    800053d2:	ffffd097          	auipc	ra,0xffffd
    800053d6:	516080e7          	jalr	1302(ra) # 800028e8 <argstr>
    800053da:	18054463          	bltz	a0,80005562 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    800053de:	4501                	li	a0,0
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	aae080e7          	jalr	-1362(ra) # 80003e8e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053e8:	fb040593          	addi	a1,s0,-80
    800053ec:	f3040513          	addi	a0,s0,-208
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	7a0080e7          	jalr	1952(ra) # 80003b90 <nameiparent>
    800053f8:	84aa                	mv	s1,a0
    800053fa:	cd61                	beqz	a0,800054d2 <sys_unlink+0x118>
  ilock(dp);
    800053fc:	ffffe097          	auipc	ra,0xffffe
    80005400:	fea080e7          	jalr	-22(ra) # 800033e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005404:	00002597          	auipc	a1,0x2
    80005408:	35c58593          	addi	a1,a1,860 # 80007760 <userret+0x6d0>
    8000540c:	fb040513          	addi	a0,s0,-80
    80005410:	ffffe097          	auipc	ra,0xffffe
    80005414:	476080e7          	jalr	1142(ra) # 80003886 <namecmp>
    80005418:	14050c63          	beqz	a0,80005570 <sys_unlink+0x1b6>
    8000541c:	00002597          	auipc	a1,0x2
    80005420:	34c58593          	addi	a1,a1,844 # 80007768 <userret+0x6d8>
    80005424:	fb040513          	addi	a0,s0,-80
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	45e080e7          	jalr	1118(ra) # 80003886 <namecmp>
    80005430:	14050063          	beqz	a0,80005570 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005434:	f2c40613          	addi	a2,s0,-212
    80005438:	fb040593          	addi	a1,s0,-80
    8000543c:	8526                	mv	a0,s1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	462080e7          	jalr	1122(ra) # 800038a0 <dirlookup>
    80005446:	892a                	mv	s2,a0
    80005448:	12050463          	beqz	a0,80005570 <sys_unlink+0x1b6>
  ilock(ip);
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	f9a080e7          	jalr	-102(ra) # 800033e6 <ilock>
  if(ip->nlink < 1)
    80005454:	04a91783          	lh	a5,74(s2)
    80005458:	08f05463          	blez	a5,800054e0 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000545c:	04491703          	lh	a4,68(s2)
    80005460:	4785                	li	a5,1
    80005462:	08f70763          	beq	a4,a5,800054f0 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005466:	4641                	li	a2,16
    80005468:	4581                	li	a1,0
    8000546a:	fc040513          	addi	a0,s0,-64
    8000546e:	ffffb097          	auipc	ra,0xffffb
    80005472:	728080e7          	jalr	1832(ra) # 80000b96 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005476:	4741                	li	a4,16
    80005478:	f2c42683          	lw	a3,-212(s0)
    8000547c:	fc040613          	addi	a2,s0,-64
    80005480:	4581                	li	a1,0
    80005482:	8526                	mv	a0,s1
    80005484:	ffffe097          	auipc	ra,0xffffe
    80005488:	2e6080e7          	jalr	742(ra) # 8000376a <writei>
    8000548c:	47c1                	li	a5,16
    8000548e:	0af51763          	bne	a0,a5,8000553c <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005492:	04491703          	lh	a4,68(s2)
    80005496:	4785                	li	a5,1
    80005498:	0af70a63          	beq	a4,a5,8000554c <sys_unlink+0x192>
  iunlockput(dp);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	186080e7          	jalr	390(ra) # 80003624 <iunlockput>
  ip->nlink--;
    800054a6:	04a95783          	lhu	a5,74(s2)
    800054aa:	37fd                	addiw	a5,a5,-1
    800054ac:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054b0:	854a                	mv	a0,s2
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	e6a080e7          	jalr	-406(ra) # 8000331c <iupdate>
  iunlockput(ip);
    800054ba:	854a                	mv	a0,s2
    800054bc:	ffffe097          	auipc	ra,0xffffe
    800054c0:	168080e7          	jalr	360(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    800054c4:	4501                	li	a0,0
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	a72080e7          	jalr	-1422(ra) # 80003f38 <end_op>
  return 0;
    800054ce:	4501                	li	a0,0
    800054d0:	a85d                	j	80005586 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    800054d2:	4501                	li	a0,0
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	a64080e7          	jalr	-1436(ra) # 80003f38 <end_op>
    return -1;
    800054dc:	557d                	li	a0,-1
    800054de:	a065                	j	80005586 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    800054e0:	00002517          	auipc	a0,0x2
    800054e4:	2b050513          	addi	a0,a0,688 # 80007790 <userret+0x700>
    800054e8:	ffffb097          	auipc	ra,0xffffb
    800054ec:	066080e7          	jalr	102(ra) # 8000054e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054f0:	04c92703          	lw	a4,76(s2)
    800054f4:	02000793          	li	a5,32
    800054f8:	f6e7f7e3          	bgeu	a5,a4,80005466 <sys_unlink+0xac>
    800054fc:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005500:	4741                	li	a4,16
    80005502:	86ce                	mv	a3,s3
    80005504:	f1840613          	addi	a2,s0,-232
    80005508:	4581                	li	a1,0
    8000550a:	854a                	mv	a0,s2
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	16a080e7          	jalr	362(ra) # 80003676 <readi>
    80005514:	47c1                	li	a5,16
    80005516:	00f51b63          	bne	a0,a5,8000552c <sys_unlink+0x172>
    if(de.inum != 0)
    8000551a:	f1845783          	lhu	a5,-232(s0)
    8000551e:	e7a1                	bnez	a5,80005566 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005520:	29c1                	addiw	s3,s3,16
    80005522:	04c92783          	lw	a5,76(s2)
    80005526:	fcf9ede3          	bltu	s3,a5,80005500 <sys_unlink+0x146>
    8000552a:	bf35                	j	80005466 <sys_unlink+0xac>
      panic("isdirempty: readi");
    8000552c:	00002517          	auipc	a0,0x2
    80005530:	27c50513          	addi	a0,a0,636 # 800077a8 <userret+0x718>
    80005534:	ffffb097          	auipc	ra,0xffffb
    80005538:	01a080e7          	jalr	26(ra) # 8000054e <panic>
    panic("unlink: writei");
    8000553c:	00002517          	auipc	a0,0x2
    80005540:	28450513          	addi	a0,a0,644 # 800077c0 <userret+0x730>
    80005544:	ffffb097          	auipc	ra,0xffffb
    80005548:	00a080e7          	jalr	10(ra) # 8000054e <panic>
    dp->nlink--;
    8000554c:	04a4d783          	lhu	a5,74(s1)
    80005550:	37fd                	addiw	a5,a5,-1
    80005552:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005556:	8526                	mv	a0,s1
    80005558:	ffffe097          	auipc	ra,0xffffe
    8000555c:	dc4080e7          	jalr	-572(ra) # 8000331c <iupdate>
    80005560:	bf35                	j	8000549c <sys_unlink+0xe2>
    return -1;
    80005562:	557d                	li	a0,-1
    80005564:	a00d                	j	80005586 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005566:	854a                	mv	a0,s2
    80005568:	ffffe097          	auipc	ra,0xffffe
    8000556c:	0bc080e7          	jalr	188(ra) # 80003624 <iunlockput>
  iunlockput(dp);
    80005570:	8526                	mv	a0,s1
    80005572:	ffffe097          	auipc	ra,0xffffe
    80005576:	0b2080e7          	jalr	178(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    8000557a:	4501                	li	a0,0
    8000557c:	fffff097          	auipc	ra,0xfffff
    80005580:	9bc080e7          	jalr	-1604(ra) # 80003f38 <end_op>
  return -1;
    80005584:	557d                	li	a0,-1
}
    80005586:	70ae                	ld	ra,232(sp)
    80005588:	740e                	ld	s0,224(sp)
    8000558a:	64ee                	ld	s1,216(sp)
    8000558c:	694e                	ld	s2,208(sp)
    8000558e:	69ae                	ld	s3,200(sp)
    80005590:	616d                	addi	sp,sp,240
    80005592:	8082                	ret

0000000080005594 <sys_open>:

uint64
sys_open(void)
{
    80005594:	7131                	addi	sp,sp,-192
    80005596:	fd06                	sd	ra,184(sp)
    80005598:	f922                	sd	s0,176(sp)
    8000559a:	f526                	sd	s1,168(sp)
    8000559c:	f14a                	sd	s2,160(sp)
    8000559e:	ed4e                	sd	s3,152(sp)
    800055a0:	0180                	addi	s0,sp,192
  char path[MAXPATH];
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, path, MAXPATH) < 0 || argint(1, &omode) < 0)
    800055a2:	08000613          	li	a2,128
    800055a6:	f5040593          	addi	a1,s0,-176
    800055aa:	4501                	li	a0,0
    800055ac:	ffffd097          	auipc	ra,0xffffd
    800055b0:	33c080e7          	jalr	828(ra) # 800028e8 <argstr>
    return -1;
    800055b4:	54fd                	li	s1,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &omode) < 0)
    800055b6:	0a054963          	bltz	a0,80005668 <sys_open+0xd4>
    800055ba:	f4c40593          	addi	a1,s0,-180
    800055be:	4505                	li	a0,1
    800055c0:	ffffd097          	auipc	ra,0xffffd
    800055c4:	2e4080e7          	jalr	740(ra) # 800028a4 <argint>
    800055c8:	0a054063          	bltz	a0,80005668 <sys_open+0xd4>

  begin_op(ROOTDEV);
    800055cc:	4501                	li	a0,0
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	8c0080e7          	jalr	-1856(ra) # 80003e8e <begin_op>

  if(omode & O_CREATE){
    800055d6:	f4c42783          	lw	a5,-180(s0)
    800055da:	2007f793          	andi	a5,a5,512
    800055de:	c3dd                	beqz	a5,80005684 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    800055e0:	4681                	li	a3,0
    800055e2:	4601                	li	a2,0
    800055e4:	4589                	li	a1,2
    800055e6:	f5040513          	addi	a0,s0,-176
    800055ea:	00000097          	auipc	ra,0x0
    800055ee:	960080e7          	jalr	-1696(ra) # 80004f4a <create>
    800055f2:	892a                	mv	s2,a0
    if(ip == 0){
    800055f4:	c151                	beqz	a0,80005678 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055f6:	04491703          	lh	a4,68(s2)
    800055fa:	478d                	li	a5,3
    800055fc:	00f71763          	bne	a4,a5,8000560a <sys_open+0x76>
    80005600:	04695703          	lhu	a4,70(s2)
    80005604:	47a5                	li	a5,9
    80005606:	0ce7e663          	bltu	a5,a4,800056d2 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	df0080e7          	jalr	-528(ra) # 800043fa <filealloc>
    80005612:	89aa                	mv	s3,a0
    80005614:	c57d                	beqz	a0,80005702 <sys_open+0x16e>
    80005616:	00000097          	auipc	ra,0x0
    8000561a:	8f2080e7          	jalr	-1806(ra) # 80004f08 <fdalloc>
    8000561e:	84aa                	mv	s1,a0
    80005620:	0c054c63          	bltz	a0,800056f8 <sys_open+0x164>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005624:	04491703          	lh	a4,68(s2)
    80005628:	478d                	li	a5,3
    8000562a:	0cf70063          	beq	a4,a5,800056ea <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000562e:	4789                	li	a5,2
    80005630:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005634:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005638:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000563c:	f4c42783          	lw	a5,-180(s0)
    80005640:	0017c713          	xori	a4,a5,1
    80005644:	8b05                	andi	a4,a4,1
    80005646:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000564a:	8b8d                	andi	a5,a5,3
    8000564c:	00f037b3          	snez	a5,a5
    80005650:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005654:	854a                	mv	a0,s2
    80005656:	ffffe097          	auipc	ra,0xffffe
    8000565a:	e52080e7          	jalr	-430(ra) # 800034a8 <iunlock>
  end_op(ROOTDEV);
    8000565e:	4501                	li	a0,0
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	8d8080e7          	jalr	-1832(ra) # 80003f38 <end_op>

  return fd;
}
    80005668:	8526                	mv	a0,s1
    8000566a:	70ea                	ld	ra,184(sp)
    8000566c:	744a                	ld	s0,176(sp)
    8000566e:	74aa                	ld	s1,168(sp)
    80005670:	790a                	ld	s2,160(sp)
    80005672:	69ea                	ld	s3,152(sp)
    80005674:	6129                	addi	sp,sp,192
    80005676:	8082                	ret
      end_op(ROOTDEV);
    80005678:	4501                	li	a0,0
    8000567a:	fffff097          	auipc	ra,0xfffff
    8000567e:	8be080e7          	jalr	-1858(ra) # 80003f38 <end_op>
      return -1;
    80005682:	b7dd                	j	80005668 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005684:	f5040513          	addi	a0,s0,-176
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	4ea080e7          	jalr	1258(ra) # 80003b72 <namei>
    80005690:	892a                	mv	s2,a0
    80005692:	c90d                	beqz	a0,800056c4 <sys_open+0x130>
    ilock(ip);
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	d52080e7          	jalr	-686(ra) # 800033e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000569c:	04491703          	lh	a4,68(s2)
    800056a0:	4785                	li	a5,1
    800056a2:	f4f71ae3          	bne	a4,a5,800055f6 <sys_open+0x62>
    800056a6:	f4c42783          	lw	a5,-180(s0)
    800056aa:	d3a5                	beqz	a5,8000560a <sys_open+0x76>
      iunlockput(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	f76080e7          	jalr	-138(ra) # 80003624 <iunlockput>
      end_op(ROOTDEV);
    800056b6:	4501                	li	a0,0
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	880080e7          	jalr	-1920(ra) # 80003f38 <end_op>
      return -1;
    800056c0:	54fd                	li	s1,-1
    800056c2:	b75d                	j	80005668 <sys_open+0xd4>
      end_op(ROOTDEV);
    800056c4:	4501                	li	a0,0
    800056c6:	fffff097          	auipc	ra,0xfffff
    800056ca:	872080e7          	jalr	-1934(ra) # 80003f38 <end_op>
      return -1;
    800056ce:	54fd                	li	s1,-1
    800056d0:	bf61                	j	80005668 <sys_open+0xd4>
    iunlockput(ip);
    800056d2:	854a                	mv	a0,s2
    800056d4:	ffffe097          	auipc	ra,0xffffe
    800056d8:	f50080e7          	jalr	-176(ra) # 80003624 <iunlockput>
    end_op(ROOTDEV);
    800056dc:	4501                	li	a0,0
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	85a080e7          	jalr	-1958(ra) # 80003f38 <end_op>
    return -1;
    800056e6:	54fd                	li	s1,-1
    800056e8:	b741                	j	80005668 <sys_open+0xd4>
    f->type = FD_DEVICE;
    800056ea:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800056ee:	04691783          	lh	a5,70(s2)
    800056f2:	02f99223          	sh	a5,36(s3)
    800056f6:	b789                	j	80005638 <sys_open+0xa4>
      fileclose(f);
    800056f8:	854e                	mv	a0,s3
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	dbc080e7          	jalr	-580(ra) # 800044b6 <fileclose>
    iunlockput(ip);
    80005702:	854a                	mv	a0,s2
    80005704:	ffffe097          	auipc	ra,0xffffe
    80005708:	f20080e7          	jalr	-224(ra) # 80003624 <iunlockput>
    end_op(ROOTDEV);
    8000570c:	4501                	li	a0,0
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	82a080e7          	jalr	-2006(ra) # 80003f38 <end_op>
    return -1;
    80005716:	54fd                	li	s1,-1
    80005718:	bf81                	j	80005668 <sys_open+0xd4>

000000008000571a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000571a:	7175                	addi	sp,sp,-144
    8000571c:	e506                	sd	ra,136(sp)
    8000571e:	e122                	sd	s0,128(sp)
    80005720:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005722:	4501                	li	a0,0
    80005724:	ffffe097          	auipc	ra,0xffffe
    80005728:	76a080e7          	jalr	1898(ra) # 80003e8e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000572c:	08000613          	li	a2,128
    80005730:	f7040593          	addi	a1,s0,-144
    80005734:	4501                	li	a0,0
    80005736:	ffffd097          	auipc	ra,0xffffd
    8000573a:	1b2080e7          	jalr	434(ra) # 800028e8 <argstr>
    8000573e:	02054a63          	bltz	a0,80005772 <sys_mkdir+0x58>
    80005742:	4681                	li	a3,0
    80005744:	4601                	li	a2,0
    80005746:	4585                	li	a1,1
    80005748:	f7040513          	addi	a0,s0,-144
    8000574c:	fffff097          	auipc	ra,0xfffff
    80005750:	7fe080e7          	jalr	2046(ra) # 80004f4a <create>
    80005754:	cd19                	beqz	a0,80005772 <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	ece080e7          	jalr	-306(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    8000575e:	4501                	li	a0,0
    80005760:	ffffe097          	auipc	ra,0xffffe
    80005764:	7d8080e7          	jalr	2008(ra) # 80003f38 <end_op>
  return 0;
    80005768:	4501                	li	a0,0
}
    8000576a:	60aa                	ld	ra,136(sp)
    8000576c:	640a                	ld	s0,128(sp)
    8000576e:	6149                	addi	sp,sp,144
    80005770:	8082                	ret
    end_op(ROOTDEV);
    80005772:	4501                	li	a0,0
    80005774:	ffffe097          	auipc	ra,0xffffe
    80005778:	7c4080e7          	jalr	1988(ra) # 80003f38 <end_op>
    return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	b7f5                	j	8000576a <sys_mkdir+0x50>

0000000080005780 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005780:	7135                	addi	sp,sp,-160
    80005782:	ed06                	sd	ra,152(sp)
    80005784:	e922                	sd	s0,144(sp)
    80005786:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005788:	4501                	li	a0,0
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	704080e7          	jalr	1796(ra) # 80003e8e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005792:	08000613          	li	a2,128
    80005796:	f7040593          	addi	a1,s0,-144
    8000579a:	4501                	li	a0,0
    8000579c:	ffffd097          	auipc	ra,0xffffd
    800057a0:	14c080e7          	jalr	332(ra) # 800028e8 <argstr>
    800057a4:	04054b63          	bltz	a0,800057fa <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    800057a8:	f6c40593          	addi	a1,s0,-148
    800057ac:	4505                	li	a0,1
    800057ae:	ffffd097          	auipc	ra,0xffffd
    800057b2:	0f6080e7          	jalr	246(ra) # 800028a4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057b6:	04054263          	bltz	a0,800057fa <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    800057ba:	f6840593          	addi	a1,s0,-152
    800057be:	4509                	li	a0,2
    800057c0:	ffffd097          	auipc	ra,0xffffd
    800057c4:	0e4080e7          	jalr	228(ra) # 800028a4 <argint>
     argint(1, &major) < 0 ||
    800057c8:	02054963          	bltz	a0,800057fa <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057cc:	f6841683          	lh	a3,-152(s0)
    800057d0:	f6c41603          	lh	a2,-148(s0)
    800057d4:	458d                	li	a1,3
    800057d6:	f7040513          	addi	a0,s0,-144
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	770080e7          	jalr	1904(ra) # 80004f4a <create>
     argint(2, &minor) < 0 ||
    800057e2:	cd01                	beqz	a0,800057fa <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    800057e4:	ffffe097          	auipc	ra,0xffffe
    800057e8:	e40080e7          	jalr	-448(ra) # 80003624 <iunlockput>
  end_op(ROOTDEV);
    800057ec:	4501                	li	a0,0
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	74a080e7          	jalr	1866(ra) # 80003f38 <end_op>
  return 0;
    800057f6:	4501                	li	a0,0
    800057f8:	a039                	j	80005806 <sys_mknod+0x86>
    end_op(ROOTDEV);
    800057fa:	4501                	li	a0,0
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	73c080e7          	jalr	1852(ra) # 80003f38 <end_op>
    return -1;
    80005804:	557d                	li	a0,-1
}
    80005806:	60ea                	ld	ra,152(sp)
    80005808:	644a                	ld	s0,144(sp)
    8000580a:	610d                	addi	sp,sp,160
    8000580c:	8082                	ret

000000008000580e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000580e:	7135                	addi	sp,sp,-160
    80005810:	ed06                	sd	ra,152(sp)
    80005812:	e922                	sd	s0,144(sp)
    80005814:	e526                	sd	s1,136(sp)
    80005816:	e14a                	sd	s2,128(sp)
    80005818:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000581a:	ffffc097          	auipc	ra,0xffffc
    8000581e:	01a080e7          	jalr	26(ra) # 80001834 <myproc>
    80005822:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005824:	4501                	li	a0,0
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	668080e7          	jalr	1640(ra) # 80003e8e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000582e:	08000613          	li	a2,128
    80005832:	f6040593          	addi	a1,s0,-160
    80005836:	4501                	li	a0,0
    80005838:	ffffd097          	auipc	ra,0xffffd
    8000583c:	0b0080e7          	jalr	176(ra) # 800028e8 <argstr>
    80005840:	04054c63          	bltz	a0,80005898 <sys_chdir+0x8a>
    80005844:	f6040513          	addi	a0,s0,-160
    80005848:	ffffe097          	auipc	ra,0xffffe
    8000584c:	32a080e7          	jalr	810(ra) # 80003b72 <namei>
    80005850:	84aa                	mv	s1,a0
    80005852:	c139                	beqz	a0,80005898 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	b92080e7          	jalr	-1134(ra) # 800033e6 <ilock>
  if(ip->type != T_DIR){
    8000585c:	04449703          	lh	a4,68(s1)
    80005860:	4785                	li	a5,1
    80005862:	04f71263          	bne	a4,a5,800058a6 <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	c40080e7          	jalr	-960(ra) # 800034a8 <iunlock>
  iput(p->cwd);
    80005870:	14893503          	ld	a0,328(s2)
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	c80080e7          	jalr	-896(ra) # 800034f4 <iput>
  end_op(ROOTDEV);
    8000587c:	4501                	li	a0,0
    8000587e:	ffffe097          	auipc	ra,0xffffe
    80005882:	6ba080e7          	jalr	1722(ra) # 80003f38 <end_op>
  p->cwd = ip;
    80005886:	14993423          	sd	s1,328(s2)
  return 0;
    8000588a:	4501                	li	a0,0
}
    8000588c:	60ea                	ld	ra,152(sp)
    8000588e:	644a                	ld	s0,144(sp)
    80005890:	64aa                	ld	s1,136(sp)
    80005892:	690a                	ld	s2,128(sp)
    80005894:	610d                	addi	sp,sp,160
    80005896:	8082                	ret
    end_op(ROOTDEV);
    80005898:	4501                	li	a0,0
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	69e080e7          	jalr	1694(ra) # 80003f38 <end_op>
    return -1;
    800058a2:	557d                	li	a0,-1
    800058a4:	b7e5                	j	8000588c <sys_chdir+0x7e>
    iunlockput(ip);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	d7c080e7          	jalr	-644(ra) # 80003624 <iunlockput>
    end_op(ROOTDEV);
    800058b0:	4501                	li	a0,0
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	686080e7          	jalr	1670(ra) # 80003f38 <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	bfc1                	j	8000588c <sys_chdir+0x7e>

00000000800058be <sys_exec>:

uint64
sys_exec(void)
{
    800058be:	7145                	addi	sp,sp,-464
    800058c0:	e786                	sd	ra,456(sp)
    800058c2:	e3a2                	sd	s0,448(sp)
    800058c4:	ff26                	sd	s1,440(sp)
    800058c6:	fb4a                	sd	s2,432(sp)
    800058c8:	f74e                	sd	s3,424(sp)
    800058ca:	f352                	sd	s4,416(sp)
    800058cc:	ef56                	sd	s5,408(sp)
    800058ce:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800058d0:	08000613          	li	a2,128
    800058d4:	f4040593          	addi	a1,s0,-192
    800058d8:	4501                	li	a0,0
    800058da:	ffffd097          	auipc	ra,0xffffd
    800058de:	00e080e7          	jalr	14(ra) # 800028e8 <argstr>
    800058e2:	0c054863          	bltz	a0,800059b2 <sys_exec+0xf4>
    800058e6:	e3840593          	addi	a1,s0,-456
    800058ea:	4505                	li	a0,1
    800058ec:	ffffd097          	auipc	ra,0xffffd
    800058f0:	fda080e7          	jalr	-38(ra) # 800028c6 <argaddr>
    800058f4:	0c054963          	bltz	a0,800059c6 <sys_exec+0x108>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    800058f8:	10000613          	li	a2,256
    800058fc:	4581                	li	a1,0
    800058fe:	e4040513          	addi	a0,s0,-448
    80005902:	ffffb097          	auipc	ra,0xffffb
    80005906:	294080e7          	jalr	660(ra) # 80000b96 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000590a:	e4040993          	addi	s3,s0,-448
  memset(argv, 0, sizeof(argv));
    8000590e:	894e                	mv	s2,s3
    80005910:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005912:	02000a13          	li	s4,32
    80005916:	00048a9b          	sext.w	s5,s1
      return -1;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000591a:	00349513          	slli	a0,s1,0x3
    8000591e:	e3040593          	addi	a1,s0,-464
    80005922:	e3843783          	ld	a5,-456(s0)
    80005926:	953e                	add	a0,a0,a5
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	ee2080e7          	jalr	-286(ra) # 8000280a <fetchaddr>
    80005930:	08054d63          	bltz	a0,800059ca <sys_exec+0x10c>
      return -1;
    }
    if(uarg == 0){
    80005934:	e3043783          	ld	a5,-464(s0)
    80005938:	cb85                	beqz	a5,80005968 <sys_exec+0xaa>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000593a:	ffffb097          	auipc	ra,0xffffb
    8000593e:	026080e7          	jalr	38(ra) # 80000960 <kalloc>
    80005942:	85aa                	mv	a1,a0
    80005944:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80005948:	cd29                	beqz	a0,800059a2 <sys_exec+0xe4>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    8000594a:	6605                	lui	a2,0x1
    8000594c:	e3043503          	ld	a0,-464(s0)
    80005950:	ffffd097          	auipc	ra,0xffffd
    80005954:	f0c080e7          	jalr	-244(ra) # 8000285c <fetchstr>
    80005958:	06054b63          	bltz	a0,800059ce <sys_exec+0x110>
    if(i >= NELEM(argv)){
    8000595c:	0485                	addi	s1,s1,1
    8000595e:	0921                	addi	s2,s2,8
    80005960:	fb449be3          	bne	s1,s4,80005916 <sys_exec+0x58>
      return -1;
    80005964:	557d                	li	a0,-1
    80005966:	a0b9                	j	800059b4 <sys_exec+0xf6>
      argv[i] = 0;
    80005968:	0a8e                	slli	s5,s5,0x3
    8000596a:	fc040793          	addi	a5,s0,-64
    8000596e:	9abe                	add	s5,s5,a5
    80005970:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <ticks+0xffffffff7ffd5e58>
      return -1;
    }
  }

  int ret = exec(path, argv);
    80005974:	e4040593          	addi	a1,s0,-448
    80005978:	f4040513          	addi	a0,s0,-192
    8000597c:	fffff097          	auipc	ra,0xfffff
    80005980:	1ba080e7          	jalr	442(ra) # 80004b36 <exec>
    80005984:	84aa                	mv	s1,a0

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005986:	10098913          	addi	s2,s3,256
    8000598a:	0009b503          	ld	a0,0(s3)
    8000598e:	c901                	beqz	a0,8000599e <sys_exec+0xe0>
    kfree(argv[i]);
    80005990:	ffffb097          	auipc	ra,0xffffb
    80005994:	ed4080e7          	jalr	-300(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005998:	09a1                	addi	s3,s3,8
    8000599a:	ff2998e3          	bne	s3,s2,8000598a <sys_exec+0xcc>

  return ret;
    8000599e:	8526                	mv	a0,s1
    800059a0:	a811                	j	800059b4 <sys_exec+0xf6>
      panic("sys_exec kalloc");
    800059a2:	00002517          	auipc	a0,0x2
    800059a6:	e2e50513          	addi	a0,a0,-466 # 800077d0 <userret+0x740>
    800059aa:	ffffb097          	auipc	ra,0xffffb
    800059ae:	ba4080e7          	jalr	-1116(ra) # 8000054e <panic>
    return -1;
    800059b2:	557d                	li	a0,-1
}
    800059b4:	60be                	ld	ra,456(sp)
    800059b6:	641e                	ld	s0,448(sp)
    800059b8:	74fa                	ld	s1,440(sp)
    800059ba:	795a                	ld	s2,432(sp)
    800059bc:	79ba                	ld	s3,424(sp)
    800059be:	7a1a                	ld	s4,416(sp)
    800059c0:	6afa                	ld	s5,408(sp)
    800059c2:	6179                	addi	sp,sp,464
    800059c4:	8082                	ret
    return -1;
    800059c6:	557d                	li	a0,-1
    800059c8:	b7f5                	j	800059b4 <sys_exec+0xf6>
      return -1;
    800059ca:	557d                	li	a0,-1
    800059cc:	b7e5                	j	800059b4 <sys_exec+0xf6>
      return -1;
    800059ce:	557d                	li	a0,-1
    800059d0:	b7d5                	j	800059b4 <sys_exec+0xf6>

00000000800059d2 <sys_pipe>:

uint64
sys_pipe(void)
{
    800059d2:	7139                	addi	sp,sp,-64
    800059d4:	fc06                	sd	ra,56(sp)
    800059d6:	f822                	sd	s0,48(sp)
    800059d8:	f426                	sd	s1,40(sp)
    800059da:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059dc:	ffffc097          	auipc	ra,0xffffc
    800059e0:	e58080e7          	jalr	-424(ra) # 80001834 <myproc>
    800059e4:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800059e6:	fd840593          	addi	a1,s0,-40
    800059ea:	4501                	li	a0,0
    800059ec:	ffffd097          	auipc	ra,0xffffd
    800059f0:	eda080e7          	jalr	-294(ra) # 800028c6 <argaddr>
    return -1;
    800059f4:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800059f6:	0e054063          	bltz	a0,80005ad6 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800059fa:	fc840593          	addi	a1,s0,-56
    800059fe:	fd040513          	addi	a0,s0,-48
    80005a02:	fffff097          	auipc	ra,0xfffff
    80005a06:	de8080e7          	jalr	-536(ra) # 800047ea <pipealloc>
    return -1;
    80005a0a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a0c:	0c054563          	bltz	a0,80005ad6 <sys_pipe+0x104>
  fd0 = -1;
    80005a10:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a14:	fd043503          	ld	a0,-48(s0)
    80005a18:	fffff097          	auipc	ra,0xfffff
    80005a1c:	4f0080e7          	jalr	1264(ra) # 80004f08 <fdalloc>
    80005a20:	fca42223          	sw	a0,-60(s0)
    80005a24:	08054c63          	bltz	a0,80005abc <sys_pipe+0xea>
    80005a28:	fc843503          	ld	a0,-56(s0)
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	4dc080e7          	jalr	1244(ra) # 80004f08 <fdalloc>
    80005a34:	fca42023          	sw	a0,-64(s0)
    80005a38:	06054863          	bltz	a0,80005aa8 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a3c:	4691                	li	a3,4
    80005a3e:	fc440613          	addi	a2,s0,-60
    80005a42:	fd843583          	ld	a1,-40(s0)
    80005a46:	64a8                	ld	a0,72(s1)
    80005a48:	ffffc097          	auipc	ra,0xffffc
    80005a4c:	b12080e7          	jalr	-1262(ra) # 8000155a <copyout>
    80005a50:	02054063          	bltz	a0,80005a70 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a54:	4691                	li	a3,4
    80005a56:	fc040613          	addi	a2,s0,-64
    80005a5a:	fd843583          	ld	a1,-40(s0)
    80005a5e:	0591                	addi	a1,a1,4
    80005a60:	64a8                	ld	a0,72(s1)
    80005a62:	ffffc097          	auipc	ra,0xffffc
    80005a66:	af8080e7          	jalr	-1288(ra) # 8000155a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a6a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a6c:	06055563          	bgez	a0,80005ad6 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005a70:	fc442783          	lw	a5,-60(s0)
    80005a74:	07e1                	addi	a5,a5,24
    80005a76:	078e                	slli	a5,a5,0x3
    80005a78:	97a6                	add	a5,a5,s1
    80005a7a:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005a7e:	fc042503          	lw	a0,-64(s0)
    80005a82:	0561                	addi	a0,a0,24
    80005a84:	050e                	slli	a0,a0,0x3
    80005a86:	9526                	add	a0,a0,s1
    80005a88:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005a8c:	fd043503          	ld	a0,-48(s0)
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	a26080e7          	jalr	-1498(ra) # 800044b6 <fileclose>
    fileclose(wf);
    80005a98:	fc843503          	ld	a0,-56(s0)
    80005a9c:	fffff097          	auipc	ra,0xfffff
    80005aa0:	a1a080e7          	jalr	-1510(ra) # 800044b6 <fileclose>
    return -1;
    80005aa4:	57fd                	li	a5,-1
    80005aa6:	a805                	j	80005ad6 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005aa8:	fc442783          	lw	a5,-60(s0)
    80005aac:	0007c863          	bltz	a5,80005abc <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005ab0:	01878513          	addi	a0,a5,24
    80005ab4:	050e                	slli	a0,a0,0x3
    80005ab6:	9526                	add	a0,a0,s1
    80005ab8:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005abc:	fd043503          	ld	a0,-48(s0)
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	9f6080e7          	jalr	-1546(ra) # 800044b6 <fileclose>
    fileclose(wf);
    80005ac8:	fc843503          	ld	a0,-56(s0)
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	9ea080e7          	jalr	-1558(ra) # 800044b6 <fileclose>
    return -1;
    80005ad4:	57fd                	li	a5,-1
}
    80005ad6:	853e                	mv	a0,a5
    80005ad8:	70e2                	ld	ra,56(sp)
    80005ada:	7442                	ld	s0,48(sp)
    80005adc:	74a2                	ld	s1,40(sp)
    80005ade:	6121                	addi	sp,sp,64
    80005ae0:	8082                	ret

0000000080005ae2 <sys_crash>:

// system call to test crashes
uint64
sys_crash(void)
{
    80005ae2:	7171                	addi	sp,sp,-176
    80005ae4:	f506                	sd	ra,168(sp)
    80005ae6:	f122                	sd	s0,160(sp)
    80005ae8:	ed26                	sd	s1,152(sp)
    80005aea:	1900                	addi	s0,sp,176
  char path[MAXPATH];
  struct inode *ip;
  int crash;
  
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005aec:	08000613          	li	a2,128
    80005af0:	f6040593          	addi	a1,s0,-160
    80005af4:	4501                	li	a0,0
    80005af6:	ffffd097          	auipc	ra,0xffffd
    80005afa:	df2080e7          	jalr	-526(ra) # 800028e8 <argstr>
    return -1;
    80005afe:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005b00:	04054363          	bltz	a0,80005b46 <sys_crash+0x64>
    80005b04:	f5c40593          	addi	a1,s0,-164
    80005b08:	4505                	li	a0,1
    80005b0a:	ffffd097          	auipc	ra,0xffffd
    80005b0e:	d9a080e7          	jalr	-614(ra) # 800028a4 <argint>
    return -1;
    80005b12:	57fd                	li	a5,-1
  if(argstr(0, path, MAXPATH) < 0 || argint(1, &crash) < 0)
    80005b14:	02054963          	bltz	a0,80005b46 <sys_crash+0x64>
  ip = create(path, T_FILE, 0, 0);
    80005b18:	4681                	li	a3,0
    80005b1a:	4601                	li	a2,0
    80005b1c:	4589                	li	a1,2
    80005b1e:	f6040513          	addi	a0,s0,-160
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	428080e7          	jalr	1064(ra) # 80004f4a <create>
    80005b2a:	84aa                	mv	s1,a0
  if(ip == 0){
    80005b2c:	c11d                	beqz	a0,80005b52 <sys_crash+0x70>
    return -1;
  }
  iunlockput(ip);
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	af6080e7          	jalr	-1290(ra) # 80003624 <iunlockput>
  crash_op(ip->dev, crash);
    80005b36:	f5c42583          	lw	a1,-164(s0)
    80005b3a:	4088                	lw	a0,0(s1)
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	64e080e7          	jalr	1614(ra) # 8000418a <crash_op>
  return 0;
    80005b44:	4781                	li	a5,0
}
    80005b46:	853e                	mv	a0,a5
    80005b48:	70aa                	ld	ra,168(sp)
    80005b4a:	740a                	ld	s0,160(sp)
    80005b4c:	64ea                	ld	s1,152(sp)
    80005b4e:	614d                	addi	sp,sp,176
    80005b50:	8082                	ret
    return -1;
    80005b52:	57fd                	li	a5,-1
    80005b54:	bfcd                	j	80005b46 <sys_crash+0x64>
	...

0000000080005b60 <kernelvec>:
    80005b60:	7111                	addi	sp,sp,-256
    80005b62:	e006                	sd	ra,0(sp)
    80005b64:	e40a                	sd	sp,8(sp)
    80005b66:	e80e                	sd	gp,16(sp)
    80005b68:	ec12                	sd	tp,24(sp)
    80005b6a:	f016                	sd	t0,32(sp)
    80005b6c:	f41a                	sd	t1,40(sp)
    80005b6e:	f81e                	sd	t2,48(sp)
    80005b70:	fc22                	sd	s0,56(sp)
    80005b72:	e0a6                	sd	s1,64(sp)
    80005b74:	e4aa                	sd	a0,72(sp)
    80005b76:	e8ae                	sd	a1,80(sp)
    80005b78:	ecb2                	sd	a2,88(sp)
    80005b7a:	f0b6                	sd	a3,96(sp)
    80005b7c:	f4ba                	sd	a4,104(sp)
    80005b7e:	f8be                	sd	a5,112(sp)
    80005b80:	fcc2                	sd	a6,120(sp)
    80005b82:	e146                	sd	a7,128(sp)
    80005b84:	e54a                	sd	s2,136(sp)
    80005b86:	e94e                	sd	s3,144(sp)
    80005b88:	ed52                	sd	s4,152(sp)
    80005b8a:	f156                	sd	s5,160(sp)
    80005b8c:	f55a                	sd	s6,168(sp)
    80005b8e:	f95e                	sd	s7,176(sp)
    80005b90:	fd62                	sd	s8,184(sp)
    80005b92:	e1e6                	sd	s9,192(sp)
    80005b94:	e5ea                	sd	s10,200(sp)
    80005b96:	e9ee                	sd	s11,208(sp)
    80005b98:	edf2                	sd	t3,216(sp)
    80005b9a:	f1f6                	sd	t4,224(sp)
    80005b9c:	f5fa                	sd	t5,232(sp)
    80005b9e:	f9fe                	sd	t6,240(sp)
    80005ba0:	b37fc0ef          	jal	ra,800026d6 <kerneltrap>
    80005ba4:	6082                	ld	ra,0(sp)
    80005ba6:	6122                	ld	sp,8(sp)
    80005ba8:	61c2                	ld	gp,16(sp)
    80005baa:	7282                	ld	t0,32(sp)
    80005bac:	7322                	ld	t1,40(sp)
    80005bae:	73c2                	ld	t2,48(sp)
    80005bb0:	7462                	ld	s0,56(sp)
    80005bb2:	6486                	ld	s1,64(sp)
    80005bb4:	6526                	ld	a0,72(sp)
    80005bb6:	65c6                	ld	a1,80(sp)
    80005bb8:	6666                	ld	a2,88(sp)
    80005bba:	7686                	ld	a3,96(sp)
    80005bbc:	7726                	ld	a4,104(sp)
    80005bbe:	77c6                	ld	a5,112(sp)
    80005bc0:	7866                	ld	a6,120(sp)
    80005bc2:	688a                	ld	a7,128(sp)
    80005bc4:	692a                	ld	s2,136(sp)
    80005bc6:	69ca                	ld	s3,144(sp)
    80005bc8:	6a6a                	ld	s4,152(sp)
    80005bca:	7a8a                	ld	s5,160(sp)
    80005bcc:	7b2a                	ld	s6,168(sp)
    80005bce:	7bca                	ld	s7,176(sp)
    80005bd0:	7c6a                	ld	s8,184(sp)
    80005bd2:	6c8e                	ld	s9,192(sp)
    80005bd4:	6d2e                	ld	s10,200(sp)
    80005bd6:	6dce                	ld	s11,208(sp)
    80005bd8:	6e6e                	ld	t3,216(sp)
    80005bda:	7e8e                	ld	t4,224(sp)
    80005bdc:	7f2e                	ld	t5,232(sp)
    80005bde:	7fce                	ld	t6,240(sp)
    80005be0:	6111                	addi	sp,sp,256
    80005be2:	10200073          	sret
    80005be6:	00000013          	nop
    80005bea:	00000013          	nop
    80005bee:	0001                	nop

0000000080005bf0 <timervec>:
    80005bf0:	34051573          	csrrw	a0,mscratch,a0
    80005bf4:	e10c                	sd	a1,0(a0)
    80005bf6:	e510                	sd	a2,8(a0)
    80005bf8:	e914                	sd	a3,16(a0)
    80005bfa:	710c                	ld	a1,32(a0)
    80005bfc:	7510                	ld	a2,40(a0)
    80005bfe:	6194                	ld	a3,0(a1)
    80005c00:	96b2                	add	a3,a3,a2
    80005c02:	e194                	sd	a3,0(a1)
    80005c04:	4589                	li	a1,2
    80005c06:	14459073          	csrw	sip,a1
    80005c0a:	6914                	ld	a3,16(a0)
    80005c0c:	6510                	ld	a2,8(a0)
    80005c0e:	610c                	ld	a1,0(a0)
    80005c10:	34051573          	csrrw	a0,mscratch,a0
    80005c14:	30200073          	mret
	...

0000000080005c1a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c1a:	1141                	addi	sp,sp,-16
    80005c1c:	e422                	sd	s0,8(sp)
    80005c1e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c20:	0c0007b7          	lui	a5,0xc000
    80005c24:	4705                	li	a4,1
    80005c26:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c28:	c3d8                	sw	a4,4(a5)
}
    80005c2a:	6422                	ld	s0,8(sp)
    80005c2c:	0141                	addi	sp,sp,16
    80005c2e:	8082                	ret

0000000080005c30 <plicinithart>:

void
plicinithart(void)
{
    80005c30:	1141                	addi	sp,sp,-16
    80005c32:	e406                	sd	ra,8(sp)
    80005c34:	e022                	sd	s0,0(sp)
    80005c36:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c38:	ffffc097          	auipc	ra,0xffffc
    80005c3c:	bd0080e7          	jalr	-1072(ra) # 80001808 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c40:	0085171b          	slliw	a4,a0,0x8
    80005c44:	0c0027b7          	lui	a5,0xc002
    80005c48:	97ba                	add	a5,a5,a4
    80005c4a:	40200713          	li	a4,1026
    80005c4e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c52:	00d5151b          	slliw	a0,a0,0xd
    80005c56:	0c2017b7          	lui	a5,0xc201
    80005c5a:	953e                	add	a0,a0,a5
    80005c5c:	00052023          	sw	zero,0(a0)
}
    80005c60:	60a2                	ld	ra,8(sp)
    80005c62:	6402                	ld	s0,0(sp)
    80005c64:	0141                	addi	sp,sp,16
    80005c66:	8082                	ret

0000000080005c68 <plic_pending>:

// return a bitmap of which IRQs are waiting
// to be served.
uint64
plic_pending(void)
{
    80005c68:	1141                	addi	sp,sp,-16
    80005c6a:	e422                	sd	s0,8(sp)
    80005c6c:	0800                	addi	s0,sp,16
  //mask = *(uint32*)(PLIC + 0x1000);
  //mask |= (uint64)*(uint32*)(PLIC + 0x1004) << 32;
  mask = *(uint64*)PLIC_PENDING;

  return mask;
}
    80005c6e:	0c0017b7          	lui	a5,0xc001
    80005c72:	6388                	ld	a0,0(a5)
    80005c74:	6422                	ld	s0,8(sp)
    80005c76:	0141                	addi	sp,sp,16
    80005c78:	8082                	ret

0000000080005c7a <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c7a:	1141                	addi	sp,sp,-16
    80005c7c:	e406                	sd	ra,8(sp)
    80005c7e:	e022                	sd	s0,0(sp)
    80005c80:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c82:	ffffc097          	auipc	ra,0xffffc
    80005c86:	b86080e7          	jalr	-1146(ra) # 80001808 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c8a:	00d5179b          	slliw	a5,a0,0xd
    80005c8e:	0c201537          	lui	a0,0xc201
    80005c92:	953e                	add	a0,a0,a5
  return irq;
}
    80005c94:	4148                	lw	a0,4(a0)
    80005c96:	60a2                	ld	ra,8(sp)
    80005c98:	6402                	ld	s0,0(sp)
    80005c9a:	0141                	addi	sp,sp,16
    80005c9c:	8082                	ret

0000000080005c9e <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c9e:	1101                	addi	sp,sp,-32
    80005ca0:	ec06                	sd	ra,24(sp)
    80005ca2:	e822                	sd	s0,16(sp)
    80005ca4:	e426                	sd	s1,8(sp)
    80005ca6:	1000                	addi	s0,sp,32
    80005ca8:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005caa:	ffffc097          	auipc	ra,0xffffc
    80005cae:	b5e080e7          	jalr	-1186(ra) # 80001808 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005cb2:	00d5151b          	slliw	a0,a0,0xd
    80005cb6:	0c2017b7          	lui	a5,0xc201
    80005cba:	97aa                	add	a5,a5,a0
    80005cbc:	c3c4                	sw	s1,4(a5)
}
    80005cbe:	60e2                	ld	ra,24(sp)
    80005cc0:	6442                	ld	s0,16(sp)
    80005cc2:	64a2                	ld	s1,8(sp)
    80005cc4:	6105                	addi	sp,sp,32
    80005cc6:	8082                	ret

0000000080005cc8 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80005cc8:	1141                	addi	sp,sp,-16
    80005cca:	e406                	sd	ra,8(sp)
    80005ccc:	e022                	sd	s0,0(sp)
    80005cce:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cd0:	479d                	li	a5,7
    80005cd2:	06b7c963          	blt	a5,a1,80005d44 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80005cd6:	00151793          	slli	a5,a0,0x1
    80005cda:	97aa                	add	a5,a5,a0
    80005cdc:	00c79713          	slli	a4,a5,0xc
    80005ce0:	0001d797          	auipc	a5,0x1d
    80005ce4:	32078793          	addi	a5,a5,800 # 80023000 <disk>
    80005ce8:	97ba                	add	a5,a5,a4
    80005cea:	97ae                	add	a5,a5,a1
    80005cec:	6709                	lui	a4,0x2
    80005cee:	97ba                	add	a5,a5,a4
    80005cf0:	0187c783          	lbu	a5,24(a5)
    80005cf4:	e3a5                	bnez	a5,80005d54 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80005cf6:	0001d817          	auipc	a6,0x1d
    80005cfa:	30a80813          	addi	a6,a6,778 # 80023000 <disk>
    80005cfe:	00151693          	slli	a3,a0,0x1
    80005d02:	00a68733          	add	a4,a3,a0
    80005d06:	0732                	slli	a4,a4,0xc
    80005d08:	00e807b3          	add	a5,a6,a4
    80005d0c:	6709                	lui	a4,0x2
    80005d0e:	00f70633          	add	a2,a4,a5
    80005d12:	6210                	ld	a2,0(a2)
    80005d14:	00459893          	slli	a7,a1,0x4
    80005d18:	9646                	add	a2,a2,a7
    80005d1a:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    80005d1e:	97ae                	add	a5,a5,a1
    80005d20:	97ba                	add	a5,a5,a4
    80005d22:	4605                	li	a2,1
    80005d24:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80005d28:	96aa                	add	a3,a3,a0
    80005d2a:	06b2                	slli	a3,a3,0xc
    80005d2c:	0761                	addi	a4,a4,24
    80005d2e:	96ba                	add	a3,a3,a4
    80005d30:	00d80533          	add	a0,a6,a3
    80005d34:	ffffc097          	auipc	ra,0xffffc
    80005d38:	452080e7          	jalr	1106(ra) # 80002186 <wakeup>
}
    80005d3c:	60a2                	ld	ra,8(sp)
    80005d3e:	6402                	ld	s0,0(sp)
    80005d40:	0141                	addi	sp,sp,16
    80005d42:	8082                	ret
    panic("virtio_disk_intr 1");
    80005d44:	00002517          	auipc	a0,0x2
    80005d48:	a9c50513          	addi	a0,a0,-1380 # 800077e0 <userret+0x750>
    80005d4c:	ffffb097          	auipc	ra,0xffffb
    80005d50:	802080e7          	jalr	-2046(ra) # 8000054e <panic>
    panic("virtio_disk_intr 2");
    80005d54:	00002517          	auipc	a0,0x2
    80005d58:	aa450513          	addi	a0,a0,-1372 # 800077f8 <userret+0x768>
    80005d5c:	ffffa097          	auipc	ra,0xffffa
    80005d60:	7f2080e7          	jalr	2034(ra) # 8000054e <panic>

0000000080005d64 <virtio_disk_init>:
  __sync_synchronize();
    80005d64:	0ff0000f          	fence
  if(disk[n].init)
    80005d68:	00151793          	slli	a5,a0,0x1
    80005d6c:	97aa                	add	a5,a5,a0
    80005d6e:	07b2                	slli	a5,a5,0xc
    80005d70:	0001d717          	auipc	a4,0x1d
    80005d74:	29070713          	addi	a4,a4,656 # 80023000 <disk>
    80005d78:	973e                	add	a4,a4,a5
    80005d7a:	6789                	lui	a5,0x2
    80005d7c:	97ba                	add	a5,a5,a4
    80005d7e:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    80005d82:	c391                	beqz	a5,80005d86 <virtio_disk_init+0x22>
    80005d84:	8082                	ret
{
    80005d86:	7139                	addi	sp,sp,-64
    80005d88:	fc06                	sd	ra,56(sp)
    80005d8a:	f822                	sd	s0,48(sp)
    80005d8c:	f426                	sd	s1,40(sp)
    80005d8e:	f04a                	sd	s2,32(sp)
    80005d90:	ec4e                	sd	s3,24(sp)
    80005d92:	e852                	sd	s4,16(sp)
    80005d94:	e456                	sd	s5,8(sp)
    80005d96:	0080                	addi	s0,sp,64
    80005d98:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    80005d9a:	85aa                	mv	a1,a0
    80005d9c:	00002517          	auipc	a0,0x2
    80005da0:	a7450513          	addi	a0,a0,-1420 # 80007810 <userret+0x780>
    80005da4:	ffffa097          	auipc	ra,0xffffa
    80005da8:	7f4080e7          	jalr	2036(ra) # 80000598 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    80005dac:	00149993          	slli	s3,s1,0x1
    80005db0:	99a6                	add	s3,s3,s1
    80005db2:	09b2                	slli	s3,s3,0xc
    80005db4:	6789                	lui	a5,0x2
    80005db6:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    80005dba:	97ce                	add	a5,a5,s3
    80005dbc:	00002597          	auipc	a1,0x2
    80005dc0:	a6c58593          	addi	a1,a1,-1428 # 80007828 <userret+0x798>
    80005dc4:	0001d517          	auipc	a0,0x1d
    80005dc8:	23c50513          	addi	a0,a0,572 # 80023000 <disk>
    80005dcc:	953e                	add	a0,a0,a5
    80005dce:	ffffb097          	auipc	ra,0xffffb
    80005dd2:	bf2080e7          	jalr	-1038(ra) # 800009c0 <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dd6:	0014891b          	addiw	s2,s1,1
    80005dda:	00c9191b          	slliw	s2,s2,0xc
    80005dde:	100007b7          	lui	a5,0x10000
    80005de2:	97ca                	add	a5,a5,s2
    80005de4:	4398                	lw	a4,0(a5)
    80005de6:	2701                	sext.w	a4,a4
    80005de8:	747277b7          	lui	a5,0x74727
    80005dec:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005df0:	12f71663          	bne	a4,a5,80005f1c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005df4:	100007b7          	lui	a5,0x10000
    80005df8:	0791                	addi	a5,a5,4
    80005dfa:	97ca                	add	a5,a5,s2
    80005dfc:	439c                	lw	a5,0(a5)
    80005dfe:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e00:	4705                	li	a4,1
    80005e02:	10e79d63          	bne	a5,a4,80005f1c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e06:	100007b7          	lui	a5,0x10000
    80005e0a:	07a1                	addi	a5,a5,8
    80005e0c:	97ca                	add	a5,a5,s2
    80005e0e:	439c                	lw	a5,0(a5)
    80005e10:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80005e12:	4709                	li	a4,2
    80005e14:	10e79463          	bne	a5,a4,80005f1c <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e18:	100007b7          	lui	a5,0x10000
    80005e1c:	07b1                	addi	a5,a5,12
    80005e1e:	97ca                	add	a5,a5,s2
    80005e20:	4398                	lw	a4,0(a5)
    80005e22:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e24:	554d47b7          	lui	a5,0x554d4
    80005e28:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e2c:	0ef71863          	bne	a4,a5,80005f1c <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005e30:	100007b7          	lui	a5,0x10000
    80005e34:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80005e38:	96ca                	add	a3,a3,s2
    80005e3a:	4705                	li	a4,1
    80005e3c:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005e3e:	470d                	li	a4,3
    80005e40:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80005e42:	01078713          	addi	a4,a5,16
    80005e46:	974a                	add	a4,a4,s2
    80005e48:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e4a:	02078613          	addi	a2,a5,32
    80005e4e:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e50:	c7ffe737          	lui	a4,0xc7ffe
    80005e54:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <ticks+0xffffffff47fd5737>
    80005e58:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e5a:	2701                	sext.w	a4,a4
    80005e5c:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005e5e:	472d                	li	a4,11
    80005e60:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    80005e62:	473d                	li	a4,15
    80005e64:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e66:	02878713          	addi	a4,a5,40
    80005e6a:	974a                	add	a4,a4,s2
    80005e6c:	6685                	lui	a3,0x1
    80005e6e:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e70:	03078713          	addi	a4,a5,48
    80005e74:	974a                	add	a4,a4,s2
    80005e76:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e7a:	03478793          	addi	a5,a5,52
    80005e7e:	97ca                	add	a5,a5,s2
    80005e80:	439c                	lw	a5,0(a5)
    80005e82:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e84:	c7c5                	beqz	a5,80005f2c <virtio_disk_init+0x1c8>
  if(max < NUM)
    80005e86:	471d                	li	a4,7
    80005e88:	0af77a63          	bgeu	a4,a5,80005f3c <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e8c:	10000ab7          	lui	s5,0x10000
    80005e90:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    80005e94:	97ca                	add	a5,a5,s2
    80005e96:	4721                	li	a4,8
    80005e98:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    80005e9a:	0001da17          	auipc	s4,0x1d
    80005e9e:	166a0a13          	addi	s4,s4,358 # 80023000 <disk>
    80005ea2:	99d2                	add	s3,s3,s4
    80005ea4:	6609                	lui	a2,0x2
    80005ea6:	4581                	li	a1,0
    80005ea8:	854e                	mv	a0,s3
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	cec080e7          	jalr	-788(ra) # 80000b96 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    80005eb2:	040a8a93          	addi	s5,s5,64
    80005eb6:	9956                	add	s2,s2,s5
    80005eb8:	00c9d793          	srli	a5,s3,0xc
    80005ebc:	2781                	sext.w	a5,a5
    80005ebe:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80005ec2:	00149513          	slli	a0,s1,0x1
    80005ec6:	009507b3          	add	a5,a0,s1
    80005eca:	07b2                	slli	a5,a5,0xc
    80005ecc:	97d2                	add	a5,a5,s4
    80005ece:	6689                	lui	a3,0x2
    80005ed0:	97b6                	add	a5,a5,a3
    80005ed2:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80005ed6:	08098713          	addi	a4,s3,128
    80005eda:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    80005edc:	6705                	lui	a4,0x1
    80005ede:	99ba                	add	s3,s3,a4
    80005ee0:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80005ee4:	4705                	li	a4,1
    80005ee6:	00e78c23          	sb	a4,24(a5)
    80005eea:	00e78ca3          	sb	a4,25(a5)
    80005eee:	00e78d23          	sb	a4,26(a5)
    80005ef2:	00e78da3          	sb	a4,27(a5)
    80005ef6:	00e78e23          	sb	a4,28(a5)
    80005efa:	00e78ea3          	sb	a4,29(a5)
    80005efe:	00e78f23          	sb	a4,30(a5)
    80005f02:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80005f06:	0ae7a423          	sw	a4,168(a5)
}
    80005f0a:	70e2                	ld	ra,56(sp)
    80005f0c:	7442                	ld	s0,48(sp)
    80005f0e:	74a2                	ld	s1,40(sp)
    80005f10:	7902                	ld	s2,32(sp)
    80005f12:	69e2                	ld	s3,24(sp)
    80005f14:	6a42                	ld	s4,16(sp)
    80005f16:	6aa2                	ld	s5,8(sp)
    80005f18:	6121                	addi	sp,sp,64
    80005f1a:	8082                	ret
    panic("could not find virtio disk");
    80005f1c:	00002517          	auipc	a0,0x2
    80005f20:	91c50513          	addi	a0,a0,-1764 # 80007838 <userret+0x7a8>
    80005f24:	ffffa097          	auipc	ra,0xffffa
    80005f28:	62a080e7          	jalr	1578(ra) # 8000054e <panic>
    panic("virtio disk has no queue 0");
    80005f2c:	00002517          	auipc	a0,0x2
    80005f30:	92c50513          	addi	a0,a0,-1748 # 80007858 <userret+0x7c8>
    80005f34:	ffffa097          	auipc	ra,0xffffa
    80005f38:	61a080e7          	jalr	1562(ra) # 8000054e <panic>
    panic("virtio disk max queue too short");
    80005f3c:	00002517          	auipc	a0,0x2
    80005f40:	93c50513          	addi	a0,a0,-1732 # 80007878 <userret+0x7e8>
    80005f44:	ffffa097          	auipc	ra,0xffffa
    80005f48:	60a080e7          	jalr	1546(ra) # 8000054e <panic>

0000000080005f4c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    80005f4c:	7135                	addi	sp,sp,-160
    80005f4e:	ed06                	sd	ra,152(sp)
    80005f50:	e922                	sd	s0,144(sp)
    80005f52:	e526                	sd	s1,136(sp)
    80005f54:	e14a                	sd	s2,128(sp)
    80005f56:	fcce                	sd	s3,120(sp)
    80005f58:	f8d2                	sd	s4,112(sp)
    80005f5a:	f4d6                	sd	s5,104(sp)
    80005f5c:	f0da                	sd	s6,96(sp)
    80005f5e:	ecde                	sd	s7,88(sp)
    80005f60:	e8e2                	sd	s8,80(sp)
    80005f62:	e4e6                	sd	s9,72(sp)
    80005f64:	e0ea                	sd	s10,64(sp)
    80005f66:	fc6e                	sd	s11,56(sp)
    80005f68:	1100                	addi	s0,sp,160
    80005f6a:	892a                	mv	s2,a0
    80005f6c:	89ae                	mv	s3,a1
    80005f6e:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f70:	45dc                	lw	a5,12(a1)
    80005f72:	0017979b          	slliw	a5,a5,0x1
    80005f76:	1782                	slli	a5,a5,0x20
    80005f78:	9381                	srli	a5,a5,0x20
    80005f7a:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    80005f7e:	00151493          	slli	s1,a0,0x1
    80005f82:	94aa                	add	s1,s1,a0
    80005f84:	04b2                	slli	s1,s1,0xc
    80005f86:	6a89                	lui	s5,0x2
    80005f88:	0b0a8a13          	addi	s4,s5,176 # 20b0 <_entry-0x7fffdf50>
    80005f8c:	9a26                	add	s4,s4,s1
    80005f8e:	0001db97          	auipc	s7,0x1d
    80005f92:	072b8b93          	addi	s7,s7,114 # 80023000 <disk>
    80005f96:	9a5e                	add	s4,s4,s7
    80005f98:	8552                	mv	a0,s4
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	b38080e7          	jalr	-1224(ra) # 80000ad2 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80005fa2:	0ae1                	addi	s5,s5,24
    80005fa4:	94d6                	add	s1,s1,s5
    80005fa6:	01748ab3          	add	s5,s1,s7
    80005faa:	8d56                	mv	s10,s5
  for(int i = 0; i < 3; i++){
    80005fac:	4b81                	li	s7,0
  for(int i = 0; i < NUM; i++){
    80005fae:	4ca1                	li	s9,8
      disk[n].free[i] = 0;
    80005fb0:	00191b13          	slli	s6,s2,0x1
    80005fb4:	9b4a                	add	s6,s6,s2
    80005fb6:	00cb1793          	slli	a5,s6,0xc
    80005fba:	0001db17          	auipc	s6,0x1d
    80005fbe:	046b0b13          	addi	s6,s6,70 # 80023000 <disk>
    80005fc2:	9b3e                	add	s6,s6,a5
  for(int i = 0; i < NUM; i++){
    80005fc4:	8c5e                	mv	s8,s7
    80005fc6:	a8ad                	j	80006040 <virtio_disk_rw+0xf4>
      disk[n].free[i] = 0;
    80005fc8:	00fb06b3          	add	a3,s6,a5
    80005fcc:	96aa                	add	a3,a3,a0
    80005fce:	00068c23          	sb	zero,24(a3) # 2018 <_entry-0x7fffdfe8>
    idx[i] = alloc_desc(n);
    80005fd2:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80005fd4:	0207c363          	bltz	a5,80005ffa <virtio_disk_rw+0xae>
  for(int i = 0; i < 3; i++){
    80005fd8:	2485                	addiw	s1,s1,1
    80005fda:	0711                	addi	a4,a4,4
    80005fdc:	1eb48363          	beq	s1,a1,800061c2 <virtio_disk_rw+0x276>
    idx[i] = alloc_desc(n);
    80005fe0:	863a                	mv	a2,a4
    80005fe2:	86ea                	mv	a3,s10
  for(int i = 0; i < NUM; i++){
    80005fe4:	87e2                	mv	a5,s8
    if(disk[n].free[i]){
    80005fe6:	0006c803          	lbu	a6,0(a3)
    80005fea:	fc081fe3          	bnez	a6,80005fc8 <virtio_disk_rw+0x7c>
  for(int i = 0; i < NUM; i++){
    80005fee:	2785                	addiw	a5,a5,1
    80005ff0:	0685                	addi	a3,a3,1
    80005ff2:	ff979ae3          	bne	a5,s9,80005fe6 <virtio_disk_rw+0x9a>
    idx[i] = alloc_desc(n);
    80005ff6:	57fd                	li	a5,-1
    80005ff8:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80005ffa:	02905d63          	blez	s1,80006034 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80005ffe:	f8042583          	lw	a1,-128(s0)
    80006002:	854a                	mv	a0,s2
    80006004:	00000097          	auipc	ra,0x0
    80006008:	cc4080e7          	jalr	-828(ra) # 80005cc8 <free_desc>
      for(int j = 0; j < i; j++)
    8000600c:	4785                	li	a5,1
    8000600e:	0297d363          	bge	a5,s1,80006034 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006012:	f8442583          	lw	a1,-124(s0)
    80006016:	854a                	mv	a0,s2
    80006018:	00000097          	auipc	ra,0x0
    8000601c:	cb0080e7          	jalr	-848(ra) # 80005cc8 <free_desc>
      for(int j = 0; j < i; j++)
    80006020:	4789                	li	a5,2
    80006022:	0097d963          	bge	a5,s1,80006034 <virtio_disk_rw+0xe8>
        free_desc(n, idx[j]);
    80006026:	f8842583          	lw	a1,-120(s0)
    8000602a:	854a                	mv	a0,s2
    8000602c:	00000097          	auipc	ra,0x0
    80006030:	c9c080e7          	jalr	-868(ra) # 80005cc8 <free_desc>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    80006034:	85d2                	mv	a1,s4
    80006036:	8556                	mv	a0,s5
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	002080e7          	jalr	2(ra) # 8000203a <sleep>
  for(int i = 0; i < 3; i++){
    80006040:	f8040713          	addi	a4,s0,-128
    80006044:	84de                	mv	s1,s7
      disk[n].free[i] = 0;
    80006046:	6509                	lui	a0,0x2
  for(int i = 0; i < 3; i++){
    80006048:	458d                	li	a1,3
    8000604a:	bf59                	j	80005fe0 <virtio_disk_rw+0x94>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    8000604c:	00191793          	slli	a5,s2,0x1
    80006050:	97ca                	add	a5,a5,s2
    80006052:	07b2                	slli	a5,a5,0xc
    80006054:	0001d717          	auipc	a4,0x1d
    80006058:	fac70713          	addi	a4,a4,-84 # 80023000 <disk>
    8000605c:	973e                	add	a4,a4,a5
    8000605e:	6789                	lui	a5,0x2
    80006060:	97ba                	add	a5,a5,a4
    80006062:	639c                	ld	a5,0(a5)
    80006064:	97b6                	add	a5,a5,a3
    80006066:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000606a:	0001d517          	auipc	a0,0x1d
    8000606e:	f9650513          	addi	a0,a0,-106 # 80023000 <disk>
    80006072:	00191793          	slli	a5,s2,0x1
    80006076:	01278733          	add	a4,a5,s2
    8000607a:	0732                	slli	a4,a4,0xc
    8000607c:	972a                	add	a4,a4,a0
    8000607e:	6609                	lui	a2,0x2
    80006080:	9732                	add	a4,a4,a2
    80006082:	630c                	ld	a1,0(a4)
    80006084:	95b6                	add	a1,a1,a3
    80006086:	00c5d603          	lhu	a2,12(a1)
    8000608a:	00166613          	ori	a2,a2,1
    8000608e:	00c59623          	sh	a2,12(a1)
  disk[n].desc[idx[1]].next = idx[2];
    80006092:	f8842603          	lw	a2,-120(s0)
    80006096:	630c                	ld	a1,0(a4)
    80006098:	96ae                	add	a3,a3,a1
    8000609a:	00c69723          	sh	a2,14(a3)

  disk[n].info[idx[0]].status = 0;
    8000609e:	97ca                	add	a5,a5,s2
    800060a0:	07a2                	slli	a5,a5,0x8
    800060a2:	97a6                	add	a5,a5,s1
    800060a4:	20078793          	addi	a5,a5,512
    800060a8:	0792                	slli	a5,a5,0x4
    800060aa:	97aa                	add	a5,a5,a0
    800060ac:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800060b0:	00461693          	slli	a3,a2,0x4
    800060b4:	00073803          	ld	a6,0(a4)
    800060b8:	9836                	add	a6,a6,a3
    800060ba:	20348613          	addi	a2,s1,515
    800060be:	00191593          	slli	a1,s2,0x1
    800060c2:	95ca                	add	a1,a1,s2
    800060c4:	05a2                	slli	a1,a1,0x8
    800060c6:	962e                	add	a2,a2,a1
    800060c8:	0612                	slli	a2,a2,0x4
    800060ca:	962a                	add	a2,a2,a0
    800060cc:	00c83023          	sd	a2,0(a6)
  disk[n].desc[idx[2]].len = 1;
    800060d0:	630c                	ld	a1,0(a4)
    800060d2:	95b6                	add	a1,a1,a3
    800060d4:	4605                	li	a2,1
    800060d6:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060d8:	630c                	ld	a1,0(a4)
    800060da:	95b6                	add	a1,a1,a3
    800060dc:	4509                	li	a0,2
    800060de:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    800060e2:	630c                	ld	a1,0(a4)
    800060e4:	96ae                	add	a3,a3,a1
    800060e6:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060ea:	00c9a223          	sw	a2,4(s3)
  disk[n].info[idx[0]].b = b;
    800060ee:	0337b423          	sd	s3,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    800060f2:	6714                	ld	a3,8(a4)
    800060f4:	0026d783          	lhu	a5,2(a3)
    800060f8:	8b9d                	andi	a5,a5,7
    800060fa:	2789                	addiw	a5,a5,2
    800060fc:	0786                	slli	a5,a5,0x1
    800060fe:	97b6                	add	a5,a5,a3
    80006100:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    80006104:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006108:	6718                	ld	a4,8(a4)
    8000610a:	00275783          	lhu	a5,2(a4)
    8000610e:	2785                	addiw	a5,a5,1
    80006110:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006114:	0019079b          	addiw	a5,s2,1
    80006118:	00c7979b          	slliw	a5,a5,0xc
    8000611c:	10000737          	lui	a4,0x10000
    80006120:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    80006124:	97ba                	add	a5,a5,a4
    80006126:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000612a:	0049a783          	lw	a5,4(s3)
    8000612e:	00c79d63          	bne	a5,a2,80006148 <virtio_disk_rw+0x1fc>
    80006132:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    80006134:	85d2                	mv	a1,s4
    80006136:	854e                	mv	a0,s3
    80006138:	ffffc097          	auipc	ra,0xffffc
    8000613c:	f02080e7          	jalr	-254(ra) # 8000203a <sleep>
  while(b->disk == 1) {
    80006140:	0049a783          	lw	a5,4(s3)
    80006144:	fe9788e3          	beq	a5,s1,80006134 <virtio_disk_rw+0x1e8>
  }

  disk[n].info[idx[0]].b = 0;
    80006148:	f8042483          	lw	s1,-128(s0)
    8000614c:	00191793          	slli	a5,s2,0x1
    80006150:	97ca                	add	a5,a5,s2
    80006152:	07a2                	slli	a5,a5,0x8
    80006154:	97a6                	add	a5,a5,s1
    80006156:	20078793          	addi	a5,a5,512
    8000615a:	0792                	slli	a5,a5,0x4
    8000615c:	0001d717          	auipc	a4,0x1d
    80006160:	ea470713          	addi	a4,a4,-348 # 80023000 <disk>
    80006164:	97ba                	add	a5,a5,a4
    80006166:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    8000616a:	00191793          	slli	a5,s2,0x1
    8000616e:	97ca                	add	a5,a5,s2
    80006170:	07b2                	slli	a5,a5,0xc
    80006172:	97ba                	add	a5,a5,a4
    80006174:	6989                	lui	s3,0x2
    80006176:	99be                	add	s3,s3,a5
    free_desc(n, i);
    80006178:	85a6                	mv	a1,s1
    8000617a:	854a                	mv	a0,s2
    8000617c:	00000097          	auipc	ra,0x0
    80006180:	b4c080e7          	jalr	-1204(ra) # 80005cc8 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006184:	0492                	slli	s1,s1,0x4
    80006186:	0009b783          	ld	a5,0(s3) # 2000 <_entry-0x7fffe000>
    8000618a:	94be                	add	s1,s1,a5
    8000618c:	00c4d783          	lhu	a5,12(s1)
    80006190:	8b85                	andi	a5,a5,1
    80006192:	c781                	beqz	a5,8000619a <virtio_disk_rw+0x24e>
      i = disk[n].desc[i].next;
    80006194:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006198:	b7c5                	j	80006178 <virtio_disk_rw+0x22c>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    8000619a:	8552                	mv	a0,s4
    8000619c:	ffffb097          	auipc	ra,0xffffb
    800061a0:	99e080e7          	jalr	-1634(ra) # 80000b3a <release>
}
    800061a4:	60ea                	ld	ra,152(sp)
    800061a6:	644a                	ld	s0,144(sp)
    800061a8:	64aa                	ld	s1,136(sp)
    800061aa:	690a                	ld	s2,128(sp)
    800061ac:	79e6                	ld	s3,120(sp)
    800061ae:	7a46                	ld	s4,112(sp)
    800061b0:	7aa6                	ld	s5,104(sp)
    800061b2:	7b06                	ld	s6,96(sp)
    800061b4:	6be6                	ld	s7,88(sp)
    800061b6:	6c46                	ld	s8,80(sp)
    800061b8:	6ca6                	ld	s9,72(sp)
    800061ba:	6d06                	ld	s10,64(sp)
    800061bc:	7de2                	ld	s11,56(sp)
    800061be:	610d                	addi	sp,sp,160
    800061c0:	8082                	ret
  if(write)
    800061c2:	01b037b3          	snez	a5,s11
    800061c6:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800061ca:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800061ce:	f6843783          	ld	a5,-152(s0)
    800061d2:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800061d6:	f8042483          	lw	s1,-128(s0)
    800061da:	00449b13          	slli	s6,s1,0x4
    800061de:	00191793          	slli	a5,s2,0x1
    800061e2:	97ca                	add	a5,a5,s2
    800061e4:	07b2                	slli	a5,a5,0xc
    800061e6:	0001da97          	auipc	s5,0x1d
    800061ea:	e1aa8a93          	addi	s5,s5,-486 # 80023000 <disk>
    800061ee:	97d6                	add	a5,a5,s5
    800061f0:	6a89                	lui	s5,0x2
    800061f2:	9abe                	add	s5,s5,a5
    800061f4:	000abb83          	ld	s7,0(s5) # 2000 <_entry-0x7fffe000>
    800061f8:	9bda                	add	s7,s7,s6
    800061fa:	f7040513          	addi	a0,s0,-144
    800061fe:	ffffb097          	auipc	ra,0xffffb
    80006202:	dcc080e7          	jalr	-564(ra) # 80000fca <kvmpa>
    80006206:	00abb023          	sd	a0,0(s7)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    8000620a:	000ab783          	ld	a5,0(s5)
    8000620e:	97da                	add	a5,a5,s6
    80006210:	4741                	li	a4,16
    80006212:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006214:	000ab783          	ld	a5,0(s5)
    80006218:	97da                	add	a5,a5,s6
    8000621a:	4705                	li	a4,1
    8000621c:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006220:	f8442683          	lw	a3,-124(s0)
    80006224:	000ab783          	ld	a5,0(s5)
    80006228:	9b3e                	add	s6,s6,a5
    8000622a:	00db1723          	sh	a3,14(s6)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    8000622e:	0692                	slli	a3,a3,0x4
    80006230:	000ab783          	ld	a5,0(s5)
    80006234:	97b6                	add	a5,a5,a3
    80006236:	06098713          	addi	a4,s3,96
    8000623a:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    8000623c:	000ab783          	ld	a5,0(s5)
    80006240:	97b6                	add	a5,a5,a3
    80006242:	40000713          	li	a4,1024
    80006246:	c798                	sw	a4,8(a5)
  if(write)
    80006248:	e00d92e3          	bnez	s11,8000604c <virtio_disk_rw+0x100>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000624c:	00191793          	slli	a5,s2,0x1
    80006250:	97ca                	add	a5,a5,s2
    80006252:	07b2                	slli	a5,a5,0xc
    80006254:	0001d717          	auipc	a4,0x1d
    80006258:	dac70713          	addi	a4,a4,-596 # 80023000 <disk>
    8000625c:	973e                	add	a4,a4,a5
    8000625e:	6789                	lui	a5,0x2
    80006260:	97ba                	add	a5,a5,a4
    80006262:	639c                	ld	a5,0(a5)
    80006264:	97b6                	add	a5,a5,a3
    80006266:	4709                	li	a4,2
    80006268:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    8000626c:	bbfd                	j	8000606a <virtio_disk_rw+0x11e>

000000008000626e <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    8000626e:	7139                	addi	sp,sp,-64
    80006270:	fc06                	sd	ra,56(sp)
    80006272:	f822                	sd	s0,48(sp)
    80006274:	f426                	sd	s1,40(sp)
    80006276:	f04a                	sd	s2,32(sp)
    80006278:	ec4e                	sd	s3,24(sp)
    8000627a:	e852                	sd	s4,16(sp)
    8000627c:	e456                	sd	s5,8(sp)
    8000627e:	0080                	addi	s0,sp,64
    80006280:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    80006282:	00151913          	slli	s2,a0,0x1
    80006286:	00a90a33          	add	s4,s2,a0
    8000628a:	0a32                	slli	s4,s4,0xc
    8000628c:	6989                	lui	s3,0x2
    8000628e:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    80006292:	9a3e                	add	s4,s4,a5
    80006294:	0001da97          	auipc	s5,0x1d
    80006298:	d6ca8a93          	addi	s5,s5,-660 # 80023000 <disk>
    8000629c:	9a56                	add	s4,s4,s5
    8000629e:	8552                	mv	a0,s4
    800062a0:	ffffb097          	auipc	ra,0xffffb
    800062a4:	832080e7          	jalr	-1998(ra) # 80000ad2 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800062a8:	9926                	add	s2,s2,s1
    800062aa:	0932                	slli	s2,s2,0xc
    800062ac:	9956                	add	s2,s2,s5
    800062ae:	99ca                	add	s3,s3,s2
    800062b0:	0209d783          	lhu	a5,32(s3)
    800062b4:	0109b703          	ld	a4,16(s3)
    800062b8:	00275683          	lhu	a3,2(a4)
    800062bc:	8ebd                	xor	a3,a3,a5
    800062be:	8a9d                	andi	a3,a3,7
    800062c0:	c2a5                	beqz	a3,80006320 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    800062c2:	8956                	mv	s2,s5
    800062c4:	00149693          	slli	a3,s1,0x1
    800062c8:	96a6                	add	a3,a3,s1
    800062ca:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800062ce:	06b2                	slli	a3,a3,0xc
    800062d0:	96d6                	add	a3,a3,s5
    800062d2:	6489                	lui	s1,0x2
    800062d4:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    800062d6:	078e                	slli	a5,a5,0x3
    800062d8:	97ba                	add	a5,a5,a4
    800062da:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    800062dc:	00f98733          	add	a4,s3,a5
    800062e0:	20070713          	addi	a4,a4,512
    800062e4:	0712                	slli	a4,a4,0x4
    800062e6:	974a                	add	a4,a4,s2
    800062e8:	03074703          	lbu	a4,48(a4)
    800062ec:	eb21                	bnez	a4,8000633c <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    800062ee:	97ce                	add	a5,a5,s3
    800062f0:	20078793          	addi	a5,a5,512
    800062f4:	0792                	slli	a5,a5,0x4
    800062f6:	97ca                	add	a5,a5,s2
    800062f8:	7798                	ld	a4,40(a5)
    800062fa:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    800062fe:	7788                	ld	a0,40(a5)
    80006300:	ffffc097          	auipc	ra,0xffffc
    80006304:	e86080e7          	jalr	-378(ra) # 80002186 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006308:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    8000630c:	2785                	addiw	a5,a5,1
    8000630e:	8b9d                	andi	a5,a5,7
    80006310:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    80006314:	6898                	ld	a4,16(s1)
    80006316:	00275683          	lhu	a3,2(a4)
    8000631a:	8a9d                	andi	a3,a3,7
    8000631c:	faf69de3          	bne	a3,a5,800062d6 <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006320:	8552                	mv	a0,s4
    80006322:	ffffb097          	auipc	ra,0xffffb
    80006326:	818080e7          	jalr	-2024(ra) # 80000b3a <release>
}
    8000632a:	70e2                	ld	ra,56(sp)
    8000632c:	7442                	ld	s0,48(sp)
    8000632e:	74a2                	ld	s1,40(sp)
    80006330:	7902                	ld	s2,32(sp)
    80006332:	69e2                	ld	s3,24(sp)
    80006334:	6a42                	ld	s4,16(sp)
    80006336:	6aa2                	ld	s5,8(sp)
    80006338:	6121                	addi	sp,sp,64
    8000633a:	8082                	ret
      panic("virtio_disk_intr status");
    8000633c:	00001517          	auipc	a0,0x1
    80006340:	55c50513          	addi	a0,a0,1372 # 80007898 <userret+0x808>
    80006344:	ffffa097          	auipc	ra,0xffffa
    80006348:	20a080e7          	jalr	522(ra) # 8000054e <panic>
	...

0000000080007000 <trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
