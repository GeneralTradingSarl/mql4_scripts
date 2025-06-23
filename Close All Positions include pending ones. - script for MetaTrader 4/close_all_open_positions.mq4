#property strict

int start()

{

   double total;

   int cnt;

   bool result = false;

   while(OrdersTotal()>0)

   {

      // close opened orders first

      total = OrdersTotal();

      for (cnt = total-1; cnt >=0 ; cnt--)

      {

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 

         {

            switch(OrderType())

            {

               case OP_BUY       :

                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Violet);break;

                   

               case OP_SELL      :

                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Violet); break;

            }             

         }

      }

      // and close pending     

      for (cnt = total-1; cnt >=0 ; cnt--)

      {

         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 

         {

            switch(OrderType())

            {

               case OP_BUYLIMIT  : result = OrderDelete(OrderTicket()); break;

               case OP_SELLLIMIT : result = OrderDelete(OrderTicket()); break;

               case OP_BUYSTOP   : result = OrderDelete(OrderTicket()); break;

               case OP_SELLSTOP  : result = OrderDelete(OrderTicket()); break;

            }

         }

      }

      if(result == false)

      {

      Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );

      Sleep(3000);

      }

   }

   return(0);

}