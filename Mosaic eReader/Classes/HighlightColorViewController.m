//
//  HighlightColorViewController.m
//  Mosaic eReader
//
//  Created by Gregory Casamento on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HighlightColorViewController.h"
#import "ColorCell.h"
#import "PublicationViewController.h"

static NSString *CellIdentifier = @"ColorCell";

@implementation HighlightColorViewController

@synthesize publicationViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        colors = [[NSArray alloc] initWithObjects: 
                  @"Green", @"Blue", @"Red", @"Yellow", @"Stop", @"Clear All", nil];
    }
    return self;
}

- (void)dealloc
{
    [colors release];  
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Delegate methods....

- (ColorCell *) _dequeueCustomCell: (UITableView *)tv
{
	ColorCell *cell = (ColorCell *) [tv dequeueReusableCellWithIdentifier: CellIdentifier];
	if(cell == nil) 
	{
		NSArray *topLevelObjects = nil;
		topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"ColorCell"
														owner: nil 
													  options: nil];
		
		
		for(id currentObject in topLevelObjects)
		{
			if([currentObject isKindOfClass: [UITableViewCell class]])
			{
				cell = (ColorCell *) currentObject;
				break;
			}
		}
	}
	return cell;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	return [NSString stringWithFormat: @"Colors"];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [colors count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	ColorCell *cell = [self _dequeueCustomCell:tv];
	NSUInteger index = [indexPath indexAtPosition: 1];
    NSString *color = [colors objectAtIndex: index];    
	cell.colorName.text = color;
    if([color isEqualToString: @"Clear All"])
    {
        color = @"Eraser";
    }
    cell.colorView.image = [UIImage imageNamed: color]; 

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// NSUInteger index = [indexPath indexAtPosition: 1];
	// NSString *color = [colors objectAtIndex: index];
	// [publicationViewController colorForHighlight: color];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	return 50;
}
@end
