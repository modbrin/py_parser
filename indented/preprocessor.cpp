#include <bits/stdc++.h>

using namespace std;
#define pb push_back
pair<int,string> rem_spaces(string& line){
    string res = "";
    int i = 0;
    int cnt = 0;
    while(i<line.size() && (line[i]==' ' || line[i]=='\t')){
        i++;
        if(line[i]==' '){
            cnt++;
        } else{
            cnt+=4;
        }
    }
    res =  line.substr(i);
    return {cnt,res};
}

int main(int argc, char* argv[])
{
    if(argc == 2) {    
    freopen(argv[1],"r",stdin);
    }

    string intent ="1INDENT1";
    string dedent = "1DEDENT1";

    string line;

    stack<int> st;
    ofstream fout("output.txt");

    while(getline(cin,line)){
        if(line.size()==0)
            continue;
        int spaces;
        tie(spaces,line) = rem_spaces(line);
       // cout <<spaces<<endl;
        if(spaces > 0){
            if(st.empty() || spaces > st.top()){
                fout << intent<<" ";
                st.push(spaces);
            } else{
                bool flag = 0;
                while(!st.empty() && st.top()>spaces){
                    fout <<dedent<<" ";
                    flag = 1;
                    st.pop();
                }
                if(st.empty() || st.top() < spaces){
                    fout <<intent<<" ";
                    st.push(spaces);
                } else if(st.top() == spaces){

                }
            }
        } else{
            while(!st.empty()){
                fout <<dedent<<" ";
                st.pop();
            }
        }

        fout << line<<endl;
    }

    while(!st.empty()){
        fout <<dedent<<" ";
        st.pop();
    }
    fout << endl;
    fout.close();
    system("parser output.txt");
}
