//
//  WLMainFrameController+FullScreen.m
//  Welly
//
//  Created by KOed on 13-3-26.
//  Copyright (c) 2013年 Welly Group. All rights reserved.
//

#define NSLOG_Rect(rect) NSLog(@#rect ": (%f, %f) %f x %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLOG_Size(size) NSLog(@#size ": %f x %f", size.width, size.height)
#define NSLog_Point(point) NSLog(@#point ": (%f, %f)", point.x, point.y)

#import "WLMainFrameController.h"
#import "WLMainFrameController+FullScreen.h"
#import "WLGlobalConfig.h"
#import "WLTabView.h"

@implementation WLMainFrameController (FullScreen)

- (BOOL)isInFullScreenMode {
	return ([_mainWindow styleMask] & NSFullScreenWindowMask) ? YES : NO;
}

+ (NSDictionary *)sizeParametersForZoomRatio:(CGFloat)zoomRatio {
	WLGlobalConfig *gConfig = [WLGlobalConfig sharedInstance];
    return @{WLCellWidthKeyName:@(floor([gConfig cellWidth] * zoomRatio)),
             WLCellHeightKeyName:@(floor([gConfig cellHeight] * zoomRatio)),
             WLChineseFontSizeKeyName:@(floor([gConfig chineseFontSize] * zoomRatio)),
             WLEnglishFontSizeKeyName:@(floor([gConfig englishFontSize] * zoomRatio))};
}

// Set and reset font size
- (void)setFont:(CGFloat)zoomRatio {
	WLGlobalConfig *gConfig = [WLGlobalConfig sharedInstance];
	// Decide whether to set or to reset the font size
	if (zoomRatio) {
		// Store old parameters
		_originalSizeParameters = [[gConfig sizeParameters] copy];
		
		// And do it..
		[gConfig setSizeParameters:[WLMainFrameController sizeParametersForZoomRatio:zoomRatio]];
	} else {
		// Restore old parameters
		[gConfig setSizeParameters:_originalSizeParameters];
		_originalSizeParameters = nil;
	}
}

- (NSApplicationPresentationOptions)window:(NSWindow *)window
	  willUseFullScreenPresentationOptions:(NSApplicationPresentationOptions)proposedOptions {
    // customize our appearance when entering full screen:
    // we don't want the dock to appear but we want the menubar to hide/show automatically
    // we also want the toolbar to hide/show automatically
    return (NSApplicationPresentationFullScreen |       // support full screen for this window (required)
            NSApplicationPresentationHideDock |         // completely hide the dock
            NSApplicationPresentationAutoHideMenuBar |  // yes we want the menu bar to show/hide
			NSApplicationPresentationAutoHideToolbar);	// we want the toolbar to show/hide
}

- (NSSize)window:(NSWindow *)window willUseFullScreenContentSize:(NSSize)proposedSize {
	return proposedSize;
}


- (void)windowWillEnterFullScreen:(NSNotification *)notification {
    self.tabBarView.hidden = YES;
		
	// Back up the original frame of _targetView
	NSRect originalFrame = self.tabView.frame;
	
	// Get the fittest ratio for the expansion
	NSRect screenRect = [[NSScreen mainScreen] frame];
	CGFloat ratioH = screenRect.size.height / originalFrame.size.height;
	CGFloat ratioW = screenRect.size.width / originalFrame.size.width;
	CGFloat screenRatio = (ratioH > ratioW) ? ratioW : ratioH;
	
    NSLog(@"will enter %f %f", ratioH, ratioW);
	// Then, do the expansion
	[self setFont:screenRatio];
	
	// Set the window style
	[_mainWindow setOpaque:YES];
	// Back up original bg color
	_originalWindowBackgroundColor = [_mainWindow backgroundColor];
	// Now set to bg color of the tab view to ensure consistency
	[_mainWindow setBackgroundColor:[[WLGlobalConfig sharedInstance] colorBG]];
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
    self.tabBarView.hidden = NO;
	// Set the size back
	[self setFont:0];
	[_mainWindow setOpaque:NO];
    [_mainWindow setBackgroundColor:_originalWindowBackgroundColor];
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
}

@end
