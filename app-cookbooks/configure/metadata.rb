maintainer        "Simeon F. Willbanks"
maintainer_email  "sfw@simeonfosterwillbanks.com"
license           "Apache 2.0"
description       "Create and configure Django project than app"
version           "0.0.1"

recipe "configure", "Create and configure Django project than app"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ apache2 python}.each do |cb|
  depends cb
end
