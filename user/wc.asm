
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	903d8d93          	addi	s11,s11,-1789 # 931 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	888a0a13          	addi	s4,s4,-1912 # 8c0 <malloc+0xe6>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1e0080e7          	jalr	480(ra) # 226 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2b85                	addiw	s7,s7,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c05                	addiw	s8,s8,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	8ba58593          	addi	a1,a1,-1862 # 930 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	31a080e7          	jalr	794(ra) # 39c <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
    for(i=0; i<n; i++){
  8e:	00001497          	auipc	s1,0x1
  92:	8a248493          	addi	s1,s1,-1886 # 930 <buf>
  96:	00050d1b          	sext.w	s10,a0
  9a:	fff5091b          	addiw	s2,a0,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit();
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86e6                	mv	a3,s9
  b2:	8662                	mv	a2,s8
  b4:	85de                	mv	a1,s7
  b6:	00001517          	auipc	a0,0x1
  ba:	82250513          	addi	a0,a0,-2014 # 8d8 <malloc+0xfe>
  be:	00000097          	auipc	ra,0x0
  c2:	65e080e7          	jalr	1630(ra) # 71c <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00000517          	auipc	a0,0x0
  e8:	7e450513          	addi	a0,a0,2020 # 8c8 <malloc+0xee>
  ec:	00000097          	auipc	ra,0x0
  f0:	630080e7          	jalr	1584(ra) # 71c <printf>
    exit();
  f4:	00000097          	auipc	ra,0x0
  f8:	290080e7          	jalr	656(ra) # 384 <exit>

00000000000000fc <main>:

int
main(int argc, char *argv[])
{
  fc:	7179                	addi	sp,sp,-48
  fe:	f406                	sd	ra,40(sp)
 100:	f022                	sd	s0,32(sp)
 102:	ec26                	sd	s1,24(sp)
 104:	e84a                	sd	s2,16(sp)
 106:	e44e                	sd	s3,8(sp)
 108:	e052                	sd	s4,0(sp)
 10a:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10c:	4785                	li	a5,1
 10e:	04a7d663          	bge	a5,a0,15a <main+0x5e>
 112:	00858493          	addi	s1,a1,8
 116:	ffe5099b          	addiw	s3,a0,-2
 11a:	1982                	slli	s3,s3,0x20
 11c:	0209d993          	srli	s3,s3,0x20
 120:	098e                	slli	s3,s3,0x3
 122:	05c1                	addi	a1,a1,16
 124:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit();
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 126:	4581                	li	a1,0
 128:	6088                	ld	a0,0(s1)
 12a:	00000097          	auipc	ra,0x0
 12e:	29a080e7          	jalr	666(ra) # 3c4 <open>
 132:	892a                	mv	s2,a0
 134:	04054063          	bltz	a0,174 <main+0x78>
      printf("wc: cannot open %s\n", argv[i]);
      exit();
    }
    wc(fd, argv[i]);
 138:	608c                	ld	a1,0(s1)
 13a:	00000097          	auipc	ra,0x0
 13e:	ec6080e7          	jalr	-314(ra) # 0 <wc>
    close(fd);
 142:	854a                	mv	a0,s2
 144:	00000097          	auipc	ra,0x0
 148:	268080e7          	jalr	616(ra) # 3ac <close>
  for(i = 1; i < argc; i++){
 14c:	04a1                	addi	s1,s1,8
 14e:	fd349ce3          	bne	s1,s3,126 <main+0x2a>
  }
  exit();
 152:	00000097          	auipc	ra,0x0
 156:	232080e7          	jalr	562(ra) # 384 <exit>
    wc(0, "");
 15a:	00000597          	auipc	a1,0x0
 15e:	78e58593          	addi	a1,a1,1934 # 8e8 <malloc+0x10e>
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	e9c080e7          	jalr	-356(ra) # 0 <wc>
    exit();
 16c:	00000097          	auipc	ra,0x0
 170:	218080e7          	jalr	536(ra) # 384 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 174:	608c                	ld	a1,0(s1)
 176:	00000517          	auipc	a0,0x0
 17a:	77a50513          	addi	a0,a0,1914 # 8f0 <malloc+0x116>
 17e:	00000097          	auipc	ra,0x0
 182:	59e080e7          	jalr	1438(ra) # 71c <printf>
      exit();
 186:	00000097          	auipc	ra,0x0
 18a:	1fe080e7          	jalr	510(ra) # 384 <exit>

000000000000018e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 18e:	1141                	addi	sp,sp,-16
 190:	e422                	sd	s0,8(sp)
 192:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 194:	87aa                	mv	a5,a0
 196:	0585                	addi	a1,a1,1
 198:	0785                	addi	a5,a5,1
 19a:	fff5c703          	lbu	a4,-1(a1)
 19e:	fee78fa3          	sb	a4,-1(a5)
 1a2:	fb75                	bnez	a4,196 <strcpy+0x8>
    ;
  return os;
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cb91                	beqz	a5,1c8 <strcmp+0x1e>
 1b6:	0005c703          	lbu	a4,0(a1)
 1ba:	00f71763          	bne	a4,a5,1c8 <strcmp+0x1e>
    p++, q++;
 1be:	0505                	addi	a0,a0,1
 1c0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c2:	00054783          	lbu	a5,0(a0)
 1c6:	fbe5                	bnez	a5,1b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1c8:	0005c503          	lbu	a0,0(a1)
}
 1cc:	40a7853b          	subw	a0,a5,a0
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strlen>:

uint
strlen(const char *s)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cf91                	beqz	a5,1fc <strlen+0x26>
 1e2:	0505                	addi	a0,a0,1
 1e4:	87aa                	mv	a5,a0
 1e6:	4685                	li	a3,1
 1e8:	9e89                	subw	a3,a3,a0
 1ea:	00f6853b          	addw	a0,a3,a5
 1ee:	0785                	addi	a5,a5,1
 1f0:	fff7c703          	lbu	a4,-1(a5)
 1f4:	fb7d                	bnez	a4,1ea <strlen+0x14>
    ;
  return n;
}
 1f6:	6422                	ld	s0,8(sp)
 1f8:	0141                	addi	sp,sp,16
 1fa:	8082                	ret
  for(n = 0; s[n]; n++)
 1fc:	4501                	li	a0,0
 1fe:	bfe5                	j	1f6 <strlen+0x20>

0000000000000200 <memset>:

void*
memset(void *dst, int c, uint n)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 206:	ce09                	beqz	a2,220 <memset+0x20>
 208:	87aa                	mv	a5,a0
 20a:	fff6071b          	addiw	a4,a2,-1
 20e:	1702                	slli	a4,a4,0x20
 210:	9301                	srli	a4,a4,0x20
 212:	0705                	addi	a4,a4,1
 214:	972a                	add	a4,a4,a0
    cdst[i] = c;
 216:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21a:	0785                	addi	a5,a5,1
 21c:	fee79de3          	bne	a5,a4,216 <memset+0x16>
  }
  return dst;
}
 220:	6422                	ld	s0,8(sp)
 222:	0141                	addi	sp,sp,16
 224:	8082                	ret

0000000000000226 <strchr>:

char*
strchr(const char *s, char c)
{
 226:	1141                	addi	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22c:	00054783          	lbu	a5,0(a0)
 230:	cb99                	beqz	a5,246 <strchr+0x20>
    if(*s == c)
 232:	00f58763          	beq	a1,a5,240 <strchr+0x1a>
  for(; *s; s++)
 236:	0505                	addi	a0,a0,1
 238:	00054783          	lbu	a5,0(a0)
 23c:	fbfd                	bnez	a5,232 <strchr+0xc>
      return (char*)s;
  return 0;
 23e:	4501                	li	a0,0
}
 240:	6422                	ld	s0,8(sp)
 242:	0141                	addi	sp,sp,16
 244:	8082                	ret
  return 0;
 246:	4501                	li	a0,0
 248:	bfe5                	j	240 <strchr+0x1a>

000000000000024a <gets>:

char*
gets(char *buf, int max)
{
 24a:	711d                	addi	sp,sp,-96
 24c:	ec86                	sd	ra,88(sp)
 24e:	e8a2                	sd	s0,80(sp)
 250:	e4a6                	sd	s1,72(sp)
 252:	e0ca                	sd	s2,64(sp)
 254:	fc4e                	sd	s3,56(sp)
 256:	f852                	sd	s4,48(sp)
 258:	f456                	sd	s5,40(sp)
 25a:	f05a                	sd	s6,32(sp)
 25c:	ec5e                	sd	s7,24(sp)
 25e:	1080                	addi	s0,sp,96
 260:	8baa                	mv	s7,a0
 262:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 264:	892a                	mv	s2,a0
 266:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 268:	4aa9                	li	s5,10
 26a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26c:	89a6                	mv	s3,s1
 26e:	2485                	addiw	s1,s1,1
 270:	0344d863          	bge	s1,s4,2a0 <gets+0x56>
    cc = read(0, &c, 1);
 274:	4605                	li	a2,1
 276:	faf40593          	addi	a1,s0,-81
 27a:	4501                	li	a0,0
 27c:	00000097          	auipc	ra,0x0
 280:	120080e7          	jalr	288(ra) # 39c <read>
    if(cc < 1)
 284:	00a05e63          	blez	a0,2a0 <gets+0x56>
    buf[i++] = c;
 288:	faf44783          	lbu	a5,-81(s0)
 28c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 290:	01578763          	beq	a5,s5,29e <gets+0x54>
 294:	0905                	addi	s2,s2,1
 296:	fd679be3          	bne	a5,s6,26c <gets+0x22>
  for(i=0; i+1 < max; ){
 29a:	89a6                	mv	s3,s1
 29c:	a011                	j	2a0 <gets+0x56>
 29e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a0:	99de                	add	s3,s3,s7
 2a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a6:	855e                	mv	a0,s7
 2a8:	60e6                	ld	ra,88(sp)
 2aa:	6446                	ld	s0,80(sp)
 2ac:	64a6                	ld	s1,72(sp)
 2ae:	6906                	ld	s2,64(sp)
 2b0:	79e2                	ld	s3,56(sp)
 2b2:	7a42                	ld	s4,48(sp)
 2b4:	7aa2                	ld	s5,40(sp)
 2b6:	7b02                	ld	s6,32(sp)
 2b8:	6be2                	ld	s7,24(sp)
 2ba:	6125                	addi	sp,sp,96
 2bc:	8082                	ret

00000000000002be <stat>:

int
stat(const char *n, struct stat *st)
{
 2be:	1101                	addi	sp,sp,-32
 2c0:	ec06                	sd	ra,24(sp)
 2c2:	e822                	sd	s0,16(sp)
 2c4:	e426                	sd	s1,8(sp)
 2c6:	e04a                	sd	s2,0(sp)
 2c8:	1000                	addi	s0,sp,32
 2ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2cc:	4581                	li	a1,0
 2ce:	00000097          	auipc	ra,0x0
 2d2:	0f6080e7          	jalr	246(ra) # 3c4 <open>
  if(fd < 0)
 2d6:	02054563          	bltz	a0,300 <stat+0x42>
 2da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2dc:	85ca                	mv	a1,s2
 2de:	00000097          	auipc	ra,0x0
 2e2:	0fe080e7          	jalr	254(ra) # 3dc <fstat>
 2e6:	892a                	mv	s2,a0
  close(fd);
 2e8:	8526                	mv	a0,s1
 2ea:	00000097          	auipc	ra,0x0
 2ee:	0c2080e7          	jalr	194(ra) # 3ac <close>
  return r;
}
 2f2:	854a                	mv	a0,s2
 2f4:	60e2                	ld	ra,24(sp)
 2f6:	6442                	ld	s0,16(sp)
 2f8:	64a2                	ld	s1,8(sp)
 2fa:	6902                	ld	s2,0(sp)
 2fc:	6105                	addi	sp,sp,32
 2fe:	8082                	ret
    return -1;
 300:	597d                	li	s2,-1
 302:	bfc5                	j	2f2 <stat+0x34>

0000000000000304 <atoi>:

int
atoi(const char *s)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30a:	00054603          	lbu	a2,0(a0)
 30e:	fd06079b          	addiw	a5,a2,-48
 312:	0ff7f793          	andi	a5,a5,255
 316:	4725                	li	a4,9
 318:	02f76963          	bltu	a4,a5,34a <atoi+0x46>
 31c:	86aa                	mv	a3,a0
  n = 0;
 31e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 320:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 322:	0685                	addi	a3,a3,1
 324:	0025179b          	slliw	a5,a0,0x2
 328:	9fa9                	addw	a5,a5,a0
 32a:	0017979b          	slliw	a5,a5,0x1
 32e:	9fb1                	addw	a5,a5,a2
 330:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 334:	0006c603          	lbu	a2,0(a3)
 338:	fd06071b          	addiw	a4,a2,-48
 33c:	0ff77713          	andi	a4,a4,255
 340:	fee5f1e3          	bgeu	a1,a4,322 <atoi+0x1e>
  return n;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  n = 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <atoi+0x40>

000000000000034e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e422                	sd	s0,8(sp)
 352:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 354:	02c05163          	blez	a2,376 <memmove+0x28>
 358:	fff6071b          	addiw	a4,a2,-1
 35c:	1702                	slli	a4,a4,0x20
 35e:	9301                	srli	a4,a4,0x20
 360:	0705                	addi	a4,a4,1
 362:	972a                	add	a4,a4,a0
  dst = vdst;
 364:	87aa                	mv	a5,a0
    *dst++ = *src++;
 366:	0585                	addi	a1,a1,1
 368:	0785                	addi	a5,a5,1
 36a:	fff5c683          	lbu	a3,-1(a1)
 36e:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 372:	fee79ae3          	bne	a5,a4,366 <memmove+0x18>
  return vdst;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37c:	4885                	li	a7,1
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <exit>:
.global exit
exit:
 li a7, SYS_exit
 384:	4889                	li	a7,2
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <wait>:
.global wait
wait:
 li a7, SYS_wait
 38c:	488d                	li	a7,3
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 394:	4891                	li	a7,4
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <read>:
.global read
read:
 li a7, SYS_read
 39c:	4895                	li	a7,5
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <write>:
.global write
write:
 li a7, SYS_write
 3a4:	48c1                	li	a7,16
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <close>:
.global close
close:
 li a7, SYS_close
 3ac:	48d5                	li	a7,21
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b4:	4899                	li	a7,6
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3bc:	489d                	li	a7,7
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <open>:
.global open
open:
 li a7, SYS_open
 3c4:	48bd                	li	a7,15
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3cc:	48c5                	li	a7,17
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d4:	48c9                	li	a7,18
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3dc:	48a1                	li	a7,8
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <link>:
.global link
link:
 li a7, SYS_link
 3e4:	48cd                	li	a7,19
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ec:	48d1                	li	a7,20
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f4:	48a5                	li	a7,9
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fc:	48a9                	li	a7,10
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 404:	48ad                	li	a7,11
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40c:	48b1                	li	a7,12
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 414:	48b5                	li	a7,13
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41c:	48b9                	li	a7,14
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 424:	48d9                	li	a7,22
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <crash>:
.global crash
crash:
 li a7, SYS_crash
 42c:	48dd                	li	a7,23
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <mount>:
.global mount
mount:
 li a7, SYS_mount
 434:	48e1                	li	a7,24
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <umount>:
.global umount
umount:
 li a7, SYS_umount
 43c:	48e5                	li	a7,25
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 450:	4605                	li	a2,1
 452:	fef40593          	addi	a1,s0,-17
 456:	00000097          	auipc	ra,0x0
 45a:	f4e080e7          	jalr	-178(ra) # 3a4 <write>
}
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 466:	7139                	addi	sp,sp,-64
 468:	fc06                	sd	ra,56(sp)
 46a:	f822                	sd	s0,48(sp)
 46c:	f426                	sd	s1,40(sp)
 46e:	f04a                	sd	s2,32(sp)
 470:	ec4e                	sd	s3,24(sp)
 472:	0080                	addi	s0,sp,64
 474:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c299                	beqz	a3,47c <printint+0x16>
 478:	0805c863          	bltz	a1,508 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 47c:	2581                	sext.w	a1,a1
  neg = 0;
 47e:	4881                	li	a7,0
 480:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 484:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 486:	2601                	sext.w	a2,a2
 488:	00000517          	auipc	a0,0x0
 48c:	48850513          	addi	a0,a0,1160 # 910 <digits>
 490:	883a                	mv	a6,a4
 492:	2705                	addiw	a4,a4,1
 494:	02c5f7bb          	remuw	a5,a1,a2
 498:	1782                	slli	a5,a5,0x20
 49a:	9381                	srli	a5,a5,0x20
 49c:	97aa                	add	a5,a5,a0
 49e:	0007c783          	lbu	a5,0(a5)
 4a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a6:	0005879b          	sext.w	a5,a1
 4aa:	02c5d5bb          	divuw	a1,a1,a2
 4ae:	0685                	addi	a3,a3,1
 4b0:	fec7f0e3          	bgeu	a5,a2,490 <printint+0x2a>
  if(neg)
 4b4:	00088b63          	beqz	a7,4ca <printint+0x64>
    buf[i++] = '-';
 4b8:	fd040793          	addi	a5,s0,-48
 4bc:	973e                	add	a4,a4,a5
 4be:	02d00793          	li	a5,45
 4c2:	fef70823          	sb	a5,-16(a4)
 4c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ca:	02e05863          	blez	a4,4fa <printint+0x94>
 4ce:	fc040793          	addi	a5,s0,-64
 4d2:	00e78933          	add	s2,a5,a4
 4d6:	fff78993          	addi	s3,a5,-1
 4da:	99ba                	add	s3,s3,a4
 4dc:	377d                	addiw	a4,a4,-1
 4de:	1702                	slli	a4,a4,0x20
 4e0:	9301                	srli	a4,a4,0x20
 4e2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e6:	fff94583          	lbu	a1,-1(s2)
 4ea:	8526                	mv	a0,s1
 4ec:	00000097          	auipc	ra,0x0
 4f0:	f58080e7          	jalr	-168(ra) # 444 <putc>
  while(--i >= 0)
 4f4:	197d                	addi	s2,s2,-1
 4f6:	ff3918e3          	bne	s2,s3,4e6 <printint+0x80>
}
 4fa:	70e2                	ld	ra,56(sp)
 4fc:	7442                	ld	s0,48(sp)
 4fe:	74a2                	ld	s1,40(sp)
 500:	7902                	ld	s2,32(sp)
 502:	69e2                	ld	s3,24(sp)
 504:	6121                	addi	sp,sp,64
 506:	8082                	ret
    x = -xx;
 508:	40b005bb          	negw	a1,a1
    neg = 1;
 50c:	4885                	li	a7,1
    x = -xx;
 50e:	bf8d                	j	480 <printint+0x1a>

0000000000000510 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 510:	7119                	addi	sp,sp,-128
 512:	fc86                	sd	ra,120(sp)
 514:	f8a2                	sd	s0,112(sp)
 516:	f4a6                	sd	s1,104(sp)
 518:	f0ca                	sd	s2,96(sp)
 51a:	ecce                	sd	s3,88(sp)
 51c:	e8d2                	sd	s4,80(sp)
 51e:	e4d6                	sd	s5,72(sp)
 520:	e0da                	sd	s6,64(sp)
 522:	fc5e                	sd	s7,56(sp)
 524:	f862                	sd	s8,48(sp)
 526:	f466                	sd	s9,40(sp)
 528:	f06a                	sd	s10,32(sp)
 52a:	ec6e                	sd	s11,24(sp)
 52c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 52e:	0005c903          	lbu	s2,0(a1)
 532:	18090f63          	beqz	s2,6d0 <vprintf+0x1c0>
 536:	8aaa                	mv	s5,a0
 538:	8b32                	mv	s6,a2
 53a:	00158493          	addi	s1,a1,1
  state = 0;
 53e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 540:	02500a13          	li	s4,37
      if(c == 'd'){
 544:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 548:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 54c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 550:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 554:	00000b97          	auipc	s7,0x0
 558:	3bcb8b93          	addi	s7,s7,956 # 910 <digits>
 55c:	a839                	j	57a <vprintf+0x6a>
        putc(fd, c);
 55e:	85ca                	mv	a1,s2
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ee2080e7          	jalr	-286(ra) # 444 <putc>
 56a:	a019                	j	570 <vprintf+0x60>
    } else if(state == '%'){
 56c:	01498f63          	beq	s3,s4,58a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 570:	0485                	addi	s1,s1,1
 572:	fff4c903          	lbu	s2,-1(s1)
 576:	14090d63          	beqz	s2,6d0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 57a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 57e:	fe0997e3          	bnez	s3,56c <vprintf+0x5c>
      if(c == '%'){
 582:	fd479ee3          	bne	a5,s4,55e <vprintf+0x4e>
        state = '%';
 586:	89be                	mv	s3,a5
 588:	b7e5                	j	570 <vprintf+0x60>
      if(c == 'd'){
 58a:	05878063          	beq	a5,s8,5ca <vprintf+0xba>
      } else if(c == 'l') {
 58e:	05978c63          	beq	a5,s9,5e6 <vprintf+0xd6>
      } else if(c == 'x') {
 592:	07a78863          	beq	a5,s10,602 <vprintf+0xf2>
      } else if(c == 'p') {
 596:	09b78463          	beq	a5,s11,61e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 59a:	07300713          	li	a4,115
 59e:	0ce78663          	beq	a5,a4,66a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5a2:	06300713          	li	a4,99
 5a6:	0ee78e63          	beq	a5,a4,6a2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5aa:	11478863          	beq	a5,s4,6ba <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ae:	85d2                	mv	a1,s4
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	e92080e7          	jalr	-366(ra) # 444 <putc>
        putc(fd, c);
 5ba:	85ca                	mv	a1,s2
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e86080e7          	jalr	-378(ra) # 444 <putc>
      }
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b765                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	4685                	li	a3,1
 5d0:	4629                	li	a2,10
 5d2:	000b2583          	lw	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e8e080e7          	jalr	-370(ra) # 466 <printint>
 5e0:	8b4a                	mv	s6,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	b771                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e6:	008b0913          	addi	s2,s6,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000b2583          	lw	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	e72080e7          	jalr	-398(ra) # 466 <printint>
 5fc:	8b4a                	mv	s6,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf85                	j	570 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 602:	008b0913          	addi	s2,s6,8
 606:	4681                	li	a3,0
 608:	4641                	li	a2,16
 60a:	000b2583          	lw	a1,0(s6)
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e56080e7          	jalr	-426(ra) # 466 <printint>
 618:	8b4a                	mv	s6,s2
      state = 0;
 61a:	4981                	li	s3,0
 61c:	bf91                	j	570 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 61e:	008b0793          	addi	a5,s6,8
 622:	f8f43423          	sd	a5,-120(s0)
 626:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 62a:	03000593          	li	a1,48
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e14080e7          	jalr	-492(ra) # 444 <putc>
  putc(fd, 'x');
 638:	85ea                	mv	a1,s10
 63a:	8556                	mv	a0,s5
 63c:	00000097          	auipc	ra,0x0
 640:	e08080e7          	jalr	-504(ra) # 444 <putc>
 644:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 646:	03c9d793          	srli	a5,s3,0x3c
 64a:	97de                	add	a5,a5,s7
 64c:	0007c583          	lbu	a1,0(a5)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	df2080e7          	jalr	-526(ra) # 444 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 65a:	0992                	slli	s3,s3,0x4
 65c:	397d                	addiw	s2,s2,-1
 65e:	fe0914e3          	bnez	s2,646 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 662:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 666:	4981                	li	s3,0
 668:	b721                	j	570 <vprintf+0x60>
        s = va_arg(ap, char*);
 66a:	008b0993          	addi	s3,s6,8
 66e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 672:	02090163          	beqz	s2,694 <vprintf+0x184>
        while(*s != 0){
 676:	00094583          	lbu	a1,0(s2)
 67a:	c9a1                	beqz	a1,6ca <vprintf+0x1ba>
          putc(fd, *s);
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	dc6080e7          	jalr	-570(ra) # 444 <putc>
          s++;
 686:	0905                	addi	s2,s2,1
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	f9e5                	bnez	a1,67c <vprintf+0x16c>
        s = va_arg(ap, char*);
 68e:	8b4e                	mv	s6,s3
      state = 0;
 690:	4981                	li	s3,0
 692:	bdf9                	j	570 <vprintf+0x60>
          s = "(null)";
 694:	00000917          	auipc	s2,0x0
 698:	27490913          	addi	s2,s2,628 # 908 <malloc+0x12e>
        while(*s != 0){
 69c:	02800593          	li	a1,40
 6a0:	bff1                	j	67c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	000b4583          	lbu	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d98080e7          	jalr	-616(ra) # 444 <putc>
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bd65                	j	570 <vprintf+0x60>
        putc(fd, c);
 6ba:	85d2                	mv	a1,s4
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	d86080e7          	jalr	-634(ra) # 444 <putc>
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b565                	j	570 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ca:	8b4e                	mv	s6,s3
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	b54d                	j	570 <vprintf+0x60>
    }
  }
}
 6d0:	70e6                	ld	ra,120(sp)
 6d2:	7446                	ld	s0,112(sp)
 6d4:	74a6                	ld	s1,104(sp)
 6d6:	7906                	ld	s2,96(sp)
 6d8:	69e6                	ld	s3,88(sp)
 6da:	6a46                	ld	s4,80(sp)
 6dc:	6aa6                	ld	s5,72(sp)
 6de:	6b06                	ld	s6,64(sp)
 6e0:	7be2                	ld	s7,56(sp)
 6e2:	7c42                	ld	s8,48(sp)
 6e4:	7ca2                	ld	s9,40(sp)
 6e6:	7d02                	ld	s10,32(sp)
 6e8:	6de2                	ld	s11,24(sp)
 6ea:	6109                	addi	sp,sp,128
 6ec:	8082                	ret

00000000000006ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ee:	715d                	addi	sp,sp,-80
 6f0:	ec06                	sd	ra,24(sp)
 6f2:	e822                	sd	s0,16(sp)
 6f4:	1000                	addi	s0,sp,32
 6f6:	e010                	sd	a2,0(s0)
 6f8:	e414                	sd	a3,8(s0)
 6fa:	e818                	sd	a4,16(s0)
 6fc:	ec1c                	sd	a5,24(s0)
 6fe:	03043023          	sd	a6,32(s0)
 702:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 706:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 70a:	8622                	mv	a2,s0
 70c:	00000097          	auipc	ra,0x0
 710:	e04080e7          	jalr	-508(ra) # 510 <vprintf>
}
 714:	60e2                	ld	ra,24(sp)
 716:	6442                	ld	s0,16(sp)
 718:	6161                	addi	sp,sp,80
 71a:	8082                	ret

000000000000071c <printf>:

void
printf(const char *fmt, ...)
{
 71c:	711d                	addi	sp,sp,-96
 71e:	ec06                	sd	ra,24(sp)
 720:	e822                	sd	s0,16(sp)
 722:	1000                	addi	s0,sp,32
 724:	e40c                	sd	a1,8(s0)
 726:	e810                	sd	a2,16(s0)
 728:	ec14                	sd	a3,24(s0)
 72a:	f018                	sd	a4,32(s0)
 72c:	f41c                	sd	a5,40(s0)
 72e:	03043823          	sd	a6,48(s0)
 732:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 736:	00840613          	addi	a2,s0,8
 73a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 73e:	85aa                	mv	a1,a0
 740:	4505                	li	a0,1
 742:	00000097          	auipc	ra,0x0
 746:	dce080e7          	jalr	-562(ra) # 510 <vprintf>
}
 74a:	60e2                	ld	ra,24(sp)
 74c:	6442                	ld	s0,16(sp)
 74e:	6125                	addi	sp,sp,96
 750:	8082                	ret

0000000000000752 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 752:	1141                	addi	sp,sp,-16
 754:	e422                	sd	s0,8(sp)
 756:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 758:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	00000797          	auipc	a5,0x0
 760:	1cc7b783          	ld	a5,460(a5) # 928 <freep>
 764:	a805                	j	794 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 766:	4618                	lw	a4,8(a2)
 768:	9db9                	addw	a1,a1,a4
 76a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 76e:	6398                	ld	a4,0(a5)
 770:	6318                	ld	a4,0(a4)
 772:	fee53823          	sd	a4,-16(a0)
 776:	a091                	j	7ba <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 778:	ff852703          	lw	a4,-8(a0)
 77c:	9e39                	addw	a2,a2,a4
 77e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 780:	ff053703          	ld	a4,-16(a0)
 784:	e398                	sd	a4,0(a5)
 786:	a099                	j	7cc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	6398                	ld	a4,0(a5)
 78a:	00e7e463          	bltu	a5,a4,792 <free+0x40>
 78e:	00e6ea63          	bltu	a3,a4,7a2 <free+0x50>
{
 792:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	fed7fae3          	bgeu	a5,a3,788 <free+0x36>
 798:	6398                	ld	a4,0(a5)
 79a:	00e6e463          	bltu	a3,a4,7a2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 79e:	fee7eae3          	bltu	a5,a4,792 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7a2:	ff852583          	lw	a1,-8(a0)
 7a6:	6390                	ld	a2,0(a5)
 7a8:	02059713          	slli	a4,a1,0x20
 7ac:	9301                	srli	a4,a4,0x20
 7ae:	0712                	slli	a4,a4,0x4
 7b0:	9736                	add	a4,a4,a3
 7b2:	fae60ae3          	beq	a2,a4,766 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7b6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ba:	4790                	lw	a2,8(a5)
 7bc:	02061713          	slli	a4,a2,0x20
 7c0:	9301                	srli	a4,a4,0x20
 7c2:	0712                	slli	a4,a4,0x4
 7c4:	973e                	add	a4,a4,a5
 7c6:	fae689e3          	beq	a3,a4,778 <free+0x26>
  } else
    p->s.ptr = bp;
 7ca:	e394                	sd	a3,0(a5)
  freep = p;
 7cc:	00000717          	auipc	a4,0x0
 7d0:	14f73e23          	sd	a5,348(a4) # 928 <freep>
}
 7d4:	6422                	ld	s0,8(sp)
 7d6:	0141                	addi	sp,sp,16
 7d8:	8082                	ret

00000000000007da <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7da:	7139                	addi	sp,sp,-64
 7dc:	fc06                	sd	ra,56(sp)
 7de:	f822                	sd	s0,48(sp)
 7e0:	f426                	sd	s1,40(sp)
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	ec4e                	sd	s3,24(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
 7ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ee:	02051493          	slli	s1,a0,0x20
 7f2:	9081                	srli	s1,s1,0x20
 7f4:	04bd                	addi	s1,s1,15
 7f6:	8091                	srli	s1,s1,0x4
 7f8:	0014899b          	addiw	s3,s1,1
 7fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7fe:	00000517          	auipc	a0,0x0
 802:	12a53503          	ld	a0,298(a0) # 928 <freep>
 806:	c515                	beqz	a0,832 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 808:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80a:	4798                	lw	a4,8(a5)
 80c:	02977f63          	bgeu	a4,s1,84a <malloc+0x70>
 810:	8a4e                	mv	s4,s3
 812:	0009871b          	sext.w	a4,s3
 816:	6685                	lui	a3,0x1
 818:	00d77363          	bgeu	a4,a3,81e <malloc+0x44>
 81c:	6a05                	lui	s4,0x1
 81e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 822:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 826:	00000917          	auipc	s2,0x0
 82a:	10290913          	addi	s2,s2,258 # 928 <freep>
  if(p == (char*)-1)
 82e:	5afd                	li	s5,-1
 830:	a88d                	j	8a2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 832:	00000797          	auipc	a5,0x0
 836:	2fe78793          	addi	a5,a5,766 # b30 <base>
 83a:	00000717          	auipc	a4,0x0
 83e:	0ef73723          	sd	a5,238(a4) # 928 <freep>
 842:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 844:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 848:	b7e1                	j	810 <malloc+0x36>
      if(p->s.size == nunits)
 84a:	02e48b63          	beq	s1,a4,880 <malloc+0xa6>
        p->s.size -= nunits;
 84e:	4137073b          	subw	a4,a4,s3
 852:	c798                	sw	a4,8(a5)
        p += p->s.size;
 854:	1702                	slli	a4,a4,0x20
 856:	9301                	srli	a4,a4,0x20
 858:	0712                	slli	a4,a4,0x4
 85a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 85c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 860:	00000717          	auipc	a4,0x0
 864:	0ca73423          	sd	a0,200(a4) # 928 <freep>
      return (void*)(p + 1);
 868:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 86c:	70e2                	ld	ra,56(sp)
 86e:	7442                	ld	s0,48(sp)
 870:	74a2                	ld	s1,40(sp)
 872:	7902                	ld	s2,32(sp)
 874:	69e2                	ld	s3,24(sp)
 876:	6a42                	ld	s4,16(sp)
 878:	6aa2                	ld	s5,8(sp)
 87a:	6b02                	ld	s6,0(sp)
 87c:	6121                	addi	sp,sp,64
 87e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 880:	6398                	ld	a4,0(a5)
 882:	e118                	sd	a4,0(a0)
 884:	bff1                	j	860 <malloc+0x86>
  hp->s.size = nu;
 886:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88a:	0541                	addi	a0,a0,16
 88c:	00000097          	auipc	ra,0x0
 890:	ec6080e7          	jalr	-314(ra) # 752 <free>
  return freep;
 894:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 898:	d971                	beqz	a0,86c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 89c:	4798                	lw	a4,8(a5)
 89e:	fa9776e3          	bgeu	a4,s1,84a <malloc+0x70>
    if(p == freep)
 8a2:	00093703          	ld	a4,0(s2)
 8a6:	853e                	mv	a0,a5
 8a8:	fef719e3          	bne	a4,a5,89a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8ac:	8552                	mv	a0,s4
 8ae:	00000097          	auipc	ra,0x0
 8b2:	b5e080e7          	jalr	-1186(ra) # 40c <sbrk>
  if(p == (char*)-1)
 8b6:	fd5518e3          	bne	a0,s5,886 <malloc+0xac>
        return 0;
 8ba:	4501                	li	a0,0
 8bc:	bf45                	j	86c <malloc+0x92>
