//+------------------------------------------------------------------+
//|                         _HPCS_CloseBBCrossOver_MT4_EA_V01_WE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
struct OrderDetail
  {
   datetime          OrderTimeOpen;
   datetime          OrderUpdatedTime;
  };
OrderDetail OD[1];

input int ii_Period = 20;
input double id_Deviation = 2;
input int ii_BandsShift = 0;

input double id_StopLoss = 10;   // Stoploss in Pips:
input double id_TakeProfit = 10;  // TakeProfit in Pips:
input double id_Lots = 0.01;     // Lots:
input int ii_Slippage = 10;   // Slippage:
input int ii_MagicNumber = 1212;   // Magic Number:
input int ii_Closure = 20;     // Closure in % :

datetime gdt_CurrentTime = Time[1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---


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
//---
   double ld_BuySignal = iCustom(_Symbol,PERIOD_CURRENT,"_HPCS_CloseBBCrossOver_MT4_Indi_V01_WE",ii_Period,id_Deviation,ii_BandsShift,0,0);
   double ld_SellSignal = iCustom(_Symbol,PERIOD_CURRENT,"_HPCS_CloseBBCrossOver_MT4_Indi_V01_WE",ii_Period,id_Deviation,ii_BandsShift,1,0);

   if(ld_BuySignal != EMPTY_VALUE)
     {
      if(gdt_CurrentTime != Time[0])
        {
         int li_TicketBuy = PlaceMarketOrder_Generic(OP_BUY,id_Lots,NULL,id_StopLoss,id_TakeProfit,ii_Slippage,ii_MagicNumber);
         if(li_TicketBuy < 0)
           {
            Print("Order not Placed With error: ",GetLastError());
           }
         ArrayResize(OD,ArraySize(OD)+1);
         if(OrderSelect(li_TicketBuy,SELECT_BY_TICKET))
           {
            OD[ArraySize(OD)-1].OrderTimeOpen = OrderOpenTime();
            OD[ArraySize(OD)-1].OrderUpdatedTime = OrderOpenTime();
           }
         gdt_CurrentTime = Time[0];
        }
     }

   if(ld_SellSignal != EMPTY_VALUE)
     {
      if(gdt_CurrentTime != Time[0])
        {
         int li_TicketSell = PlaceMarketOrder_Generic(OP_SELL,id_Lots,NULL,id_StopLoss,id_TakeProfit,ii_Slippage,ii_MagicNumber);
         if(li_TicketSell < 0)
           {
            Print("Order not Placed With error: ",GetLastError());
           }
         ArrayResize(OD,ArraySize(OD)+1);
         if(OrderSelect(li_TicketSell,SELECT_BY_TICKET))
           {
            OD[ArraySize(OD)-1].OrderTimeOpen = OrderOpenTime();
            OD[ArraySize(OD)-1].OrderUpdatedTime = OrderOpenTime();
           }
         gdt_CurrentTime = Time[0];
        }
     }
   CloseOrder(ii_MagicNumber,ii_Closure);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrder(int MagicNumber, int CloseLots)
  {
   int li_Total = OrdersTotal();
   double ld_UpdateLots = id_Lots - ((id_Lots * CloseLots)/100);
   double ld_AllowedLot = func_EnsureLotWithinAllowedLimits(ld_UpdateLots);


   for(int i = li_Total  ; i>0 ; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS) == True)
        {
         if(MagicNumber == OrderMagicNumber() && Symbol() == OrderSymbol())
           {

            for(int j=0; j<ArraySize(OD); j++)
              {
               if(OD[j].OrderTimeOpen == OrderOpenTime())
                 {
                  if(TimeCurrent() >= OD[j].OrderUpdatedTime + 30 && OrderCloseTime() == 0)
                    {
                     if(!OrderClose(OrderTicket(),ld_AllowedLot,OrderClosePrice(),ii_Slippage))
                       {
                        Print("Order not Closed With Error: ",GetLastError());
                       }
                     else
                        OD[j].OrderUpdatedTime = TimeCurrent();
                    }
                 }
              }
           }
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PlaceMarketOrder_Generic(ENUM_ORDER_TYPE _OP,
                             double          _Lots,
                             string          _namePair       = NULL,
                             double          _SLinPips       = 0,
                             double          _TPinPips       = 0,
                             int             _SlippageInPips = 10,
                             int             _MagicNumber    = 0,
                             string          _Comment        = "MO_HPCS",
                             bool            _flagDEBUGMsg   = false)
  {
//
   int rtrn_Ticket = -1,
       __Digits    = (int)MarketInfo(_namePair, MODE_DIGITS);
   double _priceOpen = 0,
          _priceSL   = 0,
          _priceTP   = 0,
          _priceAsk  = MarketInfo(_namePair, MODE_ASK),
          _priceBid  = MarketInfo(_namePair, MODE_BID),
          _Points    = MarketInfo(_namePair, MODE_POINT),
          _StopLevel = MarketInfo(_namePair, MODE_STOPLEVEL);
   color _colorArrow = clrBlack;

   int _factor  = 1;
   if(Digits == 5 || Digits == 3)
     {  _factor = 10; }

//

   if(_OP > 1)
     {
      Alert("Wrong Market Order type");
     }
   else
     {
      //
      if(_OP == OP_BUY)
        {
         _priceOpen  = _priceAsk;
         _colorArrow = clrBlue;
        }
      else
         if(_OP == OP_SELL)
           {
            _priceOpen  = _priceBid;
            _colorArrow = clrRed;
           }//



      if(_SLinPips != 0)
        {
         if(_OP == OP_BUY)
           {
            _priceSL = _priceAsk - (_SLinPips * _Points * _factor);
            if((_priceBid - _priceSL) >= (_StopLevel * _Points))
              {
               // Refer: book.mql4.com/appendix/limits
              }
            else
              {
               _priceSL = _priceBid - (_StopLevel * _Points);
              }
           }
         else
            if(_OP == OP_SELL)
              {
               _priceSL = _priceBid + (_SLinPips * _Points * _factor);
               if((_priceSL - _priceAsk) >= (_StopLevel * _Points))
                 {
                  // Refer: book.mql4.com/appendix/limits
                 }
               else
                 {
                  _priceSL = _priceAsk + (_StopLevel * _Points);
                 }
              }
        }
      if(_TPinPips != 0)
        {
         if(_OP == OP_BUY)
           {
            _priceTP = _priceAsk + (_TPinPips * _Points * _factor);
            if((_priceTP - _priceBid) >= (_StopLevel * _Points))
              {
               // Refer: book.mql4.com/appendix/limits
              }
            else
              {
               _priceTP = _priceBid + (_StopLevel * _Points);
              }
           }
         else
            if(_OP == OP_SELL)
              {
               _priceTP = _priceBid - (_TPinPips * _Points * _factor);
               if((_priceAsk - _priceTP) >= (_StopLevel * _Points))
                 {
                  // Refer: book.mql4.com/appendix/limits
                 }
               else
                 {
                  _priceTP = _priceAsk - (_StopLevel * _Points);
                 }
              }
        }

      // normalize all price values to digits
      _priceOpen = NormalizeDouble(_priceOpen, __Digits);
      _priceSL   = NormalizeDouble(_priceSL, __Digits);
      _priceTP   = NormalizeDouble(_priceTP, __Digits);

      // place market order
      rtrn_Ticket = OrderSend(_namePair, _OP, _Lots, _priceOpen, _SlippageInPips, _priceSL, _priceTP, _Comment, _MagicNumber, 0, _colorArrow);
      if(_flagDEBUGMsg == true)
        {
         Print("[DE-BUG] " + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + " Ticket = " + IntegerToString(rtrn_Ticket));
        }
      if(rtrn_Ticket == -1)
        {
         int _Error = GetLastError();                                   //StringToInteger( ErrorDescription()) ;
         if(_flagDEBUGMsg == true)
           {
            Print("Order Place Failed:", _Error);
           }
         //
         if((_Error == 129) || (_Error == 135) || (_Error == 136) || (_Error == 138) || (_Error == 146))
           {
            // Overcomable errors: 129(invalid price), 135(price changed), 136(no-quotes), 138(re-quotes), 146(busy trade subsystem)
            //if( _Error == 129 ) Alert("Invalid price. Retrying..");
            RefreshRates();                     // Update data
            rtrn_Ticket = PlaceMarketOrder_Generic(_OP, _Lots, _namePair,  _priceSL, _priceTP, _SlippageInPips, _MagicNumber, _Comment, _flagDEBUGMsg);
           }
        }
     }
//
   return(rtrn_Ticket);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double func_EnsureLotWithinAllowedLimits(double& chng_Lot,
      string _namePair = NULL)
  {
//
// Error/Information codes, printed in Experts log by this function:
// I1( chng_Lot => nw_Lot, _LotMinStp ): [INFO]  Changed given chng_Lot to nw_Lot so as to ensure it follows broker's minimum lot-step, _LotMinStp
// I2( chng_Lot => _LotMax )           : [INFO]  Given chng_Lot > maximum allowed _LotMax. It is reset to the _LotMax to place order successfully.
// E1( chng_Lot < _LotMin )            : [ERROR] Given chng_Lot < minimum allowed _LotMin. No order must be placed using this lot.
//
   string lcl_MsgCode = NULL;
//
// get minimum, maximum and step-size permitted for a lot
   double lcl_MinPermittedLot = MarketInfo(_namePair, MODE_MINLOT),
          lcl_MaxPermittedLot = MarketInfo(_namePair, MODE_MAXLOT),
          lcl_MinPermittedLotStep = MarketInfo(_namePair, MODE_LOTSTEP);
//
   int _LotDigits = 4;
   double micro_lot = 0.01,mini_lot =0.1,lot1=1;

   if(chng_Lot < lcl_MinPermittedLot)
     {
      // lot must not be below the minimum allowed limit
      // Print("[INFO]: Requested Lot(",DoubleToString(chng_Lot,NUM_OF_LOT_DIGITS),") < Minimum allowed lot(",DoubleToString(lcl_MinPermittedLot,NUM_OF_LOT_DIGITS),")");
      Print("[INFO]: Updated requested Lot to the Minimum allowed lot to place order successfully");
      chng_Lot = lcl_MinPermittedLot;
     }
   else
      if(chng_Lot > lcl_MaxPermittedLot)
        {
         // lot must not be above the maximum allowed limit
         // Print("[INFO]: Requested Lot(",DoubleToString(chng_Lot,NUM_OF_LOT_DIGITS),") > Maximum allowed lot(",DoubleToString(lcl_MaxPermittedLot,NUM_OF_LOT_DIGITS),")");
         Print("[INFO]: Updated requested Lot to the Maximum allowed lot to place order successfully");
         chng_Lot = lcl_MaxPermittedLot;
        }
//
// normalize the lot
   double _LotMicro = 0.01, // micro lots
          _LotMini  = 0.10, // mini lots
          _LotNrml  = 1.00;
//
   if(lcl_MinPermittedLot == _LotMicro)
      _LotDigits = 2;
   else
      if(lcl_MinPermittedLot == _LotMini)
         _LotDigits = 1;
      else
         if(lcl_MinPermittedLot == _LotNrml)
            _LotDigits = 0;
//
   chng_Lot = NormalizeDouble(chng_Lot, _LotDigits);

   return chng_Lot;
  }
//+------------------------------------------------------------------+
