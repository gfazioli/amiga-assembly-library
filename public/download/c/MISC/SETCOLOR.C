/***************************************************************************
**
**************************************************************************** 
*/
#include <exec/exec.h>
#include <graphics/gfx.h>
#include <graphics/view.h>
#include <dos/dosextens.h>
#include <dos/doshunks.h>
#include <intuition/classusr.h>
#include <intuition/screens.h>
#include <intuition/icclass.h>
#include <libraries/locale.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/datatypes_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/asl_protos.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>
#include <clib/locale_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/wb_protos.h>


/********** Global VAR ***************************************************************/
struct Library *DosBase,*IntuitionBase,*GfxBase,*AslBase, *IconBase;
struct Library *GadToolsBase, *LocaleBase, *DataTypesBase, *WorkbenchBase;

/********** My C prototypes **********************************************************/

/**************************************************************************************
** Main 
***************************************************************************************
*/
VOID main()
{

struct Screen *pubscreen;
struct ViewPort *vp;

	if ( !(GfxBase = OpenLibrary("graphics.library",0)) )	
		return(NULL);
		
	if ( !(IntuitionBase = OpenLibrary("intuition.library",0)) )	
	{
		CloseLibrary(GfxBase);
		return(NULL);
	}
	
	pubscreen = LockPubScreen(NULL);
	vp = &pubscreen->ViewPort;	

	SetRGB32 (vp, 4, 123<<24, 123<<24, 123<<24 );
	SetRGB32 (vp, 5, 175<<24, 175<<24, 175<<24 );
	SetRGB32 (vp, 6, 170<<24, 144<<24, 124<<24 );				
	SetRGB32 (vp, 7, 255<<24, 169<<24, 151<<24 );
	SetRGB32 (vp, 8, 0, 0, 255<<24 );
	SetRGB32 (vp, 9, 50<<24, 50<<24, 50<<24 );
	SetRGB32 (vp, 10, 96<<24, 128<<24, 96<<24 );
	SetRGB32 (vp, 11, 226<<24, 209<<24, 119<<24 );
	SetRGB32 (vp, 12, 255<<24, 212<<24, 203<<24 );
	SetRGB32 (vp, 13, 122<<24, 96<<24,  72<<24 );
	SetRGB32 (vp, 14, 210<<24, 210<<24, 210<<24 );
	SetRGB32 (vp, 15, 229<<24, 93<<24, 93<<24 );

	UnlockPubScreen(NULL,pubscreen);

	CloseLibrary(IntuitionBase);
	CloseLibrary(GfxBase);
	return(NULL);
}


/*************************************************************************************/
VOID wbmain(wbmsg)
{
	main();
	exit(0);
}
