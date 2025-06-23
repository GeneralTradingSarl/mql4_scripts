//+------------------------------------------------------------------+
//|                                            Histo ranges_v001.mq4 |
//|                                                  Rafaell (okfar) |
//|                                                            http: |
//+------------------------------------------------------------------+
#property copyright "Rafaell (okfar)"
#property link      "http:"
#property show_inputs

extern int   agoYear=1, 
             agoMonth=0,  
             agoWeek=0, 
             agoDays=0,
             nrange=12;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----

    
    
   int sDataBar;
   int i,j, rangeMax, rangeMin;
   int typHist = 1;
   int OpenTime = 0;
   double range[];
   datetime    dateRangeMax,
               dateRangeMin,
               dateRangeS,
               dateRangeF;
   double dRange;
    
   double hrange[];           
   int n[];           
    
   int nBarD = iBars(Symbol(), PERIOD_D1); 
   ArrayResize(hrange, nrange+1);
   ArrayResize(n, nrange);
   

   sDataBar = iBarShift(NULL, PERIOD_D1, StartBar(agoYear, agoMonth, agoWeek, agoDays, typHist, OpenTime), False);
   dateRangeS = iTime(Symbol(), PERIOD_D1, sDataBar);
   dateRangeF =  iTime(Symbol(), PERIOD_D1, 1);

   ArrayResize(range, sDataBar);
   for (i=sDataBar; i>0; i--) {
      range[i-1] = iHigh(Symbol(), PERIOD_D1, i) - iLow(Symbol(), PERIOD_D1, i);
      if (range[i-1] == 0)
          if (iHigh(Symbol(), PERIOD_D1, i) == 0) {
            Alert ("Pleas check your input parameters. History data missing!");
            return(0);
          }
   }
   rangeMax = ArrayMaximum(range);
double   rangeMaxA = range[rangeMax];
   dateRangeMax = iTime(Symbol(), PERIOD_D1, rangeMax+1);
   
   rangeMin = ArrayMinimum(range);
double   rangeMinA = range[rangeMin];
   dateRangeMin = iTime(Symbol(), PERIOD_D1, rangeMin+1);
  // ArraySort(range, WHOLE_ARRAY, 0, MODE_ASCEND); 
         
         
   dRange = (MathLog(rangeMaxA) - MathLog(rangeMinA/*-1*Point*/))/((nrange-1)*1.0);
   hrange[0] = rangeMinA-1*Point;
   
   //hrange[0] = range[0]-1*Point;
   double sumRange = 0;
   for (i=0; i<nrange; i++) 
      hrange[i+1] = MathLog(hrange[0]) + (i+1)*dRange;
   for (i=1; i<=nrange; i++) 
      hrange[i] = NormalizeDouble(MathExp(hrange[i]), Digits);
         
   int nsum = 0;
   for (i=sDataBar-1; i>=0; i--) {
      nsum ++;
      sumRange += range[i];
      for (j=nrange; j>0 ; j--)  { 
         if (range[i] < hrange[j] && range[i] >= hrange[j-1]) {
            n[j-1] ++;
           // break;
         }
      }
   }
        
   
   
   string text = StringConcatenate("  <",hrange[1],"\t\t", n[0], "\n");
   for (i=1; i<nrange-1;i++) { 
      text = StringConcatenate(text, hrange[i] ," - (", hrange[i+1],")\t\t", n[i],"\n");
   }   
      text = StringConcatenate(text, " > " ,hrange[nrange-1] ,"\t\t", n[nrange-1],"\n");
   
   

      string msg =   "  Pair: (from - to)\t\t" + Symbol() + " ("+TimeToStr(dateRangeS, TIME_DATE) + " - " +TimeToStr(dateRangeF, TIME_DATE) + ")\n" + 
                  "  Min:\t\t" + DoubleToStr(rangeMinA,Digits) + "\t(" + TimeToStr(dateRangeMin, TIME_DATE) + ")\n" +
                  "  Max:\t\t" + DoubleToStr(rangeMaxA,Digits) + "\t(" + TimeToStr(dateRangeMax, TIME_DATE) + ")\n" +                   
                  "  Avg:\t\t" + DoubleToStr(sumRange/nsum, Digits) + "\tn= "+ nsum +"\n\n" +
                  "  Range\t\t No. \n" +  
                    text + "\n" ;
 
   MessageBox(msg, "Daily range statistics", 0);
//----
   return(0);
  }
//+------------------------------------------------------------------+


datetime StartBar(int dye, int dmo, int dwe, int dda, int typ, int ot)
{
   int ye,mo,da,ho;
   datetime ct;
     
      
   ct=TimeCurrent();
   switch (typ) {
      case 0: {
         ct -= 60*60*(24)*(dda-1);
         ct -= 60*60*24*(7)*(dwe);
         
         ye = TimeYear(ct);
         mo = TimeMonth(ct);
         da = TimeDay(ct);
         ho = TimeHour(ct);

         if (dda > 0)
            ho=0;
         if (dwe > 0) {
            da -= (TimeDayOfWeek(TimeCurrent())-1);
            ho=0;
            //da -= DayOfWeek();      
         }
         if (dmo > 0) {
           da=1;
           ho=0;
           mo -= (dmo-1);
           while (mo < 0) {
               mo +=12;
               ye -= 1;
            }
         }
         if (dye > 0) {
           da=1;
           mo=1;
           // da  -= DayOfYear()+1 ;
           ho=0;
           ye -= (dye-1);
         
         }
       if (ot != 0) {
           ct = StrToTime(da+"."+mo+"."+ye+" "+ho);
           if (ot > TimeHour(TimeCurrent()))
               ct = ct + (ot-24)*3600;     
           else 
             ct += (ot)*3600;    
           //cd -=  (ot)*3600
           ye = TimeYear(ct);
           mo = TimeMonth(ct);
           da = TimeDay(ct);
           ho = TimeHour(ct);
        }
        
      } break;
      
      case 1: {      
         ct = TimeCurrent()+3600;
         if (dda > 0) 
            ct -= 60*60*(24)*dda;
         if (dwe > 0)
            ct -= 60*60*24*(7)*dwe;   
      
         ye = TimeYear(ct);
         mo = TimeMonth(ct);
         da = TimeDay(ct);
         ho = TimeHour(ct);
      
         if (dmo > 0) {
            mo -= dmo;
            while (mo < 0) {
               mo +=12;
               ye -= 1;
            }
         }
         if (dye > 0) {
            ye -= dye;
         }
     } break;
     
     default: {
         ye = Year();
          mo = Month();
          da = Day();
         ho = Hour();   
     } break;
  }   
 // return (StrToTime(StringConcatenate(/*"D'",*/da,".",mo,".",ye," ",ho/*,"'"*/)));
  return (StrToTime(da+"."+mo+"."+ye+" "+ho));   
} 

