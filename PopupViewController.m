#import "PopupViewController.h"
#import "SpoofLocation.h"
#import "JoystickView.h"

@interface PopupViewController () <JoystickDelegate>
@property (nonatomic, strong) UISegmentedControl *modeControl;
@property (nonatomic, strong) UITextField *manualLatField;
@property (nonatomic, strong) UITextField *manualLonField;
@property (nonatomic, strong) JoystickView *joystickView;
@property (nonatomic, assign) BOOL isPopupVisible;
@property (nonatomic, assign) CGPoint currentLocation;
@end

@implementation PopupViewController

+ (instancetype)sharedInstance {
    static PopupViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    self.view.layer.cornerRadius = 10.0;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, self.view.bounds.size.width - 40, 30)];
    titleLabel.text = @"SuperPosition";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"Manual", @"Joystick"]];
    self.modeControl.frame = CGRectMake(20, 80, self.view.bounds.size.width - 40, 30);
    [self.modeControl addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    self.modeControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.modeControl];
    
    UILabel *manualLatLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 100, 30)];
    manualLatLabel.text = @"Latitude:";
    manualLatLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:manualLatLabel];
    
    self.manualLatField = [[UITextField alloc] initWithFrame:CGRectMake(120, 120, self.view.bounds.size.width - 140, 30)];
    self.manualLatField.borderStyle = UITextBorderStyleRoundedRect;
    self.manualLatField.keyboardType = UIKeyboardTypeDecimalPad;
    self.manualLatField.hidden = YES;
    [self.view addSubview:self.manualLatField];
    
    UILabel *manualLonLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 100, 30)];
    manualLonLabel.text = @"Longitude:";
    manualLonLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:manualLonLabel];
    
    self.manualLonField = [[UITextField alloc] initWithFrame:CGRectMake(120, 160, self.view.bounds.size.width - 140, 30)];
    self.manualLonField.borderStyle = UITextBorderStyleRoundedRect;
    self.manualLonField.keyboardType = UIKeyboardTypeDecimalPad;
    self.manualLonField.hidden = YES;
    [self.view addSubview:self.manualLonField];
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeSystem];
    setButton.frame = CGRectMake(20, 200, self.view.bounds.size.width - 40, 30);
    [setButton setTitle:@"Set Location" forState:UIControlStateNormal];
    [setButton addTarget:self action:@selector(setLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setButton];
    
    self.joystickView = [[JoystickView alloc] initWithFrame:CGRectMake(20, 240, self.view.bounds.size.width - 40, self.view.bounds.size.width - 40)];
    self.joystickView.hidden = YES;
    self.joystickView.delegate = self;
    [self.view addSubview:self.joystickView];

    self.currentLocation = CGPointZero;
}

- (void)togglePopup {
    self.isPopupVisible = !self.isPopupVisible;
    
    if (self.isPopupVisible) {
        UIWindow *keyWindow = [self getKeyWindow];
        [keyWindow addSubview:self.view];
        self.view.center = keyWindow.center;
        [self animatePopupIn];
    } else {
        [self animatePopupOut];
    }
}

- (void)animatePopupIn {
    self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.view.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformIdentity;
        self.view.alpha = 1;
    }];
}

- (void)animatePopupOut {
    [UIView animateWithDuration:0.2 animations:^{
        self.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
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

- (void)modeChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: // Off
            [[SpoofLocation sharedInstance] updateLocationWithX:0 y:0];
            self.manualLatField.hidden = YES;
            self.manualLonField.hidden = YES;
            self.joystickView.hidden = YES;
            break;
        case 1: // Manual
            self.manualLatField.hidden = NO;
            self.manualLonField.hidden = NO;
            self.joystickView.hidden = YES;
            break;
        case 2: // Joystick
            self.manualLatField.hidden = YES;
            self.manualLonField.hidden = YES;
            self.joystickView.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)setLocation {
    CGFloat lat = [self.manualLatField.text floatValue];
    CGFloat lon = [self.manualLonField.text floatValue];
    self.currentLocation = CGPointMake(lat, lon);
    [self.joystickView setCustomPosition:CGPointMake(0, 0)]; 
    [[SpoofLocation sharedInstance] updateLocationWithX:lat y:lon];
}

- (void)joystickDidUpdateWithX:(CGFloat)x y:(CGFloat)y {
    CGFloat speedFactor = 0.0001; 
    CGFloat dx = x * speedFactor;
    CGFloat dy = -y * speedFactor;
    
    self.currentLocation = CGPointMake(self.currentLocation.x + dx, self.currentLocation.y + dy);
    
    [[SpoofLocation sharedInstance] updateLocationWithX:self.currentLocation.x y:self.currentLocation.y];
}

@end
