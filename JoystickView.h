#import <UIKit/UIKit.h>

@protocol JoystickDelegate <NSObject>
- (void)joystickDidUpdateWithX:(CGFloat)x y:(CGFloat)y;
@end

@interface JoystickView : UIView
@property (nonatomic, unsafe_unretained) id<JoystickDelegate> delegate;
+ (instancetype)sharedInstance;
- (void)toggleJoystick;
@end
