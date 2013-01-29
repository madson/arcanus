require "spec_helper"

describe App do
  def app ; App ; end

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

  describe "POST /new.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      post "/new.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 400 will be returned when invalid params" do
      authorize author.name, author.password
      post "/new.json", name: "foobar", content: ""

      expect(last_response.status).to be == 400
      expect(last_response.body).to include_json(errors: { content: ["can't be blank"] })
    end

    specify "HTTP 200 will be returned when valid params" do
      authorize author.name, author.password
      post "/new.json", name: "foobar", content: "baz"

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
      post "/new.json", name: "first", content: "<first>"
      post "/new.json", name: "second", content: "<second>"
      post "/new.json", name: "third", content: "<third>"
      get "/entries.json"

      expect(last_response.body).to include_json(entries: ["first", "second", "third"])
    end

    specify "entries created by others will not be returned" do
      authorize other_author.name, other_author.password
      post "/new.json", name: "other", content: "<other>"

      authorize author.name, author.password
      get "/entries.json"

      expect(last_response.body).to_not include_json(entries: ["other"])
    end
  end

  describe "GET /entries/:name.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      get "/entries/foobar.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 404 will be returned when name is not found" do
      authorize author.name, author.password
      get "/entries/missing.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "HTTP 200 will be returned when entry found" do
      authorize author.name, author.password
      post "/new.json", name: "myprecious", content: "thering"
      get "/entries/myprecious.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(name: "myprecious", content: "thering")
    end

    specify "entry created by other will not be returned" do
      authorize other_author.name, other_author.password
      post "/new.json", name: "other", content: "<other>"

      authorize author.name, author.password
      get "/entries/other.json"

      expect(last_response.status).to be == 404
    end
  end

  describe "DELETE /entries/:name.json" do
    specify "HTTP 401 will be returned when not authenticated" do
      delete "/entries/foobar.json"

      expect(last_response.status).to be == 401
      expect(last_response.body).to include_json(error: "wrong username or password")
    end

    specify "HTTP 404 will be returned when name is not found" do
      authorize author.name, author.password
      delete "/entries/missing.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "HTTP 200 will be returned when entry found" do
      authorize author.name, author.password
      post "/new.json", name: "myprecious", content: "thering"
      delete "/entries/myprecious.json"

      expect(last_response.status).to be == 200
      expect(last_response.body).to include_json(message: "entry destroyed")
    end

    it "will destroy entry so it can not be get again" do
      authorize author.name, author.password
      post "/new.json", name: "myprecious", content: "thering"
      delete "/entries/myprecious.json"
      get "/entries/myprecious.json"

      expect(last_response.status).to be == 404
      expect(last_response.body).to include_json(error: "entry not found")
    end

    specify "entry created by other will not be destroyed" do
      authorize other_author.name, other_author.password
      post "/new.json", name: "other", content: "<other>"

      authorize author.name, author.password
      delete "/entries/other.json"

      expect(last_response.status).to be == 404
    end
  end
end