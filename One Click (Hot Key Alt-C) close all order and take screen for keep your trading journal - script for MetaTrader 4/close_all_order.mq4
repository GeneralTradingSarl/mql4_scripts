//+------------------------------------------------------------------+
//| close_All_Order.mq4                                              |
//| Copyright 2018 , raymondyeung.htc@gmail.com                      |
//| Speed Technology                                                 |
//| 1) CLose all order on the Symbol Chart                           |
//| 2) Take screen for keep a Trading Journal                        |
//+------------------------------------------------------------------+

#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string dtbahl()
  {
   string dt="Local Time : "+TimeToStr(LocalTime(),TIME_DATE|TIME_SECONDS)+
             "         "+ IntegerToString((Time[0]-Time[1])/60)+" mins Chart"+"           Close Order"+"\n"+
             "Bid :"+DoubleToStr(Bid,Digits)+" Ask :"+DoubleToStr(Ask,Digits)+
             " High :"+DoubleToStr(High[0],Digits)+" Low :"+DoubleToStr(Low[0],Digits);
   return (dt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   bool   result;
   double price;
   int    cmd,error;
   int    requote;
   int    cnt;

//----  

   if(OrdersTotal()==0)
     {
      Comment(dtbahl(),"\n","No any opened order.");
      PlaySound("alert2.wav");
      Sleep(3000);
     }

   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)

     {

      if((OrderSelect(cnt,SELECT_BY_POS)==true) && OrderSymbol()==Symbol())
        {
         cmd=OrderType();

         if(cmd==OP_BUY || cmd==OP_SELL)
           {
            requote=1;
            while(true && requote<10)
              {
               if(cmd==OP_BUY) price=Bid;
               else            price=Ask;

               result=OrderClose(OrderTicket(),OrderLots(),price,2,CLR_NONE);
               if(result!=TRUE)
                 {
                  PlaySound("alert2.wav");
                  error=GetLastError(); Print("LastError = ",error);
                 }
               else
                 {
                  PlaySound("ok.wav");
                  string filename= IntegerToString(OrderTicket())+"_"+
                                  StringSubstr(("0"+ IntegerToString(Period())),StringLen("0"+IntegerToString(Period()))-2,2)+"mins"+
                                  "_Close_ca.gif";

                  Comment(dtbahl());

                  if(!WindowScreenShot(filename,640,480)) Print("indowScreenShot error: ",ErrorDescription(GetLastError()));
                  error=0;
                 }

               if(error==135) RefreshRates();
               else break;
               requote=requote+1;
              } // while(true && requote < 10)
           } // (cmd==OP_BUY || cmd==OP_SELL)
        } // (OrderSelect(cnt, SELECT_BY_POS)==true)
      else Print("Error when order select ",GetLastError());
     }

   Comment("","\n","","\n");

   return(0);
  }
//+------------------------------------------------------------------+
