//+------------------------------------------------------------------+
//|                                           ChangeObjectsColor.mq4 |
//|                                          Andrew Shelkovenko, SPb |
//|                                                   diakin@list.ru |
//+------------------------------------------------------------------+
#property copyright "sHell"
#property link      "diakin@list.ru"
#property show_inputs


// Based on 
//+------------------------------------------------------------------+
//|                                                  CLEAR_CHART.mq4 |
//|                                            Aleksandr Pak, Almaty |
//|                                                   ekr-ap@mail.ru |
//+------------------------------------------------------------------+


/*
if UseOldColor=true change colors for objects that color=OldColor

If all fields set false - change colors for all objects

If one field set true = change color of this object type only
If the change_by_Partial_name field not empty = change color of this object that name contains this field substring

If field Trend_line=true is set; // change color of Trend lines only
........................
если все поля установлены в false - меняет цвет всех объектов
если хотя бы одно поле установлено в true = меняет цвет только объектов этого типа
например:
если задано поле change_by_Partial_name = меняет цвет всех объектов имя которых содержит заданную подстроку
если задано поле Trend_line=true; //меняет цвет всех трендовых линий
*/
extern string change_by_Partial_name="";

extern bool UseOldColor=false;
extern color OldColor=Blue;
extern color NewColor=Aqua;


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
   string objname; 
   int j,k,_type;
   color objcolor;
   k=ObjectsTotal();
   bool w1=false;
   //Comment ("Begin..............");
   
   for(j=0;j<24;j++) if(u[j]) w1=true;
      
      if(!w1 && StringLen(change_by_Partial_name)==0)
         
         for (int i=k-1;i>=0; i--) //меняем все \change all
         {
         objname=ObjectName(i);
         
         objcolor=ObjectGet( objname, OBJPROP_COLOR) ;
         if ((objcolor==OldColor && UseOldColor==true) || UseOldColor==false)
         ObjectSet( objname, OBJPROP_COLOR, NewColor);
         }
      else
    {
         if(StringLen(change_by_Partial_name)!=0) 
            for (i=k-1;i>=0; i--)
            {
            objname=ObjectName(i);
   //         Comment ("objname",objname);
            
            objcolor=ObjectGet( objname, OBJPROP_COLOR) ;
            int found=StringFind(objname,change_by_Partial_name,0);
            if ( found>=0 && ( (objcolor==OldColor && UseOldColor==true) || UseOldColor==false) ) 
            {
            
   //         Comment ("Found=",objname);
            ObjectSet( objname, OBJPROP_COLOR, NewColor);
            }
            }
   
      if(w1)//если хоть один
         for (i=k-1;i>=0; i--)//изменение по типу//change by type
         {
         objname=ObjectName(i);
         _type=ObjectType(objname);
         objcolor=ObjectGet( objname, OBJPROP_COLOR) ;
         if(_type>=0 && _type<=23)
            {
            for(j=0;j<24;j++)
            if (u[_type] && ( (objcolor==OldColor && UseOldColor==true) || UseOldColor==false) ) 
            ObjectSet( objname, OBJPROP_COLOR, NewColor) ;
            }
         }
      }//else
   
   return(0);
  }

