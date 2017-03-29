class Certtest < ActiveRecord::Base
  belongs_to :project
  
    def self.certnames
        hsh = {}
        allCerts = Certtest.all
        allCerts.each do |cert|
            hsh[cert.name] = cert
        end
        
        return hsh
    end
  

  
end
