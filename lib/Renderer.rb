class Renderer

  def initialize(path, output_path)
    @path = path
    @output_path = output_path
  end

  ##
  # Render results.
  ##
  def render()

    # Get JSON.
    json = File.read("#{@output_path}/db.json")

    # Save HTML.
    template = File.read("#{@path}/web/template.html.erb")
    rendered = ERB.new(template).result(binding)
    File.open("#{@output_path}/index.html", 'w+') do |f|
      f.write rendered
    end

    # Add JS.
    javascript = File.read("#{@path}/web/script.js")
    File.open("#{@output_path}/script.js", 'w+') do |f|
      f.write javascript
    end

    # Add CSS.
    stylesheet = File.read("#{@path}/web/style.css")
    File.open("#{@output_path}/style.css", 'w+') do |f|
      f.write stylesheet
    end

  end


end
