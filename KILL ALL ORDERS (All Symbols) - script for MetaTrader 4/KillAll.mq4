//+------------------------------------------------------------------+
//|                                                     KillAll.mq4 |
//|                                            forex.monkey@live.com |
//|                                            forex.monkey@live.com |
//+------------------------------------------------------------------+
#property copyright "CodeMonkey"
#property link      "forex.monkey@live.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int x=OrdersTotal()-1;x>=0;x--){
      OrderSelect(x,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY || OrderType()==OP_SELL){
      OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),666,CLR_NONE);
      }else{OrderDelete(OrderTicket());}
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+