/***************************************************************************
** SetPatch Testing...
**************************************************************************** 
*/
#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <libraries/asl.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/animationclass.h>
#include <datatypes/pictureclass.h>
#include <graphics/gfx.h>
#include <graphics/rastport.h>
#include <graphics/view.h>

#include <dos/dosextens.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <libraries/locale.h>
#include <utility/hooks.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/assembly_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/diskfont_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <clib/locale_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>


#define _LVOEasyRequestArgs	-588

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase, *DiskfontBase;
struct Catalog *catalog;



/********** My C prototypes **********************************************************/
ULONG MyRequest(struct Window *wi, struct EasyStruct *easys, 
										ULONG * idcmp, APTR arglist);
/**************************************************************************************
** Main 
***************************************************************************************
*/
VOID main()
{

APTR	oldfunct;
APTR	newfunct;

	if(!(AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM)))
		return(NULL);
	
	IntuitionBase = AssemblyBase->ab_IntuiBase;		
	
/*	if(!(newfunct = AllocVec(1024,MEMF_FAST|MEMF_CLEAR)))
	{
		CloseLibrary(AssemblyBase);
		return(NULL);
	}
		
	CopyMemQuick(&MyRequest,newfunct,1024); */

	Forbid();
			
/*	oldfunct = SetFunction(IntuitionBase,_LVOEasyRequestArgs,newfunct); */
	oldfunct = SetFunction(IntuitionBase,_LVOEasyRequestArgs,&MyRequest);
	
	Permit();
	
return(NULL);
	
}

ULONG MyRequest(struct Window *wi, struct EasyStruct *easys, ULONG * idcmp, APTR arglist)
{
		
struct AsmRequest *asmreq;

	if(!(AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM)))
		return(NULL);	
	
	asmreq = AllocAsmRequest(AREQ_Title, "About...",
							   AREQ_ReturnKey,TRUE,	
							   AREQ_CenterHScreen,TRUE,
							   AREQ_CenterVScreen,TRUE,
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_NewLookBackFill,TRUE,
							   AREQ_APenPattern,5,
							   AREQ_BPenPattern,5,
							   TAG_DONE);
	
	ULONG res = AsmRequestArgs(asmreq,"HELLO","OK",NULL); 
	
	FreeAsmRequest(asmreq);
	
	CloseLibrary(AssemblyBase);
	
	return(res);
}


/*************************************************************************************/
VOID wbmain(wbmsg)
{
	main();
	exit(0);
}
