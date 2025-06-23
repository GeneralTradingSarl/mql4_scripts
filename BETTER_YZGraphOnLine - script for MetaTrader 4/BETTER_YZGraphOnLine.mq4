//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2006, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
//
// Скрипт создан по мотивам скрипта Игря Кима  KimIV www.kimiv.ru
// 


#property copyright "YURAZ YZH"
#property link      "yzh@mail.ru"
#property show_inputs

//extern bool   DeleteOldObjects = True;      // Удалять старые объекты
extern string _P_Objects="---------- Параметры объектов";
//extern int    TypeObjects      = 1;         // Тип объектов (0-прямоуг. 1-линия)
extern color  clObjBuy        =Aqua;      // Цвет прибыльных покупок
extern color  clObjBuyLoss    =Aqua; // Blue;      // Цвет убыточных покупок
extern color  clObjSell       =Salmon;    // Цвет прибыльных продаж
extern color  clObjSellLoss   =Salmon; // Red;       // Цвет убыточных продаж
extern string _P_Arrows="---------- Параметры указателей";
//extern bool   ShowArrow        = True;      // Показывать указатели
extern int    KodArrowBuy     =2;       // Код указателя покупки
extern int    OffSetArrowBuy  =0; // -20;       // Смещение указателя покупки
extern color  clArrowBuy      =Blue;      // Цвет указателя покупки
extern int    KodArrowSell    =1;       // Код указателя продажи
extern int    OffSetArrowSell =0; // 20;        // Смещение указателя продажи
extern color  clArrowSell     =Red;       // Цвет указателя продажи
//extern string _P_Text = "---------- Параметры текста";
extern bool   ShowTextBalance =True;      // Показывать текст баланса
//extern int    OffSetText       = 100;       // Смещение текста
//extern int    SizeText         = 9;         // Размер текста

//extern color  clTextProfit     = Green;     // Цвет суммы прибыли
//extern color  clTextLoss       = Red;       // Цвет суммы убытка
//extern color  clTextBalans     = Green;     // Цвет суммы баланса

extern int    KodArrowCloseBuy =3;
extern int    KodArrowCloseSell=3;



static int ALLPIP=0;
//------- Глобальные переменные --------------------------------------
int    frogBalance    =0;
string frogNameObjLine="LDeal";      // Наименования объектов ЛИНИЯ
string frogNameObjRect="RDeal";      // Наименования объектов ПРЯМОУГОЛЬНИК

//-----
string SIGNAL;
string name;
int arrow_code;
int iBar;
datetime datetime_object;
int len;
int fW ;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
  {
   int iPos=0;

   datetime dattimeOpen;
   datetime dattimeClose;

   double OpenPrice;
   double ClosePrice;

   fW=FileOpen ("YZSIGNAL.DAT",FILE_BIN|FILE_WRITE);
   //   SIGNAL = "B|"+TimeToStr( TimeCurrent() ,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"\n" ;      

   //   FileWriteDouble( fW, StringLen(SIGNAL), 8 ); // запишем заголовок

   iPos=0;
   while( true) // посмотрим историю
     {
      if (OrderSelect( iPos , SELECT_BY_POS, MODE_HISTORY)==false )
         break;

      if(OrderType()==OP_BUY) // BUY
        {
         SIGNAL="B|"+OrderTicket()+"|"+OrderLots()+"|"+TimeToStr( OrderOpenTime() ,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"|"+TimeToStr( OrderCloseTime() ,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"|";
        }
      if(OrderType()==OP_SELL)// SELL
        {
         SIGNAL="S|"+OrderTicket()+"|"+OrderLots()+"|"+TimeToStr( OrderOpenTime() ,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"|"+TimeToStr( OrderCloseTime() ,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"|";
        }
      len=StringLen(SIGNAL);
      FileWriteString( fW, SIGNAL, len );

      if(OrderSymbol()==Symbol() )
        {
         // if ( StringSubstr ( OrderComment(), 0,3)  == "[0]"  )
         SetPropArrow(  OrderType(), OrderLots(), OrderTicket() , OrderOpenTime() ,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(), OrderCloseTime() ,OrderClosePrice(), OrderComment()   );
        }
      iPos++;
     }

   iPos=0;
   while( true) // открытые ордера тоже поставим
     {
      if (OrderSelect( iPos , SELECT_BY_POS, MODE_TRADES)==false )
         break;

      if(OrderSymbol()==Symbol() )
        {
         // if ( StringSubstr ( OrderComment(), 0,3)  == "[0]"  )
         SetPropArrow(  OrderType(),  OrderLots(), OrderTicket() , OrderOpenTime() ,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit(), 0 ,0 ,OrderComment() );
        }
      iPos++;
     }

   FileClose(fW);
  }

//+------------------------------------------------------------------+
//| Установка свойств объекта УКАЗАТЕЛЬ                              |
//| Параметры:                                                       |
//|                                                                  |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   dtopen - дата, время открытия                                  |
//|   price pp - цена открытия                                       |
//|   dtclose - дата время закрытия                                  |
//|   priceclose - цена закрытия                                     |
//+------------------------------------------------------------------+
void SetPropArrow( int  op, double Lots, int or,  datetime dtopen, double pOpen, double pSL,double pTP, datetime dtclose, double priceclose, string sComment)
  {
   string no="ADeal";
   string oc="Close";
   string osl="SL";
   string otp="TP";

   if (op==OP_BUY || op==OP_SELL )
     {

      if(op==OP_BUY )
        {
         no=OrderTicket()+"BUY"+no+" "+DoubleToStr((priceclose-pOpen)/Point,0)+" ";
        }
      if(op==OP_SELL )
        {
         no=OrderTicket()+"SEL"+no+" "+DoubleToStr ((pOpen-priceclose)/Point,0)+" ";
        }

      if(op==OP_BUY )
         oc=OrderTicket()+"BUY"+oc+" "+DoubleToStr ((priceclose-pOpen)/Point,0)+" ";
      if(op==OP_SELL )
         oc=OrderTicket()+"SEL"+oc+" "+DoubleToStr ((pOpen-priceclose)/Point,0)+" ";

      osl=OrderTicket()+osl+" "+DoubleToStr ((pSL)/Point,0);
      otp=OrderTicket()+otp+" "+DoubleToStr ((pSL)/Point,0);

      if (ObjectFind(osl) < 0)
        {
         if(( op==OP_BUY && pSL > pOpen && pSL==priceclose )
         ||
        (op==OP_SELL && pSL < pOpen && pSL==priceclose )
          )
           {
            ObjectCreate(osl, OBJ_ARROW, 0, 0,0);

            ObjectSet(osl, OBJPROP_PRICE1   , pSL) ;

            ObjectSet(osl, OBJPROP_COLOR    , clArrowBuy);

            ObjectSet(osl, OBJPROP_ARROWCODE, 34);

            if(dtclose==0 )
               ObjectSet(osl, OBJPROP_TIME1, dtopen );
            else
               ObjectSet(osl, OBJPROP_TIME1, dtclose );
           }

        }

      if (ObjectFind(no+or) < 0)
        {
         ObjectCreate(no+or, OBJ_ARROW, 0, 0,0);
        }

      ObjectSet(no+or, OBJPROP_TIME1, dtopen);

      if (priceclose!=0)
        {
         if (ObjectFind(oc+dtclose)<0)
            ObjectCreate(oc+dtclose, OBJ_ARROW, 0, 0,0);
         ObjectSet(oc+dtclose, OBJPROP_TIME1, dtclose);
         
         int PIP;
         if  (op==OP_BUY)
           PIP  = (priceclose - pOpen ) / Point;
         if  (op==OP_SELL)   
           PIP=  (pOpen - priceclose) / Point;
           
           
         ALLPIP =   ALLPIP + PIP;
         if (ObjectFind("ALLPIP") < 0 )
         {
              ObjectCreate( "ALLPIP",OBJ_LABEL,0,0,0,0,0,0);
              
                       ObjectSet("ALLPIP", OBJPROP_XDISTANCE,100);
         ObjectSet("ALLPIP", OBJPROP_YDISTANCE, 20 );
         ObjectSet("ALLPIP", OBJPROP_CORNER, 1);
              
         }
         ObjectSetText("ALLPIP",  DoubleToStr(ALLPIP,0) , 15 , "Arial", Aqua );
         
         ObjectCreate( oc+dtclose+PIP,OBJ_TEXT,0,0,0,0,0,0);
         ObjectSetText( oc+dtclose+PIP, DoubleToStr(PIP,0), 12 ,  "Times New Roman",  Yellow) ;
         ObjectSet(oc+dtclose+PIP, OBJPROP_TIME1, dtclose-5300);
         ObjectSet(oc+dtclose+PIP,OBJPROP_COLOR, Yellow);
         if  (op==OP_BUY)
            ObjectSet(oc+dtclose+PIP, OBJPROP_PRICE1   , priceclose+50*Point); 
         if  (op==OP_SELL) 
            ObjectSet(oc+dtclose+PIP, OBJPROP_PRICE1   , priceclose-50*Point); 
            
 /*           
         ObjectCreate( oc+dtclose+Lots,OBJ_TEXT,0,0,0,0,0,0);
         ObjectSetText( oc+dtclose+Lots, DoubleToStr(Lots,2), 9 ,  "Times New Roman",  Red) ;
         ObjectSet(oc+dtclose+Lots, OBJPROP_TIME1, dtclose-35000);
         ObjectSet(oc+dtclose+Lots,OBJPROP_COLOR, Red);
         if  (op==OP_BUY)
            ObjectSet(oc+dtclose+Lots, OBJPROP_PRICE1   , priceclose+50*Point); 
         if  (op==OP_SELL) 
            ObjectSet(oc+dtclose+Lots, OBJPROP_PRICE1   , priceclose-50*Point); 
                        
*/        
            
        }

      if (op==OP_BUY)
        {
         ObjectSet(no+or, OBJPROP_PRICE1   , pOpen+OffSetArrowBuy*Point);
         ObjectSet(no+or, OBJPROP_COLOR    , clArrowBuy);
         ObjectSet(no+or, OBJPROP_ARROWCODE, KodArrowBuy);
         

         if (priceclose!=0)
           {
            ObjectSet(oc+dtclose, OBJPROP_PRICE1   , priceclose);
            ObjectSet(oc+dtclose, OBJPROP_COLOR    , clArrowBuy);
            ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, KodArrowCloseBuy);

            if(StringFind(sComment,"sl",0)!=-1  )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Red );
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 251 );
              }

          if(/*StringFind(sComment,"tp",0) != -1 ||*/  priceclose==pTP )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Yellow);
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 174 );
               
              }
            SetPropLines(   op, Lots,  or, dtopen , pOpen,   dtclose,  priceclose , 1, sComment);

           }
         else
           {
            ObjectSet(oc+Time[0], OBJPROP_PRICE1   , Bid);
            ObjectSet(oc+Time[0], OBJPROP_COLOR    , clArrowSell);
            ObjectSet(oc+Time[0], OBJPROP_ARROWCODE, KodArrowCloseSell);

            if(StringFind(sComment,"sl",0)!=-1  )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Red );
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 251 );
              }

          if(/* StringFind(sComment,"tp",0) != -1 || */ priceclose==pTP )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Yellow);
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 174 );
              }

            SetPropLines(   op, Lots,  or, dtopen , pOpen,   Time[0],  Bid, 0, sComment);
           }

        }

      if (op==OP_SELL)
        {
         ObjectSet(no+or, OBJPROP_PRICE1   , pOpen+OffSetArrowSell*Point);
         ObjectSet(no+or, OBJPROP_COLOR    , clArrowSell);
         ObjectSet(no+or, OBJPROP_ARROWCODE, KodArrowSell);

         if (priceclose!=0)
           {
            ObjectSet(oc+dtclose, OBJPROP_PRICE1   , priceclose);
            ObjectSet(oc+dtclose, OBJPROP_COLOR    , clArrowSell);
            ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, KodArrowCloseSell);
          if (/* StringFind(sComment,"tp",0) != -1 ||  */priceclose==pTP )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Yellow);
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 174 );
              }
            SetPropLines(   op,  Lots,  or, dtopen , pOpen,   dtclose,  priceclose, 1, sComment);
           }
         else
           {
            ObjectSet(oc+Time[0], OBJPROP_PRICE1   , Ask);
            ObjectSet(oc+Time[0], OBJPROP_COLOR    , clArrowSell);
            ObjectSet(oc+Time[0], OBJPROP_ARROWCODE, KodArrowCloseSell);
          if(/* StringFind(sComment,"tp",0) != -1 || */ priceclose==pTP )
              {
               ObjectSet(oc+dtclose, OBJPROP_COLOR    , Yellow);
               ObjectSet(oc+dtclose, OBJPROP_ARROWCODE, 174 );
              }
            SetPropLines(   op,  Lots, or, dtopen , pOpen,   Time[0],  Ask, 0, sComment);
           }

        }
     }
  }

//+------------------------------------------------------------------+
//| Установка свойств объекта ЛИНИЯ ТРЕНДА                           |
//| Параметры:                                                       |
//|   dt - дата, время                                               |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   pp - цена                                                      |
//+------------------------------------------------------------------+
void SetPropLines( int op, double Lots, int or, datetime dt, double pp, datetime pВремяЗакрытия,double pЦенаЗакрытия,int FlOpen, string sComment)
  {
   color  cl;
   double p1, p2;
   string no=frogNameObjLine;

   if (op==OP_BUY)
      no=OrderTicket()+no+" "+ DoubleToStr((pЦенаЗакрытия-pp)/Point,0)+" "+DoubleToStr(Lots,2)+" ";
   if(op==OP_SELL )
      no=OrderTicket()+no+" " +  DoubleToStr((pp-pЦенаЗакрытия)/Point ,0)+" "+DoubleToStr(Lots,2)+" ";

   if (op==OP_BUY || op==OP_SELL )
     {
      if (ObjectFind(no+or)<0)
         ObjectCreate(no+or, OBJ_TREND, 0, 0,0, 0,0);
      ObjectSet(no+or, OBJPROP_TIME1 , dt);
      ObjectSet(no+or, OBJPROP_PRICE1, pp);
      ObjectSet(no+or, OBJPROP_TIME2 , pВремяЗакрытия);
      ObjectSet(no+or, OBJPROP_PRICE2,  pЦенаЗакрытия);
     }
   if (op==OP_BUY)
      ObjectSet(no+or, OBJPROP_COLOR, clObjBuy);
   if (op==OP_SELL)
      ObjectSet(no+or, OBJPROP_COLOR, clObjSell);

   ObjectSet(no+or, OBJPROP_RAY , False);

   if(FlOpen==0 )
     {
      ObjectSet( no+or, OBJPROP_STYLE, DRAW_LINE );
      ObjectSet( no+or, OBJPROP_STYLE, STYLE_DOT );
      // ObjectSet( no+or, OBJPROP_COLOR,  );
     }

   p1=ObjectGet(no+or, OBJPROP_PRICE1);
   p2=ObjectGet(no+or, OBJPROP_PRICE2);
   cl=ObjectGet(no+or, OBJPROP_COLOR);
   if (p1!=0 && p2!=0)
     {
      if (cl==clObjBuy)
        {
         if (p1>p2)
           {
            ObjectSet(no+or, OBJPROP_COLOR, clObjBuyLoss);
            ObjectSet( no+or, OBJPROP_STYLE, DRAW_LINE );
            ObjectSet( no+or, OBJPROP_STYLE, STYLE_DOT );

           }
        }
      if (cl==clObjSell)
        {
         if (p1<p2)
           {
            ObjectSet(no+or, OBJPROP_COLOR, clObjSellLoss);
            ObjectSet( no+or, OBJPROP_STYLE, DRAW_LINE );
            ObjectSet( no+or, OBJPROP_STYLE, STYLE_DOT );
           }
        }
     }
  }

//+------------------------------------------------------------------+