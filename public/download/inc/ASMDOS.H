#ifndef ASSEMBLY_ASMDOS_H
#define ASSEMBLY_ASMDOS_H
/*
**    $VER: asmdos.h 41 (10.Oct.94)
**    Includes Release 41.1
**
**    This includes is for future use, not implement now
**
**    (No) Copyrights, Public Domain Software
**            Nothing Rights Reserved
*/

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef LIBRARIES_DOS_H
#include <dos/dos.h>
#endif

#ifndef LIBRARIES_DOSEXTENS_H
#include <dos/dosextens.h>
#endif

#ifndef LIBRARIES_FILEHANDLER_H
#include <dos/filehandler.h>
#endif


/* -- Type of checksum in CheckSum() comand type ------------------------- */

#define TCS_BOOTBLOCK 0
#define TCS_DATABLOCK 1
#define TCS_FILEBLOCK TCS_DATABLOCK

#endif /* ASSEMBLY_ASMDOS_H */
