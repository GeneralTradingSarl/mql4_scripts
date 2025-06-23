//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property script_show_inputs
///---
input bool InpMarketWatch=true;
//---
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <SymbolInfoSampleInit.mqh>
#include <SymbolInfo.mqh>
//+------------------------------------------------------------------+
//| Script to sample the use of class CSymbolInfo.                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Symbol Info Sample script class                                  |
//+------------------------------------------------------------------+
class CSymbolInfoSample
  {
protected:
   CSymbolInfo       m_symbol;
   //--- chart objects
   CChartObjectButton m_buttons[];
   int               m_num_symbols;
   CChartObjectLabel m_label_header;
   CChartObjectLabel m_label [];
   CChartObjectLabel m_label_info [];
   //---
   int               m_symbol_idx;

public:
                     CSymbolInfoSample(void);
                    ~CSymbolInfoSample(void);
   //---
   int               Init(void);
   void              Deinit(void);
   void              Processing(void);

private:
   void              InfoToChart(void);
   int               arraySize(int code_enum);
  };
//---
CSymbolInfoSample ExtScript;
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSymbolInfoSample::CSymbolInfoSample(void) : m_symbol_idx(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSymbolInfoSample::~CSymbolInfoSample(void)
  {
  }
//+------------------------------------------------------------------+
//| Method Init.                                                     |
//+------------------------------------------------------------------+
int CSymbolInfoSample::Init(void)
  {
   int   i,
         j,
         sy=10;
   int   dy=16;
   color color_label;
   color color_info;
//--- tuning colors
   color_info =(color)(ChartGetInteger(0,CHART_COLOR_BACKGROUND)^0xFFFFFF);
   color_label=(color)(color_info^0x202020);
//---
   if(ChartGetInteger(0,CHART_SHOW_OHLC))
      sy+=16;
//---
   m_num_symbols=SymbolsTotal(InpMarketWatch);
   ArrayResize(m_buttons,m_num_symbols);
   int un=1,deux=2;
   ArrayResize(m_label,arraySize(0)+arraySize(1)+arraySize(2)+arraySize(3));
   ArrayResize(m_label_info,ArraySize(m_label));
   int mod=10;
   if(m_num_symbols>100)
      mod=30;
//--- creation Button[]
   for(i=0; i<m_num_symbols; i++)
     {
      m_buttons[i].Create(0,"Button"+IntegerToString(i),0,10+50*(i%mod),sy+20*(i/mod),50,20);
      m_buttons[i].Description(SymbolName(i,InpMarketWatch));
      m_buttons[i].Color(Red);
      m_buttons[i].FontSize(8);
     }
   m_symbol_idx=0;
   m_symbol.Name(SymbolName(0,InpMarketWatch));
   m_buttons[0].State(true);
   sy+=20*(1+i/mod);
//--- creation header MarketInfo
   m_label_header.Create(0,"LabelHeader",0,20,sy+dy*0);
   m_label_header.Description(" Market Info ");
   m_label_header.Color(color_label);
   m_label_header.FontSize(8);
   sy+=20;
//--- Add Labels[] MarketInfo
   for(i=0,j=0; i<arraySize(0); i++,j++)
     {
      m_label[j].Create(0,"Label"         +IntegerToString(i),0,20,sy+dy*i);
      m_label[j].Description(init_l_newstr[i]);
      m_label[j].Color(color_label);
      m_label[j].FontSize(8);
      m_label[j].Font("Courier New");
      //---
      m_label_info[j].Create(0,"LabelInfo"+IntegerToString(i),0,20+350,sy+dy*i);
      m_label_info[j].Description(" ");
      m_label_info[j].Color(color_info);
      m_label_info[j].FontSize(8);
      m_label_info[j].Font("Courier New");
     }
//--- Add header SymbolInfoString
   i=0;
   sy-=20;
   m_label_header.Create(0,"LabelHeaderb",0,20+530,sy+dy*i);
   m_label_header.Description(" Symbol Info String ");
   m_label_header.Color(color_label);
   m_label_header.FontSize(8);
   sy+=20;
//--- Add Labels[] SymbolInfoString
   string valuestr="";
   for(int k=0; k<100; k++)
     {
      if(SymbolInfoString(m_symbol.Name(),k,valuestr))
        {
         m_label[j].Create(0,"Labelb"         +IntegerToString(i),0,20+530,sy+dy*i);
         m_label[j].Description(EnumToString((ENUM_SYMBOL_INFO_STRING)k));
         m_label[j].Color(color_label);
         m_label[j].FontSize(8);
         m_label[j].Font("Courier New");
         //---
         m_label_info[j].Create(0,"LabelInfob"+IntegerToString(i),0,20+530+280,sy+dy*i);
         m_label_info[j].Description(" ");
         m_label_info[j].Color(color_info);
         m_label_info[j].FontSize(8);
         m_label_info[j].Font("Courier New");
         i++;
         j++;
        }
     }
//--- Add header symbolInfoInteger
   long value=0;
   m_label_header.Create(0,"LabelHeaderc",0,20+530,sy+dy*i);
   m_label_header.Description(" Symbol Info Integer ");
   m_label_header.Color(color_label);
   m_label_header.FontSize(8);
   i++;
//--- Add Labels[]
   for(int k=0; k<100; k++)
     {
      if(SymbolInfoInteger(m_symbol.Name(),k,value))
        {
         m_label[j].Create(0,"Labelc"         +IntegerToString(i),0,20+530,sy+dy*i);
         m_label[j].Description(EnumToString((ENUM_SYMBOL_INFO_INTEGER)k));
         m_label[j].Color(color_label);
         m_label[j].FontSize(8);
         m_label[j].Font("Courier New");
         //---
         m_label_info[j].Create(0,"LabelInfoc"+IntegerToString(i),0,20+530+350,sy+dy*i);
         m_label_info[j].Description(" ");
         m_label_info[j].Color(color_info);
         m_label_info[j].FontSize(8);
         m_label_info[j].Font("Courier New");
         i++;
         j++;
        }
     }
//--- Add header symbolInfoDouble
   i=0;
   sy-=20;
   double valuedouble=0;
   m_label_header.Create(0,"LabelHeaderd",0,20+530+530,sy+dy*i);
   m_label_header.Description(" Symbol Info Double ");
   m_label_header.Color(color_label);
   m_label_header.FontSize(8);
   sy+=20;
//--- Add Labels[]
   for(int k=0; k<100; k++)
     {
      if(SymbolInfoDouble(m_symbol.Name(),k,valuedouble))
        {
         m_label[j].Create(0,"Labeld"         +IntegerToString(i),0,20+530+530,sy+dy*i);
         m_label[j].Description(EnumToString((ENUM_SYMBOL_INFO_DOUBLE)k));
         m_label[j].Color(color_label);
         m_label[j].FontSize(8);
         m_label[j].Font("Courier New");
         //---
         m_label_info[j].Create(0,"LabelInfod"+IntegerToString(i),0,20+530+530+350,sy+dy*i);
         m_label_info[j].Description(" ");
         m_label_info[j].Color(color_info);
         m_label_info[j].FontSize(8);
         m_label_info[j].Font("Courier New");
         i++;
         j++;
        }
     }
   InfoToChart();
//--- redraw chart
   ChartRedraw();
//---
//while(1==1)Sleep(5000);
//ExpertRemove();
   return(0);
  }
//+------------------------------------------------------------------+
//| Method Deinit.                                                   |
//+------------------------------------------------------------------+
void CSymbolInfoSample::Deinit(void)
  {
   ObjectsDeleteAll(0);
  }
//+------------------------------------------------------------------+
//| Method Processing.                                               |
//+------------------------------------------------------------------+
void CSymbolInfoSample::Processing(void)
  {
   int i=0;
//---
   if(!m_buttons[m_symbol_idx].State())
      m_buttons[m_symbol_idx].State(true);
   for(i=0; i<m_num_symbols; i++)
     {
      if(m_buttons[i].State() && m_symbol_idx!=i)
        {
         m_buttons[m_symbol_idx].State(false);
         m_symbol_idx=i;
         m_symbol.Name(m_buttons[i].Description());
        }
     }
   m_symbol.RefreshRates();
   InfoToChart();
//--- redraw chart (with the processing of events)
   ChartRedraw();
   Sleep(100);
  }
//+------------------------------------------------------------------+
//| Method InfoToChart.                                              |
//+------------------------------------------------------------------+
void CSymbolInfoSample::InfoToChart(void)
  {

   string str="";
   double value=0;
   long   valueint=0;
   string blanks="                                ";
   int j=0;
   for(int i=0; i<ArraySize(m_label); i++)
     {
      if(i>=arraySize(0)+arraySize(1)+arraySize(2))
        {
         if(i==arraySize(0)+arraySize(1)+arraySize(2))
            j=0;
         while(!SymbolInfoDouble(m_symbol.Name(),j,value)&&j<1000)
            j++;
         if(StringSubstr(EnumToString((ENUM_SYMBOL_INFO_DOUBLE)j),0,15)==StringSubstr("SYMBOL_TRADE_CONTRACT_SIZE",0,15)||
            StringSubstr(EnumToString((ENUM_SYMBOL_INFO_DOUBLE)j),0,12)==StringSubstr("SYMBOL_VOLUME_",0,12)||
            StringSubstr(EnumToString((ENUM_SYMBOL_INFO_DOUBLE)j),0,12)==StringSubstr("SYMBOL_MARGIN_",0,12))
            str=StringSubstr(blanks,0,20-StringLen(DoubleToString(value,2)))+
                DoubleToString(value,2);
         else
            str=StringSubstr(blanks,0,20-StringLen(DoubleToString(value,m_symbol.Digits())))+
                DoubleToString(value,m_symbol.Digits());
         m_label_info[i].Description(str);
         m_label_info[i].Font("Courier New");
         //if (m_symbol_idx==0)
         //   Print(EnumToString((ENUM_SYMBOL_INFO_DOUBLE)j)," ",value," ",m_symbol.Digits()," ",str);
         j++;
        }
      else
         if(i>=arraySize(0)+arraySize(1))
           {
            if(i==arraySize(0)+arraySize(1))
               j=0;
            while(!SymbolInfoInteger(m_symbol.Name(),j,valueint)&&j<1000)
               j++;
            if(j==SYMBOL_SELECT||j==SYMBOL_VISIBLE||j==SYMBOL_SPREAD_FLOAT)
               str=BoolToString((bool)(int)valueint);
            else
               if(j==SYMBOL_TIME||j==SYMBOL_START_TIME||j==SYMBOL_EXPIRATION_TIME)
                  str=TimeToString((datetime)valueint,TIME_SECONDS);
               else
                  if(j==SYMBOL_SPREAD)
                     str=IntegerToString((int)valueint);
                  else
                     if(j==SYMBOL_TRADE_CALC_MODE)
                       {
                        static string gg[]= {"FOREX","CFD","Futures","CFD indices"};
                        str=gg[(int)valueint];
                       }
                     else
                        if(j==SYMBOL_TRADE_MODE)
                          {
                           static string hh[]= {"Trade is disabled for the symbol",
                                                "Only long positions",
                                                "Only short positions",
                                                "Only close positions"
                                               };
                           str=hh[(int)valueint];
                          }
                        else
                           if(j==SYMBOL_TRADE_EXEMODE)
                             {
                              static string ii[]= {"No trade restrictions",
                                                   "Execution by request",
                                                   "Instant execution",
                                                   "Market execution"
                                                  };
                              str=ii[(int)valueint];
                             }
                           else
                              if(j==SYMBOL_SWAP_ROLLOVER3DAYS)
                                {
                                 static string jj[]= {"No trade restrictions",
                                                      "Execution by request",
                                                      "Instant execution",
                                                      "Market execution"
                                                     };
                                 str=EnumToString((ENUM_DAY_OF_WEEK)(int)valueint);
                                }
                              else
                                 if(j==SYMBOL_SWAP_MODE)
                                   {
                                    static string kk[]= {"points","base currency","interest;","margin currency"};
                                    str=kk[(int)valueint];
                                   }
                                 else
                                    str=IntegerToString((int)valueint);
            if(StringLen(str)>19)
               str=StringSubstr(str,0,19);
            str=StringSubstr(blanks,0,20-StringLen(str))+str;
            m_label_info[i].Description(str);
            j++;
            //Print(str," ",EnumToString((ENUM_SYMBOL_INFO_STRING)j));
           }
         else
            if(i>=arraySize(0))
              {
               while(!SymbolInfoString(m_symbol.Name(),j,str)&&j<1000)
                  j++;
               if(StringLen(str)>29)
                  str=StringSubstr(str,0,29);
               str=StringSubstr(blanks,0,30-StringLen(str))+str;
               m_label_info[i].Description(str);
               j++;
               //Print(str," ",EnumToString((ENUM_SYMBOL_INFO_STRING)j));
              }
            else
              {
               if(init_l_newstrint[i]!=MODE_LEVERAGE)
                  value=MarketInfo(m_symbol.Name(),init_l_newstrint[i]);
               if(init_l_newstrint[i]==MODE_TRADEALLOWED||
                  init_l_newstrint[i]==MODE_CLOSEBY_ALLOWED)
                  str=StringSubstr(blanks,0,20-StringLen(BoolToString((bool)(int)value)))+
                      BoolToString((bool)(int)value);
               else
                  if(init_l_newstrint[i]==MODE_LOW||
                     init_l_newstrint[i]==MODE_HIGH||
                     init_l_newstrint[i]==MODE_BID||
                     init_l_newstrint[i]==MODE_ASK||
                     init_l_newstrint[i]==MODE_POINT||
                     init_l_newstrint[i]==MODE_TICKSIZE)
                     str=StringSubstr(blanks,0,20-StringLen(DoubleToStr(value,(int)MarketInfo(m_symbol.Name(),MODE_DIGITS))))+
                         DoubleToStr(value,(int)MarketInfo(m_symbol.Name(),MODE_DIGITS));
                  else
                     if(init_l_newstrint[i]==MODE_TICKVALUE)
                        str=StringSubstr(blanks,0,20-StringLen(DoubleToStr(value,(int)MarketInfo(AccountCurrency(),MODE_DIGITS))))+
                            DoubleToStr(value,(int)MarketInfo(AccountCurrency(),MODE_DIGITS));
                     else
                        if(init_l_newstrint[i]==MODE_TIME)
                           str=StringSubstr(blanks,0,20-StringLen(TimeToString((datetime)value,TIME_SECONDS)))+
                               TimeToString((datetime)value,TIME_SECONDS);
                        else
                           if(init_l_newstrint[i]==MODE_STARTING||
                              init_l_newstrint[i]==MODE_EXPIRATION)
                              str=StringSubstr(blanks,0,20-StringLen(TimeToString((datetime)value,TIME_DATE)))+
                                  TimeToString((datetime)value,TIME_DATE);
                           else
                              if(init_l_newstrint[i]==MODE_MARGINREQUIRED||
                                 init_l_newstrint[i]==MODE_MARGININIT||
                                 init_l_newstrint[i]==MODE_LOTSTEP||
                                 init_l_newstrint[i]==MODE_MINLOT)
                                 str=StringSubstr(blanks,0,20-StringLen(DoubleToStr(value,2)))+
                                     DoubleToStr(value,2);
                              else
                                 if(init_l_newstrint[i]==MODE_DIGITS||
                                    init_l_newstrint[i]==MODE_FREEZELEVEL||
                                    init_l_newstrint[i]==MODE_SPREAD||
                                    init_l_newstrint[i]==MODE_STOPLEVEL)
                                    str=StringSubstr(blanks,0,20-StringLen(IntegerToString((int)value)))+
                                        IntegerToString((int)value);
                                 else
                                    if(init_l_newstrint[i]==MODE_PROFITCALCMODE)
                                      {
                                       string gg[]= {"FOREX","CFD","Futures"};
                                       str=StringSubstr(blanks,0,20-StringLen(gg[(int)value]))+
                                           gg[(int)value];
                                      }
                                    else
                                       if(init_l_newstrint[i]==MODE_MARGINCALCMODE)
                                         {
                                          static string hh[]= {"FOREX","CFD","Futures","CFD or indices"};
                                          str=StringSubstr(blanks,0,20-StringLen(hh[(int)value]))+
                                              hh[(int)value];
                                         }
                                       else
                                          if(init_l_newstrint[i]==MODE_SWAPTYPE)
                                            {
                                             static string ii[]= {"points","base currency","interest;","margin currency"};
                                             str=StringSubstr(blanks,0,20-StringLen(ii[(int)value]))+
                                                 ii[(int)value];
                                            }
                                          else
                                             if(init_l_newstrint[i]==MODE_LEVERAGE)
                                                str=StringSubstr(blanks,0,20-StringLen(IntegerToString(m_symbol.Leverage())))+
                                                    IntegerToString(m_symbol.Leverage());
                                             else
                                                str=StringSubstr(blanks,0,20-StringLen((string)value))+
                                                    (string)value;

               m_label_info[i].Description(str);
              }
     }
  }
//+------------------------------------------------------------------+
//| Method arraySize.                                                |
//+------------------------------------------------------------------+
int CSymbolInfoSample::arraySize(int code_enum)
  {
   int j=0;
   long value=0;
   string valuestr;
   double valuedouble;
   if(code_enum==0)
      j=ArraySize(init_l_newstrint);
   else
      if(code_enum==1)
         for(int i=0; i<1000; i++)
            if(SymbolInfoString(m_symbol.Name(),i,valuestr)/*||EnumToString((ENUM_SYMBOL_INFO_STRING)i)!="ENUM_SYMBOL_INFO_STRING::"+i*/)
               j++;
            else
               continue;
      else
         if(code_enum==2)
            for(int i=0; i<1000; i++)
               if(SymbolInfoInteger(m_symbol.Name(),i,value)/*||EnumToString((ENUM_SYMBOL_INFO_INTEGER)i)!="ENUM_SYMBOL_INFO_INTEGER::"+i*/)
                  j++;
               else
                  continue;
         else
            if(code_enum==3)
               for(int i=0; i<100000; i++)
                  if(SymbolInfoDouble(m_symbol.Name(),i,valuedouble)/*||EnumToString((ENUM_SYMBOL_INFO_DOUBLE)i)!="ENUM_SYMBOL_INFO_DOUBLE::"+i*/)
                     j++;
                  else
                     continue;

   return (j);
  }
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
int OnStart(void)
  {
//--- call init function
   if(ExtScript.Init()==0)
     {
      //--- cycle until the script is not halted
      while(!IsStopped())
         ExtScript.Processing();
     }
//--- call deinit function
   ExtScript.Deinit();
//---
   return(0);
  }
//+------------------------------------------------------------------+

