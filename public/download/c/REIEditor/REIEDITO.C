/***************************************************************************
** REI-Editor Ver.0.52
** 
** Author: =Jon=
** Date: (5.5.95)
**
**************************************************************************** 
*/
#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <assembly/asmintuition.h>
#include <libraries/asl.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/animationclass.h>
#include <graphics/gfx.h>
#include <dos/dosextens.h>
#include <dos/doshunks.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <libraries/locale.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <sources:c/REIEditor/REIEditor.h>

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

struct TagItem ScreenTAG[] = { SA_LikeWorkbench,1,
				SA_Title,"REI-Editor Ver.1.0 (5.5.95) ** UNREGISTRATED VERSION **",
				TAG_DONE };

long header[] = {HUNK_HEADER,0,1,0,0,0,HUNK_DATA,0};

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase;
struct Catalog *catalog;
struct REI *mainrei;			/* Front Edit - schermo principale */

/********** My C prototypes **********************************************************/
struct AssemblyBase *OpenLibs();
LONG WriteREIFile(struct Interface *i, STRPTR filename);

/**************************************************************************************
** Main 
***************************************************************************************
*/
VOID main(int argc, char **argv)
{
struct WBStartup *wbs;
struct WBArg *wbarg;

struct Interface *i;
	
	if ( !(AssemblyBase = OpenLibs()) )		/* Apro Libs, se fallisce esco... */
		return(NULL);
		
	if(i = OpenInterface("renamemovie.rei"))
	{	
	
		WriteREIFile(i,"ram:test.rei");
	
		CloseInterface(i);
	}
	CloseCatalog(catalog);
	CloseLibrary(AssemblyBase);
}

/**************************************************************************************
 * WriteREIFile()
 **************************************************************************************
*/
LONG WriteREIFile(struct Interface *i, STRPTR filename)
{
struct MinList *ml = &(i->int_MinList);
struct REI *rei = ml->mlh_Head;
struct REI *lastrei =  ml->mlh_TailPred;

BPTR handle;

#define	MAXRELOC32	200							/* Max rilocazioni possibili, in LONG */
#define RELOC32_SIZEOF	((MAXRELOC32+5)<<2)		/* SIZEOF della struttura in Bytes */

long nreloc32 = 0;				/* numero rilocazioni fatte */
long nlong = 0;					/* numero Long == SIZEOF di quello che scrivo >>2 */	

long nbytes = 0;				/* numero di bytes scritti per ogni Write()... */

long ebytes = 0;				/* end  bytes */


long abytes;					/* numero di bytes di alignamento */

long *reloc32;					/* puntatore all'Hunk Reloc32 allocato da me */
long indice = 3;				/* Partiamo da questo per scrivere nell'Hunl_Reloc32 */
long *align=0;					/* Una LONG a NULL da scrivere tanto è max 4 byte!! */


	reloc32 = AllocVec(RELOC32_SIZEOF,MEMF_PUBLIC|MEMF_CLEAR);	/* alloco spazio */
	
	
	handle = Open(filename,MODE_NEWFILE);
	

	Write(handle,header,8<<2);				/* Scrivo HUNK_HEADER */
		
											/* Struct Interface */
	ebytes = Write(handle,i,sizeof(*i));
	nbytes = nbytes+ebytes;					/* numero totale di bytes scritti */

			
	reloc32[indice] = ebytes;				/* Next address free */	
	indice ++;								/* incremento indice */		

											/* Struct REI */

	ebytes = Write(handle,rei,sizeof(*rei));	/* quindi scrivo la rei */
	nbytes += ebytes;						/* numero totale di bytes scritti */

	reloc32[indice] = ebytes;				/* Next address free */	
	indice ++;								/* incremento indice */




		Seek(handle,reloc32[indice-1]-nbytes,OFFSET_CURRENT); 	/* mi metto sull'offset da modificare */
		Write(handle,&ebytes,4);				/* so di mettere la rei subito dopo */
		Seek(handle,NULL,OFFSET_END);			/* ritorno dove stavo */
		
												/* Struct REI */
/*********************************************************************************************/
/* ora vado a vedere se c'è una -diversa- rei come ultima in lista */
		if ((rei == lastrei)
		{
			reloc32[indice] = OFFSET(MinList,mlh_TailPred);		/* offset */
			indice ++;								/* incremento indice */		
			nreloc32 ++;							/* numero reloc = numero reloc +1 */

			Seek(handle,reloc32[indice-1]-nbytes,OFFSET_CURRENT); 	/* mi metto sull'offset da modificare */
			Write(handle,sizeof(*i),4);				/* so di mettere la rei subito dopo */
			Seek(handle,NULL,OFFSET_END);			/* ritorno dove stavo */
		}
		else
		{
		
		}
		
		
/**********************************************************************************************
** Abbiamo praticamente finito 
**********************************************************************************************/
		abytes = (nbytes+3) & (~3);				/* Aligno a LONG i bytes scritti */
		nlong = abytes>>2;						/* mi calcolo le LONG scritte */
		abytes = abytes-nbytes;					/* Vedo se devo scrivere bytes aggiutivi */
		
		if(abytes)
			Write(handle,align,abytes);

		reloc32[0] = HUNK_RELOC32;
		reloc32[1] = nreloc32;					/* numero rilocazioni da fare */
		reloc32[2] = 0;							/* in questo Hunk */
		reloc32[indice] = 0;					/* NULL c'è sempre */
		reloc32[indice+1] = HUNK_END;			/* Fine */
		
		/* Scrivo l'Hunk_Reloc32 insieme all'Hunk_End */
		Write(handle,reloc32,(5+nreloc32)<<2);
		
		
		/* Scrivo il numero di LONG del SEGMENTO DATA */
		Seek(handle,20,OFFSET_BEGINNING);
		Write(handle,&nlong,4);
		Seek(handle,4,OFFSET_CURRENT);
		Write(handle,&nlong,4);		
		

	Close(handle);
	FreeVec(reloc32);
}

/**************************************************************************************
 * OpenLibs()
 **************************************************************************************
*/
struct AssemblyBase *OpenLibs()
{
	if(AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM))
	{
		DosBase = AssemblyBase->ab_DosBase;
		IconBase = AssemblyBase->ab_IconBase;
		IntuitionBase = AssemblyBase->ab_IntuiBase;
		GfxBase = AssemblyBase->ab_GfxBase;
		AslBase = AssemblyBase->ab_AslBase;
		GadToolsBase = AssemblyBase->ab_GadToolsBase;
		LocaleBase = AssemblyBase->ab_LocaleBase;
		DataTypesBase = AssemblyBase->ab_DataTypesBase;
		WorkbenchBase = AssemblyBase->ab_WorkbenchBase;
		
		catalog = OpenCatalogA(NULL,"REIEditor.catalog",NULL);
	}
	return(AssemblyBase);
}


/*************************************************************************************/
VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
