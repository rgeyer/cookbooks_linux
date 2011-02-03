rjg_utils_schedule_recipe "rjg_utils::aio_ebs_volume_snapshot" do
  frequency "daily"
  action "delete"
end