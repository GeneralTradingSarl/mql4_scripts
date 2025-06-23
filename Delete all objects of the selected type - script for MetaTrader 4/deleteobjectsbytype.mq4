//+------------------------------------------------------------------+
//|                                          DeleteObjectsByType.mq4 |
//|                       Copyright 2015, ForexTradingAutomation.com |
//|                                http://ForexTradingAutomation.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, ForexTradingAutomation.com"
#property link      "http://ForexTradingAutomation.com"
#property version   "1.00"
#property strict
#property show_inputs 


input bool DeleteObjectsOnAllCharts=true; // Delete objects on all charts (false-only on current chart)
input bool DeleteAllObjects=false;    // Delete all objects
sinput string H1="----- Lines and trends -----"; // "----- Lines and trends -----"
input bool Delete_OBJ_VLINE         = false;    // Delete Vertical Line objects
input bool Delete_OBJ_HLINE         = false;    // Delete Horizontal Line objects
input bool Delete_OBJ_TREND         = false;    // Delete Trend Line objects
input bool Delete_OBJ_TRENDBYANGLE  = false;    // Delete Trend Line By Angle objects
input bool Delete_OBJ_CYCLES        = false;    // Delete Cycle Lines objects

sinput string H2="----- Channels and Gann objects -----"; // "----- Channels and Gann objects  -----"
input bool Delete_OBJ_CHANNEL       = false;    // Delete Equidistant Channel objects
input bool Delete_OBJ_STDDEVCHANNEL = false;    // Delete Standard Deviation Channel objects
input bool Delete_OBJ_REGRESSION    = false;    // Delete Linear Regression Channel objects
input bool Delete_OBJ_PITCHFORK     = false;    // Delete Andrews’ Pitchfork objects
input bool Delete_OBJ_GANNLINE      = false;    // Delete Gann Line objects
input bool Delete_OBJ_GANNFAN       = false;    // Delete Gann Fan objects
input bool Delete_OBJ_GANNGRID      = false;    // Delete Gann Grid objects

sinput string H5="----- Fibonacci objects -----"; // "----- Fibonacci objects -----"
input bool Delete_OBJ_FIBO          = false;    // Delete Fibonacci Retracement
input bool Delete_OBJ_FIBOTIMES     = false;    // Delete Fibonacci Time Zones
input bool Delete_OBJ_FIBOFAN       = false;    // Delete Fibonacci Fan
input bool Delete_OBJ_FIBOARC       = false;    // Delete Fibonacci Arcs
input bool Delete_OBJ_FIBOCHANNEL   = false;    // Delete Fibonacci Channel
input bool Delete_OBJ_EXPANSION     = false;    // Delete Fibonacci Expansion

sinput string H6="----- Shape objects -----"; // "----- Shape objects -----" 
input bool Delete_OBJ_RECTANGLE     = false;    // Delete Rectangle objects
input bool Delete_OBJ_TRIANGLE      = false;    // Delete Triangle objects
input bool Delete_OBJ_ELLIPSE       = false;    // Delete Ellipse objects

sinput string H7="----- Arrow and sign objects -----"; // "----- Arrow and sign objects -----" 
/*
input bool Delete_OBJ_ARROW_THUMB_UP   = false;    // Delete Thumbs Up objects
input bool Delete_OBJ_ARROW_THUMB_DOWN = false;    // Delete Thumbs Down objects
input bool Delete_OBJ_ARROW_UP         = false;    // Delete Arrow Up objects
input bool Delete_OBJ_ARROW_DOWN       = false;    // Delete Arrow Down objects
input bool Delete_OBJ_ARROW_STOP       = false;    // Delete Stop Sign objects
input bool Delete_OBJ_ARROW_CHECK      = false;    // Delete Check Sign objects
input bool Delete_OBJ_ARROW_LEFT_PRICE = false;    // Delete Left Price Label objects
input bool Delete_OBJ_ARROW_RIGHT_PRICE= false;    // Delete Right Price Label objects
input bool Delete_OBJ_ARROW_BUY        = false;    // Delete Buy Sign objects
input bool Delete_OBJ_ARROW_SELL       = false;    // Delete Sell Sign objects
*/
input bool Delete_OBJ_ARROW=false;    // Delete Arrow objects

sinput string H8="----- Text and label objects -----"; // "----- Text and label objects -----" 
input bool Delete_OBJ_TEXT          = false;    // Delete Text objects
input bool Delete_OBJ_LABEL         = false;    // Delete Label objects

sinput string H9="----- User interface objects -----"; // "----- User interface objects -----" 

input bool Delete_OBJ_BUTTON        = false;    // Delete Button objects
input bool Delete_OBJ_BITMAP        = false;    // Delete Bitmap objects
input bool Delete_OBJ_BITMAP_LABEL  = false;    // Delete Bitmap Label objects
input bool Delete_OBJ_EDIT          = false;    // Delete Edit objects
input bool Delete_OBJ_EVENT         = false;    // Delete The "Event" object corresponding to an event in the economic calendar
input bool Delete_OBJ_RECTANGLE_LABEL=false;    // Delete The "Rectangle label" object for creating and designing the custom graphical interface.




int deleted=0;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int chartCount=0;
   if(DeleteObjectsOnAllCharts)
     {
      long currChart;
      long prevChart=ChartFirst();
      DeleteObjectsOnChart(prevChart);
      chartCount++;
      // Loop through charts
      while(true)
        {
         // Get next chart
         currChart=ChartNext(prevChart);
         // If currChart < 0 ==> we iterated through all charts, exit loop
         if(currChart<0)
            break;
         DeleteObjectsOnChart(currChart);
         chartCount++;
         prevChart=currChart;
        }
     }
   else
     {
      // Delete objects only on current chart
      DeleteObjectsOnChart(ChartID());
      chartCount++;
     }
   PrintFormat("Deleted %d objects on %d charts",deleted,chartCount);
  }
//+------------------------------------------------------------------+

void DeleteObjectsOnChart(long chartId)
  {
   if(DeleteAllObjects)
     {
      deleted+=ObjectsDeleteAll(chartId);
      return;
     }

   if(Delete_OBJ_VLINE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_VLINE);

   if(Delete_OBJ_HLINE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_HLINE);

   if(Delete_OBJ_TREND)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_TREND);

   if(Delete_OBJ_TRENDBYANGLE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_TRENDBYANGLE);

   if(Delete_OBJ_CYCLES)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_CYCLES);

   if(Delete_OBJ_CHANNEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_CHANNEL);

   if(Delete_OBJ_STDDEVCHANNEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_STDDEVCHANNEL);

   if(Delete_OBJ_REGRESSION)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_REGRESSION);

   if(Delete_OBJ_PITCHFORK)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_PITCHFORK);

   if(Delete_OBJ_GANNLINE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_GANNLINE);

   if(Delete_OBJ_GANNFAN)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_GANNFAN);

   if(Delete_OBJ_GANNGRID)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_GANNGRID);

   if(Delete_OBJ_FIBO)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_FIBO);

   if(Delete_OBJ_FIBOTIMES)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_FIBOTIMES);

   if(Delete_OBJ_FIBOFAN)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_FIBOFAN);

   if(Delete_OBJ_FIBOARC)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_FIBOARC);

   if(Delete_OBJ_FIBOCHANNEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_FIBOCHANNEL);

   if(Delete_OBJ_EXPANSION)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_EXPANSION);

   if(Delete_OBJ_RECTANGLE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_RECTANGLE);

   if(Delete_OBJ_TRIANGLE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_TRIANGLE);

   if(Delete_OBJ_ELLIPSE)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_ELLIPSE);
/*   
   if(Delete_OBJ_ARROW_THUMB_UP)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_THUMB_UP);

   if(Delete_OBJ_ARROW_THUMB_DOWN)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_THUMB_DOWN);

   if(Delete_OBJ_ARROW_UP)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_UP);

   if(Delete_OBJ_ARROW_DOWN)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_DOWN);

   if(Delete_OBJ_ARROW_STOP)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_STOP);

   if(Delete_OBJ_ARROW_CHECK)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_CHECK);

   if(Delete_OBJ_ARROW_LEFT_PRICE)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_LEFT_PRICE);
      
   if(Delete_OBJ_ARROW_RIGHT_PRICE)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_RIGHT_PRICE);

   if(Delete_OBJ_ARROW_BUY)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_BUY);

   if(Delete_OBJ_ARROW_SELL)   
      deleted += ObjectsDeleteAll(chartId, -1, OBJ_ARROW_SELL);
*/

// ObjectsDeleteAll() recognizes only OBJ_ARROW type - every arrow type is recognized as OBJ_ARROW
// When creating arrow, required arrow type must be specified, but when deleting, all arrows are recognized
// as OBJ_ARROW

   if(Delete_OBJ_ARROW)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_ARROW);

   if(Delete_OBJ_TEXT)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_TEXT);

   if(Delete_OBJ_LABEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_LABEL);

   if(Delete_OBJ_BUTTON)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_BUTTON);

   if(Delete_OBJ_BITMAP)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_BITMAP);

   if(Delete_OBJ_BITMAP_LABEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_BITMAP_LABEL);

   if(Delete_OBJ_EDIT)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_EDIT);

   if(Delete_OBJ_EVENT)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_EVENT);

   if(Delete_OBJ_RECTANGLE_LABEL)
      deleted+=ObjectsDeleteAll(chartId,-1,OBJ_RECTANGLE_LABEL);

  }
//+------------------------------------------------------------------+
