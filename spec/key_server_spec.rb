require_relative "../key-server"

describe KeyServer do
  it "should create an instance of the key_server" do 
    @key_server = KeyServer.new
    expect(@key_server).to be_instance_of(KeyServer)
  end

  it "should generate keys" do
    @key_server = KeyServer.new
    @key_server.generate_keys
    expect(@key_server.all_keys[:available].size).to eq(10)
    expect(@key_server.all_keys[:used].size).to eq(0)
  end

  it "should return a key" do
    @key_server = KeyServer.new
    @key_server.generate_keys
    expect(@key_server.dispatch_key).to_not eq(nil)
  end

  it "should return only 10 keys in default case" do 
    @key_server = KeyServer.new
    @key_server.generate_keys
    # 10 keys should be returned
    (1..10).each do |num|
      expect(@key_server.dispatch_key).to_not eq(nil)
    end
    # 11th key must be nil
    expect(@key_server.dispatch_key).to eq(nil)
  end

  it "should return n number of keys in non-default behaviour" do 
    n = 16
    @key_server = KeyServer.new
    @key_server.generate_keys(number=n)
    # n keys should be returned
    (1..n).each do |num|
      expect(@key_server.dispatch_key).to_not eq(nil)
    end
    # (n+1)th key must be nil
    expect(@key_server.dispatch_key).to eq(nil)
  end

  

end