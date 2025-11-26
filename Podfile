platform :ios, '12.0'

target 'IMCreate' do
  use_frameworks!
  pod 'FCUUID'
  pod 'IQKeyboardManagerSwift'
  pod 'SVProgressHUD'
  pod 'GKNavigationBarViewController'
  pod 'JJException'
  pod 'SDWebImage'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['OTHER_CFLAGS'] = '$(inherited) -Wno-implicit-function-declaration'
    end
  end
end
