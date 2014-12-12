require 'pathname'
require 'erubis'

module Deas; end
module Deas::Erubis

  class Source

    EXT = ".erb"
    DEFAULT_ERUBY = ::Erubis::Eruby

    attr_reader :root, :eruby_class, :context_class

    def initialize(root, *args)
      @root = Pathname.new(root.to_s)
      locals, @eruby_class = [
        args.last.kind_of?(::Hash) ? args.pop : {},
        args.last || DEFAULT_ERUBY
      ]
      @context_class = Class.new do
        # TODO: mixin context helpers?
        locals.each{ |key, value| define_method(key){ value } }
      end
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

  end

  class DefaultSource < Source

    def initialize
      super('/')
    end

  end

end
