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

int ScopeTable::id=0;
SymbolTable *table=new SymbolTable(32);
FILE *fp,*fp2,*fp3,*fp4;


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
		
	}
	;

program : program unit
	{
		{fprintf(fp2,"Line %d: program : program unit\n",line_count);}
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
					cout<<"\nsdfsdf"<<endl;
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
							cout<<"acbdc "<<line_count<<endl;
							temp->setType("FUNCTION");
								
						}
								
						
					}
				
				}
			}  nonterm RCURL {
				table->PrintAllScope();
				table->Exit_Scope();
				fprintf(fp2,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n%s\n",line_count,$2->getName().c_str()); 
			
			}
			
 		 	;
 		 	
nonterm : statements  {fprintf(fp2,"Line %d: nonterm : statements \n",line_count);}
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
table->PrintAllScope();
table->Exit_Scope();
}
 		    | LCURL RCURL {fprintf(fp2,"Line %d: compound_statement : LCURL RCURL\n",line_count);}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
		fprintf(fp2,"Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n",line_count);
		
		for(int ij=0;ij<declist.size();ij++){
			cout<<declist[ij]->getName()<<" "<<declist[ij]->getType()<<endl;
			if(declist[ij]->getType()!="ARRAY" && declist[ij]->getType()!="array"){
				declist[ij]->setType($1->getName());
			
			}
			else{
				declist[ij]->setReturnType($1->getName());
				for(int g=0;g<declist[ij]->getParamNos();g++){
					declist[ij]->values[g]->setType($1->getName());
					//cout<<"line no :"<<line_count<<" "<<$1->getType()<<$1->getName()<<endl;
					//fprintf(fp2,"penpen %s %s ser\n\n",declist[ij]->values[g]->getType().c_str(),$1->getName().c_str());
				}
			}
			table->Insert(declist[ij]);
		
		}
}
 		 ;
 		 
type_specifier	: INT {fprintf(fp2,"Line %d: type_specifier : INT\n",line_count);
			cout<<line_count<<"   "<<$1->getName()<<$1->getType()<<endl;
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
 		  	cout<<endl<<endl<<"sdfsdfsdfsdf"<<tmo->values.size()<<endl<<endl;
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
 		  
statements : statement {fprintf(fp2,"Line %d: statements : statement\n",line_count);}
	   | statements statement {fprintf(fp2,"Line %d: statements : statements statement\n",line_count);}
	   | statements error {}
	   | error {}
	   
	   ;
	   
statement : var_declaration {
		fprintf(fp2,"Line %d: statement : var_declaration\n",line_count);
		
		}
	  | expression_statement {fprintf(fp2,"Line %d: statement :  expression_statement\n",line_count);}
	  | compound_statement  {fprintf(fp2,"Line %d: statement : compound_statement\n",line_count);}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {fprintf(fp2,"Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n",line_count);}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {fprintf(fp2,"Line %d: statement : IF LPAREN expression RPAREN statement\n",line_count);}
	  | IF LPAREN expression RPAREN statement ELSE statement {fprintf(fp2,"Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n",line_count);}
	  | WHILE LPAREN expression RPAREN statement {fprintf(fp2,"Line %d: statement : WHILE LPAREN expression RPAREN statement\n",line_count);}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {fprintf(fp2,"Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n",line_count);}
	  | RETURN expression SEMICOLON {fprintf(fp2,"Line %d: statement : RETURN expression SEMICOLON\n",line_count);}
	  ;
	  
expression_statement 	: SEMICOLON {fprintf(fp2,"Line %d: expression_statement : SEMICOLON\n",line_count);}		
			| expression SEMICOLON  {fprintf(fp2,"Line %d: expression_statement : expression SEMICOLON\n",line_count);}
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
		else
			$$=sym;
}		
	 | ID LTHIRD expression RTHIRD {fprintf(fp2,"Line %d: variable : ID LTHIRD expression RTHIRD\n%s\n",line_count,$1->getName().c_str());
	 cout<<$3->getValue()-0<<" "<<endl;
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
	 	fprintf(fp2,"Error at line %d: Array index out of bound\n\n",line_count);
	 	fprintf(fp3,"Error at line %d: Array index out of bound\n\n",line_count);
	 	errors++;	
	 	$$=new SymbolInfo("Error","Error");
	 }
	 else{
	 	//$$=new SymbolInfo("ARRAYVAL",sym->getReturnType());
	 	cout<<$3->getValue()<<" "<<sym->getParamNos()<<endl;
	 	//$$->setvalue(sym->values[$3->getValue()]);
	 	$$=sym->values[$3->getValue()];
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
     	   	}
     	   	
     	   	else if($1->getType()=="FLOAT"){
     	   		$1->setvalue($3->getValue());
     	   		$$=$1;
     	   	
     	   	}
     	   	
     	   	else{
     	   		if($1->getType()!=$3->getType()){
     	   			fprintf(fp2,"Error at line %d %s %s: Types mismatch\n\n",line_count,$1->getType().c_str(),$3->getType().c_str());errors++;
     	   			fprintf(fp3,"Error at line %d: Types mismatch\n\n",line_count);
     	   			errors++;
     	   			$$=new SymbolInfo("Error","Error");
     	   		}
     	   		else{
     	   			$1->setvalue($3->getValue());
     	   			$$=$1;
     	   		}
     	   	
     	   	
     	   	}
     	   
     	   
     	   
     	   }
	   
	   table->PrintAllScope();
	   
	   }	
	   ;
			
logic_expression : rel_expression {
		fprintf(fp2,"Line %d: logic_expression : rel_expression\n",line_count);
		$$=$1;
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
     		  
     		  
     		  }
		
		
		}	
		;
				
simple_expression : term {fprintf(fp2,"Line %d: simple_expression : term\n",line_count);}
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
     			if($2->getName()=="+")
     		  		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())+($3->getValue()));
     		  	else    
     		  		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),($1->getValue())-($3->getValue()));
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
     		$$=new SymbolInfo($1->getName(),tc,$1->getNext(),((int)$1->getValue())%(int)($3->getValue()));
     	
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
			$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),($2->getValue()));
		}
		else{
		$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),-($2->getValue()));
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
		 else if($2->getValue()==0)
		 	$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),1);
		 else
		 	$$=new SymbolInfo($2->getName(),$2->getType(),$2->getNext(),0);
		 
		 }
		 | factor {fprintf(fp2,"Line %d: unary_expression : factor\n",line_count);
		 $$=$1;
		 }
		 ;
	
factor	: variable {
		fprintf(fp2,"Line %d: factor : variable\n",line_count);
		$$=$1;		
		}
	| ID LPAREN argument_list RPAREN {
	cout<<"impossible";
	cout<<"damndamn"<<$1->getName()<<" "<<errors;
	fprintf(fp2,"Line %d: factor : ID LPAREN argument_list RPAREN\n",line_count);
	SymbolInfo* sym=NULL;
	cout<<"trap";
	cout<<"skip";
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
			}
			
			
			
		}
	
	
	
	
	}
	}
	| LPAREN expression RPAREN {fprintf(fp2,"Line %d: factor : LPAREN expression RPAREN\n",line_count);
					$$=$2;
	}
	| CONST_INT  {fprintf(fp2,"Line %d: factor : CONST_INT\n%s\n",line_count,$1->getName().c_str());}
	| CONST_FLOAT {fprintf(fp2,"Line %d: factor : CONST_FLOAT\n%s\n",line_count,$1->getName().c_str());}
	| CONST_CHAR {fprintf(fp2,"Line %d: factor : CONST_CHAR\n",line_count);}
	| variable INCOP {fprintf(fp2,"Line %d: factor : variable INCOP\n",line_count);
			$1->setvalue(($1->getValue()+1));
			$$=$1;
	}
	| variable DECOP {fprintf(fp2,"Line %d: factor : variable DECOP\n",line_count);
			$1->setvalue(($1->getValue()-1));
			$$=$1;
	}
	;
	
argument_list: arguments {fprintf(fp2,"Line %d: argument_list : arguments \n",line_count);cout<<"rdisdfl";}
		|	{$$=new SymbolInfo("function","FUNCTION");cout<<"rikck";}
		;
	
	
arguments : arguments COMMA logic_expression {fprintf(fp2,"Line %d: arguments : arguments COMMA logic_expression\n",line_count);
			$1->paramtypes.push_back($3->getType());
			$1->paramnames.push_back($3->getName());
			$$=$1;

}
	      | logic_expression {fprintf(fp2,"Line %d: argument_list : logic_expression\n",line_count);
	      		$$=new SymbolInfo($1->getName(),$1->getType());
	      		$$->paramtypes.push_back($1->getType());
	      		$$->paramnames.push_back($1->getName());
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

	fp2= fopen("log.txt","w");
	fclose(fp2);
	fp3= fopen("error.txt","w");
	fclose(fp3);
	fp4=fopen("symtab.txt","w");
	
	fp2= fopen("log.txt","a");
	fp3= fopen("error.txt","a");
	fp4= fopen("symtab.txt","a");
	

	yyin=fp;
	yyparse();
	
	printf("%d",line_count);
	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
	printf("%d",line_count);
	return 0;
}

