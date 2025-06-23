//+------------------------------------------------------------------+
//|                                                    _auto_BUY.mq4 |
//|                                           "СКРИПТЫ ДЛЯ ЛЕНИВОГО" |
//|                            Скрипт открывает BUY в активном окне. |
//|                           При CreateGif=true активное окно после |
//|                       открытия позиции сохраняется как рисунок в |
//|                     ...\<Терминал>\exsperts\files\<FileName>.gif |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Bookkeeper"
#property link      "yuzefovich@gmail.com"
#property show_inputs // Если есть желание менять экстерны в процессе
//+------------------------------------------------------------------+
extern int  Aggression = 1;    // = 0 - фиксированным лотом
                               // = 1 или 2 автовыбор
extern double FixLot   = 0.1;
extern int  DistSLmin  = 35;   // StopLoss в пунктах - не меньше.
                               // Если автоматом будет меньше - будет
                               // установлен на DistSLmin пунктов
extern int  NBarsMax   = 15;   // Максимальное число баров, среди
                               // которых искать локальный минимум.
                               // Если найден не будет, будет взят
                               // меньший из Low в этом диапазоне
                               // или по DistSLmin
extern int  SlipPage   = 7;    // Проскальзывание в пунктах
extern bool StopLoss   = true; // Ставить или нет StopLoss
extern bool TakeProfit = true; // Ставить или нет TakeProfit=StopLoss
extern bool CreateGif  = false; // Создать или нет рисунок
//+------------------------------------------------------------------+
double CalcLotsAuto() // Мягко-агрессивный способ управления денюшкой.
{
   double lots;
   // Минимальный и максимальный размеры лотов
   double MinLot=MarketInfo(Symbol(),MODE_MINLOT);
   int MinLotDgts;
   if(MinLot<0.1) MinLotDgts=2; // размерность минлота   
   else
   {
      if(MinLot<1.0) MinLotDgts=1;
      else MinLotDgts=0;
   }
   double MaxLot=MarketInfo(Symbol(),MODE_MAXLOT); 
   // нужен залог на минлот
   double MarginLot=MarketInfo(Symbol(),MODE_MARGINREQUIRED)*MinLot;
   // имеем свободных средств
   double FreeMargin=AccountFreeMargin();
   // если их не имеем :(
   if(MarginLot>FreeMargin) return(-1.0);
   // а если имеем, то сколько лотов можем себе позволить на позу
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   int LotStepDgts;
   if(LotStep<0.1) LotStepDgts=2; // размерность   
   else
   {
      if(LotStep<1.0) LotStepDgts=1;
      else LotStepDgts=0;
   }
   FixLot=NormalizeDouble(FixLot,LotStepDgts);
   if(Aggression==0)
   { 
      if(FixLot>0)
      {
         MarginLot=MarketInfo(Symbol(),MODE_MARGINREQUIRED)*FixLot;
         if(MarginLot>FreeMargin) lots=NormalizeDouble(MinLot,MinLotDgts);
         else lots=NormalizeDouble(FixLot,LotStepDgts);
         return(lots);
      }
      else
      {
         lots=NormalizeDouble(MinLot,MinLotDgts);
         return(lots);
      }
   }
   int n=1;
   int m=NormalizeDouble(MaxLot/MinLot,0);
   double level=MarginLot*2;
   while(level<=FreeMargin && n<=m)
   {
      n++;
      if(Aggression==1)
         level=level+MarginLot*n; // Менее агрессивно
      else level=level+MarginLot*MathSqrt(n);
   }
   n--;
   lots=NormalizeDouble((MinLot*n),MinLotDgts);
   return(lots);
}
//+------------------------------------------------------------------+
void start() 
{
double SL, TP;
int    ticket, i;
string FileName, str;     
//----
   // Допуск уровней стопов (добавляю проскальзывание)
   double MinDistForStops=
                (MarketInfo(Symbol(),MODE_STOPLEVEL)+SlipPage)*Point;
   double lots=CalcLotsAuto();
   if(lots<=0) 
   {
      Alert("Open_BUY: My finance sing romances");
      return;
   }
   int N=0, m=0; 
   bool b=true; 
   while(b && N<NBarsMax) 
   { 
      N++;    
      if((Period()<1440 && Low[N]<=Low[N+1] && Low[N]<=Low[N-1] && Low[N]<Low[N+2] && Low[N]<Low[N-2])
         || (Period()>240 && Low[N]<=Low[N+1] && Low[N]<=Low[N-1]))
      {
         b=false;
         m=N;
      }
      else m=iLowest(NULL,0,MODE_LOW,N,0);
   } 
   RefreshRates();
   double DistStops=Bid-Low[m]+MarketInfo(Symbol(),MODE_SPREAD)*Point;
   DistStops=MathMax((DistSLmin*Point),DistStops);
   DistStops=MathMax(MinDistForStops,DistStops);
   if(StopLoss==true) SL=Bid-DistStops; 
   else SL=0;
   if(TakeProfit==true) TP=Ask+DistStops; 
   else TP=0;
   ticket=OrderSend(Symbol(),OP_BUY,
                    lots,
                    NormalizeDouble(MarketInfo(Symbol(),MODE_ASK),Digits), 
                    SlipPage,
                    NormalizeDouble(SL,Digits),
                    NormalizeDouble(TP,Digits),
                    "",0,0,CLR_NONE);
   if(ticket<0) Alert("Open_BUY LastError: ",GetLastError()); 
   else
   { 
      if(CreateGif==true)
      {
         //    рисуем, если заказано 
         datetime curdate=TimeCurrent();
         FileName=Symbol()+"_BUY_"+TimeYear(curdate);
         i=TimeMonth(curdate);
         if(i<10)
         {
            str="0"+i;
            FileName=FileName+str;
         }
         else FileName=FileName+i;
         i=TimeSeconds(curdate)+
           100*TimeMinute(curdate)+
           10000*TimeHour(curdate)+
           1000000*TimeDay(curdate);
         if(TimeDay(curdate)<10)
         {
            str="0"+i;
            FileName=FileName+str;
         }
         else FileName=FileName+i;
         FileName=FileName+".gif";
         WindowScreenShot(FileName,400,300); 
      }
   }
   return;
}
//+------------------------------------------------------------------+

