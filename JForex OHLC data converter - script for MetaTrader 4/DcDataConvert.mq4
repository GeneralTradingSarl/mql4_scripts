//+------------------------------------------------------------------------------+
//| For re-writing JForex OHLC data without the weekend candles and the seconds  |
//| Copy the input file into Metatrader/experts/files folder                     |
//| Set input and output filename                                                |
//| Start this script on any chart and timeframe                                 |
//| Wait for getting "Done" message on Terminal/Experts tab                      |
//| Now the output file is ready to import into Metatrader History Center        |
//+------------------------------------------------------------------------------+

#property show_inputs

extern string input_filename  = "EURUSD_1.csv";
extern string output_filename = "EURUSD1.csv";

int start()
  {
   int Handle = FileOpen(input_filename,FILE_CSV|FILE_READ,",");
   if(Handle == -1) {
    Print("Input file "+input_filename+" not found!");    
    return(0);
   }
   int Result = FileOpen(output_filename,FILE_CSV|FILE_WRITE,",");
   if(Result == -1) {
    Print("Output file "+output_filename+" cannot be opened!");    
    return(0);
   }
   
   string b1[];
   string b2[];
   string b3[];
   string b4[];
   string b5[];
   string b6[];
   b1[0] = FileReadString(Handle);
   b2[0] = FileReadString(Handle);
   b3[0] = FileReadString(Handle);
   b4[0] = FileReadString(Handle);
   b5[0] = FileReadString(Handle);
   b6[0] = FileReadString(Handle);

   string a1[];
   string a2[];
   string a3[];
   string a4[];
   string a5[];
   string a6[];
   
   for(int i=0; i<10000000; i++) {
   
    a1[i] = FileReadString(Handle);
    a2[i] = FileReadString(Handle);
    a3[i] = FileReadString(Handle);
    a4[i] = FileReadString(Handle);
    a5[i] = FileReadString(Handle);
    a6[i] = FileReadString(Handle);
    
    int stop    = StrToInteger(StringSubstr(a1[i],0,2));
    string date = StringSubstr(a1[i],0,10);
    string time = StringSubstr(a1[i],11,5);
    double a6i  = StrToDouble(a6[i]);
   
   if(a6i>0) {
    FileWrite(Result,date,time,a2[i],a3[i],a4[i],a5[i],a6[i]);
    }
    if(stop==0) break;
   }
   FileClose(Handle);
   FileClose(Result);
   Print("Done");
   return;
  }