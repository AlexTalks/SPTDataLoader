/*
 * Copyright (c) 2015 Spotify AB.
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SPTDataLoaderRequestMethod) {
    SPTDataLoaderRequestMethodGet,
    SPTDataLoaderRequestMethodPost,
    SPTDataLoaderRequestMethodPut,
    SPTDataLoaderRequestMethodDelete
};

extern NSString * const SPTDataLoaderRequestHostHeader;

/**
 * A representing of the request to make to the backend
 */
@interface SPTDataLoaderRequest : NSObject <NSCopying>

/**
 * The URL to request
 */
@property (nonatomic, strong) NSURL *URL;
/**
 * The number of times to retry this request in the event of a failure
 * @discussion The default is 0
 */
@property (nonatomic, assign) NSUInteger maximumRetryCount;
/**
 * The body of the request
 */
@property (nonatomic, strong) NSData *body;
/**
 * The headers represented by a dictionary
 */
@property (nonatomic, strong, readonly) NSDictionary *headers;
/**
 * Whether the result of the request should be delivered in chunks
 * @discussion This will only generate chunks if the data loader delegate is set up to receive them
 */
@property (nonatomic, assign) BOOL chunks;
/**
 * The cache policy to use for this request
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
/**
 * The method used to send the request
 * @discussion The default request method is SPTDataLoaderRequestMethodGet
 */
@property (nonatomic, assign) SPTDataLoaderRequestMethod method;
/**
 * Any user information tied to this request
 */
@property (nonatomic, strong) NSDictionary *userInfo;
/**
 * An identifier for uniquely identifying the request
 */
@property (nonatomic, assign, readonly) int64_t uniqueIdentifier;

/**
 * Class constructor
 * @param URL The URL to query
 */
+ (instancetype)requestWithURL:(NSURL *)URL;

/**
 * Adds a header value
 * @param value The value of the header field
 * @param header The header field to add the value to
 */
- (void)addValue:(NSString *)value forHeader:(NSString *)header;
/**
 * Removes a header value
 * @param header The header field to remove
 */
- (void)removeHeader:(NSString *)header;

@end
