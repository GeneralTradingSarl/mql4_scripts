//+------------------------------------------------------------------+
//|                                          CloseMultipleOrders.mq4 |
//|                                        Copyright 2014, Genius Fx |
//|                            https://www.mql5.com/en/signals/61548 |
//+------------------------------------------------------------------+
/*
   A simple script to close multiple market orders. 
   Parameters:
   *ClossAll   -> If this parameter is set to true, all orders (Buy, Sell, Pending orders) are close. This parameter supercedes every other.
   *CloseBuyOders -> Closes only Buy orders. If 'CloseOnlyProfit is set to true it closes only Buy positions in profit.
   *CloseSellOrders ->  Closes only Sell Orders. If 'CloseOnlyProfit' is set to true it closes only Sell positions in profit.
   *CloseBuyLimits   -> Delete all BuyLimit pending orders if set to true.
   *CloseSellLimit   -> Delete all SellLimit pending orders if set to true.
   *CloseOnlyProfit  -> Will close only trades in profit. If 'CloseAll' is set to true, this parameter will be ignored and all trades will be closed
   *Slippage   -> The minimum allow Slippage. Leave current settings intact if unsure of slippage to apply.
   
   Programming is my hobby. Just program for fun, though I am a newbie in mql, I do my best in learning new things.
   If you intend to modify this code for efficiency, flexibility, or for any other purpose, please do well to notify me on the modification.
   I shall really appreciate it.
   
   >>>>>>>>>>>>>>>>>>>>>>>>>>>>> ENJOY THE RELEASE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
*/

#property copyright "Copyright 2014, Genius Fx"
#property link      "https://www.mql5.com/en/signals/61548"
#property version   "1.1"
#property strict
#property script_show_inputs
//--- input parameters
input bool     CloseAll=false;
input bool     CloseBuyOrders=false;
input bool     CloseSellOrders=false;
input bool     DeleteBuyLimits=false;
input bool     DeleteSellLimits=false;
input bool     CloseOnlyProfits=true;
input int      Slippage=3;

int ticket;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      if(CloseAll){
         //Close everything
         for(int i=OrdersTotal()-1; i>=0; i--){
            if(!OrderSelect(i, SELECT_BY_POS))continue; //If order selection fails, move to the next loop
            
            if(OrderType()==OP_BUY || OrderType()==OP_SELL){
               if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage) ){
                  Alert("Block: CloseAll. Order #",OrderTicket()," not closed. Error Code: ",GetLastError());
               }
               else {
                  Alert("Block: CloseAll. Order #",OrderTicket()," closed successfully.");
               }
            }
            
            if(OrderType()==OP_BUYLIMIT && OrderType()==OP_SELLLIMIT){
               if(!OrderDelete(OrderTicket(), clrOrange)){
                  Alert("Block: PendingOrder. Order #", OrderTicket(), " not deleted");
               }
               else {
                  Alert("Block: PendingOrder. Order #", OrderTicket(), " deleted successfully.");
               }
            }
         }
      }//CloseAll ends
      else if(CloseOnlyProfits){
         if(CloseBuyOrders || CloseSellOrders){ //If close buy or sell is enabled
            for(int i=OrdersTotal()-1; i>=0; i--){
               if(!OrderSelect(i, SELECT_BY_POS))continue;
               
               //Check if it's close buy
               if(CloseBuyOrders){
                  if(OrderType() == OP_BUY) {
                      //Check to seen if in profit
                      if(OrderProfit()>0){  
                        if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)){
                           Alert("Block: CloseOnlyProfits. Order #",OrderTicket()," not closed. Error Code: ",GetLastError());
                        }
                        else {
                           Alert("Block: CloseOnlyProfits. Buy Order #",OrderTicket()," closed successfull.");
                        }
                     }
                     else {//Order not in profit
                        Alert("Block: CloseOnlyProfits. Buy Order #",OrderTicket()," skipped. Not in profit");
                     }
                  }
               }
               
               //Check if it's close sell
               if(CloseSellOrders){
                  if(OrderType() == OP_SELL) {
                      //Check to seen if in profit
                      if(OrderProfit()>0){  
                        if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)){
                           Alert("Block: CloseOnlyProfits. Sell Order #",OrderTicket()," not closed. Error Code: ",GetLastError());
                        }
                        else {
                           Alert("Block: CloseOnlyProfits. Sell Order #",OrderTicket()," closed successfull.");
                        }
                     }
                     else {//Order not in profit
                        Alert("Block: CloseOnlyProfits. Sell Order #",OrderTicket()," skipped. Not in profit");
                     }
                  }
               }
            }
         }
         else {
            //Close both buy and sell in profit
            for(int i=OrdersTotal()-1; i>=0; i--){
               if(!OrderSelect(i, SELECT_BY_POS))continue;
               
               if(OrderType()==OP_BUY || OrderType()==OP_SELL){
                  if(OrderProfit()>0){
                     //In profit
                     if(!OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Slippage) ){
                        Alert("Block: CloseOnlyProfits. Order #",OrderTicket()," not closed. Error Code: ",GetLastError());
                     }
                     else {
                        Alert("Block: CloseOnlyProfits. Order #",OrderTicket()," closed in profit.");
                     }
                  }
                  else {
                     //Not in profit
                     Alert("Block: CloseOnlyProfits. Order #",OrderTicket()," skipped. Not in profit.");
                  }
               }
            }
         }
         
      }//CloseOnlyProfits end
      
      if(DeleteBuyLimits || CloseAll){
         for(int i=0; i<OrdersTotal(); i++){
            if(!OrderSelect(i, SELECT_BY_POS)){
               Alert("Order not selected.");
            }
            else {
               switch(OrderType()){
                  case OP_BUYLIMIT:
                     if(!OrderDelete(OrderTicket(), clrOrangeRed)){
                        Alert("Block DeleteBuyLimits: Order #",OrderTicket()," not deleted.");
                     }
                     else {
                        Alert("Block DeleteBuyLimits: Order #",OrderTicket()," closed.");
                     }
                     continue;
               }
            }
         }
      }
      
      if(DeleteSellLimits || CloseAll){
         for(int i=0; i<OrdersTotal(); i++){
            if(!OrderSelect(i, SELECT_BY_POS)){
               Alert("Order not selected.");
            }
            else {
               switch(OrderType()){
                  case OP_SELLLIMIT:
                     if(!OrderDelete(OrderTicket(), clrOrangeRed)){
                        Alert("Block DeleteSellLimits: Order #",OrderTicket()," not deleted.");
                     }
                     else {
                        Alert("Block DeleteSellLimits: Order #",OrderTicket()," closed.");
                     }
                     continue;
               }
            }
         }
      }
  }
//+------------------------------------------------------------------+
