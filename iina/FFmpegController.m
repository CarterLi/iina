//
//  FFmpegController.m
//  iina
//
//  Created by lhc on 9/6/2017.
//  Copyright © 2017 lhc. All rights reserved.
//

#import "FFmpegController.h"
#import <Cocoa/Cocoa.h>

#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <libavutil/imgutils.h>
#import <libavutil/mastering_display_metadata.h>

#define THUMB_COUNT_DEFAULT 100

#define CHECK_NOTNULL(ptr,msg) if (ptr == NULL) {\
NSLog(@"Error when getting thumbnails: %@", msg);\
return -1;\
}

#define CHECK_SUCCESS(ret,msg) if (ret < 0) {\
NSLog(@"Error when getting thumbnails: %@ (%d)", msg, ret);\
return -1;\
}

#define CHECK(ret,msg) if (!(ret)) {\
NSLog(@"Error when getting thumbnails: %@", msg);\
return -1;\
}

@implementation FFThumbnail

@end


@interface FFmpegController () {
  NSMutableArray<FFThumbnail *> *_thumbnails;
  NSMutableArray<FFThumbnail *> *_thumbnailPartialResult;
  NSMutableSet *_addedTimestamps;
  NSOperationQueue *_queue;
  double _timestamp;
}

- (int)getPeeksForFile:(NSString *)file thumbnailsWidth:(int)thumbnailsWidth;
- (void)saveThumbnail:(AVFrame *)pFrame width:(int)width height:(int)height index:(int)index realTime:(int)second forFile:(NSString *)file;

@end


@implementation FFmpegController

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.thumbnailCount = THUMB_COUNT_DEFAULT;
    _thumbnails = [[NSMutableArray alloc] init];
    _thumbnailPartialResult = [[NSMutableArray alloc] init];
    _addedTimestamps = [[NSMutableSet alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _queue.maxConcurrentOperationCount = 1;
  }
  return self;
}


- (void)generateThumbnailForFile:(NSString *)file
                      thumbWidth:(int)thumbWidth
{
  [_queue cancelAllOperations];
  NSBlockOperation *op = [[NSBlockOperation alloc] init];
  __weak NSBlockOperation *weakOp = op;
  [op addExecutionBlock:^(){
    if ([weakOp isCancelled]) {
      return;
    }
    self->_timestamp = CACurrentMediaTime();
    int success = [self getPeeksForFile:file thumbnailsWidth:thumbWidth];
    if (self.delegate) {
      [self.delegate didGenerateThumbnails:[NSArray arrayWithArray:self->_thumbnails]
                                   forFile: file
                                 succeeded:(success < 0 ? NO : YES)];
    }
  }];
  [_queue addOperation:op];
}

- (int)getPeeksForFile:(NSString *)file
       thumbnailsWidth:(int)thumbnailsWidth
{
  int i, ret;

  char *cFilename = strdup(file.fileSystemRepresentation);
  [_thumbnails removeAllObjects];
  [_thumbnailPartialResult removeAllObjects];
  [_addedTimestamps removeAllObjects];

  // Register all formats and codecs. mpv should have already called it.
  // av_register_all();

  // Open video file
  AVFormatContext *pFormatCtx = NULL;
  ret = avformat_open_input(&pFormatCtx, cFilename, NULL, NULL);
  free(cFilename);
  CHECK_SUCCESS(ret, @"Cannot open video")

  // Find stream information
  ret = avformat_find_stream_info(pFormatCtx, NULL);
  CHECK_SUCCESS(ret, @"Cannot get stream info")

  // Find the first video stream
  int videoStream = -1;
  for (i = 0; i < pFormatCtx->nb_streams; i++)
    if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
      videoStream = i;
      break;
    }
  CHECK_SUCCESS(videoStream, @"No video stream")

  // Get the codec context for the video stream
  AVStream *pVideoStream = pFormatCtx->streams[videoStream];

  AVRational videoAvgFrameRate = pVideoStream->avg_frame_rate;

  // Check whether the denominator (AVRational.den) is zero to prevent division-by-zero
  if (videoAvgFrameRate.den == 0 || av_q2d(videoAvgFrameRate) == 0) {
    NSLog(@"Avg frame rate = 0, ignore");
    return -1;
  }

  // Find the decoder for the video stream
  const AVCodec *pCodec = avcodec_find_decoder(pVideoStream->codecpar->codec_id);
  CHECK_NOTNULL(pCodec, @"Unsupported codec")

  // Open codec
  AVCodecContext *pCodecCtx = avcodec_alloc_context3(pCodec);
  AVDictionary *optionsDict = NULL;

  avcodec_parameters_to_context(pCodecCtx, pVideoStream->codecpar);
  pCodecCtx->time_base = pVideoStream->time_base;

  if (pCodecCtx->pix_fmt < 0 || pCodecCtx->pix_fmt >= AV_PIX_FMT_NB) {
    avcodec_free_context(&pCodecCtx);
    avformat_close_input(&pFormatCtx);
    NSLog(@"Error when getting thumbnails: Pixel format is null");
    return -1;
  }

  ret = avcodec_open2(pCodecCtx, pCodec, &optionsDict);
  CHECK_SUCCESS(ret, @"Cannot open codec")

  // Allocate video frame
  AVFrame *pFrame = av_frame_alloc();
  CHECK_NOTNULL(pFrame, @"Cannot alloc video frame")

  // Allocate the output frame
  // We need to convert the video frame to RGBA to satisfy CGImage's data format
  int thumbWidth = thumbnailsWidth;
  int thumbHeight = (float)thumbWidth / ((float)pCodecCtx->width / pCodecCtx->height);

  AVFrame *pFrameRGB = av_frame_alloc();
  CHECK_NOTNULL(pFrameRGB, @"Cannot alloc RGBA frame")

  pFrameRGB->width = thumbWidth;
  pFrameRGB->height = thumbHeight;
  pFrameRGB->format = AV_PIX_FMT_RGBA;

  // Determine required buffer size and allocate buffer
  int size = av_image_get_buffer_size(pFrameRGB->format, thumbWidth, thumbHeight, 1);
  uint8_t *pFrameRGBBuffer = (uint8_t *)av_malloc(size);

  // Assign appropriate parts of buffer to image planes in pFrameRGB
  ret = av_image_fill_arrays(pFrameRGB->data,
                             pFrameRGB->linesize,
                             pFrameRGBBuffer,
                             pFrameRGB->format,
                             pFrameRGB->width,
                             pFrameRGB->height, 1);
  CHECK_SUCCESS(ret, @"Cannot fill data for RGBA frame")

  // Create a sws context for converting color space and resizing
  CHECK(pCodecCtx->pix_fmt != AV_PIX_FMT_NONE, @"Pixel format is none")
  struct SwsContext *sws_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt,
                                              pFrameRGB->width, pFrameRGB->height, pFrameRGB->format,
                                              SWS_BILINEAR,
                                              NULL, NULL, NULL);

  // Get duration and interval
  int64_t duration = av_rescale_q(pFormatCtx->duration, AV_TIME_BASE_Q, pVideoStream->time_base);
  double interval = duration / (double)self.thumbnailCount;
  double timebaseDouble = av_q2d(pVideoStream->time_base);
  AVPacket packet;

  // For each preview point
  for (i = 0; i <= self.thumbnailCount; i++) {
    int64_t seek_pos = interval * i + pVideoStream->start_time;

    avcodec_flush_buffers(pCodecCtx);

    // Seek to time point
    // avformat_seek_file(pFormatCtx, videoStream, seek_pos-interval, seek_pos, seek_pos+interval, 0);
    ret = av_seek_frame(pFormatCtx, videoStream, seek_pos, AVSEEK_FLAG_BACKWARD);
    CHECK_SUCCESS(ret, @"Cannot seek")

    avcodec_flush_buffers(pCodecCtx);

    // Read and decode frame
    while(av_read_frame(pFormatCtx, &packet) >= 0) {

      // Make sure it's video stream
      if (packet.stream_index == videoStream) {

        // Decode video frame
        if (avcodec_send_packet(pCodecCtx, &packet) < 0)
          break;

        ret = avcodec_receive_frame(pCodecCtx, pFrame);
        if (ret < 0) {  // something happened
          if (ret == AVERROR(EAGAIN))  // input not ready, retry
            continue;
          else
            break;
        }

        // Check if duplicated
        NSNumber *currentTimeStamp = @(pFrame->best_effort_timestamp);
        if ([_addedTimestamps containsObject:currentTimeStamp]) {
          double currentTime = CACurrentMediaTime();
          if (currentTime - _timestamp > 1) {
            if (self.delegate) {
              [self.delegate didUpdateThumbnails:NULL forFile: file withProgress: i];
              _timestamp = currentTime;
            }
          }
          break;
        } else {
          [_addedTimestamps addObject:currentTimeStamp];
        }

        // Convert the frame to RGBA
        ret = sws_scale(sws_ctx,
                        (const uint8_t* const *)pFrame->data,
                        pFrame->linesize,
                        0,
                        pCodecCtx->height,
                        pFrameRGB->data,
                        pFrameRGB->linesize);
        CHECK_SUCCESS(ret, @"Cannot convert frame")

        // Save the frame to disk
        [self saveThumbnail:pFrameRGB
                      width:pFrameRGB->width
                     height:pFrameRGB->height
                      index:i
                   realTime:(pFrame->best_effort_timestamp * timebaseDouble)
                    forFile:file];
        break;
      }

      // Free the packet
      av_packet_unref(&packet);
    }
  }
  // Free the scaler
  sws_freeContext(sws_ctx);

  // Free the RGB image
  av_free(pFrameRGBBuffer);
  av_frame_free(&pFrameRGB);
  // Free the YUV frame
  av_frame_free(&pFrame);

  // Free the codec
  avcodec_free_context(&pCodecCtx);
  // Close the video file
  avformat_close_input(&pFormatCtx);

  // NSLog(@"Thumbnails generated.");
  return 0;
}


- (void)saveThumbnail:(AVFrame *)pFrame width
                     :(int)width height
                     :(int)height index
                     :(int)index realTime
                     :(int)second forFile
                     :(NSString *)file
{
  // Create CGImage
  CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

  CGContextRef cgContext = CGBitmapContextCreate(pFrame->data[0],  // it's converted to RGBA so could be used directly
                                                 width, height,
                                                 8,  // 8 bit per component
                                                 width * 4,  // 4 bytes(rgba) per pixel
                                                 rgb,
                                                 kCGImageAlphaPremultipliedLast);
  CGImageRef cgImage = CGBitmapContextCreateImage(cgContext);

  // Create NSImage
  NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size: NSZeroSize];

  // Free resources
  CFRelease(rgb);
  CFRelease(cgContext);
  CFRelease(cgImage);

  // Add to list
  FFThumbnail *tb = [[FFThumbnail alloc] init];
  tb.image = image;
  tb.realTime = second;
  [_thumbnails addObject:tb];
  [_thumbnailPartialResult addObject:tb];
  // Post update notification
  double currentTime = CACurrentMediaTime();
  if (currentTime - _timestamp >= 0.2) {  // min notification interval: 0.2s
    if (_thumbnailPartialResult.count >= 10 || (currentTime - _timestamp >= 1 && _thumbnailPartialResult.count > 0)) {
      if (self.delegate) {
        [self.delegate didUpdateThumbnails:[NSArray arrayWithArray:_thumbnailPartialResult]
                                   forFile: file
                              withProgress: index];
      }
      [_thumbnailPartialResult removeAllObjects];
      _timestamp = currentTime;
    }
  }
}

// HDR
// Backward conversion from primaries metadata to color space is taken from here
// https://github.com/rigaya/NVEnc/issues/51#issuecomment-392572746
// Also from File__Analyze_Streams.cpp in MediaInfo

struct masteringdisplaycolorvolume_values
{
    int Code; //ISO code
    double Values[8]; // G, B, R, W pairs (x values then y values)
};
static const int MasteringDisplayColorVolume_Values_Size=4;
static const struct masteringdisplaycolorvolume_values MasteringDisplayColorVolume_Values[] =
{
    { 1, {15000, 30000,  7500,  3000, 32000, 16500, 15635, 16450}}, // BT.709
    { 9, { 8500, 39850,  6550,  2300, 35400, 14600, 15635, 16450}}, // BT.2020
    {11, {13250, 34500,  7500,  3000, 34000, 16000, 15700, 17550}}, // DCI P3
    {12, {13250 /*green_x*/, 34500 /*green_y*/,  7500 /*blue_x*/,  3000 /*blue_y*/, 34000 /*red_x*/, 16000 /*red_y*/, /* whitepoint_x */ 15635, /* whitepoint_y */ 16450}}, // Display P3
};

static inline double avr2d(AVRational a) {
  return (double)a.num / (double)a.den;
}

+ (NSDictionary *)getColorSpaceMetadataForFile:(nonnull NSString *)file
{
  int ret;
  AVFormatContext *pFormatCtx = NULL;
  AVCodecContext *pCodecCtx = NULL;
  AVFrame *pFrame = NULL;

  @try {
    char *cFilename = strdup(file.fileSystemRepresentation);
    ret = avformat_open_input(&pFormatCtx, cFilename, NULL, NULL);
    free(cFilename);
    if (ret < 0) return NULL;

    ret = avformat_find_stream_info(pFormatCtx, NULL);
    if (ret < 0) return NULL;

    int videoStream = av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (videoStream < 0) return NULL;

    // Get the codec context for the video stream
    AVStream *pVideoStream = pFormatCtx->streams[videoStream];

    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];

    switch (pVideoStream->codecpar->color_trc)
    {
      // ITU-R BT.2100 HLG (Hybrid Log-gamma) curve, aka ARIB STD-B67
      case AVCOL_TRC_ARIB_STD_B67: info[@"color-trc"] = @"hlg"; break;
      // ITU-R BT.2100 PQ (Perceptual quantizer) curve, aka SMPTE ST2084
      // assuming that AVCOL_TRC_SMPTEST2084 and AVCOL_TRC_SMPTE2084 have same value
      case AVCOL_TRC_SMPTE2084: info[@"color-trc"] = @"pq"; break;

      default: return NULL; // SDR content
    }

    AVMasteringDisplayMetadata *metadata = (AVMasteringDisplayMetadata *)av_stream_get_side_data(pVideoStream, AV_PKT_DATA_MASTERING_DISPLAY_METADATA, NULL);

    if (!metadata) {
      // Find the decoder for the video stream
      const AVCodec *pCodec = avcodec_find_decoder(pVideoStream->codecpar->codec_id);
      if (!pCodec) return NULL;

      // Open codec
      pCodecCtx = avcodec_alloc_context3(pCodec);
      if (!pCodecCtx) return NULL;

      ret = avcodec_parameters_to_context(pCodecCtx, pVideoStream->codecpar);
      if (ret < 0) return NULL;

      ret = avcodec_open2(pCodecCtx, pCodec, NULL);
      if (ret < 0) return NULL;

      AVPacket packet;
      while (av_read_frame(pFormatCtx, &packet) >= 0) {
        if (packet.stream_index != videoStream) continue;
        ret = avcodec_send_packet(pCodecCtx, &packet);
        if (ret < 0) break;

        metadata = (AVMasteringDisplayMetadata *)av_packet_get_side_data(&packet, AV_PKT_DATA_MASTERING_DISPLAY_METADATA, NULL);
        if (metadata) break;

        pFrame = av_frame_alloc();
        ret = avcodec_receive_frame(pCodecCtx, pFrame);
        if (ret < 0) {
          if (ret == AVERROR(EAGAIN)) continue;
          break;
        }

        AVFrameSideData* side_data = av_frame_get_side_data(pFrame, AV_FRAME_DATA_MASTERING_DISPLAY_METADATA);

        if(side_data) metadata = (AVMasteringDisplayMetadata *) side_data->data;
        break;
      }
    }

    if (metadata && metadata->has_primaries)
    {
      int code = -1;
      for (int i=0; i<MasteringDisplayColorVolume_Values_Size; i++)
      {
        const struct masteringdisplaycolorvolume_values* values = &MasteringDisplayColorVolume_Values[i];
        int j = 0;

        // +/- 0.0005 (3 digits after comma)
        double gValue = avr2d(metadata->display_primaries[1][0]) / 0.00002;
        if (gValue<values->Values[0*2+j]-25 || gValue>=values->Values[0*2+j]+25)
          continue;
        double bValue = avr2d(metadata->display_primaries[2][0]) / 0.00002;
        if (bValue<values->Values[1*2+j]-25 || bValue>=values->Values[1*2+j]+25)
          continue;
        double rValue = avr2d(metadata->display_primaries[0][0]) / 0.00002;
        if (rValue<values->Values[2*2+j]-25 || rValue>=values->Values[2*2+j]+25)
          continue;

        // +/- 0.00005 (4 digits after comma)
        double wpValue = avr2d(metadata->white_point[0]) / 0.00002;
        if (wpValue<values->Values[3*2+j]-2 || wpValue>=values->Values[3*2+j]+3)
          continue;

        code = values->Code;
        break;
      }

      switch (code)
      {
        case 9: info[@"primaries"] = @"bt.2020"; break;
        case 11: info[@"primaries"] = @"dci-p3"; break;
        case 12: info[@"primaries"] = @"display-p3"; break;

        case 1: // bt709. The source may not be correctly encoded, ignoring...
        default:
          break;
      }
    }

    if (!info[@"primaries"]) {
      NSLog(@"HDR: Video source doesn't provide master display metadata");

      switch (pVideoStream->codecpar->color_primaries) {
        case AVCOL_PRI_SMPTE432: info[@"primaries"] = @"display-p3"; break;
        case AVCOL_PRI_SMPTE431: info[@"primaries"] = @"dci-p3"; break;
        case AVCOL_PRI_BT2020: default: info[@"primaries"] = @"bt.2020"; break;
      }
    }

    if (metadata && metadata->has_luminance)
    {
      double max_luminance = avr2d(metadata->max_luminance);
      info[@"max_luminance"] = [NSNumber numberWithDouble:max_luminance];
      double min_luminance = avr2d(metadata->min_luminance);
      info[@"min_luminance"] = [NSNumber numberWithDouble:min_luminance];
    }

    NSLog(@"HDR: primaries=%@ color-trc=%@ max_luminance=%@", info[@"primaries"], info[@"color-trc"], info[@"max_luminance"]);

    return info;
  } @finally {
    if (pFrame) {
      av_frame_free(&pFrame);
    }
    if (pCodecCtx) {
      avcodec_free_context(&pCodecCtx);
    }
    if (pFormatCtx) {
      avformat_close_input(&pFormatCtx);
      avformat_free_context(pFormatCtx);
    }
  }
}

+ (NSDictionary *)probeVideoInfoForFile:(nonnull NSString *)file
{
  int ret;
  int64_t duration;

  char *cFilename = strdup(file.fileSystemRepresentation);

  AVFormatContext *pFormatCtx = NULL;
  ret = avformat_open_input(&pFormatCtx, cFilename, NULL, NULL);
  free(cFilename);
  if (ret < 0) {
    NSLog(@"Error when opening file %@ to obtain info: %s (%d)", file, av_err2str(ret), ret);
    return NULL;
  }

  duration = pFormatCtx->duration;
  if (duration <= 0) {
    ret = avformat_find_stream_info(pFormatCtx, NULL);
    if (ret < 0) {
      NSLog(@"Error when probing %@ to obtain info: %s (%d)", file, av_err2str(ret), ret);
      duration = -1;
    } else
      duration = pFormatCtx->duration;
  }

  NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
  info[@"@iina_duration"] = duration == -1 ? [NSNumber numberWithInt:-1] : [NSNumber numberWithDouble:(double)duration / AV_TIME_BASE];
  AVDictionaryEntry *tag = NULL;
  while ((tag = av_dict_get(pFormatCtx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
    info[[NSString stringWithCString:tag->key encoding:NSUTF8StringEncoding]] = [NSString stringWithCString:tag->value encoding:NSUTF8StringEncoding];

  avformat_close_input(&pFormatCtx);
  avformat_free_context(pFormatCtx);

  return info;
}

@end
