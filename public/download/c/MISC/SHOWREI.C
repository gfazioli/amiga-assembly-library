/**************************************************************************************
** ShowREI Ver.1.02
** 
** Author: =Jon=
** Date: (21.3.95)
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
#include <clib/icon_protos.h>
#include <clib/asl_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *AslBase, *DosBase, *IconBase;

/********** My C prototypes **********************************************************/
VOID ShowSInfo(struct REI *myrei);
void ChangeFont(struct FontRequester *fontr, struct REI *myrei);
/**************************************************************************************
 * Main 
 **************************************************************************************
*/
VOID main(int argc, char **argv)
{

struct WBStartup *wbs;
struct WBArg *wbarg;

struct Interface *i, *showi;
struct REI *myrei, *thisREI;
struct REIMessage *rmsg;
struct FileRequester *fr;
struct FontRequester *fontr;
ULONG response;
ULONG fine = TRUE;
BPTR lock;

	if (AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM))
	{
		/* Prendo la base della asl.library, che è già aperta dall'assembly.library */
		
		AslBase = AssemblyBase->ab_AslBase;
		IconBase = AssemblyBase->ab_IconBase;
		DosBase = AssemblyBase->ab_DosBase;		/* Prendo anche la dos.library */


		/* Alloco il File Requester utilizzando i nuovi comandi dell'asl.library */ 
		
		fontr = AllocAslRequest(ASL_FontRequest,NULL);
		fr = AllocAslRequestTags(ASL_FileRequest, 
											ASLFR_TitleText, "Show REI...",
											ASLFR_PositiveText, "Show",
											ASLFR_RejectIcons,TRUE,
											TAG_DONE);		
											
		showi = NULL;
		if (argc == 0)
		{
			wbs = (struct WBStartup *)argv;
			wbarg = wbs->sm_ArgList;
			if(wbs->sm_NumArgs == 2)
			{
				CurrentDir(wbarg[1].wa_Lock);
				showi = OpenInterface(wbarg[1].wa_Name);
				CurrentDir(NULL);
			}	
		}
		else
			showi = OpenInterface(argv[1]);

		/* Apro il Requester, mostrandolo all'utente */
		/* Se response è NULL, significa che è stato premuto Cancel */

		if(showi == NULL)
		{			
			response = AslRequest(fr,NULL);
			if(response)			/* se response è TRUE prosegui, altrimenti esci */
			{
				lock = Lock(fr->fr_Drawer,ACCESS_READ);
				CurrentDir(lock);						/* vedi workbench.h */
				showi = OpenInterface(fr->fr_File);
				UnLock(lock);
				CurrentDir(NULL);
			}
		}
		
		if(showi)
		{
			InterfaceInfo(NULL);
			struct MinList *mylist = &(showi->int_MinList);
			thisREI =  mylist->mlh_Head;
				
			myrei = OpenREIA(thisREI,NULL,NULL);	/* Leggi Doc di OpenREIA() */
			
			ShowSInfo(myrei);
			ChangeFont(fontr,myrei);
			
			while(fine)
			{
				rmsg = WaitREIMsg(myrei,0x5f);
		
				switch(rmsg->rim_Class)
				{
					case IDCMP_CLOSEWINDOW:
						fine = FALSE;
						break;
				}
			}			
			CloseREI(myrei,NULL);
			CloseInterface(showi);
		}			
		FreeAslRequest(fr);
		FreeAslRequest(fontr);
		CloseLibrary(AssemblyBase);
	}
}		

VOID ShowSInfo(struct REI *myrei)
{
struct AsmRequest *areq;
long sc, ch, cv, wi;

STRPTR ti;

	long n = GetREIAttrs(myrei,NULL, REIT_Screen, &sc,
							REIT_CenterHScreen,&ch,
							REIT_CenterVScreen,&cv,
							REIT_Window, &wi,
							REIT_WindowTitle, &ti,
							TAG_DONE);

	areq = AllocAsmRequest(AREQ_Title, "Special REI infos",
							   AREQ_CenterHScreen,TRUE,
							   AREQ_CenterVScreen,TRUE,
							   AREQ_NewLookBackFill,TRUE,
							   AREQ_APenPattern,5,
							   AREQ_BPenPattern,5,
							   TAG_DONE);
		
	AsmRequest(areq, "Screen: $%lx\n"
					 "Window Tilte: $%lx\n"
					 "Title: %s\n"
					 "CenterH: %ld\n"
					 "CenterV: %ld\n"
					 "Window: $%lx\n"
					 "\nNum Proc: %ld",
					 "_Exit", sc,ti,ti,ch,cv,wi,n);

	FreeAsmRequest(areq);

}

void ChangeFont(struct FontRequester *fr,struct REI *myrei)
{
	if (AslRequest(fr, NULL))
			SetREIAttrs(myrei,NULL,REIT_WindowTextAttr,&fr->fo_Attr,TAG_DONE);
}

VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
