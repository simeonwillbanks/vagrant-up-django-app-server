
execute "django-admin startproject #{node[:django][:project]}" do
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
  mode "0755"
  seed = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(# * = $ ^ . , ! ? @ & :)
  secret_key = ""
  rand_ceil = seed.size - 1
  50.times do
    secret_key << seed[rand(rand_ceil)]
  end
  variables(
    :name => node[:django][:settings][:admin][:name],
    :email => node[:django][:settings][:admin][:email],
    :project => node[:django][:project],
    :engine => node[:django][:settings][:database][:engine],
    :database => "#{node[:django][:path]}/sqlite3.db",
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

execute "startapp #{node[:django][:app]}" do
  user "vagrant"
  group "vagrant"
  cwd "#{node[:django][:path]}/#{node[:django][:project]}"
  command "python manage.py startapp #{node[:django][:app]}"
  action :run
end

# Edit settings file
execute "add #{node[:django][:app]} to INSTALLED_APPS" do
  user "vagrant"
  group "vagrant"
  cwd "#{node[:django][:path]}/#{node[:django][:project]}"
  command "sed -i 's/INSTALLED_APPS = (/INSTALLED_APPS = ( \"#{node[:django][:project]}.#{node[:django][:app]}\",/g' settings.py"
  action :run
end

execute "syncdb" do
  user "vagrant"
  group "vagrant"
  cwd "#{node[:django][:path]}/#{node[:django][:project]}"
  command "python manage.py syncdb"
  action :run
end

["logs", "public_html", "public_html/media", "#{node[:django][:project]}/apache"].each do |dir|
  directory "#{node[:django][:path]}/#{dir}" do
    owner "vagrant"
    group "vagrant"
    mode "0755"
    action :create
  end  
end

template "add django.wsgi" do
  path "#{node[:django][:path]}/#{node[:django][:project]}/apache/django.wsgi"
  source "django.wsgi.erb"
  owner "vagrant"
  group "vagrant"
  mode "0755"
  variables(
    :path => node[:django][:path],
    :settings_module => "#{node[:django][:project]}.settings"
  )
end

template "add #{node[:django][:project]}.conf" do
  path "#{node[:apache][:dir]}/sites-available/#{node[:django][:project]}.conf"
  source "virtual_host.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :server_name => node[:django][:project],
    :django_path => node[:django][:path],
    :wsgi_script_alias => "#{node[:django][:path]}/#{node[:django][:project]}/apache/django.wsgi",
    :directory => "#{node[:django][:path]}/#{node[:django][:project]}"
  )
  if ::File.exists?("#{node[:apache][:dir]}/sites-enabled/#{node[:django][:project]}.conf")
    notifies :reload, resources(:service => "apache2"), :delayed
  end
end

execute "a2ensite #{node[:django][:project]}.conf" do
  command "/usr/sbin/a2ensite #{node[:django][:project]}.conf"
  notifies :restart, resources(:service => "apache2")
  not_if do 
    ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/#{node[:django][:project]}.conf") or
      ::File.symlink?("#{node[:apache][:dir]}/sites-enabled/000-#{node[:django][:project]}.conf")
  end
  only_if do ::File.exists?("#{node[:apache][:dir]}/sites-available/#{node[:django][:project]}.conf") end
end

apache_site "000-default" do
  enable false
end

service "apache2" do 
  action :restart
end