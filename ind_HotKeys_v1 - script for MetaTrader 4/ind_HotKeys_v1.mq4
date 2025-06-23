#include <WinUser32.mqh>
	
#define PAUSE 10
#define VK_MENU 0x12 //ALT key
#define VK_CONTROL 0x11 //CTRL key
	
	
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"

#property indicator_chart_window

extern   int     CtrlAlt=0;   // Первая клавиша: 0 - Ctrl, 1 - Alt
extern   string  Key="Q";     // Вторая клавиша 

//---- input parameters

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
  
    int FirstKey=VK_CONTROL;
    if(CtrlAlt==1)FirstKey=VK_MENU;
    int SecondKey=StringGetChar(Key,0);
 
	 keybd_event(FirstKey,0,0,0);
	 Sleep(PAUSE);
	 keybd_event(SecondKey,0,0,0);
	 Sleep(PAUSE);
	 keybd_event(SecondKey,0,2,0);
	 Sleep(PAUSE);
	 keybd_event(FirstKey,0,2,0);  
  
  
  
  
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {




   return(0);
  }
//+------------------------------------------------------------------+