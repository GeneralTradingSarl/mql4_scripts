//+------------------------------------------------------------------+
//|                                   ytg_Lewel without the loss.mq4 |
//|                                                     YURIY TOKMAN |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "YURIY TOKMAN"
#property link      "yuriytokman@gmail.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----+
  GetDell("label");
  string char[256]; int i;
  for (i = 0; i < 256; i++) char[i] = CharToStr(i);
  string txt =  char[70]+char[97]+char[99]+char[116]+char[111]+char[114]+char[121]+char[32]
  +char[111]+char[102]+char[32]+char[116]+char[104]+char[101]+char[32]+char[97]
  +char[100]+char[118]+char[105]+char[115]+char[101]+char[114]+char[115]+char[58]
  +char[32]+char[121]+char[117]+char[114]+char[105]+char[121]+char[116]+char[111]
  +char[107]+char[109]+char[97]+char[110]+char[64]+char[103]+char[109]+char[97]
  +char[105]+char[108]+char[46]+char[99]+char[111]+char[109];Label("label",txt,2,3,15);
//----+
   GetDell("ytg_s");
   double lots=0;
   double sum=0;
   for (i=0; i<OrdersTotal(); i++)
   {
      if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if (OrderSymbol()!=Symbol()) continue;
      if (OrderType()==OP_BUY)
      {
       lots=lots+OrderLots();
       sum=sum+OrderLots()*OrderOpenPrice();
      }
      if (OrderType()==OP_SELL)
      {
       lots=lots-OrderLots();
       sum=sum-OrderLots()*OrderOpenPrice();
      }
   }
   double price=0;
   if (lots!=0) price=sum/lots;
   string lossfree=" Does not exist";
   if (price>0) lossfree=" = "+DoubleToStr(price,Digits);
   string msg="Level without loss for "+Symbol()+lossfree+"     ";
   string line_name = "ytg_s  " + TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);     
   SetHLine(Aqua,line_name,price);   
   Alert(msg);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Функция создаёт горизонтальную линию                             |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+
void SetHLine(color cl, string nm="", double p1=0, int st=0, int wd=1) 
 {
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_HLINE, 0, 0,0);
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSet(nm, OBJPROP_COLOR , cl);
  ObjectSet(nm, OBJPROP_STYLE , st);
  ObjectSet(nm, OBJPROP_WIDTH , wd);
 }
//+------------------------------------------------------------------+
//| Функция удаляет объекты с указанным именем                       |
//| автор: Юрий Токмань                                              |
//| e-mail: yuriytokman@gmail.com                                    |
//| ICQ#    481-971-287                                              |
//| Skype:  yuriy.g.t                                                |
//+------------------------------------------------------------------+ 
void GetDell( string name)
 {
  string vName;
  for(int i=ObjectsTotal()-1; i>=0;i--)
   {
    vName = ObjectName(i);
    if (StringFind(vName,name) !=-1) ObjectDelete(vName);
   }
 }
//+----------------------------------------------------------------------+
//| Описание: Создание текстовой метки                                   | 
//| Автор:    Юрий Токмань                                               |
//| e-mail:   yuriytokman@gmail.com                                      |
//+----------------------------------------------------------------------+
 void Label(string name_label,           //Имя объекта.
            string text_label,           //Текст обьекта. 
            int corner = 2,              //Hомер угла привязки 
            int x = 3,                   //Pасстояние X-координаты в пикселях 
            int y = 15,                  //Pасстояние Y-координаты в пикселях 
            int font_size = 10,          //Размер шрифта в пунктах.
            string font_name = "Arial",  //Наименование шрифта.
            color text_color = LimeGreen //Цвет текста.
           )
  {
   if (ObjectFind(name_label)!=-1) ObjectDelete(name_label);
       ObjectCreate(name_label,OBJ_LABEL,0,0,0,0,0);         
       ObjectSet(name_label,OBJPROP_CORNER,corner);
       ObjectSet(name_label,OBJPROP_XDISTANCE,x);
       ObjectSet(name_label,OBJPROP_YDISTANCE,y);
       ObjectSetText(name_label,text_label,font_size,font_name,text_color);
  }