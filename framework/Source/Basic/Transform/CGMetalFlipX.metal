//
//  CGMetalFlipX.metal
//  CGMetal
//
//  Created by Jason on 2021/6/17.
//

#include "../CGMetalHeader.h"

vertex VertexOut kCGMetalFlipXVertexShader(
                      uint vertexID [[ vertex_id ]],
                      constant float4 *position [[ buffer(0) ]],
                      constant float2 *texCoord [[ buffer(1) ]]
                      ) {
    VertexOut out;
    out.position = position[vertexID];
    out.texCoordinate = float2(texCoord[vertexID].x, 1.0 - texCoord[vertexID].y) ;
    return out;
}
