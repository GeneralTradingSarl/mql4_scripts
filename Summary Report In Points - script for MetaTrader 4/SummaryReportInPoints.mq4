//+------------------------------------------------------------------+
//|                                        SummaryReportInPoints.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

double InitialDeposit;
double SummaryProfit;
double GrossProfit;
double GrossLoss;
double MaxProfit;
double MinProfit;
double ConProfit1;
double ConProfit2;
double ConLoss1;
double ConLoss2;
double MaxLoss;
double MaxDrawdown;
double MaxDrawdownPercent;
double RelDrawdownPercent;
double RelDrawdown;
double ExpectedPayoff;
double ProfitFactor;
double AbsoluteDrawdown;
int    SummaryTrades;
int    ProfitTrades;
int    LossTrades;
int    ShortTrades;
int    LongTrades;
int    WinShortTrades;
int    WinLongTrades;
int    ConProfitTrades1;
int    ConProfitTrades2;
int    ConLossTrades1;
int    ConLossTrades2;
int    AvgConWinners;
int    AvgConLosers;

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int    handle=FileOpen(StringConcatenate(AccountNumber(),"_AccountHistory.csv"),FILE_CSV|FILE_WRITE,'\t');
   double initial_deposit=CalculateInitialDepositInPoints();
   CalculateSummaryInPoints(initial_deposit,handle);
   WriteReportInPoints(StringConcatenate(AccountNumber(),"_Summary.txt"));
//----
   if(handle>0) FileClose(handle);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateSummaryInPoints(double initial_deposit,int handle)
  {
   int    sequence=0, profitseqs=0, lossseqs=0;
   double sequential=0.0, prevprofit=EMPTY_VALUE, drawdownpercent, drawdown;
   double maxpeak=initial_deposit, minpeak=initial_deposit, balance=initial_deposit;
   int    trades_total=HistoryTotal();
   string order_symbol="";
   double point_value;
//---- initialize summaries
   InitializeSummaries(initial_deposit);
   if(handle>0) FileWrite(handle,"Order","Open time","Type","Lots","Symbol","Open price","StopLoss","TakeProfit","Close time","Close price","Profit in points","Balance in points","Comment","Magic");
//----
   for(int i=0; i<trades_total; i++)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- market orders only
      if(type!=OP_BUY && type!=OP_SELL) continue;
      //---- calculate profit in points
      if(order_symbol!=OrderSymbol())
        {
         order_symbol=OrderSymbol();
         point_value=MarketInfo(order_symbol,MODE_POINT);
        }
      if(point_value==0) continue;
      double open_price=OrderOpenPrice();
      double close_price=OrderClosePrice();
      double profit=(close_price-open_price)/point_value;
      if(type==OP_SELL) profit=-profit;
      balance+=profit;
      //---- output trade line
      string command="sell";
      if(type==OP_BUY) command="buy";
      if(handle>0) FileWrite(handle,OrderTicket(),TimeToStr(OrderOpenTime()),command,OrderLots(),order_symbol,open_price,OrderStopLoss(),OrderTakeProfit(),TimeToStr(OrderCloseTime()),close_price,profit,balance,OrderComment(),OrderMagicNumber());
      //---- drawdown check
      if(maxpeak<balance)
        {
         drawdown=maxpeak-minpeak;
         if(maxpeak!=0.0)
           {
            drawdownpercent=drawdown/maxpeak*100.0;
            if(RelDrawdownPercent<drawdownpercent)
              {
               RelDrawdownPercent=drawdownpercent;
               RelDrawdown=drawdown;
              }
           }
         if(MaxDrawdown<drawdown)
           {
            MaxDrawdown=drawdown;
            if(maxpeak!=0.0) MaxDrawdownPercent=MaxDrawdown/maxpeak*100.0;
            else MaxDrawdownPercent=100.0;
           }
         maxpeak=balance;
         minpeak=balance;
        }
      if(minpeak>balance) minpeak=balance;
      if(MaxLoss>balance) MaxLoss=balance;
      SummaryProfit+=profit;
      SummaryTrades++;
      if(type==OP_BUY) LongTrades++;
      else             ShortTrades++;
      //---- loss trades
      if(profit<0)
        {
         LossTrades++;
         GrossLoss+=profit;
         if(MinProfit>profit) MinProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit>=0)
           {
            if(ConProfitTrades1<sequence ||
               (ConProfitTrades1==sequence && ConProfit2<sequential))
              {
               ConProfitTrades1=sequence;
               ConProfit1=sequential;
              }
            if(ConProfit2<sequential ||
               (ConProfit2==sequential && ConProfitTrades1<sequence))
              {
               ConProfit2=sequential;
               ConProfitTrades2=sequence;
              }
            profitseqs++;
            AvgConWinners+=sequence;
            sequence=0;
            sequential=0.0;
           }
        }
      //---- profit trades (profit>=0)
      else
        {
         ProfitTrades++;
         if(type==OP_BUY) WinLongTrades++;
         else             WinShortTrades++;
         GrossProfit+=profit;
         if(MaxProfit<profit) MaxProfit=profit;
         //---- fortune changed
         if(prevprofit!=EMPTY_VALUE && prevprofit<0)
           {
            if(ConLossTrades1<sequence ||
               (ConLossTrades1==sequence && ConLoss2>sequential))
              {
               ConLossTrades1=sequence;
               ConLoss1=sequential;
              }
            if(ConLoss2>sequential ||
               (ConLoss2==sequential && ConLossTrades1<sequence))
              {
               ConLoss2=sequential;
               ConLossTrades2=sequence;
              }
            lossseqs++;
            AvgConLosers+=sequence;
            sequence=0;
            sequential=0.0;
           }
        }
      sequence++;
      sequential+=profit;
      //----
      prevprofit=profit;
     }
//---- final drawdown check
   drawdown=maxpeak-minpeak;
   if(maxpeak!=0.0)
     {
      drawdownpercent=drawdown/maxpeak*100.0;
      if(RelDrawdownPercent<drawdownpercent)
        {
         RelDrawdownPercent=drawdownpercent;
         RelDrawdown=drawdown;
        }
     }
   if(MaxDrawdown<drawdown)
     {
      MaxDrawdown=drawdown;
      if(maxpeak!=0) MaxDrawdownPercent=MaxDrawdown/maxpeak*100.0;
      else MaxDrawdownPercent=100.0;
     }
//---- consider last trade
   if(prevprofit!=EMPTY_VALUE)
     {
      profit=prevprofit;
      if(profit<0)
        {
         if(ConLossTrades1<sequence ||
            (ConLossTrades1==sequence && ConLoss2>sequential))
           {
            ConLossTrades1=sequence;
            ConLoss1=sequential;
           }
         if(ConLoss2>sequential ||
            (ConLoss2==sequential && ConLossTrades1<sequence))
           {
            ConLoss2=sequential;
            ConLossTrades2=sequence;
           }
         lossseqs++;
         AvgConLosers+=sequence;
        }
      else
        {
         if(ConProfitTrades1<sequence ||
            (ConProfitTrades1==sequence && ConProfit2<sequential))
           {
            ConProfitTrades1=sequence;
            ConProfit1=sequential;
           }
         if(ConProfit2<sequential ||
            (ConProfit2==sequential && ConProfitTrades1<sequence))
           {
            ConProfit2=sequential;
            ConProfitTrades2=sequence;
           }
         profitseqs++;
         AvgConWinners+=sequence;
        }
     }
//---- collecting done
   double dnum, profitkoef=0.0, losskoef=0.0, avgprofit=0.0, avgloss=0.0;
//---- average consecutive wins and losses
   dnum=AvgConWinners;
   if(profitseqs>0) AvgConWinners=dnum/profitseqs+0.5;
   dnum=AvgConLosers;
   if(lossseqs>0)   AvgConLosers=dnum/lossseqs+0.5;
//---- absolute values
   if(GrossLoss<0.0) GrossLoss*=-1.0;
   if(MinProfit<0.0) MinProfit*=-1.0;
   if(ConLoss1<0.0)  ConLoss1*=-1.0;
   if(ConLoss2<0.0)  ConLoss2*=-1.0;
//---- profit factor
   if(GrossLoss>0.0) ProfitFactor=GrossProfit/GrossLoss;
//---- expected payoff
   if(ProfitTrades>0) avgprofit=GrossProfit/ProfitTrades;
   if(LossTrades>0)   avgloss  =GrossLoss/LossTrades;
   if(SummaryTrades>0)
     {
      profitkoef=1.0*ProfitTrades/SummaryTrades;
      losskoef=1.0*LossTrades/SummaryTrades;
      ExpectedPayoff=profitkoef*avgprofit-losskoef*avgloss;
     }
//---- absolute drawdown
   AbsoluteDrawdown=initial_deposit-MaxLoss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeSummaries(double initial_deposit)
  {
   InitialDeposit=initial_deposit;
   MaxLoss=initial_deposit;
   SummaryProfit=0.0;
   GrossProfit=0.0;
   GrossLoss=0.0;
   MaxProfit=0.0;
   MinProfit=0.0;
   ConProfit1=0.0;
   ConProfit2=0.0;
   ConLoss1=0.0;
   ConLoss2=0.0;
   MaxDrawdown=0.0;
   MaxDrawdownPercent=0.0;
   RelDrawdownPercent=0.0;
   RelDrawdown=0.0;
   ExpectedPayoff=0.0;
   ProfitFactor=0.0;
   AbsoluteDrawdown=0.0;
   SummaryTrades=0;
   ProfitTrades=0;
   LossTrades=0;
   ShortTrades=0;
   LongTrades=0;
   WinShortTrades=0;
   WinLongTrades=0;
   ConProfitTrades1=0;
   ConProfitTrades2=0;
   ConLossTrades1=0;
   ConLossTrades2=0;
   AvgConWinners=0;
   AvgConLosers=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateInitialDepositInPoints()
  {
   string order_symbol="";
   double point_value,initial_deposit=0;
//----
   for(int i=HistoryTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) continue;
      int type=OrderType();
      //---- market orders only
      if(type!=OP_BUY && type!=OP_SELL) continue;
      //---- calculate profit in points
      if(order_symbol!=OrderSymbol())
        {
         order_symbol=OrderSymbol();
         point_value=MarketInfo(order_symbol,MODE_POINT);
        }
      if(point_value==0) { OrderPrint(); continue; }
      double profit=(OrderClosePrice()-OrderOpenPrice())/point_value;
      if(type==OP_SELL) profit=-profit;
      //---- and decrease balance
      initial_deposit-=profit;
      //---- amnesty
      if(initial_deposit<0) initial_deposit=0;
     }
//----
   return(initial_deposit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteReportInPoints(string report_name)
  {
   int handle=FileOpen(report_name,FILE_CSV|FILE_WRITE,'\t');
   if(handle<1) return;
//----
   FileWrite(handle,"Initial deposit in points ",InitialDeposit);
   FileWrite(handle,"Total net profit          ",SummaryProfit);
   FileWrite(handle,"Gross profit              ",GrossProfit);
   FileWrite(handle,"Gross loss                ",-GrossLoss);
   if(GrossLoss>0.0)
      FileWrite(handle,"Profit factor             ",ProfitFactor);
   FileWrite(handle,"Expected payoff           ",ExpectedPayoff);
   FileWrite(handle,"Absolute drawdown         ",AbsoluteDrawdown);
   FileWrite(handle,"Maximal drawdown          ",MaxDrawdown,StringConcatenate("(",MaxDrawdownPercent,"%)"));
   FileWrite(handle,"Relative drawdown         ",StringConcatenate(RelDrawdownPercent,"%"),StringConcatenate("(",RelDrawdown,")"));
   FileWrite(handle,"Trades total              ",SummaryTrades);
   if(ShortTrades>0)
      FileWrite(handle,"Short positions(won %)    ",ShortTrades,StringConcatenate("(",100.0*WinShortTrades/ShortTrades,"%)"));
   if(LongTrades>0)
      FileWrite(handle,"Long positions(won %)     ",LongTrades,StringConcatenate("(",100.0*WinLongTrades/LongTrades,"%)"));
   if(ProfitTrades>0)
      FileWrite(handle,"Profit trades (% of total)",ProfitTrades,StringConcatenate("(",100.0*ProfitTrades/SummaryTrades,"%)"));
   if(LossTrades>0)
      FileWrite(handle,"Loss trades (% of total)  ",LossTrades,StringConcatenate("(",100.0*LossTrades/SummaryTrades,"%)"));
   FileWrite(handle,"Largest profit trade      ",MaxProfit);
   FileWrite(handle,"Largest loss trade        ",-MinProfit);
   if(ProfitTrades>0)
      FileWrite(handle,"Average profit trade      ",GrossProfit/ProfitTrades);
   if(LossTrades>0)
      FileWrite(handle,"Average loss trade        ",-GrossLoss/LossTrades);
   FileWrite(handle,"Average consecutive wins  ",AvgConWinners);
   FileWrite(handle,"Average consecutive losses",AvgConLosers);
   FileWrite(handle,"Maximum consecutive wins (profit in points)",ConProfitTrades1,StringConcatenate("(",ConProfit1,")"));
   FileWrite(handle,"Maximum consecutive losses (loss in points)",ConLossTrades1,StringConcatenate("(",-ConLoss1,")"));
   FileWrite(handle,"Maximal consecutive profit (count of wins) ",ConProfit2,StringConcatenate("(",ConProfitTrades2,")"));
   FileWrite(handle,"Maximal consecutive loss (count of losses) ",-ConLoss2,StringConcatenate("(",ConLossTrades2,")"));
//----
   FileClose(handle);
  }
//+------------------------------------------------------------------+