//+------------------------------------------------------------------+
//|                                                   Flatter_V1.mq4 |
//|                                      Copyright © 02/2008, Rosych |
//|                                                   rosych@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 02/2008, Rosych"
#property link      "rosych@mail.ru"
#property show_inputs

extern string Usloviya         ="Параметры торговли";
extern double Risk             =0.1;
extern int    TakeProfit       =50; 
extern int    StopLoss         =20; 
extern int    Otstup           =20; 

extern string Kanal            ="Параметры канала";
extern double Hi               =0;//Максимальный High канала
extern double Lo               =0;//Максимальный Low канала

extern int    Slipp            =2;

double Lot;
string Smb;
int    Magicb=1;
int    Magics=2;

int start(){
  Smb=Symbol();     
  Lot=NormalizeDouble(AccountBalance()*Risk/10000.0,2);
  if(Lot>MarketInfo(Symbol(),MODE_MAXLOT))
    {Lot=MarketInfo(Symbol(),MODE_MAXLOT);}
  
    int d=Digits;    
    double b=NormalizeDouble(Hi+Otstup*Point,d);
    double b1=NormalizeDouble(b-StopLoss*Point,d);
    double b2=NormalizeDouble(b+TakeProfit*Point,d);
    double s=NormalizeDouble(Lo-Otstup*Point,d);  
    double s1=NormalizeDouble(s+StopLoss*Point,d);
    double s2=NormalizeDouble(s-TakeProfit*Point,d);
    
    if(Hi>0 && Lo>0){
     if(OrderSend(Smb,OP_BUYSTOP,Lot,b,Slipp,b1,b2,
        "buystop",Magicb,0,Navy)==true){
      Print("Ордер BuyStop установлен");}
    else{
        Print("Ошибка ",GetLastError()," при установке BuyStop ордера");}
    
    if(OrderSend(Smb,OP_SELLSTOP,Lot,s,Slipp,s1,s2,
        "sellstop",Magics,0,Orange)==true){
      Print("Ордер SellStop установлен");}
    else{
        Print("Ошибка ",GetLastError()," при установке SellStop ордера");}
    }
  
 for(int a=OrdersTotal()-1; a>=0; a--){
  if (OrderSelect(a,SELECT_BY_POS,MODE_TRADES)){
  if (OrderType()<=OP_SELL){
    for(int c=OrdersTotal()-1; c>=0; c--){
    if (OrderSelect(c,SELECT_BY_POS)){
    if (OrderType()>OP_SELL){
    if (OrderDelete(OrderTicket())==true){
        Print("Ордер ",a," удален");}
    else{
         Print("Ошибка ",GetLastError()," при удалении ордера",a);
    }
    }
    }
    }
    break;
  } 
  } 
 }
}    
//==================================================================