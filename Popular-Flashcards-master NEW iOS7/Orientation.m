//
//  Orientation.m
//  flashCards
//
//  Created by Sanjeevareddy Nandela on 3/11/15.
//
//

#import "Orientation.h"

@implementation Orientation

-(BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


@end
