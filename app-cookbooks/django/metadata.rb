maintainer        "Simeon F. Willbanks"
maintainer_email  "sfw@simeonfosterwillbanks.com"
license           "Apache 2.0"
description       "Installs DJango"
version           "0.0.1"

recipe "django", "Installs django via easy_install"

%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ apache2 python}.each do |cb|
  depends cb
end
