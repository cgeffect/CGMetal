//
//  CGMetalColour.metal
//  CGMetal
//
//  Created by Jason on 2021/6/20.
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


fragment float4
kCGMetalColourFragmentShader(VertexOut in [[ stage_in ]],
                           texture2d<float, access::sample> tex [[ texture(0) ]],
                           constant float *value [[ buffer(0) ]] ) {

    
    if (in.texCoordinate.x > value[0]) {
        float4 color = tex.sample(texSampler, in.texCoordinate);
        float v = (color.r + color.g + color.b) / 3.0;
        return float4(float3(v), color.a);
    } else {
        return tex.sample(texSampler, in.texCoordinate);
    }
    
}

