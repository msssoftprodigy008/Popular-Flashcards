//
//  FIImageUtilits.h
//  flashCards
//
//  Created by Ruslan on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FIImageUtilits : NSObject {

}

+(UIImage*)createImageFromScreen:(CGRect)rect forLayer:(CALayer*)layer;
+(UIImage*)roundedImage:(UIImage*)image forRadius:(CGFloat)radius;

@end
