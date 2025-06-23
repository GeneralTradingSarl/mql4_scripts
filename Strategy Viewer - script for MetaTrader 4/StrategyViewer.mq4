//+------------------------------------------------------------------+
//|                                                   strat_view.mq4 |
//|                                         Copyright © 2013, Ice FX |
//|                                      		    http://www.icefx.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Ice FX <http://www.icefx.eu>"
#property link      "http://www.icefx.eu"
#property show_inputs

#include <WinUser32.mqh>

#define  SCRIPT_VERSION             "1.2"

extern string fileName = "statement.csv";
extern int hourOffset = 0;

/*******************  Version history  ********************************

   v1.2 - 2013.07.03
   --------------------
      - Fixed some issue with symbol suffix problem.

   v.1.1 - 2012.12.20
   --------------------
      - Fixed: MyFxBook added ticket number to csv
      - Fixed: Missing orders if csv not content price field


   v1.0 - 2012.03.27
   --------------------
      - First release

***********************************************************************/


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int f = FileOpen(fileName ,FILE_READ|FILE_CSV, ',');   
   if (f == -1)
   {
      int res = GetLastError();
      MessageBox("File open error! " + res, "Error", MB_OK|MB_ICONWARNING);
      return(0);
   }
   FileSeek(f, 0, SEEK_SET); 

   //Skip the header
   int count = 1;
   bool hasLots, hasProfit, hasTicket = false;
   while(!FileIsLineEnding(f)) {
      string s = FileReadString(f);
      if (s == "Lots")
         hasLots = true;
      if (s == "Profit")
         hasProfit = true;
      if (s == "Ticket")
         hasTicket = true;
   }
   ObjectsDeleteAll();
   
   while(!FileIsEnding(f))
   {
      if (hasTicket)
         int ticket = FileReadNumber(f);
      else  
         ticket = count;

      string open_date = FileReadString(f);
      string close_date = FileReadString(f);
      string symb = FileReadString(f);
      string action = FileReadString(f);
      if (hasLots)
         double lots = FileReadNumber(f);
      else  
         lots = 0.0;
         
      double sl = FileReadNumber(f);
      double tp = FileReadNumber(f);
      double openPrice = FileReadNumber(f);
      double closePrice = FileReadNumber(f);
      double comission = FileReadNumber(f);
      double swap = FileReadNumber(f);
      double pips = FileReadNumber(f);
      
      if (hasProfit && !FileIsLineEnding(f))
         double profit = FileReadNumber(f);
      else  
         profit = 0.0;
      
      //Skip other fields
      while(!FileIsLineEnding(f)) FileReadString(f);
      
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

      string objName = "A-" + action + "-" + ticket;
      ObjectCreate(objName, OBJ_ARROW, 0, openTime, openPrice);
      ObjectSet(objName, OBJPROP_COLOR, c);
      ObjectSet(objName, OBJPROP_ARROWCODE, 1);
      ObjectSetText(objName, "LOT: " + DoubleToStr(lots, 2));

      objName = "L-" + action + "-" + ticket;
      ObjectCreate(objName, OBJ_TREND, 0, openTime, openPrice, closeTime, closePrice);
      ObjectSet(objName, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(objName, OBJPROP_RAY, false);
      ObjectSet(objName, OBJPROP_COLOR, c);

      objName = "C-" + action + "-" + ticket;
      ObjectCreate(objName, OBJ_ARROW, 0, closeTime, closePrice);
      ObjectSet(objName, OBJPROP_COLOR, Goldenrod);
      ObjectSet(objName, OBJPROP_ARROWCODE, 3);
      ObjectSetText(objName, "PIP: " + DoubleToStr(pips, 1) + ", Price: " + DoubleToStr(profit, 2));
      //MessageBox(StringConcatenate(open_date, " = ", TimeToStr(openTime, TIME_DATE|TIME_MINUTES), ", ", close_date, " = ", TimeToStr(closeTime, TIME_DATE|TIME_MINUTES)), "", MB_OK);
      //Print(StringConcatenate(open_date, " = ", TimeToStr(openTime, TIME_DATE|TIME_MINUTES), ", ", close_date, " = ", TimeToStr(closeTime, TIME_DATE|TIME_MINUTES)), "", MB_OK);
      count++;   
   }
   FileClose(f);
   
   MessageBox("Loaded " + count + " orders.", "Finish", MB_OK);
   
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
   string m = StringSubstr(s, 0, 2);
   string d = StringSubstr(s, 3, 2);
   string y = StringSubstr(s, 6, 4);
   string h = StringSubstr(s, 11, 2);
   string n = StringSubstr(s, 14, 2);
   
   datetime res = StrToTime(StringConcatenate(y, ".", m, ".", d, " ", h, ":", n));
   if (hourOffset != 0)
      res = res + hourOffset * 60 * 60; 
      
   return(res);
}