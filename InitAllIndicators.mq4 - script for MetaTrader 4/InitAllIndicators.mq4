//+------------------------------------------------------------------+
//|                                            InitAllIndicators.mq4 |
//|                                 		 (C)opyright © 2008, Ilnur |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

// Скрипт для переинициализации всех индикаторов, прикрепленных текущему окну.
// Для работы скрипта необходимо разрешить вызов функций из системных DLL:
// Сервис -> Настройки  -> Советники -> Разрешить импорт DLL.

#property copyright "(C)opyright © 2008, Ilnur"
#property link      "http://www.metaquotes.net"

#include <WinUser32.mqh>

#import "user32.dll"
	int GetAncestor(int hWnd, int gaFlags);
	int GetLastActivePopup(int hWnd);
	int GetDlgItem(int hDlg, int nIDDlgItem);
#import

#define PAUSE 100

#define VK_HOME 0x24
#define VK_DOWN 0x28

#define GA_ROOT 2

#define TVM_GETCOUNT 0x1105

//+------------------------------------------------------------------+
//| Вызывает окно "Список индикаторов" и возвращает его дескриптор   |
//+------------------------------------------------------------------+
int GetListDialog(int hOwnedWnd)
{
	int hDlgWnd;
//---- вызываем окно "Список индикаторов"
	PostMessageA(hOwnedWnd,WM_COMMAND,35419,0);
	Sleep(PAUSE);
//---- определяем дескриптор окна
	hDlgWnd = GetLastActivePopup(hOwnedWnd);
//----
	return(hDlgWnd);
}

//+------------------------------------------------------------------+
//| Вызывает окно свойств индикатора и возвращает его дескриптор     |
//+------------------------------------------------------------------+
int GetPropertyDialog(int hOwnedWnd, int hListDlg)
{
	int hDlgWnd;
//---- вызываем окно свойств выбранного индикатора
	PostMessageA(hListDlg,WM_COMMAND,0x48B,GetDlgItem(hListDlg,0x48B));
	Sleep(PAUSE);
//---- определяем дескриптор окна
	hDlgWnd = GetLastActivePopup(hOwnedWnd);
//----
	return(hDlgWnd);
}

//+------------------------------------------------------------------+
//| Основная функция скрипта	                                     	|
//+------------------------------------------------------------------+
void start()
{
	int hParentWnd, hListDlg, hTreeView, hPropDlg;
	int nTreeCount;
//---- получаем дескриптор основного окна терминала
	hParentWnd = GetAncestor(WindowHandle(Symbol(),Period()),GA_ROOT);

	if(hParentWnd!=0)
	{
	//---- вызываем окно "Список индикаторов"
		hListDlg = GetListDialog(hParentWnd);
	//---- находим список индикаторов
		hTreeView = GetDlgItem(hListDlg,0x48C); //
	//---- определяем общую длину списка
		nTreeCount = SendMessageA(hTreeView,TVM_GETCOUNT,0,0);
	//---- устанавливаем курсор на верхней строчке списка
		PostMessageA(hTreeView,WM_KEYDOWN,VK_HOME,0);
	//---- в цикле перебираем весь список
		for(int i=1; i<nTreeCount; i++)
		{
		//---- смещаем курсор на следующую позицию списка
			PostMessageA(hTreeView,WM_KEYDOWN,VK_DOWN,0);
		//---- проверяем активность кнопки "Свойства"
			if(IsWindowEnabled(GetDlgItem(hListDlg,0x48B))==0) continue;
		//---- вызываем окно свойств выделенного индикатора
			hPropDlg = GetPropertyDialog(hParentWnd,hListDlg);
		//---- нажимаем кнопку "ОК"
			PostMessageA(hPropDlg,WM_COMMAND,0x001,GetDlgItem(hPropDlg,0x001));
		}
	//---- закрываем окно "Список индикаторов"
		PostMessageA(hListDlg,WM_COMMAND,0x001,GetDlgItem(hListDlg,0x001));
	}
}

