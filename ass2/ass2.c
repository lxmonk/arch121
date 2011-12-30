#include <stdio.h>
#include <stdlib.h>

extern int mazeSolver(char* maze,int h,int w);

 char *readMaze(FILE *fp,int *rows,int *cols) {
        char *cptr = (char*) calloc(16384,1);
        char *ans = cptr;
        int c;
        int n = 0;
        int firstLine=1;
        *rows=0;
        *cols=0;
        c = getc (fp);
        while( c!= EOF){
                if (c == '0'){
                        *cptr = '0';
                        cptr++;
                        if(firstLine)
                                (*cols)++;
                }else if(c == '1'){
                        *cptr = '1';
                        cptr++;
                        if(firstLine)
                                (*cols)++;
                }else if(c == '\n'){
                        (*rows)++;
                        firstLine=0;
                }
                c=getc(fp);
    }
        return ans;
 }


int main(int argc, char *argv[]){
        if(argc != 2){
                printf("Usage: %s inputFileName \n", argv[0]);
                exit(-1);
        }

        FILE *filePtr;
        int h=0;
        int w=-1;
        //char* maze= (char*) calloc(16384); //128^2==16384
        //char* idx = maze;

        filePtr = fopen(argv[1],"r");

        if (filePtr == NULL){
                printf("error while opening file %s\n",argv[1]);
                exit(-1);
    }

        /*while(fgets(idx,128,filePtr) != NULL){
      if(w==-1)

     printf("\n%s", str);
   }*/
   char *maze= readMaze(filePtr,&h,&w);
   printf("w:%d; h:%d; maze:%s\n",w,h,maze);
   fclose(filePtr);
   printf("%d\n", mazeSolver(maze, h, w));
   printf("w:%d; h:%d; maze:%s\n",w,h,maze);
   return 0;
}
