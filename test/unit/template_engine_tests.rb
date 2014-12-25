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
    should have_imeths :render, :partial, :capture_partial

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

    should "allow custom cache roots on its source" do
      engine = Deas::Erubis::TemplateEngine.new('cache' => TEMPLATE_CACHE_ROOT)
      assert_equal TEMPLATE_CACHE_ROOT.to_s, engine.erb_source.cache_root.to_s
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

    should "render templates" do
      engine = Deas::Erubis::TemplateEngine.new('source_path' => TEMPLATE_ROOT)
      view_handler = OpenStruct.new({
        :identifier => Factory.integer,
        :name => Factory.string
      })
      locals = { 'local1' => Factory.string }
      exp = Factory.view_erb_rendered(engine, view_handler, locals).to_s

      assert_equal exp, engine.render('view', view_handler, locals)
    end

    should "render partial templates" do
      engine = Deas::Erubis::TemplateEngine.new('source_path' => TEMPLATE_ROOT)
      locals = { 'local1' => Factory.string }
      exp = Factory.partial_erb_rendered(engine, locals).to_s

      assert_equal exp, engine.partial('_partial', locals)
    end

    should "not implement the engine capture partial method" do
      assert_raises NotImplementedError do
        subject.capture_partial('_partial', {})
      end
    end

  end

end
