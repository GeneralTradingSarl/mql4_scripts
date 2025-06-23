//+------------------------------------------------------------------+
//|                                                    periodgen.mq4 |
//|                                                     Igor Morozov |
//+------------------------------------------------------------------+
//| Quickly create historical data from M1 data. Change TIMESHIFT to |
//| shift time for your server.                                      |
//| Steps to create data:                                            |
//| 1. create subfolder .../experts/files/databank/                  |
//| 2. copy M1 data into databank and call M1_XXXXXX.hst             |
//|    (alpari format)                                               |
//| 3. attach script 'periodgen' to the same chart XXXXXX, frame     |
//|    doesn't matter                                                |
//| 4. It will create subfolder .../experts/files/databank/XXXXXX    |
//|    in which you will find all timeframes up to D1 will be        |
//|    generated                                                     |
//+------------------------------------------------------------------+
#property copyright "Igor Morozov"
#property link      ""
//----
#include <stdlib.mqh>
#define NUM_FILES 7
#define DATA_FOLDER "databank"
#define BS "\\"
#define TIMESHIFT 3 // timeshift in hours
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
// initialize
	  int i;
	  int iFile, lFile, pFile[7];
	  string iFileName = "M1_" + Symbol() + ".hst"; // alpari input file
	  string lFileName = Symbol() + BS + Symbol() + ".log";
	  int pTime[NUM_FILES];
	  double pOpen[NUM_FILES];
	  double pLow[NUM_FILES];
	  double pHigh[NUM_FILES];
	  double pClose[NUM_FILES];
	  double pVolume[NUM_FILES];
	  int pCount[NUM_FILES];
	  int pPeriod[NUM_FILES];
	  pPeriod[0] = PERIOD_M1;
	  pPeriod[1] = PERIOD_M5;
	  pPeriod[2] = PERIOD_M15;
	  pPeriod[3] = PERIOD_M30;
	  pPeriod[4] = PERIOD_H1;
	  pPeriod[5] = PERIOD_H4;
	  pPeriod[6] = PERIOD_D1;
	  string pFileName[NUM_FILES];
	  for(i = 0; i < NUM_FILES; i++)
		     pFileName[i] = Symbol() + BS + Symbol() + pPeriod[i] + ".hst";
   int f_Unused[13];
// open files
	  iFile = FileOpen(DATA_FOLDER + BS + iFileName, FILE_BIN|FILE_READ);
	  if(iFile < 0)
	    {
		     Print(iFileName, " Open Error: ", ErrorDescription(GetLastError()));
		     return(0);
	    }
	  lFile = FileOpen(DATA_FOLDER + BS + lFileName, FILE_CSV|FILE_WRITE, " ");
	  if(lFile < 0)
	    {
		     Print(lFileName, " Open Error: ", ErrorDescription(GetLastError()));
		     return(0);
	    }
	  if(FileSize(iFile) < 192)
	    {
		     Print(iFileName, " has no data");
		     return(0);
	    }
	  for(i = 0; i < NUM_FILES; i++)
	    {
		     pFile[i] = FileOpen(DATA_FOLDER + BS + pFileName[i], FILE_BIN|FILE_WRITE);
		     if(pFile[i] < 0)
		       {
			        Print(pFileName[i], " Open Error: ", ErrorDescription(GetLastError()));
			        return(0);
		       }
	    }
	  FileWrite(lFile, TimeToStr(TimeCurrent()));
	  FileWrite(lFile, "Creating all timeframes for", Symbol(), "from", 
	            DATA_FOLDER + BS + iFileName);
	  FileWrite(lFile, "Time Shift ", TIMESHIFT);
	  // read header
	  int f_Version = FileReadInteger(iFile);
	  string f_CopyRight = FileReadString(iFile, 64);
	  string f_Symbol = FileReadString(iFile, 12);
	  int f_Period = FileReadInteger(iFile);
	  int f_Digits = FileReadInteger(iFile);
	  int f_TimeStamp = FileReadInteger(iFile);
	  int f_Sync = FileReadInteger(iFile);
	  FileReadArray(iFile, f_Unused, 0, 13);
	  FileWrite(lFile, "*------------------------------------------------");
	  FileWrite(lFile, "Header Information copied:");
	  FileWrite(lFile, "   Version:", "\t", f_Version);
	  FileWrite(lFile, " CopyRight:", "\t", f_CopyRight);
	  FileWrite(lFile, "    Symbol:", "\t", f_Symbol);
	  FileWrite(lFile, "    Period:", "\t", f_Period);
	  FileWrite(lFile, "    Digits:", "\t", f_Digits);
	  FileWrite(lFile, "Time Stamp:", "\t", TimeToStr(f_TimeStamp));
	  FileWrite(lFile, "      Sync:", "\t", f_Sync);
	  FileWrite(lFile, "*------------------------------------------------");
	  // write output headers
	  for(i = 0; i < NUM_FILES; i++)
	    {
	      FileWriteInteger(pFile[i], f_Version, LONG_VALUE);
   	   FileWriteString(pFile[i], f_CopyRight, 64);
   	   FileWriteString(pFile[i], f_Symbol, 12);
   	   FileWriteInteger(pFile[i], pPeriod[i], LONG_VALUE);
   	   FileWriteInteger(pFile[i], f_Digits, LONG_VALUE);
   	   FileWriteInteger(pFile[i], TimeCurrent(), LONG_VALUE);       //timesign
   	   FileWriteInteger(pFile[i], f_Sync, LONG_VALUE);       //last_sync
   	   FileWriteArray(pFile[i], f_Unused, 0, 13);
	    }
	  // init timeframes
	  int iCount;
	  int tCount = (FileSize(iFile) - 148) / 44;
   int f_Time = FileReadInteger(iFile) + TIMESHIFT*3600;
   double f_Open = FileReadDouble(iFile);
   double f_Low = FileReadDouble(iFile);
   double f_High = FileReadDouble(iFile);
   double f_Close = FileReadDouble(iFile);
   double f_Volume = FileReadDouble(iFile);
   iCount++;
	  FileWrite(lFile, "Start Time: ", TimeToStr(f_Time));
   for(i = 0; i < NUM_FILES; i++)
     {
 	     pTime[i] = f_Time - f_Time % (pPeriod[i]*60);
 	     pOpen[i] = f_Open;
 	     pLow[i] = f_Low;
 	     pHigh[i] = f_High;
 	     pClose[i] = f_Close;
 	     pVolume[i] = f_Volume;
     }
	  // creation loop	
   //	int testcount;
	  while(true)
	    {
		     bool isEndOfFile = FileTell(iFile) >= FileSize(iFile) - 1;
		     if(!isEndOfFile)
		       {
	   	      f_Time =FileReadInteger(iFile) + TIMESHIFT*3600;
	   	      f_Open =FileReadDouble(iFile);
   		      f_Low =FileReadDouble(iFile);
   		      f_High =FileReadDouble(iFile);
	   	      f_Close =FileReadDouble(iFile);
   		      f_Volume =FileReadDouble(iFile);
   		      iCount++;
	   	      if(iCount % 100000 == 0)
   			         Print(DoubleToStr(iCount*100.0 / tCount, 0), "% processed");
   	     }
   	   for(i = 0; i < NUM_FILES; i++)
   	     {
   		      int newtime = f_Time - f_Time % (pPeriod[i]*60);
   		      if(newtime != pTime[i] || isEndOfFile)
   		        {
	              FileWriteInteger(pFile[i], pTime[i]);
   	           FileWriteDouble(pFile[i], pOpen[i]);
      	        FileWriteDouble(pFile[i], pLow[i]);
         	     FileWriteDouble(pFile[i], pHigh[i]);
	              FileWriteDouble(pFile[i], pClose[i]);
   	           FileWriteDouble(pFile[i], pVolume[i]);
   	           pCount[i]++;
   	           if(pCount[i] % 100000 == 0)
   	      	        FileFlush(pFile[i]);
   	           if(!isEndOfFile)
   	             {
		   		            pTime[i] = newtime;
   				            pOpen[i] = f_Open;
		   		            pLow[i] = f_Low;
   				            pHigh[i] = f_High;
		   		            pClose[i] = f_Close;
   				            pVolume[i] = f_Volume;
   			           }
   		        }
   		      else
   		        {
   			         pClose[i] = f_Close;
   			         if(pLow[i] > f_Low)
   				            pLow[i] = f_Low;
   			         if(pHigh[i] < f_High)
   				            pHigh[i] = f_High;
   			         pVolume[i] += f_Volume;
   		        }
   	     }
   	   if(isEndOfFile)
   		  break;
	    }
	  // finish up
	  FileWrite(lFile, "  End Time: ", TimeToStr(f_Time));
	  FileWrite(lFile, "*------------------------------------------------");
	  FileWrite(lFile, "Records Processed (" + Symbol() + "1): ", iCount);
	  FileWrite(lFile, "Records Created:");
	  for(i = 0; i < NUM_FILES; i++)
		     FileWrite(lFile, Symbol() + pPeriod[i] + ":", pCount[i]);
   FileClose(iFile);
   FileClose(lFile);
   for(i = 0; i < NUM_FILES; i++)
 	     FileClose(pFile[i]);
   return(0);
  }
//+------------------------------------------------------------------+