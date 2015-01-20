require 'deas/template_engine'
require 'erubis'

require 'deas-erubis/version'
require 'deas-erubis/source'

module Deas::Erubis

  class TemplateEngine < Deas::TemplateEngine

    DEFAULT_HANDLER_LOCAL = 'view'.freeze
    DEFAULT_LOGGER_LOCAL  = 'logger'.freeze

    def erb_source
      @erb_source ||= Source.new(self.source_path, {
        :eruby       => self.opts['eruby'],
        :cache       => self.opts['cache'],
        :deas_source => self.opts['deas_template_source'],
        :helpers     => self.opts['helpers'],
        :locals      => { self.erb_logger_local => self.logger }
      })
    end

    def erb_handler_local
      @erb_handler_local ||= (self.opts['handler_local'] || DEFAULT_HANDLER_LOCAL)
    end

    def erb_logger_local
      @erb_logger_local ||= (self.opts['logger_local'] || DEFAULT_LOGGER_LOCAL)
    end

    # render the template including the handler as a local
    def render(template_name, view_handler, locals, &content)
      self.erb_source.render(template_name, render_locals(view_handler, locals), &content)
    end

    # render the template against the given locals
    def partial(template_name, locals, &content)
      self.erb_source.render(template_name, locals, &content)
    end

    def compile(template_name, compiled_content)
      self.erb_source.compile(template_name, compiled_content)
    end

    private

    def render_locals(view_handler, locals)
      { self.erb_handler_local => view_handler }.merge(locals)
    end

  end

end
