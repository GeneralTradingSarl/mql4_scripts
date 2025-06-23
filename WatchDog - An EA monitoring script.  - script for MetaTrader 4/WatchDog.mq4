/*=============================================================
 Info:    WatchDog - An EA monitoring script. WatchDog alerting you when things go wrong! 
 Name:    WatchDog.mq4
 Author:  Erich Pribitzer
 Version: 1.2
 Update:  2012-01-08 
 Notes:   GMT bugfix
 Version: 1.1
 Update:  2012-01-01 
 Notes:   ---
  
 Copyright (C) 2012 Erich Pribitzer 
 Email: seizu@gmx.at
=============================================================*/
#property copyright "Copyright © 2011, Erich Pribitzer"
#property link      "http://www.wartris.com"
#property show_confirm

string BASEDIR                = "C:\\Program Files\\Metatrader4\\";  // set your Metatrader installation path

#define WD_URL                "http://myWebSite.com/update.php"


#define OF_READ               0
#define OF_WRITE              1
#define OF_READWRITE          2
#define OF_SHARE_COMPAT       3
#define OF_SHARE_DENY_NONE    4
#define OF_SHARE_DENY_READ    5
#define OF_SHARE_DENY_WRITE   6
#define OF_SHARE_EXCLUSIVE    7
 
 
#define INTERNET_OPEN_TYPE_DIRECT       0
#define INTERNET_FLAG_RELOAD            0x80000000
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000
#define INTERNET_FLAG_DONT_CACHE        0x04000000
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100
#define INTERNET_FLAG_ASYNC             0x10000000
#define AGENT                           "WatchDog Alive-Checker"

#import "wininet.dll"
   int InternetOpenA(string sAgent, int lAccessType, string sProxyName="", string sProxyBypass="", int lFlags=0);
   int InternetOpenUrlA(int hInternetSession, string sUrl, string sHeaders="", int lHeadersLength=0, int lFlags=0, int lContext=0);
   int InternetCloseHandle(int hInet); 
#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _lcreat (string path, int attrib);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lwrite (int handle, string buffer, int bytes);
   int _lclose (int handle);
   int GetModuleFileNameA(int hModul,string file, int size);
   int GetModuleHandleA(string lpModuleName);
   int GetFileAttributesA(string file);
   void GetSystemTime(int& gmt[]);   
#import "user32.dll"
   int PostMessageA(int hWnd,int Msg,int wParam,int lParam);
   int SendMessageA(int hWnd,int Msg,int wParam,int lParam);
   int GetWindow(int hWnd,int uCmd);
   int GetParent(int hWnd);
#import

#define WD_CUESIZE 256                    // event message queue
#define WD_BUFFER_SIZE 1024               // log file buffer
#define WD_SHOW_HISTORY_STATEMENT 0       // 0 = off , >0 = show last history posistions (effect the WDE_STATEMENT-Event) 
#define WD_TIMEOFFSET  0                  // set your time offset (in hours) to correct the local server time                  



// define your custom envet-ids here  
// -------------------------------- journal logfile events ------------------------------------------------------
#define WDE_JL_DELETED        0           //
#define WDE_JL_REQUOTE        1           //
#define WDE_JL_FAILED         2           //
#define WDE_JL_EALOADED       3           //
#define WDE_JL_EAREMOVED      4           //
#define WDE_JL_custom1        5           //
#define WDE_JL_custom2        6           //
#define WDE_JL_custom3        7           //
#define WDE_JL_custom4        8           //
#define WDE_JL_custom5        9           //
#define WDE_JL_custom6        10          //
//---------------------------------------------------------------------------------------------------------------
#define WDE_LOG_SIZE          10          // number of log events -----------------------------------------------
//--------------------------------- none logfile events ---------------------------------------------------------
#define WDE_ALIVE             11          //
#define WDE_CONNECTIVITY      12          //
#define WDE_OPENCLOSE         13          //
#define WDE_custom1           14          //
#define WDE_custom2           15          //
#define WDE_custom3           16          //
#define WDE_custom4           17          //
#define WDE_custom5           18          //
#define WDE_custom6           19          //
#define WDE_STATEMENT         20          //
#define WDE_ERROR             21          //
#define WDE_SIZE              22          //

// event config
#define WDC_ENABLED 0            // 0 = event disabled (default)
#define WDC_INTERVAL 1           // check interval in seconds
#define WDC_FIRSTCHECK 2         // 0 = Immediately, on timestamp 
#define WDC_NORMALLEVEL 3        // 0 = (default), normal threshold
#define WDC_WARNINGLEVEL 4       //                waring threshold 
#define WDC_CRITICALLEVEL 5      //                critical threshold
#define WDC_NORMALACTION 6       // 0 = do nothing (default), action bit-flags
#define WDC_WARNINGACTION 7      // 
#define WDC_CRITICALACTION 8     // 
#define WDC_SIZE 9

// storage
#define WDS_NEXTCHECK 0      // next check time
#define WDS_LEVEL 1          // current errorlevel
#define WDS_LASTLEVEL 2      // previous errorlevel
#define WDS_CUECOUNT 3
#define WDS_LASTCUECOUNT 4
#define WDS_SIZE 5

// action bits flags 
#define WDA_MAIL 1      // send mail
#define WDA_SMS  2      // send sms 
#define WDA_LOG  4      // write to log
#define WDA_RESET 8     // reset wds_level (set to 0)

// log file stuff
string wd_fileBuffer;
string wd_logPath[WDE_LOG_SIZE];
int    wd_logDate[WDE_LOG_SIZE];
int    wd_logSize[WDE_LOG_SIZE];

int    wd_endPos[WDE_LOG_SIZE];          // pattern endpos.  
string wd_match1[WDE_LOG_SIZE];          // first pattern AND
string wd_match2[WDE_LOG_SIZE];          // second pattern AND
string wd_match3[WDE_LOG_SIZE];          // third pattern AND NOT
string wd_exclude[WDE_LOG_SIZE];         // fourth pattern

string wd_message[WDE_SIZE][WD_CUESIZE];  // message buffer
string wd_eventTitle[WDE_SIZE];

double wdc[WDE_SIZE][WDC_SIZE];           // event config buffer
double wds[WDE_SIZE][WDS_SIZE];           // event runtime buffer

double wd_time;
string wd_mailBody;
int    wd_handle;

double wd_AT[];
double wd_noT[];        // new opened
double wd_ncT[];        // new closed
int    wd_historyTotal; // history count 


double POINT;
bool   FIVEDIGITS;
int    LOTDIGITS;


int init() {

   if(Digits ==5 || MarketInfo("EURUSD",MODE_DIGITS) >= 5) {
      POINT =Point*10;
      FIVEDIGITS=true;
   }
   else {
      POINT =Point; 
      FIVEDIGITS=false;
   }
   
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)
      LOTDIGITS=2;
   else
      LOTDIGITS=1;

   int intParent = GetParent( WindowHandle( Symbol(), Period() ) );   
   wd_handle  = GetParent(GetParent(intParent));   

   // init event and storage buffer
   for(int t=0;t<WDE_SIZE;t++) {    
      for(int u=0;u<WDC_SIZE;u++)
         wdc[t][u]=0;
      for(u=0;u<WDS_SIZE;u++)
         wds[t][u]=0;
   }
 
   // init log and search stuff buffer
   for(t=0;t<WDE_LOG_SIZE;t++) {
      
      wd_match1[t]="";
      wd_match2[t]="";
      wd_match3[t]="";
      wd_exclude[t]="";
      
      wd_logPath[t]="";
      wd_logDate[t]=0;
      wd_logSize[t]=0;
      wd_endPos[t]=0;
      wd_eventTitle[t]="";
   }

   wd_historyTotal = OrdersHistoryTotal();
   wd_orderCheck(wd_AT,wd_ncT,wd_noT);


// Event configuration ===================================================================
// Event configuration ===================================================================


//   wd_eventTitle[WDE_JL_custom1]                = "Custom1";             // email subject
//   wdc[WDE_JL_custom1][WDC_ENABLED]             = 1;                     // event 0=disabled / 1=enabled
//   wdc[WDE_JL_custom1][WDC_INTERVAL]            = 60;                    // check interval in seconds
//   wdc[WDE_JL_custom1][WDC_NORMALLEVEL]         = 1;                     // perform a normal-action if level-counter is >= 1 
//   wdc[WDE_JL_custom1][WDC_NORMALACTION]        = WDA_MAIL|WDA_RESET;    // normal-action: send mail and clear level-counter
//   wd_logPath[WDE_JL_custom1]                   = BASEDIR+"logs\\";      // journal log path
//   wd_match1[WDE_JL_custom1]                    = "string1";             // first pattern AND
//   wd_match2[WDE_JL_custom1]                    = "string2";             // second pattern AND      (OPTIONAL)
//   wd_match3[WDE_JL_custom1]                    = "string3";             // third pattern AND       (OPTIONAL)
//   wd_exclude[WDE_JL_custom1]                   = "string4";             // NOT fourth pattern      (OPTIONAL)
      
   wd_eventTitle[WDE_JL_DELETED]                = "Order deleted";         // email subject
   wdc[WDE_JL_DELETED][WDC_ENABLED]             = 1;                       // event 0=disabled / 1=enabled 
   wdc[WDE_JL_DELETED][WDC_INTERVAL]            = 60;
   wdc[WDE_JL_DELETED][WDC_NORMALLEVEL]         = 1;
   wdc[WDE_JL_DELETED][WDC_NORMALACTION]        = WDA_MAIL|WDA_RESET;
   wd_logPath[WDE_JL_DELETED]                   = BASEDIR+"logs\\";
   wd_match1[WDE_JL_DELETED]                    = "order";                 // search order AND
   wd_match2[WDE_JL_DELETED]                    = "deleted";               // deleted

   // config jounal log
   wd_eventTitle[WDE_JL_REQUOTE]                = "Requote";  
   wdc[WDE_JL_REQUOTE][WDC_ENABLED]             = 0;
   wdc[WDE_JL_REQUOTE][WDC_INTERVAL]            = 60; 
   wdc[WDE_JL_REQUOTE][WDC_CRITICALLEVEL]       = 1;
   wdc[WDE_JL_REQUOTE][WDC_CRITICALACTION]      = WDA_MAIL|WDA_RESET;   
   wd_logPath[WDE_JL_REQUOTE]                   = BASEDIR+"logs\\";
   wd_match1[WDE_JL_REQUOTE]                    = "requote";

   // config jounal log
   wd_eventTitle[WDE_JL_FAILED]                 = "Failed";  
   wdc[WDE_JL_FAILED][WDC_ENABLED]              = 1;
   wdc[WDE_JL_FAILED][WDC_INTERVAL]             = 60;
   wdc[WDE_JL_FAILED][WDC_CRITICALLEVEL]        = 1;
   wdc[WDE_JL_FAILED][WDC_CRITICALACTION]       = WDA_MAIL|WDA_RESET;   
   wd_logPath[WDE_JL_FAILED]                    = BASEDIR+"logs\\";
   wd_match1[WDE_JL_FAILED]                     = "failed";
   
   // count "expert ... loaded" event
   wdc[WDE_JL_EALOADED][WDC_ENABLED]            = 1;
   wdc[WDE_JL_EALOADED][WDC_INTERVAL]           = 60; 
   wd_logPath[WDE_JL_EALOADED]                  = BASEDIR+"logs\\";
   wd_match1[WDE_JL_EALOADED]                   = "Expert";
   wd_match2[WDE_JL_EALOADED]                   = "successfully";
   
   // count "expert ... removed" event
   wd_eventTitle[WDE_JL_EAREMOVED]              = "Expert Advisor";  
   wdc[WDE_JL_EAREMOVED][WDC_ENABLED]           = 1;
   wdc[WDE_JL_EAREMOVED][WDC_INTERVAL]          = 60; 
   wdc[WDE_JL_EAREMOVED][WDC_NORMALACTION]      = WDA_MAIL;
   wdc[WDE_JL_EAREMOVED][WDC_CRITICALLEVEL]     = 1;
   wdc[WDE_JL_EAREMOVED][WDC_CRITICALACTION]    = WDA_MAIL;
   wd_logPath[WDE_JL_EAREMOVED]                 = BASEDIR+"logs\\";
   wd_match1[WDE_JL_EAREMOVED]                  = "Expert";
   wd_match2[WDE_JL_EAREMOVED]                  = "removed";

   wd_eventTitle[WDE_OPENCLOSE]                 = "Order Opened/Closed";  
   wdc[WDE_OPENCLOSE][WDC_ENABLED]              = 1;
   wdc[WDE_OPENCLOSE][WDC_INTERVAL]             = 60;
   wdc[WDE_OPENCLOSE][WDC_NORMALLEVEL]          = 1;
   wdc[WDE_OPENCLOSE][WDC_NORMALACTION]         = WDA_MAIL|WDA_RESET;
      
   wdc[WDE_ALIVE][WDC_ENABLED]                   = 0;
   wdc[WDE_ALIVE][WDC_INTERVAL]                  = 40;       // 40sec ALIVE

   wd_eventTitle[WDE_CONNECTIVITY]              = "Connectivity";  
   wdc[WDE_CONNECTIVITY][WDC_ENABLED]           = 1;
   wdc[WDE_CONNECTIVITY][WDC_INTERVAL]          = 60;       
   wdc[WDE_CONNECTIVITY][WDC_NORMALACTION]      = WDA_MAIL;
   wdc[WDE_CONNECTIVITY][WDC_CRITICALLEVEL]     = 1;
   wdc[WDE_CONNECTIVITY][WDC_CRITICALACTION]    = WDA_MAIL;

   wd_eventTitle[WDE_STATEMENT]                 = "Hourly statement";  
   wdc[WDE_STATEMENT][WDC_ENABLED]              = 1;
   wdc[WDE_STATEMENT][WDC_INTERVAL]             = 60*60;     // 1h check interval
   wdc[WDE_STATEMENT][WDC_NORMALACTION]         = WDA_MAIL|WDA_RESET;

   wd_eventTitle[WDE_ERROR]                     = "Error";  
   wdc[WDE_ERROR][WDC_ENABLED]                  = 1;
   wdc[WDE_ERROR][WDC_INTERVAL]                 = 60;     // 1min check interval
   wdc[WDE_ERROR][WDC_NORMALACTION]             = WDA_MAIL;
   wdc[WDE_ERROR][WDC_WARNINGLEVEL]             = 1;
   wdc[WDE_ERROR][WDC_WARNINGACTION]            = WDA_MAIL;
   wdc[WDE_ERROR][WDC_CRITICALLEVEL]            = 2;
   wdc[WDE_ERROR][WDC_CRITICALACTION]           = WDA_MAIL;

// Event configuration =============================================================== End =
// Event configuration =============================================================== End =

}

void wd_orderCheck(double &AT[],double &ncT[], double &noT[] )
{
   double nAT[];        // new active trades
     
   int total=OrdersTotal();
   ArrayResize(nAT,total);
   ArrayResize(noT,total);
   int lastTotal=ArraySize(AT);
   //Print("lastTotal",lastTotal);
   ArrayResize(ncT,lastTotal);

   int t,nt=0,no=0,nc=0;
   int ticket;
   
   for(int pos=0;pos<total;pos++) {

      if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
      if(OrderType()>1) continue;                             // ignore pending orders
      ticket=OrderTicket();
      nAT[nt]=ticket;
      
      for(t=0;t<lastTotal;t++) {
         if(nAT[nt]==AT[t]) { AT[t]=0; break; }      
      }
      if(t==lastTotal) { noT[no]=ticket; no++; } 
      
      nt++;
   }
   ArrayResize(noT,no);

   for(t=0;t<lastTotal;t++) {
      if(AT[t]==0) continue;
      ncT[nc]=AT[t];
      nc++;               
   }
   ArrayResize(ncT,nc);

   if(nt>0)
      ArrayCopy(AT,nAT,0,0,nt);
      
   ArrayResize(AT,nt);

}

int start() {

   int wd_session=0;
    
   while(IsStopped()==false) {
      
      if(wd_session>0) {
         InternetCloseHandle(wd_session);
         wd_session=0;
      }                 
      
      wd_mailBody="";
      wd_time=TimeLocal()+(WD_TIMEOFFSET*60*60);
      bool journalflushed=false;
      
      for(int event=0;event<WDE_SIZE;event++) {         
         //Print(wd_time,"#",wdc[event][WDC_ENABLED],"#",wds[event][WDS_NEXTCHECK],"#",wdc[event][WDC_FIRSTCHECK]);         
         int bytesRead=0;
         if(wdc[event][WDC_ENABLED]==1 && (wd_time >= wds[event][WDS_NEXTCHECK] && wd_time >= wdc[event][WDC_FIRSTCHECK]) ) {
            
            if(event < WDE_LOG_SIZE) {     // // log event ?
               
               if(journalflushed==false) {
                  wd_flushJournal();
                  journalflushed=true;
               }     
               wd_fileBuffer="";
               bytesRead=wd_refreshMT4Logs(event, wd_logPath, wd_logSize, wd_logDate, wd_fileBuffer);
            }
            
            switch(event) {
               case WDE_JL_DELETED:
               case WDE_JL_FAILED:               
               case WDE_JL_REQUOTE:               
               case WDE_JL_EALOADED:
//             case WDE_JL_custom1:
//             case WDE_JL_custom2:
//             case WDE_JL_custom3:
//             case WDE_JL_custom4:
//             case WDE_JL_custom5:
//             case WDE_JL_custom6:
                  if(wd_searchLog(event,bytesRead))
                     continue;
                  break;
               
               case WDE_JL_EAREMOVED:
                  if(wd_searchLog(event,bytesRead))
                     continue;
                  if(wds[event][WDS_LEVEL]>0 && wd_endPos[event] < wd_endPos[WDE_JL_EALOADED])
                     wds[event][WDS_LEVEL]=0;
                  break;


               case WDE_OPENCLOSE:                 
                  wd_orderCheck(wd_AT,wd_ncT,wd_noT);
                  if(ArraySize(wd_noT)>0 || ArraySize(wd_ncT)>0 || OrdersHistoryTotal()>wd_historyTotal) {  
                     wds[WDE_STATEMENT][WDS_NEXTCHECK]=wds[event][WDS_NEXTCHECK];   // invoke a statement-event
                  //Print("WDE_OPENCLOSE");
                  wds[event][WDS_LEVEL]=1;
                  }                           
                  break;
               
                                                 
               case WDE_STATEMENT:
                  if(isMarketClosed()==false) {               
                     //Print("WDE_STATEMENT");
                     wd_statement(event);
                     wds[event][WDS_LEVEL]=1;
                  }
                  break;                                                                                                               

               case WDE_CONNECTIVITY:
                  if(IsConnected()==true)
                    wds[event][WDS_LEVEL]=0;
                  else
                    wds[event][WDS_LEVEL]=1;
                  break;
                  
               case WDE_ALIVE:
                  wd_session=wd_httpGET(WD_URL);                  
                  break;                                    
               
               case WDE_ERROR:
                  if(wds[event][WDS_CUECOUNT]==0) {
                    wds[event][WDS_LEVEL]=0;                  
                  }
                  break; 

//               case WDE_custom1:
//                  if(.. your condition.. ) {
//                    wds[event][WDS_LEVEL]=1;                  
//                  }
//                  break;                

//               case WDE_custom2:
//                  if(.. your condition.. ) {
//                    wds[event][WDS_LEVEL]=1;                  
//                  }
//                  break;                



            } // end switch   
                     
            wds[event][WDS_NEXTCHECK]=wd_time+wdc[event][WDC_INTERVAL];
            
            if(wdc[event][WDC_ENABLED]==1 && wds[event][WDS_LASTLEVEL]!=wds[event][WDS_LEVEL]) {
          
               if(wdc[event][WDC_CRITICALLEVEL] != 0 && wds[event][WDS_LEVEL] >= wdc[event][WDC_CRITICALLEVEL])
                  wd_processAction(event,WDC_CRITICALACTION);  
               else if(wdc[event][WDC_WARNINGLEVEL] !=0 && wds[event][WDS_LEVEL] >= wdc[event][WDC_WARNINGLEVEL])
                  wd_processAction(event,WDC_WARNINGACTION);
               else if(wds[event][WDS_LEVEL] >= wdc[event][WDC_NORMALLEVEL])
                  wd_processAction(event,WDC_NORMALACTION); 
           }

           wds[event][WDS_LASTCUECOUNT]=wds[event][WDS_CUECOUNT]; 
           wds[event][WDS_CUECOUNT]=0; 
           wds[event][WDS_LASTLEVEL]=wds[event][WDS_LEVEL];
                          
         } // end if
      } // end for
      
      if(wd_mailBody!="") {
         //Print(wd_mailBody);return (0);
         SendMail("WatchDog",wd_mailBody);
      }
      Sleep(1000);      
  }
}

void wd_statement(int event) {

   string type[]={"Buy","Sell","BuyLimit","SellLimit","BuyStop","SellStop"};
   int total=OrdersTotal();
   int hstTotal=OrdersHistoryTotal();
   string summary="";
   double totalprofit=0;
   int totalpips=0;       
   int pip=0;
   double profit=0;
   string pe="";
            
   if(total>0) {
      wd_storeLocal(event,"***** TRADES *****");
       
      for(int pos=0;pos<total;pos++) {  
         if(OrderSelect(pos,SELECT_BY_POS)==false) continue;
         pip=NormalizeDouble(OrderOpenPrice()-OrderClosePrice(),Digits)/POINT;
         profit=OrderProfit();
         pe="";
         if(OrderType()==OP_BUY)
            pip=-pip;  
         else if(OrderType()!=OP_SELL) {
            pe="*";     // pending order
            pip=0;
         }
            
         totalpips=totalpips+pip;
         totalprofit=totalprofit+profit;
               
         summary=pe+OrderTicket()+"#"+TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES)+"#"+type[OrderType()]+"#"+DoubleToStr(OrderLots(),LOTDIGITS)+"#"+OrderSymbol()+"#"+DoubleToStr(OrderOpenPrice(),Digits)+"#"+DoubleToStr(OrderStopLoss(),Digits)+"#"+DoubleToStr(OrderTakeProfit(),Digits)+"#"+DoubleToStr(profit,LOTDIGITS)+"#"+pip;
         wd_storeLocal(event,summary);
      }
   }


   if(hstTotal>0 ) {
      int closedOrders=ArraySize(wd_ncT);
      if((hstTotal-wd_historyTotal)>closedOrders)
         closedOrders=hstTotal-wd_historyTotal;
      
      wd_historyTotal=hstTotal;                       // update
         
      int show=WD_SHOW_HISTORY_STATEMENT;
      if(closedOrders > WD_SHOW_HISTORY_STATEMENT)
         show=closedOrders;

      if(hstTotal-show < 0)
         show=hstTotal;
      show=hstTotal-show;

      //Print("1 History",hstTotal," show",show); 
             
      if(show < hstTotal) {   
         wd_storeLocal(event,"***** HISTORY *****"+ArraySize(wd_ncT));
         for(pos=show;pos<hstTotal;pos++) {
            if(OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY)==false) continue;
            //profit=OrderProfit();
            pip=NormalizeDouble(OrderOpenPrice()-OrderClosePrice(),Digits)/POINT;
            pe="";
            if(OrderType()==OP_BUY)
               pip=-pip;  
            else if(OrderType()!=OP_SELL) {
               pe="*";     // pending order
               pip=0;
            }
            summary=pe+OrderTicket()+"#"+TimeToStr(OrderOpenTime(),TIME_DATE|TIME_MINUTES)+"#"+type[OrderType()]+"#"+DoubleToStr(OrderLots(),LOTDIGITS)+"#"+OrderSymbol()+"#"+DoubleToStr(OrderOpenPrice(),Digits)+"#"+DoubleToStr(OrderStopLoss(),Digits)+"#"+DoubleToStr(OrderTakeProfit(),Digits)+"#"+DoubleToStr(OrderProfit(),LOTDIGITS)+"#"+pip;
            wd_storeLocal(event,summary);
         }
      }
   }
   
   wd_storeLocal(event,"***** SUMMARY *****");
   summary=StringConcatenate("TotalProfit:",totalprofit," TotalPips:",totalpips," Balance:",AccountBalance()," Equity:",AccountEquity()," FreeMargin:",AccountFreeMargin()," ",Symbol(),":",MarketInfo(Symbol(),MODE_BID));
   wd_storeLocal(event,summary);
}

void wd_storeLocal(int event, string buffer) {

   int cuecount=wds[event][WDS_CUECOUNT];

   if(cuecount<=WD_CUESIZE-1) {
      wd_message[event][cuecount]=buffer;
      wds[event][WDS_CUECOUNT]++;
   }   
   else
      wd_message[event][cuecount]="Out of buffer! Increase WD_CUESIZE";
}

void wd_processAction(int event, int mode) {

   int action=wdc[event][mode];

   //Print("SendMail event:" + event + "mode:" + mode + " action:" + action + " level:"+ wds[event][WDS_LEVEL]);
   
   if(action&WDA_MAIL==WDA_MAIL)       // Send mail
      wd_buildMailBody(event, mode);
   
   if(action&WDA_RESET==WDA_RESET)     // Reset
      wds[event][WDS_LEVEL]=0;   
}

void wd_buildMailBody(int event, int mode) {

   string modetxt="";
   //Print("even:",event," mode:",mode,"desc:",wd_eventDescription[event]);

   if(mode==WDC_NORMALACTION)
      modetxt="NORMAL";
   else if(mode==WDC_WARNINGACTION)
      modetxt="WARNING";
   else if(mode==WDC_CRITICALACTION)
      modetxt="CRITICAL";
      
   wd_mailBody = wd_mailBody + "--- "+ modetxt + ":" + wd_eventTitle[event] + " ---\r\n";
   int t=wds[event][WDS_CUECOUNT];

   for(int i=0;i<t;i++)
      wd_mailBody = wd_mailBody + wd_message[event][i] + "\r\n";
}

bool wd_searchLog(int &event, int bytesRead) {

   if(bytesRead>0) {
   
      string outBuffer="";
      int next=0;
      while(next>=0) {
               
         next=wd_findString(wd_fileBuffer,next,wd_match1[event],outBuffer,true);

         if(next>=0) {
            if( (StringFind(outBuffer,wd_match2[event])>=0) && (StringFind(outBuffer,wd_match3[event])>=0) && (wd_exclude[event]=="" || StringFind(outBuffer,wd_exclude[event])<0) ) {

               wd_endPos[event]=wd_logSize[event]-bytesRead+next;
               wd_storeLocal(event,outBuffer);                      
               wds[event][WDS_LEVEL]++;               // increment alert level 
            }   
         }                                                                     
      }
      event--;
      return(true);
   }
   else if(bytesRead==0) {                                      
      return(false);        // -> process next event
   }
   else if(bytesRead<0) {
      wds[WDE_ERROR][WDS_LEVEL]=2;               // set critical level      
      wd_storeLocal(WDE_ERROR,"File error! Event:" + wd_eventTitle[event]);
   }
   return (false);
}

// 
int wd_findString(string &buffer, int offset, string match, string &outBuffer, bool stripLine = false) {   

   int nextOffset=-1;
   outBuffer="";
   int msize=StringLen(match);
   int bsize=StringLen(buffer);
   int lineStart=0;
   int lineEnd=0;
   
   int pos=StringFind(buffer, match, offset);
   if(pos>=0) {
 
      if(pos+msize<bsize)
         nextOffset=(pos+msize);         
      else
         nextOffset=0;

      if(stripLine) {         
         if(nextOffset>0) {
            lineEnd=StringFind(buffer,"\r",nextOffset);
            if(lineEnd<0) {
               lineEnd=bsize+1;
               nextOffset=0;
            } 
            else
               nextOffset=lineEnd;
         }
         else
            lineEnd=bsize+1;  

         for(lineStart=pos;lineStart>=0;lineStart--) {
            if(StringGetChar(buffer,lineStart)==0xA)  // find \n
               break;
         }
         lineStart++;
         outBuffer=StringSubstr(buffer,lineStart,lineEnd-lineStart);         
      }
   }
   return (nextOffset);                     
}

int wd_refreshMT4Logs(int inx, string &path[],int &logSize[], int &logDate[], string &buffer, int woffset=0)
{   
   int currentSize=0;
   int offset=0;
   int read=0;
   int currentDate=TimeYear(TimeLocal())*10000+TimeMonth(TimeLocal())*100+TimeDay(TimeLocal());
   int fileSize=0;
   
   if(logDate[inx]==0)
      logDate[inx]=currentDate;

   string filename = path[inx] + logDate[inx] + ".log";
   
   //Print("reloadMT4Logs:",filename);
   
   if(GetFileAttributesA(filename)!=-1) {
   
      currentSize=wd_getFileSize(filename);
      //Print("FileSize=",currentSize);
      offset=logSize[inx];
      read=currentSize-logSize[inx];
   
      if(read>WD_BUFFER_SIZE)
         read = WD_BUFFER_SIZE;

      if(read>0) {
         if(woffset==0)
            buffer="";        // clean wd_fileBuffer

         if(read+logSize[inx]==currentSize)
            read=wd_readFile(filename, buffer, offset, read);
         else
            read=wd_readFile(filename, buffer, offset, read, true);

         if(read>=0) {         
            //Print("OK-Read:",filename," offset:",offset," read:",read);
            logSize[inx]=logSize[inx]+read;
         }
         else
            return (-1);
      }
   }


   //Print("date:",currentDate,":",logDate[inx]," logSize",logSize[inx],":",currentSize);
   // check next day log
   if(currentDate!=logDate[inx] && (logSize[inx]==currentSize || read==0) ) {    

        logSize[inx]=0;
        wd_endPos[inx]=0;
        logDate[inx]=currentDate;
        //wd_flushJournal();
        read=wd_refreshMT4Logs(inx, path, logSize, logDate, buffer, read);
        
        if(read<0 && woffset<=0)
            return (-1);
        else if(read<0)
            return (woffset);              
   }
      
   return (read+woffset);
}

int wd_getFileSize(string fileName) {
   
   int size=-1;
   int handle = _lopen(fileName,OF_READ);
   if(handle>0) {  
      size = _llseek(handle, 0, 2);   
      _lclose(handle);
   }
//   else {
//      int a=GetLastError();          // always 0 ???
//      Print(a);
//   }
   return(size);  
}

// readText file
int wd_readFile (string fileName, string &fileBuffer, int offset, int size=0, bool lf=false) {
   //Print("FileName: ",fileName," offset:",offset," size:",size);
   int bytesRead=-1;
   int handle = _lopen(fileName,OF_READ);
   if(handle>0) {  
      if(_llseek(handle,offset,0)>=0) {  
         int count=0;
         string _char=" ";
         int lfpos=0;
         while(_lread (handle,_char,1)>0 && (count<size || !size)) {
            fileBuffer=fileBuffer + _char;
            count++;

            if(_char=="\n")
               lfpos=count;  
         }
         if(lf==true && lfpos>0 && count>lfpos) {
            fileBuffer=StringSubstr(fileBuffer,0,lfpos);
            count=lfpos;
         }
         bytesRead=count;
      }
      _lclose(handle);
      return (bytesRead);
   }
}

bool wd_flushJournal() {
   if(wd_handle>0)
      return (SendMessageA( wd_handle, 0x0111, 33101, 0));
   return (false);
}

int wd_httpGET(string strUrl) {
  int hSession = InternetOpenA(AGENT, INTERNET_OPEN_TYPE_DIRECT, "0", "0", INTERNET_FLAG_ASYNC);
 
  InternetOpenUrlA(hSession, strUrl, "0", 0,
        INTERNET_FLAG_NO_CACHE_WRITE |
        INTERNET_FLAG_PRAGMA_NOCACHE |
        INTERNET_FLAG_RELOAD, 0);  

  return (hSession);
}

int getGreenwichMeanTime()
{
   int gmt[4];
   GetSystemTime(gmt);
   string nYear = gmt[0] & 0xFFFF;
   string nMonth = (gmt[0] >> 16)+100;
   string nDay = (gmt[1] >> 16)+100;
   string nHour = (gmt[2] & 0xFFFF)+100;
   string nMin = (gmt[2] >> 16)+100;
   string nSec = (gmt[3] & 0xFFFF)+100;
   return (StrToTime(nYear + "." + StringSubstr(nMonth,1) + "." + StringSubstr(nDay,1) + CharToStr(32) + StringSubstr(nHour,1) + ":" + StringSubstr(nMin,1)+ ":" +  StringSubstr(nSec,1) ));
}

bool isMarketClosed()
{
   int gmt = getGreenwichMeanTime();
   int dayOfweek = TimeDayOfWeek(gmt);
   int hour = TimeHour(gmt);

   if((dayOfweek==5 && hour >= 22) || dayOfweek>5 || (dayOfweek==0 && hour < 22))
      return (true);
   
   return (false);
}