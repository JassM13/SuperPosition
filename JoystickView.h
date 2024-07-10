#import <UIKit/UIKit.h>

@protocol JoystickDelegate <NSObject>
- (void)joystickDidUpdateWithX:(CGFloat)x y:(CGFloat)y;
@end

@interface JoystickView : UIView

@property (nonatomic, weak) id<JoystickDelegate> delegate;

@end
