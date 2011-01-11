rjg_utils_schedule_recipe "gitosis::s3_backup" do
  frequency "daily"
  action "delete"
end