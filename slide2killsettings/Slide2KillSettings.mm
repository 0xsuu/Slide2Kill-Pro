//#import <Preferences/Preferences.h>
#import "PSListController.h"

@interface Slide2KillSettingsListController: PSListController {
}
@end

@implementation Slide2KillSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Slide2KillSettings" target:self] retain];
	}
	return _specifiers;
}

- (void)followSina:(id)sender 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weibo.com/iamsuu"]];
}

- (void)followTwitter:(id)sender 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/al1en_Suu"]];
}

- (void)openBlog:(id)sender 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iamsuu.lofter.com"]];
}

- (void)watchDemo:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://v.youku.com/v_show/id_XNTY5NDYwOTQ0.html?x"]];
}

@end

// vim:ft=objc
