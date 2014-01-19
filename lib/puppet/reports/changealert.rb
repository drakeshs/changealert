require 'puppet'
require 'yaml'

begin
  require 'mail'
rescue LoadError => e
  Puppet.info 'This report requires the mail gem to run'
end

Puppet::Reports.register_report(:changealert) do

  def process

    from_address = ''
    to_address = ''
    smtp_server = ''
    smtp_domain = ''
    smtp_username = ''
    smtp_password = ''

    if self.status == 'changed'
      subject = "Host #{self.host} Change alert"
      output = []

      output << "The Following resources have changed:\n"
      begin
        self.resource_statuses.each do |theresource,resource_status|
          if resource_status.change_count > 0
            output << "Resource: #{resource_status.title}"
            output << "Type: #{resource_status.resource_type}"
             begin resource_status.events.each do |event|
                  output << "Property: #{event.property}"
                  output << "Value: #{event.desired_value}"
                  output << "Status: #{event.status}"
                  output << "Time: #{event.time}"
                end
              end
          end
        end
      end

      body = output.join("\n")

      Mail.defaults do
        delivery_method :smtp, {
            :address => smtp_server,
            :port => 25,
            :domain => smtp_domain,
            :user_name => smtp_username,
            :password => smtp_password,
            :authentication => 'login',
            :enable_starttls_auto => false
        }

      end

      Mail.deliver do
        to to_address
        from from_address
        subject subject
        body body
      end

    end
  end
end