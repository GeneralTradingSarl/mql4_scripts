#import "user32.dll"

   int GetAncestor(int hWnd, int gaFlags);
   int GetDlgItem(int hDlg, int nIDDlgItem);
   int PostMessageA(int hWnd, int Msg, int wParam, int lParam);
   int GetParent(int hWnd);
   int GetWindow(int hWnd,int uCmd);   

#import "kernel32.dll"     

   int  FindFirstFileA(string path, int& answer[]);
   bool FindNextFileA(int handle, int& answer[]);
   bool FindClose(int handle);
   
#import


#define WM_COMMAND   0x0111
#define WM_KEYDOWN   0x0100
#define VK_HOME      0x0024
#define VK_DOWN      0x0028

//+------------------------------------------------------------------+
//| Open a new chart                                                 |
//+------------------------------------------------------------------+
int OpenChart(string SymbolName, int TimeFrame, string Template)
{
   int hFile, SymbolsTotal, hTerminal, hWnd, intCmd;
   
   int counter;
   int win32_DATA[80];
   string tempfullname =".tpl";
   int tempnum = 34800;
   
   tempfullname=Template+tempfullname;
   
   int handle = FindFirstFileA(TerminalPath() + "\\templates\\*.tpl",win32_DATA);
   
   counter = 0;
   
   
  if (tempfullname==bufferToString(win32_DATA))
 
      {
         tempnum+=counter;
      }
      
   
   ArrayInitialize(win32_DATA,0);

   while (FindNextFileA(handle,win32_DATA))
      {

      counter++;
      
      if (tempfullname==bufferToString(win32_DATA))
      {
         tempnum+=counter;

      }

      ArrayInitialize(win32_DATA,0);
      }

   if (handle>0) FindClose(handle);   

   hFile = FileOpenHistory("symbols.sel", FILE_BIN|FILE_READ);
   if(hFile < 0) return(-1);

   SymbolsTotal = (FileSize(hFile) - 4) / 128;
   FileSeek(hFile, 4, SEEK_SET);

   hTerminal = GetAncestor(WindowHandle(Symbol(), Period()), 2);

   hWnd = GetDlgItem(hTerminal, 0xE81C);
   hWnd = GetDlgItem(hWnd, 0x50);
   hWnd = GetDlgItem(hWnd, 0x8A71);

   PostMessageA(hWnd, WM_KEYDOWN, VK_HOME, 0);


   switch( TimeFrame )
   {
      case 1:   intCmd = 33137;  break;
      case 5:   intCmd = 33138;  break;
      case 15:  intCmd = 33139;  break;
      case 30:  intCmd = 33140;  break;
      case 60:   intCmd = 35400;  break;
      case 240:   intCmd = 33136;  break;
      case 1440:   intCmd = 33134;  break;
      case 10080:   intCmd = 33141;  break;
      case 43200:  intCmd = 33334;  break;
   }


   for(int i = 0; i < SymbolsTotal; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
      
      
      PostMessageA(hTerminal, WM_COMMAND, 33160, 0);
         
      Sleep(100);
         
      PostMessageA(hTerminal,WM_COMMAND,intCmd,0); 

      Sleep(100);
      
     
      PostMessageA(hTerminal, WM_COMMAND, tempnum, 0 );

               
         return(0);

      }
      
      
      PostMessageA(hWnd, WM_KEYDOWN, VK_DOWN, 0);
      FileSeek(hFile, 116, SEEK_CUR);
   }



   FileClose(hFile);

   return(-1);

}

string bufferToString(int buffer[])
   {
   string text="";
   
   int pos = 10;
   for (int i=0; i<64; i++)
      {
      pos++;
      int curr = buffer[pos];
      text = text + CharToStr(curr & 0x000000FF)
         +CharToStr(curr >> 8 & 0x000000FF)
         +CharToStr(curr >> 16 & 0x000000FF)
         +CharToStr(curr >> 24 & 0x000000FF);
      }
   return (text);
   }  


int init()
  {
  
// New chart opens with specified parameters.

   OpenChart("GBPJPY",5, "Momentum");

   
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+