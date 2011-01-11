tmpdir = "/tmp/dir_pair"

def rsync_to_dir()
  source = new_resource.source
  dest = new_resource.dest

  source = "#{source}/" unless source.end_with? "/"
  dest = "#{dest}/" unless dest.end_with? "/"

  directory "#{tmpdir}/diff" do
    recursive true
    action :create
  end

  bash "rsync different files to a third directory" do
    code <<-EOF
rsync -avrq --compare-dest=#{dest} #{source} #{tmpdir}/diff/
EOF
  end
end

action :tar do
  tmpdir = "/tmp/dir_pair"

  source = new_resource.source
  dest = new_resource.dest
  gzipfile = new_resource.result_file

  source = "#{source}/" unless source.end_with? "/"
  dest = "#{dest}/" unless dest.end_with? "/"

  directory "#{tmpdir}/diff" do
    recursive true
    action :create
  end

  bash "rsync different files to a third directory" do
    code <<-EOF
rsync -avrq --compare-dest=#{dest} #{source} #{tmpdir}/diff/
cd #{tmpdir}/diff
tar -cf tarfile.tar *
gzip tarfile.tar
mv tarfile.tar.gz #{gzipfile}
EOF
  end

  directory tmpdir do
    recursive true
    action :delete
  end
end

action :cp_to_dir do

end