/*
 *  vec.cpp
 *  flashCards
 *
 *  Created by Ruslan on 2/18/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "vecClass.hpp"

vec3::vec3(float x,float y,float z)
{
	coord[0] = x;
	coord[1] = y;
	coord[2] = z;
}

vec3::vec3(){
    coord[0] = 0;
    coord[1] = 0;
    coord[2] = 0;
}

vec3 vec3::operator+(vec3& v)
{
    return vec3(v.coord[0]+coord[0],v.coord[1]+coord[1],v.coord[2]+coord[2]);
}

vec3 vec3::operator-(vec3& v)
{
	return vec3(coord[0]-v.coord[0],coord[1]-v.coord[1],coord[2]-v.coord[2]);
}

vec3 vec3::operator*(float n)
{
	return vec3(coord[0]*n,coord[1]*n,coord[2]*n);
}

float vec3::scalar(vec3& v)
{
	float r = 0.0;
	for (int i=0;i<3;i++) {
		r+=coord[i]*v.coord[i];
	}
	return r;
}

float vec3::length()
{
	float r = 0.0;
	for (int i=0;i<3;i++) {
		r+=coord[i]*coord[i];
	}
	return sqrt(r);
}

vec3 vec3::normalize()
{
	float l = this->length();
	if (l>1e-14) {
        return vec3(coord[0]/l,coord[1]/l,coord[2]/l);
	}

	return vec3(coord[0],coord[1],coord[2]);
}

float* generateTrianglesCoord(GPoint x,GPoint y,float width)
{
	vec3 a;
	a.coord[0] = x.x;
	a.coord[1] = x.y;
	a.coord[2] = 0.0;
	
	vec3 b;
	b.coord[0] = y.x;
    b.coord[1] = y.y;                                           
	b.coord[2] = 0.0;
	
    vec3 e;
	e = b-a;
	e = e.normalize();
	e = e*width;
	
	vec3 N;
	N.coord[0] = -e.coord[1];
	N.coord[1] = e.coord[0];
	N.coord[2] = 0.0;
	vec3 S = N*(-1.0);
	vec3 NE = (N+e);
	vec3 NW = (N-e);
	vec3 SW = NE*(-1.0);
	vec3 SE = NW*(-1.0);
	
	float *cTex = (float*)malloc(16*sizeof(float));
	
	vec3 TPoints[8];
	TPoints[0] = a+SW;
	TPoints[1] = a+NW;
	TPoints[2] = a+S;
	TPoints[3] = a+N;
	TPoints[4] = b+S;
	TPoints[5] = b+N;
	TPoints[6] = b+SE;
	TPoints[7] = b+NE;
	
	cTex[0] = TPoints[0].coord[0];
	cTex[1] = TPoints[0].coord[1];
	cTex[2] = TPoints[1].coord[0];
	cTex[3] = TPoints[1].coord[1];
	cTex[4] = TPoints[2].coord[0];
	cTex[5] = TPoints[2].coord[1];
	cTex[6] = TPoints[3].coord[0];
	cTex[7] = TPoints[3].coord[1];
	cTex[8] = TPoints[4].coord[0];
	cTex[9] = TPoints[4].coord[1];
	cTex[10] = TPoints[5].coord[0];
	cTex[11] = TPoints[5].coord[1];
	cTex[12] = TPoints[6].coord[0];
	cTex[13] = TPoints[6].coord[1];
	cTex[14] = TPoints[7].coord[0];
	cTex[15] = TPoints[7].coord[1];
	
	return cTex;
	
}

float* generateTrianglesSuperCoord(GPoint x,GPoint y,float width,float lineOff)
{
	vec3 a;
	a.coord[0] = x.x;
	a.coord[1] = x.y;
	a.coord[2] = 0.0;
	
	vec3 b;
	b.coord[0] = y.x;
	b.coord[1] = y.y;
	b.coord[2] = 0.0;
	vec3 e = b-a;
	e = e.normalize();
	vec3 e1 = e*(width+lineOff);
	e = e*width;
	
    vec3 E;
	E.coord[0] = -e1.coord[1];
	E.coord[1] = e1.coord[0];
	E.coord[2] = 0.0;
	vec3 A;
	A.coord[0] = -e.coord[1];
	A.coord[1] = e.coord[0];
	A.coord[2] = 0.0;
	
	vec3 D = A*(-1.0);
	vec3 K = E*(-1.0);
	vec3 F = b+E;
	vec3 B = b+A;
	vec3 C = b-A;
	vec3 J = b-E;
	
	
	A = a+A;
	E = a+E;
	D = a+D;
	K = a+K;
	
	float *cTex = (float*)malloc(16*sizeof(float));
	
	cTex[0] = F.coord[0];
	cTex[1] = F.coord[1];
	cTex[2] = E.coord[0];
	cTex[3] = E.coord[1];
	cTex[4] = B.coord[0];
	cTex[5] = B.coord[1];
	cTex[6] = A.coord[0];
	cTex[7] = A.coord[1];
	cTex[8] = C.coord[0];
	cTex[9] = C.coord[1];
	cTex[10] = D.coord[0];
	cTex[11] = D.coord[1];
	cTex[12] = J.coord[0];
	cTex[13] = J.coord[1];
	cTex[14] = K.coord[0];
	cTex[15] = K.coord[1];
	
	return cTex;
	
}

float* makeShov(float* vertexies,GPoint prevVertex[])
{
	float* v = (float*)malloc(16*sizeof(float));
	v[0] = prevVertex[0].x;
	v[1] = prevVertex[0].y;
	v[2] = vertexies[2];
	v[3] = vertexies[3];
	v[4] = prevVertex[1].x;
	v[5] = prevVertex[1].y;
	v[6] = vertexies[6];
	v[7] = vertexies[7];
	v[8] = prevVertex[2].x;
	v[9] = prevVertex[2].y;
	v[10] = vertexies[10];
	v[11] = vertexies[11];
	v[12] = prevVertex[3].x;
	v[13] = prevVertex[3].y;
	v[14] = vertexies[14];
	v[15] = vertexies[15];
	return v;
}

float* createCircle(GPoint beg,GPoint end,float width,float offset,int circleA)
{
	vec3 a;
	a.coord[0] = beg.x;
	a.coord[1] = beg.y;
	a.coord[2] = 0.0;
	
	vec3 b;
	b.coord[0] = end.x;
	b.coord[1] = end.y;
	b.coord[2] = 0.0;
	
	vec3 e;
	e.coord[0] = b.coord[0] - a.coord[0];
	e.coord[1] = b.coord[1] - a.coord[1];
	e.coord[2] = 0;
	e = e.normalize();
	float angle = acos(e.coord[0]);
	
	if (e.coord[1]<0) {
		angle*=-1.0;
	}
	
	float fromAngle = 0.0;
	float step = 2*M_PI/circleA;
	
	float *circle = (float*)malloc(10*(circleA+1)*sizeof(float));
	int j = 0;
	for (int i=0;i<circleA; i++) {
		GPoint p;
		p.x = b.coord[0]+(width+offset)*cos(fromAngle+step*i);
		p.y = b.coord[1]+(width+offset)*sin(fromAngle+step*i);
		circle[j] = p.x;
		circle[j+1] = p.y;
		p.x = b.coord[0]+(width+offset)*cos(fromAngle+step*(i+1));
		p.y = b.coord[1]+(width+offset)*sin(fromAngle+step*(i+1)); 
		circle[j+2] = p.x;
		circle[j+3] = p.y;
		p.x = b.coord[0]+(width)*cos(fromAngle+step*i);
		p.y = b.coord[1]+(width)*sin(fromAngle+step*i); 
		circle[j+4] = p.x;
		circle[j+5] = p.y;
		p.x = b.coord[0]+(width)*cos(fromAngle+step*(i+1));
		p.y = b.coord[1]+(width)*sin(fromAngle+step*(i+1)); 
		circle[j+6] = p.x;
		circle[j+7] = p.y;
		p.x = b.coord[0];
		p.y = b.coord[1]; 
		circle[j+8] = p.x;
		circle[j+9] = p.y;
		j+=10;
	}
	
	return circle;
		
}


float findAngle(GPoint x1,GPoint x2,GPoint y1,GPoint y2)
{
	vec3 a;
	a.coord[0] = x2.x-x1.x;
	a.coord[1] = x2.y-x1.y;
	a.coord[2] = 0.0;
	
	vec3 b;
	b.coord[0] = y2.x-y1.x;
	b.coord[1] = y2.y-y1.y;
	b.coord[2] = 0.0;
	
	a = a.normalize();
	b = b.normalize();
	
	return asin(a.coord[0]*b.coord[1]-a.coord[1]*b.coord[0]);	
}
