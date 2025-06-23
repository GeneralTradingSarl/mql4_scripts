//+------------------------------------------------------------------+
//|   21 декабря 2008 г.                            Расчёт лотов.mq4 |
//|                                                     Yuriy Tokman |
//|  ICQ# 481971287                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com  ICQ# 481971287 "

#property show_inputs

extern double Задать_процент = 10; // Размер лота

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   double Prots = Задать_процент/100;
   double Lots=MathFloor(AccountFreeMargin()*Prots/MarketInfo(Symbol(),MODE_MARGINREQUIRED)
               /MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);// Лоты 
   Alert ("Колл.лотов ", Lots);
//----
   return(0);
  }
//+------------------------------------------------------------------+