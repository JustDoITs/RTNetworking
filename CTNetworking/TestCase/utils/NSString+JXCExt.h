//
//  NSString+JXCExt.h
//  CTNetworking
//
//  Created by 任我行 on 2017/7/21.
//  Copyright © 2017年 Long Fan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JXCExt)
/**
 生成12位的随机数
 
 @return 12位的随机数
 */
+ (NSString *)randomString;



/**
 生成字符串对应的MD5
 
 @return MD5字符串
 */
- (NSString *)stringToMD5;
@end
