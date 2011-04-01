directory "/root/rs_sandbox_chef/cache" do
  recursive true
end

template "/root/rs_sandbox_chef/solo.rb" do
  source "solo.rb.erb"
end