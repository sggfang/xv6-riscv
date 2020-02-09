
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <source>:
#include "kernel/types.h"
#include "user/user.h"

void source() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
  int i;
  for (i = 2; i < 36; i++) {
   a:	4789                	li	a5,2
   c:	fcf42e23          	sw	a5,-36(s0)
  10:	02300493          	li	s1,35
    write(1, &i, sizeof(i));
  14:	4611                	li	a2,4
  16:	fdc40593          	addi	a1,s0,-36
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	39e080e7          	jalr	926(ra) # 3ba <write>
  for (i = 2; i < 36; i++) {
  24:	fdc42783          	lw	a5,-36(s0)
  28:	2785                	addiw	a5,a5,1
  2a:	0007871b          	sext.w	a4,a5
  2e:	fcf42e23          	sw	a5,-36(s0)
  32:	fee4d1e3          	bge	s1,a4,14 <source+0x14>
  }
}
  36:	70a2                	ld	ra,40(sp)
  38:	7402                	ld	s0,32(sp)
  3a:	64e2                	ld	s1,24(sp)
  3c:	6145                	addi	sp,sp,48
  3e:	8082                	ret

0000000000000040 <cull>:

void cull(int p) {
  40:	7179                	addi	sp,sp,-48
  42:	f406                	sd	ra,40(sp)
  44:	f022                	sd	s0,32(sp)
  46:	ec26                	sd	s1,24(sp)
  48:	1800                	addi	s0,sp,48
  4a:	84aa                	mv	s1,a0
  int n;
  while (read(0, &n, sizeof(n))) {
  4c:	4611                	li	a2,4
  4e:	fdc40593          	addi	a1,s0,-36
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	35e080e7          	jalr	862(ra) # 3b2 <read>
  5c:	cd19                	beqz	a0,7a <cull+0x3a>
    if (n % p != 0) {
  5e:	fdc42783          	lw	a5,-36(s0)
  62:	0297e7bb          	remw	a5,a5,s1
  66:	d3fd                	beqz	a5,4c <cull+0xc>
      write(1, &n, sizeof(n));
  68:	4611                	li	a2,4
  6a:	fdc40593          	addi	a1,s0,-36
  6e:	4505                	li	a0,1
  70:	00000097          	auipc	ra,0x0
  74:	34a080e7          	jalr	842(ra) # 3ba <write>
  78:	bfd1                	j	4c <cull+0xc>
    }
  }
}
  7a:	70a2                	ld	ra,40(sp)
  7c:	7402                	ld	s0,32(sp)
  7e:	64e2                	ld	s1,24(sp)
  80:	6145                	addi	sp,sp,48
  82:	8082                	ret

0000000000000084 <redirect>:

void redirect(int k, int pd[]) {
  84:	1101                	addi	sp,sp,-32
  86:	ec06                	sd	ra,24(sp)
  88:	e822                	sd	s0,16(sp)
  8a:	e426                	sd	s1,8(sp)
  8c:	e04a                	sd	s2,0(sp)
  8e:	1000                	addi	s0,sp,32
  90:	84aa                	mv	s1,a0
  92:	892e                	mv	s2,a1
  close(k);
  94:	00000097          	auipc	ra,0x0
  98:	32e080e7          	jalr	814(ra) # 3c2 <close>
  dup(pd[k]);
  9c:	048a                	slli	s1,s1,0x2
  9e:	94ca                	add	s1,s1,s2
  a0:	4088                	lw	a0,0(s1)
  a2:	00000097          	auipc	ra,0x0
  a6:	370080e7          	jalr	880(ra) # 412 <dup>
  close(pd[0]);
  aa:	00092503          	lw	a0,0(s2)
  ae:	00000097          	auipc	ra,0x0
  b2:	314080e7          	jalr	788(ra) # 3c2 <close>
  close(pd[1]);
  b6:	00492503          	lw	a0,4(s2)
  ba:	00000097          	auipc	ra,0x0
  be:	308080e7          	jalr	776(ra) # 3c2 <close>
}
  c2:	60e2                	ld	ra,24(sp)
  c4:	6442                	ld	s0,16(sp)
  c6:	64a2                	ld	s1,8(sp)
  c8:	6902                	ld	s2,0(sp)
  ca:	6105                	addi	sp,sp,32
  cc:	8082                	ret

00000000000000ce <sink>:

void sink() {
  ce:	1101                	addi	sp,sp,-32
  d0:	ec06                	sd	ra,24(sp)
  d2:	e822                	sd	s0,16(sp)
  d4:	1000                	addi	s0,sp,32
  int pd[2];
  int p;

  if (read(0, &p, sizeof(p))) {
  d6:	4611                	li	a2,4
  d8:	fe440593          	addi	a1,s0,-28
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	2d4080e7          	jalr	724(ra) # 3b2 <read>
  e6:	e509                	bnez	a0,f0 <sink+0x22>
    } else {
      redirect(1, pd);
      cull(p);
    }
  }
}
  e8:	60e2                	ld	ra,24(sp)
  ea:	6442                	ld	s0,16(sp)
  ec:	6105                	addi	sp,sp,32
  ee:	8082                	ret
    printf("prime %d\n", p);
  f0:	fe442583          	lw	a1,-28(s0)
  f4:	00000517          	auipc	a0,0x0
  f8:	7e450513          	addi	a0,a0,2020 # 8d8 <malloc+0xe8>
  fc:	00000097          	auipc	ra,0x0
 100:	636080e7          	jalr	1590(ra) # 732 <printf>
    pipe(pd);
 104:	fe840513          	addi	a0,s0,-24
 108:	00000097          	auipc	ra,0x0
 10c:	2a2080e7          	jalr	674(ra) # 3aa <pipe>
    if (fork()) {
 110:	00000097          	auipc	ra,0x0
 114:	282080e7          	jalr	642(ra) # 392 <fork>
 118:	cd09                	beqz	a0,132 <sink+0x64>
      redirect(0, pd);
 11a:	fe840593          	addi	a1,s0,-24
 11e:	4501                	li	a0,0
 120:	00000097          	auipc	ra,0x0
 124:	f64080e7          	jalr	-156(ra) # 84 <redirect>
      sink();
 128:	00000097          	auipc	ra,0x0
 12c:	fa6080e7          	jalr	-90(ra) # ce <sink>
 130:	bf65                	j	e8 <sink+0x1a>
      redirect(1, pd);
 132:	fe840593          	addi	a1,s0,-24
 136:	4505                	li	a0,1
 138:	00000097          	auipc	ra,0x0
 13c:	f4c080e7          	jalr	-180(ra) # 84 <redirect>
      cull(p);
 140:	fe442503          	lw	a0,-28(s0)
 144:	00000097          	auipc	ra,0x0
 148:	efc080e7          	jalr	-260(ra) # 40 <cull>
}
 14c:	bf71                	j	e8 <sink+0x1a>

000000000000014e <main>:

int main(int argc, char *argv[]) {
 14e:	1101                	addi	sp,sp,-32
 150:	ec06                	sd	ra,24(sp)
 152:	e822                	sd	s0,16(sp)
 154:	1000                	addi	s0,sp,32

  int pd[2];
  pipe(pd);
 156:	fe840513          	addi	a0,s0,-24
 15a:	00000097          	auipc	ra,0x0
 15e:	250080e7          	jalr	592(ra) # 3aa <pipe>

  if (fork()) {
 162:	00000097          	auipc	ra,0x0
 166:	230080e7          	jalr	560(ra) # 392 <fork>
 16a:	c10d                	beqz	a0,18c <main+0x3e>
    redirect(0, pd);
 16c:	fe840593          	addi	a1,s0,-24
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	f12080e7          	jalr	-238(ra) # 84 <redirect>
    sink();
 17a:	00000097          	auipc	ra,0x0
 17e:	f54080e7          	jalr	-172(ra) # ce <sink>
  } else {
    redirect(1, pd);
    source();
  }

  exit(0);
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	216080e7          	jalr	534(ra) # 39a <exit>
    redirect(1, pd);
 18c:	fe840593          	addi	a1,s0,-24
 190:	4505                	li	a0,1
 192:	00000097          	auipc	ra,0x0
 196:	ef2080e7          	jalr	-270(ra) # 84 <redirect>
    source();
 19a:	00000097          	auipc	ra,0x0
 19e:	e66080e7          	jalr	-410(ra) # 0 <source>
 1a2:	b7c5                	j	182 <main+0x34>

00000000000001a4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1aa:	87aa                	mv	a5,a0
 1ac:	0585                	addi	a1,a1,1
 1ae:	0785                	addi	a5,a5,1
 1b0:	fff5c703          	lbu	a4,-1(a1)
 1b4:	fee78fa3          	sb	a4,-1(a5)
 1b8:	fb75                	bnez	a4,1ac <strcpy+0x8>
    ;
  return os;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb91                	beqz	a5,1de <strcmp+0x1e>
 1cc:	0005c703          	lbu	a4,0(a1)
 1d0:	00f71763          	bne	a4,a5,1de <strcmp+0x1e>
    p++, q++;
 1d4:	0505                	addi	a0,a0,1
 1d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1d8:	00054783          	lbu	a5,0(a0)
 1dc:	fbe5                	bnez	a5,1cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1de:	0005c503          	lbu	a0,0(a1)
}
 1e2:	40a7853b          	subw	a0,a5,a0
 1e6:	6422                	ld	s0,8(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret

00000000000001ec <strlen>:

uint
strlen(const char *s)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f2:	00054783          	lbu	a5,0(a0)
 1f6:	cf91                	beqz	a5,212 <strlen+0x26>
 1f8:	0505                	addi	a0,a0,1
 1fa:	87aa                	mv	a5,a0
 1fc:	4685                	li	a3,1
 1fe:	9e89                	subw	a3,a3,a0
 200:	00f6853b          	addw	a0,a3,a5
 204:	0785                	addi	a5,a5,1
 206:	fff7c703          	lbu	a4,-1(a5)
 20a:	fb7d                	bnez	a4,200 <strlen+0x14>
    ;
  return n;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
  for(n = 0; s[n]; n++)
 212:	4501                	li	a0,0
 214:	bfe5                	j	20c <strlen+0x20>

0000000000000216 <memset>:

void*
memset(void *dst, int c, uint n)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21c:	ce09                	beqz	a2,236 <memset+0x20>
 21e:	87aa                	mv	a5,a0
 220:	fff6071b          	addiw	a4,a2,-1
 224:	1702                	slli	a4,a4,0x20
 226:	9301                	srli	a4,a4,0x20
 228:	0705                	addi	a4,a4,1
 22a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 22c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 230:	0785                	addi	a5,a5,1
 232:	fee79de3          	bne	a5,a4,22c <memset+0x16>
  }
  return dst;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret

000000000000023c <strchr>:

char*
strchr(const char *s, char c)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  for(; *s; s++)
 242:	00054783          	lbu	a5,0(a0)
 246:	cb99                	beqz	a5,25c <strchr+0x20>
    if(*s == c)
 248:	00f58763          	beq	a1,a5,256 <strchr+0x1a>
  for(; *s; s++)
 24c:	0505                	addi	a0,a0,1
 24e:	00054783          	lbu	a5,0(a0)
 252:	fbfd                	bnez	a5,248 <strchr+0xc>
      return (char*)s;
  return 0;
 254:	4501                	li	a0,0
}
 256:	6422                	ld	s0,8(sp)
 258:	0141                	addi	sp,sp,16
 25a:	8082                	ret
  return 0;
 25c:	4501                	li	a0,0
 25e:	bfe5                	j	256 <strchr+0x1a>

0000000000000260 <gets>:

char*
gets(char *buf, int max)
{
 260:	711d                	addi	sp,sp,-96
 262:	ec86                	sd	ra,88(sp)
 264:	e8a2                	sd	s0,80(sp)
 266:	e4a6                	sd	s1,72(sp)
 268:	e0ca                	sd	s2,64(sp)
 26a:	fc4e                	sd	s3,56(sp)
 26c:	f852                	sd	s4,48(sp)
 26e:	f456                	sd	s5,40(sp)
 270:	f05a                	sd	s6,32(sp)
 272:	ec5e                	sd	s7,24(sp)
 274:	1080                	addi	s0,sp,96
 276:	8baa                	mv	s7,a0
 278:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 27a:	892a                	mv	s2,a0
 27c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27e:	4aa9                	li	s5,10
 280:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 282:	89a6                	mv	s3,s1
 284:	2485                	addiw	s1,s1,1
 286:	0344d863          	bge	s1,s4,2b6 <gets+0x56>
    cc = read(0, &c, 1);
 28a:	4605                	li	a2,1
 28c:	faf40593          	addi	a1,s0,-81
 290:	4501                	li	a0,0
 292:	00000097          	auipc	ra,0x0
 296:	120080e7          	jalr	288(ra) # 3b2 <read>
    if(cc < 1)
 29a:	00a05e63          	blez	a0,2b6 <gets+0x56>
    buf[i++] = c;
 29e:	faf44783          	lbu	a5,-81(s0)
 2a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a6:	01578763          	beq	a5,s5,2b4 <gets+0x54>
 2aa:	0905                	addi	s2,s2,1
 2ac:	fd679be3          	bne	a5,s6,282 <gets+0x22>
  for(i=0; i+1 < max; ){
 2b0:	89a6                	mv	s3,s1
 2b2:	a011                	j	2b6 <gets+0x56>
 2b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b6:	99de                	add	s3,s3,s7
 2b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 2bc:	855e                	mv	a0,s7
 2be:	60e6                	ld	ra,88(sp)
 2c0:	6446                	ld	s0,80(sp)
 2c2:	64a6                	ld	s1,72(sp)
 2c4:	6906                	ld	s2,64(sp)
 2c6:	79e2                	ld	s3,56(sp)
 2c8:	7a42                	ld	s4,48(sp)
 2ca:	7aa2                	ld	s5,40(sp)
 2cc:	7b02                	ld	s6,32(sp)
 2ce:	6be2                	ld	s7,24(sp)
 2d0:	6125                	addi	sp,sp,96
 2d2:	8082                	ret

00000000000002d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d4:	1101                	addi	sp,sp,-32
 2d6:	ec06                	sd	ra,24(sp)
 2d8:	e822                	sd	s0,16(sp)
 2da:	e426                	sd	s1,8(sp)
 2dc:	e04a                	sd	s2,0(sp)
 2de:	1000                	addi	s0,sp,32
 2e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e2:	4581                	li	a1,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	0f6080e7          	jalr	246(ra) # 3da <open>
  if(fd < 0)
 2ec:	02054563          	bltz	a0,316 <stat+0x42>
 2f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f2:	85ca                	mv	a1,s2
 2f4:	00000097          	auipc	ra,0x0
 2f8:	0fe080e7          	jalr	254(ra) # 3f2 <fstat>
 2fc:	892a                	mv	s2,a0
  close(fd);
 2fe:	8526                	mv	a0,s1
 300:	00000097          	auipc	ra,0x0
 304:	0c2080e7          	jalr	194(ra) # 3c2 <close>
  return r;
}
 308:	854a                	mv	a0,s2
 30a:	60e2                	ld	ra,24(sp)
 30c:	6442                	ld	s0,16(sp)
 30e:	64a2                	ld	s1,8(sp)
 310:	6902                	ld	s2,0(sp)
 312:	6105                	addi	sp,sp,32
 314:	8082                	ret
    return -1;
 316:	597d                	li	s2,-1
 318:	bfc5                	j	308 <stat+0x34>

000000000000031a <atoi>:

int
atoi(const char *s)
{
 31a:	1141                	addi	sp,sp,-16
 31c:	e422                	sd	s0,8(sp)
 31e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 320:	00054603          	lbu	a2,0(a0)
 324:	fd06079b          	addiw	a5,a2,-48
 328:	0ff7f793          	andi	a5,a5,255
 32c:	4725                	li	a4,9
 32e:	02f76963          	bltu	a4,a5,360 <atoi+0x46>
 332:	86aa                	mv	a3,a0
  n = 0;
 334:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 336:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 338:	0685                	addi	a3,a3,1
 33a:	0025179b          	slliw	a5,a0,0x2
 33e:	9fa9                	addw	a5,a5,a0
 340:	0017979b          	slliw	a5,a5,0x1
 344:	9fb1                	addw	a5,a5,a2
 346:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 34a:	0006c603          	lbu	a2,0(a3)
 34e:	fd06071b          	addiw	a4,a2,-48
 352:	0ff77713          	andi	a4,a4,255
 356:	fee5f1e3          	bgeu	a1,a4,338 <atoi+0x1e>
  return n;
}
 35a:	6422                	ld	s0,8(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret
  n = 0;
 360:	4501                	li	a0,0
 362:	bfe5                	j	35a <atoi+0x40>

0000000000000364 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 364:	1141                	addi	sp,sp,-16
 366:	e422                	sd	s0,8(sp)
 368:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 36a:	02c05163          	blez	a2,38c <memmove+0x28>
 36e:	fff6071b          	addiw	a4,a2,-1
 372:	1702                	slli	a4,a4,0x20
 374:	9301                	srli	a4,a4,0x20
 376:	0705                	addi	a4,a4,1
 378:	972a                	add	a4,a4,a0
  dst = vdst;
 37a:	87aa                	mv	a5,a0
    *dst++ = *src++;
 37c:	0585                	addi	a1,a1,1
 37e:	0785                	addi	a5,a5,1
 380:	fff5c683          	lbu	a3,-1(a1)
 384:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 388:	fee79ae3          	bne	a5,a4,37c <memmove+0x18>
  return vdst;
}
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 392:	4885                	li	a7,1
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <exit>:
.global exit
exit:
 li a7, SYS_exit
 39a:	4889                	li	a7,2
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a2:	488d                	li	a7,3
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3aa:	4891                	li	a7,4
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <read>:
.global read
read:
 li a7, SYS_read
 3b2:	4895                	li	a7,5
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <write>:
.global write
write:
 li a7, SYS_write
 3ba:	48c1                	li	a7,16
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <close>:
.global close
close:
 li a7, SYS_close
 3c2:	48d5                	li	a7,21
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ca:	4899                	li	a7,6
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d2:	489d                	li	a7,7
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <open>:
.global open
open:
 li a7, SYS_open
 3da:	48bd                	li	a7,15
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e2:	48c5                	li	a7,17
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ea:	48c9                	li	a7,18
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f2:	48a1                	li	a7,8
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <link>:
.global link
link:
 li a7, SYS_link
 3fa:	48cd                	li	a7,19
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 402:	48d1                	li	a7,20
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40a:	48a5                	li	a7,9
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <dup>:
.global dup
dup:
 li a7, SYS_dup
 412:	48a9                	li	a7,10
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41a:	48ad                	li	a7,11
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 422:	48b1                	li	a7,12
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42a:	48b5                	li	a7,13
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 432:	48b9                	li	a7,14
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 43a:	48d9                	li	a7,22
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <crash>:
.global crash
crash:
 li a7, SYS_crash
 442:	48dd                	li	a7,23
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mount>:
.global mount
mount:
 li a7, SYS_mount
 44a:	48e1                	li	a7,24
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <umount>:
.global umount
umount:
 li a7, SYS_umount
 452:	48e5                	li	a7,25
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45a:	1101                	addi	sp,sp,-32
 45c:	ec06                	sd	ra,24(sp)
 45e:	e822                	sd	s0,16(sp)
 460:	1000                	addi	s0,sp,32
 462:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 466:	4605                	li	a2,1
 468:	fef40593          	addi	a1,s0,-17
 46c:	00000097          	auipc	ra,0x0
 470:	f4e080e7          	jalr	-178(ra) # 3ba <write>
}
 474:	60e2                	ld	ra,24(sp)
 476:	6442                	ld	s0,16(sp)
 478:	6105                	addi	sp,sp,32
 47a:	8082                	ret

000000000000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	7139                	addi	sp,sp,-64
 47e:	fc06                	sd	ra,56(sp)
 480:	f822                	sd	s0,48(sp)
 482:	f426                	sd	s1,40(sp)
 484:	f04a                	sd	s2,32(sp)
 486:	ec4e                	sd	s3,24(sp)
 488:	0080                	addi	s0,sp,64
 48a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48c:	c299                	beqz	a3,492 <printint+0x16>
 48e:	0805c863          	bltz	a1,51e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 492:	2581                	sext.w	a1,a1
  neg = 0;
 494:	4881                	li	a7,0
 496:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 49a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 49c:	2601                	sext.w	a2,a2
 49e:	00000517          	auipc	a0,0x0
 4a2:	45250513          	addi	a0,a0,1106 # 8f0 <digits>
 4a6:	883a                	mv	a6,a4
 4a8:	2705                	addiw	a4,a4,1
 4aa:	02c5f7bb          	remuw	a5,a1,a2
 4ae:	1782                	slli	a5,a5,0x20
 4b0:	9381                	srli	a5,a5,0x20
 4b2:	97aa                	add	a5,a5,a0
 4b4:	0007c783          	lbu	a5,0(a5)
 4b8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4bc:	0005879b          	sext.w	a5,a1
 4c0:	02c5d5bb          	divuw	a1,a1,a2
 4c4:	0685                	addi	a3,a3,1
 4c6:	fec7f0e3          	bgeu	a5,a2,4a6 <printint+0x2a>
  if(neg)
 4ca:	00088b63          	beqz	a7,4e0 <printint+0x64>
    buf[i++] = '-';
 4ce:	fd040793          	addi	a5,s0,-48
 4d2:	973e                	add	a4,a4,a5
 4d4:	02d00793          	li	a5,45
 4d8:	fef70823          	sb	a5,-16(a4)
 4dc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4e0:	02e05863          	blez	a4,510 <printint+0x94>
 4e4:	fc040793          	addi	a5,s0,-64
 4e8:	00e78933          	add	s2,a5,a4
 4ec:	fff78993          	addi	s3,a5,-1
 4f0:	99ba                	add	s3,s3,a4
 4f2:	377d                	addiw	a4,a4,-1
 4f4:	1702                	slli	a4,a4,0x20
 4f6:	9301                	srli	a4,a4,0x20
 4f8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4fc:	fff94583          	lbu	a1,-1(s2)
 500:	8526                	mv	a0,s1
 502:	00000097          	auipc	ra,0x0
 506:	f58080e7          	jalr	-168(ra) # 45a <putc>
  while(--i >= 0)
 50a:	197d                	addi	s2,s2,-1
 50c:	ff3918e3          	bne	s2,s3,4fc <printint+0x80>
}
 510:	70e2                	ld	ra,56(sp)
 512:	7442                	ld	s0,48(sp)
 514:	74a2                	ld	s1,40(sp)
 516:	7902                	ld	s2,32(sp)
 518:	69e2                	ld	s3,24(sp)
 51a:	6121                	addi	sp,sp,64
 51c:	8082                	ret
    x = -xx;
 51e:	40b005bb          	negw	a1,a1
    neg = 1;
 522:	4885                	li	a7,1
    x = -xx;
 524:	bf8d                	j	496 <printint+0x1a>

0000000000000526 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 526:	7119                	addi	sp,sp,-128
 528:	fc86                	sd	ra,120(sp)
 52a:	f8a2                	sd	s0,112(sp)
 52c:	f4a6                	sd	s1,104(sp)
 52e:	f0ca                	sd	s2,96(sp)
 530:	ecce                	sd	s3,88(sp)
 532:	e8d2                	sd	s4,80(sp)
 534:	e4d6                	sd	s5,72(sp)
 536:	e0da                	sd	s6,64(sp)
 538:	fc5e                	sd	s7,56(sp)
 53a:	f862                	sd	s8,48(sp)
 53c:	f466                	sd	s9,40(sp)
 53e:	f06a                	sd	s10,32(sp)
 540:	ec6e                	sd	s11,24(sp)
 542:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 544:	0005c903          	lbu	s2,0(a1)
 548:	18090f63          	beqz	s2,6e6 <vprintf+0x1c0>
 54c:	8aaa                	mv	s5,a0
 54e:	8b32                	mv	s6,a2
 550:	00158493          	addi	s1,a1,1
  state = 0;
 554:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 556:	02500a13          	li	s4,37
      if(c == 'd'){
 55a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 55e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 562:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 566:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56a:	00000b97          	auipc	s7,0x0
 56e:	386b8b93          	addi	s7,s7,902 # 8f0 <digits>
 572:	a839                	j	590 <vprintf+0x6a>
        putc(fd, c);
 574:	85ca                	mv	a1,s2
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	ee2080e7          	jalr	-286(ra) # 45a <putc>
 580:	a019                	j	586 <vprintf+0x60>
    } else if(state == '%'){
 582:	01498f63          	beq	s3,s4,5a0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 586:	0485                	addi	s1,s1,1
 588:	fff4c903          	lbu	s2,-1(s1)
 58c:	14090d63          	beqz	s2,6e6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 590:	0009079b          	sext.w	a5,s2
    if(state == 0){
 594:	fe0997e3          	bnez	s3,582 <vprintf+0x5c>
      if(c == '%'){
 598:	fd479ee3          	bne	a5,s4,574 <vprintf+0x4e>
        state = '%';
 59c:	89be                	mv	s3,a5
 59e:	b7e5                	j	586 <vprintf+0x60>
      if(c == 'd'){
 5a0:	05878063          	beq	a5,s8,5e0 <vprintf+0xba>
      } else if(c == 'l') {
 5a4:	05978c63          	beq	a5,s9,5fc <vprintf+0xd6>
      } else if(c == 'x') {
 5a8:	07a78863          	beq	a5,s10,618 <vprintf+0xf2>
      } else if(c == 'p') {
 5ac:	09b78463          	beq	a5,s11,634 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5b0:	07300713          	li	a4,115
 5b4:	0ce78663          	beq	a5,a4,680 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5b8:	06300713          	li	a4,99
 5bc:	0ee78e63          	beq	a5,a4,6b8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5c0:	11478863          	beq	a5,s4,6d0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5c4:	85d2                	mv	a1,s4
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	e92080e7          	jalr	-366(ra) # 45a <putc>
        putc(fd, c);
 5d0:	85ca                	mv	a1,s2
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e86080e7          	jalr	-378(ra) # 45a <putc>
      }
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b765                	j	586 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5e0:	008b0913          	addi	s2,s6,8
 5e4:	4685                	li	a3,1
 5e6:	4629                	li	a2,10
 5e8:	000b2583          	lw	a1,0(s6)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e8e080e7          	jalr	-370(ra) # 47c <printint>
 5f6:	8b4a                	mv	s6,s2
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b771                	j	586 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fc:	008b0913          	addi	s2,s6,8
 600:	4681                	li	a3,0
 602:	4629                	li	a2,10
 604:	000b2583          	lw	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	e72080e7          	jalr	-398(ra) # 47c <printint>
 612:	8b4a                	mv	s6,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bf85                	j	586 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 618:	008b0913          	addi	s2,s6,8
 61c:	4681                	li	a3,0
 61e:	4641                	li	a2,16
 620:	000b2583          	lw	a1,0(s6)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	e56080e7          	jalr	-426(ra) # 47c <printint>
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	bf91                	j	586 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 634:	008b0793          	addi	a5,s6,8
 638:	f8f43423          	sd	a5,-120(s0)
 63c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 640:	03000593          	li	a1,48
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e14080e7          	jalr	-492(ra) # 45a <putc>
  putc(fd, 'x');
 64e:	85ea                	mv	a1,s10
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e08080e7          	jalr	-504(ra) # 45a <putc>
 65a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65c:	03c9d793          	srli	a5,s3,0x3c
 660:	97de                	add	a5,a5,s7
 662:	0007c583          	lbu	a1,0(a5)
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	df2080e7          	jalr	-526(ra) # 45a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 670:	0992                	slli	s3,s3,0x4
 672:	397d                	addiw	s2,s2,-1
 674:	fe0914e3          	bnez	s2,65c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 678:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 67c:	4981                	li	s3,0
 67e:	b721                	j	586 <vprintf+0x60>
        s = va_arg(ap, char*);
 680:	008b0993          	addi	s3,s6,8
 684:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 688:	02090163          	beqz	s2,6aa <vprintf+0x184>
        while(*s != 0){
 68c:	00094583          	lbu	a1,0(s2)
 690:	c9a1                	beqz	a1,6e0 <vprintf+0x1ba>
          putc(fd, *s);
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	dc6080e7          	jalr	-570(ra) # 45a <putc>
          s++;
 69c:	0905                	addi	s2,s2,1
        while(*s != 0){
 69e:	00094583          	lbu	a1,0(s2)
 6a2:	f9e5                	bnez	a1,692 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6a4:	8b4e                	mv	s6,s3
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bdf9                	j	586 <vprintf+0x60>
          s = "(null)";
 6aa:	00000917          	auipc	s2,0x0
 6ae:	23e90913          	addi	s2,s2,574 # 8e8 <malloc+0xf8>
        while(*s != 0){
 6b2:	02800593          	li	a1,40
 6b6:	bff1                	j	692 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6b8:	008b0913          	addi	s2,s6,8
 6bc:	000b4583          	lbu	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	d98080e7          	jalr	-616(ra) # 45a <putc>
 6ca:	8b4a                	mv	s6,s2
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bd65                	j	586 <vprintf+0x60>
        putc(fd, c);
 6d0:	85d2                	mv	a1,s4
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d86080e7          	jalr	-634(ra) # 45a <putc>
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b565                	j	586 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e0:	8b4e                	mv	s6,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b54d                	j	586 <vprintf+0x60>
    }
  }
}
 6e6:	70e6                	ld	ra,120(sp)
 6e8:	7446                	ld	s0,112(sp)
 6ea:	74a6                	ld	s1,104(sp)
 6ec:	7906                	ld	s2,96(sp)
 6ee:	69e6                	ld	s3,88(sp)
 6f0:	6a46                	ld	s4,80(sp)
 6f2:	6aa6                	ld	s5,72(sp)
 6f4:	6b06                	ld	s6,64(sp)
 6f6:	7be2                	ld	s7,56(sp)
 6f8:	7c42                	ld	s8,48(sp)
 6fa:	7ca2                	ld	s9,40(sp)
 6fc:	7d02                	ld	s10,32(sp)
 6fe:	6de2                	ld	s11,24(sp)
 700:	6109                	addi	sp,sp,128
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	00000097          	auipc	ra,0x0
 726:	e04080e7          	jalr	-508(ra) # 526 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	00000097          	auipc	ra,0x0
 75c:	dce080e7          	jalr	-562(ra) # 526 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e422                	sd	s0,8(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00000797          	auipc	a5,0x0
 776:	1967b783          	ld	a5,406(a5) # 908 <freep>
 77a:	a805                	j	7aa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77c:	4618                	lw	a4,8(a2)
 77e:	9db9                	addw	a1,a1,a4
 780:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	6398                	ld	a4,0(a5)
 786:	6318                	ld	a4,0(a4)
 788:	fee53823          	sd	a4,-16(a0)
 78c:	a091                	j	7d0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78e:	ff852703          	lw	a4,-8(a0)
 792:	9e39                	addw	a2,a2,a4
 794:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 796:	ff053703          	ld	a4,-16(a0)
 79a:	e398                	sd	a4,0(a5)
 79c:	a099                	j	7e2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79e:	6398                	ld	a4,0(a5)
 7a0:	00e7e463          	bltu	a5,a4,7a8 <free+0x40>
 7a4:	00e6ea63          	bltu	a3,a4,7b8 <free+0x50>
{
 7a8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	fed7fae3          	bgeu	a5,a3,79e <free+0x36>
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e6e463          	bltu	a3,a4,7b8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b4:	fee7eae3          	bltu	a5,a4,7a8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7b8:	ff852583          	lw	a1,-8(a0)
 7bc:	6390                	ld	a2,0(a5)
 7be:	02059713          	slli	a4,a1,0x20
 7c2:	9301                	srli	a4,a4,0x20
 7c4:	0712                	slli	a4,a4,0x4
 7c6:	9736                	add	a4,a4,a3
 7c8:	fae60ae3          	beq	a2,a4,77c <free+0x14>
    bp->s.ptr = p->s.ptr;
 7cc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d0:	4790                	lw	a2,8(a5)
 7d2:	02061713          	slli	a4,a2,0x20
 7d6:	9301                	srli	a4,a4,0x20
 7d8:	0712                	slli	a4,a4,0x4
 7da:	973e                	add	a4,a4,a5
 7dc:	fae689e3          	beq	a3,a4,78e <free+0x26>
  } else
    p->s.ptr = bp;
 7e0:	e394                	sd	a3,0(a5)
  freep = p;
 7e2:	00000717          	auipc	a4,0x0
 7e6:	12f73323          	sd	a5,294(a4) # 908 <freep>
}
 7ea:	6422                	ld	s0,8(sp)
 7ec:	0141                	addi	sp,sp,16
 7ee:	8082                	ret

00000000000007f0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f0:	7139                	addi	sp,sp,-64
 7f2:	fc06                	sd	ra,56(sp)
 7f4:	f822                	sd	s0,48(sp)
 7f6:	f426                	sd	s1,40(sp)
 7f8:	f04a                	sd	s2,32(sp)
 7fa:	ec4e                	sd	s3,24(sp)
 7fc:	e852                	sd	s4,16(sp)
 7fe:	e456                	sd	s5,8(sp)
 800:	e05a                	sd	s6,0(sp)
 802:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 804:	02051493          	slli	s1,a0,0x20
 808:	9081                	srli	s1,s1,0x20
 80a:	04bd                	addi	s1,s1,15
 80c:	8091                	srli	s1,s1,0x4
 80e:	0014899b          	addiw	s3,s1,1
 812:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 814:	00000517          	auipc	a0,0x0
 818:	0f453503          	ld	a0,244(a0) # 908 <freep>
 81c:	c515                	beqz	a0,848 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	02977f63          	bgeu	a4,s1,860 <malloc+0x70>
 826:	8a4e                	mv	s4,s3
 828:	0009871b          	sext.w	a4,s3
 82c:	6685                	lui	a3,0x1
 82e:	00d77363          	bgeu	a4,a3,834 <malloc+0x44>
 832:	6a05                	lui	s4,0x1
 834:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 838:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83c:	00000917          	auipc	s2,0x0
 840:	0cc90913          	addi	s2,s2,204 # 908 <freep>
  if(p == (char*)-1)
 844:	5afd                	li	s5,-1
 846:	a88d                	j	8b8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 848:	00000797          	auipc	a5,0x0
 84c:	0c878793          	addi	a5,a5,200 # 910 <base>
 850:	00000717          	auipc	a4,0x0
 854:	0af73c23          	sd	a5,184(a4) # 908 <freep>
 858:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 85a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85e:	b7e1                	j	826 <malloc+0x36>
      if(p->s.size == nunits)
 860:	02e48b63          	beq	s1,a4,896 <malloc+0xa6>
        p->s.size -= nunits;
 864:	4137073b          	subw	a4,a4,s3
 868:	c798                	sw	a4,8(a5)
        p += p->s.size;
 86a:	1702                	slli	a4,a4,0x20
 86c:	9301                	srli	a4,a4,0x20
 86e:	0712                	slli	a4,a4,0x4
 870:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 872:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 876:	00000717          	auipc	a4,0x0
 87a:	08a73923          	sd	a0,146(a4) # 908 <freep>
      return (void*)(p + 1);
 87e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 882:	70e2                	ld	ra,56(sp)
 884:	7442                	ld	s0,48(sp)
 886:	74a2                	ld	s1,40(sp)
 888:	7902                	ld	s2,32(sp)
 88a:	69e2                	ld	s3,24(sp)
 88c:	6a42                	ld	s4,16(sp)
 88e:	6aa2                	ld	s5,8(sp)
 890:	6b02                	ld	s6,0(sp)
 892:	6121                	addi	sp,sp,64
 894:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 896:	6398                	ld	a4,0(a5)
 898:	e118                	sd	a4,0(a0)
 89a:	bff1                	j	876 <malloc+0x86>
  hp->s.size = nu;
 89c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a0:	0541                	addi	a0,a0,16
 8a2:	00000097          	auipc	ra,0x0
 8a6:	ec6080e7          	jalr	-314(ra) # 768 <free>
  return freep;
 8aa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ae:	d971                	beqz	a0,882 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b2:	4798                	lw	a4,8(a5)
 8b4:	fa9776e3          	bgeu	a4,s1,860 <malloc+0x70>
    if(p == freep)
 8b8:	00093703          	ld	a4,0(s2)
 8bc:	853e                	mv	a0,a5
 8be:	fef719e3          	bne	a4,a5,8b0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8c2:	8552                	mv	a0,s4
 8c4:	00000097          	auipc	ra,0x0
 8c8:	b5e080e7          	jalr	-1186(ra) # 422 <sbrk>
  if(p == (char*)-1)
 8cc:	fd5518e3          	bne	a0,s5,89c <malloc+0xac>
        return 0;
 8d0:	4501                	li	a0,0
 8d2:	bf45                	j	882 <malloc+0x92>
