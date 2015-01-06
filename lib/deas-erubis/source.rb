require 'pathname'
require 'erubis'
require 'deas-erubis/template_helpers'

module Deas; end
module Deas::Erubis

  class Source

    EXT           = '.erb'.freeze
    CACHE_EXT     = '.cache'.freeze
    BUFVAR_NAME   = '@_erb_buf'.freeze
    DEFAULT_ERUBY = ::Erubis::Eruby

    attr_reader :root, :cache_root, :eruby_class, :context_class

    def initialize(root, opts)
      @root        = Pathname.new(root.to_s)
      @eruby_class = opts[:eruby] || DEFAULT_ERUBY

      should_cache = !!opts[:cache]
      @cache_root  = opts[:cache] == true ? @root : Pathname.new(opts[:cache].to_s)
      @cache_root.mkpath if should_cache && !@cache_root.exist?

      if should_cache
        # use `load_file` to lookup and cache templates (faster renders)
        if @cache_root == @root
          # use the `load_file` default and don't bother with looking up, setting,
          # and making sure the cache file path exists - by default `load_file`
          # caches alongside the source with the `CACHE_EXT` appended.
          add_meta_eruby_method do |file_name|
            @eruby_class.load_file(source_file_path(file_name), {
              :bufvar => BUFVAR_NAME
            })
          end
        else
          # lookup and ensure the custom cache location exists (more expensive)
          add_meta_eruby_method do |file_name|
            @eruby_class.load_file(source_file_path(file_name), {
              :bufvar    => BUFVAR_NAME,
              :cachename => cache_file_path(file_name)
            })
          end
        end
      else
        # don't cache template files (slower renders, but no cache files created)
        add_meta_eruby_method do |file_name|
          filename = source_file_path(file_name).to_s
          template = File.send(File.respond_to?(:binread) ? :binread : :read, filename)
          @eruby_class.new(template, {
            :bufvar   => BUFVAR_NAME,
            :filename => filename
          })
        end
      end

      @deas_source   = opts[:deas_source]
      @context_class = build_context_class(opts)
    end

    def eruby(file_name)
      # should be overridden by a metaclass equivalent on init
      # the implementation changes whether you are caching templates or not
      # and the goal here is to not add a bunch of conditional overhead as this
      # will be called on every render
      raise NotImplementedError
    end

    def render(file_name, locals, &content)
      eruby(file_name).evaluate(@context_class.new(@deas_source, locals), &content)
    end

    def compile(file_name, content)
      @eruby_class.new(content, {
        :bufvar   => BUFVAR_NAME,
        :filename => file_name
      }).evaluate(@context_class.new(@deas_source, {}))
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " @root=#{@root.inspect}"\
      " @eruby=#{@eruby_class.inspect}>"
    end

    private

    def source_file_path(file_name)
      self.root.join("#{file_name}#{EXT}").to_s
    end

    def cache_file_path(file_name)
      self.cache_root.join("#{file_name}#{EXT}#{CACHE_EXT}").tap do |path|
        path.dirname.mkpath if !path.dirname.exist?
      end.to_s
    end

    def add_meta_eruby_method(&method)
      metaclass = class << self; self; end
      metaclass.class_eval do
        define_method(:eruby, &method)
      end
    end

    def build_context_class(opts)
      Class.new do
        include ::Deas::Erubis::TemplateHelpers
        # TODO: mixin context helpers? `opts[:template_helpers]`
        (opts[:default_locals] || {}).each{ |k, v| define_method(k){ v } }

        def initialize(deas_source, locals)
          @deas_source = deas_source

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
