
execute "django-admin startproject" do
  user "vagrant"
  group "vagrant"
  cwd node[:django][:path]
  command "/usr/local/bin/django-admin.py startproject #{node[:django][:project]}"
  action :run
end