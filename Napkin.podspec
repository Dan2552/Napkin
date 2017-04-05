Pod::Spec.new do |s|
  s.name             = "Napkin"
  s.version          = "0.6.0"
  s.summary          = "Resource based iOS screen builder. With ability to automatically infer input types using proprerties defined in your Luncheon models."
  s.homepage         = "https://github.com/Dan2552/Napkin"
  s.license          = 'MIT'
  s.author           = { "Daniel Inkpen" => "dan2552@gmail.com" }
  s.source           = { :git => "https://github.com/Dan2552/Napkin.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Dan2552'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Napkin' => ['Pod/Assets/*.png']
  }

  s.dependency 'Eureka', '~> 2.0'
  s.dependency 'Luncheon', '>= 0.6.0'
  s.dependency 'Placemat', '>= 0.6.0'
end
