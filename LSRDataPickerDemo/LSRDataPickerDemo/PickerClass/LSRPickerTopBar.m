//
//  LSRPickerTopBar.m
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import "LSRPickerTopBar.h"
#import <PureLayout/PureLayout.h>

#define kUsingOnePixelLineLayer  0

@interface LSRPickerTopBar ()

@end
@implementation LSRPickerTopBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self p_commonInit];
        
#if kUsingOnePixelLineLayer
        [self.layer addSublayer:[self topOnePixelLine]];
        [self.layer addSublayer:[self bottomOnePixelLine]];
#endif
    }
    return self;
}

- (void)p_commonInit
{
    CGFloat margin = 10;
    CGFloat buttonWidth = 50;
    
    [self addSubview:self.cancelButton];
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:margin];
    [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.cancelButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.cancelButton autoSetDimension:ALDimensionWidth toSize:buttonWidth];
    
    [self addSubview:self.okButton];
    [self.okButton addTarget:self action:@selector(okButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.okButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:margin];
    [self.okButton autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.okButton autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.okButton autoSetDimension:ALDimensionWidth toSize:buttonWidth];
    
    [self addSubview:self.titleLabel];
    [self.titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cancelButton withOffset:15];
    [self.titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.okButton withOffset:-15];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    
#if !kUsingOnePixelLineLayer
    
    CGFloat onePixel = 1.0 / ([[UIScreen mainScreen] scale]);
    
    [self addSubview:self.topOnePixelLine];
    [self.topOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.topOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.topOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.topOnePixelLine autoSetDimension:ALDimensionHeight toSize:onePixel];
    
    [self addSubview:self.bottomOnePixelLine];
    [self.bottomOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.bottomOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.bottomOnePixelLine autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.bottomOnePixelLine autoSetDimension:ALDimensionHeight toSize:onePixel];
#endif
}

#if kUsingOnePixelLineLayer
- (CALayer *)topOnePixelLine
{
    CGFloat one_pixel = 1.0 / [[UIScreen mainScreen] scale];
    
    CGRect lineLayerRect = CGRectZero;
    lineLayerRect.size.width = self.width;
    lineLayerRect.size.height = one_pixel;
    lineLayerRect.origin.x = 0.0f;
    lineLayerRect.origin.y = 0.0f;
    
    CALayer *lineLayer = [CALayer layer];
    [lineLayer setFrame:lineLayerRect];
    [lineLayer setBackgroundColor:[UIColor grayColor].CGColor];
    // [lineLayer setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor];
    
    return lineLayer;
}

- (CALayer *)bottomOnePixelLine
{
    CGFloat one_pixel = 1.0 / [[UIScreen mainScreen] scale];
    
    CGRect lineLayerRect = CGRectZero;
    lineLayerRect.size.width = self.width;
    lineLayerRect.size.height = one_pixel;
    lineLayerRect.origin.x = 0.0f;
    lineLayerRect.origin.y = self.height - CGRectGetHeight(lineLayerRect);
    
    CALayer *lineLayer = [CALayer layer];
    [lineLayer setFrame:lineLayerRect];
    [lineLayer setBackgroundColor:[UIColor lightGrayColor].CGColor];
    // [lineLayer setBackgroundColor:[UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor];
    return lineLayer;
}

#else

- (UIView *)topOnePixelLine
{
    if (!_topOnePixelLine)
    {
        _topOnePixelLine = [UIView new];
        _topOnePixelLine.backgroundColor = [UIColor clearColor];
    }
    return _topOnePixelLine;
}

- (UIView *)bottomOnePixelLine
{
    if (!_bottomOnePixelLine)
    {
        _bottomOnePixelLine = [UIView new];
        _bottomOnePixelLine.backgroundColor = [UIColor grayColor];
    }
    return _bottomOnePixelLine;
}
#endif

#pragma mark - Layzes
- (UIButton *)cancelButton
{
    if (!_cancelButton)
    {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (UIButton *)okButton
{
    if (!_okButton)
    {
        _okButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_okButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        [_okButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_okButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    return _okButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}

#pragma mark - Touch
- (void)cancelButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didClickedCancelButton:)])
    {
        [self.delegate topBar:self didClickedCancelButton:sender];
    }
}

- (void)okButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didClickedOkButton:)])
    {
        [self.delegate topBar:self didClickedOkButton:sender];
    }
}
@end
