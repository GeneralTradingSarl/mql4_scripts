//+------------------------------------------------------------------+
//|                                              CloseAllAdvance.mq4 |
//|                                                  ThinkTrustTrade |
//|                                        www.think-trust-trade.com |
//+------------------------------------------------------------------+
#property copyright "ThinkTrustTrade"
#property link      "www.think-trust-trade.com"
#property show_inputs

extern string  Visit="www.think-trust-trade.com";
extern string  Like="www.facebook.com/ThinkTrustTrade";
extern bool long=true;
extern bool short=true;
extern int only_magic=0;
extern int skip_magic=0;
extern bool only_below_symbol=false;
extern string symbol="EURUSD";
extern bool only_winning_positions=false;
extern bool only_losing_positions=false;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
int ticket;
if (OrdersTotal()==0) return(0);
for (int i=OrdersTotal()-1; i>=0; i--)
      {//pozicio kivalasztasa
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)//ha kivalasztas ok
            {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber(), " Order Symbol: ", OrderSymbol());
            if (only_magic>0 && OrderMagicNumber()!=only_magic) continue;
            if (skip_magic>0 && OrderMagicNumber()==skip_magic) continue;
            if (only_below_symbol==true && OrderSymbol()!=symbol) 
            {Print("order symbol different"); continue;}
            if (only_winning_positions==true && OrderProfit()<0) continue;
            if (only_losing_positions==true && OrderProfit()>0) continue;
            if (OrderType()==0 && long==true)
               {//ha long
               
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               if (ticket>0) Print ("Position ", OrderTicket() ," closed. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               }
            if (OrderType()==1 && short==true)
               {//ha short
               
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               if (ticket>0) Print ("Position ", OrderTicket() ," closed. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               }   
            }
      }//pozicio kivalszatas vege
  
//----
   return(0);
  }
//+------------------------------------------------------------------+ 

