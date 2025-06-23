//+------------------------------------------------------------------+
//|                                              File Read Write.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

// константы для функции _lopen
#define OF_READ               0
#define OF_WRITE              1
#define OF_READWRITE          2
#define OF_SHARE_COMPAT       3
#define OF_SHARE_DENY_NONE    4
#define OF_SHARE_DENY_READ    5
#define OF_SHARE_DENY_WRITE   6
#define OF_SHARE_EXCLUSIVE    7

#import "kernel32.dll"
   int _lopen  (string path, int of);
   int _lcreat (string path, int attrib);
   int _llseek (int handle, int offset, int origin);
   int _lread  (int handle, string buffer, int bytes);
   int _lwrite (int handle, string buffer, int bytes);
   int _lclose (int handle);
#import

// _lopen  : Откpывает указанный файл. Возвpащает: описатель файла.
// _lcreat : Создает указанный файл.   Возвpащает: описатель файла.
// _llseek : Устанавливает указатель в откpытом файле. Возвpащает: 
// новое смещение указателя.
// _lread  : Считывает из откpытого файла указанное число байт. 
// Возвpащает: число считанных байт; 0 - если конец файла.
// _lwrite : Записывает данные из буфеpа в указанный файл. Возвpащает: 
// число записанных байт.
// _lclose : Закpывает указанный файл. Возвpащает: 0.
// В случае неуспешного завеpшения все функции возвращают значение 
// HFILE_ERROR=-1.
 
// path   : Стpока, опpеделяющая путь и имя файла.
// of     : Способ открытия.
// attrib : 0 - чтение или запись; 1 - только чтение; 2 - невидимый или 
// 3 - системный.
// handle : Файловый описатель.
// offset : Число байт, на котоpое пеpемещается указатель.
// origin : Указывает начальную точку и напpавление пеpемещения: 0 - 
// впеpед от начала; 1 - с текущей позиции; 2 - назад от конца файла.
// buffer : Пpинимающий/записываемый буфеp.
// bytes  : Число считываемых байт.
 
// Способы открытия (параметр of):
// int OF_READ            =0; // Открыть файл только для чтения
// int OF_WRITE           =1; // Открыть файл только для записи
// int OF_READWRITE       =2; // Открыть файл в режиме запись/чтение
// int OF_SHARE_COMPAT    =3; // Открывает файл в режиме общего 
// совместного доступа. В этом режиме любой процесс может открыть данный 
// файл любое количество раз. При попытке открыть этот файл в любом другом
// режиме, функция возвращает HFILE_ERROR.
// int OF_SHARE_DENY_NONE =4; // Открывает файл в режиме общего доступа 
// без запрета на чтение/запись другим процессам. При попытке открытия 
// данного файла в режиме OF_SHARE_COMPAT, функция возвращает HFILE_ERROR.
// int OF_SHARE_DENY_READ =5; // Открывает файл в режиме общего доступа с 
// запретом на чтение другим процессам. При попытке открытия данного файла 
// с флагами OF_SHARE_COMPAT и/или OF_READ или OF_READWRITE, функция 
// возвращает HFILE_ERROR.
// int OF_SHARE_DENY_WRITE=6; // Тоже самое, только с запретом на запись.
// int OF_SHARE_EXCLUSIVE =7; // Запрет текущему и другим процессам на 
// доступ к этому файлу в режимах чтения/записи. Файл в этом режиме можно 
// открыть только один раз (текущим процессом). Все остальные попытки 
// открытия файла будут провалены.
//+------------------------------------------------------------------+
//|   прочитать файл и вернуть строку с содержимым                   |
//+------------------------------------------------------------------+
string ReadFile (string path) 
  {
    int handle=_lopen (path,OF_READ);           
    if(handle<0) 
      {
        Print("Ошибка открытия файла ",path); 
        return ("");
      }
    int result=_llseek (handle,0,0);      
    if(result<0) 
      {
        Print("Ошибка установки указателя" ); 
        return ("");
      }
    string buffer="";
    string char1="x";
    int count=0;
    result=_lread (handle,char1,1);
    while(result>0) 
      {
        buffer=buffer+char1;
        char1="x";
        count++;
        result=_lread (handle,char1,1);
     }
    result=_lclose (handle);              
    if(result<0)  
      Print("Ошибка закрытия файла ",path);
    return (buffer);
  }
 
//+------------------------------------------------------------------+
//|  записать содержимое буфера по указанному пути                   |
//+------------------------------------------------------------------+
void WriteFile (string path, string buffer) 
  {
    int count=StringLen (buffer); 
    int result;
    int handle=_lopen (path,OF_WRITE);
    if(handle<0) 
      {
        handle=_lcreat (path,0);
        if(handle<0) 
          {
            Print ("Ошибка создания файла ",path);
            return;
          }
        result=_lclose (handle);
     }
    handle=_lopen (path,OF_WRITE);               
    if(handle<0) 
      {
        Print("Ошибка открытия файла ",path); 
        return;
      }
    result=_llseek (handle,0,0);          
    if(result<0) 
      {
        Print("Ошибка установки указателя"); 
        return;
      }
    result=_lwrite (handle,buffer,count); 
    if(result<0)  
        Print("Ошибка записи в файл ",path," ",count," байт");
    result=_lclose (handle);              
    if(result<0)  
        Print("Ошибка закрытия файла ",path);
  }
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
    string buffer=ReadFile("C:\\Text.txt");
    int count=StringLen(buffer);
    Print("Прочитано байт:",count);
    WriteFile("C:\\Text2.txt",buffer);   
//----
   return(0);
  }
//+------------------------------------------------------------------+