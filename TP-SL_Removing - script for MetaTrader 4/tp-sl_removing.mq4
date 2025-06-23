//+------------------------------------------------------------------+
//|                                                   TP-SL Removing |
//|                                Copyright © 2016 (Mike eXplosion) |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016 (Mike eXplosion)"
#property link      "https://www.mql5.com/en/users/mike_explosion"
#property version   "1.0"

#property strict

#property description "Elimina TakeProfit y StopLoss de todas las posiciones."
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClearSLnTP()
  {
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      bool res=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,Blue);

     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(CalculateCurrentOrders()!=0)
      ClearSLnTP();
  }
//+------------------------------------------------------------------+
