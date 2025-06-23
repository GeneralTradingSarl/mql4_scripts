//+------------------------------------------------------------------+
//|                                                     CloseOrd.mq4 |
//|                                                  Николай Ефремов |
//|                                                      eftd@ya.ru  |
//+------------------------------------------------------------------+
#property copyright "Nic E"
#property link      ""
extern int    Slippage    = 3;       // Проскальзывание цены

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
  string Symb=Symbol();                   // Финанс. инструмент
  double Dist=1000000.0;                  // Предустановка
  bool rOrd=true, Resultat=true;
  double Win_Price=WindowPriceOnDropped();//Здесь брошен скрипт
//----1
   for(int i=1; i<=OrdersTotal(); i++)    // Цикл перебора ордеров
      {
       if (OrderSelect(i-1,SELECT_BY_POS)==true)// Если есть следующий
        {
//----2
        if (OrderSymbol()!= Symb) continue;// Не наш фин.инструм
           
//----3
        if (NormalizeDouble(MathAbs(OrderOpenPrice()-Win_Price),Digits)
            <NormalizeDouble(Dist,Digits)) //Выбираем ближайший
            {
             Dist=MathAbs(OrderOpenPrice()-Win_Price);// Новое значение            
             int    Tip    =OrderType();      // Тип выбранного орд.
             if (Tip>1)rOrd=false;       // Отложенный ордер  
             int    Ticket =OrderTicket();    // № выбранного орд. 
             double Lots=OrderLots();
             double Price  =OrderOpenPrice(); // Цена выбранного орд.
            }
       } 
      }
//----4
      while(true)           //Цикл Закрытие ордера
         {
            if (rOrd==true)  //
              {
                    if(Tip==OP_BUY) 
                      Resultat=OrderClose(Ticket,Lots,Bid,Slippage,CLR_NONE);
                    else
                      Resultat=OrderClose(Ticket,Lots,Ask,Slippage,CLR_NONE);
                   if(Resultat!=true) 
                     { 
                       int Error=GetLastError(); 
                       Alert("Ошибка № = ",Error); 
                     }
                       else Error=0;
              }
             else Resultat = OrderDelete( Ticket);// Удаление отложенного ордера 
                   if(Resultat!=true) 
                     { 
                       Error=GetLastError(); 
                       Alert("Ошибка № = ",Error); 
                     }
                       else Error=0;
          break;                                    // Выход из цикла закр          
         }   
//----
   return(0);
  }
//+------------------------------------------------------------------+