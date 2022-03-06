//
//  CGMetalGray.metal
//  CGMetal
//
//  Created by Jason on 2021/10/21.
//

#include "../CGMetalHeader.h"

fragment float4
kCGMetalGrayFragmentShader(VertexOut in [[ stage_in ]],
                           texture2d<float, access::sample> tex [[ texture(0) ]],
                           constant float *value [[ buffer(0) ]] ) {

    
    if (in.texCoordinate.x > 0.5) {
        float4 color = tex.sample(texSampler, in.texCoordinate);
        float v = (color.r + color.g + color.b) / 3.0;
        return float4(float3(v), color.a);
    } else {
        return tex.sample(texSampler, in.texCoordinate);
    }
    
}
