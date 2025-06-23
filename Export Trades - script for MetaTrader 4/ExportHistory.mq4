//+------------------------------------------------------------------+
//|                                                ExportHistory.mq4 |
//|                                 Copyright © 20101 Thomas Quester |
//|                                        http://www.mt4-expert.de/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 20101 Thomas Quester"
#property link      "http://www.mt4-expert.de/"

bool WantKomma=true;       // if Excel wants "," instead of "." for cent

//+------------------------------------------------------------------+
//| script program start function                                    |

//+------------------------------------------------------------------+

string typ2str(int typ)
{
   string r = "";
   if (typ == OP_BUY)  r = "buy";
   if (typ == OP_SELL) r = "sell";
   return (r);
 }

string p2str(double p, int digits)
{
   string s,r;
   s = DoubleToStr(p,digits);
   r = s;
   if (WantKomma)
   {
      p = StringFind(s,".",0);
   
      if (p != -1)
      {
         r = StringSubstr(s,0,p)+","+StringSubstr(s,p+1);
      }
   }
   return (r);
}
   
   
void SaveOrder(string title, int handle)
{
     int typ;
     typ = OrderType();
     if (typ == OP_BUY || typ == OP_SELL)
     {

         FileWrite(handle,
                  title,
                  typ2str(OrderType()),
                  TimeToStr(OrderOpenTime()),
                  OrderSymbol(),
                  OrderMagicNumber(),
                  p2str(OrderLots(),3),
                  p2str(OrderOpenPrice(),5),
                  p2str(OrderClosePrice(),5),
                  p2str(OrderProfit(),3),
                  OrderComment());
     }
 
}   
int start()
  {
//----
   int handle,cnt,i;
   cnt = OrdersHistoryTotal();
   handle = FileOpen("history.csv",FILE_WRITE|FILE_CSV);
   FileWrite(handle,"Opened/Closed","Type","Time and Date","Symbol","Magic Number","Lots","Open","Close","Profit","Comment");
   for (i=0;i<cnt;i++)
   {
       if (OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) == true)
       {
         SaveOrder("closed",handle);
       }
   }
   cnt = OrdersTotal();
   for (i=0;i<cnt;i++)
   {
       if (OrderSelect(i,SELECT_BY_POS, MODE_TRADES) == true)
       {
         SaveOrder("open",handle);
       }
   }
   FileClose(handle);
   
       
//----
   return(0);
  }
//+------------------------------------------------------------------+