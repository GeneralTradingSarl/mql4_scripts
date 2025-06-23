//+------------------------------------------------------------------+
//|                                              	 AllAmplitude.mq4 |
//|                                      Copyright © 2005, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, komposter"
#property link      "mailto:komposterius@mail.ru"

int start()
{
	/////////////////////////////////////////////////////////////////////////////////////////////
	// ДЛЯ ОТКЛЮЧЕНИЯ СООБЩЕНИЯ об окончании работы
	// надо вместо "int Massage = 1;" написать "int Massage = 0;"
	int Massage = 1;
	/////////////////////////////////////////////////////////////////////////////////////////////

	int bars = Bars;

	double Amp_HL_Max, Amp_HL_Min, Amp_HL_Avg, Amp_HL_Total;
	double Amp_OC_Max, Amp_OC_Min, Amp_OC_Avg, Amp_OC_Total;
	double Amp_Wick_Max, Amp_Wick_Min, Amp_Wick_Avg, Amp_Wick_Total;
	double Amp_Wick_Max_Up, Amp_Wick_Min_Up, Amp_Wick_Avg_Up, Amp_Wick_Total_Up;
	double Amp_Wick_Max_Down, Amp_Wick_Min_Down, Amp_Wick_Avg_Down, Amp_Wick_Total_Down;
	string Date_HL_Max, Date_HL_Min;
	string Date_OC_Max, Date_OC_Min;
	string Date_Wick_Max, Date_Wick_Min;
	string Date_Wick_Max_Up, Date_Wick_Min_Up;
	string Date_Wick_Max_Down, Date_Wick_Min_Down;

	int Bull_Bars, Bear_Bars;
	double Amp_HL_Max_Bull, Amp_HL_Min_Bull, Amp_HL_Avg_Bull, Amp_HL_Total_Bull;
	double Amp_OC_Max_Bull, Amp_OC_Min_Bull, Amp_OC_Avg_Bull, Amp_OC_Total_Bull;
	double Amp_Wick_Max_Bull, Amp_Wick_Min_Bull, Amp_Wick_Avg_Bull, Amp_Wick_Total_Bull;
	double Amp_Wick_Max_Bull_Up, Amp_Wick_Min_Bull_Up, Amp_Wick_Avg_Bull_Up, Amp_Wick_Total_Bull_Up;
	double Amp_Wick_Max_Bull_Down, Amp_Wick_Min_Bull_Down, Amp_Wick_Avg_Bull_Down, Amp_Wick_Total_Bull_Down;
	string Date_HL_Max_Bull, Date_HL_Min_Bull;
	string Date_OC_Max_Bull, Date_OC_Min_Bull;
	string Date_Wick_Max_Bull, Date_Wick_Min_Bull;
	string Date_Wick_Max_Bull_Up, Date_Wick_Min_Bull_Up;
	string Date_Wick_Max_Bull_Down, Date_Wick_Min_Bull_Down;

	double Amp_HL_Max_Bear, Amp_HL_Min_Bear, Amp_HL_Avg_Bear, Amp_HL_Total_Bear;
	double Amp_OC_Max_Bear, Amp_OC_Min_Bear, Amp_OC_Avg_Bear, Amp_OC_Total_Bear;
	double Amp_Wick_Max_Bear, Amp_Wick_Min_Bear, Amp_Wick_Avg_Bear, Amp_Wick_Total_Bear;
	double Amp_Wick_Max_Bear_Up, Amp_Wick_Min_Bear_Up, Amp_Wick_Avg_Bear_Up, Amp_Wick_Total_Bear_Up;
	double Amp_Wick_Max_Bear_Down, Amp_Wick_Min_Bear_Down, Amp_Wick_Avg_Bear_Down, Amp_Wick_Total_Bear_Down;
	string Date_HL_Max_Bear, Date_HL_Min_Bear;
	string Date_OC_Max_Bear, Date_OC_Min_Bear;
	string Date_Wick_Max_Bear, Date_Wick_Min_Bear;
	string Date_Wick_Max_Bear_Up, Date_Wick_Min_Bear_Up;
	string Date_Wick_Max_Bear_Down, Date_Wick_Min_Bear_Down;

	string Date_End = TimeDay ( Time[0] ) + "." + TimeMonth ( Time[0] ) + "." + TimeYear ( Time[0] );
	string DateTime_End = Date_End + " " + TimeToStr ( Time[0], TIME_MINUTES );
	datetime Minute_End = TimeMinute ( Time[0] );
	datetime Hour_End = TimeHour ( Time[0] );
	datetime Day_End = TimeDay ( Time[0] );
	datetime Month_End = TimeMonth ( Time[0] );
	datetime Year_End = TimeYear ( Time[0] );

	string Date_Start = TimeDay ( Time[bars - 1] ) + "." + TimeMonth ( Time[bars - 1] ) + "." + TimeYear ( Time[bars - 1] );
	string DateTime_Start = Date_Start + " " + TimeToStr ( Time[bars - 1], TIME_MINUTES );
	datetime Minute_Start = TimeMinute ( Time[bars - 1] );
	datetime Hour_Start = TimeHour ( Time[bars - 1] );
	datetime Day_Start = TimeDay ( Time[bars - 1] );
	datetime Month_Start = TimeMonth ( Time[bars - 1] );
	datetime Year_Start = TimeYear ( Time[bars - 1] );

	//"сооружаем" период расчёта (1-я строка в файле *.txt)
	datetime Minute_Count_tmp = Minute_End - Minute_Start;
	if ( Minute_Count_tmp < 0 ) { Minute_Count_tmp = 60 + Minute_Count_tmp; Hour_End -- ; }
	if ( Minute_Count_tmp == 60 ) { Minute_Count_tmp = 0; Hour_End ++ ; }
	if ( Minute_Count_tmp > 0 && Minute_Count_tmp < 60 ) string Minute_Count = Minute_Count_tmp + " minute(s),";
	datetime Hour_Count_tmp = Hour_End - Hour_Start;
	if ( Hour_Count_tmp < 0 ) { Hour_Count_tmp = 24 + Hour_Count_tmp; Day_End -- ; }
	if ( Hour_Count_tmp == 24 ) { Hour_Count_tmp = 0; Day_End ++ ; }
	if ( Hour_Count_tmp > 0 && Hour_Count_tmp < 24 ) string Hour_Count = Hour_Count_tmp + " hour(s),";
	datetime Day_Count_tmp = Day_End - Day_Start;
	if ( Day_Count_tmp < 0 ) { Day_Count_tmp = 30 + Day_Count_tmp; Month_End -- ; }
	if ( Day_Count_tmp >= 29 ) { Day_Count_tmp = 0; Month_End ++ ; }
	if ( Day_Count_tmp > 0 && Day_Count_tmp < 29 ) string Day_Count = Day_Count_tmp + " day(s),";
	datetime Month_Count_tmp = Month_End - Month_Start;
	if ( Month_Count_tmp < 0 ) { Month_Count_tmp = 12 + Month_Count_tmp; Year_End -- ; }
	if ( Month_Count_tmp == 12 ) { Month_Count_tmp = 0; Year_End ++ ; }
	if ( Month_Count_tmp > 0 && Month_Count_tmp < 12 ) string Month_Count = Month_Count_tmp + " month(es),";
	datetime Year_Count_tmp = Year_End - Year_Start;
	if ( Year_Count_tmp > 0 ) string Year_Count = Year_Count_tmp + " year(s),";

	//начинаем считать:
	for ( int shift = bars - 1; shift >= 0; shift-- )
	{
		//это разнообразные даты - время (для имени файла, для отдельных значений и т.д)
		string bar_hour_minute = TimeToStr ( Time[shift], TIME_MINUTES );
		datetime bar_minute = TimeMinute ( Time[shift] );
		datetime bar_hour = TimeHour ( Time[shift] );
		datetime bar_day = TimeDay ( Time[shift] );
		datetime bar_month = TimeMonth ( Time[shift] );
		datetime bar_year = TimeYear ( Time[shift] );
		string bar_date = bar_day + "." + bar_month + "." + bar_year;
		string bar_datetime = bar_day + "." + bar_month + "." + bar_year + " " + bar_hour_minute;

		//начинаем высчитывать данные
		double high = High[shift], low = Low[shift], close = Close[shift], open = Open[shift];
		/////////////////////////////////////////////////////////////////////////////////////////////
		//	Вся свеча (High-Low)
		/////////////////////////////////////////////////////////////////////////////////////////////
		double Amp_HL_tmp = ( high - low ) / Point;

		//поиск макс амплитуды HL
		if ( Amp_HL_tmp - Amp_HL_Max > 0 )
		{
			Amp_HL_Max = Amp_HL_tmp;
			Date_HL_Max = bar_datetime;
		}

		//поиск мин амплитуды HL
		if (Amp_HL_Min - Amp_HL_tmp > 0 || Amp_HL_Min == 0 )
		{
			Amp_HL_Min = Amp_HL_tmp;
			Date_HL_Min = bar_datetime;
		}

		//поиск суммарной и средней амплитуды HL
		Amp_HL_Total += Amp_HL_tmp;
		Amp_HL_Avg = Amp_HL_Total / bars;
      
		/////////////////////////////////////////////////////////////////////////////////////////////
		//	"Тело" свечи (Open-Close)
		/////////////////////////////////////////////////////////////////////////////////////////////
		double Amp_OC_tmp;

		if ( close - open >= 0 )
		{ Amp_OC_tmp = ( close - open ) / Point; }
		else
		{ Amp_OC_tmp = ( open - close ) / Point; }

		//поиск макс амплитуды OC
		if ( Amp_OC_tmp - Amp_OC_Max > 0 )
		{
			Amp_OC_Max = Amp_OC_tmp;
			Date_OC_Max = bar_datetime;
		}

		//поиск мин амплитуды OC
		if (Amp_OC_Min - Amp_OC_tmp > 0 || Amp_OC_Min == 0 )
		{
			Amp_OC_Min = Amp_OC_tmp;
			Date_OC_Min = bar_datetime;
		}

   	//поиск суммарной и средней амплитуды OC
   	Amp_OC_Total += Amp_OC_tmp;
   	Amp_OC_Avg = Amp_OC_Total / bars;

		/////////////////////////////////////////////////////////////////////////////////////////////
   	//"Тень" свечи (High-Close + Open-Low)
		/////////////////////////////////////////////////////////////////////////////////////////////
		double Amp_Wick_tmp;

		if ( close - open >= 0 )
		{ Amp_Wick_tmp = ( high - close ) / Point + ( open - low ) / Point; }
		else
		{ Amp_Wick_tmp = ( high - open ) / Point + ( close - low ) / Point; }

		//поиск макс амплитуды Wick
		if ( Amp_Wick_tmp - Amp_Wick_Max > 0 )
		{
			Amp_Wick_Max = Amp_Wick_tmp;
			Date_Wick_Max = bar_datetime;
		}

		//поиск мин амплитуды Wick
		if (Amp_Wick_Min - Amp_Wick_tmp > 0 || Amp_Wick_Min == 0 )
		{
			Amp_Wick_Min = Amp_Wick_tmp;
			Date_Wick_Min = bar_datetime;
		}

		//поиск суммарной и средней амплитуды Wick
		Amp_Wick_Total += Amp_Wick_tmp;
		Amp_Wick_Avg = Amp_Wick_Total / bars;
   
		/////////////////////////////////////////////////////////////////////////////////////////////
		// верхний "Фитиль" свечи 
		/////////////////////////////////////////////////////////////////////////////////////////////
		double Amp_Wick_tmp_Up;

		if ( close - open >= 0 )
		{ Amp_Wick_tmp_Up = ( high - close ) / Point; }
		else
		{ Amp_Wick_tmp_Up = ( high - open ) / Point; }

		//поиск макс амплитуды Wick
		if ( Amp_Wick_tmp_Up - Amp_Wick_Max_Up > 0 )
		{
			Amp_Wick_Max_Up = Amp_Wick_tmp_Up;
			Date_Wick_Max_Up = bar_datetime;
		}

		//поиск мин амплитуды Wick
		if (Amp_Wick_Min_Up - Amp_Wick_tmp_Up > 0 || Amp_Wick_Min_Up == 0 )
		{
			Amp_Wick_Min_Up = Amp_Wick_tmp_Up;
			Date_Wick_Min_Up = bar_datetime;
		}

		//поиск суммарной и средней амплитуды Wick
		Amp_Wick_Total_Up += Amp_Wick_tmp_Up;
		Amp_Wick_Avg_Up = Amp_Wick_Total_Up / bars;

		/////////////////////////////////////////////////////////////////////////////////////////////
		// нижний "Фитиль" свечи
		/////////////////////////////////////////////////////////////////////////////////////////////
		double Amp_Wick_tmp_Down;

		if ( close - open >= 0 )
		{ Amp_Wick_tmp_Down = ( open - low ) / Point; }
		else
		{ Amp_Wick_tmp_Down = ( close - low ) / Point; }

		//поиск макс амплитуды Wick
		if ( Amp_Wick_tmp_Down - Amp_Wick_Max_Down > 0 )
		{
			Amp_Wick_Max_Down = Amp_Wick_tmp_Down;
			Date_Wick_Max_Down = bar_datetime;
		}

		//поиск мин амплитуды Wick
		if (Amp_Wick_Min_Down - Amp_Wick_tmp_Down > 0 || Amp_Wick_Min_Down == 0 )
		{
			Amp_Wick_Min_Down = Amp_Wick_tmp_Down;
			Date_Wick_Min_Down = bar_datetime;
		}

		//поиск суммарной и средней амплитуды Wick
		Amp_Wick_Total_Down += Amp_Wick_tmp_Down;
		Amp_Wick_Avg_Down = Amp_Wick_Total_Down / bars;

		/////////////////////////////////////////////////////////////////////////////////////////////
		//всё то же, для бычьей свечи
		/////////////////////////////////////////////////////////////////////////////////////////////
		if (close - open >= 0)
		{
			//кол-во свечей
			Bull_Bars ++;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//	Вся свеча (High-Low)
			/////////////////////////////////////////////////////////////////////////////////////////////

			double Amp_HL_tmp_Bull = ( high - low ) / Point;

			//поиск макс амплитуды HL
			if ( Amp_HL_tmp_Bull - Amp_HL_Max_Bull > 0 )
			{
				Amp_HL_Max_Bull = Amp_HL_tmp_Bull;
				Date_HL_Max_Bull = bar_datetime;
			}

			//поиск мин амплитуды HL
			if ( Amp_HL_Min_Bull - Amp_HL_tmp_Bull > 0 || Amp_HL_Min_Bull == 0 )
			{
				Amp_HL_Min_Bull = Amp_HL_tmp_Bull;
				Date_HL_Min_Bull = bar_datetime;
			}

			//поиск суммарной и средней амплитуды HL
			Amp_HL_Total_Bull += Amp_HL_tmp_Bull;
			Amp_HL_Avg_Bull = Amp_HL_Total_Bull / Bull_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//	"Тело" свечи (Open-Close)
			/////////////////////////////////////////////////////////////////////////////////////////////

			double Amp_OC_tmp_Bull = ( close - open ) / Point;

			//поиск макс амплитуды OC
			if ( Amp_OC_tmp_Bull - Amp_OC_Max_Bull > 0 )
			{
				Amp_OC_Max_Bull = Amp_OC_tmp_Bull;
				Date_OC_Max_Bull = bar_datetime;
			}

			//поиск мин амплитуды OC
			if (Amp_OC_Min_Bull - Amp_OC_tmp_Bull > 0 || Amp_OC_Min_Bull == 0 )
			{
				Amp_OC_Min_Bull = Amp_OC_tmp_Bull;
				Date_OC_Min_Bull = bar_datetime;
			}

			//поиск суммарной и средней амплитуды OC
			Amp_OC_Total_Bull += Amp_OC_tmp_Bull;
			Amp_OC_Avg_Bull = Amp_OC_Total_Bull / Bull_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//"Фитиль" свечи (High-Close + Open-Low)
			/////////////////////////////////////////////////////////////////////////////////////////////

			double Amp_Wick_tmp_Bull = ( high - close ) / Point + ( open - low ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bull - Amp_Wick_Max_Bull > 0 )
			{
				Amp_Wick_Max_Bull = Amp_Wick_tmp_Bull;
				Date_Wick_Max_Bull = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bull - Amp_Wick_tmp_Bull > 0 || Amp_Wick_Min_Bull == 0 )
			{
				Amp_Wick_Min_Bull = Amp_Wick_tmp_Bull;
				Date_Wick_Min_Bull = bar_datetime;
			}

   		//поиск суммарной и средней амплитуды Wick
   		Amp_Wick_Total_Bull += Amp_Wick_tmp_Bull;
   		Amp_Wick_Avg_Bull = Amp_Wick_Total_Bull / Bull_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			// верхний "Фитиль" свечи 
			/////////////////////////////////////////////////////////////////////////////////////////////
			double Amp_Wick_tmp_Bull_Up;

			Amp_Wick_tmp_Bull_Up = ( high - close ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bull_Up - Amp_Wick_Max_Bull_Up > 0 )
			{
				Amp_Wick_Max_Bull_Up = Amp_Wick_tmp_Bull_Up;
				Date_Wick_Max_Bull_Up = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bull_Up - Amp_Wick_tmp_Bull_Up > 0 || Amp_Wick_Min_Bull_Up == 0 )
			{
				Amp_Wick_Min_Bull_Up = Amp_Wick_tmp_Bull_Up;
				Date_Wick_Min_Bull_Up = bar_datetime;
			}

			//поиск суммарной и средней амплитуды Wick
			Amp_Wick_Total_Bull_Up += Amp_Wick_tmp_Bull_Up;
			Amp_Wick_Avg_Bull_Up = Amp_Wick_Total_Bull_Up / Bull_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			// нижний "Фитиль" свечи
			/////////////////////////////////////////////////////////////////////////////////////////////
			double Amp_Wick_tmp_Bull_Down;

			Amp_Wick_tmp_Bull_Down = ( open - low ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bull_Down - Amp_Wick_Max_Bull_Down > 0 )
			{
				Amp_Wick_Max_Bull_Down = Amp_Wick_tmp_Bull_Down;
				Date_Wick_Max_Bull_Down = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bull_Down - Amp_Wick_tmp_Bull_Down > 0 || Amp_Wick_Min_Bull_Down == 0 )
			{
				Amp_Wick_Min_Bull_Down = Amp_Wick_tmp_Bull_Down;
				Date_Wick_Min_Bull_Down = bar_datetime;
			}

			//поиск суммарной и средней амплитуды Wick
			Amp_Wick_Total_Bull_Down += Amp_Wick_tmp_Bull_Down;
			Amp_Wick_Avg_Bull_Down = Amp_Wick_Total_Bull_Down / Bull_Bars;
		}
		/////////////////////////////////////////////////////////////////////////////////////////////
		//всё то же, для медвежьей свечи
		/////////////////////////////////////////////////////////////////////////////////////////////
		else
		{
			//кол-во свечей
			Bear_Bars ++;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//	Вся свеча (High-Low)
			/////////////////////////////////////////////////////////////////////////////////////////////

			double Amp_HL_tmp_Bear = ( high - low ) / Point;

			//поиск макс амплитуды HL
			if ( Amp_HL_tmp_Bear - Amp_HL_Max_Bear > 0 )
			{
				Amp_HL_Max_Bear = Amp_HL_tmp_Bear;
				Date_HL_Max_Bear = bar_datetime;
			}

			//поиск мин амплитуды HL
			if (Amp_HL_Min_Bear - Amp_HL_tmp_Bear > 0 || Amp_HL_Min_Bear == 0 )
			{
				Amp_HL_Min_Bear = Amp_HL_tmp_Bear;
				Date_HL_Min_Bear = bar_datetime;
			}

			//поиск суммарной и средней амплитуды HL
			Amp_HL_Total_Bear += Amp_HL_tmp_Bear;
			Amp_HL_Avg_Bear = Amp_HL_Total_Bear / Bear_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//	"Тело" свечи (Close-Open)
			/////////////////////////////////////////////////////////////////////////////////////////////
			double Amp_OC_tmp_Bear = ( open - close ) / Point;

			//поиск макс амплитуды OC
			if ( Amp_OC_tmp_Bear - Amp_OC_Max_Bear > 0 )
			{
				Amp_OC_Max_Bear = Amp_OC_tmp_Bear;
				Date_OC_Max_Bear = bar_datetime;
			}

			//поиск мин амплитуды OC
			if (Amp_OC_Min_Bear - Amp_OC_tmp_Bear > 0 || Amp_OC_Min_Bear == 0 )
			{
				Amp_OC_Min_Bear = Amp_OC_tmp_Bear;
				Date_OC_Min_Bear = bar_datetime;
			}

			//поиск суммарной и средней амплитуды OC
			Amp_OC_Total_Bear += Amp_OC_tmp_Bear;
			Amp_OC_Avg_Bear = Amp_OC_Total_Bear / Bear_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			//"Фитиль" свечи (High-Open + Close-Low)
			/////////////////////////////////////////////////////////////////////////////////////////////

			double Amp_Wick_tmp_Bear = ( high - open ) / Point + ( close - low ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bear - Amp_Wick_Max_Bear > 0 )
			{
				Amp_Wick_Max_Bear = Amp_Wick_tmp_Bear;
				Date_Wick_Max_Bear = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bear - Amp_Wick_tmp_Bear > 0 || Amp_Wick_Min_Bear == 0 )
			{
				Amp_Wick_Min_Bear = Amp_Wick_tmp_Bear;
				Date_Wick_Min_Bear = bar_datetime;
			}

			//поиск суммарной и средней амплитуды Wick
			Amp_Wick_Total_Bear += Amp_Wick_tmp_Bear;
			Amp_Wick_Avg_Bear = Amp_Wick_Total_Bear / Bear_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			// верхний "Фитиль" свечи 
			/////////////////////////////////////////////////////////////////////////////////////////////
			double Amp_Wick_tmp_Bear_Up;

			Amp_Wick_tmp_Bear_Up = ( high - open ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bear_Up - Amp_Wick_Max_Bear_Up > 0 )
			{
				Amp_Wick_Max_Bear_Up = Amp_Wick_tmp_Bear_Up;
				Date_Wick_Max_Bear_Up = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bear_Up - Amp_Wick_tmp_Bear_Up > 0 || Amp_Wick_Min_Bear_Up == 0 )
			{
				Amp_Wick_Min_Bear_Up = Amp_Wick_tmp_Bear_Up;
				Date_Wick_Min_Bear_Up = bar_datetime;
			}

			//поиск суммарной и средней амплитуды Wick
			Amp_Wick_Total_Bear_Up += Amp_Wick_tmp_Bear_Up;
			Amp_Wick_Avg_Bear_Up = Amp_Wick_Total_Bear_Up / Bear_Bars;

			/////////////////////////////////////////////////////////////////////////////////////////////
			// нижний "Фитиль" свечи
			/////////////////////////////////////////////////////////////////////////////////////////////
			double Amp_Wick_tmp_Bear_Down;

			Amp_Wick_tmp_Bear_Down = ( close - low ) / Point;

			//поиск макс амплитуды Wick
			if ( Amp_Wick_tmp_Bear_Down - Amp_Wick_Max_Bear_Down > 0 )
			{
				Amp_Wick_Max_Bear_Down = Amp_Wick_tmp_Bear_Down;
				Date_Wick_Max_Bear_Down = bar_datetime;
			}

			//поиск мин амплитуды Wick
			if (Amp_Wick_Min_Bear_Down - Amp_Wick_tmp_Bear_Down > 0 || Amp_Wick_Min_Bear_Down == 0 )
			{
				Amp_Wick_Min_Bear_Down = Amp_Wick_tmp_Bear_Down;
				Date_Wick_Min_Bear_Down = bar_datetime;
			}

			//поиск суммарной и средней амплитуды Wick
			Amp_Wick_Total_Bear_Down += Amp_Wick_tmp_Bear_Down;
			Amp_Wick_Avg_Bear_Down = Amp_Wick_Total_Bear_Down / Bear_Bars;
		}
	}


	string s_Amp_HL_Max = DoubleToStr( Amp_HL_Max, 0 );
	string s_Amp_HL_Min = DoubleToStr( Amp_HL_Min, 0 );
	string s_Amp_HL_Avg = DoubleToStr( Amp_HL_Avg, 2 );
	string s_Amp_HL_Total = DoubleToStr( Amp_HL_Total, 0 );
	string s_Amp_OC_Max = DoubleToStr( Amp_OC_Max, 0 );
	string s_Amp_OC_Min = DoubleToStr( Amp_OC_Min, 0 );
	string s_Amp_OC_Avg = DoubleToStr( Amp_OC_Avg, 2 );
	string s_Amp_OC_Total = DoubleToStr( Amp_OC_Total, 0 );
	string s_Amp_Wick_Max = DoubleToStr( Amp_Wick_Max, 0 );
	string s_Amp_Wick_Min = DoubleToStr( Amp_Wick_Min, 0 );
	string s_Amp_Wick_Avg = DoubleToStr( Amp_Wick_Avg, 2 );
	string s_Amp_Wick_Total = DoubleToStr( Amp_Wick_Total, 0 );
	string s_Amp_Wick_Max_Up = DoubleToStr( Amp_Wick_Max_Up, 0 );
	string s_Amp_Wick_Min_Up = DoubleToStr( Amp_Wick_Min_Up, 0 );
	string s_Amp_Wick_Avg_Up = DoubleToStr( Amp_Wick_Avg_Up, 2 );
	string s_Amp_Wick_Total_Up = DoubleToStr( Amp_Wick_Total_Up, 0 );
	string s_Amp_Wick_Max_Down = DoubleToStr( Amp_Wick_Max_Down, 0 );
	string s_Amp_Wick_Min_Down = DoubleToStr( Amp_Wick_Min_Down, 0 );
	string s_Amp_Wick_Avg_Down = DoubleToStr( Amp_Wick_Avg_Down, 2 );
	string s_Amp_Wick_Total_Down = DoubleToStr( Amp_Wick_Total_Down, 0 );

	string s_Amp_HL_Max_Bull = DoubleToStr( Amp_HL_Max_Bull, 0 );
	string s_Amp_HL_Min_Bull = DoubleToStr( Amp_HL_Min_Bull, 0 );
	string s_Amp_HL_Avg_Bull = DoubleToStr( Amp_HL_Avg_Bull, 2 );
	string s_Amp_HL_Total_Bull = DoubleToStr( Amp_HL_Total_Bull, 0 );
	string s_Amp_OC_Max_Bull = DoubleToStr( Amp_OC_Max_Bull, 0 );
	string s_Amp_OC_Min_Bull = DoubleToStr( Amp_OC_Min_Bull, 0 );
	string s_Amp_OC_Avg_Bull = DoubleToStr( Amp_OC_Avg_Bull, 2 );
	string s_Amp_OC_Total_Bull = DoubleToStr( Amp_OC_Total_Bull, 0 );
	string s_Amp_Wick_Max_Bull = DoubleToStr( Amp_Wick_Max_Bull, 0 );
	string s_Amp_Wick_Min_Bull = DoubleToStr( Amp_Wick_Min_Bull, 0 );
	string s_Amp_Wick_Avg_Bull = DoubleToStr( Amp_Wick_Avg_Bull, 2 );
	string s_Amp_Wick_Total_Bull = DoubleToStr( Amp_Wick_Total_Bull, 0 );
	string s_Amp_Wick_Max_Bull_Up = DoubleToStr( Amp_Wick_Max_Bull_Up, 0 );
	string s_Amp_Wick_Min_Bull_Up = DoubleToStr( Amp_Wick_Min_Bull_Up, 0 );
	string s_Amp_Wick_Avg_Bull_Up = DoubleToStr( Amp_Wick_Avg_Bull_Up, 2 );
	string s_Amp_Wick_Total_Bull_Up = DoubleToStr( Amp_Wick_Total_Bull_Up, 0 );
	string s_Amp_Wick_Max_Bull_Down = DoubleToStr( Amp_Wick_Max_Bull_Down, 0 );
	string s_Amp_Wick_Min_Bull_Down = DoubleToStr( Amp_Wick_Min_Bull_Down, 0 );
	string s_Amp_Wick_Avg_Bull_Down = DoubleToStr( Amp_Wick_Avg_Bull_Down, 2 );
	string s_Amp_Wick_Total_Bull_Down = DoubleToStr( Amp_Wick_Total_Bull_Down, 0 );

	string s_Amp_HL_Max_Bear = DoubleToStr( Amp_HL_Max_Bear, 0 );
	string s_Amp_HL_Min_Bear = DoubleToStr( Amp_HL_Min_Bear, 0 );
	string s_Amp_HL_Avg_Bear = DoubleToStr( Amp_HL_Avg_Bear, 2 );
	string s_Amp_HL_Total_Bear = DoubleToStr( Amp_HL_Total_Bear, 0 );
	string s_Amp_OC_Max_Bear = DoubleToStr( Amp_OC_Max_Bear, 0 );
	string s_Amp_OC_Min_Bear = DoubleToStr( Amp_OC_Min_Bear, 0 );
	string s_Amp_OC_Avg_Bear = DoubleToStr( Amp_OC_Avg_Bear, 2 );
	string s_Amp_OC_Total_Bear = DoubleToStr( Amp_OC_Total_Bear, 0 );
	string s_Amp_Wick_Max_Bear = DoubleToStr( Amp_Wick_Max_Bear, 0 );
	string s_Amp_Wick_Min_Bear = DoubleToStr( Amp_Wick_Min_Bear, 0 );
	string s_Amp_Wick_Avg_Bear = DoubleToStr( Amp_Wick_Avg_Bear, 2 );
	string s_Amp_Wick_Total_Bear = DoubleToStr( Amp_Wick_Total_Bear, 0 );
	string s_Amp_Wick_Max_Bear_Up = DoubleToStr( Amp_Wick_Max_Bear_Up, 0 );
	string s_Amp_Wick_Min_Bear_Up = DoubleToStr( Amp_Wick_Min_Bear_Up, 0 );
	string s_Amp_Wick_Avg_Bear_Up = DoubleToStr( Amp_Wick_Avg_Bear_Up, 2 );
	string s_Amp_Wick_Total_Bear_Up = DoubleToStr( Amp_Wick_Total_Bear_Up, 0 );
	string s_Amp_Wick_Max_Bear_Down = DoubleToStr( Amp_Wick_Max_Bear_Down, 0 );
	string s_Amp_Wick_Min_Bear_Down = DoubleToStr( Amp_Wick_Min_Bear_Down, 0 );
	string s_Amp_Wick_Avg_Bear_Down = DoubleToStr( Amp_Wick_Avg_Bear_Down, 2 );
	string s_Amp_Wick_Total_Bear_Down = DoubleToStr( Amp_Wick_Total_Bear_Down, 0 );

/////////////////////////////////////////////////////////////////////////////////////////////
//запись в файл
/////////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////////
	//генерация имени файла
	/////////////////////////////////////////////////////////////////////////////////////////////
	string period = TimeFrame_str ( Period() );
	string file_name = Symbol() + "_" + period + "---" + Date_Start + "--" + Date_End + ".txt";

	/////////////////////////////////////////////////////////////////////////////////////////////
	//составление текста
	/////////////////////////////////////////////////////////////////////////////////////////////
	string razdel = " --------------------------------------------------------------------------------------" + "\n";
	string razdel_x2 = " --------------------------------------------------------------------------------------" + "\n" +
	"  --------------------------------------------------------------------------------------" + "\n";
	string razdel_x2_ent = " --------------------------------------------------------------------------------------" + "\n" +
	"\n" +
	"  --------------------------------------------------------------------------------------" + "\n";
	string razdel_enter = "|											|\n";

	string HL = "| Вся длина свечи (High - Low)								|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_HL_Total +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_HL_Min + ")	-	" + s_Amp_HL_Min +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_HL_Max + ")	-	" + s_Amp_HL_Max + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +						s_Amp_HL_Avg +  	"	Point(s) /" + period + "		|" + "\n" ;

	string OC =
	"| \"Тело\" свечи (для бычьей свечи = Close - Open)					|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_OC_Total +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_OC_Min + ")	-	" + s_Amp_OC_Min +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_OC_Max + ")	-	" + s_Amp_OC_Max + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_OC_Avg +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick =
	"| \"Фитиль\" - длина свечи без \"тела\" (для бычьей свечи = ((High - Close) + (Open - Low))|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min + ")	-	" + s_Amp_Wick_Min +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max + ")	-	" + s_Amp_Wick_Max + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Up =
	"| верхний \"Фитиль\"  (для бычьей свечи = (High - Close)					|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Up +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Up + ")	-	" + s_Amp_Wick_Min_Up +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Up + ")	-	" + s_Amp_Wick_Max_Up + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Up +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Down =
	"| нижний \"Фитиль\"  (для бычьей свечи = (Open - Low)					|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Down +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Down + ")	-	" + s_Amp_Wick_Min_Down +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Down + ")	-	" + s_Amp_Wick_Max_Down + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Down +  	"	Point(s) /" + period + "		|" + "\n" ;

	//bull
	string HL_Bull = "| Вся длина свечи 									|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_HL_Total_Bull +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_HL_Min_Bull + ")	-	" + s_Amp_HL_Min_Bull +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_HL_Max_Bull + ")	-	" + s_Amp_HL_Max_Bull + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +						s_Amp_HL_Avg_Bull +  	"	Point(s) /" + period + "		|" + "\n" ;

	string OC_Bull =
	"| \"Тело\" свечи 	 								|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_OC_Total_Bull +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_OC_Min_Bull + ")	-	" + s_Amp_OC_Min_Bull +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_OC_Max_Bull + ")	-	" + s_Amp_OC_Max_Bull + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_OC_Avg_Bull +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bull =
	"| \"Фитиль\"										|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bull +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bull + ")	-	" + s_Amp_Wick_Min_Bull +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bull + ")	-	" + s_Amp_Wick_Max_Bull + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bull +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bull_Up =
	"| верхний \"Фитиль\"									|" + "\n" +			
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bull_Up +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bull_Up + ")	-	" + s_Amp_Wick_Min_Bull_Up +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bull_Up + ")	-	" + s_Amp_Wick_Max_Bull_Up + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bull_Up +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bull_Down =
	"| нижний \"Фитиль\"									|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bull_Down +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bull_Down + ")	-	" + s_Amp_Wick_Min_Bull_Down +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bull_Down + ")	-	" + s_Amp_Wick_Max_Bull_Down + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bull_Down +  	"	Point(s) /" + period + "		|" + "\n" ;

	//bear
	string HL_Bear = "| Вся длина свечи 									|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_HL_Total_Bear +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_HL_Min_Bear + ")	-	" + s_Amp_HL_Min_Bear +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_HL_Max_Bear + ")	-	" + s_Amp_HL_Max_Bear + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +						s_Amp_HL_Avg_Bear +  	"	Point(s) /" + period + "		|" + "\n" ;

	string OC_Bear =
	"| \"Тело\" свечи 									|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_OC_Total_Bear +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_OC_Min_Bear + ")	-	" + s_Amp_OC_Min_Bear +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_OC_Max_Bear + ")	-	" + s_Amp_OC_Max_Bear + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_OC_Avg_Bear +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bear =
	"| \"Фитиль\" 										|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bear +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bear + ")	-	" + s_Amp_Wick_Min_Bear +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bear + ")	-	" + s_Amp_Wick_Max_Bear + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bear +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bear_Up =
	"| верхний \"Фитиль\"									|" + "\n" +			
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bear_Up +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bear_Up + ")	-	" + s_Amp_Wick_Min_Bear_Up +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bear_Up + ")	-	" + s_Amp_Wick_Max_Bear_Up + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bear_Up +  	"	Point(s) /" + period + "		|" + "\n" ;

	string Wick_Bear_Down =
	"| нижний \"Фитиль\"									|" + "\n" +
	" |											|\n" +
	" | Всего изменений				-	" + 				s_Amp_Wick_Total_Bear_Down +  "	Point(s)		|" + "\n" +
	" |" + " Мин. значение	(" + Date_Wick_Min_Bear_Down + ")	-	" + s_Amp_Wick_Min_Bear_Down +		"	Point(s)		|" + "\n" +
	" |" + " Макс. значение	(" + Date_Wick_Max_Bear_Down + ")	-	" + s_Amp_Wick_Max_Bear_Down + 	"	Point(s)		|" + "\n" +
	" | В среднем 					-	" +					s_Amp_Wick_Avg_Bear_Down +  	"	Point(s) /" + period + "		|" + "\n" ;

	string logo = 
	" \n" +
	" С предложениями-пожеланиями - добро пожаловать на мыло =)\n" +
	" komposterius@mail.ru ";

	int handle = FileOpen(file_name, FILE_WRITE, " ");
	if ( handle < 0 ) { Print( "FileOpen Error! GetLastError = ", GetLastError() ); return(-1); }

	/////////////////////////////////////////////////////////////////////////////////////////////
	//собственно, ввод информации
	/////////////////////////////////////////////////////////////////////////////////////////////
	FileWrite(handle,
	"",
	razdel,
	razdel_enter,
	"| Период расчёта - ", Year_Count, Month_Count, Day_Count, Hour_Count, Minute_Count, "\n",
	razdel_enter,
	razdel_x2_ent,
	razdel_enter,
	"| Статистика по ВСЕМ барам (", bars, "Bars )						|\n",
	razdel_enter,
	razdel_x2,
	HL,
	razdel,
	OC,
	razdel,
	Wick,
	razdel,
	Wick_Up,
	razdel,
	Wick_Down,
	razdel_x2_ent,
	razdel_enter,
	"| Статистика по БЫЧЬИМ барам (", Bull_Bars, "Bars )						|\n",
	razdel_enter,
	razdel_x2,
	HL_Bull,
	razdel,
	OC_Bull,
	razdel,
	Wick_Bull,
	razdel,
	Wick_Bull_Up,
	razdel,
	Wick_Bull_Down,
	razdel_x2_ent,
	razdel_enter,
	"| Статистика по МЕДВЕЖЬИМ барам (", Bear_Bars, "Bars )						|\n",
	razdel_enter,
	razdel_x2,
	HL_Bear,
	razdel,
	OC_Bear,
	razdel,
	Wick_Bear,
	razdel,
	Wick_Bear_Up,
	razdel,
	Wick_Bear_Down,
	razdel,
	logo );

	FileClose(handle);

	if ( Massage == 1 ) { Alert( "\"" + file_name + "\" writed successfully!" ); }
return(0);
}

/////////////////////////////////////////////////////////////////////////////////
/**/ string TimeFrame_str ( int _Period )
/////////////////////////////////////////////////////////////////////////////////
// возвращает Period в виде текста
/////////////////////////////////////////////////////////////////////////////////
{
	switch ( _Period )
	{
		case PERIOD_MN1: return("Monthly");
		case PERIOD_W1:  return("Weekly");
		case PERIOD_D1:  return("Daily");
		case PERIOD_H4:  return("H4");
		case PERIOD_H1:  return("H1");
		case PERIOD_M15: return("M15");
		case PERIOD_M5:  return("M5");
		case PERIOD_M1:  return("M1");
		default:		     return("UnknownPeriod");
	}
}

