#import "AudioInterruption.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@implementation AudioInterruption

- (void) pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
}

- (void) addListener:(CDVInvokedUrlCommand*)command
{
    successCallbackID = command.callbackId;
}

// Send status back to JS env through subscribe callback
- (void) sendStatusNameInJS: (NSString*) status {
    plresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:status];
    [plresult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:plresult callbackId:successCallbackID];
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        // Check to see if it was a Begin interruption
        NSString *interruptionType;
        NSString *statusMessage;

        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
            CTCallCenter *callCenter = [[CTCallCenter alloc] init];
            CTCall *call = [[callCenter currentCalls] anyObject];
            if (call != nil && call.callState == CTCallStateIncoming) {
                interruptionType = @"INCOMING_CALL";
            }
          statusMessage = [NSString stringWithFormat:@"INTERRUPTION_BEGIN_%@", interruptionType];
            [self sendStatusNameInJS:statusMessage];
        } else {
           statusMessage = [NSString stringWithFormat:@"INTERRUPTION_ENDED_%@", interruptionType];
           [self sendStatusNameInJS:statusMessage];
        }
    }
}

@end
