    //
//  FILearningController.m
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FILearningController.h"
#import "FDBController.h"
#import "Util.h"
#import "DBTime.h"

@interface  FILearningController(Private)

- (NSInteger) updateCurrDifficForRating: (NSInteger) rating forDiff:(NSInteger)currDiffic;
- (NSInteger) updateCurrIntervalForRating: (NSInteger) rating forInt:(NSInteger)currInterval forDiff:(NSInteger)currDiffic;

@end


@implementation FILearningController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id)initWithCategory:(NSString*)Acategory forType:(FILearningProccesType)type
{
	if (Acategory) {
		category = [[NSString alloc] initWithString:Acategory];
	}
	
	right = 0;
	wrong = 0;
	notSure = 0;
	
	learnType = type;
	return [self init];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}


-(NSArray*)learningArray
{
	NSArray *learnArray = nil;
	
	if (category)
	{
		if (learnType == FILearningProccesTypeTest) 
			learnArray = [[FDBController sharedDatabase] getTestListForCategory:category];
	}
	
	return learnArray;
}

-(NSDictionary*)statisticForSession
{
	NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:wrong],[NSNumber numberWithInt:notSure],[NSNumber numberWithInt:right],nil]
													forKeys:[NSArray arrayWithObjects:@"wrong",@"notSure",@"right",nil]];
	return dic;
}

-(NSInteger)updateAnswer:(NSInteger)cardId forAnswer:(NSInteger)result
{
	NSInteger updateAfter = 0;
	
	switch (result) {
		case 0:
			wrong++;
			break;
		case 1:
			notSure++;
			break;
		case 2:
			right++;
			break;
		default:
			break;
	}
	
	NSMutableArray *statistic = [[FDBController sharedDatabase] getStatistic:category forIndex:cardId];
	NSInteger currentInterval = [[statistic objectAtIndex:0] intValue];
	NSInteger currentDiff = [[statistic objectAtIndex:1] intValue];
	NSInteger currentRecall = [[statistic objectAtIndex:2] intValue];
	NSInteger currentLapses = [[statistic objectAtIndex:3] intValue];
	currentDiff = [self updateCurrDifficForRating:result forDiff:currentDiff];
	NSInteger session = [[FDBController sharedDatabase] sessionForSet:category];
    NSInteger drill = 0;
        
	switch (result) {
        case 0:
            currentRecall = session+1;
            break;
        case 1:
			currentRecall = session+2;
			break;
		case 2:
            drill = 1;
            break;
        default:
            break;
    }
        
        
	NSMutableArray *updateArray = [NSMutableArray arrayWithObjects: [NSString stringWithFormat:@"%d",currentInterval],
									   [NSString stringWithFormat:@"%d",currentDiff],
									   [NSString stringWithFormat:@"%d",currentRecall],
									   [NSString stringWithFormat:@"%d",currentLapses],
									   [NSString stringWithFormat:@"%d",0],
									   [NSString stringWithFormat:@"%d",0],		
									   [NSString stringWithFormat:@"%d",drill],nil];
		[[FDBController sharedDatabase] updateStatistic:updateArray forCategory:category forIndex:cardId];
		[statistic release];
	
	return updateAfter;
}

-(void)updateCurrentInterval:(NSInteger)cardId
{
	
}

-(NSInteger)getIntervalForAnswer:(NSInteger)result
{
	switch (result) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 0;
			break;
	
		default:
			break;
	}
	
	return 0;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark private

- (NSInteger) updateCurrDifficForRating: (NSInteger) rating forDiff:(NSInteger)currDiffic
{
	NSInteger newDiff;
	CGFloat oldDif = currDiffic/10.0f;
	
	oldDif = oldDif-0.05*rating*rating+0.35*rating-0.3;
	
    if (oldDif < 1.3) oldDif = 1.3;
    if (oldDif > 2.5) oldDif = 2.5;
	
	newDiff = oldDif*10;
	return newDiff;
}

- (NSInteger) updateCurrIntervalForRating: (NSInteger) rating forInt:(NSInteger)currInterval forDiff:(NSInteger)currDiffic
{
	NSInteger newInterval;
	CGFloat diff = currDiffic/10.0;
	if(currInterval<=1)
	{
		newInterval = 2;
		return newInterval;
	}
	
	if(rating==0)
	{
		newInterval = [Util	roundValue:1.5];
		return newInterval;
	}
	
	newInterval = [Util roundValue:((CGFloat)(currInterval))*diff];
	
	if (newInterval>6) {
		newInterval = 6;
	}
	
    return newInterval;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	if (category) {
		[category release];
	}
	
    [super dealloc];
}


@end
