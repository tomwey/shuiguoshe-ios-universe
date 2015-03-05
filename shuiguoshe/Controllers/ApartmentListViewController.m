//
//  ApartmentListViewController.m
//  shuiguoshe
//
//  Created by tomwey on 3/1/15.
//  Copyright (c) 2015 shuiguoshe. All rights reserved.
//

#import "ApartmentListViewController.h"
#import "Defines.h"

@interface ApartmentListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@end

@implementation ApartmentListViewController
{
    NSMutableArray* _dataSource;
    UITableView*    _tableView;
    NSMutableArray* _searchResults;
    NSArray*        _currentDataSource;
    
    BOOL _seaching;
    
    NSMutableArray* _tempArray;
}

- (BOOL) shouldShowingCart { return NO; }

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _seaching = NO;
    
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
    
    _searchResults = [[NSMutableArray alloc] init];
    
    _dataSource = [[NSMutableArray alloc] init];
    
    _tempArray = [[NSMutableArray alloc] init];
    
    [[DataService sharedService] loadEntityForClass:@"Apartment"
                                                URI:@"/apartments"
                                         completion:^(id result, BOOL succeed)
     {
         for (int i=0; i<1000; i++) {
             for (Apartment* a in result) {
                 [_tempArray addObject:[NSString stringWithFormat:@"%d-%@-%@", a.oid, a.name, a.address]];
             }
             
             [_dataSource addObjectsFromArray:result];
         }
         
//         _prepareSearchString = [str copy];
         _currentDataSource = _dataSource;
         
         [_tableView reloadData];
     }];
    
    UIView* footer = [[[UIView alloc] init] autorelease];
    _tableView.tableFooterView = footer;
    
    UISearchBar* searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainScreenBounds), 44)] autorelease];
//    if ( [searchBar respondsToSelector:@selector(setBarTintColor:)] ) {
//        searchBar.barTintColor = [UIColor whiteColor];
//    }
    searchBar.delegate = self;
    
    _tableView.tableHeaderView = searchBar;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_tableView.tableHeaderView resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ( searchBar.text.length == 0 ) {
        _currentDataSource = _dataSource;
        [_tableView reloadData];
    } else {
        
        [_searchResults removeAllObjects];
        NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(Apartment* evaluatedObject, NSDictionary *bindings) {
            NSLog(@"%@",bindings);
            if([evaluatedObject.name isEqualToString:searchBar.text])
            {
                return YES;
            }
            return NO;
        }];
        
        NSArray* results = [_dataSource filteredArrayUsingPredicate:pred];
        
        [_searchResults addObjectsFromArray:results];
        [_tableView reloadData];
    }
}

- (void)dealloc
{
    [_dataSource release];
    [_searchResults release];
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_currentDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = [NSString stringWithFormat:@"cell-%d", indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if ( !cell ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
    }
    
    Apartment* a = [_currentDataSource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%@）", a.name, a.address];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( self.hasLeftButton ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kApartmentDidSelctNotification"
                                                            object:[_dataSource objectAtIndex:indexPath.row]];
        
        
        Apartment* a = [_currentDataSource objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:a.name forKey:@"apartment.name"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        Apartment* a = [_currentDataSource objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:a.name forKey:@"apartment.name"];
        
        ForwardCommand* aCommand = [ForwardCommand buildCommandWithForward:[Forward buildForwardWithType:ForwardTypePush
                                                                                                    from:self
                                                                                        toControllerName:@"HomeViewController"]];
        aCommand.userData = a;
        [aCommand execute];
    }
}

@end
