/**************************************************************************************
** Demo Ver.0.0 (usato per i testing...)
** 
** Author: =JON=
** Date: 07-Dic-1994
**
*************************************************************************************** 
*/

#include <exec/exec.h>
#include <assembly/assemblybase.h>
#include <datatypes/datatypes.h>
#include <datatypes/datatypesclass.h>
#include <datatypes/animationclass.h>
#include <libraries/asl.h>
#include <workbench/workbench.h>
#include <workbench/startup.h>

#include <clib/assembly_protos.h>
#include <clib/datatypes_protos.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/asl_protos.h>

#define REIFLAGS01	REIF_CENTERHSCREEN|REIF_CENTERVSCREEN

/********** Global VAR ***************************************************************/
struct AssemblyBase *AssemblyBase;
struct Library *DataTypesBase;

/********** My C prototypes **********************************************************/

/**************************************************************************************
 * Main 
 **************************************************************************************
*/
VOID main()
{
struct AsmRequest *areq;
Object *dto,*dto2,*dto3,*sound01;
BOOL fine = TRUE;

	if (AssemblyBase = OpenLibrary(ASSEMBLYNAME, ASSEMBLY_MINIMUM))
	{
		
		DataTypesBase = AssemblyBase->ab_DataTypesBase;
		
		dto = NewDTObject("sys:Classes/Images/Author.animbsh", DTA_ControlPanel,FALSE,TAG_DONE);
		dto2 = NewDTObject("sys:Classes/Images/Warning.bsh", DTA_ControlPanel,FALSE,TAG_DONE);		
		dto3 = NewDTObject("sys:Classes/Images/Assembly.Library.bsh", DTA_ControlPanel,FALSE,TAG_DONE);

		sound01 = NewDTObject("sys:Prefs/Sounds/sasm",
				 				 DTA_SourceType,	DTST_FILE,
								 DTA_GroupID,		GID_SOUND,
								 SDTA_Volume,		64,
								 SDTA_Cycles,		1,
								 TAG_DONE);		
		
	areq = AllocAsmRequest(AREQ_Title, "Welcome to Assembly.library Demo $VER:1.0",
							   AREQ_Object,dto3,	
							   AREQ_CenterHScreen,TRUE,
							   AREQ_CenterVScreen,TRUE,
							   AREQ_Justification, ASJ_CENTER,
							   AREQ_TextUnderObject,TRUE,
							   AREQ_NewLookBackFill,TRUE,
							   AREQ_APenPattern,0,
							   AREQ_BPenPattern,4,
							   TAG_DONE);
		
	LONG res = AsmRequestArgs(areq, "Questa Demo è di pubblico dominio, e come\n"
								"tale può essere liberamente distribuita.\n\n"
								"Il file assembly.library $VER.1.0Beta è in\n"
								"versione dimostrativa, e come tale può essere\n"
								"liberamente distribuito.",
								"_Continua|Esci", NULL);
												
	if (res == 1)
		{
			ChangeAsmReqAttrs(areq,AREQ_Object, NULL,AREQ_TextUnderObject,FALSE,
									AREQ_APenPattern,4,
							   		AREQ_BPenPattern,0,
									TAG_DONE);
		
			AsmRequestArgs(areq, "L'assembly.library è una libreria dedicata a tutti\n"
							 "i programmatori del linguaggio assembly.\n\n"
							 "Il progetto di questa libreria è nato nel 1990\n"
							 "come supporto ai programmatori assembly, e più\n"
							 "avanti si è sviluppato il pacchetto, anche per il\n" 
							 "uso sotto il linguaggio C.",
							 "_Continua",NULL);
			
			AsmRequestArgs(areq, "Le funzioni presenti nell assembly.library, coprono\n"
							 "le più disparate funzioni; troviamo infatti funzioni\n"
							 "grafiche, di supporto ad Intuition, manipolazione di\n"
							 "file, supporto ad Exec ecc...\n\n"
							 "L'Assembly.library è scritta, ovviamente, interamente\n"
							 "in assembly per Motorola 68020, è scritta utilizzando\n"
							 "le funzioni del KickStart 3.1, ed è quindi AGA.\n\n"
							 "Ciò significa che il minimo sistema richiesto per il\n"
							 "suo funzionamento è un'Amiga 1200.",
							 "_Continua",NULL);
			
			AsmRequestArgs(areq, "L'assembly.library si propone dunque di facilitare la\n"
						 "stesura di un software, sia sotto assembly, sia sotto C\n"
						 "fornendo anche un nuovo modo di gestire l'interfaccie\n"
						 "grafiche di Amiga.\n\n"
						 "Con il nuovo sistema operativo infatti, i boopsi hanno\n"
						 "dimostrato la grande facilità dell'Amiga di operare nel\n"
						 "campo della programmazione ad Oggetti (OOP).",
						 "_Continua",NULL);
							 
			AsmRequestArgs(areq, "Con l'assembly.library, s'introduce un nuovo modo di\n"
						 "concepire un qualsiasi applicativo, dal semplice software\n"
						 "PD, al più complesso programma commerciale.\n\n"
						 "La novità più importante risiede in un diverso approccio\n"
						 "nel concepire un'interfaccia utente.",
						 "_Continua",NULL);
						 
			AsmRequestArgs(areq, "Non vorrei ora dilungarmi troppo su quest'aspetto\n"
						" che è trattato benissimo nel file Re-Edit.Doc.\n\n"
						"Iniziamo invece a vedere i Request dell'assembly.library.",
						"Vediamo i _Request",NULL);			 
						
			AsmRequestArgs(areq, "L'assembly.library mette a disposizione un nuovo\n"
						"tipo di Request, che svolge la stessa funzione\n"
						"dell'EasyRequest() di Intuition, cioè la funzione che\n"
						"state vedendo... quello di informare l'utente di qualcosa.",
						"_Continua",NULL);
						
			AsmRequestArgs(areq, "Essendo un Request estremamente complesso, e\n"
						"progettato per future espansioni, molto del lavoro\n"
						"è stato svolto per renderlo il più semplice possibile\n"
						"da utilizzare. Non a caso questa Demo ne fa largo uso.",
						"_Continua",NULL);

			AsmRequestArgs(areq, "AllocAsmRequestA() è la funzione che permette\n"
						"di allocare ed inizializzare un Request.\n\n"
						"Una volta allocato ed inizializzato con i paramtri\n"
						"scelti dall'utente, l'AsmRequest deve solo essere\n"
						"invocato, tramite la funzione AsmRequestArgs().",
						"_Continua",NULL);						
						
			AsmRequestArgs(areq, "Il testo (Body) può essere\n"
						"centrato in divesi modi...\n\n"
						"ASJ_CENTER... come in questo caso.",
						"_Premi per centrare a sinistra",NULL);
						
			ChangeAsmReqAttrs(areq,AREQ_Justification, ASJ_LEFT,
									AREQ_APenPattern,4,
							   		AREQ_BPenPattern,5,
									TAG_DONE);						
			
			AsmRequestArgs(areq, "Oppure a sinistra\n"
						"come in questo caso\n"
						"bla bla bla... bla bla bla...",
						"_Premi per centrare a destra",NULL);
						
			ChangeAsmReqAttrs(areq,AREQ_Justification, ASJ_RIGHT,
								AREQ_APenPattern,5,
							    AREQ_BPenPattern,5,
								TAG_DONE);						
			
			AsmRequestArgs(areq, "Ecco tutto il testo spostato\n"
						"a destra\n"
						"bla bla bla... bla bla bla...",
						"_Continua",NULL);
						
			ChangeAsmReqAttrs(areq,AREQ_Justification, ASJ_LEFT,
									AREQ_APenPattern,4,
							   		AREQ_BPenPattern,4,
									TAG_DONE);			
			
			res = AsmRequestArgs(areq, "Premi un pulsante...",
						"_1|_2|_3|_0",NULL);
						
			res = AsmRequest(areq, "Bene, hai premuto il pulsante n.%ld...\n"
						"Giusto???",
						"_Si|Si ho premuto il n. %ld|_No",res,res);						
						
			if (res == NULL)
			{
				res = AsmRequestArgs(areq, "Come No!!!??? cacchio, allora c'è\n"
								"qualcosa che non va...",
								"_Scherzavo!!|Quit",NULL);
				if(res == NULL)
					return(NULL);
			}		
			AsmRequestArgs(areq, "I Gadget vengono inizializzati nello\n"
						"stesso modo di EasyRequest(), direi anzi, che molte\n"
						"sono le cose che sono state lasciate il più\n"
						"possibile uguali a quelle di sistema.",
						"_Continua",NULL);				

			ChangeAsmReqAttrs(areq,AREQ_Object, dto2,TAG_DONE);								
			
			AsmRequestArgs(areq, "L'introduzione delle immagini e non solo\n"
						"rendono l'AsmRequest sicuramente più piacevole\n"
						"dei normali request presenti su Amiga...\n\n"
						"Non solo possono essere caricati file IFF\n"
						"ma qualsiasi file che possiede un suo datatype...",
						"_Continua",NULL);
						
			ChangeAsmReqAttrs(areq,AREQ_Object,dto,
									AREQ_TextUnderObject,TRUE,
									TAG_DONE);
			
			AsmRequestArgs(areq, "Il testo può essere forzato a comparire\n"
						"al di sotto della nostra immagine o animazione.\n\n"
						"Premi sull'animazione per rivederla... ;)",
						"_Continua",NULL);
								
		}
	DisposeDTObject(sound01);
	DisposeDTObject(dto);	
	DisposeDTObject(dto2);
	FreeAsmRequest(areq);
	CloseLibrary(AssemblyBase);
	}
}


VOID wbmain(wbmsg)
{
	main();
	exit(0);
}
