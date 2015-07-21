Pod::Spec.new do |s|
  s.name             = "FCWebViewProgress"
  s.version          = "0.1.0"
  s.summary          = "A short description of FCWebViewProgress."
  s.description      = <<-DESC
                       a webview progress for iOS
                       DESC
  s.homepage         = "https://github.com/fencholCN/FCWebViewProgress"
  s.license          = 'MIT'
  s.author           = { "fencholCN" => "fenchol@sina.cn" }
  s.source           = { :git => "https://github.com/fencholCN/FCWebViewProgress.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'FCWebViewProgress' => ['Pod/Assets/*.png']
  }

 s.frameworks = 'UIKit'

end
