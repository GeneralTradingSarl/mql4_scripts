#property copyright "what?"
#property link      "who cares!"

//+------------------------------------------------------------------+
//| couldn't recall a fancy comment here                             |
//+------------------------------------------------------------------+
int start()
  {
//----
   //int digits   = MarketInfo(Symbol(),MODE_DIGITS);
   //double value = NormalizeDouble(WindowPriceOnDropped(),digits);
   for(int i=OrdersTotal()-1;i>=0;i--)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderSymbol()!=Symbol())
         continue;
      
      RefreshRates();
      
      if(OrderType()==OP_BUY)           
         OrderClose(OrderTicket(),OrderLots(),Bid, 3,White);
      if(OrderType()==OP_SELL)    
         OrderClose(OrderTicket(),OrderLots(),Ask, 3,White);
      if((OrderType()==OP_BUYSTOP) || (OrderType()==OP_BUYLIMIT))           
         OrderDelete(OrderTicket());
      if((OrderType()==OP_SELLSTOP) || (OrderType()==OP_SELLLIMIT))
         OrderDelete(OrderTicket());
   }   
   return(0);
  }
//+------------------------------------------------------------------+