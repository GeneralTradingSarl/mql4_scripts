//+------------------------------------------------------------------+
//|                                                   updatedata.mq4 |
//|                                                       yongbin yu |
//|                                                     forexcafe.cn |
//+------------------------------------------------------------------+
#property copyright "yongbin yu"
#property link      "forexcafe.cn"

#include <WinUser32.mqh>

#import "user32.dll"
void keybd_event(int bVk,int bScan,int dwFlags,int dwExtraInfo);
bool GetAsyncKeyState(int nVirtKey);
void mouse_event(int dwFlags,int& dx,int& dy,int dwData,int dwExtraInfo);
#import

//
#define MOUSEEVENTF_LEFTDOWN           0x0002 // left button down
#define MOUSEEVENTF_LEFTUP             0x0004 // left button up

#define KEYEVENTF_EXTENDEDKEY          0x0001
#define KEYEVENTF_KEYUP                0x0002

#define VK_0 48
#define VK_1 49
#define VK_2 50
#define VK_3 51
#define VK_4 52
#define VK_5 53
#define VK_6 54
#define VK_7 55
#define VK_8 56
#define VK_9 57
#define VK_A 65
#define VK_B 66
#define VK_C 67
#define VK_D 68
#define VK_E 69
#define VK_F 70
#define VK_G 71
#define VK_H 72
#define VK_I 73
#define VK_J 74
#define VK_K 75
#define VK_L 76
#define VK_M 77
#define VK_N 78
#define VK_O 79
#define VK_P 80
#define VK_Q 81
#define VK_R 82
#define VK_S 83
#define VK_T 84
#define VK_U 85
#define VK_V 86
#define VK_W 87
#define VK_X 88
#define VK_Y 89
#define VK_Z 90

#define VK_LBUTTON 1 //Left mouse button
#define VK_RBUTTON 2 //Right mouse button
#define VK_CANCEL 3 //Control-break processing
#define VK_MBUTTON 4 //Middle mouse button (three-button mouse)
#define VK_BACK 8 //BACKSPACE key
#define VK_TAB 9 //TAB key
#define VK_CLEAR 12 //CLEAR key
#define VK_RETURN 13 //ENTER key
#define VK_SHIFT 16 //SHIFT key
#define VK_CONTROL 17 //CTRL key
#define VK_MENU 18 //ALT key
#define VK_PAUSE 19 //PAUSE key
#define VK_CAPITAL 20 //CAPS LOCK key
#define VK_ESCAPE 27 //ESC key
#define VK_SPACE 32 //SPACEBAR
#define VK_PRIOR 33 //PAGE UP key
#define VK_NEXT 34 //PAGE DOWN key
#define VK_END 35 //END key
#define VK_HOME 36 //HOME key
#define VK_LEFT 37 //LEFT ARROW key
#define VK_UP 38 //UP ARROW key
#define VK_RIGHT 39 //RIGHT ARROW key
#define VK_DOWN 40 //DOWN ARROW key
#define VK_PRINT 42 //PRINT key
#define VK_SNAPSHOT 44 //PRINT SCREEN key
#define VK_INSERT 45 //INS key
#define VK_DELETE 46 //DEL key
#define VK_HELP 47 //HELP key
#define VK_LWIN 91 //Left Windows key (Microsoft? Natural? keyboard)
#define VK_RWIN 92 //Right Windows key (Natural keyboard)
#define VK_APPS 93 //Applications key (Natural keyboard)
#define VK_SLEEP 95 //Computer Sleep key
#define VK_NUMPAD0 96 //Numeric keypad 0 key
#define VK_NUMPAD1 97 //Numeric keypad 1 key
#define VK_NUMPAD2 98 //Numeric keypad 2 key
#define VK_NUMPAD3 99 //Numeric keypad 3 key
#define VK_NUMPAD4 100 //Numeric keypad 4 key
#define VK_NUMPAD5 101 //Numeric keypad 5 key
#define VK_NUMPAD6 102 //Numeric keypad 6 key
#define VK_NUMPAD7 103 //Numeric keypad 7 key
#define VK_NUMPAD8 104 //Numeric keypad 8 key
#define VK_NUMPAD9 105 //Numeric keypad 9 key
#define VK_MULTIPLY 106 //Multiply key
#define VK_ADD 107 //Add key
#define VK_SEPARATOR 108 //Separator key
#define VK_SUBTRACT 109 //Subtract key
#define VK_DECIMAL 110 //Decimal key
#define VK_DIVIDE 111 //Divide key
#define VK_F1 112 //F1 key
#define VK_F2 113 //F2 key
#define VK_F3 114 //F3 key
#define VK_F4 115 //F4 key
#define VK_F5 116 //F5 key
#define VK_F6 117 //F6 key
#define VK_F7 118 //F7 key
#define VK_F8 119 //F8 key
#define VK_F9 120 //F9 key
#define VK_F10 121 //F10 key
#define VK_F11 122 //F11 key
#define VK_F12 123 //F12 key
#define VK_F13 124 //F13 key
#define VK_NUMLOCK 144 //NUM LOCK key
#define VK_SCROLL 145 //SCROLL LOCK key
#define VK_LSHIFT 160 //Left SHIFT key
#define VK_RSHIFT 161 //Right SHIFT key
#define VK_LCONTROL 162 //Left CONTROL key
#define VK_RCONTROL 163 //Right CONTROL key
#define VK_LMENU 164 //Left MENU key
#define VK_RMENU 165 //Right MENU key


//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----

  //GetFocus();
  mouse_event(MOUSEEVENTF_LEFTDOWN,0,0,0,0);
  mouse_event(MOUSEEVENTF_LEFTUP,0,0,0,0);
  
   while (true) {
   Sleep(1000);
   if (Check()==1) {
      break;
   }
   SendKey(VK_HOME,true);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

void SendKey(int key,bool release = false)
{
    keybd_event(key, 0, 0, 0);
    if(release) keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
}
         
void ReleaseKey(int key)
{
   keybd_event(key, 0, KEYEVENTF_KEYUP, 0);
}

int Check()
{
   //if (GetAsyncKeyState(VK_LCONTROL) && GetAsyncKeyState(VK_B))
   if (GetAsyncKeyState(VK_ESCAPE) )
   {
      return(1);
   }
return(0);
}