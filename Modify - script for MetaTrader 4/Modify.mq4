//+------------------------------------------------------------------+
//|                                                       modify.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#property show_confirm

//+------------------------------------------------------------------+
//| script "modify first market order"                               |
//+------------------------------------------------------------------+
int start()
  {
   bool   result;
   double stop_loss,point;
   int    cmd,total,nTicket;
//----
   total=OrdersTotal();
   point=MarketInfo(Symbol(),MODE_POINT);
//----
   for(int i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
        
         cmd=OrderType();
         //---- buy or sell orders are considered
         if(cmd==OP_BUY || cmd==OP_SELL)
           {
            //---- print selected order
            OrderPrint();
            //---- modify first market order
            while(true)
              {
               if(cmd==OP_BUY) stop_loss=Bid-20*point;
               else            stop_loss=Ask+20*point;
               nTicket=OrderTicket();
               result=OrderModify(nTicket,0,stop_loss,0,0,CLR_NONE);
               if(result!=TRUE) Print("LastError = ", GetLastError());
               if(result==135) RefreshRates();
               else break;
              }
             //---- print modified order (it still selected after modify)
             if(OrderSelect(nTicket,SELECT_BY_TICKET)) OrderPrint();
             break;
           }
        }
      else { Print( "Error when order select ", GetLastError()); break; }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+