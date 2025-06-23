//+------------------------------------------------------------------+
//|                                            closeall_complete.mq4 |
//|                                                   Enrico Lambino |
//|                                          enricolambino@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino"
#property link      "enricolambino@yahoo.com"
#property version   "1.00"
#property strict
#property show_inputs
#property description "combines all the functionalities of closeall_symbol, closeall_magic, closeall_type,"
#property description "closeall_loss, closeall_profit, and closeall_comment"

#include <order_exit.mqh>

input bool order_exact=true; //exact match
input string order_symbol=NULL; // order symbol
input int order_magic=-1; // order magic number
input position order_type=ALL; // order type
input double order_loss = -1.0; // order loss threshold 
input double order_profit=-1.0; // order profit threshold 
input string order_comment=NULL; // order comment
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

void OnStart()
  {
//---   
   while(closeAll()){Sleep(1000);}
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool closeAll()
  {
   int not_closed=0;
   int total=OrdersTotal();
   for(int i=total-1;i>=0;i--)
      if(!exitOrder(i,SELECT_BY_POS,order_exact,order_magic,order_symbol,order_type,order_loss,order_profit,order_comment))
         not_closed++;
   return(not_closed);
  }
//+------------------------------------------------------------------+
