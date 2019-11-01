%option noyywrap
%x COMSTART
%x COMMENTSTART
%x COMMENT2START
%x BSLASH
%x FINSTART

%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <cstring>
#include "1405021.h"
#define DEF_BUCKET 24

using namespace std;

int line_count=1,last=1,errors=0;

FILE* logout;
FILE* tokenout;
SymbolTable* st;
string str,str2;

%}

WHITESPACE [\t\f\r\v]+
LETTER [a-zA-Z]
DIGIT[0-9]
NEWLINE \n

%%

{NEWLINE} {line_count++;}
"if" {fprintf(tokenout,"<IF> ");
      fprintf(logout,"Line no %d: Token <IF> Lexeme %s found \n\n",line_count,yytext);
		}
"else" {fprintf(tokenout,"<ELSE> ");
	fprintf(logout,"Line no %d: Token <ELSE> Lexeme %s found \n\n",line_count,yytext);
}

"for" {fprintf(tokenout,"<FOR> ");
	fprintf(logout,"Line no %d: Token <FOR> Lexeme %s found \n\n",line_count,yytext);
}

"while" {fprintf(tokenout,"<WHILE> ");
	fprintf(logout,"Line no %d: Token <WHILE> Lexeme %s found \n\n",line_count,yytext);
}

"do" {fprintf(tokenout,"<DO> ");
	fprintf(logout,"Line no %d: Token <DO> Lexeme %s found \n\n",line_count,yytext);
}

"break" {fprintf(tokenout,"<BREAK> ");
	fprintf(logout,"Line no %d: Token <BREAK> Lexeme %s found \n\n",line_count,yytext);
}

"int" {fprintf(tokenout,"<INT> ");
	fprintf(logout,"Line no %d: Token <INT> Lexeme %s found \n\n",line_count,yytext);
}

"char" {fprintf(tokenout,"<CHAR> ");
	fprintf(logout,"Line no %d: Token <CHAR> Lexeme %s found \n\n",line_count,yytext);
}

"float" {fprintf(tokenout,"<FLOAT> ");
	fprintf(logout,"Line no %d: Token <FLOAT> Lexeme %s found \n\n",line_count,yytext);
}

"double" {fprintf(tokenout,"<DOUBLE> ");
	fprintf(logout,"Line no %d: Token <DOUBLE> Lexeme %s found \n\n",line_count,yytext);
}

"void" {fprintf(tokenout,"<VOID> ");
	fprintf(logout,"Line no %d: Token <VOID> Lexeme %s found \n\n",line_count,yytext);
}

"return" {fprintf(tokenout,"<RETURN> ");
	fprintf(logout,"Line no %d: Token <RETURN> Lexeme %s found \n",line_count,yytext);
}

"switch" {fprintf(tokenout,"<SWITCH> ");
	fprintf(logout,"Line no %d: Token <SWITCH> Lexeme %s found \n\n",line_count,yytext);
}

"case" {fprintf(tokenout,"<CASE> ");
	fprintf(logout,"Line no %d: Token <CASE> Lexeme %s found \n\n",line_count,yytext);
}

"default" {fprintf(tokenout,"<DEFAULT> ");
	fprintf(logout,"Line no %d: Token <DEFAULT> Lexeme %s found \n",line_count,yytext);
}

"continue" {fprintf(tokenout,"<CONTINUE> ");
	fprintf(logout,"Line no %d: Token <CONTINUE> Lexeme %s found \n\n",line_count,yytext);
}

{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
				st->Insert(yytext,"CONST_INT");
		}

{DIGIT}*"."{DIGIT}+("E"("+"|"-")?{DIGIT}+)?  {
				fprintf(tokenout,"<CONST_FLOAT,%s> ",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
				st->Insert(yytext,"CONST_FLOAT");
}

{DIGIT}*"."{DIGIT}*"."[^\t\f\r\v\n]*	{errors++;fprintf(logout,"Error at line %d: Too many decimal point %s\n\n",line_count,yytext);
}

{DIGIT}*("."{DIGIT}+)*("E"("+"|"-")?{DIGIT}+("."{DIGIT}*)+)+(a-zA-Z_)*	{errors++;fprintf(logout,"Error at line %d: Ill formed number  %s\n\n",line_count,yytext);
}

{DIGIT}*"."{DIGIT}*("E"("+"|"-")?{DIGIT}+)?[A-Za-z_]+	{errors++;fprintf(logout,"Error at line %d: Ill formed number  %s\n\n",line_count,yytext);
}

{DIGIT}+[A-Za-z_]+			{errors++;fprintf(logout,"Error at line %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
}

"\'"[^\\\'\n]"\'"    {fprintf(tokenout,"<CHAR_CONST,%c> ",yytext[1]);
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
		st->Insert(yytext,"CONST_CHAR");
}

"\'"[^\\\'][^\'\n]+"\'"	{errors++;fprintf(logout,"Error at line %d: Multi character constant error %s\n\n",line_count,yytext);
}	

"\'"[\\\']"\'"			{errors++;fprintf(logout,"Error at line %d: Unterminated character %s\n\n",line_count,yytext);
}
"\'"[^\\\'\n]?"\n"		{errors++;fprintf(logout,"Error at line %d: Unterminated character %s\n\n",line_count,yytext);line_count++;
}

"\'\'"	{errors++;fprintf(logout,"Error at line %d:  Empty character constant error %s\n\n",line_count,yytext);
}	

"\'\\"[nt\\\'afrbv0]"\'"  {
	switch(yytext[2]){
		case 'n':
		fprintf(tokenout,"<CHAR_CONST,\n> ");
break;
		case 't':
		fprintf(tokenout,"<CHAR_CONST,\t> ");
break;		case '\\':
		fprintf(tokenout,"<CHAR_CONST,\\> ");
break;		case '\'':
		fprintf(tokenout,"<CHAR_CONST,\'> ");
break;		case 'a':
		fprintf(tokenout,"<CHAR_CONST,\a> ");
break;		case 'f':
		fprintf(tokenout,"<CHAR_CONST,\f> ");
break;		case 'r':
		fprintf(tokenout,"<CHAR_CONST,\r> ");
break;		case 'b':
		fprintf(tokenout,"<CHAR_CONST,\b> ");
break;		case 'v':
		fprintf(tokenout,"<CHAR_CONST,\v> ");
break;		case '0':
		fprintf(tokenout,"<CHAR_CONST,\0> ");
break;
		}
		
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
		st->Insert(yytext,"CONST_CHAR");
}

[+-]   {fprintf(tokenout,"<ADDOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
}

[*/%]   {fprintf(tokenout,"<ADDOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
}

"++"     |
"--"    {fprintf(tokenout,"<INCOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
}

"<"   |
"<="  |
 ">"  |
 ">=" |
 "==" |
 "!="       {fprintf(tokenout,"<RELOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
}

"="		{fprintf(tokenout,"<ASSINOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
}

"&&"     |
"||"    {fprintf(tokenout,"<LOGICOP,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
}

"!"     {fprintf(tokenout,"<NOT,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <NOT> Lexeme %s found\n\n",line_count,yytext);
}

"("     {fprintf(tokenout,"<LPAREN,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n\n",line_count,yytext);
}

")"     {fprintf(tokenout,"<RPAREN,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n\n",line_count,yytext);
}

"{"     {fprintf(tokenout,"<LCURL,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
}

"}"     {fprintf(tokenout,"<RCURL,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
}

"["     {fprintf(tokenout,"<LTHIRD,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n\n",line_count,yytext);
}

"]"     {fprintf(tokenout,"<RTHIRD,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n\n",line_count,yytext);
}

","     {fprintf(tokenout,"<COMMA,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
}

";"     {fprintf(tokenout,"<SEMICOLON,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
}
        
[a-zA-Z_][a-zA-Z0-9_]*  {fprintf(tokenout,"<ID,%s> ",yytext);
		fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n\n",line_count,yytext);
		st->Insert(yytext,"ID");
}


"\""	{last=line_count;printf("blablalb\n");BEGIN COMSTART;str="";str2="";str2+=yytext;printf("<1<%s R1 %s\n>1>",str.c_str(),str2.c_str());}
<COMSTART>[^\\\"\n]*"\""	{//printf("ASDFSADF\n");
str2+=yytext;
str=str+yytext;
str.resize(str.size()-1);
fprintf(tokenout,"<STRING,\"%s\"> ",str.c_str());
fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s found\n",last,str2.c_str());
BEGIN INITIAL;
printf("%s R3 %s\n",str.c_str(),str2.c_str());}

<COMSTART>[^\\\"\n]*"\n"   {printf("trigger %s",yytext);errors++;
str2+=yytext;
fprintf(logout,"Error at line %d: Unterminated String %s\n\n",last,str2.c_str());
BEGIN INITIAL;
line_count++;
}

<COMSTART>[^\\\"\n]*"\\"	{str2=str2+yytext;str=str+yytext;str.resize(str.size()-1);BEGIN BSLASH;}
<COMSTART>[^\\\"]*"\\\n"	{str2=str2+yytext;str=str+yytext;str.resize(str.size()-2);line_count++;}
<BSLASH>[$nt\\\'afrbv0\"]	{
	//printf("tiktak\n");
	if(yytext[0]!='$' && yytext[0]!='\n')
	str2+=yytext;
	switch(yytext[0]){
		case '$':
		BEGIN COMSTART;
		break;
		case 'n':
		BEGIN COMSTART;
		str=str+"\n";
break;		case '"':
		BEGIN COMSTART;
		str=str+"\"";
break;
		case 't':
		BEGIN COMSTART;
		str=str+"\t";
break;		case '\\':
		BEGIN COMSTART;
		str=str+"\\";
break;		case '\'':
		BEGIN COMSTART;
		str=str+"\'";
break;		case 'a':
		BEGIN COMSTART;
		str=str+"\a";
break;		case 'f':
		BEGIN COMSTART;
		str=str+"\f";
break;		case 'r':
		BEGIN COMSTART;
		str=str+"\r";
break;		case 'b':
		BEGIN COMSTART;
		str=str+"\b";
break;		case 'v':
		BEGIN COMSTART;
		str=str+"\v";
break;		case '0':
		BEGIN COMSTART;
		str=str+"\0";
break;
		}
printf("<4<%s R4 %s\n>4>",str.c_str(),str2.c_str());
}
"//"		{last=line_count;str2="";BEGIN COMMENTSTART;str2+="//";}
"/*"		{last=line_count;str2="";str2+="/*";BEGIN COMMENT2START;}
<COMMENT2START>[^*\n]*"*"	{str2+=yytext;
BEGIN FINSTART;}
<COMMENT2START>[^*\n]*"\n"	{str2+=yytext;
line_count++;
}
<FINSTART>"*"   {str2+="*";}
<FINSTART>[^*/]	{str2+=yytext;  BEGIN COMMENT2START;}
<FINSTART>[/]	{str2+="/";
fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n",last,str2.c_str());
BEGIN INITIAL;
}
<FINSTART><<EOF>>    {errors++;fprintf(logout,"Error at line %d: Unterminated comment %s\n\n",last,str2.c_str());}

<COMMENT2START><<EOF>>    {errors++;fprintf(logout,"Error at line %d: Unterminated comment %s\n\n",last,str2.c_str());BEGIN INITIAL;}

<COMMENTSTART>[^\\\n]*"\n"	{str2+=yytext;
str2.resize(str2.size()-1);
fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",last,str2.c_str());
BEGIN INITIAL;
line_count++;
}

<COMMENTSTART>[^\\\n]*"\\\n"	{str2+=yytext;line_count++;
}


.	       printf( "Unrecognized character: %s\n\n", yytext );
<COMSTART>.	       printf( "Unrecognized character cs: %s\n\n", yytext );

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	st=new SymbolTable(DEF_BUCKET);
	logout= fopen("log.txt","w");
	logoutt=logout;
	tokenout= fopen("token.txt","w");
	yyin= fin;
	yylex();
	st->PrintAllScope();
	fprintf(logout,"Total Lines: %d\n",line_count-1);
	fprintf(logout,"Total Errors: %d\n\n",errors);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}


