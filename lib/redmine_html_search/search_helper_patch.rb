module RedmineHtmlSearch
  module SearchHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :highlight_tokens, :html
      end
    end

    module InstanceMethods

      def highlight_tokens_with_html(text, tokens)
        if RedmineCkeditor.enabled?
          doc = Nokogiri::HTML.fragment(text)
          doc.children.each do |child|
            child.traverse do |node|
              if node.text?
                highlighted = highlight_tokens_without_html(node.content, tokens)
                node.replace(highlighted) unless highlighted.blank?
              end
            end
          end
          doc.to_s.html_safe
        else
          highlight_tokens_without_html(text, tokens)
        end
      end
    end
  end
end
