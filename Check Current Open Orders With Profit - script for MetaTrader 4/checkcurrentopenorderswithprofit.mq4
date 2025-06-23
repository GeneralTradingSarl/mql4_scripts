//+------------------------------------------------------------------+
//|                             CheckCurrentOpenOrdersWithProfit.mq4 |
//|                                          Author : Franck Mallouk |
//|                                       http://www.oniricforge.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright oniricforge.com"
#property link        "http://www.oniricforge.com"
#property version     "1.00"
#property description "This script lists current open orders with profit."
#property strict
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//---
   double CurrentTotalProfit=0.0; // Total Profit.
   string stringResult=""; // Report content.
//--- Looking for the open orders with profit.
   for(int tradeTicket=0; tradeTicket<=OrdersTotal(); tradeTicket++)
     {
      if(OrderSelect(tradeTicket,SELECT_BY_POS,MODE_TRADES))
        {
         int orderType=OrderType();
         //---
         if(orderType==OP_BUY || orderType==OP_SELL)
           {
            string stringOrderType;
            //---
            switch(orderType)
              {
               case OP_BUY:
                  stringOrderType="BUY";
                  break;
               case OP_SELL:
                  stringOrderType="SELL";
                  break;
              }
            //---
            while(true)
              {
               //---
               RefreshRates();
               //---
               if(OrderProfit()>0.0) // An open order with profit has been found. We append it to the list.
                 {
                  stringResult=StringConcatenate(stringResult,"\n\n","#",OrderTicket()," ; ",OrderSymbol()," ; Profit: ",OrderProfit()," ; Type: ",stringOrderType," ; Open Time: ",OrderOpenTime()," ; Open Price: ",OrderOpenPrice()," ; Volume: ",OrderLots()," ; Commission: ",OrderCommission()," ; Swap: ",OrderSwap());
                  CurrentTotalProfit+=OrderProfit();
                 }
               break;
              }
           }
        }
      else
        {
         Print("OrderSelect failed - Error code : ",GetLastError());
        }
     }
//---
   string stringCurrentDateTime=TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS); // Getting the last known value of the server time.
//--- If there is at least one open order with profit, a report file is created, in .txt format. The file name includes the account name and the current server time.
   if(CurrentTotalProfit>0.0)
     {
      //---
      string stringAccountNameForFileName=AccountName();
      //---
      StringReplace(stringAccountNameForFileName," ","_");
      //---
      string stringCurrentDateTimeForFileName=stringCurrentDateTime;
      //---
      StringReplace(stringCurrentDateTimeForFileName," ","_");
      StringReplace(stringCurrentDateTimeForFileName,".","-");
      StringReplace(stringCurrentDateTimeForFileName,":","");
      //---
      string stringFileName=StringConcatenate("report_open_orders_with_profit__",stringAccountNameForFileName,"__",stringCurrentDateTimeForFileName,".txt");
      //---
      int fileHandler;
      fileHandler=FileOpen(stringFileName,FILE_TXT|FILE_WRITE,";");
      if(fileHandler>0)
        {
         FileSeek(fileHandler,0,SEEK_END);
         FileWrite(fileHandler,"");
         FileWrite(fileHandler,"Report : Current Open Orders With Profit");
         FileWrite(fileHandler,"");
         FileWrite(fileHandler,StringConcatenate("Account name: ",AccountName()));
         FileWrite(fileHandler,"");
         FileWrite(fileHandler,StringConcatenate("Server time: ",stringCurrentDateTime));
         FileWrite(fileHandler,"");
         FileWrite(fileHandler,StringConcatenate("Current Profit: ",CurrentTotalProfit));
         FileWrite(fileHandler,"");
         FileWrite(fileHandler,stringResult);
         FileWrite(fileHandler,"");
         FileClose(fileHandler);
        }
      //---
      stringResult=StringConcatenate("\n\n","Report : Current Open Orders With Profit","\n\n","Account name: ",AccountName(),"\n\n","Server time: ",stringCurrentDateTime,"\n\n","Current Profit: ",CurrentTotalProfit,"\n",stringResult,"\n\n\n","New file created: ",stringFileName,"\n\n\n");
     }
   else
     {
      stringResult=StringConcatenate("\n\n","Report : Current Open Orders With Profit","\n\n","Account name: ",AccountName(),"\n\n","Server time: ",stringCurrentDateTime,"\n\n\n","There is currently no open order with profit.","\n\n\n");
     }
//--- Displaying a message box.
   MessageBox(stringResult,"Open Orders With Profit",MB_TOPMOST|MB_ICONINFORMATION);
//---
   return(0);
  }
//+------------------------------------------------------------------+
