/**************************************************************************************
** CATALOG .CD/CT Define
***************************************************************************************
*/
/* Window Titles */

#define	MSG_WINDOWEFFECT    1
#define STRING_LEN	200				/* elementi nel LISTVIEW */

/**************************************************************************************
** Define del Catalogo...
***************************************************************************************
*/
#define	MSG_UCONTINUE	 	1
#define	MSG_CONTINUE		2
#define	MSG_CANCEL			3
#define	MSG_WARNING		 	4
#define	MSG_UPDATING		5
#define	MSG_ABOUT			6
#define MSG_SETCOMMENT		7

#define	MSG_UPDATEINFO	 	100
#define	MSG_UPDATEINFOGAD	101
#define	MSG_WBINFO		 	102
#define	MSG_FILEERROR	 	103
#define MSG_SETCOMERR		104
#define MSG_SETCOMMENTINFO	105
#define MSG_SETCOMMENTGAD   106
#define MSG_DELETEINFO		107
#define MSG_DELETEINFOGAD	108
#define MSG_DELETEINFOERR	109

#define	MSG_DATAREL			200
#define	MSG_DATARELGAD		201
#define	MSG_COPYS			300
#define	MSG_COPYSGAD		301
#define MSG_SETCOMS			350
#define MSG_SETCOMSGAD		351

#define	MSG_SELECT			400
#define	MSG_CHECK			401
#define	MSG_CHANGEDIR		402
#define	MSG_CHANGE			403

/**********************************************
** Gadget's name define
***********************************************/

#define	BUT_SCAN		"b01"
#define BUT_SCAN_CODE	0x1001
#define BUT_SYSTEMLIST	"b02"
#define BUT_INFOWB		"b03"
#define BUT_INFOWB_CODE 0x1003
#define BUT_UPDATE		"upd"
#define BUT_UPDATE_CODE 0x1004
#define BUT_QUIT		"quit"
#define BUT_QUIT_CODE   0x10ff	
#define BUT_COMPARETO	"b05"
#define BUT_COMPARETO_CODE 0x1005
#define BUT_RESCAN		"b06"
#define BUT_RESCAN_CODE 0x1006	
#define STR_COMPARETO	"str1"
#define STR_COMPARETO_CODE 0x1201
#define LV_SOURCEFILES	"lv1"
#define LV_SOURCEFILES_CODE 0x4001
#define LV_DESTFILES	"lv2"
#define LV_DESTFILES_CODE 0x4002

/**********************************************
** Menu's and Items and SubItems name define
***********************************************/
#define CMENU_PROJECT		0

#define CITEM_SCAN			0
#define CITEM_RESCAN		1
#define CITEM_SETCOMMENT	3
#define CITEM_DELETE		4
#define CITEM_UPDATE		5
#define CITEM_ICONIFY		7
#define CITEM_ABOUT			8
#define CITEM_QUIT			10

#define CMENU_SPECIALINFO	1
#define CITEM_INFOWB		0
#define CITEM_SYSTEMLIST	1

#define CMENU_DEFAULTDRAWER	2
#define CITEM_LIBRARIES		0
#define CITEM_DEVICES		1
#define CITEM_DATATYPES		2
#define CITEM_GADGETS		3
#define CITEM_IMAGES		4
#define CITEM_CODECS		5
#define CITEM_CLASSES		6

#define CMENU_SETTINGS		3
#define CITEM_AUTORESCAN	0
#define CITEM_FOLLOW		1
#define CITEM_SETFONTS		3
#define CITEM_LOADSETTINGS	5
#define CITEM_SAVESETTINGS	6

/**************************************************************************************
** MENU #define for .rei file
***************************************************************************************
*/

#define MENU_PROJECT	 1
#define ITEM_SCAN		 1
#define ITEM_RESCAN		 2
#define ITEM_SETCOM		 3
#define ITEM_DELETE		 4
#define ITEM_UPDATE		 5
#define ITEM_ICONIFY	 6
#define ITEM_ABOUT		 7
#define ITEM_QUIT		 8

#define MENU_SPECIALINFO 2
#define ITEM_INFOWB		 21

#define MENU_DEFDRAWER	 3
#define ITEM_LIBS		 31
#define ITEM_DEVS		 32
#define ITEM_DATA		 33
#define ITEM_GADS		 34
#define ITEM_IMGS		 35
#define ITEM_CODS		 36
#define ITEM_CLAS		 37

#define MENU_SETTINGS	 4
#define ITEM_AUTORESCAN	 41
#define ITEM_FOLLOW		 42
#define ITEM_SETFONT	 43
#define ITEM_LOADSETS	 44
#define ITEM_SAVESETS	 45

#define ITEM_VOID		 0


/**************************************************************************************
** Struttura data generali in rei_UserData
***************************************************************************************
*/
struct UpDateData {
	struct  Interface *udd_i;			/* Indirizzo dell'Interfaccia */
	char	udd_DestDrawer[108];		/* massima lunghezza per il Path di controllo*/ 
	char	udd_InitDrawer[108];		/* tiene traccia dell'ultima drawer selezio. */
	char	Error[100];					/* Stringa errore di apertura file */
	ULONG	NError;						/* Numero dell'errore */
	
	struct List *freelist;				/* liste dei LISTVIEW */
	struct List *freelist2;
	
	struct AsmGadget *LastLV;			/* Ultimo LISTVIEW rilasciato */
	struct AsmGadget *NoFocusLV;		/* L'altro non selezionato */
	STRPTR CurrentDrawer;				/* Dove chiedere WBInfo */
	
	struct FileRequester *fr;			/* File Requester */
	struct FileRequester *frDrawer;		/* cambio drawer */
	struct WBArg *frargs;
	
	struct AsmRequest *areq;			/* My AsmRequest... */
	Object *dto01;						/* Lista oggetti caricati... */
	Object *dto02;
	Object *dto03;	
	Object *dto04;
	
	struct TextAttr TextPrefs;			/* New Prefs aviable from $Ver:4.1 */
	char   udd_TextName[30];			/* segue il nome della Fonts */	

	ULONG  LeftTag;						/* My Tag special List */
	ULONG  LeftValue;
	ULONG  TopTag;
	ULONG  TopValue;
	ULONG  WidthTag;
	ULONG  WidthValue;
	ULONG  HeightTag;
	ULONG  HeightValue;
	ULONG  TagDone;
	char	autorescan;
	char	follow;
};

