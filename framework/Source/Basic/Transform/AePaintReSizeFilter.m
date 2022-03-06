////
////  AePaintReSizeFilter.m
////  AeRenderEngine
////
////  Created by Jason on 2021/8/22.
////
//
//#import "AePaintReSizeFilter.h"
//
//@interface AePaintReSizeFilter ()<AePaintDataSource>
//{
//    CGSize _outputSize;
//    CGSize _sourceSize;
//    CGRect _cropRegion;
//}
//@end
//
//@implementation AePaintReSizeFilter
//{
//    GLfloat cropTextureCoordinates[8];
//}
//
//- (instancetype)init {
//    self = [super init];
//    if (self) {
//        self.cropRegion = CGRectMake(0.0, 0.0, 1.0, 1.0);
//        _filterDataSource = self;
//    }
//    return self;
//}
//
//- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
//
//    [self glPrepareRender];
//
//    //1.处理自己的滤镜
//    [self renderToTextureWithVertices:cropTextureCoordinates ae_textureCoordinates:ae_textureCoordinates];
//    
//    [self glRenderFinished];
//
//    //2.通知自己的下一个节点处理滤镜
//    [self notifyNextTargetsAboutNewFrameAtTime:frameTime];
//    
//}
//
//#pragma mark -
//#pragma mark Accessors
//
//- (void)setOutputFBOSize:(CGSize)outputSize sourceSize:(CGSize)sourceSize {
//    _outputSize = outputSize;
//    _sourceSize = sourceSize;
//    
//    //宽度等比缩放
//    float aspect = _sourceSize.width / _sourceSize.height;
//    CGSize renderSize = CGSizeMake(_outputSize.width, _outputSize.width / aspect);
//    float x = (_outputSize.width - renderSize.width) / 2;
//    float y = (_outputSize.height - renderSize.height) / 2;
//    float width = renderSize.width;
//    float height = renderSize.height;
//
//    CGPoint point1 = CGPointMake(x, y); //左上
//    CGPoint point2 = CGPointMake(x + width, y); //右上
//    CGPoint point3 = CGPointMake(x, y + height); //左下
//    CGPoint point4 = CGPointMake(x + width, y + height); //右下
//    
//    float normalX = point1.x / _outputSize.width;
//    float normalY = point1.y / _outputSize.height;
//    float normalW = (point2.x - point1.x) / _outputSize.width;
//    float normalH = (point3.y - point1.y) / _outputSize.height;
//
//    [self setCropRegion:CGRectMake(normalX, normalY, normalW, normalH)];
//    
//}
//- (void)setCropRegion:(CGRect)newValue {
////    NSLog(@"newValue: %@", NSStringFromCGRect(newValue));
////    NSParameterAssert(newValue.origin.x >= 0 && newValue.origin.x <= 1 &&
////                      newValue.origin.y >= 0 && newValue.origin.y <= 1 &&
////                      newValue.size.width >= 0 && newValue.size.width <= 1 &&
////                      newValue.size.height >= 0 && newValue.size.height <= 1);
//
//    _cropRegion = newValue;
//    [self calculateCropTextureCoordinates];
//}
//
//- (void)calculateCropTextureCoordinates {
//    CGFloat minX = _cropRegion.origin.x;
//    CGFloat minY = _cropRegion.origin.y;
//    CGFloat maxX = CGRectGetMaxX(_cropRegion);
//    CGFloat maxY = CGRectGetMaxY(_cropRegion);
//    
//    CGPoint point1 = CGPointMake(minX, minY); //左上
//    CGPoint point2 = CGPointMake(maxX, minY); //右上
//    CGPoint point3 = CGPointMake(minX, maxY); //左下
//    CGPoint point4 = CGPointMake(maxX, maxY); //右下
//    
//    float normal1X = point1.x;
//    float normal1Y = point1.y;
//    float normal2X = point2.x;
//    float normal2Y = point2.y;
//    float normal3X = point3.x;
//    float normal3Y = point3.y;
//    float normal4X = point4.x;
//    float normal4Y = point4.y;
//
//    normal1X = (normal1X - 0.5) * 2;
//    normal1Y = (0.5 - normal1Y) * 2;
//    normal2X = (normal2X - 0.5) * 2;
//    normal2Y = (0.5 - normal2Y) * 2;
//    normal3X = (normal3X - 0.5) * 2;
//    normal3Y = (0.5 - normal3Y) * 2;
//    normal4X = (normal4X - 0.5) * 2;
//    normal4Y = (0.5 - normal4Y) * 2;
//
//    CGPoint leftTopCorner = CGPointMake(normal1X, normal1Y);
//    CGPoint rightTopCorner = CGPointMake(normal2X, normal2Y);
//    CGPoint leftBottomCorner = CGPointMake(normal3X, normal3Y);
//    CGPoint rightBottomCorner = CGPointMake(normal4X, normal4Y);
//
//    cropTextureCoordinates[0] = leftBottomCorner.x; // -1,-1
//    cropTextureCoordinates[1] = leftBottomCorner.y;
//    
//    cropTextureCoordinates[2] = rightBottomCorner.x; // 1,-1
//    cropTextureCoordinates[3] = rightBottomCorner.y;
//
//    cropTextureCoordinates[4] = leftTopCorner.x; // -1,1
//    cropTextureCoordinates[5] = leftTopCorner.y;
//
//    cropTextureCoordinates[6] = rightTopCorner.x; // 1,1
//    cropTextureCoordinates[7] = rightTopCorner.y;
//
//}
//
//#pragma mark - AePaintDataSource
//- (CGSize)outputSize:(AePaintFilter *)filter {
//    return _outputSize;
//}
//
//@end
