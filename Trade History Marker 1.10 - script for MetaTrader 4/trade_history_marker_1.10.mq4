//+------------------------------------------------------------------+
//|                                         Trade History Marker.mq4 |
//|                                Copyright 2020, Chamal Abayaratne |
//|                                      https://github.com/ChamalAB |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Chamal Abayaratne"
#property link      "https://github.com/ChamalAB"
#property version   "1.10"
#property description   "Analyse past trades visually"
#property strict
#property show_inputs

/*
Author - Chamal Abayaratne

Version 1.00
- Basic markings added
- Color options
- Line styles
- line sizes

Version 1.01
- Do not draw markings for trades for which bars do not exist [Fixed]
- Added full color list availbale at mql4
- Change background color
- Enable/Disable autoscroll
- Time filter
- Order type filter

Version 1.10
- Export/ Import from data file

*/


#include <Enum_colors.mqh>
#include <CTradeHistory.mqh>

enum ENUM_ORDER_FILTERS
   {
   ORDER_FILTER_BUY_ONLY = 0,  // Longs only
   ORDER_FILTER_SELL_ONLY = 1, // Shorts only
   ORDER_FILTER_BUY_SELL = 2,  // Longs & Shorts
   };


input string header13= "";                                             // =======Data Source=======
input CTRADE_HISTORY_MODES doOrderSource = CTRADE_LOAD_LIVE;           // Data source
input bool doSaveData = false;                                         // Save history to file?
input string dataFileName = "historyData.csv";                         // Data file path
input string dataDelimiter = "'";                                      // CSV delimiter

input string header12= "";                                             // =======Order Filter=======
input ENUM_ORDER_FILTERS doOrderFilter = ORDER_FILTER_BUY_SELL;        // Order filter type

input string header10= "";                                             // =======Time Filter=======
input bool doTimeFilter = false;                                       // Enable time filter
input datetime timeFilterStartDate = D'2000.01.01 00:00';              // Filter start date
input datetime timeFilterEndDate = D'2020.12.31 00:00';                // Filter end date

input string header5= "";                                              // =======Entry Marking=======
input bool doMarkEntry = true;                                         // Enable
input ENUM_COLOR_PALLETE markEntryBuyArrowColor = COLOR_BLUE;          // Buy arrow color
input ENUM_COLOR_PALLETE markEntrySellArrowColor = COLOR_RED;          // Sell arrow color

input string header6= "";                                              // =======SL Marking=======
input bool doMarkStop = false;                                         // Enable
input ENUM_COLOR_PALLETE markStopBuyArrowColor = COLOR_BLUE;           // Buy line color
input ENUM_COLOR_PALLETE markStopSellArrowColor = COLOR_RED;           // Sell line color
input ENUM_LINE_STYLE markStopLineStyle = STYLE_SOLID;                 // Line style
input int markStopLineThickness = 1;                                   // Line thinkness [1-5]

input string header7= "";                                              // =======TP Marking=======
input bool doMarkProfit = false;                                       // Enable
input ENUM_COLOR_PALLETE markProfitBuyArrowColor = COLOR_BLUE;         // Buy line color
input ENUM_COLOR_PALLETE markProfitSellArrowColor = COLOR_RED;         // Sell line color
input ENUM_LINE_STYLE markProfitLineStyle = STYLE_SOLID;               // Line style
input int markProfitLineThickness = 1;                                 // Line thinkness [1-5]

input string header8= "";                                              // =======Exits Marking=======
input bool doMarkExit = true;                                          // Enable
input ENUM_COLOR_PALLETE markExitBuyLineColor = COLOR_BLUE;            // Buy line color
input ENUM_COLOR_PALLETE markExitSellLineColor = COLOR_RED;            // Sell line color
input ENUM_LINE_STYLE markExitLineStyle = STYLE_DASHDOTDOT;            // Line style
input int markExitLineThickness = 1;                                   // Line thinkness [1-5]

input string header9= "";                                              // =======Chart=======
input bool doChangeBackground = true;                                  // Chnage background color?
input ENUM_COLOR_PALLETE chartBackgroundColor = COLOR_GRAY;            // Background color
input bool doChartAutoScroll = false;                                  // Autoscroll

input string header11= "";                                             // =======Other=======
input string obj_prefix = "`";                                         // Prefix identifier



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Set Chart settings
   if(doChangeBackground)
      ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,chartBackgroundColor);
      
   ChartSetInteger(ChartID(),CHART_AUTOSCROLL,doChartAutoScroll);
   
   
   
//--- Delete all prefixed objects
   objectsClear();
   
   
   
//--- Draw markings
   // filters
   //--- Find how far chart data goes
   datetime chartDataLimit = Time[Bars-1];
   bool symbolFilter, orderTypeFilter, barLimitFilter, startTimeFilter, endTimeFilter;
   
   CTradeHistory *hist = new CTradeHistory(doOrderSource,dataFileName,dataDelimiter);
   
   int histTot = hist.iOrdersHistoryTotal();
   for(int i=0; i<histTot; i++)
     {
      if(hist.iOrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
        symbolFilter = hist.iOrderSymbol() == Symbol();
        
        if(doOrderFilter==ORDER_FILTER_BUY_SELL)
            orderTypeFilter = (hist.iOrderType() == OP_BUY || hist.iOrderType() == OP_SELL);
        else if(doOrderFilter==ORDER_FILTER_BUY_ONLY)
            orderTypeFilter = hist.iOrderType() == OP_BUY;
        else
            orderTypeFilter = hist.iOrderType() == OP_SELL;
            
            
        barLimitFilter = hist.iOrderOpenTime() > chartDataLimit;
        
        if(doTimeFilter)
         {
         startTimeFilter = hist.iOrderOpenTime() > timeFilterStartDate;
         endTimeFilter = hist.iOrderOpenTime() < timeFilterEndDate;
         }
        else
         {
         startTimeFilter = true;
         endTimeFilter = true;
         }
         
         // apply filters
         if(symbolFilter && orderTypeFilter && barLimitFilter && startTimeFilter && endTimeFilter)
           {
            //PrintFormat("Order selected %d type %d",OrderTicket(),OrderType());

            // mark entry
            if(doMarkEntry)
               markEntry(hist.iOrderTicket(),hist.iOrderOpenPrice(),hist.iOrderOpenTime(),hist.iOrderType());


            // mark TP if exists
            if(doMarkProfit)
               markProfit(hist.iOrderTicket(),hist.iOrderTakeProfit(),hist.iOrderOpenTime(),hist.iOrderType());

            // mark SL if exists
            if(doMarkStop)
               markStop(hist.iOrderTicket(),hist.iOrderStopLoss(),hist.iOrderOpenTime(),hist.iOrderType());

            // mark close line
            if(doMarkExit)
               markClose(hist.iOrderTicket(),
                         hist.iOrderType(),
                         hist.iOrderOpenPrice(),
                         hist.iOrderOpenTime(),
                         hist.iOrderClosePrice(),
                         hist.iOrderCloseTime(),
                         hist.iOrderStopLoss(),
                         hist.iOrderTakeProfit(),
                         hist.iOrderLots(),
                         hist.iOrderProfit(),
                         hist.iOrderComment());
           }

        }
      else
        {
         PrintFormat("Order select failed at index %d",i);
        }
     }
     
   if(doSaveData)
      {
      hist.dumpToFile();
      }
      
   delete hist;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string objectName(string name)
  {
   return obj_prefix + name;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectsClear(void)
  {
   ObjectsDeleteAll(ChartID(),obj_prefix,EMPTY,EMPTY);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void markEntry(int ticket, double price,datetime time, int type)
  {
   string objName;
   int objType;
   int objColor;

   if(type == OP_BUY)
     {
      objName = StringFormat("BUY %d",ticket);
      objType = OBJ_ARROW_BUY;
      objColor = markEntryBuyArrowColor;
     }
   else
      if(type == OP_SELL)
        {
         objName = StringFormat("SELL %d",ticket);
         objType = OBJ_ARROW_SELL;
         objColor = markEntrySellArrowColor;
        }
      else
        {
         return;
        }

   if(!ObjectCreate(ChartID(),objectName(objName),objType,0,time,price))
     {
      PrintFormat("%s:: can't create label for ticket %d! code #%d",__FUNCTION__,ticket,GetLastError());
     }

   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_COLOR,objColor);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void markStop(int ticket, double price,datetime time, int type)
  {

   if(price==0)
     {
      return;
     }

   int barShift = iBarShift(NULL,0,time);
   string objName;
   int objType;
   int objColor;

   if(type == OP_BUY)
     {
      objName = StringFormat("BUY SL %d",ticket);
      objType = OBJ_TREND;
      objColor = markStopBuyArrowColor;
     }
   else
      if(type == OP_SELL)
        {
         objName = StringFormat("SELL SL %d",ticket);
         objType = OBJ_TREND;
         objColor = markStopSellArrowColor;
        }
      else
        {
         return;
        }

   if(!ObjectCreate(ChartID(),objectName(objName),objType,0,Time[barShift],price,Time[barShift-1],price))
     {
      PrintFormat("%s:: can't create object for ticket %d! code #%d",__FUNCTION__,ticket,GetLastError());
     }

   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_RAY,false);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_COLOR,objColor);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_STYLE,markStopLineStyle);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_WIDTH,markStopLineThickness);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void markProfit(int ticket, double price,datetime time, int type)
  {

   if(price==0)
     {
      return;
     }

   int barShift = iBarShift(NULL,0,time);
   string objName;
   int objType;
   int objColor;

   if(type == OP_BUY)
     {
      objName = StringFormat("BUY TP %d",ticket);
      objType = OBJ_TREND;
      objColor = markProfitBuyArrowColor;
     }
   else
      if(type == OP_SELL)
        {
         objName = StringFormat("SELL TP %d",ticket);
         objType = OBJ_TREND;
         objColor = markProfitSellArrowColor;
        }
      else
        {
         return;
        }

   if(!ObjectCreate(ChartID(),objectName(objName),objType,0,Time[barShift],price,Time[barShift-1],price))
     {
      PrintFormat("%s:: can't create object for ticket %d! code #%d",__FUNCTION__,ticket,GetLastError());
     }

   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_RAY,false);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_COLOR,objColor);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_STYLE,markProfitLineStyle);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_WIDTH,markProfitLineThickness);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void markClose(int ticket,
               int orderType,
               double openPrice,
               datetime openTime,
               double closePrice,
               datetime closeTime,
               double stopLoss,
               double takeProfit,
               double lotsize,
               double profit,
               string comment)
  {
   int openBarShift = iBarShift(NULL,0,openTime);
   int closeBarShift = iBarShift(NULL,0,closeTime);
   string objName,objText;
   int objType;
   int objColor;

// get order type
   if(orderType == OP_BUY)
     {
      objName = StringFormat("%d Buy",ticket);
      objType = OBJ_TREND;
      objColor = markExitBuyLineColor;
     }
   else
      if(orderType == OP_SELL)
        {
         objName = StringFormat("%d Sell",ticket);
         objType = OBJ_TREND;
         objColor = markExitSellLineColor;
        }
      else
         return;

// first figure out what SL TP or manual close
   if(profit == 0)
      objName += " break even trade";
   else
      if(profit > 0)
         objName += " profit trade";
      else
         if(profit < 0)
            objName += " loss trade";

// formulate description
   objText = "%s\n"
             "Lots: %.2f\n"
             "Profit: %.2f\n"
             "Comment: %s";

   objText = StringFormat(objText,objName,lotsize,profit,comment);


// draw
   if(!ObjectCreate(ChartID(),objectName(objName),objType,0,Time[openBarShift],openPrice,Time[closeBarShift],closePrice))
     {
      PrintFormat("%s:: can't create object for ticket %d! code #%d",__FUNCTION__,ticket,GetLastError());
     }

   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_RAY,false);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_COLOR,objColor);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_STYLE,markExitLineStyle);
   ObjectSetInteger(ChartID(),objectName(objName),OBJPROP_WIDTH,markExitLineThickness);
   ObjectSetString(ChartID(),objectName(objName),OBJPROP_TOOLTIP,objText);
  }
//+------------------------------------------------------------------+
