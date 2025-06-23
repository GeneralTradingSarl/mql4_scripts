//+------------------------------------------------------------------+
//|                                               Lot Calculator.mq4 |
//|                      Copyright © 2015, MetaQuotes Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"
#property show_confirm
#property show_inputs

extern string StartDate="2016.04.01";
extern double RebatePerLot=6;
extern color  TColor=clrRed;

int ticket;
int OpType;
double asbid,TP;
double JarLevel;

double totlots;
//+------------------------------------------------------------------+
//| script "send pending order with expiration data"                 |
//+------------------------------------------------------------------+
int start()
  {

   datetime iStart=StringToTime(StartDate);

   totlots=0;
   for(int cnt=0; cnt<OrdersHistoryTotal(); cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)==True)
        {
         if(OrderTicket()>0 && OrderCloseTime()>=iStart && (OrderType()==OP_BUY || OrderType()==OP_SELL))
           {
            totlots=totlots+OrderLots();
           }
        }
     }
   double myRebate=RebatePerLot*totlots;

// Comment("\n\n\n. . . TOTAL LOTS : ",totlots,
//          "\n. . . Rebte/Lots  : $ ",RebatePerLot,
//      "\n. . . my Rebate : $ ",myRebate);

   dpkfx();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void dpkfx()
  {
   int ipos=3;
   int xpos=30;

   double myRebate=RebatePerLot*totlots;

   int st=1;
   stats("d","Start Date : "+StartDate,9,"Arial",TColor,ipos,xpos-1,65);
   stats("a","TOTAL LOTS : "+DoubleToStr(totlots,2),9,"Arial",TColor,ipos,xpos-1,50);
   stats("b","Rebate / Lots  : $ "+DoubleToStr(RebatePerLot,2),9,"Arial",TColor,ipos,xpos,35);
   stats("c","my Rebate : $ "+DoubleToStr(myRebate,2),9,"Arial",TColor,ipos,xpos-1,20);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void stats(string tname,string word,int fsize,string ftype,color tcolor,int posxy,int posx,int posy)
  {
   ObjectCreate(tname,OBJ_LABEL,0,0,0);
   ObjectSetText(tname,word,fsize,ftype,tcolor);
   ObjectSet(tname,OBJPROP_CORNER,posxy);
   ObjectSet(tname,OBJPROP_XDISTANCE,posx);
   ObjectSet(tname,OBJPROP_YDISTANCE,posy);
  }
//+------------------------------------------------------------------+
