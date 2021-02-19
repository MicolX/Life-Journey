//
//  LJTextViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 5/25/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJTextViewController.h"
#import "LJEditViewController.h"

#define FONTNAME    @"LJFontName"
#define FONTSIZE    @"LJFontSize"

@interface LJTextViewController () <UITextViewDelegate>

@property (nonatomic, strong)NSTextAttachment *textAttachment;
@property (nonatomic, strong)NSMutableAttributedString *attributedString;
@property (nonatomic, strong)NSAttributedString *attachmentString;
@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)NSString *fontName;
@property (nonatomic)double fontSize;


@end

@implementation LJTextViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                              target:self
                                                                              action:@selector(edit)];
    
    self.navigationItem.rightBarButtonItem = rightBut;
    
    if (self.isPopUpFromCalendar) {
        UIBarButtonItem *leftBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = leftBut;
    }
    
    self.textView = [[UITextView alloc] initWithFrame:self.view.frame];
    self.textView.scrollEnabled = YES;
    self.textView.delegate = self;
    self.textView.editable = NO;
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.view.bounds.size.width / 2,
                                                                   self.navigationController.navigationBar.frame.size.height)];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = @"Life Journey";
    titleView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME]) {
        self.fontName = @"AppleGothic";
        self.fontSize = 18;
        [[NSUserDefaults standardUserDefaults] setObject:self.fontName forKey:FONTNAME];
        [[NSUserDefaults standardUserDefaults] setDouble:self.fontSize forKey:FONTSIZE];
    } else {
        self.fontName = [[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME];
        self.fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:FONTSIZE];
    }
    
    [self.view addSubview:self.textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    //插入图片
    
    self.attributedString = [[NSMutableAttributedString alloc] initWithString:self.journal.journal];
    
    self.textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
    self.textAttachment.image = self.journal.photo;
    self.attachmentString = [NSAttributedString attributedStringWithAttachment:self.textAttachment];
    [self.attributedString insertAttributedString:self.attachmentString atIndex:0];
    if (self.journal.photo) {
        NSAttributedString *enter = [[NSAttributedString alloc] initWithString:@"\n\n"];
        [self.attributedString insertAttributedString:enter atIndex:1];
    }
    
    //文字属性
    [self.attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fontName size:self.fontSize] range:NSMakeRange(0, self.attributedString.length)];
    [self.attributedString addAttribute:NSTextEffectAttributeName value:NSTextEffectLetterpressStyle range:NSMakeRange(0, self.attributedString.length)];
    
    //显示于textView
    self.textView.attributedText = self.attributedString;
    
}


- (void)edit
{
    [self.view endEditing:YES];
    LJEditViewController *editVC = [[LJEditViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
    nav.navigationBar.translucent = NO;
    editVC.journal = self.journal;
    editVC.photo = self.journal.photo;
    editVC.isNew = NO;
    [self presentViewController:nav animated:YES completion:NULL];
    
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
