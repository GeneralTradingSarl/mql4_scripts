//+------------------------------------------------------------------+
//|                                                    _Open_BUY.mq4 |
//|                                           "СКРИПТЫ ДЛЯ ЛЕНИВОГО" |
//|              Скрипт открывает BUY на задаваемую часть FreeMargin |
//|                                                                  |
//|                                   Только для пар USD... и ...USD |
//|                               (благадарю komposter за подсказку) |
//|                                                                  |
//|                           Bookkeeper, 2006, yuzefovich@gmail.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property show_inputs // Если есть желание менять экстерны в процессе
//+------------------------------------------------------------------+
extern int    Interest   = 100;  // Выделить часть FreeMargin на позу:
                                 // = 0 открыть минимальным лотом
                                 // = 100 открыть со всей дури
extern int    DistSL     = 35;   // Расстояние до SL
extern int    DistTP     = 35;   // Расстояние до TP
extern int    Slippage   = 5;    // Проскальзывание
extern bool   StopLoss   = true; // Ставить или нет
extern bool   TakeProfit = true; // Ставить или нет
//+------------------------------------------------------------------+
void start() 
{
int    ticket;
double SL=0,TP=0,Stake,StepDgts,Share,QQ=1.0;
double Step=MarketInfo(Symbol(),MODE_MINLOT);   
int    Dgts=MarketInfo(Symbol(),MODE_DIGITS);     
string FirstPart=StringSubstr(Symbol(), 0, 3 );   
string SecondPart=StringSubstr(Symbol(), 3, 3 );
   Share=0.01*Interest;
   if(SecondPart == "USD") QQ=Ask;
   else
   {
      if(FirstPart != "USD") 
         Alert("OpenBUY: Who is that - "+Symbol()+"? I do not know..."); // :)

   }
   if(AccountFreeMargin()<Step*1000*QQ)
   {
      Alert("Open_BUY: No maney...");
      return;
   }
   if(Share>1.0) Share=1.0; // Часть не бывает больше целого
   if(Share<0) Share=0;    // (???)
   if(Step<0.1) StepDgts=2;
   else
   {
      if(Step<1.0) StepDgts=1;
      else StepDgts=0;
   }
   Stake=NormalizeDouble(AccountFreeMargin()*Share/1000/QQ,StepDgts);
   if(AccountFreeMargin()<Stake*1000*QQ) // Округление бывает и вверх
      Stake=NormalizeDouble(Stake-Step,StepDgts); // Теперь лишку не будет  
   //Если выделенная часть депо будет меньше минимально допустимого лота,
   //поза будет открыта на минимальный лот
   if(Stake<Step) Stake=Step;
   if(StopLoss==true) SL=Bid-DistSL*Point;
   if(TakeProfit==true) TP=Ask+2*DistTP*Point;
   ticket=OrderSend(Symbol(),OP_BUY,Stake,Ask,Slippage,
                    NormalizeDouble(SL,Dgts),
                    NormalizeDouble(TP,Dgts),
                    "",0,0,CLR_NONE);
   if(ticket<=0) Alert("Error Open_SELL: ",GetLastError()); 
   return(0);
}
//+------------------------------------------------------------------+

