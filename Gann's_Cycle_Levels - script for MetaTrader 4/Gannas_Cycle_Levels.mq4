//+------------------------------------------------------------------+
//|                                          Gann's_Cycle_Levels.mq4 |
//|                                      Copyright © 01/2008, Rosych |
//|                                                   rosych@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 01/2008, Rosych"
#property link      "rosych@mail.ru"
#property show_inputs

extern double Point_1=1.9499;//вносятся значимые High/Low
extern double Point_2=1.9880;//вносятся значимые High/Low
extern bool   Step_45=true;//отображать значения углов с шагом 45 градусов
extern bool   Step_30=true;//отображать значения углов с шагом 30 градусов
extern bool   Step_90=true;//отображать значения углов с шагом 90 градусов

double l_0, l_1, a, b, d,

       lup_45, lup_135, lup_225, lup_315,
       lup_90, lup_180, lup_270, lup_360,
       lup_30, lup_60, lup_120, lup_150, 
       lup_210, lup_240, lup_300, lup_330,

       ldn_45, ldn_135, ldn_225, ldn_315,
       ldn_90, ldn_180, ldn_270, ldn_360,
       ldn_30, ldn_60, ldn_120, ldn_150,
       ldn_210, ldn_240, ldn_300, ldn_330;

string Smb, L_0="0", L_1="360",

       Lup_45="45", Lup_135="135", Lup_225="225", Lup_315="315",
       Lup_90="90", Lup_180="180", Lup_270="270", Lup_360="360",
       Lup_30="30", Lup_60="60", Lup_120="120", Lup_150="150",
       Lup_210="210", Lup_240="240", Lup_300="300", Lup_330="330",

       Ldn_45="45", Ldn_135="135", Ldn_225="225", Ldn_315="315",
       Ldn_90="90", Ldn_180="180", Ldn_270="270", Ldn_360="360",
       Ldn_30="30", Ldn_60="60", Ldn_120="120", Ldn_150="150",
       Ldn_210="210", Ldn_240="240", Ldn_300="300", Ldn_330="330";

int start()
  {
   if(Point_1<=0 || Point_2<=0){return(0);}
   else{
   l_1=Point_1;
   d=Digits;
   b=Point_2;
   l_0=Point_2;
   a=NormalizeDouble(MathAbs(l_1-b)/4,d);
   
   lup_45=NormalizeDouble(b+a/2,d);
   lup_90=NormalizeDouble(b+a,d);
   lup_180=NormalizeDouble(b+a*2,d);
   lup_270=NormalizeDouble(b+a*3,d);
   lup_135=NormalizeDouble(lup_90+a/2,d);
   lup_225=NormalizeDouble(lup_180+a/2,d);
   lup_315=NormalizeDouble(lup_270+a/2,d);
   lup_30=NormalizeDouble(b+a/3,d);
   lup_60=NormalizeDouble(lup_30+a/3,d);
   lup_120=NormalizeDouble(lup_90+a/3,d);
   lup_150=NormalizeDouble(lup_120+a/3,d);
   lup_210=NormalizeDouble(lup_180+a/3,d);
   lup_240=NormalizeDouble(lup_210+a/3,d);
   lup_300=NormalizeDouble(lup_270+a/3,d);
   lup_330=NormalizeDouble(lup_300+a/3,d);
   
   ldn_45=NormalizeDouble(b-a/2,d);
   ldn_90=NormalizeDouble(b-a,d);
   ldn_180=NormalizeDouble(b-a*2,d);
   ldn_270=NormalizeDouble(b-a*3,d);
   ldn_135=NormalizeDouble(ldn_90-a/2,d);
   ldn_225=NormalizeDouble(ldn_180-a/2,d);
   ldn_315=NormalizeDouble(ldn_270-a/2,d);
   ldn_30=NormalizeDouble(b-a/3,d);
   ldn_60=NormalizeDouble(ldn_30-a/3,d);
   ldn_120=NormalizeDouble(ldn_90-a/3,d);
   ldn_150=NormalizeDouble(ldn_120-a/3,d);
   ldn_210=NormalizeDouble(ldn_180-a/3,d);
   ldn_240=NormalizeDouble(ldn_210-a/3,d);
   ldn_300=NormalizeDouble(ldn_270-a/3,d);
   ldn_330=NormalizeDouble(ldn_300-a/3,d);
   
   ObjectCreate(L_0,OBJ_HLINE,0,0,l_0);
   ObjectSet(L_0,OBJPROP_COLOR,Green);
   ObjectSet(L_0,OBJPROP_STYLE,DRAW_LINE);
   ObjectSet(L_0,OBJPROP_WIDTH,2);
   
   ObjectCreate(L_1,OBJ_HLINE,0,0,l_1);
   ObjectSet(L_1,OBJPROP_COLOR,Green);
   ObjectSet(L_1,OBJPROP_STYLE,DRAW_LINE);
   ObjectSet(L_1,OBJPROP_WIDTH,2);
   
   if(Point_1>Point_2){   
   if(Step_90==true){
     ObjectCreate(Lup_90,OBJ_HLINE,0,0,lup_90);
     ObjectSet(Lup_90,OBJPROP_COLOR,Blue);
     ObjectSet(Lup_90,OBJPROP_STYLE,2);
     ObjectSet(Lup_90,OBJPROP_WIDTH,0);
        
     ObjectCreate(Lup_180,OBJ_HLINE,0,0,lup_180);
     ObjectSet(Lup_180,OBJPROP_COLOR,Blue);
     ObjectSet(Lup_180,OBJPROP_STYLE,2);
     ObjectSet(Lup_180,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_270,OBJ_HLINE,0,0,lup_270);
     ObjectSet(Lup_270,OBJPROP_COLOR,Blue);
     ObjectSet(Lup_270,OBJPROP_STYLE,2);
     ObjectSet(Lup_270,OBJPROP_WIDTH,0);}
   
   if(Step_45==true){
     ObjectCreate(Lup_45,OBJ_HLINE,0,0,lup_45);
     ObjectSet(Lup_45,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Lup_45,OBJPROP_STYLE,2);
     ObjectSet(Lup_45,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_135,OBJ_HLINE,0,0,lup_135);
     ObjectSet(Lup_135,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Lup_135,OBJPROP_STYLE,2);
     ObjectSet(Lup_135,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_225,OBJ_HLINE,0,0,lup_225);
     ObjectSet(Lup_225,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Lup_225,OBJPROP_STYLE,2);
     ObjectSet(Lup_225,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_315,OBJ_HLINE,0,0,lup_315);
     ObjectSet(Lup_315,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Lup_315,OBJPROP_STYLE,2);
     ObjectSet(Lup_315,OBJPROP_WIDTH,0);
    }
   
    if(Step_30==true){
     ObjectCreate(Lup_30,OBJ_HLINE,0,0,lup_30);
     ObjectSet(Lup_30,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_30,OBJPROP_STYLE,2);
     ObjectSet(Lup_30,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_60,OBJ_HLINE,0,0,lup_60);
     ObjectSet(Lup_60,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_60,OBJPROP_STYLE,2);
     ObjectSet(Lup_60,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_120,OBJ_HLINE,0,0,lup_120);
     ObjectSet(Lup_120,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_120,OBJPROP_STYLE,2);
     ObjectSet(Lup_120,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_150,OBJ_HLINE,0,0,lup_150);
     ObjectSet(Lup_150,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_150,OBJPROP_STYLE,2);
     ObjectSet(Lup_150,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_210,OBJ_HLINE,0,0,lup_210);
     ObjectSet(Lup_210,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_210,OBJPROP_STYLE,2);
     ObjectSet(Lup_210,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_240,OBJ_HLINE,0,0,lup_240);
     ObjectSet(Lup_240,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_240,OBJPROP_STYLE,2);
     ObjectSet(Lup_240,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_300,OBJ_HLINE,0,0,lup_300);
     ObjectSet(Lup_300,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_300,OBJPROP_STYLE,2);
     ObjectSet(Lup_300,OBJPROP_WIDTH,0);
   
     ObjectCreate(Lup_330,OBJ_HLINE,0,0,lup_330);
     ObjectSet(Lup_330,OBJPROP_COLOR,DarkGray);
     ObjectSet(Lup_330,OBJPROP_STYLE,2);
     ObjectSet(Lup_330,OBJPROP_WIDTH,0);
    }
   }
   
   if(Point_1<Point_2){   
    if(Step_90==true){
     ObjectCreate(Ldn_90,OBJ_HLINE,0,0,ldn_90);
     ObjectSet(Ldn_90,OBJPROP_COLOR,Blue);
     ObjectSet(Ldn_90,OBJPROP_STYLE,2);
     ObjectSet(Ldn_90,OBJPROP_WIDTH,0);
        
     ObjectCreate(Ldn_180,OBJ_HLINE,0,0,ldn_180);
     ObjectSet(Ldn_180,OBJPROP_COLOR,Blue);
     ObjectSet(Ldn_180,OBJPROP_STYLE,2);
     ObjectSet(Ldn_180,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_270,OBJ_HLINE,0,0,ldn_270);
     ObjectSet(Ldn_270,OBJPROP_COLOR,Blue);
     ObjectSet(Ldn_270,OBJPROP_STYLE,2);
     ObjectSet(Ldn_270,OBJPROP_WIDTH,0);}
   
    if(Step_45==true){
     ObjectCreate(Ldn_45,OBJ_HLINE,0,0,ldn_45);
     ObjectSet(Ldn_45,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Ldn_45,OBJPROP_STYLE,2);
     ObjectSet(Ldn_45,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_135,OBJ_HLINE,0,0,ldn_135);
     ObjectSet(Ldn_135,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Ldn_135,OBJPROP_STYLE,2);
     ObjectSet(Ldn_135,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_225,OBJ_HLINE,0,0,ldn_225);
     ObjectSet(Ldn_225,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Ldn_225,OBJPROP_STYLE,2);
     ObjectSet(Ldn_225,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_315,OBJ_HLINE,0,0,ldn_315);
     ObjectSet(Ldn_315,OBJPROP_COLOR,LightSeaGreen);
     ObjectSet(Ldn_315,OBJPROP_STYLE,2);
     ObjectSet(Ldn_315,OBJPROP_WIDTH,0);
    }
   
    if(Step_30==true){
     ObjectCreate(Ldn_30,OBJ_HLINE,0,0,ldn_30);
     ObjectSet(Ldn_30,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_30,OBJPROP_STYLE,2);
     ObjectSet(Ldn_30,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_60,OBJ_HLINE,0,0,ldn_60);
     ObjectSet(Ldn_60,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_60,OBJPROP_STYLE,2);
     ObjectSet(Ldn_60,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_120,OBJ_HLINE,0,0,ldn_120);
     ObjectSet(Ldn_120,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_120,OBJPROP_STYLE,2);
     ObjectSet(Ldn_120,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_150,OBJ_HLINE,0,0,ldn_150);
     ObjectSet(Ldn_150,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_150,OBJPROP_STYLE,2);
     ObjectSet(Ldn_150,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_210,OBJ_HLINE,0,0,ldn_210);
     ObjectSet(Ldn_210,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_210,OBJPROP_STYLE,2);
     ObjectSet(Ldn_210,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_240,OBJ_HLINE,0,0,ldn_240);
     ObjectSet(Ldn_240,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_240,OBJPROP_STYLE,2);
     ObjectSet(Ldn_240,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_300,OBJ_HLINE,0,0,ldn_300);
     ObjectSet(Ldn_300,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_300,OBJPROP_STYLE,2);
     ObjectSet(Ldn_300,OBJPROP_WIDTH,0);
   
     ObjectCreate(Ldn_330,OBJ_HLINE,0,0,ldn_330);
     ObjectSet(Ldn_330,OBJPROP_COLOR,DarkGray);
     ObjectSet(Ldn_330,OBJPROP_STYLE,2);
     ObjectSet(Ldn_330,OBJPROP_WIDTH,0);
    }
   }
  }
 return(0);
}
//+------------------------------------------------------------------+