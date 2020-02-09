
user/_testsh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <rand>:

// return a random integer.
// from Wikipedia, linear congruential generator, glibc's constants.
unsigned int
rand()
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  unsigned int a = 1103515245;
  unsigned int c = 12345;
  unsigned int m = (1 << 31);
  seed = (a * seed + c) % m;
       6:	00002717          	auipc	a4,0x2
       a:	81670713          	addi	a4,a4,-2026 # 181c <seed>
       e:	4308                	lw	a0,0(a4)
      10:	41c657b7          	lui	a5,0x41c65
      14:	e6d7879b          	addiw	a5,a5,-403
      18:	02f5053b          	mulw	a0,a0,a5
      1c:	678d                	lui	a5,0x3
      1e:	0397879b          	addiw	a5,a5,57
      22:	9d3d                	addw	a0,a0,a5
      24:	1506                	slli	a0,a0,0x21
      26:	9105                	srli	a0,a0,0x21
      28:	c308                	sw	a0,0(a4)
  return seed;
}
      2a:	6422                	ld	s0,8(sp)
      2c:	0141                	addi	sp,sp,16
      2e:	8082                	ret

0000000000000030 <randstring>:

// generate a random string of the indicated length.
char *
randstring(char *buf, int n)
{
      30:	7139                	addi	sp,sp,-64
      32:	fc06                	sd	ra,56(sp)
      34:	f822                	sd	s0,48(sp)
      36:	f426                	sd	s1,40(sp)
      38:	f04a                	sd	s2,32(sp)
      3a:	ec4e                	sd	s3,24(sp)
      3c:	e852                	sd	s4,16(sp)
      3e:	e456                	sd	s5,8(sp)
      40:	e05a                	sd	s6,0(sp)
      42:	0080                	addi	s0,sp,64
      44:	8a2a                	mv	s4,a0
      46:	89ae                	mv	s3,a1
  for(int i = 0; i < n-1; i++)
      48:	4785                	li	a5,1
      4a:	02b7df63          	bge	a5,a1,88 <randstring+0x58>
      4e:	84aa                	mv	s1,a0
      50:	00150913          	addi	s2,a0,1
      54:	ffe5879b          	addiw	a5,a1,-2
      58:	1782                	slli	a5,a5,0x20
      5a:	9381                	srli	a5,a5,0x20
      5c:	993e                	add	s2,s2,a5
    buf[i] = "abcdefghijklmnopqrstuvwxyz"[rand() % 26];
      5e:	00001b17          	auipc	s6,0x1
      62:	38ab0b13          	addi	s6,s6,906 # 13e8 <malloc+0xe4>
      66:	4ae9                	li	s5,26
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <rand>
      70:	035577bb          	remuw	a5,a0,s5
      74:	1782                	slli	a5,a5,0x20
      76:	9381                	srli	a5,a5,0x20
      78:	97da                	add	a5,a5,s6
      7a:	0007c783          	lbu	a5,0(a5) # 3000 <__global_pointer$+0xfe7>
      7e:	00f48023          	sb	a5,0(s1)
  for(int i = 0; i < n-1; i++)
      82:	0485                	addi	s1,s1,1
      84:	ff2492e3          	bne	s1,s2,68 <randstring+0x38>
  buf[n-1] = '\0';
      88:	99d2                	add	s3,s3,s4
      8a:	fe098fa3          	sb	zero,-1(s3)
  return buf;
}
      8e:	8552                	mv	a0,s4
      90:	70e2                	ld	ra,56(sp)
      92:	7442                	ld	s0,48(sp)
      94:	74a2                	ld	s1,40(sp)
      96:	7902                	ld	s2,32(sp)
      98:	69e2                	ld	s3,24(sp)
      9a:	6a42                	ld	s4,16(sp)
      9c:	6aa2                	ld	s5,8(sp)
      9e:	6b02                	ld	s6,0(sp)
      a0:	6121                	addi	sp,sp,64
      a2:	8082                	ret

00000000000000a4 <writefile>:

// create a file with the indicated content.
void
writefile(char *name, char *data)
{
      a4:	7179                	addi	sp,sp,-48
      a6:	f406                	sd	ra,40(sp)
      a8:	f022                	sd	s0,32(sp)
      aa:	ec26                	sd	s1,24(sp)
      ac:	e84a                	sd	s2,16(sp)
      ae:	e44e                	sd	s3,8(sp)
      b0:	1800                	addi	s0,sp,48
      b2:	89aa                	mv	s3,a0
      b4:	892e                	mv	s2,a1
  unlink(name); // since no truncation
      b6:	00001097          	auipc	ra,0x1
      ba:	e48080e7          	jalr	-440(ra) # efe <unlink>
  int fd = open(name, O_CREATE|O_WRONLY);
      be:	20100593          	li	a1,513
      c2:	854e                	mv	a0,s3
      c4:	00001097          	auipc	ra,0x1
      c8:	e2a080e7          	jalr	-470(ra) # eee <open>
  if(fd < 0){
      cc:	04054663          	bltz	a0,118 <writefile+0x74>
      d0:	84aa                	mv	s1,a0
    fprintf(2, "testsh: could not write %s\n", name);
    exit(-1);
  }
  if(write(fd, data, strlen(data)) != strlen(data)){
      d2:	854a                	mv	a0,s2
      d4:	00001097          	auipc	ra,0x1
      d8:	c2c080e7          	jalr	-980(ra) # d00 <strlen>
      dc:	0005061b          	sext.w	a2,a0
      e0:	85ca                	mv	a1,s2
      e2:	8526                	mv	a0,s1
      e4:	00001097          	auipc	ra,0x1
      e8:	dea080e7          	jalr	-534(ra) # ece <write>
      ec:	89aa                	mv	s3,a0
      ee:	854a                	mv	a0,s2
      f0:	00001097          	auipc	ra,0x1
      f4:	c10080e7          	jalr	-1008(ra) # d00 <strlen>
      f8:	2501                	sext.w	a0,a0
      fa:	2981                	sext.w	s3,s3
      fc:	02a99d63          	bne	s3,a0,136 <writefile+0x92>
    fprintf(2, "testsh: write failed\n");
    exit(-1);
  }
  close(fd);
     100:	8526                	mv	a0,s1
     102:	00001097          	auipc	ra,0x1
     106:	dd4080e7          	jalr	-556(ra) # ed6 <close>
}
     10a:	70a2                	ld	ra,40(sp)
     10c:	7402                	ld	s0,32(sp)
     10e:	64e2                	ld	s1,24(sp)
     110:	6942                	ld	s2,16(sp)
     112:	69a2                	ld	s3,8(sp)
     114:	6145                	addi	sp,sp,48
     116:	8082                	ret
    fprintf(2, "testsh: could not write %s\n", name);
     118:	864e                	mv	a2,s3
     11a:	00001597          	auipc	a1,0x1
     11e:	2ee58593          	addi	a1,a1,750 # 1408 <malloc+0x104>
     122:	4509                	li	a0,2
     124:	00001097          	auipc	ra,0x1
     128:	0f4080e7          	jalr	244(ra) # 1218 <fprintf>
    exit(-1);
     12c:	557d                	li	a0,-1
     12e:	00001097          	auipc	ra,0x1
     132:	d80080e7          	jalr	-640(ra) # eae <exit>
    fprintf(2, "testsh: write failed\n");
     136:	00001597          	auipc	a1,0x1
     13a:	2f258593          	addi	a1,a1,754 # 1428 <malloc+0x124>
     13e:	4509                	li	a0,2
     140:	00001097          	auipc	ra,0x1
     144:	0d8080e7          	jalr	216(ra) # 1218 <fprintf>
    exit(-1);
     148:	557d                	li	a0,-1
     14a:	00001097          	auipc	ra,0x1
     14e:	d64080e7          	jalr	-668(ra) # eae <exit>

0000000000000152 <readfile>:

// return the content of a file.
void
readfile(char *name, char *data, int max)
{
     152:	7179                	addi	sp,sp,-48
     154:	f406                	sd	ra,40(sp)
     156:	f022                	sd	s0,32(sp)
     158:	ec26                	sd	s1,24(sp)
     15a:	e84a                	sd	s2,16(sp)
     15c:	e44e                	sd	s3,8(sp)
     15e:	e052                	sd	s4,0(sp)
     160:	1800                	addi	s0,sp,48
     162:	8a2a                	mv	s4,a0
     164:	84ae                	mv	s1,a1
     166:	89b2                	mv	s3,a2
  data[0] = '\0';
     168:	00058023          	sb	zero,0(a1)
  int fd = open(name, 0);
     16c:	4581                	li	a1,0
     16e:	00001097          	auipc	ra,0x1
     172:	d80080e7          	jalr	-640(ra) # eee <open>
  if(fd < 0){
     176:	02054d63          	bltz	a0,1b0 <readfile+0x5e>
     17a:	892a                	mv	s2,a0
    fprintf(2, "testsh: open %s failed\n", name);
    return;
  }
  int n = read(fd, data, max-1);
     17c:	fff9861b          	addiw	a2,s3,-1
     180:	85a6                	mv	a1,s1
     182:	00001097          	auipc	ra,0x1
     186:	d44080e7          	jalr	-700(ra) # ec6 <read>
     18a:	89aa                	mv	s3,a0
  close(fd);
     18c:	854a                	mv	a0,s2
     18e:	00001097          	auipc	ra,0x1
     192:	d48080e7          	jalr	-696(ra) # ed6 <close>
  if(n < 0){
     196:	0209c863          	bltz	s3,1c6 <readfile+0x74>
    fprintf(2, "testsh: read %s failed\n", name);
    return;
  }
  data[n] = '\0';
     19a:	94ce                	add	s1,s1,s3
     19c:	00048023          	sb	zero,0(s1)
}
     1a0:	70a2                	ld	ra,40(sp)
     1a2:	7402                	ld	s0,32(sp)
     1a4:	64e2                	ld	s1,24(sp)
     1a6:	6942                	ld	s2,16(sp)
     1a8:	69a2                	ld	s3,8(sp)
     1aa:	6a02                	ld	s4,0(sp)
     1ac:	6145                	addi	sp,sp,48
     1ae:	8082                	ret
    fprintf(2, "testsh: open %s failed\n", name);
     1b0:	8652                	mv	a2,s4
     1b2:	00001597          	auipc	a1,0x1
     1b6:	28e58593          	addi	a1,a1,654 # 1440 <malloc+0x13c>
     1ba:	4509                	li	a0,2
     1bc:	00001097          	auipc	ra,0x1
     1c0:	05c080e7          	jalr	92(ra) # 1218 <fprintf>
    return;
     1c4:	bff1                	j	1a0 <readfile+0x4e>
    fprintf(2, "testsh: read %s failed\n", name);
     1c6:	8652                	mv	a2,s4
     1c8:	00001597          	auipc	a1,0x1
     1cc:	29058593          	addi	a1,a1,656 # 1458 <malloc+0x154>
     1d0:	4509                	li	a0,2
     1d2:	00001097          	auipc	ra,0x1
     1d6:	046080e7          	jalr	70(ra) # 1218 <fprintf>
    return;
     1da:	b7d9                	j	1a0 <readfile+0x4e>

00000000000001dc <strstr>:

// look for the small string in the big string;
// return the address in the big string, or 0.
char *
strstr(char *big, char *small)
{
     1dc:	1141                	addi	sp,sp,-16
     1de:	e422                	sd	s0,8(sp)
     1e0:	0800                	addi	s0,sp,16
  if(small[0] == '\0')
     1e2:	0005c883          	lbu	a7,0(a1)
     1e6:	02088b63          	beqz	a7,21c <strstr+0x40>
    return big;
  for(int i = 0; big[i]; i++){
     1ea:	00054783          	lbu	a5,0(a0)
     1ee:	eb89                	bnez	a5,200 <strstr+0x24>
    }
    if(small[j] == '\0'){
      return big + i;
    }
  }
  return 0;
     1f0:	4501                	li	a0,0
     1f2:	a02d                	j	21c <strstr+0x40>
    if(small[j] == '\0'){
     1f4:	c785                	beqz	a5,21c <strstr+0x40>
  for(int i = 0; big[i]; i++){
     1f6:	00180513          	addi	a0,a6,1
     1fa:	00184783          	lbu	a5,1(a6)
     1fe:	c395                	beqz	a5,222 <strstr+0x46>
    for(j = 0; small[j]; j++){
     200:	882a                	mv	a6,a0
     202:	00158693          	addi	a3,a1,1
{
     206:	872a                	mv	a4,a0
    for(j = 0; small[j]; j++){
     208:	87c6                	mv	a5,a7
      if(big[i+j] != small[j]){
     20a:	00074603          	lbu	a2,0(a4)
     20e:	fef613e3          	bne	a2,a5,1f4 <strstr+0x18>
    for(j = 0; small[j]; j++){
     212:	0006c783          	lbu	a5,0(a3)
     216:	0705                	addi	a4,a4,1
     218:	0685                	addi	a3,a3,1
     21a:	fbe5                	bnez	a5,20a <strstr+0x2e>
}
     21c:	6422                	ld	s0,8(sp)
     21e:	0141                	addi	sp,sp,16
     220:	8082                	ret
  return 0;
     222:	4501                	li	a0,0
     224:	bfe5                	j	21c <strstr+0x40>

0000000000000226 <one>:
// its input, collect the output, check that the
// output includes the expect argument.
// if tight = 1, don't allow much extraneous output.
int
one(char *cmd, char *expect, int tight)
{
     226:	710d                	addi	sp,sp,-352
     228:	ee86                	sd	ra,344(sp)
     22a:	eaa2                	sd	s0,336(sp)
     22c:	e6a6                	sd	s1,328(sp)
     22e:	e2ca                	sd	s2,320(sp)
     230:	fe4e                	sd	s3,312(sp)
     232:	1280                	addi	s0,sp,352
     234:	84aa                	mv	s1,a0
     236:	892e                	mv	s2,a1
     238:	89b2                	mv	s3,a2
  char infile[12], outfile[12];

  randstring(infile, sizeof(infile));
     23a:	45b1                	li	a1,12
     23c:	fc040513          	addi	a0,s0,-64
     240:	00000097          	auipc	ra,0x0
     244:	df0080e7          	jalr	-528(ra) # 30 <randstring>
  randstring(outfile, sizeof(outfile));
     248:	45b1                	li	a1,12
     24a:	fb040513          	addi	a0,s0,-80
     24e:	00000097          	auipc	ra,0x0
     252:	de2080e7          	jalr	-542(ra) # 30 <randstring>

  writefile(infile, cmd);
     256:	85a6                	mv	a1,s1
     258:	fc040513          	addi	a0,s0,-64
     25c:	00000097          	auipc	ra,0x0
     260:	e48080e7          	jalr	-440(ra) # a4 <writefile>
  unlink(outfile);
     264:	fb040513          	addi	a0,s0,-80
     268:	00001097          	auipc	ra,0x1
     26c:	c96080e7          	jalr	-874(ra) # efe <unlink>

  int pid = fork();
     270:	00001097          	auipc	ra,0x1
     274:	c36080e7          	jalr	-970(ra) # ea6 <fork>
  if(pid < 0){
     278:	04054f63          	bltz	a0,2d6 <one+0xb0>
     27c:	84aa                	mv	s1,a0
    fprintf(2, "testsh: fork() failed\n");
    exit(-1);
  }

  if(pid == 0){
     27e:	e571                	bnez	a0,34a <one+0x124>
    close(0);
     280:	4501                	li	a0,0
     282:	00001097          	auipc	ra,0x1
     286:	c54080e7          	jalr	-940(ra) # ed6 <close>
    if(open(infile, 0) != 0){
     28a:	4581                	li	a1,0
     28c:	fc040513          	addi	a0,s0,-64
     290:	00001097          	auipc	ra,0x1
     294:	c5e080e7          	jalr	-930(ra) # eee <open>
     298:	ed29                	bnez	a0,2f2 <one+0xcc>
      fprintf(2, "testsh: child open != 0\n");
      exit(-1);
    }
    close(1);
     29a:	4505                	li	a0,1
     29c:	00001097          	auipc	ra,0x1
     2a0:	c3a080e7          	jalr	-966(ra) # ed6 <close>
    if(open(outfile, O_CREATE|O_WRONLY) != 1){
     2a4:	20100593          	li	a1,513
     2a8:	fb040513          	addi	a0,s0,-80
     2ac:	00001097          	auipc	ra,0x1
     2b0:	c42080e7          	jalr	-958(ra) # eee <open>
     2b4:	4785                	li	a5,1
     2b6:	04f50c63          	beq	a0,a5,30e <one+0xe8>
      fprintf(2, "testsh: child open != 1\n");
     2ba:	00001597          	auipc	a1,0x1
     2be:	1ee58593          	addi	a1,a1,494 # 14a8 <malloc+0x1a4>
     2c2:	4509                	li	a0,2
     2c4:	00001097          	auipc	ra,0x1
     2c8:	f54080e7          	jalr	-172(ra) # 1218 <fprintf>
      exit(-1);
     2cc:	557d                	li	a0,-1
     2ce:	00001097          	auipc	ra,0x1
     2d2:	be0080e7          	jalr	-1056(ra) # eae <exit>
    fprintf(2, "testsh: fork() failed\n");
     2d6:	00001597          	auipc	a1,0x1
     2da:	19a58593          	addi	a1,a1,410 # 1470 <malloc+0x16c>
     2de:	4509                	li	a0,2
     2e0:	00001097          	auipc	ra,0x1
     2e4:	f38080e7          	jalr	-200(ra) # 1218 <fprintf>
    exit(-1);
     2e8:	557d                	li	a0,-1
     2ea:	00001097          	auipc	ra,0x1
     2ee:	bc4080e7          	jalr	-1084(ra) # eae <exit>
      fprintf(2, "testsh: child open != 0\n");
     2f2:	00001597          	auipc	a1,0x1
     2f6:	19658593          	addi	a1,a1,406 # 1488 <malloc+0x184>
     2fa:	4509                	li	a0,2
     2fc:	00001097          	auipc	ra,0x1
     300:	f1c080e7          	jalr	-228(ra) # 1218 <fprintf>
      exit(-1);
     304:	557d                	li	a0,-1
     306:	00001097          	auipc	ra,0x1
     30a:	ba8080e7          	jalr	-1112(ra) # eae <exit>
    }
    char *argv[2];
    argv[0] = shname;
     30e:	00001497          	auipc	s1,0x1
     312:	51248493          	addi	s1,s1,1298 # 1820 <_edata>
     316:	6088                	ld	a0,0(s1)
     318:	eaa43023          	sd	a0,-352(s0)
    argv[1] = 0;
     31c:	ea043423          	sd	zero,-344(s0)
    exec(shname, argv);
     320:	ea040593          	addi	a1,s0,-352
     324:	00001097          	auipc	ra,0x1
     328:	bc2080e7          	jalr	-1086(ra) # ee6 <exec>
    fprintf(2, "testsh: exec %s failed\n", shname);
     32c:	6090                	ld	a2,0(s1)
     32e:	00001597          	auipc	a1,0x1
     332:	19a58593          	addi	a1,a1,410 # 14c8 <malloc+0x1c4>
     336:	4509                	li	a0,2
     338:	00001097          	auipc	ra,0x1
     33c:	ee0080e7          	jalr	-288(ra) # 1218 <fprintf>
    exit(-1);
     340:	557d                	li	a0,-1
     342:	00001097          	auipc	ra,0x1
     346:	b6c080e7          	jalr	-1172(ra) # eae <exit>
  }

  if(wait(0) != pid){
     34a:	4501                	li	a0,0
     34c:	00001097          	auipc	ra,0x1
     350:	b6a080e7          	jalr	-1174(ra) # eb6 <wait>
     354:	04951c63          	bne	a0,s1,3ac <one+0x186>
    fprintf(2, "testsh: unexpected wait() return\n");
    exit(-1);
  }
  unlink(infile);
     358:	fc040513          	addi	a0,s0,-64
     35c:	00001097          	auipc	ra,0x1
     360:	ba2080e7          	jalr	-1118(ra) # efe <unlink>

  char out[256];
  readfile(outfile, out, sizeof(out));
     364:	10000613          	li	a2,256
     368:	eb040593          	addi	a1,s0,-336
     36c:	fb040513          	addi	a0,s0,-80
     370:	00000097          	auipc	ra,0x0
     374:	de2080e7          	jalr	-542(ra) # 152 <readfile>
  unlink(outfile);
     378:	fb040513          	addi	a0,s0,-80
     37c:	00001097          	auipc	ra,0x1
     380:	b82080e7          	jalr	-1150(ra) # efe <unlink>

  if(strstr(out, expect) != 0){
     384:	85ca                	mv	a1,s2
     386:	eb040513          	addi	a0,s0,-336
     38a:	00000097          	auipc	ra,0x0
     38e:	e52080e7          	jalr	-430(ra) # 1dc <strstr>
      fprintf(2, "testsh: saw expected output, but too much else as well\n");
      return 0; // fail
    }
    return 1; // pass
  }
  return 0; // fail
     392:	4781                	li	a5,0
  if(strstr(out, expect) != 0){
     394:	c501                	beqz	a0,39c <one+0x176>
    return 1; // pass
     396:	4785                	li	a5,1
    if(tight && strlen(out) > strlen(expect) + 10){
     398:	02099863          	bnez	s3,3c8 <one+0x1a2>
}
     39c:	853e                	mv	a0,a5
     39e:	60f6                	ld	ra,344(sp)
     3a0:	6456                	ld	s0,336(sp)
     3a2:	64b6                	ld	s1,328(sp)
     3a4:	6916                	ld	s2,320(sp)
     3a6:	79f2                	ld	s3,312(sp)
     3a8:	6135                	addi	sp,sp,352
     3aa:	8082                	ret
    fprintf(2, "testsh: unexpected wait() return\n");
     3ac:	00001597          	auipc	a1,0x1
     3b0:	13458593          	addi	a1,a1,308 # 14e0 <malloc+0x1dc>
     3b4:	4509                	li	a0,2
     3b6:	00001097          	auipc	ra,0x1
     3ba:	e62080e7          	jalr	-414(ra) # 1218 <fprintf>
    exit(-1);
     3be:	557d                	li	a0,-1
     3c0:	00001097          	auipc	ra,0x1
     3c4:	aee080e7          	jalr	-1298(ra) # eae <exit>
    if(tight && strlen(out) > strlen(expect) + 10){
     3c8:	eb040513          	addi	a0,s0,-336
     3cc:	00001097          	auipc	ra,0x1
     3d0:	934080e7          	jalr	-1740(ra) # d00 <strlen>
     3d4:	0005049b          	sext.w	s1,a0
     3d8:	854a                	mv	a0,s2
     3da:	00001097          	auipc	ra,0x1
     3de:	926080e7          	jalr	-1754(ra) # d00 <strlen>
     3e2:	2529                	addiw	a0,a0,10
    return 1; // pass
     3e4:	4785                	li	a5,1
    if(tight && strlen(out) > strlen(expect) + 10){
     3e6:	fa957be3          	bgeu	a0,s1,39c <one+0x176>
      fprintf(2, "testsh: saw expected output, but too much else as well\n");
     3ea:	00001597          	auipc	a1,0x1
     3ee:	11e58593          	addi	a1,a1,286 # 1508 <malloc+0x204>
     3f2:	4509                	li	a0,2
     3f4:	00001097          	auipc	ra,0x1
     3f8:	e24080e7          	jalr	-476(ra) # 1218 <fprintf>
      return 0; // fail
     3fc:	4781                	li	a5,0
     3fe:	bf79                	j	39c <one+0x176>

0000000000000400 <t1>:

// test a command with arguments.
void
t1(int *ok)
{
     400:	1101                	addi	sp,sp,-32
     402:	ec06                	sd	ra,24(sp)
     404:	e822                	sd	s0,16(sp)
     406:	e426                	sd	s1,8(sp)
     408:	1000                	addi	s0,sp,32
     40a:	84aa                	mv	s1,a0
  printf("simple echo: ");
     40c:	00001517          	auipc	a0,0x1
     410:	13450513          	addi	a0,a0,308 # 1540 <malloc+0x23c>
     414:	00001097          	auipc	ra,0x1
     418:	e32080e7          	jalr	-462(ra) # 1246 <printf>
  if(one("echo hello goodbye\n", "hello goodbye", 1) == 0){
     41c:	4605                	li	a2,1
     41e:	00001597          	auipc	a1,0x1
     422:	13258593          	addi	a1,a1,306 # 1550 <malloc+0x24c>
     426:	00001517          	auipc	a0,0x1
     42a:	13a50513          	addi	a0,a0,314 # 1560 <malloc+0x25c>
     42e:	00000097          	auipc	ra,0x0
     432:	df8080e7          	jalr	-520(ra) # 226 <one>
     436:	e105                	bnez	a0,456 <t1+0x56>
    printf("FAIL\n");
     438:	00001517          	auipc	a0,0x1
     43c:	14050513          	addi	a0,a0,320 # 1578 <malloc+0x274>
     440:	00001097          	auipc	ra,0x1
     444:	e06080e7          	jalr	-506(ra) # 1246 <printf>
    *ok = 0;
     448:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     44c:	60e2                	ld	ra,24(sp)
     44e:	6442                	ld	s0,16(sp)
     450:	64a2                	ld	s1,8(sp)
     452:	6105                	addi	sp,sp,32
     454:	8082                	ret
    printf("PASS\n");
     456:	00001517          	auipc	a0,0x1
     45a:	12a50513          	addi	a0,a0,298 # 1580 <malloc+0x27c>
     45e:	00001097          	auipc	ra,0x1
     462:	de8080e7          	jalr	-536(ra) # 1246 <printf>
}
     466:	b7dd                	j	44c <t1+0x4c>

0000000000000468 <t2>:

// test a command with arguments.
void
t2(int *ok)
{
     468:	1101                	addi	sp,sp,-32
     46a:	ec06                	sd	ra,24(sp)
     46c:	e822                	sd	s0,16(sp)
     46e:	e426                	sd	s1,8(sp)
     470:	1000                	addi	s0,sp,32
     472:	84aa                	mv	s1,a0
  printf("simple grep: ");
     474:	00001517          	auipc	a0,0x1
     478:	11450513          	addi	a0,a0,276 # 1588 <malloc+0x284>
     47c:	00001097          	auipc	ra,0x1
     480:	dca080e7          	jalr	-566(ra) # 1246 <printf>
  if(one("grep constitute README\n", "The code in the files that constitute xv6 is", 1) == 0){
     484:	4605                	li	a2,1
     486:	00001597          	auipc	a1,0x1
     48a:	11258593          	addi	a1,a1,274 # 1598 <malloc+0x294>
     48e:	00001517          	auipc	a0,0x1
     492:	13a50513          	addi	a0,a0,314 # 15c8 <malloc+0x2c4>
     496:	00000097          	auipc	ra,0x0
     49a:	d90080e7          	jalr	-624(ra) # 226 <one>
     49e:	e105                	bnez	a0,4be <t2+0x56>
    printf("FAIL\n");
     4a0:	00001517          	auipc	a0,0x1
     4a4:	0d850513          	addi	a0,a0,216 # 1578 <malloc+0x274>
     4a8:	00001097          	auipc	ra,0x1
     4ac:	d9e080e7          	jalr	-610(ra) # 1246 <printf>
    *ok = 0;
     4b0:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     4b4:	60e2                	ld	ra,24(sp)
     4b6:	6442                	ld	s0,16(sp)
     4b8:	64a2                	ld	s1,8(sp)
     4ba:	6105                	addi	sp,sp,32
     4bc:	8082                	ret
    printf("PASS\n");
     4be:	00001517          	auipc	a0,0x1
     4c2:	0c250513          	addi	a0,a0,194 # 1580 <malloc+0x27c>
     4c6:	00001097          	auipc	ra,0x1
     4ca:	d80080e7          	jalr	-640(ra) # 1246 <printf>
}
     4ce:	b7dd                	j	4b4 <t2+0x4c>

00000000000004d0 <t3>:

// test a command, then a newline, then another command.
void
t3(int *ok)
{
     4d0:	1101                	addi	sp,sp,-32
     4d2:	ec06                	sd	ra,24(sp)
     4d4:	e822                	sd	s0,16(sp)
     4d6:	e426                	sd	s1,8(sp)
     4d8:	1000                	addi	s0,sp,32
     4da:	84aa                	mv	s1,a0
  printf("two commands: ");
     4dc:	00001517          	auipc	a0,0x1
     4e0:	10450513          	addi	a0,a0,260 # 15e0 <malloc+0x2dc>
     4e4:	00001097          	auipc	ra,0x1
     4e8:	d62080e7          	jalr	-670(ra) # 1246 <printf>
  if(one("echo x\necho goodbye\n", "goodbye", 1) == 0){
     4ec:	4605                	li	a2,1
     4ee:	00001597          	auipc	a1,0x1
     4f2:	10258593          	addi	a1,a1,258 # 15f0 <malloc+0x2ec>
     4f6:	00001517          	auipc	a0,0x1
     4fa:	10250513          	addi	a0,a0,258 # 15f8 <malloc+0x2f4>
     4fe:	00000097          	auipc	ra,0x0
     502:	d28080e7          	jalr	-728(ra) # 226 <one>
     506:	e105                	bnez	a0,526 <t3+0x56>
    printf("FAIL\n");
     508:	00001517          	auipc	a0,0x1
     50c:	07050513          	addi	a0,a0,112 # 1578 <malloc+0x274>
     510:	00001097          	auipc	ra,0x1
     514:	d36080e7          	jalr	-714(ra) # 1246 <printf>
    *ok = 0;
     518:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }
}
     51c:	60e2                	ld	ra,24(sp)
     51e:	6442                	ld	s0,16(sp)
     520:	64a2                	ld	s1,8(sp)
     522:	6105                	addi	sp,sp,32
     524:	8082                	ret
    printf("PASS\n");
     526:	00001517          	auipc	a0,0x1
     52a:	05a50513          	addi	a0,a0,90 # 1580 <malloc+0x27c>
     52e:	00001097          	auipc	ra,0x1
     532:	d18080e7          	jalr	-744(ra) # 1246 <printf>
}
     536:	b7dd                	j	51c <t3+0x4c>

0000000000000538 <t4>:

// test output redirection: echo xxx > file
void
t4(int *ok)
{
     538:	7131                	addi	sp,sp,-192
     53a:	fd06                	sd	ra,184(sp)
     53c:	f922                	sd	s0,176(sp)
     53e:	f526                	sd	s1,168(sp)
     540:	0180                	addi	s0,sp,192
     542:	84aa                	mv	s1,a0
  printf("output redirection: ");
     544:	00001517          	auipc	a0,0x1
     548:	0cc50513          	addi	a0,a0,204 # 1610 <malloc+0x30c>
     54c:	00001097          	auipc	ra,0x1
     550:	cfa080e7          	jalr	-774(ra) # 1246 <printf>

  char file[16];
  randstring(file, 12);
     554:	45b1                	li	a1,12
     556:	fd040513          	addi	a0,s0,-48
     55a:	00000097          	auipc	ra,0x0
     55e:	ad6080e7          	jalr	-1322(ra) # 30 <randstring>

  char data[16];
  randstring(data, 12);
     562:	45b1                	li	a1,12
     564:	fc040513          	addi	a0,s0,-64
     568:	00000097          	auipc	ra,0x0
     56c:	ac8080e7          	jalr	-1336(ra) # 30 <randstring>

  char cmd[64];
  strcpy(cmd, "echo ");
     570:	00001597          	auipc	a1,0x1
     574:	0b858593          	addi	a1,a1,184 # 1628 <malloc+0x324>
     578:	f8040513          	addi	a0,s0,-128
     57c:	00000097          	auipc	ra,0x0
     580:	73c080e7          	jalr	1852(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), data);
     584:	f8040513          	addi	a0,s0,-128
     588:	00000097          	auipc	ra,0x0
     58c:	778080e7          	jalr	1912(ra) # d00 <strlen>
     590:	1502                	slli	a0,a0,0x20
     592:	9101                	srli	a0,a0,0x20
     594:	fc040593          	addi	a1,s0,-64
     598:	f8040793          	addi	a5,s0,-128
     59c:	953e                	add	a0,a0,a5
     59e:	00000097          	auipc	ra,0x0
     5a2:	71a080e7          	jalr	1818(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), " > ");
     5a6:	f8040513          	addi	a0,s0,-128
     5aa:	00000097          	auipc	ra,0x0
     5ae:	756080e7          	jalr	1878(ra) # d00 <strlen>
     5b2:	1502                	slli	a0,a0,0x20
     5b4:	9101                	srli	a0,a0,0x20
     5b6:	00001597          	auipc	a1,0x1
     5ba:	07a58593          	addi	a1,a1,122 # 1630 <malloc+0x32c>
     5be:	f8040793          	addi	a5,s0,-128
     5c2:	953e                	add	a0,a0,a5
     5c4:	00000097          	auipc	ra,0x0
     5c8:	6f4080e7          	jalr	1780(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), file);
     5cc:	f8040513          	addi	a0,s0,-128
     5d0:	00000097          	auipc	ra,0x0
     5d4:	730080e7          	jalr	1840(ra) # d00 <strlen>
     5d8:	1502                	slli	a0,a0,0x20
     5da:	9101                	srli	a0,a0,0x20
     5dc:	fd040593          	addi	a1,s0,-48
     5e0:	f8040793          	addi	a5,s0,-128
     5e4:	953e                	add	a0,a0,a5
     5e6:	00000097          	auipc	ra,0x0
     5ea:	6d2080e7          	jalr	1746(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), "\n");
     5ee:	f8040513          	addi	a0,s0,-128
     5f2:	00000097          	auipc	ra,0x0
     5f6:	70e080e7          	jalr	1806(ra) # d00 <strlen>
     5fa:	1502                	slli	a0,a0,0x20
     5fc:	9101                	srli	a0,a0,0x20
     5fe:	00001597          	auipc	a1,0x1
     602:	f0258593          	addi	a1,a1,-254 # 1500 <malloc+0x1fc>
     606:	f8040793          	addi	a5,s0,-128
     60a:	953e                	add	a0,a0,a5
     60c:	00000097          	auipc	ra,0x0
     610:	6ac080e7          	jalr	1708(ra) # cb8 <strcpy>

  if(one(cmd, "", 1) == 0){
     614:	4605                	li	a2,1
     616:	00001597          	auipc	a1,0x1
     61a:	e8a58593          	addi	a1,a1,-374 # 14a0 <malloc+0x19c>
     61e:	f8040513          	addi	a0,s0,-128
     622:	00000097          	auipc	ra,0x0
     626:	c04080e7          	jalr	-1020(ra) # 226 <one>
     62a:	e515                	bnez	a0,656 <t4+0x11e>
    printf("FAIL\n");
     62c:	00001517          	auipc	a0,0x1
     630:	f4c50513          	addi	a0,a0,-180 # 1578 <malloc+0x274>
     634:	00001097          	auipc	ra,0x1
     638:	c12080e7          	jalr	-1006(ra) # 1246 <printf>
    *ok = 0;
     63c:	0004a023          	sw	zero,0(s1)
    } else {
      printf("PASS\n");
    }
  }

  unlink(file);
     640:	fd040513          	addi	a0,s0,-48
     644:	00001097          	auipc	ra,0x1
     648:	8ba080e7          	jalr	-1862(ra) # efe <unlink>
}
     64c:	70ea                	ld	ra,184(sp)
     64e:	744a                	ld	s0,176(sp)
     650:	74aa                	ld	s1,168(sp)
     652:	6129                	addi	sp,sp,192
     654:	8082                	ret
    readfile(file, buf, sizeof(buf));
     656:	04000613          	li	a2,64
     65a:	f4040593          	addi	a1,s0,-192
     65e:	fd040513          	addi	a0,s0,-48
     662:	00000097          	auipc	ra,0x0
     666:	af0080e7          	jalr	-1296(ra) # 152 <readfile>
    if(strstr(buf, data) == 0){
     66a:	fc040593          	addi	a1,s0,-64
     66e:	f4040513          	addi	a0,s0,-192
     672:	00000097          	auipc	ra,0x0
     676:	b6a080e7          	jalr	-1174(ra) # 1dc <strstr>
     67a:	c911                	beqz	a0,68e <t4+0x156>
      printf("PASS\n");
     67c:	00001517          	auipc	a0,0x1
     680:	f0450513          	addi	a0,a0,-252 # 1580 <malloc+0x27c>
     684:	00001097          	auipc	ra,0x1
     688:	bc2080e7          	jalr	-1086(ra) # 1246 <printf>
     68c:	bf55                	j	640 <t4+0x108>
      printf("FAIL\n");
     68e:	00001517          	auipc	a0,0x1
     692:	eea50513          	addi	a0,a0,-278 # 1578 <malloc+0x274>
     696:	00001097          	auipc	ra,0x1
     69a:	bb0080e7          	jalr	-1104(ra) # 1246 <printf>
      *ok = 0;
     69e:	0004a023          	sw	zero,0(s1)
     6a2:	bf79                	j	640 <t4+0x108>

00000000000006a4 <t5>:

// test input redirection: cat < file
void
t5(int *ok)
{
     6a4:	7119                	addi	sp,sp,-128
     6a6:	fc86                	sd	ra,120(sp)
     6a8:	f8a2                	sd	s0,112(sp)
     6aa:	f4a6                	sd	s1,104(sp)
     6ac:	0100                	addi	s0,sp,128
     6ae:	84aa                	mv	s1,a0
  printf("input redirection: ");
     6b0:	00001517          	auipc	a0,0x1
     6b4:	f8850513          	addi	a0,a0,-120 # 1638 <malloc+0x334>
     6b8:	00001097          	auipc	ra,0x1
     6bc:	b8e080e7          	jalr	-1138(ra) # 1246 <printf>

  char file[32];
  randstring(file, 12);
     6c0:	45b1                	li	a1,12
     6c2:	fc040513          	addi	a0,s0,-64
     6c6:	00000097          	auipc	ra,0x0
     6ca:	96a080e7          	jalr	-1686(ra) # 30 <randstring>

  char data[32];
  randstring(data, 12);
     6ce:	45b1                	li	a1,12
     6d0:	fa040513          	addi	a0,s0,-96
     6d4:	00000097          	auipc	ra,0x0
     6d8:	95c080e7          	jalr	-1700(ra) # 30 <randstring>
  writefile(file, data);
     6dc:	fa040593          	addi	a1,s0,-96
     6e0:	fc040513          	addi	a0,s0,-64
     6e4:	00000097          	auipc	ra,0x0
     6e8:	9c0080e7          	jalr	-1600(ra) # a4 <writefile>

  char cmd[32];
  strcpy(cmd, "cat < ");
     6ec:	00001597          	auipc	a1,0x1
     6f0:	f6458593          	addi	a1,a1,-156 # 1650 <malloc+0x34c>
     6f4:	f8040513          	addi	a0,s0,-128
     6f8:	00000097          	auipc	ra,0x0
     6fc:	5c0080e7          	jalr	1472(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), file);
     700:	f8040513          	addi	a0,s0,-128
     704:	00000097          	auipc	ra,0x0
     708:	5fc080e7          	jalr	1532(ra) # d00 <strlen>
     70c:	1502                	slli	a0,a0,0x20
     70e:	9101                	srli	a0,a0,0x20
     710:	fc040593          	addi	a1,s0,-64
     714:	f8040793          	addi	a5,s0,-128
     718:	953e                	add	a0,a0,a5
     71a:	00000097          	auipc	ra,0x0
     71e:	59e080e7          	jalr	1438(ra) # cb8 <strcpy>
  strcpy(cmd+strlen(cmd), "\n");
     722:	f8040513          	addi	a0,s0,-128
     726:	00000097          	auipc	ra,0x0
     72a:	5da080e7          	jalr	1498(ra) # d00 <strlen>
     72e:	1502                	slli	a0,a0,0x20
     730:	9101                	srli	a0,a0,0x20
     732:	00001597          	auipc	a1,0x1
     736:	dce58593          	addi	a1,a1,-562 # 1500 <malloc+0x1fc>
     73a:	f8040793          	addi	a5,s0,-128
     73e:	953e                	add	a0,a0,a5
     740:	00000097          	auipc	ra,0x0
     744:	578080e7          	jalr	1400(ra) # cb8 <strcpy>

  if(one(cmd, data, 1) == 0){
     748:	4605                	li	a2,1
     74a:	fa040593          	addi	a1,s0,-96
     74e:	f8040513          	addi	a0,s0,-128
     752:	00000097          	auipc	ra,0x0
     756:	ad4080e7          	jalr	-1324(ra) # 226 <one>
     75a:	e515                	bnez	a0,786 <t5+0xe2>
    printf("FAIL\n");
     75c:	00001517          	auipc	a0,0x1
     760:	e1c50513          	addi	a0,a0,-484 # 1578 <malloc+0x274>
     764:	00001097          	auipc	ra,0x1
     768:	ae2080e7          	jalr	-1310(ra) # 1246 <printf>
    *ok = 0;
     76c:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }

  unlink(file);
     770:	fc040513          	addi	a0,s0,-64
     774:	00000097          	auipc	ra,0x0
     778:	78a080e7          	jalr	1930(ra) # efe <unlink>
}
     77c:	70e6                	ld	ra,120(sp)
     77e:	7446                	ld	s0,112(sp)
     780:	74a6                	ld	s1,104(sp)
     782:	6109                	addi	sp,sp,128
     784:	8082                	ret
    printf("PASS\n");
     786:	00001517          	auipc	a0,0x1
     78a:	dfa50513          	addi	a0,a0,-518 # 1580 <malloc+0x27c>
     78e:	00001097          	auipc	ra,0x1
     792:	ab8080e7          	jalr	-1352(ra) # 1246 <printf>
     796:	bfe9                	j	770 <t5+0xcc>

0000000000000798 <t6>:

// test a command with both input and output redirection.
void
t6(int *ok)
{
     798:	711d                	addi	sp,sp,-96
     79a:	ec86                	sd	ra,88(sp)
     79c:	e8a2                	sd	s0,80(sp)
     79e:	e4a6                	sd	s1,72(sp)
     7a0:	1080                	addi	s0,sp,96
     7a2:	84aa                	mv	s1,a0
  printf("both redirections: ");
     7a4:	00001517          	auipc	a0,0x1
     7a8:	eb450513          	addi	a0,a0,-332 # 1658 <malloc+0x354>
     7ac:	00001097          	auipc	ra,0x1
     7b0:	a9a080e7          	jalr	-1382(ra) # 1246 <printf>
  unlink("testsh.out");
     7b4:	00001517          	auipc	a0,0x1
     7b8:	ebc50513          	addi	a0,a0,-324 # 1670 <malloc+0x36c>
     7bc:	00000097          	auipc	ra,0x0
     7c0:	742080e7          	jalr	1858(ra) # efe <unlink>
  if(one("grep pointers < README > testsh.out\n", "", 1) == 0){
     7c4:	4605                	li	a2,1
     7c6:	00001597          	auipc	a1,0x1
     7ca:	cda58593          	addi	a1,a1,-806 # 14a0 <malloc+0x19c>
     7ce:	00001517          	auipc	a0,0x1
     7d2:	eb250513          	addi	a0,a0,-334 # 1680 <malloc+0x37c>
     7d6:	00000097          	auipc	ra,0x0
     7da:	a50080e7          	jalr	-1456(ra) # 226 <one>
     7de:	e905                	bnez	a0,80e <t6+0x76>
    printf("FAIL\n");
     7e0:	00001517          	auipc	a0,0x1
     7e4:	d9850513          	addi	a0,a0,-616 # 1578 <malloc+0x274>
     7e8:	00001097          	auipc	ra,0x1
     7ec:	a5e080e7          	jalr	-1442(ra) # 1246 <printf>
    *ok = 0;
     7f0:	0004a023          	sw	zero,0(s1)
      *ok = 0;
    } else {
      printf("PASS\n");
    }
  }
  unlink("testsh.out");
     7f4:	00001517          	auipc	a0,0x1
     7f8:	e7c50513          	addi	a0,a0,-388 # 1670 <malloc+0x36c>
     7fc:	00000097          	auipc	ra,0x0
     800:	702080e7          	jalr	1794(ra) # efe <unlink>
}
     804:	60e6                	ld	ra,88(sp)
     806:	6446                	ld	s0,80(sp)
     808:	64a6                	ld	s1,72(sp)
     80a:	6125                	addi	sp,sp,96
     80c:	8082                	ret
    readfile("testsh.out", buf, sizeof(buf));
     80e:	04000613          	li	a2,64
     812:	fa040593          	addi	a1,s0,-96
     816:	00001517          	auipc	a0,0x1
     81a:	e5a50513          	addi	a0,a0,-422 # 1670 <malloc+0x36c>
     81e:	00000097          	auipc	ra,0x0
     822:	934080e7          	jalr	-1740(ra) # 152 <readfile>
    if(strstr(buf, "provides pointers to on-line resources") == 0){
     826:	00001597          	auipc	a1,0x1
     82a:	e8258593          	addi	a1,a1,-382 # 16a8 <malloc+0x3a4>
     82e:	fa040513          	addi	a0,s0,-96
     832:	00000097          	auipc	ra,0x0
     836:	9aa080e7          	jalr	-1622(ra) # 1dc <strstr>
     83a:	c911                	beqz	a0,84e <t6+0xb6>
      printf("PASS\n");
     83c:	00001517          	auipc	a0,0x1
     840:	d4450513          	addi	a0,a0,-700 # 1580 <malloc+0x27c>
     844:	00001097          	auipc	ra,0x1
     848:	a02080e7          	jalr	-1534(ra) # 1246 <printf>
     84c:	b765                	j	7f4 <t6+0x5c>
      printf("FAIL\n");
     84e:	00001517          	auipc	a0,0x1
     852:	d2a50513          	addi	a0,a0,-726 # 1578 <malloc+0x274>
     856:	00001097          	auipc	ra,0x1
     85a:	9f0080e7          	jalr	-1552(ra) # 1246 <printf>
      *ok = 0;
     85e:	0004a023          	sw	zero,0(s1)
     862:	bf49                	j	7f4 <t6+0x5c>

0000000000000864 <t7>:

// test a pipe with cat filename | cat.
void
t7(int *ok)
{
     864:	7135                	addi	sp,sp,-160
     866:	ed06                	sd	ra,152(sp)
     868:	e922                	sd	s0,144(sp)
     86a:	e526                	sd	s1,136(sp)
     86c:	1100                	addi	s0,sp,160
     86e:	84aa                	mv	s1,a0
  printf("simple pipe: ");
     870:	00001517          	auipc	a0,0x1
     874:	e6050513          	addi	a0,a0,-416 # 16d0 <malloc+0x3cc>
     878:	00001097          	auipc	ra,0x1
     87c:	9ce080e7          	jalr	-1586(ra) # 1246 <printf>

  char name[32], data[32];
  randstring(name, 12);
     880:	45b1                	li	a1,12
     882:	fc040513          	addi	a0,s0,-64
     886:	fffff097          	auipc	ra,0xfffff
     88a:	7aa080e7          	jalr	1962(ra) # 30 <randstring>
  randstring(data, 12);
     88e:	45b1                	li	a1,12
     890:	fa040513          	addi	a0,s0,-96
     894:	fffff097          	auipc	ra,0xfffff
     898:	79c080e7          	jalr	1948(ra) # 30 <randstring>
  writefile(name, data);
     89c:	fa040593          	addi	a1,s0,-96
     8a0:	fc040513          	addi	a0,s0,-64
     8a4:	00000097          	auipc	ra,0x0
     8a8:	800080e7          	jalr	-2048(ra) # a4 <writefile>

  char cmd[64];
  strcpy(cmd, "cat ");
     8ac:	00001597          	auipc	a1,0x1
     8b0:	e3458593          	addi	a1,a1,-460 # 16e0 <malloc+0x3dc>
     8b4:	f6040513          	addi	a0,s0,-160
     8b8:	00000097          	auipc	ra,0x0
     8bc:	400080e7          	jalr	1024(ra) # cb8 <strcpy>
  strcpy(cmd + strlen(cmd), name);
     8c0:	f6040513          	addi	a0,s0,-160
     8c4:	00000097          	auipc	ra,0x0
     8c8:	43c080e7          	jalr	1084(ra) # d00 <strlen>
     8cc:	1502                	slli	a0,a0,0x20
     8ce:	9101                	srli	a0,a0,0x20
     8d0:	fc040593          	addi	a1,s0,-64
     8d4:	f6040793          	addi	a5,s0,-160
     8d8:	953e                	add	a0,a0,a5
     8da:	00000097          	auipc	ra,0x0
     8de:	3de080e7          	jalr	990(ra) # cb8 <strcpy>
  strcpy(cmd + strlen(cmd), " | cat\n");
     8e2:	f6040513          	addi	a0,s0,-160
     8e6:	00000097          	auipc	ra,0x0
     8ea:	41a080e7          	jalr	1050(ra) # d00 <strlen>
     8ee:	1502                	slli	a0,a0,0x20
     8f0:	9101                	srli	a0,a0,0x20
     8f2:	00001597          	auipc	a1,0x1
     8f6:	df658593          	addi	a1,a1,-522 # 16e8 <malloc+0x3e4>
     8fa:	f6040793          	addi	a5,s0,-160
     8fe:	953e                	add	a0,a0,a5
     900:	00000097          	auipc	ra,0x0
     904:	3b8080e7          	jalr	952(ra) # cb8 <strcpy>
  
  if(one(cmd, data, 1) == 0){
     908:	4605                	li	a2,1
     90a:	fa040593          	addi	a1,s0,-96
     90e:	f6040513          	addi	a0,s0,-160
     912:	00000097          	auipc	ra,0x0
     916:	914080e7          	jalr	-1772(ra) # 226 <one>
     91a:	e515                	bnez	a0,946 <t7+0xe2>
    printf("FAIL\n");
     91c:	00001517          	auipc	a0,0x1
     920:	c5c50513          	addi	a0,a0,-932 # 1578 <malloc+0x274>
     924:	00001097          	auipc	ra,0x1
     928:	922080e7          	jalr	-1758(ra) # 1246 <printf>
    *ok = 0;
     92c:	0004a023          	sw	zero,0(s1)
  } else {
    printf("PASS\n");
  }

  unlink(name);
     930:	fc040513          	addi	a0,s0,-64
     934:	00000097          	auipc	ra,0x0
     938:	5ca080e7          	jalr	1482(ra) # efe <unlink>
}
     93c:	60ea                	ld	ra,152(sp)
     93e:	644a                	ld	s0,144(sp)
     940:	64aa                	ld	s1,136(sp)
     942:	610d                	addi	sp,sp,160
     944:	8082                	ret
    printf("PASS\n");
     946:	00001517          	auipc	a0,0x1
     94a:	c3a50513          	addi	a0,a0,-966 # 1580 <malloc+0x27c>
     94e:	00001097          	auipc	ra,0x1
     952:	8f8080e7          	jalr	-1800(ra) # 1246 <printf>
     956:	bfe9                	j	930 <t7+0xcc>

0000000000000958 <t8>:

// test a pipeline that has both redirection and a pipe.
void
t8(int *ok)
{
     958:	711d                	addi	sp,sp,-96
     95a:	ec86                	sd	ra,88(sp)
     95c:	e8a2                	sd	s0,80(sp)
     95e:	e4a6                	sd	s1,72(sp)
     960:	1080                	addi	s0,sp,96
     962:	84aa                	mv	s1,a0
  printf("pipe and redirects: ");
     964:	00001517          	auipc	a0,0x1
     968:	d8c50513          	addi	a0,a0,-628 # 16f0 <malloc+0x3ec>
     96c:	00001097          	auipc	ra,0x1
     970:	8da080e7          	jalr	-1830(ra) # 1246 <printf>
  
  if(one("grep suggestions < README | wc > testsh.out\n", "", 1) == 0){
     974:	4605                	li	a2,1
     976:	00001597          	auipc	a1,0x1
     97a:	b2a58593          	addi	a1,a1,-1238 # 14a0 <malloc+0x19c>
     97e:	00001517          	auipc	a0,0x1
     982:	d8a50513          	addi	a0,a0,-630 # 1708 <malloc+0x404>
     986:	00000097          	auipc	ra,0x0
     98a:	8a0080e7          	jalr	-1888(ra) # 226 <one>
     98e:	e905                	bnez	a0,9be <t8+0x66>
    printf("FAIL\n");
     990:	00001517          	auipc	a0,0x1
     994:	be850513          	addi	a0,a0,-1048 # 1578 <malloc+0x274>
     998:	00001097          	auipc	ra,0x1
     99c:	8ae080e7          	jalr	-1874(ra) # 1246 <printf>
    *ok = 0;
     9a0:	0004a023          	sw	zero,0(s1)
    } else {
      printf("PASS\n");
    }
  }

  unlink("testsh.out");
     9a4:	00001517          	auipc	a0,0x1
     9a8:	ccc50513          	addi	a0,a0,-820 # 1670 <malloc+0x36c>
     9ac:	00000097          	auipc	ra,0x0
     9b0:	552080e7          	jalr	1362(ra) # efe <unlink>
}
     9b4:	60e6                	ld	ra,88(sp)
     9b6:	6446                	ld	s0,80(sp)
     9b8:	64a6                	ld	s1,72(sp)
     9ba:	6125                	addi	sp,sp,96
     9bc:	8082                	ret
    readfile("testsh.out", buf, sizeof(buf));
     9be:	04000613          	li	a2,64
     9c2:	fa040593          	addi	a1,s0,-96
     9c6:	00001517          	auipc	a0,0x1
     9ca:	caa50513          	addi	a0,a0,-854 # 1670 <malloc+0x36c>
     9ce:	fffff097          	auipc	ra,0xfffff
     9d2:	784080e7          	jalr	1924(ra) # 152 <readfile>
    if(strstr(buf, "1 11 71") == 0){
     9d6:	00001597          	auipc	a1,0x1
     9da:	d6258593          	addi	a1,a1,-670 # 1738 <malloc+0x434>
     9de:	fa040513          	addi	a0,s0,-96
     9e2:	fffff097          	auipc	ra,0xfffff
     9e6:	7fa080e7          	jalr	2042(ra) # 1dc <strstr>
     9ea:	c911                	beqz	a0,9fe <t8+0xa6>
      printf("PASS\n");
     9ec:	00001517          	auipc	a0,0x1
     9f0:	b9450513          	addi	a0,a0,-1132 # 1580 <malloc+0x27c>
     9f4:	00001097          	auipc	ra,0x1
     9f8:	852080e7          	jalr	-1966(ra) # 1246 <printf>
     9fc:	b765                	j	9a4 <t8+0x4c>
      printf("FAIL\n");
     9fe:	00001517          	auipc	a0,0x1
     a02:	b7a50513          	addi	a0,a0,-1158 # 1578 <malloc+0x274>
     a06:	00001097          	auipc	ra,0x1
     a0a:	840080e7          	jalr	-1984(ra) # 1246 <printf>
      *ok = 0;
     a0e:	0004a023          	sw	zero,0(s1)
     a12:	bf49                	j	9a4 <t8+0x4c>

0000000000000a14 <t9>:

// ask the shell to execute many commands, to check
// if it leaks file descriptors.
void
t9(int *ok)
{
     a14:	7159                	addi	sp,sp,-112
     a16:	f486                	sd	ra,104(sp)
     a18:	f0a2                	sd	s0,96(sp)
     a1a:	eca6                	sd	s1,88(sp)
     a1c:	e8ca                	sd	s2,80(sp)
     a1e:	e4ce                	sd	s3,72(sp)
     a20:	e0d2                	sd	s4,64(sp)
     a22:	fc56                	sd	s5,56(sp)
     a24:	f85a                	sd	s6,48(sp)
     a26:	f45e                	sd	s7,40(sp)
     a28:	1880                	addi	s0,sp,112
     a2a:	8baa                	mv	s7,a0
  printf("lots of commands: ");
     a2c:	00001517          	auipc	a0,0x1
     a30:	d1450513          	addi	a0,a0,-748 # 1740 <malloc+0x43c>
     a34:	00001097          	auipc	ra,0x1
     a38:	812080e7          	jalr	-2030(ra) # 1246 <printf>

  char term[32];
  randstring(term, 12);
     a3c:	45b1                	li	a1,12
     a3e:	f9040513          	addi	a0,s0,-112
     a42:	fffff097          	auipc	ra,0xfffff
     a46:	5ee080e7          	jalr	1518(ra) # 30 <randstring>
  
  char *cmd = malloc(25 * 36 + 100);
     a4a:	3e800513          	li	a0,1000
     a4e:	00001097          	auipc	ra,0x1
     a52:	8b6080e7          	jalr	-1866(ra) # 1304 <malloc>
  if(cmd == 0){
     a56:	14050363          	beqz	a0,b9c <t9+0x188>
     a5a:	84aa                	mv	s1,a0
    fprintf(2, "testsh: malloc failed\n");
    exit(-1);
  }

  cmd[0] = '\0';
     a5c:	00050023          	sb	zero,0(a0)
  for(int i = 0; i < 17+(rand()%6); i++){
     a60:	fffff097          	auipc	ra,0xfffff
     a64:	5a0080e7          	jalr	1440(ra) # 0 <rand>
     a68:	4981                	li	s3,0
    strcpy(cmd + strlen(cmd), "echo x < README > tso\n");
     a6a:	00001b17          	auipc	s6,0x1
     a6e:	d06b0b13          	addi	s6,s6,-762 # 1770 <malloc+0x46c>
    strcpy(cmd + strlen(cmd), "echo x | echo\n");
     a72:	00001a97          	auipc	s5,0x1
     a76:	d16a8a93          	addi	s5,s5,-746 # 1788 <malloc+0x484>
  for(int i = 0; i < 17+(rand()%6); i++){
     a7a:	4a19                	li	s4,6
    strcpy(cmd + strlen(cmd), "echo x < README > tso\n");
     a7c:	8526                	mv	a0,s1
     a7e:	00000097          	auipc	ra,0x0
     a82:	282080e7          	jalr	642(ra) # d00 <strlen>
     a86:	1502                	slli	a0,a0,0x20
     a88:	9101                	srli	a0,a0,0x20
     a8a:	85da                	mv	a1,s6
     a8c:	9526                	add	a0,a0,s1
     a8e:	00000097          	auipc	ra,0x0
     a92:	22a080e7          	jalr	554(ra) # cb8 <strcpy>
    strcpy(cmd + strlen(cmd), "echo x | echo\n");
     a96:	8526                	mv	a0,s1
     a98:	00000097          	auipc	ra,0x0
     a9c:	268080e7          	jalr	616(ra) # d00 <strlen>
     aa0:	1502                	slli	a0,a0,0x20
     aa2:	9101                	srli	a0,a0,0x20
     aa4:	85d6                	mv	a1,s5
     aa6:	9526                	add	a0,a0,s1
     aa8:	00000097          	auipc	ra,0x0
     aac:	210080e7          	jalr	528(ra) # cb8 <strcpy>
  for(int i = 0; i < 17+(rand()%6); i++){
     ab0:	0019891b          	addiw	s2,s3,1
     ab4:	0009099b          	sext.w	s3,s2
     ab8:	fffff097          	auipc	ra,0xfffff
     abc:	548080e7          	jalr	1352(ra) # 0 <rand>
     ac0:	034577bb          	remuw	a5,a0,s4
     ac4:	27c5                	addiw	a5,a5,17
     ac6:	faf9ebe3          	bltu	s3,a5,a7c <t9+0x68>
  }
  strcpy(cmd + strlen(cmd), "echo ");
     aca:	8526                	mv	a0,s1
     acc:	00000097          	auipc	ra,0x0
     ad0:	234080e7          	jalr	564(ra) # d00 <strlen>
     ad4:	1502                	slli	a0,a0,0x20
     ad6:	9101                	srli	a0,a0,0x20
     ad8:	00001597          	auipc	a1,0x1
     adc:	b5058593          	addi	a1,a1,-1200 # 1628 <malloc+0x324>
     ae0:	9526                	add	a0,a0,s1
     ae2:	00000097          	auipc	ra,0x0
     ae6:	1d6080e7          	jalr	470(ra) # cb8 <strcpy>
  strcpy(cmd + strlen(cmd), term);
     aea:	8526                	mv	a0,s1
     aec:	00000097          	auipc	ra,0x0
     af0:	214080e7          	jalr	532(ra) # d00 <strlen>
     af4:	1502                	slli	a0,a0,0x20
     af6:	9101                	srli	a0,a0,0x20
     af8:	f9040593          	addi	a1,s0,-112
     afc:	9526                	add	a0,a0,s1
     afe:	00000097          	auipc	ra,0x0
     b02:	1ba080e7          	jalr	442(ra) # cb8 <strcpy>
  strcpy(cmd + strlen(cmd), " > tso\n");
     b06:	8526                	mv	a0,s1
     b08:	00000097          	auipc	ra,0x0
     b0c:	1f8080e7          	jalr	504(ra) # d00 <strlen>
     b10:	1502                	slli	a0,a0,0x20
     b12:	9101                	srli	a0,a0,0x20
     b14:	00001597          	auipc	a1,0x1
     b18:	c8458593          	addi	a1,a1,-892 # 1798 <malloc+0x494>
     b1c:	9526                	add	a0,a0,s1
     b1e:	00000097          	auipc	ra,0x0
     b22:	19a080e7          	jalr	410(ra) # cb8 <strcpy>
  strcpy(cmd + strlen(cmd), "cat < tso\n");
     b26:	8526                	mv	a0,s1
     b28:	00000097          	auipc	ra,0x0
     b2c:	1d8080e7          	jalr	472(ra) # d00 <strlen>
     b30:	1502                	slli	a0,a0,0x20
     b32:	9101                	srli	a0,a0,0x20
     b34:	00001597          	auipc	a1,0x1
     b38:	c6c58593          	addi	a1,a1,-916 # 17a0 <malloc+0x49c>
     b3c:	9526                	add	a0,a0,s1
     b3e:	00000097          	auipc	ra,0x0
     b42:	17a080e7          	jalr	378(ra) # cb8 <strcpy>

  if(one(cmd, term, 0) == 0){
     b46:	4601                	li	a2,0
     b48:	f9040593          	addi	a1,s0,-112
     b4c:	8526                	mv	a0,s1
     b4e:	fffff097          	auipc	ra,0xfffff
     b52:	6d8080e7          	jalr	1752(ra) # 226 <one>
     b56:	e12d                	bnez	a0,bb8 <t9+0x1a4>
    printf("FAIL\n");
     b58:	00001517          	auipc	a0,0x1
     b5c:	a2050513          	addi	a0,a0,-1504 # 1578 <malloc+0x274>
     b60:	00000097          	auipc	ra,0x0
     b64:	6e6080e7          	jalr	1766(ra) # 1246 <printf>
    *ok = 0;
     b68:	000ba023          	sw	zero,0(s7)
  } else {
    printf("PASS\n");
  }

  unlink("tso");
     b6c:	00001517          	auipc	a0,0x1
     b70:	c4450513          	addi	a0,a0,-956 # 17b0 <malloc+0x4ac>
     b74:	00000097          	auipc	ra,0x0
     b78:	38a080e7          	jalr	906(ra) # efe <unlink>
  free(cmd);
     b7c:	8526                	mv	a0,s1
     b7e:	00000097          	auipc	ra,0x0
     b82:	6fe080e7          	jalr	1790(ra) # 127c <free>
}
     b86:	70a6                	ld	ra,104(sp)
     b88:	7406                	ld	s0,96(sp)
     b8a:	64e6                	ld	s1,88(sp)
     b8c:	6946                	ld	s2,80(sp)
     b8e:	69a6                	ld	s3,72(sp)
     b90:	6a06                	ld	s4,64(sp)
     b92:	7ae2                	ld	s5,56(sp)
     b94:	7b42                	ld	s6,48(sp)
     b96:	7ba2                	ld	s7,40(sp)
     b98:	6165                	addi	sp,sp,112
     b9a:	8082                	ret
    fprintf(2, "testsh: malloc failed\n");
     b9c:	00001597          	auipc	a1,0x1
     ba0:	bbc58593          	addi	a1,a1,-1092 # 1758 <malloc+0x454>
     ba4:	4509                	li	a0,2
     ba6:	00000097          	auipc	ra,0x0
     baa:	672080e7          	jalr	1650(ra) # 1218 <fprintf>
    exit(-1);
     bae:	557d                	li	a0,-1
     bb0:	00000097          	auipc	ra,0x0
     bb4:	2fe080e7          	jalr	766(ra) # eae <exit>
    printf("PASS\n");
     bb8:	00001517          	auipc	a0,0x1
     bbc:	9c850513          	addi	a0,a0,-1592 # 1580 <malloc+0x27c>
     bc0:	00000097          	auipc	ra,0x0
     bc4:	686080e7          	jalr	1670(ra) # 1246 <printf>
     bc8:	b755                	j	b6c <t9+0x158>

0000000000000bca <main>:

int
main(int argc, char *argv[])
{
     bca:	1101                	addi	sp,sp,-32
     bcc:	ec06                	sd	ra,24(sp)
     bce:	e822                	sd	s0,16(sp)
     bd0:	1000                	addi	s0,sp,32
  if(argc != 2){
     bd2:	4789                	li	a5,2
     bd4:	02f50063          	beq	a0,a5,bf4 <main+0x2a>
    fprintf(2, "Usage: testsh nsh\n");
     bd8:	00001597          	auipc	a1,0x1
     bdc:	be058593          	addi	a1,a1,-1056 # 17b8 <malloc+0x4b4>
     be0:	4509                	li	a0,2
     be2:	00000097          	auipc	ra,0x0
     be6:	636080e7          	jalr	1590(ra) # 1218 <fprintf>
    exit(-1);
     bea:	557d                	li	a0,-1
     bec:	00000097          	auipc	ra,0x0
     bf0:	2c2080e7          	jalr	706(ra) # eae <exit>
  }
  shname = argv[1];
     bf4:	659c                	ld	a5,8(a1)
     bf6:	00001717          	auipc	a4,0x1
     bfa:	c2f73523          	sd	a5,-982(a4) # 1820 <_edata>
  
  seed += getpid();
     bfe:	00000097          	auipc	ra,0x0
     c02:	330080e7          	jalr	816(ra) # f2e <getpid>
     c06:	00001717          	auipc	a4,0x1
     c0a:	c1670713          	addi	a4,a4,-1002 # 181c <seed>
     c0e:	431c                	lw	a5,0(a4)
     c10:	9fa9                	addw	a5,a5,a0
     c12:	c31c                	sw	a5,0(a4)

  int ok = 1;
     c14:	4785                	li	a5,1
     c16:	fef42623          	sw	a5,-20(s0)

  t1(&ok);
     c1a:	fec40513          	addi	a0,s0,-20
     c1e:	fffff097          	auipc	ra,0xfffff
     c22:	7e2080e7          	jalr	2018(ra) # 400 <t1>
  t2(&ok);
     c26:	fec40513          	addi	a0,s0,-20
     c2a:	00000097          	auipc	ra,0x0
     c2e:	83e080e7          	jalr	-1986(ra) # 468 <t2>
  t3(&ok);
     c32:	fec40513          	addi	a0,s0,-20
     c36:	00000097          	auipc	ra,0x0
     c3a:	89a080e7          	jalr	-1894(ra) # 4d0 <t3>
  t4(&ok);
     c3e:	fec40513          	addi	a0,s0,-20
     c42:	00000097          	auipc	ra,0x0
     c46:	8f6080e7          	jalr	-1802(ra) # 538 <t4>
  t5(&ok);
     c4a:	fec40513          	addi	a0,s0,-20
     c4e:	00000097          	auipc	ra,0x0
     c52:	a56080e7          	jalr	-1450(ra) # 6a4 <t5>
  t6(&ok);
     c56:	fec40513          	addi	a0,s0,-20
     c5a:	00000097          	auipc	ra,0x0
     c5e:	b3e080e7          	jalr	-1218(ra) # 798 <t6>
  t7(&ok);
     c62:	fec40513          	addi	a0,s0,-20
     c66:	00000097          	auipc	ra,0x0
     c6a:	bfe080e7          	jalr	-1026(ra) # 864 <t7>
  t8(&ok);
     c6e:	fec40513          	addi	a0,s0,-20
     c72:	00000097          	auipc	ra,0x0
     c76:	ce6080e7          	jalr	-794(ra) # 958 <t8>
  t9(&ok);
     c7a:	fec40513          	addi	a0,s0,-20
     c7e:	00000097          	auipc	ra,0x0
     c82:	d96080e7          	jalr	-618(ra) # a14 <t9>

  if(ok){
     c86:	fec42783          	lw	a5,-20(s0)
     c8a:	cf91                	beqz	a5,ca6 <main+0xdc>
    printf("passed all tests\n");
     c8c:	00001517          	auipc	a0,0x1
     c90:	b4450513          	addi	a0,a0,-1212 # 17d0 <malloc+0x4cc>
     c94:	00000097          	auipc	ra,0x0
     c98:	5b2080e7          	jalr	1458(ra) # 1246 <printf>
  } else {
    printf("failed some tests\n");
  }
  
  exit(0);
     c9c:	4501                	li	a0,0
     c9e:	00000097          	auipc	ra,0x0
     ca2:	210080e7          	jalr	528(ra) # eae <exit>
    printf("failed some tests\n");
     ca6:	00001517          	auipc	a0,0x1
     caa:	b4250513          	addi	a0,a0,-1214 # 17e8 <malloc+0x4e4>
     cae:	00000097          	auipc	ra,0x0
     cb2:	598080e7          	jalr	1432(ra) # 1246 <printf>
     cb6:	b7dd                	j	c9c <main+0xd2>

0000000000000cb8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     cb8:	1141                	addi	sp,sp,-16
     cba:	e422                	sd	s0,8(sp)
     cbc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     cbe:	87aa                	mv	a5,a0
     cc0:	0585                	addi	a1,a1,1
     cc2:	0785                	addi	a5,a5,1
     cc4:	fff5c703          	lbu	a4,-1(a1)
     cc8:	fee78fa3          	sb	a4,-1(a5)
     ccc:	fb75                	bnez	a4,cc0 <strcpy+0x8>
    ;
  return os;
}
     cce:	6422                	ld	s0,8(sp)
     cd0:	0141                	addi	sp,sp,16
     cd2:	8082                	ret

0000000000000cd4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     cd4:	1141                	addi	sp,sp,-16
     cd6:	e422                	sd	s0,8(sp)
     cd8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     cda:	00054783          	lbu	a5,0(a0)
     cde:	cb91                	beqz	a5,cf2 <strcmp+0x1e>
     ce0:	0005c703          	lbu	a4,0(a1)
     ce4:	00f71763          	bne	a4,a5,cf2 <strcmp+0x1e>
    p++, q++;
     ce8:	0505                	addi	a0,a0,1
     cea:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     cec:	00054783          	lbu	a5,0(a0)
     cf0:	fbe5                	bnez	a5,ce0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     cf2:	0005c503          	lbu	a0,0(a1)
}
     cf6:	40a7853b          	subw	a0,a5,a0
     cfa:	6422                	ld	s0,8(sp)
     cfc:	0141                	addi	sp,sp,16
     cfe:	8082                	ret

0000000000000d00 <strlen>:

uint
strlen(const char *s)
{
     d00:	1141                	addi	sp,sp,-16
     d02:	e422                	sd	s0,8(sp)
     d04:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     d06:	00054783          	lbu	a5,0(a0)
     d0a:	cf91                	beqz	a5,d26 <strlen+0x26>
     d0c:	0505                	addi	a0,a0,1
     d0e:	87aa                	mv	a5,a0
     d10:	4685                	li	a3,1
     d12:	9e89                	subw	a3,a3,a0
     d14:	00f6853b          	addw	a0,a3,a5
     d18:	0785                	addi	a5,a5,1
     d1a:	fff7c703          	lbu	a4,-1(a5)
     d1e:	fb7d                	bnez	a4,d14 <strlen+0x14>
    ;
  return n;
}
     d20:	6422                	ld	s0,8(sp)
     d22:	0141                	addi	sp,sp,16
     d24:	8082                	ret
  for(n = 0; s[n]; n++)
     d26:	4501                	li	a0,0
     d28:	bfe5                	j	d20 <strlen+0x20>

0000000000000d2a <memset>:

void*
memset(void *dst, int c, uint n)
{
     d2a:	1141                	addi	sp,sp,-16
     d2c:	e422                	sd	s0,8(sp)
     d2e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     d30:	ce09                	beqz	a2,d4a <memset+0x20>
     d32:	87aa                	mv	a5,a0
     d34:	fff6071b          	addiw	a4,a2,-1
     d38:	1702                	slli	a4,a4,0x20
     d3a:	9301                	srli	a4,a4,0x20
     d3c:	0705                	addi	a4,a4,1
     d3e:	972a                	add	a4,a4,a0
    cdst[i] = c;
     d40:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     d44:	0785                	addi	a5,a5,1
     d46:	fee79de3          	bne	a5,a4,d40 <memset+0x16>
  }
  return dst;
}
     d4a:	6422                	ld	s0,8(sp)
     d4c:	0141                	addi	sp,sp,16
     d4e:	8082                	ret

0000000000000d50 <strchr>:

char*
strchr(const char *s, char c)
{
     d50:	1141                	addi	sp,sp,-16
     d52:	e422                	sd	s0,8(sp)
     d54:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d56:	00054783          	lbu	a5,0(a0)
     d5a:	cb99                	beqz	a5,d70 <strchr+0x20>
    if(*s == c)
     d5c:	00f58763          	beq	a1,a5,d6a <strchr+0x1a>
  for(; *s; s++)
     d60:	0505                	addi	a0,a0,1
     d62:	00054783          	lbu	a5,0(a0)
     d66:	fbfd                	bnez	a5,d5c <strchr+0xc>
      return (char*)s;
  return 0;
     d68:	4501                	li	a0,0
}
     d6a:	6422                	ld	s0,8(sp)
     d6c:	0141                	addi	sp,sp,16
     d6e:	8082                	ret
  return 0;
     d70:	4501                	li	a0,0
     d72:	bfe5                	j	d6a <strchr+0x1a>

0000000000000d74 <gets>:

char*
gets(char *buf, int max)
{
     d74:	711d                	addi	sp,sp,-96
     d76:	ec86                	sd	ra,88(sp)
     d78:	e8a2                	sd	s0,80(sp)
     d7a:	e4a6                	sd	s1,72(sp)
     d7c:	e0ca                	sd	s2,64(sp)
     d7e:	fc4e                	sd	s3,56(sp)
     d80:	f852                	sd	s4,48(sp)
     d82:	f456                	sd	s5,40(sp)
     d84:	f05a                	sd	s6,32(sp)
     d86:	ec5e                	sd	s7,24(sp)
     d88:	1080                	addi	s0,sp,96
     d8a:	8baa                	mv	s7,a0
     d8c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d8e:	892a                	mv	s2,a0
     d90:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d92:	4aa9                	li	s5,10
     d94:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d96:	89a6                	mv	s3,s1
     d98:	2485                	addiw	s1,s1,1
     d9a:	0344d863          	bge	s1,s4,dca <gets+0x56>
    cc = read(0, &c, 1);
     d9e:	4605                	li	a2,1
     da0:	faf40593          	addi	a1,s0,-81
     da4:	4501                	li	a0,0
     da6:	00000097          	auipc	ra,0x0
     daa:	120080e7          	jalr	288(ra) # ec6 <read>
    if(cc < 1)
     dae:	00a05e63          	blez	a0,dca <gets+0x56>
    buf[i++] = c;
     db2:	faf44783          	lbu	a5,-81(s0)
     db6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     dba:	01578763          	beq	a5,s5,dc8 <gets+0x54>
     dbe:	0905                	addi	s2,s2,1
     dc0:	fd679be3          	bne	a5,s6,d96 <gets+0x22>
  for(i=0; i+1 < max; ){
     dc4:	89a6                	mv	s3,s1
     dc6:	a011                	j	dca <gets+0x56>
     dc8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     dca:	99de                	add	s3,s3,s7
     dcc:	00098023          	sb	zero,0(s3)
  return buf;
}
     dd0:	855e                	mv	a0,s7
     dd2:	60e6                	ld	ra,88(sp)
     dd4:	6446                	ld	s0,80(sp)
     dd6:	64a6                	ld	s1,72(sp)
     dd8:	6906                	ld	s2,64(sp)
     dda:	79e2                	ld	s3,56(sp)
     ddc:	7a42                	ld	s4,48(sp)
     dde:	7aa2                	ld	s5,40(sp)
     de0:	7b02                	ld	s6,32(sp)
     de2:	6be2                	ld	s7,24(sp)
     de4:	6125                	addi	sp,sp,96
     de6:	8082                	ret

0000000000000de8 <stat>:

int
stat(const char *n, struct stat *st)
{
     de8:	1101                	addi	sp,sp,-32
     dea:	ec06                	sd	ra,24(sp)
     dec:	e822                	sd	s0,16(sp)
     dee:	e426                	sd	s1,8(sp)
     df0:	e04a                	sd	s2,0(sp)
     df2:	1000                	addi	s0,sp,32
     df4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     df6:	4581                	li	a1,0
     df8:	00000097          	auipc	ra,0x0
     dfc:	0f6080e7          	jalr	246(ra) # eee <open>
  if(fd < 0)
     e00:	02054563          	bltz	a0,e2a <stat+0x42>
     e04:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     e06:	85ca                	mv	a1,s2
     e08:	00000097          	auipc	ra,0x0
     e0c:	0fe080e7          	jalr	254(ra) # f06 <fstat>
     e10:	892a                	mv	s2,a0
  close(fd);
     e12:	8526                	mv	a0,s1
     e14:	00000097          	auipc	ra,0x0
     e18:	0c2080e7          	jalr	194(ra) # ed6 <close>
  return r;
}
     e1c:	854a                	mv	a0,s2
     e1e:	60e2                	ld	ra,24(sp)
     e20:	6442                	ld	s0,16(sp)
     e22:	64a2                	ld	s1,8(sp)
     e24:	6902                	ld	s2,0(sp)
     e26:	6105                	addi	sp,sp,32
     e28:	8082                	ret
    return -1;
     e2a:	597d                	li	s2,-1
     e2c:	bfc5                	j	e1c <stat+0x34>

0000000000000e2e <atoi>:

int
atoi(const char *s)
{
     e2e:	1141                	addi	sp,sp,-16
     e30:	e422                	sd	s0,8(sp)
     e32:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     e34:	00054603          	lbu	a2,0(a0)
     e38:	fd06079b          	addiw	a5,a2,-48
     e3c:	0ff7f793          	andi	a5,a5,255
     e40:	4725                	li	a4,9
     e42:	02f76963          	bltu	a4,a5,e74 <atoi+0x46>
     e46:	86aa                	mv	a3,a0
  n = 0;
     e48:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     e4a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     e4c:	0685                	addi	a3,a3,1
     e4e:	0025179b          	slliw	a5,a0,0x2
     e52:	9fa9                	addw	a5,a5,a0
     e54:	0017979b          	slliw	a5,a5,0x1
     e58:	9fb1                	addw	a5,a5,a2
     e5a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e5e:	0006c603          	lbu	a2,0(a3)
     e62:	fd06071b          	addiw	a4,a2,-48
     e66:	0ff77713          	andi	a4,a4,255
     e6a:	fee5f1e3          	bgeu	a1,a4,e4c <atoi+0x1e>
  return n;
}
     e6e:	6422                	ld	s0,8(sp)
     e70:	0141                	addi	sp,sp,16
     e72:	8082                	ret
  n = 0;
     e74:	4501                	li	a0,0
     e76:	bfe5                	j	e6e <atoi+0x40>

0000000000000e78 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e78:	1141                	addi	sp,sp,-16
     e7a:	e422                	sd	s0,8(sp)
     e7c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
     e7e:	02c05163          	blez	a2,ea0 <memmove+0x28>
     e82:	fff6071b          	addiw	a4,a2,-1
     e86:	1702                	slli	a4,a4,0x20
     e88:	9301                	srli	a4,a4,0x20
     e8a:	0705                	addi	a4,a4,1
     e8c:	972a                	add	a4,a4,a0
  dst = vdst;
     e8e:	87aa                	mv	a5,a0
    *dst++ = *src++;
     e90:	0585                	addi	a1,a1,1
     e92:	0785                	addi	a5,a5,1
     e94:	fff5c683          	lbu	a3,-1(a1)
     e98:	fed78fa3          	sb	a3,-1(a5)
  while(n-- > 0)
     e9c:	fee79ae3          	bne	a5,a4,e90 <memmove+0x18>
  return vdst;
}
     ea0:	6422                	ld	s0,8(sp)
     ea2:	0141                	addi	sp,sp,16
     ea4:	8082                	ret

0000000000000ea6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ea6:	4885                	li	a7,1
 ecall
     ea8:	00000073          	ecall
 ret
     eac:	8082                	ret

0000000000000eae <exit>:
.global exit
exit:
 li a7, SYS_exit
     eae:	4889                	li	a7,2
 ecall
     eb0:	00000073          	ecall
 ret
     eb4:	8082                	ret

0000000000000eb6 <wait>:
.global wait
wait:
 li a7, SYS_wait
     eb6:	488d                	li	a7,3
 ecall
     eb8:	00000073          	ecall
 ret
     ebc:	8082                	ret

0000000000000ebe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ebe:	4891                	li	a7,4
 ecall
     ec0:	00000073          	ecall
 ret
     ec4:	8082                	ret

0000000000000ec6 <read>:
.global read
read:
 li a7, SYS_read
     ec6:	4895                	li	a7,5
 ecall
     ec8:	00000073          	ecall
 ret
     ecc:	8082                	ret

0000000000000ece <write>:
.global write
write:
 li a7, SYS_write
     ece:	48c1                	li	a7,16
 ecall
     ed0:	00000073          	ecall
 ret
     ed4:	8082                	ret

0000000000000ed6 <close>:
.global close
close:
 li a7, SYS_close
     ed6:	48d5                	li	a7,21
 ecall
     ed8:	00000073          	ecall
 ret
     edc:	8082                	ret

0000000000000ede <kill>:
.global kill
kill:
 li a7, SYS_kill
     ede:	4899                	li	a7,6
 ecall
     ee0:	00000073          	ecall
 ret
     ee4:	8082                	ret

0000000000000ee6 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ee6:	489d                	li	a7,7
 ecall
     ee8:	00000073          	ecall
 ret
     eec:	8082                	ret

0000000000000eee <open>:
.global open
open:
 li a7, SYS_open
     eee:	48bd                	li	a7,15
 ecall
     ef0:	00000073          	ecall
 ret
     ef4:	8082                	ret

0000000000000ef6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ef6:	48c5                	li	a7,17
 ecall
     ef8:	00000073          	ecall
 ret
     efc:	8082                	ret

0000000000000efe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     efe:	48c9                	li	a7,18
 ecall
     f00:	00000073          	ecall
 ret
     f04:	8082                	ret

0000000000000f06 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f06:	48a1                	li	a7,8
 ecall
     f08:	00000073          	ecall
 ret
     f0c:	8082                	ret

0000000000000f0e <link>:
.global link
link:
 li a7, SYS_link
     f0e:	48cd                	li	a7,19
 ecall
     f10:	00000073          	ecall
 ret
     f14:	8082                	ret

0000000000000f16 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f16:	48d1                	li	a7,20
 ecall
     f18:	00000073          	ecall
 ret
     f1c:	8082                	ret

0000000000000f1e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f1e:	48a5                	li	a7,9
 ecall
     f20:	00000073          	ecall
 ret
     f24:	8082                	ret

0000000000000f26 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f26:	48a9                	li	a7,10
 ecall
     f28:	00000073          	ecall
 ret
     f2c:	8082                	ret

0000000000000f2e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f2e:	48ad                	li	a7,11
 ecall
     f30:	00000073          	ecall
 ret
     f34:	8082                	ret

0000000000000f36 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f36:	48b1                	li	a7,12
 ecall
     f38:	00000073          	ecall
 ret
     f3c:	8082                	ret

0000000000000f3e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f3e:	48b5                	li	a7,13
 ecall
     f40:	00000073          	ecall
 ret
     f44:	8082                	ret

0000000000000f46 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f46:	48b9                	li	a7,14
 ecall
     f48:	00000073          	ecall
 ret
     f4c:	8082                	ret

0000000000000f4e <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
     f4e:	48d9                	li	a7,22
 ecall
     f50:	00000073          	ecall
 ret
     f54:	8082                	ret

0000000000000f56 <crash>:
.global crash
crash:
 li a7, SYS_crash
     f56:	48dd                	li	a7,23
 ecall
     f58:	00000073          	ecall
 ret
     f5c:	8082                	ret

0000000000000f5e <mount>:
.global mount
mount:
 li a7, SYS_mount
     f5e:	48e1                	li	a7,24
 ecall
     f60:	00000073          	ecall
 ret
     f64:	8082                	ret

0000000000000f66 <umount>:
.global umount
umount:
 li a7, SYS_umount
     f66:	48e5                	li	a7,25
 ecall
     f68:	00000073          	ecall
 ret
     f6c:	8082                	ret

0000000000000f6e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f6e:	1101                	addi	sp,sp,-32
     f70:	ec06                	sd	ra,24(sp)
     f72:	e822                	sd	s0,16(sp)
     f74:	1000                	addi	s0,sp,32
     f76:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f7a:	4605                	li	a2,1
     f7c:	fef40593          	addi	a1,s0,-17
     f80:	00000097          	auipc	ra,0x0
     f84:	f4e080e7          	jalr	-178(ra) # ece <write>
}
     f88:	60e2                	ld	ra,24(sp)
     f8a:	6442                	ld	s0,16(sp)
     f8c:	6105                	addi	sp,sp,32
     f8e:	8082                	ret

0000000000000f90 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f90:	7139                	addi	sp,sp,-64
     f92:	fc06                	sd	ra,56(sp)
     f94:	f822                	sd	s0,48(sp)
     f96:	f426                	sd	s1,40(sp)
     f98:	f04a                	sd	s2,32(sp)
     f9a:	ec4e                	sd	s3,24(sp)
     f9c:	0080                	addi	s0,sp,64
     f9e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fa0:	c299                	beqz	a3,fa6 <printint+0x16>
     fa2:	0805c863          	bltz	a1,1032 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fa6:	2581                	sext.w	a1,a1
  neg = 0;
     fa8:	4881                	li	a7,0
     faa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fb0:	2601                	sext.w	a2,a2
     fb2:	00001517          	auipc	a0,0x1
     fb6:	85650513          	addi	a0,a0,-1962 # 1808 <digits>
     fba:	883a                	mv	a6,a4
     fbc:	2705                	addiw	a4,a4,1
     fbe:	02c5f7bb          	remuw	a5,a1,a2
     fc2:	1782                	slli	a5,a5,0x20
     fc4:	9381                	srli	a5,a5,0x20
     fc6:	97aa                	add	a5,a5,a0
     fc8:	0007c783          	lbu	a5,0(a5)
     fcc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fd0:	0005879b          	sext.w	a5,a1
     fd4:	02c5d5bb          	divuw	a1,a1,a2
     fd8:	0685                	addi	a3,a3,1
     fda:	fec7f0e3          	bgeu	a5,a2,fba <printint+0x2a>
  if(neg)
     fde:	00088b63          	beqz	a7,ff4 <printint+0x64>
    buf[i++] = '-';
     fe2:	fd040793          	addi	a5,s0,-48
     fe6:	973e                	add	a4,a4,a5
     fe8:	02d00793          	li	a5,45
     fec:	fef70823          	sb	a5,-16(a4)
     ff0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff4:	02e05863          	blez	a4,1024 <printint+0x94>
     ff8:	fc040793          	addi	a5,s0,-64
     ffc:	00e78933          	add	s2,a5,a4
    1000:	fff78993          	addi	s3,a5,-1
    1004:	99ba                	add	s3,s3,a4
    1006:	377d                	addiw	a4,a4,-1
    1008:	1702                	slli	a4,a4,0x20
    100a:	9301                	srli	a4,a4,0x20
    100c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1010:	fff94583          	lbu	a1,-1(s2)
    1014:	8526                	mv	a0,s1
    1016:	00000097          	auipc	ra,0x0
    101a:	f58080e7          	jalr	-168(ra) # f6e <putc>
  while(--i >= 0)
    101e:	197d                	addi	s2,s2,-1
    1020:	ff3918e3          	bne	s2,s3,1010 <printint+0x80>
}
    1024:	70e2                	ld	ra,56(sp)
    1026:	7442                	ld	s0,48(sp)
    1028:	74a2                	ld	s1,40(sp)
    102a:	7902                	ld	s2,32(sp)
    102c:	69e2                	ld	s3,24(sp)
    102e:	6121                	addi	sp,sp,64
    1030:	8082                	ret
    x = -xx;
    1032:	40b005bb          	negw	a1,a1
    neg = 1;
    1036:	4885                	li	a7,1
    x = -xx;
    1038:	bf8d                	j	faa <printint+0x1a>

000000000000103a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    103a:	7119                	addi	sp,sp,-128
    103c:	fc86                	sd	ra,120(sp)
    103e:	f8a2                	sd	s0,112(sp)
    1040:	f4a6                	sd	s1,104(sp)
    1042:	f0ca                	sd	s2,96(sp)
    1044:	ecce                	sd	s3,88(sp)
    1046:	e8d2                	sd	s4,80(sp)
    1048:	e4d6                	sd	s5,72(sp)
    104a:	e0da                	sd	s6,64(sp)
    104c:	fc5e                	sd	s7,56(sp)
    104e:	f862                	sd	s8,48(sp)
    1050:	f466                	sd	s9,40(sp)
    1052:	f06a                	sd	s10,32(sp)
    1054:	ec6e                	sd	s11,24(sp)
    1056:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1058:	0005c903          	lbu	s2,0(a1)
    105c:	18090f63          	beqz	s2,11fa <vprintf+0x1c0>
    1060:	8aaa                	mv	s5,a0
    1062:	8b32                	mv	s6,a2
    1064:	00158493          	addi	s1,a1,1
  state = 0;
    1068:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    106a:	02500a13          	li	s4,37
      if(c == 'd'){
    106e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1072:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1076:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    107a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    107e:	00000b97          	auipc	s7,0x0
    1082:	78ab8b93          	addi	s7,s7,1930 # 1808 <digits>
    1086:	a839                	j	10a4 <vprintf+0x6a>
        putc(fd, c);
    1088:	85ca                	mv	a1,s2
    108a:	8556                	mv	a0,s5
    108c:	00000097          	auipc	ra,0x0
    1090:	ee2080e7          	jalr	-286(ra) # f6e <putc>
    1094:	a019                	j	109a <vprintf+0x60>
    } else if(state == '%'){
    1096:	01498f63          	beq	s3,s4,10b4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    109a:	0485                	addi	s1,s1,1
    109c:	fff4c903          	lbu	s2,-1(s1)
    10a0:	14090d63          	beqz	s2,11fa <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10a8:	fe0997e3          	bnez	s3,1096 <vprintf+0x5c>
      if(c == '%'){
    10ac:	fd479ee3          	bne	a5,s4,1088 <vprintf+0x4e>
        state = '%';
    10b0:	89be                	mv	s3,a5
    10b2:	b7e5                	j	109a <vprintf+0x60>
      if(c == 'd'){
    10b4:	05878063          	beq	a5,s8,10f4 <vprintf+0xba>
      } else if(c == 'l') {
    10b8:	05978c63          	beq	a5,s9,1110 <vprintf+0xd6>
      } else if(c == 'x') {
    10bc:	07a78863          	beq	a5,s10,112c <vprintf+0xf2>
      } else if(c == 'p') {
    10c0:	09b78463          	beq	a5,s11,1148 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10c4:	07300713          	li	a4,115
    10c8:	0ce78663          	beq	a5,a4,1194 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10cc:	06300713          	li	a4,99
    10d0:	0ee78e63          	beq	a5,a4,11cc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10d4:	11478863          	beq	a5,s4,11e4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10d8:	85d2                	mv	a1,s4
    10da:	8556                	mv	a0,s5
    10dc:	00000097          	auipc	ra,0x0
    10e0:	e92080e7          	jalr	-366(ra) # f6e <putc>
        putc(fd, c);
    10e4:	85ca                	mv	a1,s2
    10e6:	8556                	mv	a0,s5
    10e8:	00000097          	auipc	ra,0x0
    10ec:	e86080e7          	jalr	-378(ra) # f6e <putc>
      }
      state = 0;
    10f0:	4981                	li	s3,0
    10f2:	b765                	j	109a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10f4:	008b0913          	addi	s2,s6,8
    10f8:	4685                	li	a3,1
    10fa:	4629                	li	a2,10
    10fc:	000b2583          	lw	a1,0(s6)
    1100:	8556                	mv	a0,s5
    1102:	00000097          	auipc	ra,0x0
    1106:	e8e080e7          	jalr	-370(ra) # f90 <printint>
    110a:	8b4a                	mv	s6,s2
      state = 0;
    110c:	4981                	li	s3,0
    110e:	b771                	j	109a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1110:	008b0913          	addi	s2,s6,8
    1114:	4681                	li	a3,0
    1116:	4629                	li	a2,10
    1118:	000b2583          	lw	a1,0(s6)
    111c:	8556                	mv	a0,s5
    111e:	00000097          	auipc	ra,0x0
    1122:	e72080e7          	jalr	-398(ra) # f90 <printint>
    1126:	8b4a                	mv	s6,s2
      state = 0;
    1128:	4981                	li	s3,0
    112a:	bf85                	j	109a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    112c:	008b0913          	addi	s2,s6,8
    1130:	4681                	li	a3,0
    1132:	4641                	li	a2,16
    1134:	000b2583          	lw	a1,0(s6)
    1138:	8556                	mv	a0,s5
    113a:	00000097          	auipc	ra,0x0
    113e:	e56080e7          	jalr	-426(ra) # f90 <printint>
    1142:	8b4a                	mv	s6,s2
      state = 0;
    1144:	4981                	li	s3,0
    1146:	bf91                	j	109a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1148:	008b0793          	addi	a5,s6,8
    114c:	f8f43423          	sd	a5,-120(s0)
    1150:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1154:	03000593          	li	a1,48
    1158:	8556                	mv	a0,s5
    115a:	00000097          	auipc	ra,0x0
    115e:	e14080e7          	jalr	-492(ra) # f6e <putc>
  putc(fd, 'x');
    1162:	85ea                	mv	a1,s10
    1164:	8556                	mv	a0,s5
    1166:	00000097          	auipc	ra,0x0
    116a:	e08080e7          	jalr	-504(ra) # f6e <putc>
    116e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1170:	03c9d793          	srli	a5,s3,0x3c
    1174:	97de                	add	a5,a5,s7
    1176:	0007c583          	lbu	a1,0(a5)
    117a:	8556                	mv	a0,s5
    117c:	00000097          	auipc	ra,0x0
    1180:	df2080e7          	jalr	-526(ra) # f6e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1184:	0992                	slli	s3,s3,0x4
    1186:	397d                	addiw	s2,s2,-1
    1188:	fe0914e3          	bnez	s2,1170 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    118c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1190:	4981                	li	s3,0
    1192:	b721                	j	109a <vprintf+0x60>
        s = va_arg(ap, char*);
    1194:	008b0993          	addi	s3,s6,8
    1198:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    119c:	02090163          	beqz	s2,11be <vprintf+0x184>
        while(*s != 0){
    11a0:	00094583          	lbu	a1,0(s2)
    11a4:	c9a1                	beqz	a1,11f4 <vprintf+0x1ba>
          putc(fd, *s);
    11a6:	8556                	mv	a0,s5
    11a8:	00000097          	auipc	ra,0x0
    11ac:	dc6080e7          	jalr	-570(ra) # f6e <putc>
          s++;
    11b0:	0905                	addi	s2,s2,1
        while(*s != 0){
    11b2:	00094583          	lbu	a1,0(s2)
    11b6:	f9e5                	bnez	a1,11a6 <vprintf+0x16c>
        s = va_arg(ap, char*);
    11b8:	8b4e                	mv	s6,s3
      state = 0;
    11ba:	4981                	li	s3,0
    11bc:	bdf9                	j	109a <vprintf+0x60>
          s = "(null)";
    11be:	00000917          	auipc	s2,0x0
    11c2:	64290913          	addi	s2,s2,1602 # 1800 <malloc+0x4fc>
        while(*s != 0){
    11c6:	02800593          	li	a1,40
    11ca:	bff1                	j	11a6 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11cc:	008b0913          	addi	s2,s6,8
    11d0:	000b4583          	lbu	a1,0(s6)
    11d4:	8556                	mv	a0,s5
    11d6:	00000097          	auipc	ra,0x0
    11da:	d98080e7          	jalr	-616(ra) # f6e <putc>
    11de:	8b4a                	mv	s6,s2
      state = 0;
    11e0:	4981                	li	s3,0
    11e2:	bd65                	j	109a <vprintf+0x60>
        putc(fd, c);
    11e4:	85d2                	mv	a1,s4
    11e6:	8556                	mv	a0,s5
    11e8:	00000097          	auipc	ra,0x0
    11ec:	d86080e7          	jalr	-634(ra) # f6e <putc>
      state = 0;
    11f0:	4981                	li	s3,0
    11f2:	b565                	j	109a <vprintf+0x60>
        s = va_arg(ap, char*);
    11f4:	8b4e                	mv	s6,s3
      state = 0;
    11f6:	4981                	li	s3,0
    11f8:	b54d                	j	109a <vprintf+0x60>
    }
  }
}
    11fa:	70e6                	ld	ra,120(sp)
    11fc:	7446                	ld	s0,112(sp)
    11fe:	74a6                	ld	s1,104(sp)
    1200:	7906                	ld	s2,96(sp)
    1202:	69e6                	ld	s3,88(sp)
    1204:	6a46                	ld	s4,80(sp)
    1206:	6aa6                	ld	s5,72(sp)
    1208:	6b06                	ld	s6,64(sp)
    120a:	7be2                	ld	s7,56(sp)
    120c:	7c42                	ld	s8,48(sp)
    120e:	7ca2                	ld	s9,40(sp)
    1210:	7d02                	ld	s10,32(sp)
    1212:	6de2                	ld	s11,24(sp)
    1214:	6109                	addi	sp,sp,128
    1216:	8082                	ret

0000000000001218 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1218:	715d                	addi	sp,sp,-80
    121a:	ec06                	sd	ra,24(sp)
    121c:	e822                	sd	s0,16(sp)
    121e:	1000                	addi	s0,sp,32
    1220:	e010                	sd	a2,0(s0)
    1222:	e414                	sd	a3,8(s0)
    1224:	e818                	sd	a4,16(s0)
    1226:	ec1c                	sd	a5,24(s0)
    1228:	03043023          	sd	a6,32(s0)
    122c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1230:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1234:	8622                	mv	a2,s0
    1236:	00000097          	auipc	ra,0x0
    123a:	e04080e7          	jalr	-508(ra) # 103a <vprintf>
}
    123e:	60e2                	ld	ra,24(sp)
    1240:	6442                	ld	s0,16(sp)
    1242:	6161                	addi	sp,sp,80
    1244:	8082                	ret

0000000000001246 <printf>:

void
printf(const char *fmt, ...)
{
    1246:	711d                	addi	sp,sp,-96
    1248:	ec06                	sd	ra,24(sp)
    124a:	e822                	sd	s0,16(sp)
    124c:	1000                	addi	s0,sp,32
    124e:	e40c                	sd	a1,8(s0)
    1250:	e810                	sd	a2,16(s0)
    1252:	ec14                	sd	a3,24(s0)
    1254:	f018                	sd	a4,32(s0)
    1256:	f41c                	sd	a5,40(s0)
    1258:	03043823          	sd	a6,48(s0)
    125c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1260:	00840613          	addi	a2,s0,8
    1264:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1268:	85aa                	mv	a1,a0
    126a:	4505                	li	a0,1
    126c:	00000097          	auipc	ra,0x0
    1270:	dce080e7          	jalr	-562(ra) # 103a <vprintf>
}
    1274:	60e2                	ld	ra,24(sp)
    1276:	6442                	ld	s0,16(sp)
    1278:	6125                	addi	sp,sp,96
    127a:	8082                	ret

000000000000127c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    127c:	1141                	addi	sp,sp,-16
    127e:	e422                	sd	s0,8(sp)
    1280:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1282:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1286:	00000797          	auipc	a5,0x0
    128a:	5a27b783          	ld	a5,1442(a5) # 1828 <freep>
    128e:	a805                	j	12be <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1290:	4618                	lw	a4,8(a2)
    1292:	9db9                	addw	a1,a1,a4
    1294:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1298:	6398                	ld	a4,0(a5)
    129a:	6318                	ld	a4,0(a4)
    129c:	fee53823          	sd	a4,-16(a0)
    12a0:	a091                	j	12e4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12a2:	ff852703          	lw	a4,-8(a0)
    12a6:	9e39                	addw	a2,a2,a4
    12a8:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12aa:	ff053703          	ld	a4,-16(a0)
    12ae:	e398                	sd	a4,0(a5)
    12b0:	a099                	j	12f6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b2:	6398                	ld	a4,0(a5)
    12b4:	00e7e463          	bltu	a5,a4,12bc <free+0x40>
    12b8:	00e6ea63          	bltu	a3,a4,12cc <free+0x50>
{
    12bc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12be:	fed7fae3          	bgeu	a5,a3,12b2 <free+0x36>
    12c2:	6398                	ld	a4,0(a5)
    12c4:	00e6e463          	bltu	a3,a4,12cc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12c8:	fee7eae3          	bltu	a5,a4,12bc <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12cc:	ff852583          	lw	a1,-8(a0)
    12d0:	6390                	ld	a2,0(a5)
    12d2:	02059713          	slli	a4,a1,0x20
    12d6:	9301                	srli	a4,a4,0x20
    12d8:	0712                	slli	a4,a4,0x4
    12da:	9736                	add	a4,a4,a3
    12dc:	fae60ae3          	beq	a2,a4,1290 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12e0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12e4:	4790                	lw	a2,8(a5)
    12e6:	02061713          	slli	a4,a2,0x20
    12ea:	9301                	srli	a4,a4,0x20
    12ec:	0712                	slli	a4,a4,0x4
    12ee:	973e                	add	a4,a4,a5
    12f0:	fae689e3          	beq	a3,a4,12a2 <free+0x26>
  } else
    p->s.ptr = bp;
    12f4:	e394                	sd	a3,0(a5)
  freep = p;
    12f6:	00000717          	auipc	a4,0x0
    12fa:	52f73923          	sd	a5,1330(a4) # 1828 <freep>
}
    12fe:	6422                	ld	s0,8(sp)
    1300:	0141                	addi	sp,sp,16
    1302:	8082                	ret

0000000000001304 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1304:	7139                	addi	sp,sp,-64
    1306:	fc06                	sd	ra,56(sp)
    1308:	f822                	sd	s0,48(sp)
    130a:	f426                	sd	s1,40(sp)
    130c:	f04a                	sd	s2,32(sp)
    130e:	ec4e                	sd	s3,24(sp)
    1310:	e852                	sd	s4,16(sp)
    1312:	e456                	sd	s5,8(sp)
    1314:	e05a                	sd	s6,0(sp)
    1316:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1318:	02051493          	slli	s1,a0,0x20
    131c:	9081                	srli	s1,s1,0x20
    131e:	04bd                	addi	s1,s1,15
    1320:	8091                	srli	s1,s1,0x4
    1322:	0014899b          	addiw	s3,s1,1
    1326:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1328:	00000517          	auipc	a0,0x0
    132c:	50053503          	ld	a0,1280(a0) # 1828 <freep>
    1330:	c515                	beqz	a0,135c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1332:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1334:	4798                	lw	a4,8(a5)
    1336:	02977f63          	bgeu	a4,s1,1374 <malloc+0x70>
    133a:	8a4e                	mv	s4,s3
    133c:	0009871b          	sext.w	a4,s3
    1340:	6685                	lui	a3,0x1
    1342:	00d77363          	bgeu	a4,a3,1348 <malloc+0x44>
    1346:	6a05                	lui	s4,0x1
    1348:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    134c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1350:	00000917          	auipc	s2,0x0
    1354:	4d890913          	addi	s2,s2,1240 # 1828 <freep>
  if(p == (char*)-1)
    1358:	5afd                	li	s5,-1
    135a:	a88d                	j	13cc <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    135c:	00000797          	auipc	a5,0x0
    1360:	4d478793          	addi	a5,a5,1236 # 1830 <base>
    1364:	00000717          	auipc	a4,0x0
    1368:	4cf73223          	sd	a5,1220(a4) # 1828 <freep>
    136c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    136e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1372:	b7e1                	j	133a <malloc+0x36>
      if(p->s.size == nunits)
    1374:	02e48b63          	beq	s1,a4,13aa <malloc+0xa6>
        p->s.size -= nunits;
    1378:	4137073b          	subw	a4,a4,s3
    137c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    137e:	1702                	slli	a4,a4,0x20
    1380:	9301                	srli	a4,a4,0x20
    1382:	0712                	slli	a4,a4,0x4
    1384:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1386:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    138a:	00000717          	auipc	a4,0x0
    138e:	48a73f23          	sd	a0,1182(a4) # 1828 <freep>
      return (void*)(p + 1);
    1392:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1396:	70e2                	ld	ra,56(sp)
    1398:	7442                	ld	s0,48(sp)
    139a:	74a2                	ld	s1,40(sp)
    139c:	7902                	ld	s2,32(sp)
    139e:	69e2                	ld	s3,24(sp)
    13a0:	6a42                	ld	s4,16(sp)
    13a2:	6aa2                	ld	s5,8(sp)
    13a4:	6b02                	ld	s6,0(sp)
    13a6:	6121                	addi	sp,sp,64
    13a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13aa:	6398                	ld	a4,0(a5)
    13ac:	e118                	sd	a4,0(a0)
    13ae:	bff1                	j	138a <malloc+0x86>
  hp->s.size = nu;
    13b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13b4:	0541                	addi	a0,a0,16
    13b6:	00000097          	auipc	ra,0x0
    13ba:	ec6080e7          	jalr	-314(ra) # 127c <free>
  return freep;
    13be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13c2:	d971                	beqz	a0,1396 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13c6:	4798                	lw	a4,8(a5)
    13c8:	fa9776e3          	bgeu	a4,s1,1374 <malloc+0x70>
    if(p == freep)
    13cc:	00093703          	ld	a4,0(s2)
    13d0:	853e                	mv	a0,a5
    13d2:	fef719e3          	bne	a4,a5,13c4 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13d6:	8552                	mv	a0,s4
    13d8:	00000097          	auipc	ra,0x0
    13dc:	b5e080e7          	jalr	-1186(ra) # f36 <sbrk>
  if(p == (char*)-1)
    13e0:	fd5518e3          	bne	a0,s5,13b0 <malloc+0xac>
        return 0;
    13e4:	4501                	li	a0,0
    13e6:	bf45                	j	1396 <malloc+0x92>
