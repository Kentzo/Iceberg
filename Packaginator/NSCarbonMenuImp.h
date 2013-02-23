#import <Cocoa/Cocoa.h>

@interface NSCarbonMenuImpl:NSObject
{
    NSMenu * _menu;
}

- (void)setMenu:(NSMenu *) inMenu;

- (void)popUpMenu:(NSMenu *) inMenu atLocation:(NSPoint) inPoint width:(float) inWidth forView:(id) inView withSelectedItem:(int) index withFont: (NSFont *) inFont;


@end
