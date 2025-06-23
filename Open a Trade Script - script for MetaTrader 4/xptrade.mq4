//*------------------------------------------------------------------*
//|                                                      xpTrade.mq4 |
//|                                         Developed by Coders Guru |
//|                                            http://www.xpworx.com |
//*------------------------------------------------------------------*
#property copyright "xpworx"
#property link      "http://www.xpworx.com"
#property description "Manual Trade Script"
#property version     "1.00"
//*------------------------------------------------------------------*
//Last Modified: 2015.04.22
//*------------------------------------------------------------------*
#property show_inputs
//*------------------------------------------------------------------*
enum TT {BUY, SELL, BUYLIMIT, SELLLIMIT, BUYSTOP, SELLSTOP};
enum YN {No,Yes};
//*------------------------------------------------------------------*
extern      TT          Type                       = BUY;
extern      double      Price                      = 0; 
extern      int         Distance                   = 10; 
extern      double      LotSize                    = 0.1; 
extern      int         StopLoss                   = 10; 
extern      int         TakeProfit                 = 10; 
extern      int         MagicNumber                = 1234;
extern      YN          ECN_Broker                 = Yes;
extern      int         Slippage                   = 5;
//*------------------------------------------------------------------*
int init()
{
   return(0);
}
//*------------------------------------------------------------------*
int OnStart()
{      
   int tick = -1;
   if(Type<=OP_SELL)
   {
      tick = OpenInstant(ECN_Broker, Symbol(), Type, LotSize, Slippage, StopLoss, TakeProfit, MagicNumber);
   }
   else
   {
      tick = OpenPending(Symbol(), Price, Type, LotSize, Distance, Slippage, StopLoss, TakeProfit, MagicNumber);
   }
   
   if(tick>-1) Alert("Trade placed successfully!");
   else Alert("Placing trade failed!");
   return(0);
}
//*------------------------------------------------------------------*


//*------------------------------------------------------------------*
#include <stdlib.mqh>
//*------------------------------------------------------------------*
int   TriesCount  = 5; 
int   _Pause      = 500;
//*------------------------------------------------------------------*
void GetTradeSymbol(string& TradeSymbol) 
{ 
   if(TradeSymbol=="") TradeSymbol=Symbol(); 
}
//*------------------------------------------------------------------*
double GetPoint(string TradeSymbol = "")
{
   GetTradeSymbol(TradeSymbol);
   if(StringFind(TradeSymbol,"XAU")>-1 || StringFind(TradeSymbol,"xau")>-1) return(0.1);  //Gold
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==2 || MarketInfo(TradeSymbol,MODE_DIGITS)==3) return(0.01);
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==4 || MarketInfo(TradeSymbol,MODE_DIGITS)==5) return(0.0001);
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==0) return(1); //Indexes
   return(0.0001);
}
//*------------------------------------------------------------------*
double nd(double value, string TradeSymbol="")
{
   GetTradeSymbol(TradeSymbol);
   return(NormalizeDouble(value,(int)MarketInfo(TradeSymbol,MODE_DIGITS)));
}
//*------------------------------------------------------------------*
bool isDouble(double value)
{
   if(value==0) return(true);
   else return(value-MathFloor(value)>0);      
}
//*------------------------------------------------------------------*
double GetSpread(string TradeSymbol = "")
{
   GetTradeSymbol(TradeSymbol);
   double spread = MathCeil(MarketInfo(TradeSymbol,MODE_SPREAD));
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==5 || MarketInfo(TradeSymbol,MODE_DIGITS)==3) return(spread/10);
   return(spread);
}
//*------------------------------------------------------------------*
int MinimumLimit(string TradeSymbol="")
{
   GetTradeSymbol(TradeSymbol);
   int minimum_sl = (int)MarketInfo(TradeSymbol,MODE_STOPLEVEL);
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==5 || MarketInfo(TradeSymbol,MODE_DIGITS)==3) minimum_sl = minimum_sl/10;
   minimum_sl = minimum_sl + (int)GetSpread();
   return(minimum_sl);
}
//*------------------------------------------------------------------*
int NearestPending(string TradeSymbol = "")
{
   GetTradeSymbol(TradeSymbol);
   int near = (int) MarketInfo(TradeSymbol,MODE_STOPLEVEL);
   if(MarketInfo(TradeSymbol,MODE_DIGITS)==5 || MarketInfo(TradeSymbol,MODE_DIGITS)==3) near = near/10;
   return(near);
}
//*------------------------------------------------------------------*
double GetTakeProfit(int TradeType, double _TakeProfit, double _OpenPrice=0, string TradeSymbol="")
{
   if(_TakeProfit==0) return(0);
   
   GetTradeSymbol(TradeSymbol);
   
   if(isDouble(_TakeProfit)) return(nd(_TakeProfit,TradeSymbol));
   
   double _point = GetPoint(TradeSymbol);  
   double TP=0;
   
   switch(TradeType)
   {
      case OP_BUY:
      {
         TP = nd(MarketInfo(TradeSymbol,MODE_ASK)+_TakeProfit*_point,TradeSymbol);
         break;
      }
      case OP_SELL:
      {
         TP = nd(MarketInfo(TradeSymbol,MODE_BID)-_TakeProfit*_point,TradeSymbol);
         break;
      }
      case OP_BUYLIMIT:
      {
         if(_OpenPrice==0) TP = nd(MarketInfo(TradeSymbol,MODE_ASK)+_TakeProfit*_point,TradeSymbol);
         else TP = nd(_OpenPrice+_TakeProfit*_point,TradeSymbol);
         break;
      }
      case OP_BUYSTOP:
      {
         if(_OpenPrice==0) TP = nd(MarketInfo(TradeSymbol,MODE_ASK)+_TakeProfit*_point,TradeSymbol);
         else TP = nd(_OpenPrice+_TakeProfit*_point,TradeSymbol);
         break;
      }
      case OP_SELLLIMIT:
      {
         if(_OpenPrice==0) TP = nd(MarketInfo(TradeSymbol,MODE_BID)-_TakeProfit*_point,TradeSymbol);
         else TP = nd(_OpenPrice-_TakeProfit*_point,TradeSymbol);
         break;
      }
      case OP_SELLSTOP:
      {
         if(_OpenPrice==0) TP = nd(MarketInfo(TradeSymbol,MODE_BID)-_TakeProfit*_point,TradeSymbol);
         else TP = nd(_OpenPrice-_TakeProfit*_point,TradeSymbol);
         break;
      }
   }
   return(TP);
}
//*------------------------------------------------------------------*
double GetStopLoss(int TradeType, double _StopLoss, double _OpenPrice=0, string TradeSymbol="")
{
   if(_StopLoss==0) return(0);
   
   GetTradeSymbol(TradeSymbol);
   
   if(isDouble(_StopLoss)) return(nd(_StopLoss,TradeSymbol));
   
   double _point = GetPoint(TradeSymbol);  
   double SL=0;
   
   switch(TradeType)
   {
      case OP_BUY:
      {
         SL = nd(MarketInfo(TradeSymbol,MODE_ASK)-_StopLoss*_point,TradeSymbol);
         break;
      }
      case OP_SELL:
      {
         SL = nd(MarketInfo(TradeSymbol,MODE_BID)+_StopLoss*_point,TradeSymbol);
         break;
      }
      case OP_BUYLIMIT:
      {
         if(_OpenPrice==0) SL = nd(MarketInfo(TradeSymbol,MODE_ASK)-_StopLoss*_point,TradeSymbol);
         else SL = nd(_OpenPrice-_StopLoss*_point,TradeSymbol);
         break;
      }
      case OP_BUYSTOP:
      {
         if(_OpenPrice==0) SL = nd(MarketInfo(TradeSymbol,MODE_ASK)-_StopLoss*_point,TradeSymbol);
         else SL = nd(_OpenPrice-_StopLoss*_point,TradeSymbol);
         break;
      }
      case OP_SELLLIMIT:
      {
         if(_OpenPrice==0) SL = nd(MarketInfo(TradeSymbol,MODE_BID)+_StopLoss*_point,TradeSymbol);
         else SL = nd(_OpenPrice+_StopLoss*_point,TradeSymbol);
         break;
      }
      case OP_SELLSTOP:
      {
         if(_OpenPrice==0) SL = nd(MarketInfo(TradeSymbol,MODE_BID)+_StopLoss*_point,TradeSymbol);
         else SL = nd(_OpenPrice+_StopLoss*_point,TradeSymbol);
         break;
      }
   }
   return(SL);
}
//*------------------------------------------------------------------*
double GetOpenPrice(int TradeType, double price=0, int level=0, string TradeSymbol="")
{
   GetTradeSymbol(TradeSymbol);
   
   double _point = GetPoint(TradeSymbol);
   
   double _OpenPrice=0;
   
   switch(TradeType)
   {
      case OP_BUY:
      {
         _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK),TradeSymbol);
         break;
      }
      case OP_SELL:
      {
         _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_BID),TradeSymbol);
         break;
      }
      case OP_BUYLIMIT:
      {
         if(price==0)
         {
            if(level==0) _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK),TradeSymbol);
            else _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK)-(level*_point),TradeSymbol);
         }
         else
         {
            if(level==0) _OpenPrice = nd(price,TradeSymbol);
            else _OpenPrice = nd(price-(level*_point),TradeSymbol);
         }
         break;
      }
      case OP_BUYSTOP:
      {
         if(price==0)
         {
            if(level==0) _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK),TradeSymbol);
            else _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK)+(level*_point),TradeSymbol);
         }
         else
         {
            if(level==0) _OpenPrice = nd(price,TradeSymbol);
            else _OpenPrice = nd(price+(level*_point),TradeSymbol);
         }
         break;
      }
      case OP_SELLLIMIT:
      {
         if(price==0)
         {
            if(level==0) _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_BID),TradeSymbol);
            else _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_BID)+(level*_point),TradeSymbol);
         }
         else
         {
            if(level==0) _OpenPrice = nd(price,TradeSymbol);
            else _OpenPrice = nd(price+(level*_point),TradeSymbol);
         }
         break;
      }
      case OP_SELLSTOP:
      {
         if(price==0)
         {
            if(level==0) _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_BID),TradeSymbol);
            else _OpenPrice = nd(MarketInfo(TradeSymbol,MODE_ASK)-(level*_point),TradeSymbol);
         }
         else
         {
            if(level==0) _OpenPrice = nd(price,TradeSymbol);
            else _OpenPrice = nd(price-(level*_point),TradeSymbol);
         }
         break;
      }
   }
   
   return(_OpenPrice);
}
//*------------------------------------------------------------------*
bool isValidLimit(double limit_value, string limit_type, int order_type, string TradeSymbol="")
{
   if(limit_value==0) return(true);
   
   GetTradeSymbol(TradeSymbol);
   
   double distance=0,_point;
   _point = GetPoint(TradeSymbol);
   
   if(order_type==OP_BUY)
   {
      if(limit_type=="tp") distance = (limit_value - nd(MarketInfo(TradeSymbol,MODE_ASK)))/_point;
      if(limit_type=="sl") distance = (nd(MarketInfo(TradeSymbol,MODE_ASK))-limit_value)/_point;
   }
   if(order_type==OP_SELL)
   {
      if(limit_type=="sl") distance = (limit_value - nd(MarketInfo(TradeSymbol,MODE_BID)))/_point;
      if(limit_type=="tp") distance = (nd(MarketInfo(TradeSymbol,MODE_BID))-limit_value)/_point;
   } 
   if(distance<MinimumLimit(TradeSymbol)) return(false);
   return(true);
}
//*------------------------------------------------------------------*
int OpenPending(string TradeSymbol, double TradePrice, int TradeType, double TradeLot, int Level, int TradeSlippage=5, double TradeStopLoss=0, 
double TradeTakeProfit=0, int TradeMagicNumber=0, string TradeComment="", datetime Expiration=0, color ArrowColor=Yellow)
{
   GetTradeSymbol(TradeSymbol);
   
   if(TradePrice==0 && Level<NearestPending(TradeSymbol))
   {
      Print("Pending order distance is lesser than broker allowed distance!");
      return(-1);
   }
   
   if(TradeComment=="") TradeComment = WindowExpertName();
   
   double _openprice = GetOpenPrice(TradeType, TradePrice, Level, TradeSymbol);
   double _stoploss = GetStopLoss(TradeType, TradeStopLoss, _openprice, TradeSymbol);
   double _takeprofit = GetTakeProfit(TradeType, TradeTakeProfit, _openprice, TradeSymbol);
   
   int result=-1;     
   for(int cnt=0; cnt<TriesCount; cnt++)
   {                   
      result = OrderSend(TradeSymbol,TradeType,TradeLot,_openprice,TradeSlippage,_stoploss,_takeprofit,TradeComment,TradeMagicNumber,Expiration,ArrowColor);    
      if(result>-1) break; 
      else 
      {               
         Sleep(_Pause);
         if(cnt+1==TriesCount) PrintOrderOpenError("placing",TradeType,TradeSymbol,_openprice,_stoploss,_takeprofit,TradeLot);
      }  
   }         
      
   return(result);
}
//*------------------------------------------------------------------*
int OpenInstant(bool STP, string TradeSymbol, int TradeType, double TradeLot, int TradeSlippage=5, double TradeStopLoss=0, 
double TradeTakeProfit=0, int TradeMagicNumber=0, string TradeComment="")
{
   GetTradeSymbol(TradeSymbol);
      
   int TradeTicket=-1, cnt=0, i=0;
   bool DobuleLimits;      
   double ask,bid,stoploss=0,takeprofit=0,_point=0.0001;
   
   _point = GetPoint(TradeSymbol);

   if(TradeComment=="") TradeComment = WindowExpertName();
   
   if(TradeStopLoss==0 && TradeTakeProfit==0) DobuleLimits = false;
   else
   {
      if(TradeStopLoss!=0) DobuleLimits = TradeStopLoss-MathFloor(TradeStopLoss)>0;
      else DobuleLimits = TradeTakeProfit-MathFloor(TradeTakeProfit)>0;
   }     
   
   if(STP==true)
   {
      if(TradeType==OP_BUY)
      {
         for(cnt=0; cnt<TriesCount; cnt++)
         {
            RefreshRates();
            ask = nd(MarketInfo(TradeSymbol,MODE_ASK),TradeSymbol);            
      
            if(DobuleLimits)
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(TradeStopLoss,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(TradeTakeProfit,TradeSymbol);
            }
            else
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(ask-TradeStopLoss*_point,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(ask+TradeTakeProfit*_point,TradeSymbol);
            }
            if(!isValidLimit(stoploss,"sl",TradeType,TradeSymbol) || !isValidLimit(takeprofit,"tp",TradeType,TradeSymbol))
            {
               Print("Invalid limit");
               return(-1);
            }
            if(stoploss==0 && takeprofit==0)
            {
               TradeTicket=OrderSend(TradeSymbol,OP_BUY,TradeLot,ask,TradeSlippage,0,0,TradeComment,TradeMagicNumber,0,Green);
               if(TradeTicket>-1) 
               {
                  break;
               }
               else
               {
                  if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,ask,stoploss,takeprofit,TradeLot);
                  Sleep(_Pause);
               }
            }
            else
            {
               TradeTicket=OrderSend(TradeSymbol,OP_BUY,TradeLot,ask,TradeSlippage,0,0,TradeComment,TradeMagicNumber,0,Green);
               if(TradeTicket>-1) 
               {
                  if(!OrderSelect(TradeTicket,SELECT_BY_TICKET,MODE_TRADES)) continue;
                  for(i=0; i<TriesCount; i++)
                  {
                     if(OrderModify(TradeTicket,OrderOpenPrice(),stoploss,takeprofit,0,Green)) 
                     break;
                     else
                     if(i+1==TriesCount) PrintOrderOpenError("modifying",TradeType,TradeSymbol,ask,stoploss,takeprofit,TradeLot);
                  }
                  break;
               }
               else
               {
                  if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,ask,stoploss,takeprofit,TradeLot);
                  Sleep(_Pause); 
               }
             }
         }
      }
      
      if(TradeType==OP_SELL)
      {
         for(cnt=0; cnt<TriesCount; cnt++)
         {
            RefreshRates();
            bid = nd(MarketInfo(TradeSymbol,MODE_BID),TradeSymbol);
             
            if(DobuleLimits)
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(TradeStopLoss,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(TradeTakeProfit,TradeSymbol);
            }
            else
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(bid+TradeStopLoss*_point,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(bid-TradeTakeProfit*_point,TradeSymbol);
            }
            if(!isValidLimit(stoploss,"sl",TradeType,TradeSymbol) || !isValidLimit(takeprofit,"tp",TradeType,TradeSymbol))
            {
               Print("Invalid limit");
               return(-1);
            }            
            if(stoploss==0 && takeprofit==0)
            {
               TradeTicket=OrderSend(TradeSymbol,OP_SELL,TradeLot,bid,TradeSlippage,0,0,TradeComment,TradeMagicNumber,0,Red);
               if(TradeTicket>-1) 
               {
                  break;
               }
               else
               {
                  if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,ask,stoploss,takeprofit,TradeLot);
                  Sleep(_Pause);
               }
            }
            else
            {
               TradeTicket=OrderSend(TradeSymbol,OP_SELL,TradeLot,bid,TradeSlippage,0,0,TradeComment,TradeMagicNumber,0,Red);
               if(TradeTicket>-1) 
               {
                  if(!OrderSelect(TradeTicket,SELECT_BY_TICKET,MODE_TRADES)) continue;
                  for(i=0; i<TriesCount; i++)
                  {
                     if(OrderModify(TradeTicket,OrderOpenPrice(),stoploss,takeprofit,0,Red)) 
                     break;
                     else
                     if(i+1==TriesCount) PrintOrderOpenError("modifying",TradeType,TradeSymbol,bid,stoploss,takeprofit,TradeLot);
                  }
                  break;
               }
               else
               {
                  if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,bid,stoploss,takeprofit,TradeLot);
                  Sleep(_Pause); 
               }
             }
         }
      }         
   }   
   
   if(STP==false)
   {
      if(TradeType==OP_BUY)
      {
         for(cnt=0; cnt<TriesCount; cnt++)
         {
            RefreshRates();
            ask = nd(MarketInfo(TradeSymbol,MODE_ASK),TradeSymbol);
             
            if(DobuleLimits)
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(TradeStopLoss,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(TradeTakeProfit,TradeSymbol);
            }
            else
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(ask-TradeStopLoss*_point,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(ask+TradeTakeProfit*_point,TradeSymbol);
            }
            if(!isValidLimit(stoploss,"sl",TradeType,TradeSymbol) || !isValidLimit(takeprofit,"tp",TradeType,TradeSymbol))
            {
               Print("Invalid limit");
               return(-1);
            }          
            TradeTicket=OrderSend(TradeSymbol,OP_BUY,TradeLot,ask,TradeSlippage,stoploss,takeprofit,TradeComment,TradeMagicNumber,0,Green);
            if(TradeTicket>-1) 
            {
               break;
            }
            else
            {
               if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,ask,stoploss,takeprofit,TradeLot);
               Sleep(_Pause); 
            } 
         }
      }  
          
      if(TradeType==OP_SELL)
      {
         for(cnt=0; cnt<TriesCount; cnt++)
         {
            RefreshRates();
            bid = nd(MarketInfo(TradeSymbol,MODE_BID),TradeSymbol);
             
            if(DobuleLimits)
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(TradeStopLoss,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(TradeTakeProfit,TradeSymbol);
            }
            else
            {
               if(TradeStopLoss==0) stoploss = 0; else stoploss = nd(bid+TradeStopLoss*_point,TradeSymbol);
               if(TradeTakeProfit==0) takeprofit = 0; else takeprofit = nd(bid-TradeTakeProfit*_point,TradeSymbol);
            }
            if(!isValidLimit(stoploss,"sl",TradeType,TradeSymbol) || !isValidLimit(takeprofit,"tp",TradeType,TradeSymbol))
            {
               Print("Invalid limit");
               return(-1);
            }          
            TradeTicket=OrderSend(TradeSymbol,OP_SELL,TradeLot,bid,TradeSlippage,stoploss,takeprofit,TradeComment,TradeMagicNumber,0,Red);
            if(TradeTicket>-1) 
            {
               break;
            }
            else
            {
               if(cnt+1==TriesCount) PrintOrderOpenError("opening",TradeType,TradeSymbol,bid,stoploss,takeprofit,TradeLot);
               Sleep(_Pause); 
            } 
         }
      }       
   }
   
   return(TradeTicket);
}
//*------------------------------------------------------------------*
void PrintOrderOpenError(string task, int type, string TradeSymbol, double price, double stoploss, double takeprofit, double lots)
{  
   string sType;
   if(type==OP_BUY)  sType = "BUY"; if(type==OP_SELL) sType = "SELL";  
   if(type==OP_BUYSTOP)  sType = "BUY STOP"; if(type==OP_SELLSTOP) sType = "SELL STOP";  
   if(type==OP_BUYLIMIT)  sType = "BUY LIMIT"; if(type==OP_SELLLIMIT) sType = "SELL LIMIT";  
   int error = GetLastError();
   int digits = (int) MarketInfo(TradeSymbol,MODE_DIGITS);
   string msg = "Error " + task + " " + sType + " order!" + " Error = " + IntegerToString(error) + " (" + ErrorDescription(error) + ") ";
   msg = msg + " - Symbol=" + TradeSymbol + " - Price=" + DoubleToStr(price,digits) + " - StopLoss=" + DoubleToStr(stoploss,digits) 
   + " - TakeProfit=" + DoubleToStr(takeprofit,digits) + " - Lots=" + DoubleToStr(lots,2);
   Print(msg); 
}
//*------------------------------------------------------------------*
