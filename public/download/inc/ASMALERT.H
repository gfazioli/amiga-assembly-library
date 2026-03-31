#ifndef ASSEMBLY_ASMALERT_H
#define ASSEMBLY_ASMALERT_H
/*
**
**    $VER: asmalert.h 37.00 (11.10.94)
**    Includes Release 41.1
**
**    Alert numbers, as displyed by system crashes.
**
**    (No) Copyrights, Public Domain Software
**            Nothing Rights Reserved
**
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef EXEC_ALERTS_H
#include <exec/alerts.h>
#endif

/** For the format of the alert, see EXEC/ALERT.H */

/* ======================================================================= */
/* ==== ALERTS Define ==================================================== */
/* ======================================================================= */
#define AA AN_Unknown        /* TA Identificativo assembly.library */
#define AA_DeadEnd (AA && AT_DeadEnd)   /* Irrecuperabile. */
#define AA_Recovery (AA && AT_Recovery) /* Recuperablile. */

/* -- Libraries Alert ---------------------------------------------------- */
#define AA_lib (AA_Recovery | 0x00000010)
#define AA_LIB (AA_DeadEnd | 0x00000010)

#define AA_InvalidLibs (AA_lib | 0x00000001) /* Errata apertura librerie di
                                                sistema. */
#define AA_Invalid (AA_lib | 0x00000002 /* USO UTENTE!. LA libreria assembly
                                           è stata aperta con una versione 
                                           errata. */

/* -- System Alert ------------------------------------------------------- */
#define AA_sys (AA_Recovery | 0x00000020)
#define AA_SYS (AA_DeadEnd | 0x00000020)

#endif /* ASSEMBLY_ASMALERT_H */
