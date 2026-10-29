// Copyright © 2021 Audulus LLC. All rights reserved.

#import <XCTest/XCTest.h>
#import "../../Sources/vger/vgerGlyphCache.h"
#import <MetalKit/MetalKit.h>
#import "testUtils.h"

@interface vgerGlyphCacheTests : XCTestCase {
    id<MTLDevice> device;
    id<MTLCommandQueue> queue;
}

@end

@implementation vgerGlyphCacheTests

- (void)setUp {
    device = MTLCreateSystemDefaultDevice();
    queue = [device newCommandQueue];
}

- (void)testGlyphAtlas {

    auto cache = [[vgerGlyphCache alloc] initWithDevice:device];

    auto font = CTFontCreateWithName((__bridge CFStringRef)@"Helvetica", 12.0, NULL);

    for(int i=0;i<100;++i) {
        [cache getGlyph:i font:font scale:1.0f];
    }

    CFRelease(font);

    id<MTLCommandBuffer> buf = [queue commandBuffer];
    [cache update:buf];

    auto atlas = [cache getAltas];

    // Sync texture on macOS
    #if TARGET_OS_OSX
    auto blitEncoder = [buf blitCommandEncoder];
    [blitEncoder synchronizeResource:atlas];
    [blitEncoder endEncoding];
    #endif

    [buf commit];
    [buf waitUntilCompleted];

    showTexture(atlas, @"glyph_atlas.png");

}

@end
