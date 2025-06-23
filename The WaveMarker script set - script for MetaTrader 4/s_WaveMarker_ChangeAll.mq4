//+------------------------------------------------------------------+
//|                                       s_WaveMarker_ChangeAll.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   color txtCol = Red;     // цвет надписей
   color lnCol = Blue;     // цвет линий  
//----
   int zx;
   switch(Period())
     {
       case 1:     zx = 5;   break;
       case 5:     zx = 10;  break;  
       case 15:    zx = 15;  break;
       case 30:    zx = 20;  break;
       case 60:    zx = 25;  break;
       case 240:   zx = 30;  break;  
       case 1440:  zx = 35;  break;
       case 10080: zx = 150; break;
       case 43200: zx = 250; break; 
       default: zx = 15;           
     }
   int k;
   int IndList[];
   double TxtX[][9];
   double TxtY[][9];      
   ArrayResize(IndList, 0);
   ArrayResize(TxtX, 0);  
   ArrayResize(TxtY, 0);     
   while(!IsStopped())
     {
       bool Fnd = false;
       for(int i = 0; i < ObjectsTotal(); i++)
         {
           if(StringFind(ObjectName(i), "WM(" + k + ")_", 0) == 0)
             {
               Fnd = true;
               ArrayResize(IndList, ArraySize(IndList) + 1);
               IndList[ArraySize(IndList) - 1] = k;       
               ArrayResize(TxtX, ArraySize(TxtX) / 9 + 1);
               TxtX[ArraySize(TxtX)/9-1][0] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_0", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][0] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_1", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][1] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_2", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][2] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_3", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][3] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_4", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][4] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_5", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][5] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_A", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][6] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_B", OBJPROP_TIME1);
               TxtX[ArraySize(TxtX)/9-1][7] = ObjectGet("WM(" + k + ")_" + 
                                                    "T_C", OBJPROP_TIME1);
               ArrayResize(TxtY,ArraySize(TxtY) /9 + 1);
               TxtY[ArraySize(TxtY)/9-1][0] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_0", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][0] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_1", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][1] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_2", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][2] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_3", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][3] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_4", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][4] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_5", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][5] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_A", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][6] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_B", OBJPROP_PRICE1);
               TxtY[ArraySize(TxtY)/9-1][7] = ObjectGet("WM(" + k + ")_" + 
                                                   "T_C", OBJPROP_PRICE1);
               break;
             }
         }
       if(!Fnd)
         {
           ArrayResize(IndList, ArraySize(IndList) + 1);
           IndList[ArraySize(IndList) - 1] = k;
           break;
         }
       k++;
     }
   int fb = FirstVisibleBar() - 5;
   while(!IsStopped())
     {
       for(int j = 0; j < ArraySize(IndList); j++)
         {
           k = IndList[j];
           if(j < ArraySize(IndList))
             {
               if(ObjectFind("WM(" + k + ")_" + "T_0") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_0", OBJ_TEXT, 
                                0, TxtX[j][0], TxtY[j][0]);
                   ObjectSetText("WM(" + k + ")_" + "T_0", "0", 8,
                                 "Arial", txtCol);
                 }         
               if(ObjectFind("WM(" + k + ")_" + "T_1") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_1", OBJ_TEXT, 
                                0, TxtX[j][1], TxtY[j][1]);
                   ObjectSetText("WM(" + k + ")_" + "T_1", "1", 8, 
                                 "Arial", txtCol);
                 }
               if(ObjectFind("WM(" + k + ")_" + "T_2") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_2", OBJ_TEXT, 
                                0, TxtX[j][2], TxtY[j][2]);
                   ObjectSetText("WM(" + k + ")_" + "T_2", "2", 8, 
                                 "Arial", txtCol);
                 }            
               if(ObjectFind("WM(" + k + ")_" + "T_3") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_3", OBJ_TEXT, 
                                0, TxtX[j][3], TxtY[j][3]);
                   ObjectSetText("WM(" + k + ")_" + "T_3", "3", 8, 
                                 "Arial", txtCol);
                 }            
               if(ObjectFind("WM(" + k + ")_" + "T_4") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_4", OBJ_TEXT, 
                                0, TxtX[j][4], TxtY[j][4]);
                   ObjectSetText("WM(" + k + ")_" + "T_4", "4", 8, 
                                 "Arial", txtCol);
                 }            
               if(ObjectFind("WM(" + k + ")_" + "T_5") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_5", OBJ_TEXT, 
                                0, TxtX[j][5], TxtY[j][5]);
                   ObjectSetText("WM(" + k + ")_" + "T_5", "5", 8, 
                                 "Arial", txtCol);
                 }  
               if(ObjectFind("WM(" + k + ")_" + "T_A") != 0)
                 {
                  ObjectCreate("WM(" + k + ")_" + "T_A", OBJ_TEXT, 
                               0, TxtX[j][6], TxtY[j][6]);
                  ObjectSetText("WM(" + k + ")_" + "T_A", "A", 8, 
                                "Arial", txtCol);
                 }            
               if(ObjectFind("WM(" + k + ")_" + "T_B") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_B", OBJ_TEXT, 
                                0, TxtX[j][7], TxtY[j][7]);
                   ObjectSetText("WM(" + k + ")_" + "T_B", "B", 8, 
                                 "Arial", txtCol);
                 }            
               if(ObjectFind("WM(" + k + ")_" + "T_C") != 0)
                 {
                   ObjectCreate("WM(" + k + ")_" + "T_C", OBJ_TEXT, 
                                0, TxtX[j][8], TxtY[j][8]);
                   ObjectSetText("WM(" + k + ")_" + "T_C", "C", 8, 
                                 "Arial", txtCol);             
                 }            
               TxtX[j][0] = ObjectGet("WM(" + k + ")_" + "T_0", OBJPROP_TIME1);
               TxtX[j][1] = ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_TIME1);
               TxtX[j][2] = ObjectGet("WM(" + k + ")_" + "T_2", OBJPROP_TIME1);
               TxtX[j][3] = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_TIME1);
               TxtX[j][4] = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_TIME1);
               TxtX[j][5] = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_TIME1);
               TxtX[j][6] = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_TIME1);
               TxtX[j][7] = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_TIME1);
               TxtX[j][8] = ObjectGet("WM(" + k + ")_" + "T_C", OBJPROP_TIME1);
               TxtY[j][0] = ObjectGet("WM(" + k + ")_" + "T_0", OBJPROP_PRICE1);
               TxtY[j][1] = ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_PRICE1);
               TxtY[j][2] = ObjectGet("WM(" + k + ")_" + "T_2", OBJPROP_PRICE1);
               TxtY[j][3] = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_PRICE1);
               TxtY[j][4] = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_PRICE1);
               TxtY[j][5] = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_PRICE1);
               TxtY[j][6] = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_PRICE1);
               TxtY[j][7] = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_PRICE1);
               TxtY[j][8] = ObjectGet("WM(" + k + ")_" + "T_C", OBJPROP_PRICE1);
             }
           int l_1_x1 = ObjectGet("WM(" + k + ")_" + "T_0", OBJPROP_TIME1);
           int l_1_x2 = ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_TIME1); 
           double l_1_y1=ObjectGet("WM(" + k + ")_" + "T_0", OBJPROP_PRICE1) + 
                                   Point*zx;
           double l_1_y2=ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_PRICE1) + 
                                   Point*zx;      
           if(l_1_y1 < l_1_y2)
             {
               if(l_1_x1 <= Time[0])
                   l_1_y1 = Low[iBarShift(NULL, 0, l_1_x1, false)];
               if(l_1_x2 <= Time[0])
                   l_1_y2 = High[iBarShift(NULL, 0, l_1_x2, false)];
             }
           if(l_1_y1 > l_1_y2)
             {
               if(l_1_x1 <= Time[0])
                   l_1_y1 = High[iBarShift(NULL, 0, l_1_x1, false)];
               if(l_1_x2 <= Time[0])
                   l_1_y2 = Low[iBarShift(NULL, 0, l_1_x2, false)];
             }
           int l_2_x1 = ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_TIME1);
           int l_2_x2 = ObjectGet("WM(" + k + ")_" + "T_2", OBJPROP_TIME1);
           double l_2_y1 = ObjectGet("WM(" + k + ")_" + "T_1", OBJPROP_PRICE1) +
                                     Point*zx;
           double l_2_y2 = ObjectGet("WM(" + k + ")_" + "T_2", OBJPROP_PRICE1) +
                                     Point*zx;
           if(l_2_y1 < l_2_y2)
             {
               if(l_2_x1 <= Time[0])
                   l_2_y1 = Low[iBarShift(NULL, 0, l_2_x1, false)];
               if(l_2_x2 <= Time[0])
                   l_2_y2 = High[iBarShift(NULL, 0, l_2_x2, false)];
             }
           if(l_2_y1 > l_2_y2)
             {
               if(l_2_x1 <= Time[0])
                   l_2_y1 = High[iBarShift(NULL, 0, l_2_x1, false)];
               if(l_2_x2 <= Time[0])
                   l_2_y2 = Low[iBarShift(NULL, 0, l_2_x2, false)];
             }
           int l_3_x1 = ObjectGet("WM(" + k + ")_" + "T_2", OBJPROP_TIME1);
           int l_3_x2 = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_TIME1);
           double l_3_y1 = ObjectGet("WM(" + k+ ")_" + "T_2", OBJPROP_PRICE1) +
                                     Point*zx;
           double l_3_y2 = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_PRICE1) +
                                     Point*zx;
           if(l_3_y1 < l_3_y2)
             {
               if(l_3_x1 <= Time[0])
                   l_3_y1 = Low[iBarShift(NULL, 0, l_3_x1, false)];
               if(l_3_x2 <= Time[0])
                   l_3_y2 = High[iBarShift(NULL, 0, l_3_x2, false)];      
             }
           if(l_3_y1>l_3_y2)
             {
               if(l_3_x1 <= Time[0])
                   l_3_y1 = High[iBarShift(NULL, 0, l_3_x1, false)];         
               if(l_3_x2 <= Time[0])
                   l_3_y2 = Low[iBarShift(NULL, 0, l_3_x2, false)];   
             }
           int l_4_x1 = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_TIME1);
           int l_4_x2 = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_TIME1);
           double l_4_y1 = ObjectGet("WM(" + k + ")_" + "T_3", OBJPROP_PRICE1) +
                                     Point*zx;
           double l_4_y2 = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_PRICE1) +
                                     Point*zx;
           if(l_4_y1 < l_4_y2)
             {
               if(l_4_x1 <= Time[0])
                   l_4_y1 = Low[iBarShift(NULL, 0, l_4_x1, false)];
               if(l_4_x2 <= Time[0])
                   l_4_y2 = High[iBarShift(NULL, 0, l_4_x2, false)];
             }
           if(l_4_y1 > l_4_y2)
             {
               if(l_4_x1 <= Time[0])l_4_y1 = High[iBarShift(NULL, 0, l_4_x1, false)];
               if(l_4_x2 <= Time[0])l_4_y2 = Low[iBarShift(NULL, 0, l_4_x2, false)];
             }
           int l_5_x1 = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_TIME1);
           int l_5_x2 = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_TIME1);        
           double l_5_y1 = ObjectGet("WM(" + k + ")_" + "T_4", OBJPROP_PRICE1) + 
                                     Point*zx;
           double l_5_y2 = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_PRICE1) + 
                                     Point*zx;
           if(l_5_y1 < l_5_y2)
             {
               if(l_5_x1 <= Time[0])
                   l_5_y1 = Low[iBarShift(NULL, 0, l_5_x1, false)];
               if(l_5_x2 <= Time[0])
                   l_5_y2 = High[iBarShift(NULL, 0, l_5_x2, false)];      
             }
           if(l_5_y1 > l_5_y2)
             {
               if(l_5_x1 <= Time[0])
                   l_5_y1 = High[iBarShift(NULL, 0, l_5_x1, false)];         
               if(l_5_x2 <= Time[0])
                   l_5_y2 = Low[iBarShift(NULL, 0, l_5_x2, false)];   
             }
           int l_6_x1 = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_TIME1);
           int l_6_x2 = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_TIME1);      
           double l_6_y1 = ObjectGet("WM(" + k + ")_" + "T_5", OBJPROP_PRICE1) + 
                                     Point*zx;
           double l_6_y2 = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_PRICE1) + 
                                     Point*zx;
           if(l_6_y1 < l_6_y2)
             {
               if(l_6_x1 <= Time[0])
                   l_6_y1 = Low[iBarShift(NULL, 0, l_6_x1, false)];
               if(l_6_x2 <= Time[0])
                   l_6_y2 = High[iBarShift(NULL, 0, l_6_x2, false)];      
             }
           if(l_6_y1 > l_6_y2)
             {
               if(l_6_x1 <= Time[0])
                   l_6_y1 = High[iBarShift(NULL, 0, l_6_x1, false)];         
               if(l_6_x2 <= Time[0])
                   l_6_y2 = Low[iBarShift(NULL, 0, l_6_x2, false)];   
             }
           int l_7_x1 = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_TIME1);
           int l_7_x2 = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_TIME1);       
           double l_7_y1 = ObjectGet("WM(" + k + ")_" + "T_A", OBJPROP_PRICE1) + 
                                     Point*zx;
           double l_7_y2 = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_PRICE1) + 
                                     Point*zx;
           if(l_7_y1 < l_7_y2)
             {
               if(l_7_x1 <= Time[0])
                   l_7_y1 = Low[iBarShift(NULL, 0, l_7_x1, false)];
               if(l_7_x2 <= Time[0])
                   l_7_y2 = High[iBarShift(NULL, 0, l_7_x2, false)];      
             }
           if(l_7_y1 > l_7_y2)
             {
               if(l_7_x1 <= Time[0])
                   l_7_y1 = High[iBarShift(NULL, 0, l_7_x1, false)];         
               if(l_7_x2 <= Time[0])
                   l_7_y2 = Low[iBarShift(NULL, 0, l_7_x2, false)]; 
             }
           int l_8_x1 = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_TIME1);
           int l_8_x2 = ObjectGet("WM(" + k + ")_" + "T_C", OBJPROP_TIME1);       
           double l_8_y1 = ObjectGet("WM(" + k + ")_" + "T_B", OBJPROP_PRICE1) + 
                                     Point*zx;
           double l_8_y2 = ObjectGet("WM(" + k + ")_" + "T_C", OBJPROP_PRICE1) + 
                                     Point*zx;
           if(l_8_y1 < l_8_y2)
             {
               if(l_8_x1 <= Time[0])
                   l_8_y1=Low[iBarShift(NULL, 0, l_8_x1, false)];
               if(l_8_x2 <= Time[0])
                   l_8_y2=High[iBarShift(NULL, 0, l_8_x2, false)];
             }
           if(l_8_y1 > l_8_y2)
             {
               if(l_8_x1 <= Time[0])
                   l_8_y1 = High[iBarShift(NULL, 0, l_8_x1, false)];         
               if(l_8_x2 <= Time[0])
                   l_8_y2 = Low[iBarShift(NULL, 0, l_8_x2, false)];       
             }
           if(ObjectFind("WM(" + k + ")_" + "L_1") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_1", OBJ_TREND, 0, 
                            l_1_x1, l_1_y1, l_1_x2, l_1_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_TIME1, l_1_x1);
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_PRICE1, l_1_y1);
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_TIME2, l_1_x2); 
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_PRICE2, l_1_y2);        
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_1", OBJPROP_RAY, false);
           if(ObjectFind("WM(" + k + ")_" + "L_2") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_2", OBJ_TREND, 0, 
                            l_2_x1, l_2_y1, l_2_x2, l_2_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_TIME1, l_2_x1);
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_TIME2, l_2_x2);      
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_PRICE1, l_2_y1);
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_PRICE2, l_2_y2);        
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_2", OBJPROP_RAY, false);            
           if(ObjectFind("WM(" + k + ")_" + "L_3") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_3", OBJ_TREND, 0, 
                            l_3_x1, l_3_y1, l_3_x2, l_3_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_TIME1, l_3_x1);
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_TIME2, l_3_x2);      
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_PRICE1, l_3_y1);
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_PRICE2, l_3_y2);        
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_3", OBJPROP_RAY, false);        
           if(ObjectFind("WM(" + k + ")_" + "L_4") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_4", OBJ_TREND, 0, 
                            l_4_x1, l_4_y1, l_4_x2, l_4_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_TIME1, l_4_x1);
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_TIME2, l_4_x2);      
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_PRICE1, l_4_y1);
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_PRICE2, l_4_y2);        
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_4", OBJPROP_RAY, false);   
           if(ObjectFind("WM(" + k + ")_" + "L_5") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_5", OBJ_TREND, 0, 
                            l_5_x1, l_5_y1, l_5_x2, l_5_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_TIME1, l_5_x1);
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_TIME2, l_5_x2);      
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_PRICE1, l_5_y1);
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_PRICE2, l_5_y2);        
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_5", OBJPROP_RAY, false); 
           if(ObjectFind("WM(" + k + ")_" + "L_6") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_6", OBJ_TREND, 0, 
                            l_6_x1, l_6_y1, l_6_x2, l_6_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_TIME1, l_6_x1);
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_TIME2, l_6_x2);      
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_PRICE1, l_6_y1);
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_PRICE2, l_6_y2);        
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_6", OBJPROP_RAY, false); 
           if(ObjectFind("WM(" + k + ")_" + "L_7") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_7", OBJ_TREND, 0, 
                            l_7_x1, l_7_y1, l_7_x2, l_7_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_TIME1, l_7_x1);
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_TIME2, l_7_x2);      
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_PRICE1, l_7_y1);
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_PRICE2, l_7_y2);        
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_7", OBJPROP_RAY, false);       
           if(ObjectFind("WM(" + k + ")_" + "L_8") != 0)
             {
               ObjectCreate("WM(" + k + ")_" + "L_8", OBJ_TREND, 0, 
                            l_8_x1, l_8_y1, l_8_x2, l_8_y2);
             }
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_TIME1, l_8_x1);
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_TIME2, l_8_x2);      
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_PRICE1, l_8_y1);
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_PRICE2, l_8_y2);        
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_COLOR, lnCol);
           ObjectSet("WM(" + k + ")_" + "L_8", OBJPROP_RAY, false);         
         }
       WindowRedraw();
       Sleep(1);
     }             
//----
   return(0);
  }
//+------------------------------------------------------------------+


