//+------------------------------------------------------------------+
//|                                     OpenOrderMarketExecution.mq4 |
//|                              Copyright © 2010, Khlystov Vladimir |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Khlystov Vladimir"
#property link      "http://cmillion.narod.ru"
#property show_inputs
//--------------------------------------------------------------------
extern int     stoploss       = 50,    // level of exhibiting SL, if 0, then SL is not exposed 
               takeprofit     = 50,    // level of exhibiting TP, if 0, then TP is not exposed 
               Magic          = 777;    // unique number of warrants 
extern bool    SELL           = true,  // open the warrant SELL 
               BUY            = true;  // open order BUY 
extern double  Lot            = 0.0;   // Order Quantity 
extern double  Risk           = 1;     //% which we are willing to risk, is applied at Lot = 0 
extern int     slippage       = 5;     // Maximum allowable deviation of the price for market orders 
extern bool    MarketExecution = true; // placed stop at the next tick
//--------------------------------------------------------------------
int start()
{
   string txt =StringConcatenate("OpenOrderMarketExecution Copyright © 2010, http://cmillion.narod.ru  time ",
   TimeToStr(TimeCurrent(),TIME_MINUTES),"\n","-------------------------------------","\n");
   if (BUY ) txt =StringConcatenate(txt,"Open BUY    SL = ",DoubleToStr(Bid - stoploss*Point,Digits),
   "   TP = ",DoubleToStr(Ask + takeprofit*Point,Digits),"\n");
   if (SELL) txt =StringConcatenate(txt,"Open SELL   SL = ",DoubleToStr(Ask + stoploss*Point,Digits),
   "   TP = ",DoubleToStr(Bid - takeprofit*Point,Digits),"\n");
   double MinLot = MarketInfo(Symbol(),MODE_MINLOT);
   double Maxlot = MarketInfo(Symbol(),MODE_MAXLOT);
   int OkrLOT;
   if (MinLot==0.01) OkrLOT = 2;
   if (MinLot >0.01) OkrLOT = 1;
   if (MinLot >0.1 ) OkrLOT = 0;
   if (Lot==0) 
   if (stoploss==0) {Comment("stoploss can not be 0");return;} 
   else Lot = NormalizeDouble(AccountFreeMargin()*Risk/100/MarketInfo(Symbol(),MODE_TICKVALUE)/stoploss,OkrLOT);
   if (Lot<MinLot) {Lot=MinLot;txt =StringConcatenate(txt,"Featured min ");}
   if (Lot>Maxlot) {Lot=Maxlot;txt =StringConcatenate(txt,"Featured max ");}
   txt =StringConcatenate(txt,"Lot = ",Lot);
   Comment(txt);
   //---
   double SL,TP;
   if (BUY)
   {
      if (takeprofit!=0) TP  = NormalizeDouble(Ask + takeprofit*Point,Digits); else TP=0;
      if (stoploss!=0)   SL  = NormalizeDouble(Bid - stoploss*Point,Digits); else SL=0;     
      OPENORDER (1,SL,TP);
   }
   if (SELL)
   {  
      if (takeprofit!=0) TP = NormalizeDouble(Bid - takeprofit*Point,Digits); else TP=0;
      if (stoploss!=0)   SL = NormalizeDouble(Ask + stoploss*Point,Digits);  else SL=0;              
      OPENORDER (-1,SL,TP);
   }
   while(MarketExecution)
   {
      if (stoploss==0 && takeprofit==0) break;
      else
      {
         if (SetStop()==0) break;
      }
   }
return(0);
}
//--------------------------------------------------------------------
void OPENORDER(int ord,double SL,double TP)
{
   int error,err;
   if (MarketExecution) {SL=0;TP=0;}
   while (true)
   {  error=true;
      if (ord== 1) error=OrderSend(Symbol(),OP_BUY, Lot,NormalizeDouble(Ask,Digits),
                     slippage,SL,TP,"BUY",Magic,0,Blue);
      if (ord==-1) error=OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),
                     slippage,SL,TP,"SELL",Magic,0,Red);
      if (error==-1)
      {  
         Print(Symbol()," ",ShowERROR());
         err++;Sleep(2000);RefreshRates();
      }
      if (error || err >10) return;
   }
return;
}                  
//--------------------------------------------------------------------
string ShowERROR()
{
   int err=GetLastError();
   string com;
   switch ( err )
   {                  
      case 0:   return;
      case 1:   return;
      case 2:   com=StringConcatenate(com," No connection with trade server ");break;
      case 3:   com=StringConcatenate(com," Incorrect parameters            ");break;
      case 130: com=StringConcatenate(com," Relation of the foot            ");break;
      case 134: com=StringConcatenate(com," enough money                    ");break;
      case 136: com=StringConcatenate(com," No price                        ");break;
      case 146: com=StringConcatenate(com," The subsystem is busy trade     ");break;
      case 129: com=StringConcatenate(com," Incorrect Price                 ");break;
      case 131: com=StringConcatenate(com," Invalid size                    ");break;
      case 137: com=StringConcatenate(com," broker is busy                  ");break;
      case 138: com=StringConcatenate(com," New prices                      ");break;
      default:  com=StringConcatenate(com," Error " ,err);break;
   }
   return(com);
}
//--------------------------------------------------------------------
int SetStop()
{  int tip,Ticket,n=0;
   double SL,TP;
   double OOP;bool error;
   int SPREAD = MarketInfo(Symbol(),MODE_SPREAD);
   for (int i=0; i<OrdersTotal(); i++) 
   {  if (OrderSelect(i, SELECT_BY_POS)==true)
      {  tip = OrderType();
         if (tip<2 && OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         {
            if ((OrderStopLoss()==0&&stoploss!=0)||(OrderTakeProfit()==0&&takeprofit!=0))
            {  
               OOP   = OrderOpenPrice();
               Ticket = OrderTicket();
               if (tip==OP_BUY)             
               {
                  if (takeprofit!=0) TP = NormalizeDouble(OOP + takeprofit*Point,Digits); else TP=0;
                  if (stoploss!=0)   SL = NormalizeDouble(OOP - (stoploss+SPREAD)* Point,Digits); else SL=0;       
                  error=OrderModify(Ticket,OOP,SL,TP,0,White);
                  if (error) Print("SetStop ",Ticket," ",TimeToStr(TimeCurrent(),TIME_MINUTES));
                  else {Print(Symbol()," ",ShowERROR());n++;}
               }                                         
               if (tip==OP_SELL)        
               {
                  if (takeprofit!=0) TP = NormalizeDouble(OOP - takeprofit*Point,Digits); else TP=0;
                  if (stoploss!=0)   SL = NormalizeDouble(OOP + (stoploss+SPREAD)* Point,Digits); else SL=0;             
                  error=OrderModify(Ticket,OOP,SL,TP,0,White);
                  if (error) Print("SetStop ",Ticket," ",TimeToStr(TimeCurrent(),TIME_MINUTES));
                  else {Print(Symbol()," ",ShowERROR());n++;}
               } 
            }
         }
      }
   }
   return(n);
}
//--------------------------------------------------------------------