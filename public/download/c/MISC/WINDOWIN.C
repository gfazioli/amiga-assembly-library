/**************************************************************************************
** WindowInfo Ver.1.0a
** 
** Author: =JON=
** Date: 13-Feb-1995
**
*************************************************************************************** 
*/

#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <libraries/gadtools.h>
#include <graphics/gfx.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/animationclass.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <intuition/imageclass.h>
#include <intuition/intuitionbase.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/assembly_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/graphics_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/utility_protos.h>


/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct IntuitionBase *IntuitionBase;
struct Library *DosBase,*GfxBase,*AslBase,*DataTypesBase;
struct Library *GadToolsBase, *LocaleBase;

/********** My C prototypes **********************************************************/

struct AssemblyBase *OpenLibs(void);
struct List *Update(struct REI *mainrei);
struct Window *GetWindow(struct REI *mainrei,struct REIMessage *rmsg);
void PrintInfo(struct REI *mainrei,struct Window *ewin);
Object *LoadDTObject(STRPTR objname);

/**************************************************************************************
 * Main 
 **************************************************************************************
*/

VOID main()
{
struct Interface *i;
struct REI *mainrei;
struct Window *winrei;
struct REIMessage *rmsg;
struct AsmRequest *areq;
Object *dto;
BOOL fine = TRUE;

	if (AssemblyBase = OpenLibs())
	{
		i = OpenInterface("WindowInfo.rei");
				
		dto = LoadDTObject("Author.animbsh");

		areq = AllocAsmRequest(AREQ_Title, "About...",
							   AREQ_Object,dto,	
							   AREQ_CenterHScreen,TRUE,
							   AREQ_CenterVScreen,TRUE,
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_NewLookBackFill,TRUE,
							   AREQ_APenPattern,5,
							   AREQ_BPenPattern,5,
							   TAG_DONE);
		
		AsmRequestArgs(areq, "WindowInfo Ver.1.0a (13-Feb-1995)\n"
							 "(C)1995 Giovambattista Fazioli\n\n"
							 "La prima 'piccola' prova per l'Assembly.library\n\n"
							 "Thanks to: Marco Talamelli, Giacomo Magnini, ;)",
							 "_Continua", NULL);


		mainrei = OpenREI(NULL, "main",REIT_ScreenFont,TRUE,TAG_END);
		
		struct List *list = Update(mainrei);

		while (fine)
		{
			if(rmsg = WaitREIMsg(mainrei,0x5F))
			{									
				switch(rmsg->rim_Class)
				{
					case IDCMP_CLOSEWINDOW:
						fine = FALSE;
						break;

					case IDCMP_GADGETUP:
						struct Gadget *gad = rmsg->rim_IAddress;
						if(gad->GadgetID == 0x1000)
							list = Update(mainrei);
						if(gad->GadgetID == 0x2000)	
						{
							struct Window *ewin = GetWindow(mainrei,rmsg);
							PrintInfo(mainrei,ewin);
						}	
						if(gad->GadgetID == 0x1002)
							fine = FALSE;
						break;
				}
			}			
		}			
		FreeList(list);
		CloseREI(mainrei,NULL);
		CloseInterface(i);
		DisposeDTObject(dto);
		FreeAsmRequest(areq);
		CloseLibrary(AssemblyBase);
	}
}
/**************************************************************************************
 * GetWindow()
 **************************************************************************************
*/
struct Window *GetWindow(struct REI *mainrei,struct REIMessage *rmsg)
{
	struct Screen *screen = mainrei->rei_Screen;
	struct Window *win = screen->FirstWindow;
	UWORD code = rmsg->rim_Code;
	
	while(code--)
		win = win->NextWindow;
return(win);	
}

/**************************************************************************************
 * Update()
 **************************************************************************************
*/
struct List *Update(struct REI *mainrei)
{
long asmtype;

	struct Window *win = mainrei->rei_Window;
	struct AsmGadget *agad = FindAsmGadget(mainrei,"lv1");
	struct Gadget *gad = agad->agg_Gadget;
	struct List *list=NULL;
	
	GT_GetGadgetAttrs(gad,win,NULL,GTLV_Labels,&list,TAG_DONE);
	if(list)
	{
		GT_SetGadgetAttrs(gad,win,NULL,GTLV_Labels,~0);
		FreeList(list);
	}	
	
	list = AllocNewList();
	struct Screen *screen = mainrei->rei_Screen;
	struct Window *lwin = screen->FirstWindow;
	
	while(lwin)
	{
		asmtype = ASYSI_QUESTION;
		STRPTR title = lwin->Title;
		if(title == NULL)
		{
			asmtype = ASYSI_SYSTEM;
			title = "Untitled";
		}	
		AllocNode(list,title,asmtype,NULL);
		lwin = lwin->NextWindow;
	}
	
	GT_SetGadgetAttrs(gad,win,NULL,GTLV_Labels,list);	
	return(list);
}

/**************************************************************************************
 * PrintInfo()
 **************************************************************************************
*/
void PrintInfo(struct REI *mainrei,struct Window *ewin)
{
	struct Window *win = mainrei->rei_Window;
	struct RastPort *rp = win->RPort; 

	struct AsmGadget *agad = FindAsmGadget(mainrei,"text01");
	struct Gadget *gad = agad->agg_Gadget;
	WORD x = gad->LeftEdge+6;
	WORD y = gad->TopEdge+rp->TxBaseline+6;
	
	SetABPenDrMd(rp,1,0,JAM2);
	TextFmtRastPort(rp, "Left:%-3ld \nTop:%-3ld \nWidth:%-3ld \nHeight:%-3ld \n",x,y,NULL,
								ewin->LeftEdge,ewin->TopEdge,
								ewin->Width,ewin->Height);

}

/**************************************************************************************
 * LoadDTObject(
 **************************************************************************************
*/
Object *LoadDTObject(STRPTR objname)
{
Object *obj;
BPTR lock = NULL;
BPTR oldlock, homedir;


	struct ExecBase *eb = AssemblyBase->ab_ExecBase;
	struct Process *mytask = eb->ThisTask;
	homedir = (struct Process *)mytask->pr_HomeDir;
	oldlock = CurrentDir(homedir);
	
	if(CheckFile(objname,NULL))
	{
		BPTR lock = Lock("sys:Classes/Images/",ACCESS_READ);
		CurrentDir(lock);
	}
	
	if(obj = NewDTObject(objname, DTA_ControlPanel,FALSE,TAG_DONE))
	{
		if(lock)
			UnLock(lock);		
		CurrentDir(oldlock);
		return(obj);
	}	
return(NULL);
}



/**************************************************************************************
 * OpenLibs()
 **************************************************************************************
*/

struct AssemblyBase *OpenLibs()
{
	AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM);
	
	DosBase = AssemblyBase->ab_DosBase;
	IntuitionBase = AssemblyBase->ab_IntuiBase;
	GfxBase = AssemblyBase->ab_GfxBase;
	AslBase = AssemblyBase->ab_AslBase;
	GadToolsBase = AssemblyBase->ab_GadToolsBase;
	LocaleBase = AssemblyBase->ab_LocaleBase;
	DataTypesBase = AssemblyBase->ab_DataTypesBase;
	return(AssemblyBase);
}


VOID wbmain(wbmsg)
{
	main();
	exit(0);
}
