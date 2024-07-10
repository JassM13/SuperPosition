#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SpoofLocation : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D spoofedCoordinate;

+ (instancetype)sharedInstance;
- (void)updateLocationWithX:(CGFloat)x y:(CGFloat)y;

@end