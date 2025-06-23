//+------------------------------------------------------------------+
//|                                          RemoveMoneyFromDemo.mq4 |
//|                                       Copyright 2019, Mr Stephen.|
//|             Using the spread to lower the equity in your account |
//|           Work around for brokers that do not support withdrawal |
//|           on Demo Accounts                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Mr Stephen."
#property link      ""
#property version   "1.01"
#property strict
#property script_show_inputs
//--- input parameters
input int AmountToRemove;


double Starting_Account_Balance = AccountBalance();
double Running_Account_Balance = AccountBalance();
double AmountToRemove_Balance = AmountToRemove;

static int OneLot = 100000;

double TotalLoss;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart()
  {
//---
      
      Alert("Balance:",Starting_Account_Balance," |Removing:",AmountToRemove);
      //int AccountLeverage();
      
      if(AmountToRemove <= 0) {
         Alert("Parameters are Incorrect");
         return -1;
      } else {
         double LotSize = FindLotSize();
         while(AmountToRemove_Balance > 0) {
            int ticket=OrderSend(Symbol(),OP_BUY,LotSize,0,3,0,0,"Remove Money From Demo");
            if(ticket<0){
               Alert("OrderSend failed with error #",GetLastError());
               break;
            }
            bool OrderResponse = OrderClose(ticket,LotSize,0,0,0);
            AmountToRemove_Balance=AmountToRemove_Balance-(Running_Account_Balance-AccountBalance());
            Running_Account_Balance = AccountBalance();
            Print("Amount Removed=>",(Starting_Account_Balance-AccountBalance())," |Amount to Remove:",AmountToRemove_Balance);
         }
         
        
         Alert("Total Removed:",(Starting_Account_Balance-AccountBalance()));
         return 0;
      }
      
      
  }
//+------------------------------------------------------------------+

double FindLotSize() {
   int Spread = (int)MarketInfo(_Symbol,MODE_SPREAD);
   double SpreadDecimal = Spread*DigitsToDecimal();
   double OrderAmount;
   double OurLotSize = (MaxLotSize()+1);
   double LotDebitAmount = 1;
   
   do {
      OurLotSize -= LotDebitAmount;
      
      if(OurLotSize == 1.0 && LotDebitAmount == 1.0) {
         LotDebitAmount=0.10;
      }else if(OurLotSize == 0.10 && LotDebitAmount == 0.10) {
         LotDebitAmount=0.01;
      } else {
         OurLotSize-=LotDebitAmount;
      }
      OrderAmount = (SpreadDecimal/Ask)*(OurLotSize*OneLot);
   
   }while(OrderAmount > AmountToRemove );
   
   
   
   return OurLotSize;
}

double DigitsToDecimal() {

   string Val = "0.";
   for(int x=2;x<=_Digits;x++){
      Val+="0";
   }
   
   Val+="1";
   //return Val;
   return StringToDouble(Val);
}

double MaxLotSize() {
   double LotSize = ((AccountBalance()*AccountLeverage())/OneLot);
   if(LotSize >=2) {
      LotSize = LotSize-.5;
   }
   
   return LotSize;
   
}