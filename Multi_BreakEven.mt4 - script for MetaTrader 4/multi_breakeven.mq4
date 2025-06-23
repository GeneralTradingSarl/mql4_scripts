//+------------------------------------------------------------------+
//|                                              Wamek BreakEven.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Wamek Script-2023"
#property link      "eawamek@gmail.com"
#property version   "1.00"
#property strict
#property script_show_inputs


//+------------------------------------------------------------------+
//|      input parameters                                            |
//+------------------------------------------------------------------+
enum ChooseOption {Target=1,NumOfPips=2};
extern string   Option = "SELECT TargetPrice OR NumOfPips BELOW";
extern string   NOTEWELL = "When TargetPrice is selected,Pips has no effect&Vice Versa";

input ChooseOption TargetOrPips = 2;
input int      Pips2BreakEven = 100;
input double   TargetPrice = 1.03350;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
  {
//---

 if( IsTradeAllowed())
   {      
    int pick = MessageBox("You are about to set StopLoss to BreakEven \n","BreakEven",0x00000001);               
         if (pick==1) BreakEvenFunc();
              
   }
  else MessageBox(" Enable AutoTrading !!");
 
     
   }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }


void BreakEvenFunc() {
   int mbd=0;
   
   for(int p=OrdersTotal()-1; p >=0; p--)
    if(  OrderSelect(p,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol())
     {
         // Buy
         if(OrderType()==OP_BUY ){
          if(TargetOrPips==1) 
            if(Bid> TargetPrice &&  OrderOpenPrice()>OrderStopLoss()) 
                mbd= OrderModify(OrderTicket(),OrderOpenPrice(),TargetPrice,OrderTakeProfit(),0,Blue);
                
          if(TargetOrPips==2)              
            if(Bid> OrderOpenPrice()+Pips2BreakEven*Point &&  OrderOpenPrice()>OrderStopLoss())
              mbd= OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Pips2BreakEven*Point,OrderTakeProfit(),0,Blue);
              
          if(mbd<0) Print("Buy modify. Err#",GetLastError()); 

        }
         /*----------------------------------------------------------------------------------------------------------------*/

         // Sell
         if(OrderType()==OP_SELL ){
           if(TargetOrPips==1) 
             if(Ask< TargetPrice && (OrderStopLoss()==0 ||  OrderStopLoss()>OrderOpenPrice()))
               mbd=  OrderModify(OrderTicket(),OrderOpenPrice(),TargetPrice,OrderTakeProfit(),0,Pink);
                   
           if(TargetOrPips==2)       
            if(Ask< OrderOpenPrice()- Pips2BreakEven*Point && (OrderStopLoss()==0 ||  OrderStopLoss()>OrderOpenPrice())) 
              mbd=  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Pips2BreakEven*Point,OrderTakeProfit(),0,Pink);
                
       
           if(mbd<0) Print("Sell modify. Err#",GetLastError());
         }
    }  
     
  } 
  
