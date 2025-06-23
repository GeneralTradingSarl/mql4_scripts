//+------------------------------------------------------------------+
#property copyright "Copyright © 2012 Matus German, www.MTexperts.net"
//+------------------------------------------------------------------+

int start()
{

   if(WindowOnDropped()!=0)
   {
      Print("ProfitOnDrop must be applied to main chart window!");
      return(false);
   }
   
   double dropPrice=WindowPriceOnDropped();
   double dropTime=WindowTimeOnDropped();
   
   double profit=Profit(dropPrice);
   double curTime=TimeCurrent();

   ObjectCreate("POD_line"+curTime,OBJ_TREND,0,dropTime,dropPrice,curTime,dropPrice);
   ObjectSet("POD_line"+curTime,OBJPROP_RAY,false);
   
   ObjectCreate("POD_price"+curTime,OBJ_TEXT,0,dropTime,dropPrice);
   ObjectSetText("POD_price"+curTime,DoubleToStr(profit,2));
   ObjectSet("POD_price"+curTime,OBJPROP_PRICE1,dropPrice);
   ObjectSet("POD_price"+curTime,OBJPROP_FONTSIZE,12);
   
   if(profit>=0)
   {
      ObjectSet("POD_price"+curTime,OBJPROP_COLOR,Green);
      ObjectSet("POD_line"+curTime,OBJPROP_COLOR,Green);
   }
   else
   {
      ObjectSet("POD_price"+curTime,OBJPROP_COLOR,Red);
      ObjectSet("POD_line"+curTime,OBJPROP_COLOR,Red);
   }
   
   return(0);
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
double Profit(double targetPrice)
{
   double profit=0;
   int total  = OrdersTotal();
   
   for (int cnt = total-1 ; cnt >=0 ; cnt--)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if (OrderSymbol()==Symbol())
      {
         if(OrderType()==OP_BUY)
            profit+=(targetPrice-OrderOpenPrice())*MarketInfo(Symbol(),MODE_LOTSIZE)*OrderLots()+OrderSwap();
         if(OrderType()==OP_SELL) 
            profit+=(OrderOpenPrice()-targetPrice)*MarketInfo(Symbol(),MODE_LOTSIZE)*OrderLots()+OrderSwap();
      }
   }
   return(profit);        
}
//+------------------------------------------------------------------+