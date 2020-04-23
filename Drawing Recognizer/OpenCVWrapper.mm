//
//  OpenCVWrapper.m
//  ReconhecimentoDesenhos
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

#ifdef __cplusplus

#import <opencv2/opencv.hpp>

#endif

#import "OpenCVWrapper.h"

@interface OpenCVWrapper ()

@end

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

@end
