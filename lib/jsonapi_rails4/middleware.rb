module JsonapiRails4
  class Middleware
    def initialize(app)
      @app = app
    end
    
    def call(env)
      @env = env
      process_json if json? && jsonapi?
      @app.call(@env)
    end

    private

    def process_json
      params = {}
      params[json_params['data']['type'].singularize] = json_params['data']['attributes']
      @env['rack.input'] = StringIO.new(params.to_json)
    end

    def json?
      request.content_type == 'application/json'
    end

    def jsonapi?
      json_params['data'] && json_params['data']['attributes'] && json_params['data']['type']
    end

    def json_params
      @params ||= JSON.parse(request.body.read)
      request.body.rewind
      @params
    end

    def request
      Rack::Request.new(@env)
    end
  end
end
