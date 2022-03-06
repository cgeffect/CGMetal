//
//  CGMetalNV12.metal
//  CGMetal
//
//  Created by Jason on 2021/6/1.
//

#include <metal_stdlib>
using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoor;

} VertexOut;

constexpr sampler texSampler(
                             coord::normalized,
                             address::clamp_to_edge,
                             filter::linear
                             );

vertex VertexOut
kCGMetalPixNV12VertexShader(
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
kCGMetalPixNV12FragmentShader(
                        VertexOut in [[ stage_in ]],
                        texture2d<float, access::sample> yTex [[ texture(0) ]],
                        texture2d<float, access::sample> uvTex [[ texture(1) ]]
                        ) {
    float3 yuv;
    yuv.x = yTex.sample(texSampler, in.texCoor).r;
    yuv.yz = uvTex.sample(texSampler, in.texCoor).rg;
    float y = yuv.x;
    float u = yuv.y - 0.5;
    float v = yuv.z - 0.5;
      
    float r = y + 1.402 * v;
    float g = y - 0.344 * u - 0.714 * v;
    float b = y + 1.772 * u;
    float4 color = float4(r, g, b, 1.0);
    return color;
}
