#include "CGMetalHeader.h"
#include <simd/simd.h>
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
CGMetalFragmentShader(
                        VertexOut in [[ stage_in ]],
                        texture2d<float, access::sample> tex [[ texture(0) ]]
                        ) {
    float4 color = tex.sample(texSampler, in.texCoordinate);
    return color;
}

//外界设置采样器
fragment float4
CGMetalFragmentShader1(VertexOut in [[ stage_in ]],
                       texture2d<float, access::sample> tex [[ texture(0) ]],
                       sampler sampler2D [[ sampler(0) ]]) {
    float4 color = tex.sample(sampler2D, in.texCoordinate);
    return color;
}


