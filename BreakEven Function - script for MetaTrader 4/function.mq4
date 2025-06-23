//+------------------------------------------------------------------+
//|                                                     Function.mq4 |
//|                                                      Sahil Bagdi |
//|                         https://www.mql5.com/en/users/sahilbagdi |
//+------------------------------------------------------------------+
#property copyright "Sahil Bagdi"
#property link      "https://www.mql5.com/en/users/sahilbagdi"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Breakeven                                                         |
//+------------------------------------------------------------------+
void BreakEven(double _breakEvenPips, bool useSymbol=false, bool useMagicNumber=false, int _magicNumber=0) {
    for(int i=OrdersTotal()-1; i>=0; i--) {
        if(OrderSelect(i,SELECT_BY_POS)) {
            bool magic = (useMagicNumber) ? (OrderMagicNumber()==_magicNumber) : true;
            bool symbol = (useSymbol) ? (OrderSymbol()==Symbol()) : true;
            if(!magic || !symbol) continue;
            if(OrderType() == OP_BUY) {
                if(NormalizeDouble(OrderStopLoss(),_Digits) < NormalizeDouble(OrderOpenPrice(),_Digits)) {
                    if(Bid - OrderOpenPrice() >= NormalizeDouble(_breakEvenPips * Point() * 10,_Digits)) {
                        if(NormalizeDouble(OrderStopLoss(),_Digits) != NormalizeDouble(OrderOpenPrice(),Digits)){
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice(),_Digits), OrderTakeProfit(), 0)) {
                               Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                }
            }
            
            if(OrderType() == OP_SELL) {
                if(NormalizeDouble(OrderStopLoss(),_Digits) > NormalizeDouble(OrderOpenPrice(),_Digits)) {
                    if(OrderOpenPrice() - Bid >= NormalizeDouble(_breakEvenPips * Point() * 10,_Digits)) {
                        if(NormalizeDouble(OrderStopLoss(),_Digits) != NormalizeDouble(OrderOpenPrice(),_Digits)) {
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice(),_Digits), OrderTakeProfit(), 0)) {
                                Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                }
            }
        }
    }
}