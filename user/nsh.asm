
user/_nsh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <trim>:
#include "kernel/fcntl.h"

static char *all,*next;
char buff[512];

char* trim(char *s){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
	char *temp;
	temp=s;
	while(*temp!='\0'){
   6:	00054683          	lbu	a3,0(a0)
   a:	caa9                	beqz	a3,5c <trim+0x5c>
	temp=s;
   c:	872a                	mv	a4,a0
		temp++;
   e:	0705                	addi	a4,a4,1
	while(*temp!='\0'){
  10:	00074783          	lbu	a5,0(a4)
  14:	ffed                	bnez	a5,e <trim+0xe>
	}
	while(*s==' '){
  16:	02000793          	li	a5,32
  1a:	00f69b63          	bne	a3,a5,30 <trim+0x30>
  1e:	02000693          	li	a3,32
		*s='\0';
  22:	00050023          	sb	zero,0(a0)
		s++;
  26:	0505                	addi	a0,a0,1
	while(*s==' '){
  28:	00054783          	lbu	a5,0(a0)
  2c:	fed78be3          	beq	a5,a3,22 <trim+0x22>
	}
	while(*(--temp)==' '){
  30:	fff70793          	addi	a5,a4,-1
  34:	fff74683          	lbu	a3,-1(a4)
  38:	02000713          	li	a4,32
  3c:	00e69b63          	bne	a3,a4,52 <trim+0x52>
  40:	02000693          	li	a3,32
		*temp='\0';
  44:	00078023          	sb	zero,0(a5)
	while(*(--temp)==' '){
  48:	17fd                	addi	a5,a5,-1
  4a:	0007c703          	lbu	a4,0(a5)
  4e:	fed70be3          	beq	a4,a3,44 <trim+0x44>
	}
	*(temp+1)='\0';
  52:	000780a3          	sb	zero,1(a5)
	return s;
}
  56:	6422                	ld	s0,8(sp)
  58:	0141                	addi	sp,sp,16
  5a:	8082                	ret
	temp=s;
  5c:	872a                	mv	a4,a0
  5e:	bfc9                	j	30 <trim+0x30>

0000000000000060 <redir>:

void redir(int mod,int p[]){
  60:	1101                	addi	sp,sp,-32
  62:	ec06                	sd	ra,24(sp)
  64:	e822                	sd	s0,16(sp)
  66:	e426                	sd	s1,8(sp)
  68:	e04a                	sd	s2,0(sp)
  6a:	1000                	addi	s0,sp,32
  6c:	84aa                	mv	s1,a0
  6e:	892e                	mv	s2,a1
	close(mod);
  70:	00000097          	auipc	ra,0x0
  74:	552080e7          	jalr	1362(ra) # 5c2 <close>
	dup(p[mod]);
  78:	048a                	slli	s1,s1,0x2
  7a:	94ca                	add	s1,s1,s2
  7c:	4088                	lw	a0,0(s1)
  7e:	00000097          	auipc	ra,0x0
  82:	594080e7          	jalr	1428(ra) # 612 <dup>
	close(p[0]);
  86:	00092503          	lw	a0,0(s2)
  8a:	00000097          	auipc	ra,0x0
  8e:	538080e7          	jalr	1336(ra) # 5c2 <close>
	close(p[1]);
  92:	00492503          	lw	a0,4(s2)
  96:	00000097          	auipc	ra,0x0
  9a:	52c080e7          	jalr	1324(ra) # 5c2 <close>
}
  9e:	60e2                	ld	ra,24(sp)
  a0:	6442                	ld	s0,16(sp)
  a2:	64a2                	ld	s1,8(sp)
  a4:	6902                	ld	s2,0(sp)
  a6:	6105                	addi	sp,sp,32
  a8:	8082                	ret

00000000000000aa <runcmd>:

void runcmd(char *cmd){
  aa:	c4010113          	addi	sp,sp,-960
  ae:	3a113c23          	sd	ra,952(sp)
  b2:	3a813823          	sd	s0,944(sp)
  b6:	3a913423          	sd	s1,936(sp)
  ba:	3b213023          	sd	s2,928(sp)
  be:	39313c23          	sd	s3,920(sp)
  c2:	0780                	addi	s0,sp,960
	char temp[23][23];
	char *pass[23];
	int count=0;

	cmd=trim(cmd);
  c4:	00000097          	auipc	ra,0x0
  c8:	f3c080e7          	jalr	-196(ra) # 0 <trim>
	for(int i=0;i<23;i++)pass[i]=temp[i];
  cc:	db840793          	addi	a5,s0,-584
  d0:	d0040713          	addi	a4,s0,-768
  d4:	fc940693          	addi	a3,s0,-55
  d8:	e31c                	sd	a5,0(a4)
  da:	07dd                	addi	a5,a5,23
  dc:	0721                	addi	a4,a4,8
  de:	fed79de3          	bne	a5,a3,d8 <runcmd+0x2e>
	char *s=temp[count];
	int ipos=0;
	int opos=0;
	for(char *p=cmd;*p;p++){
  e2:	00054703          	lbu	a4,0(a0)
  e6:	14070863          	beqz	a4,236 <runcmd+0x18c>
	int opos=0;
  ea:	4901                	li	s2,0
	int ipos=0;
  ec:	4981                	li	s3,0
	char *s=temp[count];
  ee:	db840793          	addi	a5,s0,-584
	int count=0;
  f2:	4681                	li	a3,0
		if(*p==' '||*p=='\n'){
  f4:	02000613          	li	a2,32
  f8:	45a9                	li	a1,10
			*s='\0';
			count++;
			s=temp[count];
		}else{
			if(*p=='<'){
  fa:	03c00813          	li	a6,60
				ipos=count++;
			}
			if(*p=='>'){
  fe:	03e00893          	li	a7,62
 102:	a005                	j	122 <runcmd+0x78>
			*s='\0';
 104:	00078023          	sb	zero,0(a5)
			count++;
 108:	2685                	addiw	a3,a3,1
			s=temp[count];
 10a:	00169793          	slli	a5,a3,0x1
 10e:	97b6                	add	a5,a5,a3
 110:	078e                	slli	a5,a5,0x3
 112:	8f95                	sub	a5,a5,a3
 114:	db840713          	addi	a4,s0,-584
 118:	97ba                	add	a5,a5,a4
	for(char *p=cmd;*p;p++){
 11a:	0505                	addi	a0,a0,1
 11c:	00054703          	lbu	a4,0(a0)
 120:	c315                	beqz	a4,144 <runcmd+0x9a>
		if(*p==' '||*p=='\n'){
 122:	fec701e3          	beq	a4,a2,104 <runcmd+0x5a>
 126:	fcb70fe3          	beq	a4,a1,104 <runcmd+0x5a>
			if(*p=='<'){
 12a:	01070763          	beq	a4,a6,138 <runcmd+0x8e>
			if(*p=='>'){
 12e:	01171763          	bne	a4,a7,13c <runcmd+0x92>
				opos=count++;
 132:	8936                	mv	s2,a3
 134:	2685                	addiw	a3,a3,1
 136:	a019                	j	13c <runcmd+0x92>
				ipos=count++;
 138:	89b6                	mv	s3,a3
 13a:	2685                	addiw	a3,a3,1
			}
			*s++=*p;
 13c:	00e78023          	sb	a4,0(a5)
 140:	0785                	addi	a5,a5,1
 142:	bfe1                	j	11a <runcmd+0x70>
		}
	}
	*s='\0';
 144:	00078023          	sb	zero,0(a5)
	count++;
 148:	0016849b          	addiw	s1,a3,1
	pass[count]=0;
 14c:	00349793          	slli	a5,s1,0x3
 150:	fd040713          	addi	a4,s0,-48
 154:	97ba                	add	a5,a5,a4
 156:	d207b823          	sd	zero,-720(a5)

	if(ipos){
 15a:	00099d63          	bnez	s3,174 <runcmd+0xca>
		close(0);
		open(pass[ipos],O_RDONLY);
	}
	if(opos){
 15e:	02091d63          	bnez	s2,198 <runcmd+0xee>
		open(pass[opos],O_WRONLY|O_CREATE);
	}

	char *pass2[23];
	int count2=0;
	for(int i=0;i<count;i++){
 162:	08905363          	blez	s1,1e8 <runcmd+0x13e>
 166:	c4840693          	addi	a3,s0,-952
 16a:	4781                	li	a5,0
 16c:	4601                	li	a2,0
		if(i==ipos-1)i+=2;
 16e:	39fd                	addiw	s3,s3,-1
		if(i==opos-1)i+=2;
 170:	397d                	addiw	s2,s2,-1
 172:	a0ad                	j	1dc <runcmd+0x132>
		close(0);
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	44c080e7          	jalr	1100(ra) # 5c2 <close>
		open(pass[ipos],O_RDONLY);
 17e:	00399793          	slli	a5,s3,0x3
 182:	fd040713          	addi	a4,s0,-48
 186:	97ba                	add	a5,a5,a4
 188:	4581                	li	a1,0
 18a:	d307b503          	ld	a0,-720(a5)
 18e:	00000097          	auipc	ra,0x0
 192:	44c080e7          	jalr	1100(ra) # 5da <open>
 196:	b7e1                	j	15e <runcmd+0xb4>
		close(1);
 198:	4505                	li	a0,1
 19a:	00000097          	auipc	ra,0x0
 19e:	428080e7          	jalr	1064(ra) # 5c2 <close>
		open(pass[opos],O_WRONLY|O_CREATE);
 1a2:	00391793          	slli	a5,s2,0x3
 1a6:	fd040713          	addi	a4,s0,-48
 1aa:	97ba                	add	a5,a5,a4
 1ac:	20100593          	li	a1,513
 1b0:	d307b503          	ld	a0,-720(a5)
 1b4:	00000097          	auipc	ra,0x0
 1b8:	426080e7          	jalr	1062(ra) # 5da <open>
 1bc:	b75d                	j	162 <runcmd+0xb8>
		if(i==ipos-1)i+=2;
 1be:	2789                	addiw	a5,a5,2
 1c0:	a005                	j	1e0 <runcmd+0x136>
		pass2[count2++]=pass[i];
 1c2:	2605                	addiw	a2,a2,1
 1c4:	00379713          	slli	a4,a5,0x3
 1c8:	fd040593          	addi	a1,s0,-48
 1cc:	972e                	add	a4,a4,a1
 1ce:	d3073703          	ld	a4,-720(a4)
 1d2:	e298                	sd	a4,0(a3)
	for(int i=0;i<count;i++){
 1d4:	2785                	addiw	a5,a5,1
 1d6:	06a1                	addi	a3,a3,8
 1d8:	0097d963          	bge	a5,s1,1ea <runcmd+0x140>
		if(i==ipos-1)i+=2;
 1dc:	fef981e3          	beq	s3,a5,1be <runcmd+0x114>
		if(i==opos-1)i+=2;
 1e0:	fef911e3          	bne	s2,a5,1c2 <runcmd+0x118>
 1e4:	2789                	addiw	a5,a5,2
 1e6:	bff1                	j	1c2 <runcmd+0x118>
	for(int i=0;i<count;i++){
 1e8:	4601                	li	a2,0
	}
	pass2[count2]=0;
 1ea:	060e                	slli	a2,a2,0x3
 1ec:	fd040793          	addi	a5,s0,-48
 1f0:	963e                	add	a2,a2,a5
 1f2:	c6063c23          	sd	zero,-904(a2)

	if(fork()){
 1f6:	00000097          	auipc	ra,0x0
 1fa:	39c080e7          	jalr	924(ra) # 592 <fork>
 1fe:	c11d                	beqz	a0,224 <runcmd+0x17a>
		wait(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	3a0080e7          	jalr	928(ra) # 5a2 <wait>
	}else{
		exec(pass2[0],pass2);
	}
}
 20a:	3b813083          	ld	ra,952(sp)
 20e:	3b013403          	ld	s0,944(sp)
 212:	3a813483          	ld	s1,936(sp)
 216:	3a013903          	ld	s2,928(sp)
 21a:	39813983          	ld	s3,920(sp)
 21e:	3c010113          	addi	sp,sp,960
 222:	8082                	ret
		exec(pass2[0],pass2);
 224:	c4840593          	addi	a1,s0,-952
 228:	c4843503          	ld	a0,-952(s0)
 22c:	00000097          	auipc	ra,0x0
 230:	3a6080e7          	jalr	934(ra) # 5d2 <exec>
}
 234:	bfd9                	j	20a <runcmd+0x160>
	*s='\0';
 236:	da040c23          	sb	zero,-584(s0)
	pass[count]=0;
 23a:	d0043423          	sd	zero,-760(s0)
	count++;
 23e:	4485                	li	s1,1
	int ipos=0;
 240:	4981                	li	s3,0
	int opos=0;
 242:	4901                	li	s2,0
 244:	bf39                	j	162 <runcmd+0xb8>

0000000000000246 <handlecmd>:

int handlecmd(){
 246:	1101                	addi	sp,sp,-32
 248:	ec06                	sd	ra,24(sp)
 24a:	e822                	sd	s0,16(sp)
 24c:	1000                	addi	s0,sp,32
	//gets(buff,num);
	//if(buff[0]==0){
	//	return -1;
	//}
	//return 0;
	if(all!=0){
 24e:	00001797          	auipc	a5,0x1
 252:	8ca7b783          	ld	a5,-1846(a5) # b18 <all>
 256:	cfa1                	beqz	a5,2ae <handlecmd+0x68>
		int p[2];
		pipe(p);
 258:	fe840513          	addi	a0,s0,-24
 25c:	00000097          	auipc	ra,0x0
 260:	34e080e7          	jalr	846(ra) # 5aa <pipe>
		
		if(next)
 264:	00001797          	auipc	a5,0x1
 268:	8ac7b783          	ld	a5,-1876(a5) # b10 <next>
 26c:	cb81                	beqz	a5,27c <handlecmd+0x36>
			redir(1,p);
 26e:	fe840593          	addi	a1,s0,-24
 272:	4505                	li	a0,1
 274:	00000097          	auipc	ra,0x0
 278:	dec080e7          	jalr	-532(ra) # 60 <redir>
		runcmd(all);
 27c:	00001517          	auipc	a0,0x1
 280:	89c53503          	ld	a0,-1892(a0) # b18 <all>
 284:	00000097          	auipc	ra,0x0
 288:	e26080e7          	jalr	-474(ra) # aa <runcmd>
		close(p[0]);
 28c:	fe842503          	lw	a0,-24(s0)
 290:	00000097          	auipc	ra,0x0
 294:	332080e7          	jalr	818(ra) # 5c2 <close>
		close(p[1]);
 298:	fec42503          	lw	a0,-20(s0)
 29c:	00000097          	auipc	ra,0x0
 2a0:	326080e7          	jalr	806(ra) # 5c2 <close>
		wait(0);
 2a4:	4501                	li	a0,0
 2a6:	00000097          	auipc	ra,0x0
 2aa:	2fc080e7          	jalr	764(ra) # 5a2 <wait>
	}
	exit(0);
 2ae:	4501                	li	a0,0
 2b0:	00000097          	auipc	ra,0x0
 2b4:	2ea080e7          	jalr	746(ra) # 59a <exit>

00000000000002b8 <tok>:
}

char *tok(char *p,char c){
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
	while(*p!='\0'&&*p!=c){
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	cb89                	beqz	a5,2d4 <tok+0x1c>
 2c4:	00f58a63          	beq	a1,a5,2d8 <tok+0x20>
		p++;
 2c8:	0505                	addi	a0,a0,1
	while(*p!='\0'&&*p!=c){
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	fbfd                	bnez	a5,2c4 <tok+0xc>
	}
	if(*p=='\0'){
		return 0;   //contain no c
 2d0:	4501                	li	a0,0
 2d2:	a039                	j	2e0 <tok+0x28>
 2d4:	4501                	li	a0,0
 2d6:	a029                	j	2e0 <tok+0x28>
	if(*p=='\0'){
 2d8:	c599                	beqz	a1,2e6 <tok+0x2e>
	}
	*p='\0';   //cut rest part of string
 2da:	00050023          	sb	zero,0(a0)
	return p+1;
 2de:	0505                	addi	a0,a0,1
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
		return 0;   //contain no c
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <tok+0x28>

00000000000002ea <main>:

int main(int argc,char *argv[]){
 2ea:	1101                	addi	sp,sp,-32
 2ec:	ec06                	sd	ra,24(sp)
 2ee:	e822                	sd	s0,16(sp)
 2f0:	e426                	sd	s1,8(sp)
 2f2:	e04a                	sd	s2,0(sp)
 2f4:	1000                	addi	s0,sp,32
	//char *buff;
	//int fd;
	
	while(1){
		fprintf(1,"@ ");
 2f6:	00000917          	auipc	s2,0x0
 2fa:	7e290913          	addi	s2,s2,2018 # ad8 <malloc+0xe8>
		memset(buff,0,512);
 2fe:	00001497          	auipc	s1,0x1
 302:	82a48493          	addi	s1,s1,-2006 # b28 <buff>
		fprintf(1,"@ ");
 306:	85ca                	mv	a1,s2
 308:	4505                	li	a0,1
 30a:	00000097          	auipc	ra,0x0
 30e:	5fa080e7          	jalr	1530(ra) # 904 <fprintf>
		memset(buff,0,512);
 312:	20000613          	li	a2,512
 316:	4581                	li	a1,0
 318:	8526                	mv	a0,s1
 31a:	00000097          	auipc	ra,0x0
 31e:	0fc080e7          	jalr	252(ra) # 416 <memset>
		gets(buff,512);
 322:	20000593          	li	a1,512
 326:	8526                	mv	a0,s1
 328:	00000097          	auipc	ra,0x0
 32c:	138080e7          	jalr	312(ra) # 460 <gets>

		if(buff[0]==0){
 330:	0004c783          	lbu	a5,0(s1)
 334:	c785                	beqz	a5,35c <main+0x72>
			fprintf(2,"no command.\n");
			exit(0);
		}
		char *temp=strchr(buff,'\n');
 336:	45a9                	li	a1,10
 338:	8526                	mv	a0,s1
 33a:	00000097          	auipc	ra,0x0
 33e:	102080e7          	jalr	258(ra) # 43c <strchr>
		temp[0]='\0';   //only receive one line
 342:	00050023          	sb	zero,0(a0)
		
		if(fork()){
 346:	00000097          	auipc	ra,0x0
 34a:	24c080e7          	jalr	588(ra) # 592 <fork>
 34e:	c50d                	beqz	a0,378 <main+0x8e>
			wait(0);
 350:	4501                	li	a0,0
 352:	00000097          	auipc	ra,0x0
 356:	250080e7          	jalr	592(ra) # 5a2 <wait>
 35a:	b775                	j	306 <main+0x1c>
			fprintf(2,"no command.\n");
 35c:	00000597          	auipc	a1,0x0
 360:	78458593          	addi	a1,a1,1924 # ae0 <malloc+0xf0>
 364:	4509                	li	a0,2
 366:	00000097          	auipc	ra,0x0
 36a:	59e080e7          	jalr	1438(ra) # 904 <fprintf>
			exit(0);
 36e:	4501                	li	a0,0
 370:	00000097          	auipc	ra,0x0
 374:	22a080e7          	jalr	554(ra) # 59a <exit>
		}else{
			all=buff;
 378:	00000517          	auipc	a0,0x0
 37c:	7b050513          	addi	a0,a0,1968 # b28 <buff>
 380:	00000797          	auipc	a5,0x0
 384:	78a7bc23          	sd	a0,1944(a5) # b18 <all>
			next=tok(all,'|');
 388:	07c00593          	li	a1,124
 38c:	00000097          	auipc	ra,0x0
 390:	f2c080e7          	jalr	-212(ra) # 2b8 <tok>
 394:	00000797          	auipc	a5,0x0
 398:	76a7be23          	sd	a0,1916(a5) # b10 <next>
			handlecmd();}
 39c:	00000097          	auipc	ra,0x0
 3a0:	eaa080e7          	jalr	-342(ra) # 246 <handlecmd>

00000000000003a4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e422                	sd	s0,8(sp)
 3a8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 3aa:	87aa                	mv	a5,a0
 3ac:	0585                	addi	a1,a1,1
 3ae:	0785                	addi	a5,a5,1
 3b0:	fff5c703          	lbu	a4,-1(a1)
 3b4:	fee78fa3          	sb	a4,-1(a5)
 3b8:	fb75                	bnez	a4,3ac <strcpy+0x8>
    ;
  return os;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3c6:	00054783          	lbu	a5,0(a0)
 3ca:	cb91                	beqz	a5,3de <strcmp+0x1e>
 3cc:	0005c703          	lbu	a4,0(a1)
 3d0:	00f71763          	bne	a4,a5,3de <strcmp+0x1e>
    p++, q++;
 3d4:	0505                	addi	a0,a0,1
 3d6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3d8:	00054783          	lbu	a5,0(a0)
 3dc:	fbe5                	bnez	a5,3cc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3de:	0005c503          	lbu	a0,0(a1)
}
 3e2:	40a7853b          	subw	a0,a5,a0
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret

00000000000003ec <strlen>:

uint
strlen(const char *s)
{
 3ec:	1141                	addi	sp,sp,-16
 3ee:	e422                	sd	s0,8(sp)
 3f0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3f2:	00054783          	lbu	a5,0(a0)
 3f6:	cf91                	beqz	a5,412 <strlen+0x26>
 3f8:	0505                	addi	a0,a0,1
 3fa:	87aa                	mv	a5,a0
 3fc:	4685                	li	a3,1
 3fe:	9e89                	subw	a3,a3,a0
 400:	00f6853b          	addw	a0,a3,a5
 404:	0785                	addi	a5,a5,1
 406:	fff7c703          	lbu	a4,-1(a5)
 40a:	fb7d                	bnez	a4,400 <strlen+0x14>
    ;
  return n;
}
 40c:	6422                	ld	s0,8(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret
  for(n = 0; s[n]; n++)
 412:	4501                	li	a0,0
 414:	bfe5                	j	40c <strlen+0x20>

0000000000000416 <memset>:

void*
memset(void *dst, int c, uint n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e422                	sd	s0,8(sp)
 41a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 41c:	ce09                	beqz	a2,436 <memset+0x20>
 41e:	87aa                	mv	a5,a0
 420:	fff6071b          	addiw	a4,a2,-1
 424:	1702                	slli	a4,a4,0x20
 426:	9301                	srli	a4,a4,0x20
 428:	0705                	addi	a4,a4,1
 42a:	972a                	add	a4,a4,a0
    cdst[i] = c;
 42c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 430:	0785                	addi	a5,a5,1
 432:	fee79de3          	bne	a5,a4,42c <memset+0x16>
  }
  return dst;
}
 436:	6422                	ld	s0,8(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <strchr>:

char*
strchr(const char *s, char c)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e422                	sd	s0,8(sp)
 440:	0800                	addi	s0,sp,16
  for(; *s; s++)
 442:	00054783          	lbu	a5,0(a0)
 446:	cb99                	beqz	a5,45c <strchr+0x20>
    if(*s == c)
 448:	00f58763          	beq	a1,a5,456 <strchr+0x1a>
  for(; *s; s++)
 44c:	0505                	addi	a0,a0,1
 44e:	00054783          	lbu	a5,0(a0)
 452:	fbfd                	bnez	a5,448 <strchr+0xc>
      return (char*)s;
  return 0;
 454:	4501                	li	a0,0
}
 456:	6422                	ld	s0,8(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret
  return 0;
 45c:	4501                	li	a0,0
 45e:	bfe5                	j	456 <strchr+0x1a>

0000000000000460 <gets>:

char*
gets(char *buf, int max)
{
 460:	711d                	addi	sp,sp,-96
 462:	ec86                	sd	ra,88(sp)
 464:	e8a2                	sd	s0,80(sp)
 466:	e4a6                	sd	s1,72(sp)
 468:	e0ca                	sd	s2,64(sp)
 46a:	fc4e                	sd	s3,56(sp)
 46c:	f852                	sd	s4,48(sp)
 46e:	f456                	sd	s5,40(sp)
 470:	f05a                	sd	s6,32(sp)
 472:	ec5e                	sd	s7,24(sp)
 474:	1080                	addi	s0,sp,96
 476:	8baa                	mv	s7,a0
 478:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 47a:	892a                	mv	s2,a0
 47c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 47e:	4aa9                	li	s5,10
 480:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 482:	89a6                	mv	s3,s1
 484:	2485                	addiw	s1,s1,1
 486:	0344d863          	bge	s1,s4,4b6 <gets+0x56>
    cc = read(0, &c, 1);
 48a:	4605                	li	a2,1
 48c:	faf40593          	addi	a1,s0,-81
 490:	4501                	li	a0,0
 492:	00000097          	auipc	ra,0x0
 496:	120080e7          	jalr	288(ra) # 5b2 <read>
    if(cc < 1)
 49a:	00a05e63          	blez	a0,4b6 <gets+0x56>
    buf[i++] = c;
 49e:	faf44783          	lbu	a5,-81(s0)
 4a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 4a6:	01578763          	beq	a5,s5,4b4 <gets+0x54>
 4aa:	0905                	addi	s2,s2,1
 4ac:	fd679be3          	bne	a5,s6,482 <gets+0x22>
  for(i=0; i+1 < max; ){
 4b0:	89a6                	mv	s3,s1
 4b2:	a011                	j	4b6 <gets+0x56>
 4b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4b6:	99de                	add	s3,s3,s7
 4b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 4bc:	855e                	mv	a0,s7
 4be:	60e6                	ld	ra,88(sp)
 4c0:	6446                	ld	s0,80(sp)
 4c2:	64a6                	ld	s1,72(sp)
 4c4:	6906                	ld	s2,64(sp)
 4c6:	79e2                	ld	s3,56(sp)
 4c8:	7a42                	ld	s4,48(sp)
 4ca:	7aa2                	ld	s5,40(sp)
 4cc:	7b02                	ld	s6,32(sp)
 4ce:	6be2                	ld	s7,24(sp)
 4d0:	6125                	addi	sp,sp,96
 4d2:	8082                	ret

00000000000004d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 4d4:	1101                	addi	sp,sp,-32
 4d6:	ec06                	sd	ra,24(sp)
 4d8:	e822                	sd	s0,16(sp)
 4da:	e426                	sd	s1,8(sp)
 4dc:	e04a                	sd	s2,0(sp)
 4de:	1000                	addi	s0,sp,32
 4e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4e2:	4581                	li	a1,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	0f6080e7          	jalr	246(ra) # 5da <open>
  if(fd < 0)
 4ec:	02054563          	bltz	a0,516 <stat+0x42>
 4f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4f2:	85ca                	mv	a1,s2
 4f4:	00000097          	auipc	ra,0x0
 4f8:	0fe080e7          	jalr	254(ra) # 5f2 <fstat>
 4fc:	892a                	mv	s2,a0
  close(fd);
 4fe:	8526                	mv	a0,s1
 500:	00000097          	auipc	ra,0x0
 504:	0c2080e7          	jalr	194(ra) # 5c2 <close>
  return r;
}
 508:	854a                	mv	a0,s2
 50a:	60e2                	ld	ra,24(sp)
 50c:	6442                	ld	s0,16(sp)
 50e:	64a2                	ld	s1,8(sp)
 510:	6902                	ld	s2,0(sp)
 512:	6105                	addi	sp,sp,32
 514:	8082                	ret
    return -1;
 516:	597d                	li	s2,-1
 518:	bfc5                	j	508 <stat+0x34>

000000000000051a <atoi>:

int
atoi(const char *s)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e422                	sd	s0,8(sp)
 51e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 520:	00054603          	lbu	a2,0(a0)
 524:	fd06079b          	addiw	a5,a2,-48
 528:	0ff7f793          	andi	a5,a5,255
 52c:	4725                	li	a4,9
 52e:	02f76963          	bltu	a4,a5,560 <atoi+0x46>
 532:	86aa                	mv	a3,a0
  n = 0;
 534:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 536:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 538:	0685                	addi	a3,a3,1
 53a:	0025179b          	slliw	a5,a0,0x2
 53e:	9fa9                	addw	a5,a5,a0
 540:	0017979b          	slliw	a5,a5,0x1
 544:	9fb1                	addw	a5,a5,a2
 546:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 54a:	0006c603          	lbu	a2,0(a3)
 54e:	fd06071b          	addiw	a4,a2,-48
 552:	0ff77713          	andi	a4,a4,255
 556:	fee5f1e3          	bgeu	a1,a4,538 <atoi+0x1e>
  return n;
}
 55a:	6422                	ld	s0,8(sp)
 55c:	0141                	addi	sp,sp,16
 55e:	8082                	ret
  n = 0;
 560:	4501                	li	a0,0
 562:	bfe5                	j	55a <atoi+0x40>

0000000000000564 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 564:	1141                	addi	sp,sp,-16
 566:	e422                	sd	s0,8(sp)
 568:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 56a:	02c05163          	blez	a2,58c <memmove+0x28>
 56e:	fff6071b          	addiw	a4,a2,-1
 572:	1702                	slli	a4,a4,0x20
 574:	9301                	srli	a4,a4,0x20
 576:	0705                	addi	a4,a4,1
 578:	972a                	add	a4,a4,a0
  dst = vdst;
 57a:	87aa                	mv	a5,a0
    *dst++ = *src++;
 57c:	0585                	addi	a1,a1,1
 57e:	0785                	addi	a5,a5,1
 580:	fff5c683          	lbu	a3,-1(a1)
 584:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
 588:	fee79ae3          	bne	a5,a4,57c <memmove+0x18>
  return vdst;
}
 58c:	6422                	ld	s0,8(sp)
 58e:	0141                	addi	sp,sp,16
 590:	8082                	ret

0000000000000592 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 592:	4885                	li	a7,1
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <exit>:
.global exit
exit:
 li a7, SYS_exit
 59a:	4889                	li	a7,2
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5a2:	488d                	li	a7,3
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5aa:	4891                	li	a7,4
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <read>:
.global read
read:
 li a7, SYS_read
 5b2:	4895                	li	a7,5
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <write>:
.global write
write:
 li a7, SYS_write
 5ba:	48c1                	li	a7,16
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <close>:
.global close
close:
 li a7, SYS_close
 5c2:	48d5                	li	a7,21
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ca:	4899                	li	a7,6
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5d2:	489d                	li	a7,7
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <open>:
.global open
open:
 li a7, SYS_open
 5da:	48bd                	li	a7,15
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5e2:	48c5                	li	a7,17
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5ea:	48c9                	li	a7,18
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5f2:	48a1                	li	a7,8
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <link>:
.global link
link:
 li a7, SYS_link
 5fa:	48cd                	li	a7,19
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 602:	48d1                	li	a7,20
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 60a:	48a5                	li	a7,9
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <dup>:
.global dup
dup:
 li a7, SYS_dup
 612:	48a9                	li	a7,10
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 61a:	48ad                	li	a7,11
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 622:	48b1                	li	a7,12
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 62a:	48b5                	li	a7,13
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 632:	48b9                	li	a7,14
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 63a:	48d9                	li	a7,22
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <crash>:
.global crash
crash:
 li a7, SYS_crash
 642:	48dd                	li	a7,23
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <mount>:
.global mount
mount:
 li a7, SYS_mount
 64a:	48e1                	li	a7,24
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <umount>:
.global umount
umount:
 li a7, SYS_umount
 652:	48e5                	li	a7,25
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 65a:	1101                	addi	sp,sp,-32
 65c:	ec06                	sd	ra,24(sp)
 65e:	e822                	sd	s0,16(sp)
 660:	1000                	addi	s0,sp,32
 662:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 666:	4605                	li	a2,1
 668:	fef40593          	addi	a1,s0,-17
 66c:	00000097          	auipc	ra,0x0
 670:	f4e080e7          	jalr	-178(ra) # 5ba <write>
}
 674:	60e2                	ld	ra,24(sp)
 676:	6442                	ld	s0,16(sp)
 678:	6105                	addi	sp,sp,32
 67a:	8082                	ret

000000000000067c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 67c:	7139                	addi	sp,sp,-64
 67e:	fc06                	sd	ra,56(sp)
 680:	f822                	sd	s0,48(sp)
 682:	f426                	sd	s1,40(sp)
 684:	f04a                	sd	s2,32(sp)
 686:	ec4e                	sd	s3,24(sp)
 688:	0080                	addi	s0,sp,64
 68a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 68c:	c299                	beqz	a3,692 <printint+0x16>
 68e:	0805c863          	bltz	a1,71e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 692:	2581                	sext.w	a1,a1
  neg = 0;
 694:	4881                	li	a7,0
 696:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 69a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 69c:	2601                	sext.w	a2,a2
 69e:	00000517          	auipc	a0,0x0
 6a2:	45a50513          	addi	a0,a0,1114 # af8 <digits>
 6a6:	883a                	mv	a6,a4
 6a8:	2705                	addiw	a4,a4,1
 6aa:	02c5f7bb          	remuw	a5,a1,a2
 6ae:	1782                	slli	a5,a5,0x20
 6b0:	9381                	srli	a5,a5,0x20
 6b2:	97aa                	add	a5,a5,a0
 6b4:	0007c783          	lbu	a5,0(a5)
 6b8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6bc:	0005879b          	sext.w	a5,a1
 6c0:	02c5d5bb          	divuw	a1,a1,a2
 6c4:	0685                	addi	a3,a3,1
 6c6:	fec7f0e3          	bgeu	a5,a2,6a6 <printint+0x2a>
  if(neg)
 6ca:	00088b63          	beqz	a7,6e0 <printint+0x64>
    buf[i++] = '-';
 6ce:	fd040793          	addi	a5,s0,-48
 6d2:	973e                	add	a4,a4,a5
 6d4:	02d00793          	li	a5,45
 6d8:	fef70823          	sb	a5,-16(a4)
 6dc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6e0:	02e05863          	blez	a4,710 <printint+0x94>
 6e4:	fc040793          	addi	a5,s0,-64
 6e8:	00e78933          	add	s2,a5,a4
 6ec:	fff78993          	addi	s3,a5,-1
 6f0:	99ba                	add	s3,s3,a4
 6f2:	377d                	addiw	a4,a4,-1
 6f4:	1702                	slli	a4,a4,0x20
 6f6:	9301                	srli	a4,a4,0x20
 6f8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6fc:	fff94583          	lbu	a1,-1(s2)
 700:	8526                	mv	a0,s1
 702:	00000097          	auipc	ra,0x0
 706:	f58080e7          	jalr	-168(ra) # 65a <putc>
  while(--i >= 0)
 70a:	197d                	addi	s2,s2,-1
 70c:	ff3918e3          	bne	s2,s3,6fc <printint+0x80>
}
 710:	70e2                	ld	ra,56(sp)
 712:	7442                	ld	s0,48(sp)
 714:	74a2                	ld	s1,40(sp)
 716:	7902                	ld	s2,32(sp)
 718:	69e2                	ld	s3,24(sp)
 71a:	6121                	addi	sp,sp,64
 71c:	8082                	ret
    x = -xx;
 71e:	40b005bb          	negw	a1,a1
    neg = 1;
 722:	4885                	li	a7,1
    x = -xx;
 724:	bf8d                	j	696 <printint+0x1a>

0000000000000726 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 726:	7119                	addi	sp,sp,-128
 728:	fc86                	sd	ra,120(sp)
 72a:	f8a2                	sd	s0,112(sp)
 72c:	f4a6                	sd	s1,104(sp)
 72e:	f0ca                	sd	s2,96(sp)
 730:	ecce                	sd	s3,88(sp)
 732:	e8d2                	sd	s4,80(sp)
 734:	e4d6                	sd	s5,72(sp)
 736:	e0da                	sd	s6,64(sp)
 738:	fc5e                	sd	s7,56(sp)
 73a:	f862                	sd	s8,48(sp)
 73c:	f466                	sd	s9,40(sp)
 73e:	f06a                	sd	s10,32(sp)
 740:	ec6e                	sd	s11,24(sp)
 742:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 744:	0005c903          	lbu	s2,0(a1)
 748:	18090f63          	beqz	s2,8e6 <vprintf+0x1c0>
 74c:	8aaa                	mv	s5,a0
 74e:	8b32                	mv	s6,a2
 750:	00158493          	addi	s1,a1,1
  state = 0;
 754:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 756:	02500a13          	li	s4,37
      if(c == 'd'){
 75a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 75e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 762:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 766:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76a:	00000b97          	auipc	s7,0x0
 76e:	38eb8b93          	addi	s7,s7,910 # af8 <digits>
 772:	a839                	j	790 <vprintf+0x6a>
        putc(fd, c);
 774:	85ca                	mv	a1,s2
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	ee2080e7          	jalr	-286(ra) # 65a <putc>
 780:	a019                	j	786 <vprintf+0x60>
    } else if(state == '%'){
 782:	01498f63          	beq	s3,s4,7a0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 786:	0485                	addi	s1,s1,1
 788:	fff4c903          	lbu	s2,-1(s1)
 78c:	14090d63          	beqz	s2,8e6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 790:	0009079b          	sext.w	a5,s2
    if(state == 0){
 794:	fe0997e3          	bnez	s3,782 <vprintf+0x5c>
      if(c == '%'){
 798:	fd479ee3          	bne	a5,s4,774 <vprintf+0x4e>
        state = '%';
 79c:	89be                	mv	s3,a5
 79e:	b7e5                	j	786 <vprintf+0x60>
      if(c == 'd'){
 7a0:	05878063          	beq	a5,s8,7e0 <vprintf+0xba>
      } else if(c == 'l') {
 7a4:	05978c63          	beq	a5,s9,7fc <vprintf+0xd6>
      } else if(c == 'x') {
 7a8:	07a78863          	beq	a5,s10,818 <vprintf+0xf2>
      } else if(c == 'p') {
 7ac:	09b78463          	beq	a5,s11,834 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7b0:	07300713          	li	a4,115
 7b4:	0ce78663          	beq	a5,a4,880 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7b8:	06300713          	li	a4,99
 7bc:	0ee78e63          	beq	a5,a4,8b8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7c0:	11478863          	beq	a5,s4,8d0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c4:	85d2                	mv	a1,s4
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	e92080e7          	jalr	-366(ra) # 65a <putc>
        putc(fd, c);
 7d0:	85ca                	mv	a1,s2
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	e86080e7          	jalr	-378(ra) # 65a <putc>
      }
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b765                	j	786 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7e0:	008b0913          	addi	s2,s6,8
 7e4:	4685                	li	a3,1
 7e6:	4629                	li	a2,10
 7e8:	000b2583          	lw	a1,0(s6)
 7ec:	8556                	mv	a0,s5
 7ee:	00000097          	auipc	ra,0x0
 7f2:	e8e080e7          	jalr	-370(ra) # 67c <printint>
 7f6:	8b4a                	mv	s6,s2
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	b771                	j	786 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fc:	008b0913          	addi	s2,s6,8
 800:	4681                	li	a3,0
 802:	4629                	li	a2,10
 804:	000b2583          	lw	a1,0(s6)
 808:	8556                	mv	a0,s5
 80a:	00000097          	auipc	ra,0x0
 80e:	e72080e7          	jalr	-398(ra) # 67c <printint>
 812:	8b4a                	mv	s6,s2
      state = 0;
 814:	4981                	li	s3,0
 816:	bf85                	j	786 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 818:	008b0913          	addi	s2,s6,8
 81c:	4681                	li	a3,0
 81e:	4641                	li	a2,16
 820:	000b2583          	lw	a1,0(s6)
 824:	8556                	mv	a0,s5
 826:	00000097          	auipc	ra,0x0
 82a:	e56080e7          	jalr	-426(ra) # 67c <printint>
 82e:	8b4a                	mv	s6,s2
      state = 0;
 830:	4981                	li	s3,0
 832:	bf91                	j	786 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 834:	008b0793          	addi	a5,s6,8
 838:	f8f43423          	sd	a5,-120(s0)
 83c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 840:	03000593          	li	a1,48
 844:	8556                	mv	a0,s5
 846:	00000097          	auipc	ra,0x0
 84a:	e14080e7          	jalr	-492(ra) # 65a <putc>
  putc(fd, 'x');
 84e:	85ea                	mv	a1,s10
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	e08080e7          	jalr	-504(ra) # 65a <putc>
 85a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 85c:	03c9d793          	srli	a5,s3,0x3c
 860:	97de                	add	a5,a5,s7
 862:	0007c583          	lbu	a1,0(a5)
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	df2080e7          	jalr	-526(ra) # 65a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 870:	0992                	slli	s3,s3,0x4
 872:	397d                	addiw	s2,s2,-1
 874:	fe0914e3          	bnez	s2,85c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 878:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 87c:	4981                	li	s3,0
 87e:	b721                	j	786 <vprintf+0x60>
        s = va_arg(ap, char*);
 880:	008b0993          	addi	s3,s6,8
 884:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 888:	02090163          	beqz	s2,8aa <vprintf+0x184>
        while(*s != 0){
 88c:	00094583          	lbu	a1,0(s2)
 890:	c9a1                	beqz	a1,8e0 <vprintf+0x1ba>
          putc(fd, *s);
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	dc6080e7          	jalr	-570(ra) # 65a <putc>
          s++;
 89c:	0905                	addi	s2,s2,1
        while(*s != 0){
 89e:	00094583          	lbu	a1,0(s2)
 8a2:	f9e5                	bnez	a1,892 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8a4:	8b4e                	mv	s6,s3
      state = 0;
 8a6:	4981                	li	s3,0
 8a8:	bdf9                	j	786 <vprintf+0x60>
          s = "(null)";
 8aa:	00000917          	auipc	s2,0x0
 8ae:	24690913          	addi	s2,s2,582 # af0 <malloc+0x100>
        while(*s != 0){
 8b2:	02800593          	li	a1,40
 8b6:	bff1                	j	892 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8b8:	008b0913          	addi	s2,s6,8
 8bc:	000b4583          	lbu	a1,0(s6)
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	d98080e7          	jalr	-616(ra) # 65a <putc>
 8ca:	8b4a                	mv	s6,s2
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	bd65                	j	786 <vprintf+0x60>
        putc(fd, c);
 8d0:	85d2                	mv	a1,s4
 8d2:	8556                	mv	a0,s5
 8d4:	00000097          	auipc	ra,0x0
 8d8:	d86080e7          	jalr	-634(ra) # 65a <putc>
      state = 0;
 8dc:	4981                	li	s3,0
 8de:	b565                	j	786 <vprintf+0x60>
        s = va_arg(ap, char*);
 8e0:	8b4e                	mv	s6,s3
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	b54d                	j	786 <vprintf+0x60>
    }
  }
}
 8e6:	70e6                	ld	ra,120(sp)
 8e8:	7446                	ld	s0,112(sp)
 8ea:	74a6                	ld	s1,104(sp)
 8ec:	7906                	ld	s2,96(sp)
 8ee:	69e6                	ld	s3,88(sp)
 8f0:	6a46                	ld	s4,80(sp)
 8f2:	6aa6                	ld	s5,72(sp)
 8f4:	6b06                	ld	s6,64(sp)
 8f6:	7be2                	ld	s7,56(sp)
 8f8:	7c42                	ld	s8,48(sp)
 8fa:	7ca2                	ld	s9,40(sp)
 8fc:	7d02                	ld	s10,32(sp)
 8fe:	6de2                	ld	s11,24(sp)
 900:	6109                	addi	sp,sp,128
 902:	8082                	ret

0000000000000904 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 904:	715d                	addi	sp,sp,-80
 906:	ec06                	sd	ra,24(sp)
 908:	e822                	sd	s0,16(sp)
 90a:	1000                	addi	s0,sp,32
 90c:	e010                	sd	a2,0(s0)
 90e:	e414                	sd	a3,8(s0)
 910:	e818                	sd	a4,16(s0)
 912:	ec1c                	sd	a5,24(s0)
 914:	03043023          	sd	a6,32(s0)
 918:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 91c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 920:	8622                	mv	a2,s0
 922:	00000097          	auipc	ra,0x0
 926:	e04080e7          	jalr	-508(ra) # 726 <vprintf>
}
 92a:	60e2                	ld	ra,24(sp)
 92c:	6442                	ld	s0,16(sp)
 92e:	6161                	addi	sp,sp,80
 930:	8082                	ret

0000000000000932 <printf>:

void
printf(const char *fmt, ...)
{
 932:	711d                	addi	sp,sp,-96
 934:	ec06                	sd	ra,24(sp)
 936:	e822                	sd	s0,16(sp)
 938:	1000                	addi	s0,sp,32
 93a:	e40c                	sd	a1,8(s0)
 93c:	e810                	sd	a2,16(s0)
 93e:	ec14                	sd	a3,24(s0)
 940:	f018                	sd	a4,32(s0)
 942:	f41c                	sd	a5,40(s0)
 944:	03043823          	sd	a6,48(s0)
 948:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 94c:	00840613          	addi	a2,s0,8
 950:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 954:	85aa                	mv	a1,a0
 956:	4505                	li	a0,1
 958:	00000097          	auipc	ra,0x0
 95c:	dce080e7          	jalr	-562(ra) # 726 <vprintf>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6125                	addi	sp,sp,96
 966:	8082                	ret

0000000000000968 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 968:	1141                	addi	sp,sp,-16
 96a:	e422                	sd	s0,8(sp)
 96c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 96e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 972:	00000797          	auipc	a5,0x0
 976:	1ae7b783          	ld	a5,430(a5) # b20 <freep>
 97a:	a805                	j	9aa <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 97c:	4618                	lw	a4,8(a2)
 97e:	9db9                	addw	a1,a1,a4
 980:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	6398                	ld	a4,0(a5)
 986:	6318                	ld	a4,0(a4)
 988:	fee53823          	sd	a4,-16(a0)
 98c:	a091                	j	9d0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 98e:	ff852703          	lw	a4,-8(a0)
 992:	9e39                	addw	a2,a2,a4
 994:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 996:	ff053703          	ld	a4,-16(a0)
 99a:	e398                	sd	a4,0(a5)
 99c:	a099                	j	9e2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 99e:	6398                	ld	a4,0(a5)
 9a0:	00e7e463          	bltu	a5,a4,9a8 <free+0x40>
 9a4:	00e6ea63          	bltu	a3,a4,9b8 <free+0x50>
{
 9a8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9aa:	fed7fae3          	bgeu	a5,a3,99e <free+0x36>
 9ae:	6398                	ld	a4,0(a5)
 9b0:	00e6e463          	bltu	a3,a4,9b8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b4:	fee7eae3          	bltu	a5,a4,9a8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9b8:	ff852583          	lw	a1,-8(a0)
 9bc:	6390                	ld	a2,0(a5)
 9be:	02059713          	slli	a4,a1,0x20
 9c2:	9301                	srli	a4,a4,0x20
 9c4:	0712                	slli	a4,a4,0x4
 9c6:	9736                	add	a4,a4,a3
 9c8:	fae60ae3          	beq	a2,a4,97c <free+0x14>
    bp->s.ptr = p->s.ptr;
 9cc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9d0:	4790                	lw	a2,8(a5)
 9d2:	02061713          	slli	a4,a2,0x20
 9d6:	9301                	srli	a4,a4,0x20
 9d8:	0712                	slli	a4,a4,0x4
 9da:	973e                	add	a4,a4,a5
 9dc:	fae689e3          	beq	a3,a4,98e <free+0x26>
  } else
    p->s.ptr = bp;
 9e0:	e394                	sd	a3,0(a5)
  freep = p;
 9e2:	00000717          	auipc	a4,0x0
 9e6:	12f73f23          	sd	a5,318(a4) # b20 <freep>
}
 9ea:	6422                	ld	s0,8(sp)
 9ec:	0141                	addi	sp,sp,16
 9ee:	8082                	ret

00000000000009f0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f0:	7139                	addi	sp,sp,-64
 9f2:	fc06                	sd	ra,56(sp)
 9f4:	f822                	sd	s0,48(sp)
 9f6:	f426                	sd	s1,40(sp)
 9f8:	f04a                	sd	s2,32(sp)
 9fa:	ec4e                	sd	s3,24(sp)
 9fc:	e852                	sd	s4,16(sp)
 9fe:	e456                	sd	s5,8(sp)
 a00:	e05a                	sd	s6,0(sp)
 a02:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a04:	02051493          	slli	s1,a0,0x20
 a08:	9081                	srli	s1,s1,0x20
 a0a:	04bd                	addi	s1,s1,15
 a0c:	8091                	srli	s1,s1,0x4
 a0e:	0014899b          	addiw	s3,s1,1
 a12:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a14:	00000517          	auipc	a0,0x0
 a18:	10c53503          	ld	a0,268(a0) # b20 <freep>
 a1c:	c515                	beqz	a0,a48 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a1e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a20:	4798                	lw	a4,8(a5)
 a22:	02977f63          	bgeu	a4,s1,a60 <malloc+0x70>
 a26:	8a4e                	mv	s4,s3
 a28:	0009871b          	sext.w	a4,s3
 a2c:	6685                	lui	a3,0x1
 a2e:	00d77363          	bgeu	a4,a3,a34 <malloc+0x44>
 a32:	6a05                	lui	s4,0x1
 a34:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a38:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a3c:	00000917          	auipc	s2,0x0
 a40:	0e490913          	addi	s2,s2,228 # b20 <freep>
  if(p == (char*)-1)
 a44:	5afd                	li	s5,-1
 a46:	a88d                	j	ab8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a48:	00000797          	auipc	a5,0x0
 a4c:	2e078793          	addi	a5,a5,736 # d28 <base>
 a50:	00000717          	auipc	a4,0x0
 a54:	0cf73823          	sd	a5,208(a4) # b20 <freep>
 a58:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a5e:	b7e1                	j	a26 <malloc+0x36>
      if(p->s.size == nunits)
 a60:	02e48b63          	beq	s1,a4,a96 <malloc+0xa6>
        p->s.size -= nunits;
 a64:	4137073b          	subw	a4,a4,s3
 a68:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a6a:	1702                	slli	a4,a4,0x20
 a6c:	9301                	srli	a4,a4,0x20
 a6e:	0712                	slli	a4,a4,0x4
 a70:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a72:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a76:	00000717          	auipc	a4,0x0
 a7a:	0aa73523          	sd	a0,170(a4) # b20 <freep>
      return (void*)(p + 1);
 a7e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a82:	70e2                	ld	ra,56(sp)
 a84:	7442                	ld	s0,48(sp)
 a86:	74a2                	ld	s1,40(sp)
 a88:	7902                	ld	s2,32(sp)
 a8a:	69e2                	ld	s3,24(sp)
 a8c:	6a42                	ld	s4,16(sp)
 a8e:	6aa2                	ld	s5,8(sp)
 a90:	6b02                	ld	s6,0(sp)
 a92:	6121                	addi	sp,sp,64
 a94:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a96:	6398                	ld	a4,0(a5)
 a98:	e118                	sd	a4,0(a0)
 a9a:	bff1                	j	a76 <malloc+0x86>
  hp->s.size = nu;
 a9c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aa0:	0541                	addi	a0,a0,16
 aa2:	00000097          	auipc	ra,0x0
 aa6:	ec6080e7          	jalr	-314(ra) # 968 <free>
  return freep;
 aaa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 aae:	d971                	beqz	a0,a82 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab2:	4798                	lw	a4,8(a5)
 ab4:	fa9776e3          	bgeu	a4,s1,a60 <malloc+0x70>
    if(p == freep)
 ab8:	00093703          	ld	a4,0(s2)
 abc:	853e                	mv	a0,a5
 abe:	fef719e3          	bne	a4,a5,ab0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 ac2:	8552                	mv	a0,s4
 ac4:	00000097          	auipc	ra,0x0
 ac8:	b5e080e7          	jalr	-1186(ra) # 622 <sbrk>
  if(p == (char*)-1)
 acc:	fd5518e3          	bne	a0,s5,a9c <malloc+0xac>
        return 0;
 ad0:	4501                	li	a0,0
 ad2:	bf45                	j	a82 <malloc+0x92>
