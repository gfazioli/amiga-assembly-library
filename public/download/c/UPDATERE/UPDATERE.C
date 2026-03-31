/**************************************************************************************
** UPDATE RSEIDENT
**------------------------------------------------------------------------------------
**; HISTORY
**;--------+--------+-----------+-----------------------------------------------------
**; Author | Rel    | Date      | Comment
**;--------+--------+-----------+-----------------------------------------------------
**; =jon=  | 4.1    | 18-Ago-95 | Aggiunta Localizzazione
**; =jon=  | 4.11   | 20-Sep-95 | New About, Add follow function
**; =jon=  | 4.11   | 22-Sep-95 | Bugs Text fix, new assembly.library
**; =jon=  | 4.12   | 18-Nov-95 | Add HighLight of the ListView
**; =jon=  | 4.13   | 19-Nov-95 | Add new Tools types and drop file icon...
**; =jon=  | 4.13   | 20-Nov-95 | Fix bugs on MenuPick of Delete Item.. there is not
**; =jon=  | 4.14   | 21-Nov-95 | Fix many graphics bugs, now it'is very good
**; =jon=  | 4.15   | 30-Gen-96 | Rev code, eliminato bugs su primo aggiornamento. 
**; =jon=  | 4.15   | 29-Feb-96 | ** Bugs su circondino blu intorno ai ListViews
**;        |        |           | questi non vengono ridisegnati quando viene
**;        |        |           | eseguito un resize della window.
**;        |        |           |
**;        |        |           |
**;        |        |           |
**;--------+--------+-----------+-----------------------------------------------------
*************************************************************************************** 
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
#include <sources:c/UpDateRes/UpDateResident.h>

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

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase, *DiskfontBase;
struct Catalog *catalog;

char settings[80];

struct Hook CAHook;

/********** My C prototypes **********************************************************/

struct AssemblyBase *OpenLibs(void);
struct REI *OpenAndInitI(STRPTR reiname,int argc, char **argv);
void About(struct REI *mainrei);
void CloseAll(struct REI *mainrei);
void Check(struct REI *mainrei);
void ChangeDir(struct REI *mainrei);
void Rescan(struct REI *mainrei);
void SetInterface(struct REI *mainrei, BOOL bool);
void InfoWB(struct REI *mainrei);
void SetCommentFile(struct REI *mainrei);
void GetDefToolsTypes(int argc, char **argv,STRPTR , STRPTR, STRPTR );

void UpDate(struct REI *mainrei);
void SetStrCopy(struct REI *mainrei, STRPTR string);
void SetREIFont(struct REI *mainrei);
void SaveSetting(struct REI *mainrei);
void LoadSetting(struct REI *mainrei);
void StoreTag(struct REI *mainrei, BOOL save);
void DeleteRes(struct REI *mainrei);

void ActiveStdMenuGad(struct REI *mainrei, BOOL on);

void FileError(struct REI *mainrei,STRPTR filename);
void WBInfoError(struct REI *mainrei,STRPTR filename);
void SetCommentError(struct REI *mainrei,STRPTR filename);
void DeleteInfoError(struct REI *mainrei,STRPTR filename);

ULONG UpDateInfo(struct REI *mainrei,STRPTR filename);
ULONG ChoiceSetComment(struct REI *mainrei,STRPTR filename);
ULONG DeleteInfo(struct REI *mainrei,STRPTR filename);

BOOL CopySel(struct REI *mainrei, ULONG numsel);
BOOL SetComSel(struct REI *mainrei, ULONG numsel);
void SetThisListView(struct REI *mainrei, BOOL which);
void MoveList(struct REI *mainrei, BOOL down);
struct REI *Iconify(struct REI *mainrei);

/********** My Asm prototypes ********************************************************/
BOOL Filling (BPTR,STRPTR,STRPTR);
BOOL SoFill(STRPTR,STRPTR,STRPTR);
void RecoverFilename(STRPTR, STRPTR);
struct Node *NodeNumber(struct List *list, ULONG number);
void ObtainError(STRPTR buffer);
Object *LoadNewDTObjectA(STRPTR filename, struct TagItem *);
Object *LoadNewDTObject(STRPTR filename, Tag, ...);
void CopyTextAttr(struct TextAttr *, struct TextAttr *);
void ShowIInfo(struct Hook *hook, struct REI *rei, struct REIMessage *REIMsg);
MakeFontName(struct UpDateData *udd);

/**************************************************************************************
 * Main 
 **************************************************************************************
*/

VOID main(int argc, char **argv)
{
struct	WBStartup *wbs;
struct	WBArg *wbarg;
struct	REI *mainrei;
struct	REIMessage *rmsg;
BOOL	fine = TRUE;

	if (AssemblyBase = OpenLibs())
	{
	
		GetDefToolsTypes(argc, argv,"SETTINGS","ENVARC:UpDateRes.Prefs",settings);
		
		if(mainrei = OpenAndInitI("main",argc, argv))
		{
			LockREI(mainrei,NULL);
			SetAsmGadgetAttrs(mainrei,NULL,BUT_SYSTEMLIST,GA_Disabled,TRUE,TAG_DONE);
			SetInterface(mainrei, TRUE);
			UnlockREI(mainrei,NULL);
				
			while (fine)
			{
				if (rmsg = WaitREIMsg(mainrei,0x5F))
				{	
					switch(rmsg->rim_Class)
					{
						case IDCMP_MOUSEBUTTONS:
							if(rmsg->rim_REICode == RIM_LEFTDOUBLECLICK)
								About(mainrei);
							break;
						
						
						case IDCMP_MENUPICK:
							switch(rmsg->rim_Code)
							{
								case ITEM_SCAN:
									LockREI(mainrei,NULL);
									Check(mainrei);
									UnlockREI(mainrei,NULL);
									break;
								
								case ITEM_RESCAN:
									LockREI(mainrei,NULL);
									Rescan(mainrei);
									UnlockREI(mainrei,NULL);
									break;	

								case ITEM_SETCOM:
									LockREI(mainrei,NULL);
									SetCommentFile(mainrei);
									UnlockREI(mainrei,NULL);
									break;
									
								case ITEM_DELETE:
									LockREI(mainrei,NULL);
									DeleteRes(mainrei);
									UnlockREI(mainrei,NULL);
									break;									
									
								case ITEM_UPDATE:	
									LockREI(mainrei,NULL);
									UpDate(mainrei);
									UnlockREI(mainrei,NULL);
									break;
								
								case ITEM_ICONIFY:		
									mainrei = Iconify(mainrei);
									break;
									
								case ITEM_ABOUT:		
									About(mainrei);
									break;

								case ITEM_QUIT:
									fine = FALSE;
									break;
									
								case ITEM_INFOWB:
									LockREI(mainrei,NULL);
									InfoWB(mainrei);
									UnlockREI(mainrei,NULL);
									break;
									
								case ITEM_SETFONT:
									SetREIFont(mainrei);
									break;
								
								case ITEM_LOADSETS:
									LockREI(mainrei,NULL);
									LoadSetting(mainrei);
									UnlockREI(mainrei,NULL);
									break;	
									
								case ITEM_SAVESETS:
									LockREI(mainrei,NULL);
									SaveSetting(mainrei);
									UnlockREI(mainrei,NULL);
									break;		
								
								case ITEM_LIBS:	
									SetStrCopy(mainrei,"Libs:");
									break;
								case ITEM_DEVS:	
									SetStrCopy(mainrei,"Devs:");
									break;
								case ITEM_DATA:	
									SetStrCopy(mainrei,"Sys:Classes/DataTypes");
									break;
								case ITEM_GADS:	
									SetStrCopy(mainrei,"Sys:Classes/Gadgets");
									break;	
								case ITEM_IMGS:	
									SetStrCopy(mainrei,"Sys:Classes/Images");
									break;	
								case ITEM_CODS:	
									SetStrCopy(mainrei,"Sys:Classes/Codecs");
									break;	
								case ITEM_CLAS:	
									SetStrCopy(mainrei,"Sys:Classes");
									break;	
									
							}
							break;
						
						case IDCMP_CLOSEWINDOW:
							fine = FALSE;
							break;
							
						case IDCMP_RAWKEY:
							switch(rmsg->rim_Code)
							{
								case 0x4D:
									MoveList(mainrei,TRUE);
									break;
								case 0x4C:
									MoveList(mainrei,FALSE);	
									break;
							}
							break;
							
						case IDCMP_VANILLAKEY:
							switch(rmsg->rim_Code)
							{
								case '?':
									About(mainrei);
									break;
								case 0x7f:
									LockREI(mainrei,NULL);
									DeleteRes(mainrei);
									UnlockREI(mainrei,NULL);
									break;	
							}
							break;	
							
						case IDCMP_GADGETUP:
							switch(((struct Gadget *)rmsg->rim_IAddress)->GadgetID)
							{
								case BUT_SCAN_CODE:
									LockREI(mainrei,NULL);
									Check(mainrei);
									UnlockREI(mainrei,NULL);
									break;
								
								case BUT_INFOWB_CODE :
									LockREI(mainrei,NULL);
									InfoWB(mainrei);
									UnlockREI(mainrei,NULL);
									break;	
									
								case BUT_UPDATE_CODE :
									LockREI(mainrei,NULL);
									UpDate(mainrei);
									UnlockREI(mainrei,NULL);
									break;	
									
								case BUT_COMPARETO_CODE :
									ChangeDir(mainrei);
									break;
									
								case BUT_RESCAN_CODE :
								case STR_COMPARETO_CODE :
									LockREI(mainrei,NULL);
									Rescan(mainrei);
									UnlockREI(mainrei,NULL);
									break;
								
								case LV_SOURCEFILES_CODE :
									SetThisListView(mainrei,TRUE);
									break;	
									
								case LV_DESTFILES_CODE :
									SetThisListView(mainrei,FALSE);
									break;	
									
								case BUT_QUIT_CODE :
									fine = FALSE;
									break;	
							
							}
							break;	
					}		
				}			
			}			
		CloseAll(mainrei);	
		}
	CloseLibrary(AssemblyBase);	
	}
}

/**************************************************************************************
 * DeleteRes()
 **************************************************************************************
*/
void DeleteRes(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Node *selnode;
struct	List *mylist;
BPTR	lock, oldlock;

	if ( GetAsmGadgetAttr(mainrei,NULL,BUT_INFOWB,GA_Disabled))
		return(NULL);

	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,
															AGATLV_SelectedNode);
	if(selnode)
	{
		RecoverFilename(selnode->ln_Name,udd->Error);
		
		if( DeleteInfo(mainrei,udd->Error))
		{		
			lock = Lock(udd->CurrentDrawer,ACCESS_READ);
			oldlock = CurrentDir(lock);
			
			if(!(DeleteFile(udd->Error)))
				DeleteInfoError(mainrei,udd->Error);
			else
			{
				mylist = (struct List *)GetAsmGadgetAttr(mainrei,udd->LastLV,
																NULL,GTLV_Labels);
				SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Labels,~0,
																		TAG_DONE);
				FreeNodeName(mylist,selnode);
				SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Labels,mylist,
																		TAG_DONE);
				Rescan(mainrei);
			}	
			CurrentDir(oldlock);
			UnLock(lock);
		}	
	}
}

/**************************************************************************************
 * SetREIFont()
 **************************************************************************************
*/
void SetREIFont(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	FontRequester *fontr;	
struct	Font *myfont;
ULONG	state;
		
	if(fontr = AllocAslRequest(ASL_FontRequest,NULL))
		if (AslRequest(fontr, NULL))
		{
			CopyTextAttr(&fontr->fo_Attr,&udd->TextPrefs);
			
			if(myfont = OpenDiskFont(&udd->TextPrefs))
			{
				SetREIAttrs(mainrei,NULL,REIT_WindowTextAttr,&udd->TextPrefs,TAG_DONE);
				FreeAslRequest(fontr);	
			}	
		}
		state = GetAsmGadgetAttr(mainrei,NULL,BUT_INFOWB,GA_Disabled);
    	if(state)
    	{
			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_RESCAN,0));
			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_UPDATE,0));
			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
		}
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_SYSTEMLIST,0));

}

/**************************************************************************************
 * SaveSettiing()
 **************************************************************************************
*/
void SaveSetting(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
short	len;
	
	StoreTag(mainrei, TRUE);
	
	len = Save(settings,&udd->TextPrefs,(sizeof(&udd->TextPrefs) +30 + 4*9)); 

}

/**************************************************************************************
 * LoadSettiing()
 **************************************************************************************
*/
void LoadSetting(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Font *myfont;
ULONG	state;

	if(Load(settings,&udd->TextPrefs,NULL))
	{
		MakeFontName(&udd->TextPrefs);
	
		if(myfont = OpenDiskFont(&udd->TextPrefs))
			SetREIAttrs(mainrei,NULL,REIT_WindowTextAttr,&udd->TextPrefs,
									 REIT_WindowTAG,&udd->LeftTag,	
										TAG_DONE);
	}
		
	state = GetAsmGadgetAttr(mainrei,NULL,BUT_INFOWB,GA_Disabled);
    if(state)
    {
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_RESCAN,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_UPDATE,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
	}
	OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_SYSTEMLIST,0));

}

/**************************************************************************************
 * SetStrCopy()
 **************************************************************************************
*/
void SetStrCopy(struct REI *mainrei, STRPTR string)
{
struct UpDateData *udd = mainrei->rei_UserData;
struct MenuItem *mi;
	
	strcpy(udd->udd_DestDrawer, string);
	SetAsmGadgetAttrs(mainrei,NULL,STR_COMPARETO,GTST_String,udd->udd_DestDrawer,TAG_DONE);
	
	/* Indirizzo del Menu che voglio controllare */
	if(mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
														CITEM_AUTORESCAN,~0))
		if( (mi->Flags & CHECKED) )			/* Controllo se è Checcato */
			Rescan(mainrei);				/* Allora eseguo */
}

/**************************************************************************************
 * Update()
 **************************************************************************************
*/
void UpDate(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;		
struct Node *selnode;
ULONG response;
ULONG numsel;
SHORT x;

	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,AGATLV_SelectedNode);	
	
	if(selnode)
	{												   
		RecoverFilename(selnode->ln_Name,udd->Error);
		response = UpDateInfo(mainrei,udd->Error);
		
		switch (response)
		{
			case 0:
				return(NULL);
				break;
				
			case 1:
				LockREI(mainrei,NULL);				
				numsel = GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,GTLV_Selected);
				if(CopySel(mainrei,numsel))
					Rescan(mainrei);
				UnlockREI(mainrei,NULL);
				break;	
				
			case 2:
				LockREI(mainrei,NULL);
				for ( x=0;  x < udd->fr->rf_NumArgs;  x++ )	
				{
					if(!(CopySel(mainrei,x)))
					{
						UnlockREI(mainrei,NULL);
						return(NULL);
					}	
				}
				Rescan(mainrei);
				UnlockREI(mainrei,NULL);
				break;
		}
	}
}

/**************************************************************************************
 * CopySel()
 **************************************************************************************
*/
BOOL CopySel(struct REI *mainrei, ULONG numsel)
{
struct UpDateData *udd = mainrei->rei_UserData;
BPTR lock, oldlock;
STRPTR filename = udd->frargs[numsel].wa_Name;
struct Node *node;
struct List *list;
APTR buffer;
BOOL succ = FALSE;

	list = (struct List *)GetAsmGadgetAttr(mainrei,NULL,LV_SOURCEFILES,GTLV_Labels);
	if(node = NodeNumber(list,numsel))
	{
		oldlock = CurrentDir(udd->frargs[numsel].wa_Lock);	
	
		if(!(buffer = Load(filename,NULL,MEMF_PUBLIC)))
		{
			ObtainError(udd->Error);
			FileError(mainrei,filename);
			CurrentDir(NULL);
			return(TRUE);
		}
		
		if(node->ln_Type != ASYSI_SYSTEM)
		{
			ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
							   GetCatalogStr(catalog,MSG_WARNING,
							   "Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,FALSE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   TAG_DONE);
	
			ULONG res = AsmRequest(udd->areq, 
								GetCatalogStr(catalog,MSG_COPYS,
								"Warning, '%s'\n"
								"is a Unknow file type.\n\n"
								"Do you want copy anyway?"),
								GetCatalogStr(catalog,MSG_COPYSGAD,
                         		"Copy|_Skip|Abort"),
                         		filename);
		
			switch (res)
			{
				case 0:
					CurrentDir(oldlock);
					FreeVec(buffer);
					return(NULL);
					break;
				
				case 2:	
					CurrentDir(oldlock);
					FreeVec(buffer);
					return(TRUE);
					break;
			}
		}
		
		CurrentDir(oldlock);
	
		if(lock = Lock(udd->udd_DestDrawer,ACCESS_READ))
		{
			oldlock = CurrentDir(lock);
			if(!CheckFile(filename,NULL))
				DeleteFile(filename);				/* Rev. (3.Sep.1995) =Jon= */
				
			Save(filename,buffer,NULL);
			CurrentDir(oldlock);
			succ = TRUE;
		}
		FreeVec(buffer);
	}
return(succ);
}

/**************************************************************************************
 * SetComSel()
 **************************************************************************************
*/
BOOL SetComSel(struct REI *mainrei, ULONG numsel)
{
struct  UpDateData *udd = mainrei->rei_UserData;
BPTR    lock, oldlock;
STRPTR  filename = udd->frargs[numsel].wa_Name;
struct  Node *node;
struct  List *list;
APTR    buffer;
BOOL    succ = FALSE;
char	tempbuf[84];

	list = (struct List *)GetAsmGadgetAttr(mainrei,NULL,LV_SOURCEFILES,GTLV_Labels);
	if(node = NodeNumber(list,numsel))
	{
		oldlock = CurrentDir(udd->frargs[numsel].wa_Lock);	
	
		if(node->ln_Type != ASYSI_SYSTEM)
		{
			ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
							   GetCatalogStr(catalog,MSG_WARNING,
							   "Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,FALSE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   TAG_DONE);
	
			ULONG res = AsmRequest(udd->areq, 
								GetCatalogStr(catalog,MSG_SETCOMS,
								"Warning, '%s'\n"
								"is a Unknow file type.\n\n"
								"Do you want SET COMMENT anyway?"),
								GetCatalogStr(catalog,MSG_SETCOMSGAD,
                         		"SET|_Skip|Abort"),
                         		filename);
		
			switch (res)
			{
				case 0:
					CurrentDir(oldlock);
					return(NULL);
					break;
				
				case 2:	
					CurrentDir(oldlock);
					return(TRUE);
					break;
			}
		}
		
		strncpy(tempbuf,node->ln_Name+30,60);
		
		if(!(SetComment(filename,tempbuf)))
		{
			SetCommentError(mainrei,filename);
			succ = FALSE;
		}
		else
			succ = TRUE;
				
		CurrentDir(oldlock);
	}
return(succ);
}



/**************************************************************************************
 * Iconify()
 **************************************************************************************
*/
struct REI *Iconify(struct REI *mainrei)
{
struct  UpDateData *udd = mainrei->rei_UserData;
struct	MsgPort      *myport=NULL;
struct	AppMenuItem *appitem=NULL;
struct	AppMessage   *appmsg=NULL;
struct	MenuItem *mi;
BOOL	fine = TRUE;
ULONG	state;

	if(myport = CreateMsgPort())
	{
		if(appitem = AddAppMenuItemA(0x22, NULL,
                           "UpDateResident 4.15",
                            myport,NULL))
        {
			StoreTag(mainrei, TRUE);
        	CloseREI(mainrei,NULL);
			WaitPort(myport);
			while((appmsg=(struct AppMessage *)GetMsg(myport)) && (fine))
			{
				if(appmsg->am_ID == 0x22)
					fine = FALSE;
				ReplyMsg((struct Message *)appmsg);
    		}
    		RemoveAppMenuItem(appitem);
        	while(appmsg=(struct AppMessage *)GetMsg(myport))    
    			ReplyMsg((struct Message *)appmsg);
    		mainrei=OpenREI(NULL,"main",REIT_WindowTAG,&udd->LeftTag,TAG_DONE);		
    		udd = mainrei->rei_UserData;
    		state = GetAsmGadgetAttr(mainrei,NULL,BUT_INFOWB,GA_Disabled);
    		if(state)
    		{
    			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_RESCAN,0));
    			OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
				OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_UPDATE,0));
				OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
				OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
				SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,AGAT_HighLight,FALSE,
																		TAG_DONE);												
			}
			else
				SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,AGAT_HighLight,TRUE,
																		TAG_DONE);	
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,
													CITEM_SYSTEMLIST,0));

			if(udd->autorescan)
			{	
				mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
														CITEM_AUTORESCAN,~0);
				mi->Flags |= CHECKED;		
			}
		
			if(udd->follow)
			{	
				mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
															CITEM_FOLLOW,~0);
				mi->Flags |= CHECKED;
			}													
		}
	DeleteMsgPort(myport);
	}
return(mainrei);	
}

/**************************************************************************************
 * MoveList()
 **************************************************************************************
*/
void MoveList(struct REI *mainrei, BOOL down)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	MenuItem *mi;
struct	Node *selnode;
BOOL	follow = FALSE;
ULONG	num;

	if(mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
														CITEM_FOLLOW,~0))
		if( (mi->Flags & CHECKED) )			/* Controllo se è Checcato */
			follow = TRUE;
	
	if(udd->LastLV == NULL)
	{
		udd->LastLV = FindAsmGadget(mainrei,LV_SOURCEFILES);
		udd->NoFocusLV = FindAsmGadget(mainrei,LV_DESTFILES);
	}	
			
	if(down)
	{
		num = GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,GTLV_Selected);
		SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Selected,num+1,
													GTLV_MakeVisible,num+1,
													TAG_DONE);		
		if (follow)		
			SetAsmGadgetAttrs(mainrei,udd->NoFocusLV,NULL,GTLV_Selected,num+1,
													GTLV_MakeVisible,num+1,
													TAG_DONE);
	}	
	else
	{
		num = GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,GTLV_Selected);
		if(num)
		{
			SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Selected,num-1,
														GTLV_MakeVisible,num-1,
														TAG_DONE);
			if (follow)
				SetAsmGadgetAttrs(mainrei,udd->NoFocusLV,NULL,GTLV_Selected,num-1,
														GTLV_MakeVisible,num-1,
														TAG_DONE);
		}														
	}

	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,
															AGATLV_SelectedNode);
		
	switch(selnode->ln_Type)
	{
		case ASYSI_QUESTION:
		
			ActiveStdMenuGad(mainrei, FALSE);
			break;

		case ASYSI_SYSTEM:
		case ASYSI_SELECTED:
			ActiveStdMenuGad(mainrei, TRUE);
			break;
	}

}

/**************************************************************************************
 * ActiveStdMenuGad (mainrei,bool)
 **************************************************************************************
*/
void ActiveStdMenuGad(struct REI *mainrei, BOOL on)
{
struct	UpDateData *udd = mainrei->rei_UserData;	

	if(!on)
	{
		SetAsmGadgetAttrs(mainrei,NULL,BUT_INFOWB,GA_Disabled,TRUE,TAG_DONE);
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
		OffMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
	}
	else
	{
		SetAsmGadgetAttrs(mainrei,NULL,BUT_INFOWB,GA_Disabled,FALSE,TAG_DONE);
		OnMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
		OnMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
		OnMenu(mainrei->rei_Window,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
	}
}

/**************************************************************************************
 * SetThisListView()
 **************************************************************************************
*/
void SetThisListView(struct REI *mainrei, BOOL which)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Node *selnode;
struct	MenuItem *mi;
ULONG	num;
BOOL	follow = FALSE;

	if(mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
														CITEM_FOLLOW,~0))
		if( (mi->Flags & CHECKED) )			/* Controllo se è Checcato */
			follow = TRUE;

	if(which)
	{
		udd->LastLV = FindAsmGadget(mainrei,LV_SOURCEFILES);
		udd->NoFocusLV = FindAsmGadget(mainrei,LV_DESTFILES);

		SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,AGAT_HighLight,FALSE,
																	TAG_DONE);
												
		SetAsmGadgetAttrs(mainrei,NULL,LV_SOURCEFILES,AGAT_HighLight,TRUE,TAG_DONE);												
		
		num = GetAsmGadgetAttr(mainrei,NULL,LV_SOURCEFILES,GTLV_Selected);
	
		if (follow)
			SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,GTLV_Selected,num,
														GTLV_MakeVisible,num,
														TAG_DONE);
		
		udd->CurrentDrawer = udd->udd_InitDrawer;
	}
	else
	{
		udd->LastLV = FindAsmGadget(mainrei,LV_DESTFILES);
		udd->NoFocusLV = FindAsmGadget(mainrei,LV_SOURCEFILES);

		SetAsmGadgetAttrs(mainrei,NULL,LV_SOURCEFILES,AGAT_HighLight,FALSE,
																	TAG_DONE);
													
		SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,AGAT_HighLight,TRUE,TAG_DONE);												

		num = GetAsmGadgetAttr(mainrei,NULL,LV_DESTFILES,GTLV_Selected);
	
		if (follow)
			SetAsmGadgetAttrs(mainrei,NULL,LV_SOURCEFILES,GTLV_Selected,num,
														GTLV_MakeVisible,num,
														TAG_DONE);

		udd->CurrentDrawer = udd->udd_DestDrawer;
	}
	
	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,
															AGATLV_SelectedNode);
		
	switch(selnode->ln_Type)
	{
		case ASYSI_QUESTION:
			ActiveStdMenuGad(mainrei, FALSE);
			break;

		case ASYSI_SYSTEM:
		case ASYSI_SELECTED:
			ActiveStdMenuGad(mainrei, TRUE);
			break;
	}
}

/**************************************************************************************
 * CloseAll()
 **************************************************************************************
*/
void CloseAll(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;
	
	CloseREI(mainrei,NULL);
	CloseInterface(udd->udd_i);
	if(udd->freelist)
	{
		FreeListName(udd->freelist);
		if(udd->freelist2)
			FreeListName(udd->freelist2);
	}	
	FreeAslRequest(udd->fr);
	FreeAslRequest(udd->frDrawer);
	
	DisposeDTObject(udd->dto01);
	DisposeDTObject(udd->dto02);
	DisposeDTObject(udd->dto03);
	DisposeDTObject(udd->dto04);
	FreeAsmRequest(udd->areq);

	FreeVec(udd);
	
	CloseLibrary(DiskfontBase);
}

/**************************************************************************************
 * OpenAndInitI()
 **************************************************************************************
*/
struct REI *OpenAndInitI(STRPTR reiname,int argc, char **argv)
{
struct	Interface *i;
struct	REI *mainrei=NULL;
struct	UpDateData *udd;
struct	Font *myfont;
APTR	buffer;
BPTR	lock, oldlock;
char	tmpname[40], YesNo[20];

	GetDefToolsTypes(argc, argv,"INTERFACE","updateresident.rei",tmpname);
	
	i = OpenInterface(tmpname);
	
	if(i==NULL)
	{
		lock = Lock("sys:i",ACCESS_READ);	/* Mettere in OpenInterface() */
		oldlock = CurrentDir(lock);
		i = OpenInterface(tmpname);
		CurrentDir(oldlock);
		UnLock(lock);
	}	
	
	if(i)
	{
		if(udd = AllocVec(sizeof(*udd),MEMF_CLEAR))
			if(Load(settings,&udd->TextPrefs,NULL))
			{
				MakeFontName(&udd->TextPrefs);
				if(myfont = OpenDiskFont(&udd->TextPrefs))		
					mainrei = OpenREI(NULL, reiname,REIT_CenterHScreen,TRUE,
										   REIT_CenterVScreen,TRUE,
										   REIT_WindowTextAttr,&udd->TextPrefs,
										   REIT_WindowTAG,&udd->LeftTag,
										   REIT_DoubleClick,TRUE,
										   TAG_DONE);
			}
			else
				mainrei = OpenREI(NULL, reiname,REIT_CenterHScreen,TRUE,
										   REIT_CenterVScreen,TRUE,
										   REIT_DoubleClick,TRUE,
										   TAG_DONE);
			
		if(mainrei)										   
		{
		
			mainrei->rei_UserData = udd;
			
			StoreTag(mainrei,FALSE);
				
			udd->autorescan = TRUE;	
			GetDefToolsTypes(argc, argv,"AUTORESCAN","YES",YesNo);
			if(!StrnCmp(AssemblyBase->ab_Locale,YesNo,"NO",-1,SC_ASCII))
				udd->autorescan = FALSE;	

			udd->follow = TRUE;
			GetDefToolsTypes(argc, argv,"FOLLOW","YES",YesNo);
			if(!StrnCmp(AssemblyBase->ab_Locale,YesNo,"NO",-1,SC_ASCII))
				udd->follow = FALSE;
				
			GetDefToolsTypes(argc, argv,"DESTDRAWER","Libs:",udd->udd_DestDrawer);
	
			SetAsmGadgetAttrs(mainrei,NULL,STR_COMPARETO,GTST_String,udd->udd_DestDrawer,TAG_DONE);
		}		
		
		udd->CurrentDrawer = udd->udd_InitDrawer;	/* InfoWB reset at the starting */
		
		udd->fr = AllocAslRequestTags(ASL_FileRequest, ASLFR_Screen, mainrei->rei_Screen,
						ASLFR_TitleText, 
						GetCatalogStr(catalog, MSG_SELECT, "Select a file(s)..."),
						ASLFR_PositiveText, 
						GetCatalogStr(catalog,MSG_CHECK , "Check"),
						ASLFR_DoMultiSelect, TRUE,
						ASLFR_RejectIcons,TRUE,
						ASLFR_InitialDrawer,udd->udd_InitDrawer,
						TAG_DONE);
		if(udd->fr == NULL)
			return(NULL);				
			
		udd->frDrawer = AllocAslRequestTags(ASL_FileRequest, 
						ASLFR_Screen, mainrei->rei_Screen,
						ASLFR_DrawersOnly, TRUE,
						ASLFR_SleepWindow, TRUE,
						ASLFR_TitleText, 
						GetCatalogStr(catalog, MSG_CHANGEDIR, "Change Dir..."),
						ASLFR_PositiveText, 
						GetCatalogStr(catalog,MSG_CHANGE , "Change"),
						ASLFR_InitialDrawer,udd->udd_DestDrawer,
						TAG_DONE);
		if(udd->frDrawer == NULL)
			return(NULL);	
			
		udd->dto01 = LoadNewDTObject("updateresident.bsh",DTA_ControlPanel,FALSE,
												PDTA_Remap,FALSE,
												PDTA_NumColors,16,
												TAG_DONE);
		udd->dto02 = LoadNewDTObject("Warning.bsh",DTA_ControlPanel,FALSE,
												PDTA_Remap,FALSE,
												PDTA_NumColors,16,
												TAG_DONE);
		udd->dto03 = LoadNewDTObject("FloppyDisk.bsh",DTA_ControlPanel,FALSE,
												PDTA_Remap,FALSE,
												PDTA_NumColors,16,
												TAG_DONE);
		udd->dto04 = LoadNewDTObject("Stop.bsh",DTA_ControlPanel,FALSE,
												PDTA_Remap,FALSE,
												PDTA_NumColors,16,
												TAG_DONE);
		
		udd->areq = AllocAsmRequest(AREQ_Title, "About...",
							   AREQ_Object,udd->dto01,
							   AREQ_LockREI,mainrei,
							   AREQ_ReturnKey,TRUE,	
							   AREQ_CenterHScreen,TRUE,
							   AREQ_CenterVScreen,TRUE,
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_TextUnderObject,TRUE,
							   AREQ_NewLookBackFill,TRUE,
							   AREQ_APenPattern,5,
							   AREQ_BPenPattern,5,
							   AREQ_FrameOnly,TRUE,
							   TAG_DONE);	
		
	}	
return(mainrei);
}

/**************************************************************************************
 * StoreTag()
 **************************************************************************************
*/
void StoreTag(struct REI *mainrei, BOOL save)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Window *win;

ULONG	bordoW, bordoH;

	GetREIAttrs(mainrei,NULL, REIT_Window, &win, TAG_DONE);

	if(save)
	{
		struct Screen *screen = win->WScreen;
		struct RastPort *rp = &screen->RastPort;

		bordoW = win->BorderLeft + win->BorderRight - 6;
		bordoH = screen->WBorTop + rp->TxHeight;
	}	
	else
	{
		bordoW = NULL;
		bordoH = NULL;
	}

	udd->LeftTag = WA_Left;
	udd->LeftValue = (UWORD *)win->LeftEdge;
	udd->TopTag = WA_Top;
	udd->TopValue = (UWORD *)win->TopEdge;
	udd->WidthTag = WA_InnerWidth;
	udd->WidthValue = (UWORD *)win->Width - bordoW;
	udd->HeightTag = WA_InnerHeight;
	udd->HeightValue = (UWORD *)win->Height - bordoH;

	udd->TagDone = TAG_DONE;

}


/**************************************************************************************
 * ChangeDir()
 **************************************************************************************
*/
void ChangeDir(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;
struct MenuItem *mi;

	if(AslRequestTags(udd->frDrawer, ASLFR_InitialDrawer,udd->udd_DestDrawer,TAG_DONE))
	{
		strcpy(udd->udd_DestDrawer, udd->frDrawer->rf_Dir);
		SetAsmGadgetAttrs(mainrei,NULL,STR_COMPARETO,GTST_String,udd->udd_DestDrawer,TAG_DONE);

		/* Indirizzo del Menu che voglio controllare */
		if(mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
															CITEM_AUTORESCAN,~0))
			if( (mi->Flags & CHECKED) )			/* Controllo se è Checcato */
				Rescan(mainrei);				/* Allora eseguo */
	}	
}


/**************************************************************************************
 * Check()
 **************************************************************************************
*/
void Check(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Node *tmpnode;
STRPTR	strinfo;
STRPTR	strinfo2;
BOOL	GHGAD = FALSE;
SHORT	x;
BPTR	res, oldlock, lock, deoldlock;
ULONG	num;

	if(AslRequestTags(udd->fr, ASLFR_InitialDrawer,udd->udd_InitDrawer,TAG_DONE))
	{
		if(udd->freelist)
		{
			SetAsmGadgetAttrs(mainrei,NULL,LV_SOURCEFILES,GTLV_Labels,~0,TAG_DONE);
			FreeListName(udd->freelist);
			SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,GTLV_Labels,~0,TAG_DONE);
			if(udd->freelist2)
				FreeListName(udd->freelist2);
		}
	
	udd->freelist = AllocNewList();
	udd->freelist2 = AllocNewList();
			
	strcpy(udd->udd_InitDrawer, udd->fr->rf_Dir);	/* copio ultima drawr */
	udd->frargs = udd->fr->rf_ArgList;			
		
	for ( x=0;  x < udd->fr->rf_NumArgs;  x++ )
	{	
	
	strinfo = AllocVec(STRING_LEN,MEMF_CLEAR);	
	tmpnode = AllocNode(udd->freelist,strinfo,ASYSI_SYSTEM,NULL);
	
	oldlock = CurrentDir(udd->frargs[x].wa_Lock);
		
		if(!CheckFile(udd->frargs[x].wa_Name,NULL))
		{
			if(res=LoadSeg(udd->frargs[x].wa_Name))
			{
				if(!(Filling(res,udd->frargs[x].wa_Name,strinfo)))
					tmpnode->ln_Type = ASYSI_QUESTION;
				UnLoadSeg(res);	
			}
			else	/* Errore, non ha funzionato LoadSeg() */
			{
				ObtainError(udd->Error);
				SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo);
				tmpnode->ln_Type = ASYSI_SELECTED;
			}
		}
		else
		{
			ObtainError(udd->Error);
			SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo);
			tmpnode->ln_Type = ASYSI_QUESTION;
		}	
		
	CurrentDir(oldlock);
	
	strinfo2 = AllocVec(STRING_LEN,MEMF_CLEAR);
	tmpnode = AllocNode(udd->freelist2,strinfo2,ASYSI_SYSTEM,NULL);
			
	lock = Lock(udd->udd_DestDrawer,ACCESS_READ);
	deoldlock = CurrentDir(lock);
		
		if(!CheckFile(udd->frargs[x].wa_Name,NULL))
		{
			if(res=LoadSeg(udd->frargs[x].wa_Name))
			{
				if(!(Filling(res,udd->frargs[x].wa_Name,strinfo2)))
					tmpnode->ln_Type = ASYSI_QUESTION;
				UnLoadSeg(res);	
			}
			else	/* Errore, non ha funzionato LoadSeg() */
			{
				ObtainError(udd->Error);
				SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo2);
				tmpnode->ln_Type = ASYSI_SELECTED;
			}
		}
		else
		{
			ObtainError(udd->Error);
			SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo2);
			tmpnode->ln_Type = ASYSI_QUESTION;
		}
		
		
	CurrentDir(deoldlock);
	if(lock)
		UnLock(lock);
	
	}
	
	struct Node *test = udd->freelist->lh_Head;
	if(test->ln_Succ == NULL)
   	{
   		FreeListName(udd->freelist);
		FreeListName(udd->freelist2);
		udd->freelist = NULL;
		udd->freelist2 = NULL;
		GHGAD = TRUE;
   	}
   	/*--- ora metto le liste ---*/
  	SetAsmGadgetAttrs(mainrei,NULL,LV_SOURCEFILES,GTLV_Labels,udd->freelist,
  														AGAT_HighLight,FALSE,
  														TAG_DONE);
   	SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,GTLV_Labels,udd->freelist2,
   														AGAT_HighLight,FALSE,
   														TAG_DONE);
   	
   	if(udd->LastLV)
	   	SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,AGAT_HighLight,TRUE,TAG_DONE);
	else
	{ 
		udd->LastLV = FindAsmGadget(mainrei,LV_SOURCEFILES);  	
		SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,AGAT_HighLight,TRUE,TAG_DONE);   	
		SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Selected,0L,
													GTLV_MakeVisible,0L,
													TAG_DONE);
	}
	
	SetInterface(mainrei, GHGAD);

		if(GHGAD == NULL)
		{
			num = GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,GTLV_Selected);
		
			SetAsmGadgetAttrs(mainrei,udd->LastLV,NULL,GTLV_Selected,num,
													GTLV_MakeVisible,num,
													TAG_DONE);
		}
	}
}

/**************************************************************************************
 * void SetInterface(struct REI *mainrei, BOOL bool)
 **************************************************************************************
*/
void SetInterface(struct REI *mainrei, BOOL bool)
{
struct	MenuItem *mi;
struct	Window *wi = mainrei->rei_Window;
struct	UpDateData *udd = mainrei->rei_UserData;


	SetAsmGadgetAttrs(mainrei,NULL,BUT_INFOWB,GA_Disabled,bool,TAG_DONE);
	SetAsmGadgetAttrs(mainrei,NULL,BUT_UPDATE,GA_Disabled,bool,TAG_DONE);
	SetAsmGadgetAttrs(mainrei,NULL,BUT_RESCAN,GA_Disabled,bool,TAG_DONE);

	/* Indirizzo del Menu che voglio controllare */
	
	if(udd->autorescan)
	{	
		mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
														CITEM_AUTORESCAN,~0);
		mi->Flags |= CHECKED;		
	}
		
	if(udd->follow)
	{	
		mi = (struct MenuItem *)AS_MenuAddress(mainrei,CMENU_SETTINGS,
															CITEM_FOLLOW,~0);
		mi->Flags |= CHECKED;
	}
	
	if(bool)
	{
		OffMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_RESCAN,0));
		OffMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
		OffMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_UPDATE,0));
		OffMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
		
		OffMenu(wi,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
		OffMenu(wi,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_SYSTEMLIST,0));
	}
	else
	{	
		OnMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_RESCAN,0));
		OnMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_SETCOMMENT,0));
		OnMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_UPDATE,0));
		OnMenu(wi,FULLMENUNUM(CMENU_PROJECT,CITEM_DELETE,0));
		
		OnMenu(wi,FULLMENUNUM(CMENU_SPECIALINFO,CITEM_INFOWB,0));
		
		OnMenu(wi,FULLMENUNUM(CMENU_SETTINGS,CITEM_AUTORESCAN,0));
		OnMenu(wi,FULLMENUNUM(CMENU_SETTINGS,CITEM_FOLLOW,0));

		OnMenu(wi,FULLMENUNUM(CMENU_SETTINGS,CITEM_LOADSETTINGS,0));
		OnMenu(wi,FULLMENUNUM(CMENU_SETTINGS,CITEM_SAVESETTINGS,0));
	}	
}

/**************************************************************************************
 * InfoWB()
 **************************************************************************************
*/
void InfoWB(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;
struct Node *selnode;
BPTR lock;

	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,AGATLV_SelectedNode);	

	if(selnode)
	{
		RecoverFilename(selnode->ln_Name,udd->Error);
		
		lock = Lock(udd->CurrentDrawer,ACCESS_READ);
		if(!(WBInfo(lock,udd->Error,mainrei->rei_Screen)))
			WBInfoError(mainrei,udd->Error);
		
		UnLock(lock);
	}
}

/**************************************************************************************
 * SetCommentFile()
 **************************************************************************************
*/
void SetCommentFile(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;
struct Node *selnode;
BPTR   lock, oldlock;
ULONG  retval;
short  x;
char   tempbuf[80];

	selnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,AGATLV_SelectedNode);	

	if(selnode)
	{
		RecoverFilename(selnode->ln_Name,udd->Error);
		
		retval = ChoiceSetComment(mainrei,udd->Error);
		
		
		switch (retval)
		{
			case 1:
		
				lock = Lock(udd->CurrentDrawer,ACCESS_READ);
				oldlock = CurrentDir(lock);
		
				strncpy(tempbuf,selnode->ln_Name+30,60);
			
				if(!(SetComment(udd->Error,tempbuf)))
					SetCommentError(mainrei,udd->Error);
		
				CurrentDir(oldlock);
				UnLock(lock);	
				break;	

			case 2:
				LockREI(mainrei,NULL);
				for ( x=0;  x < udd->fr->rf_NumArgs;  x++ )	
				{
					if(!(SetComSel(mainrei,x)))
					{
						UnlockREI(mainrei,NULL);
							return(NULL);
					}	
				}
				UnlockREI(mainrei,NULL);
				break;
		}
	}
}

/**************************************************************************************
 * Rescan()
 **************************************************************************************
*/
void Rescan(struct REI *mainrei)
{
struct	UpDateData *udd = mainrei->rei_UserData;
struct	Node *tmpnode;
SHORT	x;
BPTR	res, oldlock, lock;
STRPTR	strinfo;

	if(udd->freelist2)
	{
		SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,GTLV_Labels,~0,TAG_DONE);
		FreeListName(udd->freelist2);
	}
	
	udd->freelist2 = AllocNewList();

	if(lock = Lock(udd->udd_DestDrawer,ACCESS_READ))
	{
		oldlock = CurrentDir(lock);

		for ( x=0;  x < udd->fr->rf_NumArgs;  x++ )	
		{	
			strinfo = AllocVec(STRING_LEN,MEMF_CLEAR);		
			tmpnode = AllocNode(udd->freelist2,strinfo,ASYSI_SYSTEM,NULL);
			
			if(!CheckFile(udd->frargs[x].wa_Name,NULL))
			{
				if(res = LoadSeg(udd->frargs[x].wa_Name))
				{
					if(!(Filling(res,udd->frargs[x].wa_Name,strinfo)))
						tmpnode->ln_Type = ASYSI_QUESTION;
					UnLoadSeg(res);
				}
				else	/* Errore, non ha funzionato LoadSeg() */
				{
					ObtainError(udd->Error);
					SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo);
					tmpnode->ln_Type = ASYSI_SELECTED;
				}
			}
			else
			{
				ObtainError(udd->Error);
				SoFill(udd->Error,udd->frargs[x].wa_Name,strinfo);
				tmpnode->ln_Type = ASYSI_QUESTION;
			}		
	   	}
	CurrentDir(oldlock);
   	UnLock(lock);
   	}
   	/*--- ora metto le liste ---*/
   	SetAsmGadgetAttrs(mainrei,NULL,LV_DESTFILES,GTLV_Labels,udd->freelist2,TAG_DONE);

	tmpnode = (struct Node *)GetAsmGadgetAttr(mainrei,udd->LastLV,NULL,
															AGATLV_SelectedNode);
		
	switch(tmpnode->ln_Type)
	{
		case ASYSI_QUESTION:
			ActiveStdMenuGad(mainrei, FALSE);
			break;

		case ASYSI_SYSTEM:
		case ASYSI_SELECTED:
			ActiveStdMenuGad(mainrei, TRUE);
			break;
	}
}

/**************************************************************************************
 * About()
 **************************************************************************************
*/
void About(struct REI *mainrei)
{
struct UpDateData *udd = mainrei->rei_UserData;
ULONG res;

	CAHook.h_Entry = ShowIInfo;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
						GetCatalogStr(catalog,MSG_ABOUT, "About..."),
							   AREQ_Object,udd->dto01,
							   AREQ_LockREI,mainrei,
							   AREQ_ReturnKey,TRUE,	
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_TextUnderObject,TRUE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,TRUE,
							   AREQ_ButtomHook,&CAHook,
							   TAG_DONE);
							   
	res = AsmRequestArgs(udd->areq, 
						 GetCatalogStr(catalog,MSG_DATAREL,
						 "UpDateResident Ver.4.1.5\n"
				         "Data Release (30.Jan.96)\n"
						 "Programmed by Giovambattista Fazioli\n"
						 "Beta-Tester and Docs by Marco Talamelli\n\n"
						 "PUBLIC DOMAIN VERSION\n\n"
						 "E-Mail: Giovanni@DSTU.dstelematica.dsnet.it\n"
						 " or   : Giovanni_Fazioli@amp.flashnet.it"
						 " or   : Marco_Talamelli@amp.flashnet.it"),
						 GetCatalogStr(catalog,MSG_DATARELGAD,
                         "_Info|_Continue"), 
                         NULL);
	
	/* Clear APTR dell'Hook dei pulsanti per altro uso dei AsmRequest */
	ChangeAsmReqAttrs(udd->areq, AREQ_ButtomHook,NULL,
							   TAG_DONE);                         					
}

/**************************************************************************************
* FileError(mainrei,udd->frargs[x].wa_Name);
 **************************************************************************************
*/
void FileError(struct REI *mainrei,STRPTR filename)
{
struct UpDateData *udd = mainrei->rei_UserData;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
						GetCatalogStr(catalog,MSG_WARNING,"Warning..."),
							   AREQ_Object,udd->dto03,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,TRUE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	AsmRequest(udd->areq,
					GetCatalogStr(catalog,MSG_FILEERROR, 
					"Can't load '%s'\n"
					"Error:%ld\n"
					"%s"),
					GetCatalogStr(catalog,MSG_UCONTINUE,
                    "_Continue"), 
                    filename,udd->NError,udd->Error);
}

/**************************************************************************************
 * WBInfoError(mainrei,&filename);
 **************************************************************************************
*/
void WBInfoError(struct REI *mainrei,STRPTR filename)
{
struct UpDateData *udd = mainrei->rei_UserData;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
					GetCatalogStr(catalog,MSG_WARNING,"Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,TRUE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	AsmRequest(udd->areq, GetCatalogStr(catalog, MSG_WBINFO,
						 "Can't get Information from Workbench\n"
						 "on Drawer '%s'\n"
						 "on file '%s'"),
                         GetCatalogStr(catalog, MSG_UCONTINUE, "_Continue"),
                         udd->CurrentDrawer,filename);
}

/**************************************************************************************
 * DeleteInfoError(mainrei,&filename);
 **************************************************************************************
*/
void DeleteInfoError(struct REI *mainrei,STRPTR filename)
{
struct	UpDateData *udd = mainrei->rei_UserData;
char	errore[80];

	ObtainError(errore);

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
					GetCatalogStr(catalog,MSG_WARNING,"Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,TRUE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	AsmRequest(udd->areq, GetCatalogStr(catalog, MSG_DELETEINFOERR,
						 "Can't Delete file\n"
						 "'%s/%s'\n\n"
						 "%s"),
                         GetCatalogStr(catalog, MSG_UCONTINUE, "_Continue"),
                         udd->CurrentDrawer,filename,errore);
}



/**************************************************************************************
 * DeleteInfo(mainrei,&filename);
 **************************************************************************************
*/
ULONG DeleteInfo(struct REI *mainrei,STRPTR filename)
{
struct	UpDateData *udd = mainrei->rei_UserData;
	
	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
					GetCatalogStr(catalog,MSG_WARNING,"Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,FALSE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	ULONG retval = AsmRequest(udd->areq, GetCatalogStr(catalog, MSG_DELETEINFO,
						 "Do you really want delete\n"
						 "'%s/%s' ?"),
                         GetCatalogStr(catalog, MSG_DELETEINFOGAD, "_Delete|_Abort"),
                         udd->CurrentDrawer,filename);

return(retval);
}

/**************************************************************************************
 * void SetCommentError(struct REI *mainrei,STRPTR filename)
 **************************************************************************************
*/
void SetCommentError(struct REI *mainrei,STRPTR filename)
{
struct UpDateData *udd = mainrei->rei_UserData;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
					GetCatalogStr(catalog,MSG_WARNING,"Warning..."),
							   AREQ_Object,udd->dto02,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,TRUE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	AsmRequest(udd->areq, GetCatalogStr(catalog, MSG_SETCOMERR,
						 "Can't set comment file\n"
						 "on Drawer '%s'\n"
						 "on file '%s'"),
                         GetCatalogStr(catalog, MSG_UCONTINUE, "_Continue"),
                         udd->CurrentDrawer,filename);
}


/**************************************************************************************
 * UpDateInfo(mainrei,&filename);
 **************************************************************************************
*/
ULONG UpDateInfo(struct REI *mainrei,STRPTR filename)
{
struct UpDateData *udd = mainrei->rei_UserData;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
							GetCatalogStr(catalog,MSG_UPDATING,"UpDating..."),
							   AREQ_Object,udd->dto04,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,FALSE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	ULONG retval = AsmRequest(udd->areq, 
						 GetCatalogStr(catalog,MSG_UPDATEINFO,
						 "Copy file(s) from 'Sources files' in 'Dest files'\n"
						 "it's Correct?\n"
						 "All data will be overwrite... make a choice please"),
						 GetCatalogStr(catalog,MSG_UPDATEINFOGAD,
                         "UpDate only '%s'|UpDate All|Cancel"), 
                         filename);
return(retval);
}


/**************************************************************************************
 * ChoiceSetComment(mainrei,&filename);
 **************************************************************************************
*/
ULONG ChoiceSetComment(struct REI *mainrei,STRPTR filename)
{
struct UpDateData *udd = mainrei->rei_UserData;

	ChangeAsmReqAttrs(udd->areq,AREQ_Title, 
							GetCatalogStr(catalog,MSG_SETCOMMENT,"Set Comment..."),
							   AREQ_Object,udd->dto04,
							   AREQ_LockREI,NULL,
							   AREQ_ReturnKey,FALSE,
							   AREQ_Justification, ASJ_LEFT,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,0,
							   AREQ_FrameOnly,FALSE,
							   TAG_DONE);
	
	ULONG retval = AsmRequest(udd->areq, 
						 GetCatalogStr(catalog,MSG_SETCOMMENTINFO,
						 "Write Version information on\n" 
						 "file's comment.\n"
						 "How many files must sets?\n"),
						 GetCatalogStr(catalog,MSG_SETCOMMENTGAD,
                         "Set Comment only '%s'|Set Comment All|Cancel"), 
                         filename);
return(retval);
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

/**************************************************************************************
 * GetDefToolsTypes() - Get one tools types and set the default if not found it.
 **************************************************************************************
*/
void GetDefToolsTypes(int argc, char **argv,STRPTR tools, STRPTR defvalue, STRPTR iname)
{
struct	DiskObject *dobj;
struct	WBStartup *wbs;
struct	WBArg *wbarg;
STRPTR	iiname;
BPTR	lock;
	
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
		CurrentDir(NULL);
		UnLock(lock);
		return(NULL);
	}	
		
	iiname = FindToolType(dobj->do_ToolTypes, tools);
	strcpy(iname,iiname);
	FreeDiskObject(dobj);
	CurrentDir(NULL);
	UnLock(lock);
}



VOID wbmain(wbmsg)
{
	main(NULL, (struct WBStartup *)wbmsg);
	exit(0);
}
