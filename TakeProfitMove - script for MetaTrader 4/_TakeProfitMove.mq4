//+------------------------------------------------------------------+
//|                                             _TakeProfitMove.mq4  |
//|                                           "СКРИПТЫ ДЛЯ ЛЕНИВОГО" |
//|                Скрипт перемещает TakeProfit на Distance от рынка |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//#property show_inputs
//+------------------------------------------------------------------+
extern int Distance=5;            // Расстояние от рынка            |
extern bool UpDoun=true; //для только "подтаскивания" к рынку =false |
          //для и "подтаскивания" к рынку и "отскока" от рынка =true |
//+------------------------------------------------------------------+
void start() 
{
double NewPrice;
int    i,Total,Dist;
int    Dgts=MarketInfo(Symbol(),MODE_DIGITS);     
bool   GoGo;
//+------------------------------- УЗНАТЬ ОГРАНИЧЕНИЕ СВОЕГО ДЦ -----+
//  if(Distance<10) Dist=10;
//  else 
    Dist=Distance;
//+------------------------------------------------------------------+
  Total=OrdersTotal();
  if(Total>0)
  {
     for(i=Total-1; i>=0; i--) 
     {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true) 
        {
           if(OrderSymbol()==Symbol() && OrderType()==OP_SELL) 
           {
              NewPrice=Bid-Dist*Point;
              if(UpDoun==true) GoGo=true;
              else
              {
                 if(OrderTakeProfit()<NewPrice) GoGo=true;
                 else GoGo=false;
              }
              if(GoGo==true) if(OrderModify(OrderTicket(),
                             OrderOpenPrice(),
                             OrderStopLoss(),
                             NormalizeDouble(NewPrice,Dgts),
                             OrderExpiration(),
                             CLR_NONE)!=TRUE) 
                             Print("LastError = ", GetLastError());
           }
           if(OrderSymbol()==Symbol() && OrderType()==OP_BUY) 
           {
              NewPrice=Ask+Dist*Point;
              if(UpDoun==true) GoGo=true;
              else
              {
                 if(OrderTakeProfit()>NewPrice) GoGo=true;
                 else GoGo=false;
              }
              if(GoGo==true) if(OrderModify(OrderTicket(),
                             OrderOpenPrice(),
                             OrderStopLoss(),
                             NormalizeDouble(NewPrice,Dgts),
                             OrderExpiration(),
                             CLR_NONE)!=TRUE) 
                             Print("LastError = ", GetLastError());
           }
        }
     }
  }
}
//+------------------------------------------------------------------+

