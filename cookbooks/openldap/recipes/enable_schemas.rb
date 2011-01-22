openldap_schema "Enable schema list" do
  schemas node[:openldap][:schemas]
  action :enable
end