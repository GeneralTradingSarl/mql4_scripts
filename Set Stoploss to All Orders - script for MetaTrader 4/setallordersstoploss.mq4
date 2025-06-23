//+------------------------------------------------------------------+
//|                                         SetAllOrdersStopLoss.mq4 |
//|                                    Copyright 2021, Albrin Memedi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Albrin Memedi"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

input double StopLoss = 0;
input string Instrument = "AUDUSD";

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   for(int x=OrdersTotal(); x>=0; x--)
     {
      if(OrderSelect(x,SELECT_BY_POS)==true)
        {
         if(OrderSymbol()== Instrument)
           {
         if(OrderModify(OrderTicket(),OrderOpenPrice(),StopLoss,OrderTakeProfit(),0,clrNONE))
           {
           PrintFormat("SL placed successfully");
           }
         else
           {
            PrintFormat("Error on placing SL");
           }
          } 
        }
     }
//---

  }
//+------------------------------------------------------------------+
