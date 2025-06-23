//+------------------------------------------------------------------+
//|                                               Trader Script1.mq4 |
//|                                                        Oje Uadia |
//|                                         moneyinthesack@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Oje Uadia"
#property link      "moneyinthesack@yahoo.com"
#property show_inputs
#include <stderror.mqh>
#include <stdlib.mqh> 
 extern double lotsize = 0.01;
 extern double takeprofit=65;
 extern double stoploss=40;
 extern bool buy = false;
 extern bool sell =false;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {int ticket;
//----
if (buy==false && sell==false)
{Alert("Invalid settings, choose to buy or sell by setting one of them to true");
Alert("the script must now be relaunched");
return (0);
}
 if (buy==true && sell == true)  
 {
 Alert("Invalid settings! choose to buy or sell by setting one of them to false");
 Alert("the script must now be relaunched");
return (0);
 }
//----
for (int i =0;i<5;i++)
{
if (buy==true)
{
ticket= OrderSend(Symbol(),OP_BUY,lotsize,Ask,7,Ask-stoploss*Point,Ask+takeprofit*Point);
if (ticket>0)
{
Alert("buy order successful");
break;
}
else
Alert("error opening buy order, error code = ", ErrorDescription(GetLastError()));
}
else
if (sell==true)
{
ticket= OrderSend(Symbol(),OP_SELL,lotsize,Bid,7,Bid+stoploss*Point,Bid-takeprofit*Point);
if (ticket>0)
{
Alert("sell order successful");
break;
}
else
Alert("error opening sell order, error code = ", ErrorDescription(GetLastError()));
}
Sleep(3000);
RefreshRates();
}
   return(0);
  }
//+------------------------------------------------------------------+