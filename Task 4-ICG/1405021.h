#include <iostream>
#include <cstdlib>
//#include <conio.h>
#include <string>
#include <cstring>
#include <fstream>
#include <vector>
#include <string>

using namespace std;

//ifstream in("input.txt");

extern FILE* fp2;
extern FILE* fp3;
extern FILE* fp4;
extern int errors;
extern int line_count;
extern int foundId;
//ofstream out("output.txt");

class SymbolInfo{
	string Name;
	string Type;
	SymbolInfo* next;
	int parameternos;
	string returnType;
	string* parameterlist;
	double value;

public:
	string code;
	vector<string> paramtypes;
	vector<string> paramnames;
	vector<SymbolInfo*> values;
	string getName(){
		return Name;
	}

	void setName(string i1){
		Name = i1;
	}

	string getType(){
		return Type;
	}

	void setType(string i2){
		Type = i2;
	}

	SymbolInfo* getNext(){
		return next;
	}

	void setNext(SymbolInfo* N){
		next=N;
	}

	int getParamNos(){
	return parameternos;
	}
	void setParamNos(int no){parameternos=no;}

	string getReturnType(){
		return returnType;	
	}

	void setReturnType(string typ){
		returnType=typ;
	}

	string* getParamList(){
		return parameterlist;
}

	void setParamList(string* param){
		//not yet declared
}

	double getValue(){
		return value;
}

	void setvalue(double val){\
	     value= val;
}

	SymbolInfo(string N, string T,SymbolInfo* Ne,double val=-1,int nos=0,string type=""){
		Name = N;
		Type = T;
		next = Ne;
		value= val;
		parameternos=nos;
		returnType=type;
		parameterlist=new string[parameternos];
		code="";
		

	}

	SymbolInfo(string N, string T,double val=-1,int nos=0,string type=""){
		Name = N;
		Type = T;
		next = NULL;
		value = val;
		parameternos=nos;
		returnType=type;
		parameterlist=new string[parameternos];
		code="";
		
	}
	
	~SymbolInfo(){
		//cout<<Name<<" destroy "<<Type<<" "<<endl;
		for(int i=0;i<values.size();i++){
			delete values[i];
		}
	}

};

class ScopeTable{
	/*
	array of symbolinfo pointer is Symbucket
	*/
	SymbolInfo** SymBucket; //Symbucket is the hashtable
	ScopeTable* parentScope;
	int scopeId;
	int size;

public:
	static int id;
	int getSize(){
	    return size;
	}

	int getId(){
		return scopeId;
	}

	ScopeTable* getparentScope(){
		return parentScope;
	}

	int setSize(int s){
		size = s;
	}

	ScopeTable(int siz,ScopeTable* t=NULL){
		//size of bucket actually
		id++;
		scopeId=id;
		size = siz;
		SymBucket=new SymbolInfo*[size];
		for(int i=0;i<size ;i++){
			SymBucket[i]=new SymbolInfo("&%$","NULL");//created a head pointer
		}
		parentScope=t;
	}

	int hash(string str,int siz=-1){
		if(siz=-1)
			siz = size;
		int len=str.length()+4;
		int total=173;
		char *acc=new char[str.length()+1];
		strcpy(acc,str.c_str()); // from Herbert Schildt
		for(int i=0;i<len;i++){
			total+=acc[((i)%str.length())]*(size+i+i);
			total+=i;
			total+=size;
			total=abs(total);
		}
		return total%size;
	}

	SymbolInfo* Lookup(string target){
		ScopeTable* curr=this;
		//while(curr!=NULL){
			int hashvalue= hash(target,this->getSize());
			SymbolInfo* a=SymBucket[hashvalue];
			int track=-1;
			while(a){
				string temp = a->getName();
				if(temp == target){
					cout<<endl<<" Found in ScopeTable# "<<id <<" at position "<<hashvalue<<","<<track<<endl;
					//out<<endl<<" Found in ScopeTable# "<<id <<" at position "<<hashvalue<<","<<track<<endl;
					//cout<<a->values.size()<<endl;
					foundId=scopeId;
					return a;
				}
				a = a->getNext();
				track++;
			}
			//curr = curr->parentScope;
		//}
		foundId=-1;
		return NULL;
	}

	void Print(){
		//cout<<endl<<" ScopeTable # "<<scopeId<<endl;
		//out<<endl<<" ScopeTable # "<<scopeId<<endl;
		fprintf(fp2," ScopeTable # %d\n",scopeId);
		fprintf(fp4," ScopeTable # %d\n",scopeId);
		for(int hash=0;hash<size;hash++){

			SymbolInfo *a=SymBucket[hash];
			if(a->getNext()){
			//cout<<" "<<hash<<" --> ";
			//out<<" "<<hash<<" --> ";
			fprintf(fp2," %d --> ",hash);
			fprintf(fp4," %d --> ",hash);
			while(a->getNext()){
				//cout<<" < "<<a->getNext()->getName()<<" : "<<a->getNext()->getType()<<"> ";
				//out<<" < "<<a->getNext()->getName()<<" : "<<a->getNext()->getType()<<"> ";
				if(a->getNext()->getType()=="ARRAY"){
				fprintf(fp2," < %s , IDs , { ",a->getNext()->getName().c_str());
				fprintf(fp4," < %s , IDs , { ",a->getNext()->getName().c_str());
				for(int p=0;p<a->getNext()->values.size();p++){
					fprintf(fp2,"%lf, ",a->getNext()->values[p]->getValue());
					fprintf(fp4,"%lf, ",a->getNext()->values[p]->getValue());
				}
				fprintf(fp2,"}> ",'\b','\b');
				fprintf(fp4,"}> ",'\b','\b');				
				}
				else if(a->getNext()->getType()!="Function" && a->getNext()->getType()!="FUNCTION"){
				fprintf(fp2," < %s , %s , %lf > ",a->getNext()->getName().c_str(),"ID",a->getNext()->getValue());
				fprintf(fp4," < %s , %s , %lf > ",a->getNext()->getName().c_str(),"ID",a->getNext()->getValue());
				}
				else{
				fprintf(fp2," < %s , %s > ",a->getNext()->getName().c_str(),"ID");
				fprintf(fp4," < %s , %s > ",a->getNext()->getName().c_str(),"ID");
				}
				a=a->getNext();
			}
			//cout<<endl;
			//out<<endl;
			fprintf(fp2,"\n");
			fprintf(fp4,"\n");
			}

		}

	}

	bool Insert(string nam,string typ){
		int hashvalue= hash(nam,this->getSize());
			SymbolInfo* a=SymBucket[hashvalue];
			int track=0;
			while(a){
				string temp = a->getName();
				if(temp == nam && a->getType()!="NULL"){
					cout<<endl<<" <"<<nam<<","<<typ<<"> "<<"already exists in current ScopeTable"<<endl;
					//out<<endl<<" <"<<nam<<","<<typ<<"> "<<"already exists in current ScopeTable"<<endl;
					return false;
				}
				if(a->getNext()!=NULL)
					a = a->getNext();
				else{
					a->setNext(new SymbolInfo(nam,typ));
					cout<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					//out<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					//Print();
					return true;
				}
				track++;
			}
			
		
	}

	bool Insert(SymbolInfo* si){
		int hashvalue= hash(si->getName(),this->getSize());
			SymbolInfo* a=SymBucket[hashvalue];
			int track=0;
			while(a){
				string temp = a->getName();
				if(temp == si->getName() && a->getType()!="NULL" && temp!="1TYPE"){
					cout<<endl<<" <"<<temp<<","<<a->getType()<<"> "<<"already exists in current ScopeTable"<<endl;
					fprintf(fp2,"Error at line %d: ID (%s) already exists in current scope\n\n",line_count,si->getName().c_str());
					fprintf(fp3,"Error at line %d: ID (%s) already exists in current scope\n\n",line_count,si->getName().c_str());
					errors++;
					//out<<endl<<" <"<<nam<<","<<typ<<"> "<<"already exists in current ScopeTable"<<endl;
					return false;
				}
				if(a->getNext()!=NULL)
					a = a->getNext();
				else{
					SymbolInfo* abc=new SymbolInfo(si->getName(),si->getType());
					abc->setNext(si->getNext());
					abc->setParamNos(si->getParamNos());
					abc->setReturnType(si->getReturnType());
					abc->setvalue(si->getValue());
					//cout<<si->values.size()<<endl;
					for(int m=0;m< si-> paramtypes.size();m++){
						abc->paramtypes.push_back(si->paramtypes[m]);
									
					}
					
					for(int m=0;m< si-> paramnames.size();m++){
						abc->paramnames.push_back(si->paramnames[m]);
									
					}
					
					for(int m=0;m< si-> values.size();m++){
						//abc->values.push_back(si->values[m]);
						abc->values.push_back(new SymbolInfo(si->values[m]->getName(),si->values[m]->getType(),si->values[m]->getNext(),si->values[m]->getValue()));
					
					}
					cout<<abc->values.size()<<" sf 0"<<endl;
					//fprintf(fp2,"%d\n\n\nsizer",abc->values.size());
					a->setNext(abc);
					cout<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					//out<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					//Print();
					return true;
				}
				track++;
			}
			
		
	}
	bool Remove(string nam){
		int hashvalue= hash(nam,this->getSize());
			SymbolInfo* a=SymBucket[hashvalue];
			int track = 0;
			while(a->getNext()){
				string temp = a->getNext()->getName();
				if(temp == nam){
					SymbolInfo* tempp = a->getNext();
					a->setNext(a->getNext()->getNext());
					delete tempp;
					cout<<endl<<"Deleted entry at "<<hashvalue<<","<<track<<" from current ScopeTable"<<endl;
					//out<<endl<<"Deleted entry at "<<hashvalue<<","<<track<<" from current ScopeTable"<<endl;
					return true;
				}
				a=a->getNext();
				track++;
	}
			cout<<endl<<nam <<" not found"<<endl;
			//out<<endl<<nam <<" not found"<<endl;
			return false;
	}



	~ScopeTable(){
		for(int hash=0;hash<size;hash++){
			SymbolInfo *a=SymBucket[hash];
			while(a->getNext()){
				SymbolInfo* tmp=a;
				a=a->getNext();
				delete tmp;
			}
			delete a;
			//cout<<endl;

		}

		delete SymBucket;
	}

};

class SymbolTable{
	
	int size;
	
public:
	ScopeTable* current;
	ScopeTable* globalscope;
	SymbolTable(int siz){
		size = siz;
		current=new ScopeTable(size);
		globalscope=current;
	}

	~SymbolTable(){
        while(current!=NULL){
            ScopeTable* temp = current;
            current=current->getparentScope();
            delete temp;
        }
    //delete this;
	}

	void Enter_Scope(){
		current=new ScopeTable(size,current);
		cout<<endl<<" New ScopeTable with id "<< current->getId() <<" created"<<endl;
		//out<<endl<<" New ScopeTable with id "<< current->getId() <<" created"<<endl;

	}

	void Exit_Scope(){
		int idd=current->getId();
		ScopeTable* temp = current;
		current=current->getparentScope();
		delete temp;
		cout<<endl<<" ScopeTable with id "<< idd<<" removed"<<endl;
		//out<<endl<<" ScopeTable with id "<< idd<<" removed"<<endl;
		//ScopeTable::id--;
	}

	bool Insert(string nam,string typ){
		return current->Insert(nam,typ);
	}
	
	bool Insert(SymbolInfo* symin){
		//cout<<endl<<symin->getName();
		return current->Insert(symin);
	}

	bool Remove(string nam){
		 return current->Remove(nam);
	}

	SymbolInfo* Lookup(string nam){
		//return NULL;
		//cout<<nam<<endl<<"ookla";
		ScopeTable* now=current;
		SymbolInfo* temp=NULL;
		while(now)
		{
		temp= now->Lookup(nam);
		
		if(temp!=NULL){
			//cout<<temp->values.size()<<endl;
			return temp;
		}
		now = now->getparentScope();
		}
		cout<<endl<<" Not found1111"<<endl;
		temp=NULL;
		//out<<endl<<" Not found"<<endl;
		return NULL;
	}

	void PrintCurrentScope(){
		current->Print();
	}

	void PrintAllScope(){
		fprintf(fp4,"\nLine no %d: \n\n",line_count);
		ScopeTable* now=current;
		while(now){
			now->Print();
			now=now->getparentScope();
		}

	}

};



/*int main(){
	int abc;
	in>>abc;
	SymbolTable* st=new SymbolTable(abc);
	char com;
	string str1,str2;
	while(!in.eof()){
		in>>com;
		if(in.eof())
			break;
		if(com=='I'){
			in>>str1>>str2;
			//out<<endl<<"I "<<str1<<" "<<str2<<endl;
			cout<<endl<<"I "<<str1<<" "<<str2<<endl;
			st->Insert(str1,str2);
		}

		else if(com== 'L'){
			in>>str1;
			out<<endl<<"L "<<str1<<endl;
			cout<<endl<<"L "<<str1<<endl;
			SymbolInfo* tmp=st->Lookup(str1);
		}

		else if(com=='P'){
			in>>com;
			if(com=='A'){
				out<<endl<<"P A"<<endl;
				cout<<endl<<"P A"<<endl;
				st->PrintAllScope();
			}
			else{
				out<<endl<<"P C"<<endl;
				cout<<endl<<"P C"<<endl;
				st->PrintCurrentScope();}

		}

		else if(com=='D'){
			in>>str1;
			out<<endl<<"D "<<str1<<endl;
			cout<<endl<<"D "<<str1<<endl;
			st->Lookup(str1);
			st->Remove(str1);

		}

		else if(com=='S'){
			cout<<endl<<"S"<<endl;
			out<<endl<<"S"<<endl;
			st->Enter_Scope();
		}

		else if(com=='E'){
			cout<<endl<<"E"<<endl;
			out<<endl<<"E"<<endl;
			st->Exit_Scope();
		}

	}

	delete st;
	in.close();
	out.close();
	//getch();
	return 0;
}*/
