#property copyright "Copyright © 2010, Khlystov Vladimir"
#property link      "cmillion@narod.ru"
#property show_inputs
//--------------------------------------------------------------------
extern int     stoploss    = 0,
               takeprofit  = 0,
               Magic       = 123456;
extern bool    SELL        = false,
               BUY         = false;
extern double  Lot         = 0.1;
extern int     slippage    = 3;
//--------------------------------------------------------------------
double SL,TP;
//--------------------------------------------------------------------
int start()
{
   if (BUY)
   {
      if (takeprofit!=0) TP  = Ask + takeprofit*Point; else TP=0;
      if (stoploss!=0)   SL  = Ask - stoploss*Point; else SL=0;     
      OPENORDER ("Buy");
   }
   if (SELL)
   {  
      if (takeprofit!=0) TP = Bid - takeprofit*Point; else TP=0;
      if (stoploss!=0)   SL = Bid + stoploss*Point;  else SL=0;              
      OPENORDER ("Sell");
   }
return(0);
}
//--------------------------------------------------------------------
void OPENORDER(string ord)
{
   int error,err;
   while (true)
   {  error=true;
      if (ord=="Buy" ) error=OrderSend(Symbol(),OP_BUY, Lot,Ask,slippage,SL,TP,"",Magic,3,Blue);
      if (ord=="Sell") error=OrderSend(Symbol(),OP_SELL,Lot,Bid,slippage,SL,TP,"",Magic,3,Red);
      if (error==-1)
      {  
         ShowERROR();
         err++;Sleep(2000);RefreshRates();
      }
      if (error || err >10) return;
   }
return;
}                  
//--------------------------------------------------------------------
void ShowERROR()
{
   int err=GetLastError();
   switch ( err )
   {                  
      case 1:   return;
      default:  Alert("Error  " ,err," ",Symbol());return;
   }
}
//--------------------------------------------------------------------

