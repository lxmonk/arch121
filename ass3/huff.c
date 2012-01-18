#include <stdio.h>
#include <stdlib.h>


int freq_tab[27]={/*a=*/816,/*b=*/149,278,425,1270,222,201,609,696,
                                /*j=*/15,77,402,240,674,750,192,9,598,632,
                                /*t=*/905,275,97,236,15,197,/*z=*/7,/*space=*/1000};

extern void generateHuffmanCode(int letter_frequency[], char letter_codes[]);
extern void encode(char *text, unsigned char letter_codes[], unsigned char* encoded_text);
extern void decode(char *encoded_text, char letter_codes[], char* text);

void read(char* fileName,char *data){
        FILE *filePtr;
        filePtr = fopen(fileName,"r");

        if (filePtr == NULL){
                printf("error while opening file %s\n",fileName);
                exit(-1);
    }
        fgets(data,2048,filePtr);
        fclose(filePtr);
}

void write(char* data, char* fileName){
        FILE *filePtr;
        filePtr = fopen(fileName,"w");

        if (filePtr == NULL){
                printf("error while opening file %s\n",fileName);
                exit(-1);
    }
        fputs(data,filePtr);
        fclose(filePtr);
}

int main(int argc, char *argv[]){
        if(argc != 4){
                printf("Usage: %s encode/decode fileIn fileOut \n", argv[0]);
                exit(-1);
        }
        unsigned char letter_codes[27];
        generateHuffmanCode(freq_tab,letter_codes);	//your method
        if( *argv[1] == 'e'){ //assume "encode"
                //open fileIn and read into text:
                char text[2048];
                read(argv[2],text);

                unsigned char encoded_text[1024];
                //printf("read: %s\n",text);
                encode(text, letter_codes, encoded_text);

                //open fileOut and write encoded_text into it
                write(encoded_text,argv[3]);

        }else if( *argv[1] == 'd'){ //assume "decode"
                //open fileIn and read into encoded_text:
                unsigned char encoded_text[1024];
                read(argv[2],encoded_text);

                char text[2048];
                //printf("read: %s\n",encoded_text);
                decode(encoded_text, letter_codes, text);

                //open fileOut and write text into it
                write(text,argv[3]);
        }
}
