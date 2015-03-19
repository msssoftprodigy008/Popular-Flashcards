/*
 *  FISRHeader.h
 *  flashCards
 *
 *  Created by Ruslan on 9/7/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define kFISessionId @"ads.flashCards.session"
#define kFISessionId2 @"ads.flashCards2.session"
#define kFISessionLenSend 3
#define kFISessionDataSendingEnd 2
#define kFISessionDataSendingNotEnd 1
#define kFISessionDataAllSend -100
#define kFISessionStopSending -200
#define kFISessionSendingFailed 0
#define kFISessionDataRecieved 1
#define kFISessionAllDataRecieved 2
#define kFISessionWhantSyncSend 100
#define kFISessionNOSyncSend 101

typedef struct{
	int lengh;
	char* name;
}header;

typedef enum{
	FIWifiModeShareCards,
	FIWifiModeSync
}FIWifiMode;

typedef enum{
	FISyncModeServer,
	FISyncModeClient,
	FISyncModeNone
}FISyncMode;
