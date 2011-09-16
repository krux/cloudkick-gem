require 'tempfile'

module Cloudkick::Command
  class Parallel < Base
    
    ### find a binary in the path
    def can_run( commands, fallback=nil )
      
      commands.each do |try|        
        if command?(try) 
          return try
        end
      end

      if fallback      
        return fallback
      end
      
      raise CommandFailed, "cloudkick: no such command #{commands}"
    end  

    ### get a host list in a file
    def host_list( query=nil, username=nil, prefer_ip=nil )
      file = Tempfile.new('ck')

      client.get('nodes', query).each do |node|
        target = prefer_ip ? node.ipaddress : node.name      
        file.puts sprintf "%s %s", target, username
      end

      file.flush
      
      return file
    end
    
  end

  class Pssh < Parallel
    def index
      unless args.size > 0
        raise CommandFailed, 'usage: cloudkick pssh --query <query> ' \
        '[--username <username>] [--timeout INT] [--prefer-ip] <command>'
      end

      query     = extract_option('--query')
      username  = extract_option('--username')      
      timeout   = extract_option('--timeout' ) || -1
      prefer_ip = extract_option('--prefer-ip')
      command   = args.last.strip rescue nil

      ### what binary to use
      fallback  = 'pssh'
      bins      = [ 'parallel-ssh', fallback ]
      bin       = can_run( bins, fallback )
      
      ### get a host list file
      file      = host_list( query, username, prefer_ip )

      ### the shell out command
      to_run    = "#{bin} --inline --timeout=#{timeout} --hosts=#{file.path} #{command}"

      begin
        system( to_run )
      rescue
        raise CommandFailed, 'cloudkick: could not run: #{to_run}'
      end

      ### cleans up the tempfile
      file.close  

    end
  end

  class Pscp < Parallel
    def index
      unless args.size > 0
        raise CommandFailed, 'usage: cloudkick pscp --query <query> ' \
        '[--username <username>] [--timeout INT] [--prefer-ip] <local> <remote>'
      end

      query     = extract_option('--query')
      username  = extract_option('--username')      
      timeout   = extract_option('--timeout' ) || -1
      prefer_ip = extract_option('--prefer-ip')      
      remote    = args[-1].strip rescue nil
      local     = args[-2].strip rescue nil

      ### what binary to use
      fallback  = 'pscp'
      bins      = [ 'parallel-scp', fallback ]
      bin       = can_run( bins, fallback )
      
      ### get a host list file
      file      = host_list( query, username, prefer_ip )

      ### the shell out command
      to_run    = "#{bin} --timeout=#{timeout} --hosts=#{file.path} #{local} #{remote}"

      begin
        system( to_run )
      rescue
        raise CommandFailed, 'cloudkick: could not run: #{to_run}'
      end

      ### cleans up the tempfile
      file.close  

    end
  end
end
