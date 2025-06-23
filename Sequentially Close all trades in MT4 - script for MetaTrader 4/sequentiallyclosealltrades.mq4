//+------------------------------------------------------------------+
//|                                Sequentially Close all trades.mq4 |
//|                                   Copyright 2022, Tradecian Algo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will close all active trades sequentially. following the order in which they were opened"
#property copyright "https://tradingbotmaker.com/"
#property description  "Email - support@tradingbotmaker.com "
#property description  "Telegram - @pops1990 "
#property version "1.0"
#property  link "https://www.tradingbotmaker.com"
#property strict

input bool ENABLE_MAGIC_NUMBER= false; // Enable Magic Number
input bool ENABLE_SYMBOL_FILTER=false; // Enable Symbol filter
int MAGICNUMBER=1234; // Magic Number
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int tickets[];
   int totalOrders = TotalOrders();
   ArrayResize(tickets,totalOrders);
   RefreshRates();
   MessageBox("Close process has started");
   for(int i=0; i<totalOrders; i++)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
        {
         tickets[i]= OrderTicket();
        }
     }
     FifoTickets(tickets);
     CloseAllOrders(tickets);
     MessageBox("All orders Closed");
  }
//+------------------------------------------------------------------+
//|  Get Total Orders                                                       |
//+------------------------------------------------------------------+
int TotalOrders()
  {
   int count=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
         count++;

     }
   return count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FifoTickets(int &sorted_order_tickets[])
  {
   int size = ArrayResize(sorted_order_tickets, OrdersTotal());
   for(int i=0; i<size; i++)
      if(OrderSelect(i, SELECT_BY_POS))
         sorted_order_tickets[i] = OrderTicket();
   return ArraySort(sorted_order_tickets);
  }
//+------------------------------------------------------------------+
//|          Close All Orders                                |
//+------------------------------------------------------------------+
void CloseAllOrders(int &sorted_orders[])
  {

   for(int i=0; i<ArraySize(sorted_orders); i++)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(sorted_orders[i], SELECT_BY_TICKET) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
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

  }
//+------------------------------------------------------------------+
