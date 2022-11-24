//
//  CGMetalScaleAlpha.metal
//  VGAMac
//
//  Created by Jason on 2022/1/2.
//

#include <metal_stdlib>
using namespace metal;
#include "../CGMetalHeader.h"

fragment float4
kCGMetalScaleAlphaFragmentShader(VertexOut in [[ stage_in ]],
                           texture2d<float, access::sample> tex [[ texture(0) ]],
                           constant float *value [[ buffer(0) ]] ) {
    
    //0-0.25 -> 0-0.5
    if (in.texCoordinate.x >= 0 && in.texCoordinate.x <= 0.25) {
        if (in.texCoordinate.y >= 0 && in.texCoordinate.y <= 0.5) {
            float leftX = in.texCoordinate.x * 2;
            float leftY = in.texCoordinate.y * 2;
            float4 alpha = tex.sample(texSampler, float2(leftX, leftY));
            return alpha;
        } else {
            return float4(0,1,0,1);
        }
    } else if (in.texCoordinate.x > 0.25 && in.texCoordinate.x <= 0.75) {
        //0.25-0.75 -> 0.5-1
        float tcx = in.texCoordinate.x + 0.25;
        float4 rgb = tex.sample(texSampler, float2(tcx, in.texCoordinate.y));
        return rgb;
    } else {
        return float4(1,0,0,1);
    }
    
}
