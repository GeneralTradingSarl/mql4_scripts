//+------------------------------------------------------------------+
//| TakeAllProfit.mq4
//+------------------------------------------------------------------+

#property copyright "Copyright K Lam"
#property link      "http://www.MXQ4.net/"
#property show_confirm

extern string Name_Expert = "Take All Trades";
extern double TakeProfitPoint = 1; //any profit will close the easy to take at a day inside!

//+------------------------------------------------------------------+
//| cal the point range                                                                  |
//+------------------------------------------------------------------+
double GetSlippage() { return((Ask-Bid)/Point); }

//+------------------------------------------------------------------+
//| script "close Profit last to 0 order"
//+------------------------------------------------------------------+

int start()
  {
   bool   result;
   double price,OrderProfitCash,OrderProfitPoint,RealProfit;
   int    cmd,error;
   int    TradeTick;
   double TimeOut;

   for(TradeTick=OrdersTotal()-1; TradeTick > 0; TradeTick--)
      { TimeOut=0;
        while(!IsTradeAllowed()) {if(TimeOut > 50) break;TimeOut++;}
        if(OrderSelect(TradeTick,SELECT_BY_POS,MODE_TRADES))
           {
           cmd=OrderType();
           //---- first order is buy or sell
           if(cmd==OP_BUY || cmd==OP_SELL)
              {
              while(true)
                 {// Cal the Profit Point
                 RefreshRates();
                 if(cmd==OP_BUY) { price =Bid; OrderProfitPoint =(price-OrderOpenPrice())/Point; }
                 else            { price =Ask; OrderProfitPoint =(OrderOpenPrice()-price)/Point; }
                 
                 OrderProfitCash = OrderProfit()+OrderCommission()+OrderSwap();
                 if(OrderProfitCash <= 0) continue;
                 //if((TakeProfitPoint > OrderProfitPoint) || !OrderProfitCash) break;
                 result=OrderClose(OrderTicket(),OrderLots(),price,GetSlippage(),CLR_NONE);
                 if(result!=TRUE) { error=GetLastError(); Print("LastError = ",error); }
                 else { error=0; Print("OrderProfit = ", OrderProfit());RealProfit+=OrderProfit();}
                 
                 if(error==129 || error==135) RefreshRates();
                 else break;
                 }
              }
           }
           else Print( "Error when order select ", GetLastError());
      }
   Print("Close Profit Order Call, Profit Take =",RealProfit);
   return(0);
  }


//+------------------------------------------------------------------+