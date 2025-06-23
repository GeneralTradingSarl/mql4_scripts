//+------------------------------------------------------------------+
//|                                           Buy_Sell_ACHEGJNUS.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Multiple Buys and Sells ORDERS based on a currency pair strength.
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, MetaQuotes Ltd."
#property link          "https://www.mql5.com"
#property version       "1.01"
#property description   "persinaru@gmail.com"
#property description   "IP 2024 - free open source"
#property description   "AUD CAD CHF EUR GBP JPY NZD USD SGD."
#property description   ""
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss."
#property description   ""
#property strict
#property show_inputs
#property script_show_inputs

input double Lot = 0.01;

input bool Buys      =  false;
input bool Sells     =  false;

input bool AUD    =  false; 
input bool CAD    =  false;
input bool CHF    =  false;
input bool EUR    =  false;
input bool GBP    =  false;
input bool JPY    =  false;
input bool NZD    =  false;
input bool USD    =  false;
input bool SGD    =  false;

void OnStart()
  {
  if(IsTradeAllowed()){
  
  if (AUD){AUD();}
  if (CAD){CAD();}
  if (CHF){CHF();}
  if (EUR){EUR();}
  if (GBP){GBP();}
  if (JPY){JPY();}
  if (NZD){NZD();}
  if (USD){USD();}
  if (SGD){SGD();}

  }
   else MessageBox("Enable AutoTrading Please ");
  }

void AUD()
 {
 if (Buys) { //A C H E G J N U S
 int AUDCAD_B = OrderSend("AUDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int AUDCHF_B = OrderSend("AUDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURAUD_B = OrderSend("EURAUD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPAUD_B = OrderSend("GBPAUD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int AUDJPY_B = OrderSend("AUDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int AUDNZD_B = OrderSend("AUDNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int AUDUSD_B = OrderSend("AUDUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int AUDSGD_B = OrderSend("AUDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDCAD_S = OrderSend("AUDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int AUDCHF_S = OrderSend("AUDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURAUD_S = OrderSend("EURAUD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPAUD_S = OrderSend("GBPAUD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int AUDJPY_S = OrderSend("AUDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int AUDNZD_S = OrderSend("AUDNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int AUDUSD_S = OrderSend("AUDUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int AUDSGD_S = OrderSend("AUDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}

void CAD()
 {
 if (Buys) { //A C H E G J N U S
 int AUDCAD_B = OrderSend("AUDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CADCHF_B = OrderSend("CADCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURCAD_B = OrderSend("EURCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPCAD_B = OrderSend("GBPCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CADJPY_B = OrderSend("CADJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDCAD_B = OrderSend("NZDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDCAD_B = OrderSend("USDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDCAD_B = OrderSend("SGDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDCAD_S = OrderSend("AUDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CADCHF_S = OrderSend("CADCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURCAD_S = OrderSend("EURCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPCAD_S = OrderSend("GBPCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CADJPY_S = OrderSend("CADJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDCAD_S = OrderSend("NZDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDCAD_S = OrderSend("USDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDCAD_S = OrderSend("SGDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
void CHF()
 {
 if (Buys) { //A C H E G J N U S
 int AUDCHF_B = OrderSend("AUDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CADCHF_B = OrderSend("CADCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURCHF_B = OrderSend("EURCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPCHF_B = OrderSend("GBPCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CHFJPY_B = OrderSend("CHFJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDCHF_B = OrderSend("NZDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDCHF_B = OrderSend("USDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDCHF_B = OrderSend("SGDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDCHF_S = OrderSend("AUDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CADCHF_S = OrderSend("CADCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURCHF_S = OrderSend("EURCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPCHF_S = OrderSend("GBPCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CHFJPY_S = OrderSend("CHFJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDCHF_S = OrderSend("NZDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDCHF_S = OrderSend("USDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDCHF_S = OrderSend("SGDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
void EUR()
 {
 if (Buys) { //A C H E G J N U S
 int EURAUD_B = OrderSend("EURAUD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURCAD_B = OrderSend("EURCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURCHF_B = OrderSend("EURCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURGBP_B = OrderSend("EURGBP",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURJPY_B = OrderSend("EURJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURNZD_B = OrderSend("EURNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURUSD_B = OrderSend("EURUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURSGD_B = OrderSend("EURSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int EURAUD_S = OrderSend("EURAUD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURCAD_S = OrderSend("EURCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURCHF_S = OrderSend("EURCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURGBP_S = OrderSend("EURGBP",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURJPY_S = OrderSend("EURJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURNZD_S = OrderSend("EURNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURUSD_S = OrderSend("EURUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURSGD_S = OrderSend("EURSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
void GBP()
 {
 if (Buys) { //A C H E G J N U S
 int GBPAUD_B = OrderSend("GBPAUD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPCAD_B = OrderSend("GBPCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPCHF_B = OrderSend("GBPCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURGBP_B = OrderSend("EURGBP",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPJPY_B = OrderSend("GBPJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPNZD_B = OrderSend("GBPNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPUSD_B = OrderSend("GBPUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPSGD_B = OrderSend("GBPSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int GBPAUD_S = OrderSend("GBPAUD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPCAD_S = OrderSend("GBPCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPCHF_S = OrderSend("GBPCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURGBP_S = OrderSend("EURGBP",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPJPY_S = OrderSend("GBPJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPNZD_S = OrderSend("GBPNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPUSD_S = OrderSend("GBPUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPSGD_S = OrderSend("GBPSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
void JPY()
 {
 if (Buys) { //A C H E G J N U S
 int AUDJPY_B = OrderSend("AUDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CADJPY_B = OrderSend("CADJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int CHFJPY_B = OrderSend("CHFJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURJPY_B = OrderSend("EURJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPJPY_B = OrderSend("GBPJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDJPY_B = OrderSend("NZDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDJPY_B = OrderSend("USDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDJPY_B = OrderSend("SGDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDJPY_S = OrderSend("AUDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CADJPY_S = OrderSend("CADJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int CHFJPY_S = OrderSend("CHFJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURJPY_S = OrderSend("EURJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPJPY_S = OrderSend("GBPJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDJPY_S = OrderSend("NZDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDJPY_S = OrderSend("USDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDJPY_S = OrderSend("SGDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
void NZD()
 {
 if (Buys) { //A C H E G J N U S
 int AUDNZD_B = OrderSend("AUDNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDCAD_B = OrderSend("NZDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDCHF_B = OrderSend("NZDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURNZD_B = OrderSend("EURNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPNZD_B = OrderSend("GBPNZD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDJPY_B = OrderSend("NZDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDUSD_B = OrderSend("NZDUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDSGD_B = OrderSend("NZDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDNZD_S = OrderSend("AUDNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDCAD_S = OrderSend("NZDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDCHF_S = OrderSend("NZDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURNZD_S = OrderSend("EURNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPNZD_S = OrderSend("GBPNZD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDJPY_S = OrderSend("NZDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDUSD_S = OrderSend("NZDUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDSGD_S = OrderSend("NZDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
 void USD()
 {
 if (Buys) { //A C H E G J N U S
 int AUDUSD_B = OrderSend("AUDUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDCAD_B = OrderSend("USDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDCHF_B = OrderSend("USDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURUSD_B = OrderSend("EURUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPUSD_B = OrderSend("GBPUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDJPY_B = OrderSend("USDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDUSD_B = OrderSend("NZDUSD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDSGD_B = OrderSend("USDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDUSD_S = OrderSend("AUDUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDCAD_S = OrderSend("USDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDCHF_S = OrderSend("USDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURUSD_S = OrderSend("EURUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPUSD_S = OrderSend("GBPUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDJPY_S = OrderSend("USDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDUSD_S = OrderSend("NZDUSD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDSGD_S = OrderSend("USDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}
 
void SGD()
 {
 if (Buys) { //A C H E G J N U S
 int AUDSGD_B = OrderSend("AUDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDCAD_B = OrderSend("SGDCAD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDCHF_B = OrderSend("SGDCHF",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int EURSGD_B = OrderSend("EURSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int GBPSGD_B = OrderSend("GBPSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int SGDJPY_B = OrderSend("SGDJPY",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int NZDSGD_B = OrderSend("NZDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 int USDSGD_B = OrderSend("USDSGD",OP_BUY,Lot,0,10,0,0,"",0,0,0);
 }
 if (Sells) {
 int AUDSGD_S = OrderSend("AUDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDCAD_S = OrderSend("SGDCAD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDCHF_S = OrderSend("SGDCHF",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int EURSGD_S = OrderSend("EURSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int GBPSGD_S = OrderSend("GBPSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int SGDJPY_S = OrderSend("SGDJPY",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int NZDSGD_S = OrderSend("NZDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 int USDSGD_S = OrderSend("USDSGD",OP_SELL,Lot,0,10,0,0,"",0,0,0);
 }}


