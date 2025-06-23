//+------------------------------------------------------------------+
//|                                        Hedge_UnBalanced_Lots.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will place hedge trade of unbalanaced type in MT4"
#property copyright "https://tradingbotmaker.com/"
#property description  "Email - support@tradingbotmaker.com "
#property description  "Telegram - @pops1990 "
#property version "1.0"
#property  link "https://www.tradingbotmaker.com"
#property version   "1.00"
#property version   "1.00"
#property strict

input bool ENABLE_MAGIC_NUMBER= false; // Enable Magic Number
input bool ENABLE_SYMBOL_FILTER=true; // Enable Symbol filter
int MAGICNUMBER=1234; // Magic Number
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   double totalBuyLots = TotalClosedOrdersByType(OP_BUY);
   double totalSellLots = TotalClosedOrdersByType(OP_SELL);
   int res=-1;
   if(totalBuyLots>totalSellLots)
     {
      double diff_lots = NormalizeDouble(totalBuyLots-totalSellLots,2);
      Print("diff_lots "+diff_lots);
      res=OrderSend(Symbol(),OP_SELL,diff_lots,Bid,3,0,0,"",MAGICNUMBER,0,Red);
     }
   if(totalBuyLots<totalSellLots)
     {
      double diff_lots = NormalizeDouble(totalSellLots-totalBuyLots,2);
      Print("diff_lots "+diff_lots);
      res=OrderSend(Symbol(),OP_BUY,diff_lots,Ask,3,0,0,"",MAGICNUMBER,0,Green);
     }
   if(res<0)
     {
      Print("ERROR - Unable to place the order - ", " - ", GetLastError());
     }

  }

//+------------------------------------------------------------------+
//|  Get Total Open Orders Lots  By Type                                       |
//+------------------------------------------------------------------+
double TotalClosedOrdersByType(int type)
  {
   double lots=0.0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER) && OrderType()==type)
         lots+=OrderLots();

     }
   return lots;
  }
//+------------------------------------------------------------------+
