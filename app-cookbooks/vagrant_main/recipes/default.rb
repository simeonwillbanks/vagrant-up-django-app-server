require_recipe "sqlite"
require_recipe "python"
require_recipe node[:version_control]
require_recipe "apache2"
require_recipe "apache2::mod_wsgi"
require_recipe "django"
require_recipe "app"