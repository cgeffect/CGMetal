//
//  CGMetalProjection.metal
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
vertex VertexOut kCGMetalProjection (
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
