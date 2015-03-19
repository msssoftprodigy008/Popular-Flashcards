/*
 *  vecClass.hpp
 *  flashCards
 *
 *  Created by Ruslan on 2/18/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include <math.h>
#include <stdlib.h>
#include <stdio.h>

class vec3{
public:	
	float coord[3];
	
	vec3(float x,float y,float z);
    vec3();
	vec3 operator+(vec3& v);
	vec3 operator-(vec3& v);
	vec3 operator*(float n);
	float scalar(vec3& v);
	vec3 normalize();
	float length();
};

typedef struct GPoint{
	float x;
	float y;
}GPoint;


float* generateTrianglesCoord(GPoint x,GPoint y,float width);
float* generateTrianglesSuperCoord(GPoint x,GPoint y,float width,float lineOff);
float* makeShov(float* vertexies,GPoint prevVertex[]);
float* createCircle(GPoint beg,GPoint end,float width,float offset,int circleA);
float findAngle(GPoint x1,GPoint x2,GPoint y1,GPoint y2);