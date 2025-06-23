/*------------------------------------------------------------------+     
 |                                                     Avg_02b.mq4  |
 |                                                Copyright © 2010  |
 +------------------------------------------------------------------*/ 
#property  copyright "Copyright © 2010, basisforex@gmail.com"
#property  link      "basisforex@gmail.com"
//+-----------------------------------------------------------------+
int start()
 {
   if(Period() != 60)
    {
		Comment("Not a right Period!!! It should be H1.");
		return(0);	
	 } 
   int d = 390;
   int a, b, k, j, H = 24;
   int c[25];   
   for(j = 0; j < H; j++)
    {      
      for(k = 1; k <= H * d; k++)
       {
         if(TimeHour(iTime(NULL, 0, k)) == j)
          {
            a = (High[k] - Low[k]) / Point;         
            b = b + a;                              
          }
       }
      c[j] = b / d; 
      a = 0; b = 0;    
    }
   string t0 = "Hour= 0" + "     Avg= " + c[0] + "\n"; 
   string t1 = "Hour= 1" + "     Avg= " + c[1] + "\n"; 
   string t2 = "Hour= 2" + "     Avg= " + c[2] + "\n"; 
   string t3 = "Hour= 3" + "     Avg= " + c[3] + "\n"; 
   string t4 = "Hour= 4" + "     Avg= " + c[4] + "\n"; 
   string t5 = "Hour= 5" + "     Avg= " + c[5] + "\n"; 
   string t6 = "Hour= 6" + "     Avg= " + c[6] + "\n"; 
   string t7 = "Hour= 7" + "     Avg= " + c[7] + "\n"; 
   string t8 = "Hour= 8" + "     Avg= " + c[8] + "\n"; 
   string t9 = "Hour= 9" + "     Avg= " + c[9] + "\n"; 
   string t10 = "Hour= 10" + "   Avg= " + c[10] + "\n"; 
   string t11 = "Hour= 11" + "   Avg= " + c[11] + "\n"; 
   string t12 = "Hour= 12" + "   Avg= " + c[12] + "\n"; 
   string t13 = "Hour= 13" + "   Avg= " + c[13] + "\n"; 
   string t14 = "Hour= 14" + "   Avg= " + c[14] + "\n"; 
   string t15 = "Hour= 15" + "   Avg= " + c[15] + "\n"; 
   string t16 = "Hour= 16" + "   Avg= " + c[16] + "\n"; 
   string t17 = "Hour= 17" + "   Avg= " + c[17] + "\n"; 
   string t18 = "Hour= 18" + "   Avg= " + c[18] + "\n"; 
   string t19 = "Hour= 19" + "   Avg= " + c[19] + "\n"; 
   string t20 = "Hour= 20" + "   Avg= " + c[20] + "\n"; 
   string t21 = "Hour= 21" + "   Avg= " + c[21] + "\n"; 
   string t22 = "Hour= 22" + "   Avg= " + c[22] + "\n"; 
   string t23 = "Hour= 23" + "   Avg= " + c[23]; 
   Comment(t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11, t12, t13, t14, t15, t16, t17, t18, t19, t20, t21, t22, t23);          
 }}