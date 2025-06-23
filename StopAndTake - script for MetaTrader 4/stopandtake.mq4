//+------------------------------------------------------------------+
//|                                                  StopAndTake.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Melnichenko D.A."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
double price=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   price=ChartPriceOnDropped();
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      while(IsTradeContextBusy()){Sleep(1000);}
      ModifyOrder();
     }
  }
//+------------------------------------------------------------------+
void ModifyOrder()
{
   switch(OrderType())
   {
      case OP_BUY:
      {
         if(price > Bid)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price, 0))
               MessageBox("Order change error", "Warning", MB_OK);
         if(price < Bid)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), price, OrderTakeProfit(), 0))
               MessageBox("Order change error", "Warning", MB_OK);
         break;
      }
      case OP_SELL:
      {
         if(price < Ask)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price, 0))
               MessageBox("Order change error", "Warning", MB_OK);
         if(price > Ask)
            if(!OrderModify(OrderTicket(), OrderOpenPrice(), price, OrderTakeProfit(), 0))
               MessageBox("Order change error", "Warning", MB_OK);
         break;
      }
   }
}
//+------------------------------------------------------------------+