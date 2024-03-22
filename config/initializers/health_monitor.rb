class CustomProvider < HealthMonitor::Providers::Base
  def check!
    failed_databases = []

    ActiveRecord::Base.connection_handler.connection_pool_list(:all).each do |cp|
      cp.connection.exec_query('select 1')
    rescue Exception
      failed_databases << cp.db_config.name
    end

    raise "unable to connect to: #{failed_databases.uniq.join(',')}" unless failed_databases.empty?
  end
end

HealthMonitor.configure do |config|
  config.add_custom_provider(CustomProvider)
end
