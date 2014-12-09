require 'assert/factory'

module Factory
  extend Assert::Factory

  def self.template_root
    TEMPLATE_ROOT.to_s
  end

  def self.template_file(name)
    TEMPLATE_ROOT.join(name).to_s
  end

  def self.template_erb_rendered(view_handler, locals)
    "<h1>name: #{view_handler.name}</h1>\n"\
    "<h2>local1: #{locals['local1']}</h2>\n"
  end

  def self.partial_erb_rendered(locals)
    "<h2>local1: #{locals['local1']}</h2>\n"
  end
end
