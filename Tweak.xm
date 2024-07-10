#import <UIKit/UIKit.h>
#import "SpoofLocation.h"
#import "PopupViewController.h"

%hook CLLocation
- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D originalCoordinate = %orig;
    CLLocationCoordinate2D spoofedCoordinate = [[SpoofLocation sharedInstance] spoofedCoordinate];
    
    if (CLLocationCoordinate2DIsValid(spoofedCoordinate)) {
        return spoofedCoordinate;
    } else {
        return originalCoordinate;
    }
}
%end

// Hook UIApplication to detect shake events
%hook UIApplication
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[PopupViewController sharedInstance] togglePopup];
    }
    %orig(motion, event);
}
%end