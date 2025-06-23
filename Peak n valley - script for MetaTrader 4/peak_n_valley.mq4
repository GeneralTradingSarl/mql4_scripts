//+------------------------------------------------------------------+
//|                                                Peak n Valley.mq4 |
//|                                Copyright © 2014, Gold_Specialist |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2014, Gold_Specialist"
#property description "Peak-Valley"
#property version     "1.00"
#property show_inputs

//---- script parameters
input int PeakValley_Period=24;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   double PeakBuffer[],ValleyBuffer[];
   double FastShift=NormalizeDouble((PeakValley_Period/3),0);
   double PVDomain=PeakValley_Period*5;
   int i;
   int TotalBar=Bars-PVDomain;
   ArrayResize(PeakBuffer,TotalBar);
   ArrayResize(ValleyBuffer,TotalBar);
   for(i=0; i<TotalBar; i++)
   {
      PeakBuffer[i]=peak_function(i,PeakValley_Period,FastShift,PVDomain);
      ValleyBuffer[i]=valley_function(i,PeakValley_Period,FastShift,PVDomain);
   }
   
   Sleep(50); 
  }
//+------------------------------------------------------------------+

//====================================================================
// calculate peak
double peak_function(int i,int PeriodPV,int ShiftFast,int DomainPV)
{
   double Peak=0;
   int bsPeak=0;
   
   for(int pw=i+ShiftFast;pw<=i+DomainPV;pw++)
   if(iHigh(NULL,0,pw)>=High[iHighest(NULL,0,MODE_HIGH,ShiftFast,pw-ShiftFast)])
   {
      if(iHigh(NULL,0,pw)>=High[iHighest(NULL,0,MODE_HIGH,ShiftFast,pw+1)])
      {
         for(int Apw=pw-ShiftFast;Apw>=pw-(PeriodPV-ShiftFast);Apw--)
         if(iHigh(NULL,0,pw)==High[iHighest(NULL,0,MODE_HIGH,PeriodPV,Apw)])
         {
            Peak=iHigh(NULL,0,pw);
            bsPeak=pw;
            if(ObjectFind(0,"Peak Period: "+IntegerToString(PeakValley_Period)+" Time: "+TimeToStr(iTime(NULL,0,pw),TIME_DATE|TIME_MINUTES))==-1)
            {
               string objPeak = "Peak Period: "+IntegerToString(PeakValley_Period)+" Time: "+TimeToStr(iTime(NULL,0,pw),TIME_DATE|TIME_MINUTES);
               ObjectCreate(objPeak, OBJ_ARROW, 0, iTime(NULL,0,pw), iHigh(NULL,0,pw));
               ObjectSet(objPeak, OBJPROP_COLOR, clrBlue);
               ObjectSet(objPeak, OBJPROP_ARROWCODE, 117);
               ObjectSet(objPeak, OBJPROP_WIDTH, 1);
               ObjectSet(objPeak, OBJPROP_BACK, true);
            }
            break;
         }
         if(bsPeak>0)break;else continue;   
      }
   }
   
   return(Peak);
}

//====================================================================
// calculate valley
double valley_function(int i,int PeriodPV,int ShiftFast,int DomainPV)
{
   double Valley=0;
   int bsValley=0;
   
   for(int vw=i+ShiftFast;vw<=i+DomainPV;vw++)
   if(iLow(NULL,0,vw)<=Low[iLowest(NULL,0,MODE_LOW,ShiftFast,vw-ShiftFast)])
   {
      if(iLow(NULL,0,vw)<=Low[iLowest(NULL,0,MODE_LOW,ShiftFast,vw+1)])
      {
         for(int Avw=vw-ShiftFast;Avw>=vw-(PeriodPV-ShiftFast);Avw--)
         if(iLow(NULL,0,vw)==Low[iLowest(NULL,0,MODE_LOW,PeriodPV,Avw)])
         {
            Valley=iLow(NULL,0,vw);
            bsValley=vw;
            if(ObjectFind(0,"Valley Period: "+IntegerToString(PeakValley_Period)+" Time: "+TimeToStr(iTime(NULL,0,vw),TIME_DATE|TIME_MINUTES))==-1)
            {
               string objValley = "Valley Period: "+IntegerToString(PeakValley_Period)+" Time: "+TimeToStr(iTime(NULL,0,vw),TIME_DATE|TIME_MINUTES);
               ObjectCreate(objValley, OBJ_ARROW, 0, iTime(NULL,0,vw), iLow(NULL,0,vw));
               ObjectSet(objValley, OBJPROP_COLOR, clrRed);
               ObjectSet(objValley, OBJPROP_ARROWCODE, 117);
               ObjectSet(objValley, OBJPROP_WIDTH, 1);
               ObjectSet(objValley, OBJPROP_BACK, true);
            }
            break;
         }
         if(bsValley>0)break;else continue;      
      }
   }
   
   return(Valley);
}
