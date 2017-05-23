//
//  LJEditViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 17/10/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJEditViewController.h"
#import "LJTextViewController.h"
#import "journalStore.h"

@interface LJEditViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong)UITextView *textView;
@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIImageView *showDate;
@property (nonatomic, strong)UIImageView *showLocation;
@property (nonatomic, strong)UILabel *dateLabel;
@property (nonatomic, strong)UILabel *locationLabel;
@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic)BOOL iCloudIsOn;

@end

@implementation LJEditViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        UIBarButtonItem *leftBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                              target:self
                                                                              action:@selector(cancel)];
        
        UIBarButtonItem *rightBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                  target:self
                                                                                  action:@selector(save)];
        
        self.navigationItem.leftBarButtonItem = leftBut;
        self.navigationItem.rightBarButtonItem = rightBut;
        self.iCloudIsOn = [[journalStore sharedStore] iCloudWasOn];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //添加tap手势，收起键盘
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    
    //imageview
    CGRect imageRect = CGRectMake(12,                                                 //x
                                  12,                                                 //y
                                  (self.view.bounds.size.width - 60) * 2/3,           //width
                                  self.view.bounds.size.width * 2/3 );                //height
    
    if (!_imageView) {
        self.imageView = [[UIImageView alloc] initWithFrame:imageRect];
    }
    self.imageView.userInteractionEnabled = YES;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 8.0;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPicture)]];
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.imageView];
    
    
    //showDate imageView
    CGRect showDateImageViewRect = CGRectMake(12 + imageRect.size.width + 20,
                                              12,
                                              self.view.bounds.size.width - imageRect.size.width - 44,
                                              (self.imageView.frame.size.height - 10) / 2);
    if (!_showDate) {
        self.showDate = [[UIImageView alloc] initWithFrame:showDateImageViewRect];
    }
    self.showDate.image = [UIImage imageNamed:@"show_date"];
    
    [self.view addSubview:self.showDate];
    
    //date label
    CGRect dateRect = CGRectMake(20 + self.imageView.frame.size.width + 20,
                                 20 + 12,
                                 self.showDate.bounds.size.width,
                                 100);
    
    if (!_dateLabel) {
        self.dateLabel = [[UILabel alloc] initWithFrame:dateRect];
    }
    self.dateLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.dateLabel];
    
    
    //showLocation imageview
    CGRect showLocationImageViewRect = CGRectMake(self.showDate.frame.origin.x,
                                                  self.showDate.frame.origin.y + self.showDate.frame.size.height + 10,
                                                  self.showDate.frame.size.width,
                                                  self.showDate.frame.size.height);
    
    if (!_showLocation) {
        self.showLocation = [[UIImageView alloc] initWithFrame:showLocationImageViewRect];
    }
    self.showLocation.image = [UIImage imageNamed:@"show_location"];
    [self.view addSubview:self.showLocation];
    
    //location Label
    CGRect locationRect = CGRectMake(self.dateLabel.frame.origin.x,
                                     12 + 120 + 10 + 20,
                                     121,
                                     100);
    if (!_locationLabel) {
        self.locationLabel = [[UILabel alloc] initWithFrame:locationRect];
    }
    [self.view addSubview:self.locationLabel];
    
    //locationManager
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    [self initLocationManager:self.locationManager];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.locationManager.delegate = self;
    
    
    //textView
    CGRect textRect = CGRectMake(0.0,
                                 12 + self.imageView.frame.size.height + 12,
                                 self.view.bounds.size.width,
                                 self.view.bounds.size.height - self.imageView.frame.size.height - 24);
    
    if (!_textView) {
        self.textView = [[UITextView alloc] initWithFrame:textRect];
    }
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 8.0;
    self.textView.scrollEnabled = YES;
    self.textView.delegate = self;
    self.textView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:20];
    self.textView.backgroundColor = [UIColor colorWithRed:255 /255.0 green:248 /255.0 blue:221 /255.0 alpha:1];
    
    [self.view addSubview:self.textView];
}

- (void)viewWillAppear:(BOOL)animated
{
    //在这个方法之前才获得journal，所以如果把图片、日期、文字的设置放在viewdidload和init里都不会显示，因为那时还都是nil，唯有放这里
    //photo
    
    if (self.photo) {
        self.imageView.image = self.photo;
    } else {
        self.imageView.image = [UIImage imageNamed:@"imageView"];
    }
    
    //journal
    self.textView.text = self.journal.journal;
    
    //dateLaber
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    self.dateLabel.text = [dateFormatter stringFromDate:self.journal.date];
    self.dateLabel.numberOfLines = 0;                                       //多行显示
    
    //locationLabel
    self.locationLabel.text = self.journal.location;
    self.locationLabel.numberOfLines = 0;         //多行显示
    
    //locationManager
    if (self.isNew) {
        [self.locationManager startUpdatingLocation];
    }

    
    //监听
    //键盘出现
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    //键盘消失
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHidden)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = locations.lastObject;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placeMarks, NSError *error){
        CLPlacemark *placeMark = placeMarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@, %@", [[placeMark addressDictionary] objectForKey:@"City"], [[placeMark addressDictionary] objectForKey:@"Country"]];
        self.journal.location = address;
        self.locationLabel.text = [NSString stringWithFormat:@"%@", address];
        [self.locationManager stopUpdatingLocation];
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"ERROR:%@", error);
}

- (void)initLocationManager:(CLLocationManager *)manager
{
    //是否开启定位
    BOOL enable = [CLLocationManager locationServicesEnabled];
    //是否有权限
    int status = [CLLocationManager authorizationStatus];
    
    //如果没有权限或者没开通定位
    if (!enable || status < 3) {
        //如果iOS版本是8及以上
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            //获取授权
            [manager requestWhenInUseAuthorization];
        }
        
        //alertview在iOS8被UIAlertController替代
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Couldn't get your current location, please turn on GPS in privacy.", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Setting", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alert animated:YES completion:NULL];
    }
}


- (void)cancel
{
    [self.view endEditing:YES];
    if (self.isNew) {
        [[journalStore sharedStore] removeJournal:self.journal];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];     
}

- (void)save
{
    [self.view endEditing:YES];
    self.journal.journal = self.textView.text;
    self.journal.photo = self.photo;
    self.journal.thumbnail = [self.journal setThumbnailFromImage:self.photo];
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.iCloudIsOn) {
            if (self.isNew) {
                [[journalStore sharedStore] uploadJournalToCloud:self.journal];
            } else {
                [[journalStore sharedStore] modifyJournalOnCloud:self.journal journalIsChanged:self.journalIsChanged photoIsChanged:self.photoIsChanged];
            }
        }
    }];
}

 //添加图片
 - (void)addPicture
{
    //action sheet在iOS8被UIAlertController替代
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.photo) {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove photo", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            self.imageView.image = [UIImage imageNamed:@"imageView"];
            self.photo = nil;
            self.photoIsChanged = YES;
        }]];
    } else {
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take a photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            self.journal.journal = self.textView.text;
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            self.journal.journal = self.textView.text;
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }]];
        
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.photo = [self.journal clipPhotoFromImage:image];
    self.photoIsChanged = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}




- (void)viewWillDisappear:(BOOL)animated
{
    //注销监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



//键盘出现时上移高度
- (void)keyboardDidShow:(NSNotification *)paramNotification
{
    //获取键盘高度
    NSValue *keyboardRectAsObject = [[paramNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    //textview上移一个键盘的高度，还要加上动画上弹的高度
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height + self.imageView.frame.size.height / 2, 0);
}


//键盘消失后恢复
- (void)keyboardDidHidden
{
    self.textView.contentInset = UIEdgeInsetsZero;
}


//动画：开始打字，输入框上弹
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.journalIsChanged = YES;
    [UIView animateWithDuration:2.0
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
                         self.textView.frame = CGRectMake(0.0,
                                                          100.0,
                                                          self.view.bounds.size.width,
                                                          self.view.bounds.size.height);
                         self.dateLabel.alpha = 0;
                         self.locationLabel.alpha = 0;
                         self.imageView.userInteractionEnabled = NO;
                     }completion:NULL];
}

//动画：打字结束，输入框复位
- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView animateWithDuration:2.0
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
                         self.textView.frame = CGRectMake(0.0,
                                                          12 + self.imageView.frame.size.height + 12,
                                                          self.view.bounds.size.width,
                                                          self.view.bounds.size.height - self.imageView.frame.size.height - 24);
                         self.dateLabel.alpha = 1;
                         self.locationLabel.alpha = 1;
                         self.imageView.userInteractionEnabled = YES;
                     }completion:NULL];
}

//点击背景收起键盘
- (void)tapBackground:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
