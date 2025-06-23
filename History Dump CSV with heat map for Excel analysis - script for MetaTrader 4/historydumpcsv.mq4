//+------------------------------------------------------------------+
//|                                               HistoryDumpCSV.mq4 |
//|                                       Copyright 2016, Mark Flint |
//|                            https://www.mql5.com/en/users/flima02 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Mark Flint"
#property link      "https://www.mql5.com/en/users/flima02"
#property version   "1.03"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property description "This script creates a .CSV file of your order"
#property description "history so you can import it into Excel and analyse it."
#property description "It extracts date/time information in both"
#property description "MetaTrader format (_MT) and Excel format."
#property description "It supports aggregate analysis by calculating"
#property description "a 'Heat map' day and time slot."
#property description "The heat map default is 4 slots per hour i.e. 15 minutes."
#property description "The script will FTP the file to your specified"
#property description "FTP server, if you have defined one."
#property description "Records are sorted in Date/Time Closed order."
#property description "Times are server times. File is tab delimited."

/**************************************************************************************************************************************************************************************************************

A LITTLE DOCUMENTATION
======================
All the available MT4 trading attributes are collected from the available history and output to the CSV file.
In addition, some calculated values are output as well.  These are:

Sequence Number.   Used to keep the data in order or to re-sort it back into order.
ServerCloseTime.   This is Excel compatible version of the server datetime close value.
ServerExpiration.  This is Excel compatible version of the server datetime expiration value.
ServerOpenTime.    This is Excel compatible version of the server datetime open value.
NetProfit.         This is Profit less costs, i.e. NetProfit = Profit - Swap - Commission.
Type.              Transaction type, e.g. "OP_SELL", "OP_BUYSTOP" etc.  Better than a type number.
PriceMove.         Differential from OpenPrice to ClosePrice.
Points.            Points value for the trade, as per the broker and pair/Symbol.
Pips.              Points value for the trade, as per the broker and pair/Symbol.
PotentialWinPips.  Pips value of the TakeProfit level (if defined) to the Open level.  Typically positive values unless TP was moved to worse-than-entry level before the trade closed.
PotentialLossPips. Pips value of the StopLoss level (if defined) to the Open level.  Typically negative values unless SL was moved to better-than-entry level before the trade closed.
DurationMins.      The number of minutes from the open time to the close time.  Hint: There are 1440 minutes in a day.
HeatMapOpenDay.    The day number from 0 to 6 of the transaction open.  0=Sunday.  Allows you to drill down by day of the week for opening a trade.
HeatMapOpenSlot.   The slot number from 0 to 95 of the transaction open.  0=midnight, each increment represents 15 minutes. Allows you to drill down by the quarter hour for opening a trade.
HeatMapOpenHour.   The hour number from 0 to 23 of the transaction open.  0=midnight, each increment represents 1 hour. Allows you to drill down by the hour of the day for opening a trade.
HeatMapCloseDay.   The day number from 0 to 6 of the transaction close.  0=Sunday.  Allows you to drill down by day of the week for closing a trade.
HeatMapCloseSlot.  The slot number from 0 to 95 of the transaction close.  0=midnight, each increment represents 15 minutes. Allows you to drill down by the quarter hour for closing a trade.
HeatMapCloseHour.  The hour number from 0 to 23 of the transaction close.  0=midnight, each increment represents 1 hour. Allows you to drill down by the hour of the day for closing a trade.

Use the trading attributes and calculated values in your Excel pivot reports to help you better understand your trading profile and therefore learn ways to optimise it.
The data is appropriate for 4 and 5 digit brokers and uses the correct point and digits values for each pair being analysed.

Times are as per the broker's server, so take this into account when comparing data from brokers in different timezones.

The script is designed to be self contained and not ask for confirmation.  If you need to customise it then there is a section below that identifes 4 most likely customisations you may want:
  string reportfilename=StringConcatenate("HistoryDumpCSV_",AccountID,".CSV");  // the FileOpen has the FILE_COMMON flag meaning it is saved to the Commong/Files folder.
  uchar DELIM='\t';  // Delimiter is '\t' tab.  Other options are ';' semicolon and ',' comma.  The '\t' delimiter is the default for Excel CSV imports.
  int SLOTSPERHOUR=4;  // This divides the trading time into 15 minute slots for aggregating data.  2=30 minutes, 3=20 minutes, 1=1hour slots.
  bool SendFileByFTP=true; // If not needed, set this to false.  
Adjust these to suit your needs.

The script includes FTP functionality so that the report file generated is also sent by FTP to the configured directory on the remote FTP server.
In my case, this is a central NAS drive that holds all my reporting data for all my demo accounts.  This allows me to run multiple MT4 terminals on any PC but collect the report data from a single place.

**************************************************************************************************************************************************************************************************************/


//+------------------------------------------------------------------+
//| structure of history order entry                                 |
//+------------------------------------------------------------------+
struct Orders
  {
   int               SequenceNumber;
   double            Point; // not output. Specific for each trade symbol.
   int               Digits; // not output. Specific for each trade symbol.
   string            AccCompany;
   string            AccServer;
   string            AccName;
   int               AccNumber;
   string            ClosePrice; //double
   string            ServerCloseTime;
   datetime          ServerCloseTime_MT;
   string            Comment;
   string            Commission; //double
   string            ServerExpiration;
   datetime          ServerExpiration_MT;
   string            Lots; // double
   int               MagicNumber;
   string            OpenPrice; // double
   string            ServerOpenTime;
   datetime          ServerOpenTime_MT;
   string            NetProfit; //double // with swaps and commissions
   string            Profit; //double // without swaps and commissions
   string            StopLoss;//double
   string            Swap;//double
   string            Symbol;
   string            TakeProfit;//double
   long              Ticket; // ID
   string            Type; // OP_BUY, OP_SELLSTOP etc.
   string            PriceMove;
   string            Points;
   string            Pips;//double
   string            PotentialWinPips;//double
   string            PotentialLossPips;//double
   int               DurationMins;
   int               HeatMapOpenDay;
   int               HeatMapOpenSlot;
   int               HeatMapOpenHour;
   int               HeatMapCloseSlot;
   int               HeatMapCloseDay;
   int               HeatMapCloseHour;
  };
//+------------------------------------------------------------------+
//| Sorting structure                                                |
//+------------------------------------------------------------------+
struct TicketClose
  {
   int               TicketID;
   datetime          ServerCloseTime;
  };

// Globals
TicketClose ClosedTickets[]; // Array for sorting tickets into date/time closed sequence.
TicketClose TempClosedTicket;
string AccountID=IntegerToString(AccountNumber());
int filehandle;
bool NeedToOpenFile=true; // Set this to allow the process to open file and write the header.
int SequenceNum=0;
string msg="";
MqlDateTime ServerMqlDateTimeGMT;
long ServerTimeGMTOffsetSeconds=0;

/****************************************************************************/
// Below are the potential customisation options
/****************************************************************************/

string reportfilename=StringConcatenate("HistoryDumpCSV_",AccountID,".CSV");  // the FileOpen has the FILE_COMMON flag meaning it is saved to the Commong/Files folder.
uchar DELIM='\t';  // Delimiter is '\t' tab.  Other options are ';' semicolon and ',' comma.  The '\t' delimiter is the default for Excel CSV imports.
int SLOTSPERHOUR=4;  // This divides the trading time into 15 minute slots for aggregating data.  2=30 minutes, 3=20 minutes, 1=1hour slots.
bool SendFileByFTP=true; // If not needed, set this to false.

/****************************************************************************/

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   msg=StringConcatenate("HistoryDumpCSV: Save history data to ",reportfilename);
   MessageBox(msg);
   int i,j;
   bool FoundOrder,SavedDataOK;
   int total=OrdersHistoryTotal();
   Orders ThisOrder;
   
   ArrayResize(ClosedTickets,total);
   
   //ServerTimeGMTOffsetSeconds=TimeGMT()-TimeCurrent(); // negative if behind GMT, positive if ahead of GMT.

                                                       // Populate sorting array
   for(i=0; i<=total; i++)
     {
      FoundOrder=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(!FoundOrder) break;
      ClosedTickets[i].TicketID=OrderTicket();
      ClosedTickets[i].ServerCloseTime=OrderCloseTime();
     };
//Bubble sort array
   for(i=0; i<total-1; i++)
     {
      for(j=i+1; j<total; j++)
        {
         if(ClosedTickets[j].ServerCloseTime<ClosedTickets[i].ServerCloseTime)
           {
            // swap the entries
            TempClosedTicket.ServerCloseTime= ClosedTickets[i].ServerCloseTime;
            TempClosedTicket.TicketID       = ClosedTickets[i].TicketID;

            ClosedTickets[i].ServerCloseTime = ClosedTickets[j].ServerCloseTime;
            ClosedTickets[i].TicketID        = ClosedTickets[j].TicketID;

            ClosedTickets[j].ServerCloseTime = TempClosedTicket.ServerCloseTime;
            ClosedTickets[j].TicketID        = TempClosedTicket.TicketID;
           }
        }

     }

   for(i=0; i<total; i++)
     {
      //FoundOrder=OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      FoundOrder=OrderSelect(ClosedTickets[i].TicketID,SELECT_BY_TICKET,MODE_HISTORY);
      FillOrderData(ThisOrder);
      if(!FoundOrder || ThisOrder.Ticket<1) continue;
      SavedDataOK=SaveData(ThisOrder);
      if(!SavedDataOK) break; // error, exit.
     };
   if(!NeedToOpenFile) // file was openned, so now close it
     {
      FileFlush(filehandle); // make sure it is flushed to disk before we exit
      FileClose(filehandle);
      if(SendFileByFTP)
        {
         if(!SendFTP(reportfilename))
           {
            PlaySound("alert.wav");
            msg=StringConcatenate("HistoryDumpCSV: ERROR: FTP Failed to send file ",reportfilename);
            Print(msg); // log error in Journal
            MessageBox(msg); // interrupt user
            return;
           }
         else
           {
            msg="HistoryDumpCSV: File generated and successfully sent by FTP.";
            Print(msg); // log to Journal
            PlaySound("ok.wav"); // file generated and successfully sent by FTP.  OK!
           }
        }
      else
        {
         msg="HistoryDumpCSV: File generated successfully.  Not sent by FTP as per settings.";
         Print(msg); // log to Journal
         PlaySound("ok.wav"); // file generated successfully. FTP not wanted. OK!
        }
     }
   else
     {
      PlaySound("alert.wav");
      msg="HistoryDumpCSV: File open error / No file generated.";
      Print(msg); // log to Journal
      MessageBox(msg); // interrupt user
     }
   return;
  }
//+------------------------------------------------------------------+
//|  Fill Orders structure object                                    |
//+------------------------------------------------------------------+
void FillOrderData(Orders &ThisOrder)
  {
// Use immediately after OrderSelect, OrderSend
   ThisOrder.SequenceNumber=++SequenceNum;
   ThisOrder.Point=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   ThisOrder.Digits=int(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
   ThisOrder.AccCompany=CleanString(AccountCompany());
   ThisOrder.AccServer=CleanString(AccountServer());
   ThisOrder.AccName=CleanString(AccountName());
   ThisOrder.AccNumber=AccountNumber();
   ThisOrder.ClosePrice=DoubleToString(OrderClosePrice(),ThisOrder.Digits);
   ThisOrder.ServerCloseTime=CleanDateTime(OrderCloseTime());
   ThisOrder.ServerCloseTime_MT=OrderCloseTime(); // native MT
   ThisOrder.Comment=CleanString(OrderComment());
   ThisOrder.Commission=DoubleToString(OrderCommission(),2);
   ThisOrder.ServerExpiration=CleanDateTime(OrderExpiration());
   ThisOrder.ServerExpiration_MT=OrderExpiration(); // native MT
   ThisOrder.Lots=DoubleToString(OrderLots(),2);
   ThisOrder.MagicNumber=OrderMagicNumber();
   ThisOrder.OpenPrice=DoubleToString(OrderOpenPrice(),ThisOrder.Digits);
   ThisOrder.ServerOpenTime=CleanDateTime(OrderOpenTime());
   ThisOrder.ServerOpenTime_MT=OrderOpenTime();
   ThisOrder.NetProfit=DoubleToString(OrderProfit()+OrderSwap()+OrderCommission(),3); // profit minus swaps and commissions
   ThisOrder.Profit=DoubleToString(OrderProfit(),3); // without swaps and commissions
   ThisOrder.StopLoss=DoubleToString(OrderStopLoss(),ThisOrder.Digits);
   ThisOrder.Swap=DoubleToString(OrderSwap(),ThisOrder.Digits);
   ThisOrder.Symbol=OrderSymbol();
   ThisOrder.TakeProfit=DoubleToString(OrderTakeProfit(),ThisOrder.Digits);
   ThisOrder.Ticket=OrderTicket(); // ID
   ThisOrder.Type=OrderTypeName(OrderType()); // string name from int for OP_BUY, OP_SELLSTOP etc.
   ThisOrder.PriceMove=DoubleToString(NormalizeDouble(OrderClosePrice()-OrderOpenPrice(),ThisOrder.Digits),ThisOrder.Digits);
   ThisOrder.Points="";            // reset
   ThisOrder.Pips="";              // reset
   ThisOrder.PotentialWinPips="";  // reset
   ThisOrder.PotentialLossPips=""; // reset
   if(ThisOrder.Type=="OP_BUY")
   {
     ThisOrder.Points=DoubleToString(NormalizeDouble(PriceMoveToPoints(OrderClosePrice()-OrderOpenPrice()),ThisOrder.Digits),ThisOrder.Digits);
     ThisOrder.Pips=DoubleToString(NormalizeDouble(PointsToPips(PriceMoveToPoints(OrderClosePrice()-OrderOpenPrice())),ThisOrder.Digits),ThisOrder.Digits);
     if(OrderTakeProfit()>0) ThisOrder.PotentialWinPips=DoubleToStr(PointsToPips(PriceMoveToPoints(OrderTakeProfit()-OrderOpenPrice())),1);  // yield positive unless TP worse than entry
     if(OrderStopLoss()>0) ThisOrder.PotentialLossPips=DoubleToStr(PointsToPips(PriceMoveToPoints(OrderStopLoss()-OrderOpenPrice())),1);     // yield negative unless SL better than entry
   }
   if(ThisOrder.Type=="OP_SELL") 
   {
     ThisOrder.Points=DoubleToString(NormalizeDouble(PriceMoveToPoints(OrderOpenPrice()-OrderClosePrice()),ThisOrder.Digits),ThisOrder.Digits);
     ThisOrder.Pips=DoubleToString(NormalizeDouble(PointsToPips(PriceMoveToPoints(OrderOpenPrice()-OrderClosePrice())),ThisOrder.Digits),ThisOrder.Digits);
     if(OrderTakeProfit()>0) ThisOrder.PotentialWinPips=DoubleToStr(PointsToPips(PriceMoveToPoints(OrderOpenPrice()-OrderTakeProfit())),1); // yield positive unless TP worse than entry
     if(OrderStopLoss()>0) ThisOrder.PotentialLossPips=DoubleToStr(PointsToPips(PriceMoveToPoints(OrderOpenPrice()-OrderStopLoss())),1);    // yield negative unless SL better than entry
   }
   ThisOrder.DurationMins=int((double(OrderCloseTime())-double(OrderOpenTime()))/60);
   ThisOrder.HeatMapOpenDay=(SlotDayFromServerTime(OrderOpenTime()));
   ThisOrder.HeatMapOpenSlot=(SlotNumFromServerTime(OrderOpenTime()));
   ThisOrder.HeatMapOpenHour=(TimeHour(OrderOpenTime()));
   ThisOrder.HeatMapCloseDay=(SlotDayFromServerTime(OrderCloseTime()));
   ThisOrder.HeatMapCloseSlot=(SlotNumFromServerTime(OrderCloseTime()));
   ThisOrder.HeatMapCloseHour=(TimeHour(OrderCloseTime()));
   return;
  }
//+------------------------------------------------------------------+
bool SaveData(Orders &ThisOrder)
  {
//Save it to disk...
   string CleanComment;

   if(NeedToOpenFile)
     {
      ResetLastError();
      // filehandle=FileOpen(reportfilename,FILE_COMMON|FILE_WRITE|FILE_CSV); // overwrite previous file if present.  If written to the COMMON files directory, the SendFTP function will not work.
      filehandle=FileOpen(reportfilename,FILE_WRITE|FILE_CSV,DELIM); // overwrite previous file if present.  Send to local files directory.  SendFTP should work.
      if(filehandle==INVALID_HANDLE || filehandle<=0) return(false); // we can't open the file so exit the try.
     }
   if(filehandle!=INVALID_HANDLE)
     {
      if(NeedToOpenFile) // write a header line first.
        {
         FileWrite(filehandle,
                   "AccCompany",
                   "AccServer",
                   "AccName",
                   "AccNumber",
                   "SeqNum",
                   "ClosePrice",
                   "ServerCloseTime",
                   "ServerCloseTime_MT",
                   "Comment",
                   "Commission",
                   "ServerExpiration",
                   "ServerExpiration_MT",
                   "Lots",
                   "MagicNumber",
                   "OpenPrice",
                   "ServerOpenTime",
                   "ServerOpenTime_MT",
                   "NetProfit",
                   "Profit",
                   "StopLoss",
                   "Swap",
                   "Symbol",
                   "TakeProfit",
                   "Ticket",
                   "Type",
                   "PriceMove",
                   "Points",
                   "Pips",
                   "PotentialWinPips",
                   "PotentialLossPips",
                   "DurationMins",
                   "HeatMapOpenDay0to6",
                   "HeatMapOpenSlot",
                   "HeatMapOpenHour",
                   "HeatMapCloseDay0to6",
                   "HeatMapCloseSlot",
                   "HeatMapCloseHour" );
         NeedToOpenFile=false; // Dont need to open it or write header line again
        }

      FileWrite(filehandle,
                ThisOrder.AccCompany,
                ThisOrder.AccServer,
                ThisOrder.AccName,
                ThisOrder.AccNumber,
                ThisOrder.SequenceNumber,
                ThisOrder.ClosePrice,
                ThisOrder.ServerCloseTime,
                ThisOrder.ServerCloseTime_MT,
                ThisOrder.Comment,
                ThisOrder.Commission,
                ThisOrder.ServerExpiration,
                ThisOrder.ServerExpiration_MT,
                ThisOrder.Lots,
                ThisOrder.MagicNumber,
                ThisOrder.OpenPrice,
                ThisOrder.ServerOpenTime,
                ThisOrder.ServerOpenTime_MT,
                ThisOrder.NetProfit,
                ThisOrder.Profit,
                ThisOrder.StopLoss,
                ThisOrder.Swap,
                ThisOrder.Symbol,
                ThisOrder.TakeProfit,
                ThisOrder.Ticket,
                ThisOrder.Type,
                ThisOrder.PriceMove,
                ThisOrder.Points,
                ThisOrder.Pips,
                ThisOrder.PotentialWinPips,
                ThisOrder.PotentialLossPips,
                ThisOrder.DurationMins,
                ThisOrder.HeatMapOpenDay,
                ThisOrder.HeatMapOpenSlot,
                ThisOrder.HeatMapOpenHour,
                ThisOrder.HeatMapCloseDay,
                ThisOrder.HeatMapCloseSlot,
                ThisOrder.HeatMapCloseHour  );
      return(true);
     }
   else
     {
      MessageBox(StringConcatenate("Operation FileOpen failed for ",reportfilename,", error ",GetLastError()));
      return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Make string safe for .CSV files using comma, tab or semi-colon as seperator
//+------------------------------------------------------------------+
string CleanString(string s)
  {
   string temp=s;
   StringReplace(temp,";","|"); // replace any ';' with '|' to avoid the field delimiter in the .csv file
   StringReplace(temp,",","|"); // replace any ',' with '|' to avoid the field delimiter in the .csv file
   StringReplace(temp,"\t"," "); // replace any {tab} with {space} to avoid the field delimiter in the .csv file
   return(temp);
  }
//+------------------------------------------------------------------+
//| Text name of order type
//+------------------------------------------------------------------+
string OrderTypeName(int TradeOperation)
  {
   switch(TradeOperation)
     {
      case 0 : return("OP_BUY");
      case 1 : return("OP_SELL");
      case 2 : return("OP_BUYLIMIT");
      case 3 : return("OP_SELLLIMIT");
      case 4 : return("OP_BUYSTOP");
      case 5 : return("OP_SELLSTOP");
      default : return("other");
     }
   return("unknown?");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CleanDateTime(datetime d)
  {
   return(StringConcatenate(CleanDate(d)," ",CleanTime(d)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CleanDate(datetime d)
  {
   string temp;

   temp=StringConcatenate("00",IntegerToString(TimeYear(d)));
   string yyyy=StringSubstr(temp,(StringLen(temp)-4),4);

   temp=StringConcatenate("00",IntegerToString(TimeMonth(d)));
   string mm=StringSubstr(temp,(StringLen(temp)-2),2);

   temp=StringConcatenate("00",IntegerToString(TimeDay(d)));
   string dd=StringSubstr(temp,(StringLen(temp)-2),2);

   return(StringConcatenate(dd,"-",mm,"-",yyyy));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CleanTime(datetime d)
  {
   string temp;

   temp=StringConcatenate("00",IntegerToString(TimeHour(d)));
   string hh=StringSubstr(temp,(StringLen(temp)-2),2);

   temp=StringConcatenate("00",IntegerToString(TimeMinute(d)));
   string mi=StringSubstr(temp,(StringLen(temp)-2),2);

   temp=StringConcatenate("00",IntegerToString(TimeSeconds(d)));
   string ss=StringSubstr(temp,(StringLen(temp)-2),2);

   return(StringConcatenate(hh,":",mi,":",ss));
  }
//+------------------------------------------------------------------+
//| Translate a price move (Buy-Sell) into points for the currency
//+------------------------------------------------------------------+
double PriceMoveToPoints(double pricemove)
  {
   double TradePoint=Point;
   int TradeDigits=Digits;
   if(OrderTicket()>0) // we have a current ticket open to examine
   {
     TradePoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
     TradeDigits=int(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
   }

   if(TradeDigits==3 || TradeDigits==5) return(pricemove/TradePoint); // already in points for 3/5 digit brokers
   return((pricemove/TradePoint)*10); // convert pips to points (pip fractions) for 2/4 digit brokers.
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointsToPips(double points)
  {
   double TradePoint=Point;
   int TradeDigits=Digits;
   if(OrderTicket()>0) // we have a current ticket open to examine
   {
     TradePoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
     TradeDigits=int(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
   }

   if(TradeDigits==3 || TradeDigits==5) return(points/10); // convert points (pip fractions) to pips for 3/5 digit brokers
   return(points); // already in pips for 2/4 digit brokers
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PipsToPoints(double pips)
  {
   double TradePoint=Point;
   int TradeDigits=Digits;
   if(OrderTicket()>0) // we have a current ticket open to examine
   {
     TradePoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
     TradeDigits=int(SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS));
   }
   if(TradeDigits==3 || TradeDigits==5) return(pips*10); // convert to points (pip fractions) for 3/5 digit brokers
   return(pips); // value is already in points for 2/4 digit brokers.
  }
//+------------------------------------------------------------------+
//| Slot Day from GMT
//+------------------------------------------------------------------+
int SlotNumFromServerTime(datetime T=0)
  {
   if(T==0) T=TimeCurrent(); // last known server time
   int th,m;
   th=TimeHour(T+ServerTimeGMTOffsetSeconds); // hour number 0-23 on the server in GMT
   m=(int)MathFloor(TimeMinute(T+ServerTimeGMTOffsetSeconds)/(60/SLOTSPERHOUR));  // should yield 0-3 for 15 minute slots when SLOTSPERHOUR=4
   return((th*SLOTSPERHOUR)+m); // slot number of current GMT
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SlotDayFromServerTime(datetime T=0)
  {
   if(T==0) T=TimeCurrent(); // last known server time
   return(TimeDayOfWeek(T+ServerTimeGMTOffsetSeconds)); // 0=Sunday, 1=Monday etc. 5=Friday, 6=Saturday
  }
//+------------------------------------------------------------------+
