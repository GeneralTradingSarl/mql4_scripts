//+------------------------------------------------------------------+
//|                                                   Buy Market.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property show_inputs

#include <stdlib.mqh>
#include <WinUser32.mqh>


extern double Lots=5.0; /* Strictly set amount of lots.*/
extern double StopLoss=25;  /* SL for an opened order.*/
extern double TakeProfit=25;  /* TP for an opened order.*/
extern int slippage=3;      // Slippage
extern bool UsePrint= true;   /* Set true to log trades.*/
extern bool TakePicture = true; /* set true to take snapshot of trade */
double PipValue=1;    // this variable is here to support 5-digit brokers
//+------------------------------------------------------------------+
//| Open buy order now                                               |
//+------------------------------------------------------------------+
int start()
  {
    if (Digits == 3 || Digits == 5) PipValue = 10;
    double SL = Ask - StopLoss*PipValue*Point;
    if (StopLoss == 0) SL = 0;
    double TP = Ask + TakeProfit*PipValue*Point;
    if (TakeProfit == 0) TP = 0;
    int ticket = -1;
    int   _width     = 1920;
    int   _height    = 1200;
    string SCREENSHOT_FILENAME = StringConcatenate(Symbol() , " " , "MIN" , Period() , " " , OrderTicket() , " " , TimeYear(TimeLocal()) , "-" , TimeMonth(TimeLocal()) , "-" , TimeDay(TimeLocal()) , "  "   , TimeHour(TimeLocal()) , "." , TimeMinute(TimeLocal()) , "." , TimeSeconds(TimeLocal()) , ".gif" );
   
    if (true)
    ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, slippage, 0, 0, "Buy Market script", 0, Blue);
    else
    ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, slippage, SL, TP, "Buy Market script", 0, Blue);
    if (ticket > -1)
			{
        if (true)
					{
						OrderSelect(ticket, SELECT_BY_TICKET);
						bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, 0, Blue);
						if (ret == true && UsePrint) OrderPrint();
						if (ret == true && TakePicture) WindowScreenShot(SCREENSHOT_FILENAME, _width, _height);  
						if (ret == false)
						Print("OrderModify() error - ", ErrorDescription(GetLastError()));
					}
          //Alert3();  
			}
    else
			{
        Print("OrderSend() error - ", ErrorDescription(GetLastError()));
			}
}
//+------------------------------------------------------------------+