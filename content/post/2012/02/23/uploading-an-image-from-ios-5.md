---
author: Steve Good
date: 2012-02-23
title: Uploading an image from iOS 5
draft: false
slug: uploading-an-image-from-ios-5
tags:
- ios
- image
---

Lately I've been working steadily towards getting an iOS app released for my company, [KaiNexus][].  The first pass at this app will have the basic ability to submit an idea from your phone and be able to attach a picture.  Since I am still a novice with Objective-C it was no surprise when I ran into a brick wall when trying to upload the image from the app.  This prompted me to [ask on stackoverflow][ask on stackoverflow] to see what I had done wrong.

As it turns out, I was using an incorrect combination of line endings and content types.  I now have working code in my app and figured I would share it so that anyone else running into this problem would have a starting point.  Below is the function I wrote to handle uploading an image in Objective-C on iOS 5 (the grails pieces can be found on the [SO question][ask on stackoverflow]).

```objective-c
+ (BOOL)uploadImage:(UIImage *)image withName:(NSString *)fileName toURL:(NSURL *)url {
    NSData *imageData = UIImageJPEGRepresentation(image, 100);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"0x0hHai1CanHazB0undar135";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageToAttach\"; filename=\"%@\"\r\n",fileName]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];

    NSLog(@"%@",returnString);

    return YES;
}
```

[KaiNexus]: http://kainexus.com/
[ask on stackoverflow]: http://stackoverflow.com/questions/9419744/uploading-an-image-from-ios-to-grails
