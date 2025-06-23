//+------------------------------------------------------------------+
//|                                  Buy_with_SellStop_20_Symbol.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "Buy with Sell Stop Hedge for chart symbol"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs
#property script_show_inputs


extern int    Distance           = 20 ;
extern int    TP                 = 0;
extern int    SL                 = 0;
extern int    TP_Stop_ORD        = 0;
extern int    SL_Stop_ORD        = 0;
extern double Lot                = 0.10; 
//01.00 = 1 Standard Lot $100.000

int    N = 1  ;

#property script_show_inputs

void OnStart()
  {
  if(IsTradeAllowed()){star();}
   else MessageBox("Enable AutoTrading Please ");
  }

void star()
  {
	if (Symbol()=="AUDCNH" || Symbol()=="AUDZAR" || Symbol()=="CHFZAR" || Symbol()=="EURCNH" 
	 || Symbol()=="EURHKD" || Symbol()=="EURSEK" || Symbol()=="USDCNH" || Symbol()=="USDDKK"
	 || Symbol()=="USDNOK" || Symbol()=="USDSEK" || Symbol()=="EURCZK" || Symbol()=="EURNOK"
	 || Symbol()=="EURTRY" || Symbol()=="GBPNOK" || Symbol()=="GBPSEK" || Symbol()=="NZDSEK"
	 || Symbol()=="USDCZK" || Symbol()=="USDMXN" || Symbol()=="USDTRY" || Symbol()=="USDZAR"
	){N=10;} else N=1;

   double Pip                  = Point * 10; 
   double loss                 = 0;
   double profit               = 0;
   double loss_stop            = 0;
   double profit_stop          = 0;
   
   if (SL>0){loss   = ND(Ask-(Pip*N*TP));} else if (SL==0){loss=0;} 
   if (TP>0){profit = ND(Ask+(Pip*N*TP));} else if (TP==0){profit=0;}

   int OP_Buy_symbol  = OrderSend(Symbol(),OP_BUY,Lot,0,20,loss,profit,"Buy",0,0,clrNONE);


   if (SL_Stop_ORD>0){loss_stop   = ND(Bid+(Pip*N*(Distance-SL_Stop_ORD)));} else if (SL_Stop_ORD==0){loss_stop=0;  } 
   if (TP_Stop_ORD>0){profit_stop = ND(Bid-(Pip*N*(Distance+TP_Stop_ORD)));} else if (TP_Stop_ORD==0){profit_stop=0;}
 
   int OP_Sell_symbol = OrderSend(Symbol(),OP_SELLSTOP,Lot,
   ND(Bid-(Pip*N* Distance)),20,loss_stop,profit_stop,"Sell_Stop",0,0,clrNONE);

  }//end void start

   double ND(double val) {return(NormalizeDouble(val, Digits));}

