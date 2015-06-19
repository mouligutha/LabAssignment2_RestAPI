//
//  ViewController.m
//  WeatherAPI
//
//  Created by Kolla, Venubabu (UMKC-Student) on 6/18/15.
//  Copyright (c) 2015 Kolla, Venubabu (UMKC-Student). All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#define TextToSpeechURL "http://translate.google.com/translate_tts?tl=en&q="

#define Twilio_URL "https://api.twilio.com/2010-04-01/Accounts/AC13834e7b7d18ffeb52f674846b2017c7/SMS/Messages"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *country;
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation ViewController

AFHTTPRequestOperationManager *manager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    manager = [AFHTTPRequestOperationManager manager];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getWeatherConditions:(id)sender {
    
    NSString *twilioSID = @"AC13834e7b7d18ffeb52f674846b2017c7";
    NSString *twilioAuthKey = @"ce7ea32845386f7aa9efbe73e8e1be43";
    NSString *fromNumber = @"+19784155546";
    NSString *ToNumber = self.phoneNumber.text;
    NSString *bodyMessage;
    
    NSLog(@"starting the application");
    NSString *locationName=self.location.text;
    NSString *countryName=self.country.text;
    NSLog(@"locationName%@",locationName);
          NSLog(@"countryName%@",countryName);
    NSString *urlString=[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@,%@",locationName,countryName];
    
    NSLog(@"URL String%@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dict = [responseObject objectForKey:@"main"];
        
        NSString *temperature= [dict objectForKey:@"temp"];
        
        NSString *grid_level=[dict objectForKey:@"grid_level"];
        
        NSString *humidiity=[dict objectForKey:@"humidity"];
    
        NSString *pressure=[dict objectForKey:@"pressure"];
        NSString *sealevel=[dict objectForKey:@"sea_level"];
        NSString *temp_min=[dict objectForKey:@"temp_min"];
        NSString *temp_max=[dict objectForKey:@"temp_max"];
        
        NSArray *array=[responseObject objectForKey:@"weather"];
        NSDictionary *dict2=[array objectAtIndex:0];
        NSString *description=[dict2 objectForKey:@"description"];
        
        
        
        
        NSLog(@"Temperature: %@", temperature);
        NSLog(@"temp_min: %@",temp_min);
        
        NSLog(@"description: %@",description);
        
        NSString *messageBody = [NSString stringWithFormat:@"Temperature: %@, Min temp: %@, temp max: %@, description: %@, Humidity: %@", temperature,temp_min,temp_max,description,humidiity];
        
        
       // _bodyMessage = [messageBody mutableCopy];
        //bodyMessage = @"Temperature: %@, Min temp: %@, temp max: %@, description: %@, Humidity: %@", temperature
        
        //Starting point to send the messages
        
        NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", twilioSID, twilioAuthKey, twilioSID];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        //Set up the body the request
        
        NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", fromNumber,ToNumber,messageBody];
        
        NSData *data =[bodyString dataUsingEncoding:NSUTF8StringEncoding];
        
        
        [request setHTTPBody:data];
        
        NSError *error;
        
        NSURLResponse *response;
        
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        //Handle the received data
        
        if(error){
            NSLog(@"Error:%@", error);
        }else{
            NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
            NSLog(@"Request sent.%@",receivedString);
        }

        //Ending of the Twilio API
        
        
        //Starting of Text To Speech API
        
        //[_messageBody resignFirstResponder];
        
        NSString *sentence = [messageBody stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSString *texturl = [NSString stringWithFormat:@"%s%@", TextToSpeechURL, sentence];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:texturl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObjective) {
            
            operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"audio/mpeg"];
            
            
            
            NSLog(@"NSObject: %@", responseObjective);
            
            NSData *audioData = responseObjective;
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
            self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil]; // audioPlayer must be a strong property. Do not create it locally
            
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
            
            // NSLog(@"responseString: %@", responseString);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error description]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }];

        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        NSLog(@"Error: %@",error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error description]
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
}
     
@end
