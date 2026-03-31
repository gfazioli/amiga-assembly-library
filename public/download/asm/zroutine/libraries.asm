****************************************************************************
* file - Libraries - Generic libraries file support commands
*
* Ver.41.1 - Tables of Contents
*
* ChangeChar()		- V37
* FilterChars()		- V37
* StringToUpper()	- New
* StringToLower()	- New
* SortStrings()		- V39
* AS_AslRequest()	- V40
* FindAIFFChunk()	- V34 -i-
* TestAIFFChunk()	- V34 -i- forse l'unico recuperabile per V41
* NextIFFChunk()	- V34 -i-
* UnPackerILBMBODY()	- V36 -i- Unpacca fino a 8bitplanes (256!!) :)
* UnPackerILBMCMAP()	- V34 -i-
*
****************************************************************************

*******************
* 26-Nov-1994, Ok *
*******************
_LVOChangeChar
	movem.l	d0-d5/a0,-(sp)
	moveq	#0,d5
	move.w	d0,d4
	subq.w	#1,d4
CC_CMPtwo
	tst.w	d0
	bne.s	CC_CMP
CC_TestZero
	moveq	#1,d4
	tst.b	(a0)
	beq.s	CC_Exit
CC_CMP	move.b	(a0),d3
	cmp.b	d1,d3
	bne.s	CC_NoFind
	move.b	d2,(a0)
	addq.w	#1,d5
CC_NoFind
	addq.w	#1,a0
	dbf	d4,CC_CMPtwo
CC_Exit	move.l	d5,(sp)
	movem.l	(sp)+,d0-d5/a0
	move.l	d0,d0
	rts

***************************************************************************************
* (25-feb-1995)
***************************************************************************************
_LVOFilterChars
	movem.l d4/a0,-(sp)
	subq.w	#1,d0
	moveq	#0,d4
FC_Start
	move.b	(a0),d4
	cmp.b	d1,d4
	bmi.s	FC_Replace
	cmp.b	d2,d4
	bhi.s	FC_Replace
	bra.s	FC_Repeat
FC_Replace
	move.b	d3,(a0)
FC_Repeat
	addq.w	#1,a0
	dbf	d0,FC_Start
	movem.l (sp)+,d4/a0
	rts

*******************
* 26-Nov-1994, Ok *
*******************
_LVOStringToUpper
	movem.l	d2/a4-a6,-(sp)
	move.l	a0,a4
	move.l	ab_Locale(a6),a5
	move.l	ab_LocaleBase(a6),a6
	move.l	d0,d2
	bne.s	SkLen
	moveq	#-1,d2
CalLen	tst.b	(a0)+
	dbeq	d2,CalLen
	neg.l	d2
SkLen	subq.l	#1,d2
TLop	move.b	(a4),d0	
	move.l	a5,a0
	jsr	_LVOConvToUpper(a6)
	move.b	d0,(a4)+
	dbeq	d2,TLop
SU_End	movem.l	(sp)+,d2/a4-a6
	rts

*******************
* 26-Nov-1994, Ok *
*******************
_LVOStringToLower
	movem.l	d2/a4-a6,-(sp)
	move.l	a0,a4
	move.l	ab_Locale(a6),a5
	move.l	ab_LocaleBase(a6),a6
	move.l	d0,d2
	bne.s	LSkLen
	moveq	#-1,d2
LCalLen	tst.b	(a0)+
	dbeq	d2,LCalLen
	neg.l	d2
LSkLen	subq.l	#1,d2
LTLop	move.b	(a4),d0	
	move.l	a5,a0
	jsr	_LVOConvToLower(a6)
	move.b	d0,(a4)+
	dbeq	d2,LTLop
LSU_End	movem.l	(sp)+,d2/a4-a6
	rts

****************************************************************************
;Rel.39 14 May 1994 =jon=
_LVOAS_AslRequest
	movem.l	a5-a6,-(sp)
*	move.l	rei_AslSupport(a0),d1
	beq.s	MAR_EXT
	move.l	d1,a0
MAR_LPS	cmp.w	(a0),d0
	beq.s	MAR_FUD
	lea	12(a0),a0
	bra.s	MAR_LPS
MAR_FUD	move.l	8(a0),a0
	move.l	a0,a5
	move.l	ab_AslBase(a6),a6
	jsr	_LVOAslRequest(a6)
	tst.l	d0
	beq.s	MAR_EXT	
	move.l	a5,d0
MAR_EXT	movem.l	(sp)+,a5-a6
	rts
	
****************************************************************************
* Rel.3.1 * Last save: Apr 11 1994 =JON=
_LVOFindAIFFChunk
	move.l	a1,-(sp)
	lea	"FORM",a1
	cmp.l	(a0),a1
	bne.s	FIFF_NoINIT
	addq.l	#8,a0
	addq.l	#4,a0
FIFF_NoINIT
	move.l	d0,d1
FIFF_CheckLoop
	bsr.s	_LVOTestAIFFChunk
	beq.s	FIFFChunk_Exit
	cmp.l	(a0),d1
	beq.s	FIFF_FindIt
	bsr.s	_LVONextIFFChunk
	bra.s	FIFF_CheckLoop
FIFF_FindIt
	movem.l	(a0),d0-d1
FIFFChunk_Exit
	move.l	(sp)+,a1
	rts
	
* Rel.1.1 * Last save: Lug 29 09:10 1991 =JON=
_LVOTestAIFFChunk
	move.l	a1,-(sp)
	move.l	(a0),d0
	lea	"AAAA",a1
	cmp.l	a1,d0
	bmi.s	CheckAChunk_Error
	lea	"ZZZZ",a1
	cmp.l	a1,d0
	bhi.s	CheckAChunk_Error
	move.l	(sp)+,a1
	rts
CheckAChunk_Error
	moveq	#0,d0
	move.l	(sp)+,a1
	rts
	
* Rel.1.0 * Last save: Lug 29 09:10 1991 =JON=	
_LVONextIFFChunk
	move.l	4(a0),d0
	lea	8(a0,d0.l),a0
	move.l	4(a0),d0
	rts
* Rel.2.0 * Last save: 17:30 21 Oct 1991 =JON=
_LVOUnPackerILBMBODY
	movem.l	d0-d7/a0-a6,-(sp)

	movem.w	ClearRegs,d0-d7		* Clear all reags
	movem.l	d0-d7,-(sp)		* 8 LONGS for planes Save

	move.l	a7,a6			* My buffer for 8 max planes
	lea	bm_Planes(a1),a5	* Original Planes

	moveq	#0,d0
	move.b	bm_Depth(a1),d0	
	subq.l	#1,d0			* Align for dbf
	move.l	a5,a2
UPIBody_Copy
	move.l	(a2)+,(a6)+
	dbf	d0,UPIBody_Copy

	move.l	a7,a6			* ReSet
	move.l	a6,a4			* A4 DO NOT SCRATCH!!!

	move.w	bm_BytesPerRow(a1),d2	* copys pixel x
UPIBody_Y
	move.l	32(sp),d0
	beq.s	UPIBody_Heigth
	cmp.w	bm_Rows(a1),d0
	bls.s	UPIBody_TakeYMinus
UPIBody_Heigth
	move.w	bm_Rows(a1),d3		* copys	pixel y
	bra.s	UPIBody_UnPacker
UPIBody_TakeYMinus
	move.l	d0,d3

*********************************************
* UnPacker ©1991 TLED ©1985-1991 EA, Inc.   *
*					    *
* Author: =JON=				    *
* File date over: 17-Oct-1991		    *
*					    *
* Private Regs:				    *
*					    *
* D0 reserved for cmp value compression	    *
* D1 unused -- scratch			    *
* D2 reserved pixel x			    *
* D3 reserved pixel y			    *
* D4 new features cmp y value cmp (D3)	    *
* D5 reserved for value to write -n+1 times *
* D6 reserved for Algo unPacker	    	    *
* D7 reserved count x pixel cmp (D2)	    *
*********************************************
UPIBody_UnPacker
	movem.w	ClearRegs,d0/d4-d7
	move.l	(a6),a1			* Fisrt Planes

UPIBody_Check
	move.b	(a0)+,d0
	cmpi.b	#128,d0
	beq.s	UPIBody_Check
	cmpi.b	#127,d0
	bls.s	UPIBody_Pn
	beq.s	UPIBody_Pn

UPIBody_Nn
	neg.b	d0
	move.l	d0,d6
	move.b	(a0)+,d5
	bsr.s	UPIBody_WriteNn
	bra.s	UPIBody_Check

UPIBody_Pn
	move.l	d0,d6
	bsr.s	UPIBody_WritePn
	bra.s	UPIBody_Check

UPIBody_WriteNn
	move.b 	d5,(a1)+
	addq.w	#1,d7			* Only WORD for now (CHIP MEM)
	cmp.w	d7,d2
	beq.s	UPIBody_NextBitPlanes
	dbf	d6,UPIBody_WriteNn
UPIBody_WriteNnEnd
	rts

UPIBody_WritePn
	move.b (a0)+,(a1)+
	addq.w	#1,d7			* Only WORD for now (CHIP MEM)
	cmp.w	d7,d2
	beq.s	UPIBody_NextBitPlanes
	dbf	d6,UPIBody_WritePn
UPIBody_WritePnEnd
	rts

UPIBody_NextBitPlanes
	moveq	#0,d7
	move.l	a1,(a6)+
	move.l	(a6),d1
	beq.s	UPIBody_ReStartBitPlanes
	move.l	d1,a1
	rts
UPIBody_ReStartBitPlanes
	addq.w	#1,d4			* New features
	cmp.w	d4,d3
	beq.s	UPIBody_PExit		* Vertical Position OFF!!
	move.l	a4,a6
	move.l	(a6),a1
	rts
UPIBody_PExit
	addq.l	#4,sp
UPIBody_Exit
	movem.l	(sp)+,d0-d7		* 8 LONGS for planes Refree
	movem.l	(sp)+,d0-d7/a0-a6
	tst.l	d0
	rts
UPIBody_Error
	suba.l	a0,a0
	move.l	a0,(sp)
	bra.s	UPIBody_Exit

* Rel.2.3 * Last save: 12 Oct 08:10 1991 =JON=
_LVOUnPackerILBMCMAP
	movem.l	d1-d7/a1-a6,-(sp)
	lea	"CMAP",a2
	move.l	a2,d0
	jsr	_LVOFindAIFFChunk
	beq.s	UnPackCMAP_Exit
	move.l	a1,a2			* save dest buf
	lea	8(a0),a3		* save sorg data
	move.l	d1,d0
	moveq	#3,d1
	divu	d1,d0			* nColors
	add.w	d0,d0			* double for word, nbyte to alloc
	moveq	#0,d7
	move.w	d0,d7			* Dbf
	move.l	a1,d6			* Alloc ColorTable?
	bne.s	UnPackCMAP_NoAlloc
	moveq	#1,d1
	move.l	ab_ExecBase(a6),a6
	jsr	_LVOAllocMem(a6)
	tst.l	d0			* Rel.2.0
	beq.s	UnPackCMAP_Exit
	move.l	d0,a2
UnPackCMAP_NoAlloc
	jsr	_LVOForbid(a6)
	move.l	d7,d6
	subq.l	#1,d7			* Align dbf
	movem.w	ClearRegs,d0-d2
	move.l	a2,a1
UnPackCMAP_Loop
	move.b	(a3)+,d0
	asl.w	#4,d0
	move.b	(a3)+,d1
	move.b	(a3)+,d2
	asr.w	#4,d2
	or.w	d0,d1
	or.w 	d1,d2
	move.w	d2,(a1)+
	movem.w	ClearRegs,d0-d2
	dbf	d7,UnPackCMAP_Loop
	jsr	_LVOPermit(a6)
	move.l	a2,a0			* ColorTable
	move.l	d6,d0			* ncolors
UnPackCMAP_Exit
	movem.l	(sp)+,d1-d7/a1-a6
	rts
