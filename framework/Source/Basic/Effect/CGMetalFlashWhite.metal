//
//  CGMetalFlashWhite.metal
//  CGMetal
//
//  Created by Jason on 2022/1/1.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../CGMetalHeader.h"

constant int smooth = 1000;
fragment float4 kCGMetakFlashFragment(
    VertexOut input [[ stage_in ]],
    texture2d<float, access::sample> texture [[ texture(0) ]],
    constant float &currentTime [[ buffer(0) ]]
    ) {
    long tick = ((long)(currentTime * smooth)) % smooth;
    float freq = 1.0 / smooth * tick;
    
    float progress = max(sin(freq * M_PI_F * 2), 0.0);
    
    float4 originColor = texture.sample(texSampler, input.texCoordinate);
    float4 whiteColor = float4(1.0, 1.0, 1.0, 1.0);
    
    return mix(originColor, whiteColor, progress);
}
