#include <exec/types.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>
#include <exec/libraries.h>
#include <dos/dostags.h>
#include <stdio.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/wb_protos.h>

void cleanexit(char *msg);

#define NUM_VOCI 4

struct Library *WorkbenchBase = NULL;
struct MsgPort      *myport=NULL;
struct AppMenuItem *appitem[NUM_VOCI]= {NULL, NULL, NULL, NULL};
struct AppMessage   *appmsg=NULL;

void main(int argc, char **argv)
{
  BOOL finito = FALSE;
  int i;
  char *voci[NUM_VOCI] = {"prima", "seconda", "terza","fine"};

  /* Apro le librerie e alloco la porta messaggio */
  WorkbenchBase = OpenLibrary("workbench.library",37);
  if (!WorkbenchBase) cleanexit("Non posso aprire la workbench.library\n");
  myport = CreateMsgPort();
  if(! myport) cleanexit("Non posso creare la porta messaggio\n");

  /* Aggiungo le voci dell'array `voci` al menu, e assegno l'indice */
  /* in tale array come ID */
  for (i=0; i<NUM_VOCI; i++)
  {
    appitem[i] = AddAppMenuItemA(i,NULL,voci[i],myport,NULL);
    if(! appitem[i]) cleanexit("Non posso aggiungere tutti gli AppItem\n");
  }

  do
  {
    WaitPort(myport);
    while((appmsg=(struct AppMessage *)GetMsg(myport)))
    {
      /* se è stata selezionata la voce `fine`, esco dal programma */
      if (appmsg->am_ID == 3)
        finito = TRUE;
      else
      {
        printf("voce = %s ",voci[appmsg->am_ID]);
        printf("scelta con %ld icone selezionate\n",appmsg->am_NumArgs);
      }
      ReplyMsg((struct Message *)appmsg);
    }
  } while (! finito);
  cleanexit(NULL);
}

void cleanexit(char *msg)
{
  int i;

  if (msg) printf(msg);
  for (i=0; i<NUM_VOCI; i++)
    if (appitem[i]) RemoveAppMenuItem(appitem[i]);
  if (myport)
  {
    while(appmsg=(struct AppMessage *)GetMsg(myport))
      ReplyMsg((struct Message *)appmsg);
    DeleteMsgPort(myport);
  }
  if (WorkbenchBase) CloseLibrary(WorkbenchBase);
}