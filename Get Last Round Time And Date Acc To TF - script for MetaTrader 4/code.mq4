//+------------------------------------------------------------------+
//|                       Get Last Round Time And Date Acc To TF.mq4 |
//|                                                         IronFist |
//|                         https://www.mql5.com/en/users/sahilbagdi |
//+------------------------------------------------------------------+
#property copyright "IronFist"
#property link      "https://www.mql5.com/en/users/sahilbagdi"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Get Last Round Time And Date Acc To TF                            |
//+------------------------------------------------------------------+
datetime Get_Last_Round_Time_And_Date_Acc_To_TF(datetime From, int TimeFrame)
{
int Minutes = ((int)From - (int)(datetime)(TimeToString(From,TIME_DATE)+" 00:00:00"))/60;
int Min = Minutes-(Minutes%TimeFrame); string Date = "1970.01.01"; string _Hour_ = (string)((Min-Min%60)/60); string _Minutes_ = (string)((Min%60)%60);
return((datetime)TimeToString(From,TIME_DATE) + (datetime)(Date+" "+_Hour_+":"+_Minutes_+":00"));
}