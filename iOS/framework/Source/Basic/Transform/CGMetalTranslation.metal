//
//  CGMetalTranslation.metal
//  CGMetal
//
//  Created by Jason on 2022/1/2.
//

#include "../CGMetalHeader.h"
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

vertex VertexOut kCGMetalTranslation(
    uint vid [[ vertex_id ]],
    constant float4 *position [[ buffer(0) ]],
    const device float2 *texCoord [[ buffer(1) ]],
    const device float4x4 *matrix [[ buffer(2) ]]
    ) {
        VertexOut out;
        out.position = *matrix * float4(position[vid]);
        out.texCoordinate = texCoord[vid];
        return out;
}
