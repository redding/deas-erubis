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
      assert_equal '.erb',       subject::EXT
      assert_equal '.erb.cache', subject::CACHE_EXT
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
    should have_imeths :render

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "default its cache root and eruby class" do
      assert_equal @root, subject.cache_root.to_s
      assert_equal Deas::Erubis::Source::DEFAULT_ERUBY, subject.eruby_class
    end

    should "optionally take a custom cache root" do
      cache_root = Factory.path
      source = @source_class.new(@root, :cache_root => cache_root)
      assert_equal cache_root, source.cache_root
    end

    should "optionally take a custom eruby class" do
      eruby = 'some-eruby-class'
      source = @source_class.new(@root, :eruby => eruby)
      assert_equal eruby, source.eruby_class
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

  class RenderTests < InitTests
    desc "`render` method"
    setup do
      @file_name = "basic"
      @file_locals = {
        'name'   => Factory.string,
        'local1' => Factory.integer
      }
      @file_path = Factory.template_file("#{@file_name}#{Deas::Erubis::Source::EXT}")
    end

    should "render a template for the given file name and return its data" do
      exp = Factory.basic_erb_rendered(@file_locals)
      assert_equal exp, subject.render(@file_name, @file_locals)
    end

    should "cache templates in the source cache root" do
      cache_file_name = "#{@file_name}#{Deas::Erubis::Source::CACHE_EXT}"

      cache_file = subject.cache_root.join(cache_file_name)
      cache_file.delete if cache_file.exist?
      assert_not_file_exists cache_file
      subject.render(@file_name, @file_locals)
      assert_file_exists cache_file

      source = @source_class.new(@root, :cache_root => TEMPLATE_CACHE_ROOT)
      cache_file = source.cache_root.join(cache_file_name)
      cache_file.delete if cache_file.exist?
      assert_not_file_exists cache_file
      source.render(@file_name, @file_locals)
      assert_file_exists cache_file
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
