module Helpers
  def error_message(msg)
    JSON.generate(error: msg)
  end

  def authorize
    auth = Rack::Auth::Basic::Request.new(request.env)
    return unless auth.provided? && auth.basic? && auth.credentials

    name, @password = auth.credentials

    @author = Author.find_by(name: name)
    return if @author.nil?

    service = AuthorService.new(@author)
    service.valid_password?(@password)
  end

  def current_author
    @author
  end

  def current_author_key
    @password
  end

  def json(*args)
    JSON.generate(*args)
  end
end