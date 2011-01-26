action :schedule do
  template "/etc/cron.#{new_resource.frequency}/#{new_resource.name}" do
    mode 0755
    backup false
    source new_resource.template
    variables(
      :params => new_resource.params
    )
  end
end

action :delete do
  file "/etc/cron.#{new_resource.frequency}/#{new_resource.name}" do
    action :delete
  end
end