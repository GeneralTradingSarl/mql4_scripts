//+------------------------------------------------------------------+
//|                                                 CloseOnChart.mq4 |
//|                                   Copyright © 2006, Igor Morozov |
//|                                                               "" |
//+------------------------------------------------------------------+

// This script can be used to quickly close a trade by dragging
// and dropping over it.
#property copyright "Igor Morozov"
#property link      ""
//----
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| script "close position where script was dropped"                 |
//+------------------------------------------------------------------+
int start()
  {
	  int ret = 0;
   double target = PriceOnDropped();
   double within = 2.0;
   int OpenOrdersBuffer[1];
   ArrayResize(OpenOrdersBuffer, OrdersTotal());
   ArrayInitialize(OpenOrdersBuffer, 0);
   int i, j = 0;
   for(i = 0; i < OrdersTotal(); i++)
     {
       if(OrderSelect(i, SELECT_BY_POS))
         {
           if(OrderSymbol() != Symbol())
               continue;
           if((OrderOpenPrice() >= target - within*Point) && 
              (OrderOpenPrice() <= target + within*Point))
             {
               OpenOrdersBuffer[j] = OrderTicket();
               j++;
             }
         }
     }
   if(j > 1)
     {
       for(i = 0; i < j; i++)
         {
           if(MessageBox("Multiple Tickets Found\nClose Ticket " + 
              DoubleToStr(OpenOrdersBuffer[i],0), "Close Order", 
              MB_YESNO|MB_ICONQUESTION) == IDYES)
             {
               if(OrderSelect(OpenOrdersBuffer[i], SELECT_BY_TICKET))
   			             if(OrderClose(OrderTicket(), OrderLots(), GetPrice(OrderType()), 2))
   			                 PlaySound("ok.wav");
             }
         }
     }
   else
       if(j > 0)
         {
           if(MessageBox("Will Close Ticket " + DoubleToStr(OpenOrdersBuffer[0], 0),
              "Close Order", MB_OKCANCEL|MB_ICONQUESTION) == IDOK)
             {
               if(OrderSelect(OpenOrdersBuffer[0], SELECT_BY_TICKET))
   			             if(OrderClose(OrderTicket(), OrderLots(), GetPrice(OrderType()), 2))
   			                 PlaySound("ok.wav");
             }
         }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPrice(int ordertype)
  {
   switch(ordertype)
     {
       case OP_BUY:  return(Bid);
       case OP_SELL: return(Ask);
     }
  }
//+------------------------------------------------------------------+