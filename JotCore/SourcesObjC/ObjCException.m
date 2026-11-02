// Copyright 2026 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ObjCException.h"

@implementation ObjCException

+ (BOOL)execute:(NS_NOESCAPE void (^)(void))tryBlock error:(__autoreleasing NSError * _Nullable * _Nullable)error {
    @try {
        if (tryBlock) {
            tryBlock();
        }
        return YES;
    }
    @catch (NSException *exception) {
        if (error) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            userInfo[NSLocalizedDescriptionKey] = exception.reason ?: @"Objective-C exception";
            if (exception.name) {
                userInfo[@"NSExceptionName"] = exception.name;
            }
            if (exception.userInfo) {
                userInfo[@"NSExceptionUserInfo"] = exception.userInfo;
            }
            *error = [NSError errorWithDomain:@"com.jay3oh5.sayo.ObjCException"
                                         code:-1
                                     userInfo:userInfo];
        }
        return NO;
    }
}

@end
