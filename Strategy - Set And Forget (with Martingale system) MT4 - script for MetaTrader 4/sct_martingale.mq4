//+------------------------------------------------------------------+
//|                                                   Martingale.mq5 |
//|                                    Copyright 2020, Mario Gharib. |
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
#property script_show_inputs
#property strict

input int iNbStopOrders=5; // Number of limit orders (Buy limit Or Sell limit)
input double dEntryPrice;  // The initial entry price
input double dStopLoss;   // The initial stop loss
input double dTakeProfit;   // The initial Take profit
input double dLotSize=0.01;   // The position size of each trade.

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   string sSymbol = Symbol();
   
   if (dEntryPrice>SymbolInfoDouble(sSymbol,SYMBOL_ASK)) {
      double dGrid1=dStopLoss-dEntryPrice;
      for (int i=1 ; i<=iNbStopOrders ; i++)
         bool selllimit = OrderSend(Symbol(),OP_SELLLIMIT,dLotSize,dEntryPrice-(i-1)*dGrid1,5,dStopLoss,dTakeProfit,NULL);         
   }
   else {
      double dGrid=dEntryPrice-dStopLoss;
      for (int j=1 ; j<=iNbStopOrders ; j++)
         bool buylimit = OrderSend(Symbol(),OP_BUYLIMIT,dLotSize,dEntryPrice+(j-1)*dGrid,5,dStopLoss,dTakeProfit,NULL);
   }
}