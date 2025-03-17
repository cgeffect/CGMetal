#include "CGMetalHeader.h"
#include <simd/simd.h>

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

//VertexOut 返回数据类型->片元函数
// vertex_id是顶点shader每次处理的index，用于定位当前的顶点
// buffer表明是缓存数据，0是索引
vertex VertexOut
CGMetalVertexShader(
                      uint vertexID [[ vertex_id ]],
                      constant float4 *position [[ buffer(0) ]],
                      constant float2 *texCoord [[ buffer(1) ]]
                      ) {
    VertexOut out;
    out.position = position[vertexID];
    out.texCoordinate = float2(texCoord[vertexID].x, texCoord[vertexID].y) ;
    return out;
}
// stage_in表示这个数据来自光栅化。（光栅化是顶点处理之后的步骤，业务层无法修改）
// tex表明是纹理数据，0是索引
// buffer表明是缓存数据, 0/1是索引
fragment float4
CGMetalFragmentShader(VertexOut in [[ stage_in ]],
                      texture2d<float, access::sample> tex [[ texture(0) ]])
{
    float4 color = tex.sample(texSampler, in.texCoordinate);
    return color;
}

//外界设置采样器
fragment float4
CGMetalFragmentShader1(VertexOut in [[ stage_in ]],
                       texture2d<float, access::sample> tex [[ texture(0) ]],
                       sampler sampler2D [[ sampler(0) ]])
{
    float4 color = tex.sample(sampler2D, in.texCoordinate);
    return color;
}

fragment float4
CGMetalFragmentTwoShader(VertexOut in [[ stage_in ]],
                        texture2d<float, access::sample> tex [[ texture(0) ]],
                        texture2d<float, access::sample> tex1 [[ texture(1) ]])
{
    if (in.texCoordinate.x < 0.5) {
        float4 color = tex.sample(texSampler, in.texCoordinate);
        return color;
    } else {
        float4 color = tex1.sample(texSampler, in.texCoordinate);
        return color;
    }
}

/*
 NSString *const ae_gl_WipeHorizontalFS = AE_SHADER_STRING (
    precision highp float;

    varying vec2 varyTextCoord;
    uniform sampler2D uTexture;
    uniform sampler2D uTexture1;
    uniform float progress;

    void main()
    {
         highp vec2 p = varyTextCoord;
         vec2 uv = p.xy/vec2(1.0).xy;
         vec2 prox = vec2(progress,0);
         vec2 prox2 = vec2(progress-1.0,0);
         vec4 fromColor = texture2D(uTexture,(uv+prox));
         vec4 toColor = texture2D(uTexture1,uv+prox2);
         gl_FragColor = mix(fromColor, toColor, step(1.0 - uv.x,progress));

    }
 );
 */

