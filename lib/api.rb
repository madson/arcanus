class Api < Sinatra::Base
  include Helpers

  before do
    content_type :json
    cache_control :private, :must_revalidate, max_age: 0
  end

  def self.auth(*)
    condition do
      authorize || halt(401, error_message("wrong username or password"))
    end
  end

  get "/verify.json", auth: true do
    json name: current_author.name
  end

  get "/entries.json", auth: true do
    json entries: current_author.entries.map { |e| [e.id.to_s, e.name] }
  end

  post "/authors.json" do
    author = Author.new(params)
    service = AuthorService.new(author)

    if service.save
      return json message: "created successfully"
    end

    status 400
    json errors: author.errors
  end

  post "/entries.json", auth: true do
    entry = Entry.new(params)
    entry.author   = current_author
    entry.password = current_author_key

    service = EntryService.new(entry)

    if service.save
      return json message: "created successfully"
    end

    status 400
    json errors: entry.errors
  end

  get "/entries/:id.json", auth: true do
    entry = current_author.entries.find(params[:id])

    unless entry.nil?
      service = EntryService.new(entry)
      content = service.decrypt(current_author_key)
      return json id: entry.id.to_s, name: entry.name, content: content
    end

    status 404
    return json error: "entry not found"
  end

  delete "/entries/:id.json", auth: true do
    entry = current_author.entries.find(params[:id])

    if !entry.nil? && entry.delete
      return json message: "entry destroyed"
    end

    status 404
    return json error: "entry not found"
  end
end