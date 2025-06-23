//+------------------------------------------------------------------+
//|                                            EndOfDayDetection.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will scan all the open trades and then will close the biggest winning/losing trade"
#property copyright "https://tradingbotmaker.com/"
#property description  "Email - support@tradingbotmaker.com "
#property description  "Telegram - @pops1990 "
#property version "1.0"
#property  link "https://www.tradingbotmaker.com"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(DayEndReached())
     {
      MessageBox("End of trading day is reached");
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|           Check the day end time                          |
//+------------------------------------------------------------------+
bool DayEndReached()
  {
   datetime dCurrentTime = TimeCurrent();

   datetime time_tradeend = StrToTime(TimeToStr(TimeCurrent(),TIME_DATE) + " "  + "23:59");

   return dCurrentTime>=time_tradeend;
  }
//+------------------------------------------------------------------+
