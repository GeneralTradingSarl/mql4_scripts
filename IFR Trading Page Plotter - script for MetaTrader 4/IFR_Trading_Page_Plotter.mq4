//+------------------------------------------------------------------+
//|                                     IFR Trading Page Plotter.mq4 |
//|                                                                  |
//|                                             Author: Jason Hooper |
//|                                               Date: July 3, 2010 |
//|                                         E-Mail: nirgle@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Jason Hooper"
#property link      ""

#define NUM_LINES 8
#define MAX_COMMENTARY_LINES 10

// Your timezone's offset from UTC
extern int UTCHoursOffset = -5;

#define  COLOR_PRICEABOVE        Red
#define  COLOR_PRICEBELOW        SteelBlue
#define  COLOR_POSITION          Black
#define  COLOR_TARGET            LimeGreen
#define  COLOR_STOP              Red
#define  COLOR_COMMENTARY        Black
#define  COLOR_TARGET_RECTANGLE  C'0xB5,0xD2,0xB5'
#define  COLOR_STOP_RECTANGLE    C'0xFC,0xA4,0xA3'

int start()
{
   int win = WindowOnDropped();
   string sym = Symbol();
   
   // If symbol is "EURUSD" then the filename we'll search for is "EURUSD.txt"
   string filename = sym + ".txt";
   
   UpdateWindowFromFile(win, sym, filename);  
   
   return(0);
}

void UpdateWindowFromFile(int windowHandle, string symbol, string filename)
{
   int handle, techSpotLineNumber = 0;
   bool nextLineIsPositionPrice = false;
   bool inCommentarySection = false;
   int commentaryLine = 0;
   string commentaryAll;
   string str, commentaryLineObjectId;   
   
   // Information gathered (on different lines) about any open position
   double positionPrice, positionTarget, positionStop;
   bool positionOpen = false, positionLong;
   string positionDate, positionTime;
   
   // Where on lines the segments of strings we're looking for
   // ! [SPOT]    ![TECHNICAL SIGNIFICANCE]  ![RECOMMENDATION]         ! [POSITION]  !
   // } 1.5345(M)  Daily High May 3           Flat On A Failure          [LONG at]    
   // 01234567890123456789012345678901234567890123456789012345678901234567890123456789
   //           1         2         3         4         5         6         7
   //
   // These can/will be updated later as the file is actually read, these are just defaults
   int idxSpotPrice = 2, lenSpotPrice = 6;
   int idxTechSig = 13, lenTechSig = 39 - 13;
   int idxRecom = 40, lenRecom = 66 - 40;
   int idxPosition = 68, lenPosition = 6;
   
   // Open file
   handle = FileOpen(filename, FILE_READ);   
   if (handle < 1)
   {
      Print("File " + filename + " not found: ", GetLastError());
      return(false);
   }
   
   // Delete old objects
   for (int i = 0;  i < NUM_LINES;  i++)
   {
      string objectId = "tech" + i;
            
      // Delete old line
      ObjectDelete(objectId);
      ObjectDelete("position");
      ObjectDelete("targetrectangle");
      ObjectDelete("stoprectangle");
   }
   
   while (!FileIsEnding(handle))
   {
      str = FileReadString(handle);
      
      if (str != "")
      {
         // If we're at the line that shows us where the columns are lined up...
         if (StringFind(str, "[SPOT]") > 0)
         {          
            idxSpotPrice = StringFind(str, "! [SPOT]") + 2;
            idxTechSig = StringFind(str, "![TECHNICAL SIGNIFICANCE]") + 1;
            idxRecom = StringFind(str, "![RECOMMENDATION]") + 1;
            idxPosition = StringFind(str, "! [POSITION]") + 3;
            
            lenSpotPrice = idxTechSig - idxSpotPrice;
            lenTechSig = idxRecom - idxTechSig;
            lenRecom = idxPosition - idxRecom - 3;            
            
            Print("[[" + idxSpotPrice + " " + idxTechSig + "]]");
         }

         else
         {
            // Figure out which line we're on
            string lineType = StringSubstr(str, 0, 1);
                        
            // We're on a spot price line, extract the goods...
            if (lineType == "}")
            {
               string strSpot = StringSubstr(str, idxSpotPrice, lenSpotPrice);
               string strTechSig = StringTrimRight(StringSubstr(str, idxTechSig, lenTechSig));
               string strRecom = StringTrimRight(StringSubstr(str, idxRecom, lenRecom));
               
               // Remove the (M) stuff from the spot price 
               if (StringFind(strSpot, "(") > 0)
                  strSpot = StringSubstr(strSpot, 0, StringFind(strSpot, "("));
            
               Print("{" + strSpot + "} {" + strTechSig + "} {" + strRecom + "}");
               
               // Plot the line
               double price = StrToDouble(strSpot);
               objectId = "tech" + techSpotLineNumber;
               
               // Add horizontal line for this price to chart background
               ObjectCreate(objectId, OBJ_HLINE, windowHandle, D'2010.05.01 12:30', price);
               ObjectSetText(objectId, strTechSig + " -- " + strRecom, 8, "Arial", White);
               ObjectSet(objectId, OBJPROP_BACK, true);
   
               // Color appropriately
               if (price > iClose(symbol, 0, 0))
                  ObjectSet(objectId, OBJPROP_COLOR, COLOR_PRICEABOVE);
               else
                  ObjectSet(objectId, OBJPROP_COLOR, COLOR_PRICEBELOW);
                  
               techSpotLineNumber++;          
            }
            
            // No way to tell what lines the position information is on but we can identify the different
            // keywords and extract information about the open position as we go            
            
            // If this is set true from the last line, read the price the position was opened at
            if (nextLineIsPositionPrice == true)
            {
               string sPrice = StringSubstr(str, idxPosition, 10);               
               sPrice = StringSubstr(sPrice, 0, StringFind(sPrice, "]"));
               
               positionPrice = StrToDouble(sPrice);
               
               nextLineIsPositionPrice = false;
            }
            
            // This is where the LONG/SHORT/FLAT will be
            string s = StringSubstr(str, idxPosition, 4);
            
            if (s == "LONG")
            {
               positionOpen = true;
               positionLong = true;
               nextLineIsPositionPrice = true;
            }
            else if (s == "SHOR")
            {
               positionOpen = true;
               positionLong = false;
               nextLineIsPositionPrice = true;
            }
            else if (s == "FLAT")
            {
               positionOpen = false;
            }
            
            // If we're reading the date, time, limits of the position
            s = StringSubstr(str, idxPosition - 3, 6);
            string s2 = StringSubstr(str, idxPosition - 3 + 6);
            
            if (s == "!Open!")
               positionDate = StringTrimRight(s2);
            else if (s == "!TIME!")
               positionTime = StringTrimRight(s2);
            else if (s == "!TGT !")
               positionTarget = StrToDouble(s2);
            else if (s == "!Stop!")
               positionStop = StrToDouble(s2);
               
            if (inCommentarySection == true)
            {  
               // A line starting with ' denotes the last line in the commentary section
               if (StringSubstr(str, 0, 1) == "'")
               {
                  inCommentarySection = false;
                  
                  // Trim the leading/trailing apostrophe
                  str = StringTrimRight(StringSubstr(str, 0, StringLen(str) - 1));
               }
                  
               // Add to the running commentary.  Painted after this loop             
               commentaryAll = commentaryAll + " " + StringTrimRight(StringTrimLeft(StringSubstr(str, 1)));
            }
               
            // The line of ===== marks the start of the commentary section which we will plot in the upper right of the window
            if (lineType == "=")
               inCommentarySection = true;            
         }
      }  
   }
   
   // Draw the commentary
   if (commentaryAll != "")
      DrawCommentary(windowHandle, StringTrimLeft(StringTrimRight(commentaryAll)));

   if (positionOpen == true)
   {
      datetime positionDateTime = IFRDateTime(positionDate, positionTime);
      
      Print("Open position price is [" + positionPrice + "], opened [" + positionDate + "] [" + positionTime + "]");    
      Print("Stop is [" + positionStop + "], target is [" + positionTarget + "]");
      
      ObjectCreate("position", OBJ_ARROW, windowHandle, positionDateTime - UTCHoursOffset * 3600, positionPrice);
         
      ObjectCreate("targetrectangle", OBJ_RECTANGLE, windowHandle, positionDateTime - UTCHoursOffset * 3600, positionPrice, TimeCurrent() + 3600 * 24, positionTarget);
      ObjectCreate("stoprectangle", OBJ_RECTANGLE, windowHandle, positionDateTime - UTCHoursOffset * 3600, positionPrice, TimeCurrent() + 3600 * 24, positionStop);

      ObjectSet("targetrectangle", OBJPROP_COLOR, COLOR_TARGET_RECTANGLE);
      ObjectSet("stoprectangle", OBJPROP_COLOR, COLOR_STOP_RECTANGLE);
              
      ObjectSet("position", OBJPROP_COLOR, COLOR_POSITION);
      
      // Long is true, short is false
      if (positionLong == true)
         ObjectSet("position", OBJPROP_ARROWCODE, SYMBOL_ARROWUP);         
      else
         ObjectSet("position", OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   }
   else
      Print("No open position on this pair.");
   
   FileClose(handle);
}

datetime IFRDateTime(string date, string time)
{
   // Convert / to . in date   
   return(StrToTime(StringReplace(date, "/", ".") + " " + time));
}

string StringReplace(string s, string from, string to)
{
   string newString = "";
   
   for (int i = 0;  i < StringLen(s);  i++)
      if (StringSubstr(s, i, 1) == from)
         newString = newString + to;
      else
         newString = newString + StringSubstr(s, i, 1);
         
   return(newString);
}


void DrawCommentary(int windowId, string commentary)
{
   for (int line = 0;  line < MAX_COMMENTARY_LINES;  line++)
      ObjectDelete("commentaryLine" + line);

   int commentaryLine = 0;
   
   while (StringLen(commentary) > 0 && commentaryLine < MAX_COMMENTARY_LINES)
   {
      // Get as many full words as possible that fit into the 64-char allowable label width
      int ptr = 63;
      
      if (StringLen(commentary) < 64)
         ptr = 0;
      else
         while (StringSubstr(commentary, ptr, 1) != " " && ptr > 0)
            ptr--;
         
      string segment = StringTrimLeft(StringTrimRight(StringSubstr(commentary, 0, ptr)));
      
      // This line is part of the textual commentary at the bottom of the trading page.
      // Plot in the upper-right corner of the window
      string commentaryLineObjectId = "commentaryLine" + commentaryLine;
   
      ObjectCreate(commentaryLineObjectId, OBJ_LABEL, 0, 0, 0);
      ObjectSet(commentaryLineObjectId, OBJPROP_CORNER, 1);
      ObjectSet(commentaryLineObjectId, OBJPROP_YDISTANCE, 13 * commentaryLine + 3);
      ObjectSet(commentaryLineObjectId, OBJPROP_XDISTANCE, 5);
      ObjectSetText(commentaryLineObjectId, segment, 8, "Tahoma", COLOR_COMMENTARY);

      commentary = StringSubstr(commentary, ptr);

      if (ptr == 0)
         break;
               
      // Draw the next line (if any) below this one
      commentaryLine++;
   }
}

