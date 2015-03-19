//
//  FIGLView.h
//  flashCards
//
//  Created by Ruslan on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "vecClass.hpp"

typedef struct Vertex {
	float Position[2];
	float Color[4];
}Vertex;


typedef struct drawColor{
	float r;
	float g;
	float b;
	float alpha;
}color;


@interface FIGLView : UIView {
	EAGLContext *m_context;
	GPoint begPoint;
	color usingColor;
	GLuint framebuffer;
	GLuint renderbuffer;
	GLuint texturebuffer;
	float lwidth;
	float erraserRadius;
	float texCoord[16];
	GPoint prevVertex[4];
	CADisplayLink *dispLink;
	BOOL isFirst;
	BOOL isErrser;
	BOOL isClear;
}

-(void)clear;
-(UIImage*)getImage;
-(void)changeLineWidth:(CGFloat)lWidth;
-(void)errserEnable:(BOOL)enable;
-(void)setErraserRadius:(float)radius;
-(void)setColor:(CGFloat)red forG:(CGFloat)green forB:(CGFloat)blue forA:(CGFloat)a;
-(void)invalidate;

@property(readonly)BOOL	isClear;

@end
