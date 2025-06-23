#property show_inputs

extern int _SMMA_PERIOD = 21;

int start()
  {
   int handle = FileOpen( "ema_smma.csv", FILE_CSV | FILE_WRITE, " " );
   for( int i = Bars - 1; i >= 0; i-- )
   {
      double diff = iMA( NULL, 0, _SMMA_PERIOD,       0, MODE_SMMA, PRICE_CLOSE, i ) - 
                    iMA( NULL, 0, 2*_SMMA_PERIOD - 1, 0, MODE_EMA,  PRICE_CLOSE, i ); 
      double diff_n = NormalizeDouble( diff, 8 );              
      FileWrite( handle, "i = ", i, "\t\t difference = ", diff_n );
   }
   FileClose( handle );   
   return(0);
  }