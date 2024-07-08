#import <CoreLocation/CoreLocation.h>

@interface SpoofLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

+ (instancetype)sharedInstance;
- (CLLocationCoordinate2D)currentLocation;
- (void)updateLocationWithX:(CGFloat)x y:(CGFloat)y;

@end
