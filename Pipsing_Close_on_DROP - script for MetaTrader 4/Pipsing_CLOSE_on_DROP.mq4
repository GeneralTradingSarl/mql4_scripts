//+------------------------------------------------------------------+
//|                                        Pipsing_CLOSE_on_DROP.mq4 |
//|                                                    Aleksandr Pak |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright "AP"
#property link      "ekr-ap@mail.ru"

// http: // forum.mql4.com/ru/11202/page5
// The script closes warrants of all types on which is thrown by a mousy.
// The instruction: we take a script, (it is clamped by his{its} left key of the mouse) 
// We bear{carry} on a line of the warrant, on an edge of an arrow{a pointer}, we release{we let off} the mouse.
// We (throw).
// Two modes: 0-to close the nearest warrant.
// 1-to close all warrants in area in the nearest region.
// If in the field of throwing = +/-Region there are no warrants the script will close nothing.
// If to cause a script in the usual way too most - any reaction.
// On erroneous actions the script is silent.
// Has two modes - a group sex and on one.
// Switching a mode and the task of parameters only through recompilation
// The red inscription with the name of operation is visible only at delays
// In norm it is not visible, since there is less than second
//...............................................................
//http://forum.mql4.com/ru/11202/page5
//Скрипт закрывает ордера всех типов на которые брошен мышкой.
// в т.ч. лимитники
//Инструкция: берем скрипт, (зажимаем его левой клавишей мыши) 
//несем на линию ордера, по носику стрелки, отпускаем мышь.
//( бросаем.)
//два режима: 0- закрыть ближайший ордер.
//            1- закрыть все ордера в области в ближайшем регионе.
//если в области бросания =+/-Region нет ордеров, то скрипт ничего не закроет.
//если вызвать скрипт обычным способом тоже самое - никакой реакции.
//на ошибочные действия скрипт молчит.
//имеет  два режима - групповуха и по однму.
// переключение режима и задание параметров только через перекомпиляцию
// красная надпись с названием операции видна только при задержках
// в норме не видна,т.к. намного меньше секунды

extern int ALL_on_region=1;//1= сметает все ордера  в регионе. 0- только самый ближний.
                           //1=ALL orders from region, 0=first order
extern int Region=10;      // размер региона действия в пунктах вверх и вниз т.е. 2*Region
                           //Size of region for action
extern int Slippage=6;     //скольжение для ДЦ
                           //Slippage for Broker
extern int Repetitioons=6; //попыток закрыть
                           //Repetitioons of Close action by error

int count_order,minrop,rticket[1000],rop[1000];
double rprice[1000];


int deinit()
{

ObjectDelete("PipsWork");
}

int start()
  {int i,tck;
   double r=WindowPriceOnDropped( ) ;
    if(ObjectFind("PipsWork")<0)
              ObjectCreate("PipsWork",OBJ_TEXT,0,iTime(NULL,0,10),High[10]);
    if(r==0) return (0);
     order_monitor(r,Region*Point);
     if(ALL_on_region==1)
     {
     for(i=0;i<count_order;i++)
          {
            close_(rticket[i],rop[i]);          
          }
     } 
     else
     {
      tck=bestgoal(r);
      close_(tck,minrop);
     }
   
   
   return(0);
  }
//+------------------------------------------------------------------+
  int close_(int ticket, int cmd)
{
   bool   result;
   double price;
   int    error,i=0; 
   string tr;        
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
            { 
               switch(cmd)
               {
               case 0:tr="CLOSE OP_BY"; break;
               case 1:tr="CLOSE OP_SELL"; break;
               case 2:tr="DELETE OP_BUYL_IMIT"; break;
               case 3:tr="DELETE OP_SELL_LIMIT"; break;
               case 4:tr="DELETE OP_BUY_STOP"; break;
               case 5:tr="DELETE OP_SELL_STOP"; break;
               }
              ObjectSetText("PipsWork", tr, 14,"",Red);
              while(true)
               {i+=1;
                   RefreshRates();               
                  {
                  if(cmd==OP_BUY)      price=Bid; 
                  if(cmd==OP_SELL)      price=Ask;
                        
                  if(cmd==OP_BUY||cmd==OP_SELL) result=OrderClose(OrderTicket(),OrderLots(),price,Slippage,CLR_NONE);
                  if(cmd==OP_BUYSTOP||cmd==OP_SELLSTOP||cmd==OP_BUYLIMIT||cmd==OP_SELLLIMIT)
                  result=OrderDelete(OrderTicket());
                        error=GetLastError(); 
                        if(result==TRUE) error=0; 
                        if(error!=0) {Sleep(500); RefreshRates();} 
                  else break;
                  if(i>Repetitioons)break; 
                  if(!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) break;
                  }
              }
            }
return (error);
}
///////////////////////////////////////////////
int bestgoal(double p)
{int i,ticket;
double min=9999999,op,x,y;
       for(i=0;i<count_order;i++)
       {
       x=MathAbs(p-rprice[i]);
       if(min>x){min=x; ticket=rticket[i]; minrop=rop[i];}
       }    
return (ticket);
}
//////
void order_monitor(double p, double dp)
{
int i,k,m,n,cmd,typs;
double t,x,op;
k=OrdersTotal();
   for(i=k;i>=0;i--)
   {   
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) 
      {
        if(Symbol()==OrderSymbol())
        {
          op=OrderOpenPrice();
          x=op-p;
         rticket[n]=OrderTicket();
           if(MathAbs(x)<dp)
            {  
            cmd=OrderType();
             t=OrderCloseTime();
             //  if(t==0) 
               { 
                    t=OrderOpenTime();
                    { 
                     rticket[n]=OrderTicket();
                     rop[n]=cmd;
                     n++;
                    }
               } 
           }
        }  
     } 
   } 
   count_order=n; 
}

////////////////////////////

