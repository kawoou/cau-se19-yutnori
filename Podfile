platform :ios, '10.0'

target 'Yutnori' do
  xcodeproj 'Yutnori'
  use_frameworks!

  # Binary
  pod 'SwiftLint'

  # Database
  pod 'RealmSwift'

  # Rx
  pod 'RxSwift'
  pod 'RxCocoa'

  # UI
  pod 'SnapKit'

  target 'YutnoriTests' do
    inherit! :search_paths
    
    # Test
    pod 'Quick'
    pod 'Nimble'

    # Rx
    pod 'RxBlocking'
  end
end
