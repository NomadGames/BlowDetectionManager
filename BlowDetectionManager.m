//
//  CDBlowDetectionManager.m
//  DragonsBreath
//
//  Created by Chris Lueking on 6/28/11.
//  Copyright 2011 Nomad Games, LLC. All rights reserved.
//

#import "CDBlowDetectionManager.h"


@implementation CDBlowDetectionManager

static CDBlowDetectionManager *sharedManager = nil;

+(CDBlowDetectionManager*) sharedManager {
    @synchronized(self) {
		if (sharedManager == nil) {
            sharedManager = [[CDBlowDetectionManager alloc] init];
        }

	}
    return sharedManager;
}

-(id)init{
    if((self=[super init])) {
		NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                                  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                                  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                                  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                                  nil];
        NSError *error;
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        
        _threshold = .9;
	}
	return self;
}

-(void)startListening{
    if (_recorder) {
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
        [_recorder record];
    }
}

-(void)stopListening{
    [_recorder stop];
}

-(void)logReport{
    NSLog(@"Average input in db: %f Peak input in db: %f - Power: %f Threshold Level: %f", [_recorder averagePowerForChannel:0], [_recorder peakPowerForChannel:0], _convertedPower * 100, _threshLvl);
}

-(void)listen{
    [_recorder updateMeters];
	//const double ALPHA = 0.05;
    _threshLvl = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    _avgMeter = pow(10, (0.05 * [_recorder averagePowerForChannel:0]));
	//_lowPassResults = ALPHA * _threshLvl + (1.0 - ALPHA) * _lowPassResults;
    //NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
    float avgAmbient = -35;
    _convertedPower = ((([_recorder peakPowerForChannel:0] - avgAmbient) * (1 - 0)) / (0. - avgAmbient)) + 0;
    if (_convertedPower < 0) {
        _convertedPower = 0;
    }    
    if (_threshLvl > _threshold) {
        [self logReport];
    }
}

-(BOOL)userIsBlowing{
    if (_threshLvl > _threshold) {
        return YES;
    } else {
        return NO;
    }
}

-(float)power{
    if (_threshLvl > _threshold) {
        return _convertedPower;
    } else {
        return 0;
    }
    
    
}

@end
