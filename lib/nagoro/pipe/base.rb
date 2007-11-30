module Nagoro
  DEFAULT_PIPES = [ :Element, :Morpher, :Include, :Instruction ]

  module Pipe
    class Base
      attr_accessor :body, :stack

      JUST_CLOSE = %w[br hr]

      def initialize(options = {})
        @body = []
        @stack = []
      end

      def tag_start(tag, hash)
        case tag
        when *JUST_CLOSE
          append "<#{tag}#{hash.to_tag_params} />"
        else
          append "<#{tag}#{hash.to_tag_params}>"
        end
      end

      def tag_end(tag)
        case tag
        when *JUST_CLOSE
        else
          append "</#{tag}>"
        end
      end

      def text(string)
        append string
      end

      def instruction(name, instruction)
        instruction.strip!
        append "<?#{name} #{instruction} ?>"
      end

      def comment(comment)
        append "<!--#{comment}-->"
      end

      def doctype(name, pub_sys, long_name, uri)
        append "<!DOCTYPE #{name} #{pub_sys} #{long_name} #{uri}>"
      end

      def doctype_end
      end

      def cdata(content)
        append "<![CDATA[#{content}]]>"
      end

      def xmldecl(version, encoding, standalone)
        params = {}
        params[:encoding] = encoding if encoding
        params[:standalone] = standalone if standalone
        append "<?xml #{params.to_tag_params}?>"
      end

      def append(string)
        @body << string
      end

      def to_html
        @body.join
      end

      def entity
      end

      def reset
        @body.clear
        @stack.clear
        self
      end
    end
  end
end