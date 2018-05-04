module RedmineHtmlSearch
  class HtmlSearchLogger < Logger
    def self.write(level, message)
      if Setting.plugin_redmine_html_search['enable_log'] == 'true'
        logger ||= new("#{Rails.root}/log/html_search.log")
        logger.send(level, message)
      end
    end
  end
end
