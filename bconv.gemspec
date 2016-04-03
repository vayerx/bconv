spec = Gem::Specification.new do |s|
    s.name = 'bconv'
    s.version = "0.0.8"
    s.summary = 'ImageMagick frontend for fast jpeg compression.'
    s.description = 'Yet another ImageMagick hardcore gui-frontend with multi-threading. Only Russian language is supported.'
    s.author = 'Vasiliy Yeremeyev'
    s.email = 'vayerx@gmail.com'
    s.homepage = 'http://github.com/vayerx/bconv'
    s.license = 'GPL-3.0'
    s.has_rdoc = false

    s.required_ruby_version = '~> 2.1'
    s.requirements << 'imagemagick'
    s.add_runtime_dependency 'parseconfig', '~> 1.0', '>= 1.0.4'
    s.add_runtime_dependency 'gtk3', '~> 3.0', '>= 3.0.7'

    s.executables << 'bconv'
    s.files = [
        'lib/bconv.rb',
        'data/bconv.glade'
    ]
end
