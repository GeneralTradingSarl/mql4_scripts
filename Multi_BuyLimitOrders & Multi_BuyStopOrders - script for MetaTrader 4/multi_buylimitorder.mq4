//+------------------------------------------------------------------+
//|                                   Wamek_BuyLimitOrders.mq4       |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script-2023"
#property link      "eawamek@gmail.com"
#property version   "1.00"
#property strict
#property script_show_inputs

enum ChooseOption {Target=1,NumOfPips=2};
//--- input parameters
extern string   Option = "SELECT TargetPrice OR NumOfPips BELOW";
extern string   NOTEWELL = "When TargetPrice is selected,Pips has no effect&Vice Versa";

extern ChooseOption TargetOrPips = 2;
extern int      Pips_4rm_AskPrice = 400;
extern double   TargetPrice = 1.03350;
extern double   Lots = .01;
extern int      TakeProfit=400;
extern int      StopLoss=200;
extern int      NumOfBuyLimit = 1;
int      MagicNum = 1280;



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(IsTradeAllowed())
     {
      int pick = MessageBox("You are about to open "+DoubleToString(NumOfBuyLimit,0)+" BuyLimit orders\n","BuyLimit",0x00000001);
      if(pick==1)
         for(int i =0 ; i< NumOfBuyLimit; i++)
            place_order();

     }
   else
      MessageBox(" Enable AutoTrading Please ");

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment(" ");
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WhereToBuy()
  {
   if(TargetOrPips == 1)
      return(TargetPrice);
   else
      return(Ask-Pips_4rm_AskPrice*Point);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void place_order()
  {
   int ticket;
   double stoplosslevel,takeprofitlevel;

   if(StopLoss == 0)
      stoplosslevel=0;
   else
      stoplosslevel=WhereToBuy() - StopLoss*Point;

   if(TakeProfit == 0)
      takeprofitlevel=0;
   else
      takeprofitlevel =WhereToBuy() + TakeProfit*Point;

//---
   ticket = OrderSend(Symbol(),OP_BUYLIMIT, Lots, WhereToBuy(), 3,stoplosslevel,takeprofitlevel,NULL,MagicNum,0,Green);

   if(ticket<=0)
      Alert("OrderSend failed with error #",GetLastError());

  }







//+------------------------------------------------------------------+
