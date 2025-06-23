//+------------------------------------------------------------------+
//|                                                (ModifyOrder).mq4 |
//|                                      Copyright © 2005, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, komposter"
#property link      "mailto:komposterius@mail.ru"

/*
-----------------------------В-Н-И-М-А-Н-И-Е---------------------------------
Перед запуском скрипта настоятельно рекомендую изучить следующее руководство:

Скрипт предназначен для модификации/удаления/закрытия позиции/отложенного ордера.
Для этого необходимо:
 1) Ознакомиться с данным руководством =), !установить значения по умолчанию! (находятся под описанием,
 	 начинаются и заканчиваются строкой //+----------------------------------------------+ ),
 	 разрешить импорт внешних экспертов через меню
 	 "Сервис" -> "Настройки" -> "Советники" -> "Разрешить импортирование внешних экспертов"
 	 (необходимо для описания ошибки, которая может возникнуть при модификации ордера)
 2) Перетащить скрипт на график недалеко от ордера/позиции, который(-ую) необходимо модифицировать.
 
 3) Переместить все линии на необходимые уровни:
		- Open_Price_Line (по умолчанию - белая) - цена открытия (ТОЛЬКО ДЛЯ ОТЛОЖЕННЫХ ОРДЕРОВ)
		- Stop_Loss_Line (красная) - уровень Стоп Лосс
		- Take_Profit_Line (зелёная) - уровень Тейк Профит
		- Expiration_Line (жёлтая) - время истечения (ТОЛЬКО ДЛЯ ОТЛОЖЕННЫХ ОРДЕРОВ)

	Чтоб удалить Стоп Лосс/Тейк Профит/Время истечения - просто удалите соответствующую линию.
	Чтоб удалить отложенный ордер/закрыть позицию  - удалите линию Open_Price_Line.

 4) Когда всё будет готово, в появившемся окне нажать кнопку "ОК".
 
 Для прекращения работы скрипта в любой момент можно воспользоваться кнопкой "Отмена".
 Если Вами будет найдена ошибка в коде, или в логике работы скрипта, просьба сообщить на komposterius@mail.ru
*/
#include <stdlib.mqh>

int first = 1;
int start()
{
//+------------------------------------------------------------------+
// Максимальное расстояние в пунктах от места, на которое был "отпущен" скрипт, до
// цены открытия ордера. Для макимальной точности работы используйте "0",
// тогда ордер выделится только в случае точного попадания.
int Order_Find_Radius = 10;

// Расстояние между линией Take_Profit/Stop_Loss и линией Open_Price в пунктах по умолчанию.
// Если Take_Profit/Stop_Loss использоваться не будет, установите 0
int Take_Profit = 50;
int Stop_Loss = 50;

// Максимальное отклонение от запрошенной цены (для закрытия позиции)
int Slippage = 5;

// Время истечения ордера, выраженное в свечах
// Для периода графика H4 и Expiration_Shift = 3 время истечения наступит через 12 часов после установки
// Если необходимо стандартное время истечения для всех периодов графика, укажите "0" (без кавычек), и переходите к следующей настройке
// Если время истечения ордера использоваться не будет, установите 0
int Expiration_Shift = 0;
// Время истечения ордера, выраженное в часах
// Для того, чтоб использовать эту настройку, необходимо установить Expiration_Shift (см. выше на 2 строки) "0" (без кавычек)
// Если время истечения ордера использоваться не будет, установите 0
int Expiration_Shift_H = 0;

// Цвета отображения ордеров на графике
color Buy_Color = Lime; //( для ордеров BUYSTOP и BUYLIMIT )
color Sell_Color = Red; //( для ордеров SELLLIMIT и SELLSTOP )

// Цвета линий:
color Open_Price_Line_Color = White;
color Stop_Loss_Line_Color = Red;
color Take_Profit_Line_Color = Lime;
color Expiration_Line_Color = Yellow;

//+------------------------------------------------------------------+

double Open_Price_Level, Stop_Loss_Level, Take_Profit_Level;
datetime Expiration_Time;
int _break, error;
double DropPrice = PriceOnDropped();

// поиск ордера
for ( int x = 0; x <= Order_Find_Radius; x ++ )
{
	int _OrdersTotal = OrdersTotal();
	for ( int z = _OrdersTotal - 1; z >= 0; z -- )
	{
		OrderSelect( z, SELECT_BY_POS, MODE_TRADES );
		if ( OrderSymbol() == Symbol() )
		{
			if ( ( DropPrice - OrderOpenPrice() )/Point <= x && ( DropPrice - OrderOpenPrice() )/Point >= 0 )
			{ _break = 1; break; }
			if ( ( OrderOpenPrice() - DropPrice )/Point <= x && ( OrderOpenPrice() - DropPrice )/Point >= 0 )
			{ _break = 1; break; }
		}
	}
	if ( _break == 1 ) { break; }
}

if ( _break != 1 )
{
	MessageBox(  "Не удалось найти ордер!\n\n" +
					 "Переместите скрипт на график недалеко от цены открытия ордера, который хотите модифицировать	", 
          	 	 "Начало работы", 0x00000000 | 0x00000010 | 0x00040000 ); 
	return(0);
}

int _OrderType = OrderType();
int _OrderTicket = OrderTicket();
double _OrderOpenPrice = OrderOpenPrice();
double _OrderStopLoss = OrderStopLoss();
double _OrderTakeProfit = OrderTakeProfit();
datetime _OrderExpiration = OrderExpiration();

// Установка начальных значений:
Open_Price_Level = _OrderOpenPrice;

if ( _OrderStopLoss > 0 )
{ Stop_Loss_Level = _OrderStopLoss; }
else
{
	if ( Stop_Loss > 0 )
	{
		if ( _OrderType == OP_BUY || _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
		{ Stop_Loss_Level = Open_Price_Level - Stop_Loss*Point; }
		else
		{ Stop_Loss_Level = Open_Price_Level + Stop_Loss*Point; }
	}
}

if ( _OrderTakeProfit > 0 )
{ Take_Profit_Level = _OrderTakeProfit; }
else
{
	if ( Take_Profit > 0 )
	{
		if ( _OrderType == OP_BUY || _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
		{ Take_Profit_Level = Open_Price_Level + Take_Profit*Point; }
		else
		{ Take_Profit_Level = Open_Price_Level - Take_Profit*Point; }
	}
}

if ( _OrderExpiration > 0 )
{ Expiration_Time = _OrderExpiration; }
else
{
	if ( _OrderType != OP_BUY && _OrderType != OP_SELL )
	{
		if ( Expiration_Shift > 0 )
		{ Expiration_Time = CurTime() + Period()*60*Expiration_Shift; }
		else
		{
			if ( Expiration_Shift_H > 0 )
				{ Expiration_Time = CurTime() + 3600*Expiration_Shift_H; }
		}
	}
}

// Создание линий:
if ( first == 1 )
{						
	ObjectCreate( "Open_Price_Line", OBJ_HLINE, 0, 0, Open_Price_Level, 0, 0, 0, 0 );
	ObjectSet( "Open_Price_Line", OBJPROP_COLOR, Open_Price_Line_Color );
	ObjectSetText( "Open_Price_Line", "Open_Price_Line", 6, "Arial", Open_Price_Line_Color );

	if ( Stop_Loss_Level > 0 )
	{
		ObjectCreate( "Stop_Loss_Line", OBJ_HLINE, 0, 0, Stop_Loss_Level, 0, 0, 0, 0 );
		ObjectSet( "Stop_Loss_Line", OBJPROP_COLOR, Stop_Loss_Line_Color );
		ObjectSetText( "Stop_Loss_Line", "Stop_Loss_Line", 6, "Arial", Stop_Loss_Line_Color );
	}

	if ( Take_Profit_Level > 0 )
	{
		ObjectCreate( "Take_Profit_Line", OBJ_HLINE, 0, 0, Take_Profit_Level, 0, 0, 0, 0 );
		ObjectSet( "Take_Profit_Line", OBJPROP_COLOR, Take_Profit_Line_Color );
		ObjectSetText( "Take_Profit_Line", "Take_Profit_Line", 6, "Arial", Take_Profit_Line_Color );
	}

	if ( Expiration_Time > 0 )
	{
		ObjectCreate( "Expiration_Line", OBJ_VLINE, 0, Expiration_Time, 0, 0, 0, 0, 0 );
		ObjectSet( "Expiration_Line", OBJPROP_COLOR, Expiration_Line_Color );
		ObjectSetText( "Expiration_Line", "Expiration_Line", 6, "Arial", Expiration_Line_Color );
	}

// вывод месседжбокса
	string Question = "Для внесения изменений переместите линии на необходимые уровни и нажмите \"ОК\".\n" + 
							"Чтоб отказаться от модификации и завершить работу, нажмите \"Отмена\".";
	int  Answer = MessageBox( Question, "Модификация ордера", 0x00000001 | 0x00000040 | 0x00040000  );
	first = 0;

	// если нажата любая кроме "ОК" кнопка - выходим
	if ( Answer != 1 ) { deinit(); return(0); }
}
// считываем значения с объектов и нормализуем:
	Open_Price_Level = NormalizeDouble( ObjectGet( "Open_Price_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Stop_Loss_Level = NormalizeDouble( ObjectGet( "Stop_Loss_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Take_Profit_Level = NormalizeDouble( ObjectGet( "Take_Profit_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
	Expiration_Time = ObjectGet( "Expiration_Line", OBJPROP_TIME1 );
	
	if ( Open_Price_Level == 0 )
	{
		int order;
		if ( _OrderType == OP_BUY || _OrderType == OP_SELL )
		{
			if ( _OrderType == OP_BUY ) 
			{ order = OrderClose( _OrderTicket, OrderLots(), Bid, Slippage, Buy_Color ); }
			else
			{ order = OrderClose( _OrderTicket, OrderLots(), Ask, Slippage, Sell_Color ); }
		}
		else
		{ order = OrderDelete( _OrderTicket ); }

		if ( order > 0 )
		{
// если всё ок, выводим лог и выходим
			Print( "Ордер №", _OrderTicket, " закрыт/удалён успешно!");
			return(0);
		}
		else
		{
// если ошибка - выводим сообщение и выходим
			error = GetLastError();
			Print("Ошибка при закрытии/удалении! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
			MessageBox( "Ошибка при закрытии/удалении! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 			"Ошибка закрытия/удаления ордера", 0x00000000 | 0x00000010 | 0x00040000 ); 
			return(-1);
		}
	return(0);
	}
	
	color _Color = Buy_Color;
// проверяем все значения
	if ( _OrderType == OP_BUY )
	{
		if ( Bid - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox( "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
				 		 			 	"\n" +
				 		 			 	"Для Buy - позиции она должна быть НИЖЕ Bid.	\n" + 
				 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
				 		 			 	"\n\n" +
				 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
				 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox( "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
			 		 			 		"\n" +
			 		 			 		"Для Buy - позиции она должна быть ВЫШЕ Bid.	\n" + 
			 		 			 		"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
			 		 			 		"\n\n" +
			 		 			 		"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
			 		 			 		"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
	}

	if ( _OrderType == OP_BUYSTOP || _OrderType == OP_BUYLIMIT )
	{
		if ( Open_Price_Level - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Buy, BuyLimit и BuyStop - ордеров она должна быть НИЖЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Buy, BuyLimit и BuyStop - ордеров она должна быть ВЫШЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_BUYSTOP )
		{
			if ( Open_Price_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для BuyStop - ордера она должна быть ВЫШЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
		if ( _OrderType == OP_BUYLIMIT )
		{
			if ( Bid - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для BuyLimit - ордера она должна быть НИЖЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}

	}
	if ( _OrderType == OP_SELL )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Sell - позиции она должна быть ВЫШЕ Ask.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Ask - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Sell - позиции она должна быть НИЖЕ Ask.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
	}
	if ( _OrderType == OP_SELLLIMIT || _OrderType == OP_SELLSTOP )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Stop_Loss_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Sell, SellLimit и SellStop - ордеров она должна быть ВЫШЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( Open_Price_Level - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level != 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для Sell, SellLimit и SellStop - ордеров она должна быть НИЖЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_SELLLIMIT )
		{
			if ( Open_Price_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для SellLimit - ордера она должна быть НИЖЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
		if ( _OrderType == OP_SELLSTOP )
		{
			if ( Ask - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для SellStop - ордера она должна быть ВЫШЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
			}
		}
	}

	if ( _OrderType == OP_BUY || _OrderType == OP_SELL )
	{
		if ( Open_Price_Level != _OrderOpenPrice )
		{
			Answer = MessageBox( "Нельзя двигать Open_Price_Line (белая линия) для уже открытых позиций!\n" + 
				 		 			 	"\n\n" +
				 		 			 	"Чтобы установить линию в начальное положение и начать модификацию с начала, нажмите \"Повтор\".\n" +
				 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectSet( "Open_Price_Line", OBJPROP_PRICE1, _OrderOpenPrice ); start(); }
			deinit();
			return(-1);
		}
		if ( Expiration_Time != 0 )
		{
				Answer = MessageBox( "Нельзя устанавливать Expiration_Line (жёлтая линия) для уже открытых позиций!\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы удалить линию и начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) {	ObjectDelete( "Expiration_Line" ); start(); }
				deinit();
				return(-1);
		}
	}
	else
	{
		if ( Expiration_Time <= CurTime() && Expiration_Time != 0 )
		{
				Answer = MessageBox( "Неправильно установлена Expiration_Line (жёлтая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Срок истечения ордера не может быть в прошедшем времени!		\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать модификацию с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от модификации, нажмите \"Отмена\".", "Модификация ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { start(); }
				deinit();
				return(-1);
		}
	}
	
// выводим инфу о запросе и пытаемся модифицировать ордер
	Print( "OrderTicket=",_OrderTicket, ",_OrderType=",_OrderType, ",Open_Price_Level=",Open_Price_Level, ",Stop_Loss_Level=", Stop_Loss_Level, ",Take_Profit_Level=", Take_Profit_Level, ",Expiration_Time=", Expiration_Time, ",_Color=", _Color );
	int ordermodify = OrderModify( _OrderTicket, Open_Price_Level, Stop_Loss_Level, Take_Profit_Level, Expiration_Time, _Color );
	if ( ordermodify > 0 )
	{
// если всё ок, выводим лог и выходим
		OrderPrint();
		Print( "Ордер №", _OrderTicket, " модифицирован успешно!");
		return(0);
	}
// если ошибка - выводим сообщение и выходим
	error = GetLastError();
	Print("Ошибка при модификации! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
	MessageBox( "Ошибка при модификации! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 	"Ошибка модификации ордера", 0x00000000 | 0x00000010 | 0x00040000 ); 
return(-1);
}

int deinit()
{
// удаление всех объектов, созданных скриптом
	ObjectDelete( "Open_Price_Line" );
	ObjectDelete( "Stop_Loss_Line" );
	ObjectDelete( "Take_Profit_Line" );
	ObjectDelete( "Expiration_Line" );
return(0);
}

