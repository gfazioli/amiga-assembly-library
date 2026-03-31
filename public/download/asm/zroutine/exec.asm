***************************************************************************************
* file - Exec - main exec file support commands
*
* Ver.41.1 - Table of contens
*
* RevertMem()		- V41.1
* AllocNewList()	- New
* AllocNode()		- New
* FreeNode()		- New
* FreeList()		- New
* FreeNodeName()	- New
* FreeListName()	- New
* ReAllocVec()		- New
*
***************************************************************************************

***************************************************************************************
* (V41.1) - 21-Oct-1994 =JON= *
***************************************************************************************
_LVORevertMem
	move.l	a1,d1
	sub.l	a0,d1			* D1 = numero di byte da invertire
	bhi.s	RVM_CON
	move.l	(sp)+,d2
	rts
RVM_CON	move.l	d2,-(sp)
	asr.w	d0,d1
	asr.w	#1,d1
	subq.w	#1,d1
	subq.w	#1,d0
	bmi.s	RVM_BYT
	beq.s	RVM_WOR
RVM_LON	move.l	-(a1),d2
	move.l	(a0)+,(a1)
	move.l	d2,-4(a0)
	dbf	d1,RVM_LON
	move.l	(sp)+,d2
	rts
RVM_WOR	move.w	-(a1),d2
	move.w	(a0)+,(a1)
	move.w	d2,-2(a0)
	dbf	d1,RVM_WOR
	move.l	(sp)+,d2
	rts
RVM_BYT	move.b	-(a1),d2
	move.b	(a0)+,(a1)
	move.b	d2,-1(a0)
	dbf	d1,RVM_BYT
	move.l	(sp)+,d2
	rts

***************************************************************************************
* (13-Jan-1995) --- AllocNewList()
***************************************************************************************
_LVOAllocNewList
	movem.l	d2/a6,-(sp)
	moveq	#4+LH_SIZE,d0			* D0 = SIZEOF
	move.l	d0,d2				* Save for PackAlloc()
	moveq	#1,d1
	swap	d1
	move.l	ab_ExecBase(a6),a6	* Exec...
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	ALFail			* Can't Alloc Memory...
	move.l	d0,a0			* A0 = (struct list *)
	move.l	d2,(a0)+		* A0 = True address da restituire...
	move.l	a0,LH_TAILPRED(a0)	* MY NEWLIST...
	addq.w	#4,a0
	move.l	a0,-(a0)
	move.l	a0,d0			* Result...
ALFail	movem.l	(sp)+,d2/a6
	rts
***************************************************************************************	
* (13-Jan-1995) --- AllocNode(List,name,type,pri) (a0/a1/d0/d1)
***************************************************************************************
_LVOAllocNode
	movem.l	d2-d4/a2-a6,-(sp)
	move.l	a0,a3				* Save struct List *
	move.l	a1,a2				* Save STRPTR string
	move.b	d0,d2				* type
	move.b	d1,d3				* pri
	moveq	#4+LN_SIZE,d0			* D0 = SIZEOF
	move.l	d0,d4				* Save for PackAlloc()
	moveq	#1,d1
	swap	d1
	move.l	ab_ExecBase(a6),a6	* Exec...
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	ANFail			* Can't Alloc Memory...
	move.l	d0,a5			* A5 = (struct Node *)
	move.l	d4,(a5)+		* A5 = True address da restituire...
	move.b	d2,LN_TYPE(a5)		* INIZIALIZZA IL NODE
	move.b	d3,LN_PRI(a5)
	move.l	a2,LN_NAME(a5)
	move.l	a3,d0			* Esiste una Lista??
	beq.s	ANExit			* No allora esci
	move.l	d0,a0			* List
	ENQUEUE	a5
ANExit	move.l	a5,d0			* Result...
ANFail	movem.l	(sp)+,d2-d4/a2-a6
	rts

***************************************************************************************
* (13-Jan-1995) --- FreeNode(list,node) (a0/a1)
***************************************************************************************
_LVOFreeNode
	movem.l	a5-a6,-(sp)
	move.l	a1,a5			* A5 = struct Node *
	REMOVE				* exec MACROS
	lea	-4(a5),a1
	moveq	#4+LN_SIZE,d0
	move.l	ab_ExecBase(a6),a6
	jsr	_LVOFreeMem(a6)	
	movem.l	(sp)+,a5-a6
	rts

***************************************************************************************
* (07-Feb-1995) --- FreeList(list) (a0)
***************************************************************************************	
_LVOFreeList
	movem.l	a4-a6,-(sp)
	move.l	a0,a4				* A4 = struct List *
	move.l	ab_ExecBase(a6),a6		* Prendo subito Exec...
FLCont	move.l	(a4),a1
	move.l	(a1),d0
	beq.s	FLFrLst				* Vai a liberare la struttura List
	move.l	a1,a5				* Save for FreeMem()
	move.l	a4,a0				* struct List *
	REMOVE					* exec MACROS
	lea	-4(a5),a1
	moveq	#4+LN_SIZE,d0
	jsr	_LVOFreeMem(a6)
	bra.s	FLCont
FLFrLst	lea	-4(a4),a1
	moveq	#4+LH_SIZE,d0
	jsr	_LVOFreeMem(a6)
	movem.l	(sp)+,a4-a6
	rts

***************************************************************************************
* (26-feb-1995) --- FreeNodeName(list,node) (a0/a1)
***************************************************************************************
_LVOFreeNodeName
	movem.l	a5-a6,-(sp)
	move.l	a1,a5			* A5 = struct Node *
	REMOVE				* exec MACROS
	move.l	ab_ExecBase(a6),a6	* Prendo Exec...
	move.l	LN_NAME(a5),d0
	beq.s	OnlyNod
	move.l	d0,a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)		* Libero la stringa...
OnlyNod	lea	-4(a5),a1
	moveq	#4+LN_SIZE,d0		
	jsr	_LVOFreeMem(a6)		* Libero il Nodo...
	movem.l	(sp)+,a5-a6
	rts

***************************************************************************************
* (26-Feb-1995) --- FreeListName(list) (a0)
***************************************************************************************	
_LVOFreeListName
	movem.l	a4-a6,-(sp)
	move.l	a0,a4				* A4 = struct List *
	move.l	ab_ExecBase(a6),a6		* Prendo subito Exec...
FLNCont	move.l	(a4),a1
	move.l	(a1),d0
	beq.s	FLNLst				* Vai a liberare la struttura List
	move.l	a1,a5				* Save for FreeMem()
	move.l	a4,a0				* struct List *
	REMOVE					* exec MACROS
	move.l	LN_NAME(a5),d0
	beq.s	ONode
	move.l	d0,a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)			* Libero la stringa...
ONode	lea	-4(a5),a1
	moveq	#4+LN_SIZE,d0
	jsr	_LVOFreeMem(a6)
	bra.s	FLNCont
FLNLst	lea	-4(a4),a1
	moveq	#4+LH_SIZE,d0
	jsr	_LVOFreeMem(a6)
	movem.l	(sp)+,a4-a6
	rts
***************************************************************************************

***************************************************************************************
* (29-Sep-1995) --- newmemoryBlock = ReAllocVec(oldmemoryBlock, newsize, newattr) (a0/d0/d1)
***************************************************************************************	
_LVOReAllocVec
	movem.l	d2-d7/a2-a6,-(sp)	
	move.l	a0,a2				* Save old memoryBlock
	move.l	d0,d2				* Save new size
	move.l	ab_ExecBase(a6),a6		* take exec.library base
;;;;;;;;jsr	_LVOForbid(a6)			* multitasking off
	addq.b  #1,TDNestCnt(A6)		* FORBID
	tst.l	d1				* non ci sono nuovi attributi
	bne.s	MakeNewAlloc			* allora usa quelli vecchi...
	move.l	a2,a1
	jsr	_LVOTypeOfMem(a6)		* ricavo attributi vecchio block
	move.l	d0,d1				* li metto in D1
MakeNewAlloc
	addq.l	#4,d2
	move.l	d2,d0				* new size memoty block
	jsr	_LVOAllocMem(a6)
	tst.l	d0
	beq.s	RAVFail
	move.l	d0,a3				* new memory Block
	move.l	d2,(a3)+			* make AllocVec() function...
	;
	move.l	-4(a2),d0			* size old memoryBlock
	cmp.l	d2,d0				* if old <= new then
	ble.s	CopySo				* if d0 <= d2 then
	move.l	d2,d0				* copia fino dov'è possibile...
	;
CopySo	move.l	a2,a0				* old memoryBlock
	move.l	a3,a1				* new memoryBlock
	jsr	_LVOCopyMemQuick(a6)
	;
	move.l	a2,a1
	move.l	-(a1),d0
	jsr	_LVOFreeMem(a6)
	jsr	_LVOPermit(a6)
	move.l	a3,d0				* return()
	movem.l	(sp)+,d2-d7/a2-a6
	rts
RAVFail	jsr	_LVOPermit(a6)
	moveq	#0,d0
	movem.l	(sp)+,d2-d7/a2-a6
	rts
***************************************************************************************
