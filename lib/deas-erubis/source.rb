require 'pathname'
require 'erubis'

module Deas; end
module Deas::Erubis

  class Source

    EXT       = '.erb'.freeze
    CACHE_EXT = "#{EXT}.cache".freeze
    DEFAULT_ERUBY = ::Erubis::Eruby

    attr_reader :root, :cache_root, :eruby_class, :context_class

    def initialize(root, opts)
      @root          = Pathname.new(root.to_s)
      @cache_root    = opts[:cache_root] || @root
      @eruby_class   = opts[:eruby] || DEFAULT_ERUBY
      @context_class = build_context_class(opts)
    end

    def render(file_name, locals)
      eruby(file_name).evaluate(@context_class.new(locals))
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " @root=#{@root.inspect}"\
      " @eruby=#{@eruby_class.inspect}>"
    end

    private

    def eruby(file_name)
      @eruby_class.load_file(source_file_path(file_name), {
        :cachename => cache_file_path(file_name)
      })
    end

    def source_file_path(file_name)
      self.root.join("#{file_name}#{EXT}").to_s
    end

    def cache_file_path(file_name)
      self.cache_root.join("#{file_name}#{CACHE_EXT}").tap do |path|
        path.dirname.mkpath if !path.dirname.exist?
      end.to_s
    end

    def build_context_class(opts)
      Class.new do
        # TODO: mixin context helpers? `opts[:template_helpers]`
        (opts[:default_locals] || {}).each{ |k, v| define_method(k){ v } }

        def initialize(locals)
          metaclass = class << self; self; end
          metaclass.class_eval do
            locals.each do |key, value|
              define_method(key){ value }
            end
          end
        end
      end
    end

  end

  class DefaultSource < Source

    def initialize
      super('/', {})
    end

  end

end
