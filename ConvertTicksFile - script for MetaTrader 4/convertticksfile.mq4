//+------------------------------------------------------------------+
//|                                             convertticksfile.mq4 |
//|                                        Copyright 2012, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Converting file ticks to the CSV-format specified period of chart.\nRussian: Конвертирование файла тиков в CSV-формат заданного периода графика."
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CONVERT_WAY
  {
   CONVERT_WAY_CSV_TICKS,                                                                          // To CSV - file of ticks / В CSV - файл тиков
   CONVERT_WAY_CSV_CANDLES,                                                                        // To CSV - file of candles / В CSV - файл свечей
   CONVERT_WAY_HST_CANDLES                                                                         // To history file / В файл истории
  };
//---
input ENUM_CONVERT_WAY  i_convertWay      = CONVERT_WAY_CSV_CANDLES;                               // Way to convert / Способ преобразования
input uint              i_tfMinutes       = 5;                                                     // Minutes in candle / Минут в свече
input string            i_sourceFile      = "EURUSD.tks";                                          // Source file name / Имя исходного файла
input string            i_destinationFile = "EURUSD.csv";                                          // Destination file name / Имя формируемого файла
input int               i_digits          = 5;                                                     // Amount of significant digits / Количество значащих цифр
//---
uint g_tfSeconds;
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
struct HistoryHeader
  {
   int               version;
   uchar             copyright[64];
   uchar             symbol[12];
   int               timeFrame;
   int               digits;
   int               reserved1;
   int               reserved2;
   int               unused[13];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MESSAGE_CODE
  {
   MESSAGE_CODE_SAME_FILES,
   MESSAGE_CODE_WRONG_TF,
   MESSAGE_CODE_FILE_OPEN_ERROR,
   MESSAGE_CODE_FATAL_ERROR,
   MESSAGE_CODE_READ_ERROR,
   MESSAGE_CODE_WRITE_ERROR,
   MESSAGE_CODE_HISTORY_IS_ABSENT,
   MESSAGE_CODE_ENOUGHT_MEMORY,
   MESSAGE_CODE_HISTORY_READ_ERROR,
   MESSAGE_CODE_CONFIRM_REWRITE_HISTORY,
   MESSAGE_CODE_TITLE_REWRITE_HISTORY,
   MESSAGE_CODE_HISTORY_WRITE_ERROR,
   MESSAGE_CODE_COMPLETED,
   MESSAGE_CODE_SUCCESS_COMPLETE
  };
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Script program start function                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnStart()
  {
   if(!TuningParameters())
      return;

// Preparing the buffers for copying history data   
   MqlRates rates[];
   ulong ratesCnt=0;

// Opening the files
   int sourceHandle,destHandle;
   if(!IsFilesOpen(sourceHandle,destHandle,rates,ratesCnt))
      return;

// Converting the data    
   bool isDone=ConvertData(sourceHandle,destHandle,rates,ratesCnt);
   FileClose(sourceHandle);
   FileClose(destHandle);

// End of work
   if(isDone)
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_SUCCESS_COMPLETE));
   Comment("");
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of values of tuning parameters                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool TuningParameters()
  {
   if(i_sourceFile==i_destinationFile)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_SAME_FILES));
      return false;
     }

   if(i_tfMinutes==0 && i_convertWay!=CONVERT_WAY_CSV_TICKS)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_WRONG_TF));
      return false;
     }

   g_tfSeconds=i_tfMinutes*60;
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Opening the files for read and write of data                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFilesOpen(int &sourceHandle,int &destHandle,MqlRates &rates[],ulong &ratesCnt)
  {
// Open the source file
   sourceHandle=FileOpen(i_sourceFile,FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE,',');
   if(sourceHandle<1)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_FILE_OPEN_ERROR),i_sourceFile,".");
      return false;
     }

// Open the destination file
   if(i_convertWay!=CONVERT_WAY_HST_CANDLES) // Open the CSV-file
     {
      destHandle=FileOpen(i_destinationFile,FILE_CSV|FILE_WRITE|FILE_SHARE_WRITE,',');
      if(destHandle<1)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_FILE_OPEN_ERROR),i_destinationFile,".");
         return false;
        }
     }
   else                                                                                            // Open or create the HST-file
     {
      HistoryHeader historyHeader={401,
           {
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
           }
            ,
           {0,0,0,0,0,0,0,0,0,0,0,0},0,0,0,0,{0,0,0,0,0,0,0,0,0,0,0,0,0}
        };
      StringToCharArray("(C)opyright 2003, MetaQuotes Software Corp.",historyHeader.copyright);
      StringToCharArray(Symbol(),historyHeader.symbol);
      historyHeader.timeFrame=(int)i_tfMinutes;
      historyHeader.digits=i_digits;

      if(!CopyExistsHistoryFile(historyHeader,rates,ratesCnt))
         return false;

      if(ratesCnt>0)
         if(MessageBox(GetStringByMessageCode(MESSAGE_CODE_CONFIRM_REWRITE_HISTORY),GetStringByMessageCode(MESSAGE_CODE_TITLE_REWRITE_HISTORY),MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2)==IDNO)
            return false;

      destHandle=FileOpenHistory(Symbol()+IntegerToString(i_tfMinutes)+".hst",FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI|FILE_BIN);
      if(destHandle<1)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_FILE_OPEN_ERROR),Symbol()+IntegerToString(i_tfMinutes)+".hsts.");
         return false;
        }

      if(FileWriteStruct(destHandle,historyHeader)==0)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HISTORY_WRITE_ERROR),GetLastError());
         FileClose(destHandle);
         return false;
        }
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Copy data from existing history file                                                                                                                                                              |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool CopyExistsHistoryFile(HistoryHeader &historyHeader,MqlRates &rates[],ulong &ratesCnt)
  {
// Try to open history file
   ratesCnt=0;
   int handle=FileOpenHistory(Symbol()+IntegerToString(i_tfMinutes)+".hst",FILE_READ|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI|FILE_BIN);
   if(handle<0)
     {
      Print(GetStringByMessageCode(MESSAGE_CODE_HISTORY_IS_ABSENT));
      return true;
     }

// Allocating the memory for history data
   ulong barsCnt=(FileSize(handle)-sizeof(historyHeader))/sizeof(MqlRates);
   if(ArrayResize(rates,(int)barsCnt)<0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_ENOUGHT_MEMORY));
      return false;
     }

// Reading the header of history file
   if(FileReadStruct(handle,historyHeader)==0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HISTORY_READ_ERROR),GetLastError());
      FileClose(handle);
      return false;
     }

// Reading the history file
   while(ratesCnt<barsCnt)
     {
      if(FileReadStruct(handle,rates[(int)ratesCnt])==0)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HISTORY_READ_ERROR),GetLastError());
         FileClose(handle);
         return false;
        }

      ratesCnt++;
     }

   FileClose(handle);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Converting the data                                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ConvertData(int &sourceHandle,int &destHandle,MqlRates &rates[],ulong &ratesCnt)
  {
// Determination of the amount of ticks written in the file
   ulong sizeInRec=GetFileTicksCount(sourceHandle);
   if(sizeInRec==0)
      return false;
   sizeInRec--;

   TickStruct oneTick;
   ulong recCnt=0;

// Reading ticks and their transformation into a candle
   string completed=GetStringByMessageCode(MESSAGE_CODE_COMPLETED);
   while(recCnt<=sizeInRec)
     {
      uint bytesCnt=FileReadStruct(sourceHandle,oneTick);
      if(bytesCnt==0)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_READ_ERROR),recCnt,".");
         return false;
        }

      if(!ChoiceConvertionWay(destHandle,oneTick,rates,ratesCnt,recCnt==sizeInRec))
         return false;

      recCnt++;
      Comment(completed,DoubleToString(recCnt/1.0/sizeInRec*100,2),"%...");
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of the amount of ticks written in the file                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ulong GetFileTicksCount(int sourceHandle)
  {
// Define the size of ticks structure
   uint recSize=sizeof(TickStruct);
   if(recSize==0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_FATAL_ERROR));
      return 0;
     }

   return FileSize(sourceHandle) / recSize;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| The choice of conversion method                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ChoiceConvertionWay(int destHandle,TickStruct &tick,MqlRates &rates[],ulong &ratesCnt,bool isLastTick)
  {
// Saving ticks to a CSV-file
   if(i_convertWay==CONVERT_WAY_CSV_TICKS)
     {
      if(FileWrite(destHandle,TimeToStr(tick.time,TIME_DATE|TIME_SECONDS),DoubleToStr(tick.bid,i_digits),DoubleToStr(tick.ask,i_digits))==0)
        {
         Alert(WindowExpertName(),MESSAGE_CODE_WRITE_ERROR);
         return false;
        }
      return true;
     }

// Saving candles to CSV- or HST-file
   return ConvertTicksToTF(destHandle, tick, rates, ratesCnt, isLastTick);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Convert ticks to the candles of specified period                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ConvertTicksToTF(int destHandle,TickStruct &tick,MqlRates &rates[],ulong &ratesCnt,bool isLastTick)
  {
   static MqlRates candle={0,0,0,0,0,0,0,0};
   datetime tickCandleTime=(tick.time/g_tfSeconds)*g_tfSeconds;

// Continued formation of candle
   if(tickCandleTime==candle.time)
     {
      candle.tick_volume++;
      candle.high= MathMax(tick.bid,candle.high);
      candle.low = MathMin(tick.bid,candle.low);
      candle.close=tick.bid;
      if(!isLastTick)
         return true;
     }

// The candle is formed. We writing it to a file
   if(candle.time>0)
      if(i_convertWay==CONVERT_WAY_CSV_CANDLES)
        {
         if(!IsCandleWritingToCSV(destHandle,candle))
            return false;
        }
   else
   if(!IsCandleWritingToHST(destHandle,candle,rates,ratesCnt,isLastTick))
      return false;

// Opening the new candle
   candle.time=tickCandleTime;
   candle.tick_volume=1;
   candle.open = tick.bid;
   candle.high = tick.bid;
   candle.low=tick.bid;
   candle.close=tick.bid;

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Saving data of candle to CSV-file                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsCandleWritingToCSV(int destHandle,MqlRates &candle)
  {
   if(FileWrite(destHandle,TimeToStr(candle.time,TIME_DATE),
      TimeToStr(candle.time,TIME_MINUTES),
      DoubleToStr(candle.open, i_digits),
      DoubleToStr(candle.high, i_digits),
      DoubleToStr(candle.low, i_digits),
      DoubleToStr(candle.close, i_digits),
      IntegerToString(candle.tick_volume))==0)
     {
      Alert(WindowExpertName(),MESSAGE_CODE_WRITE_ERROR);
      return false;
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Saving data of candle to HST-file                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsCandleWritingToHST(int destHandle,MqlRates &candle,MqlRates &rates[],ulong ratesCnt,bool isLastTick)
  {
   static ulong curRatesIndex=0;

// Writing to a file "old" candles
   if(!IsWritingOldCandles(destHandle,curRatesIndex,candle.time,rates,ratesCnt))
      return false;

// Inserting a new candle or rewriting the "old" candle
   if(curRatesIndex<ratesCnt && candle.time==rates[(int)curRatesIndex].time)
      curRatesIndex++;

   if(FileWriteStruct(destHandle,candle)==0)
     {
      Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HISTORY_WRITE_ERROR),GetLastError());
      FileClose(destHandle);
      return false;
     }

// Writing the remaining candles
   if(isLastTick)
      return IsWritingOldCandles(destHandle, curRatesIndex, StringToTime("3000.12.30 00:00"), rates, ratesCnt);

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Writing "old" candles to a fila                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsWritingOldCandles(int destHandle,ulong &curRatesIndex,datetime candleTime,MqlRates &rates[],ulong ratesCnt)
  {
   while(curRatesIndex<ratesCnt && candleTime>rates[(int)curRatesIndex].time)
     {
      if(FileWriteStruct(destHandle,rates[(int)curRatesIndex])==0)
        {
         Alert(WindowExpertName(),GetStringByMessageCode(MESSAGE_CODE_HISTORY_WRITE_ERROR),GetLastError());
         FileClose(destHandle);
         return false;
        }
      curRatesIndex++;
     }

   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message and terminal language                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetStringByMessageCode(ENUM_MESSAGE_CODE messageCode)
  {
   string language=TerminalInfoString(TERMINAL_LANGUAGE);
   if(language=="Russian")
      return GetRussianMessage(messageCode);

   return GetEnglishMessage(messageCode);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for Russian language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetRussianMessage(ENUM_MESSAGE_CODE messageCode)
  {
   switch(messageCode)
     {
      case MESSAGE_CODE_SAME_FILES:                   return ": имена файлов не должны совпадать!";
      case MESSAGE_CODE_WRONG_TF:                     return ": количество минут в свече должно быть больше нуля!";
      case MESSAGE_CODE_FILE_OPEN_ERROR:              return ": не удалось открыть файл ";
      case MESSAGE_CODE_FATAL_ERROR:                  return ": фатальная ошибка скрипта - структура TickStruct имеет нулевой размер.";
      case MESSAGE_CODE_READ_ERROR:                   return ": ошибка чтения из исходного файла. Номер записи ";
      case MESSAGE_CODE_WRITE_ERROR:                  return ": ошибка записи в файл назначения. Номер записи ";
      case MESSAGE_CODE_HISTORY_IS_ABSENT:            return "Указанный файл истории не найден. Будет создан новый файл.";
      case MESSAGE_CODE_ENOUGHT_MEMORY:               return ": не хватает памяти для копирования данных.";
      case MESSAGE_CODE_HISTORY_READ_ERROR:           return ": ошибка чтения файла истории. Ошибка N";
      case MESSAGE_CODE_CONFIRM_REWRITE_HISTORY:      return "В терминале существует подобная история котировок.\nВ местах совпадения свечей история будет перезаписана. Продолжать?";
      case MESSAGE_CODE_TITLE_REWRITE_HISTORY:        return "ВНИМАНИЕ! Перезапись истории.";
      case MESSAGE_CODE_HISTORY_WRITE_ERROR:          return ": ошибка записи в файл истории.";
      case MESSAGE_CODE_COMPLETED:                    return "Обработано ";
      case MESSAGE_CODE_SUCCESS_COMPLETE:             return ": преобразование успешно завершено.";
     }

   return "";
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Getting string by code of message for English language                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetEnglishMessage(ENUM_MESSAGE_CODE messageCode)
  {
   switch(messageCode)
     {
      case MESSAGE_CODE_SAME_FILES:                   return ": file names do not have to match!";
      case MESSAGE_CODE_WRONG_TF:                     return ": the number of minutes in the candle should be greater than zero!";
      case MESSAGE_CODE_FILE_OPEN_ERROR:              return ": could not open the file ";
      case MESSAGE_CODE_FATAL_ERROR:                  return ": fatal error the script - TickStruct structure has zero size.";
      case MESSAGE_CODE_READ_ERROR:                   return ": the source file reading error. Record number ";
      case MESSAGE_CODE_WRITE_ERROR:                  return ": the destination file writing error. Record number ";
      case MESSAGE_CODE_HISTORY_IS_ABSENT:            return "The specified history file is not found. The new file will be created.";
      case MESSAGE_CODE_ENOUGHT_MEMORY:               return ": not enough memory to copy data.";
      case MESSAGE_CODE_HISTORY_READ_ERROR:           return ": reading error of the history file. Error N";
      case MESSAGE_CODE_CONFIRM_REWRITE_HISTORY:      return "MetaTrader contains the similar history of quotes.\nMatching candles of history will be overwritten. Continue?";
      case MESSAGE_CODE_TITLE_REWRITE_HISTORY:        return "ATTENTION! Rewriting history.";
      case MESSAGE_CODE_HISTORY_WRITE_ERROR:          return ": writing error of the history file. Error N";
      case MESSAGE_CODE_COMPLETED:                    return "Completed ";
      case MESSAGE_CODE_SUCCESS_COMPLETE:             return ": conversion was successful complete.";
     }

   return "";
  }
//+------------------------------------------------------------------+
