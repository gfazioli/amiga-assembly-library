#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <utility/tagitem.h>
#include <stdio.h>

#include <clib/exec_protos.h>
#include <clib/datatypes_protos.h>

void DoQuery(char *name);

struct Library *DataTypesBase;
Object *dto;

int main(int argc, char *argv[])
{
	if (DataTypesBase=OpenLibrary("datatypes.library",0)) {
		if (dto=NewDTObject(argv[1],TAG_DONE)) {
			DoQuery(argv[1]);
			DisposeDTObject(dto);
		}
		CloseLibrary(DataTypesBase);
	}
	return 0;
}


void DoQuery(char *name)
{
	ULONG *n;
	struct DTMethod *m;

	printf("Metodi disponibili per %s.\n",name);

	printf("\nMetodi:\n");
	if (GetDTAttrs(dto,DTA_Methods,&n,TAG_DONE)) {
		while (*n!=(~0))
			printf("%08x        ",*n++);
		printf("\n");
	}

	printf("\nMetodi Trigger:\n");
	if (GetDTAttrs(dto,DTA_TriggerMethods,&m,TAG_DONE))
		if (m) {
			while (m->dtm_Label) {
				printf("Label %-20.20s Command %-20.20s Method %08x\n",
					m->dtm_Label, m->dtm_Command, m->dtm_Method);
				m++;
			}
		}
		else
			printf("Nessuno.\n");


}
