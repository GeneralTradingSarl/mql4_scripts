//+------------------------------------------------------------------+
//|                                          SCT_BestTimeToTrade.mq4 |
//|                                    Copyright 2020, Forex Jarvis. |
//|                                            forexjarvis@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Forex Jarvis. forexjarvis@gmail.com"
#property version   "1.00"
#property strict
#property script_show_inputs

input int iRange = 60;   // Period: Specify the number of days

double pipPos(string sSymbol) {
      if (MarketInfo(sSymbol,MODE_DIGITS)==1 || MarketInfo(sSymbol,MODE_DIGITS)==3 || MarketInfo(sSymbol,MODE_DIGITS)==5)
         return MarketInfo(sSymbol,MODE_POINT)*10;
      else 
         return MarketInfo(sSymbol,MODE_POINT)*1;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class cCandlestick {

   public:

      datetime dtTime;
      double dRangeCandle;
      double dHighPrice;
      double dLowPrice;
      
      int iDayOfWeek;
      string sDayOfWeek;
      
      void mvGetCandleStickCharateristics (string s, int i) {
         
         dtTime = iTime(s, PERIOD_H1, i);
         dHighPrice = iHigh(s, PERIOD_H1,i);
         dLowPrice = iLow(s, PERIOD_H1,i);
         
         dRangeCandle = NormalizeDouble(MathAbs(dHighPrice-dLowPrice)/pipPos(Symbol()),4);

      }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
{
   int i;

   int handle = FileOpen(Symbol()+"_H1_history"+".csv",FILE_CSV|FILE_READ|FILE_WRITE,',');
   
   if(handle>0) {

      FileSeek(handle,0,SEEK_SET);
      FileWrite(handle, "Date", "Time", "Range in Pips");
         
      cCandlestick cCS;

      int iHourlyRange = iRange*24; //Sum of all hours
                  
      for (i=1;i<=iHourlyRange;i++) {
         
         cCS.mvGetCandleStickCharateristics(_Symbol,i);
         FileWrite(handle, TimeToString(cCS.dtTime, TIME_DATE), TimeToString(cCS.dtTime, TIME_MINUTES), DoubleToString(cCS.dRangeCandle,5));

      }
   }
   FileClose(handle);

}