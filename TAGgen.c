//IV gen
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

const char pool[] = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789";

int main( int argc, const char *argv[] )
{

	srand(time(NULL));
	int i = 0; //index var for the destination string
	int asciiconvert;
	char dest[256];
	char charsrc;

	for ( i = 0; i < 8; i++ ) // NOTE: Change for 256 bit **key** use 32 "0-31" && for 128 bit **IV** use 16 "0-15"
	{
		asciiconvert = pool[ rand()%strlen(pool) ];
		charsrc = asciiconvert;
		strcpy(&dest[i],&charsrc);
	}

	dest[sizeof(dest)-1] = 0;//deletes the new line at the end of the destination string

	int x, y;
	char hex[256];
	for ( x = 0, y = 0; x < strlen(dest); ++x, y += 2)
	{
		sprintf(hex + y, "%02x", dest[x] & 0xff);
	}


	printf("%s", hex);
//-----------------------------------------------------------------------------------------------------------

	char filename[50];
	char temp;
	int numeq;
	int fnameindex = 0;
	char apender[] = "TAG.txt";

	numeq = argv[1][fnameindex];

	while (numeq != 46)
	{
		temp = numeq;
		strcpy(&filename[fnameindex],&temp);
		fnameindex++;
		numeq = argv[1][fnameindex];
	}

	filename[sizeof(fnameindex)+1] = '\0';
	strcat(filename,apender);

//	printf("\n%s\n",filename);
//	printf("\n%d\n",sizeof(filename));//make sure the var filename does not exceed the limit

	FILE *out_file = fopen(filename,"w");
	fprintf(out_file,"%s",hex);
	fclose(out_file);

return 0;
}
