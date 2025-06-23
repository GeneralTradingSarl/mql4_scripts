//+------------------------------------------------------------------+
//|                                Brooky_FibIt_Extension_Script.mq4 |
//|                        Copyright 2012, www.Brooky_Indicators.com |
//|                                        www.Brooky_Indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, www.Brooky_Indicators.com"
#property link      "www.Brooky_Indicators.com"
#property show_confirm  
#property show_inputs
//+---------------------
//| script program start function                                    |
//+------------------------------------------------------------------+

extern int       FibOnChartNum =1;

extern color     Fib_Cbar_Color = Red;
extern int       Fib_Cbar_Size=1;
extern int       Fib_Cbar_Style=2;

extern color     Fib_Level_Color = Gray;
extern int       Fib_Level_Size=1;
extern int       Fib_Level_Style=2;

extern double     Fib_Level_1 = -0.117;
extern double     Fib_Level_2 = 0;
extern double     Fib_Level_3 = 1;
extern double     Fib_Level_4 = 1.618;
extern double     Fib_Level_5 = 2;
extern double     Fib_Level_6 = 2.382;
extern double     Fib_Level_7 = 3;

string Xtra_txtFib_Level_1  = "(SL) ";
string Xtra_txtFib_Level_2  = "";
string Xtra_txtFib_Level_3  = "";
string Xtra_txtFib_Level_4  = "(TP1)";
string Xtra_txtFib_Level_5  = "(TP2)";
string Xtra_txtFib_Level_6  = "Re Entry Break ";
string Xtra_txtFib_Level_7  = "";


string txtFib_Level_1  = "";
string txtFib_Level_2  = "";
string txtFib_Level_3  = "";
string txtFib_Level_4  = "";
string txtFib_Level_5  = "";
string txtFib_Level_6  = "";
string txtFib_Level_7  = "";


string FibPrice = " @ %$";
string FibName = "";


int start()
  {
//----
      txtFib_Level_1 = StringConcatenate(Xtra_txtFib_Level_1,DoubleToStr(Fib_Level_1,3),FibPrice);
      txtFib_Level_2 = StringConcatenate(Xtra_txtFib_Level_2,DoubleToStr(Fib_Level_2,3),FibPrice);
      txtFib_Level_3 = StringConcatenate(Xtra_txtFib_Level_3,DoubleToStr(Fib_Level_3,3),FibPrice);
      txtFib_Level_4 = StringConcatenate(Xtra_txtFib_Level_4,DoubleToStr(Fib_Level_4,3),FibPrice);
      txtFib_Level_5 = StringConcatenate(Xtra_txtFib_Level_5,DoubleToStr(Fib_Level_5,3),FibPrice);
      txtFib_Level_6 = StringConcatenate(Xtra_txtFib_Level_6,DoubleToStr(Fib_Level_6,3),FibPrice);
      txtFib_Level_7 = StringConcatenate(Xtra_txtFib_Level_7,DoubleToStr(Fib_Level_7,3),FibPrice);
      
      
      
      FibName = "Brooky_Fib_"+FibOnChartNum;
      ObjectDelete(FibName);
      
      ObjectCreate(FibName,OBJ_FIBO,0,Time[9],High[24],Time[1],Low[1]);
      
      ObjectSet(FibName, OBJPROP_COLOR,Fib_Cbar_Color);
      ObjectSet(FibName, OBJPROP_WIDTH ,Fib_Cbar_Size);
      ObjectSet(FibName, OBJPROP_STYLE ,Fib_Cbar_Style);
      
      ObjectSet(FibName, OBJPROP_RAY,True);
       
      ObjectSet(FibName, OBJPROP_LEVELSTYLE,Fib_Level_Style);
      ObjectSet(FibName, OBJPROP_LEVELCOLOR,Fib_Level_Color);      
      ObjectSet(FibName, OBJPROP_LEVELWIDTH,Fib_Level_Size);  
       
          
      ObjectSet(FibName, OBJPROP_FIBOLEVELS,7);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+0,Fib_Level_1);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+1,Fib_Level_2);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+2,Fib_Level_3);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+3,Fib_Level_4);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+4,Fib_Level_5);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+5,Fib_Level_6);
      ObjectSet(FibName, OBJPROP_FIRSTLEVEL+6,Fib_Level_7);
      

     
      ObjectSetFiboDescription(FibName,0,txtFib_Level_1);
      ObjectSetFiboDescription(FibName,1,txtFib_Level_2);
      ObjectSetFiboDescription(FibName,2,txtFib_Level_3);
      ObjectSetFiboDescription(FibName,3,txtFib_Level_4);
      ObjectSetFiboDescription(FibName,4,txtFib_Level_5);
      ObjectSetFiboDescription(FibName,5,txtFib_Level_6);      
      ObjectSetFiboDescription(FibName,6,txtFib_Level_7);
//----
   return(0);
  }
//+------------------------------------------------------------------+