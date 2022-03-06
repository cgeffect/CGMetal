//
//  CGMetalZoom.metal
//  CGMetalOS
//
//  Created by Jason on 2022/1/1.
//  Copyright © 2022 com.metal.Jason. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../CGMetalHeader.h"

vertex VertexOut zoomVertex(
    uint vid [[ vertex_id ]],
    constant float4 *position [[ buffer(0) ]],
    const device float2 *texCoord [[ buffer(1) ]],
    const device float4x4 *matrix [[ buffer(2) ]]
    ) {
        VertexOut out;

        //why not use matrix1?
        float x = 1;
        float y = 1;
        float z = 1;
        float4x4 matrix1 = {
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        };

        out.position = *matrix * float4(position[vid]);
        out.texCoordinate = texCoord[vid];
        
        return out;
}

/*
 旋转Z
 float radX = 90.0 * PI / 180.0;
 mat4 rotationMatrix = mat4(cos(radX) , sin(radX) , 0.0, 0.0,
                            -sin(radX), cos(radX), 0.0, 0.0,
                            0.0, 0.0, 1.0, 0.0,
                            0.0, 0.0, 0.0, 1.0);
 
 旋转X
 float radX = 150.0 * PI / 180.0;
 mat4 rotationMatrix = mat4(1, 0, 0.0, 0.0,
                            0, cos(radX), sin(radX), 0.0,
                            0.0, -sin(radX), cos(radX), 0.0,
                            0.0, 0.0, 0.0, 1.0);
 
 旋转Y
 float radX = 30.0 * PI / 180.0;
 mat4 rotationMatrix = mat4(cos(radX), 0, -sin(radX), 0,
                            0, 1, 0, 0,
                            sin(radX), 0, cos(radX), 0,
                            0.0, 0.0, 0.0, 1.0);

 
缩放
 mat4 rotationMatrix = mat4(2 , 0 , 0.0, 0.0,
                            0, 2, 0.0, 0.0,
                            0.0, 0.0, 1.0, 0.0,
                            0.0, 0.0, 0.0, 1.0);

 平移
 mat4 rotationMatrix = mat4(1 , 0 , 0, 0,
                            0, 1, 0, 0,
                            0.0, 0.0, 1.0, 0.0,
                            0.2, 0.2, 0.0, 1.0);

 */
