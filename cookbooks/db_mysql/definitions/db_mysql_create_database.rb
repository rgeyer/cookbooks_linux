define :db_mysql_create_database, :db_name => nil do

  bash "Create a MySQL database" do
    not_if "echo \"show databases\" | mysql | grep -q \"^#{params[:db_name]}$\""
    code "mysqladmin -u root create #{params[:db_name]}"
  end
end