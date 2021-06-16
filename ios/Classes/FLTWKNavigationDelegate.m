// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTWKNavigationDelegate.h"

@implementation FLTWKNavigationDelegate {
  FlutterMethodChannel *_methodChannel;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _methodChannel = channel;
  }
  return self;
}

#pragma mark - WKNavigationDelegate conformance

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [_methodChannel invokeMethod:@"onPageStarted" arguments:@{@"url" : webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //过滤并判断当前页面变化
    NSDictionary<NSString *, NSString *> *headers = navigationAction.request.allHTTPHeaderFields;
    NSString *accept = [headers objectForKey:@"Accept"];
    NSString *refererUrl = [headers objectForKey:@"Referer"];
//    NSLog(@"%@", accept);
    if (refererUrl != nil) {
//        NSLog(@"%@", refererUrl);
    }
    
  if (!self.hasDartNavigationDelegate){
    decisionHandler(WKNavigationActionPolicyAllow);
    return;
  }
  NSDictionary *arguments = @{
    @"url" : navigationAction.request.URL.absoluteString,
    @"isForMainFrame" : @(navigationAction.targetFrame.isMainFrame)
  };
  [_methodChannel invokeMethod:@"navigationRequest"
                     arguments:arguments
                        result:^(id _Nullable result) {
                          if ([result isKindOfClass:[FlutterError class]]) {
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          if (result == FlutterMethodNotImplemented) {
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          if (![result isKindOfClass:[NSNumber class]]) {
                            decisionHandler(WKNavigationActionPolicyAllow);
                            return;
                          }
                          NSNumber *typedResult = result;
                          decisionHandler([typedResult boolValue] ? WKNavigationActionPolicyAllow
                                                                  : WKNavigationActionPolicyCancel);
                        }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [_methodChannel invokeMethod:@"onPageFinished" arguments:@{@"url" : webView.URL.absoluteString}];
}

+ (id)errorCodeToString:(NSUInteger)code {
  switch (code) {
    case WKErrorUnknown:
      return @"unknown";
    case WKErrorWebContentProcessTerminated:
      return @"webContentProcessTerminated";
    case WKErrorWebViewInvalidated:
      return @"webViewInvalidated";
    case WKErrorJavaScriptExceptionOccurred:
      return @"javaScriptExceptionOccurred";
    case WKErrorJavaScriptResultTypeIsUnsupported:
      return @"javaScriptResultTypeIsUnsupported";
  }

  return [NSNull null];
}

- (void)onWebResourceError:(NSError *)error {
  [_methodChannel invokeMethod:@"onWebResourceError"
                     arguments:@{
                       @"errorCode" : @(error.code),
                       @"domain" : error.domain,
                       @"description" : error.description,
                       @"errorType" : [FLTWKNavigationDelegate errorCodeToString:error.code],
                     }];
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
  [self onWebResourceError:error];
}

- (void)webView:(WKWebView *)webView
    didFailProvisionalNavigation:(WKNavigation *)navigation
                       withError:(NSError *)error {
  [self onWebResourceError:error];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  NSError *contentProcessTerminatedError =
      [[NSError alloc] initWithDomain:WKErrorDomain
                                 code:WKErrorWebContentProcessTerminated
                             userInfo:nil];
  [self onWebResourceError:contentProcessTerminatedError];
}

@end
