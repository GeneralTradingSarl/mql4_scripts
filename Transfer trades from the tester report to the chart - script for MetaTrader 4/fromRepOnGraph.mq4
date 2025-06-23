//+------------------------------------------------------------------+
//|                                               fromRepOnGraph.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|    17.02.2006  Скрипт для переноса сделок из отчёта на график.   |
//|                Carrying the Deals from Report on Graph.          |
//|  Скрипт выполняет чтение сделок из файла стандарного отчёта      |
//|  тестера и отображает их в виде разноцветных прямоугольников.    |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs

extern string FileName         = "StrategyTester.htm";
extern bool   DeleteOldObjects = True;      // Удалять старые объекты
extern string _P_Objects = "---------- Параметры объектов";
extern int    TypeObjects      = 1;         // Тип объектов (0-прямоуг. 1-линия)
extern color  clObjBuy         = Aqua;      // Цвет прибыльных покупок
extern color  clObjBuyLoss     = Blue;      // Цвет убыточных покупок
extern color  clObjSell        = Salmon;    // Цвет прибыльных продаж
extern color  clObjSellLoss    = Red;       // Цвет убыточных продаж
extern string _P_Arrows = "---------- Параметры указателей";
extern bool   ShowArrow        = True;      // Показывать указатели
extern int    KodArrowBuy      = 241;       // Код указателя покупки
extern int    OffSetArrowBuy   = -20;       // Смещение указателя покупки
extern color  clArrowBuy       = Blue;      // Цвет указателя покупки
extern int    KodArrowSell     = 242;       // Код указателя продажи
extern int    OffSetArrowSell  = 20;        // Смещение указателя продажи
extern color  clArrowSell      = Red;       // Цвет указателя продажи
extern string _P_Text = "---------- Параметры текста";
extern bool   ShowTextBalance  = True;      // Показывать текст баланса
extern int    OffSetText       = 100;       // Смещение текста
extern int    SizeText         = 9;         // Размер текста
extern color  clTextProfit     = Green;     // Цвет суммы прибыли
extern color  clTextLoss       = Red;       // Цвет суммы убытка
extern color  clTextBalans     = Green;     // Цвет суммы баланса

//------- Глобальные переменные --------------------------------------
int    frogBalance     = 0;
string frogNameObjLine = "LDeal";      // Наименования объектов ЛИНИЯ
string frogNameObjRect = "RDeal";      // Наименования объектов ПРЯМОУГОЛЬНИК


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
{
  datetime dt;
  double   pp;
  int      or, pos;
  string   op, str;

  int fh=FileOpen(FileName, FILE_BIN|FILE_READ);
  if (fh>0)
  {
    if (DeleteOldObjects) ObjectsDeleteAll();
    while (!FileIsEnding(fh))
    {
      pos=StringFind(str, "<td class=msdate>");
      if (pos>0)
      {
        str=str+GetStringFromFile(fh, 250-StringLen(str));
        str=StringSubstr(str, pos+17);
        dt =StrToTime(StringSubstr(str, 0, 16));
        str=StringSubstr(str, 25);
        pos=StringFind  (str, "</td><td>");
        op =StringSubstr(str, 0, pos);
        str=StringSubstr(str, pos+9);
        pos=StringFind  (str, "</td><td>");
        or =StrToInteger(StringSubstr(str, 0, pos));
        str=StringSubstr(str, pos+9);
        pos=StringFind  (str, "</td><td>");
        str=StringSubstr(str, pos+9);
        pos=StringFind  (str, "</td><td");
        pp =StrToDouble (StringSubstr(str, 0, pos));

        Comment("Позиция: "+or);
        switch (TypeObjects)
        {
          case 0: SetPropRectangle(dt, op, or, pp); break;
          default: SetPropLines(dt, op, or, pp); break;
        }
        if (ShowArrow) SetPropArrow(dt, op, or, pp);
        if (ShowTextBalance) SetPropText(dt, op, or, pp);
        
        str=str+GetStringFromFile(fh, 250-StringLen(str));
      } else {
        str=StringSubstr(str, 125);
        str=str+GetStringFromFile(fh, 125);
      }
    }
    FileClose(fh);
  } else Comment("Ошибка открытия файла отчёта "+FileName);
}

//+------------------------------------------------------------------+
//| Читает строковый блок из файла                                   |
//| Параметры:                                                       |
//|   fh - хэндл файла                                               |
//|   ks - количество символов                                       |
//+------------------------------------------------------------------+
string GetStringFromFile(int& fh, int ks)
{
  string str="", s;
  while (StringLen(str)<ks && !FileIsEnding(fh))
  {
    s=FileReadString(fh, 1);
    if (StringGetChar(s, 0)>31) str=str+s;
  }
  return(str);
}

//+------------------------------------------------------------------+
//| Установка свойств объекта УКАЗАТЕЛЬ                              |
//| Параметры:                                                       |
//|   dt - дата, время                                               |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   pp - цена                                                      |
//+------------------------------------------------------------------+
void SetPropArrow(datetime dt, string op, int or, double pp)
{
  string no="ADeal";

  if (op=="buy" || op=="sell")
  {
    if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_ARROW, 0, 0,0);
    ObjectSet(no+or, OBJPROP_TIME1, dt);
    if (op=="buy")
    {
      ObjectSet(no+or, OBJPROP_PRICE1   , pp+OffSetArrowBuy*Point);
      ObjectSet(no+or, OBJPROP_COLOR    , clArrowBuy);
      ObjectSet(no+or, OBJPROP_ARROWCODE, KodArrowBuy);
    }
    if (op=="sell")
    {
      ObjectSet(no+or, OBJPROP_PRICE1   , pp+OffSetArrowSell*Point);
      ObjectSet(no+or, OBJPROP_COLOR    , clArrowSell);
      ObjectSet(no+or, OBJPROP_ARROWCODE, KodArrowSell);
    }
  }
}

//+------------------------------------------------------------------+
//| Установка свойств объекта ЛИНИЯ ТРЕНДА                           |
//| Параметры:                                                       |
//|   dt - дата, время                                               |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   pp - цена                                                      |
//+------------------------------------------------------------------+
void SetPropLines(datetime dt, string op, int or, double pp)
{
  color  cl;
  double p1, p2;
  string no=frogNameObjLine;

  if (op=="buy" || op=="sell")
  {
    if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_TREND, 0, 0,0, 0,0);
    ObjectSet(no+or, OBJPROP_TIME1 , dt);
    ObjectSet(no+or, OBJPROP_PRICE1, pp);
  } else {
    ObjectSet(no+or, OBJPROP_TIME2 , dt);
    ObjectSet(no+or, OBJPROP_PRICE2, pp);
  }
  if (op=="buy") ObjectSet(no+or, OBJPROP_COLOR, clObjBuy);
  if (op=="sell") ObjectSet(no+or, OBJPROP_COLOR, clObjSell);
  ObjectSet(no+or, OBJPROP_RAY , False);

  p1=ObjectGet(no+or, OBJPROP_PRICE1);
  p2=ObjectGet(no+or, OBJPROP_PRICE2);
  cl=ObjectGet(no+or, OBJPROP_COLOR);
  if (p1!=0 && p2!=0)
  {
    if (cl==clObjBuy)
    {
      if (p1>p2) ObjectSet(no+or, OBJPROP_COLOR, clObjBuyLoss);
    }
    if (cl==clObjSell)
    {
      if (p1<p2) ObjectSet(no+or, OBJPROP_COLOR, clObjSellLoss);
    }
  }
}

//+------------------------------------------------------------------+
//| Установка свойств объекта ПРЯМОУГОЛЬНИК                          |
//| Параметры:                                                       |
//|   dt - дата, время                                               |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   pp - цена                                                      |
//+------------------------------------------------------------------+
void SetPropRectangle(datetime dt, string op, int or, double pp)
{
  color  cl;
  double p1, p2;
  string no=frogNameObjRect;

  if (op=="buy" || op=="sell")
  {
    if (ObjectFind(no+or)<0) ObjectCreate(no+or, OBJ_RECTANGLE, 0, 0,0, 0,0);
    ObjectSet(no+or, OBJPROP_TIME1 , dt);
    ObjectSet(no+or, OBJPROP_PRICE1, pp);
  } else {
    ObjectSet(no+or, OBJPROP_TIME2 , dt);
    ObjectSet(no+or, OBJPROP_PRICE2, pp);
  }
  if (op=="buy") ObjectSet(no+or, OBJPROP_COLOR, clObjBuy);
  if (op=="sell") ObjectSet(no+or, OBJPROP_COLOR, clObjSell);
  ObjectSet(no+or, OBJPROP_BACK , True);

  p1=ObjectGet(no+or, OBJPROP_PRICE1);
  p2=ObjectGet(no+or, OBJPROP_PRICE2);
  cl=ObjectGet(no+or, OBJPROP_COLOR);
  if (p1!=0 && p2!=0)
  {
    if (cl==clObjBuy)
    {
      if (p1>p2) ObjectSet(no+or, OBJPROP_COLOR, clObjBuyLoss);
    }
    if (cl==clObjSell)
    {
      if (p1<p2) ObjectSet(no+or, OBJPROP_COLOR, clObjSellLoss);
    }
  }
}

//+------------------------------------------------------------------+
//| Установка свойств объектов ТЕКСТ                                 |
//| Параметры:                                                       |
//|   dt - дата, время                                               |
//|   op - операция                                                  |
//|   or - номер ордера (объекта)                                    |
//|   pp - цена                                                      |
//+------------------------------------------------------------------+
void SetPropText(datetime dt, string op, int or, double pp)
{
  color  cl, clText;
  double p1, p2, ss;
  string no, no1="T1Deal", no2="T2Deal";

  if (TypeObjects==0) no=frogNameObjRect; else no=frogNameObjLine;

  p1=ObjectGet(no+or, OBJPROP_PRICE1);
  p2=ObjectGet(no+or, OBJPROP_PRICE2);
  cl=ObjectGet(no+or, OBJPROP_COLOR);

  if (p1!=0 && p2!=0)
  {
    if (ObjectFind(no1+or)<0) ObjectCreate(no1+or, OBJ_TEXT, 0, 0,0);
    if (ObjectFind(no2+or)<0) ObjectCreate(no2+or, OBJ_TEXT, 0, 0,0);
    ObjectSet(no1+or, OBJPROP_TIME1 , dt);
    ObjectSet(no2+or, OBJPROP_TIME1 , dt);
    ObjectSet(no1+or, OBJPROP_PRICE1, pp+OffSetText*Point);
    ObjectSet(no2+or, OBJPROP_PRICE1, pp-OffSetText*Point);
    if (cl==clObjBuy || cl==clObjBuyLoss)
    {
      ss=(p2-p1)/Point;
      frogBalance+=ss;
      if (ss<0) clText=clTextLoss; else clText=clTextProfit;
      ObjectSetText(no1+or, DoubleToStr(ss, 0), SizeText, "", clText);
      ObjectSetText(no2+or, DoubleToStr(frogBalance, 0), SizeText, "", clTextBalans);
    }
    if (cl==clObjSell || cl==clObjSellLoss)
    {
      ss=(p1-p2)/Point;
      frogBalance+=ss;
      if (ss<0) clText=clTextLoss; else clText=clTextProfit;
      ObjectSetText(no1+or, DoubleToStr(ss, 0), SizeText, "", clText);
      ObjectSetText(no2+or, DoubleToStr(frogBalance, 0), SizeText, "", clTextBalans);
    }
  }
}
//+------------------------------------------------------------------+

