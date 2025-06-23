//+------------------------------------------------------------------+
//|                             Open Order With Trade Management.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "For BuyStop, 'Price' Should Be Greater Than The Current Market Price."
#property description "For SellStop, 'Price' Should Be Less Than The Current Market Price." 
#property description "For BuyLimit, 'Price' Should Be Less Than The Current Market Price." 
#property description "For SellLimit, 'Price' Should Be Greater Than The Current Market Price."  
#property strict
#property script_show_inputs

enum Order_Type
      { 
          Buy = OP_BUY, 
          Sell = OP_SELL, 
          BuyStop = OP_BUYSTOP, 
          SellStop = OP_SELLSTOP, 
          BuyLimit = OP_BUYLIMIT, 
          SellLimit = OP_SELLLIMIT
      };
       
input Order_Type OrderType = Buy;
input double StopLossInPips = 100;     //Stop Loss (In Pips)
input double TakeProfitInPips = 200;   //Take Profit (In Pips)
input double LotSize = 0.10;           //Lot Size
input int    Slippage = 10;            //Slippage
input int    Magic_Number = 12345;     //Magic Number For Trade
input double Price = 0.0;              //Price For Placing Pending Order

//Global Variables
int ticket;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{  
   if(OrderType == Buy)
     {
         //Open Buy Order
         ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, Slippage, Bid - StopLossInPips*Pip(), Bid + TakeProfitInPips*Pip(), "Buy Order By Script", Magic_Number, 0, Blue);
                     
         //Checking Error Placing Trade
         if(ticket<0) 
            { 
                  Print("Buy Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("Buy Order placed successfully");    
            }      
     }
     
   else if(OrderType == BuyStop)
     {
         //Open BuyStop Order
         ticket = OrderSend(Symbol(), OP_BUYSTOP, LotSize, Price, Slippage, Price - StopLossInPips*Pip(), Price + TakeProfitInPips*Pip(), "BuyStop Order By Script", Magic_Number, 0, Blue);
                     
         //Checking Error Placing Trade
         if(ticket<0) 
            { 
                  Print("BuyStop Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("BuyStop Order placed successfully");    
            }      
     }  

   else if(OrderType == BuyLimit)
     {
         //Open BuyLimit Order
         ticket = OrderSend(Symbol(), OP_BUYLIMIT, LotSize, Price, Slippage, Price - StopLossInPips*Pip(), Price + TakeProfitInPips*Pip(), "BuyLimit Order By Script", Magic_Number, 0, Blue);
                     
         //Checking Error Placing Trade
         if(ticket<0) 
            { 
                  Print("BuyLimit Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("BuyLimit Order placed successfully");    
            }      
     } 
             
   else if(OrderType == Sell)
     {
         //Open Sell Order
         ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, Slippage, Ask + StopLossInPips*Pip(), Ask - TakeProfitInPips*Pip(), "Sell Order By Script", Magic_Number, 0, Red);
                     
         //Checking Error Placing Trade      
         if(ticket<0) 
            { 
                  Print("Sell Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("Sell Order placed successfully");    
            }           
     }
   else if(OrderType == SellStop)
     {
         //Open SellStop Order
         ticket = OrderSend(Symbol(), OP_SELLSTOP, LotSize, Price, Slippage, Price + StopLossInPips*Pip(), Price - TakeProfitInPips*Pip(), "SellStop Order By Script", Magic_Number, 0, Red);
                     
         //Checking Error Placing Trade      
         if(ticket<0) 
            { 
                  Print("SellStop Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("SellStop Order placed successfully");    
            }           
     }
   else if(OrderType == SellLimit)
     {
         //Open SellLimit Order
         ticket = OrderSend(Symbol(), OP_SELLLIMIT, LotSize, Price, Slippage, Price + StopLossInPips*Pip(), Price - TakeProfitInPips*Pip(), "SellLimit Order By Script", Magic_Number, 0, Red);
                     
         //Checking Error Placing Trade      
         if(ticket<0) 
            { 
                  Print("SellLimit Order failed with error #",GetLastError()); 
            } 
         else 
            {
                  Print("SellLimit Order placed successfully");    
            }           
     }
}
//+------------------------------------------------------------------+


//Getting Pip Value
double Pip()
{
   double GetPip=Point()*10;
   return GetPip;
}