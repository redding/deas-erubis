require 'pathname'
require 'erubis'
require 'deas-erubis/template_helpers'

module Deas; end
module Deas::Erubis

  class Source

    EXT           = '.erb'.freeze
    BUFVAR_NAME   = '@_erb_buf'.freeze
    DEFAULT_ERUBY = ::Erubis::Eruby

    attr_reader :root, :eruby_class, :cache, :context_class

    def initialize(root, opts)
      @root          = Pathname.new(root.to_s)
      @eruby_class   = opts[:eruby] || DEFAULT_ERUBY
      @cache         = opts[:cache] ? Hash.new : NullCache.new
      @context_class = build_context_class(opts)

      @deas_source = opts[:deas_source]
    end

    def render(file_name, locals, &content)
      load(file_name).evaluate(@context_class.new(@deas_source, locals), &content)
    end

    def compile(filename, content)
      eruby(filename, content).evaluate(@context_class.new(@deas_source, {}))
    end

    def eruby(filename, content)
      @eruby_class.new(content, {
        :bufvar   => BUFVAR_NAME,
        :filename => filename
      })
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " @root=#{@root.inspect}"\
      " @eruby=#{@eruby_class.inspect}>"
    end

    private

    def load(file_name)
      @cache[file_name] ||= begin
        filename = source_file_path(file_name).to_s
        content = File.send(File.respond_to?(:binread) ? :binread : :read, filename)
        eruby(filename, content)
      end
    end

    def source_file_path(file_name)
      self.root.join("#{file_name}#{EXT}").to_s
    end

    def build_context_class(opts)
      Class.new do
        include ::Deas::Erubis::TemplateHelpers
        (opts[:helpers] || []).each{ |helper| include helper }
        (opts[:locals]  || {}).each{ |k, v| define_method(k){ v } }

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

    class NullCache
      def [](file_name);         end
      def []=(file_name, value); end
      def keys; [];              end
    end

  end

  class DefaultSource < Source

    def initialize
      super('/', {})
    end

  end

end
