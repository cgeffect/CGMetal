//
//  CGMetalGlitch.metal
//  CGMetal
//
//  Created by Jason on 2022/1/1.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//结构体(用于顶点函数输出/片元函数输入)
typedef struct
{
    float4 position [[position]];
    float2 texCoordinate;

} VertexOut;

//线性插值, 抗锯齿, nearest会出现锯齿
constexpr sampler texSampler(
                             filter::linear,
                             mag_filter::linear,
                             min_filter::linear,
                             coord::normalized,
                             address::clamp_to_edge
//                             address::clamp_to_zero
                             );


constant int smooth = 1000;

float rand(float x) {
    return fract(sin(x) * 43758.5453123);
}

fragment float4 kCGMetalGlitchFragmentShader(
    VertexOut input [[ stage_in ]],
    texture2d<float> texture [[ texture(0) ]],
    constant float &currentTime [[ buffer(0) ]]
    ) {
    long tick = ((long)(currentTime * smooth)) % smooth;
    float freq = 1.0 / smooth * tick;
    float amplitude = max(sin(freq * M_PI_F * 2), 0.0);
    float maxJitter = 0.06;
    float3 rgbOffset = float3(0.01, 0.02, -0.03) * amplitude;
    float2 textureCoor = input.texCoordinate;
    float jitter = rand(textureCoor.y) * 2 - 1.0;
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    float textureX = textureCoor.x + (needOffset ? jitter : jitter * amplitude * 0.006);
    
    float2 maskCoorR = float2(textureX + rgbOffset.r, textureCoor.y);
    float2 maskCoorG = float2(textureX + rgbOffset.g, textureCoor.y);
    float2 maskCoorB = float2(textureX + rgbOffset.b, textureCoor.y);
    
    float maskR = texture.sample(texSampler, maskCoorR).r;
    float maskG = texture.sample(texSampler, maskCoorG).g;
    float maskB = texture.sample(texSampler, maskCoorB).b;
    float4 originColor = texture.sample(texSampler, textureCoor);
    
    return float4(maskR, maskG, maskB, originColor.a);
}
