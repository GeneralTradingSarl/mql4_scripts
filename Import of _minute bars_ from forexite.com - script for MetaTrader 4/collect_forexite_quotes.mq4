//+------------------------------------------------------------------+
//|                                      import_forexite_history.mq4 |
//|                                       Copyright © 2007, Mathemat |
//|                                                                  |
//+------------------------------------------------------------------+

/* На основе обработки текстовых файлов с forexite.com в формате для Метастока выбирает
только котировки нужного инструмента и собирает их в один файл. Даты из текущего тысячелетия. */

#property copyright "Copyright © 2007, Mathemat"
#property show_inputs

extern string _sSymbol  = "XAUUSD";
extern string _fromDate = "2002.01.01";
extern string _toDate   = "2007.06.13";


/* считывает все из одного файла, формируя длинную строку с разделителями */
string ReadAllStrings( int handle, string ss )
{
   string s; 
   string res = "";
   while(!FileIsEnding( handle ) )
   {
      s = FileReadString( handle );
      if ( StringFind( s, ss ) > -1 )  res = res + s + "\n";
   }
   return ( StringTrimRight( res ) );
}



/* даты во внутреннем формате МТ4. Возвращает следующую правильную дату 
во внутреннем строковом формате. */
string nextDayInternal( string curDayInternal )
{
   string res = TimeToStr( StrToTime( curDayInternal ) + 1440 * 60, TIME_DATE );
   return( res );
}



/* Переводит дату в формате YYYY.MM.DD (внутренний МТ4) в формат имени файла с Forexite.com */
string InternalDateToForexiteFilename( string dateInternal )
{
   datetime dt = StrToTime( dateInternal );
   
   string sDay   = DoubleToStr( TimeDay( dt ), 0 );
   if ( StringLen( sDay ) == 1 ) sDay = "0" + sDay;
   
   string sMonth = DoubleToStr( TimeMonth( dt ), 0 ) ;
   if ( StringLen( sMonth ) == 1 ) sMonth = "0" + sMonth;
   
   string sYear  = StringSubstr( DoubleToStr( TimeYear( dt ), 0 ), 2, 2 );
   
   return( sDay + sMonth + sYear + ".txt" );
}


int start()
{
   int counterOpened = 0;
   string filename;
   string fileWritten;
   string s;
   string path = "\\Forexite\\";
   int handleWritten = FileOpen( _sSymbol + "_ALL.csv", FILE_CSV|FILE_WRITE, " " );
   
   string sDate = _fromDate;
   while( StrToTime( sDate ) <= StrToTime( _toDate ) )
   {
      filename = InternalDateToForexiteFilename( sDate );
      if ( MathAbs( TimeDayOfWeek( StrToTime( sDate ) ) - 3 ) == 3 )  
      {
         sDate = nextDayInternal( sDate );
      }   
      else   
      {
         int handle = FileOpen( path + filename, FILE_CSV | FILE_READ );
         if ( handle < 0 )    
         {
            Print( filename + ": no file present" ); 
            sDate = nextDayInternal( sDate );
         }   
         else               
         {
            counterOpened++;
            s = ReadAllStrings( handle, _sSymbol );
            FileWrite( handleWritten, s );
            FileClose( handle );
            FileFlush( handleWritten );
            Comment( "Days processed: " + counterOpened );
            sDate = nextDayInternal( sDate );
         }   
      }   
   }   
   FileClose( handleWritten );
   Comment( "" );
   return(0);
}