//+------------------------------------------------------------------+
//|                                                 StateToGraph.mq4 |
//|                                                      Denis Orlov |
//|                                    http://denis-or-love.narod.ru |
/*
Графическое отображение стейтмента или "стейта" ( Statement ), 
т.е. перенос данных из таблицы на график, для удобства анализа и изучения.
Подробно:
http://codebase.mql4.com/ru/6127


Graphic displaing of the statement, 
carring of a data from the *.htm table to the graph, for convenience of the analysis.
and studying.
In detail:
http://codebase.mql4.com/6135

*/
//|На основе идеи Игоря Кима fromRepOnGraph.mq4 http://www.kimiv.ru  |
//+------------------------------------------------------------------+
#property copyright "Denis Orlov"
#property link      "http://denis-or-love.narod.ru"
#property show_inputs

#include <WinUser32.mqh>
#include <stdlib.mqh>//for ErrorDescription

#import "user32.dll"
    int RegisterWindowMessageA (string param);
#import
int      MT4InternalMsg=0;

#define LengthDateStr 16
#define Pr "StateToGraph: "

extern string FileName = "Statement.txt";
extern color BuyColor = Green;
extern color SellColor = Red;
extern color ProfitColor = Green;
extern color LossColor = Red;
extern color CancelledColor = Yellow;
extern bool DeletePrev = False;

datetime OpTime, ClTime;
string ticket, type, sym, lot;
double 
OpP,
SL,TP,
ClP,
profit;
datetime FirstOpTime=0;


bool Cancelled=False;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   
      int fname=FileOpen(FileName, FILE_BIN|FILE_READ);
  if (fname>0)
  {
      if(DeletePrev)Delete_My_Obj( Pr);
      
      string str;
      while (!FileIsEnding(fname))
      {
       str=GetStringFromFile(fname); 
       
       str=StringTrimRight( str) ;
       str=StringTrimLeft( str) ;
       
       while( StringFind( str, "  ")>-1 && StringLen(str)>10)
        str=StringReplace(str, "  ", " ");
       while( StringFind( str, "\t")>-1 && StringLen(str)>10)
        str=StringReplace(str, "\t", " ");
        
        
       if(StringLen(str)<70) continue;
       
       
       Cancelled=False;
        str=StringReplace(str, "buy stop", "buy_stop"); 
        str=StringReplace(str, "buy limit", "buy_limit");
        str=StringReplace(str, "sell stop", "sell_stop");
        str=StringReplace(str, "sell limit", "sell_limit");
       
        
        int pos=StringFind(str, " ");
         ticket=StringSubstr(str, 0, pos);
        
         str=StringSubstr(str, pos+1);/// отсекли ticket
         OpTime =StrToTime(StringSubstr(str, 0, LengthDateStr));
         if(FirstOpTime==0) FirstOpTime=OpTime;
        
        str=StringSubstr(str, LengthDateStr+1);//отсекли OpTime
         pos=StringFind(str, " ");
         type=StringSubstr(str, 0, pos);
         if(StringFind(type, "_")>-1)
            {
               Cancelled=True;
               //type=StringReplace(type,"_"," ");
            }
         type=fStrUpperCase(type);
        
        str=StringSubstr(str, pos+1);/// отсекли type
         pos=StringFind(str, " ");
         lot=StringSubstr(str, 0, pos);
        
        str=StringSubstr(str, pos+1);/// отсекли lot
         pos=StringFind(str, " ");
         sym=fStrUpperCase(StringSubstr(str, 0, pos));
        
        str=StringSubstr(str, pos+1);/// отсекли sym
         pos=StringFind(str, " ");
         OpP=StrToDouble(StringSubstr(str, 0, pos));
        
        str=StringSubstr(str, pos+1);/// отсекли OpP
         pos=StringFind(str, " ");
         SL=StrToDouble(StringSubstr(str, 0, pos));
        
        str=StringSubstr(str, pos+1);/// отсекли SL
         pos=StringFind(str, " ");
         TP=StrToDouble(StringSubstr(str, 0, pos));
        
        str=StringSubstr(str, pos+1);/// отсекли TP
         ClTime =StrToTime(StringSubstr(str, 0, LengthDateStr));
        
        str=StringSubstr(str, LengthDateStr+1);//отсекли ClTime
         pos=StringFind(str, " ");
         ClP=StrToDouble(StringSubstr(str, 0, pos));
         
         //Commission
         str=StringSubstr(str, pos+1);/// отсекли ClP
         pos=StringFind(str, " ");
         
         // Taxes 
          str=StringSubstr(str, pos+1);/// отсекли Commission
         pos=StringFind(str, " ");
         
          //Swap 
          str=StringSubstr(str, pos+1);/// отсекли Taxes
         pos=StringFind(str, " ");
         
          str=StringSubstr(str, pos+1);/// отсекли Swap
          profit=StrToDouble(StringReplace(str," ",""));
         // Comment("*"+DoubleToStr(profit,Digits)+"*"); 
         
        //Comment(sym+"; "+Symbol());
      if(Symbol()==sym)
         {
            DrawPos();
         }

       /* Comment(sym+"; "+
      "Open Time="+TimeToStr(OpTime)+"; Type="+type+
      "; Volume="+DoubleToStr(lot,2)+"; Price="+DoubleToStr(OpP,Digits)+
         "; S/L="+DoubleToStr(SL,Digits)+"; T/P="+DoubleToStr(TP,Digits)+
         "; Close Time="+TimeToStr(ClTime)+
         "; Price="+DoubleToStr(ClP,Digits)+";"
         );  Sleep(5000);*/
      }
       //
      //Comment("*"+StringReplace("123456789", "456", "000")+"*"); 
      
    FileClose(fname);
    if(FirstOpTime!=0)
    {
      int handle=WindowHandle(Symbol(),Period());
      MT4InternalMsg = RegisterWindowMessageA("MetaTrader4_Internal_Message");
      PostMessageA(handle,MT4InternalMsg,55,FirstOpTime-Period()*180);//
    }
    
    
  } 
  else 
  {
      int err=GetLastError();
      Comment("Ошибка открытия файла \""+FileName+"\"\n"+
               "Error of opening file ",err,": ",ErrorDescription(err));
  }
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
void DrawPos()
{
   string op=" opened ", cl=" closed ", prof=" / Profit: "+DoubleToStr(profit,2);
   double close_pr=ClP;
   
   if(ClP==TP)cl=cl+"by TakeProfit ";
   if(ClP==SL)cl=cl+"by StopLoss ";
   
   if(Cancelled) 
      {
         color Clr=CancelledColor, ClrOrd=CancelledColor; 
      op=" posed "; cl=" cancelled "; prof="";
      close_pr=OpP;
      } else
   if(profit<0)  Clr=LossColor; else Clr=ProfitColor;
   
   if(type=="BUY") ClrOrd=BuyColor; if(type=="SELL") ClrOrd=SellColor;
   
DrawArrows(Pr+"#"+ticket+" "+type+op+TimeToStr(OpTime), 
OpTime, OpP, 1, ClrOrd, 0, 
type+" "+lot+" at "+DoubleToStr(OpP,Digits)+
" S/L:"+DoubleToStr(SL,Digits)+" T/P:"+DoubleToStr(TP,Digits));

DrawArrows(Pr+"#"+ticket+" "+type+cl+TimeToStr(ClTime), //
ClTime, close_pr, 3, ClrOrd, 0, 
type+" "+lot+" "+cl+"at "+DoubleToStr(ClP,Digits)+prof);

if(SL>0)
DrawArrows(Pr+type+" #"+ticket+" S/L: "+DoubleToStr(SL,Digits), 
OpTime, SL, 4, Red, 0, "");

if(TP>0)
DrawArrows(Pr+type+" #"+ticket+" T/P: "+DoubleToStr(TP,Digits), 
OpTime, TP, 4, Blue, 0, "");
 
 string name=Pr+"#"+ticket+" "+DoubleToStr(OpP,Digits)+" --> "+DoubleToStr(ClP,Digits);
DrawTrends(name, 
OpTime, OpP, ClTime, close_pr, Clr, 1, "", false, 0);
ObjectSet(name, OBJPROP_STYLE, STYLE_DASH);
if(!Cancelled)
ObjectSetText(name, 
type+" "+lot+prof+" ( "+DoubleToStr(ClP-OpP,Digits)+" pts )");

}
//+----------------------------------------------------------------------------+
//|  Читает строковый блок из файла до знака переноса каретки #13#10           |
//|  Параметры:                                                                |
//|    fh - описатель открытого ранее файла                                                        |
//|                                            |
//+----------------------------------------------------------------------------+
string GetStringFromFile(int& fh)
{
  string str="", s;
  while (!FileIsEnding(fh))
  {
    s=FileReadString(fh, 1);
    int Ch=StringGetChar(s, 0);
    if (Ch!=13 && Ch!=10) str=str+s;
    else return(str);
  }
  return(str);
}
string StringReplace(string text, string oldstr, string newstr)
{
  int pos=StringFind(text, oldstr);
  if(pos>-1)
   { 
      string str=StringSubstr(text, 0, pos)+newstr+StringSubstr(text, pos+StringLen(oldstr));
      return(str);
   }
   return(text);
}
//-------------------------
string fStrUpperCase(string aString){
      for(int i=0;i<StringLen(aString);i++){
         int char=StringGetChar(aString,i);
            if(char>96){
               if(char<123){
                  aString=StringSetChar(aString,i,char-32);
                  continue;
               }  
            }    
            if(char>223){
               if(char<256){
                  aString=StringSetChar(aString,i,char-32);
                  continue;
               }
            }
            if(char==184){
               aString=StringSetChar(aString,i,168);
               continue;
            }               
      }
   return(aString);
}
//------------------------------------
int DrawArrows(string name, datetime T, double P, int code, color Clr=Green, int Win=0, string Text="")
   {
   if (name=="") name="Arrow_"+T;
   
     int Error=ObjectFind(name);// ?????? 
   if (Error!=Win)// ???? ??????? ? ??. ???? ??? :(
    {  
    ObjectCreate(name, OBJ_ARROW, Win, T, P);
    }
    
    ObjectSet(name, OBJPROP_ARROWCODE, code);//SYMBOL
    ObjectSet(name, OBJPROP_COLOR, Clr);
                        
   ObjectSet(name, OBJPROP_TIME1, T);//??? ???????????? ? ??????????
   ObjectSet(name, OBJPROP_PRICE1, P);
   ObjectSetText(name,Text);
   ObjectSet(name, OBJPROP_COLOR, Clr);
   }
//------------------------------------
int DrawTrends(string name, datetime T1, double P1, datetime T2, double P2, color Clr, int W=1, string Text="", bool ray=false, int Win=0)
   {
     int Error=ObjectFind(name);// ?????? 
   if (Error!=Win)// ???? ??????? ? ??. ???? ??? :(
    {  
      ObjectCreate(name, OBJ_TREND, Win,T1,P1,T2,P2);//???????? ????????? ?????
    }
     
    ObjectSet(name, OBJPROP_TIME1 ,T1);
    ObjectSet(name, OBJPROP_PRICE1,P1);
    ObjectSet(name, OBJPROP_TIME2 ,T2);
    ObjectSet(name, OBJPROP_PRICE2,P2);
    ObjectSet(name, OBJPROP_RAY , ray);
    ObjectSet(name, OBJPROP_COLOR , Clr);
    ObjectSet(name, OBJPROP_WIDTH , W);
    ObjectSetText(name,Text);
   // WindowRedraw();
   }  
void Delete_My_Obj(string Prefix)
   {//Alert(ObjectsTotal());
   for(int k=ObjectsTotal()-1; k>=0; k--)  // По количеству всех объектов 
     {
      string Obj_Name=ObjectName(k);   // Запрашиваем имя объекта
      string Head=StringSubstr(Obj_Name,0,StringLen(Prefix));// Извлекаем первые сим

      if (Head==Prefix)// Найден объект, ..
         {
         ObjectDelete(Obj_Name);
         //Alert(Head+";"+Prefix);
         }                
        
     }
   }