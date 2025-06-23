#property show_inputs
//#property show_confirm

extern double Lots    = 0.1;
extern int Slippage   = 3;
extern int Stop_Loss  = 20;
extern int Take_Profit = 20;

//+------------------------------------------------------------------+
//| script "Open a new Buy Order"                                    |
//+------------------------------------------------------------------+
int start()
  {
   double Price = WindowPriceOnDropped();
   bool   result;
   int    cmd,total,error,slippage;
   
//----
   int NrOfDigits = MarketInfo(Symbol(),MODE_DIGITS);   // Nr. of decimals used by Symbol
   int PipAdjust;                                       // Pips multiplier for value adjustment
      if(NrOfDigits == 5 || NrOfDigits == 3)            // If decimals = 5 or 3
         PipAdjust = 10;                                // Multiply pips by 10
         else
      if(NrOfDigits == 4 || NrOfDigits == 2)            // If digits = 4 or 3 (normal)
         PipAdjust = 1;            
//----   
   
   slippage = Slippage * PipAdjust; 
   
   double stop_loss = Price + Stop_Loss * Point * PipAdjust;
   double take_profit = Price - Take_Profit * Point * PipAdjust; 
   
   if(Bid > Price)
   {
   result = OrderSend(Symbol(),OP_SELLSTOP,Lots,Price,slippage,stop_loss,take_profit,"",0,0,CLR_NONE);
   }
   if(Bid < Price)
   {
   result = OrderSend(Symbol(),OP_SELLLIMIT,Lots,Price,slippage,stop_loss,take_profit,"",0,0,CLR_NONE);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+