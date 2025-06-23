//+------------------------------------------------------------------+
//|                                    _HPCS_Third_MT4_EA_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double ld_Open = iOpen(Symbol(),Period(),0); 
   double ld_High = iHigh(Symbol(),Period(),0);
   double ld_Low = Low[0];
   double ld_Close = Close[0];
   
   string ls_OHLC =  "Open Value:"+DoubleToString(ld_Open,Digits())+"_High Value: "+DoubleToString(ld_High,Digits())+"_Low Value: "+DoubleToString(ld_Low,Digits())+"_Close Value: "+DoubleToString(ld_Close,Digits());
   int li_File = FileOpen("Third.csv",FILE_READ|FILE_WRITE|FILE_CSV);
   if(li_File!= INVALID_HANDLE)
   {
      FileWrite(li_File,ls_OHLC);
      FileClose(li_File);
      Print(" Data Writtened inside File");
   }
   
   else
   {
      Print(" error occured while opening file");
   }

    
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
