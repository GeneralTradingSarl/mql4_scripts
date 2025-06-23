
//+------------------------------------------------------------------+
//|                                               CloseAllLosses.mq4 |
//|                       Copyright © 2008, PRMQuotes Software Corp. |
//|                                           Jedimedic77@gmail.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, PRMQuotes Software Corp."
#property link      ""
//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| global variables to program:                                     |
//+------------------------------------------------------------------+
double Price[2];
int    giSlippage;
bool   CloseOrdersWithMinusProfit = true;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
  int iOrders=OrdersTotal()-1, i;
  
  if(CloseOrdersWithMinusProfit) {
    for(i=iOrders; i>=0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderProfit() <= 0)) {
        if((OrderType()<=OP_SELL) && GetMarketInfo()) {
          if(!OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage)) Print(OrderError());
        }
      }
    }
  }
}
//+------------------------------------------------------------------+
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
string OrderError() {
  int iError=GetLastError();
  return(StringConcatenate("Order:",OrderTicket()," GetLastError()=",iError," ",ErrorDescription(iError)));
}
//+------------------------------------------------------------------+
//| Function..: GetMarketInfo                                        |
//+------------------------------------------------------------------+
bool GetMarketInfo() {
  RefreshRates();
  Price[0]=MarketInfo(OrderSymbol(),MODE_ASK);
  Price[1]=MarketInfo(OrderSymbol(),MODE_BID);
  double dPoint=MarketInfo(OrderSymbol(),MODE_POINT);
  if(dPoint==0) return(false);
  giSlippage=(Price[0]-Price[1])/dPoint;
  return(Price[0]>0.0 && Price[1]>0.0);
}
//+------------------------------------------------------------------+