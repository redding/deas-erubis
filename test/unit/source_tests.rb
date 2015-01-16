require 'assert'
require 'deas-erubis/source'

require 'erubis'

class Deas::Erubis::Source

  class UnitTests < Assert::Context
    desc "Deas::Erubis::Source"
    setup do
      @source_class = Deas::Erubis::Source
    end
    subject{ @source_class }

    should "know its extension" do
      assert_equal '.erb',   subject::EXT
    end

    should "know the bufvar name to use" do
      assert_equal '@_erb_buf', subject::BUFVAR_NAME
    end

    should "know its default eruby class" do
      assert_equal ::Erubis::Eruby, subject::DEFAULT_ERUBY
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @root = Factory.template_root
      @source = @source_class.new(@root, {})
    end
    subject{ @source }

    should have_readers :root, :eruby_class, :cache, :context_class
    should have_imeths :render, :compile, :eruby

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "default its eruby class" do
      assert_equal Deas::Erubis::Source::DEFAULT_ERUBY, subject.eruby_class
    end

    should "optionally take a custom eruby class" do
      eruby = 'some-eruby-class'
      source = @source_class.new(@root, :eruby => eruby)
      assert_equal eruby, source.eruby_class
    end

    should "build eruby instances for a given template file" do
      assert_kind_of subject.eruby_class, subject.eruby('basic', Factory.string)
    end

    should "build its eruby instances with the correct bufvar name" do
      eruby = subject.eruby('basic', Factory.string)

      exp = Deas::Erubis::Source::BUFVAR_NAME
      assert_equal exp, eruby.instance_variable_get('@bufvar')
    end

    should "not cache templates by default" do
      assert_kind_of NullCache, subject.cache
    end

    should "cache templates if the :cache opt is `true`" do
      source = @source_class.new(@root, :cache => true)
      assert_kind_of Hash, source.cache
    end

    should "know its context class" do
      assert_instance_of ::Class, subject.context_class
    end

    should "mixin template helpers to its context class" do
      assert_includes Deas::Erubis::TemplateHelpers, subject.context_class

      context = subject.context_class.new('deas-source', {})
      assert_responds_to :partial, context
      assert_responds_to :capture_partial, context
    end

    should "optionally take and apply default locals to its context class" do
      local_name, local_val = [Factory.string, Factory.string]
      source = @source_class.new(@root, {
        :locals => { local_name => local_val }
      })
      context = source.context_class.new('deas-source', {})

      assert_responds_to local_name, context
      assert_equal local_val, context.send(local_name)
    end

    should "apply custom locals to its context class instances on init" do
      local_name, local_val = [Factory.string, Factory.string]
      context = subject.context_class.new('deas-source', local_name => local_val)

      assert_responds_to local_name, context
      assert_equal local_val, context.send(local_name)
    end

    should "set any deas source given to its context class as an ivar on init" do
      deas_source = 'a-deas-source'
      context = subject.context_class.new(deas_source, {})

      assert_equal deas_source, context.instance_variable_get('@deas_source')
    end

  end

  class RenderTests < InitTests
    desc "`render` method"
    setup do
      @file_name   = "basic"
      @file_locals = {
        'name'   => Factory.string,
        'local1' => Factory.integer
      }
    end

    should "render a template for the given file name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "pass its deas source to its context class" do
      deas_source = 'a-deas-source'
      source = @source_class.new(@root, :deas_source => deas_source)
      context_class = nil
      Assert.stub(source.context_class, :new) do |s, l|
        context_class = ContextClassSpy.new(s, l)
      end
      source.render(@file_name, @file_locals)

      assert_equal deas_source, context_class.deas_source
    end

  end

  class RenderCacheTests < RenderTests
    desc "when caching is enabled"
    setup do
      @source = @source_class.new(@root, :cache => true)
    end

    should "cache template eruby instances by their file name" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, @source.render(@file_name, @file_locals)

      assert_equal [@file_name], @source.cache.keys
      assert_kind_of @source.eruby_class, @source.cache[@file_name]
    end

  end

  class RenderNoCacheTests < RenderTests
    desc "when caching is disabled"
    setup do
      @source = @source_class.new(@root, :cache => false)
    end

    should "not cache template eruby instances" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, @source.render(@file_name, @file_locals)

      assert_equal [], @source.cache.keys
    end

  end

  class RenderContentTests < RenderTests
    desc "when yielding to a given content block"
    setup do
      @file_name = "yield"
      @content = Proc.new{ "<span>some content</span>" }
    end

    should "render the template for the given file name and return its data" do
      exp = Factory.yield_erb_rendered(@file_locals, &@content)
      assert_equal exp, subject.render(@file_name, @file_locals, &@content)
    end

  end

  class CompileTests < InitTests
    desc "`compile` method"

    should "compile raw content file name and return its data" do
      raw = "<p><%= 1 + 1 %></p>"
      exp = "<p>2</p>"
      assert_equal exp, subject.compile('compile', raw)
    end

  end

  class NullCacheTests < UnitTests
    desc "NullCache"
    setup do
      @cache = NullCache.new
    end
    subject{ @cache }

    should have_imeths :[], :[]=, :keys

    should "take a file name and return nothing on index" do
      assert_nil subject[Factory.path]
    end

    should "take a file name and value and do nothing on index write" do
      assert_nothing_raised do
        subject[Factory.path] = Factory.string
      end
    end

    should "always have empty keys" do
      assert_equal [], subject.keys
    end

  end

  class DefaultSourceTests < Assert::Context
    desc "Deas::Erubis::DefaultSource"
    setup do
      @source = Deas::Erubis::DefaultSource.new
    end
    subject{ @source }

    should "be a Source" do
      assert_kind_of Deas::Erubis::Source, subject
    end

    should "use `/` as its root" do
      assert_equal '/', subject.root.to_s
    end

  end

  class ContextClassSpy
    attr_reader :deas_source
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
