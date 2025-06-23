//+------------------------------------------------------------------+
//|                            Global_Close_Orders_Management_V1.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "Julian 2024 - free open source"
#property description   "Global Close Orders Management."
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss,"
#property description   "nor for happiness and euphoria on gains."
#property strict
#property show_inputs

//***************************************************************************//
extern string  Close_Orders_Management                    =  ""   ;
//***************************************************************************//
input bool     Close_All_ORDERS                          =  false;
input bool     Close_Active_Buy_and_Sell_ORDERS          =  false;
input bool     Close_Active_Buy_ORDERS                   =  false;
input bool     Close_Active_Sell_ORDERS                  =  false;
//***************************************************************************//
input bool     Close_All_Pending_Orders                  =  false;
input bool     Close_Buy_Pending_Orders                  =  false;
input bool     Close_Sell_Pending_Orders                 =  false;
//***************************************************************************//
input bool     Close_All_LIMIT_Orders                    =  false;
input bool     Close_BUY_LIMIT_Orders                    =  false;
input bool     Close_SELL_LIMIT_Orders                   =  false;
//***************************************************************************//
input bool     Close_All_STOP_Orders                     =  false;
input bool     Close_BUY_STOP_Orders                     =  false;
input bool     Close_SELL_STOP_Orders                    =  false;
//***************************************************************************//
input int      Close_ALL_Positive_Orders_Higher_than_Money    =  0;
input int      Close_BUY_Positive_Orders_Higher_than_Money    =  0;
input int      Close_SELL_Positive_Orders_Higher_than_Money   =  0;
//***************************************************************************//
input int      Close_ALL_Negative_Orders_Lower_than_Money     =  0;
input int      Close_BUY_Negative_Orders_Lower_than_Money     =  0;
input int      Close_SELL_Negative_Orders_Lower_than_Money    =  0;
//***************************************************************************//

//+------------------------------------------------------------------+
//|OnStart                                                           |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(IsTradeAllowed())
     {
      //***************************************************************************************//
      if(Close_All_ORDERS)                         {Close_All_ORDERS_X();}
      if(Close_Active_Buy_and_Sell_ORDERS)         {Close_Active_Buy_and_Sell_ORDERS_X();}
      if(Close_Active_Buy_ORDERS)                  {Close_Active_Buy_ORDERS_X(); }
      if(Close_Active_Sell_ORDERS)                 {Close_Active_Sell_ORDERS_X();}
      //***************************************************************************************//
      if(Close_All_Pending_Orders)                 {Close_All_Pending_Orders_X(); }
      if(Close_Buy_Pending_Orders)                 {Close_Buy_Pending_Orders_X(); }
      if(Close_Sell_Pending_Orders)                {Close_Sell_Pending_Orders_X();}
      //***************************************************************************************//
      if(Close_All_LIMIT_Orders)                   {Close_All_LIMIT_Orders_X(); }
      if(Close_BUY_LIMIT_Orders)                   {Close_Buy_LIMIT_Orders_X(); }
      if(Close_SELL_LIMIT_Orders)                  {Close_Sell_LIMIT_Orders_X();}
      //***************************************************************************************//
      if(Close_All_STOP_Orders)                    {Close_All_STOP_Orders_X(); }
      if(Close_BUY_STOP_Orders)                    {Close_BUY_STOP_Orders_X(); }
      if(Close_SELL_STOP_Orders)                   {Close_SELL_STOP_Orders_X();}
      //***************************************************************************************************//
      if(Close_ALL_Positive_Orders_Higher_than_Money> 0)   {Close_ALL_Positive_Orders_Higher_than_Money_X(); }
      if(Close_BUY_Positive_Orders_Higher_than_Money> 0)   {Close_BUY_Positive_Orders_Higher_than_Money_X(); }
      if(Close_SELL_Positive_Orders_Higher_than_Money>0)   {Close_SELL_Positive_Orders_Higher_than_Money_X();}
      //***************************************************************************************************//
      if(Close_ALL_Negative_Orders_Lower_than_Money< 0)    {Close_ALL_Negative_Orders_Lower_than_Money_X(); }
      if(Close_BUY_Negative_Orders_Lower_than_Money< 0)    {Close_BUY_Negative_Orders_Lower_than_Money_X(); }
      if(Close_SELL_Negative_Orders_Lower_than_Money<0)    {Close_SELL_Negative_Orders_Lower_than_Money_X();}
      //***************************************************************************************************//
     }
   else
      MessageBox("Enable AutoTrading Please ");
  }
//+------------------------------------------------------------------+
//|Close_All_ORDERS_X                                                |
//+------------------------------------------------------------------+
int Close_All_ORDERS_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           //+-----------------------------------------------------------------------------------------------------------------------+
           case OP_BUYLIMIT  :{int DEL_buylimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLLIMIT :{int DEL_sellimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_BUYSTOP   :{int DEL_buystop  = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLSTOP  :{int DEL_sellstop = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Active_Buy_and_Sell_ORDERS_X                                |
//+------------------------------------------------------------------+
int Close_Active_Buy_and_Sell_ORDERS_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Active_Buy_ORDERS_X                                         |
//+------------------------------------------------------------------+
int Close_Active_Buy_ORDERS_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Active_Sell_ORDERS_X                                        |
//+------------------------------------------------------------------+
int Close_Active_Sell_ORDERS_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_All_Pending_Orders_X                                        |
//+------------------------------------------------------------------+
int Close_All_Pending_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYLIMIT  :{int DEL_buylimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLLIMIT :{int DEL_sellimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_BUYSTOP   :{int DEL_buystop  = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLSTOP  :{int DEL_sellstop = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Buy_Pending_Orders_X                                        |
//+------------------------------------------------------------------+
int Close_Buy_Pending_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYLIMIT  :{int DEL_buylimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_BUYSTOP   :{int DEL_buystop  = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Sell_Pending_Orders_X                                       |
//+------------------------------------------------------------------+
int Close_Sell_Pending_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_SELLLIMIT :{int DEL_sellimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLSTOP  :{int DEL_sellstop = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_All_LIMIT_Orders_X                                          |
//+------------------------------------------------------------------+
int Close_All_LIMIT_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYLIMIT  :{int DEL_buylimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLLIMIT :{int DEL_sellimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Buy_LIMIT_Orders_X                                          |
//+------------------------------------------------------------------+
int Close_Buy_LIMIT_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYLIMIT  :{int DEL_buylimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_Sell_LIMIT_Orders_X                                         |
//+------------------------------------------------------------------+
int Close_Sell_LIMIT_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_SELLLIMIT :{int DEL_sellimit = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_All_STOP_Orders_X                                           |
//+------------------------------------------------------------------+
int Close_All_STOP_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYSTOP   :{int DEL_buystop  = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           case OP_SELLSTOP  :{int DEL_sellstop = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_BUY_STOP_Orders_X                                           |
//+------------------------------------------------------------------+
int Close_BUY_STOP_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUYSTOP   :{int DEL_buystop  = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_SELL_STOP_Orders_X                                          |
//+------------------------------------------------------------------+
int Close_SELL_STOP_Orders_X()
  {
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_SELLSTOP  :{int DEL_sellstop = OrderDelete(OrderTicket());}//+----------------------------------------------------+
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_ALL_Positive_Orders_Higher_than_Money_X                      |
//+------------------------------------------------------------------+
int Close_ALL_Positive_Orders_Higher_than_Money_X()
  {
  if(Close_ALL_Positive_Orders_Higher_than_Money>=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_BUY_Positive_Orders_Higher_than_Money_X                      |
//+------------------------------------------------------------------+
int Close_BUY_Positive_Orders_Higher_than_Money_X()
  {
  if(Close_ALL_Positive_Orders_Higher_than_Money>=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_SELL_Positive_Orders_Higher_than_Money_X                      |
//+------------------------------------------------------------------+
int Close_SELL_Positive_Orders_Higher_than_Money_X()
  {
  if(Close_ALL_Positive_Orders_Higher_than_Money>=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_ALL_Negative_Orders_Lower_than_Money_X                       |
//+------------------------------------------------------------------+
int Close_ALL_Negative_Orders_Lower_than_Money_X()
  {
  if(-Close_ALL_Negative_Orders_Lower_than_Money<=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           case OP_SELL      :{int CLS_sell     = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_BUY_Negative_Orders_Lower_than_Money_X                       |
//+------------------------------------------------------------------+
int Close_BUY_Negative_Orders_Lower_than_Money_X()
  {
  if(-Close_BUY_Negative_Orders_Lower_than_Money<=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
//+------------------------------------------------------------------+
//|Close_SELL_Negative_Orders_Lower_than_Money_X                       |
//+------------------------------------------------------------------+
int Close_SELL_Negative_Orders_Lower_than_Money_X()
  {
  if(-Close_SELL_Negative_Orders_Lower_than_Money<=OrderProfit()){
   int counter;
   for(counter = OrdersTotal()-1; counter >=0 ; counter--)
     {
      if(OrderSelect(counter,SELECT_BY_POS,MODE_TRADES))
        {
         switch(OrderType())
           {
           case OP_BUY       :{int CLS_buy      = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE);}
           }
        }
     }
  }
   return(0);
  }
