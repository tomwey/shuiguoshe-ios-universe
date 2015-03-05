//
//  RegisterViewController.m
//  shuiguoshe
//
//  Created by tangwei1 on 15-2-12.
//  Copyright (c) 2015年 shuiguoshe. All rights reserved.
//

#import "RegisterViewController.h"
#import "Defines.h"

@interface RegisterViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@end

@implementation RegisterViewController
{
    NSArray*     _dataSource;
    UITableView* _tableView;
    User*        _currentUser;
    
    UIButton*    _regBtn;
    
    CGPoint      _tableOffset;
    
    UITextField* _mobileField;
    UITextField* _passwordField;
    UITextField* _codeField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"快速注册";
    
    _currentUser = [[User alloc] init];
    
    FormItem* uf1 = [[[FormItem alloc] init] autorelease];
    uf1.name = @"name";
    uf1.label = @"手机号码";
    uf1.placeholder = @"请输入您的手机号";
    
    FormItem* uf2 = [[[FormItem alloc] init] autorelease];
    uf2.name = @"password";
    uf2.label = @"登录密码";
    uf2.placeholder = @"请输入至少6位密码";
    
    FormItem* uf3 = [[[FormItem alloc] init] autorelease];
    uf3.name = @"code";
    uf3.label = @"验证码";
    uf3.placeholder = @"请输入短信验证码";
    
    _dataSource = [[NSArray alloc] initWithObjects:uf1, uf2, uf3, nil];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    [_tableView release];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 44;
    
    UIView* footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(mainScreenBounds), 300)] autorelease];
    footerView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footerView;
    
    // 注册按钮
    _regBtn = createButton(@"btn_reg.png", self, @selector(doReg));
    
    [footerView addSubview:_regBtn];
    
    CGRect frame = _regBtn.frame;
    frame.origin = CGPointMake(CGRectGetWidth(mainScreenBounds) / 2 - CGRectGetWidth(frame) / 2, 20);
    _regBtn.frame = frame;
    
    _tableOffset = CGPointMake(0, -64);
}

- (void)doReg
{
    
    // 手机号检查
    if ( _mobileField.text.length == 0 ) {
        [Toast showText:@"手机号不能为空"];
        return;
    }
    
    NSString *phoneRegex = @"\\A1[3|4|5|8][0-9]\\d{8}\\z";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:_mobileField.text];
    
    if ( !matches ) {
        [Toast showText:@"手机号不正确"];
        return;
    }
    
    // 密码检查
    if ( _passwordField.text.length < 6 ) {
        [Toast showText:@"密码至少为6位"];
        return;
    }
    
    // 验证码检查
    if ( _codeField.text.length == 0 ) {
        [Toast showText:@"验证码不能为空"];
        return;
    }
    
    [self hideKeyboard];
    
    __block RegisterViewController* me = self;
    [[UserService sharedService] signup:_currentUser completion:^(BOOL succeed, NSString* errorMsg) {
        if ( succeed ) {
            [me dismissViewControllerAnimated:YES completion:nil];
        } else {
            [Toast showText:errorMsg];
        }
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = [NSString stringWithFormat:@"cell:%d", indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if ( !cell ) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UILabel* label = (UILabel *)[cell.contentView viewWithTag:100];
    if ( !label ) {
        label = createLabel(CGRectMake(15, (tableView.rowHeight - 30) / 2, 100, 30),
                            NSTextAlignmentLeft,
                            RGB(131, 131, 131),
                            [UIFont boldSystemFontOfSize:16]);
        [cell.contentView addSubview:label];
        label.tag = 100;
    }
    
    FormItem* uf = [_dataSource objectAtIndex:indexPath.row];
    label.text = uf.label;
    
    InputTextField* tf = (InputTextField *)[cell.contentView viewWithTag:101];
    if ( !tf ) {
        tf = [[InputTextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame),
                                                              0, 200, 44)];
        tf.tag = 101;
        [cell.contentView addSubview:tf];
        [tf release];
        
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.delegate = self;
        tf.font = [UIFont systemFontOfSize:14];
    }
    
    if ( indexPath.row == 2 ) {
        UIButton* codeBtn = (UIButton *)[cell.contentView viewWithTag:105];
        if ( !codeBtn ) {
            codeBtn = createButton(@"btn_code.png", self, @selector(fetchCode:));
            CGRect frame = codeBtn.frame;
            frame.origin = CGPointMake(mainScreenBounds.size.width - 10 - CGRectGetWidth(frame),
                                       44 / 2 - CGRectGetHeight(frame) / 2);
            codeBtn.frame = frame;
            [cell.contentView addSubview:codeBtn];
            codeBtn.tag = 105;
        }
        
        tf.frame = CGRectMake(CGRectGetMaxX(label.frame), 0, 120, 44);
    }
    
    tf.placeholder = uf.placeholder;
    tf.name = uf.name;
    
    if ( indexPath.row == 0 || indexPath.row == 2 ) {
        tf.keyboardType = UIKeyboardTypeNumberPad;
    } else if ( indexPath.row == 1 ) {
        tf.returnKeyType = UIReturnKeyDone;
        tf.secureTextEntry = YES;
    }
    
    if ( [tf.name isEqualToString:@"name"] ) {
        _mobileField = tf;
    }
    
    if ( [tf.name isEqualToString:@"password"] ) {
        _passwordField = tf;
    }
    
    if ( [tf.name isEqualToString:@"code"] ) {
        _codeField = tf;
    }
    
    return cell;
}

- (void)fetchCode:(UIButton *)sender
{
    // 手机号检查
    if ( _mobileField.text.length == 0 ) {
        [Toast showText:@"手机号不能为空"];
        return;
    }
    
    NSString *phoneRegex = @"\\A1[3|4|5|8][0-9]\\d{8}\\z";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:_mobileField.text];
    
    if ( !matches ) {
        [Toast showText:@"手机号不正确"];
        return;
    }
    
    [self hideKeyboard];
    
    sender.enabled = NO;
    
    _currentUser.codeType = @"1";
    [[UserService sharedService] fetchCode:_currentUser completion:^(BOOL succeed, NSString *errorMsg) {
        sender.enabled = YES;
        if ( !succeed ) {
            [Toast showText:errorMsg];
        } else {
            [Toast showText:@"短信验证码已发出"];
        }
    }];
}

#pragma mark - UITextField delegate
- (BOOL)shouldShowingCart
{
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(InputTextField *)textField
{
    if ( [textField.name isEqualToString:@"code"] && CGRectGetHeight(mainScreenBounds) == 480 ) {
        [UIView animateWithDuration:.35
                         animations:^{
                             CGPoint offset = _tableOffset;
                             offset.y += 50;
                             _tableView.contentOffset = offset;
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(InputTextField *)textField
{
    SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [textField.name capitalizedString]]);
    if ( [_currentUser respondsToSelector:setter] ) {
        [_currentUser performSelector:setter withObject:textField.text];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideKeyboard];
}

- (void)hideKeyboard
{
    for ( UITableViewCell* cell in [_tableView visibleCells] ) {
        [[cell.contentView viewWithTag:101] resignFirstResponder];
    }
}

- (void)dealloc
{
    [_currentUser release];
    [_dataSource release];
    [super dealloc];
}

@end
