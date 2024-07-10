#import <UIKit/UIKit.h>

@interface PopupViewController : UIViewController

+ (instancetype)sharedInstance;
- (void)togglePopup;

@end