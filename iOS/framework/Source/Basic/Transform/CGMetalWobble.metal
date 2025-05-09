//
//  CGMetalWobble.metal
//  CGMetal
//
//  Created by Jason on 2022/1/2.
//

//#include "../CGMetalHeader.h"
#include <metal_stdlib>
using namespace metal;
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

vertex VertexOut
WobbleVertex(const device float4 *position [[ buffer(0) ]],
             const device float &currentTime [[ buffer(2) ]],
             const device float2 *textureCoord [[ buffer(1) ]],
             uint vid [[ vertex_id ]]) {
    VertexOut out;
    
    float speed = 0.5;
    
    long tick = ((long)((currentTime * speed) * smooth)) % smooth;
    
    float freq = 1.0 / smooth * tick;
    
    float maxAmplitude = 0.1;
    float amplitudeX = maxAmplitude * sin(freq * M_PI_F * 2);
    float amplitudeY = maxAmplitude * cos(freq * M_PI_F * 2);

    float2 currentPos = position[vid].xy + float2(amplitudeX, amplitudeY);
    
    out.position = float4(currentPos.xy, 0, 1);
    out.texCoordinate = textureCoord[vid];
    
    return out;
}


