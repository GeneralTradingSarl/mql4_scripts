//+------------------------------------------------------------------+
//|                                  close_all_negative2positive.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool mResult, mSel;
bool mResult1, mSel1;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if(OrdersTotal()!=0)
     {
      //---
      //+------------------------------------------------------------------+
      //---
      int mTotal = OrdersTotal();
      for(int i = mTotal-1; i>=0; i--)
        {
         while(!IsTradeAllowed())
            Sleep(100);
         mSel = OrderSelect(i, SELECT_BY_POS);
         int mType   = OrderType();

         mResult = false;

         if(OrderProfit()<0)
           {
            switch(mType)
              {
               case OP_BUY       :
                  mResult = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
                  break;
               case OP_SELL      :
                  mResult = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
                  break;
              }

            if(mResult == false)
              {
               //Alert("Order ", OrderTicket(), " Failed to close. Error:", GetLastError());
               Sleep(2000);
              }
           }
        }
      //---
      //+------------------------------------------------------------------+
      //---
      int mTotal1 = OrdersTotal();
      for(int i1 = mTotal1-1; i1>=0; i1--)
        {
         while(!IsTradeAllowed())
            Sleep(100);
         mSel1 = OrderSelect(i1, SELECT_BY_POS);
         int mType1   = OrderType();

         mResult1 = false;

         switch(mType1)
           {
            case OP_BUY       :
               mResult1 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
               break;
            case OP_SELL      :
               mResult1 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
               break;
           }

         if(mResult1 == false)
           {
            //Alert("Order ", OrderTicket(), " Failed to close. Error:", GetLastError());
            Sleep(2000);
           }
        }
     }
//---

  }
//+------------------------------------------------------------------+
