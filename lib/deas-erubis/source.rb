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

      @default_source = opts[:default_source]
    end

    def render(template_name, locals, &content)
      load(template_name).evaluate(@context_class.new(@default_source, locals), &content)
    end

    def compile(template_name, content)
      template(template_name, content).evaluate(@context_class.new(@default_source, {}))
    end

    def template(filename, content)
      Template.new(@eruby_class.new(content, {
        :bufvar   => BUFVAR_NAME,
        :filename => filename
      }))
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)}"\
      " @root=#{@root.inspect}"\
      " @eruby=#{@eruby_class.inspect}>"
    end

    private

    def load(template_name)
      @cache[template_name] ||= begin
        filename = source_file_path(template_name).to_s
        content = File.send(File.respond_to?(:binread) ? :binread : :read, filename)
        template(filename, content)
      end
    end

    def source_file_path(template_name)
      Dir.glob(self.root.join("#{template_name}*#{EXT}")).first
    end

    def build_context_class(opts)
      Class.new do
        include ::Deas::Erubis::TemplateHelpers
        [*(opts[:helpers] || [])].each{ |helper| include helper }
        (opts[:locals]  || {}).each{ |k, v| define_method(k){ v } }

        def initialize(default_source, locals)
          @default_source = default_source

          metaclass = class << self; self; end
          metaclass.class_eval do
            locals.each do |key, value|
              define_method(key){ value }
            end
          end
        end
      end
    end

    class Template
      attr_reader :src, :filename, :eruby_class, :eruby_bufvar

      def initialize(erubis_eruby)
        @src          = erubis_eruby.src
        @filename     = erubis_eruby.filename
        @eruby_class  = erubis_eruby.class
        @eruby_bufvar = erubis_eruby.instance_variable_get('@bufvar')
      end

      def evaluate(context)
        context.instance_eval(@src, @filename)
      end
    end

    class NullCache
      def [](template_name);         end
      def []=(template_name, value); end
      def keys; [];                  end
    end

  end

  class DefaultSource < Source

    def initialize
      super('/', {})
    end

  end

end
