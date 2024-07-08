#import "SpoofLocation.h"

@implementation SpoofLocation

+ (instancetype)sharedInstance {
    static SpoofLocation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance setupLocationManager];
    });
    return sharedInstance;
}

- (void)setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (CLLocationCoordinate2D)currentLocation {
    CGFloat x = [[NSUserDefaults standardUserDefaults] floatForKey:@"joystick_x"];
    CGFloat y = [[NSUserDefaults standardUserDefaults] floatForKey:@"joystick_y"];
    return CLLocationCoordinate2DMake(x, y);
}

- (void)updateLocationWithX:(CGFloat)x y:(CGFloat)y {
    [[NSUserDefaults standardUserDefaults] setFloat:x forKey:@"joystick_x"];
    [[NSUserDefaults standardUserDefaults] setFloat:y forKey:@"joystick_y"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:x longitude:y];
    [self.locationManager.delegate locationManager:self.locationManager didUpdateLocations:@[newLocation]];
}

@end
