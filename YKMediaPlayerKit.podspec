Pod::Spec.new do |s|
  s.name         = "YKMediaPlayerKit"
  s.version      = "0.0.4"
  s.summary      = "Painlessly and natively play YouTube, Vimeo, and .MP4, .MOV, .MPV, .3GP videos and fetch thumbnails on your iOS devices"
  s.homepage     = "https://github.com/YasKuraishi/YKMediaPlayerKit"
  s.license      = 'MIT'
  s.author       = { "Yas Kuraishi" => "kuraishi@gmail.com" }
  s.social_media_url = "http://twitter.com/@YasKuraishi"
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '6.0'
  s.source       = { :git => "https://github.com/yageek/YKMediaPlayerKit.git", :tag => "0.0.4" }
  s.source_files = 'YKTwitterHelper', 'YKMediaPlayerKit/**/*.{h,m}'
  s.frameworks   = 'UIKit', 'CoreGraphics'
  s.requires_arc = true

  s.dependency 'HCYoutubeParser', '~> 0.0'
end
