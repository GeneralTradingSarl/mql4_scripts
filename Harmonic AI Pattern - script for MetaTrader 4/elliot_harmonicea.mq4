//+------------------------------------------------------------------+
//|                                                     HarmonicEA.mq4|
//|                        Copyright 2024, LT             |
//|                                       https://evolvex.com        |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input double riskPercent = 20.0;
input double trailingStopPercent = 0.25;
input double lotSize = 0.2;
input int stopLossPips = 50;
input int takeProfitPips = 100;

// Indicator variables
double rsi;
double stoch;

// Harmonic pattern variables
bool isBullishPattern;
bool isBearishPattern;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialize indicators
    IndicatorShortName("HarmonicEA");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Main trading logic
    if (IsInOversoldRegion() && IsInValidTimeframe())
    {
        if (IsHarmonicPattern())
        {
            if (isBullishPattern && IsBullishSignal())
            {
                OpenBuyTrade();
            }
            else if (isBearishPattern && IsBearishSignal())
            {
                OpenSellTrade();
            }
        }
    }

    // Trailing stop logic
    SetTrailingStop();
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

bool IsInOversoldRegion()
{
    // Check if stochastic indicator is in oversold region
    return (iStochastic(NULL, PERIOD_H4, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 0) < 20);
}

bool IsInValidTimeframe()
{
    // Check if current timeframe is 15 minutes or 1 hour
    return (Period() == PERIOD_M15 || Period() == PERIOD_H1);
}

bool IsHarmonicPattern()
{
    // Implement logic for identifying harmonic patterns
    isBullishPattern = IsBullishPattern();
    isBearishPattern = IsBearishPattern();

    return (isBullishPattern || isBearishPattern);
}

bool IsBullishPattern()
{
    // Implement logic for identifying bullish harmonic patterns
    return (IsBullishCrabPattern() || IsBullishButterflyPattern() || IsBullishBatPattern() || IsBullishDeepBatPattern() || IsBullishABCDPattern() || IsBullish3DrivePattern() || IsBullish5DrivePattern() || IsBullishSharkPattern());
}

bool IsBearishPattern()
{
    // Implement logic for identifying bearish harmonic patterns
    return (IsBearishCrabPattern() || IsBearishButterflyPattern() || IsBearishBatPattern() || IsBearishDeepBatPattern() || IsBearishABCDPattern() || IsBearish3DrivePattern() || IsBearish5DrivePattern() || IsBearishSharkPattern());
}

bool IsBullishSignal()
{
    // Check for bullish signal using RSI indicator
    rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0); // RSI calculation example
    return (rsi > 70); // Example: RSI above 70 indicates overbought condition
}

bool IsBearishSignal()
{
    // Check for bearish signal using RSI indicator
    rsi = iRSI(NULL, 0, 14, PRICE_CLOSE, 0); // RSI calculation example
    return (rsi < 30); // Example: RSI below 30 indicates oversold condition
}

void OpenBuyTrade()
{
    // Open buy trade
    double lot = CalculateLotSize();
    if (IsCorrectLotSize(lot))
    {
        double sl = Ask - stopLossPips * Point;
        double tp = Ask + takeProfitPips * Point;
        int ticket = OrderSend(Symbol(), OP_BUY, lot, Ask, 3, sl, tp, "Buy Order", 0, 0, clrGreen);
        if (ticket < 0)
        {
            Print("Error opening buy order: ", GetLastError());
        }
    }
    else
    {
        Print("Incorrect lot size!");
    }
}

void OpenSellTrade()
{
    // Open sell trade
    double lot = CalculateLotSize();
    if (IsCorrectLotSize(lot))
    {
        double sl = Bid + stopLossPips * Point;
        double tp = Bid - takeProfitPips * Point;
        int ticket = OrderSend(Symbol(), OP_SELL, lot, Bid, 3, sl, tp, "Sell Order", 0, 0, clrRed);
        if (ticket < 0)
        {
            Print("Error opening sell order: ", GetLastError());
        }
    }
    else
    {
        Print("Incorrect lot size!");
    }
}

double CalculateLotSize()
{
    // Calculate lot size based on risk percentage
    double riskAmount = AccountBalance() * riskPercent / 100;
    double lot = riskAmount / (stopLossPips * Point * lotSize);
    return lot;
}

bool IsCorrectLotSize(double lot)
{
    // Check if the calculated lot size meets the criteria
    // Add your criteria here
    return true; // Example: always return true for demonstration purposes
}

void SetTrailingStop()
{
    // Trailing stop logic for open positions
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderType() == OP_BUY)
            {
                if (Bid - OrderOpenPrice() > trailingStopPercent * Point)
                {
                    double newSL = Bid - trailingStopPercent * Point;
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen))
                    {
                        Print("Error modifying order: ", GetLastError());
                    }
                }
            }
            else if (OrderType() == OP_SELL)
            {
                if (OrderOpenPrice() - Ask > trailingStopPercent * Point)
                {
                    double newSL = Ask + trailingStopPercent * Point;
                    if (!OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed))
                    {
                        Print("Error modifying order: ", GetLastError());
                    }
                }
            }
        }
    }
}

// Harmonic pattern detection functions

bool IsBullishCrabPattern()
{
    // Calculate the Fibonacci retracement levels
    double XA = High[1] - Low[1];
    double AB = High[2] - Low[2];
    double BC = High[1] - Low[2];
    double CD = High[3] - Low[2];

    // Check if Point B is within 0.618 to 0.786 Fibonacci retracement of XA leg
    bool isBWithinRange = (Close[2] >= Low[1] + 0.618 * XA) && (Close[2] <= Low[1] + 0.786 * XA);

    // Check if Point C is within 0.382 to 0.886 Fibonacci retracement of AB leg
    bool isCWithinRange = (High[1] <= Low[2] + 0.886 * AB) && (High[1] >= Low[2] + 0.382 * AB);

    // Check if Point D is at 0.382 Fibonacci retracement of XA leg
    bool isDAt382 = (Close[3] >= Low[2] + 0.382 * XA) && (Close[3] <= Low[2] + 0.383 * XA);

    // Check if AB leg is within 1.618 to 2.618 Fibonacci extension of XA leg
    bool isABWithinRange = (High[2] <= High[1] + 2.618 * XA) && (High[2] >= High[1] + 1.618 * XA);

    // Check if CD leg is within 1.618 to 2.618 Fibonacci extension of BC leg
    bool isCDWithinRange = (Low[3] >= Low[2] + 1.618 * BC) && (Low[3] <= Low[2] + 2.618 * BC);

    // Return true if all conditions are met
    return (isBWithinRange && isCWithinRange && isDAt382 && isABWithinRange && isCDWithinRange);
}

bool IsBearishCrabPattern()
{
    // Implement logic for identifying bearish crab pattern
    double XA = High[5] - Low[0];
    double AB = High[0] - Low[5];
    double BC = High[0] - Low[1];
    double CD = High[1] - Low[4];

    // Criteria:
    // - Point B should be within 0.618 to 0.786 Fibonacci retracement of XA leg
    // - Point C should be within 0.382 to 0.886 Fibonacci retracement of AB leg
    // - Point D should be at 0.382 Fibonacci retracement of XA leg
    // - AB leg should be within 1.618 to 2.618 Fibonacci extension of XA leg
    // - CD leg should be within 1.618 to 2.618 Fibonacci extension of BC leg

    double retracementBC = BC / AB;
    double extensionCD = CD / BC;

    if (High[0] > High[5] &&             // Point B is higher than X
        Low[0] < Low[5] &&               // Point B is lower than X
        retracementBC >= 0.382 &&        // AB retracement is within 0.382 to 0.886
        retracementBC <= 0.886 &&        
        extensionCD >= 1.618 &&          // CD extension is within 1.618 to 2.618
        extensionCD <= 2.618)
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool IsBullishButterflyPattern()
{
    // Calculate the Fibonacci retracement and extension levels
    double XA = High[1] - Low[1];
    double AB = High[2] - Low[2];
    double BC = High[1] - Low[2];
    double CD = High[3] - Low[2];

    // Check if Point B is within 0.786 to 0.886 Fibonacci retracement of XA leg
    bool isBWithinRange = (Close[2] >= Low[1] + 0.786 * XA) && (Close[2] <= Low[1] + 0.886 * XA);

    // Check if Point C is within 1.618 to 2.618 Fibonacci extension of AB leg
    bool isCWithinRange = (High[1] <= High[2] + 2.618 * AB) && (High[1] >= High[2] + 1.618 * AB);

    // Check if Point D is at 0.786 Fibonacci retracement of XA leg
    bool isDAt786 = (Close[3] >= Low[2] + 0.786 * XA) && (Close[3] <= Low[2] + 0.787 * XA);

    // Check if AB leg is within 0.382 to 0.886 Fibonacci retracement of XA leg
    bool isABWithinRange = (High[2] <= High[1] + 0.886 * XA) && (High[2] >= High[1] + 0.382 * XA);

    // Check if CD leg is within 1.272 to 1.618 Fibonacci extension of BC leg
    bool isCDWithinRange = (Low[3] >= Low[2] + 1.272 * BC) && (Low[3] <= Low[2] + 1.618 * BC);

    // Return true if all conditions are met
    return (isBWithinRange && isCWithinRange && isDAt786 && isABWithinRange && isCDWithinRange);
}

bool IsBearishButterflyPattern()
{
    // Implement logic for identifying bearish butterfly pattern
    double XA = High[5] - Low[0];
    double AB = High[0] - Low[5];
    double BC = High[0] - Low[1];
    double CD = High[1] - Low[4];

    // Criteria:
    // - Point B should be within 0.786 to 0.886 Fibonacci retracement of XA leg
    // - Point C should be within 1.618 to 2.618 Fibonacci extension of AB leg
    // - Point D should be at 0.786 Fibonacci retracement of XA leg
    // - AB leg should be within 0.382 to 0.886 Fibonacci retracement of XA leg
    // - CD leg should be within 1.272 to 1.618 Fibonacci extension of BC leg

    double retracementBC = BC / AB;
    double extensionCD = CD / BC;

    if (High[0] > High[5] &&             // Point B is higher than X
        Low[0] < Low[5] &&               // Point B is lower than X
        retracementBC >= 0.382 &&        // AB retracement is within 0.382 to 0.886
        retracementBC <= 0.886 &&        
        extensionCD >= 1.272 &&          // CD extension is within 1.272 to 1.618
        extensionCD <= 1.618)
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool IsBullishBatPattern()
{
    // Implement logic for identifying bullish bat pattern
    double XA = High[4] - Low[4];
    double AB = High[3] - Low[3];
    double BC = High[2] - Low[2];
    double CD = High[1] - Low[1];

    bool validXAB = (AB >= 0.382 * XA) && (AB <= 0.5 * XA);
    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.618 * BC) && (CD <= 2.618 * BC);
    bool validPattern = validXAB && validBC && validCD;

    return validPattern;
}

bool IsBearishBatPattern()
{
    // Implement logic for identifying bearish bat pattern
    double XA = High[4] - Low[4];
    double AB = High[3] - Low[3];
    double BC = High[2] - Low[2];
    double CD = High[1] - Low[1];

    bool validXAB = (AB >= 0.382 * XA) && (AB <= 0.5 * XA);
    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.618 * BC) && (CD <= 2.618 * BC);
    bool validPattern = validXAB && validBC && validCD;

    return validPattern;
}

bool IsBullishDeepBatPattern()
{
    // Implement logic for identifying bullish deep bat pattern
    double XA = High[4] - Low[4];
    double AB = High[3] - Low[3];
    double BC = High[2] - Low[2];
    double CD = High[1] - Low[1];

    bool validXAB = (AB >= 0.5 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 0.886 * AB) && (BC <= 1.618 * AB);
    bool validCD = (CD >= 2.24 * BC) && (CD <= 3.618 * BC);
    bool validPattern = validXAB && validBC && validCD;

    return validPattern;
}

bool IsBearishDeepBatPattern()
{
    // Implement logic for identifying bearish deep bat pattern
    double XA = High[4] - Low[4];
    double AB = High[3] - Low[3];
    double BC = High[2] - Low[2];
    double CD = High[1] - Low[1];

    bool validXAB = (AB >= 0.5 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 0.886 * AB) && (BC <= 1.618 * AB);
    bool validCD = (CD >= 2.24 * BC) && (CD <= 3.618 * BC);
    bool validPattern = validXAB && validBC && validCD;

    return validPattern;
}

bool IsBullishABCDPattern()
{
    // Implement logic for identifying bullish ABCD pattern
    double AB = High[5] - Low[5];
    double BC = High[4] - Low[4];
    double CD = High[3] - Low[3];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.272 * BC) && (CD <= 3.618 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

bool IsBearishABCDPattern()
{
    // Implement logic for identifying bearish ABCD pattern
    double AB = High[5] - Low[5];
    double BC = High[4] - Low[4];
    double CD = High[3] - Low[3];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.272 * BC) && (CD <= 3.618 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

bool IsBullish3DrivePattern()
{
    // Implement logic for identifying bullish 3-drive pattern
    // Check if the pattern consists of three consecutive legs with similar Fibonacci relationships
    double XA = High[5] - Low[5];
    double AB = High[4] - Low[4];
    double BC = High[3] - Low[3];
    double CD = High[2] - Low[2];
    double DE = High[1] - Low[1];
    double EF = High[0] - Low[0];

    bool validAB = (AB >= 0.618 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 1.13 * AB) && (BC <= 1.618 * AB);
    bool validCD = (CD >= 1.618 * BC) && (CD <= 2.24 * BC);
    bool validDE = (DE >= 1.618 * CD) && (DE <= 2.618 * CD);
    bool validEF = (EF >= 0.786 * DE) && (EF <= 1.0 * DE);

    return validAB && validBC && validCD && validDE && validEF;
}

bool IsBearish3DrivePattern()
{
    // Implement logic for identifying bearish 3-drive pattern
    // Check if the pattern consists of three consecutive legs with similar Fibonacci relationships
    double XA = High[5] - Low[5];
    double AB = High[4] - Low[4];
    double BC = High[3] - Low[3];
    double CD = High[2] - Low[2];
    double DE = High[1] - Low[1];
    double EF = High[0] - Low[0];

    bool validAB = (AB >= 0.618 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 1.13 * AB) && (BC <= 1.618 * AB);
    bool validCD = (CD >= 1.618 * BC) && (CD <= 2.24 * BC);
    bool validDE = (DE >= 1.618 * CD) && (DE <= 2.618 * CD);
    bool validEF = (EF >= 0.786 * DE) && (EF <= 1.0 * DE);

    return validAB && validBC && validCD && validDE && validEF;
}

bool IsBullish5DrivePattern()
{
    // Implement logic for identifying bullish 5-drive pattern
    // Check if the pattern consists of five consecutive legs with similar Fibonacci relationships
    double XA = High[5] - Low[5];
    double AB = High[4] - Low[4];
    double BC = High[3] - Low[3];
    double CD = High[2] - Low[2];
    double DE = High[1] - Low[1];
    double EF = High[0] - Low[0];

    bool validAB = (AB >= 0.618 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 1.618 * AB) && (BC <= 2.24 * AB);
    bool validCD = (CD >= 0.5 * BC) && (CD <= 0.786 * BC);
    bool validDE = (DE >= 1.13 * CD) && (DE <= 1.618 * CD);
    bool validEF = (EF >= 1.13 * DE) && (EF <= 1.618 * DE);

    return validAB && validBC && validCD && validDE && validEF;
}

bool IsBearish5DrivePattern()
{
    // Implement logic for identifying bearish 5-drive pattern
    // Check if the pattern consists of five consecutive legs with similar Fibonacci relationships
    double XA = High[5] - Low[5];
    double AB = High[4] - Low[4];
    double BC = High[3] - Low[3];
    double CD = High[2] - Low[2];
    double DE = High[1] - Low[1];
    double EF = High[0] - Low[0];

    bool validAB = (AB >= 0.618 * XA) && (AB <= 0.786 * XA);
    bool validBC = (BC >= 1.618 * AB) && (BC <= 2.24 * AB);
    bool validCD = (CD >= 0.5 * BC) && (CD <= 0.786 * BC);
    bool validDE = (DE >= 1.13 * CD) && (DE <= 1.618 * CD);
    bool validEF = (EF >= 1.13 * DE) && (EF <= 1.618 * DE);

    return validAB && validBC && validCD && validDE && validEF;
}

bool IsBullishSharkPattern()
{
    // Implement logic for identifying bullish shark pattern
    double XA = High[1] - Low[1];
    double AB = High[2] - Low[2];
    double BC = High[1] - Low[2];
    double CD = High[3] - Low[2];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.13 * BC) && (CD <= 1.618 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

bool IsBearishSharkPattern()
{
    // Implement logic for identifying bearish shark pattern
    double XA = High[5] - Low[0];
    double AB = High[0] - Low[5];
    double BC = High[0] - Low[1];
    double CD = High[1] - Low[4];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.13 * BC) && (CD <= 1.618 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

bool IsBullishCypherPattern()
{
    // Implement logic for identifying bullish cypher pattern
    double XA = High[1] - Low[1];
    double AB = High[2] - Low[2];
    double BC = High[1] - Low[2];
    double CD = High[3] - Low[2];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.272 * BC) && (CD <= 1.414 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

bool IsBearishCypherPattern()
{
    // Implement logic for identifying bearish cypher pattern
    double XA = High[5] - Low[0];
    double AB = High[0] - Low[5];
    double BC = High[0] - Low[1];
    double CD = High[1] - Low[4];

    bool validBC = (BC >= 0.382 * AB) && (BC <= 0.886 * AB);
    bool validCD = (CD >= 1.272 * BC) && (CD <= 1.414 * BC);
    bool validPattern = validBC && validCD;

    return validPattern;
}

void OnStart()
{
    // Run pattern detection on the 15-minute time frame
    for (int i = 0; i < Bars; i++)
    {
        // Check if the current bar is on the 15-minute time frame
        if (Period() == PERIOD_M15)
        {
            // Check for patterns
            if (IsBullishCrabPattern())
            {
                Alert("Bullish Crab Pattern Detected at ", Time[i]);
            }
            else if (IsBearishCrabPattern())
            {
                Alert("Bearish Crab Pattern Detected at ", Time[i]);
            }
            else if (IsBullishButterflyPattern())
            {
                Alert("Bullish Butterfly Pattern Detected at ", Time[i]);
            }
            else if (IsBearishButterflyPattern())
            {
                Alert("Bearish Butterfly Pattern Detected at ", Time[i]);
            }
            else if (IsBullishBatPattern())
            {
                Alert("Bullish Bat Pattern Detected at ", Time[i]);
            }
            else if (IsBearishBatPattern())
            {
                Alert("Bearish Bat Pattern Detected at ", Time[i]);
            }
            else if (IsBullishDeepBatPattern())
            {
                Alert("Bullish Deep Bat Pattern Detected at ", Time[i]);
            }
            else if (IsBearishDeepBatPattern())
            {
                Alert("Bearish Deep Bat Pattern Detected at ", Time[i]);
            }
            else if (IsBullishABCDPattern())
            {
                Alert("Bullish ABCD Pattern Detected at ", Time[i]);
            }
            else if (IsBearishABCDPattern())
            {
                Alert("Bearish ABCD Pattern Detected at ", Time[i]);
            }
            else if (IsBullish3DrivePattern())
            {
                Alert("Bullish 3-Drive Pattern Detected at ", Time[i]);
            }
            else if (IsBearish3DrivePattern())
            {
                Alert("Bearish 3-Drive Pattern Detected at ", Time[i]);
            }
            else if (IsBullish5DrivePattern())
            {
                Alert("Bullish 5-Drive Pattern Detected at ", Time[i]);
            }
            else if (IsBearish5DrivePattern())
            {
                Alert("Bearish 5-Drive Pattern Detected at ", Time[i]);
            }
            else if (IsBullishSharkPattern())
            {
                Alert("Bullish Shark Pattern Detected at ", Time[i]);
            }
            else if (IsBearishSharkPattern())
            {
                Alert("Bearish Shark Pattern Detected at ", Time[i]);
            }
            else if (IsBullishCypherPattern())
            {
                Alert("Bullish Cypher Pattern Detected at ", Time[i]);
            }
            else if (IsBearishCypherPattern())
            {
                Alert("Bearish Cypher Pattern Detected at ", Time[i]);
            }
        }
    }
}
