//+------------------------------------------------------------------+
//|                                      Closing All Open Orders.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   RefreshRates();
   Print(OrdersTotal());

   for (int i = (OrdersTotal() - 1); i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == false)
          {
         Print("Error - Unable to select the order - ", GetLastError());
         break;
      } 

      bool result = false;
      
      int Slippage = 0;
      
      double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
      double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

      if (OrderType() == OP_BUY)
          {
         result = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
      }
      else if (OrderType() == OP_SELL)
          {
         result = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
      }
      
      if (result == false) Print("Error - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
   }
}