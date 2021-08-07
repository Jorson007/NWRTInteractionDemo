//
//  NWDynamicShapeView.m
//  NWRTInteractionDemo
//
//  Created by kwni on 2021/8/7.
//

#import "NWDynamicShapeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NWDynamicShapeView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.type){
        case NWShapeViewType_Rect:
            [self drawRect:context color:[UIColor redColor]];
            break;
        case NWShapeViewType_Triangle:
            [self drawTriangle:context lineColor:[UIColor blueColor] fillColor:[UIColor blueColor] lineWidth:1];
            break;
        case NWShapeViewType_Circle:
            [self drawCircle:context fillcolor:[UIColor orangeColor] radius:2*M_PI];
            break;
    }
}


/*
 *画圆
 *context   当前上下文
 *fillColor 填充色
 *radius    弧度
 *point     圆心点坐标
 */
- (void)drawCircle:(CGContextRef)context
         fillcolor:(UIColor *)fillColor
            radius:(CGFloat)radius{
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextAddArc(context, self.bounds.size.width/2, self.bounds.size.width/2, self.bounds.size.width/2, 0, radius, 0);
    CGContextDrawPath(context, kCGPathFill);
}


/*
 *任意三角形
 *context       当前上下文
 *lineColor     边框颜色
 *fillColor     填充颜色
 *pointArr      三个点的坐标
 *lineWidth     边框宽度
 */
- (void)drawTriangle:(nullable CGContextRef)context
           lineColor:(nullable UIColor *)lineColor
           fillColor:(nullable UIColor *)fillColor
           lineWidth:(CGFloat)lineWidth {
    CGContextSaveGState(context);
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    CGPoint point = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
    CGPoint points[3];
    points[0] = CGPointMake(point.x, point.y-self.frame.size.height/2);
    points[1] = CGPointMake(point.x-self.frame.size.width/2, point.y+self.frame.size.height/2);
    points[2] = CGPointMake(point.x+self.frame.size.width/2, point.y+self.frame.size.height/2);
    
    CGContextAddLines(context, points, 3);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    CGContextRestoreGState(context);
}


/*
 ＊画矩形
 *context   当前上下文
 *color     填充色
 *rect      矩形位置的大小
 */
- (void)drawRect:(nullable CGContextRef)context
           color:(nullable UIColor*)color
{
    CGContextSetShouldAntialias(context, YES);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddRect(context, self.bounds);
    CGContextDrawPath(context, kCGPathFill);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];

    CGPoint currentPoint = [touch locationInView:self];
    // 获取上一个点
    CGPoint prePoint = [touch previousLocationInView:self];
    CGFloat offsetX = currentPoint.x - prePoint.x;
    CGFloat offsetY = currentPoint.y - prePoint.y;
    
    NSLog(@"FlyElephant----当前位置:%@---之前的位置:%@",NSStringFromCGPoint(currentPoint),NSStringFromCGPoint(prePoint));
    [self.delegate refreshShapeView:self.tag offsetX:offsetX offsetY:offsetY];
}


@end
