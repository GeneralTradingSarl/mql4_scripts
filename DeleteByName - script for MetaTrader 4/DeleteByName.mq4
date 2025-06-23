//+------------------------------------------------------------------+
//|                                              DeleteByPreName.mq4 |
//|                                                      Денис Орлов |
//|                                    http://denis-or-love.narod.ru |
//|Clears the chart of all objects with the name beginning on the specified prefix
//|Для быстрой очистки графика от объектов по началу их имени        |
//+------------------------------------------------------------------+
#property copyright "Денис Орлов"
#property link      "http://denis-or-love.narod.ru"


#property show_inputs

extern string PreName ="напечатайте префикс";
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int k=ObjectsTotal()-1; k>=0; k--)  // По количеству всех объектов 
     {
      string Obj_Name=ObjectName(k);   // Запрашиваем имя объекта
      string Head=StringSubstr(Obj_Name,0,StringLen(PreName));// Извлекаем первые сим

      if (Head==PreName)// Найден объект, ..
         {
         ObjectDelete(Obj_Name);
         //Alert(Head+";"+Prefix);
         }                  
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+