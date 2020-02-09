
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	addi	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	addi	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	addi	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	addi	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	addi	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	addi	a1,a1,1
  ba:	00178513          	addi	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <fmt>:
char* fmt(char *addr){
  cc:	7179                	addi	sp,sp,-48
  ce:	f406                	sd	ra,40(sp)
  d0:	f022                	sd	s0,32(sp)
  d2:	ec26                	sd	s1,24(sp)
  d4:	e84a                	sd	s2,16(sp)
  d6:	e44e                	sd	s3,8(sp)
  d8:	1800                	addi	s0,sp,48
  da:	84aa                	mv	s1,a0
	//temp=name;
	static char buff[DIRSIZ+1];
	//char *temp;
	

	p=addr+strlen(addr);
  dc:	00000097          	auipc	ra,0x0
  e0:	38c080e7          	jalr	908(ra) # 468 <strlen>
  e4:	02051793          	slli	a5,a0,0x20
  e8:	9381                	srli	a5,a5,0x20
  ea:	97a6                	add	a5,a5,s1
	for(;(*p)!='/'&&p>=addr;p--){
  ec:	0007c683          	lbu	a3,0(a5)
  f0:	02f00713          	li	a4,47
  f4:	00e68d63          	beq	a3,a4,10e <fmt+0x42>
  f8:	0097eb63          	bltu	a5,s1,10e <fmt+0x42>
  fc:	02f00693          	li	a3,47
 100:	17fd                	addi	a5,a5,-1
 102:	0007c703          	lbu	a4,0(a5)
 106:	00d70463          	beq	a4,a3,10e <fmt+0x42>
 10a:	fe97fbe3          	bgeu	a5,s1,100 <fmt+0x34>
	}
	p++;
 10e:	00178493          	addi	s1,a5,1
	if(strlen(p)>=DIRSIZ){
 112:	8526                	mv	a0,s1
 114:	00000097          	auipc	ra,0x0
 118:	354080e7          	jalr	852(ra) # 468 <strlen>
 11c:	2501                	sext.w	a0,a0
 11e:	47b5                	li	a5,13
 120:	00a7fa63          	bgeu	a5,a0,134 <fmt+0x68>
	memmove(buff,p,strlen(p));
	memset(buff+strlen(p),' ',DIRSIZ-strlen(p));
	//printf("%s\n",buff);
	return buff;
	//temp=buff;
}
 124:	8526                	mv	a0,s1
 126:	70a2                	ld	ra,40(sp)
 128:	7402                	ld	s0,32(sp)
 12a:	64e2                	ld	s1,24(sp)
 12c:	6942                	ld	s2,16(sp)
 12e:	69a2                	ld	s3,8(sp)
 130:	6145                	addi	sp,sp,48
 132:	8082                	ret
	memmove(buff,p,strlen(p));
 134:	8526                	mv	a0,s1
 136:	00000097          	auipc	ra,0x0
 13a:	332080e7          	jalr	818(ra) # 468 <strlen>
 13e:	00001997          	auipc	s3,0x1
 142:	aca98993          	addi	s3,s3,-1334 # c08 <buff.1132>
 146:	0005061b          	sext.w	a2,a0
 14a:	85a6                	mv	a1,s1
 14c:	854e                	mv	a0,s3
 14e:	00000097          	auipc	ra,0x0
 152:	492080e7          	jalr	1170(ra) # 5e0 <memmove>
	memset(buff+strlen(p),' ',DIRSIZ-strlen(p));
 156:	8526                	mv	a0,s1
 158:	00000097          	auipc	ra,0x0
 15c:	310080e7          	jalr	784(ra) # 468 <strlen>
 160:	0005091b          	sext.w	s2,a0
 164:	8526                	mv	a0,s1
 166:	00000097          	auipc	ra,0x0
 16a:	302080e7          	jalr	770(ra) # 468 <strlen>
 16e:	1902                	slli	s2,s2,0x20
 170:	02095913          	srli	s2,s2,0x20
 174:	4639                	li	a2,14
 176:	9e09                	subw	a2,a2,a0
 178:	02000593          	li	a1,32
 17c:	01298533          	add	a0,s3,s2
 180:	00000097          	auipc	ra,0x0
 184:	312080e7          	jalr	786(ra) # 492 <memset>
	return buff;
 188:	84ce                	mv	s1,s3
 18a:	bf69                	j	124 <fmt+0x58>

000000000000018c <match>:
int match(char addr[],char name[]){
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e426                	sd	s1,8(sp)
 194:	e04a                	sd	s2,0(sp)
 196:	1000                	addi	s0,sp,32
 198:	892a                	mv	s2,a0
 19a:	84ae                	mv	s1,a1
	printf("-----%s\n",addr);
 19c:	85aa                	mv	a1,a0
 19e:	00001517          	auipc	a0,0x1
 1a2:	9b250513          	addi	a0,a0,-1614 # b50 <malloc+0xe4>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	808080e7          	jalr	-2040(ra) # 9ae <printf>
	if(name[0]=='^'){
 1ae:	0004c703          	lbu	a4,0(s1)
 1b2:	05e00793          	li	a5,94
 1b6:	02f70063          	beq	a4,a5,1d6 <match+0x4a>
		return matchhere(name+1,addr);
	}
	//do{
		if(matchhere(name,addr)){
 1ba:	85ca                	mv	a1,s2
 1bc:	8526                	mv	a0,s1
 1be:	00000097          	auipc	ra,0x0
 1c2:	e90080e7          	jalr	-368(ra) # 4e <matchhere>
		return matchhere(name+1,addr);
 1c6:	00a03533          	snez	a0,a0
			return 1;
		}
	//}while(*addr++ !='\0');
	return 0;
}
 1ca:	60e2                	ld	ra,24(sp)
 1cc:	6442                	ld	s0,16(sp)
 1ce:	64a2                	ld	s1,8(sp)
 1d0:	6902                	ld	s2,0(sp)
 1d2:	6105                	addi	sp,sp,32
 1d4:	8082                	ret
		return matchhere(name+1,addr);
 1d6:	85ca                	mv	a1,s2
 1d8:	00148513          	addi	a0,s1,1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	e72080e7          	jalr	-398(ra) # 4e <matchhere>
 1e4:	b7dd                	j	1ca <match+0x3e>

00000000000001e6 <find>:

void find(char addr[],char name[]){
 1e6:	d8010113          	addi	sp,sp,-640
 1ea:	26113c23          	sd	ra,632(sp)
 1ee:	26813823          	sd	s0,624(sp)
 1f2:	26913423          	sd	s1,616(sp)
 1f6:	27213023          	sd	s2,608(sp)
 1fa:	25313c23          	sd	s3,600(sp)
 1fe:	25413823          	sd	s4,592(sp)
 202:	25513423          	sd	s5,584(sp)
 206:	25613023          	sd	s6,576(sp)
 20a:	23713c23          	sd	s7,568(sp)
 20e:	0500                	addi	s0,sp,640
 210:	892a                	mv	s2,a0
 212:	89ae                	mv	s3,a1
	char buff[512];
	char *p;
	struct dirent de;
	struct stat st;

	if((fd=open(addr,0))<0){
 214:	4581                	li	a1,0
 216:	00000097          	auipc	ra,0x0
 21a:	440080e7          	jalr	1088(ra) # 656 <open>
 21e:	06054a63          	bltz	a0,292 <find+0xac>
 222:	84aa                	mv	s1,a0
		fprintf(2,"find:cannot find %s\n",addr);
		return;	
	}
	if(fstat(fd,&st)<0){
 224:	d8840593          	addi	a1,s0,-632
 228:	00000097          	auipc	ra,0x0
 22c:	446080e7          	jalr	1094(ra) # 66e <fstat>
 230:	06054c63          	bltz	a0,2a8 <find+0xc2>
		fprintf(2,"ls:cannot stat $s\n",addr);
		close(fd);
		return;
	}
	switch(st.type){
 234:	d9041783          	lh	a5,-624(s0)
 238:	0007869b          	sext.w	a3,a5
 23c:	4705                	li	a4,1
 23e:	08e68f63          	beq	a3,a4,2dc <find+0xf6>
 242:	4709                	li	a4,2
 244:	00e69d63          	bne	a3,a4,25e <find+0x78>
		case T_FILE:
			if(match(fmt(addr),name)){
 248:	854a                	mv	a0,s2
 24a:	00000097          	auipc	ra,0x0
 24e:	e82080e7          	jalr	-382(ra) # cc <fmt>
 252:	85ce                	mv	a1,s3
 254:	00000097          	auipc	ra,0x0
 258:	f38080e7          	jalr	-200(ra) # 18c <match>
 25c:	e535                	bnez	a0,2c8 <find+0xe2>
				}
				find(buff,name);
			}
			break;
	}
	close(fd);
 25e:	8526                	mv	a0,s1
 260:	00000097          	auipc	ra,0x0
 264:	3de080e7          	jalr	990(ra) # 63e <close>
}
 268:	27813083          	ld	ra,632(sp)
 26c:	27013403          	ld	s0,624(sp)
 270:	26813483          	ld	s1,616(sp)
 274:	26013903          	ld	s2,608(sp)
 278:	25813983          	ld	s3,600(sp)
 27c:	25013a03          	ld	s4,592(sp)
 280:	24813a83          	ld	s5,584(sp)
 284:	24013b03          	ld	s6,576(sp)
 288:	23813b83          	ld	s7,568(sp)
 28c:	28010113          	addi	sp,sp,640
 290:	8082                	ret
		fprintf(2,"find:cannot find %s\n",addr);
 292:	864a                	mv	a2,s2
 294:	00001597          	auipc	a1,0x1
 298:	8cc58593          	addi	a1,a1,-1844 # b60 <malloc+0xf4>
 29c:	4509                	li	a0,2
 29e:	00000097          	auipc	ra,0x0
 2a2:	6e2080e7          	jalr	1762(ra) # 980 <fprintf>
		return;	
 2a6:	b7c9                	j	268 <find+0x82>
		fprintf(2,"ls:cannot stat $s\n",addr);
 2a8:	864a                	mv	a2,s2
 2aa:	00001597          	auipc	a1,0x1
 2ae:	8ce58593          	addi	a1,a1,-1842 # b78 <malloc+0x10c>
 2b2:	4509                	li	a0,2
 2b4:	00000097          	auipc	ra,0x0
 2b8:	6cc080e7          	jalr	1740(ra) # 980 <fprintf>
		close(fd);
 2bc:	8526                	mv	a0,s1
 2be:	00000097          	auipc	ra,0x0
 2c2:	380080e7          	jalr	896(ra) # 63e <close>
		return;
 2c6:	b74d                	j	268 <find+0x82>
				printf("%s\n",addr);
 2c8:	85ca                	mv	a1,s2
 2ca:	00001517          	auipc	a0,0x1
 2ce:	8c650513          	addi	a0,a0,-1850 # b90 <malloc+0x124>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	6dc080e7          	jalr	1756(ra) # 9ae <printf>
 2da:	b751                	j	25e <find+0x78>
			if(strlen(addr)+DIRSIZ+2>sizeof(buff)){
 2dc:	854a                	mv	a0,s2
 2de:	00000097          	auipc	ra,0x0
 2e2:	18a080e7          	jalr	394(ra) # 468 <strlen>
 2e6:	2541                	addiw	a0,a0,16
 2e8:	20000793          	li	a5,512
 2ec:	00a7fb63          	bgeu	a5,a0,302 <find+0x11c>
				printf("find:path too long.\n");
 2f0:	00001517          	auipc	a0,0x1
 2f4:	8a850513          	addi	a0,a0,-1880 # b98 <malloc+0x12c>
 2f8:	00000097          	auipc	ra,0x0
 2fc:	6b6080e7          	jalr	1718(ra) # 9ae <printf>
		 		break;
 300:	bfb9                	j	25e <find+0x78>
			strcpy(buff,addr);
 302:	85ca                	mv	a1,s2
 304:	db040513          	addi	a0,s0,-592
 308:	00000097          	auipc	ra,0x0
 30c:	118080e7          	jalr	280(ra) # 420 <strcpy>
			p=buff+strlen(buff);
 310:	db040513          	addi	a0,s0,-592
 314:	00000097          	auipc	ra,0x0
 318:	154080e7          	jalr	340(ra) # 468 <strlen>
 31c:	02051913          	slli	s2,a0,0x20
 320:	02095913          	srli	s2,s2,0x20
 324:	db040793          	addi	a5,s0,-592
 328:	993e                	add	s2,s2,a5
			*p++='/';
 32a:	00190a93          	addi	s5,s2,1
 32e:	02f00793          	li	a5,47
 332:	00f90023          	sb	a5,0(s2)
				if(strlen(de.name)==1&&de.name[0]=='.'){
 336:	4b05                	li	s6,1
				if(strlen(de.name)==2&&de.name[0]=='.'&&de.name[1]=='.'){
 338:	4b89                	li	s7,2
 33a:	6a0d                	lui	s4,0x3
 33c:	e2ea0a13          	addi	s4,s4,-466 # 2e2e <__global_pointer$+0x1a35>
			while(read(fd,&de,sizeof(de))==sizeof(de)){
 340:	a01d                	j	366 <find+0x180>
					printf("find: cannot stat %s\n",buff);
 342:	db040593          	addi	a1,s0,-592
 346:	00001517          	auipc	a0,0x1
 34a:	86a50513          	addi	a0,a0,-1942 # bb0 <malloc+0x144>
 34e:	00000097          	auipc	ra,0x0
 352:	660080e7          	jalr	1632(ra) # 9ae <printf>
					continue;
 356:	a801                	j	366 <find+0x180>
				find(buff,name);
 358:	85ce                	mv	a1,s3
 35a:	db040513          	addi	a0,s0,-592
 35e:	00000097          	auipc	ra,0x0
 362:	e88080e7          	jalr	-376(ra) # 1e6 <find>
			while(read(fd,&de,sizeof(de))==sizeof(de)){
 366:	4641                	li	a2,16
 368:	da040593          	addi	a1,s0,-608
 36c:	8526                	mv	a0,s1
 36e:	00000097          	auipc	ra,0x0
 372:	2c0080e7          	jalr	704(ra) # 62e <read>
 376:	47c1                	li	a5,16
 378:	eef513e3          	bne	a0,a5,25e <find+0x78>
				if(de.inum==0){
 37c:	da045783          	lhu	a5,-608(s0)
 380:	d3fd                	beqz	a5,366 <find+0x180>
				memmove(p,de.name,DIRSIZ);
 382:	4639                	li	a2,14
 384:	da240593          	addi	a1,s0,-606
 388:	8556                	mv	a0,s5
 38a:	00000097          	auipc	ra,0x0
 38e:	256080e7          	jalr	598(ra) # 5e0 <memmove>
				p[DIRSIZ]=0;
 392:	000907a3          	sb	zero,15(s2)
				if(stat(buff,&st)<0){
 396:	d8840593          	addi	a1,s0,-632
 39a:	db040513          	addi	a0,s0,-592
 39e:	00000097          	auipc	ra,0x0
 3a2:	1b2080e7          	jalr	434(ra) # 550 <stat>
 3a6:	f8054ee3          	bltz	a0,342 <find+0x15c>
				if(strlen(de.name)==1&&de.name[0]=='.'){
 3aa:	da240513          	addi	a0,s0,-606
 3ae:	00000097          	auipc	ra,0x0
 3b2:	0ba080e7          	jalr	186(ra) # 468 <strlen>
 3b6:	2501                	sext.w	a0,a0
 3b8:	01651863          	bne	a0,s6,3c8 <find+0x1e2>
 3bc:	da244703          	lbu	a4,-606(s0)
 3c0:	02e00793          	li	a5,46
 3c4:	faf701e3          	beq	a4,a5,366 <find+0x180>
				if(strlen(de.name)==2&&de.name[0]=='.'&&de.name[1]=='.'){
 3c8:	da240513          	addi	a0,s0,-606
 3cc:	00000097          	auipc	ra,0x0
 3d0:	09c080e7          	jalr	156(ra) # 468 <strlen>
 3d4:	2501                	sext.w	a0,a0
 3d6:	f97511e3          	bne	a0,s7,358 <find+0x172>
 3da:	da245783          	lhu	a5,-606(s0)
 3de:	f7479de3          	bne	a5,s4,358 <find+0x172>
 3e2:	b751                	j	366 <find+0x180>

00000000000003e4 <main>:

int main(int argc,char *argv[]){
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e406                	sd	ra,8(sp)
 3e8:	e022                	sd	s0,0(sp)
 3ea:	0800                	addi	s0,sp,16
	
	if(argc<3){
 3ec:	4709                	li	a4,2
 3ee:	00a74e63          	blt	a4,a0,40a <main+0x26>
		printf("Need two parameters.\n");
 3f2:	00000517          	auipc	a0,0x0
 3f6:	7d650513          	addi	a0,a0,2006 # bc8 <malloc+0x15c>
 3fa:	00000097          	auipc	ra,0x0
 3fe:	5b4080e7          	jalr	1460(ra) # 9ae <printf>
		exit();
 402:	00000097          	auipc	ra,0x0
 406:	214080e7          	jalr	532(ra) # 616 <exit>
 40a:	87ae                	mv	a5,a1
	}
	find(argv[1],argv[2]);
 40c:	698c                	ld	a1,16(a1)
 40e:	6788                	ld	a0,8(a5)
 410:	00000097          	auipc	ra,0x0
 414:	dd6080e7          	jalr	-554(ra) # 1e6 <find>
	exit();
 418:	00000097          	auipc	ra,0x0
 41c:	1fe080e7          	jalr	510(ra) # 616 <exit>

0000000000000420 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 420:	1141                	addi	sp,sp,-16
 422:	e422                	sd	s0,8(sp)
 424:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 426:	87aa                	mv	a5,a0
 428:	0585                	addi	a1,a1,1
 42a:	0785                	addi	a5,a5,1
 42c:	fff5c703          	lbu	a4,-1(a1)
 430:	fee78fa3          	sb	a4,-1(a5)
 434:	fb75                	bnez	a4,428 <strcpy+0x8>
    ;
  return os;
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e422                	sd	s0,8(sp)
 440:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 442:	00054783          	lbu	a5,0(a0)
 446:	cb91                	beqz	a5,45a <strcmp+0x1e>
 448:	0005c703          	lbu	a4,0(a1)
 44c:	00f71763          	bne	a4,a5,45a <strcmp+0x1e>
    p++, q++;
 450:	0505                	addi	a0,a0,1
 452:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 454:	00054783          	lbu	a5,0(a0)
 458:	fbe5                	bnez	a5,448 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 45a:	0005c503          	lbu	a0,0(a1)
}
 45e:	40a7853b          	subw	a0,a5,a0
 462:	6422                	ld	s0,8(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret

0000000000000468 <strlen>:

uint
strlen(const char *s)
{
 468:	1141                	addi	sp,sp,-16
 46a:	e422                	sd	s0,8(sp)
 46c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 46e:	00054783          	lbu	a5,0(a0)
 472:	cf91                	beqz	a5,48e <strlen+0x26>
 474:	0505                	addi	a0,a0,1
 476:	87aa                	mv	a5,a0
 478:	4685                	li	a3,1
 47a:	9e89                	subw	a3,a3,a0
 47c:	00f6853b          	addw	a0,a3,a5
 480:	0785                	addi	a5,a5,1
 482:	fff7c703          	lbu	a4,-1(a5)
 486:	fb7d                	bnez	a4,47c <strlen+0x14>
    ;
  return n;
}
 488:	6422                	ld	s0,8(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret
  for(n = 0; s[n]; n++)
 48e:	4501                	li	a0,0
 490:	bfe5                	j	488 <strlen+0x20>

0000000000000492 <memset>:

void*
memset(void *dst, int c, uint n)
{
 492:	1141                	addi	sp,sp,-16
 494:	e422                	sd	s0,8(sp)
 496:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 498:	ce09                	beqz	a2,4b2 <memset+0x20>
 49a:	87aa                	mv	a5,a0
 49c:	fff6071b          	addiw	a4,a2,-1
 4a0:	1702                	slli	a4,a4,0x20
 4a2:	9301                	srli	a4,a4,0x20
 4a4:	0705                	addi	a4,a4,1
 4a6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 4a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4ac:	0785                	addi	a5,a5,1
 4ae:	fee79de3          	bne	a5,a4,4a8 <memset+0x16>
  }
  return dst;
}
 4b2:	6422                	ld	s0,8(sp)
 4b4:	0141                	addi	sp,sp,16
 4b6:	8082                	ret

00000000000004b8 <strchr>:

char*
strchr(const char *s, char c)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e422                	sd	s0,8(sp)
 4bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4be:	00054783          	lbu	a5,0(a0)
 4c2:	cb99                	beqz	a5,4d8 <strchr+0x20>
    if(*s == c)
 4c4:	00f58763          	beq	a1,a5,4d2 <strchr+0x1a>
  for(; *s; s++)
 4c8:	0505                	addi	a0,a0,1
 4ca:	00054783          	lbu	a5,0(a0)
 4ce:	fbfd                	bnez	a5,4c4 <strchr+0xc>
      return (char*)s;
  return 0;
 4d0:	4501                	li	a0,0
}
 4d2:	6422                	ld	s0,8(sp)
 4d4:	0141                	addi	sp,sp,16
 4d6:	8082                	ret
  return 0;
 4d8:	4501                	li	a0,0
 4da:	bfe5                	j	4d2 <strchr+0x1a>

00000000000004dc <gets>:

char*
gets(char *buf, int max)
{
 4dc:	711d                	addi	sp,sp,-96
 4de:	ec86                	sd	ra,88(sp)
 4e0:	e8a2                	sd	s0,80(sp)
 4e2:	e4a6                	sd	s1,72(sp)
 4e4:	e0ca                	sd	s2,64(sp)
 4e6:	fc4e                	sd	s3,56(sp)
 4e8:	f852                	sd	s4,48(sp)
 4ea:	f456                	sd	s5,40(sp)
 4ec:	f05a                	sd	s6,32(sp)
 4ee:	ec5e                	sd	s7,24(sp)
 4f0:	1080                	addi	s0,sp,96
 4f2:	8baa                	mv	s7,a0
 4f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4f6:	892a                	mv	s2,a0
 4f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 4fa:	4aa9                	li	s5,10
 4fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 4fe:	89a6                	mv	s3,s1
 500:	2485                	addiw	s1,s1,1
 502:	0344d863          	bge	s1,s4,532 <gets+0x56>
    cc = read(0, &c, 1);
 506:	4605                	li	a2,1
 508:	faf40593          	addi	a1,s0,-81
 50c:	4501                	li	a0,0
 50e:	00000097          	auipc	ra,0x0
 512:	120080e7          	jalr	288(ra) # 62e <read>
    if(cc < 1)
 516:	00a05e63          	blez	a0,532 <gets+0x56>
    buf[i++] = c;
 51a:	faf44783          	lbu	a5,-81(s0)
 51e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 522:	01578763          	beq	a5,s5,530 <gets+0x54>
 526:	0905                	addi	s2,s2,1
 528:	fd679be3          	bne	a5,s6,4fe <gets+0x22>
  for(i=0; i+1 < max; ){
 52c:	89a6                	mv	s3,s1
 52e:	a011                	j	532 <gets+0x56>
 530:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 532:	99de                	add	s3,s3,s7
 534:	00098023          	sb	zero,0(s3)
  return buf;
}
 538:	855e                	mv	a0,s7
 53a:	60e6                	ld	ra,88(sp)
 53c:	6446                	ld	s0,80(sp)
 53e:	64a6                	ld	s1,72(sp)
 540:	6906                	ld	s2,64(sp)
 542:	79e2                	ld	s3,56(sp)
 544:	7a42                	ld	s4,48(sp)
 546:	7aa2                	ld	s5,40(sp)
 548:	7b02                	ld	s6,32(sp)
 54a:	6be2                	ld	s7,24(sp)
 54c:	6125                	addi	sp,sp,96
 54e:	8082                	ret

0000000000000550 <stat>:

int
stat(const char *n, struct stat *st)
{
 550:	1101                	addi	sp,sp,-32
 552:	ec06                	sd	ra,24(sp)
 554:	e822                	sd	s0,16(sp)
 556:	e426                	sd	s1,8(sp)
 558:	e04a                	sd	s2,0(sp)
 55a:	1000                	addi	s0,sp,32
 55c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 55e:	4581                	li	a1,0
 560:	00000097          	auipc	ra,0x0
 564:	0f6080e7          	jalr	246(ra) # 656 <open>
  if(fd < 0)
 568:	02054563          	bltz	a0,592 <stat+0x42>
 56c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 56e:	85ca                	mv	a1,s2
 570:	00000097          	auipc	ra,0x0
 574:	0fe080e7          	jalr	254(ra) # 66e <fstat>
 578:	892a                	mv	s2,a0
  close(fd);
 57a:	8526                	mv	a0,s1
 57c:	00000097          	auipc	ra,0x0
 580:	0c2080e7          	jalr	194(ra) # 63e <close>
  return r;
}
 584:	854a                	mv	a0,s2
 586:	60e2                	ld	ra,24(sp)
 588:	6442                	ld	s0,16(sp)
 58a:	64a2                	ld	s1,8(sp)
 58c:	6902                	ld	s2,0(sp)
 58e:	6105                	addi	sp,sp,32
 590:	8082                	ret
    return -1;
 592:	597d                	li	s2,-1
 594:	bfc5                	j	584 <stat+0x34>

0000000000000596 <atoi>:

int
atoi(const char *s)
{
 596:	1141                	addi	sp,sp,-16
 598:	e422                	sd	s0,8(sp)
 59a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 59c:	00054603          	lbu	a2,0(a0)
 5a0:	fd06079b          	addiw	a5,a2,-48
 5a4:	0ff7f793          	andi	a5,a5,255
 5a8:	4725                	li	a4,9
 5aa:	02f76963          	bltu	a4,a5,5dc <atoi+0x46>
 5ae:	86aa                	mv	a3,a0
  n = 0;
 5b0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 5b2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 5b4:	0685                	addi	a3,a3,1
 5b6:	0025179b          	slliw	a5,a0,0x2
 5ba:	9fa9                	addw	a5,a5,a0
 5bc:	0017979b          	slliw	a5,a5,0x1
 5c0:	9fb1                	addw	a5,a5,a2
 5c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5c6:	0006c603          	lbu	a2,0(a3)
 5ca:	fd06071b          	addiw	a4,a2,-48
 5ce:	0ff77713          	andi	a4,a4,255
 5d2:	fee5f1e3          	bgeu	a1,a4,5b4 <atoi+0x1e>
  return n;
}
 5d6:	6422                	ld	s0,8(sp)
 5d8:	0141                	addi	sp,sp,16
 5da:	8082                	ret
  n = 0;
 5dc:	4501                	li	a0,0
 5de:	bfe5                	j	5d6 <atoi+0x40>

00000000000005e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5e0:	1141                	addi	sp,sp,-16
 5e2:	e422                	sd	s0,8(sp)
 5e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 5e6:	02c05163          	blez	a2,608 <memmove+0x28>
 5ea:	fff6071b          	addiw	a4,a2,-1
 5ee:	1702                	slli	a4,a4,0x20
 5f0:	9301                	srli	a4,a4,0x20
 5f2:	0705                	addi	a4,a4,1
 5f4:	972a                	add	a4,a4,a0
  dst = vdst;
 5f6:	87aa                	mv	a5,a0
    *dst++ = *src++;
 5f8:	0585                	addi	a1,a1,1
 5fa:	0785                	addi	a5,a5,1
 5fc:	fff5c683          	lbu	a3,-1(a1)
 600:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 604:	fee79ae3          	bne	a5,a4,5f8 <memmove+0x18>
  return vdst;
}
 608:	6422                	ld	s0,8(sp)
 60a:	0141                	addi	sp,sp,16
 60c:	8082                	ret

000000000000060e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 60e:	4885                	li	a7,1
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <exit>:
.global exit
exit:
 li a7, SYS_exit
 616:	4889                	li	a7,2
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <wait>:
.global wait
wait:
 li a7, SYS_wait
 61e:	488d                	li	a7,3
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 626:	4891                	li	a7,4
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <read>:
.global read
read:
 li a7, SYS_read
 62e:	4895                	li	a7,5
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <write>:
.global write
write:
 li a7, SYS_write
 636:	48c1                	li	a7,16
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <close>:
.global close
close:
 li a7, SYS_close
 63e:	48d5                	li	a7,21
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <kill>:
.global kill
kill:
 li a7, SYS_kill
 646:	4899                	li	a7,6
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <exec>:
.global exec
exec:
 li a7, SYS_exec
 64e:	489d                	li	a7,7
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <open>:
.global open
open:
 li a7, SYS_open
 656:	48bd                	li	a7,15
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 65e:	48c5                	li	a7,17
 ecall
 660:	00000073          	ecall
 ret
 664:	8082                	ret

0000000000000666 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 666:	48c9                	li	a7,18
 ecall
 668:	00000073          	ecall
 ret
 66c:	8082                	ret

000000000000066e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 66e:	48a1                	li	a7,8
 ecall
 670:	00000073          	ecall
 ret
 674:	8082                	ret

0000000000000676 <link>:
.global link
link:
 li a7, SYS_link
 676:	48cd                	li	a7,19
 ecall
 678:	00000073          	ecall
 ret
 67c:	8082                	ret

000000000000067e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 67e:	48d1                	li	a7,20
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 686:	48a5                	li	a7,9
 ecall
 688:	00000073          	ecall
 ret
 68c:	8082                	ret

000000000000068e <dup>:
.global dup
dup:
 li a7, SYS_dup
 68e:	48a9                	li	a7,10
 ecall
 690:	00000073          	ecall
 ret
 694:	8082                	ret

0000000000000696 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 696:	48ad                	li	a7,11
 ecall
 698:	00000073          	ecall
 ret
 69c:	8082                	ret

000000000000069e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 69e:	48b1                	li	a7,12
 ecall
 6a0:	00000073          	ecall
 ret
 6a4:	8082                	ret

00000000000006a6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 6a6:	48b5                	li	a7,13
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 6ae:	48b9                	li	a7,14
 ecall
 6b0:	00000073          	ecall
 ret
 6b4:	8082                	ret

00000000000006b6 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 6b6:	48d9                	li	a7,22
 ecall
 6b8:	00000073          	ecall
 ret
 6bc:	8082                	ret

00000000000006be <crash>:
.global crash
crash:
 li a7, SYS_crash
 6be:	48dd                	li	a7,23
 ecall
 6c0:	00000073          	ecall
 ret
 6c4:	8082                	ret

00000000000006c6 <mount>:
.global mount
mount:
 li a7, SYS_mount
 6c6:	48e1                	li	a7,24
 ecall
 6c8:	00000073          	ecall
 ret
 6cc:	8082                	ret

00000000000006ce <umount>:
.global umount
umount:
 li a7, SYS_umount
 6ce:	48e5                	li	a7,25
 ecall
 6d0:	00000073          	ecall
 ret
 6d4:	8082                	ret

00000000000006d6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6d6:	1101                	addi	sp,sp,-32
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6e2:	4605                	li	a2,1
 6e4:	fef40593          	addi	a1,s0,-17
 6e8:	00000097          	auipc	ra,0x0
 6ec:	f4e080e7          	jalr	-178(ra) # 636 <write>
}
 6f0:	60e2                	ld	ra,24(sp)
 6f2:	6442                	ld	s0,16(sp)
 6f4:	6105                	addi	sp,sp,32
 6f6:	8082                	ret

00000000000006f8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6f8:	7139                	addi	sp,sp,-64
 6fa:	fc06                	sd	ra,56(sp)
 6fc:	f822                	sd	s0,48(sp)
 6fe:	f426                	sd	s1,40(sp)
 700:	f04a                	sd	s2,32(sp)
 702:	ec4e                	sd	s3,24(sp)
 704:	0080                	addi	s0,sp,64
 706:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 708:	c299                	beqz	a3,70e <printint+0x16>
 70a:	0805c863          	bltz	a1,79a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 70e:	2581                	sext.w	a1,a1
  neg = 0;
 710:	4881                	li	a7,0
 712:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 716:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 718:	2601                	sext.w	a2,a2
 71a:	00000517          	auipc	a0,0x0
 71e:	4ce50513          	addi	a0,a0,1230 # be8 <digits>
 722:	883a                	mv	a6,a4
 724:	2705                	addiw	a4,a4,1
 726:	02c5f7bb          	remuw	a5,a1,a2
 72a:	1782                	slli	a5,a5,0x20
 72c:	9381                	srli	a5,a5,0x20
 72e:	97aa                	add	a5,a5,a0
 730:	0007c783          	lbu	a5,0(a5)
 734:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 738:	0005879b          	sext.w	a5,a1
 73c:	02c5d5bb          	divuw	a1,a1,a2
 740:	0685                	addi	a3,a3,1
 742:	fec7f0e3          	bgeu	a5,a2,722 <printint+0x2a>
  if(neg)
 746:	00088b63          	beqz	a7,75c <printint+0x64>
    buf[i++] = '-';
 74a:	fd040793          	addi	a5,s0,-48
 74e:	973e                	add	a4,a4,a5
 750:	02d00793          	li	a5,45
 754:	fef70823          	sb	a5,-16(a4)
 758:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 75c:	02e05863          	blez	a4,78c <printint+0x94>
 760:	fc040793          	addi	a5,s0,-64
 764:	00e78933          	add	s2,a5,a4
 768:	fff78993          	addi	s3,a5,-1
 76c:	99ba                	add	s3,s3,a4
 76e:	377d                	addiw	a4,a4,-1
 770:	1702                	slli	a4,a4,0x20
 772:	9301                	srli	a4,a4,0x20
 774:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 778:	fff94583          	lbu	a1,-1(s2)
 77c:	8526                	mv	a0,s1
 77e:	00000097          	auipc	ra,0x0
 782:	f58080e7          	jalr	-168(ra) # 6d6 <putc>
  while(--i >= 0)
 786:	197d                	addi	s2,s2,-1
 788:	ff3918e3          	bne	s2,s3,778 <printint+0x80>
}
 78c:	70e2                	ld	ra,56(sp)
 78e:	7442                	ld	s0,48(sp)
 790:	74a2                	ld	s1,40(sp)
 792:	7902                	ld	s2,32(sp)
 794:	69e2                	ld	s3,24(sp)
 796:	6121                	addi	sp,sp,64
 798:	8082                	ret
    x = -xx;
 79a:	40b005bb          	negw	a1,a1
    neg = 1;
 79e:	4885                	li	a7,1
    x = -xx;
 7a0:	bf8d                	j	712 <printint+0x1a>

00000000000007a2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 7a2:	7119                	addi	sp,sp,-128
 7a4:	fc86                	sd	ra,120(sp)
 7a6:	f8a2                	sd	s0,112(sp)
 7a8:	f4a6                	sd	s1,104(sp)
 7aa:	f0ca                	sd	s2,96(sp)
 7ac:	ecce                	sd	s3,88(sp)
 7ae:	e8d2                	sd	s4,80(sp)
 7b0:	e4d6                	sd	s5,72(sp)
 7b2:	e0da                	sd	s6,64(sp)
 7b4:	fc5e                	sd	s7,56(sp)
 7b6:	f862                	sd	s8,48(sp)
 7b8:	f466                	sd	s9,40(sp)
 7ba:	f06a                	sd	s10,32(sp)
 7bc:	ec6e                	sd	s11,24(sp)
 7be:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7c0:	0005c903          	lbu	s2,0(a1)
 7c4:	18090f63          	beqz	s2,962 <vprintf+0x1c0>
 7c8:	8aaa                	mv	s5,a0
 7ca:	8b32                	mv	s6,a2
 7cc:	00158493          	addi	s1,a1,1
  state = 0;
 7d0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7d2:	02500a13          	li	s4,37
      if(c == 'd'){
 7d6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 7da:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 7de:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 7e2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7e6:	00000b97          	auipc	s7,0x0
 7ea:	402b8b93          	addi	s7,s7,1026 # be8 <digits>
 7ee:	a839                	j	80c <vprintf+0x6a>
        putc(fd, c);
 7f0:	85ca                	mv	a1,s2
 7f2:	8556                	mv	a0,s5
 7f4:	00000097          	auipc	ra,0x0
 7f8:	ee2080e7          	jalr	-286(ra) # 6d6 <putc>
 7fc:	a019                	j	802 <vprintf+0x60>
    } else if(state == '%'){
 7fe:	01498f63          	beq	s3,s4,81c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 802:	0485                	addi	s1,s1,1
 804:	fff4c903          	lbu	s2,-1(s1)
 808:	14090d63          	beqz	s2,962 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 80c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 810:	fe0997e3          	bnez	s3,7fe <vprintf+0x5c>
      if(c == '%'){
 814:	fd479ee3          	bne	a5,s4,7f0 <vprintf+0x4e>
        state = '%';
 818:	89be                	mv	s3,a5
 81a:	b7e5                	j	802 <vprintf+0x60>
      if(c == 'd'){
 81c:	05878063          	beq	a5,s8,85c <vprintf+0xba>
      } else if(c == 'l') {
 820:	05978c63          	beq	a5,s9,878 <vprintf+0xd6>
      } else if(c == 'x') {
 824:	07a78863          	beq	a5,s10,894 <vprintf+0xf2>
      } else if(c == 'p') {
 828:	09b78463          	beq	a5,s11,8b0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 82c:	07300713          	li	a4,115
 830:	0ce78663          	beq	a5,a4,8fc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 834:	06300713          	li	a4,99
 838:	0ee78e63          	beq	a5,a4,934 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 83c:	11478863          	beq	a5,s4,94c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 840:	85d2                	mv	a1,s4
 842:	8556                	mv	a0,s5
 844:	00000097          	auipc	ra,0x0
 848:	e92080e7          	jalr	-366(ra) # 6d6 <putc>
        putc(fd, c);
 84c:	85ca                	mv	a1,s2
 84e:	8556                	mv	a0,s5
 850:	00000097          	auipc	ra,0x0
 854:	e86080e7          	jalr	-378(ra) # 6d6 <putc>
      }
      state = 0;
 858:	4981                	li	s3,0
 85a:	b765                	j	802 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 85c:	008b0913          	addi	s2,s6,8
 860:	4685                	li	a3,1
 862:	4629                	li	a2,10
 864:	000b2583          	lw	a1,0(s6)
 868:	8556                	mv	a0,s5
 86a:	00000097          	auipc	ra,0x0
 86e:	e8e080e7          	jalr	-370(ra) # 6f8 <printint>
 872:	8b4a                	mv	s6,s2
      state = 0;
 874:	4981                	li	s3,0
 876:	b771                	j	802 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 878:	008b0913          	addi	s2,s6,8
 87c:	4681                	li	a3,0
 87e:	4629                	li	a2,10
 880:	000b2583          	lw	a1,0(s6)
 884:	8556                	mv	a0,s5
 886:	00000097          	auipc	ra,0x0
 88a:	e72080e7          	jalr	-398(ra) # 6f8 <printint>
 88e:	8b4a                	mv	s6,s2
      state = 0;
 890:	4981                	li	s3,0
 892:	bf85                	j	802 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 894:	008b0913          	addi	s2,s6,8
 898:	4681                	li	a3,0
 89a:	4641                	li	a2,16
 89c:	000b2583          	lw	a1,0(s6)
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	e56080e7          	jalr	-426(ra) # 6f8 <printint>
 8aa:	8b4a                	mv	s6,s2
      state = 0;
 8ac:	4981                	li	s3,0
 8ae:	bf91                	j	802 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 8b0:	008b0793          	addi	a5,s6,8
 8b4:	f8f43423          	sd	a5,-120(s0)
 8b8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 8bc:	03000593          	li	a1,48
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	e14080e7          	jalr	-492(ra) # 6d6 <putc>
  putc(fd, 'x');
 8ca:	85ea                	mv	a1,s10
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	e08080e7          	jalr	-504(ra) # 6d6 <putc>
 8d6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8d8:	03c9d793          	srli	a5,s3,0x3c
 8dc:	97de                	add	a5,a5,s7
 8de:	0007c583          	lbu	a1,0(a5)
 8e2:	8556                	mv	a0,s5
 8e4:	00000097          	auipc	ra,0x0
 8e8:	df2080e7          	jalr	-526(ra) # 6d6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8ec:	0992                	slli	s3,s3,0x4
 8ee:	397d                	addiw	s2,s2,-1
 8f0:	fe0914e3          	bnez	s2,8d8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8f4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8f8:	4981                	li	s3,0
 8fa:	b721                	j	802 <vprintf+0x60>
        s = va_arg(ap, char*);
 8fc:	008b0993          	addi	s3,s6,8
 900:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 904:	02090163          	beqz	s2,926 <vprintf+0x184>
        while(*s != 0){
 908:	00094583          	lbu	a1,0(s2)
 90c:	c9a1                	beqz	a1,95c <vprintf+0x1ba>
          putc(fd, *s);
 90e:	8556                	mv	a0,s5
 910:	00000097          	auipc	ra,0x0
 914:	dc6080e7          	jalr	-570(ra) # 6d6 <putc>
          s++;
 918:	0905                	addi	s2,s2,1
        while(*s != 0){
 91a:	00094583          	lbu	a1,0(s2)
 91e:	f9e5                	bnez	a1,90e <vprintf+0x16c>
        s = va_arg(ap, char*);
 920:	8b4e                	mv	s6,s3
      state = 0;
 922:	4981                	li	s3,0
 924:	bdf9                	j	802 <vprintf+0x60>
          s = "(null)";
 926:	00000917          	auipc	s2,0x0
 92a:	2ba90913          	addi	s2,s2,698 # be0 <malloc+0x174>
        while(*s != 0){
 92e:	02800593          	li	a1,40
 932:	bff1                	j	90e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 934:	008b0913          	addi	s2,s6,8
 938:	000b4583          	lbu	a1,0(s6)
 93c:	8556                	mv	a0,s5
 93e:	00000097          	auipc	ra,0x0
 942:	d98080e7          	jalr	-616(ra) # 6d6 <putc>
 946:	8b4a                	mv	s6,s2
      state = 0;
 948:	4981                	li	s3,0
 94a:	bd65                	j	802 <vprintf+0x60>
        putc(fd, c);
 94c:	85d2                	mv	a1,s4
 94e:	8556                	mv	a0,s5
 950:	00000097          	auipc	ra,0x0
 954:	d86080e7          	jalr	-634(ra) # 6d6 <putc>
      state = 0;
 958:	4981                	li	s3,0
 95a:	b565                	j	802 <vprintf+0x60>
        s = va_arg(ap, char*);
 95c:	8b4e                	mv	s6,s3
      state = 0;
 95e:	4981                	li	s3,0
 960:	b54d                	j	802 <vprintf+0x60>
    }
  }
}
 962:	70e6                	ld	ra,120(sp)
 964:	7446                	ld	s0,112(sp)
 966:	74a6                	ld	s1,104(sp)
 968:	7906                	ld	s2,96(sp)
 96a:	69e6                	ld	s3,88(sp)
 96c:	6a46                	ld	s4,80(sp)
 96e:	6aa6                	ld	s5,72(sp)
 970:	6b06                	ld	s6,64(sp)
 972:	7be2                	ld	s7,56(sp)
 974:	7c42                	ld	s8,48(sp)
 976:	7ca2                	ld	s9,40(sp)
 978:	7d02                	ld	s10,32(sp)
 97a:	6de2                	ld	s11,24(sp)
 97c:	6109                	addi	sp,sp,128
 97e:	8082                	ret

0000000000000980 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 980:	715d                	addi	sp,sp,-80
 982:	ec06                	sd	ra,24(sp)
 984:	e822                	sd	s0,16(sp)
 986:	1000                	addi	s0,sp,32
 988:	e010                	sd	a2,0(s0)
 98a:	e414                	sd	a3,8(s0)
 98c:	e818                	sd	a4,16(s0)
 98e:	ec1c                	sd	a5,24(s0)
 990:	03043023          	sd	a6,32(s0)
 994:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 998:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 99c:	8622                	mv	a2,s0
 99e:	00000097          	auipc	ra,0x0
 9a2:	e04080e7          	jalr	-508(ra) # 7a2 <vprintf>
}
 9a6:	60e2                	ld	ra,24(sp)
 9a8:	6442                	ld	s0,16(sp)
 9aa:	6161                	addi	sp,sp,80
 9ac:	8082                	ret

00000000000009ae <printf>:

void
printf(const char *fmt, ...)
{
 9ae:	711d                	addi	sp,sp,-96
 9b0:	ec06                	sd	ra,24(sp)
 9b2:	e822                	sd	s0,16(sp)
 9b4:	1000                	addi	s0,sp,32
 9b6:	e40c                	sd	a1,8(s0)
 9b8:	e810                	sd	a2,16(s0)
 9ba:	ec14                	sd	a3,24(s0)
 9bc:	f018                	sd	a4,32(s0)
 9be:	f41c                	sd	a5,40(s0)
 9c0:	03043823          	sd	a6,48(s0)
 9c4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9c8:	00840613          	addi	a2,s0,8
 9cc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9d0:	85aa                	mv	a1,a0
 9d2:	4505                	li	a0,1
 9d4:	00000097          	auipc	ra,0x0
 9d8:	dce080e7          	jalr	-562(ra) # 7a2 <vprintf>
}
 9dc:	60e2                	ld	ra,24(sp)
 9de:	6442                	ld	s0,16(sp)
 9e0:	6125                	addi	sp,sp,96
 9e2:	8082                	ret

00000000000009e4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9e4:	1141                	addi	sp,sp,-16
 9e6:	e422                	sd	s0,8(sp)
 9e8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9ea:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ee:	00000797          	auipc	a5,0x0
 9f2:	2127b783          	ld	a5,530(a5) # c00 <freep>
 9f6:	a805                	j	a26 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9f8:	4618                	lw	a4,8(a2)
 9fa:	9db9                	addw	a1,a1,a4
 9fc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a00:	6398                	ld	a4,0(a5)
 a02:	6318                	ld	a4,0(a4)
 a04:	fee53823          	sd	a4,-16(a0)
 a08:	a091                	j	a4c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a0a:	ff852703          	lw	a4,-8(a0)
 a0e:	9e39                	addw	a2,a2,a4
 a10:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a12:	ff053703          	ld	a4,-16(a0)
 a16:	e398                	sd	a4,0(a5)
 a18:	a099                	j	a5e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a1a:	6398                	ld	a4,0(a5)
 a1c:	00e7e463          	bltu	a5,a4,a24 <free+0x40>
 a20:	00e6ea63          	bltu	a3,a4,a34 <free+0x50>
{
 a24:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a26:	fed7fae3          	bgeu	a5,a3,a1a <free+0x36>
 a2a:	6398                	ld	a4,0(a5)
 a2c:	00e6e463          	bltu	a3,a4,a34 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a30:	fee7eae3          	bltu	a5,a4,a24 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 a34:	ff852583          	lw	a1,-8(a0)
 a38:	6390                	ld	a2,0(a5)
 a3a:	02059713          	slli	a4,a1,0x20
 a3e:	9301                	srli	a4,a4,0x20
 a40:	0712                	slli	a4,a4,0x4
 a42:	9736                	add	a4,a4,a3
 a44:	fae60ae3          	beq	a2,a4,9f8 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a48:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a4c:	4790                	lw	a2,8(a5)
 a4e:	02061713          	slli	a4,a2,0x20
 a52:	9301                	srli	a4,a4,0x20
 a54:	0712                	slli	a4,a4,0x4
 a56:	973e                	add	a4,a4,a5
 a58:	fae689e3          	beq	a3,a4,a0a <free+0x26>
  } else
    p->s.ptr = bp;
 a5c:	e394                	sd	a3,0(a5)
  freep = p;
 a5e:	00000717          	auipc	a4,0x0
 a62:	1af73123          	sd	a5,418(a4) # c00 <freep>
}
 a66:	6422                	ld	s0,8(sp)
 a68:	0141                	addi	sp,sp,16
 a6a:	8082                	ret

0000000000000a6c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a6c:	7139                	addi	sp,sp,-64
 a6e:	fc06                	sd	ra,56(sp)
 a70:	f822                	sd	s0,48(sp)
 a72:	f426                	sd	s1,40(sp)
 a74:	f04a                	sd	s2,32(sp)
 a76:	ec4e                	sd	s3,24(sp)
 a78:	e852                	sd	s4,16(sp)
 a7a:	e456                	sd	s5,8(sp)
 a7c:	e05a                	sd	s6,0(sp)
 a7e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a80:	02051493          	slli	s1,a0,0x20
 a84:	9081                	srli	s1,s1,0x20
 a86:	04bd                	addi	s1,s1,15
 a88:	8091                	srli	s1,s1,0x4
 a8a:	0014899b          	addiw	s3,s1,1
 a8e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a90:	00000517          	auipc	a0,0x0
 a94:	17053503          	ld	a0,368(a0) # c00 <freep>
 a98:	c515                	beqz	a0,ac4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a9c:	4798                	lw	a4,8(a5)
 a9e:	02977f63          	bgeu	a4,s1,adc <malloc+0x70>
 aa2:	8a4e                	mv	s4,s3
 aa4:	0009871b          	sext.w	a4,s3
 aa8:	6685                	lui	a3,0x1
 aaa:	00d77363          	bgeu	a4,a3,ab0 <malloc+0x44>
 aae:	6a05                	lui	s4,0x1
 ab0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ab4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ab8:	00000917          	auipc	s2,0x0
 abc:	14890913          	addi	s2,s2,328 # c00 <freep>
  if(p == (char*)-1)
 ac0:	5afd                	li	s5,-1
 ac2:	a88d                	j	b34 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 ac4:	00000797          	auipc	a5,0x0
 ac8:	15478793          	addi	a5,a5,340 # c18 <base>
 acc:	00000717          	auipc	a4,0x0
 ad0:	12f73a23          	sd	a5,308(a4) # c00 <freep>
 ad4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ad6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ada:	b7e1                	j	aa2 <malloc+0x36>
      if(p->s.size == nunits)
 adc:	02e48b63          	beq	s1,a4,b12 <malloc+0xa6>
        p->s.size -= nunits;
 ae0:	4137073b          	subw	a4,a4,s3
 ae4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ae6:	1702                	slli	a4,a4,0x20
 ae8:	9301                	srli	a4,a4,0x20
 aea:	0712                	slli	a4,a4,0x4
 aec:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aee:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 af2:	00000717          	auipc	a4,0x0
 af6:	10a73723          	sd	a0,270(a4) # c00 <freep>
      return (void*)(p + 1);
 afa:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 afe:	70e2                	ld	ra,56(sp)
 b00:	7442                	ld	s0,48(sp)
 b02:	74a2                	ld	s1,40(sp)
 b04:	7902                	ld	s2,32(sp)
 b06:	69e2                	ld	s3,24(sp)
 b08:	6a42                	ld	s4,16(sp)
 b0a:	6aa2                	ld	s5,8(sp)
 b0c:	6b02                	ld	s6,0(sp)
 b0e:	6121                	addi	sp,sp,64
 b10:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b12:	6398                	ld	a4,0(a5)
 b14:	e118                	sd	a4,0(a0)
 b16:	bff1                	j	af2 <malloc+0x86>
  hp->s.size = nu;
 b18:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b1c:	0541                	addi	a0,a0,16
 b1e:	00000097          	auipc	ra,0x0
 b22:	ec6080e7          	jalr	-314(ra) # 9e4 <free>
  return freep;
 b26:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b2a:	d971                	beqz	a0,afe <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b2c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b2e:	4798                	lw	a4,8(a5)
 b30:	fa9776e3          	bgeu	a4,s1,adc <malloc+0x70>
    if(p == freep)
 b34:	00093703          	ld	a4,0(s2)
 b38:	853e                	mv	a0,a5
 b3a:	fef719e3          	bne	a4,a5,b2c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 b3e:	8552                	mv	a0,s4
 b40:	00000097          	auipc	ra,0x0
 b44:	b5e080e7          	jalr	-1186(ra) # 69e <sbrk>
  if(p == (char*)-1)
 b48:	fd5518e3          	bne	a0,s5,b18 <malloc+0xac>
        return 0;
 b4c:	4501                	li	a0,0
 b4e:	bf45                	j	afe <malloc+0x92>
