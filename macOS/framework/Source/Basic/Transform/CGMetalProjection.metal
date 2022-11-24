//
//  CGMetalProjection.metal
//  CGMetal
//
//  Created by Jason on 2022/1/2.
//

#include "../CGMetalHeader.h"

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
