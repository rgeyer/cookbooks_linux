cron_job "recipes_daily" do
  template "cron_rs_run_recipes.erb"
  frequency "daily"
  params "recipes" => node[:rjg_utils][:daily_recipes]
  action :schedule
end

#cron_job "recipes_monthly" do
#  template "cron_rs_run_recipes.erb"
#  frequency "monthly"
#  action :schedule
#end