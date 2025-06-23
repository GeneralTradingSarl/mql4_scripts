//+------------------------------------------------------------------+
//|                                                BO open trade.mq4 |
//|                                        Copyright 2016, Barash777 |
//|                                      barash.vertihvost@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Barash777"
#property link      "barash.vertihvost@gmail.com"
#property version   "1.0"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| Trade type                                                       |
//+------------------------------------------------------------------+
enum tmode
  {
   a1=0, // Buy
   a2=1, // Sell
  };

extern tmode  TradeDirection=0; // Trade direction
extern double BOInvestment=10;  // Investment size
extern int    BOExpiry=1;       // Expiration in minutes
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   OpenBO(TradeDirection);
  }
//+------------------------------------------------------------------+
//| Open BO orders                                                   |
//+------------------------------------------------------------------+
void OpenBO(int cmd)
  {
   int tkt=-1;

// define lot value
   double Lot=BOInvestment;

   if(cmd==OP_BUY)
      tkt=OrderSend(Symbol(),cmd,Lot,NormalizeDouble(Ask,Digits),0,0,0,"BO exp:"+IntegerToString(BOExpiry*60),0,0,clrGreen);
   if(cmd==OP_SELL)
      tkt=OrderSend(Symbol(),cmd,Lot,NormalizeDouble(Bid,Digits),0,0,0,"BO exp:"+IntegerToString(BOExpiry*60),0,0,clrRed);

// if order was opened
   if(tkt>0) return;
   else
     {
      int error=GetLastError();
      Print("Order was not open! Error #",error);
     }

   return;
  }
//+------------------------------------------------------------------+
