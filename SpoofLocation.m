#import "SpoofLocation.h"

@implementation SpoofLocation

+ (instancetype)sharedInstance {
    static SpoofLocation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _spoofedCoordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (void)updateLocationWithX:(CGFloat)x y:(CGFloat)y {
    NSLog(@"SuperPosition: Updating location with X: %f, Y: %f", x, y);
    self.spoofedCoordinate = CLLocationCoordinate2DMake(x, y);
    [[NSUserDefaults standardUserDefaults] setFloat:x forKey:@"joystick_x"];
    [[NSUserDefaults standardUserDefaults] setFloat:y forKey:@"joystick_y"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end