module DumbBot
  class SimpleApi
    class << self
      attr_writer :domain

      def domain
        @domain || 'http://localhost:3002/'
      end
    end

    def initialize(name:, password:)
      @domain = self.class.domain
      @auth_token = login(name, password)
    end

    def create_game(players)
      post("/games", players: players)
    end


    def perform(uuid, action, args={})
      uri = URI.parse(@domain)
      http = Net::HTTP.new(uri.hostname, uri.port)
      flatten_args = args.each_with_object({}) { |(k, v), h| h["args[#{k}"] = v }
      response = http.put("/actions/#{uuid}", URI.encode_www_form(flatten_args.merge(auth_token: @auth_token, perform: action)))
      if (200..399).cover?(response.code.to_i)
        JSON.parse(response.body)
      else
        raise "HTTP error (#{response.code}): performing #{action}"
      end
    end

    def games
      get("/games")
    end

    def games_for(type)
      get("/games/#{type}")[type.to_s] || []
    end

    def game(uuid)
      get("/games/#{uuid}")
    end

    private

    def login(name, password)
      # create user if they don't already exist
      post("/register", name: name, password: password) rescue nil
      # log the user in
      post("/login", name: name, password: password)['auth_token'] || raise('Login failed')
    end

    def get(url, params={})
      params = params.dup
      params[:auth_token] = @auth_token if @auth_token

      uri = URI.parse("#{@domain}#{url}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get_response(uri)
      if (200..399).cover?(response.code.to_i)
        JSON.parse(response.body)
      else
        raise "HTTP error (#{response.code}): GET #{url}"
      end
    end

    def post(url, params={})
      uri = URI.parse("#{@domain}#{url}")
      params = params.dup
      params[:auth_token] = @auth_token if @auth_token
      response = Net::HTTP.post_form(uri, params)
      if (200..399).cover?(response.code.to_i)
        JSON.parse(response.body)
      else
        raise "HTTP error (#{response.code}): POST #{url}"
      end
    end
  end
end
