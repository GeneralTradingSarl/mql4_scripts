//+------------------------------------------------------------------+
//|                                                 MarketBrowse.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                                  Name: Alexander |
//|                                 mailto: marketadviser@rambler.ru |
//|                                                                  |
//| to install script copy the file MarketBrowse.mq4                 |
//| to  C:\Program Files\ - Terminal folder - \experts\scripts\      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
//---- The messages window
   int Message=MessageBox("The script will be executed,\nContinue?",WindowExpertName(),MB_YESNO|MB_ICONQUESTION);
    if(Message==IDNO) return(false);
    
//---- It is necessary for the execute time measurements
     int TickCount=GetTickCount();
  string sym=Symbol();
  
//---- An information about the active account
  int add,abb;
  string abc,abd,abe,abf,acb,acc,acd,ace,acf,adb,adc,ade,adf,aeb,aec,aed,aee,aef,afb;
  abc="ACCOUNT INFORMATION";
  abd=StringConcatenate("Account Balance = ",AccountBalance());
  abe=StringConcatenate("Account Credit > ", AccountCredit());
  abf=StringConcatenate("Account Company - ", AccountCompany());
  acb=StringConcatenate("Account currency - ", AccountCurrency());
  acc=StringConcatenate("Account Equity = ",AccountEquity());
  acd=StringConcatenate("Account Free Margin = ",AccountFreeMargin());
  ace=StringConcatenate("Account Free Margin after opening the BUY order at the current price = ",AccountFreeMarginCheck(sym,OP_BUY,1));
  acf=StringConcatenate("Account Free Margin after opening the SELL order at the current price = ",AccountFreeMarginCheck(sym,OP_SELL,1));
  add=AccountFreeMarginMode();
   if(add==0) adb="Floating profit/loss is not used for calculation";
   if(add==1) adb="Both floating profit and loss on open positions on the current account are used for free margin calculation";
   if(add==2) adb="Only profit value is used for calculation, the current loss on open positions is not considered";
   if(add==3) adb="Only loss value is used for calculation, the current loss on open positions is not considered";
   if(add < 0 || add > 3) adb="Margin calculation mode is not defined";
  adc=StringConcatenate("Leverage = ", AccountLeverage());
  ade=StringConcatenate("Account Margin = ", AccountMargin());
  adf=StringConcatenate("Account Name - ", AccountName());
  aeb=StringConcatenate("Account Number - ", AccountNumber());
  aec=StringConcatenate("Account Profit = ", AccountProfit());
  aed=StringConcatenate("Account Server - ", AccountServer());
  aee=StringConcatenate("Account Stopout Level = ", AccountStopoutLevel());
  abb=AccountStopoutLevel(); if(AccountStopoutMode()==0) 
  aef=StringConcatenate("StopOut level = ", abb, "%"); else
  aef=StringConcatenate("StopOut level = ", abb, " ", AccountCurrency());
  afb=StringConcatenate(abc,"\n","\n",adf,"\n",aeb,"\n",abf,"\n",
  aed,"\n","\n",acb,"\n",adc,"\n",abe,"\n",abd,"\n",aec,"\n",acc,"\n",
  ade,"\n",acd,"\n",adb,"\n",ace,"\n",acf,"\n",aee,"\n",aef,"\n","\n");
 
//---- MARKET WATCH AND INFORMATION ABOUT FINANCIAL INSTRUMENTS
     int maa,mac,mad;
  string mae,maf,mag,mca,mcc,mcd,mce,mcf,mcg,mda,mdc,mdd,mde,mdf,mdg,mea,mec,med,mee,mef,meg,mfa,mfc,mfd,mfe,mff,mfg,
         mga,mgc,mgd,mge;
  mae="MARKET WATCH AND INFORMATION ABOUT FINANCIAL INSTRUMENTS";
  maf=StringConcatenate("Symbol - ",sym);
  mag=StringConcatenate("Minimal daily price = ",MarketInfo(sym,MODE_LOW));
  mca=StringConcatenate("Maximal daily price = ",MarketInfo(sym,MODE_HIGH));
  mcc=StringConcatenate("The time of the last quote / ",TimeToStr(MarketInfo(sym,MODE_TIME)));
  mcd=StringConcatenate("Last Bid = ",MarketInfo(sym,MODE_BID));
  mce=StringConcatenate("Last Ask = ",MarketInfo(sym,MODE_ASK));
  mcf=StringConcatenate("Point = ",MarketInfo(sym,MODE_POINT));
  mcg=StringConcatenate("Digits = ",MarketInfo(sym,MODE_DIGITS));
  mda= StringConcatenate("Spread in points = ",MarketInfo(sym,MODE_SPREAD));
  mdc=StringConcatenate("Minimal SL/TP level (in points) = ",MarketInfo(sym,MODE_STOPLEVEL));
  mdd=StringConcatenate("Lot size = ",MarketInfo(sym,MODE_LOTSIZE));
  mde=StringConcatenate("Tick size value (in the deposit currency) = ",MarketInfo(sym,MODE_TICKVALUE));
  mdf=StringConcatenate("Tick step size value in the symbol currency = ",MarketInfo(sym,MODE_TICKSIZE));
  mdg=StringConcatenate("Swap for long positions, Buy = ",MarketInfo(sym,MODE_SWAPLONG));
  mea=StringConcatenate("Swap for short positions, Sell = ",MarketInfo(sym,MODE_SWAPSHORT));
  mec=StringConcatenate("Market starting date (usually used for futures) / ",MarketInfo(sym,MODE_STARTING));
  med=StringConcatenate("Market expiration date (usually used for futures) / ",MarketInfo(sym,MODE_EXPIRATION));
   if(MarketInfo(sym,MODE_TRADEALLOWED)==1) 
    mee=StringConcatenate("Trades for symbol ",sym," - ENABLED"); else  
    mee=StringConcatenate("Trades for symbol ",sym," - DISABLED");
  mef=StringConcatenate("Minimal lot size = ",MarketInfo(sym,MODE_MINLOT));
  meg=StringConcatenate("Lot step = ",MarketInfo(sym,MODE_LOTSTEP));
  mfa=StringConcatenate("Maximal lot size = ",MarketInfo(sym,MODE_MAXLOT));
  maa=MarketInfo(sym,MODE_SWAPTYPE);
   if(maa==0) mfc="Swap calculation in points";
   if(maa==1) mfc="Swap calculation in the currency of the symbol";
   if(maa==2) mfc="Swap calculation in percents";
   if(maa==3) mfc="Swap calculation in the account currency";
   if(maa < 0 || maa > 3) mfc="Swap calculation mode is not defined";
  mac=MarketInfo(sym,MODE_PROFITCALCMODE);
   if(mac==0) mfd="Profit calculation mode, Forex";
   if(mac==1) mfd="Profit calculation mode, CFD";
   if(mac==2) mfd="Profit calculation mode, Futures";
   if(mac < 0 || mac > 2) mfd="Profit calculation mode is not defined";
  mad=MarketInfo(sym,MODE_MARGINCALCMODE);
   if(mad==0) mfe="Margin calculation mode: Forex";
   if(mad==1) mfe="Margin calculation mode: CFD";
   if(mad==2) mfe="Margin calculation mode: Futures";
   if(mad==3) mfe="Margin calculation mode: CFD for Indexes";
   if(mad < 0 || mad > 3) mfe="Margin calculation mode is not defined";
  mff=StringConcatenate("Initial margin requirements for 1 lot = ",MarketInfo(sym,MODE_MARGININIT));
  mfg=StringConcatenate("Margin to maintain open positions calculated for 1 lot = ",MarketInfo(sym,MODE_MARGINMAINTENANCE));
  mga=StringConcatenate("Hedged margin calculated for 1 lot = ",MarketInfo(sym,MODE_MARGINHEDGED));
  mgc=StringConcatenate("Free margin required to open 1 lot for buying = ",MarketInfo(sym,MODE_MARGINREQUIRED));
  mgd=StringConcatenate("Order freeze level in points = ",MarketInfo(sym,MODE_FREEZELEVEL));
  mge=StringConcatenate(mae,"\n","\n",maf,"\n",mag,"\n",mca,"\n",mcc,"\n",mcd,"\n",
  mce,"\n",mcf,"\n",mcg,"\n",mda,"\n",mdc,"\n",mdd,"\n",mde,"\n",mdf,"\n",mdg,"\n",
  mea,"\n",mec,"\n",med,"\n",mee,"\n",mef,"\n",meg,"\n",mfa,"\n",mfc,"\n",mfd,"\n",
  mfe,"\n",mff,"\n",mfg,"\n",mga,"\n",mgc,"\n",mgd,"\n","\n");

//---- CHECK FOR THE CLIENT TERMINAL OPTIONS
  string iaa,iac,iad,iae,ica,icc,icd,ice,ida,idc,idd,ide;
  iaa="CHECK FOR THE CLIENT TERMINAL OPTIONS";
  if(IsConnected()==true) iac="The connection with trade server is present"; else 
   iac="The connection with trade server is absent!";
  if(IsDemo()==true) iad="Demo account"; else 
   iad="Real account";
  if(IsDllsAllowed()==true) iae="DLL calls are allowed"; else
   iae="DLL calls are disabled. Expert cannot be executed.";
  if(IsExpertEnabled()==true) ica="The experts are allowed in the client terminal"; else
   ica="The experts are disabled in the client terminal";
  if(IsLibrariesAllowed()==true) icc="The library calls are allowed"; else
   icc="The library calls are disabled";
  if(IsOptimization()==true) icd="Expert is working in the optimization mode"; else
   icd="Expert is working in the normal mode (no optimization)";
  if(IsTesting()==true) ice="Expert is working in the test mode"; else
   ice="Expert is working in the normal mode (no testing)";
  if(IsTradeAllowed()==true) ida="Expert trading is allowed"; else
   ida="Expert trading is disabled";
  if(IsTradeContextBusy()==true) idc="(The trade context is busy now... Wait..."; else
   idc="The Trade Context is not busy";
  if(IsVisualMode()==true) idd="Expert test is performed with visualization mode"; else
   idd="Expert test is performed without visualization mode";
  ide=StringConcatenate(iaa,"\n","\n",iac,"\n",iad,"\n",iae,"\n",ica,"\n",
  icc,"\n",icd,"\n",ice,"\n",ida,"\n",idc,"\n",idd,"\n","\n");
 
//---- INFORMATION ABOUT THE CLIENT TERMINAL
  string tab,taa,tac,tba,tbb;
  tab="INFORMATION ABOUT THE CLIENT TERMINAL";
  taa=StringConcatenate("Terminal Company - ",TerminalCompany());
  tac=StringConcatenate("Terminal Name - ",TerminalName());
  tba=StringConcatenate("Terminal Path - ",TerminalPath());
  tbb=StringConcatenate(tab,"\n","\n",taa,"\n",tac,"\n",tba,"\n","\n");
 
//---- SAVING THE INFORMATON TO THE DATA FILE, C:\Program Files\ - Client terminal folder - \experts\files\
  int File=FileOpen(WindowExpertName()+"_"+sym+".csv",FILE_CSV|FILE_WRITE,'\t');
   {
    FileWrite(File,afb);
     FileWrite(File,mge);
      FileWrite(File,tbb);
       FileWrite(File,ide);
    FileClose(File);
   }
   Print("The time for the check was ",GetTickCount()-TickCount," milliseconds.");
//----
   return(0);
  }
//+------------------------------------------------------------------+ЕНИЕ ИНФОРМАЦИИ В ФАЙЛЕ ДАННЫХ, C:\Program Files\ - Терминал - \experts\files\
  int File=FileOpen(WindowExpertName()+"_"+sym+".csv",FILE_CSV|FILE_WRITE,'\t');
   {
    FileWrite(File,afb);
     FileWrite(File,mge);
      FileWrite(File,tbb);
       FileWrite(File,ide);
    FileClose(File);
   }
   Print("Время сбора информации составляет ",GetTickCount()-TickCount," миллисекунд.");
//----
   return(0);
  }
//+------------------------------------------------------------------+