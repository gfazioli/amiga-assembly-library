***************************************************************************************
** 
** UpDateReseident.4.11.asm --- da compilare in DLIB:UpDataRes.Lib
**
** Rev. (8-Sep-1995)
** 
***************************************************************************************

	opt NOCHKBIT

	include DevPac:system
	
	incdir	include_I:
	include assembly/assembly_lib.i

	XDEF	_Filling
	XDEF	_SoFill
	XDEF	_RecoverFilename
	XDEF	_NodeNumber
	XDEF	_ObtainError
	XDEF	_LoadNewDTObjectA
	XDEF	_LoadNewDTObject
	XDEF	_CopyTextAttr
	XDEF	_ShowIInfo			;$VER.4.11
	XDEF	_MakeFontName			;$VER.4.11
	
	XREF	_AssemblyBase
	

STRING_LEN	EQU (100-2)

;--------------------------------------------------------------------------------------
; BOOL Filling(BPTR res, STRPTR filename, STRPTR stringinfo)
;--------------------------------------------------------------------------------------	
SPOFF	SET 4*8
_Filling
	movem.l	d5-d7/a2-a6,-(sp)			* Save Regs on Stack...
	movem.l	SPOFF+8(sp),a0-a1		* prendo il nome e buffer...
;--------------------------------------------------------------------------------------		
	move.l	a1,a2
	moveq	#" ",d0
	moveq	#STRING_LEN,d1
Space	move.b	d0,(a1)+
	dbf	d1,Space
;--------------------------------------------------------------------------------------		
	move.l	a0,a2				* salvo nome in a2
	move.l	SPOFF+12(sp),a1
Loop1	move.b	(a0)+,(a1)+			* primo carattere
	tst.b	(a0)
	bne.s	Loop1
	suba.l	a2,a0
	move.l	a0,d0
	moveq	#30,d1
	sub.w	d0,d1
	add.l	d1,a1				* Versione...
;--------------------------------------------------------------------------------------			
	move.l	SPOFF+4(sp),d0			* res == NULL?
	beq	PriNot				* Vai e scrivi non trovato...
;--------------------------------------------------------------------------------------		
	move.l	SPOFF+4(sp),a0			* Indirizzo del seglist BPTR
NextHnk	add.l	a0,a0
	add.l	a0,a0				* L'ho moltiplicato per quattro...APTR
	move.l	(a0),d7				* Next Hunk
	move.l	-4(a0),d1			* Len of this Hunk...
	asr.w	#1,d1				* divido per due...
	subq.w	#1,d1				* per dbf
Cerca	cmpi.w	#RTC_MATCHWORD,(a0)+
	beq.s	Trovato
	dbf	d1,Cerca
	move.l	d7,a0
	move.l	a0,d7
	bne.s	NextHnk
;--------------------------------------------------------------------------------------		
	lea	NoMatch(pc),a0
Loop2	move.b	(a0)+,(a1)+			* primo carattere
	tst.b	(a0)
	bne.s	Loop2
	moveq	#0,d0				* Ritorna Done
	movem.l	(sp)+,d5-d7/a2-a6	
	rts
;--------------------------------------------------------------------------------------		
Trovato	subq.w	#2,a0				* Mi rimetto sul RTC_MATCHWORD
	moveq	#0,d0
	move.l	#"Ver.",(a1)+			* Post versione...
	move.l	a1,a2
	move.b	RT_VERSION(a0),d0		* versione...
	movem.l	a0-a1,-(sp)
	move.l	_AssemblyBase(a4),a6
	move.l	a1,a0
	moveq	#0,d1
	jsr	_LVOValueToStringDec(a6)
	movem.l	(sp)+,a0-a1	
	lea	NoId(pc),a1
	move.l	RT_IDSTRING(a0),d1		* id string...
	beq.s	SetStr
	move.l	d1,a1
;--------------------------------------------------------------------------------------		
SetStr	move.l	a2,a0
CerZero	tst.b	(a0)+
	bne.s	CerZero
	move.b	#" ",-(a0)
	addq.w	#6,a2
;--------------------------------------------------------------------------------------			
	move.l	a2,a3				* Save the buffer...
	tst.b	(a1)
	bne.s	CopyStr
	addq.w	#1,a1
	tst.b	(a1)
	bne.s	CopyStr
	lea	MalForm(pc),a1
AASTR	move.b	(a1),(a2)+
	tst.b	(a1)+
	bne.s	AASTR
	moveq	#0,d0				* Ritorna Done
	movem.l	(sp)+,d5-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------			
CopyStr	move.b	(a1)+,d0
	move.b	d0,d1
	beq.s	Finito
;--------------------------------------------------------------------------------------				
	cmpi.b	#" ",d0
	bge.s	SKT01
	moveq	#" ",d1
SKT01	cmpi.b	#"z",d0
	ble.s	SKT02
	moveq	#" ",d1		
SKT02	move.b	d1,(a2)+
	bra.s	CopyStr
;--------------------------------------------------------------------------------------				
Finito	move.b	d0,(a2)	
	moveq	#1,d0				* Ritorna Done
	movem.l	(sp)+,d5-d7/a2-a6
	rts
;--------------------------------------------------------------------------------------		
PriNot	lea	NonTro(pc),a0
CopyOne	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	CopyOne
	moveq	#1,d0				* Ritorna Done
	movem.l	(sp)+,d5-d7/a2-a6	
	rts
;--------------------------------------------------------------------------------------		
NonTro	STRING <"* --- NOT FOUND IN YOUR COMPARE DRAWER --- *">

NoId	STRING <"ID STRING NOT FOUND...">
MalForm	STRING <"MALFORMED ID STRING, Resident corrupt!">
NoMatch STRING <"RTC_MATCHWORD NOT FOUND, Can't get information!"> 

;--------------------------------------------------------------------------------------		
; SoFill(errorstring,filename,buffer)
;--------------------------------------------------------------------------------------		
SPOFF	SET 4*8
_SoFill	movem.l	d5-d7/a2-a6,-(sp)		* Save Regs on Stack...
	movem.l	SPOFF+8(sp),a0-a1		* prendo il nome e buffer...
;--------------------------------------------------------------------------------------		
	move.l	a1,a2
	moveq	#" ",d0
	moveq	#STRING_LEN,d1
1$	move.b	d0,(a1)+
	dbf	d1,1$
;--------------------------------------------------------------------------------------		
	move.l	a0,a2				* salvo nome in a2
	move.l	SPOFF+12(sp),a1
2$	move.b	(a0)+,(a1)+			* primo carattere
	tst.b	(a0)
	bne.s	2$
	suba.l	a2,a0
	move.l	a0,d0
	moveq	#30,d1
	sub.w	d0,d1
	add.l	d1,a1				* Versione...
;--------------------------------------------------------------------------------------			
	move.l	SPOFF+4(sp),a0			* IoError()
;--------------------------------------------------------------------------------------
	move.l	#"* --",(a1)+
	move.w	#"- ",(a1)+
	
3$	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	3$
	
	move.l	#" ---",(a1)+
	move.w	#" *",(a1)+
	move.b	#0,(a1)
	
	moveq	#1,d0				* Ritorna Done
	movem.l	(sp)+,d5-d7/a2-a6	
	rts

;--------------------------------------------------------------------------------------		
; RecoverFilename(STRPTR, STRPTR);
;--------------------------------------------------------------------------------------		
SPOFF	SET 4*0
_RecoverFilename
	movem.l	SPOFF+4(sp),a0-a1
	moveq	#29,d0
CoStr	move.b	(a0)+,(a1)+
	dbf	d0,CoStr
Rip	cmpi.b	#" ",-(a1)
	beq.s	Rip
	move.b	#0,1(a1)
	rts
;--------------------------------------------------------------------------------------
; NodeNumber(List,number)
;--------------------------------------------------------------------------------------		
SPOFF	SET 4*0
_NodeNumber
	move.l	SPOFF+4(sp),a0
	move.l	SPOFF+8(sp),d1	
NMCerca	move.l	(a0),d0				* offset remove = LN_SUCC
	beq.s	NMFine
	move.l	d0,a0
	dbf	d1,NMCerca
NMFine	rts

;--------------------------------------------------------------------------------------
; void ObtainError(STRPTR buffer)
;--------------------------------------------------------------------------------------
SPOFF	SET 4*4
_ObtainError
	movem.l	d2-d4/a6,-(sp)
	move.l	_AssemblyBase(a4),a6
	move.l	ab_DosBase(a6),a6
	jsr	_LVOIoErr(a6)
	move.l	d0,d1
	moveq	#0,d2
	move.l	SPOFF+4(sp),d3
	moveq	#80,d4
	jsr	_LVOFault(a6)
	movem.l	(sp)+,d2-d4/a6
	rts
;--------------------------------------------------------------------------------------
;  obj = LoadNewDTObjectA(name,taglist) (d0,a0)
;--------------------------------------------------------------------------------------
***************************************************************************************
* ### PRIVATE ###
* (9-Mar-1995) =Jon= --- obj = LoadNewDTObjectA(name,taglist) (d0,a0)
***************************************************************************************	
SPOFF	SET 4*1
_LoadNewDTObjectA
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),d0
	move.l	SPOFF+8(sp),a0
	move.l	_AssemblyBase(a4),a6
	bra.s	Skipp

_LoadNewDTObject
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),d0
	lea	SPOFF+8(sp),a0
	move.l	_AssemblyBase(a4),a6	

Skipp	movem.l	a2-a6,-(sp)
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
	move.l	(sp)+,a6
	rts
;--------------------------------------------------------------------------------------
OkTrova	move.l	d0,a3
	moveq	#0,d1			* root...
	jsr	_LVOCurrentDir(a6)
	move.l	a3,d0
	movem.l	(sp)+,a2-a6
	move.l	(sp)+,a6
	rts				
;--------------------------------------------------------------------------------------
DefImageDraw
	STRING <"sys:Classes/Images">
;-------------------------------------------------------------------------------------

**************************************************************************************
* CopyTextAttr(struct TextAttr *, struct TextAttr *);
**************************************************************************************
_CopyTextAttr
	move.l	4(sp),a0		* font requester
	move.l	a0,d0
	move.l	8(sp),a1		* my udd structure TextAttr
	move.l	4(a0),4(a1)		* Copy YSize and flags
	lea	8(a1),a0
	move.l	a0,(a1)			* set pointer to name...
	move.l	a0,a1
	move.l	d0,a0
	move.l	(a0),a0
CopiaF	move.b	(a0)+,(a1)+
	tst.b	(a0)
	bne.s	CopiaF	
	move.b	(a0)+,(a1)+
	rts

**************************************************************************************
* IInfo()
**************************************************************************************
_ShowIInfo	
	movem.l	a0-a6,-(sp)
	move.l	rim_Action(a1),d0
	subq.l	#1,d0
	bne.s	SIExit
	move.l	a2,a0				* move rei in a0
	jsr	_LVOInterfaceInfo(a6)
	movem.l	(sp)+,a0-a6
	moveq	#0,d0
	rts
SIExit	movem.l	(sp)+,a0-a6
	moveq	#-1,d0
	rts


**************************************************************************************
* MakeFontName(struct UpDateData *udd)
**************************************************************************************
_MakeFontName
	move.l	4(sp),a0
	lea	8(a0),a1
	move.l	a1,(a0)
	rts



	





