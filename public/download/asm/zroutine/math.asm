***************************************************************************************
* file - Math - main Math support commands
*
* Ver.41.1 - Table of contents
*
* StringDecToValue()	- Rev.
* StringHexToValue()	- Rev.
* StringBinToValue()	- Rev.
* ValueToStringDec()	- Rev.
* ValueToStringHex()	- Rev.
* ValueToStringBin()	- Rev.
*
***************************************************************************************

***************************************************************************************
* (20-Feb-1995) --- value = StringDecToValue(buffer) (a0)
***************************************************************************************
_LVOStringDecToValue
	movem.l	d1-d7/a0-a2,-(sp)
	movem.w	DecClearRegs(pc),d0-d7
	moveq	#"0",d5		* fasting Code
D2V_Skp	cmp.b	(a0),d5			* Check Jolly Char
	ble.s	D2V_Con
	cmpi.b	#"#",(a0)+		* Jolly...
	beq.s	D2V_Skp
	cmpi.b	#"+",-1(a0)		* Pos
	beq.s	D2V_Skp
	cmpi.b	#"-",-1(a0)		* NOT... provoca qualcosa...
	bne.s	D2V_Skp
	moveq	#1,d4			* Set Mark Negative
	bra.s	D2V_Skp
D2V_Con	STRLEN	a0,d3
	subq.w	#1,d3			* for dbf operation...
	lea	D2V_TableDec(pc),a2
D2V_Lop	move.b	(a0,d3.w),d1
	sub.b	d5,d1
	beq.s	D2V_Nex
	subq.b	#1,d1
D2V_Squ	add.l	(a2),d2
	dbf	d1,D2V_Squ
	add.l	d2,d0
	moveq	#0,d2
	moveq	#0,d1
D2V_Nex	addq.w	#4,a2
	dbf	d3,D2V_Lop
	tst.l	d4
	beq.s	D2V_Ext
	neg.l	d0
D2V_Ext	movem.l	(sp)+,d1-d7/a0-a2
	rts
DecClearRegs
	ds.w 8

***************************************************************************************
* (20-Feb-1995) --- value = StringHexToValue(string) (a0)
***************************************************************************************
_LVOStringHexToValue
	movem.l	d1-d7/a0-a2,-(sp)
	movem.w	DecClearRegs(pc),d0-d7
	suba.l	a2,a2			* Marking Neg Number
	moveq	#5,d4			* Fast CODE
	moveq	#"a",d5			* Fast CODE
	moveq	#"0",d6			* Fast CODE
	moveq	#$57,d7			* Fast CODE
H2V_Skp	cmp.b	(a0),d6			* Check Jolly Char
	ble.s	H2V_Con
	cmpi.b	#"$",(a0)+		* Jolly...
	beq.s	H2V_Skp
	cmpi.b	#"+",-1(a0)		* Pos
	beq.s	H2V_Skp
	cmpi.b	#"-",-1(a0)		* NOT... provoca qualcosa...
	bne.s	H2V_Skp
	addq.w	#1,a2			* Set Mark Negative
	bra.s	H2V_Skp
H2V_Con	STRLEN	a0,d1
	subq.w	#1,d1
H2V_Lop	move.b	(a0,d1.w),d2
	bset	d4,d2			* bit 5 UP  sDn,sDn for Fast
	cmp.b	d5,d2			* "A"	sDn,sDn for Fast
	bge.s	H2V_Wrd
	sub.b	d6,d2			* "0"	sDn,sDn for fast
	bra.s	H2V_Put
H2V_Wrd	sub.b	d7,d2			* #$57 sDn,sDn for fast
H2V_Put	rol.l	d3,d2
	or.l	d2,d0
	addq.b	#4,d3			* Ok 4 cicli di clock only QUICK
	moveq	#0,d2
	dbf     d1,H2V_Lop
	move.w	a2,d1
	beq.s	H2V_Ext
	neg.l	d0
H2V_Ext	movem.l	(sp)+,d1-d7/a0-a2
	rts

***************************************************************************************
* (20-Feb-1995) --- value = StringBinToValue(string, optlen) (a0/d0)
***************************************************************************************
_LVOStringBinToValue
	movem.l	d1-d3/a0,-(sp)
	moveq	#0,d2			* Mark Negative
	moveq	#"0",d3			* Type Of Chars
B2V_Skp	cmp.b	(a0),d3			* Check Jolly Char
	ble.s	B2V_Con
	cmpi.b	#"%",(a0)+		* Jolly...
	beq.s	B2V_Skp
	cmpi.b	#"+",-1(a0)		* Pos
	beq.s	B2V_Skp
	cmpi.b	#"-",-1(a0)		* NOT... provoca qualcosa...
	bne.s	B2V_Skp
	moveq	#1,d2			* Set Mark Negative
	bra.s	B2V_Skp
B2V_Con	move.w	d0,d1			* Introdotta lunghezza forzata?
	bne.s	B2V_Chk			* Si... considera questa...
	STRLEN	a0,d1			* Tutta la stringa
B2V_Chk	moveq	#0,d0
	subq.w	#1,d1
	bmi.s	B2V_Ext
B2V_SBt	cmp.b	(a0)+,d3
	beq.s	B2V_Lp
	bset	d1,d0
B2V_Lp	dbf	d1,B2V_SBt
	tst.w	d2
	beq.s	B2V_Ext
	not.l	d0
B2V_Ext	movem.l	(sp)+,d1-d3/a0
	rts


***************************************************************************************
* (20-Feb-1995) --- ValueToStringDec(buffer, value, optlen) (A0/D0/D1)
***************************************************************************************
_LVOValueToStringDec
	movem.l	d2-d7,-(sp)
	tst.l	d1			* Decido lunghezza della stringa??
	bne.s	ConLen			* Usa l'altra routine di conversione.
	moveq	#10,d5			; 10
	moveq	#"0",d2			; fast Code "0" $30
	tst.l	d0			; Vediamo se è negativo
	bpl.s	CDD_PL		
	move.b	#"-",(a0)+		; Se Neg metti un meno nel buffer
	neg.l	d0			; E trasforma POS
CDD_PL	cmp.l	d5,d0			; vediamo se è <10
	bhi.s	CDD_BHI			; NO
	bne.s	CDD_BNE			; <>10?
	move.w	#"10",(a0)+		; Metti 10 ed esci
	move.b	#0,(a0)
	movem.l	(sp)+,d2-d7
	rts
CDD_BNE add.b	d2,d0			; Salva il numero
	move.b	d0,(a0)+		; visto che è <10
	move.b	#0,(a0)			; azzera ed esci
	movem.l	(sp)+,d2-d7		* 
	rts
;--------------------------------------------------------------------------------------		
CDD_BHI	lea	Tables+4(pc),a1
CDD_GT	cmp.l	(a1)+,d0
	bge.s	CDD_GT
	subq.l	#8,a1
	move.l	d0,d3
DCC_LX	move.l	(a1),d1
	bne.s	DCC_CT
	move.b	d1,(a0)+
	movem.l	(sp)+,d2-d7
	rts
;--------------------------------------------------------------------------------------	
DCC_CT	moveq	#-1,d4
DCC_LP	move.l	d3,d5
	addq.w	#1,d4
	sub.l	d1,d3
	bcc.s	DCC_LP
DC_LAS	add.b	d2,d4
	move.b	d4,(a0)+
	move.l	d5,d3
	subq.w	#4,a1
	bra.s	DCC_LX
;--------------------------------------------------------------------------------------	
***************************************************************************************
* (20-Feb-1995) --- ConLen (Vedi sopra) Stessi INPUTS di ValueToStringDec()
***************************************************************************************
ConLen	move.l	a2,-(sp)
	move.l	a0,a2			* Routine che converte con la lunghezza fissa
	moveq	#0,d5			* D5 for len Count
	moveq	#10,d6
	move.l	d1,d7			* numero di caratteri finali
	sub.b	d7,d6
	move.l	d6,d7
	subq.b	#2,d1
	move.l	d1,d6
	asl.l	#2,d7
ConvDec_NoZero
	lea	ConvDec_Table(pc),a0	* Table of TEN (10)
	lea	(a0,d7.w),a0
	move.l	a2,a1
	moveq	#0,d5
	tst.l	d0
	bpl.s	ConvDec_Plus
	moveq	#1,d5			* Len+1 because there is "-"
	move.b	#"-",(a1)+		* Set Sign Char
	neg.l	d0			* Lo rende positivo
ConvDec_Plus
	move.l	d6,d4			* Loop for ....
	moveq	#"0",d7			* For Fasting CODE
ConvDec_ReStart
	moveq	#0,d3			* Ending Number
	move.l	(a0)+,d2		* 10xxx.. in d2
	move.l	d2,d1			* and save it in d1
ConvDec_Ctrl
	cmp.l	d2,d0
	bmi.s	ConvDec_Save
	add.l	d1,d2
	addq.b	#1,d3
	bra.s	ConvDec_Ctrl
ConvDec_Save
	add.b	d7,d3
	move.b	d3,(a1)+
	addq.b	#1,d5			* Count for Len
	sub.l	d1,d2
	sub.l	d2,d0
	dbf	d4,ConvDec_ReStart
	add.b	d7,d0
	move.b	d0,(a1)+
	addq.b	#1,d5
	move.l	d5,4(sp)		* D1=Len
	move.l	(sp)+,a2
	movem.l	(sp)+,d2-d7
	rts
;--------------------------------------------------------------------------------------	
; Tavole di conversione decimale.
;--------------------------------------------------------------------------------------	
	dc.l 0
D2V_TableDec
	dc.l 1
Tables	dc.l 10
	dc.l 100
	dc.l 1000
	dc.l 10000
	dc.l 100000
	dc.l 1000000
	dc.l 10000000
	dc.l 100000000
	dc.l 1000000000
ConvDec_Table
	dc.l 1000000000
	dc.l 100000000
	dc.l 10000000
	dc.l 1000000
	dc.l 100000
	dc.l 10000
	dc.l 1000
	dc.l 100
	dc.l 10
	dc.l 1

***************************************************************************************
* (20-Feb-1995) --- ValueToStringHex(buffer, value, optlen, prefix) (a0,d0,d1,d2)
***************************************************************************************
_LVOValueToStringHex
	movem.l	d2-d7/a0,-(sp)
	tst.l	d1
	bne.s	ConvHex_Default
	moveq	#8,d1
ConvHex_Default
	moveq	#$f,d5
	moveq	#48,d6
	moveq	#58,d7
	cmpi.l	#8,d1
	bhi.s	ConvHex_Exit
	move.l	d1,d3
	rol.w	#2,d3
	ror.l	d3,d0
	subq.l	#1,d1
	tst.l	d2
	beq.s	ConvHex_Next
	move.b	#"$",(a0)+
ConvHex_Next
	rol.l	#4,d0
	move.l	d0,d3
	and.b	d5,d3
	add.b	d6,d3
	cmp.b	d7,d3
	bcs.s	ConvHex_Out
	addq.b	#7,d3
ConvHex_Out
	move.b	d3,(a0)+
	dbf	d1,ConvHex_Next
ConvHex_Exit
	movem.l	(sp)+,d2-d7/a0
	rts
	
***************************************************************************************
* (20-Feb-1995) --- ValueToStringBin(buffer, value, optlen) (a0,d0,d1)
***************************************************************************************
_LVOValueToStringBin
	movem.l	d0/a0,-(sp)
	tst.l	d1
	bne.s	ConvBin_NoDefault
	moveq	#32,d1
ConvBin_NoDefault
	andi.w	#$FF,d1
	subq.b	#1,d1
	moveq	#"0",d2
ConvBin_Loop
	btst	d1,(sp)			* Fast Code
	beq.s	ConvBin_Zero
	moveq	#"1",d2
ConvBin_Zero
	move.b	d2,(a0)+
	moveq	#"0",d2
	dbf	d1,ConvBin_Loop
ConvBin_Exit
	movem.l	(sp)+,d0/a0
	rts


	