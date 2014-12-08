require 'pathname'
require 'erubis'

module Deas; end
module Deas::Erubis

  class Source

    EXT = ".erb"

    attr_reader :root, :eruby_class, :context_class

    def initialize(root, locals = nil)
      @root = Pathname.new(root.to_s)
      @eruby_class = ::Erubis::Eruby # TODO: allow for custom classes
      @context_class = Class.new do
        (locals || {}).each{ |key, value| define_method(key){ value } }
        # TODO: mixin context helpers?
      end
    end

    def inspect
      "#<#{self.class}:#{'0x0%x' % (object_id << 1)} @root=#{@root.inspect}>"
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
