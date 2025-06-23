//+------------------------------------------------------------------+
//|                                                     StopLoss.mq4 |
//|                                                 Valdir Horodenko |
//|             https://br.linkedin.com/in/valdir-horodenko-a5963215 |
//+------------------------------------------------------------------+
#property copyright "Valdir Horodenko, https://br.linkedin.com/in/valdir-horodenko-a5963215"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#property show_inputs
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input int Number_EA=1; //Number Of EA
input int Stop_Loss=50;// Stop Loss in Pips
input bool Use_Take_Proft=false; //Use Take Profit 
input int Take_Profit=50; //Take Profit in Pips
input int Seconds_Time_Execution=5;//Time Of Execution, in seconds
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {

   PrintFormat("Number_EA=%d, Stop_Loss=%d,Seconds_Time_Execution=%d",Number_EA,Stop_Loss,Seconds_Time_Execution);
   int _time_execution=(Seconds_Time_Execution*1000);

   double Pip=0.0001;
   if(Digits==2 || Digits==3) {Pip=0.01;}

   for(int i=1; i<=OrdersTotal(); i++)
     {
      if(OrderSelect(i-1,SELECT_BY_POS)==true)
        {
         string Symb=Symbol();
         int Tip=OrderType();
         if(OrderSymbol()!=Symb)continue;

         if(OrderMagicNumber()!=Number_EA) continue;

         double SL=0;
         double TP=0;

         double SL_Primary=OrderStopLoss();

         while(true)
           {
            bool Modify=false;
            int Min_Dist=(int)MarketInfo(Symb,MODE_STOPLEVEL);//Min. distance
            if(Stop_Loss<Min_Dist) // If less than allowed
               SL=Min_Dist;
            switch(Tip)
              {
               //Buy
               case 0 :
                  if(NormalizeDouble(SL_Primary,Digits)<// If it is lower than we want
                     NormalizeDouble(Bid-Stop_Loss*Point,Digits))
                    {
                     SL=Bid -(Stop_Loss*Pip);//NormalizeDouble(Bid - (Stop_Loss * Pip),Digits);
                     if(Use_Take_Proft)
                       {TP=Bid+(Take_Profit*Pip); }
                     else
                       { TP=OrderTakeProfit();}
                     if(OrderStopLoss()!=SL)
                       { Modify=true;}
                     else
                       { Modify=false; }
                     break;
                    }
               break;

               //Sell                    
               case 1 :
                  if(NormalizeDouble(SL_Primary,Digits)>// If it is lower than we want
                     NormalizeDouble(Bid-Stop_Loss*Point,Digits))
                    {
                     SL=Ask+(Stop_Loss*Pip);
                     if(Use_Take_Proft)
                       {
                        TP=Ask-(Take_Profit*Pip);
                       }
                     else
                       {
                        TP=OrderTakeProfit();
                       }
                     if(OrderStopLoss()!=SL)
                       { Modify=true; }
                     else
                       { Modify=false; }
                     break;
                    }
               break;
              }
            if(Modify==false)
               break;
            //double TP    =OrderTakeProfit();    
            double Price =OrderOpenPrice();
            int    Ticket=OrderTicket();
            bool Ans=(bool)OrderModify(Ticket,Price,SL,TP,0);
            if(Ans==true)
              {
               break;
              }
            //
            int Error=GetLastError();
            switch(Error)
              {
               case 130:
                  RefreshRates();
                  continue;
               case 136:
                  while(RefreshRates()==false)
                  Sleep(100);
                  continue;
               case 146:
                  Sleep(5000);
                  RefreshRates();
                  continue;
               case 2 :
                  break;
               case 5 :
                  break;
               case 64:
                  break;
               case 133:
                  Sleep(6000);
                  OnStart();
                  break;
               default:
                  Sleep(6000);
                  OnStart();
              }
            break;
           }
        }
     }
   Sleep(_time_execution);
   OnStart();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountPercentStopPips(string symbol,double percent,double lots)
  {
   double balance   = AccountBalance();
   double tickvalue = MarketInfo(symbol, MODE_TICKVALUE);
   double lotsize   = MarketInfo(symbol, MODE_LOTSIZE);
   double spread    = MarketInfo(symbol, MODE_SPREAD);

   double stopLossPips=percent*balance/(lots*lotsize*tickvalue)-spread;

   return (stopLossPips);
  }
//+------------------------------------------------------------------+
