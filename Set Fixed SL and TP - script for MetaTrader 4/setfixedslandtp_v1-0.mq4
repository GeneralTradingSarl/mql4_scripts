//+------------------------------------------------------------------+
//|                                         SetFixedSLandTP_v1-0.mq4 |
//|                                                    Luca Spinello |
//|                                https://mql4tradingautomation.com |
//+------------------------------------------------------------------+


#property copyright     "Luca Spinello - mql4tradingautomation.com"
#property link          "https://mql4tradingautomation.com"
#property version       "1.00"
#property strict
#property description   "This script sets a stop loss and if required a take profit to all the open orders in the "
#property description   "instrument of the chart"
#property description   " "
#property description   "DISCLAIMER: This script comes with no guarantee, you can use it at your own risk"
#property description   "We recommend to test it first on a Demo Account"

#property show_inputs

//Configure the external variables
extern int TakeProfit=40;              //Take Profit in pips
extern int StopLoss=20;                //Stop Loss in pips
extern bool OnlyMagicNumber=false;     //Modify only orders matching the magic number
extern int MagicNumber=0;              //Matching magic number
extern bool OnlyWithComment=false;     //Modify only orders with the following comment
extern string MatchingComment="";      //Matching comment
extern double Slippage=2;              //Slippage
extern int Delay=0;                    //Delay to wait between modifying orders (in milliseconds)

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
   //Counter for orders modified
   int TotalModified=0;
   
   //Normalization of the digits
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
   }
   double nDigits=CalculateNormalizedDigits();
   
   //Scan the open orders backwards
   for(int i=OrdersTotal()-1; i>=0; i--){
   
      //Select the order, if not selected print the error and continue with the next index
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         continue;
      } 
      
      //Check if the order can be modified matching the criteria, if criteria not matched skip to the next
      if(OrderSymbol()!=Symbol()) continue;
      if(OnlyMagicNumber && OrderMagicNumber()!=MagicNumber) continue;
      if(OnlyWithComment && StringCompare(OrderComment(),MatchingComment)!=0) continue;
      
      //Prepare the prices
      double TakeProfitPrice=0;
      double StopLossPrice=0;
      double OpenPrice=OrderOpenPrice();
      RefreshRates();
      if(OrderType()==OP_BUY){
         TakeProfitPrice=NormalizeDouble(OpenPrice+TakeProfit*nDigits,Digits);
         StopLossPrice=NormalizeDouble(OpenPrice-StopLoss*nDigits,Digits);
      } 
      if(OrderType()==OP_SELL){
         TakeProfitPrice=NormalizeDouble(OpenPrice-TakeProfit*nDigits,Digits);
         StopLossPrice=NormalizeDouble(OpenPrice+StopLoss*nDigits,Digits);      
      }
         
      //Try to modify the order
      if(OrderModify(OrderTicket(),OpenPrice,StopLossPrice,TakeProfitPrice,0,clrNONE)){
         TotalModified++;
      }
      else{
         Print("Order failed to update with error - ",GetLastError());
      }      
      
      //Wait a delay
      Sleep(Delay);
   
   }
   
   //Print the total of orders modified
   Print("Total orders modified = ",TotalModified);
   
  }
//+------------------------------------------------------------------+
