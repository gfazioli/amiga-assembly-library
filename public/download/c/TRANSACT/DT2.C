#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <libraries/dos.h>

struct Library *DataTypesBase;
BPTR lock;

struct DataTypeHeader *dth;
struct DataType *dtn;
STRPTR tdesc;
STRPTR gdesc;
UWORD ttype;
char *id;

int main(int argc, char *argv[])
{
	if (lock=Lock(argv[1],ACCESS_READ)) {
		if (DataTypesBase=OpenLibrary("datatypes.library",0)) {
			if (dtn=ObtainDataTypeA(DTST_FILE,(APTR)lock,NULL)) {
				dth=dtn->dtn_Header;
				ttype=dth->dth_Flags & DTF_TYPE_MASK;
				tdesc=GetDTString(ttype+DTMSG_TYPE_OFFSET);
				gdesc=GetDTString(dth->dth_GroupID);
				id=&(dth->dth_ID);

				printf("       File: %s\n",argv[1]);
				printf("Description: %s\n",dth->dth_Name);
				printf("   BaseName: %s\n",dth->dth_BaseName);
				printf("       Type: %d - %s\n",ttype,tdesc);
				printf("      Group: %s\n",gdesc);
				printf("         ID: %c%c%c%c\n",id[0],id[1],id[2],id[3]);

				ReleaseDataType(dtn);
			}
			CloseLibrary(DataTypesBase);
		}
		UnLock(lock);
	}
	return(0);
}
