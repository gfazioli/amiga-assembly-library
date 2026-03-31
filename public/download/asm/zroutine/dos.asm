***************************************************************************************
* file - Dos - Main Dos support comands
*
* Ver.41.1 - Table of Contents
*
* Load()		- Rev.
* FileInfo()		- Rev.
* Save()		- Rev.
* CheckFile()		- Rev.
* UnitInfo()		- Rev.
* CheckSum()		- Rev.
* LineInput()		- Rev.
*
***************************************************************************************
	SECTION ASSEMBLY_LIBRARY,CODE
***************************************************************************************
* (15-feb-1995) - Make up --- buffer = Load(filename,buffer,typeofmem) (a0/a1/d0)
***************************************************************************************
_LVOLoad
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	a6,a5			* Save AssemblyBase
	move.l	a0,a4			* Save FileName
	move.l	a1,a3			* Save Buffer
	move.l	a3,a2			* Copy buffer for CTRL!!!
	move.l	d0,d7			* TypeOfMem?
	bne.s	Load_OkTypeMem		* Si?
	moveq	#MEMF_PUBLIC,d7		* Default
Load_OkTypeMem
	bsr.s	_LVOFileInfo
	tst.l	d0
	beq.s	Load_Exit
	move.l	d0,a1
	move.l	fib_Size(a1),d3		* byte size in D3
	move.l	ab_ExecBase(a5),a6	* Exec
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)	
	move.l	a3,d0			* Mem personale?
	bne.s	Load_NoAlloc		* Si
	addq.l	#4,d3			* For AllocVec()
	move.l	d3,d0			* byteLen
	move.l	d7,d1			* type of mem
	jsr	_LVOAllocMem(a6)
	tst.l	d0			* Null = errore
	beq.s	Load_Exit
	move.l	d0,a3			* Save buffer in A3
	move.l	d3,(a3)+		* Byte da liberare...
	subq.l	#4,d3			* Byte da leggere...
Load_NoAlloc
	move.l	ab_DosBase(a5),a6	* DosBase
	move.l	a4,d1			* filename
	lea	MODE_OLDFILE.w,a0	
	move.l	a0,d2			* tipo di accesso
	jsr	_LVOOpen(a6)		* in teoria lo dovrebbe aprire per forza
	tst.l	d0			* Null = errore
	beq.s	Load_Exit2
	move.l	d0,d5			* BCPL handle in D5
	move.l	d5,d1			* handle in D1			
	move.l	a3,d2			* buffer in D2/ bytelen in D3
	jsr	_LVORead(a6)
	move.l	d5,d1
	jsr	_LVOClose(a6)
	move.l	a3,d0
Load_Exit
	movem.l	(sp)+,d2-d7/a2-a6
	rts
Load_Exit2
	move.l	a2,d1		* Il buffer l'ho allocato io o l'ha passato??
	bne.s	Load_Exit	* l'ha passato...
	move.l	a3,a1		* Ok, dato che l'ha allocato Load(), allora
	move.l	-(a1),d0	* lo frio!!
	move.l	ab_ExecBase(a5),a6
	jsr	_LVOFreeMem(a6)
	moveq	#0,d0		* Failure...
	movem.l	(sp)+,d2-d7/a2-a6
	rts

***************************************************************************************
* (15-Feb-1995) Make up ---  FileInfoBlock = FileInfo(filename) (a0)
***************************************************************************************
_LVOFileInfo
	movem.l	d2-d4/a2-a6,-(sp)
	move.l	a0,d4
	move.l	a6,a5
	move.l	ab_ExecBase(a5),a6
	move.l	#fib_SIZEOF+4,d0
	move.l	d0,d2
	moveq	#MEMF_PUBLIC,d1
	jsr	_LVOAllocMem(a6)
	tst.l	d0			* Rel.2.0
	beq.s	FileInfo_Exit
	move.l	d0,a4
	move.l	d2,(a4)+		* AllocVec()
	move.l	ab_DosBase(a5),a6
	move.l	d4,d1
	moveq	#ACCESS_READ,d2
	jsr	_LVOLock(a6)
	move.l	d0,d4
	beq.s	FileInfo_Error
	move.l	d0,d1
	move.l	a4,d2
	jsr	_LVOExamine(a6)
	move.l	d4,d1
	jsr	_LVOUnLock(a6)
	move.l	a4,d0
FileInfo_Exit	
	movem.l	(sp)+,d2-d4/a2-a6
	rts
FileInfo_Error
	move.l	ab_ExecBase(a5),a6
	move.l	a4,a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
	moveq	#0,d0
	movem.l	(sp)+,d2-d4/a2-a6
	rts

***************************************************************************************
* (15-Feb-1995) Meke up --- Save (filename,buffer,len) (a0/a1/d0)
***************************************************************************************
_LVOSave
	movem.l	d2-d4/a2/a6,-(sp)
	move.l	a1,a2			* Save Pointer to buffer
	move.l	d0,d3			* Save byte len...
	move.l	ab_DosBase(a6),a6
	move.l	a0,d1
	lea	MODE_READWRITE.W,a0
	move.l	a0,d2
	jsr	_LVOOpen(a6)
	tst.l	d0
	beq.s	NSSEXIT
	move.l	d0,d4			* Save BCPL handle
	tst.l	d3
	bne.s	UseThis
	move.l	-4(a2),d3		* byte TOT
	subq.l	#4,d3			* byte data to write
UseThis	move.l	d4,d1			* handle
	move.l	a2,d2
	jsr	_LVOWrite(a6)
	move.l	d4,d1
	jsr	_LVOClose(a6)
	move.l	d3,d0
NSSEXIT	movem.l	(sp)+,d2-d4/a2/a6
	rts

***************************************************************************************
* (02-Mar-1995) Make up --- error = CheckFile(filename,buffer) (a0/a1)
***************************************************************************************
_LVOCheckFile
	movem.l	d2-d6/a6,-(sp)
	move.l	a1,d6			* Save Buffer
	move.l	ab_DosBase(a6),a6
	move.l	a0,d1
	lea	MODE_OLDFILE.W,A0
	move.l	a0,d2
	jsr	_LVOOpen(a6)
	tst.l	d0
	bne.s	CK_CLO
	jsr	_LVOIoErr(a6)
	move.l	d0,d5
CKGOERR	move.l	d6,d3		* output buffer
	beq.s	CK_NTX	
	move.l	d5,d1		* Error code
	moveq	#0,d2		* header buffer null
	moveq	#80,d4
	jsr	_LVOFault(a6)
	move.l	d5,d0
CK_NTX 	movem.l	(sp)+,d2-d6/a6	
	rts
CK_CLO	move.l	d0,d1
	jsr	_LVOClose(a6)
	moveq	#0,d0
	movem.l	(sp)+,d2-d6/a6
	rts

***************************************************************************************
* (15-Feb-1995) Make up --- info = UnitInfo(volumename) (a0)
***************************************************************************************
_LVOUnitInfo
	movem.l	d2-d4/a4-a6,-(sp)
	move.l	a0,d4			* Save FileName
	move.l	a6,a5			* Save AssemblyBase
	move.l	ab_ExecBase(a5),a6
	moveq	#id_SIZEOF+4,d0
	moveq	#1,d1
	swap	d1
	jsr	_LVOAllocMem(a6)
	tst.l	d0			* Rel.2.0
	beq.s	UnitInfo_Exit
	move.l	d0,a4
	move.l	ab_DosBase(a5),a6
	move.l	d4,d1
	moveq	#ACCESS_READ,d2
	jsr	_LVOLock(a6)
	move.l	d0,d4
	beq.s	UnitInfo_Error
	move.l	d0,d1
	move.l	a4,d2
	jsr	_LVOInfo(a6)
	move.l	d4,d1
	jsr	_LVOUnLock(a6)
	move.l	a4,d0
UnitInfo_Exit
	movem.l	(sp)+,d2-d4/a4-a6
	rts
UnitInfo_Error
	move.l	ab_ExecBase(a5),a6
	move.l	-(a4),d0
	move.l	a4,a1
	jsr	_LVOFreeMem(a6)
	moveq	#0,d0
	movem.l	(sp)+,d2-d4/a4-a6
	rts

***************************************************************************************
* (15-Feb-1995) Make Up --- CheckSum(buffer,type) (a0,d0)
***************************************************************************************
_LVOCheckSum
	movem.l	d0-d1/a0-a1,-(sp)
	tst.l	d0
	beq.s	CKSBoot
	moveq	#0,d0
	moveq	#$7F,d1
	lea	BB_SIZE(a0),a1		; CheckSum pointer
	move.l	d0,(a1)			; Clear it
CKSLoop	sub.l	(a0)+,d0
	dbf	d1,CKSLoop
	move.l	d0,(a1)			; Set!!
CKSExit	movem.l	(sp)+,d0-d1/a0-a1
	rts
CKSBoot	move.l	d0,BB_CHKSUM(a0)	; Clear Old CheckSum
	moveq	#1,d1
	lea	BB_CHKSUM(a0),a1	; Save CheckSum pointer
CKSBLp	add.l	(a0)+,d0
	bcc.s	CKSJump
	addq.l	#1,d0
CKSJump	dbf	d1,CKSBLp
	not.l	d0
	move.l	d0,(a1)
	movem.l	(sp)+,d0-d1/a0-a1
	rts

; Old Algo by =STID=
;
;CheckSumBoot
;	lea	4(a0),a1
;	clr.l	(a1)
;	move.w	#$00ff,d1
;	moveq	#0,d0
;CheckSumBootLoop
;	add.l	(a0)+,d0
;	bcc.s	CheckSumBootJump
;	addq.l	#1,d0
;CheckSumBootJump
;	dbf	d1,CheckSumBootLoop
;	not.l	d0
;	move.l	d0,(a1)
;	bra.s	CheckSumExit

***************************************************************************************
* (15-Feb-1995) Make up --- len = LineInput (buffer, chars, Handle) (a0/d0,d1)
***************************************************************************************
_LVOLineInput
	tst.l	d0
	beq.s	LInput_Exit
	movem.l	d2-d3/a6,-(sp)
	move.l	ab_DosBase(a6),a6
	move.l	d0,d3
	move.l	a0,d2
	tst.l	d1
	bne.s	LI_Handle
	jsr	_LVOInput(a6)
	move.l	d0,d1
LI_Handle
	jsr	_LVORead(a6)
	move.l	d2,a0
	movem.l	(sp)+,d2-d3/a6
LInput_Exit
	rts
