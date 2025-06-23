//+------------------------------------------------------------------+
//|                                                   kopiuj_obj.mq4 |
//|                                                               tk |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "tk"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
  for(int i=0;i<ObjectsTotal(ChartID(),-1);i++)
     if(StringFind(ObjectName(i),"SSSR",0)==-1)
     {int p = i+1;
         {ObjectSetString(ChartID(),ObjectName(i),OBJPROP_NAME,"ax_"+IntegerToString(p));Print("BBBBB: ",(string)GetLastError()+" "+ObjectName(i));}
     }
  
  long idceld ;//= ChartNext(ChartID());
  long pier = ChartFirst();
  for(int i=0;i<20;i++)
    {
     idceld = pier;
         if(ChartID()!=pier&&ChartSymbol(ChartID())==ChartSymbol(pier))
          {
          usun_obiekty(idceld);
          //Print("Pozosta³o: ",ObjectsTotal(idcel));
          kopiuj(idceld);
          }
     pier = ChartNext(pier);if(pier==-1)break;
   }
  }


//+------------------------------------------------------------------+
void kopiuj(long idcel)
  {
   Print("Obiektów: "+(string)ObjectsTotal());
   for(int i=0;i<ObjectsTotal();i++)
     if(StringFind(ObjectName(i),"SSSR",0)==-1)
     {
      
      
      if(ObjectType(ObjectName(i))==OBJ_HLINE)
        {
        //Print("H");
           if(!ObjectCreate(idcel,"KOPIA Hor"+(string)i,OBJ_HLINE,0,0,ObjectGet(ObjectName(i),OBJPROP_PRICE1)))
            {
            Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
            //return(false);
            
           
            
            }
             //--- set rectangle color
               ObjectSetInteger(idcel,"KOPIA Hor"+(string)i,OBJPROP_COLOR,ObjectGetInteger(0,ObjectName(i),OBJPROP_COLOR));//Print("zzzzzz",GetLastError());
            //--- set the style of rectangle lines
               ObjectSetInteger(idcel,"KOPIA Hor"+(string)i,OBJPROP_STYLE,ObjectGetInteger(0,ObjectName(i),OBJPROP_STYLE));
            //--- set width of the rectangle lines
               ObjectSetInteger(idcel,"KOPIA Hor"+(string)i,OBJPROP_WIDTH,ObjectGetInteger(0,ObjectName(i),OBJPROP_WIDTH));
            //--- enable (true) or disable (false) the mode of filling the rectangle
               ObjectSetInteger(idcel,"KOPIA Hor"+(string)i,OBJPROP_FILL,ObjectGetInteger(0,ObjectName(i),OBJPROP_FILL));
               ObjectSetInteger(idcel,"KOPIA Hor"+(string)i,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES));
    
        }
      
      
      if(ObjectType(ObjectName(i))==OBJ_TREND)
        {
        //Print("T");
        if(!ObjectCreate(idcel,"KOPIA Tre"+(string)i,OBJ_TREND,0,(datetime)ObjectGet(ObjectName(i),OBJPROP_TIME1),ObjectGet(ObjectName(i),OBJPROP_PRICE1),ObjectGet(ObjectName(i),OBJPROP_TIME2),ObjectGet(ObjectName(i),OBJPROP_PRICE2)))
         {
         Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
         //return(false);
         }
         //--- set rectangle color
               ObjectSetInteger(idcel,"KOPIA Tre"+(string)i,OBJPROP_COLOR,ObjectGetInteger(0,ObjectName(i),OBJPROP_COLOR));//Print("zzzzzz",GetLastError());
            //--- set the style of rectangle lines
               ObjectSetInteger(idcel,"KOPIA Tre"+(string)i,OBJPROP_STYLE,ObjectGetInteger(0,ObjectName(i),OBJPROP_STYLE));
            //--- set width of the rectangle lines
               ObjectSetInteger(idcel,"KOPIA Tre"+(string)i,OBJPROP_WIDTH,ObjectGetInteger(0,ObjectName(i),OBJPROP_WIDTH));
            //--- enable (true) or disable (false) the mode of filling the rectangle
               ObjectSetInteger(idcel,"KOPIA Tre"+(string)i,OBJPROP_FILL,ObjectGetInteger(0,ObjectName(i),OBJPROP_FILL));
               ObjectSetInteger(idcel,"KOPIA Tre"+(string)i,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES));
        }
      if(ObjectType(ObjectName(i))==OBJ_RECTANGLE)
              {
              
             //Print("K");
             //Print(ObjectGet(ObjectName(i),OBJPROP_TIME1)," ",ObjectGet(ObjectName(i),OBJPROP_PRICE1)," ",ObjectGet(ObjectName(i),OBJPROP_TIME2)," ",ObjectGet(ObjectName(i),OBJPROP_PRICE2));
             if(!ObjectCreate(idcel,"KOPIA Kwa"+(string)i,OBJ_RECTANGLE,0,(datetime)ObjectGet(ObjectName(i),OBJPROP_TIME1),ObjectGet(ObjectName(i),OBJPROP_PRICE1),ObjectGet(ObjectName(i),OBJPROP_TIME2),ObjectGet(ObjectName(i),OBJPROP_PRICE2)))
             {
              Print(__FUNCTION__,
                  ": failed to create a rectangle! Error code = ",GetLastError());
              //return(false);
             }
             
             
             //--- set rectangle color
               ObjectSetInteger(idcel,"KOPIA Kwa"+(string)i,OBJPROP_COLOR,ObjectGetInteger(0,ObjectName(i),OBJPROP_COLOR));//Print("zzzzzz",GetLastError());
            //--- set the style of rectangle lines
               ObjectSetInteger(idcel,"KOPIA Kwa"+(string)i,OBJPROP_STYLE,ObjectGetInteger(0,ObjectName(i),OBJPROP_STYLE));
            //--- set width of the rectangle lines
               ObjectSetInteger(idcel,"KOPIA Kwa"+(string)i,OBJPROP_WIDTH,ObjectGetInteger(0,ObjectName(i),OBJPROP_WIDTH));
            //--- enable (true) or disable (false) the mode of filling the rectangle
               ObjectSetInteger(idcel,"KOPIA Kwa"+(string)i,OBJPROP_FILL,ObjectGetInteger(0,ObjectName(i),OBJPROP_FILL));
               ObjectSetInteger(idcel,"KOPIA Kwa"+(string)i,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES));
        }
        
        
        if(ObjectType(ObjectName(i))==OBJ_FIBO)
              {
              
             //Print("F");
             //Print(ObjectGet(ObjectName(i),OBJPROP_TIME1)," ",ObjectGet(ObjectName(i),OBJPROP_PRICE1)," ",ObjectGet(ObjectName(i),OBJPROP_TIME2)," ",ObjectGet(ObjectName(i),OBJPROP_PRICE2));
             if(!ObjectCreate(idcel,"FIBO"+(string)i,OBJ_FIBO,0,(datetime)ObjectGet(ObjectName(i),OBJPROP_TIME1),ObjectGet(ObjectName(i),OBJPROP_PRICE1),ObjectGet(ObjectName(i),OBJPROP_TIME2),ObjectGet(ObjectName(i),OBJPROP_PRICE2)))
             {
              Print(__FUNCTION__,
                  ": failed to create a rectangle! Error code = ",GetLastError());
              //return(false);
             }
             
             
             //--- set rectangle color
               ObjectSetInteger(idcel,"FIBO"+(string)i,OBJPROP_COLOR,ObjectGetInteger(0,ObjectName(i),OBJPROP_COLOR));//Print("zzzzzz",GetLastError());
            //--- set the style of rectangle lines
               ObjectSetInteger(idcel,"FIBO"+(string)i,OBJPROP_STYLE,ObjectGetInteger(0,ObjectName(i),OBJPROP_STYLE));
            //--- set width of the rectangle lines
               ObjectSetInteger(idcel,"FIBO"+(string)i,OBJPROP_WIDTH,ObjectGetInteger(0,ObjectName(i),OBJPROP_WIDTH));
            //--- enable (true) or disable (false) the mode of filling the rectangle
               ObjectSetInteger(idcel,"FIBO"+(string)i,OBJPROP_FILL,ObjectGetInteger(0,ObjectName(i),OBJPROP_FILL));
               //OBJPROP_TIMEFRAMES
               ObjectSetInteger(idcel,"FIBO"+(string)i,OBJPROP_TIMEFRAMES,ObjectGetInteger(0,ObjectName(i),OBJPROP_TIMEFRAMES));
           
        }
        
        
     }
  ChartRedraw(idcel);
  }
  
//     if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
//     {
//      Print(__FUNCTION__,
//            ": failed to create a rectangle! Error code = ",GetLastError());
//      return(false);
//     }



void usun_obiekty(long idcel)
  {
   //for(int i=ObjectsTotal(idcel,-1);i>=0;i--)
     {
      //if(StringFind(ObjectName(i),przedrostek_obiektu,0)!=-1)
        { 
        ObjectsDeleteAll(idcel,0,OBJ_HLINE); 
        ObjectsDeleteAll(idcel,0,OBJ_TREND); 
        ObjectsDeleteAll(idcel,0,OBJ_RECTANGLE); 
        ObjectsDeleteAll(idcel,0,OBJ_FIBO); 
        }
     }
  }