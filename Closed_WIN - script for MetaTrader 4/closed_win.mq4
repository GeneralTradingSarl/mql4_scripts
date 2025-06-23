//+------------------------------------------------------------------+
//|                                                       Closed WIN |
//|                                Copyright © 2016 (Mike eXplosion) |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016 (Mike eXplosion)"
#property link      "https://www.mql5.com/en/users/mike_explosion"
#property version   "1.0"

#property strict

#property description "Cierre de posiciones ganadoras."

#property show_inputs

extern string Indicator       = "Closed WIN v1.0";
extern string Copyright       = "Mike eXplosion © 2016";
extern bool   Buy             =true;
extern bool   Sell            =true;
extern int    Solo_Magico     =0;
extern int    Omitir_Magico   =0;
extern bool   Solo_Simbolo    =false;
extern string Simbolo         ="EURUSD";
extern bool   Solo_Ganadoras  =true;
extern bool   Solo_Perdedoras =false;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   int ticket;
   if(OrdersTotal()==0) return(0);
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(Solo_Magico>0 && OrderMagicNumber()!=Solo_Magico) continue;
         if(Omitir_Magico>0 && OrderMagicNumber()==Omitir_Magico) continue;
         if(Solo_Simbolo==true && OrderSymbol()!=Simbolo)
           {Print("Simbolo diferente"); continue;}
         if(Solo_Ganadoras==true && OrderProfit()<0) continue;
         if(Solo_Perdedoras==true && OrderProfit()>0) continue;
         if(OrderType()==0 && Buy==true)
           {

            ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Red);
            if(ticket==-1) Print("Error: ",GetLastError());
            if(ticket>0) Print("Posición ",OrderTicket()," cerrada.");
           }
         if(OrderType()==1 && Sell==true)
           {

            ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Red);
            if(ticket==-1) Print("Error: ",GetLastError());
            if(ticket>0) Print("Posición ",OrderTicket()," cerrada.");
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+ 
