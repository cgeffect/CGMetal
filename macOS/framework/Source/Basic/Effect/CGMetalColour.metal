//
//  CGMetalColour.metal
//  CGMetal
//
//  Created by Jason on 2021/6/20.
//

#include "../CGMetalHeader.h"

fragment float4
kCGMetalColourFragmentShader(VertexOut in [[ stage_in ]],
                           texture2d<float, access::sample> tex [[ texture(0) ]],
                           constant float *value [[ buffer(0) ]] ) {

    
    if (in.texCoordinate.x > value[0]) {
        float4 color = tex.sample(texSampler, in.texCoordinate);
        float v = (color.r + color.g + color.b) / 3.0;
        return float4(float3(v), color.a);
    } else {
        return tex.sample(texSampler, in.texCoordinate);
    }
    
}

