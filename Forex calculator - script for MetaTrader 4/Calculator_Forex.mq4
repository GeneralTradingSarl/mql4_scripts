//+------------------------------------------------------------------+
//|                                             Calculator_Forex.mq4 |
//|                                          Copyright © 2007, DRKNN |
//|                                                    drknn@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, DRKNN"
#property link      "drknn@mail.ru"

#property show_inputs
extern double  Depozit=0.0;//каким количеством капитала будем рисковать
extern double  Risk=3.0;//каким количеством капитала будем рисковать
extern string  t11="------- Для рассчёта стоп-лосса по лоту --------";
extern double  Lot=0.2;//с каким лотом будем открывать позицию. 
extern string  t1="------- Для рассчёта лота по стоп-лоссу --------";
extern double  StopLoss=15.0;

/*
   формула рассчёта максимального стоп-лосса для указанного пользователем лота:
   SL_PNT=normRisk*normDepozit/PointPrise/Lot; 
*/


//+------------------------------------------------------------------+
//|                 Начало работы скрипта                            |
//+------------------------------------------------------------------+
int start()
  {
   string SMB=Symbol();
   double normRisk=0;//содержит нормализованный риск
   double SL_PNT=0;//стоп-лосс в пунктах
   double MinLot=MarketInfo(SMB,MODE_MINLOT);//минимальный размер лота        
   double MaxLot=MarketInfo(SMB,MODE_MAXLOT);//максимальный размер лота
   double ryn_Lot=0;//рассчитываемый лот для указнааного пользователем стоп-лосса
   double LotStep=MarketInfo(SMB,MODE_LOTSTEP);//шаг изменения лота
   double normDepozit=0;
   int    TipInstrumenta=10000;
   double PointPrise=0;
   string SMB1,SMB2;
   double BazCours=0;// курс базовой валюты по отношению к доллару
   double ryn_PointPrise=0;//стоимость пункта при минимальном лоте
   double ryn_SL=0;//стоп-лосс для минимального лота
   int    MinLevel=MarketInfo(SMB,MODE_STOPLEVEL);//Минимально допустимый уровень стоп-лосса (тейк-профита) в пунктах
   string t1="=============================";
   
   
   

   
   
   //------------------------------------------------------------------------------------------------------------------------
   Alert (t1);
   //-------- Защита от дурака ----------------------
   
   if(Risk<=0){
      Alert(" Ошибка! Risk должен быть больше нуля.");
      return(0);
   }
   if(Lot<MinLot){
      Alert(" Ошибка! Lot не должен быть меньше ",MinLot);
      return(0);
   }
   if(Lot>MaxLot){
      Alert(" Ошибка! Lot не должен быть больше ",MaxLot);
      return(0);
   }
   
   if(StopLoss<MinLevel){
     Alert(" Ошибка! StopLoss не должен быть меньше ",MinLevel," пунктов");
     return(0);
   }
   if(Lot>=MinLot && Risk!=0 && StopLoss>=MinLevel){
   
   //------ нормализуем депозит ------------
   if(Depozit==0){
     normDepozit=AccountBalance();//Баланс счёта
   }
   if(Depozit>0){
     normDepozit=Depozit; 
   }
   //------ нормализуем процент риска ------------
   normRisk=Risk/100;
   // ------- смотрим, Risk," процентов от депозита это сколько в центах -----------------
   double normRiskPersent=NormalizeDouble(normDepozit*normRisk,2);
   
   // --------- вычисляем какая пара (прямая, обратная, кросс) --------------
   TipInstrumenta=StringFind( SMB,"USD",0); 
   
   //------ извлекаем имя первой валютной пары ------------
   SMB1=StringSubstr(SMB,0,3); //базовая валюта
   //SMB2=StringSubstr(SMB,3,3);// валюта котирования.
   
   // ------- текущая котировка базовой валюты к доллару США -------------
   BazCours=MarketInfo(SMB1+"USD",MODE_BID);
   //Alert("Tекущая котировка базовой валюты к доллару США = ",BazCours);
   
   
   
   // --------- рассчитываем стоимость пункта -------------------------
   if(TipInstrumenta==3){//пара прямая, напр. EurUsd
     PointPrise=1000000*Lot/10*Point;
     ryn_PointPrise=1000000*MinLot/10*Point;//стоимость пункта при минимальном лоте
   }
   if(TipInstrumenta==0){//пара обратная, напр. UsdJpy
     PointPrise=1000000*Lot/10*Point/Bid;
     ryn_PointPrise=1000000*MinLot/10*Point/Bid;//стоимость пункта при минимальном лоте
   }
   if(TipInstrumenta==-1){//Кросс-пара, напр EurJpy
     PointPrise=1000000*Lot/10*Point*BazCours/Bid;
     ryn_PointPrise=1000000*MinLot/10*Point*BazCours/Bid;
   }
   // ----- нормализуем полученную стоимость пункта ------
   PointPrise=NormalizeDouble(PointPrise,2);
   ryn_PointPrise=NormalizeDouble(ryn_PointPrise,2);
   
   // ========== вычисляем максимальный стоп-лосс для указанного пользователем лота =========================================
   
   //------ смотрим, сколько раз минимальный лот укладывается в пользовательском -------------
   double iMinLot=MinLot;
   int    SchLots=0;//сколько минимальных лотов укладывается в пользовательском
   
   if(Lot==MinLot){SchLots=1;}
   else if(Lot>MinLot){
     while(iMinLot<Lot){
       iMinLot=iMinLot+LotStep;
       SchLots++;
     }
   }  
   //теперь вычисляем уровень стоп-лосса
   SL_PNT=normRisk*normDepozit/PointPrise/SchLots;
   SL_PNT=NormalizeDouble(SL_PNT,0);
   
  
   
   
   // ========== вычисляем максимальный лот для указанного пользователем стоп-лосса =========================================
   
   // ----- смотрим, какой стоп-лосс получится при минимальном лоте -------------
   double jj=1;
   ryn_SL=normRisk*normDepozit/ryn_PointPrise/jj;
   ryn_SL=NormalizeDouble(ryn_SL,0);
   // ----- смотрим, сколько раз пользовательский стоп-лосс умещается в стоп-лоссе минимального лота
   int    SchSL=0;//сколько пользовательских стоп-лоссов умещается в максимальном стоп-лоссе при минимальном лоте
   
   if(StopLoss==ryn_SL){SchSL=1;}
   else if(StopLoss<ryn_SL){
     double iStopLoss=StopLoss;
     while(iStopLoss<ryn_SL){
       iStopLoss=iStopLoss+iStopLoss;
       SchSL++;
     }
   }  
   //----- теперь просчитываем искомый лот -------------
   ryn_Lot=SchSL*MinLot;
   
   
   
   
   // ------------ выводим результаты ----------------
   Alert("Минимально допустимый уровень стоп-лосса = ",MinLevel," пунктов");
   Alert("Стоимость пункта при минимальном ",MinLot," лоте = ",ryn_PointPrise," $");
   Alert("Стоимость пункта при лоте ",Lot," = ",PointPrise," $");
   Alert(Risk," процентов от депозита = ",normRiskPersent," $");
   Alert("Денег на счету = ",normDepozit," $");
   Alert("--------");
   Alert("Максимальный лот = ",ryn_Lot);
   Alert(SMB,"  Рассчёт лота для стоп-лосса = ",StopLoss," пунктов :");
   Alert("--------");
   Alert("Максимальный стоп-лосс = ",SL_PNT," пунктов");
   Alert(SMB,"  Рассчёт стоп-лосса для лота = ",Lot," :");
   Alert (t1);
  }
  
   return(0);
  }
//+------------------------------------------------------------------+
//|                 Конец работы скрипта                             |
//+------------------------------------------------------------------+