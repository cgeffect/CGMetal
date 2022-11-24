//
//  CGMetalRotate.metal
//  CGMetal
//
//  Created by Jason on 2022/1/1.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#include "../CGMetalHeader.h"

vertex VertexOut kCGMetalRotate (
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
