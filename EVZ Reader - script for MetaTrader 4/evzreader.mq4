//+------------------------------------------------------------------+
//|                                                    EVZReader.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property show_inputs
#property strict


#define TIME_LIMIT 1217635200
#define MAX_TIME   2147483647
#define CUSTOM_FILE_NAME "EVZ_Data"
#define ROW_BYTE_SIZE 40

enum UpdateTime
  {
   NO_UPDATE, //Update once and end program
   MINUTE,  //Update each minute
   MINUTES_5,  //Update each 5 minutes
   MINUTES_10  //Update each 10 minutes
  };

input UpdateTime Update_Values = NO_UPDATE; //Update EVZ values

//+------------------------------------------------------------------+
//|           SCRIPT MODE                                            |
//+------------------------------------------------------------------+
void OnStart()
  {
   int timeUpdate = OnInitFunction();

   if(timeUpdate>0)
     {
      datetime lastTickUpdate = 0;
      while(!IsStopped())
        {
         if(lastTickUpdate + timeUpdate*1000 < GetTickCount())
           {
            TimerFunction();
            lastTickUpdate = GetTickCount();
           }
        }
     }


   DeInitFunction();
  }

//+------------------------------------------------------------------+
//|     EXPERT ADVISOR MODE   -> CHANGE ALSO COMMENTS FROM INIT      |
//|                           -> COMMENT OUT THE SCRIPT PARTS ABOVE  |
//+------------------------------------------------------------------+
/*

int OnInit()
{
   return OnInitFunction();
}

void OnDeinit(const int reason)
{
   DeInitFunction();
}

void OnTimer()
{
   TimerFunction();
}

*/

//---
//---


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInitFunction()
  {
   scraper = new YahooScraper("^EVZ");

   scraper.SaveFile(CUSTOM_FILE_NAME+".txt", TIME_LIMIT, MAX_TIME);

   switch(Update_Values)
     {
      case NO_UPDATE:
         return 0; //ExpertRemove(); break; //expert mode
      case MINUTE:
         return 60; //EventSetTimer(60); break;
      case MINUTES_5:
         return 300; //EventSetTimer(60); break;
      case MINUTES_10:
         return 600; //EventSetTimer(60); break;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeInitFunction()
  {
   delete scraper;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TimerFunction()
  {
   scraper.UpdateFile(CUSTOM_FILE_NAME+".txt", MAX_TIME);
  }

//+------------------------------------------------------------------+
//|        CLASS TO RETRIEVE DATA FROM YAHOO FINANCE                 |
//+------------------------------------------------------------------+
class YahooScraper
  {
   string            symbol_read;

public:
                     YahooScraper(string symbolToRead);

   void              GetWebPage(int initTime, int endTime, string &resultStr);

   void              SaveFile(string filename, int initTime, int endTime);

   void              UpdateFile(string filename, int endTime);

   string            ProcessRow(string row);
   string            nZeros(int num);
  };
YahooScraper* scraper;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
YahooScraper::YahooScraper(string symbolToRead)
  {
   symbol_read = symbolToRead;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void YahooScraper::GetWebPage(int initTime,int endTime,string &resultStr)
  {
   resultStr = "";

   string cookie=NULL,headers;
   char   post[],result[];
   string domain = "https://query1.finance.yahoo.com";
   string url= domain + "/v7/finance/download/" + symbol_read + "?period1=" + IntegerToString(initTime) + "&period2=" + IntegerToString(endTime) + "&interval=1d&events=history";

//Print(url);

   ResetLastError();

   int res=WebRequest("GET",url,cookie,NULL,500,post,0,result,headers);
   if(res==-1)
     {
      Print("WebRequest Error. Error code  =",GetLastError());

      MessageBox("It is necessary to add the address '"+domain+"' to the list of allowed URLs in the 'Advisors' tab","Error",MB_ICONINFORMATION);

     }
   else
      if(res==200)
        {
         resultStr = CharArrayToString(result,0,WHOLE_ARRAY,CP_UTF8);
        }
      else
        {
         PrintFormat("Load page error '%s', code %d",url,res);

        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string YahooScraper::ProcessRow(string row)
  {
   string items[];
   StringSplit(row, ',', items);


   string date = items[0];

   StringReplace(date, "-", ".");

   string openS, highS, lowS, closeS;

   if(items[1]=="null")
     {
      openS = DoubleToString(0.0, 2);
      openS = nZeros(6-StringLen(openS)) + openS;

      highS = DoubleToString(0.0, 2);
      highS = nZeros(6-StringLen(highS)) + highS;

      lowS = DoubleToString(0.0, 2);
      lowS = nZeros(6-StringLen(lowS)) + lowS;

      closeS = DoubleToString(0.0, 2);
      closeS = nZeros(6-StringLen(closeS)) + closeS;
     }
   else
     {
      openS = DoubleToString(StringToDouble(items[1]), 2);
      openS = nZeros(6-StringLen(openS)) + openS;

      highS = DoubleToString(StringToDouble(items[2]), 2);
      highS = nZeros(6-StringLen(highS)) + highS;

      lowS = DoubleToString(StringToDouble(items[3]), 2);
      lowS = nZeros(6-StringLen(lowS)) + lowS;

      closeS = DoubleToString(StringToDouble(items[4]), 2);
      closeS = nZeros(6-StringLen(closeS)) + closeS;

     }

   return date + "," + openS + "," + lowS + "," + highS + ","+closeS;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void YahooScraper::SaveFile(string filename, int initTime, int endTime)
  {
   string tmpStr;
   GetWebPage(initTime, endTime, tmpStr);

   if(tmpStr == "")
      return;

   string queryRows[];
   StringSplit(tmpStr, '\n', queryRows);

   int requestSize = ArraySize(queryRows);

   int filehandle=FileOpen(filename,FILE_COMMON|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);


   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle, IntegerToString(requestSize-1));
      for(int i = 1; i<requestSize; i++)
        {
         string toWrite = ProcessRow(queryRows[i]);

         FileWrite(filehandle, toWrite);
        }
     }
   FileFlush(filehandle);
   FileClose(filehandle);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string YahooScraper::nZeros(int num)
  {
   string zeros = "";

   for(int z=0; z<num; z++)
     {
      zeros = zeros + "0";
     }
   return zeros;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void YahooScraper::UpdateFile(string filename,int endTime)
  {
//Abrir archivo anterior, initTime es el datetime de la ultima fila
   if(!FileIsExist(filename, FILE_COMMON))
     {
      SaveFile(filename, TIME_LIMIT, MAX_TIME);
      return;
     }

   int filehandle=FileOpen(filename,FILE_COMMON|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);


   if(filehandle!=INVALID_HANDLE)
     {
      FileSeek(filehandle, -ROW_BYTE_SIZE, SEEK_END);


      int str_size=FileReadInteger(filehandle,INT_VALUE);
      string str = FileReadString(filehandle,str_size);

      string items[];
      StringSplit(str, ',', items);

      int initTime = (int)StringToTime(items[0]);

      string tmpStr;

      //Pagina web
      GetWebPage(initTime, endTime, tmpStr);

      string queryRows[];
      StringSplit(tmpStr, '\n', queryRows);

      int requestSize = ArraySize(queryRows);

      if(requestSize>=2 && queryRows[requestSize-1]==queryRows[requestSize-2])  //Prevent repeated values from weekends
        {
         requestSize--;
        }

      //Reescribir inicio
      FileSeek(filehandle, 0, SEEK_SET);

      str_size=FileReadInteger(filehandle,INT_VALUE);
      str = FileReadString(filehandle,str_size);

      int lastRows = (int)StringToInteger(str);

      FileSeek(filehandle, 0, SEEK_SET);


      FileWriteString(filehandle, IntegerToString(lastRows + requestSize - 2)+" ");

      //Reescribir filas
      FileSeek(filehandle, -ROW_BYTE_SIZE, SEEK_END);
      for(int i = 1; i<requestSize; i++)
        {
         string toWrite = ProcessRow(queryRows[i]);

         FileWrite(filehandle, toWrite);
        }
     }
   FileFlush(filehandle);
   FileClose(filehandle);
  }
//+------------------------------------------------------------------+
