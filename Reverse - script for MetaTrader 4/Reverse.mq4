//+------------------------------------------------------------------+
//|                                                      Reverse.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|  16.12.2005  Скрипт переворачивает имеющиеся позиции.            |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
  double Lots;
  int    op;
  for (int i=OrdersTotal()-1; i>=0; i--) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
        op=OrderType();
        if (op==OP_BUY) {
          Lots=OrderLots();
          OrderClose(OrderTicket(),OrderLots(),Bid,7,CLR_NONE);
          OrderSend(Symbol(),OP_SELL,Lots,Bid,7,0,0,"Reverse",0,0,CLR_NONE);
        }
        if (op==OP_SELL) {
          Lots=OrderLots();
          OrderClose(OrderTicket(),OrderLots(),Ask,7,CLR_NONE);
          OrderSend(Symbol(),OP_BUY,Lots,Ask,7,0,0,"Reverse",0,0,CLR_NONE);
        }
      }
    }
  }
}
//+------------------------------------------------------------------+

