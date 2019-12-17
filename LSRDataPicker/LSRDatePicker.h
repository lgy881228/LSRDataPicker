//
//  LSRDatePicker.h
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import "LSRDataPicker.h"


typedef NS_ENUM(NSInteger, DateShowingType) {
    DateShowingTypeYMDHM = 1, // year、month、day、hour and minite
    DateShowingTypeYMDHMS,    // year、month、day、hour and minite、second
    DateShowingTypeYMDH,      // year、month、day and hour
    DateShowingTypeYMD,       // year、month、day
    DateShowingTypeMDHM,      // month、day、hour and minite
    DateShowingTypeDHM,       // day、hour and minite
    DateShowingTypeHM,        // hour and minite
    DateShowingTypeYM,        // year、month、
};

@class LSRDatePicker;
@protocol LSRDatePickerDelegate <NSObject>
@optional

- (void)pickerView:(LSRDatePicker *)pickerView didSelectedDateString:(NSString *)dateString;
- (void)pickerView:(LSRDatePicker *)pickerView didClickOkButtonWithDateString:(NSString *)dateString;


@end
@interface LSRDatePicker : LSRDataPicker
@property (nonatomic, assign) PickerViewType pickerViewType;

@property (nonatomic, strong) UIFont *selectedTextFont;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *selectedLabelColor;

@property (nonatomic, strong) UIFont *otherTextFont;
@property (nonatomic, strong) UIColor *otherTextColor;
@property (nonatomic, strong) UIColor *otherLabelColor;

@property (nonatomic, assign) CGFloat seperateLineHeight;
@property (nonatomic, assign) CGFloat seperatorWidth;

@property (nonatomic, assign) CGFloat componentWidth;
@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, assign) BOOL hideTopStaticSperateLine;
@property (nonatomic, assign) BOOL hideBottomStaticSperateLine;

@property (nonatomic, assign) DateShowingType dateShowType;

@property (nonatomic, weak) id<LSRDatePickerDelegate> datePickerdelegate;

@property (nonatomic, assign) int fromYear; // default [-100
@property (nonatomic, assign) int toYear;   // default 100]

// 默认的年月日时分秒
@property (nonatomic, assign) int reservedYear;
@property (nonatomic, assign) int reservedMonth;
@property (nonatomic, assign) int reservedDay;
@property (nonatomic, assign) int reservedHour;
@property (nonatomic, assign) int reservedMinute;
@property (nonatomic, assign) int reservedSecond;

/*** Time unit (单位)*/
@property (nonatomic, copy) NSString *yearUnit;
@property (nonatomic, copy) NSString *monthUnit;
@property (nonatomic, copy) NSString *dayUnit;
@property (nonatomic, copy) NSString *hourUnit;
@property (nonatomic, copy) NSString *minuteUnit;
@property (nonatomic, copy) NSString *secondUnit;

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat bottomMargin;

@end

