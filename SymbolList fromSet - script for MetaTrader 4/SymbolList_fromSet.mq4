//+------------------------------------------------------------------+
//|                                           SymbolList_fromSet.mq4 |
//|                                      Copyright © 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, komposter"
#property link      "mailto:komposterius@mail.ru"
#property show_inputs
//----
extern string	SetFile_name = "forexall";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
	  int file_handle = FileOpen(SetFile_name + ".set", FILE_READ);
	  //---- Если возникла ошибка
	  if(file_handle < 0)
	    {
		     Print("Ошибка №", GetLastError(), " при открытии файла!!!");
		     return(-1);
	    }
	  string Symbols[1];
	  int SymbolsCount = 0;
	  while(true)
	    {
		     Symbols[SymbolsCount] = FileReadString(file_handle);
		     //---- Если достигнут конец файла, останавливаемся
		     if(GetLastError() == 4099) 
		         break;
		     if(FileIsEnding(file_handle)) 
		         break;
		     SymbolsCount ++;
		     ArrayResize(Symbols, SymbolsCount + 1);
	    }
	  FileClose(file_handle);
	  string str;
	  for(int s = 0; s < SymbolsCount; s ++)
	    {
		     str = str + Symbols[s] + "\n";
	    }
	  Comment(str);	
	  file_handle = FileOpen(StringConcatenate("SymbolList(", AccountServer(), ").csv"), 
	                         FILE_CSV | FILE_WRITE );
	  if(file_handle < 0)
	    {
		     Print("Ошибка №", GetLastError(), " при открытии файла!!!");
		     return(-1);
	    }
	  FileWrite(file_handle,
					        "SYMBOL",
					        "POINT",
					        "DIGITS",
					        "SPREAD",
					        "STOPLEVEL",
					        "LOTSIZE",
					        "TICKVALUE",
					        "TICKSIZE",
					        "SWAPLONG",
					        "SWAPSHORT",
					        "STARTING",
					        "EXPIRATION",
					        "TRADEALLOWED",
					        "MINLOT",
					        "LOTSTEP",
					        "MAXLOT");
	  for(s = 0; s < SymbolsCount; s ++)
	    {
		     if(MarketInfo(Symbols[s], MODE_POINT) <= 0) 
		         continue;
		     FileWrite(file_handle, Symbols[s],
						           MarketInfo(Symbols[s], MODE_POINT),
						           MarketInfo(Symbols[s], MODE_DIGITS),
						           MarketInfo(Symbols[s], MODE_SPREAD),
						           MarketInfo(Symbols[s], MODE_STOPLEVEL),
						           MarketInfo(Symbols[s], MODE_LOTSIZE),
						           MarketInfo(Symbols[s], MODE_TICKVALUE),
						           MarketInfo(Symbols[s], MODE_TICKSIZE),
						           MarketInfo(Symbols[s], MODE_SWAPLONG),
						           MarketInfo(Symbols[s], MODE_SWAPSHORT),
						           MarketInfo(Symbols[s], MODE_STARTING),
						           MarketInfo(Symbols[s], MODE_EXPIRATION),
						           MarketInfo(Symbols[s], MODE_TRADEALLOWED),
						           MarketInfo(Symbols[s], MODE_MINLOT),
						           MarketInfo(Symbols[s], MODE_LOTSTEP),
						           MarketInfo(Symbols[s], MODE_MAXLOT));
	    }
	  FileClose(file_handle);
	  return(0);
  }
//+------------------------------------------------------------------+


