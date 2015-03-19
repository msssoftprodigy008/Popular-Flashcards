//
//  NonRotatingUIImagePickerController.m
//  flashCards
//
//  Created by Sanjeevareddy Nandela on 3/9/15.
//
//

#import "NonRotatingUIImagePickerController.h"

@implementation NonRotatingUIImagePickerController


- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}

//- (NSUInteger)supportedInterfaceOrientations {
//    
//    // ATTENTION! Only return orientation MASK values
//    // return UIInterfaceOrientationPortrait;
//    
//    return UIInterfaceOrientationMaskPortrait;
//}


//- (NSUInteger)supportedInterfaceOrientations{
//  return  [super supportedInterfaceOrientations];
//}

@end
