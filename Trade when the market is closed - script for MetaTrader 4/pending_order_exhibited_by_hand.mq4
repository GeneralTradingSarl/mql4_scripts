//+------------------------------------------------------------------+
#property copyright "Copyright 2015, http://cmillion.ru"
#property link      "http://cmillion.ru"
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
enum t
  {
   L=0,     //buy
   S=1,     //sell
  };
input t        O                    = L;      //trading transaction
extern double  Lot                  = 0.1;    //lot
extern int     Stoploss             = 0,      //stoploss, 0 Ц disabled
               Takeprofit           = 40;     //takeprofit, 0 Ц disabled
extern int     TrailingStop         = 15;     //length of trailing, 0 Ц disabled
extern int     TrailingStart        = 0;      //the minimum profit necessary to start trailing: for example, trailing can be enabled upon reaching a profit of 40 points
extern int     TrailingStep         = 1;      //trailing step
extern string  TimeStart            = "00:01";//time of placing an order
extern int     Magic                = 0;      //magic number
int     slippage=30;
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!IsExpertEnabled()) {Comment("Enable Auto Trading and launch the script again");return;}
   double STOPLEVEL,OSL,OTP,StLo,OOP,SL,TP;
   int n=0,OT;
   string txt=StringConcatenate("\nstoploss = ",Stoploss,"\n",
                                "takeprofit = ",Takeprofit,"\n",
                                "length of trailing = ",TrailingStop,"\n",
                                "minimum profit = ",TrailingStart,"\n",
                                "trailing step = ",TrailingStep,"\n");
   while(!IsStopped())
     {
      RefreshRates();
      STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
      n=0;
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol() && Magic==OrderMagicNumber())
              {
               OT=OrderType();
               OSL = NormalizeDouble(OrderStopLoss(),Digits);
               OTP = NormalizeDouble(OrderTakeProfit(),Digits);
               OOP = NormalizeDouble(OrderOpenPrice(),Digits);
               SL=OSL;TP=OTP;
               if(OT==OP_BUY)
                 {
                  if(Stoploss!=0   && Bid<=OOP - Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Bid>=OOP + Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP-Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP+Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (Bid-OOP)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Bid-TrailingStop*Point,Digits);
                     if(StLo>=OOP && StLo>OSL+TrailingStep*Point) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
               if(OT==OP_SELL)
                 {
                  if(Stoploss!=0   && Ask>=OOP + Stoploss   * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  if(Takeprofit!=0 && Ask<=OOP - Takeprofit * Point) {if(OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),slippage,clrNONE)) continue;}
                  n++;
                  if(OSL==0 && Stoploss>=STOPLEVEL && Stoploss!=0)
                    {
                     SL=NormalizeDouble(OOP+Stoploss  *Point,Digits);
                    }
                  if(OTP==0 && Takeprofit>=STOPLEVEL && Takeprofit!=0)
                    {
                     TP=NormalizeDouble(OOP-Takeprofit*Point,Digits);
                    }
                  if(TrailingStop>=STOPLEVEL && TrailingStop!=0 && (OOP-Ask)/Point>=TrailingStart)
                    {
                     StLo=NormalizeDouble(Ask+TrailingStop*Point,Digits);
                     if(StLo<=OOP && (StLo<OSL-TrailingStep*Point || OSL==0)) SL=StLo;
                    }
                  if(SL!=OSL || TP!=OTP)
                    {
                     if(!OrderModify(OrderTicket(),OOP,SL,TP,0,clrNONE)) Print("Error OrderModify <<",GetLastError(),">> ");
                    }
                 }
              }
           }
        }
      if(Lot!=0)
        {
         if(O==0) Comment("The script  ",WindowExpertName(),"\nTime of the last quote ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"\nmanages ",n," ord.\n","\nBuy ",TimeStart);
         if(O==1) Comment("The script  ",WindowExpertName(),"\nTime of the last quote ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"\nmanages ",n," ord.\n","\nSell ",TimeStart);
        }
      else Comment("The script  ",WindowExpertName(),"\nTime of the last quote ",TimeToStr(TimeCurrent(),TIME_SECONDS),txt,"\nmanages ",n," орд.\n");

      if(Lot==0 && n==0) {Comment("The script  ",WindowExpertName()," has finished operations ",TimeToStr(TimeCurrent(),TIME_SECONDS));return;}

      if(TimeCurrent()>=StrToTime(TimeStart))
        {
         if(O==0) if(OrderSend(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
         if(O==1) if(OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),slippage,0,0,NULL,Magic,0,CLR_NONE)!=-1) Lot=0;
        }
     }
  }
//+------------------------------------------------------------------+
