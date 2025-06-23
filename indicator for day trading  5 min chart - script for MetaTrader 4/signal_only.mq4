#property version   "1.00"
#property strict
#property script_show_inputs






extern int     TakeProfit           = 10; 
extern int     StopLoss             = 20;
extern double  lots =1 ;



void OnStart()
  {
             
             Alert("script started ");
             static int  ticket = 0;
             double TakeProfitLevel_buy = Bid + TakeProfit*Point;   //0.0001
             double StopLossLevel_buy = Bid - StopLoss*Point;
             double middlebb=iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_MAIN,0);
             double ma_ten = iMA(Symbol(),Period(),10,0,MODE_EMA,PRICE_CLOSE,0);
             double ma_fifty = iMA(Symbol(),Period(),50,0,MODE_EMA,PRICE_CLOSE,0);
             double sar = iSAR(Symbol(),Period(),0.02,0.2,0);
             double red = iStochastic(Symbol(),Period(),5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
             double blue = iStochastic(Symbol(),Period(),5,3,3,MODE_EMA,0,MODE_MAIN,0);
             double macd =iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE,MODE_MAIN,0);
             double rsi = iRSI(Symbol(),Period(),14,PRICE_CLOSE,0);
             
/*             
                Alert("the ckising price is ", Close[0] );
                Alert("the bb  is ", middlebb );
                Alert("the ma10 price is ", ma_ten );
                Alert("the ma50e is ", ma_fifty );
                Alert("the macd is ", macd );
                Alert("the sar is ", sar );
                Alert("the rsi is ", rsi );
                Alert("the red signL is ", red );
                Alert("the blue value is ", blue );
                
 */             
                
                
             
             
           
                            
              
             
              
             
             if ( middlebb <Close[0] && ma_ten < Close[0] && ma_fifty < Close[0] && sar < Close[0] && blue > red && macd >0 && rsi >50 )
               {
                     Alert("buy");
                                   
               }
             else
               if( middlebb > Close[0] && ma_ten > Close[0] && ma_fifty > Close[0] && sar > Close[0] && blue < red && macd < 0 && rsi < 50 ) 
               {
               
               Alert("sell "); 
               
               
               
               } 
             else 
               {
                  Alert ("something is wrong so not buying ");
                 
                  
                  
               }
             
              
            
 }
