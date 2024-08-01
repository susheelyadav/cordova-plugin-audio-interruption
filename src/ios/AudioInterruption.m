#import "AudioInterruption.h"

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
         NSNumber *interruptionType = notification.userInfo[AVAudioSessionInterruptionTypeKey];
         
        if ([[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] isEqualToNumber:[NSNumber numberWithInt:AVAudioSessionInterruptionTypeBegan]]) {
           NSString * statusMessage = [NSString stringWithFormat:@"INTERRUPTION_BEGIN_%@", interruptionType];
(*             [self sendStatusNameInJS:@"INTERRUPTION_BEGIN"]; *)
            [self sendStatusNameInJS:statusMessage];
        } else {
(*             [self sendStatusNameInJS:@"INTERRUPTION_ENDED"]; *)
           NSString * statusMessage = [NSString stringWithFormat:@"INTERRUPTION_ENDED_%@", interruptionType];
           [self sendStatusNameInJS:statusMessage];
        }
    }
}

@end
