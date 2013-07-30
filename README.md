# NagKit

I generally don't like when apps ask me to rate them, but if it must, it might as well do it right.

## Installation

CocoaPods:

    $ echo "pod 'NagKit'" >> Podfile
    $ gem install cocoapods
    $ pod install

Or you can just add the `NagKit` folder to your Xcode project.

## Usage

NagKit automatically tracks application launch events on your behalf. Just set a threshold for `NAGControllerApplicationLaunchEventName` and it will do the rest.

Set event thresholds:

    [[NAGController sharedController] setThreshold:10 forEvent:NAGControllerApplicationLaunchEventName];
    [[NAGController sharedController] setThreshold:10 forEvent:@"UserMashedThisButton"];

Fire events:

    [[NAGController sharedController] pushEvent:@"UserMashedThisButton"];

Implement `NAGControllerDelegate`:

    - (void)controller:(NAGController *)controller willShowAlert:(UIAlertView *)alert {
        alert.title = NSLocalizedString(@"NAG_USER_ALERT_TITLE", nil);
        alert.message = NSLocalizedString(@"NAG_USER_ALERT_MESSAGE", nil);
        alert.cancelButtonIndex = [alert addButtonWithTitle:NSLocalizedString(@"NAG_USER_ALERT_NO_THANKS", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"NAG_USER_ALERT_SURE", nil)];
    }
    
    - (BOOL)controllerShouldShowAlert:(BOOL)controller {
        return ([self isLoggedIn] && [self isReachable]);
    }
    
    - (BOOL)controller:(NAGController *)controller shouldIncrementCountForEvent:(NSString *)name {
        return [self isLoggedIn];
    }

Maybe do reachability stuff:

    - (void)reachabilityDidChange {
        [[NAGController sharedController] showAlertIfNeeded];
    }

## License

Released under the MIT license. Don't bug your users too much.
