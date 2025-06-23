//+------------------------------------------------------------------+
//|                                                    ZeroLevel.mq4 |
//|                                                          VadimVP |
//|                                                poluyan@fxmail.ru |
/*
 Скрипт поставит TakeProfit и StopLoss у открытых ордеров на текущем
 инструменте на уровень безубыточности.
 Расчет ведется только для ордеров текущего инструмента.
 Учитывает своп и комиссии. Работает при любых Digits.
 Точность +/- размер спреда.
 Об успешности изменений сообщит в диалоговом окне.
 Проверьте, включена ли опция "разрешить советнику торговать". 
*/
//| 
//+------------------------------------------------------------------+
#property copyright "VadimVP"
#property link      "poluyan@fxmail.ru"
 
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   int kol=0;
   int kolOK=0;
   int i=0;
   double lots=0;
   double sum=0;
   double sum1=0;
   for (i=0; i<OrdersTotal(); i++)
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()!=Symbol()) continue;
      if (OrderType()==OP_BUY)
      {
       lots=lots+OrderLots();
       sum=sum+OrderLots()*OrderOpenPrice();
       sum1=sum1+OrderProfit( )+OrderSwap( )+OrderCommission( )  ; 
       kol=kol+1;
      }
      if (OrderType()==OP_SELL)
      {
       lots=lots-OrderLots();
       sum=sum-OrderLots()*OrderOpenPrice();
       sum1=sum1+OrderProfit( )+OrderSwap( )+OrderCommission( )  ;
       kol=kol+1;
      }
   }
   double zeroprice=0;
   if (lots!=0) zeroprice=sum/lots;
   zeroprice = (MathRound(zeroprice*MathPow(10,Digits)))/MathPow(10,Digits);

   
//-----
 Alert ("!!!  Пожалуйста дождитель окончания работы скрипта!");
 int res = 0;
 for (i=0; i<OrdersTotal(); i++)
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()!=Symbol()) continue;
        
         if (sum1>0) 
         { if (OrderType()==OP_BUY) {if (zeroprice == OrderTakeProfit()) res=res+1; else { if (OrderModify(OrderTicket(),0,OrderStopLoss(),zeroprice,0,CLR_NONE)) res = res+1;}    }
           if (OrderType()==OP_SELL){if (zeroprice == OrderStopLoss()) res=res+1; else { if (  OrderModify(OrderTicket(),0,zeroprice,OrderTakeProfit(),0,CLR_NONE)) res = res+1;}     } }
         if (sum1<0) 
         { if (OrderType()==OP_BUY) {if (zeroprice == OrderStopLoss()) res=res+1; else { if (  OrderModify(OrderTicket(),0,zeroprice,OrderTakeProfit(),0,CLR_NONE)) res = res+1;} }
           if (OrderType()==OP_SELL){if (zeroprice == OrderTakeProfit()) res=res+1; else { if (OrderModify(OrderTicket(),0,OrderStopLoss(),zeroprice,0,CLR_NONE)) res = res+1;}    } } 
          
   }
 Alert ("***************************************************");
 Alert ("Цена безубыточности "+DoubleToStr(zeroprice,Digits));
 if (kol==res) Alert ("Все ордера успешно изменены! Точка безубыточности выставлена. ОК!"); else Alert ("!!! Внимание!!! Не удалось изменить - " +(kol-res)+ " ордера из "+kol+" имеющихся");
 Alert ("************ информация от ZeroLevel script ************");
 
//------

   return(0);
  }

n(0);
  }

*****");
 Alert ("Цена безубыточности "+DoubleToStr(zeroprice,Digits));
 if (kol==res) Alert ("Все ордера успешно изменены! Точка безубыточности выставлена. ОК!"); else Alert ("!!! Внимание!!! Не удалось изменить - " +(kol-res)+ " ордера из "+kol+" имеющихся");
 Alert ("************ информация от ZeroLevel script ************");
 
//------
   }
   
   return(0);
  }


double symbolprofit() // profit по ордерам ТОЛЬКО текущего инструмента (без свопов и комиссий)
{
double sprofit = 0;
for (int i=0; i<OrdersTotal(); i++)   
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()!=Symbol()) continue;
      sprofit = sprofit + OrderProfit( ); 
   }
return(sprofit);
}