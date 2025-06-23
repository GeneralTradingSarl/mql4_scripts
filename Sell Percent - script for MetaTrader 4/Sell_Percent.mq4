//+---------------------------------------------------------------------------+ 
//| Sell Percent.mq4                                                          |
//| Скрипт открывает позицию SELL размером в процент от максимально возможной |
//+---------------------------------------------------------------------------+
#property copyright "mandorr@gmail.com"
#property show_inputs
//----
#include <WinUser32.mqh>
//----
extern int StopLoss=0;
extern int TakeProfit=11;
extern int Percent=100;
void start()
{
   if (!IsCondition()) return;
   double lots=AccountLots();
   if (lots<=0)
   { 
      string title="Ошибка";
      string msg="Нет свободных средств     ";
      MessageBox(msg,title,MB_OK|MB_ICONERROR);
      return;
   }
   int slippage=2;
   double loss=0  ; if (StopLoss  >0) loss  =Bid+StopLoss  *Point;
   double profit=0; if (TakeProfit>0) profit=Bid-TakeProfit*Point;
   OrderSend(Symbol(),OP_SELL,lots,Bid,slippage,loss,profit,NULL,0,0,CLR_NONE);
   ShowError();
}
double AccountLots()
{
   double freemargin=AccountFreeMargin(); if (freemargin<=0) return (0);
   double lotmargin=0;
   string symbol=Symbol();
   string market=MarketType(symbol);
   if (market=="Forex"  ) lotmargin=LotMarginForex  (symbol);
   if (market=="Metalls") lotmargin=LotMarginCFD    (symbol);
   if (market=="CFD"    ) lotmargin=LotMarginCFD    (symbol);
   if (market=="Futures") lotmargin=LotMarginFutures(symbol);
   if (market=="") return (0);
   double lots=0; if (lotmargin>0) lots=0.01*Percent*freemargin/lotmargin;
   double minlot=MarketInfo(symbol,MODE_MINLOT);
   int count=0; if (minlot>0) count=lots/minlot;
   lots=minlot*count;
   return (lots);
}
string MarketType (string symbol)
{
   int len=StringLen(symbol);
   string base;
   if (StringSubstr(symbol,0,1)=="_") return ("Indexes");
   if (StringSubstr(symbol,0,1)=="#")
   {
      base=StringSubstr(symbol,len-1,1);
      if (base=="0") return ("Futures");
      if (base=="1") return ("Futures");
      if (base=="2") return ("Futures");
      if (base=="3") return ("Futures");
      if (base=="4") return ("Futures");
      if (base=="5") return ("Futures");
      if (base=="6") return ("Futures");
      if (base=="7") return ("Futures");
      if (base=="8") return ("Futures");
      if (base=="9") return ("Futures");
      return ("CFD");
   }
   else
   {
      if (symbol=="GOLD"  ) return ("Metalls");
      if (symbol=="SILVER") return ("Metalls");
      if (len==6)
      {
         base=StringSubstr(symbol,0,3);
         if (base=="AUD") return ("Forex");
         if (base=="CAD") return ("Forex");
         if (base=="CHF") return ("Forex");
         if (base=="EUR") return ("Forex");
         if (base=="GBP") return ("Forex");
         if (base=="LFX") return ("Forex");
         if (base=="NZD") return ("Forex");
         if (base=="SGD") return ("Forex");
         if (base=="USD") return ("Forex");
      }
   }
   return ("");
}
double LotMarginForex (string symbol)
{
   double lotsize=MarketInfo(symbol,MODE_LOTSIZE);
   double leverage=AccountLeverage();
   double result=0; if (leverage>0) result=lotsize/leverage;
   string base=StringSubstr(symbol,0,3);
   string сurrency=AccountCurrency();
   double rate_сurrency=1; if (base!=сurrency) rate_сurrency=MarketInfo(base+сurrency,MODE_BID);
   result=rate_сurrency*result;
   return (result);
}
double LotMarginCFD (string symbol)
{
   double bid_symbol=MarketInfo(symbol,MODE_BID);
   double lotsize=MarketInfo(symbol,MODE_LOTSIZE);
   double leverage=10;
   double result=0; if (leverage>0) result=lotsize*bid_symbol/leverage;
   string сurrency=AccountCurrency();
   double rate_сurrency=1; if (сurrency!="USD") rate_сurrency=MarketInfo(сurrency+"USD",MODE_BID);
   result=rate_сurrency*result;
   return (result);
}
double LotMarginFutures (string symbol)
{
   int len=StringLen(symbol);
   double result=0;
   string base=StringSubstr(symbol,0,len-2);
   if (base=="#ENQ" ) result=3750;
   if (base=="#EP"  ) result=3938;
   if (base=="#SLV" ) result=5063;
   if (base=="#GOLD") result=2363;
   if (base=="#CL"  ) result=4725;
   if (base=="#NG"  ) result=8100;
   if (base=="#W"   ) result= 608;
   if (base=="#S"   ) result=1148;
   if (base=="#C"   ) result= 473;
   string сurrency=AccountCurrency();
   double rate_сurrency=1; if (сurrency!="USD") rate_сurrency=MarketInfo(сurrency+"USD",MODE_BID);
   result=rate_сurrency*result;
   return (result);
}
bool IsCondition()
{
   bool result=true;
   string field="     ";
   string msg;
   string title="Ошибка"; if (AccountNumber()>0)title=AccountNumber()+": "+title;
   if (!IsConnected())
   {
      msg=msg+"Связь с сервером отсутствует"+field;
      result=false;
   }
   if (!IsTradeAllowed())
   {
      if (!result) msg=msg+"\n";
      msg=msg+"Торговля запрещена"+field;
      result=false;
   }
   if (!result) MessageBox(msg,title,MB_OK|MB_ICONERROR);
   return (result);
}
void ShowError()
{
   string description;
   int err=GetLastError();
   switch (err)
   {
      case   0: return;
      case   1: description="Нет ошибки, но результат неизвестен"; break;
      case   2: description="Общая ошибка"; break;
      case   3: description="Неправильные параметры"; break;
      case   4: description="Торговый сервер занят"; break;
      case   5: description="Старая версия клиентского терминала"; break;
      case   6: description="Нет связи с торговым сервером"; break;
      case   7: description="Недостаточно прав"; break;
      case   8: description="Слишком частые запросы"; break;
      case   9: description="Недопустимая операция нарушающая функционирование сервера"; break;
      case  64: description="Счет заблокирован"; break;
      case  65: description="Неправильный номер счета"; break;
      case 128: description="Истек срок ожидания совершения сделки"; break;
      case 129: description="Неправильная цена"; break;
      case 130: description="Неправильные стопы"; break;
      case 131: description="Неправильный объем"; break;
      case 132: description="Рынок закрыт"; break;
      case 133: description="Торговля запрещена"; break;
      case 134: description="Недостаточно денег для совершения операции"; break;
      case 135: description="Цена изменилась"; break;
      case 136: description="Нет цен"; break;
      case 137: description="Брокер занят"; break;
      case 138: description="Новые цены"; break;
      case 139: description="Ордер заблокирован и уже обрабатывается"; break;
      case 140: description="Разрешена только покупка"; break;
      case 141: description="Слишком много запросов"; break;
      case 145: description="Модификация запрещена, так как ордер слишком близок к рынку"; break;
      case 146: description="Подсистема торговли занята"; break;
      case 147: description="Использование даты истечения ордера запрещено брокером"; break;
      default : description="Неизвестная ошибка"; break;
   }
   string field="     ";
   string msg="Ошибка #"+err+" "+description+field;
   string title="Ошибка"; if (AccountNumber()>0)title=AccountNumber()+": "+title;
   MessageBox(msg,title,MB_OK|MB_ICONERROR);
}
// End