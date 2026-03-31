***************************************************************************************
*
* ReEdit.asm - ReEdit.o - Object files
*
* Questo è uno speciale supporto per il programma ReEdit.c, contiene tutte le funzioni
* per la scrittuira di un file .rei.
*
*
***************************************************************************************
	opt NOCHKBIT

	include DevPac:system
	
	include include_i:assembly/asmprivate.i
	include include_i:assembly/assembly_lib.i

 STRUCTURE SPECIAL,0
	APTR	sx_MainREI		* First REI address 	
	BPTR	sx_Handle		* pointer to file handle of .rei file...

	APTR	sx_Buffer		* Che devo scrivere?
	LONG	sx_Byte			* Numero di byte scritti sino ad ora...
	LONG	sx_StrOffset		* Ultima riga offset...
	 	
 	STRUCT	sx_Rel32Offset,256*4	* Hunk_reloc32
 	STRUCT 	sx_REI,rei_SIZEOF	* Copia della REI da scrivere, questa viene...
 	LABEL	sx_SIZEOF
;--------------------------------------------------------------------------------------
AWRITE	MACRO	;&buffer, len
	move.l	sx_Handle(a4),d1		* handle...
	move.l	\1,d2				* Buffer...
	move.l	\2,d3				* Numero di byte da scrivere...
	jsr	_LVOWrite(a6)			* vai...
	ENDM
;--------------------------------------------------------------------------------------
SEEKB	MACRO	;Pos
	move.l	sx_Handle(a4),d1
	move.l	\1,d2
	moveq	#OFFSET_BEGINNING,d3
	jsr	_LVOSeek(a6)
	ENDM
;--------------------------------------------------------------------------------------
SEEKC	MACRO	;Pos
	move.l	sx_Handle(a4),d1
	move.l	\1,d2
	moveq	#OFFSET_CURRENT,d3
	jsr	_LVOSeek(a6)
	ENDM
;--------------------------------------------------------------------------------------
SEEKEND	MACRO	
	move.l	sx_Handle(a4),d1		* Torna alla fine
	moveq	#0,d2
	moveq	#OFFSET_END,d3
	jsr	_LVOSeek(a6)
	ENDM
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
	XDEF	_WriteREIFile
	
	XREF	_AssemblyBase
;--------------------------------------------------------------------------------------
; success = WriteREIFile(filename, rei)
;   D0                      A0     A1
;
; BOOL WriteREIFile(STRPTR filename, struct REI *rei);
;--------------------------------------------------------------------------------------
SPOFF	SET (6+5)*4
_WriteREIFile	
	movem.l	d2-d7/a2-a6,-(sp)
	movem.l	SPOFF+4(sp),a2-a3		* filename/rei
	move.l	_AssemblyBase(a4),a5		* A5 = AssemblyBase
;--------------------------------------------------------------------------------------
	move.l	#sx_SIZEOF+4,d2			* Alloco, la memoria per una mia
	move.l	d2,d0				* struttura privata, la SPECIAL, dove
	move.l	#MEMF_CLEAR|MEMF_PUBLIC,d1	* mantengo i dati relativi alla
	move.l	ab_ExecBase(a5),a6		* scrittura del file .rei
	jsr	_LVOAllocMem(a6)		* Alloca, simulando un AllocVec().
	tst.l	d0
	bne.s	ALLOK
SExit	movem.l	(sp)+,d2-d7/a2-a6		* Errore esce... NULL
	rts
;--------------------------------------------------------------------------------------
ALLOK	move.l	d0,a4				* A4 = (struct SPECIAL *)
	move.l	d2,(a4)+			* AllocVec()
;--------------------------------------------------------------------------------------
	move.l	a3,sx_MainREI(a4)		* Salvo la REI passata negli INPUTS...
	move.l	#rei_SIZEOF,sx_StrOffset(a4)	* Ultima riga offset dove calcolare...
	lea	sx_Rel32Offset(a4),a3		* A3 = hunk_reloc32 pointer variable
	move.l	sx_MainREI(a4),a0		* sorgente rei
	lea	sx_REI(a4),a1			* destinazione
	move.l	a1,sx_Buffer(a4)		* scriviamo questo per primo...
	move.l	#(rei_SIZEOF/2)-1,d0
CopREI	move.w	(a0)+,(a1)+
	dbf	d0,CopREI
;--------------------------------------------------------------------------------------
	move.l	a2,d1				* Apre il file su disco
	move.l	#MODE_NEWFILE,d2
	move.l	ab_DosBase(a5),a6
	jsr	_LVOOpen(a6)
	tst.l	d0				* Check Handle...
	beq.s	SExit				* Go error...
	move.l	d0,sx_Handle(a4)		* Save Handle pointer
;--------------------------------------------------------------------------------------
	AWRITE	#Hunk_Header,#32		* Scrivo l'Hunk_Header, handle...
;--------------------------------------------------------------------------------------
	moveq	#0,d0				* Pulisco i campi della REI che non mi
	move.l	sx_Buffer(a4),a0		* servono..
	move.l	d0,rei_Screen(a0)
	move.l	d0,rei_Window(a0)
	move.l	d0,rei_Gadget(a0)
	move.l	d0,rei_Menu(a0)
	move.l	d0,rei_Font(a0)
	move.l	d0,rei_OldHook(a0)
	move.l	d0,rei_VI(a0)
	
	AWRITE	a0,#rei_SIZEOF			* scrivo tutta la struttura REI
	move.l	sx_MainREI(a4),sx_Buffer(a4)	* Sposto il pointer...
	add.l	d0,sx_Buffer(a4)		* mi trovo... aggiorno
	add.l	d0,sx_Byte(a4)			* aggiorno numero di byte scritti...
;--------------------------------------------------------------------------------------
	move.l	([sx_MainREI.w,a4],rei_ScreenTAG.w),d0	* ScreenTAG??
	beq.s	NoScreenTAG
	move.l	d0,a0
	bsr	WriteTAG	
	moveq	#rei_ScreenTAG,d4		* Offset... dove scrivo?
	move.l	sx_StrOffset(a4),d5		* Cosa scrivo
	bsr	WriteBPos
NoScreenTAG	
;--------------------------------------------------------------------------------------
	move.l	([sx_MainREI.w,a4],rei_PubScreenName.w),d0	* PubScreenName??
	beq.s	NoPubScreenName
	move.l	d0,a0
	bsr	WriteString	
	moveq	#rei_PubScreenName,d4		* Offset... dove scrivo?
	move.l	sx_StrOffset(a4),d5		* Cosa scrivo
	bsr	WriteBPos
NoPubScreenName
;--------------------------------------------------------------------------------------
	move.l	sx_MainREI(a4),a0			* NewWindow Title?
	lea	rei_NewWindow+nw_Title(a0),a0
	move.l	(a0),d0	
	beq.s	NoTitleWindow
	move.l	d0,a0
	bsr	WriteString	
	moveq	#rei_NewWindow+nw_Title,d4	* Offset... dove scrivo?
	move.l	sx_StrOffset(a4),d5		* Cosa scrivo
	bsr	WriteBPos
;--------------------------------------------------------------------------------------
NoTitleWindow
;--------------------------------------------------------------------------------------
	move.l	([sx_MainREI.w,a4],rei_NewWindowTAG.w),d0	* NewWindowTAG??
	beq.s	NoNewWindowTAG
	move.l	d0,a0
	bsr	WriteTAG	
	moveq	#rei_NewWindowTAG,d4		* Offset... dove scrivo?
	move.l	sx_StrOffset(a4),d5		* Cosa scrivo
	bsr	WriteBPos
NoNewWindowTAG
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------
	move.l	sx_Byte(a4),d0			* Numero di byte totali scritti
	andi.l	#3,d0				* Sono Alignati a LONG?
	beq.s	SiAlign				* Si, Ok...
	move.l	sx_Byte(a4),d1			* Riprendi i byte scritti...
	move.l	d1,d0
	addq.l	#4,d0				* Aggiungi 4 per alignare a LONG
	andi.l	#~3,d0				* Pulisci e primi due bit
	move.l	d0,sx_Byte(a4)			* Salva i nuovi bytes...
	sub.l	d1,d0
	move.l	d0,d3
	AWRITE	#Align,d3
SiAlign	move.l	sx_Byte(a4),d0			* Se questi sono i byte scritti...
	asr.l	#2,d0				* Queste sono le LONG scritte...
	move.l	d0,Mio				* Save for Seek()
	move.l	d0,Mao
;--------------------------------------------------------------------------------------
	AWRITE	#Hunk_Reloc32,#12		* Scrivo l'Hunk_Reloc32
;--------------------------------------------------------------------------------------
	lea	sx_Rel32Offset(a4),a0		* Buffer...
	move.l	NRel32,d3			* Numero di LONG da scrivere...
	asl.l	#2,d3
	AWRITE	a0,d3
;--------------------------------------------------------------------------------------
	AWRITE	#Hunk_End,#8			* Scrivo l'Hunk_End
;--------------------------------------------------------------------------------------
	SEEKB	0				* Rivai all'inizio
	AWRITE	#Hunk_Header,#32
;--------------------------------------------------------------------------------------
CloseFile
	move.l	sx_Handle(a4),d1
	move.l	ab_DosBase(a5),a6
	jsr	_LVOClose(a6)
;--------------------------------------------------------------------------------------
FreeSpecial
	move.l	a4,a1				* Libero la memoria occupata dalla
	move.l	-(a1),d0			* struttura SPECIAL, simulando questa
	move.l	ab_ExecBase(a5),a6		* volta un FreeVec()
	jsr	_LVOFreeMem(a6)
;--------------------------------------------------------------------------------------
ExitOk	moveq	#1,d0				* Qui per Ok...
Exit	movem.l	(sp)+,d2-d7/a2-a6		* Qui per eventuale errore...
	rts
;--------------------------------------------------------------------------------------
***************************************************************************************
;--------------------------------------------------------------------------------------
***************************************************************************************
* SPECIAL SUB ROUTINE
***************************************************************************************
WriteTAG
	move.l	a0,a2
	bra.s	SOO
ContaT	addq.w	#4,a2
SOO	tst.l	(a2)+
	bne.s	ContaT
	suba.l	a0,a2
	AWRITE	a0,a2
	add.l	d0,sx_Byte(a4)		* aggiorna il numero di byte scritti
	addq.l	#1,NRel32		* incrementa il numero delle relcs da fare...
	move.l	d0,d6			* sx_StrOffset aggiornamento
	rts	
***************************************************************************************
WriteString
	move.l	a0,a2
ContaS	tst.b	(a2)+
	bne.s	ContaS
	suba.l	a0,a2
	move.l	a2,d0			* Rendiamo paro il numero di byte da scrivere
	addq.l	#1,d0
	bclr	#0,d0
	AWRITE	a0,d0
	add.l	d0,sx_Byte(a4)		* aggiorna il numero di byte scritti
	addq.l	#1,NRel32		* incrementa il numero delle relcs da fare...
	move.l	d0,d6			* sx_StrOffset aggiornamento
	rts
***************************************************************************************
* WriteBPos (Pos, LONG, AggStrOffset)
*	     D4   D5	     D6
* Questa scrive la LONG d5, partendo dall'offset pos. Pos è relativo alla struttura
* data (rei) NON all'inizio del file vero e proprio.
* Per Pos = NULL, ci troviamo a 32byte dall'inizio del file, cioè dopo l'hunk_header.
* Questo ritorna alla fine del file, quando ha finito.
***************************************************************************************
WriteBPos
	move.l	d4,(a3)+			* Offset nella lista degli offset
	SEEKB	#32
	SEEKC	d4
	move.l	d5,-(sp)			* my temp buffer
	AWRITE	sp,#4
	addq.w	#4,sp
	SEEKEND
	add.l	d6,sx_StrOffset(a4)
	rts
;--------------------------------------------------------------------------------------
Hunk_Header
	dc.l $000003F3,$00000000,$00000001,$00000000,$00000000
Mio	dc.l 0					* Numero dello LONG scritte
	dc.l $000003EA
Mao	dc.l 0					* Numero dello LONG scritte
;--------------------------------------------------------------------------------------
Hunk_Reloc32
	dc.l $000003EC
NRel32	dc.l 0					* Numero rilocazioni da fare...
	dc.l 0					* HUNK Sempre 0, numero dell'hunk...
;--------------------------------------------------------------------------------------
Hunk_End
	dc.l 0					* Fine Hunk_Reloc32
	dc.l $000003F2				* Hunk_End...
;--------------------------------------------------------------------------------------
Align	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	* 18 LONG a NULL.