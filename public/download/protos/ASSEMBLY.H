/*--- functions in V41.1 or higher (Release 1.0) ---*/

/* --- Dos support commands ---*/

#pragma libcall AssemblyBase FileInfoBlock 1e 801
/*#pragma libcall AssemblyBase  24 */
/*#pragma libcall AssemblyBase assemblyReserved 2a 0*/
#pragma libcall AssemblyBase Load 30 09803
#pragma libcall AssemblyBase Save 36 09803
#pragma libcall AssemblyBase CheckSum 3c 0802
#pragma libcall AssemblyBase LineInput 48  10803
#pragma libcall AssemblyBase UnitInfo 4e 801
/*#pragma libcall AssemblyBase assemblyReserved 54 0*/
#pragma libcall AssemblyBase CheckFile 5a 9802

/* --- Exec support commands ---*/
#pragma libcall AssemblyBase FreeNodeName 60 9802
#pragma libcall AssemblyBase FreeListName 66 801
#pragma libcall AssemblyBase FreeNode 6c 9802
#pragma libcall AssemblyBase RevertMem 72 09803
#pragma libcall AssemblyBase AllocNewList 78 0
#pragma libcall AssemblyBase AllocNode 7e 109804
#pragma libcall AssemblyBase FreeList 84 801

/* --- Graphics primitive support command ---*/

#pragma libcall AssemblyBase AllocRastPort 8a 0
#pragma libcall AssemblyBase CloneRastPort 90 801
#pragma libcall AssemblyBase NewAllocRaster 96 1002
#pragma libcall AssemblyBase AddBitPlanes 9c 0802
#pragma libcall AssemblyBase RemoveBitPlanes a2 0802
#pragma libcall AssemblyBase TextFmtRastPortArgs a8 A2108906
#pragma tagcall AssemblyBase TextFmtRastPort a8 A2108906
#pragma libcall AssemblyBase DrawBox ae 3210805
#pragma libcall AssemblyBase DrawFrameStateA b4 943210807
#pragma tagcall AssemblyBase DrawFrameState b4 943210807
#pragma libcall AssemblyBase EraseInternalRect ba 801
/*#pragma libcall AssemblyBase assemblyReserved c0 0*/

/* --- Intuition primitive support command ---*/

#pragma libcall AssemblyBase OpenInterface c6 801
#pragma libcall AssemblyBase CloseInterface cc 801
#pragma libcall AssemblyBase OpenREIA d2 A9803
#pragma tagcall AssemblyBase OpenREI d2 A9803
#pragma libcall AssemblyBase CloseREI d8 9802
#pragma libcall AssemblyBase ActiveREI de 0
#pragma libcall AssemblyBase FindREI e4 901
#pragma libcall AssemblyBase RefreshREI ea 801
#pragma libcall AssemblyBase WaitREIMsg f0 0801
#pragma libcall AssemblyBase LockREI f6 9802
#pragma libcall AssemblyBase UnlockREI fc 9802
/*#pragma libcall AssemblyBase assemblyReserved 102 0*/
/*#pragma libcall AssemblyBase assemblyReserved 108 0*/
/*#pragma libcall AssemblyBase assemblyReserved 10e 0*/
#pragma libcall AssemblyBase AS_MenuAddress 114 210804
#pragma libcall AssemblyBase SetREIAttrsA 11a A9803
#pragma tagcall AssemblyBase SetREIAttrs 11a A9803
#pragma libcall AssemblyBase GetREIAttrsA 120 A9803
#pragma tagcall AssemblyBase GetREIAttrs 120 A9803
/*#pragma libcall AssemblyBase assemblyReserved 126 0*/
#pragma libcall AssemblyBase FindAsmGadget 12c 9802
#pragma libcall AssemblyBase TextFmtSizeArgs 132 A8B904
#pragma tagcall AssemblyBase TextFmtSize 132 A8B904
#pragma libcall AssemblyBase AllocAsmRequestA 138 801
#pragma tagcall AssemblyBase AllocAsmRequest 138 801
#pragma libcall AssemblyBase FreeAsmRequest 13E 801
#pragma libcall AssemblyBase AsmRequestArgs 144 BA9804
#pragma tagcall AssemblyBase AsmRequest 144 BA9804
#pragma libcall AssemblyBase ChangeAsmReqAttrsA 14A 9802
#pragma tagcall AssemblyBase ChangeAsmReqAttrs 14A 9802
#pragma libcall AssemblyBase SetAsmGadgetAttrsA 150 BA9804
#pragma tagcall AssemblyBase SetAsmGadgetAttrs 150 BA9804
#pragma libcall AssemblyBase GetAsmGadgetAttr 156 0A9804
/*--- slot reserved ---*/
#pragma libcall AssemblyBase InterfaceInfo 168 801

/*--- Math is here!! ---*/

#pragma libcall AssemblyBase StringDecToValue 1a4 801
#pragma libcall AssemblyBase StringHexToValue 1aa 801
#pragma libcall AssemblyBase StringBinToValue 1b0 0802
#pragma libcall AssemblyBase ValueToStringDec 1b6 10803
#pragma libcall AssemblyBase ValueToStringHex 1bc 210804
#pragma libcall AssemblyBase ValueToStringBin 1c2 10803
/*#pragma libcall AssemblyBase assemblyReserved 1c8 0*/

/* --- Libraries and generic fuctions ---*/

#pragma libcall AssemblyBase ChangeChar 1ce 210804
#pragma libcall AssemblyBase FilterChars 1d4 3210805
#pragma libcall AssemblyBase StringToLower 1da 09803
#pragma libcall AssemblyBase StringToUpper 1e0 09803
#pragma libcall AssemblyBase ReAllocVec 1e6 10803
