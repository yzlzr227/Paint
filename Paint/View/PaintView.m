//
//  PaintView.m
//  Paint
//
//  Created by Zhuoran Li on 11/16/15.
//  Copyright © 2015 Zhuoran Li. All rights reserved.
//

#import "PaintView.h"

typedef enum{
    PaintViewModeStroke,
    PaintViewModeBezier
}PaintViewMode;

#define width [UIScreen mainScreen].bounds.size.width
#define height [UIScreen mainScreen].bounds.size.height


@implementation PaintView{
    NSMutableArray *paintSteps;
    
    UIColor *curColor;
    
    UISlider *slider;
    
    PaintViewMode paintViewMode;
    
    NSMutableArray *bezierSteps;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self paintViewInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self paintViewInit];
    }
    return self;
}

-(void)paintViewInit{
    self.backgroundColor = [UIColor whiteColor];
    
    paintSteps = [[NSMutableArray alloc] init];
    
    bezierSteps = [[NSMutableArray alloc] init];
    
    [self createColorBoard];
    
    [self createStrokeWidthSlider];
}

-(void)createColorBoard{
    curColor = [UIColor blackColor];
    
    UIView *colorBoardView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, width, 20)];
    [self addSubview:colorBoardView];
    
    colorBoardView.layer.borderWidth = 1;
    colorBoardView.layer.borderColor = [UIColor blackColor].CGColor;
    
    NSArray *colors = [NSArray arrayWithObjects:
                       [UIColor blackColor],
                       [UIColor redColor],
                       [UIColor blueColor],
                       [UIColor greenColor],
                       [UIColor yellowColor],
                       [UIColor brownColor],
                       [UIColor orangeColor],
                       [UIColor whiteColor],
                       [UIColor orangeColor],
                       [UIColor purpleColor],
                       [UIColor cyanColor],
                       [UIColor lightGrayColor],nil];
    for (int i = 0; i < colors.count; i++){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((width / colors.count) * i, 0, width/colors.count, 20)];
        [colorBoardView addSubview:button];
        [button setBackgroundColor:colors[i]];
        [button addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)createControlBoard{
    paintViewMode = PaintViewModeStroke;
    
    UIView *controlBoard = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 60, height - 50)];
    [self addSubview:controlBoard];
    NSMutableArray *boards = [[NSMutableArray alloc]init];
    
    UIButton *bezierButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bezierButton setBackgroundColor:[UIColor greenColor]];
    [bezierButton addTarget:self action:@selector(bezierButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [boards addObject:bezierButton];
    
    int vertical = 20;
    int horizontal = 10;
    int buttonWH = 60;
    for (int i = 0; i < boards.count; i++){
        UIButton *button = boards[i];
        button.frame = CGRectMake(horizontal, (i + 1) * vertical, buttonWH, buttonWH);
        [controlBoard addSubview:button];
    }
}

-(void)changeColor:(id) target{
    UIButton *button = (UIButton *)target;
    curColor = [button backgroundColor];
}

-(void)createStrokeWidthSlider{
    slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 50, width, 20)];
    slider.maximumValue = 20;
    slider.minimumValue = 1;
    [self addSubview:slider];
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i < paintSteps.count;i++){
        PaintStep *step = paintSteps[i];
        NSMutableArray *pathPoints = step->pathPoints;
        CGMutablePathRef path = CGPathCreateMutable();
        for (int j = 0; j < pathPoints.count; j++){
            CGPoint point = [[pathPoints objectAtIndex:j]CGPointValue];
            if (j == 0){
                CGPathMoveToPoint(path, &CGAffineTransformIdentity, point.x, point.y);
            }else{
                CGPathAddLineToPoint(path, &CGAffineTransformIdentity, point.x, point.y);
            }
        }
        CGContextSetStrokeColorWithColor(ctx, step->color);
        CGContextSetLineWidth(ctx, step->strokeWidth);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    }
    
    for (int i = 0; i < bezierSteps.count; i++){
        BezierStep *step = bezierSteps[i];
        CGContextSetStrokeColorWithColor(ctx, step->color);
        CGContextSetLineWidth(ctx, step->strokeWidth);
        
        CGContextMoveToPoint(ctx, step->startPoint.x, step->startPoint.y);
        CGContextAddQuadCurveToPoint(ctx, step->controlPoint.x, step->controlPoint.y, step->endPoint.x, step->endPoint.y);
        CGContextStrokePath(ctx);
        
        switch (step->status) {
            case BezierStepStatusSetControl:
            {
                CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.233 green:0.48 blue:0.858 alpha:1.0].CGColor);
                CGFloat lengths[] = {10,10};
                CGContextSetLineDash(ctx, 1, lengths, 2);
                CGContextMoveToPoint(ctx, step->startPoint.x, step->startPoint.y);
                CGContextAddLineToPoint(ctx, step->controlPoint.x, step->controlPoint.y);
                CGContextAddLineToPoint(ctx, step->endPoint.x, step->endPoint.y);
                CGContextStrokePath(ctx);
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    switch (paintViewMode) {
        case PaintViewModeStroke:
            [self strokeModeTouchBegin:touches withEvent:event];
            break;
        case PaintViewModeBezier:
            [self bezierModeTouchesBegin:touches withEvent:event];
            break;
        default:
            break;
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    switch (paintViewMode) {
        case PaintViewModeStroke:
            [self strokeModeTouchMove:touches withEvent:event];
            break;
        case PaintViewModeBezier:
            [self strokeModeTouchMove:touches withEvent:event];
            break;
        default:
            break;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    switch (paintViewMode) {
        case PaintViewModeStroke:
            [self strokeModeTouchEnd:touches withEvent:event];
            break;
        case PaintViewModeBezier:
            [self bezierModeTouchEnd:touches withEvent:event];
        default:
            break;
    }
}

-(void)strokeModeTouchBegin:(NSSet *)touches withEvent: (UIEvent *)event{
    PaintStep *paintStep = [[PaintStep alloc] init];
    paintStep->color = curColor.CGColor;
    paintStep->pathPoints = [[NSMutableArray alloc] init];
    paintStep->strokeWidth = slider.value;
    [paintSteps addObject:paintStep];
}

-(void)strokeModeTouchMove:(NSSet *)touches withEvent:(UIEvent *)event{
    PaintStep *step = [paintSteps lastObject];
    NSMutableArray *pathPoints = step->pathPoints;
    
    CGPoint movePoint = [[touches anyObject] locationInView:self];
    NSLog(@"touchesMoved x: %f, y:%f", movePoint.x, movePoint.y);
    [pathPoints addObject:[NSValue valueWithCGPoint:movePoint]];
    [self setNeedsDisplay];
}

-(void)strokeModeTouchEnd:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

-(void)bezierModeTouchesBegin:(NSSet *)touches withEvent:(UIEvent *)event{
    BezierStep *step = [bezierSteps lastObject];
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if (step){
        switch (step->status) {
            case BezierStepStatusSetStart:
            {
                step->endPoint = point;
                step->status = BezierStepStatusSetControl;
            }
                break;
            case BezierStepStatusSetControl:
            {
                step = [[BezierStep alloc] init];
                step->color = curColor.CGColor;
                step->strokeWidth = slider.value;
                [bezierSteps addObject:step];
            }
                break;
            default:
                break;
        }
    }else{
        step = [[BezierStep alloc] init];
        step->color = curColor.CGColor;
        step->strokeWidth = slider.value;
        [bezierSteps addObject: step];
    }
}

-(void)bezierModeTouchMove: (NSSet *)touches withEvent: (UIEvent *)event{
    BezierStep *step = [bezierSteps lastObject];
    CGPoint point = [[touches anyObject] locationInView:self];
    
    switch (step->status) {
        case BezierStepStatusSetControl:
        {
            step->controlPoint = point;
        }
            break;
            
        default:
            break;
    }
    [self setNeedsDisplay];
}

-(void)bezierModeTouchEnd:(NSSet *)touches withEvent: (UIEvent *)event{
    BezierStep *step = [bezierSteps lastObject];
    CGPoint point = [[touches anyObject] locationInView:self];
    switch (step->status) {
        case BezierStepStatusSetStart:
        {
            step->startPoint = point;
        }
            break;
        case BezierStepStatusSetControl:
        {
            step->controlPoint = point;
            step->status = BezierStepStatusSetEnd;
        }
            break;
        default:
            break;
    }
}


-(void)bezierButtonClick:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (paintViewMode == PaintViewModeStroke){
        paintViewMode = PaintViewModeBezier;
        [button setBackgroundColor:[UIColor darkGrayColor]];
    }else{
        paintViewMode = PaintViewModeStroke;
        [button setBackgroundColor:[UIColor lightGrayColor]];
    }
}























/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
