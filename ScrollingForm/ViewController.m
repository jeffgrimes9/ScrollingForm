//
//  ViewController.m
//  ScrollingForm
//
//  Created by Jeff Grimes on 8/21/12.
//  Copyright (c) 2012 Jeff Grimes. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

const int pickerTag = 1001;
const int numberTag = 1002;

- (void)viewDidAppear {
    [super viewDidAppear:YES];
}

- (id)init {
    if (self = [super initWithNibName:@"ScrollingForm" bundle:nil]) {
        optionsFirstText = @"-- Select Option --";
        options = [[NSArray alloc] initWithObjects:optionsFirstText,
                          @"Option 1",
                          @"Option 2",
                          @"Option 3",
                          @"Option 4",
                          @"Option 5",
                          @"Option 6",
                          @"Option 7",
                          @"Option 8",
                          @"Option 9",
                          @"Option 10",
                          nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.scrollView) {
        [self positionScrollView:self.scrollView];
        [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height)];
    }
    
    self.dateField.text = @"";
    self.textField.text = @"";
    self.numberField.text = @"";
    self.pickerField.text = @"";
    
    [self.view addSubview:self.scrollView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.datePickerMode = UIDatePickerModeDate;
    NSDateComponents *date = [[NSDateComponents alloc] init];
    date.year = 2000;
    date.month = 1;
    date.day = 1;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    datePicker.date = [calendar dateFromComponents:date];
    [calendar release];
    [date release];
    [datePicker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
    self.dateField.inputView = datePicker;
    [datePicker release];
    
    UIPickerView *optionsPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    optionsPicker.delegate = self;
    optionsPicker.dataSource = self;
    optionsPicker.tag = pickerTag;
    [optionsPicker setShowsSelectionIndicator:YES];
    self.pickerField.inputView = optionsPicker;
    [optionsPicker release];
    
    [self.numberField setTag:numberTag];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self updateFormCompletion];
}

- (void)repositionScrollView {
    if (self.activeField == nil) {
        activeFieldHeight = 0;
    }
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, activeFieldHeight, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // scroll the active text field into view
    CGRect frameRect = self.view.frame;
    frameRect.size.height -= activeFieldHeight;
    
    float offsetMultiplier = 1.98; // decrease for greater adjustement of view when textField is pressed
    CGPoint scrollPoint = CGPointMake(0.0, self.activeField.frame.origin.y - (activeFieldHeight * offsetMultiplier));
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)scrollToBottom {
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField tag] == numberTag) {
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
    }
    self.activeField = textField;
    activeFieldHeight = self.activeField.frame.size.height;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (void)textDidChange {
    [self updateFormCompletion];
}

- (void)dateDidChange {
    UIDatePicker *datePicker = (UIDatePicker *)self.dateField.inputView;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self.dateField setText:[dateFormatter stringFromDate:datePicker.date]];
    [dateFormatter release];
    [self textDidChange];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    // adjust the scrollView's height when the keyboard is open
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    int keyboardHeight = keyboardSize.height;
    int hackSubtractor = 88; // XXX this number is a hack and I experimented until I found one that worked. It ensures that the scrollView takes up all of the screen that is covered by neither the header/footer nor the keyboard.
    int keyBoardOffset = keyboardHeight - hackSubtractor;
    [self repositionScrollView];
    [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height - keyBoardOffset)];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.activeField resignFirstResponder];
    [self.scrollView setFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.view.frame.size.height)];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == pickerTag) {
        return [options count];
    } else {
        return 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == pickerTag) {
        return [options objectAtIndex:row];
    } else {
        return @"Error";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == pickerTag) {
        [self.pickerField setText:[options objectAtIndex:row]];
        [self textDidChange];
    } else {
        return;
    }
}

- (void)updateFormCompletion {
    formIncomplete = ([self isInvalidDate] || [self isInvalidText] || [self isInvalidPicker] || [self isInvalidNumber]);
    if (formIncomplete) {
        [self.submitButton setTitle:@"Form Incomplete" forState:UIControlStateNormal];
    } else {
        [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    }
}

- (BOOL)isInvalidDate {
    NSString *date = [self.dateField text];
    return (!date || [date isEqualToString:@""]);
}

- (BOOL)isInvalidText {
    NSString *text = [self.textField text];
    return (!text || [text isEqualToString:@""]);
}

- (BOOL)isInvalidPicker {
    NSString *picker = [self.pickerField text];
    return (!picker || [picker isEqualToString:@""] || [picker isEqualToString:optionsFirstText]);
}

- (BOOL)isInvalidNumber {
    NSString *number = [self.numberField text];
    return (!number || [number isEqualToString:@""]);
}

- (IBAction)submitButtonPressed {
    [self dismissKeyboard:nil];
    
    // clean up formatting in free-entry fields
    [self.textField setText:[self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self.numberField setText:[self.numberField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    if (formIncomplete) {
        NSString *errorTitle = @"Form Incomplete";
        NSString *errorMessage = @"Invalid entries in these fields:";
        if ([self isInvalidDate]) {
            errorMessage = [errorMessage stringByAppendingString:@"\n- Date"];
        }
        if ([self isInvalidText]) {
            errorMessage = [errorMessage stringByAppendingString:@"\n- Text"];
        }
        if ([self isInvalidPicker]) {
            errorMessage = [errorMessage stringByAppendingString:@"\n- Picker"];
        }
        if ([self isInvalidNumber]) {
            errorMessage = [errorMessage stringByAppendingString:@"\n- Number"];
        }
        
        NSString *cancelButtonText = @"Go Back";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:self cancelButtonTitle:cancelButtonText otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Form Complete" message:@"Thank you for filling out all of the information in this form." delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
        [alertView show];
    }
}

- (void)positionScrollView:(UIScrollView*)scrollView {
    CGRect contentRect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    for (UIView* view in scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    if (contentRect.size.height <= (scrollView.frame.size.height + 0.1)) {
        contentRect = CGRectMake(contentRect.origin.x,
                                 contentRect.origin.y,
                                 contentRect.size.width,
                                 contentRect.size.height + 10.0f); // with 1.0 instead of 10.0 as the extra padding, the scroll indicators don't show when you scroll/bounce the scrollview.
    }
    scrollView.contentSize = contentRect.size;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.scrollView = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [options release];
    self.scrollView = nil;
    self.submitButton = nil;
    self.activeField = nil;
    self.dateField = nil;
    self.textField = nil;
    self.pickerField = nil;
    self.numberField = nil;
    [super dealloc];
}

@end