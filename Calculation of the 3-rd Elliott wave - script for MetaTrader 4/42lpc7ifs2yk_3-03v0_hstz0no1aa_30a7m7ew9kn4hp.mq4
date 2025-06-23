//+------------------------------------------------------------------+
//|                                    –асчет 3-ей волны Ёллиота.mq4 |
//|                                                         olyakish |
//|                                               olyakish@yandex.ru |
//+------------------------------------------------------------------+




extern int nBars=50;

string nameKrest[20];
double a_massKrest[20,2];
double p0,p1,p2;
int sh0,sh1,sh2;

//**************************************************************
int init()
{
   Comment(" ");
   ArrayResize(nameKrest,nBars);
   ArrayResize(a_massKrest,nBars);
   ArrayInitialize(a_massKrest,0);
   
   for (int i=0; i<=nBars; i++){nameKrest[i]=StringConcatenate("krest",i);}
   
   ObjectCreate("EXPANSION",OBJ_EXPANSION,0,iTime(NULL, 0, 30+nBars),High[30+nBars],iTime(NULL, 0, 20+nBars),High[30+nBars]+(High[30+nBars]-Low[30+nBars])*10,iTime(NULL, 0, 10+nBars),High[30+nBars]+(High[30+nBars]-Low[30+nBars])*5);   
   ObjectSet("EXPANSION",OBJPROP_COLOR,Aqua);
   ObjectSet("EXPANSION",OBJPROP_FIBOLEVELS,1);   
   ObjectSet("EXPANSION",OBJPROP_FIRSTLEVEL+1,1);
   ObjectSet("EXPANSION",OBJPROP_LEVELCOLOR,Black);
   ObjectSet("EXPANSION",OBJPROP_BACK,True);
   
   –асчет();
   
   return(0);   
} 
//**************************************************************

void –асчет()
{
   int Shift[3],i;
   double Price[3];
   bool Bull=false;
   bool Bear=false;
   double s1,s2,s3;
   Shift[0]=iBarShift(NULL,0,ObjectGet("EXPANSION",OBJPROP_TIME1),false);
   Shift[1]=iBarShift(NULL,0,ObjectGet("EXPANSION",OBJPROP_TIME2),false);
   Shift[2]=iBarShift(NULL,0,ObjectGet("EXPANSION",OBJPROP_TIME3),false);
   Price[0]=ObjectGet("EXPANSION",OBJPROP_PRICE1);
   Price[1]=ObjectGet("EXPANSION",OBJPROP_PRICE2);
   Price[2]=ObjectGet("EXPANSION",OBJPROP_PRICE3);
   
   if (Price[0]<Price[1] && Price[1]>Price[2] && Price[0]<Price[2])
      {
         Comment ("–асчет дл€ бычьего варианта");
         Bull=true;
      }
   if (Price[0]>Price[1] && Price[1]<Price[2] && Price[0]>Price[2])
      {
         Comment ("–асчет дл€ медвежьего варианта");
         Bear=true;
      }

   if (Bull && (p0!=Price[0] || p1!=Price[1] || p2!=Price[2] || sh0!=Shift[0] || sh1!=Shift[1] || sh2!=Shift[2]))
      {
         p0=Price[0];
         p1=Price[1];
         p2=Price[2];
         sh0=Shift[0];
         sh1=Shift[1];
         sh1=Shift[2];
         
         s1=0.5* (Shift[0]-Shift[1])*(Price[1]-Price[0]);   // ѕлощадь под первой волной
         s2=0.5* (Shift[1]-Shift[2])*(Price[1]-Price[2]);   // ѕлощадь под  второй волной
         s3=(s1+s2)/0.618;                                  // –асчетна€ площадь под третьей волной
        
         //----заполн€ем массив смещений и цен дл€ крестиков

         for (i=1;i<=nBars;i++)
            {
               a_massKrest[i,0]=Shift[2]-i;                    // размещение во времени 
               a_massKrest[i,1]=(s3*2)/(i)+Price[2];           // размещение по шкале цены             
               if (ObjectFind(nameKrest[i])!=-1)
                  {
                     ObjectSet(nameKrest[i],OBJPROP_PRICE1,a_massKrest[i,1]);
                     ObjectSet(nameKrest[i],OBJPROP_TIME1,iTime(NULL, 0,a_massKrest[i,0]));                     
                  }
               else  
                  { 
                     ObjectCreate(nameKrest[i],OBJ_ARROW,0,iTime(NULL, 0,a_massKrest[i,0]),a_massKrest[i,1],0,0,0,0);                     
                     ObjectSet(nameKrest[i],OBJPROP_ARROWCODE,251);
                     ObjectSet(nameKrest[i],OBJPROP_COLOR,Red);
                   }
            }     

      }
   if (Bear && (p0!=Price[0] || p1!=Price[1] || p2!=Price[2] || sh0!=Shift[0] || sh1!=Shift[1] || sh2!=Shift[2]))
      {
         p0=Price[0];
         p1=Price[1];
         p2=Price[2];
         sh0=Shift[0];
         sh1=Shift[1];
         sh1=Shift[2];
         
         s1=0.5* (Shift[0]-Shift[1])*(Price[0]-Price[1]);   // ѕлощадь под первой волной
         s2=0.5* (Shift[1]-Shift[2])*(Price[2]-Price[1]);   // ѕлощадь под  второй волной
         s3=(s1+s2)/0.618;                                  // –асчетна€ площадь под третьей волной
        
         //----заполн€ем массив смещений и цен дл€ крестиков

         for (i=1;i<=nBars;i++)
            {
               a_massKrest[i,0]=Shift[2]-i;                    // размещение во времени 
               a_massKrest[i,1]=Price[2]-(s3*2)/(i);          // размещение по шкале цены             
               if (ObjectFind(nameKrest[i])!=-1)
                  {
                     ObjectSet(nameKrest[i],OBJPROP_PRICE1,a_massKrest[i,1]);
                     ObjectSet(nameKrest[i],OBJPROP_TIME1,iTime(NULL, 0,a_massKrest[i,0]));                     
                  }
               else  
                  { 
                     ObjectCreate(nameKrest[i],OBJ_ARROW,0,iTime(NULL, 0,a_massKrest[i,0]),a_massKrest[i,1],0,0,0,0);                     
                     ObjectSet(nameKrest[i],OBJPROP_ARROWCODE,251);
                     ObjectSet(nameKrest[i],OBJPROP_COLOR,Red);
                   }
            }     
      }      


   return(0);   
}

  
//**************************************************************
void deinit()
{
   for (int i=1;i<=nBars;i++)
      {
          if (ObjectFind(nameKrest[i])!=-1)
            {
                ObjectDelete(nameKrest[i]);
            }
      }      
   ObjectDelete("EXPANSION");
   Comment(" ");
}
//***************************************************************

int start()
{
     while(IsStopped()==false)
      {
         Sleep(500);
         –асчет();
      }
}

//***************************************************************


