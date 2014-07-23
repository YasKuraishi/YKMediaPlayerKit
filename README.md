YKMediaPlayerKit
================
Painlessly and natively **play** YouTube, Vimeo, and .MP4, .MOV, .MPV, .3GP videos and fetch **thumbnails** on your iOS devices.

### Overview
If you have been playing YouTube and Vimeo videos in a `UIWebView` because it is hard to figure out direct URL to an .MP4 that you can play natively on an iOS device via  `MPMoviePlayerViewController` for superior user experience then `YKMediaPlayerKit` is for you.

It not only helps you play an online YouTube, Vimeo, and all natively supported formats such as .MP4, .MOV, .MPV, .3GP with a single method call but lets you asynchronously download thumbnail images for the videos too. You can also chose from Low, Medium, or High resolution videos or thumbnails.

Its blocks based and works asynchronously and returns all block callbacks on the main thread.

    //Variable to hold parsed video
    id<YKVideo> video;

    //You can use YouTube, Vimeo, or direct video URL too.
    NSString *videoURL = @"https://www.youtube.com/watch?v=GJey_oygU3Y";

    YKMediaPlayerKit *player = [[YKMediaPlayerKit alloc] initWithURL:[NSURL URLWithString:videoURL]];
    [player parseWithCompletion:^(YKVideoTypeOptions videoType, id<YKVideo> parsedVideo, NSError *error) {

        //Save parsed video to a class level property.
        video = parsedVideo;

        //Get thumbnails
        [player thumbWithCompletion:^(UIImage *thumb, NSError *error) {
            if (thumb) {
                //set thumbnail to respective UIImageView.
                self.imageView.image = thumb;
            }
        }];
    }];

    //Play parsed video
    - (IBAction)playButtonPressed {
        [self.video play:YKQualityMedium];
    }

Or you can do something like below:

Play **YouTube** video and fetch its thumbnail.

    NSString *videoLink = @""http://www.youtube.com/watch?v=1hZ98an9wjo";"
    YKYouTubeVideo *youTubeVideo = [[YKYouTubeVideo alloc] initWithContent:[NSURL URLWithString:videoLink]];

    //Fetch thumbnail
    [youTubeVideo parseWithCompletion:^(NSError *error) {
        [youTubeVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
            //Set thumbImage to UIImageView here
        }];
    }];

    //Then play (make sure that you have called parseWithCompletion before calling this method)
     [youTubeVideo play:YKQualityHigh];


Exactly the same for **Vimeo** videos.

    NSString *videoLink = @"http://vimeo.com/42893621";
    YKVimeoVideo *vimeoVideo = [[YKVimeoVideo alloc] initWithContent:[NSURL URLWithString:videoLink]];

    [vimeoVideo parseWithCompletion:^(NSError *error) {
        [vimeoVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
            //Set thumbImage to UIImageView here
        }];
    }];

    //Then play (make sure that you have called parseWithCompletion before calling this method)
     [vimeoVideo play:YKQualityHigh];

 Finaly playing and fetching thumbnails from an iOS supported native video format such as **.MP4, .MOV, .MPV, .3GP**

    NSString *videoLink = @"http://download.wavetlan.com/SVV/Media/HTTP/BlackBerry.mov";
    YKDirectVideo *directVideo = [[YKDirectVideo alloc] initWithContent:[NSURL URLWithString:videoLink]];

    [directVideo thumbImage:YKQualityLow completion:^(UIImage *thumbImage, NSError *error) {
        //Set thumbImage to UIImageView here
    }];

    //Then play
     [directVideo play:YKQualityHigh];

### How To Setup

If using `CocoaPods` then add this to your pods file `pod 'YKMediaPlayerKit'` and update pods

Or, simply drag and drop `YKMediaPlayerKit` folder to your project.

###  License

The MIT License (MIT)

Copyright (c) 2014 Yas Kuraishi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

### Credits

**HCYoutubeParser** by Simon Andersson's - [https://github.com/hellozimi/HCYoutubeParser](https://github.com/hellozimi/HCYoutubeParser)
