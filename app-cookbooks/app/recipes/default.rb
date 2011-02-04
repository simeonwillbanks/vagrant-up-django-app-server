
execute "django-admin startproject" do
  user "vagrant"
  group "vagrant"
  cwd node[:django][:path]
  command "/usr/local/bin/django-admin.py startproject #{node[:django][:project]}"
  action :run
end

template "edit settings.py" do
  path "#{node[:django][:path]}/#{node[:django][:project]}/settings.py"
  source "settings.py.erb"
  owner "vagrant"
  group "vagrant"
  mode "755"
  
  seed = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(# * = $ ^ . , ! ? @ & :)
  secret_key = ""
  50.times do
    secret_key << seed[rand(seed.size-1)]
  end
  
  variables(
    :name => node[:django][:settings][:admin][:name],
    :email => node[:django][:settings][:admin][:email],
    :engine => node[:django][:settings][:database][:engine],
    :database => "#{node[:django][:path]}/#{node[:django][:project]}/sqlite3.db",
    :secret_key => secret_key
  )
end

execute "syncdb" do
  user "vagrant"
  group "vagrant"
  cwd "#{node[:django][:path]}/#{node[:django][:project]}"
  command "python manage.py syncdb"
  action :run
end

execute "create app" do
  user "vagrant"
  group "vagrant"
  cwd "#{node[:django][:path]}/#{node[:django][:project]}"
  command "python manage.py startapp #{node[:django][:app]}"
  action :run
end
