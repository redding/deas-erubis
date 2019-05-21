require 'assert'
require 'deas-erubis'

require 'deas/template_source'

class Deas::Erubis::TemplateEngine

  class SystemTests < Assert::Context
    desc "Deas::Erubis::TemplateEngine"
    setup do
      @view = OpenStruct.new({
        :identifier => Factory.integer,
        :name       => Factory.string
      })
      @locals  = { 'local1' => Factory.string }
      @content = Proc.new{ "<span>some content</span>" }

      @template_source = Deas::TemplateSource.new(TEMPLATE_ROOT)
      @template_source.engine("erb", Deas::Erubis::TemplateEngine, {
        "default_template_source" => @template_source
      })

      @engine = @template_source.engines["erb"]
    end
    subject{ @engine }

    should "render templates" do
      exp = Factory.view_erb_rendered(subject, @view, @locals)
      assert_equal exp, subject.render('view', @view, @locals)
    end

    should "render templates yielding to given content blocks" do
      exp = Factory.yield_view_erb_rendered(subject, @view, @locals, &@content)
      assert_equal exp, subject.render('yield_view', @view, @locals, &@content)
    end

    should "render partial templates" do
      exp = Factory.partial_erb_rendered(subject, @locals)
      assert_equal exp, subject.partial('_partial1', @locals)
    end

    should "render partial templates yielding to given content blocks" do
      exp = Factory.yield_partial_erb_rendered(subject, @locals, &@content)
      assert_equal exp, subject.partial('_yield_partial', @locals, &@content)
    end

    should "compile raw template markup" do
      template_name = 'compile'
      file_path     = TEMPLATE_ROOT.join("#{template_name}.erb").to_s
      file_content  = File.read(file_path)

      exp = Factory.compile_erb_rendered(subject)
      assert_equal exp, subject.compile(template_name, file_content)
    end

  end

  class TemplateHelperTests < SystemTests
    desc "template helpers"
    setup do
      @source = Deas::TemplateSource.new(TEMPLATE_ROOT).tap do |s|
        s.engine 'erb', Deas::Erubis::TemplateEngine
      end
      @engine = @source.engines['erb']
    end

    should "render partials" do
      exp = Factory.partial_with_partial_erb_rendered(subject, @locals)
      assert_equal exp, subject.partial('with_partial', @locals)
    end

    should "capture render partials" do
      exp = Factory.partial_with_capture_partial_erb_rendered(subject, @locals).to_s
      assert_equal exp, subject.partial('with_capture_partial', @locals)
    end

  end

end
