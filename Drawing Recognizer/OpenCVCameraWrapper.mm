//
//  OpenCVCameraWrapper.m
//  ReconhecimentoDesenhos
//
//  Created by Gabriel on 2020-04-23.
//  Copyright © 2020 Gabriel. All rights reserved.
//

#ifdef __cplusplus

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#endif

#import "OpenCVCameraWrapper.h"

@interface OpenCVCameraWrapper () <CvVideoCameraDelegate>

@property CvVideoCamera *camera;
@property cv::Rect currentBoundingBox;
@property cv::Mat currentImage;

- (void)calculateCurrentBoundingBox:(cv::Mat&)image;

@end

@implementation OpenCVCameraWrapper

- (void)setupCameraFeed:(UIImageView*)view {
    _camera = [[CvVideoCamera alloc] initWithParentView:view];
    _camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
    _camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _camera.defaultFPS = 60;
    _camera.delegate = self;
}

- (void)processImage:(cv::Mat&)image {
    _currentImage = image.clone();
    [self calculateCurrentBoundingBox: image];
    if (_currentBoundingBox.area() > 0) {
        cv::rectangle(image, _currentBoundingBox, cv::Scalar(0, 0, 255));
    }
}

- (void)startCamera {
    if (!_camera.running) {
        [_camera start];
    }
}

- (void)stopCamera {
    if (_camera.running) {
        [_camera stop];
    }
}

- (CGRect)getCurrentBoundingBox {
    return CGRectMake(_currentBoundingBox.x
                      , _currentBoundingBox.y, _currentBoundingBox.width, _currentBoundingBox.height);
}

- (void)calculateCurrentBoundingBox:(cv::Mat&)image {
    cv::Mat imageToProcess;
    cv::cvtColor(image, imageToProcess, cv::COLOR_BGRA2GRAY);
    
    cv::medianBlur(imageToProcess, imageToProcess, 3);
    
    cv::adaptiveThreshold(imageToProcess, imageToProcess, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, 7, 11);

    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3));
    cv::morphologyEx(imageToProcess, imageToProcess, cv::MORPH_DILATE, kernel);
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(imageToProcess, contours, hierarchy, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
    
    std::vector<cv::Point> points;
    for (int i = 0; i < contours.size(); i++) {
        std::vector<cv::Point> contourPoints = contours.at(i);
        for (int j = 0; j < contourPoints.size(); j++) {
            points.push_back(contourPoints.at(j));
        }
    }
    
    if (points.size() > 0) {
        _currentBoundingBox = cv::boundingRect(points);
    } else {
        _currentBoundingBox = cv::Rect(0, 0, 0, 0);
    }
}

- (UIImage *)getCurrentImage {
    cv::Mat rgbImage;
    cv::cvtColor(_currentImage, rgbImage, cv::COLOR_BGRA2RGBA);
    return MatToUIImage(rgbImage);
}

- (UIImage *)getCurrentROI {
    cv::Mat roi(_currentImage.clone(), _currentBoundingBox);
    cv::resize(roi, roi, cv::Size(28, 28));
    cv::cvtColor(roi, roi, cv::COLOR_BGRA2GRAY);
    cv::adaptiveThreshold(roi, roi, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, 7, 11);
    return MatToUIImage(roi);
}

@end
