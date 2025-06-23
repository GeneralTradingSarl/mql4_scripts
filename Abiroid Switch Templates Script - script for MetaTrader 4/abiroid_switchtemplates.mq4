//+------------------------------------------------------------------+
//|                                                          Abiroid |
//|                                              https://abiroid.com |
//+------------------------------------------------------------------+
#property copyright "Abiroid"
#property link "https://abiroid.com"
#property version "1.1"
#property strict

//----
extern string Templates = "1.tpl,2.tpl,3.tpl";
extern bool   ApplyAllCharts = true;  // Apply New Template to All Charts
//----

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   // Vars:
   long thisChartID = ChartID();
   string newTemplate = "";
   string TemplateArray[];

   // Split Array
   StringSplit(Templates, ',', TemplateArray);
   int size = ArraySize(TemplateArray);
   for(int i=0; i < size; i++) {
      TemplateArray[i] = StringTrimLeft(StringTrimRight(TemplateArray[i]));
   }

   // Global based on Template number - array index+1
   int num;
   if(ApplyAllCharts) num = (int) GlobalVariableGet("AbiroidTemplate");
   else               num = (int) GlobalVariableGet("AbiroidTemplate_" + (string)thisChartID);

   // If run for first time - no global variable set yet - so set to 1st
   if(num == 0) {
      num = 1;
   } else {
      num++;
      if(num > size) num = 1;
   }
   newTemplate = TemplateArray[num-1];
   //GlobalVariableSet("AbiroidTemplate", num);
   if(ApplyAllCharts) GlobalVariableSet("AbiroidTemplate", num);
   else               GlobalVariableSet("AbiroidTemplate_" + (string)thisChartID, num);

   // Apply Template to all except current chart
   if(ApplyAllCharts) {
      long chartID = ChartFirst();
      int  i = 0, limit = 100;
      while(i < limit) {
         // If current chart ID - skip for now - and apply last
         // - because script gets uninitialized with new template before finishing
         // (unint reason 7)
         if(chartID != thisChartID) {
            ApplyTemplate(chartID, newTemplate);
            //Print(i, ":", ChartSymbol(chartID), " ID =", chartID);
         }
         
         chartID = ChartNext(chartID);
         if(chartID < 0) break;
         i++;
      }
   }
   
   // Apply Template for current chart
   ApplyTemplate(thisChartID, newTemplate);
}

//+------------------------------------------------------------------+
void ApplyTemplate(long CID, string templateName)
//+------------------------------------------------------------------+
{
   if(ChartApplyTemplate(CID, templateName)) {
      Print("The template " + templateName + " applied successfully");
   } else {
      Print("Failed to apply " + templateName + ", error code ", GetLastError());
   }
}

//+------------------------------------------------------------------+
