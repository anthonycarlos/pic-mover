# pic-mover.rb
$LOAD_PATH << File.dirname(__FILE__)
require 'logger'
require 'settings'
require 'remote'
require 'fileutils'

class Server

  def initialize
    @conf = Settings.new
    log_path = File.join(@conf['local_root'], 'log', @conf['local_log_file'])
    @log = Logger.new(log_path)
    @log.level = Logger.const_get(@conf['local_log_level'])
  end

  def local_pics
    path = @conf['local_root']
    pics = Dir.glob("#{path}/*.jpg")
    short_pics = pics.map{|pic| File.basename(pic) }
  end

  def remote_pics
    pics = Remote.ls(
      @conf['hostname'],
      @conf['username'],
      @conf['password'],
      File.join(@conf['remote_root'], @conf['remote_glob']))
    short_pics = pics.map{|pic| File.basename(pic) }
  end

  def pics_to_move?
    @my_local_pics.size > 0
  end

  def run
    @log.info "Running..."
    n = 0
    loop do
      n += 1
      @log.debug "Starting loop #{n}."
      @my_local_pics = local_pics
      if pics_to_move?
        @log.info "Found pics to move: #{@my_local_pics}"
        @my_remote_pics = remote_pics
        @log.info "remote_pics: #{@my_remote_pics}"
        @my_local_pics.each do |pic|
          unless @my_remote_pics.include?(pic)
            Remote.scp(
              @conf['hostname'],
              @conf['username'],
              @conf['password'],
              File.join(@conf['local_root'], pic),
              File.join(@conf['remote_root'], pic))
            @log.info "Copied local #{pic} to remote."
          else
            @log.info "Found local #{pic} already at remote."
            FileUtils.rm File.join(@conf['local_root'], pic)
            @log.info "Deleted local #{pic}."
          end
        end
      end
      sleep(@conf['scan_interval'])
    end
  end
end

server = Server.new
server.run
