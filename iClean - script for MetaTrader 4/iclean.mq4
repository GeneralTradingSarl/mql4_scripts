//+------------------------------------------------------------------+
//|                                                       iClean.mq4 |
//|                                        Copyright © 2015, Awran5. |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Awran5"
#property description "Clean, Close, Delete all orders."
#property version   "1.00"
#property strict
#property show_inputs

//--- Dependencies
#import "stdlib.ex4"
string ErrorDescription(int e);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Select
  {
   None,             // Select
   break1,           // ---- Clean
   CleanBuy,         // Clean Buy
   CleanSell,        // Clean Sell 
   CleanBuyLimit,    // Clean Buy limit
   CleanSellLimit,   // Clean Sell limit
   CleanBuyStop,     // Clean Buy stop
   CleanSellStop,    // Clean Sell stop 
   break2,           // ---- Close
   CloseBuy,         // Close Buy
   CloseSell,        // Close Sell
   break13,          // ---- Delete
   DeleteBuyLimit,   // Delete Buy limit
   DeleteSellLimit,  // Delete Sell limit
   DeleteBuyStop,    // Delete Buy stop
   DeleteSellStop    // Delete Sell stop
  };
input Select SelectOrders=None;   // Choose Action
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   doAction();
  }
//+------------------------------------------------------------------+
void doAction()
  {
   if(SelectOrders==None) Alert("Please select any Action!");
   else if(SelectOrders == CleanBuy)        CleanAll(0);
   else if(SelectOrders == CleanSell)       CleanAll(1);
   else if(SelectOrders == CloseBuy)        CloseAll(0, Bid);
   else if(SelectOrders == CloseSell)       CloseAll(1, Ask);
//---
   else if(SelectOrders == CleanBuyLimit)   CleanAll(2);
   else if(SelectOrders == CleanSellLimit)  CleanAll(3);
   else if(SelectOrders == CleanBuyStop)    CleanAll(4);
   else if(SelectOrders == CleanSellStop)   CleanAll(5);
//---
   else if(SelectOrders == DeleteBuyLimit)  DeleteAll(2);
   else if(SelectOrders == DeleteSellLimit) DeleteAll(3);
   else if(SelectOrders == DeleteBuyStop)   DeleteAll(4);
   else if(SelectOrders == DeleteSellStop)  DeleteAll(5);
  }
//+------------------------------------------------------------------+
//| CLEAN ALL ORDER'S STOPLOSS AND TAKEPROFIT
//+------------------------------------------------------------------+
void CleanAll(int type)
  {
//----
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()==type)
           {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,0))
               Alert(ErrorDescription(GetLastError()));
            else PlaySound("ok.wav");
           }
     }
//----
  }
//+------------------------------------------------------------------+
//| CLOSE OPENED ORDERS
//+------------------------------------------------------------------+
void CloseAll(int type,double price)
  {
//----
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()==type)
           {
            if(!OrderClose(OrderTicket(),OrderLots(),price,0,clrYellow))
               Alert(ErrorDescription(GetLastError()));
            else PlaySound("ok.wav");
           }
     }
//----
  }
//+------------------------------------------------------------------+
//| DELETE PENDING ORDERS
//+------------------------------------------------------------------+
void DeleteAll(int type)
  {
//----
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()==type)
           {
            if(!OrderDelete(OrderTicket(),0))
               Alert(ErrorDescription(GetLastError()));
            else PlaySound("ok.wav");
           }
     }
//----
  }
//+------------------------------------------------------------------+
//|                           E N D                                  |
//+------------------------------------------------------------------+
