//+------------------------------------------------------------------+
//|                                                 Expertoscope.mq4 |
//|                                                            Roger |
//|                                     http://www.rogerssignals.com |
//+------------------------------------------------------------------+
#property copyright "Roger"
#property link      "http://www.rogerssignals.com"
 
#property show_inputs
 
#import "kernel32.dll"
   int  FindFirstFileA(string path, int& answer[]);
   bool FindNextFileA(int handle, int& answer[]);
   bool FindClose(int handle);
   int _lopen  (string path, int of);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import
string filear[],param[][44]; 
 
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int win32_DATA[79];
   int num, i,ii,iii, cnt,pos,exp, flag,kol,xx;
   string filename=StringConcatenate(TerminalPath(),"\\profiles\\default\\");
   string word,head,end,sym,per;
   int handle = FindFirstFileA(filename+"*.chr",win32_DATA);
   if(handle!=-1)
      {
      ArrayResize(filear,1);
      filear[0]=bufferToString(win32_DATA);
      ArrayInitialize(win32_DATA,0);
      }
   num=2;
   while (FindNextFileA(handle,win32_DATA))
      {
      ArrayResize(filear,num);
      filear[num-1]=bufferToString(win32_DATA);
      ArrayInitialize(win32_DATA,0);
      num++;
      }
   num-=1;
   if (handle>0) FindClose(handle);
   for(i=0;i<num;i++)
      {//1
      handle=_lopen (filename+filear[i],0);   
      if (handle>=0)
         {//2 
         int result=_llseek (handle,0,0);      if (result<0) {Print ("Error in file seek" );}
         string buffer="";
         string char="x";
         int count=0;
         result=_lread (handle,char,1);
         while (result>0) 
            {//3
               buffer=buffer+char;
               char="x";
               count++;
               result=_lread (handle,char,1);
            }//3
         result=_lclose (handle);              
         if (result<0)  Print ("Error in file close ",filename);         
         }//2
      pos=0;flag=0;
      sym="";
      per="";
      for(cnt=0;cnt<StringLen(buffer);cnt++)
         {//2
         if(StringGetChar(buffer,cnt)==13)
            {//3
            word=StringSubstr(buffer,pos,cnt-pos);
            if(StringFind(word,"symbol=")!=-1&&cnt!=pos&&sym=="")sym=StringSubstr(word,7);
            if(StringFind(word,"period=")!=-1&&cnt!=pos&&per=="")per=StringSubstr(word,7);
            if(StringFind(word,"</window>")!=-1&&cnt!=pos)flag=1;
            if(StringFind(word,"<expert>")!=-1&&cnt!=pos&&flag==1)
               {//4
               exp++;
               ArrayResize(param,exp);
               for(cnt=cnt;cnt<StringLen(buffer);cnt++)
                  {//5
                  if(StringGetChar(buffer,cnt)==13)
                     {//6
                     word=StringSubstr(buffer,pos,cnt-pos);
                     if(StringSubstr(word,0,4)=="name")
                        {//7
                        param[exp-1][1]=StringSubstr(word,5);
                        param[exp-1][4]=sym;
                        param[exp-1][5]=per;
                        if(exp==1)
                           {//8
                           param[0][0]=0;
                           int basa[1]={1};
                           }//8
                        else
                           {//8
                           flag=0;
                           for(ii=0;ii<exp-1;ii++)
                              {//9
                              if(param[ii][1]==StringSubstr(word,5))
                                 {//10
                                 param[exp-1][0]=param[ii][0];
                                 basa[StrToInteger(param[exp-1][0])]=basa[StrToInteger(param[exp-1][0])]+1;
                                 flag=1;
                                 break;
                                 }//10
                              }//9
                           if(flag==0)
                              {//9
                              kol++;
                              ArrayResize(basa,kol+1);
                              basa[kol]=1;
                              param[exp-1][0]=kol;
                              //Print("kol - ",kol);
                              }//9
                           }//8   
                        }//7
                     if(StringSubstr(word,0,5)=="flags")
                        {//7
                        param[exp-1][2]=StringSubstr(word,6);
                        }//7
                     if(StringFind(word,"<inputs>")!=-1&&cnt!=pos)
                        {//7
                        xx=0;
                        for(cnt=cnt;cnt<StringLen(buffer);cnt++)
                           {//8
                           if(StringGetChar(buffer,cnt)==13)
                              {//9
                              word=StringSubstr(buffer,pos,cnt-pos);
                              for(iii=0;iii<StringLen(word);iii++)
                                 {//10
                                 if(CharToStr(StringGetChar(word,iii))=="=")
                                    {//11
                                    param[exp-1][6+xx]=StringSubstr(word,0,iii);
                                    param[exp-1][7+xx]=StringSubstr(word,iii+1);
                                    xx+=2;
                                    }//11
                                 }//10
                              if(StringFind(word,"</inputs>")!=-1)break;
                              pos=cnt+2;
                              }//9
                           }//8   
                        param[exp-1][3]=xx/2;
                        }//7
                     if(StringFind(word,"</inputs>")!=-1)break;
                     pos=cnt+2;
                     }//6
                  }//5
               break;   
               }//4
            pos=cnt+2;
            }//3
         }//2
      }//1
   head="<html><head><title>Experts List</title><style type=\"text/css\" media=\"screen\">td { font: 8pt Tahoma,Arial; }"+
   "</style></head><body topmargin=1 marginheight=1><div align=center><div style=\"font: 20pt Times New Roman\">"+
   "<b>Experts List</b></div><br>";  
   word="";
   for(i=0;i<=kol;i++)
      {
      int par=100;
      for (cnt=0;cnt<par;cnt++)
         {
         xx=0;
         for(ii=0;ii<exp;ii++)
            {
            if(StrToInteger(param[ii][0])!=i)continue;
            if(cnt==0)
               {
               if(xx==0)
                  {
                  par=StrToInteger(param[ii][3])*2+6;
                  word=StringConcatenate(word,"<div align=center><div style=\"font: 14pt Times New Roman\"><b>"+param[ii][1]+"</b></div><br>");
                  word=StringConcatenate(word,"<table cellspacing=1 cellpadding=3 border=1><tr align=left><td><b>Currency</b></td>");
                  }
               word=StringConcatenate(word,"<td><b>",param[ii][4],"</b></td>");              
               }
            if(cnt==1)
               {
               if(xx==0)
                  {
                  word=StringConcatenate(word,"<tr align=left><td><b>Period</b></td>");
                  }
               word=StringConcatenate(word,"<td><b>",param[ii][5],"</b></td>");            
               }  
            if(cnt==2)
               {
               if(xx==0)
                  {
                  word=StringConcatenate(word,"<tr align=left><td><b>Trade</b></td>");
                  }
               if(!DecToBin(StrToInteger(param[ii][2])))per="No";else per="Yes";
               word=StringConcatenate(word,"<td><b>",per,"</b></td>");          
               }  
            if(cnt==3||cnt==4||cnt==5)continue;
            if(cnt>5)
               {
               if(MathMod(cnt,2)*2==0)
                  {
                  if(xx==0)word=StringConcatenate(word,"<tr align=left><td><b>",param[ii][cnt],"</b></td>");
                  xx++;
                  continue;
                  }
               else word=StringConcatenate(word,"<td><b>",param[ii][cnt],"</b></td>");            
               }  
            xx++;
            }
         }   
      word=StringConcatenate(word,"</table><br>");
      }
   end="</body></html>";
   word=StringConcatenate(head,word,end);
   handle=FileOpen("Expert List.htm",FILE_WRITE);
   if(handle>0)FileWrite(handle,word);
   FileClose(handle);
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//|  read text from buffer                                           |
//+------------------------------------------------------------------+ 
string bufferToString(int buffer[])
   {
   string text="";
   
   int pos = 10;
   for (int i=0; i<64; i++)
      {
      pos++;
      int curr = buffer[pos];
      text = text + CharToStr(curr & 0x000000FF)
         +CharToStr(curr >> 8 & 0x000000FF)
         +CharToStr(curr >> 16 & 0x000000FF)
         +CharToStr(curr >> 24 & 0x000000FF);
      }
   return (text);
   }  
//+------------------------------------------------------------------+
bool DecToBin(int dec)
   {
   int ch,x=3;
   bool res;
   dec-=3;
   while(x>0)
      {
      ch=MathMod(dec,2);
      dec=MathFloor(dec/2);
      x--;
      }
   if(ch==0)res=false; else res=true;   
   return(res);
   }