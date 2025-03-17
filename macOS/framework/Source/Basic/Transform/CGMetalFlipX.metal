//
//  CGMetalFlipX.metal
//  CGMetal
//
//  Created by Jason on 2021/6/17.
//

#include <metal_stdlib>
using namespace metal;

//结构体(用于顶点函数输出/片元函数输入)
typedef struct
{
    float4 position [[position]];
    float2 texCoordinate;

} VertexOut;

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
