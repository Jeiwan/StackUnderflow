shared_examples_for "an API" do |has, hasnt, path, resource|
  has.each do |attr|
    it "returns #{resource.to_s} #{attr}" do
      if send(resource).respond_to?(attr.to_sym)
        expect(response.body).to be_json_eql(send(resource).send(attr.to_sym).to_json).at_path("#{path}#{attr}")
      else
        expect(response.body).to have_json_path("#{path}#{attr}")
      end
    end
  end if has

  hasnt.each do |attr|
    it "doesn't return #{resource.to_s} #{attr}" do
      expect(response.body).not_to have_json_path("#{path}#{attr}")
    end
  end if hasnt
end

shared_examples_for "an authenticatable API" do
  context "when access token is absent" do
    it "returns 401 status code" do
      request_json
      expect(response.status).to eq 401
    end
  end

  context "when access token is invalid" do
    it "returns 401 status code" do
      request_json access_token: '12345'
      expect(response.status).to eq 401
    end
  end
end
