require 'net/ssh'
require 'net/scp'

class Remote

  def self.ls(host, user, pw, remote_dir)
    result = Net::SSH.start(host, user, :password => pw) do |ssh|
      ssh.exec!("ls #{remote_dir}")
    end
    result.split("\n")
  end

  def self.scp(host, user, pw, local_path, remote_path)
    Net::SCP.upload!(
      host,
      user,
      local_path,
      remote_path,
      :ssh => { :password => pw })
  end

end
