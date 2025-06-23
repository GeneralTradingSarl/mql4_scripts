//+------------------------------------------------------------------+
//|                                                        Euler.mq4 |
//|                              Copyright © 2008, Nazariy S. (WWer) |
//|                         E-mail: nazariy@i.ua, skype: nazariy1309 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Nazariy S. (WWer)"
#property link      "E-mail: nazariy@i.ua, Skype: nazariy1309"


double Factorial(int value)
  {
   if(value<=1) return(1);
   double result=1.0;
   for(;value!=1;value--)
       result*=value;
   return(result);
  }

double getE()
  {
   double e=0.0;
   for(int n=0; n<12; n++)
       e+=1/Factorial(n);
   return(e);
  }

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   Alert(DoubleToStr(getE(),8));
//----
   return(0);
  }
//+------------------------------------------------------------------+