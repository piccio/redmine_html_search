module RedmineHtmlSearch
  module SearchHelperPatch

    def highlight_tokens(text, tokens)
      if RedmineCkeditor.enabled?
        doc = Nokogiri::HTML.fragment(text)
        doc.children.each do |child|
          child.traverse do |node|
            if node.text?
              highlighted = super(node.content, tokens)
              node.replace(highlighted) unless highlighted.blank?
            end
          end
        end
        doc.to_s.html_safe
      else
        super
      end
    end

  end
end
