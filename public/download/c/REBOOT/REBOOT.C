/***************************************************************************
**
** Reboot.c -- $VER.1.21
**
**************************************************************************** 
*/
#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <libraries/commodities.h>
#include <libraries/asl.h>
#include <libraries/locale.h>
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
#include <clib/commodities_protos.h>
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

/*********************************************************************************/

#define MSG_BODY_REBOOT	1
#define MSG_GADS		100

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase, *ExecBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase;
struct Library *CxBase, *DiskfontBase;
struct Catalog *catalog;

/********** My C prototypes **********************************************************/
struct AssemblyBase *OpenLibs(void);

/********** My C prototypes **********************************************************/
Object *LoadNewDTObjectA(STRPTR filename, struct TagItem *);
Object *LoadNewDTObject(STRPTR filename, Tag, ...);

void GetDefToolsTypes(int argc, char **argv,STRPTR , STRPTR, STRPTR );

/**************************************************************************************
** Main 
***************************************************************************************
*/

VOID main(int argc, char **argv)
{

struct WBStartup	*wbs;
struct WBArg		*wbarg;

struct	AsmRequest	*areq;
Object	*myimg_stop, *mysound;
ULONG	response;

char	iname[80], sname[80], appmenuname[30];
ULONG	retkey=TRUE;
ULONG	underobj=FALSE;
char 	YesNo[20];

struct	MsgPort     *myport=NULL;
struct	AppMenuItem *appitem=NULL;
struct	AppMessage  *appmsg=NULL;

	if (AssemblyBase = OpenLibs())
	{
		
		GetDefToolsTypes(argc, argv,"IMAGE","Warning.bsh",iname);
		
		GetDefToolsTypes(argc, argv,"APPMENUNAME","Reboot V1.21",appmenuname);
		
		GetDefToolsTypes(argc, argv,"SOUND","",sname);
	
		GetDefToolsTypes(argc, argv,"RETURNKEY","YES",YesNo);
		if(!StrnCmp(AssemblyBase->ab_Locale,YesNo,"NO",-1,SC_ASCII))
			retkey = FALSE;
		
		GetDefToolsTypes(argc, argv,"TEXTUNDEROBJ","NO",YesNo);
		if(!StrnCmp(AssemblyBase->ab_Locale,YesNo,"YES",-1,SC_ASCII))
			underobj = TRUE;			
	
		myimg_stop = LoadNewDTObject(iname,DTA_ControlPanel,FALSE,
											PDTA_Remap,FALSE,
											PDTA_NumColors,16,
											TAG_DONE);
											
		mysound = LoadNewDTObject(sname,TAG_DONE);

		areq = AllocAsmRequest(AREQ_Title, "Reboot...",
						   AREQ_Object,myimg_stop,
						   AREQ_Sound,mysound,
						   AREQ_ReturnKey,retkey,	
						   AREQ_CenterHScreen,TRUE,
						   AREQ_CenterVScreen,TRUE,
						   AREQ_Justification, ASJ_CENTER,
						   AREQ_TextUnderObject,underobj,
						   TAG_DONE);
		
	myport = CreateMsgPort();
	
	appitem=AddAppMenuItemA(0L,0L,appmenuname,myport,NULL);

	while(appitem && myport)
	{
		WaitPort(myport);
      	while((appmsg=(struct AppMessage *)GetMsg(myport)) && areq )
        {
			response = AsmRequestArgs(areq, GetCatalogStr(catalog, MSG_BODY_REBOOT,
							 "Do you really want Reboot System?"),
       	                  GetCatalogStr(catalog, MSG_GADS, "_Reboot|_Quit|_Cancel"),NULL);
	
			switch (response)
			{
				case 1:
					if( (ExecBase->lib_Version) >=39 )
					{	
						Delay(10);
						Disable();
						ColdReboot();
					}	
					break;
				
				case 2:
					ReplyMsg((struct Message *)appmsg);
				
					RemoveAppMenuItem(appitem);
					
					while(appmsg=(struct AppMessage *)GetMsg(myport))
    	  				ReplyMsg((struct Message *)appmsg);
			    
				    DeleteMsgPort(myport);
					FreeAsmRequest(areq);
						
					DisposeDTObject(mysound);
					DisposeDTObject(myimg_stop);
					CloseCatalog(catalog);
					CloseLibrary(AssemblyBase);
					return(0L);
					break;
				
				case0:
					break;	
			}
        ReplyMsg((struct Message *)appmsg);
		}
	}
	FreeAsmRequest(areq);
	DisposeDTObject(mysound);
	DisposeDTObject(myimg_stop);
	CloseCatalog(catalog);
	CloseLibrary(AssemblyBase);
	}
}


/**************************************************************************************
 * 
 **************************************************************************************
*/
void GetDefToolsTypes(int argc, char **argv,STRPTR tools, STRPTR defvalue, STRPTR iname)
{
struct DiskObject *dobj;
struct WBStartup *wbs;
struct WBArg *wbarg;
STRPTR iiname;
BPTR lock;
	
	lock = Lock("PROGDIR:",ACCESS_READ);
	CurrentDir(lock);

	if (argc == 0)			/* partito da Workbench */
	{
		wbs = (struct WBStartup *)argv;
		wbarg = wbs->sm_ArgList;
		dobj = GetDiskObject(wbarg[0].wa_Name);
	}
	else
		dobj = GetDiskObject(argv[0]);
	
	if(!dobj)
	{
		strcpy(iname, defvalue);
		UnLock(lock);
		CurrentDir(NULL);
		return(NULL);
	}	
		
	iiname = FindToolType(dobj->do_ToolTypes, tools);
	strcpy(iname,iiname);
	FreeDiskObject(dobj);
	UnLock(lock);
	CurrentDir(NULL);
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
	ExecBase = AssemblyBase->ab_ExecBase;
	CxBase = AssemblyBase->ab_CxBase;
	
	DiskfontBase = OpenLibrary("diskfont.library",NULL);
	
	catalog = OpenCatalogA(NULL,"Reboot.catalog",NULL);
	
	return(AssemblyBase);
}


/*************************************************************************************/

VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
