/*int k;
int gen_number(int n,int p){
	if(n==0 || p==1)
		return 3;
	if(n==1 || p==2)
		return 6;
	if(n==2 || p==0)
		return 4;
	if(n==3 || p==2)
		return 5;
	return gen_number(n-1,p)+gen_number(n-2,p-1)+gen_number(n-3,p-2)+gen_number(n-4,p)-7;
	}

int main(){
    int n,p,ans;
    n= 10;
    p =5;
    ans=gen_number(n,p);
    println(ans);
    return 0;
}*/
/*int k;
int fact(int n){
    int ans;
    if(n==1)
        return 1;

    return (n)*fact(n-1);
}

int main(){
    int k,ans;
    k=7;
    ans = fact(k);
    ans =ans /27;
    println(ans);
    return 0;
}*/
int k;

int fac(int n){
if (n==0 || n==1) return 1;
else return n*fac(n-1);
}


int gen_number(int n,int p){
    if(n==0 || p==1)
        return 3;
    if(n==1 || p==2)
        return 6;
    if(n==2 || p==0)
        return 4;
    if(n==3 || p==2)
        return 5;
    return gen_number(n-1,p)+gen_number(n-2,p-1)+gen_number(n-3,p-2)+gen_number(n-4,p)-7;
    }

int main(){
    int n,p,ans;
    n= 10;
    p =5;
    for(n=0;n<7;n++){
        p=p+8;
    }
    println(p);ans=0;
    while(p--){
        ans++;    
    }
        println(ans);
    ans=ans||p;
    if(ans==0){
        p=9;
    }
    else{
        p=11;
    }
    ans=p;
    println(ans);
    ans=30%7;
    println(ans);
    ans=!(!ans);
    println(ans);
    ans=7>0;
    println(ans);
        return 0;
}

