//+------------------------------------------------------------------+
//|                                                      Ard_Buy.mq4 |
//|                                     Copyright © 2008, ARDIANSYAH |
//|                                               ardfx.blogspot.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Ardiansyah"
#property link      "ardfx.blogspot.com"
#property show_inputs
extern int pembagi = 2;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int ticket;
   int err;
   double Margin;
   Margin = AccountFreeMargin( ) ;
   double Hasil;
   double Lots ;
   Hasil = Margin/pembagi/1000;
   Lots = MathFloor(Hasil);
   while(true)
   {
   ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,0,Ask - 1,0,NULL,0,0,White); 
   if(ticket<0)
       {
        err=GetLastError();
        Print("OrderSend failed with error ",err);
        
        if (err == 135) 
        {
         RefreshRates();
         break;
         }
        }
     else 
     {
     Print("Hasil =", Hasil);
     return(0); 
     }  
      }
   return(0);
  }
//+------------------------------------------------------------------+