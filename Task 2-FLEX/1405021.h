#include <iostream>
#include <cstdlib>
//#include <conio.h>
#include <string>
#include <cstring>
#include <fstream>

using namespace std;

//ifstream in("input.txt");
FILE* logoutt;
ofstream out("output.txt");

class SymbolInfo{
	string Name;
	string Type;
	SymbolInfo* next;

public:
	string getName(){
		return Name;
	}

	void setName(string i1){
		Name = i1;
	}

	string getType(){
		return Type;
	}

	string setType(string i2){
		Type = i2;
	}

	SymbolInfo* getNext(){
		return next;
	}

	void setNext(SymbolInfo* N){
		next=N;
	}

	SymbolInfo(string N, string T,SymbolInfo* Ne){
		Name = N;
		Type = T;
		next = Ne;

	}

	SymbolInfo(string N, string T){
		Name = N;
		Type = T;
		next = NULL;
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
		int len=str.length();
		int total=173;
		char *acc=new char[str.length()+1];
		strcpy(acc,str.c_str()); // from Herbert Schildt
		for(int i=0;i<len;i++){
			total+=acc[i]*(size+i+i);
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
					out<<endl<<" Found in ScopeTable# "<<id <<" at position "<<hashvalue<<","<<track<<endl;
					return a;
				}
				a = a->getNext();
				track++;
			}
			//curr = curr->parentScope;
		//}
		return NULL;
	}

	void Print(){
		cout<<endl<<" ScopeTable # "<<scopeId<<endl;
		out<<endl<<" ScopeTable # "<<scopeId<<endl;
		fprintf(logoutt," ScopeTable # %d\n",scopeId);
		for(int hash=0;hash<size;hash++){

			SymbolInfo *a=SymBucket[hash];
			if(a->getNext()){
			cout<<" "<<hash<<" --> ";
			out<<" "<<hash<<" --> ";
			fprintf(logoutt," %d --> ",hash);
			while(a->getNext()){
				cout<<" < "<<a->getNext()->getName()<<" : "<<a->getNext()->getType()<<"> ";
				out<<" < "<<a->getNext()->getName()<<" : "<<a->getNext()->getType()<<"> ";
				fprintf(logoutt," < %s : %s> ",a->getNext()->getName().c_str(),a->getNext()->getType().c_str());
				a=a->getNext();
			}
			cout<<endl;
			out<<endl;
			fprintf(logoutt,"\n");
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
					out<<endl<<" <"<<nam<<","<<typ<<"> "<<"already exists in current ScopeTable"<<endl;
					return false;
				}
				if(a->getNext()!=NULL)
					a = a->getNext();
				else{
					a->setNext(new SymbolInfo(nam,typ));
					cout<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					out<<endl<<" Inserted in ScopeTable# "<<id<<" at position "<<hashvalue<<","<<track<<endl;
					Print();
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
					out<<endl<<"Deleted entry at "<<hashvalue<<","<<track<<" from current ScopeTable"<<endl;
					return true;
				}
				a=a->getNext();
				track++;
	}
			cout<<endl<<nam <<" not found"<<endl;
			out<<endl<<nam <<" not found"<<endl;
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
	ScopeTable* current;
	int size;
public:
	SymbolTable(int siz){
		size = siz;
		current=new ScopeTable(size);
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
		out<<endl<<" New ScopeTable with id "<< current->getId() <<" created"<<endl;

	}

	void Exit_Scope(){
		int idd=current->getId();
		ScopeTable* temp = current;
		current=current->getparentScope();
		delete temp;
		cout<<endl<<" ScopeTable with id "<< idd<<" removed"<<endl;
		out<<endl<<" ScopeTable with id "<< idd<<" removed"<<endl;
		ScopeTable::id--;
	}

	bool Insert(string nam,string typ){
		return current->Insert(nam,typ);
	}

	bool Remove(string nam){
		 return current->Remove(nam);
	}

	SymbolInfo* Lookup(string nam){
		ScopeTable* now=current;
		while(now)
		{
		SymbolInfo* temp= now->Lookup(nam);
		if(temp!=NULL){
			return temp;
		}
		now = now->getparentScope();
		}
		cout<<endl<<" Not found"<<endl;
		out<<endl<<" Not found"<<endl;
		return NULL;
	}

	void PrintCurrentScope(){
		current->Print();
	}

	void PrintAllScope(){
		ScopeTable* now=current;
		while(now){
			now->Print();
			now=now->getparentScope();
		}

	}

};

int ScopeTable::id=0;

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
			out<<endl<<"I "<<str1<<" "<<str2<<endl;
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
