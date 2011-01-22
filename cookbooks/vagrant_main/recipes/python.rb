#
# Bootstrapping a modern Python ecosystem
#
# Recipe written by Eric Holscher
# https://github.com/ericholscher/chef-django-example/

node[:ubuntu_python_packages].each do |pkg|
    package pkg do
        :upgrade
    end
end

# System-wide packages installed by pip.
# Careful here: most Python stuff should be in a virtualenv.

node[:pip_python_packages].each_pair do |pkg, version|
    execute "install-#{pkg}" do
        command "pip install #{pkg}==#{version}"
        not_if "[ `pip freeze | grep #{pkg} | cut -d'=' -f3` = '#{version}' ]"
    end
end
