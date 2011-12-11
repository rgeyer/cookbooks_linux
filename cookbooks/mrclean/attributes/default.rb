case node[:platform]
  when "ubuntu", "debian"
    default[:mrclean][:package_list] = ["python2.6", "python-httplib2"]
  when "centos", "fedora", "redhat"
    default[:mrclean][:package_list] = ["python26", "python26-httplib2"]
end