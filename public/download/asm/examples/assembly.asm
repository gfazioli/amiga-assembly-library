*****************************************************************************
*
* Assembly.Lib -- file .o -- $VER.1.1
*
* Questo file va Assemblato in modo "linked", e registrato sotto il file
* Assembly.Lib
*
*****************************************************************************

	include DevPac:system
	
	incdir	include_I:
	include assembly/assembly.i
	include assembly/assembly_lib.i

	XDEF	_HookEntry		* Solo in .lib file		
	XDEF	_LoadNewDTObjectA
	XDEF	_LoadNewDTObject
	;
	XDEF	_FileInfo
	XDEF	_Load
	XDEF	_Save
	XDEF	_CheckSum
	XDEF	_LineInput
	XDEF	_UnitInfo
	XDEF	_CheckFile
	XDEF	_FreeNodeName
	XDEF	_FreeListName
	XDEF	_FreeNode
	XDEF	_RevertMem
	XDEF	_AllocNewList
	XDEF	_AllocNode
	XDEF	_FreeList
	XDEF	_AllocRastPort
	XDEF	_CloneRastPort
	XDEF	_NewAllocRaster
	XDEF	_AddBitPlanes
	XDEF	_RemoveBitPlanes
	XDEF	_TextFmtRastPortArgs
	XDEF	_TextFmtRastPort
	XDEF	_DrawBox
	XDEF	_DrawFrameStateA
	XDEF	_DrawFrameState
	XDEF	_EraseInternalRect
	XDEF	_OpenInterface
	XDEF	_CloseInterface
	XDEF	_OpenREIA
	XDEF	_OpenREI
	XDEF	_CloseREI
	XDEF	_ActiveREI
	XDEF	_FindREI
	XDEF	_RefreshREI
	XDEF	_WaitREIMsg
	XDEF	_LockREI
	XDEF	_UnlockREI
	XDEF	_AS_MenuAddress
	XDEF	_SetREIAttrsA
	XDEF	_SetREIAttrs
	XDEF	_GetREIAttrsA
	XDEF	_GetREIAttrs
	XDEF	_FindAsmGadget
	XDEF	_TextFmtSizeArgs
	XDEF	_TextFmtSize
	XDEF	_AllocAsmRequestA
	XDEF	_AllocAsmRequest
	XDEF	_FreeAsmRequest
	XDEF	_AsmRequestArgs
	XDEF	_AsmRequest
	XDEF	_ChangeAsmReqAttrsA
	XDEF	_ChangeAsmReqAttrs
	XDEF	_SetAsmGadgetAttrsA
	XDEF	_SetAsmGadgetAttrs
	XDEF	_GetAsmGadgetAttr
	XDEF	_InterfaceInfo
	XDEF	_StringDecToValue
	XDEF	_StringHexToValue
	XDEF	_StringBinToValue
	XDEF	_ValueToStringDec
	XDEF	_ValueToStringHex
	XDEF	_ValueToStringBin
	XDEF	_ChangeChar
	XDEF	_FilterChars
	XDEF	_StringToLower
	XDEF	_StringToUpper
	XDEF	_ReAllocVec
	
	XREF	_AssemblyBase
;---------------------------------------------------------------------------
_HookEntry
	move.l	a1,-(sp)
	move.l	a2,-(sp)
	move.l	a0,-(sp)
	move.l	h_SubEntry(a0),a0
	jsr	(a0)
	lea	12(sp),sp
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
;-----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
SPOFF	SET 1*4
_FileInfo	
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0		* filename
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFileInfo(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_Load	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1	* filename/Buffer
	move.l	SPOFF+12(sp),d0		* typeofmem
	move.l	_AssemblyBase(a4),a6	
	jsr	_LVOLoad(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_Save	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1	
	move.l	SPOFF+12(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOSave(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_CheckSum
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0		* void *
	move.l	SPOFF+8(sp),d0		* type of calculation
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOCheckSum(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_LineInput
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOLineInput(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_UnitInfo
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOUnitInfo(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_CheckFile
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOCheckFile(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_FreeNodeName
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFreeNodeName(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_FreeListName
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFreeListName(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_FreeNode
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFreeNode(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_RevertMem
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1
	move.l	SPOFF+12(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVORevertMem(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_AllocNewList
	move.l	a6,-(sp)
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAllocNewList(a6)
	move.l	(sp)+,a6
	rts			
;---------------------------------------------------------------------------
_AllocNode
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0/a1
	movem.l SPOFF+12(sp),d0/d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAllocNode(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_FreeList
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFreeList(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_AllocRastPort
	move.l	a6,-(sp)
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAllocRastPort(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_CloneRastPort
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOCloneRastPort(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_NewAllocRaster
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),d0-d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVONewAllocRaster(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_AddBitPlanes
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	SPOFF+8(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAddBitPlanes(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_RemoveBitPlanes
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	SPOFF+8(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVORemoveBitPlanes(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 3*4
_TextFmtRastPortArgs
	movem.l	d2/a2/a6,-(sp)
	move.l	SPOFF+4(sp),a1
	move.l	SPOFF+8(sp),a0
	movem.l	SPOFF+12(sp),d0-d2
	move.l	SPOFF+24(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOTextFmtRastPortArgs(a6)
	movem.l	(sp)+,d2/a2/a6
	rts
;---------------------------------------------------------------------------
_TextFmtRastPort
	movem.l	d2/a2/a6,-(sp)
	move.l	SPOFF+4(sp),a1
	move.l	SPOFF+8(sp),a0
	movem.l	SPOFF+12(sp),d0-d2
	lea	SPOFF+24(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOTextFmtRastPortArgs(a6)
	movem.l	(sp)+,d2/a2/a6
	rts	
;---------------------------------------------------------------------------
SPOFF	SET 3*4
_DrawBox
	movem.l	d2-d3/a6,-(sp)
	move.l	SPOFF+4(sp),a1
	movem.l	SPOFF+8(sp),d0-d3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVODrawBox(a6)
	movem.l	(sp)+,d2-d3/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 4*4
_DrawFrameStateA
	movem.l	d2-d4/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d4
	move.l	SPOFF+28(sp),a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVODrawFrameStateA(a6)
	movem.l	(sp)+,d2-d4/a6
	rts
;---------------------------------------------------------------------------
_DrawFrameState
	movem.l	d2-d4/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d4
	lea	SPOFF+28(sp),a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVODrawFrameStateA(a6)
	movem.l	(sp)+,d2-d4/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_EraseInternalRect	
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOEraseInternalRect(a6)
	move.l	(sp)+,a6
;---------------------------------------------------------------------------
_OpenInterface
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOOpenInterface(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_CloseInterface
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOCloseInterface(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_OpenREIA
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOOpenREIA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
_OpenREI
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	lea	SPOFF+12(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOOpenREIA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_CloseREI
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOCloseREI(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_ActiveREI
	move.l	a6,-(sp)
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOActiveREI(a6)
	move.l	(sp)+,a6
	rts		
;---------------------------------------------------------------------------
_FindREI
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFindREI(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_RefreshREI
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVORefreshREI(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_WaitREIMsg
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	SPOFF+8(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOWaitREIMsg(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_LockREI
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOLockREI(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_UnlockREI
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOUnlockREI(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_AS_MenuAddress
	movem.l	d2/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAS_MenuAddress(a6)
	movem.l	(sp)+,d2/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_SetREIAttrsA
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOSetREIAttrsA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
_SetREIAttrs
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	lea	SPOFF+12(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOSetREIAttrsA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
_GetREIAttrsA
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOGetREIAttrsA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
_GetREIAttrs
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	lea	SPOFF+12(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOGetREIAttrsA(a6)
	movem.l	(sp)+,a2/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_FindAsmGadget
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFindAsmGadget(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------	
SPOFF	SET 3*4
_TextFmtSizeArgs
	movem.l	a2-a3/a6,-(sp)
	move.l	SPOFF+4(sp),a1
	move.l	SPOFF+8(sp),a3
	move.l	SPOFF+12(sp),a0
	move.l	SPOFF+16(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOTextFmtSizeArgs(a6)
	movem.l	(sp)+,a2-a3/a6
	rts
;---------------------------------------------------------------------------
_TextFmtSize
	movem.l	a2-a3/a6,-(sp)
	move.l	SPOFF+4(sp),a1
	move.l	SPOFF+8(sp),a3
	move.l	SPOFF+12(sp),a0
	lea	SPOFF+16(sp),a2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOTextFmtSizeArgs(a6)
	movem.l	(sp)+,a2-a3/a6
	rts

;---------------------------------------------------------------------------
SPOFF	SET 1*4
_AllocAsmRequestA
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAllocAsmRequestA(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_AllocAsmRequest
	move.l	a6,-(sp)
	lea	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAllocAsmRequestA(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_FreeAsmRequest
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFreeAsmRequest(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
SPOFF	SET 3*4
_AsmRequestArgs
	movem.l	a2-a3/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAsmRequestArgs(a6)
	movem.l	(sp)+,a2-a3/a6
	rts
;---------------------------------------------------------------------------
_AsmRequest
	movem.l	a2-a3/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	lea	SPOFF+16(sp),a3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOAsmRequestArgs(a6)
	movem.l	(sp)+,a2-a3/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_ChangeAsmReqAttrsA
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOChangeAsmReqAttrsA(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_ChangeAsmReqAttrs
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	lea	SPOFF+8(sp),a1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOChangeAsmReqAttrsA(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
SPOFF	SET 3*4
_SetAsmGadgetAttrsA
	movem.l	a2-a3/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOSetAsmGadgetAttrsA(a6)
	movem.l	(sp)+,a2-a3/a6
	rts	
;---------------------------------------------------------------------------
_SetAsmGadgetAttrs
	movem.l	a2-a3/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	lea	SPOFF+16(sp),a3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOSetAsmGadgetAttrsA(a6)
	movem.l	(sp)+,a2-a3/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_GetAsmGadgetAttr
	movem.l	a2/a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a2
	move.l	SPOFF+16(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOGetAsmGadgetAttr(a6)
	movem.l	(sp)+,a2/a6
	rts	
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_InterfaceInfo
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOInterfaceInfo(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_StringDecToValue
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOStringDecToValue(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_StringHexToValue
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOStringHexToValue(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_StringBinToValue
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	move.l	SPOFF+8(sp),d0	
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOStringBinToValue(a6)
	move.l	(sp)+,a6
	rts	
;---------------------------------------------------------------------------
_ValueToStringDec
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOValueToStringDec(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_ValueToStringHex
	movem.l	d2/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOValueToStringHex(a6)
	movem.l	(sp)+,d2/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_ValueToStringBin
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOValueToStringBin(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 2*4
_ChangeChar
	movem.l	d2/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d2
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOChangeChar(a6)
	movem.l	(sp)+,d2/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 3*4
_FilterChars
	movem.l	d2-d3/a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0-d3
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOFilterChars(a6)
	movem.l	(sp)+,d2-d3/a6
	rts
;---------------------------------------------------------------------------
SPOFF	SET 1*4
_StringToLower
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	SPOFF+12(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOStringToLower(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_StringToUpper
	move.l	a6,-(sp)
	movem.l	SPOFF+4(sp),a0-a1
	move.l	SPOFF+12(sp),d0
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOStringToUpper(a6)
	move.l	(sp)+,a6
	rts
;---------------------------------------------------------------------------
_ReAllocVec
	move.l	a6,-(sp)
	move.l	SPOFF+4(sp),a0
	movem.l	SPOFF+8(sp),d0/d1
	move.l	_AssemblyBase(a4),a6
	jsr	_LVOReAllocVec(a6)
	move.l	(sp)+,a6
	rts

;---------------------------------------------------------------------------
