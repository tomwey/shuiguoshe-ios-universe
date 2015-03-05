//
//  ItemsViewController.m
//  shuiguoshe
//
//  Created by tomwey on 12/27/14.
//  Copyright (c) 2014 shuiguoshe. All rights reserved.
//

#import "ItemsViewController.h"

@interface ItemsViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ItemsViewController
{
    NSArray* _dataSource;
    int      _numberOfCols;
}

- (void)dealloc
{
    [_dataSource release];
    
    [super dealloc];
}

- (BOOL)shouldShowingCart { return YES; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.userData name];
        
    _numberOfCols = 2;
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainScreenBounds),
                                                                           CGRectGetHeight(mainScreenBounds) - NavigationBarAndStatusBarHeight())
                                                          style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    [tableView release];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.dataSource = self;
    tableView.delegate   = self;
    
    tableView.rowHeight = 240 + [self factorForDevice];
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    
    [[DataService sharedService] loadEntityForClass:@"Item"
                                                URI:[NSString stringWithFormat:@"/items/type-%ld", [self.userData cid]]
                                         completion:^(id result, BOOL succeed) {
                                             if ( succeed ) {
                                                 [_dataSource release];
                                                 _dataSource = [[NSArray alloc] initWithArray:result];
                                                 [tableView reloadData];
                                             } else {
                                                 
                                             }
                                         }];

}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self totalRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = [NSString stringWithFormat:@"cell%ld", indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if ( !cell ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self addItemViewForCell:cell atIndex: indexPath.row];
    
    return cell;
}

- (NSInteger)totalRows
{
    return ( [_dataSource count] + _numberOfCols - 1 ) / _numberOfCols;
}

- (void)addItemViewForCell:(UITableViewCell *)cell atIndex:(NSInteger)row
{
    NSInteger colCount = _numberOfCols;
    if ( [self totalRows] - 1 == row ) {
        colCount = [_dataSource count] - row * _numberOfCols;
    }
    
    CGFloat padding = 20;
    CGFloat width = ( CGRectGetWidth(mainScreenBounds) - _numberOfCols * padding - padding / 2 ) / _numberOfCols;
    
    for (int i=0; i<colCount; i++) {
        NSInteger index = row * _numberOfCols + i;
        
        ItemView* itemView = (ItemView *)[cell.contentView viewWithTag:100 + index];
        if ( !itemView ) {
            itemView = [[[ItemView alloc] init] autorelease];
            itemView.tag = 100 + index;
            [cell.contentView addSubview:itemView];
        }
        
        itemView.frame = CGRectMake(padding + (width + padding/2) * i,
                                    10, width, 230 + [self factorForDevice]);
        itemView.item = [_dataSource objectAtIndex:index];
    }
}

- (CGFloat)factorForDevice
{
    CGFloat factor = 0;
    if ( CGRectGetHeight(mainScreenBounds) > 568 ) {
        factor = 24;
    }
    
    if ( CGRectGetHeight(mainScreenBounds) > 667 ) {
        factor = 38;
    }
    
    return factor;
}

@end
