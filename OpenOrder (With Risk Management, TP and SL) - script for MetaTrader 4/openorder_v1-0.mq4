//+------------------------------------------------------------------+
//|                                               OpenOrder_v1-0.mq4 |
//|                                                    Luca Spinello |
//|                                https://mql4tradingautomation.com |
//+------------------------------------------------------------------+



#property copyright     "Luca Spinello - mql4tradingautomation.com"
#property link          "https://mql4tradingautomation.com"
#property version       "1.00"
#property strict
#property description   "This script opens an order given your desired parameters"
#property description   " "
#property description   " "
#property description   "DISCLAIMER: This script comes with no guarantee, you can use it at your own risk"
#property description   "We recommend to test it first on a Demo Account"

#property show_inputs

enum Operation{
   buy=OP_BUY,    //BUY
   sell=OP_SELL,   //SELL
};

extern double Lots=1;                  //Specify position size, this is ignored if you use the Risk %
extern bool UseRiskPercentage=true;    //True if you want to use the risk % to calculate the size
extern double RiskPercentage=2;        //% of available balance to risk
input Operation Command=buy;           //Order type
extern int TakeProfit=40;              //Take Profit in pips
extern int StopLoss=20;                //Stop Loss in pips
extern int Slippage=2;                 //Slippage in pips
extern int MagicNumber=0;              //Magic number if you want to specify one
extern string Cmt="";                  //Comment for the order if you want one

//Function to normalize the digits
double CalculateNormalizedDigits()
{
   if(Digits<=3){
      return(0.01);
   }
   else if(Digits>=4){
      return(0.0001);
   }
   else return(0);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
   //If Stop Loss is not set and risk % is in use stop the program, the stop loss is required
   if(StopLoss==0 && UseRiskPercentage){
      Print("A stop loss is required if you are using a risk percentage");
      return;
   }
   
   int Cmd=Command;
   
   //Normalize the digits and calculate the position size
   double nTickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double nDigits=CalculateNormalizedDigits();
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
      nTickValue=nTickValue*10;
   }
   if(UseRiskPercentage){
      Lots=(AccountBalance()*RiskPercentage/100)/(StopLoss*nTickValue);
      Lots=MathRound(Lots/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
   }
   
   //Set the open, stop loss and take profit prices
   double OpenPrice=0;
   double TakeProfitPrice=0;
   double StopLossPrice=0;
   if(Cmd==OP_BUY){
      OpenPrice=NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),Digits);
      if(TakeProfit!=0) TakeProfitPrice=NormalizeDouble(OpenPrice+TakeProfit*nDigits,Digits);
      if(StopLoss!=0) StopLossPrice=NormalizeDouble(OpenPrice-StopLoss*nDigits,Digits);
   } 
   if(Cmd==OP_SELL){
      OpenPrice=NormalizeDouble(MarketInfo(Symbol(),MODE_BID),Digits);
      if(TakeProfit!=0) TakeProfitPrice=NormalizeDouble(OpenPrice-TakeProfit*nDigits,Digits);
      if(StopLoss!=0) StopLossPrice=NormalizeDouble(OpenPrice+StopLoss*nDigits,Digits);
   } 
   
   //Print on screen the informations to see what we are submitting
   Print("Opening an Order ",Command," size ",Lots, " open price ",OpenPrice," slippage ",Slippage," SL ",StopLossPrice," TP ",TakeProfitPrice," comment ",Cmt," magic ",MagicNumber);
   
   //Submit the order, check the it has been accepted
   int OrderNumber;
   OrderNumber=OrderSend(Symbol(),Cmd,Lots,OpenPrice,Slippage,StopLossPrice,TakeProfitPrice,Cmt,MagicNumber);
   if(OrderNumber>0){
      Print("Order ",OrderNumber," open");
   }
   else{
      Print("Order failed with error - ",GetLastError());
   }
   
  }
//+------------------------------------------------------------------+
