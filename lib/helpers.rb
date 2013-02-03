module Helpers
  def error_message(msg)
    JSON.generate(error: msg)
  end

  def authorize
    auth = Rack::Auth::Basic::Request.new(request.env)
    return unless auth.provided? && auth.basic? && auth.credentials

    name, password = auth.credentials

    author = Author.find_by(name: name)
    return if author.nil?

    service = AuthorService.new(author)

    if service.valid_password?(password)
      @author = author
      @author_key = Digest.hash(password)
    end
  end

  def current_author
    @author
  end

  def current_author_key
    @author_key
  end

  def json(*args)
    JSON.generate(*args)
  end
end