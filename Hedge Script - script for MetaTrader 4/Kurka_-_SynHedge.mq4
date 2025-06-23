
#property copyright "Copyright © 2009, Kevin Kurka"
#include <WinUser32.mqh>




/*
string Pairs[66] = { "EURUSD","USDJPY","AUDUSD","GBPUSD","USDCHF","USDCAD","NZDUSD",//Majors
                     "EURGBP","EURCHF","EURJPY","CADJPY","CHFJPY","AUDJPY","GBPCHF","NZDJPY","EURAUD","EURCAD","AUDCHF",
                     "NZDCAD","EURDKK","AUDCAD","GBPCAD","GBPAUD","CADCHF","NZDCHF","GBPJPY","NOKSEK","EURNZD","AUDNZD",
                     "EURTRY","EURNOK","EURSEK",//Crosses
                     "CADSGD","SGDJPY","USDHKD","USDSGD","CHFSGD","EURSGD","NOKJPY","SEKJPY","NZDSGD","USDTRY","TRYJPY",
                     "GBPNZD","GBPSGD","USDDKK","EURHKD","USDNOK","NZDDKK","CHFNOK","CHFPLN","EURCZK","EURHUF","USDCZK",
                     "USDPLN","USDSEK","USDMXN","HKDJPY","GBPPLN","GBPNOK","GBPSEK","NZDSEK","GBPTRY","GBPDKK","GBPHUF","EURZAR","USDZAR"}

string Indexs[16] = { "USD","EUR","JPY","GBP","CHF","CAD","NZD","AUD","DKK","SEK","NOK","TRY","CZK","PLN","HKD","MXN","ZAR" }
*/

string Pairs[] = {   "EURUSD","EURJPY","EURGBP","EURCHF","EURCAD","EURNZD","EURAUD",
                     "USDJPY","USDCHF","USDCAD",
                     "GBPUSD","GBPJPY","GBPCHF","GBPCAD","GBPNZD","GBPAUD",
                     "CHFJPY",
                     "CADJPY","CADCHF",
                     "NZDUSD","NZDJPY","NZDCHF","NZDCAD",
                     "AUDUSD","AUDJPY","AUDCHF","AUDCAD","AUDNZD"};

string Indexes[] = { "EUR","USD","JPY","GBP","CHF","CAD","NZD","AUD"};







///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void Respect_My_Authotiry(){

             int respect=MessageBox(" I HEARBY ACKNOWLEDGE THAT KURKA IS A FOREX GENIUS "
                                ,"Respect My Authority", MB_YESNO|MB_ICONQUESTION);
             if(respect==IDNO){
               Comment(" BEGIN ACCOUNT DESTRUCTION SEQUENCE >>>>>>>>>>>>>>>>>>>>>>>");
               for (int i = 0; i < 20; i++){
                   Print(i+"Critical error detected: "+i+" User cerebrum malfunction, seek medical attention immediately"+i);
                   }
               return(0);
               }
             if(respect==IDYES) {Check_Orders();}

}


void Check_Orders(){
             
         for (int i = 0; i < OrdersTotal(); i++){
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         
             string O_Type; 
             if (OrderType()==OP_BUY){O_Type = " Buy ";}
             if (OrderType()==OP_SELL){O_Type = " Sell ";}
             //if (OrderType()!=OP_SELL || OrderType()!=OP_BUY ){continue;}
             
             int ret=MessageBox(" WOULD YOU LIKE TO HEDGE"+"\n"+"\n"+
                                "   Order Number : "+OrderTicket()+"\n"+
                                "   Symbol             : "+OrderSymbol()+"\n"+
                                "   Order Type      : "+O_Type+"\n"+
                                "   Size                  : "+DoubleToStr(OrderLots(),Digits)
                                ,"Kurka - SynHedge (Kurkafund@yahoo.com)", MB_YESNO|MB_ICONQUESTION);
             if(ret==IDNO) {continue;}
             if(ret==IDYES) {
                Hedge_This(OrderSymbol(),OrderType(),OrderLots());
                }

            
        }// i
        

}
void  Hedge_This(string HedgeSymbol, int HedgeType, double HedgeLots){

      int a,b,c;
      double TranCost = 99999999;
      string SynSymbol_1,SynSymbol_2;
      int Direction_1,Direction_2;
      double Lots_1,Lots_2;
      

      for (a = 0; a < ArraySize(Indexes); a++){ 
          if(Indexes[a] == StringSubstr(HedgeSymbol,0,3) || Indexes[a] == StringSubstr(HedgeSymbol,3,3)){ continue; }// skip useless indexes    
         for (b = 0; b < ArraySize(Pairs); b++){ 
            if (HedgeSymbol == Pairs[b]){ continue; }// Skip = values
            for (c = 0; c < ArraySize(Pairs); c++){ 
              if( HedgeSymbol == Pairs[c]){ continue; }// Skip = values
              
              double Size_1 = NormalizeDouble((MarketInfo(HedgeSymbol,MODE_TICKVALUE) * HedgeLots) / MarketInfo(Pairs[b],MODE_TICKVALUE),2);
              double Size_2 = NormalizeDouble((MarketInfo(HedgeSymbol,MODE_TICKVALUE) * HedgeLots) / MarketInfo(Pairs[c],MODE_TICKVALUE),2);
              
              if ( (Size_1 * MarketInfo(Pairs[b],MODE_TICKVALUE) * MarketInfo(Pairs[b],MODE_SPREAD)+ 
                    Size_2 * MarketInfo(Pairs[c],MODE_TICKVALUE) * MarketInfo(Pairs[c],MODE_SPREAD) ) > TranCost){ continue; } 
                    

              if (Indexes[a] == StringSubstr(Pairs[b],0,3) && StringSubstr(HedgeSymbol,0,3) == StringSubstr(Pairs[b],3,3) ){
                    if(Indexes[a] == StringSubstr(Pairs[c],0,3) && StringSubstr(HedgeSymbol,3,3) == StringSubstr(Pairs[c],3,3)){
                       TranCost = (Size_1 * MarketInfo(Pairs[b],MODE_TICKVALUE) * MarketInfo(Pairs[b],MODE_SPREAD)+ 
                                   Size_2 * MarketInfo(Pairs[c],MODE_TICKVALUE) * MarketInfo(Pairs[c],MODE_SPREAD) );
                       if(HedgeType == 0){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_BUY; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_SELL; Lots_2 = Size_2;
                                           }
                       if(HedgeType == 1){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_SELL; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_BUY; Lots_2 = Size_2;
                                           }
                       } 
                    if(Indexes[a] == StringSubstr(Pairs[c],3,3) && StringSubstr(HedgeSymbol,3,3) == StringSubstr(Pairs[c],0,3)){
                       TranCost = (Size_1 * MarketInfo(Pairs[b],MODE_TICKVALUE) * MarketInfo(Pairs[b],MODE_SPREAD)+ 
                                   Size_2 * MarketInfo(Pairs[c],MODE_TICKVALUE) * MarketInfo(Pairs[c],MODE_SPREAD) );
                       if(HedgeType == 0){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_BUY; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_BUY; Lots_2 = Size_2;
                                           }
                       if(HedgeType == 1){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_SELL; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_SELL; Lots_2 = Size_2;
                                           }
                       }
                 }
               
             if (Indexes[a] == StringSubstr(Pairs[b],3,3) && StringSubstr(HedgeSymbol,0,3) == StringSubstr(Pairs[b],0,3) ){
                    if(Indexes[a] == StringSubstr(Pairs[c],0,3) && StringSubstr(HedgeSymbol,3,3) == StringSubstr(Pairs[c],3,3)){
                       TranCost = (Size_1 * MarketInfo(Pairs[b],MODE_TICKVALUE) * MarketInfo(Pairs[b],MODE_SPREAD)+ 
                                   Size_2 * MarketInfo(Pairs[c],MODE_TICKVALUE) * MarketInfo(Pairs[c],MODE_SPREAD) );
                       if(HedgeType == 0){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_SELL; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_SELL; Lots_2 = Size_2;
                                           }
                       if(HedgeType == 1){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_BUY; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_BUY; Lots_2 = Size_2;
                                           }
                       } 
                    if(Indexes[a] == StringSubstr(Pairs[c],3,3) && StringSubstr(HedgeSymbol,3,3) == StringSubstr(Pairs[c],0,3)){
                       TranCost = (Size_1 * MarketInfo(Pairs[b],MODE_TICKVALUE) * MarketInfo(Pairs[b],MODE_SPREAD)+ 
                                   Size_2 * MarketInfo(Pairs[c],MODE_TICKVALUE) * MarketInfo(Pairs[c],MODE_SPREAD) );
                       if(HedgeType == 0){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_SELL; Lots_1 = Size_1;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_BUY; Lots_2 = Size_2;
                                           }
                       if(HedgeType == 1){ SynSymbol_1 = Pairs[b]; Direction_1 = OP_BUY; Lots_1 = Size_2;
                                           SynSymbol_2 = Pairs[c]; Direction_2 = OP_SELL; Lots_2 = Size_2;
                                           }
                    }
                 }  
                  
  
            } //End Pairs count C
         } //End Pairs count B
      } // End Index Count A

      SendHedge(SynSymbol_1,Direction_1,Lots_1);
      SendHedge(SynSymbol_2,Direction_2,Lots_2);
}

void SendHedge(string HedgeSymbol, int HedgeDirection, double HedgeLots){

      double HedgePrice;
      int j;
      if (HedgeDirection == OP_BUY){HedgePrice = MarketInfo(HedgeSymbol,MODE_ASK);}
      if (HedgeDirection == OP_SELL){HedgePrice = MarketInfo(HedgeSymbol,MODE_BID);}
      
      for (j = 0; j < 10; j++){ 
          int Ticket = OrderSend(HedgeSymbol,HedgeDirection,HedgeLots,HedgePrice,7,0,0,"Kurka - SynHedge",5384658752,0,White);
          if (Ticket > 0 ) { break; }
          if (Ticket < 0 ) {
              Print("Hedge attempt "+j+" of 10, Failed");
              continue;
              }
          }// i 
         
      

}


int start(){
      if(IsDemo() == false && AccountBalance() > 1000){
        Comment(" PLEASE CONTACT KEVIN KURKA TO OBTAIN A LICENCE FOR THIS SCRIPT: KURKAFUND@YAHOO.COM ");
        ObjectsDeleteAll();
        Print("UNAUTHORIZED ACCOUNT : "+AccountNumber());
        return(0);
        }
      Respect_My_Authotiry();
}// Start
  
  

