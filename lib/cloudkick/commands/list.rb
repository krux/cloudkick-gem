require 'tempfile'
require 'pp'

module Cloudkick::Command
    class List < Base
        def index
        
            ### defaults to 'nil', which is safe to pass
            query   = extract_option('--query')
            full    = extract_option('--full')
            json    = extract_option('--json')
            
            if args.size > 0
                raise CommandFailed, 'usage: cloudkick list [--query <query>] \
                    [--full] [--json]'
            end

            if full 
                fmt = "%-15s %-15s %-12s %-16s\n" 
                printf( fmt, "# Name", "IP", "Type", "Zone" )
            else 
                fmt = "%-15s %-15s\n"                
                printf( fmt, "# Name", "IP" )            
            end

            client.get('nodes', query).each do |node|

                if full
                    printf( fmt, 
                        node.name, node.ipaddress,
                        node.as_hash['details']['instancetype'][0],
                        node.as_hash['details']['availability'][0]
                    )
                else
                    printf( fmt, node.name, node.ipaddress )
                end                            

            end 
        end
    end
end