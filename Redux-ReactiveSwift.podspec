Pod::Spec.new do |s|
  s.name             = 'Redux-ReactiveSwift'
  s.version          = '0.1.1'
  s.summary          = 'Simple Redux Store implementation over ReactiveSwift.'

  s.description      = <<-DESC
This library focuses on simple implementation of ReduxStore backed by ReactiveSwift mutable property.
Store combines power of Redux's state controlling obviousness with reactive bindings. One can act with the store like with property.
                       DESC

  s.homepage         = 'https://github.com/soxjke/Redux-ReactiveSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Petro Korienev' => 'soxjke@gmail.com' }
  s.source           = { :git => 'https://github.com/soxjke/Redux-ReactiveSwift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/soxjke'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'  
  s.watchos.deployment_target = '2.0'  
  s.tvos.deployment_target = '9.0'   
  s.source_files = 'Redux-ReactiveSwift/Classes/**/*'
  
  s.dependency 'ReactiveSwift', '2.1.0-alpha2'
end
