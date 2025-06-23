//+------------------------------------------------------------------+
//|                                                 PrevDayLines.mq4 |
//|            Copyright 2024, MetaTrader4 Professional Code Creator |
//|                          https://www.mql5.com/en/users/mqlzone   |
//+------------------------------------------------------------------+
#property strict

// Line parameters
input color MaxLineColor = clrRed;
input color MinLineColor = clrBlue;
input color AvgLineColor = clrGreen;

input int LineWidth = 2;
input int LineStyle = STYLE_DOT;

// Line names
string maxLineName = "PrevDayMax";
string minLineName = "PrevDayMin";
string avgLineName = "PrevDayAvg";

//+------------------------------------------------------------------+
//| Script start function                                            |
//+------------------------------------------------------------------+
void OnStart()
{
    // Determine the previous day's time range
    datetime prevDayStart = iTime(NULL, PERIOD_D1, 1);
    datetime prevDayEnd = iTime(NULL, PERIOD_D1, 0);

    // Find the Max, Min, and Average values of the previous day
    double prevDayHigh = iHigh(NULL, PERIOD_D1, 1);
    double prevDayLow = iLow(NULL, PERIOD_D1, 1);
    double prevDayAvg = (prevDayHigh + prevDayLow) / 2;

    // Drawing the Max line
    if (ObjectFind(0, maxLineName) != 0)
        ObjectCreate(0, maxLineName, OBJ_HLINE, 0, 0, prevDayHigh);
    ObjectSetInteger(0, maxLineName, OBJPROP_COLOR, MaxLineColor);
    ObjectSetInteger(0, maxLineName, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, maxLineName, OBJPROP_STYLE, LineStyle);
    ObjectSetDouble(0, maxLineName, OBJPROP_PRICE1, prevDayHigh);

    // Drawing the Min line
    if (ObjectFind(0, minLineName) != 0)
        ObjectCreate(0, minLineName, OBJ_HLINE, 0, 0, prevDayLow);
    ObjectSetInteger(0, minLineName, OBJPROP_COLOR, MinLineColor);
    ObjectSetInteger(0, minLineName, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, minLineName, OBJPROP_STYLE, LineStyle);
    ObjectSetDouble(0, minLineName, OBJPROP_PRICE1, prevDayLow);

    // Drawing the Average line
    if (ObjectFind(0, avgLineName) != 0)
        ObjectCreate(0, avgLineName, OBJ_HLINE, 0, 0, prevDayAvg);
    ObjectSetInteger(0, avgLineName, OBJPROP_COLOR, AvgLineColor);
    ObjectSetInteger(0, avgLineName, OBJPROP_WIDTH, LineWidth);
    ObjectSetInteger(0, avgLineName, OBJPROP_STYLE, LineStyle);
    ObjectSetDouble(0, avgLineName, OBJPROP_PRICE1, prevDayAvg);
}
//+------------------------------------------------------------------+
