//+------------------------------------------------------------------+
//|        UploadExport.mq4  JHS©2008                                |
//+------------------------------------------------------------------+
#property copyright "JHS©2008"
#include <WinUser32.mqh>
//----
#import "TaskManager.dll"
     void   Load_TM(string dc,bool Demo);
     void   Save_TM();
   string   Version_TM();
     bool   MainWND_TM(int wnd);
     void   Show_TM();
     void   Close_TM();
      int   Sleep_TM(int milliseconds,int dt);
     void   AddSymbol_TM(string Name);
     void   AddPeriod_TM(string Name);
   string   TaskName_TM();
   string   Symbol_TM();
      int   Period_TM();
      int   FromDate_TM();
     bool   IncludeBar_TM();
   string   ExportDir_TM();
     bool   Export_TM();
     bool   LackHistory_TM();
     bool   AllHistory_TM();
      int   FileCreate_TM(string FileName);
     void   FileClose_TM(int FileHandle);
      int   FileWriteLn_TM(int FileHandle,string str);
   string   FileReadLn_TM(int FileHandle);
     void   NOP_TM();
     bool   Stopped_TM();
     void   Stop_TM(bool St);
     void   AddMenu_TM(int ID,string Caption);
     void   OnFile_TM(string FileName,int FromDT,int ToDT);
     void   OnExported_TM();
   string   Message_TM();
//----   
#import
#define DLL_VER               "136"
#define IND_VER               "132"
#define ACTION_NONE           0
#define ACTION_EXPORT         1
#define ACTION_CLOSE          2
#define ACTION_MESSAGE        3
#define ACTION_USER           8000
//Menu
//События
#define ACTION_MENU_QUIT      1000
//Пользовательские
#define ACTION_MENU_USER      9000//...9999
//глобальные переменные
string Symbols[];
int TimFram[9]={1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSymbol(string SymbolName)
  {
   int CountSymbols=ArrayRange(Symbols, 0);
   for(int i=0;i<CountSymbols;i++)
     {
      if(Symbols[i]==SymbolName) return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GenereteSymbolList()
  {//copyright "Шумахер"
       string Currencies[]={"AED", "AUD", "BHD", "BRL", "CAD", "CHF", "CNY",
                              "CYP", "CZK", "DKK", "DZD", "EEK", "EGP", "EUR",
                              "GBP", "HKD", "HRK", "HUF", "IDR", "ILS", "INR",
                              "IQD", "IRR", "ISK", "JOD", "JPY", "KRW", "KWD",
                              "LBP", "LTL", "LVL", "LYD", "MAD", "MXN", "MYR",
                              "NOK", "NZD", "OMR", "PHP", "PLN", "QAR", "RON",
                              "RUB", "SAR", "SEK", "SGD", "SKK", "SYP", "THB",
                              "TND", "TRY", "TWD", "USD", "VEB", "XAG", "XAU",
      "YER", "ZAR"};
   int Count=ArrayRange(Currencies, 0);
   int Loop, SubLoop;
   string TempSymbol;
   for(Loop=0; Loop < Count; Loop++)
      for(SubLoop=0; SubLoop < Count; SubLoop++)
        {
         TempSymbol=Currencies[Loop] + Currencies[SubLoop];
         if(MarketInfo(TempSymbol, MODE_BID) > 0)
           {
            if(CheckSymbol(TempSymbol))
              {
               ArrayResize(Symbols, ArraySize(Symbols)+1);
               Symbols[ArraySize(Symbols)-1]=TempSymbol;
              }
           }
        }
   //All
   string Another[]={"GOLD"  ,"_DJI" ,"_NQ100","_NQCOMP","_SP500","#HPQ"     ,"#IBM" ,"#INTC" ,"NQ"   ,"ZS"    ,
                       "#MSFT" ,"#QQQ" ,"#SPY"  ,"#T"     ,"#XOM"  ,"_DXY"     ,"_C"   ,"_S"    ,"_W"   ,"_QG"   ,
                       "_GC"   ,"_SI"  ,"_ES"   ,"_NQ"    ,"_QM"   ,"#DIA"     ,"#AA"  ,"#AIG"  ,"#AXP" ,"#BA"   ,
                       "#C"    ,"#CAT" ,"#DD"   ,"#DIS"   ,"#EK"   ,"#GE"      ,"#GM"  ,"#HD"   ,"#HON" ,"#IP"   ,
                       "#JNJ"  ,"#JPM" ,"#KO"   ,"#MCD"   ,"#MMM"  ,"#MO"      ,"#MRK" ,"#PFE"  ,"#PG"  ,"ZO"    ,
                       "#UTX"  ,"#VZ"  ,"#WMT"  ,"#CZ7"   ,"#WZ7"  ,"#SX7"     ,"#QMZ7","#QGX7" ,"#QGZ7","PB"    ,
                       "#ESZ7" ,"#NQZ7","#GCZ7" ,"#SIZ7"  ,"#SF8"  ,"#QMF8"    ,"#QGF8","XAU"   ,"ER2"  ,"LC"    ,
                       "6A"    ,"6B"   ,"6C"    ,"6E"     ,"6J"    ,"6S"       ,"DX"   ,"RF"    ,"RY"   ,"ES"    ,
                       "YM"    ,"FTSE" ,"FDAX"  ,"NKD"    ,"FESX"  ,"NI225_M"  ,"NI300","NI225" ,"QM"   ,"LH"    ,
                       "QG"    ,"CL"   ,"BRN"   ,"WTI"    ,"NG"    ,"HO"       ,"THU"  ,"THO"   ,"ZW"   ,"ZC"    ,
                       "ZL"    ,"ZM"   ,"KE"    ,"KW"     ,"RB"    ,"CO"       ,"YC"   ,"YW"    ,"YK"   ,"FC"    ,
                       "ZG"    ,"ZI"   ,"GC"    ,"SI"     ,"HG"    ,"PA"       ,"PL"   ,"YG"    ,"YI"   ,"LB"    ,
                       "JO"    ,"D"    ,"C"     ,"W"      ,"SB"    ,"SG"       ,"TRB"  ,"FGBL"  ,"FGBM" ,"FGBS"  ,
                       "SAEPI" ,"SADS" ,"SALB"  ,"SAMAG"  ,"SALTH" ,"SAVP"     ,"SAXR" ,"SBA"   ,"SBAB" ,"CT"    ,
                       "SBAC"  ,"SBIDU","SBOT"  ,"SBRCD"  ,"SCAL"  ,"SCOH"     ,"SCROX","SCSCO" ,"SCPA" ,"KC"    ,
                       "SCRAY" ,"SCSH" ,"SCS"   ,"SCTSH"  ,"SCVX"  ,"SDAKT"    ,"SDIVX","SICOC" ,"SIIG" ,"SAAPL" ,
                       "SINFY" ,"SGES" ,"SGM"   ,"SGD"    ,"SGLDN" ,"SGOOG"    ,"SGROW","SGS"   ,"SGT"  ,"SHPQ"  ,
                       "SJSDA" ,"SLMT" ,"SLVS"  ,"SMA"    ,"SMS"   ,"SMSFT"    ,"SNDAQ","SNENG" ,"SNTRI","CC"    ,
                       "SNVDA" ,"SNYX" ,"SWW"   ,"SSNP"   ,"SRIMM" ,"SPOT"     ,"SWBD" ,"SQQQQ" ,"SSOFO","SARO"  ,
                       "STXI"  ,"STM"  ,"STRA"  ,"SXOM"   ,"SGE"   ,"SMMM"     ,"SAA"  ,"SMO"   ,"SAIG" ,"SAXP"  ,
                       "ST"    ,"SCAT" ,"SC"    ,"SKO"    ,"SDIS"  ,"SDD"      ,"SHD"  ,"SHON"  ,"SIBM" ,"SINTC" ,
                       "SJNJ"  ,"SJPM" ,"SMCD"  ,"SMRK"   ,"SPFE"  ,"SPG"      ,"SUTX" ,"SVZ"   ,"SWMT" ,"STATTF",
                       "SATI"  ,"SALGT","SAB"   ,"SAEOS"  ,"SAOB"  ,"SHRT"     ,"SALC" ,"SATNI" ,"SAVTR","SVCLK" ,
                       "SBT"   ,"SBWP" ,"SBWS"  ,"SCBG"   ,"SCHINA","SKMX"     ,"SCELG","SCHAP" ,"SRIO" ,
                       "SBAP"  ,"SCUTR","SCYNO" ,"SDECK"  ,"SDLB"  ,"SDLLR"    ,"SEZPW","SFMCN" ,"SFTEK",
                       "SGSOL" ,"SGEF" ,"SHMSY" ,"SHPC"   ,"SHLT"  ,"SHMIN"    ,"SHXM" ,"SICON" ,"SBLUD",
                       "SIMKTA","SICE" ,"SIGLD" ,"SJST"   ,"SKCI"  ,"SLHCG"    ,"SLFL" ,"SMFW"  ,"SWFR" ,
                       "SMGM"  ,"SMIDD","SMICC" ,"SMBT"   ,"SNTGR" ,"SJWN"     ,"SPTNR","SPSPT" ,"SPRFT",
                       "SPHLY" ,"SPHI" ,"SPVH"  ,"SRL"    ,"SPCP"  ,"SPCLN"    ,"SSEIC","SSWS"  ,"SCRM" ,
                       "SSAY"  ,"S"    ,"SIMO"  ,"SSBGI"  ,"SPCU"  ,"SSTLD"    ,"SSF"  ,"SSYNT" ,"SSYX" ,
                       "STEF"  ,"STSTC","STPX"  ,"STS"    ,"STSRA" ,"SNCTY"    ,"STSS" ,"SX"    ,"SUSAP",
      "SVDSI" ,"SPAY" ,"SVIP"  ,"SVMC"   ,"SWEBX" ,"SAAPLtest","ZB"   ,"RC"    ,"GAS"  ,"AC"};
//----
   Count=ArrayRange(Another, 0);
   for(Loop=0; Loop < Count; Loop++)
     {
      TempSymbol=Another[Loop];
      if(MarketInfo(TempSymbol, MODE_BID) > 0)
        {
         if(CheckSymbol(TempSymbol))
           {
            ArrayResize(Symbols, ArraySize(Symbols)+1);
            Symbols[ArraySize(Symbols)-1]=TempSymbol;
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(!IsLibrariesAllowed())
     {
      Alert("Библиотечные вызовы запрещены. Скрипт не может выполняться.");
      return(0);
     }
   if(!IsDllsAllowed())
     {
      Alert("Вызовы из библиотек (DLL) запрещены. Скрипт не может выполняться.");
      return(0);
     }
   string DllVersion=Version_TM();DllVersion=StringSubstr(DllVersion,0,3);
   if(DllVersion!=DLL_VER)
     {
      Print("Uncompatible version: dll v."+DllVersion+" indiacator dll v."+DLL_VER);
      MessageBoxA(WindowHandle(Symbol(),Period()),"Несоответствие версии вызываемой dll и встроенного описания.","Ошибка",MB_OK+MB_ICONERROR);
      return(0);
     }else Print("Indiacator v."+IND_VER+", indiacator dll v."+DLL_VER+", dll v."+DllVersion);
   //Variables
   string CurrentSymbol,d,t,CurrentTask,FileName;
   int i,j,CurrentPeriod,barShift,FromBar,Handle,Refresh=0;
   datetime LimitDate,FromDT,ToDT;
   bool LackHistory,AllHistory,Export,Quit=false;
   //Init
   Load_TM(AccountCompany(),IsDemo());
   if(!MainWND_TM(WindowHandle(Symbol(),Period())))
     {
      Print("Обнаружен второй экзэмпляр скрипта. Данная функция не поддерживается.");
      MessageBoxA(WindowHandle(Symbol(),Period()),"Обнаружен второй экзэмпляр скрипта. Данная функция не поддерживается.","Ошибка",MB_OK+MB_ICONERROR);
      return(0);
     }
   GenereteSymbolList();
   for(i=0;i<ArrayRange(Symbols,0);i++) AddSymbol_TM(Symbols[i]);
   for(i=0;i<ArrayRange(TimFram,0);i++) AddPeriod_TM(TimFram[i]);
   //AddMenu_TM(ACTION_MENU_USER,"Всё круто");//Пример работы с меню, обработчик ниже
   while(!IsStopped() && !Quit)
     {
      switch(Sleep_TM(500,iTime(Symbol(),PERIOD_M1,0)))
        {
         case ACTION_NONE:
           {
            Refresh++;
            if(Refresh>60)//каждые 30 секунд
              {
               Refresh=0;
               RefreshRates();
              }
            break;
           }
         case ACTION_EXPORT:
           {
            CurrentTask=TaskName_TM();
            CurrentSymbol=Symbol_TM();
            if(StringLen(CurrentSymbol)==0) break;
            if(!IsConnected()) Print(CurrentTask," : Нет связи с сервером. Подкачка истории не выполняется.");
            while(StringLen(CurrentSymbol)>0 && !IsStopped())
              {
               CurrentPeriod=Period_TM();
               while(CurrentPeriod>0 && !IsStopped())
                 {
                  if(MarketInfo(CurrentSymbol,MODE_BID)>0)
                    {
                     LimitDate=FromDate_TM();

                     if(IncludeBar_TM())
                       {
                        FromBar=0;
                       }
                     else
                       {
                        FromBar=1;
                       }
                     AllHistory=AllHistory_TM();
                     if(AllHistory)
                       {
                        barShift=iBars(CurrentSymbol,CurrentPeriod);
                       }else
                       {
                        barShift=iBarShift(CurrentSymbol,CurrentPeriod,LimitDate,false);
                       }
                     LackHistory=LackHistory_TM();
                     if(LackHistory || (LimitDate>=iTime(CurrentSymbol,CurrentPeriod,barShift) && !LackHistory) || AllHistory)
                       {
                        //Upload
                        for(i=barShift;i>=FromBar && !IsStopped() && IsConnected();i--)
                          {
                           j=20;//1 секунда
                           while(iTime(CurrentSymbol,CurrentPeriod,i)==0 && j>0)
                             {
                              j--;
                              NOP_TM();
                              Sleep(50);
                             }
                          }
                        RefreshRates();
                        if(AllHistory) barShift=iBars(CurrentSymbol,CurrentPeriod);
                        //Export
                        FileName=ExportDir_TM()+AccountCompany()+"-"+CurrentSymbol+"-"+CurrentPeriod+".prn";
                        Export=Export_TM();
                        if(Export) Handle=FileCreate_TM(FileName);
                        if(Handle>=0 || !Export)
                          {
                           if(Export) FileWriteLn_TM(Handle,"<DTYYYYMMDD>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>");
                           FromDT=0;
                           for(i=barShift;i>=FromBar && !IsStopped();i--)
                             {
                              if(iTime(CurrentSymbol,CurrentPeriod,i)==0 || (LimitDate>iTime(CurrentSymbol,CurrentPeriod,i) && !AllHistory))
                                {
                                 continue;
                                }
                              ToDT=iTime(CurrentSymbol,CurrentPeriod,i);
                              if(FromDT==0) FromDT=ToDT;
                              if(!Export)
                                {
                                 NOP_TM();
                                 continue;//на всякий случай проверяем чтобы найти реальный ToDT
                                }
                              d=TimeToStr(ToDT,TIME_DATE);
                              d=StringSubstr(d,0,4)+StringSubstr(d,5,2)+StringSubstr(d,8,2);
                              t=TimeToStr(ToDT,TIME_SECONDS);
                              t=StringSubstr(t,0,2)+StringSubstr(t,3,2)+StringSubstr(t,6,2);
                              FileWriteLn_TM(Handle,StringConcatenate(d,",",t,",",
                                 iOpen  (CurrentSymbol,CurrentPeriod,i),",",
                                 iHigh  (CurrentSymbol,CurrentPeriod,i),",",
                                 iLow   (CurrentSymbol,CurrentPeriod,i),",",
                                 iClose (CurrentSymbol,CurrentPeriod,i),",",
                                 iVolume(CurrentSymbol,CurrentPeriod,i)));
                             }
                           if(Export)
                             {
                              FileClose_TM(Handle);
                              Print(CurrentTask," : Выгрузка завершена: ",CurrentSymbol," - ",CurrentPeriod);
                             }else
                             {
                              Print(CurrentTask," : Данные переданы: ",CurrentSymbol," - ",CurrentPeriod);
                             }
                           OnFile_TM(FileName,FromDT,ToDT);
                          }
                        else Print(CurrentTask," : Невозможно записать: ",FileName);
                       }
                     else if(!LackHistory) Print(CurrentTask," : Недостаточно истории: ",CurrentSymbol," - ",CurrentPeriod);
                    }
                  else Print(CurrentTask," : Нет такого инструмента: ",CurrentSymbol);
                  CurrentPeriod=Period_TM();
                 }//while(CurrentPeriod>0)
               CurrentSymbol=Symbol_TM();
              }//while(StringLen(CurrentSymbol)>0)
            Print(CurrentTask," : Экспорт завершон");
            OnExported_TM();
            break;
           }//ACTION_EXPORT
         case ACTION_CLOSE:
           {
            Close_TM();
            break;
           }//ACTION_CLOSE
         case ACTION_MENU_QUIT:
           {
            Quit=true;
            break;
           }//ACTION_MENU_QUIT         
         case ACTION_MESSAGE:
           {
            Print(Message_TM());
            break;
           }//ACTION_MENU_QUIT
         case ACTION_MESSAGE:
           {//Пример работы с меню, добавление пункта меню выше
            MessageBoxA(WindowHandle(Symbol(),Period()),"Всё круто","Тест",MB_OK);
            break;
           }//ACTION_MENU_USER         
        }//switch
     }
   Close_TM();//обязательно, на случай если открыта форма
   Save_TM();//сохраняем настройки
   Print("Скрипт завершил работу.");
  }
//+------------------------------------------------------------------+