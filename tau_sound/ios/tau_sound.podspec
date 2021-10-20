#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
s.name = 'tau_sound'
  s.version          = '9.0.0-alpha.11'
  s.summary          = 'Flutter plugin that relates to sound like audio and recorder.'
  s.description      = <<-DESC
Flutter plugin that relates to sound like audio and recorder.
                       DESC
  s.homepage         = 'https://github.com/canardoux/tau/tau_sound'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Larpoux' => 'larpoux@canardoux.xyz' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.dependency 'tau_native', '9.0.0-alpha.11'
  s.dependency 'mobile-ffmpeg-audio', '4.4.LTS'
  #---s.dependency 'ffmpeg-kit-ios-full', '~> 4.4.LTS'
end
