Pod::Spec.new do |s|
  s.name = 'CacheIsKing'
  s.version = '0.0.4'
  s.license = 'MIT'
  s.summary = 'A simple cache that can hold anything, including Swift items'
  s.homepage = 'https://github.com/nuudles/CacheIsKing'
  s.authors = { 'Christopher Luu' => 'nuudles@gmail.com' }
  s.source = { :git => 'https://github.com/nuudles/CacheIsKing.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Source/*.swift'

  s.requires_arc = true
end
