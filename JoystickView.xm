#import "JoystickView.h"
#import "SpoofLocation.h"
#import <UIKit/UIKit.h>

@interface JoystickView ()
@property (nonatomic, strong) UIView *knobView;
@property (nonatomic, assign) CGFloat joystickRadius;
@property (nonatomic, assign) CGFloat knobRadius;
@property (nonatomic, assign) BOOL isJoystickVisible;
@end

@implementation JoystickView

+ (instancetype)sharedInstance {
    static JoystickView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        [sharedInstance setup];
    });
    return sharedInstance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.joystickRadius = self.bounds.size.width / 2;
    self.knobRadius = 30.0;
    self.isJoystickVisible = NO;
    
    self.knobView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.knobRadius * 2, self.knobRadius * 2)];
    self.knobView.backgroundColor = [UIColor blueColor];
    self.knobView.layer.cornerRadius = self.knobRadius;
    self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
    [self addSubview:self.knobView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.knobView addGestureRecognizer:panGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)toggleJoystick {
    self.isJoystickVisible = !self.isJoystickVisible;
    self.hidden = !self.isJoystickVisible;
    if (self.isJoystickVisible) {
        UIWindow *keyWindow = [self getKeyWindow];
        [keyWindow addSubview:self];
        self.center = keyWindow.center;
    } else {
        [self removeFromSuperview];
    }
}

- (UIWindow *)getKeyWindow {
    for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
        if (windowScene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *window in windowScene.windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return nil;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    CGFloat newX = self.knobView.center.x + translation.x;
    CGFloat newY = self.knobView.center.y + translation.y;

    CGFloat distance = sqrt(pow(newX - self.joystickRadius, 2) + pow(newY - self.joystickRadius, 2));
    if (distance > self.joystickRadius) {
        CGFloat angle = atan2(newY - self.joystickRadius, newX - self.joystickRadius);
        newX = self.joystickRadius + self.joystickRadius * cos(angle);
        newY = self.joystickRadius + self.joystickRadius * sin(angle);
    }

    self.knobView.center = CGPointMake(newX, newY);
    [sender setTranslation:CGPointZero inView:self];

    CGFloat xValue = (newX - self.joystickRadius) / self.joystickRadius;
    CGFloat yValue = (newY - self.joystickRadius) / self.joystickRadius;
    [[SpoofLocation sharedInstance] updateLocationWithX:xValue y:yValue];

    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
        } completion:^(BOOL finished) {
            [[SpoofLocation sharedInstance] updateLocationWithX:0 y:0];
        }];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // Reset joystick position when app becomes active
    self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
}

@end
