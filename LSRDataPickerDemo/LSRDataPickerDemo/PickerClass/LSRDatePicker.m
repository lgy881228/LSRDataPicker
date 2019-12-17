//
//  LSRDatePicker.m
//  LSRDataPickerDemo
//
//  Created by 李找乐 on 2019/12/17.
//  Copyright © 2019 李找乐. All rights reserved.
//

#import "LSRDatePicker.h"
#import <objc/runtime.h>
/**
 * 每月的天数是最特殊的，俗话说 1 3 5 7 8 10 12(腊)， 31天总不差
 *  4 6 9 11，都是30天
 *  2月最特殊，分为闰年和平年，所谓闰年大家百度即可，闰年的2月份是29天，平年28天 相信只要有小学文凭的都知道，怎么算就不多说了
 */

#define MonthsOfEachYear    12 // 每年12个月
#define HoursOfEachDay      24 // 每天24小时
#define MinutesOfEachHour   60 // 每小时60分
#define SecondsOfEachMinute 60 // 每分钟60秒

#define IsThirtyOneDays(month) \
(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)

#define IsThirtyDays(month) (month == 4 || month == 6 ||month == 9 || month == 11)

#define kSideSpacing      20

@interface LSRDatePicker ()  <UIPickerViewDelegate, UIPickerViewDataSource, LSRPickerTopBarDelegate>
{
    NSInteger _yearIndex;
    NSInteger _monthIndex;
    NSInteger _dayIndex;
    NSInteger _hourIndex;
    NSInteger _minuteIndex;
    NSInteger _secondIndex;
}
// @property(nonatomic, strong)UIViewController *controller;


@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSMutableArray *months;
@property (nonatomic, strong) NSMutableArray *days;
@property (nonatomic, strong) NSMutableArray *hours;
@property (nonatomic, strong) NSMutableArray *minutes;
@property (nonatomic, strong) NSMutableArray *seconds;

@property (nonatomic, assign) int currentYear;
@property (nonatomic, assign) int currentMonth;
@property (nonatomic, assign) int currentDay;
@property (nonatomic, assign) int currentHour;
@property (nonatomic, assign) int currentMinute;
@property (nonatomic, assign) int currentSecond;

@end

@implementation LSRDatePicker

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (PickerViewTypeLongSperator == self.pickerViewType)
    {
        self.picker.subviews[1].backgroundColor = self.seperateLineColor;
        self.picker.subviews[2].backgroundColor = self.seperateLineColor;
    }
    else
    {
        self.picker.subviews[1].hidden = YES;
        self.picker.subviews[2].hidden = YES;
    }
}

- (void)commonInit
{
    self.pickerViewType = PickerViewTypeLongSperator;
    self.dateShowType = DateShowingTypeYMDHM;
    
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.topMargin = 40;
    
    CGFloat onePixel = 1.0 / ([[UIScreen mainScreen] scale]);
    self.seperateLineHeight = onePixel;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    
    self.currentYear = (int)components.year;
    self.currentMonth = (int)components.month;
    self.currentDay = (int)components.day;
    self.currentHour = (int)components.hour;
    self.currentMinute = (int)components.minute;
    self.currentSecond = 0;
    
    self.fromYear = self.currentYear - 100;
    self.toYear = self.currentYear + 100;
    
    // default [-100, 100]
    _years = [[NSMutableArray alloc] init];
    for (int i = self.fromYear; i<= self.toYear; i++)
    {
        [_years addObject:[NSString stringWithFormat:@"%.4d", i]];
    }
    
    [self months];
    [self hours];
    [self minutes];
    [self seconds];
}

- (void)showPickerView
{
    [self pickerViewSelectRowsBeforeShowing];
    
    [super showPickerView];
    
    self.topBar.titleLabel.text =  [self setDefaultText];
}

#pragma mark -
- (NSMutableArray *)months
{
    if (!_months)
    {
        _months = [[NSMutableArray alloc] init];
    }
    return [self getCommonArray:_months elementCount:MonthsOfEachYear];
}

- (NSMutableArray *)hours
{
    if (!_hours)
    {
        _hours = [[NSMutableArray alloc] init];
    }
    return [self getCommonArray:_hours elementCount:HoursOfEachDay];
}

- (NSMutableArray *)minutes
{
    if (!_minutes)
    {
        _minutes = [[NSMutableArray alloc] init];
    }
    return [self getCommonArray:_minutes elementCount:MinutesOfEachHour];
}

- (NSMutableArray *)seconds
{
    if (!_seconds)
    {
        _seconds = [[NSMutableArray alloc] init];
    }
    return [self getCommonArray:_seconds elementCount:SecondsOfEachMinute];
}

- (void)setReservedYear:(int)reservedYear
{
    if (reservedYear >= self.fromYear && reservedYear <= self.toYear)
    {
        self.currentYear = reservedYear;
    }
}

- (void)setReservedMonth:(int)reservedMonth
{
    self.currentMonth = reservedMonth;
}

- (void)setReservedDay:(int)reservedDay
{
    self.currentDay = reservedDay;
}

- (void)setReservedHour:(int)reservedHour
{
    self.currentHour = reservedHour;
}

- (void)setReservedMinute:(int)reservedMinute
{
    self.currentMinute = reservedMinute;
}

- (void)setReservedSecond:(int)reservedSecond
{
    self.currentSecond = reservedSecond;
}

- (int)reservedYear
{
    return self.currentYear;
}

- (int)reservedMonth
{
    return self.currentMonth;
}

- (int)reservedDay
{
    return self.currentDay;
}

- (int)reservedHour
{
    return self.currentHour;
}

- (int)reservedMinute
{
    return self.currentMinute;
}

- (int)reservedSecond
{
    return self.reservedSecond;
}

#pragma mark -  XMPickerTopBarDelegate
- (void)topBar:(LSRPickerTopBar *)topBar didClickedCancelButton:(UIButton *)sender
{
    [self dismissPickerView];
}


- (void)topBar:(LSRPickerTopBar *)topBar didClickedOkButton:(UIButton *)sender
{
    if ([self.datePickerdelegate respondsToSelector:@selector(pickerView:didClickOkButtonWithDateString:)])
    {
        [self.datePickerdelegate pickerView:self didClickOkButtonWithDateString:self.dateString];
    }
    
    [self dismissPickerView];
}

#pragma mark - Events
- (void)pickerViewSelectRowsBeforeShowing
{
    [self initDateData];
    
    if (self.dateShowType == DateShowingTypeYMDHM) // yyyy-MM-dd HH:mm(展示 年、月、日、时、分)
    {
        [self.picker selectRow:_yearIndex inComponent:0 animated:NO];
        [self.picker selectRow:_monthIndex inComponent:1 animated:NO];
        [self.picker selectRow:_dayIndex inComponent:2 animated:NO];
        [self.picker selectRow:_hourIndex inComponent:3 animated:NO];
        [self.picker selectRow:_minuteIndex inComponent:4 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        [self.picker selectRow:_yearIndex inComponent:0 animated:NO];
        [self.picker selectRow:_monthIndex inComponent:1 animated:NO];
        [self.picker selectRow:_dayIndex inComponent:2 animated:NO];
        [self.picker selectRow:_hourIndex inComponent:3 animated:NO];
        [self.picker selectRow:_minuteIndex inComponent:4 animated:NO];
        [self.picker selectRow:_secondIndex inComponent:5 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeYMDH) // show year-month-day hour
    {
        [self.picker selectRow:_yearIndex inComponent:0 animated:NO];
        [self.picker selectRow:_monthIndex inComponent:1 animated:NO];
        [self.picker selectRow:_dayIndex inComponent:2 animated:NO];
        [self.picker selectRow:_hourIndex inComponent:3 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeYMD) // show year-month-day
    {
        [self.picker selectRow:_yearIndex inComponent:0 animated:NO];
        [self.picker selectRow:_monthIndex inComponent:1 animated:NO];
        [self.picker selectRow:_dayIndex inComponent:2 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeYM) // show year-month
    {
        [self.picker selectRow:_yearIndex inComponent:0 animated:NO];
        [self.picker selectRow:_monthIndex inComponent:1 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeMDHM) // show month-day Hour:minute
    {
        // months
        [self.picker selectRow:_monthIndex inComponent:0 animated:NO];
        // days
        [self.picker selectRow:_dayIndex inComponent:1 animated:NO];
        // hour
        [self.picker selectRow:_hourIndex inComponent:2 animated:NO];
        // minute
        [self.picker selectRow:_minuteIndex inComponent:3 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeDHM) // show day Hour : minute
    {
        [self.picker selectRow:_dayIndex inComponent:0 animated:NO];
        [self.picker selectRow:_hourIndex inComponent:1 animated:NO];
        [self.picker selectRow:_minuteIndex inComponent:2 animated:NO];
    }
    else if (self.dateShowType == DateShowingTypeHM) // HH:mm
    {
        [self.picker selectRow:_hourIndex inComponent:0 animated:NO];
        [self.picker selectRow:_minuteIndex inComponent:1 animated:NO];
    }
}

- (void)initDateData
{
    _yearIndex = [self.years indexOfObject:[NSString stringWithFormat:@"%.4d", self.currentYear]];
    _monthIndex = [self.months indexOfObject:[NSString stringWithFormat:@"%.2d", self.currentMonth]];
    _dayIndex = [[self caculateDaysFromMonth:self.currentMonth year:self.currentYear] indexOfObject:[NSString stringWithFormat:@"%.2d", self.currentDay]];
    _hourIndex = [self.hours indexOfObject:[NSString stringWithFormat:@"%.2d", self.currentHour]];
    _minuteIndex = [self.minutes indexOfObject:[NSString stringWithFormat:@"%.2d", self.currentMinute]];
    _secondIndex = [self.seconds indexOfObject:[NSString stringWithFormat:@"%.2d", self.currentSecond]];
}

- (NSMutableArray *)getCommonArray:(NSMutableArray *)array elementCount:(int)count
{
    if (array.count)
    {
        [array removeAllObjects];
    }
    
    if (count == MonthsOfEachYear)
    {
        // 月从1开始
        for (int i = 1; i <= count; i++)
        {
            [array addObject:[NSString stringWithFormat:@"%.2d", i]];
        }
    }
    else
    {
        // 时分秒从0开始
        for (int i = 0; i < count; i++)
        {
            [array addObject:[NSString stringWithFormat:@"%.2d", i]];
        }
    }
    
    return array;
}

- (NSMutableArray *)caculateDaysFromMonth:(int)month year:(int)year
{
    _days = [[NSMutableArray alloc] init];
    if (_days && _days.count)
    {
        [_days removeAllObjects];
    }
    
    int days = 31;
//    NSLog(@"%d",DaysOfEveryMonth(month));
    if ([self daysOfEveryMonth:month] >= 30)
    {
        days = [self daysOfEveryMonth:month];
    }
    else
    {
        days = [self caculateDaysOfFebaryFromYear:year];
    }
    
    for (int i = 1; i<= days; i++)
    {
        [_days addObject:[NSString stringWithFormat:@"%.2d", i]];
    }
    
    NSInteger  row ;
    if (self.dateShowType == DateShowingTypeYMDHM || self.dateShowType == DateShowingTypeYMDHMS || self.dateShowType == DateShowingTypeYMDH || self.dateShowType == DateShowingTypeYMD)
    {
        row = [self.picker selectedRowInComponent:2];
    } else {
        row = [self.picker selectedRowInComponent:1];
    }
    if (row == _days.count)
    {
        [self.picker selectRow:_days.count-1 inComponent:2 animated:NO];
    }
    return _days;
}


- (int)caculateDaysOfFebaryFromYear:(int)year
{
    int temYear = year;
    
    if (self.dateShowType != DateShowingTypeMDHM &&
        self.dateShowType != DateShowingTypeDHM &&
        self.dateShowType != DateShowingTypeHM)
    {
        // 这里的都不包含Year的
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *component = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
        temYear = (int)component.year;
    }
    
    if (temYear %4 == 0)
    {
        return 29;
    }
    return 28;
}

- (int)daysOfEveryMonth:(int)month
{
    int days = 0;
    if (IsThirtyOneDays(month))
    {
        days = 31;
    }
    else if (IsThirtyDays(month))
    {
        days = 30;
    }
    return days;
}

- (void)configPickerView:(UIPickerView *)pickerView titleForComponent:(NSInteger)component
{
//    if (PickerViewTypeLongSperator == self.pickerViewType)
//    {
//        pickerView.subviews[1].backgroundColor = self.seperateLineColor;
//        pickerView.subviews[2].backgroundColor = self.seperateLineColor;
//    }
//    else
//    {
//        pickerView.subviews[1].hidden = YES;
//        pickerView.subviews[2].hidden = YES;
//    }
   
    CGFloat textWidth = 0;
    NSString *labelTex = @"xxxx";
    if (self.dateShowType != DateShowingTypeMDHM &&
        self.dateShowType !=DateShowingTypeDHM &&
        self.dateShowType != DateShowingTypeHM)
    {
        // 这里的都不包含Year的
        if (self.yearUnit)
        {
            labelTex = @"xxxx年";
        }
    }
    else
    {
        if (self.monthUnit || self.dayUnit || self.hourUnit || self.minuteUnit)
        {
            labelTex = @"xx月";
        }
        else
        {
            labelTex = @"xx";
        }
    }
   
    UIFont *font = nil;
    font = self.otherTextFont ? self.otherTextFont : [UIFont systemFontOfSize:16];
    textWidth = [self widthOfText:labelTex font:font];
    CGFloat sepepatorWidth = (textWidth < self.seperatorWidth) ? self.seperatorWidth : textWidth;
    int pickerTableViewNum = (int)pickerView.subviews[0].subviews[component].subviews.count;

    for (int index = 0; index < pickerTableViewNum; index++)
    {
        UIView *tableView = pickerView.subviews[0].subviews[component].subviews[index].subviews[0];

        unsigned int count = 0;
        Ivar *array = class_copyIvarList([tableView class], &count);
        for (int i = 0; i < count; i++)
        {
            Ivar property = array[i];
            const char *string = ivar_getName(property);
            NSString *name = [[NSString alloc] initWithUTF8String:string];
            if (![name isEqualToString:@"_referencingCells"]) continue;
    
            NSMutableArray * cells = object_getIvar(tableView, property);
            int count = (int)cells.count;
            if (!count) continue;
            
            UIColor *textColor = nil;
            UIColor *labelBackgroundColor = nil;
            for (int i = 0; i < count; i++)
            {
                if (index != (pickerTableViewNum - 1))
                {
                    font = self.otherTextFont ? self.otherTextFont:[UIFont systemFontOfSize:16];
                    textColor = self.otherTextColor ? self.otherTextColor : [UIColor grayColor];
                    labelBackgroundColor = self.otherLabelColor ? self.otherLabelColor : [UIColor clearColor];
                }
                else
                {
                    font = self.selectedTextFont ? self.selectedTextFont : [UIFont systemFontOfSize:16];
                    textColor = self.selectedTextColor ? self.selectedTextColor : [UIColor blackColor];
                    labelBackgroundColor = self.selectedLabelColor ? self.selectedLabelColor : [UIColor clearColor];
                }
                
                UILabel *textLabel = [cells[i] subviews][1];
                textLabel.textColor = textColor;
                textLabel.font = font;
                textLabel.backgroundColor = labelBackgroundColor;
                
                if (index != (pickerTableViewNum - 1))
                    continue;
                
                if (textLabel.subviews.count >= 1)
                    continue;
                
                // dynamic seperator
                if (self.pickerViewType == PickerViewTypeDynamicSperator)
                {
                    UIView *line = [[UIView alloc] initWithFrame:CGRectMake((textLabel.frame.size.width - sepepatorWidth)/2, textLabel.frame.size.height - self.seperateLineHeight, sepepatorWidth, self.seperateLineHeight)];
                    line.backgroundColor = self.seperateLineColor;
                    [textLabel addSubview:line];
                }
            }
        }
    }
    
    //static sperator
    if (self.pickerViewType != PickerViewTypeStaticSperator) return;
    
    CGFloat spacing = 4.75f;
    NSInteger numberOfComponent = [self numberOfComponents];
    CGFloat margin = (CGRectGetWidth(self.frame) - self.componentWidth * numberOfComponent - (numberOfComponent - 1)*spacing)/2;
    CGFloat textLabelOffSet = 9.0f;
    CGFloat textOffSet = (self.componentWidth - textLabelOffSet - sepepatorWidth)/2;
    UIView *view = pickerView.subviews[0].subviews[component].subviews[2];
    
    if (view.subviews.count >= 3)
    {
        //
    }
    else
    {
        CGFloat x = (spacing + self.componentWidth)*component + margin + textLabelOffSet + textOffSet;
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(x, CGRectGetHeight(view.frame) - 1, sepepatorWidth, 1)];
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(x, 0, sepepatorWidth, 1)];
        lineView1.backgroundColor = [UIColor blueColor];
        lineView2.backgroundColor = [UIColor blueColor];
        [view addSubview:lineView1];
        [view addSubview:lineView2];
    }
}

- (NSInteger)numberOfComponents
{
    if (self.dateShowType == DateShowingTypeYMDH || self.dateShowType == DateShowingTypeMDHM)
    {
        return 4;
    }
    else if (self.dateShowType == DateShowingTypeYMD || self.dateShowType == DateShowingTypeDHM)
    {
        return 3;
    }
    else if (self.dateShowType == DateShowingTypeYMDHM)
    {
        return 5;
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        return 6;
    }
    else if (self.dateShowType == DateShowingTypeHM || self.dateShowType == DateShowingTypeYM)
    {
        return 2;
    }
    
    return 5;
}

- (void)updateDateAcordingToYearAtRow:(NSInteger)row inComponent:(NSInteger)component
{
    // 更新日期
    self.currentYear = [self.years[row] intValue];
    [self.picker reloadComponent:(component + 2)];
    
    NSInteger selectedRow = [self.picker selectedRowInComponent:(component + 2)];
    self.currentDay = [self.days[selectedRow] intValue];
}

- (CGFloat)widthOfText:(NSString *)text font:(UIFont *)font
{
    NSDictionary *dic = @{NSFontAttributeName:font};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    return width;
}

- (NSString *)setDefaultText
{
    if (self.dateShowType == DateShowingTypeYMDHM)
    {
        return [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d", self.currentYear, self.currentMonth, self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        return [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d:%.2d‘%.2d“", self.currentYear, self.currentMonth, self.currentDay, self.currentHour, self.currentMinute, self.currentSecond];
    }
    else if (self.dateShowType == DateShowingTypeYMDH)
    {
        return [NSString stringWithFormat:@"%d-%.2d-%.2d %.2d", self.currentYear, self.currentMonth, self.currentDay, self.currentHour];
    }
    else if (self.dateShowType == DateShowingTypeYMD)
    {
          return [NSString stringWithFormat:@"%d-%.2d-%.2d", self.currentYear, self.currentMonth, self.currentDay];
    }
    else if (self.dateShowType == DateShowingTypeYM)
    {
        return [NSString stringWithFormat:@"%d-%.2d", self.currentYear, self.currentMonth];
    }
    else if (self.dateShowType == DateShowingTypeMDHM)
    {
        return [NSString stringWithFormat:@"%.2d-%.2d %.2d:%.2d", self.currentMonth, self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeDHM)
    {
        return [NSString stringWithFormat:@"%.2d %.2d:%.2d", self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeHM)
    {
        return [NSString stringWithFormat:@"%.2d:%.2d", self.currentHour, self.currentMinute];
    }
    return @"";
}

#pragma mark - SetMethods
- (void)setFromYear:(int)fromYear
{
    if (self.currentYear < fromYear)
    {
        self.currentYear = fromYear;
    }
    
    _fromYear = fromYear;
    [self.years removeAllObjects];

    for (int i = fromYear; i<= self.toYear; i++)
    {
        [_years addObject:[NSString stringWithFormat:@"%.4d", i]];
    }
}

- (void)setToYear:(int)toYear
{
    if (self.currentYear > toYear)
    {
        self.currentYear = toYear;
    }
    
    _toYear = toYear;
    [self.years removeAllObjects];
    
    for (int i = self.fromYear; i<= toYear; i++)
    {
        [_years addObject:[NSString stringWithFormat:@"%.4d", i]];
    }
}

#pragma mark - Tools
- (NSString *)yearTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", self.years[row], self.yearUnit ?: @""];
}

- (NSString *)monthTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", self.months[row], self.monthUnit ?: @""];
}

- (NSString *)dayTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", [self caculateDaysFromMonth:self.currentMonth year:self.currentYear][row], self.dayUnit ?: @""];
}

- (NSString *)hourTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", self.hours[row], self.hourUnit ?: @""];
}

- (NSString *)minuteTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", self.minutes[row], self.minuteUnit ?: @""];
}

- (NSString *)secondTitleForRow:(NSInteger)row
{
    return [NSString stringWithFormat:@"%@ %@", self.seconds[row], self.secondUnit ?: @""];
}

- (NSString *)dateString
{
    if (self.dateShowType == DateShowingTypeYMDHM) // 1 show all colums(展示 年、月、日、时、分)
    {
        return [NSString stringWithFormat:@"%.4d-%.2d-%.2d %.2d:%.2d", self.currentYear, self.currentMonth, self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        return [NSString stringWithFormat:@"%.4d-%.2d-%.2d %.2d:%.2d:%.2d", self.currentYear, self.currentMonth, self.currentDay, self.currentHour, self.currentMinute, self.currentSecond];
    }
    else if (self.dateShowType == DateShowingTypeYMDH)  // show year-month-day hour
    {
        return [NSString stringWithFormat:@"%.4d-%.2d-%.2d %.2d", self.currentYear, self.currentMonth, self.currentDay, self.currentHour];
    }
    else if (self.dateShowType == DateShowingTypeYMD) // show year-month-day
    {
        return [NSString stringWithFormat:@"%.4d-%.2d-%.2d", self.currentYear, self.currentMonth, self.currentDay];
    }
    else if (self.dateShowType == DateShowingTypeYM) // show year-month
    {
        return [NSString stringWithFormat:@"%.4d-%.2d", self.currentYear, self.currentMonth];
    }
    else if (self.dateShowType == DateShowingTypeMDHM) // show month-day Hour:minute
    {
        return [NSString stringWithFormat:@"%.2d-%.2d %.2d:%.2d", self.currentMonth, self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeDHM) // show day Hour : minute
    {
        return [NSString stringWithFormat:@"%.2d %.2d:%.2d", self.currentDay, self.currentHour, self.currentMinute];
    }
    else if (self.dateShowType == DateShowingTypeHM) // HH:mm
    {
        return [NSString stringWithFormat:@"%.2d:%.2d", self.currentHour, self.currentMinute];
    }
    else
    {
        return @"";
    }
}

#pragma mark - Delegates && DataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return [self numberOfComponents];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.dateShowType == DateShowingTypeYMDHM) // 1 show all colums(展示 年、月、日、时、分)
    {
        if (component == 0)
        {
            return self.years.count; // year
        }
        else if (component == 1)
        {
            return self.months.count; // month
        }
        else if (component == 2)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; //day
        }
        else if (component == 3)
        {
            return self.hours.count; // hour
        }
        else if (component == 4)
        {
            return self.minutes.count; // minute
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS) // 2 show year-month-day hour
    {
        if (component == 0)
        {
            return self.years.count; // year
        }
        else if (component == 1)
        {
            return self.months.count; // month
        }
        else if (component == 2)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; // day
        }
        else if (component == 3)
        {
            return self.hours.count; // hour
        }
        else if (component == 4)
        {
            return self.minutes.count; // minute
        }
        else if (component == 5)
        {
            return self.seconds.count;
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDH)
    {
        if (component == 0)
        {
            return self.years.count; // year
        }
        else if (component == 1)
        {
            return self.months.count; // month
        }
        else if (component == 2)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; // day
        }
        else if (component == 3)
        {
            return self.hours.count; // hour
        }
    }
    else if (self.dateShowType == DateShowingTypeYMD) // 3 show year-month-day
    {
        if (component == 0)
        {
            return self.years.count; // year
        }
        else if (component == 1)
        {
            return self.months.count; // month
        }
        else if (component == 2)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; // day
        }
    }
    else if (self.dateShowType == DateShowingTypeYM) // 8 show year-month
    {
        if (component == 0)
        {
            return self.years.count; // year
        }
        else if (component == 1)
        {
            return self.months.count; // month
        }
    }
    else if (self.dateShowType == DateShowingTypeMDHM) // 4 show month-day Hour:minute
    {
        if (component == 0)
        {
            return self.months.count; // months
        }
        else if (component == 1)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; // days
        }
        else if (component == 2)
        {
            return self.hours.count;
        }
        else if (component == 3)
        {
            return self.minutes.count;
        }
    }
    else if (self.dateShowType == DateShowingTypeDHM) // 5 show day Hour : minute
    {
        if (component == 0)
        {
            return [self caculateDaysFromMonth:self.currentMonth year:self.currentYear].count; // days
        }
        else if (component == 1)
        {
            return self.hours.count; // hours
        }
        else if (component == 2)
        {
            return self.minutes.count; // minutes
        }
    }
    else if (self.dateShowType == DateShowingTypeHM)
    {
        if (component == 0)
        {
            return self.hours.count; // hours
        }
        else if (component == 1)
        {
            return self.minutes.count; // minutes
        }
    }
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    NSLog(@"%@",pickerView.subviews[0].subviews[0].subviews[2].subviews[0]);
    //    NSLog(@"row ======= %ld component ======= %ld",row,component);
    //    NSLog(@" pickerView.subviews ====== %@", pickerView.subviews);
    if (![pickerView.delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)])
    {
        [self configPickerView:pickerView titleForComponent:component];
    }
    
    if (self.dateShowType == DateShowingTypeYMDHM) // show all colums(展示 年、月、日、时、分)
    {
        if (component == 0)
        {
            // year
            return [self yearTitleForRow:row];
        }
        else if (component == 1)
        {
            // month
            return [self monthTitleForRow:row];
        }
        else if (component == 2)
        {
            // day
            return [self dayTitleForRow:row];
        }
        else if (component == 3)
        {
            // hour
            return [self hourTitleForRow:row];
        }
        else if (component == 4)
        {
            // minute
            return [self minuteTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        if (component == 0)
        {
            // year
            return [self yearTitleForRow:row];
        }
        else if (component == 1)
        {
            // month
            return [self monthTitleForRow:row];
        }
        else if (component == 2)
        {
            // day
            return [self dayTitleForRow:row];
        }
        else if (component == 3)
        {
            // hour
            return [self hourTitleForRow:row];
        }
        else if (component == 4)
        {
            // minute
            return [self minuteTitleForRow:row];
        }
        else if (component == 5)
        {
            // second
            return [self secondTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDH) // show year-month-day hour
    {
        if (component == 0)
        {
            // year
            return [self yearTitleForRow:row];
        }
        else if (component == 1)
        {
            // month
            return [self monthTitleForRow:row];
        }
        else if (component == 2)
        {
            // day
            return [self dayTitleForRow:row];
        }
        else if (component == 3)
        {
            // hour
            return [self hourTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMD) // show year-month-day
    {
        if (component == 0)
        {
            // year
            return [self yearTitleForRow:row];
        }
        else if (component == 1)
        {
            // month
            return [self monthTitleForRow:row];
        }
        else if (component == 2)
        {
            // day
            return [self dayTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeYM) // show year-month
    {
        if (component == 0)
        {
            // year
            return [self yearTitleForRow:row];
        }
        else if (component == 1)
        {
            // month
            return [self monthTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeMDHM) // show month-day Hour:minute
    {
        if (component == 0)
        {
            // month
            return [self monthTitleForRow:row];
        }
        else if (component == 1)
        {
            // day
            return [self dayTitleForRow:row];
        }
        else if (component == 2)
        {
            // hou
            return [self hourTitleForRow:row];
        }
        else if (component == 3)
        {
            // minute
            return [self minuteTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeDHM) // show day Hour : minute
    {
        if (component == 0)
        {
            // day
            return [self dayTitleForRow:row];
        }
        else if (component == 1)
        {
            // hour
            return [self hourTitleForRow:row];
        }
        else if (component == 2)
        {
            // minute
            return [self minuteTitleForRow:row];
        }
    }
    else if (self.dateShowType == DateShowingTypeHM)
    {
        if (component == 0)
        {
            // hour
            return [self hourTitleForRow:row];
        }
        else if (component == 1)
        {
            // minute
            return [self minuteTitleForRow:row];
        }
    }
    
    return @"123";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.dateShowType == DateShowingTypeYMDHM) // 1 show all colums(展示 年、月、日、时、分)
    {
        if (component == 0)
        {
            [self updateDateAcordingToYearAtRow:row inComponent:component]; // year
        }
        else if (component == 1)
        {
            // month
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
            [pickerView reloadComponent:component+1];
            NSInteger selectedRow = [pickerView selectedRowInComponent:component+1];
            self.currentDay = [self.days[selectedRow] intValue];
        }
        else if (component == 2)
        {
            self.currentDay = [self.days[row] intValue]; // day
        }
        else if (component == 3)
        {
            self.currentHour = [self.hours[row] intValue]; // hour
        }
        else if (component == 4)
        {
            // minute
            self.currentMinute = [self.minutes[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDHMS)
    {
        if (component == 0)
        {
            // year
            [self updateDateAcordingToYearAtRow:row inComponent:component];
        }
        else if (component == 1)
        {
            // month
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
            [pickerView reloadComponent:component+1];
            NSInteger selectedRow = [pickerView selectedRowInComponent:component+1];
            self.currentDay = [self.days[selectedRow] intValue];
        }
        else if (component == 2)
        {
            // day
            self.currentDay = [self.days[row] intValue];
        }
        else if (component == 3)
        {
            // hour
            self.currentHour = [self.hours[row] intValue];
        }
        else if (component == 4)
        {
            // minute
            self.currentMinute = [self.minutes[row] intValue];
        }
        else if (component == 5)
        {
            self.currentSecond = [self.seconds[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMDH)  // show year-month-day hour
    {
        if (component == 0)
        {
            // year
            // 更新日期
            [self updateDateAcordingToYearAtRow:row inComponent:component];
        }
        else if (component == 1)
        {
            // month
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
            [pickerView reloadComponent:component+1];
            NSInteger selectedRow = [pickerView selectedRowInComponent:component+1];
            self.currentDay = [self.days[selectedRow] intValue];
        }
        else if (component == 2)
        {
            // day
            self.currentDay = [self.days[row] intValue];
        }
        else if (component == 3)
        {
            // hour
            self.currentHour = [self.hours[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeYMD) // show year-month-day
    {
        if (component == 0)
        {
            // year
            [self updateDateAcordingToYearAtRow:row inComponent:component];
        }
        else if (component == 1)
        {
            // month
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
            [pickerView reloadComponent:component+1];
            NSInteger selectedRow = [pickerView selectedRowInComponent:component+1];
            self.currentDay = [self.days[selectedRow] intValue];
        }
        else if (component == 2)
        {
            // day
            self.currentDay = [self.days[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeYM) // show year-month
    {
        if (component == 0)
        {
            // year
            self.currentYear = [self.years[row] intValue];
        }
        else if (component == 1)
        {
            // month
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeMDHM) // show month-day Hour:minute
    {
        if (component == 0)
        {
            // months
            // 更新日期
            self.currentMonth = [self.months[row] intValue];
            [pickerView reloadComponent:component+1];
            NSInteger selectedRow = [pickerView selectedRowInComponent:component+1];
            self.currentDay = [self.days[selectedRow] intValue];
            
        }
        else if (component == 1)
        {
            // days
            self.currentDay = [self.days[row] intValue];
        }
        else if (component == 2)
        {
            self.currentHour = [self.hours[row] intValue];
        }
        else if (component == 3)
        {
            self.currentMinute = [self.minutes[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeDHM) // show day Hour : minute
    {
        if (component == 0)
        {
            // days
            self.currentDay = [self.days[row] intValue];
        }
        else if (component == 1)
        {
            // hours
            self.currentHour = [self.hours[row] intValue];
        }
        else if (component == 2)
        {
            // minutes
            self.currentMinute = [self.minutes[row] intValue];
        }
    }
    else if (self.dateShowType == DateShowingTypeHM) // HH:mm
    {
        if (component == 0)
        {
            // hours
            self.currentHour = [self.hours[row] intValue];
        }
        else if (component == 1)
        {
            // minutes
            self.currentMinute = [self.minutes[row] intValue];
        }
    }
    
    NSString *dateString = self.dateString;
    self.topBar.titleLabel.text = dateString;
    
    // return date string
    if (self.datePickerdelegate && [self.datePickerdelegate respondsToSelector:@selector(pickerView:didSelectedDateString:)])
    {
        [self.datePickerdelegate pickerView:self didSelectedDateString:dateString];
    }
}

// set component width
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    CGFloat width = self.componentWidth ? self.componentWidth : floor((window.frame.size.width - kSideSpacing * 2) / self.numberOfComponents);
    return width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return self.rowHeight ? self.rowHeight : 50;
}


@end
