//+------------------------------------------------------------------+
//|                                           ClosingPriceReport.mq4 |
//|                                              Mustafa Doruk Basar |
//+------------------------------------------------------------------+
#property copyright "Mustafa Doruk Basar"
#property link      ""

#property show_inputs

extern int bar_index=1;
extern string file_name_suffix="closing_price_report";

string Symbols[1000];
double SyClose[1000];

int TotalSymbols, TotalRecords, nor, diff;

//+------------------------------------------------------------------+

int start()
{

   myhist(nor);
   string msg= "ClosingPriceReport -->  trader\mql4\files";
   MessageBox(msg,0);
   return(0);

}

//+------------------------------------------------------------------+

int myhist(int nor2) 
{
     
  int    handle, i, r;
  string fname, Sy, descr;
  int lasterror;

  fname = "symbols.raw";
  handle=FileOpenHistory(fname, FILE_BIN | FILE_READ);
  if(handle<1)
  {
      lasterror = GetLastError();
      Print("Error creating file: ",lasterror);
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
 
    SyClose[r]=iClose(Sy,PERIOD_D1,nor2);
    
    r++;
  }
 
  FileClose(handle);
  
  int j,handle2;

  string file_name=StringConcatenate(file_name_suffix, TimeToString(iTime(NULL,0,nor2),TIME_DATE),".csv");

  handle2=FileOpen(file_name,FILE_WRITE|FILE_CSV,";");
  if(handle2<1)
  {
      lasterror = GetLastError();
      Print("Error updating file: ",lasterror);
      return(false);
  }
  
  FileWrite(handle2,"Symbol;Close");
  
  for(j=0;j<TotalRecords;j++)
  {
      FileWrite(handle2,Symbols[j],SyClose[j]);
  }
  
  FileClose(handle2);
   
  return(0);
}
//+------------------------------------------------------------------+

