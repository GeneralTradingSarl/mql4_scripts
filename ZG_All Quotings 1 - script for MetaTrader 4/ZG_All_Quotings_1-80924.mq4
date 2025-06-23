//+----------------------------------------------------------------------------------+
//|                                                       ZG_All Quotings 1-80924.mq4|
//|24.09.2008                                             Copyright © Zhunko, getch  |
//+----------------------------------------------------------------------------------+
//| Скрипт создан на базе скрипта "Market Watch" от getch.                           |
//| Выражаю своё восхищение нестандартному подходу getch.                            |
//|                                                              Zhunko              |
//+----------------------------------------------------------------------------------+
//| Сканирование всех ТФ с обновлением окон открытых графиков, запись в файл названий|
//|и торговых условий всех символов из окна "Обзор рынка". Такиим образом скрипт     |
//|подкачивает историю по всем инструментам терминала самым "жёстким" способом.      |
//| Если при этом способе подкачки история не приходит, то это проблема со стороны   |
//|сервера брокера.                                                                  |
//+----------------------------------------------------------------------------------+
//|       !!! ВО ВРЕМЯ РАБОТЫ СКРИПТА НЕ ПРОИЗВОДИТЬ ДЕЙСТВИЙ В ТЕРМИНАЛЕ!!!         |
//+----------------------------------------------------------------------------------+
#property copyright "Copyright © Zhunko, getch"
#property link      "http://forum.mql4.com/ru/11241/page3"
//----
#import "user32.dll"
  int GetParent (int hWnd );
  int GetDlgItem (int hDlg, int nIDDlgItem);
  int SendMessageA (int hWnd, int Msg, int wParam, int lParam);
  int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import
//----
#define IDCANCEL         2
#define IDYES            6
#define IDNO             7 
#define MB_YESNOCANCEL   0x00000003
#define MB_ICONQUESTION  0x00000020
#define LVM_GETITEMCOUNT 0x1004
#define VK_HOME          0x24
#define VK_DOWN          0x28
#define WM_CLOSE         0x0010
#define WM_COMMAND       0x0111
#define WM_KEYDOWN       0x0100
#define NAME_SCRIPT      "GZ_All Quotings 1-80924"
//----
string FileName = "MarketWatch"; // Имя файла для записи информации по символам.
int    Pause = 500;              // Техническая пауза в миллисекундах.
//===================================================================================
void start()
 {
  int Count;
  int handle;
  int HandleChart;
  int i, j;
  int Question;
  //----
  int Instructions[8] = {33136, 33134, 33141, 33334, 33137, 33138, 33139, 33140};
  //----
  if (GlobalVariableCheck ("glSymbolHandle") == true)  // Запустили не первый раз.
   {
    GlobalVariableSet ("glSymbolHandle", WindowHandle (Symbol(), Period()));
    if (GlobalVariableGet ("glFileWrite") == IDYES) WriteSymbolTXT (FileName);
    if (GlobalVariableGet ("glFileWrite") == IDNO) WriteSymbolCSV (FileName);
   }
  else  // Первый запуск.
   {
    Question = MessageBox ("Производить запись в файл названий инструментов и торговых условий?" + 
                           "\nЕсли файл нужен в формате \"*.TXT\", нажимайте \"ДА\"." + 
                           "\nЕсли файл нужен в формате \"*.CSV\", нажимайте \"НЕТ\"." + 
                           "\nЕсли файл не нужен, нажимайте \"ОТМЕНА\".", NAME_SCRIPT, MB_YESNOCANCEL|MB_ICONQUESTION);
    if (Question == IDYES) FileClose (FileOpen (FileName + ".txt", FILE_WRITE)); // Открываем обнуляя файл.
    if (Question == IDNO)
     {
      handle = FileOpen (FileName + ".csv", FILE_CSV | FILE_WRITE);
      FileWrite (handle, "SYMBOL", "POINT", "DIGITS", "SPREAD", "STOPLEVEL", "LOTSIZE", "TICKVALUE", "TICKSIZE",
                         "SWAPLONG", "SWAPSHORT", "TRADEALLOWED", "MINLOT", "LOTSTEP", "MAXLOT", "STARTING", "EXPIRATION",
                         "Bar in M1", "Bar in M5", "Bar in M15", "Bar in M30", "Bar in H1", "Bar in H4", "Bar in D1", "Bar in W1", "Bar in MN1");
      FileClose (handle);
     }
    GlobalVariableSet ("glFileWrite", Question);
    GlobalVariableSet ("glSymbolHandle", WindowHandle (Symbol(), Period()));
    // Вычисление длины списка в окне "Обзор рынка".
    handle = Parent();
    if (handle != 0)  // Нашли главное окно.
     {
      handle = GetDlgItem (handle, 0xE81C); // Нашли список символов.
      handle = GetDlgItem (handle, 0x50);
      handle = GetDlgItem (handle, 0x8A71);
      Count = SendMessageA (handle, LVM_GETITEMCOUNT, 0, 0); // Получили количество элементов списка.
     }
    // Открываем окна с графиками.
    for (i = 1; i <= Count && !IsStopped(); i++)
     {
      OpenChart(i); // Открыли график очередного символа из окна "Обзор рынка".
      Sleep (Pause);
      // ЗапускаеМ выбранный в окне "Navigator" скрипт (индикатор или советник).
      PostMessageA (Parent(), WM_COMMAND, 33042, 0); // Запустили на только, что открытом графике этот скрипт.
      Sleep (Pause);
      HandleChart = GlobalVariableGet ("glSymbolHandle");  // Определяем дескриптор только, что открытого окна.
      // Переключение ТФ и эмуляция тиков.
      for (j = 0; j < 9 && !IsStopped(); j++)
       {
        if (j != 0) // Первую итерацию пропускаем. По умолчанию первый ТФ H1.
         {
          PostMessageA (HandleChart, WM_COMMAND, Instructions[j - 1], 0); // Устанавливаем ТФ.
         }
        PostMessageA (HandleChart, WM_COMMAND, 33324, 0); // Обновляем окно.
        Sleep (Pause);
        PostMessageA (HandleChart, WM_COMMAND, 33324, 0); // Обновляем окно ещё раз.
        Sleep (Pause);
       }
      PostMessageA (GetParent (HandleChart), WM_CLOSE, 0, 0); // Закрыли окно графика. 
      Sleep (Pause);
     }
    GlobalVariableDel ("glSymbolHandle");
    GlobalVariableDel ("glFileWrite");
    if (Question == IDYES || Question == IDCANCEL)
     {// Записываем в файл количество символов в окне "Обзор рынка".
      handle = FileOpen (FileName + ".txt", FILE_READ | FILE_WRITE);
      FileWrite (handle, "===================================================" +
                         "\nКоличество инструментов в окне \"Обзор рынка\" = " + Count +
                         "\nДата последнего сканирования " + TimeToStr (TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
      FileClose (handle);
     }
    if (Question == IDNO)
     {// Записываем в файл количество символов в окне "Обзор рынка".
      handle = FileOpen (FileName + ".csv", FILE_CSV | FILE_READ | FILE_WRITE);
      FileSeek (handle, 0, SEEK_END);
      FileWrite (handle, "Количество инструментов в окне \"Обзор рынка\" = " + Count +
                         "\nДата последнего сканирования " + TimeToStr (TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS));
      FileClose (handle);
     }
   }
 }
//======================================================================================
// Возвращает системный дескриптор основного окна терминала.
int Parent()
 {
  int hwnd = WindowHandle(Symbol(), Period());
  int hwnd_parent = 0;
  while (!IsStopped())
   {
    hwnd = GetParent(hwnd);   
    if (hwnd == 0) break;
    hwnd_parent = hwnd;
   }
  return (hwnd_parent);
 }
//======================================================================================
// Открывает окно графика символа, расположенного в строке номер Num окна "Обзор рынка".
void OpenChart (int Num)
 {
  int hwnd = Parent();  
  if (hwnd != 0)  // Нашли главное окно.
   {
    hwnd = GetDlgItem (hwnd, 0xE81C); // Нашли "Обзор рынка".
    hwnd = GetDlgItem (hwnd, 0x50);
    hwnd = GetDlgItem (hwnd, 0x8A71);
    PostMessageA (hwnd, WM_KEYDOWN, VK_HOME,0); // Верхняя строчка окна "Обзор рынка".
    while (Num > 1)  
     {
      PostMessageA (hwnd, WM_KEYDOWN,VK_DOWN, 0); // Сместились на нужную строчку.
      Num--;
     }
   }
  PostMessageA (Parent(), WM_COMMAND, 33160, 0); // Открыли график.
 }
//======================================================================================
// Записывает характеристика текущего торгового символа в файл формата "*.TXT".
void WriteSymbolTXT (string FileName)
 {
  int    handle;
  int    i;
  string MarketInf[20];
  //----
  for (i = 0; i < 20; i++) MarketInf[i] = ""; // Инициализируем массив.
  //----
  MarketInf[0]  = "==================== " + Symbol() + " =====================";
  MarketInf[1]  = "Point      = " + DoubleToStr (MarketInfo (Symbol(), MODE_POINT), 4);
  MarketInf[2]  = "Digits     = " + DoubleToStr (MarketInfo (Symbol(), MODE_DIGITS), 0);
  MarketInf[3]  = "Spread     = " + DoubleToStr (MarketInfo (Symbol(), MODE_SPREAD), 1);
  MarketInf[4]  = "StopLevel  = " + DoubleToStr (MarketInfo (Symbol(), MODE_STOPLEVEL), 1);
  MarketInf[5]  = "Lot Size   = " + DoubleToStr (MarketInfo (Symbol(), MODE_LOTSIZE), 2);
  MarketInf[6]  = "Tick Value = " + DoubleToStr (MarketInfo (Symbol(), MODE_TICKVALUE), 4);
  MarketInf[7]  = "Tick Size  = " + DoubleToStr (MarketInfo (Symbol(), MODE_TICKSIZE), 4);
  MarketInf[8]  = "Swap Long  = " + DoubleToStr (MarketInfo (Symbol(), MODE_SWAPLONG), 2);
  MarketInf[9]  = "Swap Short = " + DoubleToStr (MarketInfo (Symbol(), MODE_SWAPSHORT), 2);
  MarketInf[10]  = "------ The Amount Bar In TF. ------";
  MarketInf[11] = "Bar in M1  = " + iBars (Symbol(), 1);
  MarketInf[12] = "Bar in M5  = " + iBars (Symbol(), 5);
  MarketInf[13] = "Bar in M15 = " + iBars (Symbol(), 15);
  MarketInf[14] = "Bar in M30 = " + iBars (Symbol(), 30);
  MarketInf[15] = "Bar in H1  = " + iBars (Symbol(), 60);
  MarketInf[16] = "Bar in H4  = " + iBars (Symbol(), 240);
  MarketInf[17] = "Bar in D1  = " + iBars (Symbol(), 1440);
  MarketInf[18] = "Bar in W1  = " + iBars (Symbol(), 10080);
  MarketInf[19] = "Bar in MN1 = " + iBars (Symbol(), 43200);
  //----
  handle = FileOpen (FileName + ".txt", FILE_READ|FILE_WRITE|FILE_BIN);
  FileSeek (handle, 0, SEEK_END);
  FileWriteArray (handle, MarketInf, 0, 20);
  FileClose (handle);
  ArrayResize (MarketInf, 0); // Уничтожаем массив на всякий случай.
 }
//==========================================================================================
// Записывает характеристика текущего торгового символа в файл формата "*.CSV".
void WriteSymbolCSV (string FileName)
 {
  int handle = FileOpen (FileName + ".csv", FILE_CSV | FILE_READ | FILE_WRITE);
  FileSeek (handle, 0, SEEK_END);
  FileWrite (handle, Symbol(),
                     MarketInfo (Symbol(), MODE_POINT),
                     MarketInfo (Symbol(), MODE_DIGITS),
                     MarketInfo (Symbol(), MODE_SPREAD),
                     MarketInfo (Symbol(), MODE_STOPLEVEL),
                     MarketInfo (Symbol(), MODE_LOTSIZE),
                     MarketInfo (Symbol(), MODE_TICKVALUE),
                     MarketInfo (Symbol(), MODE_TICKSIZE),
                     MarketInfo (Symbol(), MODE_SWAPLONG),
                     MarketInfo (Symbol(), MODE_SWAPSHORT),
                     MarketInfo (Symbol(), MODE_TRADEALLOWED),
                     MarketInfo (Symbol(), MODE_MINLOT),
                     MarketInfo (Symbol(), MODE_LOTSTEP),
                     MarketInfo (Symbol(), MODE_MAXLOT),
                     MarketInfo (Symbol(), MODE_STARTING),
                     MarketInfo (Symbol(), MODE_EXPIRATION),
                     iBars (Symbol(), 1),
                     iBars (Symbol(), 5),
                     iBars (Symbol(), 15),
                     iBars (Symbol(), 30),
                     iBars (Symbol(), 60),
                     iBars (Symbol(), 240),
                     iBars (Symbol(), 1440),
                     iBars (Symbol(), 10080),
                     iBars (Symbol(), 43200));
  //----
  FileClose (handle);
 }
//==========================================================================================