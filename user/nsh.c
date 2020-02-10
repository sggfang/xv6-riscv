#include "kernel/fcntl.h"
#include "kernel/types.h"
#include "user/user.h"
#include "kernel/fcntl.h"

static char *all,*next;
char buff[512];

char* trim(char *s){
	char *temp;
	temp=s;
	while(*temp!='\0'){
		temp++;
	}
	while(*s==' '){
		*s='\0';
		s++;
	}
	while(*(--temp)==' '){
		*temp='\0';
	}
	*(temp+1)='\0';
	return s;
}

void redir(int mod,int p[]){
	close(mod);
	dup(p[mod]);
	close(p[0]);
	close(p[1]);
}

void runcmd(char *cmd){
	char temp[23][23];
	char *pass[23];
	int count=0;

	cmd=trim(cmd);
	for(int i=0;i<23;i++)pass[i]=temp[i];
	char *s=temp[count];
	int ipos=0;
	int opos=0;
	for(char *p=cmd;*p;p++){
		if(*p==' '||*p=='\n'){
			*s='\0';
			count++;
			s=temp[count];
		}else{
			if(*p=='<'){
				ipos=count++;
			}
			if(*p=='>'){
				opos=count++;
			}
			*s++=*p;
		}
	}
	*s='\0';
	count++;
	pass[count]=0;

	if(ipos){
		close(0);
		open(pass[ipos],O_RDONLY);
	}
	if(opos){
		close(1);
		open(pass[opos],O_WRONLY|O_CREATE);
	}

	char *pass2[23];
	int count2=0;
	for(int i=0;i<count;i++){
		if(i==ipos-1)i+=2;
		if(i==opos-1)i+=2;
		pass2[count2++]=pass[i];
	}
	pass2[count2]=0;

	if(fork()){
		wait(0);
	}else{
		exec(pass2[0],pass2);
	}
}

int handlecmd(){
	//fprintf(2,"@ ");
	//memset(buff,0,num);
	//gets(buff,num);
	//if(buff[0]==0){
	//	return -1;
	//}
	//return 0;
	if(all!=0){
		int p[2];
		pipe(p);
		
		if(next)
			redir(1,p);
		runcmd(all);
		close(p[0]);
		close(p[1]);
		wait(0);
	}
	exit(0);
}

char *tok(char *p,char c){
	while(*p!='\0'&&*p!=c){
		p++;
	}
	if(*p=='\0'){
		return 0;   //contain no c
	}
	*p='\0';   //cut rest part of string
	return p+1;
}

int main(int argc,char *argv[]){
	//char *buff;
	//int fd;
	
	while(1){
		fprintf(1,"@ ");
		memset(buff,0,512);
		gets(buff,512);

		if(buff[0]==0){
			fprintf(2,"no command.\n");
			exit(0);
		}
		char *temp=strchr(buff,'\n');
		temp[0]='\0';   //only receive one line
		
		if(fork()){
			wait(0);
		}else{
			all=buff;
			next=tok(all,'|');
			handlecmd();}
	}
	exit(0);

}


