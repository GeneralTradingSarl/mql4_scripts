//+------------------------------------------------------------------+
//|                                                   Time_cript.mq4 |
//|                                           0_o-Brian Chikasha-o_0 |
//|                                        Brianchikasha@Hotmail.com |
//+------------------------------------------------------------------+
#property copyright "0_o-Brian Chikasha-o_0"
#property link      "Brianchikasha@Hotmail.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
  
  
  switch(DayOfWeek())                                  // Header of the 'switch'
     { 
      case 0 : Alert("Today is a Sunday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;                                           // Start of the 'switch' body
      case 1 : Alert("Today is a Monday. Current time is "+TimeToStr(TimeLocal(),TIME_MINUTES));     break;
      case 2 : Comment("Today is a Tuesday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;
      case 3 : Alert("Today is a Wednesday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;
      case 4 : Alert("Today is a Thursday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;
      case 5 : Alert("Today is a Friday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;
      case 6 : Alert("Today is a Saturday. Current time is "+TimeToStr(TimeCurrent(),TIME_MINUTES));     break;
      
      default: Alert("More than ten points");     // It is not the same as the 'case'
     } 
 //string var1=TimeToStr(TimeCurrent(),TIME_MINUTES);
 
if(OrdersTotal()>0)
PlaySound("W1.wav");

//----
   return(0);
  }
//+------------------------------------------------------------------+