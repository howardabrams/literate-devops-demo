Without any recipes, we need to acquire them
automatically from the specified run list.
If you have roles listed in your run list
they are NOT expanded.

    if recipes.empty? and Chef::Config[:solo]
      node.run_list.map do |item|
        item.name if item.type == :recipe
      end
    end
