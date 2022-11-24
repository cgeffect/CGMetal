//
//  CGMetalHeader.h
//  CGMetal
//
//  Created by Jason on 2021/6/17.
//

#ifndef CGMetalHeader_h
#define CGMetalHeader_h

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

#endif /* CGMetalHeader_h */
