
//#property show_confirm
#include <stdlib.mqh>   
   
   


//+------------------------------------------------------------------+
//| script "modify first market order of this chart symbol"          |
//+------------------------------------------------------------------+
int start()
  { 
   double Price_to_delete = WindowPriceOnDropped();
   bool   result;
   double stop_loss,point;
   int    cmd,total,error;
//----
   int NrOfDigits = MarketInfo(Symbol(),MODE_DIGITS);   // Nr. of decimals used by Symbol
   int PipAdjust;                                       // Pips multiplier for value adjustment
      if(NrOfDigits == 5 || NrOfDigits == 3)            // If decimals = 5 or 3
         PipAdjust = 10;                                // Multiply pips by 10
         else
      if(NrOfDigits == 4 || NrOfDigits == 2)            // If digits = 4 or 3 (normal)
         PipAdjust = 1;          
   
//----
   total=OrdersTotal();
   point=MarketInfo(Symbol(),MODE_POINT);
//----
   for(int i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
        if(OrderSymbol() == Symbol())
         {        
         //---- print selected order
         cmd=OrderType();
         //---- buy or sell orders are considered
         if(cmd!=OP_BUY && cmd!=OP_SELL && Price_to_delete <= OrderOpenPrice() + 0.0002 && Price_to_delete >= OrderOpenPrice() - 0.0002) 
           {
            OrderPrint();
            //---- modify first pending order
            while(true)
              {
               result=OrderDelete(OrderTicket());
               if(result!=TRUE) { error=GetLastError(); Print("LastError = ",error); }
               else error=0;
               if(error==135) RefreshRates();
               else break;
              }
             //---- print modified order (it still selected after modify)
             OrderPrint();
             break;
           }
         } // end if OrderSymbol() == Symbol()           
       }
      else { Print( "Error when order select ", GetLastError()); break; }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+