#import <Foundation/Foundation.h>

#import <SPTDataLoader/SPTDataLoader.h>

@interface SPTDataLoaderDelegateMock : NSObject <SPTDataLoaderDelegate>

@property (nonatomic, assign) BOOL supportChunks;
@property (nonatomic, assign) NSUInteger numberOfCallsToSuccessfulResponse;
@property (nonatomic, assign) NSUInteger numberOfCallsToErrorResponse;
@property (nonatomic, assign) NSUInteger numberOfCallsToCancelledRequest;
@property (nonatomic, assign) NSUInteger numberOfCallsToReceiveDataChunk;
@property (nonatomic, assign) NSUInteger numberOfCallsToReceivedInitialResponse;

@end
