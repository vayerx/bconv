spec = Gem::Specification.new do |s|
    s.name = 'bconv'
    s.version = "0.0.7"
    s.summary = 'ImageMagick frontend for fast jpeg compression.'
    s.description = 'Yet another ImageMagick hardcore gui-frontend with multi-threading. Only Russian language is supported.'
    s.author = 'Vasiliy Yeremeyev'
    s.email = 'vayerx@gmail.com'
    s.homepage = 'http://github.com/vayerx/bconv'
    s.license = 'GPL-3'
    s.has_rdoc = false

    s.required_ruby_version = '~> 1.9.2'
    s.add_dependency( 'parseconfig', '>= 1.0.4' )
    s.requirements << 'libglade2, v2.6 or higher'

    s.executables << 'bconv'
    s.files = [
        'lib/bconv.rb',
        'data/bconv.glade'
    ]
end
