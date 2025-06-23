//+------------------------------------------------------------------+
//|                                                       Revers.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                             http://www.metaquotes.ru/forum/6749/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/forum/6749/"

extern int Slippage = 3;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int SymbolOrders;         // количество ордеров по данному символу
   int cnt;                  // счетчик ордеров (обходчик)
   int buyOrders,sellOrders; // количество ордеров в рынке (отложенные не считаем)
   double buyLots,sellLots;  // общий объем открытых ордеров в покупку и продажу
   double reversLot;         // объем разворотного ордера
   int intLots;              // вспомогательная переменная
   int ticket;               // тикет разворотного ордера
//----
   if(!IsDemo()) // защита от случайного запуска на реальном счете
      {
        Alert("Работа на реале запрещена!!!");
        return; // завершение работы скрипта
      }
//----
   if(OrdersTotal() == 0)
      {
        Alert("Ордера не найдены");
        return; // завершение работы скрипта
      }
//----
   for(cnt = OrdersTotal() - 1; cnt >= 0; cnt--) // пройдемся по ордерам
     {
       if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)) // если ордер выбран
          {
            if(OrderSymbol() != Symbol()) 
                continue;  // если выбранный ордер не по нашему символу
            // - переходим к следующему ордеру  
            if(OrderType() == OP_BUY) 
              {
                buyOrders++;                  // увеличим счетчик ордеров в Buy
                buyLots = buyLots + OrderLots();  // увеличим объем ордеров в Buy
              }
            if(OrderType() == OP_SELL) 
              {
                sellOrders++; // увеличим счетчик ордеров в Sell
                sellLots = sellLots + OrderLots();  // увеличим объем ордеров в Sell
              }
          }
     }
   // Ордера сосчитаны, теперь нужно проверить - есть ли ордера в рынке.
   if(buyOrders + sellOrders == 0) 
     {
       Alert("Рыночных ордеров по символу ", Symbol(), " найдено");
       return; // завершение работы скрипта
     }      
   // Дошли до этого места - значит ордера все-таки есть
   if(buyOrders*sellOrders != 0) // мы работаем только либо с ордерами Buy либо Sell, 
                                 // но не с обоими
      {
        Alert("Имеем по символу ", Symbol(), " ", buyOrders, " ордеров в покупку и ", 
              sellOrders, "ордеров в продажу. Работа прекращена");
        return; // завершение работы скрипта
      }
   // Дошли до этого места - значит имеем ордера только одного типа  
   if(buyOrders > 0)
     {
       intLots = 2*10*buyOrders;  // целое двойное количество лотов      
       reversLot = NormalizeDouble(intLots / 10, 1); // получили объем разворотного ордера
       RefreshRates();
       ticket = OrderSend(Symbol(), OP_SELL, reversLot, Bid, Slippage, 0, 0, 
                          "revers order", 0, 0, Red);
       if(ticket < 0)
         {
           Alert("Не удалось открыть ордер SELL ", Symbol(), " ", reversLot, " at ", 
                 Bid, "  Ошибка ", GetLastError());
         }
     }
//----
   if(sellOrders > 0)
     {
       intLots = 2*10*sellOrders; // целое двойное количество лотов      
       reversLot = NormalizeDouble(intLots / 10, 1); // получили объем разворотного ордера
       RefreshRates();
       ticket = OrderSend(Symbol(), OP_BUY, reversLot, Ask, Slippage, 0, 0, 
                          "revers order", 0, 0, Blue);
       if(ticket < 0)
         {
           Alert("Не удалось открыть ордер SELL ", Symbol(), " ", reversLot, " at ", 
                 Ask, "  Ошибка ", GetLastError());
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+