//
//  CGMetalPixelBufferSurfaceOutput.metal
//  CGMetal
//
//  Created by Jason on 2021/12/1.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoor;

} VertexOut;

vertex VertexOut
CGMetalPixelBufferSurfaceOutputVertexShader(
                      uint vertexID [[ vertex_id ]],
                      constant float4 *position [[ buffer(0) ]],
                      constant float2 *texCoor [[ buffer(1) ]]
                      ) {
    VertexOut out;
    
    out.position = position[vertexID];
    out.texCoor = texCoor[vertexID];
    
    return out;
}

fragment float4
CGMetalPixelBufferSurfaceOutputFragmentShader(
                        VertexOut in [[ stage_in ]],
                        texture2d<float, access::sample> tex [[ texture(0) ]]
                        ) {
    constexpr sampler texSampler;
    float4 color = tex.sample(texSampler, in.texCoor);
    return color;
}

