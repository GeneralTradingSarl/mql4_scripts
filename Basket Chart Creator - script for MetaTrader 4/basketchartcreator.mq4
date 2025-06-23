//------------------------------------------------------------------------------------------------
//--- BasketChartCreator.mq4  
//--- Copyright © 2015, Khalil Abokwaik. 
//--- Originaly posted at "Basket Robots" thread on Forex Factory
//--- Link  : http://www.forexfactory.com/showthread.php?t=529896
//------------------------------------------------------------------------------------------------
#property copyright     "Copyright © 2015, MetaQuotes Software Corp., Khalil Abokwaik"
#property link          "https://www.mql5.com/en/users/abokwaik"
#property description   "Basket Chart Creator"
#property description   "\nThis script creates MT4 Off-Line Basket Charts for user-defined Baskets of Pairs."
#property description   "The code is based on the MT4 standard PeriodConverter script."
#property description   "Quality M1 history data for basket pairs is recommended."
#property description   "\nCalculations are based on Geometric Mean method."

#property version "1.00"
#property strict
#property show_inputs
#include <WinUser32.mqh>

#define   MAX_PRICE 999999999.9
//+--- user inputs ---------------------------------------------------------------+
input string   Basket_Name="#COM#";//Basket Chart Name
input ENUM_TIMEFRAMES
               Time_Frame=PERIOD_H1;//Basket Time Frame
               //-- Commodity Currencies BASKET example
input string   Pairs             = "AUDUSD,NZDUSD,USDCAD,EURAUD,EURNZD,EURCAD,GBPAUD,GBPNZD,GBPCAD";//Basket Pairs (comma seperated)
input string   Pairs_DW          = "  +1  ,  +1  ,  -1  ,  -1  ,  -1  ,  -1  ,  -1  ,  -1  ,  -1  ";//Directional Weights (comma seperated)
input string   Template_Name="0";//Template to load on basket chart, "0" to disable
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//=- Below are sample currency baskets for YEN, EUR and GBP . These are just examples. -=
//=- However possibilities are only limited by your imagination!. Khalil Abokwaik.     -=
//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//-- YEN BASKET
//input string   Pairs             = "USDJPY,EURJPY,GBPJPY,AUDJPY,CADJPY,NZDJPY,CHFJPY";//Basket Pairs
//input string   Pairs_DW          = "-1000 ,-1100 , -1200,-900  ,-900  , -900 , -1000";//Pairs Directional Weight
//input string   Pairs_Lot_Multi   = "   1  ,   1  ,   1  ,   1  ,   1  ,   1  ,   1  ";//Lot Multiplier

//-- EUR BASKET
//input string   Pairs           = "EURUSD,EURGBP,EURAUD,EURCAD,EURCHF,EURNZD,EURJPY";//Basket Pairs
//input string   Pairs_DW        = "+1    ,+1    ,+1    ,+1    ,+1    ,+1    ,+0.01 ";//Pairs Directional Weight

//-- GBP BASKET
//input string   Pairs           = "GBPUSD,EURGBP,GBPAUD,GBPCAD,GBPCHF,GBPNZD,GBPJPY";//Basket Pairs
//input string   Pairs_DW        = "+1    ,-1    ,+1    ,+1    ,+1    ,+1    ,+0.01 ";//Pairs Directional Weight
//+------------------------------------------------------------------+
int      ExtHandle=-1;
int      InpPeriodMultiplier=0;// Period multiplier factor
string   symbol;
double   low=0;
double   high=0;
string   pairs[],xxx;
string   pair_dw_s[];
double   pair_dw[];
double   pdw=0;
double   irate=0;
int      i_digits=4;//Basket Digits    
string   sep=",";//symbols separator
int      j=0;
int      symb_cnt=0;
int      time_frame=0;

//--- Get the separator code
ushort   u_sep=StringGetCharacter(sep,0);
//+------------------------------------------------------------------+
//| script program Initilization function                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Period()!=PERIOD_M1) Alert("Generic Basket Creator Script better be attached M1 chart");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime time0;
   ulong    last_fpos=0;
   long     last_volume=0;
   int      i,start_pos,periodseconds;
   int      hwnd=0,cnt=0;

//---- History header
   int      file_version=401;
   string   c_copyright;
   string   c_symbol=Basket_Name;
   int      i_period;

   int      i_unused[13];
   MqlRates rate;
   time_frame=Time_Frame;
   i_period=Period()*time_frame;
//--- set history file handle 
   ExtHandle=FileOpenHistory(c_symbol+IntegerToString(time_frame)+".hst",FILE_BIN|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   if(ExtHandle<0)
      return;
   c_copyright="(C)opyright 2003, MetaQuotes Software Corp.";
   ArrayInitialize(i_unused,0);
// initialize symbols
//--------------------------
   symb_cnt=StringSplit(Pairs,u_sep,pairs);
   StringSplit(Pairs_DW,u_sep,pair_dw_s);
   ArrayResize(pair_dw,symb_cnt);
   double root=((double) 1/symb_cnt);
   for(j=0;j<ArraySize(pair_dw_s);j++)
     {
      pair_dw[j]=StrToDouble(pair_dw_s[j]);
     }
   Comment(c_symbol,",",Pairs,",",Pairs_DW);   //The comment is specially formatted like this to be red from Expert Advisor
//--- write history file header
   FileWriteInteger(ExtHandle,file_version,LONG_VALUE);
   FileWriteString(ExtHandle,c_copyright,64);
   FileWriteString(ExtHandle,c_symbol,12);
   FileWriteInteger(ExtHandle,time_frame,LONG_VALUE);
   FileWriteInteger(ExtHandle,i_digits,LONG_VALUE);
   FileWriteInteger(ExtHandle,0,LONG_VALUE);
   FileWriteInteger(ExtHandle,0,LONG_VALUE);
   FileWriteArray(ExtHandle,i_unused,0,13);
//--- write history file
   periodseconds=time_frame*60;
   start_pos=Bars-1;
   rate.open=0.0;
   rate.low=MAX_PRICE;
   rate.high=0.0;
   rate.close=0.0;
   rate.spread=0;
   rate.tick_volume=100;

   for(j=0;j<symb_cnt;j++)
     {
      if(pair_dw[j]>0)
        {
         if(rate.open==0) rate.open=NormalizeDouble(iOpen(pairs[j],0,start_pos)*pair_dw[j],i_digits);
         else            rate.open*=NormalizeDouble(iOpen(pairs[j],0,start_pos)*pair_dw[j],i_digits);
        }
      else
        {
         irate=iOpen(pairs[j],0,start_pos);
         if(irate>0)
           {
            if(rate.open==0) rate.open=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
            else            rate.open*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
           }

        }

      rate.tick_volume=100;
      rate.spread=0;
      rate.real_volume=0;
     }
   rate.open=NormalizeDouble(MathPow(rate.open,root),i_digits);
   rate.low=MathMin(rate.low,rate.open);
   rate.high=MathMax(rate.high,rate.open);

//--- normalize open time
   rate.time=Time[start_pos]/periodseconds;
   rate.time*=periodseconds;

   for(i=start_pos-1; i>=0; i--)
     {
      if(IsStopped())
         break;
      time0=Time[i];
      //--- history may be updated
      if(i==0)
        {
         //--- modify index if history was updated
         if(RefreshRates())
            i=iBarShift(NULL,0,time0);
        }
      //---

      if(time0>=rate.time+periodseconds || i==0)
        {
         if(i==0 && time0<rate.time+periodseconds)
           {
            rate.close=0;
            for(j=0;j<symb_cnt;j++)
              {
               rate.tick_volume=100;
               if(pair_dw[j]>0)
                 {
                  if(rate.close==0) rate.close=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);
                  else             rate.close*=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);
                 }
               else
                 {
                  irate=iClose(pairs[j],0,0);
                  if(irate>0)
                    {
                     if(rate.close==0) rate.close=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else             rate.close*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }
                 }
              }
            rate.close=NormalizeDouble(MathPow(rate.close,root),i_digits);
            low=MathMin(low,MathMin(rate.close,rate.open));
            high=MathMax(high,MathMax(rate.close,rate.open));

            if(rate.low>low) rate.low=low;
            if(rate.high<high) rate.high=high;

           }
         last_fpos=FileTell(ExtHandle);
         last_volume=(long)Volume[i];
         FileWriteStruct(ExtHandle,rate);
         cnt++;
         if(time0>=rate.time+periodseconds)
           {
            rate.time=time0/periodseconds;
            rate.time*=periodseconds;
            rate.open=0.0;
            rate.low=MAX_PRICE;
            rate.high=0.0;
            rate.spread=0;
            rate.tick_volume=0;
            rate.close=0.0;
            for(j=0;j<symb_cnt;j++)
              {
               if(pair_dw[j]>0)
                 {
                  if(rate.open==0) rate.open=NormalizeDouble(iOpen(pairs[j],0,i)*pair_dw[j],i_digits);
                  else            rate.open*=NormalizeDouble(iOpen(pairs[j],0,i)*pair_dw[j],i_digits);
                  if(rate.close==0) rate.close=NormalizeDouble(iClose(pairs[j],0,i)*pair_dw[j],i_digits);
                  else             rate.close*=NormalizeDouble(iClose(pairs[j],0,i)*pair_dw[j],i_digits);

                 }
               else
                 {
                  irate=iOpen(pairs[j],0,i);
                  if(irate>0)
                    {
                     if(rate.open==0) rate.open=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else            rate.open*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }
                  irate=iClose(pairs[j],0,i);
                  if(irate>0)
                    {
                     if(rate.close==0) rate.close=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else             rate.close*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }
                 }

              }
            rate.open=NormalizeDouble(MathPow(rate.open,root),i_digits);
            rate.close=NormalizeDouble(MathPow(rate.close,root),i_digits);
            rate.low=MathMin(rate.low,MathMin(rate.open,rate.close));
            rate.high=MathMax(rate.high,MathMax(rate.open,rate.close));
            rate.tick_volume=100;

           }
        }
      else
        {

         low=MAX_PRICE;
         high=0.0;
         rate.close=0.0;
         for(j=0;j<symb_cnt;j++)
           {
            rate.tick_volume=100;
            if(pair_dw[j]>0)
              {
               if(rate.close==0) rate.close=NormalizeDouble(iClose(pairs[j],0,i)*pair_dw[j],i_digits);
               else             rate.close*=NormalizeDouble(iClose(pairs[j],0,i)*pair_dw[j],i_digits);
              }
            else
              {
               irate=iClose(pairs[j],0,i);
               if(irate>0)
                 {
                  if(rate.close==0) rate.close=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                  else             rate.close*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                 }

              }
           }
         rate.close=NormalizeDouble(MathPow(rate.close,root),i_digits);
         low=MathMin(low,rate.close);
         high=MathMax(high,rate.close);

         if(rate.low>low) rate.low=low;
         if(rate.high<high) rate.high=high;

        }
     }
   FileFlush(ExtHandle);
   Print(cnt," record(s) written");
   Alert("Off-Line Chart Created, Look it up in File > Open Offline > ",c_symbol,",",periodName(time_frame));
//--- collect incoming ticks ---------------------------------------------------------------------
   datetime last_time=LocalTime()-5;
   while(!IsStopped())
     {
      datetime cur_time=LocalTime();
      //--- check for new rates
      if(RefreshRates())
        {
         time0=Time[0];
         FileSeek(ExtHandle,last_fpos,SEEK_SET);
         //--- is there current bar?
         if(time0<rate.time+periodseconds)
           {
            low=MAX_PRICE;
            high=0.0;
            rate.close=0.0;
            for(j=0;j<symb_cnt;j++)
              {
               rate.tick_volume=100;
               if(pair_dw[j]>0)
                 {
                  if(rate.close==0) rate.close=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);
                  else             rate.close*=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);
                 }
               else
                 {
                  irate=iClose(pairs[j],0,0);
                  if(irate>0)
                    {
                     if(rate.close==0) rate.close=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else             rate.close*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }

                 }
              }
            rate.close=NormalizeDouble(MathPow(rate.close,root),i_digits);
            low=MathMin(low,rate.close);
            high=MathMax(high,rate.close);

            if(rate.low>low) rate.low=low;
            if(rate.high<high) rate.high=high;
           }
         else
           {
            //--- no, there is new bar
            rate.tick_volume=100;
            if(rate.low>MathMin(rate.close,rate.open)) rate.low=MathMin(rate.close,rate.open);
            if(rate.high<MathMax(rate.close,rate.open)) rate.high=MathMax(rate.close,rate.open);

            //--- write previous bar remains
            FileWriteStruct(ExtHandle,rate);
            last_fpos=FileTell(ExtHandle);
            //----**********************
            rate.time=time0/periodseconds;
            rate.time*=periodseconds;
            rate.open=0.0;
            rate.low=MAX_PRICE;
            rate.high=0.0;
            rate.spread=0;
            rate.tick_volume=0;
            rate.close=0.0;
            for(j=0;j<symb_cnt;j++)
              {
               if(pair_dw[j]>0)
                 {
                  if(rate.open==0) rate.open=NormalizeDouble(iOpen(pairs[j],0,0)*pair_dw[j],i_digits);
                  else            rate.open*=NormalizeDouble(iOpen(pairs[j],0,0)*pair_dw[j],i_digits);
                  if(rate.close==0) rate.close=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);
                  else           rate.close*=NormalizeDouble(iClose(pairs[j],0,0)*pair_dw[j],i_digits);

                 }
               else
                 {
                  irate=iOpen(pairs[j],0,0);
                  if(irate>0)
                    {
                     if(rate.open==0) rate.open=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else            rate.open*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }
                  irate=iClose(pairs[j],0,0);
                  if(irate>0)
                    {
                     if(rate.close==0) rate.close=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                     else             rate.close*=NormalizeDouble(((double)1/irate)*MathAbs(pair_dw[j]),i_digits);
                    }

                 }
              }
            rate.open=NormalizeDouble(MathPow(rate.open,root),i_digits);
            rate.close=NormalizeDouble(MathPow(rate.close,root),i_digits);
            rate.low=MathMin(rate.low,MathMin(rate.open,rate.close));
            rate.high=MathMax(rate.high,MathMax(rate.open,rate.close));
            rate.tick_volume=100;

           }
         //----
         FileWriteStruct(ExtHandle,rate);
         FileFlush(ExtHandle);
         //---

         if(hwnd==0)
           {
            hwnd=WindowHandle(c_symbol,i_period);
            if(hwnd!=0)
              {
               Print("Chart window detected");
               if(Template_Name!="0") apply_template();
              }
           }

         //--- refresh window not frequently than 1 time in 2 seconds
         if(hwnd!=0 && cur_time-last_time>=2)
           {
            PostMessageA(hwnd,WM_COMMAND,33324,0);
            last_time=cur_time;
           }
        }
      Sleep(50);
     }

//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(ExtHandle>=0)
     {
      FileClose(ExtHandle);
      ExtHandle=-1;
     }
//---
  }
//+------------------------------------------------------------------+

int StringToTimeFrame(string tfs)
  {
   int tf=0;
   if(tfs=="M1" || tfs=="1"     ||tfs=="m1")   tf=PERIOD_M1;
   if(tfs=="M5" || tfs=="5"     ||tfs=="m5")   tf=PERIOD_M5;
   if(tfs=="M15"|| tfs=="15"    ||tfs=="m15")  tf=PERIOD_M15;
   if(tfs=="M30"|| tfs=="30"    ||tfs=="m30")  tf=PERIOD_M30;
   if(tfs=="H1" || tfs=="60"    ||tfs=="h1")   tf=PERIOD_H1;
   if(tfs=="H4" || tfs=="240"   ||tfs=="h4")   tf=PERIOD_H4;
   if(tfs=="D1" || tfs=="1440"  ||tfs=="d1")   tf=PERIOD_D1;
   if(tfs=="W1" || tfs=="10080" ||tfs=="w1")   tf=PERIOD_W1;
   if(tfs=="MN" || tfs=="43200" ||tfs=="mn")   tf=PERIOD_MN1;
   if(tf==0) tf=Period();
   return(tf);
  }
//---------------------
void apply_template()
  {
   string sym_code="";
   long currChart,prevChart=ChartFirst();
   currChart=prevChart;
   int i=1,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts
     {
      if(currChart<0) break;          // Have reached the end of the chart list
      sym_code=ChartSymbol(currChart);
      if(sym_code==Basket_Name)
        {
         if(ChartApplyTemplate(currChart,Template_Name))
           {
            Print("The template ",Template_Name," applied successfully");
            Alert("The template ",Template_Name," applied successfully");
           }
         else
           {
            Print("Failed to apply template ",Template_Name," error code ",GetLastError());
            Alert("Failed to apply template ",Template_Name," error code ",GetLastError());
           }
         break;
        }
      prevChart=currChart;// let's save the current chart ID for the ChartNext()
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID
      i++;// Do not forget to increase the counter
     }

  }
//--------------------------------------------------------------
string periodName(int period) // Convert time frame period minutes into string (ex. 60 to H1)
  {
   switch(period)
     {
      case 1: return("M1");
      case 5: return("M5");
      case 15: return("M15");
      case 30: return("M30");
      case 60: return("H1");
      case 240: return("H4");
      case 1440: return("D1");
      case 10080: return("W1");
      case 43200: return("MN1");
      default: return("");
     }
  }
//--------------------------------------------------------------
