//
//  LSRPickerTopBar.h
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LSRPickerTopBar;
@protocol LSRPickerTopBarDelegate <NSObject>
- (void)topBar:(LSRPickerTopBar *)topBar didClickedCancelButton:(UIButton *)sender;
- (void)topBar:(LSRPickerTopBar *)topBar didClickedOkButton:(UIButton *)sender;
@end

@interface LSRPickerTopBar : UIView

@property(nonatomic, weak) id<LSRPickerTopBarDelegate> delegate;

@property(nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIView *topOnePixelLine;
@property (nonatomic, strong) UIView *bottomOnePixelLine;

@end

NS_ASSUME_NONNULL_END
