require 'redmine_html_search/search_helper_patch'

Rails.configuration.to_prepare do
  # plugin does its actions only if ckeditor plugin is present
  if Redmine::Plugin.registered_plugins[:redmine_ckeditor].present?
    unless SearchHelper.included_modules.include? RedmineHtmlSearch::SearchHelperPatch
      SearchHelper.prepend(RedmineHtmlSearch::SearchHelperPatch)
    end
  end
end

Redmine::Plugin.register :redmine_html_search do
  name 'Redmine Html Search plugin'
  author 'Roberto Piccini'
  description 'enable HTML code on Search page'
  version '2.0.0'
  url 'https://github.com/piccio/redmine_html_search'
  author_url 'https://github.com/piccio'
end
