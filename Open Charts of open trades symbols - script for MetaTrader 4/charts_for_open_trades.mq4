//+------------------------------------------------------------------+
//|                                          Print Orders Symbol.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| This little utility script open charts of open trades symbols
//| and prints list of open trades symbols in Terminal - Experts panel  
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "Julian 2024 - free open source"
#property description   "Open charts of open trades and print open trades symbols in Terminal - Experts"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
    int totalOrders = OrdersTotal();
    for (int i = 0; i < totalOrders; i++)
    {
        if (OrderSelect(i, SELECT_BY_POS) == true)
        {
            string symbol = OrderSymbol();
            Print("Order ", i, " Symbol: ", symbol);
            ChartOpen(symbol, 60);
        }
        else
        {
            Print("Failed to select order ", i);
        }
    }
}
