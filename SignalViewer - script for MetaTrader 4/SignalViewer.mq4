//+------------------------------------------------------------------+
//|                                                     SignalViewer |
//|                                         Copyright © 2013, Ice FX |
//|                                      		    http://www.icefx.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Ice FX <http://www.icefx.eu>"
#property link      "http://www.icefx.eu"
#property show_inputs

#include <WinUser32.mqh>

#define  SCRIPT_VERSION               "1.1"

extern string  fileName             = "history.csv";
extern int     hourOffset           = 0;

/*******************  Version history  ********************************

   This script shows the MQL5 community signal orders from history csv file. 
   
   How to use:
   -----------
      - Open the signal page at www.mql5.com/en/signals
      - Click to "Export to CS: History" link and download the file
      - Copy this file to your MetaTrader\experts\files folder.
      - Open a chart and drop this script to chart
      - In inputs tab set the correct filename and the hourOffset values    
   

   v1.1 - 2014.01.04
   --------------------
      - Problem if there is no ticket number in CSV


   v1.0 - 2013.07.16
   --------------------
      - First release

***********************************************************************/


int start()
{
   int f = FileOpen(fileName ,FILE_READ|FILE_CSV, ';');   
   if (f == -1)
   {
      // File open error
      int res = GetLastError();
      MessageBox("File open error! " + res, "Error", MB_OK | MB_ICONWARNING);
      return(0);
   }
   // Move position to file begin
   FileSeek(f, 0, SEEK_SET); 

   //Skip the header
   bool hasTicket = false;
   int count = 1;
   while(!FileIsLineEnding(f)) {
      string s = FileReadString(f);
      if (s == "Order")
         hasTicket = true;   
   }
   
   // Clear chart objects
   ObjectsDeleteAll();
   
   
   while(!FileIsEnding(f))
   {
      //  Order;Time;Type;Volume;Symbol;Price;S/L;T/P;Time;Price;Commission;Swap;Profit;Comment
      
      if (hasTicket)
         int ticket = FileReadNumber(f);

      string open_date = FileReadString(f);
      string action = FileReadString(f);
      double lots = FileReadNumber(f);
      string symb = FileReadString(f);

      double openPrice = FileReadNumber(f);
      double sl = FileReadNumber(f);
      double tp = FileReadNumber(f);
      
      string close_date = FileReadString(f);
      double closePrice = FileReadNumber(f);
      double comission = FileReadNumber(f);
      double swap = FileReadNumber(f);
      double profit = FileReadNumber(f);
      string comment = FileReadString(f);
      
      //Skip other fields
      while(!FileIsLineEnding(f)) FileReadString(f);
      
      // Skip other symbol orders
      if (StringSubstr(symb, 0, 6) != StringSubstr(Symbol(), 0, 6)) continue;
      
      int ordType = getOrderTypeFromString(action);
      if (ordType == -1)
      {
         Print("Not supported order type: ", action);
         continue;         
      }

      if (ordType > OP_SELL) closePrice = openPrice; // pending orders price not changed
      
      datetime openTime = convertDate(open_date);
      datetime closeTime = convertDate(close_date);

      color c = Blue;
      if (ordType == OP_SELL || ordType == OP_SELLLIMIT || ordType == OP_SELLSTOP)
         c = Red;

      // order open arrow name:    #76840865 buy 0.05 EURUSDc at 1.30416

      string objName = StringConcatenate("#", ticket, " ", action, " ", lots, " ", symb, " at ", openPrice);
      ObjectCreate(objName, OBJ_ARROW, 0, openTime, openPrice);
      ObjectSet(objName, OBJPROP_COLOR, c);
      ObjectSet(objName, OBJPROP_ARROWCODE, 1);
      //ObjectSetText(objName, "LOT: " + DoubleToStr(lots, 2));

      // order line name:    #76840865 1.30416 -> 1.30956

      objName = StringConcatenate("#", ticket, " ", openPrice, " -> ", closePrice);
      ObjectCreate(objName, OBJ_TREND, 0, openTime, openPrice, closeTime, closePrice);
      ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(objName, OBJPROP_RAY, false);
      ObjectSet(objName, OBJPROP_COLOR, c);

      // order close arrow name: #76840865 buy 0.05 EURUSDc at 1.30416 close at 1.30956
      objName = StringConcatenate("#", ticket, " ", action, " ", lots, " ", symb, " at ", openPrice, " close at ", closePrice);
      ObjectCreate(objName, OBJ_ARROW, 0, closeTime, closePrice);
      ObjectSet(objName, OBJPROP_COLOR, Goldenrod);
      ObjectSet(objName, OBJPROP_ARROWCODE, 3);
      ObjectSetText(objName, StringConcatenate("Profit: ", profit, ", Comment: ", comment));
      
      if (sl != EMPTY_VALUE && sl > 0.0)
      {
         // SL line arrow name: #76824391 buy stop 0.10 EURUSDc at 1.32065 stop loss at 1.31865
         objName = StringConcatenate("#", ticket, " ", action, " ", lots, " ", symb, " at ", openPrice, " stop loss at ", sl);
         ObjectCreate(objName, OBJ_ARROW, 0, openTime, sl);
         ObjectSet(objName, OBJPROP_COLOR, Red);
         ObjectSet(objName, OBJPROP_ARROWCODE, 4);
      }
      
      if (tp != EMPTY_VALUE && tp > 0.0)
      {
         //  TP line arrow name: #76764027 buy stop 0.10 EURUSDc at 1.31474 take profit at 1.317
         objName = StringConcatenate("#", ticket, " ", action, " ", lots, " ", symb, " at ", openPrice, " take profit at ", tp);
         ObjectCreate(objName, OBJ_ARROW, 0, openTime, tp);
         ObjectSet(objName, OBJPROP_COLOR, Blue);
         ObjectSet(objName, OBJPROP_ARROWCODE, 4);
      }      
      //MessageBox(StringConcatenate(open_date, " = ", TimeToStr(openTime, TIME_DATE|TIME_MINUTES), ", ", close_date, " = ", TimeToStr(closeTime, TIME_DATE|TIME_MINUTES)), "", MB_OK);
      //Print(StringConcatenate(open_date, " = ", TimeToStr(openTime, TIME_DATE|TIME_MINUTES), ", ", close_date, " = ", TimeToStr(closeTime, TIME_DATE|TIME_MINUTES)), "", MB_OK);
      count++;   
   }
   FileClose(f);
   
   MessageBox(StringConcatenate(
      "  ..:: SignalViewer v", SCRIPT_VERSION, " ::..\r\n", 
      "--------------------------------------------\r\n\r\n", 
      " Loaded ", count,  " orders to chart\r\n\r\n",
      "--------------------------------------------\r\n", 
      "Copyright © 2013, Ice FX - www.icefx.eu"), "SignalViewer", MB_OK);
                        
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int getOrderTypeFromString(string s)
{
   if (s == "Buy")         return(OP_BUY);
   if (s == "Buy Stop")    return(OP_BUYSTOP);
   if (s == "Buy Limit")   return(OP_BUYLIMIT);

   if (s == "Sell")         return(OP_SELL);
   if (s == "Sell Stop")    return(OP_SELLSTOP);
   if (s == "Sell Limit")   return(OP_SELLLIMIT);
   
   return(-1);
}

datetime convertDate(string s)
{
   // 2013.06.27 14:17:53
   // 0123456789012345678

   string y  = StringSubstr(s, 0, 4);
   string m  = StringSubstr(s, 5, 2);
   string d  = StringSubstr(s, 8, 2);
   string h  = StringSubstr(s, 11, 2);
   string n  = StringSubstr(s, 14, 2);
   string ss = StringSubstr(s, 17, 2);
   
   datetime res = StrToTime(StringConcatenate(y, ".", m, ".", d, " ", h, ":", n, ":", ss));
   if (hourOffset != 0)
      res = res + hourOffset * 60 * 60; 
      
   return(res);
}