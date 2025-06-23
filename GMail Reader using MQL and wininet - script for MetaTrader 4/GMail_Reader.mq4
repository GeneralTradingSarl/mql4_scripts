//+------------------------------------------------------------------+
//|                                                 GMail Reader.mq4 |
//|                             Copyright © 2011, Stephen Ambatoding |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Stephen Ambatoding"
#property link      "http://www.metaquotes.net"

#property show_inputs
extern string GMailUserName = "";
extern string GMailPassword = "";
extern int	  NumOfEntries = 5;

#define INTERNET_OPEN_TYPE_PRECONFIG	0x0
#define INTERNET_FLAG_PRAGMA_NOCACHE	0x00000100 
#define INTERNET_FLAG_RELOAD           0x80000000
#define INTERNET_FLAG_SECURE      		0x00800000

#define CRYPT_STRING_BASE64 				0x00000001

#import "wininet"
	int InternetOpenA(string lpszAgent, int dwAccessType, string lpszProxyName, string lpszProxyBypass, int dwFlags);
	int InternetOpenUrlA(int hInternet, string lpszUrl, string lpszHeaders, int dwHeadersLength, int dwFlags, int dwContext);
	bool InternetReadFile(int hFile, string lpBuffer, int dwNumberOfBytesToRead, int& lpdwNumberOfBytesRead[]);
	int InternetCloseHandle(int hInternet);

#import "Crypt32.dll"
	int CryptBinaryToStringA(string src, int cbBinary, int dwFlags, string pszString, int& pcchString[]);
	
#import

int start()
{
	if(GMailUserName=="" || GMailPassword=="") {
		Alert("User Name / Password is blank!");
		return;
	}
	int hOpen = 0;
	int hFile = 0;
	
	Comment("");
	hOpen = InternetOpenA("sangmane", INTERNET_OPEN_TYPE_PRECONFIG, "", "", 0);
	if (hOpen>0)
	{
		string url = "https://mail.google.com/mail/feed/atom";
		string base64 = "12345678901234567890123456789012345678901234567890123456789012345678901234567890";
		string userpass = GMailUserName+":"+GMailPassword;
		int outLen[1];
		outLen[0] = StringLen(base64);
		CryptBinaryToStringA(userpass,StringLen(userpass),CRYPT_STRING_BASE64,base64,outLen);
		string header = "Authorization: Basic "+StringTrimRight(base64);
		hFile = InternetOpenUrlA(hOpen, url, header, StringLen(header), INTERNET_FLAG_PRAGMA_NOCACHE|INTERNET_FLAG_RELOAD|INTERNET_FLAG_SECURE, 0);
		if (hFile>0)
		{
			int bytesRead[1]={0};
			bool list = false;
			bool entry = false;
			string data = "";
			string display="\n";
			int p1,p2;
			while (True)
			{
				string buffer = "1234567890123456";
				bool res = InternetReadFile(hFile, buffer, StringLen(buffer), bytesRead);
				if(!res)
				{
					break;
				}
				if(bytesRead[0]==0)
				{
					break;
				}
				buffer = StringSubstr(buffer,0,bytesRead[0]);
				data = data + buffer;
			
				while(True)
				{
					if(NumOfEntries==0) break;
					bool terus = false;				

					string mail = Parse("entry",data);
					if(mail=="") break;
					NumOfEntries--;	
					string aTags[4] = {"title","summary","author","contributor"};
					string aHeaders[4] = {"Subject: ","Summary: ","From: ","To: "};
					for(int k=0; k<ArraySize(aTags); k++)
					{
						string s = Parse(aTags[k],mail);
						if(s!="")
						{
							display = display + aHeaders[k] + " ";
							if(k>=2)
							{
								string name = Parse("name",s);
								if(name!="")
								{
									display = display+name+" ";
								}
								
								string address = Parse("email",s);
								if(address!="")
								{
									display = display+address;
								}								
							}
							else
							{
								display = display+s;
							}
							display = display+"\n";
						}
					}
					display = display+"\n";	
				}
				Comment(display);	
			}
			InternetCloseHandle(hFile);
		}
		InternetCloseHandle(hOpen);
	}
	return(0);
}

string Parse(string tag, string &data)
{
	string openTag = "<"+tag+">";
	string closeTag = "</"+tag+">";
	string res="";
	int p1;
	int p2 = StringFind(data,closeTag,0);
	if(p2>=0)
	{
		p1 = StringFind(data,openTag,0)+StringLen(openTag);
		res = StringSubstr(data,p1,p2-p1);
		data = StringSubstr(data,p2+StringLen(closeTag),StringLen(data)-(p2+StringLen(closeTag)));
	}
	res = DecodeEscapeChars(res);
	if(tag=="email") res = "<"+res+">";
	return(res);
}

string DecodeEscapeChars(string s)
{
	int aChars[5]={34,38,39,60,62};
	for(int i=0; i<ArraySize(aChars); i++)
	{
		int p = StringFind(s,"&#"+DoubleToStr(aChars[i],0)+";",0);
		if(p>=0)
		{
			s = StringSubstr(s,0,p)+
				 CharToStr(aChars[i])+
				 StringSubstr(s,p+5,StringLen(s)-(p+5));
		}
	}
	return(s);
}