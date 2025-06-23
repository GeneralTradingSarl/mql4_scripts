//+------------------------------------------------------------------+
//|                                     history_data_analysis_v3.mq4 |
//|                              Copyright © 2007, Kiriyenko Dmitriy |
//|                                      http://kiriyenko.moikrug.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Kiriyenko Dmitriy"
#property link      "http://kiriyenko.moikrug.ru"
//----
#property show_inputs
#define FILE_NAME "history_data_analysis_v3.ex4"
#define WRONG_TF "Таймфрейм должен находиться в пределах M1-H4.\n\nВыберите другой таймфрейм."
#define WRONG_TF_HDR "Неверно выбран таймфрейм входных данных!"
#define WRONG_BREAKUP "Значение break_up должно быть не меньше критерия фильтра для дыры.\n"
#define BREAKUP_CHANGE "Значение breakup_min будет изменено на "
#define WRONG_BREAKUP_HDR "Неверно задан критерий разрыва!"
#define WRONG_FILE_EXT "Неверный тип файла: можно задавать только *.hst файлы"
#define WRONG_FILE_EXT_HDR "Ошибка входных данных"
//----
extern string header0 = "<---------- Входные данные ---------->";
extern bool   input_from_file = false;
extern string input_file_name = ".hst";
extern bool   input_file_in_history = true;
//----
extern string header1 = "<---------- Параметры фильтрации ---------->";
extern bool   bars_ignore = true; // активатор 
extern int    hole_min    = 3; // количество отсутствующих баров, которые код считает дырой
//----
extern int breakup_min    = 20; // кол-во отсутствующих баров, которые код считает разрывом

extern bool gap_ignore    = true; // активатор
extern int  gap_min       = 5; // кол-во отсутствующих пипсов, которые код будет игнорировать
//----
extern string header2 = "<---------- Параметры отчёта ---------->";
extern bool report_summary = false; // выводить сводку
extern bool report_table = true; // выводить таблицу
//----
string begin_week_sessions = "00:00"; // время начала недельной сессии (чч:мм)
string end_week_sessions = "21:59";   // время окончания недельной сессии (чч:мм)
bool   new_file = true;               // флаг, чтобы шапку таблицы записать один раз
int    in_handle, out_handle;         // файловые обработчики открытых файлов
int    err;                           // переменная для хранения кода ошибки
//----
#include <WinUser32.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int      period;               // таймфрейм в минутах
   string   symbol;               // обрабатываемый символ
   int      bars;                 // число баров на графике
   double   point;                // размер пункта в валюте котировки
   datetime time_start, time_end; // начальный и конечный бар
// начальная обработка входного файла и установка глобальных данных
   if(input_from_file)
     {
       // определение типа
       if(file_ext(input_file_name) != "hst")
         {
           MessageBox(WRONG_FILE_EXT, WRONG_FILE_EXT_HDR, MB_OK | MB_ICONSTOP);
           return(-3);
         }
       // открытие файла
       if(input_file_in_history)
           in_handle = FileOpenHistory(input_file_name, FILE_BIN | FILE_READ);
       else
           in_handle = FileOpen(input_file_name, FILE_BIN | FILE_READ);
       err = GetLastError();
       if(in_handle < 0 || err > 0) 
           return(error_out(err, "Открытие входного файла"));
       // определение числа баров
       bars = (FileSize(in_handle) - 148) / 44;
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Определение размера входного файла"));
       // чтение заголовка входного файла
       FileSeek(in_handle, 68, SEEK_SET);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Смещение во входном файле к символу"));
       // чтение символа/периода
       symbol = FileReadString(in_handle, 12);
       period = FileReadInteger(in_handle, LONG_VALUE);
       int digits = FileReadInteger(in_handle, LONG_VALUE);
       point = MathPow(10, -digits);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Чтение символа и периода из входного файла"));
       // определение временных границ исторических даных
       FileSeek(in_handle, 60, SEEK_CUR);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Смещение во входном файле к первой дате"));
       time_start = FileReadInteger(in_handle, LONG_VALUE);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Чтение первой даты из входного файла"));
       FileSeek(in_handle, -44, SEEK_END);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Смещение во входном файле к последней дате"));
       time_end = FileReadInteger(in_handle, LONG_VALUE);
       err = GetLastError();
       if(err > 0) 
           return (error_out(err, "Чтение последней даты из входного файла"));
       // перевод курсора в начало котировок в *.hst файле
       FileSeek(in_handle, 148, SEEK_SET);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Смещение во входном файле к началу котировок"));
     }
   else // или подстановка глобальных данных с графика
     {
       bars = Bars;
       symbol = Symbol();
       period = Period();
       point = Point;
       time_start = Time[Bars-1];
       time_end = Time[0];
     }
// выбор параметров под таймфрейм
   string time_frame;    // таймфрейм
   int duration_bar = period*60;  // длительность бара в сек.
   switch(period)
     {
       case 1:   time_frame = "M1";  break;
       case 5:   time_frame = "M5";  break;
       case 15:  time_frame = "M15"; break;
       case 30:  time_frame = "M30"; break;
       case 60:  time_frame = "H1";  break;
       case 240: time_frame = "H4";  break;
       default: 
           MessageBox(WRONG_TF, WRONG_TF_HDR, MB_OK | MB_ICONWARNING | MB_DEFBUTTON1); 
           return(-2);
     }
// проверка корректности задания фильтра по барам
   if(hole_min < 1) 
       hole_min = 1; 
   if(bars_ignore == false) 
       hole_min = 1;
// проверка корректности задания фильтра по гэпам
   if(gap_min < 0) 
       gap_min = 0;
   if(gap_ignore == false) 
       gap_min = 0;
   if(breakup_min < hole_min)
     { 
       string message = StringConcatenate(WRONG_BREAKUP, BREAKUP_CHANGE, hole_min);
       int warning_1 = MessageBox(message, WRONG_BREAKUP_HDR,
                                  MB_OKCANCEL | MB_ICONWARNING | MB_DEFBUTTON1); 
       if(warning_1 == 1) 
           breakup_min = hole_min;  
       else 
           return(-1);
       err = GetLastError();
       if(err > 0) 
           return(error_out(err, "Вывод сообщения о коррекции критерия разрыва"));
     }
// создание имени файла
   string date_start = TimeToStr(time_start, TIME_DATE);
   string date_end   = TimeToStr(time_end, TIME_DATE);
   string file_name = StringConcatenate(symbol, "_", time_frame, "_holes_",
                                        date_start, "-", date_end, ".csv");
// открытие выходного файла
   out_handle = FileOpen(file_name, FILE_CSV |FILE_WRITE, ";");
   err = GetLastError();
   if(out_handle < 0 || err > 0) 
       return(error_out(err, "Открытие выходного файла"));
// анализ данных истории 
   int    week_seconds = 604800; // количество секунд в неделе
   double weeks;                 // отношение диапазона дыры к количеству секунд в неделе
// выходные дни в сек.
   datetime holiday = StrToTime(begin_week_sessions) - StrToTime(end_week_sessions)
                        + (24*3600*3) - duration_bar;
   int hole_range; // диапазон дыры
   int bars_hole;  // баров в дыре
   int holes_total_amount;   // общее количество дыр
   int breakup_total_amount; // общее количество разрывов
   int bars_hole_amount;     // общее количество баров в дырах
   int bars_breakup_amount;  // общее количество баров в разрывах
   int gap_total_amount;     // общее количество гэпов
   int gap_holes;            // общий гэп в дырах
   int gap_breakups;         // общий гэп в разрывах
   int hole_max;             // значение максимальной дыры
   int breakup_max;          // значение максимального разрыва
   int gap_max;              // значение максимального гэпа
   bool note_ = false;
   double months, days, hours, minutes, seconds;
   int n = 1;
   for(int h = 0; h < bars; h++)
     {
       // время текущего и предыдущего баров в истории
       datetime bar_time_current, bar_time_previous;
       // цена открытия текущего и цена закрытия предыдущего баров в истории
       double open_price_current, close_price_previous;
       if(!input_from_file)
         {
           bar_time_current  = iTime(NULL, 0, Bars - h - 2);
           bar_time_previous = iTime(NULL, 0, Bars - h - 1);
           open_price_current   = NormalizeDouble(Open[Bars - h - 2],4);
           close_price_previous = NormalizeDouble(Close[Bars - h - 1],4);
         }
       else
         {
           bar_time_previous = FileReadInteger(in_handle, LONG_VALUE);
           err = GetLastError();
           // если файл закончился, завершаем цикл
           if(err == 4099) 
               break; 
           if(err > 0) 
               return(error_out(err, "Чтение из входного файла времени пред.бара"));
           FileSeek(in_handle, 24, SEEK_CUR);
           err = GetLastError();
           if(err > 0) 
               return(error_out(err, "Смещение во вх. файле к ц.закр. пред. бара"));
           close_price_previous = FileReadDouble(in_handle, DOUBLE_VALUE);
           if(err == 4099) 
               break; // если файл закончился, завершаем цикл
           err = GetLastError();
           if(err > 0) 
               return(error_out(err, "Чтение из входного файла цены закрытия"));
           FileSeek(in_handle, 8, SEEK_CUR);
           err = GetLastError();
           if(err > 0) 
               return(error_out(err, "Смещение во входном файле к след.бару"));
           bar_time_current = FileReadInteger(in_handle, LONG_VALUE);
           open_price_current = FileReadDouble(in_handle, DOUBLE_VALUE);
           err = GetLastError();
           if(err == 4099) 
               break; // если файл закончился, завершаем цикл
           if(err > 0) 
               return(error_out(err, "Чтение из вх. файла след.бара"));
           FileSeek(in_handle, -12, SEEK_CUR);
           err = GetLastError();
           if(err > 0) 
               return(error_out(err, "Смещение во входном файле к началу бара"));
         }
       // гэп в пунктах
       double abs_gap  = MathAbs(open_price_current - close_price_previous);
       double pips_gap = NormalizeDouble(abs_gap/point, 0);  
       // фактический диапазон таймфрейма с учетом неточности
       int time_frame_range = bar_time_current - bar_time_previous; 
       if(time_frame_range > duration_bar) // кол-во секунд в баре превышает таймфрейм
         {
           // кол-во секунд в баре превышает количество секунд в неделе
           if(time_frame_range > week_seconds) 
             {
               // значение дыры в недельном выражении
               weeks = MathFloor(time_frame_range / week_seconds); 
                  
               if(TimeDayOfWeek(bar_time_previous) > TimeDayOfWeek(bar_time_current))
                   hole_range = time_frame_range - holiday * (1 + weeks) - duration_bar;
               else 
                   hole_range = time_frame_range - (holiday * weeks) - duration_bar;
             } 
           else
             {
               weeks = 0;
               if(TimeDayOfWeek(bar_time_previous) > TimeDayOfWeek(bar_time_current))
                   hole_range = time_frame_range - holiday - duration_bar;
               else 
                   hole_range = time_frame_range - duration_bar;
             }
           bars_hole = hole_range / duration_bar;
           if(bars_hole >= hole_min && pips_gap >= gap_min)
             { 
               holes_total_amount++;          // общее количество дыр (увеличиваем)
               // общее количество баров в дырах (увеличиваем)
               bars_hole_amount += bars_hole;
               int gap;
               if(pips_gap >= gap_min) 
                 {
                   gap_holes += pips_gap; // общий гэп в дырах 
                   gap = pips_gap;
                   if(pips_gap == 0) 
                       n = 0; 
                 }
               else 
                   gap = 0;
               seconds = bars_hole * duration_bar;
               string duration_hole = interval_to_str(seconds);
               if(bars_hole >= breakup_min)
                 {
                   // общее количество разрывов
                   breakup_total_amount++;
                   // общее количество баров в разрывах
                   bars_breakup_amount += bars_hole; 
                   // общий гэп в разрывах
                   gap_breakups += pips_gap; 
                 }
               if(hole_max < bars_hole && bars_hole < breakup_min)
                 {
                   // максимальная дыра
                   hole_max = bars_hole;
                   // п/п номер
                   int number_hole = holes_total_amount;
                 } 
               if(breakup_max <= bars_hole && bars_hole >= breakup_min)
                 {
                   // максимальный разрыв
                   breakup_max = bars_hole;
                   // п/п номер
                   int number_breakup = holes_total_amount;
                 }     
               if(gap_max <= pips_gap)
                 {
                   // максимальный гэп
                   gap_max = pips_gap;
                   // п/п номер
                   int number_gap = holes_total_amount; 
                 }     
               // создание таблицы *.csv файла
               if(new_file && report_table)
                 {
                   if(report_summary)
                     {
                       FileSeek (out_handle, 2400, SEEK_END);
                       err = GetLastError();
                       if(err > 0) 
                           return(error_out(err, "Смещение в файле для сводки"));
                     }
                   FileWrite(out_handle, "№ п/п","Время начала", "Время окончания",
                                         "Размер (баров)", "Длительность (мин)",
                                         "Длительность", "Гэп (пт)");
                   err = GetLastError();
                   if(err > 0) 
                       return(error_out(err, "Запись шапки таблицы"));
                   new_file = false;
                 }
               FileWrite(out_handle, holes_total_amount,
                         TimeToStr(bar_time_previous + duration_bar),
                         TimeToStr(bar_time_current),
                         bars_hole, bars_hole*Period(),
                         duration_hole, gap);
               err = GetLastError();
               if(err > 0) 
                   return(error_out(err, "Запись строки таблицы"));
               // максимальная дыра и разрыв
               int hole_range_max = number_hole;
               int breakup_range_max = number_breakup;
               int gap_range_max = number_gap;
             }
         }
     }
   // ловля ошибки "индекс за пределами массива"
   err = GetLastError();
   if(err > 0 && err != 4002) 
       return(error_out(err, "После окончания перебора баров"));
   // создание отчета *.csv файла 
   double bars_hole_amount_     = bars_hole_amount;     
   double bars_breakup_amount_  = bars_breakup_amount;  
   double holes_total_amount_   = holes_total_amount;   
   double breakup_total_amount_ = breakup_total_amount; 
   double gap_holes_            = gap_holes;
   double gap_total_amount_     = gap_total_amount;
   double bars_                 = bars;
   double hole_average_size_; 
   if(holes_total_amount != breakup_total_amount)
     {
       seconds = (bars_hole_amount - bars_breakup_amount) * duration_bar;
       string duration_holes = interval_to_str(seconds);
       hole_average_size_ = NormalizeDouble((bars_hole_amount_ - 
                                            bars_breakup_amount_) /
                                            (holes_total_amount_ - 
                                            breakup_total_amount_), 2);
       int only_holes_total_amount_ = (holes_total_amount - breakup_total_amount);
       int bars_only_hole_amount_ = (bars_hole_amount - bars_breakup_amount);
     }
   seconds = time_end - time_start;
   string duration_period = interval_to_str(seconds);
   if (holes_total_amount > 0)
     {
       seconds = bars_hole_amount * duration_bar;
       string duration_holes_ = interval_to_str(seconds);        
       double hole_average_size = NormalizeDouble(bars_hole_amount_/holes_total_amount_,2);
       string gap_average_size  = NormalizeDouble(gap_holes_/holes_total_amount_, 2);

       FileSeek(out_handle, 0, SEEK_SET);
       err = GetLastError();
       if (err > 0) return (error_out(err,"Смещение в начало файла для записи отчёта"));
       
       string hole_comment;
       if (hole_min == breakup_min) hole_comment = "смотреть <Разрывы>, согласно заданным"+
                                                   " пользователем условиям)";
       else hole_comment = StringConcatenate(hole_min," - ",breakup_min," баров )"); 
       hole_comment = StringConcatenate("ДЫРЫ  ( ",hole_comment);

       string breakup_comment = StringConcatenate("РАЗРЫВЫ ( ",breakup_min," баров и выше)");
       
       if (breakup_total_amount != 0)          
       {
           seconds = bars_breakup_amount * duration_bar;
           string duration_breakups = interval_to_str(seconds);
           double breakup_average_size = NormalizeDouble(bars_breakup_amount_
                                                           /breakup_total_amount_, 2);
       }

       if (report_summary)
       {
           FileWrite(out_handle, "\nОтчет по отсутствующим барам в данных истории");
           FileWrite(out_handle, "Инструмент - ",Symbol(),"Таймфрейм",time_frame);
           FileWrite(out_handle, "Период",date_start,date_end);
           FileWrite(out_handle, "Баров в истории",bars,"баров");
           FileWrite(out_handle, "Длительность (мин)",(time_end-time_start)/60,
                                 duration_period);
           FileWrite(out_handle, "\nОБЩИЙ АНАЛИЗ дыр и разрывов");
           FileWrite(out_handle, "Количество",holes_total_amount);
           FileWrite(out_handle, "Общий размер",bars_hole_amount,"баров");
           FileWrite(out_handle, "Длительность (мин)",
                                 (bars_hole_amount*duration_bar)/60,duration_holes_);
           FileWrite(out_handle, "Средний размер",hole_average_size,"баров");
           FileWrite(out_handle, "Общий гэп",gap_holes,"пт");
           FileWrite(out_handle,"Максимальный гэп",gap_max,"пт","№",gap_range_max);
           FileWrite(out_handle, "Средний гэп",gap_average_size,"пт");
           FileWrite(out_handle, "\n" + hole_comment);
           FileWrite(out_handle,  "Количество",only_holes_total_amount_);
           FileWrite(out_handle, "Размер",bars_only_hole_amount_,"баров");
           FileWrite(out_handle, "Длительность (мин)",
                                 (bars_hole_amount-bars_breakup_amount)*duration_bar/60,
                                 duration_holes);
           FileWrite(out_handle, "Максимальный размер",hole_max,"№",hole_range_max);
           FileWrite(out_handle, "Средний размер",hole_average_size_);
           FileWrite(out_handle, "\n" + breakup_comment);
           FileWrite(out_handle, "Количество",breakup_total_amount);
           FileWrite(out_handle, "Размер",bars_breakup_amount,"баров");
           FileWrite(out_handle, "Длительность (мин)",bars_breakup_amount*duration_bar/60,
                                 duration_breakups);
           FileWrite(out_handle, "Максимальный размер",breakup_max,"баров","№",
                                 breakup_range_max);
           FileWrite(out_handle, "Средний размер",breakup_average_size,"баров\n");
           err = GetLastError();
           if (err > 0) return (error_out(err,"Запись отчёта"));
       }
     }
   else
     {
       FileWrite(out_handle, "На данном графике дыр и разрывов НЕ ОБНАРУЖЕНО");
       err = GetLastError();
       if (err > 0) return (error_out(err,"Запись \"Дыр не обнаружено\""));
     }
   FileClose(out_handle);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "Закрытие файла"));
   MessageBox("В папке терминала MT4: \Experts\files\ создан файл отчета:\n\n" + file_name, 
              "Анализ данных истории успешно завершен", MB_OK | MB_DEFBUTTON1);
   err = GetLastError();
   if(err > 0) 
       return(error_out(err, "Вывод сообщения о завершении работы"));
   return(0);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string interval_to_str(int seconds)
  {
   int hours = seconds / 3600;
   int minutes = seconds % 3600 / 60;
   string str_interval;
   string zero_h = "", zero_m = ""; 
   if(hours < 10) 
       zero_h = "0"; 
   if(minutes < 10) 
       zero_m = "0"; 
   str_interval = StringConcatenate(zero_h, DoubleToStr(hours, 0), ":",
                                    zero_m, DoubleToStr(minutes, 0));            
   if(hours > 24)  
     {
       int days = hours / 24; hours = hours % 24;
       if(hours < 10) 
           zero_h = "0";
       str_interval = StringConcatenate(DoubleToStr(days, 0), " дн. ",
                                        zero_h, DoubleToStr(hours, 0), ":",
                                        zero_m, DoubleToStr(minutes, 0));  
       if(days > 30)   
         {
           int months = days/30; days = days%30;
           str_interval = StringConcatenate(DoubleToStr(months,0)," мес. ",
                                            DoubleToStr(days,0)," дн. ",
                                            zero_h,DoubleToStr(hours,0),":",
                                            zero_m,DoubleToStr(minutes,0));  
           
           if(months > 12) 
             {
               int years  = months / 2; months = months % 12;
               str_interval = StringConcatenate(DoubleToStr(years, 0), " лет ",
                                                   DoubleToStr(months, 0), " мес. ",
                                                   DoubleToStr(days, 0), " дней  ",
                                                   zero_h, DoubleToStr(hours, 0),":",
                                                   zero_m, DoubleToStr(minutes, 0));
             }
         }
     }   
   return (str_interval);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int error_out(int err, string where)
  {
   if (err == 0) return;
   string message = StringConcatenate("Ошибка №", err, ":\"", ErrorDescription(err), "\"\n",
                                      "возникла при выполнении операции \"", where, "\"");
   string caption = StringConcatenate("Возникла ошибка в модуле: \"", FILE_NAME, "\"!");
   MessageBox(message, caption, MB_OK | MB_ICONSTOP);
   return (err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string file_ext(string file_name)
  {
   string result = StringSubstr(file_name, StringLen(file_name) - 3, 3);
   int err = GetLastError();
   if(err > 0) 
       return(error_out(err, "Обработка заданной строки-имени файла"));
   return (result);
  }
//+------------------------------------------------------------------+

