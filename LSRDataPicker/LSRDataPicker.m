//
//  LSRDataPicker.m
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import "LSRDataPicker.h"
#import <PureLayout/PureLayout.h>

@interface LSRDataPicker () <LSRDataPickerDelegate>
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *pickerAreaView;
@property (nonatomic, strong) LSRPickerTopBar *topBar;
@property (nonatomic, strong) UIPickerView *picker;

@property (nonatomic, strong) NSLayoutConstraint *pickerAreaViewTopConstraint;

@end

@implementation LSRDataPicker

- (instancetype)initWithHeight:(CGFloat)height
{
    self.pickerViewHeight = height;
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) {
            if ([UIApplication sharedApplication].windows.count > 0) {
                window = [UIApplication sharedApplication].windows.firstObject;
            }
        }

        [window addSubview:self];
        self.hidden = YES;
        
        [self autoPinEdgesToSuperviewEdgesWithInsets:ALEdgeInsetsZero];
        
        // 1 添加pikerView
        [self dataInit];
        
        [self addSubview:self.maskView];
        [self.maskView autoPinEdgesToSuperviewEdgesWithInsets:ALEdgeInsetsZero];
        
        [self addSubview:self.pickerAreaView];
        self.pickerAreaViewTopConstraint = [self.pickerAreaView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.maskView withOffset:0];
        [self.pickerAreaView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.pickerAreaView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.maskView];
        [self.pickerAreaView autoSetDimension:ALDimensionHeight toSize:self.pickerViewHeight];
    }
    return self;
}

- (void)showPickerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewSelectRowsBeforeShowing:)])
    {
        [self.delegate pickerViewSelectRowsBeforeShowing:self];
    }
    
    if ([self superview])
    {
        self.hidden = NO;
        
        [self.picker reloadAllComponents];
        
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.maskView.alpha = 0.45f;
            self.pickerAreaViewTopConstraint.constant = -self.pickerViewHeight;
            
            // 调用更改约束的view 的父视图的layoutIfNeeded 不要掉自己
            [self layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            //
        }];
    }
}

- (void)dismissPickerView
{
    if ([self superview])
    {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.maskView.alpha = 0;
            self.pickerAreaViewTopConstraint.constant = 0;
            
            // 调用更改约束的view 的父视图的layoutIfNeeded 不要掉自己
            [self layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            self.hidden = YES;
        }];
    }
}

- (CGFloat)windowHeight
{
    return CGRectGetHeight([UIApplication sharedApplication].keyWindow.frame);
}

#pragma mark - Layzes
- (CGFloat)pickerViewHeight
{
    if (_pickerViewHeight < 1.0 || _pickerViewHeight > 10000)
    {
        _pickerViewHeight = 300;
    }
    return _pickerViewHeight;
}

- (UIView *)pickerAreaView
{
    if (!_pickerAreaView)
    {
        _pickerAreaView = [[UIView alloc] initWithFrame:CGRectZero];
        _pickerAreaView.backgroundColor = [UIColor whiteColor];
        
        [_pickerAreaView addSubview:self.topBar];
        [self.topBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.topBar autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.topBar autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.topBar autoSetDimension:ALDimensionHeight toSize:50];
        
        [_pickerAreaView addSubview:self.picker];
        [self.picker autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.picker autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.picker autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.topBar withOffset:0];
        [self.picker autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        // self.backgroundColor = [UIColor greenColor];
        // _picker.backgroundColor = [UIColor redColor];
    }
    return _pickerAreaView;
}

- (LSRPickerTopBar *)topBar
{
    if (!_topBar)
    {
        _topBar = [[LSRPickerTopBar alloc] initWithFrame:CGRectZero];
    }
    return _topBar;
}

- (UIPickerView *)picker
{
    if (!_picker)
    {
        _picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
//        _picker.showsSelectionIndicator = YES;
    }
    return _picker;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMask:)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

#pragma mark - Handler
- (void)dataInit
{
    self.seperateLineColor = [UIColor grayColor];
    
    self.topBar.delegate = self;
}

- (void)tapMask:(UITapGestureRecognizer *)tap
{
    [self dismissPickerView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.picker.subviews[1].backgroundColor = self.seperateLineColor;
    self.picker.subviews[2].backgroundColor = self.seperateLineColor;
}

#pragma mark -  XMPickerTopBarDelegate
- (void)topBar:(LSRPickerTopBar *)topBar didClickedCancelButton:(UIButton *)sender
{
    [self dismissPickerView];
}

- (void)topBar:(LSRPickerTopBar *)topBar didClickedOkButton:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pickerViewDidClickOkButton:)])
    {
        [self.delegate pickerViewDidClickOkButton:self];
    }
    
    [self dismissPickerView];
}



@end
