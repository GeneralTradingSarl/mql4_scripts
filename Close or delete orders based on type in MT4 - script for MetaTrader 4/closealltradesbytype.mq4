//+------------------------------------------------------------------+
//|                                         CloseAllTradesByType.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will close all active trades and delete pending orders based on the order type passed on the input."
#property copyright "https://tradingbotmaker.com/"
#property description  "Email - support@tradingbotmaker.com "
#property description  "Telegram - @pops1990 "
#property version "1.0"
#property  link "https://www.tradingbotmaker.com"
#property version   "1.00"
#property strict
input bool ENABLE_MAGIC_NUMBER= false; // Enable Magic Number
input bool ENABLE_SYMBOL_FILTER=false; // Enable Symbol filter
int MAGICNUMBER=1234; // Magic Number
ENUM_ORDER_TYPE SELECTED_ORDER_TYPE= OP_BUY;//
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   CloseAllOrders(OP_BUY);
   CloseAllOrders(OP_SELL);
   CloseAllOrders(OP_BUYLIMIT);
   CloseAllOrders(OP_BUYSTOP);
   CloseAllOrders(OP_SELLLIMIT);
   CloseAllOrders(OP_SELLSTOP);
   //CloseAllOrders(SELECTED_ORDER_TYPE);
  }

//+------------------------------------------------------------------+
//|          Close All Orders By Type                                |
//+------------------------------------------------------------------+
void CloseAllOrders(int type)
  {
// Update the exchange rates before closing the orders.
   RefreshRates();

// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER) && OrderType()==type)
        {
         // for market order close the order
         if(OrderType()<2)
           {
            // Create the required variables.
            // Result variable - to check if the operation is successful or not.
            bool res = false;

            // Allowed Slippage - the difference between current price and close price.
            int Slippage = 0;

            // Bid and Ask prices for the instrument of the order.
            double BidPrice = MarketInfo(OrderSymbol(), MODE_BID);
            double AskPrice = MarketInfo(OrderSymbol(), MODE_ASK);

            // Closing the order using the correct price depending on the type of order.
            if(OrderType() == OP_BUY)
              {
               res = OrderClose(OrderTicket(), OrderLots(), BidPrice, Slippage);
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  res = OrderClose(OrderTicket(), OrderLots(), AskPrice, Slippage);
                 }

            // If there was an error, log it.
            if(res == false)
               Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
           }

        }
      // for pending order delete the orders
      else
        {
         if(!OrderDelete(OrderTicket()))
            Print("ERROR - Unable to delete the order - ", OrderTicket(), " - ", GetLastError());
        }

     }

  }
//+------------------------------------------------------------------+
