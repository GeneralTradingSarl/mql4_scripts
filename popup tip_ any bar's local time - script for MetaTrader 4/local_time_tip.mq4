extern int INTERVAL_MILLIS = 100;
extern int serverzone = 0;
extern int localzone = 8;


int deinit()
   {
   ObjectDelete("test09msg");  
   WindowRedraw();
   return(0);
   }
   

int start()
   {

   int Diff = localzone - serverzone;
   int NumberOfVlines,tdate,thourminute;
   string VlineName,var1;
   datetime VlineTime, VlineTimePrevious, tlocal;
   double drawpos;
   

   while( !(IsTesting() || IsStopped()) ) 
      {
      
      drawpos = 0.1*WindowPriceMax() + 0.9*WindowPriceMin();  // <----- 0.1+0.9=1,(0.2+0.8,0.3+0.7....) just adjust this to change Text object hight position.
      
      NumberOfVlines = 0;
         
      for (int j=0; j<ObjectsTotal(); j++)
         {
         if( ObjectType(ObjectName(j))==OBJ_VLINE ) 
            { 
            VlineName = ObjectName(j);
            NumberOfVlines++;
            } 
         }      

      if(NumberOfVlines != 1)    //------ allow one and only one vline in chart, if this script doesn't work, please check vline numbers.      
         {
         Sleep(INTERVAL_MILLIS);
         }
      
      else VlineTime = ObjectGet(VlineName,OBJPROP_TIME1);

      if(VlineTime != VlineTimePrevious && NumberOfVlines == 1) 
         {
         if(ObjectFind("test09msg") == -1 )          
            ObjectCreate("test09msg", OBJ_TEXT, 0, VlineTime, drawpos);
         
         tlocal = VlineTime + (Diff * PERIOD_H1 * 60);
         
         tdate = TimeDay(tlocal) + TimeMonth(tlocal)*100 + TimeYear(tlocal)*10000; 
         
         thourminute = TimeMinute(tlocal) + TimeHour(tlocal)*100;
         
         ObjectSetText("test09msg", StringConcatenate("                                 ",tdate,"___",thourminute), 10, "Times New Roman", Gray);
         ObjectSet("test09msg",OBJPROP_TIME1,VlineTime);
         //Print(WindowPriceMin()*1.1);
         ObjectSet("test09msg",OBJPROP_PRICE1,drawpos);
         WindowRedraw();
                  
         VlineTimePrevious = VlineTime;
         
         }
         
      Sleep(INTERVAL_MILLIS);
      RefreshRates();
      }
   return(0);
}


