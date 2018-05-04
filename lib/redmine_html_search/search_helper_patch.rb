module RedmineHtmlSearch
  module SearchHelperPatch

    def highlight_tokens(text, tokens)
      if RedmineCkeditor.enabled?
        RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "TEXT=#{text}")
        RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "TOKENS=#{tokens.inspect}")

        doc = Nokogiri::HTML.fragment(text)
        RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "DOC FRAGMENT=#{doc}")

        if doc.text == text
          # likely it is the title
          super
        else
          # path = ''
          # tokens.each_with_index do |token, index|
          #   path << ".//text()[contains(., '#{token}')]"
          #   path << ' | ' unless index == tokens.length - 1
          # end
          path = ".//text()[regex(., '#{tokens.join('|')}')]"
          RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "XPATH PATH=#{path}")

          # nodes = doc.xpath(path)
          nodes = doc.xpath(path, Class.new {
            def regex(node_set, regex)
              node_set.find_all { |node| node.content =~ /#{regex}/i }
            end
          }.new)
          RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "XPATH RESULT'S TEXT NODES=#{nodes}")

          if nodes.empty?
            '[...]'
          else
            strictly_ancestors = nodes.map(&:ancestors).flatten.uniq + nodes
            RedmineHtmlSearch::HtmlSearchLogger.write(:debug,
                                                      "STRICTLY ANCESTORS=#{strictly_ancestors}")

            doc.traverse do |node|
              if strictly_ancestors.include?(node)
                RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "KEEP NODE=#{node}")

                if node.text?
                  highlighted = "[...] #{super(node.content, tokens)} [...]"
                  node.replace(highlighted) unless highlighted.blank?
                  RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "NODE HIGHLIGHTED=#{node}")
                end
              else
                node.unlink
                RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "REMOVE NODE=#{node}")
              end
            end

            RedmineHtmlSearch::HtmlSearchLogger.write(:debug, "RESULT=#{doc.to_html.html_safe}")
            doc.to_html.html_safe
          end
        end
      else
        super
      end
    end

  end
end
