#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <utility/tagitem.h>
#include <stdio.h>

#include <clib/exec_protos.h>
#include <clib/datatypes_protos.h>

struct Library *DataTypesBase;
Object *dto;

int main(int argc, char *argv[])
{
	long r=-1;
	BPTR fh;

	if (DataTypesBase=OpenLibrary("datatypes.library",0)) {
		if (dto=NewDTObject(argv[1],TAG_DONE)) {
			if (fh=Open(argv[2],MODE_NEWFILE)) {
				r=DoDTMethod(dto,NULL,NULL,DTM_WRITE,NULL,fh,DTWM_IFF,NULL);
				Close(fh);
			}
			printf("Results: %ld\n",r);
			DisposeDTObject(dto);
		}
		CloseLibrary(DataTypesBase);
	}
	return 0;
}