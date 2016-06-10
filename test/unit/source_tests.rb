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

    should have_readers :root, :ext, :eruby_class, :cache, :context_class
    should have_imeths :render, :compile, :template

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "know its extension for looking up source files" do
      assert_nil subject.ext

      source = @source_class.new(@root, :ext => 'erb')
      assert_equal '.erb', source.ext
    end

    should "default its eruby class" do
      assert_equal Deas::Erubis::Source::DEFAULT_ERUBY, subject.eruby_class
    end

    should "optionally take a custom eruby class" do
      eruby = 'some-eruby-class'
      source = @source_class.new(@root, :eruby => eruby)
      assert_equal eruby, source.eruby_class
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
      assert_responds_to :source_partial, context
      assert_responds_to :source_capture_partial, context
    end

    should "mixin custom template helpers to its context class" do
      source = @source_class.new(@root, :helpers => SomeCustomHelpers)
      assert_includes SomeCustomHelpers, source.context_class

      source = @source_class.new(@root, :helpers => [SomeCustomHelpers])
      assert_includes SomeCustomHelpers, source.context_class

      context = source.context_class.new('deas-source', {})
      assert_responds_to :a_custom_method, context
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

    should "set any default source given to its context class as an ivar on init" do
      default_source = 'a-default-source'
      context = subject.context_class.new(default_source, {})

      assert_equal default_source, context.instance_variable_get('@default_source')
    end

    should "build template objects for template files" do
      filename = 'basic'
      template = subject.template(filename, Factory.string)

      assert_equal filename,                          template.filename
      assert_equal subject.eruby_class,               template.eruby_class
      assert_equal Deas::Erubis::Source::BUFVAR_NAME, template.eruby_bufvar
    end

  end

  class RenderTests < InitTests
    desc "`render` method"
    setup do
      @template_name = ['basic', 'basic_alt'].sample
      @file_locals = {
        'name'   => Factory.string,
        'local1' => Factory.integer
      }
    end

    should "render a template for the given template name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@template_name, @file_locals)
    end

    should "pass its default source to its context class" do
      default_source = 'a-deas-source'
      source = @source_class.new(@root, :default_source => default_source)
      context_class = nil
      Assert.stub(source.context_class, :new) do |s, l|
        context_class = ContextClassSpy.new(s, l)
      end
      source.render(@template_name, @file_locals)

      assert_equal default_source, context_class.default_source
    end

    should "only render templates with the matching ext if one is specified" do
      source = @source_class.new(@root, :ext => 'erb')
      file_path = Factory.template_file('basic.html.erb')
      exp = Factory.basic_erb_rendered(@file_locals)
      ['basic', 'basic.html', 'basic.html.erb'].each do |name|
        assert_equal exp, source.render(name, @file_locals)
      end

      source = @source_class.new(@root, :ext => 'erubis')
      file_path = Factory.template_file('basic_alt.erubis')
      exp = Factory.basic_erb_rendered(@file_locals)
      ['basic', 'basic_alt', 'basic_alt.erubis'].each do |name|
        assert_equal exp, source.render(name, @file_locals)
      end

      source = @source_class.new(@root, :ext => 'erb')
      ['basic_alt', 'basic_alt.erubis'].each do |name|
        assert_raises(ArgumentError){ source.render(name, @file_locals) }
      end

      source = @source_class.new(@root, :ext => 'html')
      ['basic', 'basic.html', 'basic.html.erb'].each do |name|
        assert_raises(ArgumentError){ source.render(name, @file_locals) }
      end
    end

  end

  class RenderCacheTests < RenderTests
    desc "when caching is enabled"
    setup do
      @source = @source_class.new(@root, :cache => true)
    end

    should "cache templates by their template name" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, @source.render(@template_name, @file_locals)

      assert_equal [@template_name], @source.cache.keys
      assert_kind_of Template, @source.cache[@template_name]
    end

  end

  class RenderNoCacheTests < RenderTests
    desc "when caching is disabled"
    setup do
      @source = @source_class.new(@root, :cache => false)
    end

    should "not cache templates" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, @source.render(@template_name, @file_locals)

      assert_equal [], @source.cache.keys
    end

  end

  class RenderContentTests < RenderTests
    desc "when yielding to a given content block"
    setup do
      @template_name = "yield"
      @content = Proc.new{ "<span>some content</span>" }
    end

    should "render the template for the given template name and return its data" do
      exp = Factory.yield_erb_rendered(@file_locals, &@content)
      assert_equal exp, subject.render(@template_name, @file_locals, &@content)
    end

  end

  class CompileTests < InitTests
    desc "`compile` method"

    should "evaluate raw template output and return it" do
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

    should "take a template name and return nothing on index" do
      assert_nil subject[Factory.path]
    end

    should "take a template name and value and do nothing on index write" do
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
    attr_reader :default_source
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

  module SomeCustomHelpers
    def a_custom_method; end
  end

end
