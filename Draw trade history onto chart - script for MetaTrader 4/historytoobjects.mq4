#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict
#property show_inputs

input int MAGIC_NUMBER = 0;

void OnStart() {
   ObjectsDeleteAll(0, "HistoryToObjects_");
   
   double totalProfit = 0;
   int total_order = OrdersHistoryTotal();
   for(int x=total_order; x>=0; x--) {
      if (OrderSelect(x, SELECT_BY_POS, MODE_HISTORY) == false) { continue; }
      if (MAGIC_NUMBER != 0 && OrderMagicNumber() != MAGIC_NUMBER) { continue; }
      if (OrderSymbol() != Symbol()) { continue; }
      
      string orderType = OrderType() == OP_BUY ? "Buy" : OrderType() == OP_SELL ? "Sell" : "";
      int lapse = (int) MathFloor((OrderCloseTime()-OrderOpenTime())/60)/4;
      
      totalProfit += OrderProfit();
      
      if (OrderType() != OP_BUY && OrderType() != OP_SELL) { continue; }
      
      string _name = "HistoryToObjects_"+IntegerToString(OrderTicket());
      if(ObjectCreate(0, _name, OBJ_TREND, 0, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice())) {
         ObjectSet(_name, OBJPROP_RAY, 0);
         ObjectSet(_name, OBJPROP_COLOR, OrderType() == OP_BUY ? clrBlue : clrRed);
         ObjectSet(_name, OBJPROP_SELECTABLE, false);
      }
      
      if(ObjectCreate(0, _name+"_E", OBJ_TREND, 0, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderOpenPrice())) {
         ObjectSet(_name+"_E", OBJPROP_RAY, 0);
         ObjectSet(_name+"_E", OBJPROP_COLOR, clrBlack);
         ObjectSet(_name+"_E", OBJPROP_SELECTABLE, false);
      }
      
      if(ObjectCreate(0, _name+"_TP", OBJ_TREND, 0, OrderOpenTime(), OrderTakeProfit(), OrderCloseTime(), OrderTakeProfit())) {
         ObjectSet(_name+"_TP", OBJPROP_RAY, 0);
         ObjectSet(_name+"_TP", OBJPROP_COLOR, clrBlue);
         ObjectSet(_name+"_TP", OBJPROP_SELECTABLE, false);
      }
      
      if(ObjectCreate(0, _name+"_SL", OBJ_TREND, 0, OrderOpenTime(), OrderStopLoss(), OrderCloseTime(), OrderStopLoss())) {
         ObjectSet(_name+"_SL", OBJPROP_RAY, 0);
         ObjectSet(_name+"_SL", OBJPROP_COLOR, clrRed);
         ObjectSet(_name+"_SL", OBJPROP_SELECTABLE, false);
      }
      
      int _start = iBarShift(NULL, 0, OrderOpenTime());
      if(ObjectCreate(0, _name+"_ASTART", OBJ_ARROW, 0, Time[_start], OrderType() == OP_BUY ? Low[_start] : High[_start])) {
         ObjectSet(_name+"_ASTART", OBJPROP_ARROWCODE, OrderType() == OP_BUY ? 233 : 234);
         ObjectSet(_name+"_ASTART", OBJPROP_ANCHOR, OrderType() == OP_BUY ? ANCHOR_TOP : ANCHOR_BOTTOM);
         ObjectSet(_name+"_ASTART", OBJPROP_COLOR, OrderType() == OP_BUY ? clrBlue : clrRed);
         ObjectSet(_name+"_ASTART", OBJPROP_SELECTABLE, false);
      }
      
      if(ObjectCreate(0, _name+"_ASTOP", OBJ_ARROW, 0, OrderCloseTime(), OrderClosePrice())) {
         ObjectSet(_name+"_ASTOP", OBJPROP_ARROWCODE, OrderProfit() <= 0 ? 251 : 252);
         ObjectSet(_name+"_ASTOP", OBJPROP_ANCHOR, ANCHOR_CENTER);
         ObjectSet(_name+"_ASTOP", OBJPROP_COLOR, OrderType() == OP_SELL ? clrBlue : clrRed);
         ObjectSet(_name+"_ASTOP", OBJPROP_SELECTABLE, false);
      }
      
      if(ObjectCreate(0, _name+"_TPZONE", OBJ_RECTANGLE, 0, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderTakeProfit())) {
         ObjectSet(_name+"_TPZONE", OBJPROP_COLOR, clrPowderBlue);
         ObjectSet(_name+"_TPZONE", OBJPROP_SELECTABLE, false);
         ObjectSet(_name+"_TPZONE", OBJPROP_BACK, true);
      }
      
      if(ObjectCreate(0, _name+"_SLZONE", OBJ_RECTANGLE, 0, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderStopLoss())) {
         ObjectSet(_name+"_SLZONE", OBJPROP_COLOR, clrPink);
         ObjectSet(_name+"_SLZONE", OBJPROP_SELECTABLE, false);
         ObjectSet(_name+"_SLZONE", OBJPROP_BACK, true);
      }
   }
}