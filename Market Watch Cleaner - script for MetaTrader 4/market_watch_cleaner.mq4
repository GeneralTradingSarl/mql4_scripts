//+------------------------------------------------------------------+
//|                                           MarketWatchCleaner.mq4 |
//|                                                        Jay Davis |
//|                                         https://www.tidyneat.com |
//+------------------------------------------------------------------+
#property copyright "Link to Jay Davis' profile."
#property link      "https://www.mql5.com/en/users/johnthe"
#property version   "1.00"
#property description "This script removes all instruments with spread higher than the specified maximum requested and it also removes all non-trade enabled instruments from Market Watch, which allows you to concentrate on items you may want to trade without all the clutter."
#property strict
#property script_show_inputs
//--- input parameters
input int      MaximumSpread=20;//Max spread to in show Market Watch.
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   ShowAllInstrumentsInMarketWatch(TotalInstruments());
   RemoveUnTradableInstruments();
   RemoveHighSpreadInstruments();
   Print("Market Watch now contains ", VisibleInstruments(), " visible elements, ",
   TotalTradableInstruments() - VisibleInstruments(), " tradable hidden elements, and ",
   TotalInstruments() - TotalTradableInstruments(), " elements where trade is not allowed." );
   Print("Thanks for using my script", "  \nhttps://www.mql5.com/en/users/johnthe");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowAllInstrumentsInMarketWatch(int totalInstruments)
  {
   for(int i=0; i<=totalInstruments; i++)
     {
      SymbolSelect(SymbolName(i,false),true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalInstruments()
  {
   return SymbolsTotal(false)-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VisibleInstruments()
{
return SymbolsTotal(true)-1;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalTradableInstruments()
  {
  int count = 0;
   for(int i=0; i<=TotalInstruments(); i++)
     {
      ENUM_SYMBOL_TRADE_MODE
      mode=(ENUM_SYMBOL_TRADE_MODE)
           SymbolInfoInteger(SymbolName(i,false),SYMBOL_TRADE_MODE);
      if((mode == SYMBOL_TRADE_MODE_FULL))
        {
         count++;
        }
     }
return count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveUnTradableInstruments()
  {
   for(int i=0; i<=TotalInstruments(); i++)
     {
      ENUM_SYMBOL_TRADE_MODE
      mode=(ENUM_SYMBOL_TRADE_MODE)
           SymbolInfoInteger(SymbolName(i,false),SYMBOL_TRADE_MODE);
      if((mode != SYMBOL_TRADE_MODE_FULL))
        {
         SymbolSelect(SymbolName(i,false),false);
         Print("Removed ",SymbolName(i,false)," ",
         EnumToString(mode));
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RemoveHighSpreadInstruments()
  {
   for(int i=0; i<=TotalInstruments(); i++)
     {
      long spread=SymbolInfoInteger(SymbolName(i,false),SYMBOL_SPREAD);
      if(spread>MaximumSpread)
        {
         if(SymbolSelect(SymbolName(i,false),false))
           {
            Print("Removed ",SymbolName(i,false)," with high spread of ",spread);
           }
         else
           {
            Print("Failed to remove ",SymbolName(i,false));
            Sleep(100);
            Print("RefreshingRates ...",RefreshRates());
            if(SymbolSelect(SymbolName(i,false),false))
              {
               Print("Successfully Removed ",SymbolName(i,false)," with high spread of ",spread);
                 }else {
               Print("Failed again after rates refresh, Please apply to a different chart!");
              }
           }

        }
     }
  }
//+------------------------------------------------------------------+
