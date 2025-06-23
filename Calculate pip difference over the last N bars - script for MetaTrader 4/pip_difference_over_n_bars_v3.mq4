//+------------------------------------------------------------------+
//|                                Pip Difference Over N bars V4.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|A very simple calculator on Pips over N Bars for Symbol and Period Chart
//|Since I find it fast and useful I want to share it with you !
//+------------------------------------------------------------------+


#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "Bars Pips for Chart Symbol and Period selected"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property strict
#property show_inputs
#property script_show_inputs

// Symbol to calculate pip difference for
extern int barsToCheck = 10; // Number of bars to calculate distance over
extern int point = 10; // Point to Pip conversion factor

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
{
    // Get the prices at the beginning and end of calculation
    double startPrice = Close[barsToCheck];
    double endPrice = Close[0];
    
    Print("Price at the beginning of calculation: ", startPrice);
    Print("Price at the end of calculation: ", endPrice);
    
    // Calculate the pip difference over the last N bars
    double pipDifference = (endPrice - startPrice) / Point / point;
    pipDifference = NormalizeDouble(pipDifference, Digits);
    
    string direction;
    
    // Determine the direction of the pip difference
    if (pipDifference > 0)
        direction = "up";
    else if (pipDifference < 0)
        direction = "down";
    else
        direction = "no change";
    
    // Print the pip difference
    Print("Pip difference over ", barsToCheck, " bars: ", pipDifference, " pips ", direction);

    return INIT_SUCCEEDED;
}
