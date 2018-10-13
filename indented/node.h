#include <string>
#include <iostream>

class Node{
public:
	std::string name;
	Node *left,*right,*third,*fourth;
	Node(std::string name): name(name), left(0), right(0),third(0),fourth(0) {}
    Node(std::string name,Node *left): name(name), left(left), right(0),third(0),fourth(0) {}
    Node(std::string name,Node *left,Node *right): name(name), left(left), right(right),third(0),fourth(0) {}
    Node(std::string name,Node *left,Node *right,Node* third): name(name), left(left), right(right),third(third),fourth(0) {}
    Node(std::string name,Node *left,Node *right,Node* third,Node* fourth): name(name), left(left), right(right),third(third),fourth(fourth) {}
	void print(std::string add = ""){
        if(!left && !right){
            std::cout<<add <<"Token "<<name<<std::endl; 
            return;
        }
        std::cout<<add <<"Start "<<name<<std::endl;   
        if(left)
            left->print(add + "   ");
        if(right)
            right->print(add + "   ");
        if(third)
            third->print(add + "   ");
        if(fourth)
            fourth->print(add + "   ");
        std::cout <<add<<"End "<<name << std::endl;
    }

};