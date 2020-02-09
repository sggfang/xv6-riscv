
user/_call:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <g>:
#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  return x+3;
}
   6:	250d                	addiw	a0,a0,3
   8:	6422                	ld	s0,8(sp)
   a:	0141                	addi	sp,sp,16
   c:	8082                	ret

000000000000000e <f>:

int f(int x) {
   e:	1141                	addi	sp,sp,-16
  10:	e422                	sd	s0,8(sp)
  12:	0800                	addi	s0,sp,16
  return g(x);
}
  14:	250d                	addiw	a0,a0,3
  16:	6422                	ld	s0,8(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret

000000000000001c <main>:

void main(void) {
  1c:	1141                	addi	sp,sp,-16
  1e:	e406                	sd	ra,8(sp)
  20:	e022                	sd	s0,0(sp)
  22:	0800                	addi	s0,sp,16
  printf("%d %d\n", f(8)+1, 13);
  24:	4635                	li	a2,13
  26:	45b1                	li	a1,12
  28:	00000517          	auipc	a0,0x0
  2c:	74850513          	addi	a0,a0,1864 # 770 <malloc+0xe4>
  30:	00000097          	auipc	ra,0x0
  34:	59e080e7          	jalr	1438(ra) # 5ce <printf>
  exit();
  38:	00000097          	auipc	ra,0x0
  3c:	1fe080e7          	jalr	510(ra) # 236 <exit>

0000000000000040 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  40:	1141                	addi	sp,sp,-16
  42:	e422                	sd	s0,8(sp)
  44:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  46:	87aa                	mv	a5,a0
  48:	0585                	addi	a1,a1,1
  4a:	0785                	addi	a5,a5,1
  4c:	fff5c703          	lbu	a4,-1(a1)
  50:	fee78fa3          	sb	a4,-1(a5)
  54:	fb75                	bnez	a4,48 <strcpy+0x8>
    ;
  return os;
}
  56:	6422                	ld	s0,8(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret

000000000000005c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5c:	1141                	addi	sp,sp,-16
  5e:	e422                	sd	s0,8(sp)
  60:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  62:	00054783          	lbu	a5,0(a0)
  66:	cb91                	beqz	a5,7a <strcmp+0x1e>
  68:	0005c703          	lbu	a4,0(a1)
  6c:	00f71763          	bne	a4,a5,7a <strcmp+0x1e>
    p++, q++;
  70:	0505                	addi	a0,a0,1
  72:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  74:	00054783          	lbu	a5,0(a0)
  78:	fbe5                	bnez	a5,68 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7a:	0005c503          	lbu	a0,0(a1)
}
  7e:	40a7853b          	subw	a0,a5,a0
  82:	6422                	ld	s0,8(sp)
  84:	0141                	addi	sp,sp,16
  86:	8082                	ret

0000000000000088 <strlen>:

uint
strlen(const char *s)
{
  88:	1141                	addi	sp,sp,-16
  8a:	e422                	sd	s0,8(sp)
  8c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  8e:	00054783          	lbu	a5,0(a0)
  92:	cf91                	beqz	a5,ae <strlen+0x26>
  94:	0505                	addi	a0,a0,1
  96:	87aa                	mv	a5,a0
  98:	4685                	li	a3,1
  9a:	9e89                	subw	a3,a3,a0
  9c:	00f6853b          	addw	a0,a3,a5
  a0:	0785                	addi	a5,a5,1
  a2:	fff7c703          	lbu	a4,-1(a5)
  a6:	fb7d                	bnez	a4,9c <strlen+0x14>
    ;
  return n;
}
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret
  for(n = 0; s[n]; n++)
  ae:	4501                	li	a0,0
  b0:	bfe5                	j	a8 <strlen+0x20>

00000000000000b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b2:	1141                	addi	sp,sp,-16
  b4:	e422                	sd	s0,8(sp)
  b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  b8:	ce09                	beqz	a2,d2 <memset+0x20>
  ba:	87aa                	mv	a5,a0
  bc:	fff6071b          	addiw	a4,a2,-1
  c0:	1702                	slli	a4,a4,0x20
  c2:	9301                	srli	a4,a4,0x20
  c4:	0705                	addi	a4,a4,1
  c6:	972a                	add	a4,a4,a0
    cdst[i] = c;
  c8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  cc:	0785                	addi	a5,a5,1
  ce:	fee79de3          	bne	a5,a4,c8 <memset+0x16>
  }
  return dst;
}
  d2:	6422                	ld	s0,8(sp)
  d4:	0141                	addi	sp,sp,16
  d6:	8082                	ret

00000000000000d8 <strchr>:

char*
strchr(const char *s, char c)
{
  d8:	1141                	addi	sp,sp,-16
  da:	e422                	sd	s0,8(sp)
  dc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  de:	00054783          	lbu	a5,0(a0)
  e2:	cb99                	beqz	a5,f8 <strchr+0x20>
    if(*s == c)
  e4:	00f58763          	beq	a1,a5,f2 <strchr+0x1a>
  for(; *s; s++)
  e8:	0505                	addi	a0,a0,1
  ea:	00054783          	lbu	a5,0(a0)
  ee:	fbfd                	bnez	a5,e4 <strchr+0xc>
      return (char*)s;
  return 0;
  f0:	4501                	li	a0,0
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret
  return 0;
  f8:	4501                	li	a0,0
  fa:	bfe5                	j	f2 <strchr+0x1a>

00000000000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	711d                	addi	sp,sp,-96
  fe:	ec86                	sd	ra,88(sp)
 100:	e8a2                	sd	s0,80(sp)
 102:	e4a6                	sd	s1,72(sp)
 104:	e0ca                	sd	s2,64(sp)
 106:	fc4e                	sd	s3,56(sp)
 108:	f852                	sd	s4,48(sp)
 10a:	f456                	sd	s5,40(sp)
 10c:	f05a                	sd	s6,32(sp)
 10e:	ec5e                	sd	s7,24(sp)
 110:	1080                	addi	s0,sp,96
 112:	8baa                	mv	s7,a0
 114:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 116:	892a                	mv	s2,a0
 118:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11a:	4aa9                	li	s5,10
 11c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11e:	89a6                	mv	s3,s1
 120:	2485                	addiw	s1,s1,1
 122:	0344d863          	bge	s1,s4,152 <gets+0x56>
    cc = read(0, &c, 1);
 126:	4605                	li	a2,1
 128:	faf40593          	addi	a1,s0,-81
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	120080e7          	jalr	288(ra) # 24e <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x56>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x54>
 146:	0905                	addi	s2,s2,1
 148:	fd679be3          	bne	a5,s6,11e <gets+0x22>
  for(i=0; i+1 < max; ){
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x56>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e426                	sd	s1,8(sp)
 178:	e04a                	sd	s2,0(sp)
 17a:	1000                	addi	s0,sp,32
 17c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17e:	4581                	li	a1,0
 180:	00000097          	auipc	ra,0x0
 184:	0f6080e7          	jalr	246(ra) # 276 <open>
  if(fd < 0)
 188:	02054563          	bltz	a0,1b2 <stat+0x42>
 18c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18e:	85ca                	mv	a1,s2
 190:	00000097          	auipc	ra,0x0
 194:	0fe080e7          	jalr	254(ra) # 28e <fstat>
 198:	892a                	mv	s2,a0
  close(fd);
 19a:	8526                	mv	a0,s1
 19c:	00000097          	auipc	ra,0x0
 1a0:	0c2080e7          	jalr	194(ra) # 25e <close>
  return r;
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	64a2                	ld	s1,8(sp)
 1ac:	6902                	ld	s2,0(sp)
 1ae:	6105                	addi	sp,sp,32
 1b0:	8082                	ret
    return -1;
 1b2:	597d                	li	s2,-1
 1b4:	bfc5                	j	1a4 <stat+0x34>

00000000000001b6 <atoi>:

int
atoi(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1bc:	00054603          	lbu	a2,0(a0)
 1c0:	fd06079b          	addiw	a5,a2,-48
 1c4:	0ff7f793          	andi	a5,a5,255
 1c8:	4725                	li	a4,9
 1ca:	02f76963          	bltu	a4,a5,1fc <atoi+0x46>
 1ce:	86aa                	mv	a3,a0
  n = 0;
 1d0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1d2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1d4:	0685                	addi	a3,a3,1
 1d6:	0025179b          	slliw	a5,a0,0x2
 1da:	9fa9                	addw	a5,a5,a0
 1dc:	0017979b          	slliw	a5,a5,0x1
 1e0:	9fb1                	addw	a5,a5,a2
 1e2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e6:	0006c603          	lbu	a2,0(a3)
 1ea:	fd06071b          	addiw	a4,a2,-48
 1ee:	0ff77713          	andi	a4,a4,255
 1f2:	fee5f1e3          	bgeu	a1,a4,1d4 <atoi+0x1e>
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  n = 0;
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <atoi+0x40>

0000000000000200 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 206:	02c05163          	blez	a2,228 <memmove+0x28>
 20a:	fff6071b          	addiw	a4,a2,-1
 20e:	1702                	slli	a4,a4,0x20
 210:	9301                	srli	a4,a4,0x20
 212:	0705                	addi	a4,a4,1
 214:	972a                	add	a4,a4,a0
  dst = vdst;
 216:	87aa                	mv	a5,a0
    *dst++ = *src++;
 218:	0585                	addi	a1,a1,1
 21a:	0785                	addi	a5,a5,1
 21c:	fff5c683          	lbu	a3,-1(a1)
 220:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 224:	fee79ae3          	bne	a5,a4,218 <memmove+0x18>
  return vdst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 22e:	4885                	li	a7,1
 ecall
 230:	00000073          	ecall
 ret
 234:	8082                	ret

0000000000000236 <exit>:
.global exit
exit:
 li a7, SYS_exit
 236:	4889                	li	a7,2
 ecall
 238:	00000073          	ecall
 ret
 23c:	8082                	ret

000000000000023e <wait>:
.global wait
wait:
 li a7, SYS_wait
 23e:	488d                	li	a7,3
 ecall
 240:	00000073          	ecall
 ret
 244:	8082                	ret

0000000000000246 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 246:	4891                	li	a7,4
 ecall
 248:	00000073          	ecall
 ret
 24c:	8082                	ret

000000000000024e <read>:
.global read
read:
 li a7, SYS_read
 24e:	4895                	li	a7,5
 ecall
 250:	00000073          	ecall
 ret
 254:	8082                	ret

0000000000000256 <write>:
.global write
write:
 li a7, SYS_write
 256:	48c1                	li	a7,16
 ecall
 258:	00000073          	ecall
 ret
 25c:	8082                	ret

000000000000025e <close>:
.global close
close:
 li a7, SYS_close
 25e:	48d5                	li	a7,21
 ecall
 260:	00000073          	ecall
 ret
 264:	8082                	ret

0000000000000266 <kill>:
.global kill
kill:
 li a7, SYS_kill
 266:	4899                	li	a7,6
 ecall
 268:	00000073          	ecall
 ret
 26c:	8082                	ret

000000000000026e <exec>:
.global exec
exec:
 li a7, SYS_exec
 26e:	489d                	li	a7,7
 ecall
 270:	00000073          	ecall
 ret
 274:	8082                	ret

0000000000000276 <open>:
.global open
open:
 li a7, SYS_open
 276:	48bd                	li	a7,15
 ecall
 278:	00000073          	ecall
 ret
 27c:	8082                	ret

000000000000027e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 27e:	48c5                	li	a7,17
 ecall
 280:	00000073          	ecall
 ret
 284:	8082                	ret

0000000000000286 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 286:	48c9                	li	a7,18
 ecall
 288:	00000073          	ecall
 ret
 28c:	8082                	ret

000000000000028e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 28e:	48a1                	li	a7,8
 ecall
 290:	00000073          	ecall
 ret
 294:	8082                	ret

0000000000000296 <link>:
.global link
link:
 li a7, SYS_link
 296:	48cd                	li	a7,19
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 29e:	48d1                	li	a7,20
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2a6:	48a5                	li	a7,9
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <dup>:
.global dup
dup:
 li a7, SYS_dup
 2ae:	48a9                	li	a7,10
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2b6:	48ad                	li	a7,11
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2be:	48b1                	li	a7,12
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2c6:	48b5                	li	a7,13
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2ce:	48b9                	li	a7,14
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 2d6:	48d9                	li	a7,22
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <crash>:
.global crash
crash:
 li a7, SYS_crash
 2de:	48dd                	li	a7,23
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <mount>:
.global mount
mount:
 li a7, SYS_mount
 2e6:	48e1                	li	a7,24
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <umount>:
.global umount
umount:
 li a7, SYS_umount
 2ee:	48e5                	li	a7,25
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 2f6:	1101                	addi	sp,sp,-32
 2f8:	ec06                	sd	ra,24(sp)
 2fa:	e822                	sd	s0,16(sp)
 2fc:	1000                	addi	s0,sp,32
 2fe:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 302:	4605                	li	a2,1
 304:	fef40593          	addi	a1,s0,-17
 308:	00000097          	auipc	ra,0x0
 30c:	f4e080e7          	jalr	-178(ra) # 256 <write>
}
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	6105                	addi	sp,sp,32
 316:	8082                	ret

0000000000000318 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 318:	7139                	addi	sp,sp,-64
 31a:	fc06                	sd	ra,56(sp)
 31c:	f822                	sd	s0,48(sp)
 31e:	f426                	sd	s1,40(sp)
 320:	f04a                	sd	s2,32(sp)
 322:	ec4e                	sd	s3,24(sp)
 324:	0080                	addi	s0,sp,64
 326:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 328:	c299                	beqz	a3,32e <printint+0x16>
 32a:	0805c863          	bltz	a1,3ba <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 32e:	2581                	sext.w	a1,a1
  neg = 0;
 330:	4881                	li	a7,0
 332:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 336:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 338:	2601                	sext.w	a2,a2
 33a:	00000517          	auipc	a0,0x0
 33e:	44650513          	addi	a0,a0,1094 # 780 <digits>
 342:	883a                	mv	a6,a4
 344:	2705                	addiw	a4,a4,1
 346:	02c5f7bb          	remuw	a5,a1,a2
 34a:	1782                	slli	a5,a5,0x20
 34c:	9381                	srli	a5,a5,0x20
 34e:	97aa                	add	a5,a5,a0
 350:	0007c783          	lbu	a5,0(a5)
 354:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 358:	0005879b          	sext.w	a5,a1
 35c:	02c5d5bb          	divuw	a1,a1,a2
 360:	0685                	addi	a3,a3,1
 362:	fec7f0e3          	bgeu	a5,a2,342 <printint+0x2a>
  if(neg)
 366:	00088b63          	beqz	a7,37c <printint+0x64>
    buf[i++] = '-';
 36a:	fd040793          	addi	a5,s0,-48
 36e:	973e                	add	a4,a4,a5
 370:	02d00793          	li	a5,45
 374:	fef70823          	sb	a5,-16(a4)
 378:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 37c:	02e05863          	blez	a4,3ac <printint+0x94>
 380:	fc040793          	addi	a5,s0,-64
 384:	00e78933          	add	s2,a5,a4
 388:	fff78993          	addi	s3,a5,-1
 38c:	99ba                	add	s3,s3,a4
 38e:	377d                	addiw	a4,a4,-1
 390:	1702                	slli	a4,a4,0x20
 392:	9301                	srli	a4,a4,0x20
 394:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 398:	fff94583          	lbu	a1,-1(s2)
 39c:	8526                	mv	a0,s1
 39e:	00000097          	auipc	ra,0x0
 3a2:	f58080e7          	jalr	-168(ra) # 2f6 <putc>
  while(--i >= 0)
 3a6:	197d                	addi	s2,s2,-1
 3a8:	ff3918e3          	bne	s2,s3,398 <printint+0x80>
}
 3ac:	70e2                	ld	ra,56(sp)
 3ae:	7442                	ld	s0,48(sp)
 3b0:	74a2                	ld	s1,40(sp)
 3b2:	7902                	ld	s2,32(sp)
 3b4:	69e2                	ld	s3,24(sp)
 3b6:	6121                	addi	sp,sp,64
 3b8:	8082                	ret
    x = -xx;
 3ba:	40b005bb          	negw	a1,a1
    neg = 1;
 3be:	4885                	li	a7,1
    x = -xx;
 3c0:	bf8d                	j	332 <printint+0x1a>

00000000000003c2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3c2:	7119                	addi	sp,sp,-128
 3c4:	fc86                	sd	ra,120(sp)
 3c6:	f8a2                	sd	s0,112(sp)
 3c8:	f4a6                	sd	s1,104(sp)
 3ca:	f0ca                	sd	s2,96(sp)
 3cc:	ecce                	sd	s3,88(sp)
 3ce:	e8d2                	sd	s4,80(sp)
 3d0:	e4d6                	sd	s5,72(sp)
 3d2:	e0da                	sd	s6,64(sp)
 3d4:	fc5e                	sd	s7,56(sp)
 3d6:	f862                	sd	s8,48(sp)
 3d8:	f466                	sd	s9,40(sp)
 3da:	f06a                	sd	s10,32(sp)
 3dc:	ec6e                	sd	s11,24(sp)
 3de:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3e0:	0005c903          	lbu	s2,0(a1)
 3e4:	18090f63          	beqz	s2,582 <vprintf+0x1c0>
 3e8:	8aaa                	mv	s5,a0
 3ea:	8b32                	mv	s6,a2
 3ec:	00158493          	addi	s1,a1,1
  state = 0;
 3f0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 3f2:	02500a13          	li	s4,37
      if(c == 'd'){
 3f6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 3fa:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 3fe:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 402:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 406:	00000b97          	auipc	s7,0x0
 40a:	37ab8b93          	addi	s7,s7,890 # 780 <digits>
 40e:	a839                	j	42c <vprintf+0x6a>
        putc(fd, c);
 410:	85ca                	mv	a1,s2
 412:	8556                	mv	a0,s5
 414:	00000097          	auipc	ra,0x0
 418:	ee2080e7          	jalr	-286(ra) # 2f6 <putc>
 41c:	a019                	j	422 <vprintf+0x60>
    } else if(state == '%'){
 41e:	01498f63          	beq	s3,s4,43c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 422:	0485                	addi	s1,s1,1
 424:	fff4c903          	lbu	s2,-1(s1)
 428:	14090d63          	beqz	s2,582 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 42c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 430:	fe0997e3          	bnez	s3,41e <vprintf+0x5c>
      if(c == '%'){
 434:	fd479ee3          	bne	a5,s4,410 <vprintf+0x4e>
        state = '%';
 438:	89be                	mv	s3,a5
 43a:	b7e5                	j	422 <vprintf+0x60>
      if(c == 'd'){
 43c:	05878063          	beq	a5,s8,47c <vprintf+0xba>
      } else if(c == 'l') {
 440:	05978c63          	beq	a5,s9,498 <vprintf+0xd6>
      } else if(c == 'x') {
 444:	07a78863          	beq	a5,s10,4b4 <vprintf+0xf2>
      } else if(c == 'p') {
 448:	09b78463          	beq	a5,s11,4d0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 44c:	07300713          	li	a4,115
 450:	0ce78663          	beq	a5,a4,51c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 454:	06300713          	li	a4,99
 458:	0ee78e63          	beq	a5,a4,554 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 45c:	11478863          	beq	a5,s4,56c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 460:	85d2                	mv	a1,s4
 462:	8556                	mv	a0,s5
 464:	00000097          	auipc	ra,0x0
 468:	e92080e7          	jalr	-366(ra) # 2f6 <putc>
        putc(fd, c);
 46c:	85ca                	mv	a1,s2
 46e:	8556                	mv	a0,s5
 470:	00000097          	auipc	ra,0x0
 474:	e86080e7          	jalr	-378(ra) # 2f6 <putc>
      }
      state = 0;
 478:	4981                	li	s3,0
 47a:	b765                	j	422 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 47c:	008b0913          	addi	s2,s6,8
 480:	4685                	li	a3,1
 482:	4629                	li	a2,10
 484:	000b2583          	lw	a1,0(s6)
 488:	8556                	mv	a0,s5
 48a:	00000097          	auipc	ra,0x0
 48e:	e8e080e7          	jalr	-370(ra) # 318 <printint>
 492:	8b4a                	mv	s6,s2
      state = 0;
 494:	4981                	li	s3,0
 496:	b771                	j	422 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 498:	008b0913          	addi	s2,s6,8
 49c:	4681                	li	a3,0
 49e:	4629                	li	a2,10
 4a0:	000b2583          	lw	a1,0(s6)
 4a4:	8556                	mv	a0,s5
 4a6:	00000097          	auipc	ra,0x0
 4aa:	e72080e7          	jalr	-398(ra) # 318 <printint>
 4ae:	8b4a                	mv	s6,s2
      state = 0;
 4b0:	4981                	li	s3,0
 4b2:	bf85                	j	422 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4b4:	008b0913          	addi	s2,s6,8
 4b8:	4681                	li	a3,0
 4ba:	4641                	li	a2,16
 4bc:	000b2583          	lw	a1,0(s6)
 4c0:	8556                	mv	a0,s5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	e56080e7          	jalr	-426(ra) # 318 <printint>
 4ca:	8b4a                	mv	s6,s2
      state = 0;
 4cc:	4981                	li	s3,0
 4ce:	bf91                	j	422 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4d0:	008b0793          	addi	a5,s6,8
 4d4:	f8f43423          	sd	a5,-120(s0)
 4d8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4dc:	03000593          	li	a1,48
 4e0:	8556                	mv	a0,s5
 4e2:	00000097          	auipc	ra,0x0
 4e6:	e14080e7          	jalr	-492(ra) # 2f6 <putc>
  putc(fd, 'x');
 4ea:	85ea                	mv	a1,s10
 4ec:	8556                	mv	a0,s5
 4ee:	00000097          	auipc	ra,0x0
 4f2:	e08080e7          	jalr	-504(ra) # 2f6 <putc>
 4f6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4f8:	03c9d793          	srli	a5,s3,0x3c
 4fc:	97de                	add	a5,a5,s7
 4fe:	0007c583          	lbu	a1,0(a5)
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	df2080e7          	jalr	-526(ra) # 2f6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 50c:	0992                	slli	s3,s3,0x4
 50e:	397d                	addiw	s2,s2,-1
 510:	fe0914e3          	bnez	s2,4f8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 514:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 518:	4981                	li	s3,0
 51a:	b721                	j	422 <vprintf+0x60>
        s = va_arg(ap, char*);
 51c:	008b0993          	addi	s3,s6,8
 520:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 524:	02090163          	beqz	s2,546 <vprintf+0x184>
        while(*s != 0){
 528:	00094583          	lbu	a1,0(s2)
 52c:	c9a1                	beqz	a1,57c <vprintf+0x1ba>
          putc(fd, *s);
 52e:	8556                	mv	a0,s5
 530:	00000097          	auipc	ra,0x0
 534:	dc6080e7          	jalr	-570(ra) # 2f6 <putc>
          s++;
 538:	0905                	addi	s2,s2,1
        while(*s != 0){
 53a:	00094583          	lbu	a1,0(s2)
 53e:	f9e5                	bnez	a1,52e <vprintf+0x16c>
        s = va_arg(ap, char*);
 540:	8b4e                	mv	s6,s3
      state = 0;
 542:	4981                	li	s3,0
 544:	bdf9                	j	422 <vprintf+0x60>
          s = "(null)";
 546:	00000917          	auipc	s2,0x0
 54a:	23290913          	addi	s2,s2,562 # 778 <malloc+0xec>
        while(*s != 0){
 54e:	02800593          	li	a1,40
 552:	bff1                	j	52e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 554:	008b0913          	addi	s2,s6,8
 558:	000b4583          	lbu	a1,0(s6)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	d98080e7          	jalr	-616(ra) # 2f6 <putc>
 566:	8b4a                	mv	s6,s2
      state = 0;
 568:	4981                	li	s3,0
 56a:	bd65                	j	422 <vprintf+0x60>
        putc(fd, c);
 56c:	85d2                	mv	a1,s4
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	d86080e7          	jalr	-634(ra) # 2f6 <putc>
      state = 0;
 578:	4981                	li	s3,0
 57a:	b565                	j	422 <vprintf+0x60>
        s = va_arg(ap, char*);
 57c:	8b4e                	mv	s6,s3
      state = 0;
 57e:	4981                	li	s3,0
 580:	b54d                	j	422 <vprintf+0x60>
    }
  }
}
 582:	70e6                	ld	ra,120(sp)
 584:	7446                	ld	s0,112(sp)
 586:	74a6                	ld	s1,104(sp)
 588:	7906                	ld	s2,96(sp)
 58a:	69e6                	ld	s3,88(sp)
 58c:	6a46                	ld	s4,80(sp)
 58e:	6aa6                	ld	s5,72(sp)
 590:	6b06                	ld	s6,64(sp)
 592:	7be2                	ld	s7,56(sp)
 594:	7c42                	ld	s8,48(sp)
 596:	7ca2                	ld	s9,40(sp)
 598:	7d02                	ld	s10,32(sp)
 59a:	6de2                	ld	s11,24(sp)
 59c:	6109                	addi	sp,sp,128
 59e:	8082                	ret

00000000000005a0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5a0:	715d                	addi	sp,sp,-80
 5a2:	ec06                	sd	ra,24(sp)
 5a4:	e822                	sd	s0,16(sp)
 5a6:	1000                	addi	s0,sp,32
 5a8:	e010                	sd	a2,0(s0)
 5aa:	e414                	sd	a3,8(s0)
 5ac:	e818                	sd	a4,16(s0)
 5ae:	ec1c                	sd	a5,24(s0)
 5b0:	03043023          	sd	a6,32(s0)
 5b4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5bc:	8622                	mv	a2,s0
 5be:	00000097          	auipc	ra,0x0
 5c2:	e04080e7          	jalr	-508(ra) # 3c2 <vprintf>
}
 5c6:	60e2                	ld	ra,24(sp)
 5c8:	6442                	ld	s0,16(sp)
 5ca:	6161                	addi	sp,sp,80
 5cc:	8082                	ret

00000000000005ce <printf>:

void
printf(const char *fmt, ...)
{
 5ce:	711d                	addi	sp,sp,-96
 5d0:	ec06                	sd	ra,24(sp)
 5d2:	e822                	sd	s0,16(sp)
 5d4:	1000                	addi	s0,sp,32
 5d6:	e40c                	sd	a1,8(s0)
 5d8:	e810                	sd	a2,16(s0)
 5da:	ec14                	sd	a3,24(s0)
 5dc:	f018                	sd	a4,32(s0)
 5de:	f41c                	sd	a5,40(s0)
 5e0:	03043823          	sd	a6,48(s0)
 5e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5e8:	00840613          	addi	a2,s0,8
 5ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 5f0:	85aa                	mv	a1,a0
 5f2:	4505                	li	a0,1
 5f4:	00000097          	auipc	ra,0x0
 5f8:	dce080e7          	jalr	-562(ra) # 3c2 <vprintf>
}
 5fc:	60e2                	ld	ra,24(sp)
 5fe:	6442                	ld	s0,16(sp)
 600:	6125                	addi	sp,sp,96
 602:	8082                	ret

0000000000000604 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 604:	1141                	addi	sp,sp,-16
 606:	e422                	sd	s0,8(sp)
 608:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 60a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 60e:	00000797          	auipc	a5,0x0
 612:	18a7b783          	ld	a5,394(a5) # 798 <freep>
 616:	a805                	j	646 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 618:	4618                	lw	a4,8(a2)
 61a:	9db9                	addw	a1,a1,a4
 61c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 620:	6398                	ld	a4,0(a5)
 622:	6318                	ld	a4,0(a4)
 624:	fee53823          	sd	a4,-16(a0)
 628:	a091                	j	66c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 62a:	ff852703          	lw	a4,-8(a0)
 62e:	9e39                	addw	a2,a2,a4
 630:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 632:	ff053703          	ld	a4,-16(a0)
 636:	e398                	sd	a4,0(a5)
 638:	a099                	j	67e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63a:	6398                	ld	a4,0(a5)
 63c:	00e7e463          	bltu	a5,a4,644 <free+0x40>
 640:	00e6ea63          	bltu	a3,a4,654 <free+0x50>
{
 644:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 646:	fed7fae3          	bgeu	a5,a3,63a <free+0x36>
 64a:	6398                	ld	a4,0(a5)
 64c:	00e6e463          	bltu	a3,a4,654 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 650:	fee7eae3          	bltu	a5,a4,644 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 654:	ff852583          	lw	a1,-8(a0)
 658:	6390                	ld	a2,0(a5)
 65a:	02059713          	slli	a4,a1,0x20
 65e:	9301                	srli	a4,a4,0x20
 660:	0712                	slli	a4,a4,0x4
 662:	9736                	add	a4,a4,a3
 664:	fae60ae3          	beq	a2,a4,618 <free+0x14>
    bp->s.ptr = p->s.ptr;
 668:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 66c:	4790                	lw	a2,8(a5)
 66e:	02061713          	slli	a4,a2,0x20
 672:	9301                	srli	a4,a4,0x20
 674:	0712                	slli	a4,a4,0x4
 676:	973e                	add	a4,a4,a5
 678:	fae689e3          	beq	a3,a4,62a <free+0x26>
  } else
    p->s.ptr = bp;
 67c:	e394                	sd	a3,0(a5)
  freep = p;
 67e:	00000717          	auipc	a4,0x0
 682:	10f73d23          	sd	a5,282(a4) # 798 <freep>
}
 686:	6422                	ld	s0,8(sp)
 688:	0141                	addi	sp,sp,16
 68a:	8082                	ret

000000000000068c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 68c:	7139                	addi	sp,sp,-64
 68e:	fc06                	sd	ra,56(sp)
 690:	f822                	sd	s0,48(sp)
 692:	f426                	sd	s1,40(sp)
 694:	f04a                	sd	s2,32(sp)
 696:	ec4e                	sd	s3,24(sp)
 698:	e852                	sd	s4,16(sp)
 69a:	e456                	sd	s5,8(sp)
 69c:	e05a                	sd	s6,0(sp)
 69e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6a0:	02051493          	slli	s1,a0,0x20
 6a4:	9081                	srli	s1,s1,0x20
 6a6:	04bd                	addi	s1,s1,15
 6a8:	8091                	srli	s1,s1,0x4
 6aa:	0014899b          	addiw	s3,s1,1
 6ae:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6b0:	00000517          	auipc	a0,0x0
 6b4:	0e853503          	ld	a0,232(a0) # 798 <freep>
 6b8:	c515                	beqz	a0,6e4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6bc:	4798                	lw	a4,8(a5)
 6be:	02977f63          	bgeu	a4,s1,6fc <malloc+0x70>
 6c2:	8a4e                	mv	s4,s3
 6c4:	0009871b          	sext.w	a4,s3
 6c8:	6685                	lui	a3,0x1
 6ca:	00d77363          	bgeu	a4,a3,6d0 <malloc+0x44>
 6ce:	6a05                	lui	s4,0x1
 6d0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6d4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6d8:	00000917          	auipc	s2,0x0
 6dc:	0c090913          	addi	s2,s2,192 # 798 <freep>
  if(p == (char*)-1)
 6e0:	5afd                	li	s5,-1
 6e2:	a88d                	j	754 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 6e4:	00000797          	auipc	a5,0x0
 6e8:	0bc78793          	addi	a5,a5,188 # 7a0 <base>
 6ec:	00000717          	auipc	a4,0x0
 6f0:	0af73623          	sd	a5,172(a4) # 798 <freep>
 6f4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 6f6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 6fa:	b7e1                	j	6c2 <malloc+0x36>
      if(p->s.size == nunits)
 6fc:	02e48b63          	beq	s1,a4,732 <malloc+0xa6>
        p->s.size -= nunits;
 700:	4137073b          	subw	a4,a4,s3
 704:	c798                	sw	a4,8(a5)
        p += p->s.size;
 706:	1702                	slli	a4,a4,0x20
 708:	9301                	srli	a4,a4,0x20
 70a:	0712                	slli	a4,a4,0x4
 70c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 70e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 712:	00000717          	auipc	a4,0x0
 716:	08a73323          	sd	a0,134(a4) # 798 <freep>
      return (void*)(p + 1);
 71a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 71e:	70e2                	ld	ra,56(sp)
 720:	7442                	ld	s0,48(sp)
 722:	74a2                	ld	s1,40(sp)
 724:	7902                	ld	s2,32(sp)
 726:	69e2                	ld	s3,24(sp)
 728:	6a42                	ld	s4,16(sp)
 72a:	6aa2                	ld	s5,8(sp)
 72c:	6b02                	ld	s6,0(sp)
 72e:	6121                	addi	sp,sp,64
 730:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 732:	6398                	ld	a4,0(a5)
 734:	e118                	sd	a4,0(a0)
 736:	bff1                	j	712 <malloc+0x86>
  hp->s.size = nu;
 738:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 73c:	0541                	addi	a0,a0,16
 73e:	00000097          	auipc	ra,0x0
 742:	ec6080e7          	jalr	-314(ra) # 604 <free>
  return freep;
 746:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 74a:	d971                	beqz	a0,71e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 74e:	4798                	lw	a4,8(a5)
 750:	fa9776e3          	bgeu	a4,s1,6fc <malloc+0x70>
    if(p == freep)
 754:	00093703          	ld	a4,0(s2)
 758:	853e                	mv	a0,a5
 75a:	fef719e3          	bne	a4,a5,74c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 75e:	8552                	mv	a0,s4
 760:	00000097          	auipc	ra,0x0
 764:	b5e080e7          	jalr	-1186(ra) # 2be <sbrk>
  if(p == (char*)-1)
 768:	fd5518e3          	bne	a0,s5,738 <malloc+0xac>
        return 0;
 76c:	4501                	li	a0,0
 76e:	bf45                	j	71e <malloc+0x92>
