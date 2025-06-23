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
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingStep(double trailingStepStartPips, double _trailingStepPips, double initialStopLossInPips=0, bool useSymbol=false, bool useMagicNumber=false, int _magicNumber=0, bool initialStopLossWillBeDone=true) {
    for(int i=OrdersTotal()-1; i>=0; i--) {
        if(OrderSelect(i,SELECT_BY_POS)) {
            bool magic = (useMagicNumber) ? (OrderMagicNumber()==_magicNumber) : true;
            bool symbol = (useSymbol) ? (OrderSymbol()==Symbol()) : true;
            if(!magic || !symbol) continue;
            if(OrderType() == OP_BUY) {
                if(OrderStopLoss() >= NormalizeDouble(OrderOpenPrice() + initialStopLossInPips*_Point*10,_Digits) && OrderStopLoss() != 0) {//OrderStopLoss() != 0 is not necessary here cause in Buy NULL SL is Zero and 0 Will never be grater than Order Open Price + Jobhi hai
                    if(Bid - OrderStopLoss() > _trailingStepPips * Point() * 10) {
                        if(NormalizeDouble(OrderStopLoss(),_Digits) != NormalizeDouble(OrderStopLoss() + _trailingStepPips * Point() * 10,_Digits)) {
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderStopLoss() + _trailingStepPips * Point() * 10,_Digits), OrderTakeProfit(), 0)) {
                                Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                } else if(initialStopLossWillBeDone && OrderStopLoss() < NormalizeDouble(OrderOpenPrice() + initialStopLossInPips*_Point*10,_Digits)){
                    if(Bid - OrderOpenPrice() >= trailingStepStartPips * Point() * 10) {
                        if(OrderStopLoss() != NormalizeDouble(OrderOpenPrice() + initialStopLossInPips*_Point*10,_Digits)) {
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + initialStopLossInPips*_Point*10,_Digits), OrderTakeProfit(), 0)) {
                                Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                }
            }
            if(OrderType() == OP_SELL) {
                if(OrderStopLoss() <= NormalizeDouble(OrderOpenPrice() - initialStopLossInPips*_Point*10,_Digits) && OrderStopLoss() != 0) {//OrderStopLoss() != 0 is necessary here cause in Sell NULL SL is Zero and 0 Will Always be Lower than Order Open Price - Jobhi hai
                    if(OrderStopLoss() - Bid > _trailingStepPips * Point() * 10) {
                        if(NormalizeDouble(OrderStopLoss(),_Digits) != NormalizeDouble(OrderStopLoss() - _trailingStepPips * Point() * 10,_Digits)) {
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderStopLoss() - _trailingStepPips * Point() * 10,_Digits), OrderTakeProfit(), 0)) {
                                Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                } else if(initialStopLossWillBeDone && (OrderStopLoss() > NormalizeDouble(OrderOpenPrice() - initialStopLossInPips*_Point*10,_Digits) || OrderStopLoss()==0)) {
                    if(OrderOpenPrice() - Bid >= trailingStepStartPips * Point() * 10) {
                        if(OrderStopLoss() != NormalizeDouble(OrderOpenPrice() - Bid >= _trailingStepPips * Point() * 10,_Digits)) {
                            ResetLastError();
                            if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - initialStopLossInPips*_Point*10,_Digits), OrderTakeProfit(), 0)) {
                                Print("ERROR:"," Order Modify Failed: ",_LastError,"  ||  Function Name: ",__FUNCTION__,"  ||  Line Number: ",__LINE__);
                            }
                        }
                    }
                }
            }
        }
    }
}