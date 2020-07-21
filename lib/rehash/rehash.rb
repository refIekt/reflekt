require_relative 'adapters/FileSystem.rb'

class Rehash

  def initialize(adapter = :file_system, file)
    @adapter = self.send(adapter)
  end

  def defaults(hash)

    json = Oj.dump(hash)
    @adapter.write(json)

  end

  def get(item)

  end

  private

  def file_system
    FileSystem.new(file)
  end

end
