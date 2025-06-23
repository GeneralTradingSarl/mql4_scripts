//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|                                                 s-PSI@CalculateProfitFromTime.mq4 |
//|                                       Copyright © 2011, Igor Stepovoi aka TarasBY |
//|                                                                taras_bulba@tut.by |
//|                                                                                   |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|   This product is intended for non-commercial use.  The publication is only allo- |
//|wed when you specify the name of the author (TarasBY). Edit the source code is va- |
//|lid only under condition of preservation of the text, links and author's name.     |
//|   Selling a script or(and) parts of it PROHIBITED.                                |
//|   The author is not liable for any damages resulting from the use of a script.    |
//|   For all matters relating to the work of the script, comments or suggestions for |
//|their improvement in the contact Skype: TarasBY or e-mail.                         |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
#property copyright "Copyright © 2008-12, TarasBY WM R418875277808; Z670270286972"
#property link      "taras_bulba@tut.by"
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
#property show_inputs
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|                 *****        Parameters of script         *****                   |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
extern string   Parameter = "====The parameters of calculation results of the work====";
extern int      MG           = 880; 
/*extern*/ string   List_MAGIC   = "";
extern datetime TimeBegin    = D'2011.01.01 00:00';
//IIIIIIIIIIIIIIIIIIII=========Global Values of script==========IIIIIIIIIIIIIIIIIIIIII+
double gda_Pribul[][9][25]; 
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|               Custom script iteration function                                    |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
int start()
{
    string ls_txt[3], ls_INF[3], ls_TIME, ls_Itog,
           ls_ORD[] = {"BUY","SELL","ALL"}, ls_INFO[] = {"PROFIT","LOTS","ORDERS"};
    int lia_MG[1], li_IND;
//----
    if (StringLen (List_MAGIC) > 0) {fStringToArrayINT (List_MAGIC, lia_MG);}
    else {lia_MG[0] = MG;}
    fCalculatePribul (Symbol(), gda_Pribul, lia_MG, TimeBegin);
    int li_size = 1;
    if (StringLen (List_MAGIC) > 0) li_size = ArraySize (lia_MG) + 1;
    for (int li_MG = 0; li_MG < li_size; li_MG++)
    {
        if (gda_Pribul[li_MG][8][24] == 0.0) continue;
        ls_txt[0] = StringConcatenate ("MG = ", lia_MG[li_MG], ":");
        if (li_MG == ArraySize (lia_MG)) {if (StringLen (List_MAGIC) > 0) ls_txt[0] = "MG = ALL:";}
        Print (ls_txt[0]);
        for (int li_ORD = 0; li_ORD < 3; li_ORD++)
        {
            ls_txt[1] = StringConcatenate ("Orders[", ls_ORD[li_ORD], "]: ");
            for (int li_INF = 0; li_INF < 3; li_INF++)
            {
                ls_txt[2] = StringConcatenate (ls_txt[1], "Info[", ls_INFO[li_INF], "]:  ");
                ls_TIME = "";
                for (int li_TIME = 0; li_TIME <= 24; li_TIME++)
                {
                    li_IND = 3 * li_INF + li_ORD;
                    if (li_IND >= 6) {if (gda_Pribul[li_MG][li_IND][li_TIME] == 0.0) continue;}
                    if (li_TIME == 24) {ls_Itog = "ALL = ";} else {ls_Itog = StringConcatenate (li_TIME, ":00 = ");}
                    ls_TIME = StringConcatenate (ls_TIME, ls_Itog, gda_Pribul[li_MG][li_IND][li_TIME], "; ");
                }
                Print (ls_txt[2], ls_TIME);
            }
        }
    }
//----
    return (0);
}
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|  Àutor    : TarasBY                                                               |
//+-----------------------------------------------------------------------------------+
//|       Calculate Profit                                                            |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
void fCalculatePribul (string fs_Symbol, 
                       double& ar_Pribul[][][],
                       int ar_Magic[], 
                       datetime dt = 0)
{
    int      li_int, li_Range, li_MG, li_TIME, li_Type, li_cnt = 0,
             history_total = OrdersHistoryTotal();
    double   ld_Pribul = 0, ld_Lots = 0;
//----
    li_Range = ArraySize (ar_Magic);
    ArrayResize (ar_Pribul, li_Range + 1);
    ArrayInitialize (ar_Pribul, 0.0);
    for (li_int = history_total - 1; li_int >= 0; li_int--)
    {
        if (!OrderSelect (li_int, SELECT_BY_POS, MODE_HISTORY)) continue;
        li_MG = fCheck_MyMagic (OrderMagicNumber(), ar_Magic);
        if (li_MG < 0) continue;
        if (OrderSymbol() != fs_Symbol) continue;
        if (OrderType() > 1) continue;
        if (dt > OrderCloseTime()) continue;
        li_Type = OrderType();
        ld_Pribul = OrderProfit() + OrderSwap() + OrderCommission();
        li_TIME = TimeHour (OrderOpenTime());
        //****************************************
        ar_Pribul[li_MG][li_Type][li_TIME] += ld_Pribul;
        ar_Pribul[li_MG][li_Type][24] += ld_Pribul;
        ar_Pribul[li_MG][2][li_TIME] += ld_Pribul;
        ar_Pribul[li_MG][2][24] += ld_Pribul;
        ar_Pribul[li_Range][li_Type][li_TIME] += ld_Pribul;
        ar_Pribul[li_Range][li_Type][24] += ld_Pribul;
        ar_Pribul[li_Range][2][li_TIME] += ld_Pribul;
        ar_Pribul[li_Range][2][24] += ld_Pribul;
        //****************************************
        ld_Lots = OrderLots();
        ar_Pribul[li_MG][3+li_Type][li_TIME] += ld_Lots;
        ar_Pribul[li_MG][3+li_Type][24] += ld_Lots;
        ar_Pribul[li_MG][5][li_TIME] += ld_Lots;
        ar_Pribul[li_MG][5][24] += ld_Lots;
        ar_Pribul[li_Range][3+li_Type][li_TIME] += ld_Lots;
        ar_Pribul[li_Range][3+li_Type][24] += ld_Lots;
        ar_Pribul[li_Range][5][li_TIME] += ld_Lots;
        ar_Pribul[li_Range][5][24] += ld_Lots;
        //****************************************
        ar_Pribul[li_MG][6+li_Type][li_TIME]++;
        ar_Pribul[li_MG][6+li_Type][24]++;
        ar_Pribul[li_MG][8][li_TIME]++;
        ar_Pribul[li_MG][8][24]++;
        ar_Pribul[li_Range][6+li_Type][li_TIME]++;
        ar_Pribul[li_Range][6+li_Type][24]++;
        ar_Pribul[li_Range][8][li_TIME]++;
        ar_Pribul[li_Range][8][24]++;
        li_cnt++;
    }
    Print ("Total orders in history ", li_cnt, " p.");
//----
    return;
}
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|  Àutor    : TarasBY                                                               |
//+-----------------------------------------------------------------------------------+
//|       Check Magic                                                                 |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
int fCheck_MyMagic (int fi_Magic, int ar_Magic[])
{
//----
    for (int li_int = 0; li_int < ArraySize (ar_Magic); li_int++)
    {if (fi_Magic == ar_Magic[li_int]) return (li_int);}
//----
    return (-1);
}
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
//|  Description : Return array INT from string.                                      |
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+
int fStringToArrayINT (string List, int& iArray[], string sDelimiter = ",")
{
    int i = 0, num;
    string ls_tmp;
//----
    ArrayResize (iArray, 0);
    while (StringLen (List) > 0)
    {
        num = StringFind (List, sDelimiter);
        if (num < 0)
        {
            ls_tmp = List;
            List = "";
        }
        else
        {
            ls_tmp = StringSubstr (List, 0, num);
            List = StringSubstr (List, num + 1);
        }
        i++;
        ArrayResize (iArray, i);
        iArray[i-1] = StrToInteger (ls_tmp);
    }
//----
    return (ArraySize (iArray));
}
//IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII+

