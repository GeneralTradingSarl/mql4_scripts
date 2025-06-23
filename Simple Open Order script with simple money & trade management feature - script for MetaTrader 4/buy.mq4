//+------------------------------------------------------------------+
//|                                                          BUY.mq4 |
//|                                        Copyright 2020, FXMaximus |
//|                                        https://www.fxmaximus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
//--- input parameters

input int SL_pips=20;
input int TP_pips=60;
input double perc_to_loose=1;
input double perc_to_close_at_breakeven = 0.7;

void OnStart(){
   double lotsize = Lots(SL_pips, perc_to_loose);
   
   double order1_lots = NormalizeDouble(lotsize*perc_to_close_at_breakeven,2);
   double order2_lots= NormalizeDouble(lotsize*(1-perc_to_close_at_breakeven),2);
   
   double SL_price = Ask-(SL_pips*10*Point);
   double TP_Order1 = Ask+(SL_pips*10*Point);
   double TP_Order2 = Ask+(TP_pips*10*Point);
   
   int status1, status2;
   status1 = OrderSend(Symbol(),OP_BUY,order1_lots,Ask,3,SL_price, TP_Order1, "Order1: 70% Lotsize",0,0,Blue);
   status2 = OrderSend(Symbol(),OP_BUY,order2_lots,Ask,3,SL_price, TP_Order2, "Order2: 30% Lotsize",0,0,Blue);
   
   if(status1<0)
     {
      Print("OrderSend failed with error #",GetLastError());
     }
   else
      Alert("Order 1: ", order1_lots, " SL: ", SL_pips, " TP: ", SL_pips, " Price: ", Ask, " SL:", SL_price, " TP:", TP_Order1);
   
   if(status2<0)
     {
      Print("OrderSend failed with error #",GetLastError());
     }
   else
      Alert("Order 2: ", order2_lots, " SL: ", SL_pips, " TP: ", TP_pips, " Price: ", Ask, " SL:", SL_price, " TP:", TP_Order2);
}


double Lots(double sl,double risk){
   double lot_size=0;
   
        
   string symbol_currency_right=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT);
   string symbol_currency_left=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE);
   string acc_currency=AccountCurrency();
   
   double money_risk=AccountBalance()*(risk/100);
   double dix=Point*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*10;
   
   
   //DIRECT RATES
   if(symbol_currency_right==acc_currency){//XXXGBP 
      lot_size=money_risk/(dix*sl);
      }
   //INDIRECT RATES
   else if(acc_currency==symbol_currency_left){//GBPXXX
      lot_size=money_risk*Ask/(dix*sl);
      }
   //CROSS RATES
   else if(acc_currency!=symbol_currency_left&&acc_currency!=symbol_currency_right){///XXX XXX
      string symbol_2=StringConcatenate(symbol_currency_left,acc_currency);
      SymbolSelect(symbol_2,true);
      
      double r__2=SymbolInfoDouble(symbol_2,SYMBOL_ASK);
      
      if(r__2==0){
         symbol_2=StringConcatenate(acc_currency,symbol_currency_left);
         SymbolSelect(symbol_2,true);
         r__2=SymbolInfoDouble(symbol_2,SYMBOL_ASK);
         
         }
         
      lot_size=Ask*money_risk/(dix*sl*r__2);
      }
   
   return(NormalizeDouble(lot_size,2));
}