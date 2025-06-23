//+------------------------------------------------------------------+
//|                                                      shablon.mq4 |
//|                                             Viatcheslav Suvorov  |
//+------------------------------------------------------------------+
#property copyright "Viatcheslav Suvorov"
#property show_inputs
#include <WinUser32.mqh>

#import "IdleLib.dll"
int GetLastKeyWP();
int GetLastMouseWP();
int IdleLibInit();
int IdleLibUnInit();
string GetActiveWndName();
#import

int start()
  {
        IdleLibInit();//инициализируем Dll дл€ перехвата событий   
         bool NeedLoop=true;  
         while(NeedLoop){           
           int lastkey=GetLastKeyWP();//ќпрашиваем код посл. клавиши
           int lastmouse=GetLastMouseWP();//ќпрашиваем код мыши           
           string lastwnd=GetActiveWndName();//»м€ окна Metatrader где произошло событие
           if ((lastkey!=0) && (lastwnd!="")) {             
             Print(" од нажатой клавиши=",lastkey," из окна ",lastwnd);
           }  
           if ((lastmouse!=0) && (lastwnd!="") && (lastmouse!=512)) {//отражаем все событи€ кроме движени€ мыши             
             Print(" од мыши=",lastmouse," из окна ",lastwnd);
           }                                    
           Sleep(100);
         }//while                
   return(0);
  }

void deinit()
  {
   IdleLibUnInit();
  }

