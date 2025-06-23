//+------------------------------------------------------------------+
//|                                             live-limit-ctrlA.mq4 |
//|                                Copyright © 2009, Borys Chekmasov |
//|                                     http://uatrader.blogspot.com |
//|                                     version 2.3                  |
//+------------------------------------------------------------------+
//| Скрипт предназначен для комфортной пипсовки лимитниками на живом |
//| графике. Создайте на графике линию с именем "GO!". Перетащите ее |
//| на   уровень,   с   которого   планируется   осуществлять   вход.| 
//| Для активации ордера нажмите горячую клавишу активации скрипта   |
//| активируется ордер с выставленным риском (MoneyRisk, в долларах) |  
//| и соотношением профит к стопу (ProfitLoss) из параметров скрипта.|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Borys Chekmasov"
#property link      "http://uatrader.blogspot.com"


double Lots = 0.1; //размер лота
double MoneyRisk = 30; //риск на сделку (в долларах)
double ProfitLoss=3;//отношение размера профита к размеру лосса

double open_level, stop_level, profit_level;
double symbol_mode, symbol_tik_sise,symbol_tikk_value,symbol_lotsize,leverage_lev ;
double delta_stop;


int start()
  {
//----

symbol_mode = MarketInfo (Symbol(),MODE_PROFITCALCMODE);
symbol_tik_sise = MarketInfo (Symbol(),MODE_TICKSIZE);
symbol_tikk_value = MarketInfo (Symbol(),MODE_TICKVALUE);
symbol_lotsize = MarketInfo (Symbol(),MODE_LOTSIZE);
leverage_lev = AccountLeverage();

// Вычисляем стоп
 switch (symbol_mode)
 {
 case 0: // Forex, в случае кроссов не забываем включать в обзоре рынка основные пары
   if (StringSubstr(Symbol(), 3, 3)=="USD") delta_stop = MoneyRisk/(Lots*symbol_lotsize);
   if (StringSubstr(Symbol(), 0, 3)=="USD") delta_stop =(Bid*MoneyRisk)/(Lots*symbol_lotsize);
   if (StringFind(Symbol(), "USD", 0) == -1) // кроскурсы
   {
    if (MarketInfo("USD"+StringSubstr(Symbol(), 3, 3),MODE_BID)>0) delta_stop = (MarketInfo("USD"+StringSubstr(Symbol(), 3, 3),MODE_BID)*MoneyRisk)/(Lots*symbol_lotsize);
    if (MarketInfo(StringSubstr(Symbol(), 0, 3)+"USD",MODE_BID)>0) delta_stop = MoneyRisk/(Lots*symbol_lotsize*MarketInfo(StringSubstr(Symbol(), 0, 3)+"USD",MODE_BID));
   }    
 break;
 case 1: //CFD стоки, комиссии не учитываются!!
   delta_stop = MoneyRisk/(Lots*symbol_lotsize);
 break;
 default: // фьючи, комиссии не учитываются!!
    delta_stop = (MoneyRisk*symbol_tik_sise)/(Lots*symbol_tikk_value);
 break;
 }

if (ObjectFind("GO!")>0)
{
//выставляем отложку:
open_level = ObjectGet("GO!", OBJPROP_PRICE1);
if (open_level>Bid) OrderSend(Symbol(),OP_SELLLIMIT,Lots,open_level,0,(open_level+delta_stop),(open_level-(delta_stop*ProfitLoss)),"",777,0,Red);
if (open_level<Bid) OrderSend(Symbol(),OP_BUYLIMIT,Lots,open_level,0,(open_level-delta_stop),(open_level+(delta_stop*ProfitLoss)),"",777,0,Red);
 }
//----
   return(0);
  }
//+------------------------------------------------------------------+

