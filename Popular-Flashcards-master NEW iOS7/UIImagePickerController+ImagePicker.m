//
//  UIImagePickerController+ImagePicker.m
//  flashCards
//
//  Created by Sanjeevareddy Nandela on 3/2/15.
//
//

#import "UIImagePickerController+ImagePicker.h"

@implementation UIImagePickerController (ImagePicker)


-(BOOL)shouldAutorotate{
    return NO;
    
    
}
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |   UIInterfaceOrientationMaskLandscapeRight;
//}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
