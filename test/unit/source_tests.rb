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
      assert_equal ".erb", subject::EXT
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @root = Factory.template_root
      @source = @source_class.new(@root)
    end
    subject{ @source }

    should have_readers :root, :eruby_class, :context_class

    should "know its root" do
      assert_equal @root, subject.root.to_s
    end

    should "know its eruby class" do
      assert_equal ::Erubis::Eruby, subject.eruby_class
    end

    should "know its context class" do
      assert_instance_of ::Class, subject.context_class
    end

    should "optionally take and apply default locals to its context class" do
      local_name, local_val = [Factory.string, Factory.string]
      source = @source_class.new(@root, local_name => local_val)
      context = source.context_class.new

      assert_responds_to local_name, context
      assert_equal local_val, context.send(local_name)
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
