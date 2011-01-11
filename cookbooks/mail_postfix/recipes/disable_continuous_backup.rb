rjg_utils_schedule_recipe "mail_postfix::s3_backup" do
  frequency "daily"
  action "delete"
end