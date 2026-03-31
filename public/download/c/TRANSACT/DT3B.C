#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <intuition/intuition.h>
#include <intuition/classusr.h>
#include <intuition/icclass.h>
#include <intuition/gadgetclass.h>
#include <utility/tagitem.h>

#include <stdio.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/exec_protos.h>
#include <clib/datatypes_protos.h>

#define PROPH	(w->BorderTop -2)
#define PROPW	(PROPH*2)

struct Library *DataTypesBase;
struct Window *w;
Object *dto,*pvo,*pho;
struct IntuiMessage *imsg;
struct TagItem *tstate,*tags,*tag;
ULONG tidata,errnum,sigr;
BOOL done=FALSE;

struct TagItem VertMapping[]= {
	{PGA_Top,		DTA_TopVert},
	{PGA_Visible,	DTA_VisibleVert},
	{PGA_Total,		DTA_TotalVert},
	{TAG_DONE,		NULL}
};

struct TagItem HorizMapping[]= {
	{PGA_Top,		DTA_TopHoriz},
	{PGA_Visible,	DTA_VisibleHoriz},
	{PGA_Total,		DTA_TotalHoriz},
	{TAG_DONE,		NULL}
};

void DoJob(void);

int main(int argc, char *argv[])
{
	if (DataTypesBase=OpenLibrary("datatypes.library",0)) {
		if (w=OpenWindowTags(NULL,
						WA_IDCMP,			IDCMP_CLOSEWINDOW|IDCMP_IDCMPUPDATE,
						WA_Title,			"dt3b - DataTypes example",
						WA_CloseGadget,	TRUE,
						WA_DepthGadget,	TRUE,
						WA_DragBar,			TRUE,
						WA_NoCareRefresh,	TRUE,
						WA_AutoAdjust,		TRUE,
						WA_MinWidth,		50,
						WA_MinHeight,		50,
						WA_Width,			500,
						WA_Height,			250,
						TAG_DONE	)) {

         if (dto=NewDTObject(argv[1],
                     GA_Left,    w->BorderLeft,
                     GA_Top,     w->BorderTop,
                     GA_Width,   w->Width - w->BorderLeft - w->BorderRight - PROPW,
                     GA_Height,  w->Height - w->BorderTop - w->BorderBottom - PROPH,
                     ICA_TARGET, ICTARGET_IDCMP,
                     TAG_DONE )) {

            if (pvo=NewObject(NULL,"propgclass",
                        GA_Left,       w->Width-w->BorderRight-PROPW,
                        GA_Top,        w->BorderTop,
                        GA_Height,     w->Height - w->BorderTop - w->BorderBottom - PROPH,
                        GA_Width,		PROPW,
								PGA_NewLook,	TRUE,
                        ICA_TARGET,    dto,
                        ICA_MAP,       VertMapping,
                        TAG_DONE )) {
               if (pho=NewObject(NULL,"propgclass",
                        	GA_Left,       w->BorderLeft,
                           GA_Top,        w->Height - w->BorderBottom - PROPH,
                           GA_Height,     PROPH,
                           GA_Width,      w->Width - w->BorderLeft - w->BorderRight - PROPW,
                           PGA_NewLook,   TRUE,
                           PGA_Freedom,	FREEHORIZ,
                           ICA_TARGET,    dto,
                           ICA_MAP,       HorizMapping,
                           TAG_DONE )) {

                  AddGadget(w,pvo,-1);
                  AddGadget(w,pho,-1);
                  AddDTObject(w,NULL,dto,-1);

                  RefreshDTObjects(dto,w,NULL,NULL);
                  RefreshGadgets(pvo,w,NULL);

                  DoJob();

                  RemoveGadget(w,pvo);
                  RemoveGadget(w,pho);
                  DisposeObject(pho);
                  }
               DisposeObject(pvo);
               RemoveDTObject(w,dto);
            }
            DisposeDTObject(dto);
         }
			CloseWindow(w);
		}
		CloseLibrary(DataTypesBase);
	}
	return(0);
}


void DoJob(void)
{
   while (!done) {
      sigr=Wait((1<<w->UserPort->mp_SigBit) | SIGBREAKF_CTRL_C);

      if (sigr & SIGBREAKF_CTRL_C)
         done=TRUE;

      while (imsg=(struct IntuiMessage *)GetMsg(w->UserPort)) {
         switch (imsg->Class) {

            case IDCMP_IDCMPUPDATE:
               tstate=tags=(struct TagItem *)imsg->IAddress;
               while (tag=NextTagItem(&tstate)) {
                  tidata=tag->ti_Data;
                  switch (tag->ti_Tag) {
                     case DTA_Busy: if (tidata)
                                       SetWindowPointer(w,WA_BusyPointer,TRUE,TAG_DONE);
                                    else
                                       SetWindowPointer(w,WA_Pointer,NULL,TAG_DONE);
                                    break;
                     case DTA_ErrorLevel:
                                    printf("Error: Level %d, Num %d, ",tidata,GetTagData(DTA_ErrorNumber,NULL,tags));
                                    printf("String \"%s\"\n",GetTagData(DTA_ErrorString,NULL,tags));
                                    break;
                     case DTA_Sync: RefreshDTObjects(dto,w,NULL,NULL);
                                    break;
                     case DTA_Title:
                                    SetWindowTitles(w,(STRPTR)tag->ti_Data,(STRPTR)~0);
                                    break;
                     case DTA_TopVert:
                                    SetGadgetAttrs(pvo,w,NULL,PGA_Top,tag->ti_Data,TAG_DONE);
                                    break;
                     case DTA_TotalVert:
                                    SetGadgetAttrs(pvo,w,NULL,PGA_Total,tag->ti_Data,TAG_DONE);
                                    break;
                     case DTA_VisibleVert:
                                    SetGadgetAttrs(pvo,w,NULL,PGA_Visible,tag->ti_Data,TAG_DONE);
                                    break;
                     case DTA_TopHoriz:
                                    SetGadgetAttrs(pho,w,NULL,PGA_Top,tag->ti_Data,TAG_DONE);
                                    break;
                     case DTA_TotalHoriz:
                                    SetGadgetAttrs(pho,w,NULL,PGA_Total,tag->ti_Data,TAG_DONE);
                                    break;
                     case DTA_VisibleHoriz:
                                    SetGadgetAttrs(pho,w,NULL,PGA_Visible,tag->ti_Data,TAG_DONE);
                                    break;

                     default:       printf("? tag->ti_Tag = %d ",tag->ti_Tag);
                                    if ((tag->ti_Tag - DTA_Dummy)<1000)
                                       printf("(DTA_Dummy + %d) ",tag->ti_Tag - DTA_Dummy);
                                    if ((tag->ti_Tag - GA_Dummy)<1000)
                                       printf("(GA_Dummy + 0x%04x) ",tag->ti_Tag - GA_Dummy);
                                    printf("tag->ti_Data = %d\n",tag->ti_Data);
                                    break;
                  }
               }
               break;

            case IDCMP_CLOSEWINDOW:
               done=TRUE;
               break;

            default:
               printf("? imsg->Class = %d\n",imsg->Class);
               break;
         } /* switch su imsg->Class */
         ReplyMsg(imsg);
      } /* while GetMsg */
   } /* while !done */
}