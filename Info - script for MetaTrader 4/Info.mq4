//+------------------------------------------------------------------+
//|                                                         Info.mq4 |
//|                                      Copyright © 2008, EvgeTrofi |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, EvgeTrofi"

#include <WinUser32.mqh>

int start()
{
 if (!IsConnected())
 {
  MessageBox("Связь с сервером отсутствует или прервана\t","Внимание!",MB_OK|MB_ICONERROR);
  return(-1);
 }
 string str2;
 string str="Наименование\t\tКонстанта\t\tЗначение\tЕд.изм.\t\n\n";
 str=StringConcatenate(str,"Спред\t\t\tSPREAD\t\t\t",MarketInfo(Symbol(),MODE_SPREAD),"\t\tпунктов\t\n\n");
 str=StringConcatenate(str,"Мин. стоп\t\tSTOPLEVEL\t\t",MarketInfo(Symbol(),MODE_STOPLEVEL),"\t\tпунктов\t\n\n");
 str=StringConcatenate(str,"1 лот * 1 пункт =\t\tTICKVALUE\t\t",MarketInfo(Symbol(),MODE_TICKVALUE),"\t\t",AccountCurrency(),"\t\n\n");
 switch(MarketInfo(Symbol(),MODE_SWAPTYPE))
 {
  case 0:
   str2="пунктов";
   break;
  case 1:
   str2=Symbol();
   break;
  case 2:
   str2="%";
   break;
  case 3:
   str2=AccountCurrency();
   break;
 }
 str=StringConcatenate(str,"Своп покупки\t\tSWAPLONG\t\t",MarketInfo(Symbol(),MODE_SWAPLONG),"\t\t",str2,"\t\n\n");
 str=StringConcatenate(str,"Своп продажи\t\tSWAPSHORT\t\t",MarketInfo(Symbol(),MODE_SWAPSHORT),"\t\t",str2,"\t\n\n");
 str=StringConcatenate(str,"Минимальный лот\t\tMINLOT\t\t\t",MarketInfo(Symbol(),MODE_MINLOT),"\n\n");
 str=StringConcatenate(str,"Шаг лота\t\tLOTSTEP\t\t\t",MarketInfo(Symbol(),MODE_LOTSTEP),"\n\n");
 double MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
 if(MaxLot>AccountFreeMargin()*0.99/MarketInfo(Symbol(),MODE_MARGINREQUIRED))//где 0.99 - коэффициент запаса
    MaxLot=AccountFreeMargin()*0.99/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
 str=StringConcatenate(str,"Максимальный лот = AccountFreeMargin() / MARGINREQUIRED = ",MaxLot,"\n\n");
 str=StringConcatenate(str,"Лот на проигрыш 100 пунктов = AccountFreeMargin() / 100 / TICKVALUE = ",AccountFreeMargin()/100/MarketInfo(Symbol(),MODE_TICKVALUE),"\n\n");
 
 if(MarketInfo(Symbol(),MODE_TRADEALLOWED)==0)
  str2="запрещена";
 else
  str2="разрешена";
 str=StringConcatenate(str,"\nТорговля по инструменту ",Symbol()," ",str2,"\n\n");
 MessageBox(str,"Информация по инструменту "+Symbol(),MB_OK|MB_ICONINFORMATION);
 
 return(0);
}

VALUE = ",AccountFreeMargin()/100/MarketInfo(Symbol(),MODE_TICKVALUE),"\n\n");
 
 if(MarketInfo(Symbol(),MODE_TRADEALLOWED)==0)
  str2="запрещена";
 else
  str2="разрешена";
 str=StringConcatenate(str,"\nТорговля по инструменту ",Symbol()," ",str2,"\n\n");
 MessageBox(str,"Информация по инструменту "+Symbol()+" на "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),MB_OK|MB_ICONINFORMATION);
 
 return(0);
}


