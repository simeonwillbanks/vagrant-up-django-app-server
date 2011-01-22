name "base" 
description "Base role applied to all nodes." 
run_list( 
  "recipe[build-essential]" 
)