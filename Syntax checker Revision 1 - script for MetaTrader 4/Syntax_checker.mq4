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
//| Revision: 1 2010.08.09:                                          |
//|             Single line comment re-coded.                        |                                    
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

//+------------------------------------------------------------------+
//| input parameters:                                                |
//+-----------0---+----1----+----2----+----3]------------------------+
extern string ProgramType = "E=Expert, S=Script, C=Custom Indicator, I=Include, F=Files";
extern string ProgramName = "Temp";

//+------------------------------------------------------------------+
//| global variables to program:                                     |
//+------------------------------------------------------------------+
int A[1000][6];

//+------------------------------------------------------------------+
//| script start function                                            |
//+------------------------------------------------------------------+ 
void start() {
  int    iParse=CODE, iLine=1, handle, iRow, iOpCol, iOpCols, iCol, iError;
  int    iDoubleQuoteLine, iSingleQuoteLine, iChar, iNext;
  string sPath=TerminalPath()+"\\experts\\", sTemp="Temp___.txt", sFile, sMsg="", sLine;

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
  
  ArrayInitialize(A,0); // cell at Row 0 Col 1 keeps track of last row used
      
  while(FileIsEnding(handle) == false) {
    sLine=FileReadString(handle);
    iOpCols=StringLen(sLine);
    for(iOpCol=0; iOpCol<iOpCols; iOpCol++) {
      iChar=StringGetChar(sLine,iOpCol);
      iNext=StringGetChar(sLine,iOpCol+1);
      iCol++;
      switch(iParse) {
        case CODE:
             if((iChar == 123) || (iChar == 40) || (iChar == 91)) { // "{", "(" or "["   
               if(OpenedWithChar(iChar,iLine,iCol) == ERROR) return;
             }
             else if((iChar == 125) || (iChar == 41) || (iChar == 93)) { // "}", ")" or "]"      
               if(ClosedWithChar(iChar,iLine,iCol) == ERROR) return;
             }
             else if(iChar == 34) {
               iParse=DOUBLE_QUOTE;
               if(OpenedWithChar(iChar,iLine,iCol) == ERROR) return;
               iDoubleQuoteLine=iLine;
             }  
             else if(iChar == 39) {
               iParse=SINGLE_QUOTE;
               if(OpenedWithChar(iChar,iLine,iCol) == ERROR) return;
               iSingleQuoteLine=iLine;
             }  
             else if(iChar == 47) { // "/"
               if(iNext == 42) {    // "*"
                 iParse=MULTI_LINE_COMMENT;
                 if(OpenedWithChar(iNext,iLine,iCol) == ERROR) return;
                 iOpCol++; // adjust for parsing of iNext
                 iCol++;
               }
               else if(iNext == 47) iOpCol=iOpCols; //  SINGLE_LINE_COMMENT
             }
             else if(iChar == 42) { // "*"
               if(iNext == 47) {    // "/"
                 iParse=CODE;
                 if(ClosedWithChar(iChar,iLine,iCol) == ERROR) return;
                 iOpCol++;
                 iCol++;
               } 
             }
             break;
        case DOUBLE_QUOTE:
             if((iDoubleQuoteLine > 0) && (iLine > iDoubleQuoteLine)) {
               // cater for missing double quote partner
               if(ClosedWithChar(68,iLine,iCol) == ERROR) return; // sChar = "D"
               iDoubleQuoteLine=0;
               iParse=CODE;
             }
             else if(iChar == 34) { // double quote
               if(ClosedWithChar(iChar,iLine,iCol) == ERROR) return;
               iParse=CODE;
             }
             break;
        case SINGLE_QUOTE:
             if((iSingleQuoteLine > 0) && (iLine > iSingleQuoteLine)) {
               // cater for missing single quote partner
               if(ClosedWithChar(83,iLine,iCol) == ERROR) return; // sChar = "S"
               iSingleQuoteLine=0;
               iParse=CODE;
             }        
             else if(iChar == 39) {
               if(ClosedWithChar(iChar,iLine,iCol) == ERROR) return;
               iParse=CODE;
             }
             break;
        case MULTI_LINE_COMMENT:
             if(iChar == 42) {   // "*"
               if(iNext == 47) { // "/"
                 if(ClosedWithChar(iChar,iLine,iCol) == ERROR) return;
                 iParse=CODE;
                 iOpCol++;                 
                 iCol++;
               } 
             }
             break;
      }
    }
    if(FileIsLineEnding(handle)) {
      iLine++;
      iCol=0;
    }
    else iCol++;
  }
  FileClose(handle);
  GetLastError(); // get rid of error 4099 ERR_END_OF_FILE
  FileDelete(sTemp);
  iError=GetLastError();
  if(iError != ERR_NO_ERROR) {
    Alert("DeleteFile:",sPath+"files\\"+sTemp,"  Error:",iError," ",ErrorDescription(iError));
    return;
  }
  
  iError=0;
  for(iRow=1; iRow<=A[0][1]; iRow++) {
    if(A[iRow,0] == 0 && A[iRow,3] == 0) break;
    if(A[iRow,3] == 0) {
      if(A[iRow,0] == 42) Print("At Line ",A[iRow,1]," Col ",A[iRow,2]," opening /* has no closing */");
      else {
        if(A[iRow,0] == 123)      iChar=125; // {}
        else if(A[iRow,0] == 40 ) iChar=41 ; // ()
        else if(A[iRow,0] == 91 ) iChar=93 ; // []
        else                      iChar=A[iRow,0];
        Print("At Line ",A[iRow,1]," Col ",A[iRow,2]," opening ",CharToStr(A[iRow,0])," has no closing ",CharToStr(iChar));
      }
      iError++;
    }
    else if(A[iRow,3] == 68) { // "D"
      Print("At Line ",A[iRow,1]," Col ",A[iRow,2]," double quote \" has no match");
      iError++;
    }    
    else if(A[iRow,3] == 83) { // "S"
      Print("At Line ",A[iRow,1]," Col ",A[iRow,2]," single quote \' has no match");
      iError++;
    }      
    if(A[iRow,0] == 0) {
      if(A[iRow,3] == 42) Print("At Line ",A[iRow,4]," Col ",A[iRow,5]," closing */ has no opening /*"); 
      else {
        if(A[iRow,3] == 125)      iChar=123; // {}
        else if(A[iRow,3] == 41 ) iChar=40 ; // ()
        else if(A[iRow,3] == 93 ) iChar=91 ; // [] 
        else                      iChar=A[iRow,3];
        Print("At Line ",A[iRow,4]," Col ",A[iRow,5]," closing ",CharToStr(A[iRow,3])," has no opening ",CharToStr(iChar));
      }
      iError++;
    }  
  }

  sMsg="Program: "+ProgramName+"  Errors: "+iError;
  if(iError > 0) sMsg=sMsg+"\nClick on \"Terminal\", click on \"Experts\" to view errors";
  Alert(sMsg);
}

int OpenedWithChar(int iChar, int iLine, int iCol) {
  int iRow=A[0][1]+1, iRows=ArrayRange(A, 0);
  
  if(iRow >= iRows) {
    if(ArrayResize(A,iRow) == ERROR) {
      Print("ArrayResize error: ",ErrorDescription(GetLastError()));
      return(ERROR);
    }  
  }  
  
  A[iRow,0]=iChar;
  A[iRow,1]=iLine;
  A[iRow,2]=iCol;
  A[0][1]=iRow; // keep track of max row used
  return(1);
}

int ClosedWithChar(int iChar, int iLine, int iCol) {
  int    iRow=A[0][1], iRows, iPos=-1, i, iFind;
  
  if(iChar == 125)     iFind=123; // {}
  else if(iChar == 41) iFind=40;  // ()
  else if(iChar == 93) iFind=91;  // []
  else if(iChar == 42) iFind=42;  // /* */
  else if(iChar == 68) iFind=34;  // missing double quote and double quote
  else if(iChar == 83) iFind=39;  // missing single quote and single quote
  else                 iFind=iChar;
  
  for(i=iRow; i>0; i--) {
    if((A[i,0] == iFind) && (A[i,3] == 0)) {
      iPos=i;
      break;
    }
  }
  if(iPos == -1) {
    iRows=ArrayRange(A, 0);
    if(iRow+1>=iRows) {
      if(ArrayResize(A,iRow+1) == ERROR) {
        Print("ArrayResize error: ",ErrorDescription(GetLastError()));
        return(ERROR);
      }
    }
    iRow++;
    iPos=iRow; 
  }
  A[iPos,3]=iChar;
  A[iPos,4]=iLine;
  A[iPos,5]=iCol;
  A[0][1]=iRow; // keep track of max row used
  return(1); 
}
//+------------------------------------------------------------------+