%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include <cstdio>
#include <string>
#include<cmath>
#include "1405021.h"
#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count,errors;
int last_line;
vector<SymbolInfo*> declist;
int foundId=0;
string datafield="retval dw ?\n";
//string tempparams="";

string lastlabel="";
vector <string> varz;

int ScopeTable::id=0;
SymbolTable *table=new SymbolTable(32);
FILE *fp,*fp2,*fp3,*fp4,*fp5;
int labelCount=0;
int tempCount=0;
int temptillnow=0;
int tempmax=0;
int flag=0;

string nameMaker(string name,int desiredId){
	string ss="";
	char st[5];
	//itoa(desiredId,st,10);
	sprintf(st,"%d",desiredId);
	ss=name+st;
	if(name!=""){
	int mm=0;
	for(mm=0;mm<varz.size();mm++){
		if(varz[mm]==string(ss))
			break;
	}
	if(mm>=varz.size() && table->current->getId()==desiredId)
	varz.push_back(string(ss));
	}
	return ss;
}


char *newLabel()
{
	char *lb= new char[4];
	strcpy(lb,"L");
	char b[3];
	sprintf(b,"%d", labelCount);
	labelCount++;
	strcat(lb,b);
	//lastlabel=string(lb);
	return lb;
}

char *newTemp()
{
	char *t= new char[4];
	strcpy(t,"t");
	char b[3];
	sprintf(b,"%dt", tempCount);
	tempCount++;
	temptillnow++;
	strcat(t,b);
	if(tempCount>tempmax){
	tempmax=tempCount;
	datafield+=string(t)+" dw ?\n";
	}
	int mm;
	for(mm=0;mm<varz.size();mm++){
		if(varz[mm]==string(t))
			break;
	}
	if(mm>=varz.size())
	varz.push_back(string(t));
	//varz.push_back(string(t));
	return t;
}


void yyerror(char const *s)
{
	fprintf(fp2,"Error at Line %d: %s\n",line_count,s);
	fprintf(fp3,"Error at Line %d: %s\n",line_count,s);
	errors++;
}


%}

%error-verbose

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP INCOP RELOP ASSIGNOP LOGICOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ID STRING COMMENT PRINTLN DECOP

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program
	{
		//write your code in this block in all the similar blocks below
		//{fprintf(fp2,"Line %d: start : program\n",line_count);}
		{fprintf(fp2,"Total lines: %d\n",line_count-1);}
		{fprintf(fp2,"Total errors: %d\n",errors);}
		if(errors==0){
			fprintf(fp5,".model small\n");
			fprintf(fp5,".stack 100h\n");
			fprintf(fp5,".data\n");
			fprintf(fp5,"%s .code\n",datafield.c_str());
			string spfunc="OUTDEC PROC\n;INPUT AX\nPUSH AX\nPUSH BX\nPUSH CX\nPUSH DX\nOR AX,AX\nJGE @END_IF1\nPUSH AX\nMOV DL,'-'\nMOV AH,2\nINT 21H\nPOP AX\nNEG AX\n\n@END_IF1:\nXOR CX,CX\nMOV BX,10D\n\n@REPEAT1:\nXOR DX,DX\nDIV BX\nPUSH DX\nINC CX\nOR AX,AX\nJNE @REPEAT1\n\nMOV AH,2\n\n@PRINT_LOOP:\n\nPOP DX\nOR DL,30H\nINT 21H\nLOOP @PRINT_LOOP\n\nMOV AH,2\nMOV DL,0DH\nINT 21H\nMOV DL,0AH\nINT 21H\nPOP DX\nPOP CX\nPOP BX\nPOP AX\nRET\nOUTDEC ENDP\n  ";
			
			$1->code=spfunc+$1->code;
			$1->code+="end main\n";
			fprintf(fp5,"%s",$1->code.c_str());
			//cout<<$$->code<<"ss"<<endl;
			
		
		}
		
	}
	;

program : program unit
	{
		{fprintf(fp2,"Line %d: program : program unit\n",line_count);}
		$$=$1;
		$$->code+=$2->code;
	} 
	| 
	unit
	{
                {fprintf(fp2,"Line %d: program : unit\n",line_count);}
	}
	;
	
unit : var_declaration
	{
		{fprintf(fp2,"Line %d: unit : var_declaration\n",line_count);}
	}
     	| 
     	func_declaration
     	{
		{fprintf(fp2,"Line %d: unit : func_declaration\n",line_count);}
     	}
     	| 
     	func_definition
     	{
		{fprintf(fp2,"Line %d: unit : func_definition\n",line_count);}
     	}
     	;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
			{
				table->Exit_Scope();
				printf("blablabla");
				fprintf(fp2,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n%s\n",line_count,$2->getName().c_str());
				$4->setName($2->getName());
				$4->setType("Function");
				$4->setReturnType($1->getName());
				table->Insert($4);
				
				
				
			}
			
		 	;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN LCURL
			{
			
				if($2->getName()=="main"){
					flag=1;
				}
				varz.clear();
				char *label2=newLabel();
				lastlabel=string(label2);
				last_line=line_count;
				//tempparams="";
				for(int i=0;i<$4->paramnames.size();i++){
					SymbolInfo* look=table->Lookup($4->paramnames[i]);
					string varname=nameMaker($4->paramnames[i],foundId);
					int vall=14+2*($4->paramnames.size()-i);
					//tempparams+="mov ax, [bp+"+nameMaker("",vall)+"]\n";
					//tempparams+="mov "+varname+", ax\n";
					
				}
				/*table->PrintAllScope();
				table->Exit_Scope();
				fprintf(fp2,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n%s\n",line_count,$2->getName().c_str());*/
				
				for(int i=0;i<$4->paramnames.size();i++){
					if($4->paramnames[i]=="1TYPE"){
						fprintf(fp2,"Error at Line %d: Variable name omitted \n\n",last_line);
						fprintf(fp3,"Error at Line %d: Variable name omitted \n\n",last_line);
						errors++;
						break;
					}
				}
				//return type checking here
				$4->setName($2->getName());
				$4->setType("FUNCTION");        //FUNCTION indicates declaration complete
				$4->setReturnType($1->getName());
				SymbolInfo* temp=table->Lookup($4->getName());
				if(temp==NULL){
					//table->Insert($4);
					bool k=table->globalscope->Insert($4);
					//cout<<"\nsdfsdf"<<endl;
					//fprintf(fp2,"sfsdfsdf\n");
					}
				else if(temp->getType()=="FUNCTION"){
					fprintf(fp2,"Error at line %d: Function already declared in this scope\n\n",last_line);
					fprintf(fp3,"Error at line %d: Function already declared in this scope\n\n",last_line);
					errors++;
				
				}
				
				else if(temp->getType()=="Function"){
					if($4->paramtypes.size()!=temp->paramtypes.size()){
						fprintf(fp2,"Error at line %d: Number of parameters mismatch\n\n",last_line);
						fprintf(fp3,"Error at line %d: Number of parameters mismatch\n\n",last_line);
						errors++;
					}
					else{
						for(int z=0;z<temp->paramtypes.size();z++){
							if(temp->paramtypes[z]!=$4->paramtypes[z]){
								fprintf(fp2,"Error at line %d: Function type mismatch\n\n",last_line);
								fprintf(fp3,"Error at line %d: Function type mismatch\n\n",last_line);
								errors++;
							}
						}
						
						if(temp->getReturnType()!=$4->getReturnType()){
							fprintf(fp2,"Error at line %d: Return type mismatch\n\n",last_line);
							fprintf(fp3,"Error at line %d: Return type mismatch\n\n",last_line);
							errors++;
						}
							
						else{
							//cout<<"acbdc "<<line_count<<endl;
							temp->setType("FUNCTION");
								
						}
								
						
					}
				
				}
			}  nonterm RCURL {
				$$=$8;
				string sss="";
				sss=$2->getName()+" proc\n";
				if($2->getName()=="main"){
					sss+="mov ax, @data\n";
					sss+="mov ds, ax\n";
				}
				sss+="push bp\npush ax\npush bx\npush cx\npush dx\npush si\npush di\n";
				for(int k=0;k<varz.size();k++){
					sss+="push "+varz[k]+"\n";
				}
				sss+="mov bp,sp\n";
				for(int i=0;i<$4->paramnames.size();i++){
					SymbolInfo* look=table->Lookup($4->paramnames[i]);
					string varname=nameMaker($4->paramnames[i],foundId);
					int vall=14+2*(varz.size())+2*($4->paramnames.size()-i);
					sss+="mov ax, [bp+"+nameMaker("",vall)+"]\n";
					sss+="mov "+varname+", ax\n";
					
				}
				
				sss+=$8->code;
				//char *label2=newLabel();
				sss+=lastlabel+":\n";
	  //$$->code+=string(label1)+":\n";
	  			for(int k=varz.size()-1;k>=0;k--){
	  				sss+="pop "+varz[k]+"\n";
	  			}
	  			sss+="pop di\npop si\npop dx\npop cx\npop bx\npop ax\npop bp\n";
	  			if(flag==0){
	  			sss+="ret "+nameMaker("",($4->paramnames.size())*2)+"\n";
	  			}
	  			else{
	  			flag=0;
	  			}
	  			if($2->getName()=="main"){
	  				sss+="mov ah, 4ch\n";
	  				sss+="int 21h\n";
	  			}
	  			sss+=$2->getName()+" endp\n";
	  			$$->code=sss;
				table->PrintAllScope();
				table->Exit_Scope();
				fprintf(fp2,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n%s\n",line_count,$2->getName().c_str()); 
			
			}
			
 		 	;
 		 	
nonterm : statements  {fprintf(fp2,"Line %d: nonterm : statements \n",line_count);$$=$1;//cout<<$$->code<<endl;
}
	| {fprintf(fp2,"Line %d: nonterm : statements \n",line_count);}
 	;	
 		
 		 	
parameter_list : parameters  {
				fprintf(fp2,"Line %d: parameter_list  : parameters \n",line_count);
				$$=$1;
				
}
		|
		{
		fprintf(fp2,"Line %d: parameter_list  : \n",line_count);
		table->Enter_Scope();
		SymbolInfo* a=new SymbolInfo("func","Function");
		$$=a;
		}
		;

 		 
parameters  : parameters COMMA type_specifier ID  {
		fprintf(fp2,"Line %d: parameters  : parameters COMMA type_specifier ID\n%s\n",line_count,$4->getName().c_str());
		for(int k=0;k<$1->paramnames.size();k++){
			if($1->paramnames[k]==$4->getName()){
				fprintf(fp2,"Error at line %d: multiple declaration found\n\n",line_count);
				fprintf(fp3,"Error at line %d: multiple declaration found\n\n",line_count);
				errors++;
				break;
			}
		
			
		}
		$1->paramtypes.push_back($3->getName());
		$1->paramnames.push_back($4->getName());
		datafield+=nameMaker($4->getName(),table->current->getId())+" dw ?\n";
		table->Insert(new SymbolInfo($4->getName(),$3->getName()));
		$$=$1;
		

		}
		| parameters COMMA type_specifier	 {
		fprintf(fp2,"Line %d: parameters  : parameters COMMA type_specifier\n",line_count);
		$1->paramtypes.push_back($3->getName());
		$1->paramnames.push_back("1TYPE");
		table->Insert(new SymbolInfo("1TYPE",$3->getName()));
		$$=$1;
		}
 		| type_specifier ID {
 		last_line=line_count;
 		table->Enter_Scope();
 		fprintf(fp2,"Line %d: parameters  : type_specifier ID\n%s\n",line_count,$2->getName().c_str());
 		SymbolInfo* a=new SymbolInfo("func","FUNCTION");
 		a->paramtypes.push_back($1->getName());
 		a->paramnames.push_back($2->getName());
 		datafield+=nameMaker($2->getName(),table->current->getId())+" dw ?\n";
 		table->Insert(new SymbolInfo($2->getName(),$1->getName()));
 		$$=a;
 		
 		}
 		| type_specifier {
 		last_line=line_count;
 		table->Enter_Scope();
 		fprintf(fp2,"Line %d: parameters  : type_specifier\n",line_count);
 		SymbolInfo* a=new SymbolInfo("func","FUNCTION");
 		a->paramtypes.push_back($1->getName());
 		a->paramnames.push_back("1TYPE");
 		table->Insert(new SymbolInfo("1TYPE",$1->getName()));
 		$$=a;
 		}
 		;
 		
compound_statement : LCURL {table->Enter_Scope();} statements RCURL {fprintf(fp2,"Line %d: compound_statement : LCURL statements RCURL\n",line_count);
$$=$3;
table->PrintAllScope();
table->Exit_Scope();
}
 		    | LCURL RCURL {fprintf(fp2,"Line %d: compound_statement : LCURL RCURL\n",line_count);}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
		fprintf(fp2,"Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n",line_count);
		
		for(int ij=0;ij<declist.size();ij++){
			//cout<<declist[ij]->getName()<<" "<<declist[ij]->getType()<<endl;
			if(declist[ij]->getType()!="ARRAY" && declist[ij]->getType()!="array"){
				declist[ij]->setType($1->getName());
				datafield+=nameMaker(declist[ij]->getName(),table->current->getId())+" dw ?\n";
			
			}
			else{
				declist[ij]->setReturnType($1->getName());
				for(int g=0;g<declist[ij]->getParamNos();g++){
					declist[ij]->values[g]->setType($1->getName());
					//cout<<"line no :"<<line_count<<" "<<$1->getType()<<$1->getName()<<endl;
					//fprintf(fp2,"penpen %s %s ser\n\n",declist[ij]->values[g]->getType().c_str(),$1->getName().c_str());
					
				}
				datafield+=nameMaker(declist[ij]->getName(),table->current->getId())+" dw "+nameMaker("",declist[ij]->getParamNos())+" dup (?)\n";
			}
			table->Insert(declist[ij]);
		
		}
}
 		 ;
 		 
type_specifier	: INT {fprintf(fp2,"Line %d: type_specifier : INT\n",line_count);
			//cout<<line_count<<"   "<<$1->getName()<<$1->getType()<<endl;
			$$=$1;
			}
 		| FLOAT {fprintf(fp2,"Line %d: type_specifier : FLOAT\n",line_count);
 			$$=$1;	
 			}
 		| VOID {
 		fprintf(fp2,"Line %d: type_specifier : VOID\n",line_count);
 		$$=$1;
 		}
 		;
 		
declaration_list : declaration_list COMMA ID  {
			fprintf(fp2,"Line %d: declaration_list : declaration_list COMMA ID\n%s\n",line_count,$3->getName().c_str());
			declist.push_back(new SymbolInfo($3->getName(),$3->getType()));
			$$=$3;
			//fprintf(fp2,"Line %s %s: list SEMICOLON\n",$1->getName().c_str(),$1->getNext()->getName().c_str());
			
		}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
 		  	
 		  	$3->setType("ARRAY");
 		  	$3->setParamNos(atoi($5->getName().c_str()));
 		  	SymbolInfo* tmo=new SymbolInfo($3->getName(),$3->getType());
 		  	fprintf(fp2,"Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n%s\n%s\n",line_count,tmo->getName().c_str(),$5->getName().c_str());
 		  	tmo->setParamNos(atoi($5->getName().c_str()));
 		  	for(int z=0;z<tmo->getParamNos();z++){
 		  	tmo->values.push_back(new SymbolInfo("array","type"));
 		  }
 		  	//cout<<endl<<endl<<"sdfsdfsdfsdf"<<tmo->values.size()<<endl<<endl;
 		  	declist.push_back(tmo);
 		  	$$=$3;
 		  
 		  }
 		  | ID {
 		  declist.clear();
 		  fprintf(fp2,"Line %d: declaration_list : ID\n%s\n",line_count,$1->getName().c_str());
 		  declist.push_back(new SymbolInfo($1->getName(),$1->getType()));
 		  $$=$1;
 		  }
 		  | ID LTHIRD CONST_INT RTHIRD {
 		  declist.clear();
 		  
 		  $1->setType("ARRAY");
 		  $1->setParamNos(atoi($3->getName().c_str()));
 		  SymbolInfo* tmo=new SymbolInfo($1->getName(),$1->getType());
 		  fprintf(fp2,"Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n%s\n%s\n",line_count,tmo->getName().c_str(),$3->getName().c_str());
 		  tmo->setParamNos(atoi($3->getName().c_str()));
 		  for(int z=0;z<tmo->getParamNos();z++){
 		  	tmo->values.push_back(new SymbolInfo("array","type"));
 		  }
 		  declist.push_back(tmo);
 		  $$=$1;
 		  }
 		  ;
 		  
statements : statement {fprintf(fp2,"Line %d: statements : statement\n",line_count);
		
}
	   | statements statement {
	   fprintf(fp2,"Line %d: statements : statements statement\n",line_count);
	   $$=$1;
	   $$->code+=$2->code;
	  
	   }
	   | statements error {}
	   | error {}
	   
	   ;
	   
statement : var_declaration {
		fprintf(fp2,"Line %d: statement : var_declaration\n",line_count);
		$$=$1;
		tempCount-=temptillnow;
		temptillnow=0;
		}
	  | expression_statement {fprintf(fp2,"Line %d: statement :  expression_statement\n",line_count);$$=$1;
	  tempCount-=temptillnow;
	  temptillnow=0;
	  
	  }
	  | compound_statement  {fprintf(fp2,"Line %d: statement : compound_statement\n",line_count);$$=$1;
	  tempCount-=temptillnow;
	  temptillnow=0;
	  
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
	  fprintf(fp2,"Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",line_count);
	  $$=$3;
	  char *label1=newLabel();
	  char *label2=newLabel();
	  $$->code+=string(label1)+":\n";
	  $$->code+=$4->code;
	  $$->code+="cmp "+$4->getName()+", 0\n";
	  $$->code+="je "+string(label2)+"\n";
	  $$->code+=$7->code;
	  $$->code+=$5->code;
	  $$->code+="jmp "+string(label1)+"\n";
	  $$->code+=string(label2)+":\n";
	  tempCount-=temptillnow;
	  temptillnow=0;
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
	  fprintf(fp2,"Line %d: statement : IF LPAREN expression RPAREN statement\n",line_count);
	  $$=$3;
					
	  char *label=newLabel();
	$$->code+="mov ax, "+$3->getName()+"\n";
	$$->code+="cmp ax, 0\n";
	$$->code+="je "+string(label)+"\n";
	$$->code+=$5->code;
	$$->code+=string(label)+":\n";
	  tempCount-=temptillnow;
		temptillnow=0;
	  
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
	  fprintf(fp2,"Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n",line_count);
	  $$=$3;
					
	  char *label1=newLabel();
	  char *label2=newLabel();
	$$->code+="mov ax, "+$3->getName()+"\n";
	$$->code+="cmp ax, 0\n";
	$$->code+="je "+string(label1)+"\n";
	$$->code+=$5->code;
	$$->code+="jmp "+string(label2)+"\n";
	$$->code+=string(label1)+":\n";
	$$->code+=$7->code;
	$$->code+=string(label2)+":\n";	  
	  tempCount-=temptillnow;
		temptillnow=0;
	  }
	  | WHILE LPAREN expression RPAREN statement {
	  fprintf(fp2,"Line %d: statement : WHILE LPAREN expression RPAREN statement\n",line_count);
	  $$=$3;
	  char *label1=newLabel();
	  char *label2=newLabel();
	  cout<<label1<<endl;
	  string tmp=string(label1)+":\n";
	  tmp=tmp+$$->code;
	  $$->code=tmp;
	  cout<<$$->code<<$3->getName()<<endl<<$3->code<<endl;
	  $$->code+="cmp "+$3->getName()+", 0\n";
	  $$->code+="je "+string(label2)+"\n";
	  $$->code+=$5->code;
	  $$->code+="jmp "+string(label1)+"\n";
	  $$->code+=string(label2)+":\n";
	  tempCount-=temptillnow;
		temptillnow=0;
	  
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {fprintf(fp2,"Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n",line_count);
	  SymbolInfo* sym=table->Lookup($3->getName());
	  if(sym==NULL){
	  	fprintf(fp2,"Error at line %d: Given ID not found\n\n",line_count);
		fprintf(fp3,"Error at line %d: Given ID not found\n\n",line_count);
		errors++;
	  
	  }
	  else{	
	  $$->code+="mov ax, "+nameMaker($3->getName(),foundId)+"\n";
	  $$->code+="call outdec\n";
	  }
	  
	  }
	  | RETURN expression SEMICOLON {
	  fprintf(fp2,"Line %d: statement : RETURN expression SEMICOLON\n",line_count);
	  $$=$2;
	  $$->code+="mov ax, "+$2->getName()+"\n";
	  $$->code+="mov retval, ax\n";
	  $$->code+="jmp "+lastlabel+"\n";
	  tempCount-=temptillnow;
		temptillnow=0;
	  }
	  ;
	  
expression_statement 	: SEMICOLON {fprintf(fp2,"Line %d: expression_statement : SEMICOLON\n",line_count);$$=$1;
			$$->code = "";
}		
			| expression SEMICOLON  {fprintf(fp2,"Line %d: expression_statement : expression SEMICOLON\n",line_count);
			$$=$1;
			
			}
			;
	  
variable : ID {
		fprintf(fp2,"Line %d: variable : ID\n%s\n",line_count,$1->getName().c_str());
		SymbolInfo* sym=table->Lookup($1->getName());
		
		if(sym==NULL){
			fprintf(fp2,"Error at line %d: Undeclared variable: %s\n\n",line_count,$1->getName().c_str());
			fprintf(fp3,"Error at line %d: Undeclared variable: %s\n\n",line_count,$1->getName().c_str());
			errors++;
			$$=new SymbolInfo("Error","Error");
			}
		else if(sym->getType()=="ARRAY"){
			fprintf(fp2,"Error at line %d: No index found on array\n\n",line_count);
			fprintf(fp3,"Error at line %d: No index found on array\n\n",line_count);
			errors++;
			$$=new SymbolInfo("Error","Error");
			}
		else{
			$$=sym;
			//$$= new SymbolInfo($1);
			$$=new SymbolInfo(nameMaker(sym->getName(),foundId),sym->getType());
			$$->code="";
				//$$->setType("notarray");
			
		}
}		
	 | ID LTHIRD expression RTHIRD {fprintf(fp2,"Line %d: variable : ID LTHIRD expression RTHIRD\n%s\n",line_count,$1->getName().c_str());
	//cout<<$3->getValue()-0<<" "<<endl;
	   SymbolInfo* sym=table->Lookup($1->getName());
	   
	   if(sym==NULL){
	   	fprintf(fp2,"Error at line %d: Undeclared variable: %s\n\n",line_count,$1->getName().c_str());
	   	fprintf(fp3,"Error at line %d: Undeclared variable: %s\n\n",line_count,$1->getName().c_str());
	   	errors++;
		$$=new SymbolInfo("Error","Error");
	   }
	   else if(sym->getType()!="ARRAY" && sym->getType()!="array"){
	   	fprintf(fp2,"Error at line %d: Subscripted value not Array\n\n",line_count);
	   	fprintf(fp3,"Error at line %d: Subscripted value not Array\n\n",line_count);
	   	errors++;
	   	$$=new SymbolInfo("Error","Error");
	   }
	   else if($3->getType()!="INT"){
	   	fprintf(fp2,"Error at line %d: Array subscript is not an integer\n\n",line_count);	
	   	fprintf(fp3,"Error at line %d: Array subscript is not an integer\n\n",line_count);
	   	errors++;	
	 	$$=new SymbolInfo("Error","Error");
	 }
	 else if($3->getValue()>=sym->getParamNos() || $3->getValue()<0){
	 	fprintf(fp2,"Error at line %d %lf: Array index out of bound\n\n",line_count,$3->getValue());
	 	fprintf(fp3,"Error at line %d: Array index out of bound\n\n",line_count);
	 	errors++;	
	 	$$=new SymbolInfo("Error","Error");
	 }
	 else{
	 	//$$=new SymbolInfo("ARRAYVAL",sym->getReturnType());
	 	//cout<<$3->getValue()<<" "<<sym->getParamNos()<<endl;
	 	//$$->setvalue(sym->values[$3->getValue()]);
	 	$$=sym->values[$3->getValue()];
	 	$$->setName(nameMaker($1->getName(),foundId));
	 	$$->code=$3->code+"mov bx, " +$3->getName() +"\nadd bx, bx\n";
	 	//fprintf(fp2,"%d %lf \n\n",line_count,$3->getValue());
	 }
	 
}
	 ;
	 
 expression : logic_expression	{	
 	    fprintf(fp2,"Line %d: expression : logic_expression\n",line_count);
 	    $$=$1;			
            }
	   | variable ASSIGNOP logic_expression {fprintf(fp2,"Line %d: expression : variable ASSIGNOP logic_expression\n",line_count);
	   if($1->getType()=="VOID" || $3->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
     	   else if($1->getType()=="Error" || $3->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
     	   else{
     	   	if($1->getType()=="DOUBLE"){
     	   		$1->setvalue($3->getValue());
     	   		$$=$1;

			if($1->code.length()<2){ 
			$$->code=$3->code+$1->code;
			$$->code+="mov ax, "+$3->getName()+"\n";
			$$->code+= "mov "+$1->getName()+", ax\n";
			}
				
			else{
			$$->code=$3->code+$1->code;
			$$->code+="mov ax, "+$3->getName()+"\n";
			$$->code+= "mov  "+$1->getName()+"[bx], ax\n";
			}
     	   	}
     	   	
     	   	else if($1->getType()=="FLOAT"){
     	   		$1->setvalue($3->getValue());
     	   		$$=$1;
     	   		
			if($1->code.length()<2){ 
			$$->code=$3->code+$1->code;
			$$->code+="mov ax, "+$3->getName()+"\n";
			$$->code+= "mov "+$1->getName()+", ax\n";
			}
				
			else{
				$$->code=$3->code+$1->code;
			$$->code+="mov ax, "+$3->getName()+"\n";
				$$->code+= "mov  "+$1->getName()+"[bx], ax\n";
			}
     	   	}
     	   	
     	   	else{
     	   		if($1->getType()!=$3->getType()){
     	   			fprintf(fp2,"Error at line %d %s %s: Types mismatch\n\n",line_count,$1->getType().c_str(),$3->getType().c_str());
     	   			fprintf(fp3,"Error at line %d: Types mismatch\n\n",line_count);
     	   			errors++;
     	   			$$=new SymbolInfo("Error","Error");
     	   		}
     	   		else{
     	   			$1->setvalue($3->getValue());
     	   			$$=$1;
     	   			
			if($1->code.length()<2){ 
				$$->code=$3->code+$1->code;
			$$->code+="mov ax, "+$3->getName()+"\n";
				$$->code+= "mov "+$1->getName()+", ax\n";
			}
				
			else{
				$$->code=$3->code+$1->code;
				$$->code+="mov ax, "+$3->getName()+"\n";
				$$->code+= "mov  "+$1->getName()+"[bx], ax\n";
			}
     	   		}
     	   	
     	   	
     	   	}
     	   
     	   
     	   
     	   }
	   
	   table->PrintAllScope();
	   //cout<<$$->code;
	   }	
	   ;
			
logic_expression : rel_expression {
		fprintf(fp2,"Line %d: logic_expression : rel_expression\n",line_count);
		$$=$1;
		//cout<<$1->code;
		}	
		 | rel_expression LOGICOP rel_expression {
		 fprintf(fp2,"Line %d: logic_expression : rel_expression LOGICOP rel_expression\n",line_count);
		  if($1->getType()=="VOID" || $3->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
     		  else if($1->getType()=="Error" || $3->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
     		  else{
     		  	int a;
     		  	if($2->getName()=="&&")
     		  		a=($1->getValue()) && ($3->getValue());
     		  	else
     		  		a=($1->getValue()) || ($3->getValue());
     		  	$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	$$->code=$1->code;
					$$->code+=$3->code;
					
					if($2->getName()=="&&"){
						/* 
						Check whether both operands value is 1. If both are one set value of a temporary variable to 1
						otherwise 0
						*/
				$$->code=$1->code;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->getName()+"\n";
				$$->code+="cmp ax, 0\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				$$->code+="je "+string(label1)+"\n";
				$$->code+="mov ax, " + $3->getName()+"\n";
				$$->code+="cmp ax, 0\n";
				$$->code+="je "+string(label1)+"\n";
				$$->code+="mov ax, 1\n";
				$$->code+="mov "+string(temp) +", ax\n";
				$$->code+="jmp "+string(label2) +"\n";
				//$$->code+="mov ax" +", 0\n";
				$$->code+=string(label1)+":\nmov ax" +", 0\n"+"mov "+string(temp)+", ax\n";
				$$->code+=string(label2)+":\n";
				$$->setName(string(temp));
					}
					else if($2->getName()=="||"){
						$$->code=$1->code;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->getName()+"\n";
				$$->code+="cmp ax, 0\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				$$->code+="jne "+string(label1)+"\n";
				$$->code+="mov ax, " + $3->getName()+"\n";
				$$->code+="cmp ax, 0\n";
				$$->code+="jne "+string(label1)+"\n";
				$$->code+="mov ax, 0\n";
				$$->code+="mov "+string(temp) +", ax\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov ax" +", 1\n"+"mov "+string(temp)+", ax\n";
				$$->code+=string(label2)+":\n";
				$$->setName(string(temp));
					}
					//delete $3;
     		  }
		 
		 }	
		 ;
			
rel_expression	: simple_expression {fprintf(fp2,"Line %d: rel_expression : simple_expression\n",line_count);
     		$$=$1;

}
		| simple_expression RELOP simple_expression {fprintf(fp2,"Line %d: rel_expression : simple_expression RELOP simple_expression\n",line_count);
		string tc="";
		  if($1->getType()=="VOID" || $3->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
     		  else if($1->getType()=="Error" || $3->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
     		  else{
     		  	if($2->getName()=="<"){
     		  		int a=(($1->getValue())<($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  	
     		  	else if($2->getName()=="<="){
     		  		int a=(($1->getValue())<=($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  	
     		  	else if($2->getName()==">"){
     		  		int a=(($1->getValue())>($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  	
     		  	else if($2->getName()==">="){
     		  		int a=(($1->getValue())>=($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  	
     		  	else if($2->getName()=="!="){
     		  		int a=(($1->getValue())!=($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  	
     		  	else if($2->getName()=="=="){
     		  		int a=(($1->getValue())==($3->getValue()));
     		  		$$=new SymbolInfo($1->getName(),"INT",$1->getNext(),a);
     		  	}
     		  		$$->code=$1->code;
				$$->code+=$3->code;
				$$->code+="mov ax, " + $1->getName()+"\n";
				$$->code+="cmp ax, " + $3->getName()+"\n";
				char *temp=newTemp();
				char *label1=newLabel();
				char *label2=newLabel();
				if($2->getName()=="<"){
					$$->code+="jl " + string(label1)+"\n";
				}
				else if($2->getName()=="<="){
					$$->code+="jle " + string(label1)+"\n";
				}
				else if($2->getName()==">"){
					$$->code+="jg " + string(label1)+"\n";
				}
				else if($2->getName()==">="){
					$$->code+="jge " + string(label1)+"\n";
				}
				else if($2->getName()=="=="){
					$$->code+="je " + string(label1)+"\n";
				}
				else{
					$$->code+="jne " + string(label1)+"\n";
				}
				$$->code+="mov ax, 0\n";
				$$->code+="mov "+string(temp) +", ax\n";
				$$->code+="jmp "+string(label2) +"\n";
				$$->code+=string(label1)+":\nmov ax" +", 1\n"+"mov "+string(temp)+", ax\n";
				$$->code+=string(label2)+":\n";
				$$->setName(string(temp));
     		  
     		  
     		  }
		
		
		}	
		;
				
simple_expression : term {fprintf(fp2,"Line %d: simple_expression : term\n",line_count);$$=$1;}
		  | simple_expression ADDOP term {fprintf(fp2,"Line %d: simple_expression : simple_expression ADDOP term\n",line_count);
		  string tc="";
		  if($1->getType()=="VOID" || $3->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
     		else if($1->getType()=="Error" || $3->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
     		  else{
     		  	if($1->getType()=="DOUBLE" || $3->getType()=="DOUBLE")
     				tc="DOUBLE";
    			 else if($1->getType()=="FLOAT" || $3->getType()=="FLOAT")
     				tc="FLOAT";
      			 else
     				tc="INT";
     			if($2->getName()=="+"){
     		  		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())+($3->getValue()));
     		  		$$->code=$1->code;
     		  		$$->code+=$3->code;
     		  		$$->code+="mov ax, "+ $1->getName()+"\n";
     		  		$$->code+="add ax, "+ $3->getName()+"\n";
     		  		char *temp=newTemp();
     		  		$$->code+="mov "+string(temp)+", ax\n";
     		  		$$->setName(temp);
     		  		cout << endl << $$->code << endl;
     		  		}
     		  	else {
     		  		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())-($3->getValue()));
     		  		$$->code=$1->code;
     		  		$$->code+=$3->code;
     		  		$$->code+="mov ax, "+ $1->getName()+"\n";
     		  		$$->code+="sub ax, "+ $3->getName()+"\n";
     		  		char *temp=newTemp();
     		  		$$->code+="mov "+string(temp)+", ax\n";
     		  		$$->setName(temp);
     		  		cout << endl << $$->code << endl;
     		  	}
     		  }
		  }
		  ;
					
term :	unary_expression {fprintf(fp2,"Line %d: term : unary_expression\n",line_count);
}
     |  term MULOP unary_expression {fprintf(fp2,"Line %d: term : term MULOP unary_expression\n",line_count);
     string tc="";
     if($1->getType()=="VOID" || $3->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
     else if($1->getType()=="Error" || $3->getType()=="Error")
     $$=new SymbolInfo("Error","Error");
     else{
     if($1->getType()=="DOUBLE" || $3->getType()=="DOUBLE")
     		tc="DOUBLE";
     else if($1->getType()=="FLOAT" || $3->getType()=="FLOAT")
     		tc="FLOAT";
     else
     		tc="INT";
     if($2->getName()=="*"){
     	$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())*($3->getValue()));
     	//$$=$1;
     						$$->code=$1->code;
						$$->code += $3->code;
						$$->code += "mov ax, "+ $1->getName()+"\n";
						$$->code += "mov bx, "+ $3->getName() +"\n";
						char *temp=newTemp();
						if($2->getName()=="*"){
							$$->code += "imul bx\n";
							$$->code += "mov "+ string(temp) + ", ax\n";
						}
						$$->setName(temp);
						cout << endl << $$->code << endl;
     }
     else if($2->getName()=="/"){
     	if($3->getValue()==0){
     		fprintf(fp2,"Error at line %d: Zero Division: Floating point Exception\n\n",line_count);
     		fprintf(fp3,"Error at line %d: Zero Division: Floating point Exception\n\n",line_count);
     		errors++;
     		 $$=new SymbolInfo("Error","Error");
     	}
     	else{
     		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())/($3->getValue()));
     		$$->code=$1->code;
		$$->code += $3->code;
		$$->code+="xor dx, dx\n";
		$$->code += "mov ax, "+ $1->getName()+"\n";
		$$->code += "mov bx, "+ $3->getName() +"\n";
		char *temp=newTemp();
		if($2->getName()=="/"){
			$$->code += "idiv bx\n";
			$$->code += "mov "+ string(temp) + ", ax\n";
		}
		$$->setName(temp);
		cout << endl << $$->code << endl;     		
     	}
     }
     else{
     	if(tc!="INT"){
     		fprintf(fp2,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
     		fprintf(fp3,"Error at line %d: Non-Integer operand on modulus operator\n\n",line_count);
     		errors++;
     		$$=new SymbolInfo("Error","Error");
     	}
     	else if($3->getValue()==0){
     		fprintf(fp2,"Error at line %d: Zero Division: Floating point Exception\n\n",line_count);
     		fprintf(fp3,"Error at line %d: Zero Division: Floating point Exception\n\n",line_count);
     		errors++;
     		 $$=new SymbolInfo("Error","Error");
     	}
     	else{
     		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),(int)($1->getValue())%(int)($3->getValue()));
     		$$->code=$1->code;
		$$->code += $3->code;
		$$->code+="xor dx, dx\n";
		$$->code += "mov ax, "+ $1->getName()+"\n";
		$$->code += "mov bx, "+ $3->getName() +"\n";
		char *temp=newTemp();
		if($2->getName()=="%"){
			$$->code += "idiv bx\n";
			$$->code += "mov "+ string(temp) + ", dx\n";
		}
		$$->setName(temp);
		cout << endl << $$->code << endl;     		
     	}
     	
     
     }
     
     }
     
     }
     ;

unary_expression : ADDOP unary_expression  {
		fprintf(fp2,"Line %d: unary_expression : ADDOP unary_expression\n",line_count);
		if($2->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
		else if($2->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
		
		else if($1->getName()=="+"){
			//$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),($2->getValue()));
			$$=$2;
		}
		else{
		//$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),-($2->getValue()));
		char* temp=newTemp();
		$$=new SymbolInfo(string(temp),$2->getType());
		$$->code+=$2->code;
		$$->code+="mov ax, " + $2->getName() + "\n";
		$$->code+="neg ax\n";
		$$->code+="mov "+string(temp)+", ax\n";
		$$->setvalue(-($2->getValue()));
		//$$->code+="neg "+$2->getName()+"\n";
		}


}
		 | NOT unary_expression    {fprintf(fp2,"Line %d: unary_expression : NOT unary_expression\n",line_count);
		 if($2->getType()=="VOID"){
				fprintf(fp2,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				fprintf(fp3,"Error at line %d: 'VOID' can't be used in expressions\n\n",line_count);
				errors++;
     				$$=new SymbolInfo("Error","Error");
     				}
		else if($2->getType()=="Error")
     				$$=new SymbolInfo("Error","Error");
		 else if($2->getValue()==0){
		 	//$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),1);
		 	/*$$=$2;
			char *temp=newTemp();
			$$->code+="mov ax, " + $2->getName() + "\n";
			$$->code+="not ax\n";
			$$->code+="mov "+string(temp)+", ax";*/

			$$=$2;
			char *temp=newTemp();
			char *label1=newLabel();
			char *label2=newLabel();
			$$->code+="mov ax, " + $2->getName() + "\n";
			$$->code+="cmp ax, 0\n";
			$$->code+="je " + string(label1) + "\nmov " + string(temp) +", 0\njmp " + string(label2)+"\n";
			$$->code+=string(label1)+":\nmov "+string(temp) + ", 1\n" + string(label2) + ":\n";
			$$->setName(temp);
		 	}
		 else{
		 	//$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),0);
		 	$$=$2;
			char *temp=newTemp();
			char *label1=newLabel();
			char *label2=newLabel();
			$$->code+="mov ax, " + $2->getName() + "\n";
			$$->code+="cmp ax, 0\n";
			$$->code+="je " + string(label1) + "\nmov " + string(temp) +", 0\njmp " + string(label2)+"\n";
			$$->code+=string(label1)+":\nmov "+string(temp) + ", 1\n" + string(label2) + ":\n";
			$$->setName(temp);
		 }
		 
		 }
		 | factor {fprintf(fp2,"Line %d: unary_expression : factor\n",line_count);
		 $$=$1;
		 }
		 ;
	
factor	: variable {
		fprintf(fp2,"Line %d: factor : variable\n",line_count);
		$$=$1;	
		if($$->code.length()<2){
				
			}
			
		else{
				char *temp= newTemp();
				$$->code+="mov ax, " + $1->getName() + "[bx]\n";
				$$->code+= "mov " + string(temp) + ", ax\n";
				$$->setName(string(temp));
		}	
	}
	| ID LPAREN argument_list RPAREN {
	//cout<<"impossible";
	//cout<<"damndamn"<<$1->getName()<<" "<<errors;
	fprintf(fp2,"Line %d: factor : ID LPAREN argument_list RPAREN\n",line_count);
	SymbolInfo* sym=NULL;
	//cout<<"trap";
	//cout<<"skip";
	sym=table->Lookup($1->getName());
	//if(sym!=NULL){
	
	//}
	//Total Number of Arguments mismatch in funtion
	if(sym==NULL){
		fprintf(fp2,"Error at line %d: no reference found with id %s\n\n",line_count,$1->getName().c_str());
		fprintf(fp3,"Error at line %d: no reference found with id %s\n\n",line_count,$1->getName().c_str());
		errors++;
		$$=new SymbolInfo("Error","Error");
	}
	else if(sym->getType()=="Function"){
		fprintf(fp2,"Error at line %d: %s is not defined yet (Only declaration found)\n\n",line_count,sym->getName().c_str());
		fprintf(fp3,"Error at line %d: %s is not defined yet (Only declaration found)\n\n",line_count,sym->getName().c_str());
		errors++;
		$$=new SymbolInfo("Error","Error");
		}
	else if(sym->getType()!="FUNCTION"){
		fprintf(fp2,"Error at line %d: %s is not a function\n\n",line_count,sym->getName().c_str());
		fprintf(fp3,"Error at line %d: %s is not a function\n\n",line_count,sym->getName().c_str());
		errors++;
		$$=new SymbolInfo("Error","Error");
	}
	else{
		if(sym->paramtypes.size()!=$3->paramtypes.size()){
		fprintf(fp2,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getName().c_str());
		fprintf(fp3,"Error at line %d: Total number of arguments mismatch in function %s\n\n",line_count,$1->getName().c_str());
		errors++;
		$$=new SymbolInfo("Error","Error");
		}
		else{
			int h;
			for(h=0;h<sym->paramtypes.size();h++){
				if(sym->paramtypes[h]!=$3->paramtypes[h]){
					fprintf(fp2,"Error at line %d: (%d)th argument mismatch in function %s \n\n",line_count,h+1,$1->getName().c_str());
					fprintf(fp3,"Error at line %d: (%d)th argument mismatch in function %s \n\n",line_count,h+1,$1->getName().c_str());
					errors++;
					$$=new SymbolInfo("Error","Error");
					break;
				
				}
				}
			if(h>=sym->paramtypes.size()){
				$$=new SymbolInfo(sym->getName(),sym->getReturnType());
				$$->setvalue(sym->getValue());
				$$->code=$3->code;
				for(h=0;h<sym->paramnames.size();h++){
					$$->code+="push "+$3->paramnames[h]+"\n";
				
				}
				$$->code+="call "+sym->getName()+"\n";
				char *temp= newTemp();
				$$->code+="mov ax, retval\n";
				$$->code+="mov "+string(temp)+", ax\n";
				//$$->code+=tempparams;
				$$->setName(string(temp));			
				}
			
			
			
		}
	
	
	
	
	}
	}
	| LPAREN expression RPAREN {fprintf(fp2,"Line %d: factor : LPAREN expression RPAREN\n",line_count);
					$$=$2;
	}
	| CONST_INT  {
		fprintf(fp2,"Line %d: factor : CONST_INT\n%s\n",line_count,$1->getName().c_str());
		char *temp= newTemp();
		$$=new SymbolInfo(string(temp),$1->getType());
		$$->setvalue(atof($1->getName().c_str()));
		$$->code="";
		$$->code+="mov ax, "+$1->getName()+"\n";
		$$->code+="mov "+$$->getName()+", ax\n";
		
		      
	}
	| CONST_FLOAT {fprintf(fp2,"Line %d: factor : CONST_FLOAT\n%s\n",line_count,$1->getName().c_str());
		char *temp= newTemp();
		$$=new SymbolInfo(string(temp),$1->getType());
		$$->setvalue(atof($1->getName().c_str()));
		$$->code="";
		$$->code+="mov ax, "+$1->getName()+"\n";
		$$->code+="mov "+$$->getName()+", ax\n";
	
	}
	| CONST_CHAR {fprintf(fp2,"Line %d: factor : CONST_CHAR\n",line_count);}
	| variable INCOP {fprintf(fp2,"Line %d: factor : variable INCOP\n",line_count);
			$1->setvalue(($1->getValue()+1));
			$$=$1;
			if($$->code.length()<2){
				$$->code+="inc "+$1->getName()+"\n";
			}
			
		else{
				//char *temp= newTemp();
				//$$->code+="mov ax, " + $1->getName() + "[bx]\n";
				//$$->code+= "mov " + string(temp) + ", ax\n";
				$$->code+="inc "+$1->getName()+"[bx]\n";
		}	
	}
	| variable DECOP {fprintf(fp2,"Line %d: factor : variable DECOP\n",line_count);
			$1->setvalue(($1->getValue()-1));
			$$=$1;
			if($$->code.length()<2){
				$$->code+="dec "+$1->getName()+"\n";
			}
			
			else{
				//char *temp= newTemp();
				//$$->code+="mov ax, " + $1->getName() + "[bx]\n";
				//$$->code+= "mov " + string(temp) + ", ax\n";
				$$->code+="dec "+$1->getName()+"[bx]\n";
			}	
	}
	;
	
argument_list: arguments {fprintf(fp2,"Line %d: argument_list : arguments \n",line_count);cout<<"rdisdfl";}
		|	{$$=new SymbolInfo("function","FUNCTION");}
		;
	
	
arguments : arguments COMMA logic_expression {fprintf(fp2,"Line %d: arguments : arguments COMMA logic_expression\n",line_count);
			$1->paramtypes.push_back($3->getType());
			$1->paramnames.push_back($3->getName());
			$$=$1;
			$$->code+=$3->code;

}
	      | logic_expression {fprintf(fp2,"Line %d: argument_list : logic_expression\n",line_count);
	      		$$=new SymbolInfo($1->getName(),$1->getType());
	      		$$->paramtypes.push_back($1->getType());
	      		$$->paramnames.push_back($1->getName());
	      		$$->code+=$1->code;
	      }

	      ;
 

%%
int main(int argc,char *argv[])
{

	/*if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}*/
	if((fp=fopen("input.c","r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	/*fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");*/
	fp5=fopen("code.asm","w");
	fclose(fp5);
	fp2= fopen("log.txt","w");
	fclose(fp2);
	fp3= fopen("error.txt","w");
	fclose(fp3);
	fp4=fopen("symtab.txt","w");
	
	fp2= fopen("log.txt","a");
	fp3= fopen("error.txt","a");
	fp4= fopen("symtab.txt","a");
	fp5=fopen("code.asm","a");
	

	yyin=fp;
	yyparse();
	
	printf("%d",line_count);
	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
	fclose(fp5);
	printf("%d",line_count);
	return 0;
}

