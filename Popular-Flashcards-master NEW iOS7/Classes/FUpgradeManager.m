//
//  FUpgradeManager.m
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FUpgradeManager.h"
#import "UIDevice-Reachability.h"
#import "Util.h"
#import "ModalAlert.h"

#define PRODUCT_ID @"com.adssg.flashcards.upgradedeluxe"

FUpgradeManager *sharedUpgrade = nil;
id delegate = nil;

@implementation FUpgradeManager

+(id)initWithDelegate:(id)Adelegate
{
	if (!sharedUpgrade) {
		sharedUpgrade = [[FUpgradeManager alloc] init];
	}
	
	delegate = Adelegate;
	return sharedUpgrade;
}



/////////////////////////////////////////////////

//
//- (void)makePurchase{
//    //call this when you would like to begin the purchase
//    //like when the user taps the "purchase" button
//    NSLog(@"User requests to make purchase");
//    
//    if([SKPaymentQueue canMakePayments]){
//        NSLog(@"User can make payments");
//        
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
//        productsRequest.delegate = self;
//        [productsRequest start];
//        
//    }
//    else{
//        //the user is not allowed to make payments
//        NSLog(@"User cannot make payments due to parental controls");
//    }
//}
//
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    SKProduct *validProduct = nil;
//    int count = [response.products count];
//    if(count > 0){
//        validProduct = [response.products objectAtIndex:0];
//        NSLog(@"Products Available!");
//        [self purchase:validProduct];
//        
//    }
//    else if(!validProduct){
//        NSLog(@"No products available");
//    }
//}
//
//- (IBAction)purchase:(SKProduct *)product{
//    SKPayment *payment = [SKPayment paymentWithProduct:product];
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}









/////////////////////////////////////////////////////





- (void)checkForPreviewer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//	NSString *currentUDID = [[UIDevice currentDevice] uniqueIdentifier];
    
    NSString* currentUDID = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) { // >=iOS 7
        currentUDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else { //<=iOS6, Use UDID of Device
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
        currentUDID = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
        CFRelease(uuid);
    }

    
	printf("UIID %s\n", [currentUDID cStringUsingEncoding:1]);
	BOOL result = NO;
	
	#if TARGET_IPHONE_SIMULATOR
		result = YES;
	#else
		
		if ([currentUDID isEqualToString:@"A77D2BE0-B042-57B3-BD6E-A1419501C6C0"] || 
			[currentUDID isEqualToString:@"5b5d95d17a506b2c119bba387acde90584867e0b"] || [currentUDID isEqualToString:@"dea77422efabae61aa6ab12feb53aed465c84449"]) {
			result = YES;
		}else {
			
			NSData *tmpData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://s3.amazonaws.com/adssg-global-iphone-files/reviewers.db"]];
			NSString *fileString = [NSString stringWithCString:[tmpData bytes] encoding:NSUTF8StringEncoding];
			NSArray *UDIDsArray = [fileString componentsSeparatedByString:@"*"];
			for (int i=0; i<[UDIDsArray count]; i++) {
				NSString *tmpUDID = [UDIDsArray objectAtIndex:i];
				tmpUDID = [tmpUDID stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				if ([tmpUDID isEqualToString:currentUDID]) {
					result = YES;
					break;
				}
			}
			
		}
	#endif
	
	if (result) {
		
		[Util showMessage:@"Purchase" forMessage:@"Thank you for your purchase" forButtonTitle:@"OK"];
		
		[Util buyVersion];
		
		if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
			[delegate upgradeFinished:YES];
		}
		
	} else {
		if ([SKPaymentQueue canMakePayments]) {
			SKProductsRequest *preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
			preq.delegate = self;
			[preq start];
            
            //[self makePurchase];
		} else {
			
			[Util showMessage:@"Purchase" forMessage:@"Sorry, but Purchases are disabled. Turn on purchases to upgrade" forButtonTitle:@"OK"];
			
			if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
				[delegate upgradeFinished:NO];
			}
		}
	}
	[pool release];
}

- (void)updateToDeluxe {
	if ([Util isFullVersion]) {
		if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
			[delegate upgradeFinished:YES];
		}
		return;
	}
	[self performSelectorInBackground:@selector(checkForPreviewer) withObject:nil];
}

-(void)updateToDeluxeIphone
{
	if ([Util isFullVersion]) {
		if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
			[delegate upgradeFinished:YES];
		}
		return;
	}
	[self performSelectorInBackground:@selector(checkForPreviewer) withObject:nil];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
}

- (void)requestDidFinish:(SKRequest *)request {
	// Release the request
	[request release];
}

- (void) repurchase {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	SKProduct *product = [[response products] lastObject];
	if (!product)
	{
		[Util showMessage:@"Response"
			   forMessage:@"Error retrieving product information from App Store. Sorry! Please try again later."
		   forButtonTitle:@"OK"];
		if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
			[delegate upgradeFinished:NO];
		}
		return;
	}
	
    
  
    
	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	[numberFormatter release];
	
	// Create a description that gives a heads up about 
	// a non-consumable purchase
	NSString *buyString = formattedString; 
	NSString *describeString = [NSString stringWithFormat:@"%@\n\nIf you have already purchased this item, you will not be charged again.", product.localizedDescription];
	NSArray *buttons = [NSArray arrayWithObject: buyString];
	
	 //Offer the user a choice to buy or not buy
	UIAlertView *askAlert = [[UIAlertView alloc] initWithTitle:@"Purchase"
													   message:describeString
													  delegate:self
											 cancelButtonTitle:@"No Thanks"
											 otherButtonTitles:buyString,nil];
	[askAlert show];
	[askAlert release];
    
    
    
}

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex != [alertView cancelButtonIndex]) {
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID];
        
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}else {
		// restore the GUI to provide a buy/purchase button
		// or otherwise to a ready-to-buy state
		if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
			[delegate upgradeFinished:NO];
		}
	}

}

#pragma mark -

#pragma mark payments
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    
    

}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction {
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	[Util buyVersion];
	
	if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
		[delegate upgradeFinished:YES];
	}
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled) {
		[Util showMessage:@"Transaction failed"
			   forMessage:[NSString stringWithString:[transaction.error localizedDescription]]
		   forButtonTitle:@"OK"];
	}
	
	if (delegate && [delegate respondsToSelector:@selector(upgradeFinished:)]) {
		[delegate upgradeFinished:NO];
	}
	
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions 
{
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased: 
			case SKPaymentTransactionStateRestored: 
				[self completedPurchaseTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed: 
				[self handleFailedTransaction:transaction]; 
				break;
			default: 
				break;
		}
	}
}


@end
