//+------------------------------------------------------------------+
//|                                                  RiskAdvisor.mq4 |
//|       Copyright © 2006, Arunas Pranckevicius (T-1000), Lithuania |
//|                                            irc://irc.omnitel.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Arunas Pranckevicius (T-1000), Lithuania"
#property link      "irc://irc.omnitel.net/forex"
#property show_inputs
#include <stderror.mqh>
extern int BalanceRiskPercent = 5;
extern int OrdersStopLossPips = 100;
extern int ProfitLossFactor = 3;
extern int OrdersLots = 1;


//+------------------------------------------------------------------------------+
//| script "Advise Lots Size and Stop Loss for orders on given Risk Percent"     |
//+------------------------------------------------------------------------------+
int start()
  {
   double TakeProfit = OrdersStopLossPips * ProfitLossFactor;
   double MaxLots;
   int FreeMoney;
   int StopLoss = OrdersStopLossPips;
   double Lots = OrdersLots;
   double LotSize=MarketInfo(Symbol(),MODE_LOTSIZE) / AccountLeverage();
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double MaxLot=MarketInfo(Symbol(),MODE_MAXLOT);
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   double PipSize=MarketInfo(Symbol(),MODE_TICKVALUE);
   int TradeAllowed=MarketInfo(Symbol(),MODE_TRADEALLOWED);
   double Slippage=MarketInfo(Symbol(),MODE_SPREAD);
   double RequiredMargin=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double Margin,ReservedMargin=0;
   int MinTakeProfit=TakeProfit / 2;
   int MinStopLoss=OrdersStopLossPips / 2;
   int    cmd,total;

//----
   total=OrdersTotal();
//----
   for(int i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         cmd=OrderType();
         //---- open working orders only are considered
         if(cmd==OP_BUY || cmd==OP_SELL)
           {
            //---- print selected order
            OrderPrint();
            PipSize=MarketInfo(OrderSymbol(),MODE_TICKVALUE);
            if(cmd==OP_BUY) 
            {
            if ((OrderOpenPrice() - OrderStopLoss()) / Point * PipSize * OrderLots() + OrderSwap() - OrderCommission() > AccountBalance() * 0.18 && OrderStopLoss() > Point)
               ReservedMargin += ((OrderOpenPrice() - OrderStopLoss()) / Point * PipSize * OrderLots() - OrderSwap() - OrderCommission());
            else Print ("Skipping out of Money Management order.");   
            }
            if(cmd==OP_SELL) 
            {
            if ((OrderStopLoss() - OrderOpenPrice()) / Point * PipSize * OrderLots() + OrderSwap() - OrderCommission() > AccountBalance() * 0.18 && OrderStopLoss() > Point)
               ReservedMargin += ((OrderStopLoss() - OrderOpenPrice()) / Point * PipSize * OrderLots() - OrderSwap() - OrderCommission());
            else Print ("Skipping out of Money Management order.");   
            }
           }
        }
      else { Print( "Error when order select ", GetLastError()); break; }
     }
//Print("Reserved Margin:",ReservedMargin);
PipSize=MarketInfo(Symbol(),MODE_TICKVALUE);
if (ReservedMargin <= AccountFreeMargin()) FreeMoney=AccountBalance() - AccountMargin() - ReservedMargin;
else FreeMoney=AccountBalance() - AccountMargin();
MaxLots=FreeMoney / 100 * BalanceRiskPercent / LotSize * PipSize ; //Max Lots for 1 pip market change
if (GetLastError() == ERR_ZERO_DIVIDE) {Print("Err: division by zero: FreeMoney:",FreeMoney," BalanceRiskPercent:",BalanceRiskPercent," LotSize:",LotSize);return(-1);}

Lots = MaxLots / StopLoss * PipSize; 
if (GetLastError() == ERR_ZERO_DIVIDE) {Print("Err: division by zero: MaxLots:",MaxLots," StopLoss:",StopLoss," Lots:",Lots," PipSize:",PipSize);return(-1);}
//Print("DEBUG: MaxLots=",MaxLots," PipSize=",PipSize," Lots=",Lots);

// Normalize Lots
if (MinLots == 1) Lots=MathAbs(Lots);
if (MinLots == 0.1) Lots=MathAbs(Lots * 10) / 10;
if (MinLots == 0.01) Lots=MathAbs(Lots * 100) / 100;
if (Lots == 0)
{
Alert(Symbol(),": There is not enough money for new trade!");
return(1);
}
if (Lots < MinLots) 
   //We have not much money left?! try to arrange new deposit stop loss/take profit
   {  
    StopLoss=MathAbs(StopLoss / (MinLots/Lots));
    if (GetLastError() == ERR_ZERO_DIVIDE) {Print("Err: division by zero: StopLoss:",StopLoss," Minlots:",MinLots," Lots:",Lots);return(-1);}
    if (StopLoss < Slippage * 2) StopLoss = Slippage * 2;
    TakeProfit= StopLoss * ProfitLossFactor;
    Lots=MinLots;
   }  

   if (AccountFreeMargin() < Lots * StopLoss * PipSize + Lots * RequiredMargin)
   //We have starving FREE MARGIN!
   {
      Margin=AccountFreeMargin() / (Lots * StopLoss * PipSize + Lots * RequiredMargin);
     if (GetLastError() == ERR_ZERO_DIVIDE) {Print("Err: division by zero: StopLoss:",StopLoss," Margin:",Margin," Lots:",Lots);return(-1);}
      Lots = Lots * Margin; // Recalculate lots size to fit margin requirements
   }   
   if (Lots > MaxLots) Lots = MaxLot; //We reached maximum size of order

   if (Lots > 1) Lots = NormalizeDouble(Lots,1); 
   if (Lots > 0.1 && Lots < 1) Lots = NormalizeDouble(Lots,1);
   if (Lots < 0.1) Lots = NormalizeDouble(Lots,2);
 //----
   if (ReservedMargin > AccountFreeMargin()) Comment("\n\n\nRecommended Orders Risk Info:\nRisk:",BalanceRiskPercent,"%\n","Lots:",Lots,"\nTake Profit in Pips:",TakeProfit,"\nStop Loss in Pips:",StopLoss,"\nReserved Margin: n/a due incorrect S/L in orders");
   else Comment("\n\n\nRecommended Orders Risk Info:\nRisk:",BalanceRiskPercent,"%\n","Lots:",Lots,"\nTake Profit in Pips:",TakeProfit,"\nStop Loss in Pips:",StopLoss,"\nReserved Margin:",ReservedMargin+AccountMargin()," ",AccountCurrency());
   return(0);
  }
//+------------------------------------------------------------------+