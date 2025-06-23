//+------------------------------------------------------------------+
//|                                   Winning and Loosing Streak.mq4 |
//|                                   Copyright 2022, Tradecian Algo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tradecian Algo"
#property link      "https://www.mql5.com/en/users/biswait50/seller"
#property link      "https://www.fiverr.com/biswait50"
#property description  "Contact Mail  : tradecianalgo@gmail.com"
#property description  "Telegram  : @pops1990"
#property version   "2.00"
#property strict

input bool ENABLE_MAGIC_NUMBER= false; // Enable Magic Number
input bool ENABLE_SYMBOL_FILTER=false; // Enable Symbol filter
int MAGICNUMBER=1234; // Magic Number

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int winning= getWinningStreak();
   int loosing= getLoosingStreak();
   Comment("winning streak "+ winning+"\n"
   "loosing streak "+ loosing);
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  GET  Loosing Streak                                        |
//+------------------------------------------------------------------+
int getLoosingStreak()
  {
   int loss=0;
   for(int i = (OrdersHistoryTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)  && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
        {
         if(OrderProfit()<0)
            loss++;
         else
            break;
        }

     }
   return loss;
  }
  
 //+------------------------------------------------------------------+
//|  GET  Winning Streak                                        |
//+------------------------------------------------------------------+
int getWinningStreak()
  {
   int wins=0;
   for(int i = (OrdersHistoryTotal() - 1); i >= 0; i--)
     {
      // If the order cannot be selected, throw and log an error.
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)  && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER))
        {
         if(OrderProfit()>0)
            wins++;
         else
            break;
        }

     }
   return wins;
  }