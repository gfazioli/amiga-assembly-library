/* 
** ReEdit.h - Private include files for ReEdit
*/

/* Define ID's REI */
#define MAINREI_ID   0x0000
#define CUSTOMREI_ID 0x9999

/* Standar Flags for a NewWindow in a Custom REI structure */
#define STDFLAGS 	(WFLG_CLOSEGADGET|WFLG_SIZEGADGET|WFLG_DRAGBAR|WFLG_DEPTHGADGET)

/*
** Special structure MyAlloc for private storage of data
*/
struct MyAlloc {
	struct Interface *mya_Interface;		/* ReEdit Interface pointer */
	struct REI *mya_MREI;					/* (Main) ReEdit REI pointer */
	
	struct REI *mya_CREI;					/* (Custom) REI, added width AddCREI() */

};