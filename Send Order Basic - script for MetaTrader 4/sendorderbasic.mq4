//+------------------------------------------------------------------+
//|                                               SendOrderBasic.mq4 |
//|                                                  Bott Consulting |
//|                                                       bottcg.com |
//+------------------------------------------------------------------+
#property copyright "Bott Consulting"
#property link      "bottcg.com"
#property version   "17.10"
#property strict
#property show_inputs

extern int     Order                = 0; //Order type
extern string  BuyNote              = "0 = Buy, 2 = Buy limit (lower), 4 = Buy stop (higher)"; //Buy order types note
extern string  SellNote             = "1 = Sell, 3 = Sell limit (higher), 5 = Sell stop (lower)"; //Sell order types note
extern double  Price                = 1.00000; //Price for pending orders
extern string  PriceNote            = "Price used for pending (limit or stop) orders only"; //Price note
extern int     TakeProfit           = 25; //Take profit level (in pips)
extern int     StopLoss             = 25; //Stop loss level (in pips)
extern int     Slippage             = 1; //Order slippage
extern double  Lots                 = 1.0; //Order size (in lots)
extern int     Magic                = 2017; //Magic number

//+------------------------------------------------------------------+
//|                            Function triggered when script starts |
//+------------------------------------------------------------------+
void OnStart()
  {
   string comment="";
   int ticket=0;
   double entryPrice = Bid;
   double stopLoss = 0;
   double takeProfit = 0;
   
   RefreshRates();
   double spread=NormalizeDouble(MarketInfo(Symbol(),MODE_SPREAD),Digits);

   if(Order==0)
     {
      entryPrice = NormPrice(Ask);
      stopLoss = NormPrice(Bid-StopLoss*Point);
      takeProfit = NormPrice(Bid+TakeProfit*Point);
     }
   else if(Order==2 || Order==4)
     {
      entryPrice = NormPrice(Price);
      stopLoss = NormPrice(Price-StopLoss*Point);
      takeProfit = NormPrice(Price+TakeProfit*Point);
     }
   else if(Order==1)
     {
      entryPrice = NormPrice(Bid);
      stopLoss = NormPrice(Ask+StopLoss*Point);
      takeProfit = NormPrice(Ask-TakeProfit*Point);
     }
   else if(Order==3 || Order==5)
     {
      entryPrice = NormPrice(Price);
      stopLoss = NormPrice(Price+StopLoss*Point);
      takeProfit = NormPrice(Price-TakeProfit*Point);
     }
   
   ticket = SendOrder(Symbol(),Order,Lots,entryPrice,Slippage,stopLoss,takeProfit,Magic);
   
   if(ticket>0)
     {
      comment="Order #" + string(ticket) + " confirmed with " + string(spread) + " pip spread.";
      Comment(comment);
     }
   else
     {
      HandleException();
     }
  }
//+------------------------------------------------------------------+
//|                                     Function to submit the order |
//+------------------------------------------------------------------+
int SendOrder(string symbol,int cmd,double volume,double price,int slippage,double stoploss,double takeprofit, int magicnumber)
  {
   int result=0;
   result=OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,NULL,magicnumber,0);
   return(result);
  }
//+------------------------------------------------------------------+
//|                                     Function to normalize prices |
//+------------------------------------------------------------------+
double NormPrice(double price)
  {
   double tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   price=NormalizeDouble(MathRound(price/tickSize)*tickSize,Digits);
   return(price);
  }
//+------------------------------------------------------------------+
//|                                        Function to handle errors |
//+------------------------------------------------------------------+
void HandleException()
{
   string result="";
   int error = GetLastError();
   if(error!=0 && error!=4000)
     {
      if(error>=1 && error<=150)
        {
         result+="Trading Error";
        }
      else if(error>=4001 && error<=5203)
        {
         result+="Runtime Error";
        }
      result+=" ("+string(error)+")";
     }
   if (result != ""){Alert(result);}
}
//+------------------------------------------------------------------+
