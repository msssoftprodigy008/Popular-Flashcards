//
//  UINavigationController+Orientation.m
//  flashCards
//
//  Created by Sanjeevareddy Nandela on 3/12/15.
//
//

#import "UINavigationController+Orientation.h"


@implementation UINavigationController (Orientation)


- (NSUInteger) supportedInterfaceOrientations{ // working changed by sanjeev reddy
    return UIInterfaceOrientationMaskLandscape;
}


@end


//-(NSUInteger)supportedInterfaceOrientations
//{
//    return [self.topViewController supportedInterfaceOrientations];
//}
//
//-(BOOL)shouldAutorotate
//{
//   // self.appDelegate = [[UIApplication sharedApplication] delegate];
//
////[UIApplication sharedApplication];
//
////    if(self.window.rootViewController){
////    }
////    else
//        if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) return YES;
//    else return NO;
//}