//+------------------------------------------------------------------+
//|                                                      AP 1.00.mq4 |
//|                                            Fredrich Company 2015 |
//|                                    https://www.vk.com/Fredrich85 |
//+------------------------------------------------------------------+
#property copyright "Fredrich Company 2015"
#property link      "https://www.vk.com/Fredrich85"
#property version   "1.00"
#property strict
extern int   period_slow= 70;                // период медленной скользящей средней
input int   period_fast = 25;                // период быстрой скользящей средней
input int   period_absalut=1440;             // период годовой скользящей средней
input int   shift_min1   = 1;                // начало отсчета от края баров
input int   shift_max1   = 240;              // конец баров при 6-8 недельном расчете
input int   shift_min2   = 1;                // начало отсчета от края баров
input int   shift_max2= 1440;                // конец баров при годовом расчете
input int   sleep = 5000;

input color    clr_hight = clrBlue;          // цвет верхней линии
input color    clr_low = clrRed;             // цвет нижней линии
input color    clr_med = clrGold;            // цвет средней линии
input string   name_hight = "HLine";         // имя линии
input string   name_low = "LLine";           // имя линии
input string   name_medium = "MLine";        // имя линии
input string   name_trend= "TrendLine";      // имя линии
input string   name_fibo = "TrendFibo";      // имя линии
input string   name_hightL="Year Hight Line";// имя линии
input string   name_lowL="Year Low Line";    // имя линии
input string   name_mediumL="Year Medium Line"; // имя линии
input string   name_mediumY= "Median Year";

bool on_fibo=1;
bool on_year_flat = 1;
bool on_week_flat = 1;
bool on_year_median=1;
bool on_comment=1;

double val_hight;
double val_low;
double val_medium;
datetime val_lowT;
datetime val_hightT;
double val_hightL;
double val_lowL;
double val_mediumL;
//+------------------------------------------------------------------+
//|Запуск скрипта                                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Удаление всех объектов на графике
   ObjectsDeleteAll();

//--- Пауза при перезапуске 
   Sleep(sleep);

//--- Общие переменныи для работы скрипта 
   double Price=iOpen(NULL,PERIOD_D1,0);
   double absalut=iMA(NULL,PERIOD_H4,period_absalut,0,MODE_EMA,PRICE_CLOSE,1);

//--- Расчет данных по скользящим средним
   double H4_F  = iMA(NULL , PERIOD_H4, period_fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double H4_S  = iMA(NULL , PERIOD_H4, period_slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   double D1_F  = iMA(NULL , PERIOD_D1, period_fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double D1_S  = iMA(NULL , PERIOD_D1, period_slow, 0, MODE_EMA, PRICE_CLOSE, 1);

//--- Расчет экстремумов по методике 6-8 недель
   int val_index=iHighest(NULL,PERIOD_H4,MODE_HIGH,shift_max1,shift_min1);
   if(val_index!=-1){ val_hight=High[val_index]; val_hightT=Time[val_index]; }
   else PrintFormat("Ошибка вызова iHighest. Код ошибки=%d",GetLastError());

   val_index=iLowest(NULL,PERIOD_H4,MODE_LOW,shift_max1,shift_min1);
   if(val_index!=-1) { val_low=Low[val_index]; val_lowT=Time[val_index]; }
   else PrintFormat("Ошибка вызова iLowest. Код ошибки=%d",GetLastError());

   val_medium=(val_hight+val_low)/2;

//--- Приведение в строки даты
   string  dateWeek_h = TimeToString(val_hightT,TIME_DATE);         // Дата максимума 6-8 недель
   string  dateWeek_l = TimeToString(val_lowT,TIME_DATE);           // Дата минимума  6-8 недель

//--- Расчет экстремумов за год
   val_index=iHighest(NULL,PERIOD_H4,MODE_HIGH,shift_max2,shift_min2);
   if(val_index!=-1){ val_hightL=High[val_index]; }
   else PrintFormat("Ошибка вызова iHighest. Код ошибки=%d",GetLastError());

   val_index=iLowest(NULL,PERIOD_H4,MODE_LOW,shift_max2,shift_min2);
   if(val_index!=-1) { val_lowL=Low[val_index];  }
   else PrintFormat("Ошибка вызова iLowest. Код ошибки=%d",GetLastError());

   val_mediumL=(val_hightL+val_lowL)/2;

//--- Построение линий по методике 6-8 недель
   if(on_week_flat==true)
     {
      ObjectCreate(0,name_hight,OBJ_HLINE,0,0,val_hight);
      ObjectSetInteger(0,name_hight,OBJPROP_COLOR,clr_hight);
      ObjectCreate(0,name_low,OBJ_HLINE,0,0,val_low);
      ObjectSetInteger(0,name_low,OBJPROP_COLOR,clr_low);
      ObjectCreate(0,name_medium,OBJ_HLINE,0,0,val_medium);
      ObjectSetInteger(0,name_medium,OBJPROP_COLOR,clr_med);
     }
   if(on_fibo==true)
     {
      ObjectCreate(0,name_fibo,OBJ_FIBO,0,val_hightT,val_hight,val_lowT,val_low);
      ObjectSetInteger(0,name_trend,OBJPROP_COLOR,clr_low);
     }

//--- Построение линий по методике годового флета
   if(on_year_flat==true)
     {
      ObjectCreate(0,name_hightL,OBJ_HLINE,0,0,val_hightL);
      ObjectSetInteger(0,name_hightL,OBJPROP_COLOR,clr_hight);
      ObjectSetInteger(0,name_hightL,OBJPROP_WIDTH,2);
      ObjectCreate(0,name_lowL,OBJ_HLINE,0,0,val_lowL);
      ObjectSetInteger(0,name_lowL,OBJPROP_COLOR,clr_low);
      ObjectSetInteger(0,name_lowL,OBJPROP_WIDTH,2);
      ObjectCreate(0,name_mediumL,OBJ_HLINE,0,0,val_mediumL);
      ObjectSetInteger(0,name_mediumL,OBJPROP_COLOR,clr_med);
      ObjectSetInteger(0,name_mediumL,OBJPROP_WIDTH,2);
     }

//--- Расчет основной медианы за год
   if(on_year_median==true)
     {
      ObjectCreate(0,name_mediumY,OBJ_HLINE,0,0,absalut);
      ObjectSetInteger(0,name_mediumY,OBJPROP_COLOR,clrGray);
      ObjectSetInteger(0,name_mediumY,OBJPROP_WIDTH,3);
     }

//--- Расчет средних значений отклонения цены 
   double val_h4 = (H4_F - H4_S)/Point();                      // Разница между скользящим 4 часового графика
   double val_D1 = (D1_F - D1_S)/Point();                      // Разница между скользящим дневного графика        
   double val_change = (val_hight-val_low)/Point();            // Расчет 6-8 недельного флета
   double val_change_year = (val_hightL-val_lowL)/Point();     // Расчет годового  флета
   double val_absalut = (absalut-Price)/Point();               // Отклонение от годовой средней 
   double val_absalut_week = (val_medium-Price)/Point();       // Отклонение от средней флета за 6-8 недель
   double val_absalut_year = (val_mediumL-Price)/Point();      // Отклонение от средней годового флета

//--- Вывод данных в комментарии
   if(on_comment==true)
     {
      Comment(StringFormat("Значение параметров Н4 = %G pips; D1 = %G pips\nШирина канала флета 6-8 week = %G pips годовой = %G pips\nОтклонение от годовой скользящей = %G pips\nОтклонение от средины 6-8 недельного флета = %G pips годового флета  = %G pips",val_h4,val_D1,val_change,val_change_year,val_absalut,val_absalut_week,val_absalut_year));
     }
  }
//+------------------------------------------------------------------+
