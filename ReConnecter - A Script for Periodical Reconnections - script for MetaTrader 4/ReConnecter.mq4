//+------------------------------------------------------------------+
//|                                                  ReConnecter.mq4 | Скрипт для периодического переподключения к первому счету из "Избранного"
//|                                      Copyright © 2008, komposter | thanks to Getch (http://www.mql4.com/ru/users/getch)
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, komposter"
#property link      "mailto:komposterius@mail.ru"

#property show_inputs
 
extern int Pause_sec = 600;	// пауза между переподключениями в секундах

#include <WinUser32.mqh>
#import "user32.dll"
  int GetParent( int hWnd );
  int GetDlgItem( int hDlg, int nIDDlgItem );
  int GetLastActivePopup( int hWnd );
#import

#define VK_HOME 0x24
#define VK_DOWN 0x28
#define VK_ENTER 0x0D

#define PAUSE 1000

void init()
{
	start();
}

void start()
{
	if ( !IsDllsAllowed() )
	{
		Alert( "DLLs not alllowed!" );
		return;
	}

	while ( !IsStopped() )
	{
		Login(1);
		while ( !IsStopped() )
		{
			if ( OrdersHistoryTotal() > 0 ) break;
			Sleep(1000);
		}
		Print( "Успешное подключение к счету #", AccountNumber(), "! Следующее будет через ", Pause_sec/60, " минут..." );

		Sleep(Pause_sec*1000);
	}
	return;
}

// Подключается к счету, расположенному в строчке номер Num в закладке Избранное окна Навигатор
void Login( int Num )
{
   int hwnd = WindowHandle(Symbol(), Period());
   int hwnd_parent = 0;

   while (!IsStopped())
   {
      hwnd = GetParent(hwnd);
      if (hwnd == 0) break;
      hwnd_parent = hwnd;
   }

   if (hwnd_parent != 0)  // нашли главное окно
   {
     hwnd = GetDlgItem(hwnd_parent, 0xE81C); // нашли Избранное окна Навигатор
     hwnd = GetDlgItem(hwnd, 0x52);
     hwnd = GetDlgItem(hwnd, 0x8A70);

     PostMessageA(hwnd, WM_KEYDOWN, VK_HOME,0); // верхняя строчка закладки Избранное окна Навигатор

     while (Num > 1)  
     {
       PostMessageA(hwnd, WM_KEYDOWN,VK_DOWN, 0); // сместились на нужную строчку
       Num--;
     }

     PostMessageA(hwnd, WM_KEYDOWN, VK_ENTER, 0);  // логин
     Sleep(PAUSE);                                 // выждали

     hwnd = GetLastActivePopup(hwnd_parent);  // нашли форму логина
     PostMessageA(hwnd, WM_KEYDOWN, VK_ENTER, 0); // залогинились
   }

	return;
}

