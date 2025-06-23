//+------------------------------------------------------------------+
//|                                    Spread & Pip Cost Checker.mq4 |
//|                             Copyright 2015, Obujh Software Corp. |
//|        https://www.obujh.org/scripts/spread-and-pip-cost-checker |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2015, Obujh Software Corp."
#property link        "https://www.obujh.org/scripts/spread-and-pip-cost-checker"
#property version     "1.01"
#property description "This script show you current currency pair spread, pip value and the total cost of the spread to open a position. Result will show in your account currency.\nTo see those information you have to input volume size in the input section."
#property strict
#property script_show_inputs //to show user input window
//---
input double LotSize=1.0; // Volumes
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- set variables type
   double Spread,PipCost,SpreadCost;
//--- detect spread
   Spread=MarketInfo(Symbol(),MODE_SPREAD);
//---
   if(Digits==3 || Digits==5)
     {
      Spread=Spread/10;
     }
//--- detect pip cost in account currency
   PipCost=NormalizeDouble((((MarketInfo(Symbol(),MODE_TICKVALUE)*Point)/MarketInfo(Symbol(),MODE_TICKSIZE))*LotSize),2);

   if(Digits==3 || Digits==5)
     {
      PipCost=PipCost*10;
     }
//--- calculate spread cost in account currency
   SpreadCost=NormalizeDouble(Spread*PipCost,2);
//--- show output
   Comment("Spread: ",Spread," Pips \nPip Cost: ",PipCost," ",AccountInfoString(ACCOUNT_CURRENCY),"\nSpread Cost: ",SpreadCost," ",AccountInfoString(ACCOUNT_CURRENCY),"\nVolumes: ",LotSize);
  }

//+------------------------------------------------------------------+
