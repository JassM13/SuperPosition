#import "JoystickView.h"

@interface JoystickView ()
@property (nonatomic, strong) UIView *knobView;
@property (nonatomic, assign) CGFloat joystickRadius;
@property (nonatomic, assign) CGFloat knobRadius;
@end

@implementation JoystickView

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
    
    self.knobView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.knobRadius * 2, self.knobRadius * 2)];
    self.knobView.backgroundColor = [UIColor blueColor];
    self.knobView.layer.cornerRadius = self.knobRadius;
    self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
    [self addSubview:self.knobView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.knobView addGestureRecognizer:panGestureRecognizer];
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
    [self.delegate joystickDidUpdateWithX:xValue y:yValue];

    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
        } completion:^(BOOL finished) {
            [self.delegate joystickDidUpdateWithX:0 y:0];
        }];
    }
}

@end
