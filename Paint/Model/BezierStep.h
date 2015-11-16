//
//  BezierStep.h
//  Paint
//
//  Created by Zhuoran Li on 11/16/15.
//  Copyright © 2015 Zhuoran Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    BezierStepStatusSetStart,
    BezierStepStatusSetEnd,
    BezierStepStatusSetControl
}BezierStepStatus;

@interface BezierStep : NSObject{
    @public
    CGPoint startPoint;
    CGPoint controlPoint;
    CGPoint endPoint;

    CGColorRef color;

    float strokeWidth;

    BezierStepStatus status;
}
@end
