Pod::Spec.new do |s|
  s.name                        = "VirgilSDKPythia"
  s.version                     = "0.5.2"
  s.license                     = { :type => "BSD", :file => "LICENSE" }
  s.summary                     = "Virgil Pythia SDK for Apple devices and languages."
  s.homepage                    = "https://github.com/VirgilSecurity/virgil-pythia-x/"
  s.authors                     = { "Virgil Security" => "https://virgilsecurity.com/" }
  s.source                      = { :git => "https://github.com/VirgilSecurity/virgil-pythia-x.git", :tag => s.version }
  s.ios.deployment_target       = "9.0"
  s.osx.deployment_target       = "10.11"
  s.tvos.deployment_target      = "9.0"
  s.watchos.deployment_target   = "2.0"
  s.source_files                = 'Source/**/*.{swift}'
  s.dependency "VirgilSDK", "~> 5.7"
  s.dependency "VirgilCryptoPythia", "~> 0.8.0"
  s.dependency "VirgilCrypto", "~> 5.0.0-alpha5"
end
