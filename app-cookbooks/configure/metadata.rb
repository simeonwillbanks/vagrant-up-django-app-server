maintainer        "Simeon F. Willbanks"
maintainer_email  "sfw@simeonfosterwillbanks.com"
license           "Apache 2.0"
description       "Creates Django project and app than configures the app"
version           "0.0.1"

recipe "app", "Creates Django project and app than configures the app"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ apache2 python}.each do |cb|
  depends cb
end
