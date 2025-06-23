//+------------------------------------------------------------------+
//|                                  script_cm_open_2_stoporders.mq4 |
//|                                Copyright 2016, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, cmillion@narod.ru"
#property link      "http://cmillion.ru"
#property version   "1.00"
#property strict
#property show_inputs
#property description "—крипт открыти€ противоположных стоп ордеров в указанное врем€"
#property description "ѕосле срабатывани€ одного, второй удал€етс€"
/*--------------------------------------------------------------------
¬ определенное врем€(задаЄтс€ в параметрах) выставл€ютс€ 
два отложенных ордера байстоп и селстоп на рассто€нии в пунктах (задаетс€ в 
параметрах) от текущей цены, с TP и SL в пунктах (задаетс€ в параметрах). 
ѕосле срабатывани€ одного из ордеров, противоположный удал€етс€.
ƒалее скрипт заканчивает свою работу.
//--------------------------------------------------------------------*/
extern int      level          = 10,       //рассто€ние от текущей цены до ордеров
stoploss       = 50,       //уровень выставлени€ SL, если 0, то SL не выставл€етс€
takeprofit     = 50,       //уровень выставлени€ TP, если 0, то TP не выставл€етс€
Magic          = 0;        //уникальный номер ордера
extern double   Lot            = 0.1;      //объем ордеров
extern datetime TimeSet=D'2016.01.06 01:08'; //¬рем€ выставлени€ ордеров, если текущее врем€ больше установленного, то выставл€ютс€ сразу
int slippage=3;
double STOPLEVEL;
//--------------------------------------------------------------------
void OnStart()
  {
   if(Digits==3 || Digits==5) {level*=10;stoploss*=10;takeprofit*=10;slippage*=10;}
   while(TimeCurrent()<TimeSet)
     {
      if(IsStopped()) {Comment("принудительное закрытие скрипта ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      Sleep(1000);
      Comment(TimeToStr(TimeCurrent(),TIME_SECONDS),"\n—крипт открыти€ противоположных стоп ордеров в ",
              TimeToStr(TimeSet,TIME_DATE|TIME_SECONDS),"\n",WindowExpertName(),"\n",
              "ƒо выставлени€ позиций осталось ",TimeToStr(TimeSet-TimeCurrent(),TIME_SECONDS));
     }
//---
   string txt=NULL;
   RefreshRates();
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(level<STOPLEVEL) level=(int)STOPLEVEL;
   double SL,TP,Price=NormalizeDouble(Ask+level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price+takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price-stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrBlue)!=-1)
      txt=StringConcatenate(txt,"ќрдер BUYSTOP успешно выставлен ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER BUYSTOP     Ask =",DoubleToStr(Ask,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");

   Price=NormalizeDouble(Bid-level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price-takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price+stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrRed)!=-1)
      txt=StringConcatenate(txt,"ќрдер SELLSTOP успешно выставлен ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER SELLSTOP     Bid =",DoubleToStr(Bid,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");
   Comment(txt);

//---
   while(true)
     {
      if(IsStopped()) {Comment("принудительное закрытие скрипта ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      int TicketB=0,TicketS=0,OT,j;
      for(j=OrdersTotal(); j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            OT=OrderType();
            if(OrderSymbol()==Symbol() && OT>1 && OrderMagicNumber()==Magic)
              {
               if(OT==OP_BUYSTOP) TicketB=OrderTicket();
               if(OT==OP_SELLSTOP) TicketS=OrderTicket();
              }
           }
        }
      if(TicketB>0 && TicketS==0) if(OrderDelete(TicketB)) break;
      if(TicketS>0 && TicketB==0) if(OrderDelete(TicketS)) break;
      if(TicketS==0 && TicketB==0) break;
      Comment("—крипт открыти€ противоположных стоп ордеров\n",WindowExpertName(),"\n",txt,
              "∆дем открыти€ одного из ордеров ",TimeToStr(TimeCurrent(),TIME_SECONDS));
      Sleep(1000);
     }
   Comment("—крипт \"",WindowExpertName(),"\" закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
  }
//--------------------------------------------------------------------
