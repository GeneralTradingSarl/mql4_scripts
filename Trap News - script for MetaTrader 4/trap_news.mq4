//+------------------------------------------------------------------+
//|                                                    Trap News.mq4 |
//|                                                      reza rahmad |
//|                                           reiz_gamer@yahoo.co.id |
//+------------------------------------------------------------------+
#property copyright "reza rahmad"
#property link      "reiz_gamer@yahoo.co.id"
#property version   "1.00"
#property show_inputs

#include <stdlib.mqh>
#include <WinUser32.mqh>
#property show_inputs

// Default Inputs: Start
extern double Lots  = 0.01;
 double sstop,Sell_Stop_Price,tp_buy = 0.0;
 double bstop,Buy_Stop_Price,tp_sell = 0.0 ;
extern double rangepip = 10.0;
extern int Slippage = 3;
extern double StopLoss = 7;
extern int TakeProfit = 20;
int k,d;
// Default Inputs: End

int start()
{ 
   if(Digits==5){k=10000;d=5;} 
else if(Digits==4){k=10000;d=4;}
else if(Digits==3){k=100;d=3;}
else if(Digits==2){k=100;d=2;}
else {k=100;d=2;}
rangepip = rangepip / k;
   Sell_Stop_Price = Bid - rangepip ;
   sstop = Sell_Stop_Price + StopLoss * Point;
   tp_sell = Sell_Stop_Price - TakeProfit * Point;
   
   if(Sell_Stop_Price > Bid)
   
   {
      Alert("Error: Sell_Stop_Price must be less than Bid") ;
      return(1);
   }    
   
   string SL =  DoubleToStr(Lots,2);
   
   if(MessageBox("SELL STOP : " + SL + " lots at " + DoubleToStr(Sell_Stop_Price,Digits) + " " + Symbol(),
                 "Script",MB_YESNO|MB_ICONQUESTION)!=IDYES) return(1);
//----

   int ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,Sell_Stop_Price,Slippage,sstop,tp_sell,"expert comment",255,0,CLR_NONE);
   if(ticket<1)
   {
      int error=GetLastError();
      Print("Error = ",ErrorDescription(error));
      return(1);
   }
    Buy_Stop_Price = Ask + rangepip  ;
    bstop = Buy_Stop_Price - StopLoss * Point;
    tp_buy = Buy_Stop_Price + TakeProfit * Point ;
   if(Buy_Stop_Price < Ask)
   {
      Alert("Error: Buy_Stop_Price must be greater than Ask") ;
      return(1);
   }    
   
   string BL =  DoubleToStr(Lots,2);
   
   if(MessageBox("BUY STOP : " + BL + " lots at " + DoubleToStr(Buy_Stop_Price,Digits) + " " + Symbol(),
                 "Script",MB_YESNO|MB_ICONQUESTION)!=IDYES) return(1);
//----

   ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,Buy_Stop_Price,Slippage,bstop,tp_buy,"expert comment",255,0,CLR_NONE);
   if(ticket<1)
     {
      error=GetLastError();
      Print("Error = ",ErrorDescription(error));
      return(1);
     }
   
//----
   OrderPrint();
   return(0);
}