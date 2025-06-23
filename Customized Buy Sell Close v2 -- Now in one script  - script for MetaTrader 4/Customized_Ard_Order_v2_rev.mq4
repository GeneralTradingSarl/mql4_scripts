//+------------------------------------------------------------------+
//|                             Customized Ard Buy Sell Close V2.mq4 |
//|                                     Copyright © 2008, ARDIANSYAH |
//|                                               dailysignal.co.cc  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Ardiansyah"
#property link      "DailySignal.co.cc"
#property show_inputs
extern int code=0;            //Code For Order 0 For Close Current, 1 For Buy, 2 For Sell
extern int DealerSell = 10;   //Sell Divisor of equity amount
extern int DealerBuy = 10;    //Buy Divisor of equity amount
extern double SL = 50;        //StopLoss
extern double TP = 50;        //TakeProfit
extern int SlipSell =30;      //Slippage for Sell
extern int SlipBuy = 30;       //Slippage for Buy
extern int SlipClose = 30;     //Slipage For Close
extern int IP = 10;           //It's for interbank rate 0,x for normal is set to 1
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
{
 
 int Total = OrdersTotal(); 
 switch(code)
 {
 case 0:
  while(true){
  if(close()==true) break;
  }
  break;
 case 1:
  while(true){
   if(close()==true) 
  {
    if(buy()==true) break;}
    }
    break;
 case 2:
   while(true){
   if(close()==true) 
  {
    if(sell()==true) break;}
    }
    break; 
default:
    Alert("Please Change the Code 0,1,2");// Non Code Empty Code Confirmation
    break;
 } 

return(0);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//Sell Order Function                                         ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
bool sell() //you can customized the function
{
   int  ticket, err,j=0;
   double Margin, result, Lots ;
   string sell = "selling order";
   Margin = AccountFreeMargin( ) ;
   result = Margin/DealerSell/1000;
   if(result<1)
   {
      result=result*10;
      Lots=MathFloor(result)/10;
   }
   else  Lots=MathFloor(result);
   Print("Amount of Lots  =  ", Lots); 
  
  while(true)
   {
   int limit=0;
   RefreshRates();
   double bid1=Bid;
   ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,SlipSell,(Ask+SL*Point*IP),(Ask-TP*Point*IP),sell,0,0,White);
   Print("Selling Order ........."); 
   if(ticket<0)
       {
        err=GetLastError();
        Print("Selling Order Failed == with error ",err);
        if (err==135) {RefreshRates();}
        else if(err==129)
            {
               while(true) 
               {
                  if(limit==0) {int bid2=Bid;limit=1;}
                  RefreshRates();
                  if(bid2 != Bid) break;
                  
                  }
               
               }
        else {return(false);break;}
        }
     else 
     {
     Print("Selling Order ->OK .. Price =", result);
     return(true);
     break;
    }  
  }
  
}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//End Function                                                ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//Close Order Function                                        ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
bool close()//you cancustomized the function
{
 int Total,  err;
 bool trfls;
 bool cls;
 double price;
 Total = OrdersTotal();
 if(Total==0) return(true);
 string Symb=Symbol();  
 for(int i=0; i<Total; i++)
   {  
     int limit=0;
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
     if(Symb != OrderSymbol()) {trfls=true;}
     else
       {
         RefreshRates();
         if (OrderType() == OP_BUY) price=Bid;
         if (OrderType() == OP_SELL) price=Ask;
         cls=OrderClose(OrderTicket(),OrderLots(),price,SlipClose,CLR_NONE);
         Print("Closiing Order .........");
         if (cls==false) 
        { 
            err = GetLastError();
            if (err==135) RefreshRates();
            else if(err==129)
            {
               while(true) 
               {
                  if(limit==0) {int bid2=Bid;limit=1;}
                  RefreshRates();
                  if(bid2 != Bid) break;
                  
                  }
               
               }
            else 
            {
             Print("Closing Order Failed == with error ",err);
             return(false);
             }
          }
         else 
         {
          Print("Closing Order = OK");
          trfls=true;
          //return(true);
         }
        }
      }
    }
   return(trfls);
   }
   

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//End Function                                                        ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//Buy Order Function                                         ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
bool buy()//you can customized the function
{
   int  ticket, err, j=0;
   double Margin, result, Lots ;
   string buy = "buying order";
   Margin = AccountFreeMargin( ) ;
   result = Margin/DealerBuy/1000;
   if(result<1)
   {
      result=result*10;
      Lots=MathFloor(result)/10;
   }
   else  Lots=MathFloor(result);
   Print("Amount of Lots  =  ", Lots);
  while(true)
  
   {
   int limit=0;
   RefreshRates();
   ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask ,SlipBuy,(Bid-SL*Point*IP),(Bid+TP*Point*IP),buy,0,0,White);
   Print("Buying Order ........."); 
   if(ticket<0)
      {
      err=GetLastError();
      Print("Buying Order Failed == with error ",err);
      if (err==135) RefreshRates();
      else if(err==129)
            {
               while(true) 
               {
                  if(limit==0) {int bid2=Bid;limit=1;}
                  RefreshRates();
                  if(bid2 != Bid) break;
                  
                  }
               
               }
	   else {return(false);break;}
        }
     else 
     {
     Print("Buying Order ->OK .. Price =", result);
     return(true);
     break;
    }  
  }

}
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||
//End Function                                                ||
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++||