Pod::Spec.new do |s|
  s.name                        = "VirgilSDKPythia"
  s.version                     = "0.12.0-dev.1"
  s.swift_version               = "5.0"
  s.license                     = { :type => "BSD", :file => "LICENSE" }
  s.summary                     = "Virgil Pythia SDK for Apple devices and languages."
  s.homepage                    = "https://github.com/VirgilSecurity/virgil-pythia-x/"
  s.authors                     = { "Virgil Security" => "https://virgilsecurity.com/" }
  s.source                      = { :git => "https://github.com/VirgilSecurity/virgil-pythia-x.git", :tag => s.version }
  s.ios.deployment_target       = "11.0"
  s.osx.deployment_target       = "10.13"
  s.tvos.deployment_target      = "11.0"
  s.watchos.deployment_target   = "4.0"
  s.source_files                = 'Source/**/*.{swift}'
  s.dependency "VirgilSDK", "= 9.0.0"
  s.dependency "VirgilCryptoPythia", "= 0.17.0"
end
