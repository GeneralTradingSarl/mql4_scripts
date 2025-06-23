//+------------------------------------------------------------------+
//|                                        Wamek_SellOrders.mq4      |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script-2023"
#property link      "eawamek@gmail.com"
#property version   "1.00"
#property strict
#property script_show_inputs

//--- input parameters
extern double   Lots= .01;
extern int      TakeProfit=400;
extern int      StopLoss= 200;
extern int      Num_Of_Sell =1;
int      MagicNum = 432;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {

   if(IsTradeAllowed())
     {
      int pick = MessageBox("You are about to open "+DoubleToString(Num_Of_Sell,0)+" sell order(s)\n","Sell",0x00000001);
      if(pick==1)
         for(int i =0 ; i<Num_Of_Sell; i++)
            place_order();
     }

   else
      MessageBox("Enable AutoTrading Please ");
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
void place_order()
  {
   int ticket;
   double stoplosslevel, takeprofitlevel;

   if(StopLoss == 0)
      stoplosslevel=0;
   else
      stoplosslevel=Bid + StopLoss*Point;

   if(TakeProfit == 0)
      takeprofitlevel=0;
   else
      takeprofitlevel =  Bid - TakeProfit*Point;


//---
   ticket = OrderSend(Symbol(),OP_SELL,Lots, Bid, 3,stoplosslevel,takeprofitlevel,NULL,MagicNum,0,Red);

   if(ticket< 0)
      Alert("OrderSend failed with error #",GetLastError());

  }



/*
//---Draw Object on the chart

void GenerateLABEL(long Id, string ObjName, string Info, float X, float Y, color clr)
  {
   if(ObjectFind(Id,ObjName)==-1)
     {
      ObjectCreate(Id,ObjName, OBJ_LABEL, 0, 0, 0);
      ObjectSet(ObjName, OBJPROP_CORNER, 0);
      ObjectSet(ObjName, OBJPROP_XDISTANCE, X);
      ObjectSet(ObjName, OBJPROP_YDISTANCE, Y);
      ObjectSetInteger(Id,ObjName,OBJPROP_FONTSIZE,10);
      ChartRedraw(Id);
     }
   ObjectSetText(ObjName,Info,12,"Arial",clr);
  }

//+------------------------------------------------------------------+
*/