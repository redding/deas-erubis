require 'assert'
require 'deas-erubis'

require 'deas/template_engine'
require 'deas-erubis/source'

class Deas::Erubis::TemplateEngine

  class UnitTests < Assert::Context
    desc "Deas::Erubis::TemplateEngine"
    setup do
      @engine = Deas::Erubis::TemplateEngine.new({
        'source_path' => TEST_SUPPORT_PATH
      })
    end
    subject{ @engine }

    should have_imeths :erb_source, :erb_handler_local, :erb_logger_local
    should have_imeths :render, :partial, :compile

    should "be a Deas template engine" do
      assert_kind_of Deas::TemplateEngine, subject
    end

    should "memoize its erb source" do
      assert_kind_of Deas::Erubis::Source, subject.erb_source
      assert_equal subject.source_path, subject.erb_source.root
      assert_same subject.erb_source, subject.erb_source
    end

    should "allow custom eruby classes on its source" do
      custom_eruby = 'some-eruby'
      engine = Deas::Erubis::TemplateEngine.new('eruby' => custom_eruby)
      assert_equal custom_eruby, engine.erb_source.eruby_class
    end

    should "pass any given cache option to its source" do
      engine = Deas::Erubis::TemplateEngine.new('cache' => true)
      assert_kind_of Hash, engine.erb_source.cache
    end

    should "pass any given deas template source to its source" do
      default_source = 'a-default-source'
      source_opts = nil

      Assert.stub(Deas::Erubis::Source, :new){ |root, opts| source_opts = opts }
      Deas::Erubis::TemplateEngine.new('default_template_source' => default_source).erb_source

      assert_equal default_source, source_opts[:default_source]
    end

    should "pass any given helpers option to its source" do
      engine = Deas::Erubis::TemplateEngine.new('helpers' => [SomeCustomHelpers])
      assert_includes SomeCustomHelpers, engine.erb_source.context_class
    end

    should "use 'view' as the handler local name by default" do
      assert_equal 'view', subject.erb_handler_local
    end

    should "allow custom handler local names" do
      handler_local = Factory.string
      engine = Deas::Erubis::TemplateEngine.new('handler_local' => handler_local)
      assert_equal handler_local, engine.erb_handler_local
    end

    should "use 'logger' as the logger local name by default" do
      assert_equal 'logger', subject.erb_logger_local
    end

    should "allow custom logger local names" do
      logger_local = Factory.string
      engine = Deas::Erubis::TemplateEngine.new('logger_local' => logger_local)
      assert_equal logger_local, engine.erb_logger_local
    end

  end

  module SomeCustomHelpers
    def a_custom_method; end
  end

end
