//
//  GDUVideoAndAudioCompose.h
//  GFlight
//
//  Created by qiyun on 16/6/30.
//  Copyright © 2016年 GDU. All rights reserved.
//

#import <Foundation/Foundation.h>


struct GDUColorWithRGB{
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
};

typedef struct GDUColorWithRGB GDURGBColor;

CG_INLINE GDURGBColor
GDURGBColorMake(CGFloat red, CGFloat green, CGFloat blue)
{
    GDURGBColor RGBColor;
    RGBColor.red = red; RGBColor.green = green; RGBColor.blue = blue;
    return RGBColor;
}


typedef NS_ENUM(NSInteger, GDUVideoWithAudioCompose_type) {
    
    GDUVideoWithAudioCompose_type_unknow        =   NSNotFound,
    GDUVideoWithAudioCompose_type_Breeze        =   0,  /* 唯美 */
    GDUVideoWithAudioCompose_type_Rimrock       =   1,  /* 自然 */
    GDUVideoWithAudioCompose_type_Dreamer       =   2,  /* lomo */
    GDUVideoWithAudioCompose_type_Geopark       =   3,  /* 复古 */
    GDUVideoWithAudioCompose_type_Sunshine      =   4,  /* 阳光 */
    GDUVideoWithAudioCompose_type_Ukulele       =   5,  /* 甜美 */
    GDUVideoWithAudioCompose_type_Skyscraper    =   6,  /* 胶片 */
    GDUVideoWithAudioCompose_type_Surfing       =   7   /* 明亮 */
};


@interface GDUVideoAndAudioCompose : NSObject


- (instancetype)initWithMediaSubjectType:(GDUVideoWithAudioCompose_type)type;


@property (nonatomic) GDUVideoWithAudioCompose_type subject;
@property (nonatomic, readonly, copy) NSString  *destinationPath;


/**
 *  合成一段视频和音频
 *
 *  @param videoFilePath 视频文件的路径
 *  @param audioFilePath 音频文件的路径
 *  @param outFilePath   合成后的视频文件的保存路径
 *  @param confrim       是否确定保存到相册库，默认是NO
 */
- (void)composeVidepToFilePath:(NSString *)videoFilePath
                        toPath:(NSString *)outFilePath
                     saveAlbum:(BOOL)saveAlbum;

/**
 *  视频添加滤镜
 *
 *  @param currentPath 当前视频的路径
 *  @param pathToMovie 合成之后存放视频的路径
 *  @param progress    滤镜添加进度
 *  @param completed   执行完成
 */
- (void)currentVideoFilePath:(NSString *)currentPath
              outputFilePath:(NSString *)pathToMovie
                    progress:(void (^) (float progress))progress
                   completed:(void (^) (NSString *mediaPath))completed;



/**
 *  视频转换格式为mp4
 *
 *  @param currentPath 视频的路径地址
 *  @param complete    完成
 */
- (void)exchangedFormatWithVideoAtFilePath:(NSString *)currentPath
                                  complete:(void (^) (BOOL complete, NSString *filePath))complete;

/**
 *  过滤视频的第一帧，从飞机录制过来的视频第一帧保存的时候是空的，为了避免循环读取帧数据造成退出的问题
 *
 *  @param videoUrl  视频的存储路径
 *  @param completed 完成后的hanlder
 */
+ (void)videoFilterSampleBufferRefWithUrl:(NSString *)videoUrl completed:(void (^) (void))completed;
+ (void)videoFilterSampleBufferRefWithUrl:(NSString *)videoUrl toVideoPath:(NSString *)toPath completed:(void (^) (void))completed;

/**
 *  获取视频缩略图
 *
 *  @param videoUrl 视频的存储路径
 *
 *  @return 几种滤镜组合生成的多张缩略图
 */
+ (NSArray *)thumbnailsFromVideoUrlString:(NSString *)videoUrl;
+ (NSArray *)thumbnailsFromImage:(UIImage *)image;

@end
