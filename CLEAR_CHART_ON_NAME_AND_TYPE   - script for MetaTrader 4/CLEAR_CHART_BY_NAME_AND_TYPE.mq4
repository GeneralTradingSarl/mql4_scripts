//+------------------------------------------------------------------+
//|                                                  CLEAR_CHART.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+
#property copyright "AP"
#property link      "ekr-ap@mail.ru"
#property show_inputs
/*
If all fields inactive - are deleted by all
If one field = is set even deletes only this type
For example:
If the field delete_Partial_name = ааа // удалzет all having it as a part of a name is set
If field Trend_line=true is set; // deletes all inclined lines
........................
если все поля неактивные - удаляет все
если задано хотя бы одно поле = удаляет только этот тип
например:
если задано поле delete_Partial_name = ааа //удалzет все имеющее это как часть имени
если задано поле Trend_line=true; //удаляет все наклонные линии
*/
extern string delete_on_Partial_name="";

extern bool Vertical_line=false;
extern bool Horisontal_line=false;
extern bool Trend_line=false;
extern bool Trendbyangle_line=false;
extern bool Regression_chanel=false;
extern bool _chanel=false;
extern bool StdDev_chanel=false;
extern bool Gann_line=false;
extern bool GannFan=false;
extern bool GannGrid=false;
extern bool FIBO=false;
extern bool FIBO_times=false;
extern bool FIBO_fan=false;
extern bool FIBO_arc=false;
extern bool Expansion=false;
extern bool FIBO_channel=false;
extern bool Restangle=false;
extern bool Triangle=false;
extern bool Ellipse=false;
extern bool PitchFork=false;
extern bool Cycles=false;
extern bool Text=false;
extern bool Arrow=false;
extern bool Label=false;

bool u[24];
int init()
{
u[0]=Vertical_line; u[1]=Horisontal_line; u[2]=Trend_line; u[3]=Trendbyangle_line;
u[4]=Regression_chanel; u[5]=_chanel; u[6]=StdDev_chanel; u[7]=Gann_line;
u[8]=GannFan; u[9]=GannGrid; u[10]=FIBO; u[11]=FIBO_times;
u[12]=FIBO_fan; u[13]=FIBO_arc; u[14]=Expansion; u[15]=FIBO_channel;
u[16]=Restangle; u[17]=Triangle; u[18]=Ellipse; u[19]=PitchFork;
u[20]=Cycles; u[21]=Text; u[22]=Arrow; u[23]=Label; 
}

int start()
  {
//----
   string s; 
   int j,k,_type;
   k=ObjectsTotal();
   bool w1=false;
   for(j=0;j<24;j++) if(u[j]) w1=true;
      if(!w1&&StringLen(delete_on_Partial_name)==0)
         for (int i=k-1;i>=0; i--) //удаляем все//delte ALL
         {
         s=ObjectName(i);
         ObjectDelete(s);
         }else
    {
         if(StringLen(delete_on_Partial_name)!=0) 
            for (i=k-1;i>=0; i--)//удаляем партию//delete partial 
            {
            s=ObjectName(i);
            if(StringFind(s,delete_on_Partial_name,0)>=0)ObjectDelete(s);
            }
   
      if(w1)//если хоть один
         for (i=k-1;i>=0; i--)//удаление по типу//delete by type
         {
         s=ObjectName(i);
         _type=ObjectType(s);
         if(_type>=0&&_type<=23)
            {
            for(j=0;j<24;j++)
            if(u[_type]) ObjectDelete(s);
            }
         }
      }//else
   
   return(0);
  }

