//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Creation of FXT-file for MT4 strategy tester from the data file of the real ticks stream. Description is available on the website AdvanceTools.net.\nRussian: Создание FXT-файла для тестера стратегий МТ4 из файла данных о реальном тиковом потоке. Описание доступно на сайте AdvanceTools.net."
#property version   "1.00"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CHART_TYPE
  {
   CHART_TYPE_TIME,                                                                                // Same time / Равновременной
   CHART_TYPE_CANDLE,                                                                              // Range / Равновысокий
   CHART_TYPE_VOLUME                                                                               // Equivolume / Эквиобъемный
  };
input datetime          i_startDate       = D'2014.05.28 00:00:00';                                // Start date-time / Начальная дата-время
input datetime          i_endDate         = D'2015.05.01 00:00:00';                                // Finish date-time / Конечная дата-время
input uint              i_minPreviousBars = 1000;                                                  // The number of bars before testing / Баров до начала теста
input uint              i_spread          = 0;                                                     // Spread, pts. / Спред, пп.
input ENUM_CHART_TYPE   i_chartType       = CHART_TYPE_TIME;                                       // The type of chart / Тип графика
input uint              i_chartPeriod     = 480;                                                   // Period (sec., pts., ticks) / Период (сек., пп., тики)
//---
string                  g_ticksFileName;
ENUM_TIMEFRAMES         g_tf;
int                     g_startPrevBar,g_endPrevBar;
double                  g_point;
//---
#import "kernel32.dll"
bool CopyFileW(string sourceFileName,string destinationFileName,bool bFailIfExists);
uint GetFileAttributesW(string fileName);
bool SetFileAttributesW(string fileName,int newAttributes);
#import                        
#define  INVALID_FILE_ATTRIBUTES                   UINT_MAX                                        // Error getting the file attributes
#define  FILE_ATTRIBUTE_READONLY                       0x01                                        // "Read Only"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TestHistoryHeader
  {
   int               version;            // 405
   char              copyright[64];      // copyright
   char              description[128];   // server name
                                         // 196
   char              symbol[12];
   int               period;
   int               model;              // for what modeling type was the ticks sequence generated
   int               bars;               // amount of bars in history
   int               fromdate;
   int               todate;
   int               totalTicks;
   double            modelquality;       // modeling quality
                                         // 240
   //---- general parameters
   char              currency[12];       // currency base
   int               spread;
   int               digits;
   int               unknown1;
   double            point;
   int               lot_min;            // minimum lot size
   int               lot_max;            // maximum lot size
   int               lot_step;
   int               stops_level;        // stops level value
   int               gtc_pendings;       // instruction to close pending orders at the end of day
                                         // 292
   //---- profit calculation parameters
   int               unknown2;
   double            contract_size;      // contract size
   double            tick_value;         // value of one tick
   double            tick_size;          // size of one tick
   int               profit_mode;        // profit calculation mode        { PROFIT_CALC_FOREX, PROFIT_CALC_CFD, PROFIT_CALC_FUTURES }
                                         // 324 
   //---- swap calculation
   int               swap_enable;        // enable swap
   int               swap_type;          // type of swap                   { SWAP_BY_POINTS, SWAP_BY_DOLLARS, SWAP_BY_INTEREST }
   int               unknown3;
   double            swap_long;
   double            swap_short;         // swap overnight value
   int               swap_rollover3days; // three-days swap rollover
                                         // 356   
   //---- margin calculation
   int               leverage;           // leverage
   int               free_margin_mode;   // free margin calculation mode   { MARGIN_DONT_USE, MARGIN_USE_ALL, MARGIN_USE_PROFIT, MARGIN_USE_LOSS }
   int               margin_mode;        // margin calculation mode        { MARGIN_CALC_FOREX,MARGIN_CALC_CFD,MARGIN_CALC_FUTURES,MARGIN_CALC_CFDINDEX };
   int               margin_stopout;     // margin stopout level
   int               margin_stopout_mode;// stop out check mode            { MARGIN_TYPE_PERCENT, MARGIN_TYPE_CURRENCY }
   double            margin_initial;     // margin requirements
   double            margin_maintenance; // margin maintenance requirements
   double            margin_hedged;      // margin requirements for hedged positions
   double            margin_divider;     // margin divider
   char              margin_currency[12];// margin currency
                                         // 420   
   //---- commission calculation
   double            comm_base;          // basic commission
   int               comm_type;          // basic commission type          { COMM_TYPE_MONEY, COMM_TYPE_PIPS, COMM_TYPE_PERCENT }
   int               comm_lots;          // commission per lot or per deal { COMMISSION_PER_LOT, COMMISSION_PER_DEAL }
                                         // 436   
   //---- for internal use
   int               from_bar;           // fromdate bar number
   int               to_bar;             // todate bar number
   int               start_period[6];    // number of bar at which the smaller period modeling started
   int               set_from;           // begin date from tester settings
   int               set_to;             // end date from tester settings
                                         // 476
   //----
   int               end_of_test;
   int               freeze_level;       // order's freeze level in points
   int               generating_errors;
   // 488   
   //----
   int               reserved[60];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TestHistory
  {
   datetime          otm;                // open time of bar
   double            open;               // OHLCV
   double            high;
   double            low;
   double            close;
   long              volume;
   int               ctm;                // current time inside the bar
   int               flag;               // flag of expert execution (0 - We modify the bar, and the expert is not run)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TickStruct
  {
   datetime          time;
   double            bid;
   double            ask;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MESSAGE_CODE
  {
   MESSAGE_CODE_POINT_EQUAL_TO_ZERO,
   MESSAGE_CODE_COMPLETE,
   MESSAGE_CODE_TERMINAL_FATAL_ERROR1,
   MESSAGE_CODE_DLL_ERROR,
   MESSAGE_CODE_INVALID_TEST_DATA,
   MESSAGE_CODE_HISTORY_ABSENT,
   MESSAGE_CODE_SEEK_FILE_ERROR,
   MESSAGE_CODE_TICKS_FILE,
   MESSAGE_CODE_HAS_DATA,
   MESSAGE_CODE_TO_DATE,
   MESSAGE_CODE_NOT_CORRESPONDING,
   MESSAGE_CODE_ERRORN,
   MESSAGE_CODE_FILE_OPEN,
   MESSAGE_CODE_SCRIPT_IS_OFF,
   MESSAGE_CODE_READ_TICKS_FILE_ERROR,
   MESSAGE_CODE_SEEK_FILE_ERROR2,
   MESSAGE_CODE_HEADER_FILE_ERROR,
   MESSAGE_CODE_PRECEDING_HISTORY_ERROR,
   MESSAGE_CODE_FILE_CREATE_ERROR,
   MESSAGE_CODE_TICKS_WRITE_ERROR,
   MESSAGE_CODE_FEW_BARS,
   MESSAGE_CODE_COPY_ERROR,
   MESSAGE_CODE_READ_ONLY_REMOVE_ERROR,
   MESSAGE_CODE_ATTRIBUTE_GETTING_ERROR,
   MESSAGE_CODE_READ_ONLY_SET_ERROR,
   MESSAGE_CODE_BIND_ERROR
  };
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Script program start function                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnStart()
  {
   g_tf=(ENUM_TIMEFRAMES)Period();
//---
   if(!IsParametersCorrect())
      return;
//---
   if(!CreateFXTFile())
      return;
//---
   if(!CopyFXTFileToTesterFolder())
      return;
//---
   Alert(GetStringByMessageCode(MESSAGE_CODE_COMPLETE));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of values of tuning parameters                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsParametersCorrect()
  {
   string name=WindowExpertName();
//---
   g_point=Point();
   if(g_point<=0.0)
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_POINT_EQUAL_TO_ZERO));
      return false;
     }
//---
   if(i_chartPeriod==0)
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_TERMINAL_FATAL_ERROR1));
      return false;
     }
//---
   if(!IsDllsAllowed())
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_DLL_ERROR));
      return false;
     }
//---
   if(i_startDate>=i_endDate)
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_INVALID_TEST_DATA));
      return false;
     }
//---
   if(!IsPreviousHistoryEnough())
     {
      Alert(name,GetStringByMessageCode(MESSAGE_CODE_HISTORY_ABSENT));
      return false;
     }
//---
   if(!IsTicksDataEnough())
      return false;
//---
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Is there enough of history until the date of the start date of the testing?                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsPreviousHistoryEnough()
  {
   g_endPrevBar=iBarShift(_Symbol,g_tf,i_startDate);
   int total=iBars(_Symbol,g_tf);
   while(iTime(_Symbol,g_tf,g_endPrevBar)>=i_startDate && g_endPrevBar<total)
      g_endPrevBar++;
//---
   g_startPrevBar=g_endPrevBar+(int)i_minPreviousBars-1;
//---
   return g_startPrevBar < total;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Is there a ticks history, corresponding to a given interval of testing?                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTicksDataEnough()
  {
   int handle;
   g_ticksFileName=_Symbol+".tks";
   if(!IsFileOpen(g_ticksFileName,handle))
      return false;
//---
   TickStruct tickStart,tickEnd;
   if(!IsFileRead(handle,tickStart))
      return false;
//---
   if(!FileSeek(handle,-sizeof(TickStruct),SEEK_END))
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_SEEK_FILE_ERROR));
      FileClose(handle);
      return false;
     }
//---
   if(!IsFileRead(handle,tickEnd))
      return false;
//---
   FileClose(handle);
//---
   if(tickStart.time<=i_startDate && tickEnd.time>=i_endDate)
      return true;
//---
   Alert(GetStringByMessageCode(MESSAGE_CODE_NOT_CORRESPONDING));
   Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_TICKS_FILE),g_ticksFileName,GetStringByMessageCode(MESSAGE_CODE_HAS_DATA),tickStart.time,
         GetStringByMessageCode(MESSAGE_CODE_TO_DATE),tickEnd.time,",");
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Opens a file with the specified name, and returns a file descriptor                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFileOpen(string fileName,int &fileHandle)
  {
   fileHandle=FileOpen(fileName,FILE_READ|FILE_SHARE_READ|FILE_BIN);
   if(fileHandle<=0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_ERRORN),GetLastError(),GetStringByMessageCode(MESSAGE_CODE_FILE_OPEN),fileName,GetStringByMessageCode(MESSAGE_CODE_SCRIPT_IS_OFF));
      return false;
     }
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Reading the ticks file with error handling                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFileRead(int handle,TickStruct &tick)
  {
   if(FileReadStruct(handle,tick)==0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_READ_TICKS_FILE_ERROR));
      FileClose(handle);
      return false;
     }
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Создание FXT-файла                                                                                                                                                                                |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool CreateFXTFile()
  {
   int fxtFileHandle;
   if(!IsEmptyHeaderWrite(fxtFileHandle))
      return false;
//---
   if(!IsPreviousHistoryWrite(fxtFileHandle))
      return false;
//---
   int savedBarsCnt=g_startPrevBar-g_endPrevBar+1;
   int savedTicksCnt=savedBarsCnt;
   datetime startTickDateTime=0,lastTickDateTime=0;
   if(!IsHistoryDataWrite(fxtFileHandle,savedBarsCnt,savedTicksCnt,startTickDateTime,lastTickDateTime))
      return false;
//---
   if(!FileSeek(fxtFileHandle,0,SEEK_SET))
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_SEEK_FILE_ERROR2));
      FileClose(fxtFileHandle);
      return false;
     }
//---
   bool result=IsHeaderWrite(fxtFileHandle,savedBarsCnt,savedTicksCnt,startTickDateTime,lastTickDateTime);
   FileClose(fxtFileHandle);
//---
   return result;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Forming the empty header of the FXT-file                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsEmptyHeaderWrite(int &fxtFileHandle)
  {
   if(!IsFileCreate(GetFXTFileName(),fxtFileHandle))
      return false;
//---
   TestHistoryHeader testerHeader;
   return IsReadyHeaderWrite(fxtFileHandle, testerHeader);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Generates the FXT-file name                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetFXTFileName()
  {
   return _Symbol + IntegerToString((int)g_tf) + "_0.fxt";
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Saving the header of FXT-file                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadyHeaderWrite(int fxtFileHandle,TestHistoryHeader &testerHeader)
  {
   if(FileWriteStruct(fxtFileHandle,testerHeader)==sizeof(TestHistoryHeader))
      return true;
//---
   Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HEADER_FILE_ERROR));
   FileClose(fxtFileHandle);
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Formation and recording the history, preceding the said date of commencement of testing                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsPreviousHistoryWrite(int fxtFileHandle)
  {
   TestHistory testHistory={0,0,0,0,0,0,0};
   int size=sizeof(testHistory);
   for(int i=g_startPrevBar; i>=g_endPrevBar; i--)
     {
      testHistory.otm=iTime(_Symbol,g_tf,i);
      testHistory.open = iOpen(_Symbol, g_tf, i);
      testHistory.high = iHigh(_Symbol, g_tf, i);
      testHistory.low=iLow(_Symbol,g_tf,i);
      testHistory.close=iClose(_Symbol,g_tf,i);
      testHistory.volume=iVolume(_Symbol,g_tf,i);
      testHistory.ctm=(int)testHistory.otm;
      if(FileWriteStruct(fxtFileHandle,testHistory)!=size)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_PRECEDING_HISTORY_ERROR));
         FileClose(fxtFileHandle);
         return false;
        }
     }
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Creates a file with the specified name, and returns a file descriptor                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFileCreate(string fileName,int &fileHandle)
  {
   fileHandle=FileOpen(fileName,FILE_WRITE|FILE_SHARE_WRITE|FILE_BIN|FILE_ANSI);
   if(fileHandle<=0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_ERRORN),GetLastError(),GetStringByMessageCode(MESSAGE_CODE_FILE_CREATE_ERROR));
      return false;
     }
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Writing data into FXT-file from the initial to the end date of the interval testing                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsHistoryDataWrite(int fxtFileHandle,int &savedBarsCnt,int &savedTicksCnt,datetime &startTickDateTime,datetime &lastTickDateTime)
  {
   int handle;
   if(!IsFileOpen(g_ticksFileName,handle))
     {
      FileClose(fxtFileHandle);
      return false;
     }
// The first tick search
   TickStruct tick={0,0,0};
   while(tick.time<i_startDate && !FileIsEnding(handle))
     {
      if(!IsFileRead(handle,tick))
        {
         FileClose(fxtFileHandle);
         return false;
        }
     }
   startTickDateTime=tick.time;
// Save the ticks in FXT-file
   TestHistory testerHistory={0,0,0,0,0,0,0,0};
   while(tick.time<=i_endDate && !FileIsEnding(handle))
     {
      if(!IsSaveTickToFXT(fxtFileHandle,tick,testerHistory,savedBarsCnt,savedTicksCnt))
        {
         FileClose(handle);
         return false;
        }
      lastTickDateTime=tick.time;
      //---
      if(!IsFileRead(handle,tick))
        {
         FileClose(fxtFileHandle);
         return false;
        }
     }
   FileClose(handle);
//---
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Saves the specified tick into FXT-file                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSaveTickToFXT(int fxtFileHandle,TickStruct &tick,TestHistory &testerHistory,int &savedBarsCnt,int &savedTicksCnt)
  {
   testerHistory.close=tick.bid;
   testerHistory.ctm=(int)tick.time;
// Formation of new bar
   if(testerHistory.volume==0 || IsNewBar(tick,testerHistory))
     {
      testerHistory.otm=tick.time;
      testerHistory.open = tick.bid;
      testerHistory.high = tick.bid;
      testerHistory.low=tick.bid;
      testerHistory.volume=1;
      testerHistory.flag=1;
      savedBarsCnt++;
     }
   else
// Continued the formation of the previous bar
     {
      testerHistory.high= MathMax(testerHistory.high,tick.bid);
      testerHistory.low = MathMin(testerHistory.low,tick.bid);
      testerHistory.volume++;
     }
// Writing the data
   if(FileWriteStruct(fxtFileHandle,testerHistory)==0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_TICKS_WRITE_ERROR));
      FileClose(fxtFileHandle);
      return false;
     }
   savedTicksCnt++;
//---
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Is the new bar appear?                                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsNewBar(TickStruct &tick,const TestHistory &testerHistory)
  {
   switch(i_chartType)
     {
      case CHART_TYPE_TIME:   if(tick.time<testerHistory.otm+i_chartPeriod)
         return false;
         //---
         tick.time=(tick.time/i_chartPeriod)*i_chartPeriod;
         return true;
         //---
      case CHART_TYPE_CANDLE: return ((uint)MathRound((MathMax(testerHistory.high, tick.bid) - MathMin(testerHistory.low, tick.bid)) / g_point) > i_chartPeriod);
      //---
      case CHART_TYPE_VOLUME: return testerHistory.volume >= i_chartPeriod;
     }
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Formation of FXT-file header                                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsHeaderWrite(int fxtFileHandle,int savedBarsCnt,int savedTicksCnt,datetime startTickDateTime,datetime lastTickDateTime)
  {
   if(savedBarsCnt<101)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_FEW_BARS));
      return false;
     }
   TestHistoryHeader testerHeader;
   CreateHeader(testerHeader,savedBarsCnt,savedTicksCnt,startTickDateTime,lastTickDateTime);
//---
   return IsReadyHeaderWrite(fxtFileHandle, testerHeader);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Filling in the structure of the file header                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CreateHeader(TestHistoryHeader &testerHeader,int savedBarsCnt,int savedTicksCnt,datetime startTickDateTime,datetime lastTickDateTime)
  {
   testerHeader.version=405;
   string copyright="Copyright 2001-2014, MetaQuotes Software Corp.";
   ArrayInitialize(testerHeader.copyright,0);
   StringToCharArray(copyright,testerHeader.copyright);
   string description=AccountInfoString(ACCOUNT_SERVER);
   ArrayInitialize(testerHeader.description,0);
   StringToCharArray(description,testerHeader.description);
//---
   ArrayInitialize(testerHeader.symbol,0);
   StringToCharArray(_Symbol,testerHeader.symbol);
   testerHeader.period= g_tf;
   testerHeader.model = 0;
   testerHeader.bars=savedBarsCnt;
   testerHeader.fromdate=(int)startTickDateTime;
   testerHeader.todate=(int)lastTickDateTime;
   testerHeader.modelquality=100.0;
   testerHeader.totalTicks=0;
//---
   ArrayInitialize(testerHeader.currency,0);
   StringToCharArray(SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT),testerHeader.currency);
   testerHeader.spread = (int)i_spread;
   testerHeader.digits = _Digits;
   testerHeader.unknown1=0;
   testerHeader.point=_Point;
   testerHeader.lot_min = (int)(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN) * 100);
   testerHeader.lot_max = (int)(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX) * 100);
   testerHeader.lot_step=(int)(SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP) * 100);
   testerHeader.stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   testerHeader.gtc_pendings=1;
//---
   testerHeader.unknown2=0;
   testerHeader.contract_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
   testerHeader.tick_value= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   testerHeader.tick_size = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   testerHeader.profit_mode=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE);
//---
   testerHeader.swap_enable=1;
   testerHeader.swap_type=(int)SymbolInfoInteger(_Symbol,SYMBOL_SWAP_MODE);
   testerHeader.unknown3 = 0;
   testerHeader.swap_long= SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG);
   testerHeader.swap_short=SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT);
   testerHeader.swap_rollover3days=(int)SymbolInfoInteger(_Symbol,SYMBOL_SWAP_ROLLOVER3DAYS);
//---
   testerHeader.leverage=(int)AccountInfoInteger(ACCOUNT_LEVERAGE);
   testerHeader.free_margin_mode=1;
   testerHeader.margin_mode=0;
   testerHeader.margin_stopout=(int)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   testerHeader.margin_stopout_mode=(int)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   testerHeader.margin_initial=SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_INITIAL);
   testerHeader.margin_maintenance=SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_MAINTENANCE);
   testerHeader.margin_hedged=MarketInfo(_Symbol,MODE_MARGINHEDGED);
   testerHeader.margin_divider=1.0;
   ArrayInitialize(testerHeader.margin_currency,0);
   StringToCharArray(SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN),testerHeader.margin_currency);
//---
   testerHeader.comm_base = 0.0;
   testerHeader.comm_type = 0;
   testerHeader.comm_lots = 1;
//---
   testerHeader.from_bar=0;
   testerHeader.to_bar=(int)i_minPreviousBars+1;
   for(int i=0; i<6; i++)
      testerHeader.start_period[i]=0;
   testerHeader.set_from=0;
   testerHeader.set_to=(int)i_startDate;
//---
   testerHeader.end_of_test=(int)i_endDate;
   testerHeader.freeze_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   testerHeader.generating_errors=0;
//---
   for(int i=0; i<60; i++)
      testerHeader.reserved[i]=0;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Copying FXT-file into the tester folder and setting attribute "Read Only"                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool CopyFXTFileToTesterFolder()
  {
   string dataFolder=TerminalInfoString(TERMINAL_DATA_PATH);
   string fxtFileName=GetFXTFileName();
   string sourceFullFileName=dataFolder+"\\MQL4\\Files\\"+fxtFileName;
   string destinationFullFileName=dataFolder+"\\tester\\history\\"+fxtFileName;
//---
   if(!IsWriteNewFileAllowed(destinationFullFileName))
      return false;
//---
   if(CopyFileW(sourceFullFileName,destinationFullFileName,false))
      return IsSetReadOnly(destinationFullFileName);
//---
   Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_COPY_ERROR));
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Verifying the existence in the folder of the tester of the file with the same name and the removal of the attribute "Read Only"                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsWriteNewFileAllowed(string fileName)
  {
   uint attributes=GetFileAttributesW(fileName);
   if(attributes==INVALID_FILE_ATTRIBUTES)
      return true;
//---
   attributes &=0xFFFE;
   if(SetFileAttributesW(fileName,attributes))
      return true;
//---
   Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_READ_ONLY_REMOVE_ERROR));
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Setting the attribute "Read Only" for FXT-file                                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSetReadOnly(string fileName)
  {
   uint attributes=GetFileAttributesW(fileName);
   if(attributes==INVALID_FILE_ATTRIBUTES)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_ATTRIBUTE_GETTING_ERROR));
      return false;
     }
   if(SetFileAttributesW(fileName,attributes|FILE_ATTRIBUTE_READONLY))
      return true;
//---
   Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_READ_ONLY_SET_ERROR));
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message and terminal language                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetStringByMessageCode(ENUM_MESSAGE_CODE messageCode)
  {
   string language=TerminalInfoString(TERMINAL_LANGUAGE);
   if(language=="Russian")
      return GetRussianMessage(messageCode);
//---
   return GetEnglishMessage(messageCode);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for russian language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetRussianMessage(ENUM_MESSAGE_CODE messageCode)
  {
   switch(messageCode)
     {
      case MESSAGE_CODE_POINT_EQUAL_TO_ZERO:               return ": фатальная ошибка терминала - величина пункта меньше или равна нулю. Скрипт отключен.";
      case MESSAGE_CODE_COMPLETE:                          return "Скрипт закончил свое выполнение. Файл FXT находится в папке тестера стратегий.";
      case MESSAGE_CODE_TERMINAL_FATAL_ERROR1:             return ": фатальная ошибка терминала - период графика равен 0. Скрипт отключен.";
      case MESSAGE_CODE_DLL_ERROR:                         return ": вызов функций DLL запрещен. Измените настройки терминала (Сервис - Настройки - Советники - Разрешить импорт DLL).";
      case MESSAGE_CODE_INVALID_TEST_DATA:                 return ": дата/время начала тестирования должна быть меньше даты/времени окончания тестирования. Скрипт отключен.";
      case MESSAGE_CODE_HISTORY_ABSENT:                    return ": количество баров в истории, предшествующее началу теста, недостаточно. Скрипт отключен.";
      case MESSAGE_CODE_SEEK_FILE_ERROR:                   return " ошибка перемещения файлового указателя в файле тиков. Скрипт отключен.";
      case MESSAGE_CODE_TICKS_FILE:                        return ": тиковый файл ";
      case MESSAGE_CODE_HAS_DATA:                          return " располагает данными с ";
      case MESSAGE_CODE_TO_DATE:                           return " по ";
      case MESSAGE_CODE_NOT_CORRESPONDING:                 return "что не соответствует заданному интервалу тестирования. Скрипт отключен.";
      case MESSAGE_CODE_ERRORN:                            return ": ошибка (N";
      case MESSAGE_CODE_FILE_OPEN:                         return ") открытия файла ";
      case MESSAGE_CODE_SCRIPT_IS_OFF:                     return ". Скрипт отключен.";
      case MESSAGE_CODE_READ_TICKS_FILE_ERROR:             return ": ошибка чтения файла тиков. Скрипт отключен.";
      case MESSAGE_CODE_SEEK_FILE_ERROR2:                  return ": не удалось вернуться к началу файла FXT. Скрипт отключен.";
      case MESSAGE_CODE_HEADER_FILE_ERROR:                 return ": не удалось записать заголовок FXT-файла. Скрипт отключен.";
      case MESSAGE_CODE_PRECEDING_HISTORY_ERROR:           return ": не удалось записать данные предшествующей истории. Скрипт отключен.";
      case MESSAGE_CODE_FILE_CREATE_ERROR:                 return ") создания файла. Скрипт отключен.";
      case MESSAGE_CODE_TICKS_WRITE_ERROR:                 return ": не удалось записать данные истории интервала тестирования. Скрипт отключен.";
      case MESSAGE_CODE_FEW_BARS:                          return ": общее количество записанных баров должно быть 101 и более. Скрипт отключен.";
      case MESSAGE_CODE_COPY_ERROR:                        return ": ошибка копирования файла в папку тестера стратегий. Скрипт отключен.";
      case MESSAGE_CODE_READ_ONLY_REMOVE_ERROR:            return ": не удалось убрать атрибут \"только для чтения\" у старого FXT-файла, находящемуся в папке тестера стратегий. Скрипт отключен.";
      case MESSAGE_CODE_ATTRIBUTE_GETTING_ERROR:           return ": не удалось получить атрибут файла. Скрипт отключен.";
      case MESSAGE_CODE_READ_ONLY_SET_ERROR:               return ": не удалось установить атрибут \"только для чтения\" FXT-файлу. Скрипт отключен.";
     }
   return "";
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for english language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetEnglishMessage(ENUM_MESSAGE_CODE messageCode)
  {
   switch(messageCode)
     {
      case MESSAGE_CODE_POINT_EQUAL_TO_ZERO:               return ": terminal fatal error - point is less than zero or equal to zero. The script is turned off.";
      case MESSAGE_CODE_COMPLETE:                          return "Execution of the script is completed. FXT file is located in the strategy tester folder.";
      case MESSAGE_CODE_TERMINAL_FATAL_ERROR1:             return ": terminal fatal error - chart period equals to zero. The script is turned off.";
      case MESSAGE_CODE_DLL_ERROR:                         return ": DLL function calls is prohibited. Change the terminal settings (Tools - Options - Expert Advisors - Allow DLL imports)";
      case MESSAGE_CODE_INVALID_TEST_DATA:                 return ": date / time of the test beginning should be less than date / time of end of testing. The script is turned off.";
      case MESSAGE_CODE_HISTORY_ABSENT:                    return ": the number of bars in the history, preceding the start of the test, is not enough. The script is turned off.";
      case MESSAGE_CODE_SEEK_FILE_ERROR:                   return "error moving the file pointer inside the ticks file. The script is turned off.";
      case MESSAGE_CODE_TICKS_FILE:                        return ": the ticks file ";
      case MESSAGE_CODE_HAS_DATA:                          return " is has data from ";
      case MESSAGE_CODE_TO_DATE:                           return " to ";
      case MESSAGE_CODE_NOT_CORRESPONDING:                 return "that does not correspond to a specified interval of testing. The script is turned off.";
      case MESSAGE_CODE_ERRORN:                            return ": error (N";
      case MESSAGE_CODE_FILE_OPEN:                         return ") of file opening ";
      case MESSAGE_CODE_SCRIPT_IS_OFF:                     return ". The script is turned off.";
      case MESSAGE_CODE_READ_TICKS_FILE_ERROR:             return ": Error reading the ticks file. The script is turned off.";
      case MESSAGE_CODE_SEEK_FILE_ERROR2:                  return ": unable to go back to the top of the FXT-file. The script is turned off.";
      case MESSAGE_CODE_HEADER_FILE_ERROR:                 return ": unable to save the header of FXT-file. The script is turned off.";
      case MESSAGE_CODE_PRECEDING_HISTORY_ERROR:           return ": unable to save the data of preceding history. The script is turned off.";
      case MESSAGE_CODE_FILE_CREATE_ERROR:                 return ") of file creation. The script is turned off.";
      case MESSAGE_CODE_TICKS_WRITE_ERROR:                 return ": unable to save the data into FXT-file. The script is turned off.";
      case MESSAGE_CODE_FEW_BARS:                          return ": the total number of the recorded bars must be 101 bars or more. The script is turned off.";
      case MESSAGE_CODE_COPY_ERROR:                        return ": error copying the file to a strategy tester folder. The script is turned off.";
      case MESSAGE_CODE_READ_ONLY_REMOVE_ERROR:            return ": failed to remove the attribute \"read only \" from the old FXT-file. This file is located in the strategy tester folder. The script is turned off.";
      case MESSAGE_CODE_ATTRIBUTE_GETTING_ERROR:           return ": failed to get file attribute. The script is turned off.";
      case MESSAGE_CODE_READ_ONLY_SET_ERROR:               return ": failed to set the attribute \"read only \" to the FXT-file. The script is turned off.";
     }
   return "";
  }
//+------------------------------------------------------------------+
