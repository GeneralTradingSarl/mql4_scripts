//+------------------------------------------------------------------+
//|                                        Market Watch Auto-CSV.mq4 |
//|                                 Copyright 2018, Francesco Rubeo. |
//|                         https://www.mql5.com/en/users/minervainc |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Francesco Rubeo."
#property link      "https://www.mql5.com/en/users/minervainc"
#property version   "1.00"
#property strict
int my_archive;
string my_File_Name="All Symbols in MarketWatch.csv";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(FileIsExist(my_File_Name))
     {
      FileDelete(my_File_Name);
     }

   my_archive=FileOpen(my_File_Name,FILE_WRITE|FILE_SHARE_WRITE|FILE_CSV);
//Check if Archive is opened
   if(my_archive==INVALID_HANDLE)
     {
      Print("Can't open archive");
      Print("Error code : ",GetLastError());
     }
   else
     {
      Print("Archive opened");
     }
//Loop on Marketwatch
   int n_markets=SymbolsTotal(false);
   for(int i=0;i<n_markets;i++)
     {
      PrintFormat("%s",SymbolName(i,true));
      FileWrite(my_archive,StringFormat("%s",SymbolName(i,true)));
     }
   FileClose(my_archive);
  }
//+------------------------------------------------------------------+
