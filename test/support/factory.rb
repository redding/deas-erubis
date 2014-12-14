require 'assert/factory'

module Factory
  extend Assert::Factory

  def self.template_root
    TEMPLATE_ROOT.to_s
  end

  def self.template_file(name)
    TEMPLATE_ROOT.join(name).to_s
  end

  def self.basic_erb_rendered(locals)
    "<h1>name: #{locals['name']}</h1>\n"\
    "<h2>local1: #{locals['local1']}</h2>\n"
  end

  def self.view_erb_rendered(engine, view_handler, locals)
    "<h1>name: #{view_handler.name}</h1>\n"\
    "<h2>local1: #{locals['local1']}</h2>\n"\
    "<p>id: #{view_handler.identifier}</p>\n"\
    "<p>logger: #{engine.logger.to_s}</p>\n"
  end

end
