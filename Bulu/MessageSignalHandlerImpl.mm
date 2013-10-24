//
//  MessageSignalHandlerImpl.m
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <alljoyn/InterfaceDescription.h>
#import <alljoyn/MessageReceiver.h>
#import "Constants.h"
#import "MessageSignalHandlerImpl.h"

using namespace ajn;

/**
 * Constructor for the AJN signal handler implementation.
 *
 * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.
 */
MessageSignalHandlerImpl::MessageSignalHandlerImpl(id<MessageReceiver> aDelegate, const char* path) : m_delegate(aDelegate), buluSignalMember(NULL), BusObject(path)
{
}

MessageSignalHandlerImpl::~MessageSignalHandlerImpl()
{
    m_delegate = NULL;
}

void MessageSignalHandlerImpl::RegisterSignalHandler(ajn::BusAttachment &bus)
{
    if (buluSignalMember == NULL) {
        const ajn::InterfaceDescription* messageIntf = bus.GetInterface([kInterfaceName UTF8String]);
        
        /* Store the Chat signal member away so it can be quickly looked up */
        if (messageIntf) {
            buluSignalMember = messageIntf->GetMember("bulu");
            assert(buluSignalMember);
        }
    }
    /* Register signal handler */
    QStatus status =  bus.RegisterSignalHandler(this,
                                                (MessageReceiver::SignalHandler)(&MessageSignalHandlerImpl::MessageSignalHandler),
                                                buluSignalMember,
                                                NULL);
    if (status != ER_OK) {
        NSLog(@"ERROR:AJNCChatObjectSignalHandlerImpl::RegisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
}

void MessageSignalHandlerImpl::UnregisterSignalHandler(ajn::BusAttachment &bus)
{
    if (buluSignalMember == NULL) {
        const ajn::InterfaceDescription* chatIntf = bus.GetInterface([kInterfaceName UTF8String]);
        
        /* Store the Chat signal member away so it can be quickly looked up */
        buluSignalMember = chatIntf->GetMember("Chat");
        assert(buluSignalMember);
    }
    /* Register signal handler */
    QStatus status =  bus.UnregisterSignalHandler(this, static_cast<MessageReceiver::SignalHandler>(&MessageSignalHandlerImpl::MessageSignalHandler), buluSignalMember, NULL);
    
    if (status != ER_OK) {
        NSLog(@"ERROR:AJNCChatObjectSignalHandlerImpl::UnregisterSignalHandler failed. %@", [AJNStatus descriptionForStatusCode:status] );
    }
}

/** Receive a signal from another Bulu client */
void MessageSignalHandlerImpl::MessageSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg)
{
    @autoreleasepool {
        NSString *username = [NSString stringWithCString:msg->GetArg(0)->v_string.str encoding:NSUTF8StringEncoding];
        NSString *type = [NSString stringWithCString:msg->GetArg(1)->v_string.str encoding:NSUTF8StringEncoding];
        NSString *data = [NSString stringWithCString:msg->GetArg(2)->v_string.str encoding:NSUTF8StringEncoding];
        NSString *from = [NSString stringWithCString:msg->GetSender() encoding:NSUTF8StringEncoding];
        NSString *objectPath = [NSString stringWithCString:msg->GetObjectPath() encoding:NSUTF8StringEncoding];
    ajn:SessionId sessionId = msg->GetSessionId();
        
        NSLog(@"Received signal (username: %@, type: %@, data: %@) from %@ on path %@ for session id %u [%s > %s] this=%u",
              username, type, data,
              from, objectPath, msg->GetSessionId(), msg->GetRcvEndpointName(), msg->GetDestination() ? msg->GetDestination() : "broadcast", (uint)this);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [(id<MessageReceiver>)m_delegate buluMessageReceived:username type:type data:data
                                                            from:from onObjectPath:objectPath forSession:sessionId];
        });
        
    }
}

/* send a chat signal */
QStatus MessageSignalHandlerImpl::SendBuluSignal(const char* username, const char* type, const char* data,
                                                 ajn::SessionId sessionId, AJNMessageFlag messageFlags)
{
    if (buluSignalMember == NULL) {
        return ER_OK;
    }

    NSLog(@"SendChatSignal( %s, %u)", data, sessionId);
    
    ajn::MsgArg buluArgs[3];
    buluArgs[0].Set("s", username);
    buluArgs[1].Set("s", type);
    buluArgs[2].Set("s", data);
    
    // if we are using sessionless signals, ignore the session (obviously)
    if (messageFlags == kAJNMessageFlagSessionless) {
        sessionId = 0;
    }
    
    return Signal(NULL, sessionId, *buluSignalMember, buluArgs, 3, 0, messageFlags);
}
