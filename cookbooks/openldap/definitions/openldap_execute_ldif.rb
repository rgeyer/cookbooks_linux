define :openldap_execute_ldif, :source => nil, :type => nil, :executable => "ldapmodify" do

  type_to_delete = params[:type]
  dest_file = "/tmp/#{params[:source]}"

  case params[:type]
    when :template
      template dest_file do
        source params[:source]
        variables params
        backup nil
      end
    when :remote_file
      remote_file dest_file do
        source params[:source]
        backup nil
      end
    when :file
      dest_file = params[:source]
      file dest_file do
        action :nothing
      end
  end

  Chef::Log.info("Running the following LDIF file...")
  Chef::Log.info(::File.read(dest_file))
  execute params[:executable] do
    command "#{params[:executable]} -Q -Y EXTERNAL -H ldapi:/// -f #{dest_file}"
    notifies :delete, resources(type_to_delete => dest_file), :immediately
  end
end