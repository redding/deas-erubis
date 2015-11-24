require 'assert'
require 'deas-erubis/template_helpers'

require 'much-plugin'

module Deas::Erubis::TemplateHelpers

  class UnitTests < Assert::Context
    desc "Deas::Erubis::TemplateHelpers"
    subject{ Deas::Erubis::TemplateHelpers }

    should "use much-plugin" do
      assert_includes MuchPlugin, subject
    end

  end

end
