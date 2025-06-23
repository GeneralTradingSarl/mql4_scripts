//+------------------------------------------------------------------+
//|                                                 Lines_Create.mq4 |
//|                                          Copyright © 2007, DRKNN |
//|                                                    drknn@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, DRKNN"
#property link      "drknn@mail.ru"
#include <Errors.mqh>
//#property show_inputs
//extern int ChisloSvech=300;

/*
   Скрипт устанавливает 2 горизонтальные линии на грфике на расстоянии 15 пунктов от текущей цены.
   и присваивает им имена UP_LEVEL и DOWN_LEVEL
   Если эти линии уже существуют, то скрипт переместит их на эти уровни.
*/


//+------------------------------------------------------------------+
//|                 Начало работы скрипта                            |
//+------------------------------------------------------------------+
int start()
  {
  bool fm=false;
  int GLE=0;
  double SvojstvoUP=10,SvojstvoDOWN=5;
  
// карасные - в шорт, зелёные в лонг
 
  fm=ObjectCreate("UP_LEVEL",OBJ_HLINE,0,Time[0],Bid+15*Point);
  if(fm==0 || fm==-1){GeneralError();}
  fm=ObjectSet("UP_LEVEL",OBJPROP_COLOR,Green);
  if(fm==0 || fm==-1){GeneralError();}
  fm=ObjectSet("UP_LEVEL",OBJPROP_WIDTH,1);
  if(fm==0 || fm==-1){GeneralError();}
  
  
  
  SvojstvoUP=ObjectGet("UP_LEVEL",OBJPROP_PRICE1);
            if(SvojstvoUP==5){GeneralError();}
 if(SvojstvoUP!=Bid+15*Point){
   fm=ObjectSet("UP_LEVEL",OBJPROP_PRICE1,Bid+15*Point);
  if(fm==0 || fm==-1){GeneralError();}
 }
  
  
  fm=ObjectCreate("DOWN_LEVEL",OBJ_HLINE,0,0,Bid-15*Point);
  if(fm==0 || fm==-1){GeneralError();}
  fm=ObjectSet("DOWN_LEVEL",OBJPROP_COLOR,Red);
  if(fm==0 || fm==-1){GeneralError();}
  fm=ObjectSet("DOWN_LEVEL",OBJPROP_WIDTH,1);
  if(fm==0 || fm==-1){GeneralError();}
  
  SvojstvoDOWN=ObjectGet("DOWN_LEVEL",OBJPROP_PRICE1);
            
  if(SvojstvoDOWN!=Bid-15*Point){
   fm=ObjectSet("DOWN_LEVEL",OBJPROP_PRICE1,Bid-15*Point);
  if(fm==0 || fm==-1){GeneralError();}
  }          
  
  
  
  
   return(0);
  }
//+------------------------------------------------------------------+
//|                 Конец работы скрипта                             |
//+------------------------------------------------------------------+

