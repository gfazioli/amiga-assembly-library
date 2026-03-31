/***************************************************************************
**
**************************************************************************** 
*/
#include <exec/exec.h>
#include <graphics/gfx.h>
#include <graphics/view.h>
#include <dos/dosextens.h>
#include <dos/doshunks.h>
#include <intuition/classusr.h>
#include <intuition/screens.h>
#include <intuition/icclass.h>
#include <libraries/locale.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/datatypes_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <clib/locale_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>


/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase, *DiskfontBase;
struct Catalog *catalog;

/********** My C prototypes **********************************************************/
struct AssemblyBase *OpenLibs(void);

/**************************************************************************************
** Main 
***************************************************************************************
*/
VOID main(int argc, char **argv)
{

struct WBStartup *wbs;
struct WBArg *wbarg;


	if (AssemblyBase = OpenLibs())
	{

	
	
	
	CloseLibrary(AssemblyBase);
	}
}



/**************************************************************************************
 * OpenLibs()
 **************************************************************************************
*/
struct AssemblyBase *OpenLibs()
{
	AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM);
	
	DosBase = AssemblyBase->ab_DosBase;
	IconBase = AssemblyBase->ab_IconBase;
	IntuitionBase = AssemblyBase->ab_IntuiBase;
	GfxBase = AssemblyBase->ab_GfxBase;
	AslBase = AssemblyBase->ab_AslBase;
	GadToolsBase = AssemblyBase->ab_GadToolsBase;
	LocaleBase = AssemblyBase->ab_LocaleBase;
	DataTypesBase = AssemblyBase->ab_DataTypesBase;
	WorkbenchBase = AssemblyBase->ab_WorkbenchBase;
	
	DiskfontBase = OpenLibrary("diskfont.library",NULL);
	
	catalog = OpenCatalogA(NULL,"UpDateResident.catalog",NULL);
	
	return(AssemblyBase);
}


/*************************************************************************************/

VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
