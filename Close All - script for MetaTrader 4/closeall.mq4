//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                 Copyright © 2015, FlashTrade JFL |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, FlashTrade JFL"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   for(int x=OrdersTotal()-1;x>=0;x--)
     {
      if(!OrderSelect(x,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
      if(!OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,CLR_NONE)){ Alert("fail deleting trade order"); }
     }
  }
//+------------------------------------------------------------------+
