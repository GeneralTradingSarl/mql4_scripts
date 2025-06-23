//+------------------------------------------------------------------+
//|                                      XIT_BuySellAutoStoploss.mq4  |
//|                         Copyright © 2011, Jeff West - Forex-XIT  |
//|                                        http://www.forex-xit.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Jeff West - Forex-XIT"
#property link      "http://www.forex-xit.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
#property show_inputs
#include <WinUser32.mqh>        

      extern bool   BUY           = false, // Buy if true
                    SELL          = false;
                    
                    
      extern int    Risk          = 2,     // Amount of account balance to risk per trade. 
                    Reward        = 2,     // Multiply stoploss by this to get takeprofit value
                    StopAdd       = 10,
                    MaxSlip       = 3,     // Max price slippage when order is placed
                    MaxSpread     = 6,    // Max spread
                    Magic         = 0;  // Magic number for trade, 0 if none
                    
int    ordDigits,ordSpread,ordLotsize,ordPeriod,ordMagic,ordVolume,Ordlotdigits,ordReward,ordLotcalstop,ordLeverage
       ,riskLevel,ordStopvalue,i,ordBuySell,ordError,errorReturn,traderError;
double ordPoint,ordMinlot,ordLotstep,ordAsk,ordBid,ordAccountbalance,ordMarginrequired,ordMinstop,ordTickvalue,
       ordTicksize,ordSpreaddigits,ordFreemargin,ordAccountmargin,ordRisk,ordLot,ordPlacestop,ordPlacetake,ordFrac,ordEnter,
       ordStopadd;
string ordSymbol,ordTimeframe,ordLotcomment,ordLotComm,ordComment,sayIfbulsell;
bool   ordTradeallowed,ordOpentrade;
color  buyColor;
////////////////////////////////////////////////////////
////   All account information
///////////////////////////////////////////////////////
void allInfo(){
ordAccountbalance  = NormalizeDouble(AccountBalance(),2);
ordLeverage        = AccountLeverage();
ordFreemargin      = NormalizeDouble(AccountFreeMargin(),2);
ordAccountmargin   = NormalizeDouble(AccountMargin(),2);
ordSymbol          = Symbol();
ordPeriod          = Period();
ordSpread          = MarketInfo(ordSymbol,MODE_SPREAD);
ordDigits          = MarketInfo(ordSymbol,MODE_DIGITS);
ordPoint           = MarketInfo(ordSymbol,MODE_POINT);
ordMinlot          = MarketInfo(ordSymbol,MODE_MINLOT);
ordLotstep         = MarketInfo(ordSymbol,MODE_LOTSTEP);
ordMarginrequired  = NormalizeDouble(MarketInfo(ordSymbol,MODE_MARGINREQUIRED),2);
ordMinstop         = NormalizeDouble(MarketInfo(ordSymbol,MODE_STOPLEVEL),ordDigits);
ordLotsize         = MarketInfo(ordSymbol,MODE_LOTSIZE);
ordTickvalue       = MarketInfo(ordSymbol,MODE_TICKVALUE);
ordTicksize        = NormalizeDouble(MarketInfo(ordSymbol,MODE_TICKSIZE),ordDigits);
ordAsk             = NormalizeDouble(MarketInfo(ordSymbol,MODE_ASK),ordDigits);
ordBid             = NormalizeDouble(MarketInfo(ordSymbol,MODE_BID),ordDigits);
ordSpreaddigits    = NormalizeDouble(ordSpread*ordPoint,ordDigits);
ordTradeallowed    = MarketInfo(ordSymbol,MODE_TRADEALLOWED);
}  

void ordPlace(){
RefreshRates();
OrderSend(ordSymbol,ordBuySell,ordLot,ordEnter,MaxSlip,ordPlacestop,ordPlacetake,ordComment,Magic,0,buyColor);
}             
                
int start(){
//----
allInfo(); 

switch(ordPeriod){
case PERIOD_M1 : ordTimeframe = " Chart M1 " ;break;
case PERIOD_M5 : ordTimeframe = " Chart M5 " ;break;
case PERIOD_M15: ordTimeframe = " Chart M15 ";break;
case PERIOD_M30: ordTimeframe = " Chart M30 ";break;
case PERIOD_H1 : ordTimeframe = " Chart H1 " ;break;
case PERIOD_H4 : ordTimeframe = " Chart H4 " ;break;
case PERIOD_D1 : ordTimeframe = " Chart D1 " ;break;
case PERIOD_W1 : ordTimeframe = " Chart W1 " ;break;
case PERIOD_MN1: ordTimeframe = " Chart MN1 ";break;}

if(ordTradeallowed==true){
if(ordDigits == 3 || ordDigits == 5){StopAdd = StopAdd/0.1;}
ordStopadd = NormalizeDouble(StopAdd*ordPoint,ordDigits);

if(BUY==false && SELL==false){
traderError=MessageBox("Please select either BUY or SELL","BUY and SELL False.", MB_OK|MB_ICONEXCLAMATION);
if(traderError==IDOK){return(0);}
}

if(BUY==true && SELL==true){
traderError=MessageBox("Please select either BUY or SELL","BUY and SELL True.", MB_OK|MB_ICONEXCLAMATION);
if(traderError==IDOK){return(0);}
}

if(BUY == true){
// buy stop
for(i=1; i<=200; i++){
if (iFractals(ordSymbol,ordPeriod,MODE_LOWER,i) > 0){
ordFrac=iFractals(ordSymbol,ordPeriod,MODE_LOWER,i);
string ordFracstr = DoubleToStr(ordFrac,ordDigits);
int ordOKfrac =MessageBox(ordFracstr,"Place your stop at", MB_YESNO|MB_ICONQUESTION);
if(ordOKfrac==IDNO){continue;}
if(ordOKfrac==IDYES){break;}
  }
 }
 
ordPlacestop  = NormalizeDouble(ordFrac-ordSpreaddigits-ordStopadd,ordDigits);
ordPlacetake = NormalizeDouble((ordAsk-ordPlacestop)*Reward+(ordAsk),ordDigits);
ordEnter = ordAsk;
ordStopvalue = (ordAsk-ordPlacestop)/ordTicksize;
if(ordDigits == 3 || ordDigits == 5){ordStopvalue = ordStopvalue*0.1;}
buyColor = Green;
ordBuySell = 0;
sayIfbulsell = " BUY ";
ordOpentrade = true;
}

if(SELL == true){ 
// sell stop
for(i=1; i<=200; i++){
if (iFractals(ordSymbol,ordPeriod,MODE_UPPER,i) > 0){
ordFrac = iFractals(ordSymbol,ordPeriod,MODE_UPPER,i);
ordFracstr = DoubleToStr(ordFrac,ordDigits);
ordOKfrac =MessageBox(ordFracstr,"Place your stop at", MB_YESNO|MB_ICONQUESTION);
if(ordOKfrac==IDNO){continue;}
if(ordOKfrac==IDYES){break;}
 }
}
ordPlacestop = NormalizeDouble(ordFrac+ordSpreaddigits+ordStopadd,ordDigits);
ordPlacetake =NormalizeDouble((ordBid)-(ordPlacestop-ordBid)*Reward,ordDigits);
ordStopvalue = (ordPlacestop-ordBid)/ordTicksize;
if(ordDigits == 3 || ordDigits == 5){ordStopvalue = ordStopvalue*0.1;}
ordEnter = ordBid;
buyColor = Red;
ordBuySell = 1;
sayIfbulsell = " SELL ";
ordOpentrade = true;
}

//Lot calculations
switch(ordMinlot){
case 1.0:   Ordlotdigits=0; break;           
case 0.1:   Ordlotdigits=1; break;           
case 0.01:  Ordlotdigits=2; break;           
default:    Ordlotdigits=1; break;}

ordRisk = Risk*0.01;
ordLeverage = ordLeverage*0.1;
ordLot = NormalizeDouble((ordFreemargin*ordRisk/ordStopvalue)/(ordLeverage/ordTickvalue),Ordlotdigits);  

if(ordLot<ordMinlot){
ordLot=ordMinlot;
riskLevel=MessageBox("You are risking more than "+Risk+"%","Continue Trade?", MB_YESNO);
if(riskLevel==IDYES){RefreshRates();
 }else if(riskLevel==IDNO){return(0);}
}

ordLotComm=ordLot;
ordLotcomment = StringSetChar(ordLotComm,4,0);
ordComment = sayIfbulsell+ordLotcomment+ordTimeframe;

if(ordOpentrade==true){
ordPlace();
}

ordError = GetLastError();
if(ordError>1){
switch(ordError){
case 129: ordPlace();break;
case 135: ordPlace();break;
case 136: ordPlace();break;
case 138: ordPlace();break;
case 2  : errorReturn=MessageBox("Resend order","Trade server is busy.", MB_RETRYCANCEL|MB_ICONQUESTION);if(errorReturn==IDRETRY){ordPlace();}if(errorReturn==IDCANCEL){return(0);} break;
case 128: errorReturn=MessageBox("Resend order?","Trade timeout.",  MB_RETRYCANCEL|MB_ICONQUESTION);if(errorReturn==IDRETRY){ordPlace();}if(errorReturn==IDCANCEL){return(0);} break;
case 137: errorReturn=MessageBox("Resend order?","Broker is busy.",  MB_RETRYCANCEL|MB_ICONQUESTION);if(errorReturn==IDRETRY){ordPlace();}if(errorReturn==IDCANCEL){return(0);} break;
case 5  : errorReturn=MessageBox("Update your software to latest build.","Old version of the client terminal.", MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 7  : errorReturn=MessageBox("You are not able to make this trade!","Not enough rights.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 8  : errorReturn=MessageBox("Wait a few minutes before trying again!","Too frequent requests.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 64 : errorReturn=MessageBox("Contact your broker support team!","Account disabled.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 65 : errorReturn=MessageBox("Check your login details!","Invalid account.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 130: errorReturn=MessageBox("Move your stop level higer / lower!","Invalid stops",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 131: errorReturn=MessageBox("Check script. Lots are not being calculated correctly","Invalid trade volume.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 132: errorReturn=MessageBox("Trade when markets open.","Market is closed.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 133: errorReturn=MessageBox("You are not currently able to trade.","Trade is disabled.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 134: errorReturn=MessageBox("Reduce your risk to make this trade.","Not enough money.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 141: errorReturn=MessageBox("Try again later!","Too many requests.",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 148: errorReturn=MessageBox("The amount of open and pending orders has reached the limit set by the broker.","Order limit reached",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
case 149: errorReturn=MessageBox("Broker does not allow hedging.","Hedging is disabled",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
default : errorReturn=MessageBox("Please try running script again.","An error occured",  MB_OK|MB_ICONSTOP);if(errorReturn==IDOK){return(0);} break;
 }
}
}else{Alert("You can not trade this pair!!");}
//----
   return(0);
  }
//+------------------------------------------------------------------+