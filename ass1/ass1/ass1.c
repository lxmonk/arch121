#include <stdio.h>
#include <stdlib.h>
# define MAX_LEN 100     // Maximal line size


void separateParams(char* str_buf,char* operation,char* operand2){
        char* i=str_buf;
        int j=0;
        while( *i != ' ')
                i++;
        *i=0;
        //printf("%s,%s\n",str_buf,i+1);
        *operation = *(++i);
        i+=2;
        while(*i != '\0')
                operand2[j++]=*(i++);
        operand2[j]=0;
}

extern void calc(char* op1,char* oprnd,char* op2);

int main(void) {
        char str_buf[MAX_LEN];
        char *operation =malloc(1);
        char operand2[MAX_LEN/2];
        int str_len = 0;
        while(1){
                printf(">");
                fgets(str_buf, MAX_LEN, stdin);    /* Get calculation request from user */
                if(str_buf[0]=='q') {
                    exit(0);
                }
                separateParams(str_buf,operation,operand2); /* break into 3 parameters */
                /* printf("op=%s, int(op)=%d", operation, operation); */
                calc(str_buf, operation, operand2);
        }

}
