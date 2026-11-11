# Seeds don't run on deploy, so existing admin roles in production would never get the
# new permission. Grant it to every role that can already manage roles (i.e. admins).
class GrantManageProductsToAdmins < ActiveRecord::Migration[8.1]
  class MigrationRole < ActiveRecord::Base
    self.table_name = "roles"
  end

  def up
    MigrationRole.find_each do |role|
      next unless role.permissions.include?("manage_roles")
      next if role.permissions.include?("manage_products")

      role.update_columns(permissions: role.permissions + [ "manage_products" ])
    end
  end

  def down
    MigrationRole.find_each do |role|
      role.update_columns(permissions: role.permissions - [ "manage_products" ]) if role.permissions.include?("manage_products")
    end
  end
end
