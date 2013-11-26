//Slide2Kill - Tweak.xm
//version: 1.3
//Author: Suu

#import "SBIconView.h"
#import "SBAppSwitcherController.h"
#import "SBAppSwitcherBarView.h"
#import "SBIcon.h"
#import "SBUIController.h"
//#import "UIScrollView.h"

SBIconView *onIcon;
UIScrollView *switcherScrollView;
BOOL isDragging = NO;
BOOL killIcon = NO;
BOOL killAll = NO;
BOOL killAllIcons = NO;

CGPoint touchLocation2;

#define isIPad ([[UIScreen mainScreen] bounds].size.height >= 1023)

@interface SBApplicationIcon : NSObject
- (SBApplication *)application;
@end
@interface SBIconModel : NSObject
- (SBApplicationIcon *)applicationIconForDisplayIdentifier:(NSString *)identifier;
@end
@interface SBIconViewMap : NSObject
+ (id)switcherMap;
- (SBIconModel *)iconModel;
@end
@interface SpringBoard : UIApplication
- (SBApplication *)nowPlayingApp;
@end
@interface UISwipeGestureRecognizer : NSObject
-(void)setDirection:(int)dir;
-(id)initWithTarget:(id)target action:(SEL)action;
@end
/*@interface UIScrollView : UIView
-(void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;
@end*/

bool isAppPage;

%hook SBAppSwitcherController

-(void)iconTouchBegan:(id)icon
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	onIcon = icon;
    
	UISwipeGestureRecognizer *recognizer; 
	
	recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(setSlideLeftOrRight:)] autorelease]; 
	[recognizer setDirection:1]; 
	[onIcon addGestureRecognizer:recognizer]; 
	
	recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(setSlideLeftOrRight:)] autorelease]; 
	[recognizer setDirection:2]; 
	[onIcon addGestureRecognizer:recognizer]; 
	
	%orig;
    }
    else
    {
	%orig;
    }
    
    [dict release];
    
}

%new(v:@)
-(void)setSlideLeftOrRight:(UISwipeGestureRecognizer *)recognizer
{
    isAppPage = NO;
    //[switcherScrollView scrollRectToVisible:CGRectMake(switcherScrollView.frame.origin.x + [[UIScreen mainScreen] bounds].size.width,switcherScrollView.frame.origin.y,switcherScrollView.frame.size.width,switcherScrollView.frame.size.height) animated:YES];
    [switcherScrollView setPagingEnabled:YES];
    [UIView beginAnimations:@"ToggleViews" context:nil];
    [UIView setAnimationDuration:0.3];
    switcherScrollView.frame = CGRectMake(switcherScrollView.frame.origin.x/* + [[UIScreen mainScreen] bounds].size.width*/,switcherScrollView.frame.origin.y,switcherScrollView.frame.size.width*0,switcherScrollView.frame.size.height);
    [UIView commitAnimations];
    /*
    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];
    SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");
    [barView scrollViewDidScroll:switcherScrollView];
    [self appSwitcherBar:barView pageAtIndexDidAppear:0];*/
}

-(void)iconHandleLongPress:(id)press
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	
    }
    else
    {
	%orig;
    }
    
    [dict release];
}

-(void)_beginEditing
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	
    }
    else
    {
	%orig;
    }
    
    [dict release];
}

-(void)appSwitcherBar:(id)bar pageAtIndexDidAppear:(int)pageAtIndex
{
    %orig;
    if (pageAtIndex >= 0) isAppPage = true;
    else isAppPage = false;
}

/*-(BOOL)iconViewDisplaysBadges:(id)badges
{
    return !isAppPage;
}*/

// iOS 5.x
- (NSArray *)_applicationIconsExceptTopApp
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if(([[dict objectForKey:@"Enabled"] boolValue]) && ([[dict objectForKey:@"inactiveAppsShow"] intValue] != 2))
    {
	NSMutableArray *runningApps = [NSMutableArray array];

	for (SBIconView *iconView in %orig) 
	{
	    if ([iconView.icon application].process.isRunning)
	    {
		iconView.alpha = 1;
		[runningApps addObject:iconView];
	    }
	    else
	    {
		if ([[dict objectForKey:@"inactiveAppsShow"] intValue] == 0)
		{
		    iconView.alpha = 0.5;
		    [runningApps addObject:iconView];
		}
	    }		     
	}
	return runningApps;
    }
    else
    {
	return %orig;
    }
}

// iOS 6.x
- (NSArray *)_bundleIdentifiersForViewDisplay
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if(([[dict objectForKey:@"Enabled"] boolValue]) && ([[dict objectForKey:@"inactiveAppsShow"] intValue] != 2))
    {
	NSMutableArray *runningApps = [NSMutableArray array];
	SBIconModel *iconModel = [[%c(SBIconViewMap) switcherMap] iconModel];
	for (NSString *identifier in %orig) 
	{
	    SBApplicationIcon *icon = [iconModel applicationIconForDisplayIdentifier:identifier];
	
	    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];

	    SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

	    SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];

	    if ([[icon application] isRunning])
	    {
		iconView.alpha = 1;
		[runningApps addObject:identifier];
	    }
	    else
	    {
		if ([[dict objectForKey:@"inactiveAppsShow"] intValue] == 0)
		{
		    iconView.alpha = 0.5;
		    [runningApps addObject:identifier];
		}
	    }
	}
	return runningApps;
    }
    else
    {
	return %orig;
    }

    [dict release];
}

%end

%hook SBAppSwitcherBarView

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    %orig;
    //NSLog(@"%[testb]:%@",scrollView);
    switcherScrollView = scrollView;
}

%end

%hook SBAppSwitcherScrollView

-(BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    %orig;
    BOOL temp = !isAppPage;
    //return %orig;
    return temp;
}

%end;

CGPoint touchLocation;

%hook SBIconView

- (BOOL)iconPositionIsEditable:(id)arg1 
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	return YES;
    }
    else
    {
	return %orig;
    }
    
    [dict release];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	UITouch *touch = [[event allTouches] anyObject]; 
	touchLocation = [touch locationInView:self]; 
	if (!onIcon) %orig;
    }
    else
    {
	%orig;
    }
    
    [dict release];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	if (onIcon) 
	{ 
	    float iconPos;

	    if isIPad iconPos = 17; 
	    else iconPos = 16;

	    isDragging = YES; 
	    UITouch *touch = [touches anyObject];
	    touchLocation2 = [touch locationInView:self];

	    //switcherScrollView.frame = CGRectMake(switcherScrollView.frame.origin.x + touchLocation2.x - touchLocation.x,switcherScrollView.frame.origin.y,switcherScrollView.frame.size.width,switcherScrollView.frame.size.height);
	    
	    if ([[dict objectForKey:@"SlideDownAct"] intValue] != 3)
	    {

		if (onIcon.frame.origin.y + touchLocation2.y - touchLocation.y > iconPos) 
		{
		    if ([[dict objectForKey:@"SlideDownAct"] intValue] == 1)
		    {
			onIcon.frame = CGRectMake(onIcon.frame.origin.x,onIcon.frame.origin.y + touchLocation2.y - touchLocation.y,onIcon.frame.size.width,onIcon.frame.size.height); 
			//onIcon.alpha = (100 - onIcon.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
			//onIcon.transform = CGAffineTransformMakeRotation(3.14/3);
			//[onIcon setTransform:CGAffineTransformMakeRotation(2*3.14 - 2*3.14*(100 - onIcon.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos))];
		    }

		    if ([[dict objectForKey:@"SlideDownAct"] intValue] == 0)
		    {
			SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];

			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
			{
			    NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay];
	    
			    SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

			    for (NSString *identifier in identifiers) 
			    {
				SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
				SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];

				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y + touchLocation2.y - touchLocation.y,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = (100 - iconView.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
				}
			    }
			}
			else
			{
			    NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
			    for (SBIconView *iconView in icons) 
			    {
				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y + touchLocation2.y - touchLocation.y,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = (100 - iconView.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
				}
			    }
			}
		    }
		}
	   }

	   if ([[dict objectForKey:@"SlideUpAct"] intValue] != 3)   
	   { 
		if (onIcon.frame.origin.y + touchLocation2.y - touchLocation.y < iconPos) 
		{
		    if ([[dict objectForKey:@"SlideUpAct"] intValue] == 1)
		    {
			onIcon.frame = CGRectMake(onIcon.frame.origin.x,onIcon.frame.origin.y + touchLocation2.y - touchLocation.y,onIcon.frame.size.width,onIcon.frame.size.height); 
			//onIcon.alpha = (100 - onIcon.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
		    }

		    if ([[dict objectForKey:@"SlideUpAct"] intValue] == 0)
		    {
			SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];
    
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
			{
			    NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay];
	      
			    SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

			    for (NSString *identifier in identifiers) 
			    {
				SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
				SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];

				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y + touchLocation2.y - touchLocation.y,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = (100 - iconView.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
				}
			    }
			}
			else
			{
			    NSArray *icons = [switcher _applicationIconsExceptTopApp];
		      
			    for (SBIconView *iconView in icons) 
			    {
				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconView.frame.origin.y + touchLocation2.y - touchLocation.y,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = (100 - iconView.frame.origin.y + touchLocation2.y - touchLocation.y)/(100 - iconPos); 
				}
			    }
			}
		    }
		}
	    }
	    
	    float senseDown = [[dict objectForKey:@"SlideDownSen"] floatValue];
	    float senseUp = [[dict objectForKey:@"SlideUpSen"] floatValue];

	    if (onIcon.frame.origin.y > senseDown + iconPos) 
	    { 
		if ([[dict objectForKey:@"SlideDownAct"] intValue] == 0) killAllIcons = YES;
		if ([[dict objectForKey:@"SlideDownAct"] intValue] == 1) 
		{
		    killIcon = YES;
		    killAllIcons = NO;
		}
	    } 

	    if (onIcon.frame.origin.y < -senseUp + iconPos)
	    {
		if ([[dict objectForKey:@"SlideUpAct"] intValue] == 0) killAllIcons = YES;
		if ([[dict objectForKey:@"SlideUpAct"] intValue] == 1)
		{
		    killIcon = YES;
		    killAllIcons = NO;
		}
	    }
	    
	} 
	else 
	{ 
	    %orig; 
	}
    }
    else
    {
	%orig;
    }
    
    [dict release];
    
}

-(void)touchesEnded:(id)ended withEvent:(id)event
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	if (!onIcon)
	{
	    %orig;
	}
	else
	{
	    float iconPos;
	    if isIPad iconPos = 17; 
	    else iconPos = 16;

	    if ((onIcon.frame.origin.y == iconPos) && (!killAll))
	    {
		%orig;
	    
	    }
	    else
	    {
	    
		if (!killIcon)
		{
		    if (!killAllIcons)
		    {
			onIcon.frame = CGRectMake(onIcon.frame.origin.x,iconPos,onIcon.frame.size.width,onIcon.frame.size.height);
			//onIcon.alpha = 1.0f;
		    }
		}
		else
		{
		
		    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];	 
		    if (onIcon) 	   
			[switcher iconCloseBoxTapped:onIcon];
		    killIcon = NO;
		}

		SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];
      
		NSString *nowPlayingAppID = [[(SpringBoard *)[UIApplication sharedApplication] nowPlayingApp] bundleIdentifier];

		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
		{
		    NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay]; 	   
		    SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

		    if (!killAllIcons)
		    {
			if (!killIcon)
			{
			    for (NSString *identifier in identifiers) 
			    {
				SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
				SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];
  
				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = 1.0f; 
				}
			    }
			}
		    }
		    else
		    {
			for (NSString *identifier in identifiers) 
			{
			    SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
			    SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];
  
			    if (iconView) 
			    {
				if (![[[icon application] bundleIdentifier] isEqualToString:nowPlayingAppID])
				    [switcher iconCloseBoxTapped:iconView];
			    }
			    iconView = nil;
			}
			SBUIController *uiCont = [%c(SBUIController) sharedInstance];			    
			[uiCont dismissSwitcherAnimated:YES]; 
		    }
		}
		else
		{
		    if (!killAllIcons)
		    {
			if (!killIcon)
			{
			    NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
			    for (SBIconView *iconView in icons) 
			    {
				if (iconView) 
				{
				    iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
				    //iconView.alpha = 1.0f; 
				}
			    }
			}		    
		    }
		    else
		    {
			NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
			for (SBIconView *iconView in icons) 
			{
			    if (iconView) 
			    {
				[switcher iconCloseBoxTapped:iconView];
			    }
			}
			SBUIController *uiCont = [%c(SBUIController) sharedInstance];			    
			[uiCont dismissSwitcherAnimated:YES]; 
		    }
		}
		killAllIcons = NO;
		killAll = NO;
	    }
	    onIcon = nil;	 
	}
	isDragging = NO;
    }
    else
    {
	%orig;
    }
    
    [dict release];
    
}

-(void)touchesCancelled:(id)cancelled withEvent:(id)event
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	if (!onIcon)
	{
	    %orig;
	}
	else
	{
	    float iconPos;
	    if isIPad iconPos = 17; 
	    else iconPos = 16;

	    
	    onIcon.frame = CGRectMake(onIcon.frame.origin.x,iconPos,onIcon.frame.size.width,onIcon.frame.size.height);
	    //onIcon.alpha = 1.0f;
	    

	    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];

	    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
	    {
		NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay];
	    
		SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

		for (NSString *identifier in identifiers) 
		{
		    SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
		    SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];

		    if ((iconView) && (iconView != onIcon)) 
		    {
			
			iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
			//iconView.alpha = 1.0f; 
			
		    }
		}
	    }
	    else
	    {
		NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
		for (SBIconView *iconView in icons) 
		{
		    if ((iconView) && (iconView != onIcon)) 
		    {
			  
			iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
			//iconView.alpha = 1.0f; 
			
		    }
		}
	    }
	    onIcon = nil;
	    isDragging = NO;
	}
	%orig;
    }
    else
    {
	%orig;
    }
    killAll = NO;
    [dict release];
    
}

-(void)cancelLongPressTimer
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	if (!onIcon)
	{
	    %orig;
	}
	
    }
    else
    {
	%orig;
    }
    
    [dict release];
    
}

-(void)longPressTimerFired
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.suu.slide2killsettings.plist"];

    if([[dict objectForKey:@"Enabled"] boolValue])
    {
	if (!onIcon)
	{
	    %orig;
	}
	else
	{
	    if (1)
	    {
		if (!isDragging)
		{
		    /*
		    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];

		    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
		    {
			NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay];
	    
			SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

			for (NSString *identifier in identifiers) 
			{
			    SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
			    SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];
 
			    if ((iconView) && (iconView != onIcon)) 
			    {
				[switcher iconCloseBoxTapped:iconView];
			    }
			    iconView = nil;
			}
		    }
		    else
		    {
			NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
			for (SBIconView *iconView in icons) 
			{
			    if ((iconView) && (iconView != onIcon)) 
			    {
				 [switcher iconCloseBoxTapped:iconView];
			    }
			    iconView = nil;
			}
		    }
		    killAll = YES;
		    if ([[dict objectForKey:@"LongPressAct"] intValue] == 1) killIcon = NO;
		    if ([[dict objectForKey:@"LongPressAct"] intValue] == 0) 
		    {
			 killIcon = YES;
			 SBUIController *uiCont = [%c(SBUIController) sharedInstance];			     
			 [uiCont dismissSwitcherAnimated:YES]; 
		    }
		    */
		}
		else
		{
		    float iconPos;
		    if isIPad iconPos = 17; 
		    else iconPos = 16;

		    [UIView beginAnimations:@"ToggleViews" context:nil];
		    [UIView setAnimationDuration:0.3];
		    onIcon.frame = CGRectMake(onIcon.frame.origin.x,iconPos,onIcon.frame.size.width,onIcon.frame.size.height);
		    //onIcon.alpha = 1.0f;
		    [UIView commitAnimations];
		    [onIcon resignFirstResponder];
		    SBAppSwitcherController *switcher = [%c(SBAppSwitcherController) sharedInstance];

		    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
		    {
			NSArray *identifiers = [switcher _bundleIdentifiersForViewDisplay];
	    
			SBAppSwitcherBarView *barView = MSHookIvar<SBAppSwitcherBarView *>(switcher, "_bottomBar");

			for (NSString *identifier in identifiers) 
			{
			    SBIcon *icon = [barView _iconForDisplayIdentifier:identifier];
			    SBIconView *iconView = [barView _iconViewForIcon:icon creatingIfNecessary:YES];

			    if ((iconView) && (iconView != onIcon)) 
			    {
				[UIView beginAnimations:@"ToggleViews" context:nil];
				[UIView setAnimationDuration:0.3];
				iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
				//iconView.alpha = 1.0f; 
				[UIView commitAnimations];
			    }
			}
		    }
		    else
		    {
			NSArray *icons = [switcher _applicationIconsExceptTopApp];
		    
			for (SBIconView *iconView in icons) 
			{
			    if ((iconView) && (iconView != onIcon)) 
			    {
				[UIView beginAnimations:@"ToggleViews" context:nil];
				[UIView setAnimationDuration:0.3];
				iconView.frame = CGRectMake(iconView.frame.origin.x,iconPos,iconView.frame.size.width,iconView.frame.size.height);
				//iconView.alpha = 1.0f; 
				[UIView commitAnimations];
			    }
			}
		    }
		    onIcon = nil;
		    isDragging = NO;
		    killAll = NO;
		}
		killAll = NO;
	    }		 
	}
    }
    else
    {
	%orig;
    }
    
    [dict release];
    killAll = NO;
}

%end