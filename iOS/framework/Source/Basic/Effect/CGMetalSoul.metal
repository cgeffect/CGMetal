//
//  CGMetalSoul.metal
//  CGMetal
//
//  Created by Jason on 2021/6/19.
//

#include "../CGMetalHeader.h"

fragment float4 kCGMetalSoulFragmentShader(VertexOut in [[ stage_in ]],
                                           texture2d<float, access::sample> tex [[ texture(0) ]],
                                           constant float *time [[ buffer(0) ]] ) {

    float2 varyTextCoord = in.texCoordinate;

    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;

    // 0~1
    float value = time[0];
    float mod = int(value * 10) % int(duration * 10) / 10.0;
    float progress = mod / duration;
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + (maxScale - 1.0) * progress;

    float weakX = 0.5 + (varyTextCoord.x - 0.5) / scale;
    float weakY = 0.5 + (varyTextCoord.y - 0.5) / scale;
    float2 weakTextureCoords = float2(weakX, weakY);

    float4 weakMask = tex.sample(texSampler, weakTextureCoords);
    
    float4 mask = tex.sample(texSampler, varyTextCoord);

    return mask * (1.0 - alpha) + weakMask * alpha;
    
}

