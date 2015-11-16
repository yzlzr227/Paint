//
//  PaintStep.h
//  Paint
//
//  Created by Zhuoran Li on 11/16/15.
//  Copyright © 2015 Zhuoran Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PaintStep : NSObject{
    @public
    NSMutableArray *pathPoints;
    
    CGColorRef color;
    
    float strokeWidth;
}

@end
