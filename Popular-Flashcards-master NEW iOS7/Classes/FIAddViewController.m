//
//  FIAddViewController.m
//  flashCards
//
//  Created by Ruslan on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIAddViewController.h"
#import "FRootConstants.h"
#import "FITemplateViewController.h"
#import "Util.h"
#import "Constant.h"
@interface FIAddViewController(Private)

#pragma mark targets
-(void)createSetPressed:(id)sender;
-(void)upgraded:(NSNotification*)sender;

@end

@implementation FIAddViewController
@synthesize delegate;

#pragma mark -
#pragma mark main

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
	UIView *contentView;
	if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }

                contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,286,195)];
            }
            else{
                contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,286,195)];
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }

                contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,242,195)];
            }
            else{
                contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,242,195)];
            }
        }
    }else {
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,200)];
	}
    
	self.view = contentView;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (![Util isPhone]) {
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
        [self.view addSubview:bgView];
        [bgView release];
    }
    
	
	[contentView release];
	
	UIButton *newSetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newSetButton.exclusiveTouch = YES;
	if ([Util isPhone]) {
		UIImage *newSetButtonImage = [UIImage imageNamed:@"i_newset_create1.png"];
		newSetButton.frame = CGRectMake(20,30,newSetButtonImage.size.width,newSetButtonImage.size.height);
		[newSetButton setImage:newSetButtonImage forState:UIControlStateNormal];
		[newSetButton setImage:[UIImage imageNamed:@"i_newset_create2.png"] forState:UIControlStateHighlighted];
	}else {
        UIImage *newSetButtonImage = [UIImage imageNamed:@"i_newset_create1.png"];
		newSetButton.frame = CGRectMake(50,20,newSetButtonImage.size.width,newSetButtonImage.size.height);
        [newSetButton setImage:newSetButtonImage forState:UIControlStateNormal];
		[newSetButton setImage:[UIImage imageNamed:@"i_newset_create2.png"] forState:UIControlStateHighlighted];
	}
    
	[self.view addSubview:newSetButton];
	
    if ([Util isPhone]) {
        if (delegate && [delegate respondsToSelector:@selector(addCategorySelected:)]) {
            [newSetButton addTarget:delegate
                             action:@selector(addCategorySelected:)
                   forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        [newSetButton addTarget:self
                         action:@selector(createSetPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    }
	
	if (![Util isPhone]) {
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,90,100,30)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.textColor = [UIColor darkGrayColor];
		headerLabel.shadowOffset = CGSizeMake(0,1);
		headerLabel.shadowColor = [UIColor whiteColor];
		headerLabel.font = [UIFont boldSystemFontOfSize:16];
		headerLabel.text = @"Import from:";
		[self.view addSubview:headerLabel];
		[headerLabel release];
	}
	
	if ([Util isPhone]) {
		itunesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        itunesButton.exclusiveTouch = YES;
		UIImage *itunesButtonImage = [UIImage imageNamed:@"i_newset_itunes1.png"];
		itunesButton.frame = CGRectMake(20,110,itunesButtonImage.size.width,itunesButtonImage.size.height);
		[itunesButton setImage:itunesButtonImage forState:UIControlStateNormal];
		[itunesButton setImage:[UIImage imageNamed:@"i_newset_itunes2.png"] forState:UIControlStateHighlighted];
		[self.view addSubview:itunesButton];
        
        if (![Util isFullVersion]) {
            itunesButton.hidden = YES;
        }
        
		if (delegate && [delegate respondsToSelector:@selector(itunesSelected:)]) {
			[itunesButton addTarget:delegate
							 action:@selector(itunesSelected:)
				   forControlEvents:UIControlEventTouchUpInside];
		}
	}
    
    
    quizletButton = [UIButton buttonWithType:UIButtonTypeCustom];
	quizletButton.exclusiveTouch = YES;
	if ([Util isPhone]) {
		UIImage *quizletButtonImage = [UIImage imageNamed:@"i_newset_quizlet1.png"];
		quizletButton.frame = CGRectMake(125,110,quizletButtonImage.size.width,quizletButtonImage.size.height);
        if (![Util isFullVersion]) {
            quizletButton.center = CGPointMake(self.view.frame.size.width/2.0, quizletButton.center.y);
        }
		[quizletButton setImage:quizletButtonImage forState:UIControlStateNormal];
		[quizletButton setImage:[UIImage imageNamed:@"i_newset_quizlet2.png"] forState:UIControlStateHighlighted];
	}else {
   		UIImage *quizletButtonImage = [UIImage imageNamed:@"ip_quizlet_itunes.png"];
		quizletButton.frame = CGRectMake(50,125,quizletButtonImage.size.width,quizletButtonImage.size.height);
		[quizletButton setImage:quizletButtonImage forState:UIControlStateNormal];
        [quizletButton setImage:[UIImage imageNamed:@"ip_quizlet_itunes2.png"] forState:UIControlStateHighlighted];
    }
	[self.view addSubview:quizletButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upgraded:)
                                                 name:@"upgraded"
                                               object:nil];
	
	if (delegate && [delegate respondsToSelector:@selector(quizletSelected:)]) {
		[quizletButton addTarget:delegate
						  action:@selector(quizletSelected:)
				forControlEvents:UIControlEventTouchUpInside];
	}
    
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -

#pragma mark -
#pragma mark targets

-(void)createSetPressed:(id)sender{
    FITemplateViewController *templateController = [[FITemplateViewController alloc] init];
    templateController.delegate = delegate;
    templateController.contentSizeForViewInPopover = CGSizeMake(((IS_IPHONE_5)?568:480), 300);
    [self.navigationController pushViewController:templateController animated:YES];
    [templateController release];
}

-(void)upgraded:(NSNotification*)sender{
    if ([Util isPhone]) {
        itunesButton.hidden = NO;
        quizletButton.frame = CGRectMake(125,110,quizletButton.frame.size.width,quizletButton.frame.size.height);
    }
}

#pragma mark -

@end
