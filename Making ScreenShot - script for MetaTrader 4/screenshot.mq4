//+------------------------------------------------------------------+
//|                                                    ScreenShot.mq4|
//|                                                      IvanMorozov |
//|                            https://www.mql5.com/ru/users/frostow |
//+------------------------------------------------------------------+
#property copyright "IvanMorozov"
#property link      "https://www.mql5.com/ru/users/frostow"
#property version   "1.00"
//#property show_inputs
input string   dir="//ScreenShots/";//Directory for saving(//name/name/.../)
input bool     play_sound=true;//Play sound
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int x,y;
   long chart_p,width,heigh,width_s,heigh_s;
   datetime put_time=ChartTimeOnDropped();               //Date of throwing 

   width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);    //Chart's width
   heigh = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);   //Chart's hight
   x = ChartXOnDropped();                                //Place of throwing, x
   y = ChartYOnDropped();                                //Place of throwing, y
   width_s = width - x;                                  //ScreenShot's width
   heigh_s = heigh - y;                                  //ScreenShot's hight
   chart_p = ChartPeriod(0);
   string date_time1,date_time2,period,name;

//Current date
   if(ChartPeriod(0)>=1440) date_time1=TimeToString(iTime(NULL,0,0),TIME_DATE);
   else                        date_time1=TimeToString(iTime(NULL,0,0),TIME_DATE|TIME_MINUTES);

//Date of throwing 
   if(ChartPeriod(0)>=1440) date_time2=TimeToString(put_time,TIME_DATE);
   else                        date_time2=TimeToString(put_time,TIME_DATE|TIME_MINUTES);

//Period
   if(chart_p == 43200) period = "MN1";
   if(chart_p == 10080) period = "W1";
   if(chart_p == 1440) period = "D1";
   if(chart_p == 240) period = "H4";
   if(chart_p == 60) period = "H1";
   if(chart_p<60) period="M"+IntegerToString(chart_p);

   name=(dir+Symbol()+
         "/"+
         Symbol()+
         " "+
         period+
         " from "+
         date_time2+
         " to "+
         date_time1+
         ".gif"
         );

//Making ScreenShot
   if(!WindowScreenShot(name,width_s,heigh_s)) Alert(GetLastError());
   else if(play_sound) PlaySound("alert.wav");
  }
//+------------------------------------------------------------------+
