//+------------------------------------------------------------------+
//|                                                 ly Pivot.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   double high=iHigh(Symbol(),PERIOD_MN1,1);
   double low=iLow(Symbol(),PERIOD_MN1,1);
   double close=iClose(Symbol(),PERIOD_MN1,1);
   double pp=(high+low+close)/3;
   double range=high-low;
   double s1=(2*pp)-high;
   double s2=pp-range;
   double s3=s2-range;
   double s4=s3-range;
   double r1=(2*pp)-low;
   double r2=pp+range;
   double r3=r2+range;
   double r4=r3+range;
   


   ObjectDelete("MN_Pivot");
   ObjectCreate("MN_Pivot", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), pp,TimeCurrent()+30*24*60*60,pp);
   ObjectSet("MN_Pivot", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_Pivot", OBJPROP_RAY, false);
   ObjectSet("MN_Pivot", OBJPROP_COLOR, Blue);
   ObjectSet("MN_Pivot", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_Pivottxt");
   ObjectCreate("MN_Pivottxt", OBJ_TEXT , 0,Time[0]+7*24*60*60,pp);
   ObjectSetText("MN_Pivottxt", "MN Pvt", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_s1");
   ObjectCreate("MN_s1", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), s1,TimeCurrent()+30*24*60*60,s1);
   ObjectSet("MN_s1", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_s1", OBJPROP_RAY, false);
   ObjectSet("MN_s1", OBJPROP_COLOR, Blue);
   ObjectSet("MN_s1", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_s1t");
   ObjectCreate("MN_s1t", OBJ_TEXT , 0,Time[0]+7*24*60*60,s1);
   ObjectSetText("MN_s1t", "S3", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_s2");
   ObjectCreate("MN_s2", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), s2,TimeCurrent()+30*24*60*60,s2);
   ObjectSet("MN_s2", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_s2", OBJPROP_RAY, false);
   ObjectSet("MN_s2", OBJPROP_COLOR, Blue);
   ObjectSet("MN_s2", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_s2t");
   ObjectCreate("MN_s2t", OBJ_TEXT , 0,Time[0]+7*24*60*60,s2);
   ObjectSetText("MN_s2t", "S2", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_s3");
   ObjectCreate("MN_s3", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), s3,TimeCurrent()+30*24*60*60,s3);
   ObjectSet("MN_s3", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_s3", OBJPROP_RAY, false);
   ObjectSet("MN_s3", OBJPROP_COLOR, Blue);
   ObjectSet("MN_s3", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_s3t");
   ObjectCreate("MN_s3t", OBJ_TEXT , 0,Time[0]+7*24*60*60,s3);
   ObjectSetText("MN_s3t", "S3", 8, "Tahoma", Blue);

   ObjectDelete("MN_s4");
   ObjectCreate("MN_s4", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), s4,TimeCurrent()+30*24*60*60,s4);
   ObjectSet("MN_s4", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_s4", OBJPROP_RAY, false);
   ObjectSet("MN_s4", OBJPROP_COLOR, Blue);
   ObjectSet("MN_s4", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_s4t");
   ObjectCreate("MN_s4t", OBJ_TEXT , 0,Time[0]+7*24*60*60,s4);
   ObjectSetText("MN_s4t", "S4", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_r1");
   ObjectCreate("MN_r1", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), r1,TimeCurrent()+30*24*60*60,r1);
   ObjectSet("MN_r1", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_r1", OBJPROP_RAY, false);
   ObjectSet("MN_r1", OBJPROP_COLOR, Blue);
   ObjectSet("MN_r1", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_r1t");
   ObjectCreate("MN_r1t", OBJ_TEXT , 0,Time[0]+7*24*60*60,r1);
   ObjectSetText("MN_r1t", "R1", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_r2");
   ObjectCreate("MN_r2", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), r2,TimeCurrent()+30*24*60*60,r2);
   ObjectSet("MN_r2", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_r2", OBJPROP_RAY, false);
   ObjectSet("MN_r2", OBJPROP_COLOR, Blue);
   ObjectSet("MN_r2", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_r2t");
   ObjectCreate("MN_r2t", OBJ_TEXT , 0,Time[0]+7*24*60*60,r2);
   ObjectSetText("MN_r2t", "R2", 8, "Tahoma", Blue);
   
   ObjectDelete("MN_r3");
   ObjectCreate("MN_r3", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), r3,TimeCurrent()+30*24*60*60,r3);
   ObjectSet("MN_r3", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_r3", OBJPROP_RAY, false);
   ObjectSet("MN_r3", OBJPROP_COLOR, Blue);
   ObjectSet("MN_r3", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_r3t");
   ObjectCreate("MN_r3t", OBJ_TEXT , 0,Time[0]+7*24*60*60,r3);
   ObjectSetText("MN_r3t", "R3", 8, "Tahoma", Blue);

   ObjectDelete("MN_r4");
   ObjectCreate("MN_r4", OBJ_TREND , 0,iTime(Symbol(),PERIOD_MN1,1), r4,TimeCurrent()+30*24*60*60,r4);
   ObjectSet("MN_r4", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MN_r4", OBJPROP_RAY, false);
   ObjectSet("MN_r4", OBJPROP_COLOR, Blue);
   ObjectSet("MN_r4", OBJPROP_WIDTH, 0);
   
   ObjectDelete("MN_r4t");
   ObjectCreate("MN_r4t", OBJ_TEXT , 0,Time[0]+7*24*60*60,r4);
   ObjectSetText("MN_r4t", "R4", 8, "Tahoma", Blue);
   
   
   
   ObjectDelete("MN_Start");
   ObjectCreate("MN_Start",OBJ_VLINE,0,iTime(Symbol(),PERIOD_MN1,1),0);
   ObjectSet("MN_Start", OBJPROP_STYLE, STYLE_DASH);
   ObjectSet("MN_Start", OBJPROP_COLOR, Blue);
   ObjectSet("MN_Start", OBJPROP_WIDTH, 0);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+