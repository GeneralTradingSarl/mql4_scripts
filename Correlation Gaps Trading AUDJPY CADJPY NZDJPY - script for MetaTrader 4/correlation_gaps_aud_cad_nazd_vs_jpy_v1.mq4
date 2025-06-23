//+------------------------------------------------------------------+
//|                      Correlation_Gaps_AUD_CAD_NAZD_Vs_JPY_V1.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|Watch for gaps in the correlation between two trading instruments and trade one pair against the other.
//|It is advisable not to leave the trading unattended.
//|Stop loss and take profit orders are not advisable since one pair trades against the other.
//|Close profit and wait for new opportunities.
//|Close loss or hedge it against the opposite orders.
//|Example Buy_AUD_Sell_NZD negative Sell_AUD_Buy_NZD and wait for a new opportunity.
//|Another way is to open a triangle forming a hedged pair.
//|Example Buy_AUDJPY_Sell_NZDJPY  Sell_AUD_NZD.
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "Correlation_Gaps_AUD_CAD_NAZD_Vs_JPY_V1.mq4."
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs


#property script_show_inputs
input double Lot = 1;
//+------------------------------------------------------------------+
extern string  AUDJPY_vs_CADJPY        = "Watch for Gaps In Correlation AUD_CAD ";
//+------------------------------------------------------------------+
input bool     Buy_AUDJPY_Sell_CADJPY            =  false;
input bool     Sell_AUDJPY_Buy_CADJPY            =  false;
//+------------------------------------------------------------------+
extern string  AUDJPY_vs_NZDJPY        = "Watch for Gaps In Correlation AUD_NZD "; 
//+------------------------------------------------------------------+
input bool     Buy_AUDJPY_Sell_NZDJPY            =  false;
input bool     Sell_AUDJPY_Buy_NZDJPY            =  false;
//+------------------------------------------------------------------+
extern string  CADJPY_vs_NZDJPY        = "Watch for Gaps In Correlation CAD_NZD "; 
//+------------------------------------------------------------------+
input bool     Buy_CADJPY_Sell_NZDJPY            =  false;
input bool     Sell_CADJPY_Buy_NZDJPY            =  false;
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(IsTradeAllowed())
     {
      if(Buy_AUDJPY_Sell_CADJPY)
        {
         RefreshRates();
         int AUDJPY_B1 = OrderSend("AUDJPY",OP_BUY,Lot,    0.00,10,0,0,"",0,0,0);
         int CADJPY_S1 = OrderSend("CADJPY",OP_SELL,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
      if(Sell_AUDJPY_Buy_CADJPY)
        {
         RefreshRates();
         int AUDJPY_S1 = OrderSend("AUDJPY",OP_SELL,Lot,    0.00,10,0,0,"",0,0,0);
         int CADJPY_B1 = OrderSend("CADJPY",OP_BUY ,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
//+------------------------------------------------------------------+
      if(Buy_AUDJPY_Sell_NZDJPY)
        {
         RefreshRates();
         int AUDJPY_B2 = OrderSend("AUDJPY",OP_BUY,Lot,    0.00,10,0,0,"",0,0,0);
         int NZDJPY_S2 = OrderSend("NZDJPY",OP_SELL,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
      if(Sell_AUDJPY_Buy_NZDJPY)
        {
         RefreshRates();
         int AUDJPY_S2 = OrderSend("AUDJPY",OP_SELL,Lot,    0.00,10,0,0,"",0,0,0);
         int NZDJPY_B2 = OrderSend("NZDJPY",OP_BUY,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
//+------------------------------------------------------------------+
      if(Buy_CADJPY_Sell_NZDJPY)
        {
         RefreshRates();
         int CADJPY_B3 = OrderSend("CADJPY",OP_BUY,Lot,    0.00,10,0,0,"",0,0,0);
         int NZDJPY_S3 = OrderSend("NZDJPY",OP_SELL,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
      if(Sell_CADJPY_Buy_NZDJPY)
        {
         RefreshRates();
         int CADJPY_S3 = OrderSend("CADJPY",OP_SELL,Lot,    0.00,10,0,0,"",0,0,0);
         int NZDJPY_B3 = OrderSend("NZDJPY",OP_BUY,Lot,   0.00,10,0,0,"",0,0,0);
         PlaySound("alert.wav");
        }
      if(!IsTradeAllowed())
        {
         MessageBox("Enable AutoTrading Please ");
        }
     }
  }
//+------------------------------------------------------------------+
