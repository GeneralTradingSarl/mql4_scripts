//+------------------------------------------------------------------+
//|                                             SCT_RiskPerTrade.mq4 |
//|                                        Copyright 2021, FxWeirdos |
//|                                               info@fxweirdos.com |
//+------------------------------------------------------------------+
#property copyright "Video tutorial"
#property link      "https://www.youtube.com/c/fxweirdos/videos"
#property version   "1.00"
#property strict
#property script_show_inputs

#property description "Copyright 2021, FxWeirdos. Mario Gharib. Forex Jarvis. info@fxweirdos.com"
#property description " "
#property description "RISK DISCLAIMER : Investing involves risks. Any decision to invest in either real estate or stock markets is a personal decision that should be made after thorough research, including an assessment of your personal risk tolerance and your personal financial condition and goals. Results are based on market conditions and on each personal and the action they take and the time and effort they put in"

#include <FxWeirdos\createObjects.mqh>    // Functions for creating objects
#include <FxWeirdos\pipValue.mqh>         // Functions for pip values

//--- Inputs
input color cRPTFontClr = C'255,166,36';  // Font color


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {

   double dRPTAmtRisking;           // Used to calculate the overall risk
   double dRPTAmtRewarding;         // Used to calculate the overall target      
   int kRPT;                        // Used to loop all open orders to get the overall risk
   string sRPTObjectName;           // To name the Objects
   
   //--- Delete these objects from chart 
   ObjectsDeleteAll(0);
   
   //--- Always reset these parameters at the beginning
  	dRPTAmtRisking=0.0;
  	dRPTAmtRewarding=0.0;
   sRPTObjectName="";
   
   //--- Loop all open orders in order to calculate the overall risk
	for (kRPT=0 ; kRPT<OrdersTotal() ; kRPT++) {
	   
      //--- Select the open order	   
		if (OrderSelect(kRPT,SELECT_BY_POS,MODE_TRADES)) {

         //--- Get the risks of Buys and Sells orders
   	   if (OrderGetInteger(ORDER_TYPE)==0 || OrderGetInteger(ORDER_TYPE)==1) {

            if (OrderSymbol()==Symbol()) {

               //--- Create SL object if it is not null               
               if(OrderStopLoss()!=0) {
               
                  //--- Name of the object SL Text
                  sRPTObjectName = ""; // This here is essential
                  sRPTObjectName = StringConcatenate(OrderTicket(),OrderStopLoss());
   
                  //--- Creation of the object SL Text
                  vSetText(0,sRPTObjectName,0,TimeCurrent(),OrderStopLoss(),8,cRPTFontClr,"SL: "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots())/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");// = "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots()),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
               
               }

               //--- Create TP object if it is not null               
               if (OrderTakeProfit()!=0) {
               
                  //--- Name of the object TP Text
                  sRPTObjectName = ""; // This here is essential
                  sRPTObjectName = StringConcatenate(OrderTicket(),OrderTakeProfit());
   
                  //--- Creation of the object TP Text
                  vSetText(0,sRPTObjectName,0,TimeCurrent(),OrderTakeProfit(),8,cRPTFontClr,"TP: "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots())/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");// = "+DoubleToString(dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots()),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));
               
               }

               //--- Add dRPTAmtRisking if SL is not null
               if(OrderStopLoss()!=0) {
               
      	         //--- Add the risk of this open order to the overall risk
         			dRPTAmtRisking =    dRPTAmtRisking +    dValuePips(OrderSymbol(), OrderOpenPrice(), OrderStopLoss(), OrderLots());
               }
               
               //--- Add dRPTAmtRewarding if TP is not null
               if (OrderTakeProfit()!=0) {
                                       			
      	         //--- Add the target of this open order to the overall target
         			dRPTAmtRewarding =  dRPTAmtRewarding +  dValuePips(OrderSymbol(), OrderOpenPrice(), OrderTakeProfit(), OrderLots());
         			
      			}      			
            }
   		}
   	}
   }

   //--- Hide the OneClick panel
   ChartSetInteger(0,CHART_SHOW_ONE_CLICK,false);

   //--- Create the RPTBalance, RPTTotalPercentRisked & RPTTotalPercentTarget objects
   vSetLabel(0, "RPTBalance",0,25,20,8,cRPTFontClr,"Balance: "+ DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2)+" "+AccountInfoString(ACCOUNT_CURRENCY));         
   vSetLabel(0, "RPTAllSymbolPercentRisked",0,45,20,8,cRPTFontClr,"All "+Symbol()+"'s % Risked : "+ DoubleToString(dRPTAmtRisking/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");
   vSetLabel(0, "RPTAllSymbolPercentTarget",0,65,20,8,cRPTFontClr,"All "+Symbol()+"'s % Target : "+ DoubleToString(dRPTAmtRewarding/AccountInfoDouble(ACCOUNT_BALANCE)*100,2)+"%");

}