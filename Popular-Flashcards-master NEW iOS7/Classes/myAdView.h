#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"
#import <iAd/iAd.h>

#define kGADKey1 @"a14e61276c36c14" 
#define kGADKey2 @"a14e6104f80d17a"


@protocol myAdViewDelegate <NSObject>
@optional
-(void)iAdRecievedSuccessfully;
-(void)iAdFailed;

-(void)adMobRecievedSuccessfully;
-(void)adMobFailed;

-(void)gAdRecievedSuccessfully;
-(void)gAdFailed;

@end

@interface myAdView : UIView <ADBannerViewDelegate, GADBannerViewDelegate> {
	ADBannerView *adView;
	GADBannerView *gadView;
	
	////////////////////////
	UIViewController* ViewController;
	CGSize bannerSize;
	
	NSTimer *sharedTimer;
    id<myAdViewDelegate> _delegate;
}
- (id)initWithFrame:(CGRect)frame delegate:(id<myAdViewDelegate>) delegate;
- (void)tryiAd:(NSString*)iAdType;
- (void)tryGAD:(CGSize)gadSize;

-(void)showInView:(UIView*)view animated:(BOOL)animated;
-(void)hide:(BOOL)animated;
-(void)clearAdv;

@property (nonatomic,assign)UIViewController* ViewController;
@property (nonatomic,assign)id<myAdViewDelegate> _delegate;
@end
