//+------------------------------------------------------------------+
//|                                             CloseOrders_v1-0.mq4 |
//|                                                    Luca Spinello |
//|                                https://mql4tradingautomation.com |
//+------------------------------------------------------------------+


#property copyright     "Luca Spinello - mql4tradingautomation.com"
#property link          "https://mql4tradingautomation.com"
#property version       "1.00"
#property strict
#property description   "This script allows you to close all or only the selected positions"
#property description   ""
#property description   ""
#property description   "DISCLAIMER: This script comes with no guarantee at all, you can use it at your own risk"
#property description   "We recommend to test it first on a Demo Account"


#property show_inputs

//Configure the external variables
extern bool OnlyCurrentSymbol=false;   //Close only instrument in the chart
extern bool OnlyInProfit=false;        //Close only orders in profit
extern bool OnlyInLoss=false;          //Close only orders in loss
extern bool OnlyMagicNumber=false;     //Close only orders matching the magic number
extern int MagicNumber=0;              //Matching magic number
extern bool OnlyWithComment=false;     //Close only orders with the following comment
extern string MatchingComment="";      //Matching comment
extern double Slippage=2;              //Slippage
extern int Delay=0;                    //Delay to wait between closing orders (in milliseconds)

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //Counter for orders closed
   int TotalClosed=0;
   
   //Normalization of the digits
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
   }
   
   //Scan the open orders backwards
   for(int i=OrdersTotal()-1; i>=0; i--){
   
      //Select the order, if not selected print the error and continue with the next index
      if( OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) == false ) {
         Print("ERROR - Unable to select the order - ",GetLastError());
         continue;
      } 
      
      //Check if the order can be closed matching the criteria, if criteria not matched skip to the next
      if(OnlyCurrentSymbol && OrderSymbol()!=Symbol()) continue;
      if(OnlyInProfit && OrderProfit()<=0) continue;
      if(OnlyInLoss && OrderProfit()>=0) continue;
      if(OnlyMagicNumber && OrderMagicNumber()!=MagicNumber) continue;
      if(OnlyWithComment && StringCompare(OrderComment(),MatchingComment)!=0) continue;
      
      //Prepare the close price
      double ClosePrice=0;
      RefreshRates();
      if(OrderType()==OP_BUY) ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),Digits);
      if(OrderType()==OP_SELL) ClosePrice=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),Digits);
         
      //Try to close the order
      if(OrderClose(OrderTicket(),OrderLots(),ClosePrice,Slippage,CLR_NONE)){
         TotalClosed++;
      }
      else{
         Print("Order failed to close with error - ",GetLastError());
      }      
      
      //Wait a delay
      Sleep(Delay);
   
   }
   
   //Print the total of orders closed
   Print("Total orders closed = ",TotalClosed);
   
  }
//+------------------------------------------------------------------+
