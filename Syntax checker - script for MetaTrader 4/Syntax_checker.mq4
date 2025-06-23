//+------------------------------------------------------------------+
//|                                               Syntax checker.mq4 |
//|                                         Copyright © 2010, sxTed. |
//|                                                    sxTed@gmx.com |
//| Purpose.: Check a MetaQuotes Language 4 program for basic syntax |
//|           errors like unbalanced braces, parentheses & brackets  |
//|           surrounding operators, expressions & array definers.   |
//|           Also verifies for single quotes surrounding color and  |
//|           date constants, double quotes for string constants and |
//|           multi line comment symbol pairs.                       |
//| Set up..: 1) Place files into the following subdirectories:      |
//|              "Syntax checker.mq4" into "\experts\scripts",       |
//|              "StringArraySuite.mqh" into "\experts\include".     |
//|           2) Close and then re-start MetaTrader for it to find   |
//|              the new file.                                       |
//|           3) Click on MetaEditor, click on "MQL Navigator", click|
//|              on "scripts", double click on "Syntax checker.mq4"  |
//|              and click on "Compile".                             |
//| Start up: 1) Click on "Navigator", click on "Scripts", double    |
//|              click on "Syntax checker".                          |
//|           2) Window with header "Syntax checker" is displayed.   |
//|           3) Click on the "Common" tab and ensure that a tick is |
//|              showing in "Allow DLL imports" box by clicking it.  |
//|           4) Click on the "Inputs" tab.                          |
//|              For the value of input named "ProgramType" type in: |
//|              "E" for "Expert", "S" for "Script", "F" for "Files",|
//|              "C" for "Custom Indicator" or "I" for "Include" type|
//|              of program.                                         |
//|              For the value of input named "ProgramName" type in  |
//|              the file name only. The full path name, file name & |
//|              the file extension may be typed in (if required).   |
//|           Click "Terminal", click "Experts" tab to view a print  |
//|           of errors (if encountered).                            |                                    
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, sxTed."
#property link      "sxTed@gmx.com"
#property show_inputs

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
#define CODE                 1
#define DOUBLE_QUOTE         2
#define SINGLE_QUOTE         3
#define MULTI_LINE_COMMENT   4
#define SINGLE_LINE_COMMENT  5
#define ERROR               -1

//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
#import "Kernel32.dll"
  bool CopyFileA (string source_file, string destination_file, bool if_exist);
#import
#include <stderror.mqh>
#include <stdlib.mqh>
#include <StringArraySuite.mqh>

//+------------------------------------------------------------------+
//| input parameters:                                                |
//+-----------0---+----1----+----2----+----3]------------------------+
extern string ProgramType = "E=Expert, S=Script, C=Custom Indicator, I=Include, F=Files";
extern string ProgramName = "Temp";

//+------------------------------------------------------------------+
//| global variables to program:                                     |
//+------------------------------------------------------------------+
string A[1000][6];

//+------------------------------------------------------------------+
//| script start function                                            |
//+------------------------------------------------------------------+ 
void start() {
  int    iParse=CODE, iLine=1, handle, iRows, iOpCols, iOpCol, iCol, iRow, iError;
  int    iDoubleQuoteLine, iSingleQuoteLine;
  string sPath=TerminalPath()+"\\experts\\", sTemp="Temp___.txt", sFile, sMsg="", sLine, sChar, sNext;

  ProgramType=StringSubstr(ProgramType,0,1);
  if(StringFind(ProgramName,"\\") >= 0)                   sFile=ProgramName;
  else if((ProgramType == "E") || (ProgramType == "e"))   sFile=sPath+ProgramName;
  else if((ProgramType == "S") || (ProgramType == "s"))   sFile=sPath+"scripts\\"+ProgramName;
  else if((ProgramType == "C") || (ProgramType == "c"))   sFile=sPath+"indicators\\"+ProgramName; 
  else if((ProgramType == "I") || (ProgramType == "i"))   sFile=sPath+"include\\"+ProgramName;
  else if((ProgramType == "F") || (ProgramType == "f"))   sFile=sPath+"files\\"+ProgramName;
  if(StringFind(ProgramName,".") == -1) {
    if((ProgramType == "I") || (ProgramType == "i"))      sFile=sFile+".mqh";
    else if((ProgramType == "F") || (ProgramType == "f")) sFile=sFile+".txt";
    else                                                  sFile=sFile+".mq4";
  }
  if(StringFind("ESCIFescif",ProgramType) == -1)  sMsg=sMsg+"ProgramType to be E/S/C/I/F\n";
  if(ProgramName == "")                           sMsg=sMsg+"ProgramName required\n";
  if(IsDllsAllowed() == false)                    sMsg=sMsg+"Check \"Allow DLL imports\" to enable program\n";
  if(CopyFileA(sFile,sPath+"files\\"+sTemp,0)==0) sMsg=sMsg+"CopyFileA:"+sFile+"  Error:"+GetLastError()+"\n";
  if(sMsg != "") {
    Alert(sMsg);
    return;
  }
  handle=FileOpen(sTemp, FILE_CSV|FILE_READ, ";");
  if(handle == -1) sMsg=sMsg+"File: "+sTemp+"  Error: "+ErrorDescription(GetLastError())+"\n";
  if(sMsg != "") {
    Alert(sMsg);
    return;
  }
  
  StringArrayIni(A);
  A[0][1]=iLine; // keep track of last row used in array A
    
  while(FileIsEnding(handle) == false) {
    sLine=FileReadString(handle);
    iOpCols=StringLen(sLine);
    for(iOpCol=0; iOpCol<iOpCols; iOpCol++) {
      if((iOpCol == 0) && (iCol != 0)) iCol++; // adjust for 2 or more Operators on same Line
      iCol++; // iCol is for user (allows 2 or more Operators per line; iOpCol keeps track of col in Operator 
      sChar=StringSubstr(sLine,iOpCol,1);
      switch(iParse) {
        case CODE:
             if((sChar == "{") || (sChar == "(") || (sChar == "[")) {
               if(OpenedWithChar(sChar,iLine,iCol) == ERROR) return;
             }
             else if((sChar == "}") || (sChar == ")") || (sChar == "]")) {
               if(ClosedWithChar(sChar,iLine,iCol) == ERROR) return;
             }
             else if(sChar == "\"") {
               iParse=DOUBLE_QUOTE;
               if(OpenedWithChar(sChar,iLine,iCol) == ERROR) return;
               iDoubleQuoteLine=iLine;
             }  
             else if(sChar == "\'") {
               iParse=SINGLE_QUOTE;
               if(OpenedWithChar(sChar,iLine,iCol) == ERROR) return;
               iSingleQuoteLine=iLine;
             }  
             else if(sChar == "/") {
               sNext=StringSubstr(sLine,iOpCol+1,1);
               if(sNext == "*") {
                 iParse=MULTI_LINE_COMMENT;
                 if(OpenedWithChar(sChar+sNext,iLine,iCol) == ERROR) return;
                 iOpCol++;
                 iCol++;
               } 
               else if(sNext == "/") {
                 iParse=SINGLE_LINE_COMMENT;
                 iOpCol++;
                 iCol++;
               }
             }
             else if(sChar == "*") {
               if(StringSubstr(sLine,iOpCol+1,1) == "/") {
                 iParse=CODE;
                 if(ClosedWithChar(sChar+"/",iLine,iCol) == ERROR) return;
                 iOpCol++;
                 iCol++;
               } 
             }
             break;
        case DOUBLE_QUOTE:
             if((iDoubleQuoteLine > 0) && (iLine > iDoubleQuoteLine)) {
               // cater for missing double quote partner
               if(ClosedWithChar("D",iLine,iCol) == ERROR) return;
               iDoubleQuoteLine=0;
               iParse=CODE;
             }
             else if(sChar == "\"") {
               if(ClosedWithChar(sChar,iLine,iCol) == ERROR) return;
               iParse=CODE;
             }
             break;
        case SINGLE_QUOTE:
             if((iSingleQuoteLine > 0) && (iLine > iSingleQuoteLine)) {
               // cater for missing single quote partner
               if(ClosedWithChar("S",iLine,iCol) == ERROR) return;
               iSingleQuoteLine=0;
               iParse=CODE;
             }        
             else if(sChar == "\'") {
               if(ClosedWithChar(sChar,iLine,iCol) == ERROR) return;
               iParse=CODE;
             }
             break;
        case MULTI_LINE_COMMENT:
             if(sChar == "*") {
               if(StringSubstr(sLine,iOpCol+1,1) == "/") {
                 if(ClosedWithChar(sChar+"/",iLine,iCol) == ERROR) return;
                 iParse=CODE;                 
                 iOpCol++;
                 iCol++;
               } 
             }
             break;
        case SINGLE_LINE_COMMENT:
             if(FileIsLineEnding(handle)) iParse=CODE;
             break;     
      }
    }
    if(FileIsLineEnding(handle)) {
      iLine++;
      iCol=0;
    }      
  }
  FileClose(handle);
  GetLastError(); // get rid of error 4099 ERR_END_OF_FILE
  FileDelete(sTemp);
  iError=GetLastError();
  if(iError != ERR_NO_ERROR) {
    Alert("DeleteFile:",sPath+"files\\"+sTemp,"  Error:",iError," ",ErrorDescription(iError));
    return;
  }
  //StringArrayWrite(A, "Syntax checked.txt");
  
  iRows=StrToInteger(A[0][1]);
  iError=0;
  for(iLine=1; iLine<=iRows; iLine++) {
    if(A[iLine,0] == "" && A[iLine,3] == "") continue;
    if(A[iLine,3] == "") {
      if(A[iLine,0] == "/*")     sChar="*/";
      else if(A[iLine,0] == "{") sChar="}";
      else if(A[iLine,0] == "(") sChar=")";
      else if(A[iLine,0] == "[") sChar="]";
      else                       sChar=A[iLine,0];
      Print("At Line ",A[iLine,1]," Col ",A[iLine,2]," opening ",A[iLine,0]," has no closing ",sChar);
      iError++;
    }
    else if(A[iLine,3] == "D") {
      Print("At Line ",A[iLine,1]," Col ",A[iLine,2]," double quote ",A[iLine,0]," has no match");
      iError++;
    }    
    else if(A[iLine,3] == "S") {
      Print("At Line ",A[iLine,1]," Col ",A[iLine,2]," single quote ",A[iLine,0]," has no match");
      iError++;
    }      
    if(A[iLine,0] == "") {
      if(A[iLine,3] == "*/")     sChar="/*";
      else if(A[iLine,3] == "}") sChar="{";
      else if(A[iLine,3] == ")") sChar="(";
      else if(A[iLine,3] == "]") sChar="[";
      else                       sChar=A[iLine,3];
      Print("At Line ",A[iLine,4]," Col ",A[iLine,5]," closing ",A[iLine,3]," has no opening ",sChar);
      iError++;
    }  
  }
  Alert("Program: ",ProgramName,"  Errors: ",iError);
}

int OpenedWithChar(string sChar, int iLine, int iCol) {
  int iRow=StrToInteger(A[0][1])+1, iRows=ArrayRange(A, 0);
  
  if(iRow >= iRows) {
    if(StringArrayAdd(A) == ERROR) {
      Print("ArrayResize error: ",ErrorDescription(GetLastError()));
      return(ERROR);
    }  
  }  
  
  A[iRow,0]=sChar;
  A[iRow,1]=iLine;
  A[iRow,2]=iCol;
  A[0][1]=iRow; // keep track of max row used
  return(1);
}

int ClosedWithChar(string sChar, int iLine, int iCol) {
  int    iRow=StrToInteger(A[0][1]), iRows, iPos=-1, i;
  string sOpen;
  
  if(sChar == "}")       sOpen="{";
  else if(sChar == ")")  sOpen="(";
  else if(sChar == "]")  sOpen="[";
  else if(sChar == "*/") sOpen="/*";
  else if(sChar == "D")  sOpen="\"";
  else if(sChar == "S")  sOpen="\'";
  else                   sOpen=sChar;
  
  for(i=iRow; i>0; i--) {
    if((A[i,0] == sOpen) && (A[i,3] == "")) {
      iPos=i;
      break;
    }
  }
  if(iPos == -1) {
    iRows=ArrayRange(A, 0);
    if(iRow+1>=iRows) {
      if(StringArrayAdd(A) == ERROR) {
        Print("ArrayResize error: ",ErrorDescription(GetLastError()));
        return(ERROR);
      }
    }
    iRow++;
    iPos=iRow; 
  }
  A[iPos,3]=sChar;
  A[iPos,4]=iLine;
  A[iPos,5]=iCol;
  A[0][1]=iRow; // keep track of max row used
  return(1); 
}

//+------------------------------------------------------------------+
//| Function..: GetName                                              |
//| Example...: string sName=GetName("  ID = B512 "); // "ID"        |
//+------------------------------------------------------------------+
string GetName(string sText, string sDelimiter="=") {
  sText=StringTrimLeft(sText);
  int iPos=StringFind(sText,sDelimiter);
  
  if(iPos>=0) return(StringTrimRight(StringSubstr(sText,0,iPos)));
  return("");
}

//+------------------------------------------------------------------+
//| Function..: GetValue                                             |
//| Example...: string sValue=GetValue("  ID = B512 "); // "B512"    |
//+------------------------------------------------------------------+
string GetValue(string sText, string sDelimiter="=") {
  sText=StringTrimRight(sText);
  int iPos=StringFind(sText,sDelimiter);
  
  if(iPos>=0) return(StringTrimLeft(StringSubstr(sText,iPos+StringLen(sDelimiter))));
  return("");
}
//+------------------------------------------------------------------+

