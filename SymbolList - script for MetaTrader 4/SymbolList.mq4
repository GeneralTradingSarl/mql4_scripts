//+------------------------------------------------------------------+
//|                                                   SymbolList.mq4 |
//|                                      Copyright © 2006, komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, komposter"
#property link      "mailto:komposterius@mail.ru"

#property show_inputs

extern int Min_CharsInSymbolName = 0;
extern int Max_CharsInSymbolName = 6;

extern bool Use_Reshetka			= false;
extern bool Use_Podcherkivanie	= false;
extern bool Use_09					= false;
extern bool Use_AZ					= true;
extern bool Use_az					= false;

int start()
{
	string Symbols[1000], tmpSymbol = "";
	int CharsCount = 0, SymbolsCount = 0, CurChar, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, StartTickCount = GetTickCount();
	string Chars[1000];

	if ( Max_CharsInSymbolName < 1  ) { Comment( "Max_CharsInSymbolName < 1  !!!" ); return(0); }
	if ( Min_CharsInSymbolName > 10 ) { Comment( "Min_CharsInSymbolName > 10 !!!" ); return(0); }

	if ( Use_Reshetka  )														// "#"
	{
		Chars[CharsCount] = "#";
		CharsCount ++;
	}
	if ( Use_Podcherkivanie  )												// "_"
	{
		Chars[CharsCount] = "_";
		CharsCount ++;
	}
	if ( Use_09 )																// "0" - "9"
	{
		for ( CurChar = 48; CurChar < 58;  CurChar ++ )
		{
			Chars[CharsCount] = CharToStr(CurChar);
			CharsCount ++;
		} 
	}
	if ( Use_AZ )																// "A" - "Z"
	{
		for ( CurChar = 65; CurChar < 91;  CurChar ++ )
		{
			Chars[CharsCount] = CharToStr(CurChar);
			CharsCount ++;
		} 
	}
	if ( Use_az )																// "a" - "z"
	{
		for ( CurChar = 97; CurChar < 123;  CurChar ++ )
		{
			Chars[CharsCount] = CharToStr(CurChar);
			CharsCount ++;
		} 
	}
	if ( CharsCount < 1  ) { Comment( "Не выбраны символы для перебора!!!" ); return(0); }
	ArrayResize( Chars, CharsCount );

	//---- оценочное время работы = кол-во комбинаций * время проверки одной комбинации на моем компе =)
	double count_seconds = MathPow(CharsCount,Max_CharsInSymbolName)*0.00000350;
	double count_minutes = MathFloor(count_seconds/60.0);
	count_seconds -= count_minutes*60;
	double count_hours = MathFloor(count_minutes/60.0);
	count_minutes -= count_hours*60;

	Comment( "Поиск займет приблизительно ", NormalizeDouble( count_hours, 0 ), " ч ", NormalizeDouble( count_minutes, 0 ), " м ", NormalizeDouble( count_seconds, 0 ), " с, ждите...." );

	for ( s1 = 0; s1 < CharsCount; s1 ++ )
	{
		if ( Min_CharsInSymbolName <= 1 )
		{
			tmpSymbol = Chars[s1];
			if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
			{
				Symbols[SymbolsCount] = tmpSymbol;
				SymbolsCount ++;
			}
		}
		if ( Max_CharsInSymbolName < 2 ) { continue; }

		for ( s2 = 0; s2 < CharsCount; s2 ++ )
		{
			if ( Min_CharsInSymbolName <= 2 )
			{
				tmpSymbol = StringConcatenate( Chars[s1], Chars[s2] );
				if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
				{
					Symbols[SymbolsCount] = tmpSymbol;
					SymbolsCount ++;
				}
			}
			if ( Max_CharsInSymbolName < 3 ) { continue; }

			for ( s3 = 0; s3 < CharsCount; s3 ++ )
			{
				if ( Min_CharsInSymbolName <= 3 )
				{
					tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3] );
					if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
					{
						Symbols[SymbolsCount] = tmpSymbol;
						SymbolsCount ++;
					}
				}
				if ( Max_CharsInSymbolName < 4 ) { continue; }

				for ( s4 = 0; s4 < CharsCount; s4 ++ )
				{
					if ( Min_CharsInSymbolName <= 4 )
					{
						tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4] );
						if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
						{
							Symbols[SymbolsCount] = tmpSymbol;
							SymbolsCount ++;
						}
					}
					if ( Max_CharsInSymbolName < 5 ) { continue; }

					for ( s5 = 0; s5 < CharsCount; s5 ++ )
					{
						if ( Min_CharsInSymbolName <= 5 )
						{
							tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5] );
							if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
							{
								Symbols[SymbolsCount] = tmpSymbol;
								SymbolsCount ++;
							}
						}
						if ( Max_CharsInSymbolName < 6 ) { continue; }

						for ( s6 = 0; s6 < CharsCount; s6 ++ )
						{
							if ( Min_CharsInSymbolName <= 6 )
							{
								tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5], Chars[s6] );
								if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
								{
									Symbols[SymbolsCount] = tmpSymbol;
									SymbolsCount ++;
								}
							}
							if ( Max_CharsInSymbolName < 7 ) { continue; }

							for ( s7 = 0; s7 < CharsCount; s7 ++ )
							{
								if ( Min_CharsInSymbolName <= 7 )
								{
									tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5], Chars[s6], Chars[s7] );
									if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
									{
										Symbols[SymbolsCount] = tmpSymbol;
										SymbolsCount ++;
									}
								}
								if ( Max_CharsInSymbolName < 8 ) { continue; }

								for ( s8 = 0; s8 < CharsCount; s8 ++ )
								{
									if ( Min_CharsInSymbolName <= 8 )
									{
										tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5], Chars[s6], Chars[s7], Chars[s8] );
										if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
										{
											Symbols[SymbolsCount] = tmpSymbol;
											SymbolsCount ++;
										}
									}
									if ( Max_CharsInSymbolName < 9 ) { continue; }

									for ( s9 = 0; s9 < CharsCount; s9 ++ )
									{
										if ( Min_CharsInSymbolName <= 9 )
										{
											tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5], Chars[s6], Chars[s7], Chars[s8], Chars[s9] );
											if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
											{
												Symbols[SymbolsCount] = tmpSymbol;
												SymbolsCount ++;
											}
										}
										if ( Max_CharsInSymbolName < 10 ) { continue; }

										for ( s10 = 0; s10 < CharsCount; s10 ++ )
										{
											if ( Min_CharsInSymbolName <= 10 )
											{
												tmpSymbol = StringConcatenate( Chars[s1], Chars[s2], Chars[s3], Chars[s4], Chars[s5], Chars[s6], Chars[s7], Chars[s8], Chars[s9], Chars[s10] );
												if ( MarketInfo( tmpSymbol, MODE_BID ) > 0 )
												{
													Symbols[SymbolsCount] = tmpSymbol;
													SymbolsCount ++;
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	count_seconds = (GetTickCount() - StartTickCount)/1000;
	count_minutes = MathFloor(count_seconds/60.0);
	count_seconds = count_seconds - count_minutes*60;
	count_hours = MathFloor(count_minutes/60.0);
	count_minutes -= count_hours*60;

	if ( SymbolsCount < 1  )
	{
		Comment( StringConcatenate( "Время работы: ", NormalizeDouble( count_hours, 0 ), " ч ", NormalizeDouble( count_minutes, 0 ), " м ", NormalizeDouble( count_seconds, 0 ), " с \nНе найдено ни одного символа, отвечающего условиям!!!" ) );
		return(0);
	}

	ArrayResize( Symbols, SymbolsCount );

	string strAllSymbols = Symbols[0];
	for ( int CurSymbol = 1; CurSymbol < SymbolsCount; CurSymbol ++ )
	{
		strAllSymbols = StringConcatenate( strAllSymbols, "\n", Symbols[CurSymbol] );
	}
	Comment( StringConcatenate( "Время работы: ", NormalizeDouble( count_hours, 0 ), " ч ", NormalizeDouble( count_minutes, 0 ), " м ", NormalizeDouble( count_seconds, 0 ), " с \nНайдено ", SymbolsCount, " символов:\n", strAllSymbols ) );

	int handle = FileOpen( StringConcatenate( "SymbolList(", ServerAddress(), ").csv" ), FILE_CSV | FILE_WRITE );
	if ( handle < 0 )
	{
		Print( "Ошибка №", GetLastError(), " при открытии файла!!!" );
		return(-1);
	}
	FileWrite(	handle,
					"SYMBOL",
					"POINT",
					"DIGITS",
					"SPREAD",
					"STOPLEVEL",
					"LOTSIZE",
					"TICKVALUE",
					"TICKSIZE",
					"SWAPLONG",
					"SWAPSHORT",
					"STARTING",
					"EXPIRATION",
					"TRADEALLOWED",
					"MINLOT",
					"LOTSTEP",
					"MAXLOT"
					);
	for ( CurSymbol = 0; CurSymbol < SymbolsCount; CurSymbol ++ )
	{
		FileWrite(	handle,
						Symbols[CurSymbol],
						MarketInfo( Symbols[CurSymbol], MODE_POINT ),
						MarketInfo( Symbols[CurSymbol], MODE_DIGITS ),
						MarketInfo( Symbols[CurSymbol], MODE_SPREAD ),
						MarketInfo( Symbols[CurSymbol], MODE_STOPLEVEL ),
						MarketInfo( Symbols[CurSymbol], MODE_LOTSIZE ),
						MarketInfo( Symbols[CurSymbol], MODE_TICKVALUE ),
						MarketInfo( Symbols[CurSymbol], MODE_TICKSIZE ),
						MarketInfo( Symbols[CurSymbol], MODE_SWAPLONG ),
						MarketInfo( Symbols[CurSymbol], MODE_SWAPSHORT ),
						MarketInfo( Symbols[CurSymbol], MODE_STARTING ),
						MarketInfo( Symbols[CurSymbol], MODE_EXPIRATION ),
						MarketInfo( Symbols[CurSymbol], MODE_TRADEALLOWED ),
						MarketInfo( Symbols[CurSymbol], MODE_MINLOT ),
						MarketInfo( Symbols[CurSymbol], MODE_LOTSTEP ),
						MarketInfo( Symbols[CurSymbol], MODE_MAXLOT )
						 );
	}
	FileClose( handle );
	return(0);
}

