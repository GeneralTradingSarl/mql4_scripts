//+------------------------------------------------------------------+
//|                                               accountdetails.mq4 |
//|                                           Copyright © 2006, Iggy |
//|                                                 irusoh@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Iggy"
#property link      "irusoh@yahoo.com"
//----
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
		 string stm,ta;
   int nTradeAllowed;
   if(AccountStopoutMode() == 0)
		     stm = "%";
   nTradeAllowed = MarketInfo(Symbol(), MODE_TRADEALLOWED);
		 switch(nTradeAllowed)
		   {
			    case 0:	ta = "No";	 break;
			    case 1:	ta = "Yes";	break;
		   }
		 string msg = "Account Details:" + "\n" +
		              "  Number\t\t" + AccountNumber() + "\n" +
		              "  Name\t\t" + AccountName() + "\n" +
		              "  Currency\t" + AccountCurrency() + "\n" +
		              "  Company\t" + AccountCompany() + "\n" +
		              "  Server\t\t" + AccountServer() + "\n" +
   	            "  Leverage\t" + AccountLeverage() + "\n" +
		              "  Stop Out level\t" + AccountStopoutLevel() + stm + "\n" +
		              "  Balance Details:" + "\n" +
		              "  Balance\t\t" + DoubleToStr(AccountBalance(), 4) + "\n" +
		              "  Equity\t\t" + DoubleToStr(AccountEquity(), 4) + "\n" +
		              "  Margin\t\t" + DoubleToStr(AccountMargin(), 4) + "\n" +
		              "  Free Margin\t" + DoubleToStr(AccountFreeMargin(), 4) + "\n" +
		              "  Symbol Details:" + "\n" +
		              "  Symbol\t\t" + Symbol() + "\n" +
 	              "  Lot Size\t\t" + DoubleToStr(MarketInfo(Symbol(), MODE_LOTSIZE),0) + 
 	              "\n" +
 	              "  Min Lot\t\t" + DoubleToStr(MarketInfo(Symbol(), MODE_MINLOT), 2) + 
 	              "\n" +
 	              "  Lot Step\t\t" + DoubleToStr(MarketInfo(Symbol(), MODE_LOTSTEP), 2) + 
 	              "\n" +
 	              "  Max Lot\t\t" + DoubleToStr(MarketInfo(Symbol(), MODE_MAXLOT), 2) + 
 	              "\n" +
 	              "  Tick Value\t" + DoubleToStr(MarketInfo(Symbol(), MODE_TICKVALUE), 4) + 
 	              "\n" +
 	              "  Tick Size\t" + DoubleToStr(MarketInfo(Symbol(), MODE_TICKSIZE), Digits) + 
 	              "\n"+
 	              "  Spread\t\t" + DoubleToStr(MarketInfo(Symbol(), MODE_SPREAD), 0) + 
 	              "\n" +
 	              "  Stop Loss Level\t" + DoubleToStr(MarketInfo(Symbol(), MODE_STOPLEVEL), 0) +
 	              "\n"+
 	              "  Swap Long\t" + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG), 4) + 
 	              "\n" +
 	              "  Swap Short\t" + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT), 4) + 
 	              "\n" +
 	              "  Initial Margin\t" + DoubleToStr(MarketInfo(Symbol(), MODE_MARGININIT), 4) +
 	              "\n" +
 	              "  Maint Margin\t" + DoubleToStr(MarketInfo(Symbol(), MODE_MARGINMAINTENANCE),
 	              4) + "\n" +
 	              "  Required Margin\t" + DoubleToStr(MarketInfo(Symbol(), MODE_MARGINREQUIRED),
 	              4) + "\n" +
 	              "  Trade Allowed\t" + ta + "\n";
	  MessageBox(msg, "Account/Symbol Details", 0);  
//----
   return(0);
  }
//+------------------------------------------------------------------+