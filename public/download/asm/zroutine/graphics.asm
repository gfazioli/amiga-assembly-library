***************************************************************************************
* file Graphics - main Gfx support commands
*
* Ver.41.1 - Table of Contents
*
* AddBitPlanes		   - NEW (V41.1) - REWRITE
* RemoveBitPlanes	   - NEW (V41.1)
* NewAllocRaster	   - NEW (V41.1)
* FadeColor		   - none change
* LoadCMAP		   - none change
* SetColorTable		   - none change
* CopperMove,Wait,End	   - none change
* TextFmtSizeArgs	   - New
* TextFmtRastPortArgs	   - Modificato (01-Jan-1995)
* AllocRastPort		   - New
* CloneRastPort		   - New
* DrawBox		   - New
***************************************************************************************

***************************************************************************************
* (06-10-1994) =JON= --- num = AddBitPlanes (bm, num) (a0,d0)
***************************************************************************************
_LVOAddBitPlanes
	movem.l	d2-d4/a2-a6,-(sp)
	moveq	#0,d3
	subq.w	#1,d0
	move.w	d0,d4			* num of raster...
	add.b	bm_Depth(a0),d0
	subq.b	#8,d0
	bge.s	FalExit		
	movem.w	bm_BytesPerRow(a0),d2-d3
	mulu.w	d3,d2			* D2 = quantità di memoria da alloc
	lea	bm_Depth(a0),a3		* A3^Point to depth field
	move.b	(a3),d3
	ext.w	d3
	lea	bm_Planes(a0,d3.w*4),a2	* Start to added bitplanes...
	moveq	#0,d3			* bitplanes counter
	lea	MEMF_CHIP|MEMF_CLEAR,a4
	move.l	ab_ExecBase(a6),a6
ADB_LOP	move.l	d2,d0
	move.l	a4,d1
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	FalExit
	move.l	d0,(a2)+
	addq.b	#1,(a3)
	addq.b	#1,d3
	dbf	d4,ADB_LOP
FalExit	move.l	d3,d0
	movem.l	(sp)+,d2-d4/a2-a6
	rts

***************************************************************************************
* (06-10-1994) =JON= --- num = RemoveBitPlanes (bm, num) (a0,d0)
***************************************************************************************
_LVORemoveBitPlanes
	movem.l	d2-d4/a2-a6,-(sp)
	moveq	#0,d3
	move.w	d0,d4			* num of raster...
	subq.w	#1,d4
	sub.b	bm_Depth(a0),d0
	bpl.s	FalExit
	movem.w	bm_BytesPerRow(a0),d2-d3
	mulu.w	d3,d2			* D2 = quantità di memoria da libera
	lea	bm_Depth(a0),a3		* A3^Point to depth field
	move.b	(a3),d3
	ext.w	d3
	lea	bm_Planes(a0,d3.w*4),a2	* Start to added bitplanes...
	moveq	#0,d3			* bitplanes counter
	suba.l	a4,a4			* Clear planeptr
	move.l	ab_ExecBase(a6),a6
RVB_LOP	move.l	-(a2),a1
	subq.b	#1,(a3)
	move.l	a4,(a2)			* Clear planeptr
	move.l	d2,d0
	jsr	_LVOFreeMem(a6)
	addq.b	#1,d3
	dbf	d4,RVB_LOP	
RVBExit	move.l	d3,d0
	movem.l	(sp)+,d2-d4/a2-a6
	rts

***************************************************************************************
* (06-10-1994) =JON= --- planeptr = NewAllocRaster ( width, height ) (d0,d1)
***************************************************************************************
_LVONewAllocRaster
	movem.l	d2/a6,-(sp)
	add.w	#$F,d0
	asr.w	#3,d0
	bclr	#0,d0
	mulu.w	d1,d0
	addq.w	#4,d0
	move.l	d0,d2
	lea	MEMF_CHIP|MEMF_CLEAR,a0
	move.l	a0,d1
	move.l	ab_ExecBase(a6),a6
	jsr	_LVOAllocMem(a6)
	move.l	d0,a0
	move.l	d2,(a0)+
	move.l	a0,d0
	movem.l	(sp)+,d2/a6
	rts


***************************************************************************************
* (06-10-1994) =JON= --- 
***************************************************************************************
_LVOFadeColor
	movem.l	d0-d7/a0-a6,-(sp)
	tst.l	d0
	beq.s	FadeColor_Exit
	move.l	sc_ViewPort+vp_ColorMap(a0),a1
	move.l	cm_ColorTable(a1),a1
	movem.w	ClearRegs,d1-d5
	moveq	#31,d7
	lea	$111.W,a3
	move.l	a3,d4
	move.l	d0,d6
FadeColor_Next
	btst	d7,d6
	bne.s	FadeColor_Fade
FadeColor_NextVoid
	dbf	d7,FadeColor_Next
	bra.s	FadeColor_Exit
FadeColor_Fade
	move.w	d7,d2
	add.w	d2,d2
	lea	(a1,d2.l),a2
	lea	$F00.W,a3
	move.l	a3,d3
FadeColor_Reply
	move.w	(a2),d0
	and.l	d3,d0
	beq.s	FadeColor_NextRGB
	move.w	d3,d5
	and.w	d4,d5
	sub.w	d5,(a2)
FadeColor_NextRGB
	asr.w	#4,d3
	beq.s	FadeColor_NextVoid
	bra.s	FadeColor_Reply
FadeColor_Exit
	move.l	ab_IntuiBase(a6),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

***************************************************************************************	
* 
***************************************************************************************
_LVOLoadCMAP
	movem.l	d0-d1/a0-a6,-(sp)
	move.l	a6,a5			* save TledBase
	move.l	a0,d0
	beq.s	LoadCMAP_FreeOnly
	move.l	a1,d0
	beq.s	LoadCMAP_Exit
	move.l	sc_ViewPort+vp_ColorMap(a0),a1
	move.l	cm_ColorTable(a1),8(sp)
	move.l	ab_GfxBase(a5),a6
	move.l	12(sp),a1		* ColorTable
	and.l	#$FF,(sp)		* Only byte, don't forget me!¡!¡
	move.l	(sp),d0			* count
	jsr	_LVOLoadRGB4(a6)
LoadCMAP_FreeOnly
	move.l	ab_ExecBase(a5),a6
	move.l	12(sp),a1		* ColorTable
	move.l	(sp),d0			* n colors
	add.l	d0,d0			* byte to free!
	jsr	_LVOFreeMem(a6)
LoadCMAP_Exit
	movem.l	(sp)+,d0-d1/a0-a6
	rts

****************************
* (V41) - 06-10-1994 =JON= *
****************************
_LVOSetColorTable
	movem.l	d0-d7/a0-a6,-(sp)
	tst.l	d0
	beq.s	SetColorTable_Exit
	move.l	sc_ViewPort+vp_ColorMap(a0),a2
	move.l	cm_ColorTable(a2),a2
	movem.w	ClearRegs,d1-d7			* tled.library
	move.l	d0,d7				* Bit select Reg color
	moveq	#31,d6
	lea	$0111.W,a5
	move.l	a5,d5				* Cost
SetColorTable_ActReg
	btst	d6,d7
	bne.s	SetColorTable_SetColorTable
SetColorTable_ActRegVoid
	dbf	d6,SetColorTable_ActReg
	bra.s	SetColorTable_Exit
SetColorTable_SetColorTable
	move.w	d6,d2
	add.w	d2,d2
	lea	$0F00.W,a3
	move.l	a3,d3
	lea	(a1,d2.l),a3			* A3=Offset MyColorTable
	lea	(a2,d2.l),a4			* A4=Offset ColorTable
SetColorTable_Reply
	move.w	(a3),d0
	move.w	(a4),d1
	and.w	d3,d0
	and.w	d3,d1
	sub.w	d1,d0
	SGN	d0				* tled.library
	bne.s	SetColorTable_Modify
SetColorTable_Next
	asr.w	#4,d3
	beq.s	SetColorTable_ActRegVoid
	bra.s	SetColorTable_Reply
SetColorTable_Modify
	move.w	d3,d4
	and.l	d5,d4
	tst.l	d0
	bpl.s	SetColorTable_Add
	sub.w	d4,(a4)
	bra.s	SetColorTable_Next
SetColorTable_Add
	add.w	d4,(a4)
	bra.s	SetColorTable_Next
SetColorTable_Exit
	move.l	ab_IntuiBase(a6),a6
	jsr	_LVOMakeScreen(a6)
	jsr	_LVORethinkDisplay(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

****************************
* (V41) - 06-10-1994 =JON= *
****************************
_LVOCopperMove
	movem.l	a2-a6,-(sp)
	move.l	ab_GfxBase(a6),a6
	move.l	a0,a1
	move.l	a1,a2
	jsr	_LVOCMove(a6)
	move.l	a2,a1
	jsr	_LVOCBump(a6)
	movem.l	(sp)+,a2-a6
	rts
_LVOCopperWait
	movem.l	a2-a6,-(sp)
	move.l	ab_GfxBase(a6),a6
	move.l	a0,a1
	move.l	a1,a2
	jsr	_LVOCWait(a6)
	move.l	a2,a1
	jsr	_LVOCBump(a6)
	movem.l	(sp)+,a2-a6
	rts
_LVOCopperEnd
	move.l	a0,a1
	lea	10000.W,a0
	move.l	a0,d0
	moveq	#0,d1
	subq.b	#1,d1
	bsr.s	_LVOCopperWait
	rts

***************************************************************************************
* (07-Jan-1995) =Jon= --- TextFmtSizeArgs(rp, ibox, TextFmt, ArgList) (a0,a3,a0,a2)
***************************************************************************************
_LVOTextFmtSizeArgs
	movem.l	a2-a3,-(sp)
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	#TEXTF_PRIVATE,d2		* Set Private Flags Result
	bsr.s	_LVOTextFmtRastPortArgs		* 
	moveq	#0,d0
	movem.l	d0-d1,(a3)
	move.l	a6,a3				* Libero la memoria dal testo
	move.l	ab_ExecBase(a6),a6		* formattato ed Allocato.
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
	move.l	a3,a6	
	movem.l	(sp)+,a2-a3
	rts
***************************************************************************************
* (01-Jan-1995) -- TextFmtRastPortArgs(rp,TextFmt,x,y,flgs,ArgList) (a1,a0,d0,d1,d2,a2)
***************************************************************************************
 STRUCTURE ASMTEXT,0
 	WORD	atx_Left	; Passato negli INPUTS in D0
 	WORD	atx_Top		; Passato negli INPUTS in D1
 	UWORD	atx_Flags	; Passato negli INPUTS in D2
 	APTR	atx_TextFmt	; Testo passato negli Inputs/Alloc A0
 	APTR	atx_DataStream	; DataStream passati negli Inputs in A2
 	APTR	atx_RastPort	; RastPort passata negli Inputs in A1
	WORD	atx_MaxWidth	; width della stringa più lunga RESULT priv.
	WORD	atx_MaxHeight	; height di tutte le righe RESULT private
	LABEL	atx_SIZEOF
;--------------------------------------------------------------------------------------
TFP_CON	addq.w	#1,(a3)		* Conta caratteri.. compreso zero finale
	rts
;--------------------------------------------------------------------------------------
TFP_ROU	move.b	d0,(a3)+	* Stuff routine
	rts
;--------------------------------------------------------------------------------------
_LVOTextFmtRastPortArgs
	movem.l	d2-d7/a2-a6,-(sp)	* Save Regs
	lea	-atx_SIZEOF(sp),sp	* Creo la str AsmText nello Stack...
	move.l	sp,a4			* Stack puntato in A4
	move.l	a6,a5			* Save AsmBase
	movem.w	d0-d2,atx_Left(a4)	* Save Left, Top e Flags...
	move.l	a0,atx_TextFmt(a4)	* Save fmtstring... TextFmt
	move.l	a1,atx_RastPort(a4)	* Save RastPort
	move.l	a2,atx_DataStream(a4)	* Save DataStream...
***************************************************************************************
* ** TextFmt ** ROUTINE
*
* Questa parte, stampa un testo, facendo riferimento alla struttura ASMTEXT
* A4 = ASMTEXT
* A5 = assemblybase	
***************************************************************************************		
TextFmt	move.l	ab_ExecBase(a5),a6	* Exec in A6/Allochiamo e formattiamo
	move.l	atx_TextFmt(a4),a0	* Testo...
	move.l	atx_DataStream(a4),a1	* DataStream...
	lea	TFP_CON(pc),a2		* routine che conta i caratteri
	pea	0			* clear
	move.l	sp,a3			* nello stack
	jsr	_LVORawDoFmt(a6)	* formatta
	move.l	(sp)+,d0		* Numero di Byte da Allocare
	swap	d0			* prendili
	addq.w	#5,d0			* Align + PackAlloc
	bclr	#0,d0			* Even
	move.l	d0,d2			* Save Len in D2
	moveq	#MEMF_PUBLIC,d1		* Allochiamo spazio in memoria
	jsr	_LVOAllocMem(a6)	
	tst.l	d0			* Tutto Ok??
	beq	TFP_EXT			* Exit failure...
	move.l	d0,a3			*	
	move.l	d2,(a3)+		* Pack AllocMem	A3 = Buffer
	move.l	atx_TextFmt(a4),a0	* Testo...
	move.l	a3,atx_TextFmt(a4)	* Salva quello allocato
	move.l	atx_DataStream(a4),a1	* DataStream...
	lea	TFP_ROU(pc),a2		* Crea testo formattato...
	jsr	_LVORawDoFmt(a6)
	move.l	d0,atx_DataStream(a4)	* For RESULT...
	move.l	atx_TextFmt(a4),a0	* Testo in A0
;--------------------------------------------------------------------------------------
; Arrivato qui, ho in atx_TextFmt il testo formattato e pronto per essere BUFFERIZZATO 
; e STAMPATO... in atx_DataStream il puntatore al successivo data stream... // 
;--------------------------------------------------------------------------------------
	moveq	#10,d6			* NewLine (\n) Character
	move.l	a0,a1
	move.l	sp,d3			* ##private - don't delete!!
	pea	0			* Riferimento, per fine lista
TFP_ZER	tst.b	(a0)+			* Vai alla fine della stringa...
	bne.s	TFP_ZER			
	subq.l	#1,a0			* Posizionati sullo zero...
	cmp.b	-1(a0),d6		* NewLine...
	beq.s	TFP_CES			* Bufferizza la prossima...
	subq.l	#1,a0			* Quest'Addr lo saltiamo...
TFP_CES	cmp.l	a1,a0			* Siamo tornati all'inizio??
	beq.s	TFP_EBU			* Ok, End Buffering...
	cmp.b	-(a0),d6
	bne.s	TFP_CES
	pea	1(a0)
	bra.s	TFP_CES
TFP_EBU	move.l	a0,-(sp)		* L'ultimo (primo) indirizzo...
;--------------------------------------------------------------------------------------
; Bufferizzazione terminata, ora nello stack abbiamo tanti indirizzi quante sono le 
; linee, o meglio quanti erano i NewLine (\n) presenti, questa lista termina con una 
; LONG = NULL. Ora, vediamo se è stata richiesta qualche giustificazione del testo, o 
; destra o centrata. Altrimenti non c'è problema e possiamo stampare direttamente.
;--------------------------------------------------------------------------------------
	move.l	atx_RastPort(a4),a3	* RastPort
	move.l	ab_GfxBase(a5),a6	* Il seguito lo fa la Graphics...
	move.w	atx_Flags(a4),d0	* Take Flags
	andi.w	#TEXTF_PRIVATE|3,d0	* Bit 0 e Bit 1/J_RIGHT/J_CENTER
	beq.s	NOJUST			* Nessun tipo di giustificazione...
	move.l	sp,a2			* Stringhe da stampare
	moveq	#0,d5			* Larghezza...
	moveq	#0,d2			* Altezza...
CAL_LOP	move.l	(a2)+,d4		* Indirizzi stringhe terminati???
	beq.s	CAL_EXT			* Finito...
	move.l	(a2),d7			* D7=Indirizzo successivo...
	bne.s	CAL_THE
	move.l	d4,a1
CAL_LEN	tst.b	(a1)+
	bne.s	CAL_LEN
	move.l	a1,d7
CAL_THE	sub.w	d4,d7			* lunghezza in caratteri	
	subq.w	#1,d7			* -1 per NewLine (\n)
	move.l	a3,a1
	move.l	d4,a0
	move.w	d7,d0
	jsr	_LVOTextLength(a6)
	add.w	rp_TxHeight(a3),d2	* Conta pixel in Height...
	cmp.w	d0,d5			* Chi è il più grande???
	bge.s	CAL_LOP			* D5
	move.w	d0,d5			* D0...
	bra.s	CAL_LOP
;--------------------------------------------------------------------------------------
; Perfetto, arrivati qui in pratica non abbiamo stampato na mazza, ma almeno sappiamo 
; quanto è larga la stringa più lunga... D5
;--------------------------------------------------------------------------------------
CAL_EXT	move.w	d5,atx_MaxWidth(a4)	* Num. di pixel Width Max
	move.w	d2,atx_MaxHeight(a4)	* Num. di pixel Height Max
	BTSTW	TEXTB_PRIVATE,atx_Flags(a4)
	bne	TPRIV			* Exit - PRIVATE USE ONLY!!!
;--------------------------------------------------------------------------------------
; Adesso, dato che nello SP abbiamo ancora i nostri indirizzi stringa, andiamo a 
; stampare veramente, giustificando il testo se richiesto...
;--------------------------------------------------------------------------------------
NOJUST	movem.w	atx_Left(a4),d2-d3	* D2 = Left | D3 = Top
	moveq	#0,d5			* No Justification...
TFP_LOP	move.l	(sp)+,d4		* Indirizzi stringhe terminati???
	beq.s	TFP_FRE
	move.l	(sp),d7			* D7=Indirizzo successivo...
	bne.s	TFP_THE
	move.l	d4,a1
TFP_LEN	tst.b	(a1)+
	bne.s	TFP_LEN
	move.l	a1,d7
TFP_THE	sub.w	d4,d7			* lunghezza in caratteri	
	subq.w	#1,d7			* -1 per NewLine (\n)
	move.b	atx_Flags+1(a4),d0
	andi.b	#3,d0
	beq.s	NoGiust
	move.l	a3,a1
	move.l	d4,a0
	move.w	d7,d0
	jsr	_LVOTextLength(a6)
	move.w	atx_MaxWidth(a4),d5
	sub.w	d0,d5
	BTSTW	1,atx_Flags(a4)
	beq.s	NoGiust
	asr.w	#1,d5	
NoGiust	move.w	d2,d0			* LeftEdge
	add.w	d5,d0			* Center...
	movem.w	d0/d3,rp_cp_x(a3)	   ****************************
	ori.w	#RPF_ONE_DOT,rp_Flags(a3)  **  SPECIAL MOVE Replace  **
	move.b	#$F,rp_linpatcnt(a3)	   ****************************
	move.l	a3,a1			* RastPort
	move.l	d4,a0			* Stringa
	move.w	d7,d0			* lunghezza
	jsr	_LVOText(a6)
	add.w	rp_TxHeight(a3),d3	* Prossima linea...
	bra.s	TFP_LOP	
TFP_FRE	move.l	atx_TextFmt(a4),a1
	move.l	-(a1),d0
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOFreeMem(a6)
	move.l	atx_DataStream(a4),d0
	move.l	atx_MaxWidth(a4),d1	* Private RESULT...
TFP_EXT	lea	atx_SIZEOF(sp),sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------
TPRIV	move.l	d3,sp			* Questa parte è l'uscita in caso si siano
	move.l	atx_TextFmt(a4),a1	* richiesti i dati privati: A1^TextFmt
	move.l	atx_DataStream(a4),d0	* D0 = Next DataStream
	move.l	atx_MaxWidth(a4),d1	* D1 = WidthHeight
	lea	atx_SIZEOF(sp),sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts

***************************************************************************************
* (25-Oct-1994) =JON= --- rp = AllocRastPort()
***************************************************************************************
_LVOAllocRastPort
	movem.l	d2/a4-a6,-(sp)
	move.l	#4+rp_SIZEOF,d0		* Alloc My Raster Port structure
	move.l	d0,d2
	moveq	#1,d1
	swap	d1
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	ARP_FIN
	move.l	d0,a4
	move.l	d2,(a4)+
	move.l	a4,a1
	move.l	ab_GfxBase(a5),a6
	jsr	_LVOInitRastPort(a6)
	move.l	a4,d0
ARP_FIN	movem.l	(sp)+,d2/a4-a6
	rts

***************************************************************************************
* (25-Oct-1994) =JON= --- clonerp = CloneRastPort (rp) (a0)
***************************************************************************************
_LVOCloneRastPort
	movem.l	d2/a3-a6,-(sp)
	move.l	a0,a3
	move.l	#4+rp_SIZEOF,d0		* Alloc My Raster Port structure
	move.l	d0,d2
	moveq	#1,d1
	swap	d1
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	CRP_EXT
	move.l	d0,a4
	move.l	d2,(a4)+
	move.l	a4,a0
	REPT	(rp_SIZEOF/2)
	move.w	(a3)+,(a0)+
	ENDR
	move.l	a4,d0
CRP_EXT	movem.l	(sp)+,d2/a3-a6
	rts

***************************************************************************************
* (15-11-1994) =JON= --- DrawBox(rp, left,  top,   width, height) (a1,d0,d1,d2,d3)
***************************************************************************************
_LVODrawBox	
	movem.l d2-d5/a2/a6,-(sp)
	move.l	ab_GfxBase(a6),a6
	move.w	d0,d4
	move.w	d1,d5
	move.l	a1,a2
	AMOVE	a1
	move.w	d4,d0
	move.w	d5,d1
	add.w	d2,d0
	jsr	_LVODraw(a6)
	move.w	d4,d0
	move.w	d5,d1
	add.w	d2,d0
	add.w	d3,d1
	move.l	a2,a1
	jsr	_LVODraw(a6)
	move.w	d4,d0
	move.w	d5,d1
	add.w	d3,d1
	move.l	a2,a1
	jsr	_LVODraw(a6)
	move.w	d4,d0
	move.w	d5,d1
	move.l	a2,a1
	jsr	_LVODraw(a6)
	movem.l	(sp)+,d2-d5/a2/a6
	rts	
