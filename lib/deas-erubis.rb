require 'deas/template_engine'
require 'erubis'

require "deas-erubis/version"
require "deas-erubis/source"

module Deas::Erubis

  class TemplateEngine < Deas::TemplateEngine

    DEFAULT_HANDLER_LOCAL = 'view'.freeze
    DEFAULT_LOGGER_LOCAL  = 'logger'.freeze

    def erb_source
      @erb_source ||= Source.new(self.source_path, {
        :eruby          => self.opts['eruby'],
        :cache          => self.opts['cache'],
        :default_locals => { self.erb_logger_local => self.logger }
      })
    end

    def erb_handler_local
      @erb_handler_local ||= (self.opts['handler_local'] || DEFAULT_HANDLER_LOCAL)
    end

    def erb_logger_local
      @erb_logger_local ||= (self.opts['logger_local'] || DEFAULT_LOGGER_LOCAL)
    end

    # render the template with any handler layouts; include the handler as a local
    def render(template_name, view_handler, locals)
      # TODO: look at view handler layouts and render in them??
      self.erb_source.render(template_name, render_locals(view_handler, locals))
    end

    # render the template against the given locals
    def partial(template_name, locals)
      self.erb_source.render(template_name, locals)
    end

    def capture_partial(template_name, locals, &content)
      # TODO: render template with given locals yielding to given content
      raise NotImplementedError
    end

    private

    def render_locals(view_handler, locals)
      { self.erb_handler_local => view_handler }.merge(locals)
    end

  end

end
