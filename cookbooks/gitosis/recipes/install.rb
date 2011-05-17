# Install git, and git-daemon first
%w{git-core git-daemon-run python-setuptools}.each do |p|
  package p
end

# Install Gitosis
# Probably want to wrap all of this in a big fat "not-if" type block. We're creating the temp dir, checking code out
# into it, and deleting the temp directory every time, whether gitosis is already installed or not.
gitosis_install_dir = "/tmp/gitosisinstall"

git gitosis_install_dir do
  repository "git://eagain.net/gitosis.git"
  reference "master"
  action :checkout
end

bash "Install gitosis from git" do
  cwd "#{gitosis_install_dir}"
  not_if "which gitosis-init"
  code <<-EOF
python setup.py install
  EOF
end

directory gitosis_install_dir do
  action :delete
  recursive true
end

# Add gitosis users & groups
group node[:gitosis][:gid] do
  action :create
end

user node[:gitosis][:uid] do
  comment "Gitosis for git version control"
  gid node[:gitosis][:gid]
  home node[:gitosis][:gitosis_home]
  shell "/bin/sh"
end

# / End Install Gitosis

# Initialize Gitosis

# Setup the ssh private/public key pair for the gitosis repo/install
directory "#{node[:gitosis][:gitosis_home]}/.ssh" do
  group node[:gitosis][:gid]
  owner node[:gitosis][:uid]
  mode "0700"
  recursive true
  action :create
end

# TODO: Warn about overwriting an existing key pair?
#if [[ -e $GITOSIS_HOME/.ssh/id_rsa && -e $GITOSIS_HOME/.ssh/id_rsa.pub ]]; then
#  echo "A public/private keypair already existed for the git user, and is being overwritten..."
#fi

# Create or copy the ssh key pair for gitosis.
if (node[:gitosis][:gitosis_key])
  file "#{node[:gitosis][:gitosis_home]}/.ssh/id_rsa" do
    content node[:gitosis][:gitosis_key]
    mode "00600"
    group node[:gitosis][:gid]
    owner node[:gitosis][:uid]
    backup false
    action :create
  end

  bash "Create public key from private key" do
    code <<-EOF
ssh-keygen -N \"\" -f #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa -y > #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa.pub
echo "$(cat #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa.pub) git@localhost" > #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa.pub
chown -R #{node[:gitosis][:uid]}:#{node[:gitosis][:gid]} #{node[:gitosis][:gitosis_home]}/.ssh
EOF
    not_if File.exist?("#{node[:gitosis][:gitosis_home]}/.ssh/id_rsa.pub")
  end
else
  execute "ssh-keygen" do
    command "ssh-keygen -q -t rsa -N \"\" -f #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa"
    creates "#{node[:gitosis][:gitosis_home]}/.ssh/id_rsa"
  end
end
# / End Create or copy the ssh key pair for gitosis.

execute "chown" do
  command "chown -R #{node[:gitosis][:uid]}:#{node[:gitosis][:gid]} #{node[:gitosis][:gitosis_home]}"
end

# Run gitosis-init
bash "Run gitosis-init" do
  cwd node[:gitosis][:gitosis_home]
  code <<-EOF
sudo -H -u #{node[:gitosis][:uid]} gitosis-init < #{node[:gitosis][:gitosis_home]}/.ssh/id_rsa.pub
chmod -R 755 #{node[:gitosis][:gitosis_home]}/repositories/gitosis-admin.git/hooks/post-update
  EOF
  not_if "[ -d #{node[:gitosis][:gitosis_home]}/repositories/gitosis-admin.git ]"
end

bash "Set permissions for gitosis home dir" do
  code <<EOF
chown -R #{node[:gitosis][:uid]}:#{node[:gitosis][:gid]} #{node[:gitosis][:gitosis_home]}
chmod -R 770 #{node[:gitosis][:gitosis_home]}/gitosis
chmod -R 770 #{node[:gitosis][:gitosis_home]}/repositories
EOF
end

# Setup gitosis-daemon service
template "/etc/sv/git-daemon/run" do
  source "git-daemon-run.sh.erb"
  mode 00711
  variables(:gitosis_home => node[:gitosis][:gitosis_home])
end

# TODO: Should probably embrace runit from opscode, but I'm not ready yet
execute "sv" do
  command "sv restart git-daemon"
end