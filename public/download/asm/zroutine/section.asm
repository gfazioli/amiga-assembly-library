	SECTION STATICIMAGE,DATA_C
TableImage	
	dc.l 0,TextImage,PictImage,SoundImage,DeviceImage,DrawerImage
	dc.l SelectedImage,DeselectedImage,QuestionImage,EscImage
	dc.l AltImage,InputImage
;--------------------------------------------------------------------------------------
TextImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l TxtImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
TxtImage
	dc.l $ffff8001,$9ff58001,$9ff58001,$b72f802f
	dc.l $802fffff,$00007ffe,$400a7ffe,$400a7ffe
	dc.l $48c07fc1,$7fc30007,$00000000,$3fd00000
	dc.l $2fc40000,$12200024,$00200000
;--------------------------------------------------------------------------------------
PictImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l PicImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
PicImage
	dc.l $00017ffd,$7ffd7ffd,$5ffd1fad,$07550005
	dc.l $0001ffff,$fffffffe,$fffefffe,$cffef7ae
	dc.l $fa16ffae,$fffe8000,$00000000,$00001000
	dc.l $18107c28,$7fd47ffc,$00000000
;--------------------------------------------------------------------------------------
SoundImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l SndImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
SndImage
	dc.l $00007fff,$7fff7fff,$7fff7fff,$7fff7fff
	dc.l $7fff7fff,$fffe8000,$80008000,$80008000
	dc.l $80008000,$80000000,$00017fce,$73d675ce
	dc.l $7396651e,$47be6ffe,$7ffe8000
;--------------------------------------------------------------------------------------
DeviceImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l DevImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
DevImage
	dc.l $00007c7f,$7b3f779f,$6fcf77e7,$7bcf7d9f
	dc.l $7f3f7fff,$fffe82f0,$84e08940,$93808f00
	dc.l $8e009e00,$b8000000,$00017dfe,$7afe775e
	dc.l $6fae77d6,$7bae7d5e,$7ebe8000	
;--------------------------------------------------------------------------------------
DrawerImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l DrwImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
DrwImage
	dc.l $ffff803f,$bfdfbfe3,$bffdbffd,$bffdbffd
	dc.l $c001ffff,$003f7f9f,$4000401c,$40004000
	dc.l $40004000,$00000000,$00000040,$3fe03fe2
	dc.l $3ffe3ffe,$3ffe3ffe,$7ffe0000
;--------------------------------------------------------------------------------------
SelectedImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l SelImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
SelImage
	dc.l $00007ff7,$7fef7fdd,$7bbb5d77,$6eef77df
	dc.l $7bbf7fff,$fffe8000,$80008000,$80008000
	dc.l $80008000,$80000000,$00017ff0,$7fe07fc0
	dc.l $43824106,$600e701e,$783e8000
;--------------------------------------------------------------------------------------
DeselectedImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l DesImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
DesImage
	dc.l $00007fff,$7fff7fff,$7fff7fff,$7fff7fff
	dc.l $7fff7fff,$fffe8000,$80008000,$80008000
	dc.l $80008000,$80000000,$00017ffe,$7ffe7ffe
	dc.l $7ffe7ffe,$7ffe7ffe,$7ffe8000
;--------------------------------------------------------------------------------------
QuestionImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l QueImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
QueImage
	dc.l $00007bdf,$776f7f6f,$7edf7dbf,$7fff7dbf
	dc.l $7fff7fff,$fffe8400,$88808080,$81008200
	dc.l $80008200,$80000000,$0001781e,$710e7f0e
	dc.l $7e1e7c3e,$7ffe7c3e,$7ffe8000
;--------------------------------------------------------------------------------------
EscImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l EImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
EImage	dc.l $00007dbf,$7dbf7dbf,$7dbf7dbf,$7fff7dbf
	dc.l $7fff7fff,$fffe8200,$82008200,$82008200
	dc.l $80008200,$80000000,$00017c3e,$7c3e7c3e
	dc.l $7c3e7c3e,$7ffe7c3e,$7ffe8000
;--------------------------------------------------------------------------------------
AltImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l AImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
AImage	dc.l $00007fff,$7fff7fff,$7fff7fff,$7fff7fff
	dc.l $7fff7fff,$fffe8000,$80008000,$80008000
	dc.l $80008000,$80000000,$00016ec0,$6ef656f6
	dc.l $56f602f6,$3af63a16,$7ffe8000
;--------------------------------------------------------------------------------------
InputImage
	dc.w 0,0,16,10 				* x,y,w,h
	dc.w 3					* Depth
	dc.l InpImage				* MyImage
	dc.b %111,0				* PlanePick Plane ONOFF
	dc.l 0
InpImage
	dc.l $00007ffd,$7ffd7ffd,$7ffd7ffd,$7ffd7ffd
	dc.l $00017fff,$fffe8000,$be02be02,$be02be02
	dc.l $be02be02,$bffe0000,$00010002,$3ffc3ffc
	dc.l $3ffc3ffc,$3ffc3ffc,$40008000
;--------------------------------------------------------------------------------------