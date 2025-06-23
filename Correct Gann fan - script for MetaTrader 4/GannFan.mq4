//+------------------------------------------------------------------+
//|                                                      GannFan.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, TheXpert"
#property link      "mqltech@gmail.com"

#property show_inputs

extern color DrawColor = Blue;
extern color MainColor = White;

extern int Width = 1;
extern int MainWidth = 3;

#define ID "GANN_FAN!"

int GetNextID()
{
   int maxid = 0;
   int idlen = StringLen(ID);
   
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string now = ObjectName(i);
      int pos = StringFind(now, ID);
      
      if (pos > 0)
      {
         int nowid = StrToInteger(StringSubstr(now, pos + idlen));
         if (nowid > maxid)
         {
            maxid = nowid;
         }
      }
   }
   maxid++;
   return (maxid);
}

int UNIQUE;
 
int start()
{
   int wnd = WindowOnDropped();
   double p = WindowPriceOnDropped();
   datetime t = WindowTimeOnDropped();
   
   double dp = (WindowPriceMax() - WindowPriceMin())/3.0;
   datetime dt = WindowBarsPerChart()*Period()*20; // *60(secs per minute)/3(times)

   if (wnd == 0 && p == 0 && t == 0)
   { // the script was called by doubleclick
      p = WindowPriceMin() + (WindowPriceMax() - WindowPriceMin())/3.0;
      t = Time[WindowFirstVisibleBar() - 2*WindowBarsPerChart()/3];
   }
   else
   {
      double cp = (WindowPriceMax() + WindowPriceMin())/2.0;
      
      if (p > cp)
      {
         dp = -dp;
      }
      
      datetime ct = Time[WindowFirstVisibleBar() - WindowBarsPerChart()/2];
      
      if (t > ct)
      {
         dt = -dt;
      }
   }
   
   UNIQUE = GetNextID();
   
   string UID = ID + UNIQUE;
   
   double p1 = p, p2 = p + dp;
   datetime t1 = t, t2 = t + dt;
   
   SetTrend("T11" + UID, wnd, t, p, t2, p2, MainColor, MainWidth);
   SetTrend("T12" + UID, wnd, t, p, t2, p + dp/2.0, DrawColor, Width);
   SetTrend("T13" + UID, wnd, t, p, t2, p + dp/3.0, DrawColor, Width);
   SetTrend("T14" + UID, wnd, t, p, t2, p + dp/4.0, DrawColor, Width);
   SetTrend("T18" + UID, wnd, t, p, t2, p + dp/8.0, DrawColor, Width);
   SetTrend("T21" + UID, wnd, t, p, t2, p + dp*2.0, DrawColor, Width);
   SetTrend("T31" + UID, wnd, t, p, t2, p + dp*3.0, DrawColor, Width);
   SetTrend("T41" + UID, wnd, t, p, t2, p + dp*4.0, DrawColor, Width);
   SetTrend("T81" + UID, wnd, t, p, t2, p + dp*8.0, DrawColor, Width);
   
   // start the cycle
   
   while(!IsStopped())
   {
      // if the main line is deleted
      
      double nowp1 = ObjectGet("T11" + UID, OBJPROP_PRICE1);
      
      int err = GetLastError();
      if (err == 4202)
      {
         WindowRedraw();
         break;
      }
      
      double nowp2 = ObjectGet("T11" + UID, OBJPROP_PRICE2);
      double nowt1 = ObjectGet("T11" + UID, OBJPROP_TIME1);
      double nowt2 = ObjectGet("T11" + UID, OBJPROP_TIME2);
      
      SetTrend("T12" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/2.0, DrawColor, Width);
      SetTrend("T13" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/3.0, DrawColor, Width);
      SetTrend("T14" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/4.0, DrawColor, Width);
      SetTrend("T18" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)/8.0, DrawColor, Width);
      SetTrend("T21" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*2.0, DrawColor, Width);
      SetTrend("T31" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*3.0, DrawColor, Width);
      SetTrend("T41" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*4.0, DrawColor, Width);
      SetTrend("T81" + UID, wnd, nowt1, nowp1, nowt2, nowp1 + (nowp2 - nowp1)*8.0, DrawColor, Width);
      
      p1 = nowp1;
      p2 = nowp2;
      t1 = nowt1;
      t2 = nowt2;
      
      WindowRedraw();
      Sleep(50);
   }
   
   SetTrend("T11" + UID, wnd, t1, p1, t2, p2, DrawColor, Width);
   SetTrend("T12" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/2.0, DrawColor, Width);
   SetTrend("T13" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/3.0, DrawColor, Width);
   SetTrend("T14" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/4.0, DrawColor, Width);
   SetTrend("T18" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)/8.0, DrawColor, Width);
   SetTrend("T21" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*2.0, DrawColor, Width);
   SetTrend("T31" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*3.0, DrawColor, Width);
   SetTrend("T41" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*4.0, DrawColor, Width);
   SetTrend("T81" + UID, wnd, t1, p1, t2, p1 + (p2 - p1)*8.0, DrawColor, Width);
   
   MessageBox("Gann fan was built successfully", "Done!");

   return (0);
}

void SetTrend(string name, int window, datetime t1, double price1, datetime t2, double price2, color clr = Gold, int width = 1)
{
   ObjectCreate(name, OBJ_TREND, window, t1, price1, t2, price2);
   
   ObjectSet(name, OBJPROP_CORNER, 0);
   ObjectSet(name, OBJPROP_RAY, 1);
   ObjectSet(name, OBJPROP_COLOR, clr);
   
   ObjectSet(name, OBJPROP_WIDTH, width);
   ObjectSet(name, OBJPROP_TIME1, t1);
   ObjectSet(name, OBJPROP_TIME2, t2);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
}