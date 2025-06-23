//+------------------------------------------------------------------+
//|                                                    TestStops.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#include "..\libraries\stdlib.mq4"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  { 
   int    ticket;                                         // номер тикета 
   int    digits   =MarketInfo(Symbol(),MODE_DIGITS);     // сохраним количество знаков
   double volume   =MarketInfo(Symbol(),MODE_MINLOT);     // сохраним минимальный лот
   double stoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);  // сохраним минимальный отступ
//---- покажем настройки
   Print("ћинимальный лот: ",volume," минимальный отступ: ",stoplevel);
//---- попробуем открыть позицию по рынку с максимально близко 
//---- установленными StopLoss и TakeProfit, покупаем по аску
//---- показываем, что открыватьс€ можно с отступом в stoplevel пунктов
   ticket=OrderSend(Symbol(),OP_BUY,volume,Ask,2,
                    NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                    NormalizeDouble(Bid+stoplevel*Point,digits));  // TP
   if(ticket<1) 
     {
      Print("Ўаг 1: ошибка ",ErrorDescription(GetLastError())); 
      return(-1); 
     }
//---- выделим только что открытый ордер и обновим рыночное окружение
   if(OrderSelect(ticket,SELECT_BY_TICKET)==false)
     {
      Print("Ўаг 2: ошибка ",ErrorDescription(GetLastError())); 
      return(-2);
     }
   RefreshRates();  // обновим рыночное окружение
//---- попробуем модифицировать StopLoss, не трога€ TakeProfit
//---- отодвинем стоп-лосс на 2 пипса (может и не получитьс€, если рынок дернетс€)
//---- показываем, что TakeProfit не провер€етс€, если он не изменилс€
   if(OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()-2*Point,OrderTakeProfit(),0)==false)
     {
      Print("Ўаг 3: ошибка ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- удалим стопы, ничего не показываем, просто подготовка к следующему шагу
   if(OrderModify(ticket,OrderOpenPrice(),0,0,0)==false)
     {
      Print("Ўаг 4: ошибка ",ErrorDescription(GetLastError())); 
      return(-4);
     }
   RefreshRates();  // обновим рыночное окружение
//---- попробуем снова выставить стопы вплотную к рынку
//---- показываем, что StopLoss и TakeProfit нормально став€тс€
   if(OrderModify(ticket,OrderOpenPrice(),
                  NormalizeDouble(Bid-stoplevel*Point,digits),   // SL
                  NormalizeDouble(Bid+stoplevel*Point,digits),   // TP
                  0)==false)
     {
      Print("Ўаг 5: ошибка ",ErrorDescription(GetLastError())); 
      return(-3);
     }
//---- тест закончен
   Print("“ест успешно завершен!");
   return(0);
  }
//+------------------------------------------------------------------+