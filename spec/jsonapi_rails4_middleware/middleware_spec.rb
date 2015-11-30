describe JsonapiRails4Middleware::Middleware do
  let(:app) { ->(input) { [200, input, 'app'] } }
  let(:response_body) { subject.call(env)[1]['rack.input'].read }

  subject { described_class.new(app) }

  context 'when content type is json' do
    context 'when json follows jsonapi spec' do
      context 'POST request' do
        let(:env) do
          Rack::MockRequest.env_for('', 'rack.input' => StringIO.new({
            data: {
              type: 'users',
              attributes: {
                email: 'john.doe@example.com',
                password: '12345678'
              }
            }
          }.to_json),
            'CONTENT_TYPE' => 'application/json',
            'REQUEST_METHOD' => 'POST')
        end

        it 'changes request body' do
          expect(JSON.parse(response_body)).to eq('user' => {
            'email' => 'john.doe@example.com',
            'password' => '12345678'
          })
        end
      end

      context 'PATCH request' do
        let(:env) do
          Rack::MockRequest.env_for('', 'rack.input' => StringIO.new({
            data: {
              type: 'users',
              id: 5,
              attributes: {
                email: 'john.doe@example.com',
                password: '12345678'
              }
            }
          }.to_json),
            'CONTENT_TYPE' => 'application/json',
            'REQUEST_METHOD' => 'PATCH')
        end

        it 'changes request body' do
          expect(JSON.parse(response_body)).to eq(
            'user' => {
              'id' => 5,
              'email' => 'john.doe@example.com',
              'password' => '12345678'
            }
          )
        end
      end
    end

    context 'when json does not follow jsonapi spec' do
      let(:env) do
        Rack::MockRequest.env_for('', 'rack.input' => StringIO.new({
          data: {
            model: 'users',
            params: {
              email: 'john.doe@example.com',
              password: '12345678'
            }
          }
        }.to_json),
          'CONTENT_TYPE' => 'application/json',
          'REQUEST_METHOD' => 'POST')
      end

      it 'does not change request body' do
        expect(JSON.parse(response_body)).to eq(
          'data' => {
            'model' => 'users',
            'params' => {
              'email' => 'john.doe@example.com',
              'password' => '12345678'
            }
          }
        )
      end
    end
  end

  context 'content type is not json' do
    let(:env) do
      Rack::MockRequest.env_for('', 'rack.input' => StringIO.new({
        data: {
          type: 'users',
          attributes: {
            email: 'john.doe@example.com',
            password: '12345678'
          }
        }
      }.to_json),
        'CONTENT_TYPE' => 'text/html',
        'REQUEST_METHOD' => 'POST')
    end

    it 'does not change request body' do
      expect(JSON.parse(response_body)).to eq(
        'data' => {
          'type' => 'users',
          'attributes' => {
            'email' => 'john.doe@example.com',
            'password' => '12345678'
          }
        }
      )
    end
  end

  context 'content body is empty' do
    let(:env) do
      Rack::MockRequest.env_for('',
        'rack.input' => StringIO.new({}.to_json),
        'CONTENT_TYPE' => 'text/html',
        'REQUEST_METHOD' => 'POST')
    end

    it 'does not change request body' do
      expect(JSON.parse(response_body)).to eq({})
    end
  end
end
