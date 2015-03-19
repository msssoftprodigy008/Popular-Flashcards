//
//  FUpgradeManager.h
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol FUpgradeDelegate

-(void)upgradeFinished:(BOOL)result;

@end

@interface FUpgradeManager : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver> {

}
+(id)initWithDelegate:(id)Adelegate;
- (void)updateToDeluxe;
-(void)updateToDeluxeIphone;

@end
