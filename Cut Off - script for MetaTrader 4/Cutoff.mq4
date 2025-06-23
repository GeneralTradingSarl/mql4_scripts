//+------------------------------------------------------------------+
//| CutOff.mq4
//+------------------------------------------------------------------+

#property copyright "Copyright K Lam 2009"
#property link      "http://www.FxKillU.net/"
#property show_confirm

// extern string Name_Expert = "Close All Trades";

//+------------------------------------------------------------------+
//| cal the point range                                                                  |
//+------------------------------------------------------------------+
double GetSlippage(string XSymbol)
{
   double bid   =MarketInfo(XSymbol,MODE_BID);
   double ask   =MarketInfo(XSymbol,MODE_ASK);
   double point =MarketInfo(XSymbol,MODE_POINT);
   return((ask-bid)/point);
}

void CloseAll(string SymbolToClose,int MagNo) //at Symbol
{
bool   result;
int retry;
int cmd,error;
int cnt;
int CloseNo;
double sp,price;
string XSymbol;

   for (cnt=10;IsTradeContextBusy();cnt--) {
   cnt+=2;
   Sleep(10);
    //Print("Trade context is busy. Please wait");
   }
    
   CloseNo=OrdersTotal();
   if(CloseNo==0) return(0);

   for(cnt=OrdersTotal();cnt > 0;cnt--) {//last to frist -1
      if(OrderSelect(cnt-1,SELECT_BY_POS, MODE_TRADES)==true) {
      
      for(retry=0;retry < 10;retry++) {
         if((SymbolToClose=="All") || 
         (OrderSymbol()==SymbolToClose && MagNo == 0) ||
         (OrderSymbol()==SymbolToClose && OrderMagicNumber() == MagNo)) {
         
            cmd=OrderType();
            //RefreshRates();
            XSymbol = OrderSymbol();
            sp = GetSlippage(XSymbol);
            
            if(cmd==OP_BUY) price=MarketInfo(XSymbol,MODE_BID);// Ask;
            if(cmd==OP_SELL) price=MarketInfo(XSymbol,MODE_ASK);// Bid; // not the chart price!!
            
            if(cmd==OP_BUY || cmd==OP_SELL) {
               result=OrderClose(OrderTicket(),OrderLots(),price,sp,CLR_NONE);
               if(!result) {
                  error=GetLastError();
                  Print("LastError = ",error," price=",price," Slippage=",sp);
                  } else break;
               if(error==129 || error==135 || error==146) Sleep(100);// RefreshRates(); 138
            }
            
            if(cmd!=OP_BUY && cmd!=OP_SELL) {
               result=OrderDelete(OrderTicket());
               }
         }//if
      } //for retry
      } else Print( "Error when order select ", GetLastError());//OrderSelect
   }//for
      
   CloseNo=CloseNo-OrdersTotal();   //CloseNo-=OrdersTotal();   
   if(!IsTesting()) Print(CloseNo," Orders Closed, ",SymbolToClose,"=",MagNo," Balance: ", AccountBalance()," Equity: ",AccountEquity(),"Last Profit ",AccountProfit());
}

//+------------------------------------------------------------------+
//| script "close Profit last to 0 order"
//+------------------------------------------------------------------+

int start()
{
   bool   result;
   double price;
   int    cmd,error;
   int    cnt;
   string XSymbol;
   
   int CloseNo;
   CloseNo=OrdersTotal();
   CloseAll("All",0);
   CloseNo=CloseNo-OrdersTotal();   
   Print(CloseNo," Orders Closed, Balance: ", AccountBalance()," Equity: ",AccountEquity(),"Last Profit ",AccountProfit());
}
//+------------------------------------------------------------------+