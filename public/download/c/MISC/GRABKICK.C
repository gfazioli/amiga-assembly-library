/**************************************************************************************
** GrabKick Ver.2.0 
** 
** Author: =Marco Talamelli=
** Date: (10.Jun.95)
**
*************************************************************************************** 
*/


#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <libraries/asl.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/animationclass.h>
#include <graphics/gfx.h>
#include <dos/dosextens.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <libraries/locale.h>
#include <utility/hooks.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <stdio.h>

#include <clib/assembly_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <clib/locale_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>


/********** Global VAR ***************************************************************/

/********** My C prototypes **********************************************************/
void grab(char *kickfile);

/********** Global settings **********************************************************/
/* =JON=    main(int argc, char *argv[] ) */

VOID main(int argc, char **argv)					/* questo l'ho cambiato */
{

struct WBStartup *wbs;						/* questi l'ho aggiunti */
struct WBArg *wbarg;

	char *msgmarco="\n GrabKick Version 2.0 - (C)1995 Marco Talamelli\n";

	if(argc == 0)
	{
		/* Start from WorkBench */
		printf(msgmarco);
		grab("Kickfile");
		Delay(500L);
	}

	if((argc != 2)&&(argc != 1)||(*argv[1]=='?'))
	{
		printf("\n Copy Kickstart ROM to file.");
		printf(msgmarco);
		printf(" Usage: GrabKick [<destination file name>]\n\n");
	}
	else
		if(argc == 2)
		{
			grab(argv[1]);
		}
		else
			grab("Kickfile");
}

void grab(char *kickfile)
{
	FILE *ausgabe;
	
	long anzahl = 0;
	
	unsigned short *version;
	
	char c, *romptr, *romstart, *romend=(char *)0x00ffffff;

	if(!(ausgabe = fopen(kickfile, "w")))
		{
			printf("cannot open: %s\n",kickfile);
			return;
		}
	romstart= (char *) (romend- *(unsigned long *)(romend - 0x13) +1);
	printf("\nROMstart: %lX\n",romstart);
	printf("ROMend :  %lX\n",romend);

	version=(unsigned short*)(romstart+12);
	printf("Copying Kickstart version %u.%u to file %s\n",*version,*(version+1),kickfile);

	for(romptr= romstart; romptr< (char *)(romend +1); ++romptr)
	{
		c=*romptr;
		if(fputc( c, ausgabe)==EOF)
		{
			printf("\nError while writing.");
			fclose(ausgabe);
			if(remove(kickfile)==0)
				printf(" File %s removed.",kickfile);
			printf("\n\n");
			anzahl=-1;
			break;
		}
		anzahl++;
	}
	if(anzahl>=0L)
	{
		fclose(ausgabe);
		printf("%ld bytes (%ld KB).\n\n", anzahl,anzahl/1024);
	}
}

/* Il Dice almeno in questa versione che Ho io, vuole questa riga quando si consodera il */
/* Parse del CLI o gli INPUTS del Workbench */

VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
