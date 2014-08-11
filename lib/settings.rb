require 'yaml'

class Settings

  def initialize
    @s = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'conf', 'settings.yml'))
  end

  def [](key)
    @s[key]
  end

end
