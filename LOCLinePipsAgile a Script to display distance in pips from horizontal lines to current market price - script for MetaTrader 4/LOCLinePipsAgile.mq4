//+---------------------------------------------------------------------+
//|                                                     LOCLinePips.mq4 |
//| For more EXPERTS, INDICATORS, TRAILING EAs and SUPPORT Please visit:|
//|                                      http://www.landofcash.net      |
//|           Our forum is at:   http://forex-forum.landofcash.net      |
//+---------------------------------------------------------------------+
#property copyright "Mikhail LandOfCash"
#property link      "http://www.landofcash.net"

string _verName="LOCLinePips";
string _ver="v2.0";

extern color _textColor=Lime;
extern int _sleepTimeMS=50;

bool _isRunning=false;
string _fullName;
string _objPref="LOCLinePips";


int start()
{
   _fullName=_verName+" "+_ver;
   Print("LandOfCash.net "+_fullName+" Started.");  
   Comment("LandOfCash.net "+_fullName);
   if(!_isRunning){
      Iterate();
   }
   DeleteLabels(_objPref);
   return (0);
}
  

void DoJob(){
   int    obj_total=ObjectsTotal();
   string name;
   DeleteLabels(_objPref);
   for(int i=0;i<obj_total;i++)
   {
      name=ObjectName(i);        
      if(ObjectType(name)==OBJ_HLINE){
         double price = ObjectGet(name, OBJPROP_PRICE1) ;
         CreateText(_objPref+name,Time[0],price,_textColor,DoubleToStr(MathAbs((Bid-price)/Point),0));
      }      
   }
}


void Iterate() {
   _isRunning=true;
   while(!IsStopped())    
   {              
    RefreshRates();     
    DoJob();
    Sleep(_sleepTimeMS);        
   }
}

void CreateText(string name, datetime time1, double price,color boxcolor, string text){
   ObjectDelete(name);
   if(!ObjectCreate(name, OBJ_TEXT,0, time1, price))
   {
    Print("error: cant create OBJ_TEXT! code #",GetLastError());
    return(0);
   }
   ObjectSetText(name, text, 7, "Verdana", boxcolor);
}
void DeleteLabels(string objPref){
   int    obj_total=ObjectsTotal();
   string name;
   for(int i=0;i<obj_total;i++)
   {
    name=ObjectName(i);    
    if(StringFind(name, objPref,0)>-1){      
      ObjectDelete(name);
      i--;
    }
   }
}
//+------------------------------------------------------------------+

