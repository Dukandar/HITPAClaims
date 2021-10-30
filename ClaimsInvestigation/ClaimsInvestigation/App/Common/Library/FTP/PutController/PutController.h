//
//  PutController.h
//  ZipFileExample
//
//  Created by Sunilkumar Basappa on 22/11/17.
//  Copyright © 2017 iNube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^FTPCompletionHandler)(BOOL isSucess,NSError *error);


@interface PutController : NSObject


+ (id) sharedPutController;
- (void)startSend:(NSData *)dataToUpload withURL:(NSURL *)toURL withUsername:(NSString *)username andPassword:(NSString *)password;
@end
