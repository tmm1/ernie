require 'ernie'
require 'unicorn'

class Erniecorn < Unicorn::HttpServer
  def initialize(handler, options={})
    @handler = handler
    super nil, options
  end

  def build_app!
    require @handler
  end

  def process_client(client)
    @client = client
    Ernie.process(self, self)
    @client.close
  rescue => e
    handle_error(client, e)
  ensure
    @client = nil
  end

  def read(len)
    data = ''
    while @client.kgio_read!(len - data.bytesize, data) == :wait_readable
      IO.select([@client])
    end
    data
  end

  def write(data)
    @client.kgio_write(data)
  end
end
