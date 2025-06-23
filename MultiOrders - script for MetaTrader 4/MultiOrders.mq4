//+------------------------------------------------------------------+
//|                                                  MultiOrders.mq4 |
//|                                                             `Shu |
//|                                            http://SovetnikShu.ru |
//+------------------------------------------------------------------+
#property copyright "`Shu"
#property link      "http://SovetnikShu.ru"
// #property show_confirm
// #property show_inputs
#import "moo.dll"
  void ShowIn(double& Arr[]);
// #include <ShuLib.mq4>
extern int Magic=50005;
// #include <TF.mq4>
string shu=" [1.03] (c) `Shu [http://SovetnikShu.ru]";
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
  int start() 
  {
   int i;
   int t, tb, ts;
   int ssi;
   int f;
   int cmd;
   double d;
   double pr, sl, tp, lot;
   bool b;
   string s;
   string ss[5];
   string ord1[3];
   string ord[5][3];
   Print(WindowExpertName() + shu);
   //   if (false) { Qu(); QuTF(); }
   double Arr[5];
//----
   Arr[0]=1;
   Arr[1]=2;
   Arr[2]=3;
//----
   FileDelete("orders.txt");
   ShowIn(Arr);
   f=FileOpen("orders.txt", FILE_CSV|FILE_READ, "*");
//----
     if (f==-1) 
     {
      Alert("- не смогли открыть файл ордеров!");
      return(false);
     }
   ssi=0;
     while(!FileIsEnding(f)) 
     {
      s=FileReadString(f);
        if (s!="") 
        {
         ss[ssi]=s;
         ssi++;
        }
     }
   FileClose(f);
//----
     for(i=0; i < ssi; i++) 
     {
      Print(ss[i]);
      MassStr(ss[i], ";", ord1);
        if (ArraySize(ord1) < 3) 
        {
         // - если коммента вдруг нет. мало ли?
         ArrayResize(ord1, 3);
         ord1[2]="";
        }
      ord[i][0]=ord1[0];
      ord[i][1]=StrRep(ord1[1], ",", ".");
      ord[i][2]=ord1[2];
        if (MarketInfo(ord[i][0], MODE_POINT)==0) 
        {
         Print("Не могу получить информацию о символе " + ord[i][0] + ". Прекращаю работу!");
         return(false);
        }
     }
     for(i=0; i < ssi; i++) 
     {
      lot=StrToDouble(ord[i][1]);
      if (lot==0) continue;
      pr =iif(lot > 0, MarketInfo(ord[i][0], MODE_ASK), MarketInfo(ord[i][0], MODE_BID));
      cmd=iif(lot > 0, OP_BUY, OP_SELL);
      lot=MathAbs(lot);
      OrderSend(ord[i][0], cmd, lot, pr, 0, 0, 0, ord[i][2], Magic);
     }
//----
   return(0);
  }
// на входе:  строка с разделителями
// на выходе: массив строк
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int MassStr( string s, string Разделитель, string& mass[])
  {
   int i;
   int Нашли;
   string s1;
//----
   ArrayResize(mass, 100);
   Нашли=0;
     while( s!="")
     {
      i=StringFind( s, Разделитель, 0);
      if(i==-1)i=255;
      s1=StringTrimRight(StringTrimLeft(StringSubstr( s, 0, i)) );
      s=StringTrimRight(StringTrimLeft(StringSubstr( s, i+1, 255)));
      mass[Нашли]=s1;
      Нашли++;
     }
   ArrayResize(mass, Нашли);
//----
   return(Нашли);
  }
// условное назначение DOUBLE (!)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  double iif( bool Условие, double ПервоеЗначение, double ВтороеЗначение)
  {
   if (Условие)      return(ПервоеЗначение);
   else  return(ВтороеЗначение);
  }
  string StrRep(string s, string old, string new) 
  {
   string r;
//----
   int i;
   int iOld, iNew;
   int ii;
//----
   string ss;
   iOld=StringGetChar(old, 0);
   iNew=StringGetChar(new, 0);
//----
   r="";
   ss=" ";
     for(i=0; i < StringLen(s); i++) 
     {
      ii=StringGetChar(s, i);
        if (ii==iOld) 
        {
         ss=StringSetChar(ss, 0, iNew);
        }
        else 
        {
         ss=StringSetChar(ss, 0, ii);
        }
      r=r + ss;
     }
//----
   return(r);
  }
//+------------------------------------------------------------------+

