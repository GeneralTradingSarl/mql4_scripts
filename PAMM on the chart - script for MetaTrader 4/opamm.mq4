//+------------------------------------------------------------------+
//|                                               opamm_manbeast.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                           ic.icreator@gmail.com (для спам ботов) |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "0.10"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TF 
  {
   H1 = PERIOD_H1,// H1 (нужно указать дату)
   D1 = PERIOD_D1 // D1 (вся история)
  };

input int pamm = 331296; // Номер ПАММ-счета
input TF timeframe = D1; // ТФ
input datetime dateStart=0; // Начальная дата
input datetime dateEnd=0; // Конечная дата

#import "user32.dll"
int PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int GetAncestor(int hWnd,int gaFlags);
int GetLastActivePopup(int hWnd);
int GetDlgItem(int hDlg,int nIDDlgItem);
#import

#import "kernel32.dll"
int FindFirstFileW(string Path,ushort &Answer[]);
bool FindNextFileW(int handle,ushort &Answer[]);
bool FindClose(int handle);
int DeleteFileW(string file);
#import

#define WM_COMMAND 0x0111
#define WM_KEYDOWN 0x0100
#define VK_DOWN 0x28
#define BM_CLICK 0x00F5
#define GA_ROOT 2
#define PAUSE 100
#define BASE 100.0
#define STD_OTMAZA "Не то чтобы что-то пошло не так, но что-то не работает."

string pammStr;
string tfStr;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart() 
  {
   bool isOk=true;
   string headers;
   char post[],result[];
   int timeout=3000;
   int time;
   double open,low,high,close,volume=1;
   int hwnd=0,cnt=0;
   int unused[13];
   pammStr=IntegerToString(pamm);
   tfStr=IntegerToString(timeframe);
   string name=pammStr+tfStr+".hst";
   if(GetChartPos(pammStr+"1440.hst")>-1)
      DeleteFileW(TerminalInfoString(TERMINAL_DATA_PATH)+"\\history\\"+AccountInfoString(ACCOUNT_SERVER)+"\\"+pammStr+"1440.hst");
   if(GetChartPos(pammStr+"60.hst")>-1)
      DeleteFileW(TerminalInfoString(TERMINAL_DATA_PATH)+"\\history\\"+AccountInfoString(ACCOUNT_SERVER)+"\\"+pammStr+"60.hst");
   int handle=FileOpenHistory(name,FILE_BIN|FILE_WRITE);
   if(handle<0) 
     {
      Print(STD_OTMAZA);
      return;
     }
   FileWriteInteger(handle,400,LONG_VALUE);
   FileWriteString(handle,"(C)opyright 2003, MetaQuotes Software Corp.",64);
   FileWriteString(handle,pammStr,12);
   FileWriteInteger(handle,timeframe,LONG_VALUE);
   FileWriteInteger(handle,_Digits,LONG_VALUE);
   FileWriteInteger(handle,0,LONG_VALUE);
   FileWriteInteger(handle,0,LONG_VALUE);
   FileWriteArray(handle,unused,0,13);

   int res=WebRequest("GET",getURL(timeframe),NULL,NULL,timeout,post,0,result,headers);
   if(res==-1) 
     {
      MessageBox("К сожалению, данный ресурс недоступен на территории РФ.","Ресурс заблокирован",MB_ICONERROR);
      isOk=false;
        } else {
      //PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));

      string data= CharArrayToString(result);
      string str = "";
      int prev=0;
      int n=StringFind(data,"\n");
      string items[];
      while(n>0) 
        {
         str=StringSubstr(data,prev,n-prev);
         StringSplit(str,';',items);
         if(ArraySize(items)<10) 
           {
            Alert("Кажется, период слишком большой.");
            isOk=false;
            break;
           }
         StringReplace(items[0],"-",".");
         if(timeframe == D1)
            items[0] = items[0] + " 00:00";
         time=(int) StringToTime(items[0]);
         open= BASE+StringToDouble(items[1]);
         low = BASE+StringToDouble(items[2]);
         high= BASE+StringToDouble(items[3]);
         close=BASE+StringToDouble(items[4]);

         FileWriteInteger(handle,time,LONG_VALUE);
         FileWriteDouble(handle,open,DOUBLE_VALUE);
         FileWriteDouble(handle,low,DOUBLE_VALUE);
         FileWriteDouble(handle,high,DOUBLE_VALUE);
         FileWriteDouble(handle,close,DOUBLE_VALUE);
         FileWriteDouble(handle,1,DOUBLE_VALUE);
         FileFlush(handle);

         prev=n+1;
         n=StringFind(data,"\n",prev);
        }
      FileClose(handle);
     }
   if(isOk) 
     {
      int p=GetChartPos(name);
      if(p>-1) 
        {
         OpenOfflineChartbyNum(p);
           } else {
         MessageBox("График не найден.","Ошибка",MB_ICONINFORMATION);
        }
     }
  }
// Возвращает адрес для скачивания
string getURL(int tf) 
  {
   MqlDateTime dtS,dtE;
   string date;

   TimeToStruct(dateStart,dtS);
   TimeToStruct(dateEnd,dtE);

   date=StringFormat("?start=%02i-%02i-%02i&end=%02i-%02i-%02i",
                     dtS.year,
                     dtS.mon,
                     dtS.day,
                     dtE.year,
                     dtE.mon,
                     dtE.day);

   switch(tf) 
     {
      case H1: return "http://www.alpari.ru/ru/investor/pamm/" + pammStr + "/monitoring/hourly_all_candle.csv" + date;
      default:
         case D1: return "http://www.alpari.ru/ru/investor/pamm/" + pammStr + "/monitoring/daily_all_candle.csv";
     }
  }
// Возвращает позицию графика в списке.
int GetChartPos(string FileName) 
  {
   ushort Buffer[300];
   int Pos=-1;
   string path= TerminalInfoString(TERMINAL_DATA_PATH) + "\\history\\" + AccountInfoString(ACCOUNT_SERVER) + "\\*.hst";
   int handle = FindFirstFileW(path, Buffer);
   string name= ShortArrayToString(Buffer,22,152);
   Pos++;
   if(name!=FileName) 
     {
      ArrayInitialize(Buffer,0);
      while(FindNextFileW(handle,Buffer))
        {
         name=ShortArrayToString(Buffer,22,152);
         Pos++;
         if(name==FileName) 
           {
            break;
           }
         ArrayInitialize(Buffer,0);
        }
     }

   if(handle>0)
      FindClose(handle);

   return(Pos);
  }
// Открывает список Offline-графиков. Возвращает хэндл окна списка.
int OpenOfflineList() 
  {
   int hwnd=WindowHandle(Symbol(),Period());

   hwnd=GetAncestor(hwnd,GA_ROOT);

   PostMessageA(hwnd,WM_COMMAND,33053,0);
   Sleep(PAUSE);

   hwnd=GetLastActivePopup(hwnd);

   return(hwnd);
  }
// Открывает Offline-график по номеру в списке.
void OpenOfflineChartbyNum(int ChartPos) 
  {
   int hwnd1 = OpenOfflineList();
   int hwnd2 = GetDlgItem(hwnd1, 1);

   hwnd1=GetDlgItem(hwnd1,0x487);

   while(ChartPos>=0) 
     {
      PostMessageA(hwnd1,WM_KEYDOWN,VK_DOWN,0);
      ChartPos--;
     }

   Sleep(PAUSE);

   PostMessageA(hwnd2,BM_CLICK,0,0);
  }
//+------------------------------------------------------------------+
