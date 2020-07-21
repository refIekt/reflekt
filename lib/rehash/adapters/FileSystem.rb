require_relative 'Adapter.rb'

class FileSystem < Adapter

  def read()

    p Oj.load_file(@source)

  end

  def write(json)

    p json

  end

end
