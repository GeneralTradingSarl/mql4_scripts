//+---------------------------------------------------------------------+
//| Filename: OpenAlert.mq4
//| Version:  1.0 
//| Author: David Thomas
//| email: forex.monkey@live.com
//| irc server: americas.ircforex.co
//| (Yes that is a .co domain.)
//| channels: #mqldev #help #mqldev
//| irc nick: CodeMonkey 
//|---------------------------------------------------------------------+
//| Instructions:                                                   
//| To use this script place it in your scripts folder, and restart 
//| your metatrader client application. You should then see it      
//| listed in your available scripts.                               
//|                                                                 
//| Simply add this script to any chart and it will open the alert  
//| message box. This will enable you to see the previous alert signals.
//+---------------------------------------------------------------------+
#property copyright "David Thomas"
#property link      "forex.monkey@live.com"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
Alert("-- OpenAlert v1.0 --");   
//----
   return(0);
  }
//+------------------------------------------------------------------+