class MailTemplateException < StandardError

  def initialize(data)
    @data = data
  end

  def message
    "MailTemplateException: \n#{@data.pretty_inspect.html_safe}"
  end
end
