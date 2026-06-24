control 'nginx' do
  impact 1.0
  title 'nginx is installed and serving'
  desc 'nginx should be installed, running and listening on port 80.'

  describe service('nginx') do
    it { should be_installed }
    it { should be_running }
  end

  describe port(80) do
    it { should be_listening }
  end
end

control 'vector' do
  impact 1.0
  title 'Vector is running and configured'
  desc 'The Vector agent should be running with its config in place.'

  describe service('vector') do
    it { should be_running }
  end

  describe file('/etc/vector/vector.toml') do
    it { should exist }
  end
end
