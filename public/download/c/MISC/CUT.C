#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <intuition/intuition.h>
#include <libraries/popper.h>

#include <proto/graphics.h>
#include <proto/dos.h>
#include <proto/layers.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/console.h>
#include <proto/popper.h>

#include <pragmas/dos_pragmas.h>
#include <pragmas/layers_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/exec_pragmas.h>
#include <pragmas/console_pragmas.h>

#define MakeID(a,b,c,d) ((ULONG)(a)<<24L|(ULONG)(b)<<16L|(c)<<8|(d))

ULONG *GetFile (char *Name);
void main (UWORD argc,char **argv);
void GetImage (ULONG *Buffer, struct Image *Image);
VOID Err (char *string);
extern struct Library *DOSBase;

void main (UWORD argc,char **argv)
{
	struct Image Image;
	ULONG *Buffer;
	struct Library *PopperBase;
	UWORD i;

	if (argc < 2 || argv[1][0] == '?')
	{
		Err ("Usage: CutImage [A ASAImage] [AL ASALowRes] [M MenuImage] [ML MenuLowRes]\nExample: CutImage M s:NewMenu.brush ML s:LowMenu.brush\n");
		exit (5);
	}

	if ( !(PopperBase = OpenLibrary ("popper.library", 2L)))
	{
		Err ("The popper.library is not installed !\n");
		exit (10);
	}

	i = 1;

	while (i < argc - 1)
	{
		Buffer = GetFile (argv[i+1]);
		if (Buffer)
		{
			GetImage (Buffer, &Image);
			if (Image.Width && Image.Height && Image.ImageData)
			{
				if ( stricmp (argv[i], "A") == 0)
				{
					SetASAImage (&Image, NULL);
				}
				else if ( stricmp (argv[i], "AL") == 0)
				{
					SetASAImage (NULL, &Image);
				}
				else if ( stricmp (argv[i], "M") == 0)
				{
					SetMenuImage (&Image, NULL);
				}
				else if ( stricmp (argv[i], "ML") == 0)
				{
					SetMenuImage (NULL, &Image);
				}
				else
				{
					Err ("The options ");
					Err (argv[i]);
					Err (argv[i+1]);
					Err (" are ignored.\n");
				}
			}

			FreeMem (Buffer, Buffer[0]);
		}
		else
		{
			Err ("The file ");
			Err (argv[i+1]);
			Err (" cannot be opened.\n");
		}

		i += 2;
	}

	CloseLibrary (PopperBase);
	exit (0);
}


void GetImage (ULONG *Buffer, struct Image *Image)
{
	UWORD *Temp;
	ULONG i;

	if ( *(Buffer + 1) == MakeID ('F','O','R','M') )
	{
		Image->ImageData = NULL;
		Image->Width = 0;
		if ( *(Buffer + 3) == MakeID ('I','L','B','M') )
		{
			Temp = (UWORD *)Buffer + 8;
			i = Buffer[0];
			while (i)
			{
				if (*(ULONG *)Temp == MakeID ('B','M','H','D') )
				{
					Image->Width = *(Temp + 4);
					Image->Height = *(Temp + 5);
					Image->LeftEdge = 0;
					Image->TopEdge = 0;
					Image->Depth = 1;
					Image->PlanePick = 1;
					Image->PlaneOnOff = 0;
					Image->NextImage = NULL;
				}
				if (*(ULONG *)Temp == MakeID ('B','O','D','Y') )
				{
					Image->ImageData = Temp + 4;
				}
				i -= 2;
				Temp++;
			}
		}
	}
}


ULONG *GetFile (char *Name)
{
	BPTR File;
	ULONG *Buffer, Len;
	File = Open (Name, MODE_OLDFILE);
	if (File)
	{
		Seek (File, 0, OFFSET_END);
		Len = Seek (File, 0, OFFSET_BEGINNING);
		Buffer = AllocMem (Len+4, 0L);
		if (Buffer)
		{
			Buffer[0] = Len+4;
			Read (File, Buffer+1, Len);
		}
		Close (File);
	}
	else
	{
		Buffer = NULL;
	}
	return Buffer;
}


VOID Err (char *string)
{
	BPTR out = Output();
	if (out)
		Write (out, string, strlen (string));
}
