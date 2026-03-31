***************************************************************************************
** Assembly Library Source file -- $Release.1.0a (C)1990,91,92,93,94,95
***************************************************************************************
; HISTORY
;--------+--------+-----------+-----------------------------------------------------
; Author | Rel    | Date      | Comment
;--------+--------+-----------+-----------------------------------------------------
; jon    | 41.2   | 30-Sep-95 | Add ReAllocVec() - Remove NewCopyMemQuick()
; jon    | 41.2   |  7-Oct-95 | test su DoubleClick()
; jon    | 41.21  | 18-Nov-95 | Add AGAT_HighLight in SetAsmGadgetAttrs()
; jon    | 41.21  | 18-Nov-95 | Check CREATEGADGET MACRO?? & SetAsmGadgetAttrs()
; jon    | 41.22  | 19-Nov-95 | Fix bugs in OpenInterface() on change dir "sys:i"
;--------+--------+-----------+-----------------------------------------------------

	opt NOCHKBIT
	
	OUTPUT LIBS:Assembly.Library

	include DevPac:system
	
	include include_I:assembly/asmprivate.i		; Only ##private use
	include INCLUDE_I:assembly/assemblybase.i

	SECTION assemblylib,CODE
Void
	moveq	#0,d0
	rts

InitDDescrip
	dc.w RTC_MATCHWORD
	dc.l InitDDescrip
	dc.l EndCode
	dc.b RTF_AUTOINIT  
	dc.b ASSEMBLY_VERSION
	dc.b NT_LIBRARY
	dc.b 0			; RT_PRI
	dc.l LibName		; PTR_LIBRARY NAME
	dc.l IdString		; PTR_Stringa Identificativa
	dc.l Init
LibName	ASSEMBLYNAME
***************************************************************************************
** Format: name $Rel.x.x (Last date change)
***************************************************************************************
IdString
	dc.b "Assembly 41.22 (19.11.95)",13,10,0
	even

gfxname	STRING "graphics.library"
intuiname
	STRING "intuition.library"
dosname	STRING "dos.library"
aslname	STRING "asl.library"
gadtoolsname
	STRING "gadtools.library"
commoname
	STRING "commodities.library"
iconname
	STRING "icon.library"
wbname	STRING "workbench.library"
dtname	STRING "datatypes.library"
localename
	STRING "locale.library"
lowname	STRING "lowlevel.library"
realname
	STRING "realtime.library"
ArrayName
	dc.l gfxname,intuiname,dosname,aslname,gadtoolsname
	dc.l commoname,iconname,wbname,dtname,localename,lowname,realname

Init
	dc.l ab_SIZEOF		; Library Base SIZE_OF (Obsolete size)
	dc.l FuncTable		; PTR_FUNC TABLE
	dc.l DataTable		; PTR_DATA TABLE
	dc.l InitRoutine	; PTR_INIT ROUTINE

FuncTable
	dc.l Open
	dc.l Close
	dc.l Expugne
	dc.l Void		; Default Exit Routine!! Look Hat!ø

	dc.l _LVOFileInfo		
	dc.l Void
	dc.l Void
	dc.l _LVOLoad		
	dc.l _LVOSave		
	dc.l _LVOCheckSum
	dc.l Void
	dc.l _LVOLineInput		
	dc.l _LVOUnitInfo		
	dc.l Void
	dc.l _LVOCheckFile
	dc.l _LVOFreeNodeName
	dc.l _LVOFreeListName
	dc.l _LVOFreeNode
	dc.l _LVORevertMem		
	dc.l _LVOAllocNewList
	dc.l _LVOAllocNode
	dc.l _LVOFreeList
	dc.l _LVOAllocRastPort
	dc.l _LVOCloneRastPort
	dc.l _LVONewAllocRaster
	dc.l _LVOAddBitPlanes	
	dc.l _LVORemoveBitPlanes	
	dc.l _LVOTextFmtRastPortArgs
	dc.l _LVODrawBox
	dc.l _LVODrawFrameStateA
	dc.l _LVOEraseInternalRect
	dc.l Void				; _LVOCloseImage removed
	dc.l _LVOOpenInterface
	dc.l _LVOCloseInterface
	dc.l _LVOOpenREIA
	dc.l _LVOCloseREI
	dc.l _LVOActiveREI
	dc.l _LVOFindREI
	dc.l _LVORefreshREI
	dc.l _LVOWaitREIMsg
	dc.l _LVOLockREI
	dc.l _LVOUnlockREI
	dc.l Void
	dc.l Void
	dc.l Void
	dc.l _LVOAS_MenuAddress
	dc.l _LVOSetREIAttrsA
	dc.l _LVOGetREIAttrsA
	dc.l Void
	dc.l _LVOFindAsmGadget
	dc.l Void				* _LVOAllocAsmGadgets
	dc.l Void				* _LVOFreeAsmGadgets
	dc.l _LVOTextFmtSizeArgs
	dc.l _LVOAllocAsmRequestA
	dc.l _LVOFreeAsmRequest
	dc.l _LVOAsmRequestArgs
	dc.l _LVOChangeAsmReqAttrsA
	dc.l _LVOSetAsmGadgetAttrsA
	dc.l _LVOGetAsmGadgetAttr
	dc.l Void
	dc.l Void
	dc.l _LVOInterfaceInfo
	dc.l Void
	dc.l Void
	dc.l Void
	dc.l Void
	dc.l Void
	dc.l Void		
	dc.l Void
	dc.l _LVOStringDecToValue
	dc.l _LVOStringHexToValue
	dc.l _LVOStringBinToValue
	dc.l _LVOValueToStringDec
	dc.l _LVOValueToStringHex
	dc.l _LVOValueToStringBin
	dc.l Void
	dc.l _LVOChangeChar		
	dc.l _LVOFilterChars	* Rem:CmpStrings() - use instead Locale/StrnCmp()
	dc.l _LVOStringToLower
	dc.l _LVOStringToUpper	* Rem:SetStringCase() - use instead Locale/ConvToUpper()	
	dc.l _LVOReAllocVec	* New (29-Sept-1995)
	dc.l Void		* Rem:SgnStrings()		
	dc.l Void		* Reserved SortA()		
	dc.l Void		
	dc.l Void		
	dc.l Void		
	dc.l _LVOFindAIFFChunk		* Tutta questa parte verrà sostituita più
	dc.l _LVONextIFFChunk		* avanti con funzioni di supporto alla
	dc.l _LVOTestAIFFChunk		* DataTypes.Library...
	dc.l _LVOUnPackerILBMBODY	
	dc.l _LVOUnPackerILBMCMAP	
	
	dc.l -1

DataTable
	INITBYTE LN_TYPE,NT_LIBRARY
	INITLONG LN_NAME,LibName
	INITBYTE LIB_FLAGS,LIBF_SUMUSED|LIBF_CHANGED
	INITWORD LIB_VERSION,ASSEMBLY_VERSION
	INITWORD LIB_REVISION,ASSEMBLY_REVISION
	INITLONG LIB_IDSTRING,IdString
	dc.l 0

InitRoutine
	movem.l	a2-a5,-(sp)
	move.l	d0,a5
	move.l	a0,ab_private2(a5)	* SegList
	move.l	a6,ab_ExecBase(a5)

	lea	ArrayName(pc),a2
	lea	ab_GfxBase(a5),a4

	REPT 3
	moveq	#0,d0
	move.l	(a2)+,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,(a4)+
	ENDR
	
	move.l	ab_GfxBase(a5),a4
	move.l	gb_UtilBase(a4),d0
	move.l	d0,ab_UtilityBase(a5)
	move.l	gb_LayersBase(a4),d0
	move.l	d0,ab_LayersBase(a5)
	
	lea	ab_AslBase(a5),a4

	REPT 6
	moveq	#0,d0
	move.l	(a2)+,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,(a4)+
	ENDR
	
	lea	ab_LocaleBase(a5),a4
	
	REPT 3
	moveq	#0,d0
	move.l	(a2)+,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,(a4)+
	ENDR
***************************************************************************************	
** (V41) -- Init Language Value in AssemblyBase... ;-) - FUTURE EXSTENSION
***************************************************************************************
** NOT IMPLEMENTMENT NOW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

*	move.l	ab_LowLevel(a5),a6
*	jsr	_LVOGetLanguageSelection(a6)
*	move.l	d0,ab_SystemLanguage(a5)	

	move.l	ab_LocaleBase(a5),a6		* Get System (struct Locale *)
	suba.l	a0,a0				* default
	jsr	_LVOOpenLocale(a6)
	move.l	d0,ab_Locale(a5)
	
***************************************************************************************
** Assembly Preferences **
** Questa parte gestisce le preferences di sistema, iniziamo con l'AsmRequest...
***************************************************************************************
	move.w	#5,ab_TicksDelay(a5)		* Default time for simulate Gadget...
	move.l	#$00010000,ab_FgPenRequest(a5)	* Default A and B Pens..
	move.w	#0,ab_DrMdRequest(a5)		* Default DrawMode Request

***************************************************************************************	
** #Private old =stid= code -- =STID= private user task system list...
** viene mantenuto per compatibilita' ed aspansioni future
***************************************************************************************
	move.l	ab_ExecBase(a5),a6	* Reset Execbase for sicurity system
	lea	ab_TledTask(a5),a4	* For Task List
	move.l	a4,ab_LastTask(a5)

	move.l	a5,d0
	movem.l	(sp)+,a2-a5
	rts	

Open	addq.w	#1,LIB_OPENCNT(a6)	* Count
	bclr	#3,ab_private1(a6)	* Flags
	move.l	a6,d0
	rts

Close	moveq	#0,d0
	subq.w	#1,LIB_OPENCNT(a6)	* Count
	bne.s	NoExpugne
	btst	#3,ab_private1(a6)	* Flags
	beq.s	NoExpugne
	bsr.s	Expugne
NoExpugne
	rts

Expugne	movem.l	d2/a5/a6,-(sp)
	tst.w	LIB_OPENCNT(a6)
	beq.s	lbC0000EA
	bset	#3,ab_private1(a6)	* Flags
	moveq	#0,d0
	bra	lbC00010C

lbC0000EA
	move.l	a6,a5
	move.l	ab_ExecBase(a5),a6

	move.l	a5,a1
	jsr	_LVORemove(a6)
	
	move.l	ab_LocaleBase(a5),a6	* Remove Locale Access!!
	move.l	ab_Locale(a5),a0
	jsr	_LVOCloseLocale(a6)

***************************************************************************************
** Close all library
***************************************************************************************
	move.l	ab_ExecBase(a5),a6
	
	lea	ab_GfxBase(a5),a4
	
	REPT 3
	move.l	(a4)+,a1
	jsr	_LVOCloseLibrary(a6)
	ENDR
	
	lea	ab_AslBase(a5),a4
	
	REPT 6
	move.l	(a4)+,a1
	jsr	_LVOCloseLibrary(a6)
	ENDR
	
	lea	ab_LocaleBase(a5),a4
	
	REPT 3
	move.l	(a4)+,a1
	jsr	_LVOCloseLibrary(a6)
	ENDR
	
	move.l	ab_private2(a5),d2	* SegList

	move.l	a5,a1
	moveq	#0,d0
	move.w	LIB_NEGSIZE(a5),d0
	sub.l	d0,a1
	add.w	LIB_POSSIZE(a5),d0
	jsr	_LVOFreeMem(a6)
	move.l	d2,d0
lbC00010C
	movem.l	(sp)+,d2/a5/a6
	rts

***************************************************************************************
** All include asm routine...
***************************************************************************************
 	incdir	ASM:ZRoutine/

	include Dos
	include Exec
	include Graphics
	include	Intui_GadTools
	include REI
	include Libraries
	include Math
	include section

***************************************************************************************
** 2 #Reserved[2] =JON=
***************************************************************************************
	SECTION	ClearRegs_HOLE,BSS
ClearRegs
	ds.w 8

	SECTION	BUZZ,DATA

EndCode	dc.w 0
	END

