#include <string>
#include <iostream>

class Node{
public:
	std::string name;
	Node *left,*right;
	Node(std::string name): name(name), left(0), right(0) {}
    Node(std::string name,Node *left): name(name), left(left), right(0) {}
    Node(std::string name,Node *left,Node *right): name(name), left(left), right(right) {}
	void print(){
        std::cout <<"Start "<<name<<std::endl;   
        if(left)
            left->print();
        if(right)
            right->print();
        std::cout <<"End "<<name << std::endl;
    }

};