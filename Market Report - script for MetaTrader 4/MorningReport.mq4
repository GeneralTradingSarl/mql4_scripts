//+---------------------------------------------------------------------------------------------------+
//|                      Morning report                                                               |
//|                      Copyright © 2010, Thomas Quester.                                            |
//|                                        tquester@gmx.de                                            |
//|                                                                                                   |
//| Creates an overview of symbols and indicators                                                     |                                   
//|                                                                                                   |
//|                                                                                                   |
//|                                                                                                   |
//|I do custom mql4/mql5 programming at low prices.                                                   |
//|                                                                                                   |
//|                                                                                                   |
//|You may support the author by sending money to one of the following addresses, so I can continue   |
//|publishing my code for free                                                                        |
//|                                                                                                   |
//|  - Send money to PayPal:        tquester@gmx.de                                                   |
//|  - Send money to Moneybrokers:  tquester@gmx.de                                                   |
//|                                                                                                   |
//|    As a supporter, you receive updates of our code as some of the stuff we do not publish         |
//|                                                                                                   |
//| If you do not already have a broker, you may consider opening one of the following                |
//|  - Open an account at avafx and drop me a line with your user name. (you and I will receive a     |
//|    free bonus)                                                                                    |
//|                                                                                                   |
//+---------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2010, Thomas Quester"
#property link      "tquester@gmx.de"

#property show_confirm
#property show_inputs

extern int FastMA = 13;
extern int SlowMA = 50;
extern int Timeframe = PERIOD_D1;
string gCurrencies[200];

string gSymbols[200];
int    gcCurrencies,
       gcSymbols;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

void LoadSymbols()
{
   string str;
   int handle;
   int i,j;
   double ma;
   gcCurrencies = 0;
   gcSymbols = 0;
   handle = FileOpen("symbols.txt",FILE_READ," ");
   if (handle >= 0)
   {
      while (!FileIsEnding(handle))
      {
          str = FileReadString (handle,0);
          
          if (StringGetChar(str,0) == '*')
          {
              gCurrencies[gcCurrencies] = StringSubstr(str,1);
              gcCurrencies++;
          }
          else 
          {
              gSymbols[gcSymbols] = str;
              gcSymbols++;
          }
              
          
      }
      FileClose(handle);
   }
   
   for (i=0;i<gcCurrencies;i++)
   {
       for (j=0;j<gcCurrencies;j++)
       {
         if (i != j)
         {
             str = gCurrencies[i]+gCurrencies[j];
             
             ma = iMA(str,Timeframe,2,0,MODE_SMA,PRICE_MEDIAN,0);
            
             if (ma != 0)
             {
                 
                 gSymbols[gcSymbols] = str;
                 gcSymbols++;
             }
                 
         }
       }
   }
}

int  CreateHTML(string filename)
{
   int handle;
   handle = FileOpen(filename,FILE_WRITE," ");
   if (handle < 1) return (-1);
     FileWrite(handle,"<html>");
     FileWrite(handle,"");
     FileWrite(handle,"<head>");
     FileWrite(handle,"<meta http-equiv=\"Content-Language\" content=\"de\">");
     FileWrite(handle,"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1252}\">");
     FileWrite(handle,"<title>Neue Seite 1</title>");
     FileWrite(handle,"</head>");
     FileWrite(handle,"");
     FileWrite(handle,"<body>");
     FileWrite(handle,"");
     FileWrite(handle,"<h1>Market Overview</h1>");
     FileWrite(handle,"<table border=\"1\" width=\"100%\">");
     FileWrite(handle,"  <tr>");
     FileWrite(handle,"    <td width=\"5%\">Symbol</td>");
     FileWrite(handle,"    <td width=\"10%\">Price</td>");
     FileWrite(handle,"    <td width=\"10%\">MA "+FastMA+"</td>");
     FileWrite(handle,"    <td width=\"10%\">MA "+SlowMA+"</td>");
     FileWrite(handle,"    <td width=\"20%\">Cross "+FastMA+"/"+SlowMA+"</td>");
     FileWrite(handle,"    <td width=\"10%\">SAR</td>");
     FileWrite(handle,"  </tr>");
   return (handle);
}

void HTMLLine(int handle, string symbol, double price, string ema50, string ema200, string crossma, string sar)
{
     FileWrite(handle,"  <tr>");
     FileWrite(handle,"    <td width=\"5%\">"+symbol+"</td>");
     FileWrite(handle,"    <td width=\"10%\">"+price+"</td>");
     FileWrite(handle,"    <td width=\"10%\">"+ema50+"</td>");
     FileWrite(handle,"    <td width=\"10%\">"+ema200+"</td>");
     FileWrite(handle,"    <td width=\"20%\">"+crossma+"</td>");
     FileWrite(handle,"    <td width=\"10%\">"+sar+"</td>");
     FileWrite(handle,"  </tr>");

}

void HTMLClose(int handle)
{
     FileWrite(handle,"</table>");
     FileWrite(handle,"");
     FileWrite(handle,"</body>");
     FileWrite(handle,"");
     FileWrite(handle,"</html>");
}      

double sgn(double x)
{
   if (x < 0) return (-1);
   if (x > 0) return (1);
   return (0);
}

string IntToStr(int x)
{
   return (x);
}

int start()
  {
//----
   int i,j;
   LoadSymbols();
   int handle;
   handle = CreateHTML("report.htm");
   if (handle >= 0)
   {
      for (i=0;i<gcSymbols;i++)
      {
          string sym;
          
          double ma50,ma200,ma50b,ma200b,sar,price,pt,macd,macd2,macds;
          string strMa50, strMa200, strSar, strCross;
          pt = MarketInfo(sym,MODE_POINT);
          if (pt == 0)
             pt = Point;
          sym = gSymbols[i];
          Print("Report for "+sym," pt=",pt);
          if (pt != 0)
          {
            ma50 = iMA(sym,Timeframe,FastMA,0,MODE_SMA,PRICE_MEDIAN,0);
            if (ma50 != 0)
            {
               ma200 = iMA(sym,Timeframe,SlowMA,0,MODE_SMA,PRICE_MEDIAN,0);
               ma50b = iMA(sym,Timeframe,FastMA,0,MODE_SMA,PRICE_MEDIAN,2);
               ma200b = iMA(sym,Timeframe,SlowMA,0,MODE_SMA,PRICE_MEDIAN,2);
               sar   = iSAR(sym,Timeframe,0.02,0.2,0);
               price = iMA(sym,Timeframe,2,0,MODE_SMMA,PRICE_MEDIAN,0);
               int l=0;
               if (ma50b < ma50)   
               {  
                  l = 1;
                  strMa50  = "rising / "; 
               }
               else 
               {
                  l = -1;
                  strMa50  = "falling / ";
               }
               if (ma50 < price)   
               {
                  l++;
                  strMa50  = strMa50 + "below price"; 
               }
               else 
               {
                  l--;
                  strMa50 = strMa50 + "above price";
               }
               
               if (l == 2)  strMa50 = "<font color=\"#339933\">" + strMa50 + "</font>";
               if (l == -2) strMa50 = "<font color=\"#FF0000\">" + strMa50 + "</font>";
               
               l = 0;
               if (ma200b < ma200) 
               {
                  l = 1;
                  strMa200 = "rising / "; 
               }
               else 
               {
                  l = -1;
                  strMa200 = "falling / ";
               }
               
               if (ma200 < price)  
               {
                  l++;
                  strMa200 = strMa200 + "below price"; 
               }
               else 
               {
                 l--; strMa200 = strMa200 + "above price";
               }

               if (l == 2)  strMa200 = "<font color=\"#339933\">" + strMa200 + "</font>";
               if (l == -2) strMa200 = "<font color=\"#FF0000\">" + strMa200 + "</font>";

               if (sar < price) strSar = "long"; else strSar = "short";
            
               strCross = "";
               macd = ma50-ma200;
            
               macds = sgn(macd);
               for (j=1;j<500;j++)
               {
                  ma50 = iMA(sym,Timeframe,FastMA,0,MODE_SMA,PRICE_MEDIAN,j);
                  ma200 = iMA(sym,Timeframe,SlowMA,0,MODE_SMA,PRICE_MEDIAN,j);
                  macd2 = ma50-ma200;
              
                  if (macds != sgn(macd2))
                  {
                       strCross = j+" days ago ("+TimeToStr(Time[j],TIME_DATE )+" "+IntToStr(macd/pt)+" pips)";
                       break;
                  }
              }
              HTMLLine(handle,sym,price,strMa50,strMa200,strCross,strSar);
            }
         }
      }
   }
   HTMLClose(handle);
   FileClose(handle);
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+