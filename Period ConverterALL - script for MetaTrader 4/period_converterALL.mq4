//+------------------------------------------------------------------+
//|                                          Period_ConverterALL.mq4 |
//|             Original Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//|      Add by DENISka: Only OffLine convert history from 1M Period | 
//|                  to M5, M15, M30, 1H, 4H, 1D, 1W, MN in one time |
//|                  And ReCreate M1 Volumes for create good history |
//|                                   denlove2@mail.ru ICQ:211771564 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007 Add changes by DENISka."
#property link      "denlove2@mail.ru"
#property show_inputs
//----
#include <WinUser32.mqh>
//----
extern int ReCreateM1Volume = -2;
//----
int        ExtHandle = -1; // file arrow
static int  ArrPeriod[];   // array of periods
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   if(Period() != PERIOD_M1)
     {
       Comment("For Converting begin period Must be M1."); 
       return(0);
     }
   string Comm; 
   int    i, start_pos, i_time, time0, last_fpos, periodseconds;
   double d_open, d_low, d_high, d_close, d_volume, last_volume;
   int    hwnd = 0, cnt = 0;
   if(ReCreateM1Volume > -2) // need recreate M1 TF  
     {
       int n_vol;
       Comm = "ReCreate M1 Period, to End File: ";     
       ExtHandle = FileOpenHistory(Symbol() + "" + Period() + ".hst", 
                                   FILE_BIN|FILE_READ|FILE_WRITE);
       if(ExtHandle < 0) 
         {
           Comment("Error opening file for ReCreate M1 Period.");
           return(-1);
         }
       //first enter to file
       FileSeek(ExtHandle, 148, SEEK_SET); 
       int sf = FileSize(ExtHandle);      // FileSize is not change 
       while(FileTell(ExtHandle) != sf)   // while not EOF file
         {
           FileSeek(ExtHandle, 4, SEEK_CUR);  // skip open time
           d_open = FileReadDouble(ExtHandle, DOUBLE_VALUE);
           d_low = FileReadDouble(ExtHandle, DOUBLE_VALUE);
           d_high = FileReadDouble(ExtHandle, DOUBLE_VALUE);
           d_close = FileReadDouble(ExtHandle, DOUBLE_VALUE);
           d_volume = FileReadDouble(ExtHandle, DOUBLE_VALUE);
           if((ReCreateM1Volume == -1 && d_volume <= 1) || 
              ReCreateM1Volume == 0)
             {
               n_vol = 1;
               if(d_open != d_close)
                   n_vol++;
               if(d_open != d_high)
                   if(d_close != d_high)
                       n_vol++;      
               if(d_open != d_low)
                   if(d_close != d_low)
                       n_vol++;             
             }
           else
               n_vol = d_volume;
           if(ReCreateM1Volume > 0)
               n_vol = ReCreateM1Volume;
           if(n_vol != d_volume) // write new volume
             {
               // skip back to last volume begin
               FileSeek(ExtHandle, -8, SEEK_CUR);
               FileWriteDouble(ExtHandle, n_vol, DOUBLE_VALUE);      
               FileFlush(ExtHandle);      
             }
           if(MathMod(FileTell(ExtHandle), 30000) == 0)
               Comment(Comm + " " + (sf - FileTell(ExtHandle)));      
         }    
       if(ExtHandle >= 0) 
         { 
           FileClose(ExtHandle); 
           ExtHandle = -1;
         }                 
     }
// return (0);
// converting to all TF     
   ArrayResize(ArrPeriod, 8);
   ArrPeriod[0] = 5;
   ArrPeriod[1] = 15;  
   ArrPeriod[2] = 30;  
   ArrPeriod[3] = 60;  
   ArrPeriod[4] = 240;  
   ArrPeriod[5] = 1440;  
   ArrPeriod[6] = 10080;    
   ArrPeriod[7] = 43200;      
//---- History header
   int    version = 400;
   string c_copyright = "(C)opyright 2003, MetaQuotes Software Corp.";
   string c_symbol = Symbol();
   int    i_period = 1;
   int    i_digits = Digits;
   int    i_unused[13];
   for(int qq = 0; qq < ArraySize(ArrPeriod); qq++)
     {
       i_period = Period()*ArrPeriod[qq];
       Comm = "Converting to Period (" + i_period + "), Bars to End: ";
       //----  
       ExtHandle = FileOpenHistory(c_symbol + i_period + ".hst", 
                                   FILE_BIN|FILE_WRITE);
       if(ExtHandle < 0) 
         {
           Comment("Error opening file for Convert to All TimeFrames.");
           return(-1);
         }
       //---- write history file header
       FileWriteInteger(ExtHandle, version, LONG_VALUE);
       FileWriteString(ExtHandle, c_copyright, 64);
       FileWriteString(ExtHandle, c_symbol, 12);
       FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
       FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
       FileWriteInteger(ExtHandle, 0, LONG_VALUE);        // timesign
       FileWriteInteger(ExtHandle, 0, LONG_VALUE);        // last_sync
       FileWriteArray(ExtHandle, i_unused, 0, 13);
       //---- write history file
       periodseconds = i_period*60;
       start_pos = Bars - 1;
       d_open = Open[start_pos];
       d_low = Low[start_pos];
       d_high = High[start_pos];
       d_volume = Volume[start_pos];
       //---- normalize open time
       i_time = Time[start_pos]/periodseconds;
       i_time *= periodseconds;
       for(i = start_pos - 1; i >= 0; i--)
         {
           if(MathMod(i, 1000) == 0)
               Comment(Comm + " " + i);
           time0 = Time[i];
           if(time0 >= i_time + periodseconds || i == 0)
             {
               if(i == 0 && time0 < i_time + periodseconds)
                 {
                   d_volume += Volume[0];
                   if(Low[0] < d_low)   
                       d_low = Low[0];
                   if(High[0] > d_high) 
                       d_high = High[0];
                   d_close = Close[0];
                 }
               last_fpos = FileTell(ExtHandle);
               last_volume = Volume[i];
               FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
               FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
               FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
               FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
               FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
               FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
               FileFlush(ExtHandle);
               cnt++;
               if(time0 >= i_time + periodseconds)
                 {
                   i_time = time0 / periodseconds;
                   i_time *= periodseconds;
                   d_open = Open[i];
                   d_low = Low[i];
                   d_high = High[i];
                   d_close = Close[i];
                   d_volume = last_volume;
                 }
             }
           else
             {
               d_volume += Volume[i];
               if(Low[i] < d_low)   
                   d_low = Low[i];
               if(High[i] > d_high) 
                   d_high = High[i];
               d_close = Close[i];
             }
         } 
       FileFlush(ExtHandle);
       if(ExtHandle >= 0) 
         { 
           FileClose(ExtHandle); 
           ExtHandle = -1; 
         }           
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   if(ExtHandle >= 0) 
     { 
       FileClose(ExtHandle); 
       ExtHandle = -1; 
     }
   Comment("");
  }
//+------------------------------------------------------------------+