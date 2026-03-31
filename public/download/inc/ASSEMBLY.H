#ifndef ASSEMBLY_ASSEMBLYBASE_H
#define ASSEMBLY_ASSEMBLYBASE_H
/*
**    $VER: assemblybase.h 41.10 (19-Jan-1995)
**    Includes Release 41.21
**
**    AssemblyBase Structure and costants
**
**    (No) Copyrights, Public Domain Software
**            Nothing Rights Reserved
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef ASSEMBLY_ASSEMBLY_H
#include <assembly/assembly.h>
#endif

/* ======================================================================= */
/* === AssemblyBase ====================================================== */
/* ======================================================================= */

struct AssemblyBase {
	struct Library LibNode;					/* Standard library node */
	struct GfxBase *ab_GfxBase;				/* Puntatore alla GfxBase */
	struct IntuitionBase *ab_IntuiBase;		/* Puntatore alla IntuiBase. */
	struct DosBase *ab_DosBase;       		/* Puntatore alla DosBase. */
	WORD  ab_private1;    	  				/* Uso Privato. */
	LONG  ab_private2;     					/* Uso Privato. */
	struct Library *ab_ExecBase;      		/* Puntatore alla ExecBase. */
   
/** KickStart 3.0 compatibile versione -- added news features **************/
	struct Library *ab_AslBase;       	/* Puntatore alla ASL.Library */
	struct Library *ab_GadToolsBase;  	/* Puntatore alla GadTools.Library */
	struct Library *ab_CxBase;        	/* Puntatore alla Commodities */
	struct Library *ab_IconBase;      	/* Puntatore alla Icon.Library */
	struct Library *ab_WorkbenchBase;	/* Puntatore alla Workbench.Library */
	struct Library *ab_DataTypesBase;	/* Puntatore alla DataTypes.Library */

/** Special linking library ************************************************/
	struct Library *ab_UtilityBase;   	/* (Gfx) ^Utility.Library */
	struct Library *ab_LayersBase;    	/* (Gfx) ^Layers.Library */

/** (3.1) Special Added Library ********************************************/
	struct LocaleBase *ab_LocaleBase;   	/* Puntatore alla Locale.Library */
	struct Library *ab_LowLevelBase;  	/* Puntatore alla LowLevel.Library */
	struct Library *ab_RealTimeBase;  	/* Puntatore alla RealTime.Library */
	ULONG ab_reserved1;    	 	/* future extension */

/** Preferences ************************************************************/
	UWORD ab_TicksDelay;      		/* Simulate Mouse pressing... */
	UWORD ab_FgPenRequest; 
	UWORD ab_BgPenRequest;      
	UWORD ab_DrMdRequest;
	struct Image *ab_QuestionImage;
	struct Image *ab_WarningImage;
	struct Image *ab_DangerImage;
	struct Image *ab_IOImage;
	struct Locale *ab_Locale;		/* Default struct Locale* */

/** Task private user ******************************************************/
	APTR ab_AssemblyTask; 		/* private */
	APTR ab_LastTask;	 		/* private */
	LONG ab_private3;	 		/* future use */
	LONG ab_private4;	 		/* future use */
};

/**************************************************************************** 
**
** AssemblyBase #pubblic include for open this library
**
*****************************************************************************
*/
#define ASSEMBLY_MINIMUM  41 	/* Lowest version supported */
#define ASSEMBLY_VERSION  41 	/* this version */
#define ASSEMBLY_REVISION 21  	/* this revision */

/**************************************************************************** 
** 
** Define name of library -- set by appliprog ONLY
**
*****************************************************************************
*/

#define ASSEMBLYNAME "assembly.library"

#endif /* ASSEMBLY_ASSEMBLYBASE_H */

