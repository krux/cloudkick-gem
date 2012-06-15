require 'tempfile'
#require 'json'
require 'pp'

module Cloudkick::Command
  class List < Base
    def index
    
      ### defaults to 'nil', which is safe to pass
      query   = extract_option('--query')
      full  = extract_option('--full')
      #json  = extract_option('--json')
      
      if args.size > 0
        raise CommandFailed, 'usage: cloudkick list [--query <query>] [--full]'
      end

      if full 
        fmt = "%-30s %-15s %-12s %-16s\n" 
        printf( fmt, "# Name", "IP", "Type", "Zone" )
      else 
        fmt = "%-30s %-15s\n"        
        printf( fmt, "# Name", "IP" )      
      end

      list = client.get('nodes', query).nodes

      ### sort the output by name
      list.sort { |x,y| x.name <=> y.name }.each do |node|
        if full
          ### details MAY not be filled :(
          details = node.as_hash['details']
          printf( fmt, 
            node.name, node.ipaddress,
            (details['instancetype'] ? details['instancetype'][0] : 'unknown'),
            (details['availability'] ? details['availability'][0] : 'unknown')
          )
        else
          printf( fmt, node.name, node.ipaddress )
        end              

      end 
    end
  end
end
