//
//  RIGroupScrollView.m
//  flashCards
//
//  Created by Ruslan on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIGroupScrollView.h"
#import "FIAnimationController.h"

@interface RIGroupScrollView(Private)

//init
-(void)initView:(RIGroupScrollViewLocation)location;
-(void)initButtons;
-(void)unloadButtons;
-(void)unloadView:(RIGroupScrollViewLocation)location;
-(void)unloadAllViews;
-(void)reloadFreePlaces;

//targets
-(void)handlePan:(UIPanGestureRecognizer*)sender;
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)viewPressed:(id)sender;

//private
-(void)updateView:(RIGroupScrollViewLocation)location;
-(void)completeDragging;
-(void)completeDraggingAnimation:(NSInteger)which;
-(void)makeIdentity;
-(NSInteger)calculateButtonsPerColumn;
-(NSInteger)calculateNumberOfColumns;
-(CGSize)buttonPlacedSize;
-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP;

@end


@implementation RIGroupScrollView
@synthesize r_delegate;
@synthesize r_viewSize;

#pragma mark -
#pragma mark main methods

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
		r_isInited = NO;
		
		r_numberOfButtons = 0;
		
		r_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																  action:@selector(handlePan:)];
		r_panRecognizer.delegate = self;
		[self addGestureRecognizer:r_panRecognizer];
		[r_panRecognizer release];
		self.multipleTouchEnabled = NO;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	[self unloadButtons];
	[self unloadAllViews];
	
	if (r_freePlaces) {
		[r_freePlaces release];
	}
	
    [super dealloc];
}

#pragma mark main methods ends

#pragma mark -
#pragma mark public methods



-(void)reloadData
{
	[self unloadAllViews];
	[self unloadButtons];
	r_pageNum =  [r_delegate numberOfPages:self];
	r_viewsPerPage = [r_delegate numberOfItemsPerPage:self];
	r_numberOfButtons = [r_delegate numberOfButtons:self];
	r_buttonSize = [r_delegate buttonSize:self];
	r_currentPage = 0;
	
	
	[self reloadFreePlaces];

	
	if (r_pageNum>0) {
		[self initView:RIGroupScrollViewCenter];
		[self updateView:RIGroupScrollViewCenter];
		[self initView:RIGroupScrollViewRight];
		[self updateView:RIGroupScrollViewRight];
		[self initView:RIGroupScrollViewLeft];
		[self updateView:RIGroupScrollViewLeft];
	}
	
	if (r_numberOfButtons>0) {
		[self initButtons];
	}
	
}

-(void)reloadCurrentPage
{
	[self reloadFreePlaces];
	
	if (r_pageNum>0) {
		[self updateView:RIGroupScrollViewCenter];
	}
}

-(void)reloadCurrentMemoryPages
{
	[self reloadFreePlaces];
	
	if (r_pageNum>0) {
		[self updateView:RIGroupScrollViewCenter];
		
		if (r_currentPage>0) {
			[self updateView:RIGroupScrollViewLeft];
		}
		
		if (r_currentPage<r_pageNum-1) {
			[self updateView:RIGroupScrollViewLeft];
		}
		
	}
	

}

-(BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animated
{
	r_pageNum = [r_delegate numberOfPages:self];
	r_viewsPerPage = [r_delegate numberOfItemsPerPage:self];
	
	BOOL isScrolled = NO;
	
	if (page<r_pageNum && page!=r_currentPage) {
		
		isScrolled = YES;
		
		if (animated) {
			r_centerView = [self viewWithTag:1001];
			
			if (r_centerView) {
				
				if (page>r_currentPage) {
					[[FIAnimationController sharedAnimation:nil] fallAndTrembell:r_centerView
																		 dir:kCATransitionFromRight];
				}else {
					[[FIAnimationController sharedAnimation:nil] fallAndTrembell:r_centerView
																			 dir:kCATransitionFromLeft];
				}

			}
			
		}
		r_currentPage = page;
	}

	[self updateView:RIGroupScrollViewCenter];
	[self updateView:RIGroupScrollViewLeft];
	[self updateView:RIGroupScrollViewRight];
	
	return isScrolled;
}

-(NSArray*)getFreePlace
{
	NSArray *freePlace = nil;
	
	if (r_freePlaces && [r_freePlaces count]>0) {
		freePlace = [NSArray arrayWithArray:[r_freePlaces objectAtIndex:0]];
		[r_freePlaces removeObjectAtIndex:0];
	}
	
	return freePlace;
}

-(NSInteger)getCurrentPage
{
	return r_currentPage;
}

#pragma mark public methods ends

#pragma mark -
#pragma mark init 

-(void)initView:(RIGroupScrollViewLocation)location
{
	UIView *itemView = nil;
	
	switch (location) {
		case RIGroupScrollViewLeft:
			r_leftView = [[UIView alloc] initWithFrame:CGRectMake(-self.frame.size.width,
																  0.0,
																  self.frame.size.width,
																  self.frame.size.height)];
			r_leftView.tag = 1000;
			itemView = r_leftView;
			break;
		case RIGroupScrollViewCenter:
			r_centerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,self.frame.size.width,self.frame.size.height)];
			r_centerView.tag = 1001;
			itemView = r_centerView;
			break;
		case RIGroupScrollViewRight:
			r_rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width,
																   0.0,
																   self.frame.size.width,
																   self.frame.size.height)];
			r_rightView.tag = 1002;
			itemView = r_rightView;
			break;
	
	
		default:
			break;
	}
		
	if (itemView) {
		CGSize bSZ = [self buttonPlacedSize];
		NSInteger t_distance = (itemView.frame.size.width-r_viewsPerPage*r_viewSize.width-bSZ.width-bSZ.height)/(r_viewsPerPage+1);
		NSInteger ty = 5.0;
		
		for (int i=0;i<r_viewsPerPage;i++) {
			RIPageView *pageView = [[RIPageView alloc] initWithFrame:CGRectMake(bSZ.width+i*r_viewSize.width+(i+1)*t_distance,
																			ty,
																			r_viewSize.width,
																			r_viewSize.height)];

			pageView.tag = 10010+i;
			pageView.r_delegate = self;
			pageView.r_titleLabel.text = [NSString stringWithFormat:@"Group%d",i+1];
			[itemView addSubview:pageView];
			[pageView release];
		}
		
		[self addSubview:itemView];
	}
	
}

-(void)unloadView:(RIGroupScrollViewLocation)location
{
	r_leftView = [self viewWithTag:1000];
	r_centerView = [self viewWithTag:1001];
	r_rightView = [self viewWithTag:1002];
	
	if (location == RIGroupScrollViewCenter && r_centerView){
		[r_centerView removeFromSuperview];
		[r_centerView release];
		r_centerView = nil;
	}
	
	if (location == RIGroupScrollViewLeft && r_leftView){
		[r_leftView removeFromSuperview];
		[r_leftView release];
		r_leftView = nil;
	}
	
	if (location == RIGroupScrollViewRight && r_rightView){
		[r_rightView removeFromSuperview];
		[r_rightView release];
		r_rightView = nil;
	}
	
}

-(void)initButtons
{
	NSInteger nPC = [self calculateButtonsPerColumn];
	
	NSInteger numOfPlacedToLeft = 0;
	NSInteger numOfPlacedToRight = 0;
	
	BOOL isLeft = YES;
	
	CGFloat tx = 2.0;
	CGFloat ty = 2.0;
	
	UIView *buttonLeftView = nil;
	UIView *buttonRightView = nil;
	CGSize bPZ = [self buttonPlacedSize];
	
	UIColor *cardSteelBlue = [UIColor colorWithRed:70.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1.0];
	
	for (int i=0;i<r_numberOfButtons;i++) {
		CGFloat mX;
		CGFloat mY;
		
		if (isLeft) {
			mX = tx+(numOfPlacedToLeft/nPC)*(r_buttonSize.width+tx);
			mY = ty+(numOfPlacedToLeft%nPC)*(r_buttonSize.height+ty);
		}else {
			mX = tx+(numOfPlacedToRight/nPC)*(r_buttonSize.width+tx);
			mY = ty+(numOfPlacedToRight%nPC)*(r_buttonSize.height+ty);
		}

		
		FIRoundedButton *button = [[FIRoundedButton alloc] initWithFrame:CGRectMake(mX,
																					mY,
																					r_buttonSize.width,
																					r_buttonSize.height)];
		button.r_distance = 2.0;
		button.r_innerRadius = r_buttonSize.width/6.0;
		button.r_outerRadius = r_buttonSize.width/7.0;
		button.r_innnerColor = [UIColor whiteColor];
		button.r_outerColor = [UIColor lightGrayColor];
		button.r_hinnnerColor = cardSteelBlue;
		button.r_titleLabel.text = [NSString stringWithFormat:@"button%d",i+1];
		button.tag = 10010+i;
		
		if (isLeft) {
			if (!buttonLeftView) {
				buttonLeftView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,bPZ.width,self.frame.size.height)];
				buttonLeftView.backgroundColor = self.backgroundColor;
				buttonLeftView.tag = -100;
				[self addSubview:buttonLeftView];
			}
			[buttonLeftView addSubview:button];
			
			numOfPlacedToLeft++;
			
			if (numOfPlacedToLeft%nPC == 0) {
				isLeft = NO;
			}
			
			
		}else {
			if (!buttonRightView) {
				buttonRightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-bPZ.height,0.0,bPZ.height,self.frame.size.height)];
				buttonRightView.backgroundColor = self.backgroundColor;
				buttonRightView.tag = -101;
				[self addSubview:buttonRightView];
			}
			[buttonRightView addSubview:button];
			
			numOfPlacedToRight++;
			if (numOfPlacedToRight%nPC == 0) {
				isLeft = YES;
			}
			
		}
		
		[r_delegate customizeButton:self
						  forButton:button
					   forButtonNum:i];
		[button release];
		
	}
	
	
	

	
}

-(void)unloadButtons
{
	UIView *buttonView = [self viewWithTag:-100];
	
	if (buttonView) {
		[buttonView removeFromSuperview];
		[buttonView release];
	}
	
	buttonView = [self viewWithTag:-101];
	
	if (buttonView) {
		[buttonView removeFromSuperview];
		[buttonView release];
	}
	
	
}

-(void)unloadAllViews
{
	[self unloadView:RIGroupScrollViewLeft];
	[self unloadView:RIGroupScrollViewCenter];
	[self unloadView:RIGroupScrollViewRight];
}

-(void)reloadFreePlaces
{
	if (r_freePlaces) {
		[r_freePlaces removeAllObjects];
	}else {
		r_freePlaces = [[NSMutableArray alloc] init];
	}
	
	for (int i=0;i<r_pageNum;i++) {
		NSInteger validNum = [r_delegate validItemsForPage:self forPage:i];
		for (int j=validNum;j<r_viewsPerPage;j++) {
			NSArray *freePlace = [NSArray arrayWithObjects:[NSNumber numberWithInt:i],[NSNumber numberWithInt:j],nil];
			[r_freePlaces addObject:freePlace];
		}
	}
}

#pragma mark init ends

#pragma mark -
#pragma mark targets

-(void)handlePan:(UIPanGestureRecognizer*)sender
{
	if (r_pageNum == 0) {
		return;
	}
	
	if (sender.state == UIGestureRecognizerStateEnded)
	{
		[self completeDragging];
		return;
	}
	
	CGPoint translate = [sender translationInView:self];
	CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
	
	r_leftView = (UIView*)[self viewWithTag:1000];
	r_centerView = (UIView*)[self viewWithTag:1001];
	r_rightView = (UIView*)[self viewWithTag:1002];
	
	if (r_centerView) {
		r_centerView.center = CGPointMake(centerPoint.x+translate.x,centerPoint.y);
	}
	
	if (r_rightView) {
		r_rightView.center = CGPointMake(3*centerPoint.x+translate.x,centerPoint.y);
		
		if (r_rightView.center.x>=3*centerPoint.x || r_currentPage==r_pageNum-1) {
			r_rightView.hidden = YES;
		}else {
			r_rightView.hidden = NO;
		}
	}
	
	if (r_leftView) {
		r_leftView.center = CGPointMake(-centerPoint.x+translate.x,centerPoint.y);
		
		if (r_leftView.center.x<=-centerPoint.x || r_currentPage==0) {
			r_leftView.hidden = YES;
		}else {
			r_leftView.hidden = NO;
		}

			
	}
	

	
	
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	UIView *leftView = (UIView*)[self viewWithTag:-100];
	UIView *rightView = (UIView*)[self viewWithTag:-101];
	
	if ((leftView && [touch.view isDescendantOfView:leftView]) || (rightView && [touch.view isDescendantOfView:rightView])) {
		return NO;
	}
	
	return YES;
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self updateView:RIGroupScrollViewLeft];
	[self updateView:RIGroupScrollViewRight];
}

#pragma mark targets ends

#pragma mark -
#pragma mark pageView delegate

-(void)viewDidSelected:(RIPageView*)page
{
	NSInteger tag = page.tag;
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(selectedViewForItem:forPageView:forPage:forNumInPage:)]) {
		[r_delegate selectedViewForItem:self
							forPageView:page
								forPage:r_currentPage
						   forNumInPage:tag-10010];
	}
	
}

#pragma mark pageView delegate ends

#pragma mark -
#pragma mark private

-(void)updateView:(RIGroupScrollViewLocation)location
{
	UIView *itemView = nil;
	
	NSInteger pageNumber;
	
	switch (location) {
		case RIGroupScrollViewLeft:
			
			if (r_currentPage==0) {
				return;
			}
			
			itemView = [self viewWithTag:1000];
			pageNumber = (r_currentPage-1+r_pageNum)%r_pageNum;
			break;
		case RIGroupScrollViewCenter:
			itemView = [self viewWithTag:1001];
			pageNumber = r_currentPage;
			break;
		case RIGroupScrollViewRight:
			
			if (r_currentPage==r_pageNum-1) {
				return;
			}
			
			itemView = [self viewWithTag:1002];
			pageNumber = (r_currentPage+1)%r_pageNum;
			break;
		default:
			break;
	}
	
	if (!itemView) {
		return;
	}
	
	//itemView.hidden = NO;
	NSInteger validNum = [r_delegate validItemsForPage:self forPage:pageNumber];
	
	
	for (int i=0;i<r_viewsPerPage;i++) {
		RIPageView *page = (RIPageView*)[itemView viewWithTag:10010+i];
		
		if (i>=validNum) {
			page.hidden = YES;
			continue;
		}else {
			page.hidden = NO;
		}

		
		[r_delegate viewForItem:self
					forPageView:page
						forPage:pageNumber
				   forNumInPage:i];
		
	}
	
}

-(void)completeDragging
{
	r_leftView = (UIView*)[self viewWithTag:1000];
	r_centerView = (UIView*)[self viewWithTag:1001];
	r_rightView = (UIView*)[self viewWithTag:1002];
	
	CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
	
	CGFloat min1 = [self calculateDis:r_centerView.center forSec:CGPointMake(0,centerPoint.y)];
	CGFloat min2 = [self calculateDis:r_centerView.center forSec:centerPoint];
	CGFloat min3 = [self calculateDis:r_centerView.center forSec:CGPointMake(2*centerPoint.x,centerPoint.y)];
	NSInteger which;
	
	if (min1<=min2 && min1<=min3) {
		which = 0;
	}
	else {
		if (min2<=min1 && min2<=min3) {
			which = 1;
		}
		else {
			if (min3<=min2 && min3<=min1) {
				which = 2;
			}
		}
		
	}
	
	[self completeDraggingAnimation:which];
}

-(void)completeDraggingAnimation:(NSInteger)which
{
	r_leftView = (UIView*)[self viewWithTag:1000];
	r_centerView = (UIView*)[self viewWithTag:1001];
	r_rightView = (UIView*)[self viewWithTag:1002];
	
	CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
	
	if (which == 0 && r_currentPage == r_pageNum-1) {
		which = 1;
	}else {
		if (which == 2 && r_currentPage == 0) {
			which = 1;
		}
	}
	
	switch (which) {
		case 0:
		{
			if (r_leftView) 
				r_leftView.tag = 1002;
			if (r_centerView) 
				r_centerView.tag = 1000;
			if (r_rightView) 
				r_rightView.tag = 1001;
			r_currentPage = (r_currentPage+1)%r_pageNum;
			break;
		}
		case 2:
		{
			if (r_leftView) 
				r_leftView.tag = 1001;
			if(r_centerView)
				r_centerView.tag = 1002;
			if (r_rightView) 
				r_rightView.tag = 1000;
			r_currentPage = (r_currentPage-1+r_pageNum)%r_pageNum;
			break;
		}
		default:
			break;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	
	
	switch (which) {
		case 0:
		{
			if (r_leftView) 
				r_leftView.center = CGPointMake(3*centerPoint.x,centerPoint.y);
			if (r_centerView) 
				r_centerView.center = CGPointMake(-centerPoint.x,centerPoint.y);
			if (r_rightView) 
				r_rightView.center = centerPoint;
			break;
		}
		case 1:
		{
			if (r_leftView) 
				r_leftView.center = CGPointMake(-centerPoint.x,centerPoint.y);
			if (r_centerView) 
				r_centerView.center = centerPoint;
			if (r_rightView) 
				r_rightView.center = CGPointMake(3*centerPoint.x,centerPoint.y);
			break;
		}
		case 2:
		{
			if (r_leftView) 
				r_leftView.center = centerPoint;
			if (r_centerView) 
				r_centerView.center = CGPointMake(3*centerPoint.x,centerPoint.y);
			if (r_rightView) 
				r_rightView.center = CGPointMake(-centerPoint.x,centerPoint.y);
			break;
		}
		default:
			break;
	}
	
	if (which!=1) {
		SEL	 stopSel = @selector(animationDidStop:finished:context:);
		[UIView setAnimationDidStopSelector:stopSel];
	}
	
	
	[UIView commitAnimations];
}

-(void)makeIdentity
{
	r_leftView = (UIView*)[self viewWithTag:1000];
	r_centerView = (UIView*)[self viewWithTag:1001];
	r_rightView = (UIView*)[self viewWithTag:1002];
	
	CGPoint centerPoint = CGPointMake(self.frame.size.width/2.0,self.frame.size.height/2.0);
	
	if (r_leftView) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_leftView toPoint:CGPointMake(-centerPoint.x,centerPoint.y)];
	}
	
	if (r_centerView) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_centerView toPoint:centerPoint];
	}
	
	if (r_rightView) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_rightView toPoint:CGPointMake(3*centerPoint.x,centerPoint.y)];
	}
	
}

-(NSInteger)calculateButtonsPerColumn
{
	return  (NSInteger)(self.frame.size.height/(r_buttonSize.height+2.0));
}

-(NSInteger)calculateNumberOfColumns
{
	NSInteger bPC = [self calculateButtonsPerColumn];
	
	if (r_numberOfButtons%bPC) {
		return r_numberOfButtons/bPC+1;
	}else {
		return r_numberOfButtons/bPC;
	}
}

-(CGSize)buttonPlacedSize
{
	NSInteger nOC = [self calculateNumberOfColumns];
	NSInteger nOCS = nOC/2;
	
	if (nOC%2) {
		return CGSizeMake((nOCS+1)*r_buttonSize.width+(nOCS+2)*2.0,nOCS*r_buttonSize.width+(nOCS+1)*2.0);
	}else {
		return CGSizeMake(nOCS*r_buttonSize.width+(nOCS+1)*2.0,nOCS*r_buttonSize.width+(nOCS+1)*2.0);
	}

	
}

-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP
{
	return sqrt((fP.x-sP.x)*(fP.x-sP.x)+(fP.y-sP.y)*(fP.y-sP.y));
}

#pragma mark private ends

#pragma mark -
#pragma mark UIView delegate methods

-(void)willMoveToSuperview:(UIView *)newSuperview
{
	if (r_isInited) {
		return;
	}
	
	r_isInited = YES;
	
	[self reloadData];
	
}

#pragma mark UIView delegate methods ends


@end
