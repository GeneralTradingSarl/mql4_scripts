//+------------------------------------------------------------------+
//|                                                Malish6Levels.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Aleksandr Pak, Almaty"
#property link      "ekr-ap@mail.ru"
//#property show_inputs

extern int control_level=6; //not great value = 6
extern bool ray=False;
extern color col_up=Lime;
extern color col_down=Blue;
extern double percent_lev1=0.4;
extern double percent_lev2=0.6;
extern double percent_lev3=0.8;
extern double percent_lev4=1;
extern double percent_lev5=1.2;
extern double percent_lev6=1.4;

int contr_level;
double lev[10];
int init()
  {         
      contr_level=2*control_level+1;
      if(control_level>7) {control_level=7; contr_level=13;}
           for(int i=1;i<contr_level;i++) 
            {  
               ObjectCreate(StringConcatenate
               ("ML",DoubleToStr(i,0)),OBJ_TREND,0,Time[10],Close[1],Time[1],Close[1]);
            }     
      lev[1]=percent_lev1/100.;
      lev[2]=percent_lev2/100.;
      lev[3]=percent_lev3/100.;
      lev[4]=percent_lev4/100.;
      lev[5]=percent_lev5/100.;
      lev[6]=percent_lev6/100.;
      if(ObjectFind("StartML")<0) ObjectCreate("StartML",OBJ_VLINE,0,Time[10],0);     
   return(0);
  }

int start()
  { 
   double   ts=ObjectGet("StartML",OBJPROP_TIME1);
   double   t=ts-5*60*Period();
   double   t2=t+15*60*Period();
   int      b=iBarShift(NULL,0,ts ,FALSE);
   double   p= Close[b];   
   for (int i=1; i<control_level+1;i++)
   {        string n= StringConcatenate ("ML",DoubleToStr(i,0));               
            double pl=p+p*lev[i];
            ObjectSet(n,OBJPROP_RAY,ray);         
            ObjectSet(n,OBJPROP_COLOR,col_up);         
            ObjectSet(n,OBJPROP_TIME1,t);
            ObjectSet(n,OBJPROP_PRICE1,pl);
            ObjectSet(n,OBJPROP_TIME2,t2);
            ObjectSet(n,OBJPROP_PRICE2,pl);
            n= StringConcatenate ("ML",DoubleToStr(i+control_level,0));
            pl=p-p*lev[i];
             ObjectSet(n,OBJPROP_RAY,ray);    
            ObjectSet(n,OBJPROP_COLOR,col_down);
            ObjectSet(n,OBJPROP_TIME1,t);
            ObjectSet(n,OBJPROP_PRICE1,pl);
            ObjectSet(n,OBJPROP_TIME2,t2);
            ObjectSet(n,OBJPROP_PRICE2,pl);
    }  
    WindowRedraw();
   return(0);
  }

