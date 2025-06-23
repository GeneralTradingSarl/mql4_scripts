//+------------------------------------------------------------------+
//|                                       StringArraySuiteSample.mq4 |
//|                                         Copyright © 2006, sx ted |
//|                                                       2006.07.14 |
//| Purpose: Usage of functions in StringArraySuite.mqh              |
//| Notes..: View the formatted output files with WordPad or similar |
//|          in folder C:\Program Files\MetaTrader 4\experts\files   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, sx ted"
#include <StringArraySuite.mqh>
//+------------------------------------------------------------------+
//| script program init function                                     |
//+------------------------------------------------------------------+
int init() 
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| PadStrL function                                                 |
//+------------------------------------------------------------------+
string PadStrL(string str, string sPadChar, int iLen) 
  {
   while( StringLen(str) < iLen ) 
       str = sPadChar + str;
   return (str);
  }
//+------------------------------------------------------------------+
//| script program deinit function                                   |
//+------------------------------------------------------------------+
int deinit() 
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start() 
  {
   if(iOpen(NULL, PERIOD_MN1, 0) == 0) 
       iOpen(NULL, PERIOD_MN1, 0); // refresh chart if not currently open
   int iMonths = iBarShift(NULL, PERIOD_MN1, D'2000.01.01'); 
   int iLen = 1, iYear, iRows, iRow, iCol, i;
   int iMaxVolume = iVolume(NULL, PERIOD_MN1, Highest(NULL, PERIOD_MN1, MODE_VOLUME, iMonths));
//----
   while(iMaxVolume >= MathPow(10, iLen)) 
       iLen++;
   string A[1][13]={"Year", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", 
                    "Sep", "Oct", "Nov", "Dec"};
//----
   for(iCol = 1; iCol <= 12; iCol++) 
       A[iRow][iCol] = PadStrL(A[iRow][iCol], " ", iLen);
   datetime tTime;
//----
   for(i = iMonths; i >= 0; i--) 
     {
       tTime = iTime(NULL, PERIOD_MN1, i);
       if(TimeYear(tTime) != iYear) 
         {
           iYear = TimeYear(tTime);
           iRow = StringArrayAdd(A, 1, PadStrL(" ", " ", iLen));
           A[iRow][0] = DoubleToStr(iYear, 0);
         }
       iCol = TimeMonth(tTime);
       A[iRow][iCol] = PadStrL(DoubleToStr(iVolume(NULL, PERIOD_MN1, i), 0), " ", iLen);
     }
//----
   StringArraySort(A, 0, 0, MODE_DESCEND);
   iRow = StringArrayFind(A, "Year", 1, 0, 0, MODE_DESCEND); // hard seek
   iRow = StringArrayInsert(A, iRow+1, 1, PadStrL("-", "-", iLen));
   A[iRow][0] = "----";
//----
   StringArrayWrite(A, Symbol() + "_MN_Volume_ZA.CSV");
   string A1[][13];
   iRows = StringArrayLoad(Symbol() + "_MN_Volume_ZA.CSV", A1, 13); // import from file to array
   if(iRows < 0 ) 
       return (-1);
   StringArraySort(A1, 2, iRows-2); // default MODE_ASCEND sort, excluding first 2 header rows
   iRow = StringArrayFind(A1, "2000", 1, 2, iRows - 2);
   int iCells = StringArrayDelete(A1, iRow); // delete row with year="2000"
//----
   StringArrayWrite(A1, Symbol() + "_MN_Volume_AZ.CSV");
   return(0);
  }
//+------------------------------------------------------------------+