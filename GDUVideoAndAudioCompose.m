//
//  GDUVideoAndAudioCompose.m
//  GFlight
//
//  Created by qiyun on 16/6/30.
//  Copyright © 2016年 GDU. All rights reserved.
//

#import "GDUVideoAndAudioCompose.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <GPUImageMovie.h>
#import <GPUImageCropFilter.h>
#import <GPUImageContrastFilter.h>
#import <GPUImageBrightnessFilter.h>
#import <GPUImageRGBFilter.h>
#import <GPUImageMovieWriter.h>
#import <GPUImagePolarPixellateFilter.h>
#import <GPUImagePixellateFilter.h>
#import <GPUImageChromaKeyBlendFilter.h>
#import <GPUImageFilterGroup.h>
#import <GPUImageSepiaFilter.h>
#import <GPUImageVignetteFilter.h>
#import <GPUImageSaturationFilter.h>
#import <GPUImageSharpenFilter.h>
#import <GPUImageExposureFilter.h>
#import <GPUImageWhiteBalanceFilter.h>  //色温
#import <GPUImageGammaFilter.h>         //y射线
#import <GPUImageSoftLightBlendFilter.h>
#import <GPUImageAverageLuminanceThresholdFilter.h>
#import <GPUImageLowPassFilter.h>
#import <GPUImageHalftoneFilter.h>
#import <GPUImageGrayscaleFilter.h>
#import <GPUImageMotionDetector.h>
#import <GPUImageSepiaFilter.h>
#import <GPUImageSolidColorGenerator.h>
#import <GPUImageOpacityFilter.h>
#import <GPUImageFilterPipeline.h>
#import <GPUImageBilateralFilter.h>
#import <GPUImageHueFilter.h>
#import <GPUImageColorInvertFilter.h>
#import <GPUImageGaussianBlurPositionFilter.h>
#import <GPUImageMedianFilter.h>
#import <GPUImageKuwaharaRadius3Filter.h>
#import <GPUImagePicture.h>
#import <GPUImageLuminosity.h>
#import <GPUImageLevelsFilter.h>
#import <GPUImageSoftEleganceFilter.h>

#import "UIImage+KSTool.h"

typedef void (^kVideoFilterAdding_progress) (float progress);
typedef void (^kVideoFilterAdding_finished) (NSString *mediaPath);

@implementation GDUVideoAndAudioCompose{
    
@private
    GPUImageMovie                   *movieFile;
    GPUImageMovieWriter             *movieWriter;
    NSTimer                         *timer;
    NSURL                           *sampleURL;
    kVideoFilterAdding_progress     filter_progress;
    kVideoFilterAdding_finished     filter_finished;
    CGSize                          videoSize;
    GDUVideoWithAudioCompose_type   subjectType;
    NSArray                         *audios;
}

#pragma mark    -   life cycle

- (instancetype)initWithMediaSubjectType:(GDUVideoWithAudioCompose_type)type{
    
    if (self == [super init]) {
        
        subjectType = type;
        audios = @[@"Breeze",@"Rimrock",@"Dreamer",@"Geopark",@"Sunshine",@"Ukulele",@"Skyscraper",@"Surfing"];
        videoSize = CGSizeZero;
    }
    return self;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
    [movieWriter cancelRecording];
    if (filter_finished) filter_finished(nil);
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
    // TODO: Stop recording if recording in progress
    [movieWriter cancelRecording];
    
    [timer invalidate];
    [movieFile removeAllTargets];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidEnterBackground:)
                                                name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(applicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIApplicationDidBecomeActiveNotification
                                                 object:nil];
}

#pragma mark    -   get method

- (GDUVideoWithAudioCompose_type)subject{
    
    return subjectType;
}

- (void)setSubject:(GDUVideoWithAudioCompose_type)subject{
    
    subjectType = subject;
}

- (NSString *)destinationPath{
    
    return [sampleURL absoluteString];
}


#pragma mark    -   private method

- (void)composeVidepToFilePath:(NSString *)videoFilePath
                        toPath:(NSString *)outFilePath
                     saveAlbum:(BOOL)saveAlbum{
    
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:audios[MIN(audios.count - 1, subjectType)] ofType:@"mp3"];
    if (!videoFilePath || !audioFilePath) { PDLLog(@"参数不能为空"); return;}

    //创建avmutablecomposition对象，avmutablecompositiontrack或者可以说它将处理我们的视频和音频文件
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //获取视频文件
    //NSString *filePathWithMp4 = [[NSBundle mainBundle] pathForResource:@"video2" ofType:@"mp4"];
    NSURL *video_url = [NSURL fileURLWithPath:videoFilePath];
    AVURLAsset  *videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    
    //使用AVURLAsset读取音频文件，确定当前文件存在及时长.
    //NSURL *audio_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Asteroid_Sound" ofType:@"mp3"]];
    AVURLAsset  *audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:audioFilePath] options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMinimum(audioAsset.duration, videoAsset.duration));
    
    //Now we are creating the first AVMutableCompositionTrack containing our audio and add it to our AVMutableComposition object.
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];

    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,CMTimeMinimum(audioAsset.duration, videoAsset.duration));
    
    //现在我们创建包含我们的视频的avmutablecompositiontrack，添加到的avmutablecomposition对象
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime durationV = videoAsset.duration;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
    NSUInteger dSeconds = floor(dTotalSeconds * 3600 / 60 / 60);
    //NSLog(@"dSeconds = %lu",(unsigned long)dSeconds);
    if (dSeconds <= 0) { PDLLog(@"无效的视频..."); if (filter_finished) filter_finished(outFilePath); return; }
    
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    //保存音视频文件合成后的存放路口，并使之为路径文件重写
    if ([[NSFileManager defaultManager] fileExistsAtPath:outFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outFilePath error:nil];
    
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outFilePath];
    
    //现在创建一个avassetexportsession对象将在指定路径保存你的视频。
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:^(void ) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if (filter_finished) filter_finished(outFilePath);
             
             if (saveAlbum) [self exportDidFinish:_assetExport];
             
//             /* 合成音乐之后自动添加滤镜 */
//             [self currentVideoFilePath:outFilePath outputFilePath:outFilePath progress:^(float progress) {
//                 
//             } completed:^(NSString *mediaPath){
//                 
//             }];
         });
     }
    ];
}

- (void)exportDidFinish:(AVAssetExportSession*)session {
    
    if(session.status == AVAssetExportSessionStatusCompleted) {
        
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error) {
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                    message:@"Video Saving Failed"
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"Ok"
                                                                                          otherButtonTitles: nil, nil];
                                                    [alert show];
                                                } else {
                                                    UIAlertView *alert = [[UIAlertView alloc]
                                                                          initWithTitle:@"Video Saved"
                                                                          message:@"Saved To Photo Album"
                                                                          delegate:self
                                                                          cancelButtonTitle:@"Ok"
                                                                          otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                            });
                                        }];
        }
    }
}


- (void)currentVideoFilePath:(NSString *)currentPath outputFilePath:(NSString *)pathToMovie progress:(void (^) (float progress))progress completed:(void (^) (NSString *mediaPath))completed{
    
    [self addObservers];

#if 1
    sampleURL = [NSURL fileURLWithPath:currentPath];
#else
    sampleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"video_welcome" ofType:@"mp4"]];
#endif
    /* 读取视频格式信息，得到视频的长宽用于视频录制生成新的视频文件 */
    AVAsset *anAsset = [[AVURLAsset alloc] initWithURL:sampleURL options:nil];
    AVAssetTrack *assetTrack = [[anAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    movieFile = [[GPUImageMovie alloc] initWithAsset:anAsset];
    videoSize = assetTrack.naturalSize;
    
    CMTime durationV = anAsset.duration;
    NSUInteger dTotalSeconds = CMTimeGetSeconds(durationV);
    NSUInteger dSeconds = floor(dTotalSeconds * 3600 / 60 / 60);
    PDLLog(@"dSeconds = %lu",(unsigned long)dSeconds);
    
    /* 添加一个滤镜，自定义滤镜的使用并将其添加到新的视频录制对象中 */
    GPUImageFilterGroup *pixellateFilterGroup = [self filterType];
    [pixellateFilterGroup forceProcessingAtSizeRespectingAspectRatio:assetTrack.naturalSize];
    [movieFile addTarget:pixellateFilterGroup];
    
    /* 解除链接绑定 */
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    /* 新的视频生成对象 */
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:videoSize];
    [pixellateFilterGroup addTarget:movieWriter];
    
    /* 根据视频是否含有音频来设置
     if ([[anAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0){
     movieFile.audioEncodingTarget = movieWriter;
     } else {//no audio
     movieFile.audioEncodingTarget = nil;
     }
     */
    movieFile.audioEncodingTarget = nil;        /* 添加主题音乐，过滤掉音频 */
    movieWriter.shouldPassthroughAudio = NO;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    /* 开始录制新的视频 */
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    if (completed) filter_finished = completed;
    if (progress)  filter_progress = progress;
    
    /* 视频生成完成 */
    __weak __typeof(GPUImageMovieWriter) *weakSelf = movieWriter;
    __weak __typeof(NSTimer) *weakTimer = timer;
    __weak __typeof(GPUImageMovie) *weakMovie = movieFile;
    __weak __typeof(GDUVideoAndAudioCompose) *weakCompose = self;
    
    [movieWriter setCompletionBlock:^{
        
        [pixellateFilterGroup removeTarget:weakSelf];
        PDLLog(@"滤镜添加完成...");
        [weakTimer invalidate];
        [weakSelf finishRecording];
        [weakMovie removeAllTargets];
        [weakCompose removeObservers];
        [weakCompose composeVidepToFilePath:pathToMovie toPath:pathToMovie saveAlbum:NO];
    }];
    
    [movieWriter setFailureBlock:^(NSError *error) {
       
        [weakCompose removeObservers];
        PDLLog(@"滤镜错误  %@",[error description]);
    }];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingSampleProgress)
                                           userInfo:nil
                                            repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (movieFile.progress == 0.0) {
            
            PDLLog(@"添加失败");
            [pixellateFilterGroup removeTarget:weakSelf];
            [weakTimer invalidate];
            [weakSelf cancelRecording];
            [weakMovie removeAllTargets];
            [self removeObservers];
            if (filter_finished) filter_finished(nil);
        }
    });
}


- (GPUImageFilterGroup *)filterType{
    
    GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];

    switch (subjectType) {
            
        case GDUVideoWithAudioCompose_type_Breeze:{

            /* 色温 temperature 最大值10000，最小值1000，正常值5000;  tint（最大值1000，最小值-1000，正常值0.0） */
            GPUImageWhiteBalanceFilter *balanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
            balanceFilter.temperature = 10000;
            balanceFilter.tint = 0.0;

            GPUImageOpacityFilter *opacityFilter = [[GPUImageOpacityFilter alloc] init];
            opacityFilter.opacity = 0.8;
            [balanceFilter          addTarget:opacityFilter];
            
            [(GPUImageFilterGroup *) filterGroup setInitialFilters:[NSArray arrayWithObject: balanceFilter]];
            [(GPUImageFilterGroup *) filterGroup setTerminalFilter:opacityFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Rimrock:
        {
            GPUImageBrightnessFilter *halftoneFilter = [[GPUImageBrightnessFilter alloc] init];
            halftoneFilter.brightness = 0.1;
            [(GPUImageFilterGroup *)filterGroup addFilter:halftoneFilter];
            
            [(GPUImageFilterGroup *)filterGroup setInitialFilters:[NSArray arrayWithObject:halftoneFilter]];
            [(GPUImageFilterGroup *)filterGroup setTerminalFilter:halftoneFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Dreamer:
        {
            GPUImageContrastFilter *halftoneFilter = [[GPUImageContrastFilter alloc] init];
            halftoneFilter.contrast = 1.3;
            [(GPUImageFilterGroup *)filterGroup addFilter:halftoneFilter];
            
            [(GPUImageFilterGroup *)filterGroup setInitialFilters:[NSArray arrayWithObject:halftoneFilter]];
            [(GPUImageFilterGroup *)filterGroup setTerminalFilter:halftoneFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Geopark:
        {
            /* 古典 */
            GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
            [(GPUImageFilterGroup *)filterGroup addFilter:sepiaFilter];
            
            GPUImageVignetteFilter *veFilter = [[GPUImageVignetteFilter alloc] init];
            [(GPUImageFilterGroup *)filterGroup addFilter:veFilter];
            [sepiaFilter addTarget:veFilter];
            
            [(GPUImageFilterGroup *)filterGroup setInitialFilters:[NSArray arrayWithObject:sepiaFilter]];
            [(GPUImageFilterGroup *)filterGroup setTerminalFilter:veFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Sunshine:{
            
            /* 饱和度  0 - 1 - 2*/
            GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
            [saturationFilter setSaturation:1.2];
            [(GPUImageFilterGroup *)filterGroup addFilter:saturationFilter];
            
            /* 色温 temperature 最大值10000，最小值1000，正常值5000;  tint（最大值1000，最小值-1000，正常值0.0） */
            GPUImageWhiteBalanceFilter *balanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
            balanceFilter.temperature = 8000;
            balanceFilter.tint = 0.0;

            [saturationFilter          addTarget:balanceFilter];
            
            [(GPUImageFilterGroup *) filterGroup setInitialFilters:[NSArray arrayWithObject: saturationFilter]];
            [(GPUImageFilterGroup *) filterGroup setTerminalFilter:balanceFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Ukulele:
        {
            GPUImageBrightnessFilter *halftoneFilter = [[GPUImageBrightnessFilter alloc] init];
            halftoneFilter.brightness = 0.15;
            [(GPUImageFilterGroup *)filterGroup addFilter:halftoneFilter];
            
            GPUImageRGBFilter *passFilter = [[GPUImageRGBFilter alloc] init];
            [passFilter setRed:1];
            [passFilter setBlue:0.9];
            [passFilter setGreen:0.9];
            [(GPUImageFilterGroup *)filterGroup addFilter:passFilter];
            [halftoneFilter addTarget:passFilter];
            
            [(GPUImageFilterGroup *)filterGroup setInitialFilters:[NSArray arrayWithObject:halftoneFilter]];
            [(GPUImageFilterGroup *)filterGroup setTerminalFilter:passFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Skyscraper:
            
        {
            GPUImageGrayscaleFilter *halftoneFilter = [[GPUImageGrayscaleFilter alloc] init];
            [(GPUImageFilterGroup *)filterGroup addFilter:halftoneFilter];
            
            GPUImageColorInvertFilter *passFilter = [[GPUImageColorInvertFilter alloc] init];
            [(GPUImageFilterGroup *)filterGroup addFilter:passFilter];
            [halftoneFilter addTarget:passFilter];

            [(GPUImageFilterGroup *)filterGroup setInitialFilters:[NSArray arrayWithObject:halftoneFilter]];
            [(GPUImageFilterGroup *)filterGroup setTerminalFilter:passFilter];
        }
            break;
            
        case GDUVideoWithAudioCompose_type_Surfing:
        {
            /* GRB值 1是正常值 ， 最小是0 */
            GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
            [brightnessFilter setBrightness:0.3];
            [(GPUImageFilterGroup *)filterGroup addFilter:brightnessFilter];
            
            /* 色温 temperature 最大值10000，最小值1000，正常值5000;  tint（最大值1000，最小值-1000，正常值0.0） */
            GPUImageWhiteBalanceFilter *balanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
            balanceFilter.temperature = 7000;
            balanceFilter.tint = 0.0;
            
            [brightnessFilter          addTarget:balanceFilter];
            //[saturationFilter   addTarget:balanceFilter];
            
            [(GPUImageFilterGroup *) filterGroup setInitialFilters:[NSArray arrayWithObject: brightnessFilter]];
            [(GPUImageFilterGroup *) filterGroup setTerminalFilter:balanceFilter];
        }

            break;
            
        default:
            break;
    }
    return filterGroup;
}

/* --------------------此方法作废，在滤镜中会添加多个导致时间延时-------------- */

/**
 *  自定义滤镜混合效果
 *
 *  @param filterGroup  滤镜组合
 *  @param contrast     对比度     0 - 4
 *  @param exposure     GRB值     0 - 1
 *  @param saturation   饱和度     0 - 2
 *  @param sharpen      锐化      -4 - 4
 *  @param brightness   亮度      -1 - 1
 *  @param exposure     曝光度    -10 - 10
 *  @param temperature  色温      1000 - 10000
 *  @param gamma        伽马射线   0 - 3
 */
- (void)filterGroup:(GPUImageFilterGroup *)filterGroup
        setContrast:(CGFloat)contrast
      setSaturation:(CGFloat)saturation
         setSharpen:(CGFloat)sharpen
      setBrightness:(CGFloat)brightness
        setExposure:(CGFloat)exposure
     setTemperature:(CGFloat)temperature
           setGamma:(CGFloat)gamma
        setRgbValue:(GDURGBColor)rgb
             isGray:(BOOL)gray{
    
    /* 对比度  0 - 1 - 4*/
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    [contrastFilter setContrast:contrast];
    [(GPUImageFilterGroup *)filterGroup addFilter:contrastFilter];
    
    //GPUImageVignetteFilter 模糊
    
    /* 灰色 */
    GPUImageGrayscaleFilter *grayFilter = [[GPUImageGrayscaleFilter alloc] init];
    if (gray) [(GPUImageFilterGroup *)filterGroup addFilter:grayFilter];
    
    /* GRB值 1是正常值 ， 最小是0 */
    GPUImageRGBFilter *rgbFilter = [[GPUImageRGBFilter alloc] init];
    [rgbFilter setRed:rgb.red];
    [rgbFilter setGreen:rgb.green];
    [rgbFilter setBlue:rgb.blue];
    [(GPUImageFilterGroup *)filterGroup addFilter:rgbFilter];

    /* 饱和度  0 - 1 - 2*/
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    [saturationFilter setSaturation:saturation];
    [(GPUImageFilterGroup *)filterGroup addFilter:saturationFilter];
    
    /* 锐化   -4 - 0 - 4*/
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [sharpenFilter setSharpness:sharpen];
    [(GPUImageFilterGroup *)filterGroup addFilter:sharpenFilter];
    
    /* 亮度   -1 - 0 - 1*/
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
    [brightnessFilter setBrightness:brightness];
    [(GPUImageFilterGroup *)filterGroup addFilter:brightnessFilter];
    
    /* 曝光度  -10  - 0 - 10*/
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc]init];
    [exposureFilter setExposure:exposure];
    [(GPUImageFilterGroup *)filterGroup addFilter:exposureFilter];
    
    /* 色温 temperature 最大值10000，最小值1000，正常值5000;  tint（最大值1000，最小值-1000，正常值0.0） */
    GPUImageWhiteBalanceFilter *balanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    balanceFilter.temperature = temperature;
    balanceFilter.tint = 0.0;

    /*  伽马射线,γ射线 Gamma ranges from 0.0 to 3.0, with 1.0 as the normal level. */
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    [gammaFilter setGamma:gamma];
    [(GPUImageFilterGroup *)filterGroup addFilter:gammaFilter];
    
    if (gray){
        [contrastFilter addTarget:grayFilter];
        [grayFilter addTarget:rgbFilter];
    }else [contrastFilter     addTarget:rgbFilter];
    
    [rgbFilter          addTarget:saturationFilter];
    [saturationFilter   addTarget:sharpenFilter];
    [sharpenFilter      addTarget:brightnessFilter];
    [brightnessFilter   addTarget:balanceFilter];
    [balanceFilter      addTarget:exposureFilter];
    [exposureFilter     addTarget:gammaFilter];
    
    
    [(GPUImageFilterGroup *) filterGroup setInitialFilters:[NSArray arrayWithObject: contrastFilter]];
    [(GPUImageFilterGroup *) filterGroup setTerminalFilter:gammaFilter];
}

- (void)retrievingSampleProgress{
    
    PDLLog(@"添加滤镜进度   %.1f",movieFile.progress);
    if (movieFile.progress >= 1.0){
        
        [timer invalidate];
        [self removeObservers];
    }
    filter_progress(movieFile.progress);
}


- (void)exchangedFormatWithVideoAtFilePath:(NSString *)currentPath complete:(void (^) (BOOL complete, NSString *filePath))complete{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:currentPath] options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
        
        NSString *exportPath = [NSString stringWithFormat:@"%@/%@",
                                [NSHomeDirectory() stringByAppendingString:@"/tmp"],
                                [currentPath lastPathComponent]];
        exportSession.outputURL = [NSURL fileURLWithPath:exportPath];
        PDLLog(@"~~~~~~~~~~~~ %@", exportPath);
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    PDLLog(@"~~~~~~~~~~~~ Export failed: %@", [[exportSession error] localizedDescription]);
                    if (complete) complete(NO,nil);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    PDLLog(@"~~~~~~~~~~~~ Export canceled");
                    if (complete) complete(NO,nil);
                    break;
                case AVAssetExportSessionStatusCompleted:
                    PDLLog(@"~~~~~~~~~~~~ 转换成功");
                    if (complete) complete(YES,exportPath);
                    break;
                default:
                    break;
            }
        }];
    }
}

+ (void)videoFilterSampleBufferRefWithUrl:(NSString *)videoUrl completed:(void (^) (void))completed{
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoUrl] options:optDict];
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC), CMTimeMakeWithSeconds(asset.duration.value / asset.duration.timescale - 1.2, NSEC_PER_SEC));
    
    [compositionTrack insertTimeRange:timeRange ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    //输出类型
    exportSession.outputFileType = @"com.apple.quicktime-movie";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoUrl])
        [[NSFileManager defaultManager] removeItemAtPath:videoUrl error:nil];
    
    exportSession.outputURL = [NSURL fileURLWithPath:videoUrl];
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch (exportSession.status) {
                
            case AVAssetExportSessionStatusExporting:
                PDLLog(@"exporter Exporting");
                PDLLog(@"%f",exportSession.progress);
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                PDLLog(@"exporter Completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) completed();
                });
            }
                break;
                
            default:
                break;
        }
    }];
}

+ (void)videoFilterSampleBufferRefWithUrl:(NSString *)videoUrl toVideoPath:(NSString *)toPath completed:(void (^) (void))completed{
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoUrl] options:optDict];
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(0, NSEC_PER_SEC), CMTimeMakeWithSeconds(asset.duration.value / asset.duration.timescale - 0, NSEC_PER_SEC));
    
    [compositionTrack insertTimeRange:timeRange ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:kCMTimeZero error:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    //输出类型
    exportSession.outputFileType = @"com.apple.quicktime-movie";
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:toPath])
        [[NSFileManager defaultManager] removeItemAtPath:toPath error:nil];
    
    exportSession.outputURL = [NSURL fileURLWithPath:toPath];
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        switch (exportSession.status) {
                
            case AVAssetExportSessionStatusExporting:
                PDLLog(@"exporter Exporting");
                PDLLog(@"%f",exportSession.progress);
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                PDLLog(@"exporter Completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completed) completed();
                });
            }
                break;
                
            default:
                break;
        }
    }];
}

+ (NSArray *)thumbnailsFromImage:(UIImage *)image{
    
    NSMutableArray  *images = [NSMutableArray arrayWithCapacity:9];
    int value = 0;
    
    @synchronized (self) {
        
        while (value < 8) {
            
            GDUVideoAndAudioCompose *compose = [[GDUVideoAndAudioCompose alloc] initWithMediaSubjectType:value];
            UIImage *newImage = [GDUVideoAndAudioCompose imageFilterWithType:value sourceImage:image filterGroup:[compose filterType]];
            
            if (newImage) [images addObject:newImage];
            else [images addObject:image];
            
            value ++;
        }
    }
    return [images copy];
}

+ (NSArray *)thumbnailsFromVideoUrlString:(NSString *)videoUrl{
    
    NSMutableArray  *images = [NSMutableArray arrayWithCapacity:9];
    
    UIImage *image = [UIImage imageWithVideo:[NSURL fileURLWithPath:videoUrl]];
    int value = 0;
    
    @synchronized (self) {
        
        while (value < 8) {
            
            GDUVideoAndAudioCompose *compose = [[GDUVideoAndAudioCompose alloc] initWithMediaSubjectType:value];
            UIImage *newImage = [GDUVideoAndAudioCompose imageFilterWithType:value sourceImage:image filterGroup:[compose filterType]];
            
            if (newImage) [images addObject:newImage];
            else [images addObject:image];
            
            value ++;
        }
    }
    return [images copy];
}


+ (UIImage *)imageFilterWithType:(NSInteger)index sourceImage:(UIImage *)image filterGroup:(GPUImageFilterGroup *)filterGroup{
    
    // pass the image through a brightness filter to darken a bit and a gaussianBlur filter to blur
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    
    [filterGroup forceProcessingAtSize:image.size];
    [stillImageSource addTarget:filterGroup];
    [filterGroup useNextFrameForImageCapture];
    [stillImageSource processImage];

    GPUImageFilterPipeline *pipeline = [[GPUImageFilterPipeline alloc]initWithOrderedFilters:@[filterGroup] input:stillImageSource output:nil];

    return [pipeline currentFilteredFrame];
}

- (void)dealloc{
    
    [self removeObservers];
}

@end
