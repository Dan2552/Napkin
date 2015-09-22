#
# Be sure to run `pod lib lint Napkin.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Napkin"
  s.version          = "0.2.0"
  s.summary          = "A short description of Napkin."
  s.description      = <<-DESC
                       An optional longer description of Napkin

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/Dan2552/Napkin"
  s.license          = 'MIT'
  s.author           = { "Daniel Green" => "dan2552@gmail.com" }
  s.source           = { :git => "https://github.com/Dan2552/Napkin.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/Dan2552'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Napkin' => ['Pod/Assets/*.png']
  }

  s.dependency 'Luncheon', '~> 0.2.0'
  s.dependency 'XLForm', '~> 3.0.0'
  s.dependency 'Placemat', '~> 0.2.0'
end
