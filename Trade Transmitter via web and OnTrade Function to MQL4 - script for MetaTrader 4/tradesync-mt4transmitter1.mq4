//+------------------------------------------------------------------+
//|                                    TradeSync-MT4Transmitter1.mq4 |
//|                                                         TheCoder |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "TheCoder"
#property link      "https://www.mql5.com/en/users/brazilianguy3"
#define revnumber "1.00"
#property version   revnumber
#property strict

enum ENUM_TRADE_REQUEST_ACTIONS {TRADE_ACTION_DEAL, TRADE_ACTION_PENDING, TRADE_ACTION_SLTP, TRADE_ACTION_MODIFY, TRADE_ACTION_REMOVE, TRADE_ACTION_CLOSE_BY};
input string HubServerAddress="http://thecoder1.pythonanywhere.com:80";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   updateActiveOrders();
   TellUser((("Welcome to TradeSync Transmitter for MT4 version ") + (revnumber)));
   TellUser("Detected " + IntegerToString(active_total) + " active orders in account # " + IntegerToString(AccountNumber()) + " on Account Server "+ AccountServer()+" under the name of "+AccountName());
   TellUser("Trading Activity Broadcast Initiated");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(findChanged())
     {
      updateActiveOrders();
     }
  }
//+------------------------------------------------------------------+


/**
* cache for all active trades and orders
* as they were found during the previous tick
*/

int active_ticket[1000];
int active_type[1000];
double active_price[1000];
double active_stoploss[1000];
double active_takeprofit[1000];
bool active_still_active[1000];
int active_total;


/**
* find newly opened, changed or closed orders
* and send messages for every change. Additionally
* the function will return true if any changes were
* detected, false otherwise.
*/
bool findChanged()
  {
   bool changed = false;
   int total = (OrdersTotal()>1000)?1000:OrdersTotal();
   int ticket;
   int index;
   for(int i=0; i<total; i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         changed = true;
         continue;
        }
      ticket = OrderTicket();
      index = getOrderCacheIndex(ticket);
      if(index == -1)
        {
         // new order
         changed = true;
         messageNewOrder(ticket);
        }
      else
        {
         active_still_active[index] = true; // order is still there
         if(OrderOpenPrice() != active_price[index] ||
            OrderStopLoss() != active_stoploss[index] ||
            OrderTakeProfit() != active_takeprofit[index] ||
            OrderType() != active_type[index])
           {
            // already active order was changed
            changed = true;
            messageChangedOrder(active_ticket[index]);
           }
        }
     }

// find closed orders. Orders that are in our cached list
// from the last tick but were not seen in the previous step.
   for(index=0; index<active_total; index++)
     {
      if(active_still_active[index] == false)
        {
         // the order must have been closed.
         changed = true;
         messagePurgedOrder(active_ticket[index]);
        }

      // reset all these temporary flags again for the next tick
      active_still_active[index] = false;
     }
   return(changed);
  }

/**
* read in the current state of all open orders
* and trades so we can track any changes in the next tick
*/
void updateActiveOrders()
  {
   active_total = OrdersTotal();
   string strLine=" TradeSyncSummary [";
   uchar jsonSummaryData[];
   StringToCharArray(strLine, jsonSummaryData, 0, StringLen(strLine));
   int jsonWriteCount=StringLen(strLine);

   for(int i=0; i<active_total; i++)
     {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         active_ticket[i]=-1;
         continue;
        };
      active_ticket[i] = OrderTicket();
      active_type[i] = OrderType();
      active_price[i] = OrderOpenPrice();
      active_stoploss[i] = OrderStopLoss();
      active_takeprofit[i] = OrderTakeProfit();
      active_still_active[i] = false; // filled in the next tick
      //Elements for JSON File
      //JSON Format will be "array":[{

      strLine = "{"+
                "\"TR_ID\": "+IntegerToString(AccountNumber())+","+
                "\"POS_NUM\": "+ IntegerToString(active_ticket[i])+","+
                "\"SYMBOL\": \"" + OrderSymbol()+"\"," +
                "\"ORD_TYPE\": " + IntegerToString(active_type[i])+","+
                "\"PRICE\": "+DoubleToStr(active_price[i],5)+","+
                "\"SL\": "+DoubleToStr(active_stoploss[i],5)+","+
                "\"TP\": "+DoubleToStr(active_takeprofit[i],5)+"},"  ;

      StringToCharArray(strLine, jsonSummaryData, jsonWriteCount, StringLen(strLine));
      jsonWriteCount=jsonWriteCount+StringLen(strLine);

      //End of JSON Looped Elements
     }
   StringToCharArray("}]", jsonSummaryData, jsonWriteCount-2, 4);  //Fechamento da array com ]

   char serverResult[];
   string serverHeaders;
   int res = WebRequest("POST", HubServerAddress, "", "", 500, jsonSummaryData, ArraySize(jsonSummaryData), serverResult, serverHeaders);
   TellUser(("Just did WebRequest with: Positions Summary: "+CharArrayToString(jsonSummaryData) ));
   TellUser("While Transmitting Summary , Web request result was "+  IntegerToString(res) + ", error: #" + IntegerToString((res == -1 ? GetLastError() : 0)));




  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getOrderCacheIndex(int ticket)
  {
   int gOCIndex = -1;
   for(int a=0; a<active_total; a++)
     {
      if(ticket == active_ticket[a])
        {
         gOCIndex = a;
         break;
        }
     }
   return gOCIndex;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void messageNewOrder(int NewTicket)
  {
   TellUser(("About to Add Ticket "+ IntegerToString(NewTicket)));
   if(OrderSelect(NewTicket,SELECT_BY_TICKET,MODE_TRADES))
     {
      TransmitTradeRequest(TRADE_ACTION_DEAL,NewTicket, OrderType(),OrderSymbol(),OrderLots(),OrderOpenPrice(),0, OrderStopLoss(),OrderTakeProfit(),20,0,0, OrderComment());
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void messageChangedOrder(int ChangedTicket)
  {
   TellUser(("About to Modify Ticket "+ IntegerToString(ChangedTicket)));
   if(OrderSelect(ChangedTicket,SELECT_BY_TICKET,MODE_TRADES))
     {
      if(OrderType()==0 || OrderType()==1)          //Position, not Order
        {
         TransmitTradeRequest(TRADE_ACTION_SLTP,ChangedTicket,OrderType(),OrderSymbol(),OrderLots(),OrderOpenPrice(),0, OrderStopLoss(),OrderTakeProfit(),20,0,0, OrderComment());
        }
      else
        {
         TransmitTradeRequest(TRADE_ACTION_MODIFY,ChangedTicket,OrderType(),OrderSymbol(),OrderLots(),OrderOpenPrice(),OrderOpenPrice(), OrderStopLoss(),OrderTakeProfit(),20,0,0, OrderComment());

        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void messagePurgedOrder(int ClosedTicket)
  {
   TellUser(("About to Purge Ticket "+ IntegerToString(ClosedTicket)));
   if(OrderSelect(ClosedTicket,SELECT_BY_TICKET,MODE_HISTORY))
     {
      if(OrderType()==0 || OrderType()==1)         //Position, not Order
        {
         TransmitTradeRequest(TRADE_ACTION_DEAL,ClosedTicket, ((OrderType()%2)==0)?1:0,OrderSymbol(),OrderLots(),OrderOpenPrice(),0, OrderStopLoss(),OrderTakeProfit(),20,0,0, OrderComment());
        }
      else
        {
         TransmitTradeRequest(TRADE_ACTION_REMOVE,ClosedTicket, OrderType(),OrderSymbol(),OrderLots(),OrderOpenPrice(),0, OrderStopLoss(),OrderTakeProfit(),20,0,0, OrderComment());


        }


     }
  }





void TransmitTradeRequest(ENUM_TRADE_REQUEST_ACTIONS rAction,  int rOrderTicket, int   rType,   string rSymbol,   double rVolume, double  rPrice,  double rStoplimit=0, double   rSL=0, double  rTP=0,   int rDeviation=20,   int rPosition=0, int rPosition_by=0,   string rComment="")

  {
   int rOriginalAccount=AccountNumber() ;
   datetime rTimeLocal = TimeCurrent();
   datetime rTimeGMT = TimeGMT();
   double rEquity=AccountEquity();
   double rBalance=AccountBalance();


// JSON text to send
   string strJsonText = "TradeSyncRequest [{"+
                        "\"TR_ID\": \""+IntegerToString(rOriginalAccount) + "\","+
                        "\"T_LOCAL\": \""+ TimeToStr(rTimeLocal,TIME_DATE|TIME_SECONDS) +"\"," +
                        "\"T_GMT\": \""+ TimeToStr(rTimeGMT,TIME_DATE|TIME_SECONDS) +"\"," +
                        "\"ACC_EQ\": "+ DoubleToStr(rEquity,2) +"," +
                        "\"ACC_BAL\": "+ DoubleToStr(rBalance,2) +"," +
                        "\"ACTION\": \""+ EnumToString(rAction) +"\"," +
                        "\"ORD_NUM\": "+ IntegerToString(rOrderTicket) +"," +
                        "\"ORD_TYPE\": "+ IntegerToString(rType) +"," +
                        "\"SYMBOL\": \""+ rSymbol +"\"," +
                        "\"VOLUME\": "+ DoubleToStr(rVolume,2) +"," +
                        "\"PRICE\": "+ DoubleToStr(rPrice,5) +"," +
                        "\"STOP_LIMIT\": "+ DoubleToStr(rStoplimit,5) +"," +
                        "\"SL\": "+ DoubleToStr(rSL,5) +"," +
                        "\"TP\": "+ DoubleToStr(rTP,5) +"," +
                        "\"DEVIATION\": "+ IntegerToString(rDeviation) +"," +
                        "\"POS\": "+ IntegerToString(rPosition) +"," +
                        "\"POS_BY\": "+ IntegerToString(rPosition_by) +"," +
                        "";  //"\"rComment\": \""+ rComment +"\"}]";
   /*
   2020.01.23 21:32:28.592 TradeSync-MT4Transmitter1 EURUSD,H1: Just did WebRequest with:   {"rOriginalAccount": "525059","rTimeLocal": "2020.01.24 02:32:28","rTimeGMT": "2020.01.24 00:32:28","rEquity": 100000.51,"rBalance": 100000.51,"rAction": "TRADE_ACTION_REMOVE","rOrderTicket": 35964949,"rType": 3,"rSymbol": "EURUSD","rVolume": 0.28,"rPrice": 1.11801,"rStoplimit": 0.00000,"rSL": 0.00000,"rTP": 0.00000,"rDeviation": 20,"rPosition": 0,"rPosition_by": 0,
   "rComment": "cancelled"}
   */
// Text must be converted to a uchar array. Note that StringToCharArray() adds
// a nul character to the end of the array unless the size/length parameter
// is explicitly specified
   uchar jsonData[];
   StringToCharArray(strJsonText, jsonData, 0, StringLen(strJsonText));

// Use MT4's WebRequest() to send the JSON data to the server.
   char serverResult[];
   string serverHeaders;
   int res = WebRequest("POST", HubServerAddress, "", "", 500, jsonData, ArraySize(jsonData), serverResult, serverHeaders);
   TellUser(("Just did WebRequest with:   "+strJsonText));
   TellUser("While Transmitting Order# "+ IntegerToString(rOrderTicket)+", Web request result was "+  IntegerToString(res) + ", error: #" + IntegerToString((res == -1 ? GetLastError() : 0)));
  }

//+------------------------------------------------------------------+
//| Function to Print a message to the Console                       |
//+------------------------------------------------------------------+
void TellUser(string message, int ImportanceRank = 1)
  {
   bool WriteToLog = true;
   bool ShowOnScreen = true;
   if(WriteToLog)
     {
      WriteToLogFile(message);
     }
   if(ShowOnScreen)
     {
      Print(message);
     }
  }

//+-----------------------------------------------------------------+
// Function to Write a Log file
//+-----------------------------------------------------------------+
void WriteToLogFile(string LogMessage)
  {
   string LogFileName = "TradeSync\\TradeSyncTransmitterMT4"+ TimeToString(TimeLocal(),TIME_DATE)+".log";
   int fH = FileOpen(LogFileName,FILE_READ|FILE_WRITE|FILE_COMMON);
   FileSeek(fH,0,SEEK_END);
   string row = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS) +": "+ LogMessage + "\r\n";
   FileWriteString(fH, row, StringLen(row));
   FileClose(fH);
  }



// Known limitations and future development of ver 1.00.
// 1. Limitation of transmitting a maximum of 1000 positions.
// 2.
