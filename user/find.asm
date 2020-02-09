
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	442080e7          	jalr	1090(ra) # 452 <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	416080e7          	jalr	1046(ra) # 452 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	3f4080e7          	jalr	1012(ra) # 452 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	b7a98993          	addi	s3,s3,-1158 # be0 <buf.1108>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	554080e7          	jalr	1364(ra) # 5ca <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	3d2080e7          	jalr	978(ra) # 452 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	3c4080e7          	jalr	964(ra) # 452 <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	3d4080e7          	jalr	980(ra) # 47c <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
  b4:	7179                	addi	sp,sp,-48
  b6:	f406                	sd	ra,40(sp)
  b8:	f022                	sd	s0,32(sp)
  ba:	ec26                	sd	s1,24(sp)
  bc:	e84a                	sd	s2,16(sp)
  be:	e44e                	sd	s3,8(sp)
  c0:	e052                	sd	s4,0(sp)
  c2:	1800                	addi	s0,sp,48
  c4:	892a                	mv	s2,a0
  c6:	89ae                	mv	s3,a1
  c8:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  ca:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  ce:	85a6                	mv	a1,s1
  d0:	854e                	mv	a0,s3
  d2:	00000097          	auipc	ra,0x0
  d6:	030080e7          	jalr	48(ra) # 102 <matchhere>
  da:	e919                	bnez	a0,f0 <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  dc:	0004c783          	lbu	a5,0(s1)
  e0:	cb89                	beqz	a5,f2 <matchstar+0x3e>
  e2:	0485                	addi	s1,s1,1
  e4:	2781                	sext.w	a5,a5
  e6:	ff2784e3          	beq	a5,s2,ce <matchstar+0x1a>
  ea:	ff4902e3          	beq	s2,s4,ce <matchstar+0x1a>
  ee:	a011                	j	f2 <matchstar+0x3e>
      return 1;
  f0:	4505                	li	a0,1
  return 0;
}
  f2:	70a2                	ld	ra,40(sp)
  f4:	7402                	ld	s0,32(sp)
  f6:	64e2                	ld	s1,24(sp)
  f8:	6942                	ld	s2,16(sp)
  fa:	69a2                	ld	s3,8(sp)
  fc:	6a02                	ld	s4,0(sp)
  fe:	6145                	addi	sp,sp,48
 100:	8082                	ret

0000000000000102 <matchhere>:
  if(re[0] == '\0')
 102:	00054703          	lbu	a4,0(a0)
 106:	cb3d                	beqz	a4,17c <matchhere+0x7a>
{
 108:	1141                	addi	sp,sp,-16
 10a:	e406                	sd	ra,8(sp)
 10c:	e022                	sd	s0,0(sp)
 10e:	0800                	addi	s0,sp,16
 110:	87aa                	mv	a5,a0
  if(re[1] == '*')
 112:	00154683          	lbu	a3,1(a0)
 116:	02a00613          	li	a2,42
 11a:	02c68563          	beq	a3,a2,144 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
 11e:	02400613          	li	a2,36
 122:	02c70a63          	beq	a4,a2,156 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 126:	0005c683          	lbu	a3,0(a1)
  return 0;
 12a:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 12c:	ca81                	beqz	a3,13c <matchhere+0x3a>
 12e:	02e00613          	li	a2,46
 132:	02c70d63          	beq	a4,a2,16c <matchhere+0x6a>
  return 0;
 136:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 138:	02d70a63          	beq	a4,a3,16c <matchhere+0x6a>
}
 13c:	60a2                	ld	ra,8(sp)
 13e:	6402                	ld	s0,0(sp)
 140:	0141                	addi	sp,sp,16
 142:	8082                	ret
    return matchstar(re[0], re+2, text);
 144:	862e                	mv	a2,a1
 146:	00250593          	addi	a1,a0,2
 14a:	853a                	mv	a0,a4
 14c:	00000097          	auipc	ra,0x0
 150:	f68080e7          	jalr	-152(ra) # b4 <matchstar>
 154:	b7e5                	j	13c <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
 156:	c691                	beqz	a3,162 <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
 158:	0005c683          	lbu	a3,0(a1)
 15c:	fee9                	bnez	a3,136 <matchhere+0x34>
  return 0;
 15e:	4501                	li	a0,0
 160:	bff1                	j	13c <matchhere+0x3a>
    return *text == '\0';
 162:	0005c503          	lbu	a0,0(a1)
 166:	00153513          	seqz	a0,a0
 16a:	bfc9                	j	13c <matchhere+0x3a>
    return matchhere(re+1, text+1);
 16c:	0585                	addi	a1,a1,1
 16e:	00178513          	addi	a0,a5,1
 172:	00000097          	auipc	ra,0x0
 176:	f90080e7          	jalr	-112(ra) # 102 <matchhere>
 17a:	b7c9                	j	13c <matchhere+0x3a>
    return 1;
 17c:	4505                	li	a0,1
}
 17e:	8082                	ret

0000000000000180 <match>:
{
 180:	1101                	addi	sp,sp,-32
 182:	ec06                	sd	ra,24(sp)
 184:	e822                	sd	s0,16(sp)
 186:	e426                	sd	s1,8(sp)
 188:	e04a                	sd	s2,0(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	892a                	mv	s2,a0
 18e:	84ae                	mv	s1,a1
  if(re[0] == '^')
 190:	00054703          	lbu	a4,0(a0)
 194:	05e00793          	li	a5,94
 198:	00f70e63          	beq	a4,a5,1b4 <match+0x34>
    if(matchhere(re, text))
 19c:	85a6                	mv	a1,s1
 19e:	854a                	mv	a0,s2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	f62080e7          	jalr	-158(ra) # 102 <matchhere>
 1a8:	ed01                	bnez	a0,1c0 <match+0x40>
  }while(*text++ != '\0');
 1aa:	0485                	addi	s1,s1,1
 1ac:	fff4c783          	lbu	a5,-1(s1)
 1b0:	f7f5                	bnez	a5,19c <match+0x1c>
 1b2:	a801                	j	1c2 <match+0x42>
    return matchhere(re+1, text);
 1b4:	0505                	addi	a0,a0,1
 1b6:	00000097          	auipc	ra,0x0
 1ba:	f4c080e7          	jalr	-180(ra) # 102 <matchhere>
 1be:	a011                	j	1c2 <match+0x42>
      return 1;
 1c0:	4505                	li	a0,1
}
 1c2:	60e2                	ld	ra,24(sp)
 1c4:	6442                	ld	s0,16(sp)
 1c6:	64a2                	ld	s1,8(sp)
 1c8:	6902                	ld	s2,0(sp)
 1ca:	6105                	addi	sp,sp,32
 1cc:	8082                	ret

00000000000001ce <find>:

void
find(char *path, char *re)
{
 1ce:	d8010113          	addi	sp,sp,-640
 1d2:	26113c23          	sd	ra,632(sp)
 1d6:	26813823          	sd	s0,624(sp)
 1da:	26913423          	sd	s1,616(sp)
 1de:	27213023          	sd	s2,608(sp)
 1e2:	25313c23          	sd	s3,600(sp)
 1e6:	25413823          	sd	s4,592(sp)
 1ea:	25513423          	sd	s5,584(sp)
 1ee:	25613023          	sd	s6,576(sp)
 1f2:	23713c23          	sd	s7,568(sp)
 1f6:	0500                	addi	s0,sp,640
 1f8:	892a                	mv	s2,a0
 1fa:	89ae                	mv	s3,a1
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
 1fc:	4581                	li	a1,0
 1fe:	00000097          	auipc	ra,0x0
 202:	442080e7          	jalr	1090(ra) # 640 <open>
 206:	06054b63          	bltz	a0,27c <find+0xae>
 20a:	84aa                	mv	s1,a0
    fprintf(2, "find: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
 20c:	d8840593          	addi	a1,s0,-632
 210:	00000097          	auipc	ra,0x0
 214:	448080e7          	jalr	1096(ra) # 658 <fstat>
 218:	06054d63          	bltz	a0,292 <find+0xc4>
    fprintf(2, "find: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 21c:	d9041783          	lh	a5,-624(s0)
 220:	0007869b          	sext.w	a3,a5
 224:	4705                	li	a4,1
 226:	0ae68063          	beq	a3,a4,2c6 <find+0xf8>
 22a:	4709                	li	a4,2
 22c:	00e69e63          	bne	a3,a4,248 <find+0x7a>
  case T_FILE:
    if(match(re, fmtname(path)))
 230:	854a                	mv	a0,s2
 232:	00000097          	auipc	ra,0x0
 236:	dce080e7          	jalr	-562(ra) # 0 <fmtname>
 23a:	85aa                	mv	a1,a0
 23c:	854e                	mv	a0,s3
 23e:	00000097          	auipc	ra,0x0
 242:	f42080e7          	jalr	-190(ra) # 180 <match>
 246:	e535                	bnez	a0,2b2 <find+0xe4>

      find(buf, re);
    }
    break;
  }
  close(fd);
 248:	8526                	mv	a0,s1
 24a:	00000097          	auipc	ra,0x0
 24e:	3de080e7          	jalr	990(ra) # 628 <close>
}
 252:	27813083          	ld	ra,632(sp)
 256:	27013403          	ld	s0,624(sp)
 25a:	26813483          	ld	s1,616(sp)
 25e:	26013903          	ld	s2,608(sp)
 262:	25813983          	ld	s3,600(sp)
 266:	25013a03          	ld	s4,592(sp)
 26a:	24813a83          	ld	s5,584(sp)
 26e:	24013b03          	ld	s6,576(sp)
 272:	23813b83          	ld	s7,568(sp)
 276:	28010113          	addi	sp,sp,640
 27a:	8082                	ret
    fprintf(2, "find: cannot open %s\n", path);
 27c:	864a                	mv	a2,s2
 27e:	00001597          	auipc	a1,0x1
 282:	8c258593          	addi	a1,a1,-1854 # b40 <malloc+0xea>
 286:	4509                	li	a0,2
 288:	00000097          	auipc	ra,0x0
 28c:	6e2080e7          	jalr	1762(ra) # 96a <fprintf>
    return;
 290:	b7c9                	j	252 <find+0x84>
    fprintf(2, "find: cannot stat %s\n", path);
 292:	864a                	mv	a2,s2
 294:	00001597          	auipc	a1,0x1
 298:	8c458593          	addi	a1,a1,-1852 # b58 <malloc+0x102>
 29c:	4509                	li	a0,2
 29e:	00000097          	auipc	ra,0x0
 2a2:	6cc080e7          	jalr	1740(ra) # 96a <fprintf>
    close(fd);
 2a6:	8526                	mv	a0,s1
 2a8:	00000097          	auipc	ra,0x0
 2ac:	380080e7          	jalr	896(ra) # 628 <close>
    return;
 2b0:	b74d                	j	252 <find+0x84>
      printf("%s\n", path);
 2b2:	85ca                	mv	a1,s2
 2b4:	00001517          	auipc	a0,0x1
 2b8:	8bc50513          	addi	a0,a0,-1860 # b70 <malloc+0x11a>
 2bc:	00000097          	auipc	ra,0x0
 2c0:	6dc080e7          	jalr	1756(ra) # 998 <printf>
 2c4:	b751                	j	248 <find+0x7a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 2c6:	854a                	mv	a0,s2
 2c8:	00000097          	auipc	ra,0x0
 2cc:	18a080e7          	jalr	394(ra) # 452 <strlen>
 2d0:	2541                	addiw	a0,a0,16
 2d2:	20000793          	li	a5,512
 2d6:	00a7fb63          	bgeu	a5,a0,2ec <find+0x11e>
      printf("find: path too long\n");
 2da:	00001517          	auipc	a0,0x1
 2de:	89e50513          	addi	a0,a0,-1890 # b78 <malloc+0x122>
 2e2:	00000097          	auipc	ra,0x0
 2e6:	6b6080e7          	jalr	1718(ra) # 998 <printf>
      break;
 2ea:	bfb9                	j	248 <find+0x7a>
    strcpy(buf, path);
 2ec:	85ca                	mv	a1,s2
 2ee:	db040513          	addi	a0,s0,-592
 2f2:	00000097          	auipc	ra,0x0
 2f6:	118080e7          	jalr	280(ra) # 40a <strcpy>
    p = buf+strlen(buf);
 2fa:	db040513          	addi	a0,s0,-592
 2fe:	00000097          	auipc	ra,0x0
 302:	154080e7          	jalr	340(ra) # 452 <strlen>
 306:	02051913          	slli	s2,a0,0x20
 30a:	02095913          	srli	s2,s2,0x20
 30e:	db040793          	addi	a5,s0,-592
 312:	993e                	add	s2,s2,a5
    *p++ = '/';
 314:	00190a93          	addi	s5,s2,1
 318:	02f00793          	li	a5,47
 31c:	00f90023          	sb	a5,0(s2)
      if(strlen(de.name) == 1 && de.name[0] == '.')
 320:	4b05                	li	s6,1
      if(strlen(de.name) == 2 && de.name[0] == '.' && de.name[1] == '.')
 322:	4b89                	li	s7,2
 324:	6a0d                	lui	s4,0x3
 326:	e2ea0a13          	addi	s4,s4,-466 # 2e2e <__global_pointer$+0x1a5d>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 32a:	a01d                	j	350 <find+0x182>
        printf("find: cannot stat %s\n", buf);
 32c:	db040593          	addi	a1,s0,-592
 330:	00001517          	auipc	a0,0x1
 334:	82850513          	addi	a0,a0,-2008 # b58 <malloc+0x102>
 338:	00000097          	auipc	ra,0x0
 33c:	660080e7          	jalr	1632(ra) # 998 <printf>
        continue;
 340:	a801                	j	350 <find+0x182>
      find(buf, re);
 342:	85ce                	mv	a1,s3
 344:	db040513          	addi	a0,s0,-592
 348:	00000097          	auipc	ra,0x0
 34c:	e86080e7          	jalr	-378(ra) # 1ce <find>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 350:	4641                	li	a2,16
 352:	da040593          	addi	a1,s0,-608
 356:	8526                	mv	a0,s1
 358:	00000097          	auipc	ra,0x0
 35c:	2c0080e7          	jalr	704(ra) # 618 <read>
 360:	47c1                	li	a5,16
 362:	eef513e3          	bne	a0,a5,248 <find+0x7a>
      if(de.inum == 0)
 366:	da045783          	lhu	a5,-608(s0)
 36a:	d3fd                	beqz	a5,350 <find+0x182>
      memmove(p, de.name, DIRSIZ);
 36c:	4639                	li	a2,14
 36e:	da240593          	addi	a1,s0,-606
 372:	8556                	mv	a0,s5
 374:	00000097          	auipc	ra,0x0
 378:	256080e7          	jalr	598(ra) # 5ca <memmove>
      p[DIRSIZ] = 0;
 37c:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 380:	d8840593          	addi	a1,s0,-632
 384:	db040513          	addi	a0,s0,-592
 388:	00000097          	auipc	ra,0x0
 38c:	1b2080e7          	jalr	434(ra) # 53a <stat>
 390:	f8054ee3          	bltz	a0,32c <find+0x15e>
      if(strlen(de.name) == 1 && de.name[0] == '.')
 394:	da240513          	addi	a0,s0,-606
 398:	00000097          	auipc	ra,0x0
 39c:	0ba080e7          	jalr	186(ra) # 452 <strlen>
 3a0:	2501                	sext.w	a0,a0
 3a2:	01651863          	bne	a0,s6,3b2 <find+0x1e4>
 3a6:	da244703          	lbu	a4,-606(s0)
 3aa:	02e00793          	li	a5,46
 3ae:	faf701e3          	beq	a4,a5,350 <find+0x182>
      if(strlen(de.name) == 2 && de.name[0] == '.' && de.name[1] == '.')
 3b2:	da240513          	addi	a0,s0,-606
 3b6:	00000097          	auipc	ra,0x0
 3ba:	09c080e7          	jalr	156(ra) # 452 <strlen>
 3be:	2501                	sext.w	a0,a0
 3c0:	f97511e3          	bne	a0,s7,342 <find+0x174>
 3c4:	da245783          	lhu	a5,-606(s0)
 3c8:	f7479de3          	bne	a5,s4,342 <find+0x174>
 3cc:	b751                	j	350 <find+0x182>

00000000000003ce <main>:


int main(int argc, char *argv[]) {
 3ce:	1101                	addi	sp,sp,-32
 3d0:	ec06                	sd	ra,24(sp)
 3d2:	e822                	sd	s0,16(sp)
 3d4:	e426                	sd	s1,8(sp)
 3d6:	1000                	addi	s0,sp,32
 3d8:	84ae                	mv	s1,a1
  if(argc <= 2)
 3da:	4789                	li	a5,2
 3dc:	00a7dd63          	bge	a5,a0,3f6 <main+0x28>
    fprintf(2, "find: not enough params provided");
  find(argv[1], argv[2]);
 3e0:	688c                	ld	a1,16(s1)
 3e2:	6488                	ld	a0,8(s1)
 3e4:	00000097          	auipc	ra,0x0
 3e8:	dea080e7          	jalr	-534(ra) # 1ce <find>
  
  exit(0);
 3ec:	4501                	li	a0,0
 3ee:	00000097          	auipc	ra,0x0
 3f2:	212080e7          	jalr	530(ra) # 600 <exit>
    fprintf(2, "find: not enough params provided");
 3f6:	00000597          	auipc	a1,0x0
 3fa:	79a58593          	addi	a1,a1,1946 # b90 <malloc+0x13a>
 3fe:	4509                	li	a0,2
 400:	00000097          	auipc	ra,0x0
 404:	56a080e7          	jalr	1386(ra) # 96a <fprintf>
 408:	bfe1                	j	3e0 <main+0x12>

000000000000040a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 410:	87aa                	mv	a5,a0
 412:	0585                	addi	a1,a1,1
 414:	0785                	addi	a5,a5,1
 416:	fff5c703          	lbu	a4,-1(a1)
 41a:	fee78fa3          	sb	a4,-1(a5)
 41e:	fb75                	bnez	a4,412 <strcpy+0x8>
    ;
  return os;
}
 420:	6422                	ld	s0,8(sp)
 422:	0141                	addi	sp,sp,16
 424:	8082                	ret

0000000000000426 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 42c:	00054783          	lbu	a5,0(a0)
 430:	cb91                	beqz	a5,444 <strcmp+0x1e>
 432:	0005c703          	lbu	a4,0(a1)
 436:	00f71763          	bne	a4,a5,444 <strcmp+0x1e>
    p++, q++;
 43a:	0505                	addi	a0,a0,1
 43c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 43e:	00054783          	lbu	a5,0(a0)
 442:	fbe5                	bnez	a5,432 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 444:	0005c503          	lbu	a0,0(a1)
}
 448:	40a7853b          	subw	a0,a5,a0
 44c:	6422                	ld	s0,8(sp)
 44e:	0141                	addi	sp,sp,16
 450:	8082                	ret

0000000000000452 <strlen>:

uint
strlen(const char *s)
{
 452:	1141                	addi	sp,sp,-16
 454:	e422                	sd	s0,8(sp)
 456:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 458:	00054783          	lbu	a5,0(a0)
 45c:	cf91                	beqz	a5,478 <strlen+0x26>
 45e:	0505                	addi	a0,a0,1
 460:	87aa                	mv	a5,a0
 462:	4685                	li	a3,1
 464:	9e89                	subw	a3,a3,a0
 466:	00f6853b          	addw	a0,a3,a5
 46a:	0785                	addi	a5,a5,1
 46c:	fff7c703          	lbu	a4,-1(a5)
 470:	fb7d                	bnez	a4,466 <strlen+0x14>
    ;
  return n;
}
 472:	6422                	ld	s0,8(sp)
 474:	0141                	addi	sp,sp,16
 476:	8082                	ret
  for(n = 0; s[n]; n++)
 478:	4501                	li	a0,0
 47a:	bfe5                	j	472 <strlen+0x20>

000000000000047c <memset>:

void*
memset(void *dst, int c, uint n)
{
 47c:	1141                	addi	sp,sp,-16
 47e:	e422                	sd	s0,8(sp)
 480:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 482:	ce09                	beqz	a2,49c <memset+0x20>
 484:	87aa                	mv	a5,a0
 486:	fff6071b          	addiw	a4,a2,-1
 48a:	1702                	slli	a4,a4,0x20
 48c:	9301                	srli	a4,a4,0x20
 48e:	0705                	addi	a4,a4,1
 490:	972a                	add	a4,a4,a0
    cdst[i] = c;
 492:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 496:	0785                	addi	a5,a5,1
 498:	fee79de3          	bne	a5,a4,492 <memset+0x16>
  }
  return dst;
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	addi	sp,sp,16
 4a0:	8082                	ret

00000000000004a2 <strchr>:

char*
strchr(const char *s, char c)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e422                	sd	s0,8(sp)
 4a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4a8:	00054783          	lbu	a5,0(a0)
 4ac:	cb99                	beqz	a5,4c2 <strchr+0x20>
    if(*s == c)
 4ae:	00f58763          	beq	a1,a5,4bc <strchr+0x1a>
  for(; *s; s++)
 4b2:	0505                	addi	a0,a0,1
 4b4:	00054783          	lbu	a5,0(a0)
 4b8:	fbfd                	bnez	a5,4ae <strchr+0xc>
      return (char*)s;
  return 0;
 4ba:	4501                	li	a0,0
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret
  return 0;
 4c2:	4501                	li	a0,0
 4c4:	bfe5                	j	4bc <strchr+0x1a>

00000000000004c6 <gets>:

char*
gets(char *buf, int max)
{
 4c6:	711d                	addi	sp,sp,-96
 4c8:	ec86                	sd	ra,88(sp)
 4ca:	e8a2                	sd	s0,80(sp)
 4cc:	e4a6                	sd	s1,72(sp)
 4ce:	e0ca                	sd	s2,64(sp)
 4d0:	fc4e                	sd	s3,56(sp)
 4d2:	f852                	sd	s4,48(sp)
 4d4:	f456                	sd	s5,40(sp)
 4d6:	f05a                	sd	s6,32(sp)
 4d8:	ec5e                	sd	s7,24(sp)
 4da:	1080                	addi	s0,sp,96
 4dc:	8baa                	mv	s7,a0
 4de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4e0:	892a                	mv	s2,a0
 4e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4e4:	4aa9                	li	s5,10
 4e6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4e8:	89a6                	mv	s3,s1
 4ea:	2485                	addiw	s1,s1,1
 4ec:	0344d863          	bge	s1,s4,51c <gets+0x56>
    cc = read(0, &c, 1);
 4f0:	4605                	li	a2,1
 4f2:	faf40593          	addi	a1,s0,-81
 4f6:	4501                	li	a0,0
 4f8:	00000097          	auipc	ra,0x0
 4fc:	120080e7          	jalr	288(ra) # 618 <read>
    if(cc < 1)
 500:	00a05e63          	blez	a0,51c <gets+0x56>
    buf[i++] = c;
 504:	faf44783          	lbu	a5,-81(s0)
 508:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 50c:	01578763          	beq	a5,s5,51a <gets+0x54>
 510:	0905                	addi	s2,s2,1
 512:	fd679be3          	bne	a5,s6,4e8 <gets+0x22>
  for(i=0; i+1 < max; ){
 516:	89a6                	mv	s3,s1
 518:	a011                	j	51c <gets+0x56>
 51a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 51c:	99de                	add	s3,s3,s7
 51e:	00098023          	sb	zero,0(s3)
  return buf;
}
 522:	855e                	mv	a0,s7
 524:	60e6                	ld	ra,88(sp)
 526:	6446                	ld	s0,80(sp)
 528:	64a6                	ld	s1,72(sp)
 52a:	6906                	ld	s2,64(sp)
 52c:	79e2                	ld	s3,56(sp)
 52e:	7a42                	ld	s4,48(sp)
 530:	7aa2                	ld	s5,40(sp)
 532:	7b02                	ld	s6,32(sp)
 534:	6be2                	ld	s7,24(sp)
 536:	6125                	addi	sp,sp,96
 538:	8082                	ret

000000000000053a <stat>:

int
stat(const char *n, struct stat *st)
{
 53a:	1101                	addi	sp,sp,-32
 53c:	ec06                	sd	ra,24(sp)
 53e:	e822                	sd	s0,16(sp)
 540:	e426                	sd	s1,8(sp)
 542:	e04a                	sd	s2,0(sp)
 544:	1000                	addi	s0,sp,32
 546:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 548:	4581                	li	a1,0
 54a:	00000097          	auipc	ra,0x0
 54e:	0f6080e7          	jalr	246(ra) # 640 <open>
  if(fd < 0)
 552:	02054563          	bltz	a0,57c <stat+0x42>
 556:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 558:	85ca                	mv	a1,s2
 55a:	00000097          	auipc	ra,0x0
 55e:	0fe080e7          	jalr	254(ra) # 658 <fstat>
 562:	892a                	mv	s2,a0
  close(fd);
 564:	8526                	mv	a0,s1
 566:	00000097          	auipc	ra,0x0
 56a:	0c2080e7          	jalr	194(ra) # 628 <close>
  return r;
}
 56e:	854a                	mv	a0,s2
 570:	60e2                	ld	ra,24(sp)
 572:	6442                	ld	s0,16(sp)
 574:	64a2                	ld	s1,8(sp)
 576:	6902                	ld	s2,0(sp)
 578:	6105                	addi	sp,sp,32
 57a:	8082                	ret
    return -1;
 57c:	597d                	li	s2,-1
 57e:	bfc5                	j	56e <stat+0x34>

0000000000000580 <atoi>:

int
atoi(const char *s)
{
 580:	1141                	addi	sp,sp,-16
 582:	e422                	sd	s0,8(sp)
 584:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 586:	00054603          	lbu	a2,0(a0)
 58a:	fd06079b          	addiw	a5,a2,-48
 58e:	0ff7f793          	andi	a5,a5,255
 592:	4725                	li	a4,9
 594:	02f76963          	bltu	a4,a5,5c6 <atoi+0x46>
 598:	86aa                	mv	a3,a0
  n = 0;
 59a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 59c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 59e:	0685                	addi	a3,a3,1
 5a0:	0025179b          	slliw	a5,a0,0x2
 5a4:	9fa9                	addw	a5,a5,a0
 5a6:	0017979b          	slliw	a5,a5,0x1
 5aa:	9fb1                	addw	a5,a5,a2
 5ac:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5b0:	0006c603          	lbu	a2,0(a3)
 5b4:	fd06071b          	addiw	a4,a2,-48
 5b8:	0ff77713          	andi	a4,a4,255
 5bc:	fee5f1e3          	bgeu	a1,a4,59e <atoi+0x1e>
  return n;
}
 5c0:	6422                	ld	s0,8(sp)
 5c2:	0141                	addi	sp,sp,16
 5c4:	8082                	ret
  n = 0;
 5c6:	4501                	li	a0,0
 5c8:	bfe5                	j	5c0 <atoi+0x40>

00000000000005ca <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5ca:	1141                	addi	sp,sp,-16
 5cc:	e422                	sd	s0,8(sp)
 5ce:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5d0:	02c05163          	blez	a2,5f2 <memmove+0x28>
 5d4:	fff6071b          	addiw	a4,a2,-1
 5d8:	1702                	slli	a4,a4,0x20
 5da:	9301                	srli	a4,a4,0x20
 5dc:	0705                	addi	a4,a4,1
 5de:	972a                	add	a4,a4,a0
  dst = vdst;
 5e0:	87aa                	mv	a5,a0
    *dst++ = *src++;
 5e2:	0585                	addi	a1,a1,1
 5e4:	0785                	addi	a5,a5,1
 5e6:	fff5c683          	lbu	a3,-1(a1)
 5ea:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 5ee:	fee79ae3          	bne	a5,a4,5e2 <memmove+0x18>
  return vdst;
}
 5f2:	6422                	ld	s0,8(sp)
 5f4:	0141                	addi	sp,sp,16
 5f6:	8082                	ret

00000000000005f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5f8:	4885                	li	a7,1
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <exit>:
.global exit
exit:
 li a7, SYS_exit
 600:	4889                	li	a7,2
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <wait>:
.global wait
wait:
 li a7, SYS_wait
 608:	488d                	li	a7,3
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 610:	4891                	li	a7,4
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <read>:
.global read
read:
 li a7, SYS_read
 618:	4895                	li	a7,5
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <write>:
.global write
write:
 li a7, SYS_write
 620:	48c1                	li	a7,16
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <close>:
.global close
close:
 li a7, SYS_close
 628:	48d5                	li	a7,21
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <kill>:
.global kill
kill:
 li a7, SYS_kill
 630:	4899                	li	a7,6
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <exec>:
.global exec
exec:
 li a7, SYS_exec
 638:	489d                	li	a7,7
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <open>:
.global open
open:
 li a7, SYS_open
 640:	48bd                	li	a7,15
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 648:	48c5                	li	a7,17
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 650:	48c9                	li	a7,18
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 658:	48a1                	li	a7,8
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <link>:
.global link
link:
 li a7, SYS_link
 660:	48cd                	li	a7,19
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 668:	48d1                	li	a7,20
 ecall
 66a:	00000073          	ecall
 ret
 66e:	8082                	ret

0000000000000670 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 670:	48a5                	li	a7,9
 ecall
 672:	00000073          	ecall
 ret
 676:	8082                	ret

0000000000000678 <dup>:
.global dup
dup:
 li a7, SYS_dup
 678:	48a9                	li	a7,10
 ecall
 67a:	00000073          	ecall
 ret
 67e:	8082                	ret

0000000000000680 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 680:	48ad                	li	a7,11
 ecall
 682:	00000073          	ecall
 ret
 686:	8082                	ret

0000000000000688 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 688:	48b1                	li	a7,12
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 690:	48b5                	li	a7,13
 ecall
 692:	00000073          	ecall
 ret
 696:	8082                	ret

0000000000000698 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 698:	48b9                	li	a7,14
 ecall
 69a:	00000073          	ecall
 ret
 69e:	8082                	ret

00000000000006a0 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 6a0:	48d9                	li	a7,22
 ecall
 6a2:	00000073          	ecall
 ret
 6a6:	8082                	ret

00000000000006a8 <crash>:
.global crash
crash:
 li a7, SYS_crash
 6a8:	48dd                	li	a7,23
 ecall
 6aa:	00000073          	ecall
 ret
 6ae:	8082                	ret

00000000000006b0 <mount>:
.global mount
mount:
 li a7, SYS_mount
 6b0:	48e1                	li	a7,24
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <umount>:
.global umount
umount:
 li a7, SYS_umount
 6b8:	48e5                	li	a7,25
 ecall
 6ba:	00000073          	ecall
 ret
 6be:	8082                	ret

00000000000006c0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6c0:	1101                	addi	sp,sp,-32
 6c2:	ec06                	sd	ra,24(sp)
 6c4:	e822                	sd	s0,16(sp)
 6c6:	1000                	addi	s0,sp,32
 6c8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6cc:	4605                	li	a2,1
 6ce:	fef40593          	addi	a1,s0,-17
 6d2:	00000097          	auipc	ra,0x0
 6d6:	f4e080e7          	jalr	-178(ra) # 620 <write>
}
 6da:	60e2                	ld	ra,24(sp)
 6dc:	6442                	ld	s0,16(sp)
 6de:	6105                	addi	sp,sp,32
 6e0:	8082                	ret

00000000000006e2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e2:	7139                	addi	sp,sp,-64
 6e4:	fc06                	sd	ra,56(sp)
 6e6:	f822                	sd	s0,48(sp)
 6e8:	f426                	sd	s1,40(sp)
 6ea:	f04a                	sd	s2,32(sp)
 6ec:	ec4e                	sd	s3,24(sp)
 6ee:	0080                	addi	s0,sp,64
 6f0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6f2:	c299                	beqz	a3,6f8 <printint+0x16>
 6f4:	0805c863          	bltz	a1,784 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6f8:	2581                	sext.w	a1,a1
  neg = 0;
 6fa:	4881                	li	a7,0
 6fc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 700:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 702:	2601                	sext.w	a2,a2
 704:	00000517          	auipc	a0,0x0
 708:	4bc50513          	addi	a0,a0,1212 # bc0 <digits>
 70c:	883a                	mv	a6,a4
 70e:	2705                	addiw	a4,a4,1
 710:	02c5f7bb          	remuw	a5,a1,a2
 714:	1782                	slli	a5,a5,0x20
 716:	9381                	srli	a5,a5,0x20
 718:	97aa                	add	a5,a5,a0
 71a:	0007c783          	lbu	a5,0(a5)
 71e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 722:	0005879b          	sext.w	a5,a1
 726:	02c5d5bb          	divuw	a1,a1,a2
 72a:	0685                	addi	a3,a3,1
 72c:	fec7f0e3          	bgeu	a5,a2,70c <printint+0x2a>
  if(neg)
 730:	00088b63          	beqz	a7,746 <printint+0x64>
    buf[i++] = '-';
 734:	fd040793          	addi	a5,s0,-48
 738:	973e                	add	a4,a4,a5
 73a:	02d00793          	li	a5,45
 73e:	fef70823          	sb	a5,-16(a4)
 742:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 746:	02e05863          	blez	a4,776 <printint+0x94>
 74a:	fc040793          	addi	a5,s0,-64
 74e:	00e78933          	add	s2,a5,a4
 752:	fff78993          	addi	s3,a5,-1
 756:	99ba                	add	s3,s3,a4
 758:	377d                	addiw	a4,a4,-1
 75a:	1702                	slli	a4,a4,0x20
 75c:	9301                	srli	a4,a4,0x20
 75e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 762:	fff94583          	lbu	a1,-1(s2)
 766:	8526                	mv	a0,s1
 768:	00000097          	auipc	ra,0x0
 76c:	f58080e7          	jalr	-168(ra) # 6c0 <putc>
  while(--i >= 0)
 770:	197d                	addi	s2,s2,-1
 772:	ff3918e3          	bne	s2,s3,762 <printint+0x80>
}
 776:	70e2                	ld	ra,56(sp)
 778:	7442                	ld	s0,48(sp)
 77a:	74a2                	ld	s1,40(sp)
 77c:	7902                	ld	s2,32(sp)
 77e:	69e2                	ld	s3,24(sp)
 780:	6121                	addi	sp,sp,64
 782:	8082                	ret
    x = -xx;
 784:	40b005bb          	negw	a1,a1
    neg = 1;
 788:	4885                	li	a7,1
    x = -xx;
 78a:	bf8d                	j	6fc <printint+0x1a>

000000000000078c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 78c:	7119                	addi	sp,sp,-128
 78e:	fc86                	sd	ra,120(sp)
 790:	f8a2                	sd	s0,112(sp)
 792:	f4a6                	sd	s1,104(sp)
 794:	f0ca                	sd	s2,96(sp)
 796:	ecce                	sd	s3,88(sp)
 798:	e8d2                	sd	s4,80(sp)
 79a:	e4d6                	sd	s5,72(sp)
 79c:	e0da                	sd	s6,64(sp)
 79e:	fc5e                	sd	s7,56(sp)
 7a0:	f862                	sd	s8,48(sp)
 7a2:	f466                	sd	s9,40(sp)
 7a4:	f06a                	sd	s10,32(sp)
 7a6:	ec6e                	sd	s11,24(sp)
 7a8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7aa:	0005c903          	lbu	s2,0(a1)
 7ae:	18090f63          	beqz	s2,94c <vprintf+0x1c0>
 7b2:	8aaa                	mv	s5,a0
 7b4:	8b32                	mv	s6,a2
 7b6:	00158493          	addi	s1,a1,1
  state = 0;
 7ba:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7bc:	02500a13          	li	s4,37
      if(c == 'd'){
 7c0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 7c4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 7c8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 7cc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d0:	00000b97          	auipc	s7,0x0
 7d4:	3f0b8b93          	addi	s7,s7,1008 # bc0 <digits>
 7d8:	a839                	j	7f6 <vprintf+0x6a>
        putc(fd, c);
 7da:	85ca                	mv	a1,s2
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	ee2080e7          	jalr	-286(ra) # 6c0 <putc>
 7e6:	a019                	j	7ec <vprintf+0x60>
    } else if(state == '%'){
 7e8:	01498f63          	beq	s3,s4,806 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7ec:	0485                	addi	s1,s1,1
 7ee:	fff4c903          	lbu	s2,-1(s1)
 7f2:	14090d63          	beqz	s2,94c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7f6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7fa:	fe0997e3          	bnez	s3,7e8 <vprintf+0x5c>
      if(c == '%'){
 7fe:	fd479ee3          	bne	a5,s4,7da <vprintf+0x4e>
        state = '%';
 802:	89be                	mv	s3,a5
 804:	b7e5                	j	7ec <vprintf+0x60>
      if(c == 'd'){
 806:	05878063          	beq	a5,s8,846 <vprintf+0xba>
      } else if(c == 'l') {
 80a:	05978c63          	beq	a5,s9,862 <vprintf+0xd6>
      } else if(c == 'x') {
 80e:	07a78863          	beq	a5,s10,87e <vprintf+0xf2>
      } else if(c == 'p') {
 812:	09b78463          	beq	a5,s11,89a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 816:	07300713          	li	a4,115
 81a:	0ce78663          	beq	a5,a4,8e6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 81e:	06300713          	li	a4,99
 822:	0ee78e63          	beq	a5,a4,91e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 826:	11478863          	beq	a5,s4,936 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 82a:	85d2                	mv	a1,s4
 82c:	8556                	mv	a0,s5
 82e:	00000097          	auipc	ra,0x0
 832:	e92080e7          	jalr	-366(ra) # 6c0 <putc>
        putc(fd, c);
 836:	85ca                	mv	a1,s2
 838:	8556                	mv	a0,s5
 83a:	00000097          	auipc	ra,0x0
 83e:	e86080e7          	jalr	-378(ra) # 6c0 <putc>
      }
      state = 0;
 842:	4981                	li	s3,0
 844:	b765                	j	7ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 846:	008b0913          	addi	s2,s6,8
 84a:	4685                	li	a3,1
 84c:	4629                	li	a2,10
 84e:	000b2583          	lw	a1,0(s6)
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	e8e080e7          	jalr	-370(ra) # 6e2 <printint>
 85c:	8b4a                	mv	s6,s2
      state = 0;
 85e:	4981                	li	s3,0
 860:	b771                	j	7ec <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 862:	008b0913          	addi	s2,s6,8
 866:	4681                	li	a3,0
 868:	4629                	li	a2,10
 86a:	000b2583          	lw	a1,0(s6)
 86e:	8556                	mv	a0,s5
 870:	00000097          	auipc	ra,0x0
 874:	e72080e7          	jalr	-398(ra) # 6e2 <printint>
 878:	8b4a                	mv	s6,s2
      state = 0;
 87a:	4981                	li	s3,0
 87c:	bf85                	j	7ec <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 87e:	008b0913          	addi	s2,s6,8
 882:	4681                	li	a3,0
 884:	4641                	li	a2,16
 886:	000b2583          	lw	a1,0(s6)
 88a:	8556                	mv	a0,s5
 88c:	00000097          	auipc	ra,0x0
 890:	e56080e7          	jalr	-426(ra) # 6e2 <printint>
 894:	8b4a                	mv	s6,s2
      state = 0;
 896:	4981                	li	s3,0
 898:	bf91                	j	7ec <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 89a:	008b0793          	addi	a5,s6,8
 89e:	f8f43423          	sd	a5,-120(s0)
 8a2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8a6:	03000593          	li	a1,48
 8aa:	8556                	mv	a0,s5
 8ac:	00000097          	auipc	ra,0x0
 8b0:	e14080e7          	jalr	-492(ra) # 6c0 <putc>
  putc(fd, 'x');
 8b4:	85ea                	mv	a1,s10
 8b6:	8556                	mv	a0,s5
 8b8:	00000097          	auipc	ra,0x0
 8bc:	e08080e7          	jalr	-504(ra) # 6c0 <putc>
 8c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8c2:	03c9d793          	srli	a5,s3,0x3c
 8c6:	97de                	add	a5,a5,s7
 8c8:	0007c583          	lbu	a1,0(a5)
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	df2080e7          	jalr	-526(ra) # 6c0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8d6:	0992                	slli	s3,s3,0x4
 8d8:	397d                	addiw	s2,s2,-1
 8da:	fe0914e3          	bnez	s2,8c2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8de:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	b721                	j	7ec <vprintf+0x60>
        s = va_arg(ap, char*);
 8e6:	008b0993          	addi	s3,s6,8
 8ea:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 8ee:	02090163          	beqz	s2,910 <vprintf+0x184>
        while(*s != 0){
 8f2:	00094583          	lbu	a1,0(s2)
 8f6:	c9a1                	beqz	a1,946 <vprintf+0x1ba>
          putc(fd, *s);
 8f8:	8556                	mv	a0,s5
 8fa:	00000097          	auipc	ra,0x0
 8fe:	dc6080e7          	jalr	-570(ra) # 6c0 <putc>
          s++;
 902:	0905                	addi	s2,s2,1
        while(*s != 0){
 904:	00094583          	lbu	a1,0(s2)
 908:	f9e5                	bnez	a1,8f8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 90a:	8b4e                	mv	s6,s3
      state = 0;
 90c:	4981                	li	s3,0
 90e:	bdf9                	j	7ec <vprintf+0x60>
          s = "(null)";
 910:	00000917          	auipc	s2,0x0
 914:	2a890913          	addi	s2,s2,680 # bb8 <malloc+0x162>
        while(*s != 0){
 918:	02800593          	li	a1,40
 91c:	bff1                	j	8f8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 91e:	008b0913          	addi	s2,s6,8
 922:	000b4583          	lbu	a1,0(s6)
 926:	8556                	mv	a0,s5
 928:	00000097          	auipc	ra,0x0
 92c:	d98080e7          	jalr	-616(ra) # 6c0 <putc>
 930:	8b4a                	mv	s6,s2
      state = 0;
 932:	4981                	li	s3,0
 934:	bd65                	j	7ec <vprintf+0x60>
        putc(fd, c);
 936:	85d2                	mv	a1,s4
 938:	8556                	mv	a0,s5
 93a:	00000097          	auipc	ra,0x0
 93e:	d86080e7          	jalr	-634(ra) # 6c0 <putc>
      state = 0;
 942:	4981                	li	s3,0
 944:	b565                	j	7ec <vprintf+0x60>
        s = va_arg(ap, char*);
 946:	8b4e                	mv	s6,s3
      state = 0;
 948:	4981                	li	s3,0
 94a:	b54d                	j	7ec <vprintf+0x60>
    }
  }
}
 94c:	70e6                	ld	ra,120(sp)
 94e:	7446                	ld	s0,112(sp)
 950:	74a6                	ld	s1,104(sp)
 952:	7906                	ld	s2,96(sp)
 954:	69e6                	ld	s3,88(sp)
 956:	6a46                	ld	s4,80(sp)
 958:	6aa6                	ld	s5,72(sp)
 95a:	6b06                	ld	s6,64(sp)
 95c:	7be2                	ld	s7,56(sp)
 95e:	7c42                	ld	s8,48(sp)
 960:	7ca2                	ld	s9,40(sp)
 962:	7d02                	ld	s10,32(sp)
 964:	6de2                	ld	s11,24(sp)
 966:	6109                	addi	sp,sp,128
 968:	8082                	ret

000000000000096a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 96a:	715d                	addi	sp,sp,-80
 96c:	ec06                	sd	ra,24(sp)
 96e:	e822                	sd	s0,16(sp)
 970:	1000                	addi	s0,sp,32
 972:	e010                	sd	a2,0(s0)
 974:	e414                	sd	a3,8(s0)
 976:	e818                	sd	a4,16(s0)
 978:	ec1c                	sd	a5,24(s0)
 97a:	03043023          	sd	a6,32(s0)
 97e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 982:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 986:	8622                	mv	a2,s0
 988:	00000097          	auipc	ra,0x0
 98c:	e04080e7          	jalr	-508(ra) # 78c <vprintf>
}
 990:	60e2                	ld	ra,24(sp)
 992:	6442                	ld	s0,16(sp)
 994:	6161                	addi	sp,sp,80
 996:	8082                	ret

0000000000000998 <printf>:

void
printf(const char *fmt, ...)
{
 998:	711d                	addi	sp,sp,-96
 99a:	ec06                	sd	ra,24(sp)
 99c:	e822                	sd	s0,16(sp)
 99e:	1000                	addi	s0,sp,32
 9a0:	e40c                	sd	a1,8(s0)
 9a2:	e810                	sd	a2,16(s0)
 9a4:	ec14                	sd	a3,24(s0)
 9a6:	f018                	sd	a4,32(s0)
 9a8:	f41c                	sd	a5,40(s0)
 9aa:	03043823          	sd	a6,48(s0)
 9ae:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9b2:	00840613          	addi	a2,s0,8
 9b6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9ba:	85aa                	mv	a1,a0
 9bc:	4505                	li	a0,1
 9be:	00000097          	auipc	ra,0x0
 9c2:	dce080e7          	jalr	-562(ra) # 78c <vprintf>
}
 9c6:	60e2                	ld	ra,24(sp)
 9c8:	6442                	ld	s0,16(sp)
 9ca:	6125                	addi	sp,sp,96
 9cc:	8082                	ret

00000000000009ce <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9ce:	1141                	addi	sp,sp,-16
 9d0:	e422                	sd	s0,8(sp)
 9d2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9d8:	00000797          	auipc	a5,0x0
 9dc:	2007b783          	ld	a5,512(a5) # bd8 <freep>
 9e0:	a805                	j	a10 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9e2:	4618                	lw	a4,8(a2)
 9e4:	9db9                	addw	a1,a1,a4
 9e6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ea:	6398                	ld	a4,0(a5)
 9ec:	6318                	ld	a4,0(a4)
 9ee:	fee53823          	sd	a4,-16(a0)
 9f2:	a091                	j	a36 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9f4:	ff852703          	lw	a4,-8(a0)
 9f8:	9e39                	addw	a2,a2,a4
 9fa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9fc:	ff053703          	ld	a4,-16(a0)
 a00:	e398                	sd	a4,0(a5)
 a02:	a099                	j	a48 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a04:	6398                	ld	a4,0(a5)
 a06:	00e7e463          	bltu	a5,a4,a0e <free+0x40>
 a0a:	00e6ea63          	bltu	a3,a4,a1e <free+0x50>
{
 a0e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a10:	fed7fae3          	bgeu	a5,a3,a04 <free+0x36>
 a14:	6398                	ld	a4,0(a5)
 a16:	00e6e463          	bltu	a3,a4,a1e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a1a:	fee7eae3          	bltu	a5,a4,a0e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a1e:	ff852583          	lw	a1,-8(a0)
 a22:	6390                	ld	a2,0(a5)
 a24:	02059713          	slli	a4,a1,0x20
 a28:	9301                	srli	a4,a4,0x20
 a2a:	0712                	slli	a4,a4,0x4
 a2c:	9736                	add	a4,a4,a3
 a2e:	fae60ae3          	beq	a2,a4,9e2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a32:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a36:	4790                	lw	a2,8(a5)
 a38:	02061713          	slli	a4,a2,0x20
 a3c:	9301                	srli	a4,a4,0x20
 a3e:	0712                	slli	a4,a4,0x4
 a40:	973e                	add	a4,a4,a5
 a42:	fae689e3          	beq	a3,a4,9f4 <free+0x26>
  } else
    p->s.ptr = bp;
 a46:	e394                	sd	a3,0(a5)
  freep = p;
 a48:	00000717          	auipc	a4,0x0
 a4c:	18f73823          	sd	a5,400(a4) # bd8 <freep>
}
 a50:	6422                	ld	s0,8(sp)
 a52:	0141                	addi	sp,sp,16
 a54:	8082                	ret

0000000000000a56 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a56:	7139                	addi	sp,sp,-64
 a58:	fc06                	sd	ra,56(sp)
 a5a:	f822                	sd	s0,48(sp)
 a5c:	f426                	sd	s1,40(sp)
 a5e:	f04a                	sd	s2,32(sp)
 a60:	ec4e                	sd	s3,24(sp)
 a62:	e852                	sd	s4,16(sp)
 a64:	e456                	sd	s5,8(sp)
 a66:	e05a                	sd	s6,0(sp)
 a68:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a6a:	02051493          	slli	s1,a0,0x20
 a6e:	9081                	srli	s1,s1,0x20
 a70:	04bd                	addi	s1,s1,15
 a72:	8091                	srli	s1,s1,0x4
 a74:	0014899b          	addiw	s3,s1,1
 a78:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a7a:	00000517          	auipc	a0,0x0
 a7e:	15e53503          	ld	a0,350(a0) # bd8 <freep>
 a82:	c515                	beqz	a0,aae <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a86:	4798                	lw	a4,8(a5)
 a88:	02977f63          	bgeu	a4,s1,ac6 <malloc+0x70>
 a8c:	8a4e                	mv	s4,s3
 a8e:	0009871b          	sext.w	a4,s3
 a92:	6685                	lui	a3,0x1
 a94:	00d77363          	bgeu	a4,a3,a9a <malloc+0x44>
 a98:	6a05                	lui	s4,0x1
 a9a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a9e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 aa2:	00000917          	auipc	s2,0x0
 aa6:	13690913          	addi	s2,s2,310 # bd8 <freep>
  if(p == (char*)-1)
 aaa:	5afd                	li	s5,-1
 aac:	a88d                	j	b1e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 aae:	00000797          	auipc	a5,0x0
 ab2:	14278793          	addi	a5,a5,322 # bf0 <base>
 ab6:	00000717          	auipc	a4,0x0
 aba:	12f73123          	sd	a5,290(a4) # bd8 <freep>
 abe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ac0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ac4:	b7e1                	j	a8c <malloc+0x36>
      if(p->s.size == nunits)
 ac6:	02e48b63          	beq	s1,a4,afc <malloc+0xa6>
        p->s.size -= nunits;
 aca:	4137073b          	subw	a4,a4,s3
 ace:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ad0:	1702                	slli	a4,a4,0x20
 ad2:	9301                	srli	a4,a4,0x20
 ad4:	0712                	slli	a4,a4,0x4
 ad6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ad8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 adc:	00000717          	auipc	a4,0x0
 ae0:	0ea73e23          	sd	a0,252(a4) # bd8 <freep>
      return (void*)(p + 1);
 ae4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ae8:	70e2                	ld	ra,56(sp)
 aea:	7442                	ld	s0,48(sp)
 aec:	74a2                	ld	s1,40(sp)
 aee:	7902                	ld	s2,32(sp)
 af0:	69e2                	ld	s3,24(sp)
 af2:	6a42                	ld	s4,16(sp)
 af4:	6aa2                	ld	s5,8(sp)
 af6:	6b02                	ld	s6,0(sp)
 af8:	6121                	addi	sp,sp,64
 afa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 afc:	6398                	ld	a4,0(a5)
 afe:	e118                	sd	a4,0(a0)
 b00:	bff1                	j	adc <malloc+0x86>
  hp->s.size = nu;
 b02:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b06:	0541                	addi	a0,a0,16
 b08:	00000097          	auipc	ra,0x0
 b0c:	ec6080e7          	jalr	-314(ra) # 9ce <free>
  return freep;
 b10:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b14:	d971                	beqz	a0,ae8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b18:	4798                	lw	a4,8(a5)
 b1a:	fa9776e3          	bgeu	a4,s1,ac6 <malloc+0x70>
    if(p == freep)
 b1e:	00093703          	ld	a4,0(s2)
 b22:	853e                	mv	a0,a5
 b24:	fef719e3          	bne	a4,a5,b16 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b28:	8552                	mv	a0,s4
 b2a:	00000097          	auipc	ra,0x0
 b2e:	b5e080e7          	jalr	-1186(ra) # 688 <sbrk>
  if(p == (char*)-1)
 b32:	fd5518e3          	bne	a0,s5,b02 <malloc+0xac>
        return 0;
 b36:	4501                	li	a0,0
 b38:	bf45                	j	ae8 <malloc+0x92>
