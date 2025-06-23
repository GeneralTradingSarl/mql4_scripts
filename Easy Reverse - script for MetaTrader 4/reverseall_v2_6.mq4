//+------------------------------------------------------------------+
//|                                                   reverseall.mq4 |
//|                                 Copyright © 2015, FlashTrade JFL |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, FlashTrade JFL"
#property link      "https://www.mql5.com/en/users/aeither"
#property version   "1.10"
#property strict
#property script_show_inputs
//--- input parameters
input bool     DoubleReverse=false; //Change "true" to duplicate Lot
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int m=1;
   int OT=OrdersTotal();
   double Lot[];
   string Symb[];
   int op[],ticket[];
   ArrayResize(Lot,OT);
   ArrayResize(op,OT);
   ArrayResize(ticket,OT);
   ArrayResize(Symb,OT);
   for(int i=0; i<OT; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY)
           {//Close Buy
            Lot[i]=OrderLots();
            op[i]=OP_SELL;
            ticket[i]=OrderTicket();
            Symb[i]=OrderSymbol();
           }
         if(OrderType()==OP_SELL)
           {//Close Sell
            Lot[i]=OrderLots();
            op[i]=OP_BUY;
            ticket[i]=OrderTicket();
            Symb[i]=OrderSymbol();
           }
        } //if (select)
     } //for  
   if(DoubleReverse==true) { m=2; }
   for(int i=0; i<OT; i++)
     {
      if(op[i]==OP_SELL && Symb[i]==Symbol())
        {
         if(OrderClose(ticket[i],Lot[i],Bid,5,CLR_NONE)==false)
           { Print("Error Closing"); return; }
         if(OrderSend(Symbol(),OP_SELL,Lot[i]*m,Bid,5,0,0,NULL,0,0,CLR_NONE)==false)
           { Print("Error Selling"); return; }
        }
      if(op[i]==OP_BUY && Symb[i]==Symbol())
        {
         if(OrderClose(ticket[i],Lot[i],Ask,5,CLR_NONE)==false)
           { Print("Error Closing"); return; }
         if(OrderSend(Symbol(),OP_BUY,Lot[i]*m,Ask,5,0,0,NULL,0,0,CLR_NONE)==false)
           { Print("Error Buying"); return; }
        }
     }
  }
//+------------------------------------------------------------------+
