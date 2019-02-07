#
#  Be sure to run `pod spec lint MoveKin.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "MoveKin"
  s.version      = "0.1.0"
  s.summary      = "Allow apps to communicate in order to move Kin"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  Allow apps to communicate in order to move Kin.
  To know more about kin, visit https://KinEcosystem.org/.
                   DESC

  s.homepage     = "https://KinEcosystem.org/"
  s.swift_version = "4.2"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Specify the authors of the library, with email addresses. Email addresses
  #  of the authors are extracted from the SCM log. E.g. $ git log. CocoaPods also
  #  accepts just a name if you'd rather not provide an email address.
  #
  #  Specify a social_media_url where others can refer to, for example a twitter
  #  profile URL.
  #

  s.author             = { "Natan Rolnik" => "natanrolnik@gmail.com" }
  # Or just: s.author    = "Natan Rolnik"
  # s.authors            = { "Natan Rolnik" => "natanrolnik@gmail.com" }
  # s.social_media_url   = "http://twitter.com/Natan Rolnik"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.platform     = :ios
  s.ios.deployment_target = "8.1"
  s.source       = { :git => "https://github.com/kinecosystem/move-kin-ios.git", :tag => "#{s.version}" }
  s.source_files  = "MoveKin/**/*.{swift}"

  s.dependency "StellarKit", "~> 0.3.12"

end
