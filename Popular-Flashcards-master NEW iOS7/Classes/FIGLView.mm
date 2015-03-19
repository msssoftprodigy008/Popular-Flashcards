//
//  FIGLView.m
//  flashCards
//
//  Created by Ruslan on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIGLView.h"

#define lineOffset 1.0
#define circleApp 100

@interface FIGLView(Private)

-(void)clearView;
-(void)drawView;
-(void)panMoved:(UIPanGestureRecognizer*)sender;

//opengl init
-(void)initBuffers;
-(void)setMatrix;
-(void)initTextureCoord;

//drawing primitives
-(void)drawCircle:(GPoint)begin forEnd:(GPoint)end forMinRad:(float)minRad forMaxRad:(float)maxRad forColor:(color)circColor;
-(void)drawSeam:(float*)vertexies;
-(void)drawTriangleLine:(float*)vertexies forColor:(color)lineColor;

@end


@implementation FIGLView
@synthesize isClear;

+(Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		
		self.contentScaleFactor = [UIScreen mainScreen].scale;
		CAEAGLLayer *eaglLayer = (CAEAGLLayer*)super.layer;
		eaglLayer.opaque = YES;
		//eaglLayer.contentsScale = [UIScreen mainScreen].scale;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], 
										kEAGLDrawablePropertyRetainedBacking, 
										kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

		m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
				
		if (!m_context || ![EAGLContext setCurrentContext:m_context]) {
			[self release];
			return nil;
		}
		
		[self initBuffers];
		[self setMatrix];
		
		usingColor.r = 0.5f;
		usingColor.g = 0.5f;
		usingColor.b = 0.5f;
		usingColor.alpha = 1.0;
		erraserRadius = 5.0;
		lwidth = 5.0;
		[self changeLineWidth:5.0];
		[self clearView];
		isClear = YES;
		
		dispLink = [CADisplayLink displayLinkWithTarget:self
													  selector:@selector(drawView)];
		[dispLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
    }
    return self;
}

-(void)invalidate
{
	if (dispLink) {
		[dispLink invalidate];
		dispLink = nil;
	}
}

#pragma mark -
#pragma mark class methods

-(void)clear
{
	[self clearView];
	isClear = YES;
}

-(void)errserEnable:(BOOL)enable
{
	isErrser = enable;
}

-(void)setErraserRadius:(float)radius
{
	erraserRadius = radius*[UIScreen mainScreen].scale;
}

-(void)setColor:(CGFloat)red forG:(CGFloat)green forB:(CGFloat)blue forA:(CGFloat)a;
{
	usingColor.r = red;
	usingColor.g = green;
	usingColor.b = blue;
	usingColor.alpha = a;
}

-(UIImage*)getImage
{
	CGSize displaySize	= CGSizeMake(self.frame.size.width*[UIScreen mainScreen].scale,
									 self.frame.size.height*[UIScreen mainScreen].scale);
	CGSize winSize		= CGSizeMake(self.frame.size.width*[UIScreen mainScreen].scale,
									 self.frame.size.height*[UIScreen mainScreen].scale);;
	
	//Create buffer for pixels
	GLuint bufferLength = displaySize.width * displaySize.height * 4;
	GLubyte* buffer = (GLubyte*)malloc(bufferLength);
	
	//Read Pixels from OpenGL
	glReadPixels(0, 0, displaySize.width, displaySize.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	//Make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	
	//Configure image
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * displaySize.width;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	CGImageRef iref = CGImageCreate(displaySize.width, displaySize.height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
	
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
	CGContextRef context = CGBitmapContextCreate(pixels, winSize.width, winSize.height, 8, winSize.width * 4, CGImageGetColorSpace(iref), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	
	CGContextTranslateCTM(context, 0, displaySize.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, displaySize.width, displaySize.height), iref);
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage *outputImage = [[[UIImage alloc] initWithCGImage:imageRef] autorelease];
	
	//Dealloc
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGImageRelease(iref);
	CGColorSpaceRelease(colorSpaceRef);
	CGContextRelease(context);
	free(buffer);
	free(pixels);
	
	return outputImage;
}

-(void)changeLineWidth:(CGFloat)lWidth
{
	lwidth = lWidth*[UIScreen mainScreen].scale;
	glLineWidth(lWidth);
	//glPointSize(lWidth);

}

#pragma mark -

#pragma mark -
#pragma mark opengl init

-(void)initBuffers
{
	glGenFramebuffersOES(1,&framebuffer);
	glGenRenderbuffersOES(1,&renderbuffer);
	glBindFramebufferOES(GL_FRAMEBUFFER_OES,framebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES,renderbuffer);
	[m_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES,
								 GL_COLOR_ATTACHMENT0_OES,
								 GL_RENDERBUFFER_OES,
								 renderbuffer);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
		
}

-(void)setMatrix
{
	CGFloat scaleFactor = [UIScreen mainScreen].scale;
	glViewport(0,0,CGRectGetWidth(self.frame)*scaleFactor,CGRectGetHeight(self.frame)*scaleFactor);
	glMatrixMode(GL_PROJECTION);
	glOrthof(-self.frame.size.width/2*scaleFactor,
			 self.frame.size.width/2*scaleFactor,
			 -self.frame.size.height/2*scaleFactor,
			 self.frame.size.height/2*scaleFactor,-1.0,1.0);
	
	glMatrixMode(GL_MODELVIEW);
}


#pragma mark -


#pragma mark -
#pragma mark targets

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *t = [event touchesForView:self];
	UITouch *imageTouch = [[t objectEnumerator] nextObject];
	CGPoint p = [imageTouch locationInView:self];
	CGFloat scaleFactor = [UIScreen mainScreen].scale;
	p = CGPointMake(p.x*scaleFactor,p.y*scaleFactor);
	begPoint.x = p.x-self.frame.size.width/2*scaleFactor;
	begPoint.y = scaleFactor*self.frame.size.height/2-p.y;
	

	
	isFirst = YES;
	
	if (!isErrser) {
		[self drawCircle:begPoint forEnd:begPoint forMinRad:lwidth forMaxRad:lwidth+lineOffset forColor:usingColor];
	}else {
		color col;
		col.r=col.g=col.b=col.alpha=1.0;
		[self drawCircle:begPoint forEnd:begPoint forMinRad:erraserRadius forMaxRad:erraserRadius+lineOffset forColor:col];
	}
	
	if (isClear) {
		isClear = NO;
	}

}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *t = [event touchesForView:self];
	UITouch *imageTouch = [[t objectEnumerator] nextObject];
	CGPoint p = [imageTouch locationInView:self];
	GPoint nexPoint;
	CGFloat scaleFactor = [UIScreen mainScreen].scale;
	p = CGPointMake(p.x*scaleFactor,p.y*scaleFactor);
	nexPoint.x = p.x-scaleFactor*self.frame.size.width/2;
	nexPoint.y = scaleFactor*self.frame.size.height/2-p.y;

		
	if (isErrser) {
		color col;
		col.r=col.g=col.b=col.alpha=1.0;
		float* vertexies = generateTrianglesSuperCoord(begPoint,nexPoint,erraserRadius,lineOffset);
		[self drawTriangleLine:vertexies forColor:col];
		[self drawCircle:begPoint forEnd:nexPoint forMinRad:erraserRadius forMaxRad:erraserRadius+lineOffset forColor:col];
		free(vertexies);
	}
	else {
		float width = lwidth;
		float* vertexies = generateTrianglesSuperCoord(begPoint,nexPoint,width,lineOffset);
        
        /*NSLog(@"bginX %0.2lf beginY %0.2lf endX %0.2lf endY %0.2lf width %0.2lf lineoff %0.2lf",begPoint.x,begPoint.y,nexPoint.x,nexPoint.y,width,lineOffset);
        
        NSLog(@"LINE_________________________");
        for (int i=0; i<16; i++) {
            NSLog(@"%0.2lf",vertexies[i]);
        }
        NSLog(@"LINE_________________________");*/
        
		if (isFirst) {
			isFirst = NO;
		}else {
			[self drawSeam:vertexies];
			[self drawCircle:begPoint forEnd:begPoint forMinRad:lwidth forMaxRad:lwidth+lineOffset-1 forColor:usingColor];
		}

		[self drawTriangleLine:vertexies forColor:usingColor];
	
		prevVertex[0].x = vertexies[0];
		prevVertex[0].y = vertexies[1];
		prevVertex[1].x = vertexies[4];
		prevVertex[1].y = vertexies[5];
		prevVertex[2].x = vertexies[8];
		prevVertex[2].y = vertexies[9];
		prevVertex[3].x = vertexies[12];
		prevVertex[3].y = vertexies[13];
	
		free(vertexies);
	}
	
	begPoint = nexPoint;
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!isFirst) {
		[self drawCircle:begPoint forEnd:begPoint forMinRad:lwidth forMaxRad:lwidth+lineOffset forColor:usingColor];
	}

}

#pragma mark -

#pragma mark -
#pragma mark drawing primitives

-(void)drawCircle:(GPoint)begin forEnd:(GPoint)end forMinRad:(float)minRad forMaxRad:(float)maxRad forColor:(color)circColor
{
	float *circleArr = createCircle(begin,end,minRad,maxRad-minRad,circleApp);
	color colorArr[5*(circleApp+1)];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	for (int i=0;i<5*(circleApp+1);i++) {
		colorArr[i] = circColor;
		if (i%5==0 || i%5==1) {
			colorArr[i].alpha = 0.0;
		}
	}
	
	for (int i=0;i<circleApp;i++) {
		glVertexPointer(2,GL_FLOAT,2*sizeof(float),&circleArr[10*i]); 
		glColorPointer(4,GL_FLOAT,sizeof(color),&colorArr[5*i]);
		glDrawArrays(GL_TRIANGLE_STRIP,0,5);
	}
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	free(circleArr);
	
}

-(void)drawSeam:(float*)vertexies
{
	float *axVert = makeShov(vertexies,prevVertex);
	
	color axcolor[8];
	for (int i=0;i<8;i++) {
		axcolor[i] = usingColor;
	}
	
	axcolor[0].alpha = 0.0;
	axcolor[1].alpha = 0.0;
	axcolor[6].alpha = 0.0;
	axcolor[7].alpha = 0.0;
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2,GL_FLOAT,2*sizeof(float),&axVert[0]); 
	glColorPointer(4,GL_FLOAT,sizeof(color),&axcolor[0]);
	glDrawArrays(GL_TRIANGLE_STRIP,0,8);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
		
	free(axVert);
	
}

-(void)drawTriangleLine:(float*)vertexies forColor:(color)lineColor;
{
	color colorArr[8];
	for (int i=0;i<8;i++) {
		colorArr[i] = lineColor;
	}
	
	colorArr[0].alpha = 0.0;
	colorArr[1].alpha = 0.0;
	colorArr[7].alpha = 0.0;
	colorArr[6].alpha = 0.0;
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2,GL_FLOAT,2*sizeof(float),&vertexies[0]); 
	glColorPointer(4,GL_FLOAT,sizeof(color),&colorArr[0]);
	glDrawArrays(GL_TRIANGLE_STRIP,0,8);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
}

#pragma mark -

#pragma mark -
#pragma mark private
-(void)clearView
{
	
	 glClearColor(1.0f,1.0f,1.0f,1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_POINT_SMOOTH);
	
	
}

-(void)drawView
{
	[m_context presentRenderbuffer:GL_RENDERBUFFER_OES];
}



#pragma mark -

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	
	if ([EAGLContext currentContext] == m_context) {
		[EAGLContext setCurrentContext:nil];
	}
	[m_context release];
    [super dealloc];
}


@end
