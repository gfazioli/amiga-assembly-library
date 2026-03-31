struct WBArg *wbarg;
	
	wbarg = &(wbs->sm_ArgList[0]);
	STRPTR geppo = wbarg->wa_Name;
	wbarg = &(wbs->sm_ArgList[1]);
	STRPTR geppo2 = wbarg->wa_Name;
	
	struct ExecBase *eb = AssemblyBase->ab_ExecBase;
	struct Process *mytask = eb->ThisTask;
	struct Node *mynode = eb->ThisTask;
	STRPTR geppo3 = (STRPTR)mytask->pr_Arguments;
	STRPTR geppo4 = mynode->ln_Name;
	
			
	struct UpDateData *udd = mainrei->rei_UserData;
	ChangeAsmReqAttrs(udd->areq,AREQ_Title, "WBStartup Info....",
							   AREQ_Object,NULL,
							   AREQ_LockREI,mainrei,
							   AREQ_ReturnKey,TRUE,	
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_TextUnderObject,FALSE,
							   AREQ_APenPattern,5,
							   TAG_DONE);
							   
	AsmRequest(udd->areq, "Contenuti: %s\n %s\n %s\n ** %s **\n",
                         "_Continue", geppo,geppo2,geppo3,geppo4);