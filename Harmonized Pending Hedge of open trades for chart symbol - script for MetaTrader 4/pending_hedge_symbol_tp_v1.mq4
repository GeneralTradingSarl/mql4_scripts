//+------------------------------------------------------------------+
//|                                   Pending_Hedge_Symbol_TP_V1.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| This script sets pending hedges with distance in pips for chart symbol.
//| If hedged are 100% harmonized strategy will do nothing,
//| else calculates difference between Buy and Sell Trades and places a harmonized pending hedge 100%.
//| Deletes old hedges for symbol and places new ones.
//| This way can be used as manual trailing pending hedges, when desired.
//| I use this strategy often, so I consider is useful enough to share it with you. 
//+------------------------------------------------------------------+


#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "Harmonized Hedge  of open trades for chart symbol"
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs
#property script_show_inputs


extern int     Distance = 20 ;
extern int     TP       = 0;
extern int     SL       = 0;
double         Pip      = Point * 10; 
double         DIGITS = MarketInfo(OrderSymbol(),MODE_DIGITS);
int N                    = 1  ;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(IsTradeAllowed())
     {
      int pick = MessageBox("Pending Hedge ="+DoubleToString(Distance,0)+" Pips","Symbol",0x00000001);
      if(pick==1)
         for(int i =0 ; i<1; i++)
           star();

     }
   else
      MessageBox("Enable AutoTrading Please ");

  }

void star()
  {
  for(int Simple=OrdersTotal()-1; Simple>=0; Simple--){
   if(OrderSelect(Simple, SELECT_BY_POS==true, MODE_TRADES)){
   if(OrderSymbol()== Symbol()){
   if(OrderType()==OP_BUYLIMIT){int OP_BuyLimit = OrderDelete(OrderTicket());}
   if(OrderType()==OP_BUYSTOP){int OP_BuyStop = OrderDelete(OrderTicket());}
   if(OrderType()==OP_SELLLIMIT){int OP_SellLimit = OrderDelete(OrderTicket());}
   if(OrderType()==OP_SELLSTOP){int OP_SellStop = OrderDelete(OrderTicket());}}}}

	if (Symbol()=="AUDCNH" || Symbol()=="AUDZAR" || Symbol()=="CHFZAR" || Symbol()=="EURCNH" 
	 || Symbol()=="EURHKD" || Symbol()=="EURSEK" || Symbol()=="USDCNH" || Symbol()=="USDDKK"
	 || Symbol()=="USDNOK" || Symbol()=="USDSEK" || Symbol()=="EURCZK" || Symbol()=="EURNOK"
	 || Symbol()=="EURTRY" || Symbol()=="GBPNOK" || Symbol()=="GBPSEK" || Symbol()=="NZDSEK"
	 || Symbol()=="USDCZK" || Symbol()=="USDMXN" || Symbol()=="USDTRY" || Symbol()=="USDZAR"
	){N=10;} 


  stat();
  }//end void start

void stat()
  {
  double LotsBuy_symbol = 0.0;
  double LotsSell_symbol = 0.0;
  double loss_stop_sell = 0.0;
  double profit_stop_sell = 0.0;
  double loss_stop_buy = 0.0;
  double profit_stop_buy = 0.0;
  double Lot_SELL = 0.0;
  double Lot_BUY = 0.0;
  double SELL = 0.0;
  double BUY = 0.0;
  
  
  for(int symbol_t=OrdersTotal()-1; symbol_t>=0; symbol_t--){
  if(OrderSelect(symbol_t, SELECT_BY_POS==true, MODE_TRADES)){
  if(OrderSymbol()== Symbol()){
   if(OrderType()==OP_BUY){ND(LotsBuy_symbol+=OrderLots());}
   if(OrderType()==OP_SELL){ND(LotsSell_symbol+=OrderLots());}
   
   Lot_SELL = LotsBuy_symbol -LotsSell_symbol;
   Lot_BUY  = LotsSell_symbol-LotsBuy_symbol ;
   }}}

   if (SL>0){loss_stop_sell   = ND(Bid+(Pip*N*(Distance+SL)));}  
   if (TP>0){profit_stop_sell = ND(Bid-(Pip*N*(Distance+TP)));} 
   if (SL>0){loss_stop_buy    = ND(Ask-(Pip*N*(Distance+SL)));} 
   if (TP>0){profit_stop_buy  = ND(Ask+(Pip*N*(Distance+TP)));} 
   
   BUY = ND(Bid-(Pip*N* Distance));
   SELL = ND(Bid+(Pip*N* Distance));
   
  if(Lot_SELL>Lot_BUY){
   int OP_Sell_symbol = OrderSend(Symbol(),OP_SELLSTOP,Lot_SELL,BUY,20,loss_stop_sell,profit_stop_sell,"Sell_Stop",0,0,clrNONE);
   PlaySound("Sell_Stop_Order.wav"); return;}
else if(Lot_BUY>Lot_SELL){
   int OP_Buy_symbol = OrderSend(Symbol(),OP_BUYSTOP,Lot_BUY,SELL,20,loss_stop_buy,profit_stop_buy,"Buy_Stop",0,0,clrNONE);
   PlaySound("Buy_Stop_Order.wav");return;}
}

double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
