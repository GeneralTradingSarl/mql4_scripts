//+------------------------------------------------------------------+
//|                                                AllMarketData.mq4 |
//|                                 Copyright © 2011, MGAlgorithmics |
//|                                          http://www.mgaforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MGAlgorithmics"
#property link      "http://www.mgaforex.com"


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>

#define LONG     0
#define SHORT    1
#define TYPE     2

#define SWAP     0
#define CURRENCY 1
#define DIR      2

#define SIZE     0   //Lot information
#define MIN      1
#define LOTSTEP  2
#define MAXLOT   3

#define VALUE    1  //Tick info

#define STARTING   0  //Timing info
#define EXPIRATION 1

#define ALLOWED    0  //Trade
#define MODE       1  //profit calc mode

#define CALC       0  //Margin
#define INIT       1
#define HEDGED     2
#define REQUIRED   3 
    
string Symbols[1000];
string Descr[1000];
double SyDigits[1000];
double Spread[1000];
double swap[1000][3];
double Stop[1000];
double Lot[1000][4];
double Tick[1000][2];
double Timing[1000][2];
double Trade[1000][2];
double Margin[1000][4];
double Freeze[1000];

int p, n, TotalSymbols, MAX=0;

void start() 
{
  TotalSymbols=FindSymbols();
  
  PrintResult ("All Market Data", TotalSymbols);
}

int FindSymbols() 
{
  int    handle, i, r, TotalRecords;
  string fname, Sy, descr;
  //----->
  fname = "symbols.raw";
  handle=FileOpenHistory(fname, FILE_BIN | FILE_READ);
  if(handle<1)
    {
     Print("HTML Report generator - Unable to open file"+fname+", the last error is: ", GetLastError());
     return(false);
    }  
  TotalRecords=FileSize(handle) / 1936;
  ArrayResize(Symbols, TotalRecords);
    
  for(i=0; i<TotalRecords; i++) 
  {
    Sy=FileReadString(handle, 12);
    descr=FileReadString(handle, 75);
    FileSeek(handle, 1849, SEEK_CUR); // goto the next record
     
    Symbols[r]=Sy;
    Descr[r]=descr;
    SyDigits[r]=MarketInfo(Sy,MODE_DIGITS);
    
    Spread[r]=MarketInfo(Sy,MODE_SPREAD);
    
    swap[r][LONG]=MarketInfo(Sy,MODE_SWAPLONG);
    swap[r][SHORT]=MarketInfo(Sy,MODE_SWAPSHORT); 
    swap[r][TYPE]=MarketInfo(Sy,MODE_SWAPTYPE);
  
    Stop[r]=MarketInfo(Sy,MODE_STOPLEVEL);
  
    Lot[r][SIZE]=MarketInfo(Sy,MODE_LOTSIZE);
    Lot[r][MIN]= MarketInfo(Sy,MODE_MINLOT);
    Lot[r][LOTSTEP]=MarketInfo(Sy,MODE_LOTSTEP);
    Lot[r][MAXLOT]=MarketInfo(Sy,MODE_MAXLOT);
  
    Tick[r][VALUE]= MarketInfo(Sy,MODE_TICKVALUE);
    Tick[r][SIZE]=MarketInfo(Sy,MODE_TICKSIZE);
  
    Timing[r][STARTING]=MarketInfo(Sy,MODE_STARTING);
    Timing[r][EXPIRATION]=MarketInfo(Sy,MODE_EXPIRATION);
  
    Trade[r][ALLOWED]=MarketInfo(Sy,MODE_TRADEALLOWED);
    Trade[r][MODE]=MarketInfo(Sy,MODE_PROFITCALCMODE); 
    if (Trade[r][MODE]>MAX) MAX=Trade[r][MODE];
    
    
    // the script won't print the following items ... if you need them, amend yourself the PrintResult function below :)
    
    /*Margin[r][CALC]=MarketInfo(sSymbol,MODE_MARGINCALCMODE);
    Margin[r][INIT]=MarketInfo(sSymbol,MODE_MARGININIT);
    Margin[r][HEDGED]=MarketInfo(sSymbol,MODE_MARGINHEDGED);
    Margin[r][REQUIRED]=MarketInfo(sSymbol,MODE_MARGINREQUIRED);
    Freeze[r]=MarketInfo(sSymbol,MODE_FREEZELEVEL);*/
         
    // a different index for the count can be useful if you want to filter some elements from the whole list
    r++;
  }
 
  FileClose(handle);
  return(TotalRecords);
}
  
//+------------------------------------------------------------------+

int PrintResult (string title, int symbols)
 {
   int i, h;
   string fname, col="#E0E0E0";
   string sl, s0, fs;
//----
   fname = title+".html";
   h = FileOpen(fname,FILE_WRITE);
   if(h<1)
    {
     Print("HTML Report generator - Unable to open file"+fname+", the last error is: ", GetLastError());
     return(false);
    }
   
   s0="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">";FileWrite(h,s0);
   s0="<html><head><title>"+AccountCompany()+" "+title+"</title>" ;FileWrite(h,s0);
   s0="<meta name=\"generator\" content=\"MGAlgorithmics, forex software.\">" ;FileWrite(h,s0);
   s0="<link rel=\"help\" href=\"http://www.mgaforex.com\">" ;FileWrite(h,s0);

   s0="<style type=\"text/css\" media=\"screen\">" ;FileWrite(h,s0);
   s0="<!--td { font: 8pt Calibri,Arial; }//--></style>" ;FileWrite(h,s0);

   s0="</head>" ;FileWrite(h,s0);
   
   s0="<body topmargin=1 marginheight=1 style=\"background-color:#EEEEEE;\">" ;FileWrite(h,s0);

   s0="<div align=center><div style=\"font: 12pt Arial\">" ;FileWrite(h,s0);   
   s0="<b>"+WindowExpertName()+".ex4 Generated Report</b>" ;FileWrite(h,s0);
   s0="</div>" ;FileWrite(h,s0);
   
   s0="<div align=center><div style=\"font: 8pt Arial\">" ;FileWrite(h,s0);
   s0="<b>@2011 <a href=\"http://www.mgaforex.com\">MGAforex.com</a></b>" ;FileWrite(h,s0);
   s0="</div>" ;FileWrite(h,s0);
   s0="<br>" ;FileWrite(h,s0);
   
   s0="<div style=\"width:1000px;\">" ;FileWrite(h,s0);
   
   s0="<span style=\"float:left; background-color:#FFFFFF; border:1px solid; border-color:#C0C0C0;\">" ;FileWrite(h,s0);
   s0="<table cellspacing=3 cellpadding=3 border=0>" ;FileWrite(h,s0);
   
   for (int j=0; j<=MAX; j++)
      {
      s0="<tr align=center bgcolor=\"#6699CC\"><font color=\"#FFFFFF\">" ;FileWrite(h,s0); //6666CC
      FileWrite(h,Header());  
      s0="</tr>";FileWrite(h,s0);
         for (i=0; i<symbols; i++)
         {
         if (Trade[i][MODE]!=j) continue;
         fs=StringConcatenate("<tr align=center bgcolor=\""+col+"\">",Line(i),"</tr>");
         FileWrite(h,fs);
         }
      }

   s0="</table>";FileWrite(h,s0);
   s0="</span>"; FileWrite(h,s0);
   s0="</span></div></body></html>"; FileWrite(h,s0);
   FileClose(h); 

   //----
   return(0);
}
  
string Header ()
{  
   string s0;
   s0=StringConcatenate(
   "<td>#</td>",        "<td>Symbol</td>",      "<td>Description</td>",    "<td>Digits</td>",      "<td>Spread</td>",
   "<td>Swap Long</td>","<td>Swap Short</td>",  "<td>Swap Type</td>",      "<td>Stop Level</td>",  "<td>Lot Size</td>",
   "<td>Lot Min</td>",  "<td>Lot Step</td>",    /*"<td>Lot Max</td>",*/    "<td>Tick Value</td>",  "<td>Tick Size</td>",
   /*"<td>Starting</td>",*/   /*"<td>Expiration</td>",*/
   "<td>Trade Allowed</td>",   "<td>Pr. Mode</td>"
   );
  //----
   return(s0);
}

string Line (int i)
{
  string fs1;
  
  fs1=StringConcatenate(
     "<td>"+DoubleToStr(i,0)+"</td>",
     "<td>"+Symbols[i]+"</td>",  
     "<td nowrap>"+Descr[i]+"</td>",
     "<td>"+DoubleToStr(SyDigits[i],0)+"</td>",
     "<td>"+DoubleToStr(Spread[i],0)+"</td>",      
     "<td bgcolor=\""+Highlight(swap[i][LONG])+"\">"+DoubleToStr(swap[i][LONG],4)+"</td>",
     "<td bgcolor=\""+Highlight(swap[i][SHORT])+"\">"+DoubleToStr(swap[i][SHORT],4)+"</td>",
     "<td>"+InfoToStr(swap[i][TYPE], MODE_SWAPTYPE)+"</td>",
     "<td>"+DoubleToStr(Stop[i],0)+"</td>",
     "<td>"+DoubleToStr(Lot[i][SIZE],0)+"</td>",
     "<td>"+DoubleToStr(Lot[i][MIN],3)+"</td>",
     "<td>"+DoubleToStr(Lot[i][LOTSTEP],3)+"</td>",
   //"<td>"+DoubleToStr(Lot[i][MAXLOT],3)+"</td>",
     "<td>"+DoubleToStr(Tick[i][VALUE],6)+"</td>",
     "<td>"+DoubleToStr(Tick[i][SIZE],6)+"</td>",
   //"<td>"+TimeToStr(Timing[i][STARTING])+"</td>",
   //"<td>"+TimeToStr(Timing[i][EXPIRATION])+"</td>",
     "<td>"+InfoToStr (Trade[i][ALLOWED], MODE_TRADEALLOWED)+"</td>",
     "<td>"+InfoToStr (Trade[i][MODE], MODE_TRADES)+"</td>"
     );
    
//----
   return(fs1);
  }

/*string SwitchColor (string actual)       //ruins of an older function, it might still be of some use...
  {
   string res;
   if (actual=="#C0C0C0") res = "#E0E0E0";
   if (actual=="#E0E0E0") res = "#C0C0C0";
//----
   return(res);
  }*/

string Highlight (double sw)
{
   string res;
   if (sw<0) res = "#E0E0E0";  
   if (sw>=0) res = "#C0C0C0";
//----
   return(res);
}
  
string InfoToStr (double info, int mode)
{
  switch (mode)
          {
            case MODE_TRADES:
               if (info==0) return ("Forex");
               if (info==1) return ("CFD");
               if (info==2) return ("Future");
               break;
            case MODE_TRADEALLOWED:
               if (info==1) return ("yes");
               if (info!=1) return ("no");
               break;
            case MODE_SWAPTYPE:
               if (info==0) return ("points");
               if (info==1) return ("dep ccy");
               if (info==2) return ("percent");
               break;
          }
//----
}  
  
  
  
  
  
  
  
  