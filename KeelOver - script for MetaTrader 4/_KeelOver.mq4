//+------------------------------------------------------------------+
//|                                                    _KeelOver.mq4 |
//|                                           "СКРИПТЫ ДЛЯ ЛЕНИВОГО" |
//|                ПЕРЕВОРОТ:  Скрипт закрывает все открытые позиции |
//|                и открывает одну на разницу сумм лотов Buy и Sell |
//|                ВНИМАНИЕ: если суммы лотов Buy и Sell равны - все |
//|                                     позиции просто будут закрыты |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property show_inputs // Если есть желание менять экстерны в процессе
//----
extern int    DistSL    =35;   // StopLoss в пунктах
extern int    DistTP    =35;   // TakeProfit в пунктах
extern int    Slippage  =7;    // Проскальзывание
extern bool   StopLoss  =true; // Ставить или нет
extern bool   TakeProfit=true; // Ставить или нет
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int    Total, i, Pos, ticket, MinLotDgts;
   bool   Result;
   double MinLot=MarketInfo(Symbol(), MODE_MINLOT);
   double SL=0, TP=0, Stake, BuyLots=0, SellLots=0;
   Total=OrdersTotal();
   if(Total > 0) // Если есть ордера
     {
      for(i=Total - 1; i>=0; i--)
        {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)
           {
            Pos=OrderType();
            Stake=OrderLots();
            if((OrderSymbol()==Symbol()) &&
               (Pos==OP_BUY || Pos==OP_SELL)) // Смотрим только открытые Buy и Sell
              {                                   // в активном окне
               if(Pos==OP_BUY)
                 {
                  BuyLots=BuyLots + Stake;    // Суммируем Лоты открытых Buy
                  Result=OrderClose(OrderTicket(), OrderLots(), Bid , Slippage);
                  if(Result!=true)
                     Alert("KeelOver: CloseBuyError = ", GetLastError());
                 }
               else
                 {
                  SellLots=SellLots + Stake;  // Суммируем Лоты открытых Sell
                  Result=OrderClose(OrderTicket(), OrderLots(), Ask , Slippage);
                  if(Result!=true)
                     Alert("KeelOver: CloseSellError = ", GetLastError());
                 }
              }
           }
        }
      if(MinLot < 0.1)
         MinLotDgts=2;
      else
        {
         if(MinLot < 1.0)
            MinLotDgts=1;
         else
            MinLotDgts=0;
        }
      Stake=NormalizeDouble(BuyLots - SellLots, MinLotDgts);
      if(Stake!=0) // Если есть что переворачивать
        {
         if(Stake > 0) // продажей
           {
            RefreshRates();
            if(StopLoss==true)
               SL=NormalizeDouble(Ask + DistSL*Point, Digits);
            if(TakeProfit==true)
               TP=NormalizeDouble(Bid - 2*DistTP*Point, Digits);
            ticket=OrderSend(Symbol(), OP_SELL, Stake, Bid , Slippage, SL, TP, "");
            if(ticket<=0)
               Alert("KeelOver: OpenSellError: ", GetLastError());
           }
         else // покупкой
           {
            Stake=-Stake;
            RefreshRates();
            if(StopLoss==true)
               SL=NormalizeDouble(Bid - DistSL*Point, Digits);
            if(TakeProfit==true)
               TP=NormalizeDouble(Ask + 2*DistTP*Point, Digits);
            ticket=OrderSend(Symbol(), OP_BUY, Stake, Ask , Slippage, SL, TP, "");
            if(ticket<=0)
               Alert("KeelOver: OpenBuyError: ", GetLastError());
           }
        }
      else
         Alert("KeelOver: BuyLots = SellLots");
     }
   return;
  }
//+------------------------------------------------------------------+

