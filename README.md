# CGMetal
<img width="500" alt="截屏2021-11-27 上午12 10 19" src="https://user-images.githubusercontent.com/15692322/143607725-a52eaeb1-4eb0-41ba-bad7-7682b88df4b4.png">

CGMetal 是一个适用于 iOS 的GPU加速Metal处理库<br>

SDK 的 Github 地址：https://github.com/cgeffect/CGMetal

![image](https://user-images.githubusercontent.com/15692322/124692294-eb4b0d80-df0f-11eb-9f2a-41e5641af4a4.png)

![image](https://user-images.githubusercontent.com/15692322/139858060-c016cecb-4cf7-43bd-ad32-b802910fbd45.gif)

### 工程结构

CGMetal: iOS动态framework<br/>
CGMetalMac: Mac动态framework<br/>
MetaliOS: 集成CGMetal动态framework的iOS工程<br/>
MetalMac: 集成CGMetalMac动态framework的Mac工程<br/>

### 输入源
1. CGMetalImageInput(图片)
2. CGMetalPixelBufferInput(CVPixelBufferRef)<br/>
    support: NV12/32BGRA
3. CGMetalRawDataInput(二进制数据)<br/>
    support: NV12/NV12/BGRA/RGBA/I420
4. CGMetalTextureInput(纹理输入, Metal纹理)
5. CGMetalVideoInput(本地视频输入, 重编码)
6. CGMetalCameraInput(相机输入)
7. CGMetalPlayerInput(视频输入, 播放)

### 输出源
1. CGMetalImageOutput(图片)
2. CGMetalPixelBufferOutput(CVPxielBufferRef)
3. CGMetalRawDataOutput(二进制数据)
4. CGMetalTextureOutput(纹理输入, Metal纹理)
5. CGMetalVideoOutput(视频)
6. CGMetalNSViewOutput(Mac渲染)
7. CGMetalUIViewOutput(iOS渲染)
8. CGMetalCALayerOutput(iOS/Mac渲染)
9. CGMetalPixelBufferSurfaceOutput(CVPxielBufferRef)

### 代码示例
``` 
UIImage *sourceImage = [UIImage imageNamed:@"rgba"];
CGMetalImageInput *inputSource = [[CGMetalImageInput alloc] initWithImage:sourceImage];
CGMetalBasic *basic = [[CGMetalBasic alloc] init];
CGMetalViewOutput * metalView = [[CGMetalViewOutput alloc] initWithFrame:frame];

[inputSource addTarget:basic];
[basic addTarget:metalView];
[inputSource requestRender];
```

### Effect效果
CGMetalGlitch 毛刺<br/>
CGMetalColour 着色<br/>
CGMetalGray 灰度<br/>
CGMetalShake 色彩偏移<br/>
CGMetalSoul 灵魂出窍<br/>

### Transform效果
CGMetalCrop 裁剪<br/>
CGMetalFlipX X轴反转<br/>
CGMetalFlipY Y轴反转<br/>
CGMetalProjection 透视<br/>
CGMetalRotate Z轴旋转<br/>
CGMetalTranslation XY平移<br/>
CGMetalZoom 缩放<br/>
CGMetalWobble 晃动<br/>
continue...

### 注意
模拟器不支持fast texture upload, 使用真机运行
iOS10以上, Xcode 13及其以上

### 官方文档
[Metal](https://developer.apple.com/documentation/metal)
[Using Metal to Draw a View’s Contents](https://developer.apple.com/documentation/metal/using_metal_to_draw_a_view_s_contents)<br/>
[Processing a Texture in a Compute Function](https://developer.apple.com/documentation/metal/compute_passes/processing_a_texture_in_a_compute_function)<br/>
[Synchronizing CPU and GPU Work](https://developer.apple.com/documentation/metal/resource_synchronization/synchronizing_cpu_and_gpu_work)<br/>
[Performing Calculations on a GPU](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu)
