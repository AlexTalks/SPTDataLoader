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
#import <XCTest/XCTest.h>

#import "SPTDataLoaderRequestTaskHandler.h"

#import "SPTDataLoaderRequestResponseHandlerMock.h"
#import "SPTDataLoaderRateLimiter.h"
#import "SPTDataLoaderResponse.h"
#import "SPTDataLoaderRequest.h"
#import "NSURLSessionTaskMock.h"

@interface SPTDataLoaderRequestTaskHandler ()

@property (nonatomic, assign) NSUInteger retryCount;

@end

@interface SPTDataLoaderRequestTaskHandlerTest : XCTestCase

@property (nonatomic, strong) SPTDataLoaderRequestTaskHandler *handler;

@property (nonatomic, strong) SPTDataLoaderRequestResponseHandlerMock *requestResponseHandler;
@property (nonatomic, strong) SPTDataLoaderRateLimiter *rateLimiter;
@property (nonatomic, strong) SPTDataLoaderRequest *request;
@property (nonatomic, strong) NSURLSessionTaskMock *task;

@end

@implementation SPTDataLoaderRequestTaskHandlerTest

#pragma mark XCTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.requestResponseHandler = [SPTDataLoaderRequestResponseHandlerMock new];
    self.rateLimiter = [SPTDataLoaderRateLimiter rateLimiterWithDefaultRequestsPerSecond:10.0];
    self.request = [SPTDataLoaderRequest requestWithURL:[NSURL URLWithString:@"https://spclient.wg.spotify.com/thing"]];
    self.task = [NSURLSessionTaskMock new];
    self.handler = [SPTDataLoaderRequestTaskHandler dataLoaderRequestTaskHandlerWithTask:self.task
                                                                                 request:self.request
                                                                  requestResponseHandler:self.requestResponseHandler
                                                                             rateLimiter:self.rateLimiter];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark SPTDataLoaderRequestOperationTest

- (void)testNotNil
{
    XCTAssertNotNil(self.handler, @"The handler should not be nil after its construction");
}

- (void)testReceiveDataRelayedToRequestResponseHandler
{
    self.request.chunks = YES;
    NSData *data = [@"thing" dataUsingEncoding:NSUTF8StringEncoding];
    [self.handler receiveData:data];
    XCTAssertEqual(self.requestResponseHandler.numberOfReceivedDataRequestCalls, 1, @"The handler did not relay the received data onto its request response handler");
}

- (void)testRelaySuccessfulResponse
{
    [self.handler completeWithError:nil];
    XCTAssertEqual(self.requestResponseHandler.numberOfSuccessfulDataResponseCalls, 1, @"The handler did not relay the successful response onto its request response handler");
}

- (void)testRelayFailedResponse
{
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil];
    [self.handler receiveResponse:nil];
    [self.handler completeWithError:error];
    XCTAssertEqual(self.requestResponseHandler.numberOfFailedResponseCalls, 1, @"The handler did not relay the failed response onto its request response handler");
}

- (void)testRelayRetryAfterToRateLimiter
{
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:SPTDataLoaderResponseHTTPStatusCodeOK
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{ @"Retry-After" : @"60" }];
    [self.handler receiveResponse:httpResponse];
    [self.handler completeWithError:nil];
    XCTAssertEqual(floor([self.rateLimiter earliestTimeUntilRequestCanBeExecuted:self.request]), 59.0, @"The retry-after header was not relayed to the rate limiter");
}

- (void)testRetry
{
    self.handler.retryCount = 10;
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:SPTDataLoaderResponseHTTPStatusCodeNotFound
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{ @"Retry-After" : @"60" }];
    [self.handler receiveResponse:httpResponse];
    [self.handler completeWithError:nil];
    XCTAssertEqual(self.requestResponseHandler.numberOfSuccessfulDataResponseCalls, 0, @"The handler did relay a successful response onto its request response handler when it should have silently retried");
    XCTAssertEqual(self.requestResponseHandler.numberOfFailedResponseCalls, 0, @"The handler did relay a failed response onto its request response handler when it should have silently retried");
}

- (void)testDataCreationWithContentLengthFromResponse
{
    // It's times like these... I wish I had the SPTSingletonSwizzler ;)
    // Simply don't know how to test NSMutableData dataWithCapacity is called correctly
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:SPTDataLoaderResponseHTTPStatusCodeOK
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:@{ @"Content-Length" : @"60" }];
    NSURLSessionResponseDisposition disposition = [self.handler receiveResponse:httpResponse];
    XCTAssertEqual(disposition, NSURLSessionResponseAllow, @"The operation should have returned an allow disposition");
}

- (void)testStartCallsResume
{
    [self.handler start];
    XCTAssertEqual(self.task.numberOfCallsToResume, 1, @"The task should be resumed on start if no backoff and rate-limiting is applied");
}

- (void)testResponseCreatedIfNoInitialDataReceived
{
    [self.handler completeWithError:nil];
    XCTAssertNotNil(self.requestResponseHandler.lastReceivedResponse, @"The response should be created even without an initial receivedResponse call");
}

@end
