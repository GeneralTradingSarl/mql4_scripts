//+------------------------------------------------------------------+
//|                                                  close_all-e.mq4 |
//|                                         Copyright 2015, eevviill |
//|                                     http://alievtm.blogspot.com/ |
//+------------------------------------------------------------------+
#property copyright "eevviill"
#property link      "http://alievtm.blogspot.com/"
#property show_inputs
#property strict
#property version "2.1"

extern string ma = "Main";
extern int magic = -1;
extern bool all_symbols=true;

extern string emp1= "//////////////////////////////////////////";
extern string t_o = "Type of order";
extern bool close_only_buy=false;
extern bool close_only_sell=false;
extern bool delete_pending_orders=false;

extern string emp2="///////////////////////////////////////////";
extern string p_l_o="Type of profit";
extern bool close_only_profit_orders=false;
extern bool close_only_lose_orders=false;

extern string emp3= "//////////////////////////////////////////";
extern string o_s = "Order close settings";
extern int MaxAttempts=14;
extern double pause_if_trade_buzy=0.2;
extern int slippage=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   double order_prof;
   bool ticket_ex;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderMagicNumber()==magic || magic==-1)
           {
            if(OrderSymbol()==Symbol() || all_symbols)
              {
               ticket_ex=false;
               order_prof=OrderProfit()+OrderSwap()+OrderCommission();
               for(int j_ex=0;j_ex<MaxAttempts; j_ex++)
                 {
                  while(IsTradeContextBusy()) Sleep(int(pause_if_trade_buzy*1000));
                  RefreshRates();
                  //---
                  if(OrderType()==OP_BUY
                     && !close_only_sell
                     && (!close_only_profit_orders || order_prof>0)
                     && (!close_only_lose_orders || order_prof<0)
                     ) ticket_ex=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),int(MarketInfo(OrderSymbol(),MODE_DIGITS))),slippage,clrNONE);
                  //---
                  else
                     if(OrderType()==OP_SELL
                        && !close_only_buy
                        && (!close_only_profit_orders || order_prof>0)
                        && (!close_only_lose_orders || order_prof<0)
                        ) ticket_ex=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),int(MarketInfo(OrderSymbol(),MODE_DIGITS))),slippage,clrNONE);
                  //---
                  else
                     if(delete_pending_orders && (OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYLIMIT)) ticket_ex=OrderDelete(OrderTicket(),clrNONE);
                  //--- no closing
                  else
                     ticket_ex=true;

                  if(ticket_ex)break;
                 }//end for2
              }//end symbol
           }//end magic number
        }//end order select
     }//end for1
  }//end on start
//+------------------------------------------------------------------+
