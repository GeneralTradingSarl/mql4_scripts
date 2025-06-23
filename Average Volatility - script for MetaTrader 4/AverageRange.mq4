//+------------------------------------------------------------------+
//|                                                 AverageRange.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|   14.09.2005  Скрипт для расчёта:                                |
//| средней волатильности инструмента High-Low                       |
//| среднего размера тела свечи       ABS(Open-Close)                |
//| среднего размера тени свечи                                      |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"
#property show_inputs

extern datetime BeginDateCalc = D'2001.01.01';
extern datetime EndDateCalc   = D'2005.09.30';

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start() {
  int    i, b=0, bb=0, eb, h=0, l=0, s=0, t=0;
  string comm="";

  for (i=Bars; i>0; i--) {
    if (Time[i]>=BeginDateCalc && Time[i]<=EndDateCalc) {
      if (bb==0) bb=i;
      s+=(High[i]-Low[i])/Point;
      t+=MathAbs(Open[i]-Close[i])/Point;
      if (Open[i]>Close[i]) {
        h+=(High[i]-Open[i])/Point;
        l+=(Close[i]-Low[i])/Point;
      } else {
        h+=(High[i]-Close[i])/Point;
        l+=(Open[i]-Low[i])/Point;
      }
      b++;
    }
  }

  comm = "Начало: " + TimeToStr(Time[bb], TIME_DATE|TIME_MINUTES) + "\n";
  comm = comm + "Конец: " + TimeToStr(Time[bb-b+1], TIME_DATE|TIME_MINUTES) + "\n";
  comm = comm + "Средняя волатильность: " + s/b + " п.\n";
  comm = comm + "Средний размер тела: " + t/b + " п.\n";
  comm = comm + "Средний размер верхней тени: " + h/b + " п.\n";
  comm = comm + "Средний размер нижней тени: " + l/b + " п.";

  Comment(comm);
}
//+------------------------------------------------------------------+

