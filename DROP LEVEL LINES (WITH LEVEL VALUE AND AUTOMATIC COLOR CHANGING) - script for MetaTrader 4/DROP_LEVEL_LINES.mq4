#include <stdlib.mqh>   

/*
This script will help you to draw horizontal segment lines (level lines).

-	This new script will draw horizontal lines like a segment (short line). 
-	It will show a text with the value (price) of the level line inserted above or below the line.
-	It will recognize when the line it's a bottom or top line changing automatically the color of the line and the position of the text (below a bottom line or above a top line).

Some properties can be modified by editing the code:
1.	You can modify the color for bottom or top lines
2.	You can modify the width of the lines 
3.	You can modify the length of the segment line
4.	You can modify the line type: segment (short line) or Ray (long full line)
5.	You can choose if you want to insert the level value as a text or not
6.	You can modify the distance of the text from the line
7.	You can modify the font size of the text
8.	You can modify the color of the text
*/


//+------ CHANGE HERE ALL LINE PROPERTIES --------------------------+

   // Modify below the color for your Bottom and top lines
color    Bottom_Line_Color = DodgerBlue;  // Color of bottom lines
color    Top_Line_Color    = Magenta;     // Color of Top lines

   // Modify below the properties of the lines
int      Line_Width        = 2;           // From 1 (thin) to 5 (thick) 
int      Line_length       = 4000;        // Length of segment line. 
bool     Line_Ray          = false;       // If "true" all lines will be drawn as a "Ray" (Long Line). If false = as a segment.

   // Modify below the properties of the text
bool     Insert_Text       = true;        // If true the level value will be displayed below or above the line. False = Not displayed
double   Dist_Text         = 4;           // Distance of text from line line (percent value of the window vertical high)
int      Font_Size         = 8;           // Font size of the text 
color    Text_Color        = White;       // Color of the text displayed below or above the line

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double      Price_on_Drop = WindowPriceOnDropped();
   datetime    time = WindowTimeOnDropped();
   int         TimeNow = TimeCurrent();
   int         timeframe = Period();
   double      Length_Factor;
   int         shift=iBarShift(NULL,timeframe,time);
   double      Max_at_time = High[shift];
   double      Min_at_time = Low[shift];
   double      Dist_to_Max = MathAbs(Price_on_Drop - Max_at_time)*10000;
   double      Dist_to_Min = MathAbs(Price_on_Drop - Min_at_time)*10000;
   double      Window_Max = WindowPriceMax();
   double      Window_Min = WindowPriceMin();
   double      Window_Dist = Window_Max - Window_Min;
   double      Text_Dist;
   color       Line_Color;
   string      Level_Value = DoubleToStr((MathRound(Price_on_Drop*10000)/10000),4);
   
   if(Dist_to_Max < Dist_to_Min) {Text_Dist = Window_Dist * (Dist_Text/100); Line_Color = Top_Line_Color;}
   if(Dist_to_Max > Dist_to_Min) {Text_Dist = Window_Dist * (-Dist_Text/100) + (0.03 * Window_Dist); Line_Color = Bottom_Line_Color;}
   
   
   switch(timeframe)
      {
      case 1      : Length_Factor = 0.2;   break;
      case 5      : Length_Factor = 1;     break;
      case 15     : Length_Factor = 3;     break;
      case 30     : Length_Factor = 6;     break;
      case 60     : Length_Factor = 12;    break;
      case 240    : Length_Factor = 48;    break;
      case 1440   : Length_Factor = 288;   break;
      case 10080  : Length_Factor = 2016;  break;
      case 43200  : Length_Factor = 8640;  break;
      }
      
   
   int length = Length_Factor * Line_length;

         if(Line_Ray == false)
         ObjectCreate("Line" + TimeNow,OBJ_TREND,0,time+length,Price_on_Drop,time-length,Price_on_Drop);
         else
         ObjectCreate("Line" + TimeNow,OBJ_HLINE,0,0,Price_on_Drop);       
         ObjectSet("Line" + TimeNow,OBJPROP_COLOR,Line_Color);
         ObjectSet("Line" + TimeNow,OBJPROP_WIDTH,Line_Width);
         ObjectSet("Line" + TimeNow,OBJPROP_RAY,Line_Ray);
         
         if(Insert_Text == true)
            {
            ObjectCreate("Text" + TimeNow,OBJ_TEXT,0,time,Price_on_Drop + Text_Dist,Price_on_Drop);
            ObjectSetText("Text" + TimeNow,"" + Level_Value,Font_Size,"Arial",Text_Color); 
            }
         
   return(0);
  }
//+------------------------------------------------------------------+