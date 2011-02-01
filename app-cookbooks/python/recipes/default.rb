package "python" do
  action :upgrade
end

%w{ 
  dev setuptools sqlite
}.each do |pkg|
  package "python-#{pkg}" do
    action :install
  end
end
