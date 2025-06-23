//+------------------------------------------------------------------+
//|                          SCT_PriceAction_AllPotentialEntries.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

class cCandlestick {

   public:

      double dOpenPrice, dHighPrice, dLowPrice, dClosePrice, dRangeCandle, dBodyCandle, dUpperWickCandle, dLowerWickCandle;
      
      bool bBullCandle;
      bool bBearCandle;
      bool bDojiCandle;
      
      void mvGetCandleStickCharateristics (string s, int i) {
         
         dOpenPrice = iOpen(s, PERIOD_CURRENT,i);
         dHighPrice = iHigh(s, PERIOD_CURRENT,i);
         dLowPrice = iLow(s, PERIOD_CURRENT,i);
         dClosePrice = iClose(s, PERIOD_CURRENT,i);
         
         dRangeCandle = NormalizeDouble(MathAbs(dHighPrice-dLowPrice)/SymbolInfoDouble(s,SYMBOL_POINT),_Digits);
         dBodyCandle = NormalizeDouble(MathAbs(dOpenPrice-dClosePrice)/SymbolInfoDouble(s,SYMBOL_POINT),_Digits);
         dUpperWickCandle = NormalizeDouble(MathAbs(dHighPrice-MathMax(dClosePrice,dOpenPrice))/SymbolInfoDouble(s,SYMBOL_POINT),_Digits);
         dLowerWickCandle = NormalizeDouble(MathAbs(MathMin(dClosePrice,dOpenPrice)-dLowPrice)/SymbolInfoDouble(s,SYMBOL_POINT),_Digits);
         
         if (dBodyCandle<=1.0 && dUpperWickCandle>dBodyCandle && dLowerWickCandle>dBodyCandle) {
            bDojiCandle=true; bBullCandle=false; bBearCandle=false;}
         else if (dOpenPrice<dClosePrice) {
            bDojiCandle=false; bBullCandle=true; bBearCandle=false;}
         else if (dOpenPrice>dClosePrice) {
            bDojiCandle=false; bBullCandle=false; bBearCandle=true;}
      }
};

cCandlestick cCS1, cCS2;

void OnStart()
  {
   int z=1;
   long chartid=0;

   int HowManySymbols=SymbolsTotal(true);

   int counter;

   for(int i=0;i<HowManySymbols;i++) {

      counter=0;
      string sArrowBuy1="", sArrowBuy2="", sArrowSell1="", sArrowSell2="";

      cCS1.mvGetCandleStickCharateristics(SymbolName(i,true),z);
      cCS2.mvGetCandleStickCharateristics(SymbolName(i,true),z+1);


   // OPEN CHART TO DOWNLOAD DATA                    |

      chartid=ChartOpen(SymbolName(i,true), PERIOD_CURRENT);  

      // ===============================================|
      // ===============================================|
      
      if (cCS1.bBullCandle && cCS2.bBullCandle && cCS1.dRangeCandle>cCS2.dRangeCandle && cCS1.dBodyCandle>=cCS2.dBodyCandle) {
         sArrowBuy1 = StringConcatenate("sArrowBuy1 ",SymbolName(i,true), string(iTime(SymbolName(i,true),PERIOD_CURRENT,z)));
         ObjectCreate(chartid,sArrowBuy1,OBJ_ARROW_BUY,0,iTime(SymbolName(i,true),PERIOD_CURRENT,z),cCS1.dLowPrice);
         ObjectSet(sArrowBuy1,OBJPROP_COLOR,clrGreen);
         sArrowBuy2 = StringConcatenate("sArrowBuy2 ",SymbolName(i,true), string(iTime(SymbolName(i,true),PERIOD_CURRENT,z+1)));
         ObjectCreate(chartid,sArrowBuy2,OBJ_ARROW_BUY,0,iTime(SymbolName(i,true),PERIOD_CURRENT,z+1),cCS2.dLowPrice);
         ObjectSet(sArrowBuy2,OBJPROP_COLOR,clrGreen);
         counter++;
      }

      // ===============================================|
      // ===============================================|
   
      if (cCS1.bBearCandle && cCS2.bBearCandle && cCS1.dBodyCandle>cCS2.dBodyCandle && cCS1.dRangeCandle>=cCS2.dRangeCandle) {
         sArrowSell1= StringConcatenate("sArrowSell1 ",SymbolName(i,true),string(iTime(SymbolName(i,true),PERIOD_CURRENT,z)));
         ObjectCreate(chartid,sArrowSell1,OBJ_ARROW_SELL,0,iTime(SymbolName(i,true),PERIOD_CURRENT,z),cCS1.dHighPrice);
         ObjectSet(sArrowSell1,OBJPROP_COLOR,clrRed);
         sArrowSell2 = StringConcatenate("sArrowSell2 ",SymbolName(i,true), string(iTime(SymbolName(i,true),PERIOD_CURRENT,z+1)));
         ObjectCreate(chartid,sArrowSell2,OBJ_ARROW_SELL,0,iTime(SymbolName(i,true),PERIOD_CURRENT,z+1),cCS2.dHighPrice);
         ObjectSet(sArrowSell2,OBJPROP_COLOR,clrRed);
         counter++;
      }

      if (counter==0)
         ChartClose(chartid);
   }

   
  }
//+------------------------------------------------------------------+
