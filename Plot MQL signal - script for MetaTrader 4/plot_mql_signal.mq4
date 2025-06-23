//+------------------------------------------------------------------+
//|                                      Plot MQL signal history.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Irwan Adnan, Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs 

input int timeshift=0;
input string filename="";

int
type,
filehandle,
i=0;

string
header,
symbol,
typ,
comment;

double
lot,
openprice,
closeprice,
commission,
swap,
profit,
sl,
tp;

datetime
opentime,
closetime;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   filehandle=FileOpen(filename+".csv",FILE_CSV|FILE_READ|FILE_SHARE_READ);

   if(filehandle!=INVALID_HANDLE)
     {
      //header = FileReadString(filehandle);

      while(!FileIsEnding(filehandle))
        {
         opentime    = StrToTime(FileReadString(filehandle));
         typ         = FileReadString(filehandle);
         lot         = StrToDouble(FileReadString(filehandle));
         symbol      = FileReadString(filehandle);
         openprice   = StrToDouble(FileReadString(filehandle));
         sl          = StrToDouble(FileReadString(filehandle));
         tp          = StrToDouble(FileReadString(filehandle));
         closetime   = StrToTime(FileReadString(filehandle));
         closeprice   = StrToDouble(FileReadString(filehandle));
         commission   = StrToDouble(FileReadString(filehandle));
         swap         = StrToDouble(FileReadString(filehandle));
         profit      = StrToDouble(FileReadString(filehandle));
         comment     = FileReadString(filehandle);

         if(typ=="Buy")type=0;
         else if(typ=="Sell")type = 1;
         else if(typ=="Buy Limit")type = 2;
         else if(typ=="Sell Limit")type = 3;
         else if(typ=="Buy Stop")type = 4;
         else if(typ=="Sell Stop")type = 5;

         Print(opentime,";",type,";",lot,";",symbol,";",openprice,";",sl,";",
               tp,";",closetime,";",closeprice,";",commission,";",swap,";",profit,";",comment);

         string open="open"+TimeToStr(opentime);
         string close= "close"+TimeToStr(closetime);
         string tren = "tren"+TimeToStr(opentime);

         if(StringFind(symbol,_Symbol)!=-1 || StringFind(_Symbol,symbol)!=-1)
           {
            ObjectCreate(open,OBJ_ARROW_BUY,0,opentime-timeshift*3600,openprice);
            ObjectSet(open,OBJPROP_ARROWCODE,2);
            ObjectSetText(open,DoubleToStr(lot)+" lot",10,NULL,clrNONE);

            ObjectCreate(close,OBJ_ARROW_BUY,0,closetime-timeshift*3600,closeprice);
            ObjectSet(close,OBJPROP_ARROWCODE,3);
            string pip=DoubleToStr(MathAbs(openprice-closeprice)/_Point,0)+" pips";
            ObjectSetText(close,pip,10,NULL,clrNONE);

            ObjectCreate(tren,OBJ_TREND,0,opentime-timeshift*3600,openprice,closetime-timeshift*3600,closeprice);
            ObjectSet(tren,OBJPROP_RAY,0);
            ObjectSet(tren,OBJPROP_STYLE,1);

            if(type==0)
              {
               ObjectSet(open,OBJPROP_COLOR,clrGreen);
               ObjectSet(close,OBJPROP_COLOR,clrGreen);
               ObjectSet(tren,OBJPROP_COLOR,clrGreen);
              }
            else if(type==1)
              {
               ObjectSet(open,OBJPROP_COLOR,clrRed);
               ObjectSet(close,OBJPROP_COLOR,clrRed);
               ObjectSet(tren,OBJPROP_COLOR,clrRed);
              }
           }
        }

      FileClose(filehandle);
     }
  }
//+------------------------------------------------------------------+
