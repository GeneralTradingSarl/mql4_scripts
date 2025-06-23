//+------------------------------------------------------------------+
//| PZ_DeleteAllPendingOrders.mq4
//| --
//| This script deletes all non-executed pending orders.
//+------------------------------------------------------------------+
#property copyright "Copyright © http://www.pointzero-trading.com"
#property link      "http://www.pointzero-trading.com"

//---- Dependencies
#import "stdlib.ex4"
   string ErrorDescription(int e);
#import
#include <stdlib.mqh>
#include <WinUser32.mqh>

//-- Don't change me
#define  ShortName            "PZ Delete All Pending Orders"
#define  Shift                1

//-- Internal
double   LastOrderLots = EMPTY_VALUE;
double   LastOrderPrice;
double   DecimalPip;

//+------------------------------------------------------------------+
//| Custom Script start function                           
//+------------------------------------------------------------------+
int start()
{
   // Confirm
   if(MessageBox(ShortName +" - Do you really want to delete all pending orders?",
                 "Script",MB_YESNO|MB_ICONQUESTION)!=IDYES) return(1);
  
   // Order type
   int Type;
   
   // Iterate orders
	for(int i = OrdersTotal()-1; i >= 0; i--)
	{
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES); Type = OrderType();
		if(OrderSymbol() == Symbol())
		{ 
	      if(Type == OP_BUYSTOP || Type == OP_SELLSTOP || Type == OP_BUYLIMIT || Type == OP_SELLLIMIT)  
	      {
            if(!OrderDelete(OrderTicket()))
               Print(ShortName +" (OrderDelete Error) "+ ErrorDescription(GetLastError()));
         }
      }
   }

   // Hi there!
   Comment("Copyright © http://www.pointzero-trading.com");
   
   // Bye
   return(0);
}


