//+------------------------------------------------------------------+
//|                                                       Коэф_ф.mq4 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"

#property show_inputs

 #define STOPOUT 0.8

 extern bool fixedfrac=true;
 extern double f = 0.1 ;
 extern int stoploss = -100 ; // зависит от системы
 extern double maxlot = 0 ;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----

   double b = Lots ();
   if (Lots ()>0)Alert("Лоты: ",b);
   else Alert("Упс! Неподсчитало. ",b);   
//----
   return(0);
  }
//+------------------------------------------------------------------+

 double Lots ()
  {
   double a, b, lot;

   if (! fixedfrac) return (f) ;

   if (f < 0.01 || f > STOPOUT || stoploss >= 0)
   return (0.1) ;

   a = NormalizeDouble (AccountBalance () / MarketInfo (Symbol (), MODE_MARGINREQUIRED) - 0.1, 2) ;
   b = NormalizeDouble (AccountBalance () / ((-stoploss*MarketInfo(Symbol (), MODE_TICKVALUE)) / f), 2) ;
   if (a < b)
    lot = a ;
   else lot = b ;

   if (maxlot > 0)
     return (MathMin (maxlot, MathMax (lot, 0.1))) ;
   else
  return (MathMax (lot, 0.1)) ;
 }