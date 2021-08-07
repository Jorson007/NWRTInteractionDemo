//
//  NWDynamicShapeView.h
//  NWRTInteractionDemo
//
//  Created by kwni on 2021/8/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,NWShapeViewType){
    NWShapeViewType_Circle,
    NWShapeViewType_Triangle,
    NWShapeViewType_Rect,
};

@protocol NWRefreshViewOriginProtocal <NSObject>

-(void)refreshShapeView:(NSInteger)index offsetX:(CGFloat)x offsetY:(CGFloat)y;

@end

@interface NWDynamicShapeView : UIView

@property (nonatomic,assign) NWShapeViewType type;
@property (nonatomic,weak)   id<NWRefreshViewOriginProtocal> delegate;

@end

NS_ASSUME_NONNULL_END
