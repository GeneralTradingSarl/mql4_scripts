//+------------------------------------------------------------------+
//|                                         Total Orders By Type.mq4 |
//|                                   Copyright 2022, Tradecian Algo |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property description "This script will calculate thetotal  active and closed orders based on order types"
#property copyright "https://tradingbotmaker.com/"
#property description  "Email - support@tradingbotmaker.com "
#property description  "Telegram - @pops1990 "
#property version "1.0"
#property  link "https://www.tradingbotmaker.com"
#property  strict
#property strict

input bool ENABLE_MAGIC_NUMBER= false; // Enable Magic Number
input bool ENABLE_SYMBOL_FILTER=false; // Enable Symbol filter
int MAGICNUMBER=1234; // Magic Number
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

   int openBuys= TotalOpenOrdersByType(OP_BUY);
   int openSells= TotalOpenOrdersByType(OP_SELL);
   int openBuyStop= TotalOpenOrdersByType(OP_BUYSTOP);
   int openSellStop= TotalOpenOrdersByType(OP_SELLSTOP);
   int openBuyLimit= TotalOpenOrdersByType(OP_BUYLIMIT);
   int openSellLimit= TotalOpenOrdersByType(OP_SELLLIMIT);
   
   int closedBuys= TotalClosedOrdersByType(OP_BUY);
   int closedSells= TotalClosedOrdersByType(OP_SELL);

   Comment(
           "open Buys "+ (string)openBuys+"\n"
           "open Sells "+ (string)openSells+"\n"
           "open Buy Stop "+ (string)openBuyStop+"\n"
           "open Sell Stop "+ (string)openSellStop+"\n"
           "open Buy Limit "+ (string)openBuyLimit+"\n"
           "open Sell Limit "+ (string)openSellLimit+"\n"
           "closed Buys "+ (string)closedBuys+"\n"
           "closed Sells "+ (string)closedSells+"\n"
           );

  }
//+------------------------------------------------------------------+
//|  Get Total Open Orders  By Type                                       |
//+------------------------------------------------------------------+
int TotalOpenOrdersByType(int type)
  {
   int count=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER) && OrderType()==type)
         count++;

     }
   return count;
  }

//+------------------------------------------------------------------+
//|  Get Total Open Orders  By Type                                       |
//+------------------------------------------------------------------+
int TotalClosedOrdersByType(int type)
  {
   int count=0;
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderType()!=6 && OrderType()!=7 && ((ENABLE_SYMBOL_FILTER && OrderSymbol()==Symbol()) || !ENABLE_SYMBOL_FILTER) && ((ENABLE_MAGIC_NUMBER && OrderMagicNumber()==MAGICNUMBER) || !ENABLE_MAGIC_NUMBER) && OrderType()==type)
         count++;

     }
   return count;
  }
//+------------------------------------------------------------------+
