//+------------------------------------------------------------------+
//| CloseAllPositive Scripts  by ***NicoMax***                       |
//|                                                                  |
//| Close All Open order with positive profit                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
extern int    Slippage      = 1;

int start()
  {
  bool   Result;
  int    Pos,Error,Total;
  for(int i=1; i<=OrdersTotal(); i++)
  {      
  if (OrderSelect(i-1,SELECT_BY_POS)==true)
      {   
        if ( OrderProfit()>1)
            {
            Pos=OrderType();
            if(Pos==OP_BUY) 
              Result=OrderClose(OrderTicket(),
                                OrderLots(),
                                Bid,
                                Slippage,
                                CLR_NONE);
              else
              Result=OrderClose(OrderTicket(),
                                OrderLots(),
                                Ask,
                                Slippage,
                                CLR_NONE);
             }
          }
      } 
   return(0);
  }
//+------------------------------------------------------------------+