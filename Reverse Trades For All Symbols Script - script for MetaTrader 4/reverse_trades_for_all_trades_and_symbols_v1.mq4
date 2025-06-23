//+------------------------------------------------------------------+
//|                     ReverseTradesForAllSymbols_Script.mq4        |
//|                        Copyright 2024, Your Company Name         |
//|                          http://www.yourwebsite.com              |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "Reverse All Trades"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs
#property script_show_inputs

// Input parameters
extern bool reverseAllTrades = false;            // Reverse All Trades

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    if (reverseAllTrades)
    {
    ReverseAllTrades();
    }
}

//+------------------------------------------------------------------+
//| Reverse all trades function                                      |
//+------------------------------------------------------------------+
void ReverseAllTrades()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            int orderType = OrderType();
            double openPrice = OrderOpenPrice();
            double lotSize = OrderLots();
            string symbol = OrderSymbol();

            // Close existing order
            bool closeResult = OrderClose(OrderTicket(), lotSize, Bid, 5, clrNONE);
            if (closeResult)
            {
                Print("Closed order: ", OrderTicket(), " for symbol: ", symbol, " at price: ", Bid);
                
                // Open opposite order
                int oppositeType = (orderType == OP_BUY) ? OP_SELL : OP_BUY;
                double oppositePrice = (orderType == OP_BUY) ? Ask : Bid;
                
                int ticket = OrderSend(symbol, oppositeType, lotSize, oppositePrice, 5, 0, 0, "Reverse Trade", 0, 0, clrNONE);
                
                if (ticket > 0)
                {
                    Print("Opened opposite order: ", ticket, " for symbol: ", symbol, " at price: ", oppositePrice);
                }
                else
                {
                    Print("Failed to open opposite order for symbol: ", symbol);
                }
            }
            else
            {
                Print("Failed to close order: ", OrderTicket(), " for symbol: ", symbol);
            }
            // Pause for a short time to avoid rapid execution
            Sleep(1000);
        }
    }
}
