//+------------------------------------------------------------------+
//|                                                    s_wininet.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"
//----
#import "wininet.dll"
int InternetAttemptConnect (int x);
  int InternetOpenW(string sAgent, int lAccessType, 
                    string sProxyName = "", string sProxyBypass = "", 
                    int lFlags = 0);
  int InternetOpenUrlW(int hInternetSession, string sUrl, 
                       string sHeaders = "", int lHeadersLength = 0,
                       int lFlags = 0, int lContext = 0);
  int InternetReadFile(int hFile, int& sBuffer[], int lNumBytesToRead, 
                       int& lNumberOfBytesRead[]);
  int InternetCloseHandle(int hInet);
#import
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   if(!IsDllsAllowed())
     {
       Alert("Необходимо в настройках разрешить использование DLL");
       return(0);
     }
   int rv = InternetAttemptConnect(0);
   if(rv != 0)
     {
       Alert("Ошибка при вызове InternetAttemptConnect()");
       return(0);
     }
   int hInternetSession = InternetOpenW("Microsoft Internet Explorer", 
                                        0, "", "", 0);
   if(hInternetSession <= 0)
     {
       Alert("Ошибка при вызове InternetOpenW()");
       return(0);         
     }
   int hURL = InternetOpenUrlW(hInternetSession, 
              "http://www.mql4.com/ru/users/Integer", "", 0, 0, 0);
   if(hURL <= 0)
     {
       Alert("Ошибка при вызове InternetOpenUrlW()");
       InternetCloseHandle(hInternetSession);
       return(0);         
     }      
   int cBuffer[256];
   int dwBytesRead[1]; 
   string TXT = "";
   while(!IsStopped())
     {
       bool bResult = InternetReadFile(hURL, cBuffer, 1024, dwBytesRead);
       if(dwBytesRead[0] == 0)
           break;
       string text = "";   
       for(int i = 0; i < 256; i++)
         {
         	 text = text + CharToStr(cBuffer[i] & 0x000000FF);
        	  if(StringLen(text) == dwBytesRead[0])
        	      break;
        	  text = text + CharToStr(cBuffer[i] >> 8 & 0x000000FF);
        	  if(StringLen(text) == dwBytesRead[0])
        	      break;
           text = text + CharToStr(cBuffer[i] >> 16 & 0x000000FF);
           if(StringLen(text) == dwBytesRead[0])
               break;
           text = text + CharToStr(cBuffer[i] >> 24 & 0x000000FF);
         }
       TXT = TXT + text;
       Sleep(1);
     }
   if(TXT != "")
     {
       int h = FileOpen("SavedFromInternet.htm", FILE_CSV|FILE_WRITE);
       if(h > 0)
         {
           FileWrite(h,TXT);
           FileClose(h);
           Alert("Готово! См. файл .../experts/files/SavedFromInternet.htm");
         }
       else
         {
           Alert("Ошибка при вызове FileOpen()");
         }
     }
   else
     {
       Alert("Нет считанных данных");
     }
   InternetCloseHandle(hInternetSession);
   return(0);
}
//+------------------------------------------------------------------+