//+------------------------------------------------------------------+
//|                              CloseBiggestWinningLoosingTrade.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will scan all the open trades and then will close the biggest winning/losing trade"
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
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int ticket = GetTicketOfBiggestLosingTrade();
   if(ticket>0)
      CloseOrderByTick(ticket); 
   ticket = GetTicketOfBiggestWinningTrade();
   if(ticket>0)
      CloseOrderByTick(ticket);
  }

//+------------------------------------------------------------------+
//|  Find the ticket number of biggest losing ticket number          |
//+------------------------------------------------------------------+
int GetTicketOfBiggestLosingTrade()
  {
   int ticket=0;
   double profit=0;
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
        {
         if(OrderProfit()<0 && OrderProfit()<profit)
           {
            profit= OrderProfit();
            ticket = OrderTicket();
           }
        }
     }
   return ticket;
  }
//+------------------------------------------------------------------+
//|  Find the ticket number of biggest winning ticket number          |
//+------------------------------------------------------------------+
int GetTicketOfBiggestWinningTrade()
  {
   int ticket=0;
   double profit=0;
   for(int i = (OrdersTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
        {
         if(OrderProfit()>profit)
           {
            profit= OrderProfit();
            ticket = OrderTicket();
           }
        }
     }
   return ticket;
  }
//+------------------------------------------------------------------+
//|          Close Order By Ticket                                   |
//+------------------------------------------------------------------+
void CloseOrderByTick(int ticket)
  {
// Update the exchange rates before closing the orders.
   RefreshRates();

// Start a loop to scan all the orders.
// The loop starts from the last order, proceeding backwards; Otherwise it would skip some orders.

// If the order cannot be selected, throw and log an error.
   if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
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
//+------------------------------------------------------------------+
