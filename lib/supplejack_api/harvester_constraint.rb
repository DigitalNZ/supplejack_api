module SupplejackApi
  class HarvesterConstraint
      
    def initialize
      begin
       @ips = ENV['HARVESTER_IPS'].gsub(/\s+/, "").split(',')
      rescue
        # Allow supplejack:install generator to work without application.yml file
        @ips = ['127.0.0.1']
      end
    end
    
    def matches?(request)
      forwarded_ips(request).each {|ip| return false unless @ips.include?(ip) }
      @ips.include?(request.remote_ip)
    end
    
    def forwarded_ips(request)
      ip_addresses = request.env['HTTP_X_FORWARDED_FOR']
      ip_addresses ? ip_addresses.strip.split(/[,\s]+/) : []
    end
  end
end
