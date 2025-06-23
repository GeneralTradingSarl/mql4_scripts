//+------------------------------------------------------------------+
//|                                                calculateLots.mq4 |
//|                                                      flourishing |
//|                                    http://www.tradesignal.com.cn |
//+------------------------------------------------------------------+
#property copyright "flourishing"
#property link      "http://www.tradesignal.com.cn"
#include <WinUser32.mqh>

#property show_inputs
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
extern  string starttime = "2009.1.1 00:00";
extern string  endtime = "2009.2.30 00:00";

int start()
  {
//----
   double totallots;
   int i ,cnt;
   cnt = OrdersHistoryTotal();
   for(i =0;i<cnt;i++)
     if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
       if( OrderOpenTime()>StrToTime(starttime) && OrderOpenTime()<StrToTime(endtime))
         totallots = OrderLots()+totallots;
         
   MessageBox("From "+starttime+" To "+endtime+" \n\nTotal Lots: "+DoubleToStr(totallots,2)+ " Lots");
         
         
//----
   return(0);
  }
//+------------------------------------------------------------------+