//+------------------------------------------------------------------+
//|                                          CloseMultipleTrades.mq4 |
//|                                                   Filip Jankovic |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Filip Jankovic"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int numOrders=OrdersTotal(),ordertype,prev_ordertype,opposite_ticket,ticket;
   double orderLotsTotal=0.0;
   string prev_symbol;
   string symbol;
   int tickets_array[];
   ArrayResize(tickets_array,500,10);

   for(int i=numOrders-1; i>-1; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS)==True)
        {
         symbol=OrderSymbol();
         if(i==(numOrders-1))
            prev_symbol=symbol;
         if(symbol!=prev_symbol)
           {
            Alert("WARNING CANNOT CLOSE POSITIONS AS NOT ALL SAME SYMBOL!");
            return(1);
           }
         prev_symbol=symbol;
         ticket=OrderTicket();
         if(OrderType()==OP_BUYLIMIT||OrderType()==OP_SELLLIMIT)
           {
            if(OrderDelete(ticket)==True)
              {
               i++;
               numOrders=numOrders-1;
               continue;
              }
            else
              {
               Alert("OrderDelete failed error code is",GetLastError());
               i++;
               continue;
              }

           }
         tickets_array[i]=ticket;
         ordertype=OrderType();
         if(i==numOrders-1)
            prev_ordertype=ordertype;
         if(prev_ordertype!=ordertype)
           {
            Alert("WARNING CANNOT CLOSE POSITIONS IF NOT ALL SAME TYPE OF TRADE!");
            return(1);
           }
         orderLotsTotal=orderLotsTotal+OrderLots();
        }
      else
        {
         Alert("OrderSelect failed error code is",GetLastError());
         i++;
         continue;
        }
     }
   RefreshRates();
   if(ordertype==OP_SELL)
     {
      OrderSend(symbol,OP_BUY,orderLotsTotal,Ask,0.00005,0,0);
     }
   else
      OrderSend(symbol,OP_SELL,orderLotsTotal,Bid,(0.00005),0,0);

   numOrders=OrdersTotal();
   for(int i=(numOrders-1); i>-1; i--)
     {
      OrderSelect(numOrders,SELECT_BY_POS);
      opposite_ticket=OrderTicket();
      RefreshRates();
      OrderCloseBy(tickets_array[i], opposite_ticket);
      numOrders=numOrders-1;
     }

//----
   Alert("ALL CLOSED :)");
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
