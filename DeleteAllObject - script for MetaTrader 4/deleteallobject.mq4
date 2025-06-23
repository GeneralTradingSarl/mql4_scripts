//+------------------------------------------------------------------+
//|                                              DeleteAllObject.mq4 |
//|                                                            hairi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "hairi"
#property link          "https://www.mql5.com"
#property version       "1.0"
#property description   "Delete Object Script"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   Comment("");
   ObjectsDeleteAll(0,"",0,OBJ_VLINE);
   ObjectsDeleteAll(0,"",0,OBJ_HLINE);
   ObjectsDeleteAll(0,"",0,OBJ_TREND);
   ObjectsDeleteAll(0,"",0,OBJ_TRENDBYANGLE);
   ObjectsDeleteAll(0,"",0,OBJ_CYCLES);
   ObjectsDeleteAll(0,"",0,OBJ_CHANNEL);
   ObjectsDeleteAll(0,"",0,OBJ_STDDEVCHANNEL);
   ObjectsDeleteAll(0,"",0,OBJ_REGRESSION);
   ObjectsDeleteAll(0,"",0,OBJ_PITCHFORK);
   ObjectsDeleteAll(0,"",0,OBJ_GANNLINE);
   ObjectsDeleteAll(0,"",0,OBJ_GANNFAN);
   ObjectsDeleteAll(0,"",0,OBJ_GANNGRID);
   ObjectsDeleteAll(0,"",0,OBJ_FIBO);
   ObjectsDeleteAll(0,"",0,OBJ_FIBOTIMES);
   ObjectsDeleteAll(0,"",0,OBJ_FIBOFAN);
   ObjectsDeleteAll(0,"",0,OBJ_FIBOARC);
   ObjectsDeleteAll(0,"",0,OBJ_FIBOCHANNEL);
   ObjectsDeleteAll(0,"",0,OBJ_EXPANSION);
   ObjectsDeleteAll(0,"",0,OBJ_RECTANGLE);
   ObjectsDeleteAll(0,"",0,OBJ_TRIANGLE);
   ObjectsDeleteAll(0,"",0,OBJ_ELLIPSE);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_THUMB_UP);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_THUMB_DOWN);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_UP);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_DOWN);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_STOP);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_CHECK);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_LEFT_PRICE);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_RIGHT_PRICE);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_BUY);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW_SELL);
   ObjectsDeleteAll(0,"",0,OBJ_ARROW);
   ObjectsDeleteAll(0,"",0,OBJ_TEXT);
   ObjectsDeleteAll(0,"",0,OBJ_LABEL);
   ObjectsDeleteAll(0,"",0,OBJ_BUTTON);
   ObjectsDeleteAll(0,"",0,OBJ_CHART);
   ObjectsDeleteAll(0,"",0,OBJ_BITMAP);
   ObjectsDeleteAll(0,"",0,OBJ_BITMAP_LABEL);
   ObjectsDeleteAll(0,"",0,OBJ_EDIT);
   ObjectsDeleteAll(0,"",0,OBJ_EVENT);
   ObjectsDeleteAll(0,"",0,OBJ_RECTANGLE_LABEL);
  }
//+------------------------------------------------------------------+
