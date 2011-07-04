class ResponseStub
  def initialize(filename)
    @filename = filename
  end
  def body
    path = File.expand_path(File.join(File.dirname(__FILE__), "../files", @filename))
    File.open(path).read
  end
end

class RespStub
  def get(path)
    filename = path.split('/').last
    ResponseStub.new(filename)
  end
end

class Net::HTTP
  def self.start(serv)
    yield(RespStub.new)
  end
end
