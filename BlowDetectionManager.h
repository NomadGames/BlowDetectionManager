//
//  CDBlowDetectionManager.h
//  DragonsBreath
//
//  Created by Chris Lueking on 6/28/11.
//  Copyright 2011 Nomad Games, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface CDBlowDetectionManager : NSObject {
    AVAudioRecorder *_recorder;
    //double _lowPassResults;
    double _threshold;
    double _threshLvl;
    double _avgMeter;
    float _convertedPower;
}

+(CDBlowDetectionManager*) sharedManager;

-(void)startListening;
-(void)listen;
-(float)power;

@end
