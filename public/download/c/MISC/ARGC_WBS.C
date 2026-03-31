/**************************************************************************************
** ShowREI Ver.1.0 
** 
** Author: =Jon=
** Date: (6.3.95)
**
*************************************************************************************** 
*/

#include <exec/exec.h>
#include <libraries/asl.h>
#include <assembly/assemblybase.h>
#include <intuition/intuition.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <stdio.h>

#include <clib/assembly_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/utility_protos.h>


/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *AslBase, *DosBase;

/********** My C prototypes **********************************************************/


/**************************************************************************************
 * Main 
 **************************************************************************************
*/
VOID main(int argc, char **argv)
{

struct WBStartup *wbs;
struct WBArg *wbarg;

struct Interface *i;
struct REI *myrei, *thisREI;
struct REIMessage *rmsg;
struct AsmRequest *asmreq;
struct FileRequester *fr;
ULONG response;
ULONG fine = TRUE;
LONG num;
BPTR lock;
SHORT x;

	if (AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM))
	{
	
		/* Prendo la base della asl.library, che è già aperta dall'assembly.library */
		
		AslBase = AssemblyBase->ab_AslBase;
		DosBase = AssemblyBase->ab_DosBase;		/* Prendo anche la dos.library */

		if(argc)
		{
			printf("Programma %s ",argv[0]);
			printf("lanciato da shell ");
			printf("con %d parametri\n",argc - 1);
			for(x=1; x<argc; x++)
			printf("   parm = %s\n",argv[x]);
		}
		
		if (argc == 0)
		{
			wbs = (struct WBStartup *)argv;
			num = wbs->sm_NumArgs;
			wbarg = wbs->sm_ArgList;

			STRPTR strinfo = wbarg[0].wa_Name;
			
			asmreq = AllocAsmRequestA(NULL);
			
			AsmRequest(asmreq,"Num: %ld\n\ninfo: %s \n", NULL, num, strinfo);
			
			FreeAsmRequest(asmreq);			
		}			


		/* Alloco il File Requester utilizzando i nuovi comandi dell'asl.library */ 
		
		fr = AllocAslRequestTags(ASL_FileRequest, 
											ASLFR_TitleText, "Show REI...",
											ASLFR_PositiveText, "Show",
											ASLFR_RejectIcons,TRUE,
											TAG_DONE);		

		/* Apro il Requester, mostrandolo all'utente */
		/* Se response è NULL, significa che è stato premuto Cancel */
		
		response = AslRequest(fr,NULL);
		
		if(response)				/* se response è TRUE prosegui, altrimenti esci */
		{
		
			lock = Lock(fr->fr_Drawer,ACCESS_READ);
			CurrentDir(lock);						/* vedi workbench.h */
			
			i = OpenInterface(fr->fr_File);
			
			struct MinList *mylist = &(i->int_MinList);
			
			thisREI =  mylist->mlh_Head;
			
			UnLock(lock);
			CurrentDir(NULL);
			
			myrei = OpenREIA(thisREI,NULL,NULL);		/* Leggi Doc di OpenREIA() */
			
			while(fine)
			{
				rmsg = WaitREIMsg(myrei,0x5f);
			
				if(rmsg->rim_Class == IDCMP_CLOSEWINDOW)
						fine = FALSE;
			}			

			CloseREI(myrei,NULL);
			CloseInterface(i);
			
			FreeAslRequest(fr);
			CloseLibrary(AssemblyBase);
		}
	}
}		

VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
