Pod::Spec.new do |s|
  s.name     = 'MKImpulse'
  s.version  = '1.0.5'
  s.license  = 'MIT'
  s.summary  = 'MKImpulse是一个代替NSTimer的高精度脉冲器, 基于GCD编写.'
  s.homepage = 'https://github.com/SYFH/MKImpulse'
  s.author   = { 'SYFH' => 'SYFH' }
  s.source   = { :git => 'https://github.com/SYFH/MKImpulse.git', :tag => s.version }
  s.platform = :ios, '7.0'
  s.source_files = 'MKImpulse/*.{h,m}'
end