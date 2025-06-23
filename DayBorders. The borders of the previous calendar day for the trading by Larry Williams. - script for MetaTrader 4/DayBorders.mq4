//+------------------------------------------------------------------+
//|                                                    DayBorders.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright " AP"
#property link      "ekr-ap@mail.ru"
//------------------------------------------------------------------+
/*
Скрипт рисует границы предыдущего календарного дня.
Вертикальные линии предыдущего дня с фиксированными именами DayTimeOpen DayTimeClose
Горизонтальные линии с фиксированнымии именами DayOpen DayClose
Цвета линий устанавливаются при компиляции.
*/
/*
The script draws borders of the last calendar day.
Vertical lines of the last day with fixed names DayTimeOpen DayTimeClose
Horizontal lines with fixed names DayOpen DayClose
Colors of lines of borders are set at compilation.
*/
color color_Time=Green, color_DayOpen=Green,color_DayClose=Purple; //Set colors of lines

int start()
  {
datetime day=24*60*60;
datetime r=(TimeCurrent()/day)*day;
int      cd=iBarShift(NULL,0,r,FALSE);
datetime r2=r-day;

if(TimeDayOfWeek(r2)==0) r2=r2-day-day;
int cd2=iBarShift(NULL,0,r2,FALSE);

                     if(ObjectFind("DayTimeClose")==-1)    
                              {ObjectCreate  ("DayTimeClose",OBJ_VLINE,0,r,0);                               
                              }
                   else        ObjectSet     ("DayTimeClose",OBJPROP_TIME1,r);
                     if(ObjectFind("DayTimeOpen")==-1)      
                              {ObjectCreate  ("DayTimeOpen",OBJ_VLINE,0,r2,0);                               
                              }
                     else     ObjectSet      ("DayTimeOpen",OBJPROP_TIME1,r2);
                     
if(ObjectFind("DayOpen")==-1)          {ObjectCreate("DayOpen",OBJ_HLINE,0,0,Open[cd2]);                                       
                                       }
                              else     ObjectSet("DayOpen",OBJPROP_PRICE1,Open[cd2]);

if(ObjectFind("DayClose")==-1)          {ObjectCreate("DayClose",OBJ_HLINE,0,0,Close[cd]);                                       
                                       }                                       
                              else     ObjectSet("DayClose",OBJPROP_PRICE1,Open[cd]);
                              
                if(Open[cd2]<Close[cd]) {ObjectSetText("DayOpen","^"); 
                                       ObjectSetText("DayClose","^");
                                          }
                else {ObjectSetText("DayOpen","V");
                     ObjectSetText("DayClose","V");
                     }                              
                              ObjectSet     ("DayTimeClose",OBJPROP_COLOR,color_Time);
                              ObjectSet     ("DayTimeOpen",OBJPROP_COLOR,color_Time);
                              ObjectSet("DayOpen",OBJPROP_COLOR,color_DayOpen);
                              ObjectSet("DayClose",OBJPROP_COLOR,color_DayClose);                                                         
   return(0);
  }
//+------------------------------------------------------------------+