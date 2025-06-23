//+------------------------------------------------------------------+
//|                                                   SymbolInfo.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|  02.04.2006  Скрипт для выгрузки информации о символах.          |
//|  04.05.2006  Добавил столбец "Залог".                            |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs
//------- Внешние параметры скрипта ---------------------------------+
extern string siFileName  = "SymbolInfo.csv";
extern string siSeparator = ".";
//------- Глобальные переменные скрипта -----------------------------+
string siMS[16]={"AUDUSD","CHFJPY","EURAUD","EURCAD","EURCHF",
                 "EURGBP","EURJPY","EURUSD","GBPCHF","GBPJPY",
                 "GBPUSD","GOLD","NZDUSD","USDCAD","USDCHF","USDJPY"};
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
  {
   double b, ls, z;
   double aud = MarketInfo("AUDUSD", MODE_BID);
   double eur = MarketInfo("EURUSD", MODE_BID);
   double gbp = MarketInfo("GBPUSD", MODE_BID);
   double nzd = MarketInfo("NZDUSD", MODE_BID);
   int    d, i, k;
   string st;
   FileDelete(siFileName);
   st = ";" + TimeToStr(LocalTime(), TIME_DATE) + ";" + AccountCompany();
   WritingLineInFile(siFileName, st);
   WritingLineInFile(siFileName, "");
   st = "№;Символ;Long;Short;Спрэд;Стопы;Контракт;Залог";
   WritingLineInFile(siFileName, st);
   for(i = 0; i < ArraySize(siMS); i++)
     {
       b = MarketInfo(siMS[i], MODE_BID);
       d = MarketInfo(siMS[i], MODE_DIGITS);
       ls = MarketInfo(siMS[i], MODE_LOTSIZE);
       z = 0;
       st = DoubleToStr(i + 1, 0) + ";" +
                        siMS[i] + ";" + 
                        DoubleToStr(MarketInfo(siMS[i], MODE_SWAPLONG), 2) + ";" +
                        DoubleToStr(MarketInfo(siMS[i], MODE_SWAPSHORT), 2) + ";" +
                        DoubleToStr(MarketInfo(siMS[i], MODE_SPREAD), 0) + ";" +
                        DoubleToStr(MarketInfo(siMS[i], MODE_STOPLEVEL), 0) + ";" +
                        DoubleToStr(ls, 0) + ";";
       if(d == 2) 
           k = 10000; 
       else 
           k = 100;
       if(StringSubstr(siMS[i], 0, 3) == "AUD") 
           z = ls*aud / 100;
       if(StringSubstr(siMS[i], 0, 3) == "EUR") 
           z = ls*eur / 100;
       if(StringSubstr(siMS[i], 0, 3) == "GBP") 
           z = ls*gbp / 100;
       if(StringSubstr(siMS[i], 0, 3) == "NZD") 
           z = ls*nzd / 100;
       if(StringSubstr(siMS[i], 0, 3) == "USD") 
           z = ls / 100;  // else z = ls*b / k;
       st = st + DoubleToStr(z, 2);
       if(siSeparator != ".") 
           st = StrTran(st, ".", siSeparator);
       WritingLineInFile(siFileName, st);
     }
   st = "Сформирован файл: " + siFileName;
   Comment(st); 
   Print(st);
  }
//+------------------------------------------------------------------+
//| Замена подстроки                                                 |
//| Параметры:                                                       |
//|   str     - текстовая строка, в которой производится замена      |
//|   strfrom - заменяемая подстрока                                 |
//|   strto   - заменяющая подстрока                                 |
//+------------------------------------------------------------------+
string StrTran(string str, string strfrom, string strto)
  {
   int    n;
   string outstr = "", tempstr;
   for(n = 0; n < StringLen(str); n++)
     {
       tempstr = StringSubstr(str, n, StringLen(strfrom));
       if(tempstr == strfrom)
         {
           outstr = outstr + strto;
           n = n + StringLen(strfrom) - 1;
         } 
       else 
           outstr = outstr + StringSubstr(str, n, 1);
     }
   return(outstr);
  }
//+------------------------------------------------------------------+
//| Запись строки в файл                                             |
//+------------------------------------------------------------------+
void WritingLineInFile(string FileName, string text)
  {
   int file_handle = FileOpen(FileName, FILE_READ|FILE_WRITE, " ");
	  if(file_handle > 0)
	    {
		     FileSeek(file_handle, 0, SEEK_END);
		     FileWrite(file_handle, text);
		     FileClose(file_handle);
	    }
  }
//+------------------------------------------------------------------+

