define :rjg_utils_schedule_recipe, :json_file => nil, :frequency => 'daily', :action => 'schedule' do
  node_attribute = case params[:frequency]
    when 'hourly' then node[:rjg_utils][:hourly_recipes]
    when 'daily' then node[:rjg_utils][:daily_recipes]
    when 'weekly' then node[:rjg_utils][:weekly_recipes]
    when 'monthly' then node[:rjg_utils][:monthly_recipes]
  end
  daily_recipes = node_attribute
  if(params[:action] == 'schedule')
    daily_recipes += [{ "recipe" => "#{params[:name]}", "json_file" => "#{params[:json_file]}" }]
  else
    daily_recipes -= [{ "recipe" => "#{params[:name]}", "json_file" => "#{params[:json_file]}" }]
  end
  case params[:frequency]
    when 'hourly' then node_attribute = node[:rjg_utils][:hourly_recipes] = daily_recipes.uniq
    when 'daily' then node_attribute = node[:rjg_utils][:daily_recipes] = daily_recipes.uniq
    when 'weekly' then node_attribute = node[:rjg_utils][:weekly_recipes] = daily_recipes.uniq
    when 'monthly' then node_attribute = node[:rjg_utils][:monthly_recipes] = daily_recipes.uniq
  end

  cron_job "recipes_#{params[:frequency]}" do
    template "cron_rs_run_recipes.erb"
    frequency params[:frequency]
    params "recipes" => node_attribute
    action :schedule
  end
end