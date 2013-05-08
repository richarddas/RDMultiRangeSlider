Pod::Spec.new do |s|
  s.name         = 'RDMultiRangeSlider'
  s.version      = '0.1'
  s.authors      = { 'Richard Das' => 'richard@richarddas.com' }
  s.license 	 = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = 'https://bitbucket.org/digitalannexe/rdmultirangeslider'
  s.summary      = 'A custom slider UIControl with 2 handles.'
  s.source       = { :git => 'https://digitalannexe@bitbucket.org/digitalannexe/rdmultirangeslider.git', :tag => "#{s.version}" }
  s.source_files = "RDMultiRangeSlider/Classes/*", "RDMultiRangeSlider/Resources/*"
  s.platform     = :ios
  s.frameworks   = 'UIKit', 'QuartzCore'
  s.requires_arc = true
end