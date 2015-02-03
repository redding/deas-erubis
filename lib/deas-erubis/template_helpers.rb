require 'deas-erubis/source'

module Deas; end
module Deas::Erubis

  module TemplateHelpers

    def self.included(receiver)
      receiver.class_eval{ include Methods }
    end

    module Methods

      def partial(name, locals = nil)
        source_partial(@default_source, name, locals)
      end

      def capture_partial(name, locals = nil, &c)
        source_capture_partial(@default_source, name, locals, &c)
      end

      def source_partial(source, name, locals = nil)
        source.partial(name, locals || {})
      end

      def source_capture_partial(source, name, locals = nil, &c)
        _erb_buffer source.partial(name, locals || {}, &Proc.new{ _erb_capture(&c) })
      end

      private

      def _erb_capture(&content)
        begin
          # copy original buffer state
          orig_buf_value = _erb_bufvar
          instance_variable_set(_erb_bufvar_name, "\n")

          # evaluate the given content
          result = instance_eval(&content)
          new_buf_value = _erb_bufvar

          # return result if nothing buffered; otherwise return what was buffered
          new_buf_value == "\n" ? "\n#{result}" : new_buf_value
        ensure
          # reset buffer to original state
          instance_variable_set(_erb_bufvar_name, orig_buf_value)
        end
      end

      def _erb_buffer(content)
        _erb_bufvar << content
      end

      def _erb_bufvar
        instance_variable_get(_erb_bufvar_name)
      end

      def _erb_bufvar_name
        Deas::Erubis::Source::BUFVAR_NAME
      end

    end

  end

end
