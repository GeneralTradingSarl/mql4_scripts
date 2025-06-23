#include <stdlib.mqh>   



//+------ CHANGE HERE RESISTANCE LINE PARAMETERS --------------------+

color Resistance_Color     = Magenta;  //  
int   Resistance_Width     = 2;           // From 1 (thin) to 5 (thick) 
int   Resistance_length    = 4000;        // Length of resistance line. 
bool  Resistance_Ray       = false;       // If "false" resistance line will be drawn as a "segment". If "true", as a "Ray".

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double      Resistance = WindowPriceOnDropped();
   datetime    time = WindowTimeOnDropped();
   int         TimeNow = TimeCurrent();
   int         timeframe = Period();
   double      factor;

   switch(timeframe)
      {
      case 1      : factor = 0.2;   break;
      case 5      : factor = 1;     break;
      case 15     : factor = 3;     break;
      case 30     : factor = 6;     break;
      case 60     : factor = 12;    break;
      case 240    : factor = 48;    break;
      case 1440   : factor = 288;   break;
      case 10080  : factor = 2016;  break;
      case 43200  : factor = 8640;  break;
      }
   
   int length = factor * Resistance_length;

         ObjectCreate("Resistance_Line" + TimeNow,OBJ_TREND,0,time+length,Resistance,time-length,Resistance);        
         ObjectSet("Resistance_Line" + TimeNow,OBJPROP_COLOR,Resistance_Color);
         ObjectSet("Resistance_Line" + TimeNow,OBJPROP_WIDTH,Resistance_Width);
         ObjectSet("Resistance_Line" + TimeNow,OBJPROP_RAY,false);
         
   return(0);
  }
//+------------------------------------------------------------------+