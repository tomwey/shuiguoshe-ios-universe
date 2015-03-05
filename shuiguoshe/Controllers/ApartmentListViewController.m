//
//  ApartmentListViewController.m
//  shuiguoshe
//
//  Created by tomwey on 3/1/15.
//  Copyright (c) 2015 shuiguoshe. All rights reserved.
//

#import "ApartmentListViewController.h"
#import "Defines.h"

@interface ApartmentListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation ApartmentListViewController
{
    NSMutableArray* _dataSource;
    UITableView*    _tableView;
}

- (BOOL) shouldShowingCart { return NO; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择小区";
    
    self.hasLeftButton = [self.userData boolValue];
    
    if ( self.hasLeftButton ) {
        [self setLeftBarButtonWithImage:@"btn_close.png"
                                command:[ForwardCommand buildCommandWithForward:
                                         [Forward buildForwardWithType:ForwardTypeDismiss
                                                                  from:self toController:nil]]];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    CGRect frame = self.view.bounds;
    
    _tableView = [[UITableView alloc] initWithFrame:frame
                                              style:UITableViewStylePlain];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _dataSource = [[NSMutableArray alloc] init];
    
    [[DataService sharedService] loadEntityForClass:@"Apartment"
                                                URI:@"/apartments"
                                         completion:^(id result, BOOL succeed)
     {
         [_dataSource addObjectsFromArray:result];
         [_tableView reloadData];
     }];
    
    UIView* footer = [[[UIView alloc] init] autorelease];
    _tableView.tableFooterView = footer;
}

- (void)dealloc
{
    [_dataSource release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = [NSString stringWithFormat:@"cell-%d", indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if ( !cell ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
    }
    
    Apartment* a = [_dataSource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%@）", a.name, a.address];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.hasLeftButton ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kApartmentDidSelctNotification"
                                                            object:[_dataSource objectAtIndex:indexPath.row]];
        
        
        Apartment* a = [_dataSource objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:a.name forKey:@"apartment.name"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        Apartment* a = [_dataSource objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:a.name forKey:@"apartment.name"];
        
        ForwardCommand* aCommand = [ForwardCommand buildCommandWithForward:[Forward buildForwardWithType:ForwardTypePush
                                                                                                    from:self
                                                                                        toControllerName:@"HomeViewController"]];
        aCommand.userData = [_dataSource objectAtIndex:indexPath.row];
        [aCommand execute];
    }
}

@end
