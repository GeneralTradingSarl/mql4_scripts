//+------------------------------------------------------------------+
//|                                                   JMBUYERv2.mq4  |
//|                       Copyright © 2008, PRMQuotes Software Corp. |
//|                                           Jedimedic77@gmail.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, PRMQuotes Software Corp."

#include <stdlib.mqh>
#include <WinUser32.mqh>

//+----------------------------------------------------------------------+
//| To modify Lotsize of script change value listed here, right now      |
//| its set to 1.0 change that value if you desire different lotsize     |
//| I have found that it is important to keep the decimal in place,      |
//| but really dont know why yet, but fractional lots work too (ex...    |
//| 0.1, 0.3, 1.12), you get the picture.                                |
//| AGAIN DONT FORGET TO SAVE AND COMPILE AFTER MAKING ANY MODIFICATIONS |
//+----------------------------------------------------------------------+
extern double Lots = 0.10; // change this number to change the lotsize
extern double stoploss = 100;  // change this number to change the stoploss
extern double takeprofit = 100; // change this number to change the takeprofit

//+---Don't forget to save and compile after changing the Lotsize--------+

//+------------------------------------------------------------------+
//|  Each of the following lines produces an individual order        |
//|  3 lines produces 3 orders, to increase or decrease the number   |
//|  of individual orders either add, or take away identical lines   |
//|  within the parenthesis. Again dont forget to save and compile   |
//|  time you modify the code.                                       |
//+------------------------------------------------------------------+
int start()
  {
OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-stoploss*Point,Bid+takeprofit*Point,"JMBUYER",0,0,CLR_NONE);
OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-stoploss*Point,Bid+takeprofit*Point,"JMBUYER",0,0,CLR_NONE);
OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-stoploss*Point,Bid+takeprofit*Point,"JMBUYER",0,0,CLR_NONE);
OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-stoploss*Point,Bid+takeprofit*Point,"JMBUYER",0,0,CLR_NONE);
OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Bid-stoploss*Point,Bid+takeprofit*Point,"JMBUYER",0,0,CLR_NONE);

}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+