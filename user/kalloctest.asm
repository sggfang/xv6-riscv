
user/_kalloctest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test0>:
  test1();
  exit();
}

void test0()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  void *a, *a1;
  printf("start test0\n");  
  10:	00001517          	auipc	a0,0x1
  14:	9d850513          	addi	a0,a0,-1576 # 9e8 <malloc+0xea>
  18:	00001097          	auipc	ra,0x1
  1c:	828080e7          	jalr	-2008(ra) # 840 <printf>
  int n = ntas();
  20:	00000097          	auipc	ra,0x0
  24:	528080e7          	jalr	1320(ra) # 548 <ntas>
  28:	84aa                	mv	s1,a0
  for(int i = 0; i < NCHILD; i++){
    int pid = fork();
  2a:	00000097          	auipc	ra,0x0
  2e:	476080e7          	jalr	1142(ra) # 4a0 <fork>
    if(pid < 0){
  32:	04054863          	bltz	a0,82 <test0+0x82>
      printf("fork failed");
      exit();
    }
    if(pid == 0){
  36:	c135                	beqz	a0,9a <test0+0x9a>
    int pid = fork();
  38:	00000097          	auipc	ra,0x0
  3c:	468080e7          	jalr	1128(ra) # 4a0 <fork>
    if(pid < 0){
  40:	04054163          	bltz	a0,82 <test0+0x82>
    if(pid == 0){
  44:	c939                	beqz	a0,9a <test0+0x9a>
      exit();
    }
  }

  for(int i = 0; i < NCHILD; i++){
    wait();
  46:	00000097          	auipc	ra,0x0
  4a:	46a080e7          	jalr	1130(ra) # 4b0 <wait>
  4e:	00000097          	auipc	ra,0x0
  52:	462080e7          	jalr	1122(ra) # 4b0 <wait>
  }
  int t = ntas();
  56:	00000097          	auipc	ra,0x0
  5a:	4f2080e7          	jalr	1266(ra) # 548 <ntas>
  printf("test0 done: #test-and-sets = %d\n", t - n);
  5e:	409505bb          	subw	a1,a0,s1
  62:	00001517          	auipc	a0,0x1
  66:	9b650513          	addi	a0,a0,-1610 # a18 <malloc+0x11a>
  6a:	00000097          	auipc	ra,0x0
  6e:	7d6080e7          	jalr	2006(ra) # 840 <printf>
}
  72:	70a2                	ld	ra,40(sp)
  74:	7402                	ld	s0,32(sp)
  76:	64e2                	ld	s1,24(sp)
  78:	6942                	ld	s2,16(sp)
  7a:	69a2                	ld	s3,8(sp)
  7c:	6a02                	ld	s4,0(sp)
  7e:	6145                	addi	sp,sp,48
  80:	8082                	ret
      printf("fork failed");
  82:	00001517          	auipc	a0,0x1
  86:	97650513          	addi	a0,a0,-1674 # 9f8 <malloc+0xfa>
  8a:	00000097          	auipc	ra,0x0
  8e:	7b6080e7          	jalr	1974(ra) # 840 <printf>
      exit();
  92:	00000097          	auipc	ra,0x0
  96:	416080e7          	jalr	1046(ra) # 4a8 <exit>
{
  9a:	6961                	lui	s2,0x18
  9c:	6a090913          	addi	s2,s2,1696 # 186a0 <__global_pointer$+0x17397>
        if(a == (char*)0xffffffffffffffffL){
  a0:	59fd                	li	s3,-1
        *(int *)(a+4) = 1;
  a2:	4a05                	li	s4,1
        a = sbrk(4096);
  a4:	6505                	lui	a0,0x1
  a6:	00000097          	auipc	ra,0x0
  aa:	48a080e7          	jalr	1162(ra) # 530 <sbrk>
  ae:	84aa                	mv	s1,a0
        if(a == (char*)0xffffffffffffffffL){
  b0:	03350063          	beq	a0,s3,d0 <test0+0xd0>
        *(int *)(a+4) = 1;
  b4:	01452223          	sw	s4,4(a0) # 1004 <__BSS_END__+0x4dc>
        a1 = sbrk(-4096);
  b8:	757d                	lui	a0,0xfffff
  ba:	00000097          	auipc	ra,0x0
  be:	476080e7          	jalr	1142(ra) # 530 <sbrk>
        if (a1 != a + 4096) {
  c2:	6785                	lui	a5,0x1
  c4:	94be                	add	s1,s1,a5
  c6:	00951963          	bne	a0,s1,d8 <test0+0xd8>
      for(i = 0; i < N; i++) {
  ca:	397d                	addiw	s2,s2,-1
  cc:	fc091ce3          	bnez	s2,a4 <test0+0xa4>
      exit();
  d0:	00000097          	auipc	ra,0x0
  d4:	3d8080e7          	jalr	984(ra) # 4a8 <exit>
          printf("wrong sbrk\n");
  d8:	00001517          	auipc	a0,0x1
  dc:	93050513          	addi	a0,a0,-1744 # a08 <malloc+0x10a>
  e0:	00000097          	auipc	ra,0x0
  e4:	760080e7          	jalr	1888(ra) # 840 <printf>
          exit();
  e8:	00000097          	auipc	ra,0x0
  ec:	3c0080e7          	jalr	960(ra) # 4a8 <exit>

00000000000000f0 <test1>:

// Run system out of memory and count tot memory allocated
void test1()
{
  f0:	715d                	addi	sp,sp,-80
  f2:	e486                	sd	ra,72(sp)
  f4:	e0a2                	sd	s0,64(sp)
  f6:	fc26                	sd	s1,56(sp)
  f8:	f84a                	sd	s2,48(sp)
  fa:	f44e                	sd	s3,40(sp)
  fc:	f052                	sd	s4,32(sp)
  fe:	0880                	addi	s0,sp,80
  void *a;
  int pipes[NCHILD];
  int tot = 0;
  char buf[1];
  
  printf("start test1\n");  
 100:	00001517          	auipc	a0,0x1
 104:	94050513          	addi	a0,a0,-1728 # a40 <malloc+0x142>
 108:	00000097          	auipc	ra,0x0
 10c:	738080e7          	jalr	1848(ra) # 840 <printf>
  for(int i = 0; i < NCHILD; i++){
 110:	fc840913          	addi	s2,s0,-56
    int fds[2];
    if(pipe(fds) != 0){
 114:	fb840513          	addi	a0,s0,-72
 118:	00000097          	auipc	ra,0x0
 11c:	3a0080e7          	jalr	928(ra) # 4b8 <pipe>
 120:	84aa                	mv	s1,a0
 122:	e905                	bnez	a0,152 <test1+0x62>
      printf("pipe() failed\n");
      exit();
    }
    int pid = fork();
 124:	00000097          	auipc	ra,0x0
 128:	37c080e7          	jalr	892(ra) # 4a0 <fork>
    if(pid < 0){
 12c:	02054f63          	bltz	a0,16a <test1+0x7a>
      printf("fork failed");
      exit();
    }
    if(pid == 0){
 130:	c929                	beqz	a0,182 <test1+0x92>
          exit();
        }
      }
      exit();
    } else {
      close(fds[1]);
 132:	fbc42503          	lw	a0,-68(s0)
 136:	00000097          	auipc	ra,0x0
 13a:	39a080e7          	jalr	922(ra) # 4d0 <close>
      pipes[i] = fds[0];
 13e:	fb842783          	lw	a5,-72(s0)
 142:	00f92023          	sw	a5,0(s2)
  for(int i = 0; i < NCHILD; i++){
 146:	0911                	addi	s2,s2,4
 148:	fd040793          	addi	a5,s0,-48
 14c:	fd2794e3          	bne	a5,s2,114 <test1+0x24>
 150:	a855                	j	204 <test1+0x114>
      printf("pipe() failed\n");
 152:	00001517          	auipc	a0,0x1
 156:	8fe50513          	addi	a0,a0,-1794 # a50 <malloc+0x152>
 15a:	00000097          	auipc	ra,0x0
 15e:	6e6080e7          	jalr	1766(ra) # 840 <printf>
      exit();
 162:	00000097          	auipc	ra,0x0
 166:	346080e7          	jalr	838(ra) # 4a8 <exit>
      printf("fork failed");
 16a:	00001517          	auipc	a0,0x1
 16e:	88e50513          	addi	a0,a0,-1906 # 9f8 <malloc+0xfa>
 172:	00000097          	auipc	ra,0x0
 176:	6ce080e7          	jalr	1742(ra) # 840 <printf>
      exit();
 17a:	00000097          	auipc	ra,0x0
 17e:	32e080e7          	jalr	814(ra) # 4a8 <exit>
      close(fds[0]);
 182:	fb842503          	lw	a0,-72(s0)
 186:	00000097          	auipc	ra,0x0
 18a:	34a080e7          	jalr	842(ra) # 4d0 <close>
 18e:	64e1                	lui	s1,0x18
 190:	6a048493          	addi	s1,s1,1696 # 186a0 <__global_pointer$+0x17397>
        if(a == (char*)0xffffffffffffffffL){
 194:	5a7d                	li	s4,-1
        *(int *)(a+4) = 1;
 196:	4905                	li	s2,1
        if (write(fds[1], "x", 1) != 1) {
 198:	00001997          	auipc	s3,0x1
 19c:	8c898993          	addi	s3,s3,-1848 # a60 <malloc+0x162>
        a = sbrk(PGSIZE);
 1a0:	6505                	lui	a0,0x1
 1a2:	00000097          	auipc	ra,0x0
 1a6:	38e080e7          	jalr	910(ra) # 530 <sbrk>
        if(a == (char*)0xffffffffffffffffL){
 1aa:	03450063          	beq	a0,s4,1ca <test1+0xda>
        *(int *)(a+4) = 1;
 1ae:	01252223          	sw	s2,4(a0) # 1004 <__BSS_END__+0x4dc>
        if (write(fds[1], "x", 1) != 1) {
 1b2:	864a                	mv	a2,s2
 1b4:	85ce                	mv	a1,s3
 1b6:	fbc42503          	lw	a0,-68(s0)
 1ba:	00000097          	auipc	ra,0x0
 1be:	30e080e7          	jalr	782(ra) # 4c8 <write>
 1c2:	01251863          	bne	a0,s2,1d2 <test1+0xe2>
      for(i = 0; i < N; i++) {
 1c6:	34fd                	addiw	s1,s1,-1
 1c8:	fce1                	bnez	s1,1a0 <test1+0xb0>
      exit();
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2de080e7          	jalr	734(ra) # 4a8 <exit>
          printf("write failed");
 1d2:	00001517          	auipc	a0,0x1
 1d6:	89650513          	addi	a0,a0,-1898 # a68 <malloc+0x16a>
 1da:	00000097          	auipc	ra,0x0
 1de:	666080e7          	jalr	1638(ra) # 840 <printf>
          exit();
 1e2:	00000097          	auipc	ra,0x0
 1e6:	2c6080e7          	jalr	710(ra) # 4a8 <exit>
  int stop = 0;
  while (!stop) {
    stop = 1;
    for(int i = 0; i < NCHILD; i++){
      if (read(pipes[i], buf, 1) == 1) {
        tot += 1;
 1ea:	2485                	addiw	s1,s1,1
      if (read(pipes[i], buf, 1) == 1) {
 1ec:	4605                	li	a2,1
 1ee:	fc040593          	addi	a1,s0,-64
 1f2:	fcc42503          	lw	a0,-52(s0)
 1f6:	00000097          	auipc	ra,0x0
 1fa:	2ca080e7          	jalr	714(ra) # 4c0 <read>
 1fe:	4785                	li	a5,1
 200:	02f50a63          	beq	a0,a5,234 <test1+0x144>
 204:	4605                	li	a2,1
 206:	fc040593          	addi	a1,s0,-64
 20a:	fc842503          	lw	a0,-56(s0)
 20e:	00000097          	auipc	ra,0x0
 212:	2b2080e7          	jalr	690(ra) # 4c0 <read>
 216:	4785                	li	a5,1
 218:	fcf509e3          	beq	a0,a5,1ea <test1+0xfa>
 21c:	4605                	li	a2,1
 21e:	fc040593          	addi	a1,s0,-64
 222:	fcc42503          	lw	a0,-52(s0)
 226:	00000097          	auipc	ra,0x0
 22a:	29a080e7          	jalr	666(ra) # 4c0 <read>
 22e:	4785                	li	a5,1
 230:	02f51063          	bne	a0,a5,250 <test1+0x160>
        tot += 1;
 234:	2485                	addiw	s1,s1,1
  while (!stop) {
 236:	b7f9                	j	204 <test1+0x114>
    }
  }
  int n = (PHYSTOP-KERNBASE)/PGSIZE;
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
  if(n - tot > 1000) {
    printf("test1 failed: cannot allocate enough memory\n");
 238:	00001517          	auipc	a0,0x1
 23c:	84050513          	addi	a0,a0,-1984 # a78 <malloc+0x17a>
 240:	00000097          	auipc	ra,0x0
 244:	600080e7          	jalr	1536(ra) # 840 <printf>
    exit();
 248:	00000097          	auipc	ra,0x0
 24c:	260080e7          	jalr	608(ra) # 4a8 <exit>
  printf("total allocated number of pages: %d (out of %d)\n", tot, n);
 250:	6621                	lui	a2,0x8
 252:	85a6                	mv	a1,s1
 254:	00001517          	auipc	a0,0x1
 258:	86450513          	addi	a0,a0,-1948 # ab8 <malloc+0x1ba>
 25c:	00000097          	auipc	ra,0x0
 260:	5e4080e7          	jalr	1508(ra) # 840 <printf>
  if(n - tot > 1000) {
 264:	67a1                	lui	a5,0x8
 266:	409784bb          	subw	s1,a5,s1
 26a:	3e800793          	li	a5,1000
 26e:	fc97c5e3          	blt	a5,s1,238 <test1+0x148>
  }
  printf("test1 done\n");
 272:	00001517          	auipc	a0,0x1
 276:	83650513          	addi	a0,a0,-1994 # aa8 <malloc+0x1aa>
 27a:	00000097          	auipc	ra,0x0
 27e:	5c6080e7          	jalr	1478(ra) # 840 <printf>
}
 282:	60a6                	ld	ra,72(sp)
 284:	6406                	ld	s0,64(sp)
 286:	74e2                	ld	s1,56(sp)
 288:	7942                	ld	s2,48(sp)
 28a:	79a2                	ld	s3,40(sp)
 28c:	7a02                	ld	s4,32(sp)
 28e:	6161                	addi	sp,sp,80
 290:	8082                	ret

0000000000000292 <main>:
{
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  test0();
 29a:	00000097          	auipc	ra,0x0
 29e:	d66080e7          	jalr	-666(ra) # 0 <test0>
  test1();
 2a2:	00000097          	auipc	ra,0x0
 2a6:	e4e080e7          	jalr	-434(ra) # f0 <test1>
  exit();
 2aa:	00000097          	auipc	ra,0x0
 2ae:	1fe080e7          	jalr	510(ra) # 4a8 <exit>

00000000000002b2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2b2:	1141                	addi	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2b8:	87aa                	mv	a5,a0
 2ba:	0585                	addi	a1,a1,1
 2bc:	0785                	addi	a5,a5,1
 2be:	fff5c703          	lbu	a4,-1(a1)
 2c2:	fee78fa3          	sb	a4,-1(a5) # 7fff <__global_pointer$+0x6cf6>
 2c6:	fb75                	bnez	a4,2ba <strcpy+0x8>
    ;
  return os;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret

00000000000002ce <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e422                	sd	s0,8(sp)
 2d2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	cb91                	beqz	a5,2ec <strcmp+0x1e>
 2da:	0005c703          	lbu	a4,0(a1)
 2de:	00f71763          	bne	a4,a5,2ec <strcmp+0x1e>
    p++, q++;
 2e2:	0505                	addi	a0,a0,1
 2e4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	fbe5                	bnez	a5,2da <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2ec:	0005c503          	lbu	a0,0(a1)
}
 2f0:	40a7853b          	subw	a0,a5,a0
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret

00000000000002fa <strlen>:

uint
strlen(const char *s)
{
 2fa:	1141                	addi	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 300:	00054783          	lbu	a5,0(a0)
 304:	cf91                	beqz	a5,320 <strlen+0x26>
 306:	0505                	addi	a0,a0,1
 308:	87aa                	mv	a5,a0
 30a:	4685                	li	a3,1
 30c:	9e89                	subw	a3,a3,a0
 30e:	00f6853b          	addw	a0,a3,a5
 312:	0785                	addi	a5,a5,1
 314:	fff7c703          	lbu	a4,-1(a5)
 318:	fb7d                	bnez	a4,30e <strlen+0x14>
    ;
  return n;
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  for(n = 0; s[n]; n++)
 320:	4501                	li	a0,0
 322:	bfe5                	j	31a <strlen+0x20>

0000000000000324 <memset>:

void*
memset(void *dst, int c, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e422                	sd	s0,8(sp)
 328:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 32a:	ce09                	beqz	a2,344 <memset+0x20>
 32c:	87aa                	mv	a5,a0
 32e:	fff6071b          	addiw	a4,a2,-1
 332:	1702                	slli	a4,a4,0x20
 334:	9301                	srli	a4,a4,0x20
 336:	0705                	addi	a4,a4,1
 338:	972a                	add	a4,a4,a0
    cdst[i] = c;
 33a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 33e:	0785                	addi	a5,a5,1
 340:	fee79de3          	bne	a5,a4,33a <memset+0x16>
  }
  return dst;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <strchr>:

char*
strchr(const char *s, char c)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 350:	00054783          	lbu	a5,0(a0)
 354:	cb99                	beqz	a5,36a <strchr+0x20>
    if(*s == c)
 356:	00f58763          	beq	a1,a5,364 <strchr+0x1a>
  for(; *s; s++)
 35a:	0505                	addi	a0,a0,1
 35c:	00054783          	lbu	a5,0(a0)
 360:	fbfd                	bnez	a5,356 <strchr+0xc>
      return (char*)s;
  return 0;
 362:	4501                	li	a0,0
}
 364:	6422                	ld	s0,8(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret
  return 0;
 36a:	4501                	li	a0,0
 36c:	bfe5                	j	364 <strchr+0x1a>

000000000000036e <gets>:

char*
gets(char *buf, int max)
{
 36e:	711d                	addi	sp,sp,-96
 370:	ec86                	sd	ra,88(sp)
 372:	e8a2                	sd	s0,80(sp)
 374:	e4a6                	sd	s1,72(sp)
 376:	e0ca                	sd	s2,64(sp)
 378:	fc4e                	sd	s3,56(sp)
 37a:	f852                	sd	s4,48(sp)
 37c:	f456                	sd	s5,40(sp)
 37e:	f05a                	sd	s6,32(sp)
 380:	ec5e                	sd	s7,24(sp)
 382:	1080                	addi	s0,sp,96
 384:	8baa                	mv	s7,a0
 386:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 388:	892a                	mv	s2,a0
 38a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 38c:	4aa9                	li	s5,10
 38e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 390:	89a6                	mv	s3,s1
 392:	2485                	addiw	s1,s1,1
 394:	0344d863          	bge	s1,s4,3c4 <gets+0x56>
    cc = read(0, &c, 1);
 398:	4605                	li	a2,1
 39a:	faf40593          	addi	a1,s0,-81
 39e:	4501                	li	a0,0
 3a0:	00000097          	auipc	ra,0x0
 3a4:	120080e7          	jalr	288(ra) # 4c0 <read>
    if(cc < 1)
 3a8:	00a05e63          	blez	a0,3c4 <gets+0x56>
    buf[i++] = c;
 3ac:	faf44783          	lbu	a5,-81(s0)
 3b0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3b4:	01578763          	beq	a5,s5,3c2 <gets+0x54>
 3b8:	0905                	addi	s2,s2,1
 3ba:	fd679be3          	bne	a5,s6,390 <gets+0x22>
  for(i=0; i+1 < max; ){
 3be:	89a6                	mv	s3,s1
 3c0:	a011                	j	3c4 <gets+0x56>
 3c2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3c4:	99de                	add	s3,s3,s7
 3c6:	00098023          	sb	zero,0(s3)
  return buf;
}
 3ca:	855e                	mv	a0,s7
 3cc:	60e6                	ld	ra,88(sp)
 3ce:	6446                	ld	s0,80(sp)
 3d0:	64a6                	ld	s1,72(sp)
 3d2:	6906                	ld	s2,64(sp)
 3d4:	79e2                	ld	s3,56(sp)
 3d6:	7a42                	ld	s4,48(sp)
 3d8:	7aa2                	ld	s5,40(sp)
 3da:	7b02                	ld	s6,32(sp)
 3dc:	6be2                	ld	s7,24(sp)
 3de:	6125                	addi	sp,sp,96
 3e0:	8082                	ret

00000000000003e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 3e2:	1101                	addi	sp,sp,-32
 3e4:	ec06                	sd	ra,24(sp)
 3e6:	e822                	sd	s0,16(sp)
 3e8:	e426                	sd	s1,8(sp)
 3ea:	e04a                	sd	s2,0(sp)
 3ec:	1000                	addi	s0,sp,32
 3ee:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3f0:	4581                	li	a1,0
 3f2:	00000097          	auipc	ra,0x0
 3f6:	0f6080e7          	jalr	246(ra) # 4e8 <open>
  if(fd < 0)
 3fa:	02054563          	bltz	a0,424 <stat+0x42>
 3fe:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 400:	85ca                	mv	a1,s2
 402:	00000097          	auipc	ra,0x0
 406:	0fe080e7          	jalr	254(ra) # 500 <fstat>
 40a:	892a                	mv	s2,a0
  close(fd);
 40c:	8526                	mv	a0,s1
 40e:	00000097          	auipc	ra,0x0
 412:	0c2080e7          	jalr	194(ra) # 4d0 <close>
  return r;
}
 416:	854a                	mv	a0,s2
 418:	60e2                	ld	ra,24(sp)
 41a:	6442                	ld	s0,16(sp)
 41c:	64a2                	ld	s1,8(sp)
 41e:	6902                	ld	s2,0(sp)
 420:	6105                	addi	sp,sp,32
 422:	8082                	ret
    return -1;
 424:	597d                	li	s2,-1
 426:	bfc5                	j	416 <stat+0x34>

0000000000000428 <atoi>:

int
atoi(const char *s)
{
 428:	1141                	addi	sp,sp,-16
 42a:	e422                	sd	s0,8(sp)
 42c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 42e:	00054603          	lbu	a2,0(a0)
 432:	fd06079b          	addiw	a5,a2,-48
 436:	0ff7f793          	andi	a5,a5,255
 43a:	4725                	li	a4,9
 43c:	02f76963          	bltu	a4,a5,46e <atoi+0x46>
 440:	86aa                	mv	a3,a0
  n = 0;
 442:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 444:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 446:	0685                	addi	a3,a3,1
 448:	0025179b          	slliw	a5,a0,0x2
 44c:	9fa9                	addw	a5,a5,a0
 44e:	0017979b          	slliw	a5,a5,0x1
 452:	9fb1                	addw	a5,a5,a2
 454:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 458:	0006c603          	lbu	a2,0(a3)
 45c:	fd06071b          	addiw	a4,a2,-48
 460:	0ff77713          	andi	a4,a4,255
 464:	fee5f1e3          	bgeu	a1,a4,446 <atoi+0x1e>
  return n;
}
 468:	6422                	ld	s0,8(sp)
 46a:	0141                	addi	sp,sp,16
 46c:	8082                	ret
  n = 0;
 46e:	4501                	li	a0,0
 470:	bfe5                	j	468 <atoi+0x40>

0000000000000472 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 472:	1141                	addi	sp,sp,-16
 474:	e422                	sd	s0,8(sp)
 476:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 478:	02c05163          	blez	a2,49a <memmove+0x28>
 47c:	fff6071b          	addiw	a4,a2,-1
 480:	1702                	slli	a4,a4,0x20
 482:	9301                	srli	a4,a4,0x20
 484:	0705                	addi	a4,a4,1
 486:	972a                	add	a4,a4,a0
  dst = vdst;
 488:	87aa                	mv	a5,a0
    *dst++ = *src++;
 48a:	0585                	addi	a1,a1,1
 48c:	0785                	addi	a5,a5,1
 48e:	fff5c683          	lbu	a3,-1(a1)
 492:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 496:	fee79ae3          	bne	a5,a4,48a <memmove+0x18>
  return vdst;
}
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret

00000000000004a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4a0:	4885                	li	a7,1
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4a8:	4889                	li	a7,2
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4b0:	488d                	li	a7,3
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4b8:	4891                	li	a7,4
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <read>:
.global read
read:
 li a7, SYS_read
 4c0:	4895                	li	a7,5
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <write>:
.global write
write:
 li a7, SYS_write
 4c8:	48c1                	li	a7,16
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <close>:
.global close
close:
 li a7, SYS_close
 4d0:	48d5                	li	a7,21
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4d8:	4899                	li	a7,6
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4e0:	489d                	li	a7,7
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <open>:
.global open
open:
 li a7, SYS_open
 4e8:	48bd                	li	a7,15
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4f0:	48c5                	li	a7,17
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4f8:	48c9                	li	a7,18
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 500:	48a1                	li	a7,8
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <link>:
.global link
link:
 li a7, SYS_link
 508:	48cd                	li	a7,19
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 510:	48d1                	li	a7,20
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 518:	48a5                	li	a7,9
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <dup>:
.global dup
dup:
 li a7, SYS_dup
 520:	48a9                	li	a7,10
 ecall
 522:	00000073          	ecall
 ret
 526:	8082                	ret

0000000000000528 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 528:	48ad                	li	a7,11
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 530:	48b1                	li	a7,12
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 538:	48b5                	li	a7,13
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 540:	48b9                	li	a7,14
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 548:	48d9                	li	a7,22
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <crash>:
.global crash
crash:
 li a7, SYS_crash
 550:	48dd                	li	a7,23
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <mount>:
.global mount
mount:
 li a7, SYS_mount
 558:	48e1                	li	a7,24
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <umount>:
.global umount
umount:
 li a7, SYS_umount
 560:	48e5                	li	a7,25
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 568:	1101                	addi	sp,sp,-32
 56a:	ec06                	sd	ra,24(sp)
 56c:	e822                	sd	s0,16(sp)
 56e:	1000                	addi	s0,sp,32
 570:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 574:	4605                	li	a2,1
 576:	fef40593          	addi	a1,s0,-17
 57a:	00000097          	auipc	ra,0x0
 57e:	f4e080e7          	jalr	-178(ra) # 4c8 <write>
}
 582:	60e2                	ld	ra,24(sp)
 584:	6442                	ld	s0,16(sp)
 586:	6105                	addi	sp,sp,32
 588:	8082                	ret

000000000000058a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 58a:	7139                	addi	sp,sp,-64
 58c:	fc06                	sd	ra,56(sp)
 58e:	f822                	sd	s0,48(sp)
 590:	f426                	sd	s1,40(sp)
 592:	f04a                	sd	s2,32(sp)
 594:	ec4e                	sd	s3,24(sp)
 596:	0080                	addi	s0,sp,64
 598:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 59a:	c299                	beqz	a3,5a0 <printint+0x16>
 59c:	0805c863          	bltz	a1,62c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5a0:	2581                	sext.w	a1,a1
  neg = 0;
 5a2:	4881                	li	a7,0
 5a4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5a8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5aa:	2601                	sext.w	a2,a2
 5ac:	00000517          	auipc	a0,0x0
 5b0:	54c50513          	addi	a0,a0,1356 # af8 <digits>
 5b4:	883a                	mv	a6,a4
 5b6:	2705                	addiw	a4,a4,1
 5b8:	02c5f7bb          	remuw	a5,a1,a2
 5bc:	1782                	slli	a5,a5,0x20
 5be:	9381                	srli	a5,a5,0x20
 5c0:	97aa                	add	a5,a5,a0
 5c2:	0007c783          	lbu	a5,0(a5)
 5c6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5ca:	0005879b          	sext.w	a5,a1
 5ce:	02c5d5bb          	divuw	a1,a1,a2
 5d2:	0685                	addi	a3,a3,1
 5d4:	fec7f0e3          	bgeu	a5,a2,5b4 <printint+0x2a>
  if(neg)
 5d8:	00088b63          	beqz	a7,5ee <printint+0x64>
    buf[i++] = '-';
 5dc:	fd040793          	addi	a5,s0,-48
 5e0:	973e                	add	a4,a4,a5
 5e2:	02d00793          	li	a5,45
 5e6:	fef70823          	sb	a5,-16(a4)
 5ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ee:	02e05863          	blez	a4,61e <printint+0x94>
 5f2:	fc040793          	addi	a5,s0,-64
 5f6:	00e78933          	add	s2,a5,a4
 5fa:	fff78993          	addi	s3,a5,-1
 5fe:	99ba                	add	s3,s3,a4
 600:	377d                	addiw	a4,a4,-1
 602:	1702                	slli	a4,a4,0x20
 604:	9301                	srli	a4,a4,0x20
 606:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 60a:	fff94583          	lbu	a1,-1(s2)
 60e:	8526                	mv	a0,s1
 610:	00000097          	auipc	ra,0x0
 614:	f58080e7          	jalr	-168(ra) # 568 <putc>
  while(--i >= 0)
 618:	197d                	addi	s2,s2,-1
 61a:	ff3918e3          	bne	s2,s3,60a <printint+0x80>
}
 61e:	70e2                	ld	ra,56(sp)
 620:	7442                	ld	s0,48(sp)
 622:	74a2                	ld	s1,40(sp)
 624:	7902                	ld	s2,32(sp)
 626:	69e2                	ld	s3,24(sp)
 628:	6121                	addi	sp,sp,64
 62a:	8082                	ret
    x = -xx;
 62c:	40b005bb          	negw	a1,a1
    neg = 1;
 630:	4885                	li	a7,1
    x = -xx;
 632:	bf8d                	j	5a4 <printint+0x1a>

0000000000000634 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 634:	7119                	addi	sp,sp,-128
 636:	fc86                	sd	ra,120(sp)
 638:	f8a2                	sd	s0,112(sp)
 63a:	f4a6                	sd	s1,104(sp)
 63c:	f0ca                	sd	s2,96(sp)
 63e:	ecce                	sd	s3,88(sp)
 640:	e8d2                	sd	s4,80(sp)
 642:	e4d6                	sd	s5,72(sp)
 644:	e0da                	sd	s6,64(sp)
 646:	fc5e                	sd	s7,56(sp)
 648:	f862                	sd	s8,48(sp)
 64a:	f466                	sd	s9,40(sp)
 64c:	f06a                	sd	s10,32(sp)
 64e:	ec6e                	sd	s11,24(sp)
 650:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 652:	0005c903          	lbu	s2,0(a1)
 656:	18090f63          	beqz	s2,7f4 <vprintf+0x1c0>
 65a:	8aaa                	mv	s5,a0
 65c:	8b32                	mv	s6,a2
 65e:	00158493          	addi	s1,a1,1
  state = 0;
 662:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 664:	02500a13          	li	s4,37
      if(c == 'd'){
 668:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 66c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 670:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 674:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 678:	00000b97          	auipc	s7,0x0
 67c:	480b8b93          	addi	s7,s7,1152 # af8 <digits>
 680:	a839                	j	69e <vprintf+0x6a>
        putc(fd, c);
 682:	85ca                	mv	a1,s2
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	ee2080e7          	jalr	-286(ra) # 568 <putc>
 68e:	a019                	j	694 <vprintf+0x60>
    } else if(state == '%'){
 690:	01498f63          	beq	s3,s4,6ae <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 694:	0485                	addi	s1,s1,1
 696:	fff4c903          	lbu	s2,-1(s1)
 69a:	14090d63          	beqz	s2,7f4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 69e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6a2:	fe0997e3          	bnez	s3,690 <vprintf+0x5c>
      if(c == '%'){
 6a6:	fd479ee3          	bne	a5,s4,682 <vprintf+0x4e>
        state = '%';
 6aa:	89be                	mv	s3,a5
 6ac:	b7e5                	j	694 <vprintf+0x60>
      if(c == 'd'){
 6ae:	05878063          	beq	a5,s8,6ee <vprintf+0xba>
      } else if(c == 'l') {
 6b2:	05978c63          	beq	a5,s9,70a <vprintf+0xd6>
      } else if(c == 'x') {
 6b6:	07a78863          	beq	a5,s10,726 <vprintf+0xf2>
      } else if(c == 'p') {
 6ba:	09b78463          	beq	a5,s11,742 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 6be:	07300713          	li	a4,115
 6c2:	0ce78663          	beq	a5,a4,78e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6c6:	06300713          	li	a4,99
 6ca:	0ee78e63          	beq	a5,a4,7c6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6ce:	11478863          	beq	a5,s4,7de <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6d2:	85d2                	mv	a1,s4
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e92080e7          	jalr	-366(ra) # 568 <putc>
        putc(fd, c);
 6de:	85ca                	mv	a1,s2
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e86080e7          	jalr	-378(ra) # 568 <putc>
      }
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b765                	j	694 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ee:	008b0913          	addi	s2,s6,8
 6f2:	4685                	li	a3,1
 6f4:	4629                	li	a2,10
 6f6:	000b2583          	lw	a1,0(s6)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e8e080e7          	jalr	-370(ra) # 58a <printint>
 704:	8b4a                	mv	s6,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	b771                	j	694 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 70a:	008b0913          	addi	s2,s6,8
 70e:	4681                	li	a3,0
 710:	4629                	li	a2,10
 712:	000b2583          	lw	a1,0(s6)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e72080e7          	jalr	-398(ra) # 58a <printint>
 720:	8b4a                	mv	s6,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bf85                	j	694 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 726:	008b0913          	addi	s2,s6,8
 72a:	4681                	li	a3,0
 72c:	4641                	li	a2,16
 72e:	000b2583          	lw	a1,0(s6)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e56080e7          	jalr	-426(ra) # 58a <printint>
 73c:	8b4a                	mv	s6,s2
      state = 0;
 73e:	4981                	li	s3,0
 740:	bf91                	j	694 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 742:	008b0793          	addi	a5,s6,8
 746:	f8f43423          	sd	a5,-120(s0)
 74a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 74e:	03000593          	li	a1,48
 752:	8556                	mv	a0,s5
 754:	00000097          	auipc	ra,0x0
 758:	e14080e7          	jalr	-492(ra) # 568 <putc>
  putc(fd, 'x');
 75c:	85ea                	mv	a1,s10
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	e08080e7          	jalr	-504(ra) # 568 <putc>
 768:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76a:	03c9d793          	srli	a5,s3,0x3c
 76e:	97de                	add	a5,a5,s7
 770:	0007c583          	lbu	a1,0(a5)
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	df2080e7          	jalr	-526(ra) # 568 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77e:	0992                	slli	s3,s3,0x4
 780:	397d                	addiw	s2,s2,-1
 782:	fe0914e3          	bnez	s2,76a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 786:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 78a:	4981                	li	s3,0
 78c:	b721                	j	694 <vprintf+0x60>
        s = va_arg(ap, char*);
 78e:	008b0993          	addi	s3,s6,8
 792:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 796:	02090163          	beqz	s2,7b8 <vprintf+0x184>
        while(*s != 0){
 79a:	00094583          	lbu	a1,0(s2)
 79e:	c9a1                	beqz	a1,7ee <vprintf+0x1ba>
          putc(fd, *s);
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	dc6080e7          	jalr	-570(ra) # 568 <putc>
          s++;
 7aa:	0905                	addi	s2,s2,1
        while(*s != 0){
 7ac:	00094583          	lbu	a1,0(s2)
 7b0:	f9e5                	bnez	a1,7a0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 7b2:	8b4e                	mv	s6,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	bdf9                	j	694 <vprintf+0x60>
          s = "(null)";
 7b8:	00000917          	auipc	s2,0x0
 7bc:	33890913          	addi	s2,s2,824 # af0 <malloc+0x1f2>
        while(*s != 0){
 7c0:	02800593          	li	a1,40
 7c4:	bff1                	j	7a0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 7c6:	008b0913          	addi	s2,s6,8
 7ca:	000b4583          	lbu	a1,0(s6)
 7ce:	8556                	mv	a0,s5
 7d0:	00000097          	auipc	ra,0x0
 7d4:	d98080e7          	jalr	-616(ra) # 568 <putc>
 7d8:	8b4a                	mv	s6,s2
      state = 0;
 7da:	4981                	li	s3,0
 7dc:	bd65                	j	694 <vprintf+0x60>
        putc(fd, c);
 7de:	85d2                	mv	a1,s4
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	d86080e7          	jalr	-634(ra) # 568 <putc>
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b565                	j	694 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ee:	8b4e                	mv	s6,s3
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b54d                	j	694 <vprintf+0x60>
    }
  }
}
 7f4:	70e6                	ld	ra,120(sp)
 7f6:	7446                	ld	s0,112(sp)
 7f8:	74a6                	ld	s1,104(sp)
 7fa:	7906                	ld	s2,96(sp)
 7fc:	69e6                	ld	s3,88(sp)
 7fe:	6a46                	ld	s4,80(sp)
 800:	6aa6                	ld	s5,72(sp)
 802:	6b06                	ld	s6,64(sp)
 804:	7be2                	ld	s7,56(sp)
 806:	7c42                	ld	s8,48(sp)
 808:	7ca2                	ld	s9,40(sp)
 80a:	7d02                	ld	s10,32(sp)
 80c:	6de2                	ld	s11,24(sp)
 80e:	6109                	addi	sp,sp,128
 810:	8082                	ret

0000000000000812 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 812:	715d                	addi	sp,sp,-80
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e010                	sd	a2,0(s0)
 81c:	e414                	sd	a3,8(s0)
 81e:	e818                	sd	a4,16(s0)
 820:	ec1c                	sd	a5,24(s0)
 822:	03043023          	sd	a6,32(s0)
 826:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82e:	8622                	mv	a2,s0
 830:	00000097          	auipc	ra,0x0
 834:	e04080e7          	jalr	-508(ra) # 634 <vprintf>
}
 838:	60e2                	ld	ra,24(sp)
 83a:	6442                	ld	s0,16(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <printf>:

void
printf(const char *fmt, ...)
{
 840:	711d                	addi	sp,sp,-96
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e40c                	sd	a1,8(s0)
 84a:	e810                	sd	a2,16(s0)
 84c:	ec14                	sd	a3,24(s0)
 84e:	f018                	sd	a4,32(s0)
 850:	f41c                	sd	a5,40(s0)
 852:	03043823          	sd	a6,48(s0)
 856:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	00840613          	addi	a2,s0,8
 85e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 862:	85aa                	mv	a1,a0
 864:	4505                	li	a0,1
 866:	00000097          	auipc	ra,0x0
 86a:	dce080e7          	jalr	-562(ra) # 634 <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6125                	addi	sp,sp,96
 874:	8082                	ret

0000000000000876 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 876:	1141                	addi	sp,sp,-16
 878:	e422                	sd	s0,8(sp)
 87a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	00000797          	auipc	a5,0x0
 884:	2907b783          	ld	a5,656(a5) # b10 <freep>
 888:	a805                	j	8b8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 88a:	4618                	lw	a4,8(a2)
 88c:	9db9                	addw	a1,a1,a4
 88e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	6318                	ld	a4,0(a4)
 896:	fee53823          	sd	a4,-16(a0)
 89a:	a091                	j	8de <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 89c:	ff852703          	lw	a4,-8(a0)
 8a0:	9e39                	addw	a2,a2,a4
 8a2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 8a4:	ff053703          	ld	a4,-16(a0)
 8a8:	e398                	sd	a4,0(a5)
 8aa:	a099                	j	8f0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ac:	6398                	ld	a4,0(a5)
 8ae:	00e7e463          	bltu	a5,a4,8b6 <free+0x40>
 8b2:	00e6ea63          	bltu	a3,a4,8c6 <free+0x50>
{
 8b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b8:	fed7fae3          	bgeu	a5,a3,8ac <free+0x36>
 8bc:	6398                	ld	a4,0(a5)
 8be:	00e6e463          	bltu	a3,a4,8c6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8c2:	fee7eae3          	bltu	a5,a4,8b6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 8c6:	ff852583          	lw	a1,-8(a0)
 8ca:	6390                	ld	a2,0(a5)
 8cc:	02059713          	slli	a4,a1,0x20
 8d0:	9301                	srli	a4,a4,0x20
 8d2:	0712                	slli	a4,a4,0x4
 8d4:	9736                	add	a4,a4,a3
 8d6:	fae60ae3          	beq	a2,a4,88a <free+0x14>
    bp->s.ptr = p->s.ptr;
 8da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8de:	4790                	lw	a2,8(a5)
 8e0:	02061713          	slli	a4,a2,0x20
 8e4:	9301                	srli	a4,a4,0x20
 8e6:	0712                	slli	a4,a4,0x4
 8e8:	973e                	add	a4,a4,a5
 8ea:	fae689e3          	beq	a3,a4,89c <free+0x26>
  } else
    p->s.ptr = bp;
 8ee:	e394                	sd	a3,0(a5)
  freep = p;
 8f0:	00000717          	auipc	a4,0x0
 8f4:	22f73023          	sd	a5,544(a4) # b10 <freep>
}
 8f8:	6422                	ld	s0,8(sp)
 8fa:	0141                	addi	sp,sp,16
 8fc:	8082                	ret

00000000000008fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fe:	7139                	addi	sp,sp,-64
 900:	fc06                	sd	ra,56(sp)
 902:	f822                	sd	s0,48(sp)
 904:	f426                	sd	s1,40(sp)
 906:	f04a                	sd	s2,32(sp)
 908:	ec4e                	sd	s3,24(sp)
 90a:	e852                	sd	s4,16(sp)
 90c:	e456                	sd	s5,8(sp)
 90e:	e05a                	sd	s6,0(sp)
 910:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	02051493          	slli	s1,a0,0x20
 916:	9081                	srli	s1,s1,0x20
 918:	04bd                	addi	s1,s1,15
 91a:	8091                	srli	s1,s1,0x4
 91c:	0014899b          	addiw	s3,s1,1
 920:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 922:	00000517          	auipc	a0,0x0
 926:	1ee53503          	ld	a0,494(a0) # b10 <freep>
 92a:	c515                	beqz	a0,956 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 92c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 92e:	4798                	lw	a4,8(a5)
 930:	02977f63          	bgeu	a4,s1,96e <malloc+0x70>
 934:	8a4e                	mv	s4,s3
 936:	0009871b          	sext.w	a4,s3
 93a:	6685                	lui	a3,0x1
 93c:	00d77363          	bgeu	a4,a3,942 <malloc+0x44>
 940:	6a05                	lui	s4,0x1
 942:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 946:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 94a:	00000917          	auipc	s2,0x0
 94e:	1c690913          	addi	s2,s2,454 # b10 <freep>
  if(p == (char*)-1)
 952:	5afd                	li	s5,-1
 954:	a88d                	j	9c6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 956:	00000797          	auipc	a5,0x0
 95a:	1c278793          	addi	a5,a5,450 # b18 <base>
 95e:	00000717          	auipc	a4,0x0
 962:	1af73923          	sd	a5,434(a4) # b10 <freep>
 966:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 968:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 96c:	b7e1                	j	934 <malloc+0x36>
      if(p->s.size == nunits)
 96e:	02e48b63          	beq	s1,a4,9a4 <malloc+0xa6>
        p->s.size -= nunits;
 972:	4137073b          	subw	a4,a4,s3
 976:	c798                	sw	a4,8(a5)
        p += p->s.size;
 978:	1702                	slli	a4,a4,0x20
 97a:	9301                	srli	a4,a4,0x20
 97c:	0712                	slli	a4,a4,0x4
 97e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 980:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 984:	00000717          	auipc	a4,0x0
 988:	18a73623          	sd	a0,396(a4) # b10 <freep>
      return (void*)(p + 1);
 98c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 990:	70e2                	ld	ra,56(sp)
 992:	7442                	ld	s0,48(sp)
 994:	74a2                	ld	s1,40(sp)
 996:	7902                	ld	s2,32(sp)
 998:	69e2                	ld	s3,24(sp)
 99a:	6a42                	ld	s4,16(sp)
 99c:	6aa2                	ld	s5,8(sp)
 99e:	6b02                	ld	s6,0(sp)
 9a0:	6121                	addi	sp,sp,64
 9a2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9a4:	6398                	ld	a4,0(a5)
 9a6:	e118                	sd	a4,0(a0)
 9a8:	bff1                	j	984 <malloc+0x86>
  hp->s.size = nu;
 9aa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9ae:	0541                	addi	a0,a0,16
 9b0:	00000097          	auipc	ra,0x0
 9b4:	ec6080e7          	jalr	-314(ra) # 876 <free>
  return freep;
 9b8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9bc:	d971                	beqz	a0,990 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9c0:	4798                	lw	a4,8(a5)
 9c2:	fa9776e3          	bgeu	a4,s1,96e <malloc+0x70>
    if(p == freep)
 9c6:	00093703          	ld	a4,0(s2)
 9ca:	853e                	mv	a0,a5
 9cc:	fef719e3          	bne	a4,a5,9be <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 9d0:	8552                	mv	a0,s4
 9d2:	00000097          	auipc	ra,0x0
 9d6:	b5e080e7          	jalr	-1186(ra) # 530 <sbrk>
  if(p == (char*)-1)
 9da:	fd5518e3          	bne	a0,s5,9aa <malloc+0xac>
        return 0;
 9de:	4501                	li	a0,0
 9e0:	bf45                	j	990 <malloc+0x92>
