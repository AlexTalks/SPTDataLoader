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
#import "ViewController.h"

#import <SPTDataLoader/SPTDataLoaderFactory.h>
#import <SPTDataLoader/SPTDataLoaderService.h>
#import <SPTDataLoader/SPTDataLoader.h>
#import <SPTDataLoader/SPTDataLoaderRequest.h>

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logInButtonTouchedUpInside:(id)sender
{
    NSURLComponents *accountsComponents = [NSURLComponents new];
    accountsComponents.scheme = @"https";
    accountsComponents.host = @"accounts.spotify.com";
    accountsComponents.path = @"/authorize";
    
    NSURLQueryItem *responseTypeQueryItem = [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"];
    NSURLQueryItem *clientIDQueryItem = [NSURLQueryItem queryItemWithName:@"client_id" value:@"c0af246cb182480cb614d27026bfc9c3"];
    NSURLQueryItem *scopeQueryItem = [NSURLQueryItem queryItemWithName:@"scope" value:@"playlist-read-private"];
    NSURLQueryItem *redirectURIQueryItem = [NSURLQueryItem queryItemWithName:@"redirect_uri" value:@"sptdataloaderdemo://login"];
    NSURLQueryItem *stateQueryItem = [NSURLQueryItem queryItemWithName:@"state" value:@"AAAAAAAAAAAAAAAA"];
    
    accountsComponents.queryItems = @[ responseTypeQueryItem, clientIDQueryItem, scopeQueryItem, redirectURIQueryItem, stateQueryItem ];
    
    [[UIApplication sharedApplication] openURL:accountsComponents.URL];
}

@end
