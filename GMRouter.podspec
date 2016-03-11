#
# Be sure to run `pod lib lint GMRouter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "GMRouter"
  s.version          = "0.1.0"
  s.summary          = "A not boring url parser"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    Not boring about query in url
                       DESC

  s.homepage         = "https://github.com/geminiwen/GMRouter"
  s.license          = 'MIT'
  s.author           = { "Gemini Wen" => "coffeesherk@gmail.com" }
  s.source           = { :git => "https://github.com/geminiwen/GMRouter.git", :tag => s.version.to_s }
  s.social_media_url = 'http://weibo.com/coffeesherk'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'GMRouter/*'
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
