
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84ae                	mv	s1,a1
  if (argc != 2)
   c:	4789                	li	a5,2
   e:	02f51063          	bne	a0,a5,2e <main+0x2e>
    write(2, "Error message", strlen("Error message"));

  int x = atoi(argv[1]);
  12:	6488                	ld	a0,8(s1)
  14:	00000097          	auipc	ra,0x0
  18:	1b8080e7          	jalr	440(ra) # 1cc <atoi>

  sleep(x);
  1c:	00000097          	auipc	ra,0x0
  20:	2c0080e7          	jalr	704(ra) # 2dc <sleep>

  exit(0);
  24:	4501                	li	a0,0
  26:	00000097          	auipc	ra,0x0
  2a:	226080e7          	jalr	550(ra) # 24c <exit>
    write(2, "Error message", strlen("Error message"));
  2e:	00000517          	auipc	a0,0x0
  32:	75a50513          	addi	a0,a0,1882 # 788 <malloc+0xe6>
  36:	00000097          	auipc	ra,0x0
  3a:	068080e7          	jalr	104(ra) # 9e <strlen>
  3e:	0005061b          	sext.w	a2,a0
  42:	00000597          	auipc	a1,0x0
  46:	74658593          	addi	a1,a1,1862 # 788 <malloc+0xe6>
  4a:	4509                	li	a0,2
  4c:	00000097          	auipc	ra,0x0
  50:	220080e7          	jalr	544(ra) # 26c <write>
  54:	bf7d                	j	12 <main+0x12>

0000000000000056 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  56:	1141                	addi	sp,sp,-16
  58:	e422                	sd	s0,8(sp)
  5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5c:	87aa                	mv	a5,a0
  5e:	0585                	addi	a1,a1,1
  60:	0785                	addi	a5,a5,1
  62:	fff5c703          	lbu	a4,-1(a1)
  66:	fee78fa3          	sb	a4,-1(a5)
  6a:	fb75                	bnez	a4,5e <strcpy+0x8>
    ;
  return os;
}
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cb91                	beqz	a5,90 <strcmp+0x1e>
  7e:	0005c703          	lbu	a4,0(a1)
  82:	00f71763          	bne	a4,a5,90 <strcmp+0x1e>
    p++, q++;
  86:	0505                	addi	a0,a0,1
  88:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	fbe5                	bnez	a5,7e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  90:	0005c503          	lbu	a0,0(a1)
}
  94:	40a7853b          	subw	a0,a5,a0
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret

000000000000009e <strlen>:

uint
strlen(const char *s)
{
  9e:	1141                	addi	sp,sp,-16
  a0:	e422                	sd	s0,8(sp)
  a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a4:	00054783          	lbu	a5,0(a0)
  a8:	cf91                	beqz	a5,c4 <strlen+0x26>
  aa:	0505                	addi	a0,a0,1
  ac:	87aa                	mv	a5,a0
  ae:	4685                	li	a3,1
  b0:	9e89                	subw	a3,a3,a0
  b2:	00f6853b          	addw	a0,a3,a5
  b6:	0785                	addi	a5,a5,1
  b8:	fff7c703          	lbu	a4,-1(a5)
  bc:	fb7d                	bnez	a4,b2 <strlen+0x14>
    ;
  return n;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	addi	sp,sp,16
  c2:	8082                	ret
  for(n = 0; s[n]; n++)
  c4:	4501                	li	a0,0
  c6:	bfe5                	j	be <strlen+0x20>

00000000000000c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ce:	ce09                	beqz	a2,e8 <memset+0x20>
  d0:	87aa                	mv	a5,a0
  d2:	fff6071b          	addiw	a4,a2,-1
  d6:	1702                	slli	a4,a4,0x20
  d8:	9301                	srli	a4,a4,0x20
  da:	0705                	addi	a4,a4,1
  dc:	972a                	add	a4,a4,a0
    cdst[i] = c;
  de:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e2:	0785                	addi	a5,a5,1
  e4:	fee79de3          	bne	a5,a4,de <memset+0x16>
  }
  return dst;
}
  e8:	6422                	ld	s0,8(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <strchr>:

char*
strchr(const char *s, char c)
{
  ee:	1141                	addi	sp,sp,-16
  f0:	e422                	sd	s0,8(sp)
  f2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	cb99                	beqz	a5,10e <strchr+0x20>
    if(*s == c)
  fa:	00f58763          	beq	a1,a5,108 <strchr+0x1a>
  for(; *s; s++)
  fe:	0505                	addi	a0,a0,1
 100:	00054783          	lbu	a5,0(a0)
 104:	fbfd                	bnez	a5,fa <strchr+0xc>
      return (char*)s;
  return 0;
 106:	4501                	li	a0,0
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret
  return 0;
 10e:	4501                	li	a0,0
 110:	bfe5                	j	108 <strchr+0x1a>

0000000000000112 <gets>:

char*
gets(char *buf, int max)
{
 112:	711d                	addi	sp,sp,-96
 114:	ec86                	sd	ra,88(sp)
 116:	e8a2                	sd	s0,80(sp)
 118:	e4a6                	sd	s1,72(sp)
 11a:	e0ca                	sd	s2,64(sp)
 11c:	fc4e                	sd	s3,56(sp)
 11e:	f852                	sd	s4,48(sp)
 120:	f456                	sd	s5,40(sp)
 122:	f05a                	sd	s6,32(sp)
 124:	ec5e                	sd	s7,24(sp)
 126:	1080                	addi	s0,sp,96
 128:	8baa                	mv	s7,a0
 12a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12c:	892a                	mv	s2,a0
 12e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 130:	4aa9                	li	s5,10
 132:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 134:	89a6                	mv	s3,s1
 136:	2485                	addiw	s1,s1,1
 138:	0344d863          	bge	s1,s4,168 <gets+0x56>
    cc = read(0, &c, 1);
 13c:	4605                	li	a2,1
 13e:	faf40593          	addi	a1,s0,-81
 142:	4501                	li	a0,0
 144:	00000097          	auipc	ra,0x0
 148:	120080e7          	jalr	288(ra) # 264 <read>
    if(cc < 1)
 14c:	00a05e63          	blez	a0,168 <gets+0x56>
    buf[i++] = c;
 150:	faf44783          	lbu	a5,-81(s0)
 154:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 158:	01578763          	beq	a5,s5,166 <gets+0x54>
 15c:	0905                	addi	s2,s2,1
 15e:	fd679be3          	bne	a5,s6,134 <gets+0x22>
  for(i=0; i+1 < max; ){
 162:	89a6                	mv	s3,s1
 164:	a011                	j	168 <gets+0x56>
 166:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 168:	99de                	add	s3,s3,s7
 16a:	00098023          	sb	zero,0(s3)
  return buf;
}
 16e:	855e                	mv	a0,s7
 170:	60e6                	ld	ra,88(sp)
 172:	6446                	ld	s0,80(sp)
 174:	64a6                	ld	s1,72(sp)
 176:	6906                	ld	s2,64(sp)
 178:	79e2                	ld	s3,56(sp)
 17a:	7a42                	ld	s4,48(sp)
 17c:	7aa2                	ld	s5,40(sp)
 17e:	7b02                	ld	s6,32(sp)
 180:	6be2                	ld	s7,24(sp)
 182:	6125                	addi	sp,sp,96
 184:	8082                	ret

0000000000000186 <stat>:

int
stat(const char *n, struct stat *st)
{
 186:	1101                	addi	sp,sp,-32
 188:	ec06                	sd	ra,24(sp)
 18a:	e822                	sd	s0,16(sp)
 18c:	e426                	sd	s1,8(sp)
 18e:	e04a                	sd	s2,0(sp)
 190:	1000                	addi	s0,sp,32
 192:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 194:	4581                	li	a1,0
 196:	00000097          	auipc	ra,0x0
 19a:	0f6080e7          	jalr	246(ra) # 28c <open>
  if(fd < 0)
 19e:	02054563          	bltz	a0,1c8 <stat+0x42>
 1a2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a4:	85ca                	mv	a1,s2
 1a6:	00000097          	auipc	ra,0x0
 1aa:	0fe080e7          	jalr	254(ra) # 2a4 <fstat>
 1ae:	892a                	mv	s2,a0
  close(fd);
 1b0:	8526                	mv	a0,s1
 1b2:	00000097          	auipc	ra,0x0
 1b6:	0c2080e7          	jalr	194(ra) # 274 <close>
  return r;
}
 1ba:	854a                	mv	a0,s2
 1bc:	60e2                	ld	ra,24(sp)
 1be:	6442                	ld	s0,16(sp)
 1c0:	64a2                	ld	s1,8(sp)
 1c2:	6902                	ld	s2,0(sp)
 1c4:	6105                	addi	sp,sp,32
 1c6:	8082                	ret
    return -1;
 1c8:	597d                	li	s2,-1
 1ca:	bfc5                	j	1ba <stat+0x34>

00000000000001cc <atoi>:

int
atoi(const char *s)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d2:	00054603          	lbu	a2,0(a0)
 1d6:	fd06079b          	addiw	a5,a2,-48
 1da:	0ff7f793          	andi	a5,a5,255
 1de:	4725                	li	a4,9
 1e0:	02f76963          	bltu	a4,a5,212 <atoi+0x46>
 1e4:	86aa                	mv	a3,a0
  n = 0;
 1e6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1e8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ea:	0685                	addi	a3,a3,1
 1ec:	0025179b          	slliw	a5,a0,0x2
 1f0:	9fa9                	addw	a5,a5,a0
 1f2:	0017979b          	slliw	a5,a5,0x1
 1f6:	9fb1                	addw	a5,a5,a2
 1f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1fc:	0006c603          	lbu	a2,0(a3)
 200:	fd06071b          	addiw	a4,a2,-48
 204:	0ff77713          	andi	a4,a4,255
 208:	fee5f1e3          	bgeu	a1,a4,1ea <atoi+0x1e>
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  n = 0;
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <atoi+0x40>

0000000000000216 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 21c:	02c05163          	blez	a2,23e <memmove+0x28>
 220:	fff6071b          	addiw	a4,a2,-1
 224:	1702                	slli	a4,a4,0x20
 226:	9301                	srli	a4,a4,0x20
 228:	0705                	addi	a4,a4,1
 22a:	972a                	add	a4,a4,a0
  dst = vdst;
 22c:	87aa                	mv	a5,a0
    *dst++ = *src++;
 22e:	0585                	addi	a1,a1,1
 230:	0785                	addi	a5,a5,1
 232:	fff5c683          	lbu	a3,-1(a1)
 236:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 23a:	fee79ae3          	bne	a5,a4,22e <memmove+0x18>
  return vdst;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret

0000000000000244 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 244:	4885                	li	a7,1
 ecall
 246:	00000073          	ecall
 ret
 24a:	8082                	ret

000000000000024c <exit>:
.global exit
exit:
 li a7, SYS_exit
 24c:	4889                	li	a7,2
 ecall
 24e:	00000073          	ecall
 ret
 252:	8082                	ret

0000000000000254 <wait>:
.global wait
wait:
 li a7, SYS_wait
 254:	488d                	li	a7,3
 ecall
 256:	00000073          	ecall
 ret
 25a:	8082                	ret

000000000000025c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 25c:	4891                	li	a7,4
 ecall
 25e:	00000073          	ecall
 ret
 262:	8082                	ret

0000000000000264 <read>:
.global read
read:
 li a7, SYS_read
 264:	4895                	li	a7,5
 ecall
 266:	00000073          	ecall
 ret
 26a:	8082                	ret

000000000000026c <write>:
.global write
write:
 li a7, SYS_write
 26c:	48c1                	li	a7,16
 ecall
 26e:	00000073          	ecall
 ret
 272:	8082                	ret

0000000000000274 <close>:
.global close
close:
 li a7, SYS_close
 274:	48d5                	li	a7,21
 ecall
 276:	00000073          	ecall
 ret
 27a:	8082                	ret

000000000000027c <kill>:
.global kill
kill:
 li a7, SYS_kill
 27c:	4899                	li	a7,6
 ecall
 27e:	00000073          	ecall
 ret
 282:	8082                	ret

0000000000000284 <exec>:
.global exec
exec:
 li a7, SYS_exec
 284:	489d                	li	a7,7
 ecall
 286:	00000073          	ecall
 ret
 28a:	8082                	ret

000000000000028c <open>:
.global open
open:
 li a7, SYS_open
 28c:	48bd                	li	a7,15
 ecall
 28e:	00000073          	ecall
 ret
 292:	8082                	ret

0000000000000294 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 294:	48c5                	li	a7,17
 ecall
 296:	00000073          	ecall
 ret
 29a:	8082                	ret

000000000000029c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 29c:	48c9                	li	a7,18
 ecall
 29e:	00000073          	ecall
 ret
 2a2:	8082                	ret

00000000000002a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2a4:	48a1                	li	a7,8
 ecall
 2a6:	00000073          	ecall
 ret
 2aa:	8082                	ret

00000000000002ac <link>:
.global link
link:
 li a7, SYS_link
 2ac:	48cd                	li	a7,19
 ecall
 2ae:	00000073          	ecall
 ret
 2b2:	8082                	ret

00000000000002b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2b4:	48d1                	li	a7,20
 ecall
 2b6:	00000073          	ecall
 ret
 2ba:	8082                	ret

00000000000002bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2bc:	48a5                	li	a7,9
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2c4:	48a9                	li	a7,10
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2cc:	48ad                	li	a7,11
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2d4:	48b1                	li	a7,12
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2dc:	48b5                	li	a7,13
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2e4:	48b9                	li	a7,14
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 2ec:	48d9                	li	a7,22
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <crash>:
.global crash
crash:
 li a7, SYS_crash
 2f4:	48dd                	li	a7,23
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <mount>:
.global mount
mount:
 li a7, SYS_mount
 2fc:	48e1                	li	a7,24
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <umount>:
.global umount
umount:
 li a7, SYS_umount
 304:	48e5                	li	a7,25
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 30c:	1101                	addi	sp,sp,-32
 30e:	ec06                	sd	ra,24(sp)
 310:	e822                	sd	s0,16(sp)
 312:	1000                	addi	s0,sp,32
 314:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 318:	4605                	li	a2,1
 31a:	fef40593          	addi	a1,s0,-17
 31e:	00000097          	auipc	ra,0x0
 322:	f4e080e7          	jalr	-178(ra) # 26c <write>
}
 326:	60e2                	ld	ra,24(sp)
 328:	6442                	ld	s0,16(sp)
 32a:	6105                	addi	sp,sp,32
 32c:	8082                	ret

000000000000032e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 32e:	7139                	addi	sp,sp,-64
 330:	fc06                	sd	ra,56(sp)
 332:	f822                	sd	s0,48(sp)
 334:	f426                	sd	s1,40(sp)
 336:	f04a                	sd	s2,32(sp)
 338:	ec4e                	sd	s3,24(sp)
 33a:	0080                	addi	s0,sp,64
 33c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 33e:	c299                	beqz	a3,344 <printint+0x16>
 340:	0805c863          	bltz	a1,3d0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 344:	2581                	sext.w	a1,a1
  neg = 0;
 346:	4881                	li	a7,0
 348:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 34c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 34e:	2601                	sext.w	a2,a2
 350:	00000517          	auipc	a0,0x0
 354:	45050513          	addi	a0,a0,1104 # 7a0 <digits>
 358:	883a                	mv	a6,a4
 35a:	2705                	addiw	a4,a4,1
 35c:	02c5f7bb          	remuw	a5,a1,a2
 360:	1782                	slli	a5,a5,0x20
 362:	9381                	srli	a5,a5,0x20
 364:	97aa                	add	a5,a5,a0
 366:	0007c783          	lbu	a5,0(a5)
 36a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 36e:	0005879b          	sext.w	a5,a1
 372:	02c5d5bb          	divuw	a1,a1,a2
 376:	0685                	addi	a3,a3,1
 378:	fec7f0e3          	bgeu	a5,a2,358 <printint+0x2a>
  if(neg)
 37c:	00088b63          	beqz	a7,392 <printint+0x64>
    buf[i++] = '-';
 380:	fd040793          	addi	a5,s0,-48
 384:	973e                	add	a4,a4,a5
 386:	02d00793          	li	a5,45
 38a:	fef70823          	sb	a5,-16(a4)
 38e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 392:	02e05863          	blez	a4,3c2 <printint+0x94>
 396:	fc040793          	addi	a5,s0,-64
 39a:	00e78933          	add	s2,a5,a4
 39e:	fff78993          	addi	s3,a5,-1
 3a2:	99ba                	add	s3,s3,a4
 3a4:	377d                	addiw	a4,a4,-1
 3a6:	1702                	slli	a4,a4,0x20
 3a8:	9301                	srli	a4,a4,0x20
 3aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ae:	fff94583          	lbu	a1,-1(s2)
 3b2:	8526                	mv	a0,s1
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f58080e7          	jalr	-168(ra) # 30c <putc>
  while(--i >= 0)
 3bc:	197d                	addi	s2,s2,-1
 3be:	ff3918e3          	bne	s2,s3,3ae <printint+0x80>
}
 3c2:	70e2                	ld	ra,56(sp)
 3c4:	7442                	ld	s0,48(sp)
 3c6:	74a2                	ld	s1,40(sp)
 3c8:	7902                	ld	s2,32(sp)
 3ca:	69e2                	ld	s3,24(sp)
 3cc:	6121                	addi	sp,sp,64
 3ce:	8082                	ret
    x = -xx;
 3d0:	40b005bb          	negw	a1,a1
    neg = 1;
 3d4:	4885                	li	a7,1
    x = -xx;
 3d6:	bf8d                	j	348 <printint+0x1a>

00000000000003d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3d8:	7119                	addi	sp,sp,-128
 3da:	fc86                	sd	ra,120(sp)
 3dc:	f8a2                	sd	s0,112(sp)
 3de:	f4a6                	sd	s1,104(sp)
 3e0:	f0ca                	sd	s2,96(sp)
 3e2:	ecce                	sd	s3,88(sp)
 3e4:	e8d2                	sd	s4,80(sp)
 3e6:	e4d6                	sd	s5,72(sp)
 3e8:	e0da                	sd	s6,64(sp)
 3ea:	fc5e                	sd	s7,56(sp)
 3ec:	f862                	sd	s8,48(sp)
 3ee:	f466                	sd	s9,40(sp)
 3f0:	f06a                	sd	s10,32(sp)
 3f2:	ec6e                	sd	s11,24(sp)
 3f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3f6:	0005c903          	lbu	s2,0(a1)
 3fa:	18090f63          	beqz	s2,598 <vprintf+0x1c0>
 3fe:	8aaa                	mv	s5,a0
 400:	8b32                	mv	s6,a2
 402:	00158493          	addi	s1,a1,1
  state = 0;
 406:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 408:	02500a13          	li	s4,37
      if(c == 'd'){
 40c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 410:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 414:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 418:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 41c:	00000b97          	auipc	s7,0x0
 420:	384b8b93          	addi	s7,s7,900 # 7a0 <digits>
 424:	a839                	j	442 <vprintf+0x6a>
        putc(fd, c);
 426:	85ca                	mv	a1,s2
 428:	8556                	mv	a0,s5
 42a:	00000097          	auipc	ra,0x0
 42e:	ee2080e7          	jalr	-286(ra) # 30c <putc>
 432:	a019                	j	438 <vprintf+0x60>
    } else if(state == '%'){
 434:	01498f63          	beq	s3,s4,452 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 438:	0485                	addi	s1,s1,1
 43a:	fff4c903          	lbu	s2,-1(s1)
 43e:	14090d63          	beqz	s2,598 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 442:	0009079b          	sext.w	a5,s2
    if(state == 0){
 446:	fe0997e3          	bnez	s3,434 <vprintf+0x5c>
      if(c == '%'){
 44a:	fd479ee3          	bne	a5,s4,426 <vprintf+0x4e>
        state = '%';
 44e:	89be                	mv	s3,a5
 450:	b7e5                	j	438 <vprintf+0x60>
      if(c == 'd'){
 452:	05878063          	beq	a5,s8,492 <vprintf+0xba>
      } else if(c == 'l') {
 456:	05978c63          	beq	a5,s9,4ae <vprintf+0xd6>
      } else if(c == 'x') {
 45a:	07a78863          	beq	a5,s10,4ca <vprintf+0xf2>
      } else if(c == 'p') {
 45e:	09b78463          	beq	a5,s11,4e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 462:	07300713          	li	a4,115
 466:	0ce78663          	beq	a5,a4,532 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 46a:	06300713          	li	a4,99
 46e:	0ee78e63          	beq	a5,a4,56a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 472:	11478863          	beq	a5,s4,582 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 476:	85d2                	mv	a1,s4
 478:	8556                	mv	a0,s5
 47a:	00000097          	auipc	ra,0x0
 47e:	e92080e7          	jalr	-366(ra) # 30c <putc>
        putc(fd, c);
 482:	85ca                	mv	a1,s2
 484:	8556                	mv	a0,s5
 486:	00000097          	auipc	ra,0x0
 48a:	e86080e7          	jalr	-378(ra) # 30c <putc>
      }
      state = 0;
 48e:	4981                	li	s3,0
 490:	b765                	j	438 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 492:	008b0913          	addi	s2,s6,8
 496:	4685                	li	a3,1
 498:	4629                	li	a2,10
 49a:	000b2583          	lw	a1,0(s6)
 49e:	8556                	mv	a0,s5
 4a0:	00000097          	auipc	ra,0x0
 4a4:	e8e080e7          	jalr	-370(ra) # 32e <printint>
 4a8:	8b4a                	mv	s6,s2
      state = 0;
 4aa:	4981                	li	s3,0
 4ac:	b771                	j	438 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ae:	008b0913          	addi	s2,s6,8
 4b2:	4681                	li	a3,0
 4b4:	4629                	li	a2,10
 4b6:	000b2583          	lw	a1,0(s6)
 4ba:	8556                	mv	a0,s5
 4bc:	00000097          	auipc	ra,0x0
 4c0:	e72080e7          	jalr	-398(ra) # 32e <printint>
 4c4:	8b4a                	mv	s6,s2
      state = 0;
 4c6:	4981                	li	s3,0
 4c8:	bf85                	j	438 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4ca:	008b0913          	addi	s2,s6,8
 4ce:	4681                	li	a3,0
 4d0:	4641                	li	a2,16
 4d2:	000b2583          	lw	a1,0(s6)
 4d6:	8556                	mv	a0,s5
 4d8:	00000097          	auipc	ra,0x0
 4dc:	e56080e7          	jalr	-426(ra) # 32e <printint>
 4e0:	8b4a                	mv	s6,s2
      state = 0;
 4e2:	4981                	li	s3,0
 4e4:	bf91                	j	438 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4e6:	008b0793          	addi	a5,s6,8
 4ea:	f8f43423          	sd	a5,-120(s0)
 4ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4f2:	03000593          	li	a1,48
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	e14080e7          	jalr	-492(ra) # 30c <putc>
  putc(fd, 'x');
 500:	85ea                	mv	a1,s10
 502:	8556                	mv	a0,s5
 504:	00000097          	auipc	ra,0x0
 508:	e08080e7          	jalr	-504(ra) # 30c <putc>
 50c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 50e:	03c9d793          	srli	a5,s3,0x3c
 512:	97de                	add	a5,a5,s7
 514:	0007c583          	lbu	a1,0(a5)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	df2080e7          	jalr	-526(ra) # 30c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 522:	0992                	slli	s3,s3,0x4
 524:	397d                	addiw	s2,s2,-1
 526:	fe0914e3          	bnez	s2,50e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 52a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 52e:	4981                	li	s3,0
 530:	b721                	j	438 <vprintf+0x60>
        s = va_arg(ap, char*);
 532:	008b0993          	addi	s3,s6,8
 536:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 53a:	02090163          	beqz	s2,55c <vprintf+0x184>
        while(*s != 0){
 53e:	00094583          	lbu	a1,0(s2)
 542:	c9a1                	beqz	a1,592 <vprintf+0x1ba>
          putc(fd, *s);
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	dc6080e7          	jalr	-570(ra) # 30c <putc>
          s++;
 54e:	0905                	addi	s2,s2,1
        while(*s != 0){
 550:	00094583          	lbu	a1,0(s2)
 554:	f9e5                	bnez	a1,544 <vprintf+0x16c>
        s = va_arg(ap, char*);
 556:	8b4e                	mv	s6,s3
      state = 0;
 558:	4981                	li	s3,0
 55a:	bdf9                	j	438 <vprintf+0x60>
          s = "(null)";
 55c:	00000917          	auipc	s2,0x0
 560:	23c90913          	addi	s2,s2,572 # 798 <malloc+0xf6>
        while(*s != 0){
 564:	02800593          	li	a1,40
 568:	bff1                	j	544 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 56a:	008b0913          	addi	s2,s6,8
 56e:	000b4583          	lbu	a1,0(s6)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	d98080e7          	jalr	-616(ra) # 30c <putc>
 57c:	8b4a                	mv	s6,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	bd65                	j	438 <vprintf+0x60>
        putc(fd, c);
 582:	85d2                	mv	a1,s4
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	d86080e7          	jalr	-634(ra) # 30c <putc>
      state = 0;
 58e:	4981                	li	s3,0
 590:	b565                	j	438 <vprintf+0x60>
        s = va_arg(ap, char*);
 592:	8b4e                	mv	s6,s3
      state = 0;
 594:	4981                	li	s3,0
 596:	b54d                	j	438 <vprintf+0x60>
    }
  }
}
 598:	70e6                	ld	ra,120(sp)
 59a:	7446                	ld	s0,112(sp)
 59c:	74a6                	ld	s1,104(sp)
 59e:	7906                	ld	s2,96(sp)
 5a0:	69e6                	ld	s3,88(sp)
 5a2:	6a46                	ld	s4,80(sp)
 5a4:	6aa6                	ld	s5,72(sp)
 5a6:	6b06                	ld	s6,64(sp)
 5a8:	7be2                	ld	s7,56(sp)
 5aa:	7c42                	ld	s8,48(sp)
 5ac:	7ca2                	ld	s9,40(sp)
 5ae:	7d02                	ld	s10,32(sp)
 5b0:	6de2                	ld	s11,24(sp)
 5b2:	6109                	addi	sp,sp,128
 5b4:	8082                	ret

00000000000005b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5b6:	715d                	addi	sp,sp,-80
 5b8:	ec06                	sd	ra,24(sp)
 5ba:	e822                	sd	s0,16(sp)
 5bc:	1000                	addi	s0,sp,32
 5be:	e010                	sd	a2,0(s0)
 5c0:	e414                	sd	a3,8(s0)
 5c2:	e818                	sd	a4,16(s0)
 5c4:	ec1c                	sd	a5,24(s0)
 5c6:	03043023          	sd	a6,32(s0)
 5ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5d2:	8622                	mv	a2,s0
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e04080e7          	jalr	-508(ra) # 3d8 <vprintf>
}
 5dc:	60e2                	ld	ra,24(sp)
 5de:	6442                	ld	s0,16(sp)
 5e0:	6161                	addi	sp,sp,80
 5e2:	8082                	ret

00000000000005e4 <printf>:

void
printf(const char *fmt, ...)
{
 5e4:	711d                	addi	sp,sp,-96
 5e6:	ec06                	sd	ra,24(sp)
 5e8:	e822                	sd	s0,16(sp)
 5ea:	1000                	addi	s0,sp,32
 5ec:	e40c                	sd	a1,8(s0)
 5ee:	e810                	sd	a2,16(s0)
 5f0:	ec14                	sd	a3,24(s0)
 5f2:	f018                	sd	a4,32(s0)
 5f4:	f41c                	sd	a5,40(s0)
 5f6:	03043823          	sd	a6,48(s0)
 5fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 5fe:	00840613          	addi	a2,s0,8
 602:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 606:	85aa                	mv	a1,a0
 608:	4505                	li	a0,1
 60a:	00000097          	auipc	ra,0x0
 60e:	dce080e7          	jalr	-562(ra) # 3d8 <vprintf>
}
 612:	60e2                	ld	ra,24(sp)
 614:	6442                	ld	s0,16(sp)
 616:	6125                	addi	sp,sp,96
 618:	8082                	ret

000000000000061a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 61a:	1141                	addi	sp,sp,-16
 61c:	e422                	sd	s0,8(sp)
 61e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 620:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 624:	00000797          	auipc	a5,0x0
 628:	1947b783          	ld	a5,404(a5) # 7b8 <freep>
 62c:	a805                	j	65c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 62e:	4618                	lw	a4,8(a2)
 630:	9db9                	addw	a1,a1,a4
 632:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 636:	6398                	ld	a4,0(a5)
 638:	6318                	ld	a4,0(a4)
 63a:	fee53823          	sd	a4,-16(a0)
 63e:	a091                	j	682 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 640:	ff852703          	lw	a4,-8(a0)
 644:	9e39                	addw	a2,a2,a4
 646:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 648:	ff053703          	ld	a4,-16(a0)
 64c:	e398                	sd	a4,0(a5)
 64e:	a099                	j	694 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 650:	6398                	ld	a4,0(a5)
 652:	00e7e463          	bltu	a5,a4,65a <free+0x40>
 656:	00e6ea63          	bltu	a3,a4,66a <free+0x50>
{
 65a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65c:	fed7fae3          	bgeu	a5,a3,650 <free+0x36>
 660:	6398                	ld	a4,0(a5)
 662:	00e6e463          	bltu	a3,a4,66a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 666:	fee7eae3          	bltu	a5,a4,65a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 66a:	ff852583          	lw	a1,-8(a0)
 66e:	6390                	ld	a2,0(a5)
 670:	02059713          	slli	a4,a1,0x20
 674:	9301                	srli	a4,a4,0x20
 676:	0712                	slli	a4,a4,0x4
 678:	9736                	add	a4,a4,a3
 67a:	fae60ae3          	beq	a2,a4,62e <free+0x14>
    bp->s.ptr = p->s.ptr;
 67e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 682:	4790                	lw	a2,8(a5)
 684:	02061713          	slli	a4,a2,0x20
 688:	9301                	srli	a4,a4,0x20
 68a:	0712                	slli	a4,a4,0x4
 68c:	973e                	add	a4,a4,a5
 68e:	fae689e3          	beq	a3,a4,640 <free+0x26>
  } else
    p->s.ptr = bp;
 692:	e394                	sd	a3,0(a5)
  freep = p;
 694:	00000717          	auipc	a4,0x0
 698:	12f73223          	sd	a5,292(a4) # 7b8 <freep>
}
 69c:	6422                	ld	s0,8(sp)
 69e:	0141                	addi	sp,sp,16
 6a0:	8082                	ret

00000000000006a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6a2:	7139                	addi	sp,sp,-64
 6a4:	fc06                	sd	ra,56(sp)
 6a6:	f822                	sd	s0,48(sp)
 6a8:	f426                	sd	s1,40(sp)
 6aa:	f04a                	sd	s2,32(sp)
 6ac:	ec4e                	sd	s3,24(sp)
 6ae:	e852                	sd	s4,16(sp)
 6b0:	e456                	sd	s5,8(sp)
 6b2:	e05a                	sd	s6,0(sp)
 6b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6b6:	02051493          	slli	s1,a0,0x20
 6ba:	9081                	srli	s1,s1,0x20
 6bc:	04bd                	addi	s1,s1,15
 6be:	8091                	srli	s1,s1,0x4
 6c0:	0014899b          	addiw	s3,s1,1
 6c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6c6:	00000517          	auipc	a0,0x0
 6ca:	0f253503          	ld	a0,242(a0) # 7b8 <freep>
 6ce:	c515                	beqz	a0,6fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6d2:	4798                	lw	a4,8(a5)
 6d4:	02977f63          	bgeu	a4,s1,712 <malloc+0x70>
 6d8:	8a4e                	mv	s4,s3
 6da:	0009871b          	sext.w	a4,s3
 6de:	6685                	lui	a3,0x1
 6e0:	00d77363          	bgeu	a4,a3,6e6 <malloc+0x44>
 6e4:	6a05                	lui	s4,0x1
 6e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6ee:	00000917          	auipc	s2,0x0
 6f2:	0ca90913          	addi	s2,s2,202 # 7b8 <freep>
  if(p == (char*)-1)
 6f6:	5afd                	li	s5,-1
 6f8:	a88d                	j	76a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 6fa:	00000797          	auipc	a5,0x0
 6fe:	0c678793          	addi	a5,a5,198 # 7c0 <base>
 702:	00000717          	auipc	a4,0x0
 706:	0af73b23          	sd	a5,182(a4) # 7b8 <freep>
 70a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 70c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 710:	b7e1                	j	6d8 <malloc+0x36>
      if(p->s.size == nunits)
 712:	02e48b63          	beq	s1,a4,748 <malloc+0xa6>
        p->s.size -= nunits;
 716:	4137073b          	subw	a4,a4,s3
 71a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 71c:	1702                	slli	a4,a4,0x20
 71e:	9301                	srli	a4,a4,0x20
 720:	0712                	slli	a4,a4,0x4
 722:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 724:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 728:	00000717          	auipc	a4,0x0
 72c:	08a73823          	sd	a0,144(a4) # 7b8 <freep>
      return (void*)(p + 1);
 730:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 734:	70e2                	ld	ra,56(sp)
 736:	7442                	ld	s0,48(sp)
 738:	74a2                	ld	s1,40(sp)
 73a:	7902                	ld	s2,32(sp)
 73c:	69e2                	ld	s3,24(sp)
 73e:	6a42                	ld	s4,16(sp)
 740:	6aa2                	ld	s5,8(sp)
 742:	6b02                	ld	s6,0(sp)
 744:	6121                	addi	sp,sp,64
 746:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 748:	6398                	ld	a4,0(a5)
 74a:	e118                	sd	a4,0(a0)
 74c:	bff1                	j	728 <malloc+0x86>
  hp->s.size = nu;
 74e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 752:	0541                	addi	a0,a0,16
 754:	00000097          	auipc	ra,0x0
 758:	ec6080e7          	jalr	-314(ra) # 61a <free>
  return freep;
 75c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 760:	d971                	beqz	a0,734 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 762:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 764:	4798                	lw	a4,8(a5)
 766:	fa9776e3          	bgeu	a4,s1,712 <malloc+0x70>
    if(p == freep)
 76a:	00093703          	ld	a4,0(s2)
 76e:	853e                	mv	a0,a5
 770:	fef719e3          	bne	a4,a5,762 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 774:	8552                	mv	a0,s4
 776:	00000097          	auipc	ra,0x0
 77a:	b5e080e7          	jalr	-1186(ra) # 2d4 <sbrk>
  if(p == (char*)-1)
 77e:	fd5518e3          	bne	a0,s5,74e <malloc+0xac>
        return 0;
 782:	4501                	li	a0,0
 784:	bf45                	j	734 <malloc+0x92>
