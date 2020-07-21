require 'oj'
require_relative 'adapters/FileSystem.rb'

class Rehash

  def initialize(adapter = :file_system, filepath)
    @adapter = self.send(adapter, filepath)
  end

  def defaults(hash)

    json = Oj.dump(hash)
    @adapter.write(json)

  end

  def get(item)

  end

  private

  def file_system(filepath)
    FileSystem.new(filepath)
  end

end
