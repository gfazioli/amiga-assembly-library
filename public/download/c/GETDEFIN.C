STRPTR GetDefInterfaceName(int argc, char **argv)
{
struct DiskObject *dobj;
struct WBStartup *wbs;
struct WBArg *wbarg;
STRPTR icname;
STRPTR iname;

	if (argc == 0)
	{
		wbs = (struct WBStartup *)argv;
		wbarg = wbs->sm_ArgList;
		icname = wbarg[0].wa_Name;
		CurrentDir(wbarg[0].wa_Lock);
	}
	else
		icname = argv[0];	

	if( !(dobj = GetDiskObject(icname)) )
	{
		CurrentDir(NULL);
		return(NULL);
	}	
		
	iname = FindToolType(dobj->do_ToolTypes, "INTERFACE");
	FreeDiskObject(dobj);
	CurrentDir(NULL);
	return(iname);
}