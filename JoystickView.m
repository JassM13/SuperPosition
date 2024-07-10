#import "JoystickView.h"

@interface JoystickView ()

@property (nonatomic, strong) UIView *knobView;
@property (nonatomic, strong) UIView *baseView;
@property (nonatomic, assign) CGFloat joystickRadius;
@property (nonatomic, assign) CGFloat knobRadius;
@property (nonatomic, assign) CGPoint lastPosition;

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
    
    self.baseView = [[UIView alloc] initWithFrame:self.bounds];
    self.baseView.backgroundColor = [UIColor lightGrayColor];
    self.baseView.layer.cornerRadius = self.joystickRadius;
    self.baseView.alpha = 0.5;
    [self addSubview:self.baseView];
    
    self.knobView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.knobRadius * 2, self.knobRadius * 2)];
    self.knobView.backgroundColor = [UIColor blueColor];
    self.knobView.layer.cornerRadius = self.knobRadius;
    self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
    [self addSubview:self.knobView];
    
    self.lastPosition = CGPointZero;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint touchLocation = [sender locationInView:self];
    
    CGFloat dx = touchLocation.x - self.joystickRadius;
    CGFloat dy = touchLocation.y - self.joystickRadius;
    CGFloat distance = sqrt(dx*dx + dy*dy);
    
    if (distance > self.joystickRadius) {
        dx = dx * self.joystickRadius / distance;
        dy = dy * self.joystickRadius / distance;
    }
    
    CGPoint newCenter = CGPointMake(self.joystickRadius + dx, self.joystickRadius + dy);
    self.knobView.center = newCenter;
    
    CGFloat xValue = dx / self.joystickRadius;
    CGFloat yValue = dy / self.joystickRadius;
    
    self.lastPosition = CGPointMake(xValue, yValue);
    [self.delegate joystickDidUpdateWithX:xValue y:yValue];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.knobView.center = CGPointMake(self.joystickRadius, self.joystickRadius);
        } completion:^(BOOL finished) {
            self.lastPosition = CGPointZero;
            [self.delegate joystickDidUpdateWithX:0 y:0];
        }];
    }
}

- (void)setCustomPosition:(CGPoint)position {
    CGFloat dx = position.x * self.joystickRadius;
    CGFloat dy = position.y * self.joystickRadius;
    
    CGPoint newCenter = CGPointMake(self.joystickRadius + dx, self.joystickRadius + dy);
    self.knobView.center = newCenter;
    self.lastPosition = position;
    
    [self.delegate joystickDidUpdateWithX:position.x y:position.y];
}

@end