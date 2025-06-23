//+------------------------------------------------------------------+
//|                                                         open.mq4 |
//|                                                               tk |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "tk"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
string template_ = "np";

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
  long nr;
  nr = ChartOpen(Symbol(),1);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),5);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),15);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),30);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),60);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),240);
  ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),1440); 
  ChartApplyTemplate(nr,template_);
  //nr = ChartOpen(Symbol(),1440); 
  //ChartApplyTemplate(nr,template_);
  nr = ChartOpen(Symbol(),10080);
  ChartApplyTemplate(nr,template_);
  //Print("vvvvvvvvvvvvvvvv"+ChartID());
  }
//+------------------------------------------------------------------+
