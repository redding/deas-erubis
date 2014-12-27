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

    should "know its extensions" do
      assert_equal '.erb',   subject::EXT
      assert_equal '.cache', subject::CACHE_EXT
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

    should have_readers :root, :cache_root, :eruby_class, :context_class
    should have_imeths :eruby, :render

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
      assert_kind_of subject.eruby_class, subject.eruby('basic')
    end

    should "build its eruby instances with the correct bufvar name" do
      exp = Deas::Erubis::Source::BUFVAR_NAME
      assert_equal exp, subject.eruby('basic').instance_variable_get('@bufvar')
    end

    should "default its cache root" do
      assert_equal Pathname.new('').to_s, subject.cache_root.to_s
    end

    should "use the root as its cache root if :cache opt is `true`" do
      source = @source_class.new(@root, :cache => true)
      assert_equal @root.to_s, source.cache_root.to_s
    end

    should "optionally use a custom cache root" do
      source = @source_class.new(@root, :cache => TEMPLATE_CACHE_ROOT)
      assert_equal TEMPLATE_CACHE_ROOT.to_s, source.cache_root.to_s
    end

    should "create the cache root if it doesn't exist already" do
      FileUtils.rm_rf(TEMPLATE_CACHE_ROOT) if TEMPLATE_CACHE_ROOT.exist?
      source = @source_class.new(@root, :cache => TEMPLATE_CACHE_ROOT)
      assert_file_exists TEMPLATE_CACHE_ROOT.to_s
    end

    should "know its context class" do
      assert_instance_of ::Class, subject.context_class
    end

    should "optionally take and apply default locals to its context class" do
      local_name, local_val = [Factory.string, Factory.string]
      source = @source_class.new(@root, {
        :default_locals => { local_name => local_val }
      })
      context = source.context_class.new({})

      assert_responds_to local_name, context
      assert_equal local_val, context.send(local_name)
    end

    should "apply locals to its context class instances on init" do
      local_name, local_val = [Factory.string, Factory.string]
      context = subject.context_class.new(local_name => local_val)

      assert_responds_to local_name, context
      assert_equal local_val, context.send(local_name)
    end

  end

  class RenderSetupTests < InitTests
    setup do
      @file_locals = {
        'name'   => Factory.string,
        'local1' => Factory.integer
      }
    end
    teardown do
      Dir.glob(TEMPLATE_ROOT.join("*#{@source_class::CACHE_EXT}").to_s).each do |f|
        FileUtils.rm_f(f)
      end
      Dir.glob(TEMPLATE_CACHE_ROOT.join("*#{@source_class::CACHE_EXT}").to_s).each do |f|
        FileUtils.rm_f(f)
      end
    end
  end

  class RenderTests < RenderSetupTests
    desc "`render` method"
    setup do
      @file_name = "basic"
    end

  end

  class RenderEnabledCacheTests < RenderTests
    desc "when caching is enabled"
    setup do
      @source = @source_class.new(@root, :cache => true)
    end

    should "render a template for the given file name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "cache templates in the root (cache root) alongside the source" do
      f = "#{@file_name}#{@source_class::EXT}#{@source_class::CACHE_EXT}"
      cache_file = subject.root.join(f)

      assert_not_file_exists cache_file
      subject.render(@file_name, @file_locals)
      assert_file_exists cache_file
    end

  end

  class RenderCustomCacheTests < RenderTests
    desc "when caching is enabled on a custom cache root"
    setup do
      @source = @source_class.new(@root, :cache => TEMPLATE_CACHE_ROOT)
    end

    should "render a template for the given file name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "cache templates in the cache root" do
      f = "#{@file_name}#{@source_class::EXT}#{@source_class::CACHE_EXT}"
      cache_file = TEMPLATE_CACHE_ROOT.join(f)

      assert_not_file_exists cache_file
      subject.render(@file_name, @file_locals)
      assert_file_exists cache_file
    end

  end

  class RenderNoCacheTests < RenderTests
    desc "when caching is disabled"
    setup do
      @source = @source_class.new(@root, :cache => TEMPLATE_CACHE_ROOT)
    end

    should "render a template for the given file name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "not cache templates" do
      f = "#{@file_name}#{@source_class::EXT}#{@source_class::CACHE_EXT}"
      cache_file = subject.root.join(f)

      assert_not_file_exists cache_file
      subject.render(@file_name, @file_locals)
      assert_not_file_exists cache_file
    end

  end

  class DefaultSource < UnitTests
    desc "DefaultSource"
    setup do
      @source = Deas::Erubis::DefaultSource.new
    end
    subject{ @source }

    should "be a Source" do
      assert_kind_of @source_class, subject
    end

    should "use `/` as its root" do
      assert_equal '/', subject.root.to_s
    end

  end

end
