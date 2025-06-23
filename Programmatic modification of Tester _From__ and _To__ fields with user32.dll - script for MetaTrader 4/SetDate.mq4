#import "user32.dll"
#include <WinUser32.mqh>
#property copyright "Copyright c 2011, Mike Furlender"


#define _ID_TESTER                     0x53         
#define _ID_TW                         0xE81B     
#define _ID_TERMINAL                   0xE81E
#define _ID_INNER                      0x81BF


#property show_inputs
#property show_confirm

extern string from_date = "2000.01.01";
extern string to_date   = "2012.05.05";
extern int pause = 50;

void start()
{
   ChangeDates(0,from_date);
   ChangeDates(3,to_date);
   
   return;
}   
 void ChangeDates (int fieldID, string date)
 {
   
   /*------------------Navigate window hierarchy to reach "From:" field-----------------*/
   int hMetaTrader = GetAncestor(WindowHandle(Symbol(),Period()),2);            
   Print("hMetaTrader = ", hMetaTrader," || ", DecToHex(hMetaTrader));

   int hTerminal = GetDlgItem(hMetaTrader, _ID_TERMINAL );                            
   Print("hTerminal = ", hTerminal," || ", DecToHex(hTerminal));

   int hTesterW = GetDlgItem(hMetaTrader, _ID_TW );                                    
   Print("hTesterW = ", hTesterW," || ", DecToHex(hTesterW));  
   
   int hTester = GetDlgItem(hTesterW, _ID_TESTER );                                    
   Print("hTester = ", hTester," || ", DecToHex(hTester));  
   
    
   int hInner = GetDlgItem(hTester, _ID_INNER );                                    
   Print("hInner = ", hInner," || ", DecToHex(hInner));  
   
   
   int child = GetWindow(hInner,GW_CHILD); Sleep(pause);
   Print("child = ", child," || ", DecToHex(child));
   
   for (int i=1; i<=14+fieldID; i++) child = GetWindow(child,GW_HWNDNEXT);  
   Print("child = ", child," || ", DecToHex(child));
   
   int from = child;
   /*--------------------------------------------------------------------------*/


   
  
   /*------------------Parse external string variable "date"-----------------*/
   string pt1,pt2,pt3;
   int loc1,loc2,loc3;
   
   int v1,v2,v3; 
 
   
   pt1 = StringSubstr(date,0,loc1);
   pt2 = StringSubstr(date,5,2);
   pt3 = StringSubstr(date,8,2);
   
   v1= StrToNumber(pt1);
   v2= StrToNumber(pt2);
   v3= StrToNumber(pt3);
   /*--------------------------------------------------------------------------*/
   
   Print(loc1,"     ",loc2);
   Print (v1,"      ",v2,"     ",v3);
   
   
   PostMessageA (from, WM_SETFOCUS, 0, 0); Sleep(pause); //set focus on the From: field

   /*--------------------------Parse "From:" field ------------------------*/      
   string p1 =   "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234" ; 
   GetWindowTextA ( from , p1 , 12 ) ;  //get From: as string

   pt1 = StringSubstr(p1,0,4); // first digit
   pt2 = StringSubstr(p1,5,2); //digit after first "." in date
   pt3 = StringSubstr(p1,8,2); //digit after second "." in date

   int x1= StrToNumber(pt1);

   /*------------------------------------------------------------------------*/
   int d1 = v1-x1; //Calculate date offset

   Print (d1);

   /*------------------------Move selection to Year------------------------*/


   string pty,pty2;
   int xy,xy2;
   
     while(true)
   {   
      PostMessageA(from, WM_KEYDOWN, VK_DOWN,0); Sleep(pause);
      GetWindowTextA ( from , p1 , 12 ) ;
      PostMessageA(from, WM_KEYDOWN, VK_UP,0); Sleep(pause);
      
      pty = StringSubstr(p1,0,4);
      xy  = StrToNumber(pty);
      Print(xy,"   ",x1);
      if (xy!=x1){  Sleep(pause); break; }
      else
      {
         PostMessageA(from, WM_KEYDOWN, VK_RIGHT,0); Sleep(pause);
      }
    }
   /*------------------------------------------------------------------------*/
   
        

   /*---------------------------------Set year-------------------------------*/
   if (d1>0)
   {
      for(i=1; i<=d1; i++)PostMessageA(from, WM_KEYDOWN, VK_UP,0); Sleep(pause);
   }
   if (d1<0)
   {   
      for(i=1; i<=0-d1; i++)PostMessageA(from, WM_KEYDOWN, VK_DOWN,0);Sleep(pause);
   }
   PostMessageA(from, WM_KEYDOWN, VK_RIGHT,0);Sleep(pause); //Move selection to month
   /*------------------------------------------------------------------------*/
 
 
 
 
   /*---------------------------------Set month-------------------------------*/
  
   while(true)
   {   
      
      GetWindowTextA ( from , p1 , 12 ) ;
      

      pty2 = StringSubstr(p1,5,2);
      xy2 = StrToNumber(pty2);
      
      Print(xy2,"   ",v2);
      if (xy2==v2){  Sleep(pause); break; }
      else
      {
         PostMessageA(from, WM_KEYDOWN, VK_DOWN,0); Sleep(pause);
      }
    }  
  PostMessageA(from, WM_KEYDOWN, VK_RIGHT,0);Sleep(pause); //Move selection to day
  
  /*------------------------------------------------------------------------*/
  
  
  
  
  /*---------------------------------Set day-------------------------------*/
   
   while(true)
   {   
      
      GetWindowTextA ( from , p1 , 12 ) ;
      

      
      pty2 = StringSubstr(p1,8,2);
      xy2 = StrToNumber(pty2);
      
      Print(xy2,"   ",v3);
      if (xy2==v3){  Sleep(pause); break; }
      else
      {
         PostMessageA(from, WM_KEYDOWN, VK_DOWN,0); Sleep(pause);
      }
    }
  /*------------------------------------------------------------------------*/
     PostMessageA (from, WM_KILLFOCUS, 0, 0); Sleep(pause); //kill focus 
 

return(0);

}
//+------------------------------------------------------------------+
double StrToNumber(string str)  { //Function written by Hanover
//+------------------------------------------------------------------+
// Usage: strips all non-numeric characters out of a string
  int    dp   = -1;
  int    sgn  = 1;
  double num  = 0.0;
  for (int i=0; i<StringLen(str); i++)  {
    string s = StringSubstr(str,i,1);
    if (s == "-")  sgn = -sgn;   else
    if (s == ".")  dp = 0;       else
    if (s >= "0" && s <= "9")  {
      if (dp >= 0)  dp++;
      if (dp > 0)
        num = num + StrToInteger(s) / MathPow(10,dp);
      else
        num = num * 10 + StrToInteger(s);
    }
  }
  return(num*sgn);
}
string DecToHex(int n)
  {
   string s = "", c;
   while(n != 0)
     {
      if(n%16 < 10)
          c = CharToStr(n % 16 + '0');
      else 
          c = CharToStr(n % 16 + 'A'-10);
      s = c + s;
      n = n / 16;
     }
   return(s);
  }





