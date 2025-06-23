//+------------------------------------------------------------------+
//|                                             RoNz Auto SL n TP.mq4|
//|                                   Copyright 2014, Rony Nofrianto |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Rony Nofrianto"
#property link      ""
#property version   "1.00"
#property strict

int CalculateCurrentOrders()
  {
   int buys=0,sells=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderType()==OP_BUY)
        {
         buys++;
        }
      if(OrderType()==OP_SELL)
        {
         sells++;
        }
     }

   if(buys>0) return(buys);
   else       return(-sells);

  }
bool ClearSLnTP()
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
       bool res=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,Blue);

     }
   return false;
  }
void OnStart()
  {
   if(CalculateCurrentOrders()!=0)
      ClearSLnTP();
  }
