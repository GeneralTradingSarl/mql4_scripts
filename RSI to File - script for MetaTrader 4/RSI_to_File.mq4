//+------------------------------------------------------------------+
//|                                                  RSI_to_File.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

#property show_inputs
string SymbolsArray[13]={"","USDCHF","GBPUSD","EURUSD","USDJPY","AUDUSD","USDCAD","EURGBP","EURAUD","EURCHF","EURJPY","GBPJPY","GBPCHF"};

//+------------------------------------------------------------------+
//| string SymbolByNumber                                   |
//+------------------------------------------------------------------+
string GetSymbolString(int Number)
  {
//----
   string res="";
   res=SymbolsArray[Number];   
//----
   return(res);
  }

//+------------------------------------------------------------------+
//| возвращает период                                                |
//+------------------------------------------------------------------+
int PeriodNumber(int number)
   {
   int per_min;
   switch (number)
      {
      case 0: per_min=PERIOD_M1;break;
      case 1: per_min=PERIOD_M5;break;
      case 2: per_min=PERIOD_M15;break;
      case 3: per_min=PERIOD_M30;break;
      case 4: per_min=PERIOD_H1;break;
      case 5: per_min=PERIOD_H4;break;
      default: per_min=PERIOD_D1;break;
      }
   return(per_min);   
   }

//+------------------------------------------------------------------+
//|   выводит в файл котировки + значения индикатора                 |
//+------------------------------------------------------------------+
void RSI_output(string SymbolName,int PeriodMinutes)
   {
   int size=iBars(SymbolName,PeriodMinutes);
//----
   if (size==0) return;
   int handle=FileOpen(SymbolName+PeriodMinutes+"_RSI.csv",FILE_WRITE|FILE_CSV);
   if (handle<0) return;
   FileWrite(handle,"Time seconds;Time;Open;Low;High;Close;Volume;RSI");
   for (int i=size-1;i>=0;i--)
      {
      FileWrite(handle,iTime(SymbolName,PeriodMinutes,i),TimeToStr(iTime(SymbolName,PeriodMinutes,i))
         ,iOpen(SymbolName,PeriodMinutes,i),iLow(SymbolName,PeriodMinutes,i),iHigh(SymbolName,PeriodMinutes,i)
         ,iClose(SymbolName,PeriodMinutes,i),iVolume(SymbolName,PeriodMinutes,i),iCustom(SymbolName,PeriodMinutes,"RSI",0,i));
      }
   FileClose(handle);      
//----
   return;
   }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  int SymbolCounter,PeriodCounter; 
//----
   for (SymbolCounter=1;SymbolCounter<13;SymbolCounter++)
      {
      for (PeriodCounter=2;PeriodCounter<=6;PeriodCounter++)
         {
         //Print("NewBar on ",GetSymbolString(SymbolCounter),PeriodNumber(PeriodCounter),"M");
         RSI_output(GetSymbolString(SymbolCounter),PeriodNumber(PeriodCounter));
         }
      }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+