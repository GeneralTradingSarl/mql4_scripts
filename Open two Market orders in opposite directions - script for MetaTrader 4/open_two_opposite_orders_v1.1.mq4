//+------------------------------------------------------------------+
//|                                     Open two opposite orders.mq4 |
//|                                         Copyright 2021, Odera FX |
//|                                       mailto:chidera67@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Odera FX"
#property link      "mailto:chidera67@gmail.com"
#property version   "1.10"
#property strict
#property script_show_inputs

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
input double   InpLots        = 0.01;                    //Size of the trade
input int      InpSL          = 150;                     //Stop loss in points 150 = 15 pips
input int      InpTP          = 300;                     //Take profit in points 300 = 30 pips
input int      InpRetries     = 10;                      //Retries in case of failed trades
int error;
double sl,tp;
double lot_size=InpLots;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   int retry1 = 0, retry2 = 0;
   while(true)
     {
      int ticket=OrderSend(_Symbol,OP_BUY,lot_size,Ask,3,0,0);       // Opens a market order and assigns the ticket id to the variable ticket
      error=GetLastError();
      if(Fun_Error(error)==1)
         continue;
      if(ticket > 0 && OrderSelect(ticket,SELECT_BY_TICKET))
        {
         int mod_retry = 0;
         while(true)
           {
            mod_retry++;
            sl = NormalizeDouble(Bid - (InpSL*Point),Digits);
            tp = NormalizeDouble(Bid + (InpTP*Point),Digits);
            bool order_modify=OrderModify(ticket,OrderOpenPrice(),sl,tp,0);   //Modifies the market order to add stop loss and take profit levels this is especially useful ECN accounts that do not allow stop levels with OrderSend function
            if(mod_retry > InpRetries)
               break;
            if(Fun_Error(error)==1)
               continue;
            else
               break;
           }
        }
      retry1++;
      if(ticket > 0 || retry1 >= InpRetries)
         break;
     }
   while(true)
     {
      RefreshRates();
      int ticket2=OrderSend(_Symbol,OP_SELL,lot_size,Bid,3,0,0);           //Opens a market order and assigns the ticket id to the variable ticket
      error= GetLastError();
      if(Fun_Error(error)==1)
         continue;
      if(ticket2 > 0 && OrderSelect(ticket2,SELECT_BY_TICKET))
        {
         int mod_retry = 0;
         while(true)
           {
            mod_retry++;
            sl = NormalizeDouble(Ask + (InpSL*Point),Digits);
            tp = NormalizeDouble(Ask - (InpTP*Point),Digits);
            bool order_modify2=OrderModify(ticket2,OrderOpenPrice(),sl,tp,0);   //Modifies the market order to add stop loss and take profit levels this is especially useful ECN accounts that do not allow stop levels with OrderSend function
            if(mod_retry > InpRetries)
               break;
            if(Fun_Error(error)==1)
               continue;
            else
               break;
           }
        }
      retry2++;
      if(ticket2 > 0 || retry2 >= InpRetries)
         break;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fun_Error(int Error) // Function of processing errors
  {
   switch(Error)
     {
      // Not crucial errors
      case  4:
         Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 6:
         Alert("No connection to trade server. Trying once again...");
         RefreshRates();
         return (1);
      case 129:
         Alert("Invalid price! Trying once again with updated price.");
         RefreshRates();
         return (1);
      case 130:
         Alert("Error 130 occured! Invalid stops");
         return (0);
      case 131:
         Alert("Invalid Trade Volume. Increasing lots by 0.01 and trying again");
         lot_size=lot_size+0.01;
         RefreshRates();
         return(1);
      case 145:
         Alert("Modification is denied because order is too close to market");
         return(0);
      case 135:
         Alert("Price changed. Trying once again..");
         RefreshRates();                        // Refresh rates
         return(1);                             // Exit the function
      case 136:
         Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)           // Till a new tick
            Sleep(1);                           // Pause in the loop
         return(1);                             // Exit the function
      case 137:
         Alert("Broker is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 146:
         Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                            // Simple solution
         return(1);                             // Exit the function
      // Critical errors
      case  2:
         Alert("Common error.");
         return(0);                             // Exit the function
      case  5:
         Alert("Old terminal version.");
         return(0);                             // Exit the function
      case 64:
         Alert("Account blocked.");
         return(0);                             // Exit the function
      case 133:
         Alert("Trading forbidden.");
         return(0);                             // Exit the function
      case 134:
         Alert("Not enough money to execute operation.");
         return(0);                             // Exit the function
      default:
         if(Error !=0)
            Alert("Error occurred: ",Error);  // Other variants
         return(0);                             // Exit the function
     }                                       //End of switch function
  }                                          //End of Fun error
