//+------------------------------------------------------------------+
//|                                                send_telegram.mq4 |
//+------------------------------------------------------------------+
#property copyright "2019, Nabi Karamalizadeh, JahanWeb co."
#property link      "@JahanChart http://www.jahanweb.com"
#property description "Send a telegram message"
#property version   "1.00"
#property strict

#include <stderror.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string token="xxxxxxxxxxxxxxxxxxxxxxxxxxxx";//get your token from @BotFather
   string chat_id="xxxxxxxxxx";//get your chat id from @userinfobot
   string message="Salam @JahanChart";//your message

   string cookie=NULL,headers;
   char post[],result[];
   int res;
   
//--- to enable access to the server, you should add URL "https://api.telegram.org"
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
   string base_url="https://api.telegram.org";
   string url=base_url+"/bot"+token+"/sendMessage?chat_id="+chat_id+"&text="+message;
   
//--- Reset the last error code
   ResetLastError();
   
   int timeout=2000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
   res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
   
//--- Checking errors
   if(res==-1)
     {
      int error_code=GetLastError();
      string error_msg=ErrorDescription(error_code);
      Print("Error in WebRequest. Error code: ",error_code," Error: ",error_msg);
      if(error_code==4060)
        {
         //--- Perhaps the URL is not listed, display a message about the necessity to add the address
         MessageBox("Add the address '"+base_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONERROR);
        }
      else
        {
         MessageBox("Access to the server is not possible.\nError: "+error_msg+"\nCode: "+error_code,"Error",MB_ICONERROR);
        }
     }
   else
     {
      //--- Load successfully
      MessageBox("The message sent successfully.\nResult: "+CharArrayToString(result),"Success",MB_ICONINFORMATION);
     }
  }
//+------------------------------------------------------------------+
