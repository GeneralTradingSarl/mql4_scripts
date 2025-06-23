//+------------------------------------------------------------------+
//|                                                   StepByStep.mq4 |
//|                                              Viatcheslav Suvorov |
//+------------------------------------------------------------------+
#property copyright "Viatcheslav Suvorov"
#property show_inputs
#include <WinUser32.mqh>

#import "IdleLib.dll"
int GetLastKeyWP();
int IdleLibInit();
int IdleLibUnInit();
string GetActiveWndName();
#import

extern datetime startdate=0;//дата и время начала эмуляции
extern string instruments="EURUSD GBPUSD";//инструменты эмуляции, например "EURUSD GBPUSD USDJPY"
extern string minperiod="M5";

datetime  minTime;
datetime  maxTime;
int     LastShift[100];
int     Handles[100];
int     HandlesPeriod[100];
string  NameOfHandles[100];
int     CountHandle;
datetime EmulationTime=0;
int mytimeframe[];

void AddData(int minutes)
{
  int oldTime=EmulationTime;
  EmulationTime=EmulationTime+minutes*60; 
  bool holy=false;
  if (TimeDayOfWeek(EmulationTime)==0 || TimeDayOfWeek(EmulationTime)==6){
    while ((EmulationTime<maxTime) && (TimeDayOfWeek(EmulationTime)==0 || TimeDayOfWeek(EmulationTime)==6)) EmulationTime++;
    EmulationTime=EmulationTime+3600;    
    holy=true;
  }//   
  for (int i=1;i<=CountHandle;i++){    
    int shift=iBarShift(NameOfHandles[i],HandlesPeriod[i]-1,EmulationTime);     
    if (LastShift[i]>0) int shift1=LastShift[i]; else
      shift1=iBarShift(NameOfHandles[i],HandlesPeriod[i]-1,oldTime);              
    if ((shift!=-1) && (shift1!=-1)){       
      for (int j=shift1-1;j>shift;j--){                
         LastShift[i]=j;
         FileWriteInteger(Handles[i], iTime(NameOfHandles[i],HandlesPeriod[i]-1,j), LONG_VALUE);
         FileWriteDouble(Handles[i], iOpen(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iLow(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iHigh(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iClose(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iVolume(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);        
      }//for
   // if (minutes<HandlesPeriod[i]-1){
    if (HandlesPeriod[i]-1>mytimeframe[0]){
      datetime timeLastBar=iTime(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1); 
      int sh1=iBarShift(NameOfHandles[i],mytimeframe[0],timeLastBar);
            
      int sh2=iBarShift(NameOfHandles[i],mytimeframe[0],EmulationTime)+1;
      if (sh1-sh2==0) int delt=1; else  delt=sh1-sh2+1;
      

      if ((sh1<0) || (sh2<0)){
        double h1=iHigh(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1);
        double l1=iLow(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1);            
      } else {              
        h1=iHigh(NameOfHandles[i],mytimeframe[0],Highest(NameOfHandles[i],mytimeframe[0],MODE_HIGH,delt,sh2));
        l1=iLow(NameOfHandles[i],mytimeframe[0],Lowest(NameOfHandles[i],mytimeframe[0],MODE_LOW,delt,sh2));            
      }
      double o1=iOpen(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1);
      double c1=iClose(NameOfHandles[i],mytimeframe[0],sh2);
      if ((o1>h1) || (o1<l1) || (c1>h1) || (c1<l1)) {
        h1=MathMax(h1,MathMax(o1,c1));
        l1=MathMin(l1,MathMin(o1,c1));
      }  
      
      if (EmulationTime>=timeLastBar+HandlesPeriod[i]-1){                        
         int LastFPos=FileTell(Handles[i]);
         FileWriteInteger(Handles[i], iTime(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1), LONG_VALUE);
         FileWriteDouble(Handles[i], o1, DOUBLE_VALUE);
         FileWriteDouble(Handles[i], l1, DOUBLE_VALUE);
         FileWriteDouble(Handles[i], h1, DOUBLE_VALUE);
         FileWriteDouble(Handles[i], c1, DOUBLE_VALUE);         
         FileWriteDouble(Handles[i],iVolume(NameOfHandles[i],HandlesPeriod[i]-1,LastShift[i]-1), DOUBLE_VALUE);                         
         FileSeek(Handles[i],LastFPos,SEEK_SET);         
      }     
    }//if  
      FileFlush(Handles[i]);
      int hwnd=WindowHandle("t_"+NameOfHandles[i],HandlesPeriod[i]);        
      if(hwnd!=0) PostMessageA(hwnd,WM_COMMAND,33324,0);                              
    }//if
  }//for  
}
void BuildHistoryToDateTime()
{
  if (EmulationTime==0) EmulationTime=startdate;
  if (EmulationTime<minTime) EmulationTime=minTime;
  if (EmulationTime>maxTime) EmulationTime=minTime;
  for (int i=1;i<=CountHandle;i++){
    int shift=iBarShift(NameOfHandles[i],HandlesPeriod[i]-1,EmulationTime);          
    if (shift!=-1) {      
      for (int j=iBars(NameOfHandles[i],HandlesPeriod[i]-1);j>shift;j--){
         LastShift[i]=j;
         FileWriteInteger(Handles[i], iTime(NameOfHandles[i],HandlesPeriod[i]-1,j), LONG_VALUE);
         FileWriteDouble(Handles[i], iOpen(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iLow(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iHigh(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iClose(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);
         FileWriteDouble(Handles[i], iVolume(NameOfHandles[i],HandlesPeriod[i]-1,j), DOUBLE_VALUE);        
      }//for
      FileFlush(Handles[i]);
      int hwnd=WindowHandle("t_"+NameOfHandles[i],HandlesPeriod[i]);        
      if(hwnd!=0) PostMessageA(hwnd,WM_COMMAND,33324,0);                              
    }//if
  }//for
}
void InitAllHistory()
{  
  int pos=0;
  string curstr="";
  bool sign=true;
  CountHandle=0;
  int    i_unused[13];
  ArrayInitialize(Handles,0);
  ArrayInitialize(HandlesPeriod,0);     
  ArrayInitialize(LastShift,0);  
     
  while (sign) {
    if (pos>StringLen(instruments))  sign=false; else {
      int curchar=StringGetChar(instruments,pos);
      if ((curchar==' ') || (pos==StringLen(instruments))) { 
        Print("Распознал имя ",curstr);
        for (int i=0;i<ArraySize(mytimeframe);i++){     
          int modifyTF=mytimeframe[i]+1;
          int ExtHandle=FileOpenHistory("t_"+curstr+modifyTF+".hst", FILE_BIN|FILE_WRITE);   
          if (ExtHandle>0) {          
            CountHandle++;
            Handles[CountHandle]=ExtHandle;
            HandlesPeriod[CountHandle]=modifyTF;
            NameOfHandles[CountHandle]=curstr;          
               FileSeek(Handles[CountHandle],0,SEEK_SET);           
               FileWriteInteger(Handles[CountHandle], 400, LONG_VALUE);
               FileWriteString(Handles[CountHandle],"(C)opyright 2003, MetaQuotes Software Corp.", 64);
               FileWriteString(Handles[CountHandle], "t_"+curstr, 12);
               FileWriteInteger(Handles[CountHandle], modifyTF, LONG_VALUE);
               FileWriteInteger(Handles[CountHandle], MarketInfo(curstr,MODE_DIGITS), LONG_VALUE);
               FileWriteInteger(Handles[CountHandle], 0, LONG_VALUE);      
               FileWriteInteger(Handles[CountHandle], 0, LONG_VALUE);       
               FileWriteArray(Handles[CountHandle], i_unused, 0, 13);               
          }//if            
        }//for
        curstr="";
      } else curstr=curstr+CharToStr(curchar);
    }//else  
    pos++;
  }//while 
}//InitAllHistory

int start()
  {
   if (minperiod=="M1") {
     ArrayResize(mytimeframe,8); 
     mytimeframe[0]=1;mytimeframe[1]=5;mytimeframe[2]=15;mytimeframe[3]=30;mytimeframe[4]=60;mytimeframe[5]=240;mytimeframe[6]=1440;mytimeframe[7]=10080;     
   } else if (minperiod=="M5") {
     ArrayResize(mytimeframe,7); 
     mytimeframe[0]=5;mytimeframe[1]=15;mytimeframe[2]=30;mytimeframe[3]=60;mytimeframe[4]=240;mytimeframe[5]=1440;mytimeframe[6]=10080;          
   } else if (minperiod=="M15") {
     ArrayResize(mytimeframe,6); 
     mytimeframe[0]=15;mytimeframe[1]=30;mytimeframe[2]=60;mytimeframe[3]=240;mytimeframe[4]=1440;mytimeframe[5]=10080; 
   } else if (minperiod=="M30") {
     ArrayResize(mytimeframe,5);    
     mytimeframe[0]=30;mytimeframe[1]=60;mytimeframe[2]=240;mytimeframe[3]=1440;mytimeframe[4]=10080;     
   } else if (minperiod=="H1") {
     ArrayResize(mytimeframe,4);    
     mytimeframe[0]=60;mytimeframe[1]=240;mytimeframe[2]=1440;mytimeframe[3]=10080;     
   } else if (minperiod=="H4") {
     ArrayResize(mytimeframe,3);    
     mytimeframe[0]=240;mytimeframe[1]=1440;mytimeframe[2]=10080;     
   } else if (minperiod=="D1") {
     ArrayResize(mytimeframe,2);    
     mytimeframe[0]=1440;mytimeframe[1]=10080;     
   } else if (minperiod=="W1") {
     ArrayResize(mytimeframe,1);    
     mytimeframe[0]=10080;     
   } else {
     Print("Неправильный минималтьный TF");
     return(-1);
   }
   IdleLibInit();//инициализируем Dll
   InitAllHistory();
   minTime=iTime(NameOfHandles[1],HandlesPeriod[1]-1,iBars(NameOfHandles[1],HandlesPeriod[1]-1)-1); 
   maxTime=iTime(NameOfHandles[1],HandlesPeriod[1]-1,0);   
   //Print("minTime=",TimeYear(minTime)," ",TimeMonth(minTime)," ",TimeDay(minTime));
    
   BuildHistoryToDateTime();      

         bool NeedLoop=true;int tick=0;
         while(NeedLoop){            
           int lastkey=GetLastKeyWP();           
           string lastwnd=GetActiveWndName();
           if ((lastkey==102) && (lastwnd!="")) {            
             if (StringFind(lastwnd,"M10081",0)>0) AddData(10080); else
             if (StringFind(lastwnd,"M1441",0)>0) AddData(1440); else               
             if (StringFind(lastwnd,"M241",0)>0) AddData(240); else 
             if (StringFind(lastwnd,"M61",0)>0) AddData(60); else 
             if (StringFind(lastwnd,"M31",0)>0) AddData(30); else 
             if (StringFind(lastwnd,"M16",0)>0) AddData(15); else 
             if (StringFind(lastwnd,"M6",0)>0) AddData(5); else 
             if (StringFind(lastwnd,"M2",0)>0) AddData(1);
             if (EmulationTime>=maxTime) NeedLoop=false;
           }//if  

           Sleep(100);
           tick++;
           if (tick>=20){
             for (int i=1;i<=CountHandle;i++){
               tick=0;
               int hwnd=WindowHandle("t_"+NameOfHandles[i],HandlesPeriod[i]);        
               if(hwnd!=0) PostMessageA(hwnd,WM_COMMAND,33324,0);                                           
             }//for  
            }//if  
         }//while                
              
   IdleLibUnInit();
   return(0);
  }//start

void deinit()
  { 
    for (int i=1;i<=CountHandle;i++){ 
      if(Handles[i]>=0) FileClose(Handles[i]);
    }  
  }//deinit()

