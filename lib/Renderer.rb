class Renderer

  def initialize(path, output_path)

    @path = path
    @output_path = output_path

  end

  ##
  # Place files in output path.
  ##
  def render()

    filenames = [
      "bundle.js",
      "index.html",
      "package-lock.json",
      "package.json",
      "README.md",
      "server.js"
    ]

    filenames.each do |filename|
      file = File.read(File.join(@path, "web", filename))
      File.open(File.join(@output_path, filename), 'w+') do |f|
        f.write file
      end
    end

    file = File.read(File.join(@path, "web", "gitignore.txt"))
    File.open(File.join(@output_path, ".gitignore"), 'w+') do |f|
      f.write file
    end

  end


end
