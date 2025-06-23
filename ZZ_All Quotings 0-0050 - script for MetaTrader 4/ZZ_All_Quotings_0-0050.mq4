//+-----------------------------------------------------------------------------------------+
//|                                                               ZZ_All Quotings 0-0050.mq4|
//|                                                               Copyright © Zhunko        |
//|27.03.2007 - 09.05.2007                                        MF ZHUNKO zhunko@mail.ru  |
//+-----------------------------------------------------------------------------------------+
//| Скрипт для закачки истории по всем валютным парам и металлам.                           |
//| С поледующим контролем на "дыры" в истории.                                             |
//| В связи с функциональным расширением, скрипт "ZZ_All Quotings Exchange+Metals 0-0050"   |
//| переименован в "ZZ_All Quotings 0-0050".                                                |
//| Перед использованием скрипта установите в МТ4 сервис->настройки->графики->              |
//|нужное максимальное количество баров в окне. Именно это количество баров будет           |
//|загружаться и контролироваться. За тем перезагрузите МТ4 и воспользуйтесь скриптом.      |
//| Конец работы скрипта не означает конец загрузки истории. Процесс загрузки можете пос-   |
//|мотреть в диспетчере задач. По окончании загрузки истории необходимо перезагрузить МТ4   |
//|для её сохранения в файлах *.hst.                                                        |
//+-----------------------------------------------------------------------------------------+
//|                              ИЗМЕНЕНИЯ и ДОПОЛНЕНИЯ.                                    |
//| 1.Дополнения в версии ZZ_All Quotings Exchange+Metals 0-0020 от 28.03.2007.             |
//| 1.1.Изменён алгоритм опроса на наличие баров в истории.                                 |
//| 1.2.Полная информация о дефектных барах выводится в файлы.                              |
//|     Валютные пары : ZZ_All_Quotings_Exchange_InCorrect.txt;                             |
//|     Металлы: ZZ_All_Quotings_Metals_InCorrect.txt.                                      |
//| 2.Дополнения в версии ZZ_All Quotings Exchange+Metals 0-0030 от 31.03.2007.             |
//| 2.1.Изменён принцип контроля загрузки.                                                  |
//| 2.2.Введён визуальный контроль всех процессов.                                          |
//| 2.3.Введён полный контроль всей загруженной истории.                                    |
//| 2.4.В файл записываются только интервалы отсутствия баров.                              |
//| 3.Дополнения в версии ZZ_All Quotings Exchange+Metals 0-0040 от 31.03.2007.             |
//| 3.1.Введены диалоговые окна. Теперь можно подтвердить или отказаться от загрузки        |
//|     валютных пар, металлов и контроля дефектных интервалов истории.                     |
//| 4.Дополнения в версии ZZ_All Quotings Exchange+Metals 0-0050 от 06.05.2007.             |
//| 4.1.Устранена ошибка в создании файлов. Пустые файлы создавались при отказе от          |
//|     контроля на "дыры" в истории.                                                       |
//| 4.2.Увеличено количество групп инструментов. Включены все инструменты                   |
//|     "Alpari Ltd.", "Forex Best", "MoneyRein Corporation", "North Finance Company Ltd"   |
//|     и основные инструменты "North-West Financial Broker".                               |
//| 5.Дополнения в версии ZZ_All Quotings 0-0050 от 09.05.2007.                             |
//| 5.1.Всвязи с функциональным расширением скрипт "ZZ_All Quotings Exchange+Metals 0-0050" |
//|     в "ZZ_All Quotings 0-0050".                                                         |
//+-----------------------------------------------------------------------------------------+
#property copyright "Copyright © 2007 Zhunko"
#property link      "zhunko@mail.ru"
#include <WinUser32.mqh>
//----Глобальные переменные.------------------------------------------
datetime Market_Info, Mark_Inf, iTimeBegin, timetemp;
int      a, b, p, h, e, ee, g, i, j, jj, ii, pp;
//----Массивы.--------------------------------------------------------
int    ArrayTimFram_time[12] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200, 40320, 41760, 44640};
string ArrayCurrency[]     = {"AUD", "ALL", "ARS", "BRL", "BWP", "CAD", "CCK", "CHF", "CLP", "CNY", "COP", "CVE", "CYP", "CZK", "DKK", "DOP", "DZD", "EGP", "EUR", "GBP",
                              "GEL", "GIP", "HKD", "HRK", "HUF", "IDR", "IRR", "ILS", "INR", "ISK", "JPY", "KRW", "LBR", "LSL", "LTL", "LVL", "MAD", "MTL", "MXN", "MYR",
                              "NOK", "NPR", "NZD", "PHP", "PKR", "PLN", "QAR", "RUB", "RUR", "SAR", "SEK", "SGD", "SKK", "THB", "TND", "TRY", "TWD", "UAH", "USD", "XOF",
                              "ZAR", "ZMK"};
string ArrayMetals[]       = {"GOLD", "PALL", "PALLADIUM", "PLAT", "PLATINUM", "SILVER", "XAG", "XAU"};
string ArrayIndexes[]      = {// Обозначения "Alpari Ltd.".
                              "_C", "_DJI", "_DXY", "_ES", "_GC", "_NQ", "_NQ100", "_NQCOMP", "_QG", "_QM", "_S", "_SI", "_SP500", "_W",
                              // Обозначения "MoneyRein Corporation", "North-West Financial Broker".
                              "$ATX", "$BKBRIC", "$COMPQ", "$DAXI", "$FTSE", "$INDU", "$NDX", "$NIKKEI", "$NYA", "$OEX", "$QQQQ", "$SPX", "$TRAN",
                              // Обозначения "North Finance Company Ltd".
                              "DAX", "DJI", "NASDAQ", "S&P500"};
string ArrayCFD_Viena[]    = {// Обозначения "MoneyRein Corporation".
                              "BFC#", "BUD#", "BWIN#", "BWT#", "CNTY#", "COV#", "CWT#", "EBS#", "EYBL#", "FLU#", "HEAD#", "HVB#", "ICLL#", "IEA#", "KTM#", "LNZ#", "MEL#",
                              "MMK#", "OMV#", "PAL#", "RHI#", "RIBH#", "SBO#", "SEM#", "SNT#", "TKA#", "UQA#", "VER#", "VOE#", "WIE#", "WOL#" ,"WST#"};
string ArrayCFD_London[]   = {// Обозначения "MoneyRein Corporation".
                              "AAL#", "AIRC#", "ALS#", "AMEC#", "AMV#", "ANGL#", "ANTO#", "ADAD#", "AV.#", "AVE#", "AXA#", "AZN#", "BA.#", "BARC#", "BATS#", "BAY#", "BDEV#",
                              "BGEO#", "BLT#", "BP.#", "BT.A#", "CBRY#", "CCL#", "CHZN#", "CPG#", "CS#", "CW#", "DBK#", "DPO#", "EBID#", "EETD#", "ELXB#", "EMG#", "EMI#",
                              "EVR#", "FGP#", "FIVE#", "FP.#", "GAZ#", "GLH#", "GSK#", "HBOS#", "HCU#", "HMSO", "HNS#", "HOME#", "HSBA#", "HYUD#", "IMT#", "KZG#", "LGLD#",
                              "LKOD#", "LLOY#", "LSE#", "MKS#", "MNOD#", "MRW#", "NCU#", "NSTR#", "NVTK#", "OGZD#", "OML#", "PFD#", "PLZL#", "PRTY#", "PSON#", "RB.#",
                              "RBS#", "RDSA#", "REX#", "RKMD#", "RMM#", "ROSN#", "RR.#", "RTR#", "RYA#", "SBE#", "SBRY#", "SGGD#", "SMSN#", "SNKB#", "SPW#", "SSA#", "SVST#",
                              "TDE#", "THK#", "TPSD#", "TSCO#", "TTA#", "UESD#", "ULVR#", "UMB#", "VED#", "VKW#", "VOD#", "XTA#", "YELL#"};
string ArrayCFD_NewYork[]  = {// Обозначения "Alpari Ltd.", "North-West Financial Broker".
                              "#AA", "#AAPL", "#ABB", "#ABM", "#ABN", "#ADBE", "#AEP", "#AIG", "#AKH", "#AKZOY", "#AMAT", "#AMD", "#AMZN", "#ASD", "#AXP", "#BA", "#BAC",
                              "#BAYER", "#BC", "#BDK", "#BF", "#BGP", "#BK", "#BKS", "#BMY", "#BNG", "#BTM", "#C", "#CAJ", "#CAT", "#CC", "#CIA", "#CL_", "#CMX", "#COP",
                              "#CSCO", "#CSG", "#CSX", "#CTBK", "#CVS", "#CVX", "#CY", "#DA", "#DCX", "#DD", "#DELL", "#DIA", "#DIS", "#DLB", "#DWA", "#EBAY", "#EK", "#ELE",
                              "#EMC", "#EN", "#EWJ", "#F", "#FDC", "#FDX", "#FIA", "#FS", "#FTE", "#GE", "#GLDN", "#GLW", "#GM", "#GOOG", "#GS", "#GYMB", "#HAL", "#HD", "#HLF",
                              "#HLT", "#HMC", "#HON", "#HPQ", "#IBM", "#IBN", "#INTC", "#IP", "#IPG", "#JNJ", "#JPM", "#KEP", "#KFT", "#KO", "#KYO", "#LF", "#LMT", "#LOW",
                              "#LPL", "#LSI", "#LXK", "#LYG", "#NBT", "#MC", "#MCD", "#MGM", "#MKTAY", "#MMM", "#MO", "#MOT", "#MRK", "#MSFT", "#MT", "#MTL", "#MTU", "#MU",
                              "#MXWL", "#NEM", "#NEW", "#NKE", "#NOK", "#NOVL", "#NSANY", "#NVS", "#NYT", "#NZT", "#ORCL", "#PALM", "#PD", "#PDCO", "#PEP", "#PFE", "#PG",
                              "#PHG", "#PLA", "#PPG", "#PSO", "#PUB", "#Q", "#QQQ", "#RDS", "#RIO", "#ROS", "#ROST", "#RTI", "#S", "#SAP", "#SBUX", "#SGP", "#SHLD", "#SI",
                              "#SNDK", "#SNE", "#SNY", "#SPY", "#SUNW", "#SYMC", "#T", "#TCK", "#TDK", "#TEO", "#TLM", "#TM", "#TRB", "#TRCR", "#TSM", "#TTM", "#TWX", "#TXM",
                              "#UBS", "#UL", "#UTX", "#VIP", "#VRSN", "#VZ", "#WBD", "#WDC", "#WFC", "#WFMI", "#WMT", "#WYNN", "#XOM", "#XRX", "#YHOO",
                              // Обозначения "MoneyRein Corporation".
                              "AA#", "AAPL#", "ABB#", "ABM#", "ABN#", "ADBE#", "AEP#", "AIG#", "AKH#", "AKZOY#", "AMAT#", "AMD#", "AMZN#", "ASD#", "AXP#", "BA#", "BAC#",
                              "BAYER#", "BC#", "BDK#", "BF#", "BGP#", "BK#", "BKS#", "BMY#", "BNG#", "BTM#", "C#", "CAJ#", "CAT#", "CC#", "CIA#", "CL_#", "CMX#", "COP#",
                              "CSCO#", "CSG#", "CSX#", "CTBK#", "CVS#", "CVX#", "CY#", "DA#", "DCX#", "DD#", "DELL#", "DIA#", "DIS#", "DLB#", "DWA#", "EBAY#", "EK#", "ELE#",
                              "EMC#", "EN#", "EWJ#", "F#", "FDC#", "FDX#", "FIA#", "FS#", "FTE#", "GE#", "GLDN#", "GLW#", "GM#", "GOOG#", "GS#", "GYMB#", "HAL#", "HD#", "HLF#",
                              "HLT#", "HMC#", "HON#", "HPQ#", "IBM#", "IBN#", "INTC#", "IP#", "IPG#", "JNJ#", "JPM#", "KEP#", "KFT#", "KO#", "KYO#", "LF#", "LMT#", "LOW#",
                              "LPL#", "LSI#", "LXK#", "LYG#", "NBT#", "MC#", "MCD#", "MGM#", "MKTAY#", "MMM#", "MO#", "MOT#", "MRK#", "MSFT#", "MT#", "MTL#", "MTU#", "MU#",
                              "MXWL#", "NEM#", "NEW#", "NKE#", "NOK#", "NOVL#", "NSANY#", "NVS#", "NYT#", "NZT#", "ORCL#", "PALM#", "PD#", "PDCO#", "PEP#", "PFE#", "PG#",
                              "PHG#", "PLA#", "PPG#", "PSO#", "PUB#", "Q#", "QQQ#", "RDS#", "RIO#", "ROS#", "ROST#", "RTI#", "S#", "SAP#", "SBUX#", "SGP#", "SHLD#", "SI#",
                              "SNDK#", "SNE#", "SNY#", "SPY#", "SUNW#", "SYMC#", "T#", "TCK#", "TDK#", "TEO#", "TLM#", "TM#", "TRB#", "TRCR#", "TSM#", "TTM#", "TWX#", "TXM#",
                              "UBS#", "UL#", "UTX#", "VIP#", "VRSN#", "VZ#", "WBD#", "WDC#", "WFC#", "WFMI#", "WMT#", "WYNN#", "XOM#", "XRX#", "YHOO#"};
string ArrayCFD_Tokyo[]    = {// Обозначения "MoneyRein Corporation".
                              "4901", "4902", "4911", "5016", "5108", "5401", "6367", "6473", "6502", "6701", "6703", "6752", "6758", "6762", "6764", "6773", "6796", "6952",
                              "6971", "7012", "7201", "7202", "7203", "7261", "7267", "7269", "7731", "7733", "7751", "7752", "7762", "7951", "8031", "9205", "9532", "9984"};
string ArrayCFD_Moscow[]   = {// Обозначения "MoneyRein Corporation".
                              "AFLT#", "AVAZ#", "CHMF#", "EESR#", "GAZP#", "GMKN#", "LKOH#", "MSNG#", "MTSS#", "NLMK#", "NNSI#", "NTMK#", "RBCI#", "RTKM#", "SBER#", "SIBN#",
                              "SNGS#", "TATN#", "VRSI#"};
string ArrayCFD_RU[]       = {// Обозначения "Forex Best".
                              "AFLRUR", "AVTRUR", "EEPRUR", "EESRUR", "GAZRUR", "GMKRUR", "IRKRUR", "LBDRUR", "LKORUR", "MMKRUR", "MSNRUR", "MTSRUR", "OG3RUR", "MG5RUR",
                              "PLZRUR", "RBCRUR", "RSNRUR", "RTKRUR", "RTPRUR", "SBERUR", "SBPRUR", "SIBRUR", "SNGRUR", "SNPRUR", "SPTRUR", "STKRUR", "SVARUR", "TAPRUR",
                              "TATRUR", "UAZRUR", "UTARUR", "VTLRUR", "YENRUR"};
string ArrayCFD_ForexBest[]= {// Обозначения "Forex Best".
                              "BO", "BP", "C" ,"CA", "CC", "CF", "CL", "CP", "CT", "DA", "DF", "DX", "ED", "EEU", "ENQ", "EP", "ER", "EU", "FC", "FF", "GC", "HO", "HU", "JY",
                              "LB", "LC", "LH", "MA", "MX", "ND", "NE", "NG", "NKD", "NQG", "NQM", "O", "OJ", "PA", "PB", "PL", "RC", "S", "SF", "SI", "SM", "SP", "SU", "W",
                              "Y5", "YG", "YI", "YM", "ZI", "ZO"};
string ArrayName1[12]      = {"ВАЛЮТНЫХ ПАР", "ВАЛЮТНЫХ ПАР PROF", "ВАЛЮТНЫХ ПАР MINI", "МЕТАЛЛОВ", "INDEXES", "CFD VIENA", "CFD LONDON", "CFD NEW YORK", "CFD TOKYO", "CFD MOSCOW", "CFD RU", "CFD FOREX BEST"};
string ArrayName2[12]      = {"валютных пар", "валютных пар Prof", "валютных пар Mini", "металлов", "Indexes", "CFD Viena", "CFD London", "CFD New York", "CFD Tokyo", "CFD Moscow", "CFD RU", "CFD Forex Best"};
string ArrayNameFile[12]   = {"Exchange", "ExchangeProf", "ExchangeMini", "Metals", "Indexes", "CFD_Viena", "CFD_London", "CFD_NewYork", "CFD_Tokyo", "CFD_Moscow", "CFD_RU", "CFD_ForexBest"};
string ArrayTimfram_str[9] = {"M1 ", "M5 ", "M15", "M30", "H1 ", "H4 ", "D1 ", "W1 ", "MN1"};
string ArrayInCorrect[100000000];
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
  {
   int      QuestExch   = IDYES;
   int      QuestCheck  = IDYES;
   int      size;
//----
   datetime time[];
   int      Array_Size[9];
   int      Array_Differ[9];
   string   ArrayExchange[500];
   string   ArrayExchangeProf[500];
   string   ArrayExchangeMini[500];
   string   ArrayTools[9][500];
   string   Info[9];
// Создаём массив с названием валютных пар в зависимости от наличия этих пар у брокера.
   i = -1;
   j = -1;
   Array_Size[0] = ArraySize (ArrayCurrency);
   for(a = 0; a < Array_Size[0]; a++) // Для валютных пар.
       for(b = 0; b < Array_Size[0]; b++)
         {
           Market_Info = MarketInfo(ArrayCurrency[a] + ArrayCurrency[b], MODE_TIME);
           if(ArrayCurrency[a] != ArrayCurrency[b] && Market_Info != 0)
             {
               i++; // Счётчик реального количества инструментов.
               ArrayExchange[i] = ArrayCurrency[a] + ArrayCurrency[b];
               if(AccountCompany() == "MoneyRein Corporation")
                 {
                   j++; // Счётчик реального количества инструментов.
                   ArrayExchangeProf[j] = ArrayCurrency[a] + ArrayCurrency[b] + "prof";
                   ArrayExchangeMini[j] = ArrayCurrency[a] + ArrayCurrency[b] + "mini";
                 }
             }
         }
// Определяем размер массивов.
   Array_Size[0]  = i + 1;
   Array_Size[1]  = j + 1;
   Array_Size[2]  = j + 1;
   Array_Size[3]  = ArraySize(ArrayMetals);
   Array_Size[4]  = ArraySize(ArrayIndexes);
   Array_Size[5]  = ArraySize(ArrayCFD_Viena);
   Array_Size[6]  = ArraySize(ArrayCFD_London);
   Array_Size[7]  = ArraySize(ArrayCFD_NewYork);
   Array_Size[8]  = ArraySize(ArrayCFD_Tokyo);
   Array_Size[9]  = ArraySize(ArrayCFD_Moscow);
   Array_Size[10] = ArraySize(ArrayCFD_RU);
   Array_Size[11] = ArraySize(ArrayCFD_ForexBest);
// Создаём двумерный массив с инструментами.
   for(i = 0; i < Array_Size[0] ; i++) 
       ArrayTools[0][i] = ArrayExchange[i];
   for(i = 0; i < Array_Size[1] ; i++) 
       ArrayTools[1][i] = ArrayExchangeProf[i];
   for(i = 0; i < Array_Size[2] ; i++) 
       ArrayTools[2][i] = ArrayExchangeMini[i];
   for(i = 0; i < Array_Size[3] ; i++) 
       ArrayTools[3][i] = ArrayMetals[i];
   for(i = 0; i < Array_Size[4] ; i++) 
       ArrayTools[4][i] = ArrayIndexes[i];
   for(i = 0; i < Array_Size[5] ; i++) 
       ArrayTools[5][i] = ArrayCFD_Viena[i];
   for(i = 0; i < Array_Size[6] ; i++) 
       ArrayTools[6][i] = ArrayCFD_London[i];
   for(i = 0; i < Array_Size[7] ; i++) 
       ArrayTools[7][i] = ArrayCFD_NewYork[i];
   for(i = 0; i < Array_Size[8] ; i++) 
       ArrayTools[8][i] = ArrayCFD_Tokyo[i];
   for(i = 0; i < Array_Size[9] ; i++) 
       ArrayTools[9][i] = ArrayCFD_Moscow[i];
   for(i = 0; i < Array_Size[10]; i++) 
       ArrayTools[10][i] = ArrayCFD_RU[i];
   for(i = 0; i < Array_Size[11]; i++) 
       ArrayTools[11][i] = ArrayCFD_ForexBest[i];
// Определяем количество ТФ в каждой группе инструментов.
   for(i = 0; i <= 11; i++) 
       Array_Differ[i] = 9 * Array_Size[i];  
// Начинаем подкачку истории.
   for(g = 0; g <= 11; g++)
     {
       // Вопрос пользователю о загрузке истории группы инструментов. 
       // Загружать/не загружать.
       QuestExch = MessageBox ("Загружаем историю " + ArrayName2[g] + 
                               "?", "История " + ArrayName2[g], 
                               MB_YESNO|MB_ICONQUESTION);
       //----
       if(QuestExch == IDYES)
         {
           // Инициализируем переменные.
           e = 1; ee = 0; j = 0; jj = 0; ii = 0; pp = 0; 
           // Вопрос пользователю об контроле на "дыры" в истории. 
           // Конторолировать/не контролировать.
           QuestCheck = MessageBox ("Проводить контроль загруженной истории\n" + 
                                    ArrayName2[g] + " на дефектные интервалы (дыры)?", 
                                    "Конроль истории увеличивает время работы скрипта!",
                                    MB_YESNO|MB_ICONQUESTION);
           for(a = 0; a < Array_Size[g]; a++) // Для металлов.
             {
               ii++; // Счётчик возможного количества инструментов.
               Market_Info = MarketInfo (ArrayTools[g][a], MODE_TIME);
               if(Market_Info != 0)
                 {
                   j++; // Счётчик реального количества инструментов.
                   for(p = 0; p <= 8; p++)
                     {
                       pp++; // Счётчик общего количества ТФ.
                       Mark_Inf = Market_Info - 60 * ArrayTimFram_time[p];
                       iTimeBegin = iTime(ArrayTools[g][a], ArrayTimFram_time[p], 0);
                       while(Mark_Inf < iTimeBegin)
                         {
                           jj++; // Счётчик ожиданий последнего бара.
                           size = ArrayCopySeries(time, MODE_TIME, ArrayTools[g][a], 
                                                  ArrayTimFram_time[p]);
                           if(GetLastError() == 0) 
                               break;
                           // Если остановка, создаём срочно файл *.dat .
                           if(IsStopped() == true && QuestCheck == IDYES) 
                             {
                               ArrayInCorrect[e] = "===============================" + 
                                                   "=================";
                               ArrayInCorrect[e + 1] = "Дата завершения контроля " + 
                                                       TimeToStr(TimeLocal(), 
                                                       TIME_DATE|TIME_SECONDS);
                               ArrayInCorrect[e + 2] = "Произведено принудительное" + 
                                                       " завершения контроля.";
                               FileCreate_ArrayString ("ZZ_All_Quotings_" + 
                                                       ArrayNameFile[g] + 
                                                       "_InCorrect.dat", ArrayInCorrect, 
                                                       0, e + 3, 0, SEEK_SET);
                               return;
                             }
                         }
                       // Если пользователь ответил "YES" производим контроль истории 
                       // на "дыры".
                       if(QuestCheck == IDYES) 
                         {
                           for(h = 0; h < size - 1; h++)
                             {
                               timetemp = (time[h] - time[h + 1]) / 60;
                               if((ArrayTimFram_time[p] != ArrayTimFram_time[7] && 
                                  ArrayTimFram_time[p] != ArrayTimFram_time[8] && 
                                  timetemp != ArrayTimFram_time[p] && 
                                  TimeDayOfWeek (time[h]) != 1 && 
                                  TimeDayOfWeek (time[h + 1]) != 5) ||
                                  (ArrayTimFram_time[p] == ArrayTimFram_time[7] && 
                                  timetemp != ArrayTimFram_time[7]) ||
                                  (ArrayTimFram_time[p] == ArrayTimFram_time[8] && 
                                  (((TimeMonth (time[h + 1]) == 1 || 
                                  TimeMonth (time[h + 1]) == 3 || 
                                  TimeMonth (time[h + 1]) == 5 || 
                                  TimeMonth (time[h + 1]) == 7 || 
                                  TimeMonth (time[h + 1]) == 8 || 
                                  TimeMonth (time[h + 1]) == 10 || 
                                  TimeMonth (time[h + 1]) == 12) && 
                                  timetemp != ArrayTimFram_time[11]) ||
                                  ((TimeMonth (time[h + 1]) == 4 || 
                                  TimeMonth (time[h + 1]) == 6 || 
                                  TimeMonth (time[h + 1]) == 9 || 
                                  TimeMonth (time[h + 1]) == 11) && 
                                  timetemp != ArrayTimFram_time[8]) ||
                                  ((MathMod (TimeYear (time[h + 1]), 4) == 0 && 
                                  TimeMonth (time[h + 1]) == 2 && 
                                  timetemp != ArrayTimFram_time[10]) || 
                                  (MathMod (TimeYear (time[h + 1]), 4) != 0 && 
                                  TimeMonth (time[h + 1]) == 2 && 
                                  timetemp != ArrayTimFram_time[9])))))
                                 {
                                   if(j != ee)
                                     {
                                       ArrayInCorrect[0] = "Дата начала контроля " + 
                                                           TimeToStr(TimeLocal(), 
                                                           TIME_DATE|TIME_SECONDS);
                                       if(j < 10)  
                                           ArrayInCorrect[e] = " " + j + 
                                                               ".====================" + 
                                                               ArrayTools[g][a] + 
                                                               "=====================";
                                       if(j >= 10) 
                                           ArrayInCorrect[e] = j + ".====================" + 
                                                               ArrayTools[g][a] + 
                                                               "=====================";
                                       ee = j;
                                       e++;
                                     }
                                   ArrayInCorrect[e] = ArrayTools[g][a] + "_" + 
                                                       ArrayTimfram_str[p] + " <" + 
                                                       TimeToStr (time[h + 1], 
                                                       TIME_DATE|TIME_MINUTES) + ">=<" + 
                                                       TimeToStr (time[h], 
                                                       TIME_DATE|TIME_MINUTES) + ">";
                                   e++;
                                 }
                               Comment("ЗАГРУЗКА ", ArrayName1[g],
                                       "\nЗагружено: ", 100 * (9 * ii - 8 + p) / 
                                       Array_Differ[g], " %",
                                       "\nИнструмент: ", "№ ", j, ". ", ArrayTools[g][a],
                                       "\nТаймфрейм: ", ArrayTimfram_str[p],
                                       "\nБаров в ТФ: ", size,
                                       "\nКонтроль истории = ", h,
                                       "\nДефектных интервалов = ", e); 
                             } 
                         }
                       else
                         {
                           Comment("ЗАГРУЗКА ", ArrayName1[g],
                                   "\nЗагружено: ", 100 * (9 * ii - 8 + p) / 
                                   Array_Differ[g], " %",
                                   "\nИнструмент: ", "№ ", j, ". ", ArrayTools[g][a],
                                   "\nТаймфрейм: ", ArrayTimfram_str[p],
                                   "\nБаров в ТФ: ", size); 
                         }
                     }
                 }
             }
           if(QuestCheck == IDYES)
             {
               ArrayInCorrect[e + 1] = "=========================================" + 
                                       "==========\nДата завершения контроля " + 
                                       TimeToStr(TimeLocal(), TIME_DATE|TIME_SECONDS);
               FileCreate_ArrayString("ZZ_All_Quotings_" + ArrayNameFile[g] + 
                                      "_InCorrect.txt", ArrayInCorrect, 0, e, 0, SEEK_SET);
             }
           if(j != 0 && QuestCheck == IDYES) 
               Info[g] = StringConcatenate ("\nСчётчик циклов подбора ", ArrayName2[g], 
                                            " = ", ii,
                                            "\nКоличество ", ArrayName2[g], 
                                            " в ОБЗОРЕ РЫНКА  = ", j,
                                            "\nСчётчик циклов ТФ ", ArrayName2[g], 
                                            " = ", pp,
                                            "\nСчётчик ожиданий последнего бара ", 
                                            ArrayName2[g], " = ", jj,
                                            "\nДефектных интервалов ", ArrayName2[g], 
                                            " = ", e - j - 1,
                                            "\nФайл с дефектными интервалами: ..." + 
                                            "MetaTrader 4.00\experts\files\ZZ_All_Quotings_", 
                                            ArrayNameFile[1], "_InCorrect.txt\n");
           else 
               Info[g] = "";
           //----
           if(j != 0 && QuestCheck == IDNO)  
               Info[g] = StringConcatenate ("\nСчётчик циклов подбора ", ArrayName2[g], 
                                            " = ", ii,
                                            "\nКоличество ", ArrayName2[g], 
                                            " в ОБЗОРЕ РЫНКА  = ", j,
                                            "\nСчётчик циклов ТФ ", ArrayName2[g], " = ", pp,
                                            "\nСчётчик ожиданий последнего бара ", 
                                            ArrayName2[g], " = ", jj, "\n");
           else 
               Info[g] = "";       
         }
     }
//----
   Comment(Info[0], Info[1], Info[2], Info[3], Info[4], Info[5], Info[6], Info[7], Info[8]);
   return;
  }
//+------------------------------------------------------------------+
//| Функция "Создать файл массива со строковыми данными".            |
//| // (название файла; массив для записи; начальный индекс в        |
//| массиве; количество элементов для чтения; смещение в байтах;     |
//| начальное положение файлового указателя)                         |
//+------------------------------------------------------------------+
int FileCreate_ArrayString(string Name, string Array[], int start, int count, 
                           int offset, int origin)  
  {
   bool   BL;
   int    Bool;
   int    handle;
//----
   handle = FileOpen(Name, FILE_BIN|FILE_WRITE, ';');
//----
   if(handle == -1)
     {
       Print("Файл ", Name, " не создан, последняя ошибка : ", GetLastError());
       Bool = -1;
       return(false);
     }
   else
     {
       BL = FileSeek(handle, offset, origin);
       Bool = FileWriteArray(handle, Array, start, count);
       if(BL == false) 
           Print("Файловый указатель файла ",  Name, " не смещён, последняя ошибка : ", 
                 GetLastError());
       if(Bool == -1) 
           Print("Значение в файл ", Name, " не записано, последняя ошибка : ", 
                 GetLastError());
       FileClose (handle);
    }
   return(Bool);
  }
//+------------------------------------------------------------------+

