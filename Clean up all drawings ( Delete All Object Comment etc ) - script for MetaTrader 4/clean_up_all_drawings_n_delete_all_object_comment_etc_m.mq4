//+------------------------------------------------------------------+
//|      Clean up all drawings ( Delete All Object Comment etc ).mq4 |
//|                                                    Dwi Sudarsono |
//|                                        https://t.me/DwiSudarsono |
//+------------------------------------------------------------------+
#property copyright "Dwi Sudarsono"
#property link      "https://t.me/DwiSudarsono"
#property version   "1.00"
#property description   "Clean up all drawings ( Delete All Object Comment etc )"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   ObjectsDeleteAll();
   Comment("");
  }
//+------------------------------------------------------------------+
