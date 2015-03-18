class CaerbannogGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def copy_migration
    migration_template "add_caerbannog_messages.rb", "db/migrate/add_caerbannog_messages.rb"
  end

  def create_message_model
    copy_file "caerbannog_message.rb", "app/models/caerbannog_message.rb"
  end

  def create_caerbannog_initializer
    copy_file "caerbannog_initializer.rb", "config/initializers/caerbannog_initializer.rb"
  end
end

