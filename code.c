/*
TEST FILE FOR A C LIKE LANGUAGE AS MENTIONED IN THE REF.PDF

FILE NAME: 				CODE.C
FUNCTION:         A TEST FILE TO CHECK PROCESSING OF THE COMPILER INPUT
SUBMITTED BY: 		GROUP 10, COMPILERS LAB, IIT PATNA
GROUP MEMBERS: 		TANMAY DAS (1401CS47)
									MAYANK GOYAL (1401CS25)
									AVANISH KUMAR DAS (1401CS05)
*/

#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

/*
struct node{
	int a, b;
	double c, d, e;
	struct node* next;
};
*/

// a union
union fruit
{
    int data;
    double a;
    long c;
};

// Function definition
int abc(int a, int b);
int gf();
int isBSTUtil(struct node* node, int min, int max);

// creating structure
struct node
{
    int data;
    struct node* left;
    struct node* right;
};

/* function definition of abc */
int abc() {
	int a, *b, c, d, f, e;
	extern int l;
	const int m=5;
  struct node node;
  b = 4.233;
	b = d+c;
	a=4;

	a=c-5;

  // accessing data through pointer
	*node->data->left->right=b;

  // while loop
  while(a<4) {
		int a, b, c;
		a=*b+c;
		a=4;
		if(gf()&&abc(5,6))
			*b=abc(4);
	}
	a=abc(4);
	if(a==5) {
		c=d+e;
	}
	if(!(a==4)) {
		*b=c;
	}

  // Examples of looping
	do {
		for(a=4; a<=10; a+=2) {
			if(a&10)
				*b=c;
		}
	} while(b != 5);
	a=*b&c;
	*b=a^b;
	goto label;
	*b = c << 5;
	*b <<= 3;
	d++;
	--c;
	return (2+a);
}

// Main function of the c-like language
void main(int a){

  /*
    A few declarations and assignments, also using pointers
  */
  struct node* a, *temp;
	int b,c,d,e;
	int ab;
	int a=6;
	c=gf(3);

  // For loop
	for(a=5;a<10;a++) {
		a>>=2;
		if(b<=c)
			b=5;

	}
  // Conditionals
	if(a > 0) {
		b = (c == d)?(d+5):(c-15);
	}

  // Function call
	abc(a,b+5,c+e);

  // Switch statement
	switch(a) {
		case 'a':
			b=4;
			if(a==5) {
				c=d+e;
				d=5;
				if(a == 4) {
					b=3;
					c=5;
					a=b+c;
				}
				continue;
			}
		case 'b':
			b=4;
			if(a==5) {
				c=d+e;
				d=5;
				break;
			}
			break;
		default :
			b=4;
			if(a==5) {
				c=d+e;
				d=5;
			}
	}
	return 0;
}
