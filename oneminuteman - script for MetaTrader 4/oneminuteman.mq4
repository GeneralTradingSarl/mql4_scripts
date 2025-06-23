//+------------------------------------------------------------------+
//|                                                 oneminuteman.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---get the ask price put in an array increment an int then go thru the array simply looking for the highest and lowest price range
   double prices[1202]= {};//prices array 1 min=60 000 milliseconds bot sleeps for 50 ms each run
   int t=0;//index to the price
   double high=0.0;//high
   double low=0.0;//low
   while(1)
     {
      Sleep(50);//sleep 50 ms then refresh rates
      RefreshRates();
      prices[t]=Ask;//assign the price to the correct index

      if(t==1201)//if t "counter of entries" is at 1201  go thru the data and push each price an index lower
        {
         for(int i=0; i<1201; i++)
           {
            prices[i]=prices[i+1];
           }
        }
      t++;
      if(t==1202)//if the increments leads to end of arrsy reset it to 1201
        {
         t=1201;
        }
        
      low=100000;
      high=0;
      for(int i=0; i<1200; i++)//go through the data finding highs and lows
        {
         if(prices[i]>prices[i+1]&&prices[i]>high)
           {
            high=prices[i];
           }
         if(prices[i]<prices[i+1]&&prices[i]<low)
           {
            low=prices[i];
           }
        }
      Alert("highest deal ", high);//shout out the highs and lows
      Alert("lowest deal ", low);


     }

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

  }
//+------------------------------------------------------------------+
