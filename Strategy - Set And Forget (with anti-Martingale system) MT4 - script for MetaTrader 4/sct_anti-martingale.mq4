//+------------------------------------------------------------------+
//|                                          SCT_Anti-Martingale.mq5 |
//|                                    Copyright 2018, Mario Gharib. |
//|                                         mario.gharib@hotmail.com |
//+------------------------------------------------------------------+
//|IMPORTANT INFORMATION YOU NEED TO KNOW                            |
//+------------------------------------------------------------------+
//|Please note that investing involves risks. Any decision to invest |
//|in either the real estate or stock markets is a personal decision |
//|that should be made after thorough research, including an         |
//|assessment of your personal risk tolerance and your personal      |
//|financial condition and goals. Results are based on market        |
//|conditions and on each individual and the action they take and the|
//|time and effort they put in.                                      |
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, Mario Gharib. mario.gharib@hotmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs


input int iNbStopOrders; // Number of stop orders (Buy Stop Or Sell Stop)
input double dEntryPrice;  // The initial entry price
input double dStopPrice;   // The initial stop Price
input double dLotSize=0.01;   // The position size of each trade.
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      string sSymbol = Symbol();
      
      if (dEntryPrice>SymbolInfoDouble(sSymbol,SYMBOL_ASK)) {
         double dGrid1=dEntryPrice-dStopPrice;
         for (int i=1 ; i<=iNbStopOrders ; i++)
            bool buystop = OrderSend(Symbol(),OP_BUYSTOP,dLotSize,dEntryPrice+(i-1)*dGrid1,5,dEntryPrice+(i-1)*dGrid1-dGrid1,dEntryPrice+(i-1)*dGrid1+2*dGrid1,NULL);
      }
      else {
         double dGrid=dStopPrice-dEntryPrice;
         for (int j=1 ; j<=iNbStopOrders ; j++)
            bool sellstop = OrderSend(Symbol(),OP_SELLSTOP,dLotSize,dEntryPrice-(j-1)*dGrid,5,dEntryPrice-(j-1)*dGrid+dGrid,dEntryPrice-(j-1)*dGrid-2*dGrid,NULL);
      }  
  }
//+------------------------------------------------------------------+
