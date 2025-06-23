//+------------------------------------------------------------------+
//|                                                   CreateHTML.mq4 |
//|                                  Copyright © 2007, Waddah Attar. |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Waddah Attar."
#property link      "waddahattar@hotmail.com"
//----
int handle;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   handle = FileOpen(Symbol() + " - " + GetPeriodName() + ".htm", 
                     FILE_BIN|FILE_WRITE);
   if(handle < 1)
     {
       Print("Err ", GetLastError());
       return(0);
     }
   WriteHTMLHeader();
   WriteString("<P>Symbol: <B>" + Symbol() + "</B>  -  Period: <B>" + 
               GetPeriodName() + "</B>  -  Bars: <B>" + Bars + 
               "</B></P>");
   WriteTABLEHeader();
//----
   for(int i = 0; i < Bars - 1; i++)
     {
       WriteRow(i);
       if(Period() < PERIOD_D1 && TimeDay(Time[i]) != 
          TimeDay(Time[i+1]) && i != Bars - 1)
         {
           WriteTABLEFooter();
           WriteString("<HR>");
           WriteTABLEHeader();
         }
     }
   WriteTABLEFooter();
   WriteString("<HR>");
   WriteString("This Report Created By Waddah Attar HTML Script" + "<BR>");
   WriteString("Email: <A href='mailto:waddahattar@hotmail.com'>");
   WriteString("waddahattar@hotmail.com</A>"+"<BR>");
   WriteHTMLFooter();  
   FileClose(handle);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteString(string txt)
  {
   FileWriteString(handle, txt,StringLen(txt));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteHTMLHeader()
  {
   WriteString("<HTML>");
   WriteString("<HEAD>");
   WriteString("<TITLE>");
   WriteString(Symbol() + " - " + GetPeriodName() + " - By Waddah Attar");
   WriteString("</TITLE>");
   WriteString("</HEAD>");
   WriteString("<BODY>");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteHTMLFooter()
  {
   WriteString("</BODY>");
   WriteString("</HTML>");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteTABLEHeader()
  {
   WriteString("<TABLE cellSpacing=1 cellPadding=1 width=95%" + 
               " align=center border=1>");
   WriteString("<TBODY bgColor=ivory>");
   WriteString("<TR bgcolor=#ffdead>");
   WriteString("<TH>Date</TH>");
   if(Period()<PERIOD_D1)
       WriteString("<TH>Time</TH>");
   WriteString("<TH>Open</TH>");
   WriteString("<TH>High</TH>");
   WriteString("<TH>Low</TH>");
   WriteString("<TH>Close</TH>");
   WriteString("<TH>Volume</TH>");
   WriteString("<TH>Chng Vol %</TH>");
   WriteString("<TH>(H+L+C)/3</TH>");
   WriteString("<TH>(H-L)</TH>");
   WriteString("<TH>(C-O)</TH>");
   WriteString("</TR>");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteTABLEFooter()
  {
   WriteString("</TBODY>");
   WriteString("</TABLE>");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteRow(int i)
  {
   string clr = "";
   if(Close[i] > Open[i]) 
       clr = "bgColor=#f0fff0";
   if(Close[i] < Open[i]) 
       clr = "bgColor=#fff0f0";
   WriteString("<TR " + clr + ">");
   WriteString("<TD>");
   WriteString(TimeToStr(Time[i], TIME_DATE));
   WriteString("</TD>");
   if(Period() < PERIOD_D1)
     {
       WriteString("<TD>");
       WriteString(TimeToStr(Time[i], TIME_MINUTES));
       WriteString("</TD>");
     }
   WriteString("<TD>");
   WriteString(DoubleToStr(Open[i], Digits));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr(High[i], Digits));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr(Low[i], Digits));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr(Close[i], Digits));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr(Volume[i], 0));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr((Volume[i] - Volume[i+1]) / Volume[i]*100, 2));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr((High[i] + Low[i] + Close[i]) / 3, Digits));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr((High[i] - Low[i]) / Point, 0));
   WriteString("</TD>");
   WriteString("<TD>");
   WriteString(DoubleToStr((Close[i] - Open[i]) / Point, 0));
   WriteString("</TD>");
   WriteString("</TR>");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetPeriodName()
  {
   switch(Period())
     {
       case PERIOD_D1:  return("Day");
       case PERIOD_H1:  return("Hour");
       case PERIOD_H4:  return("4 Hour");
       case PERIOD_M1:  return("Minute");
       case PERIOD_M15: return("15 Minute");
       case PERIOD_M30: return("30 Minute");
       case PERIOD_M5:  return("5 Minute");
       case PERIOD_MN1: return("Month");
       case PERIOD_W1:  return("Week");
     }
  }
//+------------------------------------------------------------------+