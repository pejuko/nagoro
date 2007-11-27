module Nagoro
  class Template
    class << self
      def [](*listeners)
        instance = new
        instance.listeners = listeners.flatten.map{|l|
          Listener.const_get(l).new
        }
        instance.file = '<nagoro eval>'
        instance
      end
    end

    attr_accessor :listeners, :compiled, :binding, :file

    def render_file(filename)
      raise "File does not exist" unless File.file?(filename)
      file = File.new(filename)
      render(file)
    ensure
      file.close unless file.closed?
    end

    def render(string_or_io, options = {})
      @options = options
      @file = options[:file] || '<nagoro>'
      @compiled = compile(pipeline(string_or_io))
      self
    end

    def pipeline(string_or_io)
      listeners.inject(string_or_io) do |template, listener|
        listener.process(template)
        html = listener.to_html
        listener.reset
        html
      end
    end

    def compile(template)
      template = template.read if template.respond_to?(:read)
      copy = template.gsub('`', '\\\\`')
      compile!(copy)
    end

    def compile!(template)
      template.gsub!(/<\?r\s+(.*?)\s+\?>/m, "`;\\1; _out_ << %Q`")
      "_out_ = []; _out_ << %Q`#{template}`; _out_.join"
    end

    def result(binding = @binding, file = @file)
      raise(RuntimeError, "Compile or filter first") unless @compiled
      raise(ArgumentError, "Binding required for eval") unless binding
      eval(@compiled, binding, file).strip
    end
  end
end
