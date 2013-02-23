#import "PBPreferencePaneTemplateKeywordsController.h"

@implementation PBPreferencePaneTemplateKeywordsController

- (void) awakeFromNib
{
    NSTextFieldCell * tPrototypeCell = nil;
    NSTableColumn *tableColumn = nil;
    
    [IBkeywordsArray_ setIntercellSpacing:NSMakeSize(3,0)];
    
    // Key
    
    tableColumn = [IBkeywordsArray_ tableColumnWithIdentifier: @"Key"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
    
    // Value
    
    tableColumn = [IBkeywordsArray_ tableColumnWithIdentifier: @"Value"];
    tPrototypeCell = [tableColumn dataCell];
    [tPrototypeCell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    
    [super awakeFromNib];
}

- (id) init
{
    self=[super init];
    
    if (self!=nil)
    {
        // Register for Notifications
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(defaultsDidChanged:)
                                                     name:PBPREFERENCEPANE_TEMPLATEKEYWORDS_NOTIFICATION_DEFAULTS_DIDCHANGE
                                                   object:nil];
    }
    
    return self;
}

#pragma mark -

- (IBAction) changeDefaults:(id) sender
{
    // A COMPLETER
}

#pragma mark -

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [keysArray_ count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{    
    NSString * tKey;
    
    tKey=[keysArray_ objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString: @"Key"])
    {
        return tKey;
    }
    else
    if ([[aTableColumn identifier] isEqualToString: @"Value"])
    {
    	return [keywordsDictionary_ objectForKey:tKey];
    }
    
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if ([[tableColumn identifier] isEqualToString: @"Value"])
    {
        NSString * tKey;
        
        tKey=[keysArray_ objectAtIndex:row];
        
        [keywordsDictionary_ setObject:object forKey:tKey];
        
        [defaults_ setObject:keywordsDictionary_ forKey:@"Keywords"];
    }
}

#pragma mark -

- (void) updateWithDefaults
{
    NSDictionary * tDictionary;
    
    [keywordsDictionary_ release];
    
    tDictionary=[defaults_ dictionaryForKey:@"Keywords"];
    
    if (tDictionary!=nil)
    {
        keywordsDictionary_=[tDictionary mutableCopy];
    }
    else
    {
        keywordsDictionary_=[[NSMutableDictionary alloc] initWithCapacity:2];
        
        [keywordsDictionary_ setObject:@"My Great Company" forKey:@"COMPANY_NAME"];
        
        [keywordsDictionary_ setObject:@"com.mygreatcompany.pkg" forKey:@"COMPANY_PACKAGE_IDENTIFIER"];
        
        [defaults_ setObject:keywordsDictionary_ forKey:@"Keywords"];
    }
    
    [keysArray_ release];
    
    keysArray_=[[keywordsDictionary_ allKeys] mutableCopy];
    
    [keysArray_ sortUsingSelector:@selector(compare:)];
    
    [IBkeywordsArray_ reloadData];
}

@end
