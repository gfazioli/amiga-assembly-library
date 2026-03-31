****************************************************************************
* file - Intui-Gadtools - main intuition/gadtools file support commands
*
* Ver.41.1 - Table of CONTENTS
*
*
* SetAsmGadgetAttrsA()	- New
* GetAsmGadgetAttr()	- New
* [NewLook BackFill]    - New - usato per AsmRequest()
* [LayoutCallBack Hook] - New - usato per AsmRequest()
* DrawFrameStateA()	- New 
* ChangeAsmReqAttrsA()	- New - Ok
* AllocAsmRequestA()	- New - Ok
* FreeAsmRequest()	- New - Ok
* AsmRequestArgs()	- New - Ok
* AllocAsmGadget()	- New - Internal use only...!
* FreeAsmGList()	- New - Internal use only...!
* WaitREIMsg()		- New - OK
* (AutoGadget)		- Ok manca gestione di tutti i Gadgets ancora
* (AutoKey)		- OK '   '    '    '   '     '   '   '   ' 
* (AutoMenu)		- OK
* AS_MenuAddress()	- Ok
* OpenInterface()	- New - modificato
* CloseInterface()	- New - modificato
* FindREI()		- New - modificato
* FindAsmGadget()       - New - modificato
* 
***************************************************************************************

***************************************************************************************
* (14-Feb-1995) --- SetAsmGadgetAttrsA(rei, AsmGadget, name, taglist) (A0/A1/A2/A3)
***************************************************************************************
SAGTable
	dc.l SAGExit
	dc.l SAGNewHook,SAGExit,SAGExit,SAGExit,SAGExit,SAGExit,SAGExit,SAGExit
	dc.l SAGExit,SAGExit,SAGExit,SAGExit,SAGExit,SAGExit,SAGExit,SAGHighLight
	dc.l SAGExit,SAGExit,SAGExit,SAGExit
;--------------------------------------------------------------------------------------
_LVOSetAsmGadgetAttrsA
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a3,d0			* TagList Nulla??
	beq.s	SAGExit			* allora esci...
	move.l	a0,d0
	bne.s	SAGFind			* Ok, c'è una rei, quindi opero su questa...
SAGExit	movem.l	(sp)+,d2-d7/a2-a6
	rts
SAGFind	move.l	a6,a5			* Save AsmBase in A5
	move.l	d0,a4			* Save i (REI)
	move.l	a1,d7			* E' stato passato l'indirizzo dell'AsmGadget?
	bne.s	SAGGad			* si...
	move.l	a2,a1			* cercalo via name...
	lea	rei_HEADAsmGadget(a4),a0	* List
	FINDNAME
	move.l	d0,d7			* D7 = (struct AsmGadget *)
	beq.s	SAGExit
SAGGad	move.l	a3,a0			* A0 = (struct TagItem *)
TII_TAG	MIXTAGLIST.s	SAGTable(pc),GOI_TAG,SAGExit,8000,GADROU
;--------------------------------------------------------------------------------------
GADROU	move.l	a0,-(sp)		* Salvo A0 = (struct TagItem *)
	move.l	(a0),d1			* D1 = ti_Tag da ricercare...
	move.l	(agg_TagList.w,d7.l),a0	* Prendo il puntatore alla mia StdTagList...
	FINDTAG
	beq.s	NoTags			* Non esiste il ti_Tag...
	move.l	([sp],4.w),4(a0)	* ti_Data in ti_Data
	move.l	sp,d5			* salvo lo Stack
	suba.l	a2,a2
	move.l	a2,-(sp)
	move.l	4(a0),-(sp)
	move.l	(a0),-(sp)
	move.l	(agg_Gadget.w,d7.l),a0
	move.l	rei_Window(a4),a1
	move.l	sp,a3
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOGT_SetGadgetAttrsA(a6)
	move.l	d5,sp
NoTags	move.l	(sp)+,a0
	addq.l	#8,a0
	bra	TII_TAG	
;--------------------------------------------------------------------------------------
SAGNewHook
	move.l	(a0)+,d0		* Indirizzo del nuovo Hook...
	move.l	d0,(agg_NewGadget+gng_UserData.w,d7.l)
	bra	TII_TAG
;--------------------------------------------------------------------------------------
SAGHighLight
	move.l	(a0)+,d0
	beq.s	NoHighLight
	move.l	a0,-(sp)
	move.l	([rei_Window.w,a4],wd_RPort.w),a1		* Rport	
	moveq	#3,d0						* Color 3
	move.l	ab_GfxBase(a5),a6				* GfxBase
	jsr	_LVOSetAPen(a6)					* SetAPen()
	move.l	([rei_Window.w,a4],wd_RPort.w),a1		* RPort
	move.l	d7,a0
	move.l	agg_Gadget(a0),a0
	movem.w	gg_LeftEdge(a0),d0-d3				* Coordinate
	subq.w	#1,d1
	addq.w	#1,d3
	move.l	a5,a6						* AsmBase
	bsr	_LVODrawBox					* DrawBox()
	move.l	(sp)+,a0
	bra	TII_TAG
NoHighLight
	move.l	a0,-(sp)	
	move.l	([rei_Window.w,a4],wd_RPort.w),a1		* Rport	
	moveq	#0,d0						* Color 3
	move.l	ab_GfxBase(a5),a6				* GfxBase
	jsr	_LVOSetAPen(a6)					* SetAPen()
	move.l	([rei_Window.w,a4],wd_RPort.w),a1		* RPort
	move.l	d7,a0
	move.l	agg_Gadget(a0),a0
	movem.w	gg_LeftEdge(a0),d0-d3				* Coordinate
	subq.w	#1,d1
	addq.w	#1,d3
	move.l	a5,a6						* AsmBase
	bsr	_LVODrawBox
	move.l	(sp)+,a0
	bra	TII_TAG
***************************************************************************************
* (24-Feb-1995) - value = GetAsmGadgetAttr(rei,AsmGadget,name, attribute) (A0/A1/A2/D0)
***************************************************************************************
GAGTable
	dc.l GAGExit,GAGNewHook
	dc.l GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit
	dc.l GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit,GAGExit
	dc.l GAGSelNode
;--------------------------------------------------------------------------------------
_LVOGetAsmGadgetAttr
	movem.l	d6-d7/a2-a6,-(sp)
	move.l	d0,d6			* Attributo nullo??
	beq.s	GAGExit			* allora esci...
	move.l	a0,d0
	bne.s	GAGFind			* Ok, c'è una rei, quindi opero su questa...
GAGExit	movem.l	(sp)+,d6-d7/a2-a6
	rts
GAGFind	move.l	ab_GadToolsBase(a6),a6	* Only This...
	move.l	d0,a4			* Save i (REI)
	move.l	a1,d7			* E' stato passato l'indirizzo dell'AsmGadget?
	bne.s	GAGGad			* si...
	move.l	a2,a1			* cercalo via name...
	lea	rei_HEADAsmGadget(a4),a0	* List
	FINDNAME
	move.l	d0,d7			* D7 = (struct AsmGadget *)
	beq.s	GAGExit
GAGGad	move.l	d7,a5			* A5 = (struct AsmGadget *)
	move.l	d6,d0			* attributo...
	swap	d0
	andi.w	#~$8000,d0		* lo posso gestire io...??
	bne.s	GGADROU			* No, allora usa GT_GetGadgetAttrsA()
;--------------------------------------------------------------------------------------	
	swap	d0
	lea	GAGTable(pc),a1
	jmp	([a1,d0.w*4])	
;--------------------------------------------------------------------------------------
GGADROU	suba.l	a2,a2				* Request
	move.l	a2,-(sp)			* Buco... non serve questo spazio addr
	move.l	sp,d7				* &list
	move.l	a2,-(sp)			* TAG_DONE
	move.l	d7,-(sp)			* &list
	move.l	d6,-(sp)			* attributo da leggere
	move.l	sp,a3				* TagList
	move.l	rei_Window(a4),a1		* Window
	move.l	agg_Gadget(a5),a0		* Gadget
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	move.l	12(sp),d0			* RESULT...
	lea	16(sp),sp			* repristino Stack...
	movem.l	(sp)+,d6-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
GAGNewHook
	move.l	agg_NewGadget+gng_UserData(a5),d0
	movem.l	(sp)+,d6-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
GAGSelNode
	suba.l	a2,a2				* Request
	move.l	a2,-(sp)			* Buco... non serve questo spazio addr
	move.l	sp,d7				* &attr
	move.l	a2,-(sp)			* TAG_DONE
	move.l	d7,-(sp)			* &attr
	pea	GTLV_Labels			* prima leggo le labels...
	move.l	sp,a3				* TagList
	move.l	rei_Window(a4),a1		* Window
	move.l	agg_Gadget(a5),a0		* Gadget
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	move.l	12(sp),d0			* RESULT...
	lea	16(sp),sp			* repristino Stack...
	move.l	d0,d6
	beq.s	GAGFine				* non ci sono Liste attaccate al gadget
	move.l	a2,-(sp)			* Buco... non serve questo spazio addr
	move.l	sp,d7				* &attr
	move.l	a2,-(sp)			* TAG_DONE
	move.l	d7,-(sp)			* &attr
	pea	GTLV_Selected			* prima leggo le labels...
	move.l	sp,a3				* TagList
	move.l	rei_Window(a4),a1		* Window
	move.l	agg_Gadget(a5),a0		* Gadget
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	move.l	12(sp),d1			* Ordinal number selected...
	lea	16(sp),sp			* repristino Stack..
	move.l	d6,a0				* Lables (struct List *)
NNode	move.l	LN_SUCC(a0),d0
	move.l	d0,a0
	dbf	d1,NNode
GAGFine	movem.l	(sp)+,d6-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
	

;--------------------------------------------------------------------------------------
AsmGadgetHook
	move.l	(a1)+,d0			* (struct TagItem *)
	beq	GOI_TAG
	move.l	a1,a3				* Save Table...
	move.l	d0,a2
	move.l	(a2),d0				* TAG_DONE ??
	beq.s	INRExit
INRLoop	lea	rei_HEADAsmGadget(a4),a0	* List
	move.l	(a2)+,a1			* Name
	FINDNAME
	move.l	(a2)+,a1			* (struct Hook *)
	move.l	d0,a0				* (struct AsmGadget *)	
	move.l	a0,d0
	beq.s	INRChk
	move.l	a1,agg_NewGadget+gng_UserData(a0)	* Put Hook in Gadget...
INRChk	move.l	(a2),d0
	bne.s	INRLoop	
INRExit	move.l	a3,a1				* Repristino tavola...
	bra	TII_TAG
;--------------------------------------------------------------------------------------



***************************************************************************************
** (11-Feb-1995) =Jon= --- NewLook BackFill Hook for AsmRequest()...
***************************************************************************************
NewLookLayFill	
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	h_SubEntry(a0),a4		* (struct REI *)/(struct AsmRequest *)
	tst.l	areq_GadFmt(a4)
	bne.s	MKDraw
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------	
MKDraw	move.l	h_Data(a0),a5			* asmbase
	move.l	ab_GfxBase(a5),a6		* Tutto con la Graphics...
	addq.l	#4,a1
	move.l	a1,a3				* A3 ^ Rectangle
;--------------------------------------------------------------------------------------		
	movem.w	ra_MinX(a3),d0-d3	* Rectangle	
	move.w	d3,d1
	sub.w	#2,d1
	move.w	([areq_ScreenRP.w,a4],rp_TxHeight.w),d5
	sub.w	d5,d1
	asr.w	#1,d5
	sub.w	d5,d1
	subq.w	#6,d1
	move.w	d1,d5
;--------------------------------------------------------------------------------------			
	move.w	areq_FgPatternPen(a4),d0
	beq.s	SkGBack
	move.l	a2,a1
	jsr	_LVOSetAPen(a6)
	moveq	#0,d4			* bytecount NULL
	move.l	d4,a0			* mask == NULL
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d5,d3
	subq.w	#2,d3
	jsr	_LVOBltPattern(a6)
SkGBack	move.w	areq_BgPatternPen(a4),d0
	beq.s	MResto
	move.l	a2,a1
	jsr	_LVOSetAPen(a6)
	moveq	#0,d4			* bytecount NULL
	move.l	d4,a0			* mask == NULL
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d5,d1
	addq.w	#1,d1
	jsr	_LVOBltPattern(a6)
;--------------------------------------------------------------------------------------
MResto	movem.w	ra_MinX(a3),d0-d2		* Rectangle
	movem.w	d0/d5,rp_cp_x(a2)			****************************
	ori.w	#RPF_FRST_DOT,rp_Flags(a2)	 	**  SPECIAL MOVE Replace  **
	move.b	#$F,rp_linpatcnt(a2)	   		****************************
	move.l	a2,a1
	move.l	([rei_VI.b,a4],vi_DrawInfo.w),a0		* DrawInfo
	move.l	dri_Pens(a0),a0
	move.w	SHINEPEN*2(a0),d0
	jsr	_LVOSetAPen(a6)
	move.l	a2,a1
	move.w	d2,d0
	move.w	d5,d1
	jsr	_LVODraw(a6)
	move.l	a2,a1
	move.l	([rei_VI.b,a4],vi_DrawInfo.w),a0		* DrawInfo
	move.l	dri_Pens(a0),a0
	move.w	SHADOWPEN*2(a0),d0
	jsr	_LVOSetAPen(a6)
	movem.w	ra_MinX(a3),d0-d2	* Rectangle
	subq.w	#1,d5
	movem.w	d0/d5,rp_cp_x(a2)			****************************
	ori.w	#RPF_FRST_DOT,rp_Flags(a2)	 	**  SPECIAL MOVE Replace  **
	move.b	#$F,rp_linpatcnt(a2)	   		****************************
	move.l	a2,a1
	move.w	d2,d0
	move.w	d5,d1
	jsr	_LVODraw(a6)
	movem.l	(sp)+,d2-d7/a2-a6
	rts

***************************************************************************************
** (18-Jan-1995) =Jon= - Default LayoutbackFill per l'Asmrequest.
***************************************************************************************
LayFill	movem.l	d2-d7/a2-a6,-(sp)
	move.l	h_SubEntry(a0),a4		* (struct REI *)/(struct AsmRequest *)
	move.l	h_Data(a0),a5			* asmbase
	addq.w	#4,a1
	move.l	a1,a3				* A3 ^ Rectangle
	move.l	ab_GfxBase(a5),a6
	movem.w	areq_FgPatternPen(a4),d0-d1	* APen
	moveq	#RP_JAM2,d2
	move.l	a2,a1
	jsr	_LVOSetABPenDrMd(a6)
	pea	$AAAA5555		* Retino
	move.l	sp,rp_AreaPtrn(a2)	* Immagine del retino
	move.b	#1,rp_AreaPtSz(a2)	* 2 Long Word
	moveq	#0,d4			* bytecount NULL
	move.l	d4,a0			* mask == NULL
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d0,d2
	addq.w	#4,d2
	jsr	_LVOBltPattern(a6)
	move.l	d4,a0			* mask == NULL
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d2,d0
	subq.w	#4,d0
	jsr	_LVOBltPattern(a6)
	move.l	d4,a0			* mask == NULL
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d1,d3
	addq.w	#2,d3
	jsr	_LVOBltPattern(a6)
	move.l	a2,a1			* RastPorts
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	move.w	d3,d1
	move.w	d1,d5
	sub.w	#2,d1
	tst.l	areq_GadFmt(a4)
	beq.s	LBFDraw
	move.w	([areq_ScreenRP.w,a4],rp_TxHeight.w),d5
	sub.w	d5,d1
	asr.w	#1,d5
	sub.w	d5,d1
	subq.w	#5,d1
	move.w	d1,d5
LBFDraw	move.l	d4,a0			* mask == NULL
	jsr	_LVOBltPattern(a6)
	movem.w	ra_MinX(a3),d0-d3	* Rectangle
	addq.w	#4,d0
	addq.w	#2,d1
	sub.w	d0,d2	
	subq.w	#3,d2
	sub.w	d1,d5
	move.w	d5,d3
	move.l	a4,a0			* REI...
	move.l	sp,d5			* Save Stack...
	pea	0
	pea	1
	pea	IA_Recessed
	move.l	sp,a1
	move.l	a5,a6
	bsr.s	_LVODrawFrameStateA
	move.l	d5,sp
	move.l	d4,rp_AreaPtrn(a2)	* Repristina tutto
	move.b	d4,rp_AreaPtSz(a2)
	addq.w	#4,sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	
***************************************************************************************
* (19-Jan-1995) =Jon= ---(rei,left,top,width,height,state,taglist) (a0,d0-d4,a1)
***************************************************************************************
_LVODrawFrameStateA
	movem.l	d2-d5/a2-a6,-(sp)
	move.l	a0,a4				* Save REI...
	move.l	sp,a5				* Salvo lo Stack pointer
	move.l	a1,-(sp)			* Next TagList... or TAG_DONE
	move.l	a1,d5				* Null Next Extra TagList?? == TAG_DONE
	beq.s	SkipMo
	pea	TAG_MORE			* Next TagList...
SkipMo	move.l	d3,-(sp)
	pea	IA_Height
	move.l	d2,-(sp)
	pea	IA_Width
	move.l	d1,-(sp)
	pea	IA_Top
	move.l	d0,-(sp)
	pea	IA_Left
	move.l	sp,a2				* move the taglist...
	lea	frameclassname(pc),a1
	suba.l	a0,a0
	move.l	ab_IntuiBase(a6),a6
	jsr	_LVONewObjectA(a6)
	move.l	a5,sp				* repristino Stack Pointer
	move.l	d0,d5				* d5 = Object
	beq.s	DFSExit
	move.l	([rei_Window.b,a4],wd_RPort.w),a0
	move.l	d5,a1					* Object
	move.l	([rei_VI.w,a4],vi_DrawInfo.w),a2		* DrawInfo
	moveq	#0,d0
	moveq	#0,d1
	move.l	d4,d2
	jsr	_LVODrawImageState(a6)	
	move.l	d5,a0
	jsr	_LVODisposeObject(a6)
	movem.l	(sp)+,d2-d5/a2-a6
DFSExit	rts
frameclassname	
	STRING "frameiclass"	

***************************************************************************************
** (18-Jan-1995) =Jon= --- ChangeAsmRequestAttrsA(areq,taglist) (a0/a1)
***************************************************************************************
_LVOChangeAsmReqAttrsA
	movem.l	d2-d3/a2-a6,-(sp)
	move.l	a6,a5				* Save AssemblyBase...
	move.l	a0,a4				* A4 = (struct AsmRequest *)
	move.l	a1,a0
	bra	AR_PTAG

***************************************************************************************
** (13-May-1995) =Jon= --- AllocAsmRequestA(taglist) (a0)
***************************************************************************************
STDICM	EQU	IDCMP_REFRESHWINDOW|IDCMP_CLOSEWINDOW|BUTTONIDCMP|IDCMP_ACTIVEWINDOW|IDCMP_IDCMPUPDATE
SIDCMP	EQU	STDICM|IDCMP_VANILLAKEY|IDCMP_NEWSIZE|LISTVIEWIDCMP

STADFL	EQU	WFLG_CLOSEGADGET|WFLG_ACTIVATE|WFLG_RMBTRAP|WFLG_DRAGBAR|WFLG_DEPTHGADGET
SFLAGS	EQU	STADFL		*** |WFLG_SIZEGADGET|WFLG_SIZEBBOTTOM|WFLG_SIMPLE_REFRESH

REIFLAGS	EQU	REIF_REQUEST|REIF_NOFONTSENSITIVE

AsmRequestTable
	dc.l AR_EXT,ARQLeft,ARQTop,ARQREI,ARQWindow,ARQScreen,ARQTitle,ARQIDCMP
	dc.l ARQIDCMPHook,ARQLockREI,ARQJust,ARQObject,ARQSound
	dc.l AR_TAGG,AR_TAGG 				** RESERVED
	dc.l ARQCenterH,ARQCenterV,ARQCenterM,ARQUnderObject
	dc.l ARQAPenPattern,ARQBPenPattern,ARQPubScreenName,ARQNewLookBackFill
	dc.l ARQReturnKey,ARQFrameOnly,ARQWindowFlags,ARQButtomHook
;--------------------------------------------------------------------------------------
_LVOAllocAsmRequestA
	movem.l	d2-d3/a2-a6,-(sp)
	move.l	a6,a5				* Save AssemblyBase...
	suba.l	a4,a4				* AllocMem()...
	move.l	a0,a2				* Save TagList...
	move.l	#4+areq_SIZEOF,d2		* memoria per la struttura AsmRequest
	move.l	d2,d0
	moveq	#1,d1
	swap	d1				* MEMF_CLEAR
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOAllocMem(a6)	
	move.l	d0,a4				* tutto ok??
	tst.l	d0
	bne.s	AR_Cont				* Ok, continua...
AR_EXT	move.l	a4,d0
	movem.l	(sp)+,d2-d3/a2-a6
	rts
;--------------------------------------------------------------------------------------
; Prima di saltare ai Tags, eseguiamo delle inizializzazioni standar, in caso via Tags
; saranno modificate, altrimenti rimaranno queste, nel caso nessun Tags venga inizia...
;--------------------------------------------------------------------------------------
AR_Cont	move.l	d2,(a4)+			* D2 = vero SizeOF - AllocVec() ;)
	move.l	a5,a6
	bsr	_LVOAllocRastPort			* Alloco per calcoli...
	move.l	d0,areq_SysRP(a4)			* System RastPort
	move.l	#SIDCMP,rei_NewWindow+nw_IDCMPFlags(a4)	* Set IDCMP
	move.l	#SFLAGS,rei_NewWindow+nw_Flags(a4)	* Set Flags
	moveq	#-1,d0
	move.l	d0,rei_NewWindow+nw_MaxHeight(a4)
	move.l	d0,rei_NewWindow+nw_MaxWidth(a4)
	move.l	#REIFLAGS,rei_Flags(a4)			* Mode Requester... for REI
	lea	areq_Hook(a4),a0			* Default LayoutCallBack Hook
	lea	LayFill(pc),a1				* routine...
	movem.l	a1/a4/a5,h_Entry(a0)			* Init...
	move.l	a0,rei_LayoutCallBack(a4)		* Use Defaul Hook standar...
	move.l	#$00020000,areq_FgPatternPen(a4)	* Default Pattern Color
	move.w	#ARQF_RETURNKEY,areq_Flags(a4)		* Set ON Return Key... default
	lea	areq_STDWindowTAG(a4),a0
	move.l	#WA_InnerWidth,(a0)		* Costruisco la Standar Window TAG
	move.l	#WA_InnerHeight,8(a0)
	move.l	#WA_AutoAdjust,16(a0)
	move.l	#1,20(a0)
	move.l	#TAG_MORE,24(a0)
	moveq	#0,d0				* Azzero questi Tags per sicurezza...
	move.l	d0,28(a0)
	move.l	d0,32(a0)
	move.l	a0,rei_STDWindowTAG(a4)
;--------------------------------------------------------------------------------------	
	move.l	ab_IntuiBase(a5),a6		* Prendo per default, l'indirizzo
	suba.l	a0,a0				* dello schermo pubblico... passando
	jsr	_LVOLockPubScreen(a6)		* NAME = NULL.
	move.l	d0,rei_Screen(a4)		* Dopo di che prendo la RastPort di
	move.l	d0,a1				* di questo schermo, e la salvo...
	lea	sc_RastPort(a1),a0
	move.l	a0,areq_ScreenRP(a4)
	suba.l	a0,a0
	jsr	_LVOUnlockPubScreen(a6)		* Unlokko lo schermo...
;--------------------------------------------------------------------------------------
	move.l	a2,a0				* Indirizzo della TagList...
;--------------------------------------------------------------------------------------	
AR_PTAG	USETAGLIST.s	AsmRequestTable(pc),AR_TAGG,AR_EXT2
AR_EXT2	move.l	a4,d0
	movem.l	(sp)+,d2-d3/a2-a6
	rts
;--------------------------------------------------------------------------------------
ARQLeft	move.l	(a0)+,d0
	move.w	d0,areq_LeftEdge(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQTop	move.l	(a0)+,d0
	move.w	d0,areq_TopEdge(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQREI	move.l	(a0)+,d0			* Prendo la struttura REI
	beq	AR_TAGG
	move.l	(rei_Screen.w,d0.l),a2		* (struct Screen *)
	move.l	a2,rei_Screen(a4)		* Stesso schermo, grazie...
	lea	sc_RastPort(a2),a2		* (struct RastPort *)
	move.l	a2,areq_ScreenRP(a4)		* Save it...
	tst.l	rei_NewWindow+nw_Title(a4)
	bne	AR_TAGG
	move.l	(rei_Window.w,d0.l),a2		* 
	move.l	wd_Title(a2),d1			* Titolo della Window di riferimento...
	beq	AR_TAGG
	move.l	d1,rei_NewWindow+nw_Title(a4)	* Set Req Title...
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQWindow
	move.l	(a0)+,d0			* Window/Screen output...
	beq	AR_TAGG				* Ok, usa il default pubscreen...
	move.l	(wd_WScreen.w,d0.l),a2		* Window's Screen...
	move.l	a2,rei_Screen(a4)		* In AsmRequest.. che inizia con la REI
	lea	sc_RastPort(a2),a2		* Prendo la RastPort dello schermo
	move.l	a2,areq_ScreenRP(a4)		* di output
	bra	AR_TAGG				* Aricomincia...
;--------------------------------------------------------------------------------------
ARQScreen
	move.l	(a0)+,a2			* (struct Screen *)
	move.l	a2,rei_Screen(a4)		* Set ScreenPtr Output
	lea	sc_RastPort(a2),a2		* (struct RastPort *)
	move.l	a2,areq_ScreenRP(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQTitle
	move.l	(a0)+,d0			* Check for NULL Title...
	move.l	d0,a2
	bne.s	okSet
	lea	defStr(pc),a2			* Prendiamo il Default Title x sicurezza
	move.l	rei_Window(a4),d0		* C'è la Window di riferimento??
	beq.s	okSet				* No, usiamo il default...
	move.l	(wd_Title.w,d0.l),d1		* Titolo della Window di riferimento...
	beq.s	okSet
	move.l	d1,a2
okSet	move.l	a2,rei_NewWindow+nw_Title(a4)	* Set Req Title...
	bra	AR_TAGG
defStr	STRING <"System Request">	
;--------------------------------------------------------------------------------------
ARQIDCMP
	move.l	#SIDCMP,rei_NewWindow+nw_IDCMPFlags(a4)	* Set IDCMP
	move.l	(a0)+,d0
	or.l	d0,rei_NewWindow+nw_IDCMPFlags(a4)	* Aggiungo IDCMPFlags...
	move.l	d0,areq_IDCMPFlags(a4)			* Li salvo per controllo...
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQIDCMPHook
	move.l	(a0)+,areq_IDCMPHook(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQLockREI
	move.l	(a0)+,areq_LockREI(a4)			* REI da bloccare...
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQJust	move.l	(a0)+,d0
	move.w	d0,areq_TextFlags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQObject					* Inserisce l'Object nella nostra
	move.l	(a0)+,d0
	move.l	d0,areq_Object(a4)		* setta comunque
	beq	AR_TAGG				* Se NULL esci...
	move.l	a0,d2
	move.l	d0,a0				* Object *
	move.l	sp,d3				* salvo lo stack
	subq.w	#8,sp
	move.l	sp,a3				* chiedo informazioni sulle
	pea	TAG_DONE			* dimensioni di quest'oggetto
	move.l	a3,-(sp)			* e le registro in una ULONG
	pea	DTA_NominalVert			* per uso successivo...
	addq.w	#4,a3
	move.l	a3,-(sp)
	pea	DTA_NominalHoriz
	move.l	sp,a2				* Attrs
	move.l	ab_DataTypesBase(a5),a6
	jsr	_LVOGetDTAttrsA(a6)		* prendo infos...
	move.l	(a3),areq_ObjectWidth(a4)	* salvo dimensioni nella AsmRequest
	subq.w	#4,a3
	move.l	(a3),areq_ObjectHeight(a4)	
	move.l	d3,sp				* Repristino StackPointer....
	move.l	d2,a0
	bra	AR_PTAG
;--------------------------------------------------------------------------------------
ARQSound
	move.l	(a0)+,areq_Sound(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQCenterH
	move.l	(a0)+,d0
	bne.s	ACHFSET
	BCLRL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	AR_TAGG
ACHFSET	BSETL	REIB_CENTERHSCREEN,rei_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQCenterV
	move.l	(a0)+,d0
	bne.s	ACVFSET
	BCLRL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	AR_TAGG
ACVFSET	BSETL	REIB_CENTERVSCREEN,rei_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQCenterM
	move.l	(a0)+,d0
	bne.s	ACMFSET
	BCLRL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	AR_TAGG
ACMFSET	BSETL	REIB_CENTERMOUSE,rei_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQUnderObject
	BCLRW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)
	move.l	(a0)+,d0
	beq	AR_TAGG
	BSETW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQAPenPattern
	move.l	(a0)+,d0
	move.w	d0,areq_FgPatternPen(a4)	* Default Pattern Color
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQBPenPattern
	move.l	(a0)+,d0
	move.w	d0,areq_BgPatternPen(a4)	* Default Pattern Color
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQPubScreenName
	move.l	(a0)+,d2			* nome schermo pubblico
	exg.l	a0,d2
	move.l	ab_IntuiBase(a5),a6		* 
	jsr	_LVOLockPubScreen(a6)		* 
	move.l	d0,rei_Screen(a4)		* Dopo di che prendo la RastPort di
	move.l	d0,a1
	lea	sc_RastPort(a1),a0
	move.l	a0,areq_ScreenRP(a4)
	suba.l	a0,a0
	jsr	_LVOUnlockPubScreen(a6)		* Unlokko lo schermo...
	move.l	d2,a0
	bra	AR_PTAG
;--------------------------------------------------------------------------------------
ARQNewLookBackFill
	lea	LayFill(pc),a2
	move.l	(a0)+,d0
	beq.s	StaDefH
	lea	NewLookLayFill(pc),a2
StaDefH	lea	areq_Hook(a4),a1
	move.l	a2,h_Entry(a1)
	bra	AR_PTAG
;--------------------------------------------------------------------------------------
ARQReturnKey
	BCLRW	ARQB_RETURNKEY,areq_Flags(a4)
	move.l	(a0)+,d0
	beq	AR_TAGG
	BSETW	ARQB_RETURNKEY,areq_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
FONLY	SET	WFLG_CLOSEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET
ARQFrameOnly
	move.l	(a0)+,d0
	beq.s	FONLOFF
	andi.l	#~FONLY,rei_NewWindow+nw_Flags(a4)
	move.l	#0,rei_NewWindow+nw_Title(a4)
	bra	AR_TAGG
FONLOFF	ori.l	#FONLY,rei_NewWindow+nw_Flags(a4)
	bra	AR_TAGG
;--------------------------------------------------------------------------------------
ARQWindowFlags
	move.l	(a0)+,d0
	or.l	d0,rei_NewWindow+nw_Flags(a4)	
	bra	AR_TAGG
;--------------------------------------------------------------------------------------	
ARQButtomHook
	move.l	(a0)+,areq_ButtomHook(a4)
	bra	AR_TAGG	
	
***************************************************************************************
** (18-Jan-1995) =Jon= --- FreeAsmRequest(areq) (A0)
***************************************************************************************
_LVOFreeAsmRequest
	movem.l	a2-a6,-(sp)
	move.l	a6,a5			* Save AssemblyBase
	move.l	a0,a4			* Save AsmRequest
	move.l	ab_ExecBase(a5),a6	* Prendo Exec
	move.l	areq_SysRP(a4),a1	* System RastPort
	move.l	-(a1),d0		* Pack Alloc
	jsr	_LVOFreeMem(a6)	
	move.l	a4,a1			* AsmRequest...
	move.l	-(a1),d0		* Pack Alloc
	jsr	_LVOFreeMem(a6)		* Libera la memoria dalla str AsmRequest
	movem.l	(sp)+,a2-a6
	rts

***************************************************************************************
** (18-Jan-1995) =Jon= --- AsmRequestArgs(areq,TextFmt,GadFmt,ArgList) (a0/a1/a2/a3)
***************************************************************************************
_LVOAsmRequestArgs
	movem.l	d2-d7/a2-a6,-(sp)	* Save praticamente tutto...
	move.l	a6,a5			* Save AssemblyBase in A5
	move.l	a0,a4			* AsmRequest fix in A4
	movem.l	a1-a3,areq_TextFmt(a4)	* Save TextFmt, GadFmt, DataStrem
;--------------------------------------------------------------------------------------	
	move.l	areq_LockREI(a4),d0	* C'è una REI da bloccare??
	beq.s	PCalc			* no, continua...
	move.l	d0,a0
	bsr	_LVOLockREI
;--------------------------------------------------------------------------------------
; Calcoliamo width & height minimi del Request, cioè senza Text o Image... più però
; eventuali Gadgets... D6 è una costante = 14
;--------------------------------------------------------------------------------------	
PCalc	moveq	#12,d6					* MakeCostant
	add.b	([rei_Screen.b,a4],sc_WBorBottom.w),d6
	moveq	#0,d0
	move.b	([rei_Screen.b,a4],sc_WBorLeft.w),d0
	add.b	([rei_Screen.b,a4],sc_WBorRight.w),d0
	add.w	#8+12,d0
	move.w	d0,rei_NewWindow+nw_Width(a4)		* Min Width
	move.w	d6,rei_NewWindow+nw_Height(a4)		* Min Height
	move.l	areq_LeftEdge(a4),rei_NewWindow+nw_LeftEdge(a4)
	tst.l	areq_GadFmt(a4)				* Ci sono Gadgets??
	beq.s	CkText					* No, prosegui...
	move.w	([areq_ScreenRP.b,a4],rp_TxHeight.w),d0
	move.w	d0,d1
	asr.w	#1,d0
	add.w	d0,d1
	addq.w	#8,d1
	add.w	d1,rei_NewWindow+nw_Height(a4)		* New Min Height
;--------------------------------------------------------------------------------------
; Calcoliamo quanto occupa il Testo nel request...
;--------------------------------------------------------------------------------------	
CkText	move.l	areq_TextFmt(a4),d0			* Esiste un testo?
	beq.s	CKObject				* No, salta questa parte...
	move.l	d0,a0
	move.l	areq_SysRP(a4),a1
	move.l	areq_DataStream(a4),a2
	moveq	#0,d0				* Calcoliamo la grandezza del Testo
	moveq	#0,d1				* Usando una chiamata diretta...
	moveq	#0,d2
	move.w	#TEXTF_PRIVATE,d2		* Set Private Flags Result
	bsr	_LVOTextFmtRastPortArgs		* 
	move.l	d0,areq_GadArgList(a4)		* ArgList successiva per i Gadgets...
	move.l	d1,areq_IBox+ibox_Width(a4)	* dimensioni...
	move.l	ab_ExecBase(a5),a6		* formattato ed Allocato.
	move.l	-(a1),d0			* Lo libero perchè tanto lo devo
	jsr	_LVOFreeMem(a6)			* da ristampare comunque...
	move.l	a5,a6				* AssemblyBase...
	movem.w	areq_IBox+ibox_Width(a4),d0-d1
	add.w	d0,rei_NewWindow+nw_Width(a4)		* Larghezza
	add.w	d1,rei_NewWindow+nw_Height(a4)		* Altezza
	move.w	d6,areq_IBox+ibox_Left(a4)		* Da qui il testo...
	move.w	([areq_SysRP.w,a4],rp_TxBaseline.w),d0
	addq.w	#6,d0
	move.w	d0,areq_IBox+ibox_Top(a4)
;--------------------------------------------------------------------------------------
CKObject	
	move.l	areq_Object(a4),d0		* Esiste un'Object??
	bne.s	MakeObj				* 
	move.l	d0,areq_ObjectWidth(a4)
	move.l	d0,areq_ObjectHeight(a4)	
	bra.s	CaGads
	
MakeObj	BTSTW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)	
	bne.s	Under				* Vado a mettere tutto sotto...
;--------------------------------------------------------------------------------------	
	move.w	areq_IBox+ibox_Height(a4),d0	* height del testo... se c'è...
	move.l	areq_ObjectHeight(a4),d1	* height Object... che c'è per forza...
	sub.w	d0,d1				* D1 - D0 = d1 (se D0 = NULL)!!
	ble.s	SAddH
	add.w	d1,rei_NewWindow+nw_Height(a4)
SAddH	move.l	areq_ObjectWidth(a4),d1
	addq.l	#8,d1				* /////
	add.w	d1,rei_NewWindow+nw_Width(a4)
	add.w	d1,areq_IBox+ibox_Left(a4)
	bra.s	CaGads
;--------------------------------------------------------------------------------------	
Under	move.w	areq_IBox+ibox_Width(a4),d0	* width del testo... se c'è...
	move.l	areq_ObjectWidth(a4),d1		* width Obejct... che c'è per forza...
	sub.w	d0,d1				* D1 - D0 = d1 (se D0 = NULL)!!
	ble.s	SAddW
	add.w	d1,rei_NewWindow+nw_Width(a4)
SAddW	move.l	areq_ObjectHeight(a4),d1
	addq.l	#4,d1
	add.w	d1,rei_NewWindow+nw_Height(a4)
	add.w	d1,areq_IBox+ibox_Top(a4)
;--------------------------------------------------------------------------------------	
; Andiamo a vedere se devono essere addizionati dei Gadget. Se esistono, li formattiamo
; e andiamo a vedere quanto occupano (width, height), allargando la Window se necess...
;--------------------------------------------------------------------------------------	
CaGads	lea	rei_HEADAsmGadget(a4),a0	* Resetto la lista per accogliere gli
	NEWLIST	a0				* eventuali Gadgets...
	move.l	areq_GadFmt(a4),d0		* Ci sono Gadgets...??
	beq.s	Show				* No, prosegui
	move.l	areq_ScreenRP(a4),a1		* Screen RastPort
	move.l	areq_GadFmt(a4),a0		* Gadget Format Text
	move.l	areq_GadArgList(a4),a2		* Succ ArgList for Gadget
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#TEXTF_PRIVATE,d2		* Set Private Flags Result
	bsr	_LVOTextFmtRastPortArgs		* Calling in private mode operation...
	move.l	a1,areq_GadFmt(a4)	* Gadget formattati... testo vero allocato...
	swap	d1
	move.w	d1,areq_GadFmtWidth(a4)		* Salvo Grandezza della Gadget String
	bsr	CreateGadFmt
	tst.l	d0				* Controlliamo se tutto è andato Ok...
	beq	FreeGTX				* C'è stato qualche errore...
;--------------------------------------------------------------------------------------	
Show	move.l	a4,a0				* Structure REI
	suba.l	a2,a2				* NULL TagList...
	bsr	_LVOOpenREIA			* Showing Requester...
	tst.l	d0
	bne.s	ARGLay
	move.l	areq_LockREI(a4),d0		* C'è una REI da Sbloccare??
	beq	CExit				* no, continua...
	move.l	d0,a0
	bsr	_LVOUnlockREI
	moveq	#0,d0
	movem.l	(sp)+,d2-d7/a2-a6		* ERROR la REI non si è aperta...
	rts
;--------------------------------------------------------------------------------------
ARGLay	tst.l	areq_TextFmt(a4)			* Esiste un testo?
	beq	ARGWait					* No, attendi un Mes allora...
ARGText	movem.w	ab_FgPenRequest(a5),d0-d2
	move.l	([rei_Window.w,a4],wd_RPort.w),a1	* RastPort...
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOSetABPenDrMd(a6)
	move.l	([rei_Window.w,a4],wd_RPort.w),a1	* RastPort...
	move.l	a1,areq_ReqRP(a4)			* Save in AsmRequest...
	move.l	areq_TextFmt(a4),a0
	move.l	areq_DataStream(a4),a2
;;;;;;;;move.w	areq_IBox+ibox_Left(a4),d0;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	moveq	#0,d0
	BTSTW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)	
	bne.s	NoUnder
	add.w	areq_ObjectWidth+2(a4),d0
NoUnder	add.w	([rei_Window.w,a4],wd_Width.w),d0
	sub.w	areq_IBox+ibox_Width(a4),d0
	asr.w	#1,d0
	
	BTSTW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)	
	bne.s	NoYCent
	move.w	areq_IBox+ibox_Height(a4),d2
	move.w	areq_ObjectHeight+2(a4),d1
	sub.w	d2,d1
	ble.s	NoYCent
	asr.w	#1,d1
	add.w	areq_IBox+ibox_Top(a4),d1	
	bra.s	YeYCent	
		
NoYCent	move.w	areq_IBox+ibox_Top(a4),d1
YeYCent	move.w	areq_TextFlags(a4),d2
	moveq	#0,d3
	move.b	([rei_Window.w,a4],wd_BorderTop.w),d3
	add.w	d3,d1
	move.l	a5,a6
	bsr	_LVOTextFmtRastPortArgs
;--------------------------------------------------------------------------------------
	move.l	areq_Object(a4),d0		* Esiste un Object da agganciare
	beq	ARGSnd				* No, vedi se esiste un souno...
	move.l	sp,d7				* Salvo lo StackPointer
	pea	TAG_DONE
	pea	([areq_ObjectHeight.w,a4])
	pea	GA_Height			* GA_Height
	pea	([areq_ObjectWidth.w,a4])	
	pea	GA_Width			* GA_Width
	moveq	#0,d1
	move.b	([rei_Window.w,a4],wd_BorderTop.w),d1
	addq.w	#6,d1				* Default Top value
	move.l	d1,-(sp)
	pea	GA_Top				* GA_Top	
	moveq	#14,d1
	BTSTW	ARQB_TEXTUNDEROBJECT,areq_Flags(a4)
	beq.s	SkCent	
	move.w	([rei_Window.w,a4],wd_Width.w),d1
	sub.w	areq_ObjectWidth+2(a4),d1
	asr.w	#1,d1
SkCent	move.l	d1,-(sp)
	pea	GA_Left				* GA_Left
	pea	1
	pea	DTA_Immediate			* (ON) DTA_Immediate
	pea	ICTARGET_IDCMP
	pea	ICA_TARGET			* (SET) ICA_TARGET
	move.l	ab_DataTypesBase(a5),a6
	move.l	d0,a0				* Object *
	move.l	rei_Window(a4),a1		* Window
	suba.l	a2,a2				* Requester
	move.l	sp,a3				* Attrs
	jsr	_LVOSetDTAttrsA(a6)
	move.l	d7,sp				* Repristino lo stack...
	move.l	rei_Window(a4),a0		* Window	
	suba.l	a1,a1				* Request
	move.l	areq_Object(a4),a2		* Object
	moveq	#-1,d0				* Position
	jsr	_LVOAddDTObject(a6)
	move.l	areq_Object(a4),a0		* Object
	move.l	rei_Window(a4),a1		* Window
	suba.l	a2,a2				* Request
	move.l	a2,a3				* Addizional Attribute (none define)...
	jsr	_LVORefreshDTObjectA(a6)
	move.l	a5,a6
;--------------------------------------------------------------------------------------	
ARGSnd	move.l	areq_Sound(a4),d0		* Esiste un oggetto da suonare??
	beq.s	ARGWait				* No allora mettiti in attesa...
	move.l	d0,a2				* Object in A2
	move.l	sp,a3				* Save Satck...
	pea	0
	pea	STM_PLAY
	pea	0
	pea	DTM_TRIGGER
	move.l	sp,a1
	DOMETHODA
	move.l	a3,sp
;--------------------------------------------------------------------------------------
ARGWait	move.l	a4,a0				* (struct REI *)
	moveq	#"_",d0				* Underscore
	bsr	_LVOWaitREIMsg			* Attendiamo un messaggio...
	move.l	d0,a0				* (struct REIMessage *)
	
	move.l	rim_Class(a0),d0
	and.l	areq_IDCMPFlags(a4),d0		* IDCMPFlags aggiuntivi??
	bne.s	CkHook
	
	move.l	rim_REICode(a0),d0		* Prendo REICode per vedere se è stato
	sub.l	#"QUIT",d0			* premuto un bottone...
	beq.s	ClosREI
	moveq	#0,d0
	move.l	d0,areq_Response(a4)
	move.l	d0,rim_REICode(a0)		* Lo pulisco per evitare confusione...
	
	move.l	rim_Class(a0),d0
	sub.l	#IDCMP_NEWSIZE,d0
	beq	ARGText				* Future implement of ReSizeing...
	sub.l	#(IDCMP_CLOSEWINDOW-IDCMP_NEWSIZE),d0	* IDCMP_CLOSEWINDOW
	beq.s	ClosREI
	sub.l	#(IDCMP_VANILLAKEY-IDCMP_CLOSEWINDOW),d0
	beq	ARGCKey
	sub.l	#(IDCMP_IDCMPUPDATE-IDCMP_VANILLAKEY),d0
	beq	ARGWTag
	bra.s	ARGWait
;--------------------------------------------------------------------------------------
; Chiamiamo un CustumHook per gestire degli IDCMP aggiuntivi...
;--------------------------------------------------------------------------------------
CkHook	move.l	d0,areq_Response(a4)		* IDCMPFlags ricevuto...
	move.l	areq_IDCMPHook(a4),d0
	beq.s	ClosREI
	move.l	d0,a0				* A0 = (struct Hook *)
	lea	rei_REIMessage(a4),a1		* A1 = (struct REIMessage *)
	move.l	a4,a2				* A2 = (struct REI *) Rev.(13.5.95)
	move.l	h_Entry(a0),a3
	move.l	#0,rim_REICode(a1)
	jsr	(a3)
	addq.l	#1,d0				* Check for ~0
	beq.s	ClosREI				* Ok, restituito -1, quindi esci...
	bra.s	ARGWait				* niente, continua come prima...
;--------------------------------------------------------------------------------------
ClosREI	move.l	areq_Object(a4),d0		* E' stato aggiunto un'Object??
	beq.s	CCLREI				* No, prosegui...
	move.l	d0,a1				* Object da rimuovere
	move.l	rei_Window(a4),a0		* su questa Window...
	move.l	ab_DataTypesBase(a5),a6		* Non liberiamo la memoria, in modo che
	jsr	_LVORemoveDTObject(a6)		* l'Object può essere riusato...
;--------------------------------------------------------------------------------------
; Prima di chiudere tutto, controllo se era stato messo un ButtomHook
;--------------------------------------------------------------------------------------
CCLREI	move.l	a5,a6
	move.l	areq_ButtomHook(a4),d0
	beq.s	CREIHOK
	move.l	d0,a0				* A0 = (struct Hook *)
	lea	rei_REIMessage(a4),a1		* A1 = (struct REIMessage *)
	move.l	a4,a2				* A2 = (struct REI *) Rev.(13.5.95)
	move.l	h_Entry(a0),a3
	move.l	areq_Response(a4),rim_REICode(a1) * Numero gadget premuto...
	jsr	(a3)
	addq.l	#1,d0				* Check for ~0
	bne	ARGWait				* niente, continua come prima...

CREIHOK	move.l	a4,a0				* Chiudiamo il Request...
	bsr	_LVOCloseREI
;--------------------------------------------------------------------------------------		
	move.l	a4,a0				* Se ci sono li libera altrimenti no..
	bsr	_LVOFreeAsmGList		* esce safely sempre e comunque...
;--------------------------------------------------------------------------------------		
FreeGTX	move.l	areq_GadFmt(a4),d0		* Sono stati creati dei Gadgets...???
	beq.s	NoUnLk				* No, proseguii...
	move.l	ab_ExecBase(a5),a6		* Libero il testo allocato per i
	move.l	d0,a1				* Gadgets...
	move.l	-(a1),d0			* 
	jsr	_LVOFreeMem(a6)			* 
	move.l	a5,a6
;--------------------------------------------------------------------------------------	
NoUnLk	move.l	areq_LockREI(a4),d0		* C'è una REI da Sbloccare??
	beq.s	CExit				* no, continua...
	move.l	d0,a0
	bsr	_LVOUnlockREI
;--------------------------------------------------------------------------------------	
CExit	move.l	areq_Response(a4),d0		* RESULT...
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
; Gestione eventi da tastiera - A0 = (struct REIMessage *)
;--------------------------------------------------------------------------------------
EscEsc	cmpi.w	#27,d2				* 27 = Escape...
	bne	ARGWait				* non è stato premuto Escape...
	moveq	#0,d0
	bra	KExit
;--------------------------------------------------------------------------------------
ARGCKey	move.w	rim_Code(a0),d2			* Codice Tasto...
	tst.l	([rei_HEADAsmGadget.w,a4])	* Ci sono Gadgets...
	beq.s	EscEsc
;--------------------------------------------------------------------------------------
	BTSTW	ARQB_RETURNKEY,areq_Flags(a4)
	beq.s	ChekEsc
	cmpi.w	#13,d2
	bne.s	ChekEsc
	move.l	rei_HEADAsmGadget(a4),a2	* Primo...
	bra.s	SimPres
;--------------------------------------------------------------------------------------
ChekEsc	cmpi.w	#27,d2				* 27 = Escape...
	bne.s	CCheckK				* non è stato premuto Escape...
	move.l	areq_LastAsmGadget(a4),a2	* Ultimo
	bra.s	SimPres
;--------------------------------------------------------------------------------------
CCheckK	move.w	rim_Qualifier(a0),d0
	sub.b	#IEQUALIFIER_LCOMMAND,d0
	bne.s	AKeyNo
	move.l	areq_LastAsmGadget(a4),a2	* Ultimo...
	sub.w	#"b",d2
	beq.s	SimPres
	move.l	rei_HEADAsmGadget(a4),a2		* Primo...
	sub.w	#"v"-"b",d2
	beq.s	SimPres
AKeyNo	bra	ARGWait
;--------------------------------------------------------------------------------------
SimPres	move.l	a2,a3					* A3 (struct AsmGadget *)
	move.l	agg_Gadget(a3),a2			* A2 (struct Gadget *)
	move.l	([rei_Window.w,a4],wd_RPort.w),a0	* RastPort
	move.l	gg_GadgetRender(a2),a1			* Image
	movem.w	gg_LeftEdge(a2),d0-d1			* coordinate
	moveq	#IDS_SELECTED,d2			* Modo --selezionato--
	move.l	([rei_VI.w,a4],vi_DrawInfo.w),a2	* take private drawinfo...
	move.l	ab_IntuiBase(a5),a6	
	jsr	_LVODrawImageState(a6)			* drawing
	move.w	ab_TicksDelay(a5),d1			* from assembly preferences
	ext.l	d1
	move.l	ab_DosBase(a5),a6
	jsr	_LVODelay(a6)				* Waiting...
	move.l	agg_Gadget(a3),a0			* (struct Gadget *)
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVORefreshGadgets(a6)
	moveq	#0,d0
	move.w	agg_NewGadget+gng_GadgetID(a3),d0
KExit	move.l	d0,areq_Response(a4)
	bra	ClosREI
;--------------------------------------------------------------------------------------
; Simple Hook per tutti i Bottoni del Request...
;--------------------------------------------------------------------------------------
SaveID	move.l	#"QUIT",rim_REICode(a1)		* REICode...
	moveq	#0,d0
	move.w	agg_NewGadget+gng_GadgetID(a2),d0		* Codice di ritorno...
	lea	-rei_REIMessage(a1),a0		* Prendo l'indirizzo della mia REI...
	move.l	d0,areq_Response(a0)
	moveq	#0,d0				* Per compatibilità con gli Hook...
	rts
;--------------------------------------------------------------------------------------
; Attende i messaggi via Tag da un DataTypesObject... in A6 = asmbase... A5 scratch
;--------------------------------------------------------------------------------------
ARGWTag	move.l	rim_IAddress(a0),a5		* cancello temp la asmbase...
WTagLop	move.l	(a5)+,d0
	bne.s	WTagEla
	move.l	a6,a5
	bra	ARGWait
WTagEla	sub.l	#DTA_Sync,d0
	beq.s	WTagRef
	addq.w	#4,a5
	bra.s	WTagLop
;--------------------------------------------------------------------------------------		
WTagRef	move.l	a6,d5				* Save Temp AsmBase...
	move.l	ab_DataTypesBase(a6),a6
	move.l	areq_Object(a4),a0
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	move.l	a2,a3
	jsr	_LVORefreshDTObjectA(a6)
	move.l	d5,a6
	addq.w	#4,a5
	bra.s	WTagLop
***************************************************************************************
* Alloca le struttura AsmGadget, le inizializza e le aggancia alla REI. Questa routine
* alloca solo Gadget BUTTON e li inizializza creando un layout orizzontale...
***************************************************************************************
CreateGadFmt
	movem.l	d2-d7/a2-a3,-(sp)
	move.l	sp,a3			* Salvo lo Stack... per il reset successivo
	move.l	areq_GadFmt(a4),a0	* Stringa dei Gadget Allocati e formattati...
	move.l	a0,a1			* In A1 per vedere quando ho finito...
	add.l	-(a0),a0		* Vado alla fine della stringa completa...
	moveq	#1,d7			* D7 = Almeno un Gadget deve esistere!!!
	moveq	#"|",d1			* Usato per la comparazione...
	moveq	#0,d2			* Usato per pulire "|"
ARQGGLP	cmpa.l	a0,a1			* Sono tornato all'inizio della stringa???
	beq.s	ARQGEND			* Si, quindi ho finito, vado a buff questa...
	cmp.b	-(a0),d1		* Check #"|"...
	bne.s	ARQGGLP			* Continua a cercare...
	move.b	d2,(a0)+		* Pulisci mettendo uno zero al posto di #"|"
	move.l	a0,-(sp)		* Bufferrizza la stringa
	addq.w	#1,d7			* Incrementa numero di Gadgets da allocare...
	bra.s	ARQGGLP			* Ricomincia il loop...
ARQGEND	move.l	a0,-(sp)		* Bufferizzo l'ultima (prima)...
;--------------------------------------------------------------------------------------
	subq.w	#1,d7			* Controllo se è un solo Gadget...
	beq	ARQGONE			* Se è uno solo, fallo a parte...
	move.w	d7,d2
AllGads	suba.l	a0,a0
	moveq	#BUTTON_KIND,d0
	bsr	_LVOAllocAsmGadget
	tst.l	d0
	beq	ARQGERR			* Memoria insufficiente... Errore, esci...
	move.l	d0,a1			* Nodo AsmGadget...
	lea	rei_HEADAsmGadget(a4),a0	* Lista degli AsmGadget...	
	ADDTAIL
	dbf	d2,AllGads
;--------------------------------------------------------------------------------------
	move.w	areq_GadFmtWidth(a4),d2	* Grandezza della Gadget String
	move.l	areq_ScreenRP(a4),a1	* RastPort
	move.w	rp_TxWidth(a1),d1	* Width...
	add.w	d1,d2
	mulu.w	d7,d1
	add.w	d1,d2
	move.w	d7,d1
	asl.w	#3,d1
	add.w	d1,d2
	add.w	#8+8+8,d2		* Vari bordi...
	sub.w	rei_NewWindow+nw_Width(a4),d2
	ble.s	SKPPOLI
	add.w	d2,rei_NewWindow+nw_Width(a4)
;-------------------------------------------------------------------------------------- 
SKPPOLI	subq.w	#1,d7			* Aggiusto il valore per il DBF
	move.l	rei_HEADAsmGadget(a4),a2	* A2 = Primo AsmGadget...
;--------------------------------------------------------------------------------------
; Inizializziamo D7-1 Strutture Gadget... l'ultimo lo si fa a parte...	
;--------------------------------------------------------------------------------------
	moveq	#0,d6			* D6 = GadgetID per ogni Bottone...
	move.l	#AGF_RELBBOTTOM,d4	* D4 = Flags per tutti...
	move.l	#$00040002,d3		* D3 = Pixel separation...
	lea	SimpleHook(pc),a0	* (struct Hook *)
	move.l	a0,d2			* D2 = Fix pointer Hook...
	suba.l	a0,a0			* A0 = XChild... per il Primo è NULL...
;--------------------------------------------------------------------------------------
ARQIGAD	addq.w	#1,d6			* Incrementa il Codice GadgetID
	move.l	(sp)+,agg_NewGadget+gng_GadgetText(a2)	* TextFmt...
	move.l	d2,agg_NewGadget+gng_UserData(a2)	* (struct Hook *)
	move.w	d6,agg_NewGadget+gng_GadgetID(a2)	* Code ID per ogni Gadget...
	move.l	d3,agg_LeftEdge(a2)	* Pixel separator...
	move.l	d4,agg_Flags(a2)	* Special Relative Flags setting...
	move.l	a0,agg_XChild(a2)	* XChild...		
;--------------------------------------------------------------------------------------	
	move.l	a2,a0			* Set New XChild...
	move.l	LN_SUCC(a0),a2
	dbf	d7,ARQIGAD
;--------------------------------------------------------------------------------------
; Questa Parte inizializza i dati relativi all'ultimo A2 = Gadget...
;--------------------------------------------------------------------------------------
	move.l	a2,areq_LastAsmGadget(a4)	* For simulation press gadget... ;)
	move.l	(sp)+,agg_NewGadget+gng_GadgetText(a2)	* TextFmt...
	move.l	d2,agg_NewGadget+gng_UserData(a2)		* (struct Hook *)
	move.l	d3,agg_LeftEdge(a2)		* Pixel separator...
	move.l	#AGF_RELBBOTTOM|AGF_RELBRIGHT,agg_Flags(a2)
;--------------------------------------------------------------------------------------
	move.l	a2,d0			* Return TRUE...
ARQGERR	move.l	a3,sp
	move.l	a5,a6
	movem.l	(sp)+,d2-d7/a2-a3
	rts
;--------------------------------------------------------------------------------------
ARQGONE	move.w	areq_GadFmtWidth(a4),d0	* Grandezza della Gadget String
	move.l	areq_ScreenRP(a4),a1	* RastPort
	add.w	rp_TxWidth(a1),d0
	add.w	#8+8+8,d0		* Vari bordi...
	sub.w	rei_NewWindow+nw_Width(a4),d0
	ble.s	SKPONE
	add.w	d0,rei_NewWindow+nw_Width(a4)
SKPONE	suba.l	a0,a0
	moveq	#BUTTON_KIND,d0
	bsr	_LVOAllocAsmGadget
	tst.l	d0
	beq.s	ARQGERR			* Memoria insufficiente... Errore, esci...
	move.l	d0,a1
	move.l	a1,a2
	lea	rei_HEADAsmGadget(a4),a0	* Lista degli AsmGadget...	
	ADDTAIL
;--------------------------------------------------------------------------------------
; Inizializziamo quest'unico Gadgets...
;--------------------------------------------------------------------------------------
	moveq	#0,d6			* D6 = GadgetID per ogni Bottone...
	move.l	#AGF_HCENTER|AGF_RELBBOTTOM,d4	* D4 = Flags solo per quest'unico gad
	moveq	#2,d3			* D3 = Pixel separation...
	lea	SimpleHook(pc),a0	* (struct Hook *)
	move.l	a0,d2			* D2 = Fix pointer Hook...
;--------------------------------------------------------------------------------------
	move.l	a2,areq_LastAsmGadget(a4)	* For simulation press gadget... ;)
	move.l	(sp)+,agg_NewGadget+gng_GadgetText(a2)	* TextFmt...
	move.l	d2,agg_NewGadget+gng_UserData(a2)	* (struct Hook *)
	move.w	d6,agg_NewGadget+gng_GadgetID(a2)	* Code ID per ogni Gadget...
	move.w	d3,agg_TopEdge(a2)	* Pixel separator...
	move.l	d4,agg_Flags(a2)	* Special Relative Flags setting...
;--------------------------------------------------------------------------------------
	move.l	a2,d0			* Return TRUE...
	move.l	a3,sp
	move.l	a5,a6
	movem.l	(sp)+,d2-d7/a2-a3
	rts
;--------------------------------------------------------------------------------------
; Simple Hook structure per tutti i Bottoni del Request...
;--------------------------------------------------------------------------------------
SimpleHook
	dc.l 0,0			* Minimal Node to NULL
	dc.l SaveID			* Routine di Uscita...
	dc.l 0,0			* il resto a NULL...
;--------------------------------------------------------------------------------------

*****i* assembly.library/AllocAsmGadget ****************************************
*
*   NAME   
*	AllocAsmGadget -- Alloca un AsmGadget.
*
*   SYNOPSIS
*	asmgadget = AllocAsmGadget(name,kind)
*	   D0                       A0   D0
*
*   FUNCTION
*	Questa funzione alloca in memoria una struttura AsmGadget, creando anche
*	la relativa struttura StandarTag. L'AsmGadget così creato, NON viene
*	agganciato alla rei, è compito del Task provvedere alla concatenazione in
*	lista.
*
*   INPUTS
*	name - Nome/ID dell'AsmGadget.
*	kind - Tipo di Gadget da Allocare, vedi gadtools define.
*
*   RESULT
*	asmgadget - Struttura AsmGadget o NULL se errore.
*
*   EXAMPLE
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	FreeAsmGList()
*
****************************************************************************
*
* Per adesso alloca solo Button_Kind...
*
*
STDTAGS	dc.l 0,BUTTONTAG_SIZEOF
STDTAG	dc.l 0,BUTTAG
;--------------------------------------------------------------------------------------
BUTTAG	dc.l GA_Disabled,0
 	dc.l GT_Underscore,$5F
 	dc.l GA_Immediate,0
	dc.l TAG_DONE
;--------------------------------------------------------------------------------------
_LVOAllocAsmGadget
	movem.l	d5-d7/a2-a6,-(sp)
	move.l	d0,d7				* Save Kind
	move.l	a0,a2				* Save name
	lea	STDTAGS(pc),a0
	move.l	(a0,d7.w*4),d0			* SIZEOF della Standar Tag...
	move.l	d0,d6				* D6=SIZEOF...
	add.w	#agg_SIZEOF+4,d0		* L'intera struttura...
	move.l	d0,d5
	moveq	#1,d1
	swap	d1
	addq.w	#1,d1
	move.l	ab_ExecBase(a6),a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	AAGExit
	move.l	d0,a3
	move.l	d5,(a3)+			* Simulate AllocVec()...
	lea	STDTAG(pc),a0
	move.l	(a0,d7.w*4),a0			* Indirizzo della TagList...
	lea	agg_SIZEOF(a3),a1		* Mia TagList vuota...
	asr.w	#2,d6				* copio a LONG
	subq.w	#1,d6
CopTag	move.l	(a0)+,(a1)+
	dbf	d6,CopTag
	lea	agg_SIZEOF(a3),a1		* Mia TagList copiata....
	move.l	a1,agg_TagList(a3)
	move.l	d7,agg_Kind(a3) 
	move.l	a2,LN_NAME(a3)
	move.l	a3,d0
AAGExit	movem.l	(sp)+,d5-d7/a2-a6
	rts

***************************************************************************************
* (07-Feb-1995) --- FreeAsmGList(rei) (a0)
***************************************************************************************	
_LVOFreeAsmGList
	movem.l	a4-a6,-(sp)
	lea	rei_HEADAsmGadget(a0),a4	* A4 = struttura List
	move.l	ab_ExecBase(a6),a6		* Prendo subito Exec...
FALCont	move.l	(a4),a1
	move.l	(a1),d0
	beq.s	FALExit				* Finito, esci...
FALLoop	move.l	a1,a5				* Save for FreeMem()
	move.l	a4,a0				* struct List *
	REMOVE					* exec MACROS
	move.l	a5,a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
	move.l	(a4),a1
	move.l	(a1),d0
	bne.s	FALLoop
FALExit movem.l	(sp)+,a4-a6
	rts





***************************************************************************************
** Special Re-Make -- GT_GetIMsg() -> AS_GetIMsg() & GT_ReplyIMsg() -> AS_ReplyIMsg()
**
** Queste funzioni sono attualmente ##private -- e non dispongono di Docs in quanto
** sono lesatta copia delle funzione della gadtools.library.
***************************************************************************************
_LVOAS_GetIMsg
	movem.l	d7/a5-a6,-(sp)
	move.l	a0,a5				* Save WindowPorts (UserPort)
	move.l	ab_ExecBase(a6),a6
	bra.s	AGMGet
AGMFilt	move.l	d7,a1
	move.l	([8.w,sp],ab_GadToolsBase.w),a6
	jsr	_LVOGT_FilterIMsg(a6)
	tst.l	d0
	bne.s	AGMExit
	move.l	d7,a1
	move.l	([8.w,sp],ab_ExecBase.w),a6
	jsr	_LVOReplyMsg(a6)
	move.l	a5,a0
AGMGet	jsr	_LVOGetMsg(a6)
	move.l	d0,d7
	bne.s	AGMFilt
AGMExit	movem.l	(sp)+,d7/a5-a6
	rts
***************************************************************************************	
_LVOAS_ReplyIMsg
	move.l	a6,-(sp)
	move.l	a1,d0
	beq.s	ARMExit
	move.l	ab_GadToolsBase(a6),a6
	jsr	_LVOGT_PostFilterIMsg(a6)
	move.l	d0,a1
	move.l	([sp],ab_ExecBase.w),a6
	jsr	_LVOReplyMsg(a6)
ARMExit	move.l	(sp)+,a6
	rts

***************************************************************************************
* (NEW) - 15-11-1994 =JON= *
***************************************************************************************
CLEARTIMEVAL	MACRO	; RESULT MESSAGE
	move.l	a2,a1	
	bsr	_LVOAS_ReplyIMsg
	moveq	#0,d0
	move.l	d0,rei_LeftSeconds(a4)
	move.l	d0,rei_LeftMicros(a4)
	move.l	d0,rei_RightSeconds(a4)
	move.l	d0,rei_RightMicros(a4)
	lea	rei_REIMessage(a4),a0
	move.l	#\1,rim_REICode(a0)
	move.l	a0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
	ENDM

CheckDouble
	BTSTL	REIB_DOUBLECLICK,rei_Flags(a4)	* Devo controllare il DoubleClick?
	bne.s	CkType				* Si, guarda quale bottone...
SeeIntu	
	CLEARTIMEVAL RIM_SEEINTUITION
	*
CkType	move.w	im_Code(a2),d0			* Original Intuition message
	sub.w	#SELECTDOWN,d0
	beq.s	IsLeft
	sub.w	#(SELECTUP-SELECTDOWN),d0
	beq	StdExit
;	subq.w	#1,d0				* ($69-$68) (MENUDOWN-SELECTDOWN)
;	beq.s	IsRight
	*
	CLEARTIMEVAL RIM_SEEINTUITION

IsLeft	movem.l	im_Seconds(a2),d2-d3		* Take Sec and Mic...
	move.l	rei_LeftSeconds(a4),d0
	add.l	rei_LeftMicros(a4),d0
	beq.s	IsLeftD
	move.l	ab_IntuiBase(a5),a6		* Get Intuition
	movem.l	rei_LeftSeconds(a4),d0-d1
	jsr	_LVODoubleClick(a6)
	move.l	a5,a6				* Reset AssemblyBase...
	tst.l	d0
	beq	SeeIntu
	CLEARTIMEVAL RIM_LEFTDOUBLECLICK
	
IsLeftD	movem.l	d2-d3,rei_LeftSeconds(a4)	* Solo la prima volta...
	move.l	d0,rei_RightSeconds(a4)	
	move.l	d0,rei_RightMicros(a4)	
StdExit	move.l	a2,a1	
	bsr	_LVOAS_ReplyIMsg
	lea	rei_REIMessage(a4),a0
	move.l	#RIM_SEEINTUITION,rim_REICode(a0)
	move.l	a0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
		
	

_LVOWaitREIMsg
	movem.l	d2-d7/a2-a6,-(sp)
	move.b	d0,d6			* D6 = Default Underscore
	move.l	a6,a5			* Save AsmBase
	move.l	a0,a4			* Save REI
GetMesD	move.l	([rei_Window.w,a4],wd_UserPort.w),a0	* Port in A0
	bsr	_LVOAS_GetIMsg
	move.l	d0,d7
	bne.s	WRElabo
InWait	moveq	#0,d1			* altrimenti metti in attesa il Task::!!
	moveq	#0,d0
	move.l	([rei_Window.w,a4],wd_UserPort.w),a0
	move.b	MP_SIGBIT(a0),d1
	bset	d1,d0
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOWait(a6)
GetMes	move.l	a5,a6
	move.l	([rei_Window.w,a4],wd_UserPort.w),a0	* Port in A0
	bsr	_LVOAS_GetIMsg		* E' arrivato per forza di cose!
	move.l	d0,d7			* Check for NULL and switch in D7
	beq.s	WExit			* Torna in attesa...
WRElabo	move.l	d7,a2			* IntuiMessage in A2
;--------------------------------------------------------------------------------------
	move.l	im_Class(a2),rei_REIMessage+rim_Class(a4)
	move.l	im_Code(a2),rei_REIMessage+rim_Code(a4)
	move.l	im_IAddress(a2),rei_REIMessage+rim_IAddress(a4)
;--------------------------------------------------------------------------------------	
	move.l	im_Class(a2),d0
	subq.l	#IDCMP_NEWSIZE,d0
	beq.s	Drawing
	subq.l	#(IDCMP_REFRESHWINDOW-IDCMP_NEWSIZE),d0
	beq.s	Refresh
	subq.l	#(IDCMP_MOUSEBUTTONS-IDCMP_REFRESHWINDOW),d0
	beq	CheckDouble					; NEW (V41.2)
	sub.l	#(IDCMP_GADGETUP-IDCMP_MOUSEBUTTONS),d0
;	
;	sub.l	#(IDCMP_GADGETUP-IDCMP_REFRESHWINDOW),d0
	beq	AutoGadget
	sub.l	#(IDCMP_MENUPICK-IDCMP_GADGETUP),d0	
	beq	AutoMenu
	sub.l	#(IDCMP_VANILLAKEY-IDCMP_MENUPICK),d0
	beq	AutoKey
	move.l	a2,a1	
	bsr	_LVOAS_ReplyIMsg
WExit	lea	rei_REIMessage(a4),a0
	move.l	a0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------	
Refresh	move.l	rei_Window(a4),a0		* Prende la Window
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOGT_BeginRefresh(a6)
	move.l	rei_Window(a4),a0
	moveq	#1,d0
	jsr	_LVOGT_EndRefresh(a6)
;--------------------------------------------------------------------------------------
Reply	move.l	d7,a1
	pea	GetMes(pc)
	move.l	a5,a6
	bra	_LVOAS_ReplyIMsg
;--------------------------------------------------------------------------------------
Drawing	move.l	rei_glist(a4),a0	
	move.l	gg_NextGadget(a0),d0	* Ci sono Gadget??
	beq.s	AskHook
	moveq	#0,d1
	move.l	d1,gg_NextGadget(a0)
	move.l	d0,a0
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOFreeGadgets(a6)	* Free Gadgets
	move.l	rei_glist(a4),a2
	move.l	rei_HEADAsmGadget(a4),a3	* sicuramente ci sono!!...
	move.l	a5,a6
	jsr	LayoutAsmGList		* A4=REI, A3=AsmGList, A2=PrevGadget	
	move.l	ab_LayersBase(a5),a6
	move.l	([rei_Window.w,a4],wd_RPort.w),a1
	move.l	([rp_Layer.w,a1],lr_BackFill.w),a0
	suba.l	a2,a2
	jsr	_LVODoHookClipRects(a6)
;--------------------------------------------------------------------------------------
AskHook	move.l	rei_CustomHook(a4),d0		* Controlliamo se esiste un
	beq.s	NoCHook				* Custom Hook...
DoHook	move.l	a5,a6				* Dato che esiste un CustomHook, non
	move.l	d7,a1				* eseguiamo nessun refresh della Window
	bsr	_LVOAS_ReplyIMsg		* ma invochiamo l'Hook
	move.l	rei_CustomHook(a4),a0		* Il messaggio qui è già restituito...
	suba.l	a1,a1
	move.l	rei_Window(a4),a2
	move.l	a5,a6
	move.l	h_Entry(a0),a3
	pea	GetMes(pc)			* Altri messaggi... qui ritorna
	jmp	(a3)
;--------------------------------------------------------------------------------------	
NoCHook	move.l	rei_Window(a4),a0		* Se non esiste un CustomHook, tutto
	move.l	ab_IntuiBase(a5),a6		* procede come sempre... e la Window
	jsr	_LVORefreshWindowFrame(a6)	* viene rinfrescata...
	move.l	ab_GadToolsBase(a5),a6
	move.l	rei_Window(a4),a0
	suba.l	a1,a1
	jsr	_LVOGT_RefreshWindow(a6)
	move.l	d7,a1
	pea	GetMes(pc)
	move.l	a5,a6
	bra	_LVOAS_ReplyIMsg
;--------------------------------------------------------------------------------------
; AUTOGADGET()
;--------------------------------------------------------------------------------------
CYCSave	move.l	rei_Window(a4),a1	* A1 = Window
	moveq	#0,d0
	move.l	sp,d7			* Save Stack pointer
	move.l	d0,-(sp)		* TAG_DONE
	move.l	d0,-(sp)		* Space for pointer
	pea	GTCY_Active
	move.l	d0,-(sp)
	pea	GTCY_Labels
	move.l	sp,a3
	subq.w	#4,sp
	move.l	sp,4(a3)		* Put pointer
	subq.w	#4,sp
	move.l	sp,12(a3)
	move.l	agg_Gadget(a2),a0
	move.l	a2,d2			* Save Temp D2
	suba.l	a2,a2
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	movem.l	(sp)+,d0-d1		* D0 = Value to set
	move.l	d7,sp			* Reset Stack
	move.l	d2,a2			* A2 = (struct AsmGadget *)
	move.l	agg_TagList(a2),a0
	move.l	d0,CYCDATA_Active(a0)
	move.l	d1,CYCDATA_Labels(a0)
	bra	JmpAddr
;--------------------------------------------------------------------------------------
LISSave move.l	rei_Window(a4),a1	* A1 = Window
	moveq	#0,d0
	move.l	sp,d7			* Save Stack pointer
	move.l	d0,-(sp)		* TAG_DONE
	move.l	d0,-(sp)		* Space for pointer
	pea	GTLV_Selected
	move.l	d0,-(sp)
	pea	GTLV_Labels
	move.l	sp,a3
	subq.w	#4,sp
	move.l	sp,4(a3)		* Put pointer
	subq.w	#4,sp
	move.l	sp,12(a3)
	move.l	agg_Gadget(a2),a0
	move.l	a2,d2			* Save A2 Temp in D2
	suba.l	a2,a2
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	move.l	d2,a2			* A2 = (struct AsmGadget *)
	movem.l	(sp)+,d0-d1		* D0 = Value to set
	move.l	d7,sp			* Reset Stack
	move.l	agg_TagList(a2),a0
	move.l	d0,LISDATA_MakeVisible(a0)
	move.l	d0,LISDATA_Selected(a0)
	move.l	d1,LISDATA_Labels(a0)
	bra.s	JmpAddr
;--------------------------------------------------------------------------------------
STRSave move.l	agg_TagList(a2),a1	* Prende la TAGLIST
	move.l	STRDATA_String(a1),d0	* C'era una Stringa Iniziata!!
	beq.s	JmpAddr			* No... allora esci
	move.l	d0,a1			* User Buffer in A1
	move.l	agg_Gadget(a2),a0	* Prendiamo il Buffer allocato
	move.l	gg_SpecialInfo(a0),a0	* Dalla GadTools.library
	move.l	si_Buffer(a0),a0	* lo mettiamo in A0
CUBufer	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	CUBufer
	move.b	(a0),(a1)
	bra.s	JmpAddr
;--------------------------------------------------------------------------------------
AAG_Table2
	dc.l 0			* GENERIC_KIND (not implement now!)
	dc.l JmpAddr		* BUTTON_KIND
	dc.l JmpAddr		* CHECKBOX_KIND (not implement now!)
	dc.l STRSave		* INTEGER_KIND
	dc.l LISSave		* LISTVIEW_KIND
	dc.l JmpAddr		* MX_KIND (not implement now!)
	dc.l JmpAddr		* NUMBER_KIND
	dc.l CYCSave		* CYCLE_KIND
	dc.l JmpAddr		* PALETTE_KIND (not implement now!)
	dc.l JmpAddr		* SCROLLER_KIND (not implement now!)
	dc.l JmpAddr		* RESERVED_KIND (not implement now!)
	dc.l JmpAddr		* SLIDER_KIND (not implement now!)
	dc.l STRSave		* STRING_KIND
	dc.l JmpAddr		* TEXT_KIND --------------------------------	
***************************************************************************************
* New - Internal Command Routine for layout gadtools's gadgets handle
* 
* Questo viene chiamato con:
*
* A2 = (struct IntuiMessage *)
* A4 = (struct REI *)
* A5 = assembly base
* A6 = gadtools base
*
***************************************************************************************
AutoGadget
	move.l	a2,-(sp)		* Rispondo al messaggio, tanto so che cos'è
	move.l	rei_REIMessage+rim_IAddress(a4),a2	* A2 (struct Gadget *)
	move.l	gg_UserData(a2),a2			* A2 (struct AsmGadget *)
	move.l	agg_Kind(a2),d0				* Che tipo devo gestire?
	beq.s	JmpAddr					* security... generic kind
	lea	AAG_Table2(pc),a0
	move.l	ab_GadToolsBase(a5),a6
	jmp	([a0,d0.w*4])
;--------------------------------------------------------------------------------------
JmpAddr	move.l	agg_NewGadget+gng_UserData(a2),d0	* D0 = (struct Hook *)
	beq.s	AGSimGd			* Se non c'era, allora esci
	lea	rei_REIMessage(a4),a1	* A1 = message (struct REIMessage *)
	move.l	d0,a0			* A0 = itself (struct Hook *)
	move.l	a5,a6			* Force A6 = asmbase...
	jsr	([h_Entry.w,a0])	* Chiama l'Hook
	move.l	(sp)+,a1
	move.l	a5,a6
	pea	GetMes(pc)
	bra	_LVOAS_ReplyIMsg
AG_ER1	move.l	(sp)+,a1
	move.l	a5,a6
	pea	WExit(pc)
	bra	_LVOAS_ReplyIMsg	
AGSimGd	move.l	(sp)+,a1
	move.l	#GADGETUP,rei_REIMessage+rim_Class(a4)
	move.l	agg_Gadget(a2),rei_REIMessage+rim_IAddress(a4)
	move.l	a5,a6
	pea	WExit(pc)
	bra	_LVOAS_ReplyIMsg	
	
***************************************************************************************
* Anche questo viene chiamato con:
*
* A2 = (struct IntuiMessage *)
* A4 = (struct REI *)
* A5 = assembly base
* A6 = gadtools base
*
***************************************************************************************
AutoKey	move.l	a2,-(sp)			* Rispondo al mes, tanto so che cos'è
	move.w	rei_REIMessage+rim_Qualifier(a4),d1	* from REIMessage
	andi.w	#~$8007,d1		* Vediamo se è un messaggio che posso gestire
	bne.s	AG_ER1			* Alreimenti esci
	move.w	rei_REIMessage+rim_Code(a4),d5	* D5 = Tasto (premuto) da cercare
	move.l	([rei_HEADAsmGadget.w,a4]),d0	* Che ce stanno Gadget??
	beq.s	AG_ER1				* No, allora vedi da usci...
	move.l	rei_HEADAsmGadget(a4),a2	* A2 (struct AsmGadget *)
CerRout	move.l	agg_NewGadget+gng_GadgetText(a2),d0	* Ha un testo associato??
	bne.s	FinRout				* Si, allora controlla
ChekNex	move.l	([a2]),d0			* Prendi successivo, esiste...
	move.l	LN_SUCC(a2),a2
	bne.s	CerRout				* si continua
AAG_EXT	move.l	(sp)+,a1
	move.l	a5,a6
	bsr	_LVOAS_ReplyIMsg
	lea	rei_REIMessage(a4),a0		* Esce da WaitREIMsg()
	move.l	a0,d0				* (struct REIMessage *)
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------	
FinRout	move.l	d0,a0			* A0 ^ GadgetText
Undersc	move.b	(a0)+,d0		* carattere
	beq.s	ChekNex
	cmp.b	d6,d0			* Cerco l'Underscore
	bne.s	Undersc			* niente, continua
	cmp.b	(a0),d5			* Trovato, cont. il carattere ora
	beq.s	CharFin			* TROVATO... era questo
	bchg	#5,d5			* Riprovo, per il CASE
	cmp.b	(a0),d5			* prova adesso...
	bne.s	ChekNex			* Niente, non era questo evident...
***************************************************************************************
* Esiste dunque un Gadget con testo e con underscore corrispondente al tasto che noi
* stavamo cercando. Ora controllo se questo Gadget è ON, altrimenti esco.
***************************************************************************************
CharFin	move.w	([agg_Gadget.w,a2],gg_Flags.w),d0	* Flags
	btst	#8,d0			* It's ghosted??
	bne.s	AAG_EXT			* è ghostato, quindi esci...
	move.l	agg_Kind(a2),d0		* Che tipo devo gestire?
	lea	AAG_Table(pc),a0	* Table
	jmp	([d0.w*4,a0])		* Elabora
***************************************************************************************
* - BUTTON - 
***************************************************************************************
AAG_BUT	move.l	a2,a3					* A3 (struct AsmGadget *)
	move.l	agg_Gadget(a3),a2			* A2 (struct Gadget *)
	move.l	([rei_Window.w,a4],wd_RPort.w),a0	* RastPort
	move.l	gg_GadgetRender(a2),a1			* Image
	movem.w	gg_LeftEdge(a2),d0-d1			* coordinate
	moveq	#IDS_SELECTED,d2			* Modo --selezionato--
	move.l	([rei_VI.w,a4],vi_DrawInfo.w),a2		* take private drawinfo...
	move.l	ab_IntuiBase(a5),a6	
	jsr	_LVODrawImageState(a6)			* drawing
	move.w	ab_TicksDelay(a5),d1			* from assembly preferences
	ext.l	d1
	move.l	ab_DosBase(a5),a6
	jsr	_LVODelay(a6)				* Waiting...
	move.l	agg_Gadget(a3),a0			* (struct Gadget *)
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVORefreshGadgets(a6)
	move.l	a3,a2					* (struct AsmGadget *)
	bra	JmpAddr
***************************************************************************************
* - STRING/INTEGER/KIND -
***************************************************************************************
AAG_STR	move.l	a2,a3					* (struct AsmGadget *)
	move.l	agg_Gadget(a3),a0			* (struct Gadget *)
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOActivateGadget(a6)
	move.l	a3,a2					* (struct AsmGadget *)
	bra	JmpAddr
***************************************************************************************
* - CYCLE_KIND -
***************************************************************************************
AAG_CYC	move.l	a2,a3					* (struct AsmGadget *)
	move.l	agg_Gadget(a3),a2			* (struct Gadget *)	
	move.l	([rei_Window.w,a4],wd_RPort.w),a0	* RastPort
	move.l	gg_GadgetRender(a2),a1			* Image
	movem.w	gg_LeftEdge(a2),d0-d1
	moveq	#IDS_SELECTED,d2
	move.l	([rei_VI.w,a4],vi_DrawInfo.w),a2
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVODrawImageState(a6)			* drawing...
	move.w	ab_TicksDelay(a5),d1
	ext.l	d1
	move.l	ab_DosBase(a5),a6
	jsr	_LVODelay(a6)				* waiting...
	move.l	agg_Gadget(a3),a0			* (struct Gadget *)
	move.l	a3,d6					* Save (struct AsmGadget *)
	moveq	#0,d0
	move.l	sp,d7					* STACK in D7
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	pea	GTCY_Active
	move.l	d0,-(sp)
	pea	GTCY_Labels	
	move.l	sp,a3					* A3 setting
	subq.w	#4,sp
	move.l	sp,4(a3)
	subq.w	#4,sp
	move.l	sp,12(a3)
	move.l	rei_Window(a4),a1			* Windowptr
	suba.l	a2,a2
	move.l	ab_GadToolsBase(a5),a6
	jsr	_LVOGT_GetGadgetAttrsA(a6)
	movem.l	(sp)+,d1/a0				* D1 = Active| A0 = Labels
	move.l	d7,sp					* RESET STACK
	addq.l	#1,d1
	move.l	(a0,d1.l*4),d0
	bne.s	SetCyc
	move.w	d0,d1
SetCyc	move.l	d6,a0					* (struct AsmGadget *)
	move.l	agg_TagList(a0),a1			* TagItems
	move.l	agg_Gadget(a0),a0			* (struct Gadget *)
	move.l	d1,CYCDATA_Active(a1)
	move.l	sp,d7					* STACK in D7
	pea	0
	move.l	d1,-(sp)
	move.w	d1,rei_REIMessage+rim_Code(a4)		* Set in REIMessage...
	pea	GTCY_Active
	move.l	sp,a3
	move.l	rei_Window(a4),a1
	suba.l	a2,a2
	jsr	_LVOGT_SetGadgetAttrsA(a6)
	move.l	d7,sp					* RESET STACK
	move.l	d6,a2					* A2 (strcut AsmGadget *)
	bra	JmpAddr

;--------------------------------------------------------------------------------------
; AUTOGADGET GADGET'S TABLE --
;--------------------------------------------------------------------------------------
AAG_Table
	dc.l AAG_EXT		* GENERIC_KIND (not implement now!)
	dc.l AAG_BUT		* BUTTON_KIND
	dc.l AAG_EXT		* CHECKBOX_KIND (not implement now!)
	dc.l AAG_STR		* INTEGER_KIND
	dc.l AAG_EXT		* LISTVIEW_KIND
	dc.l AAG_EXT		* MX_KIND (not implement now!)
	dc.l AAG_EXT		* NUMBER_KIND
	dc.l AAG_CYC		* CYCLE_KIND
	dc.l AAG_EXT		* PALETTE_KIND (not implement now!)
	dc.l AAG_EXT		* SCROLLER_KIND (not implement now!)
	dc.l AAG_EXT		* RESERVED_KIND (not implement now!)
	dc.l AAG_EXT		* SLIDER_KIND (not implement now!)
	dc.l AAG_STR		* STRING_KIND
	dc.l AAG_EXT		* TEXT_KIND --------------------------------

***************************************************************************************
* Questo viene chiamato con:
*
* A2 = (struct IntuiMessage *)
* A4 = (struct REI *)
* A5 = assembly base
* A6 = gadtools base
*
***************************************************************************************
AutoMenu
	move.l	a2,a3			* Salvo IntuiMessage in A3
	move.w	im_Code(a3),d0		* Controlliamo che sia arrivato un codice
	cmpi.w	#MENUNULL,d0		* corretto e non MENUNULL... in questo caso
	beq.s	AMU_NOM			* Esce, azzerando tutto...
;--------------------------------------------------------------------------------------
	move.l	rei_Menu(a4),a0
	move.l	ab_IntuiBase(a5),a6
	jsr	_LVOItemAddress(a6)
	move.l	d0,a2					* A2 (struct Sub/MenuItem *)
	move.l	a2,rei_REIMessage+rim_IAddress(a4)	* Save Address in rim_IAddress
	move.l	mi_SIZEOF(a2),d1			* ID in MenuItem structure...
	move.w	d1,rei_REIMessage+rim_Code(a4)		* ID del Menu in rim_Code
	move.l	a3,a1					* rispondo al mes
	move.l	a5,a6			
	pea	WExit(pc)				* ed esco spudoratamente
	bra	_LVOAS_ReplyIMsg
;--------------------------------------------------------------------------------------
AMU_NOM move.w	d0,rei_REIMessage+rim_Code(a4)		* Mette in rim_Code MENUNULL
	addq.w	#1,d0					* D0 == NULL!
	move.l	d0,rei_REIMessage+rim_IAddress(a4)	* Clear rim_IAddress
	move.l	a3,a1					* Rispondiamo al messaggio
	move.l	a5,a6
	pea	GetMes(pc)
	bra	_LVOAS_ReplyIMsg
;--------------------------------------------------------------------------------------

***************************************************************************************
* (18.3.95) =Jon= --- MenuItem = AS_MenuAddress(rei,nMenu,nItem,nSubItem)(A0,d0,d1,d2)
***************************************************************************************
_LVOAS_MenuAddress
	movem.l	d2-d3,-(sp)
	move.w	d0,d3
	move.l	rei_Menu(a0),d0			* A0 ^ Primo Menu
	move.l	d0,a0
	bra.s	CMenu
LMenu	move.l	mu_NextMenu(a0),d0
	move.l	d0,a0
	beq.s	IA_EXIT
CMenu	dbf	d3,LMenu
	addq.w	#1,d1
	beq.s	IA_EXIT
	subq.w	#1,d1
	move.l	mu_FirstItem(a0),d0
	move.l	d0,a0
	bra.s	CItem
LItem	move.l	mi_NextItem(a0),d0
	move.l	d0,a0
	beq.s	IA_EXIT
CItem	dbf	d1,LItem
	addq.w	#1,d2
	beq.s	IA_EXIT
	subq.w	#1,d2
	move.l	mi_SubItem(a0),d0
	move.l	d0,a0
	bra.s	CSub
LSub	move.l	mi_NextItem(a0),d0
	move.l	d0,a0
	beq.s	IA_EXIT
CSub	dbf	d2,LSub
IA_EXIT	movem.l	(sp)+,d2-d3
	rts

***************************************************************************************
* (07-Mar-1995) =Jon= --- [i = OpenInterface(name) (a0) ]
***************************************************************************************
_LVOOpenInterface
	movem.l	a2-a6,-(sp)
	move.l	a0,d0			* Name NULL???
	bne.s	OPRCont			* No, allora continua...
	movem.l	(sp)+,a2-a6
	rts

OPRCont	move.l	d0,a3			* Save FileName...
	move.l	a6,a5			* save asmbase...
	move.l	ab_DosBase(a5),a6	* prendo la dos...
;--------------------------------------------------------------------------------------	
	move.l	a3,d1			* provo a caricare il file .rei, con la path
	jsr	_LVOLoadSeg(a6)		* completa passata negli Inputs...
	tst.l	d0
	bne.s	OPROk			* Ok... trovato...	
;--------------------------------------------------------------------------------------	
	move.l	a3,d1			* Ricavo solo il filename, ovvero l'ultima
	jsr	_LVOFilePart(a6)	* parte della path...
	move.l	d0,a3			* A3 ora punta solo al filename...
;--------------------------------------------------------------------------------------	
	move.l	([ab_ExecBase.w,a5],ThisTask.w),a0	* A0 = (struct Task *)
	move.l	pr_HomeDir(a0),d1	* mi sposto sulla directory dell'applicazione
	jsr	_LVOCurrentDir(a6)
	move.l	d0,a4			* Old directoty	
	move.l	a3,d1			* riprovo a caricare...
	jsr	_LVOLoadSeg(a6)
	move.l	d0,a2
	move.l	a4,d1			* reset old directory
	jsr	_LVOCurrentDir(a6)
	move.l	a2,d0
	tst.l	d0
	bne.s	OPROk
;--------------------------------------------------------------------------------------	
	movem.l	(sp)+,a2-a6		* altrimenti esci...
	rts
;--------------------------------------------------------------------------------------	
OPROk	add.l	d0,d0			* BCPL to ADDR
	add.l	d0,d0
	addq.l	#4,d0
;--------------------------------------------------------------------------------------		
	move.l	d0,a0
	cmpi.l	#"FORM",int_FORM(a0)
	bne.s	FailFre
	move.l	int_REI0(a0),d1
	andi.l	#$FFFFFF00,d1
	cmpi.l	#("REI "-32),d1
	bne.s	FailFre
;--------------------------------------------------------------------------------------	
	move.l	([ab_ExecBase.w,a5],ThisTask.w),a0	* A0 = (struct Task *)
	move.l	d0,TC_Userdata(a0)	* Put List in UserData of this Task...
	movem.l	(sp)+,a2-a6
	rts	
;--------------------------------------------------------------------------------------	
FailFre	move.l	d0,d1
	subq.l	#4,d1
	asr.l	#2,d1
	jsr	_LVOUnLoadSeg(a6)
	moveq	#0,d0
	movem.l	(sp)+,a2-a6
	rts
;--------------------------------------------------------------------------------------
***************************************************************************************
* (20-Jan-1995) =Jon= --- [ CloseInterface(i) (a0) ] ####### TESING #######
***************************************************************************************
_LVOCloseInterface
	move.l	a6,-(sp)
	move.l	ab_ExecBase(a6),a0
	move.l	ThisTask(a0),a0
	move.l	TC_Userdata(a0),d1
	beq.s	CIExit
	clr.l	TC_Userdata(a0)
	subq.l	#4,d1
	asr.l	#2,d1
	move.l	ab_DosBase(a6),a6
	jsr	_LVOUnLoadSeg(a6)
CIExit	move.l	(sp)+,a6
	rts
	
***************************************************************************************
* (20-Jan-1995) =Jon= ++++ rei = FindREI(name) (a1)
***************************************************************************************
_LVOFindREI
	move.l	a1,d0
	beq.s	FDRExit
	move.l	ab_ExecBase(a6),a0
	move.l	([ThisTask.w,a0],TC_Userdata.w),d0	* (Struct MinList *)
	beq.s	FDRExit
	move.l	d0,a0
	FINDNAME
FDRExit	rts
	
***************************************************************************************
* (25-Jan-1995) =Jon= ++++ asmgadget = FindAsmGadget(rei,name) (a0/a1)
***************************************************************************************
_LVOFindAsmGadget
	lea	rei_HEADAsmGadget(a0),a0
	FINDNAME
	rts	

	