//
//  MessageSignalHandlerImpl.h
//  Bulu
//
//  Created by apple on 13/2/17.
//  Copyright (c) 2013年 cardinalblue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AJNSignalHandlerImpl.h"
#import <alljoyn/BusObject.h>

#import "MessageReceiver.h"

class MessageSignalHandlerImpl : public ajn::BusObject {
protected:
    
    /**
     * Objective C delegate called when one of the below virtual functions
     * is called.
     */
    __weak id<MessageReceiver> m_delegate;
    
private:
    const ajn::InterfaceDescription::Member* buluSignalMember;
    
    /** Receive a signal from another Chat client */
    void MessageSignalHandler(const ajn::InterfaceDescription::Member* member, const char* srcPath, ajn::Message& msg);
    
public:
    /**
     * Constructor for the AJN signal handler implementation.
     *
     * @param aDelegate         Objective C delegate called when one of the below virtual functions is called.
     */
    MessageSignalHandlerImpl(id<MessageReceiver> aDelegate, const char* path);
    
    virtual void RegisterSignalHandler(ajn::BusAttachment& bus);
    
    virtual void UnregisterSignalHandler(ajn::BusAttachment& bus);
    
    /**
     * Virtual destructor for derivable class.
     */
    virtual ~MessageSignalHandlerImpl();
    
    // Send a bulu signal
    QStatus SendBuluSignal(const char* username, const char* type, const char* data,
                           ajn::SessionId sessionId, AJNMessageFlag messageFlags=kAJNMessageFlagSessionless);
};
