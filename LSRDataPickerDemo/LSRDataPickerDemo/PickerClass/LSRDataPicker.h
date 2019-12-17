//
//  LSRDataPicker.h
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRPickerTopBar.h"

typedef NS_ENUM(NSInteger, PickerViewType) {
    PickerViewTypeLongSperator = 1, // Default
    PickerViewTypeDynamicSperator,
    PickerViewTypeStaticSperator,
};


@class LSRDataPicker;
@protocol LSRDataPickerDelegate <NSObject, UIPickerViewDataSource, UIPickerViewDelegate>
@optional
- (void)pickerViewSelectRowsBeforeShowing:(LSRDataPicker *)pickerView;
- (void)pickerViewDidClickOkButton:(LSRDataPicker *)pickerView;
@end
@interface LSRDataPicker : UIView
@property (nonatomic, weak) id<LSRDataPickerDelegate> delegate;

@property (nonatomic, readonly) LSRPickerTopBar *topBar;
@property (nonatomic, readonly) UIPickerView *picker;

@property (nonatomic, readwrite) CGFloat pickerViewHeight;

/** sperate line color 分割线颜色*/
@property (nonatomic, strong) UIColor *seperateLineColor;

- (instancetype)initWithHeight:(CGFloat)height;

- (void)showPickerView;
- (void)dismissPickerView;

@end


