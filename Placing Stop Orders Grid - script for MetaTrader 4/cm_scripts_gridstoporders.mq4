//+------------------------------------------------------------------+
//|                                    cm_scripts_gridstoporders.mq4 |
//|                                Copyright 2015, cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, cmillion@narod.ru"
#property link      "’лыстов ¬ладимир"
#property version   "1.00"
#property strict
//---
#property show_inputs
//---
#property description "—крипт определ€ет цену в точке графика, в которую он был брошен, и в зависимости от этого строит сеть отложенных ордеров."
#property description "≈сли указанна€ цена ниже текущей цены, то скрипт ставит Sell и ниже сеть Sell Stop, если выше, то ставит Buy и выше сеть Buy Stop."
//---
extern int      Step           = 30;       //рассто€ние (в пунктах) между ордерами
extern int      Orders         = 5;        //кол-во ордеров сетки
extern double   Lot            = 0.1;      //объем первого Stop ордера
extern double   K_Lot          = 1;        //умножение лота Stop ордеров 
extern double   PlusLot        = 0.1;      //прибавл€ть это значение к лоту последующих ордеров
extern int      DigitsLot      = 2;        //округление значени€ лота
extern int      stoploss       = 50;       //уровень выставлени€ SL, если 0, то SL не выставл€етс€
extern int      takeprofit     = 100;      //уровень выставлени€ TP, если 0, то TP не выставл€етс€
extern int      Expiration     = 1440;     //—рок истечени€ отложенного ордера в минутах, если 0, то срок не ограничен (1440 - сутки)
extern int      attempts       = 10;       //кол-во попыток открыти€ ордера 
extern int      Magic          = 0;        //уникальный номер ордера
//---
string txt;
int n,slippage=3;
datetime expiration;
double STOPLEVEL;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(Expiration>0) expiration=TimeCurrent()+Expiration*60; else expiration=0;
   Comment("«апуск скрипта ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\nCopyright © 2015 cmillion@narod.ru");
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(Digits==3 || Digits==5) slippage=30;
   double Price;
   double LOT=Lot;
//---
   Price=NormalizeDouble(WindowPriceOnDropped(),Digits);
   int i;
//---
   if(Price>Ask)
     {
      Price=NormalizeDouble(Ask,Digits);
      OPENORDER(OP_BUY,Price,LOT);
      for(i=1; i<=Orders; i++)
        {
         Price=NormalizeDouble(Price+Step*Point,Digits);
         LOT=NormalizeDouble(LOT*K_Lot+PlusLot,DigitsLot);
         OPENORDER(OP_BUYSTOP,Price,LOT);
        }
     }
   if(Price<Bid)
     {
      Price=NormalizeDouble(Bid,Digits);
      OPENORDER(OP_SELL,Price,LOT);
      for(i=1; i<=Orders; i++)
        {
         Price=NormalizeDouble(Price-Step*Point,Digits);
         LOT=NormalizeDouble(LOT*K_Lot+PlusLot,DigitsLot);
         OPENORDER(OP_SELLSTOP,Price,LOT);
        }
     }
   Comment("—крипт закончил свою работу, выставлено ",n," ордеров  ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\nCopyright © 2015 cmillion@narod.ru");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OPENORDER(int ord,double Price,double L)
  {
   int error,err;
   double SL=0,TP=0;
   while(true)
     {
      error=0;
      if(ord==OP_BUY)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_SELL)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(ord==OP_BUYSTOP)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_SELLSTOP)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(ord==OP_SELLLIMIT)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price-takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price+stoploss*Point,Digits);  else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Blue);
        }
      if(ord==OP_BUYLIMIT)
        {
         if(takeprofit!=0) TP=NormalizeDouble(Price+takeprofit*Point,Digits); else TP=0;
         if(stoploss!=0) SL=NormalizeDouble(Price-stoploss*Point,Digits); else SL=0;
         error=OrderSend(Symbol(),ord,L,Price,slippage,SL,TP,"cmillion",Magic,expiration,Red);
        }
      if(error==-1)
        {
         txt=StringConcatenate(txt,"\nError ",GetLastError());
         if(ord==OP_BUYSTOP)   txt = StringConcatenate(txt,"  OPENORDER BUYSTOP   Ask =",DoubleToStr(Ask,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_SELLSTOP)  txt = StringConcatenate(txt,"  OPENORDER SELLSTOP  Bid =",DoubleToStr(Bid,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_SELLLIMIT) txt = StringConcatenate(txt,"  OPENORDER SELLLIMIT Ask =",DoubleToStr(Ask,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         if(ord==OP_BUYLIMIT)  txt = StringConcatenate(txt,"  OPENORDER BUYLIMIT  Bid =",DoubleToStr(Bid,Digits),"   Lot =",DoubleToStr(L,DigitsLot),"   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits)," (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL);
         Print(txt);
         Comment(txt,"  ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
         err++;Sleep(1000);RefreshRates();
        }
      else
        {
         Comment("ќрдер ",error," успешно выставлен ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
         n++;
         return;
        }
      if(err>attempts) return;
     }
   return;
  }
//+------------------------------------------------------------------+
