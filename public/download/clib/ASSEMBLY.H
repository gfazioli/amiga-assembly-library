#ifndef  CLIB_ASSEMBLY_PROTOS_H
#define  CLIB_ASSEMBLY_PROTOS_H

/*
**	$VER: assembly_protos.h 41.6 (29.Sep.1995)
**	Includes Release 41.1
**
**	C prototypes. For use with 32 bit integers only.
**
**      (No) Copyrights, Public Domain Software
**              Nothing Rights Reserved
*/

#ifndef  ASSEMBLY_ASSEMBLY_H
#include <assembly/assembly.h>
#endif

/*--- Assembly.lib C support ---*/

void HookEntry(void);

/*--- Dos support commands ---*/

struct FileInfoBlock *FileInfo(STRPTR filename);
APTR Load(STRPTR filename, APTR buffer, ULONG typeofmem);
ULONG Save(STRPTR filename, APTR buffer, ULONG len);
void CheckSum(APTR buffer, ULONG type);
ULONG LineInput(APTR, ULONG, BPTR);
struct InfoData *UnitInfo(STRPTR volumename);
LONG CheckFile(STRPTR filename, STRPTR errorstring);

/*--- Exec support commands ---*/
void FreeNodeName(struct List *, struct Node *);
void FreeListName(struct List *);
void FreeNode(struct List *, struct Node *);
void RevertMem(APTR, APTR, ULONG);
struct List *AllocNewList(void);
struct Node *AllocNode(struct List *, STRPTR, ULONG, LONG);
void FreeList(struct List *);

/*--- Graphics primitive support command ---*/

struct RastPort *AllocRastPort(void);
struct RastPort *CloneRastPort(struct RastPort *rp);
PLANEPTR NewAllocRaster(ULONG width, ULONG height);
ULONG AddBitPlanes(struct BitMap *bm, ULONG);
ULONG RemoveBitPlanes(struct BitMap *bm, ULONG);
APTR TextFmtRastPortArgs(struct RastPort *rp, STRPTR, LONG, LONG, LONG, APTR args);
APTR TextFmtRastPort(struct RastPort *rp, STRPTR, LONG, LONG, LONG, ... );
void DrawBox(struct RastPort *rp, LONG, LONG, LONG, LONG);
void DrawFrameStateA(struct REI *, ULONG, ULONG, ULONG, ULONG, ULONG, struct TagItem *);
void DrawFrameState(struct REI *, ULONG, ULONG, ULONG, ULONG, ULONG, Tag, ...);
void EraseInternalRect(struct Window *win);

/*--- Intuition primitive support command ---*/

struct Interface *OpenInterface(STRPTR);
void CloseInterface(struct Interface *i);
struct REI *OpenREIA(struct REI *, STRPTR, struct TagItem * );
struct REI *OpenREI(struct REI *, STRPTR, Tag,...);
struct REI *CloseREI(struct REI *, STRPTR );
struct REI *ActiveREI(void);
struct REI *FindREI(STRPTR);
void RefreshREI(struct REI *);
struct REIMessage *WaitREIMsg(struct REI *, LONG);
struct REI *LockREI(struct REI *, STRPTR);
BOOL UnlockREI(struct REI *, STRPTR);
APTR AS_MenuAddress(struct REI *, ULONG, ULONG, ULONG);
BOOL SetREIAttrsA(struct REI *, STRPTR, struct TagItem *);
void SetREIAttrs(struct REI *, STRPTR, Tag,...);
ULONG *GetREIAttrsA(struct REI *, STRPTR, struct TagItem *);
ULONG *GetREIAttrs(struct REI *, STRPTR, Tag,...);
struct AsmGadget *FindAsmGadget(struct REI *, STRPTR);
void TextFmtSizeArgs(struct RastPort *, struct IBox *, STRPTR, APTR);
void TextFmtSize(struct RastPort *, struct IBox *, STRPTR, ...);
/**************************************/
/**** New generation of Requestert ****/
/**************************************/
struct AsmRequest *AllocAsmRequestA (struct TagItem *);
struct AsmRequest *AllocAsmRequest (Tag, ...);
void FreeAsmRequest (struct AsmRequest *);
LONG AsmRequestArgs (struct AsmRequest *, STRPTR, STRPTR, APTR);
LONG AsmRequest (struct AsmRequest *, STRPTR, STRPTR, ...);
void ChangeAsmReqAttrsA(struct AsmRequest *, struct TagItem *);
void ChangeAsmReqAttrs(struct AsmRequest *, Tag, ...);
BOOL SetAsmGadgetAttrsA(struct REI *,struct AsmGadget *,STRPTR, struct TagItem *);
BOOL SetAsmGadgetAttrs(struct REI *,struct AsmGadget *,STRPTR, Tag, ...);
ULONG GetAsmGadgetAttr(struct REI *,struct AsmGadget *,STRPTR, ULONG);
ULONG InterfaceInfo(struct REI *);

/*--- Math is here!! ---*/

LONG Bin2Val(STRPTR, LONG);
void ConvBin(APTR, LONG, ULONG);
void ConvDecZ(APTR, LONG, ULONG);
void ConvHex (APTR, LONG, LONG, BOOL);
LONG Dec2Val(STRPTR);
LONG Hex2Val(STRPTR);
void ConvDec(APTR, LONG);

/*--- Libraries and generic fuctions ---*/

ULONG ChangeChar(STRPTR, ULONG, ULONG, ULONG);
void FilterChars(STRPTR, ULONG, ULONG, ULONG, ULONG);
void StringToLower(struct Locale *, STRPTR, LONG);
void StringToUpper(struct Locale *, STRPTR, LONG);
ULONG *ReAllocVec(ULONG *, ULONG, ULONG);

#endif	 /* CLIB_ASSEMBLY_PROTOS_H */
