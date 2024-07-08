#include <objc/runtime.h>
#import "SpoofLocation.h"
#import "JoystickView.h"

%hook CLLocation
- (CLLocationCoordinate2D)coordinate {
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"joystick_x"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"joystick_y"];
    return CLLocationCoordinate2DMake(x, y);
}
%end

%hook UIApplication
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[JoystickView sharedInstance] toggleJoystick];
    }
    %orig(motion, event);
}
%end
