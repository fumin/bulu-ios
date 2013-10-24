//
//  MessageReceiver.mm
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import "MessageReceiver.h"

#import "AJNInterfaceDescription.h"

void createBuluInterface(AJNBusAttachment* busAttachment)
{
    AJNInterfaceDescription* interface = [busAttachment createInterfaceWithName:kInterfaceName];
    QStatus status = ER_OK;
    
    // bulu(string name, string type, char[] message);
    status = [interface addSignalWithName:@"bulu" inputSignature:@"sss"
                            argumentNames:[NSArray arrayWithObject:@"username,type,data"]];
    if (status != ER_OK) {
        NSLog(@"ERROR: Failed to add signal to chat interface. %@", [AJNStatus descriptionForStatusCode:status]);
        return;
    }
    [interface activate];
}
