***************************************************************************************
* file - REI - main REI file support commands
*
* Table of CONTENTS
*
* CallBackLV		   - PRIVATE USE ONLY -- Custom CallBack for ListView gadgets
* NewGetVisualInfo()	   - PRIVATE USE
* OpenREIA()       	   - New - modificato (old DisplayREIA())
* EraseInternalRect()	   - New
* LayoutAsmGadget()        - PRIVATE USE
* NewFreeVisualInfo()	   - PRIVATE USE
* GetSystemHook()	   - PRIVATE USE
* CloseREI()		   - New - modificato (old FreeDisplayREI())
* ActiveREI()		   - Ok
* LockREI()		   - Ok - modificato
* UnlockREI()		   - Ok	- modificato
* RefreshREI()		   - Da rifare...
* InterfaceInfo()	   - New
* LoadNewDTObjectA()	   - PRIVATE USE ONLY
* SetREIAttrsA()	   - Ok - da controllare
* GetREIAttrsA()	   - Ok
*
***************************************************************************************

***************************************************************************************
* CallBack Hook for ListView... (a0 = Hook, a1 = LVDrawMsg, a2 = Node)
***************************************************************************************
CallBackLVHook
	ds.b MLN_SIZE
	dc.l _CallBackLV,0,0
_CallBackLV
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a1,a4				* A4 = (struct LVdrawMsg *)
	move.l	a2,a3				* A3 = (struct Node *)
	move.l	h_Data(a0),a5			* A5 = AssemblyBase
	cmpi.l	#LV_DRAW,lvdm_MethodID(a4)
	beq.s	CB_Draw
	moveq	#LVCB_UNKNOWN,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
CB_Draw	move.l	([lvdm_DrawInfo.w,a4],dri_Pens.w),a0	* DrawInfo->dri_Pens
	move.w	HIGHLIGHTTEXTPEN*2(a0),d6		* apen
	move.w	FILLPEN*2(a0),d7			* bpen
	move.l	lvdm_State(a4),d2			* LVR_NORMAL check...
	beq.s	CB_SPEN
	subq.l	#LVR_NORMALDISABLED,d2
	bne.s	CB_Pens
;--------------------------------------------------------------------------------------
CB_SPEN	move.w	TEXTPEN*2(a0),d6			* apen
	move.w	BACKGROUNDPEN*2(a0),d7			* bpen
;--------------------------------------------------------------------------------------
CB_Pens	swap	d6					* Clear space for image...
	move.b	LN_TYPE(a3),d6
	andi.b	#~ASYSI_GHOST,d6
	beq.s	ContFit
	move.w	#STDIM_WIDTH,d6				* Standar Offset
ContFit	move.l	LN_NAME(a3),a0				* Prendo il Nome
	STRLEN	a0,d0					* Calcolo la lunghezza...
	move.l	lvdm_RastPort(a4),a1			* RastPort
	lea	-te_SIZEOF(sp),sp			* struct TextExtent on Stack
	move.l	sp,a2
	move.l	a3,d4
	suba.l	a3,a3
	moveq	#1,d1
	move.w	lvdm_Bounds+ra_MaxX(a4),d2
	sub.w	lvdm_Bounds+ra_MinX(a4),d2
	sub.w	d6,d2
	subq.w	#3,d2
	move.w	lvdm_Bounds+ra_MaxY(a4),d3
	sub.w	lvdm_Bounds+ra_MinY(a4),d3
	addq.w	#1,d3
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOTextFit(a6)
;--------------------------------------------------------------------------------------
	move.l	d4,a3
	move.l	d0,d4					* fit
	sub.w	te_Extent+ra_MaxY(a2),d3		* Calculatin slack center...
	add.w	te_Extent+ra_MinY(a2),d3
	asr.w	#1,d3					* D3 = ((slack+1)>>1)
	move.w	lvdm_Bounds+ra_MinX(a4),d5		* x
	sub.w	te_Extent+ra_MinX(a2),d5
	addq.w	#2,d5
	add.w	d6,d5					* D5.w = x
	swap	d6
	swap	d5
	move.w	lvdm_Bounds+ra_MinY(a4),d5		* y
	sub.w	te_Extent+ra_MinY(a2),d5
	add.w	d3,d5					* D5.W = y
	add.w	d5,te_Extent+ra_MinY(a2)		* extent.te_Extent.MinY += y;
	add.w	d5,te_Extent+ra_MaxY(a2)		* extent.te_Extent.MaxY += y;
	swap	d5
	add.w	d5,te_Extent+ra_MinX(a2)		* extent.te_Extent.MinX += x;
	add.w	d5,te_Extent+ra_MaxX(a2)		* extent.te_Extent.MaxX += x;
	move.l	lvdm_RastPort(a4),a1			* RastPort
	move.l	d7,d0					* SetAPen(rp,bpen);
	jsr	_LVOSetAPen(a6)
	move.l	lvdm_RastPort(a4),a1			* FillOldExtent()
	movem.w	lvdm_Bounds+ra_MinX(a4),d0-d3
	move.w	d4,-(sp)				* Save D4 Temporaneamente...
	moveq	#0,d4
	move.l	d4,a0
	jsr	_LVOBltPattern(a6)
	move.w	(sp)+,d4				* Recupero D4 = fit
	move.l	lvdm_RastPort(a4),a1			* RastPort
	move.w	d6,d0					* apen
	ext.l	d0
	move.l	d7,d1					* bpen
	moveq	#RP_JAM2,d2
	jsr	_LVOSetABPenDrMd(a6)
	move.l	lvdm_RastPort(a4),a1			* RastPort
	swap	d5
;--------------------------------------------------------------------------------------
	move.l	d5,rp_cp_x(a1)				****************************
	ori.w	#RPF_FRST_DOT,rp_Flags(a1)	 	**  SPECIAL MOVE Replace  **
	move.b	#$F,rp_linpatcnt(a1)	   		****************************	
;--------------------------------------------------------------------------------------
	move.l	LN_NAME(a3),a0
	move.l	d4,d0
	jsr	_LVOText(a6)
	moveq	#0,d0
	move.b	LN_TYPE(a3),d0
	andi.b	#~ASYSI_GHOST,d0
	beq.s	NoImage
	swap	d6
	move.l	lvdm_RastPort(a4),a0			* RastPort
	lea	TableImage,a1
	move.l	(a1,d0.w*4),d0
	beq.s	NoImage
	move.l	d0,a1
	move.w	d5,d1
	move.w	rp_TxBaseline(a0),d0
	asr.w	#1,d0
	addq.w	#4,d0
	sub.w	d0,d1
	swap	d5
	move.w	d5,d0
	sub.w	d6,d0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVODrawImage(a6)	
	
NoImage	move.l	lvdm_State(a4),d2			* LVR_NORMAL check...
	subq.l	#LVR_NORMALDISABLED,d2
	beq.s	MKGhost
	subq.l	#(LVR_SELECTEDDISABLED-LVR_NORMALDISABLED),d2
	beq.s	MKGhost
	btst	#ASYSI_GHOSTB,LN_TYPE(a3)		* Is it in Ghost Mode??
	beq.s	SafExt
;--------------------------------------------------------------------------------------	
MKGhost	move.l	lvdm_RastPort(a4),a1		* Questa è la routine che esegue
	move.l	([lvdm_DrawInfo.w,a4],dri_Pens.w),a0	* il Ghosting di un'elemento
	move.w	BACKGROUNDPEN*2(a0),d0			* apen
	moveq	#0,d1
	moveq	#RP_JAM1,d2
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOSetABPenDrMd(a6)
	lea	GhostPattern(pc),a0
	move.l	lvdm_RastPort(a4),a1
	move.l	a0,rp_AreaPtrn(a1)
	move.b	#1,rp_AreaPtSz(a1)
	movem.w	lvdm_Bounds+ra_MinX(a4),d0-d3
	moveq	#0,d4
	move.l	d4,a0
	jsr	_LVOBltPattern(a6)
	moveq	#0,d0
	move.l	lvdm_RastPort(a4),a1
	move.l	d0,rp_AreaPtrn(a1)		* Annulla il Patterns...
	move.b	d0,rp_AreaPtSz(a1)
;--------------------------------------------------------------------------------------	
SafExt	lea	te_SIZEOF(sp),sp			* Reset Stack...
	moveq	#LVCB_OK,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
GhostPattern
	dc.l $44441111				* Standar AmigaGhosting...
;--------------------------------------------------------------------------------------





***************************************************************************************
** USO INTERNO
**
** Questo è il rifacimento del comando gadtools/GetVisualInfo.
**
** vi = NewGetVisualInfo (Screen, taglist)
**                          A0       A1
**
** STRUCTURE VisualInfo,0
**	APTR 	vi_Screen
**	APTR 	vi_TextFont
**	APTR 	vi_DrawInfo
**      APTR 	vi_reserved
**	UBYTE	vi_APen
**	UBYTE	vi_BPen
**
**	LABEL	vi_SIZEOF
**
***************************************************************************************
NewGetVisualInfo
	movem.l	d2/a3-a6,-(sp)
	move.l	a6,a5			* Save asmbase
	move.l	a0,d0
	beq	VIError
	move.l	d0,a4			* Save ScreenPtr
	moveq	#4+vi_SIZEOF,d0		* vi_SIZEOF
	move.l	d0,d2
	moveq	#1,d1
	swap	d1
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	GExit
	move.l	d0,a3			* A3 struct vi *
	move.l	d2,(a3)+		* PAck AllocMem
	move.l	a4,vi_Screen(a3)	* Save Screen 
	move.l	sc_Font(a4),a0
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOOpenFont(a6)
	tst.l	d0
	beq	VIError
	move.l	d0,vi_TextFont(a3)	* Save Font (struct TextFont *)
	move.l	a4,a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOGetScreenDrawInfo(a6)
	tst.l	d0
	beq	VIError
	move.l	d0,vi_DrawInfo(a3)
	move.l	d0,a0
	move.w	([dri_Pens.w,a0],4.w),d1
	move.b	d1,vi_APen(a3)
	move.w	([dri_Pens.w,a0],$E.w),d1
	move.b	d1,vi_BPen(a3)
	move.l	a3,d0
GExit	movem.l	(sp)+,d2/a3-a6
	rts	

***************************************************************************************
* (25-Jan-1995) =Jon= ** rei = OpenREIA(rei, name, taglist) (a0/a1/a2)
***************************************************************************************
TagReiTable
	dc.l SRE_ESR	* Offset...
	dc.l INITScreen,INITWindowTAG,INITScreenTAG,INITGadgetTextAttr
	dc.l INITEmpty,INITEmpty,INITNewMenu,INITNewMenuTAG
	dc.l INITUserData,INITLayoutCallBack,INITCustomHook
	dc.l INITRememberPos,INITRememberSize,INITCenterHScreen,INITCenterVScreen
	dc.l INITCenterMouse,INITNoFontSensitive,INITWindowTitle,INITWindow
	dc.l INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty
	dc.l INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty,INITEmpty
	dc.l INITDoubleClick
_LVOOpenREIA
	movem.l	d2-d6/a2-a6,-(sp)	
	move.l	a6,a5			* Save AsmBase
	move.l	a0,d0			* E' stata inserita una REI??
	bne.s	SRE_FND			* Ok, allora non cercarla tramite il nome...
	move.l	a1,d0			* se è stato inserito un nome NULL
	beq.s	SRE_ESR			* esci...
	move.l	ab_ExecBase(a5),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),a0	* struct MinList *
	move.l	a0,d0
	beq.s	SRE_ESR
	FINDNAME	
	move.l	d0,a4			* (struct REI *) in A4
	move.l	a4,d0			* Check...	
	bne.s	SRE_FND			* Ok, nome e node trovati... continua...
SRE_ESR	movem.l	(sp)+,d2-d6/a2-a6	* Niente, esci e basta
	rts
;--------------------------------------------------------------------------------------					
SRE_FND	move.l	d0,a4			* QUESTA REI SEMPRE IN A4
	moveq	#0,d0
	BTSTL	REIB_OPENCLOSE,rei_Flags(a4)
	bne.s	SRE_ESR
	move.l	a2,a0			* TagItem in A1...
	move.l	a0,d0			* C'è una TagItem list??
	beq	REIMain
;--------------------------------------------------------------------------------------
; Questa parte, inizializza una struttura REI tramite una TagList.
;--------------------------------------------------------------------------------------
TI_TAG	USETAGLIST.l	TagReiTable(pc),GO_TAG,REIMain
;--------------------------------------------------------------------------------------
INITScreen
	move.l	(a0)+,rei_Screen(a4)
	bra.s	GO_TAG
;--------------------------------------------------------------------------------------
INITWindowTAG
	move.l	(a0)+,rei_NewWindowTAG(a4)
	bra.s	GO_TAG
;--------------------------------------------------------------------------------------
INITScreenTAG
	move.l	(a0)+,rei_ScreenTAG(a4)
	bra.s	GO_TAG
;--------------------------------------------------------------------------------------
INITGadgetTextAttr
	move.l	(a0)+,rei_GadgetTextAttr(a4)
	bra.s	GO_TAG
;--------------------------------------------------------------------------------------
INITNewMenu
	move.l	(a0)+,rei_NewMenu(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITNewMenuTAG
	move.l	(a0)+,rei_NewMenuTAG(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITUserData
	move.l	(a0)+,rei_UserData(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITLayoutCallBack
	move.l	(a0)+,rei_LayoutCallBack(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITCustomHook
	move.l	(a0)+,rei_CustomHook(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITRememberPos	
	move.l	(a0)+,d0
	bne.s	RPFSET
	BCLRL	REIB_REMEMBERPOS,rei_Flags(a4)
	bra	GO_TAG
RPFSET	BSETL	REIB_REMEMBERPOS,rei_Flags(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITRememberSize	
	move.l	(a0)+,d0
	bne.s	RSFSET
	BCLRL	REIB_REMEMBERSIZE,rei_Flags(a4)
	bra	GO_TAG
RSFSET	BSETL	REIB_REMEMBERSIZE,rei_Flags(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITCenterHScreen	
	move.l	(a0)+,d0
	bne.s	CHFSET
	BCLRL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	GO_TAG
CHFSET	BSETL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITCenterVScreen	
	move.l	(a0)+,d0
	bne.s	CVFSET
	BCLRL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	GO_TAG
CVFSET	BSETL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITCenterMouse
	move.l	(a0)+,d0
	bne.s	CMFSET
	BCLRL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	GO_TAG
CMFSET	BSETL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	GO_TAG	
;--------------------------------------------------------------------------------------
INITNoFontSensitive
	move.l	(a0)+,d0
	bne.s	NFFSET
	BCLRL	REIB_NOFONTSENSITIVE,rei_Flags(a4)
	bra	GO_TAG
NFFSET	BSETL	REIB_NOFONTSENSITIVE,rei_Flags(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITWindowTitle
	move.l	(a0)+,rei_NewWindow+nw_Title(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITWindow
	move.l	(a0)+,d0
	beq	GO_TAG
	move.l	d0,a0
	move.l	wd_WScreen(a0),rei_Screen(a4)
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITEmpty
	addq.w	#4,a0
	bra	GO_TAG
;--------------------------------------------------------------------------------------
INITDoubleClick
	move.l	(a0)+,d0
	bne.s	DCFSET
	BCLRL	REIB_DOUBLECLICK,rei_Flags(a4)
	bra	GO_TAG
DCFSET	BSETL	REIB_DOUBLECLICK,rei_Flags(a4)
	bra	GO_TAG
	
;--------------------------------------------------------------------------------------
; Si comincia... questa è la parte del codice vero e proprio.
;--------------------------------------------------------------------------------------
REIMain	move.l	ab_IntuiBase(a5),a6	* Get Intuition for now...
	move.l	rei_Screen(a4),d0	* (struct Screen *)
	bne.s	SRE_GAI			* Get All Infos...
	move.l	rei_ScreenTAG(a4),d0
	beq.s	SRE_PUB			* Vediamo il pubblico quale è, allora
	move.l	d0,a1
	suba.l	a0,a0
	jsr	_LVOOpenScreenTagList(a6)	* Apriamo quindi un CustomScreen
	tst.l	d0				* NULL pointer??
	beq	SRE_EX2				* Exit... error
	move.l	d0,rei_Screen(a4)		* Apriti qua!
	bra.s	SRE_GAI	
SRE_PUB	move.l	rei_PubScreenName(a4),a0
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,a3
	suba.l	a0,a0
	move.l	a3,a1
	jsr	_LVOUnlockPubScreen(a6)
	move.l	a3,d0
;--------------------------------------------------------------------------------------
; Questa parte, potrebbe variare in future versioni del sistema, in quanto dato che noi 
; adesso conosciamo la struttura visual info, ci prendiamo solo questa, chiamando tra 
; l'altro, una routine privata. Prendiamo quindi questo, VisualInfo.
;--------------------------------------------------------------------------------------
SRE_GAI	move.l	d0,rei_Screen(a4)	* Save...
	move.l	d0,a0			* Screen pointer (struct Screen *)
	move.l	a5,a6			* AsmBase...
	bsr	NewGetVisualInfo	* Prende...
	move.l	d0,rei_VI(a4)		* Salva...
;--------------------------------------------------------------------------------------
; Inizializzo la NewWindow inserendo le infos relative allo schermo su cui si aprirà.
;--------------------------------------------------------------------------------------
	move.l	rei_Screen(a4),a0		* A0 = Screen
	move.w	sc_Flags(a0),d0			* D0 = Flags
	andi.w	#SCREENTYPE,d0			* D0 = Type of Screen
	move.l	a0,rei_NewWindow+nw_Screen(a4)	* Pointer to Screen
	move.w	d0,rei_NewWindow+nw_Type(a4)	* Type!!
;--------------------------------------------------------------------------------------
	jsr	_LVOAllocRastPort		* Alloco una RastPort fittizia per
	tst.l	d0
	beq	SRE_FREEINFOS
	move.l	d0,rei_rpGadget(a4)		* calcolare pos/size dei Gadget...
	move.l	ab_GfxBase(a5),a6
	move.l	rei_Screen(a4),a0
	lea	sc_RastPort(a0),a0
	move.l	rp_Font(a0),rei_GadgetFont(a4)	* Screen TextFont - Default
	move.l	rei_GadgetTextAttr(a4),d0	* Custom TextAttr Font for Gadget??
	beq.s	NOFONT				* Niente, proseguii...
	move.l	d0,a0
	jsr	_LVOOpenFont(a6)		* 
	move.l	d0,rei_GadgetFont(a4)		* Salva comunque, anche se NULL...
;--------------------------------------------------------------------------------------
; Il CreateContex() viene sempre fatta, e prima di Aprire la Window.
;--------------------------------------------------------------------------------------
NOFONT	move.l	rei_GadgetFont(a4),a0
	move.l	rei_rpGadget(a4),a1
	jsr	_LVOSetFont(a6)
	
	lea	rei_glist(a4),a0	* glist pointer for CreateContex()
	move.l	ab_GadToolsBase(a5),a6	* glist = prevGad
	jsr	_LVOCreateContext(a6)	* Già ha in A6 la GadToolsBase
;--------------------------------------------------------------------------------------
	move.l	rei_Screen(a4),a0
	move.l	rei_rpGadget(a4),a1
	BTSTL	REIB_REMEMBERSIZE,rei_Flags(a4)
	beq.s	NoRSize
	movem.l	rei_RemWidth(a4),d2-d3
	tst.l	d2
	bne.s	FontSen
;--------------------------------------------------------------------------------------
NoRSize	BTSTL	REIB_NOFONTSENSITIVE,rei_Flags(a4)
	bne.s	UnderS			* Coordinate standar
	move.l	rei_PropWidth(a4),d2
	move.l	rei_PropHeight(a4),d3
FontSen	move.w	rp_TxWidth(a1),d0
	move.w	rp_TxHeight(a1),d1
	move.w	d2,d4
	swap	d2
	mulu.w	d2,d0
	add.w	d4,d0
	move.w	d3,d4
	swap	d3
	mulu.w	d3,d1
	add.w	d4,d1
	movem.w	d0-d1,rei_NewWindow+nw_Width(a4)

;-------movem.w	rei_NewWindow+nw_MinWidth(a4),d0-d1
;-------mulu.w	rp_TxWidth(a1),d0
;-------mulu.w	rp_TxHeight(a1),d1
	
	movem.w	d0-d1,rei_NewWindow+nw_MinWidth(a4)
;--------------------------------------------------------------------------------------
; Vediamo se esiste il Flags, per centrare la Window Rispetto allo Schermo.
;--------------------------------------------------------------------------------------
UnderS	BTSTL	REIB_UNDERSCREEN,rei_Flags(a4)
	beq.s	Center
	move.l	d0,rei_NewWindow+nw_LeftEdge(a4)	* Parti da qua, sotto lo Screen
	movem.w	([rei_Screen.w,a4],sc_Width.w),d1-d2	* Larg. e Alt. dello schermo
	sub.w	d0,d2
	movem.w d1-d2,rei_NewWindow+nw_Width(a4)	
	bra	OPENWSO	
Center	BTSTL	REIB_REMEMBERPOS,rei_Flags(a4)
	beq.s	NoRem
	movem.w	rei_RemLeft(a4),d0-d1
	movem.w	d0-d1,rei_NewWindow+nw_LeftEdge(a4)
	bra.s	OpenWin
NoRem	BTSTL	REIB_CENTERHSCREEN,rei_Flags(a4)
	beq.s	ReiCenV	
	move.w	([rei_Screen.w,a4],sc_Width.w),d0
	sub.w	rei_NewWindow+nw_Width(a4),d0
	asr.w	#1,d0
	move.w	d0,rei_NewWindow+nw_LeftEdge(a4)
ReiCenV	BTSTL	REIB_CENTERVSCREEN,rei_Flags(a4)
	beq.s	FLMouse
	move.w	([rei_Screen.w,a4],sc_Height.w),d0
	sub.w	rei_NewWindow+nw_Height(a4),d0
	asr.w	#1,d0
	move.w	d0,rei_NewWindow+nw_TopEdge(a4)
FLMouse	BTSTL	REIB_CENTERMOUSE,rei_Flags(a4)
	beq.s	OpenWin
	movem.w	([rei_Screen.w,a4],sc_MouseY.w),d0-d1
	exg.l	d0,d1
	movem.w	rei_NewWindow+nw_Width(a4),d2-d3
	asr.w	#1,d2
	asr.w	#1,d3
	sub.w	d2,d0
	bge.s	FLOk01
	moveq	#0,d0	
FLOk01	sub.w	d3,d1
	bge.s	FLSave
	moveq	#0,d1
FLSave	movem.w	d0-d1,rei_NewWindow+nw_LeftEdge(a4)
;--------------------------------------------------------------------------------------
OpenWin	lea	rei_NewWindow(a4),a0		* NewWindow Structure
	move.l	rei_STDWindowTAG(a4),d0		* Get Standar Window TagItem List
	move.l	d0,a1
	beq	OPENWSO
	tst.l	rei_NewWindowTAG(a4)		* Esiste un'estensione personale?
	beq	OPENOOO
;--------------------------------------------------------------------------------------
	move.l	rei_NewWindowTAG(a4),a1		* Extra...
;----	move.l	a1,a0
;----	move.l	#WA_Width,d1
;----	FINDTAG	
;----	beq.s	SFIW
;----	move.l	4(a0),d4			* Vuole una nuova Width

SFIW	move.l	a1,a0				* reset Tag_Item list
	move.l	#WA_InnerWidth,d1
	FINDTAG	
	beq.s	SFIH
	move.l	4(a0),d4			* Vuole una nuova InnerWidth
;SFH	move.l	a1,a0
;----	move.l	#WA_Height,d1
;----	FINDTAG	
;----	beq.s	SFIH
;----	move.l	4(a0),d5			* Vuole una nuova Height

SFIH	move.l	a1,a0
	move.l	#WA_InnerHeight,d1
	FINDTAG	
	beq.s	ENDSER
	move.l	4(a0),d5			* Vuole una nuova InnerHeight

ENDSER	lea	rei_NewWindow(a4),a0		* NewWindow Structure
	move.l	rei_STDWindowTAG(a4),d0		* Get Standar Window TagItem List
	move.l	d0,a1
	movem.w	d4-d5,nw_Width(a0)
;--------------------------------------------------------------------------------------	
OPENOOO	move.w	nw_Width(a0),6(a1)
	move.w	nw_Height(a0),14(a1)	
	move.l	rei_NewWindowTAG(a4),28(a1)	* TAG_MORE			
;--------------------------------------------------------------------------------------
OPENWSO	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOOpenWindowTagList(a6)
	tst.l	d0				* Some error??
	beq	SRE_FREEFONT			* Then Exit
	move.l	d0,rei_Window(a4)		* Save Pointer in REI
	move.l	d0,a0
	move.l	a4,wd_UserData(a0)		* Put Addr of this REI
;--------------------------------------------------------------------------------------
	move.l	rei_LayoutCallBack(a4),d0	* CallBack Hook
	beq	SRECOX
	move.l	d0,a1
	move.l	([rei_Window.w,a4],wd_RPort.w),a0
	move.l	rp_Layer(a0),a0			* Layer
	move.l	ab_LayersBase(a5),a6
	jsr	_LVOInstallLayerHook(a6)
	move.l	d0,rei_OldHook(a4)
	move.l	rei_Window(a4),a0		* Window
	move.l	a5,a6				* AsmBase
	pea	SRECOX(pc)
***************************************************************************************
* (22-Feb-1995) --- EraseInternalRect(window) (A0)
***************************************************************************************
_LVOEraseInternalRect
	movem.l	d2-d6/a2-a6,-(sp)
	movem.w	ClearREI(pc),d0-d5
	move.b	wd_BorderLeft(a0),d0		* xmin
	move.b	wd_BorderTop(a0),d1		* ymin
	move.b	wd_BorderRight(a0),d4
	move.b	wd_BorderBottom(a0),d5
	movem.w	wd_Width(a0),d2-d3
	sub.w	d4,d2				* xmax
	sub.w	d5,d3				* ymax
	subq.w	#1,d2
	subq.w	#1,d3
	move.l	wd_RPort(a0),a1			* RastPort
	move.l	rp_Layer(a1),d4			* Layer
	beq.s	EIRNLay
	move.l	a6,a4				* Save AsmBase
	move.l	d4,a5				* A5 = Layer
	move.l	ab_GfxBase(a4),a6	
	jsr	_LVOLockLayerRom(a6)
	move.l	lr_BackFill(a5),a0
	movem.w	d0-d3,-(sp)
	move.l	sp,a2
	move.l	ab_LayersBase(a4),a6
	jsr	_LVODoHookClipRects(a6)
	addq.w	#8,sp
	move.l	ab_GfxBase(a4),a6
	jsr	_LVOUnlockLayerRom(a6)
	movem.l	(sp)+,d2-d6/a2-a6
	rts
EIRNLay	move.l	a1,a0
	sub.w	d0,d2
	addq.w	#1,d2
	move.w	d2,d4
	move.w	d0,d2
	sub.w	d1,d3
	addq.w	#1,d3
	move.w	d3,d5
	move.w	d1,d3
	moveq	#0,d6
	move.l	ab_GfxBase(a4),a6
	jsr	_LVOClipBlit(a6)
	movem.l	(sp)+,d2-d6/a2-a6
	rts
;--------------------------------------------------------------------------------------
SRECOX	move.l	([rei_HEADAsmGadget.w,a4]),d0	* HEAD / TAIL
	beq.s	AddGad			* Addiziona CreateContex() comunque e sempre
	move.l	rei_glist(a4),a2	* PrevGadget
	move.l	rei_HEADAsmGadget(a4),a3	* A3 = 1mo Node AsmGadget...
	move.l	a5,a6
	bsr	LayoutAsmGList		* A4=REI, A3=AsmGList, A2=PrevGadget
;--------------------------------------------------------------------------------------
AddGad	move.l	rei_Window(a4),a0	* Come si vede, il PrevGad viene sempre
	move.l	rei_glist(a4),a1	* addizionato alla Window, anche se non sono
	moveq	#-1,d0			* presenti strutture AsmGadget.
	moveq	#-1,d1
	suba.l	a2,a2
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOAddGList(a6)
	move.l	rei_glist(a4),a0	* Rinfresca tutti i Gadgets addizionati
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	moveq	#-1,d0
	jsr	_LVORefreshGList(a6)
	move.l	ab_GadToolsBase(a5),a6
	move.l	rei_Window(a4),a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)	
;--------------------------------------------------------------------------------------
; Attacco Menu...
;--------------------------------------------------------------------------------------
SRE_MNU	move.l	rei_NewMenu(a4),d0	* Ci sono Menu?
	beq.s	CU_HOOK			* CustomHook...
	move.l	d0,a0
	move.l	rei_NewMenuTAG(a4),a1
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOCreateMenusA(a6)
	move.l	d0,rei_Menu(a4)
	move.l	d0,a0
	move.l	rei_VI(a4),a1
	suba.l	a2,a2
	jsr	_LVOLayoutMenusA(a6)
	move.l	rei_Window(a4),a0
	move.l	rei_Menu(a4),a1
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOSetMenuStrip(a6)
;--------------------------------------------------------------------------------------
; Invoca se presente, in CustomHook...
;--------------------------------------------------------------------------------------
CU_HOOK	move.l	rei_CustomHook(a4),d0
	beq.s	SRE_ASL
	move.l	d0,a0
	suba.l	a1,a1
	move.l	rei_Window(a4),a2
	move.l	a5,a6
	move.l	h_Entry(a0),a3
	jsr	(a3)
;--------------------------------------------------------------------------------------
; Asl... future implement - Non è supportato al momento.
;--------------------------------------------------------------------------------------
SRE_ASL	
*	move.l	rei_AslSupport(a4),d0
*	beq.s	SRE_PEX	
;--------------------------------------------------------------------------------------
; Bring front screen if REIF_REQUEST is setting...
;--------------------------------------------------------------------------------------
	BTSTL	REIB_REQUEST,rei_Flags(a4)
	beq.s	SRE_PEX
	move.l	ab_IntuiBase(a5),a6
	move.l	rei_Screen(a4),a0
	jsr	_LVOScreenToFront(a6)
SRE_PEX	BSETL	REIB_OPENCLOSE,rei_Flags(a4)		* This REI is OPEN
	move.l	a4,d0					* Exit All OK... D0 = REI
SRE_EXT	movem.l	(sp)+,d2-d6/a2-a6
	rts
ClearREI	ds.l 8
;--------------------------------------------------------------------------------------
; Queste sono le uscite, in caso di errore... in teoria non dovrebbero mai essere
; usate, anzi, più avanti dovrebbero essere inseriti dei DisplayAlert() in grado di
; fornire più informazioni al programmatore.
;--------------------------------------------------------------------------------------
SRE_FREEGADGETS
	move.l	rei_glist(a4),a0	* = CreateContex()
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOFreeGadgets(a6)
SRE_FREEFONT
	move.l	rei_GadgetTextAttr(a4),d0
	beq.s	NoFOP
	move.l	ab_GfxBase(a5),a6
	move.l	d0,a1
	jsr	_LVOCloseFont(a6)
NoFOP	move.l	ab_ExecBase(a5),a6
	move.l	rei_rpGadget(a4),a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
SRE_FREEINFOS				* Free VI & DrawInfo
	move.l	rei_VI(a4),a0
	move.l	a5,a6
	bsr	NewFreeVisualInfo
SRE_CLOSESCREEN				* Close Screen
	move.l	rei_ScreenTAG(a4),d0	* Lo schermo CUSTOM viene sempre e solamente
	beq.s	SRE_EX2			* aperto se esiste una TagList.
	move.l	rei_Screen(a4),a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOCloseScreen(a6)
	moveq	#0,d0			* NULL per restituire un errore.
SRE_EX2	movem.l	(sp)+,d2-d6/a2-a6
	rts

***************************************************************************************
** LayoutAsmGList(rei, asmglist,PrevGadget)
**                A4      A3       A2
** 
** Questo comando di uso esclusivamente interno, si preoccupa di effetuare il layout
** dei Gadget da visualizzare in una REI (Window). La struttura NewGadget presente
** all'interno della struttura AsmGadget, viene corretamente inizializzata, basandosi
** su particolari infos presenti nella AsmGadget.
**
***************************************************************************************
MAKEFONT	MACRO
	moveq	#-1,d0			* Calcola il n. di caratteri
CLEN\@	tst.b	(a0)+
	dbeq	d0,CLEN\@
	lea	(a0,d0.l),a0		* Ritorna inizio stringa...
	neg.l	d0			* D0 = n. di caratteri
	move.l	rei_rpGadget(a4),a1	* RastPort fittizia...
	move.w	rp_TxWidth(a1),d7	* Width of one char
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOTextLength(a6)	* pixel calculating
	move.w	d0,d2
	add.w	d7,d2			* D2 = Width of Gadget
	move.w	d6,d3			* D3 = Height of Gadget
	ENDM
;--------------------------------------------------------------------------------------
MAKELABEL	MACRO
	move.l	agg_NewGadget+gng_GadgetText(a3),d0		* Check Label for LISTVIEW
	beq.s	LABEX\@
	move.l	d0,a0
	moveq	#0,d2
	move.l	rei_rpGadget(a4),a1
	move.w	rp_TxHeight(a1),d3
	btst	#2,agg_NewGadget+gng_Flags+3(a3)
	bne.s	MKLAB\@
	moveq	#-1,d0			* Calcola il n. di caratteri
CLENL\@	tst.b	(a0)+
	dbeq	d0,CLENL\@
	lea	(a0,d0.l),a0		* Ritorna inizio stringa...
	neg.l	d0			* D0 = n. di caratteri
	move.w	rp_TxWidth(a1),d7	* Width of one char
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOTextLength(a6)	* pixel calculating
	move.w	d0,d2
	add.w	d7,d2			* D2 = Width of Gadget
	move.w	d2,agg_LabelWidth(a3)
	moveq	#-6,d3
MKLAB\@	addq.w	#6,d3
	move.w	d3,agg_LabelHeight(a3)
LABEX\@	
	ENDM
;--------------------------------------------------------------------------------------
CHILD	MACRO
	move.l	agg_XChild(a3),d7
	beq.s	CHD\@
	move.l	d7,a0
	add.w	agg_NewGadget+gng_LeftEdge(a0),d0
	move.l	agg_Gadget(a0),a0
	move.l	gg_GadgetRender(a0),a0
	add.w	ibox_Width(a0),d0
	moveq	#0,d4
CHD\@	move.l	agg_YChild(a3),d7
	beq.s	CHDEND\@
	move.l	d7,a0
	add.w	agg_NewGadget+gng_TopEdge(a0),d1
	move.l	agg_Gadget(a0),a0
	move.l	gg_GadgetRender(a0),a0
	add.w	ibox_Height(a0),d1
	moveq	#0,d5
CHDEND\@	
	ENDM
;--------------------------------------------------------------------------------------	
RELATIVE	MACRO
	move.l	rei_Window(a4),a0
	BTSTL	AGB_RELBRIGHT,agg_Flags(a3)
	beq.s	NRELR\@
	sub.w	agg_LabelWidth(a3),d0
	move.w	wd_Width(a0),d7
	sub.w	d0,d7
	move.b	wd_BorderRight(a0),d0
	ext.w	d0
	sub.w	d0,d7
	sub.w	d2,d7
	move.w	d7,d0
	moveq	#0,d4
NRELR\@	BTSTL	AGB_RELBBOTTOM,agg_Flags(a3)
	beq.s	RELEX\@
	sub.w	agg_LabelHeight(a3),d1
	move.w	wd_Height(a0),d7
	sub.w	d1,d7
	move.b	wd_BorderBottom(a0),d1
	ext.w	d1
	sub.w	d1,d7
	sub.w	d3,d7
	move.w	d7,d1
	moveq	#0,d5
RELEX\@	
	ENDM
;--------------------------------------------------------------------------------------	
CENTER	MACRO
	move.l	rei_Window(a4),a0
	BTSTL	AGB_HCENTER,agg_Flags(a3)
	beq.s	CEN\@
	move.w	wd_Width(a0),d0
	sub.w	d2,d0
	asr.w	#1,d0
	moveq	#0,d4
CEN\@	BTSTL	AGB_VCENTER,agg_Flags(a3)
	beq.s	CENEND\@
	move.w	wd_Height(a0),d1
	sub.w	d3,d1
	asr.w	#1,d1
	moveq	#0,d5
CENEND\@
	ENDM
;--------------------------------------------------------------------------------------
INNER	MACRO	
	move.l	agg_InnerWidth(a3),d7
	beq.s	NoIn\@
	move.l	d7,a0
	move.w	agg_NewGadget+gng_LeftEdge(a0),d2
	sub.w	d0,d2
	sub.w	agg_LabelWidth(a0),d2
	sub.w	agg_Width(a3),d2
NoIn\@	move.l	agg_InnerHeight(a3),d7
	beq.s	INNEX\@
	move.l	d7,a0
	move.w	agg_NewGadget+gng_TopEdge(a0),d3
	sub.w	d1,d3
	sub.w	agg_LabelHeight(a0),d3
	sub.w	agg_Height(a3),d3
INNEX\@	
	ENDM
;--------------------------------------------------------------------------------------
CREATEGADGET	MACRO
	move.l	ab_GadToolsBase(a5),a6		* GadTools...
	move.l	rei_VI(a4),agg_NewGadget+gng_VisualInfo(a3)	* Put VisualInfo
	move.l	rei_GadgetTextAttr(a4),agg_NewGadget+gng_TextAttr(a3)
	move.l	agg_NewGadget+gng_UserData(a3),d4	* AsmHook or NULL...
	move.l	a3,agg_NewGadget+gng_UserData(a3)	* Put itself in UserData...
	move.l	a2,a0				* Previus *Gadget
	lea	agg_NewGadget(a3),a1		* NewGadget ->A1
	movem.l	agg_Kind(a3),d0/a2		* Take Kind/TagList
	jsr	_LVOCreateGadgetA(a6)		* CREATE A GADGET
	move.l	d0,a0				* A0 ^ This Gadget
	move.l	a0,agg_Gadget(a3)		* Gadtools *Gadget structure
	move.l	d4,agg_NewGadget+gng_UserData(a3)	* AsmHook or NULL...
	movem.l	(sp)+,d4-d5/a2
	move.l	gg_NextGadget(a2),d0		* true intui gadget
	move.l	d0,agg_IGadget(a3)		* Intuition * Gadget structure
	move.l	a0,a2				* Prev Gadget...
	ENDM
;--------------------------------------------------------------------------------------
LayoutAsmGList
	movem.l	d2-d7/a2-a5,-(sp)
	move.l	a6,a5					* Save AsmBase
	move.w	([rei_rpGadget.w,a4],rp_TxHeight.w),d5
	move.w	d5,d6		
	asr.w	#1,d5		
	add.w	d5,d6		
	addq.w	#4,d6				* D6 Standar Height of Gadget...
	moveq	#0,d4
	moveq	#0,d5
	move.b	([rei_Window.w,a4],wd_BorderLeft.w),d4	* Fisso, Border
	move.b	([rei_Window.w,a4],wd_BorderTop.w),d5	* Fisso, Border
	bra.s	LAY_GO
LAY_EXT	move.l	([a3]),d0		* questo che ho fatto era l'ultimo??
	beq.s	LAY_END			* si, esci...
	move.l	LN_SUCC(a3),a3		* ok, prendi il successivo....
LAY_GO	move.l	agg_Kind(a3),d0		* Kind... D7 è Scratch...
	lea	LAY_Table(pc),a1	* Table
	jmp	([d0.w*4,a1])		* Free
LAY_END	movem.l	(sp)+,d2-d7/a2-a5
	rts

;--------------------------------------------------------------------------------------
; BUTTON_KIND CREATE -
;--------------------------------------------------------------------------------------
LAY_BUT	movem.l	d4-d5/a2,-(sp)
	move.l	agg_NewGadget+gng_GadgetText(a3),a0	* String
	MAKEFONT			* Calling... MACRO
	movem.w	agg_LeftEdge(a3),d0-d1	* Left and Top Edge
LIKECYB	CHILD
	RELATIVE
	CENTER
	add.w	d4,d0
	add.w	d5,d1
	movem.w	d0-d3,agg_NewGadget+gng_LeftEdge(a3)
	CREATEGADGET
	bra	LAY_EXT
;--------------------------------------------------------------------------------------
; CYCLE_KIND CREATE -
;--------------------------------------------------------------------------------------
LAY_CYC	movem.l	d4-d5/a2,-(sp)
	MAKELABEL
	move.l	([agg_TagList.w,a3],CYCDATA_Labels.w),a0
	move.l	(a0),a0
	MAKEFONT
	add.w	#20,d2
	movem.w	agg_LeftEdge(a3),d0-d1
	add.w	agg_LabelWidth(a3),d0
	add.w	agg_LabelHeight(a3),d1
	bra	LIKECYB
;--------------------------------------------------------------------------------------
; TEXT_KIND/NUMBER_KIND CREATE -
;--------------------------------------------------------------------------------------
LAY_TEX	movem.l	d4-d5/a2,-(sp)
	MAKELABEL
	movem.w	agg_LeftEdge(a3),d0-d2
	move.w	d6,d3
	bra.s	LIKECOM
;--------------------------------------------------------------------------------------
; LISTVIEW_KIND CREATE -
;--------------------------------------------------------------------------------------
LAY_LIS	movem.l	d4-d5/a2,-(sp)
	MAKELABEL
	lea	CallBackLVHook(pc),a0		* Custom CallBack hook...
	move.l	a5,h_Data(a0)
	move.l	agg_TagList(a3),a1
	move.l	a0,LISDATA_CallBack(a1)
	moveq	#0,d0
	move.w	([rei_rpGadget.w,a4],rp_TxHeight.w),d0
	addq.w	#2,d0
	move.l	d0,LISDATA_ItemHeight(a1)
	movem.w	agg_LeftEdge(a3),d0-d3		* x,y,w,h
LIKECOM	add.w	agg_LabelWidth(a3),d0
	add.w	agg_LabelHeight(a3),d1
	CHILD
	add.w	d4,d0
	add.w	d5,d1
	move.l	rei_Window(a4),a0
	BTSTL	AGB_WINDOWWIDTH,agg_Flags(a3)	* End of Window Relative??
	beq.s	LIS_001
	move.b	wd_BorderRight(a0),d4
	move.w	wd_Width(a0),d2
	ext.w	d4
	sub.w	d0,d2
	sub.w	d4,d2
	sub.w	agg_Width(a3),d2
LIS_001	BTSTL	AGB_WINDOWHEIGHT,agg_Flags(a3)
	beq.s	LIS_INN
	move.b	wd_BorderBottom(a0),d4
	move.w	wd_Height(a0),d3
	ext.w	d4
	sub.w	d1,d3
	sub.w	d4,d3
	sub.w	agg_Height(a3),d3
LIS_INN	INNER
	CENTER
	movem.w	d0-d3,agg_NewGadget+gng_LeftEdge(a3)
	CREATEGADGET
	bra	LAY_EXT
;--------------------------------------------------------------------------------------
; INNER_KIND CREATE -
;--------------------------------------------------------------------------------------
LAY_INN	movem.l	d4-d5/a2,-(sp)
	movem.w	agg_LeftEdge(a3),d0-d3			* Left and Top Edge
	CENTER
	movem.w	d0-d3,agg_NewGadget+gng_LeftEdge(a3)
	move.l	ab_GadToolsBase(a5),a6		* GadTools...
	move.l	rei_VI(a4),agg_NewGadget+gng_VisualInfo(a3)	* Put VisualInfo
	move.l	rei_GadgetTextAttr(a4),agg_NewGadget+gng_TextAttr(a3)
	move.l	agg_NewGadget+gng_UserData(a3),d4	* AsmHook or NULL...
	move.l	a3,agg_NewGadget+gng_UserData(a3)	* Put itself in UserData...
	move.l	a2,a0				* Previus *Gadget
	lea	agg_NewGadget(a3),a1		* NewGadget ->A1
	moveq	#GENERIC_KIND,d0		* SPECIAL FIX to GENERIC FOR INNER_KIND
	move.l	agg_TagList(a3),a2		* Take Kind/TagList
	jsr	_LVOCreateGadgetA(a6)		* CREATE A GADGET
	move.l	d0,a0				* A0 ^ This Gadget
	move.l	a0,agg_Gadget(a3)		* Gadtools *Gadget structure
	move.l	d4,agg_NewGadget+gng_UserData(a3)	* AsmHook or NULL...
	movem.l	(sp)+,d4-d5/a2
	move.l	gg_NextGadget(a2),d0		* true intui gadget
	move.l	d0,agg_IGadget(a3)		* Intuition * Gadget structure
	move.l	a0,a2				* Prev Gadget...
	bra	LAY_EXT
;--------------------------------------------------------------------------------------
; INTEGER/STRING_KIND CREATE
;--------------------------------------------------------------------------------------
LAY_STR	movem.l	d4-d5/a2,-(sp)
	MAKELABEL
	movem.w	agg_LeftEdge(a3),d0-d2
	move.w	d6,d3
	add.w	agg_LabelWidth(a3),d0
	add.w	agg_LabelHeight(a3),d1
	CHILD
	add.w	d4,d0
	add.w	d5,d1
	move.l	rei_Window(a4),a0
	BTSTL	AGB_WINDOWWIDTH,agg_Flags(a3)	* End of Window Relative??
	beq.s	STR_INN
	move.b	wd_BorderRight(a0),d4
	move.w	wd_Width(a0),d2
	ext.w	d4
	sub.w	d0,d2
	sub.w	d4,d2
	sub.w	agg_Width(a3),d2
STR_INN	INNER
	CENTER
	movem.w	d0-d3,agg_NewGadget+gng_LeftEdge(a3)
	CREATEGADGET
	bra	LAY_EXT
;--------------------------------------------------------------------------------------
; UPPERCASE_KIND CREATE - 
;--------------------------------------------------------------------------------------
LAY_UPP	lea	UPPHook(pc),a0			* Hook...
	bra.s	CCOMMON
;--------------------------------------------------------------------------------------
; DECIMAL_KIND CREATE - INTEGER Revision KIND
;--------------------------------------------------------------------------------------
LAY_DEC	lea	DECHook(pc),a0			* Hook...
	bra.s	CCOMMON
;--------------------------------------------------------------------------------------
; HEXDECIMAL_KIND CREATE - 
;--------------------------------------------------------------------------------------
LAY_HEX	lea	HEXHook(pc),a0			* Hook...
	bra.s	CCOMMON	
;--------------------------------------------------------------------------------------
; BINARY_KIND CREATE - INTEGER Revision KIND
;--------------------------------------------------------------------------------------
LAY_BIN	lea	BINHook(pc),a0			* Hook...
;--------------------------------------------------------------------------------------
CCOMMON	move.l	a5,h_Data(a0)
	move.l	agg_TagList(a3),a1
	move.l	#GTST_EditHook,STRTAG_EditHook(a1)
	move.l	a0,STRDATA_EditHook(a1)
	movem.l	d4-d5/a2,-(sp)
	MAKELABEL
	movem.w	agg_LeftEdge(a3),d0-d2
	move.w	d6,d3
	add.w	agg_LabelWidth(a3),d0
	add.w	agg_LabelHeight(a3),d1
	CHILD
	add.w	d4,d0
	add.w	d5,d1
	move.l	rei_Window(a4),a0
	BTSTL	AGB_WINDOWWIDTH,agg_Flags(a3)	* End of Window Relative??
	beq.s	COM_INN
	move.b	wd_BorderRight(a0),d4
	move.w	wd_Width(a0),d2
	ext.w	d4
	sub.w	d0,d2
	sub.w	d4,d2
	sub.w	agg_Width(a3),d2
COM_INN	INNER
	CENTER
	movem.w	d0-d3,agg_NewGadget+gng_LeftEdge(a3)
	move.l	ab_GadToolsBase(a5),a6		* GadTools...
	move.l	rei_VI(a4),agg_NewGadget+gng_VisualInfo(a3)	* Put VisualInfo
	move.l	rei_GadgetTextAttr(a4),agg_NewGadget+gng_TextAttr(a3)
	move.l	agg_NewGadget+gng_UserData(a3),d4	* AsmHook or NULL...
	move.l	a3,agg_NewGadget+gng_UserData(a3)	* Put itself in UserData...
	move.l	a2,a0				* Previus *Gadget
	lea	agg_NewGadget(a3),a1		* NewGadget ->A1
	moveq	#STRING_KIND,d0
	move.l	agg_TagList(a3),a2		* Take TagList
	jsr	_LVOCreateGadgetA(a6)		* CREATE A GADGET
	move.l	d0,a0				* A0 ^ This Gadget
	move.l	a0,agg_Gadget(a3)		* Gadtools *Gadget structure
	move.l	d4,agg_NewGadget+gng_UserData(a3)	* AsmHook or NULL...
	movem.l	(sp)+,d4-d5/a2
	move.l	gg_NextGadget(a2),d0		* true intui gadget
	move.l	d0,agg_IGadget(a3)		* Intuition * Gadget structure
	move.l	a0,a2				* Prev Gadget...
	bra	LAY_EXT	
;--------------------------------------------------------------------------------------
; LAYOUT Table
;--------------------------------------------------------------------------------------
LAY_Table	
	dc.l LAY_EXT		* GENERIC_KIND (da testare)
	dc.l LAY_BUT		* BUTTON_KIND
	dc.l LAY_EXT		* CHECKBOX_KIND (not implement now!)
	dc.l LAY_TEX		* INTEGER_KIND
	dc.l LAY_LIS		* LISTVIEW_KIND
	dc.l LAY_EXT		* MX_KIND (not implement now!)
	dc.l LAY_TEX		* NUMBER_KIND
	dc.l LAY_CYC		* CYCLE_KIND
	dc.l LAY_EXT		* PALETTE_KIND (not implement now!)
	dc.l LAY_EXT		* SCROLLER_KIND (not implement now!)
	dc.l LAY_EXT		* RESERVED_KIND (not implement now!)
	dc.l LAY_EXT		* SLIDER_KIND (not implement now!)
	dc.l LAY_TEX		* STRING_KIND
	dc.l LAY_TEX		* TEXT_KIND
;----------------------------------------------------My Special Custom Kind------------
	dc.l LAY_INN		* INNER_KIND	
	dc.l LAY_UPP		* UPPERCASE_KIND
	dc.l LAY_DEC		* DECIMAL_KIND
	dc.l LAY_HEX		* HEXEDICIMAL_KIND
	dc.l LAY_BIN		* BINARY_KIND
;--------------------------------------------------------------------------------------	
; SPECIAL HOOK For: UPPERCASE, DECIMAL, HEXDECIMAL & BINARY KIND...
;--------------------------------------------------------------------------------------	
UPPHook	ds.b MLN_SIZE			* Queste sono le strutture Hook
	dc.l UPPERRoutine,0,0
DECHook	ds.b MLN_SIZE
	dc.l DECRoutine,0,0
HEXHook	ds.b MLN_SIZE
	dc.l HEXRoutine,0,0
BINHook	ds.b MLN_SIZE
	dc.l BINRoutine,0,0
;======================================================================================
;== Special Hook Routine for STRING_KIND ==============================================
;======================================================================================
UPPERRoutine
	movem.l	a0-a6,-(sp)
	moveq	#0,d0			* Unknow Message
	cmpi.l	#SGH_KEY,(a1)
	bne.s	ExiHook
	cmpi.w	#EO_INSERTCHAR,sgw_EditOp(a2)
	beq.s	UPPELA
	cmpi.w	#EO_REPLACECHAR,sgw_EditOp(a2)
	bne.s	ExiHook
UPPELA	move.w	sgw_Code(a2),d0
	move.l	([h_Data.w,a0],ab_UtilityBase.w),a6
	pea	Use(pc)
	jmp	_LVOToUpper(a6)
;--------------------------------------------------------------------------------------
DECRoutine
	movem.l	a0-a6,-(sp)
	moveq	#0,d0			* Unknow Message
	cmpi.l	#SGH_KEY,(a1)
	bne.s	ExiHook
	cmpi.w	#EO_INSERTCHAR,sgw_EditOp(a2)
	beq.s	DECELA
	cmpi.w	#EO_REPLACECHAR,sgw_EditOp(a2)
	bne.s	ExiHook
DECELA	move.w	sgw_Code(a2),d0
	cmpi.b	#"#",d0
	beq.s	Use
	cmpi.b	#"0",d0
	bmi.s	Fail
	cmpi.b	#"9",d0
	bhi.s	Fail
Use	move.w	sgw_BufferPos(a2),d1
	subq.w	#1,d1
	move.l	sgw_WorkBuffer(a2),a0
	move.b	d0,(a0,d1.l)
	moveq	#-1,d0			* Know message	
ExiHook	movem.l	(sp)+,a0-a6
	rts		
Fail	cmpi.b	#"-",d0
	beq	Use
	cmpi.b	#"+",d0
	beq	Use
	move.l	#~SGA_USE,sgw_Actions(a2)
	moveq	#0,d0
	movem.l	(sp)+,a0-a6
	rts
;--------------------------------------------------------------------------------------
HEXRoutine
	movem.l	a0-a6,-(sp)
	moveq	#0,d0			* Unknow Message
	cmpi.l	#SGH_KEY,(a1)
	bne.s	ExiHook
	cmpi.w	#EO_INSERTCHAR,sgw_EditOp(a2)
	beq.s	HEXELA
	cmpi.w	#EO_REPLACECHAR,sgw_EditOp(a2)
	bne	ExiHook
HEXELA	move.w	sgw_Code(a2),d0
	move.l	([h_Data.w,a0],ab_UtilityBase.w),a6
	jsr	_LVOToUpper(a6)
	cmp.b	#"$",d0
	beq	Use
	cmpi.b	#"0",d0
	bmi	Fail
	cmpi.b	#"9",d0
	ble	Use
	cmpi.b	#"A",d0
	bmi	Fail
	cmpi.b	#"F",d0
	ble	Use
	bra	Fail
;--------------------------------------------------------------------------------------
BINRoutine
	movem.l	a0-a6,-(sp)
	moveq	#0,d0			* Unknow Message
	cmpi.l	#SGH_KEY,(a1)
	bne	ExiHook
	cmpi.w	#EO_INSERTCHAR,sgw_EditOp(a2)
	beq.s	BINELA
	cmpi.w	#EO_REPLACECHAR,sgw_EditOp(a2)
	bne	ExiHook
BINELA	move.w	sgw_Code(a2),d0
	cmp.b	#"%",d0
	beq	Use
	cmpi.b	#"0",d0
	beq	Use
	cmpi.b	#"1",d0
	beq	Use
	bra	Fail
	
***************************************************************************************
** USO INTERNO
**
** Questo è il rifacimento del comando gadtools/FreeVisualInfo().
***************************************************************************************
NewFreeVisualInfo	
	movem.l	d2/a3-a6,-(sp)
	move.l	a6,a5
	move.l	a0,a3
VIError	move.l	vi_DrawInfo(a3),d0
	beq.s	SkipD
	move.l	d0,a1
	move.l	vi_Screen(a3),a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOFreeScreenDrawInfo(a6)
SkipD	move.l	vi_TextFont(a3),d0
	beq.s	SExit
	move.l	d0,a1
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOCloseFont(a6)
SExit	moveq	#0,d0
	movem.l	(sp)+,d2/a3-a6
	rts
***************************************************************************************
** USO INTERMO
**
** Prende l'indirizzo dell'Hook usato per tracciare un pattern sulle finestre dello
** schermo del Workbench.
***************************************************************************************
GetSystemHook
	movem.l	a0-a6,-(sp)
	move.l	ab_IntuiBase(a6),a6
	suba.l	a0,a0
	jsr	_LVOLockPubScreen(a6)
	move.l	d0,a2
	suba.l	a0,a0
	move.l	a2,a1
	jsr	_LVOUnlockPubScreen(a6)
	move.l	sc_FirstWindow(a2),a0
Cerca	move.l	wd_Flags(a0),d0
	andi.l	#WBENCHWINDOW,d0
	beq.s	ProsW
	move.l	wd_Title(a0),d0
	beq.s	Trovata
ProsW	move.l	wd_NextWindow(a0),d0
	move.l	d0,a0
	bne.s	Cerca
	movem.l	(sp)+,a0-a6
	rts
Trovata	move.l	([wd_RPort.w,a0],rp_Layer.w),a0
	move.l	lr_BackFill(a0),d0
	movem.l	(sp)+,a0-a6
	rts

***************************************************************************************
* (V41.1) - 15-11-1994 =JON= ** CloseREI(rei, name) (a0/a1)
***************************************************************************************
_LVOCloseREI
	movem.l	d2-d4/a3-a6,-(sp)
	move.l	a6,a5			* Shift AsmBase in A5 - Common
	move.l	a0,d0			* E' stata inserita una REI??
	bne.s	USRE_FF			* Ok, allora non cercarla tramite il nome...
	move.l	ab_ExecBase(a5),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),a0	* struct List *
	move.l	a0,d0
	beq.s	USREESR
	FINDNAME
	move.l	d0,a4			* (struct REI *) in A4
	move.l	a4,d0
	bne.s	USRE_FF			* Trovata...
USREESR	movem.l	(sp)+,d2-d4/a3-a6
	rts
;--------------------------------------------------------------------------------------	
USRE_FF	moveq	#0,d4			* D4 = Clear Register...
	move.l	d0,a4			* Shift REI in A4
	moveq	#0,d0
	BTSTL	REIB_OPENCLOSE,rei_Flags(a4)
	beq.s	USREESR
;--------------------------------------------------------------------------------------	
; Asl... future implement...
;--------------------------------------------------------------------------------------	
;-------move.l	rei_AslSupport(a4),d0	* Free Asl support??
;-------beq.s	USRE_MU			* No, Check menù...
;--------------------------------------------------------------------------------------	
	move.l	d4,rei_REIMessage+rim_REICode(a4)	* Pulisco rim_REICode...
;--------------------------------------------------------------------------------------	
; Ora controlliamo se la Window aveva dei MENU attaccati...
;--------------------------------------------------------------------------------------	
USRE_MU	move.l	rei_Menu(a4),d0		* Address of ADD Menù...
	beq.s	USRE_W			* No Menù... Free Gadgets (V41.1)
	move.l	rei_Window(a4),a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOClearMenuStrip(a6)
	move.l	rei_Menu(a4),a0
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOFreeMenus(a6)
	move.l	d4,rei_Menu(a4)		* Clear Pointer Menu...
;--------------------------------------------------------------------------------------	
USRE_W	BTSTL	REIB_REMEMBERPOS,rei_Flags(a4)
	beq.s	RemSize
	movem.w	([rei_Window.w,a4],wd_LeftEdge.w),d0-d1
	movem.w	d0-d1,rei_RemLeft(a4)
RemSize	BTSTL	REIB_REMEMBERSIZE,rei_Flags(a4)
	beq.s	CloseW
	movem.w	([rei_Window.w,a4],wd_Width.w),d0-d1
	move.b	([rei_Screen.w,a4],sc_BarHeight.w),d2
	ext.w	d2
	addq.b	#1,d2
	sub.w	d2,d1
	sub.w	d2,rei_NewWindow+nw_MinHeight(a4)
	move.w	([rei_rpGadget.w,a4],rp_TxWidth.w),d2
	move.w	([rei_rpGadget.w,a4],rp_TxHeight.w),d3
	divu.w	d2,d0
	swap	d0
	divu.w	d3,d1
	swap	d1	
	movem.l	d0-d1,rei_RemWidth(a4)
	movem.w	rei_NewWindow+nw_MinWidth(a4),d0-d1
	divu.w	d2,d0
	divu.w	d3,d1
	movem.w	d0-d1,rei_NewWindow+nw_MinWidth(a4)
CloseW	move.l	rei_Window(a4),a0	* Window... every presents...
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOCloseWindow(a6)	* Close Window!!!
	move.l	d4,rei_Window(a4)	* Clear pointer window
	lea	rei_NewWindow(a4),a0
;--------------------------------------------------------------------------------------
; In questa nuova versione... liberiamo comunque la memoria dalla lista dei Gadget
; partendo dal ritorno di CreateContex() contenuto come sappiamo in rei_glist. La
; Window arrivati a questo punto è già stata chiusa.
;--------------------------------------------------------------------------------------
	move.l	rei_glist(a4),a0	* = CreateContex
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOFreeGadgets(a6)	* Free Gadgets
	move.l	d4,rei_glist(a4)	* Clear Gads pointer
;--------------------------------------------------------------------------------------	
	move.l	rei_VI(a4),a0		* Visual Info...
	move.l	a5,a6	
	bsr	NewFreeVisualInfo	* My private routine...
	move.l	d4,rei_VI(a4)		* Clear security
;--------------------------------------------------------------------------------------
; Ora invece, vediamo se era stato aperto un CustomScreen...
;--------------------------------------------------------------------------------------
	move.l	rei_ScreenTAG(a4),d0	* NewScreen TagItem list??
	beq.s	CRFONT			* NO.. Exit... safely and ok...
	move.l	rei_Screen(a4),a0	* Take Screen ptr
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOCloseScreen(a6)	* Close Screens
	move.l	d4,rei_Screen(a4)
;--------------------------------------------------------------------------------------
; Free Font...
;--------------------------------------------------------------------------------------
CRFONT	tst.l	rei_GadgetTextAttr(a4)
	beq.s	RPFREE
	move.l	rei_GadgetFont(a4),d0
	beq.s	RPFREE
	move.l	d0,a1
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOCloseFont(a6)
;--------------------------------------------------------------------------------------	
RPFREE	move.l	ab_ExecBase(a5),a6
	move.l	rei_rpGadget(a4),a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
;--------------------------------------------------------------------------------------
USRE_E	BCLRL	REIB_OPENCLOSE,rei_Flags(a4)	* This REI is CLOSE
	move.l	a4,d0				* A4 = Address REI
	movem.l	(sp)+,d2-d4/a3-a6
	rts

***************************************************************************************
*(V41) - 20 Sept 1994 =JON= ** ActiveREI() ()
***************************************************************************************
_LVOActiveREI
	movem.l	a5-a6,-(sp)
	move.l	ab_IntuiBase(a6),a6
	moveq	#0,d0
	jsr	_LVOLockIBase(a6)
	move.l	d0,a0
	move.l	ib_ActiveWindow(a6),a5
	jsr	_LVOUnlockIBase(a6)
	move.l	wd_UserData(a5),d0
	movem.l	(sp)+,a5-a6
	rts	

***************************************************************************************
* (25-Jan-1995) =Jon= ** rei = LockREI(rei, name) (a0/a1)
***************************************************************************************
_LVOLockREI
	movem.l	a5-a6,-(sp)
	move.l	a0,d0			* E' stato passato un'indirizzo di una REI???
	bne.s	LRmain			* Si, allora vai...
	move.l	a1,d0			* E' stato passato un nome, allora???
	bne.s	LRname			* Perfetto vai...
	bsr.s	_LVOActiveREI		* Ok, prendi quella Attiva...
	bne.s	LRmain	
LRexit	movem.l	(sp)+,a5-a6
	rts
LRname	move.l	ab_ExecBase(a6),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),d0	* struct List *
	beq.s	LRexit
	move.l	d0,a0
	FINDNAME		
	beq.s	LRexit			* Exit failure...
LRmain	move.l	d0,a5			* A5 = struct REI *
	BTSTL	REIB_LOCK,rei_Flags(a5)	* Controlliamo se è già stata bloccata...
	bne.s	LRexit			* Esci... è già bloccata...
	lea	rei_Request(a5),a0	* facciamo entrare la Window in modo request
	move.l	ab_IntuiBase(a6),a6	* così da bloccare ogni tipo di INPUT...
	jsr	_LVOInitRequester(a6)
	lea	rei_Request(a5),a0
	move.l	rei_Window(a5),a1
	jsr	_LVORequest(a6)
	move.l	rei_Window(a5),a0	* Poniamo adesso il mouse in attesa...
	lea	LRTAG(pc),a1		* see below...
	jsr	_LVOSetWindowPointerA(a6)
	BSETL	REIB_LOCK,rei_Flags(a5)	* Settiamo il Flags nella REI....
	move.l	a5,d0
	movem.l	(sp)+,a5-a6
	rts
LRTAG	dc.l WA_BusyPointer,1,TAG_DONE

***************************************************************************************
* (25-Jan-1995) =Jon= ** rei = UnlockREI(rei, name) (a0/a1)
***************************************************************************************
_LVOUnlockREI
	movem.l	a5-a6,-(sp)
	move.l	a0,d0			* E' stato passato un addr??
	bne.s	URmain
	move.l	a1,d0			* Allora è stato passato il nome??
	bne.s	URname
URexit	movem.l	(sp)+,a5-a6
	rts
URname	move.l	ab_ExecBase(a6),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),d0	* struct List *
	beq.s	URexit
	move.l	d0,a0
	FINDNAME		
	beq.s	URexit			* Exit failure...
URmain	move.l	d0,a5			* A5 = struct REI *		
	BTSTL	REIB_LOCK,rei_Flags(a5)	* Vediamo se è bloccata...
	beq.s	URexit			* bhe'... allora che la sblocco a fare.. esci
	lea	rei_Request(a5),a0	* Request
	move.l	rei_Window(a5),a1	* This Window
	move.l	ab_IntuiBase(a6),a6	* Intuition...
	jsr	_LVOEndRequest(a6)	* Unlock!! -- riavvia i messaggi...
	move.l	rei_Window(a5),a0	* Window another
	lea	ULTAG(pc),a1		* Normal Pointer
	jsr	_LVOSetWindowPointerA(a6)	* Clear pointer to normal
	BCLRL	REIB_LOCK,rei_Flags(a5)	* puliamo il bit di lock, visto che...
UREI_LK	movem.l	(sp)+,a5-a6
	rts
ULTAG	dc.l WA_BusyPointer,0,TAG_DONE

***************************************************************************************
* (V41.1) - 06-10-1994 =JON= **** ######DA RIFARE O DA TOGLIERE########
***************************************************************************************
_LVORefreshREI
	movem.l	d2-d4/a2-a6,-(sp)
	move.l	a6,a5			* Save AsmBase
	move.l	a0,a3			* Save REI Address
	move.l	rei_glist(a3),a0	* There is a Gadget?
	move.l	rei_Window(a3),a1	* On this Window
	suba.l	a2,a2			* No Request mode
	moveq	#-1,d0			* All Gadgets list
	move.l	ab_IntuiBase(a5),a6	* Use only Intuition
	jsr	_LVORefreshGList(a6)
	move.l	rei_Window(a3),a0
	suba.l	a1,a1
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOGT_RefreshWindow(a6)
RRE_WIN	move.l	rei_Window(a3),a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVORefreshWindowFrame(a6)
	movem.l	(sp)+,d2-d4/a2-a6
	rts

***************************************************************************************
* (24-Jun-1995) =Jon= --- succ = InterfaceInfo(rei) (a0)
***************************************************************************************
_LVOInterfaceInfo
	move.l	ab_ExecBase(a6),a1
	move.l	([ThisTask.w,a1],TC_Userdata.w),d0	* struct MinList *
	bne.s	IICont
	rts	
IICont	movem.l	a2-a6,-(sp)
	move.l	d0,a5				* Save MinList == (Struct Interface *)
;--------------------------------------------------------------------------------------
	move.l	a0,a4				* Save....
	lea	ObjectI(pc),a0
	move.l	a0,d0
	move.l	sp,a3				* Salvo lo stack (24.Jun.95)
	pea	TAG_DONE
	pea	16
	pea	PDTA_NumColors
	pea	0
	pea	PDTA_Remap
	move.l	sp,a0
	bsr	_LVOLoadNewDTObjectA
	move.l	a3,sp				* Reset Stack...
	move.l	d0,a3
	move.l	a4,a0
;--------------------------------------------------------------------------------------
	move.l	sp,a4				* Save Stack...
	pea	0				* TAG_DONE
	pea	1	
	pea	AREQ_CenterVScreen
	pea	1
	pea	AREQ_CenterHScreen
	move.l	a0,-(sp)
	pea	AREQ_REI
	move.l	a0,-(sp)
	pea	AREQ_LockREI
	pea	ITitle(pc)
	pea	AREQ_Title
	move.l	a3,-(sp)
	pea	AREQ_Object
	
	move.l	sp,a0
	bsr	_LVOAllocAsmRequestA
	move.l	a4,sp
	tst.l	d0
	beq.s	IIExit
	move.l	d0,a4
	move.l	a4,a0
	lea	IIText(pc),a1
	suba.l	a2,a2
	exg.l	a5,a3
	lea	int_IName(a3),a3
	bsr	_LVOAsmRequestArgs
	move.l	a4,a0
	bsr	_LVOFreeAsmRequest
	move.l	a5,d0
	beq.s	NoPree
	move.l	d0,a0
	move.l	ab_DataTypesBase(a6),a6
	jsr	_LVODisposeDTObject(a6)
NoPree	moveq	#1,d0	
NoFree	movem.l	(sp)+,a2-a6
	rts
IIExit	move.l	a3,d0
	beq.s	NoFree
	move.l	d0,a0
	move.l	ab_DataTypesBase(a6),a6
	jsr	_LVODisposeDTObject(a6)
	moveq	#0,d0
	movem.l	(sp)+,a2-a6
	rts
;--------------------------------------------------------------------------------------
ITitle	STRING "Informations..."
IIText	dc.b "Name: %s",10
	dc.b "Version: %s",10
	dc.b "Author: %s",10
	dc.b "Address: %s",10
	dc.b "Date: %s",10
	dc.b "Comment: %s",0
	even
ObjectI	STRING "Interface.bsh"
;--------------------------------------------------------------------------------------	
***************************************************************************************
* ### PRIVATE ###
* (9-Mar-1995) =Jon= --- obj = LoadNewDTObjectA(name,taglist) (d0,a0)
***************************************************************************************	
_LVOLoadNewDTObjectA
	movem.l	a2-a6,-(sp)
	move.l	a6,a5			* Sposto l'AssemblyBase in A5
	move.l	a0,a4			* Salvo la TagList...
	move.l	d0,a3			* Salvo il Filename...
;--------------------------------------------------------------------------------------	
	move.l	ab_DataTypesBase(a5),a6
	jsr	_LVONewDTObjectA(a6)
	tst.l	d0
	bne.s	LNDExit			* Ok.. trovato...
;--------------------------------------------------------------------------------------
	move.l	ab_DosBase(a5),a6	* Lavoro in Dos...
	move.l	a3,d1			* Ricavo solo il filename, ovvero l'ultima
	jsr	_LVOFilePart(a6)	* parte della path...
	move.l	d0,a3			* Ora ho solo il filename senza path...
	move.l	([ab_ExecBase.w,a5],ThisTask.w),a0	* A0 = (struct Task *)
	move.l	pr_HomeDir(a0),d1	* mi sposto sulla drawer attuale...
	jsr	_LVOCurrentDir(a6)
;--------------------------------------------------------------------------------------
	move.l	a4,a0			* Riprovo qui...
	move.l	a3,d0
	move.l	ab_DataTypesBase(a5),a6
	jsr	_LVONewDTObjectA(a6)
	tst.l	d0
	bne.s	OkTrova			* Ok.. trovato...
;--------------------------------------------------------------------------------------
	lea	DefImageDraw(pc),a0
	move.l	a0,d1
	move.l	#ACCESS_READ,d2
	move.l	ab_DosBase(a5),a6
	jsr	_LVOLock(a6)
	tst.l	d0
	beq.s	OkTrova
	move.l	d0,a2			* Save lock for UnLock()
	move.l	d0,d1
	jsr	_LVOCurrentDir(a6)	* mi sposto in sys:Classes/Images
;--------------------------------------------------------------------------------------
	move.l	a4,a0			* Riprovo qui...
	move.l	a3,d0
	move.l	ab_DataTypesBase(a5),a6
	jsr	_LVONewDTObjectA(a6)
	move.l	d0,a3
	move.l	a2,d1
	move.l	ab_DosBase(a5),a6
	jsr	_LVOUnLock(a6)
	moveq	#0,d1			* root...
	jsr	_LVOCurrentDir(a6)
	move.l	a3,d0
LNDExit	movem.l	(sp)+,a2-a6
	rts
;--------------------------------------------------------------------------------------
OkTrova	move.l	d0,a3
	moveq	#0,d1			* root...
	jsr	_LVOCurrentDir(a6)
	move.l	a3,d0
	movem.l	(sp)+,a2-a6
	rts				
;--------------------------------------------------------------------------------------
DefImageDraw
	STRING <"sys:Classes/Images">
;--------------------------------------------------------------------------------------

***************************************************************************************
* (17-Mar-1995) =Jon= --- SetREIAttrsA(rei,name,TagList) (a0/a1/a2)
***************************************************************************************
SETREITable
	dc.l SET_ESR	* Offset...
	dc.l SETScreen,SETSKIP,SETSKIP,SETWindowTextAttr
	dc.l SETSKIP,SETSKIP,SETSKIP,SETSKIP
	dc.l SETUserData,SETSKIP,SETSKIP
	dc.l SETRememberPos,SETRememberSize,SETCenterHScreen,SETCenterVScreen
	dc.l SETCenterMouse,SETNoFontSensitive,SETWindowTitle,SETSKIP
	dc.l SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP	; AsmGadget skip...
	dc.l SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP,SETSKIP
	dc.l SETDoubleClick
_LVOSetREIAttrsA
	movem.l	d2-d6/a2-a6,-(sp)	
	moveq	#0,d6			* Usato come flags booleano...
	move.l	a6,a5			* Save AsmBase
	move.l	a0,d0			* E' stata inserita una REI??
	bne.s	SET_FND			* Ok, allora non cercarla tramite il nome...
	move.l	a1,d0			* se è stato inserito un nome NULL
	beq.s	SET_ESR			* esci...
	move.l	ab_ExecBase(a5),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),a0	* struct MinList *
	move.l	a0,d0
	beq.s	SET_ESR
	FINDNAME	
	move.l	d0,a4			* (struct REI *) in A4
	move.l	a4,d0			* Check...	
	bne.s	SET_FND			* Ok, nome e node trovati... continua...
SET_ESR	tst.l	d6			* Devo chiudere e riaprire la REI??
	bne.s	RefreshingREI		* Si vai...
SET_EXT	movem.l	(sp)+,d2-d6/a2-a6	* Niente, esci e basta
	rts
;--------------------------------------------------------------------------------------
RefreshingREI
	move.l	a4,a0			* REI da chiudere
	suba.l	a1,a1			* nome nullo...
	bsr	_LVOCloseREI		* chiudi tutto...
RREFRSH	move.l	a4,a0			* REI da aprire...
	suba.l	a1,a1
	move.l	a1,a2
	bsr	_LVOOpenREIA
	tst.l	d0
	bne.s	SET_EXT
	lea	TopazAttr(pc),a0
	move.l	a0,rei_GadgetTextAttr(a4)
	bra	RREFRSH
;--------------------------------------------------------------------------------------
SET_FND	move.l	d0,a4			* QUESTA REI SEMPRE IN A4
	move.l	a2,a0			* TagItem in A1...
	move.l	a0,d0			* C'è una TagItem list??
	beq.s	SET_ESR			* Se non c'è TagList esci al volo, grazie.
;--------------------------------------------------------------------------------------
SETTAG	USETAGLIST.l	SETREITable(pc),SETATAG,SET_ESR
;--------------------------------------------------------------------------------------
SETScreen
	move.l	(a0)+,d0		* NULL Screen??
	beq.s	SETATAG			* Yes, exit... next Tag please...
	move.l	a0,a2			* Save TagItem...
	move.l	rei_Screen(a4),d1	* Old Screen Pointer...
	sub.l	d0,d1			* è lo stesso schermo?? allora non fare
	beq.s	SETATAG			* niente...
	move.l	d0,rei_Screen(a4)	* New Screen OutPut...
	moveq	#1,d6			* Set per chiudere a riaprire la REI all'uscita
	bra.s	SETATAG
;--------------------------------------------------------------------------------------
SETSKIP	addq.w	#4,a0
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETWindowTextAttr
	move.l	(a0)+,rei_GadgetTextAttr(a4)
	moveq	#1,d6
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETUserData
	move.l	(a0)+,rei_UserData(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETRememberPos
	move.l	(a0)+,d0
	beq.s	RPosOff
	BSETL	REIB_REMEMBERPOS,rei_Flags(a4)
	bra	SETATAG
RPosOff	BCLRL	REIB_REMEMBERPOS,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETRememberSize
	move.l	(a0)+,d0
	beq.s	RSizOff
	BSETL	REIB_REMEMBERSIZE,rei_Flags(a4)
	bra	SETATAG
RSizOff	BCLRL	REIB_REMEMBERSIZE,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETCenterHScreen
	move.l	(a0)+,d0
	beq.s	CHOff
	BSETL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	SETATAG
CHOff	BCLRL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETCenterVScreen
	move.l	(a0)+,d0
	beq.s	CVOff
	BSETL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	SETATAG
CVOff	BCLRL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETCenterMouse
	move.l	(a0)+,d0
	beq.s	CMOff
	BSETL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	SETATAG
CMOff	BCLRL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETNoFontSensitive
	move.l	(a0)+,d0
	beq.s	NFOff
	BSETL	REIB_NOFONTSENSITIVE,rei_Flags(a4)
	bra	SETATAG
NFOff	BCLRL	REIB_NOFONTSENSITIVE,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
SETWindowTitle
	move.l	(a0)+,a1		* window title
	move.l	a0,d2			* save TagItem
	moveq	#-1,d0
	move.l	d0,a2			* screen title inalterato...
	move.l	rei_Window(a4),a0	* window
	move.l	a1,rei_NewWindow+nw_Title(a4)	* lo metto anche nella REI...
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOSetWindowTitles(a6)
	move.l	a5,a6			* Reset assemblybase
	move.l	d2,a0			* Reset TagItem
	bra	SETTAG
;--------------------------------------------------------------------------------------
SETDoubleClick
	move.l	(a0)+,d0
	beq.s	SETDC
	BSETL	REIB_DOUBLECLICK,rei_Flags(a4)
	bra	SETATAG
SETDC	BCLRL	REIB_DOUBLECLICK,rei_Flags(a4)
	bra	SETATAG
;--------------------------------------------------------------------------------------
TopazAttr
	dc.l TopazName
	dc.w 8
	dc.b FS_NORMAL,FPF_ROMFONT
TopazName
	STRING "topaz.font"	
;--------------------------------------------------------------------------------------
***************************************************************************************
* (17-Mar-1995) =Jon= --- num = GetREIAttrsA(rei,name,TagList) (a0/a1/a2)
***************************************************************************************
GetREITable
	dc.l GET_ESR	* Offset...
	dc.l GETScreen,GETWindowTAG,GETScreenTAG,GETWindowTextAttr
	dc.l SKIPGET,SKIPGET,GETNewMenu,GETNewMenuTAG
	dc.l GETUserData,GETLayoutCallBack,GETCustomHook
	dc.l GETRememberPos,GETRememberSize,GETCenterHScreen,GETCenterVScreen
	dc.l GETCenterMouse,GETNoFontSensitive,GETWindowTitle,GETWindow
	dc.l GETFirstAsmGadget,GETLastAsmGadget
	dc.l SKIPGET,SKIPGET,SKIPGET,SKIPGET,SKIPGET,SKIPGET,SKIPGET,SKIPGET
	dc.l SKIPGET,SKIPGET,SKIPGET,SKIPGET
	dc.l GETDoubleClick
_LVOGetREIAttrsA
	movem.l	d2-d6/a2-a6,-(sp)	
	moveq	#0,d2
	move.l	a6,a5			* Save AsmBase
	move.l	a0,d0			* E' stata inserita una REI??
	bne.s	GET_FND			* Ok, allora non cercarla tramite il nome...
	move.l	a1,d0			* se è stato inserito un nome NULL
	beq.s	GET_ESR			* esci...
	move.l	ab_ExecBase(a5),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),a0	* struct MinList *
	move.l	a0,d0
	beq.s	GET_ESR
	FINDNAME	
	move.l	d0,a4			* (struct REI *) in A4
	move.l	a4,d0			* Check...	
	bne.s	GET_FND			* Ok, nome e node trovati... continua...
GET_ESR	move.l	d2,d0
	movem.l	(sp)+,d2-d6/a2-a6	* Niente, esci e basta
	rts
;--------------------------------------------------------------------------------------
GET_FND	move.l	d0,a4			* QUESTA REI SEMPRE IN A4
	move.l	a2,a0			* TagItem in A1...
	move.l	a0,d0			* C'è una TagItem list??
	beq.s	GET_ESR			* Se non c'è TagList esci al volo, grazie.
;--------------------------------------------------------------------------------------
GETTAG	USETAGLIST.l	GetREITable(pc),GETATAG,GET_ESR
;--------------------------------------------------------------------------------------
GETScreen
	move.l	rei_Screen(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra.s	GETATAG
;--------------------------------------------------------------------------------------
SKIPGET	addq.w	#4,a0
	bra.s	GETATAG
;--------------------------------------------------------------------------------------
GETWindowTAG
	move.l	rei_NewWindowTAG(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETScreenTAG
	move.l	rei_ScreenTAG(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETWindowTextAttr
	move.l	rei_GadgetTextAttr(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETNewMenu
	move.l	rei_NewMenu(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETNewMenuTAG
	move.l	rei_NewMenuTAG(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG	
;--------------------------------------------------------------------------------------
GETUserData
	move.l	rei_UserData(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETLayoutCallBack
	move.l	rei_LayoutCallBack(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------	
GETCustomHook
	move.l	rei_CustomHook(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------	
GETRememberPos
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_REMEMBERPOS,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETRememberSize
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_REMEMBERSIZE,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETCenterHScreen
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_CENTERHSCREEN,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETCenterVScreen
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_CENTERVSCREEN,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETCenterMouse
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_CENTERMOUSE,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETNoFontSensitive
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_NOFONTSENSITIVE,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETWindowTitle
	move.l	rei_NewWindow+nw_Title(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETWindow
	move.l	rei_Window(a4),([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETFirstAsmGadget
	move.l	rei_HEADAsmGadget(a4),d1
	move.l	LN_SUCC(a0),d0
	bne.s	FHEAD	
	moveq	#0,d1
FHEAD	move.l	d1,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETLastAsmGadget
	move.l	rei_TAILAsmGadget(a4),d1
	move.l	LN_PRED(a0),d0
	bne.s	FTAIL	
	moveq	#0,d1
FTAIL	move.l	d1,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------
GETDoubleClick
	move.l	rei_Flags(a4),d0
	andi.l	#REIB_DOUBLECLICK,d0
	move.l	d0,([a0])
	addq.w	#1,d2
	addq.w	#4,a0
	bra	GETATAG
;--------------------------------------------------------------------------------------