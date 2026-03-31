/***************************************************************************
** HOOK SIDE -- LV CallBack Fuctions
 ***************************************************************************
*/

/* Apply a ghosting pattern to a given rectangle in a rastport */
VOID Ghost(struct RastPort *rp, UWORD pen, UWORD x0, UWORD y0, UWORD x1, UWORD y1)
{
    SetABPenDrMd(rp,0,0,JAM1);
    SetAfPt(rp,GhostPattern,1);
    RectFill(rp,x0,y0,x1,y1);
    SetAfPt(rp,NULL,0);
}

/* Erase any part of "oldExtent" which is not covered by "newExtent" */
VOID FillOldExtent(struct RastPort *rp,struct Rectangle *oldExtent, 
												struct Rectangle *newExtent)
{ 
	RectFill(rp,oldExtent->MinX,oldExtent->MinY,oldExtent->MaxX,oldExtent->MaxY);
}	

/*
    if (oldExtent->MinX < newExtent->MinX)
        RectFill(rp,oldExtent->MinX,
                    oldExtent->MinY,
                    newExtent->MinX-1,
                    oldExtent->MaxY);

    if (oldExtent->MaxX > newExtent->MaxX)
        RectFill(rp,newExtent->MaxX+1,
                    oldExtent->MinY,
                    oldExtent->MaxX,
                    oldExtent->MaxY);

    if (oldExtent->MaxY > newExtent->MaxY)
        RectFill(rp,oldExtent->MinX,
                    newExtent->MaxY+1,
                    oldExtent->MaxX,
                    oldExtent->MaxY);

    if (oldExtent->MinY < newExtent->MinY)
        RectFill(rp,oldExtent->MinX,
                    oldExtent->MinY,
                    oldExtent->MaxX,
                    newExtent->MinY-1);
                    	
} */

/* This function is called whenever an item of the listview needs to be drawn
 * by gadtools. The function must fill every pixel of the area described in
 * the LVDrawMsg structure. This function does the exact same rendering as
 * the built-in rendering function in gadtools, except that it render the
 * normal items using the highlight text pen instead of simply text pen.
 */
ULONG RenderHook(struct Hook *hk, struct Node *node, struct LVDrawMsg *msg)
{
struct RastPort   *rp;
UBYTE              state;
struct TextExtent  extent;
ULONG              fit;
WORD               x,y,slack;
ULONG              apen,bpen;
UWORD             *pens;
STRPTR             name;

    if (msg->lvdm_MethodID != LV_DRAW)
        return(LVCB_UNKNOWN);

    rp    = msg->lvdm_RastPort;
    if(node->ln_Type)
    	state = LVR_NORMALDISABLED;
	else    	
    	state = msg->lvdm_State;
    pens  = msg->lvdm_DrawInfo->dri_Pens;

    apen = pens[FILLTEXTPEN];
    bpen = pens[FILLPEN];
    if ((state == LVR_NORMAL) || (state == LVR_NORMALDISABLED))
    {
        apen = pens[TEXTPEN];   		 /* this is normally TEXTPEN */
        bpen = pens[BACKGROUNDPEN];
    }
    
    name = node->ln_Name;
	    
    fit = TextFit(rp,name,strlen(name),&extent,NULL,1,
                  msg->lvdm_Bounds.MaxX-msg->lvdm_Bounds.MinX-3-40,
                  msg->lvdm_Bounds.MaxY-msg->lvdm_Bounds.MinY+1);

    slack = (msg->lvdm_Bounds.MaxY - msg->lvdm_Bounds.MinY) - (extent.te_Extent.MaxY - extent.te_Extent.MinY);

    x = msg->lvdm_Bounds.MinX - extent.te_Extent.MinX + 2+40;
    y = msg->lvdm_Bounds.MinY - extent.te_Extent.MinY + ((slack+1)>>1);

    extent.te_Extent.MinX += x;
    extent.te_Extent.MaxX += x;
    extent.te_Extent.MinY += y;
    extent.te_Extent.MaxY += y;
    
    SetAPen(rp,bpen);
    FillOldExtent(rp,&msg->lvdm_Bounds,&extent.te_Extent);
    
    SetABPenDrMd(rp,apen,bpen,JAM2);
    Move(rp,x,y);
    Text(rp,name,fit);
    
    if ((state == LVR_NORMALDISABLED) || (state == LVR_SELECTEDDISABLED))
    {
        Ghost(rp,pens[BLOCKPEN],msg->lvdm_Bounds.MinX, msg->lvdm_Bounds.MinY,
                                msg->lvdm_Bounds.MaxX, msg->lvdm_Bounds.MaxY);
    }

    return(LVCB_OK);
}
