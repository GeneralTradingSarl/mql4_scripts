//+------------------------------------------------------------------+
//|                                                  Wave Labels.mq4 |
//|                                           Copyright 2012, bdeyes |
//|                                 http://www.mql4.com/users/bdeyes |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, bdeyes"
#property link      "http://www.mql4.com/users/bdeyes"

#include <stdlib.mqh>


//+------ CHANGE HERE CHARACTER PARAMETERS -----------------------+

string Text1 = "A";  // Enter Text to place on screen - leave only quotes to not print (i.e "A" > "" ) 
string Text2 = "B";  // Enter Text to place on screen
string Text3 = "C";  // Enter Text to place on screen
string Text4 = "D";  // Enter Text to place on screen
string Text5 = "E";  // Enter Text to place on screen
string Text_font = "Arial Bold"; // font of text
int Text_fontsize = 14; // size of text
color Text_color = Red; // color of text

int TextBarsAhead2 = 7; // # bars to space 2nd letter from first
int TextBarsAhead3 = 14; // # bars to space 3rd letter from first
int TextBarsAhead4 = 21; // # bars to space 4th letter from first
int TextBarsAhead5 = 28; // # bars to space 5th letter from first  
  

//+------------------------------------------------------------------+   






//+-----------------------------SCRIPT CODE--------------------------+
int start()
  { 
   double price = WindowPriceOnDropped(); // find the price point where dropped
   datetime Time1 = WindowTimeOnDropped(); // find the time point where dropped
   int TimeNow = TimeCurrent(); // get the current time ( makes name unique)
   datetime Time2 = Time1+TextBarsAhead2*Period()*60;
   datetime Time3 = Time1+TextBarsAhead3*Period()*60;
   datetime Time4 = Time1+TextBarsAhead4*Period()*60;
   datetime Time5 = Time1+TextBarsAhead5*Period()*60;
     
   
   string gap = "    "; // spacing between text characters
   string text = Text1+gap+Text2+gap+Text3+gap+Text4+gap+Text5; // put the text in a line
   TextToPrint ("Wave labels1" + TimeNow, Text1, Text_fontsize, Text_font, Text_color, Time1, price); //print 1st letter
   TextToPrint ("Wave labels2" + TimeNow, Text2, Text_fontsize, Text_font, Text_color, Time2, price); //print 1st letter
   TextToPrint ("Wave labels3" + TimeNow, Text3, Text_fontsize, Text_font, Text_color, Time3, price); //print 1st letter
   TextToPrint ("Wave labels4" + TimeNow, Text4, Text_fontsize, Text_font, Text_color, Time4, price); //print 1st letter
   TextToPrint ("Wave labels5" + TimeNow, Text5, Text_fontsize, Text_font, Text_color, Time5, price); //print 1st letter
   

         
   return(0);
  }
//+------------------------------------------------------------------+

void TextToPrint(string TextName, string LabelText, int FontSize, string FontName, color TextColor, datetime Time0, double Price0)
  {
    if(StringLen(LabelText)<1) return(0);
    ObjectCreate(TextName, OBJ_TEXT, 0, Time0, Price0);
    ObjectSetText(TextName, LabelText, FontSize, FontName, TextColor);
    
  }