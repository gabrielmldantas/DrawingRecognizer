//
//  OpenCVCameraWrapper.h
//  ReconhecimentoDesenhos
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

#ifndef OpenCVCameraWrapper_h
#define OpenCVCameraWrapper_h

#include <UIKit/UIKit.h>

@interface OpenCVCameraWrapper : NSObject

- (void)setupCameraFeed:(UIImageView*)view;
- (void)startCamera;
- (void)stopCamera;
- (CGRect)getCurrentBoundingBox;
- (UIImage *)getCurrentImage;

@end

#endif /* OpenCVCameraWrapper_h */
