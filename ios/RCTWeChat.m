//
//  RCTWeChat.m
//  RCTWeChat
//
//  Created by Yorkie Liu on 10/16/15.
//  Copyright © 2015 WeFlex. All rights reserved.
//

#import "RCTWeChat.h"
#import "WXApiObject.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTBridge.h>
#import <React/RCTLog.h>
#import <React/RCTImageLoader.h>

// Define error messages
#define NOT_REGISTERED (@"registerApp required.")
#define INVOKE_FAILED (@"WeChat API invoke returns false.")

@implementation RCTWeChat

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"RCTOpenURLNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * aURL = [NSURL URLWithString:aURLString];

    if ([WXApi handleOpenURL:aURL delegate:self])
    {
        return YES;
    } else {
        return NO;
    }
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

RCT_EXPORT_METHOD(registerApp:(NSString *)appid
                  :(NSString*) UNIVERSAL_LINK
                  :(RCTResponseSenderBlock)callback)
{
    self.appId = appid;
    //在register之前打开log, 后续可以根据log排查问题
    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
        NSLog(@"WeChatSDK: %@", log);
    }];
    callback(@[[WXApi registerApp:appid universalLink:UNIVERSAL_LINK] ? [NSNull null] : INVOKE_FAILED]);
    //调用自检函数
    // [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
    //     NSLog(@"WXULCheckStep: %@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
    // }];
}

RCT_EXPORT_METHOD(registerAppWithDescription:(NSString *)appid
                  :(NSString*) UNIVERSAL_LINK
                  :(NSString *)appdesc
                  :(RCTResponseSenderBlock)callback)
{
    //在register之前打开log, 后续可以根据log排查问题
    [WXApi startLogByLevel:WXLogLevelDetail logBlock:^(NSString *log) {
        NSLog(@"WeChatSDK: %@", log);
    }];
    self.appId = appid;
    callback(@[[WXApi registerApp:appid universalLink:UNIVERSAL_LINK] ? [NSNull null] : INVOKE_FAILED]);
    //调用自检函数
    // [WXApi checkUniversalLinkReady:^(WXULCheckStep step, WXCheckULStepResult* result) {
    //     NSLog(@"WXULCheckStep: %@, %u, %@, %@", @(step), result.success, result.errorInfo, result.suggestion);
    // }];
}

RCT_EXPORT_METHOD(isWXAppInstalled:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([WXApi isWXAppInstalled])]);
}

RCT_EXPORT_METHOD(isWXAppSupportApi:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], @([WXApi isWXAppSupportApi])]);
}

RCT_EXPORT_METHOD(getWXAppInstallUrl:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], [WXApi getWXAppInstallUrl]]);
}

RCT_EXPORT_METHOD(getApiVersion:(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], [WXApi getApiVersion]]);
}

RCT_EXPORT_METHOD(openWXApp:(RCTResponseSenderBlock)callback)
{
    callback(@[([WXApi openWXApp] ? [NSNull null] : INVOKE_FAILED)]);
}

RCT_EXPORT_METHOD(sendRequest:(NSString *)openid
                  :(RCTResponseSenderBlock)callback)
{
    BaseReq* req = [[BaseReq alloc] init];
    req.openID = openid;
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendReq成功");
            callback(@[[NSNull null], @"sendReq成功"]);
        } else {
            NSLog(@"sendReq异常");
            callback(@[INVOKE_FAILED, @"sendReq异常"]);
        }
    }];
}

RCT_EXPORT_METHOD(sendAuthRequest:(NSString *)scope
                  :(NSString *)state
                  :(RCTResponseSenderBlock)callback)
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = scope;
    req.state = state;
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            NSLog(@"SendAuthReq成功");
            callback(@[[NSNull null], @"SendAuthReq成功"]);
        } else {
            NSLog(@"SendAuthReq异常");
            callback(@[INVOKE_FAILED, @"SendAuthReq异常"]);
        }
    }];
}

RCT_EXPORT_METHOD(sendSuccessResponse:(RCTResponseSenderBlock)callback)
{
    BaseResp* resp = [[BaseResp alloc] init];
    resp.errCode = WXSuccess;
    [WXApi sendResp:resp completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendResp成功");
            callback(@[[NSNull null], @"sendResp成功"]);
        } else {
            NSLog(@"sendResp异常");
            callback(@[INVOKE_FAILED, @"sendResp异常"]);
        }
    }];
}

RCT_EXPORT_METHOD(sendErrorCommonResponse:(NSString *)message
                  :(RCTResponseSenderBlock)callback)
{
    BaseResp* resp = [[BaseResp alloc] init];
    resp.errCode = WXErrCodeCommon;
    resp.errStr = message;
    [WXApi sendResp:resp completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendResp成功");
            callback(@[[NSNull null], @"sendResp成功"]);
        } else {
            NSLog(@"sendResp异常");
            callback(@[INVOKE_FAILED, @"sendResp异常"]);
        }
    }];
}

RCT_EXPORT_METHOD(sendErrorUserCancelResponse:(NSString *)message
                  :(RCTResponseSenderBlock)callback)
{
    BaseResp* resp = [[BaseResp alloc] init];
    resp.errCode = WXErrCodeUserCancel;
    resp.errStr = message;
    [WXApi sendResp:resp completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendResp成功");
            callback(@[[NSNull null], @"sendResp成功"]);
        } else {
            NSLog(@"sendResp异常");
            callback(@[INVOKE_FAILED, @"sendResp异常"]);
        }
    }];
}

RCT_EXPORT_METHOD(shareToTimeline:(NSDictionary *)data
                  :(RCTResponseSenderBlock)callback)
{
    [self shareToWeixinWithData:data scene:WXSceneTimeline callback:callback];
}

RCT_EXPORT_METHOD(shareToSession:(NSDictionary *)data
                  :(RCTResponseSenderBlock)callback)
{
    [self shareToWeixinWithData:data scene:WXSceneSession callback:callback];
}

RCT_EXPORT_METHOD(shareToFavorite:(NSDictionary *)data
                  :(RCTResponseSenderBlock)callback)
{
    [self shareToWeixinWithData:data scene:WXSceneFavorite callback:callback];
}

RCT_EXPORT_METHOD(pay:(NSDictionary *)data
                  :(RCTResponseSenderBlock)callback)
{
    PayReq* req             = [PayReq new];
    req.partnerId           = data[@"partnerId"];
    req.prepayId            = data[@"prepayId"];
    req.nonceStr            = data[@"nonceStr"];
    req.timeStamp           = [data[@"timeStamp"] unsignedIntValue];
    req.package             = data[@"package"];
    req.sign                = data[@"sign"];
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendReq成功");
            callback(@[[NSNull null], @"sendReq成功"]);
        } else {
            NSLog(@"sendReq异常");
            callback(@[INVOKE_FAILED, @"sendReq异常"]);
        }
    }];
}

- (void)shareToWeixinWithData:(NSDictionary *)aData
                   thumbImage:(UIImage *)aThumbImage
                        scene:(int)aScene
                     callBack:(RCTResponseSenderBlock)callback
{
    NSString *type = aData[RCTWXShareType];

    if ([type isEqualToString:RCTWXShareTypeText]) {
        NSString *text = aData[RCTWXShareDescription];
        [self shareToWeixinWithTextMessage:aScene Text:text callBack:callback];
    } else {
        NSString * title = aData[RCTWXShareTitle];
        NSString * description = aData[RCTWXShareDescription];
        NSString * mediaTagName = aData[@"mediaTagName"];
        NSString * messageAction = aData[@"messageAction"];
        NSString * messageExt = aData[@"messageExt"];

        if (type.length <= 0 || [type isEqualToString:RCTWXShareTypeNews]) {
            NSString * webpageUrl = aData[RCTWXShareWebpageUrl];
            if (webpageUrl.length <= 0) {
                callback(@[@"webpageUrl required"]);
                return;
            }

            WXWebpageObject* webpageObject = [WXWebpageObject object];
            webpageObject.webpageUrl = webpageUrl;

            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:webpageObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];

        } else if ([type isEqualToString:RCTWXShareTypeAudio]) {
            WXMusicObject *musicObject = [WXMusicObject new];
            musicObject.musicUrl = aData[@"musicUrl"];
            musicObject.musicLowBandUrl = aData[@"musicLowBandUrl"];
            musicObject.musicDataUrl = aData[@"musicDataUrl"];
            musicObject.musicLowBandDataUrl = aData[@"musicLowBandDataUrl"];

            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:musicObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];

        } else if ([type isEqualToString:RCTWXShareTypeVideo]) {
            WXVideoObject *videoObject = [WXVideoObject new];
            videoObject.videoUrl = aData[@"videoUrl"];
            videoObject.videoLowBandUrl = aData[@"videoLowBandUrl"];

            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:videoObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];

        } else if ([type isEqualToString:RCTWXShareTypeImageUrl] ||
                   [type isEqualToString:RCTWXShareTypeImageFile] ||
                   [type isEqualToString:RCTWXShareTypeImageResource]) {
            NSURL *url = [NSURL URLWithString:aData[RCTWXShareImageUrl]];
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
            [self.bridge.imageLoader loadImageWithURLRequest:imageRequest callback:^(NSError *error, UIImage *image) {
                if (image == nil){
                    callback(@[@"fail to load image resource"]);
                } else {
                    WXImageObject *imageObject = [WXImageObject object];
                    imageObject.imageData = UIImagePNGRepresentation(image);
                    
                    [self shareToWeixinWithMediaMessage:aScene
                                                  Title:title
                                            Description:description
                                                 Object:imageObject
                                             MessageExt:messageExt
                                          MessageAction:messageAction
                                             ThumbImage:aThumbImage
                                               MediaTag:mediaTagName
                                               callBack:callback];
                    
                }
            }];
        } else if ([type isEqualToString:RCTWXShareTypeFile]) {
            NSString * filePath = aData[@"filePath"];
            NSString * fileExtension = aData[@"fileExtension"];

            WXFileObject *fileObject = [WXFileObject object];
            fileObject.fileData = [NSData dataWithContentsOfFile:filePath];
            fileObject.fileExtension = fileExtension;

            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:fileObject
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];

        } else if ([type isEqualToString:RCTWXShareTypeMiniProgram]) {
            NSString * webpageUrl = aData[RCTWXShareWebpageUrl];
            WXMiniProgramObject *miniProgramObj = [WXMiniProgramObject object];
            miniProgramObj.webpageUrl = webpageUrl; // 兼容低版本的网页链接
            miniProgramObj.miniProgramType = [aData[@"miniprogramType"] intValue]; //WXMiniProgramObject.MINIPTOGRAM_TYPE_RELEASE;// 正式版:0，测试版:1，体验版:2
            miniProgramObj.userName = aData[@"userName"];     // 小程序原始id
            miniProgramObj.path = aData[@"path"];
            [self shareToWeixinWithMediaMessage:aScene
                                          Title:title
                                    Description:description
                                         Object:miniProgramObj
                                     MessageExt:messageExt
                                  MessageAction:messageAction
                                     ThumbImage:aThumbImage
                                       MediaTag:mediaTagName
                                       callBack:callback];
            
        } else {
            callback(@[@"message type unsupported"]);
        }
    }
}


// - (void)shareToWeixinWithData:(NSDictionary *)aData scene:(int)aScene callback:(RCTResponseSenderBlock)aCallBack
// {
//     NSString *imageUrl = aData[RCTWXShareTypeThumbImageUrl];
//     if (imageUrl.length && _bridge.imageLoader) {
//         NSURL *url = [NSURL URLWithString:imageUrl];
//         NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
//         [_bridge.imageLoader loadImageWithURLRequest:imageRequest size:CGSizeMake(100, 100) scale:1 clipped:FALSE resizeMode:RCTResizeModeStretch progressBlock:nil partialLoadBlock:nil
//             completionBlock:^(NSError *error, UIImage *image) {
//             [self shareToWeixinWithData:aData thumbImage:image scene:aScene callBack:aCallBack];
//         }];
//     } else {
//         [self shareToWeixinWithData:aData thumbImage:nil scene:aScene callBack:aCallBack];
//     }

// }

- (void)shareToWeixinWithData:(NSDictionary *)aData scene:(int)aScene callback:(RCTResponseSenderBlock)aCallBack
{
    NSString *imageUrl = aData[RCTWXShareTypeThumbImageUrl];
    if (imageUrl.length && _bridge.imageLoader) {
        NSURL *url = [NSURL URLWithString:imageUrl];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
       if ([aData[RCTWXShareType] isEqualToString:RCTWXShareTypeMiniProgram]) {
            [self shareToWeixinWithData:aData thumbImage:image scene:aScene callBack:aCallBack];
        }else{
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:url];
            [_bridge.imageLoader loadImageWithURLRequest:imageRequest size:CGSizeMake(100, 100) scale:1 clipped:FALSE resizeMode:RCTResizeModeStretch progressBlock:nil partialLoadBlock:nil
                                         completionBlock:^(NSError *error, UIImage *image) {
                                             [self shareToWeixinWithData:aData thumbImage:image scene:aScene callBack:aCallBack];
                                         }];
        }
    } else {
        [self shareToWeixinWithData:aData thumbImage:nil scene:aScene callBack:aCallBack];
    }

}

- (void)shareToWeixinWithTextMessage:(int)aScene
                                Text:(NSString *)text
                                callBack:(RCTResponseSenderBlock)callback
{
    SendMessageToWXReq* req = [SendMessageToWXReq new];
    req.bText = YES;
    req.scene = aScene;
    req.text = text;
    
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendReq成功");
            callback(@[[NSNull null], @"sendReq成功"]);
        } else {
            NSLog(@"sendReq异常");
            callback(@[INVOKE_FAILED, @"sendReq异常"]);
        }
    }];
}

- (void)shareToWeixinWithMediaMessage:(int)aScene
                                Title:(NSString *)title
                          Description:(NSString *)description
                               Object:(id)mediaObject
                           MessageExt:(NSString *)messageExt
                        MessageAction:(NSString *)action
                           ThumbImage:(UIImage *)thumbImage
                             MediaTag:(NSString *)tagName
                             callBack:(RCTResponseSenderBlock)callback
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    message.mediaObject = mediaObject;
    message.messageExt = messageExt;
    message.messageAction = action;
    message.mediaTagName = tagName;
    [message setThumbImage:thumbImage];

    SendMessageToWXReq* req = [SendMessageToWXReq new];
    req.bText = NO;
    req.scene = aScene;
    req.message = message;
    
    [WXApi sendReq:req completion:^(BOOL success) {
        if (success) {
            NSLog(@"sendReq成功");
            callback(@[[NSNull null], @"sendReq成功"]);
        } else {
            NSLog(@"sendReq异常");
            callback(@[INVOKE_FAILED, @"sendReq异常"]);
        }
    }];
}

#pragma mark - wx callback

-(void) onReq:(BaseReq*)req
{
    // TODO(Yorkie)
    NSLog(@"onReq!!!!!");
}

-(void) onResp:(BaseResp*)resp
{
    NSLog(@"OnResp!!!!!");
	if([resp isKindOfClass:[SendMessageToWXResp class]])
	{
	    SendMessageToWXResp *r = (SendMessageToWXResp *)resp;
    
	    NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
	    body[@"errStr"] = r.errStr;
	    body[@"lang"] = r.lang;
	    body[@"country"] =r.country;
	    body[@"type"] = @"SendMessageToWX.Resp";
	    [self.bridge.eventDispatcher sendDeviceEventWithName:RCTWXEventName body:body];
	} else if ([resp isKindOfClass:[SendAuthResp class]]) {
	    SendAuthResp *r = (SendAuthResp *)resp;
	    NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
	    body[@"errStr"] = r.errStr;
	    body[@"state"] = r.state;
	    body[@"lang"] = r.lang;
	    body[@"country"] =r.country;
	    body[@"type"] = @"SendAuth.Resp";
    
	    if (resp.errCode == WXSuccess) {
	        if (self.appId && r) {
		    // ios第一次获取不到appid会卡死，加个判断OK		
		    [body addEntriesFromDictionary:@{@"appid":self.appId, @"code":r.code}];
		    [self.bridge.eventDispatcher sendDeviceEventWithName:RCTWXEventName body:body];
	        }
	    }
	    else {
	        [self.bridge.eventDispatcher sendDeviceEventWithName:RCTWXEventName body:body];
	    }
	} else if ([resp isKindOfClass:[PayResp class]]) {
	        PayResp *r = (PayResp *)resp;
	        NSMutableDictionary *body = @{@"errCode":@(r.errCode)}.mutableCopy;
	        body[@"errStr"] = r.errStr;
	        body[@"type"] = @(r.type);
	        body[@"returnKey"] =r.returnKey;
	        body[@"type"] = @"PayReq.Resp";
	        [self.bridge.eventDispatcher sendDeviceEventWithName:RCTWXEventName body:body];
    	}
}

@end
