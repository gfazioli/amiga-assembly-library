#ifndef ASSEMBLY_ASMINTUITION_H
#define ASSEMBLY_ASMINTUITION_H
/*
**    $VER: asmintuition.h 41.404 (07.8.95)
**    Includes Release 41.11
**
**    All Intuition, Gadtools and Requester are here.
**
**    (No) Copyrights, Public Domain Software
**            Nothing Rights Reserved
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_RASTPORT_H
#include <graphics/rastport.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

/* ======================================================================= */
/* === Interface ========================================================= */
/* ======================================================================= */
/* Questa struttura ritorna da OpenInterface() */

struct Interface {
    struct MinList int_MinList;
	STRPTR	int_IName;					/* Nome dell'interfaccia */
	STRPTR	int_Version;				/* Versione */
	STRPTR	int_Author;					/* Nome dell'autore */
	STRPTR	int_Address;				/* Address o E-Mail */
	STRPTR	int_Date;					/* Data di creazione */
	STRPTR	int_Comment;				/* stringa di commento... */
	ULONG	int_FORM;					/* FORM identificative */
	ULONG	int_REI0;					/* 'R','E','I',0x00  <-- Version */		
	UBYTE	int_reserved1[40];			/* future expansion... */
	STRPTR	int_CatalogName;			/* (STRPTR) opzionale... */
	struct  Catalog *int_Catalog;		/* (struct Catalog *) se aperto... */    
};

/* ======================================================================= */
/* === REIMessage ======================================================== */
/* ======================================================================= */
/* This is RESULT of WaitREIMsg() */

struct REIMessage {
	ULONG	rim_Class;
	UWORD	rim_Code;
	UWORD	rim_Qualifier;
	APTR	rim_IAddress;
	ULONG	rim_REICode;				/* Special REI return code */
};	

/*
** NEW (V41.2) - Special return code (new class) on rim_REICode
*/

#define RIM_SEEINTUITION	NULL		/* none to comunication... :) */

#define RIM_LEFTDOUBLECLICK		1		/* Left mousebutton DoubleClick */
#define RIM_RIGHTDOUBLECLICK	2		/* Right mousebutton DoubleClick */

/* ======================================================================= */
/* === REI =============================================================== */
/* ======================================================================= */
/* This structure is strictly READ ONLY */

struct REI {
    struct Node rei_Node;
    struct Screen *rei_Screen;
	struct Window *rei_Window;
	struct Menu   *rei_Menu;    
	struct TagItem *rei_STDWindowTAG;	/* Standar Window TagItem List */
	LONG   rei_VI;
	UBYTE  rei_reserved2[32];
	UWORD  rei_ID;
	BYTE   *rei_UserData;				/* general-purpose user data */

/*******CUT-CUT- Il resto della struttura è privato ************************/

	struct TagItem *rei_ScreenTAG;
	STRPTR rei_PubScreenName;	
	UWORD  rei_RemLeft; 	          /* Remember LeftEdge */
	UWORD  rei_RemTop;			      /* Remember TopEdge */
	LONG   rei_RemWidth;			  /* Remember Width */
	LONG   rei_RemHeight;		  	  /* Remember Height */
	LONG   rei_PropWidth;		  	  /* Gadget sensitive layout */
	LONG   rei_PropHeight;		  	  /* Gadget sensitive layout */
 	struct NewWindow rei_NewWindow; 
 	struct TagItem   *rei_NewWindowTAG;
	struct AsmGadget *rei_HEADAsmGadget;
	struct AsmGadget *rei_TAIL;
	struct AsmGadget *rei_TAILAsmGadget;
	struct NewMenu   *rei_NewMenu;
 	struct TagItem   *rei_NewMenuTAG;
 	struct Hook	 	 *rei_MenuHook;
 	struct TextAttr  *rei_GadgetTextAttr;
 	struct TextFont  *rei_GadgetFont;
 	struct Hook      *rei_LayoutCallBack;
 	struct Hook      *rei_CustomHook;
 	ULONG  rei_Flags;
	struct RastPort  *rei_rpGadget;
	struct Hook      *rei_OldHook;
	struct Gadget    *rei_glist;
	struct Requester rei_Request;
	struct REIMessage rei_REIMessage;
	ULONG  rei_LeftSeconds;				/* NEW (V41.2) for DoubleClick, myTimeVal */
	ULONG  rei_LeftMicros;
	ULONG  rei_RightSeconds;
	ULONG  rei_RightMicros;
};

/*
** TAGS for OpenREIA(), SetREIAttrsA() and GetREIAttrsA()
** Vedere le specifiche di ogni comando per essere sicuri che ogni Tags
** sia davvero supportato. Ad esempio REIT_FirstAsmGadget, è supportato
** solo da GetREIAttrsA(), e non da gli altri.
** (O|S|G) indica con quale comando un'attributo può essere utilizzato.
** (O) - OpenREIA()
** (S) - SetREIAttrsA()
** (G) - GetREIAttrsA()
*/

#define REIT_Base	        TAG_USER

#define REIT_Screen			REIT_Base+1		/* (O|G) (struct Screen *) */
#define REIT_WindowTAG		REIT_Base+2		/* (O|G) (struct TagItem *) */
#define REIT_ScreenTAG		REIT_Base+3		/* (O|G) (struct TagItem *) */
#define REIT_WindowTextAttr	REIT_Base+4		/* (O|G) (struct TextAttr *) */
#define REIT_WindowTextFont	REIT_Base+5		/* (O|G) (struct TextFont *) */
#define REIT_ScreenFont		REIT_Base+6		/* (O|G) (BOOL) */
#define REIT_NewMenu		REIT_Base+7		/* (O|G) (struct NewMenu *) */
#define REIT_NewMenuTAG		REIT_Base+8		/* (O|G) (struct TagItem *) */
#define REIT_UserData		REIT_Base+9		/* (O|S|G) (ULONG) */
#define REIT_LayoutCallBack	REIT_Base+10	/* (O|G) (struct Hook *) */
#define REIT_CustomHook		REIT_Base+11	/* (O|G) (struct Hook *) */
#define REIT_RememberPos	REIT_Base+12	/* (O|G) (BOOL) */
#define REIT_RememberSize	REIT_Base+13	/* (O|G) (BOOL) */
#define REIT_CenterHScreen	REIT_Base+14	/* (O|G) (BOOL) */
#define REIT_CenterVScreen	REIT_Base+15	/* (O|G) (BOOL) */
#define REIT_CenterMouse	REIT_Base+16	/* (O|G) (BOOL) */
#define REIT_NoFontSensitive	REIT_Base+17	/* (O|G) (BOOL) */
#define REIT_WindowTitle	REIT_Base+18	/* (O|S|G) (STRPTR) */
#define REIT_Window			REIT_Base+19	/* (O|G) (struct Window *) */

/* --- Special AsmGadget support --- */
#define REIT_FirstAsmGadget	REIT_Base+20	/* (G)	 (struct AsmGadget *) */
#define REIT_LastAsmGadget	REIT_Base+21	/* (G)	 (struct AsmGadget *) */
#define REIT_AsmGadgetHook	REIT_Base+22	/* (S|G) (struct TagItem *) */
#define REIT_AsmMenuHook	REIT_Base+23	/* (S|G) (struct TagItem *) */

/* --- Align a REI with a REI, Resize and Move a REI --- */
#define REIT_AlignLeft		REIT_Base+30	/* (S) (struct REI *) */
#define REIT_AlignTop		REIT_Base+31	/* (S) (struct REI *) */   
#define REIT_AlignRight		REIT_Base+32	/* (S) (struct REI *) */
#define REIT_AlignBottom	REIT_Base+33	/* (S) (struct REI *) */

/* --- NEW (V41.2) --- */
#define REIT_DoubleClick	REIT_Base+34	/* (O|S|G) (BOOL) */

/* ======================================================================= */
/* === AsmGadget ========================================================= */
/* ======================================================================= */
/* This structure is strictly READ ONLY */

struct AsmGadget {
	struct	Node agg_Node;
	ULONG	agg_Kind;
	struct	TagItem *agg_TagList;
	APTR	agg_UserData;				/* general-purpose user data */
/*** uso privato... */
    struct	NewGadget agg_NewGadget;		/* gadtools compatible */
    ULONG	agg_Flags;
    struct	Gadget *agg_Gadget;
 	struct	Gadget *agg_IGadget;
    WORD	agg_LeftEdge;
    WORD	agg_TopEdge;
    WORD	agg_Width;
	WORD	agg_Height;
	UWORD	agg_LabelWidth;
	UWORD	agg_LabelHeight;
	struct	Gadget *agg_XChild;
	struct	Gadget *agg_YChild;
	struct	Gadget *agg_InnerWidth;
	struct	Gadget *agg_InnerHeight;
};

/*--------------------------------------------------------------------------
* NEW KIND -- Qui vengono definiti questi KIND aggiuntivi, che si
* accodano a quelli della gadtools.library. Vedi AllocAsmGadget() per
* maggiori dettagli.
*------------------------------------------------------------------------ */

#define UPPERCASE_KIND		15
#define DECIMAL_KIND		16
#define HEXDECIMAL_KIND		17
#define BINARY_KIND			18

/*--------------------------------------------------------------------------
** TAGS for SetAsmGadgetAttrsA() and GetAsmGadgetAttr()
**------------------------------------------------------------------------*/
#define AGAT_Dummy	TAG_USER

#define AGAT_AsmGadgetHook	AGAT_Dummy+1	/* (struct Hook *) */

#define AGAT_RelBBottom		AGAT_Dummy+2	/* Booleani */
#define AGAT_RelBRight		AGAT_Dummy+3
#define AGAT_HCenter		AGAT_Dummy+4
#define AGAT_VCenter		AGAT_Dummy+5
#define AGAT_WindowWidth	AGAT_Dummy+6
#define AGAT_WindowHeight	AGAT_Dummy+7

#define AGAT_XChild			AGAT_Dummy+8	/* (struct AsmGadget *) */
#define AGAT_YChild			AGAT_Dummy+9
#define AGAT_HorzInner		AGAT_Dummy+10
#define AGAT_VertInner		AGAT_Dummy+11

#define AGAT_NextAsmGadget	AGAT_Dummy+12	/* (struct AsmGadget *) via Node */
#define AGAT_PrevAsmGadget	AGAT_Dummy+13

#define AGAT_UserData		AGAT_Dummy+14	/* user define... */
#define AGAT_AsmGadgetID	AGAT_Dummy+15
#define AGAT_HighLight		AGAT_Dummy+16	/* (S) */

#define AGATLV_SelectedNode	AGAT_Dummy+20	/* (struct Node *) for LV */



/*--------------------------------------------------------------------------
** System internal little images, for LISTVIEW CallBack routine
**------------------------------------------------------------------------*/
#define ASYSI_DEFAULT	0
#define ASYSI_TEXT		1
#define ASYSI_PICTURE	2
#define ASYSI_SOUND		3	
#define ASYSI_SYSTEM	4
#define ASYSI_DRAWER	5
#define ASYSI_SELECTED	6
#define ASYSI_NORMAL	7
#define ASYSI_QUESTION	8
#define ASYSI_WARNING	9
#define ASYSI_ALT		10
#define ASYSI_INPUT		11
#define ASYSI_GHOSTB	7
#define ASYSI_GHOST		(1<<ASYSI_GHOSTB)

/* ======================================================================= */
/* === AsmRequest ======================================================== */
/* ======================================================================= */
/*  La struttura che ritorna da AllocAsmRequestA() è di uso privato. */

struct AsmRequest {

 	/* all ##private */
}; 	

/*
** TAGS for AllocAsmRequestA()  and ChangeAsmReqAttrsA()
*/
#define AREQ_Base	TAG_USER

#define AREQ_Left				AREQ_Base+1
#define AREQ_Top				AREQ_Base+2
#define AREQ_REI				AREQ_Base+3
#define AREQ_Window				AREQ_Base+4
#define AREQ_Screen				AREQ_Base+5
#define AREQ_Title				AREQ_Base+6
#define AREQ_IDCMP				AREQ_Base+7
#define AREQ_IDCMPHook			AREQ_Base+8
#define AREQ_LockREI			AREQ_Base+9
#define AREQ_Justification		AREQ_Base+10
#define AREQ_Object				AREQ_Base+11
#define AREQ_Sound				AREQ_Base+12
#define AREQ_Reserved2			AREQ_Base+13
#define AREQ_Reserved3			AREQ_Base+14
#define AREQ_CenterHScreen		AREQ_Base+15
#define AREQ_CenterVScreen		AREQ_Base+16
#define AREQ_CenterMouse		AREQ_Base+17
#define AREQ_TextUnderObject	AREQ_Base+18
#define AREQ_APenPattern		AREQ_Base+19
#define AREQ_BPenPattern		AREQ_Base+20
#define AREQ_PubScreenName		AREQ_Base+21
#define AREQ_NewLookBackFill	AREQ_Base+22
#define AREQ_ReturnKey			AREQ_Base+23
#define AREQ_FrameOnly			AREQ_Base+24
#define AREQ_WindowFlags		AREQ_Base+25
#define AREQ_ButtomHook			AREQ_Base+26
 
#endif /* ASSEMBLY_ASMINTUITION_H */
