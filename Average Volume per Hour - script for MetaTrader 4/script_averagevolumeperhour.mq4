//+------------------------------------------------------------------+
//|                                  Script_AverageVolumePerHour.mq4 |
//|                                                         M Wilson |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "M Wilson"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- This script should only work on the 1 hour timeframe
   if(PeriodSeconds()!=3600)
     {
      Alert(__FILE__+", Script should only be run on the 1hr timeframe");
      return;
     }

//--- Get the number of bars
   int intBars=Bars;

//--- Initiate 2 24 hour arrays to contain the average and the count.
   double dblAverageVolume[24];
   int intCount[24];
   ArrayFill(dblAverageVolume,0,24,0);
   ArrayFill(intCount,0,24,0);

//--- Scan through the vars updating the average volume
   for(int i=0;i<intBars;i++)
     {
      //Get the array index, ie the hour
      int intHour=TimeHour(iTime(Symbol(),0,i));

      //Get the volune
      double dblVolume=MathAbs((double)iVolume(Symbol(),0,i));

      //Update the array
      dblAverageVolume[intHour]=(dblAverageVolume[intHour]*intCount[intHour]+dblVolume)/(intCount[intHour]+1);
      intCount[intHour]++;
     }

//--- Once we have all of the data, build a message box
   string strVolume="";
   for(int i=0;i<24;i++)
     {
      strVolume+="Hr "+IntegerToString(i)+" -> "+DoubleToString(dblAverageVolume[i],2)+"\n";

     }
   MessageBox(strVolume);

  }
//+------------------------------------------------------------------+
