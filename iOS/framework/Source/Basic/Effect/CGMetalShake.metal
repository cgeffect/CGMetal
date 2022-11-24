//
//  CGMetalShake.metal
//  CGMetal
//
//  Created by Jason on 2021/6/4.
//

#include "../CGMetalHeader.h"

constant int smooth = 1000;

fragment float4 kCGMetalShakeFragmentShader(
                        VertexOut in [[ stage_in ]],
                        texture2d<float, access::sample> tex [[ texture(0) ]],
                        constant float *time [[ buffer(0) ]]
                        ) {
        
    float2 varyTextCoord = in.texCoordinate;
    float duration = 0.7;
    float maxScale = 1.1;
    float offset = 0.02;

    float value = time[0];
    float mod = int(value * 10) % int(duration * 10) / 10.0;
    float progress = mod / duration; // 0~1

    float2 offsetCoords = float2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;

    float2 ScaleTextureCoords = float2(0.5, 0.5) + (varyTextCoord - float2(0.5, 0.5)) / scale;

    float4 maskR = tex.sample(texSampler, ScaleTextureCoords + offsetCoords);
    float4 maskB = tex.sample(texSampler, ScaleTextureCoords - offsetCoords);
    float4 mask = tex.sample(texSampler, ScaleTextureCoords);

    float4 color = float4(maskR.r, mask.g, maskB.b, mask.a);

    return color;
}

fragment float4
kCGMetalShakeFragmentShader1(
    VertexOut input [[ stage_in ]],
    texture2d<float, access::sample> texture [[ texture(0) ]],
    constant float &currentTime [[ buffer(0) ]]
    ) {
    
    long tick = ((long)(currentTime * smooth)) % smooth;

    float freq = 1.0 / smooth * tick;
        
    float maxScale = 0.01;
    
    float2 textureCoor = input.texCoordinate;
    
    float2 offset = maxScale * max(sin(freq * M_PI_F * 2), 0.0);
    
    constexpr sampler textureSampler;
    
    float maskColorR = texture.sample(textureSampler, textureCoor - offset).r;
    float maskColorG = texture.sample(textureSampler, textureCoor + offset).g;
    float4 originColor = texture.sample(textureSampler, textureCoor);
    
    float4 color = float4(maskColorR, maskColorG, originColor.ba);
    return color;
}
