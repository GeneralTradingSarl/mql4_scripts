//+------------------------------------------------------------------+
//|                                            MAE_MFE_DrawDowns.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

// pasted from the SummaryReport script
#define OP_BALANCE 6
#define OP_CREDIT  7
#define StatParameters 8
// pasted from the SummaryReport script
#property show_inputs
#property strict
extern int MaxTimeMissed=15;   // max allowed gap in loaded M1 history
//+------------------------------------------------------------------+
//| Fill the MAE arrays in deposit currency                          |
//+------------------------------------------------------------------+
bool SetMAEAndMFE(double  &MFE_Array[],double  &MAE_Array[],const int &TicketsArray[])
  {
   bool res=false;
//----
   int bar,i,limit=ArraySize(TicketsArray);
   ArrayResize(MAE_Array,limit);
   ArrayResize(MFE_Array,limit);
   int openShift,closeShift;
   int type,znak,K_spread;
   double spread,symPoint;
   double MFE_points,MAE_points;
   double currProfit,currLoss;
   double buy,sell,OPrice,PointCost;
   double deltaPricePoints;
//----
//Print("Step into 1");

   for(i=0;i<limit;i++)
     {
      //Print("Step into 2");

      if(OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
        {
         openShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         closeShift=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         //Print("History to calculate MFE by order #",TicketsArray[i]," there are ",openShift-closeShift," M1 bars, time in minutes ",DoubleToStr((OrderCloseTime()-OrderOpenTime())/60.0,0));
         //if (openShift==-1 || closeShift==-1) Print("Not enough history to calculate MFE by order #",TicketsArray[i]);
         type=OrderType();
         OPrice=OrderOpenPrice();
         if(type==OP_BUY)
           {
            znak=1;
            K_spread=0;
            buy=1;
            sell=0;
           }
         else
           {
            znak=-1;
            K_spread=1;
            buy=0;
            sell=1;
           }
         spread=MarketInfo(OrderSymbol(),MODE_SPREAD);
         symPoint=MarketInfo(OrderSymbol(),MODE_POINT);
         //Print("spread=",spread,"   symPoint=",symPoint);
         //if (openShift-closeShift>0)
         MFE_points=-10000;
         MAE_points=-10000;
         deltaPricePoints=(OrderOpenPrice()-OrderClosePrice())/symPoint;
         if(deltaPricePoints==0)
           {
            //Print("If there will be division by zero in the SetMAEAndMFE function, profit will be equal to zero");
            PointCost=MarketInfo(OrderSymbol(),MODE_POINT)*MarketInfo(OrderSymbol(),MODE_LOTSIZE);
            string first   =StringSubstr(OrderSymbol(),0,3);         // first symbol, e.g. EUR
            string second  =StringSubstr(OrderSymbol(),3,3);         // second symbol, e.g. USD
            string currency=AccountCurrency();                       // deposit currency, e.g. USD
            if(second==currency) PointCost=PointCost*OrderLots();
            else
              {
               string crossCurrency=StringConcatenate(second,currency);
               int barCross=iBarShift(crossCurrency,PERIOD_M1,OrderOpenTime());
               double CrossRate=iOpen(crossCurrency,PERIOD_M1,barCross);
               PointCost=PointCost*OrderLots()*CrossRate;
              }
           }
         else PointCost=MathAbs((OrderProfit())/deltaPricePoints);
         //else PointCost=MathAbs((OrderProfit()+OrderSwap())/deltaPricePoints);
         //Print("Order #",TicketsArray[i]," opened by price ",OPrice);
         for(bar=openShift;bar>=closeShift;bar--)
           {
            //currProfit=(OrderOpenPrice()-Low[bar])*znak-K_spread*spread*symPoint;
            currProfit=(iHigh(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iLow(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            currLoss=(iLow(OrderSymbol(),PERIOD_M1,bar)-OPrice)*buy-(iHigh(OrderSymbol(),PERIOD_M1,bar)+spread*symPoint-OPrice)*sell;
            if(iHigh(OrderSymbol(),PERIOD_M1,bar)==0) Print("2% For order #",TicketsArray[i],"  by symbol ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  problem accessing iHigh(OrderSymbol(),PERIOD_M1,bar) by time ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));
            if(iLow(OrderSymbol(),PERIOD_M1,bar)==0) Print("2%For order #",TicketsArray[i],"  by symbol ",OrderSymbol()," openShift=",openShift," closeShift=",closeShift,"  problem accessing iLow(OrderSymbol(),PERIOD_M1,bar) by time ",TimeToStr(iTime(OrderSymbol(),PERIOD_M1,bar)));

            //Print("currProfit=",currProfit,"   currLoss=",currLoss,"   OPrice=",OPrice);
            //if (currProfit>0 && currProfit/symPoint>MFE_points) 
            if(currProfit/symPoint>MFE_points)
              {
               MFE_points=currProfit/symPoint;
               //Print("currProfit=",currProfit/symPoint);
              }
            //if (currLoss<0 && -currLoss/symPoint>MAE_points) 
            if(-currLoss/symPoint>MAE_points)
              {
               MAE_points=-currLoss/symPoint;
               //Print("currLoss=",currLoss/symPoint);
              }
           }
         MFE_Array[i]=MFE_points*PointCost;
         MAE_Array[i]=-MAE_points*PointCost;

         if(MathAbs(MFE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFE_Array[i]=",MFE_Array[i],"  MFE_points=",MFE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);
         if(MathAbs(MAE_Array[i])>10000) Print(OrderSymbol()," #",TicketsArray[i],"; MFA_Array[i]=",MAE_Array[i],"  MAE_points=",MAE_points,"  PointCost=",PointCost,"  symPoint=",symPoint,"  OrderProfit()=",OrderProfit(),"  deltaPrice=",deltaPricePoints);

         //Print("#",TicketsArray[i],";",MFE_Array[i],";",MAE_Array[i]);
        }
      else
        {
         Alert("Failed to select order #",TicketsArray[i]);
        }
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//|  Fills values of profits and losses                              |
//+------------------------------------------------------------------+
void    FillOrderProfits(double  &ProfitsArray[],double  &NormalizedProfitsArray[],double  &SwapArray[],const int &TicketsArray[])
  {
   int total=ArraySize(TicketsArray);
   ArrayResize(ProfitsArray,total);
   ArrayResize(SwapArray,total);
   ArrayResize(NormalizedProfitsArray,total);
//----
   for(int i=0;i<total;i++)
     {
      if(OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
        {
         ProfitsArray[i]=OrderProfit()+OrderSwap()-OrderCommission();
         SwapArray[i]=OrderSwap();
         if(OrderLots()!=0) NormalizedProfitsArray[i]=0.1*ProfitsArray[i]/OrderLots();
         else Alert("Found order with zero value of lot #",TicketsArray[i]);
        }
      else
        {
         Alert("Failed to select order #",TicketsArray[i]);
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Returns array of tickets sorted by close time                    |
//+------------------------------------------------------------------+
int LoadSortedTickets(int  &Tickets[])
  {
   int i,counter=0;
   int TicketAndTime[][2];
//----
   if(ArraySize(Tickets)==0) return(0);
   ArrayResize(TicketAndTime,OrdersHistoryTotal());

   for(i=0;i<OrdersHistoryTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderType()<=OP_SELL)
           {
            TicketAndTime[counter][0]=(int)OrderCloseTime();
            TicketAndTime[counter][1]=(int)OrderTicket();
            counter++;
           }
        }
     }
   ArrayResize(TicketAndTime,counter);
   ArrayResize(Tickets,counter);
   ArraySort(TicketAndTime);
   for(i=0;i<counter;i++)
     {
      Tickets[i]=TicketAndTime[i][1];
     }
   int err=GetLastError();
//----
   return(counter);
  }
//+------------------------------------------------------------------+
//| Returns true, if symbol with the symbolName is already present   |
//+------------------------------------------------------------------+
bool AddSymbol(string  &SimbolListArray[],string symbolName)
  {
   bool res=false;
   int size=ArraySize(SimbolListArray);
//----
//Print("Add symbol ",symbolName);
   ArrayResize(SimbolListArray,size+1);
   if(ArraySize(SimbolListArray)==size+1)
     {
      SimbolListArray[size]=StringTrimLeft(StringTrimRight(symbolName));
      res=true;
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Returns true, if symbol with the symbolName is already present   |
//+------------------------------------------------------------------+
bool SymbolFoundInArray(const string &SimbolListArray[],string symbolName)
  {
   bool res=false;
   int pos;
//----
   for(int i=0;i<ArraySize(SimbolListArray);i++)
     {
      pos=StringFind(SimbolListArray[i],StringTrimLeft(StringTrimRight(symbolName)));
      if(pos!=-1 && pos==0)
        {
         if(StringLen(SimbolListArray[i])!=StringLen(StringTrimLeft(StringTrimRight(symbolName))))
           {
            //Print("Finding new symbol in array ended up with surprise");
            //Print("first=|",SimbolListArray[i],"| second=|",symbolName,"|");
           }
         res=true;
         break;
        }
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Calculates number of open and canceled orders                    |
//+------------------------------------------------------------------+
bool GetNumberOfOrders(int  &Closed,int  &Cancelled,string  &SymbolsArray[])
  {
   bool res=false;
//Print("Orders in history ",OrdersHistoryTotal());
//----
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderType()==OP_BALANCE) continue;
         if(!SymbolFoundInArray(SymbolsArray,OrderSymbol()))
            AddSymbol(SymbolsArray,OrderSymbol());
         if(OrderType()>OP_SELL) Cancelled++;
         else Closed++;
        }
     }
   if(Cancelled+Closed>0) res=true;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Returns index of the found FindName string                       |
//+------------------------------------------------------------------+
int IndexOfName(string  &StringArray[],string FindName)
  {
   int res=-1000;
//----
   int total=ArraySize(StringArray);
   for(int i=0;i<total;i++)
      if(StringArray[i]==FindName)
        {
         res=i;
         break;
        }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Check M1 history for gaps                                        |
//+------------------------------------------------------------------+
bool    CheckHistoryOnClosedOrders(int  &ClosedTicketsArray[],string  &SymbolsForClosedOrders[])
  {
   bool res=true;
   int errors[][3];  // first element - index of symbol, second - ticket of order, third - date/time of error
   ArrayResize(errors,1000);
   int errCounter=0;    // errors counter
   int openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
   int closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
   int TimeInterval[][2];// first element - start date of gap, second element - end date of gap
   int indexSymbol;
   datetime timeClose;
//----
   int i,number_orders=ArraySize(ClosedTicketsArray),number_symbols=ArraySize(SymbolsForClosedOrders);
   ArrayResize(TimeInterval,number_symbols);
   for(i=0;i<number_symbols;i++) TimeInterval[i][0]=(int)TimeCurrent();
//----
   for(i=0;i<number_orders;i++)
     {
      if(OrderSelect(ClosedTicketsArray[i],SELECT_BY_TICKET))
        {
         openBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime());
         if(OrderCloseTime()!=0) closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,OrderCloseTime());
         else closeBar_M1=iBarShift(OrderSymbol(),PERIOD_M1,TimeCurrent());
         indexSymbol=IndexOfName(SymbolsForClosedOrders,OrderSymbol());
         if(MathAbs(iTime(OrderSymbol(),PERIOD_M1,openBar_M1)-OrderOpenTime())/60>MaxTimeMissed)
           {
            if(errCounter==ArraySize(errors)/3)
              {
               ArrayResize(errors,errCounter+10);
              }
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=(int)OrderOpenTime();
            res=false;
            if(OrderOpenTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=(int)OrderOpenTime();
            if(OrderOpenTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=(int)OrderOpenTime();
            //Print("Error finding the opening bar on symbol ",OrderSymbol()," M1 for order #",ClosedTicketsArray[i],"=>",TimeToStr(OrderOpenTime()));
            errCounter++;
           }
         if(OrderCloseTime()!=0) timeClose=OrderCloseTime();
         else timeClose=TimeCurrent();
         if(MathAbs(iTime(OrderSymbol(),PERIOD_M1,closeBar_M1)-timeClose)/60>MaxTimeMissed)
           {
            errors[errCounter][0]=indexSymbol;
            errors[errCounter][1]=ClosedTicketsArray[i];
            errors[errCounter][2]=(int)OrderCloseTime();
            res=false;
            if(OrderCloseTime()<TimeInterval[indexSymbol][0]) TimeInterval[indexSymbol][0]=(int)timeClose;
            if(OrderCloseTime()>TimeInterval[indexSymbol][1]) TimeInterval[indexSymbol][1]=(int)timeClose;
            Print("Error finding the closing bar on symbol ",OrderSymbol()," M1 for order #",ClosedTicketsArray[i],"=>",TimeToStr(timeClose));
            errCounter++;
           }
        }
     }
//----
   if(!res)
     {
      Alert("Found errors of M1 gaps in available history, when checking account - ",errCounter,"! See the Journal tab for more details");
      for(i=0;i<number_symbols;i++)
        {
         if(TimeInterval[i][0]*TimeInterval[i][1]!=0) Print("Not enough history for ",SymbolsForClosedOrders[i]," on the interval: ",TimeToStr(TimeInterval[i][0]),"-",TimeToStr(TimeInterval[i][1]));
        }
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Calculate all drawdowns                                          |
//+------------------------------------------------------------------+
bool CalculateDD(int  &ClosedTicketsArray[],string  &SymbolsArray[],double  &minEquity,double  &MoneyDD,
                 double  &MoneyDDPer,double  &RelativeDD,double  &RelativeDDMoney)
  {
   bool res=false;
//----
   int AllOpenedOrdersTickets[];           // array of closed orders from history + currently open orders
   int ConveyerArray[][2];                 // first element - time, second - ticket
//----
   int i,k=0,marketOrders=0;
   for(i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY || OrderType()==OP_SELL) marketOrders++;
        }
     }
//Print("marketOrders=",marketOrders,",  orders in history=",ArraySize(ClosedTicketsArray));
   if(ArraySize(ClosedTicketsArray)+marketOrders==0)
     {
      Print("No orders for processing");
     }
   ArrayResize(AllOpenedOrdersTickets,ArraySize(ClosedTicketsArray)+marketOrders);
//----
   i=0;
   if(ArraySize(ClosedTicketsArray)>0) for(i=0;i<ArraySize(ClosedTicketsArray);i++) AllOpenedOrdersTickets[i]=ClosedTicketsArray[i];
//Print("AllOpenedOrdersTickets=",ArraySize(AllOpenedOrdersTickets));
   if(marketOrders>0)
     {
      while(k<marketOrders)
        {
         if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               AllOpenedOrdersTickets[i]=OrderTicket();
               //Print("i=",i,"   k=",k,"  ticket=",OrderTicket());
               if(!SymbolFoundInArray(SymbolsArray,OrderSymbol())) AddSymbol(SymbolsArray,OrderSymbol());
               i++;
              }
            else Alert("Failed to select order!!!");
           }
         k++;
        }
     }
   if(!CheckHistoryOnClosedOrders(AllOpenedOrdersTickets,SymbolsArray))   return(false);
   ArrayResize(ConveyerArray,ArraySize(AllOpenedOrdersTickets)*2);
//Print("Size of conveyor=",ArrayRange(ConveyerArray,0));
   for(i=0;i<ArrayRange(AllOpenedOrdersTickets,0);i++)
     {
      //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]);
      if(OrderSelect(AllOpenedOrdersTickets[i],SELECT_BY_TICKET))
        {
         //Print("i=",i,"   ticket=",AllOpenedOrdersTickets[i]," OrderOpenTime=",TimeToStr(OrderOpenTime())," OrderCloseTime=",TimeToStr(OrderCloseTime()));
         ConveyerArray[2*i][0]=(int)OrderOpenTime();
         ConveyerArray[2*i][1]=AllOpenedOrdersTickets[i];
         if(OrderCloseTime()!=0) ConveyerArray[2*i+1][0]=(int)OrderCloseTime();
         else ConveyerArray[2*i+1][0]=(int)TimeCurrent()+200;
         ConveyerArray[2*i+1][1]=-AllOpenedOrdersTickets[i];
        }
      else Alert("Failed to select orders when calculating drawdowns!!!");
     }
   ArraySort(ConveyerArray);      // sort conveyor by time of events: opening-closing orders
                                  //for (i=0;i<ArrayRange(ConveyerArray,0);i++) Print(TimeToStr(ConveyerArray[i][0])," - ", ConveyerArray[i][1]);
//----
   int ticket=OrderSelect(ConveyerArray[0][1],SELECT_BY_TICKET);
   string SymbolName=OrderSymbol();
   int max=ArrayRange(ConveyerArray,0);
//----
   datetime startTrade=TimeRoundeMinute(ConveyerArray[0][0]);
   datetime stopTrade=TimeRoundeMinute(ConveyerArray[max-1][0]);
   if(stopTrade>TimeCurrent()) stopTrade=TimeCurrent();
//----
   double balance=10000;         // initial deposit value equals to 10 000
   double minimalEquity=balance; // initial deposit value equals to 10 000
   double lastPeak=balance;      // last maximum of equity
   double lastMin=balance;       // last minimum of equity
   double equity;                // current equity
   double MaxProfit,MinProfit,FixedProfit;
   double currDD,lastmaxDD=0,currPercentDD,lastPercentDD=0;
   int curr_pos;
   int stack[];
   datetime curr_minute;
   equity=balance;
   int FileHandle;
//   Print("Start date ",TimeToStr(startTrade,TIME_DATE|TIME_SECONDS),
//      ", end date ",TimeToStr(stopTrade,TIME_DATE|TIME_SECONDS));
   FileHandle=FileOpen(IntegerToString(AccountNumber())+"_equity_2.csv",FILE_CSV|FILE_WRITE);
   FileWrite(FileHandle,"Date","BALANCE","EQUITY");
   FileWrite(FileHandle,TimeToStr(startTrade-1),balance,equity);
   for(curr_minute=startTrade;curr_minute<=stopTrade;curr_minute=curr_minute+60)
     {
      SetStack(stack,ConveyerArray,curr_minute,curr_pos);
      CheckAllProfits(stack,MaxProfit,MinProfit,curr_minute);
      equity=balance+(MaxProfit+MinProfit)/2;
      //      Print("balance=",balance);
      if(equity>lastPeak)
        {
         lastPeak=equity;
         lastMin=equity;
        }
      if(equity<lastMin)
        {
         lastMin=equity;
         currDD=lastPeak-lastMin;
         if(currDD>lastmaxDD)
           {
            lastmaxDD=currDD;
            MoneyDDPer=(lastmaxDD)/lastPeak*100;
            MoneyDD=lastmaxDD;
           }
         currPercentDD=currDD/lastPeak*100;
         if(currPercentDD>lastPercentDD)
           {
            lastPercentDD=currPercentDD;
            RelativeDD=lastPercentDD;
            RelativeDDMoney=currDD;
           }
        }
      //----
      if(lastMin<minimalEquity)
        {
         minimalEquity=lastMin;
        }
      //----
      CloseTickets(stack,curr_minute,FixedProfit);
      balance=balance+FixedProfit;
      FileWrite(FileHandle,TimeToStr(curr_minute),balance,equity);
     }
   FileClose(FileHandle);
   minEquity=minimalEquity;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Summarize profits by opened tickets                              |
//+------------------------------------------------------------------+
bool   CheckAllProfits(const int &stackTickets[],double  &maxProfit,double  &minProfit,datetime this_minute)
  {
   bool res=false;
   maxProfit=0;
   minProfit=0;
   double thisOrderMaxProfit,thisOrderMinProfit;
//----
   int i;
   for(i=0;i<ArraySize(stackTickets);i++)
     {
      if(GetProfit(stackTickets[i],thisOrderMaxProfit,thisOrderMinProfit,this_minute))
        {
         //Print("Calculated profit for order #",stackTickets[i]," at ",TimeToStr(this_minute));
         //Print("thisOrderMaxProfit=",thisOrderMaxProfit,"   thisOrderMinProfit=",thisOrderMinProfit);
         maxProfit+=thisOrderMaxProfit;
         minProfit+=thisOrderMinProfit;
        }
      else Print("Failed to determine current profit for order #",stackTickets[i]);
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Returns minimum/maximum profit for order                         |
//+------------------------------------------------------------------+
bool GetProfit(int ticket,double  &maxProf,double  &minProf,datetime at_minute)
  {
   bool res=true;
//----
   string symbol,crossPair,firstCurrency,secondCurrency,baseCurrency=AccountCurrency();
   int bar,type,err;
   double openPrice,spread,point,pointCost=0,lots,price;
   datetime foundedTime;
   minProf=0;
   maxProf=0;
//Print("Get value of profit for order #",ticket);
   if(ticket<0) return(res);
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      symbol=OrderSymbol();
      firstCurrency=StringSubstr(OrderSymbol(),0,3);
      secondCurrency=StringSubstr(OrderSymbol(),3,3);
      //Print("base=",baseCurrency,"   firstCurrency=",firstCurrency,"   secondCurrency=",secondCurrency);
      type=OrderType();
      openPrice=OrderOpenPrice();
      bar=iBarShift(symbol,PERIOD_M1,at_minute);
      foundedTime=iTime(symbol,PERIOD_M1,bar);
      spread=MarketInfo(symbol,MODE_SPREAD);
      point=MarketInfo(symbol,MODE_POINT);
      lots=OrderLots();
      if(firstCurrency==baseCurrency)
        {
         price=(iHigh(symbol,PERIOD_M1,bar)+iLow(symbol,PERIOD_M1,bar))/2;
         //Print("price=",price);
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
        }
      if(secondCurrency==baseCurrency)
        {
         pointCost=point*MarketInfo(symbol,MODE_LOTSIZE);
        }
      if(firstCurrency!=baseCurrency && secondCurrency!=baseCurrency)
        {
         //Print("Cross ",symbol);
         if(MarketInfo(secondCurrency+baseCurrency,MODE_BID)>0)
           {
            crossPair=StringConcatenate(secondCurrency,baseCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)*price;
           }
         if(MarketInfo(baseCurrency+secondCurrency,MODE_BID)>0)
           {
            crossPair=StringConcatenate(baseCurrency,secondCurrency);
            price=(iHigh(crossPair,PERIOD_M1,bar)+iLow(crossPair,PERIOD_M1,bar))/2;
            //Print(crossPair,"=",price,"   ",TimeToStr(foundedTime));
            pointCost=point*MarketInfo(symbol,MODE_LOTSIZE)/price;
           }
         //----
         err=GetLastError();
         //Print("Error accessing price ",crossPair," M1 at ",TimeToStr(at_minute));
        }
      //Print("Point cost for order #",ticket," is ",pointCost);

      if(foundedTime!=TimeRoundeMinute(at_minute))
        {
         //Print("Error of time mismatch for ",symbol," M1 at ",TimeToStr(at_minute));
         //Print("        foundedTime=",TimeToStr(foundedTime));
        }
      if(type==OP_BUY)
        {
         maxProf=(iHigh(symbol,PERIOD_M1,bar)-openPrice)/point;
         minProf=(iLow(symbol,PERIOD_M1,bar)-openPrice)/point;
        }
      if(type==OP_SELL)
        {
         maxProf=(openPrice-iHigh(symbol,PERIOD_M1,bar))/point+spread;
         minProf=(openPrice-iLow(symbol,PERIOD_M1,bar))/point+spread;
        }
      maxProf=maxProf*lots*pointCost;
      minProf=minProf*lots*pointCost;
      //Print("maxProf=",maxProf,"   minProf=",minProf," at ",TimeToStr(at_minute));
     }
   else
     {
      res=false;
      Print("Failed to select order #",ticket," at ",TimeToStr(at_minute),". GetProfit() function");
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Close needed orders and return result of closed orders           |
//+------------------------------------------------------------------+
bool CloseTickets(int  &stackTickets[],datetime this_minute,double  &fixedProfit)
  {
   bool res=false;
//----
   int toCloseTickets[];
   int closedCounter=0;
   fixedProfit=0;
   for(int i=0;i<ArraySize(stackTickets);i++)
     {
      if(OrderSelect(stackTickets[i],SELECT_BY_TICKET))
        {
         if(TimeRoundeMinute(OrderCloseTime())==TimeRoundeMinute(this_minute) && stackTickets[i]>=0)
           {
            fixedProfit=fixedProfit+OrderProfit()+OrderSwap()-OrderCommission();
            AddTicketToClose(toCloseTickets,stackTickets[i]);
            //Print("Remove from stack order #",stackTickets[i]," at ",TimeToStr(this_minute));
            closedCounter++;
           }
        }
     }
   if(closedCounter>0)
     {
      res=true;
      for(int i=0;i<closedCounter;i++)
        {
         if(!DeleteTicketFromStack(stackTickets,toCloseTickets[i])) Print("Failed to delete order #",toCloseTickets[i]);
         if(!DeleteTicketFromStack(stackTickets,-toCloseTickets[i])) Print("Failed to delete order #",-toCloseTickets[i]);
        }
      GetLastError();
      ArrayResize(toCloseTickets,0);
      if(GetLastError()>0) Print("Error setting zero size of array");
     }
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| Deletes closed orders from stack                                 |
//+------------------------------------------------------------------+
bool  DeleteTicketFromStack(int  &OpenedTicketsArray[],int ñlosedTicket)
  {
   bool res=false;
//----
   int i,pos,size=ArraySize(OpenedTicketsArray);
   for(i=0;i<size;i++)
     {
      if(OpenedTicketsArray[i]==ñlosedTicket)
        {
         pos=i;
         break;
        }
     }
   GetLastError();
   OpenedTicketsArray[pos]=OpenedTicketsArray[size-1];
   ArrayResize(OpenedTicketsArray,size-1);   // remove last element
   if(GetLastError()==0) res=true;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//|  Add TicketNumber to the Array array                             |
//+------------------------------------------------------------------+
bool  AddTicketToClose(int  &Array[],int TicketNumber)
  {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(Array);
   ArrayResize(Array,size+1);
   Array[size]=TicketNumber;
   if(GetLastError()==0) res=true;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//|  Proceed operations with tickets stack of opened orders          |
//+------------------------------------------------------------------+
void SetStack(int  &stackArray[],const int &Conveyer[][],datetime this_minute,int  &conveyer_pos)
  {
//----
   int list=ArrayRange(Conveyer,0);
//----
   while((TimeRoundeMinute(this_minute)==TimeRoundeMinute(Conveyer[conveyer_pos][0])))
     {
      AddTicketToStack(stackArray,Conveyer[conveyer_pos][1]);
      //Print("Add to stack order #",Conveyer[conveyer_pos][1]," at ",TimeToStr(this_minute));
      conveyer_pos++;
      if(conveyer_pos>=ArrayRange(Conveyer,0))
        {
         break;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Add tickets once again opened orders                              |
//+------------------------------------------------------------------+
bool AddTicketToStack(int  &stackArray[],int ticket)
  {
   bool res=false;
//----
   GetLastError();
   int size=ArraySize(stackArray);
   ArrayResize(stackArray,size+1);
   stackArray[size]=ticket;
   if(GetLastError()==0) res=true;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//|  Round date with minute precision                                |
//+------------------------------------------------------------------+
datetime TimeRoundeMinute(datetime in)
  {
   datetime res;
//----
   res=StrToTime(TimeToStr(in,TIME_DATE|TIME_MINUTES));
//----
   return(res);
  }
//+------------------------------------------------------------------+
//|  Write table of profits and corresponding MAE and MFE            |
//+------------------------------------------------------------------+
bool WriteMAE_MFE(const double &MFE_Array[],const double &MAE_Array[],const int &TicketsArray[],string FileName)
  {
   bool res=true;
   int i,FH,total=ArraySize(TicketsArray);
   string Line;
//----
   if(total==0) return(false);
   Print("Number of rows in MAE_MFE table is ",total);
   FH=FileOpen(FileName,FILE_READ|FILE_WRITE|FILE_CSV);
   if(FH>0)
     {
      FileWrite(FH,"Ticket #","MFE","P&L","MAE","P&L");

      for(i=0;i<total;i++)
         if(OrderSelect(TicketsArray[i],SELECT_BY_TICKET))
           {
            FileSeek(FH,0,SEEK_END);
            FileWrite(FH,OrderTicket(),MFE_Array[i],OrderProfit(),MAE_Array[i],OrderProfit());
           }
      FileClose(FH);
     }
   else res=false;
//----
   return(res);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   Print(AccountName());
   int ClosedOrders, CancelledOrders;      // number of opened and canceled orders
   int ClosedTickets[],CancelledTickets[]; // arrays of tickets of closed and canceled orders
   int AllOpenedOrdersTickets[];           // array of closed orders from history + currently open orders
   string Symbols[];                       // array of symbols by which there were deals
   double Swaps[];                         // swaps
   double Profits[],NormalizedProfits[];   // arrays of initial profits and profits normalized to 0.1 lot
   double MFE[];                           // array of maximum potential profits for each order
   double MAE[];                           // array of maximum drawdowns for each orders
   double AccountDetails[][9];
   double MinimalEquity;                   // minimum historical value of equity
   double MoneyDrawDown;                   // maximum money drawdown
   double MoneyDrawDownInPercent;          // maximum money drawdown in percents
   double RelativeDrawDown;                // maximum relative drawdown
   double RelativeDrawDownInMoney;         // maximum relative drawdown in money
//----
   if(!GetNumberOfOrders(ClosedOrders,CancelledOrders,Symbols))
     {
      Print("No orders found in history, processing has been canceled");
     }
//----
   ArrayResize(ClosedTickets,ClosedOrders);
   ArrayResize(CancelledTickets,CancelledOrders);
   ArrayResize(AccountDetails,ClosedOrders);
   ArrayResize(Swaps,ClosedOrders);
//----
   LoadSortedTickets(ClosedTickets);
   FillOrderProfits(Profits,NormalizedProfits,Swaps,ClosedTickets);

   if(CheckHistoryOnClosedOrders(ClosedTickets,Symbols)) // check for gaps in history
     {
      SetMAEAndMFE(MFE,MAE,ClosedTickets);                  // if there are now gaps - fill MAE and MFE
      WriteMAE_MFE(MFE,MAE,ClosedTickets,"MAE_MFE_reports\\"+IntegerToString(AccountNumber())+"_MAE_MFE.csv");
     }
   else return (0);
//----
   CalculateDD(ClosedTickets,Symbols,MinimalEquity,MoneyDrawDown,MoneyDrawDownInPercent,RelativeDrawDown,RelativeDrawDownInMoney);
   Print("AbsDD=",10000-MinimalEquity," MoneyDrawDown=",MoneyDrawDown,"  MoneyDrawDownInPercent=",MoneyDrawDownInPercent,
         "  RelativeDrawDown=",RelativeDrawDown," RelativeDrawDownInMoney=",RelativeDrawDownInMoney);
//----
   return(0);
  }
//+------------------------------------------------------------------+
