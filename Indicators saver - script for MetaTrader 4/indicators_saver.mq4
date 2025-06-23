//+------------------------------------------------------------------+
//|                                              Indicator saver.mq4 |
//|                                                         Greshnik |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Greshnik"
#property link      ""
#property version   "1.00"
#property strict
#property script_show_inputs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  
extern int      o_begin=100;//Begin after
extern int      o_cases=0;//Number of records(0-All)
extern int      o_digits=8;//Number of digits after decimal point
input ENUM_MA_METHOD o_ma=MODE_SMA;//The method of averaging
input ENUM_APPLIED_PRICE o_price=PRICE_OPEN;//The price used
extern int      o_period=14;//Averaging period
input string   c_1="";//---
input bool     s_time=true;//Time
input bool     s_time_dayofweek=false;//Day of week
input bool     s_time_hour=false;//Hour
input bool     s_time_minute=false;//Minute
input bool     s_iOpen=true;//Open
input bool     s_iHigh=true;//High
input bool     s_iLow=true;//Low
input bool     s_iClose=true;//Close
input bool     s_iVolume=true;//Volume
input string   c_2="";//---
input bool     e_iAC=false;//Accelerator Oscillator
input bool     e_iAD=false;//Accumulation/Distribution
input bool     e_iADX=false;//Average Directional Index
input bool     e_iAlligator=false;//Alligator
input int      jaw_period=13;//.           Jaw_period
input int      jaw_shift=8;//.           Jaw_shift
input int      teeth_period=8;//.           Teeth_period
input int      teeth_shift=5;//.           Teeth_shift
input int      lips_period=5;//.           Lips_period
input int      lips_shift=3;//.           Lips_shift
input bool     e_iAO=false;//Awesome Oscillator
input bool     e_iATR=false;//Average True Range
input bool     e_iBearsPower=false;//Bears Power
input bool     e_iBands=false;//Bollinger Bands®
input double   deviation=2.0;//.           Standard deviations
input int      bands_shift=0;//.           Bands shift
input bool     e_iBullsPower=false;//Bulls Power
input bool     e_iCCI=false;//Commodity Channel Index
input bool     e_iDeMarker=false;//DeMarker
input bool     e_iEnvelopes=false;//Envelopes
input int      ma_shift=0;//.           MA shift
input double   deviation1=0.1;//.           Percent deviation from the main line.
input bool     e_iForce=false;//Force Index
input bool     e_iFractals=false;//Fractals
input bool     e_iGator=false;//Gator Oscillator
input int      jaw_period1=13;//.           Jaw_period
input int      jaw_shift1=8;//.           Jaw_shift
input int      teeth_period1=8;//.           Teeth_period
input int      teeth_shift1=5;//.           Teeth_shift
input int      lips_period1=5;//.           Lips_period
input int      lips_shift1=3;//.           Lips_shift
input bool     e_iIchimoku=false;//Ichimoku Kinko Hyo
input int      tenkan_sen=9;//.           Period of Tenkan-sen line
input int      kijun_sen=26;//.           Period of Kijun-sen line
input int      senkou_span_b=52;//.           Period of Senkou Span B line
input bool     e_iBWMFI=false;//Market Facilitation Index by Bill Williams
input bool     e_iMomentum=false;//Momentum
input bool     e_iMFI=false;//Money Flow Index
input bool     e_iMA=false;//Moving Average
input int      ma_shift1=0;//.           MA shift
input bool     e_iOsMA=false;//Moving Average of Oscillator (MACD histogram)
input int      fast_ema_period=12;//.           Fast EMA period
input int      slow_ema_period=26;//.           Slow EMA period
input int      signal_period=9;//.           Signal line period
input bool     e_iMACD=false;//Moving Averages Convergence-Divergence
input int      fast_ema_period1=12;//.           Fast EMA period
input int      slow_ema_period1=26;//.           Slow EMA period
input int      signal_period1=9;//.           Signal line period
input bool     e_iOBV=false;//On Balance Volume
input bool     e_iSAR=false;//Parabolic Stop And Reverse System
input double   step=0.02;//.           Price increment step - acceleration factor
input double   maximum=0.2;//.           Maximum value of step
input bool     e_iRSI=false;//Relative Strength Index
input bool     e_iRVI=false;//Relative Vigor Index
input bool     e_iStdDev=false;//Standard Deviation
input int      ma_shift2=0;//.           MA shift
input bool     e_iStochastic=false;//Stochastic Oscillator
input int      Kperiod=5;//.           K line period
input int      Dperiod=5;//.           D line period
input int      slowing=3;//.           Slowing
input ENUM_STO_PRICE     price_field=STO_LOWHIGH;//.           Price
input bool     e_iWPR=false;//Williams' Percent Range
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   string s1;
   datetime dt1;
   string s2=Symbol()+"_"+IntegerToString(Period())+".txt";
   int hand=FileOpen(s2,FILE_WRITE|FILE_BIN);

   if(o_begin<0) o_begin=0;
   if(o_period<1) o_period=1;
   if(o_cases<0) o_cases=0;
   
   s1="";
   if(s_time) s1=s1+"Time"+CharToStr(9);
   if(s_time_dayofweek) s1=s1+"DayOfWeak"+CharToStr(9);
   if(s_time_hour) s1=s1+"Hour"+CharToStr(9);
   if(s_time_minute) s1=s1+"Minute"+CharToStr(9);
   if(s_iOpen)s1=s1+"Open"+CharToStr(9);
   if(s_iHigh)s1=s1+"High"+CharToStr(9);
   if(s_iLow)s1=s1+"Low"+CharToStr(9);
   if(s_iClose)s1=s1+"Close"+CharToStr(9);
   if(s_iVolume)s1=s1+"Volume"+CharToStr(9);

   if(e_iAC)s1=s1+"AC"+CharToStr(9);
   if(e_iAD)s1=s1+"AD"+CharToStr(9);
   if(e_iADX)
     {
      s1=s1+"ADX_0"+CharToStr(9);
      s1=s1+"ADX_1"+CharToStr(9);
      s1=s1+"ADX_2"+CharToStr(9);
     }
   if(e_iAO)s1=s1+"AO"+CharToStr(9);
   if(e_iATR)s1=s1+"ATR"+CharToStr(9);
   if(e_iAlligator)
     {
      s1=s1+"Alligator_0"+CharToStr(9);
      s1=s1+"Alligator_1"+CharToStr(9);
      s1=s1+"Alligator_2"+CharToStr(9);
     }
   if(e_iBWMFI)s1=s1+"BWMFI"+CharToStr(9);
   if(e_iBands)
     {
      s1=s1+"Bands_0"+CharToStr(9);
      s1=s1+"Bands_1"+CharToStr(9);
     }
   if(e_iBearsPower)s1=s1+"BearsPower"+CharToStr(9);
   if(e_iBullsPower)s1=s1+"BullsPower"+CharToStr(9);
   if(e_iCCI)s1=s1+"CCI"+CharToStr(9);
   if(e_iDeMarker)s1=s1+"DeMarker"+CharToStr(9);
   if(e_iEnvelopes)
     {
      s1=s1+"Envelopes_0"+CharToStr(9);
      s1=s1+"Envelopes_1"+CharToStr(9);
     }
   if(e_iForce)s1=s1+"Force"+CharToStr(9);
   if(e_iFractals)
     {
      s1=s1+"Fractals_0"+CharToStr(9);
      s1=s1+"Fractals_1"+CharToStr(9);
     }
   if(e_iGator)
     {
      s1=s1+"Gator_0"+CharToStr(9);
      s1=s1+"Gator_1"+CharToStr(9);
     }
   if(e_iIchimoku)
     {
      s1=s1+"Ichimoku_0"+CharToStr(9);
      s1=s1+"Ichimoku_1"+CharToStr(9);
      s1=s1+"Ichimoku_2"+CharToStr(9);
      s1=s1+"Ichimoku_3"+CharToStr(9);
      s1=s1+"Ichimoku_4"+CharToStr(9);
     }
   if(e_iMA)s1=s1+"MA"+CharToStr(9);
   if(e_iMACD)
     {
      s1=s1+"MACD_0"+CharToStr(9);
      s1=s1+"MACD_1"+CharToStr(9);
     }
   if(e_iMFI)s1=s1+"MFI"+CharToStr(9);
   if(e_iMomentum)s1=s1+"Momentum"+CharToStr(9);
   if(e_iOBV)s1=s1+"OBV"+CharToStr(9);
   if(e_iOsMA)s1=s1+"OsMA"+CharToStr(9);
   if(e_iRSI)s1=s1+"RSI"+CharToStr(9);
   if(e_iRVI)
     {
      s1=s1+"RVI_0"+CharToStr(9);
      s1=s1+"RVI_1"+CharToStr(9);
     }
   if(e_iSAR)s1=s1+"SAR"+CharToStr(9);
   if(e_iStdDev)s1=s1+"StdDev"+CharToStr(9);
   if(e_iStochastic)
     {
      s1=s1+"Stochastic_0"+CharToStr(9);
      s1=s1+"Stochastic_1"+CharToStr(9);
     }
   if(e_iWPR)s1=s1+"WPR"+CharToStr(9);
   s1=StringSubstr(s1,0,StringLen(s1)-1);
   s1=s1+CharToStr(13)+CharToStr(10);
   FileWriteString(hand,s1);

   int i1,len1=Bars-o_begin;
   if(o_cases!=0)
   {
      if(len1>o_cases)len1=o_cases;
   }
   for(i1=len1-1;i1>=0;i1--)
     {
      dt1=Time[i1];
      s1="";
      if(s_time) s1=s1+TimeToString(dt1)+CharToStr(9);
      if(s_time_dayofweek) s1=s1+IntegerToString(TimeDayOfWeek(dt1))+CharToStr(9);
      if(s_time_hour) s1=s1+IntegerToString(TimeHour(dt1))+CharToStr(9);
      if(s_time_minute) s1=s1+IntegerToString(TimeMinute(dt1))+CharToStr(9);
      if(s_iOpen)s1=s1+DoubleToStr(Open[i1],Digits)+CharToStr(9);
      if(s_iHigh)s1=s1+DoubleToStr(High[i1],Digits)+CharToStr(9);
      if(s_iLow)s1=s1+DoubleToStr(Low[i1],Digits)+CharToStr(9);
      if(s_iClose)s1=s1+DoubleToStr(Close[i1],Digits)+CharToStr(9);
      if(s_iVolume)s1=s1+IntegerToString(Volume[i1])+CharToStr(9);

      if(e_iAC)s1=s1+DoubleToStr(iAC(Symbol(),Period(),i1),o_digits)+CharToStr(9);
      if(e_iAD)s1=s1+DoubleToStr(iAD(Symbol(),Period(),i1),o_digits)+CharToStr(9);
      if(e_iADX)
        {
         s1=s1+DoubleToStr(iADX(Symbol(),Period(),o_period,o_price,0,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iADX(Symbol(),Period(),o_period,o_price,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iADX(Symbol(),Period(),o_period,o_price,2,i1),o_digits)+CharToStr(9);
        }
      if(e_iAO)s1=s1+DoubleToStr(iAO(Symbol(),Period(),i1),o_digits)+CharToStr(9);
      if(e_iATR)s1=s1+DoubleToStr(iATR(Symbol(),Period(),o_period,i1),o_digits)+CharToStr(9);
      if(e_iAlligator)
        {
         s1=s1+DoubleToStr(iAlligator(Symbol(),Period(),jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,o_ma,o_price,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iAlligator(Symbol(),Period(),jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,o_ma,o_price,2,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iAlligator(Symbol(),Period(),jaw_period,jaw_shift,teeth_period,teeth_shift,lips_period,lips_shift,o_ma,o_price,3,i1),o_digits)+CharToStr(9);
        }
      if(e_iBWMFI)s1=s1+DoubleToStr(iBWMFI(Symbol(),Period(),i1),o_digits)+CharToStr(9);
      if(e_iBands)
        {
         s1=s1+DoubleToStr(iBands(Symbol(),Period(),o_period,deviation,bands_shift,o_price,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iBands(Symbol(),Period(),o_period,deviation,bands_shift,o_price,2,i1),o_digits)+CharToStr(9);
        }
      if(e_iBearsPower)s1=s1+DoubleToStr(iBearsPower(Symbol(),Period(),o_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iBullsPower)s1=s1+DoubleToStr(iBullsPower(Symbol(),Period(),o_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iCCI)s1=s1+DoubleToStr(iCCI(Symbol(),Period(),o_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iDeMarker)s1=s1+DoubleToStr(iDeMarker(Symbol(),Period(),o_period,i1),o_digits)+CharToStr(9);
      if(e_iEnvelopes)
        {
         s1=s1+DoubleToStr(iEnvelopes(Symbol(),Period(),o_period,o_ma,ma_shift,o_price,deviation1,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iEnvelopes(Symbol(),Period(),o_period,o_ma,ma_shift,o_price,deviation1,2,i1),o_digits)+CharToStr(9);
        }
      if(e_iForce)s1=s1+DoubleToStr(iForce(Symbol(),Period(),o_period,o_ma,o_price,i1),o_digits)+CharToStr(9);
      if(e_iFractals)
        {
         s1=s1+DoubleToStr(iFractals(Symbol(),Period(),1, i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iFractals(Symbol(),Period(),2, i1),o_digits)+CharToStr(9);
        }
      if(e_iGator)
        {
         s1=s1+DoubleToStr(iGator(Symbol(),Period(),jaw_period1,jaw_shift1,teeth_period1,teeth_shift1,lips_period1,lips_shift1,o_ma,o_price,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iGator(Symbol(),Period(),jaw_period1,jaw_shift1,teeth_period1,teeth_shift1,lips_period1,lips_shift1,o_ma,o_price,2,i1),o_digits)+CharToStr(9);
        }
      if(e_iIchimoku)
        {
         s1=s1+DoubleToStr(iIchimoku(Symbol(),Period(),tenkan_sen,kijun_sen,senkou_span_b,1,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iIchimoku(Symbol(),Period(),tenkan_sen,kijun_sen,senkou_span_b,2,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iIchimoku(Symbol(),Period(),tenkan_sen,kijun_sen,senkou_span_b,3,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iIchimoku(Symbol(),Period(),tenkan_sen,kijun_sen,senkou_span_b,4,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iIchimoku(Symbol(),Period(),tenkan_sen,kijun_sen,senkou_span_b,5,i1),o_digits)+CharToStr(9);
        }
      if(e_iMA)s1=s1+DoubleToStr(iMA(Symbol(),Period(),o_period,ma_shift1,o_ma,o_price,i1),o_digits)+CharToStr(9);
      if(e_iMACD)
        {
         s1=s1+DoubleToStr(iMACD(Symbol(),Period(),fast_ema_period1,slow_ema_period1,signal_period1,o_price,0, i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iMACD(Symbol(),Period(),fast_ema_period1,slow_ema_period1,signal_period1,o_price,1, i1),o_digits)+CharToStr(9);
        }
      if(e_iMFI)s1=s1+DoubleToStr(iMFI(Symbol(),Period(),o_period,i1),o_digits)+CharToStr(9);
      if(e_iMomentum)s1=s1+DoubleToStr(iMomentum(Symbol(),Period(),o_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iOBV)s1=s1+DoubleToStr(iOBV(Symbol(),Period(),o_price,i1),o_digits)+CharToStr(9);
      if(e_iOsMA)s1=s1+DoubleToStr(iOsMA(Symbol(),Period(),fast_ema_period,slow_ema_period,signal_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iRSI)s1=s1+DoubleToStr(iRSI(Symbol(),Period(),o_period,o_price,i1),o_digits)+CharToStr(9);
      if(e_iRVI)
        {
         s1=s1+DoubleToStr(iRVI(Symbol(),Period(),o_period,0,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iRVI(Symbol(),Period(),o_period,1,i1),o_digits)+CharToStr(9);
        }
      if(e_iSAR)s1=s1+DoubleToStr(iSAR(Symbol(),Period(),step,maximum,i1),o_digits)+CharToStr(9);
      if(e_iStdDev)s1=s1+DoubleToStr(iStdDev(Symbol(),Period(),o_period,ma_shift2,o_ma,o_price,i1),o_digits)+CharToStr(9);
      if(e_iStochastic)
        {
         s1=s1+DoubleToStr(iStochastic(Symbol(),Period(),Kperiod,Dperiod,slowing,o_ma,(int)price_field,0,i1),o_digits)+CharToStr(9);
         s1=s1+DoubleToStr(iStochastic(Symbol(),Period(),Kperiod,Dperiod,slowing,o_ma,(int)price_field,1,i1),o_digits)+CharToStr(9);
        }
      if(e_iWPR)s1=s1+DoubleToStr(iWPR(Symbol(),Period(),o_period,i1),o_digits)+CharToStr(9);

      s1=StringSubstr(s1,0,StringLen(s1)-1);
      s1=s1+CharToStr(13)+CharToStr(10);
      FileWriteString(hand,s1);
     }
   FileClose(hand);
   
   MessageBox("Ok:  "+IntegerToString(len1)+" records","Ok");
  }
//+------------------------------------------------------------------+
