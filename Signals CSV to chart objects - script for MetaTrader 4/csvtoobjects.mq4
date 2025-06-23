#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict
#property show_inputs

input string FILENAME = "";

void OnStart() {
   Comment("");
   if (FILENAME == "") {
      Print("Please insert filename");
      Comment("Please insert filename");
      return;
   }
   ObjectsDeleteAll(0, "CSVToObjects_");
   
   int handle = FileOpen(FILENAME+".csv", FILE_READ|FILE_CSV);
   if (handle < 0) {
      Print("File not found");
      Comment("File not found");
      return;
   }
   int line = 0, col = 0;
   string cell[];
   while (!FileIsEnding(handle)) {
      if (col == 0) { ArrayFree(cell); }
      col += 1;
      
      array_push(cell, FileReadString(handle));
      
      if (FileIsLineEnding(handle)) {
         line += 1;
         col = 0;
         
         if (line == 1) { continue; }
         if (cell[3] != Symbol()) { continue; }
         
         datetime _OrderOpenTime   = StrToTime(cell[0]);
         datetime _OrderCloseTime  = StrToTime(cell[5]);
         double   _OrderOpenPrice  = StrToDouble(cell[4]);
         double   _OrderClosePrice = StrToDouble(cell[6]);
         double   _OrderProfit     = StrToDouble(cell[9]);
         int      _OrderType       = cell[1] == "Buy" ? OP_BUY : cell[1] == "Sell" ? OP_SELL : -1;
         
         if (_OrderType == -1) { continue; }
         
         string _name = "CSVToObjects_"+IntegerToString(line);
         if(ObjectCreate(0, _name, OBJ_TREND, 0, _OrderOpenTime, _OrderOpenPrice, _OrderCloseTime, _OrderClosePrice)) {
            ObjectSet(_name, OBJPROP_RAY, 0);
            ObjectSet(_name, OBJPROP_COLOR, _OrderType == OP_BUY ? clrBlue : clrRed);
            ObjectSet(_name, OBJPROP_SELECTABLE, false);
         }
         
         if(ObjectCreate(0, _name+"_E", OBJ_TREND, 0, _OrderOpenTime, _OrderOpenPrice, _OrderCloseTime, _OrderOpenPrice)) {
            ObjectSet(_name+"_E", OBJPROP_RAY, 0);
            ObjectSetString(0, _name+"_E", OBJPROP_TEXT, "   "+cell[9]);
            ObjectSet(_name+"_E", OBJPROP_COLOR, clrBlack);
            ObjectSet(_name+"_E", OBJPROP_SELECTABLE, false);
         }
         
         int _start = iBarShift(NULL, 0, _OrderOpenTime);
         if(ObjectCreate(0, _name+"_ASTART", OBJ_ARROW, 0, _OrderOpenTime, _OrderType == OP_BUY ? Low[_start] : High[_start])) {
            ObjectSet(_name+"_ASTART", OBJPROP_ARROWCODE, _OrderType == OP_BUY ? 233 : 234);
            ObjectSet(_name+"_ASTART", OBJPROP_ANCHOR, _OrderType == OP_BUY ? ANCHOR_TOP : ANCHOR_BOTTOM);
            ObjectSet(_name+"_ASTART", OBJPROP_COLOR, _OrderType == OP_BUY ? clrBlue : clrRed);
            ObjectSet(_name+"_ASTART", OBJPROP_SELECTABLE, false);
         }
      
         if(ObjectCreate(0, _name+"_ASTOP", OBJ_ARROW, 0, _OrderCloseTime, _OrderClosePrice)) {
            ObjectSet(_name+"_ASTOP", OBJPROP_ARROWCODE, _OrderProfit <= 0 ? 251 : 252);
            ObjectSet(_name+"_ASTOP", OBJPROP_ANCHOR, ANCHOR_CENTER);
            ObjectSet(_name+"_ASTOP", OBJPROP_COLOR, _OrderType == OP_SELL ? clrBlue : clrRed);
            ObjectSet(_name+"_ASTOP", OBJPROP_SELECTABLE, false);
         }
         
         /*if(ObjectCreate(0, _name+"_TP", OBJ_TREND, 0, _OrderOpenTime, _OrderTakeProfit, _OrderCloseTime, _OrderTakeProfit)) {
            ObjectSet(_name+"_TP", OBJPROP_RAY, 0);
            ObjectSet(_name+"_TP", OBJPROP_COLOR, clrBlue);
            ObjectSet(_name+"_TP", OBJPROP_SELECTABLE, false);
         }
         
         if(ObjectCreate(0, _name+"_SL", OBJ_TREND, 0, _OrderOpenTime, _OrderStopLoss, _OrderCloseTime, _OrderStopLoss)) {
            ObjectSet(_name+"_SL", OBJPROP_RAY, 0);
            ObjectSet(_name+"_SL", OBJPROP_COLOR, clrRed);
            ObjectSet(_name+"_SL", OBJPROP_SELECTABLE, false);
         }*/
      }
      //Print(FileReadString(handle));
      /*col += 1;
      if (FileIsLineEnding(handle)) {
         line += 1;
         
         Print(col);
         col = 0;
         Print(col);
         Print("end");
      }*/
      //if (line == 1) { continue; }
      
      /*col += 1;
      
      if (FileIsLineEnding(handle)) {
         Print(col);
         col = 0;
         Print(col);
         Print("end");
      }*/
   }
   
   Print(line);
   FileClose(handle);
}

template<typename T>
void array_push(T &array[], T txt) {
   int size = ArraySize(array);
   ArrayResize(array, ArraySize(array)+1);
   array[size] = txt;
}