
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"

int main(int argc,char *argv[]){
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	0900                	addi	s0,sp,144
	int parent_fd[2];
	int child_fd[2];
	pipe(parent_fd);
   8:	fe840513          	addi	a0,s0,-24
   c:	00000097          	auipc	ra,0x0
  10:	2ba080e7          	jalr	698(ra) # 2c6 <pipe>
	pipe(child_fd);
  14:	fe040513          	addi	a0,s0,-32
  18:	00000097          	auipc	ra,0x0
  1c:	2ae080e7          	jalr	686(ra) # 2c6 <pipe>
	char buffer[100];

	if(fork()!=0){
  20:	00000097          	auipc	ra,0x0
  24:	28e080e7          	jalr	654(ra) # 2ae <fork>
  28:	c921                	beqz	a0,78 <main+0x78>
		write(parent_fd[1],"ping",4);
  2a:	4611                	li	a2,4
  2c:	00000597          	auipc	a1,0x0
  30:	7c458593          	addi	a1,a1,1988 # 7f0 <malloc+0xe4>
  34:	fec42503          	lw	a0,-20(s0)
  38:	00000097          	auipc	ra,0x0
  3c:	29e080e7          	jalr	670(ra) # 2d6 <write>
		read(child_fd[0],buffer,4);
  40:	4611                	li	a2,4
  42:	f7840593          	addi	a1,s0,-136
  46:	fe042503          	lw	a0,-32(s0)
  4a:	00000097          	auipc	ra,0x0
  4e:	284080e7          	jalr	644(ra) # 2ce <read>
		printf("%d: received %s\n",getpid(),buffer);
  52:	00000097          	auipc	ra,0x0
  56:	2e4080e7          	jalr	740(ra) # 336 <getpid>
  5a:	85aa                	mv	a1,a0
  5c:	f7840613          	addi	a2,s0,-136
  60:	00000517          	auipc	a0,0x0
  64:	79850513          	addi	a0,a0,1944 # 7f8 <malloc+0xec>
  68:	00000097          	auipc	ra,0x0
  6c:	5e6080e7          	jalr	1510(ra) # 64e <printf>
	}else{
		read(parent_fd[0],buffer,4);
		printf("%d: received %s\n",getpid(),buffer);
		write(child_fd[1],"pong",4);
	}
	exit();
  70:	00000097          	auipc	ra,0x0
  74:	246080e7          	jalr	582(ra) # 2b6 <exit>
		read(parent_fd[0],buffer,4);
  78:	4611                	li	a2,4
  7a:	f7840593          	addi	a1,s0,-136
  7e:	fe842503          	lw	a0,-24(s0)
  82:	00000097          	auipc	ra,0x0
  86:	24c080e7          	jalr	588(ra) # 2ce <read>
		printf("%d: received %s\n",getpid(),buffer);
  8a:	00000097          	auipc	ra,0x0
  8e:	2ac080e7          	jalr	684(ra) # 336 <getpid>
  92:	85aa                	mv	a1,a0
  94:	f7840613          	addi	a2,s0,-136
  98:	00000517          	auipc	a0,0x0
  9c:	76050513          	addi	a0,a0,1888 # 7f8 <malloc+0xec>
  a0:	00000097          	auipc	ra,0x0
  a4:	5ae080e7          	jalr	1454(ra) # 64e <printf>
		write(child_fd[1],"pong",4);
  a8:	4611                	li	a2,4
  aa:	00000597          	auipc	a1,0x0
  ae:	76658593          	addi	a1,a1,1894 # 810 <malloc+0x104>
  b2:	fe442503          	lw	a0,-28(s0)
  b6:	00000097          	auipc	ra,0x0
  ba:	220080e7          	jalr	544(ra) # 2d6 <write>
  be:	bf4d                	j	70 <main+0x70>

00000000000000c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  c0:	1141                	addi	sp,sp,-16
  c2:	e422                	sd	s0,8(sp)
  c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c6:	87aa                	mv	a5,a0
  c8:	0585                	addi	a1,a1,1
  ca:	0785                	addi	a5,a5,1
  cc:	fff5c703          	lbu	a4,-1(a1)
  d0:	fee78fa3          	sb	a4,-1(a5)
  d4:	fb75                	bnez	a4,c8 <strcpy+0x8>
    ;
  return os;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb91                	beqz	a5,fa <strcmp+0x1e>
  e8:	0005c703          	lbu	a4,0(a1)
  ec:	00f71763          	bne	a4,a5,fa <strcmp+0x1e>
    p++, q++;
  f0:	0505                	addi	a0,a0,1
  f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f4:	00054783          	lbu	a5,0(a0)
  f8:	fbe5                	bnez	a5,e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fa:	0005c503          	lbu	a0,0(a1)
}
  fe:	40a7853b          	subw	a0,a5,a0
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret

0000000000000108 <strlen>:

uint
strlen(const char *s)
{
 108:	1141                	addi	sp,sp,-16
 10a:	e422                	sd	s0,8(sp)
 10c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 10e:	00054783          	lbu	a5,0(a0)
 112:	cf91                	beqz	a5,12e <strlen+0x26>
 114:	0505                	addi	a0,a0,1
 116:	87aa                	mv	a5,a0
 118:	4685                	li	a3,1
 11a:	9e89                	subw	a3,a3,a0
 11c:	00f6853b          	addw	a0,a3,a5
 120:	0785                	addi	a5,a5,1
 122:	fff7c703          	lbu	a4,-1(a5)
 126:	fb7d                	bnez	a4,11c <strlen+0x14>
    ;
  return n;
}
 128:	6422                	ld	s0,8(sp)
 12a:	0141                	addi	sp,sp,16
 12c:	8082                	ret
  for(n = 0; s[n]; n++)
 12e:	4501                	li	a0,0
 130:	bfe5                	j	128 <strlen+0x20>

0000000000000132 <memset>:

void*
memset(void *dst, int c, uint n)
{
 132:	1141                	addi	sp,sp,-16
 134:	e422                	sd	s0,8(sp)
 136:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 138:	ce09                	beqz	a2,152 <memset+0x20>
 13a:	87aa                	mv	a5,a0
 13c:	fff6071b          	addiw	a4,a2,-1
 140:	1702                	slli	a4,a4,0x20
 142:	9301                	srli	a4,a4,0x20
 144:	0705                	addi	a4,a4,1
 146:	972a                	add	a4,a4,a0
    cdst[i] = c;
 148:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14c:	0785                	addi	a5,a5,1
 14e:	fee79de3          	bne	a5,a4,148 <memset+0x16>
  }
  return dst;
}
 152:	6422                	ld	s0,8(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strchr>:

char*
strchr(const char *s, char c)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cb99                	beqz	a5,178 <strchr+0x20>
    if(*s == c)
 164:	00f58763          	beq	a1,a5,172 <strchr+0x1a>
  for(; *s; s++)
 168:	0505                	addi	a0,a0,1
 16a:	00054783          	lbu	a5,0(a0)
 16e:	fbfd                	bnez	a5,164 <strchr+0xc>
      return (char*)s;
  return 0;
 170:	4501                	li	a0,0
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	addi	sp,sp,16
 176:	8082                	ret
  return 0;
 178:	4501                	li	a0,0
 17a:	bfe5                	j	172 <strchr+0x1a>

000000000000017c <gets>:

char*
gets(char *buf, int max)
{
 17c:	711d                	addi	sp,sp,-96
 17e:	ec86                	sd	ra,88(sp)
 180:	e8a2                	sd	s0,80(sp)
 182:	e4a6                	sd	s1,72(sp)
 184:	e0ca                	sd	s2,64(sp)
 186:	fc4e                	sd	s3,56(sp)
 188:	f852                	sd	s4,48(sp)
 18a:	f456                	sd	s5,40(sp)
 18c:	f05a                	sd	s6,32(sp)
 18e:	ec5e                	sd	s7,24(sp)
 190:	1080                	addi	s0,sp,96
 192:	8baa                	mv	s7,a0
 194:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 196:	892a                	mv	s2,a0
 198:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 19a:	4aa9                	li	s5,10
 19c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19e:	89a6                	mv	s3,s1
 1a0:	2485                	addiw	s1,s1,1
 1a2:	0344d863          	bge	s1,s4,1d2 <gets+0x56>
    cc = read(0, &c, 1);
 1a6:	4605                	li	a2,1
 1a8:	faf40593          	addi	a1,s0,-81
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	120080e7          	jalr	288(ra) # 2ce <read>
    if(cc < 1)
 1b6:	00a05e63          	blez	a0,1d2 <gets+0x56>
    buf[i++] = c;
 1ba:	faf44783          	lbu	a5,-81(s0)
 1be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1c2:	01578763          	beq	a5,s5,1d0 <gets+0x54>
 1c6:	0905                	addi	s2,s2,1
 1c8:	fd679be3          	bne	a5,s6,19e <gets+0x22>
  for(i=0; i+1 < max; ){
 1cc:	89a6                	mv	s3,s1
 1ce:	a011                	j	1d2 <gets+0x56>
 1d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1d2:	99de                	add	s3,s3,s7
 1d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d8:	855e                	mv	a0,s7
 1da:	60e6                	ld	ra,88(sp)
 1dc:	6446                	ld	s0,80(sp)
 1de:	64a6                	ld	s1,72(sp)
 1e0:	6906                	ld	s2,64(sp)
 1e2:	79e2                	ld	s3,56(sp)
 1e4:	7a42                	ld	s4,48(sp)
 1e6:	7aa2                	ld	s5,40(sp)
 1e8:	7b02                	ld	s6,32(sp)
 1ea:	6be2                	ld	s7,24(sp)
 1ec:	6125                	addi	sp,sp,96
 1ee:	8082                	ret

00000000000001f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f0:	1101                	addi	sp,sp,-32
 1f2:	ec06                	sd	ra,24(sp)
 1f4:	e822                	sd	s0,16(sp)
 1f6:	e426                	sd	s1,8(sp)
 1f8:	e04a                	sd	s2,0(sp)
 1fa:	1000                	addi	s0,sp,32
 1fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1fe:	4581                	li	a1,0
 200:	00000097          	auipc	ra,0x0
 204:	0f6080e7          	jalr	246(ra) # 2f6 <open>
  if(fd < 0)
 208:	02054563          	bltz	a0,232 <stat+0x42>
 20c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 20e:	85ca                	mv	a1,s2
 210:	00000097          	auipc	ra,0x0
 214:	0fe080e7          	jalr	254(ra) # 30e <fstat>
 218:	892a                	mv	s2,a0
  close(fd);
 21a:	8526                	mv	a0,s1
 21c:	00000097          	auipc	ra,0x0
 220:	0c2080e7          	jalr	194(ra) # 2de <close>
  return r;
}
 224:	854a                	mv	a0,s2
 226:	60e2                	ld	ra,24(sp)
 228:	6442                	ld	s0,16(sp)
 22a:	64a2                	ld	s1,8(sp)
 22c:	6902                	ld	s2,0(sp)
 22e:	6105                	addi	sp,sp,32
 230:	8082                	ret
    return -1;
 232:	597d                	li	s2,-1
 234:	bfc5                	j	224 <stat+0x34>

0000000000000236 <atoi>:

int
atoi(const char *s)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 23c:	00054603          	lbu	a2,0(a0)
 240:	fd06079b          	addiw	a5,a2,-48
 244:	0ff7f793          	andi	a5,a5,255
 248:	4725                	li	a4,9
 24a:	02f76963          	bltu	a4,a5,27c <atoi+0x46>
 24e:	86aa                	mv	a3,a0
  n = 0;
 250:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 252:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 254:	0685                	addi	a3,a3,1
 256:	0025179b          	slliw	a5,a0,0x2
 25a:	9fa9                	addw	a5,a5,a0
 25c:	0017979b          	slliw	a5,a5,0x1
 260:	9fb1                	addw	a5,a5,a2
 262:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 266:	0006c603          	lbu	a2,0(a3)
 26a:	fd06071b          	addiw	a4,a2,-48
 26e:	0ff77713          	andi	a4,a4,255
 272:	fee5f1e3          	bgeu	a1,a4,254 <atoi+0x1e>
  return n;
}
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret
  n = 0;
 27c:	4501                	li	a0,0
 27e:	bfe5                	j	276 <atoi+0x40>

0000000000000280 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 280:	1141                	addi	sp,sp,-16
 282:	e422                	sd	s0,8(sp)
 284:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 286:	02c05163          	blez	a2,2a8 <memmove+0x28>
 28a:	fff6071b          	addiw	a4,a2,-1
 28e:	1702                	slli	a4,a4,0x20
 290:	9301                	srli	a4,a4,0x20
 292:	0705                	addi	a4,a4,1
 294:	972a                	add	a4,a4,a0
  dst = vdst;
 296:	87aa                	mv	a5,a0
    *dst++ = *src++;
 298:	0585                	addi	a1,a1,1
 29a:	0785                	addi	a5,a5,1
 29c:	fff5c683          	lbu	a3,-1(a1)
 2a0:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 2a4:	fee79ae3          	bne	a5,a4,298 <memmove+0x18>
  return vdst;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ae:	4885                	li	a7,1
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2b6:	4889                	li	a7,2
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <wait>:
.global wait
wait:
 li a7, SYS_wait
 2be:	488d                	li	a7,3
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2c6:	4891                	li	a7,4
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <read>:
.global read
read:
 li a7, SYS_read
 2ce:	4895                	li	a7,5
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <write>:
.global write
write:
 li a7, SYS_write
 2d6:	48c1                	li	a7,16
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <close>:
.global close
close:
 li a7, SYS_close
 2de:	48d5                	li	a7,21
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2e6:	4899                	li	a7,6
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ee:	489d                	li	a7,7
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <open>:
.global open
open:
 li a7, SYS_open
 2f6:	48bd                	li	a7,15
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2fe:	48c5                	li	a7,17
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 306:	48c9                	li	a7,18
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 30e:	48a1                	li	a7,8
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <link>:
.global link
link:
 li a7, SYS_link
 316:	48cd                	li	a7,19
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 31e:	48d1                	li	a7,20
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 326:	48a5                	li	a7,9
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <dup>:
.global dup
dup:
 li a7, SYS_dup
 32e:	48a9                	li	a7,10
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 336:	48ad                	li	a7,11
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 33e:	48b1                	li	a7,12
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 346:	48b5                	li	a7,13
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 34e:	48b9                	li	a7,14
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 356:	48d9                	li	a7,22
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <crash>:
.global crash
crash:
 li a7, SYS_crash
 35e:	48dd                	li	a7,23
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mount>:
.global mount
mount:
 li a7, SYS_mount
 366:	48e1                	li	a7,24
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <umount>:
.global umount
umount:
 li a7, SYS_umount
 36e:	48e5                	li	a7,25
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 376:	1101                	addi	sp,sp,-32
 378:	ec06                	sd	ra,24(sp)
 37a:	e822                	sd	s0,16(sp)
 37c:	1000                	addi	s0,sp,32
 37e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 382:	4605                	li	a2,1
 384:	fef40593          	addi	a1,s0,-17
 388:	00000097          	auipc	ra,0x0
 38c:	f4e080e7          	jalr	-178(ra) # 2d6 <write>
}
 390:	60e2                	ld	ra,24(sp)
 392:	6442                	ld	s0,16(sp)
 394:	6105                	addi	sp,sp,32
 396:	8082                	ret

0000000000000398 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 398:	7139                	addi	sp,sp,-64
 39a:	fc06                	sd	ra,56(sp)
 39c:	f822                	sd	s0,48(sp)
 39e:	f426                	sd	s1,40(sp)
 3a0:	f04a                	sd	s2,32(sp)
 3a2:	ec4e                	sd	s3,24(sp)
 3a4:	0080                	addi	s0,sp,64
 3a6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3a8:	c299                	beqz	a3,3ae <printint+0x16>
 3aa:	0805c863          	bltz	a1,43a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ae:	2581                	sext.w	a1,a1
  neg = 0;
 3b0:	4881                	li	a7,0
 3b2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3b6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3b8:	2601                	sext.w	a2,a2
 3ba:	00000517          	auipc	a0,0x0
 3be:	46650513          	addi	a0,a0,1126 # 820 <digits>
 3c2:	883a                	mv	a6,a4
 3c4:	2705                	addiw	a4,a4,1
 3c6:	02c5f7bb          	remuw	a5,a1,a2
 3ca:	1782                	slli	a5,a5,0x20
 3cc:	9381                	srli	a5,a5,0x20
 3ce:	97aa                	add	a5,a5,a0
 3d0:	0007c783          	lbu	a5,0(a5)
 3d4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3d8:	0005879b          	sext.w	a5,a1
 3dc:	02c5d5bb          	divuw	a1,a1,a2
 3e0:	0685                	addi	a3,a3,1
 3e2:	fec7f0e3          	bgeu	a5,a2,3c2 <printint+0x2a>
  if(neg)
 3e6:	00088b63          	beqz	a7,3fc <printint+0x64>
    buf[i++] = '-';
 3ea:	fd040793          	addi	a5,s0,-48
 3ee:	973e                	add	a4,a4,a5
 3f0:	02d00793          	li	a5,45
 3f4:	fef70823          	sb	a5,-16(a4)
 3f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3fc:	02e05863          	blez	a4,42c <printint+0x94>
 400:	fc040793          	addi	a5,s0,-64
 404:	00e78933          	add	s2,a5,a4
 408:	fff78993          	addi	s3,a5,-1
 40c:	99ba                	add	s3,s3,a4
 40e:	377d                	addiw	a4,a4,-1
 410:	1702                	slli	a4,a4,0x20
 412:	9301                	srli	a4,a4,0x20
 414:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 418:	fff94583          	lbu	a1,-1(s2)
 41c:	8526                	mv	a0,s1
 41e:	00000097          	auipc	ra,0x0
 422:	f58080e7          	jalr	-168(ra) # 376 <putc>
  while(--i >= 0)
 426:	197d                	addi	s2,s2,-1
 428:	ff3918e3          	bne	s2,s3,418 <printint+0x80>
}
 42c:	70e2                	ld	ra,56(sp)
 42e:	7442                	ld	s0,48(sp)
 430:	74a2                	ld	s1,40(sp)
 432:	7902                	ld	s2,32(sp)
 434:	69e2                	ld	s3,24(sp)
 436:	6121                	addi	sp,sp,64
 438:	8082                	ret
    x = -xx;
 43a:	40b005bb          	negw	a1,a1
    neg = 1;
 43e:	4885                	li	a7,1
    x = -xx;
 440:	bf8d                	j	3b2 <printint+0x1a>

0000000000000442 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 442:	7119                	addi	sp,sp,-128
 444:	fc86                	sd	ra,120(sp)
 446:	f8a2                	sd	s0,112(sp)
 448:	f4a6                	sd	s1,104(sp)
 44a:	f0ca                	sd	s2,96(sp)
 44c:	ecce                	sd	s3,88(sp)
 44e:	e8d2                	sd	s4,80(sp)
 450:	e4d6                	sd	s5,72(sp)
 452:	e0da                	sd	s6,64(sp)
 454:	fc5e                	sd	s7,56(sp)
 456:	f862                	sd	s8,48(sp)
 458:	f466                	sd	s9,40(sp)
 45a:	f06a                	sd	s10,32(sp)
 45c:	ec6e                	sd	s11,24(sp)
 45e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 460:	0005c903          	lbu	s2,0(a1)
 464:	18090f63          	beqz	s2,602 <vprintf+0x1c0>
 468:	8aaa                	mv	s5,a0
 46a:	8b32                	mv	s6,a2
 46c:	00158493          	addi	s1,a1,1
  state = 0;
 470:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 472:	02500a13          	li	s4,37
      if(c == 'd'){
 476:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 47a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 47e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 482:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 486:	00000b97          	auipc	s7,0x0
 48a:	39ab8b93          	addi	s7,s7,922 # 820 <digits>
 48e:	a839                	j	4ac <vprintf+0x6a>
        putc(fd, c);
 490:	85ca                	mv	a1,s2
 492:	8556                	mv	a0,s5
 494:	00000097          	auipc	ra,0x0
 498:	ee2080e7          	jalr	-286(ra) # 376 <putc>
 49c:	a019                	j	4a2 <vprintf+0x60>
    } else if(state == '%'){
 49e:	01498f63          	beq	s3,s4,4bc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4a2:	0485                	addi	s1,s1,1
 4a4:	fff4c903          	lbu	s2,-1(s1)
 4a8:	14090d63          	beqz	s2,602 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4ac:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4b0:	fe0997e3          	bnez	s3,49e <vprintf+0x5c>
      if(c == '%'){
 4b4:	fd479ee3          	bne	a5,s4,490 <vprintf+0x4e>
        state = '%';
 4b8:	89be                	mv	s3,a5
 4ba:	b7e5                	j	4a2 <vprintf+0x60>
      if(c == 'd'){
 4bc:	05878063          	beq	a5,s8,4fc <vprintf+0xba>
      } else if(c == 'l') {
 4c0:	05978c63          	beq	a5,s9,518 <vprintf+0xd6>
      } else if(c == 'x') {
 4c4:	07a78863          	beq	a5,s10,534 <vprintf+0xf2>
      } else if(c == 'p') {
 4c8:	09b78463          	beq	a5,s11,550 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4cc:	07300713          	li	a4,115
 4d0:	0ce78663          	beq	a5,a4,59c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d4:	06300713          	li	a4,99
 4d8:	0ee78e63          	beq	a5,a4,5d4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4dc:	11478863          	beq	a5,s4,5ec <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4e0:	85d2                	mv	a1,s4
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	e92080e7          	jalr	-366(ra) # 376 <putc>
        putc(fd, c);
 4ec:	85ca                	mv	a1,s2
 4ee:	8556                	mv	a0,s5
 4f0:	00000097          	auipc	ra,0x0
 4f4:	e86080e7          	jalr	-378(ra) # 376 <putc>
      }
      state = 0;
 4f8:	4981                	li	s3,0
 4fa:	b765                	j	4a2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4fc:	008b0913          	addi	s2,s6,8
 500:	4685                	li	a3,1
 502:	4629                	li	a2,10
 504:	000b2583          	lw	a1,0(s6)
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	e8e080e7          	jalr	-370(ra) # 398 <printint>
 512:	8b4a                	mv	s6,s2
      state = 0;
 514:	4981                	li	s3,0
 516:	b771                	j	4a2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 518:	008b0913          	addi	s2,s6,8
 51c:	4681                	li	a3,0
 51e:	4629                	li	a2,10
 520:	000b2583          	lw	a1,0(s6)
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	e72080e7          	jalr	-398(ra) # 398 <printint>
 52e:	8b4a                	mv	s6,s2
      state = 0;
 530:	4981                	li	s3,0
 532:	bf85                	j	4a2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 534:	008b0913          	addi	s2,s6,8
 538:	4681                	li	a3,0
 53a:	4641                	li	a2,16
 53c:	000b2583          	lw	a1,0(s6)
 540:	8556                	mv	a0,s5
 542:	00000097          	auipc	ra,0x0
 546:	e56080e7          	jalr	-426(ra) # 398 <printint>
 54a:	8b4a                	mv	s6,s2
      state = 0;
 54c:	4981                	li	s3,0
 54e:	bf91                	j	4a2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 550:	008b0793          	addi	a5,s6,8
 554:	f8f43423          	sd	a5,-120(s0)
 558:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 55c:	03000593          	li	a1,48
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e14080e7          	jalr	-492(ra) # 376 <putc>
  putc(fd, 'x');
 56a:	85ea                	mv	a1,s10
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e08080e7          	jalr	-504(ra) # 376 <putc>
 576:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 578:	03c9d793          	srli	a5,s3,0x3c
 57c:	97de                	add	a5,a5,s7
 57e:	0007c583          	lbu	a1,0(a5)
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	df2080e7          	jalr	-526(ra) # 376 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 58c:	0992                	slli	s3,s3,0x4
 58e:	397d                	addiw	s2,s2,-1
 590:	fe0914e3          	bnez	s2,578 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 594:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 598:	4981                	li	s3,0
 59a:	b721                	j	4a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 59c:	008b0993          	addi	s3,s6,8
 5a0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5a4:	02090163          	beqz	s2,5c6 <vprintf+0x184>
        while(*s != 0){
 5a8:	00094583          	lbu	a1,0(s2)
 5ac:	c9a1                	beqz	a1,5fc <vprintf+0x1ba>
          putc(fd, *s);
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	dc6080e7          	jalr	-570(ra) # 376 <putc>
          s++;
 5b8:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ba:	00094583          	lbu	a1,0(s2)
 5be:	f9e5                	bnez	a1,5ae <vprintf+0x16c>
        s = va_arg(ap, char*);
 5c0:	8b4e                	mv	s6,s3
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	bdf9                	j	4a2 <vprintf+0x60>
          s = "(null)";
 5c6:	00000917          	auipc	s2,0x0
 5ca:	25290913          	addi	s2,s2,594 # 818 <malloc+0x10c>
        while(*s != 0){
 5ce:	02800593          	li	a1,40
 5d2:	bff1                	j	5ae <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5d4:	008b0913          	addi	s2,s6,8
 5d8:	000b4583          	lbu	a1,0(s6)
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	d98080e7          	jalr	-616(ra) # 376 <putc>
 5e6:	8b4a                	mv	s6,s2
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	bd65                	j	4a2 <vprintf+0x60>
        putc(fd, c);
 5ec:	85d2                	mv	a1,s4
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	d86080e7          	jalr	-634(ra) # 376 <putc>
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b565                	j	4a2 <vprintf+0x60>
        s = va_arg(ap, char*);
 5fc:	8b4e                	mv	s6,s3
      state = 0;
 5fe:	4981                	li	s3,0
 600:	b54d                	j	4a2 <vprintf+0x60>
    }
  }
}
 602:	70e6                	ld	ra,120(sp)
 604:	7446                	ld	s0,112(sp)
 606:	74a6                	ld	s1,104(sp)
 608:	7906                	ld	s2,96(sp)
 60a:	69e6                	ld	s3,88(sp)
 60c:	6a46                	ld	s4,80(sp)
 60e:	6aa6                	ld	s5,72(sp)
 610:	6b06                	ld	s6,64(sp)
 612:	7be2                	ld	s7,56(sp)
 614:	7c42                	ld	s8,48(sp)
 616:	7ca2                	ld	s9,40(sp)
 618:	7d02                	ld	s10,32(sp)
 61a:	6de2                	ld	s11,24(sp)
 61c:	6109                	addi	sp,sp,128
 61e:	8082                	ret

0000000000000620 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 620:	715d                	addi	sp,sp,-80
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	e010                	sd	a2,0(s0)
 62a:	e414                	sd	a3,8(s0)
 62c:	e818                	sd	a4,16(s0)
 62e:	ec1c                	sd	a5,24(s0)
 630:	03043023          	sd	a6,32(s0)
 634:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 638:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 63c:	8622                	mv	a2,s0
 63e:	00000097          	auipc	ra,0x0
 642:	e04080e7          	jalr	-508(ra) # 442 <vprintf>
}
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6161                	addi	sp,sp,80
 64c:	8082                	ret

000000000000064e <printf>:

void
printf(const char *fmt, ...)
{
 64e:	711d                	addi	sp,sp,-96
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	addi	s0,sp,32
 656:	e40c                	sd	a1,8(s0)
 658:	e810                	sd	a2,16(s0)
 65a:	ec14                	sd	a3,24(s0)
 65c:	f018                	sd	a4,32(s0)
 65e:	f41c                	sd	a5,40(s0)
 660:	03043823          	sd	a6,48(s0)
 664:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 668:	00840613          	addi	a2,s0,8
 66c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 670:	85aa                	mv	a1,a0
 672:	4505                	li	a0,1
 674:	00000097          	auipc	ra,0x0
 678:	dce080e7          	jalr	-562(ra) # 442 <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6125                	addi	sp,sp,96
 682:	8082                	ret

0000000000000684 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 684:	1141                	addi	sp,sp,-16
 686:	e422                	sd	s0,8(sp)
 688:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68e:	00000797          	auipc	a5,0x0
 692:	1aa7b783          	ld	a5,426(a5) # 838 <freep>
 696:	a805                	j	6c6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 698:	4618                	lw	a4,8(a2)
 69a:	9db9                	addw	a1,a1,a4
 69c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a0:	6398                	ld	a4,0(a5)
 6a2:	6318                	ld	a4,0(a4)
 6a4:	fee53823          	sd	a4,-16(a0)
 6a8:	a091                	j	6ec <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6aa:	ff852703          	lw	a4,-8(a0)
 6ae:	9e39                	addw	a2,a2,a4
 6b0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6b2:	ff053703          	ld	a4,-16(a0)
 6b6:	e398                	sd	a4,0(a5)
 6b8:	a099                	j	6fe <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ba:	6398                	ld	a4,0(a5)
 6bc:	00e7e463          	bltu	a5,a4,6c4 <free+0x40>
 6c0:	00e6ea63          	bltu	a3,a4,6d4 <free+0x50>
{
 6c4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c6:	fed7fae3          	bgeu	a5,a3,6ba <free+0x36>
 6ca:	6398                	ld	a4,0(a5)
 6cc:	00e6e463          	bltu	a3,a4,6d4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	fee7eae3          	bltu	a5,a4,6c4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6d4:	ff852583          	lw	a1,-8(a0)
 6d8:	6390                	ld	a2,0(a5)
 6da:	02059713          	slli	a4,a1,0x20
 6de:	9301                	srli	a4,a4,0x20
 6e0:	0712                	slli	a4,a4,0x4
 6e2:	9736                	add	a4,a4,a3
 6e4:	fae60ae3          	beq	a2,a4,698 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6e8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ec:	4790                	lw	a2,8(a5)
 6ee:	02061713          	slli	a4,a2,0x20
 6f2:	9301                	srli	a4,a4,0x20
 6f4:	0712                	slli	a4,a4,0x4
 6f6:	973e                	add	a4,a4,a5
 6f8:	fae689e3          	beq	a3,a4,6aa <free+0x26>
  } else
    p->s.ptr = bp;
 6fc:	e394                	sd	a3,0(a5)
  freep = p;
 6fe:	00000717          	auipc	a4,0x0
 702:	12f73d23          	sd	a5,314(a4) # 838 <freep>
}
 706:	6422                	ld	s0,8(sp)
 708:	0141                	addi	sp,sp,16
 70a:	8082                	ret

000000000000070c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 70c:	7139                	addi	sp,sp,-64
 70e:	fc06                	sd	ra,56(sp)
 710:	f822                	sd	s0,48(sp)
 712:	f426                	sd	s1,40(sp)
 714:	f04a                	sd	s2,32(sp)
 716:	ec4e                	sd	s3,24(sp)
 718:	e852                	sd	s4,16(sp)
 71a:	e456                	sd	s5,8(sp)
 71c:	e05a                	sd	s6,0(sp)
 71e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 720:	02051493          	slli	s1,a0,0x20
 724:	9081                	srli	s1,s1,0x20
 726:	04bd                	addi	s1,s1,15
 728:	8091                	srli	s1,s1,0x4
 72a:	0014899b          	addiw	s3,s1,1
 72e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 730:	00000517          	auipc	a0,0x0
 734:	10853503          	ld	a0,264(a0) # 838 <freep>
 738:	c515                	beqz	a0,764 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 73a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 73c:	4798                	lw	a4,8(a5)
 73e:	02977f63          	bgeu	a4,s1,77c <malloc+0x70>
 742:	8a4e                	mv	s4,s3
 744:	0009871b          	sext.w	a4,s3
 748:	6685                	lui	a3,0x1
 74a:	00d77363          	bgeu	a4,a3,750 <malloc+0x44>
 74e:	6a05                	lui	s4,0x1
 750:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 754:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 758:	00000917          	auipc	s2,0x0
 75c:	0e090913          	addi	s2,s2,224 # 838 <freep>
  if(p == (char*)-1)
 760:	5afd                	li	s5,-1
 762:	a88d                	j	7d4 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 764:	00000797          	auipc	a5,0x0
 768:	0dc78793          	addi	a5,a5,220 # 840 <base>
 76c:	00000717          	auipc	a4,0x0
 770:	0cf73623          	sd	a5,204(a4) # 838 <freep>
 774:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 776:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 77a:	b7e1                	j	742 <malloc+0x36>
      if(p->s.size == nunits)
 77c:	02e48b63          	beq	s1,a4,7b2 <malloc+0xa6>
        p->s.size -= nunits;
 780:	4137073b          	subw	a4,a4,s3
 784:	c798                	sw	a4,8(a5)
        p += p->s.size;
 786:	1702                	slli	a4,a4,0x20
 788:	9301                	srli	a4,a4,0x20
 78a:	0712                	slli	a4,a4,0x4
 78c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 78e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 792:	00000717          	auipc	a4,0x0
 796:	0aa73323          	sd	a0,166(a4) # 838 <freep>
      return (void*)(p + 1);
 79a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 79e:	70e2                	ld	ra,56(sp)
 7a0:	7442                	ld	s0,48(sp)
 7a2:	74a2                	ld	s1,40(sp)
 7a4:	7902                	ld	s2,32(sp)
 7a6:	69e2                	ld	s3,24(sp)
 7a8:	6a42                	ld	s4,16(sp)
 7aa:	6aa2                	ld	s5,8(sp)
 7ac:	6b02                	ld	s6,0(sp)
 7ae:	6121                	addi	sp,sp,64
 7b0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7b2:	6398                	ld	a4,0(a5)
 7b4:	e118                	sd	a4,0(a0)
 7b6:	bff1                	j	792 <malloc+0x86>
  hp->s.size = nu;
 7b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7bc:	0541                	addi	a0,a0,16
 7be:	00000097          	auipc	ra,0x0
 7c2:	ec6080e7          	jalr	-314(ra) # 684 <free>
  return freep;
 7c6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7ca:	d971                	beqz	a0,79e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ce:	4798                	lw	a4,8(a5)
 7d0:	fa9776e3          	bgeu	a4,s1,77c <malloc+0x70>
    if(p == freep)
 7d4:	00093703          	ld	a4,0(s2)
 7d8:	853e                	mv	a0,a5
 7da:	fef719e3          	bne	a4,a5,7cc <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7de:	8552                	mv	a0,s4
 7e0:	00000097          	auipc	ra,0x0
 7e4:	b5e080e7          	jalr	-1186(ra) # 33e <sbrk>
  if(p == (char*)-1)
 7e8:	fd5518e3          	bne	a0,s5,7b8 <malloc+0xac>
        return 0;
 7ec:	4501                	li	a0,0
 7ee:	bf45                	j	79e <malloc+0x92>
