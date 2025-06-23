//+------------------------------------------------------------------+
//|                                    SCT_BestTimeStrategyWorks.mq4 |
//|                                    Copyright 2020, Forex Jarvis. |
//|                                            forexjarvis@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Forex Jarvis. forexjarvis@gmail.com"
#property version   "1.00"
#property strict
#property script_show_inputs

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

input datetime dStartingDate = D'2020.01.01 00:00:00';   // START DATE
input double   dWL = 40;                                 // Win/Loss ratio
input double   dRR = 2;                                  // Reward/Risk ratio

#define SIZE 5
double dAmtWon[24][SIZE];      // AMOUNT WON
double dAmtWonTotal;
double dAmtLoss[24][SIZE];     // AMOUNT LOSS
double dAmtLossTotal;
double dWins[24][SIZE];        // TRADES WON
double dWinsTotal;
double dLoss[24][SIZE];        // TRADES LOST
double dLossTotal;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
{

   int handle = FileOpen("BestTimeStrategyWorks"+".csv",FILE_CSV|FILE_READ|FILE_WRITE,',');

   int OrderHistory = OrdersHistoryTotal();
   int i;
   int j;
   
   int iDayOfWeek;
   string sDayOfWeek;
      
   if(handle>0) {

      FileSeek(handle,0,SEEK_SET);
      FileWrite(handle, "Day of week", "Hour of Day", "Sum of Wins", "Sum of Losses", "Sum of AmountWon", "Sum of AmountLost", "Win/Loss Ratio", "Reward/Risk Ratio");

		for (j = 0 ; j < OrderHistory ; j++)  {

   	   if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)) {
   			if (OrderCloseTime()>dStartingDate && OrderType()!=6) {
         
               datetime dtime    = OrderCloseTime();
               double profit     = OrderProfit();
               double commission = OrderCommission();

               iDayOfWeek = TimeDayOfWeek(dtime)-1;
               i=(int)StringSubstr(TimeToString(dtime, TIME_MINUTES),0,2);

   				if(profit>0){
                  dWins[i][iDayOfWeek] = dWins[i][iDayOfWeek]+1;
   					dAmtWon[i][iDayOfWeek] = dAmtWon[i][iDayOfWeek]+profit+2*commission;
   				} else {
   					dLoss[i][iDayOfWeek] = dLoss[i][iDayOfWeek]+1;
   					dAmtLoss[i][iDayOfWeek] = dAmtLoss[i][iDayOfWeek]+profit+2*commission;
   				}
            }
         }
      }
      
      double percent=0.0, percenttotal=0.0;
      double rr=0.0, rrtotal=0.0;
      int k, v;
            
      for (v=0; v<5; v++) {
         for (k=0; k<24; k++) {
            if (dWins[k][v]>0)
               percent = (dWins[k][v]/(dWins[k][v]+dLoss[k][v]))*100;
            else 
               percent = 0;
               
            if (dAmtLoss[k][v]!=0)
               rr= MathAbs(dAmtWon[k][v]/dAmtLoss[k][v]);
            else if (dAmtWon[k][v]!=0)
               rr=100;

            if (v==0) sDayOfWeek="Monday";
            else if (v==1) sDayOfWeek="Tuesday";
            else if (v==2) sDayOfWeek="Wednesday";
            else if (v==3) sDayOfWeek="Thursday";
            else if (v==4) sDayOfWeek="Friday";
         
            if(percent>dWL && rr>=dRR) {
               dWinsTotal=dWinsTotal+dWins[k][v];
               dLossTotal=dLossTotal+dLoss[k][v];
               dAmtWonTotal=dAmtWonTotal+dAmtWon[k][v];
               dAmtLossTotal=dAmtLossTotal+dAmtLoss[k][v];
               FileWrite(handle, sDayOfWeek, k, DoubleToString(dWins[k][v],0), DoubleToString(dLoss[k][v],0), DoubleToString(dAmtWon[k][v],1), DoubleToString(dAmtLoss[k][v],1), DoubleToString(percent,0), DoubleToString(rr,1));
            }
         }
      }
      
      if (dWinsTotal>0)
         percenttotal = (dWinsTotal/(dWinsTotal+dLossTotal))*100;
      else 
         percenttotal = 0;
         
      if (dAmtLossTotal!=0)
         rrtotal= MathAbs(dAmtWonTotal/dAmtLossTotal);
      else if (dAmtWonTotal!=0)
         rrtotal=100;
      
      FileWrite(handle, "\nBest strategy's performance with :\n* At least "+DoubleToString(dWL,0)+"% W/L Ratio and\n* At least "+DoubleToString(dRR,0)+"|1 R/R Ratio", "", DoubleToString(dWinsTotal,0), DoubleToString(dLossTotal,0), DoubleToString(dAmtWonTotal,1), DoubleToString(dAmtLossTotal,1), DoubleToString(percenttotal,0), DoubleToString(rrtotal,1));
       
   }
   
   FileClose(handle);

}