#include <stdlib.mqh>   



//+------ CHANGE HERE THE COLOR AND WIDTH OF RESISTANCE LINE --------+

color Resistance_Color = Magenta;   
int   Resistance_Width = 1;         // From 1 (thin) to 5 (thick) 

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double Resistance = WindowPriceOnDropped();
   int TimeNow = TimeCurrent();
   
         ObjectCreate("Resistance_Line" + TimeNow,OBJ_HLINE,0,0,Resistance);
         
         ObjectSet("Resistance_Line" + TimeNow,OBJPROP_COLOR,Resistance_Color);
         ObjectSet("Resistance_Line" + TimeNow,OBJPROP_WIDTH,Resistance_Width);
         
   return(0);
  }
//+------------------------------------------------------------------+