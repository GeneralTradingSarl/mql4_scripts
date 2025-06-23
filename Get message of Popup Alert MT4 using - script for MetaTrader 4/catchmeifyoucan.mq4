//+------------------------------------------------------------------+
//|                                              CatchMeIfYouCan.mq4 |
//|                           Copyright 2022, Hung_tthanh@yahoo.com. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Hung_tthanh@yahoo.com."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define WM_GETTEXTLENGTH 0xE
#define WM_GETTEXT 0xD


#import "user32.dll"
   int FindWindowW(string lpClassName, string lpWindowName);
   int FindWindowExW(int hWnd1, int hWnd2, string lpsz1, string lpsz2);
   int SendMessageA(int hwnd, int wMsg, int wParam, int lParam);
   int SendMessageA(int hwnd, int wMsg, int wParam, char &lParam[]); //Edit lParam to receive value return
#import
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   GetAlertMsgContent();
  }
//+------------------------------------------------------------------+

void GetAlertMsgContent()
{
   int Hwnd = 0; //handle of parent window
   int CHwnd = 0; //handle of textbox
   
   Hwnd = FindWindowW("#32770", "Alert");//replace FindWindowA to FindWindowW for mql4
   Print(__FUNCTION__, "--> Parent handle = "+ (string)Hwnd);
   
   //Get handle of textbox in Dialog
   CHwnd = FindWindowExW(Hwnd, 0, "Edit", NULL);//Find All control have class name is "Edit"
   Print(__FUNCTION__, "--> Child hanld = "+ (string)CHwnd);
   
   //Get content of Message in textbox
   //Get length of message string
   int textLength = SendMessageA(CHwnd, WM_GETTEXTLENGTH, 0, 0);
   Print(__FUNCTION__, "--> Text length = "+ (string)textLength);
   
   //Get content message - using function SendMessageA
   string contentMsg = "";
   char ch[540];
   for(int i = 0; i < ArraySize(ch); i++) ch[i] = 0x000;
   
   ArrayInitialize(ch, 0x000);
   
   int length = SendMessageA(CHwnd, WM_GETTEXT, textLength + 1, ch);
   
   for(int i = 0; i < length; i++) contentMsg += CharToString(ch[i]);
   
   Print(__FUNCTION__, "--> Content Message = "+ contentMsg);
   Sleep(100);
}

//Done!!!