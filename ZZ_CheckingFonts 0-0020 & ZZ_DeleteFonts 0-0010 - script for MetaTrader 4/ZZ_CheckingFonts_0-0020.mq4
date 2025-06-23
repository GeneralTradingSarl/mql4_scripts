//+------------------------------------------------------------------+
//|                                       ZZ_CheckingFonts 0-0020.mq4|
//|                                       Copyright © Zhunko         |
//|21.11.2007 - 09.02.2008                zhunko@mail.ru             |
//+------------------------------------------------------------------+
#property copyright "Copyright © Zhunko"
#property link      "zhunko@mail.ru"
#property show_inputs
//----Внешние переменные.---------------------------------------------
extern string NameFont  = "Wingdings"; // Название шрифта.
extern int    SizeFonte = 20;          // Размер элеметов шрифта на графике.
extern int    DistFonte = 10;          // Дистанция между элеметами шрифта на графике в пикселях.
extern int    NumberFirstSymbol = 30;  // Нижнее ограничение номера элемента.
extern int    AmountSymbol = 255;      // Верхнее ограничение номера элемента.
extern color  ColorFont = Red;         // Цвет элементов шрифта на графике.
extern color  ColorNumber = Yellow;    // Цвет номеров элементов.
//--------------------------------------------------------------------
#import "user32.dll"
 int GetClientRect (int hWnd, int lpRect[]);
#import
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
 {
  int Size = 1.3 * SizeFonte;
  int i, n;
  int XDISTANCE;
  int YDISTANCE;
  int Rect[4];
  //----
  GetClientRect (WindowHandle (Symbol(), Period()), Rect);
  Size = (Size + DistFonte);
  int Amount = (Rect[2] - Size) / Size;
  if (AmountSymbol > 455) AmountSymbol = 455;
  // Удалям всё по возможности.
  for (i = 0; i <= 455; i++)
   {
    ObjectDelete ("LABEL Arrow " + i);
    ObjectDelete ("LABEL Arrow №" + i);
   }
  // Рисуем шрифты.
  for (i = NumberFirstSymbol; i <= AmountSymbol; i++)
   {
    n = i - NumberFirstSymbol;
    if (0 <= n && n < Amount)
     {
      XDISTANCE = Size * n + 1;
      YDISTANCE = 20;
     }
    else
     if (Amount <= n && n < 2 * Amount)
      {
       XDISTANCE = Size * n - Amount * Size + 1;
       YDISTANCE = 20 + 2 * SizeFonte;
      }
     else
      if (2 * Amount <= n && n < 3 * Amount)
       {
        XDISTANCE = Size * n - 2 * Amount * Size + 1;
        YDISTANCE = 20 + 4 * SizeFonte;
       }
      else
       if (3 * Amount <= n && n < 4 * Amount)
        {
         XDISTANCE = Size * n - 3 * Amount * Size + 1;
         YDISTANCE = 20 + 6 * SizeFonte;
        }
       else
        if (4 * Amount <= n && n < 5 * Amount)
         {
          XDISTANCE = Size * n - 4 * Amount * Size + 1;
          YDISTANCE = 20 + 8 * SizeFonte;
         }
        else
         if (5 * Amount <= n && n <  6 * Amount)
          {
           XDISTANCE = Size * n - 5 * Amount * Size + 1;
           YDISTANCE = 20 + 10 * SizeFonte;
          }
         else
          if (6 * Amount <= n && n < 7 * Amount)
           {
            XDISTANCE = Size * n - 6 * Amount * Size + 1;
            YDISTANCE = 20 + 12 * SizeFonte;
           }
          else
           if (7 * Amount <= n && n < 8 * Amount)
            {
             XDISTANCE = Size * n - 7 * Amount * Size + 1;
             YDISTANCE = 20 + 14 * SizeFonte;
            }
           else
            if (8 * Amount <= n && n < 9 * Amount)
             {
              XDISTANCE = Size * n - 8 * Amount * Size + 1;
              YDISTANCE = 20 + 16 * SizeFonte;
             }
            else
             if (9 * Amount <= n && n < 10 * Amount)
              {
               XDISTANCE = Size * n - 9 * Amount * Size + 1;
               YDISTANCE = 20 + 18 * SizeFonte;
              }
             else
              if (10 * Amount <= n && n < 11 * Amount)
               {
                XDISTANCE = Size * n - 10 * Amount * Size + 1;
                YDISTANCE = 20 + 20 * SizeFonte;
               }
              else
               if (11 * Amount <= n && n < 12 * Amount)
                {
                 XDISTANCE = Size * n - 11 * Amount * Size + 1;
                 YDISTANCE = 20 + 22 * SizeFonte;
                }
               else
                if (12 * Amount <= n && n < 13 * Amount)
                 {
                  XDISTANCE = Size * n - 12 * Amount * Size + 1;
                  YDISTANCE = 20 + 24 * SizeFonte;
                 }
                else
                 if (13 * Amount <= n && n < 14 * Amount)
                  {
                   XDISTANCE = Size * n - 13 * Amount * Size + 1;
                   YDISTANCE = 20 + 26 * SizeFonte;
                  }
                 else
                  if (14 * Amount <= n && n < 15 * Amount)
                   {
                    XDISTANCE = Size * n - 14 * Amount * Size + 1;
                    YDISTANCE = 20 + 28 * SizeFonte;
                   }
                  else
                   if (15 * Amount <= n && n < 16 * Amount)
                    {
                     XDISTANCE = Size * n - 15 * Amount * Size + 1;
                     YDISTANCE = 20 + 30 * SizeFonte;
                    }
                   else
                    if (16 * Amount <= n && n < 17 * Amount)
                     {
                      XDISTANCE = Size * n - 16 * Amount * Size + 1;
                      YDISTANCE = 20 + 32 * SizeFonte;
                     }
    // Создаём объект элемента шрифта.
    ObjectCreate  ("LABEL Arrow " + i, OBJ_LABEL, 0, 0, 0, 0, 0);
    ObjectSetText ("LABEL Arrow " + i, StringSetChar ("", 0, i), SizeFonte, NameFont, ColorFont);
    ObjectSet     ("LABEL Arrow " + i, OBJPROP_ARROWCODE, i);
    ObjectSet     ("LABEL Arrow " + i, OBJPROP_CORNER, 0);
    ObjectSet     ("LABEL Arrow " + i, OBJPROP_XDISTANCE, XDISTANCE);
    ObjectSet     ("LABEL Arrow " + i, OBJPROP_YDISTANCE, YDISTANCE);
    ObjectSet     ("LABEL Arrow " + i, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
    // Создаём объект номер элемента шрифта.
    ObjectCreate  ("LABEL Arrow №" + i, OBJ_LABEL, 0, 0, 0, 0, 0);
    ObjectSetText ("LABEL Arrow №" + i, DoubleToStr (i, 0), 7, "Areal", ColorNumber);
    ObjectSet     ("LABEL Arrow №" + i, OBJPROP_CORNER, 0);
    ObjectSet     ("LABEL Arrow №" + i, OBJPROP_XDISTANCE, XDISTANCE);
    ObjectSet     ("LABEL Arrow №" + i, OBJPROP_YDISTANCE, YDISTANCE);
    ObjectSet     ("LABEL Arrow №" + i, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   }
  return(0);
 }
//--------------------------------------------------------------------