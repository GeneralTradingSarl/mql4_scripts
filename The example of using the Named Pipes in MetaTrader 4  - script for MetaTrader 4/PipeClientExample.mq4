//+------------------------------------------------------------------+
//|                                            PipeClientExample.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   string str_client="PipeClient on MQL4 build 445";
   int    size_str=StringLen(str_client);
//--- wait for pipe server
   while(!IsStopped())
     {
      ExtPipe=FileOpen("\\\\.\\pipe\\MQL5.Pipe.Server",FILE_READ|FILE_WRITE|FILE_BIN);
      if(ExtPipe>=0)
         break;
      Sleep(250);
     }
   if(IsStopped())
      return(0);
   Print("Client: pipe opened");
   GetLastError();
//--- send welcome message
   FileWriteInteger(ExtPipe,size_str);
   if(FileWriteString(ExtPipe,str_client,size_str)<size_str)
     {
      Print("Client: send welcome message failed");
      return(0);
     }
   FileFlush(ExtPipe);
   FileSeek(ExtPipe,0,SEEK_SET);
//--- read data from server
   string str;
   int    value=0,size=0,last_error=0;
//--- read string
   size=FileReadInteger(ExtPipe);
   str=FileReadString(ExtPipe,size);
   if(GetLastError()!=0 || size!=StringLen(str))
     {
      Print("Client: read string failed");
      return;
     }
   Print("Server: ",str," received");
//--- read integer
   value=FileReadInteger(ExtPipe);
   last_error=GetLastError();
   if(last_error!=0)
     {
      Print("Client: read integer failed [",last_error,"]");
      return;
     }
   Print("Server: ",value," received"); 
//--- send data to server
   FileFlush(ExtPipe);
   FileSeek(ExtPipe,0,SEEK_SET);
//---- send string
   str="Test string";
   size_str=StringLen(str);
   FileWriteInteger(ExtPipe,size_str);
   if(FileWriteString(ExtPipe,str,size_str)<size_str)
     {
      Print("Client: send string failed");
      return(0);
     }
//---- send integer
   if(FileWriteInteger(ExtPipe,value)<4)
     {
      Print("Client: write integer failed [",GetLastError(),"]");
      return(0);
     }
//--- benchmark
   FileFlush(ExtPipe);
   FileSeek(ExtPipe,0,SEEK_SET);
//----
   double buffer[];
   double volume=0.0;
   int    array_size=1024*1024;

   if(ArrayResize(buffer,array_size)==array_size)
     {
      int ticks=GetTickCount();
      //--- read 8 Mb * 128 = 1024 Mb from server
      for(int i=0;i<128;i++)
        {
         if(!WaitForRead(ExtPipe,array_size))
            break;
         if(FileReadArray(ExtPipe,buffer,0,array_size)<array_size)
           {
            Print("Client: benchmark failed after ",volume/1024," Kb");
            break;
           }
         //--- check the data
         if(buffer[0]!=i || buffer[array_size-1]!=i+array_size-1)
           {
            Print("Client: benchmark invalid content");
            break;
           }
         volume+=array_size*8;
        }
      if(IsStopped())
         return(0);
      //---- send final confirmation
      FileFlush(ExtPipe);
      FileSeek(ExtPipe,0,SEEK_SET);
      value=12345;
      if(FileWriteInteger(ExtPipe,value)<4)
         Print("Client: benchmark confirmation failed ");     
      //--- show statistics
      ticks=GetTickCount()-ticks;
      if(ticks>0)
        {
         volume/=1024;
         Print("Client: ",DoubleToStr(volume/1024,0)," Mb sent in ",ticks," milliseconds at ",DoubleToStr(volume/ticks,2)," Mb per second");
        }
     }
//--- close pipe
   FileClose(ExtPipe);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|  ∆дем пока поступ€т данные в ожидаемом объеме                    |
//+------------------------------------------------------------------+
bool WaitForRead(int handle, int size)
  {
//----
   while(!IsStopped())
     {
      if(FileSize(handle)>=size)
         return(true);
      Sleep(1);
     }
//----
   return(false);
  }
//+------------------------------------------------------------------+

