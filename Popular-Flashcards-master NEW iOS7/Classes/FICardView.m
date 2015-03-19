//
//  FICardView.m
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FICardView.h"
#import <QuartzCore/QuartzCore.h>
#import "FRootConstants.h"
#import "Util.h"
#import "Constant.h"
@interface FICardView(Private)

//IPhone device
-(void)initContent;
-(void)setContent;
-(void)handleImageTap:(UITapGestureRecognizer*)sender;
-(void)audioButtonPressed:(UITapGestureRecognizer*)sender;
-(void)updateCardNumberLabel:(NSInteger)first forLast:(NSInteger)last;

//IPad device
-(void)initIPadContent;
-(void)setIPadContent;
-(void)updateIPadCardNumberLabel:(NSInteger)first forLast:(NSInteger)last;

@end


@implementation FICardView

@synthesize isBothSide;
@synthesize isReversed;
@synthesize isCheckBoxExist;
@synthesize delegate;
@synthesize currentFont;
@synthesize cardTextView;
@synthesize isQuestion;

-(id)initWithContent:(NSDictionary*)content forSide:(BOOL)isB forRev:(BOOL)isRev forCheckBox:(BOOL)isChEx {
	
	CGRect cardFrame;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		cardFrame = CGRectMake(0,0,(IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth,kFCardHieght);
	}else {
		cardFrame = CGRectMake(0,0,kFCardLargeWidth,kFCardLargeHeight);
	}
    
	if ((self = [super initWithFrame:cardFrame])) {
        // Initialization code
		
		isBothSide = isB;
		isReversed = isRev;
		isCheckBoxExist = isChEx;
		
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
			[self initContent];
		}else {
			[self initIPadContent];
		}
        
		
		isQuestion = YES;
		if (content) {
			cardContentDictionary = [[NSDictionary alloc] initWithDictionary:content];
			
			if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
				[self setContent];
			}else {
				[self setIPadContent];
			}
            
		}
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled =  YES;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(updateCardTextView)
													 name:@"cardUpdateTextPosition"
												   object:nil];
		
		
	}
    return self;
}

-(void)setCurrentFont:(UIFont *)font
{
	cardTextView.font = font;
	questionLabel.font = font;
}

-(void)changeContent:(NSDictionary*)newContent
{
	if (cardContentDictionary) {
		[cardContentDictionary release];
	}
	
	cardContentDictionary = [[NSDictionary alloc] initWithDictionary:newContent];
	isQuestion = YES;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
		[self setContent];
	}else {
		[self setIPadContent];
	}
	
}

-(void)changeSide
{
	isQuestion = !isQuestion;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
		[self setContent];
	}else {
		[self setIPadContent];
	}
	
}

-(void)setSide:(BOOL)isQ
{
	isQuestion = isQ;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
		[self setContent];
	}else {
		[self setIPadContent];
	}
	
}

-(void)reloadContent
{
	if (cardContentDictionary) {
		
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
			[self setContent];
		}else {
			[self setIPadContent];
		}
		
	}
}

-(void)setShadowOffset:(CGPoint)offset
{
	cardView.layer.shadowOffset = CGSizeMake(offset.x,offset.y);
}

-(void)check:(BOOL)isChecked
{
	[checkButton changeState:isChecked];
}

-(void)handleImageTap:(UITapGestureRecognizer*)sender
{
	if (delegate && [delegate respondsToSelector:@selector(imageNeedFullScreen:forSize:forSide:)]) {
		[delegate imageNeedFullScreen:cardImageView.center forSize:[cardImageView drawnedImageSize] forSide:isQuestion];
	}
}

-(void)setShadowColor:(UIColor*)shadowColor
{
	cardView.layer.shadowColor = shadowColor.CGColor;
}

-(void)hideShadow
{
	cardView.layer.shadowOpacity = 0.0f;
    
}

-(void)seeShadow
{
	cardView.layer.shadowOpacity = 0.7f;
}

-(void)stopAudio
{
	if (audioPlayer && [audioPlayer isPlaying]) {
		[audioPlayer stop];
		audioPlayer.currentTime = 0.0;
	}
}

-(void)updateCardTextView
{
	CGPoint offset = cardTextView.contentOffset;
	CGPoint toffset = offset;
	
	CGSize contentSize = cardTextView.contentSize;
	CGSize toSize = CGSizeMake(contentSize.width-1.0,contentSize.height);
	toffset.y = toffset.y-1.0;
	cardTextView.contentOffset = toffset;
	cardTextView.contentOffset = offset;
	cardTextView.contentSize = toSize;
	cardTextView.contentSize = contentSize;
}

-(void)handleTapOnImage:(BOOL)handle
{
	cardImageView.userInteractionEnabled = handle;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark -
#pragma mark FIBouncingViewDelegate methods
-(void)stateChanged:(BOOL)newState
{
	if (delegate && [delegate respondsToSelector:@selector(checkButtonChangedState:)]) {
		if (newState) {
			[delegate checkButtonChangedState:FICheckboxStateChecked];
		}else {
			[delegate checkButtonChangedState:FICheckboxStateNotChecked];
		}
        
	}
}

#pragma mark -
#pragma mark targets
-(void)audioButtonPressed:(UITapGestureRecognizer*)sender
{
	if (audioPlayer) {
		if ([audioPlayer isPlaying]) {
			[audioPlayer stop];
			audioPlayer.currentTime = 0.0;
		}else {
			[audioPlayer play];
		}
        
	}
}

#pragma mark - Added a new method for text View scrolling..

- (CGSize)measureHeightOfUITextView:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        CGRect frame = textView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
                // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size1 = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
        
        
        //CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return size1.size;
    }
    else
    {
        return textView.contentSize;
    }
}




#pragma mark -
#pragma mark private methods

-(void)initContent
{
    // CHECK HERE ONLY.. MAIN ISSUE.. //
	cardTextView = [[UITextView alloc] init];
	cardTextView.editable = NO;
//	cardTextView.font = currentFont;
    cardTextView.font = [UIFont systemFontOfSize:12.0f];
//	cardTextView.clipsToBounds = NO;
//	cardTextView.contentMode = (UIViewContentModeScaleAspectFit);
//	cardTextView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	cardTextView.backgroundColor = [UIColor clearColor];
	cardTextView.textColor = [UIColor darkTextColor];
    cardTextView.text = @"";
	[cardTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionOld) context:NULL];
	
	cardImageView = [[FISketchedImageView alloc] initWithAtrributes:CGRectNull attr:nil];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
	[cardImageView addGestureRecognizer:tap];
	[tap release];
	
    CGFloat qWidth;
	
	
    
	if (IS_IPHONE_5) {
        cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardWidthIPhone5,kFCardHieght)];
        if (isCheckBoxExist) {
            checkButton = [[FIBouncingView alloc] initWithImages:CGRectMake(kFCardWidthIPhone5-10-36,10,36,36)
                                                       forActive:[UIImage imageNamed:@"i_checkbox_2.png"]
                                                   forNoneActive:[UIImage imageNamed:@"i_checkbox_1.png"]
                                                     forDelegate:self];
        }
        if (isCheckBoxExist) {
            qWidth = kFCardWidthIPhone5-3*5-36;
        }else {
            qWidth = kFCardWidthIPhone5-10;
        }
    }
    else{
        cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardWidth,kFCardHieght)];
        if (isCheckBoxExist) {
            checkButton = [[FIBouncingView alloc] initWithImages:CGRectMake(kFCardWidth-10-36,10,36,36)
                                                       forActive:[UIImage imageNamed:@"i_checkbox_2.png"]
                                                   forNoneActive:[UIImage imageNamed:@"i_checkbox_1.png"]
                                                     forDelegate:self];
        }
        if (isCheckBoxExist) {
            qWidth = kFCardWidth-3*5-36;
        }else {
            qWidth = kFCardWidth-10;
        }
    }
	cardView.image = [UIImage imageNamed:@"i_card_screen.png"];
	cardView.backgroundColor = [UIColor clearColor];
	
	
	
	//create shadow
	cardView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cardView.bounds].CGPath;
	cardView.layer.shadowColor = [UIColor blackColor].CGColor;
	cardView.layer.shadowRadius = 20.0f;
	cardView.layer.shadowOpacity = 0.7f;
	
	cardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,60,60)];
	cardNumberLabel.backgroundColor = [UIColor clearColor];
	cardNumberLabel.textAlignment = UITextAlignmentRight;
	cardNumberLabel.textColor = [UIColor colorWithRed:143.0/255.0 green:143.0/255.0 blue:143.0/255.0 alpha:1.0];
	cardNumberLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
	allNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,60,60)];
	allNumberLabel.textAlignment = UITextAlignmentLeft;
	allNumberLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0];
	allNumberLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
	allNumberLabel.backgroundColor = [UIColor clearColor];
	
    
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
		([UIScreen mainScreen].scale == 2.0)) {
		// Retina display
		questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,kFICardBigLineHeight,qWidth,30)];
	} else {
		// non-Retina display
		questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,kFICardBigLineHeight+3,qWidth,30)];
	}
	
	
	questionLabel.backgroundColor = [UIColor clearColor];
	questionLabel.textColor = [UIColor darkTextColor];
	questionLabel.font = currentFont;
	
	lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
																  questionLabel.frame.origin.y+questionLabel.frame.size.height-7,
																  (IS_IPHONE_5)?kFCardWidthIPhone5 :kFCardWidth,
																  1)];
	lineImageView.image = [UIImage imageNamed:@"i_card_line.png"];
	lineImageView.backgroundColor = [UIColor clearColor];
	lineImageView.hidden = YES;
    
	soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UITapGestureRecognizer *soundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioButtonPressed:)];
	[soundButton addGestureRecognizer:soundTap];
	[soundTap release];
	
	[self addSubview:cardView];
	[self addSubview:cardTextView];
	[self addSubview:cardNumberLabel];
	[self addSubview:allNumberLabel];
	[self addSubview:lineImageView];
	[self addSubview:questionLabel];
	[self addSubview:cardImageView];
	[self addSubview:soundButton];
	
    
    NSLog(@"%f",self.center.x);
	if (isCheckBoxExist)
		[self addSubview:checkButton];
    
	
	if (isCheckBoxExist)
		[checkButton release];
	
	[cardView release];
	[cardTextView release];
	[cardImageView release];
	[cardNumberLabel release];
	[allNumberLabel release];
	[questionLabel release];
	[lineImageView release];
}

-(void)setContent
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger cardNumber = [[cardContentDictionary objectForKey:@"number"] intValue];
	NSInteger allCardsNumber = [[cardContentDictionary objectForKey:@"allNumber"] intValue];
	NSData *sound;
	
	[self updateCardNumberLabel:cardNumber forLast:allCardsNumber];
	
	NSString *textC = @"";
	UIImage *imageC = nil;
	cardTextView.hidden = NO;
	cardImageView.hidden = NO;
	soundButton.hidden = NO;
	
	if (audioPlayer) {
		if ([audioPlayer isPlaying]) {
			[audioPlayer stop];
		}
		[audioPlayer release];
		audioPlayer = nil;
	}
	
	if (isQuestion && !isBothSide) {
		
		//initialization for question
		lineImageView.hidden = YES;
		if (!isReversed)
		{
			imageC = [cardContentDictionary objectForKey:@"qImage"];
			textC =  [cardContentDictionary objectForKey:@"question"];
			sound = [cardContentDictionary objectForKey:@"qSound"];
		}
		else {
			imageC = [cardContentDictionary objectForKey:@"aImage"];
			textC =  [cardContentDictionary objectForKey:@"answer"];
			sound = [cardContentDictionary objectForKey:@"aSound"];
		}
        
		
		questionLabel.hidden = YES;
		
		
	}
	else {
		//initialization for answer
		lineImageView.hidden = NO;
		if (!isReversed) {
			imageC = [cardContentDictionary objectForKey:@"aImage"];
			textC =  [cardContentDictionary objectForKey:@"answer"];
			sound = [cardContentDictionary objectForKey:@"aSound"];
			
			if (isBothSide && !imageC) {
				imageC = [cardContentDictionary objectForKey:@"qImage"];
			}
			
			if (isBothSide && !sound) {
				sound = [cardContentDictionary objectForKey:@"qSound"];
			}
			
		}
		else {
			imageC = [cardContentDictionary objectForKey:@"qImage"];
			textC =  [cardContentDictionary objectForKey:@"question"];
			sound = [cardContentDictionary objectForKey:@"qSound"];
			
			if (isBothSide && !imageC) {
				imageC = [cardContentDictionary objectForKey:@"aImage"];
			}
			
			if (isBothSide && !sound) {
				sound = [cardContentDictionary objectForKey:@"aSound"];
			}
			
		}
		
		NSString *question;
		
		if (!isReversed)
			question = [cardContentDictionary objectForKey:@"question"];
		else
			question = [cardContentDictionary objectForKey:@"answer"];
        
		questionLabel.hidden = NO;
		questionLabel.text = question;
	}
	
	if(imageC || sound)
	{
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
			([UIScreen mainScreen].scale == 2.0)) {
			// Retina display
			cardTextView.frame = CGRectMake((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth/2,
											kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-15,
											(IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth/2-5,
											kFCardHieght-(kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10)-5);
		}else {
			cardTextView.frame = CGRectMake((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth/2,
											kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10,
											(IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth/2-5,
											kFCardHieght-(kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10)-5);
		}
		cardTextView.textAlignment = NSTextAlignmentLeft;
	}
	else
	{
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
			([UIScreen mainScreen].scale == 2.0)) {
			// Retina display
			cardTextView.frame = CGRectMake(0,
											kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-15,
											(IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth-10,
											kFCardHieght-(kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10)-5);
		}else {
			cardTextView.frame = CGRectMake(0,
											kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10,
											(IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth-10,
											kFCardHieght-(kFICardBigLineHeight+kFICardSmallLineHeight+kFINormalLine/2-10)-5);
		}
        NSLog(@"TextView:-->%@",[cardTextView description]);
        [self updatetheCardTextAlignmenttoCenter];
		cardTextView.textAlignment = NSTextAlignmentCenter;
	}
	
	if (!imageC) {
		cardImageView.hidden = YES;
	}
	
	CGRect soundButtonFrame;
	
	if (textC && ![textC isEqualToString:@""]) {
		cardImageView.frame = CGRectMake(kFPicFrameLeftOffset+kFPicLeftOffset,
										 kFPicFrameTopOffset+kFPicTopOffset,
										 kFPicSmallWidth,
										 kFPicSmallHeight);
	}
	else {
		cardImageView.frame = CGRectMake(kFPicFrameLeftOffset+kFPicLeftOffset,
										 kFPicFrameTopOffset+kFPicTopOffset,
										 kFPicNormalWidth,
										 kFPicNormalHeight);
		cardTextView.hidden = YES;
	}
	
	
	if (imageC) {
		NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
		[attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
		[attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
		[attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
		[attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
		[attrib setObject:imageC forKey:@"image"];
		CGRect imageFrame = [self convertRect:[cardImageView changeAtributes:attrib] fromView:cardImageView];
        
		soundButtonFrame = CGRectMake(imageFrame.origin.x+imageFrame.size.width-30,
									  imageFrame.origin.y+imageFrame.size.height-30,
									  60,60);
		[soundButton setImage:[UIImage imageNamed:@"i_audio_small.png"] forState:UIControlStateNormal];
		[soundButton setImage:[UIImage imageNamed:@"i_audio_small.png"] forState:UIControlStateHighlighted];
		
        
	}else {
		if (textC && ![textC isEqualToString:@""]) {
			soundButtonFrame = CGRectMake(kFPicFrameLeftOffset+kFPicLeftOffset+10,
										  kFPicFrameTopOffset+10,
										  120,120);
			[soundButton setImage:[UIImage imageNamed:@"i_audio_medium.png"] forState:UIControlStateNormal];
			[soundButton setImage:[UIImage imageNamed:@"i_audio_medium.png"] forState:UIControlStateHighlighted];
		}else {
			soundButtonFrame = CGRectMake((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth/2-120,
										  (kFCardHieght+kFPicTopOffset)/2-95,
										  240,240);
			[soundButton setImage:[UIImage imageNamed:@"i_audio_large.png"] forState:UIControlStateNormal];
			[soundButton setImage:[UIImage imageNamed:@"i_audio_large.png"] forState:UIControlStateHighlighted];
		}
	}
	
	soundButton.frame = soundButtonFrame;
    
	if (sound) {
		audioPlayer = [[AVAudioPlayer alloc] initWithData:sound error:nil];
		[audioPlayer prepareToPlay];
	}else {
		soundButton.hidden = YES;
	}
    
	
	cardTextView.text = textC;
    
	
	if (cardTextView && [cardTextView.text length]>0) {
		NSRange range;
		range.location = 0;
		range.length = 1;
		[cardTextView scrollRangeToVisible:range];
	}
	
//	CGSize contentSz = cardTextView.contentSize;
    CGSize contentSz = [self measureHeightOfUITextView:cardTextView];

	CGSize frameSz = cardTextView.frame.size;
	
	if (frameSz.height<contentSz.height) {
		cardTextView.userInteractionEnabled = YES;
	}
	else {
		cardTextView.userInteractionEnabled = NO;
	}
	
    
	[pool release];
	
}
// Added by Nil ...
- (void)updatetheCardTextAlignmenttoCenter{
	UITextView *tv = cardTextView;
    
    //NSLog(@"Observer Value Called");
	//Center vertical alignment
    //	CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale]-[tv frame].origin.y)/2.0;
  
	CGFloat topCorrect = ([tv bounds].size.height - [tv sizeThatFits:tv.bounds.size].height * [tv zoomScale]-[tv frame].origin.y)/2.0;
    
   // NSLog(@"Top Correct Value : %f",topCorrect);
	topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
	tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

-(void)updateCardNumberLabel:(NSInteger)first forLast:(NSInteger)last
{
	if (last<=0) {
		cardNumberLabel.hidden = YES;
		allNumberLabel.hidden = YES;
		return;
	}else {
		cardNumberLabel.hidden = NO;
		allNumberLabel.hidden = NO;
	}
    
	
	if (first<10) {
		cardNumberLabel.frame = CGRectMake(0.0,0.0,14.0,30.0);
		allNumberLabel.frame = CGRectMake(14.0,0.0,60.0,32.0);
	}
	
	if (first>=10 && first<100) {
		cardNumberLabel.frame = CGRectMake(0.0,0.0,22.0,30.0);
		allNumberLabel.frame = CGRectMake(22.0,0.0,60.0,32.0);
	}
	
	if (first>=100 && first<1000) {
		cardNumberLabel.frame = CGRectMake(0.0,0.0,30.0,30.0);
		allNumberLabel.frame = CGRectMake(30.0,0.0,60.0,32.0);
	}
	
	if (first>=1000 && first<=10000) {
		cardNumberLabel.frame = CGRectMake(0.0,0.0,38.0,30.0);
		allNumberLabel.frame = CGRectMake(38.0,0.0,60.0,32.0);
	}
	
	cardNumberLabel.text = [NSString stringWithFormat:@"%d",first];
	allNumberLabel.text = [NSString stringWithFormat:@"/%d",last];
	
	
}

-(void)initIPadContent
{
	cardTextView = [[UITextView alloc] init];   // text view of description
	cardTextView.editable = NO;
	cardTextView.font = currentFont;
	cardTextView.clipsToBounds = YES;
	cardTextView.contentMode = UIViewContentModeScaleAspectFit;
	cardTextView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	cardTextView.backgroundColor = [UIColor clearColor];
	cardTextView.textColor = [UIColor darkTextColor];
	[cardTextView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
	
	cardImageView = [[FISketchedImageView alloc] initWithAtrributes:CGRectNull attr:nil];
    
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
	[cardImageView addGestureRecognizer:tap];
	[tap release];
	
	cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardLargeWidth,kFCardLargeHeight)];
	cardView.backgroundColor = [UIColor clearColor];
	
	//create shadow
	cardView.layer.shadowPath = [UIBezierPath bezierPathWithRect:cardView.bounds].CGPath;
	cardView.layer.shadowColor = [UIColor blackColor].CGColor;
	cardView.layer.shadowRadius = 20.0f;
	cardView.layer.shadowOpacity = 0.7f;
	
	
	if (isCheckBoxExist) {
		checkButton = [[FIBouncingView alloc] initWithImages:CGRectMake(kFCardLargeWidth-10-36,10,36,36)
												   forActive:[UIImage imageNamed:@"i_checkbox_2.png"]
											   forNoneActive:[UIImage imageNamed:@"i_checkbox_1.png"]
												 forDelegate:self];
	}
	
	cardNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,100.0,60.0)];
	cardNumberLabel.backgroundColor = [UIColor clearColor];
	cardNumberLabel.textAlignment = NSTextAlignmentRight;
	cardNumberLabel.textColor = [UIColor blackColor]; //count starting
	cardNumberLabel.font = [UIFont fontWithName:@"Helvetica" size:34];
	
	slashNumerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,9.0,60.0)]; //count divide by slash
	slashNumerLabel.textColor = [UIColor blackColor];
	slashNumerLabel.backgroundColor = [UIColor clearColor];
	slashNumerLabel.alpha = 0.5f;
	slashNumerLabel.font = [UIFont fontWithName:@"Helvetica" size:25];
	slashNumerLabel.text = @"/";
	
	allNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,50.0,30.0)];
	allNumberLabel.textColor = [UIColor blackColor];
	allNumberLabel.alpha = 0.5;
	allNumberLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	allNumberLabel.backgroundColor = [UIColor clearColor];
	
	
	questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0,73.0,588.0,45.0)];//15.0,77.0,588.0,60.0
	questionLabel.backgroundColor = [UIColor clearColor];
	questionLabel.textColor = [UIColor blackColor];
	questionLabel.font = currentFont;
	
	soundButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UITapGestureRecognizer *soundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audioButtonPressed:)];
	[soundButton addGestureRecognizer:soundTap];
	[soundTap release];
	
	[self addSubview:cardView];
	[self addSubview:cardTextView];
	[self addSubview:cardNumberLabel];
	[self addSubview:slashNumerLabel];
	[self addSubview:allNumberLabel];
	[self addSubview:questionLabel];
	[self addSubview:cardImageView];
	[self addSubview:soundButton];
	
	if (isCheckBoxExist) {
		[self addSubview:checkButton];
		[checkButton release];
	}
	
	[cardView release];
	[cardTextView release];
	[cardImageView release];
	[cardNumberLabel release];
	[slashNumerLabel release];
	[allNumberLabel release];
	[questionLabel release];
}

-(void)setIPadContent
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger cardNumber = [[cardContentDictionary objectForKey:@"number"] intValue];
	NSInteger allCardsNumber = [[cardContentDictionary objectForKey:@"allNumber"] intValue];
	NSData *sound;
	
	[self updateIPadCardNumberLabel:cardNumber forLast:allCardsNumber];
	
	NSString *textC = @"";
	UIImage *imageC = nil;
	cardTextView.hidden = NO;
	cardImageView.hidden = NO;
	soundButton.hidden = NO;
	
	if (audioPlayer) {
		if ([audioPlayer isPlaying]) {
			[audioPlayer stop];
		}
		[audioPlayer release];
		audioPlayer = nil;
	}
	
	if (isQuestion && !isBothSide) {
		
		//initialization for question
		cardView.image = [UIImage imageNamed:@"card_1.png"];
		if (!isReversed)
		{
			imageC = [cardContentDictionary objectForKey:@"qImage"];
			textC =  [cardContentDictionary objectForKey:@"question"];
			sound = [cardContentDictionary objectForKey:@"qSound"];
		}
		else {
			imageC = [cardContentDictionary objectForKey:@"aImage"];
			textC =  [cardContentDictionary objectForKey:@"answer"];
			sound = [cardContentDictionary objectForKey:@"aSound"];
		}
		
		
		questionLabel.hidden = YES;
		
		
	}
	else {
		//initialization for answer
		cardView.image = [UIImage imageNamed:@"card_2.png"];
		if (!isReversed) {
			imageC = [cardContentDictionary objectForKey:@"aImage"];
			textC =  [cardContentDictionary objectForKey:@"answer"];
			sound = [cardContentDictionary objectForKey:@"aSound"];
			
			if (isBothSide && !imageC) {
				imageC = [cardContentDictionary objectForKey:@"qImage"];
			}
			
			if (isBothSide && !sound) {
				sound = [cardContentDictionary objectForKey:@"qSound"];
			}
			
		}
		else {
			imageC = [cardContentDictionary objectForKey:@"qImage"];
			textC =  [cardContentDictionary objectForKey:@"question"];
			sound = [cardContentDictionary objectForKey:@"qSound"];
			
			if (isBothSide && !imageC) {
				imageC = [cardContentDictionary objectForKey:@"aImage"];
			}
			
			if (isBothSide && !sound) {
				sound = [cardContentDictionary objectForKey:@"aSound"];
			}
			
		}
		
		NSString *question;
		
		if (!isReversed)
			question = [cardContentDictionary objectForKey:@"question"];
		else
			question = [cardContentDictionary objectForKey:@"answer"];
		
		questionLabel.hidden = NO;
		questionLabel.text = question;
	}
	
	if(imageC || sound)
	{
		cardTextView.frame = CGRectMake(253,162,kFCardLargeWidth-263,kFCardLargeHeight-170);
		cardTextView.textAlignment = NSTextAlignmentLeft;
	}
	else
	{
		cardTextView.frame = CGRectMake(7,127,kFCardLargeWidth-14,kFCardLargeHeight-160);
		cardTextView.textAlignment = NSTextAlignmentCenter;
	}
	
	
	
	CGRect soundButtonFrame = CGRectNull;
	
	if (!textC || [textC isEqualToString:@""]) {
		cardImageView.frame = CGRectMake(28,164,582,290);
		if (imageC) {
			NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
            [attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
            [attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
            [attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
            [attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
            [attrib setObject:imageC forKey:@"image"];
            CGRect imageFrame = [self convertRect:[cardImageView changeAtributes:attrib] fromView:cardImageView];
            
			soundButtonFrame = CGRectMake(imageFrame.origin.x+imageFrame.size.width-45.0,
                                          imageFrame.origin.y+imageFrame.size.height-45.0,
                                          90.0,
                                          90.0);
			[soundButton setImage:[UIImage imageNamed:@"ip_audio_small.png"] forState:UIControlStateNormal];
		}else {
			soundButtonFrame = CGRectMake(kFCardLargeWidth/2-145,
										  kFCardLargeHeight/2-95,
										  290.0,
										  290.0);
			[soundButton setImage:[UIImage imageNamed:@"ip_audio_large.png"] forState:UIControlStateNormal];
		}
        
        
	}
	else {
		cardImageView.frame = CGRectMake(35,185,172,174);
        
		if (imageC) {
			NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
            [attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
            [attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
            [attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
            [attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
            [attrib setObject:imageC forKey:@"image"];
            CGRect imageFrame = [self convertRect:[cardImageView changeAtributes:attrib] fromView:cardImageView];
			soundButtonFrame = CGRectMake(imageFrame.origin.x+imageFrame.size.width-30,
										  imageFrame.origin.y+imageFrame.size.height-30,
										  60,60);
			[soundButton setImage:[UIImage imageNamed:@"i_audio_small.png"] forState:UIControlStateNormal];
		}else {
			soundButtonFrame = CGRectMake(45,
										  200,
										  172,172);
			[soundButton setImage:[UIImage imageNamed:@"ip_audio_medium.png"] forState:UIControlStateNormal];
		}
	}
	
	if (!imageC) {
		cardImageView.hidden = YES;
	}
    
    
	soundButton.frame = soundButtonFrame;
	soundButton.layer.shadowPath = [UIBezierPath bezierPathWithRect:soundButton.bounds].CGPath;
	soundButton.layer.shadowRadius = 10;
	soundButton.layer.shadowColor = [UIColor blackColor].CGColor;
    
	
	if (sound) {
		audioPlayer = [[AVAudioPlayer alloc] initWithData:sound error:nil];
		[audioPlayer prepareToPlay];
	}else {
		soundButton.hidden = YES;
	}
	
	
	//cardImageView.image = imageC;
    NSLog(@"Text value : %@",textC);
	cardTextView.text = textC;
	
	
	if (cardTextView && [cardTextView.text length]>0) {
		NSRange range;
		range.location = 0;
		range.length = 1;
		[cardTextView scrollRangeToVisible:range];
	}
	
//	CGSize contentSz = cardTextView.contentSize;
    CGSize contentSz = [self measureHeightOfUITextView:cardTextView];
	CGSize frameSz = cardTextView.frame.size;
	
	if (frameSz.height<contentSz.height) {
		cardTextView.userInteractionEnabled = YES;
	}
	else {
		cardTextView.userInteractionEnabled = NO;
	}
	
	
	[pool release];
}

-(void)updateIPadCardNumberLabel:(NSInteger)first forLast:(NSInteger)last
{
	if (last<=0) {
		cardNumberLabel.hidden = YES;
		slashNumerLabel.hidden = YES;
		allNumberLabel.hidden = YES;
		return;
	}else {
		cardNumberLabel.hidden = NO;
		slashNumerLabel.hidden = NO;
		allNumberLabel.hidden = NO;
	}
	
	if (first<10) {
		cardNumberLabel.frame = CGRectMake(-65,5,100,60);
		slashNumerLabel.frame = CGRectMake(35,9,9,60);
		allNumberLabel.frame = CGRectMake(44,27,50,30);
	}
	
	if (first>=10 && first<100) {
		cardNumberLabel.frame = CGRectMake(-48,5,100,60);
		slashNumerLabel.frame = CGRectMake(52,9,9,60);
		allNumberLabel.frame = CGRectMake(61,27,50,30);
	}
	
	if (first>=100 && first<1000) {
		cardNumberLabel.frame = CGRectMake(-30,5,100,60);
		slashNumerLabel.frame = CGRectMake(70,9,9,60);
		allNumberLabel.frame = CGRectMake(79,27,50,30);
	}
	
	if (first>=1000 && first<10000) {
		cardNumberLabel.frame = CGRectMake(-5,5,100,60);
		slashNumerLabel.frame = CGRectMake(95,9,9,60);
		allNumberLabel.frame = CGRectMake(104,27,50,30);
	}
	
	
	cardNumberLabel.text = [NSString stringWithFormat:@"%d",first];
	allNumberLabel.text = [NSString stringWithFormat:@"%d",last];
	
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	UITextView *tv = object;
    
   // NSLog(@"Observer Value Called");
	//Center vertical alignment
//	CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale]-[tv frame].origin.y)/2.0;
	CGFloat topCorrect = ([tv bounds].size.height - [tv sizeThatFits:tv.bounds.size].height * [tv zoomScale]-[tv frame].origin.y)/2.0;

    //NSLog(@"Top Correct Value : %f",topCorrect);
	topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
	tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}


#pragma mark -

- (void)dealloc {
	[cardTextView removeObserver:self forKeyPath:@"contentSize"];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"cardUpdateTextPosition"
												  object:nil];
	
	if (cardContentDictionary) {
		[cardContentDictionary release];
	}
	
	if (currentFont) {
		[currentFont release];
	}
	
	
	
	if (audioPlayer) {
		if ([audioPlayer isPlaying]) {
			[audioPlayer stop];
		}
		[audioPlayer release];
	}
	
    [super dealloc];
}


@end
