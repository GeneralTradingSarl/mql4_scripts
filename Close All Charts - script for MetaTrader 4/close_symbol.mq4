//+------------------------------------------------------------------+
//|                                                     close tk.mq4 |
//|                                                               tk |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "tk"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {string cs = ChartSymbol();
  long chid=ChartFirst();long pom;
//---
  //ChartAc
  for(int i=0;i<20;i++)
    {pom=ChartNext(chid);if(ChartSymbol(chid)==cs)ChartClose(chid);if(pom==-1)break;chid=pom;}
    
  }
//+------------------------------------------------------------------+
