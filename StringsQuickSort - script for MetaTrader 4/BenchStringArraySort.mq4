//+------------------------------------------------------------------+
//|                                              StringArraySort.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property stacksize 512000
//+------------------------------------------------------------------+
//| StringArray Sorting sample                                       |
//+------------------------------------------------------------------+
int start()
  {
   string text[100];          // array to sort
   string line;               // string for reading
   int    text_size=100;      // initial array size
   int    lines_read=0;       // realy read lines count
   int    file;               // file
   int    start,total;        // claculating times
   int    min,sec,hsec,tmp;   // for human time print
   int    i;
//---- opening text file
   file=FileOpen("list.txt",FILE_CSV|FILE_READ,0x7F);
   if(file<0)
     {
      Print("can\'t open list.txt for reading");
      return(0);
     }
//---- reading file to text array
   while(FileIsEnding(file)==false)
     {
      line=FileReadString(file);
      //---- when array size is less than need-grow it
      if(lines_read>=text_size)
        {
         ArrayResize(text,text_size+100);
         text_size+=100;
        }
//---- empty strings dropped
      if(StringLen(line)<1) continue;
      text[lines_read]=line;
      lines_read++;
     }
//----
   FileClose(file);
//---- now sort array
   start=GetTickCount();
   SortStrArrayRange(text,0,lines_read);
   //SortStrArray(text);
   total=GetTickCount()-start;
//---- converting timespan to human presentation
   min=total/60000;
   tmp=total%60000;
   sec=tmp/1000;
   hsec=tmp%1000;
//---- outpit results
   Print("Array sort time is ",min," min ",sec," sec ",hsec, " msec");
//---- write text array to file
   file=FileOpen("sorted_list.txt",FILE_CSV|FILE_WRITE);
   if(file<0)
     {
      Print("can\'t open sorted_list.txt for writing");
      return(0);
     }
//----
   for(i=0;i<lines_read;i++)
     FileWrite(file,text[i]);
//----
   FileClose(file);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| sorting range wraper                                             |
//+------------------------------------------------------------------+
void SortStrArrayRange(string& A[],int start,int count)
  {
   QSortStringArray(A,start,(start+count)-1);
  }
//+------------------------------------------------------------------+
//| main sorting function                                            |
//+------------------------------------------------------------------+
void QSortStringArray(string& A[],int low,int high)
  {
   string pivot, tmp;
   int    scan_forward, scan_back;
   int    middle;
//---- if elements to sort less than 2 - return.
   if(high-low<=0) return(0);
   else
     if(high-low==1)
       {
        //---- if count of elements to sort equal to 2 swap it if need
        if(A[high]<A[low])
          {
           tmp=A[low];
           A[low]=A[high];
           A[high]=tmp;
          }
        return(0);
       }
//---- calc middle element and store it in the pivot variable.
   middle=(low+high)/2;
   pivot=A[middle];
   //---- swap middle and first elements
   tmp=A[middle];
   A[middle]=A[low];
   A[low]=tmp;
//---- initializing scan_up and scan_down indexes
   scan_forward=low+1;
   scan_back=high;
//---- scan elements that places in opposite lists.
   while(scan_forward<scan_back)
     {
      //---- scan to forward. stop when crossing second list or current element greater than middle.
      while(scan_forward <= scan_back && A[scan_forward]<=pivot) scan_forward++;
      //---- scan to backward. stop when current element greater than or equal to middle.
      while(A[scan_back]>pivot) scan_back--;
      //---- if scan indexes not crossed they points to elements need to swap.
      if(scan_forward < scan_back)
        {
         tmp=A[scan_forward];
         A[scan_forward]=A[scan_back];
         A[scan_back]=tmp;
        }
     }
//---- swap first and dividing elements
   A[low] = A[scan_back];
//---- swap middle and dividing elements
   A[scan_back] = pivot;
//---- if first sublist has 2 or more elements sort it's too
   if(low < scan_back-1)   QSortStringArray(A, low, scan_back-1);
//---- if second sublist has 2 or more elements sort it's too
   if(scan_back+1 < high)  QSortStringArray(A, scan_back+1, high);
//---- that's all
   return(0);
  }
//+------------------------------------------------------------------+