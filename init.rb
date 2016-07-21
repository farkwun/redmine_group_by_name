require_dependency 'redmine_group_by_name/issues_helper_patch'

Redmine::Plugin.register :redmine_group_by_name do
  name 'Redmine Group by Name'
  description 'List view groups by name not group id'
  url 'https://github.com/farkwun/redmine_group_by_name'

  author 'farkwun'
  author_url 'https://github.com/farkwun'

  version '0.1.0'
  requires_redmine :version_or_higher => '3.3.0'
end
