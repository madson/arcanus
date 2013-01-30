require "spec_helper"

describe Api do
  def app ; Api ; end

  subject { last_response }

  let(:author) do
    author = create(:author)
    AuthorService.new(author).save
    author
  end

  let(:other_author) do
    author = create(:author)
    AuthorService.new(author).save
    author
  end

  describe "GET /verify.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      get "/verify.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 200 will be returned when authenticated" do
      authorize author.name, author.password
      get "/verify.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(name: author.name)
    end
  end

  describe "POST /authors.json" do
    specify "HTTP 400 will be returned when invalid params" do
      post "/authors.json", name: "joao", password: ""

      expect(last_response.status).to be == 400
      expect(last_response.body).to include_json(errors: { password: ["can't be blank", "is too short (minimum is 5 characters)"] })
    end

    specify "HTTP 200 will be returned when valid params" do
      post "/authors.json", name: "joao", password: "12345"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(message: "created successfully")
    end
  end

  describe "POST /entries.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      post "/entries.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 400 will be returned when invalid params" do
      authorize author.name, author.password
      post "/entries.json", name: "foobar", content: ""

      expect(last_response.status).to be == 400
      expect(last_response.body).to include_json(errors: { content: ["can't be blank"] })
    end

    specify "HTTP 200 will be returned when valid params" do
      authorize author.name, author.password
      post "/entries.json", name: "foobar", content: "baz"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(message: "created successfully")
    end
  end

  describe "GET /entries.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      get "/entries.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 200 will be returned when authenticated" do
      authorize author.name, author.password
      get "/entries.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(entries: [])
    end

    it "returns all created entries" do
      authorize author.name, author.password
      post "/entries.json", name: "first", content: "<first>"
      post "/entries.json", name: "second", content: "<second>"
      post "/entries.json", name: "third", content: "<third>"
      get "/entries.json"

      expect(last_response.body).to include_json(
        entries: [[anything, "first"], [anything, "second"], [anything, "third"]]
      )
    end

    specify "entries created by others will not be returned" do
      authorize other_author.name, other_author.password
      post "/entries.json", name: "other", content: "<other>"

      authorize author.name, author.password
      get "/entries.json"

      expect(last_response.body).to_not include_json(entries: ["other"])
    end
  end

  describe "GET /entries/:id.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      get "/entries/1234.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 404 will be returned when id is not found" do
      authorize author.name, author.password
      get "/entries/1234.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "HTTP 200 will be returned when entry found" do
      authorize author.name, author.password
      post "/entries.json", name: "myprecious", content: "thering"
      entry_id = Entry.last.id.to_s
      get "/entries/#{entry_id}.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(
        id: entry_id, name: "myprecious", content: "thering"
      )
    end

    specify "entry created by other will not be returned" do
      authorize other_author.name, other_author.password
      post "/entries.json", name: "other", content: "<other>"

      entry_id = Entry.last.id.to_s

      authorize author.name, author.password
      get "/entries/#{entry_id}.json"

      expect(last_response.status).to be == 404
    end
  end

  describe "DELETE /entries/:id.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      delete "/entries/1234.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 404 will be returned when id is not found" do
      authorize author.name, author.password
      delete "/entries/1234.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "HTTP 200 will be returned when entry found" do
      authorize author.name, author.password
      post "/entries.json", name: "myprecious", content: "thering"
      delete "/entries/#{Entry.last.id}.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(message: "entry destroyed")
    end

    it "will destroy entry so it can not be get again" do
      authorize author.name, author.password
      post "/entries.json", name: "myprecious", content: "thering"
      entry_id = Entry.last.id.to_s
      delete "/entries/#{entry_id}.json"
      get "/entries/#{entry_id}.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "entry created by other will not be destroyed" do
      authorize other_author.name, other_author.password
      post "/entries.json", name: "other", content: "<other>"

      entry_id = Entry.last.id.to_s
      authorize author.name, author.password
      delete "/entries/#{entry_id}.json"

      expect(last_response.status).to be == 404
    end
  end
end